// Single-tile baked art: 32x32, no offsets, no active lights or hidden collision.
turf/ViltrumGround
	name = "Teal stone"
	icon = 'src/Icons/Turfs/Viltrum/ViltrumGround.dmi'
	icon_state = "teal_stone"
	density = FALSE
	opacity = FALSE
	layer = TURF_LAYER
	plane = 0
	build_category = BUILD_GROUND
	Health = 1.#INF
	FlyOverAble = TRUE

turf/ViltrumFloor
	name = "Civic stone-metal"
	icon = 'src/Icons/Turfs/Viltrum/ViltrumFloors.dmi'
	icon_state = "civic_white"
	density = FALSE
	opacity = FALSE
	layer = TURF_LAYER
	plane = 0
	build_category = BUILD_FLOOR
	Health = 1.#INF
	FlyOverAble = TRUE
	Road
		name = "Imperial boulevard"
		icon_state = "structural"
	Structural
		name = "Structural platform"
		icon_state = "structural"
	Beacon
		name = "Landing marker"
		icon = 'src/Icons/Turfs/Viltrum/ViltrumTechnology.dmi'
		icon_state = "beacon"

turf/ViltrumLandscape
	parent_type = /turf/ViltrumGround
	name = "Polar plateau stone"
	icon = 'src/Icons/Turfs/Viltrum/ViltrumLandscape.dmi'
	icon_state = "plateau"
	Shore
		name = "Pale cyan shore"
		icon_state = "pale_shore"
	Snow
		name = "Polar snow"
		icon_state = "snow"
	Ice
		name = "Polar ice"
		icon_state = "ice"
	Crater
		name = "Impact stone"
		icon_state = "crater"
	Garden
		name = "Engineered teal garden"
		icon_state = "garden"
	Rough
		name = "Rough teal stone"
		icon_state = "rough_stone"
	Ruins
		name = "Weathered masonry"
		icon_state = "ruins"
	Cyan
		name = "Cyan stone"
		icon_state = "cyan_stone"

turf/ViltrumDistrictFloor
	parent_type = /turf/ViltrumFloor
	icon = 'src/Icons/Turfs/Viltrum/ViltrumLandscape.dmi'
	icon_state = "palace"
	Palace
		name = "Imperial inlaid floor"
	Laboratory
		name = "Laboratory floor"
		icon_state = "laboratory"
	Grate
		name = "Industrial grate"
		icon_state = "grate"
	Arena
		name = "Arena floor"
		icon_state = "arena"

turf/ViltrumOcean
	parent_type = /turf/ViltrumGround
	name = "Deep cyan sea"
	icon = 'src/Icons/Turfs/Viltrum/ViltrumLandscape.dmi'
	icon_state = "deep_sea"
	Water = TRUE
	density = TRUE
	Buildable = FALSE
	Shallow
		name = "Shallow cyan sea"
		icon_state = "shallow_sea"
	Boundary
		name = "Polar storm boundary"
		icon_state = "storm_sea"
		FlyOverAble = FALSE
		Enter(atom/movable/mover)
			return FALSE

// SafeTeleport assigns loc directly, which does not call turf Entered in BYOND.
// Resolve this mapped boundary before the existing teleport updates its context.
proc/resolvePlanetSurfaceArrival(turf/destination)
	if(istype(destination,/turf/ViltrumOcean/Boundary))
		var/turf/landing = locate(VILTRUM_LANDING_X,VILTRUM_LANDING_Y,Z_LEVEL_VILTRUM)
		if(landing && !landing.density) return landing
	if(istype(destination,/turf/EarthOceanBoundary))
		var/turf/landing = locate(SUPER_EARTH_LANDING_X,SUPER_EARTH_LANDING_Y,Z_LEVEL_SUPER_EARTH)
		if(landing && !landing.density) return landing
	return destination
