client/var/tmp/datum/ClassicHud/nexus_classic_hud
client/var/tmp/nexus_classic_typing = FALSE
mob/var/list/nexus_classic_layout
mob/var/list/nexus_classic_viewport

proc/classicNumber(value, fallback = 0)
	return nexusIsFiniteNumber(value) ? value : fallback

proc/normalizeClassicGeometry(list/state, id, width = 1366, height = 768)
	if(!islist(state)) state = list()
	var/is_bar = isClassicBarId(id)
	var/is_fixed_panel = id == "menu" || id == "inventory" || id == "skills"
	var/default_width = id == "chat" ? 540 : (isClassicBarId(id) ? 541 : 280)
	var/default_height = isClassicBarId(id) ? 52 : (id == "chat" ? 480 : 220)
	if(is_fixed_panel)
		default_width = 460
		default_height = 680
	else if(id == "stats")
		default_width = 380
		default_height = 430
	if(id == "target") default_height = 286
	width = max(240, classicNumber(width, 1366))
	height = max(160, classicNumber(height, 768))
	var/panel_width = is_fixed_panel ? min(default_width, width) : round(Clamp(classicNumber(state["w"], default_width), min(is_bar ? 60 : 240, width), width))
	var/minimum_height = isClassicBarId(id) ? 52 : 120
	var/panel_height = is_fixed_panel ? min(default_height, height) : round(Clamp(classicNumber(state["h"], default_height), minimum_height, height))
	var/default_x = (id in list("menu", "stats", "inventory", "skills")) ? 8 : max(8, width - panel_width - 8)
	var/default_y = id == "chat" ? height - panel_height - 66 : 150
	if(isClassicBarId(id))
		default_x = max(0, round((width - panel_width) / 2))
		default_y = height - panel_height
	if(id == "target") default_x = max(8, width - panel_width - 300)
	return list("x" = round(Clamp(classicNumber(state["x"], default_x), 0, width - panel_width)), "y" = round(Clamp(classicNumber(state["y"], default_y), 0, max(0, height - (state["collapsed"] ? 26 : panel_height)))), "w" = panel_width, "h" = panel_height, "collapsed" = !!state["collapsed"], "open" = ("open" in state) ? !!state["open"] : (id in list("chat", "bar")))

proc/resizeClassicGeometry(list/state, id, old_width, old_height, new_width, new_height)
	if(!islist(state)) state = normalizeClassicGeometry(null, id, old_width, old_height)
	state = state.Copy()
	// Preserve the distance from the nearest screen edge when the map changes size.
	if(state["x"] + state["w"] / 2 > old_width / 2) state["x"] += new_width - old_width
	if(state["y"] + state["h"] / 2 > old_height / 2) state["y"] += new_height - old_height
	return normalizeClassicGeometry(state, id, new_width, new_height)

mob/proc/initializeClassicHud()
	if(!client || !playerCharacter) return
	if(client.nexus_classic_hud && client.nexus_classic_hud.owner != src) del(client.nexus_classic_hud)
	if(!client.nexus_classic_hud) client.nexus_classic_hud = new(src)
	client.nexus_classic_hud.applyLayout()

mob/proc/showClassicWidget(id, requested_section)
	if(!client || !playerCharacter) return
	initializeClassicHud()
	if(requested_section) client.nexus_classic_hud.section = requested_section
	client.nexus_classic_hud.setOpen(id, TRUE)
	if(id == "sense") client.nexus_classic_hud.setOpen("target", TRUE)

mob/proc/toggleClassicWidget(id, requested_section)
	if(!client || !playerCharacter) return
	initializeClassicHud()
	if(requested_section) client.nexus_classic_hud.section = requested_section
	client.nexus_classic_hud.setOpen(id, !client.nexus_classic_hud.isOpen(id))

mob/verb/closeClassicLegacy()
	set hidden = TRUE
	if(client && client.nexus_classic_hud) client.nexus_classic_hud.legacy_open = FALSE
	winset(src, "classiclegacy", "is-visible=false")
	winset(src, "classiclegacy.body", "left=")
	if(client && client.nexus_chat_hud) client.nexus_chat_hud.applyLayout()

datum/ClassicHud
	var/tmp
		mob/owner
		list/windows = list()
		list/ready = list()
		list/payloads = list()
		list/last_widget_refresh = list()
		chat_signature
		chat_refresh_pending = FALSE
		list/command_entries = list()
		section = "actions"
		chat_channel = "all"
		legacy_open = FALSE
		loop_running = FALSE
		viewport_width = 1366
		viewport_height = 768
		last_viewport_poll = -100
		last_menu_refresh = -100
		last_saved = 0
		dirty = FALSE
		generation = 0

	New(mob/new_owner)
		owner = new_owner
		if(!islist(owner.nexus_classic_layout)) owner.nexus_classic_layout = list()
		if(islist(owner.nexus_classic_viewport))
			viewport_width = max(240, classicNumber(owner.nexus_classic_viewport["w"], viewport_width))
			viewport_height = max(160, classicNumber(owner.nexus_classic_viewport["h"], viewport_height))
		owner.initializeClassicBars(viewport_width, viewport_height)
		pollViewport()
		for(var/id in list("chat", "sense", "target", "bar", "menu", "stats", "inventory", "skills"))
			owner.nexus_classic_layout[id] = normalizeClassicGeometry(owner.nexus_classic_layout[id], id, viewport_width, viewport_height)
		for(var/bar_id in owner.nexus_classic_bars)
			if(!islist(owner.nexus_classic_layout[bar_id])) owner.nexus_classic_layout[bar_id] = normalizeClassicGeometry(null, bar_id, viewport_width, viewport_height)
		startLoop()

	Del()
		if(owner && owner.client)
			if(dirty) owner.save_player_settings()
			for(var/id in windows)
				owner << browse(null, "window=[control(id)]")
			for(var/id in owner.nexus_classic_bars)
				if(id != "bar") winset(owner, control(id), "parent=")
			for(var/id in list("inventory", "skills")) winset(owner, control(id), "parent=")
			winset(owner, "classiclegacy", "is-visible=false")
			winset(owner, "classiclegacy.body", "left=")
			if(owner.client.nexus_classic_hud == src) owner.client.nexus_classic_hud = null
			owner.client.nexus_classic_typing = FALSE
			winset(owner, "mapwindow", "macro=macro")
		owner = null
		. = ..()

	proc/control(id)
		return "mapwindow.classic_[id]"

	proc/isOpen(id)
		return owner && islist(owner.nexus_classic_layout) && islist(owner.nexus_classic_layout[id]) && owner.nexus_classic_layout[id]["open"]

	proc/isVisible(id)
		if(!isOpen(id)) return FALSE
		if(isClassicBarId(id) && !islist(owner.nexus_classic_bars[id])) return FALSE
		if(id == "chat") return owner.nexus_interface_layout == "overlay" && owner.client.nexus_chat_hud && owner.client.nexus_chat_hud.is_visible
		return TRUE

	proc/setOpen(id, value)
		if(!owner || !(id in owner.nexus_classic_layout)) return
		owner.nexus_classic_layout[id]["open"] = !!value
		if(id == "chat" && owner.client.nexus_chat_hud) owner.client.nexus_chat_hud.is_visible = !!value
		if(!value)
			owner.client.nexus_classic_typing = FALSE
			winset(owner, "mapwindow", "macro=macro")
		dirty = TRUE
		applyLayout()
		refresh()

	proc/reloadWidget(id)
		if(!owner || !windows[id]) return
		owner << browse(null, "window=[control(id)]")
		windows -= id
		ready -= id
		payloads -= id
		applyLayout()

	proc/pollViewport()
		if(!owner || !owner.client) return
		var/list/size_parts = splittext(winget(owner, "mapwindow.map", "size"), "x")
		if(size_parts.len != 2) return
		var/new_width = max(240, text2num(size_parts[1]))
		var/new_height = max(160, text2num(size_parts[2]))
		owner.nexus_classic_viewport = list("w" = new_width, "h" = new_height)
		if(new_width == viewport_width && new_height == viewport_height) return
		for(var/id in owner.nexus_classic_layout)
			owner.nexus_classic_layout[id] = resizeClassicGeometry(owner.nexus_classic_layout[id], id, viewport_width, viewport_height, new_width, new_height)
			if(windows[id]) applyGeometry(id)
		viewport_width = new_width
		viewport_height = new_height
		dirty = TRUE

	proc/applyGeometry(id)
		var/list/state = owner.nexus_classic_layout[id]
		winset(owner, control(id), "pos=[state["x"]],[state["y"]];size=[state["w"]]x[state["collapsed"] ? 26 : state["h"]];is-visible=true")

	proc/applyLayout()
		if(!owner || !owner.client) return
		pollViewport()
		for(var/id in owner.nexus_classic_layout)
			if(!isVisible(id))
				if(windows[id])
					owner << browse(null, "window=[control(id)]")
					winset(owner, control(id), "is-visible=false")
					windows -= id
					ready -= id
					payloads -= id
				continue
			if(!windows[id])
				if((isClassicBarId(id) && id != "bar") || id == "inventory" || id == "skills")
					var/control_background = isClassicBarId(id) ? "#00000000" : "#181510"
					winset(owner, "classic_[id]", "parent=mapwindow;type=browser;is-visible=false;border=none;background-color=[control_background]")
				if(isClassicBarId(id))
					// WebView2 transparency was added in Dream Seeker 516.1680. Keep
					// this runtime-only so older Dream Maker skin parsers do not treat
					// the unknown DMF parameter as a missing file.
					winset(owner, control(id), "background-color=#00000000;inner-background-color=#00000000")
				windows[id] = "[++generation]"
				prepareNexusHudBrowserResources(owner)
				owner << browse_rsc('src/Code/UI/Browser/ClassicHud.css', "ClassicHud.css")
				owner << browse_rsc('src/Code/UI/Browser/ClassicHud.js', "ClassicHud.js")
				applyGeometry(id)
				owner << browse(buildHtml(id), "window=[control(id)]")

	proc/buildHtml(id)
		var/list/config = list("id" = id, "kind" = isClassicBarId(id) ? "bar" : id, "ref" = "\ref[src]", "generation" = windows[id], "geometry" = owner.nexus_classic_layout[id], "viewport" = list("w" = viewport_width, "h" = viewport_height))
		var/encoded_config = url_encode(json_encode(config))
		return {"<!doctype html><html><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'><link rel='stylesheet' href='ClassicHud.css'></head><body><script>window.classicConfig=JSON.parse(decodeURIComponent('[encoded_config]'));</script><script src='ClassicHud.js'></script></body></html>"}

	proc/push(id, list/data)
		if(!ready[id] || !windows[id]) return
		data["geometry"] = owner.nexus_classic_layout[id]
		data["viewport"] = list("w" = viewport_width, "h" = viewport_height)
		var/payload = json_encode(data)
		if(payloads[id] == payload) return
		payloads[id] = payload
		owner << output(url_encode(payload), "[control(id)]:classicUpdate")

	proc/startLoop()
		set waitfor = FALSE
		if(loop_running) return
		loop_running = TRUE
		while(src && owner && owner.client && owner.playerCharacter)
			if(world.time - last_viewport_poll >= 20)
				pollViewport()
				last_viewport_poll = world.time
			refresh(TRUE)
			if(dirty && world.time - last_saved >= 30)
				owner.save_player_settings()
				dirty = FALSE
				last_saved = world.time
			sleep(5)
		if(src) loop_running = FALSE

	proc/queueChatRefresh()
		set waitfor = FALSE
		if(chat_refresh_pending) return
		chat_refresh_pending = TRUE
		sleep(1)
		if(!src) return
		chat_refresh_pending = FALSE
		if(owner && owner.nexus_classic_layout["chat"]["collapsed"] && payloads["chat"]) return
		refreshChat()

	proc/refreshChat()
		if(!owner || !owner.client || !ready["chat"] || !isVisible("chat")) return
		var/signature = json_encode(list(owner.client.nexus_chat_revision, chat_channel, owner.TextSize, owner.nexus_classic_layout["chat"], viewport_width, viewport_height))
		if(payloads["chat"] && chat_signature == signature) return
		owner.client.initializeNexusChatHistory()
		var/list/entries = owner.client.nexus_chat_history[chat_channel]
		var/list/messages = list()
		for(var/entry in entries) messages += getNexusChatEntryHtml(entry)
		push("chat", list("channel" = chat_channel, "messages" = messages, "fontSize" = Clamp(round(owner.TextSize + 11), 12, 21)))
		chat_signature = signature

	proc/shouldRefreshWidget(id, periodic = FALSE)
		if(periodic && payloads[id])
			if(owner.nexus_classic_layout[id]["collapsed"]) return FALSE
			var/interval = (isClassicBarId(id) || id == "target") ? 5 : 10
			if(world.time - last_widget_refresh[id] < interval) return FALSE
		last_widget_refresh[id] = world.time
		return TRUE

	proc/refresh(periodic = FALSE)
		if(!owner || !owner.client) return
		for(var/id in windows)
			if(!ready[id] || !isVisible(id)) continue
			if(!shouldRefreshWidget(id, periodic)) continue
			if(isClassicBarId(id))
				var/list/bar = owner.nexus_classic_bars[id]
				if(islist(bar)) push(id, list("slots" = owner.buildClassicActionBar(FALSE, id), "columns" = bar["columns"], "size" = bar["size"], "locked" = bar["locked"], "name" = bar["name"]))
				continue
			switch(id)
				if("chat")
					refreshChat()
				if("menu")
					if(world.time - last_menu_refresh < 10 && payloads[id]) continue
					last_menu_refresh = world.time
					push(id, buildMenuData())
				else
					var/datum/ClassicSnapshot/snapshot = owner.captureClassicData(id)
					push(id, list("rows" = snapshot.rows, "name" = id == "target" && owner.canMonitorClassicTarget(owner.Target) ? "[owner.Target]" : "", "empty" = id == "target" ? "No readable target. Select a signature in Sense." : "No readable signatures nearby."))
					del(snapshot)

	proc/buildCommands()
		command_entries = list()
		var/list/sources = list(owner)
		for(var/obj/object in owner) sources += object
		for(var/atom/source in sources)
			for(var/verb_path in source.verbs)
				var/list/metadata = nexus_classic_command_catalog["[verb_path]"]
				if(!islist(metadata) || isnull(metadata[2])) continue
				if(lowertext(metadata[2]) == "admin" && !owner.IsAdmin()) continue
				var/token = md5("\ref[source]|[verb_path]")
				command_entries[token] = list("source" = source, "path" = verb_path, "name" = metadata[1], "category" = metadata[2], "explicit" = metadata[3])

	proc/buildMenuData()
		var/list/catalog = getClassicSections()
		if(!owner.IsAdmin())
			catalog -= "admin"
		if(!(section in catalog)) section = "actions"
		if(section in list("actions", "playtest", "admin")) buildCommands()
		else command_entries = list()
		var/list/commands = list()
		for(var/token in command_entries)
			var/list/entry = command_entries[token]
			if(section == "playtest" && lowertext(entry["category"]) != "playtest") continue
			if(section == "admin" && lowertext(entry["category"]) != "admin") continue
			if(!(section in list("actions", "playtest", "admin"))) continue
			commands += list(list("token" = token, "label" = entry["name"], "value" = entry["category"], "group" = entry["category"]))
		var/datum/ClassicSnapshot/snapshot = owner.captureClassicData(section)
		var/list/result = list("sections" = catalog, "section" = section, "rows" = snapshot.rows, "commands" = commands)
		del(snapshot)
		return result

	proc/runCommand(token)
		buildCommands()
		var/list/entry = command_entries[token]
		if(!islist(entry)) return
		var/atom/source = entry["source"]
		if(!source || (source != owner && source.loc != owner) || !(entry["path"] in source.verbs)) return
		if(istype(source, /obj/items))
			var/obj/items/item = source
			if(!item.canUseAfterNexusTradeYield(owner)) return
		// The native command parser prompts for arguments and rechecks verb permissions.
		var/command = replacetext(entry["name"], " ", "-")
		winset(owner, null, list2params(list("command" = command)))

	proc/showLegacy()
		legacy_open = TRUE
		// Move the existing default Info pane; BYOND cannot reliably swap default Info controls.
		winset(owner, "rpane.rpanewindow", "left=")
		winset(owner, "classiclegacy.body", "left=infowindow;splitter=100")
		winset(owner, "infowindow", "is-visible=true")
		winset(owner, "classiclegacy", "is-visible=true")
		owner.client.show_verb_panel = TRUE
		owner.RefreshAllTabsNoWait()

	Topic(href, list/href_list)
		if(!owner || !owner.client || usr != owner || !owner.playerCharacter) return
		var/id = href_list["widget"]
		if(!windows[id] || href_list["generation"] != windows[id]) return
		var/action = href_list["action"]
		if(isClassicBarId(id) && (action in list("use", "assign", "swap", "clear")))
			var/slot = text2num(href_list["value"])
			if(owner.classicBarForSlot(slot) != id) return
		if(action == "ready")
			ready[id] = TRUE
			payloads -= id
		else if(action == "typing")
			owner.client.nexus_classic_typing = href_list["value"] == "1"
			if(owner.client.nexus_classic_typing)
				owner.StopMovement()
				for(var/held_key in owner.keys_down.Copy()) owner.HandleKeyUp(held_key)
		else if(action == "geometry")
			if(isClassicBarId(id) && owner.nexus_classic_bars[id]["locked"])
				applyGeometry(id)
				return
			var/list/state = owner.nexus_classic_layout[id].Copy()
			for(var/key in list("x", "y")) state[key] = text2num(href_list[key])
			if(!(id in list("menu", "inventory", "skills")))
				for(var/key in list("w", "h")) state[key] = text2num(href_list[key])
			if(isClassicBarId(id)) state["w"] = max(state["w"], owner.nexus_classic_bars[id]["size"] + 28)
			owner.nexus_classic_layout[id] = normalizeClassicGeometry(state, id, viewport_width, viewport_height)
			applyGeometry(id)
			dirty = TRUE
		else if(action == "close")
			setOpen(id, FALSE)
			return
		else if(action == "collapse")
			owner.nexus_classic_layout[id]["collapsed"] = !owner.nexus_classic_layout[id]["collapsed"]
			applyGeometry(id)
			dirty = TRUE
		else if(action == "channel" && id == "chat")
			chat_channel = normalizeNexusChatChannel(href_list["value"])
			owner.client.nexus_chat_hud.active_channel = chat_channel
		else if(action == "chat" && id == "chat")
			var/chat_action = href_list["value"]
			if(chat_action in list("say", "ooc", "emote", "logs", "cmd")) owner.client.nexus_chat_hud.handleAction(chat_action)
		else if(action == "section" && id == "menu")
			section = href_list["value"]
			payloads -= "menu"
		else if(action == "command" && id == "menu") runCommand(href_list["value"])
		else if(action == "settings" && id == "menu") owner.Settings()
		else if(action == "ki_settings" && id == "menu") owner.kiSettings()
		else if(action == "inventory" && id == "menu") setOpen("inventory", TRUE)
		else if(action == "skills" && id == "menu") setOpen("skills", TRUE)
		else if(action == "legacy" && id == "menu") showLegacy()
		else if(action == "reset" && id == "menu")
			for(var/widget in owner.nexus_classic_layout)
				var/list/state = normalizeClassicGeometry(null, widget, viewport_width, viewport_height)
				state["open"] = isOpen(widget)
				owner.nexus_classic_layout[widget] = state
				if(windows[widget]) applyGeometry(widget)
			dirty = TRUE
		else if(action == "widget" && id == "menu")
			var/widget = href_list["value"]
			if(widget == "bar") owner.showNexusHotkeyEditor()
			else if(widget in list("sense", "target", "chat", "stats")) setOpen(widget, TRUE)
		else if(action == "row" && (id in list("sense", "menu", "stats", "inventory", "skills")))
			var/datum/ClassicSnapshot/snapshot = owner.captureClassicData(id == "menu" ? section : id)
			var/atom/subject = snapshot.subjects[href_list["value"]]
			del(snapshot)
			if(subject)
				if(id == "sense" && ismob(subject) && owner.canMonitorClassicTarget(subject))
					owner.setSelectedTarget(subject, FALSE)
					owner.Target = subject // Sense can inspect signatures beyond combat selection range.
					setOpen("target", TRUE)
				else subject.Click(null, "classic", "left=1")
		else if((action == "panel_use" || action == "panel_bar" || action == "panel_examine") && (id == "inventory" || id == "skills"))
			var/datum/ClassicSnapshot/panel_snapshot = owner.captureClassicData(id)
			var/obj/subject = panel_snapshot.subjects[href_list["value"]]
			del(panel_snapshot)
			if(subject)
				if(action == "panel_use")
					if(id == "skills") owner.executeNexusHotkeyAction(subject)
					else subject.Click(null, "classic", "left=1")
				else if(action == "panel_bar" && owner.isNexusHotkeyObjectAvailable(subject)) owner.showNexusHotkeyEditor(0, null, "classic-skill:\ref[subject]")
				else if(action == "panel_examine")
					if(owner.client.nexus_player_menu) del(owner.client.nexus_player_menu)
					var/datum/NexusPlayerMenu/detail_panel = new(owner, id)
					detail_panel.embedded_widget = id
					owner.client.nexus_player_menu = detail_panel
					if(id == "skills") detail_panel.showSkillExamine(subject)
					else if(istype(subject, /obj/items)) detail_panel.showItemExamine(subject)
		else if(action == "use" && isClassicBarId(id))
			owner.useClassicSlot(text2num(href_list["value"]))
		else if(action == "lock" && isClassicBarId(id))
			owner.nexus_classic_bars[id]["locked"] = !owner.nexus_classic_bars[id]["locked"]
			owner.classicBarChanged()
		else if(action == "hotkeys" && isClassicBarId(id)) owner.showNexusHotkeyEditor(text2num(href_list["value"]), id)
		else if(action == "assign" && isClassicBarId(id) && !owner.nexus_classic_bars[id]["locked"])
			owner.assignClassicSlot(text2num(href_list["value"]), href_list["token"])
		else if(action == "swap" && isClassicBarId(id) && !owner.nexus_classic_bars[id]["locked"])
			owner.swapClassicSlots(text2num(href_list["value"]), text2num(href_list["from"]))
		else if(action == "clear" && isClassicBarId(id) && !owner.nexus_classic_bars[id]["locked"]) owner.clearClassicSlot(text2num(href_list["value"]))
		else if(action == "skills" && isClassicBarId(id)) owner.showNexusPlayerMenu("skills")
		refresh()
