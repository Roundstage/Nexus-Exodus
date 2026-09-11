// Actions belong to character slots; keys activate a slot even when its action changes.
mob/var
	list/nexus_classic_slots
	list/nexus_classic_bars
	nexus_classic_next_bar = 1
	nexus_classic_bar_rows = 1
	nexus_classic_bar_columns = 12
	nexus_classic_bar_size = 40
	nexus_classic_bar_locked = FALSE

proc/classicNumericVar(datum/subject, key)
	if(!subject || !(key in subject.vars)) return 0
	return classicNumber(subject.vars[key])

obj/proc/getClassicCooldown(mob/user)
	var/deadline = classicNumericVar(src, "next_use")
	var/now = world.time
	var/duration = classicNumericVar(src, "cooldown_ticks")
	if(istype(src, /obj/Keep_Body))
		now = world.realtime
		duration = classicNumericVar(src, "hours_per_use") * 36000
	else if(istype(src, /obj/Kaio_Revive))
		now = world.realtime
		duration = classicNumericVar(src, "revive_delay") * 36000
	else if(istype(src, /obj/Noxian_Guillotine))
		now = world.realtime
		deadline = classicNumericVar(src, "cooldown")
		duration = 3000
	else if(istype(src, /obj/Ability)) duration = TickMult(classicNumericVar(src, "self_cooldown"))
	else if("self_cooldown" in vars) duration = classicNumericVar(src, "self_cooldown") * 10
	if(classicNumericVar(src, "next_beam_use") > deadline)
		deadline = max(deadline, classicNumericVar(src, "next_beam_use"))
		duration = beam_skill_cooldown_ticks
	if(istype(src, /obj/Giant_Form)) duration = 50
	if(istype(src, /obj/PressurePunch))
		deadline = user.last_pressurePunch + pressure_punch_cooldown_ticks
		duration = pressure_punch_cooldown_ticks
	if(istype(src, /obj/RockThrow))
		deadline = classicNumericVar(src, "spread_mode") ? 0 : user.last_RockThrow + 30
		duration = 30
	if(istype(src, /obj/RockSlide))
		deadline = user.last_RockSlide + 120
		duration = 120
	if(istype(src, /obj/RockTomb))
		deadline = user.last_RockTomb + 150
		duration = 150
	if(istype(src, /obj/Dash_Attack))
		deadline = user.lastDashAttack ? user.lastDashAttack + 100 : 0
		duration = 100
	if(istype(src, /obj/Attacks/Sokidan))
		deadline = user.lastSokidan + 20
		duration = 20
	if(istype(src, /obj/WolfFangFist))
		deadline = user.last_WolfFangFist + 200
		duration = 200
	if(istype(src, /obj/Dropkick))
		deadline = user.last_dropkick + 300
		duration = 300
	if(istype(src, /obj/RoundhouseKick))
		deadline = user.last_RoundhouseKick + 120
		duration = 120
	if(istype(src, /obj/Attacks/Scatter_Shot))
		deadline = user.last_scattershot + 600
		duration = 600
	if(istype(src, /obj/Attacks/Shockwave))
		deadline = user.next_shockwave
		duration = 70 * user.Speed_delay_mult(severity = 0.25)
	if(istype(src, /obj/Attacks/Explosion))
		duration = 20 * user.Speed_delay_mult(severity = 0.35)
		deadline = classicNumericVar(src, "last_use") + duration
	if(istype(src, /obj/Hakai))
		duration = hakai_cooldown
		deadline = user.last_hakai_use + duration
	if(istype(src, /obj/Taiyoken))
		duration = 200
		deadline = user.last_solar_flare + duration
	if(istype(src, /obj/Lunge))
		duration = user.Lunge_refire()
		deadline = user.last_lunge_attack + duration
	if(istype(src, /obj/Flash_Step))
		duration = user.TapWarpCantMoveTime()
		deadline = user.last_tap_warp + duration
	if(istype(src, /obj/Buff) && user.current_buff != src)
		duration = 20
		deadline = world.time + user.rebuff_timer * 10
	if(("Next_Use" in vars) && classicNumericVar(src, "Next_Use") > Year)
		return list("remaining" = 0, "duration" = 0, "label" = "Year [round(classicNumericVar(src, "Next_Use"), 0.1)]")
	return list("remaining" = max(0, deadline - now) / 10, "duration" = max(0, duration) / 10)

obj/proc/getClassicSkillState(mob/user)
	var/list/result = getClassicCooldown(user)
	var/remaining = result["remaining"]
	var/state = "ready"
	var/label = "Ready"
	if(result["label"])
		state = "cooldown"
		label = result["label"]
	else if(remaining > 0)
		state = "cooldown"
		label = "[round(remaining, 0.1)]s"
	else if(!user.isNexusHotkeyObjectAvailable(src) || user.KO || user.input_disabled)
		state = "unavailable"
		label = "Unavailable"
	else if(user.current_buff == src || (istype(src, /obj/Giant_Form) && user.using_giant_form) || (classicNumericVar(src, "using")))
		state = "active"
		label = "Active"
	else if(classicNumericVar(src, "charging"))
		state = "active"
		label = "Charging"
	else if(("stance_id" in vars) && vars["stance_id"] == user.active_nexus_stance_id && (!user.active_nexus_stance_until || user.active_nexus_stance_until > world.time))
		state = "active"
		label = "Stance"
	else
		var/drain = 0
		if("energy_cost" in vars)
			var/is_energy = !istype(src, /obj/Attacks/NexusMeleeTechnique)
			if("physical_damage" in vars) is_energy = !vars["physical_damage"]
			drain = user.GetSkillDrain(mod = classicNumericVar(src, "energy_cost"), is_energy = is_energy)
		else if("Drain" in vars) drain = user.GetSkillDrain(mod = classicNumericVar(src, "Drain"), is_energy = 1)
		if(drain > user.Ki)
			state = "resource"
			label = "Low energy"
	result["state"] = state
	result["label"] = label
	return result

mob/proc/classicBindingForObject(obj/skill)
	if(!skill || !isNexusHotkeyObjectAvailable(skill)) return null
	if(!skill.hotbar_id) skill.hotbar_id = Assign_hotbar_ID()
	return list("kind" = "object", "object id" = skill.hotbar_id, "object type" = skill.type, "display name" = "[skill]")

mob/proc/initializeClassicSlots()
	nexus_classic_bar_rows = Clamp(round(classicNumber(nexus_classic_bar_rows, 1)), 1, 3)
	nexus_classic_bar_columns = max(1, round(classicNumber(nexus_classic_bar_columns, 12)))
	nexus_classic_bar_size = Clamp(round(classicNumber(nexus_classic_bar_size, 40)), 32, 64)
	if(islist(nexus_classic_slots))
		return
	nexus_classic_slots = list()
	nexus_classic_slots.len = 12
	var/index = 0
	var/list/used = list()
	populateClassicDefaultSlots()
	for(var/position in 1 to nexus_classic_slots.len)
		var/list/default_binding = nexus_classic_slots[position]
		if(!islist(default_binding)) continue
		index = position
		var/default_object = resolveClassicBinding(default_binding)
		if(isobj(default_object)) used += default_object
	for(var/combination in nexus_hotkey_bindings)
		var/list/binding = nexus_hotkey_bindings[combination]
		if(!islist(binding) || binding["kind"] == "slot") continue
		var/obj/skill = resolveNexusHotkeyBinding(combination)
		if(!isobj(skill) || skill.is_for_moving || (skill in used)) continue
		nexus_classic_slots[++index] = binding.Copy()
		used += skill
		if(index >= nexus_classic_slots.len) break
	if(index < nexus_classic_slots.len)
		for(var/obj/skill in src)
			if(!isNexusHotkeyObjectAvailable(skill) || skill.is_for_moving || !hascall(skill, "Hotbar_use") || (skill in used)) continue
			nexus_classic_slots[++index] = classicBindingForObject(skill)
			if(index >= nexus_classic_slots.len) break

// The Classic HUD can be constructed before the legacy key table has finished
// migrating. Fill that initially empty bar once the bindings are available,
// while leaving every player-customized bar untouched.
mob/proc/populateClassicDefaultSlots()
	if(!islist(nexus_classic_slots) || !islist(nexus_hotkey_bindings)) return
	for(var/list/existing_binding in nexus_classic_slots)
		if(islist(existing_binding)) return
	var/index = 0
	var/list/used = list()
	for(var/base_key in keys)
		var/list/binding = nexus_hotkey_bindings[base_key]
		if(!islist(binding) || binding["kind"] == "slot") continue
		var/obj/hotkey_object = resolveNexusHotkeyBinding(base_key)
		if(!isobj(hotkey_object) || hotkey_object.is_for_moving || (hotkey_object in used)) continue
		nexus_classic_slots[++index] = binding.Copy()
		used += hotkey_object
		if(index >= nexus_classic_slots.len) break

mob/proc/resolveClassicSlot(index)
	initializeClassicSlots()
	if(!isnum(index) || index != round(index) || index < 1 || index > nexus_classic_slots.len) return null
	var/list/binding = nexus_classic_slots[index]
	if(!islist(binding)) return null
	return resolveClassicBinding(binding)

mob/proc/buildClassicActionBar(all_slots = FALSE, bar_id = "bar", page = 0)
	initializeClassicSlots()
	var/list/result = list()
	initializeClassicBars()
	var/list/bar = nexus_classic_bars[bar_id]
	if(!islist(bar)) return result
	var/list/indexes = bar["slots"]
	var/start = page ? (page - 1) * 12 + 1 : 1
	var/end = page ? min(indexes.len, start + 11) : indexes.len
	if(end < start) return result
	var/list/slot_keys = buildClassicSlotKeyMap()
	for(var/position in start to end)
		var/index = indexes[position]
		var/list/binding = nexus_classic_slots[index]
		var/skill = resolveClassicSlot(index)
		var/list/entry = list("slot" = index, "position" = position, "name" = islist(binding) ? binding["display name"] : "Empty slot", "key" = "", "state" = islist(binding) ? "unavailable" : "empty", "label" = islist(binding) ? "Unavailable" : "Assign skill")
		entry["key"] = slot_keys["[index]"] ? slot_keys["[index]"] : ""
		if(skill)
			if(isobj(skill))
				var/obj/object = skill
				var/list/state = object.getClassicSkillState(src)
				for(var/key in state) entry[key] = state[key]
				entry["name"] = "[object]"
				if(getNexusSkillArtworkFile(object.type) || (object.icon && (object.icon_state in icon_states(object.icon)))) entry["icon"] = getNexusBrowserAtomIconResource(src, object)
				entry["fallback"] = !entry["icon"]
				if(!entry["icon"]) entry["icon"] = getNexusPixelInterfaceIconResource(src, getNexusSkillInterfaceIconKind(object.hotbar_type))
			else
				entry["icon"] = getNexusBindingSkillArtworkResource(src, binding)
				entry["fallback"] = !entry["icon"]
				if(!entry["icon"]) entry["icon"] = getNexusPixelInterfaceIconResource(src, "skills")
				entry["state"] = "ready"
				entry["label"] = "Ready"
				if(binding["kind"] == "verb")
					var/atom/source = resolveClassicVerbSource(binding)
					if(isobj(source))
						var/obj/object = source
						var/list/state = object.can_hotbar ? object.getClassicSkillState(src) : object.getClassicCooldown(src)
						for(var/key in state) entry[key] = state[key]
						if(state["remaining"] > 0)
							entry["state"] = "cooldown"
							entry["label"] = "[round(state["remaining"], 0.1)]s"
						if(getNexusSkillArtworkFile(object.type) || (object.icon && (object.icon_state in icon_states(object.icon))))
							entry["icon"] = getNexusBrowserAtomIconResource(src, object)
							entry["fallback"] = FALSE
		result += list(entry)
	return result

mob/proc/useClassicSlot(index)
	var/skill = resolveClassicSlot(index)
	if(skill) executeNexusHotkeyAction(skill)
	if(client) winset(src, "mapwindow.map", "focus=true")

mob/proc/assignClassicSlot(index, token)
	initializeClassicSlots()
	if(!isnum(index) || index != round(index) || index < 1 || index > nexus_classic_slots.len) return
	if(!token)
		showNexusHotkeyEditor(index, classicBarForSlot(index))
		return
	var/list/binding = classicBindingFromToken(token)
	if(!islist(binding) || !resolveClassicBinding(binding)) return
	nexus_classic_slots[index] = binding.Copy()
	classicBarChanged()

mob/proc/swapClassicSlots(first, second)
	initializeClassicSlots()
	if(!isnum(first) || !isnum(second) || first != round(first) || second != round(second) || min(first, second) < 1 || max(first, second) > nexus_classic_slots.len) return
	var/list/previous = nexus_classic_slots[first]
	nexus_classic_slots[first] = nexus_classic_slots[second]
	nexus_classic_slots[second] = previous
	classicBarChanged()

mob/proc/clearClassicSlot(index)
	initializeClassicSlots()
	if(isnum(index) && index == round(index) && index >= 1 && index <= nexus_classic_slots.len)
		nexus_classic_slots[index] = null
		classicBarChanged()

mob/proc/classicBarChanged()
	if(!client) return
	client.syncNexusHotkeyMacros()
	Hotkey_server_backup_save()
	if(client.nexus_classic_hud)
		client.nexus_classic_hud.dirty = TRUE
		client.nexus_classic_hud.refresh()

mob/proc/buildClassicSlotKeyMap()
	var/list/result = list()
	for(var/combination in nexus_hotkey_bindings)
		var/list/binding = nexus_hotkey_bindings[combination]
		if(!islist(binding) || binding["kind"] != "slot") continue
		var/slot_key = "[binding["slot"]]"
		result[slot_key] = result[slot_key] ? "[result[slot_key]] / [combination]" : combination
	return result

mob/proc/getClassicSlotKeys(index)
	var/list/result = list()
	for(var/combination in nexus_hotkey_bindings)
		var/list/binding = nexus_hotkey_bindings[combination]
		if(islist(binding) && binding["kind"] == "slot" && binding["slot"] == index) result += combination
	return jointext(result, " / ")

mob/proc/migrateClassicSlotKeys()
	if(nexus_classic_slot_keys_version || !nexus_hotkey_bindings.len) return
	initializeClassicSlots()
	// Convert only bindings whose actions are on this character's bar. Preserve all others.
	for(var/combination in nexus_hotkey_bindings)
		var/list/binding = nexus_hotkey_bindings[combination]
		if(!islist(binding) || binding["kind"] == "slot") continue
		var/resolved = resolveNexusHotkeyBinding(combination)
		if(!resolved) continue
		for(var/index in 1 to nexus_classic_slots.len)
			if(resolveClassicSlot(index) != resolved) continue
			nexus_hotkey_bindings[combination] = list("kind" = "slot", "slot" = index)
			break
	nexus_classic_slot_keys_version = 1
	Hotkey_server_backup_save()

mob/proc/resolveClassicBinding(list/binding)
	if(!islist(binding)) return
	if(binding["kind"] == "object") return resolveNexusHotkeyObject(binding)
	if(binding["kind"] == "action")
		var/datum/NexusHotkeyAction/action = getNexusHotkeyAction(binding["action id"])
		if(action && action.isAvailable(src)) return action
	if(binding["kind"] == "verb" && resolveClassicVerbSource(binding))
		var/datum/NexusHotkeyAction/ClassicVerb/action = new
		action.binding = binding.Copy()
		return action

mob/proc/resolveClassicVerbSource(list/binding)
	if(!islist(binding) || binding["kind"] != "verb") return
	var/path = text2path(binding["verb"])
	var/list/metadata = nexus_classic_command_catalog[binding["verb"]]
	if(!path || !islist(metadata) || isnull(metadata[2])) return
	if(lowertext(metadata[2]) == "admin" && !IsAdmin()) return
	if(binding["source"] == "mob") return (path in verbs) ? src : null
	for(var/obj/object in src)
		// Object verbs are tied to that owned item, never to an arbitrary client ref.
		if(object.hotbar_id != binding["object id"] || "[object.type]" != binding["object type"] || !(path in object.verbs)) continue
		if(istype(object, /obj/items))
			var/obj/items/item = object
			if(item.isNexusTradeOfferedBy(src)) return
		return object

datum/NexusHotkeyAction/ClassicVerb
	var/list/binding

	isAvailable(mob/user)
		return !!user.resolveClassicVerbSource(binding)

	execute(mob/user)
		if(!user.client || !isAvailable(user)) return FALSE
		var/list/metadata = nexus_classic_command_catalog[binding["verb"]]
		// BYOND prompts for declared arguments and enforces the verb's native permissions.
		winset(user, null, list2params(list("command" = replacetext(metadata[1], " ", "-"))))
		return TRUE

mob/proc/classicBindingFromToken(token)
	if(!istext(token)) return
	if(findtext(token, "classic-skill:") == 1) token = copytext(token, 15)
	if(findtext(token, "classic-action:") == 1)
		var/datum/NexusHotkeyAction/action = getNexusHotkeyAction(copytext(token, 16))
		if(action && action.isAvailable(src)) return list("kind" = "action", "action id" = action.action_id, "display name" = action.display_name)
	if(findtext(token, "classic-command:") == 1) token = copytext(token, 17)
	for(var/obj/object in src)
		if(token == "\ref[object]" && isNexusHotkeyObjectAvailable(object) && (hascall(object, "Hotbar_use") || istype(object, /obj/items))) return classicBindingForObject(object)
	var/list/sources = list(src)
	for(var/obj/object in src) sources += object
	for(var/atom/source in sources)
		for(var/path in source.verbs)
			if(md5("\ref[source]|[path]") != token) continue
			var/list/metadata = nexus_classic_command_catalog["[path]"]
			if(!islist(metadata) || isnull(metadata[2])) return
			var/list/binding = list("kind" = "verb", "verb" = "[path]", "source" = source == src ? "mob" : "object", "display name" = metadata[1])
			if(isobj(source))
				var/obj/object = source
				if(!object.hotbar_id) object.hotbar_id = Assign_hotbar_ID()
				binding["object id"] = object.hotbar_id
				binding["object type"] = "[object.type]"
			if(resolveClassicVerbSource(binding)) return binding

mob/proc/buildClassicActionCatalog()
	var/list/result = list()
	initializeNexusHotkeyActionRegistry()
	for(var/action_id in nexus_hotkey_action_registry)
		var/datum/NexusHotkeyAction/action = nexus_hotkey_action_registry[action_id]
		if(action.isAvailable(src)) result += list(list("token" = "classic-action:[action_id]", "name" = action.display_name, "group" = action.hotbar_type, "icon" = getNexusSkillArtworkResource(src, action.artwork_type)))
	for(var/obj/object in src)
		if(!isNexusHotkeyObjectAvailable(object) || (!hascall(object, "Hotbar_use") && !istype(object, /obj/items))) continue
		result += list(list("token" = "classic-skill:\ref[object]", "name" = "[object]", "group" = istype(object, /obj/items) ? "Inventory / Use" : object.hotbar_type, "icon" = getNexusBrowserAtomIconResource(src, object)))
	var/list/sources = list(src)
	for(var/obj/object in src) sources += object
	for(var/atom/source in sources)
		for(var/path in source.verbs)
			var/list/metadata = nexus_classic_command_catalog["[path]"]
			if(!islist(metadata) || isnull(metadata[2]) || (lowertext(metadata[2]) == "admin" && !IsAdmin())) continue
			result += list(list("token" = "classic-command:[md5("\ref[source]|[path]")]", "name" = metadata[1], "group" = source == src ? metadata[2] : "[metadata[2]] / [source]", "icon" = getNexusSkillArtworkResource(src, isobj(source) ? source.type : path)))
	return result

proc/isClassicBarId(id)
	return id == "bar" || (istext(id) && findtext(id, "bar_") == 1)

mob/proc/initializeClassicBars(viewport_width = 1366, viewport_height = 768)
	initializeClassicSlots()
	if(islist(nexus_classic_bars)) return
	nexus_classic_bars = list()
	if(!islist(nexus_classic_layout)) nexus_classic_layout = list()
	// Preserve old slot IDs and bindings while splitting the legacy bank into independent bars.
	for(var/start = 1, start <= nexus_classic_slots.len, start += 12)
		var/number = round((start - 1) / 12) + 1
		var/id = number == 1 ? "bar" : "bar_[number]"
		var/list/indexes = list()
		for(var/index in start to min(start + 11, nexus_classic_slots.len)) indexes += index
		nexus_classic_bars[id] = list("name" = "Bar [number]", "slots" = indexes, "columns" = min(indexes.len, nexus_classic_bar_columns), "size" = nexus_classic_bar_size, "locked" = nexus_classic_bar_locked)
		if(!islist(nexus_classic_layout[id]))
			nexus_classic_layout[id] = normalizeClassicGeometry(null, id, viewport_width, viewport_height)
			nexus_classic_layout[id]["open"] = number <= nexus_classic_bar_rows
			nexus_classic_layout[id]["y"] = max(0, nexus_classic_layout[id]["y"] - (number - 1) * 54)
	nexus_classic_next_bar = max(1, nexus_classic_bars.len + 1)

mob/proc/classicBarForSlot(index)
	initializeClassicBars()
	for(var/id in nexus_classic_bars)
		var/list/bar = nexus_classic_bars[id]
		if(index in bar["slots"]) return id

mob/proc/createClassicBar()
	initializeClassicBars()
	nexus_classic_next_bar = max(1, classicNumber(nexus_classic_next_bar, 1))
	var/id = "bar_[nexus_classic_next_bar++]"
	while(id in nexus_classic_bars) id = "bar_[nexus_classic_next_bar++]"
	nexus_classic_bars[id] = list("name" = "Bar [nexus_classic_next_bar - 1]", "slots" = list(), "columns" = 1, "size" = 40, "locked" = FALSE, "auto_columns" = TRUE)
	nexus_classic_layout[id] = normalizeClassicGeometry(null, id)
	addClassicBarSlots(id)
	fitClassicBar(id)
	if(client && client.nexus_classic_hud)
		var/list/new_bar_geometry = nexus_classic_layout[id]
		new_bar_geometry["x"] = max(0, round((client.nexus_classic_hud.viewport_width - new_bar_geometry["w"]) / 2))
		new_bar_geometry["y"] = max(0, client.nexus_classic_hud.viewport_height - new_bar_geometry["h"] - (nexus_classic_bars.len - 1) * (new_bar_geometry["h"] + 2))
		client.nexus_classic_hud.applyGeometry(id)
	classicBarChanged()
	return id

mob/proc/addClassicBarSlots(id, count = 1)
	initializeClassicBars()
	var/list/bar = nexus_classic_bars[id]
	if(!islist(bar)) return
	// Small additive operations avoid allocating an arbitrary client-supplied list length.
	// There is no maximum bar count or slot count; repeat additions as needed.
	count = count == 12 ? 12 : 1
	var/list/indexes = bar["slots"]
	for(var/n in 1 to count)
		nexus_classic_slots.len++
		indexes += nexus_classic_slots.len
	if(bar["auto_columns"]) bar["columns"] = min(12, max(1, indexes.len))
	fitClassicBar(id)
	classicBarChanged()
	return indexes[indexes.len]

mob/proc/removeClassicBarSlot(id, index)
	initializeClassicBars()
	var/list/bar = nexus_classic_bars[id]
	if(!islist(bar)) return
	var/list/indexes = bar["slots"]
	if(!(index in indexes)) return
	indexes -= index
	nexus_classic_slots[index] = null
	for(var/key in nexus_hotkey_bindings.Copy())
		var/list/binding = nexus_hotkey_bindings[key]
		if(binding["kind"] == "slot" && binding["slot"] == index) nexus_hotkey_bindings -= key
	bar["columns"] = min(max(1, indexes.len), bar["columns"])
	fitClassicBar(id)
	classicBarChanged()

mob/proc/removeClassicBar(id)
	initializeClassicBars()
	var/list/bar = nexus_classic_bars[id]
	if(!islist(bar)) return
	var/list/indexes = bar["slots"]
	for(var/index in indexes) nexus_classic_slots[index] = null
	for(var/key in nexus_hotkey_bindings.Copy())
		var/list/binding = nexus_hotkey_bindings[key]
		if(binding["kind"] == "slot" && (binding["slot"] in indexes)) nexus_hotkey_bindings -= key
	if(client && client.nexus_classic_hud)
		client.nexus_classic_hud.setOpen(id, FALSE)
		if(id != "bar") winset(src, "mapwindow.classic_[id]", "parent=")
	nexus_classic_layout -= id
	nexus_classic_bars -= id
	classicBarChanged()

mob/proc/fitClassicBar(id = "bar")
	initializeClassicBars()
	var/list/bar = nexus_classic_bars[id]
	if(!islist(bar) || !client) return
	initializeClassicHud()
	var/list/indexes = bar["slots"]
	var/columns = min(max(1, indexes.len), max(1, classicNumber(bar["columns"], 12)))
	var/list/state = nexus_classic_layout[id].Copy()
	state["w"] = columns * (bar["size"] + 3) + 25
	state["h"] = max(52, 8 + round((indexes.len + columns - 1) / columns) * (bar["size"] + 3))
	nexus_classic_layout[id] = normalizeClassicGeometry(state, id, client.nexus_classic_hud.viewport_width, client.nexus_classic_hud.viewport_height)
	client.nexus_classic_hud.setOpen(id, TRUE)
