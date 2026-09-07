// Existing Nexus materials curated into a small, documented 32x32 map kit.
turf/EarthFloor
	name = "Wooden floor"
	icon = 'src/Icons/Turfs/Earth/EarthCity.dmi'
	icon_state = "wood"
	density = FALSE
	opacity = FALSE
	Health = 1.#INF
	FlyOverAble = TRUE
	build_category = BUILD_FLOOR
	Sidewalk
		name = "Concrete sidewalk"
		icon = 'src/Icons/Turfs/Earth/EarthNeighborhoodDetails.dmi'
		icon_state = "sidewalk"
	Road
		name = "Paved road"
		icon = 'src/Icons/Turfs/Earth/EarthNeighborhoodDetails.dmi'
		icon_state = "asphalt"
	Crosswalk
		name = "Pedestrian crossing"
		icon = 'src/Icons/Turfs/Earth/EarthNeighborhoodDetails.dmi'
		icon_state = "cross_h"
	Concrete
		name = "Industrial concrete floor"
		icon = 'src/Icons/Turfs/Earth/EarthStreets.dmi'
		icon_state = "industrial_concrete"
	Stone
		name = "Old town cobblestone"
		icon_state = "stone"
	Clinic
		name = "Clinic floor"
		icon_state = "clinic"
	Grate
		name = "Industrial grate"
		icon_state = "grate"

turf/EarthBridge
	parent_type = /turf/EarthFloor
	name = "Raised asphalt road bridge"
	icon = 'src/Icons/Turfs/Earth/EarthNeighborhoodDetails.dmi'
	icon_state = "asphalt"
	// Records the watercourse beneath the deck without invoking swimming hooks.
	Water = TRUE
	Buildable = FALSE

turf/EarthRoof
	parent_type = /turf/EarthFloor
	name = "Red tiled structural roof"
	icon_state = "roof_red"
	density = TRUE
	opacity = TRUE
	FlyOverAble = FALSE
	build_category = BUILD_ROOF
	Enter(atom/movable/mover)
		return FALSE
	Dark
		name = "Dark structural roof"
		icon_state = "roof_dark"
	Blue
		name = "Blue structural roof"
		icon_state = "roof_blue"

turf/EarthFacade
	parent_type = /turf/EarthFloor
	name = "Decorative house facade"
	icon_state = "facade"
	build_category = BUILD_DECOR
	Brick
		name = "Decorative brick facade"
		icon_state = "facade_brick"
	Wood
		name = "Decorative timber facade"
		icon_state = "facade_wood"

obj/EarthFurnishing
	name = "Bed"
	icon = 'src/Icons/Turfs/Earth/EarthCity.dmi'
	icon_state = "bed"
	density = TRUE
	opacity = FALSE
	Health = 1.#INF
	Grabbable = FALSE
	Givable = FALSE
	Savable = FALSE
	Knockable = FALSE
	Bookcase
		name = "Bookcase"
		icon_state = "bookcase"
	Cabinet
		name = "Kitchen cabinet"
		icon_state = "cabinet"
	Dresser
		name = "Dresser"
		icon_state = "dresser"
	Bench
		name = "Park bench"
		icon_state = "bench"
	Chair
		name = "Wooden chair"
		icon_state = "chair"
	Table
		name = "Dining table"
		icon_state = "table"
	Shelf
		name = "Shop display shelf"
		icon_state = "shelf"
	Desk
		name = "Reading desk"
		icon_state = "desk"
	Flowers
		name = "Flower vase"
		icon_state = "flowers"
	Stove
		name = "Kitchen stove"
		icon_state = "stove"
	Sink
		name = "Sink"
		icon_state = "sink"
	Files
		name = "Filing cabinet"
		icon_state = "files"
	Toolbox
		name = "Workshop tools"
		icon_state = "toolbox"

obj/EarthDirectory
	parent_type = /obj/EarthFurnishing
	name = "Public information terminal"
	icon_state = "computer"
	var/directions_text = "Follow the marked roads to the civic district and the arrival park."
	Click()
		if(usr && usr.z == z && get_dist(usr,src) <= 2) usr << "[name]: [directions_text]"

turf/EarthOceanBoundary
	name = "Open ocean boundary"
	icon = 'src/Icons/Turfs/Earth/EarthRiverTerrain.dmi'
	icon_state = "water_255"
	density = TRUE
	opacity = FALSE
	Water = TRUE
	Health = 1.#INF
	FlyOverAble = FALSE
	Buildable = FALSE
	Enter(atom/movable/mover)
		return FALSE
