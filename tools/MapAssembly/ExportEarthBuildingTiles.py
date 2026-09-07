"""Lossless DMI retiling of native house/service exports for turf visibility.

Structural turfs carry their own 32x32 crop, so a building stays visible even
when BYOND sight blocking hides its southwest object anchor from the player.
"""
import hashlib,json
from pathlib import Path
from PIL import Image,PngImagePlugin
ROOT=Path(__file__).resolve().parents[2]
cells=[];sources={}
for name in ['Houses','Services']:
 manifest=json.loads((ROOT/f'ArtSource/Earth/EarthNeighborhood{name}Export.json').read_text())
 sources.update(manifest['sourceHashes'])
 for state in manifest['states']:
  sheet=Image.open(ROOT/state['dmi']).convert('RGBA');w,h=state['cellSize'];index=state['sourceCell']
  for y in range(h//32):
   for x in range(w//32):
    frame=sheet.crop((index*w+x*32,h-(y+1)*32,index*w+(x+1)*32,h-y*32))
    cells.append((f'{state["state"]}_{x}_{y}',frame))
sheet=Image.new('RGBA',(512,((len(cells)+15)//16)*32))
description='# BEGIN DMI\nversion = 4.0\n\twidth = 32\n\theight = 32\n'
for i,(name,frame) in enumerate(cells):
 sheet.paste(frame,(i%16*32,i//16*32));description+=f'state = "{name}"\n\tdirs = 1\n\tframes = 1\n'
info=PngImagePlugin.PngInfo();info.add_text('Description',description+'# END DMI\n',zip=True)
destination=ROOT/'src/Icons/Turfs/Earth/EarthBuildingTiles.dmi';sheet.save(destination,format='PNG',pnginfo=info)
(ROOT/'ArtSource/Earth/EarthBuildingTilesExport.json').write_text(json.dumps({'sourceHashes':sources,'dmi':destination.relative_to(ROOT).as_posix(),'states':[name for name,_ in cells],'count':len(cells),'conversion':'Lossless 32x32 crops; pixel colors/alpha unchanged; coordinates southwest-up.'},indent=2)+'\n')
print(f'{len(cells)} structural 32x32 crops from existing native house/service art.')
