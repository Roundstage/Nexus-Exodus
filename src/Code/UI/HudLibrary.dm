var/list/nexus_hud_library_icon_cache = list()

proc/getNexusHudLibraryIcon(width, height, background_color = "#101923", border_color = "#40556b", accent_color = "")
	width = max(1, round(width))
	height = max(1, round(height))
	var/cache_key = "[width]x[height]-[background_color]-[border_color]-[accent_color]"
	if(nexus_hud_library_icon_cache[cache_key]) return nexus_hud_library_icon_cache[cache_key]
	var/icon/panel_icon = icon('UserNamesBarsUi.png')
	panel_icon.Scale(width, height)
	panel_icon.DrawBox(background_color, 1, 1, width, height)
	panel_icon.DrawBox("#160f0a", 1, 1, width, 2)
	panel_icon.DrawBox("#160f0a", 1, height - 1, width, height)
	panel_icon.DrawBox("#160f0a", 1, 1, 2, height)
	panel_icon.DrawBox("#160f0a", width - 1, 1, width, height)
	if(width >= 6 && height >= 6)
		panel_icon.DrawBox(border_color, 3, 3, width - 2, 3)
		panel_icon.DrawBox(border_color, 3, height - 2, width - 2, height - 2)
		panel_icon.DrawBox(border_color, 3, 3, 3, height - 2)
		panel_icon.DrawBox(border_color, width - 2, 3, width - 2, height - 2)
	if(width >= 12 && height >= 12)
		for(var/bolt_x in list(5, width - 4))
			for(var/bolt_y in list(5, height - 4)) panel_icon.DrawBox("#c6a15c", bolt_x, bolt_y, bolt_x + 1, bolt_y + 1)
	if(accent_color) panel_icon.DrawBox(accent_color, 1, 1, 4, height)
	nexus_hud_library_icon_cache[cache_key] = panel_icon
	return panel_icon

proc/getNexusRpgBrowserCss()
	return {"
	*{border-radius:0!important;box-shadow:none!important}html,body{background:#17130f!important;background-image:none!important;color:#e8d4aa!important;font-family:'Courier New',monospace!important}body:before{display:none!important}.shell,.menu-frame,.header,.toolbar,.footer,.workspace,.content,.entries,.results,.catalog,.topbar{background-color:#211a13!important;background-image:none!important}.panel,.pane,.card,.action,.action-card,.keyboard,.key,.numpad,.reward,.result,.progress-card,.milestone,.milestone-card,.skill-card,.stat-row,.meter,.portrait,.emote-card,.status>div,.mutation,.mutation-panel,.review-panel #reviewSummary,.option-card span,.trait-choice span,.race-entry span,.portrait-choice span,.hair-choice span,.clothing-choice span,.frost-form-card,.preview-shell,.frost-form-preview{background:#2b2117!important;background-image:none!important;border:2px solid #715735!important;outline:1px solid #120d08!important}.header,.menu-title,.panel h2,.pane h2,h1,h2,h3,thead,.stage-strip span.active{background:#3a2a1b!important;background-image:none!important;color:#f0d497!important;border-color:#a27c45!important;text-shadow:1px 1px #0b0805!important}.title b,.menu-title span,h1{letter-spacing:1px!important}.button,button,a.button,a.tab,.top-button,.filters button,.toolbar button,.post,.confirm,.journey-button,.preview-controls button,.wizard-nav button,.close,.back,.play,.create,.delete{background:#49351f!important;background-image:none!important;border:2px outset #9a7440!important;color:#f2d79e!important;font-family:'Courier New',monospace!important;font-weight:bold!important;text-transform:uppercase!important;text-decoration:none!important}.button:hover,button:hover,a.button:hover,a.tab:hover,.top-button:hover,.filters button:hover,.toolbar button:hover,.post:hover,.confirm:hover,.close:hover,.back:hover{background:#624825!important;color:#fff2c2!important}.button:active,button:active,a.button:active,a.tab:active,.top-button:active,.filters button:active{border-style:inset!important}.active,.tab.active,.filters button.active,.stage-strip span.active{background:#76542a!important;color:#fff3bf!important;border-color:#d4ad65!important}input,textarea,select,.editor,.search{background:#120f0c!important;color:#f3dfb6!important;border:2px inset #6e5738!important;font-family:'Courier New',monospace!important}.preview,.stage-scroll,.race-scroll,.clothing-grid{background:#18130e!important}.badge,.identity,.target,.level-strip,.mode{background:#302317!important;border:1px solid #8d6b3c!important;color:#eacb8f!important}table{border-collapse:separate!important;border-spacing:1px!important;background:#17110c!important}td,th{border:1px solid #4e3b27!important;background:#251c14!important}img{image-rendering:pixelated!important}.hint,small,.title span,.counter,.description,.footer{color:#bca47c!important}::-webkit-scrollbar{width:14px;height:14px}::-webkit-scrollbar-track{background:#17110c;border:1px solid #4b3824}::-webkit-scrollbar-thumb{background:#6b4e2d;border:2px outset #9b7441}
	"}

client/var/tmp
	datum/NexusHudWindow/nexus_hud_window
	datum/NexusChatHud/nexus_chat_hud
	list/nexus_chat_history

obj/HudWindow
	mouse_opacity = 2
	plane = 20 // Reserved above the per-client lighting plane.
	layer = 120
	appearance_flags = RESET_ALPHA | RESET_COLOR
	var/tmp/datum/NexusHudWindow/window
	var/tmp/action_id

	Click(location, control, params)
		if(!window || !window.canInteract()) return
		window.handleAction(action_id)

datum/NexusHudWindow
	var/tmp/mob/owner
	var/tmp/list/elements = list()

	New(mob/new_owner)
		. = ..()
		owner = new_owner

	Del()
		clearElements()
		if(owner && owner.client && owner.client.nexus_hud_window == src)
			owner.client.nexus_hud_window = null
		. = ..()

	proc/canInteract()
		return owner && owner.client && usr == owner

	proc/clearElements()
		if(!islist(elements)) elements = list()
		for(var/obj/hud_object in elements)
			if(owner && owner.client) owner.client.screen -= hud_object
			del(hud_object)
		elements.Cut()

	proc/addElement(label, action_id, x, y, width, height, background_color = "#101923", border_color = "#40556b", accent_color = "", text_color = "#edf3fa", text_alignment = "left", font_size = 9, mouse_enabled = TRUE)
		return addElementAt(label, action_id, "LEFT:[round(x)],TOP:-[round(y)]", width, height, background_color, border_color, accent_color, text_color, text_alignment, font_size, mouse_enabled)

	proc/addElementAt(label, action_id, screen_location, width, height, background_color = "#101923", border_color = "#40556b", accent_color = "", text_color = "#edf3fa", text_alignment = "left", font_size = 9, mouse_enabled = TRUE)
		if(!owner || !owner.client) return
		var/obj/hud_object = new /obj/HudWindow
		hud_object.vars["window"] = src
		hud_object.vars["action_id"] = action_id
		hud_object.icon = getNexusHudLibraryIcon(width, height, background_color, border_color, accent_color)
		hud_object.screen_loc = screen_location
		hud_object.maptext_x = text_alignment == "left" ? 9 : 0
		hud_object.maptext_y = max(1, round((height - font_size - 2) / 2))
		hud_object.maptext_width = text_alignment == "left" ? width - 16 : width
		hud_object.maptext_height = height
		hud_object.maptext = "<div style='font-family:Courier New;font-size:[font_size]px;font-weight:bold;color:[text_color];text-align:[text_alignment];white-space:nowrap;text-shadow:1px 1px #000'>[label]</div>"
		hud_object.mouse_opacity = mouse_enabled ? 2 : 1
		elements += hud_object
		owner.client.screen += hud_object
		return hud_object

	proc/handleAction(action_id)
		return

mob/var
	nexus_chat_hud_x = 312
	nexus_chat_hud_width = 500
	nexus_chat_hud_height = 210
	nexus_chat_hud_collapsed = FALSE

client/proc/initializeNexusChatHistory()
	if(!islist(nexus_chat_history)) nexus_chat_history = list()
	for(var/channel in list("all", "combat", "ic", "ooc"))
		if(!islist(nexus_chat_history[channel])) nexus_chat_history[channel] = list()

client/proc/operator<<(out, target, window)
	if(istext(out) && !window && mob && mob.playerCharacter)
		initializeNexusChatHistory()
		var/list/all_entries = nexus_chat_history["all"]
		all_entries += "<span style='color:#d4ad65'>\[SYSTEM\]</span> [out]"
		while(all_entries.len > 300) all_entries.Cut(1, 2)
		if(nexus_chat_hud)
			nexus_chat_hud.scroll_offset = 0
			nexus_chat_hud.refresh()
		mob.ChatLog(out, mob.key, "all")
		return
	return ..()

client/proc/receiveNexusHudChatMessage(message, channel = "all")
	if(!message) return
	initializeNexusChatHistory()
	channel = normalizeNexusChatChannel(channel)
	var/list/all_entries = nexus_chat_history["all"]
	all_entries += "<span style='color:#9b815c'>\[[uppertext(channel)]\]</span> [message]"
	while(all_entries.len > 300) all_entries.Cut(1, 2)
	if(channel != "all")
		var/list/channel_entries = nexus_chat_history[channel]
		channel_entries += message
		while(channel_entries.len > 300) channel_entries.Cut(1, 2)
	if(nexus_chat_hud)
		nexus_chat_hud.scroll_offset = 0
		nexus_chat_hud.refresh()

datum/NexusChatHud
	parent_type = /datum/NexusHudWindow
	var/tmp
		active_channel = "all"
		is_visible = TRUE
		scroll_offset = 0

	Del()
		if(owner && owner.client && owner.client.nexus_chat_hud == src) owner.client.nexus_chat_hud = null
		. = ..()

	proc/getVisibleMessageCount()
		if(!owner) return 4
		return max(4, round((owner.nexus_chat_hud_height - 70) / 18))

	proc/buildMessageHtml()
		if(!owner || !owner.client) return ""
		owner.client.initializeNexusChatHistory()
		var/list/entries = owner.client.nexus_chat_history[active_channel]
		if(!islist(entries) || !entries.len) return "<span style='color:#8f7b5e'>No [uppertext(active_channel)] messages yet.</span>"
		var/visible_count = getVisibleMessageCount()
		var/end_index = max(1, entries.len - scroll_offset)
		var/start_index = max(1, end_index - visible_count + 1)
		var/rendered = ""
		for(var/entry_index = start_index, entry_index <= end_index, entry_index++)
			rendered += "<div style='border-bottom:1px solid #3b2b1c;padding:2px 1px'>[entries[entry_index]]</div>"
		return rendered

	proc/refresh()
		clearElements()
		if(!is_visible || !owner || !owner.client || !owner.playerCharacter) return
		var/panel_x = Clamp(round(owner.nexus_chat_hud_x), 8, 900)
		var/panel_y = 8
		var/panel_width = Clamp(round(owner.nexus_chat_hud_width), 360, 820)
		var/panel_height = Clamp(round(owner.nexus_chat_hud_height), 130, 460)
		owner.nexus_chat_hud_x = panel_x
		owner.nexus_chat_hud_width = panel_width
		owner.nexus_chat_hud_height = panel_height
		if(owner.nexus_chat_hud_collapsed) panel_height = 24
		addElementAt("", null, "LEFT:[panel_x],BOTTOM:[panel_y]", panel_width, panel_height, "#201810", "#765a35", "", "#ead39f", "left", 9, FALSE)
		var/header_y = panel_y + panel_height - 22
		var/control_width = 21
		var/list/header_actions = list("scroll_up" = "^", "scroll_down" = "v", "move_left" = "<-", "move_right" = "->", "width_down" = "W-", "width_up" = "W+", "height_down" = "H-", "height_up" = "H+", "collapse" = owner.nexus_chat_hud_collapsed ? "+" : "_")
		var/control_x = panel_x + panel_width - 4 - (header_actions.len * control_width)
		addElementAt("CHAT / [uppertext(active_channel)]", null, "LEFT:[panel_x + 4],BOTTOM:[header_y]", max(60, control_x - panel_x - 4), 20, "#382719", "#8f6c3b", "#d2aa61", "#f1d69c", "left", 9, FALSE)
		for(var/action_id in header_actions)
			addElementAt(header_actions[action_id], action_id, "LEFT:[control_x],BOTTOM:[header_y]", control_width, 20, "#46321d", "#987140", "", "#f2d8a0", "center", 8)
			control_x += control_width
		if(owner.nexus_chat_hud_collapsed) return
		var/tab_y = panel_y + panel_height - 43
		var/tab_width = round((panel_width - 8) / 4)
		var/tab_x = panel_x + 4
		for(var/channel in list("all", "combat", "ic", "ooc"))
			var/is_active = channel == active_channel
			addElementAt(uppertext(channel), "channel:[channel]", "LEFT:[tab_x],BOTTOM:[tab_y]", tab_width, 19, is_active ? "#725027" : "#302319", is_active ? "#d2aa61" : "#725735", is_active ? "#e0bd74" : "", is_active ? "#fff0bd" : "#cbb389", "center", 8)
			tab_x += tab_width
		var/footer_height = 22
		var/message_y = panel_y + footer_height
		var/message_height = max(40, panel_height - 68)
		var/obj/message_panel = addElementAt("", null, "LEFT:[panel_x + 4],BOTTOM:[message_y]", panel_width - 8, message_height, "#130f0b", "#574128", "", "#ead7b0", "left", 8, FALSE)
		message_panel.maptext_x = 7
		message_panel.maptext_y = 5
		message_panel.maptext_width = panel_width - 22
		message_panel.maptext_height = message_height - 10
		message_panel.maptext = "<div style='font-family:Courier New;font-size:8px;color:#ead7b0'>[buildMessageHtml()]</div>"
		var/list/footer_actions = list("say" = "SAY", "ooc" = "OOC", "emote" = "EMOTE", "logs" = "LOGS")
		var/footer_width = round((panel_width - 8) / footer_actions.len)
		var/footer_x = panel_x + 4
		for(var/action_id in footer_actions)
			addElementAt(footer_actions[action_id], action_id, "LEFT:[footer_x],BOTTOM:[panel_y + 2]", footer_width, 18, "#3c2b1a", "#846238", "", "#ead09a", "center", 8)
			footer_x += footer_width

	handleAction(action_id)
		if(!owner || !owner.client) return
		if(findtext(action_id, "channel:") == 1)
			active_channel = normalizeNexusChatChannel(copytext(action_id, 9))
			scroll_offset = 0
		else switch(action_id)
			if("scroll_up")
				owner.client.initializeNexusChatHistory()
				var/list/entries = owner.client.nexus_chat_history[active_channel]
				scroll_offset = min(max(0, entries.len - 1), scroll_offset + getVisibleMessageCount())
			if("scroll_down") scroll_offset = max(0, scroll_offset - getVisibleMessageCount())
			if("move_left") owner.nexus_chat_hud_x = max(8, owner.nexus_chat_hud_x - 64)
			if("move_right") owner.nexus_chat_hud_x = min(900, owner.nexus_chat_hud_x + 64)
			if("width_down") owner.nexus_chat_hud_width = max(360, owner.nexus_chat_hud_width - 64)
			if("width_up") owner.nexus_chat_hud_width = min(820, owner.nexus_chat_hud_width + 64)
			if("height_down") owner.nexus_chat_hud_height = max(130, owner.nexus_chat_hud_height - 48)
			if("height_up") owner.nexus_chat_hud_height = min(460, owner.nexus_chat_hud_height + 48)
			if("collapse") owner.nexus_chat_hud_collapsed = !owner.nexus_chat_hud_collapsed
			if("say") spawn() owner.Say()
			if("ooc") spawn() owner.GlobalSay()
			if("emote") owner.showNexusEmoteEditor()
			if("logs") owner.showNexusPlayerLogs(active_channel)
		refresh()

	proc/setVisible(new_visibility)
		is_visible = !!new_visibility
		refresh()

mob/proc/hideNexusLegacyInterface()
	if(!client) return
	winset(src, "mainwindow.mainvsplit", "left=mapwindow;right=;splitter=100")
	winset(src, "mapwindow", "is-visible=true")
	winset(src, "mapwindow.map", "is-visible=true")
	winset(src, "mpane.mpanewindow", "right=;splitter=100")
	for(var/window_id in list("rpane", "infowindow", "outputwindow", "chat", "chat2", "chat3")) winset(src, window_id, "is-visible=false")

mob/proc/initializeNexusChatHud()
	if(!client || !playerCharacter) return
	hideNexusLegacyInterface()
	if(client.nexus_chat_hud) del(client.nexus_chat_hud)
	client.nexus_chat_hud = new /datum/NexusChatHud(src)
	client.nexus_chat_hud.refresh()

mob/proc/toggleNexusChatHud()
	if(!client || !playerCharacter) return
	if(!client.nexus_chat_hud) initializeNexusChatHud()
	else client.nexus_chat_hud.setVisible(!client.nexus_chat_hud.is_visible)
