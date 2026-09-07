proc/runViltrumPlanetStartupSmokeTests()
	runViltrumSliceStartupSmokeTests()
	var/list/saved_disabled = disabled_planets.Copy()
	var/list/saved_destroyed = destroyed_planets.Copy()
	var/saved_earth_only = Earth_Only
	Earth_Only = FALSE
	disabled_planets -= "Viltrum"
	disabled_planets -= "Earth"
	destroyed_planets -= "Viltrum"
	destroyed_planets -= "Earth"
	unhide_restored_planets("Viltrum")
	var/obj/Planets/Viltrum/planet = initializeViltrumPlanet()
	nexusSmokeAssert(planet && planet.z == Z_LEVEL_SPACE && planet.Planet_Z == Z_LEVEL_VILTRUM, "Viltrum is not discoverable in space")
	var/planet_count = 0
	for(var/obj/Planets/Viltrum/candidate in planets)
		if(candidate.z || candidate.planet_turf) planet_count++
	nexusSmokeAssert(planet_count == 1, "Viltrum initialization duplicated its space object")
	var/turf/surface = locate(250, 250, Z_LEVEL_VILTRUM)
	var/turf/corner = locate(500, 500, Z_LEVEL_VILTRUM)
	nexusSmokeAssert(surface && istype(surface.loc, /area/Viltrum) && corner && istype(corner.loc, /area/Viltrum), "Viltrum surface is missing or uses the wrong global Z")
	nexusSmokeAssert(resolveNexusPlanetMapRegion(Z_LEVEL_VILTRUM, /area/Viltrum, 250, 250), "Viltrum is absent from the planetary scanner")
	var/mob/NexusSmokeTest/traveler = new(surface)
	for(var/race_name in list("Viltrumite", "Half-Viltrumite"))
		traveler.Race = race_name
		traveler.Spawn_Bind = null
		var/list/spawns = traveler.Get_spawns()
		nexusSmokeAssert(spawns.len > 0, "[race_name] has no Viltrum spawn")
		for(var/obj/Spawn/spawn_point in spawns)
			nexusSmokeAssert(spawn_point.z == Z_LEVEL_VILTRUM && spawn_point.name == "Viltrumite", "[race_name] still uses another race's homeworld")
	if(planet)
		Bump_Planet(planet, traveler)
		nexusSmokeAssert(traveler.z == Z_LEVEL_VILTRUM && abs(traveler.x - VILTRUM_LANDING_X) <= 10 && abs(traveler.y - VILTRUM_LANDING_Y) <= 10, "Viltrum landing missed the spaceport")
		Liftoff(traveler)
		nexusSmokeAssert(traveler.z == Z_LEVEL_SPACE, "Viltrum cannot launch travelers back to space")
		disabled_planets |= "Viltrum"
		hide_destroyed_planets("Viltrum")
		nexusSmokeAssert(!planet.z && planet.planet_turf, "Disabling Viltrum did not hide its space object")
		traveler.SafeTeleport(surface)
		traveler.Spawn_Bind = "Viltrum"
		var/list/fallback_spawns = traveler.Get_spawns()
		nexusSmokeAssert(fallback_spawns.len > 0, "Disabled Viltrum has no Earth fallback")
		for(var/obj/Spawn/spawn_point in fallback_spawns)
			nexusSmokeAssert(spawn_point.z == Z_LEVEL_EARTH && spawn_point.name == "Human", "Disabled Viltrum falls back to Saiyan or disabled spawns")
		disabled_planets -= "Viltrum"
		unhide_restored_planets("Viltrum")
		nexusSmokeAssert(planet.z == Z_LEVEL_SPACE && !planet.planet_turf, "Re-enabling Viltrum did not restore its space object")
	del(traveler)
	Earth_Only = saved_earth_only
	disabled_planets = saved_disabled
	destroyed_planets = saved_destroyed
	hide_destroyed_planets("Viltrum")
