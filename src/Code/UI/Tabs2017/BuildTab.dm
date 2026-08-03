turf/var
	build_category = BUILD_UNDEFINED

obj/var
	build_category = BUILD_UNDEFINED

#define NEXUS_BUILD_PAGE_SIZE 48

var/list/nexus_build_browser_icon_cache = list()

client/var/tmp
	datum/NexusBuildWindow/nexus_build_window
	list/nexus_build_icon_resources = list()

mob/verb
	MapFocus()
		set hidden = 1
		if(!client) return
		if(!classic_ui) winset(src,"mainwindow.map","focus=true")
		else winset(src,"mapwindow.map","focus=true")

mob/proc
	ToggleBuildMenu()
		if(!client) return
		winset(src, "TabHolder", "is-visible=false")
		if(client.nexus_build_window)
			client.nexus_build_window.show()
			return
		client.nexus_build_window = new /datum/NexusBuildWindow(src)
		client.nexus_build_window.show()

	PopulateBuildTabs()
		set waitfor = 0
		if(!client) return

		winset(src, "TabHolder.tab1", "tabs=TabScience,TabBuildFloors,TabBuildGround,TabBuildRoofs,TabBuildWalls,TabBuildDecor,TabBuildTrees,TabBuildOther,TabBuildCustom")

		PopulateBuildTab(win = "TabBuildOther", cat = BUILD_UNDEFINED)
		PopulateBuildTab(win = "TabBuildFloors", cat = BUILD_FLOOR)
		PopulateBuildTab(win = "TabBuildGround", cat = BUILD_GROUND)
		PopulateBuildTab(win = "TabBuildRoofs", cat = BUILD_ROOF)
		PopulateBuildTab(win = "TabBuildWalls", cat = BUILD_WALL)
		PopulateBuildTab(win = "TabBuildDecor", cat = BUILD_DECOR)
		PopulateBuildTab(win = "TabBuildTrees", cat = BUILD_TREES)
		PopulateBuildTab(win = "TabScience")
		PopulateBuildTab(win = "TabBuildCustom", cat = BUILD_CUSTOM)

	PopulateBuildTab(win = "TabBuildFloors", cat = BUILD_UNDEFINED)
		set waitfor = 0
		winset(src, "[win].grid1", "is-list=true")
		winset(src, "[win].grid1", "cells=0") //clears grid
		var/added = 0
		if(win == "TabScience")
			syncTechnologyProgression(silent = TRUE)
			global_science_items = list()
			if(islist(GLOBAL_SCIENCE_TAB_ITEMS))
				for(var/obj/item in GLOBAL_SCIENCE_TAB_ITEMS)
					if(!(item in global_science_items)) global_science_items += item
			for(var/obj/item in tech_list)
				if(canAccessTechnology(item) && !(item in global_science_items)) global_science_items += item
			for(var/obj/item in individual_science_items)
				if(!(item in global_science_items)) global_science_items += item

			for(var/obj/o in global_science_items)
				if(!(o.type in Illegal_Science))
					added++
					winset(src, "[win].grid1", "current-cell=[added]")
					src << output(o, "[win].grid1")

		else if(win == "TabBuildCustom")
			var/isAdmin = IsAdmin()
			CheckAddNewButtonForCustomDecors()
			added++
			winset(src, "[win].grid1", "current-cell=[added]")
			src << output(addNewButton, "[win].grid1")
			for(var/obj/CustomDecorBlueprint/o in customDecors)
				if(o.creator != ckey) continue
				added++
				winset(src, "[win].grid1", "current-cell=[added]")
				src << output(o, "[win].grid1")
			//now we load in the ones that arent ours if we are admin
			if(isAdmin)
				for(var/obj/CustomDecorBlueprint/o in customDecors)
					if(o.creator == ckey) continue
					added++
					winset(src, "[win].grid1", "current-cell=[added]")
					src << output(o, "[win].grid1")
					sleep(3) //i find that i crash if it tries to load too many at once
		else
			for(var/obj/Build/b in getBuildCatalogForCategory(cat))
				added++
				winset(src, "[win].grid1", "current-cell=[added]")
				src << output(b, "[win].grid1")
		winset(src, "[win].grid1", "cells=[added]")

datum/NexusBuildWindow
	var/tmp
		mob/owner
		category = "Floors"
		search_query = ""
		page = 1

	New(mob/new_owner)
		. = ..()
		owner = new_owner

	Del()
		if(owner && owner.client)
			owner << browse(null, "window=NexusBuildBrowser")
			if(owner.client.nexus_build_window == src) owner.client.nexus_build_window = null
		owner = null
		. = ..()

	proc/canUse()
		return owner && owner.client && owner.playerCharacter && usr == owner

	proc/getCategoryId(category_name = null)
		if(!category_name) category_name = category
		switch(category_name)
			if("Floors") return BUILD_FLOOR
			if("Ground") return BUILD_GROUND
			if("Roofs") return BUILD_ROOF
			if("Walls") return BUILD_WALL
			if("Decor") return BUILD_DECOR
			if("Trees") return BUILD_TREES
			if("Other") return BUILD_UNDEFINED
		return null

	proc/getScienceBlueprints()
		var/list/results = list()
		if(islist(GLOBAL_SCIENCE_TAB_ITEMS))
			for(var/obj/item in GLOBAL_SCIENCE_TAB_ITEMS)
				if(!(item.type in Illegal_Science) && !(item in results)) results += item
		for(var/obj/item in tech_list)
			if(owner.canAccessTechnology(item) && !(item.type in Illegal_Science) && !(item in results)) results += item
		for(var/obj/item in owner.individual_science_items)
			if(!(item.type in Illegal_Science) && !(item in results)) results += item
		return results

	proc/getBlueprints(apply_search = TRUE)
		var/list/results = list()
		if(category == "Science")
			results = getScienceBlueprints()
		else if(category == "Custom")
			for(var/obj/CustomDecorBlueprint/blueprint in customDecors)
				if(blueprint.creator == owner.ckey || owner.IsAdmin()) results += blueprint
		else
			var/category_id = getCategoryId()
			for(var/obj/Build/blueprint in Builds)
				if(blueprint.build_category == category_id) results += blueprint
		if(!apply_search || !search_query) return results
		var/list/filtered = list()
		var/needle = lowertext(search_query)
		for(var/atom/blueprint in results)
			var/extra_text = ""
			if(istype(blueprint, /obj/Build))
				var/obj/Build/build = blueprint
				extra_text = "[build.Creates]"
			else if(category == "Science")
				extra_text = "[blueprint:science_path] [blueprint:science_level]"
			if(findtext(lowertext("[blueprint.name] [blueprint.desc] [extra_text]"), needle)) filtered += blueprint
		return filtered

	proc/buildIcon(atom/subject)
		if(!subject || !subject.icon) return "<span class='fallback'>?</span>"
		var/icon_key = "\ref[subject]|[subject.icon]|[subject.icon_state]"
		var/resource_name = "build_[md5(icon_key)].png"
		if(!islist(owner.client.nexus_build_icon_resources)) owner.client.nexus_build_icon_resources = list()
		if(!owner.client.nexus_build_icon_resources[resource_name])
			var/icon/preview = nexus_build_browser_icon_cache[icon_key]
			if(!preview)
				preview = icon(subject.icon, subject.icon_state)
				nexus_build_browser_icon_cache[icon_key] = preview
			owner << browse_rsc(preview, resource_name)
			owner.client.nexus_build_icon_resources[resource_name] = TRUE
		return "<img src='[resource_name]' alt=''>"

	proc/getDisplayName(atom/subject)
		var/display_name = "[subject.name]"
		if(istype(subject, /obj/Build) && copytext(display_name, -2) == "-B") display_name = copytext(display_name, 1, -2)
		return display_name

	proc/buildBlueprintCard(atom/subject)
		var/display_name = getDisplayName(subject)
		var/description = subject.desc ? "[subject.desc]" : "Select this blueprint for placement."
		var/action
		var/meta
		var/action_label
		var/secondary_actions = ""
		if(istype(subject, /obj/Build))
			var/obj/Build/build = subject
			action = "select_build"
			action_label = "SELECT"
			meta = "PLACE TILE &middot; [Commas(owner.turfLayCost())] RES &middot; [html_encode("[build.Creates]")]"
		else if(istype(subject, /obj/CustomDecorBlueprint))
			var/obj/CustomDecorBlueprint/custom = subject
			action = "select_custom"
			action_label = "PLACE"
			meta = "CUSTOM &middot; [Commas(customDecorBuildCost)] RES &middot; BY [html_encode(custom.creator)]"
			if(custom.creator == owner.ckey)
				secondary_actions = "<a href='byond://?src=\ref[src]&action=customize&ref=\ref[custom]'>EDIT</a><a class='danger' href='byond://?src=\ref[src]&action=delete_custom&ref=\ref[custom]'>DELETE</a>"
		else
			action = "craft"
			action_label = "CRAFT"
			meta = "SCIENCE &middot; [Commas(Item_cost(owner, subject))] RES &middot; TECH [subject:science_level][subject:science_path ? " / [html_encode(subject:science_path)]" : ""]"
		return "<article class='blueprint'><div class='preview'>[buildIcon(subject)]</div><div class='copy'><span>[meta]</span><b>[html_encode(display_name)]</b><small>[html_encode(description)]</small></div><div class='actions'><a href='byond://?src=\ref[src]&action=[action]&ref=\ref[subject]'>[action_label]</a>[secondary_actions]</div></article>"

	proc/buildNavigation()
		var/html = ""
		for(var/category_name in list("Floors", "Ground", "Roofs", "Walls", "Decor", "Trees", "Other", "Custom", "Science"))
			var/state = category_name == category ? "active" : ""
			html += "<a class='tab [state]' href='byond://?src=\ref[src]&action=category&id=[category_name]'>[uppertext(category_name)]</a>"
		return html

	proc/buildCatalog()
		var/list/blueprints = getBlueprints()
		var/page_count = blueprints.len ? 1 + floor((blueprints.len - 1) / NEXUS_BUILD_PAGE_SIZE) : 1
		page = Clamp(page, 1, page_count)
		var/start_index = (page - 1) * NEXUS_BUILD_PAGE_SIZE + 1
		var/end_index = min(blueprints.len, start_index + NEXUS_BUILD_PAGE_SIZE - 1)
		var/cards = ""
		if(category == "Custom" && !search_query)
			cards += "<article class='blueprint create'><div class='preview'><span class='fallback'>+</span></div><div class='copy'><span>CUSTOM BLUEPRINT</span><b>Create New Decor</b><small>Import an icon and configure a reusable roleplay decoration. [owner.MyDecorCount()]/[myDecorLimit] slots used.</small></div><div class='actions'><a href='byond://?src=\ref[src]&action=new_custom'>CREATE</a></div></article>"
		for(var/index = start_index, index <= end_index, index++) cards += buildBlueprintCard(blueprints[index])
		if(!cards) cards = "<div class='empty'>No blueprints matched this category or search.</div>"
		var/pagination = "<span>PAGE [page] / [page_count]</span>"
		if(page > 1) pagination = "<a href='byond://?src=\ref[src]&action=page&id=[page - 1]'>PREVIOUS</a>[pagination]"
		if(page < page_count) pagination += "<a href='byond://?src=\ref[src]&action=page&id=[page + 1]'>NEXT</a>"
		return "<div class='catalog-meta'><span>[blueprints.len] BLUEPRINT[blueprints.len == 1 ? "" : "S"]</span><div class='pagination'>[pagination]</div></div><section class='catalog'>[cards]</section>"

	proc/buildHtml()
		var/obj/Resources/resources = owner.GetResourceObject()
		var/resource_total = resources ? resources.Value : 0
		var/search_clear = search_query ? "<a class='clear' href='byond://?src=\ref[src]&action=search&q='>CLEAR</a>" : ""
		var/selection = istype(owner.Target, /obj/Build) ? "<a class='selection' href='byond://?src=\ref[src]&action=clear_selection'>SELECTED: [html_encode(getDisplayName(owner.Target))] &middot; CLEAR</a>" : "<span class='selection'>NO ACTIVE BLUEPRINT</span>"
		return {"<!doctype html><html><head><meta charset='utf-8'><title>Build Catalog</title><style>[getNexusRpgBrowserCss()]
		*{box-sizing:border-box}html,body{margin:0;min-height:100%;background:#100d0a;color:#ead9b6;font:12px 'Courier New',monospace}.shell{min-height:100vh}.header{position:sticky;top:0;z-index:10;padding:14px 16px;border-bottom:2px solid #80613b;background:#211a13}.top{display:flex;align-items:center;gap:10px}.title{margin-right:auto}.title b{display:block;color:#f1d49a;font:22px Georgia,serif;letter-spacing:1px}.title small{display:block;margin-top:3px}.resource{padding:8px 11px;border:2px inset #9a7440;background:#17110c;color:#ffe3a7;font-weight:bold}.selection{padding:8px 11px;border:1px solid #5e7147;background:#182013;color:#afd184;text-decoration:none}.close{padding:8px 11px;text-decoration:none}.tabs{display:flex;gap:5px;margin-top:12px;overflow-x:auto;padding-bottom:3px}.tab{flex:0 0 auto;padding:7px 10px;text-decoration:none}.tools{display:flex;gap:6px;margin-top:9px}.tools input{flex:1;min-width:240px;padding:8px 10px}.tools button,.tools .clear{padding:8px 12px;text-decoration:none}.catalog-meta{display:flex;align-items:center;justify-content:space-between;padding:12px 18px 0;color:#bda578;font-weight:bold}.pagination{display:flex;align-items:center;gap:7px}.pagination a{padding:5px 8px;border:1px solid #775b35;background:#342719;color:#e7c98f;text-decoration:none}.catalog{display:grid;grid-template-columns:repeat(auto-fill,minmax(270px,1fr));gap:10px;padding:12px 18px 24px}.blueprint{display:grid;grid-template-columns:64px 1fr;grid-template-rows:1fr auto;gap:8px 10px;min-height:126px;padding:10px;border:2px solid #715735;background:#2b2117;outline:1px solid #120d08}.blueprint:hover{border-color:#c09252;background:#35281a}.preview{grid-row:1/3;display:flex;align-items:center;justify-content:center;width:64px;height:64px;border:2px inset #715735;background:#120f0c;overflow:hidden}.preview img{max-width:60px;max-height:60px}.fallback{color:#e9c678;font:bold 30px Georgia,serif}.copy{min-width:0}.copy span,.copy b,.copy small{display:block}.copy span{color:#9f865e;font-size:9px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.copy b{margin-top:5px;color:#f0d497;font-size:14px}.copy small{margin-top:6px;max-height:34px;overflow:hidden;color:#bca47c;line-height:1.35}.actions{grid-column:2;display:flex;gap:5px}.actions a{padding:6px 9px;border:2px outset #9a7440;background:#49351f;color:#f2d79e;text-decoration:none;font-weight:bold}.actions .danger{border-color:#8e4c43;background:#48241e;color:#f0afa2}.blueprint.create{border-style:dashed}.empty{grid-column:1/-1;padding:70px;text-align:center;color:#9d8764}@media(max-width:760px){.selection{display:none}.catalog{grid-template-columns:1fr}.title small{display:none}}
		</style><script>function runBuildSearch(){var q=document.getElementById('build-search').value||'';window.location.href='byond://?src=\ref[src]&action=search&q='+encodeURIComponent(q);return false;}</script></head><body><div class='shell'><header class='header'><div class='top'><div class='title'><b>BUILD CATALOG / [uppertext(category)]</b><small>Search, preview and select without loading every blueprint at once</small></div>[selection]<span class='resource'>[Commas(resource_total)] RES</span><a class='close' href='byond://?src=\ref[src]&action=close'>CLOSE</a></div><nav class='tabs'>[buildNavigation()]</nav><form class='tools' onsubmit='return runBuildSearch()'><input id='build-search' maxlength='60' value='[html_encode(search_query)]' placeholder='Search this category...'><button type='submit'>SEARCH</button>[search_clear]</form></header>[buildCatalog()]</div></body></html>"}

	proc/show()
		if(!owner || !owner.client || !owner.playerCharacter)
			del(src)
			return
		owner << browse(buildHtml(), "window=NexusBuildBrowser;size=1120x760;can_resize=true;can_close=true")

	Topic(href, list/href_list)
		if(!canUse()) return
		switch(href_list["action"])
			if("category")
				if(href_list["id"] in list("Floors", "Ground", "Roofs", "Walls", "Decor", "Trees", "Other", "Custom", "Science"))
					category = href_list["id"]
					search_query = ""
					page = 1
					if(category == "Science") owner.syncTechnologyProgression(silent = TRUE)
			if("search")
				var/new_query = href_list["q"]
				search_query = copytext("[new_query]", 1, 61)
				page = 1
			if("page") page = max(1, text2num(href_list["id"]))
			if("clear_selection") owner.stopBuildingThings()
			if("select_build")
				var/obj/Build/build = locate(href_list["ref"])
				if(build && (build in Builds) && owner.selectBuildBlueprint(build))
					del(src)
					return
			if("craft")
				var/obj/technology = locate(href_list["ref"])
				if(technology && (technology in getScienceBlueprints())) owner.TryCreateScienceItem(technology)
			if("select_custom")
				var/obj/CustomDecorBlueprint/custom = locate(href_list["ref"])
				if(custom && (custom in getBlueprints(FALSE)))
					owner.TryBuildCustomDecor(custom)
					del(src)
					return
			if("new_custom") owner.TryNewCustomDecorBlueprint()
			if("customize")
				var/obj/CustomDecorBlueprint/custom = locate(href_list["ref"])
				if(custom && custom.creator == owner.ckey) owner.CustomizeDecor(custom)
			if("delete_custom")
				var/obj/CustomDecorBlueprint/custom = locate(href_list["ref"])
				if(custom && custom.creator == owner.ckey) owner.DestroyDecor(custom)
			if("close")
				del(src)
				owner.MapFocus()
				return
		show()

#undef NEXUS_BUILD_PAGE_SIZE
