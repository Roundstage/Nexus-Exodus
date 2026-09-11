// Native palette: controls and sprite slots are allocated once and updated in place.
var/list/nexus_build_thumb_cache = list()
var/list/nexus_build_control_icon_cache = list()
var/const/NEXUS_BUILD_SLOTS = 25
var/const/NEXUS_BUILD_STROKE_LIMIT = 128

proc/getBuildThumbnail(atom/blueprint, size = 32)
	if(!blueprint || !blueprint.icon) return null
	var/cache_key = "[blueprint.icon]|[blueprint.icon_state]|[blueprint.dir]|[size]"
	if(nexus_build_thumb_cache[cache_key]) return nexus_build_thumb_cache[cache_key]
	var/icon/thumb = icon(blueprint.icon,blueprint.icon_state,blueprint.dir)
	var/scale = min(1,size / max(1,thumb.Width(),thumb.Height()))
	if(scale < 1) thumb.Scale(max(1,round(thumb.Width()*scale)),max(1,round(thumb.Height()*scale)))
	nexus_build_thumb_cache[cache_key] = thumb
	return thumb

proc/getBuildControlIcon(width, height, role, selected, hovered)
	var/cache_key = "[width]x[height]|[role]|[selected]|[hovered]"
	if(nexus_build_control_icon_cache[cache_key]) return nexus_build_control_icon_cache[cache_key]
	var/fill_color = "#2b251d"
	var/border_color = "#514333"
	if(role == "background")
		fill_color = "#1c1914"
		border_color = "#8c7049"
	else if(role == "drag" || role == "status")
		fill_color = "#242019"
		border_color = fill_color
	else if(role == "page")
		fill_color = "#1c1914"
		border_color = fill_color
	else if(role == "select")
		fill_color = "#12110e"
		border_color = "#393128"
	else if(role == "category")
		fill_color = "#242019"
		border_color = fill_color
	if(selected)
		fill_color = "#493a25"
		border_color = "#d0ac70"
	else if(hovered)
		fill_color = "#393025"
		border_color = "#987a50"
	var/icon/control_icon = icon('src/Icons/Unsorted/UserNamesBarsUi.png')
	control_icon.Scale(width,height)
	control_icon.DrawBox(border_color,1,1,width,height)
	control_icon.DrawBox(fill_color,2,2,width-1,height-1)
	if(selected) control_icon.DrawBox(border_color,2,1,width-1,2)
	nexus_build_control_icon_cache[cache_key] = control_icon
	return control_icon

obj/NexusBuildDetailText
	parent_type = /obj/NexusHudBitmapText
	layer = 151
	mouse_opacity = 0

obj/NexusBuildControl
	parent_type = /obj/NexusHud
	mouse_opacity = 2
	layer = 150
	var/tmp
		datum/NexusBuildWindow/session
		action = ""
		atom/blueprint
		offset_x = 0
		offset_y = 0
		control_width = 32
		control_height = 32
		render_width = 32
		render_height = 32
		label_text = ""
		label_active = FALSE
		hovered = FALSE
		font_size = 12
		obj/NexusBuildDetailText/primary_text
		obj/NexusBuildDetailText/detail_text

	proc/setLabel(label, active_state = FALSE)
		label_text = label
		label_active = active_state
		if(!session || !session.canActivateControl(src)) hovered = FALSE
		var/scale = session ? session.panel_scale : 1
		render_width = max(1,round(control_width*scale))
		render_height = max(1,round(control_height*scale))
		icon = getBuildControlIcon(render_width,render_height,action,active_state,hovered)
		maptext_width = max(1,render_width - 8)
		font_size = action == "drag" ? 16 : 12
		if(scale < 0.9) font_size = 8
		maptext = null
		// These rectangles position glyph sprites; no client HTML layout is involved.
		maptext_height = max(1,render_height-4)
		maptext_x = 4
		maptext_y = 2
		if(action == "status")
			maptext_height = max(1,round((render_height-4)/2))
			maptext_y = render_height-maptext_height-2
		var/list/lines = splittext(label,"\n")
		var/centered = action in list("category","close","clear_search","edges","cliffs","size","rotate","stop","previous","next","page","new_custom","edit_custom","configure")
		if(label || primary_text)
			if(!primary_text)
				primary_text = new
				vis_contents += primary_text
			primary_text.pixel_x = maptext_x
			primary_text.pixel_y = maptext_y
			primary_text.maptext_width = maptext_width
			primary_text.maptext_height = maptext_height
			primary_text.setBitmapText(lines.len ? lines[1] : "",font_size,active_state ? "#ffe1a6" : "#eee3cf",centered ? "center" : "left",action != "status")
		if(action == "status")
			if(!detail_text)
				detail_text = new
				vis_contents += detail_text
			detail_text.pixel_x = maptext_x
			detail_text.pixel_y = 2
			detail_text.maptext_width = maptext_width
			detail_text.maptext_height = maptext_height
			detail_text.setBitmapText(lines.len > 1 ? lines[2] : "",8,"#bba88b")
		if(label) name = label

	Del()
		if(primary_text) del(primary_text)
		if(detail_text) del(detail_text)
		session = null
		. = ..()

	proc/updatePosition()
		// TOP already aligns the full icon height, unlike NORTH. Do not subtract it again.
		if(invisibility)
			screen_loc = null
			return
		if(session) screen_loc = "LEFT:[session.panel_x+round(offset_x*session.panel_scale)],TOP:-[session.panel_y+round(offset_y*session.panel_scale)]"

	proc/refreshThumbnail()
		overlays = null
		if(!blueprint) return
		var/icon/thumb = getBuildThumbnail(blueprint,max(1,min(32,render_width-8,render_height-6)))
		if(!thumb) return
		var/image/thumbnail = image(thumb)
		thumbnail.pixel_x = round((render_width-thumb.Width())/2)
		thumbnail.pixel_y = round((render_height-thumb.Height())/2)
		thumbnail.mouse_opacity = 0
		overlays += thumbnail

	Click(location, control, params)
		if(session && session.canUse()) session.handleControl(src,params)

	MouseEntered(location, control, params)
		if(session && session.canUse())
			hovered = session.canActivateControl(src)
			setLabel(label_text,label_active)
			if(blueprint) session.showHint(blueprint)

	MouseExited(location, control, params)
		hovered = FALSE
		setLabel(label_text,label_active)
		if(session && session.canUse() && blueprint) session.refreshStatus()

	MouseDown(location, control, params)
		if(action == "drag" && session && session.canUse()) session.beginPanelDrag(params)

	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		if(action == "drag" && session && session.canUse()) session.movePanel(params)

	MouseDrop(over_object, src_location, over_location, src_control, over_control, params)
		if(action == "drag" && session && session.canUse()) session.movePanel(params)

datum/NexusBuildWindow
	var/tmp
		active = FALSE
		list/controls = list()
		list/slots = list()
		list/category_controls = list()
		list/filtered_blueprints = list()
		list/footer_controls = list()
		obj/NexusBuildControl/background_control
		obj/NexusBuildControl/status_control
		obj/NexusBuildControl/page_control
		obj/NexusBuildControl/edges_control
		obj/NexusBuildControl/cliffs_control
		obj/NexusBuildControl/search_control
		obj/NexusBuildControl/size_control
		obj/NexusBuildControl/config_control
		obj/science_selection
		panel_x = 8
		panel_y = 56
		panel_width = 220
		panel_height = 448
		panel_scale = 1
		visible_rows = 5
		page_size = NEXUS_BUILD_SLOTS
		viewport_width = 1248
		viewport_height = 704
		viewport_watch_id = 0
		drag_start_x = 0
		drag_start_y = 0
		drag_mouse_x = 0
		drag_mouse_y = 0
		brush_size = 1
		brush_direction = SOUTH
		door_password = ""
		sign_text = ""
		prompt_open = FALSE

	Del()
		hide()
		for(var/obj/NexusBuildControl/control in controls) del(control)
		controls.Cut()
		if(owner && owner.client && owner.client.nexus_build_window == src) owner.client.nexus_build_window = null
		owner = null
		. = ..()

	proc/canUse()
		return active && owner && owner.client && owner.playerCharacter && usr == owner

	proc/toggle()
		if(active) hide()
		else show()

	proc/show()
		if(!owner || !owner.client || !owner.playerCharacter) return
		if(!controls.len) createControls()
		active = TRUE
		refreshViewport()
		owner.client.screen |= controls
		refreshCatalog()
		owner.MapFocus()
		watchViewport(++viewport_watch_id)

	proc/hide()
		active = FALSE
		viewport_watch_id++
		cancelStroke()
		for(var/obj/NexusBuildControl/control in controls)
			if(control.hovered) control.setLabel(control.label_text,control.label_active)
		if(owner)
			owner.build_brush = null
			if(owner.client) owner.client.screen -= controls

	proc/addControl(label, action_id, x, y, width, height)
		var/obj/NexusBuildControl/control = new
		control.session = src
		control.action = action_id
		control.offset_x = x
		control.offset_y = y
		control.control_width = width
		control.control_height = height
		control.setLabel(label)
		control.updatePosition()
		controls += control
		return control

	proc/createControls()
		background_control = addControl("","background",0,0,220,448)
		background_control.layer = 149
		var/obj/NexusBuildControl/title = addControl("BUILD CATALOG","drag",6,6,184,24)
		title.mouse_over_pointer = MOUSE_DRAG_POINTER
		addControl("X","close",194,6,20,24)
		var/index = 0
		for(var/category_name in list("Floors","Ground","Roofs","Walls","Decor","Trees","Other","Custom","Science"))
			var/obj/NexusBuildControl/control = addControl(category_name,"category",6+(index%3)*70,32+round(index/3)*20,68,18)
			category_controls[category_name] = control
			index++
		search_control = addControl("Search...","search",6,94,174,20)
		addControl("X","clear_search",184,94,30,20)
		edges_control = addControl("Edges OFF","edges",6,118,102,18)
		cliffs_control = addControl("Cliffs OFF","cliffs",112,118,102,18)
		size_control = addControl("Brush 1x1","size",6,140,82,18)
		addControl("Rotate","rotate",92,140,62,18)
		addControl("Stop","stop",158,140,56,18)
		for(var/slot_index = 0, slot_index < NEXUS_BUILD_SLOTS, slot_index++)
			var/obj/NexusBuildControl/slot = addControl("","select",6+(slot_index%5)*42,162+round(slot_index/5)*40,40,38)
			slots += slot
		footer_controls += addControl("<","previous",6,364,24,18)
		page_control = addControl("","page",34,364,152,18)
		footer_controls += page_control
		footer_controls += addControl(">","next",190,364,24,18)
		status_control = addControl("Select a blueprint","status",6,386,208,26)
		footer_controls += status_control
		footer_controls += addControl("New decor","new_custom",6,416,72,24)
		footer_controls += addControl("Edit","edit_custom",82,416,44,24)
		config_control = addControl("Configure","configure",130,416,84,24)
		footer_controls += config_control

	proc/fitToViewport(width, height)
		viewport_width = max(32,round(width))
		viewport_height = max(32,round(height))
		var/first_entry = (page-1)*page_size+1
		var/new_rows = Clamp(round((viewport_height-16-248)/40),1,5)
		var/new_scale = min(1,(viewport_width-16)/220,(viewport_height-16)/(248+new_rows*40))
		var/layout_changed = new_rows != visible_rows || new_scale != panel_scale
		if(layout_changed)
			for(var/obj/NexusBuildControl/control in footer_controls) control.offset_y += (new_rows-visible_rows)*40
			visible_rows = new_rows
			page_size = visible_rows*5
			page = round((first_entry-1)/page_size)+1
			panel_scale = new_scale
			background_control.control_height = 248+visible_rows*40
			for(var/obj/NexusBuildControl/control in controls)
				control.setLabel(control.label_text,control.label_active)
				if(control.action == "select") control.refreshThumbnail()
			for(var/index = 1, index <= slots.len, index++)
				var/obj/NexusBuildControl/slot = slots[index]
				slot.invisibility = index > page_size ? 101 : 0
				slot.mouse_opacity = index > page_size ? 0 : 2
		panel_width = round(220*panel_scale)
		panel_height = round((248+visible_rows*40)*panel_scale)
		clampPosition()
		if(layout_changed) refreshCatalog()

	proc/clampPosition()
		panel_x = Clamp(round(panel_x),8,max(8,viewport_width-panel_width-8))
		panel_y = Clamp(round(panel_y),8,max(8,viewport_height-panel_height-8))
		for(var/obj/NexusBuildControl/control in controls) control.updatePosition()

	proc/refreshViewport()
		if(!owner || !owner.client) return
		var/list/view_parts = splittext("[owner.client.view]","x")
		var/native_width = (view_parts.len == 2 ? text2num(view_parts[1]) : 2*owner.client.view+1)*world.icon_size
		var/native_height = (view_parts.len == 2 ? text2num(view_parts[2]) : 2*owner.client.view+1)*world.icon_size
		var/map_control = classic_ui ? "mapwindow.map" : "mainwindow.map"
		var/list/metrics = params2list(winget(owner,map_control,"size;view-size"))
		var/list/control_size = splittext("[metrics["size"]]","x")
		var/list/view_size = splittext("[metrics["view-size"]]","x")
		if(control_size.len == 2 && view_size.len == 2 && text2num(view_size[1]) > 0 && text2num(view_size[2]) > 0)
			native_width *= text2num(control_size[1])/text2num(view_size[1])
			native_height *= text2num(control_size[2])/text2num(view_size[2])
		if(native_width > 0 && native_height > 0) fitToViewport(native_width,native_height)

	proc/watchViewport(watch_id)
		set waitfor = FALSE
		while(active && owner && owner.client && watch_id == viewport_watch_id)
			sleep(10)
			if(!active || watch_id != viewport_watch_id) return
			refreshViewport()

	proc/refreshCatalog()
		filtered_blueprints = getBlueprints()
		page = Clamp(page,1,max(1,ceil(filtered_blueprints.len/page_size)))
		for(var/category_name in category_controls)
			var/obj/NexusBuildControl/control = category_controls[category_name]
			control.setLabel(category_name,category == category_name)
		for(var/index = 1, index <= slots.len, index++)
			var/obj/NexusBuildControl/slot = slots[index]
			var/entry_index = (page-1)*page_size+index
			var/atom/entry = index <= page_size && entry_index <= filtered_blueprints.len ? filtered_blueprints[entry_index] : null
			if(slot.blueprint != entry)
				slot.blueprint = entry
				slot.refreshThumbnail()
			slot.setLabel("",entry && entry == owner.build_brush)
			slot.name = entry ? getDisplayName(entry) : "Empty slot"
		if(page_control) page_control.setLabel("[page]/[max(1,ceil(filtered_blueprints.len/page_size))] - [filtered_blueprints.len] items")
		if(search_control) search_control.setLabel(search_query ? "Search: [search_query]" : "Search...")
		refreshStatus()

	proc/showHint(atom/blueprint)
		if(status_control && blueprint) status_control.setLabel("[getDisplayName(blueprint)]\nSelect to use this blueprint")

	proc/refreshStatus()
		if(!owner) return
		if(status_control)
			var/atom/brush = category == "Science" ? science_selection : owner.build_brush
			status_control.setLabel(brush ? "[getDisplayName(brush)]\nDrag to paint / Right-click cancels" : "Choose a blueprint\nClick and drag on the map to build")
			if(category == "Science") status_control.setLabel(brush ? "[getDisplayName(brush)]\nUse Craft item to manufacture." : "Select technology, then Craft item.")
		if(config_control) config_control.setLabel(category == "Science" ? "Craft item" : "Configure")
		if(edges_control) edges_control.setLabel("Edges: [owner.build_auto_edges ? "ON" : "OFF"]",owner.build_auto_edges)
		if(cliffs_control) cliffs_control.setLabel("Cliffs: [owner.build_auto_cliffs ? "ON" : "OFF"]",owner.build_auto_cliffs)
		if(size_control) size_control.setLabel("Brush: [brush_size]x[brush_size]")
		var/atom/selected = category == "Science" ? science_selection : owner.build_brush
		for(var/obj/NexusBuildControl/slot in slots) slot.setLabel("",slot.blueprint && slot.blueprint == selected)
		for(var/obj/NexusBuildControl/control in controls)
			if(control.hovered && !canActivateControl(control)) control.setLabel(control.label_text,control.label_active)

	proc/selectBlueprint(atom/blueprint)
		if(committing || !owner) return FALSE
		if(istype(blueprint,/obj/Build))
			if(!(blueprint in Builds)) return FALSE
		else if(istype(blueprint,/obj/CustomDecorBlueprint))
			if(!(blueprint in customDecors) || (blueprint:creator != owner.ckey && !owner.IsAdmin())) return FALSE
		else return FALSE
		cancelStroke()
		owner.build_brush = blueprint
		brush_direction = blueprint.dir
		refreshStatus()
		return TRUE

	proc/setCategory(category_name)
		if(!(category_name in list("Floors","Ground","Roofs","Walls","Decor","Trees","Other","Custom","Science"))) return
		cancelStroke()
		category = category_name
		search_query = ""
		page = 1
		if(category == "Science") owner.syncTechnologyProgression(silent = TRUE)
		refreshCatalog()

	proc/handleControl(obj/NexusBuildControl/control,params)
		if(!canActivateControl(control)) return
		switch(control.action)
			if("category") setCategory(control.name)
			if("select")
				if(category == "Science")
					if(control.blueprint && (control.blueprint in getScienceBlueprints())) science_selection = control.blueprint
				else selectBlueprint(control.blueprint)
			if("close") hide()
			if("stop")
				cancelStroke()
				owner.build_brush = null
				science_selection = null
			if("edges") owner.build_auto_edges = !owner.build_auto_edges
			if("cliffs") owner.build_auto_cliffs = !owner.build_auto_cliffs
			if("size")
				cancelStroke()
				brush_size = brush_size == 1 ? 3 : (brush_size == 3 ? 5 : 1)
			if("rotate")
				cancelStroke()
				if(!istype(owner.build_brush,/obj/Build) || !ispath(owner.build_brush:Creates,/turf)) brush_direction = turn(brush_direction,90)
			if("previous","next")
				page += control.action == "next" ? 1 : -1
				refreshCatalog()
			if("search")
				cancelStroke()
				prompt_open = TRUE
				var/query = input(owner,"Search blueprints in this category","Build search",search_query) as text|null
				prompt_open = FALSE
				if(!active) return
				if(!isnull(query)) search_query = copytext(query,1,61)
				page = 1
				refreshCatalog()
			if("clear_search")
				search_query = ""
				page = 1
				refreshCatalog()
			if("new_custom")
				owner.TryNewCustomDecorBlueprint()
				setCategory("Custom")
			if("edit_custom")
				if(istype(owner.build_brush,/obj/CustomDecorBlueprint)) owner.CustomizeDecor(owner.build_brush)
				refreshCatalog()
			if("configure")
				cancelStroke()
				if(category == "Science")
					if(science_selection && (science_selection in getScienceBlueprints())) owner.TryCreateScienceItem(science_selection)
					refreshStatus()
					return
				prompt_open = TRUE
				door_password = input(owner,"Password for painted doors (blank for none)","Build settings",door_password) as text
				sign_text = input(owner,"Text for painted signs","Build settings",sign_text) as text
				prompt_open = FALSE
		refreshStatus()

	proc/canActivateControl(obj/NexusBuildControl/control)
		if(!control || control.session != src || !active || committing || prompt_open || control.invisibility) return FALSE
		switch(control.action)
			if("background","drag","status","page") return FALSE
			if("select") return !!control.blueprint
			if("previous") return page > 1
			if("next") return page*page_size < filtered_blueprints.len
			if("clear_search") return !!search_query
			if("stop") return owner && (owner.build_brush || science_selection)
			if("edit_custom") return owner && istype(owner.build_brush,/obj/CustomDecorBlueprint)
			if("rotate") return owner && owner.build_brush && (!istype(owner.build_brush,/obj/Build) || !ispath(owner.build_brush:Creates,/turf))
			if("configure") return category != "Science" || !!science_selection
		return control.action in list("category","close","edges","cliffs","size","search","new_custom")

	proc/beginPanelDrag(params)
		cancelStroke()
		var/list/mouse_params = params2list(params)
		var/list/pixels = screenLocationPixels(mouse_params["screen-loc"])
		if(!pixels) return
		drag_start_x = panel_x
		drag_start_y = panel_y
		drag_mouse_x = pixels[1]
		drag_mouse_y = pixels[2]

	proc/movePanel(params)
		var/list/mouse_params = params2list(params)
		var/list/pixels = screenLocationPixels(mouse_params["screen-loc"])
		if(!pixels) return
		panel_x = max(0,drag_start_x+pixels[1]-drag_mouse_x)
		panel_y = max(0,drag_start_y-pixels[2]+drag_mouse_y)
		clampPosition()
