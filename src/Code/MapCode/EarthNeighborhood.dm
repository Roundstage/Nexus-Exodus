// Ordinary adjacent houses. Anchor is the southwest tile; art and footprint
// are 5x6 tiles for houses and 7x6 for services. Roof turfs supply collision.
obj/EarthHouse
	parent_type = /obj/CityHouse
	name = "Townhouse"
	icon = 'src/Icons/Turfs/Earth/EarthNeighborhoodHouses.dmi'
	icon_state = "cream"
	Sage
		icon_state = "sage"
	Brick
		icon_state = "brick"
	Blue
		icon_state = "blue"
	Hospital
		name = "Neighborhood hospital"
		icon = 'src/Icons/Turfs/Earth/EarthNeighborhoodServices.dmi'
		icon_state = "hospital"
	Shop
		name = "Neighborhood shop"
		icon = 'src/Icons/Turfs/Earth/EarthNeighborhoodServices.dmi'
		icon_state = "shop"
	Civic
		name = "Community building"
		icon = 'src/Icons/Turfs/Earth/EarthNeighborhoodServices.dmi'
		icon_state = "civic"
	Garage
		name = "Motor repair garage"
		icon = 'src/Icons/Turfs/Earth/EarthNeighborhoodServices.dmi'
		icon_state = "garage"

var/image/earth_building_ground

turf/EarthBuildingStructure
	parent_type = /turf/CityBuildingFootprint/Earth
	name = "Building structure"
	// Each turf is visible independently of the southwest house object anchor.
	icon = 'src/Icons/Turfs/Earth/EarthBuildingTiles.dmi'
	icon_state = "cream_0_0"
	New()
		..()
		if(!earth_building_ground) earth_building_ground = image('src/Icons/Turfs/Earth/EarthRiverTerrain.dmi', icon_state = "bank_0")
		underlays += earth_building_ground

turf/EarthStreet
	parent_type = /turf/EarthFloor/Road
	icon = 'src/Icons/Turfs/Earth/EarthNeighborhoodDetails.dmi'
	icon_state = "asphalt"
	LaneHorizontal
		icon_state = "lane_h"
	LaneVertical
		icon_state = "lane_v"
	CrossingHorizontal
		icon_state = "cross_h"
	CrossingVertical
		icon_state = "cross_v"
	Sidewalk
		name = "Neighborhood sidewalk"
		icon_state = "sidewalk"
	CurbNorth
		name = "Sidewalk curb"
		icon_state = "curb_n"
	CurbSouth
		name = "Sidewalk curb"
		icon_state = "curb_s"
	CurbEast
		name = "Sidewalk curb"
		icon_state = "curb_e"
	CurbWest
		name = "Sidewalk curb"
		icon_state = "curb_w"
	Lawn
		name = "Garden lawn"
		icon_state = "lawn"
	GardenPath
		name = "Garden path"
		icon_state = "garden_path"
	Bridge
		name = "Asphalt bridge"
		Water = TRUE
		Buildable = FALSE
		icon_state = "asphalt"
		North
			icon_state = "bridge_n"
			density = TRUE
		South
			icon_state = "bridge_s"
			density = TRUE
		East
			icon_state = "bridge_e"
		West
			icon_state = "bridge_w"
		Sidewalk
			icon_state = "sidewalk"
		Lane
			icon_state = "lane_h"

obj/EarthStreetFixture
	parent_type = /obj/EarthFurnishing
	icon = 'src/Icons/Turfs/Earth/EarthNeighborhoodDetails.dmi'
	name = "Garden hedge"
	icon_state = "hedge"
	Fence
		name = "Garden fence"
		icon_state = "fence"
	Lamp
		name = "Street lamp"
		icon = 'src/Icons/Turfs/Earth/EarthNeighborhoodProps.dmi'
		icon_state = "lamp"
		pixel_y = 0
		pixel_x = -16
		layer = 5
	Tree
		name = "Street tree"
		icon = 'src/Icons/Turfs/Earth/EarthNeighborhoodProps.dmi'
		icon_state = "tree"
		pixel_x = -16
		layer = 5
	Bench
		name = "Park bench"
		icon = 'src/Icons/Turfs/Earth/EarthNeighborhoodProps.dmi'
		icon_state = "bench"
		pixel_x = -16
	Bin
		name = "Street bin"
		icon_state = "bin"
	Flowers
		name = "Flower bed"
		icon_state = "flowers"
		density = FALSE
	Car
		name = "Parked car"
		icon = 'src/Icons/Turfs/Earth/EarthNeighborhoodProps.dmi'
		icon_state = "car"
		bound_width = 64
		bound_height = 96
