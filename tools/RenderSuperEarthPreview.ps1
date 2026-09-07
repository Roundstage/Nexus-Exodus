$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$map = [IO.File]::ReadAllText((Join-Path $PSScriptRoot '../src/Maps/SuperEarth.dmm'))
$colors = [Collections.Generic.Dictionary[string,Drawing.Color]]::new([StringComparer]::Ordinal)
foreach($match in [regex]::Matches($map,'(?m)^"([a-zA-Z]+)" = (.+)$')) {
 $hex = '#78a55b'
 $value = $match.Groups[2].Value
 if($value.Contains('/turf/Water')) {$hex='#235785'}
 elseif($value.Contains('/turf/GroundSnow')) {$hex='#e0e7e8'}
 elseif($value.Contains('/turf/GroundDirt')) {$hex='#d2b87a'}
 elseif($value.Contains('/turf/GroundPebbles')) {$hex='#a7a391'}
 elseif($value.Contains('/turf/Tile38')) {$hex='#c8d6dc'}
 elseif($value.Contains('/turf/Tile40')) {$hex='#6b8290'}
 if($value.Contains('/obj/Trees/')) {$hex='#406c3d'}
 if($value.Contains('/obj/Spawn')) {$hex='#ffd174'}
 $colors[$match.Groups[1].Value]=[Drawing.ColorTranslator]::FromHtml($hex)
}
$block=[regex]::Match($map,'\(1,1,1\) = \{"\r?\n([\s\S]*?)\r?\n"\}')
$rows=$block.Groups[1].Value -split '\r?\n'
$bitmap=[Drawing.Bitmap]::new(500,500)
try {
 for($y=0;$y -lt 500;$y++) {for($x=0;$x -lt 500;$x++) {$bitmap.SetPixel($x,$y,$colors[$rows[$y].Substring($x*2,2)])}}
 $bitmap.Save([IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../docs/Maps/SuperEarthOverview.png')),[Drawing.Imaging.ImageFormat]::Png)
} finally {$bitmap.Dispose()}
