var/vector_movement_inertia_enabled = 1
var/vector_movement_acceleration_per_decisecond = 2.4
var/vector_movement_velocity_retention_per_decisecond = 0.117649
var/vector_movement_stop_velocity = 0.3
var/vector_movement_physics_step_deciseconds = 10 / 60
var/vector_movement_cardinal_gap_ratio = 0.2

mob/var/tmp
	movement_acceleration_x = 0
	movement_acceleration_y = 0
	movement_velocity_x = 0
	movement_velocity_y = 0
	movement_last_frame_pixels = 0
	movement_teleport_generation = 0
	movement_preserved_facing_direction = 0
	movement_physics_time_accumulator = 0

mob/proc
	usingMovementInertia()
		if(!vector_movement_inertia_enabled) return
		return UsingVectorMovement()

	hasMovementInput()
		return north || south || east || west

	getMovementInputX()
		return (east ? 1 : 0) - (west ? 1 : 0)

	getMovementInputY()
		return (north ? 1 : 0) - (south ? 1 : 0)

	isMovementCardinal(d)
		return d == NORTH || d == EAST || d == SOUTH || d == WEST

	isMovementDiagonal(d)
		return d == NORTHEAST || d == NORTHWEST || d == SOUTHEAST || d == SOUTHWEST

	getMovementGapDirection(movement_x, movement_y)
		var/absolute_x = abs(movement_x)
		var/absolute_y = abs(movement_y)
		var/cardinal_ratio = Clamp(vector_movement_cardinal_gap_ratio, 0, 1)
		if(absolute_x && absolute_y <= absolute_x * cardinal_ratio) return movement_x > 0 ? EAST : WEST
		if(absolute_y && absolute_x <= absolute_y * cardinal_ratio) return movement_y > 0 ? NORTH : SOUTH
		return XYtoDir(movement_x, movement_y)

	movementVelocityMagnitude()
		return sqrt(movement_velocity_x ** 2 + movement_velocity_y ** 2)

	movementFramePixels()
		if(world.tick_lag <= 0) return 0
		return movementVelocityMagnitude() * world.tick_lag

	hasMovementMomentum()
		return movementVelocityMagnitude() > vector_movement_stop_velocity

	movementDurationRetention(retention_per_decisecond, duration_deciseconds)
		retention_per_decisecond = Clamp(retention_per_decisecond, 0, 1)
		if(duration_deciseconds <= 0) return 1
		return retention_per_decisecond ** duration_deciseconds

	getMovementMaximumVelocity(d = NORTH)
		return getVectorMaximumVelocity(d, apply_diagonal_penalty = FALSE)

	resetMovementPhysics(clear_fraction = TRUE, clear_glide = TRUE)
		movement_acceleration_x = 0
		movement_acceleration_y = 0
		movement_velocity_x = 0
		movement_velocity_y = 0
		movement_last_frame_pixels = 0
		movement_preserved_facing_direction = 0
		movement_physics_time_accumulator = 0
		if(clear_fraction)
			vector_fraction_x = 0
			vector_fraction_y = 0
		clearNexusGapNudgeTarget()
		if(clear_glide) glide_size = 0

	clampMovementVelocity(max_velocity)
		max_velocity = max(0, max_velocity)
		var/current_velocity = movementVelocityMagnitude()
		if(!current_velocity || current_velocity <= max_velocity) return current_velocity
		var/scale = max_velocity / current_velocity
		movement_velocity_x *= scale
		movement_velocity_y *= scale
		return max_velocity

	accelerateMovementVelocity(input_x, input_y, acceleration_delta, max_velocity)
		movement_acceleration_x = 0
		movement_acceleration_y = 0
		var/input_magnitude = sqrt(input_x ** 2 + input_y ** 2)
		if(input_magnitude && acceleration_delta > 0)
			movement_acceleration_x = input_x / input_magnitude * acceleration_delta
			movement_acceleration_y = input_y / input_magnitude * acceleration_delta
			movement_velocity_x += movement_acceleration_x
			movement_velocity_y += movement_acceleration_y
		return clampMovementVelocity(max_velocity)

	retainMovementVelocity(retention, stop_velocity = -1)
		retention = Clamp(retention, 0, 1)
		movement_velocity_x *= retention
		movement_velocity_y *= retention
		if(stop_velocity >= 0)
			if(abs(movement_velocity_x) <= stop_velocity) movement_velocity_x = 0
			if(abs(movement_velocity_y) <= stop_velocity) movement_velocity_y = 0
		var/current_velocity = movementVelocityMagnitude()
		if(stop_velocity >= 0 && current_velocity <= stop_velocity)
			movement_velocity_x = 0
			movement_velocity_y = 0
			current_velocity = 0
		return current_velocity

	resolveMovementVelocityCollision()
		if(!last_vector_move_attempted) return
		var/x_blocked = last_vector_move_requested_x != last_vector_move_actual_x
		var/y_blocked = last_vector_move_requested_y != last_vector_move_actual_y
		if(x_blocked)
			movement_velocity_x = 0
			vector_fraction_x = 0
		if(y_blocked)
			movement_velocity_y = 0
			vector_fraction_y = 0

	handleMovementPhysicsLockedInput(input_direction)
		if(!input_direction || !CanInputMove() || !move || Disabled() || icon_state == "KB") return
		if(lunge_attacking || evading || attack_forced_movement || in_dragon_rush || dragon_rush_attack_active) return
		if(strangling || cant_move_due_to_hakai || shockwaving || Giving_Power) return
		if(IsGreatApe() && !Great_Ape_control) return
		if(BeamStruggling()) return
		if(dash_attacking)
			if(input_direction == turn(dir, 90)) desired_dash_dir = turn(dir, 45)
			if(input_direction == turn(dir, -90)) desired_dash_dir = turn(dir, -45)
			return
		if(Beam_stunned())
			StruggleAgainstBeamStun()
			return
		if(grabber && !KO)
			if(!struggle_timer) spawn Grab_Struggle()
			return
		if(moving_charge == 1)
			if(dir != input_direction)
				dir = input_direction
				return
			moving_charge = 2
		if(attack_barrier_obj && attack_barrier_obj.Firing_Attack_Barrier)
			dir = input_direction
			return
		if(blocking || power_attacking || Regeneration_Skill || Shadow_Sparring)
			dir = input_direction
			return
		if(Ship)
			if(istype(Ship, /obj/Ships/Spacepod) && loc != Ship) SafeTeleport(Ship)
			if(Ship && !Ship.Moving && Ship.Ki > 0)
				Ship.Move_Randomly = 0
				Ship.Moving = 1
				Ship.MoveReset()
				step(Ship, input_direction)
				if(Ship) Ship.Fuel()
			return
		if(car) car.dir = input_direction

	movementPhysicsHardLocked()
		if(Ship || car) return TRUE
		if(active_skill_motion) return TRUE
		if(KB || KO || lunge_attacking || evading || dash_attacking || attack_forced_movement || in_dragon_rush || dragon_rush_attack_active) return TRUE
		if(strangling || cant_move_due_to_hakai || shockwaving || Giving_Power) return TRUE
		if(moving_charge == 1 || blocking || power_attacking || Regeneration_Skill || Shadow_Sparring) return TRUE
		if(grabber && !KO) return TRUE
		if(IsGreatApe() && !Great_Ape_control) return TRUE
		if(BeamStruggling() || Beam_stunned()) return TRUE
		var/bank_lock_age = world.time - last_bank_bump
		if(last_bank_bump > 0 && bank_lock_age >= 0 && bank_lock_age < 10) return TRUE
		if(islist(active_prompts) && ("bank" in active_prompts)) return TRUE
		return FALSE

	movementPhysicsSuspended(ignore_client = FALSE, validate_standard_movement = TRUE)
		if(!vector_movement_inertia_enabled) return TRUE
		if(!ignore_client && !UsingVectorMovement()) return TRUE
		if(!isturf(loc)) return TRUE
		if(movementPhysicsHardLocked()) return TRUE
		if(validate_standard_movement && (!CanInputMove() || !Can_Move())) return TRUE
		return FALSE

	updateMovementVelocity(input_direction, duration_deciseconds = world.tick_lag)
		var/input_x = getMovementInputX()
		var/input_y = getMovementInputY()
		var/speed_direction = input_direction
		if(!speed_direction) speed_direction = XYtoDir(movement_velocity_x, movement_velocity_y)
		if(!speed_direction) speed_direction = last_direction_pressed
		if(!speed_direction) speed_direction = NORTH
		var/max_velocity = getMovementMaximumVelocity(speed_direction)
		var/acceleration_delta = max_velocity * vector_movement_acceleration_per_decisecond * max(0, duration_deciseconds)
		accelerateMovementVelocity(input_x, input_y, acceleration_delta, max_velocity)
		return max_velocity

	applyMovementFrameFriction(duration_deciseconds = world.tick_lag)
		var/retention = movementDurationRetention(vector_movement_velocity_retention_per_decisecond, duration_deciseconds)
		if(retainMovementVelocity(retention, vector_movement_stop_velocity)) return
		movement_acceleration_x = 0
		movement_acceleration_y = 0
		movement_physics_time_accumulator = 0
		vector_fraction_x = 0
		vector_fraction_y = 0
		clearNexusGapNudgeTarget()
		glide_size = 0

	tryNexusInertiaMove(movement_x, movement_y)
		var/movement_pixels = sqrt(movement_x ** 2 + movement_y ** 2)
		if(movement_pixels <= 0) return
		if(client) configureNexusVectorCollisionBounds()
		var/velocity_direction = XYtoDir(movement_x, movement_y)
		var/gap_direction = getMovementGapDirection(movement_x, movement_y)
		var/facing_direction = dir
		movement_preserved_facing_direction = facing_direction
		if(isMovementCardinal(gap_direction))
			var/cardinal_pixels = (gap_direction == EAST || gap_direction == WEST) ? abs(movement_x) : abs(movement_y)
			var/lookahead_pixels = max(1, round(cardinal_pixels) + 1)
			var/list/preflight_candidates = getNexusGapNudgeCandidates(gap_direction, lookahead_pixels)
			if(preflight_candidates.len == 1 && nudgeNexusVectorMove(gap_direction, lookahead_pixels, preflight_candidates))
				last_vector_move_requested_x = 0
				last_vector_move_requested_y = 0
				last_vector_move_actual_x = 0
				last_vector_move_actual_y = 0
				last_vector_move_attempted = 0
				last_vector_move_complete = 0
				movement_preserved_facing_direction = 0
				dir = facing_direction
				return TRUE
		var/start_z = z
		var/start_teleport_generation = movement_teleport_generation
		var/moved = vector_step(src, step_speed = movement_pixels, requested_x = movement_x, requested_y = movement_y, movement_direction = velocity_direction)
		if(movement_teleport_generation != start_teleport_generation)
			movement_preserved_facing_direction = 0
			dir = facing_direction
			return moved
		if(last_vector_move_complete || z != start_z)
			clearNexusGapNudgeTarget()
			movement_preserved_facing_direction = 0
			dir = facing_direction
			return moved
		var/nudged
		if(isMovementCardinal(gap_direction))
			nudged = nudgeNexusVectorMove(gap_direction)
		if(movement_teleport_generation != start_teleport_generation)
			movement_preserved_facing_direction = 0
			dir = facing_direction
			return nudged || moved
		var/slid
		if(!nudged && isMovementDiagonal(gap_direction))
			slid = slideNexusDiagonalMove(velocity_direction)
		if(movement_teleport_generation != start_teleport_generation)
			movement_preserved_facing_direction = 0
			dir = facing_direction
			return slid || moved
		if(!nudged) resolveMovementVelocityCollision()
		if(movement_teleport_generation != start_teleport_generation)
			movement_preserved_facing_direction = 0
			dir = facing_direction
			return TRUE
		movement_preserved_facing_direction = 0
		dir = facing_direction
		return nudged || slid || moved

	processMovementPhysicsStep(input_direction, duration_deciseconds)
		updateMovementVelocity(input_direction, duration_deciseconds)
		if(movementVelocityMagnitude() <= vector_movement_stop_velocity)
			movement_last_frame_pixels = 0
			applyMovementFrameFriction(duration_deciseconds)
			return
		var/movement_x = movement_velocity_x * duration_deciseconds
		var/movement_y = movement_velocity_y * duration_deciseconds
		var/requested_pixels = sqrt(movement_x ** 2 + movement_y ** 2)
		movement_last_frame_pixels = requested_pixels
		glide_size = GetVectorGlideSize(requested_pixels)
		var/start_z = z
		var/start_teleport_generation = movement_teleport_generation
		var/start_x = Px(0)
		var/start_y = Py(0)
		var/moved = tryNexusInertiaMove(movement_x, movement_y)
		if(movement_teleport_generation != start_teleport_generation) return moved
		if(z != start_z || !isturf(loc))
			resetMovementPhysics(clear_glide = FALSE)
			return moved
		var/actual_x = Px(0) - start_x
		var/actual_y = Py(0) - start_y
		movement_last_frame_pixels = sqrt(actual_x ** 2 + actual_y ** 2)
		if(movement_last_frame_pixels)
			glide_size = GetVectorGlideSize(movement_last_frame_pixels)
		else glide_size = 0
		applyMovementFrameFriction(duration_deciseconds)
		return moved

	processMovementPhysicsFrame(input_direction)
		var/physics_step = max(0.001, vector_movement_physics_step_deciseconds)
		movement_physics_time_accumulator += max(0, world.tick_lag)
		var/start_x = Px(0)
		var/start_y = Py(0)
		var/start_z = z
		var/start_teleport_generation = movement_teleport_generation
		var/moved
		var/physics_steps = 0
		while(movement_physics_time_accumulator + 0.000001 >= physics_step && physics_steps < 12)
			movement_physics_time_accumulator = max(0, movement_physics_time_accumulator - physics_step)
			if(processMovementPhysicsStep(input_direction, physics_step)) moved = TRUE
			physics_steps++
			if(movement_teleport_generation != start_teleport_generation || z != start_z || !isturf(loc)) break
		if(physics_steps >= 12 && movement_physics_time_accumulator >= physics_step)
			movement_physics_time_accumulator = 0
		if(!physics_steps || movement_teleport_generation != start_teleport_generation || z != start_z || !isturf(loc)) return moved
		var/actual_x = Px(0) - start_x
		var/actual_y = Py(0) - start_y
		movement_last_frame_pixels = sqrt(actual_x ** 2 + actual_y ** 2)
		if(movement_last_frame_pixels) glide_size = GetVectorGlideSize(movement_last_frame_pixels)
		else glide_size = 0
		return moved
