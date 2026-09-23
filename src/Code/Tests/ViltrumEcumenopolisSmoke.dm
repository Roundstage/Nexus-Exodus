proc/runViltrumEcumenopolisStartupSmokeTests()
	var/mob/NexusSmokeTest/traveler = new(locate(VILTRUM_LANDING_X,VILTRUM_LANDING_Y,Z_LEVEL_VILTRUM))
	var/entrances = 0
	for(var/obj/CityBuildingDoor/ViltrumCity/door in city_building_doors.Copy())
		if(door.z != Z_LEVEL_VILTRUM) continue
		entrances++
		var/turf/street = locate(door.x,door.y-1,door.z)
		var/turf/inside = locate(door.target_x,door.target_y,door.target_z)
		nexusSmokeAssert(street && !street.density && inside && !inside.density, "Viltrum doorway approach or interior is blocked")
		if(!street || !inside) continue
		traveler.SafeTeleport(street)
		nexusSmokeAssert(!door.isValidDestination(locate(SUPER_EARTH_LANDING_X,SUPER_EARTH_LANDING_Y,Z_LEVEL_SUPER_EARTH)), "Viltrum entry accepts Earth as an interior")
		var/turf/earth_interior = locate(10,130,Z_LEVEL_CITY_INTERIORS)
		for(var/obj/CityBuildingDoor/Earth/earth_door in city_building_doors)
			if(earth_door.z == Z_LEVEL_SUPER_EARTH)
				earth_interior = locate(earth_door.target_x,earth_door.target_y,earth_door.target_z)
				break
		nexusSmokeAssert(!door.isValidDestination(earth_interior), "Viltrum entry accepts an Earth room on the correct Z")
		traveler.KO = TRUE
		nexusSmokeAssert(!door.travel(traveler), "KO player entered a Viltrum house")
		traveler.KO = FALSE
		traveler.KB = TRUE
		nexusSmokeAssert(!door.travel(traveler), "Knockback triggered a Viltrum doorway")
		traveler.KB = FALSE
		step(traveler,NORTH)
		nexusSmokeAssert(traveler.loc == inside && traveler.z == Z_LEVEL_CITY_INTERIORS, "Walking through a mapped Viltrum doorway failed")
		nexusSmokeAssert(getNexusPlanetControlId(traveler) == "viltrum", "Viltrum interior lost planet context")
		var/obj/CityBuildingDoor/Exit/ViltrumCity/return_door
		for(var/obj/CityBuildingDoor/Exit/ViltrumCity/candidate in city_building_doors)
			if(candidate.building_id == door.building_id)
				return_door = candidate
				break
		nexusSmokeAssert(return_door, "Viltrum interior lacks its return portal")
		if(return_door)
			traveler.SafeTeleport(locate(return_door.x,return_door.y+1,return_door.z))
			nexusSmokeAssert(!return_door.isValidDestination(locate(SUPER_EARTH_LANDING_X,SUPER_EARTH_LANDING_Y,Z_LEVEL_SUPER_EARTH)), "Viltrum return accepts Earth")
			step(traveler,SOUTH)
			nexusSmokeAssert(traveler.loc == street && getNexusPlanetControlId(traveler) == "viltrum", "Viltrum return did not reach its own street")
		traveler.SafeTeleport(locate(VILTRUM_LANDING_X,VILTRUM_LANDING_Y,Z_LEVEL_VILTRUM))
		if(get_dist(traveler,door)>1) nexusSmokeAssert(!door.travel(traveler), "Viltrum doorway allows remote entry")
	nexusSmokeAssert(entrances == 37, "Viltrum city lost existing accessible interiors")
	var/structures = 0
	for(var/turf/ViltrumCityStructure/structure in block(locate(1,1,Z_LEVEL_VILTRUM),locate(500,500,Z_LEVEL_VILTRUM)))
		structures++
		nexusSmokeAssert(structure.density && structure.opacity && !structure.FlyOverAble, "City structure does not follow the structural roof convention")
		if(structures == 1)
			nexusSmokeAssert(!structure.Enter(traveler), "City structure allows walking")
			traveler.Flying = TRUE
			nexusSmokeAssert(!structure.Enter(traveler), "City structure allows flight bypass")
			traveler.KB = TRUE
			nexusSmokeAssert(!structure.Enter(traveler), "City structure allows knockback bypass")
			traveler.Flying = FALSE
			traveler.KB = FALSE
			var/icon/tile_art = icon(structure.icon,structure.icon_state)
			nexusSmokeAssert(tile_art.Width() == 32 && tile_art.Height() == 32 && structure.underlays.len, "Structure lacks independent 32px art and ground")
	nexusSmokeAssert(structures > 25000, "Ecumenopolis is missing its mapped buildings")
	del(traveler)
	runViltrumTerrainGenerationSmokeTests()
	world.log << "VILTRUM_ECUMENOPOLIS_PASSED: [entrances] mapped door round trips; [structures] structural tiles"

proc/runViltrumTerrainGenerationSmokeTests()
	var/list/before_columns = list()
	for(var/tile_x = 1, tile_x <= 500, tile_x++)
		before_columns += getAuthoredTerrainSmokeColumn(tile_x,Z_LEVEL_VILTRUM)
		if(world.tick_usage > 60) sleep(world.tick_lag)
	var/shore_count = 0
	for(var/turf/ground in block(locate(1,1,Z_LEVEL_VILTRUM),locate(500,500,Z_LEVEL_VILTRUM)))
		ground.GenerateEdges()
		ground.GenerateShoreWaves()
		if(ground.Water || ground.density) continue
		var/turf/water = get_step(ground,SOUTH)
		if(water && water.Water)
			shore_count++
			ground.GenerateCliffs()
	var/list/saved_zones = generated_zones.Copy()
	var/mob/NexusSmokeTest/visitor = new(locate(1,1,Z_LEVEL_VILTRUM))
	for(var/zone_x = 1, zone_x <= 4, zone_x++)
		for(var/zone_y = 1, zone_y <= 4, zone_y++)
			visitor.loc = locate((zone_x-1)*125+1,(zone_y-1)*125+1,Z_LEVEL_VILTRUM)
			var/zone = GetZoneNum(visitor)
			generated_zones -= zone
			GenerateZone(zone)
	generated_zones = saved_zones
	del(visitor)
	for(var/tile_x = 1, tile_x <= 500, tile_x++)
		nexusSmokeAssert(before_columns[tile_x] == getAuthoredTerrainSmokeColumn(tile_x,Z_LEVEL_VILTRUM), "Runtime cliffs/edges/waves changed authored Viltrum column [tile_x]")
		if(world.tick_usage > 60) sleep(world.tick_lag)
	nexusSmokeAssert(shore_count > 100, "Viltrum shoreline regression has no coastline coverage")
	world.log << "VILTRUM_TERRAIN_GENERATION_PASSED: 250000 tiles, 16 zones, [shore_count] shorelines unchanged"
