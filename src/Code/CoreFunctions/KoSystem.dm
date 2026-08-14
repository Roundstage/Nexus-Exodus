mob/var/tmp
	healing_modifier = 1
	has_healing_modifier_changed = FALSE
	is_waiting_for_healing = FALSE
	last_combat_timeout_message = 0
	has_angered_before_ko = FALSE
	is_healing_something = FALSE

mob/proc/Cause_Combat_KO(mob/victim, mob/attacker, combat_mode_override)
	if(!victim) victim = src
	victim.combat_ko_total = 0 // Deprecated three-KO save field.
	victim.is_waiting_for_healing = FALSE
	victim.is_healing_something = FALSE
	victim.willpower_ready_announced = FALSE
	var/has_mode_override = combat_mode_override == CASUAL_COMBAT || combat_mode_override == LETHAL_COMBAT
	var/is_casual = has_mode_override ? combat_mode_override == CASUAL_COMBAT : attacker && attacker.sparring_mode == CASUAL_COMBAT
	if(is_casual)
		victim.ko_is_lethal = FALSE
		victim.ko_recovery_ready_at = world.time + victim.time_to_heal_ko(victim)
		var/attacker_name = attacker ? "[attacker]" : "an unknown cause"
		victim.announce_combat_message("[victim] was defeated by [attacker_name] during a [CASUAL_COMBAT].", center = victim)
		return
	victim.enterLethalCombat()
	victim.ko_recovery_ready_at = world.time + victim.time_to_heal_ko(victim)
	victim.setRPMode(TRUE, announce = FALSE)
	var/attacker_name = attacker ? "[attacker]" : "an unknown cause"
	victim.announce_combat_message("[victim] was defeated by [attacker_name] during a [LETHAL_COMBAT].", center = victim)
	victim.drainWillpower(victim.getLethalKoDrain(), "The lethal knockout damages your resolve.")

// Compatibility wrappers for healing items which previously manipulated KO counters.
mob/proc/increase_combat_ko(reason_of_increase, quantity = 1, mob/victim)
	if(!victim) victim = src
	victim.combat_ko_total = 0
	return victim.drainWillpower(max(1, quantity) * WILLPOWER_EXTERNAL_DRAIN, reason_of_increase)

mob/proc/decrease_combat_ko(reason_of_decrease, quantity = 1, mob/victim)
	if(!victim) victim = src
	victim.combat_ko_total = 0
	return victim.restoreWillpower(max(1, quantity) * WILLPOWER_LETHAL_KO_DRAIN, reason_of_decrease)

mob/proc/get_time_out_of_combat(mob/victim)
	if(!victim) victim = src
	return world.time - victim.last_attacked_time

mob/proc/has_entered_combat(mob/victim)
	if(!victim) victim = src
	if(!victim.last_attacked_time) return FALSE
	return victim.get_time_out_of_combat(victim) <= KO_SYSTEM_OUT_OF_COMBAT_TIMER

mob/proc/is_out_of_combat(mob/victim)
	if(!victim) victim = src
	return !victim.has_entered_combat(victim)

mob/proc/announce_combat_message(message, mob/center)
	if(!center) center = src
	for(var/mob/observer in view(44, center))
		observer << "[message]"
		observer.ChatLog("[message]", observer.key)

mob/proc/time_to_heal_ko(mob/victim)
	if(!victim) victim = src
	var/time_to_heal = KO_SYSTEM_NORMAL_KO_DURATION
	time_to_heal *= victim.healing_modifier
	time_to_heal *= 1 - victim.getMilestoneRank("rapid_recovery") * 0.1
	if(victim.z == Z_LEVEL_HBTC) time_to_heal /= 6
	return max(10, round(time_to_heal))

mob/proc/set_healing_modifier(modifier, reason, is_cummulative = FALSE, mob/victim)
	if(!victim) victim = src
	if(modifier <= 0) return
	var/old_modifier = victim.healing_modifier
	var/new_modifier = is_cummulative ? old_modifier * modifier : modifier
	if(new_modifier == old_modifier) return
	victim.healing_modifier = new_modifier
	if(victim.KO && victim.ko_recovery_ready_at > world.time)
		var/remaining = victim.ko_recovery_ready_at - world.time
		victim.ko_recovery_ready_at = world.time + max(10, round(remaining * new_modifier / old_modifier))
	victim.has_healing_modifier_changed = FALSE
	victim.announce_combat_message("[victim]'s knockout recovery modifier changed from [old_modifier]x to [new_modifier]x due to [reason].", center = victim)

mob/proc/try_healing_combat_ko(mob/victim)
	if(!victim) victim = src
	victim.normalizeWillpower()
	if(!victim.KO)
		victim.recoverWillpower()
		return
	if(!victim.ko_recovery_ready_at)
		victim.ko_recovery_ready_at = world.time + victim.time_to_heal_ko(victim)
	if(world.time < victim.ko_recovery_ready_at) return
	if(!victim.ko_is_lethal && !victim.rp_mode)
		victim.UnKO()
		victim.announce_combat_message("[victim] comes back up from their defeat in a [CASUAL_COMBAT].", center = victim)
		return
	if(victim.willpower > 0)
		if(!victim.willpower_ready_announced)
			victim << "Your body is ready. Use Get Up (Willpower) or toggle RP Mode to rise."
			victim.willpower_ready_announced = TRUE
		return
	if(victim.isInLethalCombat()) return
	victim.restoreWillpower(WILLPOWER_FAILURE_RECOVERY, "Your resolve returns after the lethal pressure fades.")
	victim.willpowerGetUp(force = TRUE)
