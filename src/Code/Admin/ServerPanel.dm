proc/getNexusServerSettingCategories()
	return list(
		"Progression" = /upForm/admin_gains,
		"World" = /upForm/admin_world,
		"Battlegrounds" = /upForm/admin_battlegrounds,
		"Races" = /upForm/admin_races,
		"Combat" = /upForm/admin_combat,
		"Science" = /upForm/admin_science)

proc/getNexusServerSettingDisplay(value)
	if(islist(value))
		var/list/list_value = value
		return "[list_value.len] entries"
	if(isnull(value)) return "null"
	var/value_text = "[value]"
	if(length(value_text) > 42) value_text = "[copytext(value_text, 1, 40)]..."
	return value_text

datum/NexusServerPanel
	parent_type = /datum/NexusHudWindow
	var/tmp/category = "Progression"
	var/tmp/search_query = ""
	var/tmp/page = 1
	var/tmp/page_size = 9
	var/tmp/list/visible_setting_names = list()

	proc/createSettingsModel(category_name = category)
		var/list/categories = getNexusServerSettingCategories()
		var/form_path = categories[category_name]
		if(!ispath(form_path, /upForm)) return
		return new form_path(owner.client, owner, list(), TRUE)

	proc/getCurrentSettings()
		var/upForm/settings_model = createSettingsModel()
		if(!settings_model || !islist(settings_model.form_vars) || !islist(settings_model.form_vars["admin"]))
			if(settings_model) del(settings_model)
			return list()
		var/list/current_settings = settings_model.form_vars["admin"].Copy()
		del(settings_model)
		return current_settings

	proc/refreshVisibleSettings(list/current_settings)
		visible_setting_names = list()
		var/query = lowertext(search_query)
		for(var/setting_name in current_settings)
			var/search_text = lowertext("[setting_name] [getNexusServerSettingDisplay(current_settings[setting_name])]")
			if(query && !findtext(search_text, query)) continue
			visible_setting_names += setting_name
		var/max_page = max(1, round((visible_setting_names.len + page_size - 1) / page_size))
		page = Clamp(page, 1, max_page)

	proc/render()
		if(!owner || !owner.client || owner.AdminLevel() < 4)
			del(src)
			return
		clearElements()
		var/list/current_settings = getCurrentSettings()
		refreshVisibleSettings(current_settings)
		var/max_page = max(1, round((visible_setting_names.len + page_size - 1) / page_size))

		addElement("", null, 12, 12, 620, 430, "#080d14", "#587087", "", "#ffffff", "left", 9, FALSE)
		addElement("SERVER CONTROL PANEL", null, 24, 22, 430, 30, "#101c28", "#395168", "#72c6eb", "#f2f7fb", "left", 13, FALSE)
		addElement("CLOSE", "close", 528, 22, 92, 30, "#241718", "#7e4646", "#e26767", "#ffd8d4", "center", 9)

		var/list/categories = getNexusServerSettingCategories()
		var/category_index = 0
		for(var/category_name in categories)
			category_index++
			var/is_active = category_name == category
			var/button_x = 24 + (category_index - 1) * 98
			addElement(uppertext(category_name), "category:[category_index]", button_x, 60, 92, 25, is_active ? "#193044" : "#101923", is_active ? "#74c8ec" : "#364a5c", is_active ? "#74c8ec" : "", is_active ? "#ffffff" : "#9fb1c3", "center", 8)

		var/search_label = search_query ? "FILTER: [html_encode(search_query)]" : "SEARCH ALL SETTINGS IN [uppertext(category)]"
		addElement(search_label, "search", 24, 93, 596, 27, "#0d1721", "#405a70", "#72c6eb", "#bcd2e3", "left", 9)

		var/start_index = (page - 1) * page_size + 1
		var/end_index = min(visible_setting_names.len, start_index + page_size - 1)
		var/row_number = 0
		if(!visible_setting_names.len)
			addElement("NO SETTINGS MATCH THIS FILTER", null, 24, 130, 596, 28, "#15191e", "#493f41", "#8e6262", "#bbaeb0", "center", 9, FALSE)
		else
			for(var/index = start_index, index <= end_index, index++)
				row_number++
				var/setting_name = visible_setting_names[index]
				var/current_value = getNexusServerSettingDisplay(current_settings[setting_name])
				var/row_label = "[setting_name]   =   [html_encode(current_value)]"
				addElement(row_label, "setting:[index]", 24, 126 + (row_number - 1) * 28, 596, 23, row_number % 2 ? "#101923" : "#0d151e", "#304456", "#4e829d", "#e6eef5", "left", 9)

		addElement("PREVIOUS", "previous", 24, 390, 104, 28, "#101923", "#40556b", "", page > 1 ? "#edf3fa" : "#607080", "center", 8)
		addElement("PAGE [page] / [max_page]   -   [visible_setting_names.len] SETTINGS", null, 136, 390, 372, 28, "#0d151e", "#304456", "", "#9fb5c8", "center", 8, FALSE)
		addElement("NEXT", "next", 516, 390, 104, 28, "#101923", "#40556b", "", page < max_page ? "#edf3fa" : "#607080", "center", 8)

	proc/editListSetting(setting_name, list/current_list)
		var/choice = alert(owner, "[setting_name] contains [current_list.len] entries.", "Server Setting", "Add", "Remove", "Cancel")
		if(choice == "Add")
			var/new_entry = input(owner, "Enter the new list entry.", setting_name) as null|text
			if(isnull(new_entry) || !length(new_entry)) return FALSE
			current_list += new_entry
			owner.admin_blame(owner, "[owner.key] added '[new_entry]' to server setting [setting_name] through the HUD Server Panel.")
			return TRUE
		if(choice == "Remove")
			if(!current_list.len) return FALSE
			var/entry = input(owner, "Choose the entry to remove.", setting_name) as null|anything in current_list
			if(isnull(entry)) return FALSE
			current_list -= entry
			owner.admin_blame(owner, "[owner.key] removed '[entry]' from server setting [setting_name] through the HUD Server Panel.")
			return TRUE
		return FALSE

	proc/editSetting(setting_name)
		var/upForm/settings_model = createSettingsModel()
		if(!settings_model || !settings_model.isValidFormVar("admin", setting_name))
			if(settings_model) del(settings_model)
			return
		var/current_value = settings_model.getFormVar("admin", setting_name)
		if(islist(current_value))
			editListSetting(setting_name, current_value)
			del(settings_model)
			return
		var/new_value
		if(isnum(current_value))
			new_value = input(owner, "Set [setting_name]. Current value: [current_value]", "Server Control Panel", current_value) as null|num
		else
			new_value = input(owner, "Set [setting_name]. Current value: [current_value]", "Server Control Panel", current_value) as null|text
		if(isnull(new_value))
			del(settings_model)
			return
		var/error_message = settings_model.ProcessVariable("admin", setting_name, "[new_value]", owner.client)
		if(error_message)
			owner << "Unable to change [setting_name]: [error_message]"
			del(settings_model)
			return
		var/old_display = getNexusServerSettingDisplay(current_value)
		settings_model.FormSetTempVars("admin")
		owner.admin_blame(owner, "[owner.key] changed server setting [setting_name] from '[old_display]' to '[new_value]' through the HUD Server Panel.")
		del(settings_model)

	handleAction(action_id)
		if(!canInteract() || owner.AdminLevel() < 4) return
		if(action_id == "close")
			del(src)
			return
		if(action_id == "search")
			var/new_query = input(owner, "Search setting names or current values in [category]. Leave blank to clear.", "Server Control Panel", search_query) as null|text
			if(!isnull(new_query))
				search_query = new_query
				page = 1
			render()
			return
		if(action_id == "previous") page--
		else if(action_id == "next") page++
		else if(findtext(action_id, "category:") == 1)
			var/category_number = text2num(copytext(action_id, 10))
			var/list/categories = getNexusServerSettingCategories()
			if(category_number >= 1 && category_number <= categories.len)
				category = categories[category_number]
				search_query = ""
				page = 1
		else if(findtext(action_id, "setting:") == 1)
			var/setting_number = text2num(copytext(action_id, 9))
			var/list/current_settings = getCurrentSettings()
			refreshVisibleSettings(current_settings)
			if(setting_number >= 1 && setting_number <= visible_setting_names.len)
				var/setting_name = visible_setting_names[setting_number]
				if(setting_name in current_settings) editSetting(setting_name)
		render()

mob/proc/showNexusServerPanel()
	if(!client || AdminLevel() < 4) return
	if(client.nexus_hud_window) del(client.nexus_hud_window)
	client.nexus_hud_window = new /datum/NexusServerPanel(src)
	var/datum/NexusServerPanel/server_panel = client.nexus_hud_window
	server_panel.render()
	admin_blame(src, "[key] opened the HUD Server Control Panel.")
