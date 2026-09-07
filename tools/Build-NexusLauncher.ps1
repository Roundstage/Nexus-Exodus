[CmdletBinding()]
param(
	[Parameter(Mandatory)]
	[string]$DistributionKeyPath,
	[string]$Version = '0.1.0.1 internal',
	[string]$ByondCompilerArchivePath,
	[string]$ByondExeArchivePath,
	[string]$OutputDirectory,
	[switch]$KeepTemp
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$CompilerVersion = '516.1686'
$CompilerSha256 = '2e355847d2080f6ff83ffba2b62b66574a4939e110323669d843f8afb7b5ace3'
$ByondExeVersion = '516.1687'
$ByondExeSha256 = 'fe2cb843ec8591269d7b0b43a1ae84b01dbd6edc2db4e22a7a0bbc03bd8b6c02'

function Assert-ArchiveHash {
	param(
		[string]$Path,
		[string]$Expected,
		[string]$Label
	)

	if(![IO.File]::Exists($Path)) {
		throw "$Label archive not found: $Path"
	}
	$actual = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
	if($actual -ne $Expected) {
		throw "$Label archive hash mismatch. Expected $Expected, received $actual."
	}
}

function Copy-SanitizedWorkingTree {
	param(
		[string]$RepositoryRoot,
		[string]$Destination
	)

	[IO.Directory]::CreateDirectory($Destination) | Out-Null
	$relativePaths = @(& git -C $RepositoryRoot -c core.quotepath=false ls-files --cached --others --exclude-standard)
	if($LASTEXITCODE -ne 0) {
		throw 'Unable to enumerate the Git working tree.'
	}

	foreach($relativePath in $relativePaths) {
		$normalized = $relativePath.Replace('\', '/')
		if($normalized -ieq 'SECRETS.dm' -or
			$normalized -like 'artifacts/*' -or
			$normalized -match '(?i)\.(dmb|rsc|dyn\.rsc)$') {
			continue
		}
		$sourcePath = Join-Path $RepositoryRoot $relativePath
		if(![IO.File]::Exists($sourcePath)) {
			continue
		}
		$destinationPath = Join-Path $Destination $relativePath
		[IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($destinationPath)) | Out-Null
		[IO.File]::Copy($sourcePath, $destinationPath, $true)
	}

	$templatePath = Join-Path $Destination 'SecretsExample.dm'
	if(![IO.File]::Exists($templatePath)) {
		throw 'SecretsExample.dm is required to create a sanitized launcher build.'
	}
	[IO.File]::Copy($templatePath, (Join-Path $Destination 'SECRETS.dm'), $false)
}

function Get-GitValue {
	param(
		[string]$RepositoryRoot,
		[string[]]$Arguments
	)

	$value = (& git -C $RepositoryRoot @Arguments 2>$null) -join ''
	if($LASTEXITCODE -ne 0) {
		return $null
	}
	return $value.Trim()
}

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$resolvedKeyPath = (Resolve-Path -LiteralPath $DistributionKeyPath).Path
if($resolvedKeyPath.StartsWith($repositoryRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
	throw 'The BYOND Distribution Key file must be stored outside the repository.'
}

$keyLines = @(Get-Content -LiteralPath $resolvedKeyPath)
if($keyLines.Count -ne 1 -or [string]::IsNullOrWhiteSpace($keyLines[0])) {
	throw 'The Distribution Key file must contain exactly one non-empty line.'
}
$distributionKey = $keyLines[0].Trim()
$keyLines = $null

if(!$ByondCompilerArchivePath) {
	$ByondCompilerArchivePath = Join-Path ([IO.Path]::GetTempPath()) "Nexus-Exodus-BYOND-$CompilerVersion\BYOND-$CompilerVersion.zip"
}
if(!$ByondExeArchivePath) {
	$ByondExeArchivePath = Join-Path ([IO.Path]::GetTempPath()) "NexusExodus-ByondExe-$ByondExeVersion\${ByondExeVersion}_byondexe.zip"
}
if(!$OutputDirectory) {
	$safeVersion = ($Version -replace '[^A-Za-z0-9._-]', '-')
	$OutputDirectory = Join-Path $repositoryRoot "artifacts\launcher\$safeVersion"
}

$resolvedCompilerArchive = (Resolve-Path -LiteralPath $ByondCompilerArchivePath).Path
$resolvedByondExeArchive = (Resolve-Path -LiteralPath $ByondExeArchivePath).Path
Assert-ArchiveHash $resolvedCompilerArchive $CompilerSha256 'BYOND compiler'
Assert-ArchiveHash $resolvedByondExeArchive $ByondExeSha256 'BYONDexe'

$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ('Nexus-Exodus-launcher-' + [Guid]::NewGuid().ToString('N'))
$sourceDirectory = Join-Path $tempRoot 'source'
$compilerDirectory = Join-Path $tempRoot 'compiler'
$vendorDirectory = Join-Path $tempRoot 'vendor'
$vendorConfigPath = $null
$succeeded = $false
$previousByondSystem = $env:BYOND_SYSTEM
$previousCompatibilityLayer = $env:__COMPAT_LAYER

try {
	Copy-SanitizedWorkingTree $repositoryRoot $sourceDirectory
	Expand-Archive -LiteralPath $resolvedCompilerArchive -DestinationPath $compilerDirectory
	Expand-Archive -LiteralPath $resolvedByondExeArchive -DestinationPath $vendorDirectory

	$dreamMakerPath = Join-Path $compilerDirectory 'byond\bin\dm.exe'
	$byondSystem = Join-Path $compilerDirectory 'byond'
	$byondExeRoot = Join-Path $vendorDirectory 'byondexe'
	$byondExePath = Join-Path $byondExeRoot 'byondexe.exe'
	$includeDirectory = Join-Path $byondExeRoot 'setup\cfg'
	if(![IO.File]::Exists($dreamMakerPath) -or ![IO.File]::Exists($byondExePath)) {
		throw 'A required Dream Maker or BYONDexe executable is missing from the pinned archives.'
	}

	$env:BYOND_SYSTEM = $byondSystem
	$env:__COMPAT_LAYER = 'RunAsInvoker'
	Write-Host "Compiling Nexus Exodus with BYOND $CompilerVersion..."
	Push-Location $sourceDirectory
	try {
		$compilerLines = @(& $dreamMakerPath DU.dme 2>&1)
		$compilerExitCode = $LASTEXITCODE
	}
	finally {
		Pop-Location
	}
	$compilerOutput = $compilerLines -join [Environment]::NewLine
	$compilerOutput
	if($compilerExitCode -ne 0 -or $compilerOutput -notmatch '0 errors, 0 warnings') {
		throw "Dream Maker did not produce a clean build (exit code $compilerExitCode)."
	}

	$dmbPath = Join-Path $sourceDirectory 'DU.dmb'
	$rscPath = Join-Path $sourceDirectory 'DU.rsc'
	if(![IO.File]::Exists($dmbPath) -or ![IO.File]::Exists($rscPath)) {
		throw 'Dream Maker did not produce matching DU.dmb and DU.rsc files.'
	}

	$packageDirectory = Join-Path $tempRoot 'hub-package'
	[IO.Directory]::CreateDirectory($packageDirectory) | Out-Null
	[IO.File]::Copy($dmbPath, (Join-Path $packageDirectory 'DU.dmb'), $false)
	[IO.File]::Copy($rscPath, (Join-Path $packageDirectory 'DU.rsc'), $false)
	$hubZipPath = Join-Path $includeDirectory 'hub.zip'
	Compress-Archive -Path (Join-Path $packageDirectory '*') -DestinationPath $hubZipPath -CompressionLevel Optimal

	$launcherConfigDirectory = Join-Path $sourceDirectory 'launcher\cfg'
	foreach($configFile in @('hub.ini', 'hub.html')) {
		$sourceConfig = Join-Path $launcherConfigDirectory $configFile
		if(![IO.File]::Exists($sourceConfig)) {
			throw "Launcher configuration is missing: $configFile"
		}
		[IO.File]::Copy($sourceConfig, (Join-Path $includeDirectory $configFile), $true)
	}
	$themePath = Join-Path $launcherConfigDirectory 'hub.theme.css'
	$vendorCssPath = Join-Path $includeDirectory 'hub.css'
	if(![IO.File]::Exists($themePath) -or ![IO.File]::Exists($vendorCssPath)) {
		throw 'The Nexus theme or vendor hub.css is missing.'
	}
	[IO.File]::AppendAllText(
		$vendorCssPath,
		[Environment]::NewLine + (Get-Content -LiteralPath $themePath -Raw),
		[Text.UTF8Encoding]::new($false)
	)

	$launcherExeName = 'NexusExodus.exe'
	$vendorConfigPath = Join-Path $byondExeRoot 'byondexe.ini'
	$vendorConfig = @(
		"key = $distributionKey"
		'byond = setup/bin'
		'include = setup/cfg'
		"exe = $launcherExeName"
		'company = Nexus Exodus'
		'product = Nexus Exodus'
		"version = $Version"
	) -join [Environment]::NewLine
	[IO.File]::WriteAllText($vendorConfigPath, $vendorConfig, [Text.UTF8Encoding]::new($false))
	$vendorConfig = $null

	Write-Host "Generating $launcherExeName with BYONDexe $ByondExeVersion..."
	Push-Location $byondExeRoot
	try {
		$byondExeLines = @(& $byondExePath 2>&1)
		$byondExeExitCode = $LASTEXITCODE
	}
	finally {
		[IO.File]::Delete($vendorConfigPath)
		$distributionKey = $null
		Pop-Location
	}
	$byondExeOutput = $byondExeLines -join [Environment]::NewLine
	$byondExeOutput
	$generatedExePath = Join-Path $byondExeRoot $launcherExeName
	if($byondExeExitCode -ne 0 -or ![IO.File]::Exists($generatedExePath)) {
		throw "BYONDexe failed to generate the launcher (exit code $byondExeExitCode)."
	}

	[IO.Directory]::CreateDirectory($OutputDirectory) | Out-Null
	$outputExePath = Join-Path $OutputDirectory $launcherExeName
	[IO.File]::Copy($generatedExePath, $outputExePath, $true)

	$commit = Get-GitValue $repositoryRoot @('rev-parse', 'HEAD')
	$dirty = [bool](Get-GitValue $repositoryRoot @('status', '--porcelain'))
	$manifest = [ordered]@{
		product = 'Nexus Exodus'
		version = $Version
		built_at_utc = [DateTime]::UtcNow.ToString('o')
		source_commit = $commit
		source_worktree_dirty = $dirty
		compiler_version = $CompilerVersion
		compiler_archive_sha256 = $CompilerSha256
		byondexe_version = $ByondExeVersion
		byondexe_archive_sha256 = $ByondExeSha256
		files = @(
			[ordered]@{
				name = $launcherExeName
				size = (Get-Item -LiteralPath $outputExePath).Length
				sha256 = (Get-FileHash -LiteralPath $outputExePath -Algorithm SHA256).Hash.ToLowerInvariant()
			}
		)
	}
	$manifestPath = Join-Path $OutputDirectory 'manifest.json'
	[IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 5), [Text.UTF8Encoding]::new($false))
	$sumPath = Join-Path $OutputDirectory 'SHA256SUMS.txt'
	[IO.File]::WriteAllText($sumPath, "$($manifest.files[0].sha256)  $launcherExeName$([Environment]::NewLine)", [Text.UTF8Encoding]::new($false))

	$succeeded = $true
	Write-Host "Launcher created: $outputExePath"
}
finally {
	$distributionKey = $null
	$keyLines = $null
	$vendorConfig = $null
	if($vendorConfigPath -and [IO.File]::Exists($vendorConfigPath)) {
		[IO.File]::Delete($vendorConfigPath)
	}
	if($null -eq $previousByondSystem) {
		Remove-Item Env:BYOND_SYSTEM -ErrorAction SilentlyContinue
	}
	else {
		$env:BYOND_SYSTEM = $previousByondSystem
	}
	if($null -eq $previousCompatibilityLayer) {
		Remove-Item Env:__COMPAT_LAYER -ErrorAction SilentlyContinue
	}
	else {
		$env:__COMPAT_LAYER = $previousCompatibilityLayer
	}

	if([IO.Directory]::Exists($tempRoot) -and (!$KeepTemp -or $succeeded)) {
		[IO.Directory]::Delete($tempRoot, $true)
	}
	elseif([IO.Directory]::Exists($tempRoot)) {
		Write-Host "Launcher staging directory retained for diagnostics: $tempRoot"
	}
}
