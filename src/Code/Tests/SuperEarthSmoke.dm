proc/runSuperEarthStartupSmokeTests()
	runEarthCityStartupSmokeTests()
	var/list/saved_disabled = disabled_planets.Copy()
	var/list/saved_destroyed = destroyed_planets.Copy()
	var/saved_earth_only = Earth_Only
	Earth_Only = FALSE
	disabled_planets -= "Super Terra"
	destroyed_planets -= "Super Terra"
	unhide_restored_planets("Super Terra")
	var/obj/Planets/SuperEarth/planet = initializeSuperEarthPlanet()
	nexusSmokeAssert(planet && planet.z == Z_LEVEL_SPACE && planet.Planet_Z == Z_LEVEL_SUPER_EARTH, "Super Terra is not discoverable in space")
	var/planet_count = 0
	for(var/obj/Planets/SuperEarth/candidate in planets)
		if(candidate.z || candidate.planet_turf) planet_count++
	nexusSmokeAssert(planet_count == 1, "Super Terra initialization duplicated its planet")
	var/turf/surface = locate(250, 250, Z_LEVEL_SUPER_EARTH)
	var/turf/corner = locate(500, 500, Z_LEVEL_SUPER_EARTH)
	nexusSmokeAssert(surface && istype(surface.loc, /area/SuperEarth) && corner && istype(corner.loc, /area/SuperEarth), "Super Terra map bounds or global Z are wrong")
	nexusSmokeAssert(resolveNexusPlanetMapRegion(Z_LEVEL_SUPER_EARTH, /area/SuperEarth, 250, 250), "Super Terra is missing from scanner")
	var/mob/NexusSmokeTest/traveler = new(surface)
	for(var/race_name in Race_List())
		if(isViltrumiteSpawnRace(race_name))
			nexusSmokeAssert(!getSuperEarthRacialSpawns(race_name).len, "Viltrumites received Super Terra racial spawns")
			continue
		traveler.Race = race_name
		traveler.Spawn_Bind = null
		var/list/spawns = traveler.Get_spawns()
		nexusSmokeAssert(spawns.len > 0, "Super Terra is missing [race_name]")
		for(var/obj/Spawn/spawn_point in spawns)
			var/turf/spawn_turf = spawn_point.loc
			nexusSmokeAssert(spawn_turf && !spawn_turf.density, "Super Terra spawn is on blocked terrain: [race_name]")
			nexusSmokeAssert(spawn_point.z == Z_LEVEL_SUPER_EARTH && spawn_point.name == race_name, "[race_name] does not prefer its Super Terra spawn")
	if(planet)
		Bump_Planet(planet, traveler)
		nexusSmokeAssert(traveler.z == Z_LEVEL_SUPER_EARTH && abs(traveler.x - SUPER_EARTH_LANDING_X) <= 10 && abs(traveler.y - SUPER_EARTH_LANDING_Y) <= 10, "Super Terra arrival missed the spaceport")
		Liftoff(traveler)
		nexusSmokeAssert(traveler.z == Z_LEVEL_SPACE, "Super Terra liftoff failed")
		disabled_planets |= "Super Terra"
		hide_destroyed_planets("Super Terra")
		nexusSmokeAssert(!planet.z && planet.planet_turf && !getSuperEarthRacialSpawns("Human").len, "Disabled Super Terra remains accessible through racial spawns")
		disabled_planets -= "Super Terra"
		unhide_restored_planets("Super Terra")
		nexusSmokeAssert(planet.z == Z_LEVEL_SPACE && getSuperEarthRacialSpawns("Human").len, "Super Terra re-enable failed")
	del(traveler)
	Earth_Only = saved_earth_only
	disabled_planets = saved_disabled
	destroyed_planets = saved_destroyed
	hide_destroyed_planets("Super Terra")
