"""Render actual DMI frames/anchors at native player scale; no engine lighting."""
import ast, hashlib, json, re, sys
from pathlib import Path
from PIL import Image, ImageDraw
ROOT=Path(__file__).resolve().parents[2]
source_arg=next((a.split('=',1)[1] for a in sys.argv if a.startswith('--source=')),None)
source=ROOT/(source_arg or ('.codex-tmp/EarthNaturalLandmarks' if (ROOT/'docs/Maps/EarthNaturalLandmarks.json').exists() else '.codex-tmp/EarthWilderness' if (ROOT/'docs/Maps/EarthWilderness.json').exists() else '.codex-tmp/EarthNeighborhood'))
data=json.loads((source/'Preview.json').read_text())
report=json.loads((source/'EarthNeighborhood.json').read_text())
if '--preview' not in sys.argv:
 for file,field in [('src/Maps/SuperEarth.dmm','outputHash'),('src/Maps/CityInteriors.dmm','interiorHash'),('docs/Maps/CityBuildings.json','buildingDataHash')]:
  assert hashlib.sha256((ROOT/file).read_bytes()).hexdigest()==report[field],f'Preview differs from applied {file}; refresh it or explicitly use --preview'
out=ROOT/'docs/Maps/EarthNeighborhoodPreview';out.mkdir(exist_ok=True)
catalog={}
tree=ast.parse((ROOT/'tools/MapAssembly/RenderPlanetAtlas.py').read_text())
for node in tree.body:
 if isinstance(node,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='catalog' for t in node.targets):catalog.update(ast.literal_eval(node.value));break
for filename in ['EarthCityExport','EarthStreetExport']:
 for item in json.loads((ROOT/f'ArtSource/Earth/{filename}.json').read_text())['states']:
  catalog[item['type']]=(item['dmi'],item['state'],0)
details='src/Icons/Turfs/Earth/EarthNeighborhoodDetails.dmi'
river='src/Icons/Turfs/Earth/EarthRiverTerrain.dmi'
house='src/Icons/Turfs/Earth/EarthNeighborhoodHouses.dmi'
service='src/Icons/Turfs/Earth/EarthNeighborhoodServices.dmi'
props='src/Icons/Turfs/Earth/EarthNeighborhoodProps.dmi'
for suffix,state in {'':'asphalt','/LaneHorizontal':'lane_h','/LaneVertical':'lane_v','/CrossingHorizontal':'cross_h','/CrossingVertical':'cross_v','/Sidewalk':'sidewalk','/CurbNorth':'curb_n','/CurbSouth':'curb_s','/CurbEast':'curb_e','/CurbWest':'curb_w','/Lawn':'lawn','/GardenPath':'garden_path','/Bridge':'asphalt','/Bridge/North':'bridge_n','/Bridge/South':'bridge_s','/Bridge/East':'bridge_e','/Bridge/West':'bridge_w'}.items():catalog['/turf/EarthStreet'+suffix]=(details,state,0)
catalog['/turf/EarthBuildingStructure']=('src/Icons/Turfs/Earth/EarthBuildingTiles.dmi','cream_0_0',0)
catalog['/turf/EarthRiver']=(river,'water_255',0)
catalog['/turf/EarthRiverBank']=(river,'bank_0',0)
catalog['/turf/EarthRiverFall']=(river,'waterfall',0)
catalog['/turf/EarthRiverSteps']=(river,'steps',0)
catalog['/turf/EarthRiverRock']=(river,'rock_lip',0)
natural='src/Icons/Turfs/Earth/EarthNaturalTiles.dmi'
for suffix,state in {'':'sand_top_0','/Snow':'snow_top_0','/Forest':'forest_top_0','/Sand':'sand_ground','/Dune':'dune_4','/Ramp':'sand_ramp_n','/Cave':'cave_floor','/CaveMouth':'cave_mouth_1_1'}.items():catalog['/turf/EarthNaturalGround'+suffix]=(natural,state,0)
for suffix,state in {'':'sand_face_0','/Snow':'snow_face_0','/Forest':'forest_face_0','/Cave':'cave_roof'}.items():catalog['/turf/EarthNaturalRoof'+suffix]=(natural,state,0)
catalog['/turf/EarthNaturalFall']=(natural,'waterfall',0)
catalog['/turf/EarthNaturalFoam']=(natural,'foam',0)
catalog['/turf/EarthOceanBoundary']=(river,'water_255',0)
catalog['/turf/EarthBridge']=(details,'asphalt',0)
catalog['/turf/EarthFloor/Road']=(details,'asphalt',0)
catalog['/turf/EarthFloor/Sidewalk']=(details,'sidewalk',0)
catalog['/turf/EarthFloor/Crosswalk']=(details,'cross_h',0)
catalog['/turf/EarthStreet/Bridge/Sidewalk']=(details,'sidewalk',0)
catalog['/turf/EarthStreet/Bridge/Lane']=(details,'lane_h',0)
catalog['/turf/CityBuildingFootprint']=(details,'lawn',0)
catalog['/turf/CityBuildingFootprint/Earth']=(details,'lawn',0)
for suffix,state in {'':'cream','/Sage':'sage','/Brick':'brick','/Blue':'blue'}.items():catalog['/obj/EarthHouse'+suffix]=(house,state,0)
for state in ['hospital','shop','civic','garage']:catalog['/obj/EarthHouse/'+state.capitalize()]=(service,state,0)
for state in ['tree','bench','lamp','car']:catalog['/obj/EarthStreetFixture/'+state.capitalize()]=(props,state,0)
for suffix,state in {'':'hedge','/Fence':'fence','/Bin':'bin','/Flowers':'flowers'}.items():catalog['/obj/EarthStreetFixture'+suffix]=(details,state,0)
catalog['/obj/CityBuildingDoor/Earth']=(details,'doorstep',0)
catalog['/obj/CityBuildingDoor/Earth/Exit']=(details,'exit_mat',0)
catalog['/obj/Trees/Tree_20191']=('src/Icons/Turfs/Celianna/CeliannaFarmnatureTilesetPartLarge.dmi','Tree1',0)
catalog['/obj/Trees/Tree_20193']=('src/Icons/Turfs/Celianna/CeliannaFarmnatureTilesetPartLarge.dmi','Pine_Tree',0)
catalog['/obj/Trees/Tree_20194']=('src/Icons/Turfs/Celianna/CeliannaTileB1Large.dmi','Largetree2',0)
cache={}
source_cache={}
def sprite(filename,state=''):
 key=(filename,state)
 if key in cache:return cache[key]
 if filename not in source_cache:
  image=Image.open(ROOT/filename);meta=image.info.get('Description','');image=image.convert('RGBA')
  w=re.search(r'width\s*=\s*(\d+)',meta);h=re.search(r'height\s*=\s*(\d+)',meta);w=int(w[1]) if w else 32;h=int(h[1]) if h else 32
  indices={};index=0
  for match in re.finditer(r'state = "([^"]*)"(.*?)(?=state = |# END DMI|\Z)',meta,re.S):
   indices[match[1]]=index
   dirs=re.search(r'dirs = (\d+)',match[2]);frames=re.search(r'frames = (\d+)',match[2]);index+=(int(dirs[1]) if dirs else 1)*(int(frames[1]) if frames else 1)
  source_cache[filename]=(image,meta,w,h,indices)
 image,meta,w,h,indices=source_cache[filename]
 if meta and state not in indices:raise ValueError(f'Missing state: {filename}:{state}')
 index=indices.get(state,0)
 cols=image.width//w;result=image.crop((index%cols*w,index//cols*h,(index%cols+1)*w,(index//cols+1)*h));cache[key]=result;return result
unknown=set()
def render(bounds,pixels=32,player=None):
 a,b,c,d=bounds;canvas=Image.new('RGBA',((c-a+1)*pixels,(d-b+1)*pixels),(46,65,53,255));objects=[]
 for y in range(b,d+1):
  for x in range(a,c+1):
   stack=data['palette'][data['grid'][len(data['grid'])-y][x-1]];types=re.findall(r'/(?:turf|obj)(?:/\w+)*',stack)
   turf=next(v for v in types if v.startswith('/turf'))
   if turf not in catalog:unknown.add(turf);continue
   filename,state,period=catalog[turf]
   override=re.search(re.escape(turf)+r'\{[^}]*icon_state\s*=\s*"([^"]+)"',stack)
   if override:state=override[1]
   if period:state=f'{(x-1)%period},{(y-1)%period}'
   tile=sprite(filename,state)
   if tile.size!=(32,32):tile=tile.crop((((x-1)*32)%tile.width,((y-1)*32)%tile.height,((x-1)*32)%tile.width+32,((y-1)*32)%tile.height+32))
   tile=tile.resize((pixels,pixels),Image.Resampling.NEAREST)
   if turf=='/turf/EarthBuildingStructure':canvas.alpha_composite(sprite(river,'bank_0').resize((pixels,pixels),Image.Resampling.NEAREST),((x-a)*pixels,(d-y)*pixels))
   canvas.alpha_composite(tile,((x-a)*pixels,(d-y)*pixels))
   for t in types:
    if t.startswith('/obj') and t in catalog:objects.append((x,y,t))
 # Include sprites anchored just below the crop whose northward extent is visible.
 for y in range(max(1,b-8),b):
  for x in range(max(1,a-8),c+1):
   stack=data['palette'][data['grid'][len(data['grid'])-y][x-1]]
   for t in re.findall(r'/obj(?:/\w+)*',stack):
    if t in catalog:objects.append((x,y,t))
 if player:
  avatar=sprite('src/Icons/PlayerIcons/BaseIcons/WhiteMale.dmi').resize((pixels,pixels),Image.Resampling.NEAREST)
  canvas.alpha_composite(avatar,((player[0]-a)*pixels,(d-player[1])*pixels))
 for x,y,t in sorted(objects,key=lambda item:-item[1]):
  filename,state,_=catalog[t]
  if not (ROOT/filename).exists():continue
  overlay=sprite(filename,state);offset=-16 if t in ['/obj/EarthStreetFixture/Tree','/obj/EarthStreetFixture/Bench','/obj/EarthStreetFixture/Lamp'] else 0
  w,h=overlay.size
  if t.startswith('/obj/Trees/'):offset=-(w-32)//2
  offset_y=-10 if t=='/obj/Trees/Tree_20194' else 0
  overlay=overlay.resize((w*pixels//32,h*pixels//32),Image.Resampling.NEAREST)
  canvas.alpha_composite(overlay,((x-a)*pixels+offset*pixels//32,(d-y+1)*pixels-h*pixels//32-offset_y*pixels//32))
 return canvas.convert('RGB')
render([51,369,89,393],32,(61,378)).save(out/'ResidentialBlock.png')
render([51,330,89,352],32,(65,338)).save(out/'HospitalStreet.png')
render([101,289,127,310],32,(114,295)).save(out/'BookshopStreet.png')
render([116,304,150,323],32,(126,319)).save(out/'RiverBridge.png')
render([119,340,165,359],32,(129,347)).save(out/'WaterfallPark.png')
if (ROOT/'docs/Maps/EarthWilderness.json').exists():
 render([348,370,372,391],32).save(out/'EasternRiver.png')
 render([177,110,203,134],32).save(out/'DesertRiver.png')
render([40,258,201,404],8).save(out/'CityOverview.png')
render([1,1,500,500],4).save(out/'PlanetOverview.png')
if (source/'EarthNaturalLandmarks.json').exists():
 render([103,100,160,147],24,(132,104)).save(out/'SandstoneMountain.png')
 render([102,100,139,117],32,(132,104)).save(out/'SandstoneCaveEntrance.png')
 render([256,422,305,466],24,(281,425)).save(out/'ArcticMountain.png')
 render([338,330,397,353],32,(347,336)).save(out/'ForestWaterfall.png')
 render([90,61,174,103],16,(127,77)).save(out/'DuneField.png')
 surface_data=data
 data=json.loads((source/'InteriorPreview.json').read_text())
 render([325,215,358,238],32,(341,219)).save(out/'SandstoneCaveInterior.png')
 data=surface_data
if '--atlas' in sys.argv:
 full=render([1,1,500,500],8);target=ROOT/'docs/Maps';full.resize((1000,1000),Image.Resampling.NEAREST).save(target/'SuperEarthOverview.png')
 atlas=Image.new('RGB',(2120,2210),'#17232d');draw=ImageDraw.Draw(atlas);draw.text((20,16),'SUPER EARTH | NEIGHBORHOOD REVISION | NORTH UP',fill='#d5ddda')
 for r in range(5):
  for c in range(5):
   label=f'{"ABCDE"[r]}{c+1}';tile=full.crop((c*800,r*800,(c+1)*800,(r+1)*800));tile.save(target/f'SuperEarthChunks/SuperEarth{label}.png');x,y=20+c*420,60+r*425;draw.text((x,y),label,fill='#d5ddda');atlas.paste(tile.resize((400,400),Image.Resampling.NEAREST),(x,y+20))
 atlas.save(target/'SuperEarthChunkAtlas.png')
assert not unknown,f'Uncatalogued turfs: {unknown}'
print(f'Native-scale DMI composition and overview: {out}')
