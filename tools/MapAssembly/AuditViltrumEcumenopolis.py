"""Check exported native sources, real alpha and every structural DMI crop."""
import hashlib,json,re
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[2]
ART=ROOT/'ArtSource/Viltrum/Ecumenopolis'
data=json.loads((ART/'Export.json').read_text())
for file,expected in data['sourceHashes'].items():
 assert hashlib.sha256((ROOT/file).read_bytes()).hexdigest()==expected,('Re-export edited native source',file)
def load(file):
 image=Image.open(ROOT/file);meta=image.info['Description'];im=image.convert('RGBA')
 w=int(re.search(r'width\s*=\s*(\d+)',meta)[1]);h=int(re.search(r'height\s*=\s*(\d+)',meta)[1])
 names=re.findall(r'state = "([^"]*)"',meta);cols=im.width//w
 assert len(set(names))==len(names)
 return {name:im.crop((i%cols*w,i//cols*h,(i%cols+1)*w,(i//cols+1)*h)) for i,name in enumerate(names)}
tiles=load('src/Icons/Turfs/Viltrum/ViltrumCityStructures.dmi');count=0
for item in data['states']:
 building=load(item['dmi'])[item['state']];w,h=building.size
 assert [w,h]==item['cellSize']
 assert set(building.getchannel('A').tobytes())=={0,255},'Background must have genuine binary alpha'
 assert building.tobytes()==Image.open(ROOT/item['source'].replace('.aseprite','.png')).convert('RGBA').tobytes(), 'DMI differs from native export preview'
 for y in range(h//32):
  for x in range(w//32):
   crop=building.crop((x*32,h-(y+1)*32,(x+1)*32,h-y*32))
   assert tiles[f'{item["state"]}_{x}_{y}'].tobytes()==crop.tobytes(), 'Structural art mismatch'
   count+=1
assert count==len(tiles)==len(data['structuralStates'])
streets=load('src/Icons/Turfs/Viltrum/ViltrumCityStreets.dmi')
for name,frame in streets.items():
 assert frame.size==(32,32)
 if name in ['threshold','exit']:assert set(frame.getchannel('A').tobytes())=={0,255}
 else:assert frame.getchannel('A').getextrema()==(255,255),'Ground must occupy the whole tile'
# Reused trees/furnishings retain their independent transparent backgrounds.
for file,states in [('src/Icons/Turfs/Earth/EarthNeighborhoodProps.dmi',['tree']),('src/Icons/Turfs/Viltrum/ViltrumObjects.dmi',['planter','bench'])]:
 source=load(file)
 for name in states:assert source[name].getchannel('A').getextrema()==(0,255)
result={'buildings':len(data['states']),'structuralTiles':count,'streetStates':len(streets),'nativeHashesMatch':True,'losslessStructuralCrops':True,'transparentObjects':True,'fullTileGround':True}
(ART/'Audit.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
