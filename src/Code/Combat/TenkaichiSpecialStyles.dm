obj/Attacks/TenkaichiSpecialStyle
	name = "Tenkaichi Special Style"
	desc = "A Roleplay Tenkaichi attack whose behavior is not represented by a generic blast."
	can_hotbar = 1
	hotbar_type = "Blast"
	repeat_macro = 0

obj/Attacks/TenkaichiSpecialStyle/WallOfFlame
	name = "Wall of Flame"
	desc = "Create a persistent five-tile wall of fire that damages and briefly stuns enemies who enter it."
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Blasts/RTWallOfFlame.dmi'
	var
		energy_cost = 30
		cooldown_ticks = 160
		field_duration = 150
		tmp/next_use = 0

	verb/Hotbar_use()
		set hidden = 1
		useStyle(usr)

	verb/Wall_of_Flame()
		set name = "Wall of Flame"
		set category = "Skills"
		useStyle(usr)

	proc/useStyle(mob/user)
		if(!user || user.KO || user.rp_mode || user.cant_blast()) return FALSE
		if(world.time < next_use)
			var/seconds_left = round((next_use - world.time) / 10, 0.1)
			user << "[src] will be ready in [seconds_left] seconds."
			return FALSE
		var/drain = user.GetSkillDrain(mod = energy_cost, is_energy = 1)
		if(user.Ki < drain)
			user << "You do not have enough energy to use [src]."
			return FALSE
		var/turf/front = get_step(user, user.dir)
		if(!front || front.density)
			user << "There is no room to create [src] in front of you."
			return FALSE
		user.Ki -= drain
		next_use = world.time + cooldown_ticks
		flick("Blast", user)
		user.showTenkaichiTechniqueAnnouncement(name, "#ff7043", 'FogoNaMao.mp3', 45)
		var/list/field_turfs = list(front)
		var/left_direction = turn(user.dir, -90)
		var/right_direction = turn(user.dir, 90)
		var/turf/left_turf = front
		var/turf/right_turf = front
		for(var/offset = 1, offset <= 2, offset++)
			left_turf = get_step(left_turf, left_direction)
			right_turf = get_step(right_turf, right_direction)
			if(left_turf && !left_turf.density) field_turfs += left_turf
			if(right_turf && !right_turf.density) field_turfs += right_turf
		for(var/turf/field_turf in field_turfs)
			new /obj/Effect/TenkaichiFlameField(field_turf, user, field_duration)
		player_view(15, user) << "[user] raises a persistent Wall of Flame!"
		return TRUE

obj/Effect/TenkaichiFlameField
	name = "Wall of Flame"
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Blasts/RTWallOfFlame.dmi'
	density = 0
	mouse_opacity = 0
	Grabbable = 0
	var
		mob/owner
		expires_at = 0
		list/next_pulse_by_target
		list/pulses_by_target

	New(turf/new_location, mob/new_owner, duration = 150)
		..()
		owner = new_owner
		expires_at = world.time + max(10, duration)
		next_pulse_by_target = list()
		pulses_by_target = list()
		if(new_location) SafeTeleport(new_location)
		alpha = 0
		transform = matrix() * 0.65
		animate(src, alpha = 255, transform = matrix(), time = 5, easing = CUBIC_EASING)
		spawn() processField()

	proc/processField()
		set waitfor = 0
		while(src && owner && world.time < expires_at)
			for(var/mob/target in loc)
				if(!owner.canHitTenkaichiTechniqueTarget(target)) continue
				if(next_pulse_by_target[target] > world.time) continue
				if(pulses_by_target[target] >= 6) continue
				next_pulse_by_target[target] = world.time + 10
				pulses_by_target[target] = pulses_by_target[target] + 1
				if(pulses_by_target[target] == 1)
					target.text_overlay("<center><b><font color=#ff7043>BURN</font></b></center>", xx = -16, yy = 40, timer = 8)
					player_view(10, target) << sound('Kiplosion.ogg', volume = 28)
				var/damage = owner.getKiCombatDamage(target, 0.45)
				owner.applyTenkaichiTechniqueDamage(target, damage)
				if(target)
					target.ApplyStun(time = 4, stun_power = 1.5)
					target.BurnStack++
					if(!target.isBurning)
						target.isBurning = TRUE
						target.try_applying_burn_effect()
			sleep(2)
		if(src) del(src)
