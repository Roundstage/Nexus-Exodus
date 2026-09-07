/var/const
	SUPER_EARTH_LANDING_X = 101
	SUPER_EARTH_LANDING_Y = 362

area/SuperEarth
	name = "Super Terra"
	auto_cliffs = FALSE
	auto_edges = FALSE
	auto_waves = FALSE
	has_resources = 1
	resource_refill_mod = 2000
	has_daynight_cycle = 1
	can_planet_destroy = 0
	can_has_dragonballs = 0

obj/Planets/SuperEarth
	name = "Super Terra"
	icon_state = "Earth"
	Planet_X = SUPER_EARTH_LANDING_X
	Planet_Y = SUPER_EARTH_LANDING_Y
	Planet_Z = Z_LEVEL_SUPER_EARTH
	Nav_Level = 0
	New()
		. = ..()
		CenterIcon(src)
		walk_rand(src, 100)

proc/initializeSuperEarthPlanet()
	var/turf/surface = locate(SUPER_EARTH_LANDING_X, SUPER_EARTH_LANDING_Y, Z_LEVEL_SUPER_EARTH)
	if(!surface || !istype(surface.loc, /area/SuperEarth)) return
	for(var/obj/Planets/SuperEarth/planet in planets)
		if(planet.z || planet.planet_turf) return planet
	var/turf/center = locate(150, 350, Z_LEVEL_SPACE)
	if(!center) return
	for(var/turf/Other/Stars/position in range(30, center))
		if(position.density || !istype(position.loc, /area/Space)) continue
		var/blocked = FALSE
		for(var/atom/movable/occupant in position)
			if(occupant.density)
				blocked = TRUE
				break
		if(!blocked)
			var/obj/Planets/SuperEarth/planet = new(position)
			hide_destroyed_planets("Super Terra")
			return planet

proc/getSuperEarthRacialSpawns(race_name)
	var/list/spawns = list()
	if(isViltrumiteSpawnRace(race_name)) return spawns
	for(var/obj/Spawn/spawn_point in Spawn_List)
		if(spawn_point.z == Z_LEVEL_SUPER_EARTH && spawn_point.name == race_name && !spawn_point.is_on_destroyed_planet()) spawns += spawn_point
	return spawns
