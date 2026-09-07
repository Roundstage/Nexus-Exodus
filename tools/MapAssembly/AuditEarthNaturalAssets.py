"""Verify actual 32px DMI pixels, named map states and retained native sources."""
import hashlib,json,re
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[2]
folder=ROOT/'ArtSource/Earth';report=json.loads((folder/'EarthNaturalTilesExport.json').read_text())
dmi=ROOT/'src/Icons/Turfs/Earth/EarthNaturalTiles.dmi'
assert hashlib.sha256(dmi.read_bytes()).hexdigest()==report['dmiHash']
assert hashlib.sha256((folder/'EarthNaturalTiles.aseprite').read_bytes()).hexdigest()==report['sourceHash']
image=Image.open(dmi);description=image.info['Description'];assert 'width = 32' in description and 'height = 32' in description
names=re.findall(r'state = "([^"]+)"',description);assert names==report['states'] and len(names)==1582 and len(set(names))==1582
sheet=image.convert('RGBA');native=Image.open(folder/'EarthNaturalTiles.png').convert('RGBA');assert sheet.tobytes()==native.tobytes()
for i in range(len(names)):
 assert sheet.crop((i%16*32,i//16*32,(i%16+1)*32,(i//16+1)*32)).getchannel('A').getextrema()==(255,255)
mapped=0
for filename in ['SuperEarth.dmm','CityInteriors.dmm']:
 source=(ROOT/'src/Maps'/filename).read_text()
 for state in re.findall(r'/turf/EarthNatural\w+(?:/\w+)*\{[^}]*icon_state = "([^"]+)"',source):assert state in names,state;mapped+=1
assert mapped>1495
print(f'1582 opaque 32x32 tile states, {mapped} mapped overrides, exact native export, zero monolithic landform sprites.')
