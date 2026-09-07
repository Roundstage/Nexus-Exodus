"""Export closed/opening/open/closing sequences from twenty native pose cells."""
import argparse,hashlib,json,subprocess,tempfile
from pathlib import Path
from PIL import Image,PngImagePlugin
ROOT=Path(__file__).resolve().parents[2];SOURCE=ROOT/'ArtSource/Viltrum'
parser=argparse.ArgumentParser();parser.add_argument('--aseprite',required=True);parser.add_argument('--initialize',type=Path);args=parser.parse_args()
styles=['civic','palace','laboratory','hangar','force_field'];types=['/obj/ViltrumDoor','/obj/ViltrumDoor/Palace','/obj/ViltrumDoor/Laboratory','/obj/ViltrumDoor/Hangar','/obj/ViltrumDoor/ForceField'];document=SOURCE/'ViltrumDoors.aseprite'
with tempfile.TemporaryDirectory(prefix='ViltrumDoors-') as temporary:
 temporary=Path(temporary)
 if args.initialize:
  if document.exists():raise ValueError('Native door source exists; edit it directly.')
  original=SOURCE/'ViltrumDoorsOriginal.png'
  if original.exists():raise ValueError('Original exists; refusing replacement.')
  original.write_bytes(args.initialize.read_bytes());incoming=Image.open(original).convert('RGBA');sheet=Image.new('RGBA',(640,32))
  for row in range(5):
   for col in range(4):
    tile=incoming.crop((round(col*incoming.width/4),round(row*incoming.height/5),round((col+1)*incoming.width/4),round((row+1)*incoming.height/5))).resize((32,32),Image.Resampling.NEAREST)
    tile.putalpha(tile.getchannel('A').point(lambda value:255 if value>=128 else 0));sheet.paste(tile,((row*4+col)*32,0))
  png=temporary/'Import.png';sheet.save(png);subprocess.run([args.aseprite,'--batch',str(png),'--save-as',str(document)],check=True)
 png=temporary/'Export.png';subprocess.run([args.aseprite,'--batch',str(document),'--save-as',str(png)],check=True)
 poses=Image.open(png).convert('RGBA');assert poses.size==(640,32)
 sheet=Image.new('RGBA',(960,32));description='# BEGIN DMI\nversion = 4.0\n\twidth = 32\n\theight = 32\n';index=0
 report={'cellSize':[32,32],'animationTicks':3,'states':[],'sourceHashes':{str(document.relative_to(ROOT)).replace('\\','/'):hashlib.sha256(document.read_bytes()).hexdigest()}}
 for row,style in enumerate(styles):
  for suffix,cells in [('closed',[0]),('opening',[0,1]),('open',[2]),('closing',[2,3])]:
   state=f'{style}_{suffix}';description+=f'state = "{state}"\n\tdirs = 1\n\tframes = {len(cells)}\n'
   if len(cells)>1:description+='\tdelay = 1.5,1.5\n\tloop = 1\n'
   for cell in cells:
    tile=poses.crop(((row*4+cell)*32,0,(row*4+cell+1)*32,32));assert set(tile.getchannel('A').tobytes())<={0,255}
    if suffix=='open':assert tile.getpixel((16,16))[3]==0,'Open doorway must reveal its floor'
    if suffix=='closed':assert tile.getpixel((16,16))[3]==255,'Closed panel must cover its center'
    sheet.paste(tile,(index*32,0));index+=1
   report['states'].append({'state':state,'type':types[row] if suffix=='closed' else None,'dmi':'src/Icons/Turfs/Viltrum/ViltrumDoors.dmi','source':str(document.relative_to(ROOT)).replace('\\','/'),'sourceCells':[row*4+c for c in cells],'dirs':1,'frames':len(cells),'transparent':True})
 description+='# END DMI\n';metadata=PngImagePlugin.PngInfo();metadata.add_text('Description',description,zip=True);sheet.save(ROOT/'src/Icons/Turfs/Viltrum/ViltrumDoors.dmi',format='PNG',pnginfo=metadata)
 (SOURCE/'ViltrumDoors.png').write_bytes(png.read_bytes());(SOURCE/'ViltrumDoorExport.json').write_text(json.dumps(report,indent=2)+'\n');print('Audited 20 door states / 30 frames, five styles, transparent open apertures and 3-tick animations.')
