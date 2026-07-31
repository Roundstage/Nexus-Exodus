# Building

## Overview
Player construction, map save/load of built tiles, buildable object catalog, and custom decor blueprints.

## Files
- `src/Code/Building/Build.dm`
- `src/Code/Building/Connector Wires.dm`
- `src/Code/Building/Custom Icon Build Tab.dm`

## Proc Reference

### proc/mapSave()
- Purpose: Persist player-built turfs into segmented savefiles under `data/Map*`.
- Side effects: writes `Types`, `Healths`, `Builders`, `Xs`, `Ys`, `Zs`, `FlyOver` lists to disk.

### proc/mapLoad()
- Purpose: Load saved player-built turfs from `data/Map*` into the live world.
- Side effects: instantiates turfs, rebuilds `Turfs` and `built_turfs`, removes default map decor.

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

### obj/Build/Click()
- Purpose: Select a build template or place it at the player location.
- Side effects: checks combat, sets `Target`, calls `buildLay`.

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
