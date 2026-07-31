#define COMBAT_DAMAGE_PHYSICAL 1
#define COMBAT_DAMAGE_KI 2

var
	combat_damage_bp_exponent = 0.5
	combat_damage_stat_exponent = 0.85

proc/calculateScaledCombatDamage(factor = 0, attacker_bp = 0, defender_bp = 0, source_stat = 0, guard_stat = 0)
	if(factor <= 0 || attacker_bp <= 0 || source_stat <= 0) return 0
	defender_bp = max(defender_bp, 0.01)
	guard_stat = max(guard_stat, 0)
	var/stat_term = 2 * source_stat / (source_stat + guard_stat)
	stat_term = Clamp(stat_term, 0, 2) ** combat_damage_stat_exponent
	return factor * (attacker_bp / defender_bp) ** combat_damage_bp_exponent * stat_term

mob/proc/getPhysicalCombatDamage(mob/target, factor = 0)
	if(!target) return 0
	return calculateScaledCombatDamage(factor, BP, target.BP, Swordless_strength(), target.End)

mob/proc/getKiCombatDamage(mob/target, factor = 0)
	if(!target) return 0
	return calculateScaledCombatDamage(factor, BP, target.BP, Pow, target.Res)

mob/proc/getHybridCombatDamage(mob/target, factor = 0)
	if(!target || factor <= 0) return 0
	var/physical_damage = getPhysicalCombatDamage(target, factor * 0.5)
	var/ki_damage = getKiCombatDamage(target, factor * 0.5)
	return physical_damage + ki_damage

datum/CombatDamageBudget
	var/max_factor_per_target = 0
	var/list/used_factor_by_target = list()

	New(max_factor = 0)
		max_factor_per_target = max(0, max_factor)

	proc/reserveFactor(mob/target, requested_factor = 0)
		if(!target || requested_factor <= 0) return 0
		if(max_factor_per_target <= 0) return requested_factor
		var/used_factor = used_factor_by_target[target]
		var/remaining_factor = max_factor_per_target - used_factor
		if(remaining_factor <= 0) return 0
		var/reserved_factor = min(requested_factor, remaining_factor)
		used_factor_by_target[target] = used_factor + reserved_factor
		return reserved_factor
