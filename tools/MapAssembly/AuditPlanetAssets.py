"""Audit the production asset manifests and their actual DMI frame metadata."""
from pathlib import Path
import hashlib,json,re
from PIL import Image
ROOT=Path(__file__).resolve().parents[2]
manifests=['Viltrum/ViltrumExport.json','Viltrum/ViltrumRevision.json','Viltrum/ViltrumCapitalExport.json','Viltrum/ViltrumLandscapeExport.json','Viltrum/ViltrumDoorExport.json','Earth/EarthCityExport.json','Earth/EarthStreetExport.json']
checked=set();native=set();frames_checked=0;files={}
for filename in manifests:
 manifest=json.loads((ROOT/'ArtSource'/filename).read_text())
 for relative,digest in manifest['sourceHashes'].items():
  source=ROOT/relative;assert hashlib.sha256(source.read_bytes()).hexdigest()==digest,f'Native source changed without export: {source}';native.add(relative.replace('\\','/'))
 for item in manifest['states']:
  key=(item['dmi'],item['state'])
  if key in checked:continue
  checked.add(key)
  if item['dmi'] not in files:
   source=Image.open(ROOT/item['dmi']);metadata=source.info['Description'];w=re.search(r'width\s*=\s*(\d+)',metadata);h=re.search(r'height\s*=\s*(\d+)',metadata);w=int(w[1]) if w else 32;h=int(h[1]) if h else 32;assert (w,h)==(32,32)
   states={};index=0
   for match in re.finditer(r'state = "([^"]*)"(.*?)(?=state = |# END DMI|\Z)',metadata,re.S):
    dirs=int(re.search(r'dirs = (\d+)',match[2])[1]);frames=int(re.search(r'frames = (\d+)',match[2])[1]);assert match[1] not in states
    states[match[1]]=(index,dirs,frames,match[2]);index+=dirs*frames
   assert index*32*32==source.width*source.height,'DMI has missing or unaccounted frames'
   files[item['dmi']]=(source.convert('RGBA'),states)
  source,states=files[item['dmi']];assert item['state'] in states
  index,dirs,frames,metadata=states[item['state']];assert (dirs,frames)==(item['dirs'],item['frames']);frames_checked+=dirs*frames
  if frames>1:
   delays=re.search(r'delay = ([\d.,]+)',metadata);assert delays and len(delays[1].split(','))==frames
  for offset in range(dirs*frames):
   n=index+offset;cols=source.width//32;tile=source.crop((n%cols*32,n//cols*32,n%cols*32+32,n//cols*32+32));alpha=tile.getchannel('A')
   assert set(alpha.tobytes())<={0,255},f'Unintended fringe alpha: {key}'
   if item.get('transparent') is False:assert alpha.getextrema()==(255,255)
   if item.get('type','') and item['type'].startswith(('/obj/ViltrumFurnishing','/obj/ViltrumCapitalFurnishing','/obj/EarthFurnishing','/obj/EarthDirectory')):assert alpha.getextrema()==(0,255),f'Baked object background: {key}'
result={'manifests':len(manifests),'nativeSources':len(native),'dmiFiles':len(files),'states':len(checked),'frames':frames_checked,'frameSize':[32,32],'binaryAlpha':True,'nativeSourceHashesMatch':True}
(ROOT/'docs/Maps/PlanetAssetChecks.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
