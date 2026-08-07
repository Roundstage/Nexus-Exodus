mob/var
	rp_mode = FALSE
	willpower = 100
	max_willpower = 100

mob/var/tmp
	ko_is_lethal = FALSE
	ko_recovery_ready_at = 0
	lethal_combat_until = 0
	willpower_recovery_ready_at = 0
	willpower_ready_announced = FALSE
	image/lethal_intent_status_overlay
	image/rp_mode_status_overlay
	rp_mode_input_lock = FALSE

mob/proc/refreshCombatStatusOverlays()
	if(sparring_mode == LETHAL_COMBAT)
		if(!lethal_intent_status_overlay)
			lethal_intent_status_overlay = image('LethalHud.dmi', layer = 25)
			overlays += lethal_intent_status_overlay
	else if(lethal_intent_status_overlay)
		overlays -= lethal_intent_status_overlay
		lethal_intent_status_overlay = null
	if(rp_mode)
		if(!rp_mode_status_overlay)
			rp_mode_status_overlay = image('RPModeHud.dmi', layer = 25)
			overlays += rp_mode_status_overlay
	else if(rp_mode_status_overlay)
		overlays -= rp_mode_status_overlay
		rp_mode_status_overlay = null
	refreshActionHud()

mob/proc/getMaxWillpower()
	return max(1, max_willpower + getMilestoneRank("iron_will") * 10)

mob/proc/normalizeWillpower()
	willpower = Clamp(willpower, 0, getMaxWillpower())
	return willpower

mob/proc/isInLethalCombat()
	return lethal_combat_until > world.time

mob/proc/getLethalKoDrain()
	return max(5, WILLPOWER_LETHAL_KO_DRAIN - getMilestoneRank("will_of_fire") * 5)

mob/proc/getWillpowerRecoveryInterval()
	var/recovery_mult = 1 - getMilestoneRank("steadfast_spirit") * 0.15
	return max(50, round(WILLPOWER_RECOVERY_INTERVAL * recovery_mult))

mob/proc/enterLethalCombat()
	var/duration = willpower > 40 ? WILLPOWER_LETHAL_DURATION : WILLPOWER_CRITICAL_DURATION
	var/rapid_deployment_rank = getMilestoneRank("rapid_deployment")
	if(rapid_deployment_rank) duration *= 1 - rapid_deployment_rank * 0.25
	lethal_combat_until = max(lethal_combat_until, world.time + duration)
	ko_is_lethal = TRUE

mob/proc/drainWillpower(amount, reason, announce = TRUE)
	if(amount <= 0) return 0
	normalizeWillpower()
	var/before = willpower
	willpower = max(0, willpower - amount)
	var/drained = before - willpower
	if(announce && drained > 0)
		src << "<font color=#ff8080>[reason] Willpower: [round(willpower)]/[round(getMaxWillpower())]."
	if(willpower <= 0)
		forceWillpowerBreakKnockout()
		if(announce) src << "<font color=red>Your will is broken. You cannot rise until the lethal combat pressure fades."
	return drained

mob/proc/tryDrainTechniqueWillpower(amount, technique_name = "Technique", reserve = 1)
	if(amount <= 0) return TRUE
	normalizeWillpower()
	reserve = Clamp(reserve, 0, getMaxWillpower())
	if(willpower - amount < reserve) return FALSE
	drainWillpower(amount, "[technique_name] strains your resolve.", announce = FALSE)
	return TRUE

mob/proc/forceWillpowerBreakKnockout()
	ko_is_lethal = TRUE
	ko_recovery_ready_at = max(ko_recovery_ready_at, world.time + time_to_heal_ko(src))
	if(!KO)
		if(client) KO(last_attacker, allow_anger = FALSE, combat_ko_handled = TRUE)
		else
			KO = TRUE
			icon_state = "KO"
			move = 0
			attacking = 0
	setRPMode(TRUE, announce = FALSE)
	updateOverheadHealthHud()

mob/proc/restoreWillpower(amount, reason, announce = TRUE)
	if(amount <= 0) return 0
	normalizeWillpower()
	var/before = willpower
	willpower = min(getMaxWillpower(), willpower + amount)
	var/restored = willpower - before
	if(announce && restored > 0)
		src << "<font color=#80ff80>[reason] Willpower: [round(willpower)]/[round(getMaxWillpower())]."
	return restored

mob/proc/setRPMode(enabled, announce = TRUE)
	enabled = !!enabled
	if(rp_mode == enabled)
		if(enabled && !rp_mode_input_lock)
			AlterInputDisabled(1)
			rp_mode_input_lock = TRUE
		else if(!enabled && rp_mode_input_lock)
			AlterInputDisabled(-1)
			rp_mode_input_lock = FALSE
		refreshCombatStatusOverlays()
		return
	rp_mode = enabled
	if(enabled)
		if(grabbedObject) ReleaseGrab()
		if(grabber) grabber.ReleaseGrab()
		if(!rp_mode_input_lock)
			AlterInputDisabled(1)
			rp_mode_input_lock = TRUE
		attacking = 0
		Auto_Attack = 0
		Action = null
		if(announce) player_view(22, src) << "<font color=#80c0ff>[src] enters RP Mode and withdraws from combat."
	else
		if(rp_mode_input_lock)
			AlterInputDisabled(-1)
			rp_mode_input_lock = FALSE
		if(announce) player_view(22, src) << "<font color=#80c0ff>[src] leaves RP Mode."
	refreshCombatStatusOverlays()

mob/proc/applyRegenerationHealth(amount, drains_willpower = TRUE)
	if(amount <= 0 || Health >= 100) return 0
	var/health_before = Health
	Health = min(100, Health + amount)
	var/healed = Health - health_before
	if(drains_willpower && healed > 0 && isInLethalCombat())
		drainWillpower(healed * 0.25, "Regenerating under combat pressure costs Willpower.", announce = FALSE)
	return healed

mob/proc/willpowerGetUp(force = FALSE)
	if(!KO) return FALSE
	normalizeWillpower()
	if(!force && world.time < ko_recovery_ready_at)
		src << "You need [round((ko_recovery_ready_at - world.time) / 10, 0.1)] more seconds before you can rise."
		return FALSE
	if(willpower <= 0)
		src << "You have no Willpower left."
		return FALSE
	UnKO()
	Health = Clamp(max(1, willpower), 1, 100)
	setRPMode(FALSE, announce = FALSE)
	ko_is_lethal = FALSE
	willpower_ready_announced = FALSE
	updateOverheadHealthHud()
	player_view(22, src) << "<font color=#ffff80>[src] forces themselves back up through sheer Willpower!"
	return TRUE

mob/proc/recoverWillpower()
	normalizeWillpower()
	if(KO || isInLethalCombat() || willpower >= getMaxWillpower()) return
	if(!willpower_recovery_ready_at)
		willpower_recovery_ready_at = world.time + getWillpowerRecoveryInterval()
		return
	if(world.time < willpower_recovery_ready_at) return
	restoreWillpower(WILLPOWER_RECOVERY_AMOUNT, "You recover outside lethal combat.", announce = FALSE)
	willpower_recovery_ready_at = world.time + getWillpowerRecoveryInterval()

mob/verb/toggleRPMode()
	set name = "Toggle RP Mode"
	set category = "Other"
	if(KO && rp_mode)
		willpowerGetUp()
		return
	if(!rp_mode && has_entered_combat(victim = src))
		src << "You cannot enter RP Mode while actively fighting."
		return
	setRPMode(!rp_mode)

mob/verb/useWillpower()
	set name = "Get Up (Willpower)"
	set category = "Other"
	willpowerGetUp()
