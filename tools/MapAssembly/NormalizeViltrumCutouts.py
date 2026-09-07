"""Technical alpha normalization for the generated checkerboard export.

The generator returned RGB twice despite requesting alpha. Remove only bright
neutral background connected to the sheet border; dark outlines protect ivory
object surfaces. The normalized PNG is imported into the editable Aseprite source.
"""
import sys
from pathlib import Path
from PIL import Image,ImageDraw
source=Image.open(sys.argv[1]).convert('RGB')
mask=Image.new('L',source.size)
pixels=list(zip(*[iter(source.tobytes())]*3))
mask.putdata([255 if min(pixel)>=215 and max(pixel)-min(pixel)<=14 else 0 for pixel in pixels])
# Seed known background at the cell corners as well as sheet edges. The image
# service sometimes adds a one-pixel gray frame outside the checkerboard.
for row in range(2):
 for col in range(4):
  point=(round(col*source.width/4)+4,round(row*source.height/2)+4)
  if mask.getpixel(point)==255:ImageDraw.floodfill(mask,point,128)
alpha=mask.point(lambda value:0 if value==128 else 255)
result=source.convert('RGBA');result.putalpha(alpha)
destination=Path(sys.argv[2])
if destination.exists():raise SystemExit('Output exists; refusing replacement.')
result.save(destination)
assert alpha.getextrema()==(0,255)
print('RGBA cutouts normalized; ivory surfaces inside outlines preserved.')
