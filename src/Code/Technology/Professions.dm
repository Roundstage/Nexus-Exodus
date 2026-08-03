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
	amount *= 1 + getMilestoneRank("profession_specialist") * 0.1
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
	multiplier *= 1 + getProgressionNodeRank("mining_efficient_extraction") * 0.1
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
	find_chance *= 1 + getMilestoneRank("ore_whisperer") * 0.15
	find_chance *= 1 + getProgressionNodeRank("mining_ore_sense") * 0.15
	if(!prob(find_chance)) return
	var/ore_type = /obj/items/Ore/Copper
	var/roll = rand(1, 1000)
	if(mining_level >= 35 && hasMiningOreUnlock(/obj/items/Ore/HeartOfTheMountain) && roll <= 12 + (mining_level - 35) * 2)
		ore_type = /obj/items/Ore/HeartOfTheMountain
	else if(mining_level >= 30 && hasMiningOreUnlock(/obj/items/Ore/Auracite) && roll <= 55 + (mining_level - 30) * 3)
		ore_type = /obj/items/Ore/Auracite
	else if(mining_level >= 20 && hasMiningOreUnlock(/obj/items/Ore/Mythril) && roll <= 175 + (mining_level - 20) * 5)
		ore_type = /obj/items/Ore/Mythril
	else if(mining_level >= 14 && hasMiningOreUnlock(/obj/items/Ore/Silver) && roll <= 310 + (mining_level - 14) * 6)
		ore_type = /obj/items/Ore/Silver
	else if(mining_level >= 7 && hasMiningOreUnlock(/obj/items/Ore/Iron) && roll <= 520 + (mining_level - 7) * 7)
		ore_type = /obj/items/Ore/Iron
	else if(mining_level >= 3 && hasMiningOreUnlock(/obj/items/Ore/Tin) && roll <= 720)
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

var/list/world_ore_deposits = list()
var/world_ore_target_count = 180
var/world_ore_generation_running = FALSE

proc/getWorldOreTypeForRoll(roll)
	if(roll <= 450) return /obj/items/Ore/Copper
	if(roll <= 660) return /obj/items/Ore/Tin
	if(roll <= 810) return /obj/items/Ore/Iron
	if(roll <= 890) return /obj/items/Ore/Silver
	if(roll <= 950) return /obj/items/Ore/Mythril
	if(roll <= 995) return /obj/items/Ore/Auracite
	return /obj/items/Ore/HeartOfTheMountain

proc/getWorldOreRequirement(ore_type)
	switch(ore_type)
		if(/obj/items/Ore/Tin) return 3
		if(/obj/items/Ore/Iron) return 7
		if(/obj/items/Ore/Silver) return 14
		if(/obj/items/Ore/Mythril) return 20
		if(/obj/items/Ore/Auracite) return 30
		if(/obj/items/Ore/HeartOfTheMountain) return 35
	return 1

proc/getWorldOreIcon(ore_type)
	switch(ore_type)
		if(/obj/items/Ore/Tin) return 'RTTinOre.dmi'
		if(/obj/items/Ore/Iron) return 'RTIronOre.dmi'
		if(/obj/items/Ore/Silver) return 'RTSilverOre.dmi'
		if(/obj/items/Ore/Mythril) return 'RTMythrilOre.dmi'
		if(/obj/items/Ore/Auracite) return 'RTAuraciteOre.dmi'
		if(/obj/items/Ore/HeartOfTheMountain) return 'RTMythrilOre.dmi'
	return 'RTCopperOre.dmi'

proc/getWorldOreName(ore_type)
	var/obj/items/Ore/example = new ore_type
	var/result = example.ore_name
	del(example)
	return result

proc/isValidWorldOreTurf(turf/target)
	if(!target || target.density || target.Water || istype(target, /turf/Other/Blank)) return FALSE
	var/area/target_area = target.get_area()
	if(!target_area || !target_area.has_resources || istype(target_area, /area/ship_area)) return FALSE
	for(var/obj/WorldOreDeposit/deposit in target) return FALSE
	return TRUE

proc/generateWorldOreDeposits(target_count = 0)
	if(target_count <= 0) target_count = world_ore_target_count
	world_ore_deposits = remove_nulls(world_ore_deposits)
	var/needed = max(0, target_count - world_ore_deposits.len)
	var/attempts = max(needed * 60, 200)
	while(needed > 0 && attempts-- > 0)
		var/turf/target = locate(rand(1, world.maxx), rand(1, world.maxy), rand(1, world.maxz))
		if(!isValidWorldOreTurf(target)) continue
		var/ore_type = getWorldOreTypeForRoll(rand(1, 1000))
		var/obj/WorldOreDeposit/deposit = new(target)
		deposit.configureOre(ore_type)
		needed--
	return target_count - needed

proc/startWorldOreGeneration()
	set waitfor = FALSE
	if(world_ore_generation_running) return
	world_ore_generation_running = TRUE
	sleep(100)
	while(TRUE)
		generateWorldOreDeposits()
		sleep(max(1200, round(6000 / max(0.1, Year_Speed))))

obj/WorldOreDeposit
	name = "Ore Deposit"
	desc = "A naturally occurring mineral deposit."
	Savable = 0
	Grabbable = 0
	attackable = 0
	density = 1
	var
		ore_type = /obj/items/Ore/Copper
		ore_amount = 2
		required_mining_level = 1
		tmp/being_mined = FALSE

	New()
		. = ..()
		world_ore_deposits += src

	Del()
		world_ore_deposits -= src
		. = ..()

	proc/configureOre(new_ore_type)
		ore_type = new_ore_type
		required_mining_level = getWorldOreRequirement(ore_type)
		ore_amount = ore_type == /obj/items/Ore/HeartOfTheMountain ? 1 : rand(2, 5)
		var/ore_name = getWorldOreName(ore_type)
		name = "[ore_name] Deposit"
		desc = "A [ore_name] deposit containing approximately [ore_amount] ore. Mining level [required_mining_level] required."
		icon = getWorldOreIcon(ore_type)
		if(ore_type == /obj/items/Ore/HeartOfTheMountain) color = rgb(255, 164, 72)

	proc/refreshDepositDescription()
		var/ore_name = getWorldOreName(ore_type)
		desc = "A [ore_name] deposit containing approximately [ore_amount] ore. Mining level [required_mining_level] required."

	proc/mineDeposit(mob/miner)
		if(!miner || !(miner in range(1, src)) || miner.KO || being_mined) return
		miner.syncProfessionProgression()
		miner.syncProgressionTrees(silent = TRUE)
		if(miner.mining_level < required_mining_level)
			miner << "Mining level [required_mining_level] is required for [src]."
			return
		if(!miner.hasMiningOreUnlock(ore_type))
			miner << "Unlock [getWorldOreName(ore_type)] Prospecting in the Mining progression tree first."
			return
		being_mined = TRUE
		var/turf/start_turf = miner.base_loc()
		player_view(10, miner) << "[miner] begins extracting [src]."
		var/mining_time = max(15, round(55 - miner.mining_level * 0.7))
		spawn(mining_time)
			if(!src || !miner) return
			if(miner.KO || miner.base_loc() != start_turf || !(miner in range(1, src)))
				being_mined = FALSE
				miner << "Mining interrupted."
				return
			var/yield_amount = max(1, round(miner.getMiningYieldMultiplier()))
			yield_amount = min(yield_amount, ore_amount)
			miner.addMinedOre(ore_type, yield_amount)
			miner.gainProfessionExperience("Mining", max(2, required_mining_level * 1.5), "mining [src]", announce = TRUE)
			ore_amount -= yield_amount
			player_view(10, miner) << "[miner] extracts [yield_amount] ore from [src]."
			if(ore_amount <= 0)
				del(src)
			else
				being_mined = FALSE
				refreshDepositDescription()

	verb/Mine()
		set src in oview(1)
		mineDeposit(usr)

mob/Admin4/verb/seedWorldOreDeposits()
	set name = "Seed World Ore Deposits"
	set category = "Admin"
	var/target_count = input(src, "Top the world up to how many ore deposits?", "World Ore Generation", world_ore_target_count) as num
	target_count = Clamp(round(target_count), 1, 1000)
	world_ore_target_count = target_count
	var/generated_total = generateWorldOreDeposits(target_count)
	src << "World ore generation now tracks [world_ore_deposits.len]/[target_count] deposits ([generated_total] target result)."

#undef NEXUS_PROFESSION_LEVEL_CAP
