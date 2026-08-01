var/list/nexus_action_button_icon_cache = list()
var/list/nexus_shortcut_button_icon_cache = list()
var/list/nexus_shortcut_bar_icon_cache = list()

proc/getNexusActionButtonIcon(active, accent_color)
	var/cache_key = "[active]-[accent_color]"
	if(nexus_action_button_icon_cache[cache_key]) return nexus_action_button_icon_cache[cache_key]
	var/icon/button_icon = icon('UserNamesBarsUi.png')
	button_icon.Scale(108, 20)
	button_icon.DrawBox(active ? "#51391f" : "#251c13", 1, 1, 108, 20)
	button_icon.DrawBox("#140e09", 1, 1, 108, 2)
	button_icon.DrawBox("#140e09", 1, 19, 108, 20)
	button_icon.DrawBox("#140e09", 1, 1, 2, 20)
	button_icon.DrawBox("#140e09", 107, 1, 108, 20)
	button_icon.DrawBox(active ? accent_color : "#765936", 3, 3, 106, 3)
	button_icon.DrawBox(active ? accent_color : "#765936", 3, 18, 106, 18)
	button_icon.DrawBox(active ? accent_color : "#765936", 3, 3, 3, 18)
	button_icon.DrawBox("#c39a55", 5, 5, 6, 6)
	button_icon.DrawBox("#c39a55", 103, 5, 104, 6)
	nexus_action_button_icon_cache[cache_key] = button_icon
	return button_icon

proc/getNexusShortcutBarIcon(button_count)
	button_count = max(1, round(button_count))
	var/cache_key = "buttons-[button_count]"
	if(nexus_shortcut_bar_icon_cache[cache_key]) return nexus_shortcut_bar_icon_cache[cache_key]
	var/bar_width = button_count * 28 + 8
	var/icon/bar_icon = icon('UserNamesBarsUi.png')
	bar_icon.Scale(bar_width, 34)
	bar_icon.DrawBox(rgb(29, 22, 14, 236), 1, 1, bar_width, 34)
	bar_icon.DrawBox("#130d08", 1, 1, bar_width, 3)
	bar_icon.DrawBox("#130d08", 1, 32, bar_width, 34)
	bar_icon.DrawBox("#130d08", 1, 1, 3, 34)
	bar_icon.DrawBox("#130d08", bar_width - 2, 1, bar_width, 34)
	bar_icon.DrawBox("#4f7f43", 4, 4, bar_width - 3, 5)
	bar_icon.DrawBox("#7d6338", 4, 29, bar_width - 3, 30)
	nexus_shortcut_bar_icon_cache[cache_key] = bar_icon
	return bar_icon

proc/drawNexusShortcutGlyph(icon/button_icon, action_id, glyph_color)
	switch(action_id)
		if("inventory")
			button_icon.DrawBox(glyph_color, 7, 10, 20, 21)
			button_icon.DrawBox(glyph_color, 10, 7, 17, 10)
			button_icon.DrawBox("#26180c", 12, 9, 15, 11)
			button_icon.DrawBox("#26180c", 9, 13, 18, 14)
		if("skills")
			for(var/index = 0, index <= 10, index++)
				button_icon.DrawBox(glyph_color, 7 + index, 18 - index, 9 + index, 20 - index)
			button_icon.DrawBox("#e7c77d", 7, 18, 12, 20)
			button_icon.DrawBox("#79532a", 5, 20, 9, 23)
		if("sense")
			button_icon.DrawBox(glyph_color, 6, 13, 21, 16)
			button_icon.DrawBox(glyph_color, 9, 10, 18, 19)
			button_icon.DrawBox("#17100a", 11, 12, 16, 17)
			button_icon.DrawBox("#f1dfae", 13, 13, 14, 14)
		if("world")
			button_icon.DrawBox(glyph_color, 8, 7, 19, 22)
			button_icon.DrawBox(glyph_color, 6, 10, 21, 19)
			button_icon.DrawBox("#1b3f2c", 12, 7, 15, 22)
			button_icon.DrawBox("#1b3f2c", 6, 14, 21, 16)
		if("chat")
			button_icon.DrawBox(glyph_color, 6, 8, 21, 19)
			button_icon.DrawBox(glyph_color, 9, 19, 13, 22)
			button_icon.DrawBox("#2a1d12", 9, 12, 11, 14)
			button_icon.DrawBox("#2a1d12", 14, 12, 16, 14)
			button_icon.DrawBox("#2a1d12", 19, 12, 19, 14)
		if("hotkeys")
			for(var/key_x in list(7, 12, 17))
				for(var/key_y in list(9, 14, 19)) button_icon.DrawBox(glyph_color, key_x, key_y, key_x + 3, key_y + 3)
		if("admin")
			button_icon.DrawBox(glyph_color, 7, 8, 20, 12)
			button_icon.DrawBox(glyph_color, 9, 12, 18, 21)
			button_icon.DrawBox("#2a140f", 12, 13, 15, 18)
			button_icon.DrawBox("#f3d28d", 13, 14, 14, 15)

proc/getNexusShortcutButtonIcon(action_id, active = FALSE, accent_color = "#7bcf68")
	var/cache_key = "[action_id]-[active]-[accent_color]"
	if(nexus_shortcut_button_icon_cache[cache_key]) return nexus_shortcut_button_icon_cache[cache_key]
	var/icon/button_icon = icon('UserNamesBarsUi.png')
	button_icon.Scale(26, 26)
	button_icon.DrawBox(active ? "#4d3a20" : "#2b2116", 1, 1, 26, 26)
	button_icon.DrawBox("#130d08", 1, 1, 26, 2)
	button_icon.DrawBox("#130d08", 1, 25, 26, 26)
	button_icon.DrawBox("#130d08", 1, 1, 2, 26)
	button_icon.DrawBox("#130d08", 25, 1, 26, 26)
	button_icon.DrawBox(active ? accent_color : "#765a35", 3, 3, 24, 3)
	button_icon.DrawBox(active ? accent_color : "#765a35", 3, 24, 24, 24)
	drawNexusShortcutGlyph(button_icon, action_id, active ? "#fff0bd" : accent_color)
	nexus_shortcut_button_icon_cache[cache_key] = button_icon
	return button_icon

client/var/tmp
	list/nexus_action_buttons
	list/nexus_shortcut_buttons
	obj/NexusHud/ShortcutBarBackground/nexus_shortcut_bar
	datum/NexusPlayerMenu/nexus_player_menu

mob/proc/hasCompleteActionHud()
	if(!client || !islist(client.nexus_action_buttons) || client.nexus_action_buttons.len != 3) return FALSE
	var/list/found_actions = list()
	for(var/obj/NexusHud/ActionButton/button in client.nexus_action_buttons)
		if(button && button.action_id) found_actions[button.action_id] = TRUE
	return found_actions["lethal"] && found_actions["rp_mode"] && found_actions["character"]

mob/proc/getNexusShortcutTypes()
	var/list/shortcut_types = list(
		/obj/NexusHud/ShortcutButton/Inventory,
		/obj/NexusHud/ShortcutButton/Skills,
		/obj/NexusHud/ShortcutButton/Sense,
		/obj/NexusHud/ShortcutButton/Chat,
		/obj/NexusHud/ShortcutButton/Hotkeys)
	if(IsAdmin())
		shortcut_types += /obj/NexusHud/ShortcutButton/World
		shortcut_types += /obj/NexusHud/ShortcutButton/Admin
	return shortcut_types

mob/proc/hasCompleteShortcutHud()
	if(!client || !islist(client.nexus_shortcut_buttons)) return FALSE
	var/list/required_types = getNexusShortcutTypes()
	if(client.nexus_shortcut_buttons.len != required_types.len) return FALSE
	for(var/shortcut_type in required_types)
		var/found_type = FALSE
		for(var/obj/NexusHud/ShortcutButton/button in client.nexus_shortcut_buttons)
			if(button && button.type == shortcut_type)
				found_type = TRUE
				break
		if(!found_type) return FALSE
	return TRUE

mob/proc/rebuildActionHud()
	if(!client) return
	if(islist(client.nexus_action_buttons))
		for(var/obj/NexusHud/ActionButton/old_button in client.nexus_action_buttons)
			client.screen -= old_button
			del(old_button)
	client.nexus_action_buttons = list(
		new /obj/NexusHud/ActionButton/Lethal,
		new /obj/NexusHud/ActionButton/RPMode,
		new /obj/NexusHud/ActionButton/Character)
	for(var/obj/NexusHud/ActionButton/button in client.nexus_action_buttons)
		button.update(src)

mob/proc/rebuildShortcutHud()
	if(!client) return
	if(client.nexus_shortcut_bar)
		client.screen -= client.nexus_shortcut_bar
		del(client.nexus_shortcut_bar)
		client.nexus_shortcut_bar = null
	if(islist(client.nexus_shortcut_buttons))
		for(var/obj/NexusHud/ShortcutButton/old_button in client.nexus_shortcut_buttons)
			client.screen -= old_button
			del(old_button)
	client.nexus_shortcut_buttons = list()
	var/list/shortcut_types = getNexusShortcutTypes()
	client.nexus_shortcut_bar = new
	client.nexus_shortcut_bar.icon = getNexusShortcutBarIcon(shortcut_types.len)
	var/button_x = 12
	for(var/shortcut_type in shortcut_types)
		var/obj/NexusHud/ShortcutButton/button = new shortcut_type
		button.screen_loc = "LEFT:[button_x],TOP:-12"
		button.update(src)
		client.nexus_shortcut_buttons += button
		button_x += 28

mob/proc/initializeActionHud()
	if(!client || !playerCharacter) return
	winset(src, "button24", "is-visible=false")
	winset(src, "button26", "is-visible=false")
	winset(src, "button62", "is-visible=false")
	winset(src, "LETHAL", "is-visible=false")
	winset(src, "lethalcombat", "is-visible=false")
	if(!hasCompleteActionHud()) rebuildActionHud()
	if(!hasCompleteShortcutHud()) rebuildShortcutHud()
	if(client.nexus_shortcut_bar && !(client.nexus_shortcut_bar in client.screen)) client.screen += client.nexus_shortcut_bar
	for(var/obj/NexusHud/ActionButton/button in client.nexus_action_buttons)
		if(!(button in client.screen)) client.screen += button
	for(var/obj/NexusHud/ShortcutButton/shortcut in client.nexus_shortcut_buttons)
		if(!(shortcut in client.screen)) client.screen += shortcut
	refreshActionHud()

mob/proc/refreshActionHud()
	if(!client || !playerCharacter) return
	if(!hasCompleteActionHud())
		initializeActionHud()
		return
	if(!hasCompleteShortcutHud()) rebuildShortcutHud()
	if(client.nexus_shortcut_bar && !(client.nexus_shortcut_bar in client.screen)) client.screen += client.nexus_shortcut_bar
	for(var/obj/NexusHud/ActionButton/button in client.nexus_action_buttons)
		if(!(button in client.screen)) client.screen += button
		button.update(src)
	for(var/obj/NexusHud/ShortcutButton/shortcut in client.nexus_shortcut_buttons)
		if(!(shortcut in client.screen)) client.screen += shortcut
		shortcut.update(src)

mob/proc/removeActionHud()
	if(!client) return
	if(islist(client.nexus_action_buttons))
		for(var/obj/NexusHud/ActionButton/button in client.nexus_action_buttons)
			client.screen -= button
			del(button)
		client.nexus_action_buttons = null
	if(islist(client.nexus_shortcut_buttons))
		for(var/obj/NexusHud/ShortcutButton/shortcut in client.nexus_shortcut_buttons)
			client.screen -= shortcut
			del(shortcut)
		client.nexus_shortcut_buttons = null
	if(client.nexus_shortcut_bar)
		client.screen -= client.nexus_shortcut_bar
		del(client.nexus_shortcut_bar)
		client.nexus_shortcut_bar = null
	if(client.nexus_player_menu) del(client.nexus_player_menu)

obj/NexusHud/ShortcutBarBackground
	mouse_opacity = 0
	plane = 20
	layer = 108
	screen_loc = "LEFT:8,TOP:-8"

obj/NexusHud/ActionButton
	mouse_opacity = 2
	layer = 110
	maptext_x = 4
	maptext_y = 5
	maptext_width = 100
	maptext_height = 11
	var/tmp/mob/owner
	var/action_id
	var/accent_color = "#8fa5bd"

	New(mob/new_owner)
		. = ..()
		owner = new_owner
		update(owner)

	proc/isActive(mob/character)
		return FALSE

	proc/getLabel(mob/character)
		return uppertext(action_id)

	proc/update(mob/character)
		if(!character) return
		owner = character
		var/active = isActive(character)
		icon = getNexusActionButtonIcon(active, accent_color)
		var/text_color = active ? "#fff1bd" : "#d2bd93"
		maptext = "<div style='font-family:Courier New;font-size:8px;font-weight:bold;letter-spacing:.5px;color:[text_color];text-align:center;text-shadow:1px 1px #000'>[getLabel(character)]</div>"

	Click(location, control, params)
		if(!owner || usr != owner || !owner.client) return
		switch(action_id)
			if("lethal") owner.toggleLethalIntent()
			if("rp_mode") owner.toggleRPMode()
			if("character") owner.showCharacterSheet()
		owner.refreshActionHud()

	Lethal
		action_id = "lethal"
		accent_color = "#ff4d5f"
		screen_loc = "RIGHT:-8,TOP:-8"
		desc = "Toggle lethal intent."

		isActive(mob/character)
			return character.sparring_mode == LETHAL_COMBAT

		getLabel(mob/character)
			return character.sparring_mode == LETHAL_COMBAT ? "LETHAL  ON" : "LETHAL  OFF"

	RPMode
		action_id = "rp_mode"
		accent_color = "#ff9b54"
		screen_loc = "RIGHT:-8,TOP:-32"
		desc = "Toggle RP Mode. While active, combat interaction is blocked."

		isActive(mob/character)
			return character.rp_mode

		getLabel(mob/character)
			return character.rp_mode ? "RPMODE  ON" : "RPMODE  OFF"

	Character
		action_id = "character"
		accent_color = "#62c8ff"
		screen_loc = "RIGHT:-8,TOP:-56"
		desc = "Open the detailed character sheet."

		getLabel(mob/character)
			return "CHARACTER"

obj/NexusHud/ShortcutButton
	mouse_opacity = 2
	plane = 20
	layer = 110
	var/tmp/mob/owner
	var/action_id
	var/accent_color = "#82c46f"

	proc/isActive(mob/character)
		return FALSE

	proc/update(mob/character)
		if(!character) return
		owner = character
		icon = getNexusShortcutButtonIcon(action_id, isActive(character), accent_color)

	Click(location, control, params)
		if(!owner || usr != owner || !owner.client) return
		switch(action_id)
			if("inventory") owner.showNexusPlayerMenu("inventory")
			if("skills") owner.showNexusPlayerMenu("skills")
			if("sense") owner.showNexusPlayerMenu("sense")
			if("world") owner.showNexusPlayerMenu("world")
			if("chat") owner.toggleNexusChatHud()
			if("hotkeys") owner.showNexusHotkeyEditor()
			if("admin") owner.showNexusAdminPanel(FALSE)
		owner.refreshActionHud()

	Inventory
		action_id = "inventory"
		accent_color = "#d6aa5d"
		desc = "Inventory"

	Skills
		action_id = "skills"
		accent_color = "#ef876d"
		desc = "Skills and techniques"

	Sense
		action_id = "sense"
		accent_color = "#72d9f5"
		desc = "Sense"

	World
		action_id = "world"
		accent_color = "#78cc72"
		desc = "World information"

	Chat
		action_id = "chat"
		accent_color = "#e6c47b"
		desc = "Show or hide chat"

		isActive(mob/character)
			return character.client && character.client.nexus_chat_hud && character.client.nexus_chat_hud.is_visible

	Hotkeys
		action_id = "hotkeys"
		accent_color = "#b39cff"
		desc = "Hotkey editor"

	Admin
		action_id = "admin"
		accent_color = "#ff6d61"
		desc = "Admin control panel"

datum/NexusPlayerMenu
	var/tmp/mob/owner
	var/tmp/section = "inventory"
	var/tmp/list/browser_icon_resources
	var/tmp/browser_icon_index = 0

	New(mob/new_owner, starting_section = "inventory")
		. = ..()
		owner = new_owner
		browser_icon_resources = list()
		section = normalizeSection(starting_section)

	Del()
		if(owner)
			owner << browse(null, "window=NexusPlayerMenu")
			if(owner.client && owner.client.nexus_player_menu == src) owner.client.nexus_player_menu = null
		. = ..()

	proc/canUse()
		return owner && owner.client && owner.playerCharacter && usr == owner

	proc/normalizeSection(requested_section)
		if(requested_section == "world" && owner && owner.IsAdmin()) return requested_section
		if(requested_section in list("inventory", "skills", "sense")) return requested_section
		return "inventory"

	proc/getSections()
		var/list/sections = list("inventory", "skills", "sense")
		if(owner && owner.IsAdmin()) sections += "world"
		return sections

	proc/getBrowserIcon(atom/subject)
		if(!owner || !subject || !subject.icon) return null
		var/cache_key = "\ref[subject]|[subject.icon]|[subject.icon_state]|[subject.dir]"
		if(browser_icon_resources[cache_key]) return browser_icon_resources[cache_key]
		var/icon/preview = icon(subject.icon, subject.icon_state, subject.dir ? subject.dir : SOUTH)
		if(!preview) return null
		browser_icon_index++
		var/resource_name = "nexus_menu_icon_[browser_icon_index].png"
		owner << browse_rsc(preview, resource_name)
		browser_icon_resources[cache_key] = resource_name
		return resource_name

	proc/buildIcon(atom/subject, alt_text)
		var/resource_name = getBrowserIcon(subject)
		if(!resource_name) return "<div class='item-icon missing'>?</div>"
		return "<div class='item-icon'><img src='[resource_name]' alt='[html_encode(alt_text)]'></div>"

	proc/buildNavigation()
		var/navigation = ""
		for(var/menu_section in getSections())
			var/active_class = menu_section == section ? "tab active" : "tab"
			navigation += "<a class='[active_class]' href='byond://?src=\ref[src]&action=section&id=[menu_section]'>[uppertext(menu_section)]</a>"
		return navigation

	proc/buildInventory()
		var/html = ""
		var/obj/Resources/resources = owner.GetResourceObject()
		if(resources)
			resources.Update_value()
			html += "<div class='card resource'><span>RESOURCE</span><b>[Commas(resources.Value)] resources</b><small>Crafting and technology currency carried by this character.</small></div>"
		var/item_count = 0
		for(var/obj/items/item in owner.item_list)
			item_count++
			var/status_text = item.suffix ? "[item.suffix]" : "Carried"
			var/description_text = item.desc ? "[item.desc]" : "No description available."
			html += "<a class='card with-icon' href='byond://?src=\ref[src]&action=use_item&item=\ref[item]'>[buildIcon(item, "[item]")]<div class='card-copy'><span>[html_encode(status_text)]</span><b>[html_encode("[item]")]</b><small>[html_encode(description_text)]</small></div><em>CLICK TO INTERACT</em></a>"
		if(!item_count) html += "<div class='empty'>This character is not carrying any items.</div>"
		return html

	proc/buildSkills()
		var/html = ""
		var/skill_count = 0
		for(var/obj/skill in owner.contents)
			if(!skill.hotbar_type) continue
			skill_count++
			var/mastery_text = nexusIsFiniteNumber(skill.Mastery) ? "Mastery [round(skill.Mastery, 0.1)]%" : "Learned"
			var/use_link = hascall(skill, "Hotbar_use") ? "<a class='use' href='byond://?src=\ref[src]&action=use_skill&skill=\ref[skill]'>USE</a>" : ""
			html += "<div class='card with-icon'>[buildIcon(skill, "[skill]")]<div class='card-copy'><span>[html_encode("[skill.hotbar_type]")]</span><b>[html_encode("[skill]")]</b><small>[html_encode(mastery_text)]</small></div>[use_link]</div>"
		if(!skill_count) html += "<div class='empty'>No techniques are registered on this character.</div>"
		return html

	proc/buildSense()
		if(!owner.current_area) return "<div class='empty'>Sense data is unavailable at this location.</div>"
		if(owner.Android && !owner.Scouter && !owner.Cyber_Scanner) return "<div class='empty'>Androids require a scanner to read nearby energy.</div>"
		if(!owner.Android && !owner.sense_obj && !owner.Scouter && !owner.Cyber_Scanner) return "<div class='empty'>This character has not learned Sense and has no active scanner.</div>"
		var/html = ""
		var/target_count = 0
		var/turf/origin = owner.base_loc()
		var/has_advanced_sense = !!(locate(/obj/Advanced_Sense) in owner)
		var/has_sense_three = !!(locate(/obj/Sense3) in owner)
		for(var/mob/target in owner.current_area.mob_list)
			if(target == owner || target.type == /mob/Body || target.unsenseable || !target.loc) continue
			if(!CanSense(owner, target)) continue
			target_count++
			var/location_text = target.locz() == owner.locz() ? "[getdir(origin, target)] / [getdist(origin, target)] tiles" : "Different depth"
			var/power_text = owner.Scouter || owner.Cyber_Scanner ? Commas(Scouter_Reading(target, owner.Scouter, unlimited = TRUE)) : "[owner.Sense_Power(target)]% of your power"
			var/details = "<small>[html_encode(power_text)]</small>"
			if(has_advanced_sense || has_sense_three || owner.Scouter || owner.Cyber_Scanner)
				details += "<small>Health [round(target.Health)]% / Energy [round(target.Ki / max(1, target.max_ki) * 100)]%</small>"
			if(has_sense_three)
				details += "<small>[html_encode("[target.Race]")] / [html_encode("[target.alignment]")]</small>"
				details += "<div class='sense-stats'><i>STR [target.strpcnt_rate()]</i><i>END [target.durpcnt_rate()]</i><i>SPD [target.spdpcnt_rate()]</i><i>FOR [target.powpcnt_rate()]</i><i>RES [target.respcnt_rate()]</i><i>OFF [target.offpcnt_rate()]</i><i>DEF [target.defpcnt_rate()]</i></div>"
			html += "<a class='card with-icon sense-card' href='byond://?src=\ref[src]&action=target&target=\ref[target]'>[buildIcon(target, "[target]")]<div class='card-copy'><span>[html_encode(location_text)]</span><b>[html_encode("[target]")]</b>[details]</div><em>SET AS TARGET</em></a>"
		if(!target_count) html += "<div class='empty'>No readable energy signatures are nearby.</div>"
		return html

	proc/buildWorld()
		if(!owner.IsAdmin()) return "<div class='empty'>World inspection is restricted to administrators.</div>"
		var/turf/current_turf = owner.base_loc()
		var/location_text = current_turf ? "[current_turf.x], [current_turf.y], [current_turf.z]" : "Unknown"
		var/area/current_location = owner.get_area()
		var/area_text = current_location ? "[current_location]" : "Unknown area"
		var/player_count = 0
		var/player_cards = ""
		for(var/mob/player in players)
			if(!player.client) continue
			player_count++
			player_cards += "<div class='card compact with-icon'>[buildIcon(player, "[player]")]<div class='card-copy'><span>ONLINE / [player.client.inactivity] inactivity</span><b>[html_encode("[player]")]</b><small>[html_encode("[player.Race] / [player.Class]")]</small><small>[player.x], [player.y], [player.z] / BP [Commas(player.BP)]</small></div></div>"
		return "<div class='world-grid'><div><small>YEAR</small><b>[round(Year, 0.1)]</b></div><div><small>PLAYERS</small><b>[player_count]</b></div><div><small>AREA</small><b>[html_encode(area_text)]</b></div><div><small>COORDINATES</small><b>[location_text]</b></div><div><small>OOC</small><b>[OOC ? "ENABLED" : "DISABLED"]</b></div><div><small>TOURNAMENT</small><b>[Tournament ? "ACTIVE" : "INACTIVE"]</b></div></div><h2>CONNECTED CHARACTERS</h2><div class='cards'>[player_cards]</div>"

	proc/buildContent()
		switch(section)
			if("inventory") return buildInventory()
			if("skills") return buildSkills()
			if("sense") return buildSense()
			if("world") return buildWorld()
		return ""

	proc/buildHtml()
		var/rendered_content = buildContent()
		if(section != "world") rendered_content = "<div class='cards'>[rendered_content]</div>"
		return {"<!doctype html><html><head><meta charset='utf-8'><title>Nexus Menu</title><style>[getNexusRpgBrowserCss()]
		*{box-sizing:border-box}html,body{margin:0;min-height:100%;font:12px 'Courier New',monospace}.shell{min-height:100vh;padding:10px}.header{position:sticky;top:0;z-index:2;border:2px solid #755a36;padding:8px;background:#21190f}.top{display:flex;align-items:center;gap:8px}.title{margin-right:auto}.title b{display:block;font-size:17px;letter-spacing:1px}.title small{display:block;margin-top:2px}.close{padding:6px 9px}.tabs{display:flex;gap:4px;margin-top:8px}.tab{flex:1;padding:7px;text-align:center}.content{margin-top:7px;border:2px solid #684e2f;padding:8px}.cards{display:grid;grid-template-columns:repeat(3,minmax(180px,1fr));gap:6px}.card{position:relative;display:block;min-height:92px;padding:9px;border:2px solid #624b30;background:#2a2117;color:#ead7ad;text-decoration:none}.card:hover{border-color:#bd9655;background:#392a1b}.card span,.card b,.card small,.card em{display:block}.card span{color:#c69c57;font-size:9px}.card b{margin:6px 0;font-size:13px}.card small{color:#b9a37c;line-height:1.35}.card em{position:absolute;right:7px;bottom:6px;color:#e2bd72;font-size:8px;font-style:normal}.card.resource{border-color:#85652e}.card.compact{min-height:72px}.use{position:absolute;right:7px;bottom:6px;padding:4px 8px;border:1px solid #9a7440;color:#ffe2a5;text-decoration:none}.world-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:6px;margin-bottom:10px}.world-grid div{min-height:64px;padding:9px;border:2px solid #644b2e;background:#2a2117}.world-grid small,.world-grid b{display:block}.world-grid b{margin-top:7px;color:#f0d79e}.empty{padding:36px;text-align:center;color:#b9a37c}h2{margin:10px 0 7px;padding:7px;border:2px solid #755a36;font-size:13px}@media(max-width:760px){.cards{grid-template-columns:repeat(2,1fr)}.world-grid{grid-template-columns:repeat(2,1fr)}}
		.card.with-icon{display:flex;gap:9px}.card-copy{flex:1;min-width:0}.item-icon{width:48px;height:48px;flex:0 0 48px;border:2px solid #59452d;background:#15110c;display:flex;align-items:center;justify-content:center;image-rendering:pixelated;overflow:hidden}.item-icon img{max-width:44px;max-height:44px;image-rendering:pixelated}.item-icon.missing{color:#826d4d;font-size:18px}.sense-card{min-height:132px}.sense-stats{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:2px;margin-top:5px}.sense-stats i{font-size:8px;color:#d1b47d;font-style:normal}
		</style></head><body><div class='shell'><div class='header'><div class='top'><div class='title'><b>NEXUS MENU / [uppertext(section)]</b><small>Pixel interface for the systems formerly hidden in legacy tabs</small></div><a class='close' href='byond://?src=\ref[src]&action=close'>CLOSE</a></div><div class='tabs'>[buildNavigation()]</div></div><div class='content'>[rendered_content]</div></div></body></html>"}

	proc/show()
		if(!owner || !owner.client || !owner.playerCharacter)
			del(src)
			return
		owner << browse(buildHtml(), "window=NexusPlayerMenu;size=980x680;can_resize=true;can_close=true")

	Topic(href, list/href_list)
		if(!canUse()) return
		switch(href_list["action"])
			if("section") section = normalizeSection(href_list["id"])
			if("use_item")
				var/obj/items/item = locate(href_list["item"])
				if(item && item in owner.item_list) item.Click()
			if("use_skill")
				var/obj/skill = locate(href_list["skill"])
				if(skill && skill in owner.contents && skill.hotbar_type && hascall(skill, "Hotbar_use")) skill:Hotbar_use(owner)
			if("target")
				var/mob/new_target = locate(href_list["target"])
				if(new_target && new_target != owner && new_target.loc && owner.current_area && new_target in owner.current_area.mob_list && CanSense(owner, new_target)) owner.Target = new_target
			if("close")
				del(src)
				return
		show()

mob/proc/showNexusPlayerMenu(section = "inventory")
	if(!client || !playerCharacter) return
	if(client.nexus_player_menu) del(client.nexus_player_menu)
	client.nexus_player_menu = new /datum/NexusPlayerMenu(src, section)
	client.nexus_player_menu.show()
