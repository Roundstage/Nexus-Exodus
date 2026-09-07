"""Curate existing Nexus assets into a small editable Earth mapping kit."""
import argparse,hashlib,json,re,subprocess,tempfile
from pathlib import Path
from PIL import Image,PngImagePlugin
ROOT=Path(__file__).resolve().parents[2];SOURCE=ROOT/'ArtSource/Earth'
parser=argparse.ArgumentParser();parser.add_argument('--aseprite',required=True);parser.add_argument('--initialize',action='store_true');args=parser.parse_args()
# state, DM type, existing source, existing state. No upstream imports.
floorfile='src/Icons/Turfs/FloorsLAWL.dmi';rooffile='src/Icons/Turfs/Celianna/TileA3.dmi';metalfile='src/Icons/Turfs/Tiles1212011.dmi';furniture='src/Icons/MapObjects/Furnature.dmi';lab='src/Icons/Objects/Technology/Lab.dmi'
items=[('wood','/turf/EarthFloor',floorfile,'Wood Medium'),('sidewalk','/turf/EarthFloor/Sidewalk',metalfile,'west city tile'),('road','/turf/EarthFloor/Road',metalfile,'Metal Roof'),('stone','/turf/EarthFloor/Stone',floorfile,'Flagstone Grey'),('clinic','/turf/EarthFloor/Clinic',metalfile,'cool tile'),('grate','/turf/EarthFloor/Grate',metalfile,'Metal Grate'),('bridge','/turf/EarthBridge',floorfile,'Wood Medium'),('roof_red','/turf/EarthRoof',rooffile,'RedRoof3'),('roof_dark','/turf/EarthRoof/Dark',rooffile,'BlackRoof3'),('roof_blue','/turf/EarthRoof/Blue',rooffile,'BlueRoof3'),('facade','/turf/EarthFacade',rooffile,'PlainWall3'),('facade_brick','/turf/EarthFacade/Brick',rooffile,'RedBrickWall3'),('facade_wood','/turf/EarthFacade/Wood',rooffile,'WoodenWall3'),('bed','/obj/EarthFurnishing',furniture,'39'),('bookcase','/obj/EarthFurnishing/Bookcase',furniture,'6'),('cabinet','/obj/EarthFurnishing/Cabinet',furniture,'4'),('dresser','/obj/EarthFurnishing/Dresser',furniture,'36'),('bench','/obj/EarthFurnishing/Bench',furniture,'34'),('chair','/obj/EarthFurnishing/Chair',furniture,'75'),('table','/obj/EarthFurnishing/Table',furniture,'56'),('shelf','/obj/EarthFurnishing/Shelf',furniture,'33'),('desk','/obj/EarthFurnishing/Desk',furniture,'28'),('flowers','/obj/EarthFurnishing/Flowers',furniture,'31'),('computer','/obj/EarthDirectory',lab,'computer'),('stove','/obj/EarthFurnishing/Stove',lab,'Stove'),('sink','/obj/EarthFurnishing/Sink',lab,'sink'),('files','/obj/EarthFurnishing/Files',lab,'Files'),('toolbox','/obj/EarthFurnishing/Toolbox',lab,'Tool2')]
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def existing_frame(filename,state):
 source=ROOT/filename
 if filename==furniture:source=ROOT/'.codex-tmp/EarthAssetAudit/Furnature.dmi'
 im=Image.open(source);meta=im.info['Description'];w=re.search(r'width\s*=\s*(\d+)',meta);h=re.search(r'height\s*=\s*(\d+)',meta);w=int(w[1]) if w else 32;h=int(h[1]) if h else 32;assert (w,h)==(32,32);index=0
 for match in re.finditer(r'state = "([^"]*)"(.*?)(?=state = |# END DMI|\Z)',meta,re.S):
  if match[1]==state:
   cols=im.width//w;return im.convert('RGBA').crop((index%cols*w,index//cols*h,(index%cols+1)*w,(index//cols+1)*h))
  dirs=re.search(r'dirs = (\d+)',match[2]);frames=re.search(r'frames = (\d+)',match[2]);index+=(int(dirs[1]) if dirs else 1)*(int(frames[1]) if frames else 1)
 raise ValueError(f'Missing source state {filename}:{state}')
SOURCE.mkdir(exist_ok=True,parents=True);document=SOURCE/'EarthCityAdditions.aseprite'
with tempfile.TemporaryDirectory(prefix='EarthCityKit-') as temporary:
 temporary=Path(temporary)
 if args.initialize:
  if document.exists():raise ValueError('Native source exists; edit it directly.')
  sheet=Image.new('RGBA',(len(items)*32,32))
  for index,(_,_,filename,state) in enumerate(items):sheet.paste(existing_frame(filename,state),(index*32,0))
  png=temporary/'Import.png';sheet.save(png);subprocess.run([args.aseprite,'--batch',str(png),'--save-as',str(document)],check=True)
 png=temporary/'Export.png';subprocess.run([args.aseprite,'--batch',str(document),'--save-as',str(png)],check=True)
 sheet=Image.open(png).convert('RGBA');assert sheet.size==(len(items)*32,32)
 description='# BEGIN DMI\nversion = 4.0\n\twidth = 32\n\theight = 32\n';report={'origin':'Curated pre-existing Nexus Exodus assets; no new claim of authorship or upstream import.','states':[],'sourceHashes':{str(document.relative_to(ROOT)).replace('\\','/'):digest(document)},'originalSourceHashes':{filename:digest(ROOT/filename) for _,_,filename,_ in items}}
 for index,(state,dm_type,filename,original_state) in enumerate(items):
  tile=sheet.crop((index*32,0,index*32+32,32));alpha=tile.getchannel('A')
  if dm_type.startswith('/obj/'):assert alpha.getextrema()==(0,255),f'Object background is opaque: {state}'
  else:assert alpha.getextrema()==(255,255),f'Architectural tile must fill its square: {state}'
  description+=f'state = "{state}"\n\tdirs = 1\n\tframes = 1\n'
  report['states'].append({'state':state,'type':dm_type,'dmi':'src/Icons/Turfs/Earth/EarthCity.dmi','source':str(document.relative_to(ROOT)).replace('\\','/'),'sourceCell':index,'originalSource':filename,'originalState':original_state,'modification':'First south-facing frame; state renamed; pixels retained. Legacy binary DMI decoded by BYOND using identity blend.','dirs':1,'frames':1,'transparent':dm_type.startswith('/obj/')})
 description+='# END DMI\n';metadata=PngImagePlugin.PngInfo();metadata.add_text('Description',description,zip=True);output=ROOT/'src/Icons/Turfs/Earth/EarthCity.dmi';output.parent.mkdir(exist_ok=True);sheet.save(output,format='PNG',pnginfo=metadata)
 (SOURCE/'EarthCityAdditions.png').write_bytes(png.read_bytes());(SOURCE/'EarthCityExport.json').write_text(json.dumps(report,indent=2)+'\n');print(f'Audited {len(items)} curated Earth states; original assets unchanged.')
