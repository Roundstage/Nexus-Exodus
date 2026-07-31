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
		setRPMode(TRUE, announce = FALSE)
		if(announce) src << "<font color=red>Your will is broken. You cannot rise until the lethal combat pressure fades."
	return drained

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
	if(rp_mode == enabled) return
	rp_mode = enabled
	if(enabled)
		attacking = 0
		Auto_Attack = 0
		Action = null
		if(announce) player_view(22, src) << "<font color=#80c0ff>[src] enters RP Mode and withdraws from combat."
	else if(announce)
		player_view(22, src) << "<font color=#80c0ff>[src] leaves RP Mode."

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
