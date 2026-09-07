[CmdletBinding()]
param([string]$DmmToolsPath, [ValidateSet('Viltrum','SuperEarth')][string]$Planet = 'Viltrum', [string[]]$Chunks = @('A1','C3','D3'))
$ErrorActionPreference = 'Stop'
$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
if(!$DmmToolsPath) { $DmmToolsPath = Join-Path $repo '.codex-tmp/SpacemanDmm/DmmTools.exe' }
if(!(Test-Path -LiteralPath $DmmToolsPath)) { throw 'Supply -DmmToolsPath from the official SpacemanDMM suite. This check never starts StrongDMM.' }
$before = (Get-FileHash -LiteralPath (Join-Path $repo 'DU.dme')).Hash
foreach($chunk in $Chunks) {
 $environment = & (Join-Path $repo 'tools/Open-PlanetChunk.ps1') -Planet $Planet -Chunk $chunk -PrepareOnly
 $includes = [regex]::Matches([IO.File]::ReadAllText($environment),'(?m)^#include "[^"\r\n]+\.dmm"')
 if($includes.Count -ne 1 -or !$includes[0].Value.Contains("$Planet$chunk.dmm")) { throw 'Editor environment must include exactly the selected chunk.' }
 $map = Join-Path $repo "src/Maps/PlanetChunks/$Planet/$Planet$chunk.dmm"
 $output = & $DmmToolsPath -e $environment --jobs 1 minimap --min 1,1,1 --max 1,1,1 -o (Join-Path $repo '.codex-tmp/SpacemanDmm/Checks') $map 2>&1
 $exitCode = $LASTEXITCODE
 # dmm-tools can return zero after parser errors, so inspect diagnostics too.
 if($exitCode -ne 0 -or ($output -join "`n") -match '(?im)^error[: ]|some parsing errors|error loading icon') { throw ($output -join "`n") }
 Write-Output "PASS ${chunk}: one 100x100 map, environment parse and asset resolution"
}
if((Get-FileHash -LiteralPath (Join-Path $repo 'DU.dme')).Hash -ne $before) { throw 'DU.dme was unexpectedly modified.' }
Write-Output 'PASS DU.dme unchanged; no editor or game client was opened.'
