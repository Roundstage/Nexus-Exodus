# Earth natural landmarks — 6 September 2026

The western city remains Earth's only city. Nine remaining remote buildings and their local dirt approaches were removed; their interiors were retired without moving the 66 retained Earth/Viltrum rooms. All 72 old terrain stair tiles were removed. No whole-mountain, dune or waterfall objects are placed.

| Place | Surface location (Z21) | Exploration |
| --- | --- | --- |
| Sandstone massif | Around 132,124 | Three irregular terraces connected by natural scree ramps. Approach from 107,124 and walk around the terraces to reach the summit. |
| Whispering Sandstone Cave | Entrance 132,106 | A natural arch leads into a separate, irregular cavern at Z22. Three connected chambers contain 243 floor tiles; the exit returns to 132,105. |
| Arctic mountain | Around 281,444 | Three snowy terraces with exposed glacial rock. A southern approach at 281,425 connects to the upper paths. |
| Forest waterfall | Around 368,342 | Walkable mossy shelves on both banks, a three-tile falling curtain and downstream foam over the retained plunge pool. The original river remains continuous. |
| Desert dune field | Around 108,94; 111,76; 158,68 | Three crescent ridges share a wind direction. All 1,495 terrain cells are walkable, with continuous shading and edges matching the original sand. |

Every formation is authored as 32×32 turfs. `EarthNaturalGround` carries walkable terrace/ramp tiles and an authored `terrain_height`. `EarthNaturalRoof` supplies dense, opaque, non-flyable rock structure. Elevation is represented by traversable terraces and blocking faces on the surface Z level; this does not add a general vertical climbing physics system. Cave entrances are invisible transfer triggers over visible cave-mouth turfs, following the separate-interior choice.

The 61 approved city exteriors, 29 accessible city buildings, all 20 current spawn atoms/coordinates, 441 arrival tiles and both local asphalt bridges remain. 23,508 city cells are exact semantic matches to the preceding map; the only city changes are the 24 explicitly rejected stair tiles. All 4,200 checked river-union tiles outside the city remain wet, and the three source lakes reach the ocean. There are no intercontinental roads or wilderness asphalt grids.

## Artwork and sources

[Research and design references](EarthNaturalLandmarksReferences.md) summarize primary geology sources and official RPG Maker mapping guidance. The initial whole-formation concepts were abandoned after the user's clarification that terrain must be explorable tiles.

The production source is `ArtSource/Earth/EarthNaturalTiles.aseprite`, with 1,582 fully opaque 32px states: 87 reusable terrain/arch states and 1,495 cells forming continuous dune surfaces. `EarthNaturalMaterialsOriginal.png` and the normalized native material sheet preserve the original image generation. The original game's `Turf1.dmi:light desert` backs the dune edges so they match the existing desert. Prompts and provenance are retained in ArtSource/Earth.

## Validation and authoring

- `node tools/MapAssembly/TestEarthNaturalLandmarks.cjs`: all 1,759 recorded walkable mountain/ledge tiles and all terrace levels are reachable; 152 ramp tiles, 243 connected cave tiles, city preservation, river connectivity, spawns and road restrictions pass.
- `node tools/MapAssembly/CityBuildingChecks.cjs`: all 66 retained building interiors remain connected with exact return doors and furniture.
- `node tools/MapAssembly/TestPlanetChunks.cjs SuperEarth`: parser, chunk membership, DME types, reproducible assembly and manual-output protection.
- `python tools/MapAssembly/AuditEarthNaturalAssets.py`: native export hash, exact pixels, real 32px dimensions, opaque coverage and mapped icon states.
- `tools/Invoke-ByondSmoke.ps1`: compiles and exercises actual walking up each landmark, cave entry/return, planet context and solid rock behavior. See latest smoke result recorded below.

`AuthorEarthNaturalLandmarks.cjs` previews before `--apply`, preserves a complete snapshot under `RebuildBaseline/BeforeEarthNaturalLandmarks`, and refuses unrecorded output/interior/registry edits. The old wilderness generator is retired. Source chunks remain the authoring source; `DU.dme` includes the assembled runtime maps once.

Native DMI previews are under [EarthNeighborhoodPreview](EarthNeighborhoodPreview). StrongDMM and interactive gameplay/lighting review remain deferred per the user's instruction; these images do not certify engine lighting or occlusion.

Applied surface SHA256: `79d64ee0c0f4c47ba38d84946e4ae1a8dd33101056a9ef8797c6232392b6dd41`.

Final validation: BYOND 516.1686 compiled with zero errors/warnings; versioned and
clean startup tests passed (7:07 pm local build). All map and natural-asset checks
passed. The global strict asset-reference audit has zero missing, ambiguous or
case issues, but still reports the pre-existing UIStuff.dm:91 browser resource
alias `NexusExodusLogo.png` as BarePath. Naming path checks passed; legacy
identifier migration findings are unchanged in scope.
