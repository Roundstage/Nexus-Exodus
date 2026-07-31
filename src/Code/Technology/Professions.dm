#define NEXUS_PROFESSION_LEVEL_CAP 50

proc/getProfessionExperienceForLevel(level)
	level = Clamp(round(level), 1, NEXUS_PROFESSION_LEVEL_CAP)
	return (level - 1) ** 2 * 50

proc/getProfessionLevelForExperience(experience)
	var/level = 1
	while(level < NEXUS_PROFESSION_LEVEL_CAP && experience >= getProfessionExperienceForLevel(level + 1))
		level++
	return level

mob/var
	mining_experience = 0
	mining_level = 1
	smithing_experience = 0
	smithing_level = 1
	profession_progression_version = 0

mob/proc/syncProfessionProgression(announce = FALSE)
	mining_experience = max(0, mining_experience)
	smithing_experience = max(0, smithing_experience)
	var/old_mining_level = max(1, mining_level)
	var/old_smithing_level = max(1, smithing_level)
	mining_level = getProfessionLevelForExperience(mining_experience)
	smithing_level = getProfessionLevelForExperience(smithing_experience)
	profession_progression_version = 1
	if(announce && mining_level > old_mining_level)
		src << "<font color=#d8a56b>Your Mining level increased to [mining_level]."
	if(announce && smithing_level > old_smithing_level)
		src << "<font color=#e0bd83>Your Smithing level increased to [smithing_level]."

mob/proc/gainProfessionExperience(profession, amount, reason, announce = FALSE)
	if(amount <= 0) return 0
	switch(profession)
		if("Mining") mining_experience += amount
		if("Smithing") smithing_experience += amount
		else return 0
	if(getMilestoneRank("liberal_arts"))
		gainTechnologyExperience(amount * 0.25, "[profession]: [reason]", announce = FALSE)
	syncProfessionProgression(announce)
	if(announce) src << "You gained [round(amount, 0.1)] [profession] XP from [reason]."
	return amount

mob/proc/getMiningYieldMultiplier()
	var/multiplier = 1 + (mining_level - 1) * 0.02
	if(getMilestoneRank("mining_expert")) multiplier *= 1.5
	return multiplier

mob/proc/isMiningCave()
	var/area/current_mining_area = get_area()
	return istype(current_mining_area, /area/Mining_Cave)

mob/proc/addMinedOre(ore_type, amount = 1)
	if(!ispath(ore_type, /obj/items/Ore) || amount <= 0) return
	for(var/obj/items/Ore/ore in item_list)
		if(ore.type != ore_type) continue
		ore.stack_amount += amount
		ore.refreshOreDescription()
		return ore
	var/obj/items/Ore/new_ore = new ore_type(src)
	new_ore.stack_amount = amount
	new_ore.refreshOreDescription()
	return new_ore

mob/proc/tryMineOre()
	if(!isMiningCave()) return
	var/find_chance = min(24, 5 + mining_level * 0.35)
	if(getMilestoneRank("mining_expert")) find_chance *= 1.35
	if(!prob(find_chance)) return
	var/ore_type = /obj/items/Ore/Copper
	var/roll = rand(1, 100)
	if(mining_level >= 30 && roll <= 4 + (mining_level - 30) * 0.35)
		ore_type = /obj/items/Ore/Auracite
	else if(mining_level >= 18 && roll <= 16 + (mining_level - 18) * 0.5)
		ore_type = /obj/items/Ore/Mythril
	else if(mining_level >= 6 && roll <= 48 + (mining_level - 6) * 0.5)
		ore_type = /obj/items/Ore/Iron
	var/obj/items/Ore/ore = addMinedOre(ore_type)
	if(ore) src << "<font color=#d8b47c>You uncover [ore.ore_name]. You now carry [ore.stack_amount]."

mob/proc/performMiningTick(base_yield)
	syncProfessionProgression()
	var/resource_yield = max(1, round(base_yield * getMiningYieldMultiplier()))
	if(isMiningCave())
		gainProfessionExperience("Mining", max(1, resource_yield ** 0.25), "excavation")
		tryMineOre()
	return resource_yield

obj/items/Ore
	name = "Ore"
	Savable = 1
	Stealable = 1
	Cost = 0
	can_hotbar = 0
	var/stack_amount = 1
	var/ore_name = "ore"

	New()
		. = ..()
		refreshOreDescription()

	proc/refreshOreDescription()
		name = "[ore_name] Ore x[stack_amount]"
		desc = "Raw [ore_name] ore used by a forge. Stack: [stack_amount]."

	Click()
		if(src in usr) usr << desc

	Copper
		ore_name = "Copper"
		icon = 'RTCopperOre.dmi'

	Iron
		ore_name = "Iron"
		icon = 'RTIronOre.dmi'

	Mythril
		ore_name = "Mythril"
		icon = 'RTMythrilOre.dmi'

	Auracite
		ore_name = "Auracite"
		icon = 'RTAuraciteOre.dmi'

datum/SmithingRecipe
	var
		id
		name
		description
		required_level = 1
		ore_type
		ore_cost = 3
		result_type

	New(new_id, new_name, new_description, new_level, new_ore_type, new_ore_cost, new_result_type)
		id = new_id
		name = new_name
		description = new_description
		required_level = new_level
		ore_type = new_ore_type
		ore_cost = new_ore_cost
		result_type = new_result_type

var/list/smithing_recipe_catalog

proc/initializeSmithingRecipes()
	if(islist(smithing_recipe_catalog) && smithing_recipe_catalog.len) return
	smithing_recipe_catalog = list()
	smithing_recipe_catalog["copper_sword"] = new /datum/SmithingRecipe("copper_sword", "Copper Sword", "Reliable starter blade.", 1, /obj/items/Ore/Copper, 3, /obj/items/Sword/Forged/Copper)
	smithing_recipe_catalog["copper_armor"] = new /datum/SmithingRecipe("copper_armor", "Copper Armor", "Balanced starter protection.", 1, /obj/items/Ore/Copper, 4, /obj/items/Armor/Forged/Copper)
	smithing_recipe_catalog["iron_sword"] = new /datum/SmithingRecipe("iron_sword", "Iron Sword", "A stronger and heavier forged blade.", 6, /obj/items/Ore/Iron, 4, /obj/items/Sword/Forged/Iron)
	smithing_recipe_catalog["iron_armor"] = new /datum/SmithingRecipe("iron_armor", "Iron Armor", "Heavy protection for committed fighters.", 6, /obj/items/Ore/Iron, 5, /obj/items/Armor/Forged/Iron)
	smithing_recipe_catalog["mythril_sword"] = new /datum/SmithingRecipe("mythril_sword", "Mythril Sword", "Light, sharp and difficult to forge.", 18, /obj/items/Ore/Mythril, 5, /obj/items/Sword/Forged/Mythril)
	smithing_recipe_catalog["mythril_armor"] = new /datum/SmithingRecipe("mythril_armor", "Mythril Armor", "Protection without sacrificing mobility.", 18, /obj/items/Ore/Mythril, 6, /obj/items/Armor/Forged/Mythril)
	smithing_recipe_catalog["auracite_sword"] = new /datum/SmithingRecipe("auracite_sword", "Auracite Sword", "A masterwork energy-conductive blade.", 30, /obj/items/Ore/Auracite, 6, /obj/items/Sword/Forged/Auracite)
	smithing_recipe_catalog["auracite_armor"] = new /datum/SmithingRecipe("auracite_armor", "Auracite Armor", "Elite protection made from rare ore.", 30, /obj/items/Ore/Auracite, 7, /obj/items/Armor/Forged/Auracite)

mob/proc/countOre(ore_type)
	var/amount = 0
	for(var/obj/items/Ore/ore in item_list)
		if(ore.type == ore_type) amount += ore.stack_amount
	return amount

mob/proc/consumeOre(ore_type, amount)
	if(amount <= 0) return TRUE
	if(countOre(ore_type) < amount) return FALSE
	for(var/obj/items/Ore/ore in item_list)
		if(ore.type != ore_type) continue
		var/taken = min(amount, ore.stack_amount)
		ore.stack_amount -= taken
		amount -= taken
		if(ore.stack_amount <= 0) del(ore)
		else ore.refreshOreDescription()
		if(amount <= 0) break
	return TRUE

mob/proc/applyMasterBlacksmithQuality(obj/items/item)
	if(!item || !getMilestoneRank("master_blacksmith")) return
	if(istype(item, /obj/items/Sword))
		var/obj/items/Sword/sword = item
		sword.Damage = min(2, sword.Damage * 1.05)
		sword.Sword_Desc()
	else if(istype(item, /obj/items/Armor))
		var/obj/items/Armor/armor = item
		armor.Armor = min(2, armor.Armor * 1.05)
		armor.Armor_Desc()

mob/proc/craftSmithingRecipe(datum/SmithingRecipe/recipe)
	if(!recipe || smithing_level < recipe.required_level) return FALSE
	var/ore_cost = max(1, recipe.ore_cost - getMilestoneRank("master_blacksmith"))
	if(!consumeOre(recipe.ore_type, ore_cost))
		var/obj/items/Ore/ore_example = new recipe.ore_type
		src << "You need [ore_cost] [ore_example.ore_name] ore to forge [recipe.name]."
		del(ore_example)
		return FALSE
	var/obj/items/forged_item = new recipe.result_type(src)
	applyMasterBlacksmithQuality(forged_item)
	gainProfessionExperience("Smithing", 15 + recipe.required_level * 3, "forging [recipe.name]", announce = TRUE)
	player_view(15, src) << "<font color=#e0bd83>[src] forges [forged_item]."
	return forged_item

mob/proc/openSmithingMenu(obj/Forge/forge)
	if(!forge || getdist(src, forge) > 1 || KO || rp_mode) return
	syncProfessionProgression()
	initializeSmithingRecipes()
	var/list/options = list("Cancel")
	for(var/recipe_id in smithing_recipe_catalog)
		var/datum/SmithingRecipe/recipe = smithing_recipe_catalog[recipe_id]
		if(smithing_level < recipe.required_level) continue
		var/ore_cost = max(1, recipe.ore_cost - getMilestoneRank("master_blacksmith"))
		var/obj/items/Ore/ore_example = new recipe.ore_type
		var/label = "[recipe.name] - [ore_cost] [ore_example.ore_name] ore - [recipe.description]"
		del(ore_example)
		options[label] = recipe
	var/choice = input(src, "Smithing level [smithing_level]. Choose a recipe.", "Forge") in options
	if(!choice || choice == "Cancel") return
	craftSmithingRecipe(options[choice])

obj/Forge
	name = "Forge"
	desc = "A smithing station used to turn mined ore into weapons and armor."
	icon = 'Lab2.dmi'
	density = 1
	Health = 100000
	Cost = 250000
	Savable = 1
	takes_gradual_damage = 1
	science = 1
	science_level = 3
	science_path = "Engineering"

	verb/Smith()
		set src in oview(1)
		usr.openSmithingMenu(src)

obj/items/Sword/Forged
	Cost = 0
	can_change_icon = 0
	Stealable = 1

	Copper
		name = "Copper Sword"
		icon = 'RTCopperSword.dmi'
		Damage = 1.2
		Cost = 0

	Iron
		name = "Iron Sword"
		icon = 'RTIronSword.dmi'
		Damage = 1.35
		Cost = 0

	Mythril
		name = "Mythril Sword"
		icon = 'RTMythrilSword.dmi'
		Damage = 1.5
		Cost = 0

	Auracite
		name = "Auracite Sword"
		icon = 'RTAuraciteSword.dmi'
		Damage = 1.65
		Style = "Energy"
		Cost = 0

obj/items/Armor/Forged
	Cost = 0
	can_change_icon = 0
	Stealable = 1
	armor_ver = 2

	Copper
		name = "Copper Armor"
		icon = 'RTCopperArmor.dmi'
		Armor = 1.2
		heaviness = 1.08
		Cost = 0

	Iron
		name = "Iron Armor"
		icon = 'RTIronArmor.dmi'
		Armor = 1.42
		heaviness = 1.22
		Cost = 0

	Mythril
		name = "Mythril Armor"
		icon = 'RTMythrilArmor.dmi'
		Armor = 1.48
		heaviness = 1.04
		Cost = 0

	Auracite
		name = "Auracite Armor"
		icon = 'RTAuraciteArmor.dmi'
		Armor = 1.68
		heaviness = 1.12
		Cost = 0

#undef NEXUS_PROFESSION_LEVEL_CAP
