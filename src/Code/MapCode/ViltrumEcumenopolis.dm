// South-facing houses share sidewalk frontages. Their complete structural
// footprint carries the same art tile by tile, independently of anchor visibility.
obj/ViltrumCityHouse
	parent_type = /obj/CityHouse
	name = "Viltrum townhouse"
	icon = 'src/Icons/Turfs/Viltrum/ViltrumCityResidence.dmi'
	icon_state = "residence"
	ResidenceB
		icon = 'src/Icons/Turfs/Viltrum/ViltrumCityResidenceB.dmi'
		icon_state = "residenceb"
	Hospital
		name = "District hospital"
		icon = 'src/Icons/Turfs/Viltrum/ViltrumCityHospital.dmi'
		icon_state = "hospital"
	Science
		name = "Science library"
		icon = 'src/Icons/Turfs/Viltrum/ViltrumCityScience.dmi'
		icon_state = "science"
	Transit
		name = "Transit terminal"
		icon = 'src/Icons/Turfs/Viltrum/ViltrumCityTransit.dmi'
		icon_state = "transit"
	Civic
		name = "Imperial civic hall"
		icon = 'src/Icons/Turfs/Viltrum/ViltrumCityCivic.dmi'
		icon_state = "civic"

var/image/viltrum_city_building_ground

turf/ViltrumCityStructure
	parent_type = /turf/CityBuildingFootprint
	name = "Building structure"
	build_category = BUILD_ROOF
	icon = 'src/Icons/Turfs/Viltrum/ViltrumCityStructures.dmi'
	icon_state = "residence_0_0"
	New()
		..()
		if(!viltrum_city_building_ground) viltrum_city_building_ground = image('src/Icons/Turfs/Viltrum/ViltrumCityStreets.dmi', icon_state = "pavement")
		underlays += viltrum_city_building_ground

turf/ViltrumCityStreet
	parent_type = /turf/ViltrumFloor
	name = "City avenue"
	icon = 'src/Icons/Turfs/Viltrum/ViltrumCityStreets.dmi'
	icon_state = "road"
	LaneHorizontal
		icon_state = "lane_h"
	LaneVertical
		icon_state = "lane_v"
	CrossingHorizontal
		icon_state = "cross_h"
	CrossingVertical
		icon_state = "cross_v"
	Pavement
		name = "Public pavement"
		icon_state = "pavement"
	Garden
		name = "Planted garden"
		icon_state = "garden"
	Plaza
		name = "Civic plaza"
		icon_state = "plaza"
	Quay
		name = "Waterfront promenade"
		icon_state = "quay_0"

obj/ViltrumCityTree
	parent_type = /obj/ViltrumFurnishing
	name = "City garden tree"
	icon = 'src/Icons/Turfs/Earth/EarthNeighborhoodProps.dmi'
	icon_state = "tree"
	pixel_x = -16
	layer = 5

obj/CityBuildingDoor/ViltrumCity
	icon = 'src/Icons/Turfs/Viltrum/ViltrumCityStreets.dmi'
	icon_state = "threshold"
	Crossed(atom/movable/mover)
		..()
		if(ismob(mover)) travel(mover)

// Reuse the existing exit type and empty-room policy; only its graphic and
// destination change. Other legacy portals retain their existing interaction.
obj/CityBuildingDoor/Exit/ViltrumCity
	icon = 'src/Icons/Turfs/Viltrum/ViltrumCityStreets.dmi'
	icon_state = "exit"
	Crossed(atom/movable/mover)
		..()
		if(ismob(mover)) travel(mover)
