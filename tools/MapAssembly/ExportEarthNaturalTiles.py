"""Crop generated material samples; export native modular terrain as 32px DMIs."""
import argparse, hashlib, json, subprocess, tempfile, re
from pathlib import Path
from PIL import Image, PngImagePlugin
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--initialize',type=Path);p.add_argument('--refine',action='store_true');p.add_argument('--aseprite',required=True);a=p.parse_args()
folder=ROOT/'ArtSource/Earth';native=folder/'EarthNaturalTiles.aseprite';names_file=folder/'EarthNaturalTileStates.txt'
with tempfile.TemporaryDirectory(prefix='EarthNatural-') as temporary:
 temporary=Path(temporary)
 if a.initialize:
  assert not native.exists(),'Edit existing native terrain; do not reinitialize.'
  original=folder/'EarthNaturalMaterialsOriginal.png';original.write_bytes(a.initialize.read_bytes())
  source=Image.open(original).convert('RGBA');materials=Image.new('RGBA',(128,128))
  for row in range(4):
   for col in range(4):
    tile=source.crop((col*source.width//4,row*source.height//4,(col+1)*source.width//4,(row+1)*source.height//4)).resize((32,32),Image.Resampling.NEAREST)
    assert tile.getchannel('A').getextrema()==(255,255),'Terrain samples must fill the whole square.'
    materials.paste(tile,(col*32,row*32))
  materials.save(folder/'EarthNaturalMaterials.png')
  subprocess.run([a.aseprite,'--batch',str(folder/'EarthNaturalMaterials.png'),'--save-as',str(folder/'EarthNaturalMaterials.aseprite')],check=True)
 if a.initialize or a.refine:
  ground=Image.open(ROOT/'src/Icons/Turfs/Turf1.dmi');description=ground.info['Description'];index=0
  for match in re.finditer(r'state = "([^"]*)"(.*?)(?=state = |# END DMI|\Z)',description,re.S):
   if match[1]=='light desert':break
   dirs=re.search(r'dirs = (\d+)',match[2]);frames=re.search(r'frames = (\d+)',match[2]);index+=(int(dirs[1]) if dirs else 1)*(int(frames[1]) if frames else 1)
  else:raise ValueError('Missing native desert ground')
  cols=ground.width//32;ground.convert('RGBA').crop((index%cols*32,index//cols*32,(index%cols+1)*32,(index//cols+1)*32)).save(folder/'EarthNaturalBaseGround.png')
  subprocess.run([a.aseprite,'--batch','--script-param','materials='+str(folder/'EarthNaturalMaterials.png'),'--script-param','base='+str(folder/'EarthNaturalBaseGround.png'),'--script-param','native='+str(native),'--script-param','names='+str(names_file),'--script',str(ROOT/'tools/MapAssembly/CreateEarthNaturalTiles.lua')],check=True)
 exported=temporary/'Export.png';subprocess.run([a.aseprite,'--batch',str(native),'--save-as',str(exported)],check=True)
 sheet=Image.open(exported).convert('RGBA');names=names_file.read_text().splitlines();assert len(names)==87+29*15+31*15+35*17
 description='# BEGIN DMI\nversion = 4.0\n\twidth = 32\n\theight = 32\n'
 for i,name in enumerate(names):
  tile=sheet.crop((i%16*32,i//16*32,(i%16+1)*32,(i//16+1)*32));assert tile.getchannel('A').getextrema()==(255,255)
  description+=f'state = "{name}"\n\tdirs = 1\n\tframes = 1\n'
 info=PngImagePlugin.PngInfo();info.add_text('Description',description+'# END DMI\n',zip=True)
 destination=ROOT/'src/Icons/Turfs/Earth/EarthNaturalTiles.dmi';sheet.save(destination,format='PNG',pnginfo=info);sheet.save(folder/'EarthNaturalTiles.png')
 manifest={'origin':'Original image_gen full-square materials; native Aseprite modular terrain. No monolithic objects.','tileSize':[32,32],'sourceHash':hashlib.sha256(native.read_bytes()).hexdigest(),'dmiHash':hashlib.sha256(destination.read_bytes()).hexdigest(),'states':names}
 (folder/'EarthNaturalTilesExport.json').write_text(json.dumps(manifest,indent=2)+'\n');print(f'Exported {len(names)} fully opaque 32px states.')
