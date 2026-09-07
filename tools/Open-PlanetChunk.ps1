[CmdletBinding()]
param(
 [ValidateSet('Viltrum','SuperEarth')][string]$Planet = 'Viltrum',
 [ValidatePattern('^[A-E][1-5]$')][string]$Chunk = 'C3',
 [switch]$PrepareOnly,
 [string]$StrongDmmPath
)
$ErrorActionPreference = 'Stop'
$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$source = Join-Path $repo "src/Maps/PlanetChunks/$Planet/$Planet$Chunk.dmm"
if(!(Test-Path -LiteralPath $source)) { throw "Chunk does not exist: $source" }
$directory = Join-Path $repo '.codex-tmp/PlanetChunkEditor'
[IO.Directory]::CreateDirectory($directory) | Out-Null
# Editors resolve icon strings relative to the environment, not FILE_DIR.
# A junction exposes the real sources without copying or including other maps.
$assetLink = Join-Path $directory 'src'
$assetTarget = Join-Path $repo 'src'
if(Test-Path -LiteralPath $assetLink) {
 $existingLink = Get-Item -LiteralPath $assetLink
 if($existingLink.LinkType -ne 'Junction' -or [IO.Path]::GetFullPath($existingLink.Target) -ne $assetTarget) { throw 'Unexpected editor src directory; refusing to replace it.' }
} else {
 New-Item -ItemType Junction -Path $assetLink -Value $assetTarget | Out-Null
}
$environment = Join-Path $directory "$Planet$Chunk.dme"
$lines = foreach($line in [IO.File]::ReadAllLines((Join-Path $repo 'DU.dme'))) {
 if($line -match '^\s*#include\s+"[^"\r\n]+\.dmm"') { continue }
 if($line -match '^\s*#include\s+"([^"\r\n]+)"') {
  '#include "' + [IO.Path]::GetFullPath((Join-Path $repo $Matches[1])).Replace('\','/') + '"'
 } elseif($line -match '^\s*#define FILE_DIR\b') { continue }
 else { $line }
}
$lines = @('#define FILE_DIR "' + $repo.Replace('\','/') + '"') + $lines + @('#include "' + $source.Replace('\','/') + '"')
[IO.File]::WriteAllLines($environment,$lines,[Text.UTF8Encoding]::new($false))
if($PrepareOnly) { return $environment }
if(!$StrongDmmPath) { $StrongDmmPath = Join-Path $repo 'StrongDMM.exe' }
if(!(Test-Path -LiteralPath $StrongDmmPath)) { throw 'StrongDMM not found; supply -StrongDmmPath or use -PrepareOnly.' }
# StrongDMM accepts an environment path followed by a map path.
Start-Process -FilePath $StrongDmmPath -ArgumentList @(('"'+$environment+'"'),('"'+$source+'"')) -WorkingDirectory $repo
Write-Output $environment
