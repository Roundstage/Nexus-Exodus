/*
with pix moving since the map will seem so much bigger just imagine all the extra landmarks we
can add to the map without it seeming "right next to each other"
since travel time will be increased. We could add Roshi's house, procedural dungeons entrances, and so on. Each separate ecosystem and village
and town would seem more legitimate instead of being able to reach anything in 12 seconds max. We could make Earth the best map ever for
starters.
*/

world/fps = 60

var/BASE_MOVE_DELAY = 1

mob/var
	tmp
		next_input_move_time = 0
		last_input_move = 0
		input_disabled = 0 //+1 for each thing disabling input

var/epsilon = 0.0001
var/use_vector_movement = 1
var/vector_move_max_pixels = 256
var/vector_move_min_sleep_mult = 0.1
var/vector_glide_min = 1
var/vector_glide_target = 0
var/vector_glide_max = 0
var/vector_glide_high_speed_scale = 1
var/vector_move_base_pixels_per_second = 70
var/vector_walk_speed_pixels_per_second = 16
var/vector_move_speed_delay_baseline = 2.3
var/vector_move_speed_stat_severity = 0.2
var/vector_move_speed_stat_minimum = 0.7
var/vector_move_speed_stat_maximum = 1.4
var/vector_player_collision_size = 24
var/vector_gap_nudge_fraction = 0.5
var/vector_gap_nudge_pixels = 1

mob/var/tmp
	walking_mode = FALSE
	nexus_gap_nudge_direction
	nexus_gap_nudge_input_direction
	nexus_gap_nudge_target_offset

mob/proc
	configureNexusVectorCollisionBounds()
		if(bound_x || bound_y || bound_width != world.icon_size || bound_height != world.icon_size) return
		var/collision_size = Clamp(vector_player_collision_size, 1, world.icon_size)
		var/collision_offset = round((world.icon_size - collision_size) / 2)
		bound_x = collision_offset
		bound_y = collision_offset
		bound_width = collision_size
		bound_height = collision_size

	isNexusVectorNudgeBlocker(atom/obstacle)
		if(!obstacle || obstacle == src || !obstacle.density) return FALSE
		if(isturf(obstacle)) return !Flying
		if(ismob(obstacle)) return TRUE
		if(!isobj(obstacle)) return TRUE
		if(istype(obstacle, /obj/Turfs/Door)) return FALSE
		if(Flying || lunge_attacking || evading) return FALSE
		return istype(obstacle, /obj/Trees) || istype(obstacle, /obj/Big_Rock) || istype(obstacle, /obj/Turfs)

	nexusVectorDensityCount(fraction_x, fraction_y, fraction_width = 0, fraction_height = 0, offset_x = 0, offset_y = 0, extra_width = 0, extra_height = 0)
		var/density_count = -1
		for(var/atom/obstacle in obounds(src, bound_width * fraction_x + offset_x, bound_height * fraction_y + offset_y, bound_width * fraction_width + extra_width, bound_height * fraction_height + extra_height))
			if(density_count < 0) density_count = 0
			if(isNexusVectorNudgeBlocker(obstacle)) density_count++
		return density_count

	getNexusGapNudgeCandidates(move_direction, lookahead_pixels = 1)
		var/list/candidates = list()
		var/fraction = vector_gap_nudge_fraction
		lookahead_pixels = max(1, round(lookahead_pixels))
		switch(move_direction)
			if(NORTH)
				if(nexusVectorDensityCount(fraction, 1, -fraction, -1, 0, 0, 0, lookahead_pixels) == 0) candidates += EAST
				if(nexusVectorDensityCount(0, 1, -fraction, -1, 0, 0, 0, lookahead_pixels) == 0) candidates += WEST
			if(EAST)
				if(nexusVectorDensityCount(1, fraction, -1, -fraction, 0, 0, lookahead_pixels, 0) == 0) candidates += NORTH
				if(nexusVectorDensityCount(1, 0, -1, -fraction, 0, 0, lookahead_pixels, 0) == 0) candidates += SOUTH
			if(SOUTH)
				if(nexusVectorDensityCount(fraction, 0, -fraction, -1, 0, -lookahead_pixels, 0, lookahead_pixels) == 0) candidates += EAST
				if(nexusVectorDensityCount(0, 0, -fraction, -1, 0, -lookahead_pixels, 0, lookahead_pixels) == 0) candidates += WEST
			if(WEST)
				if(nexusVectorDensityCount(0, fraction, -1, -fraction, -lookahead_pixels, 0, lookahead_pixels, 0) == 0) candidates += NORTH
				if(nexusVectorDensityCount(0, 0, -1, -fraction, -lookahead_pixels, 0, lookahead_pixels, 0) == 0) candidates += SOUTH
		return candidates

	setNexusGapNudgeTarget(nudge_direction)
		var/current_offset
		var/target_offset
		switch(nudge_direction)
			if(EAST)
				current_offset = step_x
				target_offset = step_x <= 0 ? 1 : world.icon_size + 1
			if(WEST)
				current_offset = step_x
				target_offset = step_x >= 0 ? -1 : -world.icon_size - 1
			if(NORTH)
				current_offset = step_y
				target_offset = step_y <= 0 ? 1 : world.icon_size + 1
			if(SOUTH)
				current_offset = step_y
				target_offset = step_y >= 0 ? -1 : -world.icon_size - 1
		if(!isnum(target_offset)) return FALSE
		var/max_nudge_distance = max(bound_width, bound_height) * vector_gap_nudge_fraction + 1
		if(abs(target_offset - current_offset) > max_nudge_distance) return FALSE
		nexus_gap_nudge_target_offset = target_offset
		return TRUE

	hasNexusGapNudgeTargetRemaining()
		switch(nexus_gap_nudge_direction)
			if(EAST) return step_x < nexus_gap_nudge_target_offset
			if(WEST) return step_x > nexus_gap_nudge_target_offset
			if(NORTH) return step_y < nexus_gap_nudge_target_offset
			if(SOUTH) return step_y > nexus_gap_nudge_target_offset
		return FALSE

	clearNexusGapNudgeTarget()
		nexus_gap_nudge_direction = null
		nexus_gap_nudge_input_direction = null
		nexus_gap_nudge_target_offset = null

	findNexusGapNudgeDirection(move_direction, lookahead_pixels = 1, list/candidates)
		if(!candidates) candidates = getNexusGapNudgeCandidates(move_direction, lookahead_pixels)
		if(!candidates.len)
			clearNexusGapNudgeTarget()
			return
		if(nexus_gap_nudge_input_direction == move_direction && nexus_gap_nudge_direction)
			if((nexus_gap_nudge_direction in candidates) && hasNexusGapNudgeTargetRemaining())
				return nexus_gap_nudge_direction
			clearNexusGapNudgeTarget()
			if(candidates.len > 1) return
		else if(candidates.len > 1)
			return
		nexus_gap_nudge_input_direction = move_direction
		nexus_gap_nudge_direction = candidates[1]
		if(!setNexusGapNudgeTarget(nexus_gap_nudge_direction))
			clearNexusGapNudgeTarget()
			return
		return nexus_gap_nudge_direction

	nudgeNexusVectorMove(move_direction, lookahead_pixels = 1, list/candidates)
		var/nudge_direction = findNexusGapNudgeDirection(move_direction, lookahead_pixels, candidates)
		if(!nudge_direction) return
		var/nudge_x = 0
		var/nudge_y = 0
		switch(nudge_direction)
			if(EAST) nudge_x = vector_gap_nudge_pixels
			if(WEST) nudge_x = -vector_gap_nudge_pixels
			if(NORTH) nudge_y = vector_gap_nudge_pixels
			if(SOUTH) nudge_y = -vector_gap_nudge_pixels
		var/facing_direction = dir
		var/previous_preserved_facing = movement_preserved_facing_direction
		movement_preserved_facing_direction = facing_direction
		var/moved = Move(loc, nudge_direction, step_x + nudge_x, step_y + nudge_y)
		movement_preserved_facing_direction = previous_preserved_facing
		dir = facing_direction
		return moved

	slideNexusDiagonalMove(move_direction)
		if(!(move_direction in list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))) return
		var/facing_direction = dir
		var/previous_preserved_facing = movement_preserved_facing_direction
		movement_preserved_facing_direction = facing_direction
		var/teleport_generation = movement_teleport_generation
		var/moved
		var/start_x
		var/start_y
		var/remaining_y = last_vector_move_requested_y - last_vector_move_actual_y
		if(remaining_y)
			start_x = Px(0)
			start_y = Py(0)
			var/y_direction = remaining_y > 0 ? NORTH : SOUTH
			moved = Move(loc, y_direction, step_x, step_y + remaining_y)
			last_vector_move_actual_x += round(Px(0) - start_x)
			last_vector_move_actual_y += round(Py(0) - start_y)
			if(movement_teleport_generation != teleport_generation)
				movement_preserved_facing_direction = previous_preserved_facing
				dir = facing_direction
				return moved
			if(Px(0) != start_x || Py(0) != start_y)
				movement_preserved_facing_direction = previous_preserved_facing
				dir = facing_direction
				return TRUE
		var/remaining_x = last_vector_move_requested_x - last_vector_move_actual_x
		if(remaining_x)
			start_x = Px(0)
			start_y = Py(0)
			var/x_direction = remaining_x > 0 ? EAST : WEST
			moved = Move(loc, x_direction, step_x + remaining_x, step_y)
			last_vector_move_actual_x += round(Px(0) - start_x)
			last_vector_move_actual_y += round(Py(0) - start_y)
			if(movement_teleport_generation != teleport_generation)
				movement_preserved_facing_direction = previous_preserved_facing
				dir = facing_direction
				return moved
			if(Px(0) != start_x || Py(0) != start_y)
				movement_preserved_facing_direction = previous_preserved_facing
				dir = facing_direction
				return TRUE
		movement_preserved_facing_direction = previous_preserved_facing
		dir = facing_direction
		return moved

	// Adapted from Woo/Tyruswoo's Gap-Nudge Movement v3.3.
	// https://secure.byond.com/developer/Woo/GapNudgeMovement
	tryNexusVectorMoveWithGapNudge(move_direction, movement_pixels)
		if(client) configureNexusVectorCollisionBounds()
		if(move_direction in list(NORTH, EAST, SOUTH, WEST))
			var/lookahead_pixels = max(1, round(movement_pixels) + 1)
			var/list/preflight_candidates = getNexusGapNudgeCandidates(move_direction, lookahead_pixels)
			if(preflight_candidates.len == 1 && nudgeNexusVectorMove(move_direction, lookahead_pixels, preflight_candidates))
				last_vector_move_requested_x = 0
				last_vector_move_requested_y = 0
				last_vector_move_actual_x = 0
				last_vector_move_actual_y = 0
				last_vector_move_attempted = 0
				last_vector_move_complete = 0
				return TRUE
		var/start_z = z
		var/moved = vector_step(src, dir_to_angle_0_360(move_direction), movement_pixels)
		if(last_vector_move_complete || z != start_z)
			clearNexusGapNudgeTarget()
			return moved
		var/resolved
		if(move_direction in list(NORTH, EAST, SOUTH, WEST))
			resolved = nudgeNexusVectorMove(move_direction)
		else
			resolved = slideNexusDiagonalMove(move_direction)
		return resolved || moved

	GetInputMoveDelay(d = NORTH, raw_mult_only)
		var/t = BASE_MOVE_DELAY
		if(!d) return t

		// apply small, focused modifiers via helpers to reduce nesting
		t = _GetInputMoveDelay_apply_basic_modifiers(t)

		if(d && d in list(NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST))
			t = _GetInputMoveDelay_diagonal_mult(t)

		if(!raw_mult_only)
			t = _GetInputMoveDelay_apply_tick_and_clean(t)

		return t

	UsingVectorMovement()
		if(!client) return
		return 1

	GetVectorMovementStatMultiplier()
		var/speed_delay = Speed_delay_mult(severity = vector_move_speed_stat_severity)
		if(!isnum(speed_delay) || speed_delay <= 0) return 1
		var/speed_multiplier = vector_move_speed_delay_baseline / speed_delay
		return Clamp(speed_multiplier, vector_move_speed_stat_minimum, vector_move_speed_stat_maximum)

	getVectorMaximumVelocity(d = NORTH, apply_diagonal_penalty = FALSE)
		if(!d) d = NORTH
		var/speed = vector_move_base_pixels_per_second * GetVectorMovementStatMultiplier()
		var/delay_mult = _GetInputMoveDelay_apply_basic_modifiers(BASE_MOVE_DELAY)
		if(apply_diagonal_penalty && isMovementDiagonal(d)) delay_mult = _GetInputMoveDelay_diagonal_mult(delay_mult)
		if(delay_mult) speed /= delay_mult
		if(walking_mode) speed = min(speed, vector_walk_speed_pixels_per_second)
		return max(0, speed)

	setWalkingMode(enabled, announce = TRUE)
		enabled = !!enabled
		if(walking_mode == enabled) return walking_mode
		walking_mode = enabled
		if(walking_mode) clampMovementVelocity(vector_walk_speed_pixels_per_second)
		if(announce)
			var/mode_label = walking_mode ? "enabled" : "disabled"
			var/mode_color = walking_mode ? "#7ee7b8" : "#aeb8c2"
			src << "<font color=[mode_color]>Walk mode [mode_label]."
			text_overlay("<center><b><font color=[mode_color]>WALK [uppertext(mode_label)]</font></b></center>", xx = -32, yy = 44, timer = 12)
		return walking_mode

	toggleWalkingMode()
		return setWalkingMode(!walking_mode)

	GetVectorMovePixels(d = NORTH)
		if(!d) d = NORTH
		var/speed = getVectorMaximumVelocity(d, apply_diagonal_penalty = TRUE) * world.tick_lag
		if(speed < 1) speed = 1
		if(vector_move_min_sleep_mult)
			var/max_pixels_for_loop = 32 / vector_move_min_sleep_mult
			if(speed > max_pixels_for_loop) speed = max_pixels_for_loop
		if(vector_move_max_pixels && speed > vector_move_max_pixels) speed = vector_move_max_pixels
		return speed

	GetVectorMoveLoopMult(speed)
		var/mult = 1
		if(speed > 32) mult = 32 / speed
		if(vector_move_min_sleep_mult && mult < vector_move_min_sleep_mult) mult = vector_move_min_sleep_mult
		return mult

	GetVectorGlideSize(speed)
		var/glide = speed
		if(vector_glide_target && speed > vector_glide_target)
			glide = vector_glide_target + (speed - vector_glide_target) * vector_glide_high_speed_scale
		if(vector_glide_min && glide < vector_glide_min) glide = vector_glide_min
		if(vector_glide_max && glide > vector_glide_max) glide = vector_glide_max
		return glide

	VectorMoveDir(d, loop_mult = 1)
		if(!d) return
		var/pixels = GetVectorMovePixels(d) * loop_mult
		if(pixels <= 0) return
		return tryNexusVectorMoveWithGapNudge(d, pixels)

	// helper: apply sight, injuries and stun modifiers
	_GetInputMoveDelay_apply_basic_modifiers(t)
		if(sight) t += 0.5
		if(!Flying)
			for(var/obj/Injuries/Leg/i in injury_list)
				t += 0.5
		if(stun_level) t += stun_level * 4
		return t

	// helper: diagonal movement multiplier
	_GetInputMoveDelay_diagonal_mult(t)
		return t * 1.15

	// helper: apply tick scaling and clean floating point
	_GetInputMoveDelay_apply_tick_and_clean(t)
		t *= world.tick_lag
		t = TickMult(t)
		t -= epsilon
		return t

	UpdateNextInputMoveTime(d = NORTH)
		next_input_move_time = world.time + GetInputMoveDelay(d)

	CanInputMove()
		if(input_disabled) return
		if(rp_mode) return
		if(in_dragon_rush) return
		if(stun_level && stun_stops_movement) return
		else return 1 //and remove this line if you enable the above line

	AlterInputDisabled(n = 1)
		input_disabled += n
		if(input_disabled < 0) input_disabled = 0
		if(input_disabled) resetMovementPhysics(clear_glide = FALSE)






	//non-core stuff

	FearSlowDown()

		var/fear_slow_down = 1
		if(chaser && getdist(src, chaser) > 20) fear_slow_down += 0.5
		return fear_slow_down

	HealthSlowdown()
		var/health_slowdown = 0
		var/health_slowdown_start = 50
		if(Health < health_slowdown_start && !undelayed && !Zombie_Power)
			var/hp = Clamp(Health,0,100)
			health_slowdown = (health_slowdown_start - hp) / 36
		return health_slowdown
