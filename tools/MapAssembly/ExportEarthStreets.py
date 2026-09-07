"""Original quiet street materials, exported from a separate native source."""
import argparse,hashlib,json,subprocess,tempfile
from pathlib import Path
from PIL import Image,PngImagePlugin
ROOT=Path(__file__).resolve().parents[2];SOURCE=ROOT/'ArtSource/Earth'
parser=argparse.ArgumentParser();parser.add_argument('--aseprite',required=True);parser.add_argument('--initialize',type=Path);args=parser.parse_args()
states=[('asphalt','/turf/EarthFloor/Road'),('crosswalk','/turf/EarthFloor/Crosswalk'),('concrete','/turf/EarthFloor/Sidewalk'),('industrial_concrete','/turf/EarthFloor/Concrete')];document=SOURCE/'EarthStreetAdditions.aseprite'
with tempfile.TemporaryDirectory(prefix='EarthStreets-') as temporary:
 temporary=Path(temporary)
 if args.initialize:
  if document.exists():raise ValueError('Native source exists; edit it directly.')
  original=SOURCE/'EarthStreetsOriginal.png'
  if original.exists():raise ValueError('Original exists; refusing replacement.')
  original.write_bytes(args.initialize.read_bytes());incoming=Image.open(original).convert('RGBA');sheet=Image.new('RGBA',(128,32))
  for index in range(4):
   col,row=index%2,index//2;tile=incoming.crop((round(col*incoming.width/2),round(row*incoming.height/2),round((col+1)*incoming.width/2),round((row+1)*incoming.height/2))).resize((32,32),Image.Resampling.NEAREST);sheet.paste(tile,(index*32,0))
  png=temporary/'Import.png';sheet.save(png);subprocess.run([args.aseprite,'--batch',str(png),'--save-as',str(document)],check=True)
 png=temporary/'Export.png';subprocess.run([args.aseprite,'--batch',str(document),'--save-as',str(png)],check=True);sheet=Image.open(png).convert('RGBA');assert sheet.size==(128,32) and sheet.getchannel('A').getextrema()==(255,255)
 description='# BEGIN DMI\nversion = 4.0\n\twidth = 32\n\theight = 32\n';report={'origin':'Original built-in OpenAI image_gen street materials.','states':[],'sourceHashes':{str(document.relative_to(ROOT)).replace('\\','/'):hashlib.sha256(document.read_bytes()).hexdigest()}}
 for index,(state,dm_type) in enumerate(states):
  description+=f'state = "{state}"\n\tdirs = 1\n\tframes = 1\n';report['states'].append({'state':state,'type':dm_type,'dmi':'src/Icons/Turfs/Earth/EarthStreets.dmi','source':str(document.relative_to(ROOT)).replace('\\','/'),'sourceCell':index,'dirs':1,'frames':1,'transparent':False})
 description+='# END DMI\n';metadata=PngImagePlugin.PngInfo();metadata.add_text('Description',description,zip=True);sheet.save(ROOT/'src/Icons/Turfs/Earth/EarthStreets.dmi',format='PNG',pnginfo=metadata)
 (SOURCE/'EarthStreets.png').write_bytes(png.read_bytes());(SOURCE/'EarthStreetExport.json').write_text(json.dumps(report,indent=2)+'\n');print('Audited four original opaque 32x32 street materials.')
