# Building

## Overview
Player construction, map save/load of built tiles, buildable object catalog, and custom decor blueprints.

## Files
- `src/Code/Building/Build.dm`
- `src/Code/Building/Connector Wires.dm`
- `src/Code/Building/CustomIconBuildTab.dm`
- `src/Code/UI/Tabs2017/BuildTab.dm`

## Proc Reference

### proc/getMapSavePath(segment = 1)
- Purpose: Return the canonical `data/MapN` path for a validated segment number.

### proc/writeMapSaveSegment(...)
- Purpose: Write one aligned set of turf properties to a segmented map savefile.

### proc/writeMapSaveManifest(segment_count)
- Purpose: Commit the number of map segments written by the latest completed save.

### proc/getMapSaveSegmentCount()
- Purpose: Read the committed segment count, or zero for legacy saves without a manifest.

### proc/mapSave()
- Purpose: Persist player-built turfs into segmented savefiles under `data/Map*`.
- Side effects: writes `Types`, `Healths`, `Builders`, `Xs`, `Ys`, `Zs`, `FlyOver` lists to disk.
- Notes: records the committed segment count in `data/MapManifest` so stale files from a previously larger save are ignored.

### proc/mapLoad()
- Purpose: Load saved player-built turfs from `data/Map*` into the live world.
- Side effects: instantiates turfs, rebuilds `Turfs` and `built_turfs`, removes default map decor.
- Compatibility: honors `data/MapManifest` when present and falls back to scanning legacy segmented saves when absent.

### proc/mapLoadExternal(savefile/f)
- Purpose: Load an external map savefile on top of the current world.
- Inputs: `f` (path or savefile handle).
- Side effects: creates turfs and rebuilds `built_turfs` from that file.

### mob/proc/maxTurfUpgrade()
- Purpose: Compute the maximum wall HP upgrade allowed by Knowledge/Intelligence.
- Returns: numeric BP cap for upgrades.

### turf/proc/makeDenseAll(mob/m)
- Purpose: Set all turfs built by the same builder to be non-flyover.
- Inputs: `m` (requesting mob for cooldown enforcement).

### turf/proc/upgradeAll(mob/m, display_message = 0, for_free = 0)
- Purpose: Upgrade all structures for a builder up to `maxTurfUpgrade()`.
- Side effects: charges resources, updates turret/object health lists.

### turf/verb/upgrade()
- Purpose: Player-facing verb to upgrade or adjust density on their built tiles.
- Side effects: calls `makeDenseAll` and/or `upgradeAll` based on choice.

### proc/addBuilds()
- Purpose: Populate the global `Builds` list with buildable turf/object templates.
- Side effects: instantiates temporary objects to capture icon/name data.
- Indexing: rebuilds category buckets and a prefix index used by searchable build interfaces.

### proc/getCatalogSearchTokens(search_text)
- Purpose: Lowercase, split, and deduplicate searchable tokens of at least two characters.

### proc/registerCatalogSearchEntry(search_index, entry, search_text)
- Purpose: Add an entry to every normalized token-prefix bucket used by build and technology search.

### proc/searchCatalogIndex(search_index, query, category_entries, maximum_results = 100)
- Purpose: Intersect query-prefix buckets, apply the optional allowed/category set, and enforce a result limit.

### proc/rebuildBuildCatalogIndexes()
- Purpose: Rebuild category and prefix indexes after the build templates are created.

### proc/getBuildCatalogForCategory(build_category)
- Purpose: Return the prebuilt recipe bucket for one build category.

### proc/searchBuildCatalog(query, build_category = null, maximum_results = 100)
- Purpose: Return build recipes matching all normalized query prefixes, optionally restricted to one category.
- Performance: intersects prebuilt prefix buckets instead of scanning every recipe for each query.

### obj/Build/Click()
- Purpose: Route native icon clicks through `mob/proc/selectBuildBlueprint()`.

### mob/proc/selectBuildBlueprint(obj/Build/build)
- Purpose: Authoritative selection path shared by native icon clicks and the modern `M`-key build catalog.
- Side effects: checks combat, places the first tile, sets or clears `Target`, reports resource cost, and restores map focus.

### mob/proc/turfLayCost()
- Purpose: Calculate the resource cost per tile to build.
- Returns: integer cost (scaled by total built turfs and multipliers).

### mob/proc/stopBuildingThings()
- Purpose: Clear current build target selection.

### proc/isInVoid(mob/m)
- Purpose: Determine whether a mob is in the void/blank turf.
- Returns: true if location is invalid or `/turf/Other/Blank`.

### proc/buildLay(obj/Build/o, mob/p)
- Purpose: Core build placement routine for a selected template.
- Side effects: validates build rules, instantiates the target turf/obj, charges resources, updates `Built_Objs`/`built_turfs`.

### proc/initializeBuiltObjs()
- Purpose: Rebuild `Built_Objs` map from existing savable built objects.

### obj/Connector/New()
- Purpose: Initialize a connector with light source and refresh nearby icons.
- Side effects: adds to `all_connectors` and calls `DecideConnectorIcon` on neighbors.

### obj/Connector/Del()
- Purpose: Remove connector from global list.

### obj/Connector/proc/ConnectorHasPower()
- Purpose: Query whether a connector is currently powered.

### obj/Connector/proc/SetConnectorPowerStatus(on = 1, signal_sent_time)
- Purpose: Propagate power state through connected connectors.
- Side effects: updates light alpha, throttles recursion by timestamps.

### obj/Connector/proc/ConnectorLightSourceUpdate()
- Purpose: Sync light source icon and state with the connector sprite.

### obj/Connector/proc/DecideConnectorIcon()
- Purpose: Choose connector sprite based on adjacent connectors.
- Side effects: populates `attached_connectors`, updates icon/light source.

### mob/Admin4/verb/clearAllCustomDecors()
- Purpose: Delete all custom decor blueprints and spawned decor.
- Side effects: clears `customDecors`, deletes `/obj/Turfs/Custom`.

### proc/DeleteSpamCustomDecors()
- Purpose: Prune unused or default custom decor blueprints.
- Side effects: deletes items from `customDecors`.

### proc/CheckAddNewButtonForCustomDecors()
- Purpose: Ensure the "Add New" button exists in the custom build tab.

### obj/AddNewCustomDecorButton/Click()
- Purpose: Launch creation flow for a new custom decor blueprint.

### mob/proc/TryNewCustomDecorBlueprint()
- Purpose: Gate the creation flow by limits and server settings.

### mob/proc/MyDecorCount()
- Purpose: Count custom decor blueprints owned by the current player.

### mob/proc/NewCustomDecorBlueprintProc(obj/Turfs/Custom/copyThis)
- Purpose: Create a new blueprint, optionally cloning an existing decor.
- Side effects: charges resources, invokes `CustomizeDecor`, appends to `customDecors`.

### mob/proc/TryBuildCustomDecor(obj/CustomDecorBlueprint/c)
- Purpose: Validate and build a decor from a blueprint.

### mob/proc/CantBuildCustomDecor(obj/CustomDecorBlueprint/c)
- Purpose: Return a failure reason string for custom decor build attempts.

### mob/proc/BuildCustomDecor(obj/CustomDecorBlueprint/c)
- Purpose: Place a custom decor object in the world.
- Side effects: charges resources, updates `Built_Objs`, marks `Savable`.

### obj/CustomDecorBlueprint/Click(location, control, params)
- Purpose: Build the selected decor and refocus the map window.

### obj/CustomDecorBlueprint/verb/Destroy_Decor()
- Purpose: Remove a blueprint (creator/admin only).

### obj/CustomDecorBlueprint/verb/Customize_Decor()
- Purpose: Re-open the customization flow for a blueprint.

### mob/proc/DestroyDecor(obj/CustomDecorBlueprint/c)
- Purpose: Backend removal of a custom decor blueprint.
- Side effects: removes from `customDecors` and refreshes build tab.

### mob/proc/CustomizeDecor(obj/CustomDecorBlueprint/c)
- Purpose: Prompt for icon, name, offsets, description, density, and layer.
- Side effects: validates icon size/type and updates blueprint fields.
