mob/var/tmp
	healing_modifier = 1
	has_healing_modifier_changed = FALSE
	is_waiting_for_healing = FALSE
	last_combat_timeout_message = 0
	is_healing_something = FALSE
	list/anger_combat_opponents

// Saved with the character so reconnecting cannot immediately rearm Anger.
mob/var
	has_angered_before_ko = FALSE
	anger_last_combat_at = 0

var/const/ANGER_ROUND_REST_TIME = 5 * 60 * 10

mob/proc/canRestAngerCombatRound()
	return !KO && Health >= 100 && Ki >= max_ki && world.realtime - anger_last_combat_at >= ANGER_ROUND_REST_TIME

mob/proc/tryResetAngerAfterRest()
	if(!has_angered_before_ko && !length(anger_combat_opponents)) return FALSE
	if(!anger_last_combat_at || !canRestAngerCombatRound()) return FALSE
	for(var/mob/opponent in anger_combat_opponents)
		if(!opponent.KO && !opponent.canRestAngerCombatRound()) return FALSE
	for(var/mob/opponent in anger_combat_opponents)
		opponent.anger_combat_opponents -= src
	anger_combat_opponents = null
	has_angered_before_ko = FALSE
	return TRUE

mob/proc/recordAngerCombatOpponent(mob/opponent)
	if(!ismob(opponent) || opponent == src || KO || opponent.KO) return
	tryResetAngerAfterRest()
	opponent.tryResetAngerAfterRest()
	if(!anger_combat_opponents) anger_combat_opponents = list()
	if(!opponent.anger_combat_opponents) opponent.anger_combat_opponents = list()
	anger_combat_opponents |= opponent
	opponent.anger_combat_opponents |= src
	anger_last_combat_at = world.realtime
	opponent.anger_last_combat_at = world.realtime

mob/proc/finishAngerCombatRound()
	// A real defeat ends this character's round and removes them from every rival's round.
	// A rival still fighting someone else keeps their consumed second wind.
	for(var/mob/opponent in anger_combat_opponents)
		opponent.anger_combat_opponents -= src
		if(!length(opponent.anger_combat_opponents))
			opponent.has_angered_before_ko = FALSE
			opponent.Calm()
	anger_combat_opponents = null
	has_angered_before_ko = FALSE
	Calm()

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
