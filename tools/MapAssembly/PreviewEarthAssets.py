"""Read-only contact sheet for a small curated set of existing repository assets."""
from pathlib import Path
import re,sys
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parents[2]
groups={
 'src/Icons/Turfs/Celianna/TileA3.dmi':['RedRoof3','BlackRoof3','BlueRoof3','PlainWall3','WoodenWall3','RedBrickWall3'],
 'src/Icons/Turfs/FloorsLAWL.dmi':['Wood Medium','Tile','Flagstone Grey','Flagstone Brown','Marble','Gravel Dark'],
 'src/Icons/Turfs/Tiles1212011.dmi':['west city tile','metal floor','Metal Roof','Metal Grate'],
 'src/Icons/Objects/Technology/Lab.dmi':['chair','Stove','sink','Cabnit','Books','Files','Bed','BedTop','computer','bar','Tool2','Tool1'],
 'src/Icons/Turfs/Turfs96.dmi':['Table1','pot','bush','sway/bridge']
}
if '--domestic' in sys.argv:
 groups={'.codex-tmp/EarthAssetAudit/Furnature.dmi':[str(i) for i in range(2,79)],'.codex-tmp/EarthAssetAudit/Roomobj.dmi':['bed top','bed','flowers','flowers2','firewood']}
items=[]
for filename,wanted in groups.items():
 im=Image.open(ROOT/filename).convert('RGBA');metadata=Image.open(ROOT/filename).info['Description'];width=re.search(r'width\s*=\s*(\d+)',metadata);height=re.search(r'height\s*=\s*(\d+)',metadata);w=int(width[1]) if width else 32;h=int(height[1]) if height else 32;index=0
 for match in re.finditer(r'state = "([^"]*)"(.*?)(?=state = |# END DMI|\Z)',metadata,re.S):
  if match[1] in wanted:
   cols=im.width//w;tile=im.crop(((index%cols)*w,(index//cols)*h,(index%cols+1)*w,(index//cols+1)*h));items.append((match[1],tile))
  dirs=re.search(r'dirs = (\d+)',match[2]);frames=re.search(r'frames = (\d+)',match[2]);index+=(int(dirs[1]) if dirs else 1)*(int(frames[1]) if frames else 1)
canvas=Image.new('RGB',(960,((len(items)+7)//8)*125),'#44505c');draw=ImageDraw.Draw(canvas)
for i,(name,tile) in enumerate(items):
 x=i%8*120;y=i//8*125;draw.text((x+3,y+3),name,fill='white');tile=tile.resize((96,96),Image.Resampling.NEAREST);canvas.paste(tile,(x+4,y+22),tile)
canvas.save(ROOT/('docs/Maps/EarthDomesticAssetCandidates.png' if '--domestic' in sys.argv else 'docs/Maps/EarthExistingAssetCandidates.png'))
