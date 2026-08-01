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
	profession_progression_version = 2
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
	var/find_chance = min(28, 6 + mining_level * 0.4)
	if(getMilestoneRank("mining_expert")) find_chance *= 1.35
	if(!prob(find_chance)) return
	var/ore_type = /obj/items/Ore/Copper
	var/roll = rand(1, 1000)
	if(mining_level >= 35 && roll <= 12 + (mining_level - 35) * 2)
		ore_type = /obj/items/Ore/HeartOfTheMountain
	else if(mining_level >= 30 && roll <= 55 + (mining_level - 30) * 3)
		ore_type = /obj/items/Ore/Auracite
	else if(mining_level >= 20 && roll <= 175 + (mining_level - 20) * 5)
		ore_type = /obj/items/Ore/Mythril
	else if(mining_level >= 14 && roll <= 310 + (mining_level - 14) * 6)
		ore_type = /obj/items/Ore/Silver
	else if(mining_level >= 7 && roll <= 520 + (mining_level - 7) * 7)
		ore_type = /obj/items/Ore/Iron
	else if(mining_level >= 3 && roll <= 720)
		ore_type = /obj/items/Ore/Tin
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

	Tin
		ore_name = "Tin"
		icon = 'RTTinOre.dmi'

	Iron
		ore_name = "Iron"
		icon = 'RTIronOre.dmi'

	Silver
		ore_name = "Silver"
		icon = 'RTSilverOre.dmi'

	Mythril
		ore_name = "Mythril"
		icon = 'RTMythrilOre.dmi'

	Auracite
		ore_name = "Auracite"
		icon = 'RTAuraciteOre.dmi'

	HeartOfTheMountain
		ore_name = "Heart of the Mountain"
		icon = 'RTMythrilOre.dmi'
		color = rgb(255, 164, 72)

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

#undef NEXUS_PROFESSION_LEVEL_CAP
