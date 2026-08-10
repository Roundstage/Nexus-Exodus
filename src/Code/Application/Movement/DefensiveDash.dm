var
	defensive_dash_distance_pixels = 224
	defensive_dash_cooldown_deciseconds = 6
	defensive_dash_stamina_cost = 3
	defensive_dash_max_velocity = 360
	defensive_dash_acceleration = 1440
	defensive_dash_deceleration = 2400
	defensive_dash_evasion_window_deciseconds = 1.5
	defensive_dash_velocity_transfer = 0.2
	defensive_dash_afterimage_interval = 0.25

mob/var/tmp
	defensive_dashing = FALSE
	defensive_dash_ready_at = 0
	defensive_dash_evasion_until = 0

obj/Blast/var/defensive_dash_evadable = TRUE

mob/proc
	getDefensiveDashDirection(direction_override)
		if(direction_override in list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)) return direction_override
		var/input_direction = move_dir()
		if(input_direction) return input_direction
		if(last_direction_pressed in list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)) return last_direction_pressed
		if(dir in list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)) return dir

	canDefensiveDash(direction_override)
		if(!getDefensiveDashDirection(direction_override)) return FALSE
		if(!isturf(loc) || !CanInputMove() || !Can_Move()) return FALSE
		if(defensive_dashing || active_skill_motion || movementPhysicsHardLocked()) return FALSE
		if(grabbedObject || grabber || attacking > 1) return FALSE
		if(world.time < defensive_dash_ready_at) return FALSE
		if(stamina < defensive_dash_stamina_cost) return FALSE
		return TRUE

	isDefensiveDashEvading(obj/Blast/projectile)
		if(!defensive_dashing || !active_skill_motion) return FALSE
		if(active_skill_motion.moved_pixels <= 0 && skill_motion_internal_move != active_skill_motion) return FALSE
		if(world.time >= defensive_dash_evasion_until) return FALSE
		if(KO || KB || (Frozen && !paralysis_immune)) return FALSE
		if(projectile)
			if(!projectile.defensive_dash_evadable || projectile.Beam || projectile.Explosive || projectile.Size) return FALSE
		return TRUE

	showDefensiveDashEffect()
		AfterImage(TickMult(7), 2)
		var/dash_sound = getNexusShonenSound("dodge")
		if(dash_sound) player_view(12, src) << sound(dash_sound, volume = 18)

	tryDefensiveDash(direction_override)
		set waitfor = 0
		var/dash_direction = getDefensiveDashDirection(direction_override)
		if(!canDefensiveDash(dash_direction)) return FALSE
		defensive_dashing = TRUE
		defensive_dash_ready_at = world.time + defensive_dash_cooldown_deciseconds
		defensive_dash_evasion_until = world.time + defensive_dash_evasion_window_deciseconds
		AddStamina(-defensive_dash_stamina_cost)
		showDefensiveDashEffect()
		var/result = runNexusSkillLine(
			dash_direction,
			defensive_dash_distance_pixels,
			defensive_dash_max_velocity,
			defensive_dash_acceleration,
			defensive_dash_deceleration,
			defensive_dash_afterimage_interval,
			defensive_dash_velocity_transfer)
		defensive_dashing = FALSE
		if(!result) defensive_dash_evasion_until = 0
		return result
