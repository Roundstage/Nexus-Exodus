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

proc/getNexusServerSettingNameDisplay(setting_name)
	if(isnull(setting_name)) return "(unnamed setting)"
	var/name_text = "[setting_name]"
	if(!length(name_text)) return "(unnamed setting)"
	return html_encode(name_text)

datum/NexusServerPanel
	parent_type = /datum/NexusHudWindow
	var/tmp/category = "Progression"
	var/tmp/search_query = ""
	var/tmp/page = 1
	var/tmp/page_size = 14
	var/tmp/list/visible_setting_names = list()

	Del()
		if(owner) owner << browse(null, "window=nexus_server_panel")
		. = ..()

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
		var/source_ref = "\ref[src]"
		var/html = {"
		<!doctype html><html><head><meta charset='UTF-8'><style>
		*{box-sizing:border-box;border-radius:0}html,body{margin:0;min-height:100%;background:#080d14;color:#edf3fa;font-family:'Courier New',monospace;font-size:15px}body{padding:18px}.panel{max-width:1100px;min-height:680px;margin:auto;border:2px solid #587087;background:#0d151e;box-shadow:inset 0 0 0 2px #263b4d;padding:14px}.header{display:flex;align-items:center;justify-content:space-between;background:#101c28;border:1px solid #395168;padding:12px 14px;color:#72c6eb;font-size:21px;font-weight:bold}.close,.tab,.pager,.setting{color:inherit;text-decoration:none}.close{padding:8px 18px;background:#241718;border:1px solid #7e4646;color:#ffd8d4;font-size:13px}.tabs{display:grid;grid-template-columns:repeat(6,1fr);gap:7px;margin:14px 0}.tab{padding:10px 6px;text-align:center;background:#101923;border:1px solid #40556b;color:#9fb1c3;font-weight:bold}.tab.active{background:#193044;border-color:#74c8ec;color:#fff;box-shadow:inset 4px 0 #74c8ec}.search{display:flex;gap:8px;margin-bottom:14px}.search input{flex:1;min-width:0;padding:12px;background:#080d14;border:2px inset #405a70;color:#edf3fa;font:16px 'Courier New',monospace}.search button{width:130px;background:#193044;border:1px solid #74c8ec;color:#fff;font-weight:bold}.table{border:1px solid #405a70}.row{display:grid;grid-template-columns:minmax(0,2fr) minmax(220px,1fr);min-height:34px}.row>*{padding:8px 12px;border-bottom:1px solid #304456;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.row>*+*{border-left:1px solid #304456}.labels{background:#172330;color:#72c6eb;font-size:12px;font-weight:bold}.setting:hover>*{background:#193044;color:#fff}.empty{padding:24px;text-align:center;color:#bbaeb0}.footer{display:grid;grid-template-columns:150px 1fr 150px;gap:10px;margin-top:14px}.pager,.page-info{padding:10px;text-align:center;border:1px solid #40556b;background:#101923}.page-info{color:#9fb5c8}.disabled{color:#607080;pointer-events:none}@media(max-width:760px){.tabs{grid-template-columns:repeat(3,1fr)}body{padding:8px}.panel{min-height:0}.footer{grid-template-columns:100px 1fr 100px}}
		</style></head><body><main class='panel'><header class='header'><span>SERVER CONTROL PANEL</span><a class='close' href='byond://?src=[source_ref]&action=close'>CLOSE</a></header><nav class='tabs'>"}
		var/list/categories = getNexusServerSettingCategories()
		var/category_index = 0
		for(var/category_name in categories)
			category_index++
			var/is_active = category_name == category
			html += "<a class='tab[is_active ? " active" : ""]' href='byond://?src=[source_ref]&action=category:[category_index]'>[uppertext(category_name)]</a>"
		html += "</nav><form class='search' action='byond://' method='get'><input type='hidden' name='src' value='[source_ref]'><input type='hidden' name='action' value='search'><input type='search' name='query' value='[html_encode(search_query)]' placeholder='Search names or values in [html_encode(category)]...' autofocus><button type='submit'>SEARCH</button></form><section class='table'><div class='row labels'><span>VARIABLE</span><span>CURRENT VALUE</span></div>"
		var/start_index = (page - 1) * page_size + 1
		var/end_index = min(visible_setting_names.len, start_index + page_size - 1)
		if(!visible_setting_names.len)
			html += "<div class='empty'>NO SETTINGS MATCH THIS FILTER</div>"
		else
			for(var/index = start_index, index <= end_index, index++)
				var/setting_name = visible_setting_names[index]
				var/current_value = getNexusServerSettingDisplay(current_settings[setting_name])
				html += "<a class='setting row' href='byond://?src=[source_ref]&action=setting:[index]'><span>[getNexusServerSettingNameDisplay(setting_name)]</span><span>[html_encode(current_value)]</span></a>"
		html += "</section><footer class='footer'><a class='pager[page > 1 ? "" : " disabled"]' href='byond://?src=[source_ref]&action=previous'>PREVIOUS</a><div class='page-info'>PAGE [page] / [max_page] &nbsp;-&nbsp; [visible_setting_names.len] SETTINGS</div><a class='pager[page < max_page ? "" : " disabled"]' href='byond://?src=[source_ref]&action=next'>NEXT</a></footer></main></body></html>"
		owner << browse(html, "window=nexus_server_panel;size=1000x760;can_resize=1")

	Topic(href, list/href_list)
		if(!canInteract() || owner.AdminLevel() < 4) return
		var/action_id = href_list["action"]
		if(action_id == "search")
			search_query = href_list["query"] || ""
			page = 1
			render()
			return
		handleAction(action_id)

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
