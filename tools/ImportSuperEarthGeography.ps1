param([Parameter(Mandatory=$true)][string]$ReferencePath)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$bitmap = [Drawing.Bitmap]::new((Resolve-Path -LiteralPath $ReferencePath).Path)
try {
 $rows = [Collections.Generic.List[string]]::new()
 for($y=0; $y -lt 500; $y++) {
  $row = [Text.StringBuilder]::new()
  for($x=0; $x -lt 500; $x++) {
   $pixel = $bitmap.GetPixel([Math]::Min($bitmap.Width-1,[int][Math]::Floor(($x+0.5)*$bitmap.Width/500)),[Math]::Min($bitmap.Height-1,[int][Math]::Floor(($y+0.5)*$bitmap.Height/500)))
   $terrain = '2'
   if($pixel.B -gt $pixel.R*1.08 -and $pixel.B -gt $pixel.G*0.97) { $terrain = '0' }
   elseif($pixel.R -gt 185 -and $pixel.G -gt 185 -and $pixel.B -gt 175) { $terrain = '3' }
   elseif($pixel.R -gt $pixel.G*1.08 -and $pixel.R -gt $pixel.B*1.2) { $terrain = '1' }
   elseif([Math]::Abs([int]$pixel.R-[int]$pixel.G) -lt 12 -and $pixel.R -gt 110) { $terrain = '4' }
   [void]$row.Append($terrain)
  }
  $rows.Add($row.ToString())
 }
 $target = Join-Path $PSScriptRoot '../docs/Maps/SuperEarthGeography.json'
 $json = @{description='Terrain classes sampled from the user-provided Earth reference. Rows run north to south.'; width=500; height=500; rows=$rows.ToArray()} | ConvertTo-Json -Depth 4 -Compress
 [IO.File]::WriteAllText([IO.Path]::GetFullPath($target),$json,[Text.UTF8Encoding]::new($false))
 Write-Output 'Imported 500x500 geography classes.'
}
finally { $bitmap.Dispose() }
