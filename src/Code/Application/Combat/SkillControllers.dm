var/global/datum/SkillControllerRegistry/skill_controller_registry = new

datum/SkillControllerRegistry
	var/list/controllers = list()

	New()
		controllers = list()
		register(new /datum/SkillController/GuidedBlast)
		register(new /datum/SkillController/GuidedBomb)

	proc/register(datum/SkillController/controller)
		if(!controller || !controller.id) return
		controllers[controller.id] = controller

	proc/get(id)
		return controllers[id]

datum/SkillController
	var/id

	proc/getControlDirection(mob/user)
		if(!user) return SOUTH
		if(user.last_direction_pressed in list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
			return user.last_direction_pressed
		return user.dir

datum/SkillController/GuidedBlast
	id = SKILL_CONTROLLER_GUIDED_BLAST

	proc/execute(mob/user, obj/Blast/blast, datum/SkillDefinition/def, obj/source_skill)
		if(!user || !blast) return
		var/control_range = def ? def.control_range : 0
		if(!control_range) control_range = 25
		var/bump_limit = def ? def.control_bumps : 0
		var/allow_bump = bump_limit > 0
		var/loop_delay = def ? def.control_delay : 0
		if(!loop_delay) loop_delay = ki_projectile_step_delay
		var/avoid_owner = def ? def.control_avoid_owner : 0
		var/avoid_owner_chance = def ? def.control_avoid_owner_chance : 0
		if(!avoid_owner_chance) avoid_owner_chance = 85
		var/stop_on_deflect = def ? def.control_stop_on_deflect : 0
		var/bumps = bump_limit
		var/move_speed = blast.vector_speed
		if(!move_speed) move_speed = 32
		var/velocity_x = 0
		var/velocity_y = 0
		blast.stopProjectileFlight()
		var/flight_id = blast.projectile_flight_id

		while(blast && blast.z && blast.in_use && user && blast.Owner == user && flight_id == blast.projectile_flight_id && getdist(blast, user) < control_range)
			if(stop_on_deflect && blast.deflected) break
			if(source_skill && ("Using" in source_skill.vars))
				source_skill.vars["Using"] = 1
			var/control_dir = getControlDirection(user)
			var/turf/next_step = Get_step(blast, control_dir)
			if(blast.Owner && next_step && (blast.Owner in next_step) && (blast.owner_immune || (avoid_owner && prob(avoid_owner_chance))))
				control_dir = pick(turn(control_dir,45),turn(control_dir,-45))
			else if(allow_bump && next_step && (locate(/mob) in next_step))
				for(var/mob/m in next_step)
					if(m == blast.Owner && (blast.owner_immune || prob(avoid_owner_chance)))
						control_dir = pick(turn(control_dir,45),turn(control_dir,-45))
						continue
					else
						var/bump_dir
						if(prob(50)) bump_dir = get_dir(m, user)
						else bump_dir = pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
						blast.Bump(m, override_delete = bumps, override_dir = bump_dir)
					bumps--
			if(blast)
				var/control_angle = dir_to_angle_0_360(control_dir)
				var/desired_x = sin(control_angle) * move_speed
				var/desired_y = cos(control_angle) * move_speed
				var/change_x = desired_x - velocity_x
				var/change_y = desired_y - velocity_y
				var/change_magnitude = sqrt(change_x ** 2 + change_y ** 2)
				var/max_change = move_speed * 0.55
				if(change_magnitude > max_change && change_magnitude)
					var/change_scale = max_change / change_magnitude
					change_x *= change_scale
					change_y *= change_scale
				velocity_x += change_x
				velocity_y += change_y
				var/physical_direction = XYtoDir(velocity_x, velocity_y)
				if(physical_direction) blast.dir = physical_direction
				vector_step(blast, requested_x = velocity_x, requested_y = velocity_y, movement_direction = physical_direction)
				blast.density = 1
			if(user.KO && blast) del(blast)
			sleep(loop_delay)

		if(blast && blast.z && blast.in_use && flight_id == blast.projectile_flight_id)
			if(!user || !blast.Owner) del(blast)
			else if(blast.Owner == user) blast.startKiProjectileWalk(blast.dir)

datum/SkillController/GuidedBomb
	id = SKILL_CONTROLLER_GUIDED_BOMB

	proc/execute(mob/user, obj/Blast/blast, datum/SkillDefinition/def, obj/source_skill)
		if(!user || !blast) return
		var/max_steps = def ? def.control_max_steps : 0
		if(!max_steps) max_steps = 80
		var/max_distance = def ? def.control_range : 0
		if(!max_distance) max_distance = 30

		if("sb_moving" in blast.vars)
			blast.vars["sb_moving"] = 1
		var/velocity_x = 0
		var/velocity_y = 0
		blast.stopProjectileFlight()
		var/flight_id = blast.projectile_flight_id

		for(var/v in 1 to max_steps)
			if(!blast || !blast.z || !blast.in_use || !user || blast.Owner != user || blast.projectile_flight_id != flight_id) break
			var/step_delay = 1
			if("sb_move_speed" in blast.vars) step_delay = blast.vars["sb_move_speed"]
			var/move_speed = blast.vector_speed
			if(!move_speed) move_speed = 32
			var/control_direction = getControlDirection(user)
			if(!(control_direction in list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)))
				sleep(TickMult(step_delay))
				continue
			var/control_angle = dir_to_angle_0_360(control_direction)
			var/desired_x = sin(control_angle) * move_speed
			var/desired_y = cos(control_angle) * move_speed
			var/change_x = desired_x - velocity_x
			var/change_y = desired_y - velocity_y
			var/change_magnitude = sqrt(change_x ** 2 + change_y ** 2)
			var/max_change = move_speed * 0.55
			if(change_magnitude > max_change && change_magnitude)
				var/change_scale = max_change / change_magnitude
				change_x *= change_scale
				change_y *= change_scale
			velocity_x += change_x
			velocity_y += change_y
			var/physical_direction = XYtoDir(velocity_x, velocity_y)
			if(physical_direction) blast.dir = physical_direction
			vector_step(blast, requested_x = velocity_x, requested_y = velocity_y, movement_direction = physical_direction)
			sleep(TickMult(step_delay))
			if(!blast || !blast.z || !blast.in_use || !user || blast.Owner != user || blast.projectile_flight_id != flight_id) break
			if(getdist(user, blast) > max_distance) break
			if(def && def.control_stop_on_deflect && blast.deflected) break

		if(blast && blast.z && blast.in_use && blast.projectile_flight_id == flight_id)
			if(!user || !blast.Owner) del(blast)
			else if(blast.Owner == user && hascall(blast, "SpiritBombGoOffSomewhere"))
				call(blast, "SpiritBombGoOffSomewhere")()
