proc/runEarthNaturalLandmarkStartupSmokeTests()
	var/mob/NexusSmokeTest/explorer = new(locate(107,124,Z_LEVEL_SUPER_EARTH))
	checkEarthNaturalClimb(explorer,107,124,"sandstone_massif",3)
	checkEarthNaturalClimb(explorer,281,425,"arctic_peak",3)
	checkEarthNaturalClimb(explorer,344,342,"forest_falls",1)
	checkEarthNaturalClimb(explorer,391,344,"forest_east_ledge",1)
	var/stairs = 0
	for(var/turf/EarthRiverSteps/old_step in block(locate(1,1,Z_LEVEL_SUPER_EARTH),locate(500,500,Z_LEVEL_SUPER_EARTH))) stairs++
	nexusSmokeAssert(!stairs,"Rejected Earth terrain stairs remain")
	for(var/turf/EarthNaturalRoof/rock in block(locate(105,100,Z_LEVEL_SUPER_EARTH),locate(158,146,Z_LEVEL_SUPER_EARTH)))
		explorer.Flying = TRUE
		nexusSmokeAssert(rock.density && rock.opacity && !rock.Enter(explorer),"Natural rock structure must block walking, flight and sight")
		explorer.Flying = FALSE
		break
	var/obj/EarthCaveEntrance/entrance = locate() in locate(132,106,Z_LEVEL_SUPER_EARTH)
	var/obj/EarthCaveEntrance/Exit/exit_door = locate() in locate(341,218,Z_LEVEL_CITY_INTERIORS)
	nexusSmokeAssert(entrance && exit_door,"Sandstone cave lacks its mapped entrance/exit")
	if(entrance && exit_door)
		var/turf/approach = locate(132,105,Z_LEVEL_SUPER_EARTH)
		explorer.SafeTeleport(approach)
		explorer.KO = TRUE
		nexusSmokeAssert(!entrance.travel(explorer),"Cave permits unconscious entry")
		explorer.KO = FALSE
		step(explorer,NORTH)
		nexusSmokeAssert(explorer.loc == locate(341,219,Z_LEVEL_CITY_INTERIORS),"Walking into the cave failed")
		nexusSmokeAssert(getNexusPlanetControlId(explorer) == "super_earth","Cave lost Earth planet context")
		step(explorer,SOUTH)
		nexusSmokeAssert(explorer.loc == approach,"Cave exit did not return to its accessible approach")
	for(var/list/point in list(list(368,342),list(369,341),list(369,339)))
		var/turf/water = locate(point[1],point[2],Z_LEVEL_SUPER_EARTH)
		nexusSmokeAssert(water.Water,"Forest waterfall interrupts the river")
	del(explorer)

// Find a route using the actual loaded turfs, then walk every step through the
// engine. This catches solid ramps and blocked ledges that image review misses.
proc/checkEarthNaturalClimb(mob/explorer,start_x,start_y,landmark,level)
	var/turf/start = locate(start_x,start_y,Z_LEVEL_SUPER_EARTH)
	var/list/frontier = list(start)
	var/list/visited = list()
	var/list/previous = list()
	visited[start] = TRUE
	var/turf/EarthNaturalGround/summit
	var/index = 1
	while(index <= frontier.len && index <= 12000)
		var/turf/current = frontier[index++]
		if(istype(current,/turf/EarthNaturalGround) && !current.density)
			var/turf/EarthNaturalGround/terrain = current
			if(terrain.landmark_id == landmark && terrain.terrain_height == level)
				summit = terrain
				break
		for(var/direction in list(NORTH,EAST,SOUTH,WEST))
			var/turf/neighbor = get_step(current,direction)
			if(!neighbor || neighbor.z != start.z || neighbor.density || neighbor.Water || visited[neighbor]) continue
			if(abs(neighbor.x-start_x)>55 || abs(neighbor.y-start_y)>55) continue
			var/blocked = FALSE
			for(var/atom/movable/obstacle in neighbor)
				if(obstacle.density) blocked = TRUE
			if(blocked) continue
			visited[neighbor] = TRUE
			previous[neighbor] = current
			frontier += neighbor
	nexusSmokeAssert(summit,"Natural mountain has no walking route to its summit")
	if(!summit) return
	var/list/route = list()
	var/turf/position = summit
	while(position != start)
		route.Insert(1,position)
		position = previous[position]
	explorer.SafeTeleport(start)
	for(var/turf/next_step in route)
		step(explorer,get_dir(explorer,next_step))
		nexusSmokeAssert(explorer.loc == next_step,"Walking up a natural ramp or terrace failed")
		if(explorer.loc != next_step) return
