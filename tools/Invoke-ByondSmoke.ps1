[CmdletBinding()]
param(
	[ValidateSet('Versioned', 'Clean', 'Both')]
	[string]$DataMode = 'Both',
	[int]$StartupTimeoutSeconds = 180,
	[int]$ObservationSeconds = 30,
	[string]$ByondArchivePath,
	[switch]$CompileOnly,
	[switch]$KeepTemp
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ByondVersion = '516.1686'
$ByondUrl = 'https://www.byond.com/download/build/516/516.1686_byond.zip'
$ByondSha256 = '2e355847d2080f6ff83ffba2b62b66574a4939e110323669d843f8afb7b5ace3'

function Repair-ProcessEnvironmentPath {
	$environment = [Environment]::GetEnvironmentVariables([EnvironmentVariableTarget]::Process)
	$pathKeys = @($environment.Keys | Where-Object {
		[string]::Equals([string]$_, 'Path', [StringComparison]::OrdinalIgnoreCase)
	})
	if($pathKeys.Count -le 1) {
		return
	}

	$canonicalKey = @($pathKeys | Where-Object { [string]$_ -ceq 'Path' } | Select-Object -First 1)
	if($canonicalKey.Count -eq 0) {
		$canonicalKey = @($pathKeys[0])
	}
	$pathValue = [string]$environment[$canonicalKey[0]]

	foreach($pathKey in $pathKeys) {
		if([string]$pathKey -cne [string]$canonicalKey[0]) {
			Remove-Item -LiteralPath "Env:$pathKey" -ErrorAction SilentlyContinue
		}
	}
	[Environment]::SetEnvironmentVariable('Path', $pathValue, [EnvironmentVariableTarget]::Process)
}

Repair-ProcessEnvironmentPath

function Copy-WorkingTree {
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
		$sourcePath = Join-Path $RepositoryRoot $relativePath
		if(![IO.File]::Exists($sourcePath)) {
			continue
		}

		$destinationPath = Join-Path $Destination $relativePath
		$destinationParent = [IO.Path]::GetDirectoryName($destinationPath)
		[IO.Directory]::CreateDirectory($destinationParent) | Out-Null
		[IO.File]::Copy($sourcePath, $destinationPath, $true)
	}
}

function Get-AvailableTcpPort {
	$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0)
	$listener.Start()
	try {
		return ([Net.IPEndPoint]$listener.LocalEndpoint).Port
	}
	finally {
		$listener.Stop()
	}
}

function Test-TcpPort {
	param([int]$Port)

	$client = New-Object Net.Sockets.TcpClient
	try {
		$connect = $client.BeginConnect('127.0.0.1', $Port, $null, $null)
		if(!$connect.AsyncWaitHandle.WaitOne(500)) {
			return $false
		}
		$client.EndConnect($connect)
		return $true
	}
	catch {
		return $false
	}
	finally {
		$client.Close()
	}
}

function Get-LogText {
	param([string]$Path)

	if(![IO.File]::Exists($Path)) {
		return ''
	}

	$stream = [IO.File]::Open($Path, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite)
	$reader = New-Object IO.StreamReader($stream)
	try {
		return $reader.ReadToEnd()
	}
	finally {
		$reader.Dispose()
		$stream.Dispose()
	}
}

function Assert-CleanLogs {
	param([string[]]$Paths)

	foreach($path in $Paths) {
		$contents = Get-LogText $path
		if($contents -match '(?im)^\s*(runtime error:|warning:)') {
			throw "Runtime diagnostic found in $path"
		}
	}
}

function Quote-NativeArgument {
	param([string]$Value)
	return '"' + $Value.Replace('"', '\"') + '"'
}

function Invoke-WorldSmoke {
	param(
		[string]$DreamDaemonPath,
		[string]$DmbPath,
		[string]$RunDirectory,
		[string]$Label,
		[int]$StartupTimeout,
		[int]$ObservationTime
	)

	[IO.Directory]::CreateDirectory($RunDirectory) | Out-Null
	$port = Get-AvailableTcpPort
	$daemonLog = Join-Path $RunDirectory 'dreamdaemon.log'
	$worldLog = Join-Path $RunDirectory 'Errors.log'
	$stdoutLog = Join-Path $RunDirectory 'dreamdaemon.stdout.log'
	$stderrLog = Join-Path $RunDirectory 'dreamdaemon.stderr.log'
	$logs = @($daemonLog, $worldLog, $stdoutLog, $stderrLog)

	foreach($log in $logs) {
		if([IO.File]::Exists($log)) {
			[IO.File]::Delete($log)
		}
	}

	$arguments = @(
		(Quote-NativeArgument $DmbPath),
		$port,
		'-safe',
		'-invisible',
		'-params',
		'nexus_smoke_tests=1',
		'-cd',
		(Quote-NativeArgument $RunDirectory),
		'-log',
		(Quote-NativeArgument $daemonLog)
	)

	Write-Host "Starting $Label smoke test on port $port..."
	$process = $null
	try {
		$process = Start-Process `
			-FilePath $DreamDaemonPath `
			-ArgumentList $arguments `
			-WorkingDirectory $RunDirectory `
			-RedirectStandardOutput $stdoutLog `
			-RedirectStandardError $stderrLog `
			-WindowStyle Hidden `
			-PassThru

		$startupDeadline = [DateTime]::UtcNow.AddSeconds($StartupTimeout)
		$ready = $false
		while([DateTime]::UtcNow -lt $startupDeadline) {
			$process.Refresh()
			if($process.HasExited) {
				$process.WaitForExit()
				throw "Dream Daemon exited during $Label startup with code $($process.ExitCode)."
			}

			Assert-CleanLogs $logs
			$daemonOutput = Get-LogText $daemonLog
			$worldOutput = Get-LogText $worldLog
			if((Test-TcpPort $port) -and
				$daemonOutput -match "World opened on network port $port\." -and
				$worldOutput -match 'NEXUS_SMOKE_TESTS_PASSED' -and
				$worldOutput -match 'NEXUS_INITIALIZATION_COMPLETE') {
				$ready = $true
				break
			}
			Start-Sleep -Milliseconds 250
		}

		if(!$ready) {
			throw "$Label world did not become ready within $StartupTimeout seconds."
		}

		$observationDeadline = [DateTime]::UtcNow.AddSeconds($ObservationTime)
		while([DateTime]::UtcNow -lt $observationDeadline) {
			$process.Refresh()
			if($process.HasExited) {
				$process.WaitForExit()
				throw "Dream Daemon exited during $Label observation with code $($process.ExitCode)."
			}
			Assert-CleanLogs $logs
			Start-Sleep -Milliseconds 500
		}

		Assert-CleanLogs $logs
		Write-Host "$Label smoke test passed."
	}
	finally {
		if($null -ne $process) {
			$process.Refresh()
			if(!$process.HasExited) {
				Stop-Process -Id $process.Id -Force
				Wait-Process -Id $process.Id -ErrorAction SilentlyContinue
			}
			Start-Sleep -Seconds 1
		}
	}
}

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("Nexus-Exodus-smoke-" + [Guid]::NewGuid().ToString('N'))
$worldDirectory = Join-Path $tempRoot 'world'
$toolsDirectory = Join-Path ([IO.Path]::GetTempPath()) "Nexus-Exodus-BYOND-$ByondVersion"
$archivePath = Join-Path $toolsDirectory "BYOND-$ByondVersion.zip"
$succeeded = $false
$previousByondSystem = $env:BYOND_SYSTEM
$previousCompatibilityLayer = $env:__COMPAT_LAYER
$cacheMutex = New-Object Threading.Mutex($false, 'Local\NexusExodusByond5161686')
$cacheLockTaken = $false

try {
	try {
		$cacheLockTaken = $cacheMutex.WaitOne([TimeSpan]::FromMinutes(5))
	}
	catch [Threading.AbandonedMutexException] {
		$cacheLockTaken = $true
	}
	if(!$cacheLockTaken) {
		throw 'Timed out waiting for the shared BYOND tool cache.'
	}
	[IO.Directory]::CreateDirectory($toolsDirectory) | Out-Null
	Copy-WorkingTree $repositoryRoot $worldDirectory

	if($ByondArchivePath) {
		$resolvedArchive = (Resolve-Path $ByondArchivePath).Path
		$providedHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $resolvedArchive).Hash.ToLowerInvariant()
		if($providedHash -ne $ByondSha256) {
			throw "BYOND archive hash mismatch. Expected $ByondSha256, received $providedHash."
		}
		$replaceCachedArchive = ![IO.File]::Exists($archivePath)
		if(!$replaceCachedArchive) {
			$cachedHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $archivePath).Hash.ToLowerInvariant()
			$replaceCachedArchive = $cachedHash -ne $ByondSha256
		}
		if($replaceCachedArchive) {
			[IO.File]::Copy($resolvedArchive, $archivePath, $true)
		}
	}
	else {
		if([IO.File]::Exists($archivePath)) {
			$cachedHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $archivePath).Hash.ToLowerInvariant()
			if($cachedHash -ne $ByondSha256) {
				[IO.File]::Delete($archivePath)
			}
		}
		if(![IO.File]::Exists($archivePath)) {
			Write-Host "Downloading BYOND $ByondVersion..."
			$downloadPath = "$archivePath.download"
			Invoke-WebRequest -UseBasicParsing -Uri $ByondUrl -OutFile $downloadPath
			[IO.File]::Move($downloadPath, $archivePath)
		}
	}

	$actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $archivePath).Hash.ToLowerInvariant()
	if($actualHash -ne $ByondSha256) {
		throw "BYOND archive hash mismatch. Expected $ByondSha256, received $actualHash."
	}

	$byondDirectory = Join-Path $toolsDirectory 'byond'
	$byondBin = Join-Path $byondDirectory 'bin'
	$dreamMakerPath = Join-Path $byondBin 'dm.exe'
	$dreamDaemonPath = Join-Path $byondBin 'dd.exe'
	if(![IO.File]::Exists($dreamMakerPath) -or ![IO.File]::Exists($dreamDaemonPath)) {
		if([IO.Directory]::Exists($byondDirectory)) {
			[IO.Directory]::Delete($byondDirectory, $true)
		}
		Expand-Archive -LiteralPath $archivePath -DestinationPath $toolsDirectory
	}
	if(![IO.File]::Exists($dreamMakerPath) -or ![IO.File]::Exists($dreamDaemonPath)) {
		throw 'The BYOND archive does not contain dm.exe and dd.exe.'
	}

	$toolVersion = [Diagnostics.FileVersionInfo]::GetVersionInfo($dreamDaemonPath).FileVersion
	$compilerVersion = [Diagnostics.FileVersionInfo]::GetVersionInfo($dreamMakerPath).FileVersion
	if(!$toolVersion -or !$compilerVersion -or !$toolVersion.Contains($ByondVersion) -or !$compilerVersion.Contains($ByondVersion)) {
		[IO.Directory]::Delete($byondDirectory, $true)
		Expand-Archive -LiteralPath $archivePath -DestinationPath $toolsDirectory
		$toolVersion = [Diagnostics.FileVersionInfo]::GetVersionInfo($dreamDaemonPath).FileVersion
		$compilerVersion = [Diagnostics.FileVersionInfo]::GetVersionInfo($dreamMakerPath).FileVersion
	}
	if(!$toolVersion -or !$compilerVersion -or !$toolVersion.Contains($ByondVersion) -or !$compilerVersion.Contains($ByondVersion)) {
		throw "Unexpected BYOND tool versions: Dream Daemon $toolVersion; Dream Maker $compilerVersion"
	}
	if($cacheLockTaken) {
		$cacheMutex.ReleaseMutex()
		$cacheLockTaken = $false
	}

	$env:BYOND_SYSTEM = $byondDirectory
	$env:__COMPAT_LAYER = 'RunAsInvoker'
	Write-Host "Compiling with BYOND $ByondVersion..."
	Push-Location $worldDirectory
	try {
		$compilerLines = @(& $dreamMakerPath DU.dme 2>&1)
		$compilerExitCode = $LASTEXITCODE
	}
	finally {
		Pop-Location
	}
	$compilerOutput = $compilerLines -join [Environment]::NewLine
	$compilerOutput
	if($compilerExitCode -ne 0) {
		throw "Dream Maker failed with exit code $compilerExitCode."
	}
	if($compilerOutput -notmatch '0 errors, 0 warnings') {
		throw 'Compilation did not finish with 0 errors and 0 warnings.'
	}
	foreach($requiredMap in @('src/Maps/Map2018.dmm', 'src/Maps/Space2018.dmm')) {
		if($compilerOutput.Replace('\', '/') -notmatch [regex]::Escape("loading $requiredMap")) {
			throw "Compilation did not load required map: $requiredMap"
		}
	}

	$dmbPath = Join-Path $worldDirectory 'DU.dmb'
	$rscPath = Join-Path $worldDirectory 'DU.rsc'
	if(![IO.File]::Exists($dmbPath) -or ![IO.File]::Exists($rscPath)) {
		throw 'Compilation did not produce DU.dmb and DU.rsc.'
	}

	if(!$CompileOnly) {
		if($DataMode -in @('Versioned', 'Both')) {
			Invoke-WorldSmoke $dreamDaemonPath $dmbPath $worldDirectory 'Versioned data' $StartupTimeoutSeconds $ObservationSeconds
		}
		if($DataMode -in @('Clean', 'Both')) {
			$cleanRunDirectory = Join-Path $worldDirectory '.smoke-clean'
			Invoke-WorldSmoke $dreamDaemonPath $dmbPath $cleanRunDirectory 'Clean data' $StartupTimeoutSeconds $ObservationSeconds
		}
	}

	$succeeded = $true
	if($CompileOnly) {
		Write-Host 'BYOND compile passed. Dream Daemon was not started.'
	}
	else {
		Write-Host 'BYOND compile and smoke tests passed.'
	}
}
catch {
	Write-Host "Smoke test failed: $($_.Exception.Message)"
	Get-ChildItem -LiteralPath $tempRoot -Recurse -File -Filter '*.log' -ErrorAction SilentlyContinue | ForEach-Object {
		Write-Host "===== $($_.FullName) ====="
		Get-LogText $_.FullName
	}
	throw
}
finally {
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
	if($cacheLockTaken) {
		$cacheMutex.ReleaseMutex()
	}
	$cacheMutex.Dispose()

	if($succeeded -and !$KeepTemp) {
		[IO.Directory]::Delete($tempRoot, $true)
	}
	else {
		Write-Host "Smoke test files: $tempRoot"
	}
}
