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
	nexusSmokeAssert(!hud.runTargetContextAction(target, /mob/Admin1/verb/adminHeal), "World action accepted a disconnected target")
	nexusSmokeAssert(!hud.runTargetContextAction(target, /mob/Admin2/verb/worldHeal), "World action accepted an unrelated verb")
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
	var/obj/items/Armor/armor = new(character)
	armor.suffix = "Equipped"
	armor.appearance_priority = 700
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
			assertBuffLayerSmoke(character, visual[1], "preset [type_text]")
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
	runBuffLayerSmokeTests()
	world.log << "NEXUS_MATERIALIZE_BUFF_CONTEXT_TESTS_PASSED"

proc/assertBuffLayerSmoke(mob/character, icon_resource, context)
	var/image/reference_appearance = image(icon_resource)
	var/equipment_layer = character.layer
	for(var/datum/PlayerAppearanceEntry/entry in character.player_appearance_manager.sortedEntries())
		if(entry.category == "equipment") equipment_layer = max(equipment_layer, entry.rendered.layer)
	var/matches = 0
	for(var/appearance_value in character.overlays)
		if(appearance_value:icon != reference_appearance.icon) continue
		matches++
		nexusSmokeAssert(appearance_value:layer > equipment_layer, "[context]: buff is underneath clothing or armor")
		if(character.Auras && character.Auras.Old)
			nexusSmokeAssert(character.Auras.Old.layer > appearance_value:layer, "[context]: powerup is underneath a buff")
	nexusSmokeAssert(matches == 1, "[context]: expected exactly one buff appearance")

proc/runBuffLayerSmokeTests()
	var/mob/previous_usr = usr
	var/mob/NexusSmokeTest/character = new
	usr = character
	character.Ki = 100000
	character.max_ki = 100000
	character.Tail = TRUE
	var/obj/FireFist/fire_fist = new(character)
	fire_fist.FireFist()
	var/obj/SaiyanPower/saiyan_power = new(character)
	saiyan_power.SaiyanPower()
	var/obj/items/Clothes/ShortSleeveShirt/shirt = new(character)
	var/obj/items/Armor/armor = new(character)
	shirt.suffix = "Equipped"
	armor.suffix = "Equipped"
	character.setEquipmentAppearancePriority(armor, 700)
	var/obj/Auras/aura = new(character)
	character.BPpcnt = 150
	character.Aura_Overlays()
	assertBuffLayerSmoke(character, 'src/Icons/VFX/FlamingFists.dmi', "Fire Fist equipped after activation")
	assertBuffLayerSmoke(character, 'src/Icons/VFX/SaiyanPower.dmi', "Saiyan Power equipped after activation")
	character.Clothes_Equip(shirt)
	character.Clothes_Equip(shirt)
	assertBuffLayerSmoke(character, 'src/Icons/VFX/FlamingFists.dmi', "Fire Fist after reequip")

	var/obj/Buff/custom_buff = new(character)
	var/icon/custom_icon = icon('src/Icons/Effects/GivePower.dmi')
	custom_icon.Blend(rgb(120, 80, 255), ICON_MULTIPLY)
	custom_buff.buff_overlays += custom_icon
	character.Buff_Enable(custom_buff)
	assertBuffLayerSmoke(character, custom_icon, "custom buff with powerup already active")
	// Reproduce a legacy raw overlay and lost temporary manager before a real save/load.
	character.overlays += 'src/Icons/VFX/FlamingFists.dmi'
	character.overlays += custom_icon
	var/savefile/saved = new
	character.Write(saved)
	var/mob/NexusSmokeTest/loaded = new
	loaded.Read(saved)
	loaded.Aura_Overlays()
	var/obj/Buff/loaded_buff = locate(/obj/Buff) in loaded
	var/loaded_icon = loaded_buff.buff_overlays[2]
	assertBuffLayerSmoke(loaded, 'src/Icons/VFX/FlamingFists.dmi', "Fire Fist after legacy load")
	assertBuffLayerSmoke(loaded, loaded_icon, "custom icon after legacy load")
	loaded.rebuildPlayerAppearance("repeat loaded buff rebuild")
	assertBuffLayerSmoke(loaded, loaded_icon, "custom icon after repeat rebuild")
	loaded.FireFist_Revert()
	loaded.SaiyanPower_Revert()
	loaded.Buff_Disable(loaded_buff)
	nexusSmokeAssert(!countAppearanceSmokeIcon(loaded, 'src/Icons/VFX/FlamingFists.dmi') && !countAppearanceSmokeIcon(loaded, loaded_icon) && !countAppearanceSmokeIcon(loaded, 'src/Icons/VFX/SaiyanPower.dmi'), "relogged buff removal left managed effects")
	del(loaded)
	character.Buff_Disable(custom_buff)
	character.FireFist_Revert()
	character.SaiyanPower_Revert()

	var/obj/Majin/majin = new(character)
	majin.Majin()
	assertBuffLayerSmoke(character, majin.icon, "Majin with powerup already active")
	character.Majin_Revert()
	nexusSmokeAssert(!countAppearanceSmokeIcon(character, majin.icon), "Majin revert left its managed effect")

	// Powerup must stay above transformation hair/electricity when either is added later.
	character.Tail = null
	character.ssj = 2
	character.ssj2hair = 'src/Icons/PlayerIcons/Hair/HairGokuSSj.dmi'
	character.SSj_Hair()
	character.Aura_Overlays()
	character.Add_Sparks()
	character.rebuildPlayerAppearance("transformation while powering up")
	for(var/appearance_value in character.overlays)
		if(appearance_value:icon == character.ssj2hair || appearance_value:icon == 'src/Icons/PlayerIcons/TobiUchihaIcons/SSj2ElectricTobiUchiha.dmi')
			nexusSmokeAssert(aura.Old.layer > max(character.layer, appearance_value:layer), "powerup is underneath transformation hair or electricity")
	character.ssj = 0
	character.is_ssj_blue = TRUE
	character.super_God_Fist = TRUE
	character.ssj_blue_aura = 'src/Icons/Ki/Auras/AuraSSjBig.dmi'
	character.Aura_Overlays()
	nexusSmokeAssert(countAppearanceSmokeIcon(character, super_God_Fist_aura.icon) == 1 && !countBuffUnderlaySmokeIcon(character, super_God_Fist_aura.icon) && super_God_Fist_aura.layer > PLAYER_BUFF_LAYER, "Super God Fist aura is behind buffs")
	character.super_God_Fist = FALSE
	character.Aura_Overlays()
	nexusSmokeAssert(!countAppearanceSmokeIcon(character, super_God_Fist_aura.icon), "Super God Fist aura remained after switching powerup")
	character.is_ssj_blue = FALSE
	for(var/form in list("gold", "ultra_instinct"))
		character.is_gold_form = form == "gold"
		character.ultra_instinct = form == "ultra_instinct"
		character.gold_form_aura = 'src/Icons/Ki/Auras/AuraSSjBig.dmi'
		character.Aura_Overlays()
		nexusSmokeAssert(aura.Old.layer > PLAYER_BUFF_LAYER && !countBuffUnderlaySmokeIcon(character, aura.Old.icon), "[form] powerup retained an underlay copy")
	character.is_gold_form = FALSE
	character.ultra_instinct = FALSE
	custom_buff.buff_overlays = list("Cancel", aura.icon)
	character.rebuff_timer = 0
	character.Buff_Enable(custom_buff)
	character.Aura_Overlays()
	character.rebuildPlayerAppearance("buff reuses powerup resource")
	var/foreground_auras = 0
	for(var/appearance_value in character.overlays)
		if(appearance_value:icon == aura.Old.icon && appearance_value:layer == aura.Old.layer) foreground_auras++
	nexusSmokeAssert(foreground_auras == 1, "buff cleanup removed a powerup using the same resource")
	character.Buff_Disable(custom_buff)
	character.BPpcnt = 100
	character.Aura_Overlays()
	nexusSmokeAssert(!countAppearanceSmokeIcon(character, aura.Old.icon) && !countAppearanceSmokeIcon(character, super_God_Fist_aura.icon), "powering down left a foreground aura")
	usr = previous_usr
	del(character)
	world.log << "NEXUS_BUFF_LAYER_TESTS_PASSED"

proc/countBuffUnderlaySmokeIcon(mob/character, icon_resource)
	var/count = 0
	var/image/reference_appearance = image(icon_resource)
	for(var/appearance_value in character.underlays)
		if(appearance_value:icon == reference_appearance.icon) count++
	return count
