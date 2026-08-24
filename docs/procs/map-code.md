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
