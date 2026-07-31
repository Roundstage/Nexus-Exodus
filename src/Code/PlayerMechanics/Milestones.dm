datum/MilestoneDefinition
	var
		id
		name
		description
		cost = 1
		max_rank = 1

	New(new_id, new_name, new_description, new_cost = 1, new_max_rank = 1)
		id = new_id
		name = new_name
		description = new_description
		cost = new_cost
		max_rank = new_max_rank

var/list/milestone_catalog

proc/initializeMilestoneCatalog()
	if(islist(milestone_catalog) && milestone_catalog.len) return
	milestone_catalog = list()
	milestone_catalog["iron_will"] = new /datum/MilestoneDefinition("iron_will", "Iron Will", "+10 maximum Willpower per rank.", 1, 3)
	milestone_catalog["will_of_fire"] = new /datum/MilestoneDefinition("will_of_fire", "Will of Fire", "Reduces Willpower lost to lethal knockouts by 5 per rank.", 2, 2)
	milestone_catalog["controlled_fury"] = new /datum/MilestoneDefinition("controlled_fury", "Controlled Fury", "Builds anger 15% faster from damage per rank.", 2, 2)
	milestone_catalog["scientific_method"] = new /datum/MilestoneDefinition("scientific_method", "Scientific Method", "Gains 10% more Technology XP per rank.", 2, 3)
	milestone_catalog["rapid_recovery"] = new /datum/MilestoneDefinition("rapid_recovery", "Rapid Recovery", "Reduces knockout recovery time by 10% per rank.", 2, 2)
	milestone_catalog["steadfast_spirit"] = new /datum/MilestoneDefinition("steadfast_spirit", "Steadfast Spirit", "Recovers Willpower outside lethal combat 15% faster per rank.", 2, 2)
	milestone_catalog["liberal_arts"] = new /datum/MilestoneDefinition("liberal_arts", "Liberal Arts Degree", "Converts 25% of Mining and Smithing XP into Technology XP.", 1, 1)
	milestone_catalog["mining_expert"] = new /datum/MilestoneDefinition("mining_expert", "Mining Expert", "Increases natural mining yield by 50% and improves ore discovery.", 3, 1)
	milestone_catalog["rapid_deployment"] = new /datum/MilestoneDefinition("rapid_deployment", "Rapid Deployment", "Reduces lethal combat pressure duration by 25% per rank.", 3, 2)
	milestone_catalog["master_blacksmith"] = new /datum/MilestoneDefinition("master_blacksmith", "Master Blacksmith", "Forged equipment gains 5% quality and recipes consume one less ore.", 4, 1)

mob/var
	milestone_points = 0
	total_milestone_points = 0
	list/milestones_owned = list()
	milestone_last_year = -1
	milestone_progression_version = 0

mob/proc/getMilestoneRank(milestone_id)
	if(!islist(milestones_owned)) milestones_owned = list()
	var/rank = milestones_owned[milestone_id]
	if(!isnum(rank)) rank = 0
	return max(0, rank)

mob/proc/syncMilestoneProgression(silent = FALSE)
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
	if(milestone_points < milestone.cost)
		src << "You need [milestone.cost] Milestone Points for [milestone.name]."
		return FALSE
	milestone_points -= milestone.cost
	milestones_owned[milestone_id] = current_rank + 1
	if(milestone_id == "iron_will") restoreWillpower(10, "Iron Will strengthens your resolve.", announce = FALSE)
	src << "<font color=#ffff80>Purchased [milestone.name] rank [current_rank + 1]/[milestone.max_rank]."
	return TRUE

mob/verb/milestones()
	set name = "Milestones"
	set category = "Other"
	syncMilestoneProgression(silent = TRUE)
	initializeMilestoneCatalog()
	var/list/options = list("Cancel")
	for(var/milestone_id in milestone_catalog)
		var/datum/MilestoneDefinition/milestone = milestone_catalog[milestone_id]
		var/rank = getMilestoneRank(milestone_id)
		var/label = "[milestone.name] ([rank]/[milestone.max_rank]) - [milestone.cost] MP - [milestone.description]"
		options[label] = milestone_id
	var/choice = input(src, "Available points: [milestone_points]", "Milestones") in options
	if(!choice || choice == "Cancel") return
	var/selected_id = options[choice]
	if(alert(src, "Purchase [choice]?", "Milestones", "Yes", "No") == "Yes")
		purchaseMilestone(selected_id)
