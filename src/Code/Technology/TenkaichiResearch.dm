#define NEXUS_ARCANE_CIRCLE_RANGE 2

mob/var
	arcane_essence = 0
	arcane_essence_lifetime = 0

mob/proc/gainArcaneEssence(amount, reason = "arcane practice", announce = FALSE)
	if(amount <= 0) return 0
	var/gained = round(amount * getMagicPotential(), 0.1)
	arcane_essence += gained
	arcane_essence_lifetime += gained
	if(announce) src << "<font color=#c88cff>You gathered [gained] Arcane Essence from [reason]."
	return gained

mob/proc/getArcaneCircleTier()
	var/highest_tier = 0
	for(var/obj/items/MagicCircle/circle in item_list)
		highest_tier = max(highest_tier, circle.circle_tier)
	for(var/obj/items/MagicCircle/circle in range(NEXUS_ARCANE_CIRCLE_RANGE, src))
		highest_tier = max(highest_tier, circle.circle_tier)
	return highest_tier

mob/proc/getArcaneMeditationMultiplier()
	var/multiplier = 1
	switch(getArcaneCircleTier())
		if(2 to 1.#INF) multiplier = 2
		if(1) multiplier = 1.5
	for(var/obj/items/ManaPylon/pylon in range(5, src))
		if(pylon)
			multiplier *= 1.25
			break
	return multiplier

mob/proc/getPhilosophersStoneRegenerationBonus()
	if(locate(/obj/items/PhilosophersStone) in item_list) return 0.5
	return 0

mob/proc/getArcaneCraftLockReason(node_id, essence_cost, required_circle_tier = 0)
	syncProgressionTrees(silent = TRUE)
	if(!hasProgressionNode(node_id)) return "Unlock this formula in the Magic progression tree first."
	if(required_circle_tier && getArcaneCircleTier() < required_circle_tier)
		return "This ritual requires a tier [required_circle_tier] magic circle in your inventory or within [NEXUS_ARCANE_CIRCLE_RANGE] tiles."
	if(arcane_essence < essence_cost) return "Requires [essence_cost] Arcane Essence; you have [round(arcane_essence, 0.1)]."
	return null

datum/ArcaneFormula
	var
		id
		display_name
		description
		construct_type
		essence_cost = 0
		ore_type
		ore_cost = 0
		required_circle_tier = 0
		create_in_inventory = TRUE

	New(new_id, new_name, new_description, new_construct_type, new_essence_cost, new_ore_type = null, new_ore_cost = 0, new_circle_tier = 0, new_in_inventory = TRUE)
		id = new_id
		display_name = new_name
		description = new_description
		construct_type = new_construct_type
		essence_cost = new_essence_cost
		ore_type = new_ore_type
		ore_cost = new_ore_cost
		required_circle_tier = new_circle_tier
		create_in_inventory = new_in_inventory

var/list/arcane_formula_catalog

proc/registerArcaneFormula(datum/ArcaneFormula/formula)
	if(!formula || !formula.id) return
	if(!islist(arcane_formula_catalog)) arcane_formula_catalog = list()
	arcane_formula_catalog[formula.id] = formula
	return formula

proc/initializeArcaneFormulaCatalog()
	if(islist(arcane_formula_catalog) && arcane_formula_catalog.len) return
	arcane_formula_catalog = list()
	registerArcaneFormula(new /datum/ArcaneFormula("magic_goo_1", "Magic Goo I", "A basic magical sparring construct.", /obj/Peebag/MagicGoo, 30, null, 0, 0, FALSE))
	registerArcaneFormula(new /datum/ArcaneFormula("magic_goo_2", "Magic Goo II", "A copper-reinforced magical sparring construct.", /obj/Peebag/MagicGoo/Tier2, 75, /obj/items/Ore/Copper, 1, 0, FALSE))
	registerArcaneFormula(new /datum/ArcaneFormula("magic_goo_3", "Magic Goo III", "A mythril-bound magical sparring construct.", /obj/Peebag/MagicGoo/Tier3, 150, /obj/items/Ore/Mythril, 1, 1, FALSE))
	registerArcaneFormula(new /datum/ArcaneFormula("magic_goo_4", "Magic Goo IV", "The peak auracite-bound magical sparring construct.", /obj/Peebag/MagicGoo/Tier4, 300, /obj/items/Ore/Auracite, 1, 2, FALSE))
	registerArcaneFormula(new /datum/ArcaneFormula("boxing_gloves", "Boxing Gloves", "Enchanted gloves for controlled sparring.", /obj/items/ArcaneBoxingGloves, 35))
	registerArcaneFormula(new /datum/ArcaneFormula("magic_armor", "Magic Armor", "Copper armor assembled by ritual.", /obj/items/Armor/Forged/ArcaneArmor, 90, /obj/items/Ore/Copper, 3))
	registerArcaneFormula(new /datum/ArcaneFormula("magic_sword", "Magic Sword", "A copper blade assembled by ritual.", /obj/items/Sword/Forged/ArcaneSword, 80, /obj/items/Ore/Copper, 3))
	registerArcaneFormula(new /datum/ArcaneFormula("magic_gauntlets", "Magic Gauntlets", "A focus that improves Magic training.", /obj/items/ArcaneFocusGauntlets, 100, /obj/items/Ore/Silver, 1))
	registerArcaneFormula(new /datum/ArcaneFormula("magic_dummy", "Magic Dummy", "A basic punching dummy animated by magic.", /obj/Peebag, 45, null, 0, 0, FALSE))
	registerArcaneFormula(new /datum/ArcaneFormula("door_pass", "Magic Door Pass", "An arcane access token compatible with native doors.", /obj/items/Door_Pass, 40))
	registerArcaneFormula(new /datum/ArcaneFormula("magic_hammer", "Magic Hammer", "A copper war hammer assembled by ritual.", /obj/items/Sword/Forged/MagicHammer, 90, /obj/items/Ore/Copper, 3))
	registerArcaneFormula(new /datum/ArcaneFormula("mana_pylon", "Mana Pylon", "A stationary amplifier for nearby essence gathering.", /obj/items/ManaPylon, 160, /obj/items/Ore/Silver, 2, 1, FALSE))
	registerArcaneFormula(new /datum/ArcaneFormula("spell_book", "Spell Book", "A grimoire linked to the Magic tree.", /obj/items/SpellBook, 45))
	registerArcaneFormula(new /datum/ArcaneFormula("utility_belt", "Utility Belt", "A compact pocket-space container.", /obj/items/ArcaneSatchel, 60))
	registerArcaneFormula(new /datum/ArcaneFormula("book_case", "Book Case", "A portable enchanted book case.", /obj/items/ArcaneSatchel/Bookcase, 65))
	registerArcaneFormula(new /datum/ArcaneFormula("magic_door", "Magic Door", "A password-secured arcane door.", /obj/Turfs/Door/ArcaneDoor, 120, /obj/items/Ore/Silver, 1, 1, FALSE))
	registerArcaneFormula(new /datum/ArcaneFormula("simulation_crystal", "Simulation Crystal", "A native combat simulator bound into crystal.", /obj/items/Simulator/ArcaneCrystal, 150, /obj/items/Ore/Silver, 2))
	registerArcaneFormula(new /datum/ArcaneFormula("magic_scanner", "Magic Scanner", "A lens that reads aptitude, essence and mutation signatures.", /obj/items/MagicScanner, 80))
	registerArcaneFormula(new /datum/ArcaneFormula("locator", "Locator", "A compass that locates visible souls in the same realm.", /obj/items/ArcaneLocator, 120, /obj/items/Ore/Silver, 1))
	registerArcaneFormula(new /datum/ArcaneFormula("disguise", "Disguise", "A reusable glamour veil.", /obj/items/ArcaneDisguise, 110, /obj/items/Ore/Silver, 1))
	registerArcaneFormula(new /datum/ArcaneFormula("stone_of_understanding", "Stone of Understanding", "A universal magical translator.", /obj/items/StoneOfUnderstanding, 180, /obj/items/Ore/Silver, 2, 1))
	registerArcaneFormula(new /datum/ArcaneFormula("magic_fishing_lure", "Magic Fishing Lure", "A consumable lure that gathers essence near water.", /obj/items/MagicFishingLure, 25))
	registerArcaneFormula(new /datum/ArcaneFormula("orb_of_mastery", "Orb of Mastery", "A focus that greatly improves Magic training.", /obj/items/ArcaneOrbOfMastery, 200, /obj/items/Ore/Mythril, 1, 1))
	registerArcaneFormula(new /datum/ArcaneFormula("cooking_bag", "Cooking Bag", "An expanded pocket-space container.", /obj/items/ArcaneSatchel/CookingBag, 100))
	registerArcaneFormula(new /datum/ArcaneFormula("enchanted_doll", "Enchanted Doll", "A shell for a temporary arcane companion.", /obj/items/EnchantedDoll, 220, /obj/items/Ore/Mythril, 1, 1))
	registerArcaneFormula(new /datum/ArcaneFormula("elixir_health", "Elixir of Health", "Triples natural regeneration for five minutes.", /obj/items/ArcaneElixir/Health, 60))
	registerArcaneFormula(new /datum/ArcaneFormula("upgrade_kit", "Upgrade Kit", "Applies arcane masterwork quality to forged equipment.", /obj/items/ArcaneUpgradeKit, 220, /obj/items/Ore/Auracite, 1, 1))
	registerArcaneFormula(new /datum/ArcaneFormula("magic_vault", "Magic Vault", "A password-protected Arcane Essence reservoir.", /obj/items/MagicVault, 180, /obj/items/Ore/Silver, 2, 1, FALSE))
	registerArcaneFormula(new /datum/ArcaneFormula("elixir_life", "Elixir of Life", "Permanently extends decline age once.", /obj/items/ArcaneElixir/Life, 300, /obj/items/Ore/Mythril, 1, 2))
	registerArcaneFormula(new /datum/ArcaneFormula("elixir_empowerment", "Elixir of Empowerment", "Fully restores and grants Progression XP once.", /obj/items/ArcaneElixir/Empowerment, 200, /obj/items/Ore/Mythril, 1, 1))
	registerArcaneFormula(new /datum/ArcaneFormula("elixir_replenishment", "Elixir of Replenishment", "Doubles natural energy recovery for five minutes.", /obj/items/ArcaneElixir/Replenishment, 75))
	registerArcaneFormula(new /datum/ArcaneFormula("elixir_merriment", "Elixir of Merriment", "Improves roleplay and chat XP for ten minutes.", /obj/items/ArcaneElixir/Merriment, 90))
	registerArcaneFormula(new /datum/ArcaneFormula("crystal_ball", "Crystal Ball", "A focus for remote observation.", /obj/items/CrystalBall, 250, /obj/items/Ore/Mythril, 1, 2))
	registerArcaneFormula(new /datum/ArcaneFormula("book_lessons", "Book of Lessons", "A one-use grimoire of Progression XP.", /obj/items/ArcaneBook/Lessons, 180, /obj/items/Ore/Silver, 1, 1))
	registerArcaneFormula(new /datum/ArcaneFormula("book_fortitude", "Book of Fortitude", "A one-use long-lasting defensive ward.", /obj/items/ArcaneBook/Fortitude, 200, /obj/items/Ore/Silver, 1, 1))
	registerArcaneFormula(new /datum/ArcaneFormula("book_ages", "Book of Ages", "Trades physical age for one Milestone Point.", /obj/items/ArcaneBook/Ages, 300, /obj/items/Ore/Mythril, 1, 2))
	registerArcaneFormula(new /datum/ArcaneFormula("book_power", "Book of Power", "A one-use permanent growth grimoire.", /obj/items/ArcaneBook/Power, 450, /obj/items/Ore/Auracite, 1, 2))
	registerArcaneFormula(new /datum/ArcaneFormula("shikon_jewel", "Shikon Jewel", "An ancient jewel that amplifies the bearer's power.", /obj/items/Shikon_Jewel, 750, /obj/items/Ore/Auracite, 3, 2))
	registerArcaneFormula(new /datum/ArcaneFormula("elixir_reformation", "Elixir of Reformation", "Resets native mutations and stat allocation.", /obj/items/ArcaneElixir/Reformation, 400, /obj/items/Ore/Auracite, 1, 2))
	registerArcaneFormula(new /datum/ArcaneFormula("magic_circle", "Magic Circle", "A portable ritual focus.", /obj/items/MagicCircle, 120, /obj/items/Ore/Silver, 2, 0, FALSE))
	registerArcaneFormula(new /datum/ArcaneFormula("transmutation_circle", "Transmutation Circle", "A master circle for equivalent exchange.", /obj/items/MagicCircle/Transmutation, 250, /obj/items/Ore/Auracite, 2, 1, FALSE))
	registerArcaneFormula(new /datum/ArcaneFormula("philosophers_stone", "Philosopher's Stone", "The ultimate alchemical catalyst.", /obj/items/PhilosophersStone, 500, /obj/items/Ore/HeartOfTheMountain, 1, 2))

mob/proc/craftArcaneFormula(formula_id)
	initializeArcaneFormulaCatalog()
	var/datum/ArcaneFormula/formula = arcane_formula_catalog[formula_id]
	if(!formula || !formula.construct_type) return FALSE
	var/node_id = "magic_[formula.id]"
	var/lock_reason = getArcaneCraftLockReason(node_id, formula.essence_cost, formula.required_circle_tier)
	if(lock_reason)
		src << lock_reason
		return FALSE
	if(formula.construct_type == /obj/items/PhilosophersStone && locate(/obj/items/PhilosophersStone) in item_list)
		src << "You already carry a Philosopher's Stone."
		return FALSE
	if(formula.ore_type && countOre(formula.ore_type) < formula.ore_cost)
		var/obj/items/Ore/ore_example = new formula.ore_type
		src << "This ritual requires [formula.ore_cost] [ore_example.ore_name] ore."
		del(ore_example)
		return FALSE
	if(formula.ore_type && !consumeOre(formula.ore_type, formula.ore_cost)) return FALSE
	arcane_essence -= formula.essence_cost
	var/atom/creation_location = formula.create_in_inventory ? src : base_loc()
	var/obj/created = new formula.construct_type(creation_location)
	if(!created)
		arcane_essence += formula.essence_cost
		if(formula.ore_type) addMinedOre(formula.ore_type, formula.ore_cost)
		return FALSE
	created.Builder = key
	player_view(12, src) << "<font color=#c88cff>[src] completes the ritual for [created]."
	Play_Melee_Sound(sound_range = 12, origin = src, sound_file = 'src/Sound/SoundEffects/Combat/Kiplosion.ogg', sound_volume = 45)
	Make_Shockwave(src, sw_icon_size = 128)
	gainMagicExperience(max(1, formula.essence_cost / 30), "crafting [created]", announce = TRUE)
	return TRUE

mob/proc/craftArcaneConstruct(choice)
	initializeArcaneFormulaCatalog()
	for(var/formula_id in arcane_formula_catalog)
		var/datum/ArcaneFormula/formula = arcane_formula_catalog[formula_id]
		if(formula.display_name == choice) return craftArcaneFormula(formula.id)
	return FALSE

mob/proc/openArcaneWorkshop()
	syncMagicProgression(silent = TRUE)
	syncProgressionTrees(silent = TRUE)
	initializeArcaneFormulaCatalog()
	var/list/options = list("Cancel")
	var/list/formula_ids_by_option = list()
	for(var/formula_id in arcane_formula_catalog)
		var/datum/ArcaneFormula/formula = arcane_formula_catalog[formula_id]
		if(!hasProgressionNode("magic_[formula.id]")) continue
		var/option = "[formula.display_name] — [formula.essence_cost] Essence"
		options += option
		formula_ids_by_option[option] = formula.id
	var/choice = input(src, "Arcane Essence: [round(arcane_essence, 0.1)]\nChoose a formula.", "Arcane Workshop") in options
	if(!choice || choice == "Cancel") return
	craftArcaneFormula(formula_ids_by_option[choice])

obj/Arcane_Crafting
	name = "Arcane Crafting"
	desc = "Shape gathered Arcane Essence into magical constructs and ritual tools."
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTMagicCircle.dmi'
	Skill = 1
	hotbar_type = "Ability"
	can_hotbar = 1
	teachable = 0

	verb/Arcane_Crafting()
		set category = "Skills"
		usr.openArcaneWorkshop()

	verb/Hotbar_use()
		set hidden = 1
		usr.openArcaneWorkshop()

obj/Peebag
	var
		training_gain_multiplier = 1
		magic_training_equipment = FALSE
		training_tier = 1

	Tier2
		name = "Tier 2 Punching Bag"
		desc = "A reinforced RPT punching bag that grants 25% more bag-training gains."
		icon = 'src/Icons/RoleplayTenkaichi/Technology/RTPunchingBag2.dmi'
		Cost = 12000
		science = 1
		science_level = 2
		training_gain_multiplier = 1.25
		training_tier = 2

	Tier3
		name = "Tier 3 Punching Bag"
		desc = "A calibrated RPT punching bag that grants 50% more bag-training gains."
		icon = 'src/Icons/RoleplayTenkaichi/Technology/RTPunchingBag3.dmi'
		Cost = 40000
		science = 1
		science_level = 3
		training_gain_multiplier = 1.5
		training_tier = 3

	Tier4
		name = "Tier 4 Punching Bag"
		desc = "A high-resistance RPT punching bag that grants 80% more bag-training gains."
		icon = 'src/Icons/RoleplayTenkaichi/Technology/RTPunchingBag4.dmi'
		Cost = 150000
		science = 1
		science_level = 4
		training_gain_multiplier = 1.8
		training_tier = 4

	Tier5
		name = "Tier 5 Punching Bag"
		desc = "An Engineering-grade RPT punching bag that doubles bag-training gains."
		icon = 'src/Icons/RoleplayTenkaichi/Technology/RTPunchingBag5.dmi'
		Cost = 600000
		science = 1
		science_level = 6
		science_path = "Engineering"
		training_gain_multiplier = 2
		training_tier = 5

	Tier6
		name = "Tier 6 Punching Bag"
		desc = "The peak technological RPT punching bag, granting 150% more bag-training gains."
		icon = 'src/Icons/RoleplayTenkaichi/Technology/RTPunchingBag6.dmi'
		Cost = 2500000
		science = 1
		science_level = 8
		science_path = "Engineering"
		training_gain_multiplier = 2.5
		training_tier = 6

	MagicGoo
		name = "Tier 1 Magic Goo"
		desc = "A magical sparring construct that reinforces BP training and grants Magic XP when struck."
		icon = 'src/Icons/RoleplayTenkaichi/Magic/RTMagicGoo1.dmi'
		Cost = 0
		science = 0
		training_gain_multiplier = 1.25
		magic_training_equipment = TRUE
		training_tier = 1

		Tier2
			name = "Tier 2 Magic Goo"
			icon = 'src/Icons/RoleplayTenkaichi/Magic/RTMagicGoo2.dmi'
			training_gain_multiplier = 1.5
			training_tier = 2

		Tier3
			name = "Tier 3 Magic Goo"
			icon = 'src/Icons/RoleplayTenkaichi/Magic/RTMagicGoo3.dmi'
			training_gain_multiplier = 1.85
			training_tier = 3

		Tier4
			name = "Tier 4 Magic Goo"
			icon = 'src/Icons/RoleplayTenkaichi/Magic/RTMagicGoo4.dmi'
			training_gain_multiplier = 2.25
			training_tier = 4

obj/items/MagicCircle
	name = "Magic Circle"
	desc = "A portable ritual circle. Keep it in your inventory or stand within two tiles to gather 50% more Arcane Essence."
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTMagicCircle.dmi'
	Savable = 1
	Grabbable = 1
	Cost = 0
	layer = 2
	var/circle_tier = 1

	verb/Recover()
		set src in oview(1)
		if(Builder && Builder != usr.key)
			usr << "Only this circle's creator can recover it."
			return
		Move(usr)
		usr << "You recover [src]."

	Transmutation
		name = "Transmutation Circle"
		desc = "An advanced alchemical circle. It doubles Arcane Essence gathering and can exchange resources or ores."
		icon = 'src/Icons/RoleplayTenkaichi/Magic/RTTransmutationCircle.dmi'
		circle_tier = 2

		verb/Transmute()
			set src in oview(1)
			if(!usr.hasProgressionNode("magic_transmutation_circle"))
				usr << "You do not understand this circle's formula."
				return
			usr.performArcaneTransmutation()

mob/proc/performArcaneTransmutation()
	var/list/options = list(
		"Cancel",
		"20,000 Resources -> 10 Arcane Essence",
		"4 Copper -> 1 Tin",
		"4 Iron -> 1 Silver",
		"4 Silver -> 1 Mythril",
		"4 Mythril -> 1 Auracite")
	var/choice = input(src, "Choose an equivalent exchange.", "Transmutation") in options
	if(!choice || choice == "Cancel") return FALSE
	var/source_ore
	var/target_ore
	if(choice == "20,000 Resources -> 10 Arcane Essence")
		var/obj/Resources/resources = GetResourceObject()
		if(!resources || resources.Value < 20000)
			src << "You need 20,000 resources."
			return FALSE
		resources.Value -= 20000
		gainArcaneEssence(10, "transmutation", announce = TRUE)
	else
		switch(choice)
			if("4 Copper -> 1 Tin")
				source_ore = /obj/items/Ore/Copper
				target_ore = /obj/items/Ore/Tin
			if("4 Iron -> 1 Silver")
				source_ore = /obj/items/Ore/Iron
				target_ore = /obj/items/Ore/Silver
			if("4 Silver -> 1 Mythril")
				source_ore = /obj/items/Ore/Silver
				target_ore = /obj/items/Ore/Mythril
			if("4 Mythril -> 1 Auracite")
				source_ore = /obj/items/Ore/Mythril
				target_ore = /obj/items/Ore/Auracite
		if(!source_ore || countOre(source_ore) < 4)
			src << "You lack four units of the required source ore."
			return FALSE
		if(!consumeOre(source_ore, 4)) return FALSE
		addMinedOre(target_ore, 1)
		gainMagicExperience(3, "ore transmutation", announce = TRUE)
	player_view(10, src) << "<font color=#c88cff>The transmutation circle flares as [src] completes an equivalent exchange."
	Play_Melee_Sound(sound_range = 10, origin = src, sound_file = 'src/Sound/SoundEffects/Combat/Kiplosion.ogg', sound_volume = 40)
	return TRUE

obj/items/PhilosophersStone
	name = "Philosopher's Stone"
	desc = "A masterwork alchemical catalyst. Carrying one grants +0.5 effective Regeneration and perfect language comprehension."
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTEnchantmentItems.dmi'
	icon_state = "PhiloStone"
	Savable = 1
	Cost = 0
	bankable = 0

obj/items/StoneOfUnderstanding
	name = "Stone of Understanding"
	desc = "An enchanted listening stone. Carrying it makes every non-secret language fully understandable."
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTEnchantmentItems.dmi'
	icon_state = "ArcanEar"
	Savable = 1
	Cost = 0

obj/items/UniversalTranslator
	name = "Universal Translator"
	desc = "A registered language processor. Carrying it makes your spoken language understandable and translates speech you hear."
	icon = 'src/Icons/Objects/Technology/CellPhone.dmi'
	Cost = 2000000
	science = 1
	science_level = 5
	science_path = "Engineering"
	Savable = 1

mob/Admin4/verb/testTenkaichiResearch(mob/character in players)
	set name = "Test Tenkaichi Research"
	set category = "Admin"
	if(!character) return
	initializeProgressionTreeCatalog()
	character.magic_experience = magic_level_thresholds[magic_level_thresholds.len]
	character.magic_level = magic_level_thresholds.len
	character.technology_experience = technology_level_thresholds[technology_level_thresholds.len]
	character.player_tech_level = technology_level_thresholds.len
	character.arcane_essence += 1500
	character.arcane_essence_lifetime += 1500
	for(var/node_id in progression_node_catalog)
		var/datum/ProgressionNode/node = progression_node_catalog[node_id]
		var/grant_node = node.category == "Magic"
		if(node.category == "Science" && node.reward_type)
			if(ispath(node.reward_type, /obj/Peebag) || node.reward_type == /obj/items/UniversalTranslator) grant_node = TRUE
		if(!grant_node) continue
		character.progression_nodes_owned[node.id] = max(1, node.max_rank)
		character.applyProgressionNodeReward(node, announce = FALSE)
	for(var/ore_type in list(/obj/items/Ore/Copper, /obj/items/Ore/Tin, /obj/items/Ore/Iron, /obj/items/Ore/Silver, /obj/items/Ore/Mythril, /obj/items/Ore/Auracite, /obj/items/Ore/HeartOfTheMountain))
		character.addMinedOre(ore_type, 10)
	new /obj/Peebag/MagicGoo(character.base_loc())
	new /obj/Peebag/MagicGoo/Tier2(character.base_loc())
	new /obj/Peebag/MagicGoo/Tier3(character.base_loc())
	new /obj/Peebag/MagicGoo/Tier4(character.base_loc())
	new /obj/items/MagicCircle(character)
	new /obj/items/MagicCircle/Transmutation(character)
	new /obj/items/UniversalTranslator(character)
	character.syncNexusLanguages(silent = FALSE)
	character << "Tenkaichi research test package granted: every Magic branch and formula, Goo tiers, circles, translator, ores and Arcane Essence."
	src << "Granted the Tenkaichi research test package to [character]."

#undef NEXUS_ARCANE_CIRCLE_RANGE
