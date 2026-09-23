"""Compose actual shipped DMI frames at player scale; no simulated engine light."""
import ast, hashlib, json, re, sys
from pathlib import Path
from PIL import Image, ImageDraw
ROOT=Path(__file__).resolve().parents[2]
STAGE=ROOT/'.codex-tmp/ViltrumEcumenopolis'
OUT=ROOT/'docs/Maps/ViltrumEcumenopolisPreview';OUT.mkdir(exist_ok=True)
data=json.loads((STAGE/'Preview.json').read_text())
report=json.loads((STAGE/'ViltrumEcumenopolis.json').read_text())
catalog={}
tree=ast.parse((ROOT/'tools/MapAssembly/RenderPlanetAtlas.py').read_text())
for node in tree.body:
 if isinstance(node,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='catalog' for t in node.targets):catalog.update(ast.literal_eval(node.value));break
for name in ['ViltrumExport','ViltrumRevision','ViltrumCapitalExport','ViltrumLandscapeExport','ViltrumDoorExport']:
 for item in json.loads((ROOT/f'ArtSource/Viltrum/{name}.json').read_text())['states']:
  if item.get('type'):catalog[item['type']]=(item['dmi'],item['state'],0)
street='src/Icons/Turfs/Viltrum/ViltrumCityStreets.dmi'
for suffix,state in {'':'road','/LaneHorizontal':'lane_h','/LaneVertical':'lane_v','/CrossingHorizontal':'cross_h','/CrossingVertical':'cross_v','/Pavement':'pavement','/Garden':'garden','/Plaza':'plaza','/Quay':'quay_0'}.items():catalog['/turf/ViltrumCityStreet'+suffix]=(street,state,0)
catalog['/turf/ViltrumCityStructure']=('src/Icons/Turfs/Viltrum/ViltrumCityStructures.dmi','residence_0_0',0)
catalog['/turf/ViltrumFloor/Road']=('src/Icons/Turfs/Viltrum/ViltrumFloors.dmi','structural',0)
catalog['/obj/CityBuildingDoor/ViltrumCity']=(street,'threshold',0)
catalog['/obj/ViltrumCityTree']=('src/Icons/Turfs/Earth/EarthNeighborhoodProps.dmi','tree',0)
for item in json.loads((ROOT/'ArtSource/Viltrum/Ecumenopolis/Export.json').read_text())['states']:catalog[item['type']]=(item['dmi'],item['state'],0)
cache={};frames={}
def sprite(file,state=''):
 key=(file,state)
 if key in frames:return frames[key]
 if file not in cache:
  source=Image.open(ROOT/file);meta=source.info.get('Description','');im=source.convert('RGBA')
  w=re.search(r'width\s*=\s*(\d+)',meta);h=re.search(r'height\s*=\s*(\d+)',meta)
  w=int(w[1]) if w else 32;h=int(h[1]) if h else 32
  states={};index=0
  for match in re.finditer(r'state = "([^"]*)"(.*?)(?=state = |# END DMI|\Z)',meta,re.S):
   states[match[1]]=index
   dirs=re.search(r'dirs = (\d+)',match[2]);count=re.search(r'frames = (\d+)',match[2])
   index+=(int(dirs[1]) if dirs else 1)*(int(count[1]) if count else 1)
  cache[file]=(im,w,h,states)
 im,w,h,states=cache[file]
 assert not states or state in states,(file,state)
 index=states.get(state,0);cols=im.width//w
 result=im.crop((index%cols*w,index//cols*h,(index%cols+1)*w,(index//cols+1)*h));frames[key]=result;return result
parsed=[]
for stack in data['palette']:
 t=re.search(r'/turf(?:/\w+)*',stack)[0]
 assert t in catalog,('Uncatalogued turf',t)
 file,state,period=catalog[t]
 override=re.search(re.escape(t)+r'\{[^}]*icon_state\s*=\s*"([^"]+)"',stack)
 if override:state=override[1]
 objects=[s[0] for s in re.finditer(r'/obj(?:/\w+)*',stack) if s[0] in catalog]
 parsed.append((t,file,state,period,objects))
def render(bounds,pixels=32,player=None):
 a,b,c,d=bounds;canvas=Image.new('RGBA',((c-a+1)*pixels,(d-b+1)*pixels),(123,141,146,255));objects=[]
 for y in range(b,d+1):
  for x in range(a,c+1):
   t,file,state,period,items=parsed[data['grid'][500-y][x-1]]
   if period:state=f'{(x-1)%period},{(y-1)%period}'
   tile=sprite(file,state).resize((pixels,pixels),Image.Resampling.NEAREST)
   canvas.alpha_composite(tile,((x-a)*pixels,(d-y)*pixels))
   objects.extend((x,y,item) for item in items)
 # Include offscreen anchors whose silhouettes overlap the crop.
 for y in range(max(1,b-10),d+1):
  for x in range(max(1,a-8),c+1):
   if x>=a and y>=b:continue
   objects.extend((x,y,item) for item in parsed[data['grid'][500-y][x-1]][4])
 if player:canvas.alpha_composite(sprite('src/Icons/PlayerIcons/BaseIcons/WhiteMale.dmi').resize((pixels,pixels),Image.Resampling.NEAREST),((player[0]-a)*pixels,(d-player[1])*pixels))
 for x,y,item in sorted(objects,key=lambda p:-p[1]):
  file,state,_=catalog[item];frame=sprite(file,state);w,h=frame.size
  offset=-16 if item=='/obj/ViltrumCityTree' else 0
  canvas.alpha_composite(frame.resize((w*pixels//32,h*pixels//32),Image.Resampling.NEAREST),((x-a)*pixels+offset*pixels//32,(d-y+1)*pixels-h*pixels//32))
 return canvas.convert('RGB')
houses=[b for b in report['buildings'] if b['style']=='residence' and b.get('id')]
sample=next(b for b in houses if b['bounds'][1]>300)
x,y,_,_=sample['bounds']
render([x-3,y-9,x+26,y+8],player=(x+8,y-2)).save(OUT/'ResidentialStreet.png')
hospital=next(b for b in report['buildings'] if b['style']=='hospital' and b.get('id'))
x,y,_,_=hospital['bounds'];render([x-4,y-9,x+25,y+9],player=(x+3,y-2)).save(OUT/'HospitalStreet.png')
civic=next(b for b in report['buildings'] if b.get('id')=='viltrum_001')
x,y,_,_=civic['bounds'];render([x-12,y-12,x+19,y+12],player=(x+3,y-3)).save(OUT/'ImperialCourt.png')
render([1,1,500,500],4).save(OUT/'PlanetOverview.png')
render([200,55,300,160],8).save(OUT/'ArrivalDistrict.png')
atlas=Image.new('RGB',(2120,2210),'#192a35');draw=ImageDraw.Draw(atlas)
draw.text((20,18),'VILTRUM | ECUMENOPOLIS | DMI COMPOSITION | NORTH UP',fill='#d2e4dd')
for r in range(5):
 for c in range(5):
  x=20+c*420;y=60+r*425
  tile=render([c*100+1,(4-r)*100+1,(c+1)*100,(5-r)*100],4)
  if '--atlas' in sys.argv:tile.save(ROOT/f'docs/Maps/ViltrumChunks/Viltrum{"ABCDE"[r]}{c+1}.png')
  draw.text((x,y),f'{"ABCDE"[r]}{c+1}',fill='#d2e4dd');atlas.paste(tile,(x,y+20))
atlas.save(OUT/'ChunkAtlas.png')
if '--atlas' in sys.argv:
 atlas.save(ROOT/'docs/Maps/ViltrumChunkAtlas.png')
 Image.open(OUT/'PlanetOverview.png').resize((1000,1000),Image.Resampling.NEAREST).save(ROOT/'docs/Maps/ViltrumOverview.png')
(OUT/'Provenance.json').write_text(json.dumps({'candidateHash':hashlib.sha256((STAGE/'Viltrum.dmm').read_bytes()).hexdigest(),
 'render':'Actual DMI frames and coordinates; native-scale neighborhood crops, scaled planet atlas. Engine lighting, sight and interactive play are user review.',
 'dmiHashes':{f:hashlib.sha256((ROOT/f).read_bytes()).hexdigest() for f,_,_ in catalog.values() if (ROOT/f).exists()}},indent=2)+'\n')
print('Rendered actual DMI neighborhood crops and 25-chunk atlas.')
