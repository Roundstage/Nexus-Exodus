// The neighboring water mask is authored into each icon_state in the chunks.
// Preserve the existing water/step gameplay while replacing the old seams.
turf/EarthRiver
	parent_type = /turf/Water2
	name = "River water"
	icon = 'src/Icons/Turfs/Earth/EarthRiverTerrain.dmi'
	icon_state = "water_255"
	wave_icon = null

turf/EarthRiverBank
	parent_type = /turf/EarthFloor
	name = "Meadow and riverbank"
	icon = 'src/Icons/Turfs/Earth/EarthRiverTerrain.dmi'
	icon_state = "bank_0"
	build_category = BUILD_GROUND

turf/EarthRiverFall
	parent_type = /turf/WaterFall
	icon = 'src/Icons/Turfs/Earth/EarthRiverTerrain.dmi'
	icon_state = "waterfall"

turf/EarthRiverSteps
	parent_type = /turf/Stairs_Grass
	icon = 'src/Icons/Turfs/Earth/EarthRiverTerrain.dmi'
	icon_state = "steps"

turf/EarthRiverRock
	parent_type = /turf/Wall12
	icon = 'src/Icons/Turfs/Earth/EarthRiverTerrain.dmi'
	icon_state = "rock_lip"
