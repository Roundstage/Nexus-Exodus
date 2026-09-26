// Browser rows carry references, but every menu and action resolves them against fresh panel data.
datum/ClassicHud
	proc/resolveContextSubject(widget, token)
		if(!(widget in list("sense", "target", "menu", "stats", "inventory", "skills"))) return
		var/datum/ClassicSnapshot/snapshot = owner.captureClassicData(widget == "menu" ? section : widget)
		var/atom/subject
		for(var/list/row in snapshot.rows)
			if(row["token"] == token)
				subject = snapshot.subjects[token]
				break
		del(snapshot)
		return subject

	proc/contextOptions(atom/subject)
		var/list/options = list()
		if(!owner || !subject) return options
		if(istype(subject, /obj/Contract_Soul) && subject.loc == owner)
			options += list(list("id" = "soul", "label" = "Manage Soul"))
		else if(isobj(subject) && subject.loc == owner)
			options += list(list("id" = "use", "label" = "Use"))
		if(isobj(subject) && subject:examinable && subject.desc)
			options += list(list("id" = "examine", "label" = "Examine"))
		// The command parser checks each verb's native src/range and argument restrictions.
		// Do not expose verbs of a remote mob or an object carried by someone else.
		if(isobj(subject) && (subject.loc == owner || (isturf(subject.loc) && subject in view(1, owner))))
			for(var/verb_path in subject.verbs)
				var/list/metadata = nexus_classic_command_catalog["[verb_path]"]
				if(!islist(metadata) || isnull(metadata[2]) || lowertext(metadata[2]) == "admin") continue
				options += list(list("id" = md5("[verb_path]"), "label" = metadata[1], "path" = verb_path, "explicit" = metadata[3]))
		if(owner.IsAdmin())
			if(ismob(subject))
				for(var/verb_path in list(/mob/AdminEssentials/verb/managePlayer, /mob/Admin1/verb/teleport, /mob/Admin1/verb/summon, /mob/Admin1/verb/adminHeal, /mob/Admin1/verb/adminRevive))
					if(!(verb_path in owner.verbs)) continue
					var/list/metadata = nexus_classic_command_catalog["[verb_path]"]
					if(!islist(metadata)) continue
					options += list(list("id" = md5("[verb_path]"), "label" = metadata[1], "path" = verb_path, "target" = TRUE))
			if(owner.AdminLevel() >= 3 && /mob/AdminEssentials/verb/adminInspector in owner.verbs)
				options += list(list("id" = "inspect", "label" = "Admin Inspector"))
		return options

	proc/contextCommand(atom/subject, list/option)
		var/command = replacetext(option["label"], " ", "-")
		if(option["explicit"] || option["target"]) command += " \"\ref[subject]\""
		return command

	proc/runTargetContextAction(mob/target, verb_path)
		if(!owner || usr != owner || !owner.IsAdmin() || !target || !(target in players) || !target.client) return FALSE
		// Only these single-target verbs may bypass the native argument parser.
		if(!(verb_path in list(/mob/AdminEssentials/verb/managePlayer, /mob/Admin1/verb/teleport, /mob/Admin1/verb/summon, /mob/Admin1/verb/adminHeal, /mob/Admin1/verb/adminRevive))) return FALSE
		if(!(verb_path in owner.verbs)) return FALSE
		if((verb_path == /mob/Admin1/verb/teleport || verb_path == /mob/Admin1/verb/summon) && (!target.z || !owner.z)) return FALSE
		call(owner, verb_path)(target)
		return TRUE

	proc/runContextAction(widget, token, action_id)
		var/atom/subject = resolveContextSubject(widget, token)
		if(!subject) return FALSE
		if(istype(subject, /obj/items))
			var/obj/items/item = subject
			if(item.nexus_trade_suspended_verbs || item.isNexusTradeOfferedBy(owner)) return FALSE
		var/list/selected
		for(var/list/option in contextOptions(subject))
			if(option["id"] == action_id)
				selected = option
				break
		if(!selected) return FALSE
		if(selected["target"]) return runTargetContextAction(subject, selected["path"])
		switch(action_id)
			if("soul") return owner.manageNexusSoulContract(subject)
			if("use")
				if(istype(subject, /obj/items)) return owner.useNexusInventoryItem(subject)
				if(owner.isNexusHotkeyObjectAvailable(subject)) return owner.executeNexusHotkeyAction(subject)
				subject.Click(null, "classic", "left=1")
			if("examine") owner.Examine(subject)
			if("inspect") owner.showNexusAdminInspector(subject)
			else
				if(!owner.client) return FALSE
				winset(owner, null, list2params(list("command" = contextCommand(subject, selected))))
		return TRUE

	proc/showContextMenu(widget, token)
		var/atom/subject = resolveContextSubject(widget, token)
		var/list/options = list()
		for(var/list/option in contextOptions(subject))
			options += list(list("id" = option["id"], "label" = option["label"]))
		owner << output(url_encode(json_encode(list("token" = token, "label" = subject ? "[subject]" : "Unavailable", "options" = options))), "[control(widget)]:classicContext")
