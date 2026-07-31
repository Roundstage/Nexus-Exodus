#define NEXUS_HOTKEY_VERSION 1

var/list/nexus_hotkey_base_keys = list(\
	"Space", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",\
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",\
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",\
	"Numpad0", "Numpad1", "Numpad2", "Numpad3", "Numpad4", "Numpad5",\
	"Numpad6", "Numpad7", "Numpad8", "Numpad9", "Multiply", "Add", "Subtract", "Divide", "Separator",\
	"F3", "F4", "F7", "F8", "F9", "F10", "F12", "Back", "Insert", "Delete", "Pause")

var/list/nexus_static_hotkey_base_keys = list(\
	"Space", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",\
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",\
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",\
	"Numpad0", "Numpad1", "Numpad2", "Numpad3", "Numpad4", "Numpad5",\
	"Numpad6", "Numpad7", "Numpad8", "Numpad9")

proc/normalizeNexusHotkeyBase(base_key)
	if(!istext(base_key)) return
	for(var/allowed_key in nexus_hotkey_base_keys)
		if(lowertext(allowed_key) == lowertext(base_key)) return allowed_key

proc/canonicalNexusHotkey(base_key, use_ctrl = 0, use_shift = 0, use_alt = 0)
	base_key = normalizeNexusHotkeyBase(base_key)
	if(!base_key) return
	var/combination = ""
	if(use_ctrl) combination += "CTRL+"
	if(use_shift) combination += "SHIFT+"
	if(use_alt) combination += "ALT+"
	return "[combination][base_key]"

proc/getNexusHotkeyBase(combination)
	if(!istext(combination)) return
	var/list/parts = dd_text2list(combination, "+")
	if(!parts.len) return
	return normalizeNexusHotkeyBase(parts[parts.len])

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

proc/getNexusHotkeyAction(action_id)
	initializeNexusHotkeyActionRegistry()
	return nexus_hotkey_action_registry[action_id]

mob/var/tmp
	list/nexus_hotkey_bindings = new
	nexus_hotkey_version
	list/active_nexus_hotkey_actions = new
	list/active_nexus_hotkey_combinations = new
	list/nexus_hotkey_editor_actions = new
	nexus_hotkey_editor_open

client/var/tmp
	list/generated_nexus_hotkey_macros = new
	nexus_hotkey_editor

mob/proc/isNexusHotkeyObjectAvailable(obj/hotkey_object)
	if(!hotkey_object || hotkey_object.loc != src || !hotkey_object.can_hotbar) return 0
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
	if(nexus_hotkey_version < NEXUS_HOTKEY_VERSION)
		migrateLegacyHotkeyBindings()
		nexus_hotkey_version = NEXUS_HOTKEY_VERSION
	if(client) client.syncNexusHotkeyMacros()

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
	if(combination == "ALT+F4") return 0
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
	var/list/generated_up_keys = list()
	var/macro_number = 0
	for(var/combination in mob.nexus_hotkey_bindings)
		if(!mob.resolveNexusHotkeyBinding(combination)) continue
		var/base_key = getNexusHotkeyBase(combination)
		if(!base_key) continue
		var/is_static_bare_key = combination == base_key && (base_key in nexus_static_hotkey_base_keys)
		if(is_static_bare_key) continue
		macro_number++
		var/down_id = "nexus_hotkey_[macro_number]_down"
		winset(src, down_id, list("parent" = "macro", "name" = combination, "command" = "nexusHotkeyDown [combination] [base_key]"))
		generated_nexus_hotkey_macros += down_id
		if(!(base_key in nexus_static_hotkey_base_keys) && !(base_key in generated_up_keys))
			var/up_id = "nexus_hotkey_[macro_number]_up"
			winset(src, up_id, list("parent" = "macro", "name" = "[base_key]+UP", "command" = "nexusHotkeyUp [base_key]"))
			generated_nexus_hotkey_macros += up_id
			generated_up_keys += base_key

mob/verb/nexusHotkeyDown(combination as text, base_key as text)
	set hidden = 1
	set instant = 1
	set waitfor = 0
	if(nexus_hotkey_editor_open) return
	base_key = normalizeNexusHotkeyBase(base_key)
	if(!base_key || !resolveNexusHotkeyBinding(combination)) return
	for(var/repetition in 1 to 3) keys_down -= base_key
	keys_down += base_key
	HotbarUseHandler(combination, base_key)

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
		badges += "<span class='binding'>[html_encode(combination)] - [display_name]<button onclick=\"event.stopPropagation();clearBinding('[combination]')\">x</button></span>"
	return badges

mob/proc/renderNexusVirtualKey(base_key, display_label)
	var/key_class = base_key == "Space" ? "key space-key" : "key"
	return "<div class='[key_class]' ondragover='event.preventDefault()' ondrop=\"dropAction(event,'[base_key]')\"><strong>[html_encode(display_label || base_key)]</strong>[getNexusKeyBindingBadges(base_key)]</div>"

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

	var/keyboard_html = ""
	keyboard_html += "<div class='key-row'>"
	for(var/key_name in list("F3", "F4", "F7", "F8", "F9", "F10", "F12", "Back", "Insert", "Delete", "Pause")) keyboard_html += renderNexusVirtualKey(key_name, key_name)
	keyboard_html += "</div><div class='key-row'>"
	for(var/key_name in list("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")) keyboard_html += renderNexusVirtualKey(key_name, key_name)
	keyboard_html += "</div><div class='key-row offset-one'>"
	for(var/key_name in list("Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P")) keyboard_html += renderNexusVirtualKey(key_name, key_name)
	keyboard_html += "</div><div class='key-row offset-two'>"
	for(var/key_name in list("A", "S", "D", "F", "G", "H", "J", "K", "L")) keyboard_html += renderNexusVirtualKey(key_name, key_name)
	keyboard_html += "</div><div class='key-row offset-three'>"
	for(var/key_name in list("Z", "X", "C", "V", "B", "N", "M")) keyboard_html += renderNexusVirtualKey(key_name, key_name)
	keyboard_html += "</div><div class='key-row space-row'>[renderNexusVirtualKey("Space", "SPACE")]</div>"

	var/numpad_html = ""
	for(var/key_name in list("Numpad7", "Numpad8", "Numpad9", "Divide", "Numpad4", "Numpad5", "Numpad6", "Multiply", "Numpad1", "Numpad2", "Numpad3", "Subtract", "Numpad0", "Separator", "Add"))
		numpad_html += renderNexusVirtualKey(key_name, replacetext(key_name, "Numpad", "NUM "))

	var/binding_summary = ""
	for(var/combination in nexus_hotkey_bindings)
		var/list/binding_info = nexus_hotkey_bindings[combination]
		binding_summary += "<div><code>[html_encode(combination)]</code><span>[html_encode(getNexusBindingDisplayName(binding_info))]</span><button onclick=\"clearBinding('[combination]')\">Remove</button></div>"
	if(!binding_summary) binding_summary = "<p class='empty'>No bindings configured.</p>"

	return {"<!doctype html>
	<html><head><meta charset='utf-8'><title>Nexus Hotkeys</title><style>
	*{box-sizing:border-box}body{margin:0;background:#070b12;color:#edf2fa;font:13px Arial,sans-serif;overflow:hidden}
	.shell{height:100vh;display:grid;grid-template-columns:300px 1fr;background:radial-gradient(circle at 75% 20%,#18203a 0,#090e18 42%,#05080e 100%)}
	.catalog{padding:22px 18px;border-right:1px solid #2c3547;background:rgba(8,12,20,.92);overflow:auto}.catalog h1{margin:0 0 4px;font-size:22px;letter-spacing:.08em}.catalog p{margin:0 0 15px;color:#8d9bb0}.catalog input{width:100%;padding:10px;border:1px solid #38445b;background:#101722;color:white;border-radius:4px;margin-bottom:12px}
	.action-card{padding:10px 12px;margin:7px 0;border:1px solid #343f55;border-left:4px solid #9d77ff;background:#111925;cursor:grab;border-radius:4px}.action-card:hover{border-color:#b99cff;background:#172235}.action-card b{display:block}.action-card span{font-size:10px;text-transform:uppercase;letter-spacing:.12em;color:#7f90aa}
	.workspace{padding:18px 22px;overflow:auto}.toolbar{display:flex;align-items:center;gap:16px;margin-bottom:16px}.toolbar h2{margin:0 auto 0 0;font-size:16px;letter-spacing:.08em}.modifier{padding:8px 11px;border:1px solid #3a4760;background:#111925;border-radius:4px}.toolbar button,.summary button{border:1px solid #4b5870;background:#151e2d;color:#eaf0f9;padding:7px 10px;border-radius:3px;cursor:pointer}.toolbar button:hover,.summary button:hover{border-color:#ff7d66}
	.keyboard-wrap{display:grid;grid-template-columns:minmax(650px,1fr) 275px;gap:18px}.keyboard{padding:15px;border:1px solid #2e394e;background:rgba(11,17,28,.82);border-radius:8px}.key-row{display:flex;gap:6px;margin-bottom:6px}.offset-one{padding-left:20px}.offset-two{padding-left:38px}.offset-three{padding-left:62px}.space-row{justify-content:center;margin-top:9px}
	.key{position:relative;min-width:58px;min-height:55px;flex:1;padding:8px 5px;border:1px solid #46536b;border-bottom:3px solid #252e3e;background:linear-gradient(#1c2738,#111824);border-radius:5px;color:#dce6f5;text-align:center;overflow:hidden}.key:hover{border-color:#a887ff;box-shadow:0 0 12px rgba(157,119,255,.2)}.key strong{font:11px Consolas,monospace;letter-spacing:.05em}.space-key{max-width:440px;min-height:62px}
	.binding{display:block;margin-top:4px;padding:2px 18px 2px 3px;background:#44316f;color:#f1eaff;font-size:8px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;position:relative}.binding button{position:absolute;right:2px;top:0;border:0;background:none;color:#ff9b87;cursor:pointer}
	.numpad{display:grid;grid-template-columns:repeat(4,1fr);gap:6px;padding:15px;border:1px solid #2e394e;background:rgba(11,17,28,.82);border-radius:8px}.numpad .key{min-width:0;min-height:69px}
	.summary{margin-top:18px;border-top:1px solid #303a4d;padding-top:12px}.summary h3{font-size:12px;text-transform:uppercase;letter-spacing:.12em;color:#9aa9bf}.summary>div{display:grid;grid-template-columns:180px 1fr auto;align-items:center;gap:12px;padding:6px 8px;border-bottom:1px solid #202a39}.summary code{color:#c9b7ff}.empty{color:#78879c}
	.hint{color:#93a1b6;font-size:11px;margin:10px 0}.warning{color:#ff9a80}
	</style></head><body><div class='shell'>
	<aside class='catalog'><h1>ACTION DECK</h1><p>Drag an available action onto a key.</p><input id='filter' placeholder='Filter actions...' oninput='filterActions()'>[actions_html]</aside>
	<main class='workspace'><div class='toolbar'><h2>VIRTUAL KEYBOARD</h2><label class='modifier'><input id='ctrl' type='checkbox'[editor.use_ctrl ? " checked" : ""]> CTRL</label><label class='modifier'><input id='shift' type='checkbox'[editor.use_shift ? " checked" : ""]> SHIFT</label><label class='modifier'><input id='alt' type='checkbox'[editor.use_alt ? " checked" : ""]> ALT</label><button onclick='importLegacy()'>Import legacy</button><button onclick='clearAll()'>Clear all</button><button onclick='closeEditor()'>Close</button></div>
	<p class='hint'>Select modifiers, then drop an action. Numpad keys are independent from number-row keys. <span class='warning'>System keys and ALT+F4 are reserved.</span></p>
	<div class='keyboard-wrap'><section class='keyboard'>[keyboard_html]</section><section class='numpad'>[numpad_html]</section></div>
	<section class='summary'><h3>Active bindings</h3>[binding_summary]</section></main></div>
	<script>
	var handlerRef='\ref[editor]';
	function sendTopic(data){data.src=handlerRef;if(window.BYOND&&BYOND.topic){BYOND.topic(data);return;}var query='';for(var key in data){if(query)query+='&';query+=encodeURIComponent(key)+'='+encodeURIComponent(data\[key\]);}window.location.href='byond://?'+query;}
	function startDrag(event,id){event.dataTransfer.setData('text/plain',id);}
	function modifiers(){return{ctrl:document.getElementById('ctrl').checked?'1':'0',shift:document.getElementById('shift').checked?'1':'0',alt:document.getElementById('alt').checked?'1':'0'};}
	function dropAction(event,key){event.preventDefault();var m=modifiers();sendTopic({action:'bind',action_token:event.dataTransfer.getData('text/plain'),base_key:key,ctrl:m.ctrl,shift:m.shift,alt:m.alt});}
	function clearBinding(combo){sendTopic({action:'unbind',combination:combo});}
	function clearAll(){if(confirm('Remove every custom binding?'))sendTopic({action:'clear'});}
	function importLegacy(){sendTopic({action:'import_legacy'});}
	function closeEditor(){sendTopic({action:'close'});}
	function filterActions(){var query=document.getElementById('filter').value.toLowerCase();var cards=document.getElementsByClassName('action-card');for(var i=0;i<cards.length;i++)cards\[i\].style.display=cards\[i\].innerText.toLowerCase().indexOf(query)>=0?'block':'none';}
	</script></body></html>"}

datum/NexusHotkeyEditor
	var/tmp/mob/owner
	var/tmp/use_ctrl
	var/tmp/use_shift
	var/tmp/use_alt

	New(mob/new_owner)
		. = ..()
		owner = new_owner

	proc/show()
		if(!owner || !owner.client) return
		owner << browse(owner.buildNexusHotkeyEditorHtml(src), "window=NexusHotkeys;size=1180x760;can_resize=true;can_close=false")

	Topic(href, list/href_list)
		if(!owner || usr != owner || !owner.client) return
		var/action = href_list["action"]
		switch(action)
			if("bind")
				var/base_key = normalizeNexusHotkeyBase(href_list["base_key"])
				use_ctrl = text2num(href_list["ctrl"])
				use_shift = text2num(href_list["shift"])
				use_alt = text2num(href_list["alt"])
				var/combination = canonicalNexusHotkey(base_key, use_ctrl, use_shift, use_alt)
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

mob/proc/hideNexusHotkeyEditor()
	if(!client) return
	nexus_hotkey_editor_open = 0
	src << browse(null, "window=NexusHotkeys")
	Hotkey_server_backup_save()
	client.syncNexusHotkeyMacros()
