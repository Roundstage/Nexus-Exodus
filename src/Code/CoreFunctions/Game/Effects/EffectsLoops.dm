var/list/nexus_status_effect_mobs = list()
var/const/nexus_status_time_epsilon = 0.001

mob/proc/try_applying_burn_effect()
	// Resume saved stacks through the shared scheduler; never overwrite the base regen stat.
	if(!isBurning && BurnStack <= 0) return
	if(KO || rp_mode || Safezone || BurnStack <= 0)
		clearBurnEffect()
		return
	if(burn_effect_running) return
	isBurning = TRUE
	burn_effect_running = TRUE
	burn_next_tick = world.time + 20
	registerNexusStatusEffects()
	refreshBurnOverlay()

mob/proc/applyBurnEffect(mob/source, stacks = 1)
	if(KO || rp_mode || Safezone || stacks <= 0) return FALSE
	var/was_burning = isBurning
	BurnStack = max(0, BurnStack) + stacks
	isBurning = TRUE
	burn_source = source
	burn_combat_mode = getNexusStatusCombatMode(source)
	try_applying_burn_effect()
	if(!was_burning) src << "You are burning! Your Health regeneration is reduced by 30%."
	return TRUE

mob/proc/clearBurnEffect()
	BurnStack = 0
	isBurning = FALSE
	burn_effect_running = FALSE
	burn_next_tick = 0
	burn_source = null
	burn_combat_mode = CASUAL_COMBAT
	refreshBurnOverlay()
	if(!hasNexusStatusEffects()) unregisterNexusStatusEffects()

mob/proc/getBurnRegenerationMultiplier()
	return isBurning && BurnStack > 0 && !KO && !rp_mode && !Safezone ? 0.7 : 1

mob/proc/refreshBurnOverlay()
	// RPT Debuff.dm uses this animated Burning state while periodic damage is active.
	var/list/stale_overlays = list()
	for(var/appearance_value in overlays)
		if(appearance_value:icon == 'src/Icons/NexusIntegrated/Attacks/Effects/RTStatusEffects.dmi' && appearance_value:icon_state == "Burning")
			stale_overlays += appearance_value
	overlays -= stale_overlays
	if(getBurnRegenerationMultiplier() < 1)
		overlays += image('src/Icons/NexusIntegrated/Attacks/Effects/RTStatusEffects.dmi', icon_state = "Burning", layer = MOB_LAYER + 1)

mob/proc/tryApplyFireFistBurn(mob/target)
	if(!isFireFist || !ismob(target) || !prob(40)) return FALSE
	return target.applyBurnEffect(src)

mob/proc/getNexusMaximumHealth()
	return 100

mob/proc/getNexusFireRegenerationMultiplier()
	return world.time < nexus_fire_dot_until ? 0.3 : 1

mob/proc/getNexusElectricStatMultiplier()
	return world.time < nexus_electric_dot_until ? 0.85 : 1

proc/getNexusStatusCombatMode(mob/source)
	return source && source.sparring_mode == LETHAL_COMBAT ? LETHAL_COMBAT : CASUAL_COMBAT

mob/proc/hasNexusStatusEffects()
	return isBurning || BurnStack > 0 || nexus_fire_dot_until > 0 || nexus_electric_dot_until > 0 || nexus_poison_dot_until > 0

mob/proc/registerNexusStatusEffects()
	if(!(src in nexus_status_effect_mobs)) nexus_status_effect_mobs += src

mob/proc/unregisterNexusStatusEffects()
	nexus_status_effect_mobs -= src

mob/proc/applyNexusFireDot(mob/source, duration_ticks = 80, damage_percent = 2)
	if(KO || rp_mode || Safezone) return FALSE
	var/was_active = world.time < nexus_fire_dot_until
	nexus_fire_dot_until = world.time + max(1, duration_ticks)
	nexus_fire_dot_percent = was_active ? max(nexus_fire_dot_percent, damage_percent) : damage_percent
	nexus_fire_dot_source = source
	nexus_fire_dot_combat_mode = getNexusStatusCombatMode(source)
	if(!was_active || nexus_fire_dot_next_tick <= world.time) nexus_fire_dot_next_tick = world.time + 20
	registerNexusStatusEffects()
	if(!was_active) src << "Arcane fire engulfs you, crippling regeneration."
	return TRUE

mob/proc/applyNexusElectricDot(mob/source, duration_ticks = 60, damage_percent = 1)
	if(KO || rp_mode || Safezone) return FALSE
	var/was_active = world.time < nexus_electric_dot_until
	nexus_electric_dot_until = world.time + max(1, duration_ticks)
	nexus_electric_dot_percent = was_active ? max(nexus_electric_dot_percent, damage_percent) : damage_percent
	nexus_electric_dot_source = source
	nexus_electric_dot_combat_mode = getNexusStatusCombatMode(source)
	if(!was_active || nexus_electric_dot_next_tick <= world.time) nexus_electric_dot_next_tick = world.time + 20
	registerNexusStatusEffects()
	if(!was_active) src << "Electric arcs disrupt your Accuracy, Reflex and Speed."
	return TRUE

mob/proc/applyNexusPoisonDot(mob/source, duration_ticks = 120, damage_percent = 2)
	if(KO || rp_mode || Safezone || Poison_resist() >= 100) return FALSE
	var/was_active = world.time < nexus_poison_dot_until
	nexus_poison_dot_until = world.time + max(1, duration_ticks)
	nexus_poison_dot_percent = was_active ? max(nexus_poison_dot_percent, damage_percent) : damage_percent
	nexus_poison_dot_source = source
	nexus_poison_dot_combat_mode = getNexusStatusCombatMode(source)
	if(!was_active || nexus_poison_dot_next_tick <= world.time) nexus_poison_dot_next_tick = world.time + 20
	registerNexusStatusEffects()
	if(!was_active) src << "A dangerous poison begins attacking your vitality."
	return TRUE

mob/proc/clearNexusStatusEffects()
	clearBurnEffect()
	nexus_fire_dot_until = 0
	nexus_fire_dot_next_tick = 0
	nexus_fire_dot_percent = 0
	nexus_fire_dot_source = null
	nexus_fire_dot_combat_mode = CASUAL_COMBAT
	nexus_electric_dot_until = 0
	nexus_electric_dot_next_tick = 0
	nexus_electric_dot_percent = 0
	nexus_electric_dot_source = null
	nexus_electric_dot_combat_mode = CASUAL_COMBAT
	nexus_poison_dot_until = 0
	nexus_poison_dot_next_tick = 0
	nexus_poison_dot_percent = 0
	nexus_poison_dot_source = null
	nexus_poison_dot_combat_mode = CASUAL_COMBAT
	unregisterNexusStatusEffects()

mob/proc/applyNexusStatusDamage(amount, mob/source, effect_name, combat_mode = CASUAL_COMBAT)
	if(amount <= 0 || KO || rp_mode || Safezone) return 0
	var/health_before = Health
	Health = max(0, Health - amount)
	var/applied_damage = health_before - Health
	if(applied_damage <= 0) return 0
	if(source && source != src) SetLastAttackedTime(source)
	gainAngerFromDamage(applied_damage)
	showDamageIndicator(applied_damage)
	updateOverheadHealthHud()
	queueNexusCombatDamage(source, applied_damage, effect_name, "Health")
	if(Health <= 0 && !KO) KO(source, combat_mode_override = combat_mode)
	return applied_damage

mob/proc/processNexusStatusEffects(current_time_override)
	if(KO || rp_mode || Safezone)
		clearNexusStatusEffects()
		return
	var/current_time = isnum(current_time_override) ? current_time_override : world.time
	if(isBurning || BurnStack > 0)
		try_applying_burn_effect()
		while(!KO && BurnStack > 0 && current_time + nexus_status_time_epsilon >= burn_next_tick)
			burn_next_tick += 20
			BurnStack--
			applyNexusStatusDamage(3, burn_source, "Burn", burn_combat_mode)
		if(KO || BurnStack <= 0)
			clearBurnEffect()
			if(!KO) src << "You are no longer burning."
	if(KO) return
	if(nexus_fire_dot_until > 0)
		while(!KO && nexus_fire_dot_next_tick <= nexus_fire_dot_until + nexus_status_time_epsilon && current_time + nexus_status_time_epsilon >= nexus_fire_dot_next_tick)
			nexus_fire_dot_next_tick += 20
			applyNexusStatusDamage(getNexusMaximumHealth() * nexus_fire_dot_percent / 100, nexus_fire_dot_source, "Fire DoT", nexus_fire_dot_combat_mode)
		if(current_time + nexus_status_time_epsilon >= nexus_fire_dot_until && nexus_fire_dot_next_tick > nexus_fire_dot_until + nexus_status_time_epsilon)
			nexus_fire_dot_until = 0
			nexus_fire_dot_next_tick = 0
			nexus_fire_dot_percent = 0
			nexus_fire_dot_source = null
			nexus_fire_dot_combat_mode = CASUAL_COMBAT
	if(KO) return
	if(nexus_electric_dot_until > 0)
		var/electric_tick_applied = FALSE
		while(!KO && nexus_electric_dot_next_tick <= nexus_electric_dot_until + nexus_status_time_epsilon && current_time + nexus_status_time_epsilon >= nexus_electric_dot_next_tick)
			nexus_electric_dot_next_tick += 20
			applyNexusStatusDamage(getNexusMaximumHealth() * nexus_electric_dot_percent / 100, nexus_electric_dot_source, "Electric DoT", nexus_electric_dot_combat_mode)
			electric_tick_applied = TRUE
		if(electric_tick_applied && !KO && !paralysis_immune) ApplyStun(time = 3, stun_power = 0.5)
		if(current_time + nexus_status_time_epsilon >= nexus_electric_dot_until && nexus_electric_dot_next_tick > nexus_electric_dot_until + nexus_status_time_epsilon)
			nexus_electric_dot_until = 0
			nexus_electric_dot_next_tick = 0
			nexus_electric_dot_percent = 0
			nexus_electric_dot_source = null
			nexus_electric_dot_combat_mode = CASUAL_COMBAT
	if(KO) return
	if(nexus_poison_dot_until > 0)
		if(Poison_resist() >= 100)
			nexus_poison_dot_until = 0
			nexus_poison_dot_next_tick = 0
			nexus_poison_dot_percent = 0
			nexus_poison_dot_source = null
			nexus_poison_dot_combat_mode = CASUAL_COMBAT
		else
			while(!KO && nexus_poison_dot_next_tick <= nexus_poison_dot_until + nexus_status_time_epsilon && current_time + nexus_status_time_epsilon >= nexus_poison_dot_next_tick)
				nexus_poison_dot_next_tick += 20
				var/poison_damage = getNexusMaximumHealth() * nexus_poison_dot_percent / 100 / max(0.1, Poison_resist())
				applyNexusStatusDamage(poison_damage, nexus_poison_dot_source, "Poison DoT", nexus_poison_dot_combat_mode)
			if(current_time + nexus_status_time_epsilon >= nexus_poison_dot_until && nexus_poison_dot_next_tick > nexus_poison_dot_until + nexus_status_time_epsilon)
				nexus_poison_dot_until = 0
				nexus_poison_dot_next_tick = 0
				nexus_poison_dot_percent = 0
				nexus_poison_dot_source = null
				nexus_poison_dot_combat_mode = CASUAL_COMBAT
	if(!hasNexusStatusEffects()) unregisterNexusStatusEffects()

proc/processNexusActiveStatusEffects()
	if(!nexus_status_effect_mobs || !nexus_status_effect_mobs.len) return
	var/list/status_targets = nexus_status_effect_mobs.Copy()
	for(var/mob/status_target in status_targets)
		if(status_target) status_target.processNexusStatusEffects()
	nexus_status_effect_mobs -= null
