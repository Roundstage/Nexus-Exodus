obj/Attacks/NexusSpecialStyle
	name = "Nexus Special Style"
	desc = "A Nexus attack whose behavior is not represented by a generic blast."
	can_hotbar = 1
	hotbar_type = "Blast"
	repeat_macro = 0

obj/Attacks/NexusSpecialStyle/WallOfFlame
	name = "Wall of Flame"
	desc = "Create a persistent five-tile wall of fire that damages and briefly stuns enemies who enter it."
	icon = 'src/Icons/NexusIntegrated/Attacks/Blasts/RTWallOfFlame.dmi'
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
		user.showNexusTechniqueAnnouncement(name, "#ff7043", 'FogoNaMao.mp3', 45)
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
			new /obj/Effect/NexusFlameField(field_turf, user, field_duration)
		player_view(15, user) << "[user] raises a persistent Wall of Flame!"
		return TRUE

obj/Attacks/NexusSpecialStyle/ChargedProjectile
	desc = "A charged Nexus projectile adapted to Nexus Exodus combat scaling."
	var
		energy_cost = 150
		cooldown_ticks = 120
		charge_ticks = 18
		projectile_damage_factor = 10
		explosion_size = 2
		projectile_shockwave = 2
		launch_delay_ticks = 0
		strength_scaled = FALSE
		requires_weapon = FALSE
		weapon_projectile = FALSE
		cast_text_color = "#ffd45c"
		impact_effect_icon = 'src/Icons/NexusIntegrated/Attacks/Effects/RTImpactHeavy.dmi'
		impact_effect_state
		impact_sound_volume = 55
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
		if(requires_weapon && !user.usingMeleeWeapon())
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
		if(weapon_projectile)
			user.showNexusTechniqueAnnouncement("Preparing [name]", cast_text_color, pick(nexus_sword_swing_light_sounds), 26)
			user.pulseNexusGlow(cast_text_color, 3.2, 190, max(8, charge_ticks))
		else
			user.overlays += user.BlastCharge
			user.showNexusTechniqueAnnouncement("Charging [name]", cast_text_color, 'BasicbeamCharge.ogg', 42)
			user.pulseNexusGlow(cast_text_color, 4.5, 225, max(8, charge_ticks))
		sleep(charge_ticks)
		if(user && !weapon_projectile) user.overlays -= user.BlastCharge
		if(!user || loc != user || user.KO || user.rp_mode || user.cant_blast(ignore_attack_check = 1))
			if(user) user.attacking = 0
			charging = FALSE
			return FALSE
		var/obj/Blast/projectile = get_cached_blast()
		var/total_damage_budget = projectile_damage_factor * (explosion_size ? 2 : 1)
		projectile.setStats(user, Percent = projectile_damage_factor, Off_Mult = strength_scaled ? 1.2 : 1, Explosion = explosion_size, explosion_percent = explosion_size ? projectile_damage_factor : 0, max_damage_factor = total_damage_budget)
		projectile.strength_scaled = strength_scaled
		projectile.weapon_scaled = weapon_projectile
		projectile.from_attack = src
		projectile.icon = icon
		projectile.projectile_impact_icon = impact_effect_icon
		projectile.projectile_impact_icon_state = impact_effect_state
		projectile.projectile_impact_color = cast_text_color
		projectile.projectile_impact_sound = weapon_projectile ? pick(nexus_sword_impact_sounds) : 'Explosion2.wav'
		projectile.projectile_impact_sound_volume = impact_sound_volume
		projectile.dir = user.dir
		projectile.Distance = 40
		projectile.vector_speed = 32
		projectile.Shockwave = projectile_shockwave
		projectile.SafeTeleport(user.loc)
		CenterIcon(projectile)
		projectile.queueNexusProjectileGlowUpdate()
		if(weapon_projectile)
			showNexusSwordSlashEffect(user, cast_text_color, 1.35)
			player_view(15, user) << sound(pick(nexus_sword_swing_heavy_sounds), volume = 42)
			flick("Attack", user)
		else
			player_view(15, user) << sound('Blast.wav', volume = 55)
			flick("Blast", user)
		user.attacking = 0
		charging = FALSE
		if(launch_delay_ticks) sleep(launch_delay_ticks)
		if(projectile && projectile.z) projectile.startKiProjectileWalk(user.dir)
		return TRUE

obj/Attacks/NexusSpecialStyle/ChargedProjectile/DragonNova
	name = "Dragon Nova"
	desc = "A giant charged energy sphere adapted from Nexus. It is slow, explosive, and intended as a Force finisher."
	icon = 'src/Icons/NexusIntegrated/Attacks/Blasts/RTDragonNova.dmi'
	energy_cost = 200
	cooldown_ticks = 140
	charge_ticks = 24
	projectile_damage_factor = 18
	explosion_size = 4
	projectile_shockwave = 4
	cast_text_color = "#ffb347"
	impact_sound_volume = 72

	verb/Dragon_Nova()
		set name = "Dragon Nova"
		set category = "Skills"
		fireChargedProjectile(usr)

obj/Attacks/NexusSpecialStyle/ChargedProjectile/SkyBreak
	name = "Sky Break"
	desc = "A weapon swing that breaks the sound barrier and launches a Strength-scaled cutting blast."
	icon = 'src/Icons/NexusIntegrated/Attacks/Blasts/RTSkyBreak.dmi'
	energy_cost = 180
	cooldown_ticks = 130
	charge_ticks = 16
	projectile_damage_factor = 13
	explosion_size = 3
	projectile_shockwave = 4
	launch_delay_ticks = 1
	strength_scaled = TRUE
	requires_weapon = TRUE
	weapon_projectile = TRUE
	cast_text_color = "#8ed8ff"
	impact_effect_icon = 'src/Icons/Effects/CC0/SwordSlash.dmi'
	impact_effect_state = "slash"
	impact_sound_volume = 42

	verb/Sky_Break()
		set name = "Sky Break"
		set category = "Skills"
		fireChargedProjectile(usr)

obj/Attacks/NexusSpecialStyle/ChargedProjectile/EchoingSlash
	name = "Echoing Slash"
	desc = "A fast weapon swing that launches a physical cutting wave with sword audiovisuals and no blast explosion."
	icon = 'src/Icons/NexusIntegrated/Attacks/Blasts/RTEchoingSlash.dmi'
	energy_cost = 120
	cooldown_ticks = 90
	charge_ticks = 8
	projectile_damage_factor = 14
	explosion_size = 0
	projectile_shockwave = 3
	launch_delay_ticks = 1
	strength_scaled = TRUE
	requires_weapon = TRUE
	weapon_projectile = TRUE
	cast_text_color = "#b8ecff"
	impact_effect_icon = 'src/Icons/Effects/CC0/SwordSlash.dmi'
	impact_effect_state = "slash"
	impact_sound_volume = 38

	verb/Echoing_Slash()
		set name = "Echoing Slash"
		set category = "Skills"
		fireChargedProjectile(usr)

obj/Effect/NexusFlameField
	name = "Wall of Flame"
	icon = 'src/Icons/NexusIntegrated/Attacks/Blasts/RTWallOfFlame.dmi'
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
		setNexusGlow("#ff632e", 3.2, 205, 'src/Code/WorldMechanics/WeatherDayNight/NexusLightGradient.dmi', 8, "aura")
		animate(src, alpha = 255, transform = matrix(), time = 5, easing = CUBIC_EASING)
		spawn() processField()

	Del()
		clearNexusGlow()
		. = ..()

	proc/processField()
		set waitfor = 0
		while(src && owner && world.time < expires_at)
			for(var/mob/target in loc)
				if(!owner.canHitNexusTechniqueTarget(target)) continue
				if(next_pulse_by_target[target] > world.time) continue
				if(pulses_by_target[target] >= skill_wall_of_flame_max_pulses) continue
				next_pulse_by_target[target] = world.time + 10
				pulses_by_target[target] = pulses_by_target[target] + 1
				if(pulses_by_target[target] == 1)
					target.text_overlay("<center><b><font color=#ff7043>BURN</font></b></center>", xx = -16, yy = 40, timer = 8)
					player_view(10, target) << sound('Kiplosion.ogg', volume = 28)
				var/damage = owner.getKiCombatDamage(target, skill_wall_of_flame_pulse_factor)
				owner.applyNexusTechniqueDamage(target, damage, "Wall of Flame")
				if(target)
					target.ApplyStun(time = 4, stun_power = 1.5)
					target.BurnStack++
					if(!target.isBurning)
						target.isBurning = TRUE
						target.try_applying_burn_effect()
			sleep(2)
		if(src) del(src)

// Restored integrated techniques live beside the other special styles so Dream Maker project saves
// cannot orphan their type definitions by dropping a newly-added include from DU.dme.
// The full Shockwave definition is loaded later from ProjectileSystem/Blasts.dm.
obj/Attacks/Shockwave

obj/Attacks/NexusAreaTechnique
	parent_type = /obj/Attacks/Shockwave
	name = "Nexus Area Technique"
	desc = "A specialized targetless shockwave adapted from Nexus."
	can_hotbar = 1
	hotbar_type = "Blast"
	repeat_macro = 0
	var
		energy_cost = 60
		cooldown_ticks = 140
		radius = 4
		area_damage_factor = 5
		knockback_distance = 2
		pull_distance = 0
		physical_damage = FALSE
		ground_only = FALSE
		intercepts_blasts = FALSE
		blast_intercept_limit = 12
		target_limit = 16
		cast_text_color = "#ffd166"
		cast_sound = 'Kiplosion.ogg'
		cast_sound_category
		shockwave_effect_state = "middle"
		tmp/next_use = 0

	Hotbar_use()
		useAreaTechnique(usr)

	Shockwave()
		useAreaTechnique(usr)

	proc/getAreaCastSound()
		var/open_sound = getNexusShonenSound(cast_sound_category)
		return open_sound ? open_sound : cast_sound

	proc/showAreaEffect(mob/user)
		showNexusOpenCombatEffect(user, "smoke_shockwaves_128", shockwave_effect_state, radius / 2, cast_text_color, 225, BLEND_ADD, 18, 0.25)

	proc/interceptAreaBlasts(mob/user)
		if(!user || !intercepts_blasts) return 0
		var/intercepted = 0
		for(var/obj/Blast/projectile in blast_view(radius + 1, user))
			if(intercepted >= blast_intercept_limit) break
			if(!projectile.z || projectile.Beam || projectile.Owner == user) continue
			var/projectile_delta_x = projectile.nexusCollisionCenterXPixels() - user.nexusCollisionCenterXPixels()
			var/projectile_delta_y = projectile.nexusCollisionCenterYPixels() - user.nexusCollisionCenterYPixels()
			var/projectile_radius = projectile.getNexusProjectileCollisionRadiusPixels()
			if(projectile_delta_x * projectile_delta_x + projectile_delta_y * projectile_delta_y > (radius * world.icon_size + projectile_radius) ** 2) continue
			showNexusOpenCombatEffect(projectile, "aim_32", "blast_blue", 1.25, null, 245, BLEND_ADD, 5, 0.35)
			projectile.Explosive = 0
			projectile.skip_all_collisions = 1
			intercepted++
			del(projectile)
		if(intercepted)
			Play_Melee_Sound(sound_range = 12, origin = user, sound_file = getNexusShonenSound("explosions"), sound_volume = 38)
		return intercepted

	proc/useAreaTechnique(mob/user)
		set waitfor = 0
		if(!user || loc != user || user.KO || user.rp_mode || user.cant_blast()) return FALSE
		if(world.time < next_use)
			user << "[src] will be ready in [round((next_use - world.time) / 10, 0.1)] seconds."
			return FALSE
		var/drain = user.GetSkillDrain(mod = energy_cost, is_energy = physical_damage ? 0 : 1)
		if(user.Ki < drain)
			user << "You do not have enough energy to use [src]."
			return FALSE
		user.Ki -= drain
		next_use = world.time + cooldown_ticks
		user.attacking = 3
		user.showNexusTechniqueAnnouncement(name, cast_text_color, getAreaCastSound(), 55)
		flick(physical_damage ? "Attack" : "Blast", user)
		showAreaEffect(user)
		interceptAreaBlasts(user)
		var/hit_count = 0
		for(var/mob/target in nexusMobsInCircle(user, radius * world.icon_size))
			if(hit_count >= target_limit) break
			if(!user.canHitNexusTechniqueTarget(target)) continue
			if(ground_only && target.Flying) continue
			if(target.AOE_auto_dodge(user, user.loc)) continue
			var/center_delta_x = target.nexusCollisionCenterXPixels() - user.nexusCollisionCenterXPixels()
			var/center_delta_y = target.nexusCollisionCenterYPixels() - user.nexusCollisionCenterYPixels()
			var/distance_tiles = sqrt(center_delta_x * center_delta_x + center_delta_y * center_delta_y) / world.icon_size
			var/distance_falloff = max(0.55, 1 - distance_tiles * 0.08)
			var/damage = physical_damage ? user.getPhysicalCombatDamage(target, area_damage_factor * distance_falloff) : user.getKiCombatDamage(target, area_damage_factor * distance_falloff)
			if(!user.applyNexusTechniqueDamage(target, damage, name)) continue
			hit_count++
			if(target && pull_distance > 0) target.pullTowardNexusSource(user, pull_distance)
			else if(target && knockback_distance > 0) target.KnockbackNoWait(user, knockback_distance, override_dir = get_dir(user, target) || user.dir, bypass_immunity = 1)
		user.attacking = 0
		return TRUE

mob/proc/pullTowardNexusSource(mob/source, distance = 1)
	set waitfor = 0
	if(!source || source == src || source.z != z) return FALSE
	var/pull_steps = max(1, round(distance))
	AlterInputDisabled(1)
	if(src && source && getdist(src, source) > 1)
		runNexusSkillApproach(source, pull_steps * world.icon_size, world.icon_size, 90, 180, 240, 0, FALSE)
	AlterInputDisabled(-1)
	return TRUE

obj/Attacks/NexusAreaTechnique/SuperExplosiveWave
	name = "Super Explosive Wave"
	desc = "Detonate a violent eight-tile shockwave that destroys hostile blasts and hurls enemies up to twelve tiles away."
	icon = 'src/Icons/NexusIntegrated/Attacks/Blasts/RTMegaBurst.dmi'
	hotbar_type = "Defensive"
	energy_cost = 80
	cooldown_ticks = 140
	radius = 8
	area_damage_factor = 12
	knockback_distance = 12
	intercepts_blasts = TRUE
	blast_intercept_limit = 40
	cast_text_color = "#75e6ff"
	cast_sound_category = "explosions"
	shockwave_effect_state = "big"

	showAreaEffect(mob/user)
		var/obj/Effect/effect = showNexusExplosiveWaveEffect(user, radius)
		for(var/mob/viewer in player_view(radius + 2, user))
			if(viewer.client) viewer.ScreenShake(Amount = 6, Offset = 5)
		return effect

	verb/Super_Explosive_Wave()
		set name = "Super Explosive Wave"
		set category = "Skills"
		useAreaTechnique(usr)

obj/Attacks/NexusAreaTechnique/Earthquake
	name = "Earthquake"
	desc = "Collapse the ground inward across an eight-tile radius, damaging and pulling grounded enemies toward you. Flying targets are unaffected."
	icon = 'src/Icons/NexusIntegrated/Attacks/Effects/RTShockwave.dmi'
	energy_cost = 60
	cooldown_ticks = 160
	radius = 8
	area_damage_factor = 10
	knockback_distance = 0
	pull_distance = 3
	physical_damage = TRUE
	ground_only = TRUE
	cast_text_color = "#d6a76c"
	cast_sound_category = "land"
	shockwave_effect_state = "middle"
	// Use the tracked short rumble by resource name; DU.dme already indexes its containing directory.
	cast_sound = 'Earthquakeshort.ogg'

	showAreaEffect(mob/user)
		return showNexusEarthquakeEffect(user, radius)

	verb/Earthquake()
		set category = "Skills"
		useAreaTechnique(usr)

obj/Attacks/NexusSpecialStyle/SuperGhostKamikaze
	name = "Super Ghost Kamikaze Attack"
	desc = "Create three copies of yourself that relentlessly pursue one selected target. Their shared damage budget prevents the volley from multiplying without limit."
	icon = 'src/Icons/NexusIntegrated/Attacks/Blasts/RTHomingBlast.dmi'
	var
		energy_cost = 100
		cooldown_ticks = 160
		ghost_count = 3
		ghost_damage_factor = 6
		locked_homing = TRUE
		tmp/next_use = 0

	verb/Hotbar_use()
		set hidden = 1
		useStyle(usr)

	verb/Super_Ghost_Kamikaze_Attack()
		set name = "Super Ghost Kamikaze Attack"
		set category = "Skills"
		useStyle(usr)

	proc/useStyle(mob/user)
		set waitfor = 0
		if(!user || loc != user || user.KO || user.rp_mode || user.cant_blast()) return FALSE
		if(world.time < next_use)
			user << "[src] will be ready in [round((next_use - world.time) / 10, 0.1)] seconds."
			return FALSE
		var/mob/target = user.getSelectedTarget(max_dist = 20)
		if(!user.canHitNexusTechniqueTarget(target))
			user << "Select a valid target within 20 tiles."
			return FALSE
		var/drain = user.GetSkillDrain(mod = energy_cost, is_energy = 1)
		if(user.Ki < drain)
			user << "You do not have enough energy to use [src]."
			return FALSE
		user.Ki -= drain
		next_use = world.time + cooldown_ticks
		user.attacking = 3
		user.showNexusTechniqueAnnouncement(name, "#f4f0b0", 'BasicbeamCharge.ogg', 42)
		var/datum/CombatDamageBudget/shared_budget = new(ghost_damage_factor * ghost_count)
		for(var/ghost_index = 1, ghost_index <= ghost_count, ghost_index++)
			if(ghost_index > 1) sleep(3)
			if(!user || !target || !user.canHitNexusTechniqueTarget(target)) break
			var/obj/Blast/ghost = get_cached_blast()
			ghost.setStats(user, Percent = ghost_damage_factor, Off_Mult = 1.5, Explosion = 1, explosion_percent = 0, shared_budget = shared_budget)
			ghost.from_attack = src
			ghost.applyNexusCharacterCopyAppearance(user)
			ghost.blast_homing_target = target
			ghost.Can_Home = 0
			ghost.Distance = 40
			ghost.vector_speed = 32
			ghost.Shockwave = 2
			ghost.SafeTeleport(user.loc)
			ghost.queueNexusProjectileGlowUpdate()
			ghost.followSelectedTarget(target)
		if(user) user.attacking = 0
		return TRUE

obj/Attacks/NexusSpecialStyle/DefensiveBlasting
	name = "Evasive Barrage"
	desc = "Leap 8 to 12 tiles backward based on Speed while releasing eight independently paced pursuing blasts from your leading side."
	icon = 'src/Icons/NexusIntegrated/Attacks/Blasts/RTHomingBlast.dmi'
	hotbar_type = "Defensive"
	Cost_To_Learn = 18
	student_point_cost = 30
	var
		energy_cost = 70
		cooldown_ticks = 100
		blast_count = 8
		blast_damage_factor = 2.5
		tmp/next_use = 0

	proc/getRetreatTiles(mob/user)
		if(!user) return 8
		var/speed_delay = max(0.01, user.Speed_delay_mult(severity = 0.5))
		return 8 + Clamp(round((1 / speed_delay - 0.4) * 4), 0, 4)

	verb/Hotbar_use()
		set hidden = 1
		useStyle(usr)

	verb/Defensive_Blasting()
		set name = "Evasive Barrage"
		set category = "Skills"
		useStyle(usr)

	proc/useStyle(mob/user)
		set waitfor = 0
		if(!user || loc != user || user.KO || user.rp_mode || user.cant_blast()) return FALSE
		if(world.time < next_use)
			user << "[src] will be ready in [round((next_use - world.time) / 10, 0.1)] seconds."
			return FALSE
		var/mob/target = user.getSelectedTarget(max_dist = 18)
		if(!user.canHitNexusTechniqueTarget(target))
			user << "Select a valid target within 18 tiles."
			return FALSE
		var/drain = user.GetSkillDrain(mod = energy_cost, is_energy = 1)
		if(user.Ki < drain) return FALSE
		user.Ki -= drain
		next_use = world.time + cooldown_ticks
		user.attacking = 3
		user.showNexusTechniqueAnnouncement(name, "#8ed8ff", 'Blast.wav', 40)
		var/datum/CombatDamageBudget/shared_budget = new(blast_damage_factor * blast_count)
		var/aim_direction = get_dir(user, target) || user.dir
		var/retreat_direction = turn(aim_direction, 180)
		var/retreat_x = user.bound_center_x() - target.bound_center_x()
		var/retreat_y = user.bound_center_y() - target.bound_center_y()
		var/retreat_pixels = getRetreatTiles(user) * world.icon_size
		// Begin the retreat first. Shots are emitted during the motion instead of
		// appearing as one stationary formation at its starting point.
		spawn() if(user && target && target.z == user.z)
			user.runNexusSkillMotion(null, retreat_direction, retreat_pixels, max_velocity = 48, acceleration = 96, deceleration = 72, afterimage_interval = 1.5, pass_mobs = TRUE, movement_vector_x = retreat_x, movement_vector_y = retreat_y, facing_direction = aim_direction)
		for(var/shot_index = 1, shot_index <= blast_count, shot_index++)
			if(!user || user.KO || user.KB || !target || target.z != user.z || target.KO) break
			var/obj/Blast/projectile = get_cached_blast()
			projectile.setStats(user, Percent = blast_damage_factor, Off_Mult = 1, Explosion = 0, owner_immunity = 1, shared_budget = shared_budget)
			projectile.from_attack = src
			projectile.icon = icon
			// The custom flight controller owns a minimum forty-tile path budget.
			projectile.Distance = 999
			projectile.vector_speed = rand(8, 16)
			projectile.Shockwave = 1
			var/launch_direction = get_dir(user, target)
			var/turf/launch_turf = get_step(user, launch_direction)
			if(!launch_turf || launch_turf.density) launch_turf = user.loc
			projectile.SafeTeleport(launch_turf)
			projectile.pixel_x += rand(-3, 3)
			projectile.pixel_y += rand(-3, 3)
			projectile.dir = launch_direction
			projectile.blast_homing_target = target
			projectile.queueNexusProjectileGlowUpdate()
			projectile.followNexusTargetFor(target, 20, 0, 40)
			sleep(TickMult(0.5))
		if(user) user.attacking = 0
		return TRUE

obj/Attacks/NexusSpecialStyle/SphereOfDestruction
	name = "Sphere of Destruction"
	desc = "Launch a concentrated one-tile sphere with very high tracking accuracy. It slowly pursues for 10 to 40 seconds, or 60 seconds at overwhelming Energy efficiency; multiple spheres may coexist."
	icon = 'src/Icons/Ki/Big/DeathBall2017Purple.dmi'
	Cost_To_Learn = 35
	student_point_cost = 50
	var
		energy_cost = 160
		cooldown_ticks = 220
		sphere_damage_factor = 16
		tmp/next_use = 0

	proc/getChaseDuration(mob/user)
		if(!user) return 100
		if(user.Eff >= 6) return 600
		return Clamp(round(user.Eff * 100), 100, 400)

	verb/Hotbar_use()
		set hidden = 1
		useStyle(usr)

	verb/Sphere_of_Destruction()
		set name = "Sphere of Destruction"
		set category = "Skills"
		useStyle(usr)

	proc/useStyle(mob/user)
		set waitfor = 0
		if(!user || loc != user || user.KO || user.rp_mode || user.cant_blast()) return FALSE
		if(world.time < next_use)
			user << "[src] will be ready in [round((next_use - world.time) / 10, 0.1)] seconds."
			return FALSE
		var/mob/target = user.getSelectedTarget(max_dist = 25)
		if(!user.canHitNexusTechniqueTarget(target)) return FALSE
		var/drain = user.GetSkillDrain(mod = energy_cost, is_energy = 1)
		if(user.Ki < drain)
			user << "You do not have enough energy to use [src]."
			return FALSE
		user.Ki -= drain
		next_use = world.time + cooldown_ticks
		user.showNexusTechniqueAnnouncement(name, "#b56cff", 'BasicbeamCharge.ogg', 55)
		var/obj/Blast/projectile = get_cached_blast()
		projectile.setStats(user, Percent = sphere_damage_factor, Off_Mult = 4, Explosion = 2, explosion_percent = sphere_damage_factor, max_damage_factor = sphere_damage_factor * 2, owner_immunity = 1)
		projectile.from_attack = src
		// Crop transparent padding before scaling so the animated core fills one tile.
		var/icon/sphere_icon = new(icon)
		sphere_icon.Crop(65, 65, 236, 236)
		sphere_icon.Scale(world.icon_size, world.icon_size)
		projectile.icon = sphere_icon
		projectile.color = null
		// Size is a radius in tiles. Zero uses the physical 32x32 bounds, producing
		// the requested one-tile diameter instead of the old two-tile diameter.
		projectile.Size = 0
		projectile.bound_width = world.icon_size
		projectile.bound_height = world.icon_size
		projectile.Distance = 999
		projectile.vector_speed = 5
		projectile.Shockwave = 4
		projectile.SafeTeleport(user.loc)
		CenterIcon(projectile)
		projectile.blast_homing_target = target
		projectile.queueNexusProjectileGlowUpdate()
		projectile.followNexusTargetFor(target, getChaseDuration(user))
		return TRUE

obj/Blast/proc/followNexusTargetFor(mob/target, duration_ticks, startup_delay = 0, minimum_distance_tiles = 0)
	set waitfor = 0
	stopProjectileFlight()
	Can_Home = 0
	var/flight_id = projectile_flight_id
	if(startup_delay > 0) sleep(startup_delay)
	var/expires_at = world.time + max(1, duration_ticks)
	var/travelled_pixels = 0
	while(src && z && !deflected && Owner && target && target.z == z && !target.KO && world.time < expires_at && flight_id == projectile_flight_id)
		var/move_speed = vector_speed
		if(!move_speed) move_speed = 20
		var/old_x = Px(0)
		var/old_y = Py(0)
		vector_step_toward(src, target, move_speed)
		if(src && z)
			var/moved_x = Px(0) - old_x
			var/moved_y = Py(0) - old_y
			travelled_pixels += sqrt(moved_x ** 2 + moved_y ** 2)
		if(target in loc && !target.isDefensiveDashEvading(src))
			Bump(target)
			return
		sleep(TickMult(ki_projectile_step_delay))
	// Evasive Barrage stops steering after two seconds but retains its final
	// heading until its total path reaches the requested minimum distance.
	var/minimum_distance_pixels = max(0, minimum_distance_tiles) * world.icon_size
	while(src && z && !deflected && Owner && travelled_pixels < minimum_distance_pixels && flight_id == projectile_flight_id)
		var/move_speed = vector_speed
		if(!move_speed) move_speed = 20
		var/old_x = Px(0)
		var/old_y = Py(0)
		vector_step_dir(src, dir, move_speed)
		if(src && z)
			var/moved_x = Px(0) - old_x
			var/moved_y = Py(0) - old_y
			var/moved_distance = sqrt(moved_x ** 2 + moved_y ** 2)
			travelled_pixels += moved_distance
			if(moved_distance <= 0) break
		sleep(TickMult(ki_projectile_step_delay))
	if(src && z && !deflected && flight_id == projectile_flight_id) del(src)

mob/var/tmp
	destruction_aura_suppressed_until = 0
	destruction_aura_active = FALSE

var/list/nexus_destruction_range_icons = list()

proc/getNexusDestructionRangeIcon(radius_pixels)
	radius_pixels = max(2, round(radius_pixels))
	var/cache_key = "[radius_pixels]"
	if(nexus_destruction_range_icons[cache_key]) return nexus_destruction_range_icons[cache_key]
	var/diameter = radius_pixels * 2 + 2
	var/icon/range_icon = icon('src/Icons/UI/Healthbar.dmi', "100")
	range_icon.Scale(diameter, diameter)
	range_icon.DrawBox(null, 1, 1, diameter, diameter)
	var/center = (diameter + 1) / 2
	var/inner_radius = radius_pixels - 2
	for(var/row = 1, row <= diameter, row++)
		var/delta_y = row - center
		if(abs(delta_y) > radius_pixels) continue
		var/outer_span = sqrt(radius_pixels ** 2 - delta_y ** 2)
		range_icon.DrawBox("#edb5ff", round(center - outer_span) + 1, row, round(center + outer_span), row)
		if(abs(delta_y) < inner_radius)
			var/inner_span = sqrt(inner_radius ** 2 - delta_y ** 2)
			range_icon.DrawBox("#7020a018", round(center - inner_span) + 1, row, round(center + inner_span), row)
	nexus_destruction_range_icons[cache_key] = range_icon
	return range_icon

obj/Attacks/NexusSpecialStyle/AuraOfDestruction
	name = "Aura of Destruction"
	desc = "Surround yourself with a damaging four-tile aura that suppresses enemy teleports and dashes. While active, it stops your Energy recovery, drains heavy Energy and reduces movement speed by 30%."
	icon = 'src/Icons/Ki/Auras/BlackDemonflame.dmi'
	hotbar_type = "Ability"
	Cost_To_Learn = 30
	student_point_cost = 45
	var
		activation_cost = 80
		upkeep_cost = 150
		radius = 4
		pulse_damage_factor = 2
		tmp/active = FALSE
		tmp/aura_generation = 0
		tmp/mob/aura_owner
		tmp/image/aura_flames
		tmp/image/aura_field

	Del()
		stopAura()
		return ..()

	proc/stopAura()
		active = FALSE
		aura_generation++
		if(aura_owner)
			aura_owner.overlays -= aura_flames
			aura_owner.underlays -= aura_field
			aura_owner.destruction_aura_active = FALSE
			aura_owner.clearNexusActionGlow()
		aura_owner = null
		aura_flames = null
		aura_field = null

	proc/showAura(mob/user)
		aura_owner = user
		aura_flames = image(icon = icon)
		aura_flames.color = "#c078ff"
		aura_flames.alpha = 180
		aura_flames.blend_mode = BLEND_ADD
		user.overlays += aura_flames
		var/field_size = radius * 2 * world.icon_size + 2
		aura_field = image(icon = getNexusDestructionRangeIcon(radius * world.icon_size))
		// Match the collision center, including the caster's non-default density bounds.
		aura_field.pixel_x = user.bound_x + user.bound_width / 2 - field_size / 2
		aura_field.pixel_y = user.bound_y + user.bound_height / 2 - field_size / 2
		aura_field.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		aura_field.alpha = 230
		aura_field.blend_mode = BLEND_DEFAULT
		user.underlays += aura_field

	verb/Hotbar_use()
		set hidden = 1
		toggleAura(usr)

	verb/Aura_of_Destruction()
		set name = "Aura of Destruction"
		set category = "Skills"
		toggleAura(usr)

	proc/toggleAura(mob/user)
		if(!user || loc != user) return FALSE
		if(active)
			stopAura()
			user << "[src] fades."
			return TRUE
		if(user.KO || user.rp_mode || user.cant_blast()) return FALSE
		var/drain = user.GetSkillDrain(mod = activation_cost, is_energy = 1)
		if(user.Ki < drain)
			user << "You do not have enough energy to use [src]."
			return FALSE
		user.Ki -= drain
		active = TRUE
		aura_generation++
		showAura(user)
		user.destruction_aura_active = TRUE
		user.setNexusActionGlow("#9d4edd", 8, 220, 'src/Code/WorldMechanics/WeatherDayNight/NexusLightGradient.dmi', 8, "aura")
		user.showNexusTechniqueAnnouncement(name, "#d66cff", 'Aura.ogg', 45)
		processAura(user, aura_generation)
		return TRUE

	proc/processAura(mob/user, generation)
		set waitfor = 0
		while(active && generation == aura_generation && user && loc == user && user.z && !user.KO)
			var/upkeep = user.GetSkillDrain(mod = upkeep_cost, is_energy = 1)
			if(user.Ki < upkeep) break
			user.Ki -= upkeep
			for(var/mob/target in nexusMobsInCircle(user, radius * world.icon_size))
				if(!user.canHitNexusTechniqueTarget(target)) continue
				target.destruction_aura_suppressed_until = world.time + 15
				if(target.active_skill_motion) target.cancelNexusSkillMotion("Aura of Destruction")
				user.applyNexusTechniqueDamage(target, user.getKiCombatDamage(target, pulse_damage_factor), name)
			sleep(10)
		if(generation == aura_generation) stopAura()

obj/Attacks/NexusSpecialStyle/DeathLaser
	name = "Death Laser"
	desc = "Fire an instantaneous, needle-thin laser that pierces every valid target in a thirty-tile line without charging or becoming a beam struggle."
	icon = 'src/Icons/Ki/Beams/FreezaDeathRay.dmi'
	hotbar_type = "Blast"
	Cost_To_Learn = 28
	student_point_cost = 40
	var
		energy_cost = 70
		cooldown_ticks = 100
		laser_damage_factor = 14
		line_range = 30
		tmp/next_use = 0

	verb/Hotbar_use()
		set hidden = 1
		fireLaser(usr)

	verb/Death_Laser()
		set name = "Death Laser"
		set category = "Skills"
		fireLaser(usr)

	proc/fireLaser(mob/user)
		if(!user || loc != user || user.KO || user.rp_mode || user.cant_blast()) return FALSE
		if(world.time < next_use)
			user << "[src] will be ready in [round((next_use - world.time) / 10, 0.1)] seconds."
			return FALSE
		var/drain = user.GetSkillDrain(mod = energy_cost, is_energy = 1)
		if(user.Ki < drain) return FALSE
		user.Ki -= drain
		next_use = world.time + cooldown_ticks
		flick("Blast", user)
		user.showNexusTechniqueAnnouncement(name, "#d66cff", 'Blast.wav', 52)
		var/list/hit_targets = list()
		var/turf/line_turf = user.loc
		for(var/line_step = 1, line_step <= line_range, line_step++)
			line_turf = get_step(line_turf, user.dir)
			if(!line_turf || line_turf.density) break
			showNexusOpenCombatEffect(line_turf, "aim_32", "blast_blue", 0.45, "#d66cff", 235, BLEND_ADD, 3, 0)
			for(var/mob/target in line_turf)
				if(target in hit_targets || !user.canHitNexusTechniqueTarget(target)) continue
				hit_targets += target
				user.applyNexusTechniqueDamage(target, user.getKiCombatDamage(target, laser_damage_factor), name)
		return TRUE
