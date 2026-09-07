// Integration coverage for actual mapped doors, including Crossed travel.
proc/runCityBuildingStartupSmokeTests()
	var/mob/NexusSmokeTest/traveler = new(locate(SUPER_EARTH_LANDING_X,SUPER_EARTH_LANDING_Y,Z_LEVEL_SUPER_EARTH))
	var/earth_doors = 0
	for(var/obj/CityBuildingDoor/Earth/door in city_building_doors.Copy())
		if(door.z != Z_LEVEL_SUPER_EARTH) continue
		earth_doors++
		var/turf/street = locate(door.x,door.y-1,door.z)
		var/turf/inside = locate(door.target_x,door.target_y,door.target_z)
		nexusSmokeAssert(street && !street.density && inside && !inside.density && istype(inside.loc,/area/CityInterior/Earth), "Earth door lacks its street or private interior")
		if(!street || !inside) continue
		traveler.SafeTeleport(street)
		// Reproduce the reported wrong-world destination using clear Viltrum
		// landing turf. A density check alone must not accept this redirect.
		var/saved_target_x = door.target_x
		var/saved_target_y = door.target_y
		var/saved_target_z = door.target_z
		door.target_x = VILTRUM_LANDING_X
		door.target_y = VILTRUM_LANDING_Y
		door.target_z = Z_LEVEL_VILTRUM
		nexusSmokeAssert(!door.travel(traveler) && traveler.loc == street,"Earth interior door sent a player to Viltrum")
		door.target_x = saved_target_x
		door.target_y = saved_target_y
		door.target_z = saved_target_z
		traveler.KO = TRUE
		nexusSmokeAssert(!door.travel(traveler) && traveler.loc == street, "Knocked-out player entered a house")
		traveler.KO = FALSE
		traveler.KB = TRUE
		nexusSmokeAssert(!door.travel(traveler), "Knockback triggered an interior transfer")
		traveler.KB = FALSE
		// Step onto the actual threshold: this exercises engine Crossed dispatch.
		step(traveler,NORTH)
		nexusSmokeAssert(traveler.loc == inside && traveler.z == Z_LEVEL_CITY_INTERIORS, "Walking through a mapped Earth doorway failed")
		nexusSmokeAssert(getNexusPlanetControlId(traveler) == "super_earth", "Earth interior lost its planet context")
		var/obj/CityBuildingDoor/Earth/Exit/return_door
		for(var/obj/CityBuildingDoor/Earth/Exit/candidate in city_building_doors)
			if(candidate.building_id == door.building_id)
				return_door = candidate
				break
		nexusSmokeAssert(return_door, "Earth interior has no return door")
		if(return_door)
			traveler.SafeTeleport(locate(return_door.x,return_door.y+1,return_door.z))
			nexusSmokeAssert(!return_door.isValidDestination(locate(VILTRUM_LANDING_X,VILTRUM_LANDING_Y,Z_LEVEL_VILTRUM)),"Earth interior exit accepts the wrong planet")
			step(traveler,SOUTH)
			nexusSmokeAssert(traveler.loc == street, "Interior exit did not return to its own street")
			nexusSmokeAssert(getNexusPlanetControlId(traveler) == "super_earth", "Return door lost Earth context")
		traveler.SafeTeleport(locate(SUPER_EARTH_LANDING_X,SUPER_EARTH_LANDING_Y,Z_LEVEL_SUPER_EARTH))
		if(get_dist(traveler,door)>1) nexusSmokeAssert(!door.travel(traveler), "Building door permits remote entry")
	nexusSmokeAssert(earth_doors == 29, "Approved Earth city is missing mapped entrances")
	for(var/turf/EarthStreet/Bridge/bridge in block(locate(110,300,Z_LEVEL_SUPER_EARTH),locate(150,410,Z_LEVEL_SUPER_EARTH)))
		if(istype(bridge,/turf/EarthStreet/Bridge/North) || istype(bridge,/turf/EarthStreet/Bridge/South))
			nexusSmokeAssert(bridge.density && !bridge.opacity, "Bridge parapet must stop walking without hiding the river")
		else nexusSmokeAssert(!bridge.density && bridge.Enter(traveler), "Bridge deck or pedestrian pavement blocks walking")
	del(traveler)
