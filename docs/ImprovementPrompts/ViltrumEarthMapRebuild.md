# Astra execution brief: Viltrum and Earth map rebuild

## Mission

Replace the current procedural 500x500 Viltrum and Super Earth blockouts with
high-quality, playable worlds that are comfortable to edit. The runtime maps may
remain 500x500 and keep their existing Z-level integration, but no mapper should
have to open a 500x500 source map in StrongDMM.

Use a 5x5 grid of 100x100 source chunks. Assemble those chunks deterministically
into the existing `src/Maps/Viltrum.dmm` and `src/Maps/SuperEarth.dmm` outputs.
The chunks, their manifests, and original Aseprite files are the source of truth;
the two 500x500 DMM files are generated artifacts.

Do Viltrum first and use it to prove the pipeline. Do Earth only after Viltrum
passes compile, startup, visual, and gameplay checks.

This is a map and asset project, not a rewrite of combat, movement, saving,
planetary control, or the map scanner.

## Product direction

### Viltrum

The supplied planet reference establishes the macro identity: a cold cyan and
teal world, pale water/atmosphere, darker teal landmasses, scattered islands,
and a clean silhouette visible from space. Treat it as a mood and geography
reference, not as a literal tile-for-pixel projection.

Viltrum should feel older and more advanced than Earth at the same time:
monumental, durable, ordered, spacious, and intimidating. It is not a neon
cyberpunk city and not a dirty human industrial city. Favor:

- axial city planning and strong symmetry around imperial buildings;
- pale stone-metal, dark structural metal, teal glass, restrained cyan light;
- broad plazas and flight corridors that accommodate high-speed combat;
- enormous civic buildings, military compounds, statues, banners, and terraces;
- technology integrated into architecture rather than loose computers everywhere;
- a sparse population footprint: fewer small homes, more communal/official halls;
- wilderness that still looks engineered through roads, pylons, and remote stations.

### Earth

Earth should provide contrast: warmer, denser, improvised, greener, and visibly
lived in. It needs a recognizable modern city, suburbs, transport infrastructure,
shops, ordinary interiors, countryside, coast, forest, mountains, arctic terrain,
and a dry region. Reuse the best geography work already present in the Super Earth
generator, but replace empty landmarks and repeated rectangles with authored
districts and human-scale details.

Earth should use curated existing assets before new art is commissioned. Viltrum
should use a purpose-built Aseprite set so it does not look like recolored Earth.

## Current repository facts to preserve

- `DU.dme` currently includes `Map2018.dmm`, `Space2018.dmm`, `Viltrum.dmm`, and
  `SuperEarth.dmm` in that order.
- `Z_LEVEL_VILTRUM` is 20 and `Z_LEVEL_SUPER_EARTH` is 21 in
  `src/Code/CoreFunctions/Vars/WorldConstants.dm`.
- Viltrum landing is currently `(250,78,Z_LEVEL_VILTRUM)` and its racial spawn is
  centered near `(250,250,Z_LEVEL_VILTRUM)`.
- Super Earth landing is currently controlled by `SUPER_EARTH_LANDING_X/Y` and
  lands near `(101,362,Z_LEVEL_SUPER_EARTH)`.
- Planet objects, liftoff, disabling/restoring planets, respawn fallback, planetary
  control, and scanner regions already support both worlds.
- `src/Code/Tests/ViltrumPlanetSmoke.dm` and
  `src/Code/Tests/SuperEarthSmoke.dm` protect that integration.
- The existing generators write the final 500x500 maps directly and use `--force`.
  They are blockout tools, not the desired long-term authoring workflow.
- The working tree may contain unrelated user changes. Preserve all of them.

Do not change Z-level ordering merely to solve editing performance. Do not add one
Z-level per district. The assembled world must remain a single seamless surface
per planet unless a future request explicitly chooses instanced interiors.

## ClassicBlunder audit and reuse policy

The reference repository was audited at:

- URL: `https://github.com/Antenora/ClassicBlunder`
- commit: `f31a9dafed198530838d7762bf9c10ace2ed9187`
- audit date: 2026-09-06

Useful source collections include:

- `Map/2_City.dmm` for city composition and density reference;
- `Map/SpaceStation.dmm` and `Map/Storage Maps/MechaShip.dmm` for technological
  room composition;
- `Map/Storage Maps/Marketplace.dmm`, `TrainStation.dmm`, `ScienceLab.dmm`,
  `ScienceFactory.dmm`, `ScienceOffice.dmm`, `ScienceCafe.dmm`,
  `ScienceSatellite.dmm`, and `ShinraTowerEntrance.dmm` for modular POI reference;
- `Mapping/NewIcons/Industrial*.dmi` for an eight-file industrial kit;
- `Turfs/Technology.dmi`, `Tiles.dmi`, `Floors.dmi`, `Walls.dmi`, `Roofs.dmi`,
  `TrainInterior.dmi`, and the laser-door sprites;
- `Icons/Objects/Technology32x64.dmi`, `Technology64x64.dmi`, `Doors.dmi`,
  `Objects.dmi`, domestic props, seats, tables, store fixtures, and wall sprites.

The audit found no `LICENSE`, `COPYING`, or `NOTICE` file in the repository root or
history path query. On 2026-09-06, the Nexus Exodus user confirmed that the
ClassicBlunder developers directly authorized use of their repository's maps and
assets in this project. Treat that confirmation as the project's permission basis;
it is not a claim that the repository has a general public license.

ClassicBlunder content is therefore approved for selective import and adaptation:

1. Import the smallest coherent asset subsets that support the planned districts;
   do not bulk-copy the repository.
2. Record the direct developer permission, source URL, source commit, original
   path, author if known, modifications, and destination in `docs/AssetCredits.md`.
3. Compute SHA-256 hashes for imported originals and keep an import manifest under
   `docs/Maps/ClassicBlunderAssetImport.json`.
4. Preserve original unmodified files in a clearly documented import/source folder
   when an asset will be edited, then export normalized production copies to the
   appropriate Nexus icon folder.
5. Do not include a complete upstream DMM directly in `DU.dme`. Its type paths,
   areas, doors, consoles, passwords, and runtime assumptions belong to another
   codebase. It may be used as an authorized layout/template source, but recreate
   the chosen structures with Nexus Exodus types, areas, collision rules, and
   gameplay requirements.
6. Remove embedded passwords, upstream-only objects, admin/event artifacts, stale
   area types, and undefined paths from every adapted structure.

## Authoring architecture

### Tracked inputs

Create this structure using PascalCase names and no spaces:

```text
src/Maps/PlanetChunks/
  Viltrum/
    ViltrumA1.dmm ... ViltrumE5.dmm
    ViltrumManifest.json
  SuperEarth/
    SuperEarthA1.dmm ... SuperEarthE5.dmm
    SuperEarthManifest.json

ArtSource/
  Viltrum/
    ViltrumPalette.aseprite
    ViltrumGround.aseprite
    ViltrumArchitecture.aseprite
    ViltrumTechnology.aseprite
    ViltrumProps.aseprite
  Earth/
    EarthCityAdditions.aseprite
```

Every chunk is exactly 100x100 at local coordinates `(1,1,1)`. Rows A-E run
north to south in the design documents; columns 1-5 run west to east. The
assembler owns the conversion between that human-readable convention and DMM's
row orientation. Document and test the conversion so a map is never vertically
mirrored silently.

### Generated outputs

Keep these stable for game integration:

```text
src/Maps/Viltrum.dmm
src/Maps/SuperEarth.dmm
docs/Maps/ViltrumOverview.png
docs/Maps/SuperEarthOverview.png
docs/Maps/ViltrumChunkAtlas.png
docs/Maps/SuperEarthChunkAtlas.png
```

Add a sidecar metadata file for each generated map containing the generator
version, manifest hash, individual chunk hashes, output hash, dimensions, palette
key count, and generation time. Do not depend on comments inside DMM syntax.

### Tools

Replace the two independent direct-map generators with a shared implementation:

```text
tools/MapAssembly/AssemblePlanetMaps.cjs
tools/MapAssembly/SeedPlanetChunks.cjs
tools/MapAssembly/RenderPlanetAtlas.ps1
tools/MapAssembly/TestPlanetChunks.cjs
tools/Open-PlanetChunk.ps1
```

Required behavior:

- Parse ordinary DMM key dictionaries and coordinate blocks; do not rely on fixed
  one- or two-character keys.
- Canonicalize and deduplicate identical atom stacks across chunks.
- Rewrite keys deterministically and emit a 500x500, one-Z DMM.
- Refuse missing, duplicate, wrongly sized, multi-Z, malformed, or out-of-manifest
  chunks.
- Validate that every serialized type exists in `DU.dme`'s environment.
- Generate identical bytes from identical inputs.
- Treat final DMM files as generated. Refuse to replace an output whose recorded
  hash no longer matches, unless the caller explicitly acknowledges that manual
  output edits will be lost.
- Never overwrite a chunk or `.aseprite` source through `--force`.
- `Open-PlanetChunk.ps1` must create its editor environment under a temporary or
  ignored directory, include normal game code plus exactly one selected chunk,
  and open that chunk in StrongDMM. It must not rewrite `DU.dme`.
- Preserve `ViltrumEditor.dme` and `SuperEarthEditor.dme` until the replacement
  chunk workflow is proven; remove or repurpose them only in a separate cleanup.

The old `GenerateViltrumMap.cjs` and `GenerateSuperEarthMap.cjs` should first be
used to seed terrain into chunks. After parity is proven, convert them to thin
wrappers around the new shared tool or retire them with documentation. Never run
their current `--force` paths after manual chunk work begins.

## World layout

### Viltrum 5x5 atlas

| Chunk | Primary content | Required play value |
| --- | --- | --- |
| A1 | Northwest ocean and islands | Visual boundary, one remote beacon |
| A2 | Polar escarpment | Wilderness traversal, cave/event hook |
| A3 | Northern defense citadel | Military POI and planetary defense vista |
| A4 | Polar preserve | Snow/ice contrast and training route |
| A5 | Northeast ocean | Visual boundary and offshore platform silhouette |
| B1 | Western cliffs and aqueduct | Coastal route into the capital |
| B2 | Residential terraces | Homes, communal hall, clinic, quiet RP space |
| B3 | Imperial palace precinct | Throne/audience hall, memorial court, guarded offices |
| B4 | Science enclave | Research hall, medical lab, archive, energy systems |
| B5 | Eastern cliffs | Scenic overlook and concealed service entrance |
| C1 | Grand training grounds | Open combat fields and endurance course |
| C2 | Civic and market district | Services, gathering space, food, equipment, NPC hooks |
| C3 | Capital forum | Viltrumite racial spawn, main plaza, wayfinding hub |
| C4 | War college and arena | Academy, barracks, arena, spectator circulation |
| C5 | Planetary energy works | High-technology utility POI and sabotage/event hooks |
| D1 | Western badlands | Craters, ruins, resource gathering, long sightlines |
| D2 | Shipyard approach | Freight road, hangars, maintenance and transit |
| D3 | Imperial spaceport | Existing planet landing, terminal, safe arrival radius |
| D4 | Fabrication district | Industrial gameplay, warehouses, repair facilities |
| D5 | Abandoned research ruins | Exploration, lore, hostile/event staging |
| E1 | Southwest ocean | Boundary |
| E2 | Southern coast | Beach/cliff route and isolated watch post |
| E3 | Southern badlands | Sparse wilderness and impact basin |
| E4 | Southeast coast | Communications array and route back north |
| E5 | Southeast ocean | Boundary |

The connected city occupies B2-D4 but must not read as a nine-chunk solid building
mass. Use green/stone courtyards, reservoirs, parade grounds, and broad boulevards
to create breathing room. The palace in B3, forum in C3, and spaceport in D3 form
the main north-south axis. Training in C1 and the energy works in C5 establish a
second east-west axis.

Keep the existing landing coordinate if practical. If the chunk pipeline makes a
coordinate adjustment desirable, define named constants for all important points
and migrate every caller and smoke assertion together. Do not leave magic numbers.

### Earth 5x5 atlas

| Chunk | Primary content | Required play value |
| --- | --- | --- |
| A1 | Northwest sea | Boundary and weather vista |
| A2 | Glacier coast | Arctic biome and research outpost |
| A3 | Alpine range | Mountain paths, waterfall source, cave hook |
| A4 | Boreal forest | Cold wilderness and cabin POI |
| A5 | Northeast sea | Boundary |
| B1 | Temperate coast | Beach, cliffs, lighthouse |
| B2 | Rural town and farms | Low-tech homes, food, peaceful RP |
| B3 | Lake and forest reserve | Water route and natural gathering area |
| B4 | Suburbs | Housing, school/dojo, local shops |
| B5 | Harbor | Docks, warehouses, ferry/ship staging |
| C1 | Western sea/islands | Boundary with optional island event space |
| C2 | Old town | Dense walkable blocks and small businesses |
| C3 | Metropolitan core | Main human spawn, civic plaza, hospital, commerce |
| C4 | Commercial/industrial belt | Factories, garages, technology vendors |
| C5 | Eastern coast | Waterfront promenade and port connection |
| D1 | Southwest coast | Scenic route and sparse settlement |
| D2 | Grassland and farms | Open combat/training and resources |
| D3 | Airport/spaceport and transit | Planet landing, rail/bus hub, safe arrival radius |
| D4 | Desert and oasis city | Dry biome, canyon route, secondary settlement |
| D5 | Southeast coast | Delta/wetland transition |
| E1 | Southern sea | Boundary |
| E2 | Tropical islands | Jungle biome and exploration |
| E3 | Southern ocean | Boundary |
| E4 | Arid islands | Desert coast/event space |
| E5 | Southern sea | Boundary |

Cut the current Super Earth terrain into chunks as the starting point so its
continent masks, rivers, lakes, waterfalls, and biome intent are not discarded.
Then reshape terrain only where the authored city network needs it. Keep snow and
ice confined to the northern region and preserve green margins around desert
waterways as specified in the existing Super Earth documentation.

## Level-design rules

- Main boulevards: 7-11 walkable tiles wide.
- Secondary streets: 5-7 tiles wide.
- Alleys/service paths: at least 3 tiles wide.
- Sidewalks/terraces: at least 2 tiles wide.
- Primary public doors: 3-5 tiles wide; secondary doors: at least 2 tiles wide.
- Main combat plazas: at least 28x28 clear tiles.
- Arena combat floor: at least 48 tiles across, with four unobstructed exits.
- Planet landing: a clear 21x21 region centered on the landing coordinate because
  `Bump_Planet` currently scatters arrivals by plus/minus ten tiles.
- Never place a spawn on a dense turf or inside a door animation footprint.
- Every required POI must be reachable from its planet landing and main spawn by
  cardinal walking without admin powers, flight, destructible walls, or doors that
  require an unknown password.
- Provide at least two routes into every major district so one battle cannot seal
  the world.
- Keep permanent dense coverage below 30 percent in outdoor urban chunks and below
  20 percent in dedicated combat areas.
- Favor large baked turf/facade sprites and sparse objects over one decorative obj
  per tile. Static decoration that has no gameplay behavior should not inflate
  runtime atom count unnecessarily.
- Clearly distinguish collision-bearing base tiles from nonblocking visual
  overlays. Large sprites need documented anchor tiles and footprints.
- Avoid narrow diagonal seams, one-tile bridges, hidden entrances, and visual edges
  whose apparent collision disagrees with their turf density.
- Chunk boundaries must be visually invisible in the assembled map. At least two
  traversable connections must cross every boundary between neighboring active
  land chunks.
- Ocean/world edges must be deliberately inaccessible or return players safely;
  test high-speed flight and knockback at every boundary.

## Viltrum Aseprite asset brief

### Technical format

- Base grid: 32x32 pixels.
- Use crisp pixel art, nearest-neighbor scaling, transparent backgrounds, and no
  semi-transparent fringe pixels unless the effect intentionally requires alpha.
- Multi-tile structures may use 32x64, 64x64, 96x96, or larger cells, but their
  DMI frame size, anchor, pixel offsets, and collision footprint must be explicit.
- Use lower snake case for icon states and stable directional suffixes:
  `_n`, `_s`, `_e`, `_w`, `_ne`, `_nw`, `_se`, `_sw`.
- Doors need complete closed/opening/open/closing frames and matching density logic.
- Animated screens should use short loops and restrained frame counts.
- Keep the editable `.aseprite` source, exported PNG sheets if useful, final DMI,
  palette, and export notes together under documented paths.
- Confirm every state with an automated DMI metadata audit before mapping with it.

### Palette and material language

Sample final colors from the supplied planet reference during execution. Preserve
the following roles even if exact hex values change:

- pale cyan: atmosphere, water highlight, polished civic surface;
- saturated teal: land identity, glass, banners, controlled energy;
- deep blue-teal: water depth, structural shadow, road inset;
- cool off-white: monumental stone-metal and palace surfaces;
- charcoal/navy: frames, vents, expansion joints, readable outlines;
- restrained warm gold: imperial authority accent only;
- warning amber/red: industrial and military hazards only.

Do not use magenta neon, rainbow signage, rusty corrugated metal as the dominant
material, or Earth-style asphalt everywhere.

### Minimum viable asset set

1. `ViltrumGround.dmi`
   - teal soil/stone variants;
   - pale shore and deep/shallow water transitions;
   - plateau, crater, snow, ice, and engineered garden variants;
   - cardinal and corner transitions needed by the atlas.
2. `ViltrumFloors.dmi`
   - civic white, teal inset, dark structural, palace, laboratory, grate, landing
     pad, road, curb, crossing, warning, and arena-floor states.
3. `ViltrumWalls.dmi`
   - wall faces, top caps, inner/outer corners, columns, windows, glass walls,
     parapets, railings, gates, and damaged/ruined variants.
4. `ViltrumDoors.dmi`
   - civic, palace, laboratory, hangar, and force-field entrances with animation.
5. `ViltrumArchitecture.dmi`
   - modular facade pieces for palace, academy, residence, lab, hangar, tower, and
     memorial structures; include shadow/roof pieces that compose cleanly.
6. `ViltrumTechnology.dmi`
   - integrated consoles, holographic table, medical station, energy conduit,
     reactor element, communications array, defense emitter, and landing beacon.
7. `ViltrumProps.dmi`
   - benches, planters, lighting pylons, banners, statues, crates, lockers, beds,
     tables, storage, signs, and ruin debris.

Implement only the first states needed for the first vertical slice, then expand
the same coherent kit. Do not create dozens of isolated one-off sprites before a
complete district can be assembled.

### Asset definitions

Add clean types in subsystem-specific files, for example:

```text
src/Code/MapCode/ViltrumTerrain.dm
src/Code/MapCode/ViltrumArchitecture.dm
src/Code/MapCode/ViltrumTechnology.dm
```

Add every new DM file to the `// BEGIN_INCLUDE` block in `DU.dme`. Follow project
naming: PascalCase types, camelCase procs, snake_case variables, tab indentation.
Set build categories, density, opacity, destructibility, lighting, layer, and
plane intentionally. Do not inherit gameplay behavior from a convenient legacy
type unless that behavior is actually desired.

## Earth asset strategy

First inventory what Nexus Exodus already has under `src/Icons/MapObjects` and
`src/Icons/Turfs`. It already contains buildings, doors, furniture, props, metal
floors, technological floors, landing-bay floors, houses, stairs, water, and large
terrain tiles. Build an in-game/editor catalog before drawing replacements.

ClassicBlunder reuse is authorized. Prioritize the smallest coherent Earth kit:

- industrial roads, walls, fences, houses, shops, and props;
- ordinary domestic furniture and store fixtures;
- train/transport pieces;
- technology floors, doors, consoles, roofs, and glass;
- only the POI composition lessons needed for Earth.

Normalize imported paths and wrap them in new Nexus types rather than importing
the upstream type hierarchy. Do not use ClassicBlunder industrial art as Viltrum's
primary visual language. It may inform Earth factories and service areas.

## Implementation phases and gates

### Phase 0: protect and baseline

1. Read repository instructions and inspect `git status`.
2. Record hashes of the current two generated maps and their generators.
3. Run the current compile-only smoke baseline and note pre-existing failures.
4. Render/save current overviews for visual comparison.
5. Do not alter unrelated dirty files.

Gate: baseline evidence is documented and current map work is recoverable.

### Phase 1: chunk pipeline

1. Implement the shared parser, validator, assembler, atlas renderer, and tests.
2. Split the current Viltrum output into 25 exact 100x100 chunks without visual or
   semantic changes.
3. Reassemble it and prove byte-equivalent semantics: dimensions, tile atom stacks,
   coordinates, landmarks, and area types must match even if DMM keys differ.
4. Prove deterministic regeneration twice.
5. Open several individual chunks in StrongDMM using the temporary editor DME.

Gate: existing Viltrum behavior is preserved and no 500x500 map must be opened for
editing.

### Phase 2: Viltrum vertical slice

Build C3 (capital forum), D3 (spaceport), and the direct corridor between them.
Create only the Aseprite assets needed for those chunks. Include:

- safe planet arrival and clear wayfinding;
- Viltrumite spawn plaza;
- one complete public building with exterior and interior;
- one functioning technological landmark;
- one broad combat space;
- finished chunk seams to neighboring temporary terrain.

Gate: compile, startup smoke, asset audit, connectivity tests, atlas render, and an
in-game walkthrough all pass. Visual style is approved before producing the rest.

### Phase 3: Viltrum capital and military ring

Complete B2-B4, C1-C5, D2-D4. Add palace, residences, civic/market functions,
science, war college, arena, shipyards, industry, and energy works. Keep buildings
purposeful: every large facade needs a reachable entrance and useful interior or
must be clearly background scenery.

Gate: all capital POIs are reachable by two routes; arena and plazas support actual
combat; map scanner output is legible; atom counts remain within the measured
budget established by the vertical slice.

### Phase 4: Viltrum wilderness and polish

Complete remaining chunks, coastlines, polar regions, badlands, ruins, outposts,
boundary safety, signs, lighting, and environmental transitions. Replace the
temporary tinted Vegeta planet icon only if a correctly licensed/original space
icon is included in scope.

Gate: Viltrum meets the full definition of done below.

### Phase 5: Earth vertical slice and city

Cut current Super Earth terrain into chunks, preserve its geographic features,
then build C3, D3, and their transit corridor. Use existing/authorized city assets
and create original gap-fill art. The vertical slice must include a hospital or
civic building, shops, housing, transport, and an open training/combat area.

Gate: Earth has a visually distinct, human-scale city and preserves spawn/landing,
scanner, planet-control, biome, river, and waterfall behavior.

### Phase 6: Earth regions and final integration

Complete the remaining atlas, connect biome travel routes, add regional POIs,
finish signs and navigation, update docs/proc references, and perform full tests.

Gate: both worlds meet all automated and manual acceptance criteria.

## Automated verification

Run after every phase that changes code/assets/maps:

```powershell
.\tools\Test-NamingConventions.ps1
.\tools\Test-AssetReferences.ps1 -Strict
.\tools\Invoke-ByondSmoke.ps1 -CompileOnly
```

Run the full baseline before final delivery:

```powershell
.\tools\Invoke-ByondSmoke.ps1
```

Add focused checks for:

- exactly 25 chunks per planet and exactly 100x100x1 per chunk;
- deterministic assembly and 500x500x1 final outputs;
- no undefined atom paths or wrong area types;
- no duplicate required spawns;
- clear 21x21 planet landing regions;
- cardinal connectivity from landing and spawn to every required POI;
- two boundary crossings between adjacent active land chunks;
- no unreachable public room and no doorless decorative shell presented as usable;
- safe outer boundaries under walking, flight, knockback, and teleport arrival;
- map scanner region bounds and rendering progress;
- Viltrum/Super Earth planet discovery, liftoff, disable/enable, respawn fallback,
  saved-position compatibility, and planetary-control context;
- DMI state existence, frame dimensions, animation metadata, and filename casing;
- output atom counts by category (turfs, static objs, dynamic objs, light sources).

Do not weaken existing assertions to make a new map pass. Update coordinates through
named constants and strengthen tests around the new invariants.

## Visual and gameplay review checklist

- Inspect every chunk alone and in the assembled atlas.
- Inspect every seam at day and night.
- Walk and fly from landing to all POIs without admin teleport.
- Fight in the forum, arena, training grounds, Earth metro plaza, and wilderness.
- Test doors and large sprites from all directions.
- Confirm roofs/walls do not obscure entrances or characters unexpectedly.
- Confirm lighting does not create hundreds of unnecessary active light sources.
- Confirm the scanner remains understandable at 500x500 overview scale.
- Confirm each district has a distinct silhouette and at least one memorable anchor.
- Confirm signs and road hierarchy make navigation possible without memorizing coords.
- Confirm Viltrum cannot be mistaken for an Earth industrial zone.
- Confirm Earth looks inhabited rather than procedurally scattered.

## Definition of done

The project is complete only when:

1. Mappers edit 100x100 chunks, not either 500x500 final DMM.
2. Assembly is deterministic, validated, documented, and safe against overwriting
   manual source work.
3. Viltrum contains a coherent capital, palace, civic/market district, residences,
   war college, arena, spaceport, science enclave, fabrication/energy areas,
   wilderness, ruins, and outposts.
4. Earth contains a coherent modern city, housing, commerce, civic/medical space,
   transport, industry, rural settlement, and distinct natural regions.
5. Both worlds have safe landings, valid spawns, redundant navigation routes,
   high-speed combat spaces, and protected boundaries.
6. All new art has editable sources, coherent states, correct collision metadata,
   and documented provenance.
7. Every ClassicBlunder import has a manifest entry, source hash, modification
   record, and direct-permission credit in `docs/AssetCredits.md`.
8. Naming, strict asset references, compile-only smoke, full smoke, focused map
   tests, atlas review, and in-game walkthrough pass with zero new warnings or
   runtimes.
9. `docs/Maps/Viltrum.md`, `docs/Maps/SuperEarth.md`, relevant `docs/procs/`
   references, and `docs/AssetCredits.md` match the shipped implementation.
10. The final handoff lists changed files, test results, known limitations, asset
    provenance, screenshots/atlases, and the next recommended mapping slice.

## Copy-paste prompt for Astra

You are implementing the Viltrum and Earth map rebuild in the Nexus Exodus BYOND
DM repository. Read the repository `AGENTS.md` and then read this entire file before
acting. Treat this file as the approved product and technical specification.

Execute the phases in order, beginning with baseline protection and the chunk
authoring pipeline. Preserve all unrelated working-tree changes. Do not overwrite
manual maps or art sources. Do not change the existing Z-level model: Viltrum must
remain one seamless runtime surface at `Z_LEVEL_VILTRUM`, and Super Earth must
remain one seamless runtime surface at `Z_LEVEL_SUPER_EARTH`. Make 25 local
100x100 source chunks per planet and deterministically assemble each set into the
existing 500x500 DMM output.

Use the supplied cyan/teal planet image as Viltrum's macro visual reference. Build
Viltrum as monumental, ordered, spacious, and technologically superior to Earth,
using an original Aseprite asset kit with editable sources. Build Earth as warmer,
denser, greener, modern, and lived-in. Reuse current Nexus assets first.

The user confirmed on 2026-09-06 that the ClassicBlunder developers directly
authorized this project to use and adapt its maps and assets. Use commit
`f31a9dafed198530838d7762bf9c10ace2ed9187` as the audited source baseline.
Selectively import the city, industrial, domestic, transport, and technology assets
needed by the plan. Document the direct permission and every source/destination in
`docs/AssetCredits.md` and `docs/Maps/ClassicBlunderAssetImport.json`; do not treat
the authorization as a general public license. Adapt layouts to Nexus types rather
than including upstream DMM files directly.

Deliver the Viltrum C3/D3 vertical slice and its complete tests before scaling the
asset set or mapping the rest of Viltrum. Finish and verify Viltrum before changing
Earth. Use named constants for any moved coordinates, keep planet/spawn/scanner/
save/admin behavior intact, update documentation when behavior changes, and add
all new DM files to `DU.dme`.

At every gate, run the focused map tests, naming audit, strict asset-reference
audit, and compile-only smoke. Run the full BYOND smoke suite before final handoff.
Do not claim completion based only on generated previews: inspect chunk seams,
walk/fly routes, combat spaces, doors, landings, and boundaries in game. Continue
until the definition of done in this file is satisfied or a genuine product
decision requires user input. Report blockers with concrete evidence and
continue any independent work that remains safe.
