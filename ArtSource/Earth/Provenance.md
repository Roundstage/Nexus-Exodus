# Earth sources — 2026-09-06

EarthCityAdditions.aseprite curates 28 first-frame states from assets already in
Nexus Exodus. EarthCityExport.json records each original path, source SHA-256,
selected icon state/cell, output state and native-source hash. Sources include
Celianna architecture, FloorsLAWL, Tiles1212011, existing furniture and lab props.
Existing artwork retains its original authorship and applicable project credits;
this packaging does not grant a new public license or claim original authorship.
No ClassicBlunder asset or type hierarchy was imported.

Legacy binary DMI furniture was converted in an isolated headless BYOND helper:
icon construction plus a white ICON_MULTIPLY identity operation forces modern
PNG encoding, preserving pixels and transparency. Original repo assets are
read-only. PreviewEarthAssets.py creates the contact-sheet inventory. Selected
south frames are packed as independent 32x32 states with binary alpha for objects.
Rejected/EarthCityFirstImport.aseprite preserves the rejected opaque furniture
selection; it is not the production source.

EarthStreetAdditions.aseprite contains four original OpenAI built-in image_gen
materials. EarthStreetsOriginal.png retains the generated sheet.
Prompt brief: four touching full-square opaque top-down pixel-art road surfaces,
quiet neutral asphalt without metal ridges, zebra crosswalk, concrete sidewalk,
industrial concrete; 2x2 grid, no perspective, props, text, gutters or transparency,
32x32-compatible detail and a muted modern Earth palette. Equal cells were cropped
and nearest-neighbor resized, imported into native Aseprite and exported with DMI
metadata. Road and Sidewalk use this sheet; two additional states are available
for later mapping.

Export commands:
- ExportEarthCityKit.py --aseprite <Aseprite.exe>
- ExportEarthStreets.py --aseprite <Aseprite.exe>
- AuditPlanetAssets.py

Exporters read the native documents. Initialization refuses existing sources.
EarthCity.dmi and EarthStreets.dmi under src/Icons/Turfs/Earth are production
artifacts. The manifests document exact mappings, metadata and hashes.

## Ordinary city houses and river revision

EarthNeighborhoodHouses, EarthNeighborhoodServices and EarthNeighborhoodProps
are original built-in OpenAI image_gen cutout atlases made on 2026-09-06. Final
generated originals, normalized PNGs, native Aseprite documents and export
manifests share those stems in this directory. EarthNeighborhoodPrompts.json
contains all generation and background-extraction prompts. The service and prop
atlases required a second image_gen edit to obtain actual alpha. Normalization
thresholds alpha at 128, crops each separated silhouette and resizes with nearest
neighbor sampling. No external art pack was imported or copied into these assets.

Houses export four 160x192 states (cream, sage, brick, blue); services export four
224x192 states (hospital, shop, civic, garage). Props use 64x96 cells with a tree,
bench, lamp and car at their own bottom-aligned visible sizes. The car is available
in the kit but is not placed in this map revision. Furniture remains transparent.
Artist/reference pack pages are recorded in docs/Maps/CityDesignReferences.md as
visual research, not as imported production artwork or a license claim.

EarthNeighborhoodDetails.aseprite is original precision pixel work authored
through Aseprite's native Lua API: 22 road, sidewalk, curb, threshold, planting
and bridge states. ReviseEarthBridgeDetails.lua updates only the four parapet
states in that native source. It does not redraw the generated building art.

EarthRiverMaterialsOriginal.png is an original built-in image_gen atlas of four
water, meadow, bank soil and rock materials. The normalized 128x32 materials and
EarthRiverMaterials.aseprite are retained. CreateEarthRiverTerrain.lua uses these
swatches inside native Aseprite to build 512 water/bank states from eight-neighbor
masks, plus waterfall, terrain steps and rock lip. EarthRiverTerrain.aseprite is
the exported native source; the manifest records each of its 515 states.

EarthBuildingTiles.dmi is a lossless packaging derivative of the exported house
and service art: 288 individual 32x32 crops, with southwest-up coordinate names.
Each solid structural turf can display its own pixels when sight blocking hides
the full building object's anchor. This derivative is not a separately painted
source. The asset audit compares every crop byte-for-byte with its source frame.

Production files are under src/Icons/Turfs/Earth. Re-export native documents with:

- ExportEarthNeighborhood.py Houses|Services|Props --aseprite <Aseprite.exe>
- ExportEarthStreetDetails.py --aseprite <Aseprite.exe>
- ExportEarthRiverTerrain.py --aseprite <Aseprite.exe>
- ExportEarthBuildingTiles.py
- AuditEarthNeighborhoodAssets.py

All commands are under tools/MapAssembly. Initialization guards refuse replacing
an existing native source. Edit native documents, export, then audit; retain the
generated originals and prompts. Preview rendering reads the production DMI
pixels and does not modify production artwork.

EarthNaturalMaterialsOriginal.png is the original generated full-square terrain
material atlas. EarthNaturalPrompts.json retains the exact built-in prompt.
EarthNaturalMaterials.aseprite and EarthNaturalTiles.aseprite are editable native
sources. The latter supplies 87 reusable terrain/arch states and 1,495 unique
32px dune cells whose edges match the retained Turf1.dmi `light desert` terrain.
EarthNaturalBaseGround.png is a lossless extraction of that existing game tile.
The initial whole-mountain concepts were discarded when the user clarified
that players must climb and explore real terrain tiles.

Use ExportEarthNaturalTiles.py --aseprite <path> for ordinary native exports.
--refine deliberately rebuilds the native tile layout from the retained
materials using CreateEarthNaturalTiles.lua; preserve hand-painted edits before
using it. AuditEarthNaturalAssets.py verifies native hashes, pixel coverage and
every mapped explicit state. Landforms use no monolithic sprite objects.
