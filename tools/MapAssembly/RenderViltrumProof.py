"""Show full-block repeats and prove that every furnishing preserves its floor."""
from pathlib import Path
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parents[2]
objects=Image.open(ROOT/'src/Icons/Turfs/Viltrum/ViltrumObjects.dmi').convert('RGBA')
walls=Image.open(ROOT/'src/Icons/Turfs/Viltrum/ViltrumEnvelope.dmi').convert('RGBA')
floors=Image.open(ROOT/'src/Icons/Turfs/Viltrum/ViltrumFloors.dmi').convert('RGBA')
ground=Image.open(ROOT/'src/Icons/Turfs/Viltrum/ViltrumGround.dmi').convert('RGBA')
canvas=Image.new('RGB',(640,440),'#122c38');draw=ImageDraw.Draw(canvas)
draw.text((10,8),'VILTRUM | FULL-BLOCK ARCHITECTURE',fill='#e5f5f5')
for index,label in enumerate(['WALL FACE','SOLID ROOF','GLASS FACE','DARK ROOF']):
 tile=walls.crop((index*32,0,index*32+32,32));x=10+index*156
 draw.text((x,26),label,fill='#a7d8dd')
 for y in range(2):
  for col in range(4):canvas.paste(tile,(x+col*32,42+y*32))
draw.text((10,126),'SAME TRANSPARENT OBJECTS OVER THREE DIFFERENT FLOORS',fill='#e5f5f5')
names=['PLANTER','BENCH','BANNER','MEMORIAL','CONSOLE','REACTOR','BEACON','TABLE']
for index,name in enumerate(names):draw.text((10+index*79,146),name,fill='#a7d8dd')
backs=[floors.crop((0,0,32,32)),ground.crop((0,0,32,32)),floors.crop((64,0,96,32))]
for row,back in enumerate(backs):
 for index in range(8):
  obj=objects.crop((index*32,0,index*32+32,32))
  assert obj.getchannel('A').getextrema()==(0,255)
  patch=Image.new('RGBA',(64,64))
  for x in [0,32]:
   for y in [0,32]:patch.paste(back,(x,y))
  patch.alpha_composite(obj,(16,16));canvas.paste(patch,(10+index*79,164+row*80))
draw.text((10,416),'Roofs: collision + opacity. Walls: decorative. Objects: true alpha.',fill='#a7d8dd')
canvas.resize((1280,880),Image.Resampling.NEAREST).save(ROOT/'docs/Maps/ViltrumMaterialProof.png')
