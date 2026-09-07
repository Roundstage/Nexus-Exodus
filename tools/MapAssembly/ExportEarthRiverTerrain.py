"""Convert materials and native matching terrain transitions to a 32x32 DMI."""
import argparse,hashlib,json,subprocess,tempfile
from pathlib import Path
from PIL import Image,PngImagePlugin
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--aseprite',required=True);p.add_argument('--initialize',type=Path);a=p.parse_args()
folder=ROOT/'ArtSource/Earth';native=folder/'EarthRiverTerrain.aseprite';dmi=ROOT/'src/Icons/Turfs/Earth/EarthRiverTerrain.dmi'
names=[f'bank_{i}' for i in range(256)]+[f'water_{i}' for i in range(256)]+['waterfall','steps','rock_lip']
with tempfile.TemporaryDirectory(prefix='EarthRiver-') as temporary:
 temporary=Path(temporary)
 if a.initialize:
  assert not native.exists(),'Native source exists; edit it directly.'
  original=folder/'EarthRiverMaterialsOriginal.png';original.write_bytes(a.initialize.read_bytes());source=Image.open(original).convert('RGBA');swatches=Image.new('RGBA',(128,32))
  for i in range(4):
   col,row=i%2,i//2;tile=source.crop((col*source.width//2,row*source.height//2,(col+1)*source.width//2,(row+1)*source.height//2)).resize((32,32),Image.Resampling.NEAREST);assert tile.getchannel('A').getextrema()==(255,255);swatches.paste(tile,(i*32,0))
  materials=folder/'EarthRiverMaterials.png';swatches.save(materials)
  subprocess.run([a.aseprite,'--batch',str(materials),'--save-as',str(folder/'EarthRiverMaterials.aseprite')],check=True)
  subprocess.run([a.aseprite,'--batch','--script-param','materials='+materials.as_posix(),'--script-param','native='+native.as_posix(),'--script',str(ROOT/'tools/MapAssembly/CreateEarthRiverTerrain.lua')],check=True)
 png=temporary/'Export.png';subprocess.run([a.aseprite,'--batch',str(native),'--save-as',str(png)],check=True);sheet=Image.open(png).convert('RGBA')
 assert sheet.size==(512,1056)
 description='# BEGIN DMI\nversion = 4.0\n\twidth = 32\n\theight = 32\n';states=[]
 for i,name in enumerate(names):
  tile=sheet.crop((i%16*32,i//16*32,(i%16+1)*32,(i//16+1)*32));assert tile.getchannel('A').getextrema()==(255,255)
  description+=f'state = "{name}"\n\tdirs = 1\n\tframes = 1\n';states.append({'state':name,'cellSize':[32,32],'dmi':dmi.relative_to(ROOT).as_posix(),'source':native.relative_to(ROOT).as_posix(),'sourceCell':i,'dirs':1,'frames':1,'transparent':False})
 info=PngImagePlugin.PngInfo();info.add_text('Description',description+'# END DMI\n',zip=True);sheet.save(dmi,format='PNG',pnginfo=info);sheet.save(folder/'EarthRiverTerrain.png')
 (folder/'EarthRiverTerrainExport.json').write_text(json.dumps({'origin':'Original image_gen materials; native Aseprite matching edge/corner transitions.','maskBits':['north','east','south','west','northeast','southeast','southwest','northwest'],'sourceHashes':{native.relative_to(ROOT).as_posix():hashlib.sha256(native.read_bytes()).hexdigest()},'states':states},indent=2)+'\n')
 print('515 opaque terrain transition, waterfall, step and rock states exported.')
