mob/var/tmp
	build_auto_edges = FALSE
	build_auto_cliffs = FALSE
	atom/build_brush

turf/var
	build_edges_enabled = FALSE
	build_elevation = 0
	tmp/list/build_edge_overlays

proc/getSavedBuildElevation(list/elevations,index)
	if(!islist(elevations) || index > elevations.len || !nexusIsFiniteNumber(elevations[index])) return 0
	return max(0,round(elevations[index]))

proc/isBuildTerrainBoundary(turf/material, elevation, turf/neighbor, neighbor_elevation)
	if(!neighbor || neighbor_elevation > elevation) return FALSE
	if(neighbor.density && neighbor.type != initial(material.cliff_type)) return FALSE
	return neighbor.type != material || neighbor_elevation < elevation

// Track only this tool's overlays so refreshing borders preserves authored art.
turf/proc/refreshBuildEdges()
	if(build_edge_overlays) overlays -= build_edge_overlays
	build_edge_overlays = null
	// This opt-in belongs to a player-built tile, not the world's automatic decorator.
	if(!Builder || !build_edges_enabled || Water || density || !auto_edge || !edge_icon) return
	build_edge_overlays = list()
	for(var/direction in list(NORTH, EAST, WEST, SOUTH))
		var/turf/neighbor = get_step(src, direction)
		if(!neighbor) continue
		if(!isBuildTerrainBoundary(type,build_elevation,neighbor,neighbor.build_elevation)) continue
		var/state = "N"
		switch(direction)
			if(EAST) state = "E"
			if(WEST) state = "W"
			if(SOUTH) state = "S"
		var/image/border = image(icon = edge_icon, icon_state = state)
		build_edge_overlays += border
		overlays += border

proc/refreshBuildEdgesAround(turf/center)
	if(!center) return
	for(var/turf/tile in range(1,center)) tile.refreshBuildEdges()

// A cliff is a paid, owned tile placed through the same permission checks.
// Explicit brush finishing may border open natural land too. Global generators
// retain their area restrictions; roads, banks, objects and other owners are excluded.
mob/proc/getBuildCliffDestination(turf/ground,turf/material,elevation,list/painted_keys = null)
	if(!ground || initial(material.Water) || initial(material.density) || !initial(material.auto_cliff) || !initial(material.cliff_type) || initial(material.build_category) != BUILD_GROUND) return
	var/turf/border_tile = get_step(ground,SOUTH)
	if(!border_tile || border_tile.contents.len || border_tile.density || border_tile.loc != ground.loc || !canReachBuildTile(border_tile)) return
	if(border_tile.build_elevation >= elevation) return
	if(border_tile.Builder && border_tile.Builder != getBuildOwnerKey()) return
	if(painted_keys && painted_keys["[border_tile.x],[border_tile.y],[border_tile.z]"]) return
	if(istype(border_tile,/turf/EarthFloor) || istype(border_tile,/turf/EarthRiver) || istype(border_tile,/turf/Teleporter)) return
	if(!border_tile.Water && border_tile.build_category != BUILD_GROUND) return
	return border_tile

mob/proc/placeBuildCliff(turf/ground, explicit_build = FALSE, list/painted_keys = null)
	if(!ground || ground.Water || ground.density || !ground.auto_cliff || !ground.cliff_type) return
	var/turf/border_tile = get_step(ground,SOUTH)
	if(explicit_build)
		if(ground.Builder != getBuildOwnerKey()) return
		border_tile = getBuildCliffDestination(ground,ground.type,ground.build_elevation,painted_keys)
		if(!border_tile) return
	else
		if(!border_tile || border_tile.contents.len || border_tile.density) return
		if(border_tile.Builder && border_tile.Builder != getBuildOwnerKey()) return
		if(!ground.allowsAutomaticCliffs() || !border_tile.Water || !border_tile.allowsAutomaticCliffs()) return
		var/turf/south = get_step(border_tile,SOUTH)
		if(!south || !south.Water || !south.allowsAutomaticCliffs()) return
	for(var/obj/Build/blueprint in Builds)
		if(blueprint.Creates == ground.cliff_type)
			return buildLay(blueprint,src,border_tile,FALSE)
