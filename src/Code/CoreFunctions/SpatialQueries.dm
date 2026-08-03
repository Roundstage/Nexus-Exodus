// Efficiently returns all active projectiles within range of center.
var/spatial_native_query_max_range = 32

proc/blast_view(dist=10, atom/center)
	if(!center) return new/list
	dist = max(0, dist)
	var/turf/center_turf = center.base_loc()
	if(!center_turf) return new/list
	var/area/a=center_turf.loc
	if(!a) return new/list
	var/list/l=new
	if(dist <= spatial_native_query_max_range)
		for(var/obj/Blast/nearby_blast in range(dist, center_turf))
			if(nearby_blast.z && nearby_blast.locz() == center_turf.z && nearby_blast.get_area() == a) l += nearby_blast
		return l
	for(var/obj/Blast/b in a.blast_objs) if(b.z&&b.locz()==center_turf.z&&getdist(b,center_turf)<=dist) l+=b
	return l

proc/player_range(range=20, atom/center)
	var/list/l=new
	if(!center) return l
	range = max(0, range)
	var/turf/center_turf = center.base_loc()
	if(!center_turf) return l
	var/area/a=center_turf.loc
	if(!a) return l
	if(range <= spatial_native_query_max_range)
		for(var/mob/nearby_player in range(range, center_turf))
			if(nearby_player.client && nearby_player.current_area == a && nearby_player.locz() == center_turf.z) l += nearby_player
		return l
	for(var/mob/m in a.player_list) if(m.locz()==center_turf.z&&getdist(m,center_turf)<=range) l+=m
	return l

proc/player_view(range = 20, atom/center, seePastDenseObjs = 1)
	var/list/l=new
	if(!center) return l
	range = max(0, range)
	var/turf/center_turf = center.base_loc()
	if(!center_turf) return l
	var/area/a=center_turf.loc
	if(!a) return l
	if(range <= spatial_native_query_max_range)
		for(var/mob/nearby_player in range(range, center_turf))
			if(nearby_player.client && nearby_player.current_area == a && nearby_player.locz() == center_turf.z && viewable(nearby_player,center_turf,5000,seePastDenseObjs)) l += nearby_player
		return l
	for(var/mob/m in a.player_list) if(m&&m.locz()==center_turf.z&&getdist(m,center_turf)<=range&&viewable(m,center_turf,5000,seePastDenseObjs)) l+=m
	return l

proc/mob_view(range=20, atom/center, seePastDenseObjs = 1)
	var/list/l=new
	if(!center) return l
	range = max(0, range)
	var/turf/center_turf = center.base_loc()
	if(!center_turf) return l
	var/area/a=center_turf.loc
	if(!a) return l
	if(range <= spatial_native_query_max_range)
		for(var/mob/nearby_mob in range(range, center_turf))
			if(nearby_mob.current_area == a && nearby_mob.locz() == center_turf.z && viewable(nearby_mob,center_turf,5000,seePastDenseObjs)) l += nearby_mob
		return l
	for(var/mob/m in a.mob_list) if(m.locz()==center_turf.z&&getdist(m,center_turf)<=range&&viewable(m,center_turf,5000,seePastDenseObjs)) l+=m
	return l

proc/npc_view(range=20, atom/center, seePastDenseObjs = 1)
	var/list/l=new
	if(!center) return l
	range = max(0, range)
	var/turf/center_turf = center.base_loc()
	if(!center_turf) return l
	var/area/a=center_turf.loc
	if(!a) return l
	if(range <= spatial_native_query_max_range)
		for(var/mob/nearby_npc in range(range, center_turf))
			if(!nearby_npc.client && nearby_npc.current_area == a && nearby_npc.locz() == center_turf.z && viewable(nearby_npc,center_turf,5000,seePastDenseObjs)) l += nearby_npc
		return l
	for(var/mob/m in a.npc_list) if(m.locz()==center_turf.z&&getdist(m,center_turf)<=range&&viewable(m,center_turf, 5000, seePastDenseObjs)) l+=m
	return l

#define GRID_RAY_VISIBILITY 1
#define GRID_RAY_LIGHT 2

proc/nexusGridRayTileBlocks(turf/ray_turf, ray_mode, see_past_dense_objects = TRUE)
	if(!ray_turf) return TRUE
	if(ray_mode == GRID_RAY_LIGHT) return nexusTurfBlocksLight(ray_turf)
	if(ray_turf.opacity) return TRUE
	for(var/obj/o in ray_turf)
		if(o.opacity || (!see_past_dense_objects && o.density)) return TRUE
	return FALSE

proc/gridRayCanReach(atom/start_atom, atom/end_atom, ray_mode = GRID_RAY_VISIBILITY, see_past_dense_objects = TRUE)
	var/turf/start_turf = start_atom ? start_atom.base_loc() : null
	var/turf/end_turf = end_atom ? end_atom.base_loc() : null
	if(!start_turf || !end_turf || start_turf.z != end_turf.z) return FALSE
	if(start_turf == end_turf) return TRUE

	var/x = start_turf.x
	var/y = start_turf.y
	var/delta_x = end_turf.x - x
	var/delta_y = end_turf.y - y
	var/step_x = delta_x > 0 ? 1 : delta_x < 0 ? -1 : 0
	var/step_y = delta_y > 0 ? 1 : delta_y < 0 ? -1 : 0
	var/tiles_x = abs(delta_x)
	var/tiles_y = abs(delta_y)
	var/progress_x = 0
	var/progress_y = 0

	while(progress_x < tiles_x || progress_y < tiles_y)
		var/decision = (1 + 2 * progress_x) * tiles_y - (1 + 2 * progress_y) * tiles_x
		if(decision == 0)
			var/turf/x_side = locate(x + step_x, y, start_turf.z)
			var/turf/y_side = locate(x, y + step_y, start_turf.z)
			if(x_side != end_turf && nexusGridRayTileBlocks(x_side, ray_mode, see_past_dense_objects)) return FALSE
			if(y_side != end_turf && nexusGridRayTileBlocks(y_side, ray_mode, see_past_dense_objects)) return FALSE
			x += step_x
			y += step_y
			progress_x++
			progress_y++
		else if(decision < 0)
			x += step_x
			progress_x++
		else
			y += step_y
			progress_y++
		var/turf/next_turf = locate(x, y, start_turf.z)
		if(next_turf == end_turf) return TRUE
		if(nexusGridRayTileBlocks(next_turf, ray_mode, see_past_dense_objects)) return FALSE
	return FALSE

proc/traceGridRay(atom/start_atom, atom/end_atom, include_start = FALSE)
	var/turf/start_turf = start_atom ? start_atom.base_loc() : null
	var/turf/end_turf = end_atom ? end_atom.base_loc() : null
	var/list/ray = list()
	if(!start_turf || !end_turf || start_turf.z != end_turf.z) return ray
	if(include_start) ray += start_turf
	if(start_turf == end_turf) return ray

	var/x = start_turf.x
	var/y = start_turf.y
	var/delta_x = end_turf.x - x
	var/delta_y = end_turf.y - y
	var/step_x = delta_x > 0 ? 1 : delta_x < 0 ? -1 : 0
	var/step_y = delta_y > 0 ? 1 : delta_y < 0 ? -1 : 0
	var/tiles_x = abs(delta_x)
	var/tiles_y = abs(delta_y)
	var/progress_x = 0
	var/progress_y = 0

	while(progress_x < tiles_x || progress_y < tiles_y)
		var/decision = (1 + 2 * progress_x) * tiles_y - (1 + 2 * progress_y) * tiles_x
		if(decision == 0)
			var/turf/x_side = locate(x + step_x, y, start_turf.z)
			var/turf/y_side = locate(x, y + step_y, start_turf.z)
			if(x_side) ray += x_side
			if(y_side) ray += y_side
			x += step_x
			y += step_y
			progress_x++
			progress_y++
		else if(decision < 0)
			x += step_x
			progress_x++
		else
			y += step_y
			progress_y++
		var/turf/next_turf = locate(x, y, start_turf.z)
		if(next_turf) ray += next_turf
	return ray

proc/viewable(atom/a, atom/b, max_dist = 5000, seePastDenseObjs = 1)
	var/turf/start_turf = a ? a.base_loc() : null
	var/turf/end_turf = b ? b.base_loc() : null
	if(!start_turf || !end_turf || start_turf.z != end_turf.z) return
	if(start_turf == end_turf) return TRUE
	if(getdist(start_turf, end_turf) > max_dist) return
	return gridRayCanReach(start_turf, end_turf, GRID_RAY_VISIBILITY, seePastDenseObjs)
