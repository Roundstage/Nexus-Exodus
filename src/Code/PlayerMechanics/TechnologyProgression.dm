var/list/technology_level_thresholds = list(0, 50, 150, 350, 700, 1200, 2000, 3200)

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

mob/proc/getTechnologyPathSlots()
	if(player_tech_level >= 8) return 3
	if(player_tech_level >= 7) return 2
	if(player_tech_level >= 5) return 1
	return 0

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
	if(islist(GLOBAL_SCIENCE_TAB_ITEMS) && technology in GLOBAL_SCIENCE_TAB_ITEMS) return TRUE
	if(islist(individual_science_items) && technology in individual_science_items) return TRUE
	return canUnlockTechnology(technology)

mob/proc/isTechnologyReferenceClick(obj/technology)
	return istype(technology, /obj) && technology.referenceObject && canAccessTechnology(technology)

mob/proc/refreshTechnologyUnlocks(announce = FALSE)
	if(!islist(individual_science_items)) individual_science_items = list()
	if(!islist(player_tech_paths)) player_tech_paths = list()
	for(var/obj/technology in tech_list)
		if(!canUnlockTechnology(technology)) continue
		if(technology in individual_science_items) continue
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
	syncTechnologyProgression(silent = TRUE)
	var/slots = getTechnologyPathSlots()
	if(slots <= length(player_tech_paths))
		src << "You have no unspent Technology Path slots."
		return
	var/list/choices = list("Genetics", "Engineering", "Robotics")
	for(var/path in player_tech_paths) choices -= path
	choices += "Cancel"
	var/choice = input(src, "Choose a permanent Technology Path ([length(player_tech_paths)]/[slots] selected).", "Technology Path") in choices
	if(!choice || choice == "Cancel") return
	if(alert(src, "Specialize in [choice]? This choice is permanent.", "Technology Path", "Yes", "No") != "Yes") return
	player_tech_paths += choice
	refreshTechnologyUnlocks(announce = TRUE)
	src << "You specialized in [choice]."
