[CmdletBinding()]
param(
	[switch]$Detailed,
	[switch]$PathStrict,
	[switch]$Strict
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$environmentPath = Join-Path $repositoryRoot 'DU.dme'
$issues = New-Object 'Collections.Generic.List[object]'
$sourceFiles = New-Object 'Collections.Generic.List[object]'
$sourceDirectories = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
$nativeCallbacks = @{
	'AllowUpload' = $true
	'Bump' = $true
	'Click' = $true
	'Close' = $true
	'Command' = $true
	'Cross' = $true
	'Crossed' = $true
	'DblClick' = $true
	'Del' = $true
	'Enter' = $true
	'Entered' = $true
	'Exit' = $true
	'Exited' = $true
	'Export' = $true
	'Import' = $true
	'Login' = $true
	'Logout' = $true
	'MouseDown' = $true
	'MouseDrag' = $true
	'MouseDrop' = $true
	'MouseEntered' = $true
	'MouseExited' = $true
	'MouseMove' = $true
	'MouseUp' = $true
	'MouseWheel' = $true
	'Move' = $true
	'New' = $true
	'North' = $true
	'Northeast' = $true
	'Northwest' = $true
	'Read' = $true
	'South' = $true
	'Southeast' = $true
	'Southwest' = $true
	'Stat' = $true
	'Topic' = $true
	'Uncross' = $true
	'Uncrossed' = $true
	'West' = $true
	'Write' = $true
}
$builtInTypeSegments = @{
	'area' = $true
	'atom' = $true
	'client' = $true
	'datum' = $true
	'exception' = $true
	'icon' = $true
	'image' = $true
	'list' = $true
	'matrix' = $true
	'mob' = $true
	'mutable_appearance' = $true
	'obj' = $true
	'regex' = $true
	'savefile' = $true
	'sound' = $true
	'turf' = $true
	'world' = $true
}
$variableScopeSegments = @{
	'area' = $true
	'atom' = $true
	'client' = $true
	'const' = $true
	'datum' = $true
	'global' = $true
	'icon' = $true
	'image' = $true
	'list' = $true
	'matrix' = $true
	'mob' = $true
	'obj' = $true
	'regex' = $true
	'savefile' = $true
	'sound' = $true
	'static' = $true
	'tmp' = $true
	'turf' = $true
	'world' = $true
}

function Add-NamingIssue {
	param(
		[string]$Category,
		[string]$Path,
		[int]$Line,
		[string]$Name,
		[string]$Expected
	)

	$issues.Add([pscustomobject]@{
		Category = $Category
		Path = $Path
		Line = $Line
		Name = $Name
		Expected = $Expected
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

function Get-IndentLevel {
	param([string]$Whitespace)

	$tabs = ([regex]::Matches($Whitespace, "`t")).Count
	$spaces = ([regex]::Matches($Whitespace, ' ')).Count
	return $tabs + [Math]::Floor($spaces / 4)
}

if(![IO.File]::Exists($environmentPath)) {
	throw "Dream Maker environment not found: $environmentPath"
}

foreach($line in [IO.File]::ReadAllLines($environmentPath)) {
	$match = [regex]::Match($line, '^\s*#include\s+"(?<path>src\\Code\\[^"]+\.dm)"$', [Text.RegularExpressions.RegexOptions]::IgnoreCase)
	if(!$match.Success) {
		continue
	}

	$relativePath = $match.Groups['path'].Value.Replace('\', '/')
	if($relativePath.StartsWith('src/Code/_libs/', [StringComparison]::OrdinalIgnoreCase)) {
		continue
	}
	$fullPath = Join-Path $repositoryRoot $relativePath
	if(![IO.File]::Exists($fullPath)) {
		throw "Included source file not found: $relativePath"
	}
	$sourceFiles.Add([pscustomobject]@{ RelativePath = $relativePath; FullPath = $fullPath })

	$fileName = [IO.Path]::GetFileName($relativePath)
	if($fileName -cnotmatch '^[A-Z][A-Za-z0-9]*\.dm$') {
		Add-NamingIssue 'File' $relativePath 0 $fileName 'PascalCase.dm without spaces'
	}

	$directory = [IO.Path]::GetDirectoryName($relativePath).Replace('\', '/')
	while($directory -and $directory -ne 'src/Code') {
		[void]$sourceDirectories.Add($directory)
		$directory = [IO.Path]::GetDirectoryName($directory).Replace('\', '/')
	}
}

foreach($directory in $sourceDirectories) {
	$directoryName = [IO.Path]::GetFileName($directory)
	if($directoryName -cnotmatch '^[A-Z][A-Za-z0-9]*$') {
		Add-NamingIssue 'Directory' $directory 0 $directoryName 'CamelCase without spaces'
	}
}

$includedSourcePaths = New-Object 'Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
foreach($sourceFile in $sourceFiles) {
	[void]$includedSourcePaths.Add($sourceFile.RelativePath)
}
$codeRoot = Join-Path $repositoryRoot 'src/Code'
foreach($fullPath in [IO.Directory]::EnumerateFiles($codeRoot, '*.dm', [IO.SearchOption]::AllDirectories)) {
	$relativePath = $fullPath.Substring($repositoryRoot.Length + 1).Replace('\', '/')
	if($relativePath.StartsWith('src/Code/_libs/', [StringComparison]::OrdinalIgnoreCase) -or $includedSourcePaths.Contains($relativePath)) {
		continue
	}
	$fileName = [IO.Path]::GetFileName($relativePath)
	if($fileName -cnotmatch '^[A-Z][A-Za-z0-9]*\.dm$') {
		Add-NamingIssue 'File' $relativePath 0 $fileName 'PascalCase.dm without spaces'
	}
}

$assetRoots = @('src/Icons', 'src/Images', 'src/Maps', 'src/Sound')
foreach($assetRoot in $assetRoots) {
	$fullAssetRoot = Join-Path $repositoryRoot $assetRoot
	foreach($fullDirectory in [IO.Directory]::EnumerateDirectories($fullAssetRoot, '*', [IO.SearchOption]::AllDirectories)) {
		$relativeDirectory = $fullDirectory.Substring($repositoryRoot.Length + 1).Replace('\', '/')
		$directoryName = [IO.Path]::GetFileName($fullDirectory)
		if($directoryName -cnotmatch '^[A-Z][A-Za-z0-9]*$') {
			Add-NamingIssue 'AssetDirectory' $relativeDirectory 0 $directoryName 'CamelCase without spaces'
		}
	}
	foreach($fullAssetPath in [IO.Directory]::EnumerateFiles($fullAssetRoot, '*', [IO.SearchOption]::AllDirectories)) {
		$relativeAssetPath = $fullAssetPath.Substring($repositoryRoot.Length + 1).Replace('\', '/')
		$assetStem = [IO.Path]::GetFileNameWithoutExtension($fullAssetPath)
		$assetExtension = [IO.Path]::GetExtension($fullAssetPath)
		if($assetStem -cnotmatch '^[A-Z][A-Za-z0-9]*$') {
			Add-NamingIssue 'AssetFile' $relativeAssetPath 0 ([IO.Path]::GetFileName($fullAssetPath)) 'PascalCase without spaces'
		}
		if($assetExtension -cnotmatch '^\.[a-z0-9]+$') {
			Add-NamingIssue 'AssetExtension' $relativeAssetPath 0 $assetExtension 'lowercase extension'
		}
	}
}

$assetExtensions = @('.dmi', '.png', '.jpg', '.gif', '.ogg', '.wav', '.mp3', '.mid', '.rtf')
foreach($fullAssetPath in [IO.Directory]::EnumerateFiles($codeRoot, '*', [IO.SearchOption]::AllDirectories)) {
	$relativeAssetPath = $fullAssetPath.Substring($repositoryRoot.Length + 1).Replace('\', '/')
	if($relativeAssetPath.StartsWith('src/Code/_libs/', [StringComparison]::OrdinalIgnoreCase) -or [IO.Path]::GetExtension($fullAssetPath).ToLowerInvariant() -notin $assetExtensions) {
		continue
	}
	$assetStem = [IO.Path]::GetFileNameWithoutExtension($fullAssetPath)
	$assetExtension = [IO.Path]::GetExtension($fullAssetPath)
	if($assetStem -cnotmatch '^[A-Z][A-Za-z0-9]*$') {
		Add-NamingIssue 'AssetFile' $relativeAssetPath 0 ([IO.Path]::GetFileName($fullAssetPath)) 'PascalCase without spaces'
	}
	if($assetExtension -cnotmatch '^\.[a-z0-9]+$') {
		Add-NamingIssue 'AssetExtension' $relativeAssetPath 0 $assetExtension 'lowercase extension'
	}
}

foreach($sourceFile in $sourceFiles) {
	$lines = [IO.File]::ReadAllLines($sourceFile.FullPath)
	$inBlockComment = $false
	$methodScopes = @{}
	for($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
		$codeLine = Get-CodeWithoutComments $lines[$lineIndex] ([ref]$inBlockComment)
		if([String]::IsNullOrWhiteSpace($codeLine)) {
			continue
		}

		$indentMatch = [regex]::Match($codeLine, '^(?<whitespace>\s*)')
		$indent = Get-IndentLevel $indentMatch.Groups['whitespace'].Value
		$code = $codeLine.Trim()
		foreach($scopeIndent in @($methodScopes.Keys)) {
			if([int]$scopeIndent -ge $indent) {
				$methodScopes.Remove($scopeIndent)
			}
		}

		$scopeMatch = [regex]::Match($code, '^(?:/?[A-Za-z_][A-Za-z0-9_]*/)*(?:proc|verb)$', [Text.RegularExpressions.RegexOptions]::IgnoreCase)
		if($scopeMatch.Success) {
			$methodScopes[$indent] = $true
		}

		$methodName = $null
		$methodMatch = [regex]::Match($code, '^(?:/?[A-Za-z_][A-Za-z0-9_]*/)*(?:proc|verb)/(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*\(', [Text.RegularExpressions.RegexOptions]::IgnoreCase)
		if($methodMatch.Success) {
			$methodName = $methodMatch.Groups['name'].Value
		}
		else {
			$parentMethodScope = $methodScopes.ContainsKey($indent - 1)
			if($parentMethodScope) {
				$nestedMethodMatch = [regex]::Match($code, '^(?<name>[A-Za-z_][A-Za-z0-9_]*)\s*\(')
				if($nestedMethodMatch.Success) {
					$methodName = $nestedMethodMatch.Groups['name'].Value
				}
			}
		}
		if($methodName -and !$nativeCallbacks.ContainsKey($methodName) -and $methodName -cnotmatch '^[a-z][A-Za-z0-9]*$') {
			Add-NamingIssue 'Proc' $sourceFile.RelativePath ($lineIndex + 1) $methodName 'camelCase'
		}

		$typeMatch = [regex]::Match($code, '^/?(?<path>[A-Za-z_][A-Za-z0-9_]*(?:/[A-Za-z_][A-Za-z0-9_]*)+)\s*(?:$|\{)')
		if($typeMatch.Success) {
			$typeSegments = $typeMatch.Groups['path'].Value.Split('/')
			if(!($typeSegments -contains 'proc') -and !($typeSegments -contains 'verb') -and !($typeSegments -contains 'var')) {
				foreach($typeSegment in $typeSegments) {
					if(!$builtInTypeSegments.ContainsKey($typeSegment) -and $typeSegment -cnotmatch '^[A-Z][A-Za-z0-9]*$') {
						Add-NamingIssue 'Type' $sourceFile.RelativePath ($lineIndex + 1) $typeSegment 'PascalCase custom type segment'
					}
				}
			}
		}

		$variableMatches = [regex]::Matches($code, '\bvar/(?<path>[A-Za-z_][A-Za-z0-9_]*(?:/[A-Za-z_][A-Za-z0-9_]*)*)')
		foreach($variableMatch in $variableMatches) {
			$variableSegments = $variableMatch.Groups['path'].Value.Split('/')
			$variableName = $variableSegments[$variableSegments.Count - 1]
			if($variableScopeSegments.ContainsKey($variableName) -and $variableSegments.Count -eq 1) {
				continue
			}
			if($variableName -cnotmatch '^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$') {
				Add-NamingIssue 'Variable' $sourceFile.RelativePath ($lineIndex + 1) $variableName 'snake_case'
			}
		}
	}
}

Write-Host "Naming convention audit: $($sourceFiles.Count) compiled first-party DM files"
foreach($category in @('Directory', 'File', 'AssetDirectory', 'AssetFile', 'AssetExtension', 'Type', 'Proc', 'Variable')) {
	$count = @($issues | Where-Object Category -eq $category).Count
	Write-Host ("{0,-10} {1,6}" -f ($category + ':'), $count)
}
Write-Host ("{0,-10} {1,6}" -f 'Total:', $issues.Count)

if($Detailed -and $issues.Count -gt 0) {
	$issues |
		Sort-Object Category, Path, Line, Name |
		Format-Table Category, Path, Line, Name, Expected -AutoSize
}

$pathCategories = @('Directory', 'File', 'AssetDirectory', 'AssetFile', 'AssetExtension')
$pathIssueCount = @($issues | Where-Object Category -in $pathCategories).Count
if($PathStrict -and $pathIssueCount -gt 0) {
	throw "Naming convention audit found $pathIssueCount path violations."
}

if($Strict -and $issues.Count -gt 0) {
	throw "Naming convention audit found $($issues.Count) violations."
}
