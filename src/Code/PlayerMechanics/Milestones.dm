datum/MilestoneDefinition
	var
		id
		name
		description
		cost = 1
		max_rank = 1
		branch = "General"
		tier = 1
		list/prerequisites = list()
		exclusive_group

	New(new_id, new_name, new_description, new_cost = 1, new_max_rank = 1, new_branch = "General", new_tier = 1, list/new_prerequisites = null, new_exclusive_group = null)
		id = new_id
		name = new_name
		description = new_description
		cost = new_cost
		max_rank = new_max_rank
		branch = new_branch
		tier = max(1, round(new_tier))
		if(islist(new_prerequisites)) prerequisites = new_prerequisites.Copy()
		exclusive_group = new_exclusive_group

var/list/milestone_catalog

proc/initializeMilestoneCatalog()
	if(islist(milestone_catalog) && milestone_catalog.len) return
	milestone_catalog = list()
	milestone_catalog["iron_will"] = new /datum/MilestoneDefinition("iron_will", "Iron Will", "+10 maximum Willpower per rank.", 1, 3, "Resolve", 1)
	milestone_catalog["will_of_fire"] = new /datum/MilestoneDefinition("will_of_fire", "Will of Fire", "Reduces Willpower lost to lethal knockouts by 5 per rank.", 2, 2, "Resolve", 2, list("iron_will"))
	milestone_catalog["steadfast_spirit"] = new /datum/MilestoneDefinition("steadfast_spirit", "Steadfast Spirit", "Recovers Willpower outside lethal combat 15% faster per rank.", 2, 2, "Resolve", 2, list("iron_will"))
	milestone_catalog["rapid_recovery"] = new /datum/MilestoneDefinition("rapid_recovery", "Rapid Recovery", "Reduces knockout recovery time by 10% per rank.", 2, 2, "Resolve", 3, list("steadfast_spirit"))
	milestone_catalog["rapid_deployment"] = new /datum/MilestoneDefinition("rapid_deployment", "Rapid Deployment", "Reduces lethal combat pressure duration by 25% per rank.", 3, 2, "Resolve", 3, list("will_of_fire"))

	milestone_catalog["controlled_fury"] = new /datum/MilestoneDefinition("controlled_fury", "Controlled Fury", "Builds anger 15% faster from damage per rank.", 2, 2, "Combat", 1)

	// Nexus combat milestones, adapted to Nexus' authoritative combat paths.
	milestone_catalog["unarmed_mastery"] = new /datum/MilestoneDefinition("unarmed_mastery", "Unarmed Mastery", "+2.5% unarmed melee damage per rank.", 1, 2, "Martial Arts", 1)
	milestone_catalog["deft_hands"] = new /datum/MilestoneDefinition("deft_hands", "Deft Hands", "+2.5% flat melee accuracy per rank.", 2, 4, "Martial Arts", 2, list("unarmed_mastery"))
	milestone_catalog["one_two_punch"] = new /datum/MilestoneDefinition("one_two_punch", "One-Two Punch", "Reduces melee attack delay by 10% per rank, to a maximum of 40%.", 2, 4, "Martial Arts", 3, list("deft_hands"))
	milestone_catalog["burning_fists"] = new /datum/MilestoneDefinition("burning_fists", "Burning Fists / Fire Fist", "Unlocks the Fire Fist stance: +20% melee damage and a 40% chance to burn on hit while draining Energy.", 4, 1, "Martial Arts", 4, list("one_two_punch"))
	milestone_catalog["way_of_the_fist"] = new /datum/MilestoneDefinition("way_of_the_fist", "Way of the Fist", "+10% unarmed melee damage.", 5, 1, "Martial Arts", 4, list("one_two_punch"))
	milestone_catalog["way_of_the_open_palm"] = new /datum/MilestoneDefinition("way_of_the_open_palm", "Way of the Open Palm", "Reduces unarmed melee attack delay by a further 10%.", 8, 1, "Martial Arts", 5, list("way_of_the_fist"))

	milestone_catalog["weapon_training"] = new /datum/MilestoneDefinition("weapon_training", "Weapon Training", "+2.5% weapon melee damage per rank.", 1, 2, "Weapon", 1)
	milestone_catalog["swordsman"] = new /datum/MilestoneDefinition("swordsman", "Swordsman", "+8% melee damage while wielding a weapon.", 3, 1, "Weapon", 2, list("weapon_training"))
	milestone_catalog["bleeding_edge"] = new /datum/MilestoneDefinition("bleeding_edge", "Bleeding Edge", "Unlocks a focused weapon stance with a 50% chance to add a 12.5% bleed, at the cost of 10% attack speed.", 4, 1, "Weapon", 3, list("swordsman"))
	milestone_catalog["thundering_blows"] = new /datum/MilestoneDefinition("thundering_blows", "Thundering Blows", "Unlocks a weapon stance with a 50% chance to deal a 10% aftershock and briefly stagger, at the cost of 10% attack speed.", 4, 1, "Weapon", 3, list("swordsman"))
	milestone_catalog["exploit_weakness"] = new /datum/MilestoneDefinition("exploit_weakness", "Exploit Weakness", "+10% damage and +25% flat melee accuracy when attacking from behind.", 4, 1, "Weapon", 4, list("bleeding_edge"))

	milestone_catalog["ki_manipulation"] = new /datum/MilestoneDefinition("ki_manipulation", "Ki Manipulation", "+3% ki attack damage per rank.", 1, 2, "Ki", 1)
	milestone_catalog["bulls_eye"] = new /datum/MilestoneDefinition("bulls_eye", "Bull's Eye", "+3% flat projectile accuracy per rank.", 1, 4, "Ki", 2, list("ki_manipulation"))
	milestone_catalog["energy_marksmanship"] = new /datum/MilestoneDefinition("energy_marksmanship", "Energy Marksmanship", "+10% projectile accuracy, +5% homing and a 30% chance to bypass Precognition.", 4, 1, "Ki", 3, list("bulls_eye"))
	milestone_catalog["forceful_negotiator"] = new /datum/MilestoneDefinition("forceful_negotiator", "Forceful Negotiator", "+13% ki attack damage.", 6, 1, "Ki", 3, list("bulls_eye"))
	milestone_catalog["concentrated_fire"] = new /datum/MilestoneDefinition("concentrated_fire", "Concentrated Fire", "+10% damage against your selected target, but -5% against everyone else.", 5, 1, "Ki", 4, list("energy_marksmanship"))
	milestone_catalog["this_drill_will_pierce_the_heavens"] = new /datum/MilestoneDefinition("this_drill_will_pierce_the_heavens", "This Drill Will Pierce the Heavens", "All scaled attacks ignore 10% of the opponent's Endurance or Resistance.", 8, 1, "Ki", 5, list("concentrated_fire"))

	milestone_catalog["turtle_shell"] = new /datum/MilestoneDefinition("turtle_shell", "Turtle Shell", "Reduces damage received from behind by 10% per rank.", 1, 2, "Survival", 1)
	milestone_catalog["sturdy_build"] = new /datum/MilestoneDefinition("sturdy_build", "Sturdy Build", "Reduces all incoming damage by 3% per rank.", 2, 2, "Survival", 2, list("turtle_shell"))
	milestone_catalog["desperate_struggle"] = new /datum/MilestoneDefinition("desperate_struggle", "Desperate Struggle", "+20% damage while below 50 Willpower.", 3, 1, "Survival", 3, list("sturdy_build"))
	milestone_catalog["challengers_mark"] = new /datum/MilestoneDefinition("challengers_mark", "Challenger's Mark", "Take 15% less damage from your selected target, but 5% more from other attackers.", 6, 1, "Survival", 4, list("desperate_struggle"))
	milestone_catalog["venomous_intent"] = new /datum/MilestoneDefinition("venomous_intent", "Venomous Intent", "Unlocks a stance whose damaging hits have a 25% chance to poison for 12% maximum Health over twelve seconds.", 6, 1, "Survival", 4, list("sturdy_build"))
	milestone_catalog["crushing_resolve"] = new /datum/MilestoneDefinition("crushing_resolve", "Crushing Resolve", "Unlocks a lethal-only stance whose damaging hits can spend 1 Willpower to drain 2 Willpower, with a five-second internal cooldown.", 6, 1, "Resolve", 4, list("will_of_fire"))

	milestone_catalog["salt_of_the_earth"] = new /datum/MilestoneDefinition("salt_of_the_earth", "Salt of the Earth", "Doubles Anger gained from damage.", 3, 1, "Fire", 2, list("controlled_fury"))
	milestone_catalog["fire_lord"] = new /datum/MilestoneDefinition("fire_lord", "Fire Lord", "Fire attacks deal 5% more damage per Burn stack on the target, up to 25%.", 3, 1, "Fire", 3, list("salt_of_the_earth"))
	milestone_catalog["smolder"] = new /datum/MilestoneDefinition("smolder", "Smolder", "Projectile hits have a 35% chance to add a burning stack, up to five active stacks.", 6, 1, "Fire", 4, list("fire_lord"))
	milestone_catalog["roleplay_scholar"] = new /datum/MilestoneDefinition("roleplay_scholar", "Roleplay Scholar", "Gains 10% more Progression XP from qualified roleplay sessions per rank.", 2, 3, "Growth", 1)
	milestone_catalog["patient_growth"] = new /datum/MilestoneDefinition("patient_growth", "Patient Growth", "Improves the online/offline hourly Progression XP rate as though its earning interval were 10% shorter per rank.", 2, 3, "Growth", 2, list("roleplay_scholar"))
	milestone_catalog["arcane_memory"] = new /datum/MilestoneDefinition("arcane_memory", "Arcane Memory", "Gains 10% more Magic XP per rank.", 2, 3, "Growth", 2, list("roleplay_scholar"))
	milestone_catalog["language_savant"] = new /datum/MilestoneDefinition("language_savant", "Language Savant", "Learns languages through exposure and lessons 25% faster per rank.", 2, 3, "Culture", 1)
	milestone_catalog["custom_language"] = new /datum/MilestoneDefinition("custom_language", "Custom Language", "Create one persistent custom language that can be taught to other characters.", 3, 1, "Culture", 3, list("language_savant"))

	milestone_catalog["scientific_method"] = new /datum/MilestoneDefinition("scientific_method", "Scientific Method", "Gains 10% more Technology XP per rank.", 2, 3, "Scholarship", 1)
	milestone_catalog["liberal_arts"] = new /datum/MilestoneDefinition("liberal_arts", "Liberal Arts Degree", "Converts 25% of Mining and Smithing XP into Technology XP.", 1, 1, "Scholarship", 2, list("scientific_method"))
	milestone_catalog["profession_specialist"] = new /datum/MilestoneDefinition("profession_specialist", "Profession Specialist", "Gains 10% more Mining and Smithing XP per rank.", 2, 3, "Craft", 1)
	milestone_catalog["mining_expert"] = new /datum/MilestoneDefinition("mining_expert", "Mining Expert", "Increases natural mining yield by 50% and improves ore discovery.", 3, 1, "Craft", 2, list("profession_specialist"))
	milestone_catalog["ore_whisperer"] = new /datum/MilestoneDefinition("ore_whisperer", "Ore Whisperer", "Increases natural ore discovery chance by 15% per rank.", 2, 2, "Craft", 3, list("mining_expert"))
	milestone_catalog["master_blacksmith"] = new /datum/MilestoneDefinition("master_blacksmith", "Master Blacksmith", "Forged equipment gains 5% quality and recipes consume one less ore.", 4, 1, "Craft", 3, list("mining_expert"))

	// Build-enabling milestones are intentionally shown in the same uncategorized Milestone list.
	milestone_catalog["versatile_training"] = new /datum/MilestoneDefinition("versatile_training", "Versatile Training", "+2% Strength, Endurance, Force, Resistance, Offense, Defense and Speed per rank.", 2, 3, "Builds", 1)
	milestone_catalog["momentum_damage"] = new /datum/MilestoneDefinition("momentum_damage", "Momentum Damage", "Adds 25% of Speed to both physical and ki source-stat damage calculations.", 4, 1, "Builds", 2, null, "secondary_damage_stat")
	milestone_catalog["precision_damage"] = new /datum/MilestoneDefinition("precision_damage", "Precision Damage", "Adds 25% of Offense to both physical and ki source-stat damage calculations.", 4, 1, "Builds", 2, null, "secondary_damage_stat")
	milestone_catalog["fortified_damage"] = new /datum/MilestoneDefinition("fortified_damage", "Fortified Damage", "Adds 20% of Endurance to physical damage and 20% of Resistance to ki damage.", 4, 1, "Builds", 2, null, "secondary_damage_stat")
	milestone_catalog["sweeping_impact"] = new /datum/MilestoneDefinition("sweeping_impact", "Sweeping Impact", "Ordinary melee hits deal 35% splash damage to up to eight enemies within three tiles of the target.", 5, 1, "Builds", 3)
	milestone_catalog["echoing_assault"] = new /datum/MilestoneDefinition("echoing_assault", "Echoing Assault", "Ordinary melee hits have an 8% chance per rank to strike the primary target again for 60% damage.", 3, 2, "Builds", 3)
	milestone_catalog["keen_edge"] = new /datum/MilestoneDefinition("keen_edge", "Keen Edge", "+3 percentage points of critical-hit chance per rank.", 2, 3, "Builds", 2)
	milestone_catalog["unencumbered_combatant"] = new /datum/MilestoneDefinition("unencumbered_combatant", "Unencumbered Combatant", "+15% effective Offense and Defense while no weapon or armor is equipped.", 5, 1, "Builds", 3)
	for(var/milestone_id in milestone_catalog)
		var/datum/MilestoneDefinition/milestone = milestone_catalog[milestone_id]
		milestone.prerequisites = list()

mob/var
	milestone_points = 0
	total_milestone_points = 0
	list/milestones_owned = list()
	milestone_last_year = -1
	milestone_progression_version = 0
	tmp/milestone_bleeding_edge_active = FALSE
	tmp/milestone_thundering_blows_active = FALSE
	tmp/milestone_venomous_intent_active = FALSE
	tmp/milestone_crushing_resolve_active = FALSE
	tmp/milestone_next_poison_proc = 0
	tmp/milestone_next_willpower_proc = 0

mob/proc/getMilestoneRank(milestone_id)
	if(!islist(milestones_owned)) milestones_owned = list()
	var/rank = milestones_owned[milestone_id]
	if(!isnum(rank)) rank = 0
	return max(0, rank)

mob/proc/normalizeMilestonePointBalances()
	var/normalized_points = nexusIsFiniteNumber(milestone_points) ? max(0, round(milestone_points)) : 0
	var/normalized_total = nexusIsFiniteNumber(total_milestone_points) ? max(0, round(total_milestone_points)) : 0
	normalized_total = Clamp(max(normalized_total, normalized_points), 0, NEXUS_MILESTONE_POINT_CAP)
	milestone_points = Clamp(normalized_points, 0, normalized_total)
	total_milestone_points = normalized_total

mob/proc/grantMilestonePoints(amount, reason = "character growth", announce = FALSE)
	normalizeMilestonePointBalances()
	if(!nexusIsFiniteNumber(amount) || amount <= 0) return 0
	var/available_points = max(0, NEXUS_MILESTONE_POINT_CAP - total_milestone_points)
	var/granted = min(max(0, round(amount)), available_points)
	if(granted <= 0)
		if(announce) src << "You have reached the lifetime cap of [NEXUS_MILESTONE_POINT_CAP] Milestone Points."
		return 0
	milestone_points += granted
	total_milestone_points += granted
	if(announce) src << "You received [granted] Milestone Point[granted == 1 ? "" : "s"] from [reason]."
	return granted

mob/proc/getMilestoneLockReason(datum/MilestoneDefinition/milestone)
	if(!milestone) return "Unknown milestone."
	if(getMilestoneRank(milestone.id) >= milestone.max_rank) return null
	if(milestone.exclusive_group)
		for(var/other_id in milestone_catalog)
			var/datum/MilestoneDefinition/other = milestone_catalog[other_id]
			if(other.id != milestone.id && other.exclusive_group == milestone.exclusive_group && getMilestoneRank(other.id))
				return "Exclusive with [other.name]."
	if(milestone_points < milestone.cost) return "Requires [milestone.cost] Milestone Points."
	return null

mob/proc/syncMilestoneProgression(silent = FALSE)
	if(islist(milestones_owned))
		for(var/owned_id in milestones_owned)
			if(findtext("[owned_id]", "ub_") == 1 && getMilestoneRank(owned_id) > 0) migrateLegacyUltimateBuffMilestone(owned_id)
	ensureMilestoneCombatRewards()
	if(milestone_progression_version < 1)
		var/starting_points = grantMilestonePoints(MILESTONE_STARTING_POINTS, "starting progression", announce = FALSE)
		milestone_last_year = floor(max(0, Year))
		milestone_progression_version = 1
		if(!silent && starting_points) src << "You received [starting_points] starting Milestone Points."
		return
	var/current_year = floor(max(0, Year))
	if(milestone_last_year < 0)
		milestone_last_year = current_year
		return
	if(current_year <= milestone_last_year) return
	var/elapsed_years = current_year - milestone_last_year
	milestone_last_year = current_year
	var/earned = grantMilestonePoints(elapsed_years, "character growth", announce = FALSE)
	if(!silent && earned) src << "You earned [earned] Milestone Point[earned == 1 ? "" : "s"] through character growth."

mob/proc/purchaseMilestone(milestone_id)
	initializeMilestoneCatalog()
	var/datum/MilestoneDefinition/milestone = milestone_catalog[milestone_id]
	if(!milestone) return FALSE
	var/current_rank = getMilestoneRank(milestone_id)
	if(current_rank >= milestone.max_rank)
		src << "[milestone.name] is already at its maximum rank."
		return FALSE
	var/lock_reason = getMilestoneLockReason(milestone)
	if(lock_reason)
		src << lock_reason
		return FALSE
	milestone_points -= milestone.cost
	milestones_owned[milestone_id] = current_rank + 1
	if(milestone_id == "iron_will") restoreWillpower(10, "Iron Will strengthens your resolve.", announce = FALSE)
	ensureMilestoneCombatRewards()
	src << "<font color=#ffff80>Purchased [milestone.name] rank [current_rank + 1]/[milestone.max_rank]."
	return TRUE

mob/proc/ensureMilestoneCombatRewards()
	if(getMilestoneRank("burning_fists") && !(locate(/obj/FireFist) in src)) contents += new /obj/FireFist(src)
	if(getMilestoneRank("bleeding_edge") && !(locate(/obj/MilestoneTechnique/BleedingEdge) in src)) contents += new /obj/MilestoneTechnique/BleedingEdge(src)
	if(getMilestoneRank("thundering_blows") && !(locate(/obj/MilestoneTechnique/ThunderingBlows) in src)) contents += new /obj/MilestoneTechnique/ThunderingBlows(src)
	if(getMilestoneRank("venomous_intent") && !(locate(/obj/MilestoneTechnique/VenomousIntent) in src)) contents += new /obj/MilestoneTechnique/VenomousIntent(src)
	if(getMilestoneRank("crushing_resolve") && !(locate(/obj/MilestoneTechnique/CrushingResolve) in src)) contents += new /obj/MilestoneTechnique/CrushingResolve(src)

mob/proc/getMilestoneMeleeDamageMultiplier(mob/target, has_weapon = FALSE)
	var/multiplier = 1
	if(has_weapon)
		multiplier *= 1 + getMilestoneRank("weapon_training") * 0.025
		if(getMilestoneRank("swordsman")) multiplier *= 1.08
	else
		multiplier *= 1 + getMilestoneRank("unarmed_mastery") * 0.025
		if(getMilestoneRank("way_of_the_fist")) multiplier *= 1.1
	if(target && getMilestoneRank("exploit_weakness") && target.dir == dir) multiplier *= 1.1
	return multiplier

mob/proc/getMilestoneMeleeDelayMultiplier(has_weapon = FALSE)
	var/multiplier = max(0.6, 1 - getMilestoneRank("one_two_punch") * 0.1)
	if(!has_weapon && getMilestoneRank("way_of_the_open_palm")) multiplier *= 0.9
	if(has_weapon && milestone_bleeding_edge_active) multiplier *= 1.1
	if(has_weapon && milestone_thundering_blows_active) multiplier *= 1.1
	return multiplier

mob/proc/getMilestoneMeleeAccuracyBonus(mob/target)
	var/bonus = getMilestoneRank("deft_hands") * 2.5
	if(target && getMilestoneRank("exploit_weakness") && target.dir == dir) bonus += 25
	return bonus

mob/proc/getMilestoneProjectileAccuracyBonus()
	var/bonus = getMilestoneRank("bulls_eye") * 3
	if(getMilestoneRank("energy_marksmanship")) bonus += 10
	return bonus

mob/proc/getMilestoneProjectileHomingBonus()
	return getMilestoneRank("energy_marksmanship") ? 5 : 0

mob/proc/getMilestoneKiDamageMultiplier()
	var/multiplier = 1 + getMilestoneRank("ki_manipulation") * 0.03
	if(getMilestoneRank("forceful_negotiator")) multiplier *= 1.13
	return multiplier

mob/proc/getMilestoneGuardMultiplier()
	return getMilestoneRank("this_drill_will_pierce_the_heavens") ? 0.9 : 1

mob/proc/getMilestoneAllStatsMultiplier()
	return 1 + getMilestoneRank("versatile_training") * 0.02

mob/proc/getMilestoneScaledCombatStat(stat_value)
	return max(0, stat_value) * getMilestoneAllStatsMultiplier()

mob/proc/getMilestonePhysicalDamageStat()
	var/source_stat = Swordless_strength()
	if(getMilestoneRank("momentum_damage")) source_stat += Spd * 0.25
	else if(getMilestoneRank("precision_damage")) source_stat += Off * 0.25
	else if(getMilestoneRank("fortified_damage")) source_stat += End * 0.2
	return getMilestoneScaledCombatStat(source_stat) * getNexusStanceStrengthMultiplier()

mob/proc/getMilestoneKiDamageStat()
	var/source_stat = Pow
	if(getMilestoneRank("momentum_damage")) source_stat += Spd * 0.25
	else if(getMilestoneRank("precision_damage")) source_stat += Off * 0.25
	else if(getMilestoneRank("fortified_damage")) source_stat += Res * 0.2
	return getMilestoneScaledCombatStat(source_stat) * getNexusStanceForceMultiplier()

mob/proc/isMilestoneUnencumbered()
	if(!getMilestoneRank("unencumbered_combatant")) return FALSE
	if(usingMeleeWeapon()) return FALSE
	for(var/obj/items/Gun/gun in src)
		if(gun.Equipped) return FALSE
	if(armor_obj && armor_obj.loc == src && armor_obj.suffix) return FALSE
	return TRUE

mob/proc/getMilestoneEffectiveOffense()
	var/effective_offense = getMilestoneScaledCombatStat(Off)
	if(isMilestoneUnencumbered()) effective_offense *= 1.15
	effective_offense *= getNexusElectricStatMultiplier()
	effective_offense *= getNexusSandThrowStatMultiplier()
	return effective_offense

mob/proc/getMilestoneEffectiveDefense()
	var/effective_defense = getMilestoneScaledCombatStat(Def)
	if(isMilestoneUnencumbered()) effective_defense *= 1.15
	effective_defense *= getNexusStanceDefenseMultiplier()
	effective_defense *= getNexusElectricStatMultiplier()
	effective_defense *= getNexusSandThrowStatMultiplier()
	effective_defense *= getNexusGuardBreakDefenseMultiplier()
	return effective_defense

mob/proc/getMilestoneEffectiveSpeed()
	return getMilestoneScaledCombatStat(Spd) * getNexusElectricStatMultiplier() * getNexusWingClipSpeedMultiplier()

mob/proc/getMilestoneCriticalChanceBonus()
	return getMilestoneRank("keen_edge") * 3

mob/proc/getMilestoneMeleeAreaRadius()
	return getMilestoneRank("sweeping_impact") ? 3 : 0

mob/proc/getMilestoneDoubleAttackChance()
	return getMilestoneRank("echoing_assault") * 8

mob/proc/isMilestoneFireAttack(attack_name)
	if(!attack_name) return FALSE
	var/lower_name = lowertext("[attack_name]")
	return findtext(lower_name, "fire") || findtext(lower_name, "flame") || findtext(lower_name, "burn")

mob/proc/getMilestoneFireLordBonus(mob/target, attack_name)
	if(!target || !getMilestoneRank("fire_lord") || !isMilestoneFireAttack(attack_name)) return 0
	return min(0.25, max(0, target.BurnStack) * 0.05)

mob/proc/getMilestoneOutgoingDamageMultiplier(mob/target, attack_name)
	var/multiplier = 1
	if(getMilestoneRank("desperate_struggle") && willpower < 50) multiplier *= 1.2
	var/fire_lord_bonus = getMilestoneFireLordBonus(target, attack_name)
	if(fire_lord_bonus) multiplier *= 1 + fire_lord_bonus
	if(target && getMilestoneRank("concentrated_fire"))
		var/mob/selected_target = getSelectedTarget(require_view = FALSE)
		multiplier *= selected_target == target ? 1.1 : 0.95
	return multiplier

mob/proc/getMilestoneIncomingDamageMultiplier(mob/attacker)
	var/multiplier = 1 - getMilestoneRank("sturdy_build") * 0.03
	if(attacker && getMilestoneRank("turtle_shell") && attacker.dir == dir)
		multiplier *= 1 - getMilestoneRank("turtle_shell") * 0.1
	if(attacker && getMilestoneRank("challengers_mark"))
		var/mob/selected_target = getSelectedTarget(require_view = FALSE)
		multiplier *= selected_target == attacker ? 0.85 : 1.05
	return max(0.1, multiplier)

mob/proc/tryApplyMilestoneProjectileEffects(mob/target)
	if(!target) return FALSE
	var/applied = tryApplyMilestoneHitStances(target)
	if(getMilestoneRank("smolder") && target.BurnStack < 5 && prob(35))
		target.BurnStack++
		if(!target.isBurning)
			target.isBurning = TRUE
			target.try_applying_burn_effect()
		applied = TRUE
	return applied

mob/proc/tryApplyMilestoneHitStances(mob/target)
	if(!target || target.KO || target.rp_mode || target.Safezone) return FALSE
	var/applied = FALSE
	if(milestone_venomous_intent_active && getMilestoneRank("venomous_intent") && world.time >= milestone_next_poison_proc && prob(25))
		if(target.applyNexusPoisonDot(src, 120, 2))
			milestone_next_poison_proc = world.time + 20
			applied = TRUE
	if(milestone_crushing_resolve_active && getMilestoneRank("crushing_resolve") && sparring_mode == LETHAL_COMBAT && target.sparring_mode == LETHAL_COMBAT && world.time >= milestone_next_willpower_proc && prob(25))
		if(tryDrainTechniqueWillpower(1, "Crushing Resolve", 1))
			target.drainWillpower(2, "[src]'s Crushing Resolve attacks your will.")
			milestone_next_willpower_proc = world.time + 50
			applied = TRUE
	return applied

mob/proc/applyMilestoneMeleeAreaDamage(mob/primary_target, damage, attack_name)
	var/radius = getMilestoneMeleeAreaRadius()
	if(!primary_target || radius <= 0 || damage <= 0) return 0
	var/hit_count = 0
	for(var/mob/area_target in view(radius, primary_target))
		if(hit_count >= 8) break
		if(area_target == primary_target || !canHitNexusTechniqueTarget(area_target)) continue
		if(area_target.AOE_auto_dodge(src, primary_target.loc)) continue
		area_target.TakeDamage(damage * 0.35, attacker = src, attack_name = "Sweeping Impact ([attack_name])")
		hit_count++
	return hit_count

mob/proc/tryApplyMilestoneDoubleAttack(mob/primary_target, damage, attack_name)
	if(!primary_target || damage <= 0 || !prob(getMilestoneDoubleAttackChance())) return FALSE
	if(!canHitNexusTechniqueTarget(primary_target)) return FALSE
	var/double_attack_sound = using_sword() ? pick(nexus_sword_impact_sounds) : 'Mediumpunch.ogg'
	Play_Melee_Sound(sound_range = 10, origin = primary_target, sound_file = double_attack_sound, sound_volume = 25)
	primary_target.TakeDamage(damage * 0.6, attacker = src, attack_name = "Echoing Assault ([attack_name])")
	return TRUE

obj/MilestoneTechnique
	Skill = 1
	teachable = 0
	can_hotbar = 1
	hotbar_type = "Buff"

	BleedingEdge
		name = "Bleeding Edge (Milestone)"
		desc = "Toggle the integrated Bleeding Edge weapon stance. Weapon strikes can inflict an additional bleed, but attack 10% slower."

		verb/Hotbar_use()
			set hidden = 1
			toggle(usr)

		verb/Toggle_Bleeding_Edge()
			set name = "Toggle Bleeding Edge"
			set category = "Skills"
			toggle(usr)

		proc/toggle(mob/user)
			if(!user || !user.getMilestoneRank("bleeding_edge")) return
			user.milestone_bleeding_edge_active = !user.milestone_bleeding_edge_active
			player_view(10, user) << sound('src/Sound/SoundEffects/Combat/Weapons/SwordImpact4.ogg', volume = 35)
			user << (user.milestone_bleeding_edge_active ? "You focus on the Bleeding Edge." : "You release your Bleeding Edge focus.")

	ThunderingBlows
		name = "Thundering Blows (Milestone)"
		desc = "Toggle the integrated Thundering Blows weapon stance. Weapon strikes can create a damaging stagger, but attack 10% slower."

		verb/Hotbar_use()
			set hidden = 1
			toggle(usr)

		verb/Toggle_Thundering_Blows()
			set name = "Toggle Thundering Blows"
			set category = "Skills"
			toggle(usr)

		proc/toggle(mob/user)
			if(!user || !user.getMilestoneRank("thundering_blows")) return
			user.milestone_thundering_blows_active = !user.milestone_thundering_blows_active
			player_view(10, user) << sound('Kiplosion.ogg', volume = 30)
			user << (user.milestone_thundering_blows_active ? "Thunder gathers around your weapon." : "Your weapon falls silent.")

	VenomousIntent
		name = "Venomous Intent (Milestone)"
		desc = "Toggle a stance with a 25% chance on damaging hits to inflict a twelve-second poison based on maximum Health."

		verb/Hotbar_use()
			set hidden = 1
			toggle(usr)

		verb/Toggle_Venomous_Intent()
			set name = "Toggle Venomous Intent"
			set category = "Skills"
			toggle(usr)

		proc/toggle(mob/user)
			if(!user || !user.getMilestoneRank("venomous_intent")) return
			user.milestone_venomous_intent_active = !user.milestone_venomous_intent_active
			user << (user.milestone_venomous_intent_active ? "Your attacks carry Venomous Intent." : "You release your Venomous Intent.")

	CrushingResolve
		name = "Crushing Resolve (Milestone)"
		desc = "Toggle a lethal-only stance. Damaging hits have a 25% chance to spend 1 Willpower and drain 2 from the target, at most once every five seconds."

		verb/Hotbar_use()
			set hidden = 1
			toggle(usr)

		verb/Toggle_Crushing_Resolve()
			set name = "Toggle Crushing Resolve"
			set category = "Skills"
			toggle(usr)

		proc/toggle(mob/user)
			if(!user || !user.getMilestoneRank("crushing_resolve")) return
			user.milestone_crushing_resolve_active = !user.milestone_crushing_resolve_active
			user << (user.milestone_crushing_resolve_active ? "You focus on crushing hostile resolve." : "You stop attacking your opponents' resolve.")

mob/proc/getLegacyUltimateBuffType(milestone_id)
	var/buff_type
	switch(milestone_id)
		if("ub_high_tension") buff_type = /obj/Buff/Ultimate/HighTension
		if("ub_godspeed") buff_type = /obj/Buff/Ultimate/Godspeed
		if("ub_fists_of_fury") buff_type = /obj/Buff/Ultimate/FistsOfFury
		if("ub_arcane_power") buff_type = /obj/Buff/Ultimate/ArcanePower
		if("ub_bestial_wrath") buff_type = /obj/Buff/Ultimate/BestialWrath
		if("ub_bushido") buff_type = /obj/Buff/Ultimate/Bushido
	return buff_type

mob/proc/migrateLegacyUltimateBuffMilestone(milestone_id)
	var/buff_type = getLegacyUltimateBuffType(milestone_id)
	if(!buff_type) return FALSE
	initializeProgressionTreeCatalog()
	var/node_id = getProgressionNodeIdForReward(buff_type)
	if(node_id)
		if(!islist(progression_nodes_owned)) progression_nodes_owned = list()
		progression_nodes_owned[node_id] = max(1, getProgressionNodeRank(node_id))
	if(!(locate(buff_type) in src)) contents += new buff_type(src)
	return TRUE

mob/verb/milestones()
	set name = "Milestones"
	set category = "Other"
	showProgressionTrees("Milestones")
