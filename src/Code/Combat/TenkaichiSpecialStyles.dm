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

obj/Attacks/TenkaichiSpecialStyle/ChargedProjectile
	desc = "A charged Roleplay Tenkaichi projectile adapted to Nexus Exodus combat scaling."
	var
		energy_cost = 150
		cooldown_ticks = 120
		charge_ticks = 18
		projectile_damage_factor = 10
		explosion_size = 2
		strength_scaled = FALSE
		requires_weapon = FALSE
		tmp/next_use = 0

	verb/Hotbar_use()
		set hidden = 1
		fireChargedProjectile(usr)

	proc/fireChargedProjectile(mob/user)
		set waitfor = 0
		if(!user || loc != user || user.KO || user.rp_mode || user.cant_blast()) return FALSE
		if(world.time < next_use)
			user << "[src] will be ready in [round((next_use - world.time) / 10, 0.1)] seconds."
			return FALSE
		if(requires_weapon && !user.using_sword())
			user << "You must equip a weapon before using [src]."
			return FALSE
		var/drain = user.GetSkillDrain(mod = energy_cost, is_energy = 1)
		if(user.Ki < drain)
			user << "You do not have enough energy to use [src]."
			return FALSE
		next_use = world.time + cooldown_ticks
		user.Ki -= drain
		user.attacking = 3
		charging = TRUE
		user.overlays += user.BlastCharge
		user.showTenkaichiTechniqueAnnouncement("Charging [name]", strength_scaled ? "#a9d3ff" : "#ffd45c", 'BasicbeamCharge.ogg', 42)
		user.pulseNexusGlow(strength_scaled ? "#a8d5ff" : "#ffd75a", 4.5, 225, max(8, charge_ticks))
		sleep(charge_ticks)
		if(user) user.overlays -= user.BlastCharge
		if(!user || loc != user || user.KO || user.rp_mode || user.cant_blast(ignore_attack_check = 1))
			if(user) user.attacking = 0
			charging = FALSE
			return FALSE
		var/obj/Blast/projectile = get_cached_blast()
		projectile.setStats(user, Percent = projectile_damage_factor, Off_Mult = strength_scaled ? 1.2 : 1, Explosion = explosion_size, explosion_percent = projectile_damage_factor, max_damage_factor = projectile_damage_factor * 2)
		projectile.strength_scaled = strength_scaled
		projectile.from_attack = src
		projectile.icon = icon
		projectile.dir = user.dir
		projectile.Distance = 40
		projectile.vector_speed = 32
		projectile.Shockwave = 2
		projectile.SafeTeleport(user.loc)
		CenterIcon(projectile)
		projectile.queueNexusProjectileGlowUpdate()
		player_view(15, user) << sound('Blast.wav', volume = 55)
		flick("Blast", user)
		user.attacking = 0
		charging = FALSE
		projectile.startKiProjectileWalk(user.dir)
		return TRUE

obj/Attacks/TenkaichiSpecialStyle/ChargedProjectile/DragonNova
	name = "Dragon Nova"
	desc = "A giant charged energy sphere adapted from Roleplay Tenkaichi. It is slow, explosive, and intended as a Force finisher."
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Blasts/RTDragonNova.dmi'
	energy_cost = 200
	cooldown_ticks = 140
	charge_ticks = 24
	projectile_damage_factor = 12
	explosion_size = 4

	verb/Dragon_Nova()
		set name = "Dragon Nova"
		set category = "Skills"
		fireChargedProjectile(usr)

obj/Attacks/TenkaichiSpecialStyle/ChargedProjectile/SkyBreak
	name = "Sky Break"
	desc = "A weapon swing that breaks the sound barrier and launches a Strength-scaled cutting blast."
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Blasts/RTSkyBreak.dmi'
	energy_cost = 180
	cooldown_ticks = 130
	charge_ticks = 16
	projectile_damage_factor = 8
	explosion_size = 2
	strength_scaled = TRUE
	requires_weapon = TRUE

	verb/Sky_Break()
		set name = "Sky Break"
		set category = "Skills"
		fireChargedProjectile(usr)

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
		setNexusGlow("#ff632e", 3.2, 205, 'NexusLightGradient.dmi', 8, "aura")
		animate(src, alpha = 255, transform = matrix(), time = 5, easing = CUBIC_EASING)
		spawn() processField()

	Del()
		clearNexusGlow()
		. = ..()

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
