turf/var
	build_category = BUILD_UNDEFINED

obj/var
	build_category = BUILD_UNDEFINED

client/var/tmp
	datum/NexusBuildWindow/nexus_build_window

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
			client.nexus_build_window.toggle()
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
			var/list/added_science_types = list()
			if(islist(GLOBAL_SCIENCE_TAB_ITEMS))
				for(var/obj/item in GLOBAL_SCIENCE_TAB_ITEMS)
					if(isRetiredScienceEquipment(item)) continue
					if(item.type in added_science_types) continue
					added_science_types += item.type
					global_science_items += item
			for(var/obj/item in tech_list)
				if(!canAccessTechnology(item) || (item.type in added_science_types)) continue
				added_science_types += item.type
				global_science_items += item
			for(var/obj/item in individual_science_items)
				if(isRetiredScienceEquipment(item)) continue
				if(item.type in added_science_types) continue
				added_science_types += item.type
				global_science_items += item

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
		var/list/added_types = list()
		if(islist(GLOBAL_SCIENCE_TAB_ITEMS))
			for(var/obj/item in GLOBAL_SCIENCE_TAB_ITEMS)
				if(isRetiredScienceEquipment(item)) continue
				if((item.type in Illegal_Science) || (item.type in added_types)) continue
				added_types += item.type
				results += item
		for(var/obj/item in tech_list)
			if(!owner.canAccessTechnology(item) || (item.type in Illegal_Science) || (item.type in added_types)) continue
			added_types += item.type
			results += item
		for(var/obj/item in owner.individual_science_items)
			if(isRetiredScienceEquipment(item)) continue
			if((item.type in Illegal_Science) || (item.type in added_types)) continue
			added_types += item.type
			results += item
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
			results = getBuildCatalogForCategory(category_id).Copy()
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

	proc/getDisplayName(atom/subject)
		var/display_name = "[subject.name]"
		if(istype(subject, /obj/Build) && copytext(display_name, -2) == "-B") display_name = copytext(display_name, 1, -2)
		return display_name
