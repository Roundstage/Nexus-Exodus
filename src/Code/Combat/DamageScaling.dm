#define COMBAT_DAMAGE_PHYSICAL 1
#define COMBAT_DAMAGE_KI 2

var
	combat_damage_bp_exponent = 1
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
	var/guard_stat = target.getMilestoneScaledCombatStat(target.End) * getMilestoneGuardMultiplier()
	return calculateScaledCombatDamage(factor, getForgedUnarmedAttackBP(), target.getForgedArmorEnduranceBP(), getMilestonePhysicalDamageStat(), guard_stat)

mob/proc/getUnresistedPhysicalCombatDamage(factor = 0)
	return calculateScaledCombatDamage(factor, getForgedUnarmedAttackBP(), max(BP, 0.01), getMilestonePhysicalDamageStat(), 0)

mob/proc/getWeaponCombatSourceStat(obj/items/Sword/weapon)
	if(weapon && weapon.Style == "Energy") return (getMilestonePhysicalDamageStat() * 0.5) + (getMilestoneKiDamageStat() * 0.5)
	return getMilestonePhysicalDamageStat()

mob/proc/getSwordCombatDamageMultiplier(obj/items/Sword/weapon, mob/target, sword_modifier = 1)
	if(!weapon) return 1
	var/damage_multiplier = 1 + ((weapon.Damage - 1) * sword_damage_mod * sword_modifier)
	if(weapon.is_silver)
		if(target && (target.Vampire || istype(target, /mob/Enemy/Zombie))) damage_multiplier *= silver_sword_damage_mult
		else damage_multiplier *= silver_sword_damage_penalty
	if(weapon.Style == "Energy") damage_multiplier *= energy_sword_damage_mod
	return damage_multiplier

mob/proc/getWeaponCombatDamage(mob/target, factor = 0)
	if(!target || factor <= 0) return 0
	var/obj/KiWeaponTechnique/ki_weapon = usingKiWeapon()
	if(ki_weapon && ki_weapon.counts_as_weapon)
		var/ki_guard_stat = target.getMilestoneScaledCombatStat(ki_weapon.uses_energy_defense ? target.Res : target.End) * getMilestoneGuardMultiplier()
		var/ki_weapon_damage = calculateScaledCombatDamage(factor, getKiWeaponCombatBP(), target.getForgedArmorEnduranceBP(), getKiWeaponSourceStat(ki_weapon), ki_guard_stat)
		return ki_weapon_damage * getKiWeaponEnergyMultiplier(ki_weapon) * getMilestoneMeleeDamageMultiplier(target, TRUE)
	var/obj/items/Sword/weapon = using_sword()
	if(!weapon) return getPhysicalCombatDamage(target, factor)
	var/guard_stat = target.getMilestoneScaledCombatStat(target.End) * getMilestoneGuardMultiplier()
	var/source_stat = getWeaponCombatSourceStat(weapon)
	var/sword_modifier = Class == "Legendary Saiyan" ? 0.4 : 1
	if(weapon.Style == "Energy")
		guard_stat = target.getMilestoneScaledCombatStat(target.Res) * getMilestoneGuardMultiplier()
	var/damage = calculateScaledCombatDamage(factor, getForgedWeaponAttackBP(), target.getForgedArmorEnduranceBP(), source_stat, guard_stat)
	damage *= getSwordCombatDamageMultiplier(weapon, target, sword_modifier)
	damage *= getMilestoneMeleeDamageMultiplier(target, TRUE)
	return damage

mob/proc/getUnresistedWeaponCombatDamage(factor = 0)
	if(factor <= 0) return 0
	var/obj/KiWeaponTechnique/ki_weapon = usingKiWeapon()
	if(ki_weapon && ki_weapon.counts_as_weapon)
		var/ki_weapon_damage = calculateScaledCombatDamage(factor, getKiWeaponCombatBP(), max(BP, 0.01), getKiWeaponSourceStat(ki_weapon), 0)
		return ki_weapon_damage * getKiWeaponEnergyMultiplier(ki_weapon) * getMilestoneMeleeDamageMultiplier(null, TRUE)
	var/obj/items/Sword/weapon = using_sword()
	if(!weapon) return getUnresistedPhysicalCombatDamage(factor)
	var/sword_modifier = Class == "Legendary Saiyan" ? 0.4 : 1
	var/damage = calculateScaledCombatDamage(factor, getForgedWeaponAttackBP(), max(BP, 0.01), getWeaponCombatSourceStat(weapon), 0)
	damage *= getSwordCombatDamageMultiplier(weapon, null, sword_modifier)
	damage *= getMilestoneMeleeDamageMultiplier(null, TRUE)
	return damage

mob/proc/getKiCombatDamage(mob/target, factor = 0)
	if(!target) return 0
	var/guard_stat = target.getMilestoneScaledCombatStat(target.Res) * getMilestoneGuardMultiplier()
	return calculateScaledCombatDamage(factor, getForgedKiAttackBP(), target.BP, getMilestoneKiDamageStat(), guard_stat) * getMilestoneKiDamageMultiplier() * getForgedKiDamageMultiplier()

mob/proc/getUnresistedKiCombatDamage(factor = 0)
	return calculateScaledCombatDamage(factor, getForgedKiAttackBP(), max(BP, 0.01), getMilestoneKiDamageStat(), 0) * getMilestoneKiDamageMultiplier() * getForgedKiDamageMultiplier()

mob/proc/getUnresistedKiProjectileCombatDamage(factor = 0)
	return calculateScaledCombatDamage(factor, getForgedKiAttackBP(), max(BP, 0.01), getMilestoneKiDamageStat(), 0) * getMilestoneKiDamageMultiplier()

mob/proc/getHybridCombatDamage(mob/target, factor = 0)
	if(!target || factor <= 0) return 0
	var/physical_damage = getPhysicalCombatDamage(target, factor * 0.5)
	var/ki_damage = getKiCombatDamage(target, factor * 0.5)
	return physical_damage + ki_damage

mob/proc/getUnresistedHybridCombatDamage(factor = 0)
	if(factor <= 0) return 0
	return getUnresistedPhysicalCombatDamage(factor * 0.5) + getUnresistedKiCombatDamage(factor * 0.5)

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
