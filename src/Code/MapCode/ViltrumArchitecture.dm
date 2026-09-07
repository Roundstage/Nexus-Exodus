// In this game's convention ROOFS are the solid structural walls. Wall faces
// are decorative front elevations. Neither type covers the playable interior.
turf/ViltrumWall
	name = "Imperial wall facade"
	icon = 'src/Icons/Turfs/Viltrum/ViltrumEnvelope.dmi'
	icon_state = "wall_face"
	density = FALSE
	opacity = FALSE
	layer = TURF_LAYER
	plane = 0
	build_category = BUILD_DECOR
	Health = 1.#INF
	FlyOverAble = TRUE
	Glass
		name = "Teal glass facade"
		icon_state = "glass_face"
	Column
		name = "Civic column"
		icon = 'src/Icons/Turfs/Viltrum/ViltrumWalls.dmi'
		icon_state = "column"
		density = TRUE
		FlyOverAble = FALSE

turf/ViltrumRoof
	name = "Imperial structural roof"
	icon = 'src/Icons/Turfs/Viltrum/ViltrumEnvelope.dmi'
	icon_state = "roof"
	density = TRUE
	opacity = TRUE
	layer = TURF_LAYER
	plane = 0
	build_category = BUILD_ROOF
	Health = 1.#INF
	FlyOverAble = FALSE
	Enter(atom/movable/mover)
		// The generic turf hook permits flight through dense turfs. Structural
		// roofs are actual walls, so they must not invoke that flight bypass.
		return FALSE
	Dark
		name = "Structural metal roof"
		icon_state = "roof_dark"

// Furnishings are sparse movable-type objects, with transparent 32x32 art.
// Their fixed placement does not bake any floor into the sprite or replace a turf.
obj/ViltrumFurnishing
	name = "Engineered garden planter"
	icon = 'src/Icons/Turfs/Viltrum/ViltrumObjects.dmi'
	icon_state = "planter"
	density = TRUE
	opacity = FALSE
	layer = OBJ_LAYER
	plane = 0
	Health = 1.#INF
	Grabbable = FALSE
	Givable = FALSE
	Savable = FALSE
	Knockable = FALSE
	Bench
		name = "Civic bench"
		icon_state = "bench"
	Banner
		name = "Imperial standard"
		icon_state = "banner"
	Memorial
		name = "Founders' memorial"
		icon_state = "memorial"
	ArchiveTable
		name = "Public archive table"
		icon_state = "archive_table"
	LandingBeacon
		name = "Landing marker"
		icon_state = "beacon"
		density = FALSE

// Capital furnishings share the same fixed-object behavior and independent floor.
obj/ViltrumCapitalFurnishing
	parent_type = /obj/ViltrumFurnishing
	icon = 'src/Icons/Turfs/Viltrum/ViltrumCapitalObjects.dmi'
	icon_state = "bed"
	Bed
		name = "Communal residence bed"
	MedicalBed
		name = "Medical examination station"
		icon_state = "medical_bed"
	Locker
		name = "Equipment locker"
		icon_state = "locker"
	FreightCrate
		name = "Sealed freight container"
		icon_state = "freight_crate"
	Throne
		name = "Imperial audience throne"
		icon_state = "throne"
	ServingCounter
		name = "Communal serving counter"
		icon_state = "serving_counter"
	Workbench
		name = "Precision maintenance workbench"
		icon_state = "workbench"
	CommunicationsMast
		name = "Communications mast"
		icon_state = "communications_mast"
