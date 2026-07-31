[CmdletBinding()]
param(
	[switch]$Detailed,
	[switch]$Strict
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$vendorRoot = Join-Path $repositoryRoot 'src/Code/_libs'
$legacyRoot = Join-Path $repositoryRoot 'src/Legacy'
$assetRoots = @('src/Icons', 'src/Images', 'src/Maps', 'src/Sound')
$assetExtensions = @('.dmi', '.png', '.jpg', '.gif', '.ogg', '.wav', '.mp3', '.mid', '.rtf')
$generatedAliases = @{
	'nexus_creator_backdrop.png' = $true
}
$assetsByName = New-Object 'Collections.Generic.Dictionary[string,Collections.Generic.List[string]]' ([StringComparer]::OrdinalIgnoreCase)
$assetsByRelativePath = New-Object 'Collections.Generic.Dictionary[string,string]' ([StringComparer]::OrdinalIgnoreCase)
$issues = New-Object 'Collections.Generic.List[object]'
$scanFiles = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)

function Get-RelativePath {
	param([string]$FullPath)
	return $FullPath.Substring($repositoryRoot.Length + 1).Replace('\', '/')
}

function Add-Asset {
	param([string]$FullPath)

	$relativePath = Get-RelativePath $FullPath
	$fileName = [IO.Path]::GetFileName($FullPath)
	if(!$assetsByName.ContainsKey($fileName)) {
		$assetsByName.Add($fileName, (New-Object 'Collections.Generic.List[string]'))
	}
	$assetsByName[$fileName].Add($FullPath)
	$assetsByRelativePath[$relativePath] = $FullPath
}

function Add-ReferenceIssue {
	param(
		[string]$Category,
		[string]$Path,
		[int]$Line,
		[string]$Resource,
		[string]$Detail
	)

	$issues.Add([pscustomobject]@{
		Category = $Category
		Path = $Path
		Line = $Line
		Resource = $Resource
		Detail = $Detail
	})
}

function Get-CodeWithoutComments {
	param(
		[string]$Line,
		[ref]$InBlockComment
	)

	$remaining = $Line
	$result = ''
	while($remaining.Length -gt 0) {
		if($InBlockComment.Value) {
			$commentEnd = $remaining.IndexOf('*/', [StringComparison]::Ordinal)
			if($commentEnd -lt 0) {
				return $result
			}
			$remaining = $remaining.Substring($commentEnd + 2)
			$InBlockComment.Value = $false
			continue
		}

		$lineComment = $remaining.IndexOf('//', [StringComparison]::Ordinal)
		$blockComment = $remaining.IndexOf('/*', [StringComparison]::Ordinal)
		if($lineComment -ge 0 -and ($blockComment -lt 0 -or $lineComment -lt $blockComment)) {
			$result += $remaining.Substring(0, $lineComment)
			return $result
		}
		if($blockComment -ge 0) {
			$result += $remaining.Substring(0, $blockComment)
			$remaining = $remaining.Substring($blockComment + 2)
			$InBlockComment.Value = $true
			continue
		}

		$result += $remaining
		return $result
	}
	return $result
}

foreach($assetRoot in $assetRoots) {
	$fullAssetRoot = Join-Path $repositoryRoot $assetRoot
	foreach($fullPath in [IO.Directory]::EnumerateFiles($fullAssetRoot, '*', [IO.SearchOption]::AllDirectories)) {
		Add-Asset $fullPath
	}
}

$codeRoot = Join-Path $repositoryRoot 'src/Code'
foreach($fullPath in [IO.Directory]::EnumerateFiles($codeRoot, '*', [IO.SearchOption]::AllDirectories)) {
	if($fullPath.StartsWith($vendorRoot, [StringComparison]::OrdinalIgnoreCase)) {
		continue
	}
	$extension = [IO.Path]::GetExtension($fullPath).ToLowerInvariant()
	if($extension -in $assetExtensions) {
		Add-Asset $fullPath
	}
	if($extension -in @('.dm', '.dmf')) {
		[void]$scanFiles.Add($fullPath)
	}
}

foreach($fullPath in [IO.Directory]::EnumerateFiles((Join-Path $repositoryRoot 'src/Maps'), '*.dmm', [IO.SearchOption]::AllDirectories)) {
	[void]$scanFiles.Add($fullPath)
}
[void]$scanFiles.Add((Join-Path $repositoryRoot 'UI.dmf'))

$resourcePattern = New-Object Text.RegularExpressions.Regex("'(?<resource>[^'\r\n]+\.(?:dmi|png|jpg|gif|ogg|wav|mp3|mid|rtf))'", ([Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [Text.RegularExpressions.RegexOptions]::CultureInvariant))
$referenceCount = 0
foreach($fullPath in $scanFiles) {
	if($fullPath.StartsWith($vendorRoot, [StringComparison]::OrdinalIgnoreCase) -or $fullPath.StartsWith($legacyRoot, [StringComparison]::OrdinalIgnoreCase)) {
		continue
	}
	$relativeSourcePath = Get-RelativePath $fullPath
	$lines = [IO.File]::ReadAllLines($fullPath)
	$inBlockComment = $false
	for($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
		$code = Get-CodeWithoutComments $lines[$lineIndex] ([ref]$inBlockComment)
		foreach($match in $resourcePattern.Matches($code)) {
			$referenceCount++
			$resource = $match.Groups['resource'].Value
			if($generatedAliases.ContainsKey($resource)) {
				continue
			}
			if($resource.Contains('/') -or $resource.Contains('\')) {
				$relativeResource = $resource.Replace('\', '/')
				if($assetsByRelativePath.ContainsKey($relativeResource)) {
					$actualRelativePath = Get-RelativePath $assetsByRelativePath[$relativeResource]
					if($resource.Replace('\', '/') -cne $actualRelativePath) {
						Add-ReferenceIssue 'Case' $relativeSourcePath ($lineIndex + 1) $resource "Expected $actualRelativePath"
					}
				}
				else {
					Add-ReferenceIssue 'Missing' $relativeSourcePath ($lineIndex + 1) $resource 'Explicit asset path does not exist'
				}
				continue
			}

			if(!$assetsByName.ContainsKey($resource)) {
				Add-ReferenceIssue 'Missing' $relativeSourcePath ($lineIndex + 1) $resource 'No asset has this basename'
				continue
			}
			$candidates = $assetsByName[$resource]
			if($candidates.Count -gt 1) {
				$candidateList = @($candidates | ForEach-Object { Get-RelativePath $_ }) -join ', '
				Add-ReferenceIssue 'Ambiguous' $relativeSourcePath ($lineIndex + 1) $resource $candidateList
				continue
			}
			$actualName = [IO.Path]::GetFileName($candidates[0])
			if($resource -cne $actualName) {
				Add-ReferenceIssue 'Case' $relativeSourcePath ($lineIndex + 1) $resource "Expected $actualName"
			}
		}
	}
}

Write-Host "Asset reference audit: $referenceCount active references across $($scanFiles.Count) files"
foreach($category in @('Missing', 'Ambiguous', 'Case')) {
	$count = @($issues | Where-Object Category -eq $category).Count
	Write-Host ("{0,-11} {1,6}" -f ($category + ':'), $count)
}
Write-Host ("{0,-11} {1,6}" -f 'Total:', $issues.Count)

if($Detailed -and $issues.Count -gt 0) {
	$issues |
		Sort-Object Category, Path, Line, Resource |
		Format-Table Category, Path, Line, Resource, Detail -AutoSize
}

if($Strict -and $issues.Count -gt 0) {
	throw "Asset reference audit found $($issues.Count) issues."
}
