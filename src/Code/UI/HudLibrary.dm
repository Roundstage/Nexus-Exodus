var/list/nexus_hud_library_icon_cache = list()

proc/getNexusHudLibraryIcon(width, height, background_color = "#101923", border_color = "#40556b", accent_color = "")
	width = max(1, round(width))
	height = max(1, round(height))
	var/cache_key = "[width]x[height]-[background_color]-[border_color]-[accent_color]"
	if(nexus_hud_library_icon_cache[cache_key]) return nexus_hud_library_icon_cache[cache_key]
	var/icon/panel_icon = icon('UserNamesBarsUi.png')
	panel_icon.Scale(width, height)
	panel_icon.DrawBox(background_color, 1, 1, width, height)
	panel_icon.DrawBox(border_color, 1, 1, width, 1)
	panel_icon.DrawBox(border_color, 1, height, width, height)
	panel_icon.DrawBox(border_color, 1, 1, 1, height)
	panel_icon.DrawBox(border_color, width, 1, width, height)
	if(accent_color) panel_icon.DrawBox(accent_color, 1, 1, 4, height)
	nexus_hud_library_icon_cache[cache_key] = panel_icon
	return panel_icon

client/var/tmp/datum/NexusHudWindow/nexus_hud_window

obj/HudWindow
	mouse_opacity = 2
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
		if(!owner || !owner.client) return
		var/obj/hud_object = new /obj/HudWindow
		hud_object.vars["window"] = src
		hud_object.vars["action_id"] = action_id
		hud_object.icon = getNexusHudLibraryIcon(width, height, background_color, border_color, accent_color)
		hud_object.screen_loc = "LEFT:[round(x)],TOP:-[round(y)]"
		hud_object.maptext_x = text_alignment == "left" ? 9 : 0
		hud_object.maptext_y = max(1, round((height - font_size - 2) / 2))
		hud_object.maptext_width = text_alignment == "left" ? width - 16 : width
		hud_object.maptext_height = height
		hud_object.maptext = "<div style='font-family:Arial;font-size:[font_size]px;font-weight:bold;color:[text_color];text-align:[text_alignment];white-space:nowrap;text-shadow:1px 1px #000'>[label]</div>"
		hud_object.mouse_opacity = mouse_enabled ? 2 : 1
		elements += hud_object
		owner.client.screen += hud_object
		return hud_object

	proc/handleAction(action_id)
		return
