# Earth: one city and wilderness — 2026-09-06

> Historical stage. Superseded by [EarthNaturalLandmarks.md](EarthNaturalLandmarks.md): the remaining shelters are retired and the wilderness contains explorable tile terrain.

This is the current Earth map revision. The approved western neighborhood remains
the only major city. The east continent and southern desert are wilderness,
without asphalt grids or roads across the ocean.

## Applied changes

- Restored 30,796 road/pavement tiles to terrain, including all legacy ocean
  causeways. Asphalt is confined to the main city; its two local river bridges
  remain complete. Outgoing stubs end at the last city junctions.
- Retained 64 city buildings, including its three southern services reached by
  short local dirt paths. Six isolated shelters remain: Northern woodland cabin,
  Arctic research outpost, Alpine survey shelter, Jungle lookout lodge, Island
  nature lodge and Southern dune shelter. Each has a small dirt forecourt.
- Retired 18 regional suburb, commercial, port and oasis buildings. Their former
  surface lots return to the original biome, and their unused rooms/doors are
  cleared. Full records, contents and source maps are retained in the backup.
  There are 38 accessible Earth buildings and 75 total Earth/Viltrum interiors.
- Repaired 486 natural terrain cells. The historical generator drew the bank of
  each river segment over previous water segments, causing grass dams and grassy
  islands in the source lakes. The new helper unions all channel, source-lake and
  plunge-pool water first. Banks no longer overwrite any part of that union.
- Removed artificial riverbank extensions into open ocean at the river mouths.
  The original continental outlines, all waterfall/stair landmarks and biome
  placement remain. The user's expanded western water is retained.
- Restored original wilderness ground and 407 existing tree objects. The eastern
  combat clearing uses the surrounding biome instead of an isolated lawn patch.

## Latest editor changes were recovered first

The assembled SuperEarth.dmm contained 4,397 edited cells not yet saved to source
chunks. Recovery imported those edits before the authorized road/terrain cleanup.
All retained house footprints use their edited ground and objects, including the
user's removal of generated structural turf beneath the city houses. Do not
reapply the earlier house-footprint generator over these changes.

All twenty spawn atoms retain their latest editor positions. In particular,
Makyo is now 97,367; Demigod 151,326; Kai 154,322. The older scenic seed coordinates
are historical. The 441-tile arrival park remains clear.

Two malformed dictionary entries contained multiple turfs. Recovery retained the
last declared turf in each entry and preserved the complete raw file at
`RebuildBaseline/EarthManualRecovery/SuperEarthEditorSave.dmm`. The exact tile
deltas and normalization decisions are in `SuperEarthManualRecovery.json`.
The wilderness pass retains its own complete pre-change snapshot under
`RebuildBaseline/BeforeEarthWilderness`.

## Verification

Full `Invoke-ByondSmoke.ps1` passed with BYOND 516.1686: zero compiler errors or
warnings, and both Versioned and Clean startup modes passed without runtimes.
The ten focused SuperEarth chunk/parser/assembly/overwrite checks also passed.

`TestEarthWilderness.cjs` checks the applied map or `--preview`: all retained house
footprints, current spawns, local door access, zero asphalt outside the city, no
intercontinental land routes, complete local bridge decks and water at every
sample of the original river union outside the approved city reach. It flood
fills actual water from the ocean to all three source lakes. The city reach is
checked against its approved continuous channel separately.

The dry-land graph deliberately excludes water regardless of BYOND density;
Water2 uses existing swimming/flight entry hooks. Players can still cross water
using those game mechanics. A test must not recreate roads to force every
continent into the city's dry-land component.

`TestEarthLayout.cjs` and `TestEarthNeighborhood.cjs` delegate to the current
topology checks after this revision. `CityBuildingChecks.cjs` verifies all 75
remaining interiors (24,998 walkable floor cells), furniture and exact return
links. Runtime smoke walks all 38 Earth doors, probes the removed causeways and
river junctions, and tests structural roof behavior in an isolated fixture so
it does not overwrite the user's edited city ground.

Current assembled SHA-256:
`cdb81658affff136cefb8fcd5002d3e35d0f5a0d4f544d928d91d3be55609039`.
Machine-readable evidence is in `EarthWildernessChecks.json`,
`CityInteriorChecks.json` and `src/Maps/SuperEarthMetadata.json`.

## Preview and editing

[Full planet](EarthNeighborhoodPreview/PlanetOverview.png),
[city](EarthNeighborhoodPreview/CityOverview.png),
[eastern river bend](EarthNeighborhoodPreview/EasternRiver.png),
[desert source lake](EarthNeighborhoodPreview/DesertRiver.png),
[chunk atlas](SuperEarthChunkAtlas.png).

These previews compose production DMI pixels, including existing wilderness tree
sprites. They are not client screenshots. StrongDMM and interactive visual review
remain deferred by the user.

Edit the current source chunks and assemble with
`node tools/MapAssembly/AssemblePlanetMaps.cjs SuperEarth`. The initial city and
regional generators are historical. `AuthorEarthWilderness.cjs` produces a
guarded preview; `--apply` verifies recorded output, interior and registry hashes
before rebuilding from its retained baseline. Recover any later manual edits
first. `RenderEarthNeighborhood.py --atlas` now selects the wilderness preview
by default and checks that it matches the applied maps before rendering.
