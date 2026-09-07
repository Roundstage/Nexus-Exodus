# River city correction — 2026-09-06

The user rejected the Earth neighborhood preview because the river, surviving
grass patches, waterfall stripe and road crossings did not compose as terrain.
The corrected neighborhood is applied to the production Earth chunks. See
[EarthCityRebuild.md](EarthCityRebuild.md) for current assets, coordinates and
verification; the rejected preview is not the production reference.

## Primary references and application

- [Waterfront Toronto — Don Mouth Naturalization](https://www.waterfrontoronto.ca/our-projects/don-mouth-naturalization-and-port-lands-flood-protection): plan the river valley, parkland, streets and crossings together. In Nexus, reserve a continuous planted bank corridor before positioning streets or houses.
- [Waterfront Toronto — Keating Channel Precinct](https://www.waterfrontoronto.ca/our-projects/keating-channel-precinct): a continuous waterfront promenade links public spaces and selected bridges. Use a riverside walking route, with neighborhood streets set behind it.
- [FHWA — Bridge abutment hydraulic considerations](https://www.fhwa.dot.gov/publications/research/infrastructure/structures/bridge/17013/011.cfm): crossing location and bank stability matter; abutments generally sit back from the channel banks. Our game bridges need a legible continuous deck, parapets, bank supports and connected approaches. This is a visual/gameplay interpretation, not an engineering design.
- [Red Blob Games — Rivers](https://www.redblobgames.com/x/2022-voronoi-maps-tutorial/#rivers): drainage follows downhill connections and accumulates upstream flow. Keep the source, falls, downstream channel and sea connected; do not draw disconnected water remnants around roads.
- [Tiled — Using Terrains](https://doc.mapeditor.org/en/stable/manual/terrain/): terrain transitions must match neighboring edges and corners. Use a complete set of water/bank transitions and consistent ground materials rather than isolated texture rectangles.
- [RPG Maker — Mapping Forests](https://www.rpgmakerweb.com/blog/mapping-forests): natural vegetation benefits from varying silhouettes and groupings. Place small clusters along the banks and leave walking routes readable.

## Implementation constraints

Keep the continents, all racial spawn coordinates and the clear arrival area.
Preservation of a spawn does not require preserving the rejected grass texture.
Restyle the arrival park and waterfall surrounds to join the neighboring ground;
test their passability and retained gameplay features rather than exact old pixel
or turf-string identity. Keep roofs as solid structure, furniture transparent,
and accessible buildings linked to separate interiors.

Rework roads that intersect the river corridor, use deliberate bank-to-bank
bridges, and show a native-scale river/bridge composition before claiming the
terrain is repaired. Scripted previews do not simulate all BYOND lighting and
occlusion behavior. StrongDMM remains deferred by the user.
