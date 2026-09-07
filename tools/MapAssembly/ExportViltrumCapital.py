"""Import/export the capital furniture sheet; native Aseprite remains authoritative."""
import argparse, hashlib, json, subprocess, tempfile
from pathlib import Path
from PIL import Image, PngImagePlugin
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'ArtSource/Viltrum'
parser=argparse.ArgumentParser()
parser.add_argument('--aseprite',required=True)
parser.add_argument('--initialize',type=Path)
args=parser.parse_args()
states=[('bed','Bed'),('medical_bed','MedicalBed'),('locker','Locker'),('freight_crate','FreightCrate'),('throne','Throne'),('serving_counter','ServingCounter'),('workbench','Workbench'),('communications_mast','CommunicationsMast')]
document=SOURCE/'ViltrumCapitalObjects.aseprite'
with tempfile.TemporaryDirectory(prefix='ViltrumCapitalArt-') as temporary:
 temporary=Path(temporary)
 if args.initialize:
  if document.exists():raise ValueError('Native source exists; edit it directly instead of reinitializing.')
  incoming=Image.open(args.initialize).convert('RGBA')
  assert incoming.getchannel('A').getextrema()==(0,255),'Real alpha required'
  sheet=Image.new('RGBA',(256,32))
  for index in range(8):
   col,row=index%4,index//4
   tile=incoming.crop((col*incoming.width//4,row*incoming.height//2,(col+1)*incoming.width//4,(row+1)*incoming.height//2)).resize((32,32),Image.Resampling.NEAREST)
   sheet.paste(tile,(index*32,0))
  png=temporary/'Import.png';sheet.save(png)
  subprocess.run([args.aseprite,'--batch',str(png),'--save-as',str(document)],check=True)
 png=temporary/'Export.png'
 subprocess.run([args.aseprite,'--batch',str(document),'--save-as',str(png)],check=True)
 sheet=Image.open(png).convert('RGBA');assert sheet.size==(256,32)
 description='# BEGIN DMI\nversion = 4.0\n\twidth = 32\n\theight = 32\n'
 report={'cellSize':[32,32],'anchor':'Single 32x32 object, zero offsets. Opaque silhouette on real alpha; density is independent of floor.','states':[],'sourceHashes':{str(document.relative_to(ROOT)).replace('\\','/'):hashlib.sha256(document.read_bytes()).hexdigest()}}
 for index,(state,subtype) in enumerate(states):
  tile=sheet.crop((index*32,0,index*32+32,32));alpha=tile.getchannel('A')
  assert set(alpha.tobytes())=={0,255},f'{state}: binary alpha required'
  assert all(tile.getpixel(p)[3]==0 for p in [(0,0),(31,0),(0,31),(31,31)]),f'{state}: corners must be transparent'
  assert 100<sum(a==255 for a in alpha.tobytes())<900,f'{state}: invalid silhouette coverage'
  description+=f'state = "{state}"\n\tdirs = 1\n\tframes = 1\n'
  report['states'].append({'state':state,'type':f'/obj/ViltrumCapitalFurnishing/{subtype}','source':str(document.relative_to(ROOT)).replace('\\','/'),'sourceCell':index,'dmi':'src/Icons/Turfs/Viltrum/ViltrumCapitalObjects.dmi','dirs':1,'frames':1,'transparent':True})
 description+='# END DMI\n';metadata=PngImagePlugin.PngInfo();metadata.add_text('Description',description,zip=True)
 output=ROOT/'src/Icons/Turfs/Viltrum/ViltrumCapitalObjects.dmi';sheet.save(output,format='PNG',pnginfo=metadata)
 assert Image.open(output).info['Description']==description
 (SOURCE/'ViltrumCapitalObjects.png').write_bytes(png.read_bytes())
 (SOURCE/'ViltrumCapitalExport.json').write_text(json.dumps(report,indent=2)+'\n')
 print('Audited eight capital furnishings: 32x32, real binary alpha, clear corners, native sources retained.')
