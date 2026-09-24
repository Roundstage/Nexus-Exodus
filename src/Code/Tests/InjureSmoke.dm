mob/NexusSmokeTest/InjureProbe
	var/last_injure_action
	var/injure_outcomes = 0
	var/execution_calls = 0
	var/forced_execution = FALSE
	var/mob/execution_attacker

	recordInjureOutcome(mob/target, action, message)
		last_injure_action = action
		injure_outcomes++

	Death(mob/attacker, Force_Death = 0, drone_sd = 0, lose_hero = 1, lose_immortality = 1)
		execution_calls++
		forced_execution = Force_Death
		execution_attacker = attacker

obj/items/Sword/InjureTransferProbe
	catalog_test_only = TRUE
	var/fail_transfer = FALSE

	Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
		if(fail_transfer) return FALSE
		return ..()

proc/runInjureSmokeTests()
	var/mob/NexusSmokeTest/InjureProbe/actor = new(locate(2, 2, 1))
	var/mob/NexusSmokeTest/InjureProbe/target = new(locate(3, 2, 1))
	actor.Race = "Human"
	actor.alignment = "Evil"
	target.Race = "Human"
	target.KO = TRUE
	target.willpower = 60
	nexusSmokeAssert(!actor.applyInjureAction(target, "Arm") && !target.injury_list.len, "temporary Injure accepted 60 WP")
	target.willpower = 59.9
	nexusSmokeAssert(actor.applyInjureAction(target, "Arm"), "temporary Injure rejected less than 60 WP")
	nexusSmokeAssert(actor.applyInjureAction(target, "Arm") && target.injury_list.len == 2, "temporary Injure could not injure both arms")
	nexusSmokeAssert(!actor.applyInjureAction(target, "Arm"), "temporary Injure exceeded the limb injury cap")
	sleep(6)
	nexusSmokeAssert(target.injury_list.len == 2, "delayed injury registration duplicated a wound")
	target.willpower = 50
	nexusSmokeAssert(!actor.applyInjureAction(target, "Arm", TRUE) && !actor.applyInjureAction(target, "Delimb Arm"), "permanent or delimb Injure accepted 50 WP")
	target.willpower = 49.9
	nexusSmokeAssert(actor.applyInjureAction(target, "Delimb Arm") && actor.applyInjureAction(target, "Delimb Arm"), "Delimb could not upgrade two existing temporary wounds")
	nexusSmokeAssert(!actor.applyInjureAction(target, "Delimb Arm") && target.injury_list.len == 2, "Delimb created a third arm injury")
	for(var/obj/Injuries/injury in target.injury_list)
		nexusSmokeAssert(injury.delimbed && !injury.Wear_Off, "Delimb did not persist as a permanent limb injury")
	nexusSmokeAssert(actor.applyInjureAction(target, "Leg", TRUE), "permanent Injure rejected less than 50 WP")
	nexusSmokeAssert(actor.applyInjureAction(target, "Eye"), "temporary injuries stopped being available below 50 WP")
	target.Tail = TRUE
	target.willpower = 50
	nexusSmokeAssert(!actor.applyInjureAction(target, "Rip tail off") && target.Tail, "tail removal accepted 50 WP")
	target.willpower = 49
	nexusSmokeAssert(actor.applyInjureAction(target, "Rip tail off") && !target.Tail, "tail removal failed below 50 WP")
	target.willpower = 1
	nexusSmokeAssert(!actor.applyInjureAction(target, "Kill") && !target.execution_calls && !("Kill" in actor.getInjureOptions(target)), "Kill accepted positive WP")
	target.willpower = 0
	nexusSmokeAssert(("Kill" in actor.getInjureOptions(target)) && actor.applyInjureAction(target, "Kill") && target.execution_calls == 1 && target.execution_attacker == actor && !target.forced_execution, "Kill did not route 0-WP execution through normal Death protection and regeneration")
	target.Safezone = TRUE
	nexusSmokeAssert(!actor.applyInjureAction(target, "Kill") && target.execution_calls == 1, "Kill bypassed safezone protection")
	target.Safezone = FALSE
	target.willpower = 55
	var/original_alignment = target.alignment
	nexusSmokeAssert(actor.applyInjureAction(target, "Humiliate") && actor.last_injure_action == "Humiliate" && target.willpower == 55 && target.alignment == original_alignment, "Humiliate changed WP or alignment before the alignment system exists")
	target.willpower = 100
	nexusSmokeAssert(actor.applyInjureAction(target, "Mercy") && actor.last_injure_action == "Mercy" && target.KO && target.willpower == 100 && target.alignment == original_alignment, "Mercy changed combat state or alignment instead of recording the RP outcome")
	target.Race = "Majin"
	target.willpower = 0
	nexusSmokeAssert(actor.getInjureActionError(target, "Arm") && !actor.getInjureActionError(target, "Steal") && !actor.getInjureActionError(target, "Mercy"), "Majin injury immunity hid unrelated Injure actions")
	target.Race = "Human"
	target.KO = FALSE
	nexusSmokeAssert(!actor.applyInjureAction(target, "Kill") && actor.getInjureActionError(target, "Steal"), "Injure accepted a target who got up while the menu was open")
	target.KO = TRUE
	target.loc = locate(5, 2, 1)
	nexusSmokeAssert(actor.getInjureActionError(target, "Steal") && !actor.applyInjureAction(target, "Internal"), "Injure accepted a target who moved away")
	target.loc = locate(3, 2, 1)
	actor.KO = TRUE
	nexusSmokeAssert(actor.getInjureActionError(target, "Steal"), "a knocked-out actor could steal")
	actor.KO = FALSE
	actor.rp_mode = TRUE
	nexusSmokeAssert(actor.getInjureActionError(target, "Steal"), "an actor in RP Mode could steal")
	actor.rp_mode = FALSE
	nexusSmokeAssert(actor.getInjureActionError(actor, "Steal") && actor.getInjureActionError(actor, "Kill"), "Injure allowed self-theft or accidental self-execution")
	runInjureLootSmokeTests(actor, target)
	for(var/obj/Injuries/injury in target.injury_list.Copy()) del(injury)
	del(target)
	del(actor)
	world.log << "NEXUS_INJURE_TESTS_PASSED"

proc/runInjureLootSmokeTests(mob/NexusSmokeTest/InjureProbe/actor, mob/NexusSmokeTest/InjureProbe/target)
	var/obj/items/Weights/carried = new(target)
	sleep(1)
	target.willpower = 30
	nexusSmokeAssert(!actor.stealInjureLoot(target, carried) && carried.loc == target, "ordinary theft accepted 30 WP")
	target.willpower = 29.9
	nexusSmokeAssert(actor.stealInjureLoot(target, carried) && carried.loc == actor && (carried in actor.item_list) && !(carried in target.item_list), "ordinary theft below 30 WP did not move exactly one carried item")
	nexusSmokeAssert(!actor.stealInjureLoot(target, carried), "the same stolen item was transferred twice")
	carried.Move(target)
	actor.Race = "Heran"
	target.willpower = 70.1
	nexusSmokeAssert(!actor.stealInjureLoot(target, carried), "Heran theft accepted more than 70 WP")
	target.willpower = 70
	nexusSmokeAssert(actor.stealInjureLoot(target, carried), "Heran theft rejected exactly 70 WP")
	carried.Move(target)
	actor.Race = "Human"
	nexusSmokeAssert(!actor.stealInjureLoot(target, carried), "the theft threshold used the victim's race or stale actor eligibility")
	target.willpower = 20
	carried.Givable = FALSE
	nexusSmokeAssert(!actor.stealInjureLoot(target, carried), "theft transferred a bound item")
	carried.Givable = TRUE
	carried.suffix = "Installed"
	nexusSmokeAssert(!actor.stealInjureLoot(target, carried), "theft transferred an installed item without uninstalling it")
	carried.suffix = null
	var/obj/Injuries/skill_like_object = new
	skill_like_object.loc = target
	nexusSmokeAssert(actor.getInjureLootError(target, skill_like_object), "theft accepted a non-item ability or injury")
	del(skill_like_object)
	var/list/fillers = list()
	while(actor.item_count() < actor.MaxItems())
		var/obj/items/Weights/filler = new
		filler.Move(actor)
		fillers += filler
	nexusSmokeAssert(!actor.stealInjureLoot(target, carried) && carried.loc == target, "theft ignored inventory capacity")
	for(var/obj/items/filler in fillers) del(filler)
	del(carried)
	var/list/gear_types = list(/obj/items/Sword, /obj/items/Armor, /obj/items/Gloves/Forged, /obj/items/Mask/Forged, /obj/items/Weights, /obj/items/Scouter, /obj/items/Clothes/Jumpsuit)
	for(var/gear_type in gear_types)
		var/obj/items/gear = new gear_type(target)
		sleep(2)
		var/strength_before = target.Str
		var/endurance_before = target.End
		var/defense_before = target.Def
		target.toggleInjureLootEquipment(gear)
		target.hotbar += gear
		nexusSmokeAssert(gear.suffix == "Equipped" && (gear in actor.getInjureLootChoices(target)), "equipped gear was excluded from the theft picker: [gear_type]")
		nexusSmokeAssert(actor.stealInjureLoot(target, gear) && gear.loc == actor && !gear.suffix && !(gear in target.item_list) && !(gear in target.hotbar), "theft failed to detach equipped gear and its old inventory/hotbar references: [gear_type]")
		nexusSmokeAssert(target.equipped_sword != gear && target.armor_obj != gear && target.equipped_gloves != gear && target.equipped_forged_mask != gear && target.weights_obj != gear && target.Scouter != gear, "the old owner retained an equipment pointer after theft: [gear_type]")
		nexusSmokeAssertNear(target.Str, strength_before, 0.0001, "theft did not restore the old owner's Strength")
		nexusSmokeAssertNear(target.End, endurance_before, 0.0001, "theft did not restore the old owner's Endurance")
		nexusSmokeAssertNear(target.Def, defense_before, 0.0001, "theft did not restore the old owner's Defense")
		del(gear)
	var/obj/items/Sword/InjureTransferProbe/failed_item = new(target)
	sleep(1)
	target.Apply_Sword(failed_item)
	var/equipped_strength = target.Str
	failed_item.fail_transfer = TRUE
	nexusSmokeAssert(!actor.stealInjureLoot(target, failed_item) && failed_item.loc == target && failed_item.suffix == "Equipped" && target.equipped_sword == failed_item, "a failed theft transfer stripped or lost the victim's equipment")
	nexusSmokeAssertNear(target.Str, equipped_strength, 0.0001, "a failed theft transfer changed the victim's equipment bonus")
	del(failed_item)
