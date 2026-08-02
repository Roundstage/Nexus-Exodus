var/list/nexus_action_button_icon_cache = list()
var/list/nexus_shortcut_button_icon_cache = list()
var/list/nexus_shortcut_bar_icon_cache = list()

var/nexus_live_browser_refresh_ticks = 10

proc/getNexusLiveBrowserScript(datum/handler, restore_scroll_y = 0)
	restore_scroll_y = round(Clamp(text2num("[restore_scroll_y]"), 0, 100000))
	return {"<script>
	var nexusLiveHandler='\ref[handler]';
	function nexusLiveTopic(data){data.src=nexusLiveHandler;if(window.BYOND&&BYOND.topic){BYOND.topic(data);return;}var query='';for(var key in data){if(query)query+='&';query+=encodeURIComponent(key)+'='+encodeURIComponent(data\[key]);}window.location.href='byond://?'+query;}
	function nexusLiveScrollY(){return Math.max(document.documentElement?document.documentElement.scrollTop:0,document.body?document.body.scrollTop:0,window.pageYOffset||0);}
	function nexusStartLiveUpdates(){window.setTimeout(function(){window.scrollTo(0,[restore_scroll_y]);nexusLiveTopic({action:'heartbeat',scroll_y:nexusLiveScrollY()});window.setInterval(function(){nexusLiveTopic({action:'heartbeat',scroll_y:nexusLiveScrollY()});},500);},0);}
	if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',nexusStartLiveUpdates);else nexusStartLiveUpdates();
	</script>"}

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
		if("cmd")
			button_icon.DrawBox(glyph_color, 5, 8, 21, 10)
			button_icon.DrawBox(glyph_color, 5, 19, 21, 21)
			button_icon.DrawBox(glyph_color, 5, 8, 7, 21)
			button_icon.DrawBox(glyph_color, 19, 8, 21, 21)
			button_icon.DrawBox("#21170e", 9, 12, 11, 14)
			button_icon.DrawBox("#21170e", 13, 15, 17, 17)
		if("menu")
			button_icon.DrawBox(glyph_color, 6, 8, 21, 10)
			button_icon.DrawBox(glyph_color, 6, 13, 21, 15)
			button_icon.DrawBox(glyph_color, 6, 18, 21, 20)
			button_icon.DrawBox("#21170e", 8, 9, 9, 9)
			button_icon.DrawBox("#21170e", 8, 14, 9, 14)
			button_icon.DrawBox("#21170e", 8, 19, 9, 19)
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
		/obj/NexusHud/ShortcutButton/Hotkeys,
		/obj/NexusHud/ShortcutButton/Menu)
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
	if(client.nexus_character_sheet) del(client.nexus_character_sheet)

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
			if("menu") owner.Settings()
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

	Menu
		action_id = "menu"
		accent_color = "#e0bd74"
		desc = "Open the Escape menu"

	Admin
		action_id = "admin"
		accent_color = "#ff6d61"
		desc = "Admin control panel"

mob/proc/showNexusCommandPrompt()
	if(!client || !playerCharacter) return
	if(!client.nexus_chat_hud) initializeNexusChatHud()
	else if(!client.nexus_chat_hud.is_visible) client.nexus_chat_hud.setVisible(TRUE)
	if(nexus_interface_layout == "side_tabs")
		winset(src, "nexuschatwindow.command", "focus=true")
		return
	var/command_text = input(src, "Enter the same command you would type in the CMD bar.", "CMD") as text|null
	if(command_text) winset(src, null, "command=[command_text]")

mob/verb/focusNexusCommand()
	set hidden = TRUE
	if(!client || !playerCharacter) return
	if(nexus_interface_layout == "side_tabs")
		if(winget(src, "nexuschatwindow.command", "focus") == "true") winset(src, "mapwindow.map", "focus=true")
		else showNexusCommandPrompt()
		return
	showNexusCommandPrompt()

datum/NexusPlayerMenu
	var/tmp/mob/owner
	var/tmp/section = "inventory"
	var/tmp/list/browser_icon_resources
	var/tmp/browser_icon_index = 0
	var/tmp/live_refresh_loop
	var/tmp/last_browser_heartbeat
	var/tmp/last_scroll_y
	var/tmp/last_render_signature
	var/tmp/auto_refresh_paused

	New(mob/new_owner, starting_section = "inventory")
		. = ..()
		owner = new_owner
		browser_icon_resources = list()
		section = normalizeSection(starting_section)
		last_browser_heartbeat = world.time

	Del()
		if(owner)
			owner << browse(null, "window=NexusPlayerMenu")
			if(owner.client && owner.client.nexus_player_menu == src) owner.client.nexus_player_menu = null
		. = ..()

	proc/canUse()
		return owner && owner.client && owner.playerCharacter && usr == owner

	proc/hasLiveOwner()
		return owner && owner.client && owner.playerCharacter && owner.client.nexus_player_menu == src

	proc/isBrowserOpen()
		if(!hasLiveOwner()) return FALSE
		var/window_visibility = winget(owner, "NexusPlayerMenu", "is-visible")
		if(window_visibility == "false") return FALSE
		if(window_visibility == "true") return TRUE
		return world.time - last_browser_heartbeat <= 30

	proc/recordHeartbeat(scroll_y)
		last_browser_heartbeat = world.time
		var/numeric_scroll_y = text2num("[scroll_y]")
		if(isnum(numeric_scroll_y)) last_scroll_y = round(Clamp(numeric_scroll_y, 0, 100000))

	proc/startLiveRefresh()
		set waitfor = FALSE
		if(live_refresh_loop) return
		live_refresh_loop = TRUE
		while(src && hasLiveOwner())
			sleep(nexus_live_browser_refresh_ticks)
			if(!src || !hasLiveOwner() || !isBrowserOpen()) break
			if(!auto_refresh_paused) show(FALSE)
		if(src)
			live_refresh_loop = FALSE
			del(src)

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

	proc/getSkillDamageData(obj/skill)
		var/list/data = list("factor" = 0, "model" = "Dynamic / utility", "range" = "See mechanics", "mechanics" = "Behavior is described by the technique.", "requirements" = "Owned and available on the skill bar.")
		if(istype(skill, /obj/Attacks/TenkaichiMeleeTechnique))
			var/obj/Attacks/TenkaichiMeleeTechnique/technique = skill
			data["factor"] = technique.damage_multiplier * (1 + technique.extra_hits * technique.extra_hit_multiplier)
			data["model"] = "Physical"
			data["range"] = technique.dash_range > 1 ? "Up to [technique.dash_range] tiles" : "Adjacent target"
			var/list/effects = list("[technique.extra_hits + 1] hit(s)", "[technique.knockback_multiplier]x knockback")
			if(technique.stun_ticks) effects += "[round(technique.stun_ticks / 10, 0.1)]s stun"
			if(technique.bleed_fraction) effects += "[round(technique.bleed_fraction * 100)]% bleed"
			if(technique.breaks_guard) effects += "breaks guard"
			if(technique.line_reach) effects += "pierces [technique.line_reach] extra tile(s)"
			if(technique.splash_radius) effects += "[technique.splash_radius]-tile splash"
			data["mechanics"] = "[technique.behavior]: [jointext(effects, ", ")]."
			var/list/requirements = list()
			if(technique.requires_weapon) requirements += owner.using_sword() ? "Weapon equipped: READY" : "Weapon equipped: MISSING"
			if(technique.requires_unarmed) requirements += owner.using_sword() ? "Must be unarmed: BLOCKED" : "Must be unarmed: READY"
			if(technique.behavior in list("grapple_throw", "grapple_slam")) requirements += owner.grabbedObject ? "Must hold a grabbed target: READY" : "Must hold a grabbed target: MISSING"
			if(!requirements.len) requirements += "No weapon or grab requirement"
			data["requirements"] = jointext(requirements, " / ")
			data["cost"] = "[technique.energy_cost] stamina-drain units"
			data["cooldown"] = "[round(technique.cooldown_ticks / 10, 0.1)] seconds"
			return data
		if(istype(skill, /obj/Attacks/TenkaichiSpecialStyle/ChargedProjectile))
			var/obj/Attacks/TenkaichiSpecialStyle/ChargedProjectile/projectile_skill = skill
			data["factor"] = projectile_skill.projectile_damage_factor * (projectile_skill.explosion_size ? 2 : 1)
			data["model"] = projectile_skill.strength_scaled ? "Physical" : "Ki"
			data["range"] = projectile_skill.explosion_size ? "40 tiles / [projectile_skill.explosion_size]-tile explosion" : "40 tiles / direct impact"
			data["mechanics"] = projectile_skill.explosion_size ? "Charges for [round(projectile_skill.charge_ticks / 10, 0.1)] seconds, then deals direct and splash damage within a shared maximum budget." : "Charges for [round(projectile_skill.charge_ticks / 10, 0.1)] seconds, then launches a cutting projectile with [projectile_skill.projectile_shockwave]-tile knockback."
			data["requirements"] = projectile_skill.requires_weapon ? (owner.using_sword() ? "Weapon equipped: READY" : "Weapon equipped: MISSING") : "No weapon requirement"
			data["cost"] = "[projectile_skill.energy_cost] energy-drain units"
			data["cooldown"] = "[round(projectile_skill.cooldown_ticks / 10, 0.1)] seconds"
			return data
		if(skill.hotbar_type == "Beam" && istype(skill, /obj/Attacks))
			var/obj/Attacks/beam_skill = skill
			data["factor"] = beam_skill.damage_factor
			data["model"] = "Ki"
			data["range"] = "[beam_skill.Range] tiles"
			data["mechanics"] = "Sustained beam; can enter a beam clash. Its impact mode and distance modifiers can change the final result."
			data["requirements"] = "Enough energy; cannot fire while grabbed, disabled or in RP Mode"
			data["cost"] = "Drain [beam_skill.Drain]"
			data["cooldown"] = "[round(beam_skill_cooldown_ticks / 10, 0.1)] seconds"
			return data
		if(istype(skill, /obj/Attacks/Big_Bang_Attack))
			data["factor"] = skill_big_bang_damage_factor * 2
			data["model"] = "Ki"
			data["range"] = "Projectile / 4-tile explosion"
			data["mechanics"] = "Charged direct hit plus explosion, capped by one shared damage budget."
		else if(istype(skill, /obj/Attacks/Charge))
			data["factor"] = skill_charge_damage_factor * 2
			data["model"] = "Ki"
			data["range"] = "Projectile / 2-tile explosion"
			data["mechanics"] = "Charged direct hit plus explosion."
		else if(istype(skill, /obj/Attacks/Cyber_Charge))
			data["factor"] = skill_cyber_charge_damage_factor * 2
			data["model"] = "Ki"
			data["range"] = "Projectile / 1-tile explosion"
		else if(istype(skill, /obj/Attacks/Makosen))
			data["factor"] = skill_makosen_total_factor
			data["model"] = "Ki"
			data["range"] = "Short-range barrage"
			data["mechanics"] = "Many small shots share one per-target damage budget."
		else if(istype(skill, /obj/Attacks/Scatter_Shot))
			data["factor"] = skill_scatter_shot_total_factor
			data["model"] = "Ki"
			data["range"] = "Selected target / homing barrage"
			data["mechanics"] = "Surrounds the selected target with homing shots that share one damage budget."
		else if(istype(skill, /obj/Attacks/Sokidan))
			data["factor"] = skill_sokidan_total_factor
			data["model"] = "Ki"
			data["range"] = "Guided projectile"
			data["mechanics"] = "Player-guided homing projectile with impact and splash damage."
		else if(istype(skill, /obj/Attacks/Kienzan))
			data["factor"] = skill_kienzan_damage_factor
			data["model"] = "Ki"
			data["range"] = "Guided piercing projectile"
			data["mechanics"] = "Can hit multiple targets and loses half of its remaining damage after each pierce."
		else if(istype(skill, /obj/RockThrow))
			data["factor"] = 3.5
			data["model"] = "Physical"
			data["range"] = "Selected target / thrown projectile"
			data["mechanics"] = "Powerful mode uses one heavy rock; rapid mode uses weaker repeated rocks."
		else if(istype(skill, /obj/RockSlide))
			data["factor"] = 8.25
			data["model"] = "Physical"
			data["range"] = "Area barrage"
			data["mechanics"] = "Maximum preview for fifteen rocks; actual hits and total damage vary."
		else if(istype(skill, /obj/RockTomb))
			data["factor"] = 8
			data["model"] = "Physical"
			data["range"] = "Selected target / heavy projectile"
			data["mechanics"] = "Heavy rock; mastery adds secondary explosion damage."
		else if(istype(skill, /obj/Dropkick))
			data["factor"] = skill_dropkick_opening_factor + skill_dropkick_finisher_factor
			data["model"] = "Physical"
			data["range"] = "Lunge to selected target"
			data["mechanics"] = "Opening kick plus finisher; may initiate Dragon Rush on collision."
		else if(istype(skill, /obj/WolfFangFist))
			data["factor"] = 5
			data["model"] = "Physical"
			data["range"] = "Advancing five-hit melee"
			data["mechanics"] = "Five advancing strikes; may initiate Dragon Rush on collision."
		else if(istype(skill, /obj/Dash_Attack))
			data["factor"] = skill_dash_attack_max_factor
			data["model"] = "Physical"
			data["range"] = "Movement-scaled dash"
			data["mechanics"] = "Preview shows the maximum factor; actual damage grows with distance traveled."
		else if(istype(skill, /obj/RoundhouseKick))
			data["factor"] = 4
			data["model"] = "Physical"
			data["range"] = "Adjacent area strike"
		else if(istype(skill, /obj/PressurePunch))
			data["factor"] = 6
			data["model"] = "Physical"
			data["range"] = "Adjacent area strike"
		else if(istype(skill, /obj/Attacks/Blast))
			data["factor"] = skill_blast_total_factor
			data["model"] = "Ki"
			data["range"] = "Rapid projectile"
			data["mechanics"] = "Repeated basic blasts; preview is the per-projectile damage budget."
		if(skill.hotbar_type in list("Melee", "Blast", "Beam", "Ability")) data["requirements"] = "Cannot attack while grabbed, KO, disabled or in RP Mode; some techniques also need a selected target"
		if("Drain" in skill.vars && isnum(skill.vars["Drain"]))
			var/skill_drain = skill.vars["Drain"]
			data["cost"] = "Drain [skill_drain]"
		return data

	proc/buildDetailRow(label, value)
		return "<div><small>[html_encode(label)]</small><b>[html_encode("[value]")]</b></div>"

	proc/showExamineWindow(title, subtitle, icon_html, body_html)
		if(!owner || !owner.client) return
		auto_refresh_paused = TRUE
		var/html = {"<!doctype html><html><head><meta charset='utf-8'><title>[html_encode(title)]</title><style>[getNexusRpgBrowserCss()]
		*{box-sizing:border-box}html,body{margin:0;min-height:100%;font:12px 'Courier New',monospace}.shell{padding:12px}.header{display:flex;gap:12px;align-items:center;border:2px solid #755a36;background:#21190f;padding:10px}.header h1{margin:0;color:#f0d79e;font-size:18px}.header p{margin:4px 0 0;color:#b9a37c}.header-copy{flex:1}.back{padding:7px 10px}.body{margin-top:8px;border:2px solid #684e2f;background:#21190f;padding:10px}.description{padding:10px;border:1px solid #624b30;background:#2a2117;color:#d9c49a;line-height:1.5}.details{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:6px;margin-top:8px}.details div{min-height:68px;padding:8px;border:2px solid #624b30;background:#2a2117}.details small,.details b{display:block}.details small{color:#c69c57}.details b{margin-top:7px;color:#ead7ad;line-height:1.35}.notice{margin-top:8px;padding:8px;border-left:3px solid #d6aa5d;color:#b9a37c}.item-icon{width:56px;height:56px;flex:0 0 56px;border:2px solid #59452d;background:#15110c;display:flex;align-items:center;justify-content:center;image-rendering:pixelated;overflow:hidden}.item-icon img{max-width:52px;max-height:52px;image-rendering:pixelated}.item-icon.missing{color:#826d4d;font-size:18px}
		</style>[getNexusLiveBrowserScript(src, last_scroll_y)]</head><body><div class='shell'><div class='header'>[icon_html]<div class='header-copy'><h1>[html_encode(title)]</h1><p>[html_encode(subtitle)]</p></div><a class='back' href='byond://?src=\ref[src]&action=back'>BACK</a></div><div class='body'>[body_html]</div></div></body></html>"}
		owner << browse(html, "window=NexusPlayerMenu;size=980x680;can_resize=true;can_close=true")

	proc/showItemExamine(obj/items/item)
		var/description_text = item.desc ? "[item.desc]" : "No description available."
		var/details = buildDetailRow("STATUS", item.suffix ? item.suffix : "Carried")
		details += buildDetailRow("TYPE", item.type)
		if("Level" in item.vars && isnum(item.vars["Level"])) details += buildDetailRow("LEVEL", round(item.vars["Level"], 0.1))
		if("Durability" in item.vars && isnum(item.vars["Durability"])) details += buildDetailRow("DURABILITY", round(item.vars["Durability"], 0.1))
		if("Cost" in item.vars && isnum(item.vars["Cost"])) details += buildDetailRow("BASE VALUE", Commas(item.vars["Cost"]))
		showExamineWindow("[item]", "INVENTORY ITEM", buildIcon(item, "[item]"), "<div class='description'>[html_encode(description_text)]</div><div class='details'>[details]</div><div class='notice'>Left-click the item in Inventory to open its interaction menu.</div>")

	proc/showSkillExamine(obj/skill)
		var/list/data = getSkillDamageData(skill)
		var/mob/preview_target = ismob(owner.Target) && owner.Target != owner ? owner.Target : owner
		var/factor = data["factor"]
		var/raw_damage
		if(isnum(factor) && factor > 0)
			switch(data["model"])
				if("Physical") raw_damage = owner.getPhysicalCombatDamage(preview_target, factor)
				if("Ki") raw_damage = owner.getKiCombatDamage(preview_target, factor)
				else raw_damage = owner.getHybridCombatDamage(preview_target, factor)
		var/preview_label = preview_target == owner ? "SELF-STAT BASELINE" : "RAW VS [preview_target]"
		var/preview_value = isnum(raw_damage) ? "[round(raw_damage, 0.01)] Health ([factor]x factor)" : "No fixed raw-damage formula"
		var/details = buildDetailRow(preview_label, preview_value)
		details += buildDetailRow("DAMAGE MODEL", data["model"])
		details += buildDetailRow("RANGE", data["range"])
		details += buildDetailRow("COST", data["cost"] ? data["cost"] : "Dynamic / see description")
		details += buildDetailRow("COOLDOWN", data["cooldown"] ? data["cooldown"] : "No dedicated fixed cooldown documented")
		details += buildDetailRow("REQUIREMENTS", data["requirements"])
		var/description_text = skill.desc ? "[skill.desc]" : "No description available."
		var/body = "<div class='description'>[html_encode(description_text)]</div><div class='details'>[details]</div><div class='notice'><b>MECHANICS</b><br>[html_encode(data["mechanics"])]<br><br>Raw damage is calculated from your current stats before block, critical hits, shields, positioning and other situational modifiers.</div>"
		showExamineWindow("[skill]", "[skill.hotbar_type] / MASTERY [round(skill.Mastery, 0.1)]%", buildIcon(skill, "[skill]"), body)

	proc/showSenseExamine(mob/target)
		var/has_advanced_sense = !!(locate(/obj/Advanced_Sense) in owner)
		var/has_sense_three = !!(locate(/obj/Sense3) in owner)
		var/power_text = owner.Scouter || owner.Cyber_Scanner ? Commas(Scouter_Reading(target, owner.Scouter, unlimited = TRUE)) : "[owner.Sense_Power(target)]% of your power"
		var/details = buildDetailRow("SIGNATURE", power_text)
		details += buildDetailRow("POSITION", target.locz() == owner.locz() ? "[getdir(owner.base_loc(), target)] / [getdist(owner.base_loc(), target)] tiles" : "Different depth")
		if(has_advanced_sense || has_sense_three || owner.Scouter || owner.Cyber_Scanner)
			details += buildDetailRow("HEALTH", "[round(target.Health)]%")
			details += buildDetailRow("ENERGY", "[round(target.Ki / max(1, target.max_ki) * 100)]%")
		if(has_sense_three)
			details += buildDetailRow("IDENTITY", "[target.Race] / [target.alignment]")
			details += buildDetailRow("STAT READINGS", "STR [target.strpcnt_rate()] / END [target.durpcnt_rate()] / SPD [target.spdpcnt_rate()] / FOR [target.powpcnt_rate()] / RES [target.respcnt_rate()] / OFF [target.offpcnt_rate()] / DEF [target.defpcnt_rate()]")
		showExamineWindow("[target]", "SENSE SIGNATURE", buildIcon(target, "[target]"), "<div class='description'>Only information available to your current Sense or scanner level is shown.</div><div class='details'>[details]</div>")

	proc/showWorldExamine(mob/target)
		if(!target || !owner.IsAdmin()) return
		var/details = buildDetailRow("ACCOUNT", target.key ? target.key : "NPC / disconnected")
		details += buildDetailRow("RACE / CLASS", "[target.Race] / [target.Class]")
		details += buildDetailRow("COORDINATES", "[target.x], [target.y], [target.z]")
		details += buildDetailRow("BASE POWER", Commas(target.BP))
		details += buildDetailRow("HEALTH", "[round(target.Health, 0.1)]%")
		details += buildDetailRow("ENERGY", "[round(target.Ki, 0.1)] / [round(target.max_ki, 0.1)]")
		details += buildDetailRow("WILLPOWER", "[round(target.willpower, 0.1)] / [round(target.max_willpower, 0.1)]")
		details += buildDetailRow("RP / LETHAL", "[target.rp_mode ? "RP MODE" : "NORMAL"] / [target.sparring_mode == LETHAL_COMBAT ? "LETHAL" : "NON-LETHAL"]")
		var/edit_notice = owner.AdminLevel() >= 3 ? "Use EDIT in the World card to open the complete structured inspector." : "Editing requires Admin Level 3."
		showExamineWindow("[target]", "ADMIN WORLD INSPECTION", buildIcon(target, "[target]"), "<div class='description'>Current server-side character information.</div><div class='details'>[details]</div><div class='notice'>[edit_notice]</div>")

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
			var/use_url = "byond://?src=\ref[src]&action=use_item&item=\ref[item]"
			var/examine_url = "byond://?src=\ref[src]&action=examine_item&item=\ref[item]"
			html += "<div class='card with-icon with-actions' onmousedown=\"return nexusRightClick(window.event,'[examine_url]')\" oncontextmenu=\"window.location.href='[examine_url]';return false;\">[buildIcon(item, "[item]")]<div class='card-copy'><span>[html_encode(status_text)]</span><b>[html_encode("[item]")]</b><small>[html_encode(description_text)]</small></div><div class='card-actions'><a href='[use_url]'>USE</a><a href='[examine_url]'>EXAMINE</a></div></div>"
		if(!item_count) html += "<div class='empty'>This character is not carrying any items.</div>"
		return html

	proc/buildSkills()
		var/html = ""
		var/skill_count = 0
		for(var/obj/skill in owner.contents)
			if(!skill.hotbar_type) continue
			skill_count++
			var/mastery_text = nexusIsFiniteNumber(skill.Mastery) ? "Mastery [round(skill.Mastery, 0.1)]%" : "Learned"
			var/skill_examine_url = "byond://?src=\ref[src]&action=examine_skill&skill=\ref[skill]"
			var/use_link = hascall(skill, "Hotbar_use") ? "<a href='byond://?src=\ref[src]&action=use_skill&skill=\ref[skill]'>USE</a>" : ""
			html += "<div class='card with-icon with-actions' onmousedown=\"return nexusRightClick(window.event,'[skill_examine_url]')\" oncontextmenu=\"window.location.href='[skill_examine_url]';return false;\">[buildIcon(skill, "[skill]")]<div class='card-copy'><span>[html_encode("[skill.hotbar_type]")]</span><b>[html_encode("[skill]")]</b><small>[html_encode(mastery_text)]</small><small>Damage, range and usage details available.</small></div><div class='card-actions'>[use_link]<a href='[skill_examine_url]'>EXAMINE</a></div></div>"
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
			var/target_url = "byond://?src=\ref[src]&action=target&target=\ref[target]"
			var/sense_examine_url = "byond://?src=\ref[src]&action=examine_sense&target=\ref[target]"
			html += "<div class='card with-icon sense-card with-actions' onmousedown=\"return nexusRightClick(window.event,'[sense_examine_url]')\" oncontextmenu=\"window.location.href='[sense_examine_url]';return false;\">[buildIcon(target, "[target]")]<div class='card-copy'><span>[html_encode(location_text)]</span><b>[html_encode("[target]")]</b>[details]</div><div class='card-actions'><a href='[target_url]'>TARGET</a><a href='[sense_examine_url]'>EXAMINE</a></div></div>"
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
			var/world_examine_url = "byond://?src=\ref[src]&action=examine_world&target=\ref[player]"
			var/edit_link = owner.AdminLevel() >= 3 ? "<a href='byond://?src=\ref[src]&action=edit_world&target=\ref[player]'>EDIT</a>" : ""
			player_cards += "<div class='card compact with-icon with-actions' onmousedown=\"return nexusRightClick(window.event,'[world_examine_url]')\" oncontextmenu=\"window.location.href='[world_examine_url]';return false;\">[buildIcon(player, "[player]")]<div class='card-copy'><span>ONLINE / [player.client.inactivity] inactivity</span><b>[html_encode("[player]")]</b><small>[html_encode("[player.Race] / [player.Class]")]</small><small>[player.x], [player.y], [player.z] / BP [Commas(player.BP)]</small></div><div class='card-actions'><a href='[world_examine_url]'>EXAMINE</a>[edit_link]</div></div>"
		return "<div class='world-grid'><div><small>YEAR</small><b>[round(Year, 0.1)]</b></div><div><small>PLAYERS</small><b>[player_count]</b></div><div><small>AREA</small><b>[html_encode(area_text)]</b></div><div><small>COORDINATES</small><b>[location_text]</b></div><div><small>OOC</small><b>[OOC ? "ENABLED" : "DISABLED"]</b></div><div><small>TOURNAMENT</small><b>[Tournament ? "ACTIVE" : "INACTIVE"]</b></div></div><h2>CONNECTED CHARACTERS</h2><div class='cards'>[player_cards]</div>"

	proc/buildContent()
		switch(section)
			if("inventory") return buildInventory()
			if("skills") return buildSkills()
			if("sense") return buildSense()
			if("world") return buildWorld()
		return ""

	proc/buildHtml(rendered_content_override)
		var/rendered_content = isnull(rendered_content_override) ? buildContent() : rendered_content_override
		if(section != "world") rendered_content = "<div class='cards'>[rendered_content]</div>"
		return {"<!doctype html><html><head><meta charset='utf-8'><title>Nexus Menu</title><style>[getNexusRpgBrowserCss()]
		*{box-sizing:border-box}html,body{margin:0;min-height:100%;font:12px 'Courier New',monospace}.shell{min-height:100vh;padding:10px}.header{position:sticky;top:0;z-index:2;border:2px solid #755a36;padding:8px;background:#21190f}.top{display:flex;align-items:center;gap:8px}.title{margin-right:auto}.title b{display:block;font-size:17px;letter-spacing:1px}.title small{display:block;margin-top:2px}.close{padding:6px 9px}.tabs{display:flex;gap:4px;margin-top:8px}.tab{flex:1;padding:7px;text-align:center}.content{margin-top:7px;border:2px solid #684e2f;padding:8px}.cards{display:grid;grid-template-columns:repeat(3,minmax(180px,1fr));gap:6px}.card{position:relative;display:block;min-height:92px;padding:9px;border:2px solid #624b30;background:#2a2117;color:#ead7ad;text-decoration:none}.card.with-actions{padding-bottom:42px}.card:hover{border-color:#bd9655;background:#392a1b}.card span,.card b,.card small{display:block}.card span{color:#c69c57;font-size:9px}.card b{margin:6px 0;font-size:13px}.card small{color:#b9a37c;line-height:1.35}.card.resource{border-color:#85652e}.card.compact{min-height:72px}.card-actions{position:absolute;left:8px;right:8px;bottom:7px;display:flex;justify-content:flex-end;gap:5px}.card-actions a{display:block;padding:4px 8px;border:2px outset #9a7440;background:#49351f;color:#ffe2a5;text-decoration:none;font-size:9px;font-weight:bold}.card-actions a:active{border-style:inset}.world-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:6px;margin-bottom:10px}.world-grid div{min-height:64px;padding:9px;border:2px solid #644b2e;background:#2a2117}.world-grid small,.world-grid b{display:block}.world-grid b{margin-top:7px;color:#f0d79e}.empty{padding:36px;text-align:center;color:#b9a37c}h2{margin:10px 0 7px;padding:7px;border:2px solid #755a36;font-size:13px}@media(max-width:760px){.cards{grid-template-columns:repeat(2,1fr)}.world-grid{grid-template-columns:repeat(2,1fr)}}
		.card.with-icon{display:flex;gap:9px}.card-copy{flex:1;min-width:0}.item-icon{width:48px;height:48px;flex:0 0 48px;border:2px solid #59452d;background:#15110c;display:flex;align-items:center;justify-content:center;image-rendering:pixelated;overflow:hidden}.item-icon img{max-width:44px;max-height:44px;image-rendering:pixelated}.item-icon.missing{color:#826d4d;font-size:18px}.sense-card{min-height:132px}.sense-stats{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:2px;margin-top:5px}.sense-stats i{font-size:8px;color:#d1b47d;font-style:normal}
		.live-state{padding:5px 8px;border:2px solid #4f7f43;background:#1c2b18;color:#9ee88b;font-size:9px;font-weight:bold}
		</style><script>function nexusRightClick(e,url){e=e||window.event;if(e&&e.button==2){window.location.href=url;return false;}return true;}</script>[getNexusLiveBrowserScript(src, last_scroll_y)]</head><body><div class='shell'><div class='header'><div class='top'><div class='title'><b>NEXUS MENU / [uppertext(section)]</b><small>Live server state; updates automatically when values change</small></div><span class='live-state'>LIVE / 1s</span><a class='close' href='byond://?src=\ref[src]&action=close'>CLOSE</a></div><div class='tabs'>[buildNavigation()]</div></div><div class='content'>[rendered_content]</div></div></body></html>"}

	proc/show(force_refresh = TRUE)
		if(!owner || !owner.client || !owner.playerCharacter)
			del(src)
			return
		auto_refresh_paused = FALSE
		var/rendered_content = buildContent()
		var/render_signature = md5("[section]|[rendered_content]")
		if(!force_refresh && render_signature == last_render_signature) return
		last_render_signature = render_signature
		owner << browse(buildHtml(rendered_content), "window=NexusPlayerMenu;size=980x680;can_resize=true;can_close=true")
		if(force_refresh) last_browser_heartbeat = world.time
		startLiveRefresh()

	Topic(href, list/href_list)
		if(!canUse()) return
		switch(href_list["action"])
			if("heartbeat")
				recordHeartbeat(href_list["scroll_y"])
				return
			if("back")
				show(TRUE)
				return
			if("section") section = normalizeSection(href_list["id"])
			if("use_item")
				var/obj/items/item = locate(href_list["item"])
				if(item && item in owner.item_list) item.Click()
			if("use_skill")
				var/obj/skill = locate(href_list["skill"])
				if(skill && skill in owner.contents && skill.hotbar_type && hascall(skill, "Hotbar_use")) skill:Hotbar_use(owner)
			if("examine_item")
				var/obj/items/examined_item = locate(href_list["item"])
				if(examined_item && examined_item in owner.item_list) showItemExamine(examined_item)
				return
			if("examine_skill")
				var/obj/examined_skill = locate(href_list["skill"])
				if(examined_skill && examined_skill in owner.contents && examined_skill.hotbar_type) showSkillExamine(examined_skill)
				return
			if("examine_sense")
				var/mob/examined_target = locate(href_list["target"])
				if(examined_target && examined_target != owner && examined_target.loc && owner.current_area && examined_target in owner.current_area.mob_list && CanSense(owner, examined_target)) showSenseExamine(examined_target)
				return
			if("examine_world")
				var/mob/world_target = locate(href_list["target"])
				if(owner.IsAdmin() && world_target && world_target in players) showWorldExamine(world_target)
				return
			if("edit_world")
				var/mob/edit_target = locate(href_list["target"])
				if(owner.AdminLevel() >= 3 && edit_target && edit_target in players) owner.showNexusAdminInspector(edit_target)
				return
			if("target")
				var/mob/new_target = locate(href_list["target"])
				if(new_target && new_target != owner && new_target.loc && owner.current_area && new_target in owner.current_area.mob_list && CanSense(owner, new_target)) owner.Target = new_target
			if("close")
				del(src)
				return
		show(TRUE)

mob/proc/showNexusPlayerMenu(section = "inventory")
	if(!client || !playerCharacter) return
	if(client.nexus_player_menu) del(client.nexus_player_menu)
	client.nexus_player_menu = new /datum/NexusPlayerMenu(src, section)
	client.nexus_player_menu.show()
