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
		if(owner && owner.client)
			owner << browse(null, "window=nexuschatwindow.chat")
			if(owner.client.nexus_chat_hud == src) owner.client.nexus_chat_hud = null
		. = ..()

	proc/getVisibleMessageCount()
		return 80

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
			if(length(rendered)) rendered += "<br><span style='color:#4b3927'>------------------------------------------------------------</span><br>"
			rendered += "<span>[entries[entry_index]]</span>"
		return rendered

	proc/getRightAnchoredLocation(panel_width, local_x, element_width, bottom_y)
		var/right_offset = 8 + panel_width - local_x - element_width
		return "RIGHT:-[right_offset],BOTTOM:[bottom_y]"

	proc/buildLink(label, action_id, class_name = "button")
		return "<a class='[class_name]' href='byond://?src=\ref[src]&action=[action_id]'>[html_encode(label)]</a>"

	proc/buildHtml()
		var/tabs = ""
		for(var/channel in list("all", "combat", "ic", "ooc"))
			var/tab_class = channel == active_channel ? "tab active" : "tab"
			tabs += buildLink(uppertext(channel), "channel&id=[channel]", tab_class)
		var/footer = buildLink("SAY", "say")
		footer += buildLink("OOC", "ooc")
		footer += buildLink("EMOTE", "emote")
		footer += buildLink("LOGS", "logs")
		return {"<!doctype html><html><head><meta charset='utf-8'><title>Nexus Chat</title><style>[getNexusRpgBrowserCss()]
		*{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:hidden;font:10px 'Courier New',monospace}.shell{height:100vh;display:flex;flex-direction:column;padding:4px;background:#17110c}.header{display:flex;align-items:center;gap:3px;flex:0 0 24px;padding:3px 4px;border:2px solid #755a36;background:#3a2a1b}.header b{margin-right:auto;color:#f0d497;font-size:11px}.button,.tab{display:block;padding:4px 6px;border:2px outset #9a7440;background:#49351f;color:#f2d79e;text-align:center;text-decoration:none;font-weight:bold}.header .button{padding:2px 5px}.tabs{display:grid;grid-template-columns:repeat(4,1fr);gap:3px;flex:0 0 25px;margin-top:3px}.tab{padding:4px 2px}.tab.active{background:#76542a;color:#fff3bf;border-color:#d4ad65}.messages{flex:1;min-height:0;margin-top:3px;padding:7px;overflow-y:auto;border:2px inset #574128;background:#100d09;color:#ead7b0;font-size:10px;line-height:1.35}.footer{display:grid;grid-template-columns:repeat(4,1fr);gap:3px;flex:0 0 25px;margin-top:3px}.footer .button{padding:4px 1px}.hint{flex:0 0 15px;padding-top:3px;color:#927b58;text-align:center;font-size:8px}::-webkit-scrollbar{width:12px}::-webkit-scrollbar-track{background:#17110c}::-webkit-scrollbar-thumb{background:#6b4e2d;border:2px outset #9b7441}
		</style><script>window.onload=function(){var panel=document.getElementById('messages');if(panel){panel.scrollTop=panel.scrollHeight;}}</script></head><body><div class='shell'><div class='header'><b>CHAT / [uppertext(active_channel)]</b>[buildLink("UP", "scroll_up")][buildLink("DOWN", "scroll_down")][buildLink("HIDE", "hide")]</div><div class='tabs'>[tabs]</div><div class='messages' id='messages'>[buildMessageHtml()]</div><div class='footer'>[footer]</div><div class='hint'>CMD BAR BELOW / ENTER TO FOCUS OR RETURN TO MAP</div></div></body></html>"}

	proc/attachSidePanel()
		if(!owner || !owner.client) return
		winset(owner, "mainwindow.mainvsplit", "left=mapwindow;right=nexuschatwindow;splitter=74")
		winset(owner, "nexuschatwindow", "is-visible=true")
		winset(owner, "nexuschatwindow.chat", "is-visible=true")
		winset(owner, "nexuschatwindow.command", "is-visible=true")

	proc/refresh()
		clearElements()
		if(!is_visible || !owner || !owner.client || !owner.playerCharacter) return
		owner << browse(buildHtml(), "window=nexuschatwindow.chat")

	handleAction(action_id)
		if(!owner || !owner.client) return
		switch(action_id)
			if("scroll_up")
				owner.client.initializeNexusChatHistory()
				var/list/entries = owner.client.nexus_chat_history[active_channel]
				scroll_offset = min(max(0, entries.len - 1), scroll_offset + getVisibleMessageCount())
			if("scroll_down") scroll_offset = max(0, scroll_offset - getVisibleMessageCount())
			if("say") spawn() owner.Say()
			if("ooc") spawn() owner.GlobalSay()
			if("emote") owner.showNexusEmoteEditor()
			if("logs") owner.showNexusPlayerLogs(active_channel)
			if("hide")
				setVisible(FALSE)
				return
		refresh()

	Topic(href, list/href_list)
		if(!owner || !owner.client || usr != owner) return
		var/action_id = href_list["action"]
		if(action_id == "channel")
			active_channel = normalizeNexusChatChannel(href_list["id"])
			scroll_offset = 0
			refresh()
			return
		handleAction(action_id)

	proc/setVisible(new_visibility)
		is_visible = !!new_visibility
		if(owner && owner.client) owner.client.show_chatbox = is_visible
		if(is_visible)
			attachSidePanel()
			refresh()
		else if(owner && owner.client)
			owner << browse(null, "window=nexuschatwindow.chat")
			winset(owner, "mainwindow.mainvsplit", "left=mapwindow;right=;splitter=100")
			winset(owner, "mapwindow.map", "focus=true")

mob/proc/hideNexusLegacyInterface()
	if(!client) return
	winset(src, "mainwindow.mainvsplit", "left=mapwindow;right=nexuschatwindow;splitter=74")
	winset(src, "mapwindow", "is-visible=true")
	winset(src, "mapwindow.map", "is-visible=true")
	winset(src, "nexuschatwindow", "is-visible=true")
	winset(src, "mpane.mpanewindow", "right=;splitter=100")
	for(var/window_id in list("rpane", "infowindow", "outputwindow", "chat", "chat2", "chat3")) winset(src, window_id, "is-visible=false")

mob/proc/initializeNexusChatHud()
	if(!client || !playerCharacter) return
	hideNexusLegacyInterface()
	if(client.nexus_chat_hud) del(client.nexus_chat_hud)
	client.nexus_chat_hud = new /datum/NexusChatHud(src)
	client.nexus_chat_hud.setVisible(client.show_chatbox)

mob/proc/toggleNexusChatHud()
	if(!client || !playerCharacter) return
	if(!client.nexus_chat_hud) initializeNexusChatHud()
	else client.nexus_chat_hud.setVisible(!client.nexus_chat_hud.is_visible)
