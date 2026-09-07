"""Check native hashes, variable DMI cells, transparency and lossless roof crops."""
from pathlib import Path
import hashlib,json,re
from PIL import Image
ROOT=Path(__file__).resolve().parents[2]
manifests=[f'EarthNeighborhood{name}Export.json' for name in ['Houses','Services','Props','Details']]+['EarthRiverTerrainExport.json']
checked=set();native=set();files={}
def sources(manifest):
 for relative,digest in manifest['sourceHashes'].items():
  source=ROOT/relative
  assert hashlib.sha256(source.read_bytes()).hexdigest()==digest,f'Native source changed without export: {source}'
  native.add(relative.replace('\\','/'))
def dmi(filename):
 if filename in files:return files[filename]
 source=Image.open(ROOT/filename);metadata=source.info['Description']
 w=int(re.search(r'width\s*=\s*(\d+)',metadata)[1]);h=int(re.search(r'height\s*=\s*(\d+)',metadata)[1])
 assert source.width%w==0 and source.height%h==0,'Partial DMI frame'
 states={};index=0;cols=source.width//w;rgba=source.convert('RGBA')
 for match in re.finditer(r'state = "([^"]*)"(.*?)(?=state = |# END DMI|\Z)',metadata,re.S):
  dirs=int(re.search(r'dirs = (\d+)',match[2])[1]);frames=int(re.search(r'frames = (\d+)',match[2])[1])
  assert match[1] not in states and dirs==frames==1
  states[match[1]]=index;index+=1
 capacity=cols*(source.height//h)
 assert index<=capacity and capacity-index<cols,'Missing or unaccounted DMI frames'
 for n in range(index,capacity):
  assert rgba.crop((n%cols*w,n//cols*h,n%cols*w+w,n//cols*h+h)).getchannel('A').getextrema()==(0,0)
 files[filename]=(rgba,states,w,h)
 return files[filename]
def frame(filename,state):
 source,states,w,h=dmi(filename);n=states[state];cols=source.width//w
 return source.crop((n%cols*w,n//cols*h,n%cols*w+w,n//cols*h+h))
for filename in manifests:
 manifest=json.loads((ROOT/'ArtSource/Earth'/filename).read_text());sources(manifest)
 for item in manifest['states']:
  key=(item['dmi'],item['state']);assert key not in checked;checked.add(key)
  source,states,w,h=dmi(item['dmi'])
  assert (w,h)==tuple(item.get('cellSize',[32,32]))
  assert item['state'] in states and item['dirs']==item['frames']==1
  alpha=frame(*key).getchannel('A')
  assert set(alpha.tobytes())<={0,255},f'Unintended fringe alpha: {key}'
  if item.get('transparent') is False:assert alpha.getextrema()==(255,255)
  if item.get('transparent') is True:assert alpha.getextrema()==(0,255),f'Baked object background: {key}'
# Every structural turf reproduces its house/service pixels, including alpha.
tiles=json.loads((ROOT/'ArtSource/Earth/EarthBuildingTilesExport.json').read_text());sources(tiles)
count=0
for name in ['Houses','Services']:
 manifest=json.loads((ROOT/f'ArtSource/Earth/EarthNeighborhood{name}Export.json').read_text())
 for item in manifest['states']:
  full=frame(item['dmi'],item['state']);w,h=full.size
  for y in range(h//32):
   for x in range(w//32):
    state=f'{item["state"]}_{x}_{y}';actual=frame(tiles['dmi'],state)
    assert actual.tobytes()==full.crop((x*32,h-(y+1)*32,(x+1)*32,h-y*32)).tobytes(),f'Building crop differs: {state}'
    checked.add((tiles['dmi'],state));count+=1
assert count==tiles['count']==len(tiles['states'])==288
result={'manifests':len(manifests)+1,'nativeSources':len(native),'dmiFiles':len(files),'states':len(checked),'frameSizes':sorted({(v[2],v[3]) for v in files.values()}),'binaryAlpha':True,'nativeSourceHashesMatch':True,'losslessBuildingTiles':count}
(ROOT/'docs/Maps/EarthNeighborhoodAssetChecks.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
