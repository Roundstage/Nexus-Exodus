var/list/nexus_action_button_icon_cache = list()
var/list/nexus_shortcut_button_icon_cache = list()
var/list/nexus_shortcut_bar_icon_cache = list()

var/nexus_live_browser_refresh_ticks = 10
var/nexus_live_browser_heartbeat_milliseconds = 1000
var/nexus_live_browser_scroll_idle_ticks = 20
var/nexus_live_browser_scroll_placeholder = "NEXUS_SCROLL_POSITION"

proc/getNexusLiveBrowserScript(datum/handler, restore_scroll_y = 0)
	if("[restore_scroll_y]" != nexus_live_browser_scroll_placeholder)
		restore_scroll_y = round(Clamp(text2num("[restore_scroll_y]"), 0, 100000))
	return {"<script>
	var nexusLiveHandler='\ref[handler]';
	var nexusLiveRestoreScrollY=[restore_scroll_y];
	var nexusLiveScrollKey='nexus_live_scroll_'+nexusLiveHandler;
	var nexusLiveRestoring=true;
	var nexusLiveScrollTimer=null;
	function nexusLiveTopic(data){data.src=nexusLiveHandler;if(window.BYOND&&BYOND.topic){BYOND.topic(data);return;}var query='';for(var key in data){if(query)query+='&';query+=encodeURIComponent(key)+'='+encodeURIComponent(data\[key]);}window.location.href='byond://?'+query;}
	function nexusLiveScrollY(){return Math.max(document.documentElement?document.documentElement.scrollTop:0,document.body?document.body.scrollTop:0,window.pageYOffset||0);}
	function nexusReadStoredScroll(){try{var stored=window.sessionStorage?window.sessionStorage.getItem(nexusLiveScrollKey):null;if(stored!==null){var parsed=parseInt(stored,10);if(!isNaN(parsed))return Math.max(0,parsed);}}catch(error){}return null;}
	function nexusStoreLiveScroll(){if(nexusLiveRestoring)return;try{if(window.sessionStorage)window.sessionStorage.setItem(nexusLiveScrollKey,String(nexusLiveScrollY()));}catch(error){}}
	function nexusPublishLiveScroll(){nexusStoreLiveScroll();nexusLiveTopic({action:'heartbeat',scroll_y:nexusLiveScrollY()});}
	function nexusLiveOnScroll(){if(nexusLiveRestoring)return;nexusStoreLiveScroll();if(nexusLiveScrollTimer)window.clearTimeout(nexusLiveScrollTimer);nexusLiveScrollTimer=window.setTimeout(nexusPublishLiveScroll,80);}
	function nexusStartLiveUpdates(){var stored=nexusReadStoredScroll();var target=stored===null?nexusLiveRestoreScrollY:stored;window.addEventListener('scroll',nexusLiveOnScroll);window.addEventListener('beforeunload',function(){nexusLiveRestoring=false;nexusPublishLiveScroll();});window.setTimeout(function(){window.scrollTo(0,target);},0);window.setTimeout(function(){window.scrollTo(0,target);},80);window.setTimeout(function(){window.scrollTo(0,target);nexusLiveRestoring=false;nexusPublishLiveScroll();window.setInterval(nexusPublishLiveScroll,[nexus_live_browser_heartbeat_milliseconds]);},220);}
	if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',nexusStartLiveUpdates);else nexusStartLiveUpdates();
	</script>"}

proc/isNexusTechniqueObject(obj/candidate)
	if(!candidate || istype(candidate, /obj/items)) return FALSE
	return candidate.Skill == 1 && !!candidate.hotbar_type

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
		if("progression")
			button_icon.DrawBox(glyph_color, 13, 9, 15, 16)
			button_icon.DrawBox(glyph_color, 8, 14, 20, 16)
			button_icon.DrawBox(glyph_color, 8, 15, 10, 19)
			button_icon.DrawBox(glyph_color, 18, 15, 20, 19)
			button_icon.DrawBox("#f4d06f", 11, 5, 17, 10)
			button_icon.DrawBox("#f4d06f", 5, 18, 11, 23)
			button_icon.DrawBox("#f4d06f", 17, 18, 23, 23)
		if("milestones")
			button_icon.DrawBox(glyph_color, 8, 7, 20, 10)
			button_icon.DrawBox(glyph_color, 9, 10, 19, 16)
			button_icon.DrawBox(glyph_color, 5, 9, 9, 14)
			button_icon.DrawBox(glyph_color, 19, 9, 23, 14)
			button_icon.DrawBox(glyph_color, 13, 16, 15, 20)
			button_icon.DrawBox(glyph_color, 9, 20, 19, 23)
			button_icon.DrawBox("#fff0bd", 12, 11, 16, 14)
		if("build")
			button_icon.DrawBox(glyph_color, 6, 6, 19, 10)
			button_icon.DrawBox(glyph_color, 9, 10, 16, 13)
			for(var/index = 0, index <= 9, index++)
				button_icon.DrawBox(glyph_color, 14 - round(index / 2), 12 + index, 16 - round(index / 2), 14 + index)
			button_icon.DrawBox("#fff0bd", 7, 7, 17, 8)
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
		/obj/NexusHud/ShortcutButton/Progression,
		/obj/NexusHud/ShortcutButton/Milestones,
		/obj/NexusHud/ShortcutButton/Build,
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
	if(client.nexus_music_library_window) del(client.nexus_music_library_window)

obj/NexusHud/ShortcutBarBackground
	mouse_opacity = 0
	plane = NEXUS_FIXED_HUD_PLANE
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
			if("character") owner.toggleCharacterSheet()
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

		isActive(mob/character)
			return character.client && character.client.nexus_character_sheet

obj/NexusHud/ShortcutButton
	mouse_opacity = 2
	plane = NEXUS_FIXED_HUD_PLANE
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
			if("inventory") owner.toggleNexusPlayerMenu("inventory")
			if("skills") owner.toggleNexusPlayerMenu("skills")
			if("progression") owner.toggleProgressionTrees()
			if("milestones") owner.toggleProgressionTrees("Milestones")
			if("build") owner.ToggleBuildMenu()
			if("sense") owner.toggleNexusPlayerMenu("sense")
			if("world") owner.toggleNexusPlayerMenu("world")
			if("chat") owner.toggleNexusChatHud()
			if("hotkeys") owner.toggleNexusHotkeyEditor()
			if("menu") owner.Settings()
			if("admin") owner.toggleNexusAdminPanel(FALSE)
		owner.refreshActionHud()

	Inventory
		action_id = "inventory"
		accent_color = "#d6aa5d"
		desc = "Inventory"

		isActive(mob/character)
			return character.client && character.client.nexus_player_menu && character.client.nexus_player_menu.section == "inventory"

	Skills
		action_id = "skills"
		accent_color = "#ef876d"
		desc = "Skills and techniques"

		isActive(mob/character)
			return character.client && character.client.nexus_player_menu && character.client.nexus_player_menu.section == "skills"

	Progression
		action_id = "progression"
		accent_color = "#65c7e8"
		desc = "Progression Trees"

		isActive(mob/character)
			return character.client && character.client.nexus_progression_tree && character.client.nexus_progression_tree.category != "Milestones"

	Milestones
		action_id = "milestones"
		accent_color = "#f0c34e"
		desc = "Milestones"

		isActive(mob/character)
			return character.client && character.client.nexus_progression_tree && character.client.nexus_progression_tree.category == "Milestones"

	Build
		action_id = "build"
		accent_color = "#d49a5b"
		desc = "Build and Science catalog"

		isActive(mob/character)
			return character.client && character.client.nexus_build_window

	Sense
		action_id = "sense"
		accent_color = "#72d9f5"
		desc = "Sense"

		isActive(mob/character)
			return character.client && character.client.nexus_player_menu && character.client.nexus_player_menu.section == "sense"

	World
		action_id = "world"
		accent_color = "#78cc72"
		desc = "World information"

		isActive(mob/character)
			return character.client && character.client.nexus_player_menu && character.client.nexus_player_menu.section == "world"

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

		isActive(mob/character)
			return character.nexus_hotkey_editor_open

	Menu
		action_id = "menu"
		accent_color = "#e0bd74"
		desc = "Open the Escape menu"

	Admin
		action_id = "admin"
		accent_color = "#ff6d61"
		desc = "Admin control panel"

		isActive(mob/character)
			return character.client && character.client.nexus_admin_panel

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
	var/tmp/live_refresh_loop
	var/tmp/last_browser_heartbeat
	var/tmp/last_scroll_y
	var/tmp/last_scroll_activity = -1000
	var/tmp/last_render_signature
	var/tmp/auto_refresh_paused

	New(mob/new_owner, starting_section = "inventory")
		. = ..()
		owner = new_owner
		section = normalizeSection(starting_section)
		last_browser_heartbeat = world.time

	Del()
		if(owner)
			owner << browse(null, "window=NexusPlayerMenu")
			if(owner.client && owner.client.nexus_player_menu == src) owner.client.nexus_player_menu = null
		. = ..()

	proc/canUse()
		return owner && owner.client && owner.playerCharacter && usr == owner

	proc/isOwnedSkill(obj/skill)
		return skill && skill.loc == owner && isNexusTechniqueObject(skill)

	proc/canInspectSenseTarget(mob/target)
		if(!target || target == owner || !target.loc || target.unsenseable) return FALSE
		if(owner.get_area() != target.get_area()) return FALSE
		return CanSense(owner, target)

	proc/useOwnedSkill(obj/skill)
		if(!isOwnedSkill(skill)) return FALSE
		return owner.executeNexusHotkeyAction(skill)

	proc/getNumericObjectVar(datum/subject, variable_name)
		if(!subject || !variable_name) return null
		var/dynamic_name = "[variable_name]"
		if(!(dynamic_name in subject.vars)) return null
		var/value = subject.vars[dynamic_name]
		if(!isnum(value)) return null
		return value

	proc/formatSkillMultiplier(multiplier)
		if(!nexusIsFiniteNumber(multiplier)) return "Unknown"
		if(multiplier == 1) return "No change (1x)"
		var/percent_change = round((multiplier - 1) * 100, 0.1)
		var/prefix = percent_change > 0 ? "+" : ""
		return "[prefix][percent_change]% ([round(multiplier, 0.01)]x)"

	proc/formatSkillDescriptionHtml(description_text)
		var/formatted = html_encode(description_text ? "[description_text]" : "No description available.")
		formatted = replacetext(formatted, "&lt;br&gt;", "<br>")
		formatted = replacetext(formatted, "&lt;br/&gt;", "<br>")
		formatted = replacetext(formatted, "&lt;br /&gt;", "<br>")
		return formatted

	proc/getSkillEffectData(obj/skill)
		var/list/data = list("heading" = null, "summary" = null, "state" = null, "stat_changes" = null, "attributes" = null, "upkeep" = null)
		if(!skill) return data
		if(istype(skill, /obj/Buff))
			var/obj/Buff/buff = skill
			var/list/multipliers = list(
				"Battle Power" = buff.buff_bp,
				"Energy capacity" = buff.buff_ki,
				"Strength" = buff.buff_str,
				"Endurance" = buff.buff_dur,
				"Speed" = buff.buff_spd,
				"Force" = buff.buff_for,
				"Resistance" = buff.buff_res,
				"Offense" = buff.buff_off,
				"Defense" = buff.buff_def,
				"Regeneration" = buff.buff_reg,
				"Recovery" = buff.buff_rec)
			var/list/changes = list()
			for(var/stat_name in multipliers)
				var/multiplier = multipliers[stat_name]
				if(nexusIsFiniteNumber(multiplier) && multiplier != 1) changes += "[stat_name] [formatSkillMultiplier(multiplier)]"
			var/is_transformation = islist(buff.buff_attributes) && ("transformation" in buff.buff_attributes)
			data["heading"] = is_transformation ? "TRANSFORMATION EFFECT" : "BUFF EFFECT"
			data["summary"] = is_transformation ? "Adds static Battle Power based on the server average, clamped from 25% to 400% of natural Battle Power. It drains Energy, counts as a primary transformation, and replaces another active primary form." : "Toggles the listed multipliers on this character."
			data["state"] = buff.suffix ? "ACTIVE" : "INACTIVE"
			data["stat_changes"] = changes.len ? jointext(changes, "; ") : "No direct stat multipliers"
			if(islist(buff.buff_attributes) && buff.buff_attributes.len) data["attributes"] = jointext(buff.buff_attributes, ", ")
			var/list/upkeep_parts = list()
			if(buff.buff_bp > 1) upkeep_parts += "Battle Power multiplier continuously drains Energy"
			if(is_transformation) upkeep_parts += "Transformation Battle Power has separate Energy upkeep"
			if(upkeep_parts.len) data["upkeep"] = jointext(upkeep_parts, "; ")
			return data
		if(skill.hotbar_type == "Buff")
			data["heading"] = "BUFF EFFECT"
			data["summary"] = skill.desc ? "[skill.desc]" : "This skill applies a temporary or toggleable combat effect."
			data["state"] = "Use to toggle or activate; current availability is checked when used"
			return data
		if(skill.hotbar_type != "Transformation") return data
		data["heading"] = "TRANSFORMATION EFFECT"
		data["summary"] = skill.desc ? "[skill.desc]" : "This skill changes the character into another form."
		data["state"] = owner.detectPrimaryTransformation() ? "Active primary form: [owner.detectPrimaryTransformation()]" : "No primary transformation active"
		if(istype(skill, /obj/Giant_Form))
			if(owner.Race == "Makyo") data["summary"] = "Enlarges a Makyo and adds 30 percentage points to the Battle Power multiplier."
			else data["summary"] = "Doubles visual size, adds 20 percentage points to the Battle Power multiplier, raises Strength, Endurance, and Resistance by 25%, and lowers Speed, Offense, and Defense by 25%."
			data["state"] = owner.using_giant_form ? "ACTIVE" : "INACTIVE"
		else if(istype(skill, /obj/Ultra_Super_Saiyan))
			var/obj/Ultra_Super_Saiyan/ultra_skill = skill
			data["summary"] = "When enabled, powering beyond Super Saiyan with [Commas(ussj_bp_req)] available BP can enter Ultra Super Saiyan: [round(1 + ussj_bp, 0.01)]x BP, [ussj_ki]x Energy, [ussj_str]x Strength, [ussj_dur]x Endurance, [ussj_spd]x Speed, and [ussj_res]x Resistance."
			data["state"] = "Trigger [ultra_skill.using_ussj ? "ENABLED" : "DISABLED"] / Form [owner.is_ussj ? "ACTIVE" : "INACTIVE"]"
		else if(istype(skill, /obj/HeranTransformation))
			data["summary"] = "Adds the same Battle Power as the standard Super Saiyan form without exceeding that equivalent. Current potential gain: [Commas(round(owner.getHeranTransformationEquivalentBPAdd()))] BP. Mastery removes its Energy upkeep."
			data["state"] = owner.heran_transformed ? "ACTIVE" : "INACTIVE"
		else if(istype(skill, /obj/Great_Ape))
			var/obj/Great_Ape/ape_skill = skill
			data["summary"] = "Toggles the full-moon trigger; it does not transform immediately. Great Ape adds 2.5 points to the Battle Power multiplier, raises Strength, Endurance, and Resistance to 1.3x, and lowers Speed and Defense to 0.1x."
			data["state"] = "[owner.IsGreatApe() ? "FORM ACTIVE" : "FORM INACTIVE"] / [ape_skill.Setting ? "MOON TRIGGER ENABLED" : "MOON TRIGGER DISABLED"] / [owner.Great_Ape_control ? "CONTROLLED" : "UNCONTROLLED"]"
			data["stat_changes"] = "Battle Power multiplier +2.5 points; Strength +30% (1.3x); Endurance +30% (1.3x); Resistance +30% (1.3x); Speed -90% (0.1x); Defense -90% (0.1x)"
			data["attributes"] = "Requires a full moon and enabled trigger, a tail, no cybernetic BP or modules, no active Super Saiyan form, and a living non-God character; 3-minute cooldown after reverting"
			data["upkeep"] = owner.Great_Ape_control ? "Controlled form avoids berserk behavior and can last up to 150 minutes" : "Uncontrolled form stops training, automatically seeks or attacks nearby characters, and reverts after 45 seconds"
		return data

	proc/getProjectilePreviewReservedFactor(list/damage_data, direct_multiplier = 1)
		if(!owner || !islist(damage_data)) return 0
		var/direct_factor = damage_data["projectile_direct_factor"]
		if(!nexusIsFiniteNumber(direct_factor))
			var/fallback_factor = damage_data["factor"]
			return nexusIsFiniteNumber(fallback_factor) ? max(0, fallback_factor * direct_multiplier) : 0
		var/explosion_factor = damage_data["projectile_explosion_factor"]
		if(!nexusIsFiniteNumber(explosion_factor)) explosion_factor = 0
		var/budget_factor = damage_data["projectile_budget_factor"]
		if(!nexusIsFiniteNumber(budget_factor)) budget_factor = 0
		var/direct_request = max(0, direct_factor * direct_multiplier)
		explosion_factor = max(0, explosion_factor)
		if(budget_factor <= 0) return direct_request + explosion_factor
		var/datum/CombatDamageBudget/preview_budget = new(budget_factor)
		var/reserved_factor = preview_budget.reserveFactor(owner, direct_request)
		reserved_factor += preview_budget.reserveFactor(owner, explosion_factor)
		del(preview_budget)
		return reserved_factor

	proc/getUnresistedSkillDamage(obj/skill, list/damage_data)
		if(!owner || !skill || !islist(damage_data)) return null
		var/factor = damage_data["factor"]
		if(!nexusIsFiniteNumber(factor) || factor <= 0) return null
		var/preview_profile = damage_data["preview_profile"]
		if(preview_profile == "nexus_melee") return owner.getUnresistedMeleeDamage() * factor
		if(preview_profile == "weapon_projectile" || preview_profile == "ki_projectile")
			var/direct_multiplier = ki_power * owner.getForgedKiDamageMultiplier()
			var/projectile_factor = getProjectilePreviewReservedFactor(damage_data, direct_multiplier)
			if(preview_profile == "weapon_projectile") return owner.getUnresistedWeaponCombatDamage(projectile_factor)
			return owner.getUnresistedKiProjectileCombatDamage(projectile_factor)
		if(preview_profile == "raw_ki")
			return calculateScaledCombatDamage(factor, owner.BP, max(owner.BP, 0.01), owner.Pow, 0)
		var/model = damage_data["model"]
		if(model == "Physical") return owner.getUnresistedPhysicalCombatDamage(factor)
		if(model == "Ki") return owner.getUnresistedKiCombatDamage(factor)
		if(model == "Hybrid") return owner.getUnresistedHybridCombatDamage(factor)
		return null

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
		if(isnum(numeric_scroll_y))
			numeric_scroll_y = round(Clamp(numeric_scroll_y, 0, 100000))
			if(numeric_scroll_y != last_scroll_y) last_scroll_activity = world.time
			last_scroll_y = numeric_scroll_y

	proc/startLiveRefresh()
		set waitfor = FALSE
		if(live_refresh_loop) return
		live_refresh_loop = TRUE
		while(src && hasLiveOwner())
			sleep(nexus_live_browser_refresh_ticks)
			if(!src || !hasLiveOwner() || !isBrowserOpen()) break
			if(!auto_refresh_paused && last_scroll_y <= 0 && world.time - last_scroll_activity >= nexus_live_browser_scroll_idle_ticks) show(FALSE)
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
		return getNexusBrowserAtomIconResource(owner, subject)

	proc/buildIcon(atom/subject, alt_text)
		var/resource_name = getBrowserIcon(subject)
		if(!resource_name) return "<div class='item-icon hud-sprite missing' aria-label='[html_encode(alt_text)]'>--</div>"
		return "<div class='item-icon hud-sprite'><img src='[resource_name]' alt='[html_encode(alt_text)]'></div>"

	proc/getSectionSubtitle(menu_section)
		switch(menu_section)
			if("inventory") return "Carried gear and currencies"
			if("skills") return "Techniques ready for action"
			if("sense") return "Energy signatures in the current area"
			if("world") return "World and connected character overview"
		return "Character menu"

	proc/buildNavigation()
		var/navigation = ""
		for(var/menu_section in getSections())
			var/active_class = menu_section == section ? "tab hud-tab active" : "tab hud-tab"
			navigation += "<a class='[active_class]' href='byond://?src=\ref[src]&action=section&id=[menu_section]'>[uppertext(menu_section)]</a>"
		return navigation

	proc/getSkillDamageData(obj/skill)
		var/list/data = list("factor" = 0, "model" = "Dynamic / utility", "preview_profile" = "direct", "range" = "See mechanics", "mechanics" = "Behavior is described by the technique.", "requirements" = "Owned and available on the skill bar.")
		if(istype(skill, /obj/Attacks/NexusMeleeTechnique))
			var/obj/Attacks/NexusMeleeTechnique/technique = skill
			data["factor"] = technique.damage_multiplier * (1 + technique.extra_hits * technique.extra_hit_multiplier)
			data["model"] = "Physical"
			data["preview_profile"] = "nexus_melee"
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
		if(istype(skill, /obj/Attacks/NexusSpecialStyle/WallOfFlame))
			var/obj/Attacks/NexusSpecialStyle/WallOfFlame/flame_wall = skill
			data["factor"] = 0.45 * 6
			data["model"] = "Ki"
			data["range"] = "Five-tile wall in front of the user"
			data["mechanics"] = "Persists for [round(flame_wall.field_duration / 10, 0.1)] seconds. A target can take up to six 0.45-factor pulses; each pulse briefly stuns and adds a Burn stack."
			data["cost"] = "[flame_wall.energy_cost] energy-drain units"
			data["cooldown"] = "[round(flame_wall.cooldown_ticks / 10, 0.1)] seconds"
			return data
		if(istype(skill, /obj/Attacks/NexusSpecialStyle/ChargedProjectile))
			var/obj/Attacks/NexusSpecialStyle/ChargedProjectile/projectile_skill = skill
			data["factor"] = projectile_skill.projectile_damage_factor * (projectile_skill.explosion_size ? 2 : 1)
			data["model"] = projectile_skill.strength_scaled ? "Physical" : "Ki"
			data["preview_profile"] = projectile_skill.weapon_projectile ? "weapon_projectile" : "ki_projectile"
			data["projectile_direct_factor"] = projectile_skill.projectile_damage_factor
			data["projectile_explosion_factor"] = projectile_skill.explosion_size ? projectile_skill.projectile_damage_factor : 0
			data["projectile_budget_factor"] = data["factor"]
			data["range"] = projectile_skill.explosion_size ? "40 tiles / [projectile_skill.explosion_size]-tile explosion" : "40 tiles / direct impact"
			data["mechanics"] = projectile_skill.explosion_size ? "Charges for [round(projectile_skill.charge_ticks / 10, 0.1)] seconds, then deals direct and splash damage within a shared maximum budget." : "Charges for [round(projectile_skill.charge_ticks / 10, 0.1)] seconds, then launches a cutting projectile with [projectile_skill.projectile_shockwave]-tile knockback."
			data["requirements"] = projectile_skill.requires_weapon ? (owner.using_sword() ? "Weapon equipped: READY" : "Weapon equipped: MISSING") : "No weapon requirement"
			data["cost"] = "[projectile_skill.energy_cost] energy-drain units"
			data["cooldown"] = "[round(projectile_skill.cooldown_ticks / 10, 0.1)] seconds"
			return data
		if(istype(skill, /obj/Attacks/NexusSpecialStyle/SuperGhostKamikaze))
			var/obj/Attacks/NexusSpecialStyle/SuperGhostKamikaze/ghost_skill = skill
			var/ghost_total_factor = max(0, ghost_skill.ghost_count * ghost_skill.ghost_damage_factor)
			data["factor"] = ghost_total_factor
			data["model"] = "Ki"
			data["preview_profile"] = "ki_projectile"
			data["projectile_direct_factor"] = ghost_total_factor
			data["projectile_explosion_factor"] = 0
			data["projectile_budget_factor"] = ghost_total_factor
			data["range"] = "Selected target within 20 tiles"
			data["mechanics"] = "Maximum if all [ghost_skill.ghost_count] homing ghosts hit one target; their [ghost_skill.ghost_damage_factor]x direct hits share one damage budget."
			data["requirements"] = "A valid selected target within 20 tiles"
			data["cost"] = "[ghost_skill.energy_cost] energy-drain units"
			data["cooldown"] = "[round(ghost_skill.cooldown_ticks / 10, 0.1)] seconds"
			return data
		if(skill.hotbar_type == "Beam" && istype(skill, /obj/Attacks))
			var/obj/Attacks/beam_skill = skill
			data["factor"] = beam_skill.damage_factor
			data["model"] = "Ki"
			data["preview_profile"] = "ki_projectile"
			data["projectile_direct_factor"] = beam_skill.damage_factor
			data["projectile_explosion_factor"] = 0
			data["projectile_budget_factor"] = owner.beam_impact_mode == BEAM_IMPACT_EXPLOSIVE ? beam_skill.damage_factor : 0
			data["range"] = "[beam_skill.Range] tiles"
			data["mechanics"] = "Sustained beam; can enter a beam clash. Its impact mode and distance modifiers can change the final result."
			data["requirements"] = "Enough energy; cannot fire while grabbed, disabled or in RP Mode"
			data["cost"] = "Drain [beam_skill.Drain]"
			data["cooldown"] = "[round(beam_skill_cooldown_ticks / 10, 0.1)] seconds"
			return data
		if(istype(skill, /obj/Attacks/Big_Bang_Attack))
			data["factor"] = skill_big_bang_damage_factor * 2
			data["model"] = "Ki"
			data["preview_profile"] = "ki_projectile"
			data["projectile_direct_factor"] = skill_big_bang_damage_factor
			data["projectile_explosion_factor"] = skill_big_bang_damage_factor
			data["projectile_budget_factor"] = data["factor"]
			data["range"] = "Projectile / 4-tile explosion"
			data["mechanics"] = "Charged direct hit plus explosion, capped by one shared damage budget."
		else if(istype(skill, /obj/Attacks/Charge))
			data["factor"] = skill_charge_damage_factor * 2
			data["model"] = "Ki"
			data["preview_profile"] = "ki_projectile"
			data["projectile_direct_factor"] = skill_charge_damage_factor
			data["projectile_explosion_factor"] = skill_charge_damage_factor
			data["projectile_budget_factor"] = data["factor"]
			data["range"] = "Projectile / 2-tile explosion"
			data["mechanics"] = "Charged direct hit plus explosion."
		else if(istype(skill, /obj/Attacks/Cyber_Charge))
			data["factor"] = skill_cyber_charge_damage_factor * 2
			data["model"] = "Ki"
			data["preview_profile"] = "ki_projectile"
			data["projectile_direct_factor"] = skill_cyber_charge_damage_factor
			data["projectile_explosion_factor"] = skill_cyber_charge_damage_factor
			data["projectile_budget_factor"] = data["factor"]
			data["range"] = "Projectile / 1-tile explosion"
		else if(istype(skill, /obj/Attacks/Makosen))
			data["factor"] = skill_makosen_total_factor
			data["model"] = "Ki"
			data["preview_profile"] = "ki_projectile"
			data["projectile_direct_factor"] = skill_makosen_total_factor
			data["projectile_explosion_factor"] = 0
			data["projectile_budget_factor"] = skill_makosen_total_factor
			data["range"] = "Short-range barrage"
			data["mechanics"] = "Many small shots share one per-target damage budget."
		else if(istype(skill, /obj/Attacks/Scatter_Shot))
			data["factor"] = skill_scatter_shot_total_factor
			data["model"] = "Ki"
			data["preview_profile"] = "ki_projectile"
			data["projectile_direct_factor"] = skill_scatter_shot_total_factor
			data["projectile_explosion_factor"] = skill_scatter_shot_total_factor
			data["projectile_budget_factor"] = skill_scatter_shot_total_factor
			data["range"] = "Selected target / homing barrage"
			data["mechanics"] = "Surrounds the selected target with homing shots that share one damage budget."
		else if(istype(skill, /obj/Attacks/Sokidan))
			data["factor"] = skill_sokidan_total_factor
			data["model"] = "Ki"
			data["preview_profile"] = "ki_projectile"
			data["projectile_direct_factor"] = skill_sokidan_damage_factor
			data["projectile_explosion_factor"] = skill_sokidan_damage_factor
			data["projectile_budget_factor"] = skill_sokidan_total_factor
			data["range"] = "Guided projectile"
			data["mechanics"] = "Player-guided homing projectile with impact and splash damage."
		else if(istype(skill, /obj/Attacks/Kienzan))
			data["factor"] = skill_kienzan_damage_factor
			data["model"] = "Ki"
			data["preview_profile"] = "ki_projectile"
			data["projectile_direct_factor"] = skill_kienzan_damage_factor
			data["projectile_explosion_factor"] = 0
			data["projectile_budget_factor"] = 0
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
		else if(istype(skill, /obj/Attacks/NexusAreaTechnique))
			var/obj/Attacks/NexusAreaTechnique/area_skill = skill
			data["factor"] = area_skill.area_damage_factor
			data["model"] = area_skill.physical_damage ? "Physical" : "Ki"
			data["range"] = "Up to [area_skill.radius] tiles around the user"
			data["mechanics"] = "Preview is the maximum center-range hit; damage falls with distance. Can affect up to [area_skill.target_limit] targets."
			data["cost"] = "[area_skill.energy_cost] [area_skill.physical_damage ? "stamina" : "energy"]-drain units"
			data["cooldown"] = "[round(area_skill.cooldown_ticks / 10, 0.1)] seconds"
		else if(istype(skill, /obj/Attacks/Attack_Barrier))
			data["factor"] = skill_attack_barrier_damage_factor
			data["model"] = "Ki"
			data["preview_profile"] = "ki_projectile"
			data["projectile_direct_factor"] = skill_attack_barrier_damage_factor
			data["projectile_explosion_factor"] = 0
			data["projectile_budget_factor"] = 0
			data["range"] = "Orbiting projectile / contact"
			data["mechanics"] = "Preview is for one orbiting blast; the barrier can launch multiple independently damaging blasts."
		else if(istype(skill, /obj/Attacks/Shockwave))
			data["factor"] = skill_shockwave_damage_factor
			data["model"] = "Hybrid"
			data["range"] = "7-tile area around the user"
			data["mechanics"] = "Hybrid Strength/Force shockwave damage plus distance-scaled knockback."
		else if(istype(skill, /obj/Attacks/Explosion))
			data["factor"] = skill_explosion_damage_factor
			data["model"] = "Ki"
			data["range"] = "Clicked ground within 20 tiles / learned blast radius"
			data["mechanics"] = "Toggles an aimed ground explosion; preview is the damage to one target in its area."
		else if(istype(skill, /obj/Attacks/Kikoho))
			data["factor"] = 7
			data["model"] = "Ki"
			data["range"] = "Target in front"
			data["mechanics"] = "High-impact Ki strike that also accumulates self-damage."
		else if(istype(skill, /obj/Attacks/Genki_Dama))
			var/obj/Attacks/Genki_Dama/spirit_bomb = skill
			data["factor"] = spirit_bomb.sb_max_dmg * (spirit_bomb.sb_explosion_size ? 2 : 1)
			data["model"] = "Ki"
			data["preview_profile"] = "ki_projectile"
			data["projectile_direct_factor"] = spirit_bomb.sb_max_dmg
			data["projectile_explosion_factor"] = spirit_bomb.sb_explosion_size ? spirit_bomb.sb_max_dmg : 0
			data["projectile_budget_factor"] = data["factor"]
			data["range"] = "Guided charged projectile / [spirit_bomb.sb_explosion_size]-tile explosion"
			data["mechanics"] = "Preview is the full-charge direct-plus-explosion maximum; releasing early deals less damage."
			data["cost"] = "[spirit_bomb.Genki_Dama_drain] Energy to begin charging"
			data["cooldown"] = "[spirit_bomb.self_cooldown] seconds"
		else if(istype(skill, /obj/Final_Explosion))
			data["factor"] = 25
			data["model"] = "Ki"
			data["preview_profile"] = "raw_ki"
			data["range"] = "Expanding self-centered area"
			data["mechanics"] = "Preview is the maximum nine-second charge. The blast strikes in five stacks, damages the user, and expands with charge time."
		else if(istype(skill, /obj/Attacks/Blast))
			var/obj/Attacks/Blast/basic_blast = skill
			var/projectile_count = Clamp(round(basic_blast.Blast_Count), 1, basic_blast_max_volley_size)
			var/per_projectile_factor = max(0, basic_blast.getBasicBlastDamageFactor())
			var/direct_factor = per_projectile_factor * projectile_count
			var/explosion_factor = basic_blast.Explosive ? per_projectile_factor : 0
			data["factor"] = min(skill_blast_total_factor, direct_factor + explosion_factor)
			data["model"] = "Ki"
			data["preview_profile"] = "ki_projectile"
			data["projectile_direct_factor"] = direct_factor
			data["projectile_explosion_factor"] = explosion_factor
			data["projectile_budget_factor"] = skill_blast_total_factor
			data["range"] = "[projectile_count]-projectile rapid volley"
			data["mechanics"] = "Current [projectile_count]-shot volley at [round(per_projectile_factor, 0.001)]x per direct hit[explosion_factor ? ", plus one same-factor center-projectile splash" : ""]; all hits share a [skill_blast_total_factor]x per-target budget."
		if(!data["factor"])
			var/generic_factor = getNumericObjectVar(skill, "damage_factor")
			if(!nexusIsFiniteNumber(generic_factor) || generic_factor <= 0) generic_factor = getNumericObjectVar(skill, "area_damage_factor")
			if(!nexusIsFiniteNumber(generic_factor) || generic_factor <= 0) generic_factor = getNumericObjectVar(skill, "projectile_damage_factor")
			if(nexusIsFiniteNumber(generic_factor) && generic_factor > 0)
				data["factor"] = generic_factor
				var/physical_flag = getNumericObjectVar(skill, "physical_damage")
				data["model"] = skill.hotbar_type == "Melee" || physical_flag ? "Physical" : "Ki"
				data["mechanics"] = "Runtime damage factor exposed by this skill; conditional hits or splash may change its total."
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
		prepareNexusHudBrowserResources(owner)
		var/html = {"<!doctype html><html><head><meta charset='utf-8'><title>[html_encode(title)]</title><style>
		*{box-sizing:border-box}html,body{margin:0;min-height:100%;font:12px 'Courier New',monospace}.shell{padding:12px}.header{display:flex;gap:12px;align-items:center;border:2px solid #755a36;background:#21190f;padding:10px}.header h1{margin:0;color:#f0d79e;font-size:18px}.header p{margin:4px 0 0;color:#b9a37c}.header-copy{flex:1}.back{padding:7px 10px}.body{margin-top:8px;border:2px solid #684e2f;background:#21190f;padding:10px}.description{padding:10px;border:1px solid #624b30;background:#2a2117;color:#d9c49a;line-height:1.5}.details{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:6px;margin-top:8px}.details div{min-height:68px;padding:8px;border:2px solid #624b30;background:#2a2117}.details small,.details b{display:block}.details small{color:#c69c57}.details b{margin-top:7px;color:#ead7ad;line-height:1.35}.notice{margin-top:8px;padding:8px;border-left:3px solid #d6aa5d;color:#b9a37c}.item-icon{width:56px;height:56px;flex:0 0 56px;border:2px solid #59452d;background:#15110c;display:flex;align-items:center;justify-content:center;image-rendering:pixelated;overflow:hidden}.item-icon img{max-width:52px;max-height:52px;image-rendering:pixelated}.item-icon.missing{color:#826d4d;font-size:18px}
		[getNexusHudBrowserCss("bronze")]</style>[getNexusLiveBrowserScript(src, last_scroll_y)]</head><body class='nexus-hud'><div class='shell hud-shell'><div class='header hud-frame'>[icon_html]<div class='header-copy'><h1 class='hud-title'>[html_encode(title)]</h1><p class='hud-muted'>[html_encode(subtitle)]</p></div><a class='back hud-button' href='byond://?src=\ref[src]&action=back'>BACK</a></div><div class='body hud-frame'>[body_html]</div></div></body></html>"}
		owner << browse(html, "window=NexusPlayerMenu;size=980x680;can_resize=true;can_close=true")

	proc/showItemExamine(obj/items/item)
		var/description_text = item.desc ? "[item.desc]" : "No description available."
		var/details = buildDetailRow("STATUS", item.suffix ? item.suffix : "Carried")
		details += buildDetailRow("TYPE", item.type)
		var/item_level = getNumericObjectVar(item, "Level")
		var/item_durability = getNumericObjectVar(item, "Durability")
		var/item_cost = getNumericObjectVar(item, "Cost")
		if(isnum(item_level)) details += buildDetailRow("LEVEL", round(item_level, 0.1))
		if(isnum(item_durability)) details += buildDetailRow("DURABILITY", round(item_durability, 0.1))
		if(isnum(item_cost)) details += buildDetailRow("BASE VALUE", Commas(item_cost))
		showExamineWindow("[item]", "INVENTORY ITEM", buildIcon(item, "[item]"), "<div class='description'>[html_encode(description_text)]</div><div class='details'>[details]</div><div class='notice'>Left-click the item in Inventory to open its interaction menu.</div>")

	proc/showSkillExamine(obj/skill)
		var/list/data = getSkillDamageData(skill)
		var/factor = data["factor"]
		var/raw_damage = getUnresistedSkillDamage(skill, data)
		var/preview_value = nexusIsFiniteNumber(raw_damage) ? "About [round(raw_damage, 0.01)] Health ([factor]x skill factor)" : "No fixed raw-damage formula"
		var/details = buildDetailRow("UNRESISTED EQUAL-POWER DAMAGE", preview_value)
		details += buildDetailRow("DAMAGE MODEL", data["model"])
		details += buildDetailRow("RANGE", data["range"])
		details += buildDetailRow("COST", data["cost"] ? data["cost"] : "Dynamic / see description")
		details += buildDetailRow("COOLDOWN", data["cooldown"] ? data["cooldown"] : "No dedicated fixed cooldown documented")
		details += buildDetailRow("REQUIREMENTS", data["requirements"])
		var/list/effect_data = getSkillEffectData(skill)
		if(effect_data["state"]) details += buildDetailRow("CURRENT STATE", effect_data["state"])
		if(effect_data["stat_changes"]) details += buildDetailRow("STAT CHANGES", effect_data["stat_changes"])
		if(effect_data["attributes"]) details += buildDetailRow("SPECIAL ATTRIBUTES", effect_data["attributes"])
		if(effect_data["upkeep"]) details += buildDetailRow("UPKEEP", effect_data["upkeep"])
		var/description_text = skill.desc ? "[skill.desc]" : "No description available."
		var/effect_html = ""
		if(effect_data["summary"]) effect_html = "<div class='notice'><b>[html_encode(effect_data["heading"])]</b><br>[formatSkillDescriptionHtml(effect_data["summary"])]</div>"
		var/damage_notice = nexusIsFiniteNumber(raw_damage) ? "The damage preview uses only your current offensive stats and gear against an equal-BP baseline with zero Endurance and Resistance. It never reads your selected target. Actual damage changes with enemy BP, defenses, armor, blocking, shields, critical hits, positioning, and conditional hits." : "This utility, buff, or transformation has no single fixed damage value. Its concrete effects are listed above and below."
		var/use_link = hascall(skill, "Hotbar_use") && owner.isNexusHotkeyObjectAvailable(skill) ? "<a class='hud-button' href='byond://?src=\ref[src]&action=use_skill&subject=\ref[skill]'>USE SKILL</a>" : ""
		var/body = "<div class='description'>[formatSkillDescriptionHtml(description_text)]</div><div class='details'>[details]</div>[effect_html]<div class='notice'><b>MECHANICS</b><br>[html_encode(data["mechanics"])]<br><br>[html_encode(damage_notice)]</div><div class='notice'>[use_link]</div>"
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
			html += "<div class='card hud-card resource with-icon'>[buildIcon(resources, "Resources")]<div class='card-copy'><span class='hud-label'>RESOURCE</span><b>[Commas(resources.Value)] resources</b><small>Crafting and technology currency carried by this character.</small></div></div>"
		html += "<div class='card hud-card resource'><div class='card-copy'><span class='hud-label'>ARCANE CURRENCY</span><b>[Value(round(owner.arcane_essence, 0.1))] Arcane Essence</b><small>Magical currency available for rituals, crafting, and secure player trades.</small></div></div>"
		var/item_count = 0
		for(var/obj/items/item in owner.item_list)
			item_count++
			var/status_text = item.suffix ? "[item.suffix]" : "Carried"
			var/description_text = item.desc ? "[item.desc]" : "No description available."
			var/use_url = "byond://?src=\ref[src]&action=use_item&item=\ref[item]"
			var/examine_url = "byond://?src=\ref[src]&action=examine_item&item=\ref[item]"
			html += "<div class='card hud-card with-icon with-actions' onmousedown=\"return nexusRightClick(window.event,'[examine_url]')\" oncontextmenu=\"window.location.href='[examine_url]';return false;\">[buildIcon(item, "[item]")]<div class='card-copy'><span class='hud-label'>[html_encode(status_text)]</span><b>[html_encode("[item]")]</b><small>[html_encode(description_text)]</small></div><div class='card-actions'><a class='hud-button' href='[use_url]'>USE</a><a class='hud-button' href='[examine_url]'>EXAMINE</a></div></div>"
		if(!item_count) html += "<div class='empty'>This character is not carrying any items.</div>"
		return html

	proc/buildSkills()
		var/html = ""
		var/skill_count = 0
		for(var/obj/skill in owner.contents)
			if(!isNexusTechniqueObject(skill)) continue
			skill_count++
			var/mastery_text = nexusIsFiniteNumber(skill.Mastery) ? "Mastery [round(skill.Mastery, 0.1)]%" : "Learned"
			var/skill_examine_url = "byond://?src=\ref[src]&action=examine_skill&subject=\ref[skill]"
			var/use_link = hascall(skill, "Hotbar_use") && owner.isNexusHotkeyObjectAvailable(skill) ? "<a class='hud-button' href='byond://?src=\ref[src]&action=use_skill&subject=\ref[skill]'>USE</a>" : ""
			html += "<div class='card hud-card with-icon with-actions' onmousedown=\"return nexusRightClick(window.event,'[skill_examine_url]')\" oncontextmenu=\"window.location.href='[skill_examine_url]';return false;\">[buildIcon(skill, "[skill]")]<div class='card-copy'><span class='hud-label'>[html_encode("[skill.hotbar_type]")]</span><b>[html_encode("[skill]")]</b><small>[html_encode(mastery_text)]</small><small>Damage or effect, range, and usage details available.</small></div><div class='card-actions'>[use_link]<a class='hud-button' href='[skill_examine_url]'>EXAMINE</a></div></div>"
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
			var/target_url = "byond://?src=\ref[src]&action=target&subject=\ref[target]"
			var/sense_examine_url = "byond://?src=\ref[src]&action=examine_sense&subject=\ref[target]"
			html += "<div class='card hud-card with-icon sense-card with-actions' onmousedown=\"return nexusRightClick(window.event,'[sense_examine_url]')\" oncontextmenu=\"window.location.href='[sense_examine_url]';return false;\">[buildIcon(target, "[target]")]<div class='card-copy'><span class='hud-label'>[html_encode(location_text)]</span><b>[html_encode("[target]")]</b>[details]</div><div class='card-actions'><a class='hud-button' href='[target_url]'>TARGET</a><a class='hud-button' href='[sense_examine_url]'>EXAMINE</a></div></div>"
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
			var/edit_link = owner.AdminLevel() >= 3 ? "<a class='hud-button' href='byond://?src=\ref[src]&action=edit_world&target=\ref[player]'>EDIT</a>" : ""
			player_cards += "<div class='card hud-card compact with-icon with-actions' onmousedown=\"return nexusRightClick(window.event,'[world_examine_url]')\" oncontextmenu=\"window.location.href='[world_examine_url]';return false;\">[buildIcon(player, "[player]")]<div class='card-copy'><span class='hud-label'>ONLINE / [player.client.inactivity] inactivity</span><b>[html_encode("[player]")]</b><small>[html_encode("[player.Race] / [player.Class]")]</small><small>[player.x], [player.y], [player.z] / BP [Commas(player.BP)]</small></div><div class='card-actions'><a class='hud-button' href='[world_examine_url]'>EXAMINE</a>[edit_link]</div></div>"
		return "<div class='world-grid'><div class='hud-panel'><small class='hud-label'>YEAR</small><b>[round(Year, 0.1)]</b></div><div class='hud-panel'><small class='hud-label'>PLAYERS</small><b>[player_count]</b></div><div class='hud-panel'><small class='hud-label'>AREA</small><b>[html_encode(area_text)]</b></div><div class='hud-panel'><small class='hud-label'>COORDINATES</small><b>[location_text]</b></div><div class='hud-panel'><small class='hud-label'>OOC</small><b>[OOC ? "ENABLED" : "DISABLED"]</b></div><div class='hud-panel'><small class='hud-label'>TOURNAMENT</small><b>[Tournament ? "ACTIVE" : "INACTIVE"]</b></div></div><h2 class='hud-section-title'>CONNECTED CHARACTERS</h2><div class='cards'>[player_cards]</div>"

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
		var/section_subtitle = getSectionSubtitle(section)
		return {"<!doctype html><html><head><meta charset='utf-8'><title>Nexus Menu</title><style>
		*{box-sizing:border-box}html,body{margin:0;min-height:100%;font:12px 'Courier New',monospace}.shell{min-height:100vh;padding:10px}.header{position:sticky;top:0;z-index:2;border:2px solid #755a36;padding:8px;background:#21190f}.top{display:flex;align-items:center;gap:8px}.title{margin-right:auto}.title b{display:block;font-size:17px;letter-spacing:1px}.title small{display:block;margin-top:2px}.close{padding:6px 9px}.tabs{display:flex;gap:4px;margin-top:8px}.tab{flex:1;padding:7px;text-align:center}.content{margin-top:7px;border:2px solid #684e2f;padding:8px}.cards{display:grid;grid-template-columns:repeat(3,minmax(180px,1fr));gap:6px}.card{position:relative;display:block;min-height:92px;padding:9px;border:2px solid #624b30;background:#2a2117;color:#ead7ad;text-decoration:none}.card.with-actions{padding-bottom:42px}.card:hover{border-color:#bd9655;background:#392a1b}.card span,.card b,.card small{display:block}.card span{color:#c69c57;font-size:9px}.card b{margin:6px 0;font-size:13px}.card small{color:#b9a37c;line-height:1.35}.card.resource{border-color:#85652e}.card.compact{min-height:72px}.card-actions{position:absolute;left:8px;right:8px;bottom:7px;display:flex;justify-content:flex-end;gap:5px}.card-actions a{display:block;padding:4px 8px;border:2px outset #9a7440;background:#49351f;color:#ffe2a5;text-decoration:none;font-size:9px;font-weight:bold}.card-actions a:active{border-style:inset}.world-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:6px;margin-bottom:10px}.world-grid div{min-height:64px;padding:9px;border:2px solid #644b2e;background:#2a2117}.world-grid small,.world-grid b{display:block}.world-grid b{margin-top:7px;color:#f0d79e}.empty{padding:36px;text-align:center;color:#b9a37c}h2{margin:10px 0 7px;padding:7px;border:2px solid #755a36;font-size:13px}@media(max-width:760px){.cards{grid-template-columns:repeat(2,1fr)}.world-grid{grid-template-columns:repeat(2,1fr)}}
		.card.with-icon{display:flex;gap:9px}.card-copy{flex:1;min-width:0}.item-icon{width:48px;height:48px;flex:0 0 48px;border:2px solid #59452d;background:#15110c;display:flex;align-items:center;justify-content:center;image-rendering:pixelated;overflow:hidden}.item-icon img{max-width:44px;max-height:44px;image-rendering:pixelated}.item-icon.missing{color:#826d4d;font-size:18px}.sense-card{min-height:132px}.sense-stats{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:2px;margin-top:5px}.sense-stats i{font-size:8px;color:#d1b47d;font-style:normal}
		[getNexusHudBrowserCss("bronze")]</style><script>function nexusRightClick(e,url){e=e||window.event;if(e&&e.button==2){window.location.href=url;return false;}return true;}</script>[getNexusLiveBrowserScript(src, last_scroll_y)]</head><body class='nexus-hud'><div class='shell hud-shell'><div class='header hud-frame'><div class='top'><div class='title'><b class='hud-title'>NEXUS MENU / [uppertext(section)]</b><small class='hud-muted'>[html_encode(section_subtitle)]</small></div><a class='close hud-button danger' href='byond://?src=\ref[src]&action=close'>CLOSE</a></div><div class='tabs'>[buildNavigation()]</div></div><div class='content hud-frame'>[rendered_content]</div></div></body></html>"}

	proc/show(force_refresh = TRUE)
		if(!owner || !owner.client || !owner.playerCharacter)
			del(src)
			return
		auto_refresh_paused = FALSE
		var/rendered_content = buildContent()
		var/render_signature = md5("[section]|[rendered_content]")
		if(!force_refresh && render_signature == last_render_signature) return
		last_render_signature = render_signature
		prepareNexusHudBrowserResources(owner)
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
				if(item && item in owner.item_list && !item.isNexusTradeOfferedBy(owner)) item.Click()
			if("use_skill")
				var/obj/skill = locate(href_list["subject"] ? href_list["subject"] : href_list["skill"])
				useOwnedSkill(skill)
			if("examine_item")
				var/obj/items/examined_item = locate(href_list["item"])
				if(examined_item && examined_item in owner.item_list) showItemExamine(examined_item)
				return
			if("examine_skill")
				var/obj/examined_skill = locate(href_list["subject"] ? href_list["subject"] : href_list["skill"])
				if(isOwnedSkill(examined_skill)) showSkillExamine(examined_skill)
				return
			if("examine_sense")
				var/mob/examined_target = locate(href_list["subject"] ? href_list["subject"] : href_list["target"])
				if(canInspectSenseTarget(examined_target)) showSenseExamine(examined_target)
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
				var/mob/new_target = locate(href_list["subject"] ? href_list["subject"] : href_list["target"])
				if(canInspectSenseTarget(new_target)) owner.Target = new_target
			if("close")
				del(src)
				return
		show(TRUE)

mob/proc/showNexusPlayerMenu(section = "inventory")
	if(!client || !playerCharacter) return
	if(client.nexus_player_menu) del(client.nexus_player_menu)
	client.nexus_player_menu = new /datum/NexusPlayerMenu(src, section)
	client.nexus_player_menu.show()

mob/proc/toggleNexusPlayerMenu(section = "inventory")
	if(!client || !playerCharacter) return
	var/datum/NexusPlayerMenu/current_menu = client.nexus_player_menu
	if(current_menu && current_menu.section == current_menu.normalizeSection(section))
		del(current_menu)
		return
	showNexusPlayerMenu(section)
