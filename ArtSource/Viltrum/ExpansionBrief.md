
## Capital and wilderness source additions — 2026-09-06

Original art generated with the built-in OpenAI image_gen tool, no upstream art
imports. The capital sheet is stored as `ViltrumCapitalGenerated.png`; its RGB
background was normalized to real binary alpha before native Aseprite import.
The full original landscape sheet is `ViltrumLandscapeOriginal.png`. Native
sources and individual state definitions are authoritative in
`ViltrumCapitalExport.json` and `ViltrumLandscapeExport.json`.

Prompt set:
1. Eight isolated pixel-art furnishings in a 4x2 grid: ivory/teal bed, medical bed,
navy locker, freight crate, imperial throne, serving counter, workbench and
communications mast. Crisp 32x32-compatible RPG perspective, transparent perimeter,
no floor, sparse gold, navy outlines, no text.
2. Background extraction preserving the eight designs and grid; remove dark painted
background and glow; actual alpha requested, uniform white fallback supplied.
Technical flood-fill removes only bright neutral background connected to cell
corners, preserving outlined ivory surfaces. Final DMI alpha is exactly 0 or 255.
3. Sixteen touching full-square opaque terrain textures in a 4x4 grid, north-up,
quiet 32x32 pixel-art: deep sea, shallow sea, pale shore, plateau, snow, ice,
crater, garden, palace floor, laboratory floor, grate, arena floor, rough stone,
ruined masonry, cyan stone and storm sea. Cold cyan/teal/navy/ivory palette,
no labels, gutters, freestanding props or perspective.

Commands: `ExportViltrumCapital.py` and `ExportViltrumTerrain.py` with
`--aseprite <Aseprite.exe>`. `--initialize` is only accepted for missing sources.
Exports audit dimensions, source hashes, DMI metadata and alpha. The native files
can be edited without rerunning map layout tools; regenerate their DMI exports
and assemble chunks separately. No source can be replaced with --force.

## Animated doors

ViltrumDoorsOriginal.png is original built-in OpenAI image_gen output.
Prompt brief: a precise four-column/five-row sheet of 32x32-compatible top-down
pixel-art sci-fi door panels; each row is civic ivory/teal, palace ivory/gold,
laboratory cyan/navy, industrial hangar or restrained cyan force field.
Columns show closed, half-opening, fully open and half-closing. Keep framing
consistent, open aperture genuinely transparent, no floor/background, text,
perspective or glow fringe. Use the approved cold Viltrum palette.

Equal cells were cropped, nearest-neighbor resized and alpha thresholded to
0/255 before import into ViltrumDoors.aseprite. ExportViltrumDoors.py maps closed
and open to one frame, opening and closing to two frames (1.5 ticks each, loop=1).
The twenty states contain thirty frames; ViltrumDoorExport.json records exact
pose indices and source hash. Open centers must be transparent and closed centers
opaque. The DM code changes collision after the three-tick transition and defers
closing while occupied.
