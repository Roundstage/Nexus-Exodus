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
		projectile.startKiProjectileWalk(user.dir)
		return TRUE

obj/Attacks/NexusSpecialStyle/ChargedProjectile/DragonNova
	name = "Dragon Nova"
	desc = "A giant charged energy sphere adapted from Nexus. It is slow, explosive, and intended as a Force finisher."
	icon = 'src/Icons/NexusIntegrated/Attacks/Blasts/RTDragonNova.dmi'
	energy_cost = 200
	cooldown_ticks = 140
	charge_ticks = 24
	projectile_damage_factor = 12
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
	projectile_damage_factor = 8
	explosion_size = 2
	projectile_shockwave = 4
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
	projectile_damage_factor = 7
	explosion_size = 0
	projectile_shockwave = 3
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
				if(!owner.canHitNexusTechniqueTarget(target)) continue
				if(next_pulse_by_target[target] > world.time) continue
				if(pulses_by_target[target] >= 6) continue
				next_pulse_by_target[target] = world.time + 10
				pulses_by_target[target] = pulses_by_target[target] + 1
				if(pulses_by_target[target] == 1)
					target.text_overlay("<center><b><font color=#ff7043>BURN</font></b></center>", xx = -16, yy = 40, timer = 8)
					player_view(10, target) << sound('Kiplosion.ogg', volume = 28)
				var/damage = owner.getKiCombatDamage(target, 0.45)
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

	proc/interceptAreaBlasts(mob/user)
		if(!user || !intercepts_blasts) return 0
		var/intercepted = 0
		for(var/obj/Blast/projectile in range(radius, user))
			if(intercepted >= blast_intercept_limit) break
			if(!projectile.z || projectile.Beam || projectile.Owner == user) continue
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
		showNexusOpenCombatEffect(user, "smoke_shockwaves_128", shockwave_effect_state, radius / 2, cast_text_color, 225, BLEND_ADD, 18, 0.25)
		interceptAreaBlasts(user)
		var/hit_count = 0
		for(var/mob/target in oview(radius, user))
			if(hit_count >= target_limit) break
			if(!user.canHitNexusTechniqueTarget(target)) continue
			if(ground_only && target.Flying) continue
			if(target.AOE_auto_dodge(user, user.loc)) continue
			var/distance_falloff = max(0.55, 1 - getdist(user, target) * 0.08)
			var/damage = physical_damage ? user.getPhysicalCombatDamage(target, area_damage_factor * distance_falloff) : user.getKiCombatDamage(target, area_damage_factor * distance_falloff)
			if(!user.applyNexusTechniqueDamage(target, damage, name)) continue
			hit_count++
			if(target && pull_distance > 0) target.pullTowardNexusSource(user, pull_distance)
			else if(target && knockback_distance > 0) target.Knockback(user, knockback_distance, bypass_immunity = 1)
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
	desc = "Detonate a defensive shockwave that destroys hostile blasts and repels every valid enemy within four tiles."
	icon = 'src/Icons/NexusIntegrated/Attacks/Blasts/RTMegaBurst.dmi'
	hotbar_type = "Defensive"
	energy_cost = 80
	cooldown_ticks = 140
	radius = 4
	area_damage_factor = 6
	knockback_distance = 4
	intercepts_blasts = TRUE
	blast_intercept_limit = 24
	cast_text_color = "#75e6ff"
	cast_sound_category = "ability_release"
	shockwave_effect_state = "big"

	verb/Super_Explosive_Wave()
		set name = "Super Explosive Wave"
		set category = "Skills"
		useAreaTechnique(usr)

obj/Attacks/NexusAreaTechnique/Earthquake
	name = "Earthquake"
	desc = "Collapse the ground inward, damaging and pulling nearby grounded enemies toward you. Flying targets are unaffected."
	icon = 'src/Icons/NexusIntegrated/Attacks/Effects/RTShockwave.dmi'
	energy_cost = 60
	cooldown_ticks = 160
	radius = 5
	area_damage_factor = 5
	knockback_distance = 0
	pull_distance = 3
	physical_damage = TRUE
	ground_only = TRUE
	cast_text_color = "#d6a76c"
	cast_sound_category = "land"
	shockwave_effect_state = "middle"
	// Use the tracked short rumble by resource name; DU.dme already indexes its containing directory.
	cast_sound = 'Earthquakeshort.ogg'

	verb/Earthquake()
		set category = "Skills"
		useAreaTechnique(usr)

obj/Attacks/NexusSpecialStyle/SuperGhostKamikaze
	name = "Super Ghost Kamikaze Attack"
	desc = "Create three homing ghosts that pursue one selected target. Their shared damage budget prevents the volley from multiplying without limit."
	icon = 'src/Icons/NexusIntegrated/Attacks/Blasts/RTHomingBlast.dmi'
	var
		energy_cost = 100
		cooldown_ticks = 160
		ghost_count = 3
		ghost_damage_factor = 2.5
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
			ghost.icon = icon
			ghost.blast_homing_target = target
			ghost.homing_chance = 140
			ghost.Can_Home = 1
			ghost.Distance = 40
			ghost.vector_speed = 32
			ghost.Shockwave = 2
			ghost.SafeTeleport(user.loc)
			CenterIcon(ghost)
			ghost.queueNexusProjectileGlowUpdate()
			ghost.startKiProjectileWalk(get_dir(user, target))
		if(user) user.attacking = 0
		return TRUE
