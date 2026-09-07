# Viltrum generation and export record

Tool: OpenAI built-in `image_gen`, 2026-09-06. No API-key CLI generation was used.

Reference: user-supplied `Imagem do Codex 6 de set. de 2026, 12_28_11.jpg`.
Used only as cyan/teal palette and planetary mood reference.

## Prompt set

1. Original kit: a 4x4 sheet for top-down BYOND, independent 32x32 pixel-art cells,
   ivory stone-metal, teal/navy and restrained gold. Rows: ground/civic floor/
   road/structural floor; wall/glass/column/closed-door concept; planter/bench/
   banner/memorial; console/reactor/beacon/archive table. No gutters or labels.
   Generated original: `ViltrumGeneratedKit.png`. The closed-door concept is not
   exported because it has no complete animation/logic. Initial wall/furnishing
   treatments were rejected by the user and replaced in the live slice.
2. Architecture correction: four equal 2x2 full-square cells, no underlying floor,
   freestanding block or margins. Wall face: full-tile front masonry elevation;
   roof: full-tile overhead pale structural surface; glass face: full-tile teal
   glass/mullions; dark roof: full-tile navy structural panels. Roofs are the true
   collision/vision-blocking walls; faces are decorative. Generated original:
   `ViltrumEnvelopeOriginal.png`; editable source: `ViltrumEnvelope.aseprite`.
3. Furnishings correction: eight independent sprites in a 4x2 sheet, preserving
   the initial kit's forms: planter, bench, banner, memorial, console, reactor,
   beacon and archive table. Request actual alpha backgrounds, no floors,
   ground shadows or painted checkerboard. Keep integral legs, plinths and
   containers; cool offwhite/teal/navy/gold and crisp 32px export geometry.
4. Transparency retry: remove the checkerboard from the eight-object sheet,
   including gaps underneath furniture; preserve objects and cell positions;
   explicitly request an RGBA PNG with alpha=0 background. Both model outputs
   were nevertheless RGB and were rejected as transparent deliverables.

## Technical normalization

The fourth output was converted to true alpha using
`tools/MapAssembly/NormalizeViltrumCutouts.py`: flood-fill only bright neutral
background connected to known cell-margin seeds. Dark object outlines protect
ivory surfaces. Cells are cropped and resized by nearest-neighbor into an
editable native Aseprite sheet. The first incorrect seed attempt is preserved
under `Rejected`; it is not used by runtime assets.

Current source: `ViltrumObjects.aseprite`. The normalized pre-import original is
`ViltrumObjectsOriginal.png`. Export checks require alpha minima 0 and maxima 255
in all eight 32x32 states, plus transparent background area. Runtime smoke checks
a table frame's transparent corner and preserves its underlying floor. The proof
image renders each object on civic, teal ground and structural flooring.

`ViltrumRevision.json` records authoritative current Aseprite hashes, state names,
source cell indexes and DMI destinations. Both revision scripts refuse replacing
existing source documents during initialization. Subsequent exports read them.

Sources remain editable raster layers, not vector originals or layered manual
pixel paintings. Earlier concept sheets retain their original backgrounds for
provenance; they are not the furnishing sprites currently placed in the map.
