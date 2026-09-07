"""Small deterministic tile previews, not runtime lighting/overlay simulation."""
import json, re, sys
from pathlib import Path
from PIL import Image, ImageDraw
ROOT = Path(__file__).resolve().parents[2]
data = json.loads(Path(sys.argv[1]).read_text(encoding='utf-8'))
planet = data['planet']
catalog = {
 '/turf/EarthOceanBoundary': ('src/Icons/Turfs/Turfs96.dmi','stillwater',0),
 '/turf/Ground_Wasteland': ('src/Icons/Turfs/WastelandGround.dmi', '', 0),
 '/turf/GroundDirt': ('src/Icons/Turfs/LargeTurfIcons/BigDirtTurfs.dmi', '', 4),
 '/turf/GroundSnow': ('src/Icons/Turfs/LargeTurfIcons/BigSnowTurf.dmi', '', 6),
 '/turf/Water2': ('src/Icons/Turfs/Turfs96.dmi', 'stillwater', 0),
 '/turf/TileStone': ('src/Icons/Turfs/Turf57.dmi', '55', 0),
 '/turf/Tile38': ('src/Icons/Turfs/Metaltiles1.dmi', 'metalfloora', 0),
 '/turf/Tile40': ('src/Icons/Turfs/Metaltiles1.dmi', 'gratingfloora', 0),
 '/turf/Wall21': ('src/Icons/Turfs/Metaltiles1.dmi', 'metalwalla', 0),
 '/turf/Tile22': ('src/Icons/Turfs/FloorsLAWL.dmi', 'SS Floor', 0),
 '/turf/Ground10': ('src/Icons/Turfs/Turf1.dmi','light desert',0),
 '/turf/Grass12': ('src/Icons/Turfs/JungleGrassTile.dmi','',0),
 '/turf/GroundIce2': ('src/Icons/Turfs/LargeTurfIcons/BigIceTurf2.dmi','',6),
 '/turf/Ground14': ('src/Icons/Turfs/LargeTurfIcons/BigSandTurf.dmi','',4),
 '/turf/Grass13': ('src/Icons/Turfs/LargeTurfIcons/BigGrassTurf2.dmi','',3),
 '/turf/Grass8': ('src/Icons/Turfs/LargeTurfIcons/BigGrassAndDirtTurf.dmi','',6),
 '/turf/Wall12': ('src/Icons/Turfs/Turfs3.dmi','cliff',0),
 '/turf/WaterFall': ('src/Icons/Turfs/TurfsLegacy1.dmi','waterfall',0),
 '/turf/Stairs_Grass': ('src/Icons/Turfs/Celianna/CeliannaFarmnatureTileset.dmi','Grass_Stairs',0),
}
extra = ROOT/'ArtSource/Viltrum/ViltrumExport.json'
if extra.exists():
 for item in json.loads(extra.read_text())['states']:
  if item.get('type'): catalog[item['type']] = (item['dmi'],item['state'],0)
 # Roads deliberately use the quiet structural state: tiled neon lines overwhelm
 # an eleven-tile boulevard. Keep the unused road concept in the editable source.
 catalog['/turf/ViltrumFloor/Road']=('src/Icons/Turfs/Viltrum/ViltrumFloors.dmi','structural',0)
for name in ['ViltrumRevision','ViltrumCapitalExport','ViltrumLandscapeExport','ViltrumDoorExport']:
 revision=ROOT/f'ArtSource/Viltrum/{name}.json'
 if revision.exists():
  for item in json.loads(revision.read_text())['states']:
   if item.get('type'): catalog[item['type']]=(item['dmi'],item['state'],0)
cache, frames = {}, {}
catalog['/turf/CityBuildingFootprint']=('src/Icons/Turfs/Viltrum/ViltrumFloors.dmi','civic_white',0)
catalog['/turf/CityBuildingFootprint/Earth']=('src/Icons/Turfs/Earth/EarthStreets.dmi','concrete',0)
catalog['/obj/CityBuildingDoor']=('src/Icons/Turfs/Viltrum/ViltrumDoors.dmi','civic_open',0)
buildings={}
for city in ['Viltrum','Earth']:
 manifest=ROOT/f'ArtSource/{city}/{city}BuildingExport.json'
 if manifest.exists():
  for item in json.loads(manifest.read_text())['states']:
   buildings[item['type']]=item
for name in ['EarthCityExport','EarthStreetExport']:
 earth_catalog=ROOT/f'ArtSource/Earth/{name}.json'
 if earth_catalog.exists():
  for item in json.loads(earth_catalog.read_text())['states']:
   catalog[item['type']]=(item['dmi'],item['state'],0)
catalog['/turf/EarthBridge']=('src/Icons/Turfs/Earth/EarthStreets.dmi','asphalt',0)
def sprite(filename, state):
 key=(filename,state)
 if key in frames: return frames[key]
 if filename not in cache:
  source=Image.open(ROOT/filename)
  metadata=source.info.get('Description','')
  width=re.search(r'^\s*width\s*=\s*(\d+)',metadata,re.M)
  height=re.search(r'^\s*height\s*=\s*(\d+)',metadata,re.M)
  w,h=(int(width[1]),int(height[1])) if width and height else ((32,32) if metadata else (source.width,source.height))
  states={};index=0
  for match in re.finditer(r'state = "([^"]*)"(.*?)(?=state = |# END DMI|\Z)',metadata,re.S):
   states[match[1]]=index
   dirs=re.search(r'dirs = (\d+)',match[2]);count=re.search(r'frames = (\d+)',match[2])
   index+=(int(dirs[1]) if dirs else 1)*(int(count[1]) if count else 1)
  if not states: states['']=0
  cache[filename]=(source.convert('RGBA'),w,h,states)
 source,w,h,states=cache[filename]
 if state not in states: raise ValueError(f'Missing DMI state: {filename}: {state}')
 index=states[state];cols=source.width//w
 frame=source.crop(((index%cols)*w,(index//cols)*h,(index%cols+1)*w,(index//cols+1)*h))
 frames[key]=frame.resize((8,8),Image.Resampling.NEAREST)
 return frames[key]
types=[];objects=[]
for stack in data['palette']:
 match=re.search(r'/turf(?:/\w+)*',stack)
 if not match or match[0] not in catalog: raise ValueError(f'Uncatalogued terrain: {stack}')
 types.append(match[0])
 objects.append([m[0] for m in re.finditer(r'/obj(?:/\w+)*',stack) if m[0] in catalog])
canvas=Image.new('RGB',(4000,4000),'#172c36');large_objects=[]
for row, values in enumerate(data['grid']):
 for col,index in enumerate(values):
  filename,state,period=catalog[types[index]]
  if period: state=f'{col%period},{(499-row)%period}'
  tile=sprite(filename,state)
  canvas.paste(tile,(col*8,row*8),tile)
  for obj in objects[index]:
   obj_file,obj_state,_=catalog[obj];overlay=sprite(obj_file,obj_state)
   canvas.paste(overlay,(col*8,row*8),overlay)
  for item in re.finditer(r'/obj(?:/\w+)*',data['palette'][index]):
   if item[0] in buildings:large_objects.append((col,row,buildings[item[0]]))
for col,row,item in sorted(large_objects,key=lambda v:v[1]):
 source=Image.open(ROOT/item['dmi']).convert('RGBA');names=['residence','hospital','civic','terrace','science','hangar'] if '/Viltrum/' in item['dmi'] else ['residence','hospital','civic','shop','workshop','apartment']
 index=names.index(item['state']);w,h=item['cellSize'];overlay=source.crop((index*w,0,(index+1)*w,h)).resize((w//4,h//4),Image.Resampling.NEAREST)
 canvas.paste(overlay,(col*8,(row+1)*8-h//4),overlay)
out=ROOT/'docs/Maps'
if data['baseline']: out=out/'RebuildBaseline'
out.mkdir(parents=True,exist_ok=True)
canvas.resize((1000,1000),Image.Resampling.NEAREST).save(out/f'{planet}Overview.png')
atlas=Image.new('RGB',(2120,2210),'#0b1b26');draw=ImageDraw.Draw(atlas)
draw.text((20,12),f'{planet.upper()} | 25 SOURCE CHUNKS | NORTH UP',fill='#c9eeee')
draw.text((20,29),'First-frame tiles and supported furnishings; legacy overlays, auto-edges and lighting need in-game review.',fill='#99b8c4')
chunks_dir=out/f'{planet}Chunks';chunks_dir.mkdir(exist_ok=True)
for row in range(5):
 for col in range(5):
  label=f'{"ABCDE"[row]}{col+1}'; x=20+col*420;y=65+row*425
  crop=canvas.crop((col*800,row*800,(col+1)*800,(row+1)*800))
  crop.save(chunks_dir/f'{planet}{label}.png')
  atlas.paste(crop.resize((400,400),Image.Resampling.NEAREST),(x,y+17))
  draw.text((x,y),f'{label}   X {col*100+1}-{col*100+100}   Y {(4-row)*100+1}-{(5-row)*100}',fill='#c9eeee')
atlas.save(out/f'{planet}ChunkAtlas.png')
print(f'Rendered {planet} terrain overview, 25 chunks and atlas: {out}')
