# City design reset — 2026-09-06

The user rejected the current in-game result. The new direction is ordinary house
sprites placed directly beside neighboring houses in a recognizable street/block
structure. This supersedes the isolated tower and oversized paved-lot treatment.
Separate interiors reached through doors remain the selected gameplay model.

## References researched

| Reference | What it contributes to this project |
| --- | --- |
| [LimeZu — Modern Exteriors](https://limezu.itch.io/modernexteriors) | Primary visual reference for compact modern houses, consistent doors/windows, streets and neighborhood props. The author supplies 16/32/48-pixel variants. |
| [LimeZu — Additional Houses](https://limezu.itch.io/modernexteriors/devlog/1084097/399th-update-additional-houses-99) | House variants, side-facing versions and completed door animations. A street needs usable orientations, not only south-facing showcase illustrations. |
| [finalbossblues — Omega Modern](https://finalbossblues.itch.io/omega-modern-graphics-pack) | Alternative for simpler, more readable RPG proportions. Modular house/building pieces allow related forms in one consistent style. |
| [RPG Maker — Mapping: Towns](https://www.rpgmakerweb.com/blog/mapping-towns) | Purposeful neighborhoods, coherent materials, sensible paths and evaluation of each player-visible view. Start compact; avoid oversized empty areas. |
| [NACTO — Neighborhood Street](https://nacto.org/publication/urban-street-design-guide/streets/neighborhood-street/) | Street hierarchy: residential streets connect homes to nearby shops/schools and provide pedestrian space. Used as urban composition reference, not literal real-world engineering dimensions. |
| [NACTO — Neighborhood Main Street](https://nacto.org/publication/urban-street-design-guide/streets/neighborhood-main-street/) | Busier commercial frontage, crossings, sidewalks and small public spaces. Helps distinguish a main street from residential lanes. |

The linked artist previews are references. No pack was purchased or imported in
this research pass. The project should use one coherent native pixel-art family;
the different packs above are alternatives, not a recommendation to mix them.

## Selected visual example

This official LimeZu preview was inspected at full size. Neighboring buildings
share a pavement network; doors are readable against characters; narrow gaps,
trees, benches and a small park organize the space. The buildings feel like a
neighborhood because their sizes and spacing relate to one another.

![Official LimeZu neighborhood preview](https://img.itch.zone/aW1hZ2UvMTMyOTQyNi83NzMxMTU1LmdpZg==/original/ZK4jma.gif)

Credit and source: [LimeZu / Modern Exteriors](https://limezu.itch.io/modernexteriors).
This is an externally hosted reference, not Nexus production art.

## Proposed project specification

These are design starting points for Nexus, not dimensions taken from a source.

- Make a kit of ordinary one/two-storey homes: detached, attached/terraced,
  corner house, small apartment, corner shop and a modest clinic. Use a shared
  perspective, roof height, wall height, window scale and door scale.
- Anchor dimensions to the actual player sprite. Begin with homes about 5–7
  tiles wide and 5–7 tiles deep; the front door should read at one tile wide.
  Confirm against characters at normal game zoom before choosing final sizes.
- Compose rows of 4–6 neighboring homes. Use shared side walls or 0–1 tile
  visual gaps where no passage is intended. Provide occasional real alleys of
  at least 3 tiles; do not imply walking through a one-tile decorative gap.
- Align entrances to a common frontage. Use a continuous 2-tile sidewalk, small
  entrance steps and backyards behind houses. Avoid a separate giant concrete
  rectangle centered under every sprite.
- Residential streets start at 7 walkable tiles; main avenues retain 9–11.
  Preserve designated combat plazas and peripheral routes rather than widening
  every house's surroundings into a combat square.
- Place shops at corners and civic/medical destinations on the main street.
  Reserve large silhouettes for a few landmarks. Ordinary housing establishes
  the neighborhood's visual rhythm.
- Variation should come from compatible roofs, windows, awnings and gardens.
  Avoid unique monumental architecture for every residential building.
- Road bridges continue the asphalt surface and show a consistent deck/edge.
  Preserve riverbanks, source lakes and waterfalls; avoid arbitrary piers into
  water sources just to connect a rectangular road graph.
- Viltrum's residential kit should still be ordinary readable housing under the
  latest instruction. Its palette/material accents may differ from Earth's;
  the rejected skinny tower sprites are not the new baseline.

## Next concrete slice

Design one compact residential block with 8–12 adjacent houses, one corner shop,
one accessible residence, a nearby clinic entrance, sidewalks, an alley and small
backyards. Show the block with a real player sprite at normal zoom. Check entry,
occlusion and collision there before changing the wider maps again.

## Current implementation state

Latest refinement: [EarthWilderness.md](EarthWilderness.md) preserves the approved
city and subsequent editor changes while replacing remote road grids with
wilderness. Earth now has 64 city buildings and six isolated shelters, with 38
accessible buildings. The earlier delivery below records how the kit was made.

Earth now uses four compatible house sprites and four service buildings on
aligned frontages, with transparent street furnishings. The main western city
has 15 rows; the Earth surface has 88 exteriors and 56 doors to separate rooms.
The subsequent river/grass correction reserves continuous banks before streets
and provides two complete asphalt bridges. See [EarthCityRebuild.md](EarthCityRebuild.md)
and [RiverCityReferences.md](RiverCityReferences.md) for the applied revision.

BYOND 516.1686 compiles with zero errors/warnings and passes both startup smoke
modes, including all Earth door entry/return paths. Historical palace/hospital
tests now inspect their migrated positions. The 37 Viltrum rooms are retained;
its rejected exterior art has not been redesigned in this Earth-first pass.
Native-scale DMI compositions are available for review. Interactive game visuals
and StrongDMM remain deferred and are not certified by these previews.
