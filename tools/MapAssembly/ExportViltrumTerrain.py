"""Export sixteen full-block terrain/floor states from an editable Aseprite sheet."""
import argparse,hashlib,json,subprocess,tempfile
from pathlib import Path
from PIL import Image,PngImagePlugin
ROOT=Path(__file__).resolve().parents[2];SOURCE=ROOT/'ArtSource/Viltrum'
parser=argparse.ArgumentParser();parser.add_argument('--aseprite',required=True);parser.add_argument('--initialize',type=Path);args=parser.parse_args()
states=[('deep_sea','/turf/ViltrumOcean'),('shallow_sea','/turf/ViltrumOcean/Shallow'),('pale_shore','/turf/ViltrumLandscape/Shore'),('plateau','/turf/ViltrumLandscape'),('snow','/turf/ViltrumLandscape/Snow'),('ice','/turf/ViltrumLandscape/Ice'),('crater','/turf/ViltrumLandscape/Crater'),('garden','/turf/ViltrumLandscape/Garden'),('palace','/turf/ViltrumDistrictFloor/Palace'),('laboratory','/turf/ViltrumDistrictFloor/Laboratory'),('grate','/turf/ViltrumDistrictFloor/Grate'),('arena','/turf/ViltrumDistrictFloor/Arena'),('rough_stone','/turf/ViltrumLandscape/Rough'),('ruins','/turf/ViltrumLandscape/Ruins'),('cyan_stone','/turf/ViltrumLandscape/Cyan'),('storm_sea','/turf/ViltrumOcean/Boundary')]
document=SOURCE/'ViltrumLandscape.aseprite'
with tempfile.TemporaryDirectory(prefix='ViltrumLandscape-') as temporary:
 temporary=Path(temporary)
 if args.initialize:
  if document.exists():raise ValueError('Native source exists; edit it directly.')
  original=SOURCE/'ViltrumLandscapeOriginal.png'
  if original.exists():raise ValueError('Original exists; refusing replacement.')
  original.write_bytes(args.initialize.read_bytes());incoming=Image.open(original).convert('RGBA');sheet=Image.new('RGBA',(512,32))
  for index in range(16):
   col,row=index%4,index//4;tile=incoming.crop((round(col*incoming.width/4),round(row*incoming.height/4),round((col+1)*incoming.width/4),round((row+1)*incoming.height/4))).resize((32,32),Image.Resampling.NEAREST);sheet.paste(tile,(index*32,0))
  png=temporary/'Import.png';sheet.save(png);subprocess.run([args.aseprite,'--batch',str(png),'--save-as',str(document)],check=True)
 png=temporary/'Export.png';subprocess.run([args.aseprite,'--batch',str(document),'--save-as',str(png)],check=True)
 sheet=Image.open(png).convert('RGBA');assert sheet.size==(512,32) and sheet.getchannel('A').getextrema()==(255,255)
 description='# BEGIN DMI\nversion = 4.0\n\twidth = 32\n\theight = 32\n';report={'cellSize':[32,32],'states':[],'sourceHashes':{str(document.relative_to(ROOT)).replace('\\','/'):hashlib.sha256(document.read_bytes()).hexdigest()}}
 for index,(state,dm_type) in enumerate(states):
  description+=f'state = "{state}"\n\tdirs = 1\n\tframes = 1\n'
  report['states'].append({'state':state,'type':dm_type,'source':str(document.relative_to(ROOT)).replace('\\','/'),'sourceCell':index,'dmi':'src/Icons/Turfs/Viltrum/ViltrumLandscape.dmi','dirs':1,'frames':1,'transparent':False})
 description+='# END DMI\n';metadata=PngImagePlugin.PngInfo();metadata.add_text('Description',description,zip=True)
 sheet.save(ROOT/'src/Icons/Turfs/Viltrum/ViltrumLandscape.dmi',format='PNG',pnginfo=metadata)
 (SOURCE/'ViltrumLandscape.png').write_bytes(png.read_bytes());(SOURCE/'ViltrumLandscapeExport.json').write_text(json.dumps(report,indent=2)+'\n')
 print('Audited sixteen opaque full-square 32x32 terrain/floor states.')
