var/list/technology_level_thresholds = list(0, 50, 150, 350, 700, 1200, 2000, 3200)

#define NEXUS_TECHNOLOGY_TARGET_CRAFTS_PER_LEVEL 12

mob/var
	technology_experience = 0
	technology_last_knowledge = -1
	technology_progression_version = 0

proc/getTechnologyLevelForExperience(experience)
	var/level = 1
	for(var/index = 1, index <= technology_level_thresholds.len, index++)
		if(experience >= technology_level_thresholds[index]) level = index
	return level

mob/proc/getTechnologyExperienceModifier()
	return 1 + getMilestoneRank("scientific_method") * 0.1

proc/getTechnologyCraftExperienceForLevel(science_level)
	var/reward_level = Clamp(round(science_level), 1, technology_level_thresholds.len)
	var/level_start = technology_level_thresholds[reward_level]
	var/level_end
	if(reward_level < technology_level_thresholds.len)
		level_end = technology_level_thresholds[reward_level + 1]
	else
		level_end = level_start + (level_start - technology_level_thresholds[reward_level - 1])
	return max(5, round((level_end - level_start) / NEXUS_TECHNOLOGY_TARGET_CRAFTS_PER_LEVEL))

proc/getTechnologyCraftExperience(obj/technology)
	if(!technology) return 0
	return getTechnologyCraftExperienceForLevel(max(1, technology.science_level))

mob/proc/getTechnologyPathSlots()
	if(player_tech_level >= 8) return 3
	if(player_tech_level >= 7) return 2
	if(player_tech_level >= 5) return 1
	return 0

proc/isRetiredScienceEquipment(obj/technology)
	if(!technology) return FALSE
	return technology.type in list(/obj/items/Sword, /obj/items/Armor, /obj/items/Shikon_Jewel)

proc/scienceBlueprintListContainsType(list/blueprints, blueprint_type)
	if(!islist(blueprints) || !blueprint_type) return FALSE
	for(var/obj/blueprint in blueprints)
		if(blueprint.type == blueprint_type) return TRUE
	return FALSE

proc/getCanonicalScienceBlueprint(blueprint_type)
	if(!blueprint_type) return null
	for(var/obj/technology in tech_list)
		if(technology.type == blueprint_type) return technology
	return null

proc/getNormalizedScienceBlueprintList(list/blueprints)
	var/list/normalized_blueprints = list()
	if(!islist(blueprints)) return normalized_blueprints
	var/list/seen_types = list()
	for(var/obj/blueprint in blueprints)
		if(blueprint.type in seen_types) continue
		seen_types += blueprint.type
		var/obj/canonical_blueprint = getCanonicalScienceBlueprint(blueprint.type)
		normalized_blueprints += canonical_blueprint ? canonical_blueprint : blueprint
	return normalized_blueprints

mob/proc/normalizeIndividualScienceItems()
	var/previous_count = islist(individual_science_items) ? length(individual_science_items) : 0
	individual_science_items = getNormalizedScienceBlueprintList(individual_science_items)
	return max(0, previous_count - length(individual_science_items))

mob/proc/canUnlockTechnology(obj/technology)
	if(!istype(technology, /obj) || !technology.science) return FALSE
	var/required_level = technology.science_level
	if(!required_level) required_level = 1
	required_level = max(1, required_level)
	if(player_tech_level < required_level) return FALSE
	if(required_level >= 5 && technology.science_path && !(technology.science_path in player_tech_paths)) return FALSE
	return TRUE

mob/proc/canAccessTechnology(obj/technology)
	if(!istype(technology, /obj)) return FALSE
	if(isRetiredScienceEquipment(technology)) return FALSE
	if(scienceBlueprintListContainsType(GLOBAL_SCIENCE_TAB_ITEMS, technology.type)) return TRUE
	if(scienceBlueprintListContainsType(individual_science_items, technology.type)) return TRUE
	if(progression_tree_version >= NEXUS_PROGRESSION_VERSION) return hasProgressionReward(technology.type)
	return canUnlockTechnology(technology)

mob/proc/isTechnologyReferenceClick(obj/technology)
	return istype(technology, /obj) && technology.referenceObject && canAccessTechnology(technology)

mob/proc/refreshTechnologyUnlocks(announce = FALSE)
	normalizeIndividualScienceItems()
	if(!islist(player_tech_paths)) player_tech_paths = list()
	for(var/obj/technology in tech_list)
		if(progression_tree_version >= NEXUS_PROGRESSION_VERSION)
			if(!hasProgressionReward(technology.type)) continue
		else if(!canUnlockTechnology(technology)) continue
		if(scienceBlueprintListContainsType(individual_science_items, technology.type)) continue
		individual_science_items += technology
		if(announce) src << "Technology unlocked: [technology]."

mob/proc/gainTechnologyExperience(amount, reason, announce = FALSE)
	if(amount <= 0) return 0
	var/gained = amount * getTechnologyExperienceModifier()
	technology_experience += gained
	if(announce) src << "You gained [round(gained, 0.1)] Technology XP from [reason]."
	syncTechnologyProgression(silent = !announce)
	return gained

mob/proc/syncTechnologyProgression(silent = TRUE)
	normalizeIndividualScienceItems()
	if(!islist(player_tech_paths)) player_tech_paths = list()
	var/old_level = player_tech_level
	if(technology_progression_version < 1)
		technology_experience = max(technology_experience, max(0, Knowledge - 1))
		if(player_tech_level > 0 && player_tech_level <= technology_level_thresholds.len)
			technology_experience = max(technology_experience, technology_level_thresholds[player_tech_level])
		technology_last_knowledge = Knowledge
		technology_progression_version = 1
	else
		if(technology_last_knowledge < 0) technology_last_knowledge = Knowledge
		if(Knowledge > technology_last_knowledge)
			technology_experience += (Knowledge - technology_last_knowledge) * getTechnologyExperienceModifier()
		technology_last_knowledge = Knowledge
	var/earned_level = getTechnologyLevelForExperience(technology_experience)
	player_tech_level = max(player_tech_level, earned_level)
	if(player_tech_level != old_level)
		if(!silent)
			src << "<font color=#80ffff>Your Technology Level increased to [player_tech_level]."
			if(getTechnologyPathSlots() > length(player_tech_paths)) src << "You can now choose a Technology Path from the Other tab."
		refreshTechnologyUnlocks(announce = !silent)
	else if(technology_progression_version == 1 && old_level <= 0)
		refreshTechnologyUnlocks(announce = FALSE)
	return player_tech_level

mob/verb/chooseTechnologyPath()
	set name = "Choose Technology Path"
	set category = "Other"
	showProgressionTrees("Science")

#undef NEXUS_TECHNOLOGY_TARGET_CRAFTS_PER_LEVEL
