// Separate authored interiors; the exterior sprite is one fixed map object.
// Each footprint is made of structural turfs, never a single dense anchor.
var/const/Z_LEVEL_CITY_INTERIORS = 22
var/list/city_building_doors = list()

area/CityInterior
	parent_type = /area/Inside
	var/surface_region = "viltrum"
	Earth
		surface_region = "super_earth"

turf/CityBuildingFootprint
	icon = 'src/Icons/Turfs/Viltrum/ViltrumFloors.dmi'
	icon_state = "civic_white"
	density = TRUE
	opacity = TRUE
	Health = 1.#INF
	Buildable = FALSE
	FlyOverAble = FALSE
	Enter(atom/movable/mover)
		return FALSE
	Earth
		icon = 'src/Icons/Turfs/Earth/EarthStreets.dmi'
		icon_state = "concrete"

obj/CityHouse
	name = "Viltrum residence"
	icon = 'src/Icons/Turfs/Viltrum/ViltrumBuildings.dmi'
	icon_state = "residence"
	layer = 5
	density = FALSE
	opacity = FALSE
	Health = 1.#INF
	Grabbable = FALSE
	Givable = FALSE
	Savable = FALSE
	Knockable = FALSE
	var/building_id
	Click()
		if(!usr || !building_id) return
		for(var/obj/CityBuildingDoor/door in city_building_doors)
			if(door.building_id == building_id && door.z == z)
				return door.travel(usr)
	Hospital
		icon_state = "hospital"
	Civic
		icon_state = "civic"
	Terrace
		icon_state = "terrace"
	Science
		icon_state = "science"
	Hangar
		icon_state = "hangar"
	Earth
		name = "Residence"
		icon = 'src/Icons/Turfs/Earth/EarthBuildings.dmi'
		Hospital
			icon_state = "hospital"
		Civic
			icon_state = "civic"
		Shop
			icon_state = "shop"
		Workshop
			icon_state = "workshop"
		Apartment
			icon_state = "apartment"

obj/CityBuildingDoor
	name = "Enter building"
	icon = 'src/Icons/Turfs/Viltrum/ViltrumDoors.dmi'
	icon_state = "civic_open"
	density = FALSE
	opacity = FALSE
	Health = 1.#INF
	Grabbable = FALSE
	Givable = FALSE
	Savable = FALSE
	Knockable = FALSE
	var/building_id
	var/target_x = 0
	var/target_y = 0
	var/target_z = 0
	var/interior_region = "viltrum"
	New()
		..()
		city_building_doors += src
	Del()
		city_building_doors -= src
		..()
	Click()
		travel(usr)
	verb/enterBuilding()
		set name = "Enter building"
		set src in oview(1)
		travel(usr)
	proc/travel(mob/traveler)
		if(!traveler || traveler.z != z || get_dist(traveler,src) > 1 || traveler.KO || traveler.KB) return FALSE
		var/turf/destination = locate(target_x,target_y,target_z)
		if(!isValidDestination(destination) || destination.density) return FALSE
		for(var/atom/movable/obstacle in destination)
			if(obstacle.density && !ismob(obstacle)) return FALSE
		traveler.SafeTeleport(destination)
		return traveler.loc == destination
	proc/isValidDestination(turf/destination)
		if(!destination || !isturf(loc)) return FALSE
		var/turf/source = loc
		if(istype(source.loc,/area/CityInterior))
			var/area/CityInterior/interior = source.loc
			if(interior.surface_region != interior_region) return FALSE
			if(interior_region == "super_earth") return destination.z == Z_LEVEL_SUPER_EARTH && istype(destination.loc,/area/SuperEarth)
			if(interior_region == "viltrum") return destination.z == Z_LEVEL_VILTRUM && istype(destination.loc,/area/Viltrum)
			return FALSE
		if(destination.z != Z_LEVEL_CITY_INTERIORS || !istype(destination.loc,/area/CityInterior)) return FALSE
		var/area/CityInterior/interior = destination.loc
		return interior.surface_region == interior_region
	Exit
		name = "Return to street"
	Earth
		interior_region = "super_earth"
		icon = 'src/Icons/Turfs/Earth/EarthNeighborhoodDetails.dmi'
		icon_state = "doorstep"
		Crossed(atom/movable/mover)
			..()
			if(ismob(mover)) travel(mover)
		Exit
			name = "Return to street"
			icon_state = "exit_mat"

proc/getCityInteriorRegion(turf/position)
	if(!position || !istype(position.loc,/area/CityInterior)) return null
	var/area/CityInterior/interior = position.loc
	return getNexusPlanetMapRegion(interior.surface_region)
