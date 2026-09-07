[CmdletBinding()]
param(
 [ValidateSet('Viltrum','SuperEarth')][string]$Planet = 'Viltrum',
 [string]$PythonPath = 'python',
 [switch]$Baseline
)
$ErrorActionPreference = 'Stop'
$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$arguments = @((Join-Path $PSScriptRoot 'BuildAtlasData.cjs'),$Planet)
if($Baseline) { $arguments += '--baseline' }
& node @arguments
if($LASTEXITCODE -ne 0) { throw 'Atlas data validation failed' }
$suffix = if($Baseline) {'Baseline'} else {''}
& $PythonPath (Join-Path $PSScriptRoot 'RenderPlanetAtlas.py') (Join-Path $repo ".codex-tmp/PlanetAtlas/$Planet$suffix.json")
if($LASTEXITCODE -ne 0) { throw 'Atlas rendering failed' }
