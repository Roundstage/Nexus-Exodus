/var/const
	VILTRUM_LANDING_X = 250
	VILTRUM_LANDING_Y = 78

/area/Viltrum
	name = "Viltrum"
	has_resources = 1
	resource_refill_mod = 1000
	has_daynight_cycle = 1
	can_has_dragonballs = 0
	can_planet_destroy = 0

/obj/Planets/Viltrum
#ifdef SPACEMAN_DMM
	// The map-only parser loses these inherited fields across the intervening
	// legacy includes. Explicit editor fields keep the real assignments below.
	// BYOND excludes this block and inherits the original /obj/Planets fields.
	var/Planet_X
	var/Planet_Y
	var/Planet_Z
	var/Nav_Level
#endif
	name = "Viltrum"
	icon_state = "Vegeta"
	color = "#d6b8a4"
	Planet_X = VILTRUM_LANDING_X
	Planet_Y = VILTRUM_LANDING_Y
	Planet_Z = Z_LEVEL_VILTRUM
	Nav_Level = 0
	New()
		. = ..()
		CenterIcon(src)
		walk_rand(src, 100)

// Place once after persistent settings load, before planet visibility is applied.
proc/initializeViltrumPlanet()
	var/turf/surface = locate(VILTRUM_LANDING_X, VILTRUM_LANDING_Y, Z_LEVEL_VILTRUM)
	if(!surface || !istype(surface.loc, /area/Viltrum)) return
	for(var/obj/Planets/Viltrum/planet in planets)
		if(planet.z || planet.planet_turf) return planet
	var/turf/center = locate(350, 350, Z_LEVEL_SPACE)
	if(!center) return
	for(var/turf/Other/Stars/position in range(30, center))
		if(position.density || !istype(position.loc, /area/Space)) continue
		var/blocked = FALSE
		for(var/atom/movable/occupant in position)
			if(occupant.density)
				blocked = TRUE
				break
		if(!blocked)
			var/obj/Planets/Viltrum/planet = new(position)
			hide_destroyed_planets("Viltrum")
			return planet

proc/isViltrumiteSpawnRace(race_name)
	return race_name == "Viltrumite" || race_name == "Half-Viltrumite"
