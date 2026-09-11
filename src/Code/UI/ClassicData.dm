// The native tabs and the Classic HUD share the same visibility and data rules.
mob/var/tmp/datum/ClassicSnapshot/nexus_classic_capture

mob/proc/classicStatPanel(panel_name)
	if(nexus_classic_capture)
		nexus_classic_capture.group = "[panel_name]"
		return TRUE
	return statpanel(panel_name)

mob/proc/classicStat(label, value)
	if(nexus_classic_capture)
		if(args.len == 1) nexus_classic_capture.add(null, label)
		else nexus_classic_capture.add(label, value)
		return
	if(args.len == 1) stat(label)
	else stat(label, value)

datum/ClassicSnapshot
	var/list/rows = list()
	var/list/subjects = list()
	var/group = ""

	proc/add(label, value)
		if(islist(value))
			for(var/entry in value) add(label, entry)
			return
		var/atom/subject = istype(value, /atom) ? value : null
		var/token = subject ? "\ref[subject]" : ""
		if(subject) subjects[token] = subject
		rows += list(list("label" = subject ? "[subject]" : (isnull(label) ? "[value]" : "[label]"), "value" = subject ? (isnull(label) ? "[subject.suffix]" : "[label]") : (isnull(label) ? "" : "[value]"), "token" = token, "group" = group))

mob/proc/canMonitorClassicTarget(mob/subject)
	if(!ismob(subject) || !subject.loc || !loc || subject.unsenseable) return FALSE
	if(subject == src) return TRUE
	if(subject.get_area() != get_area()) return FALSE
	return CanSense(src, subject)

mob/proc/captureClassicData(section)
	var/datum/ClassicSnapshot/snapshot = new
	var/datum/ClassicSnapshot/previous = nexus_classic_capture
	nexus_classic_capture = snapshot
	try
		switch(section)
			if("stats") Stat_Stat()
			if("inventory")
				classicStatPanel("Items")
				snapshot.add("ITEMS CARRIED", item_list.len)
				var/obj/Resources/resources = GetResourceObject()
				if(resources)
					resources.Update_value()
					snapshot.add(null, resources)
				for(var/obj/items/item in item_list) snapshot.add(null, item)
			if("skills")
				classicStatPanel("Skills")
				for(var/obj/skill in src)
					if(isNexusTechniqueObject(skill)) snapshot.add(null, skill)
			if("sense")
				Stat_Sense()
				Stat_Scouter()
				Stat_Vampire()
			if("target")
				sense2_obj = locate(/obj/Advanced_Sense) in src
				sense3_obj = locate(/obj/Sense3) in src
				if(ismob(Target) && canMonitorClassicTarget(Target)) Stat_Sense_Tab()
				// Inspect is administrative object access, not public target information.
				for(var/list/row in snapshot.rows.Copy())
					if(row["group"] == "Inspect") snapshot.rows -= list(row)
				// Keep the complete native snapshot available through All native tabs.
				// The combat frame prioritizes vitals and the full readable stat build.
				var/list/compact_labels = list("Power", "Health", "Energy", "Strength:", "Durability:", "Speed:", "Force:", "Resistance:", "Accuracy:", "Reflex:", "Regeneration:", "Recovery:")
				for(var/list/row in snapshot.rows.Copy())
					if(Scouter && Scouter.suffix && row["value"] == Target.name && row["label"] == "[Commas(Scouter_Reading(Target, Scouter))]")
						row["value"] = row["label"]
						row["label"] = "Power"
					if(!(row["label"] in compact_labels) && row["label"] != "Android stat builds are unsensable") snapshot.rows -= list(row)
			if("factions") Stat_leagues()
			if("world")
				classicStatPanel("World")
				classicStat("Year", round(Year, 0.1))
				classicStat("Area", "[get_area()]")
				classicStat("Players online", players.len)
				for(var/mob/player in players)
					if(player.client) classicStat(null, player)
			if("admin") if(IsAdmin()) Stat_Admin()
			if("modules") Stat_Modules()
			if("souls") Stat_Souls()
			if("science") Stat_Science()
			if("build") Stat_Build()
			if("navigation")
				Stat_Ship()
				Stat_Nav()
			if("radar") Stat_Radar()
			if("sagas") saga_tab()
			if("looting")
				if(Lootables) classicStat(Lootables)
	catch(var/exception/error)
		nexus_classic_capture = previous
		del(snapshot)
		throw error
	nexus_classic_capture = previous
	return snapshot

proc/getClassicSections()
	return list("actions" = "Actions / Other", "playtest" = "Playtest", "sagas" = "Sagas", "factions" = "Factions", "stats" = "Stats", "inventory" = "Items / Inventory", "science" = "Science", "build" = "Build", "modules" = "Modules", "souls" = "Souls", "radar" = "Radar", "navigation" = "Ship / Navigation", "looting" = "Looting", "world" = "World / Who", "admin" = "Admin")
