#define NEXUS_HOTKEY_VERSION 2
#define NEXUS_HOTKEY_DOUBLE_PREFIX "DOUBLE:"
#define NEXUS_HOTKEY_DOUBLE_TAP_WINDOW 4

var/list/nexus_hotkey_base_keys = list(\
	"Space", "Escape", "Tab", "Return", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",\
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",\
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",\
	"North", "South", "East", "West", "Northeast", "Northwest", "Southeast", "Southwest", "Center",\
	"Numpad0", "Numpad1", "Numpad2", "Numpad3", "Numpad4", "Numpad5",\
	"Numpad6", "Numpad7", "Numpad8", "Numpad9", "Multiply", "Add", "Subtract", "Divide", "Separator",\
	"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",\
	"Back", "Insert", "Delete", "Home", "End", "PageUp", "PageDown", "Pause")

var/list/nexus_static_hotkey_base_keys = list(\
	"Space", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",\
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",\
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",\
	"Numpad0", "Numpad1", "Numpad2", "Numpad3", "Numpad4", "Numpad5",\
	"Numpad6", "Numpad7", "Numpad8", "Numpad9")

var/list/nexus_keyboard_layout_ids = list("us", "br", "gb", "fr", "de", "us(dvorak)")

proc/normalizeNexusKeyboardLayout(layout_id)
	if(!istext(layout_id)) return "us"
	layout_id = lowertext(layout_id)
	if(layout_id in nexus_keyboard_layout_ids) return layout_id
	return "us"

proc/getNexusKeyboardLayoutName(layout_id)
	switch(normalizeNexusKeyboardLayout(layout_id))
		if("br") return "br - Brazilian ABNT2"
		if("gb") return "gb - United Kingdom ISO"
		if("fr") return "fr - French AZERTY"
		if("de") return "de - German QWERTZ"
		if("us(dvorak)") return "us(dvorak) - Dvorak"
	return "us - United States ANSI"

proc/getNexusKeyboardLayoutRows(layout_id)
	switch(normalizeNexusKeyboardLayout(layout_id))
		if("fr")
			return list(list("A", "Z", "E", "R", "T", "Y", "U", "I", "O", "P"), list("Q", "S", "D", "F", "G", "H", "J", "K", "L", "M"), list("W", "X", "C", "V", "B", "N"))
		if("de")
			return list(list("Q", "W", "E", "R", "T", "Z", "U", "I", "O", "P"), list("A", "S", "D", "F", "G", "H", "J", "K", "L"), list("Y", "X", "C", "V", "B", "N", "M"))
		if("us(dvorak)")
			return list(list("P", "Y", "F", "G", "C", "R", "L"), list("A", "O", "E", "U", "I", "D", "H", "T", "N", "S"), list("Q", "J", "K", "X", "B", "M", "W", "V", "Z"))
	return list(list("Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"), list("A", "S", "D", "F", "G", "H", "J", "K", "L"), list("Z", "X", "C", "V", "B", "N", "M"))

proc/getNexusUnixKeyName(base_key)
	base_key = normalizeNexusHotkeyBase(base_key)
	if(!base_key) return "unknown"
	switch(base_key)
		if("Space") return "space"
		if("Escape") return "escape"
		if("Tab") return "tab"
		if("Return") return "return"
		if("Back") return "backspace"
		if("Insert") return "insert"
		if("Delete") return "delete"
		if("Home") return "home"
		if("End") return "end"
		if("PageUp") return "page_up"
		if("PageDown") return "page_down"
		if("Pause") return "pause"
		if("North") return "up"
		if("South") return "down"
		if("East") return "right"
		if("West") return "left"
		if("Northeast") return "up_right"
		if("Northwest") return "up_left"
		if("Southeast") return "down_right"
		if("Southwest") return "down_left"
		if("Center") return "center"
		if("Multiply") return "kp_multiply"
		if("Add") return "kp_add"
		if("Subtract") return "kp_subtract"
		if("Divide") return "kp_divide"
		if("Separator") return "kp_separator"
	if(findtext(base_key, "Numpad") == 1) return "kp_[lowertext(copytext(base_key, 7))]"
	return lowertext(base_key)

proc/normalizeNexusHotkeyBase(base_key)
	if(!istext(base_key)) return
	for(var/allowed_key in nexus_hotkey_base_keys)
		if(lowertext(allowed_key) == lowertext(base_key)) return allowed_key

proc/canonicalNexusHotkey(base_key, use_ctrl = 0, use_shift = 0, use_alt = 0, tap_count = 1)
	base_key = normalizeNexusHotkeyBase(base_key)
	if(!base_key) return
	var/combination = ""
	if(use_ctrl) combination += "CTRL+"
	if(use_shift) combination += "SHIFT+"
	if(use_alt) combination += "ALT+"
	combination = "[combination][base_key]"
	if(tap_count >= 2) return "[NEXUS_HOTKEY_DOUBLE_PREFIX][combination]"
	return combination

proc/isNexusDoubleTapHotkey(combination)
	return istext(combination) && findtext(combination, NEXUS_HOTKEY_DOUBLE_PREFIX) == 1

proc/getNexusHotkeyTriggerCombination(combination)
	if(!istext(combination)) return
	if(isNexusDoubleTapHotkey(combination)) return copytext(combination, length(NEXUS_HOTKEY_DOUBLE_PREFIX) + 1)
	return combination

proc/getNexusHotkeyBase(combination)
	if(!istext(combination)) return
	combination = getNexusHotkeyTriggerCombination(combination)
	var/list/parts = dd_text2list(combination, "+")
	if(!parts.len) return
	return normalizeNexusHotkeyBase(parts[parts.len])

proc/getNexusMovementKeysForHotkeyBase(base_key)
	base_key = normalizeNexusHotkeyBase(base_key)
	switch(base_key)
		if("North") return list("north")
		if("South") return list("south")
		if("East") return list("east")
		if("West") return list("west")
		if("Northeast") return list("north", "east")
		if("Northwest") return list("north", "west")
		if("Southeast") return list("south", "east")
		if("Southwest") return list("south", "west")
	return list()

proc/getNexusMovementHotkeyCommand(base_key, key_down = TRUE)
	var/list/movement_keys = getNexusMovementKeysForHotkeyBase(base_key)
	var/command_text = ""
	var/verb_name = key_down ? "KeyDown" : "KeyUp"
	for(var/movement_key in movement_keys)
		if(length(command_text)) command_text += "\n"
		command_text += "[verb_name] \"[movement_key]\""
	return command_text

proc/getNexusHotkeyDownMacroCommand(trigger_combination, base_key)
	var/command_text = "nexusHotkeyDown \"[trigger_combination]\" \"[base_key]\""
	var/movement_command = getNexusMovementHotkeyCommand(base_key, TRUE)
	if(length(movement_command)) command_text = "[movement_command]\n[command_text]"
	return command_text

proc/getNexusHotkeyUpMacroCommand(base_key)
	var/command_text = "nexusHotkeyUp \"[base_key]\""
	var/movement_command = getNexusMovementHotkeyCommand(base_key, FALSE)
	if(length(movement_command)) command_text = "[movement_command]\n[command_text]"
	return command_text

proc/getNexusUnixHotkeyName(combination)
	var/trigger_combination = getNexusHotkeyTriggerCombination(combination)
	if(!trigger_combination) return "unassigned"
	var/list/parts = dd_text2list(trigger_combination, "+")
	var/list/unix_parts = list()
	for(var/part in parts)
		switch(uppertext(part))
			if("CTRL") unix_parts += "ctrl_l"
			if("SHIFT") unix_parts += "shift_l"
			if("ALT") unix_parts += "alt_l"
			else unix_parts += getNexusUnixKeyName(part)
	var/formatted = jointext(unix_parts, " + ")
	if(isNexusDoubleTapHotkey(combination)) return "[formatted] + [formatted]"
	return formatted

datum/NexusHotkeyAction
	var/action_id
	var/display_name
	var/hotbar_type = "Ability"
	var/repeat_action = 0

	proc/isAvailable(mob/user)
		return !!user

	proc/execute(mob/user)
		return 0

	Zanzoken
		var/warp_direction

		New(new_id, new_name, new_direction)
			. = ..()
			action_id = new_id
			display_name = new_name
			warp_direction = new_direction

		isAvailable(mob/user)
			return user && user.hasZanzokenSkill()

		execute(mob/user)
			if(!isAvailable(user)) return 0
			user.directionalZanzoken(warp_direction)
			return 1

	DefensiveDash
		var/dash_direction

		New(new_id, new_name, new_direction)
			. = ..()
			action_id = new_id
			display_name = new_name
			hotbar_type = "Defensive"
			dash_direction = new_direction

		execute(mob/user)
			if(!user) return 0
			user.tryDefensiveDash(dash_direction)
			return 1

	CycleTarget
		New()
			. = ..()
			action_id = "cycle_target"
			display_name = "Cycle Target"
			hotbar_type = "Targeting"

		execute(mob/user)
			if(!user) return 0
			user.cycleSelectedTarget()
			return 1

	ToggleWalk
		New()
			. = ..()
			action_id = "toggle_walk"
			display_name = "Toggle Walk"
			hotbar_type = "Movement"

		execute(mob/user)
			if(!user) return 0
			user.toggleWalkingMode()
			return 1

var/list/nexus_hotkey_action_registry

proc/initializeNexusHotkeyActionRegistry()
	if(nexus_hotkey_action_registry) return
	nexus_hotkey_action_registry = list()
	var/datum/NexusHotkeyAction/action
	action = new /datum/NexusHotkeyAction/Zanzoken("zanzoken_north", "Zanzoken: North", NORTH)
	nexus_hotkey_action_registry[action.action_id] = action
	action = new /datum/NexusHotkeyAction/Zanzoken("zanzoken_northeast", "Zanzoken: Northeast", NORTHEAST)
	nexus_hotkey_action_registry[action.action_id] = action
	action = new /datum/NexusHotkeyAction/Zanzoken("zanzoken_east", "Zanzoken: East", EAST)
	nexus_hotkey_action_registry[action.action_id] = action
	action = new /datum/NexusHotkeyAction/Zanzoken("zanzoken_southeast", "Zanzoken: Southeast", SOUTHEAST)
	nexus_hotkey_action_registry[action.action_id] = action
	action = new /datum/NexusHotkeyAction/Zanzoken("zanzoken_south", "Zanzoken: South", SOUTH)
	nexus_hotkey_action_registry[action.action_id] = action
	action = new /datum/NexusHotkeyAction/Zanzoken("zanzoken_southwest", "Zanzoken: Southwest", SOUTHWEST)
	nexus_hotkey_action_registry[action.action_id] = action
	action = new /datum/NexusHotkeyAction/Zanzoken("zanzoken_west", "Zanzoken: West", WEST)
	nexus_hotkey_action_registry[action.action_id] = action
	action = new /datum/NexusHotkeyAction/Zanzoken("zanzoken_northwest", "Zanzoken: Northwest", NORTHWEST)
	nexus_hotkey_action_registry[action.action_id] = action
	action = new /datum/NexusHotkeyAction/DefensiveDash("short_dash_north", "Short Dash: North", NORTH)
	nexus_hotkey_action_registry[action.action_id] = action
	action = new /datum/NexusHotkeyAction/DefensiveDash("short_dash_northeast", "Short Dash: Northeast", NORTHEAST)
	nexus_hotkey_action_registry[action.action_id] = action
	action = new /datum/NexusHotkeyAction/DefensiveDash("short_dash_east", "Short Dash: East", EAST)
	nexus_hotkey_action_registry[action.action_id] = action
	action = new /datum/NexusHotkeyAction/DefensiveDash("short_dash_southeast", "Short Dash: Southeast", SOUTHEAST)
	nexus_hotkey_action_registry[action.action_id] = action
	action = new /datum/NexusHotkeyAction/DefensiveDash("short_dash_south", "Short Dash: South", SOUTH)
	nexus_hotkey_action_registry[action.action_id] = action
	action = new /datum/NexusHotkeyAction/DefensiveDash("short_dash_southwest", "Short Dash: Southwest", SOUTHWEST)
	nexus_hotkey_action_registry[action.action_id] = action
	action = new /datum/NexusHotkeyAction/DefensiveDash("short_dash_west", "Short Dash: West", WEST)
	nexus_hotkey_action_registry[action.action_id] = action
	action = new /datum/NexusHotkeyAction/DefensiveDash("short_dash_northwest", "Short Dash: Northwest", NORTHWEST)
	nexus_hotkey_action_registry[action.action_id] = action
	action = new /datum/NexusHotkeyAction/CycleTarget
	nexus_hotkey_action_registry[action.action_id] = action
	action = new /datum/NexusHotkeyAction/ToggleWalk
	nexus_hotkey_action_registry[action.action_id] = action

proc/getNexusHotkeyAction(action_id)
	initializeNexusHotkeyActionRegistry()
	return nexus_hotkey_action_registry[action_id]

mob/var/tmp
	list/nexus_hotkey_bindings = new
	nexus_hotkey_version
	nexus_keyboard_layout = "us"
	list/active_nexus_hotkey_actions = new
	list/active_nexus_hotkey_combinations = new
	list/nexus_hotkey_last_press_times = new
	list/nexus_hotkey_editor_actions = new
	nexus_hotkey_editor_open

client/var/tmp
	list/generated_nexus_hotkey_macros = new
	nexus_hotkey_editor

mob/proc/isNexusHotkeyObjectAvailable(obj/hotkey_object)
	if(!hotkey_object || hotkey_object.loc != src || !hotkey_object.can_hotbar) return 0
	if(istype(hotkey_object, /obj/items))
		var/obj/items/item = hotkey_object
		if(item.isNexusTradeOfferedBy(src)) return 0
	if(istype(hotkey_object, /obj/Flash_Step) && !hasZanzokenSkill()) return 0
	return 1

mob/proc/resolveNexusHotkeyObject(list/binding_info)
	if(!islist(binding_info)) return
	var/object_id = binding_info["object id"]
	var/object_type = binding_info["object type"]
	if(istext(object_type)) object_type = text2path(object_type)
	for(var/obj/hotkey_object in src)
		if(object_id && hotkey_object.hotbar_id == object_id && isNexusHotkeyObjectAvailable(hotkey_object)) return hotkey_object
	if(object_type)
		for(var/obj/hotkey_object in src)
			if(hotkey_object.type == object_type && isNexusHotkeyObjectAvailable(hotkey_object)) return hotkey_object

mob/proc/resolveNexusHotkeyBinding(combination)
	if(!islist(nexus_hotkey_bindings)) return
	var/list/binding_info = nexus_hotkey_bindings[combination]
	if(!islist(binding_info)) return
	if(binding_info["kind"] == "action")
		var/datum/NexusHotkeyAction/action = getNexusHotkeyAction(binding_info["action id"])
		if(action && action.isAvailable(src)) return action
	if(binding_info["kind"] == "object") return resolveNexusHotkeyObject(binding_info)

mob/proc/executeNexusHotkeyAction(hotkey_action)
	if(istype(hotkey_action, /datum/NexusHotkeyAction))
		var/datum/NexusHotkeyAction/action = hotkey_action
		return action.execute(src)
	if(isobj(hotkey_action))
		var/obj/hotkey_object = hotkey_action
		if(!isNexusHotkeyObjectAvailable(hotkey_object)) return 0
		if(!hascall(hotkey_object, "Hotbar_use")) return 0
		hotkey_object:Hotbar_use(src)
		return 1
	return 0

mob/proc/nexusHotkeyActionRepeats(hotkey_action)
	if(istype(hotkey_action, /datum/NexusHotkeyAction))
		var/datum/NexusHotkeyAction/action = hotkey_action
		return action.repeat_action
	if(isobj(hotkey_action))
		var/obj/hotkey_object = hotkey_action
		return hotkey_object.repeat_macro
	return 0

mob/proc/migrateLegacyHotkeyBindings()
	if(!islist(nexus_hotkey_bindings)) nexus_hotkey_bindings = list()
	if(nexus_hotkey_bindings.len || !islist(hotbar_ids)) return
	for(var/hotbar_id in hotbar_ids)
		if(!istext(hotbar_id)) continue
		var/list/legacy_info = hotbar_ids[hotbar_id]
		if(!islist(legacy_info)) continue
		var/list_position = legacy_info["hotbar position"]
		if(istext(list_position)) list_position = text2num(list_position)
		if(!isnum(list_position) || list_position < 1 || list_position > keys.len) continue
		var/base_key = keys[list_position]
		nexus_hotkey_bindings[base_key] = list(\
			"kind" = "object",\
			"object id" = hotbar_id,\
			"object type" = legacy_info["object type"],\
			"display name" = "Legacy action")

mob/proc/initializeNexusHotkeys()
	if(!islist(nexus_hotkey_bindings)) nexus_hotkey_bindings = list()
	if(!islist(active_nexus_hotkey_actions)) active_nexus_hotkey_actions = list()
	if(!islist(active_nexus_hotkey_combinations)) active_nexus_hotkey_combinations = list()
	if(!islist(nexus_hotkey_last_press_times)) nexus_hotkey_last_press_times = list()
	nexus_keyboard_layout = normalizeNexusKeyboardLayout(nexus_keyboard_layout)
	if(nexus_hotkey_version < NEXUS_HOTKEY_VERSION)
		migrateLegacyHotkeyBindings()
		nexus_hotkey_version = NEXUS_HOTKEY_VERSION
	if(client) client.syncNexusHotkeyMacros()

mob/proc/getNexusHotkeyBindingIdForPress(trigger_combination, was_held = FALSE, press_time = world.time)
	trigger_combination = getNexusHotkeyTriggerCombination(trigger_combination)
	if(!trigger_combination) return
	if(was_held) return trigger_combination
	if(!islist(nexus_hotkey_last_press_times)) nexus_hotkey_last_press_times = list()
	var/double_combination = "[NEXUS_HOTKEY_DOUBLE_PREFIX][trigger_combination]"
	if(resolveNexusHotkeyBinding(double_combination))
		if(trigger_combination in nexus_hotkey_last_press_times)
			var/last_press_time = nexus_hotkey_last_press_times[trigger_combination]
			if(isnum(last_press_time) && press_time >= last_press_time && press_time - last_press_time <= NEXUS_HOTKEY_DOUBLE_TAP_WINDOW)
				nexus_hotkey_last_press_times -= trigger_combination
				return double_combination
		nexus_hotkey_last_press_times[trigger_combination] = press_time
	return trigger_combination

mob/proc/getNexusBindingDisplayName(list/binding_info)
	if(!islist(binding_info)) return "Unassigned"
	if(binding_info["kind"] == "action")
		var/datum/NexusHotkeyAction/action = getNexusHotkeyAction(binding_info["action id"])
		if(action) return action.display_name
	if(binding_info["kind"] == "object")
		var/obj/hotkey_object = resolveNexusHotkeyObject(binding_info)
		if(hotkey_object) return "[hotkey_object]"
		if(binding_info["display name"]) return binding_info["display name"]
	return "Unavailable action"

mob/proc/bindNexusHotkey(combination, list/binding_info)
	if(!canonicalNexusHotkey(getNexusHotkeyBase(combination))) return 0
	if(getNexusHotkeyTriggerCombination(combination) == "ALT+F4") return 0
	if(!islist(nexus_hotkey_bindings)) nexus_hotkey_bindings = list()
	nexus_hotkey_bindings[combination] = binding_info.Copy()
	nexus_hotkey_version = NEXUS_HOTKEY_VERSION
	Hotkey_server_backup_save()
	if(client) client.syncNexusHotkeyMacros()
	return 1

mob/proc/unbindNexusHotkey(combination)
	if(!islist(nexus_hotkey_bindings) || !(combination in nexus_hotkey_bindings)) return
	nexus_hotkey_bindings -= combination
	Hotkey_server_backup_save()
	if(client) client.syncNexusHotkeyMacros()

mob/proc/importLegacyNexusHotkeys()
	nexus_hotkey_bindings = list()
	migrateLegacyHotkeyBindings()
	nexus_hotkey_version = NEXUS_HOTKEY_VERSION
	Hotkey_server_backup_save()
	if(client) client.syncNexusHotkeyMacros()

client/proc/clearNexusHotkeyMacros()
	if(!islist(generated_nexus_hotkey_macros)) generated_nexus_hotkey_macros = list()
	for(var/macro_id in generated_nexus_hotkey_macros)
		winset(src, macro_id, "parent=")
	generated_nexus_hotkey_macros = list()

client/proc/syncNexusHotkeyMacros()
	clearNexusHotkeyMacros()
	if(!mob || !islist(mob.nexus_hotkey_bindings)) return
	var/list/generated_up_combinations = list()
	var/list/generated_down_combinations = list()
	var/macro_number = 0
	for(var/combination in mob.nexus_hotkey_bindings)
		if(!mob.resolveNexusHotkeyBinding(combination)) continue
		var/trigger_combination = getNexusHotkeyTriggerCombination(combination)
		var/base_key = getNexusHotkeyBase(combination)
		if(!base_key || !trigger_combination) continue
		var/is_static_bare_key = trigger_combination == base_key && (base_key in nexus_static_hotkey_base_keys)
		if(is_static_bare_key) continue
		if(trigger_combination in generated_down_combinations) continue
		macro_number++
		var/down_id = "nexus_hotkey_[macro_number]_down"
		var/down_command = getNexusHotkeyDownMacroCommand(trigger_combination, base_key)
		winset(src, down_id, list("parent" = "macro", "name" = trigger_combination, "command" = down_command))
		generated_nexus_hotkey_macros += down_id
		generated_down_combinations += trigger_combination
		var/up_combination = "[trigger_combination]+UP"
		if(!(up_combination in generated_up_combinations))
			var/up_id = "nexus_hotkey_[macro_number]_up"
			var/up_command = getNexusHotkeyUpMacroCommand(base_key)
			winset(src, up_id, list("parent" = "macro", "name" = up_combination, "command" = up_command))
			generated_nexus_hotkey_macros += up_id
			generated_up_combinations += up_combination

mob/verb/nexusHotkeyDown(combination as text, base_key as text)
	set hidden = 1
	set instant = 1
	set waitfor = 0
	if(nexus_hotkey_editor_open) return
	base_key = normalizeNexusHotkeyBase(base_key)
	if(!base_key) return
	var/was_key_held = (base_key in keys_down)
	for(var/repetition in 1 to 3) keys_down -= base_key
	keys_down += base_key
	HotbarUseHandler(combination, base_key, was_key_held)

mob/verb/nexusHotkeyUp(base_key as text)
	set hidden = 1
	set instant = 1
	set waitfor = 0
	base_key = normalizeNexusHotkeyBase(base_key)
	if(base_key) HandleKeyUp(base_key)

mob/proc/getNexusKeyBindingBadges(base_key)
	var/badges = ""
	if(!islist(nexus_hotkey_bindings)) return badges
	for(var/combination in nexus_hotkey_bindings)
		if(getNexusHotkeyBase(combination) != base_key) continue
		var/list/binding_info = nexus_hotkey_bindings[combination]
		var/display_name = html_encode(getNexusBindingDisplayName(binding_info))
		var/binding_class = isNexusDoubleTapHotkey(combination) ? "binding double" : "binding single"
		badges += "<span class='[binding_class]'><i>[html_encode(getNexusUnixHotkeyName(combination))]</i><b>[display_name]</b><button onclick=\"event.stopPropagation();clearBinding('[combination]')\">x</button></span>"
	return badges

mob/proc/renderNexusVirtualKey(base_key, display_label, raw_label = FALSE)
	var/key_class = base_key == "Space" ? "key space-key" : "key"
	if(base_key in list("North", "South", "East", "West")) key_class += " direction-key"
	var/key_label = display_label || getNexusUnixKeyName(base_key)
	if(!raw_label) key_label = html_encode(key_label)
	return "<div class='[key_class]' ondragover='event.preventDefault()' ondrop=\"dropAction(event,'[base_key]')\"><strong>[key_label]</strong><small>[html_encode(base_key)]</small>[getNexusKeyBindingBadges(base_key)]</div>"

mob/proc/buildNexusHotkeyEditorHtml(datum/NexusHotkeyEditor/editor)
	initializeNexusHotkeys()
	nexus_hotkey_editor_actions = list()
	var/actions_html = ""
	var/action_number = 0
	initializeNexusHotkeyActionRegistry()
	for(var/action_id in nexus_hotkey_action_registry)
		var/datum/NexusHotkeyAction/action = nexus_hotkey_action_registry[action_id]
		if(!action.isAvailable(src)) continue
		action_number++
		var/action_token = "action_[action_number]"
		nexus_hotkey_editor_actions[action_token] = list("kind" = "action", "action id" = action.action_id, "display name" = action.display_name)
		actions_html += "<div class='action-card' draggable='true' ondragstart=\"startDrag(event,'[action_token]')\"><b>[html_encode(action.display_name)]</b><span>[html_encode(action.hotbar_type)]</span></div>"
	for(var/obj/hotkey_object in src)
		if(!isNexusHotkeyObjectAvailable(hotkey_object)) continue
		if(!hotkey_object.hotbar_id) hotkey_object.hotbar_id = Assign_hotbar_ID()
		action_number++
		var/action_token = "action_[action_number]"
		nexus_hotkey_editor_actions[action_token] = list(\
			"kind" = "object",\
			"object id" = hotkey_object.hotbar_id,\
			"object type" = hotkey_object.type,\
			"display name" = "[hotkey_object]")
		actions_html += "<div class='action-card' draggable='true' ondragstart=\"startDrag(event,'[action_token]')\"><b>[html_encode("[hotkey_object]")]</b><span>[html_encode(hotkey_object.hotbar_type)]</span></div>"

	var/layout_options = ""
	for(var/layout_id in nexus_keyboard_layout_ids)
		var/selected = layout_id == nexus_keyboard_layout ? " selected" : ""
		layout_options += "<option value='[html_encode(layout_id)]'[selected]>[html_encode(getNexusKeyboardLayoutName(layout_id))]</option>"

	var/keyboard_html = ""
	keyboard_html += "<div class='key-row'>"
	for(var/key_name in list("Escape", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "Pause")) keyboard_html += renderNexusVirtualKey(key_name, getNexusUnixKeyName(key_name))
	keyboard_html += "</div><div class='key-row'>"
	for(var/key_name in list("1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "Back")) keyboard_html += renderNexusVirtualKey(key_name, getNexusUnixKeyName(key_name))
	var/list/layout_rows = getNexusKeyboardLayoutRows(nexus_keyboard_layout)
	for(var/row_number in 1 to layout_rows.len)
		var/row_class = row_number == 1 ? "offset-one" : row_number == 2 ? "offset-two" : "offset-three"
		keyboard_html += "</div><div class='key-row [row_class]'>"
		if(row_number == 1) keyboard_html += renderNexusVirtualKey("Tab", "tab")
		var/list/layout_row = layout_rows[row_number]
		for(var/key_name in layout_row) keyboard_html += renderNexusVirtualKey(key_name, getNexusUnixKeyName(key_name))
		if(row_number == 2) keyboard_html += renderNexusVirtualKey("Return", "return")
	keyboard_html += "</div><div class='key-row space-row'>[renderNexusVirtualKey("Space", "space")]</div>"

	var/navigation_html = ""
	for(var/key_name in list("Insert", "Home", "PageUp", "Delete", "End", "PageDown")) navigation_html += renderNexusVirtualKey(key_name, getNexusUnixKeyName(key_name))
	navigation_html += "<div class='nav-spacer'></div>[renderNexusVirtualKey("North", "&uarr;<br>up", TRUE)]<div class='nav-spacer'></div>"
	navigation_html += "[renderNexusVirtualKey("West", "&larr;<br>left", TRUE)][renderNexusVirtualKey("South", "&darr;<br>down", TRUE)][renderNexusVirtualKey("East", "&rarr;<br>right", TRUE)]"

	var/numpad_html = ""
	for(var/key_name in list("Numpad7", "Numpad8", "Numpad9", "Divide", "Numpad4", "Numpad5", "Numpad6", "Multiply", "Numpad1", "Numpad2", "Numpad3", "Subtract", "Numpad0", "Separator", "Add"))
		numpad_html += renderNexusVirtualKey(key_name, getNexusUnixKeyName(key_name))

	var/binding_summary = ""
	for(var/combination in nexus_hotkey_bindings)
		var/list/binding_info = nexus_hotkey_bindings[combination]
		var/trigger_label = isNexusDoubleTapHotkey(combination) ? "DOUBLE" : "SINGLE"
		binding_summary += "<div><em>[trigger_label]</em><code>[html_encode(getNexusUnixHotkeyName(combination))]</code><span>[html_encode(getNexusBindingDisplayName(binding_info))]</span><button onclick=\"clearBinding('[combination]')\">Remove</button></div>"
	if(!binding_summary) binding_summary = "<p class='empty'>No bindings configured.</p>"

	return {"<!doctype html>
	<html><head><meta charset='utf-8'><title>Nexus Hotkeys</title><style>[getNexusRpgBrowserCss()]
	*{box-sizing:border-box}body{margin:0;background:#100d08;color:#ead9b5;font:14px Arial,sans-serif;overflow:hidden}
	.shell{height:100vh;display:grid;grid-template-columns:320px minmax(0,1fr);background:#100d08;border:3px solid #8f692f}
	.catalog{padding:18px;border-right:3px double #8f692f;background:#19130c;overflow:auto}.catalog h1{margin:0 0 5px;color:#ffd77a;font:24px Nexus,Georgia,serif;letter-spacing:.08em}.catalog p{margin:0 0 15px;color:#bca579}.catalog input{width:100%;padding:11px;border:2px inset #8f692f;background:#080706;color:#fff1c8;margin-bottom:12px;font:14px Consolas,monospace}
	.action-card{padding:11px 12px;margin:7px 0;border:2px solid #66502c;border-left:7px solid #c6923c;background:#241b10;cursor:grab}.action-card:hover{border-color:#ffd77a;background:#302313}.action-card b{display:block;color:#fff1c8}.action-card span{font-size:10px;text-transform:uppercase;letter-spacing:.12em;color:#bca579}
	.workspace{padding:17px 20px;overflow:auto}.toolbar{display:flex;align-items:flex-end;flex-wrap:wrap;gap:10px;min-width:1380px;margin-bottom:12px;padding:10px;border:2px solid #72552c;background:#1b150d}.toolbar h2{margin:0 auto 0 0;align-self:center;color:#ffd77a;font:18px Nexus,Georgia,serif;letter-spacing:.08em}.control{display:block;color:#cdb787;font-size:10px;text-transform:uppercase}.control select{display:block;min-width:230px;margin-top:3px;padding:7px;border:2px inset #8f692f;background:#090806;color:#fff1c8;font:12px Consolas,monospace}.modifier{padding:7px 9px;border:1px solid #6c522c;background:#2a2013;font:12px Consolas,monospace}.toolbar button,.summary button{border:2px outset #8f692f;background:#3a2a16;color:#fff1c8;padding:7px 10px;cursor:pointer;font:11px Nexus,Georgia,serif;text-transform:uppercase}.toolbar button:hover,.summary button:hover{color:#ffd77a;background:#51391b}
	.trigger-strip{display:flex;align-items:center;gap:7px;margin:0 0 12px;padding:8px 12px;border:2px solid #72552c;background:#171109}.trigger-strip>strong{color:#ffd77a;margin-right:8px}.trigger-strip label{padding:7px 12px;border:1px solid #66502c;background:#281e12;font:12px Consolas,monospace}.trigger-strip small{margin-left:auto;color:#bca579}
	.keyboard-wrap{display:grid;grid-template-columns:minmax(820px,1fr) 230px 300px;gap:12px;min-width:1380px}.keyboard{padding:13px;border:3px double #8f692f;background:#18120b}.key-row{display:flex;gap:4px;margin-bottom:5px}.offset-one{padding-left:12px}.offset-two{padding-left:28px}.offset-three{padding-left:48px}.space-row{justify-content:center;margin-top:8px}
	.key{position:relative;min-width:52px;min-height:76px;flex:1;padding:7px 3px;border:2px outset #75603a;border-bottom-width:4px;background:#292116;color:#f4dfad;text-align:center;overflow:hidden}.key:hover{border-color:#ffd77a;background:#392b17}.key strong{display:block;font:11px Consolas,monospace}.key small{display:block;color:#907e5e;font:8px Consolas,monospace;margin-bottom:3px}.space-key{max-width:500px;min-height:80px}.direction-key strong{font-size:14px;line-height:1.05}
	.binding{display:block;margin-top:3px;padding:3px 18px 3px 4px;color:#fff8df;font-size:8px;text-align:left;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;position:relative}.binding.single{background:#355229}.binding.double{background:#62402a}.binding i,.binding b{display:block;overflow:hidden;text-overflow:ellipsis}.binding i{color:#ffdb7d;font-style:normal}.binding button{position:absolute;right:2px;top:1px;border:0;background:none;color:#ffc2a3;cursor:pointer}
	.navigation,.numpad{display:grid;gap:5px;padding:13px;border:3px double #8f692f;background:#18120b;align-content:start}.navigation{grid-template-columns:repeat(3,1fr)}.navigation .key,.numpad .key{min-width:0;min-height:84px}.nav-spacer{min-height:84px}.numpad{grid-template-columns:repeat(4,1fr)}
	.summary{margin-top:15px;border:3px double #8f692f;background:#18120b;padding:10px}.summary h3{margin:0 0 7px;color:#ffd77a;font:14px Nexus,Georgia,serif;letter-spacing:.1em}.summary>div{display:grid;grid-template-columns:65px 230px 1fr auto;align-items:center;gap:10px;padding:7px 8px;border-top:1px solid #4f3a1e}.summary em{color:#cdb787;font:10px Consolas,monospace}.summary code{color:#ffd77a}.empty{color:#907e5e}
	.hint{color:#bca579;font-size:11px;margin:8px 2px 12px}.warning{color:#ff9a80}
	</style></head><body><div class='shell'>
	<aside class='catalog'><h1>ACTION DECK</h1><p>Drag an action onto its key. The same action may be used more than once.</p><input id='filter' placeholder='Search actions...' oninput='filterActions()'>[actions_html]</aside>
	<main class='workspace'><div class='toolbar'><h2>HOTKEY FORGE</h2><label class='control'>XKB keyboard layout<select onchange='selectLayout(this.value)'>[layout_options]</select></label><label class='modifier'><input id='ctrl' type='checkbox'[editor.use_ctrl ? " checked" : ""]> ctrl_l</label><label class='modifier'><input id='shift' type='checkbox'[editor.use_shift ? " checked" : ""]> shift_l</label><label class='modifier'><input id='alt' type='checkbox'[editor.use_alt ? " checked" : ""]> alt_l</label><button onclick='importLegacy()'>Import legacy</button><button onclick='clearAll()'>Clear all</button><button onclick='closeEditor()'>Close</button></div>
	<div class='trigger-strip'><strong>ACTIVATION</strong><label><input name='tap_count' type='radio' value='1'[editor.tap_count == 1 ? " checked" : ""]> single press</label><label><input name='tap_count' type='radio' value='2'[editor.tap_count == 2 ? " checked" : ""]> double tap</label><small>Example: space = Manual Attack &nbsp; / &nbsp; space + space = Lunge</small></div>
	<p class='hint'>Choose an XKB layout, modifiers and activation type, then drop an action. Unix/XKB names are shown first. <span class='warning'>F1/F2 keep their client functions; alt_l + f4 is reserved.</span></p>
	<div class='keyboard-wrap'><section class='keyboard'>[keyboard_html]</section><section class='navigation'>[navigation_html]</section><section class='numpad'>[numpad_html]</section></div>
	<section class='summary'><h3>Active bindings</h3>[binding_summary]</section></main></div>
	<script>
	var handlerRef='\ref[editor]';
	function sendTopic(data){data.src=handlerRef;if(window.BYOND&&BYOND.topic){BYOND.topic(data);return;}var query='';for(var key in data){if(query)query+='&';query+=encodeURIComponent(key)+'='+encodeURIComponent(data\[key\]);}window.location.href='byond://?'+query;}
	function startDrag(event,id){event.dataTransfer.setData('text/plain',id);}
	function modifiers(){return{ctrl:document.getElementById('ctrl').checked?'1':'0',shift:document.getElementById('shift').checked?'1':'0',alt:document.getElementById('alt').checked?'1':'0'};}
	function tapCount(){var taps=document.getElementsByName('tap_count');for(var i=0;i<taps.length;i++)if(taps\[i\].checked)return taps\[i\].value;return'1';}
	function dropAction(event,key){event.preventDefault();var m=modifiers();sendTopic({action:'bind',action_token:event.dataTransfer.getData('text/plain'),base_key:key,ctrl:m.ctrl,shift:m.shift,alt:m.alt,tap_count:tapCount()});}
	function clearBinding(combo){sendTopic({action:'unbind',combination:combo});}
	function clearAll(){if(confirm('Remove every custom binding?'))sendTopic({action:'clear'});}
	function importLegacy(){sendTopic({action:'import_legacy'});}
	function selectLayout(layout){sendTopic({action:'layout',layout:layout});}
	function closeEditor(){sendTopic({action:'close'});}
	function filterActions(){var query=document.getElementById('filter').value.toLowerCase();var cards=document.getElementsByClassName('action-card');for(var i=0;i<cards.length;i++)cards\[i\].style.display=cards\[i\].innerText.toLowerCase().indexOf(query)>=0?'block':'none';}
	</script></body></html>"}

datum/NexusHotkeyEditor
	var/tmp/mob/owner
	var/tmp/use_ctrl
	var/tmp/use_shift
	var/tmp/use_alt
	var/tmp/tap_count = 1

	New(mob/new_owner)
		. = ..()
		owner = new_owner

	proc/show()
		if(!owner || !owner.client) return
		owner << browse(owner.buildNexusHotkeyEditorHtml(src), "window=NexusHotkeys;size=1720x980;can_resize=true;can_close=false")

	Topic(href, list/href_list)
		if(!owner || usr != owner || !owner.client) return
		var/action = href_list["action"]
		switch(action)
			if("bind")
				var/base_key = normalizeNexusHotkeyBase(href_list["base_key"])
				use_ctrl = text2num(href_list["ctrl"])
				use_shift = text2num(href_list["shift"])
				use_alt = text2num(href_list["alt"])
				tap_count = text2num(href_list["tap_count"]) >= 2 ? 2 : 1
				var/combination = canonicalNexusHotkey(base_key, use_ctrl, use_shift, use_alt, tap_count)
				var/list/binding_info = owner.nexus_hotkey_editor_actions[href_list["action_token"]]
				if(combination && islist(binding_info))
					var/available_action
					if(binding_info["kind"] == "action")
						var/datum/NexusHotkeyAction/hotkey_action = getNexusHotkeyAction(binding_info["action id"])
						available_action = hotkey_action && hotkey_action.isAvailable(owner)
					else available_action = owner.resolveNexusHotkeyObject(binding_info)
					if(available_action) owner.bindNexusHotkey(combination, binding_info)
			if("unbind")
				owner.unbindNexusHotkey(href_list["combination"])
			if("clear")
				owner.nexus_hotkey_bindings = list()
				owner.nexus_hotkey_version = NEXUS_HOTKEY_VERSION
				owner.Hotkey_server_backup_save()
				owner.client.syncNexusHotkeyMacros()
			if("import_legacy")
				owner.importLegacyNexusHotkeys()
			if("layout")
				owner.nexus_keyboard_layout = normalizeNexusKeyboardLayout(href_list["layout"])
				owner.Hotkey_server_backup_save()
			if("close")
				owner.hideNexusHotkeyEditor()
				return
		show()

mob/proc/showNexusHotkeyEditor()
	if(!client) return
	Remove_Duplicate_Moves()
	StopMovement()
	initializeNexusHotkeys()
	nexus_hotkey_editor_open = 1
	var/datum/NexusHotkeyEditor/editor = client:nexus_hotkey_editor
	if(!editor || editor.owner != src)
		client:nexus_hotkey_editor = new /datum/NexusHotkeyEditor(src)
		editor = client:nexus_hotkey_editor
	editor.show()

mob/proc/toggleNexusHotkeyEditor()
	if(!client) return
	if(nexus_hotkey_editor_open)
		hideNexusHotkeyEditor()
		return
	showNexusHotkeyEditor()

mob/proc/hideNexusHotkeyEditor()
	if(!client) return
	nexus_hotkey_editor_open = 0
	src << browse(null, "window=NexusHotkeys")
	Hotkey_server_backup_save()
	client.syncNexusHotkeyMacros()
