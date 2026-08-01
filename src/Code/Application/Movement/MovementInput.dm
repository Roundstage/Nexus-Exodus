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

mob/proc
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

	GetVectorMovePixels(d = NORTH)
		if(!d) d = NORTH
		// debug: force a high base speed (pixels per second) instead of stat-based scaling
		var/speed = 70
		var/delay_mult = GetInputMoveDelay(d, raw_mult_only = 1)
		if(delay_mult) speed /= delay_mult
		speed *= world.tick_lag
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
		return vector_step(src, dir_to_angle_0_360(d), pixels)

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
