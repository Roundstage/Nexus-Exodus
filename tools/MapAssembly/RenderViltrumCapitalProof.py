"""Display exported furnishing alpha over three production floors."""
from pathlib import Path
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parents[2]
objects=Image.open(ROOT/'src/Icons/Turfs/Viltrum/ViltrumCapitalObjects.dmi').convert('RGBA')
floors=Image.open(ROOT/'src/Icons/Turfs/Viltrum/ViltrumFloors.dmi').convert('RGBA')
ground=Image.open(ROOT/'src/Icons/Turfs/Viltrum/ViltrumGround.dmi').convert('RGBA')
canvas=Image.new('RGB',(800,340),'#122c38');draw=ImageDraw.Draw(canvas)
draw.text((12,12),'VILTRUM | CAPITAL FURNISHINGS | ACTUAL 32x32 EXPORTS',fill='#e5f5f5')
for index,label in enumerate(['BED','MEDICAL','LOCKER','CARGO','THRONE','CANTEEN','WORKBENCH','COMMS']):draw.text((12+index*98,42),label,fill='#a7d8dd')
for row,back in enumerate([floors.crop((0,0,32,32)),ground.crop((0,0,32,32)),floors.crop((64,0,96,32))]):
 for index in range(8):
  patch=Image.new('RGBA',(64,64))
  for x in [0,32]:
   for y in [0,32]:patch.paste(back,(x,y))
  tile=objects.crop((index*32,0,index*32+32,32));patch.alpha_composite(tile,(16,16));canvas.paste(patch,(12+index*98,62+row*84))
draw.text((12,320),'Transparent objects; independent floors; no active lights or per-object processing.',fill='#a7d8dd')
canvas.resize((1600,680),Image.Resampling.NEAREST).save(ROOT/'docs/Maps/ViltrumCapitalMaterialProof.png')
