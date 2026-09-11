"""Build deterministic HUD glyph sprites from the project's OFL Silkscreen font."""
import argparse
import io
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, PngImagePlugin

ROOT = Path(__file__).resolve().parents[1]
FONT = ROOT / "src/Fonts/SilkscreenRegular.ttf"
ATLAS = ROOT / "src/Icons/UI/NexusHudGlyphs.dmi"
METRICS = ROOT / "src/Fonts/NexusHudGlyphs.json"
SIZES = (8, 12, 16)
CHARS = list(range(32, 127)) + list(range(160, 256))
CELL = 24


def generate():
    atlas = Image.new("RGBA", (CELL * 16, CELL * ((len(CHARS) * len(SIZES) + 15) // 16)))
    metrics = {"source": "SilkscreenRegular.ttf", "license": "SilkscreenOFL.txt", "sizes": {}}
    description = ["# BEGIN DMI", "version = 4.0", f"\twidth = {CELL}", f"\theight = {CELL}"]
    index = 0
    for size in SIZES:
        font = ImageFont.truetype(str(FONT), size)
        top = min(font.getbbox(chr(code))[1] for code in CHARS)
        bottom = max(font.getbbox(chr(code))[3] for code in CHARS)
        height = bottom - top
        info = metrics["sizes"][str(size)] = {"height": height, "advances": {}, "bounds": {}}
        for code in CHARS:
            char = chr(code)
            mask = Image.new("L", (CELL, CELL))
            ImageDraw.Draw(mask).text((0, CELL - height - top), char, font=font, fill=255)
            # Preserve solid pixel edges; never rescale a finished word or HUD group.
            mask = mask.point(lambda value: 255 if value >= 128 else 0)
            glyph = Image.new("RGBA", (CELL, CELL), "white")
            glyph.putalpha(mask)
            bbox = mask.getbbox()
            advance = max(1, round(font.getlength(char)), bbox[2] if bbox else 0)
            info["advances"][str(code)] = advance
            info["bounds"][str(code)] = [bbox[1] - CELL + height, bbox[3] - CELL + height] if bbox else None
            atlas.paste(glyph, ((index % 16) * CELL, (index // 16) * CELL))
            description.extend([f'state = "{size}-{code}"', "\tdirs = 1", "\tframes = 1"])
            index += 1
    description.append("# END DMI")
    png_info = PngImagePlugin.PngInfo()
    png_info.add_text("Description", "\n".join(description), zip=True)
    output = io.BytesIO()
    atlas.save(output, format="PNG", pnginfo=png_info)
    return atlas, metrics, output.getvalue()


def text_width(text, size, metrics):
    widths = metrics["sizes"][str(size)]["advances"]
    return sum(widths.get(str(ord(char)), widths["63"]) for char in text)


def draw_text(atlas, metrics, text, size, width, height, color="#eee3cf", align="left"):
    """Same integer glyph placement as HudBitmapText.dm; no HTML renderer involved."""
    info = metrics["sizes"][str(size)]
    bounds = [info["bounds"].get(str(ord(char)), info["bounds"]["63"]) for char in text]
    top = min(b[0] for b in bounds if b)
    bottom = max(b[1] for b in bounds if b)
    ink_height = bottom - top
    assert ink_height + 1 <= height, (text, size, height)
    assert text_width(text, size, metrics) + 1 <= width, (text, size, width)
    image = Image.new("RGBA", (width, height))
    text_length = text_width(text, size, metrics) + 1
    x = (width - text_length) // 2 if align == "center" else width - text_length if align == "right" else 0
    y = (height - ink_height - 1) // 2
    for char in text:
        code = ord(char) if ord(char) in CHARS else 63
        index = SIZES.index(size) * len(CHARS) + CHARS.index(code)
        cell_x, cell_y = index % 16 * CELL, index // 16 * CELL
        glyph = atlas.crop((cell_x, cell_y + CELL - info["height"] + top, cell_x + CELL, cell_y + CELL - info["height"] + bottom))
        shadow = Image.new("RGBA", glyph.size, "#080706")
        shadow.putalpha(glyph.getchannel("A"))
        colored = Image.new("RGBA", glyph.size, color)
        colored.putalpha(glyph.getchannel("A"))
        image.alpha_composite(shadow, (x + 1, y + 1))
        image.alpha_composite(colored, (x, y))
        x += info["advances"][str(code)]
    return image


def verify(atlas, metrics):
    for size in SIZES:
        for code in CHARS:
            if code in (32, 160, 173):
                continue
            index = SIZES.index(size) * len(CHARS) + CHARS.index(code)
            glyph = atlas.crop((index % 16 * CELL, index // 16 * CELL, index % 16 * CELL + CELL, index // 16 * CELL + CELL))
            assert glyph.getchannel("A").getbbox(), (size, code)
    cases = [("BUILD CATALOG", 12, 176, 22), ("SCIENCE", 12, 60, 16),
             ("EDGES ON", 12, 94, 16), ("(8000) 100%", 12, 96, 18),
             ("(8000) 100%", 8, 63, 12), ("ÁGUA <A> & B", 12, 130, 18)]
    for text, size, width, height in cases:
        rendered = draw_text(atlas, metrics, text, size, width, height)
        assert rendered.getchannel("A").getbbox(), text
    print(f"HUD font: {len(CHARS) * len(SIZES)} glyphs, measured labels, energy and Latin text passed")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    atlas, metrics, png = generate()
    verify(atlas, metrics)
    metrics_text = json.dumps(metrics, separators=(",", ":")) + "\n"
    if args.check:
        existing = Image.open(ATLAS)
        assert existing.tobytes() == atlas.tobytes() and existing.info["Description"] == Image.open(io.BytesIO(png)).info["Description"], "Stale HUD glyph atlas"
        assert METRICS.read_text(encoding="utf-8") == metrics_text, "Stale HUD glyph metrics"
    else:
        ATLAS.write_bytes(png)
        METRICS.write_text(metrics_text, encoding="utf-8")


if __name__ == "__main__":
    main()
