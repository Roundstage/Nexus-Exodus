obj/proc/MakeImmovableIndestructable()
	Health = 1.#INF
	Dead_Zone_Immune = 1
	Knockable = 0
	//Bolted = 1
	Grabbable = 0
	Cloakable = 0
	can_blueprint = 0

proc/View(r,c)
	return view(r,c)

proc/Missile(t,s,e)
	missile(t,s,e)

proc/Get_step(mob/m,D)
	return get_step(m,D)

proc/Remove_all_nulls()
	set waitfor=0
	while(1)
		sleep(600)
		players = remove_nulls(players)
		compactGarbageCollectionQueue(TRUE)
		pending_object_delete_list = remove_nulls(pending_object_delete_list)
		all_blast_objs = remove_nulls(all_blast_objs)
		cached_blasts = remove_nulls(cached_blasts)
		screen_indicator_cache = remove_nulls(screen_indicator_cache)
		cached_bodies = remove_nulls(cached_bodies)
		all_areas = remove_nulls(all_areas)
		light_sources = remove_nulls(light_sources)
		for(var/cache_key in cached_objects)
			cached_objects[cache_key] = remove_nulls(cached_objects[cache_key])
		for(var/area/a in all_areas)
			a.mob_list = remove_nulls(a.mob_list)
			a.player_list = remove_nulls(a.player_list)
			a.npc_list = remove_nulls(a.npc_list)
