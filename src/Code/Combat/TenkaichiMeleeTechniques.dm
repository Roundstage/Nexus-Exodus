mob
	var/tmp/obj/Attacks/TenkaichiMeleeTechnique/active_tenkaichi_melee_technique
	var/tmp/mob/active_tenkaichi_melee_target
	var/tmp/tenkaichi_melee_context_id = 0
	var/tmp/active_tenkaichi_riposte_until = 0

obj/Attacks/TenkaichiMeleeTechnique
	name = "Tenkaichi Melee Technique"
	desc = "A Roleplay Tenkaichi technique adapted to the Nexus combat engine."
	can_hotbar = 1
	hotbar_type = "Melee"
	repeat_macro = 0
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTImpact.dmi'
	var
		requires_weapon = FALSE
		requires_unarmed = FALSE
		damage_multiplier = 1
		accuracy_bonus = 0
		knockback_multiplier = 1
		energy_cost = 8
		cooldown_ticks = 50
		dash_range = 1
		extra_hits = 0
		extra_hit_multiplier = 0
		extra_hit_delay = 2
		stun_ticks = 0
		bleed_fraction = 0
		breaks_guard = FALSE
		behavior = "strike"
		line_reach = 0
		splash_mode
		splash_radius = 0
		splash_damage_multiplier = 0
		splash_target_limit = 0
		effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTImpact.dmi'
		effect_icon_state
		tmp/next_use = 0

	verb/Hotbar_use()
		set hidden = 1
		useTechnique(usr)

	proc/useTechnique(mob/user)
		if(user) user.castTenkaichiMeleeTechnique(src)

	proc/showImpact(mob/target)
		if(!target || !effect_icon) return
		var/obj/Effect/effect = GetEffect()
		effect.icon = effect_icon
		if(effect_icon_state) effect.icon_state = effect_icon_state
		effect.density = 0
		effect.SafeTeleport(target.loc)
		CenterIcon(effect)
		spawn(5) if(effect) del(effect)

	proc/getSplashTargets(mob/attacker, mob/primary_target)
		var/list/targets = list()
		if(!attacker || !splash_damage_multiplier || !splash_target_limit) return targets
		if(splash_mode == "front")
			var/turf/front = get_step(attacker, attacker.dir)
			if(!front) return targets
			var/list/target_turfs = list(front, get_step(front, turn(attacker.dir, 90)), get_step(front, turn(attacker.dir, -90)))
			for(var/turf/target_turf in target_turfs)
				if(!target_turf) continue
				for(var/mob/candidate in target_turf)
					if(candidate != attacker && candidate != primary_target) targets += candidate
		else if(splash_mode == "radius")
			for(var/mob/candidate in oview(splash_radius, attacker))
				if(candidate != primary_target) targets += candidate
		return targets

	proc/applyOnHit(mob/attacker, mob/target, damage)
		if(!attacker || !target) return
		showImpact(target)
		if(target && bleed_fraction > 0) target.BleedDamage(damage * bleed_fraction)
		if(target && stun_ticks > 0) target.ApplyStun(time = stun_ticks, stun_power = 1.5)
		if(line_reach > 1) applyLineHits(attacker, target, damage)
		var/secondary_count = 0
		for(var/mob/secondary_target in getSplashTargets(attacker, target))
			if(secondary_count >= splash_target_limit) break
			if(!attacker.canHitTenkaichiTechniqueTarget(secondary_target)) continue
			secondary_count++
			showImpact(secondary_target)
			attacker.applyTenkaichiTechniqueDamage(secondary_target, damage * splash_damage_multiplier)
			if(secondary_target && knockback_multiplier > 1) secondary_target.Knockback(attacker, max(1, round(knockback_multiplier)))
		if(extra_hits > 0) spawn()
			for(var/hit_index = 1, hit_index <= extra_hits, hit_index++)
				sleep(extra_hit_delay)
				if(!target || target.Health <= 0 || getdist(attacker, target) > 1) break
				showImpact(target)
				attacker.applyTenkaichiTechniqueDamage(target, damage * extra_hit_multiplier)
		if(behavior == "kickback_combo") spawn() attacker.performTenkaichiKickbackFollowup(src, target)

	proc/applyLineHits(mob/attacker, mob/primary_target, damage)
		if(!attacker || line_reach < 2) return
		var/turf/line_turf = get_step(attacker, attacker.dir)
		for(var/tile_index = 2, tile_index <= line_reach, tile_index++)
			line_turf = get_step(line_turf, attacker.dir)
			if(!line_turf || line_turf.density) break
			for(var/mob/line_target in line_turf)
				if(line_target == primary_target || !attacker.canHitTenkaichiTechniqueTarget(line_target)) continue
				showImpact(line_target)
				attacker.applyTenkaichiTechniqueDamage(line_target, damage * 0.75)

mob/proc/canHitTenkaichiTechniqueTarget(mob/target)
	if(!target || target == src || target.rp_mode || target.Safezone) return FALSE
	return TRUE

mob/proc/applyTenkaichiTechniqueDamage(mob/target, damage)
	if(!canHitTenkaichiTechniqueTarget(target) || damage <= 0) return FALSE
	target.TakeDamage(damage)
	if(target && target.Health <= 0)
		if(!target.KO) target.KO(src)
		else if(Fatal) target.Death(src)
	return TRUE

mob/proc/resolveTenkaichiTechniqueHit(mob/target, obj/Attacks/TenkaichiMeleeTechnique/technique, damage_multiplier = 1, force_hit = FALSE)
	if(!canHitTenkaichiTechniqueTarget(target) || !technique) return FALSE
	var/accuracy = Clamp(get_melee_accuracy(target) + technique.accuracy_bonus, 0, 100)
	if(!force_hit && target.CanMeleeDodge(src) && target.evade_meter > 0 && !prob(accuracy))
		target.MeleeAutoDodge(src)
		return FALSE
	if(target.blocking && !technique.breaks_guard)
		if(technique.behavior == "iai_dash")
			player_view(15, src) << "[target] completely blocks [src]'s [technique]."
			return FALSE
		damage_multiplier *= 0.23
	var/damage = get_melee_damage(target) * technique.damage_multiplier * damage_multiplier
	if(!applyTenkaichiTechniqueDamage(target, damage)) return FALSE
	technique.showImpact(target)
	if(technique.bleed_fraction > 0) target.BleedDamage(damage * technique.bleed_fraction)
	if(technique.stun_ticks > 0) target.ApplyStun(time = technique.stun_ticks, stun_power = 1.5)
	if(technique.knockback_multiplier > 1) target.Knockback(src, max(1, round(technique.knockback_multiplier)), bypass_immunity = 1)
	return TRUE

mob/proc/payTenkaichiTechniqueCost(obj/Attacks/TenkaichiMeleeTechnique/technique)
	if(!technique) return FALSE
	var/technique_drain = GetSkillDrain(mod = technique.energy_cost, is_energy = 0)
	if(Ki < technique_drain)
		src << "You do not have enough energy to use [technique]."
		return FALSE
	Ki -= technique_drain
	technique.next_use = world.time + technique.cooldown_ticks
	return TRUE

mob/proc/consumeTenkaichiMeleeTechnique(mob/target)
	if(!active_tenkaichi_melee_technique || active_tenkaichi_melee_target != target) return
	var/obj/Attacks/TenkaichiMeleeTechnique/technique = active_tenkaichi_melee_technique
	active_tenkaichi_melee_technique = null
	active_tenkaichi_melee_target = null
	return technique

mob/proc/castTenkaichiMeleeTechnique(obj/Attacks/TenkaichiMeleeTechnique/technique)
	set waitfor = 0
	if(!technique || technique.loc != src || KO || rp_mode) return FALSE
	if(world.time < technique.next_use)
		var/seconds_left = round((technique.next_use - world.time) / 10, 0.1)
		src << "[technique] will be ready in [seconds_left] seconds."
		return FALSE
	var/obj/items/Sword/weapon = using_sword()
	if(technique.requires_weapon && !weapon)
		src << "You must equip a weapon before using [technique]."
		return FALSE
	if(technique.requires_unarmed && weapon)
		src << "You must unequip your weapon before using [technique]."
		return FALSE
	if(technique.behavior == "grapple_throw" || technique.behavior == "grapple_slam") return castTenkaichiGrappleTechnique(technique)
	if(technique.behavior == "iai_dash") return castTenkaichiIaiSlash(technique)
	if(technique.behavior == "march") return castTenkaichiMarchOfFury(technique)
	if(technique.behavior == "delayed_barrage") return castTenkaichiDelayedBarrage(technique)
	if(technique.behavior == "riposte") return activateTenkaichiRiposte(technique)
	if(!can_melee()) return FALSE
	var/maximum_range = max(1, technique.dash_range)
	var/mob/target = getTenkaichiTechniqueTarget(maximum_range)
	if(!target && technique.splash_mode == "radius")
		for(var/mob/candidate in oview(1, src))
			if(canHitTenkaichiTechniqueTarget(candidate))
				target = candidate
				break
	if(!canHitTenkaichiTechniqueTarget(target))
		var/range_label = maximum_range == 1 ? "tile" : "tiles"
		src << "Select a valid target within [maximum_range] [range_label]."
		return FALSE
	var/technique_drain = GetSkillDrain(mod = technique.energy_cost, is_energy = 0)
	var/base_melee_drain = GetSkillDrain(mod = 24, is_energy = 0)
	if(Ki < technique_drain + base_melee_drain)
		src << "You do not have enough energy to use [technique]."
		return FALSE
	if(getdist(src, target) > 1)
		for(var/step_index = 1, step_index <= maximum_range && target && getdist(src, target) > 1, step_index++)
			AfterImage(5)
			if(!step_towards(src, target)) break
			sleep(world.tick_lag)
	if(!target || getdist(src, target) > 1)
		src << "[technique] could not reach the selected target."
		return FALSE
	Ki -= technique_drain
	technique.next_use = world.time + technique.cooldown_ticks
	setTenkaichiMeleeContext(technique, target)
	Melee(target, from_auto_attack = 1)
	return TRUE

mob/proc/getTenkaichiTechniqueTarget(maximum_range = 1)
	var/mob/target = getSelectedTarget(max_dist = maximum_range)
	if(canHitTenkaichiTechniqueTarget(target)) return target
	if(maximum_range <= 1)
		var/turf/front = get_step(src, dir)
		if(front)
			for(var/mob/candidate in front)
				if(canHitTenkaichiTechniqueTarget(candidate)) return candidate

mob/proc/castTenkaichiIaiSlash(obj/Attacks/TenkaichiMeleeTechnique/technique)
	if(!technique || !can_melee()) return FALSE
	var/mob/selected = getSelectedTarget(max_dist = technique.dash_range)
	if(!canHitTenkaichiTechniqueTarget(selected))
		src << "Select a valid target within [technique.dash_range] tiles."
		return FALSE
	if(!payTenkaichiTechniqueCost(technique)) return FALSE
	var/dash_direction = get_dir(src, selected)
	var/list/hit_targets = list()
	attacking = 1
	dir = dash_direction
	animate(src, alpha = 155, time = 2)
	for(var/step_index = 1, step_index <= technique.dash_range, step_index++)
		var/turf/next_turf = get_step(src, dash_direction)
		if(!next_turf || next_turf.density) break
		for(var/mob/candidate in next_turf)
			if(canHitTenkaichiTechniqueTarget(candidate) && !(candidate in hit_targets)) hit_targets += candidate
		AfterImage(5)
		SafeTeleport(next_turf)
		sleep(world.tick_lag)
	for(var/mob/hit_target in hit_targets)
		resolveTenkaichiTechniqueHit(hit_target, technique)
	animate(src, alpha = 255, time = 2)
	Reset_melee()
	return TRUE

mob/proc/castTenkaichiMarchOfFury(obj/Attacks/TenkaichiMeleeTechnique/technique)
	if(!technique || !can_melee()) return FALSE
	var/mob/target = getSelectedTarget(max_dist = technique.dash_range)
	if(!canHitTenkaichiTechniqueTarget(target))
		src << "March of Fury requires a selected target within [technique.dash_range] tiles."
		return FALSE
	if(!payTenkaichiTechniqueCost(technique)) return FALSE
	attacking = 1
	for(var/hit_index = 1, hit_index <= 4, hit_index++)
		if(!target || !canHitTenkaichiTechniqueTarget(target)) break
		for(var/pursuit_step = 1, pursuit_step <= 2 && getdist(src, target) > 1, pursuit_step++)
			AfterImage(5)
			if(!step_towards(src, target)) break
			sleep(world.tick_lag)
		if(getdist(src, target) <= 1)
			dir = get_dir(src, target)
			resolveTenkaichiTechniqueHit(target, technique, 0.45)
		sleep(4)
	Reset_melee()
	return TRUE

mob/proc/castTenkaichiDelayedBarrage(obj/Attacks/TenkaichiMeleeTechnique/technique)
	if(!technique || !can_melee()) return FALSE
	var/mob/target = getTenkaichiTechniqueTarget(1)
	if(!canHitTenkaichiTechniqueTarget(target))
		src << "[technique] requires an adjacent target."
		return FALSE
	if(!payTenkaichiTechniqueCost(technique)) return FALSE
	attacking = 1
	player_view(15, src) << "[src] prepares a rapid barrage."
	sleep(5)
	for(var/hit_index = 1, hit_index <= 6, hit_index++)
		if(!target || getdist(src, target) > 1) break
		resolveTenkaichiTechniqueHit(target, technique, 0.25)
		sleep(1)
	Reset_melee()
	return TRUE

mob/proc/castTenkaichiGrappleTechnique(obj/Attacks/TenkaichiMeleeTechnique/technique)
	if(!technique) return FALSE
	if(!grabbedObject) Grab()
	var/mob/target = grabbedObject
	if(!target || target.grabber != src || !canHitTenkaichiTechniqueTarget(target))
		src << "You must grab a valid opponent before using [technique]."
		return FALSE
	if(!canUseTenkaichiGrappleTechnique()) return FALSE
	if(!payTenkaichiTechniqueCost(technique)) return FALSE
	attacking = 1
	move = 0
	target.ApplyStun(time = 8, no_immunity = 1, stun_power = 3)
	if(technique.behavior == "grapple_throw")
		animate(src, pixel_y = 32, time = 4)
		animate(target, pixel_y = 32, time = 4)
		sleep(4)
		animate(target, pixel_y = 0, time = 2)
		sleep(2)
		resolveTenkaichiTechniqueHit(target, technique, force_hit = TRUE)
		ReleaseGrab()
		if(target)
			Make_Shockwave(target, sw_icon_size = 128)
			target.Knockback(src, 5, bypass_immunity = 1)
	else
		animate(target, transform = turn(matrix(), 180), pixel_y = 24, time = 4)
		sleep(4)
		animate(target, transform = null, pixel_y = 0, time = 2)
		sleep(2)
		resolveTenkaichiTechniqueHit(target, technique, force_hit = TRUE)
		ReleaseGrab()
		if(target)
			Make_Shockwave(target, sw_icon_size = 128)
			target.ApplyStun(time = 8, no_immunity = 1, stun_power = 3)
	animate(src, pixel_y = 0, time = 2)
	move = 1
	Reset_melee()
	return TRUE

mob/proc/canUseTenkaichiGrappleTechnique()
	var/mob/held_target = grabbedObject
	grabbedObject = null
	var/can_use = can_melee()
	grabbedObject = held_target
	return can_use

mob/proc/performTenkaichiKickbackFollowup(obj/Attacks/TenkaichiMeleeTechnique/technique, mob/target)
	set waitfor = 0
	if(!technique || !target) return
	sleep(5)
	if(!canHitTenkaichiTechniqueTarget(target) || target.blocking) return
	for(var/step_index = 1, step_index <= 6 && getdist(src, target) > 1, step_index++)
		AfterImage(5)
		if(!step_towards(src, target)) break
		sleep(world.tick_lag)
	if(target && getdist(src, target) <= 1)
		resolveTenkaichiTechniqueHit(target, technique, 0.8)

mob/proc/activateTenkaichiRiposte(obj/Attacks/TenkaichiMeleeTechnique/technique)
	if(!technique || !payTenkaichiTechniqueCost(technique)) return FALSE
	active_tenkaichi_riposte_until = world.time + 40
	src << "Riposte is ready for four seconds. The next incoming melee attack will be countered."
	return TRUE

mob/proc/tryTenkaichiRiposte(mob/attacker)
	if(!attacker || world.time > active_tenkaichi_riposte_until || !using_sword()) return FALSE
	var/obj/Attacks/TenkaichiMeleeTechnique/Riposte/riposte = locate() in src
	if(!riposte) return FALSE
	active_tenkaichi_riposte_until = 0
	dir = get_dir(src, attacker)
	player_view(15, src) << "[src] ripostes [attacker]'s melee attack!"
	attacker.ApplyStun(time = 6, stun_power = 2)
	resolveTenkaichiTechniqueHit(attacker, riposte, force_hit = TRUE)
	return TRUE

mob/proc/setTenkaichiMeleeContext(obj/Attacks/TenkaichiMeleeTechnique/technique, mob/target)
	active_tenkaichi_melee_technique = technique
	active_tenkaichi_melee_target = target
	tenkaichi_melee_context_id++
	var/context_id = tenkaichi_melee_context_id
	spawn(2) if(tenkaichi_melee_context_id == context_id)
		active_tenkaichi_melee_technique = null
		active_tenkaichi_melee_target = null

obj/Attacks/TenkaichiMeleeTechnique/Slice
	name = "Slice"
	desc = "A fast weapon strike with regular damage and a very short cooldown."
	requires_weapon = TRUE
	accuracy_bonus = 5
	energy_cost = 4
	cooldown_ticks = 15
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTSlash.dmi'
	verb/Slice()
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/Bash
	name = "Bash"
	desc = "Bash with a hammer or sword pommel, sacrificing damage to stun the target."
	requires_weapon = TRUE
	damage_multiplier = 0.65
	accuracy_bonus = 5
	stun_ticks = 10
	energy_cost = 10
	cooldown_ticks = 80
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTImpact.dmi'
	verb/Bash()
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/Flourish
	name = "Flourish"
	desc = "An elaborate weapon strike that converts speed into stronger impact."
	requires_weapon = TRUE
	damage_multiplier = 1.35
	accuracy_bonus = 10
	knockback_multiplier = 1.2
	energy_cost = 18
	cooldown_ticks = 100
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTSlashArc.dmi'
	verb/Flourish()
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/WindHowl
	name = "Wind Howl"
	desc = "Unleash a slicing shockwave that hits enemies around the wielder."
	requires_weapon = TRUE
	damage_multiplier = 0.9
	energy_cost = 30
	cooldown_ticks = 140
	splash_mode = "radius"
	splash_radius = 2
	splash_damage_multiplier = 0.75
	splash_target_limit = 8
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTCircleWind.dmi'
	verb/Wind_Howl()
		set name = "Wind Howl"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/IaiSlash
	name = "Iai Slash"
	desc = "Rush up to six tiles and strike through the target with a speed-amplified slash."
	requires_weapon = TRUE
	damage_multiplier = 1.25
	accuracy_bonus = 10
	knockback_multiplier = 1.2
	energy_cost = 20
	cooldown_ticks = 100
	dash_range = 6
	behavior = "iai_dash"
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTSlashDust.dmi'
	verb/Iai_Slash()
		set name = "Iai Slash"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/Riposte
	name = "Riposte"
	desc = "Ready your equipped weapon and counter the next incoming melee attack within four seconds."
	requires_weapon = TRUE
	damage_multiplier = 1.15
	accuracy_bonus = 100
	energy_cost = 14
	cooldown_ticks = 100
	behavior = "riposte"
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTSlashArc.dmi'
	verb/Riposte()
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/Cleave
	name = "Cleave"
	desc = "Sweep the three tiles in front of you with increased accuracy and damage."
	requires_weapon = TRUE
	damage_multiplier = 1.1
	accuracy_bonus = 10
	energy_cost = 12
	cooldown_ticks = 60
	splash_mode = "front"
	splash_damage_multiplier = 0.65
	splash_target_limit = 2
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTSlashArc.dmi'
	verb/Cleave()
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/SwordStab
	name = "Sword Stab"
	desc = "A focused stab that pierces the adjacent target and a second target directly behind them."
	requires_weapon = TRUE
	damage_multiplier = 1.4
	accuracy_bonus = 5
	knockback_multiplier = 0
	bleed_fraction = 0.1
	line_reach = 2
	energy_cost = 18
	cooldown_ticks = 100
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTStab.dmi'
	verb/Sword_Stab()
		set name = "Sword Stab"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/OverheadSmash
	name = "Overhead Smash"
	desc = "A heavy, less accurate overhead attack that crashes through three tiles in a straight line."
	requires_weapon = TRUE
	damage_multiplier = 1.35
	accuracy_bonus = -15
	knockback_multiplier = 1.3
	energy_cost = 20
	cooldown_ticks = 100
	line_reach = 3
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTImpactHeavy.dmi'
	verb/Overhead_Smash()
		set name = "Overhead Smash"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/ColossalImpact
	name = "Colossal Impact"
	desc = "Drive your weapon down and unleash a gigantic close-range shockwave."
	requires_weapon = TRUE
	damage_multiplier = 1.1
	knockback_multiplier = 1.5
	energy_cost = 35
	cooldown_ticks = 180
	splash_mode = "radius"
	splash_radius = 2
	splash_damage_multiplier = 0.65
	splash_target_limit = 12
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTShockwave.dmi'
	verb/Colossal_Impact()
		set name = "Colossal Impact"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/BurningSlash
	name = "Burning Slash"
	desc = "A three-hit weapon combo whose finishing strike tears open a bleeding wound."
	requires_weapon = TRUE
	damage_multiplier = 0.65
	extra_hits = 2
	extra_hit_multiplier = 0.45
	extra_hit_delay = 3
	bleed_fraction = 0.1
	energy_cost = 30
	cooldown_ticks = 140
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTBlackSlash.dmi'
	verb/Burning_Slash()
		set name = "Burning Slash"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/Headbutt
	name = "Headbutt"
	desc = "A blunt close-range strike with a brief stagger."
	requires_unarmed = TRUE
	damage_multiplier = 1.15
	stun_ticks = 4
	energy_cost = 10
	cooldown_ticks = 55
	verb/Headbutt()
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/UppercutCombo
	name = "Uppercut Combo"
	desc = "A three-hit rising combination whose final uppercut launches the target."
	requires_unarmed = TRUE
	damage_multiplier = 0.8
	extra_hits = 2
	extra_hit_multiplier = 0.45
	extra_hit_delay = 3
	knockback_multiplier = 1.5
	energy_cost = 14
	cooldown_ticks = 75
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTUppercut.dmi'
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTUppercut.dmi'
	verb/Uppercut_Combo()
		set name = "Uppercut Combo"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/AxeKick
	name = "Axe Kick"
	desc = "A descending kick with strong knockback."
	requires_unarmed = TRUE
	damage_multiplier = 1.25
	knockback_multiplier = 1.4
	energy_cost = 12
	cooldown_ticks = 65
	verb/Axe_Kick()
		set name = "Axe Kick"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/KickbackCombo
	name = "Kickback Combo"
	desc = "Knock the target away, pursue them with afterimages and land a second hit unless they block."
	requires_unarmed = TRUE
	damage_multiplier = 0.9
	knockback_multiplier = 2
	energy_cost = 22
	cooldown_ticks = 110
	behavior = "kickback_combo"
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTSweepingKick.dmi'
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTSweepingKick.dmi'
	verb/Kickback_Combo()
		set name = "Kickback Combo"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/MarchOfFury
	name = "March of Fury"
	desc = "Pursue the selected target through movement and deliver four separately resolved melee attacks."
	damage_multiplier = 1
	dash_range = 7
	energy_cost = 34
	cooldown_ticks = 170
	behavior = "march"
	verb/March_of_Fury()
		set name = "March of Fury"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/PileDriver
	name = "Pile Driver"
	desc = "Requires a grabbed opponent; invert and slam them head-first with an unavoidable impact."
	requires_unarmed = TRUE
	damage_multiplier = 1.5
	stun_ticks = 8
	energy_cost = 24
	cooldown_ticks = 125
	behavior = "grapple_slam"
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTGrappleImpact.dmi'
	icon_state = "1"
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTGrappleImpact.dmi'
	effect_icon_state = "1"
	verb/Pile_Driver()
		set name = "Pile Driver"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/MegatonThrow
	name = "Megaton Throw"
	desc = "Requires a grabbed opponent; leap with them, slam them down and throw them away."
	requires_unarmed = TRUE
	damage_multiplier = 1.3
	energy_cost = 20
	cooldown_ticks = 110
	behavior = "grapple_throw"
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTGrappleImpact.dmi'
	icon_state = "2"
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTGrappleImpact.dmi'
	effect_icon_state = "2"
	verb/Megaton_Throw()
		set name = "Megaton Throw"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/ConsecutiveNormalPunches
	name = "Consecutive Normal Punches"
	desc = "Telegraph briefly, then unleash six separately resolved unarmed hits on an adjacent target."
	requires_unarmed = TRUE
	damage_multiplier = 1
	accuracy_bonus = 5
	energy_cost = 30
	cooldown_ticks = 170
	behavior = "delayed_barrage"
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTImpact.dmi'
	verb/Consecutive_Normal_Punches()
		set name = "Consecutive Normal Punches"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/ExplodingHeartStrike
	name = "Exploding Heart Strike"
	desc = "A precise unarmed strike that deals heavy damage and internal bleeding."
	requires_unarmed = TRUE
	damage_multiplier = 1.45
	accuracy_bonus = 5
	bleed_fraction = 0.15
	energy_cost = 24
	cooldown_ticks = 130
	verb/Exploding_Heart_Strike()
		set name = "Exploding Heart Strike"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/TexasSmash
	name = "Texas Smash"
	desc = "A slow, devastating unarmed blow with extreme knockback."
	requires_unarmed = TRUE
	damage_multiplier = 1.6
	accuracy_bonus = -10
	knockback_multiplier = 2
	energy_cost = 32
	cooldown_ticks = 180
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTShockwave.dmi'
	verb/Texas_Smash()
		set name = "Texas Smash"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/GuardBreak
	name = "Guard Break"
	desc = "A focused strike that bypasses an active melee guard and briefly staggers the defender."
	damage_multiplier = 0.8
	accuracy_bonus = 20
	breaks_guard = TRUE
	stun_ticks = 6
	energy_cost = 18
	cooldown_ticks = 105
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTImpactHeavy.dmi'
	verb/Guard_Break()
		set name = "Guard Break"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/WingClip
	name = "Wing Clip"
	desc = "Attack the target's joints with high accuracy, reduced damage and a movement stagger."
	damage_multiplier = 0.75
	accuracy_bonus = 18
	stun_ticks = 7
	energy_cost = 16
	cooldown_ticks = 90
	verb/Wing_Clip()
		set name = "Wing Clip"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/BurningShot
	name = "Burning Shot"
	desc = "Warp into range and land a fiery three-hit unarmed combination."
	requires_unarmed = TRUE
	damage_multiplier = 0.7
	extra_hits = 2
	extra_hit_multiplier = 0.4
	dash_range = 6
	energy_cost = 28
	cooldown_ticks = 140
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTBurningShot.dmi'
	verb/Burning_Shot()
		set name = "Burning Shot"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/BlueCometSpecial
	name = "Blue Comet Special"
	desc = "A speed-focused advancing assault adapted as a long-range five-hit rush."
	requires_unarmed = TRUE
	damage_multiplier = 0.5
	extra_hits = 4
	extra_hit_multiplier = 0.25
	dash_range = 8
	energy_cost = 34
	cooldown_ticks = 175
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTShockwave.dmi'
	verb/Blue_Comet_Special()
		set name = "Blue Comet Special"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/CriticalEdge
	name = "Critical Edge"
	desc = "Condense the original critical stance into one accurate strike at 133% damage."
	damage_multiplier = 1.33
	accuracy_bonus = 15
	energy_cost = 20
	cooldown_ticks = 120
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTImpactHeavy.dmi'
	verb/Critical_Edge()
		set name = "Critical Edge"
		set category = "Skills"
		useTechnique(usr)
