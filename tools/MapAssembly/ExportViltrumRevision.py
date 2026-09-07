"""Export revised full-block architecture and alpha furnishings from Aseprite."""
import argparse,hashlib,json,shutil,subprocess,tempfile
from pathlib import Path
from PIL import Image,PngImagePlugin
ROOT=Path(__file__).resolve().parents[2];SOURCE=ROOT/'ArtSource/Viltrum'
parser=argparse.ArgumentParser()
parser.add_argument('--aseprite',required=True)
parser.add_argument('--envelope',type=Path)
parser.add_argument('--objects',type=Path)
args=parser.parse_args()
groups={
 'ViltrumEnvelope':{'columns':2,'rows':2,'input':args.envelope,'alpha':False,'states':[
  ('wall_face','/turf/ViltrumWall'),('roof','/turf/ViltrumRoof'),('glass_face','/turf/ViltrumWall/Glass'),('roof_dark','/turf/ViltrumRoof/Dark')]},
 'ViltrumObjects':{'columns':4,'rows':2,'input':args.objects,'alpha':True,'states':[
  ('planter','/obj/ViltrumFurnishing'),('bench','/obj/ViltrumFurnishing/Bench'),('banner','/obj/ViltrumFurnishing/Banner'),('memorial','/obj/ViltrumFurnishing/Memorial'),('console','/obj/ViltrumConsole'),('reactor','/obj/ViltrumConsole/Reactor'),('beacon','/obj/ViltrumFurnishing/LandingBeacon'),('archive_table','/obj/ViltrumFurnishing/ArchiveTable')]}
}
report={'cellSize':[32,32],'anchor':'One 32x32 cell at pixel (0,0), no overhang. Roofs carry structural collision/opacity; wall faces are decorative. Furnishings use alpha and preserve underlying turf.','states':[],'sourceHashes':{}}
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
with tempfile.TemporaryDirectory(prefix='ViltrumRevision-') as directory:
 for name,group in groups.items():
  document=SOURCE/f'{name}.aseprite'
  if group['input']:
   if document.exists():raise ValueError(f'Source already exists; edit it in Aseprite: {document}')
   incoming=Image.open(group['input']).convert('RGBA')
   if group['alpha'] and incoming.getchannel('A').getextrema()[0]==255:raise ValueError('Furnishing input has no real transparency; refuse painted backgrounds.')
   original=SOURCE/f'{name}Original.png'
   if original.exists() and digest(original)!=digest(group['input']):raise ValueError('Different original exists; refusing replacement.')
   if not original.exists():shutil.copy2(group['input'],original)
   sheet=Image.new('RGBA',(32*len(group['states']),32))
   for index in range(len(group['states'])):
    x,y=index%group['columns'],index//group['columns']
    box=(round(incoming.width*x/group['columns']),round(incoming.height*y/group['rows']),round(incoming.width*(x+1)/group['columns']),round(incoming.height*(y+1)/group['rows']))
    tile=incoming.crop(box).resize((32,32),Image.Resampling.NEAREST)
    sheet.paste(tile,(index*32,0))
   png=Path(directory)/f'{name}.png';sheet.save(png)
   subprocess.run([args.aseprite,'--batch',str(png),'--save-as',str(document)],check=True)
  png=Path(directory)/f'{name}Export.png'
  subprocess.run([args.aseprite,'--batch',str(document),'--save-as',str(png)],check=True)
  sheet=Image.open(png).convert('RGBA')
  assert sheet.size==(32*len(group['states']),32)
  report['sourceHashes'][str(document.relative_to(ROOT)).replace('\\','/')]=digest(document)
  description='# BEGIN DMI\nversion = 4.0\n\twidth = 32\n\theight = 32\n'
  for index,(state,dm_type) in enumerate(group['states']):
   tile=sheet.crop((index*32,0,index*32+32,32));alpha=tile.getchannel('A')
   if group['alpha']:
    assert alpha.getextrema()[0]==0 and alpha.getextrema()[1]==255,f'{state} needs transparent background and opaque object'
    assert sum(1 for a in alpha.tobytes() if a==0)>32,f'{state} is not a usable cutout'
   else:assert alpha.getextrema()==(255,255)
   report['states'].append({'state':state,'type':dm_type,'dmi':f'src/Icons/Turfs/Viltrum/{name}.dmi','source':str(document.relative_to(ROOT)).replace('\\','/'),'sourceCell':index,'dirs':1,'frames':1,'transparent':group['alpha']})
   description+=f'state = "{state}"\n\tdirs = 1\n\tframes = 1\n'
  description+='# END DMI\n';metadata=PngImagePlugin.PngInfo();metadata.add_text('Description',description,zip=True)
  output=ROOT/f'src/Icons/Turfs/Viltrum/{name}.dmi';sheet.save(output,format='PNG',pnginfo=metadata)
  assert Image.open(output).info['Description']==description
(SOURCE/'ViltrumRevision.json').write_text(json.dumps(report,indent=2)+'\n')
print('Audited four opaque architectural states and eight transparent object states; editable sources preserved.')
