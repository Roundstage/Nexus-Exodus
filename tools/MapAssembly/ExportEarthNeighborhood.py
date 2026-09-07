"""Normalize original transparent atlases through editable Aseprite into DMIs.

Only atlas slicing, nearest-neighbor sizing and DMI packaging happen here.
No chroma key: sources must already have a genuine transparent background.
"""
import argparse, hashlib, json, subprocess, tempfile
from pathlib import Path
from PIL import Image, PngImagePlugin

ROOT = Path(__file__).resolve().parents[2]
SETS = {
    'Houses': (160, 192, ['cream', 'sage', 'brick', 'blue']),
    'Services': (224, 192, ['hospital', 'shop', 'civic', 'garage']),
    'Props': (64, 96, ['tree', 'bench', 'lamp', 'car']),
}
parser = argparse.ArgumentParser()
parser.add_argument('kind', choices=SETS)
parser.add_argument('--initialize', type=Path)
parser.add_argument('--aseprite', required=True)
args = parser.parse_args()
width, height, names = SETS[args.kind]
folder = ROOT / 'ArtSource/Earth'
stem = f'EarthNeighborhood{args.kind}'
native = folder / f'{stem}.aseprite'
destination = ROOT / f'src/Icons/Turfs/Earth/{stem}.dmi'

with tempfile.TemporaryDirectory(prefix='EarthNeighborhood-') as temporary:
    temporary = Path(temporary)
    if args.initialize:
        assert not native.exists(), 'Native source exists: edit it, do not reinitialize.'
        original = folder / f'{stem}Original.png'
        assert not original.exists() or original.read_bytes() == args.initialize.read_bytes(), 'Different original already retained.'
        source = Image.open(args.initialize).convert('RGBA')
        low, high = source.getchannel('A').getextrema()
        assert low == 0 and high >= 240, 'Requires real alpha; no color-key substitutes.'
        original.write_bytes(args.initialize.read_bytes())
        alpha = source.getchannel('A').point(lambda a: 255 if a >= 128 else 0)
        split_x = min(range(source.width * 45 // 100, source.width * 55 // 100),
                      key=lambda x: sum(alpha.crop((x, 0, x + 1, source.height)).tobytes()))
        split_y = min(range(source.height * 45 // 100, source.height * 55 // 100),
                      key=lambda y: sum(alpha.crop((0, y, source.width, y + 1)).tobytes()))
        xs, ys = [0, split_x, source.width], [0, split_y, source.height]
        sheet = Image.new('RGBA', (width * len(names), height))
        for i, name in enumerate(names):
            col, row = i % 2, i // 2
            tile = source.crop((xs[col], ys[row], xs[col + 1], ys[row + 1]))
            # Ignore near-transparent antialias fringes when finding cell bounds.
            tile.putalpha(tile.getchannel('A').point(lambda alpha: 255 if alpha >= 128 else 0))
            bounds = tile.getbbox()
            assert bounds and bounds[0] > 0 and bounds[1] > 0, f'Atlas gutter missing: {name}'
            target = {'tree': (64,96), 'bench': (64,32), 'lamp': (32,64), 'car': (64,96)}.get(name, (width,height))
            tile = tile.crop(bounds).resize(target, Image.Resampling.NEAREST)
            sheet.paste(tile, (i * width + (width-target[0])//2, height-target[1]))
        incoming = temporary / 'Import.png'
        sheet.save(incoming)
        subprocess.run([args.aseprite, '--batch', str(incoming), '--save-as', str(native)], check=True)
    exported = temporary / 'Export.png'
    subprocess.run([args.aseprite, '--batch', str(native), '--save-as', str(exported)], check=True)
    sheet = Image.open(exported).convert('RGBA')
    assert sheet.size == (width * len(names), height)
    description = f'# BEGIN DMI\nversion = 4.0\n\twidth = {width}\n\theight = {height}\n'
    states = []
    for i, name in enumerate(names):
        tile = sheet.crop((i * width, 0, (i + 1) * width, height))
        assert set(tile.getchannel('A').tobytes()) == {0, 255}
        assert all(tile.getpixel(p)[3] == 0 for p in [(0, 0), (width - 1, 0)])
        # Pink window-box flowers are valid; a key-colored backdrop is not.
        assert sum(bool(r > 150 and b > 150 and g < 100 and a) for r, g, b, a in tile.get_flattened_data()) < width * height * .005, 'Visible magenta backdrop'
        description += f'state = "{name}"\n\tdirs = 1\n\tframes = 1\n'
        states.append({'state': name, 'cellSize': [width, height], 'footprint': [width // 32, height // 32],
                       'dmi': destination.relative_to(ROOT).as_posix(), 'source': native.relative_to(ROOT).as_posix(),
                       'sourceCell': i, 'dirs': 1, 'frames': 1, 'transparent': True})
    metadata = PngImagePlugin.PngInfo()
    metadata.add_text('Description', description + '# END DMI\n', zip=True)
    sheet.save(destination, format='PNG', pnginfo=metadata)
    sheet.save(folder / f'{stem}.png')
    report = {'origin': 'Original built-in OpenAI image_gen atlas; transparent source retained.',
              'sourceHashes': {native.relative_to(ROOT).as_posix(): hashlib.sha256(native.read_bytes()).hexdigest()},
              'states': states}
    (folder / f'{stem}Export.json').write_text(json.dumps(report, indent=2) + '\n')
    print(f'{stem}: {len(names)} states, {width}x{height}, native source, binary alpha, no magenta.')
