// Every part of a natural landmark is a real 32x32 turf. Broad continuous
// ramps join walkable terraces; rock faces use the solid-roof convention.
turf/EarthNaturalGround
	parent_type = /turf/EarthFloor
	name = "Sandstone terrace"
	icon = 'src/Icons/Turfs/Earth/EarthNaturalTiles.dmi'
	icon_state = "sand_top_0"
	Buildable = FALSE
	var/terrain_height = 0
	var/landmark_id
	Snow
		name = "Snowy mountain terrace"
		icon_state = "snow_top_0"
	Forest
		name = "Mossy rock shelf"
		icon_state = "forest_top_0"
	Sand
		name = "Wind-shaped sand"
		icon_state = "sand_ground"
	Dune
		name = "Sand dune slope"
		icon_state = "dune_4"
	Ramp
		name = "Natural scree slope"
		icon_state = "sand_ramp_n"
	Cave
		name = "Sandstone cavern floor"
		icon_state = "cave_floor"
	CaveMouth
		name = "Mysterious sandstone cave"
		icon_state = "cave_mouth_1_1"

turf/EarthNaturalRoof
	parent_type = /turf/EarthNaturalGround
	name = "Sandstone rock face"
	icon_state = "sand_face_0"
	density = TRUE
	opacity = TRUE
	FlyOverAble = FALSE
	build_category = BUILD_ROOF
	Enter(atom/movable/mover)
		return FALSE
	Snow
		name = "Glacial rock face"
		icon_state = "snow_face_0"
	Forest
		name = "Mossy cliff face"
		icon_state = "forest_face_0"
	Cave
		name = "Solid sandstone"
		icon_state = "cave_roof"

turf/EarthNaturalFall
	parent_type = /turf/WaterFall
	name = "Forest waterfall"
	Water = TRUE
	icon = 'src/Icons/Turfs/Earth/EarthNaturalTiles.dmi'
	icon_state = "waterfall"

turf/EarthNaturalFoam
	parent_type = /turf/EarthRiver
	name = "Waterfall plunge pool"
	icon = 'src/Icons/Turfs/Earth/EarthNaturalTiles.dmi'
	icon_state = "foam"

obj/EarthCaveEntrance
	parent_type = /obj/CityBuildingDoor
	name = "Enter the sandstone cave"
	interior_region = "super_earth"
	icon = null
	Crossed(atom/movable/mover)
		..()
		if(ismob(mover)) travel(mover)
	Exit
		name = "Leave the sandstone cave"
