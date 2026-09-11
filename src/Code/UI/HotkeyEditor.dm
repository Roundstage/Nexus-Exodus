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
	nexus_classic_slot_keys_version = 0
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
	if(!hotkey_object || hotkey_object.loc != src) return 0
	if(!hotkey_object.can_hotbar && !istype(hotkey_object, /obj/items)) return 0
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
	if(binding_info["kind"] == "slot") return resolveClassicSlot(binding_info["slot"])
	if(binding_info["kind"] == "action")
		var/datum/NexusHotkeyAction/action = getNexusHotkeyAction(binding_info["action id"])
		if(action && action.isAvailable(src)) return action
	if(binding_info["kind"] == "object") return resolveNexusHotkeyObject(binding_info)

mob/proc/executeNexusHotkeyAction(hotkey_action)
	if(client && client.nexus_classic_typing) return 0
	if(istype(hotkey_action, /datum/NexusHotkeyAction))
		var/datum/NexusHotkeyAction/action = hotkey_action
		return action.execute(src)
	if(isobj(hotkey_action))
		var/obj/hotkey_object = hotkey_action
		if(!isNexusHotkeyObjectAvailable(hotkey_object)) return 0
		if(!hascall(hotkey_object, "Hotbar_use"))
			if(istype(hotkey_object, /obj/items))
				hotkey_object.Click()
				return 1
			return 0
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
	initializeClassicSlots()
	populateClassicDefaultSlots()
	migrateClassicSlotKeys()
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
	if(binding_info["kind"] == "slot")
		initializeClassicSlots()
		var/index = binding_info["slot"]
		if(isnum(index) && index == round(index) && index >= 1 && index <= nexus_classic_slots.len)
			var/list/binding = nexus_classic_slots[index]
			var/bar_id = classicBarForSlot(index)
			var/list/bar = nexus_classic_bars[bar_id]
			var/list/indexes = islist(bar) ? bar["slots"] : list()
			return "[islist(bar) ? bar["name"] : "Bar"] / slot [indexes.Find(index)]: [islist(binding) ? binding["display name"] : "Empty"]"
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
		var/list/binding = mob.nexus_hotkey_bindings[combination]
		if(!islist(binding) || (binding["kind"] != "slot" && !mob.resolveNexusHotkeyBinding(combination))) continue
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
	if(nexus_hotkey_editor_open || (client && client.nexus_classic_typing)) return
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

mob/proc/buildNexusHotkeyEditorHtml(datum/NexusHotkeyEditor/editor)
	initializeNexusHotkeys()
	prepareNexusHudBrowserResources(src)
	src << browse_rsc('src/Code/UI/Browser/ClassicHud.css', "ClassicHud.css")
	src << browse_rsc('src/Code/UI/Browser/HotbarEditor.css', "HotbarEditor.css")
	src << browse_rsc('src/Code/UI/Browser/HotbarEditor.js', "HotbarEditor.js")
	initializeClassicBars()
	if(!(editor.bar_id in nexus_classic_bars)) editor.bar_id = nexus_classic_bars.len ? nexus_classic_bars[1] : ""
	var/list/bar = nexus_classic_bars[editor.bar_id]
	var/list/indexes = islist(bar) ? bar["slots"] : list()
	editor.page = Clamp(editor.page, 1, max(1, round((indexes.len + 11) / 12)))
	if(!(editor.selected_slot in indexes)) editor.selected_slot = indexes.len ? indexes[(editor.page - 1) * 12 + 1] : 0
	var/list/bars = list()
	for(var/id in nexus_classic_bars)
		var/list/entry = nexus_classic_bars[id]
		var/list/entry_slots = entry["slots"]
		bars += list(list("id" = id, "name" = entry["name"], "count" = entry_slots.len))
	var/list/bindings = list()
	for(var/combination in nexus_hotkey_bindings)
		var/list/binding = nexus_hotkey_bindings[combination]
		bindings += list(list("key" = combination, "fingerprint" = md5(json_encode(binding)), "name" = getNexusBindingDisplayName(binding), "slot" = binding["kind"] == "slot" ? binding["slot"] : 0))
	var/list/config = list("ref" = "\ref[editor]", "selected" = editor.selected_slot, "pendingAction" = editor.pending_action, "bar" = editor.bar_id, "bars" = bars, "page" = editor.page, "pages" = max(1, round((indexes.len + 11) / 12)), "count" = indexes.len, "slots" = buildClassicActionBar(FALSE, editor.bar_id, editor.page), "actions" = buildClassicActionCatalog(), "bindings" = bindings, "keys" = nexus_hotkey_base_keys, "columns" = islist(bar) ? bar["columns"] : 1, "size" = islist(bar) ? bar["size"] : 40, "locked" = islist(bar) ? bar["locked"] : FALSE, "name" = islist(bar) ? bar["name"] : "", "notice" = editor.notice)
	var/encoded_config = url_encode(json_encode(config))
	return {"<!doctype html><html><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'><link rel='stylesheet' href='ClassicHud.css'><link rel='stylesheet' href='HotbarEditor.css'></head><body><script>window.hotbarConfig=JSON.parse(decodeURIComponent('[encoded_config]'));</script><script src='HotbarEditor.js'></script></body></html>"}

datum/NexusHotkeyEditor
	var/tmp/mob/owner
	var/tmp/selected_slot = 1
	var/tmp/bar_id = "bar"
	var/tmp/page = 1
	var/tmp/pending_action = ""
	var/tmp/notice = ""

	New(mob/new_owner)
		. = ..()
		owner = new_owner

	proc/show()
		if(!owner || !owner.client) return
		owner << browse(owner.buildNexusHotkeyEditorHtml(src), "window=NexusHotkeys;size=860x620;can_resize=true;can_close=false")

	Topic(href, list/href_list)
		if(!owner || usr != owner || !owner.client || !owner.nexus_hotkey_editor_open) return
		owner.initializeClassicBars()
		if(href_list["bar"] in owner.nexus_classic_bars) bar_id = href_list["bar"]
		var/list/bar = owner.nexus_classic_bars[bar_id]
		var/list/indexes = islist(bar) ? bar["slots"] : list()
		var/index = text2num(href_list["slot"])
		if(isnum(index) && index == round(index) && index >= 1 && index <= 36) selected_slot = index
		notice = ""
		switch(href_list["action"])
			if("assign") owner.assignClassicSlot(selected_slot, href_list["token"])
			if("swap") owner.swapClassicSlots(selected_slot, text2num(href_list["from"]))
			if("clear_slot") owner.clearClassicSlot(selected_slot)
			if("select_bar")
				page = 1
				selected_slot = 0
			if("page")
				page = max(1, round(classicNumber(text2num(href_list["page"]), 1)))
				selected_slot = 0
			if("add_bar")
				bar_id = owner.createClassicBar()
				selected_slot = 0
				page = 1
			if("remove_bar")
				owner.removeClassicBar(bar_id)
				selected_slot = 0
				page = 1
			if("add_slot")
				selected_slot = owner.addClassicBarSlots(bar_id, text2num(href_list["count"]))
				page = max(1, round((indexes.len + 11) / 12))
			if("remove_slot") owner.removeClassicBarSlot(bar_id, selected_slot)
			if("bind")
				if(!(selected_slot in indexes)) return
				var/combination = canonicalNexusHotkey(href_list["key"], href_list["ctrl"] == "1", href_list["shift"] == "1", href_list["alt"] == "1", href_list["double"] == "1" ? 2 : 1)
				if(!combination || (getNexusHotkeyBase(combination) in list("F1", "F2")) || getNexusHotkeyTriggerCombination(combination) == "ALT+F4")
					notice = "This key is reserved or unsupported."
				else
					var/list/current = owner.nexus_hotkey_bindings[combination]
					// The client must acknowledge the exact binding it saw, including concurrent changes.
					if(islist(current) && !(current["kind"] == "slot" && current["slot"] == selected_slot) && href_list["replace"] != md5(json_encode(current)))
						notice = "[combination] is already assigned to [owner.getNexusBindingDisplayName(current)]. Select it again to confirm replacement."
					else
						owner.bindNexusHotkey(combination, list("kind" = "slot", "slot" = selected_slot))
						notice = "[combination] activates slot [selected_slot]."
			if("unbind") owner.unbindNexusHotkey(href_list["key"])
			if("layout")
				if(!islist(bar)) return
				bar["name"] = copytext(href_list["name"], 1, 81)
				bar["columns"] = Clamp(round(classicNumber(text2num(href_list["columns"]), 1)), 1, max(1, indexes.len))
				bar["size"] = Clamp(round(classicNumber(text2num(href_list["size"]), 40)), 32, 64)
				bar["locked"] = href_list["locked"] == "1"
				owner.fitClassicBar(bar_id)
			if("open_bar") owner.showClassicWidget(bar_id)
			if("hide_bar")
				if(owner.client.nexus_classic_hud) owner.client.nexus_classic_hud.setOpen(bar_id, FALSE)
			if("close")
				owner.hideNexusHotkeyEditor()
				return
		owner.classicBarChanged()
		show()

mob/proc/showNexusHotkeyEditor(selected_slot = 1, bar_id, action_token)
	if(!client) return
	Remove_Duplicate_Moves()
	StopMovement()
	initializeNexusHotkeys()
	for(var/held_key in keys_down.Copy()) HandleKeyUp(held_key)
	winset(src, "mapwindow", "macro=classictyping")
	nexus_hotkey_editor_open = 1
	var/datum/NexusHotkeyEditor/editor = client:nexus_hotkey_editor
	if(!editor || editor.owner != src)
		client:nexus_hotkey_editor = new /datum/NexusHotkeyEditor(src)
		editor = client:nexus_hotkey_editor
	initializeClassicBars()
	if(bar_id && islist(nexus_classic_bars[bar_id])) editor.bar_id = bar_id
	editor.pending_action = action_token
	editor.selected_slot = selected_slot
	editor.page = 1
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
	client.nexus_classic_typing = FALSE
	winset(src, "mapwindow", "macro=macro")
	winset(src, "mapwindow.map", "focus=true")
	src << browse(null, "window=NexusHotkeys")
	Hotkey_server_backup_save()
	client.syncNexusHotkeyMacros()
