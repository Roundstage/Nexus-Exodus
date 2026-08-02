var/list/magic_level_thresholds = list(0, 80, 220, 500, 900, 1450, 2200, 3200, 4500)
var/list/magic_research_catalog

datum/MagicResearchNode
	var
		id
		name
		description
		branch
		required_level = 1
		reward_type

	New(new_id, new_name, new_description, new_branch, new_level, new_reward_type)
		id = new_id
		name = new_name
		description = new_description
		branch = new_branch
		required_level = new_level
		reward_type = new_reward_type

proc/initializeMagicResearchCatalog()
	if(islist(magic_research_catalog) && magic_research_catalog.len) return
	magic_research_catalog = list()
	magic_research_catalog["arcane_sense"] = new /datum/MagicResearchNode("arcane_sense", "Arcane Sense", "Perceive the flow of living energy.", "Divination", 1, /obj/Sense)
	magic_research_catalog["telepathy"] = new /datum/MagicResearchNode("telepathy", "Telepathy", "Project speech directly into another mind.", "Divination", 2, /obj/Telepathy)
	magic_research_catalog["mending"] = new /datum/MagicResearchNode("mending", "Rejuvenation", "Channel energy to heal another being.", "Restoration", 3, /obj/Heal)
	magic_research_catalog["warding"] = new /datum/MagicResearchNode("warding", "Mystic Shield", "Shape energy into a sustained defensive ward.", "Warding", 4, /obj/Shield)
	magic_research_catalog["materialization"] = new /datum/MagicResearchNode("materialization", "Materialization", "Conjure matter through disciplined will.", "Conjuration", 5, /obj/Materialization)
	magic_research_catalog["force"] = new /datum/MagicResearchNode("force", "Magic Force", "Release arcane force as a radial shockwave.", "Evocation", 6, /obj/Attacks/Shockwave)
	magic_research_catalog["translocation"] = new /datum/MagicResearchNode("translocation", "Translocation", "Fold space to travel to a known destination.", "Conjuration", 7, /obj/Teleport)
	magic_research_catalog["grand_ward"] = new /datum/MagicResearchNode("grand_ward", "Grand Ward", "Project a defensive barrier around yourself.", "Warding", 8, /obj/Attacks/Attack_Barrier)
	magic_research_catalog["destruction"] = new /datum/MagicResearchNode("destruction", "Arcane Detonation", "Release destructive energy around a selected point.", "Evocation", 9, /obj/Attacks/Explosion)

mob/var
	magic_experience = 0
	magic_level = 1
	magic_training = FALSE
	list/magic_nodes_unlocked = list()
	magic_progression_version = 0

mob/proc/getMagicPotential()
	if(Race == "Makyo") return 1.6
	if(Race == "Namekian") return Class == "Ancient" ? 1.8 : 1.35
	if(Race == "Kanassan") return 1.35
	if(Race == "Kai") return 1.5
	if(Race == "Demon" || Race == "Majin") return 1.4
	if(Race == "Heran" || Race == "Tsujin" || Race == "Android") return 0.8
	return 1

proc/getMagicLevelForExperience(experience)
	var/level = 1
	for(var/index = 1, index <= magic_level_thresholds.len, index++)
		if(experience >= magic_level_thresholds[index]) level = index
	return level

mob/proc/gainMagicExperience(amount, reason, announce = FALSE)
	if(amount <= 0) return 0
	var/gained = amount * getMagicPotential()
	magic_experience += gained
	if(announce) src << "You gained [round(gained, 0.1)] Magic XP from [reason]."
	syncMagicProgression(silent = !announce)
	return gained

mob/proc/grantMagicResearchNode(datum/MagicResearchNode/node, announce = FALSE)
	if(!node || !node.reward_type) return FALSE
	if(!islist(magic_nodes_unlocked)) magic_nodes_unlocked = list()
	if(node.id in magic_nodes_unlocked) return FALSE
	magic_nodes_unlocked += node.id
	if(!(locate(node.reward_type) in src)) contents += new node.reward_type(src)
	if(announce) src << "<font color=#d99cff>Magic research unlocked: [node.name]."
	return TRUE

mob/proc/refreshMagicResearchUnlocks(announce = FALSE)
	initializeMagicResearchCatalog()
	for(var/node_id in magic_research_catalog)
		var/datum/MagicResearchNode/node = magic_research_catalog[node_id]
		if(magic_level >= node.required_level) grantMagicResearchNode(node, announce)

mob/proc/syncMagicProgression(silent = TRUE)
	magic_experience = max(0, magic_experience)
	var/old_level = max(1, magic_level)
	magic_level = max(magic_level, getMagicLevelForExperience(magic_experience))
	magic_progression_version = 1
	if(magic_level > old_level && !silent)
		src << "<font color=#d99cff>Your Magic Level increased to [magic_level]."
	refreshMagicResearchUnlocks(announce = !silent)
	return magic_level

mob/proc/showScienceResearchTree()
	syncTechnologyProgression(silent = TRUE)
	var/html = "<html><head><style>body{background:#130f0b;color:#ead7ae;font-family:monospace}h1,h2{color:#ffc45f}.branch{border:1px solid #805a2c;margin:8px;padding:8px}.open{color:#8fffa0}.locked{color:#777}</style></head><body>"
	html += "<h1>Science Tree</h1><p>Technology Level [player_tech_level]/[technology_level_thresholds.len] | XP [round(technology_experience, 0.1)] | Knowledge [round(Knowledge, 0.1)]</p>"
	html += "<p>Knowledge remains the source attribute. Crafting, mining, and smithing advance Technology XP; levels 5+ require a selected branch.</p>"
	var/list/branches = list("Foundation", "Engineering", "Robotics", "Genetics")
	for(var/branch in branches)
		html += "<div class='branch'><h2>[branch]</h2>"
		var/found
		for(var/obj/technology in tech_list)
			var/technology_branch = technology.science_path ? technology.science_path : "Foundation"
			if(technology_branch != branch) continue
			found = TRUE
			var/required_level = max(1, technology.science_level)
			var/access_class = canAccessTechnology(technology) ? "open" : "locked"
			html += "<div class='[access_class]'>L[required_level] - [html_encode(technology.name)] [canAccessTechnology(technology) ? "UNLOCKED" : "LOCKED"]</div>"
		if(!found) html += "<div class='locked'>No registered designs.</div>"
		html += "</div>"
	html += "<p>Use Choose Technology Path when a specialization slot is available.</p></body></html>"
	src << browse(html, "window=nexus_science_tree;size=860x700")

mob/proc/showMagicResearchTree()
	syncMagicProgression(silent = TRUE)
	initializeMagicResearchCatalog()
	var/html = "<html><head><style>body{background:#100d18;color:#e7d9ff;font-family:monospace}h1,h2{color:#d99cff}.branch{border:1px solid #664080;margin:8px;padding:8px}.open{color:#9fffc8}.locked{color:#777}</style></head><body>"
	html += "<h1>Magic Tree</h1><p>Magic Level [magic_level]/[magic_level_thresholds.len] | XP [round(magic_experience, 0.1)] | Potential x[round(getMagicPotential(), 0.05)]</p>"
	for(var/branch in list("Divination", "Restoration", "Warding", "Conjuration", "Evocation"))
		html += "<div class='branch'><h2>[branch]</h2>"
		for(var/node_id in magic_research_catalog)
			var/datum/MagicResearchNode/node = magic_research_catalog[node_id]
			if(node.branch != branch) continue
			var/unlocked = (node.id in magic_nodes_unlocked)
			html += "<div class='[unlocked ? "open" : "locked"]'>L[node.required_level] - [node.name]: [node.description] [unlocked ? "UNLOCKED" : "LOCKED"]</div>"
		html += "</div>"
	html += "<p>Select Meditation: Magic under Stat Focus to advance this tree.</p></body></html>"
	src << browse(html, "window=nexus_magic_tree;size=860x700")

mob/verb/researchTrees()
	set name = "Research Trees"
	set category = "Other"
	var/choice = input(src, "Open which progression tree?", "Research Trees") in list("Cancel", "Science", "Magic")
	if(choice == "Science") showScienceResearchTree()
	if(choice == "Magic") showMagicResearchTree()

mob/Admin4/verb/testResearchTrees(mob/character in players)
	set name = "Test Research Trees"
	set category = "Admin"
	var/choice = input(src, "Advance which tree for [character]?", "Research Test") in list("Cancel", "Science", "Magic", "Both")
	if(!choice || choice == "Cancel") return
	if(choice in list("Science", "Both"))
		character.technology_experience = technology_level_thresholds[technology_level_thresholds.len]
		character.syncTechnologyProgression(silent = FALSE)
	if(choice in list("Magic", "Both"))
		character.magic_experience = magic_level_thresholds[magic_level_thresholds.len]
		character.syncMagicProgression(silent = FALSE)
	src << "Advanced [character]'s [choice] research progression for testing."
