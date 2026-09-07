// Exercise the runtime decorator, which only starts visiting Earth zones when
// a player enters them. A startup map/preview check alone misses this mutation.
proc/runEarthTerrainGenerationSmokeTests()
	var/list/before_columns = list()
	for(var/tile_x = 1, tile_x <= 500, tile_x++)
		before_columns += getEarthTerrainSmokeColumn(tile_x)
		if(world.tick_usage > 60) sleep(world.tick_lag)
	var/shore_count = 0
	for(var/turf/ground in block(locate(1,1,Z_LEVEL_SUPER_EARTH),locate(500,500,Z_LEVEL_SUPER_EARTH)))
		ground.GenerateEdges()
		ground.GenerateShoreWaves()
		if(ground.Water || ground.density || !ground.auto_cliff || !ground.cliff_type) continue
		var/turf/water = get_step(ground,SOUTH)
		if(!water || !water.Water) continue
		shore_count++
		ground.GenerateCliffs()
	nexusSmokeAssert(shore_count > 100, "Earth cliff regression did not exercise real shorelines")
	var/list/saved_zones = generated_zones.Copy()
	var/mob/NexusSmokeTest/visitor = new(locate(1,1,Z_LEVEL_SUPER_EARTH))
	for(var/zone_x = 1, zone_x <= 4, zone_x++)
		for(var/zone_y = 1, zone_y <= 4, zone_y++)
			visitor.loc = locate((zone_x-1)*125+1,(zone_y-1)*125+1,Z_LEVEL_SUPER_EARTH)
			var/zone = GetZoneNum(visitor)
			generated_zones -= zone
			GenerateZone(zone)
	generated_zones = saved_zones
	del(visitor)
	for(var/tile_x = 1, tile_x <= 500, tile_x++)
		nexusSmokeAssert(before_columns[tile_x] == getEarthTerrainSmokeColumn(tile_x), "Runtime decoration changed Earth terrain or shoreline overlays in column [tile_x]")
		if(world.tick_usage > 60) sleep(world.tick_lag)
	runCliffAreaBoundarySmokeTests()
	world.log << "EARTH_TERRAIN_GENERATION_PASSED: 250000 tiles, 16 zones, [shore_count] shorelines, edge/wave overlays unchanged"

proc/getEarthTerrainSmokeColumn(tile_x)
	var/list/tiles = list()
	for(var/tile_y = 1, tile_y <= 500, tile_y++)
		var/turf/tile = locate(tile_x,tile_y,Z_LEVEL_SUPER_EARTH)
		var/list/shore_overlays = list()
		for(var/appearance_value in tile.overlays)
			var/icon_path = "[appearance_value:icon]"
			if(findtext(icon_path,"src/Icons/Turfs/Edges/") == 1 || findtext(icon_path,"src/Icons/Turfs/Surf/") == 1)
				shore_overlays += "[icon_path]:[appearance_value:icon_state]:[appearance_value:dir]:[appearance_value:pixel_x]:[appearance_value:pixel_y]"
		var/shore_signature = jointext(shore_overlays,";")
		tiles += "[tile.type]|[tile.icon]|[tile.icon_state]|[tile.dir]|[tile.density]|[tile.opacity]|[tile.Water]|[tile.loc.type]|[tile.wave_icon_applied]|[shore_signature]"
	return md5(jointext(tiles,"\n"))

// Use an empty interior slot and temporary areas to cover a legacy source
// beside protected water or protected southern ground, then restore the slot.
proc/runCliffAreaBoundarySmokeTests()
	var/area/legacy_area = new /area
	var/area/protected_area = new /area
	protected_area.auto_cliffs = FALSE
	var/list/originals = list()
	for(var/tile_y = 294, tile_y <= 296, tile_y++)
		var/turf/original = locate(398,tile_y,Z_LEVEL_CITY_INTERIORS)
		originals += list(list(original.type,original.appearance,original.loc,original.Water))
	var/turf/ground = new /turf/GroundDirt(locate(398,296,Z_LEVEL_CITY_INTERIORS))
	var/turf/water = new /turf/Water2(locate(398,295,Z_LEVEL_CITY_INTERIORS))
	var/turf/south_ground = new /turf/EarthFloor/Road(locate(398,294,Z_LEVEL_CITY_INTERIORS))
	runShoreOverlayAreaSmokeTests(ground,water,legacy_area,protected_area)
	legacy_area.contents += ground
	protected_area.contents += water
	legacy_area.contents += south_ground
	ground.GenerateCliffs()
	nexusSmokeAssert(istype(locate(398,295,Z_LEVEL_CITY_INTERIORS),/turf/Water2) && istype(locate(398,294,Z_LEVEL_CITY_INTERIORS),/turf/EarthFloor/Road), "Legacy cliffs crossed into protected water")
	legacy_area.contents += water
	protected_area.contents += south_ground
	ground.GenerateCliffs()
	nexusSmokeAssert(istype(locate(398,295,Z_LEVEL_CITY_INTERIORS),/turf/Water2) && istype(locate(398,294,Z_LEVEL_CITY_INTERIORS),/turf/EarthFloor/Road), "Legacy cliffs flooded protected southern ground")
	legacy_area.contents += south_ground
	ground.GenerateCliffs()
	nexusSmokeAssert(istype(locate(398,295,Z_LEVEL_CITY_INTERIORS),/turf/Wall7) && istype(locate(398,294,Z_LEVEL_CITY_INTERIORS),/turf/Water2), "Legacy maps lost their configured cliff generation")
	for(var/tile_y = 294, tile_y <= 296, tile_y++)
		var/list/original = originals[tile_y-293]
		var/original_type = original[1]
		var/turf/restored = new original_type(locate(398,tile_y,Z_LEVEL_CITY_INTERIORS))
		restored.appearance = original[2]
		var/area/original_area = original[3]
		original_area.contents += restored
		restored.Water = original[4]
	del(legacy_area)
	del(protected_area)

proc/runShoreOverlayAreaSmokeTests(turf/ground,turf/water,area/legacy_area,area/protected_area)
	protected_area.auto_edges = FALSE
	protected_area.auto_waves = FALSE
	protected_area.contents += ground
	legacy_area.contents += water
	ground.do_south_edge = TRUE
	// Keep a legitimate existing overlay: disabling auto-decoration must not
	// clear authored appearances or unrelated shadows.
	ground.overlays += ambient_occlusion
	var/prior_appearance = ground.appearance
	var/list/prior_overlays = ground.overlays.Copy()
	ground.GenerateEdges()
	ground.GenerateShoreWaves()
	nexusSmokeAssert(ground.appearance == prior_appearance && !water.wave_icon_applied, "Protected ground received automatic edges/waves or lost its existing overlay")
	legacy_area.contents += ground
	protected_area.contents += water
	ground.GenerateShoreWaves()
	nexusSmokeAssert(ground.appearance == prior_appearance && !water.wave_icon_applied, "Legacy waves crossed into protected water")
	legacy_area.contents += water
	ground.GenerateEdges()
	nexusSmokeAssert(ground.overlays.len == prior_overlays.len+1, "Legacy maps lost their configured shoreline edges")
	ground.GenerateShoreWaves()
	nexusSmokeAssert(ground.overlays.len == prior_overlays.len+2 && water.wave_icon_applied == water.wave_icon, "Legacy maps lost their configured shore waves")
	ground.do_south_edge = FALSE
	ground.overlays = prior_overlays
	water.wave_icon_applied = null
