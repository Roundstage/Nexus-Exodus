proc/runBuildBrushSmokeTests()
	var/list/originals = list()
	var/area/test_area = new /area
	for(var/tile_y = 280, tile_y <= 289, tile_y++)
		for(var/tile_x = 380, tile_x <= 390, tile_x++)
			var/turf/prior = locate(tile_x,tile_y,Z_LEVEL_CITY_INTERIORS)
			nexusSmokeAssert(!prior.contents.len,"Build brush fixture is occupied")
			originals += list(list(prior.x,prior.y,prior.type,prior.appearance,prior.loc,prior.Water))
			var/turf/ground = new /turf/GroundDirt(prior)
			test_area.contents += ground
	var/list/prior_built_turfs = built_turfs["build-smoke"]
	if(!Built_Objs) initializeBuiltObjs()
	var/list/prior_built_objects = Built_Objs["buildsmoke"]
	var/mob/NexusSmokeTest/BuildTools/builder = new(locate(380,280,Z_LEVEL_CITY_INTERIORS))
	var/mob/NexusSmokeTest/combat_target = new
	builder.Target = combat_target
	builder.build_test_cost = 100
	var/datum/NexusBuildWindow/panel = new(builder)
	panel.active = TRUE
	panel.createControls()
	runBuildPanelLayoutSmokeTests(panel)
	for(var/obj/NexusBuildControl/control in panel.controls)
		if(control.action in list("background","drag","status","page"))
			control.hovered = TRUE
			control.setLabel(control.label_text,control.label_active)
			nexusSmokeAssert(!panel.canActivateControl(control) && !control.hovered,"Passive build text or background advertises a click action")
		if(control.action == "category") nexusSmokeAssert(panel.canActivateControl(control),"Build category became noninteractive")
		if(control.action == "clear_search")
			panel.search_query = "fixture"
			control.hovered = TRUE
			control.setLabel(control.label_text)
			nexusSmokeAssert(control.hovered,"Available search-clear button lost its hover")
			panel.handleControl(control,"")
			nexusSmokeAssert(!panel.search_query && !control.hovered,"A button kept its hover after its action became unavailable")
	var/obj/NexusBuildControl/first_slot = panel.slots[1]
	var/control_count = panel.controls.len
	var/obj/Build/terrain = new
	terrain.Creates = /turf/Wall7
	terrain.icon = 'src/Icons/Turfs/TurfsLegacy1.dmi'
	terrain.icon_state = "cliff"
	var/obj/Build/decor = new
	decor.Creates = /obj/Turfs/Custom
	decor.icon = 'src/Icons/UI/CustomDecor.dmi'
	Builds += terrain
	Builds += decor
	panel.selectBlueprint(terrain)
	panel.setCategory("Ground")
	panel.setCategory("Floors")
	panel.page = 2
	panel.refreshCatalog()
	nexusSmokeAssert(panel.controls.len == control_count && panel.slots[1] == first_slot,"Build palette recreated controls during category/page changes")
	nexusSmokeAssert(builder.build_brush == terrain && builder.Target == combat_target,"Category selection changed the brush or combat target")
	var/turf/feet = builder.loc
	var/turf/start = locate(382,282,builder.z)
	var/turf/finish = locate(385,282,builder.z)
	var/obj/Turfs/Custom/cover = new(start)
	nexusSmokeAssert(getBuildMouseTile(cover,start,"mapwindow.map") == start,"Build mouse ignored the turf under a world object")
	nexusSmokeAssert(getBuildMouseTile(first_slot,start,"mapwindow.map") == null && getBuildMouseTile(null,null,"mapwindow.map") == null,"Build mouse mapped a HUD/missing destination to the world")
	del(cover)
	var/before_resources = builder.Res()
	nexusSmokeAssert(panel.beginStroke(start),"Visible remote stroke did not start")
	panel.extendStroke(finish)
	panel.extendStroke(start)
	nexusSmokeAssert(panel.stroke_tiles.len == 4 && builder.Res() == before_resources && start.type == /turf/GroundDirt,"Drag preview placed terrain or repeated a coordinate")
	panel.commitStroke(finish)
	for(var/tile_x = 382, tile_x <= 385, tile_x++)
		var/turf/placed = locate(tile_x,282,builder.z)
		nexusSmokeAssert(placed.type == /turf/Wall7 && placed.Builder == "build-smoke" && (placed in Turfs),"Brush did not place/save an owned turf at the cursor")
	nexusSmokeAssert(feet.type == /turf/GroundDirt && builder.Res() == before_resources-400,"Brush built at the feet or charged duplicate tiles")
	nexusSmokeAssert(builder.build_brush == terrain && !panel.dragging && !panel.preview_images.len,"Releasing the stroke lost selection or left previews")
	panel.selectBlueprint(decor)
	for(var/size in list(1,3,5))
		panel.brush_size = size
		panel.updateHover(locate(382,282,builder.z))
		nexusSmokeAssert(panel.hover_images.len == size*size,"Build hover preview does not show the full [size]x[size] footprint")
		var/list/hover_keys = list()
		for(var/image/preview in panel.hover_images)
			nexusSmokeAssert(isturf(preview.loc) && abs(preview.x-382) <= round(size/2) && abs(preview.y-282) <= round(size/2) && preview.overlays.len,"Build hover lacks an outline or extends outside its brush")
			hover_keys["[preview.x],[preview.y]"] = TRUE
		nexusSmokeAssert(hover_keys.len == size*size,"Build hover repeats a tile instead of covering its footprint")
		panel.updateHover(null)
		nexusSmokeAssert(!panel.hover_images.len && !panel.hover_tile,"Leaving the map retained a build hover preview")
	panel.brush_size = 1
	start = locate(382,280,builder.z)
	finish = locate(385,280,builder.z)
	before_resources = builder.Res()
	panel.beginStroke(start)
	panel.extendStroke(finish)
	panel.extendStroke(start)
	panel.commitStroke(finish)
	for(var/tile_x = 382, tile_x <= 385, tile_x++)
		var/turf/placed_at = locate(tile_x,280,builder.z)
		var/object_count = 0
		for(var/obj/Turfs/Custom/object in placed_at)
			object_count++
			nexusSmokeAssert(object.Builder == "build-smoke" && object.Savable,"Painted decor lost ownership or persistence")
		nexusSmokeAssert(object_count == 1,"Object stroke duplicated or missed a cursor tile")
	nexusSmokeAssert(!(locate(/obj/Turfs/Custom) in feet) && builder.Res() == before_resources-400 && builder.build_brush == decor,"Object stroke spawned at the feet, charged twice or deselected the brush")
	var/obj/CustomDecorBlueprint/custom = new
	custom.name = "Cursor custom decor"
	custom.pixel_x = 7
	custom.creator = builder.ckey
	customDecors += custom
	panel.selectBlueprint(custom)
	before_resources = builder.Res()
	panel.beginStroke(locate(384,281,builder.z))
	panel.commitStroke(locate(384,281,builder.z))
	var/obj/Turfs/Custom/custom_result = locate(/obj/Turfs/Custom) in locate(384,281,builder.z)
	nexusSmokeAssert(custom_result && custom_result.name == custom.name && custom_result.pixel_x == 7 && custom_result.Builder == "build-smoke" && builder.Res() == before_resources-customDecorBuildCost,"Custom decor did not use the cursor, appearance or configured cost")
	panel.selectBlueprint(decor)
	panel.brush_size = 3
	before_resources = builder.Res()
	panel.beginStroke(locate(382,281,builder.z))
	nexusSmokeAssert(panel.stroke_tiles.len == 9,"3x3 build brush has the wrong footprint")
	panel.commitStroke(null)
	nexusSmokeAssert(builder.Res() == before_resources && !panel.dragging,"Releasing outside the world committed a brush")
	panel.brush_size = 1
	before_resources = builder.Res()
	panel.beginStroke(locate(383,281,builder.z))
	panel.cancelStroke()
	panel.commitStroke(locate(383,281,builder.z))
	nexusSmokeAssert(builder.Res() == before_resources && !panel.preview_images.len,"Cancelled stroke committed or leaked its preview")
	panel.beginStroke(locate(383,281,builder.z))
	panel.setCategory("Walls")
	panel.commitStroke(locate(383,281,builder.z))
	nexusSmokeAssert(builder.Res() == before_resources,"Category change committed an old drag")
	panel.beginStroke(locate(383,281,builder.z))
	builder.last_attacked_time = max(1,world.time)
	panel.commitStroke(locate(383,281,builder.z))
	nexusSmokeAssert(builder.Res() == before_resources && builder.Target == combat_target,"Combat did not block a pending stroke or lost its target")
	builder.last_attacked_time = 0
	panel.selectBlueprint(decor)
	panel.beginStroke(locate(383,281,builder.z))
	builder.loc = locate(380,281,builder.z)
	panel.commitStroke(locate(383,281,builder.z))
	nexusSmokeAssert(builder.Res() == before_resources,"Moving the builder committed an old stroke")
	runBuildFinishingSmokeTests(panel,builder,test_area)
	panel.hide()
	nexusSmokeAssert(!builder.build_brush && !panel.active && !panel.preview_images.len && !panel.hover_images.len,"Closing the panel left the brush active")
	del(panel)
	del(builder)
	del(combat_target)
	Builds -= terrain
	Builds -= decor
	del(terrain)
	del(decor)
	customDecors -= custom
	del(custom)
	for(var/list/prior in originals)
		var/turf/current = locate(prior[1],prior[2],Z_LEVEL_CITY_INTERIORS)
		for(var/obj/Turfs/Custom/object in current)
			object.reallyDelete = TRUE
			del(object)
		var/original_type = prior[3]
		var/turf/restored = new original_type(current)
		restored.appearance = prior[4]
		var/area/original_area = prior[5]
		original_area.contents += restored
		restored.Water = prior[6]
	built_turfs["build-smoke"] = prior_built_turfs
	Built_Objs["buildsmoke"] = prior_built_objects
	del(test_area)
	world.log << "BUILD_BRUSH_SMOKE_PASSED: native palette reuse, cursor terrain/objects, drag deduplication, costs, cancellation, combat"

proc/runBuildFinishingSmokeTests(datum/NexusBuildWindow/panel,mob/NexusSmokeTest/BuildTools/builder,area/test_area)
	test_area.auto_cliffs = FALSE
	test_area.auto_edges = FALSE
	test_area.auto_waves = FALSE
	var/obj/Build/ground_blueprint = new
	ground_blueprint.Creates = /turf/Ground4
	ground_blueprint.icon = 'src/Icons/Turfs/Turfs12.dmi'
	ground_blueprint.icon_state = "desert"
	Builds += ground_blueprint
	panel.selectBlueprint(ground_blueprint)
	panel.brush_size = 3
	builder.build_auto_cliffs = TRUE
	builder.build_auto_edges = TRUE
	var/before_resources = builder.Res()
	var/turf/center = locate(388,286,builder.z)
	panel.brush_size = 5
	panel.updateHover(center)
	exportNexusBuildTerrainSmokePreview(panel,"BuildBrush5x5Smoke.png",386,283,5,6)
	panel.clearHover()
	panel.brush_size = 3
	panel.beginStroke(center)
	nexusSmokeAssert(panel.finishing_preview_images.len == 3 && builder.Res() == before_resources,"Drag preview omitted its cliff face or charged resources before release")
	panel.commitStroke(center)
	for(var/tile_x = 387, tile_x <= 389, tile_x++)
		for(var/tile_y = 285, tile_y <= 287, tile_y++)
			var/turf/ground = locate(tile_x,tile_y,builder.z)
			nexusSmokeAssert(istype(ground,/turf/Ground4) && ground.build_edges_enabled,"Finishing replaced the painted footprint with an internal cliff")
		var/turf/cliff = locate(tile_x,284,builder.z)
		nexusSmokeAssert(istype(cliff,/turf/Wall7) && cliff.Builder == "build-smoke" && (cliff in Turfs),"Enabled cliffs did not finish and save the southern land boundary")
	center = locate(388,286,builder.z)
	var/turf/corner = locate(387,287,builder.z)
	nexusSmokeAssert(!center.build_edge_overlays.len && corner.build_edge_overlays.len == 2,"Enabled edges missed a land boundary or drew seams inside the brush")
	var/border_count = corner.overlays.len
	refreshBuildEdgesAround(corner)
	nexusSmokeAssert(corner.overlays.len == border_count,"Refreshing land borders duplicated their edges")
	nexusSmokeAssert(builder.Res() == before_resources-1200,"Cliff finishing charged intermediate brush rows or omitted a final cliff cost")
	exportNexusBuildTerrainSmokePreview(panel,"BuildTerrainFinishingSmoke.png",386,283,5,6)
	var/turf/road = new /turf/EarthFloor/Road(locate(388,284,builder.z))
	var/turf/occupied = new /turf/GroundDirt(locate(387,284,builder.z))
	var/obj/Turfs/Custom/prop = new(occupied)
	var/turf/other_owner = new /turf/GroundDirt(locate(389,284,builder.z))
	other_owner.Builder = "another-builder"
	before_resources = builder.Res()
	for(var/tile_x = 387, tile_x <= 389, tile_x++) builder.placeBuildCliff(locate(tile_x,285,builder.z),TRUE)
	nexusSmokeAssert(istype(road,/turf/EarthFloor/Road) && prop.loc == occupied && other_owner.type == /turf/GroundDirt && builder.Res() == before_resources,"Cliff finishing replaced a road, an occupied tile or another owner's land")
	// Same material can form another terrace, as shown in the user's reference video.
	panel.brush_size = 1
	center = locate(388,286,builder.z)
	before_resources = builder.Res()
	panel.beginStroke(center)
	nexusSmokeAssert(panel.stroke_elevation == 2 && panel.finishing_preview_images.len == 1,"Nested same-material terrace lacks a raised preview")
	panel.commitStroke(center)
	center = locate(388,286,builder.z)
	var/turf/nested_cliff = locate(388,285,builder.z)
	nexusSmokeAssert(center.build_elevation == 2 && center.build_edge_overlays.len == 4 && istype(nested_cliff,/turf/Wall7) && nested_cliff.build_elevation == 1 && builder.Res() == before_resources-200,"Painting the same material failed to create the nested terrace from the reference")
	var/save_segment = 987654
	nexusSmokeAssert(!fexists(getMapSavePath(save_segment)),"Terrain save fixture would overwrite an existing segment")
	writeMapSaveSegment(save_segment,list(center.type,nested_cliff.type),list(1,1),list("build-smoke","build-smoke"),list(388,388),list(286,285),list(builder.z,builder.z),list(0,0),list(TRUE,FALSE),list(center.build_elevation,nested_cliff.build_elevation))
	var/savefile/terrain_save = new(getMapSavePath(save_segment))
	var/list/saved_elevations = terrain_save["BuildElevations"]
	nexusSmokeAssert(getSavedBuildElevation(saved_elevations,1) == 2 && getSavedBuildElevation(saved_elevations,2) == 1 && getSavedBuildElevation(null,1) == 0,"Saved terrace elevations were lost or old map segments cannot load")
	terrain_save = null
	fdel(getMapSavePath(save_segment))
	for(var/tile_x = 382, tile_x <= 384, tile_x++)
		for(var/tile_y = 287, tile_y <= 289, tile_y++) new /turf/Ground4(locate(tile_x,tile_y,builder.z))
	center = locate(383,288,builder.z)
	panel.beginStroke(center)
	panel.commitStroke(center)
	center = locate(383,288,builder.z)
	nexusSmokeAssert(center.build_elevation == 1 && center.build_edge_overlays.len == 4 && istype(locate(383,287,builder.z),/turf/Wall7),"A raised patch on matching base terrain has no visible boundary")
	builder.build_auto_cliffs = FALSE
	builder.build_auto_edges = FALSE
	panel.brush_size = 1
	center = locate(383,286,builder.z)
	panel.beginStroke(center)
	panel.commitStroke(center)
	center = locate(383,286,builder.z)
	nexusSmokeAssert(!center.build_edges_enabled && !center.build_edge_overlays && istype(locate(383,285,builder.z),/turf/GroundDirt),"Disabled finishing options still decorated a stroke")
	Builds -= ground_blueprint
	del(ground_blueprint)
	world.log << "BUILD_FINISHING_SMOKE_PASSED: same-material/nested terraces, live previews, saved elevations, 3x3 cliffs, costs, opt-out, protected features"

// Compose actual fixture icons for review without opening a graphical client.
proc/exportNexusBuildTerrainSmokePreview(datum/NexusBuildWindow/panel,filename,left,bottom,width,height)
	var/icon/result = icon('src/Icons/Unsorted/UserNamesBarsUi.png')
	result.Scale(width*32,height*32)
	for(var/tile_x = left, tile_x < left+width, tile_x++)
		for(var/tile_y = bottom, tile_y < bottom+height, tile_y++)
			var/turf/tile = locate(tile_x,tile_y,panel.owner.z)
			var/px = (tile_x-left)*32+1
			var/py = (tile_y-bottom)*32+1
			result.Blend(icon(tile.icon,tile.icon_state,tile.dir,1),ICON_OVERLAY,px,py)
			for(var/appearance_value in tile.overlays)
				if(appearance_value:icon) result.Blend(icon(appearance_value:icon,appearance_value:icon_state,appearance_value:dir,1),ICON_OVERLAY,px+appearance_value:pixel_x,py+appearance_value:pixel_y)
	var/list/preview_images = panel.hover_images + panel.preview_images + panel.finishing_preview_images
	for(var/image/preview in preview_images)
		var/px = (preview.x-left)*32+1
		var/py = (preview.y-bottom)*32+1
		var/icon/ghost = icon(preview.icon,preview.icon_state,preview.dir,1)
		ghost.Blend(rgb(255,255,255,preview.alpha),ICON_MULTIPLY)
		result.Blend(ghost,ICON_OVERLAY,px+preview.pixel_x,py+preview.pixel_y)
		for(var/appearance_value in preview.overlays)
			var/icon/overlay_icon = icon(appearance_value:icon,appearance_value:icon_state,appearance_value:dir,1)
			if(!(appearance_value:appearance_flags & RESET_ALPHA)) overlay_icon.Blend(rgb(255,255,255,preview.alpha),ICON_MULTIPLY)
			result.Blend(overlay_icon,ICON_OVERLAY,px+preview.pixel_x+appearance_value:pixel_x,py+preview.pixel_y+appearance_value:pixel_y)
	fcopy(icon(result,"",SOUTH,1),filename)

proc/runBuildPanelLayoutSmokeTests(datum/NexusBuildWindow/panel)
	var/control_count = panel.controls.len
	var/obj/NexusBuildControl/first_slot = panel.slots[1]
	for(var/list/viewport in list(list(1248,704),list(640,480),list(1248,352),list(320,320),list(210,260),list(1248,704)))
		panel.panel_x = 9999
		panel.panel_y = 9999
		panel.fitToViewport(viewport[1],viewport[2])
		nexusSmokeAssert(panel.panel_x >= 8 && panel.panel_y >= 8 && panel.panel_x+panel.panel_width <= viewport[1]-8 && panel.panel_y+panel.panel_height <= viewport[2]-8,"Build panel escaped the visible map after resizing/dragging")
		var/obj/NexusBuildControl/background = panel.background_control
		var/icon/backdrop = icon(background.icon)
		nexusSmokeAssert(backdrop.Width() == panel.panel_width && backdrop.Height() == panel.panel_height && backdrop.GetPixel(round(panel.panel_width/2),round(panel.panel_height/2)) == "#1c1914","Build panel lost its full opaque background")
		nexusSmokeAssert(background.screen_loc == "LEFT:[panel.panel_x],TOP:-[panel.panel_y]","Build background subtracts its height twice from TOP")
		var/list/visible_controls = list()
		for(var/obj/NexusBuildControl/control in panel.controls)
			if(control == background) continue
			if(control.invisibility)
				nexusSmokeAssert(!control.screen_loc && !control.mouse_opacity && !control.blueprint,"Hidden build slots remain visible, clickable or populated")
				continue
			var/left = round(control.offset_x*panel.panel_scale)
			var/top = round(control.offset_y*panel.panel_scale)
			if(control.label_text)
				assertNexusHudBitmapText(control.primary_text)
				nexusSmokeAssert(!control.maptext && control.maptext_y >= 0 && control.maptext_y+control.maptext_height <= control.render_height,"Build label has insufficient line space")
				if(control.action != "status") nexusSmokeAssert(control.maptext_height == control.render_height-4 && control.maptext_y == 2,"Build label does not use the available height of its button")
			nexusSmokeAssert(left >= 0 && top >= 0 && left+control.render_width <= panel.panel_width && top+control.render_height <= panel.panel_height,"Build control extends beyond its background")
			for(var/list/rect in visible_controls)
				nexusSmokeAssert(left >= rect[3] || left+control.render_width <= rect[1] || top >= rect[4] || top+control.render_height <= rect[2],"Build controls overlap after adapting the grid")
			visible_controls += list(list(left,top,left+control.render_width,top+control.render_height))
		var/obj/NexusBuildControl/status = panel.status_control
		nexusSmokeAssert(status.detail_text.pixel_y+status.detail_text.maptext_height <= status.maptext_y,"Build status lines overlap after resizing")
		nexusSmokeAssert(panel.controls.len == control_count && panel.slots[1] == first_slot,"Resizing recreated the native build controls")
	panel.status_control.setLabel("A very long blueprint name with <markup> that must fit\nDrag to paint; right-click cancels.")
	var/status_text = panel.status_control.primary_text.text_value
	nexusSmokeAssert(findtext(status_text,"<markup>") && findtext(panel.status_control.primary_text.rendered_text,"...") && findtext(panel.status_control.detail_text.rendered_text,"Drag to paint"),"Build status does not preserve literal text or truncate long names explicitly")
	assertNexusHudBitmapText(panel.status_control.primary_text)
	assertNexusHudBitmapText(panel.status_control.detail_text)
	var/obj/Build/thumbnail_fixture = new
	thumbnail_fixture.icon = 'src/Icons/UI/CustomDecor.dmi'
	var/icon/original_icon = icon(thumbnail_fixture.icon)
	var/icon/thumbnail = getBuildThumbnail(thumbnail_fixture)
	nexusSmokeAssert(thumbnail.Width() == original_icon.Width() && thumbnail.Height() == original_icon.Height() && first_slot.render_width-8 >= thumbnail.Width() && first_slot.render_height-6 >= thumbnail.Height(),"Compact build panel shrinks or clips native 32px thumbnails")
	del(thumbnail_fixture)
	panel.panel_x = 8
	panel.panel_y = 56
	panel.clampPosition()
	panel.refreshStatus()
	exportNexusBuildPanelSmokePreview(panel)
	world.log << "BUILD_PANEL_LAYOUT_SMOKE_PASSED: opaque background, TOP anchor, viewport fit, no overlapping controls, native thumbnails, reuse"

proc/exportNexusBuildPanelSmokePreview(datum/NexusBuildWindow/panel)
	var/icon/preview = icon(panel.background_control.icon)
	for(var/obj/NexusBuildControl/control in panel.controls)
		if(control == panel.background_control || control.invisibility) continue
		var/draw_x = control.offset_x+1
		var/draw_y = panel.panel_height-control.offset_y-control.render_height+1
		preview.Blend(control.icon,ICON_OVERLAY,draw_x,draw_y)
		if(control.blueprint)
			var/icon/thumb = getBuildThumbnail(control.blueprint)
			if(thumb) preview.Blend(thumb,ICON_OVERLAY,draw_x+round((control.render_width-thumb.Width())/2),draw_y+round((control.render_height-thumb.Height())/2))
		for(var/obj/NexusHudBitmapText/label in control.vis_contents)
			if(label.icon) preview.Blend(label.icon,ICON_OVERLAY,draw_x+label.pixel_x,draw_y+label.pixel_y)
	// Animated terrain can give the composite several frames; export one review image.
	fcopy(icon(preview,"",SOUTH,1),"BuildPanelTextSmoke.png")
