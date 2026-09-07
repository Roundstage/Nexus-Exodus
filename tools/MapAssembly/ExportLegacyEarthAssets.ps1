[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$output = Join-Path $repo '.codex-tmp/EarthAssetAudit'
[IO.Directory]::CreateDirectory($output) | Out-Null
$lines = @('world/New()')
foreach ($name in @('Furnature','Roomobj')) {
 $source = Join-Path $repo "src/Icons/MapObjects/$name.dmi"
 Copy-Item -LiteralPath $source -Destination (Join-Path $output "${name}Source.dmi")
 $lines += "`tvar/icon/art_$name = icon('${name}Source.dmi')"
 $lines += "`tart_$name.Blend(rgb(255,255,255), ICON_MULTIPLY)"
 $lines += "`tfcopy(fcopy_rsc(art_$name), `"$name.dmi`")"
 $lines += "`ttext2file(json_encode(icon_states(art_$name)), `"$name.json`")"
}
$lines += "`tshutdown()"
$environment = Join-Path $output 'EarthAssetAudit.dme'
[IO.File]::WriteAllText($environment, ($lines -join "`n") + "`n", [Text.UTF8Encoding]::new($false))
$bin = Join-Path $env:TEMP 'Nexus-Exodus-BYOND-516.1686/byond/bin'
& (Join-Path $bin 'dm.exe') $environment
if ($LASTEXITCODE -ne 0) { throw 'Legacy asset audit compilation failed.' }
$arguments = @('EarthAssetAudit.dmb','0','-safe','-invisible')
$process = Start-Process -FilePath (Join-Path $bin 'dd.exe') -ArgumentList $arguments -WorkingDirectory $output -WindowStyle Hidden -RedirectStandardOutput (Join-Path $output 'ExportStdout.log') -RedirectStandardError (Join-Path $output 'ExportStderr.log') -PassThru
if (!$process.WaitForExit(15000)) { $process.Kill(); throw 'Legacy asset conversion timed out.' }
foreach ($name in @('Furnature','Roomobj')) {
 if (!(Test-Path -LiteralPath (Join-Path $output "$name.dmi"))) { throw "Missing converted $name" }
 Write-Output "Converted audit copy: $output/$name.dmi"
}
