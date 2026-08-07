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
	// Divination
	magic_research_catalog["arcane_sense"] = new /datum/MagicResearchNode("arcane_sense", "Arcane Sense", "Perceive the flow of living energy.", "Divination", 1, /obj/Sense)
	magic_research_catalog["telepathy"] = new /datum/MagicResearchNode("telepathy", "Telepathy", "Project speech directly into another mind.", "Divination", 2, /obj/Telepathy)
	magic_research_catalog["magic_scanner"] = new /datum/MagicResearchNode("magic_scanner", "Magic Scanner", "Craft a lens that reads magic and mutation signatures.", "Divination", 4, /obj/Arcane_Crafting)
	magic_research_catalog["locator"] = new /datum/MagicResearchNode("locator", "Locator", "Craft a compass that locates visible souls in the same realm.", "Divination", 5, /obj/Arcane_Crafting)
	magic_research_catalog["crystal_ball"] = new /datum/MagicResearchNode("crystal_ball", "Crystal Ball", "Craft a focus for remote observation.", "Divination", 7, /obj/Arcane_Crafting)

	// Restoration
	magic_research_catalog["mending"] = new /datum/MagicResearchNode("mending", "Mending", "Channel native energy to heal another being.", "Restoration", 2, /obj/Heal)
	magic_research_catalog["rejuvenate"] = new /datum/MagicResearchNode("rejuvenate", "Rejuvenate", "Port the RPT restorative aura for nearby allies.", "Restoration", 4, /obj/ArcaneSpell/Rejuvenate)

	// Warding
	magic_research_catalog["warding"] = new /datum/MagicResearchNode("warding", "Mystic Shield", "Shape energy into a sustained defensive ward.", "Warding", 2, /obj/Shield)
	magic_research_catalog["empowered_defenses"] = new /datum/MagicResearchNode("empowered_defenses", "Empowered Defenses", "Ward nearby allies against incoming damage.", "Warding", 4, /obj/ArcaneSpell/EmpoweredDefenses)
	magic_research_catalog["grand_ward"] = new /datum/MagicResearchNode("grand_ward", "Grand Ward", "Project a defensive barrier around yourself.", "Warding", 7, /obj/Attacks/Attack_Barrier)

	// Evocation
	magic_research_catalog["fireball"] = new /datum/MagicResearchNode("fireball", "Fireball", "Hurl an explosive sphere of arcane fire.", "Evocation", 2, /obj/ArcaneSpell/Projectile/Fireball)
	magic_research_catalog["frost_bolt"] = new /datum/MagicResearchNode("frost_bolt", "Frost Bolt", "Launch a chilling projectile that can stun its target.", "Evocation", 3, /obj/ArcaneSpell/Projectile/FrostBolt)
	magic_research_catalog["lightning_bolt"] = new /datum/MagicResearchNode("lightning_bolt", "Lightning Bolt", "Cast a fast, high-impact bolt of lightning.", "Evocation", 4, /obj/ArcaneSpell/Projectile/LightningBolt)
	magic_research_catalog["frost_nova"] = new /datum/MagicResearchNode("frost_nova", "Frost Nova", "Freeze and damage enemies around the caster.", "Evocation", 5, /obj/ArcaneSpell/FrostNova)
	magic_research_catalog["force"] = new /datum/MagicResearchNode("force", "Magic Force", "Release arcane force as a radial shockwave.", "Evocation", 6, /obj/Attacks/Shockwave)
	magic_research_catalog["destruction"] = new /datum/MagicResearchNode("destruction", "Arcane Detonation", "Release destructive energy around a selected point.", "Evocation", 9, /obj/Attacks/Explosion)

	// Conjuration
	magic_research_catalog["materialization"] = new /datum/MagicResearchNode("materialization", "Materialization", "Conjure matter through disciplined will.", "Conjuration", 2, /obj/Materialization)
	magic_research_catalog["earth_prison"] = new /datum/MagicResearchNode("earth_prison", "Earth Prison", "Raise a temporary ring of earthen walls.", "Conjuration", 4, /obj/ArcaneSpell/EarthPrison)
	magic_research_catalog["gravity_well"] = new /datum/MagicResearchNode("gravity_well", "Gravity Well", "Conjure a temporary high-gravity field.", "Conjuration", 6, /obj/ArcaneSpell/GravityWell)
	magic_research_catalog["translocation"] = new /datum/MagicResearchNode("translocation", "Translocation", "Fold space to travel to a known destination.", "Conjuration", 7, /obj/Teleport)
	magic_research_catalog["create_portal"] = new /datum/MagicResearchNode("create_portal", "Create Portal", "Bind an anchor and open a temporary two-way portal.", "Conjuration", 9, /obj/ArcaneSpell/CreatePortal)

	// Enchantment
	magic_research_catalog["boxing_gloves"] = new /datum/MagicResearchNode("boxing_gloves", "Boxing Gloves", "Craft enchanted gloves for controlled sparring.", "Enchantment", 2, /obj/Arcane_Crafting)
	magic_research_catalog["magic_sword"] = new /datum/MagicResearchNode("magic_sword", "Magic Sword", "Forge a copper blade through an arcane ritual.", "Enchantment", 3, /obj/Arcane_Crafting)
	magic_research_catalog["magic_armor"] = new /datum/MagicResearchNode("magic_armor", "Magic Armor", "Forge copper armor through an arcane ritual.", "Enchantment", 3, /obj/Arcane_Crafting)
	magic_research_catalog["door_pass"] = new /datum/MagicResearchNode("door_pass", "Magic Door Pass", "Craft a configurable arcane access token.", "Enchantment", 3, /obj/Arcane_Crafting)
	magic_research_catalog["magic_hammer"] = new /datum/MagicResearchNode("magic_hammer", "Magic Hammer", "Forge an enchanted war hammer.", "Enchantment", 4, /obj/Arcane_Crafting)
	magic_research_catalog["magic_gauntlets"] = new /datum/MagicResearchNode("magic_gauntlets", "Magic Gauntlets", "Craft a focus that improves Magic training.", "Enchantment", 4, /obj/Arcane_Crafting)
	magic_research_catalog["empowered_attacks"] = new /datum/MagicResearchNode("empowered_attacks", "Empowered Attacks", "Empower the attacks of nearby allies.", "Enchantment", 5, /obj/ArcaneSpell/EmpoweredAttacks)
	magic_research_catalog["accelerate"] = new /datum/MagicResearchNode("accelerate", "Accelerate", "Temporarily hasten movement and combat cadence.", "Enchantment", 5, /obj/ArcaneSpell/Accelerate)
	magic_research_catalog["disguise"] = new /datum/MagicResearchNode("disguise", "Disguise", "Craft a reusable glamour veil.", "Enchantment", 5, /obj/Arcane_Crafting)
	magic_research_catalog["enchant"] = new /datum/MagicResearchNode("enchant", "Enchant", "Imbue forged equipment with arcane masterwork quality.", "Enchantment", 6, /obj/ArcaneSpell/Enchant)
	magic_research_catalog["upgrade_kit"] = new /datum/MagicResearchNode("upgrade_kit", "Upgrade Kit", "Bottle one permanent equipment enchantment.", "Enchantment", 7, /obj/Arcane_Crafting)

	// Constructs
	magic_research_catalog["magic_dummy"] = new /datum/MagicResearchNode("magic_dummy", "Magic Dummy", "Create a basic sparring construct.", "Constructs", 2, /obj/Arcane_Crafting)
	magic_research_catalog["magic_door"] = new /datum/MagicResearchNode("magic_door", "Magic Door", "Create a password-secured arcane door.", "Constructs", 4, /obj/Arcane_Crafting)
	magic_research_catalog["mana_pylon"] = new /datum/MagicResearchNode("mana_pylon", "Mana Pylon", "Build a focus that amplifies nearby essence gathering.", "Constructs", 5, /obj/Arcane_Crafting)
	magic_research_catalog["magic_vault"] = new /datum/MagicResearchNode("magic_vault", "Magic Vault", "Build a protected reservoir for Arcane Essence.", "Constructs", 6, /obj/Arcane_Crafting)
	magic_research_catalog["enchanted_doll"] = new /datum/MagicResearchNode("enchanted_doll", "Enchanted Doll", "Create a temporary arcane companion.", "Constructs", 7, /obj/Arcane_Crafting)

	// Artifacts
	magic_research_catalog["spell_book"] = new /datum/MagicResearchNode("spell_book", "Spell Book", "Craft a grimoire linked to the Magic tree.", "Artifacts", 2, /obj/Arcane_Crafting)
	magic_research_catalog["utility_belt"] = new /datum/MagicResearchNode("utility_belt", "Utility Belt", "Create a compact pocket-space container.", "Artifacts", 3, /obj/Arcane_Crafting)
	magic_research_catalog["book_case"] = new /datum/MagicResearchNode("book_case", "Book Case", "Create a portable enchanted book case.", "Artifacts", 3, /obj/Arcane_Crafting)
	magic_research_catalog["cooking_bag"] = new /datum/MagicResearchNode("cooking_bag", "Cooking Bag", "Create an expanded pocket-space cooking bag.", "Artifacts", 4, /obj/Arcane_Crafting)
	magic_research_catalog["simulation_crystal"] = new /datum/MagicResearchNode("simulation_crystal", "Simulation Crystal", "Bind the native simulator design into a crystal focus.", "Artifacts", 5, /obj/Arcane_Crafting)
	magic_research_catalog["orb_of_mastery"] = new /datum/MagicResearchNode("orb_of_mastery", "Orb of Mastery", "Craft an artifact that improves Magic training.", "Artifacts", 6, /obj/Arcane_Crafting)
	magic_research_catalog["book_lessons"] = new /datum/MagicResearchNode("book_lessons", "Book of Lessons", "Record knowledge that grants Progression XP once.", "Artifacts", 7, /obj/Arcane_Crafting)
	magic_research_catalog["book_fortitude"] = new /datum/MagicResearchNode("book_fortitude", "Book of Fortitude", "Record a long-lasting defensive ward.", "Artifacts", 7, /obj/Arcane_Crafting)
	magic_research_catalog["book_ages"] = new /datum/MagicResearchNode("book_ages", "Book of Ages", "Create a dangerous grimoire that trades age for talent.", "Artifacts", 8, /obj/Arcane_Crafting)
	magic_research_catalog["book_power"] = new /datum/MagicResearchNode("book_power", "Book of Power", "Create a one-use grimoire of permanent growth.", "Artifacts", 9, /obj/Arcane_Crafting)
	magic_research_catalog["shikon_jewel"] = new /datum/MagicResearchNode("shikon_jewel", "Shikon Jewel", "Perform a master ritual to create the ancient jewel that amplifies its bearer's power.", "Artifacts", 9, /obj/Arcane_Crafting)

	// Alchemy
	magic_research_catalog["arcane_crafting"] = new /datum/MagicResearchNode("arcane_crafting", "Arcane Crafting", "Shape Arcane Essence into persistent magical constructs.", "Alchemy", 2, /obj/Arcane_Crafting)
	magic_research_catalog["magic_goo_1"] = new /datum/MagicResearchNode("magic_goo_1", "Magic Goo I", "Create the first tier of magical sparring construct.", "Alchemy", 3, /obj/Arcane_Crafting)
	magic_research_catalog["magic_fishing_lure"] = new /datum/MagicResearchNode("magic_fishing_lure", "Magic Fishing Lure", "Distill a lure that draws magic from water.", "Alchemy", 3, /obj/Arcane_Crafting)
	magic_research_catalog["magic_circle"] = new /datum/MagicResearchNode("magic_circle", "Magic Circle", "Create a portable ritual focus that amplifies Arcane Essence gathering.", "Alchemy", 4, /obj/Arcane_Crafting)
	magic_research_catalog["elixir_health"] = new /datum/MagicResearchNode("elixir_health", "Elixir of Health", "Brew a temporary regeneration catalyst.", "Alchemy", 4, /obj/Arcane_Crafting)
	magic_research_catalog["magic_goo_2"] = new /datum/MagicResearchNode("magic_goo_2", "Magic Goo II", "Reinforce Magic Goo with ore and denser essence.", "Alchemy", 5, /obj/Arcane_Crafting)
	magic_research_catalog["elixir_replenishment"] = new /datum/MagicResearchNode("elixir_replenishment", "Elixir of Replenishment", "Brew a temporary energy-recovery catalyst.", "Alchemy", 5, /obj/Arcane_Crafting)
	magic_research_catalog["stone_of_understanding"] = new /datum/MagicResearchNode("stone_of_understanding", "Stone of Understanding", "Enchant a stone that translates every spoken language for its bearer.", "Alchemy", 5, /obj/Arcane_Crafting)
	magic_research_catalog["transmutation_circle"] = new /datum/MagicResearchNode("transmutation_circle", "Transmutation Circle", "Perform equivalent exchanges between resources, essence and ores.", "Alchemy", 6, /obj/Arcane_Crafting)
	magic_research_catalog["elixir_merriment"] = new /datum/MagicResearchNode("elixir_merriment", "Elixir of Merriment", "Brew a tonic that improves roleplay XP gains.", "Alchemy", 6, /obj/Arcane_Crafting)
	magic_research_catalog["magic_goo_3"] = new /datum/MagicResearchNode("magic_goo_3", "Magic Goo III", "Create an advanced mythril-bound magical sparring construct.", "Alchemy", 7, /obj/Arcane_Crafting)
	magic_research_catalog["elixir_empowerment"] = new /datum/MagicResearchNode("elixir_empowerment", "Elixir of Empowerment", "Brew a one-use restorative progression catalyst.", "Alchemy", 7, /obj/Arcane_Crafting)
	magic_research_catalog["magic_goo_4"] = new /datum/MagicResearchNode("magic_goo_4", "Magic Goo IV", "Create the peak auracite-bound magical sparring construct.", "Alchemy", 8, /obj/Arcane_Crafting)
	magic_research_catalog["elixir_life"] = new /datum/MagicResearchNode("elixir_life", "Elixir of Life", "Brew a permanent life-extension draught.", "Alchemy", 8, /obj/Arcane_Crafting)
	magic_research_catalog["philosophers_stone"] = new /datum/MagicResearchNode("philosophers_stone", "Philosopher's Stone", "Use a master transmutation circle and Heart of the Mountain to create the ultimate catalyst.", "Alchemy", 9, /obj/Arcane_Crafting)
	magic_research_catalog["elixir_reformation"] = new /datum/MagicResearchNode("elixir_reformation", "Elixir of Reformation", "Brew a dangerous draught that resets native mutations and stat allocation.", "Alchemy", 9, /obj/Arcane_Crafting)

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
	var/gained = amount * getMagicPotential() * (1 + getMilestoneRank("arcane_memory") * 0.1)
	if(locate(/obj/items/ArcaneFocusGauntlets) in item_list) gained *= 1.05
	if(locate(/obj/items/ArcaneOrbOfMastery) in item_list) gained *= 1.1
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
		if(progression_tree_version >= 1)
			if(hasProgressionNode("magic_[node.id]")) grantMagicResearchNode(node, announce)
		else if(magic_level >= node.required_level) grantMagicResearchNode(node, announce)

mob/proc/migrateShikonResearch()
	if(magic_progression_version >= 2) return FALSE
	if(!islist(progression_nodes_owned)) progression_nodes_owned = list()
	var/legacy_node_id = getProgressionScienceNodeIdForType(/obj/items/Shikon_Jewel)
	var/had_legacy_research = getProgressionNodeRank(legacy_node_id) > 0 || scienceBlueprintListContainsType(individual_science_items, /obj/items/Shikon_Jewel)
	progression_nodes_owned -= legacy_node_id
	if(islist(individual_science_items))
		var/list/retained_blueprints = list()
		for(var/obj/blueprint in individual_science_items)
			if(blueprint.type != /obj/items/Shikon_Jewel) retained_blueprints += blueprint
		individual_science_items = retained_blueprints
	if(had_legacy_research) progression_nodes_owned["magic_shikon_jewel"] = max(1, getProgressionNodeRank("magic_shikon_jewel"))
	magic_progression_version = 2
	return had_legacy_research

mob/proc/syncMagicProgression(silent = TRUE)
	migrateShikonResearch()
	magic_experience = max(0, magic_experience)
	var/old_level = max(1, magic_level)
	magic_level = max(magic_level, getMagicLevelForExperience(magic_experience))
	magic_progression_version = 2
	if(magic_level > old_level && !silent)
		src << "<font color=#d99cff>Your Magic Level increased to [magic_level]."
	refreshMagicResearchUnlocks(announce = !silent)
	return magic_level

mob/proc/showScienceResearchTree()
	showProgressionTrees("Science")

mob/proc/showMagicResearchTree()
	showProgressionTrees("Magic")

mob/verb/researchTrees()
	set name = "Research Trees"
	set category = "Other"
	showProgressionTrees("Science")

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
