"""Native Aseprite building sheets -> multi-tile DMI, with real cutout alpha."""
import argparse, hashlib, json, subprocess, tempfile
from pathlib import Path
from collections import deque
from PIL import Image, PngImagePlugin
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('planet',choices=['Viltrum','Earth']);p.add_argument('--initialize',type=Path);p.add_argument('--aseprite',required=True);args=p.parse_args()
folder=ROOT/'ArtSource'/args.planet;folder.mkdir(exist_ok=True)
names=['residence','hospital','civic','terrace','science','hangar'] if args.planet=='Viltrum' else ['residence','hospital','civic','shop','workshop','apartment']
w,h=256,320 if args.planet=='Viltrum' else 256
native=folder/f'{args.planet}Buildings.aseprite'
with tempfile.TemporaryDirectory(prefix='CityBuildings-') as temporary:
 temp=Path(temporary)
 if args.initialize:
  if native.exists():raise ValueError('Native source exists; edit it instead of reinitializing.')
  original=folder/f'{args.planet}BuildingsCutoutsOriginal.png';original.write_bytes(args.initialize.read_bytes())
  image=Image.open(original).convert('RGBA');sheet=Image.new('RGBA',(w*6,h))
  for i in range(6):
   col,row=i%3,i//3;tile=image.crop((round(col*image.width/3),round(row*image.height/2),round((col+1)*image.width/3),round((row+1)*image.height/2)))
   # Technical chroma-key normalization; generated originals remain untouched.
   pixels=list(tile.getdata());mask=bytearray(len(pixels))
   for j,(r,g,b,a) in enumerate(pixels):mask[j]=int(a>=128 and not(r>150 and b>150 and g<130 and min(r,b)-g>70))
   # Keep the building component; discard disconnected atlas guide marks.
   seen=bytearray(len(mask));largest=[];tw,th=tile.size
   for j,on in enumerate(mask):
    if not on or seen[j]:continue
    seen[j]=1;queue=deque([j]);component=[]
    while queue:
     v=queue.popleft();component.append(v);x,y=v%tw,v//tw
     for n in [v-1 if x else -1,v+1 if x<tw-1 else -1,v-tw if y else -1,v+tw if y<th-1 else -1]:
      if n>=0 and mask[n] and not seen[n]:seen[n]=1;queue.append(n)
    if len(component)>len(largest):largest=component
   alpha=bytearray(len(mask))
   for j in largest:alpha[j]=255
   tile.putalpha(Image.frombytes('L',tile.size,bytes(alpha)));box=tile.getbbox();assert box and len(largest)>1000
   tile=tile.crop(box);scale=min((w-8)/tile.width,(h-8)/tile.height);tile=tile.resize((round(tile.width*scale),round(tile.height*scale)),Image.Resampling.NEAREST)
   sheet.paste(tile,(i*w+(w-tile.width)//2,h-4-tile.height))
  incoming=temp/'Incoming.png';sheet.save(incoming);subprocess.run([args.aseprite,'--batch',str(incoming),'--save-as',str(native)],check=True)
 exported=temp/'Native.png';subprocess.run([args.aseprite,'--batch',str(native),'--save-as',str(exported)],check=True)
 sheet=Image.open(exported).convert('RGBA');assert sheet.size==(w*6,h)
 description=f'# BEGIN DMI\nversion = 4.0\n\twidth = {w}\n\theight = {h}\n'
 states=[];base='/obj/CityHouse'+('/Earth' if args.planet=='Earth' else '')
 suffixes=['','/Hospital','/Civic','/Terrace','/Science','/Hangar'] if args.planet=='Viltrum' else ['','/Hospital','/Civic','/Shop','/Workshop','/Apartment']
 for i,name in enumerate(names):
  tile=sheet.crop((i*w,0,(i+1)*w,h));assert set(tile.getchannel('A').tobytes())=={0,255};assert tile.getpixel((0,0))[3]==0
  description+=f'state = "{name}"\n\tdirs = 1\n\tframes = 1\n'
  states.append({'state':name,'type':base+suffixes[i],'dmi':f'src/Icons/Turfs/{args.planet}/{args.planet}Buildings.dmi','source':str(native.relative_to(ROOT)).replace('\\','/'),'cellSize':[w,h],'footprint':[8,h//32],'dirs':1,'frames':1,'transparent':True})
 description+='# END DMI\n';metadata=PngImagePlugin.PngInfo();metadata.add_text('Description',description,zip=True)
 destination=ROOT/f'src/Icons/Turfs/{args.planet}/{args.planet}Buildings.dmi';sheet.save(destination,format='PNG',pnginfo=metadata)
 sheet.save(folder/f'{args.planet}Buildings.png')
 report={'sourceHashes':{str(native.relative_to(ROOT)).replace('\\','/'):hashlib.sha256(native.read_bytes()).hexdigest()},'states':states}
 (folder/f'{args.planet}BuildingExport.json').write_text(json.dumps(report,indent=2)+'\n')
 print(f'{args.planet}: six {w}x{h} building states, genuine binary alpha, native source retained.')
