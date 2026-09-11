mob/proc/getBuildOwnerKey()
	return key

mob/proc/canReachBuildTile(turf/tile)
	if(!tile || !isturf(loc) || tile.z != z) return FALSE
	return tile in getReachableBuildTiles()

mob/proc/getReachableBuildTiles()
	if(!isturf(loc)) return list()
	return view(client ? client.view : 15,src)

var/list/build_preview_tile_icons = list()

proc/getBuildPreviewTileIcon(border_mask)
	var/cache_key = "[border_mask]"
	if(build_preview_tile_icons[cache_key]) return build_preview_tile_icons[cache_key]
	var/icon/tile_icon = icon('src/Icons/Unsorted/UserNamesBarsUi.png')
	tile_icon.Scale(32,32)
	tile_icon.DrawBox("#ffe19b22",1,1,32,32)
	if(border_mask & NORTH) tile_icon.DrawBox("#ffe19b",1,31,32,32)
	if(border_mask & SOUTH) tile_icon.DrawBox("#ffe19b",1,1,32,2)
	if(border_mask & EAST) tile_icon.DrawBox("#ffe19b",31,1,32,32)
	if(border_mask & WEST) tile_icon.DrawBox("#ffe19b",1,1,2,32)
	build_preview_tile_icons[cache_key] = tile_icon
	return tile_icon

// Mouse location is the turf under the cursor, even when an object covers it.
// Never substitute the player's feet when an event has no world destination.
proc/getBuildMouseTile(atom/object, location, control)
	if(control != "mapwindow.map" && control != "mainwindow.map" && control != "map") return null
	if(object && object.plane == NEXUS_FIXED_HUD_PLANE) return null
	if(isturf(location)) return location
	if(isturf(object)) return object
	if(object && isturf(object.loc)) return object.loc
	return null

datum/NexusBuildWindow
	var/tmp
		dragging = FALSE
		committing = FALSE
		stroke_generation = 0
		atom/stroke_brush
		list/stroke_tiles = list()
		list/stroke_keys = list()
		list/preview_images = list()
		list/hover_images = list()
		list/finishing_preview_images = list()
		turf/hover_tile
		stroke_elevation
		turf/last_mouse_tile
		stroke_origin_z = 0
		stroke_origin_x = 0
		stroke_origin_y = 0

	proc/consumesMapClick(atom/object,location,control)
		return active && owner && owner.build_brush && getBuildMouseTile(object,location,control)

	proc/clearPreviews()
		if(owner && owner.client)
			owner.client.images -= preview_images
		preview_images.Cut()
		clearHover()

	proc/clearHover()
		if(owner && owner.client) owner.client.images -= hover_images
		hover_images.Cut()
		hover_tile = null
		clearFinishingPreviews()

	proc/clearFinishingPreviews()
		if(owner && owner.client) owner.client.images -= finishing_preview_images
		finishing_preview_images.Cut()

	proc/cancelStroke()
		stroke_generation++
		dragging = FALSE
		stroke_brush = null
		stroke_elevation = null
		stroke_tiles.Cut()
		stroke_keys.Cut()
		last_mouse_tile = null
		clearPreviews()

	proc/makePreview(turf/tile,atom/brush,border_mask = NORTH|SOUTH|EAST|WEST,elevation = null,list/painted_keys = null)
		var/image/preview = image(brush.icon,tile,brush.icon_state)
		preview.dir = brush_direction
		preview.pixel_x = brush.pixel_x
		preview.pixel_y = brush.pixel_y
		preview.plane = NEXUS_WORLD_OVERLAY_PLANE
		preview.layer = 90
		preview.alpha = 150
		preview.mouse_opacity = 0
		addFinishingPreview(preview,tile,brush,elevation,painted_keys)
		var/image/outline = image(getBuildPreviewTileIcon(border_mask))
		outline.pixel_x = -brush.pixel_x
		outline.pixel_y = -brush.pixel_y
		outline.appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM
		outline.mouse_opacity = 0
		preview.overlays += outline
		return preview

	proc/getBrushElevation(turf/tile)
		if(!owner.build_auto_cliffs || !istype(owner.build_brush,/obj/Build)) return null
		var/turf/material = owner.build_brush:Creates
		if(!ispath(material,/turf) || initial(material.Water) || initial(material.density) || initial(material.build_category) != BUILD_GROUND || !initial(material.auto_cliff)) return null
		return tile.build_elevation+1

	proc/addFinishingPreview(image/preview,turf/tile,atom/brush,elevation,list/painted_keys)
		if(!istype(brush,/obj/Build)) return
		var/turf/material = brush:Creates
		if(!ispath(material,/turf) || initial(material.Water) || initial(material.density)) return
		var/level = isnull(elevation) ? tile.build_elevation : elevation
		if(owner.build_auto_edges && initial(material.auto_edge) && initial(material.edge_icon))
			for(var/direction in list(NORTH,EAST,WEST,SOUTH))
				var/turf/neighbor = get_step(tile,direction)
				if(!neighbor) continue
				if(painted_keys && painted_keys["[neighbor.x],[neighbor.y],[neighbor.z]"])
					if(!isnull(elevation) || neighbor.build_elevation >= level) continue
				else if(!isBuildTerrainBoundary(material,level,neighbor,neighbor.build_elevation)) continue
				var/state = direction == NORTH ? "N" : (direction == SOUTH ? "S" : (direction == EAST ? "E" : "W"))
				var/image/edge = image(initial(material.edge_icon),icon_state = state)
				edge.pixel_x = -preview.pixel_x
				edge.pixel_y = -preview.pixel_y
				preview.overlays += edge
		if(isnull(elevation)) return
		var/turf/destination = owner.getBuildCliffDestination(tile,material,elevation,painted_keys)
		if(!destination) return
		var/turf/cliff_material = initial(material.cliff_type)
		var/image/cliff = image(initial(cliff_material.icon),destination,initial(cliff_material.icon_state))
		cliff.plane = NEXUS_WORLD_OVERLAY_PLANE
		cliff.layer = 90
		cliff.alpha = 150
		cliff.mouse_opacity = 0
		finishing_preview_images += cliff

	proc/updateHover(turf/tile)
		if(dragging || committing) return
		if(tile && tile == hover_tile && hover_images.len) return
		clearHover()
		if(!active || !owner || !owner.build_brush || dragging || committing || prompt_open || category == "Science") return
		var/list/reachable = owner.getReachableBuildTiles()
		if(!tile || !(tile in reachable)) return
		hover_tile = tile
		var/radius = round(brush_size/2)
		var/elevation = getBrushElevation(tile)
		var/list/targets = list()
		var/list/painted_keys = list()
		for(var/tile_x = tile.x-radius, tile_x <= tile.x+radius, tile_x++)
			for(var/tile_y = tile.y-radius, tile_y <= tile.y+radius, tile_y++)
				var/turf/target = locate(tile_x,tile_y,tile.z)
				if(!target || !(target in reachable)) continue
				targets += target
				painted_keys["[target.x],[target.y],[target.z]"] = TRUE
		for(var/turf/target in targets)
			var/border_mask = 0
			if(target.x == tile.x-radius) border_mask |= WEST
			if(target.x == tile.x+radius) border_mask |= EAST
			if(target.y == tile.y-radius) border_mask |= SOUTH
			if(target.y == tile.y+radius) border_mask |= NORTH
			hover_images += makePreview(target,owner.build_brush,border_mask,elevation,painted_keys)
		if(owner.client)
			owner.client.images += hover_images
			owner.client.images += finishing_preview_images

	proc/beginStroke(turf/tile)
		if(!active || committing || prompt_open || !owner || !owner.build_brush || !owner.canReachBuildTile(tile)) return FALSE
		if(owner.KO || !owner.is_out_of_combat(owner)) return FALSE
		cancelStroke()
		dragging = TRUE
		stroke_brush = owner.build_brush
		stroke_elevation = getBrushElevation(tile)
		stroke_origin_z = owner.z
		stroke_origin_x = owner.x
		stroke_origin_y = owner.y
		addBrushAt(tile)
		last_mouse_tile = tile
		refreshStrokePreviews()
		return TRUE

	proc/addBrushAt(turf/center)
		if(!center || !dragging || !stroke_brush || center.z != stroke_origin_z) return
		var/radius = round(brush_size/2)
		var/list/reachable = owner.getReachableBuildTiles()
		for(var/tile_x = center.x-radius, tile_x <= center.x+radius, tile_x++)
			for(var/tile_y = center.y-radius, tile_y <= center.y+radius, tile_y++)
				if(stroke_tiles.len >= NEXUS_BUILD_STROKE_LIMIT) return
				var/turf/tile = locate(tile_x,tile_y,center.z)
				if(!tile || !(tile in reachable)) continue
				var/tile_key = "[tile.x],[tile.y],[tile.z]"
				if(stroke_keys[tile_key]) continue
				stroke_keys[tile_key] = TRUE
				stroke_tiles += tile

	proc/refreshStrokePreviews()
		if(owner.client) owner.client.images -= preview_images
		preview_images.Cut()
		clearFinishingPreviews()
		for(var/turf/tile in stroke_tiles)
			var/border_mask = 0
			for(var/direction in list(NORTH,EAST,WEST,SOUTH))
				var/turf/neighbor = get_step(tile,direction)
				if(!neighbor || !stroke_keys["[neighbor.x],[neighbor.y],[neighbor.z]"]) border_mask |= direction
			preview_images += makePreview(tile,stroke_brush,border_mask,stroke_elevation,stroke_keys)
		if(owner.client)
			owner.client.images += preview_images
			owner.client.images += finishing_preview_images

	proc/extendStroke(turf/tile)
		if(!dragging || !tile || tile.z != stroke_origin_z) return
		if(!owner || owner.x != stroke_origin_x || owner.y != stroke_origin_y || owner.z != stroke_origin_z)
			cancelStroke()
			return
		if(!owner.canReachBuildTile(tile))
			last_mouse_tile = null
			return
		// Fill gaps between mouse packets while retaining one placement per coordinate.
		if(last_mouse_tile)
			var/steps = max(abs(tile.x-last_mouse_tile.x),abs(tile.y-last_mouse_tile.y))
			for(var/step_index = 1, step_index <= steps, step_index++)
				var/paint_x = round(last_mouse_tile.x+(tile.x-last_mouse_tile.x)*step_index/steps,1)
				var/paint_y = round(last_mouse_tile.y+(tile.y-last_mouse_tile.y)*step_index/steps,1)
				addBrushAt(locate(paint_x,paint_y,tile.z))
		else addBrushAt(tile)
		last_mouse_tile = tile
		refreshStrokePreviews()
		if(status_control) status_control.setLabel("[stroke_tiles.len]/[NEXUS_BUILD_STROKE_LIMIT] tiles - release to place\nRight-click to cancel")

	proc/commitStroke(turf/release_tile)
		if(!dragging || committing) return
		if(!release_tile || !owner || owner.x != stroke_origin_x || owner.y != stroke_origin_y || owner.z != stroke_origin_z)
			cancelStroke()
			return
		extendStroke(release_tile)
		if(!dragging) return
		var/list/pending = stroke_tiles.Copy()
		var/atom/brush = stroke_brush
		var/generation = stroke_generation
		dragging = FALSE
		committing = TRUE
		clearPreviews()
		var/placed = 0
		var/list/placed_ground = list()
		try
			for(var/turf/tile in pending)
				if(!active || generation != stroke_generation || owner.build_brush != brush) break
				if(owner.x != stroke_origin_x || owner.y != stroke_origin_y || owner.z != stroke_origin_z) break
				var/atom/result = placeBrushTile(brush,tile)
				if(result)
					placed++
					if(isturf(result)) placed_ground += result
				if(world.tick_usage > 60) sleep(world.tick_lag)
			// Finish the completed perimeter, never intermediate rows within a large brush.
			if(active && generation == stroke_generation && owner.build_brush == brush)
				for(var/turf/ground in placed_ground)
					if(!active || generation != stroke_generation || owner.build_brush != brush || owner.x != stroke_origin_x || owner.y != stroke_origin_y || owner.z != stroke_origin_z) break
					if(owner.build_auto_cliffs) owner.placeBuildCliff(ground,TRUE,stroke_keys)
				for(var/turf/ground in placed_ground) refreshBuildEdgesAround(ground)
		catch(var/exception/error)
			committing = FALSE
			cancelStroke()
			throw error
		committing = FALSE
		cancelStroke()
		refreshStatus()
		if(status_control) status_control.setLabel("[placed]/[pending.len] placed - [Commas(owner.Res())] RES\n[brush ? getDisplayName(brush) : "Select a blueprint"]")

	proc/placeBrushTile(atom/brush,turf/tile)
		if(istype(brush,/obj/Build)) return buildLay(brush,owner,tile,TRUE,src)
		if(istype(brush,/obj/CustomDecorBlueprint)) return buildLay(null,owner,tile,TRUE,src,brush)
		return null

client
	MouseDown(object,location,control,params)
		if(nexus_build_window && nexus_build_window.active && mob && mob.build_brush)
			var/list/buttons = params2list(params)
			var/turf/tile = getBuildMouseTile(object,location,control)
			if(tile)
				if(buttons["right"] == "1")
					nexus_build_window.cancelStroke()
					nexus_build_window.refreshStatus()
					return
				if(buttons["left"] == "1")
					nexus_build_window.beginStroke(tile)
					return
		return ..()

	MouseDrag(src_object,over_object,src_location,over_location,src_control,over_control,params)
		if(nexus_build_window && nexus_build_window.dragging)
			var/turf/tile = getBuildMouseTile(over_object,over_location,over_control)
			if(tile) nexus_build_window.extendStroke(tile)
			else nexus_build_window.last_mouse_tile = null
			return
		return ..()

	MouseUp(object,location,control,params)
		if(nexus_build_window && nexus_build_window.dragging)
			var/turf/tile = getBuildMouseTile(object,location,control)
			nexus_build_window.commitStroke(tile)
			return
		return ..()

	MouseEntered(object,location,control,params)
		if(nexus_build_window && nexus_build_window.active) nexus_build_window.updateHover(getBuildMouseTile(object,location,control))
		return ..()

	MouseExited(object,location,control,params)
		if(nexus_build_window && !nexus_build_window.dragging && getBuildMouseTile(object,location,control) == nexus_build_window.hover_tile) nexus_build_window.clearHover()
		return ..()
