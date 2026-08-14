#define NEXUS_PROGRESSION_VERSION 3
#define NEXUS_PROGRESSION_EXPERIENCE_SCALE 10
#define NEXUS_PROGRESSION_EXPERIENCE_SCALE_VERSION 1
#define NEXUS_PASSIVE_PROGRESSION_INTERVAL 36000
#define NEXUS_PASSIVE_PROGRESSION_BASE_REWARD 2
#define NEXUS_ROLEPLAY_SESSION_IDLE_TIMEOUT 9000
#define NEXUS_ROLEPLAY_SESSION_PARTNER_WINDOW 6000
#define NEXUS_ROLEPLAY_SESSION_MINIMUM_DURATION 18000
#define NEXUS_ROLEPLAY_SESSION_MINIMUM_MESSAGES 6
#define NEXUS_ROLEPLAY_SESSION_MINIMUM_WORDS 120
#define NEXUS_ROLEPLAY_SESSION_REWARD 3
#define NEXUS_PROGRESSION_NODE_WIDTH 122
#define NEXUS_PROGRESSION_NODE_ICON_SIZE 58
#define NEXUS_PROGRESSION_NODE_ICON_LEFT 32
#define NEXUS_PROGRESSION_NODE_ICON_CENTER_Y 29
#define NEXUS_PROGRESSION_NODE_HEIGHT 122
#define NEXUS_PROGRESSION_TIER_SPACING 190
#define NEXUS_PROGRESSION_STACK_SPACING 132

proc/getScaledProgressionExperience(amount)
	return round(max(0, amount) * NEXUS_PROGRESSION_EXPERIENCE_SCALE, 0.1)

datum/ProgressionNode
	var
		id
		name
		description
		category
		branch
		tier = 1
		cost = 1
		max_rank = 1
		list/prerequisites = list()
		reward_kind = "passive"
		reward_type
		reward_value
		required_track
		required_racial_track
		required_level = 0
		exclusive_group
		external_unlock = FALSE
		icon_file
		icon_state

	New(new_id, new_name, new_description, new_category, new_branch, new_tier = 1, new_cost = 1)
		id = new_id
		name = new_name
		description = new_description
		category = new_category
		branch = new_branch
		tier = max(1, round(new_tier))
		cost = max(0, round(getScaledProgressionExperience(new_cost)))

var/list/progression_node_catalog
var/list/progression_node_ids_by_reward_type
var/list/progression_registered_skill_types
var/list/progression_browser_icon_cache = list()
var/list/progression_combat_excluded_skill_types

proc/registerProgressionNode(datum/ProgressionNode/node)
	if(!node || !node.id) return
	if(!islist(progression_node_catalog)) progression_node_catalog = list()
	progression_node_catalog[node.id] = node
	if(node.reward_type)
		if(!islist(progression_node_ids_by_reward_type)) progression_node_ids_by_reward_type = list()
		progression_node_ids_by_reward_type["[node.reward_type]"] = node.id
	return node

proc/createProgressionNode(node_id, node_name, node_description, category, branch, tier, cost, list/prerequisites = null)
	var/datum/ProgressionNode/node = new(node_id, node_name, node_description, category, branch, tier, cost)
	if(islist(prerequisites)) node.prerequisites = prerequisites.Copy()
	return registerProgressionNode(node)

proc/getProgressionTierLifetimeRequirement(tier)
	var/list/tier_requirements = list(0, 6, 18, 42, 72, 105, 150, 210, 270, 330)
	tier = max(1, round(tier))
	if(tier > tier_requirements.len) return getScaledProgressionExperience(tier_requirements[tier_requirements.len])
	return getScaledProgressionExperience(tier_requirements[tier])

proc/getProgressionBaseActiveExperiencePerHour()
	return getScaledProgressionExperience(NEXUS_PASSIVE_PROGRESSION_BASE_REWARD)

proc/getProgressionNodeIdForType(reward_type)
	if(!reward_type) return null
	var/reward_text = "[reward_type]"
	return "skill_[md5(reward_text)]"

proc/getProgressionScienceNodeIdForType(reward_type)
	if(!reward_type) return null
	var/reward_text = "[reward_type]"
	return "science_[md5(reward_text)]"

proc/getRacialProgressionNodeId(racial_track, reward_type)
	if(!racial_track || !reward_type) return null
	return "racial_[md5("[racial_track]|[reward_type]")]"

proc/getRacialProgressionRootId(racial_track)
	if(!racial_track) return null
	return "racial_[md5("[racial_track]")]_root"

mob/proc/getRacialProgressionTrack()
	switch(Race)
		if("Human") return "Earth Guardian"
		if("Saiyan", "Half Saiyan", "Legendary Saiyan", "Heran") return "Braal Elite"
		if("Namekian") return "Namekian"
		if("Alien", "Kanassan") return "Arconian"
		if("Frost Lord") return "Ice Master"
		if("Kai", "Demigod") return "Kaioshin"
		if("Demon", "Majin", "Makyo") return "Daimao"
		if("Android", "Bio-Android", "Spirit Doll", "Tsujin") return "Android Master"
	return null

proc/getRacialProgressionSkillPackages()
	return list(
		"Earth Guardian" = list(
			/obj/Attacks/Blast, /obj/Attacks/Charge, /obj/Attacks/Beam, /obj/Fly,
			/obj/Power_Control, /obj/Heal, /obj/Materialization, /obj/Shield, /obj/Give_Power,
			/obj/Keep_Body, /obj/Bind, /obj/Attacks/Attack_Barrier, /obj/Sense, /obj/Advanced_Sense,
			/obj/Telepathy, /obj/Observe, /obj/Reincarnation, /obj/Meditate_Level_2, /obj/Shadow_Spar, /obj/Hide_Energy),
		"Braal Elite" = list(
			/obj/Attacks/Charge, /obj/Attacks/Explosion, /obj/Attacks/Beam, /obj/Attacks/Garlic_Gun,
			/obj/Attacks/Final_Flash, /obj/Fly, /obj/Attacks/Kienzan, /obj/Attacks/Shockwave, /obj/Attacks/Blast),
		"Namekian" = list(
			/obj/Attacks/Charge, /obj/Fly, /obj/Heal, /obj/Power_Control, /obj/Materialization,
			/obj/Unlock_Potential, /obj/Give_Power, /obj/Shield, /obj/Meditate_Level_2, /obj/Shadow_Spar,
			/obj/Namekian_Fusion, /obj/Hide_Energy, /obj/Make_Dragon_Balls, /obj/Reincarnation,
			/obj/Telepathy, /obj/Observe, /obj/Sense, /obj/Advanced_Sense, /obj/Attacks/Masenko,
			/obj/Attacks/Blast, /obj/Attacks/Beam, /obj/Attacks/Piercer, /obj/Attacks/Sokidan,
			/obj/Attacks/Scatter_Shot, /obj/Attacks/Makosen, /obj/Zanzoken, /obj/SplitForm, /obj/Attacks/Shockwave),
		"Arconian" = list(
			/obj/Shunkan_Ido, /obj/Fly, /obj/Zanzoken, /obj/Attacks/Blast, /obj/Attacks/Charge,
			/obj/Attacks/Sokidan, /obj/Heal, /obj/Shield, /obj/Limit_Breaker, /obj/Telepathy,
			/obj/Observe, /obj/Attacks/Attack_Barrier, /obj/Sense, /obj/Meditate_Level_2, /obj/Shadow_Spar,
			/obj/Attacks/Beam, /obj/Attacks/Spin_Blast, /obj/Attacks/Explosion, /obj/Power_Control,
			/obj/SplitForm, /obj/Attacks/Shockwave),
		"Ice Master" = list(
			/obj/Attacks/Blast, /obj/Attacks/Charge, /obj/Attacks/Explosion, /obj/Attacks/Beam,
			/obj/Attacks/Ray, /obj/Attacks/Sokidan, /obj/Attacks/Genki_Dama/Death_Ball, /obj/Fly,
			/obj/Power_Control, /obj/Shield, /obj/Attacks/Kienzan, /obj/Attacks/Shockwave),
		"Android Master" = list(
			/obj/Attacks/Blast, /obj/Attacks/Charge, /obj/Attacks/Attack_Barrier, /obj/Attacks/Beam,
			/obj/Attacks/Ray, /obj/Attacks/Genki_Dama/Death_Ball, /obj/Fly, /obj/Shield),
		"Kaioshin" = list(
			/obj/Attacks/Blast, /obj/Attacks/Charge, /obj/Attacks/Beam, /obj/Attacks/Sokidan,
			/obj/Attacks/Scatter_Shot, /obj/Heal, /obj/Shield, /obj/Give_Power, /obj/Fly,
			/obj/Power_Control, /obj/Materialization, /obj/Unlock_Potential, /obj/Keep_Body,
			/obj/Restore_Youth, /obj/Kaio_Revive, /obj/Bind, /obj/Make_Fruit, /obj/Teleport,
			/obj/Make_Holy_Pendant, /obj/Meditate_Level_2, /obj/Telepathy, /obj/Observe,
			/obj/Reincarnation, /obj/Sense, /obj/Advanced_Sense, /obj/Shadow_Spar, /obj/Mystic,
			/obj/Focusin_revert, /obj/Hakai),
		"Daimao" = list(
			/obj/Attacks/Blast, /obj/Attacks/Charge, /obj/Attacks/Explosion, /obj/Attacks/Beam,
			/obj/Attacks/Spin_Blast, /obj/Attacks/Sokidan, /obj/Attacks/Piercer, /obj/Self_Destruct,
			/obj/Attacks/Genocide, /obj/Fly, /obj/Shield, /obj/SplitForm, /obj/MakeAmulet,
			/obj/Keep_Body, /obj/Majin, /obj/Restore_Youth, /obj/Materialization, /obj/Bind,
			/obj/Make_Fruit, /obj/Demon_Contract, /obj/Kaio_Revive, /obj/Attacks/Kienzan,
			/obj/Attacks/Shockwave, /obj/Make_Holy_Pendant, /obj/Telepathy, /obj/Observe,
			/obj/Attacks/Attack_Barrier, /obj/Reincarnation, /obj/Sense, /obj/Advanced_Sense,
			/obj/Meditate_Level_2, /obj/Shadow_Spar, /obj/Giant_Form, /obj/Hakai))

proc/registerRacialProgressionSkill(racial_track, skill_type, tier, list/prerequisites)
	if(!racial_track || !skill_type) return null
	var/skill_name = initial(skill_type:name)
	var/skill_description = initial(skill_type:desc)
	var/node_id = getRacialProgressionNodeId(racial_track, skill_type)
	var/datum/ProgressionNode/node = createProgressionNode(node_id, "[skill_name]", skill_description ? "[skill_description]" : "Learn [skill_name] through the [racial_track] lineage.", "Racial", racial_track, tier, Clamp(2 + tier * 2, 4, 28), prerequisites)
	// Assign the reward after registration so the universal Combat tree remains the canonical reward lookup.
	node.reward_kind = "skill"
	node.reward_type = skill_type
	node.required_racial_track = racial_track
	node.icon_file = initial(skill_type:icon)
	node.icon_state = initial(skill_type:icon_state)
	return node

proc/initializeProgressionRacialCatalog()
	var/list/packages = getRacialProgressionSkillPackages()
	for(var/racial_track in packages)
		var/root_id = getRacialProgressionRootId(racial_track)
		var/datum/ProgressionNode/root = createProgressionNode(root_id, "[racial_track] Legacy", "Open the highest-rank skill curriculum associated with your race's spawn world.", "Racial", racial_track, 1, 3)
		root.required_racial_track = racial_track
		var/list/skill_types = packages[racial_track]
		var/list/normal_skills = list()
		var/has_hakai = FALSE
		for(var/skill_type in skill_types)
			if(skill_type == /obj/Hakai)
				has_hakai = TRUE
				continue
			if(!(skill_type in normal_skills)) normal_skills += skill_type
		var/list/previous_tier = list(root_id)
		for(var/tier = 2, tier <= 9, tier++)
			var/list/current_tier = list()
			for(var/index = 1, index <= normal_skills.len, index++)
				var/skill_tier = 2 + floor((index - 1) * 8 / max(1, normal_skills.len))
				if(skill_tier != tier) continue
				var/parent_id = previous_tier[((current_tier.len) % previous_tier.len) + 1]
				var/datum/ProgressionNode/node = registerRacialProgressionSkill(racial_track, normal_skills[index], tier, list(parent_id))
				if(node) current_tier += node.id
			if(current_tier.len) previous_tier = current_tier
		if(has_hakai)
			var/datum/ProgressionNode/hakai = registerRacialProgressionSkill(racial_track, /obj/Hakai, 10, previous_tier.Copy())
			if(hakai)
				hakai.cost = getScaledProgressionExperience(60)
				hakai.description = "Erase a target with Hakai. This apex racial technique requires every final [racial_track] route and 3300 lifetime Progression XP."

proc/isProgressionMagicSkillType(skill_type)
	initializeMagicResearchCatalog()
	for(var/node_id in magic_research_catalog)
		var/datum/MagicResearchNode/magic_node = magic_research_catalog[node_id]
		if(magic_node.reward_type == skill_type) return TRUE
	return FALSE

proc/getProgressionFoundationSkillTypes()
	return list(
		/obj/Power_Control,
		/obj/Attacks/Blast,
		/obj/Lunge,
		/obj/Fly,
		/obj/Shield,
		/obj/Attacks/NexusStance/Block,
		/obj/Meditate_Level_2,
		/obj/Attacks/Charge,
		/obj/Attacks/Shockwave,
		/obj/Dash_Attack,
		/obj/Zanzoken,
		/obj/Buff,
		/obj/Attacks/Beam,
		/obj/Attacks/Sokidan)

proc/getProgressionCombatExcludedSkillTypes()
	if(!islist(progression_combat_excluded_skill_types))
		progression_combat_excluded_skill_types = list(
			/obj/Majin,
			/obj/Keep_Body,
			/obj/Demon_Contract,
			/obj/Attacks/Cyber_Charge,
			/obj/Attacks/Laser_Beam,
			/obj/Mystic,
			/obj/Observe,
			/obj/Invisibility,
			/obj/Make_Swarm,
			/obj/Make_Fruit,
			/obj/Attacks/Time_Freeze,
			/obj/Hakai,
			/obj/Make_Holy_Pendant,
			/obj/Buff/Preset/CombatMathematics,
			/obj/Buff/Preset/BleedingEdge,
			/obj/Focusin_revert,
			/obj/Overdrive,
			/obj/Great_Ape,
			/obj/MakeAmulet,
			/obj/Make_Dragon_Balls,
			/obj/Namekian_Fusion,
			/obj/Third_Eye,
			/obj/Unlock_Potential,
			/obj/Bind,
			/obj/Shunkan_Ido,
			/obj/FireFist)
	return progression_combat_excluded_skill_types

proc/isProgressionCombatTreeExcluded(skill_type)
	if(!skill_type) return TRUE
	if(skill_type in getProgressionCombatExcludedSkillTypes()) return TRUE
	if(ispath(skill_type, /obj/MilestoneTechnique)) return TRUE
	if(ispath(skill_type, /obj/ArcaneSpell)) return TRUE
	return FALSE

proc/getProgressionUnarmedAttackTypes()
	var/list/unarmed_types = list()
	unarmed_types.Add(getNexusUnarmedAttackTypes())
	unarmed_types.Add(
		/obj/PressurePunch,
		/obj/RoundhouseKick,
		/obj/Dropkick,
		/obj/WolfFangFist,
		/obj/Hokuto_Shinken)
	return unarmed_types

proc/isProgressionCombatSkillType(skill_type)
	if(!skill_type || isProgressionCombatTreeExcluded(skill_type)) return FALSE
	if(skill_type in getProgressionFoundationSkillTypes()) return TRUE
	if(skill_type in getNexusWeaponAttackTypes()) return TRUE
	if(skill_type in getProgressionUnarmedAttackTypes()) return TRUE
	if(skill_type in getNexusBeamAttackTypes()) return TRUE
	if(skill_type in getNexusRockAttackTypes()) return TRUE
	if(skill_type in getNexusSpecialStyleAttackTypes()) return TRUE
	if(skill_type in list(/obj/God_Fist, /obj/Attacks/Genki_Dama)) return TRUE
	if(skill_type == /obj/Buff/Focus || ispath(skill_type, /obj/Buff/Preset) || ispath(skill_type, /obj/Buff/Ultimate)) return TRUE
	if(ispath(skill_type, /obj/Attacks))
		return initial(skill_type:Skill) && initial(skill_type:can_hotbar) && initial(skill_type:Cost_To_Learn) > 0
	return FALSE

proc/getProgressionCombatBranchForType(skill_type, skill_name, hotbar_type)
	if(!skill_type || isProgressionCombatTreeExcluded(skill_type)) return null
	if(skill_type in getNexusWeaponAttackTypes()) return "Weapon"
	if(skill_type in getProgressionUnarmedAttackTypes()) return "Unarmed"
	if(skill_type in getNexusRockAttackTypes()) return "Physical"
	if(skill_type in getNexusBeamAttackTypes() || hotbar_type == "Beam") return "Beam"
	if(skill_type == /obj/Buff || skill_type == /obj/God_Fist || skill_type == /obj/Buff/Focus || ispath(skill_type, /obj/Buff/Preset) || ispath(skill_type, /obj/Buff/Ultimate)) return "Buffs"
	if(ispath(skill_type, /obj/Attacks) || hotbar_type == "Blast") return "Ki"
	var/lower_name = lowertext("[skill_name]")
	for(var/weapon_word in list("sword", "slash", "cleave", "riposte", "blade", "bash", "flourish", "stab"))
		if(findtext(lower_name, weapon_word)) return "Weapon"
	if(hotbar_type == "Melee") return "Unarmed"
	return null

proc/getProgressionSkillTier(base_cost)
	base_cost = max(0, base_cost)
	if(base_cost <= 5) return 1
	if(base_cost <= 20) return 2
	return 3

proc/getProgressionSkillCost(base_cost, student_cost, tier = 1)
	base_cost = max(0, base_cost)
	if(!base_cost && isnum(student_cost)) base_cost = student_cost * 0.2
	if(!base_cost) base_cost = tier * 6
	return Clamp(round(base_cost), 2, 60)

proc/registerProgressionSkillType(skill_type, forced_branch = null, forced_tier = 0, forced_cost = 0, external_unlock = FALSE, allow_magic_reward = FALSE)
	if(!skill_type || !isProgressionCombatSkillType(skill_type) || (!allow_magic_reward && isProgressionMagicSkillType(skill_type))) return
	if(!islist(progression_registered_skill_types)) progression_registered_skill_types = list()
	var/type_key = "[skill_type]"
	if(progression_registered_skill_types[type_key]) return
	progression_registered_skill_types[type_key] = TRUE
	var/skill_name = initial(skill_type:name)
	var/skill_description = initial(skill_type:desc)
	var/hotbar_type = initial(skill_type:hotbar_type)
	var/base_cost = initial(skill_type:Cost_To_Learn)
	var/student_cost = initial(skill_type:student_point_cost)
	var/branch = forced_branch ? forced_branch : getProgressionCombatBranchForType(skill_type, skill_name, hotbar_type)
	if(!branch) return
	var/tier = forced_tier > 0 ? forced_tier : getProgressionSkillTier(base_cost)
	var/cost = forced_cost > 0 ? forced_cost : getProgressionSkillCost(base_cost, student_cost, tier)
	var/root_id = "combat_[lowertext(branch)]_root"
	var/node_id = getProgressionNodeIdForType(skill_type)
	var/description = skill_description ? "[skill_description]" : "Learn [skill_name]."
	var/datum/ProgressionNode/node = createProgressionNode(node_id, "[skill_name]", description, "Combat", branch, tier + 1, cost, list(root_id))
	node.reward_kind = "skill"
	node.reward_type = skill_type
	node.external_unlock = external_unlock
	node.icon_file = initial(skill_type:icon)
	node.icon_state = initial(skill_type:icon_state)
	progression_node_ids_by_reward_type[type_key] = node_id
	return node

proc/configureProgressionRewardPath(reward_type, display_tier, node_cost, list/prerequisites, exclusive_group = null)
	var/node_id = getProgressionNodeIdForType(reward_type)
	var/datum/ProgressionNode/node = progression_node_catalog[node_id]
	if(!node) return
	node.tier = max(1, display_tier)
	node.cost = max(0, round(getScaledProgressionExperience(node_cost)))
	node.prerequisites = list()
	for(var/prerequisite in prerequisites)
		if(ispath(prerequisite, /obj)) node.prerequisites += getProgressionNodeIdForType(prerequisite)
		else node.prerequisites += prerequisite
	node.exclusive_group = exclusive_group
	return node

proc/configureProgressionFoundationReward(reward_type, display_tier, node_cost, list/prerequisites, new_description = null)
	var/datum/ProgressionNode/node = configureProgressionRewardPath(reward_type, display_tier, node_cost, prerequisites)
	if(!node) return
	node.category = "Combat"
	node.branch = "Foundation"
	node.external_unlock = FALSE
	if(new_description) node.description = new_description
	return node

proc/configureProgressionFoundationPaths()
	var/datum/ProgressionNode/root = progression_node_catalog["combat_foundation_root"]
	if(root)
		root.name = "Combat Foundation"
		root.description = "Begin the universal movement, ki-control, offense and defense curriculum required for healthy combat."
		root.cost = getScaledProgressionExperience(2)

	configureProgressionFoundationReward(/obj/Power_Control, 2, 4, list("combat_foundation_root"), "Regulate Battle Power, power up and power down before learning more demanding ki applications.")
	configureProgressionFoundationReward(/obj/Attacks/Blast, 2, 4, list("combat_foundation_root"), "Learn the fundamental rapid ki projectile used as the basis for ranged combat.")
	configureProgressionFoundationReward(/obj/Lunge, 2, 3, list("combat_foundation_root"), "Learn the universal committed melee approach used to enter close combat.")

	configureProgressionFoundationReward(/obj/Fly, 3, 6, list(/obj/Power_Control), "Manipulate ki to levitate and fly, trading Energy for unrestricted movement.")
	configureProgressionFoundationReward(/obj/Shield, 3, 6, list(/obj/Power_Control, /obj/Attacks/Blast), "Shape controlled ki into a defensive barrier that converts incoming damage into Energy drain.")
	configureProgressionFoundationReward(/obj/Meditate_Level_2, 3, 5, list(/obj/Power_Control), "Deepen meditation into an effective training discipline after learning to regulate your own Battle Power.")
	configureProgressionFoundationReward(/obj/Attacks/Charge, 3, 5, list(/obj/Attacks/Blast), "Concentrate a basic blast into a slower explosive projectile with greater commitment.")
	configureProgressionFoundationReward(/obj/Attacks/Shockwave, 3, 5, list(/obj/Power_Control, /obj/Attacks/Blast), "Release controlled ki and physical force in a radial wave that damages and repels nearby opponents.")
	configureProgressionFoundationReward(/obj/Dash_Attack, 3, 6, list(/obj/Lunge), "Turn the basic lunge into a controllable line rush that rewards distance and attacking from behind.")

	configureProgressionFoundationReward(/obj/Attacks/NexusStance/Block, 4, 8, list(/obj/Shield), "Brace in a timed stance that reduces final damage and improves blast evasion while sacrificing Strength, Force and Reflex.")
	configureProgressionFoundationReward(/obj/Zanzoken, 4, 8, list(/obj/Fly, /obj/Dash_Attack), "Use a burst of extreme speed to evade, reposition and pursue through an afterimage-like movement technique.")
	configureProgressionFoundationReward(/obj/Buff, 4, 10, list(/obj/Power_Control, /obj/Shield), "Create and tune a personal combat buff after mastering safe control of your own ki output.")
	configureProgressionFoundationReward(/obj/Attacks/Beam, 4, 8, list(/obj/Attacks/Charge), "Sustain concentrated ki as a controllable energy wave; the basis of named beam techniques.")

	configureProgressionFoundationReward(/obj/Attacks/Sokidan, 5, 12, list(/obj/Power_Control, /obj/Attacks/Beam), "Shape and guide a Spirit Ball after mastering both ki regulation and sustained energy projection.")

proc/finalizeProgressionCombatPaths()
	for(var/branch in list("Buffs", "Ki", "Beam", "Physical", "Unarmed", "Weapon"))
		var/list/previous_tier = list("combat_[lowertext(branch)]_root")
		for(var/display_tier = 2, display_tier <= 4, display_tier++)
			var/list/current_tier = list()
			for(var/node_id in progression_node_catalog)
				var/datum/ProgressionNode/node = progression_node_catalog[node_id]
				if(node.category != "Combat" || node.branch != branch || node.reward_kind != "skill") continue
				if(node.exclusive_group == "ultimate_buff" || node.tier != display_tier) continue
				current_tier += node.id
			if(!current_tier.len) continue
			var/parent_index = 0
			for(var/node_id in current_tier)
				parent_index++
				var/datum/ProgressionNode/node = progression_node_catalog[node_id]
				node.prerequisites = list(previous_tier[((parent_index - 1) % previous_tier.len) + 1])
			previous_tier = current_tier

proc/configureProgressionBeamPaths()
	var/datum/ProgressionNode/root = progression_node_catalog["combat_beam_root"]
	if(root)
		root.name = "Beam Discipline"
		root.description = "Specialize the foundational Beam into named sustained-wave techniques."

	configureProgressionRewardPath(/obj/Attacks/Masenko, 5, 13, list("combat_beam_root", /obj/Attacks/Beam))
	configureProgressionRewardPath(/obj/Attacks/Ray, 5, 12, list("combat_beam_root", /obj/Attacks/Beam))
	configureProgressionRewardPath(/obj/Attacks/RoleplayBeam/PhotonFlash, 5, 12, list("combat_beam_root", /obj/Attacks/Beam))

	configureProgressionRewardPath(/obj/Attacks/Kamehameha, 6, 18, list(/obj/Attacks/Masenko))
	configureProgressionRewardPath(/obj/Attacks/Dodompa, 6, 18, list(/obj/Attacks/Ray))
	configureProgressionRewardPath(/obj/Attacks/Garlic_Gun, 6, 18, list(/obj/Attacks/RoleplayBeam/PhotonFlash))

	configureProgressionRewardPath(/obj/Attacks/RoleplayBeam/DoubleSunday, 7, 22, list(/obj/Attacks/Kamehameha))
	configureProgressionRewardPath(/obj/Attacks/RoleplayBeam/TyrantLancer, 7, 22, list(/obj/Attacks/Dodompa))
	configureProgressionRewardPath(/obj/Attacks/RoleplayBeam/BusterCannon, 7, 22, list(/obj/Attacks/Garlic_Gun))

	var/datum/ProgressionNode/final_flash = configureProgressionRewardPath(/obj/Attacks/Final_Flash, 8, 34, list(/obj/Attacks/Kamehameha))
	if(final_flash) final_flash.description = "The Beam tree's peak raw-power wave, built for maximum direct damage."
	var/datum/ProgressionNode/makankosappo = configureProgressionRewardPath(/obj/Attacks/Piercer, 8, 32, list(/obj/Attacks/RoleplayBeam/TyrantLancer))
	if(makankosappo) makankosappo.description = "A peak piercing beam that grows over distance and deals 2.3x damage to shields."

proc/configureProgressionKiPaths()
	var/datum/ProgressionNode/explosive_wave = configureProgressionRewardPath(/obj/Attacks/NexusAreaTechnique/SuperExplosiveWave, 6, 22, list(/obj/Attacks/Shockwave))
	if(explosive_wave) explosive_wave.description = "Release a defensive four-tile shockwave that destroys hostile blasts, damages nearby enemies and repels them."
	var/datum/ProgressionNode/ghost_attack = configureProgressionRewardPath(/obj/Attacks/NexusSpecialStyle/SuperGhostKamikaze, 8, 36, list(/obj/Attacks/NexusAreaTechnique/SuperExplosiveWave, /obj/Attacks/Scatter_Shot))
	if(ghost_attack) ghost_attack.description = "Launch three homing ghosts at one selected target; the volley uses a shared damage budget."
	var/datum/ProgressionNode/dragon_nova = configureProgressionRewardPath(/obj/Attacks/NexusSpecialStyle/ChargedProjectile/DragonNova, 7, 34, list(/obj/Attacks/Big_Bang_Attack))
	if(dragon_nova) dragon_nova.description = "Master a huge charged ki sphere before attempting the ultimate gathered-energy attack."
	var/datum/ProgressionNode/genki_dama = configureProgressionRewardPath(/obj/Attacks/Genki_Dama, 10, 60, list(/obj/Attacks/NexusSpecialStyle/ChargedProjectile/DragonNova, /obj/Attacks/Sokidan))
	if(genki_dama)
		genki_dama.name = "Genki Dama"
		genki_dama.description = "The highest raw-damage player technique: gather, grow and guide a massive sphere before releasing its full impact and explosion."

proc/configureProgressionPhysicalPaths()
	configureProgressionRewardPath(/obj/RockThrow, 2, 7, list("combat_physical_root"))
	configureProgressionRewardPath(/obj/RockSlide, 3, 12, list(/obj/RockThrow))
	configureProgressionRewardPath(/obj/RockTomb, 4, 18, list(/obj/RockSlide))
	var/datum/ProgressionNode/earthquake = configureProgressionRewardPath(/obj/Attacks/NexusAreaTechnique/Earthquake, 5, 24, list(/obj/RockTomb))
	if(earthquake) earthquake.description = "Collapse a five-tile physical shockwave inward, damaging and pulling grounded enemies toward you; flying targets are unaffected."

proc/configureProgressionWeaponPaths()
	configureProgressionRewardPath(/obj/Attacks/NexusMeleeTechnique/CriticalEdge, 4, 18, list(/obj/Attacks/NexusMeleeTechnique/Riposte))
	configureProgressionRewardPath(/obj/Attacks/NexusSpecialStyle/ChargedProjectile/EchoingSlash, 4, 20, list(/obj/Attacks/NexusMeleeTechnique/WindHowl))
	configureProgressionRewardPath(/obj/Attacks/NexusSpecialStyle/ChargedProjectile/SkyBreak, 5, 28, list(/obj/Attacks/NexusSpecialStyle/ChargedProjectile/EchoingSlash))

proc/configureProgressionUnarmedPaths()
	configureProgressionRewardPath(/obj/Attacks/NexusMeleeTechnique/Headbutt, 2, 8, list("combat_unarmed_root"))
	configureProgressionRewardPath(/obj/Attacks/NexusMeleeTechnique/UppercutCombo, 2, 8, list("combat_unarmed_root"))
	configureProgressionRewardPath(/obj/Attacks/NexusMeleeTechnique/WingClip, 2, 8, list("combat_unarmed_root"))
	configureProgressionRewardPath(/obj/Attacks/NexusMeleeTechnique/SandThrow, 2, 8, list("combat_unarmed_root"))

	configureProgressionRewardPath(/obj/Attacks/NexusMeleeTechnique/AxeKick, 3, 12, list(/obj/Attacks/NexusMeleeTechnique/Headbutt))
	configureProgressionRewardPath(/obj/Attacks/NexusMeleeTechnique/MegatonThrow, 3, 14, list(/obj/Attacks/NexusMeleeTechnique/Headbutt))
	configureProgressionRewardPath(/obj/Attacks/NexusMeleeTechnique/KickbackCombo, 3, 14, list(/obj/Attacks/NexusMeleeTechnique/UppercutCombo))
	configureProgressionRewardPath(/obj/Attacks/NexusMeleeTechnique/GuardBreak, 3, 14, list(/obj/Attacks/NexusMeleeTechnique/WingClip))

	configureProgressionRewardPath(/obj/Attacks/NexusMeleeTechnique/PileDriver, 4, 20, list(/obj/Attacks/NexusMeleeTechnique/MegatonThrow))
	configureProgressionRewardPath(/obj/Attacks/NexusMeleeTechnique/ConsecutiveNormalPunches, 4, 20, list(/obj/Attacks/NexusMeleeTechnique/KickbackCombo))
	configureProgressionRewardPath(/obj/Attacks/NexusMeleeTechnique/BurningShot, 4, 18, list(/obj/Attacks/NexusMeleeTechnique/KickbackCombo))
	configureProgressionRewardPath(/obj/Attacks/NexusMeleeTechnique/BlueCometSpecial, 4, 20, list(/obj/Attacks/NexusMeleeTechnique/KickbackCombo))
	configureProgressionRewardPath(/obj/RoundhouseKick, 4, 20, list(/obj/Attacks/NexusMeleeTechnique/AxeKick))
	configureProgressionRewardPath(/obj/WolfFangFist, 4, 22, list(/obj/Attacks/NexusMeleeTechnique/KickbackCombo))

	var/datum/ProgressionNode/texas_smash = configureProgressionRewardPath(/obj/Attacks/NexusMeleeTechnique/TexasSmash, 5, 28, list(/obj/Attacks/NexusMeleeTechnique/PileDriver))
	if(texas_smash) texas_smash.description = "The impact route's peak single blow, trading accuracy for devastating raw damage and knockback."
	var/datum/ProgressionNode/march_of_fury = configureProgressionRewardPath(/obj/Attacks/NexusMeleeTechnique/MarchOfFury, 5, 30, list(/obj/Attacks/NexusMeleeTechnique/ConsecutiveNormalPunches))
	if(march_of_fury) march_of_fury.description = "The combo route's peak pursuit technique, resolving four attacks for the highest sustained unarmed damage."
	var/datum/ProgressionNode/exploding_heart = configureProgressionRewardPath(/obj/Attacks/NexusMeleeTechnique/ExplodingHeartStrike, 5, 28, list(/obj/Attacks/NexusMeleeTechnique/GuardBreak))
	if(exploding_heart) exploding_heart.description = "The precision route's capstone strike, combining heavy direct damage with internal bleeding."
	var/datum/ProgressionNode/pressure_punch = configureProgressionRewardPath(/obj/PressurePunch, 5, 30, list(/obj/RoundhouseKick))
	if(pressure_punch) pressure_punch.description = "A peak impact strike with a raw physical factor of 6 and extreme knockback."
	var/datum/ProgressionNode/dropkick = configureProgressionRewardPath(/obj/Dropkick, 5, 32, list(/obj/Attacks/NexusMeleeTechnique/BurningShot))
	if(dropkick) dropkick.description = "A capstone lunge that combines opening and finishing hits for a total physical factor of 8."
	var/datum/ProgressionNode/hundred_crack_fist = configureProgressionRewardPath(/obj/Hokuto_Shinken, 5, 30, list(/obj/WolfFangFist))
	if(hundred_crack_fist) hundred_crack_fist.description = "A capstone barrage of at least twenty-four rapid strikes, totaling a minimum physical factor of 6."

proc/configureProgressionAuthoredAttackPaths()
	configureProgressionBeamPaths()
	configureProgressionKiPaths()
	configureProgressionPhysicalPaths()
	configureProgressionWeaponPaths()
	configureProgressionUnarmedPaths()

proc/disperseProgressionScienceTierFive()
	for(var/branch in list("Engineering", "Robotics", "Genetics"))
		var/list/candidates = list()
		for(var/obj/technology in tech_list)
			if(!technology.science || technology.science_path != branch || technology.science_level != 5) continue
			var/inserted = FALSE
			for(var/index = 1, index <= candidates.len, index++)
				var/obj/existing = candidates[index]
				if(technology.Cost < existing.Cost)
					candidates.Insert(index, technology)
					inserted = TRUE
					break
			if(!inserted) candidates += technology
		for(var/index = 1, index <= candidates.len, index++)
			var/obj/technology = candidates[index]
			technology.science_level = 5 + min(3, floor((index - 1) * 4 / max(1, candidates.len)))

proc/initializeProgressionCombatCatalog()
	for(var/branch in list("Foundation", "Buffs", "Ki", "Beam", "Physical", "Unarmed", "Weapon"))
		var/branch_key = lowertext(branch)
		var/datum/ProgressionNode/root = createProgressionNode("combat_[branch_key]_root", "[branch] Fundamentals", "Opens the first [branch] techniques.", "Combat", branch, 1, 3)
		root.max_rank = 1

	var/list/foundation_skill_types = getProgressionFoundationSkillTypes()
	for(var/foundation_type in foundation_skill_types)
		registerProgressionSkillType(foundation_type, "Foundation", 1, 4, FALSE, TRUE)

	var/list/preset_buffs = list(
		/obj/Buff/Focus,
		/obj/Buff/Preset/MuscleForce,
		/obj/Buff/Preset/KiBlade,
		/obj/Buff/Preset/MagicForce,
		/obj/Buff/Preset/OffensiveStance,
		/obj/Buff/Preset/DefensiveStance,
		/obj/Buff/Preset/BurningFist,
		/obj/Buff/Preset/KiFist,
		/obj/Buff/Preset/DemonicFury,
		/obj/Buff/Preset/AngelicGrace,
		/obj/Buff/Preset/Channel)
	var/buff_index = 0
	for(var/buff_type in preset_buffs)
		buff_index++
		var/buff_tier = buff_index <= 4 ? 1 : (buff_index <= 9 ? 2 : 3)
		registerProgressionSkillType(buff_type, "Buffs", buff_tier, 4 + buff_tier * 4)
	var/list/ultimate_buffs = list(
		/obj/Buff/Ultimate/HighTension,
		/obj/Buff/Ultimate/Godspeed,
		/obj/Buff/Ultimate/FistsOfFury,
		/obj/Buff/Ultimate/ArcanePower,
		/obj/Buff/Ultimate/BestialWrath,
		/obj/Buff/Ultimate/Bushido)
	for(var/buff_type in ultimate_buffs)
		var/datum/ProgressionNode/ultimate_node = registerProgressionSkillType(buff_type, "Buffs", 4, 30)
		ultimate_node.exclusive_group = "ultimate_buff"
	registerProgressionSkillType(/obj/God_Fist, "Buffs", 9, 60)

	var/weapon_index = 0
	for(var/weapon_type in getNexusWeaponAttackTypes())
		weapon_index++
		var/weapon_tier = weapon_index <= 4 ? 1 : (weapon_index <= 8 ? 2 : 3)
		registerProgressionSkillType(weapon_type, "Weapon", weapon_tier, 4 + weapon_tier * 5)
	var/unarmed_index = 0
	for(var/unarmed_type in getProgressionUnarmedAttackTypes())
		unarmed_index++
		var/unarmed_tier = unarmed_index <= 5 ? 1 : (unarmed_index <= 10 ? 2 : 3)
		registerProgressionSkillType(unarmed_type, "Unarmed", unarmed_tier, 4 + unarmed_tier * 5)
	var/beam_index = 0
	for(var/beam_type in getNexusBeamAttackTypes())
		beam_index++
		var/beam_tier = beam_index <= 4 ? 1 : (beam_index <= 8 ? 2 : 3)
		registerProgressionSkillType(beam_type, "Beam", beam_tier, 4 + beam_tier * 5)
	for(var/rock_type in getNexusRockAttackTypes())
		registerProgressionSkillType(rock_type, "Physical", 1, 8)
	var/ki_index = 0
	for(var/ki_type in getNexusSpecialStyleAttackTypes())
		ki_index++
		var/ki_tier = ki_index <= 3 ? 1 : 2
		var/ki_branch = ki_type == /obj/Attacks/NexusAreaTechnique/Earthquake ? "Physical" : "Ki"
		registerProgressionSkillType(ki_type, ki_branch, ki_tier, 4 + ki_tier * 5)
	registerProgressionSkillType(/obj/Attacks/Genki_Dama, "Ki", 9, 60)

	for(var/skill_type in typesof(/obj))
		if(skill_type in Illegal_learnables) continue
		if(initial(skill_type:Cost_To_Learn)) registerProgressionSkillType(skill_type)

	finalizeProgressionCombatPaths()
	configureProgressionAuthoredAttackPaths()
	finalizeProgressionCombatPaths()
	configureProgressionAuthoredAttackPaths()
	configureProgressionRewardPath(/obj/Buff/Focus, 2, 8, list("combat_buffs_root"))
	configureProgressionRewardPath(/obj/Buff/Preset/MuscleForce, 2, 8, list("combat_buffs_root"))
	configureProgressionRewardPath(/obj/Buff/Preset/KiBlade, 2, 8, list("combat_buffs_root"))
	configureProgressionRewardPath(/obj/Buff/Preset/DefensiveStance, 3, 12, list(/obj/Buff/Focus))
	configureProgressionRewardPath(/obj/Buff/Preset/OffensiveStance, 3, 12, list(/obj/Buff/Preset/MuscleForce))
	configureProgressionRewardPath(/obj/Buff/Preset/MagicForce, 3, 12, list(/obj/Buff/Preset/KiBlade))
	configureProgressionRewardPath(/obj/Buff/Preset/BurningFist, 3, 12, list(/obj/Buff/Preset/KiBlade))
	configureProgressionRewardPath(/obj/Buff/Preset/AngelicGrace, 4, 16, list(/obj/Buff/Preset/DefensiveStance))
	configureProgressionRewardPath(/obj/Buff/Preset/DemonicFury, 4, 16, list(/obj/Buff/Preset/OffensiveStance))
	configureProgressionRewardPath(/obj/Buff/Preset/KiFist, 4, 16, list(/obj/Buff/Preset/BurningFist))
	configureProgressionRewardPath(/obj/Buff/Preset/Channel, 4, 16, list(/obj/Buff/Preset/MagicForce))
	configureProgressionRewardPath(/obj/Buff/Ultimate/Godspeed, 5, 30, list(/obj/Buff/Preset/AngelicGrace), "ultimate_buff")
	configureProgressionRewardPath(/obj/Buff/Ultimate/HighTension, 5, 30, list(/obj/Buff/Preset/DemonicFury), "ultimate_buff")
	configureProgressionRewardPath(/obj/Buff/Ultimate/BestialWrath, 5, 30, list(/obj/Buff/Preset/DemonicFury), "ultimate_buff")
	configureProgressionRewardPath(/obj/Buff/Ultimate/FistsOfFury, 5, 30, list(/obj/Buff/Preset/KiFist), "ultimate_buff")
	configureProgressionRewardPath(/obj/Buff/Ultimate/ArcanePower, 5, 30, list(/obj/Buff/Preset/Channel), "ultimate_buff")
	configureProgressionRewardPath(/obj/Buff/Ultimate/Bushido, 5, 30, list(/obj/Buff/Preset/OffensiveStance), "ultimate_buff")
	configureProgressionRewardPath(/obj/God_Fist, 10, 60, list(/obj/Buff, "combat_buffs_root"))
	configureProgressionFoundationPaths()

proc/initializeProgressionMagicCatalog()
	initializeMagicResearchCatalog()
	initializeArcaneFormulaCatalog()
	createProgressionNode("magic_attunement", "Arcane Attunement", "Open your senses to structured magic study.", "Magic", "Foundation", 1, 3)
	var/list/magic_branches = list()
	for(var/magic_id in magic_research_catalog)
		var/datum/MagicResearchNode/magic_node = magic_research_catalog[magic_id]
		if(!(magic_node.branch in magic_branches)) magic_branches += magic_node.branch
	for(var/branch in magic_branches)
		var/list/previous_tier = list("magic_attunement")
		for(var/magic_level = 1, magic_level <= magic_level_thresholds.len, magic_level++)
			var/list/current_tier = list()
			for(var/magic_id in magic_research_catalog)
				var/datum/MagicResearchNode/magic_node = magic_research_catalog[magic_id]
				if(magic_node.branch != branch || magic_node.required_level != magic_level) continue
				var/node_id = "magic_[magic_id]"
				var/parent_id = previous_tier[((current_tier.len) % previous_tier.len) + 1]
				var/datum/ProgressionNode/node = createProgressionNode(node_id, magic_node.name, magic_node.description, "Magic", magic_node.branch, magic_node.required_level + 1, max(3, magic_node.required_level * 4), list(parent_id))
				node.reward_kind = "magic"
				node.reward_type = magic_node.reward_type
				node.reward_value = magic_node.id
				node.required_track = "Magic"
				node.required_level = magic_node.required_level
				var/datum/ArcaneFormula/formula = arcane_formula_catalog[magic_node.id]
				var/icon_type = formula && formula.construct_type ? formula.construct_type : magic_node.reward_type
				node.icon_file = initial(icon_type:icon)
				node.icon_state = initial(icon_type:icon_state)
				current_tier += node_id
			if(current_tier.len) previous_tier = current_tier

proc/initializeProgressionScienceCatalog()
	createProgressionNode("science_foundation", "Scientific Method", "Opens structured research and registered Foundation designs.", "Science", "Foundation", 1, 3)
	for(var/path_name in list("Engineering", "Robotics", "Genetics"))
		var/path_id = "science_path_[lowertext(path_name)]"
		var/datum/ProgressionNode/path_node = createProgressionNode(path_id, "[path_name] Specialization", "Commit one available Technology Path slot to [path_name].", "Science", path_name, 2, 10, list("science_foundation"))
		path_node.reward_kind = "tech_path"
		path_node.reward_value = path_name
		path_node.required_track = "Technology"
		path_node.required_level = 5
	disperseProgressionScienceTierFive()
	for(var/branch in list("Foundation", "Engineering", "Robotics", "Genetics"))
		var/list/previous_tier = list(branch == "Foundation" ? "science_foundation" : "science_path_[lowertext(branch)]")
		for(var/required_level = 1, required_level <= technology_level_thresholds.len, required_level++)
			var/list/current_tier = list()
			for(var/obj/technology in tech_list)
				if(!technology.science) continue
				var/technology_branch = technology.science_path ? technology.science_path : "Foundation"
				if(technology_branch != branch || max(1, technology.science_level) != required_level) continue
				var/node_id = getProgressionScienceNodeIdForType(technology.type)
				var/parent_id = previous_tier[((current_tier.len) % previous_tier.len) + 1]
				var/description = technology.desc ? "[technology.desc]" : "Unlock the [technology.name] design."
				var/datum/ProgressionNode/node = createProgressionNode(node_id, "[technology.name]", description, "Science", branch, required_level + 1, max(2, required_level * 3), list(parent_id))
				node.reward_kind = "technology"
				node.reward_type = technology.type
				node.required_track = "Technology"
				node.required_level = required_level
				node.icon_file = technology.icon
				node.icon_state = technology.icon_state
				progression_node_ids_by_reward_type["[technology.type]"] = node_id
				current_tier += node_id
			if(current_tier.len) previous_tier = current_tier

proc/initializeProgressionProfessionCatalog()
	var/datum/ProgressionNode/mining_root = createProgressionNode("mining_prospector", "Prospector", "Learn safe extraction and Copper prospecting.", "Mining", "Extraction", 1, 3)
	mining_root.required_track = "Mining"
	mining_root.required_level = 1
	var/list/ore_nodes = list(
		list("mining_tin", "Tin Prospecting", 3, "mining_prospector", 'RTTinOre.dmi', 2),
		list("mining_iron", "Iron Prospecting", 7, "mining_tin", 'RTIronOre.dmi', 3),
		list("mining_silver", "Silver Prospecting", 14, "mining_iron", 'RTSilverOre.dmi', 4),
		list("mining_mythril", "Mythril Prospecting", 20, "mining_iron", 'RTMythrilOre.dmi', 4),
		list("mining_auracite", "Auracite Prospecting", 30, "mining_silver", 'RTAuraciteOre.dmi', 5),
		list("mining_heart", "Heart of the Mountain", 35, "mining_mythril", 'RTMythrilOre.dmi', 5))
	for(var/list/ore_data in ore_nodes)
		var/datum/ProgressionNode/ore_node = createProgressionNode(ore_data[1], ore_data[2], "Unlocks discovery and extraction of this ore.", "Mining", "Prospecting", ore_data[6], 3 + round(ore_data[3] / 3), list(ore_data[4]))
		ore_node.required_track = "Mining"
		ore_node.required_level = ore_data[3]
		ore_node.icon_file = ore_data[5]
	var/datum/ProgressionNode/extraction = createProgressionNode("mining_efficient_extraction", "Efficient Extraction", "+10% natural mining yield per rank.", "Mining", "Extraction", 2, 5, list("mining_prospector"))
	extraction.max_rank = 3
	var/datum/ProgressionNode/ore_sense = createProgressionNode("mining_ore_sense", "Ore Sense", "+15% chance to uncover an ore stack per rank.", "Mining", "Extraction", 3, 7, list("mining_efficient_extraction"))
	ore_sense.max_rank = 2

	var/datum/ProgressionNode/smith_root = createProgressionNode("smithing_apprentice", "Forge Apprentice", "Unlocks Normal equipment frames, Copper upgrades and pickaxes.", "Smithing", "Forgecraft", 1, 3)
	smith_root.required_track = "Smithing"
	smith_root.required_level = 1
	var/list/material_nodes = list(
		list("smithing_bronze", "Bronze Working", 4, "smithing_apprentice", 'RTCopperOre.dmi', 2),
		list("smithing_iron", "Iron Working", 8, "smithing_bronze", 'RTIronOre.dmi', 3),
		list("smithing_silver", "Silversmith", 14, "smithing_bronze", 'RTSilverOre.dmi', 3),
		list("smithing_mythril", "Mythril Working", 20, "smithing_iron", 'RTMythrilOre.dmi', 4),
		list("smithing_auracite", "Auracite Conduction", 30, "smithing_silver", 'RTAuraciteOre.dmi', 4),
		list("smithing_masterwork", "Masterwork Alloy", 35, "smithing_mythril", 'RTMythrilOre.dmi', 5))
	for(var/list/material_data in material_nodes)
		var/datum/ProgressionNode/material_node = createProgressionNode(material_data[1], material_data[2], "Unlocks this material module at the Nexus Forge.", "Smithing", "Materials", material_data[6], 3 + round(material_data[3] / 3), list(material_data[4]))
		material_node.required_track = "Smithing"
		material_node.required_level = material_data[3]
		material_node.icon_file = material_data[5]
	var/datum/ProgressionNode/efficiency = createProgressionNode("smithing_resource_efficiency", "Resource Efficiency", "Reduces forged ore costs by one per rank, to a minimum of one.", "Smithing", "Forgecraft", 2, 6, list("smithing_apprentice"))
	efficiency.max_rank = 2

proc/initializeProgressionTreeCatalog()
	if(islist(progression_node_catalog) && progression_node_catalog.len) return
	progression_node_catalog = list()
	progression_node_ids_by_reward_type = list()
	progression_registered_skill_types = list()
	initializeProgressionCombatCatalog()
	initializeProgressionMagicCatalog()
	initializeProgressionScienceCatalog()
	initializeProgressionProfessionCatalog()
	initializeProgressionRacialCatalog()

mob/var
	progression_experience = 0
	progression_lifetime_experience = 0
	progression_chat_experience = 0
	progression_passive_experience = 0
	progression_roleplay_sessions_completed = 0
	list/progression_nodes_owned = list()
	progression_tree_version = 0
	progression_experience_scale_version = 0
	progression_last_passive_realtime = 0
	progression_last_communication_award = 0
	progression_last_communication_hash
	tmp/progression_roleplay_session_started_time = 0
	tmp/progression_roleplay_session_last_time = 0
	tmp/progression_roleplay_session_messages = 0
	tmp/progression_roleplay_session_words = 0
	tmp/progression_roleplay_session_rewarded = FALSE
	tmp/progression_roleplay_session_multiplier = 1
	tmp/progression_last_roleplay_contribution_time = 0
	tmp/list/progression_roleplay_session_participants = list()

mob/proc/getProgressionNodeRank(node_id)
	if(!islist(progression_nodes_owned)) progression_nodes_owned = list()
	var/rank = progression_nodes_owned[node_id]
	if(!isnum(rank)) return 0
	return max(0, round(rank))

mob/proc/hasProgressionNode(node_id)
	return getProgressionNodeRank(node_id) > 0

mob/proc/getProgressionNodeIdForReward(reward_type)
	initializeProgressionTreeCatalog()
	return progression_node_ids_by_reward_type["[reward_type]"]

mob/proc/hasProgressionReward(reward_type)
	var/node_id = getProgressionNodeIdForReward(reward_type)
	return node_id && hasProgressionNode(node_id)

mob/proc/hasExactProgressionRewardObject(reward_type)
	if(!reward_type) return FALSE
	for(var/obj/reward in src)
		if(reward.type == reward_type) return TRUE
	return FALSE

mob/proc/migrateProgressionExperienceScale()
	if(progression_experience_scale_version >= NEXUS_PROGRESSION_EXPERIENCE_SCALE_VERSION) return FALSE
	progression_experience = getScaledProgressionExperience(progression_experience)
	progression_lifetime_experience = getScaledProgressionExperience(progression_lifetime_experience)
	progression_chat_experience = getScaledProgressionExperience(progression_chat_experience)
	progression_passive_experience = getScaledProgressionExperience(progression_passive_experience)
	progression_experience_scale_version = NEXUS_PROGRESSION_EXPERIENCE_SCALE_VERSION
	return TRUE

mob/proc/getProgressionRequiredLevel(datum/ProgressionNode/node)
	if(!node || !node.required_track) return 0
	switch(node.required_track)
		if("Technology") return player_tech_level
		if("Magic") return magic_level
		if("Mining") return mining_level
		if("Smithing") return smithing_level
	return 0

mob/proc/getProgressionNodeLockReason(datum/ProgressionNode/node)
	if(!node) return "Unknown node."
	if(getProgressionNodeRank(node.id) >= node.max_rank) return null
	if(node.required_racial_track && getRacialProgressionTrack() != node.required_racial_track)
		return "Restricted to the [node.required_racial_track] racial curriculum."
	for(var/prerequisite_id in node.prerequisites)
		if(!hasProgressionNode(prerequisite_id))
			var/datum/ProgressionNode/prerequisite = progression_node_catalog[prerequisite_id]
			return "Requires [prerequisite ? prerequisite.name : prerequisite_id]."
	if(node.required_level > 0 && getProgressionRequiredLevel(node) < node.required_level)
		return "Requires [node.required_track] level [node.required_level]."
	var/lifetime_requirement = getProgressionTierLifetimeRequirement(node.tier)
	if(progression_lifetime_experience < lifetime_requirement)
		return "Requires [lifetime_requirement] lifetime Progression XP for tier [node.tier]."
	if(node.reward_kind == "tech_path")
		if(node.reward_value in player_tech_paths) return null
		if(length(player_tech_paths) >= getTechnologyPathSlots()) return "Requires an available Technology Path slot."
	if(node.exclusive_group)
		for(var/other_id in progression_node_catalog)
			var/datum/ProgressionNode/other = progression_node_catalog[other_id]
			if(other.id != node.id && other.exclusive_group == node.exclusive_group && hasProgressionNode(other.id))
				return "Exclusive with [other.name]."
	if(node.external_unlock) return "Granted by race, teaching, event, quest or another talent."
	if(progression_experience < node.cost) return "Requires [node.cost] Progression XP."
	return null

mob/proc/applyProgressionNodeReward(datum/ProgressionNode/node, announce = TRUE)
	if(!node) return FALSE
	switch(node.reward_kind)
		if("skill")
			if(node.reward_type && !hasExactProgressionRewardObject(node.reward_type))
				var/obj/new_skill = new node.reward_type(src)
				new_skill.Taught = 0
		if("magic")
			initializeMagicResearchCatalog()
			var/datum/MagicResearchNode/magic_node = magic_research_catalog[node.reward_value]
			if(magic_node) grantMagicResearchNode(magic_node, announce)
		if("technology")
			if(!islist(individual_science_items)) individual_science_items = list()
			for(var/obj/technology in tech_list)
				if(technology.type == node.reward_type && !scienceBlueprintListContainsType(individual_science_items, technology.type))
					individual_science_items += technology
					break
		if("tech_path")
			if(!islist(player_tech_paths)) player_tech_paths = list()
			if(!(node.reward_value in player_tech_paths)) player_tech_paths += node.reward_value
	if(announce)
		src << sound('Capsuleclick.ogg', volume = 18)
		src << "<font color=#ffd166>Progression unlocked: [node.name]."
	return TRUE

mob/proc/purchaseProgressionNode(node_id)
	migrateProgressionExperienceScale()
	initializeProgressionTreeCatalog()
	var/datum/ProgressionNode/node = progression_node_catalog[node_id]
	if(!node) return FALSE
	var/current_rank = getProgressionNodeRank(node.id)
	if(current_rank >= node.max_rank)
		src << "[node.name] is already at maximum rank."
		return FALSE
	var/lock_reason = getProgressionNodeLockReason(node)
	if(lock_reason)
		src << lock_reason
		return FALSE
	progression_experience -= node.cost
	progression_nodes_owned[node.id] = current_rank + 1
	applyProgressionNodeReward(node, announce = TRUE)
	return TRUE

mob/proc/gainProgressionExperience(amount, reason = "progression", announce = FALSE, source_kind = "other")
	migrateProgressionExperienceScale()
	if(amount <= 0) return 0
	var/gained = round(amount, 0.1)
	if(source_kind == "chat" && arcane_merriment_until > world.time) gained *= 1.25
	progression_experience += gained
	progression_lifetime_experience += gained
	if(source_kind == "chat") progression_chat_experience += gained
	if(source_kind == "passive") progression_passive_experience += gained
	if(announce) src << "<font color=#ffd166>You gained [gained] Progression XP from [reason]."
	return gained

mob/proc/resetProgressionRoleplaySession()
	progression_roleplay_session_started_time = 0
	progression_roleplay_session_last_time = 0
	progression_roleplay_session_messages = 0
	progression_roleplay_session_words = 0
	progression_roleplay_session_rewarded = FALSE
	progression_roleplay_session_multiplier = 1
	progression_roleplay_session_participants = list()

mob/proc/tryAwardProgressionRoleplaySession()
	if(progression_roleplay_session_rewarded || !progression_roleplay_session_started_time) return 0
	if(world.time - progression_roleplay_session_started_time < NEXUS_ROLEPLAY_SESSION_MINIMUM_DURATION) return 0
	if(progression_roleplay_session_messages < NEXUS_ROLEPLAY_SESSION_MINIMUM_MESSAGES) return 0
	if(progression_roleplay_session_words < NEXUS_ROLEPLAY_SESSION_MINIMUM_WORDS) return 0
	if(!islist(progression_roleplay_session_participants) || !progression_roleplay_session_participants.len) return 0
	progression_roleplay_session_rewarded = TRUE
	var/reward = getScaledProgressionExperience(NEXUS_ROLEPLAY_SESSION_REWARD * progression_roleplay_session_multiplier)
	reward *= 1 + getMilestoneRank("roleplay_scholar") * 0.1
	var/gained = gainProgressionExperience(reward, "roleplay session", announce = FALSE, source_kind = "chat")
	if(gained > 0)
		progression_roleplay_sessions_completed++
		src << "<font color=#ffd166>Roleplay session completed: +[round(gained, 0.1)] Progression XP."
	return gained

mob/proc/awardProgressionFromCommunication(raw_text, source_name = "roleplay", multiplier = 1)
	if(!client || !playerCharacter) return 0
	if(!(source_name in list("say", "whisper", "thought", "emote"))) return 0
	var/word_count = countNexusWords(raw_text)
	if(word_count < 4) return 0
	var/message_hash = md5(lowertext("[raw_text]"))
	if(message_hash == progression_last_communication_hash && world.time - progression_last_communication_award < 6000) return 0
	var/minimum_delay = source_name == "emote" ? 200 : 100
	if(world.time - progression_last_communication_award < minimum_delay) return 0
	progression_last_communication_award = world.time
	progression_last_communication_hash = message_hash
	if(progression_roleplay_session_started_time && progression_roleplay_session_last_time && world.time - progression_roleplay_session_last_time > NEXUS_ROLEPLAY_SESSION_IDLE_TIMEOUT)
		resetProgressionRoleplaySession()
	if(!progression_roleplay_session_started_time)
		progression_roleplay_session_started_time = world.time
		progression_roleplay_session_participants = list()
	progression_roleplay_session_last_time = world.time
	progression_last_roleplay_contribution_time = world.time
	progression_roleplay_session_messages++
	progression_roleplay_session_words += min(200, word_count)
	progression_roleplay_session_multiplier = max(progression_roleplay_session_multiplier, Clamp(multiplier, 1, 1.25))
	for(var/mob/participant in Say_Recipients())
		if(participant == src || !participant.client || !participant.playerCharacter || !participant.ckey) continue
		if(client.computer_id && participant.client.computer_id == client.computer_id) continue
		if(!participant.progression_last_roleplay_contribution_time || world.time - participant.progression_last_roleplay_contribution_time > NEXUS_ROLEPLAY_SESSION_PARTNER_WINDOW) continue
		if(!islist(progression_roleplay_session_participants)) progression_roleplay_session_participants = list()
		if(!islist(participant.progression_roleplay_session_participants)) participant.progression_roleplay_session_participants = list()
		progression_roleplay_session_participants[participant.ckey] = TRUE
		participant.progression_roleplay_session_participants[ckey] = TRUE
		participant.tryAwardProgressionRoleplaySession()
	return tryAwardProgressionRoleplaySession()

mob/proc/getProgressionHourlyExperience()
	var/growth_interval_modifier = max(0.7, 1 - getMilestoneRank("patient_growth") * 0.1)
	return round(getProgressionBaseActiveExperiencePerHour() / growth_interval_modifier, 0.1)

mob/proc/updatePassiveProgression(announce = TRUE)
	migrateProgressionExperienceScale()
	if(progression_last_passive_realtime <= 0)
		progression_last_passive_realtime = world.realtime
		return 0
	var/elapsed = world.realtime - progression_last_passive_realtime
	if(elapsed < NEXUS_PASSIVE_PROGRESSION_INTERVAL) return 0
	var/elapsed_hours = floor(elapsed / NEXUS_PASSIVE_PROGRESSION_INTERVAL)
	progression_last_passive_realtime += elapsed_hours * NEXUS_PASSIVE_PROGRESSION_INTERVAL
	var/reward = elapsed_hours * getProgressionHourlyExperience()
	var/reason = elapsed_hours == 1 ? "hourly progression" : "[elapsed_hours] hours of online/offline progression"
	return gainProgressionExperience(reward, reason, announce = announce, source_kind = "passive")

mob/proc/syncProgressionTrees(silent = TRUE)
	initializeProgressionTreeCatalog()
	migrateProgressionExperienceScale()
	normalizeIndividualScienceItems()
	if(!islist(progression_nodes_owned)) progression_nodes_owned = list()
	progression_experience = max(0, progression_experience)
	progression_lifetime_experience = max(progression_lifetime_experience, progression_experience)
	if(progression_tree_version < NEXUS_PROGRESSION_VERSION)
		if(isnum(Experience) && Experience > 0)
			var/scaled_legacy_experience = getScaledProgressionExperience(Experience)
			progression_experience += scaled_legacy_experience
			progression_lifetime_experience += scaled_legacy_experience
			Experience = 0
		for(var/node_id in progression_node_catalog)
			var/datum/ProgressionNode/node = progression_node_catalog[node_id]
			if(node.reward_kind == "skill" && node.reward_type && hasExactProgressionRewardObject(node.reward_type)) progression_nodes_owned[node.id] = max(1, getProgressionNodeRank(node.id))
			else if(node.reward_kind == "magic")
				if((node.reward_value in magic_nodes_unlocked) || magic_level >= node.required_level) progression_nodes_owned[node.id] = 1
			else if(node.reward_kind == "technology")
				for(var/obj/technology in tech_list)
					if(technology.type != node.reward_type) continue
					if(scienceBlueprintListContainsType(GLOBAL_SCIENCE_TAB_ITEMS, technology.type) || scienceBlueprintListContainsType(individual_science_items, technology.type) || canUnlockTechnology(technology)) progression_nodes_owned[node.id] = 1
					break
			else if(node.category == "Mining" && node.branch == "Prospecting" && mining_level >= node.required_level)
				progression_nodes_owned[node.id] = 1
			else if(node.category == "Smithing" && node.branch == "Materials" && smithing_level >= node.required_level)
				progression_nodes_owned[node.id] = 1
		progression_nodes_owned["magic_attunement"] = magic_level >= 1 ? 1 : getProgressionNodeRank("magic_attunement")
		progression_nodes_owned["science_foundation"] = player_tech_level >= 1 ? 1 : getProgressionNodeRank("science_foundation")
		for(var/path_name in player_tech_paths) progression_nodes_owned["science_path_[lowertext(path_name)]"] = 1
		if(mining_level > 1 || profession_progression_version > 0) progression_nodes_owned["mining_prospector"] = 1
		if(smithing_level > 1 || profession_progression_version > 0) progression_nodes_owned["smithing_apprentice"] = 1
		progression_tree_version = NEXUS_PROGRESSION_VERSION
		if(!silent) src << "Your legacy Skill Points and learned abilities were migrated to Progression Trees."
	for(var/node_id in progression_node_catalog)
		var/datum/ProgressionNode/node = progression_node_catalog[node_id]
		if(node.reward_kind == "skill" && node.reward_type && hasExactProgressionRewardObject(node.reward_type)) progression_nodes_owned[node.id] = max(1, getProgressionNodeRank(node.id))
		if(hasProgressionNode(node.id)) applyProgressionNodeReward(node, announce = FALSE)
	if(progression_last_passive_realtime <= 0) progression_last_passive_realtime = world.realtime
	updatePassiveProgression(announce = !silent)

mob/proc/hasMiningOreUnlock(ore_type)
	if(progression_tree_version < NEXUS_PROGRESSION_VERSION) return TRUE
	switch(ore_type)
		if(/obj/items/Ore/Tin) return hasProgressionNode("mining_tin")
		if(/obj/items/Ore/Iron) return hasProgressionNode("mining_iron")
		if(/obj/items/Ore/Silver) return hasProgressionNode("mining_silver")
		if(/obj/items/Ore/Mythril) return hasProgressionNode("mining_mythril")
		if(/obj/items/Ore/Auracite) return hasProgressionNode("mining_auracite")
		if(/obj/items/Ore/HeartOfTheMountain) return hasProgressionNode("mining_heart")
	return hasProgressionNode("mining_prospector")

mob/proc/hasSmithingMaterialUnlock(material_id)
	if(progression_tree_version < NEXUS_PROGRESSION_VERSION) return TRUE
	if(material_id == "copper") return hasProgressionNode("smithing_apprentice")
	return hasProgressionNode("smithing_[material_id]")

mob/proc/getSmithingOreDiscount()
	return getMilestoneRank("master_blacksmith") + getProgressionNodeRank("smithing_resource_efficiency")

client/var/tmp/datum/NexusProgressionTreeWindow/nexus_progression_tree
client/var/tmp/list/progression_browser_icon_resources = list()

datum/NexusProgressionTreeWindow
	var/tmp
		mob/owner
		category = "Combat"
		branch_filter = "Foundation"
		search_query = ""

	New(mob/new_owner, initial_category = "Combat", initial_branch = "Foundation")
		. = ..()
		owner = new_owner
		category = initial_category
		branch_filter = initial_category == "Combat" ? initial_branch : getDefaultBranch(initial_category)

	Del()
		if(owner && owner.client)
			owner << browse(null, "window=NexusProgressionTrees")
			if(owner.client.nexus_progression_tree == src) owner.client.nexus_progression_tree = null
		owner = null
		. = ..()

	proc/canUse()
		return owner && owner.client && owner.playerCharacter && usr == owner

	proc/getNodeState(datum/ProgressionNode/node)
		var/rank = owner.getProgressionNodeRank(node.id)
		if(rank >= node.max_rank) return "owned"
		if(owner.getProgressionNodeLockReason(node)) return "locked"
		return "available"

	proc/buildNodeIcon(datum/ProgressionNode/node)
		if(!node.icon_file) return "<span class='fallback'>[html_encode(copytext(node.name, 1, 2))]</span>"
		var/icon_key = "[node.icon_file]|[node.icon_state]"
		var/resource_name = "progression_[md5(icon_key)].png"
		if(owner && owner.client && !islist(owner.client.progression_browser_icon_resources)) owner.client.progression_browser_icon_resources = list()
		if(owner && owner.client && !owner.client.progression_browser_icon_resources[resource_name])
			var/icon/node_icon = progression_browser_icon_cache[icon_key]
			if(!node_icon)
				node_icon = icon(node.icon_file, node.icon_state)
				progression_browser_icon_cache[icon_key] = node_icon
			owner << browse_rsc(node_icon, resource_name)
			owner.client.progression_browser_icon_resources[resource_name] = TRUE
		return "<img src='[resource_name]' alt=''>"

	proc/buildProgressionGraphNode(datum/ProgressionNode/node, node_x, node_y)
		var/state = getNodeState(node)
		var/rank = owner.getProgressionNodeRank(node.id)
		var/lock_reason = owner.getProgressionNodeLockReason(node)
		var/action = state == "available" ? "byond://?src=\ref[src]&action=purchase&node=[url_encode(node.id)]" : "#"
		var/requirement = lock_reason ? lock_reason : (state == "owned" ? "Completed" : "Ready to unlock")
		var/capstone_class = node.exclusive_group == "ultimate_buff" || node.tier >= 10 ? "capstone" : ""
		var/list/prerequisite_names = list()
		for(var/prerequisite_id in node.prerequisites)
			var/datum/ProgressionNode/prerequisite = progression_node_catalog[prerequisite_id]
			prerequisite_names += prerequisite ? prerequisite.name : "[prerequisite_id]"
		var/prerequisite_text = prerequisite_names.len ? jointext(prerequisite_names, " + ") : "None"
		var/prerequisite_html = prerequisite_names.len ? "<span class='node-requirements' title='Requires: [html_encode(prerequisite_text)]'>REQ: [html_encode(uppertext(prerequisite_text))]</span>" : ""
		return "<a class='tree-node [state] [capstone_class]' data-node-id='[html_encode(node.id)]' style='left:[node_x]px;top:[node_y]px' href='[action]'><span class='node-tier hud-panel'>T[node.tier]</span><span class='node-icon hud-sprite'>[buildNodeIcon(node)]</span><span class='node-cost hud-panel'>[node.cost] XP</span><b>[html_encode(node.name)]</b><span class='node-meta'>RANK [rank]/[node.max_rank]</span>[prerequisite_html]<span class='node-tip hud-panel'><strong>[html_encode(node.name)]</strong><small>[html_encode(node.description)]</small><em>Requires: [html_encode(prerequisite_text)]</em><em>[html_encode(requirement)]</em></span></a>"

	proc/buildMilestoneGraphNode(datum/MilestoneDefinition/milestone, node_x, node_y)
		var/rank = owner.getMilestoneRank(milestone.id)
		var/state = rank >= milestone.max_rank ? "owned" : "available"
		var/reason = owner.getMilestoneLockReason(milestone)
		if(reason) state = "locked"
		var/action = state == "available" ? "byond://?src=\ref[src]&action=milestone&node=[url_encode(milestone.id)]" : "#"
		var/status_text = reason
		if(!status_text) status_text = state == "owned" ? "Completed" : "Ready to unlock"
		return "<a class='tree-node [state]' style='left:[node_x]px;top:[node_y]px' href='[action]'><span class='node-tier hud-panel'>T[milestone.tier]</span><span class='node-icon hud-sprite'><span class='fallback'>M</span></span><b>[html_encode(milestone.name)]</b><span class='node-meta'>[rank]/[milestone.max_rank] · [milestone.cost] MP</span><span class='node-tip hud-panel'><strong>[html_encode(milestone.name)]</strong><small>[html_encode(milestone.description)]</small><em>[html_encode(status_text)]</em></span></a>"

	proc/buildMilestoneList()
		var/list/entries = collectVisibleEntries()
		if(!entries.len) return "<div class='empty'>No milestones matched this category or search.</div>"
		var/list_html = "<div class='milestone-list'>"
		for(var/datum/MilestoneDefinition/milestone in entries)
			var/rank = owner.getMilestoneRank(milestone.id)
			var/state = rank >= milestone.max_rank ? "owned" : "available"
			var/reason = owner.getMilestoneLockReason(milestone)
			if(reason) state = "locked"
			var/action = state == "available" ? "byond://?src=\ref[src]&action=milestone&node=[url_encode(milestone.id)]" : "#"
			var/status_text = reason ? reason : (state == "owned" ? "Completed" : "Ready to unlock")
			list_html += "<a class='milestone-card hud-card [state]' href='[action]'><strong>[html_encode(milestone.name)]</strong><small>[html_encode(milestone.description)]</small><span class='milestone-status'>[rank]/[milestone.max_rank] · [milestone.cost] MP · [html_encode(status_text)]</span></a>"
		list_html += "</div>"
		return list_html

	proc/getAvailableBranches(category_name = null)
		if(!category_name) category_name = category
		var/list/branches = list()
		if(category_name == "Milestones")
			return branches
		else if(category_name == "Racial")
			initializeProgressionTreeCatalog()
			var/racial_track = owner ? owner.getRacialProgressionTrack() : null
			if(racial_track)
				for(var/node_id in progression_node_catalog)
					var/datum/ProgressionNode/node = progression_node_catalog[node_id]
					if(node.category == "Racial" && node.branch == racial_track)
						branches += racial_track
						break
			return branches
		else
			initializeProgressionTreeCatalog()
			for(var/node_id in progression_node_catalog)
				var/datum/ProgressionNode/node = progression_node_catalog[node_id]
				if(node.category == category_name && !(node.branch in branches)) branches += node.branch
		return branches

	proc/getDefaultBranch(category_name)
		var/list/branches = getAvailableBranches(category_name)
		var/preferred_branch
		switch(category_name)
			if("Combat") preferred_branch = "Foundation"
			if("Science") preferred_branch = "Foundation"
			if("Magic") preferred_branch = "Divination"
			if("Mining") preferred_branch = "Extraction"
			if("Smithing") preferred_branch = "Forgecraft"
			if("Racial") preferred_branch = owner ? owner.getRacialProgressionTrack() : null
		if(preferred_branch in branches) return preferred_branch
		return branches.len ? branches[1] : ""

	proc/entryMatchesSearch(datum/entry)
		if(!search_query) return FALSE
		var/haystack = lowertext("[entry:name] [entry:description] [entry:branch]")
		return findtext(haystack, lowertext(search_query)) > 0

	proc/collectVisibleEntries()
		var/list/all_entries = list()
		var/list/all_entry_ids = list()
		if(category == "Milestones")
			initializeMilestoneCatalog()
			for(var/milestone_id in milestone_catalog)
				all_entry_ids += milestone_id
				all_entries[milestone_id] = milestone_catalog[milestone_id]
		else
			initializeProgressionTreeCatalog()
			for(var/node_id in progression_node_catalog)
				var/datum/ProgressionNode/node = progression_node_catalog[node_id]
				if(node.category != category) continue
				if(category == "Racial" && node.required_racial_track != owner.getRacialProgressionTrack()) continue
				all_entry_ids += node.id
				all_entries[node.id] = node
		var/list/included_ids = list()
		for(var/entry_id in all_entry_ids)
			var/datum/entry = all_entries[entry_id]
			if(category == "Milestones" && !search_query)
				included_ids[entry_id] = TRUE
			else if(search_query)
				if(entryMatchesSearch(entry)) included_ids[entry_id] = TRUE
			else if("[entry:branch]" == branch_filter)
				included_ids[entry_id] = TRUE
		var/found_ancestor = TRUE
		while(found_ancestor)
			found_ancestor = FALSE
			for(var/entry_id in all_entry_ids)
				if(!included_ids[entry_id]) continue
				var/datum/entry = all_entries[entry_id]
				var/list/prerequisites = entry:prerequisites
				if(!islist(prerequisites)) continue
				for(var/prerequisite_id in prerequisites)
					if(!all_entries[prerequisite_id] || included_ids[prerequisite_id]) continue
					included_ids[prerequisite_id] = TRUE
					found_ancestor = TRUE
		var/list/entries = list()
		for(var/entry_id in all_entry_ids)
			if(included_ids[entry_id]) entries += all_entries[entry_id]
		return entries

	proc/buildTreeNavigation()
		var/branch_html = ""
		for(var/branch_name in getAvailableBranches())
			var/state = !search_query && branch_name == branch_filter ? "active" : ""
			branch_html += "<a class='branch-tab hud-tab [state]' href='byond://?src=\ref[src]&action=filter&id=[url_encode(branch_name)]'>[html_encode(uppertext(branch_name))]</a>"
		var/clear_search = search_query ? "<a class='clear-search hud-button' href='byond://?src=\ref[src]&action=search&q='>CLEAR</a>" : ""
		var/search_status
		if(search_query)
			search_status = category == "Milestones" ? "Searching every Milestone for <b>[html_encode(search_query)]</b>" : "Searching every [html_encode(category)] branch for <b>[html_encode(search_query)]</b>"
		else
			search_status = category == "Milestones" ? "Showing every Milestone in one list" : "Showing <b>[html_encode(branch_filter)]</b>; choose another branch without rebuilding the whole catalog"
		var/tier_html = ""
		var/tier_label = "JUMP"
		if(category == "Milestones") tier_label = "ALL MILESTONES"
		else for(var/tier_number = 1, tier_number <= 10, tier_number++) tier_html += "<a class='hud-button' href='#' onclick='jumpTier([tier_number]);return false'>T[tier_number]</a>"
		var/branch_navigation = branch_html ? "<div class='branch-tabs'>[branch_html]</div>" : ""
		return "<div class='tree-tools'><form onsubmit='return runTreeSearch()'><input id='tree-search' maxlength='60' value='[html_encode(search_query)]' placeholder='Search skills, research or branch...'><button class='hud-button' type='submit'>SEARCH</button>[clear_search]</form><div class='tier-jumps'><span>[tier_label]</span>[tier_html]</div><div class='search-status hud-muted'>[search_status]</div></div>[branch_navigation]"

	proc/buildGraphLayout(list/entries)
		var/list/branches = list()
		var/list/branch_tier_counts = list()
		var/max_tier = 1
		for(var/datum/entry in entries)
			var/entry_tier = max(1, entry:tier)
			max_tier = max(max_tier, entry_tier)
			var/entry_branch = "[entry:branch]"
			if(!(entry_branch in branches)) branches += entry_branch
			var/count_key = "[entry_branch]|[entry_tier]"
			branch_tier_counts[count_key] = max(0, branch_tier_counts[count_key]) + 1

		var/list/branch_tops = list()
		var/list/branch_heights = list()
		var/list/branch_centers = list()
		var/next_top = 54
		for(var/branch in branches)
			var/largest_stack = 1
			for(var/tier_number = 1, tier_number <= max_tier, tier_number++) largest_stack = max(largest_stack, branch_tier_counts["[branch]|[tier_number]"])
			var/branch_height = max(150, largest_stack * NEXUS_PROGRESSION_STACK_SPACING + 46)
			branch_tops[branch] = next_top
			branch_heights[branch] = branch_height
			branch_centers[branch] = next_top + branch_height / 2
			next_top += branch_height + 18

		var/canvas_height = max(520, next_top + 30)
		var/canvas_width = max(980, 210 + max_tier * NEXUS_PROGRESSION_TIER_SPACING)
		var/list/positions = list()
		var/list/slot_indexes = list()
		for(var/datum/entry in entries)
			var/entry_id = "[entry:id]"
			var/entry_tier = max(1, entry:tier)
			var/entry_branch = "[entry:branch]"
			var/count_key = "[entry_branch]|[entry_tier]"
			var/slot_index = max(0, slot_indexes[count_key])
			slot_indexes[count_key] = slot_index + 1
			var/stack_count = max(1, branch_tier_counts[count_key])
			var/node_x = 70 + (entry_tier - 1) * NEXUS_PROGRESSION_TIER_SPACING
			var/node_y = branch_centers[entry_branch] - ((stack_count - 1) * NEXUS_PROGRESSION_STACK_SPACING) / 2 + slot_index * NEXUS_PROGRESSION_STACK_SPACING - NEXUS_PROGRESSION_NODE_HEIGHT / 2
			positions[entry_id] = list("x" = round(node_x), "y" = round(node_y))

		return list(
			"branches" = branches,
			"branch_tops" = branch_tops,
			"branch_heights" = branch_heights,
			"positions" = positions,
			"canvas_height" = canvas_height,
			"canvas_width" = canvas_width,
			"max_tier" = max_tier
		)

	proc/buildGraph()
		var/is_milestone_graph = category == "Milestones"
		if(is_milestone_graph) return buildMilestoneList()
		var/list/entries = collectVisibleEntries()
		if(!entries.len) return "<div class='empty'>No progression nodes matched this branch or search.</div>"

		var/list/layout = buildGraphLayout(entries)
		var/list/branches = layout["branches"]
		var/list/branch_tops = layout["branch_tops"]
		var/list/branch_heights = layout["branch_heights"]
		var/list/positions = layout["positions"]
		var/canvas_height = layout["canvas_height"]
		var/canvas_width = layout["canvas_width"]
		var/max_tier = layout["max_tier"]

		var/lane_html = ""
		for(var/branch in branches)
			lane_html += "<div class='branch-lane hud-panel' style='top:[round(branch_tops[branch])]px;height:[round(branch_heights[branch])]px'><span>[html_encode(branch)]</span></div>"
		var/tier_html = ""
		for(var/tier_number = 1, tier_number <= max_tier, tier_number++)
			var/tier_x = 70 + (tier_number - 1) * NEXUS_PROGRESSION_TIER_SPACING
			tier_html += "<div class='tier-marker' style='left:[tier_x]px'>TIER [tier_number]</div>"

		var/line_html = ""
		var/node_html = ""
		for(var/datum/entry in entries)
			var/entry_id = "[entry:id]"
			var/list/entry_position = positions[entry_id]
			var/list/entry_prerequisites = entry:prerequisites
			var/entry_state
			if(is_milestone_graph)
				var/datum/MilestoneDefinition/milestone = entry
				entry_state = owner.getMilestoneRank(milestone.id) >= milestone.max_rank ? "owned" : (owner.getMilestoneLockReason(milestone) ? "locked" : "available")
				node_html += buildMilestoneGraphNode(milestone, entry_position["x"], entry_position["y"])
			else
				var/datum/ProgressionNode/node = entry
				entry_state = getNodeState(node)
				node_html += buildProgressionGraphNode(node, entry_position["x"], entry_position["y"])
			if(!islist(entry_prerequisites)) continue
			for(var/prerequisite_id in entry_prerequisites)
				var/list/parent_position = positions["[prerequisite_id]"]
				if(!islist(parent_position)) continue
				var/safe_prerequisite_id = html_encode("[prerequisite_id]")
				var/safe_entry_id = html_encode(entry_id)
				var/x1 = parent_position["x"] + NEXUS_PROGRESSION_NODE_ICON_LEFT + NEXUS_PROGRESSION_NODE_ICON_SIZE
				var/y1 = parent_position["y"] + NEXUS_PROGRESSION_NODE_ICON_CENTER_Y
				var/x2 = entry_position["x"] + NEXUS_PROGRESSION_NODE_ICON_LEFT
				var/y2 = entry_position["y"] + NEXUS_PROGRESSION_NODE_ICON_CENTER_Y
				var/control_offset = round(max(36, abs(x2 - x1) * 0.42))
				line_html += "<path class='link [entry_state]' data-base-class='link [entry_state]' data-from='[safe_prerequisite_id]' data-to='[safe_entry_id]' d='M [x1] [y1] C [x1 + control_offset] [y1], [x2 - control_offset] [y2], [x2] [y2]'/>"
		return "<div class='graph-stage'><div class='pan-hint hud-panel'>CLICK + DRAG TO MOVE</div><div class='graph-wrap' tabindex='0' aria-label='Progression graph; click and drag to move'><div class='graph-canvas' style='width:[canvas_width]px;height:[canvas_height]px'>[lane_html][tier_html]<svg class='connections' width='[canvas_width]' height='[canvas_height]' viewBox='0 0 [canvas_width] [canvas_height]'>[line_html]</svg>[node_html]</div></div></div>"

	proc/buildHtml()
		owner.updatePassiveProgression()
		var/tabs = ""
		for(var/tab in list("Science", "Magic", "Mining", "Smithing", "Combat", "Racial", "Milestones"))
			var/tab_state = tab == category ? "active" : ""
			tabs += "<a class='tab hud-tab [tab_state]' href='byond://?src=\ref[src]&action=category&id=[tab]'>[uppertext(tab)]</a>"
		var/currency_label = category == "Milestones" ? "[owner.milestone_points] MILESTONE POINTS" : "[round(owner.progression_experience, 0.1)] PROGRESSION XP"
		var/tree_navigation = buildTreeNavigation()
		return {"<!doctype html><html><head><meta charset='utf-8'><title>Progression Trees</title><style>
		*{box-sizing:border-box}html,body{margin:0;min-height:100%;background:#070a0e;color:#e8edf2;font:12px Arial,sans-serif}body{background:radial-gradient(circle at 50% -10%,#26303b 0,#10161d 38%,#080b0f 72%);background-attachment:fixed}.shell{min-height:100vh}.header{position:sticky;top:0;z-index:5;border-bottom:1px solid #536170;background:rgba(8,12,17,.97);box-shadow:0 6px 18px #000;padding:12px 16px}.top{display:flex;align-items:center;gap:10px}.title{margin-right:auto}.title b{display:block;font:22px Georgia,serif;letter-spacing:2px;color:#f2f5f8}.title small{color:#8090a1;letter-spacing:.8px}.currency{padding:8px 12px;border:1px solid #d7a83e;background:#241c0b;color:#ffd970;font-weight:bold}.close{padding:8px 11px;border:1px solid #70474c;color:#ffaaa5;text-decoration:none}.tabs,.subtabs{display:flex;gap:5px;margin-top:10px}.tab,.subtab{padding:8px 12px;border:1px solid #354454;background:#101923;color:#8192a4;text-decoration:none;font-weight:bold}.tab.active,.subtab.active{border-color:#e0b341;background:#392b0c;color:#ffde79;box-shadow:inset 0 -2px #f4c64e}.subtabs{justify-content:center}.subtab{min-width:120px;text-align:center}.source{margin-top:9px;color:#718194;font-size:10px}.trees{display:flex;align-items:flex-start;justify-content:center;gap:18px;padding:20px;overflow-x:auto}.branch{min-width:270px;max-width:330px;flex:1}.branch h2{margin:0 0 12px;padding:10px;text-align:center;border:1px solid #556474;background:linear-gradient(#1b2530,#10171f);color:#d9e3ec;font:15px Georgia,serif;letter-spacing:1px}.rail{position:relative;padding:0 0 20px}.rail:before{content:'';position:absolute;left:38px;top:20px;bottom:40px;width:4px;background:linear-gradient(#e6b640,#9d6b17 70%,#343b42);box-shadow:0 0 8px #bd861f}.node{position:relative;display:grid;grid-template-columns:60px 1fr auto;gap:8px;min-height:92px;margin:0 0 14px;padding:9px 9px 9px 8px;border:1px solid #4d5a67;background:linear-gradient(135deg,#17212b,#0d131a);color:#dce5ed;text-decoration:none;box-shadow:0 4px 10px #000}.node:before{content:'';position:absolute;left:28px;top:-15px;width:22px;height:15px;border-left:4px solid #d9a62e;border-bottom:4px solid #d9a62e}.node:first-child:before{display:none}.node.available{border-color:#e2b33e;box-shadow:0 0 12px rgba(239,183,49,.34),0 4px 10px #000}.node.available:hover{background:linear-gradient(135deg,#29384a,#121c27);transform:translateY(-1px)}.node.owned{border-color:#d9ad3d;background:linear-gradient(135deg,#3a2d0d,#151612)}.node.locked{filter:grayscale(1);opacity:.53}.icon{position:relative;z-index:2;width:56px;height:56px;display:flex;align-items:center;justify-content:center;border:2px solid #be9131;background:#05070a;box-shadow:0 0 7px #000;overflow:hidden}.icon img{max-width:52px;max-height:52px;image-rendering:pixelated}.fallback{font:bold 20px Georgia,serif;color:#e6bb54}.copy{min-width:0}.copy b,.copy small,.copy em{display:block}.copy b{color:#ffe091;font-size:13px}.copy small{margin-top:5px;color:#aebac6;line-height:1.3;max-height:34px;overflow:hidden}.copy em{margin-top:6px;color:#7f91a2;font-size:9px;font-style:normal}.rank{align-self:start;padding:3px 5px;background:#05070a;color:#f2c34f;font-size:9px}.cost{position:absolute;right:7px;bottom:6px;color:#c99f3b;font-size:9px}.tier{position:absolute;left:72px;top:-7px;padding:1px 5px;background:#0a0e13;color:#6f8090;font-size:8px}.empty{padding:70px;text-align:center;color:#728191}@media(max-width:850px){.trees{justify-content:flex-start}.branch{min-width:280px}.tab{padding:7px 8px;font-size:10px}}
		.graph-stage{position:relative}.graph-wrap{height:calc(100vh - 210px);min-height:520px;padding:18px;overflow:hidden;cursor:move;user-select:none;-webkit-user-select:none}.graph-wrap.dragging{cursor:grabbing}.graph-wrap:focus{outline:1px solid #d2aa61;outline-offset:-3px}.pan-hint{position:absolute;z-index:40;right:28px;top:26px;padding:5px 8px;color:#d2aa61;font-size:9px;letter-spacing:1px;pointer-events:none}.graph-canvas{position:relative;margin:0 auto;border:1px solid #35414d;background:linear-gradient(rgba(255,255,255,.018) 1px,transparent 1px),linear-gradient(90deg,rgba(255,255,255,.018) 1px,transparent 1px),radial-gradient(circle at 35% 15%,rgba(50,75,93,.28),transparent 48%),#090d12;background-size:24px 24px,24px 24px,auto,auto;box-shadow:0 12px 32px #000}.branch-lane{position:absolute;z-index:0;left:8px;right:8px;border:1px solid rgba(91,112,130,.23);border-radius:18px;background:linear-gradient(90deg,rgba(27,39,49,.55),rgba(12,18,24,.2))}.branch-lane span{position:absolute;left:12px;top:8px;color:#667a8d;font:bold 10px Arial,sans-serif;letter-spacing:1.3px;text-transform:uppercase}.tier-marker{position:absolute;z-index:3;top:14px;width:122px;text-align:center;color:#708295;font:bold 9px Arial,sans-serif;letter-spacing:1.5px}.connections{position:absolute;z-index:1;left:0;top:0;overflow:visible;pointer-events:none}.link{fill:none;stroke:#3a4653;stroke-width:3;stroke-linecap:round;opacity:.72;transition:opacity .12s,stroke-width .12s}.link.locked{stroke:#2d353e}.link.available{stroke:#d8a938}.link.owned{stroke:#48c98c}.link.dimmed{opacity:.08}.link.focused{opacity:1;stroke-width:5;filter:drop-shadow(0 0 3px currentColor)}.tree-node{position:absolute;z-index:4;width:122px;min-height:[NEXUS_PROGRESSION_NODE_HEIGHT]px;text-align:center;color:#dce5ed;text-decoration:none}.node-icon{position:relative;display:flex;align-items:center;justify-content:center;width:58px;height:58px;margin:0 auto 9px;border:3px solid #485663;border-radius:50%;background:radial-gradient(circle,#1d2934,#05070a 72%);box-shadow:0 4px 10px #000;overflow:hidden}.node-icon img{max-width:52px;max-height:52px;image-rendering:pixelated}.node-cost{position:absolute;z-index:5;left:50%;top:47px;transform:translateX(-50%);min-width:45px;padding:2px 4px;border:1px solid #9a7440;color:#ffe091;font-size:10px;font-weight:bold;line-height:12px;white-space:nowrap}.tree-node b{display:block;height:28px;padding:0 2px;overflow:hidden;color:#d9e3ec;font-size:11px;line-height:13px;text-shadow:0 2px 2px #000}.node-meta{display:block;margin-top:1px;color:#9bafc1;font-size:9px}.node-requirements{display:block;margin:2px auto 0;max-width:118px;overflow:hidden;color:#d2aa61;font-size:8px;line-height:10px;text-overflow:ellipsis;white-space:nowrap}.node-tier{position:absolute;z-index:2;left:72px;top:-3px;padding:2px 5px;border:1px solid #485663;border-radius:8px;background:#080b0f;color:#8b9bad;font:bold 8px Arial,sans-serif}.tree-node.locked{filter:grayscale(1);opacity:.45}.tree-node.available .node-icon{border-color:#e0b341;box-shadow:0 0 13px rgba(224,179,65,.52),0 4px 10px #000}.tree-node.available:hover .node-icon{transform:scale(1.07);background:radial-gradient(circle,#3a321a,#080a0d 72%)}.tree-node.owned .node-icon{border-color:#48c98c;box-shadow:0 0 13px rgba(72,201,140,.45),0 4px 10px #000}.tree-node.owned .node-tier{border-color:#48c98c;color:#7fe9b7}.tree-node.capstone .node-icon{border-color:#ff4e9a;background:radial-gradient(circle,#4a1831,#09070b 72%);box-shadow:0 0 18px rgba(255,78,154,.65),0 4px 10px #000}.tree-node.capstone .node-tier{border-color:#ff4e9a;color:#ff86bb}.node-tip{display:none;position:absolute;z-index:30;left:126px;top:-8px;width:240px;padding:10px;border:1px solid #a78336;background:rgba(5,8,11,.98);box-shadow:0 8px 22px #000;text-align:left;pointer-events:none}.tree-node:hover{z-index:25}.tree-node:hover .node-tip{display:block}.node-tip strong,.node-tip small,.node-tip em{display:block}.node-tip strong{color:#ffe091;font-size:12px}.node-tip small{margin-top:6px;color:#b2bec9;line-height:1.35}.node-tip em{margin-top:7px;color:#d0a83e;font-size:10px;font-style:normal}
		.tree-tools{display:grid;grid-template-columns:minmax(360px,1fr) auto;gap:8px 14px;margin-top:10px;padding-top:9px;border-top:1px solid #2d3843}.tree-tools form{display:flex;gap:5px}.tree-tools input{width:100%;min-width:220px;padding:7px 9px}.tree-tools button,.clear-search{padding:7px 10px;text-decoration:none}.search-status{grid-column:1/-1;color:#8798a8;font-size:10px}.tier-jumps{display:flex;align-items:center;gap:3px}.tier-jumps span{margin-right:4px;color:#718194;font-size:9px}.tier-jumps a{padding:5px 6px;border:1px solid #3e4c59;background:#111922;color:#9eafbe;text-decoration:none;font-size:9px}.branch-tabs{display:flex;gap:5px;margin-top:8px;overflow-x:auto;padding-bottom:2px}.branch-tab{flex:0 0 auto;padding:6px 10px;border:1px solid #354454;background:#101923;color:#8192a4;text-decoration:none;font-size:10px;font-weight:bold}.branch-tab.active{border-color:#e0b341;background:#392b0c;color:#ffde79}.tree-node.capstone .node-tip{left:auto;right:126px}
		.milestone-list{display:grid;grid-template-columns:repeat(auto-fill,minmax(270px,1fr));gap:12px;padding:20px}.milestone-card{position:relative;min-height:142px;padding:14px 14px 34px;border:1px solid #4d5a67;background:linear-gradient(135deg,#17212b,#0d131a);color:#dce5ed;text-decoration:none;box-shadow:0 4px 10px #000}.milestone-card strong,.milestone-card small,.milestone-card .milestone-status{display:block}.milestone-card strong{color:#ffe091;font:16px Georgia,serif}.milestone-card small{margin-top:9px;color:#aebac6;line-height:1.4}.milestone-status{position:absolute;left:14px;right:14px;bottom:12px;color:#d0a83e;font-size:10px}.milestone-card.available{border-color:#e2b33e;box-shadow:0 0 12px rgba(239,183,49,.25),0 4px 10px #000}.milestone-card.available:hover{background:linear-gradient(135deg,#29384a,#121c27);transform:translateY(-1px)}.milestone-card.owned{border-color:#48c98c;background:linear-gradient(135deg,#173328,#101916)}.milestone-card.locked{filter:grayscale(1);opacity:.55}
		.branch-lane{border-radius:0!important}.node-icon{border-radius:0!important;box-shadow:0 4px 10px #000!important}.node-tier{border-radius:0!important}.tree-node.available .node-icon{outline-color:#e0b341!important;box-shadow:0 0 0 2px #e0b341,3px 3px 0 #000!important}.tree-node.owned .node-icon{outline-color:#48c98c!important;box-shadow:0 0 0 2px #48c98c,3px 3px 0 #000!important}.tree-node.capstone .node-icon{outline-color:#ff4e9a!important;box-shadow:0 0 0 2px #ff4e9a,3px 3px 0 #000!important}.node-tip{box-shadow:4px 4px 0 #000!important}.node-tip small{color:#b2bec9!important}.graph-canvas{border:2px solid #120d08;outline:1px solid #715735;background-color:#100d09}.header{margin:8px;padding:12px 16px}.currency{padding:8px 12px}.source{color:#bca47c}.tree-tools{border-top-color:#715735}
		[getNexusHudBrowserCss("bronze")]</style><script>
		var nexusGraphWrap=null,nexusPanActive=false,nexusPanMoved=false,nexusPanSuppressClick=false,nexusPanStartX=0,nexusPanStartY=0,nexusPanScrollX=0,nexusPanScrollY=0,nexusPanKey='nexusProgressionPan_[md5("[category]|[branch_filter]")]';
		function nexusSaveGraphPan(){if(!nexusGraphWrap)return;try{sessionStorage.setItem(nexusPanKey,nexusGraphWrap.scrollLeft+','+nexusGraphWrap.scrollTop);}catch(error){}}
		function runTreeSearch(){var q=document.getElementById('tree-search').value||'';window.location.href='byond://?src=\ref[src]&action=search&q='+encodeURIComponent(q);return false;}
		function jumpTier(tier){var wrap=document.querySelector('.graph-wrap');if(!wrap)return;wrap.scrollLeft=Math.max(0,70+(tier-1)*[NEXUS_PROGRESSION_TIER_SPACING]-wrap.clientWidth/2);nexusSaveGraphPan();}
		function nexusClearGraphConnections(){var links=document.querySelectorAll('.connections .link');for(var index=0;index<links.length;index++){var link=links.item(index);link.setAttribute('class',link.getAttribute('data-base-class'));}}
		function nexusFocusGraphConnections(nodeId){var links=document.querySelectorAll('.connections .link');for(var index=0;index<links.length;index++){var link=links.item(index),baseClass=link.getAttribute('data-base-class'),connected=link.getAttribute('data-from')===nodeId||link.getAttribute('data-to')===nodeId;link.setAttribute('class',baseClass+(connected?' focused':' dimmed'));}}
		function nexusInitGraphConnections(){var nodes=document.querySelectorAll('.tree-node');for(var index=0;index<nodes.length;index++){var node=nodes.item(index);if(!node.getAttribute('data-node-id'))continue;node.onmouseenter=function(){nexusFocusGraphConnections(this.getAttribute('data-node-id'));};node.onmouseleave=nexusClearGraphConnections;node.onfocus=function(){nexusFocusGraphConnections(this.getAttribute('data-node-id'));};node.onblur=nexusClearGraphConnections;}}
		function nexusInitGraphPan(){var wrap=document.querySelector('.graph-wrap');if(!wrap)return;nexusGraphWrap=wrap;try{var saved=sessionStorage.getItem(nexusPanKey);if(saved){var divider=saved.indexOf(',');if(divider>0){wrap.scrollLeft=parseInt(saved.substring(0,divider),10)||0;wrap.scrollTop=parseInt(saved.substring(divider+1),10)||0;}}}catch(error){}
		wrap.onmousedown=function(event){event=event||window.event;if(event.button!==0&&event.button!==1)return;nexusPanActive=true;nexusPanMoved=false;nexusPanStartX=event.clientX;nexusPanStartY=event.clientY;nexusPanScrollX=wrap.scrollLeft;nexusPanScrollY=wrap.scrollTop;wrap.className='graph-wrap dragging';wrap.focus();};
		document.onmousemove=function(event){if(!nexusPanActive)return;event=event||window.event;var deltaX=event.clientX-nexusPanStartX,deltaY=event.clientY-nexusPanStartY;if(Math.abs(deltaX)+Math.abs(deltaY)>4)nexusPanMoved=true;wrap.scrollLeft=nexusPanScrollX-deltaX;wrap.scrollTop=nexusPanScrollY-deltaY;if(nexusPanMoved){if(event.preventDefault)event.preventDefault();event.returnValue=false;}};
		document.onmouseup=function(){if(!nexusPanActive)return;nexusPanActive=false;nexusPanSuppressClick=nexusPanMoved;wrap.className='graph-wrap';nexusSaveGraphPan();};
		wrap.onclick=function(event){if(!nexusPanSuppressClick)return true;nexusPanSuppressClick=false;event=event||window.event;if(event.preventDefault)event.preventDefault();event.returnValue=false;return false;};
		wrap.ondragstart=function(){return false;};wrap.onkeydown=function(event){event=event||window.event;var key=event.keyCode,handled=true;if(key===37)wrap.scrollLeft-=64;else if(key===39)wrap.scrollLeft+=64;else if(key===38)wrap.scrollTop-=64;else if(key===40)wrap.scrollTop+=64;else handled=false;if(handled){nexusSaveGraphPan();if(event.preventDefault)event.preventDefault();event.returnValue=false;return false;}};}
		function nexusInitProgressionGraph(){nexusInitGraphPan();nexusInitGraphConnections();}
		if(window.addEventListener)window.addEventListener('load',nexusInitProgressionGraph,false);else if(window.attachEvent)window.attachEvent('onload',nexusInitProgressionGraph);
		</script></head><body class='nexus-hud'><div class='shell hud-shell'><div class='header hud-frame'><div class='top'><div class='title'><b class='hud-title'>PROGRESSION / [uppertext(category)]</b><small class='hud-muted'>Load one branch at a time / click + drag the canvas to navigate</small></div><span class='currency hud-panel hud-accent'>[currency_label]</span><a class='close hud-button danger' href='byond://?src=\ref[src]&action=close'>CLOSE</a></div><div class='tabs'>[tabs]</div><div class='source'>Earned: [round(owner.progression_chat_experience, 0.1)] from [owner.progression_roleplay_sessions_completed] roleplay sessions / [round(owner.progression_passive_experience, 0.1)] hourly online/offline / [round(owner.progression_lifetime_experience, 0.1)] lifetime / [owner.getProgressionHourlyExperience()] XP each elapsed hour</div>[tree_navigation]</div><main>[buildGraph()]</main></div></body></html>"}

	proc/show()
		if(!owner || !owner.client || !owner.playerCharacter)
			del(src)
			return
		prepareNexusHudBrowserResources(owner)
		owner << browse(buildHtml(), "window=NexusProgressionTrees;size=1280x820;can_resize=true;can_close=true")

	Topic(href, list/href_list)
		if(!canUse()) return
		switch(href_list["action"])
			if("category")
				if(href_list["id"] in list("Science", "Magic", "Mining", "Smithing", "Combat", "Racial", "Milestones"))
					category = href_list["id"]
					branch_filter = getDefaultBranch(category)
					search_query = ""
			if("filter")
				if(href_list["id"] in getAvailableBranches())
					branch_filter = href_list["id"]
					search_query = ""
			if("search")
				var/new_query = href_list["q"]
				search_query = copytext("[new_query]", 1, 61)
			if("purchase") owner.purchaseProgressionNode(href_list["node"])
			if("milestone") owner.purchaseMilestone(href_list["node"])
			if("close")
				del(src)
				return
		show()

mob/proc/showProgressionTrees(initial_category = "Combat", initial_branch = "Foundation")
	if(!client || !playerCharacter) return
	syncProgressionTrees(silent = TRUE)
	syncMilestoneProgression(silent = TRUE)
	if(client.nexus_progression_tree) del(client.nexus_progression_tree)
	client.nexus_progression_tree = new /datum/NexusProgressionTreeWindow(src, initial_category, initial_branch)
	client.nexus_progression_tree.show()

mob/proc/toggleProgressionTrees(initial_category = "Combat", initial_branch = "Foundation")
	if(!client || !playerCharacter) return
	var/datum/NexusProgressionTreeWindow/current_window = client.nexus_progression_tree
	if(current_window)
		var/current_is_milestones = current_window.category == "Milestones"
		var/request_is_milestones = initial_category == "Milestones"
		if(current_is_milestones == request_is_milestones)
			del(current_window)
			return
	showProgressionTrees(initial_category, initial_branch)

mob/verb/progressionTrees()
	set name = "Progression Trees"
	set category = "Other"
	showProgressionTrees()

#undef NEXUS_PASSIVE_PROGRESSION_INTERVAL
#undef NEXUS_PASSIVE_PROGRESSION_BASE_REWARD
#undef NEXUS_PROGRESSION_EXPERIENCE_SCALE
#undef NEXUS_PROGRESSION_EXPERIENCE_SCALE_VERSION
#undef NEXUS_ROLEPLAY_SESSION_IDLE_TIMEOUT
#undef NEXUS_ROLEPLAY_SESSION_PARTNER_WINDOW
#undef NEXUS_ROLEPLAY_SESSION_MINIMUM_DURATION
#undef NEXUS_ROLEPLAY_SESSION_MINIMUM_MESSAGES
#undef NEXUS_ROLEPLAY_SESSION_MINIMUM_WORDS
#undef NEXUS_ROLEPLAY_SESSION_REWARD
#undef NEXUS_PROGRESSION_NODE_WIDTH
#undef NEXUS_PROGRESSION_NODE_ICON_SIZE
#undef NEXUS_PROGRESSION_NODE_ICON_LEFT
#undef NEXUS_PROGRESSION_NODE_ICON_CENTER_Y
#undef NEXUS_PROGRESSION_NODE_HEIGHT
#undef NEXUS_PROGRESSION_TIER_SPACING
#undef NEXUS_PROGRESSION_STACK_SPACING
