proc/runEarthCityStartupSmokeTests()
	runEarthTerrainGenerationSmokeTests()
	runEarthBoundaryStartupSmokeTests()
	runCityBuildingStartupSmokeTests()
	runEarthNaturalLandmarkStartupSmokeTests()
	for(var/tile_x = SUPER_EARTH_LANDING_X - 10, tile_x <= SUPER_EARTH_LANDING_X + 10, tile_x++)
		for(var/tile_y = SUPER_EARTH_LANDING_Y - 10, tile_y <= SUPER_EARTH_LANDING_Y + 10, tile_y++)
			var/turf/arrival = locate(tile_x,tile_y,Z_LEVEL_SUPER_EARTH)
			nexusSmokeAssert(arrival && !arrival.density && !arrival.Water, "Earth arrival lawn contains blocked terrain")
			if(arrival)
				for(var/atom/movable/occupant in arrival) nexusSmokeAssert(!occupant.density, "Earth arrival lawn contains a dense object")
	for(var/list/field in list(list(160,259,189,288),list(63,230,92,259),list(320,269,349,298)))
		for(var/tile_x = field[1], tile_x <= field[3], tile_x++)
			for(var/tile_y = field[2], tile_y <= field[4], tile_y++)
				var/turf/combat_floor = locate(tile_x,tile_y,Z_LEVEL_SUPER_EARTH)
				nexusSmokeAssert(combat_floor && !combat_floor.density, "Earth city combat terrain is obstructed")
				if(combat_floor)
					for(var/atom/movable/occupant in combat_floor) nexusSmokeAssert(!occupant.density, "Earth city combat floor contains a dense object")
	for(var/list/fall in list(list(139,350),list(368,342),list(184,96)))
		var/turf/waterfall = locate(fall[1],fall[2],Z_LEVEL_SUPER_EARTH)
		nexusSmokeAssert(istype(waterfall,/turf/WaterFall), "Earth authored city erased a waterfall")
	// The user revised the mapped city's ground under its exterior objects.
	// Check the real hospital object, and probe structural behavior in an empty
	// interior slot without restoring old roofs over their approved city edits.
	var/obj/EarthHouse/Hospital/hospital = locate() in locate(54,340,Z_LEVEL_SUPER_EARTH)
	nexusSmokeAssert(hospital, "Approved Earth hospital exterior is missing")
	var/turf/prior_floor = locate(398,298,Z_LEVEL_CITY_INTERIORS)
	var/prior_type = prior_floor.type
	var/turf/hospital_roof = new /turf/EarthBuildingStructure(prior_floor)
	var/mob/NexusSmokeTest/roof_probe = new(locate(397,298,Z_LEVEL_CITY_INTERIORS))
	roof_probe.Flying = TRUE
	nexusSmokeAssert(istype(hospital_roof,/turf/EarthBuildingStructure) && hospital_roof.density && hospital_roof.opacity && !hospital_roof.Enter(roof_probe), "Earth building structure must remain solid and sight blocking")
	var/icon/structural_art = icon(hospital_roof.icon,hospital_roof.icon_state)
	nexusSmokeAssert(structural_art.Width() == 32 && structural_art.Height() == 32, "Earth structures must display per turf even when the exterior object anchor is hidden")
	del(roof_probe)
	new prior_type(hospital_roof)
	var/legacy_bridges = 0
	for(var/turf/EarthBridge/bridge in block(locate(1,1,Z_LEVEL_SUPER_EARTH),locate(500,500,Z_LEVEL_SUPER_EARTH)))
		legacy_bridges++
	nexusSmokeAssert(!legacy_bridges, "Retired regional causeways remain on Earth")
	for(var/list/position in list(list(250,398),list(250,414),list(110,170),list(160,170)))
		var/turf/ocean = locate(position[1],position[2],Z_LEVEL_SUPER_EARTH)
		// Water2 uses swimming/flight entry hooks, not a dense turf flag.
		nexusSmokeAssert(istype(ocean,/turf/EarthRiver) && ocean.Water, "An ocean causeway was not restored to water")
	for(var/list/position in list(list(367,413),list(356,380),list(388,302),list(372,267),list(391,221),list(381,174),list(190,119),list(203,71)))
		var/turf/river = locate(position[1],position[2],Z_LEVEL_SUPER_EARTH)
		nexusSmokeAssert(istype(river,/turf/EarthRiver) && river.Water, "Grass cuts an authored river segment or source lake")

proc/runEarthBoundaryStartupSmokeTests()
	var/turf/landing = locate(SUPER_EARTH_LANDING_X,SUPER_EARTH_LANDING_Y,Z_LEVEL_SUPER_EARTH)
	var/mob/NexusSmokeTest/boundary_probe = new(landing)
	for(var/list/edge in list(list(1,1),list(1,250),list(1,500),list(250,500),list(500,500),list(500,250),list(500,1),list(250,1)))
		var/turf/boundary = locate(edge[1],edge[2],Z_LEVEL_SUPER_EARTH)
		nexusSmokeAssert(istype(boundary,/turf/EarthOceanBoundary), "Earth edge lacks its ocean boundary")
		boundary_probe.Flying = FALSE
		boundary_probe.KB = FALSE
		nexusSmokeAssert(!boundary.Enter(boundary_probe), "Earth boundary allows walking")
		boundary_probe.Flying = TRUE
		boundary_probe.KB = TRUE
		nexusSmokeAssert(!boundary.Enter(boundary_probe), "Earth boundary allows flight or knockback")
		boundary_probe.SafeTeleport(boundary)
		nexusSmokeAssert(boundary_probe.loc == landing, "Earth boundary teleport did not return to the safe arrival lawn")
	del(boundary_probe)
