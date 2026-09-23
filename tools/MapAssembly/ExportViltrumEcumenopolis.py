"""Package original transparent art through editable Aseprite and tiled DMIs.

Initialization only crops alpha bounds and samples to the declared tile grid;
subsequent exports read the native source, preserving manual art edits.
"""
import argparse, hashlib, json, subprocess, tempfile
from pathlib import Path
from PIL import Image, PngImagePlugin

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / 'ArtSource/Viltrum/Ecumenopolis'
OUT = ROOT / 'src/Icons/Turfs/Viltrum'
SETS = {'Residence': (160,192), 'ResidenceB': (160,192),
        'Hospital': (224,192), 'Science': (224,192),
        'Transit': (224,192), 'Civic': (256,320)}
parser = argparse.ArgumentParser()
parser.add_argument('--aseprite', required=True)
parser.add_argument('--initialize', action='store_true')
args = parser.parse_args()

def package(frames, size, destination):
    w,h=size; cols=min(16,len(frames)) if w==32 else len(frames)
    sheet=Image.new('RGBA',(cols*w,((len(frames)+cols-1)//cols)*h))
    description=f'# BEGIN DMI\nversion = 4.0\n\twidth = {w}\n\theight = {h}\n'
    for i,(name,frame) in enumerate(frames):
        assert frame.size==size
        sheet.paste(frame,(i%cols*w,i//cols*h))
        description+=f'state = "{name}"\n\tdirs = 1\n\tframes = 1\n'
    info=PngImagePlugin.PngInfo()
    info.add_text('Description',description+'# END DMI\n',zip=True)
    sheet.save(destination,format='PNG',pnginfo=info)

states=[]; cells=[]; sources={}
with tempfile.TemporaryDirectory(prefix='ViltrumEcumenopolis-') as temporary:
    temporary=Path(temporary)
    for name,size in SETS.items():
        original=ART/'Generated'/f'{name}.png'
        native=ART/f'{name}.aseprite'
        if not native.exists():
            if not args.initialize or not original.exists(): continue
            image=Image.open(original).convert('RGBA')
            assert image.getchannel('A').getextrema()==(0,255),f'No real alpha: {name}'
            # Crisp pixel-art alpha, matching the existing neighborhood pipeline.
            image.putalpha(image.getchannel('A').point(lambda a:255 if a>=128 else 0))
            image=image.crop(image.getbbox()).resize(size,Image.Resampling.NEAREST)
            incoming=temporary/f'{name}.png';image.save(incoming)
            subprocess.run([args.aseprite,'--batch',str(incoming),'--save-as',str(native)],check=True)
        exported=temporary/f'{name}Export.png'
        subprocess.run([args.aseprite,'--batch',str(native),'--save-as',str(exported)],check=True)
        image=Image.open(exported).convert('RGBA');assert image.size==size
        assert set(image.getchannel('A').tobytes())=={0,255}
        state=name.lower();destination=OUT/f'ViltrumCity{name}.dmi'
        package([(state,image)],size,destination)
        image.save(ART/f'{name}.png')
        sources[native.relative_to(ROOT).as_posix()]=hashlib.sha256(native.read_bytes()).hexdigest()
        states.append({'type':'/obj/ViltrumCityHouse'+('' if name=='Residence' else '/'+name),
                       'state':state,'cellSize':size,'footprint':[size[0]//32,size[1]//32],
                       'dmi':destination.relative_to(ROOT).as_posix(),
                       'source':native.relative_to(ROOT).as_posix()})
        w,h=size
        for y in range(h//32):
            for x in range(w//32):
                cells.append((f'{state}_{x}_{y}',image.crop((x*32,h-(y+1)*32,(x+1)*32,h-y*32))))
    if cells: package(cells,(32,32),OUT/'ViltrumCityStructures.dmi')
    street_native=ART/'Streets.aseprite'
    if street_native.exists():
        exported=temporary/'Streets.png'
        subprocess.run([args.aseprite,'--batch',str(street_native),'--save-as',str(exported)],check=True)
        sheet=Image.open(exported).convert('RGBA')
        names=json.loads((ART/'StreetStates.json').read_text())
        package([(name,sheet.crop((i*32,0,(i+1)*32,32))) for i,name in enumerate(names)],(32,32),OUT/'ViltrumCityStreets.dmi')
        sources[street_native.relative_to(ROOT).as_posix()]=hashlib.sha256(street_native.read_bytes()).hexdigest()
        sheet.save(ART/'Streets.png')
report={'origin':'Original built-in image_gen assets; alpha-bound crop and nearest-neighbor tile sizing; editable Aseprite sources are authoritative.',
        'sourceHashes':sources,'states':states,'structuralStates':[name for name,_ in cells]}
(ART/'Export.json').write_text(json.dumps(report,indent=2)+'\n')
print(f'{len(states)} buildings; {len(cells)} lossless structural crops exported.')
