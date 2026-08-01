mob
	var/tmp/obj/Attacks/TenkaichiMeleeTechnique/active_tenkaichi_melee_technique
	var/tmp/mob/active_tenkaichi_melee_target
	var/tmp/tenkaichi_melee_context_id = 0

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
		stun_ticks = 0
		bleed_fraction = 0
		breaks_guard = FALSE
		splash_mode
		splash_radius = 0
		splash_damage_multiplier = 0
		splash_target_limit = 0
		effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTImpact.dmi'
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
		for(var/hit_index = 1, hit_index <= extra_hits, hit_index++)
			if(!target || target.Health <= 0) break
			attacker.applyTenkaichiTechniqueDamage(target, damage * extra_hit_multiplier)
		if(target && bleed_fraction > 0) target.BleedDamage(damage * bleed_fraction)
		if(target && stun_ticks > 0) target.ApplyStun(time = stun_ticks, stun_power = 1.5)
		var/secondary_count = 0
		for(var/mob/secondary_target in getSplashTargets(attacker, target))
			if(secondary_count >= splash_target_limit) break
			if(!attacker.canHitTenkaichiTechniqueTarget(secondary_target)) continue
			secondary_count++
			showImpact(secondary_target)
			attacker.applyTenkaichiTechniqueDamage(secondary_target, damage * splash_damage_multiplier)
			if(secondary_target && knockback_multiplier > 1) secondary_target.Knockback(attacker, max(1, round(knockback_multiplier)))

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
	if(!can_melee()) return FALSE
	var/maximum_range = max(1, technique.dash_range)
	var/mob/target = getSelectedTarget(max_dist = maximum_range)
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
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTSlashDust.dmi'
	verb/Iai_Slash()
		set name = "Iai Slash"
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
	desc = "A focused piercing stab with high damage and a bleeding wound."
	requires_weapon = TRUE
	damage_multiplier = 1.4
	accuracy_bonus = 5
	bleed_fraction = 0.1
	energy_cost = 18
	cooldown_ticks = 100
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTStab.dmi'
	verb/Sword_Stab()
		set name = "Sword Stab"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/OverheadSmash
	name = "Overhead Smash"
	desc = "A heavy, less accurate overhead attack that crashes into the three forward tiles."
	requires_weapon = TRUE
	damage_multiplier = 1.35
	accuracy_bonus = -15
	knockback_multiplier = 1.3
	energy_cost = 20
	cooldown_ticks = 100
	splash_mode = "front"
	splash_damage_multiplier = 0.65
	splash_target_limit = 2
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
	desc = "Two rising unarmed blows that lift the target away."
	requires_unarmed = TRUE
	damage_multiplier = 0.8
	extra_hits = 1
	extra_hit_multiplier = 0.55
	knockback_multiplier = 1.5
	energy_cost = 14
	cooldown_ticks = 75
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
	desc = "A rapid three-kick combination with escalating impact."
	requires_unarmed = TRUE
	damage_multiplier = 0.7
	extra_hits = 2
	extra_hit_multiplier = 0.45
	knockback_multiplier = 1.4
	energy_cost = 22
	cooldown_ticks = 110
	verb/Kickback_Combo()
		set name = "Kickback Combo"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/MarchOfFury
	name = "March of Fury"
	desc = "Rush toward a target and deliver a six-hit advancing combination."
	requires_unarmed = TRUE
	damage_multiplier = 0.4
	extra_hits = 5
	extra_hit_multiplier = 0.25
	dash_range = 7
	energy_cost = 34
	cooldown_ticks = 170
	verb/March_of_Fury()
		set name = "March of Fury"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/PileDriver
	name = "Pile Driver"
	desc = "A committed grappling impact with high damage and a short stun."
	requires_unarmed = TRUE
	damage_multiplier = 1.5
	stun_ticks = 8
	energy_cost = 24
	cooldown_ticks = 125
	effect_icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTImpactHeavy.dmi'
	verb/Pile_Driver()
		set name = "Pile Driver"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/TenkaichiMeleeTechnique/MegatonThrow
	name = "Megaton Throw"
	desc = "A massive body check adapted as a high-knockback unarmed strike."
	requires_unarmed = TRUE
	damage_multiplier = 1.3
	knockback_multiplier = 2
	energy_cost = 20
	cooldown_ticks = 110
	verb/Megaton_Throw()
		set name = "Megaton Throw"
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
