# Map Code

## Overview
Auto-generated first-pass proc summaries based on signature names. Refine descriptions during refactors.

## Files
- `src/Code/MapCode/AmbientOcclusion.dm`
- `src/Code/MapCode/AutoEdge.dm`
- `src/Code/MapCode/JaggedEdgeFillers.dm`
- `src/Code/MapCode/QuadrantGenerator.dm`

## Proc Reference

### src/Code/MapCode/AmbientOcclusion.dm

#### turf/proc/IsAOCaster
- Signature: `IsAOCaster()`
- Inputs: None
- Purpose: Return whether AOCaster.
- Returns: boolean flag.
- Side effects: none expected.

#### turf/proc/IsAOReciever
- Signature: `IsAOReciever()`
- Inputs: None
- Purpose: Return whether AOReciever.
- Returns: boolean flag.
- Side effects: none expected.

#### turf/proc/CheckBottomAO
- Signature: `CheckBottomAO(skip_reciever_check)`
- Inputs: skip_reciever_check
- Purpose: Check Bottom AO.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/CheckRightAO
- Signature: `CheckRightAO(skip_reciever_check)`
- Inputs: skip_reciever_check
- Purpose: Check Right AO.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/CheckLeftAO
- Signature: `CheckLeftAO(skip_reciever_check)`
- Inputs: skip_reciever_check
- Purpose: Check Left AO.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/GenerateAmbientOcclusion
- Signature: `GenerateAmbientOcclusion(skip_side_checks)`
- Inputs: skip_side_checks
- Purpose: Handle generate ambient occlusion.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/GenerateAmbientOcclusionOnSelfAndNeighbors
- Signature: `GenerateAmbientOcclusionOnSelfAndNeighbors()`
- Inputs: None
- Purpose: Handle generate ambient occlusion on self and neighbors.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/MapCode/AutoEdge.dm

#### mob/Admin5/verb/testAlpha
- Signature: `testAlpha(atom/t in world)`
- Inputs: atom/t in world
- Purpose: Handle test alpha.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/GenerateFeatures
- Signature: `GenerateFeatures(ao_skip_side_checks = 0, do_cliff_check = 1, do_edge_check = 1, do_wave_check = 1, do_ao_check = 1)`
- Inputs: ao_skip_side_checks = 0, do_cliff_check = 1, do_edge_check = 1, do_wave_check = 1, do_ao_check = 1
- Purpose: Handle generate features.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/GenerateEdges
- Signature: `GenerateEdges()`
- Inputs: None
- Purpose: Handle generate edges.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/GenerateShoreWaves
- Signature: `GenerateShoreWaves()`
- Inputs: None
- Purpose: Handle generate shore waves.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/GenerateCliffs
- Signature: `GenerateCliffs()`
- Inputs: None
- Purpose: Handle generate cliffs.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/MapCode/QuadrantGenerator.dm

#### proc/round_up
- Signature: `round_up(n = 1)`
- Inputs: n = 1
- Purpose: Handle round up.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GenerateMapFeatures
- Signature: `GenerateMapFeatures()`
- Inputs: None
- Purpose: Handle generate map features.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GenerateMapFeaturesByZone
- Signature: `GenerateMapFeaturesByZone()`
- Inputs: None
- Purpose: Handle generate map features by zone.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GenerateZone
- Signature: `GenerateZone(n = 1)`
- Inputs: n = 1
- Purpose: Handle generate zone.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GetZoneNum
- Signature: `GetZoneNum(mob/m)`
- Inputs: mob/m
- Purpose: Return Zone Num.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/GenerateFeaturesOnPlayerTurfsOnMapLoad
- Signature: `GenerateFeaturesOnPlayerTurfsOnMapLoad()`
- Inputs: None
- Purpose: Handle generate features on player turfs on map load.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GenerateFeaturesOnBuildLay
- Signature: `GenerateFeaturesOnBuildLay(turf/t)`
- Inputs: turf/t
- Purpose: Handle generate features on build lay.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/MapCode/CityBuildings.dm

`obj/CityBuildingDoor/travel(mob/traveler)` validates same-Z proximity (one tile),
KO/knockback state, target turf and stationary target obstacles before using
SafeTeleport. Returns whether the traveler reached that destination. New/Del
maintain city_building_doors. Click and enterBuilding dispatch the same checks.
Earth/Crossed also dispatches actual movement over a threshold. Earth exits
return to the tile immediately in front of their own surface door, preventing
an automatic entry loop. The base Viltrum doors retain explicit interaction.

`obj/CityHouse/Click()` finds the same-Z doorway with its building_id and delegates
to travel, preserving proximity rules when clicking a large sprite.

`getCityInteriorRegion(turf/position)` resolves an interior area's surface_region
to its planet map region, or returns null outside CityInterior areas. The Z22
rooms therefore retain Earth/Viltrum context for existing planetary control.

### src/Code/MapCode/EarthNeighborhood.dm

`turf/EarthBuildingStructure/New()` adds a shared meadow underlay beneath the
individual 32x32 building crop. Full building objects and solid sight-blocking
structural turfs use the same art, so a hidden southwest anchor does not leave
blank footprint turf. Structure Enter inherits the unconditional block from
CityBuildingFootprint; the interior is reached through a separate door.

EarthStreet defines asphalt, lanes, crossings, pavement and bridge deck pieces.
North/South bridge parapets are dense and nonopaque; deck and pedestrian pieces
remain walkable. EarthStreetFixture supplies transparent trees, benches, lamps,
fences, bins and planting. Collision belongs to the object, not its background.

### src/Code/MapCode/EarthRiverTerrain.dm

EarthRiver inherits Water2 mechanics with the new water states and no legacy
wave-icon overlay. EarthRiverBank supplies the matched meadow/soil edge states;
EarthRiverFall, EarthRiverSteps and EarthRiverRock retain the existing waterfall,
stairs and rock mechanics. Eight-neighbor icon selection is authored in the DMM
by tools/MapAssembly/EarthRiverTerrain.cjs, without runtime terrain generation.

### src/Code/MapCode/EarthNaturalLandmarks.dm

EarthNaturalGround provides full 32px terrace, continuous ramp, dune and cave
floor turfs. `terrain_height` documents authored terrace levels on the surface
map; it is not a new movement axis. EarthNaturalRoof supplies solid, opaque rock
faces and cavern enclosure, including an unconditional Enter block.
EarthNaturalFall keeps WaterFall entry/exit behavior and explicitly sets Water;
EarthNaturalFoam inherits EarthRiver water mechanics. The old EarthRiverSteps
definition remains compatible with historical maps but is not placed on Earth.

EarthCaveEntrance inherits the guarded CityBuildingDoor travel implementation.
Its invisible Crossed trigger transfers an adjacent conscious player from a
visible cave-mouth turf to Z22; Exit returns to the clear approach at Z21.
The cave uses CityInterior/Earth, preserving the surface planet context.

### Interior destination validation — 2026-09-07

CityBuildingDoor.isValidDestination(turf/destination) validates the destination
before travel. Surface entrances require Z22 CityInterior turf with the door's
interior_region; Earth building/cave doors use super_earth, Viltrum doors use
viltrum. Exits require their matching surface area and Z level. This prevents a
misconfigured interior destination from sending players to another planet even
when that destination is walkable. Proximity, KO/KB and obstruction checks remain.

DU.dme loads the five runtime maps in a protected preamble before BEGIN_INCLUDE.
Dream Maker's alphabetically generated map registrations cannot become the
first includes and change the global Z assignments. TestRuntimeMapOrder.cjs
models that editor save and checks accumulated map Z ranges; the smoke runner
also verifies the actual compiler load sequence, including CityInteriors.

### Runtime shoreline preservation — 2026-09-07

`GenerateCliffs()` in AutoEdge.dm is called by GenerateFeatures during the
player-triggered GenerateZone passes. Its legacy behavior replaces southern
water with cliff_type (Wall7 by default) and extends water one tile farther south.
This changes the actual terrain and collision, not just its overlays.

`area.auto_cliffs` defaults to TRUE for existing maps; SuperEarth sets it FALSE.
`turf.allowsAutomaticCliffs()` checks that area policy. GenerateCliffs checks the
source, water destination and southern extension before either replacement, so
legacy ground types and neighboring unprotected areas cannot rewrite protected
terrain. SuperEarth also disables `area.auto_edges` and `area.auto_waves`.
GenerateEdges checks the source area through allowsAutomaticEdges;
GenerateShoreWaves checks both the source and water area through
allowsAutomaticWaves before adding an overlay or recording wave_icon_applied.
These checks apply to direct calls as well as GenerateFeatures/GenerateZone.
Ambient-occlusion shadows remain available. No existing overlays are cleared.

No DMM or saved player construction is rewritten by this fix. Loading the newly
compiled world restores authored terrain; generated cliffs have no Builder and
are not included by mapSave's player-construction filter.
