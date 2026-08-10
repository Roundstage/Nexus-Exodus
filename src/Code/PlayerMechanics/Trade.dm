mob/var/tmp/datum/NexusTradeSession/nexus_trade_session

obj/items/proc/isNexusTradeOfferedBy(mob/user)
	if(!user || loc != user || !user.nexus_trade_session) return FALSE
	return src in user.nexus_trade_session.getOffer(user)

obj/items/proc/canUseAfterNexusTradeYield(mob/user)
	return user && loc == user && (src in user.item_list) && !isNexusTradeOfferedBy(user)

obj/items/proc/canContinueNexusTradeInteraction(mob/user, atom/original_location)
	if(!user || loc != original_location) return FALSE
	if(original_location == user) return (src in user.item_list) && !isNexusTradeOfferedBy(user)
	return TRUE

obj/items/var/tmp/list/nexus_trade_suspended_verbs

obj/items/proc/setNexusTradeInteractionLocked(locked)
	if(locked)
		if(nexus_trade_suspended_verbs) return
		nexus_trade_suspended_verbs = verbs.Copy()
		verbs -= nexus_trade_suspended_verbs
		return
	if(!nexus_trade_suspended_verbs) return
	verbs += nexus_trade_suspended_verbs
	nexus_trade_suspended_verbs = null

proc/formatNexusTradeEssence(amount)
	if(!nexusIsFiniteNumber(amount)) return "0"
	return "[round(amount, 0.1)]"

proc/getNexusTradeUnsafeLegacyInteractionReason(obj/items/item)
	if(!item) return null
	if(istype(item, /obj/items/Robotics_Tools)) return "Robotics Tools have a legacy multi-stage interaction and are not yet eligible for secure trade."
	if(istype(item, /obj/items/Resource_Vaccuum))
		var/obj/items/Resource_Vaccuum/vacuum = item
		if(vacuum.Vaccuuming) return "An active Resource Vacuum cannot be traded until its collection cycle finishes."
	if(istype(item, /obj/items/T_Heal))
		var/obj/items/T_Heal/healing_injection = item
		if(healing_injection.injecting) return "An active healing injection cannot be traded until its use finishes."
	if(istype(item, /obj/items/Stun_Controls))
		var/obj/items/Stun_Controls/stun_controls = item
		if(stun_controls.cant_stun) return "Active stun controls cannot be traded until their cooldown finishes."
	if(istype(item, /obj/items/Nav_System))
		var/obj/items/Nav_System/navigation = item
		if(navigation.Destination) return "An active navigation autopilot cannot be traded until its route ends."
	if(istype(item, /obj/items/Gun))
		var/obj/items/Gun/gun = item
		if(gun.Firing) return "A firing gun cannot be traded until its refire cycle finishes."
		if(gun.nexus_customization_pending) return "A gun cannot be traded while its customization calibration is incomplete."
	if(istype(item, /obj/items/Ammo))
		var/obj/items/Ammo/ammunition = item
		if(ammunition.Reloading) return "An ammunition pack cannot be traded while a reload is in progress."
	if(istype(item, /obj/items/Gravity))
		var/obj/items/Gravity/gravity_generator = item
		if(gravity_generator.upgrading) return "A gravity generator cannot be traded while its upgrade prompt is active."
	if(istype(item, /obj/items/MagicVault))
		var/obj/items/MagicVault/vault = item
		if(vault.nexus_trade_prompt_pending) return "A Magic Vault cannot be traded while a password or balance prompt is active."
	if(istype(item, /obj/items/Moon) && item.icon_state == "On") return "An active artificial moon cannot be traded during its deletion countdown."
	if(istype(item, /obj/items/Nuke))
		var/obj/items/Nuke/nuke = item
		if(nuke.Bolted || nuke.detonated) return "An armed or detonating bomb cannot be securely traded."
	if(istype(item, /obj/items/ArcaneDisguise))
		var/obj/items/ArcaneDisguise/disguise = item
		if(disguise.active) return "An active Arcane Disguise cannot be traded until its glamour expires."
	if(istype(item, /obj/items/PDA))
		var/obj/items/PDA/pda = item
		if(pda.initial_reference_check_pending) return "A newly created PDA cannot be traded until its initialization check finishes."
	if(istype(item, /obj/items/Devil_Mat))
		var/obj/items/Devil_Mat/devil_mat = item
		if(devil_mat.disabled_cleanup_pending) return "A disabled Devil Mat pending cleanup cannot be traded."
	if(istype(item, /obj/items/Android_Blueprint))
		var/obj/items/Android_Blueprint/blueprint = item
		if(blueprint.Body && blueprint.Body.type == /obj/Ships/Ship) return "Ship blueprints have delayed cleanup state and cannot be securely traded."
	return null

proc/getNexusTradeIgnoredScalarVariables()
	return list("loc", "x", "y", "z", "contents", "verbs", "overlays", "underlays", "vis_contents", "vis_locs")

proc/getNexusTradeScalarFingerprint(datum/subject)
	if(!subject) return "missing"
	var/list/parts = list("type=[subject.type]")
	var/list/ignored_variables = getNexusTradeIgnoredScalarVariables()
	var/field_index = 0
	for(var/variable_name in subject.vars)
		if(variable_name in ignored_variables) continue
		if(!issaved(subject.vars[variable_name])) continue
		var/value = subject.vars[variable_name]
		if(!(isnum(value) || istext(value) || ispath(value) || isfile(value) || isicon(value))) continue
		field_index++
		var/variable_text = "[variable_name]"
		var/field_prefix = "field=[field_index];name_length=[length(variable_text)];name_hash=[md5(variable_text)]"
		if(isnum(value)) parts += "[field_prefix];kind=number;value=[value]"
		else if(istext(value)) parts += "[field_prefix];kind=text;length=[length(value)];hash=[md5(value)]"
		else if(ispath(value)) parts += "[field_prefix];kind=path;value=[value]"
		else if(isicon(value)) parts += "[field_prefix];kind=icon;value=[value]"
		else if(isfile(value)) parts += "[field_prefix];kind=file;value=[value]"
	return md5(jointext(parts, "\n"))

proc/getNexusTradeFullScalarDisclosure(datum/subject)
	if(!subject) return ""
	var/list/ignored_variables = getNexusTradeIgnoredScalarVariables()
	var/list/fields = list()
	for(var/variable_name in subject.vars)
		if(variable_name in ignored_variables) continue
		if(!issaved(subject.vars[variable_name])) continue
		var/value = subject.vars[variable_name]
		if(!(isnum(value) || istext(value) || ispath(value) || isfile(value) || isicon(value))) continue
		var/variable_text = html_encode("[variable_name]")
		var/value_text = html_encode("[value]")
		fields += "<span style='display:block;margin:2px 0'><b>[variable_text]</b>: [value_text]</span>"
	var/field_text = fields.len ? jointext(fields, "") : "<span>No saved scalar fields.</span>"
	return "<details class='scalar-config' style='margin-top:7px;padding:6px;border:1px solid #665236;background:#15110d'><summary style='cursor:pointer;color:#e5bd66'>FULL REPLICATED SCALAR CONFIGURATION ([fields.len] FIELDS)</summary><div style='margin-top:5px;color:#bda77e;overflow-wrap:anywhere'>[field_text]</div></details>"

datum/NexusTradeContentSnapshot
	var/list/fingerprint_parts
	var/list/disclosure_rows
	var/list/visited
	var/node_count = 0
	var/saved_graph_entry_count = 0
	var/maximum_depth = 8
	var/maximum_nodes = 200
	var/maximum_saved_graph_entries = 1000
	var/error

	New(atom/root, depth_limit = 8, node_limit = 200)
		..()
		fingerprint_parts = list()
		disclosure_rows = list()
		visited = list()
		maximum_depth = max(1, depth_limit)
		maximum_nodes = max(1, node_limit)
		if(!root)
			error = "The offered container no longer exists."
			return
		visited += root
		captureContents(root, 0)

	proc/captureContents(atom/container, depth)
		if(error || !container) return
		if(depth >= maximum_depth)
			for(var/atom/movable/nested_entry in container)
				error = "Nested contents exceed the secure trade depth limit of [maximum_depth]."
				return
			return
		var/content_index = 0
		for(var/atom/movable/nested_entry in container)
			content_index++
			if(!isobj(nested_entry))
				error = "A container holds unsupported non-item contents and cannot be securely traded."
				return
			var/obj/nested_object = nested_entry
			if(nested_object in visited)
				error = "A container contains a cyclic object reference and cannot be securely traded."
				return
			node_count++
			if(node_count > maximum_nodes)
				error = "Container contents exceed the secure trade limit of [maximum_nodes] objects."
				return
			visited += nested_object
			if(istype(nested_object, /obj/items))
				var/obj/items/nested_item = nested_object
				if(!nested_item.Givable)
					error = "Nested item [nested_item.type] is bound and cannot be transferred."
					return
				if(nested_item.suffix == "Equipped" || nested_item.suffix == "Installed")
					error = "Nested item [nested_item.type] must be unequipped or uninstalled before it can be traded."
					return
				if(nested_item.suffix && !nested_item.Can_Drop_With_Suffix)
					error = "Nested item [nested_item.type] cannot be transferred while its current status is active."
					return
				if(istype(nested_item, /obj/items/Force_Field))
					error = "Force fields cannot be transferred inside another offered item."
					return
				var/nested_unsafe_reason = getNexusTradeUnsafeLegacyInteractionReason(nested_item)
				if(nested_unsafe_reason)
					error = "Nested item cannot be securely traded: [nested_unsafe_reason]"
					return
			var/scalar_fingerprint = getNexusTradeScalarFingerprint(nested_object)
			var/datum/NexusTradeSavedListSnapshot/list_snapshot = new(nested_object)
			var/list_error = list_snapshot.error
			saved_graph_entry_count += list_snapshot.entry_count
			if(list_error)
				error = "Nested item [nested_object.type] cannot be securely inspected: [list_error]"
				del(list_snapshot)
				return
			if(saved_graph_entry_count > maximum_saved_graph_entries)
				error = "Nested saved-list configuration exceeds the secure trade limit of [maximum_saved_graph_entries] total entries."
				del(list_snapshot)
				return
			var/saved_list_fingerprint = list_snapshot.getFingerprint()
			var/saved_list_disclosure = list_snapshot.getDisclosure()
			del(list_snapshot)
			fingerprint_parts += "depth=[depth + 1];index=[content_index];parent_ref=\ref[container];item_ref=\ref[nested_object];type=[nested_object.type];state=[scalar_fingerprint];saved_lists=[saved_list_fingerprint]"
			var/nested_name = html_encode("[nested_object]")
			var/nested_type = html_encode("[nested_object.type]")
			var/nested_seal = copytext(scalar_fingerprint, 1, 13)
			var/indent = min(72, depth * 12)
			disclosure_rows += "<article style='margin:5px 0 0 [indent]px;padding:6px;border:1px solid #604c31;background:#1d1710'><b>[nested_name]</b><span style='display:block'>Exact type: [nested_type]</span><span style='display:block'>Nested depth: [depth + 1] / scalar seal: [nested_seal]</span>[getNexusTradeFullScalarDisclosure(nested_object)][saved_list_disclosure]</article>"
			captureContents(nested_object, depth + 1)
			if(error) return

	proc/getFingerprint()
		var/error_state = error ? error : "none"
		var/parts_text = jointext(fingerprint_parts, "\n")
		return md5("error=[error_state]\n[parts_text]")

	proc/getDisclosure()
		if(!node_count && !error) return ""
		var/error_html = error ? "<div class='notice error'>[html_encode(error)]</div>" : ""
		var/rows_html = disclosure_rows.len ? jointext(disclosure_rows, "") : "<div class='empty compact'>No supported nested objects.</div>"
		return "<details class='container-contents' open style='margin-top:7px;padding:7px;border:2px solid #765d36;background:#17120d'><summary style='cursor:pointer;color:#e5bd66'>CONTAINER CONTENTS ([node_count] OBJECTS)</summary>[error_html]<div style='margin-top:5px'>[rows_html]</div></details>"

proc/getNexusTradeContentsFingerprint(atom/container)
	var/datum/NexusTradeContentSnapshot/snapshot = new(container)
	var/fingerprint = snapshot.getFingerprint()
	del(snapshot)
	return fingerprint

proc/getNexusTradeContentsError(atom/container)
	var/datum/NexusTradeContentSnapshot/snapshot = new(container)
	var/content_error = snapshot.error
	del(snapshot)
	return content_error

proc/getNexusTradeContentsDisclosure(atom/container)
	var/datum/NexusTradeContentSnapshot/snapshot = new(container)
	var/disclosure = snapshot.getDisclosure()
	del(snapshot)
	return disclosure

datum/NexusTradeSavedListSnapshot
	var/list/fingerprint_parts
	var/list/disclosure_rows
	var/list/captured_refs
	var/list/active_refs
	var/list/captured_datum_refs
	var/list/active_datum_refs
	var/list_count = 0
	var/datum_count = 0
	var/entry_count = 0
	var/maximum_depth = 8
	var/maximum_entries = 1000
	var/error

	New(datum/subject, depth_limit = 8, entry_limit = 1000)
		..()
		fingerprint_parts = list()
		disclosure_rows = list()
		captured_refs = list()
		active_refs = list()
		captured_datum_refs = list()
		active_datum_refs = list()
		maximum_depth = max(1, depth_limit)
		maximum_entries = max(1, entry_limit)
		if(!subject)
			error = "The replicated subject no longer exists."
			return
		var/subject_ref = "\ref[subject]"
		captured_datum_refs[subject_ref] = TRUE
		active_datum_refs[subject_ref] = TRUE
		var/list/ignored_variables = getNexusTradeIgnoredScalarVariables()
		for(var/variable_name in subject.vars)
			if(variable_name in ignored_variables) continue
			if(!issaved(subject.vars[variable_name])) continue
			var/value = subject.vars[variable_name]
			if(!islist(value)) continue
			var/list/saved_list = value
			list_count++
			var/variable_text = html_encode("[variable_name]")
			disclosure_rows += "<article style='margin-top:5px;padding:6px;border:1px solid #604c31;background:#1d1710'><b>[variable_text]</b><span style='display:block'>Saved list with [saved_list.len] ordered entries</span></article>"
			fingerprint_parts += "variable=[variable_name];list_ref=\ref[saved_list];length=[saved_list.len]"
			captureList(saved_list, "[variable_name]", 0)
			if(error) return
		for(var/variable_name in subject.vars)
			if(variable_name in ignored_variables) continue
			if(!issaved(subject.vars[variable_name])) continue
			var/value = subject.vars[variable_name]
			if(!istype(value, /datum)) continue
			var/value_path = "[variable_name]"
			var/encoded_value = encodeValue(value, value_path, 1)
			fingerprint_parts += "direct_variable=[value_path];value=[encoded_value]"
			if(error) return
		active_datum_refs[subject_ref] = null

	proc/captureList(list/current_list, list_path, depth)
		if(error || !current_list) return
		if(depth >= maximum_depth && current_list.len)
			error = "Saved list [list_path] exceeds the secure trade depth limit of [maximum_depth]."
			return
		var/list_ref = "\ref[current_list]"
		if(active_refs[list_ref])
			error = "Saved list [list_path] contains a cycle and cannot be securely traded."
			return
		if(captured_refs[list_ref])
			fingerprint_parts += "path=[list_path];shared_list_ref=[list_ref]"
			return
		captured_refs[list_ref] = TRUE
		active_refs[list_ref] = TRUE
		for(var/list_index = 1, list_index <= current_list.len, list_index++)
			entry_count++
			if(entry_count > maximum_entries)
				error = "Saved list configuration exceeds the secure trade limit of [maximum_entries] entries."
				active_refs[list_ref] = null
				return
			var/entry = current_list[list_index]
			var/entry_path = "[list_path]/entry-[list_index]"
			var/encoded_entry = encodeValue(entry, entry_path, depth + 1)
			fingerprint_parts += "path=[entry_path];value=[encoded_entry]"
			if(error)
				active_refs[list_ref] = null
				return
			var/entry_description = html_encode(describeValue(entry))
			var/path_text = html_encode(entry_path)
			disclosure_rows += "<span style='display:block;margin:2px 0 2px [min(72, depth * 12)]px'><b>[path_text]</b>: [entry_description]</span>"
			if(isAssociationKey(entry))
				var/associated_value = current_list[entry]
				if(!isnull(associated_value))
					entry_count++
					if(entry_count > maximum_entries)
						error = "Saved list configuration exceeds the secure trade limit of [maximum_entries] entries."
						active_refs[list_ref] = null
						return
					var/association_path = "[list_path]/key-[entry]"
					var/encoded_association = encodeValue(associated_value, association_path, depth + 1)
					fingerprint_parts += "association_index=[list_index];key=[encoded_entry];value=[encoded_association]"
					if(error)
						active_refs[list_ref] = null
						return
					var/association_description = html_encode(describeValue(associated_value))
					var/association_text = html_encode(association_path)
					disclosure_rows += "<span style='display:block;margin:2px 0 2px [min(72, (depth + 1) * 12)]px'><b>[association_text]</b>: [association_description]</span>"
		active_refs[list_ref] = null

	proc/isAssociationKey(value)
		return istext(value) || ispath(value) || isfile(value) || isicon(value) || istype(value, /datum)

	proc/captureDatum(datum/datum_value, datum_path, depth)
		if(error || !datum_value) return
		if(depth > maximum_depth)
			error = "Saved datum [datum_path] exceeds the secure trade depth limit of [maximum_depth]."
			return
		var/datum_ref = "\ref[datum_value]"
		if(active_datum_refs[datum_ref])
			var/cycle_type_text = html_encode("[datum_value.type]")
			fingerprint_parts += "path=[datum_path];cycle_datum_ref=[datum_ref];type=[datum_value.type]"
			disclosure_rows += "<span style='display:block;margin:2px 0 2px [min(72, depth * 12)]px'><b>[html_encode(datum_path)]</b>: Cycle reference to [cycle_type_text]</span>"
			return
		if(captured_datum_refs[datum_ref])
			var/shared_type_text = html_encode("[datum_value.type]")
			fingerprint_parts += "path=[datum_path];shared_datum_ref=[datum_ref];type=[datum_value.type]"
			disclosure_rows += "<span style='display:block;margin:2px 0 2px [min(72, depth * 12)]px'><b>[html_encode(datum_path)]</b>: Shared reference to [shared_type_text]</span>"
			return
		captured_datum_refs[datum_ref] = TRUE
		active_datum_refs[datum_ref] = TRUE
		datum_count++
		entry_count++
		if(entry_count > maximum_entries)
			error = "Saved configuration exceeds the secure trade limit of [maximum_entries] entries."
			active_datum_refs[datum_ref] = null
			return
		var/datum_type_text = html_encode("[datum_value.type]")
		var/datum_path_text = html_encode(datum_path)
		var/datum_scalar_state = getNexusTradeScalarFingerprint(datum_value)
		var/datum_contents_disclosure = ""
		if(istype(datum_value, /atom))
			var/atom/atom_value = datum_value
			datum_contents_disclosure = getNexusTradeContentsDisclosure(atom_value)
		fingerprint_parts += "path=[datum_path];datum_ref=[datum_ref];type=[datum_value.type];state=[datum_scalar_state]"
		disclosure_rows += "<article style='margin:5px 0 0 [min(72, depth * 12)]px;padding:6px;border:1px solid #604c31;background:#1d1710'><b>[datum_path_text]</b><span style='display:block'>Saved datum type: [datum_type_text]</span>[getNexusTradeFullScalarDisclosure(datum_value)][datum_contents_disclosure]</article>"
		var/list/ignored_variables = getNexusTradeIgnoredScalarVariables()
		for(var/variable_name in datum_value.vars)
			if(variable_name in ignored_variables) continue
			if(!issaved(datum_value.vars[variable_name])) continue
			var/value = datum_value.vars[variable_name]
			var/field_path = "[datum_path]/[variable_name]"
			if(islist(value))
				var/list/saved_list = value
				list_count++
				fingerprint_parts += "datum_variable=[field_path];list_ref=\ref[saved_list];length=[saved_list.len]"
				disclosure_rows += "<span style='display:block;margin:2px 0 2px [min(72, (depth + 1) * 12)]px'><b>[html_encode(field_path)]</b>: Saved list with [saved_list.len] ordered entries</span>"
				captureList(saved_list, field_path, depth + 1)
			else if(istype(value, /datum))
				var/encoded_value = encodeValue(value, field_path, depth + 1)
				fingerprint_parts += "datum_variable=[field_path];value=[encoded_value]"
			if(error)
				active_datum_refs[datum_ref] = null
				return
		active_datum_refs[datum_ref] = null

	proc/encodeValue(value, value_path, depth)
		if(isnull(value)) return "null"
		if(isnum(value)) return "number=[value]"
		if(istext(value)) return "text_length=[length(value)];text_hash=[md5(value)]"
		if(ispath(value)) return "path=[value]"
		if(isfile(value)) return "file=[value]"
		if(isicon(value)) return "icon=[value]"
		if(islist(value))
			var/list/nested_list = value
			captureList(nested_list, value_path, depth)
			return "list_ref=\ref[nested_list];length=[nested_list.len]"
		if(istype(value, /atom))
			var/atom/atom_value = value
			var/content_error = getNexusTradeContentsError(atom_value)
			if(content_error)
				error = "Saved list value [value_path] cannot be securely inspected: [content_error]"
			captureDatum(atom_value, value_path, depth)
			return "atom_ref=\ref[atom_value];type=[atom_value.type];state=[getNexusTradeScalarFingerprint(atom_value)];contents=[getNexusTradeContentsFingerprint(atom_value)]"
		if(istype(value, /datum))
			var/datum/datum_value = value
			captureDatum(datum_value, value_path, depth)
			return "datum_ref=\ref[datum_value];type=[datum_value.type];state=[getNexusTradeScalarFingerprint(datum_value)]"
		error = "Saved list value [value_path] has an unsupported value type."
		return "unsupported"

	proc/describeValue(value)
		if(isnull(value)) return "null"
		if(islist(value))
			var/list/nested_list = value
			return "Nested list ([nested_list.len] entries)"
		if(istype(value, /atom))
			var/atom/atom_value = value
			var/scalar_seal = copytext(getNexusTradeScalarFingerprint(atom_value), 1, 13)
			return "[atom_value] ([atom_value.type], scalar seal [scalar_seal])"
		if(istype(value, /datum))
			var/datum/datum_value = value
			var/scalar_seal = copytext(getNexusTradeScalarFingerprint(datum_value), 1, 13)
			return "Saved datum [datum_value.type] (scalar seal [scalar_seal])"
		return "[value]"

	proc/getFingerprint()
		var/error_state = error ? error : "none"
		var/parts_text = jointext(fingerprint_parts, "\n")
		return md5("error=[error_state]\n[parts_text]")

	proc/getDisclosure()
		var/error_html = error ? "<div class='notice error'>[html_encode(error)]</div>" : ""
		var/rows_html = disclosure_rows.len ? jointext(disclosure_rows, "") : "<div class='empty compact'>No saved list fields.</div>"
		return "<details class='saved-list-config' style='margin-top:7px;padding:7px;border:2px solid #765d36;background:#17120d'><summary style='cursor:pointer;color:#e5bd66'>FULL SAVED LIST CONFIGURATION ([list_count] LISTS / [datum_count] DATUMS / [entry_count] ENTRIES)</summary>[error_html]<div style='margin-top:5px;color:#bda77e;overflow-wrap:anywhere'>[rows_html]</div></details>"

proc/getNexusTradeSavedListsFingerprint(datum/subject)
	var/datum/NexusTradeSavedListSnapshot/snapshot = new(subject)
	var/fingerprint = snapshot.getFingerprint()
	del(snapshot)
	return fingerprint

proc/getNexusTradeSavedListsError(datum/subject)
	var/datum/NexusTradeSavedListSnapshot/snapshot = new(subject)
	var/list_error = snapshot.error
	del(snapshot)
	return list_error

proc/getNexusTradeSavedListsDisclosure(datum/subject)
	var/datum/NexusTradeSavedListSnapshot/snapshot = new(subject)
	var/disclosure = snapshot.getDisclosure()
	del(snapshot)
	return disclosure

proc/getNexusTradeItemGraphError(atom/root)
	if(!root) return "The item no longer exists."
	var/datum/NexusTradeSavedListSnapshot/root_snapshot = new(root)
	var/root_error = root_snapshot.error
	var/root_entries = root_snapshot.entry_count
	del(root_snapshot)
	if(root_error) return root_error
	var/datum/NexusTradeContentSnapshot/content_snapshot = new(root)
	var/content_error = content_snapshot.error
	var/total_entries = root_entries + content_snapshot.saved_graph_entry_count
	del(content_snapshot)
	if(content_error) return content_error
	if(total_entries > 1000) return "Saved-list configuration exceeds the secure trade limit of 1000 total entries across the item and its contents."
	return null

proc/getNexusTradeBlueprintSavedListSubjects(obj/items/Android_Blueprint/blueprint)
	var/list/subjects = list()
	if(!blueprint || !blueprint.Body) return subjects
	var/atom/design = blueprint.Body
	subjects += design
	for(var/obj/component in design)
		if(!(component in subjects)) subjects += component
		if(!istype(component, /obj/Module)) continue
		var/obj/Module/module = component
		for(var/obj/ability in module.Abilities)
			if(ability && !(ability in subjects)) subjects += ability
	return subjects

proc/getNexusTradeBlueprintSavedListsError(obj/items/Android_Blueprint/blueprint)
	var/total_entries = 0
	for(var/atom/subject in getNexusTradeBlueprintSavedListSubjects(blueprint))
		var/datum/NexusTradeSavedListSnapshot/snapshot = new(subject)
		var/subject_error = snapshot.error
		total_entries += snapshot.entry_count
		del(snapshot)
		if(subject_error) return "[subject.type] cannot be securely inspected: [subject_error]"
		if(total_entries > 1000) return "Replicated saved-list configuration exceeds the secure trade limit of 1000 total entries."
	return null

proc/getNexusTradeBlueprintFingerprint(obj/items/Android_Blueprint/blueprint)
	if(!blueprint || !blueprint.Body) return "blank"
	var/atom/design = blueprint.Body
	var/list/parts = list("design_ref=\ref[design]", "design_type=[design.type]", "design_state=[getNexusTradeScalarFingerprint(design)]", "design_contents=[getNexusTradeContentsFingerprint(design)]")
	for(var/obj/component in design)
		parts += "component_ref=\ref[component];type=[component.type];state=[getNexusTradeScalarFingerprint(component)]"
		if(istype(component, /obj/Module))
			var/obj/Module/module = component
			for(var/obj/ability in module.Abilities)
				parts += "module_ability_ref=\ref[ability];type=[ability.type];state=[getNexusTradeScalarFingerprint(ability)]"
	var/subject_index = 0
	for(var/atom/list_subject in getNexusTradeBlueprintSavedListSubjects(blueprint))
		subject_index++
		parts += "saved_list_subject_index=[subject_index];ref=\ref[list_subject];type=[list_subject.type];state=[getNexusTradeSavedListsFingerprint(list_subject)]"
	return md5(jointext(parts, "\n"))

proc/getNexusTradeItemFingerprint(obj/items/item)
	if(!item) return "missing"
	var/list/parts = list("item_ref=\ref[item]", "item_type=[item.type]", "item_state=[getNexusTradeScalarFingerprint(item)]", "item_saved_lists=[getNexusTradeSavedListsFingerprint(item)]", "nested_contents=[getNexusTradeContentsFingerprint(item)]")
	if(istype(item, /obj/items/Android_Blueprint))
		parts += "blueprint_state=[getNexusTradeBlueprintFingerprint(item)]"
	return md5(jointext(parts, "\n"))

proc/getNexusTradeAbilityDisclosure(obj/ability)
	if(!ability) return ""
	var/ability_name = html_encode("[ability]")
	var/ability_type = html_encode("[ability.type]")
	var/ability_description = html_encode(ability.desc ? "[ability.desc]" : "No description available.")
	return "<article class='module-details'><b>[ability_name]</b><span>Exact type: [ability_type]</span><span>Description: [ability_description]</span>[getNexusTradeFullScalarDisclosure(ability)][getNexusTradeSavedListsDisclosure(ability)][getNexusTradeContentsDisclosure(ability)]</article>"

proc/getNexusTradeModuleDisclosure(obj/Module/module)
	if(!module) return ""
	var/list/effects = list()
	if(module.BPx != 1) effects += "Battle power [round(module.BPx, 0.01)]x"
	if(module.Kix != 1) effects += "Energy [round(module.Kix, 0.01)]x"
	if(module.Strx != 1) effects += "Strength [round(module.Strx, 0.01)]x"
	if(module.Endx != 1) effects += "Endurance [round(module.Endx, 0.01)]x"
	if(module.Powx != 1) effects += "Force [round(module.Powx, 0.01)]x"
	if(module.Resx != 1) effects += "Resistance [round(module.Resx, 0.01)]x"
	if(module.Spdx != 1) effects += "Speed [round(module.Spdx, 0.01)]x"
	if(module.Offx != 1) effects += "Offense [round(module.Offx, 0.01)]x"
	if(module.Defx != 1) effects += "Defense [round(module.Defx, 0.01)]x"
	if(module.Regx != 1) effects += "Regeneration [round(module.Regx, 0.01)]x"
	if(module.Recx != 1) effects += "Recovery [round(module.Recx, 0.01)]x"
	if(module.Leechx != 1) effects += "Leech [round(module.Leechx, 0.01)]x"
	if(module.Life_Add) effects += "Lifespan +[module.Life_Add]"
	if(module.Regenerate_Add) effects += "Regeneration lives +[module.Regenerate_Add]"
	if(module.Lungs) effects += "Space breathing"
	if(module.Cyber_Fly) effects += "Antigravity flight"
	if(module.Nanite_Repair) effects += "Nanite repair"
	if(module.Scanner) effects += "Integrated scanner"
	if(module.Cyber_Force_Field) effects += "Automatic force field"
	if(module.Blast_Absorb) effects += "Blast absorption"
	if(module.paralysis_immunity) effects += "Time/paralysis resistance"
	if(module.Giant) effects += "Giant chassis"
	if(module.Android_Only) effects += "Android-only"
	if(module.Requires_Password)
		if(module.Password) effects += "Access code / frequency: [module.Password] (the seller may still know this code; change it after purchase if the module supports changing it)"
		else effects += "Access code not configured"
	var/list/abilities = list()
	for(var/obj/ability in module.Abilities) abilities += "[ability] ([ability.type])"
	if(abilities.len)
		var/ability_text = jointext(abilities, ", ")
		effects += "Abilities: [ability_text]"
	if(!effects.len) effects += "No additional scalar effects"
	var/module_name = html_encode("[module]")
	var/module_type = html_encode("[module.type]")
	var/module_status = html_encode(module.suffix ? "[module.suffix]" : "Not installed")
	var/module_description = html_encode(module.desc ? "[module.desc]" : "No description available.")
	var/module_effects = html_encode(jointext(effects, "; "))
	var/list/ability_disclosures = list()
	for(var/obj/ability in module.Abilities) ability_disclosures += getNexusTradeAbilityDisclosure(ability)
	var/ability_details = ""
	if(ability_disclosures.len)
		var/ability_disclosure_text = jointext(ability_disclosures, "")
		ability_details = "<div class='module-list'><b>REPLICATED MODULE ABILITIES ([ability_disclosures.len])</b>[ability_disclosure_text]</div>"
	return "<article class='module-details'><b>[module_name]</b><span>Exact type: [module_type]</span><span>Status: [module_status]</span><span>Base / upgrade value: [Commas(module.Cost)] / [Commas(module.Total_Cost)] resources</span><span>Effects: [module_effects]</span><span>Description: [module_description]</span>[getNexusTradeFullScalarDisclosure(module)][getNexusTradeSavedListsDisclosure(module)][getNexusTradeContentsDisclosure(module)][ability_details]</article>"

proc/getNexusTradeComponentDisclosure(obj/component)
	if(!component) return ""
	var/component_name = html_encode("[component]")
	var/component_type = html_encode("[component.type]")
	var/component_status = html_encode(component.suffix ? "[component.suffix]" : "No active status")
	var/component_description = html_encode(component.desc ? "[component.desc]" : "No description available.")
	var/replication_status = component.clonable ? "Replicated with this design" : "Not replicated by Android duplication"
	return "<article class='module-details'><b>[component_name]</b><span>Exact type: [component_type]</span><span>Replication: [replication_status]</span><span>Status: [component_status]</span><span>Base / upgrade value: [Commas(component.Cost)] / [Commas(component.Total_Cost)] resources</span><span>Description: [component_description]</span>[getNexusTradeFullScalarDisclosure(component)][getNexusTradeSavedListsDisclosure(component)][getNexusTradeContentsDisclosure(component)]</article>"

proc/getNexusTradeObjectConfigurationDisclosure(obj/design)
	if(!design) return ""
	var/list/field_labels = list(
		"BP" = "Battle power",
		"bp_mod" = "Damage scale",
		"Force" = "Force",
		"Offense" = "Offense",
		"Off" = "Offense rating",
		"Def" = "Defense rating",
		"Health" = "Durability",
		"Armor" = "Armor",
		"Damage" = "Damage",
		"Max_Ammo" = "Maximum ammo",
		"Ammo" = "Loaded ammo",
		"Delay" = "Refire delay",
		"Velocity" = "Projectile velocity",
		"Precision" = "Precision",
		"Reload_Speed" = "Reload speed",
		"Range" = "Range",
		"Knockbacks" = "Knockback",
		"Knockback" = "Knockback",
		"Explodes" = "Explosion",
		"Spread" = "Spread",
		"Stun" = "Stun",
		"Bullet" = "Projectile mode",
		"Resources" = "Stored resources",
		"DrillRate" = "Drilling rate",
		"Level" = "Level",
		"Customization_Points" = "Customization points",
		"Str" = "Impact strength",
		"Dur" = "Durability rating",
		"Spd" = "Movement speed",
		"Eff" = "Fuel efficiency",
		"Frc" = "Weapon force",
		"Res" = "Resistance rating",
		"Reg" = "Regeneration rating",
		"Rec" = "Recovery rating",
		"Ki" = "Current fuel / energy",
		"max_ki" = "Maximum fuel / energy",
		"Weapon_Mounts" = "Weapon mounts",
		"Refire" = "Ship refire",
		"Nav" = "Navigation level",
		"Comms" = "Communications enabled",
		"Launchable" = "Launch capable",
		"dna_verification" = "DNA lock",
		"Turret_Power" = "Turret power",
		"Turret_Refire" = "Turret refire",
		"Turret_Offense" = "Turret offense",
		"Turret_Force" = "Turret force",
		"Password" = "Access code / frequency",
		"Bolted" = "Bolted",
		"dna_protected" = "DNA protected"
	)
	var/list/configuration = list()
	for(var/field_name in field_labels)
		if(!(field_name in design.vars)) continue
		var/value = design.vars[field_name]
		if(!(isnum(value) || istext(value) || ispath(value))) continue
		var/field_label = field_labels[field_name]
		configuration += "[field_label]: [value]"
	if(!configuration.len) return "No additional allowlisted scalar configuration"
	return html_encode(jointext(configuration, "; "))

proc/getNexusTradeBlueprintDisclosure(obj/items/Android_Blueprint/blueprint)
	if(!blueprint || !blueprint.Body) return "<div class='blueprint blank'><b>BLUEPRINT CONTENTS</b><span>Blank / no stored design</span></div>"
	var/atom/design = blueprint.Body
	var/design_name = html_encode("[design]")
	var/design_type = html_encode("[design.type]")
	var/design_facts = "Stored design: [design_name]<br>Design type: [design_type]"
	if(ismob(design))
		var/mob/android_design = design
		var/race_class = html_encode("[android_design.Race] / [android_design.Class]")
		design_facts += "<br>Race / class: [race_class]"
		design_facts += "<br>Current / base / cyber power: [Commas(android_design.BP)] / [Commas(android_design.base_bp)] / [Commas(android_design.cyber_bp)]"
		design_facts += "<br><b>Replicated combat core</b>"
		design_facts += "<br>STR [Commas(android_design.Str)] ([round(android_design.strmod, 0.01)]x) / END [Commas(android_design.End)] ([round(android_design.endmod, 0.01)]x) / SPD [Commas(android_design.Spd)] ([round(android_design.spdmod, 0.01)]x)"
		design_facts += "<br>FOR [Commas(android_design.Pow)] ([round(android_design.formod, 0.01)]x) / RES [Commas(android_design.Res)] ([round(android_design.resmod, 0.01)]x) / OFF [Commas(android_design.Off)] ([round(android_design.offmod, 0.01)]x) / DEF [Commas(android_design.Def)] ([round(android_design.defmod, 0.01)]x)"
		design_facts += "<br>Energy [Commas(android_design.max_ki)] / efficiency [round(android_design.Eff, 0.01)]x / regeneration [round(android_design.regen, 0.01)]x / recovery [round(android_design.recov, 0.01)]x"
		design_facts += getNexusTradeFullScalarDisclosure(android_design)
		design_facts += getNexusTradeSavedListsDisclosure(android_design)
	else if(isobj(design))
		var/obj/object_design = design
		design_facts += "<br>Base / upgrade value: [Commas(object_design.Cost)] / [Commas(object_design.Total_Cost)] resources"
		design_facts += "<br><b>Replicated object configuration</b><br>[getNexusTradeObjectConfigurationDisclosure(object_design)]"
		design_facts += getNexusTradeFullScalarDisclosure(object_design)
		design_facts += getNexusTradeSavedListsDisclosure(object_design)
	var/list/module_facts = list()
	var/list/component_facts = list()
	for(var/obj/component in design)
		if(istype(component, /obj/Module))
			module_facts += getNexusTradeModuleDisclosure(component)
			continue
		component_facts += getNexusTradeComponentDisclosure(component)
	if(module_facts.len)
		var/module_text = jointext(module_facts, "")
		design_facts += "<div class='module-list'><b>INSTALLED / STORED MODULES ([module_facts.len])</b>[module_text]</div>"
	else
		design_facts += "<br>Installed / stored modules: None"
	if(component_facts.len)
		var/component_text = jointext(component_facts, "")
		design_facts += "<div class='module-list'><b>REPLICATED DIRECT COMPONENTS / ABILITIES ([component_facts.len])</b>[component_text]</div>"
	else
		design_facts += "<br>Direct components / abilities: None"
	var/design_seal = copytext(getNexusTradeBlueprintFingerprint(blueprint), 1, 13)
	return "<div class='blueprint'><b>BLUEPRINT CONTENTS</b><div class='blueprint-body' style='margin-top:4px;color:#d8c08e;line-height:1.45'>[design_facts]<br>Design seal: [design_seal]</div></div>"

proc/getNexusTradeItemDisclosure(obj/items/item)
	if(!item) return "<div class='item-facts danger'>This item no longer exists.</div>"
	var/status_text = item.suffix ? "[item.suffix]" : "Carried / unequipped"
	var/description_text = item.desc ? "[item.desc]" : "No description available."
	var/type_text = html_encode("[item.type]")
	var/state_seal = copytext(getNexusTradeItemFingerprint(item), 1, 13)
	var/html = "<div class='item-facts'><span><b>Exact type:</b> [type_text]</span><span><b>Status:</b> [html_encode(status_text)]</span><span><b>Base / upgrade value:</b> [Commas(item.Cost)] / [Commas(item.Total_Cost)] resources</span><span><b>Description:</b> [html_encode(description_text)]</span><span><b>State seal:</b> [state_seal]</span></div>[getNexusTradeFullScalarDisclosure(item)][getNexusTradeSavedListsDisclosure(item)][getNexusTradeContentsDisclosure(item)]"
	if(istype(item, /obj/items/MagicVault))
		var/obj/items/MagicVault/vault = item
		var/vault_code = vault.Password ? html_encode("[vault.Password]") : "Not configured"
		html += "<div class='blueprint' style='border-color:#765d36'><b>MAGIC VAULT VALUE</b><span>Stored Arcane Essence: [formatNexusTradeEssence(vault.stored_essence)]</span><span>Access code: [vault_code] (the seller may still know this code)</span></div>"
	if(istype(item, /obj/items/Android_Blueprint)) html += getNexusTradeBlueprintDisclosure(item)
	return html

datum/NexusTradeSession
	var/mob/trader_a
	var/mob/trader_b
	var/list/offer_a
	var/list/offer_b
	var/resources_a = 0
	var/resources_b = 0
	var/essence_a = 0
	var/essence_b = 0
	var/accepted_a = FALSE
	var/accepted_b = FALSE
	var/final_a = FALSE
	var/final_b = FALSE
	var/invitation_accepted = FALSE
	var/phase = "invite"
	var/revision = 1
	var/confirmation_revision = 0
	var/confirmation_fingerprint
	var/committing = FALSE
	var/last_error

	New(mob/first_trader, mob/second_trader, monitor_session = TRUE)
		..()
		trader_a = first_trader
		trader_b = second_trader
		offer_a = list()
		offer_b = list()
		if(trader_a) trader_a.nexus_trade_session = src
		if(trader_b) trader_b.nexus_trade_session = src
		if(monitor_session) monitorSession()

	Del()
		var/mob/first_trader = trader_a
		var/mob/second_trader = trader_b
		unlockOfferedItems()
		trader_a = null
		trader_b = null
		if(first_trader && first_trader.nexus_trade_session == src)
			first_trader.nexus_trade_session = null
			if(first_trader.client) first_trader << browse(null, "window=NexusTrade")
		if(second_trader && second_trader.nexus_trade_session == src)
			second_trader.nexus_trade_session = null
			if(second_trader.client) second_trader << browse(null, "window=NexusTrade")
		..()

	proc/isParticipant(mob/player)
		return player && (player == trader_a || player == trader_b) && player.nexus_trade_session == src

	proc/getPartner(mob/player)
		if(player == trader_a) return trader_b
		if(player == trader_b) return trader_a

	proc/getOffer(mob/player)
		if(player == trader_a) return offer_a
		if(player == trader_b) return offer_b
		return list()

	proc/unlockOfferedItems()
		for(var/obj/items/item in offer_a) if(item) item.setNexusTradeInteractionLocked(FALSE)
		for(var/obj/items/item in offer_b) if(item) item.setNexusTradeInteractionLocked(FALSE)

	proc/getResourceOffer(mob/player)
		if(player == trader_a) return resources_a
		if(player == trader_b) return resources_b
		return 0

	proc/getEssenceOffer(mob/player)
		if(player == trader_a) return essence_a
		if(player == trader_b) return essence_b
		return 0

	proc/isAccepted(mob/player)
		if(player == trader_a) return accepted_a
		if(player == trader_b) return accepted_b
		return FALSE

	proc/isFinalConfirmed(mob/player)
		if(player == trader_a) return final_a
		if(player == trader_b) return final_b
		return FALSE

	proc/playersAreNearby()
		if(!trader_a || !trader_b) return FALSE
		var/turf/first_location = trader_a.base_loc()
		var/turf/second_location = trader_b.base_loc()
		return first_location && second_location && first_location.z == second_location.z && get_dist(first_location, second_location) <= 2

	proc/getSessionError(require_joined = TRUE)
		if(!trader_a || !trader_b) return "A trader is no longer available."
		if(trader_a == trader_b) return "A character cannot trade with themselves."
		if(trader_a.nexus_trade_session != src || trader_b.nexus_trade_session != src) return "One trader is already in another trade."
		if(!trader_a.client || !trader_b.client || !trader_a.playerCharacter || !trader_b.playerCharacter) return "A trader disconnected or left their character."
		if(!playersAreNearby()) return "Both traders must remain within two tiles of each other."
		if(trader_a.Final_Realm() || trader_b.Final_Realm()) return "Items cannot be traded in the final realm."
		if(require_joined && !invitation_accepted) return "The trade invitation has not been accepted."
		return null

	proc/getItemError(obj/items/item, mob/owner)
		if(!item || !owner) return "The offered item no longer exists."
		if(item.loc != owner || !(item in owner.item_list)) return "[item] is no longer carried by [owner]."
		if(!item.Givable) return "[item] is bound and cannot be transferred."
		if(item.suffix == "Equipped" || item.suffix == "Installed") return "[item] must be unequipped or uninstalled before it can be traded."
		if(item.suffix && !item.Can_Drop_With_Suffix) return "[item] cannot be transferred while its current status is active."
		if(istype(item, /obj/items/Force_Field)) return "Force fields cannot be transferred directly between players."
		var/unsafe_interaction_reason = getNexusTradeUnsafeLegacyInteractionReason(item)
		if(unsafe_interaction_reason) return unsafe_interaction_reason
		var/item_graph_error = getNexusTradeItemGraphError(item)
		if(item_graph_error) return "[item] cannot be securely traded: [item_graph_error]"
		if(istype(item, /obj/items/Android_Blueprint))
			var/obj/items/Android_Blueprint/blueprint = item
			if(blueprint.Body)
				var/blueprint_content_error = getNexusTradeItemGraphError(blueprint.Body)
				if(blueprint_content_error) return "[item]'s stored design cannot be securely traded: [blueprint_content_error]"
				var/blueprint_list_error = getNexusTradeBlueprintSavedListsError(blueprint)
				if(blueprint_list_error) return "[item]'s stored design cannot be securely traded: [blueprint_list_error]"
		return null

	proc/getOfferError()
		var/session_error = getSessionError(TRUE)
		if(session_error) return session_error
		if(!nexusIsFiniteNumber(resources_a) || !nexusIsFiniteNumber(resources_b) || resources_a < 0 || resources_b < 0 || resources_a != round(resources_a) || resources_b != round(resources_b)) return "The resource offer is invalid."
		if(!nexusIsFiniteNumber(essence_a) || !nexusIsFiniteNumber(essence_b) || essence_a < 0 || essence_b < 0 || essence_a != round(essence_a, 0.1) || essence_b != round(essence_b, 0.1)) return "The Arcane Essence offer is invalid."
		if(resources_a > trader_a.Res()) return "[trader_a] no longer has [Commas(resources_a)] offered resources."
		if(resources_b > trader_b.Res()) return "[trader_b] no longer has [Commas(resources_b)] offered resources."
		if(essence_a > trader_a.arcane_essence) return "[trader_a] no longer has [formatNexusTradeEssence(essence_a)] offered Arcane Essence."
		if(essence_b > trader_b.arcane_essence) return "[trader_b] no longer has [formatNexusTradeEssence(essence_b)] offered Arcane Essence."
		if((resources_a || resources_b) && (!trader_a.GetResourceObject() || !trader_b.GetResourceObject())) return "A trader's resource bag is unavailable."
		var/list/seen_items = list()
		for(var/item_entry in offer_a)
			var/obj/items/offered_item = item_entry
			if(!offered_item) return "An offered item no longer exists."
			if(offered_item in seen_items) return "An item appears more than once in the trade."
			seen_items += offered_item
			var/item_error = getItemError(offered_item, trader_a)
			if(item_error) return item_error
		for(var/item_entry in offer_b)
			var/obj/items/offered_item = item_entry
			if(!offered_item) return "An offered item no longer exists."
			if(offered_item in seen_items) return "An item appears more than once in the trade."
			seen_items += offered_item
			var/item_error = getItemError(offered_item, trader_b)
			if(item_error) return item_error
		var/first_count_after_trade = trader_a.item_count() - offer_a.len + offer_b.len
		var/second_count_after_trade = trader_b.item_count() - offer_b.len + offer_a.len
		if(first_count_after_trade > trader_a.MaxItems()) return "[trader_a] would exceed their inventory limit."
		if(second_count_after_trade > trader_b.MaxItems()) return "[trader_b] would exceed their inventory limit."
		return null

	proc/getOfferFingerprint()
		var/list/parts = list("a_resources=[resources_a]", "b_resources=[resources_b]", "a_essence=[essence_a]", "b_essence=[essence_b]")
		for(var/obj/items/item in offer_a) parts += "a_item=[getNexusTradeItemFingerprint(item)]"
		for(var/obj/items/item in offer_b) parts += "b_item=[getNexusTradeItemFingerprint(item)]"
		return md5(jointext(parts, "\n"))

	proc/resetConfirmations(reason)
		revision++
		accepted_a = FALSE
		accepted_b = FALSE
		final_a = FALSE
		final_b = FALSE
		confirmation_revision = 0
		confirmation_fingerprint = null
		if(invitation_accepted) phase = "offer"
		last_error = reason

	proc/pruneDeletedOffers()
		var/changed = FALSE
		for(var/index = offer_a.len, index >= 1, index--)
			if(!offer_a[index])
				offer_a.Cut(index, index + 1)
				changed = TRUE
		for(var/index = offer_b.len, index >= 1, index--)
			if(!offer_b[index])
				offer_b.Cut(index, index + 1)
				changed = TRUE
		if(changed) resetConfirmations("A deleted item was removed from the offers; both traders must accept again.")

	proc/setAccepted(mob/player, value)
		if(player == trader_a) accepted_a = value
		else if(player == trader_b) accepted_b = value

	proc/setFinalConfirmed(mob/player, value)
		if(player == trader_a) final_a = value
		else if(player == trader_b) final_b = value

	proc/addItem(mob/player, obj/items/item)
		if(phase != "offer" || !isParticipant(player)) return FALSE
		var/item_error = getItemError(item, player)
		if(item_error)
			player << item_error
			return FALSE
		var/list/my_offer = getOffer(player)
		if(item in my_offer) return FALSE
		my_offer += item
		item.setNexusTradeInteractionLocked(TRUE)
		resetConfirmations("[player] changed their offered items; both acceptances were cleared.")
		return TRUE

	proc/removeItem(mob/player, obj/items/item)
		if(phase != "offer" || !isParticipant(player)) return FALSE
		var/list/my_offer = getOffer(player)
		if(!(item in my_offer)) return FALSE
		my_offer -= item
		item.setNexusTradeInteractionLocked(FALSE)
		resetConfirmations("[player] changed their offered items; both acceptances were cleared.")
		return TRUE

	proc/setCurrencyOffer(mob/player, currency, amount)
		if(phase != "offer" || !isParticipant(player)) return FALSE
		if(!nexusIsFiniteNumber(amount) || amount < 0)
			player << "Trade offers cannot contain negative or non-finite amounts."
			return FALSE
		if(currency == "resources")
			amount = round(amount)
			if(amount > player.Res())
				player << "You only have [Commas(player.Res())] resources."
				return FALSE
			if(amount == getResourceOffer(player)) return TRUE
			if(player == trader_a) resources_a = amount
			else resources_b = amount
		else if(currency == "essence")
			amount = round(amount, 0.1)
			if(amount > player.arcane_essence)
				player << "You only have [formatNexusTradeEssence(player.arcane_essence)] Arcane Essence."
				return FALSE
			if(amount == getEssenceOffer(player)) return TRUE
			if(player == trader_a) essence_a = amount
			else essence_b = amount
		else return FALSE
		resetConfirmations("[player] changed their currency offer; both acceptances were cleared.")
		return TRUE

	proc/acceptTerms(mob/player)
		if(phase != "offer" || !isParticipant(player)) return FALSE
		var/offer_error = getOfferError()
		if(offer_error)
			last_error = offer_error
			player << offer_error
			return FALSE
		setAccepted(player, TRUE)
		last_error = null
		if(accepted_a && accepted_b)
			phase = "confirm"
			confirmation_revision = revision
			confirmation_fingerprint = getOfferFingerprint()
			final_a = FALSE
			final_b = FALSE
		return TRUE

	proc/getPlainOfferSummary(mob/player)
		var/list/my_offer = getOffer(player)
		var/list/item_summaries = list()
		for(var/obj/items/item in my_offer) item_summaries += "[item] ([item.type], seal [copytext(getNexusTradeItemFingerprint(item), 1, 13)])"
		var/items_text = item_summaries.len ? jointext(item_summaries, ", ") : "no items"
		return "[items_text]; [Commas(getResourceOffer(player))] resources; [formatNexusTradeEssence(getEssenceOffer(player))] Arcane Essence"

	proc/rollbackMovedItems(list/moved_from_a, list/moved_from_b)
		for(var/obj/items/item in moved_from_a)
			if(item && trader_a) item.Move(trader_a)
		for(var/obj/items/item in moved_from_b)
			if(item && trader_b) item.Move(trader_b)

	proc/commitTrade()
		if(committing || phase != "confirm" || !final_a || !final_b) return FALSE
		committing = TRUE
		var/offer_error = getOfferError()
		var/current_fingerprint = getOfferFingerprint()
		if(!offer_error && (revision != confirmation_revision || current_fingerprint != confirmation_fingerprint)) offer_error = "The accepted offer changed before completion. Both traders must review it again."
		if(offer_error)
			committing = FALSE
			resetConfirmations(offer_error)
			if(trader_a) trader_a << offer_error
			if(trader_b) trader_b << offer_error
			showBoth()
			return FALSE
		var/mob/first_trader = trader_a
		var/mob/second_trader = trader_b
		var/first_summary = getPlainOfferSummary(first_trader)
		var/second_summary = getPlainOfferSummary(second_trader)
		var/list/items_from_a = offer_a.Copy()
		var/list/items_from_b = offer_b.Copy()
		var/list/moved_from_a = list()
		var/list/moved_from_b = list()
		var/first_skip_restore_hotbar = trader_a.skip_restore_hotbar
		var/second_skip_restore_hotbar = trader_b.skip_restore_hotbar
		trader_a.skip_restore_hotbar = TRUE
		trader_b.skip_restore_hotbar = TRUE
		for(var/obj/items/item in items_from_a)
			item.Move(trader_b)
			if(item.loc != trader_b)
				rollbackMovedItems(moved_from_a, moved_from_b)
				trader_a.skip_restore_hotbar = first_skip_restore_hotbar
				trader_b.skip_restore_hotbar = second_skip_restore_hotbar
				trader_a.Restore_hotbar_from_IDs()
				trader_b.Restore_hotbar_from_IDs()
				committing = FALSE
				resetConfirmations("An item could not be transferred; no currency changed.")
				showBoth()
				return FALSE
			moved_from_a += item
		for(var/obj/items/item in items_from_b)
			item.Move(trader_a)
			if(item.loc != trader_a)
				rollbackMovedItems(moved_from_a, moved_from_b)
				trader_a.skip_restore_hotbar = first_skip_restore_hotbar
				trader_b.skip_restore_hotbar = second_skip_restore_hotbar
				trader_a.Restore_hotbar_from_IDs()
				trader_b.Restore_hotbar_from_IDs()
				committing = FALSE
				resetConfirmations("An item could not be transferred; no currency changed.")
				showBoth()
				return FALSE
			moved_from_b += item
		var/obj/Resources/first_resources = trader_a.GetResourceObject()
		var/obj/Resources/second_resources = trader_b.GetResourceObject()
		if(first_resources && second_resources)
			first_resources.Value = first_resources.Value - resources_a + resources_b
			second_resources.Value = second_resources.Value - resources_b + resources_a
			first_resources.Update_value()
			second_resources.Update_value()
		trader_a.arcane_essence = round(trader_a.arcane_essence - essence_a + essence_b, 0.1)
		trader_b.arcane_essence = round(trader_b.arcane_essence - essence_b + essence_a, 0.1)
		trader_a.skip_restore_hotbar = first_skip_restore_hotbar
		trader_b.skip_restore_hotbar = second_skip_restore_hotbar
		trader_a.Restore_hotbar_from_IDs()
		trader_b.Restore_hotbar_from_IDs()
		trader_a.rebuildPlayerAppearance("secure trade completed")
		trader_b.rebuildPlayerAppearance("secure trade completed")
		Log(trader_a, "SECURE TRADE COMPLETE: [trader_a.key] offered [first_summary]; [trader_b.key] offered [second_summary]. Offer revision [revision], seal [current_fingerprint].")
		first_trader << "<font color=#9ee6a8><b>Trade complete.</b> You gave [first_summary] and received [second_summary]."
		second_trader << "<font color=#9ee6a8><b>Trade complete.</b> You gave [second_summary] and received [first_summary]."
		committing = FALSE
		del(src)
		return TRUE

	proc/cancelTrade(reason = "The trade was cancelled.")
		var/mob/first_trader = trader_a
		var/mob/second_trader = trader_b
		if(first_trader) first_trader << reason
		if(second_trader) second_trader << reason
		del(src)

	proc/monitorSession()
		set waitfor = FALSE
		while(trader_a && trader_b)
			sleep(10)
			if(committing) continue
			var/session_error = getSessionError(FALSE)
			if(session_error)
				cancelTrade(session_error)
				return

	proc/buildOfferPanel(mob/side, mob/viewer)
		var/list/my_offer = getOffer(side)
		var/side_name = html_encode("[side]")
		var/acceptance_class = isAccepted(side) ? "accepted" : ""
		var/acceptance_text = isAccepted(side) ? "TERMS ACCEPTED" : "REVIEWING"
		var/html = "<section class='offer-panel hud-frame'><div class='offer-title'><div><small class='hud-label'>TRADER</small><h2>[side_name]</h2></div><span class='status [acceptance_class]'>[acceptance_text]</span></div>"
		html += "<div class='currency-grid'><div><small>RESOURCES</small><b>[Commas(getResourceOffer(side))]</b></div><div><small>ARCANE ESSENCE</small><b>[formatNexusTradeEssence(getEssenceOffer(side))]</b></div></div>"
		if(phase == "offer" && side == viewer)
			html += "<div class='currency-actions'><a class='hud-button' href='byond://?src=\ref[src]&action=set_currency&currency=resources'>SET RESOURCES</a><a class='hud-button' href='byond://?src=\ref[src]&action=set_currency&currency=essence'>SET ESSENCE</a></div>"
		html += "<h3>OFFERED ITEMS ([my_offer.len])</h3><div class='offered-items'>"
		if(!my_offer.len) html += "<div class='empty compact'>No items offered.</div>"
		for(var/obj/items/item in my_offer)
			var/remove_link = phase == "offer" && side == viewer ? "<a class='hud-button danger' href='byond://?src=\ref[src]&action=remove_item&item=\ref[item]'>REMOVE</a>" : ""
			var/item_name = html_encode("[item]")
			html += "<article class='trade-item'><div class='trade-item-title'><b>[item_name]</b>[remove_link]</div>[getNexusTradeItemDisclosure(item)]</article>"
		html += "</div></section>"
		return html

	proc/buildInventoryPicker(mob/viewer)
		if(phase != "offer") return ""
		var/list/my_offer = getOffer(viewer)
		var/html = "<section class='inventory-panel hud-frame'><div class='section-heading'><div><small class='hud-label'>YOUR INVENTORY</small><h2>Add items to your offer</h2></div><span>[viewer.item_count()] / [viewer.MaxItems()] slots</span></div><div class='inventory-grid'>"
		var/item_count = 0
		for(var/obj/items/item in viewer.item_list)
			if(item in my_offer) continue
			item_count++
			var/item_error = getItemError(item, viewer)
			var/action = item_error ? "<span class='blocked'>[html_encode(item_error)]</span>" : "<a class='hud-button' href='byond://?src=\ref[src]&action=add_item&item=\ref[item]'>ADD</a>"
			var/item_name = html_encode("[item]")
			var/item_type = html_encode("[item.type]")
			html += "<article class='inventory-item'><div><b>[item_name]</b><small>[item_type]</small></div>[action]</article>"
		if(!item_count) html += "<div class='empty'>No additional carried items are available.</div>"
		html += "</div></section>"
		return html

	proc/buildHtml(mob/viewer)
		var/mob/partner = getPartner(viewer)
		var/phase_label = phase == "invite" ? "INVITATION" : phase == "offer" ? "OFFER REVIEW / REVISION [revision]" : "FINAL CONFIRMATION / REVISION [revision]"
		var/viewer_name = html_encode("[viewer]")
		var/partner_name = html_encode("[partner]")
		var/first_trader_name = html_encode("[trader_a]")
		var/second_trader_name = html_encode("[trader_b]")
		var/html = {"<!doctype html><html><head><meta charset='utf-8'><title>Secure Trade</title><style>
		*{box-sizing:border-box}html,body{margin:0;min-height:100%;font:12px 'Courier New',monospace}.shell{min-height:100vh;padding:10px}.trade-header{padding:10px;border:2px solid #755a36;background:#21190f}.header-row,.offer-title,.section-heading,.trade-item-title{display:flex;align-items:center;gap:8px}.header-row>div:first-child,.offer-title>div:first-child,.section-heading>div:first-child{margin-right:auto}.header-row h1,.offer-title h2,.section-heading h2{margin:3px 0;color:#f0d79e}.notice{margin-top:8px;padding:8px;border:2px solid #684e2f;background:#2a2117;color:#d9c49b}.notice.error{border-color:#9a4f3c;color:#ffb09c}.actions{display:flex;flex-wrap:wrap;gap:6px;margin-top:9px}.offers{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:8px;margin-top:8px}.offer-panel,.inventory-panel{padding:9px;border:2px solid #684e2f;background:#21190f}.status{padding:5px 7px;border:2px solid #6f5333;color:#b9a37c}.status.accepted{border-color:#527a4d;color:#9ee6a8}.currency-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:5px;margin:8px 0}.currency-grid div{padding:8px;border:2px solid #624b30;background:#2a2117}.currency-grid small,.currency-grid b{display:block}.currency-grid b{margin-top:4px;color:#f0d79e}.currency-actions{display:flex;gap:5px;margin-bottom:9px}.offer-panel h3{margin:10px 0 6px;color:#c69c57;font-size:11px}.trade-item{margin-bottom:6px;padding:8px;border:2px solid #624b30;background:#2a2117}.trade-item-title{margin-bottom:6px}.trade-item-title>b{margin-right:auto;color:#f0d79e}.item-facts span{display:block;margin:2px 0;color:#b9a37c;line-height:1.35}.item-facts span b{color:#d5b878}.blueprint{margin-top:7px;padding:7px;border:2px solid #85652e;background:#17120d}.blueprint b,.blueprint span{display:block}.blueprint b{color:#e5bd66}.blueprint span{margin-top:4px;color:#d8c08e;line-height:1.45}.blueprint.blank{border-color:#78503a}.module-list{margin-top:7px}.module-details{margin-top:5px;padding:6px;border:1px solid #6f5a38;background:#21190f}.module-details>b{color:#f0d79e}.module-details span{font-size:10px}.inventory-panel{margin-top:8px}.inventory-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:5px;margin-top:7px}.inventory-item{display:flex;align-items:center;gap:7px;padding:7px;border:2px solid #624b30;background:#2a2117}.inventory-item>div{min-width:0;margin-right:auto}.inventory-item b,.inventory-item small{display:block;overflow-wrap:anywhere}.inventory-item b{color:#e6cf9d}.inventory-item small{margin-top:3px;color:#9e8865}.blocked{max-width:48%;color:#d88973;font-size:9px;text-align:right}.empty{padding:22px;text-align:center;color:#9e8865}.empty.compact{padding:12px}.seal{color:#e5bd66}[getNexusHudBrowserCss("bronze")]@media(max-width:800px){.offers{grid-template-columns:1fr}.inventory-grid{grid-template-columns:1fr}}
		</style></head><body class='nexus-hud'><main class='shell hud-shell'><header class='trade-header hud-frame'><div class='header-row'><div><small class='hud-label'>SECURE PLAYER TRADE</small><h1>[phase_label]</h1><span>You: [viewer_name] / Partner: [partner_name]</span></div><a class='hud-button danger' href='byond://?src=\ref[src]&action=cancel'>CANCEL TRADE</a></div>"}
		if(last_error) html += "<div class='notice error'>[html_encode(last_error)]</div>"
		if(phase == "invite")
			var/invitation_text
			if(viewer == trader_b) invitation_text = "[first_trader_name] invited you to a secure trade. Nothing transfers until both players accept the same offer and separately finalize it."
			else invitation_text = "Waiting for [second_trader_name] to accept the invitation."
			html += "<div class='notice'>[invitation_text]</div>"
			if(viewer == trader_b) html += "<div class='actions'><a class='hud-button' href='byond://?src=\ref[src]&action=accept_invite'>BEGIN TRADE</a><a class='hud-button danger' href='byond://?src=\ref[src]&action=cancel'>DECLINE</a></div>"
			html += "</header></main></body></html>"
			return html
		if(phase == "offer")
			html += "<div class='notice'>Every offer change clears both acceptances. Exact item types, values, descriptions, statuses, blueprint contents, and state seals are shown below.</div><div class='actions'>"
			if(isAccepted(viewer)) html += "<a class='hud-button danger' href='byond://?src=\ref[src]&action=withdraw_acceptance'>WITHDRAW ACCEPTANCE</a>"
			else html += "<a class='hud-button' href='byond://?src=\ref[src]&action=accept_terms'>ACCEPT REVISION [revision]</a>"
			html += "</div>"
		else
			var/final_seal = copytext(confirmation_fingerprint, 1, 13)
			html += "<div class='notice'><b>FINAL CHECK:</b> both players accepted revision [confirmation_revision]. Confirm only after checking the complete offers again. Sealed offer: <span class='seal'>[final_seal]</span>.</div><div class='actions'>"
			if(isFinalConfirmed(viewer)) html += "<span class='status accepted'>FINAL CONFIRMED / WAITING</span>"
			else html += "<a class='hud-button' href='byond://?src=\ref[src]&action=final_confirm'>FINALIZE SEALED TRADE</a>"
			html += "<a class='hud-button danger' href='byond://?src=\ref[src]&action=edit_offer'>EDIT / REJECT TERMS</a></div>"
		html += "</header><div class='offers'>[buildOfferPanel(trader_a, viewer)][buildOfferPanel(trader_b, viewer)]</div>[buildInventoryPicker(viewer)]</main></body></html>"
		return html

	proc/showTo(mob/viewer)
		if(!isParticipant(viewer) || !viewer.client) return
		pruneDeletedOffers()
		viewer << browse(buildHtml(viewer), "window=NexusTrade;size=1120x780;can_resize=true;can_close=true")

	proc/showBoth()
		if(trader_a && trader_a.client) showTo(trader_a)
		if(trader_b && trader_b.client) showTo(trader_b)

	Topic(href, list/href_list)
		if(!isParticipant(usr)) return
		if(committing) return
		var/mob/player = usr
		var/action = href_list["action"]
		if(action == "cancel")
			cancelTrade("[player] cancelled the secure trade.")
			return
		var/session_error = getSessionError(FALSE)
		if(session_error)
			cancelTrade(session_error)
			return
		if(action == "accept_invite")
			if(player != trader_b || phase != "invite") return
			invitation_accepted = TRUE
			phase = "offer"
			last_error = null
			showBoth()
			return
		if(!invitation_accepted) return
		switch(action)
			if("add_item")
				var/obj/items/item_to_add = locate(href_list["item"])
				addItem(player, item_to_add)
			if("remove_item")
				var/obj/items/item_to_remove = locate(href_list["item"])
				removeItem(player, item_to_remove)
			if("set_currency")
				if(phase != "offer") return
				var/currency = href_list["currency"]
				var/current_amount = currency == "resources" ? getResourceOffer(player) : getEssenceOffer(player)
				var/available_amount = currency == "resources" ? player.Res() : player.arcane_essence
				var/currency_label = currency == "resources" ? "resources" : "Arcane Essence"
				var/available_text = currency == "resources" ? Commas(available_amount) : formatNexusTradeEssence(available_amount)
				var/amount = input(player, "Offer how much [currency_label]? Available: [available_text]. Any change clears both acceptances.", "Secure Trade", current_amount) as null|num
				if(isnull(amount) || !isParticipant(player) || phase != "offer") return
				setCurrencyOffer(player, currency, amount)
			if("accept_terms")
				acceptTerms(player)
			if("withdraw_acceptance")
				if(phase == "offer")
					setAccepted(player, FALSE)
					last_error = "[player] withdrew their acceptance."
			if("edit_offer")
				if(phase == "confirm") resetConfirmations("[player] reopened the offer; both traders must accept the new revision.")
			if("final_confirm")
				if(phase != "confirm") return
				if(revision != confirmation_revision || getOfferFingerprint() != confirmation_fingerprint)
					resetConfirmations("The offer changed after acceptance; both traders must review it again.")
				else
					var/offer_error = getOfferError()
					if(offer_error)
						resetConfirmations(offer_error)
					else
						setFinalConfirmed(player, TRUE)
						if(final_a && final_b)
							commitTrade()
							return
		showBoth()

mob/verb/secureTrade()
	set name = "Trade"
	set category = "Other"
	if(!client || !playerCharacter) return
	if(nexus_trade_session)
		nexus_trade_session.showTo(src)
		return
	if(Final_Realm())
		src << "Items cannot be traded in the final realm."
		return
	var/list/nearby_traders = list()
	for(var/mob/player in oview(1, src))
		if(player == src || !player.client || !player.playerCharacter || player.nexus_trade_session) continue
		nearby_traders += player
	if(!nearby_traders.len)
		src << "There are no available players within one tile."
		return
	var/mob/partner = input(src, "Who do you want to invite to a secure trade?", "Secure Trade") as null|anything in nearby_traders
	if(!partner) return
	if(nexus_trade_session || partner.nexus_trade_session)
		src << "One of you is already in another trade."
		return
	var/turf/my_location = base_loc()
	var/turf/their_location = partner.base_loc()
	if(!partner.client || !my_location || !their_location || my_location.z != their_location.z || get_dist(my_location, their_location) > 1)
		src << "That player is no longer close enough to trade."
		return
	var/datum/NexusTradeSession/trade = new(src, partner)
	src << "You invited [partner] to a secure trade."
	partner << "[src] invited you to a secure trade. Use Other > Trade if the window is closed."
	trade.showBoth()
