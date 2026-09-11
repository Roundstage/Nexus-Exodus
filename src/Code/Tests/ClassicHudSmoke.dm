proc/runClassicHudSmokeTests()
	runSkillArtworkSmokeTests()
	runNexusVitalsLayoutSmokeTests()
	var/list/geometry = normalizeClassicGeometry(list("x" = 9000, "y" = -200, "w" = 9999, "h" = -20), "chat", 800, 600)
	nexusSmokeAssert(geometry["x"] == 0 && geometry["y"] == 0 && geometry["w"] == 800 && geometry["h"] == 120, "Classic geometry escaped the map or accepted invalid dimensions")
	var/list/menu_geometry = normalizeClassicGeometry(list("x" = 100, "y" = 90, "w" = 9999, "h" = 120), "menu", 1920, 1080)
	nexusSmokeAssert(menu_geometry["x"] == 100 && menu_geometry["y"] == 90 && menu_geometry["w"] == 460 && menu_geometry["h"] == 680, "Classic menu did not preserve its fixed reference size")
	var/list/skills_geometry = normalizeClassicGeometry(list("x" = 120, "y" = 80, "w" = 900, "h" = 900), "skills", 1920, 1080)
	nexusSmokeAssert(skills_geometry["w"] == 460 && skills_geometry["h"] == 680, "embedded Skills panel did not preserve the approved fixed size")
	var/list/default_chat_geometry = normalizeClassicGeometry(null, "chat", 1920, 1080)
	var/list/default_bar_geometry = normalizeClassicGeometry(null, "bar", 1920, 1080)
	nexusSmokeAssert(default_chat_geometry["w"] == 540 && default_chat_geometry["h"] == 480, "Classic chat did not receive its approved default size")
	nexusSmokeAssert(default_bar_geometry["x"] == round((1920 - default_bar_geometry["w"]) / 2) && default_bar_geometry["y"] + default_bar_geometry["h"] == 1080, "primary hotbar is not centered flush with the bottom edge")
	var/list/sense_geometry = resizeClassicGeometry(normalizeClassicGeometry(null, "sense", 1920, 1080), "sense", 1920, 1080, 1366, 768)
	var/list/target_geometry = resizeClassicGeometry(normalizeClassicGeometry(null, "target", 1920, 1080), "target", 1920, 1080, 1366, 768)
	nexusSmokeAssert(target_geometry["x"] + target_geometry["w"] <= sense_geometry["x"], "Classic target covered Sense after changing resolution")
	var/mob/user = new
	var/mob/refresh_user = new
	var/datum/ClassicHud/refresh_hud = new(refresh_user)
	refresh_hud.payloads["stats"] = "previous"
	refresh_hud.shouldRefreshWidget("stats")
	nexusSmokeAssert(!refresh_hud.shouldRefreshWidget("stats", TRUE), "Classic rebuilt unchanged slow panels within their refresh interval")
	nexusSmokeAssert(refresh_hud.shouldRefreshWidget("stats"), "Classic throttled an explicit user refresh")
	refresh_hud.last_widget_refresh["stats"] = world.time - 10
	nexusSmokeAssert(refresh_hud.shouldRefreshWidget("stats", TRUE), "Classic did not resume periodic data updates")
	refresh_user.nexus_classic_layout["stats"]["collapsed"] = TRUE
	refresh_hud.last_widget_refresh["stats"] = world.time - 10
	nexusSmokeAssert(!refresh_hud.shouldRefreshWidget("stats", TRUE), "Classic rebuilt a collapsed panel")
	refresh_hud.payloads -= "stats"
	nexusSmokeAssert(refresh_hud.shouldRefreshWidget("stats", TRUE), "Classic skipped the initial payload of a reopened panel")
	del(refresh_hud)
	del(refresh_user)
	var/obj/legacy_skill = new(user)
	legacy_skill.Skill = 1
	legacy_skill.hotbar_type = null
	var/datum/ClassicSnapshot/skills_snapshot = user.captureClassicData("skills")
	nexusSmokeAssert(isNexusTechniqueObject(legacy_skill) && skills_snapshot.subjects["\ref[legacy_skill]"] == legacy_skill, "Skills panel omitted a legacy owned skill without hotbar_type")
	del(skills_snapshot)
	del(legacy_skill)
	var/obj/PressurePunch/punch = new(user)
	user.last_pressurePunch = world.time
	var/list/state = punch.getClassicCooldown(user)
	// Float timestamp subtraction can differ by a fraction of a tick.
	nexusSmokeAssert(state["remaining"] > 0 && state["remaining"] <= pressure_punch_cooldown_ticks / 10 + 0.1, "Classic Pressure Punch cooldown [state["remaining"]] does not match [pressure_punch_cooldown_ticks / 10]")
	var/obj/Keep_Body/support = new(user)
	// BYOND real-time timestamps lose sub-minute precision at this date; compare clock domains.
	support.next_use = world.realtime + 600
	state = support.getClassicCooldown(user)
	nexusSmokeAssert(state["remaining"] > 0 && state["remaining"] <= 120, "Classic wall-clock cooldown [state["remaining"]] does not match 60")
	var/obj/Giant_Form/form = new(user)
	state = form.getClassicSkillState(user)
	nexusSmokeAssert(state["state"] == "ready", "Classic could not read a ready skill without optional stance fields")
	user.using_giant_form = TRUE
	state = form.getClassicSkillState(user)
	nexusSmokeAssert(state["state"] == "active", "Classic did not report an active toggle")
	user.using_giant_form = FALSE
	form.next_use = world.time + 30
	state = form.getClassicCooldown(user)
	nexusSmokeAssert(state["remaining"] > 0 && state["remaining"] <= 3.1, "Classic world-time cooldown [state["remaining"]] does not match 3")
	user.nexus_classic_slots = list()
	user.nexus_classic_slots.len = 36
	user.nexus_classic_slots[1] = user.classicBindingForObject(punch)
	user.nexus_classic_slots[2] = user.classicBindingForObject(form)
	user.nexus_hotkey_bindings = list("CTRL+1" = user.classicBindingForObject(punch))
	user.migrateClassicSlotKeys()
	user.nexus_hotkey_bindings["ALT+1"] = list("kind" = "slot", "slot" = 1)
	var/list/slot_key_map = user.buildClassicSlotKeyMap()
	nexusSmokeAssert(slot_key_map["1"] == user.getClassicSlotKeys(1), "Classic key map lost multiple shortcuts or their order")
	user.nexus_hotkey_bindings -= "ALT+1"
	slot_key_map = user.buildClassicSlotKeyMap()
	nexusSmokeAssert(slot_key_map["1"] == "CTRL+1", "Classic retained a removed shortcut")
	nexusSmokeAssert(user.nexus_hotkey_bindings["CTRL+1"]["kind"] == "slot" && user.resolveNexusHotkeyBinding("CTRL+1") == punch, "Classic migration lost an existing hotkey")
	user.swapClassicSlots(1, 2)
	nexusSmokeAssert(user.resolveNexusHotkeyBinding("CTRL+1") == form, "Classic key followed the object instead of its slot")
	user.clearClassicSlot(1)
	nexusSmokeAssert(!user.resolveNexusHotkeyBinding("CTRL+1") && user.getClassicSlotKeys(1) == "CTRL+1", "Clearing an action lost its slot key")
	user.nexus_classic_slots[1] = user.classicBindingForObject(form)
	user.nexus_classic_slots[36] = user.classicBindingForObject(form)
	user.nexus_hotkey_bindings["SHIFT+3"] = list("kind" = "slot", "slot" = 36)
	nexusSmokeAssert(user.resolveNexusHotkeyBinding("SHIFT+3") == form, "The third hotbar cannot activate its last slot")
	nexusSmokeAssert(findtext(user.getNexusBindingDisplayName(user.nexus_hotkey_bindings["SHIFT+3"]), "Bar 3 / slot 12:"), "Slot binding names do not identify their action")
	nexusSmokeAssert(user.resolveClassicSlot(2) == punch && user.resolveClassicSlot(1) == form, "Classic reorder lost skill identity")
	var/mob/default_bar_user = new
	var/obj/Manual_Attack/default_attack = new(default_bar_user)
	var/obj/Meditate/default_meditate = new(default_bar_user)
	default_bar_user.nexus_classic_slots = list()
	default_bar_user.nexus_classic_slots.len = 12
	default_bar_user.nexus_hotkey_bindings = list(
		"Space" = default_bar_user.classicBindingForObject(default_attack),
		"J" = default_bar_user.classicBindingForObject(default_meditate))
	default_bar_user.populateClassicDefaultSlots()
	nexusSmokeAssert(default_bar_user.resolveClassicSlot(1) == default_attack && default_bar_user.resolveClassicSlot(2) == default_meditate, "Classic default bar omitted Space Attack or J Meditate")
	var/list/preserved_default_binding = default_bar_user.nexus_classic_slots[1]
	default_bar_user.nexus_hotkey_bindings["B"] = default_bar_user.classicBindingForObject(default_meditate)
	default_bar_user.populateClassicDefaultSlots()
	nexusSmokeAssert(default_bar_user.nexus_classic_slots[1] == preserved_default_binding && !default_bar_user.nexus_classic_slots[3], "Classic default population overwrote a customized bar")
	del(default_bar_user)
	user.swapClassicSlots(0, 2)
	nexusSmokeAssert(user.resolveClassicSlot(2) == punch, "Classic accepted an invalid slot index")
	user.clearClassicSlot(2)
	nexusSmokeAssert(!user.resolveClassicSlot(2), "Classic clearing a slot retained its action")
	user.nexus_classic_slots[2] = user.classicBindingForObject(punch)
	punch.loc = null
	nexusSmokeAssert(!user.resolveClassicSlot(2), "Classic kept using a skill removed from the character")
	del(punch)
	var/mob/target = new
	user.Target = target
	var/datum/ClassicSnapshot/snapshot = user.captureClassicData("target")
	nexusSmokeAssert(!snapshot.rows.len && !user.nexus_classic_capture, "Classic exposed a missing target or leaked capture state")
	del(snapshot)
	var/list/catalog = getClassicSections()
	nexusSmokeAssert(("actions" in catalog) && ("playtest" in catalog) && ("sagas" in catalog) && ("factions" in catalog), "Classic omitted a required function category")
	var/previous_classic_ui = classic_ui
	classic_ui = FALSE
	user.max_ki = max(1, user.max_ki)
	snapshot = user.captureClassicData("stats")
	classic_ui = previous_classic_ui
	var/list/stat_labels = list()
	for(var/list/row in snapshot.rows) stat_labels += row["label"]
	nexusSmokeAssert(("Strength" in stat_labels) && ("Recovery" in stat_labels) && ("Critical Chance:" in stat_labels), "Classic Stats omitted attributes when native classic_ui was disabled")
	del(snapshot)
	user.setNexusMainVitalsScale(300)
	nexusSmokeAssert(user.nexus_main_vitals_scale == 150, "Vitals scale accepted an excessive size")
	user.setNexusMainVitalsScale(-1)
	nexusSmokeAssert(user.nexus_main_vitals_scale == 50, "Vitals scale accepted an unreadable size")
	user.verbs += /mob/verb/Settings
	var/verb_token = "classic-command:[md5("\ref[user]|/mob/verb/Settings")]"
	var/list/verb_binding = user.classicBindingFromToken(verb_token)
	nexusSmokeAssert(islist(verb_binding) && user.resolveClassicVerbSource(verb_binding) == user, "Classic rejected an owned visible verb")
	user.verbs -= /mob/verb/Settings
	nexusSmokeAssert(!user.resolveClassicBinding(verb_binding), "Classic kept a removed verb executable")
	var/obj/items/item = new(user)
	item.can_hotbar = 0
	user.item_list += item
	snapshot = user.captureClassicData("inventory")
	var/found_inventory_count = FALSE
	for(var/list/inventory_row in snapshot.rows)
		if(inventory_row["label"] == "ITEMS CARRIED" && text2num("[inventory_row["value"]]") == user.item_list.len) found_inventory_count = TRUE
	nexusSmokeAssert(found_inventory_count && snapshot.subjects["\ref[item]"] == item, "Inventory panel omitted its item count or an owned item action token")
	del(snapshot)
	user.assignClassicSlot(3, "classic-skill:\ref[item]")
	nexusSmokeAssert(user.isNexusHotkeyObjectAvailable(item) && user.resolveClassicSlot(3) == item, "Classic could not assign a non-legacy-hotbar inventory item")
	item.loc = null
	nexusSmokeAssert(!user.resolveClassicSlot(3), "Classic executed an item no longer owned")
	del(item)
	user.initializeClassicBars()
	var/original_bar_count = user.nexus_classic_bars.len
	var/dynamic_bar
	for(var/n in 1 to 8) dynamic_bar = user.createClassicBar()
	nexusSmokeAssert(user.nexus_classic_bars.len == original_bar_count + 8, "Classic bars still have a fixed count limit")
	for(var/n in 1 to 5) user.addClassicBarSlots(dynamic_bar, 12)
	var/list/dynamic_settings = user.nexus_classic_bars[dynamic_bar]
	var/list/dynamic_slots = dynamic_settings["slots"]
	nexusSmokeAssert(dynamic_slots.len == 61, "Classic bars still cap their slots at 12 or 36")
	var/last_slot = dynamic_slots[dynamic_slots.len]
	user.nexus_classic_slots[last_slot] = user.classicBindingForObject(form)
	user.nexus_hotkey_bindings["ALT+R"] = list("kind" = "slot", "slot" = last_slot)
	nexusSmokeAssert(user.resolveNexusHotkeyBinding("ALT+R") == form, "Dynamic slot hotkey cannot resolve its action")
	var/list/page_three = user.buildClassicActionBar(FALSE, dynamic_bar, 6)
	nexusSmokeAssert(page_three.len == 1 && page_three[1]["slot"] == last_slot, "Editor pagination discarded slots beyond the old cap")
	user.removeClassicBarSlot(dynamic_bar, dynamic_slots[1])
	nexusSmokeAssert(user.resolveNexusHotkeyBinding("ALT+R") == form, "Removing a slot renumbered another slot's hotkey")
	var/savefile/bar_backup = new
	bar_backup["bars"] << user.nexus_classic_bars
	var/list/restored_bars
	bar_backup["bars"] >> restored_bars
	var/list/restored_settings = restored_bars[dynamic_bar]
	var/list/restored_slots = restored_settings["slots"]
	nexusSmokeAssert(restored_slots.len == 60 && restored_slots[60] == last_slot, "Saved dynamic bars lost their slot IDs")
	user.removeClassicBar(dynamic_bar)
	nexusSmokeAssert(!(dynamic_bar in user.nexus_classic_bars) && !("ALT+R" in user.nexus_hotkey_bindings) && user.resolveNexusHotkeyBinding("SHIFT+3") == form, "Deleting a bar damaged another bar or kept deleted shortcuts")
	del(target)
	del(user)

proc/runNexusVitalsLayoutSmokeTests()
	runNexusHudBitmapTextSmokeTests()
	var/mob/owner = new
	owner.icon = 'src/Icons/PlayerIcons/BaseIcons/NewHumanIconsFromGuppinas/BaseHumanPale.dmi'
	owner.Ki = 8000
	owner.max_ki = 8000
	var/obj/NexusHud/VitalsPanel/panel = new
	panel.initialize(owner)
	panel.setScreenPosition(92, 62)
	var/obj/Buff/Focus/focus = new(owner)
	focus.suffix = "Active"
	owner.current_buff = focus
	owner.bp_mult += focus.buff_bp - 1
	for(var/scale_percent in list(50, 75, 100, 125, 150, 75))
		owner.nexus_main_vitals_scale = scale_percent
		panel.update(owner)
		var/scale = scale_percent / 100
		var/icon/backdrop = icon(panel.icon)
		var/icon/bar = icon(panel.health_row.icon)
		var/obj/NexusHud/ActiveModifiersReadout/buffs = panel.active_modifiers_readout
		var/icon/buff_backdrop = icon(buffs.icon)
		var/matrix/panel_transform = panel.transform
		nexusSmokeAssert(!(panel.appearance_flags & KEEP_TOGETHER) && panel_transform.a == 1 && panel_transform.e == 1 && !panel_transform.b && !panel_transform.c && !panel_transform.d && !panel_transform.f && !panel.pixel_x && !panel.pixel_y, "Vitals [scale_percent]% rescaled the entire composed panel")
		nexusSmokeAssert(backdrop.Width() == round(296 * scale) && backdrop.Height() == round(136 * scale) && panel.screen_loc == "LEFT:92,BOTTOM:62", "Vitals [scale_percent]% lost its native pixel size or drag anchor")
		nexusSmokeAssert(bar.Width() == round(168 * scale) && panel.health_row.pixel_x + bar.Width() <= backdrop.Width(), "Vitals [scale_percent]% bar escaped its panel")
		for(var/obj/NexusHud/VitalRow/row in list(panel.willpower_row, panel.health_row, panel.energy_row, panel.stamina_row))
			assertNexusHudBitmapText(row.primary_text)
			assertNexusHudBitmapText(row.detail_text)
			nexusSmokeAssert(row.detail_text.pixel_x >= row.maptext_x + row.maptext_width && row.detail_text.maptext_width > 0 && row.detail_text.pixel_x + row.detail_text.maptext_width <= bar.Width(), "Vitals [scale_percent]% labels overlap their values")
			var/list/expected_labels = scale < 1 ? list("WP","HP","KI","STA") : list("WILLPOWER","HEALTH","ENERGY","STAMINA")
			nexusSmokeAssert(row.primary_text.rendered_text in expected_labels, "Vitals [scale_percent]% truncated a status label")
		nexusSmokeAssert(panel.energy_row.detail_text.rendered_text == "(8000) 100%", "Vitals [scale_percent]% clipped or wrapped the current energy amount")
		nexusSmokeAssert(buffs.alpha == 255 && findtext(buffs.header_text.text_value, "Focus") && findtext(buffs.first_row_text.rendered_text, "BP 1.18x"), "Buffs [scale_percent]% lost the active Focus summary")
		nexusSmokeAssert(buff_backdrop.Width() == backdrop.Width() && buffs.pixel_y >= backdrop.Height() + 4, "Buffs [scale_percent]% overlaps the vitals frame")
		nexusSmokeAssert(buffs.header_text.pixel_y + buffs.header_text.maptext_height <= buff_backdrop.Height() && buffs.first_row_text.pixel_y + buffs.first_row_text.maptext_height <= buffs.header_text.pixel_y && buffs.second_row_text.pixel_y + buffs.second_row_text.maptext_height <= buffs.first_row_text.pixel_y, "Buffs [scale_percent]% clips or overlaps its text rows")
		for(var/obj/NexusHud/ActiveModifierText/text_row in buffs.vis_contents)
			if(text_row.text_value) assertNexusHudBitmapText(text_row)
		var/icon/row_preview = icon('src/Icons/UI/NexusHudGlyphs.dmi',"8-32")
		row_preview.Crop(1,1,bar.Width(),4*(bar.Height()+4))
		var/preview_y = 1
		for(var/obj/NexusHud/VitalRow/row in list(panel.stamina_row,panel.energy_row,panel.health_row,panel.willpower_row))
			row_preview.Blend(row.icon,ICON_OVERLAY,1,preview_y)
			for(var/obj/NexusHudBitmapText/label in row.vis_contents)
				row_preview.Blend(label.icon,ICON_OVERLAY,label.pixel_x+1,preview_y+label.pixel_y)
			preview_y += bar.Height()+4
		fcopy(row_preview,"VitalsTextSmoke[scale_percent].png")
		for(var/list/energy_case in list(list(222,99.9),list(0,0),list(987654,100),list(1.0e9,99.9)))
			panel.energy_row.update("ENERGY",energy_case[2],"", "#37cfff",scale,energy_case[1])
			assertNexusHudBitmapText(panel.energy_row.detail_text)
			nexusSmokeAssert(panel.energy_row.detail_text.rendered_text == panel.energy_row.detail_text.text_value && findtext(panel.energy_row.detail_text.rendered_text,"[energy_case[2]]%"),"Vitals [scale_percent]% truncated energy [energy_case[1]] / [energy_case[2]]%: [panel.energy_row.detail_text.rendered_text]")
	// Live value/name changes, narrow layouts, overflow, and clearing an active buff.
	focus.name = "<Focus> & a very long custom combat buff name"
	focus.buff_spd = 1.35
	focus.buff_reg = 1.2
	focus.buff_ki = 1.1
	focus.buff_str = 1.2
	focus.buff_dur = 1.3
	focus.buff_for = 1.4
	focus.buff_res = 1.5
	panel.update(owner)
	nexusSmokeAssert(findtext(panel.active_modifiers_readout.header_text.text_value, "<Focus> &") && findtext(panel.active_modifiers_readout.first_row_text.text_value, "SPD 1.35x"), "Buff text is stale or does not preserve literal names")
	for(var/columns in list(20, 35, 46, 60))
		var/list/summary = owner.getNexusActiveHudModifierSummary(8, columns)
		nexusSmokeAssert(length(summary["title"]) + 8 <= columns && length(summary["first_row"]) <= columns && length(summary["second_row"]) <= columns && findtext(summary["second_row"], "MORE"), "Buff summary overflows [columns] columns or silently loses extra stats")
	owner.current_buff = null
	focus.suffix = null
	owner.bp_mult -= focus.buff_bp - 1
	panel.update(owner)
	var/obj/NexusHud/ActiveModifiersReadout/cleared_buffs = panel.active_modifiers_readout
	nexusSmokeAssert(!cleared_buffs.alpha && !cleared_buffs.header_text.alpha && !cleared_buffs.first_row_text.alpha && !cleared_buffs.second_row_text.alpha && !cleared_buffs.header_text.icon && !cleared_buffs.first_row_text.icon && !cleared_buffs.second_row_text.icon, "Deactivated buff left a blank panel or stale text")
	del(focus)
	del(panel)
	del(owner)

proc/assertNexusHudBitmapText(obj/NexusHudBitmapText/label)
	nexusSmokeAssert(label && label.icon && !label.maptext && label.rendered_text,"HUD text has no rendered glyphs or still depends on maptext")
	nexusSmokeAssert(label.text_width <= label.maptext_width && label.text_height <= label.maptext_height,"HUD glyphs exceed their measured text box")
	var/icon/raster = icon(label.icon)
	nexusSmokeAssert(raster.Width() == label.maptext_width && raster.Height() == label.maptext_height,"HUD text raster does not match its layout box")
	var/visible_pixel = FALSE
	for(var/py = 1, py <= raster.Height() && !visible_pixel, py++)
		for(var/px = 1, px <= raster.Width(), px++)
			var/pixel = raster.GetPixel(px,py)
			if(pixel && pixel != "#00000000")
				visible_pixel = TRUE
				break
	nexusSmokeAssert(visible_pixel,"HUD text is entirely transparent despite a nonempty label")

proc/runNexusHudBitmapTextSmokeTests()
	var/obj/NexusHudBitmapText/label = new
	for(var/list/fixture in list(list("BUILD CATALOG",16,176,20),list("Science",12,60,14),list("(8000) 100%",12,96,14),list("(8000) 100%",8,63,11),list("<A> & B",12,100,16),list("Ação / É água",12,150,20)))
		label.maptext_width = fixture[3]
		label.maptext_height = fixture[4]
		label.setBitmapText(fixture[1],fixture[2],"#eee3cf","left",TRUE)
		assertNexusHudBitmapText(label)
		nexusSmokeAssert(label.rendered_text == fixture[1],"A standard HUD label was truncated")
	label.maptext_width = 100
	label.maptext_height = 20
	label.setBitmapText("Long custom blueprint names must end with visible dots",12)
	nexusSmokeAssert(findtext(label.rendered_text,"...") && label.text_width <= 100,"Long HUD labels are clipped instead of deliberately shortened")
	label.setBitmapText("Line one\nLine two",8)
	nexusSmokeAssert(!findtext(label.text_value,"\n"),"HUD labels can wrap through input line breaks")
	var/icon/unchanged_icon = label.icon
	label.setBitmapText("Line one\nLine two",8)
	nexusSmokeAssert(label.icon == unchanged_icon,"An unchanged HUD label was rebuilt")
	for(var/index = 1, index <= 520, index++) label.setBitmapText("[index]%",12)
	nexusSmokeAssert(nexus_hud_text_icon_cache.len <= 512,"Changing numeric readouts grows the text cache without limit")
	label.setBitmapText("")
	nexusSmokeAssert(!label.icon && !label.rendered_text,"Clearing a HUD label left stale glyphs")
	del(label)
	world.log << "HUD_BITMAP_TEXT_SMOKE_PASSED: actual glyph pixels, metrics, literal text, energy, truncation, bounded cache"
