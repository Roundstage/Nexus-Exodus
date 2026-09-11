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
- Side effects: selects the persistent build brush without placing anything. Repeated selection is idempotent; the combat `Target` is untouched.

### mob/proc/turfLayCost()
- Purpose: Calculate the resource cost per tile to build.
- Returns: integer cost (scaled by total built turfs and multipliers).

### mob/proc/stopBuildingThings()
- Purpose: Clear current build target selection.

### proc/isInVoid(mob/m)
- Purpose: Determine whether a mob is in the void/blank turf.
- Returns: true if location is invalid or `/turf/Other/Blank`.

### proc/buildLay(obj/Build/o, mob/p, turf/destination, decorate = TRUE, datum/NexusBuildWindow/session = null, obj/CustomDecorBlueprint/custom = null)
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
- Purpose: Open the native build panel and select an authorized custom decor brush. Placement uses the shared `buildLay` validation and the explicit mouse destination.

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

### Native construction panel and brush (2026-09-11)
- `M` toggles a draggable native map HUD. `BuildPanel.dm` allocates controls and 25 sprite slots once; categories, pages, search, selection and option changes update those same controls. No browser, HTML navigation or `browse()` reload participates in building.
- The compact panel is 220x448 native pixels with an opaque background, thin frames, three rows of three category tabs, gold selection/hover feedback and unscaled 32px thumbnails at its normal size. `/obj/NexusHudBitmapText` renders labels from the project's Silkscreen glyph sprites, with exact advance/ink measurements, discrete font sizes and explicit ellipsis; these controls no longer render HTML/maptext. The title uses 16px glyphs, normal controls 12px, and small controls/status details 8px. Status lines occupy independent boxes below the grid. `TOP` already accounts for each icon's height; applying another height offset hides the background and misaligns controls. `fitToViewport()` reduces visible rows before reducing scale, reuses hidden slots, adapts pagination, and clamps the entire panel inside an 8px margin. A visibility-scoped viewport watcher reads the map's actual `size` and `view-size`, accounting for skin zoom and cropped map controls.
- `NexusBuildWindow/selectBlueprint()` keeps the brush in `mob.build_brush`, independently from combat `Target`. Selecting twice keeps it selected; changing category preserves it. Science selection requires an explicit **Craft item** action and custom decor selection does not spawn anything.
- `getBuildMouseTile(object, location, control)` uses the mouse event's world turf, including when an object covers it, and rejects HUD controls and missing locations. It never falls back to the character's position.
- `updateHover()` displays all 1/9/25 cells in the selected brush, a visible footprint outline, and the enabled finishing. `beginStroke()` / `extendStroke()` preview the complete stroke, including perimeter edges and southern cliff faces, before release. Reachable tiles are collected once per footprint; repeated hover events on the same tile reuse the preview. Interpolation covers gaps between mouse packets; coordinate keys deduplicate the stroke, capped at 128 tiles. `MouseUp` calls `commitStroke()`, which validates and places each unique tile once, retaining the selected brush.
- Right-click cancels the stroke. Stop clears the brush. Closing, moving, changing category/brush and releasing outside the world cancel pending work. A generation counter prevents stale work after cancellation during a yielded commit; combat and resources are checked at placement time.
- `buildLay()` requires an explicit destination in the builder's visible view on the same Z, and rechecks area restrictions, ownership, resources, entrances and turret passes there. Terrain and objects share this path; custom decor additionally validates catalog membership, creator/admin access and the custom-building policy. Object limits are checked before allocation. Every placed tile/object is charged and registered for saving once.
- Objects retain the selected brush after placement. Door passwords and sign text are configured before painting through **Configure**, so painting never opens a prompt per object. **Rotate** affects objects; turf orientation uses the blueprint's original direction. Walking does not place anything.
- With Cliffs enabled, a ground stroke targets one level above its starting tile. `build_elevation` distinguishes same-material raised patches and nested terraces, following the supplied `2026-09-11 08-04-55.mp4` reference. Adjacent terrain at the same type/level joins without internal seams. Without Cliffs, painting preserves the destination's existing level.
- `placeBuildCliff(ground, explicit_build, painted_keys)` uses `getBuildCliffDestination()` for explicit brush finishing: one paid/owned cliff may occupy lower, empty southern natural ground or ordinary water in the same area. Roads, authored Earth banks/landforms, entrances, objects, other owners and coordinates included in the current stroke are excluded. All normal `buildLay()` permission, resource and distance checks still apply. The entire footprint is placed before cliffs are generated, avoiding transient cliffs and extra costs inside a 3x3/5x5 brush. No lower tile is flooded to make room for a cliff.
- `refreshBuildEdges()` tracks only build-generated overlays and outlines material/level boundaries using existing edge sprites; it does not add texture-fringe blending. `refreshBuildEdgesAround()` updates neighboring player-built borders while preserving authored art. The explicit player options apply to owned construction even where global automatic decoration is disabled. Super Earth's `auto_edges`, `auto_cliffs` and `auto_waves` remain FALSE, and the legacy world generators retain all protected-area checks.
- Map segments store optional aligned `BuildEdges` and `BuildElevations` lists. Both normal and external loading restore elevations through `getSavedBuildElevation()`; old saves default to level zero and disabled build edges.
- `canActivateControl()` gates both clicks and hover highlighting. The title remains a drag handle without button highlighting; backgrounds, status text, page labels, empty slots and unavailable actions do not advertise a clickable action. Stop also clears Science selection.
- Regression coverage: `BuildBrushSmoke.dm` exercises opaque background geometry, TOP anchoring, viewport fitting, non-overlapping controls, visible text pixels, explicit truncation, native thumbnail sizes, control reuse, real terrain/object placement away from the builder, interpolation, deduplication, resource costs, ownership/saving, cancellation and combat. It exports `BuildPanelTextSmoke.png` from actual runtime icons in the temporary smoke directory. `BuildTerrainSmoke.dm` covers shoreline finishing and protected areas. Research, rationale and verification limits are recorded in `docs/BuildHudRenderingResearch.md`.
- Reference examined: Fourth Fate [native HUD](https://github.com/Antenora/ClassicBlunder/blob/ca513d9b428f0a53f4c46cb94b699f49a2fc5b67/_Reworks/Building/build_hud.dm), [mouse/paint tools](https://github.com/Antenora/ClassicBlunder/blob/ca513d9b428f0a53f4c46cb94b699f49a2fc5b67/_Reworks/Building/build_tools.dm), [previews](https://github.com/Antenora/ClassicBlunder/blob/ca513d9b428f0a53f4c46cb94b699f49a2fc5b67/_Reworks/Building/build_preview.dm) and [session state](https://github.com/Antenora/ClassicBlunder/blob/ca513d9b428f0a53f4c46cb94b699f49a2fc5b67/_Reworks/Building/build_core.dm). This implements the native palette/paint workflow using Nexus code, assets and construction permissions.
