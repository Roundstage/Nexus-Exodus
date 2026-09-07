"""Export the editable Aseprite street additions and audit DMI states."""
import argparse, hashlib, json, subprocess, tempfile
from pathlib import Path
from PIL import Image, PngImagePlugin
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--aseprite',required=True);p.add_argument('--initialize',action='store_true');a=p.parse_args()
names=['asphalt','lane_h','lane_v','cross_h','cross_v','sidewalk','curb_n','curb_s','curb_e','curb_w','lawn','garden_path','doorstep','exit_mat','hedge','fence','bin','flowers','bridge_n','bridge_s','bridge_e','bridge_w']
folder=ROOT/'ArtSource/Earth';native=folder/'EarthNeighborhoodDetails.aseprite';dmi=ROOT/'src/Icons/Turfs/Earth/EarthNeighborhoodDetails.dmi'
if a.initialize:
 assert not native.exists(),'Edit the native source rather than reinitializing.'
 subprocess.run([a.aseprite,'--batch','--script-param','native='+native.as_posix(),'--script',str(ROOT/'tools/MapAssembly/CreateEarthStreetDetails.lua')],check=True)
with tempfile.TemporaryDirectory(prefix='EarthDetails-') as temporary:
 png=Path(temporary)/'Export.png';subprocess.run([a.aseprite,'--batch',str(native),'--save-as',str(png)],check=True)
 sheet=Image.open(png).convert('RGBA');assert sheet.size==(32*len(names),32)
 description='# BEGIN DMI\nversion = 4.0\n\twidth = 32\n\theight = 32\n';states=[]
 for i,name in enumerate(names):
  transparent=12<=i<=17;alpha=sheet.crop((i*32,0,(i+1)*32,32)).getchannel('A')
  assert alpha.getextrema()==((0,255) if transparent else (255,255)),name
  description+=f'state = "{name}"\n\tdirs = 1\n\tframes = 1\n'
  states.append({'state':name,'cellSize':[32,32],'dmi':dmi.relative_to(ROOT).as_posix(),'source':native.relative_to(ROOT).as_posix(),'sourceCell':i,'dirs':1,'frames':1,'transparent':transparent})
 info=PngImagePlugin.PngInfo();info.add_text('Description',description+'# END DMI\n',zip=True);sheet.save(dmi,format='PNG',pnginfo=info);sheet.save(folder/'EarthNeighborhoodDetails.png')
 (folder/'EarthNeighborhoodDetailsExport.json').write_text(json.dumps({'origin':'Native Aseprite additions to the established Earth street kit.','sourceHashes':{native.relative_to(ROOT).as_posix():hashlib.sha256(native.read_bytes()).hexdigest()},'states':states},indent=2)+'\n')
 print(f'{len(names)} audited street, curb, garden, bridge and doorstep states.')
