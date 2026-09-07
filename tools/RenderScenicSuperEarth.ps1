$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$repo=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$data=Get-Content (Join-Path $repo 'docs/Maps/SuperEarthRender.json') -Raw | ConvertFrom-Json
$assets=@{
 '/turf/Ground10'=@('src/Icons/Turfs/Turf1.dmi','light desert',0)
 '/turf/Grass12'=@('src/Icons/Turfs/JungleGrassTile.dmi','',0)
 '/turf/GroundSnow'=@('src/Icons/Turfs/LargeTurfIcons/BigSnowTurf.dmi','',6)
 '/turf/GroundIce2'=@('src/Icons/Turfs/LargeTurfIcons/BigIceTurf2.dmi','',6)
 '/turf/Water2'=@('src/Icons/Turfs/Turfs96.dmi','stillwater',0)
 '/turf/Ground14'=@('src/Icons/Turfs/LargeTurfIcons/BigSandTurf.dmi','',4)
 '/turf/Grass13'=@('src/Icons/Turfs/LargeTurfIcons/BigGrassTurf2.dmi','',3)
 '/turf/Grass8'=@('src/Icons/Turfs/LargeTurfIcons/BigGrassAndDirtTurf.dmi','',6)
 '/turf/GroundDirt'=@('src/Icons/Turfs/LargeTurfIcons/BigDirtTurfs.dmi','',4)
 '/turf/Wall12'=@('src/Icons/Turfs/Turfs3.dmi','cliff',0)
 '/turf/WaterFall'=@('src/Icons/Turfs/TurfsLegacy1.dmi','waterfall',0)
 '/turf/Stairs_Grass'=@('src/Icons/Turfs/Celianna/CeliannaFarmnatureTileset.dmi','Grass_Stairs',0)
}
$cache=@{}
function LoadSprite($rel) {
 if($cache.ContainsKey($rel)){return $cache[$rel]}
 $filename=Join-Path $repo $rel
 $bytes=[IO.File]::ReadAllBytes($filename);$meta='';$pos=8
 while($pos -lt $bytes.Length-12){$length=[int]($bytes[$pos]*16777216+$bytes[$pos+1]*65536+$bytes[$pos+2]*256+$bytes[$pos+3]);$type=[Text.Encoding]::ASCII.GetString($bytes,$pos+4,4)
  if($type -eq 'zTXt'){$offset=$pos+8;while($bytes[$offset] -ne 0){$offset++};$offset+=2;$stream=[IO.MemoryStream]::new($bytes,$offset,$pos+8+$length-$offset);$z=[IO.Compression.ZLibStream]::new($stream,[IO.Compression.CompressionMode]::Decompress);$reader=[IO.StreamReader]::new($z);$meta=$reader.ReadToEnd();$reader.Dispose();$stream.Dispose()}
  $pos+=$length+12
 }
 $states=[Collections.Generic.Dictionary[string,int]]::new([StringComparer]::Ordinal);$frame=0
 foreach($m in [regex]::Matches($meta,'(?s)state = "([^"]*)"(.*?)(?=state = |# END DMI|$)')){$states[$m.Groups[1].Value]=$frame;$dirs=[regex]::Match($m.Groups[2].Value,'dirs = (\d+)');$frames=[regex]::Match($m.Groups[2].Value,'frames = (\d+)');$d=1;$f=1;if($dirs.Success){$d=[int]$dirs.Groups[1].Value};if($frames.Success){$f=[int]$frames.Groups[1].Value};$frame+=$d*$f}
 $result=@{bitmap=[Drawing.Bitmap]::new($filename);states=$states};$cache[$rel]=$result;return $result
}
try {
 foreach($location in @(@('Waterfall',139,350),@('Meadow',101,362),@('Desert',140,95),@('Jungle',413,297),@('Arctic',279,438))) {
  $bitmap=[Drawing.Bitmap]::new(864,672);$graphics=[Drawing.Graphics]::FromImage($bitmap);$graphics.Clear([Drawing.Color]::Black)
  for($row=0;$row -lt 21;$row++){for($col=0;$col -lt 27;$col++){
   $x=[int]$location[1]-13+$col;$y=[int]$location[2]+10-$row;$tile=$data.palette[$data.grid[500-$y][$x-1]];$a=$assets[$tile[0]];if(!$a){throw "Unknown tile $($tile[0])"};$sprite=LoadSprite $a[0];$state=$a[1];if($a[2] -gt 0){$state=([string](($x-1)%$a[2]))+','+([string](($y-1)%$a[2]))};$frame=0;if($sprite.states.ContainsKey($state)){$frame=$sprite.states[$state]}else{throw "Missing DMI state $($a[0]): $state"};$columns=[int]($sprite.bitmap.Width/32);$sx=($frame%$columns)*32;$sy=[Math]::Floor($frame/$columns)*32
   $graphics.DrawImage($sprite.bitmap,[Drawing.Rectangle]::new($col*32,$row*32,32,32),[int]$sx,[int]$sy,32,32,[Drawing.GraphicsUnit]::Pixel)
  }}
  $bitmap.Save((Join-Path $repo ('docs/Maps/SuperEarth'+$location[0]+'.png')),[Drawing.Imaging.ImageFormat]::Png);$graphics.Dispose();$bitmap.Dispose()
 }
 $overview=[Drawing.Bitmap]::new(500,500)
 for($y=0;$y -lt 500;$y++){for($x=0;$x -lt 500;$x++){$overview.SetPixel($x,$y,[Drawing.ColorTranslator]::FromHtml($data.palette[$data.grid[$y][$x]][1]))}}
 $overview.Save((Join-Path $repo 'docs/Maps/SuperEarthOverview.png'),[Drawing.Imaging.ImageFormat]::Png);$overview.Dispose()
} finally {foreach($s in $cache.Values){$s.bitmap.Dispose()}}
