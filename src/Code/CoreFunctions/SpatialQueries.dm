// Efficiently returns all active projectiles within range of center.
var/spatial_native_query_max_range = 32

// Combat collision is intentionally separate from BYOND density bounds. Density bounds remain
// the cheap rectangular movement collider; these helpers add exact circle/rectangle/capsule tests
// after a native range query has produced a small candidate set.
var/list/nexus_expanded_combat_hitbox_mobs = list()

atom/proc/nexusCollisionCenterXPixels()
	return ((x - 1) * world.icon_size) + (world.icon_size * 0.5)

atom/proc/nexusCollisionCenterYPixels()
	return ((y - 1) * world.icon_size) + (world.icon_size * 0.5)

atom/movable/nexusCollisionCenterXPixels()
	return bound_center_x() * world.icon_size

atom/movable/nexusCollisionCenterYPixels()
	return bound_center_y() * world.icon_size

mob/var/tmp
	list/nexus_combat_hitbox_sources
	nexus_combat_hitbox_width
	nexus_combat_hitbox_height

mob/proc/getNexusCombatHitboxWidth()
	if(nexus_combat_hitbox_width > 0) return nexus_combat_hitbox_width
	return max(1, bound_width)

mob/proc/getNexusCombatHitboxHeight()
	if(nexus_combat_hitbox_height > 0) return nexus_combat_hitbox_height
	return max(1, bound_height)

mob/proc/setNexusCombatHitboxSource(source_id, hitbox_width = 0, hitbox_height = 0)
	if(!source_id) return
	if(!nexus_combat_hitbox_sources) nexus_combat_hitbox_sources = list()
	if(hitbox_width > 0 && hitbox_height > 0)
		nexus_combat_hitbox_sources[source_id] = list(max(1, hitbox_width), max(1, hitbox_height))
	else
		nexus_combat_hitbox_sources -= source_id
		if(!nexus_combat_hitbox_sources.len) nexus_combat_hitbox_sources = null
	var/new_width
	var/new_height
	if(nexus_combat_hitbox_sources)
		for(var/active_source in nexus_combat_hitbox_sources)
			var/list/source_bounds = nexus_combat_hitbox_sources[active_source]
			if(!source_bounds || source_bounds.len < 2) continue
			new_width = max(new_width, source_bounds[1])
			new_height = max(new_height, source_bounds[2])
	nexus_combat_hitbox_width = new_width
	nexus_combat_hitbox_height = new_height
	if(new_width > bound_width || new_height > bound_height)
		if(!(src in nexus_expanded_combat_hitbox_mobs)) nexus_expanded_combat_hitbox_mobs += src
	else
		nexus_expanded_combat_hitbox_mobs -= src

proc/nexusPointToRectDistanceSquared(point_x, point_y, mob/target, physical_bounds_only = FALSE)
	if(!target) return 1.#INF
	var/target_width = physical_bounds_only ? max(1, target.bound_width) : target.getNexusCombatHitboxWidth()
	var/target_height = physical_bounds_only ? max(1, target.bound_height) : target.getNexusCombatHitboxHeight()
	var/delta_x = max(0, abs(point_x - target.nexusCollisionCenterXPixels()) - target_width * 0.5)
	var/delta_y = max(0, abs(point_y - target.nexusCollisionCenterYPixels()) - target_height * 0.5)
	return delta_x * delta_x + delta_y * delta_y

proc/nexusCircleIntersectsHitbox(center_x, center_y, radius, mob/target, physical_bounds_only = FALSE)
	if(!target || radius < 0) return FALSE
	return nexusPointToRectDistanceSquared(center_x, center_y, target, physical_bounds_only) <= radius * radius

proc/nexusPointToSegmentDistanceSquared(point_x, point_y, start_x, start_y, end_x, end_y)
	var/segment_x = end_x - start_x
	var/segment_y = end_y - start_y
	var/segment_length_squared = segment_x * segment_x + segment_y * segment_y
	if(segment_length_squared <= 0)
		var/static_x = point_x - start_x
		var/static_y = point_y - start_y
		return static_x * static_x + static_y * static_y
	var/projection = ((point_x - start_x) * segment_x + (point_y - start_y) * segment_y) / segment_length_squared
	projection = Clamp(projection, 0, 1)
	var/nearest_x = start_x + segment_x * projection
	var/nearest_y = start_y + segment_y * projection
	var/delta_x = point_x - nearest_x
	var/delta_y = point_y - nearest_y
	return delta_x * delta_x + delta_y * delta_y

proc/nexusSegmentsIntersect(a_start_x, a_start_y, a_end_x, a_end_y, b_start_x, b_start_y, b_end_x, b_end_y)
	var/a_dx = a_end_x - a_start_x
	var/a_dy = a_end_y - a_start_y
	var/b_dx = b_end_x - b_start_x
	var/b_dy = b_end_y - b_start_y
	var/denominator = a_dx * b_dy - a_dy * b_dx
	var/offset_x = b_start_x - a_start_x
	var/offset_y = b_start_y - a_start_y
	if(abs(denominator) <= 0.0001)
		if(abs(offset_x * a_dy - offset_y * a_dx) > 0.0001) return FALSE
		var/a_length_squared = a_dx * a_dx + a_dy * a_dy
		if(a_length_squared <= 0.0001)
			return nexusPointToSegmentDistanceSquared(a_start_x, a_start_y, b_start_x, b_start_y, b_end_x, b_end_y) <= 0.0001
		var/first_projection = (offset_x * a_dx + offset_y * a_dy) / a_length_squared
		var/second_projection = first_projection + (b_dx * a_dx + b_dy * a_dy) / a_length_squared
		return max(min(first_projection, second_projection), 0) <= min(max(first_projection, second_projection), 1)
	var/a_fraction = (offset_x * b_dy - offset_y * b_dx) / denominator
	var/b_fraction = (offset_x * a_dy - offset_y * a_dx) / denominator
	return a_fraction >= 0 && a_fraction <= 1 && b_fraction >= 0 && b_fraction <= 1

proc/nexusSegmentIntersectsHitbox(start_x, start_y, end_x, end_y, mob/target, physical_bounds_only = FALSE)
	if(!target) return FALSE
	var/half_width = (physical_bounds_only ? max(1, target.bound_width) : target.getNexusCombatHitboxWidth()) * 0.5
	var/half_height = (physical_bounds_only ? max(1, target.bound_height) : target.getNexusCombatHitboxHeight()) * 0.5
	var/center_x = target.nexusCollisionCenterXPixels()
	var/center_y = target.nexusCollisionCenterYPixels()
	var/left = center_x - half_width
	var/right = center_x + half_width
	var/bottom = center_y - half_height
	var/top = center_y + half_height
	if(start_x >= left && start_x <= right && start_y >= bottom && start_y <= top) return TRUE
	if(end_x >= left && end_x <= right && end_y >= bottom && end_y <= top) return TRUE
	if(nexusSegmentsIntersect(start_x, start_y, end_x, end_y, left, bottom, right, bottom)) return TRUE
	if(nexusSegmentsIntersect(start_x, start_y, end_x, end_y, right, bottom, right, top)) return TRUE
	if(nexusSegmentsIntersect(start_x, start_y, end_x, end_y, right, top, left, top)) return TRUE
	return nexusSegmentsIntersect(start_x, start_y, end_x, end_y, left, top, left, bottom)

proc/nexusCapsuleIntersectsHitbox(start_x, start_y, end_x, end_y, radius, mob/target, physical_bounds_only = FALSE)
	if(!target || radius < 0) return FALSE
	if(nexusSegmentIntersectsHitbox(start_x, start_y, end_x, end_y, target, physical_bounds_only)) return TRUE
	var/radius_squared = radius * radius
	if(nexusPointToRectDistanceSquared(start_x, start_y, target, physical_bounds_only) <= radius_squared) return TRUE
	if(nexusPointToRectDistanceSquared(end_x, end_y, target, physical_bounds_only) <= radius_squared) return TRUE
	var/half_width = (physical_bounds_only ? max(1, target.bound_width) : target.getNexusCombatHitboxWidth()) * 0.5
	var/half_height = (physical_bounds_only ? max(1, target.bound_height) : target.getNexusCombatHitboxHeight()) * 0.5
	var/center_x = target.nexusCollisionCenterXPixels()
	var/center_y = target.nexusCollisionCenterYPixels()
	if(nexusPointToSegmentDistanceSquared(center_x - half_width, center_y - half_height, start_x, start_y, end_x, end_y) <= radius_squared) return TRUE
	if(nexusPointToSegmentDistanceSquared(center_x + half_width, center_y - half_height, start_x, start_y, end_x, end_y) <= radius_squared) return TRUE
	if(nexusPointToSegmentDistanceSquared(center_x + half_width, center_y + half_height, start_x, start_y, end_x, end_y) <= radius_squared) return TRUE
	return nexusPointToSegmentDistanceSquared(center_x - half_width, center_y + half_height, start_x, start_y, end_x, end_y) <= radius_squared

proc/nexusMobsInCircle(atom/center, radius_pixels, include_center = FALSE)
	var/list/result = list()
	if(!center || radius_pixels < 0) return result
	var/turf/center_turf = center.base_loc()
	if(!center_turf) return result
	var/center_x = center.nexusCollisionCenterXPixels()
	var/center_y = center.nexusCollisionCenterYPixels()
	var/broadphase_pixels = radius_pixels + world.icon_size * 0.5
	var/broadphase_tiles = max(1, round((broadphase_pixels + world.icon_size - 0.0001) / world.icon_size))
	for(var/mob/candidate in range(broadphase_tiles, center_turf))
		if(!candidate.z || candidate.locz() != center_turf.z) continue
		if(!include_center && candidate == center) continue
		if(nexusCircleIntersectsHitbox(center_x, center_y, radius_pixels, candidate)) result += candidate
	// Enlarged combat rectangles keep standard movement locs/bounds, so the native query can
	// legitimately omit their outer edge. They are few and tracked separately.
	for(var/mob/candidate in nexus_expanded_combat_hitbox_mobs)
		if(!candidate || !candidate.z)
			nexus_expanded_combat_hitbox_mobs -= candidate
			continue
		if(candidate in result || candidate.locz() != center_turf.z) continue
		if(!include_center && candidate == center) continue
		var/extra_tiles = max(1, round((max(candidate.getNexusCombatHitboxWidth(), candidate.getNexusCombatHitboxHeight()) * 0.5 + world.icon_size - 0.0001) / world.icon_size))
		if(getdist(candidate, center_turf) > broadphase_tiles + extra_tiles) continue
		if(nexusCircleIntersectsHitbox(center_x, center_y, radius_pixels, candidate)) result += candidate
	return result

proc/nexusMobsInCapsule(atom/center, start_x, start_y, end_x, end_y, radius_pixels)
	var/list/result = list()
	if(!center || radius_pixels < 0) return result
	var/turf/center_turf = center.base_loc()
	if(!center_turf) return result
	var/query_x = center.nexusCollisionCenterXPixels()
	var/query_y = center.nexusCollisionCenterYPixels()
	var/max_endpoint_offset = max(abs(start_x - query_x), abs(start_y - query_y), abs(end_x - query_x), abs(end_y - query_y))
	var/broadphase_pixels = max_endpoint_offset + radius_pixels + world.icon_size * 0.5
	var/broadphase_tiles = max(1, round((broadphase_pixels + world.icon_size - 0.0001) / world.icon_size))
	for(var/mob/candidate in range(broadphase_tiles, center_turf))
		if(!candidate.z || candidate.locz() != center_turf.z) continue
		if(nexusCapsuleIntersectsHitbox(start_x, start_y, end_x, end_y, radius_pixels, candidate)) result += candidate
	for(var/mob/candidate in nexus_expanded_combat_hitbox_mobs)
		if(!candidate || !candidate.z)
			nexus_expanded_combat_hitbox_mobs -= candidate
			continue
		if(candidate in result || candidate.locz() != center_turf.z) continue
		var/extra_tiles = max(1, round((max(candidate.getNexusCombatHitboxWidth(), candidate.getNexusCombatHitboxHeight()) * 0.5 + world.icon_size - 0.0001) / world.icon_size))
		if(getdist(candidate, center_turf) > broadphase_tiles + extra_tiles) continue
		if(nexusCapsuleIntersectsHitbox(start_x, start_y, end_x, end_y, radius_pixels, candidate)) result += candidate
	return result

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
