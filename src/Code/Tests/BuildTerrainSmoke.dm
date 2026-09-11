mob/NexusSmokeTest/BuildTools
	var/build_test_cost = 0
	var/build_test_resources = 1000000
	turfLayCost()
		return build_test_cost
	getBuildOwnerKey()
		return "build-smoke"
	Res()
		return build_test_resources
	Alter_Res(Amount = 0)
		build_test_resources += Amount
		return Amount

// Reuse the restored interior fixture owned by the Earth shoreline smoke test.
proc/runBuildTerrainSmokeTests(turf/ground,turf/water,turf/south_ground,area/legacy_area,area/protected_area)
	var/list/original_overlays = ground.overlays.Copy()
	var/original_builder = ground.Builder
	legacy_area.contents += ground
	legacy_area.contents += water
	ground.Builder = "build-smoke"
	ground.build_edges_enabled = FALSE
	ground.refreshBuildEdges()
	nexusSmokeAssert(ground.overlays.len == original_overlays.len, "Disabled build edges changed terrain")
	ground.build_edges_enabled = TRUE
	ground.refreshBuildEdges()
	var/border_count = ground.overlays.len
	nexusSmokeAssert(border_count > original_overlays.len, "Enabled build edges produced no shoreline")
	ground.refreshBuildEdges()
	nexusSmokeAssert(ground.overlays.len == border_count, "Refreshing build edges duplicated overlays")
	water.Water = FALSE
	refreshBuildEdgesAround(water)
	nexusSmokeAssert(ground.overlays.len == border_count, "A different land material lost its build edge")
	water.Water = TRUE
	protected_area.contents += ground
	ground.refreshBuildEdges()
	nexusSmokeAssert(ground.build_edge_overlays.len > 0, "World decoration policy suppressed explicitly enabled player-built edges")
	ground.build_edges_enabled = FALSE
	ground.refreshBuildEdges()
	nexusSmokeAssert(ground.overlays.len == original_overlays.len, "Disabling player-built edges removed authored overlays")
	legacy_area.contents += ground
	ground.build_edges_enabled = FALSE
	ground.refreshBuildEdges()
	ground.Builder = original_builder
	nexusSmokeAssert(ground.overlays.len == original_overlays.len, "Build edges removed unrelated overlays")
	var/mob/NexusSmokeTest/BuildTools/builder = new(ground)
	var/obj/Build/blueprint = new
	blueprint.Creates = /turf/Wall7
	Builds += blueprint
	var/turf/prior_tile = builder.loc
	var/prior_type = prior_tile.type
	nexusSmokeAssert(builder.selectBuildBlueprint(blueprint) && builder.build_brush == blueprint, "Build blueprint selection failed")
	nexusSmokeAssert(prior_tile.type == prior_type && builder.loc == prior_tile, "Selecting a blueprint placed terrain")
	builder.selectBuildBlueprint(blueprint)
	nexusSmokeAssert(builder.build_brush == blueprint, "Selecting the same blueprint unexpectedly cleared the brush")
	// A submitted remote placement must fail before any tile or cost changes.
	var/turf/remote = locate(350,250,Z_LEVEL_CITY_INTERIORS)
	var/remote_type = remote.type
	buildLay(blueprint,builder,remote)
	nexusSmokeAssert(remote.type == remote_type, "Build placement accepted a distant destination")
	builder.last_attacked_time = max(1,world.time)
	builder.build_brush = blueprint
	buildLay(blueprint,builder,water)
	nexusSmokeAssert(!builder.build_brush && istype(water,/turf/Water2), "Build placement ignored combat after selection")
	builder.last_attacked_time = 0
	// Cliffs must not flood southern land, occupy protected water or delete objects.
	builder.placeBuildCliff(ground)
	nexusSmokeAssert(istype(water,/turf/Water2) && istype(south_ground,/turf/EarthFloor/Road), "Build cliffs flooded southern land")
	protected_area.contents += water
	builder.placeBuildCliff(ground)
	nexusSmokeAssert(istype(water,/turf/Water2), "Build cliffs replaced protected water")
	Builds -= blueprint
	del(blueprint)
	del(builder)
	runBuildBrushSmokeTests()
	world.log << "BUILD_TERRAIN_SMOKE_PASSED: selection, distance, combat, edges, protected cliffs"
