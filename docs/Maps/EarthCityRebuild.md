# Earth city and river revision — 2026-09-06

> Latest: [EarthNaturalLandmarks.md](EarthNaturalLandmarks.md). The city remains;
> all isolated buildings and old terrain stairs are retired, with explorable
> tile mountains, dunes, waterfall ledges and a sandstone cave in the wilderness.

> Superseded planet-wide layout: [EarthWilderness.md](EarthWilderness.md) is now
> current. It preserves the user's later city edits, removes ocean/remote roads,
> reduces regional buildings to six isolated shelters and repairs all rivers.
> Counts, hashes and generated structural footprints below describe the earlier
> city delivery. Do not restore them over the latest editor changes.

Applied to the 25 SuperEarth source chunks and assembled Z21 map. The western
city uses ordinary neighboring houses along shared sidewalks; streets follow
the river corridor instead of cutting through water and leaving grass fragments.
The continents and all 20 racial spawn coordinates/fields are retained.

## Current composition

- 15 aligned rows in the western city; 88 exteriors across Earth, including
  compact regional destinations. Four 5x6-tile house variants and four 7x6-tile
  hospital/shop/civic/garage variants share one perspective and frontage.
- 56 accessible Earth buildings: the 42 existing destinations plus 14 ordinary
  residences. Step on a threshold or use the nearby door/building to enter Z22;
  exit returns one tile in front of that same street door. Homes have furniture,
  and services retain their existing fixtures. Names do not add new healing,
  trading or other service mechanics.
- 37 Viltrum interiors retain their coordinates and contents. The combined Z22
  interior map is now 400x300, with 93 rooms; Earth homes use 14x12 rooms and
  larger services 22x18. Solid roof turfs seal each perimeter.
- A continuous river corridor between y260 and y410, minimum seven water tiles
  wide. The correction is limited to 290 declared cells in x112..174/y260..410.
  Outside that correction all 138,636 original water cells checked remain water,
  water-marked crossings or boundary ocean. All 21 waterfall cells and terrain
  stairs keep their locations. The long artificial cliff stripe is shortened
  around the western waterfall.
- Riverside walking paths follow both banks, with planted setbacks between
  water and streets. Road crossings at y314 and y398 have continuous asphalt,
  pedestrian pavement and concrete parapets anchored beyond both riverbanks.
  Regional asphalt causeways remain from the earlier layout.
- Generated meadow/water/soil/rock materials replace the bright rectangular
  grass patches and checker-like water. Neighbor-based edge and corner variants
  join bank surfaces; trees and small plantings follow the corridor.
- The 21x21 arrival park remains clear. Three reserved combat spaces, all racial
  spawns, public destinations and natural land-seam crossings remain reachable.

## Review coordinates and images

All surface coordinates below are on Z21. Images compose actual production DMI
pixels, north up. The detailed images use 32 pixels per tile and include a real
player base sprite for scale; they are not screenshots of the running client.

| Place | Coordinate | Native-scale preview |
| --- | --- | --- |
| Residential frontage | 61,378 | [ResidentialBlock.png](EarthNeighborhoodPreview/ResidentialBlock.png) |
| Hospital street | 65,338 | [HospitalStreet.png](EarthNeighborhoodPreview/HospitalStreet.png) |
| Shops and homes | 114,295 | [BookshopStreet.png](EarthNeighborhoodPreview/BookshopStreet.png) |
| Southern river bridge | 126,319 | [RiverBridge.png](EarthNeighborhoodPreview/RiverBridge.png) |
| Waterfall and bank walk | 129,347 | [WaterfallPark.png](EarthNeighborhoodPreview/WaterfallPark.png) |

[City overview](EarthNeighborhoodPreview/CityOverview.png),
[planet overview](EarthNeighborhoodPreview/PlanetOverview.png) and
[25-chunk atlas](SuperEarthChunkAtlas.png) are refreshed. StrongDMM and interactive
gameplay/lighting/occlusion review remain deferred by the user. Static previews
do not certify those visual behaviors.

## Verification of this applied revision

| Check | Result |
| --- | --- |
| Full Invoke-ByondSmoke.ps1, BYOND 516.1686 | 0 errors, 0 warnings; Versioned and Clean startup pass |
| Actual mapped Earth thresholds | All 56 entry/return pairs pass engine Crossed movement, KO/knockback restrictions and planet context checks |
| TestEarthNeighborhood.cjs | Continuous river, two complete bridges, zero overlapping buildings, zero blocked front sidewalks, 20 preserved/connected spawns |
| TestEarthLayout.cjs --regions | 52 destinations, combat spaces, 441 arrival cells, all land seams and biome restrictions pass |
| CityBuildingChecks.cjs | 93 connected interiors, 29,298 walkable floor cells, exact return links and retained furniture |
| TestPlanetChunks.cjs | Ten parser/assembly/overwrite protection groups pass for each planet |
| Existing Viltrum slice/world graph checks | Pass; 2,152 manually authored tiles retained |
| AuditEarthNeighborhoodAssets.py | Six DMIs, five exported native sources, 837 states, binary alpha, all 288 building crops identical to full sprites |
| AuditPlanetAssets.py | Earlier seven manifests and 12 DMIs still pass |
| Naming audit | Zero source/asset path problems; legacy identifier violations remain |
| Strict asset references | Zero missing/ambiguous/case problems; existing bare logo path in UIStuff.dm:91 still fails strict audit |

Machine-readable evidence: EarthNeighborhoodChecks.json,
EarthNeighborhoodAssetChecks.json, CityInteriorChecks.json,
SuperEarthWorldChecks.json and SuperEarthMetadata.json. Current assembled Earth
SHA-256: `4883ebac0e975f0e18df43fe45eddccf2f32c7bbbd82c652a33a10adcaa07e46`.

## Source and editing workflow

`ArtSource/Earth/Provenance.md` records asset sources and export commands.
`EarthNeighborhood.json` records building bounds, doors, river cross-sections,
bridges and changed terrain cells. `CityBuildings.json` is the interior registry.

`AuthorEarthNeighborhood.cjs` defaults to a preview under
`.codex-tmp/EarthNeighborhood`; `--apply` retains the first baseline under
`RebuildBaseline/BeforeEarthNeighborhood`. Subsequent runs require matching
surface, chunk, interior and registry hashes. Recover any manual edits before
re-authoring. Ordinary map edits should target the source chunks and use
`AssemblePlanetMaps.cjs SuperEarth`; do not overwrite manual map changes by
rerunning a historical generator. `RenderEarthNeighborhood.py --atlas` renders
the checked preview and updates the atlas after matching it to production.

The environment includes only Map2018, Space2018, Viltrum, SuperEarth and
CityInteriors in that order. The 50 source chunks must never also be included as
runtime maps. No StrongDMM session or asset pack import was used for this pass.
Research and how it informed the terrain are recorded in
[RiverCityReferences.md](RiverCityReferences.md).
