#define NEXUS_SKILL_MOTION_REACHED 1
#define NEXUS_SKILL_MOTION_INTERRUPTED 0

var/skill_motion_default_acceleration = 240
var/skill_motion_default_deceleration = 300
var/skill_motion_default_max_velocity = 120
var/skill_motion_stop_velocity = 0.5
var/skill_motion_stall_frames = 3
var/skill_auto_dodge_distance_pixels = 32
var/skill_auto_dodge_max_velocity = 160
var/skill_auto_dodge_acceleration = 320
var/skill_auto_dodge_deceleration = 400

mob
	var/tmp/datum/NexusSkillMotion/active_skill_motion
	var/tmp/datum/NexusSkillMotion/skill_motion_internal_move
	var/tmp/skill_motion_generation = 0
	var/tmp/skill_movement_velocity_x = 0
	var/tmp/skill_movement_velocity_y = 0
	var/tmp/last_skill_motion_pixels = 0
	var/tmp/list/last_skill_motion_contacts = list()
	var/tmp/list/last_skill_motion_evaded_contacts = list()

datum/NexusSkillMotionResult
	var/valid = FALSE
	var/reached = FALSE
	var/generation = 0
	var/moved_pixels = 0
	var/list/contacted_mobs = list()
	var/list/evaded_contacts = list()

	proc/reset()
		valid = FALSE
		reached = FALSE
		generation = 0
		moved_pixels = 0
		contacted_mobs = list()
		evaded_contacts = list()

	proc/capture(datum/NexusSkillMotion/motion, motion_result)
		reset()
		if(!motion) return
		valid = TRUE
		reached = motion_result == NEXUS_SKILL_MOTION_REACHED
		generation = motion.generation
		moved_pixels = motion.moved_pixels
		contacted_mobs = motion.contacted_mobs.Copy()
		evaded_contacts = motion.evaded_contacts.Copy()

datum/NexusSkillMotion
	var/mob/subject
	var/atom/movable/target
	var/tracking_target = FALSE
	var/movement_direction
	var/movement_vector_x = 0
	var/movement_vector_y = 0
	var/max_distance_pixels = 0
	var/stop_distance_pixels = 0
	var/max_velocity = 0
	var/acceleration = 0
	var/deceleration = 0
	var/afterimage_interval = 0
	var/velocity_transfer = 0
	var/pass_mobs = FALSE
	var/require_selected_target = FALSE
	var/list/contacted_mobs = list()
	var/list/evaded_contacts = list()
	var/generation = 0
	var/start_z = 0
	var/start_teleport_generation = 0
	var/moved_pixels = 0
	var/budget_pixels = 0
	var/stalled_frames = 0
	var/next_afterimage_time = 0
	var/reached_goal = FALSE
	var/interrupted = FALSE

	New(mob/new_subject, atom/movable/new_target, new_direction, new_max_distance, new_stop_distance, new_max_velocity, new_acceleration, new_deceleration, new_afterimage_interval, new_velocity_transfer, new_pass_mobs, new_require_selected_target, new_movement_vector_x, new_movement_vector_y)
		subject = new_subject
		target = new_target
		tracking_target = new_target ? TRUE : FALSE
		movement_direction = new_direction
		movement_vector_x = new_movement_vector_x
		movement_vector_y = new_movement_vector_y
		max_distance_pixels = max(0, new_max_distance)
		stop_distance_pixels = max(0, new_stop_distance)
		max_velocity = max(0, new_max_velocity)
		acceleration = max(0, new_acceleration)
		deceleration = max(0, new_deceleration)
		afterimage_interval = max(0, new_afterimage_interval)
		velocity_transfer = Clamp(new_velocity_transfer, 0, 1)
		pass_mobs = new_pass_mobs ? TRUE : FALSE
		require_selected_target = new_require_selected_target ? TRUE : FALSE
		if(subject)
			generation = subject.skill_motion_generation
			start_z = subject.z
			start_teleport_generation = subject.movement_teleport_generation
		. = ..()

	proc/canContinue()
		if(interrupted || !subject) return FALSE
		if(subject.active_skill_motion != src || subject.skill_motion_generation != generation) return FALSE
		if(!isturf(subject.loc) || subject.z != start_z) return FALSE
		if(subject.movement_teleport_generation != start_teleport_generation) return FALSE
		if(subject.KO || subject.KB) return FALSE
		if(subject.lunge_attacking && subject.lunge_evaded) return FALSE
		if(tracking_target && !target) return FALSE
		if(target && (!target.z || target.z != subject.z)) return FALSE
		if(require_selected_target && subject.selected_target != target) return FALSE
		return TRUE

	proc/targetDeltaX()
		if(!subject || !target) return 0
		return (target.bound_center_x() - subject.bound_center_x()) * world.icon_size

	proc/targetDeltaY()
		if(!subject || !target) return 0
		return (target.bound_center_y() - subject.bound_center_y()) * world.icon_size

	proc/remainingPixels()
		var/path_remaining = max(0, max_distance_pixels - budget_pixels)
		if(!target) return path_remaining
		var/delta_x = targetDeltaX()
		var/delta_y = targetDeltaY()
		var/maximum_component = max(abs(delta_x), abs(delta_y))
		var/euclidean_distance = sqrt(delta_x ** 2 + delta_y ** 2)
		if(maximum_component > 0)
			path_remaining *= euclidean_distance / maximum_component
		var/target_remaining = 0
		if(maximum_component > stop_distance_pixels)
			target_remaining = euclidean_distance * (maximum_component - stop_distance_pixels) / maximum_component
		return min(path_remaining, target_remaining)

	proc/goalReached()
		if(target)
			return max(abs(targetDeltaX()), abs(targetDeltaY())) <= stop_distance_pixels
		if(tracking_target) return FALSE
		return moved_pixels >= max_distance_pixels - 0.0001

	proc/travelBudgetExhausted()
		return budget_pixels >= max_distance_pixels - 0.0001

	proc/updateDesiredVelocity(duration_deciseconds)
		if(!subject) return
		var/remaining = remainingPixels()
		if(goalReached())
			reached_goal = TRUE
			return
		if(travelBudgetExhausted())
			interrupted = TRUE
			return
		var/direction_x
		var/direction_y
		if(target)
			direction_x = targetDeltaX()
			direction_y = targetDeltaY()
			var/intent_direction = XYtoDir(direction_x, direction_y)
			if(intent_direction) subject.dir = intent_direction
		else if(movement_vector_x || movement_vector_y)
			direction_x = movement_vector_x
			direction_y = movement_vector_y
			var/vector_intent_direction = XYtoDir(direction_x, direction_y)
			if(vector_intent_direction) subject.dir = vector_intent_direction
		else
			var/angle = dir_to_angle_0_360(movement_direction)
			direction_x = sin(angle)
			direction_y = cos(angle)
			if(movement_direction) subject.dir = movement_direction
		var/direction_magnitude = sqrt(direction_x ** 2 + direction_y ** 2)
		if(!direction_magnitude)
			reached_goal = TRUE
			return
		direction_x /= direction_magnitude
		direction_y /= direction_magnitude
		var/braking_velocity = sqrt(max(0, 2 * deceleration * remaining))
		var/desired_speed = min(max_velocity, braking_velocity)
		var/desired_x = direction_x * desired_speed
		var/desired_y = direction_y * desired_speed
		var/change_x = desired_x - subject.skill_movement_velocity_x
		var/change_y = desired_y - subject.skill_movement_velocity_y
		var/change_magnitude = sqrt(change_x ** 2 + change_y ** 2)
		var/current_velocity = subject.skillMotionVelocityMagnitude()
		var/velocity_response = desired_speed < current_velocity ? deceleration : acceleration
		var/max_change = velocity_response * max(0, duration_deciseconds)
		if(change_magnitude > max_change && change_magnitude)
			var/change_scale = max_change / change_magnitude
			change_x *= change_scale
			change_y *= change_scale
		subject.skill_movement_velocity_x += change_x
		subject.skill_movement_velocity_y += change_y
		current_velocity = subject.skillMotionVelocityMagnitude()
		if(current_velocity > max_velocity && current_velocity)
			var/velocity_scale = max_velocity / current_velocity
			subject.skill_movement_velocity_x *= velocity_scale
			subject.skill_movement_velocity_y *= velocity_scale

	proc/projectBlockedVelocity()
		if(!subject || !subject.last_vector_move_attempted) return
		if(subject.last_vector_move_requested_x != subject.last_vector_move_actual_x)
			subject.skill_movement_velocity_x = 0
			subject.vector_fraction_x = 0
		if(subject.last_vector_move_requested_y != subject.last_vector_move_actual_y)
			subject.skill_movement_velocity_y = 0
			subject.vector_fraction_y = 0

	proc/collectContacts()
		if(!pass_mobs || !subject) return
		for(var/mob/candidate in range(1, subject))
			if(candidate == subject || candidate in contacted_mobs) continue
			if(bounds_dist(subject, candidate) <= 0)
				contacted_mobs += candidate
				if(candidate.isDefensiveDashEvading()) evaded_contacts += candidate

	proc/processStep(duration_deciseconds)
		if(!canContinue())
			interrupted = TRUE
			return FALSE
		if(goalReached())
			reached_goal = TRUE
			return FALSE
		if(travelBudgetExhausted())
			interrupted = TRUE
			return FALSE
		updateDesiredVelocity(duration_deciseconds)
		if(reached_goal) return FALSE
		var/velocity = subject.skillMotionVelocityMagnitude()
		if(velocity <= skill_motion_stop_velocity && !remainingPixels())
			reached_goal = TRUE
			return FALSE
		var/movement_x = subject.skill_movement_velocity_x * duration_deciseconds
		var/movement_y = subject.skill_movement_velocity_y * duration_deciseconds
		var/requested_pixels = sqrt(movement_x ** 2 + movement_y ** 2)
		var/remaining = remainingPixels()
		if(requested_pixels > remaining && requested_pixels)
			var/request_scale = remaining / requested_pixels
			movement_x *= request_scale
			movement_y *= request_scale
			requested_pixels = remaining
		if(requested_pixels <= 0) return TRUE
		var/start_x = subject.Px(0)
		var/start_y = subject.Py(0)
		var/teleport_generation = subject.movement_teleport_generation
		subject.movement_last_frame_pixels = requested_pixels
		subject.glide_size = subject.GetVectorGlideSize(requested_pixels)
		subject.skill_motion_internal_move = src
		var/moved = subject.tryNexusInertiaMove(movement_x, movement_y)
		if(subject && subject.skill_motion_internal_move == src) subject.skill_motion_internal_move = null
		if(!subject || subject.movement_teleport_generation != teleport_generation || !canContinue())
			interrupted = TRUE
			return FALSE
		var/actual_x = subject.Px(0) - start_x
		var/actual_y = subject.Py(0) - start_y
		var/actual_pixels = sqrt(actual_x ** 2 + actual_y ** 2)
		moved_pixels += actual_pixels
		if(target) budget_pixels += max(abs(actual_x), abs(actual_y))
		else budget_pixels += actual_pixels
		collectContacts()
		subject.movement_last_frame_pixels = actual_pixels
		if(actual_pixels) subject.glide_size = subject.GetVectorGlideSize(actual_pixels)
		else subject.glide_size = 0
		projectBlockedVelocity()
		if(subject.last_vector_move_attempted && requested_pixels >= 1 && actual_pixels < 0.01)
			stalled_frames++
		else stalled_frames = 0
		if(stalled_frames >= max(1, skill_motion_stall_frames))
			interrupted = TRUE
			return FALSE
		if(goalReached())
			reached_goal = TRUE
			return FALSE
		if(travelBudgetExhausted())
			interrupted = TRUE
			return FALSE
		return moved || !subject.last_vector_move_attempted

	proc/showAfterimage()
		if(!subject || afterimage_interval <= 0 || world.time < next_afterimage_time) return
		next_afterimage_time = world.time + afterimage_interval
		subject.AfterImage(TickMult(8), 2)

	proc/executeMotion()
		if(!canContinue() || !movement_direction && !target && !movement_vector_x && !movement_vector_y || max_distance_pixels <= 0 || max_velocity <= 0 || acceleration <= 0 || deceleration <= 0)
			interrupted = TRUE
			return NEXUS_SKILL_MOTION_INTERRUPTED
		var/physics_step = max(0.001, vector_movement_physics_step_deciseconds)
		var/time_accumulator = 0
		var/first_step = TRUE
		var/start_time = world.time
		var/maximum_duration = max(5, max_distance_pixels / max_velocity * 4 + 5)
		while(canContinue() && !reached_goal && world.time - start_time <= maximum_duration)
			showAfterimage()
			if(first_step)
				processStep(min(max(0.001, world.tick_lag), physics_step))
				first_step = FALSE
				continue
			sleep(world.tick_lag)
			if(!canContinue()) break
			time_accumulator += max(0, world.tick_lag)
			var/steps = 0
			while(time_accumulator + 0.000001 >= physics_step && steps < 12 && canContinue() && !reached_goal)
				time_accumulator = max(0, time_accumulator - physics_step)
				processStep(physics_step)
				steps++
			if(steps >= 12 && time_accumulator >= physics_step) time_accumulator = 0
		if(!reached_goal && !interrupted) interrupted = TRUE
		return reached_goal ? NEXUS_SKILL_MOTION_REACHED : NEXUS_SKILL_MOTION_INTERRUPTED

mob/proc
	skillMotionVelocityMagnitude()
		return sqrt(skill_movement_velocity_x ** 2 + skill_movement_velocity_y ** 2)

	ownsNexusSkillMotion(datum/NexusSkillMotion/motion)
		return motion && active_skill_motion == motion && skill_motion_generation == motion.generation

	cancelNexusSkillMotion(reason)
		skill_motion_generation++
		if(active_skill_motion)
			active_skill_motion.interrupted = TRUE
			active_skill_motion = null
		skill_motion_internal_move = null
		skill_movement_velocity_x = 0
		skill_movement_velocity_y = 0
		movement_last_frame_pixels = 0
		if(reason) clearNexusGapNudgeTarget()

	runNexusSkillMotion(atom/movable/target, movement_direction, max_distance_pixels, stop_distance_pixels = 0, max_velocity = skill_motion_default_max_velocity, acceleration = skill_motion_default_acceleration, deceleration = skill_motion_default_deceleration, afterimage_interval = 0.5, velocity_transfer = 0, pass_mobs = FALSE, require_selected_target = FALSE, datum/NexusSkillMotionResult/result_capture, movement_vector_x = 0, movement_vector_y = 0)
		if(result_capture) result_capture.reset()
		cancelNexusSkillMotion()
		resetMovementPhysics(clear_glide = FALSE)
		skill_motion_generation++
		last_skill_motion_contacts = list()
		last_skill_motion_evaded_contacts = list()
		var/datum/NexusSkillMotion/motion = new(src, target, movement_direction, max_distance_pixels, stop_distance_pixels, max_velocity, acceleration, deceleration, afterimage_interval, velocity_transfer, pass_mobs, require_selected_target, movement_vector_x, movement_vector_y)
		active_skill_motion = motion
		var/result = motion.executeMotion()
		var/owns_motion = ownsNexusSkillMotion(motion)
		if(!owns_motion)
			del(motion)
			return result
		last_skill_motion_pixels = motion.moved_pixels
		last_skill_motion_contacts = motion.contacted_mobs.Copy()
		last_skill_motion_evaded_contacts = motion.evaded_contacts.Copy()
		if(result_capture) result_capture.capture(motion, result)
		var/transfer_x = skill_movement_velocity_x * motion.velocity_transfer
		var/transfer_y = skill_movement_velocity_y * motion.velocity_transfer
		if(active_skill_motion == motion) active_skill_motion = null
		if(skill_motion_internal_move == motion) skill_motion_internal_move = null
		skill_movement_velocity_x = 0
		skill_movement_velocity_y = 0
		if(result && motion.velocity_transfer)
			movement_velocity_x = transfer_x
			movement_velocity_y = transfer_y
			clampMovementVelocity(getMovementMaximumVelocity(movement_direction || dir))
		else
			movement_velocity_x = 0
			movement_velocity_y = 0
		var/has_carry = hasMovementMomentum()
		if(!has_carry) glide_size = 0
		del(motion)
		if(has_carry || hasMovementInput()) move_loop()
		return result

	runNexusSkillLine(movement_direction, distance_pixels, max_velocity = skill_motion_default_max_velocity, acceleration = skill_motion_default_acceleration, deceleration = skill_motion_default_deceleration, afterimage_interval = 0.5, velocity_transfer = 0, pass_mobs = FALSE, datum/NexusSkillMotionResult/result_capture)
		return runNexusSkillMotion(null, movement_direction, distance_pixels, 0, max_velocity, acceleration, deceleration, afterimage_interval, velocity_transfer, pass_mobs, FALSE, result_capture)

	runNexusSkillVector(direction_x, direction_y, distance_pixels, max_velocity = skill_motion_default_max_velocity, acceleration = skill_motion_default_acceleration, deceleration = skill_motion_default_deceleration, afterimage_interval = 0.5, velocity_transfer = 0, pass_mobs = FALSE, datum/NexusSkillMotionResult/result_capture)
		if(!direction_x && !direction_y) return NEXUS_SKILL_MOTION_INTERRUPTED
		return runNexusSkillMotion(null, XYtoDir(direction_x, direction_y), distance_pixels, 0, max_velocity, acceleration, deceleration, afterimage_interval, velocity_transfer, pass_mobs, FALSE, result_capture, direction_x, direction_y)

	runNexusSkillApproach(atom/movable/target, maximum_distance_pixels, stop_distance_pixels = 32, max_velocity = skill_motion_default_max_velocity, acceleration = skill_motion_default_acceleration, deceleration = skill_motion_default_deceleration, afterimage_interval = 0.5, require_selected_target = TRUE, datum/NexusSkillMotionResult/result_capture)
		if(!target) return NEXUS_SKILL_MOTION_INTERRUPTED
		return runNexusSkillMotion(target, get_dir(src, target), maximum_distance_pixels, stop_distance_pixels, max_velocity, acceleration, deceleration, afterimage_interval, 0, FALSE, require_selected_target, result_capture)

	canStartNexusVectorDodge(movement_direction)
		if(!(movement_direction in list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))) return FALSE
		if(!isturf(loc) || KO || KB) return FALSE
		var/turf/dodge_turf = get_step(src, movement_direction)
		if(!dodge_turf || !Can_Enter(dodge_turf, 1)) return FALSE
		return TRUE

	runNexusVectorDodge(movement_direction)
		set waitfor = 0
		runNexusSkillLine(movement_direction, skill_auto_dodge_distance_pixels, skill_auto_dodge_max_velocity, skill_auto_dodge_acceleration, skill_auto_dodge_deceleration, 0, 0)

	tryNexusVectorDodge(movement_direction)
		if(!canStartNexusVectorDodge(movement_direction)) return FALSE
		runNexusVectorDodge(movement_direction)
		return TRUE
