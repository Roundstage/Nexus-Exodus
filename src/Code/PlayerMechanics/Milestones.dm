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

	// Roleplay Tenkaichi combat milestones, adapted to Nexus' authoritative combat paths.
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

	milestone_catalog["salt_of_the_earth"] = new /datum/MilestoneDefinition("salt_of_the_earth", "Salt of the Earth", "Doubles Anger gained from damage.", 3, 1, "Fire", 2, list("controlled_fury"))
	milestone_catalog["fire_lord"] = new /datum/MilestoneDefinition("fire_lord", "Fire Lord", "Deal 1% more and take 1% less damage per burning creature within 10 tiles, up to 10%.", 3, 1, "Fire", 3, list("salt_of_the_earth"))
	milestone_catalog["smolder"] = new /datum/MilestoneDefinition("smolder", "Smolder", "Projectile hits have a 35% chance to add a burning stack, up to five active stacks.", 6, 1, "Fire", 4, list("fire_lord"))
	milestone_catalog["roleplay_scholar"] = new /datum/MilestoneDefinition("roleplay_scholar", "Roleplay Scholar", "Gains 10% more Progression XP from qualified roleplay sessions per rank.", 2, 3, "Growth", 1)
	milestone_catalog["patient_growth"] = new /datum/MilestoneDefinition("patient_growth", "Patient Growth", "Reduces the active-time Progression XP interval by 10% per rank.", 2, 3, "Growth", 2, list("roleplay_scholar"))
	milestone_catalog["arcane_memory"] = new /datum/MilestoneDefinition("arcane_memory", "Arcane Memory", "Gains 10% more Magic XP per rank.", 2, 3, "Growth", 2, list("roleplay_scholar"))
	milestone_catalog["language_savant"] = new /datum/MilestoneDefinition("language_savant", "Language Savant", "Learns languages through exposure and lessons 25% faster per rank.", 2, 3, "Culture", 1)
	milestone_catalog["custom_language"] = new /datum/MilestoneDefinition("custom_language", "Custom Language", "Create one persistent custom language that can be taught to other characters.", 3, 1, "Culture", 3, list("language_savant"))

	milestone_catalog["scientific_method"] = new /datum/MilestoneDefinition("scientific_method", "Scientific Method", "Gains 10% more Technology XP per rank.", 2, 3, "Scholarship", 1)
	milestone_catalog["liberal_arts"] = new /datum/MilestoneDefinition("liberal_arts", "Liberal Arts Degree", "Converts 25% of Mining and Smithing XP into Technology XP.", 1, 1, "Scholarship", 2, list("scientific_method"))
	milestone_catalog["profession_specialist"] = new /datum/MilestoneDefinition("profession_specialist", "Profession Specialist", "Gains 10% more Mining and Smithing XP per rank.", 2, 3, "Craft", 1)
	milestone_catalog["mining_expert"] = new /datum/MilestoneDefinition("mining_expert", "Mining Expert", "Increases natural mining yield by 50% and improves ore discovery.", 3, 1, "Craft", 2, list("profession_specialist"))
	milestone_catalog["ore_whisperer"] = new /datum/MilestoneDefinition("ore_whisperer", "Ore Whisperer", "Increases natural ore discovery chance by 15% per rank.", 2, 2, "Craft", 3, list("mining_expert"))
	milestone_catalog["master_blacksmith"] = new /datum/MilestoneDefinition("master_blacksmith", "Master Blacksmith", "Forged equipment gains 5% quality and recipes consume one less ore.", 4, 1, "Craft", 3, list("mining_expert"))
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

mob/proc/getMilestoneRank(milestone_id)
	if(!islist(milestones_owned)) milestones_owned = list()
	var/rank = milestones_owned[milestone_id]
	if(!isnum(rank)) rank = 0
	return max(0, rank)

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
		milestone_points += MILESTONE_STARTING_POINTS
		total_milestone_points += MILESTONE_STARTING_POINTS
		milestone_last_year = floor(max(0, Year))
		milestone_progression_version = 1
		if(!silent) src << "You received [MILESTONE_STARTING_POINTS] starting Milestone Points."
		return
	var/current_year = floor(max(0, Year))
	if(milestone_last_year < 0)
		milestone_last_year = current_year
		return
	if(current_year <= milestone_last_year) return
	var/earned = current_year - milestone_last_year
	milestone_last_year = current_year
	milestone_points += earned
	total_milestone_points += earned
	if(!silent) src << "You earned [earned] Milestone Point[earned == 1 ? "" : "s"] through character growth."

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

mob/proc/getMilestoneFireLordBonus()
	if(!getMilestoneRank("fire_lord")) return 0
	var/burning_creatures = 0
	for(var/mob/nearby in range(10, src))
		if(nearby.isBurning) burning_creatures++
	return min(0.1, burning_creatures * 0.01)

mob/proc/getMilestoneOutgoingDamageMultiplier(mob/target)
	var/multiplier = 1
	if(getMilestoneRank("desperate_struggle") && willpower < 50) multiplier *= 1.2
	var/fire_lord_bonus = getMilestoneFireLordBonus()
	if(fire_lord_bonus) multiplier *= 1 + fire_lord_bonus
	if(target && getMilestoneRank("concentrated_fire"))
		var/mob/selected_target = getSelectedTarget(require_view = FALSE)
		multiplier *= selected_target == target ? 1.1 : 0.95
	return multiplier

mob/proc/getMilestoneIncomingDamageMultiplier(mob/attacker)
	var/multiplier = 1 - getMilestoneRank("sturdy_build") * 0.03
	if(attacker && getMilestoneRank("turtle_shell") && attacker.dir == dir)
		multiplier *= 1 - getMilestoneRank("turtle_shell") * 0.1
	var/fire_lord_bonus = getMilestoneFireLordBonus()
	if(fire_lord_bonus) multiplier *= 1 - fire_lord_bonus
	if(attacker && getMilestoneRank("challengers_mark"))
		var/mob/selected_target = getSelectedTarget(require_view = FALSE)
		multiplier *= selected_target == attacker ? 0.85 : 1.05
	return max(0.1, multiplier)

mob/proc/tryApplyMilestoneProjectileEffects(mob/target)
	if(!target || !getMilestoneRank("smolder") || target.BurnStack >= 5 || !prob(35)) return FALSE
	target.BurnStack++
	if(!target.isBurning)
		target.isBurning = TRUE
		target.try_applying_burn_effect()
	return TRUE

obj/MilestoneTechnique
	Skill = 1
	teachable = 0
	can_hotbar = 1
	hotbar_type = "Buff"

	BleedingEdge
		name = "Bleeding Edge (Milestone)"
		desc = "Toggle the RPT Bleeding Edge weapon stance. Weapon strikes can inflict an additional bleed, but attack 10% slower."

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
		desc = "Toggle the RPT Thundering Blows weapon stance. Weapon strikes can create a damaging stagger, but attack 10% slower."

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
