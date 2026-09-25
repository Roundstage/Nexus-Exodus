mob/NexusSmokeTest/ContextAdmin
	var/test_admin_level = 3
	IsAdmin()
		return test_admin_level > 0
	AdminLevel()
		return test_admin_level

proc/runClassicContextSmokeTests()
	var/mob/previous_usr = usr
	var/mob/NexusSmokeTest/ContextAdmin/owner = new
	usr = owner
	var/datum/ClassicHud/hud = new(owner)
	var/obj/Contract_Soul/NexusMenuSoulProbe/soul = new(owner)
	hud.section = "souls"
	var/datum/ClassicSnapshot/souls = owner.captureClassicData("souls")
	nexusSmokeAssert(souls.subjects["\ref[soul]"] == soul && souls.rows.len == 1, "single-argument stat row lost its soul reference")
	del(souls)
	var/datum/ClassicSnapshot/capture = new
	owner.nexus_classic_capture = capture
	owner.classicStat(list(soul))
	owner.classicStat("Heading")
	owner.classicStat("Zero", 0)
	owner.nexus_classic_capture = null
	nexusSmokeAssert(capture.subjects["\ref[soul]"] == soul && capture.rows.len == 3 && capture.rows[2]["label"] == "Heading" && capture.rows[3]["value"] == "0", "legacy stat list/text capture lost references or zero values")
	del(capture)
	nexusSmokeAssert(hud.runContextAction("menu", "\ref[soul]", "soul") && soul.use_count == 1, "right-click Souls action did not reach the owned soul")
	soul.loc = null
	nexusSmokeAssert(!hud.runContextAction("menu", "\ref[soul]", "soul") && soul.use_count == 1, "stale soul context retained access after transfer")
	soul.loc = owner
	nexusSmokeAssert(!hud.runContextAction("inventory", "\ref[soul]", "soul"), "forged context token reached a soul outside the displayed panel")
	var/obj/items/Amulet/NexusMenuUseProbe/item = new(owner)
	owner.item_list |= item
	nexusSmokeAssert(hud.runContextAction("inventory", "\ref[item]", "use") && item.use_count == 1 && item.last_user == owner, "context Use lost item activation or usr")
	nexusSmokeAssert(!hud.runContextAction("inventory", "\ref[item]", "forged-action"), "context accepted an unknown action")
	var/mob/NexusSmokeTest/target = new
	owner.verbs |= list(/mob/AdminEssentials/verb/managePlayer, /mob/AdminEssentials/verb/adminInspector, /mob/Admin1/verb/teleport)
	var/list/options = hud.contextOptions(target)
	var/has_manage = FALSE
	var/has_inspect = FALSE
	for(var/list/option in options)
		if(option["path"] == /mob/AdminEssentials/verb/managePlayer)
			has_manage = TRUE
			nexusSmokeAssert(hud.contextCommand(target, option) == "Manage-Player \"\ref[target]\"", "admin context did not bind the clicked player")
		if(option["id"] == "inspect") has_inspect = TRUE
	nexusSmokeAssert(has_manage && has_inspect, "admin row context is missing target actions")
	owner.test_admin_level = 0
	nexusSmokeAssert(!hud.contextOptions(target).len, "ordinary player received admin context actions")
	owner.test_admin_level = 1
	options = hud.contextOptions(target)
	for(var/list/option in options) nexusSmokeAssert(option["id"] != "inspect", "level-one admin received inspector")
	options = hud.contextOptions(item)
	var/has_use_verb = FALSE
	for(var/list/option in options)
		if(option["path"] == /obj/items/Amulet/verb/Use)
			has_use_verb = TRUE
			nexusSmokeAssert(hud.contextCommand(item, option) == "Use \"\ref[item]\"", "item context did not bind its verb source")
	nexusSmokeAssert(has_use_verb, "item context omitted native item verbs")
	del(hud)
	del(soul)
	del(item)
	del(target)
	del(owner)
	usr = previous_usr

proc/runMaterializeBuffSmokeTests()
	var/mob/previous_usr = usr
	var/mob/NexusSmokeTest/character = new(locate(4, 4, 1))
	usr = character
	var/obj/Materialization/materialize = new(character)
	for(var/choice in list("Make Armor", "Make Sword", "Make Gauntlets", "Make Weights"))
		var/obj/items/item = materialize.materializeEquipment(character, choice)
		nexusSmokeAssert(item && item.loc == get_step(character, character.dir), "Materialize failed to create [choice]")
		if(choice != "Make Weights")
			nexusSmokeAssert(item:forged_material_id == "normal" && !item:master_blacksmith_quality, "Materialize created upgraded equipment")
		if(choice == "Make Sword") nexusSmokeAssert(item.type == /obj/items/Sword/Forged/Science, "Materialize bypassed the normal Science sword")
		if(choice == "Make Gauntlets") nexusSmokeAssert(item.type == /obj/items/Gloves/Forged/Science, "Materialize bypassed the normal Science gauntlets")
		del(item)
	nexusSmokeAssert(!materialize.materializeEquipment(character, "Learn new weight tier") && !materialize.materializeEquipment(character, /obj/items/Sword/Forged/Mythril), "Materialize accepted a removed choice or arbitrary subtype")
	materialize.loc = null
	nexusSmokeAssert(!materialize.materializeEquipment(character, "Make Sword"), "transferred Materialize still created equipment")
	del(materialize)
	character.loc = null
	var/list/catalog = getPresetBuffAppearances()
	for(var/type_text in catalog)
		var/skill_type = text2path(type_text)
		var/obj/skill = new skill_type(character)
		if(istype(skill, /obj/Buff))
			character.rebuff_timer = 0
			character.Buff_Enable(skill)
		else character.toggleDemonBuff(skill)
		for(var/list/visual in catalog[type_text])
			nexusSmokeAssert("" in icon_states(visual[1]), "buff DMI is missing its default state: [type_text]")
			nexusSmokeAssert(countAppearanceSmokeIcon(character, visual[1]) == 1, "buff lost or duplicated its persistent visual: [type_text]")
		character.rebuildPlayerAppearance("repeat buff rebuild")
		for(var/list/visual in catalog[type_text]) nexusSmokeAssert(countAppearanceSmokeIcon(character, visual[1]) == 1, "buff rebuild duplicated a visual: [type_text]")
		if(istype(skill, /obj/Buff)) character.Buff_Disable(skill)
		else character.revertDemonBuff()
		for(var/list/visual in catalog[type_text]) nexusSmokeAssert(countAppearanceSmokeIcon(character, visual[1]) == 0, "disabled buff left a visual: [type_text]")
		del(skill)
	var/obj/Buff/Focus/focus = new(character)
	character.rebuff_timer = 0
	character.Buff_Enable(focus)
	var/savefile/saved = new
	character.Write(saved)
	var/mob/NexusSmokeTest/loaded = new
	loaded.Read(saved)
	nexusSmokeAssert(countAppearanceSmokeIcon(loaded, 'src/Icons/NexusIntegrated/Buffs/RTFocusElectricity.dmi') == 1, "Focus electricity was lost or duplicated on relog")
	loaded.Buff_Disable(locate(/obj/Buff/Focus) in loaded)
	nexusSmokeAssert(!countAppearanceSmokeIcon(loaded, 'src/Icons/NexusIntegrated/Buffs/RTFocusElectricity.dmi'), "relogged Focus could not remove its electricity")
	del(loaded)
	character.Buff_Disable(focus)
	del(focus)
	character.normalizeMajinBPMultiplier()
	character.base_bp = 10000
	character.bp_mult = 1.4
	character.Ki = character.max_ki
	character.last_bp_get_time = -100
	var/baseline_bp = character.get_bp()
	character.ismystic = TRUE
	character.last_bp_get_time = -100
	nexusSmokeAssertNear(character.get_bp(), baseline_bp * 1.5, 0.1, "Mystic does not grant x1.5 BP in base form")
	character.ismystic = FALSE
	character.ismajin = TRUE
	character.last_bp_get_time = -100
	nexusSmokeAssertNear(character.get_bp(), baseline_bp * 1.5, 0.1, "Majin does not grant x1.5 BP with other bonuses")
	character.majin_bp_version = 0
	character.bp_mult = 1.6
	character.normalizeMajinBPMultiplier()
	character.normalizeMajinBPMultiplier()
	nexusSmokeAssertNear(character.bp_mult, 1.4, 0.001, "legacy active Majin migration lost or duplicated another BP bonus")
	character.ismajin = FALSE
	del(character)
	usr = previous_usr
	world.log << "NEXUS_MATERIALIZE_BUFF_CONTEXT_TESTS_PASSED"
