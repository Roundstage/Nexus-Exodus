"""Export editable Aseprite sheets into audited 32px DMI states.

--initialize IMAGE creates the first source documents and refuses existing sources.
Subsequent exports read the Aseprite documents; they never replace source art.
"""
import argparse, hashlib, json, re, shutil, subprocess, tempfile
from pathlib import Path
from PIL import Image, PngImagePlugin
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'ArtSource/Viltrum'
parser=argparse.ArgumentParser()
parser.add_argument('--aseprite',required=True)
parser.add_argument('--initialize',type=Path)
args=parser.parse_args()
groups={
 'ViltrumGround': [(0,'teal_stone','/turf/ViltrumGround','ViltrumGround')],
 'ViltrumArchitecture': [(1,'civic_white','/turf/ViltrumFloor','ViltrumFloors'),(2,'road','/turf/ViltrumFloor/Road','ViltrumFloors'),(3,'structural','/turf/ViltrumFloor/Structural','ViltrumFloors'),(4,'wall','/turf/ViltrumWall','ViltrumWalls'),(5,'glass','/turf/ViltrumWall/Glass','ViltrumWalls'),(6,'column','/turf/ViltrumWall/Column','ViltrumWalls')],
 'ViltrumProps': [(8,'planter','/turf/ViltrumFurnishing','ViltrumProps'),(9,'bench','/turf/ViltrumFurnishing/Bench','ViltrumProps'),(10,'banner','/turf/ViltrumFurnishing/Banner','ViltrumProps'),(11,'memorial','/turf/ViltrumFurnishing/Memorial','ViltrumProps')],
 'ViltrumTechnology': [(12,'console','/obj/ViltrumConsole','ViltrumTechnology'),(13,'reactor','/obj/ViltrumConsole/Reactor','ViltrumTechnology'),(14,'beacon','/turf/ViltrumFloor/Beacon','ViltrumTechnology'),(15,'archive_table','/turf/ViltrumFurnishing/ArchiveTable','ViltrumTechnology')]
}
def digest(file):return hashlib.sha256(Path(file).read_bytes()).hexdigest()
if args.initialize:
 SOURCE.mkdir(parents=True,exist_ok=True)
 original=SOURCE/'ViltrumGeneratedKit.png'
 if original.exists() and digest(original)!=digest(args.initialize): raise SystemExit('A different original already exists; refusing replacement.')
 if not original.exists(): shutil.copy2(args.initialize,original)
 source=Image.open(args.initialize).convert('RGB')
 for name,states in groups.items():
  if (SOURCE/f'{name}.aseprite').exists(): continue
  sheet=Image.new('RGBA',(32*len(states),32))
  for col,(index,*_) in enumerate(states):
   x,y=index%4,index//4
   box=(round(source.width*x/4),round(source.height*y/4),round(source.width*(x+1)/4),round(source.height*(y+1)/4))
   # Format normalization of the original kit; opaque nearest-neighbor 32px cells.
   tile=source.crop(box).resize((32,32),Image.Resampling.NEAREST)
   sheet.paste(tile,(col*32,0))
  png=SOURCE/f'{name}.png'
  if not png.exists(): sheet.save(png)
  subprocess.run([args.aseprite,'--batch',str(png),'--save-as',str(SOURCE/f'{name}.aseprite')],check=True)
 palette=Image.new('RGB',(32,32)); colors=['#74cbe6','#009bb7','#124858','#dae5de','#142d3b','#b79c55','#d78846','#4ab2b7']
 for n,color in enumerate(colors): palette.paste(color,(n*4,0,n*4+4,32))
 if not (SOURCE/'ViltrumPalette.png').exists(): palette.save(SOURCE/'ViltrumPalette.png')
 if not (SOURCE/'ViltrumPalette.aseprite').exists(): subprocess.run([args.aseprite,'--batch',str(SOURCE/'ViltrumPalette.png'),'--save-as',str(SOURCE/'ViltrumPalette.aseprite')],check=True)
 (SOURCE/'Provenance.json').write_text(json.dumps({'origin':'OpenAI built-in image_gen, original Viltrum civic kit','generatedOriginal':'ViltrumGeneratedKit.png','sha256':digest(args.initialize),'normalization':'4x4 equal cells cropped and nearest-neighbor resized to opaque 32x32. Closed-door concept omitted until complete animation and logic exist. Aseprite sheets are editable raster sources.','reference':'User-supplied Imagem do Codex 6 de set. de 2026, 12_28_11.jpg; palette and mood only.','states':'ViltrumExport.json'},indent=2)+'\n')
destination=ROOT/'src/Icons/Turfs/Viltrum';destination.mkdir(parents=True,exist_ok=True)
report={'cellSize':[32,32],'anchor':'single turf; southwest pixel (0,0); no offsets or overhang','lighting':'baked accents; no active light sources','states':[],'sourceHashes':{}}
packs={}
with tempfile.TemporaryDirectory(prefix='ViltrumAssetExport-') as directory:
 for name,states in groups.items():
  document=SOURCE/f'{name}.aseprite'
  output=Path(directory)/f'{name}.png'
  subprocess.run([args.aseprite,'--batch',str(document),'--save-as',str(output)],check=True)
  sheet=Image.open(output).convert('RGBA')
  if sheet.size!=(32*len(states),32):raise ValueError(f'Unexpected source sheet dimensions: {name}')
  report['sourceHashes'][str(document.relative_to(ROOT))]=digest(document)
  for col,(_,state,dm_type,pack) in enumerate(states):
   tile=sheet.crop((col*32,0,col*32+32,32))
   if tile.getchannel('A').getextrema()!=(255,255):raise ValueError(f'Expected opaque baked tile: {state}')
   packs.setdefault(pack,[]).append((state,tile))
   report['states'].append({'state':state,'type':dm_type,'source':str(document.relative_to(ROOT)).replace('\\','/'),'sourceCell':col,'dmi':f'src/Icons/Turfs/Viltrum/{pack}.dmi','dirs':1,'frames':1})
 for pack,states in packs.items():
  sheet=Image.new('RGBA',(32*len(states),32))
  description='# BEGIN DMI\nversion = 4.0\nwidth = 32\nheight = 32\n'
  for col,(state,tile) in enumerate(states):
   sheet.paste(tile,(col*32,0));description+=f'state = "{state}"\n\tdirs = 1\n\tframes = 1\n'
  description+='# END DMI\n'
  metadata=PngImagePlugin.PngInfo();metadata.add_text('Description',description,zip=True)
  output=destination/f'{pack}.dmi';sheet.save(output,format='PNG',pnginfo=metadata)
  check=Image.open(output)
  assert check.size==(32*len(states),32)
  assert re.findall(r'state = "([^"]+)"',check.info['Description'])==[s[0] for s in states]
  assert all(re.fullmatch('[a-z][a-z0-9_]*',state) for state,_ in states)
(SOURCE/'ViltrumExport.json').write_text(json.dumps(report,indent=2)+'\n')
print(f'Exported and audited {len(report["states"])} states in {len(packs)} DMI files; sources retained.')
