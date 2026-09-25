proc/runClassicResponsiveLayoutSmokeTests()
	var/list/layout = list(
		"chat" = list("x" = 1360, "y" = 520, "w" = 550, "h" = 450, "open" = TRUE),
		"bar" = list("x" = 680, "y" = 986, "w" = 541, "h" = 94, "open" = TRUE),
		"bar_2" = list("x" = 1260, "y" = 720, "w" = 80, "h" = 223, "open" = TRUE))
	var/original = json_encode(layout)
	for(var/list/size in list(list(1003, 625), list(800, 600), list(640, 480), list(1920, 1080), list(2560, 1080)))
		var/width = size[1]
		var/height = size[2]
		var/scale = classicHudScale(1920, 1080, width, height)
		var/list/placed = list()
		for(var/id in layout)
			var/list/state = layout[id]
			var/list/display = scaleClassicGeometry(state, 1920, 1080, width, height)
			nexusSmokeAssert(display["scale"] == scale && display["content_w"] == state["w"] && display["content_h"] == state["h"], "Classic [id] changed its logical content instead of scaling it")
			nexusSmokeAssert(abs(display["w"] - state["w"] * scale) < 1.01 && abs(display["h"] - state["h"] * scale) < 1.01, "Classic [id] lost proportional size at [width]x[height]")
			nexusSmokeAssert(display["x"] >= 0 && display["y"] >= 0 && display["x"] + display["w"] <= width && display["y"] + display["h"] <= height, "Classic [id] escaped [width]x[height]")
			for(var/list/other in placed)
				nexusSmokeAssert(display["x"] >= other["x"] + other["w"] || display["x"] + display["w"] <= other["x"] || display["y"] >= other["y"] + other["h"] || display["y"] + display["h"] <= other["y"], "Classic scaling overlapped formerly separate panels")
			placed += list(display)
		nexusSmokeAssert(json_encode(layout) == original, "Classic window resize modified the saved layout")
	var/list/chat = layout["chat"]
	var/list/restored = scaleClassicGeometry(chat, 1920, 1080, 1920, 1080)
	for(var/key in list("x", "y", "w", "h"))
		nexusSmokeAssert(restored[key] == chat[key], "Classic failed to restore [key] at reference resolution")
	var/list/display = scaleClassicGeometry(chat, 1920, 1080, 1003, 625)
	display["x"] -= 40
	display["y"] -= 30
	var/list/moved = unscaleClassicGeometry(display, chat, "chat", 1920, 1080, 1003, 625)
	var/list/projected = scaleClassicGeometry(moved, 1920, 1080, 1003, 625)
	nexusSmokeAssert(abs(projected["x"] - display["x"]) <= 1 && abs(projected["y"] - display["y"]) <= 1 && moved["w"] == chat["w"] && moved["h"] == chat["h"], "Classic scaled drag drifted or changed panel size")
	display["w"] += 20
	display["h"] += 15
	var/list/resized = unscaleClassicGeometry(display, chat, "chat", 1920, 1080, 1003, 625)
	nexusSmokeAssert(resized["w"] > chat["w"] && resized["h"] > chat["h"], "Classic scaled resize failed to update logical dimensions")
	var/list/collapsed = chat.Copy()
	collapsed["collapsed"] = TRUE
	collapsed["open"] = FALSE
	display = scaleClassicGeometry(collapsed, 1920, 1080, 960, 540)
	nexusSmokeAssert(display["h"] == 13 && display["collapsed"] && !display["open"], "Classic collapsed header did not scale or changed visibility")
	var/list/old_chat = list("x" = 8, "y" = 170, "w" = 550, "h" = 335, "open" = FALSE, "preferred" = chat.Copy())
	old_chat["preferred"]["viewport_w"] = 1920
	old_chat["preferred"]["viewport_h"] = 1080
	var/list/old_layout = list("chat" = old_chat)
	var/list/reference = migrateClassicLayout(old_layout, list("w" = 1003, "h" = 625))
	nexusSmokeAssert(reference["reference_w"] == 1920 && reference["reference_h"] == 1080 && old_layout["chat"]["x"] == chat["x"] && old_layout["chat"]["h"] == chat["h"] && !old_layout["chat"]["open"] && !old_layout["chat"]["preferred"], "Classic migration kept the discarded rearrangement instead of the player's placement")
	old_layout = json_decode(json_encode(old_layout))
	reference = migrateClassicLayout(old_layout, json_decode(json_encode(reference)))
	nexusSmokeAssert(reference["reference_w"] == 1920 && old_layout["chat"]["x"] == 1360, "Classic settings reload lost its scaling reference")

mob/NexusSmokeTest/StarterHotkeyProbe
	var/tmp/last_hotkey_action

	executeNexusHotkeyAction(hotkey_action)
		last_hotkey_action = hotkey_action
		return TRUE

proc/runStarterHotkeySmokeTests()
	// Reproduce settings/HUD initialization before legacy defaults and basic proxy objects exist.
	var/mob/NexusSmokeTest/StarterHotkeyProbe/early = new
	early.initializeNexusHotkeys()
	nexusSmokeAssert(early.nexus_hotkey_version < 3, "early HUD initialization consumed the pending starter hotkey migration")
	early.bindNexusHotkey("ALT+F6", list("kind" = "action", "action id" = "cycle_target"))
	nexusSmokeAssert(early.nexus_hotkey_version < 3, "an early custom key consumed the pending starter hotkey migration")
	early.playerCharacter = TRUE
	early.Add_hotbar_proxies()
	early.Generate_starter_hotbar()
	early.initializeNexusHotkeys()
	var/obj/Meditate/meditate = locate(/obj/Meditate) in early
	var/obj/Train/train = locate(/obj/Train) in early
	nexusSmokeAssert(early.resolveNexusHotkeyBinding("J") == meditate && early.resolveNexusHotkeyBinding("K") == train, "late-loaded starter defaults did not bind J Meditate and K Train")
	early.HandleKeyDown("J")
	nexusSmokeAssert(early.last_hotkey_action == meditate, "J did not dispatch the Meditate action through the gameplay key handler")
	early.HandleKeyDown("K")
	nexusSmokeAssert(early.last_hotkey_action == train, "K did not dispatch the Train action through the gameplay key handler")
	var/list/directions = list("North" = NORTH, "Northeast" = NORTHEAST, "East" = EAST, "Southeast" = SOUTHEAST, "South" = SOUTH, "Southwest" = SOUTHWEST, "West" = WEST, "Northwest" = NORTHWEST)
	for(var/direction_name in directions)
		var/combination = "CTRL+[direction_name]"
		var/datum/NexusHotkeyAction/DefensiveDash/dash = early.resolveNexusHotkeyBinding(combination)
		nexusSmokeAssert(istype(dash) && dash.dash_direction == directions[direction_name], "starter Ctrl direction did not bind the correct Short Dash: [combination]")
		early.nexusHotkeyDown(combination, direction_name)
		nexusSmokeAssert(early.last_hotkey_action == dash, "Ctrl directional hotkey did not dispatch its Short Dash: [combination]")
		early.nexusHotkeyUp(direction_name)
	// Once migrated, a removed binding must stay removed even if the old table still contains it.
	early.hotbar.len = keys.len
	early.hotbar[keys.Find("J")] = meditate
	early.unbindNexusHotkey("J")
	early.initializeNexusHotkeys()
	early.last_hotkey_action = null
	early.HandleKeyDown("J")
	nexusSmokeAssert(!("J" in early.nexus_hotkey_bindings) && !early.last_hotkey_action, "removed modern hotkey was restored or executed through the legacy fallback")
	var/list/train_binding = early.nexus_hotkey_bindings["K"]
	nexusSmokeAssert(train_binding["kind"] == "object", "starter Train key unnecessarily occupies a bar slot")
	early.nexus_classic_slots[1] = early.classicBindingForObject(train)
	early.bindNexusHotkey("K", list("kind" = "slot", "slot" = 1))
	early.clearClassicSlot(1)
	early.hotbar[keys.Find("K")] = train
	early.last_hotkey_action = null
	early.HandleKeyDown("K")
	nexusSmokeAssert(!early.last_hotkey_action, "an empty modern bar slot executed its previous legacy action")
	early.Restore_starter_hotbar()
	nexusSmokeAssert(early.resolveNexusHotkeyBinding("J") == meditate && early.resolveNexusHotkeyBinding("K") == train && early.resolveNexusHotkeyBinding("CTRL+North") == getNexusHotkeyAction("short_dash_north") && !("ALT+F6" in early.nexus_hotkey_bindings), "explicit starter reset did not restore modern basic/dash keys")
	del(early)

	var/mob/NexusSmokeTest/fresh = new
	fresh.playerCharacter = TRUE
	fresh.Add_hotbar_proxies()
	fresh.initializeNexusHotkeys()
	nexusSmokeAssert(istype(fresh.resolveNexusHotkeyBinding("J"), /obj/Meditate) && istype(fresh.resolveNexusHotkeyBinding("K"), /obj/Train) && istype(fresh.resolveNexusHotkeyBinding("Space"), /obj/Manual_Attack) && istype(fresh.resolveNexusHotkeyBinding("W"), /obj/Move_Up), "new character without a legacy table did not receive its default basic keys")
	nexusSmokeAssert(fresh.nexus_classic_slots.len == 12 && fresh.nexus_hotkey_version == 3, "starter initialization overflowed the first bar or did not finish migration")
	for(var/index in 1 to fresh.nexus_classic_slots.len)
		var/action = fresh.resolveClassicSlot(index)
		nexusSmokeAssert(!istype(action, /obj/Meditate) && !istype(action, /obj/Train), "starter bar was populated with Meditate or Train")
	nexusSmokeAssert(!fresh.resolveNexusHotkeyBinding("R") && !(locate(/obj/Fly) in fresh), "installing starter keys granted an unlearned skill")
	var/obj/Fly/fly = new(fresh)
	nexusSmokeAssert(fresh.resolveNexusHotkeyBinding("R") == fly, "a reserved default key did not activate after its skill was learned")
	del(fresh)

	// Repair a version-2 partial backup without changing an existing bar or an occupied key.
	var/mob/NexusSmokeTest/partial = new
	partial.playerCharacter = TRUE
	partial.Add_hotbar_proxies()
	partial.nexus_hotkey_version = 2
	partial.nexus_classic_slot_keys_version = 1
	partial.nexus_classic_slots = list()
	partial.nexus_classic_slots.len = 2
	partial.nexus_classic_slots[1] = partial.classicBindingForObject(locate(/obj/Meditate) in partial)
	partial.nexus_hotkey_bindings = list("K" = list("kind" = "slot", "slot" = 2), "CTRL+North" = list("kind" = "action", "action id" = "cycle_target"))
	partial.hotbar_ids = list("custom-legacy-train" = list("hotbar position" = keys.Find("C"), "object type" = /obj/Train))
	var/bar_before = json_encode(partial.nexus_classic_slots)
	partial.initializeNexusHotkeys()
	nexusSmokeAssert(partial.nexus_hotkey_bindings["J"]["kind"] == "object" && istype(partial.resolveNexusHotkeyBinding("J"), /obj/Meditate), "repair did not create an independent J shortcut for Meditate")
	nexusSmokeAssert(partial.nexus_hotkey_bindings["K"]["slot"] == 2 && !partial.resolveNexusHotkeyBinding("K") && partial.resolveNexusHotkeyBinding("CTRL+North") == getNexusHotkeyAction("cycle_target") && json_encode(partial.nexus_classic_slots) == bar_before, "starter repair overwrote a custom shortcut, empty slot, or saved bar")
	nexusSmokeAssert(istype(partial.resolveNexusHotkeyBinding("C"), /obj/Train), "partial modern bindings prevented migration of a custom legacy shortcut")
	del(partial)

	var/mob/NexusSmokeTest/rebound = new
	rebound.playerCharacter = TRUE
	rebound.Add_hotbar_proxies()
	rebound.nexus_hotkey_version = 2
	rebound.nexus_hotkey_bindings = list("ALT+J" = rebound.classicBindingForObject(locate(/obj/Meditate) in rebound), "ALT+K" = rebound.classicBindingForObject(locate(/obj/Train) in rebound), "ALT+East" = list("kind" = "action", "action id" = "short_dash_east"))
	rebound.initializeNexusHotkeys()
	nexusSmokeAssert(!("J" in rebound.nexus_hotkey_bindings) && !("K" in rebound.nexus_hotkey_bindings) && !("CTRL+East" in rebound.nexus_hotkey_bindings) && istype(rebound.resolveNexusHotkeyBinding("ALT+J"), /obj/Meditate) && istype(rebound.resolveNexusHotkeyBinding("ALT+K"), /obj/Train) && rebound.resolveNexusHotkeyBinding("ALT+East") == getNexusHotkeyAction("short_dash_east"), "starter repair rebound actions that the player had already moved to other keys")
	var/bindings_before = json_encode(rebound.nexus_hotkey_bindings)
	rebound.initializeNexusHotkeys()
	nexusSmokeAssert(json_encode(rebound.nexus_hotkey_bindings) == bindings_before, "starter hotkey initialization changed an already migrated keymap")
	del(rebound)
	world.log << "NEXUS_STARTER_HOTKEY_TESTS_PASSED"

obj/items/Amulet/NexusMenuUseProbe
	catalog_test_only = TRUE
	var/use_count = 0
	var/mob/last_user
	Use()
		use_count++
		last_user = usr
	Click()
		CRASH("Inventory USE dispatched Amulet.Click instead of Amulet.Use")

obj/items/Fruit/NexusMenuUseProbe
	catalog_test_only = TRUE
	var/use_count = 0
	Use()
		use_count++
	Click()
		CRASH("Inventory USE dispatched Fruit.Click instead of Fruit.Use")

obj/items/NexusMenuClickProbe
	catalog_test_only = TRUE
	var/use_count = 0
	Click()
		use_count++

obj/Contract_Soul/NexusMenuSoulProbe
	catalog_test_only = TRUE
	var/use_count = 0
	Click()
		use_count++

proc/runNexusMenuActionsSmokeTests()
	var/mob/previous_usr = usr
	var/mob/NexusSmokeTest/owner = new
	var/mob/NexusSmokeTest/stranger = new
	usr = owner
	var/obj/items/Amulet/NexusMenuUseProbe/amulet = new(owner)
	var/obj/items/Fruit/NexusMenuUseProbe/fruit = new(owner)
	var/obj/items/NexusMenuClickProbe/click_item = new(owner)
	owner.item_list |= list(amulet, fruit, click_item)
	var/datum/NexusPlayerMenu/menu = new(owner)
	nexusSmokeAssert(menu.useOwnedItem(amulet) && amulet.use_count == 1 && amulet.last_user == owner, "Inventory USE did not execute the owned amulet's portal action with the correct user")
	nexusSmokeAssert(owner.useNexusInventoryItem(fruit) && fruit.use_count == 1, "embedded Inventory USE did not execute the fruit's use action")
	nexusSmokeAssert(menu.useOwnedItem(click_item) && click_item.use_count == 1, "Inventory lost the ordinary click fallback for items without Hotbar_use")
	amulet.loc = stranger
	nexusSmokeAssert(!menu.useOwnedItem(amulet) && amulet.use_count == 1, "a stale inventory reference executed an item transferred to another character")
	amulet.loc = owner
	var/datum/NexusTradeSmokeSession/trade = new(owner, stranger, FALSE)
	trade.invitation_accepted = TRUE
	trade.phase = "offer"
	nexusSmokeAssert(trade.addItem(owner, fruit), "menu test could not offer a fruit for trade")
	nexusSmokeAssert(!menu.useOwnedItem(fruit) && fruit.use_count == 1, "Inventory USE consumed a fruit locked in a trade offer")
	trade.removeItem(owner, fruit)
	del(trade)
	var/obj/Contract_Soul/NexusMenuSoulProbe/soul = new(owner)
	soul.name = "<Contracted Soul>"
	var/obj/Contract_Soul/NexusMenuSoulProbe/foreign_soul = new(stranger)
	foreign_soul.name = "Foreign Soul"
	menu.section = menu.normalizeSection("souls")
	var/souls_html = menu.buildContent()
	nexusSmokeAssert(menu.section == "souls" && findtext(menu.buildNavigation(), "id=souls"), "the replacement player menu does not expose its Souls section")
	nexusSmokeAssert(findtext(souls_html, "&lt;Contracted Soul&gt;") && findtext(souls_html, "Offline") && findtext(souls_html, "action=manage_soul") && !findtext(souls_html, "Foreign Soul"), "Souls omitted an offline contract or exposed another character's contract")
	nexusSmokeAssert(owner.manageNexusSoulContract(soul) && soul.use_count == 1, "Souls MANAGE did not reach the owned contract's actions")
	nexusSmokeAssert(!owner.manageNexusSoulContract(foreign_soul) && foreign_soul.use_count == 0, "Souls allowed interaction with another character's contract")
	soul.loc = stranger
	nexusSmokeAssert(!owner.manageNexusSoulContract(soul) && soul.use_count == 1, "Souls executed a stale contract reference after ownership changed")
	nexusSmokeAssert(findtext(menu.buildSouls(), "no contracted souls"), "Souls retained a stale row after losing its last contract")
	del(soul)
	del(foreign_soul)
	del(menu)
	del(amulet)
	del(fruit)
	del(click_item)
	del(owner)
	del(stranger)
	usr = previous_usr
	var/list/map_properties = params2list("mapwindow.is-visible=true;mapwindow.map.is-visible=true;mapwindow.classic_chat.is-visible=true;mapwindow.classic_bar_87.is-visible=true")
	var/list/browser_targets = getNexusLobbyBrowserTargets(map_properties, list("mainwindow", "NexusPlayerMenu", "NexusHotkeys", "NexusCharacterSelect", "InvisBrowser"))
	nexusSmokeAssert(("mapwindow.classic_bar_87" in browser_targets) && ("mapwindow.classic_chat" in browser_targets) && ("NexusPlayerMenu" in browser_targets) && ("NexusHotkeys" in browser_targets), "reconnect cleanup missed restored browsers or an orphaned dynamic hotbar")
	nexusSmokeAssert(!("mapwindow.map" in browser_targets) && !("mainwindow" in browser_targets) && !("NexusCharacterSelect" in browser_targets) && !("InvisBrowser" in browser_targets), "reconnect cleanup targeted the game map, login selector, or resolution browser")
	world.log << "NEXUS_MENU_ACTIONS_TESTS_PASSED"

proc/runIndependentHotkeySmokeTests()
	var/mob/NexusSmokeTest/StarterHotkeyProbe/owner = new
	owner.playerCharacter = TRUE
	owner.Add_hotbar_proxies()
	owner.initializeNexusHotkeys()
	owner.initializeClassicBars()
	var/obj/Meditate/meditate = locate(/obj/Meditate) in owner
	var/obj/Train/train = locate(/obj/Train) in owner
	var/datum/NexusHotkeyEditor/editor = new(owner)
	editor.binding_mode = "direct"
	var/bar_before = json_encode(owner.nexus_classic_slots)
	var/list/request = list("key" = "F6", "ctrl" = "1", "shift" = "1", "token" = "classic-skill:\ref[meditate]")
	nexusSmokeAssert(editor.bindKey(request) && owner.resolveNexusHotkeyBinding("CTRL+SHIFT+F6") == meditate && json_encode(owner.nexus_classic_slots) == bar_before, "independent binding failed or added its action to a bar")
	owner.nexusHotkeyDown("CTRL+SHIFT+F6", "F6")
	nexusSmokeAssert(owner.last_hotkey_action == meditate, "independent modifier hotkey did not dispatch through gameplay input")
	owner.nexusHotkeyUp("F6")
	var/list/meditate_binding = owner.nexus_hotkey_bindings["CTRL+SHIFT+F6"]
	var/old_fingerprint = md5(json_encode(meditate_binding))
	request["token"] = "classic-skill:\ref[train]"
	nexusSmokeAssert(!editor.bindKey(request) && owner.resolveNexusHotkeyBinding("CTRL+SHIFT+F6") == meditate, "direct binding silently replaced an existing shortcut")
	request["replace"] = "stale-fingerprint"
	nexusSmokeAssert(!editor.bindKey(request), "direct binding accepted a stale conflict acknowledgement")
	request["replace"] = old_fingerprint
	nexusSmokeAssert(editor.bindKey(request) && owner.resolveNexusHotkeyBinding("CTRL+SHIFT+F6") == train, "direct binding refused a confirmed replacement")
	request = list("key" = "F7", "double" = "1", "token" = "classic-action:cycle_target")
	nexusSmokeAssert(editor.bindKey(request) && owner.resolveNexusHotkeyBinding("DOUBLE:F7") == getNexusHotkeyAction("cycle_target"), "independent double-tap action was not bound")
	owner.verbs += /mob/verb/Settings
	request = list("key" = "F8", "token" = "classic-command:[md5("\ref[owner]|/mob/verb/Settings")]")
	nexusSmokeAssert(editor.bindKey(request) && istype(owner.resolveNexusHotkeyBinding("F8"), /datum/NexusHotkeyAction/ClassicVerb), "independent native command could not resolve")
	owner.verbs -= /mob/verb/Settings
	nexusSmokeAssert(!owner.resolveNexusHotkeyBinding("F8"), "independent native command retained a revoked verb")
	request["key"] = "F1"
	nexusSmokeAssert(!editor.bindKey(request), "direct editor accepted a reserved key")
	var/mob/NexusSmokeTest/stranger = new
	var/obj/Train/foreign_train = new(stranger)
	request = list("key" = "F9", "token" = "classic-skill:\ref[foreign_train]")
	nexusSmokeAssert(!editor.bindKey(request) && !("F9" in owner.nexus_hotkey_bindings), "direct editor accepted another character's action")
	owner.nexus_classic_slots[1] = owner.classicBindingForObject(meditate)
	owner.bindNexusHotkey("J", list("kind" = "slot", "slot" = 1))
	owner.bindNexusHotkey("ALT+J", list("kind" = "slot", "slot" = 1))
	nexusSmokeAssert(owner.moveClassicSlotToDirectHotkeys(1) && !owner.nexus_classic_slots[1] && owner.resolveNexusHotkeyBinding("J") == meditate && owner.resolveNexusHotkeyBinding("ALT+J") == meditate, "moving a bar action to independent hotkeys lost its keys or kept the slot occupied")
	owner.nexus_classic_slots[1] = owner.classicBindingForObject(train)
	owner.nexus_classic_slot_keys_version = 0
	owner.migrateClassicSlotKeys()
	nexusSmokeAssert(owner.nexus_hotkey_bindings["J"]["direct"] && owner.resolveNexusHotkeyBinding("J") == meditate && owner.nexus_hotkey_bindings["CTRL+SHIFT+F6"]["direct"], "slot migration recaptured an independent shortcut")
	owner.clearClassicSlot(1)
	var/savefile/backup = new
	backup["bindings"] << owner.nexus_hotkey_bindings
	owner.nexus_hotkey_bindings = null
	backup["bindings"] >> owner.nexus_hotkey_bindings
	owner.initializeNexusHotkeys()
	nexusSmokeAssert(owner.resolveNexusHotkeyBinding("J") == meditate && owner.resolveNexusHotkeyBinding("CTRL+SHIFT+F6") == train && owner.nexus_hotkey_bindings["J"]["direct"], "independent shortcuts did not survive save/reload and initialization")
	owner.removeClassicBar("bar")
	nexusSmokeAssert(owner.resolveNexusHotkeyBinding("J") == meditate, "deleting a bar also deleted an independent hotkey")
	request = list("key" = "F9", "token" = "classic-skill:\ref[meditate]")
	nexusSmokeAssert(editor.bindKey(request) && owner.nexus_classic_bars.len == 0, "binding a direct key requires or recreates a visible bar")
	owner.unbindNexusHotkey("F9")
	owner.initializeNexusHotkeys()
	nexusSmokeAssert(!owner.resolveNexusHotkeyBinding("F9"), "initialization restored an explicitly removed direct hotkey")
	del(foreign_train)
	del(stranger)
	del(editor)
	del(owner)
	world.log << "NEXUS_INDEPENDENT_HOTKEY_TESTS_PASSED"

proc/runClassicHudSmokeTests()
	var/mob/NexusSmokeTest/legacy_layout_owner = new
	legacy_layout_owner.nexus_classic_layout = list("chat" = list("x" = 123, "y" = 45, "w" = 540, "h" = 480, "open" = TRUE))
	var/layout_before_migration = json_encode(legacy_layout_owner.nexus_classic_layout)
	var/savefile/legacy_layout_save = new
	legacy_layout_save["nexus_interface_layout"] << "side_tabs"
	legacy_layout_save["nexus_interface_layout"] >> legacy_layout_owner.nexus_interface_layout
	legacy_layout_owner.hideNexusNativeTabs()
	nexusSmokeAssert(legacy_layout_owner.nexus_interface_layout == "overlay" && legacy_layout_owner.tabs_hidden && json_encode(legacy_layout_owner.nexus_classic_layout) == layout_before_migration, "legacy tab preference migration lost the saved Classic layout or kept tabs enabled")
	legacy_layout_owner.Toggle_tabs()
	legacy_layout_owner.Update_tab_button_text(TRUE)
	legacy_layout_owner.closeClassicLegacy()
	nexusSmokeAssert(legacy_layout_owner.tabs_hidden && legacy_layout_owner.nexus_interface_layout == "overlay" && !legacy_layout_owner.classicStatPanel("Other"), "legacy entry points re-enabled native tab output")
	del(legacy_layout_owner)
	runStarterHotkeySmokeTests()
	runIndependentHotkeySmokeTests()
	runNexusMenuActionsSmokeTests()
	runClassicResponsiveLayoutSmokeTests()
	runSkillArtworkSmokeTests()
	runNexusVitalsLayoutSmokeTests()
	var/list/geometry = normalizeClassicGeometry(list("x" = 9000, "y" = -200, "w" = 9999, "h" = -20), "chat", 800, 600)
	nexusSmokeAssert(geometry["x"] == 0 && geometry["y"] == 0 && geometry["w"] == 800 && geometry["h"] == 120, "Classic geometry escaped the map or accepted invalid dimensions")
	var/list/menu_geometry = normalizeClassicGeometry(list("x" = 100, "y" = 90, "w" = 9999, "h" = 120), "menu", 1920, 1080)
	nexusSmokeAssert(menu_geometry["x"] == 100 && menu_geometry["y"] == 90 && menu_geometry["w"] == 460 && menu_geometry["h"] == 680, "Classic menu did not preserve its fixed reference size")
	var/list/skills_geometry = normalizeClassicGeometry(list("x" = 120, "y" = 80, "w" = 900, "h" = 900), "skills", 1920, 1080)
	nexusSmokeAssert(skills_geometry["w"] == 460 && skills_geometry["h"] == 680, "embedded Skills panel did not preserve the approved fixed size")
	var/list/default_chat_geometry = normalizeClassicGeometry(null, "chat", 1920, 1080)
	var/list/default_bar_geometry = normalizeClassicGeometry(null, "bar", 1920, 1080)
	nexusSmokeAssert(default_chat_geometry["w"] == 540 && default_chat_geometry["h"] == 480, "Classic chat did not receive its approved default size")
	nexusSmokeAssert(default_bar_geometry["x"] == round((1920 - default_bar_geometry["w"]) / 2) && default_bar_geometry["y"] + default_bar_geometry["h"] == 1080, "primary hotbar is not centered flush with the bottom edge")
	var/list/sense_geometry = scaleClassicGeometry(normalizeClassicGeometry(null, "sense", 1920, 1080), 1920, 1080, 1366, 768)
	var/list/target_geometry = scaleClassicGeometry(normalizeClassicGeometry(null, "target", 1920, 1080), 1920, 1080, 1366, 768)
	nexusSmokeAssert(target_geometry["x"] + target_geometry["w"] <= sense_geometry["x"], "Classic target covered Sense after changing resolution")
	var/mob/user = new
	var/mob/refresh_user = new
	var/datum/ClassicHud/refresh_hud = new(refresh_user)
	refresh_hud.payloads["stats"] = "previous"
	refresh_hud.shouldRefreshWidget("stats")
	nexusSmokeAssert(!refresh_hud.shouldRefreshWidget("stats", TRUE), "Classic rebuilt unchanged slow panels within their refresh interval")
	nexusSmokeAssert(refresh_hud.shouldRefreshWidget("stats"), "Classic throttled an explicit user refresh")
	refresh_hud.last_widget_refresh["stats"] = world.time - 10
	nexusSmokeAssert(refresh_hud.shouldRefreshWidget("stats", TRUE), "Classic did not resume periodic data updates")
	refresh_user.nexus_classic_layout["stats"]["collapsed"] = TRUE
	refresh_hud.last_widget_refresh["stats"] = world.time - 10
	nexusSmokeAssert(!refresh_hud.shouldRefreshWidget("stats", TRUE), "Classic rebuilt a collapsed panel")
	refresh_hud.payloads -= "stats"
	nexusSmokeAssert(refresh_hud.shouldRefreshWidget("stats", TRUE), "Classic skipped the initial payload of a reopened panel")
	del(refresh_hud)
	del(refresh_user)
	var/obj/legacy_skill = new(user)
	legacy_skill.Skill = 1
	legacy_skill.hotbar_type = null
	var/datum/ClassicSnapshot/skills_snapshot = user.captureClassicData("skills")
	nexusSmokeAssert(isNexusTechniqueObject(legacy_skill) && skills_snapshot.subjects["\ref[legacy_skill]"] == legacy_skill, "Skills panel omitted a legacy owned skill without hotbar_type")
	del(skills_snapshot)
	del(legacy_skill)
	var/obj/PressurePunch/punch = new(user)
	user.last_pressurePunch = world.time
	var/list/state = punch.getClassicCooldown(user)
	// Float timestamp subtraction can differ by a fraction of a tick.
	nexusSmokeAssert(state["remaining"] > 0 && state["remaining"] <= pressure_punch_cooldown_ticks / 10 + 0.1, "Classic Pressure Punch cooldown [state["remaining"]] does not match [pressure_punch_cooldown_ticks / 10]")
	var/obj/Keep_Body/support = new(user)
	// BYOND real-time timestamps lose sub-minute precision at this date; compare clock domains.
	support.next_use = world.realtime + 600
	state = support.getClassicCooldown(user)
	nexusSmokeAssert(state["remaining"] > 0 && state["remaining"] <= 120, "Classic wall-clock cooldown [state["remaining"]] does not match 60")
	var/obj/Giant_Form/form = new(user)
	state = form.getClassicSkillState(user)
	nexusSmokeAssert(state["state"] == "ready", "Classic could not read a ready skill without optional stance fields")
	user.using_giant_form = TRUE
	state = form.getClassicSkillState(user)
	nexusSmokeAssert(state["state"] == "active", "Classic did not report an active toggle")
	user.using_giant_form = FALSE
	form.next_use = world.time + 30
	state = form.getClassicCooldown(user)
	nexusSmokeAssert(state["remaining"] > 0 && state["remaining"] <= 3.1, "Classic world-time cooldown [state["remaining"]] does not match 3")
	user.nexus_classic_slots = list()
	user.nexus_classic_slots.len = 36
	user.nexus_classic_slots[1] = user.classicBindingForObject(punch)
	user.nexus_classic_slots[2] = user.classicBindingForObject(form)
	user.nexus_hotkey_bindings = list("CTRL+1" = user.classicBindingForObject(punch))
	user.migrateClassicSlotKeys()
	user.nexus_hotkey_bindings["ALT+1"] = list("kind" = "slot", "slot" = 1)
	var/list/slot_key_map = user.buildClassicSlotKeyMap()
	nexusSmokeAssert(slot_key_map["1"] == user.getClassicSlotKeys(1), "Classic key map lost multiple shortcuts or their order")
	user.nexus_hotkey_bindings -= "ALT+1"
	slot_key_map = user.buildClassicSlotKeyMap()
	nexusSmokeAssert(slot_key_map["1"] == "CTRL+1", "Classic retained a removed shortcut")
	nexusSmokeAssert(user.nexus_hotkey_bindings["CTRL+1"]["kind"] == "slot" && user.resolveNexusHotkeyBinding("CTRL+1") == punch, "Classic migration lost an existing hotkey")
	user.swapClassicSlots(1, 2)
	nexusSmokeAssert(user.resolveNexusHotkeyBinding("CTRL+1") == form, "Classic key followed the object instead of its slot")
	user.clearClassicSlot(1)
	nexusSmokeAssert(!user.resolveNexusHotkeyBinding("CTRL+1") && user.getClassicSlotKeys(1) == "CTRL+1", "Clearing an action lost its slot key")
	user.nexus_classic_slots[1] = user.classicBindingForObject(form)
	user.nexus_classic_slots[36] = user.classicBindingForObject(form)
	user.nexus_hotkey_bindings["SHIFT+3"] = list("kind" = "slot", "slot" = 36)
	nexusSmokeAssert(user.resolveNexusHotkeyBinding("SHIFT+3") == form, "The third hotbar cannot activate its last slot")
	nexusSmokeAssert(findtext(user.getNexusBindingDisplayName(user.nexus_hotkey_bindings["SHIFT+3"]), "Bar 3 / slot 12:"), "Slot binding names do not identify their action")
	nexusSmokeAssert(user.resolveClassicSlot(2) == punch && user.resolveClassicSlot(1) == form, "Classic reorder lost skill identity")
	var/mob/default_bar_user = new
	var/obj/Manual_Attack/default_attack = new(default_bar_user)
	var/obj/Meditate/default_meditate = new(default_bar_user)
	default_bar_user.nexus_classic_slots = list()
	default_bar_user.nexus_classic_slots.len = 12
	default_bar_user.nexus_hotkey_bindings = list(
		"Space" = default_bar_user.classicBindingForObject(default_attack),
		"J" = default_bar_user.classicBindingForObject(default_meditate))
	default_bar_user.populateClassicDefaultSlots()
	nexusSmokeAssert(default_bar_user.resolveClassicSlot(1) == default_attack && !default_bar_user.resolveClassicSlot(2) && default_bar_user.resolveNexusHotkeyBinding("J") == default_meditate, "Classic default bar omitted Space Attack or forced Meditate onto a slot")
	var/list/preserved_default_binding = default_bar_user.nexus_classic_slots[1]
	default_bar_user.nexus_hotkey_bindings["B"] = default_bar_user.classicBindingForObject(default_meditate)
	default_bar_user.populateClassicDefaultSlots()
	nexusSmokeAssert(default_bar_user.nexus_classic_slots[1] == preserved_default_binding && !default_bar_user.nexus_classic_slots[3], "Classic default population overwrote a customized bar")
	del(default_bar_user)
	user.swapClassicSlots(0, 2)
	nexusSmokeAssert(user.resolveClassicSlot(2) == punch, "Classic accepted an invalid slot index")
	user.clearClassicSlot(2)
	nexusSmokeAssert(!user.resolveClassicSlot(2), "Classic clearing a slot retained its action")
	user.nexus_classic_slots[2] = user.classicBindingForObject(punch)
	punch.loc = null
	nexusSmokeAssert(!user.resolveClassicSlot(2), "Classic kept using a skill removed from the character")
	del(punch)
	var/mob/target = new
	user.Target = target
	var/datum/ClassicSnapshot/snapshot = user.captureClassicData("target")
	nexusSmokeAssert(!snapshot.rows.len && !user.nexus_classic_capture, "Classic exposed a missing target or leaked capture state")
	del(snapshot)
	var/list/catalog = getClassicSections()
	nexusSmokeAssert(("actions" in catalog) && ("playtest" in catalog) && ("sagas" in catalog) && ("factions" in catalog), "Classic omitted a required function category")
	var/previous_classic_ui = classic_ui
	classic_ui = FALSE
	user.max_ki = max(1, user.max_ki)
	snapshot = user.captureClassicData("stats")
	classic_ui = previous_classic_ui
	var/list/stat_labels = list()
	for(var/list/row in snapshot.rows) stat_labels += row["label"]
	nexusSmokeAssert(("Strength" in stat_labels) && ("Recovery" in stat_labels) && ("Critical Chance:" in stat_labels), "Classic Stats omitted attributes when native classic_ui was disabled")
	del(snapshot)
	user.setNexusMainVitalsScale(300)
	nexusSmokeAssert(user.nexus_main_vitals_scale == 150, "Vitals scale accepted an excessive size")
	user.setNexusMainVitalsScale(-1)
	nexusSmokeAssert(user.nexus_main_vitals_scale == 50, "Vitals scale accepted an unreadable size")
	user.verbs += /mob/verb/Settings
	var/verb_token = "classic-command:[md5("\ref[user]|/mob/verb/Settings")]"
	var/list/verb_binding = user.classicBindingFromToken(verb_token)
	nexusSmokeAssert(islist(verb_binding) && user.resolveClassicVerbSource(verb_binding) == user, "Classic rejected an owned visible verb")
	user.verbs -= /mob/verb/Settings
	nexusSmokeAssert(!user.resolveClassicBinding(verb_binding), "Classic kept a removed verb executable")
	var/obj/items/item = new(user)
	item.can_hotbar = 0
	user.item_list += item
	snapshot = user.captureClassicData("inventory")
	var/found_inventory_count = FALSE
	for(var/list/inventory_row in snapshot.rows)
		if(inventory_row["label"] == "ITEMS CARRIED" && text2num("[inventory_row["value"]]") == user.item_list.len) found_inventory_count = TRUE
	nexusSmokeAssert(found_inventory_count && snapshot.subjects["\ref[item]"] == item, "Inventory panel omitted its item count or an owned item action token")
	del(snapshot)
	user.assignClassicSlot(3, "classic-skill:\ref[item]")
	nexusSmokeAssert(user.isNexusHotkeyObjectAvailable(item) && user.resolveClassicSlot(3) == item, "Classic could not assign a non-legacy-hotbar inventory item")
	item.loc = null
	nexusSmokeAssert(!user.resolveClassicSlot(3), "Classic executed an item no longer owned")
	del(item)
	user.initializeClassicBars()
	var/original_bar_count = user.nexus_classic_bars.len
	var/dynamic_bar
	for(var/n in 1 to 8) dynamic_bar = user.createClassicBar()
	nexusSmokeAssert(user.nexus_classic_bars.len == original_bar_count + 8, "Classic bars still have a fixed count limit")
	for(var/n in 1 to 5) user.addClassicBarSlots(dynamic_bar, 12)
	var/list/dynamic_settings = user.nexus_classic_bars[dynamic_bar]
	var/list/dynamic_slots = dynamic_settings["slots"]
	nexusSmokeAssert(dynamic_slots.len == 61, "Classic bars still cap their slots at 12 or 36")
	var/last_slot = dynamic_slots[dynamic_slots.len]
	user.nexus_classic_slots[last_slot] = user.classicBindingForObject(form)
	user.nexus_hotkey_bindings["ALT+R"] = list("kind" = "slot", "slot" = last_slot)
	nexusSmokeAssert(user.resolveNexusHotkeyBinding("ALT+R") == form, "Dynamic slot hotkey cannot resolve its action")
	var/list/page_three = user.buildClassicActionBar(FALSE, dynamic_bar, 6)
	nexusSmokeAssert(page_three.len == 1 && page_three[1]["slot"] == last_slot, "Editor pagination discarded slots beyond the old cap")
	user.removeClassicBarSlot(dynamic_bar, dynamic_slots[1])
	nexusSmokeAssert(user.resolveNexusHotkeyBinding("ALT+R") == form, "Removing a slot renumbered another slot's hotkey")
	var/savefile/bar_backup = new
	bar_backup["bars"] << user.nexus_classic_bars
	var/list/restored_bars
	bar_backup["bars"] >> restored_bars
	var/list/restored_settings = restored_bars[dynamic_bar]
	var/list/restored_slots = restored_settings["slots"]
	nexusSmokeAssert(restored_slots.len == 60 && restored_slots[60] == last_slot, "Saved dynamic bars lost their slot IDs")
	user.removeClassicBar(dynamic_bar)
	nexusSmokeAssert(!(dynamic_bar in user.nexus_classic_bars) && !("ALT+R" in user.nexus_hotkey_bindings) && user.resolveNexusHotkeyBinding("SHIFT+3") == form, "Deleting a bar damaged another bar or kept deleted shortcuts")
	del(target)
	del(user)

proc/runNexusVitalsLayoutSmokeTests()
	runNexusHudBitmapTextSmokeTests()
	var/mob/owner = new
	owner.icon = 'src/Icons/PlayerIcons/BaseIcons/NewHumanIconsFromGuppinas/BaseHumanPale.dmi'
	owner.Ki = 8000
	owner.max_ki = 8000
	var/obj/NexusHud/VitalsPanel/panel = new
	panel.initialize(owner)
	panel.setScreenPosition(92, 62)
	var/obj/Buff/Focus/focus = new(owner)
	focus.suffix = "Active"
	owner.current_buff = focus
	owner.bp_mult += focus.buff_bp - 1
	for(var/scale_percent in list(50, 75, 100, 125, 150, 75))
		owner.nexus_main_vitals_scale = scale_percent
		panel.update(owner)
		var/scale = scale_percent / 100
		var/icon/backdrop = icon(panel.icon)
		var/icon/bar = icon(panel.health_row.icon)
		var/obj/NexusHud/ActiveModifiersReadout/buffs = panel.active_modifiers_readout
		var/icon/buff_backdrop = icon(buffs.icon)
		var/matrix/panel_transform = panel.transform
		nexusSmokeAssert(!(panel.appearance_flags & KEEP_TOGETHER) && panel_transform.a == 1 && panel_transform.e == 1 && !panel_transform.b && !panel_transform.c && !panel_transform.d && !panel_transform.f && !panel.pixel_x && !panel.pixel_y, "Vitals [scale_percent]% rescaled the entire composed panel")
		nexusSmokeAssert(backdrop.Width() == round(296 * scale) && backdrop.Height() == round(136 * scale) && panel.screen_loc == "LEFT:92,BOTTOM:62", "Vitals [scale_percent]% lost its native pixel size or drag anchor")
		nexusSmokeAssert(bar.Width() == round(168 * scale) && panel.health_row.pixel_x + bar.Width() <= backdrop.Width(), "Vitals [scale_percent]% bar escaped its panel")
		for(var/obj/NexusHud/VitalRow/row in list(panel.willpower_row, panel.health_row, panel.energy_row, panel.stamina_row))
			assertNexusHudBitmapText(row.primary_text)
			assertNexusHudBitmapText(row.detail_text)
			nexusSmokeAssert(row.detail_text.pixel_x >= row.maptext_x + row.maptext_width && row.detail_text.maptext_width > 0 && row.detail_text.pixel_x + row.detail_text.maptext_width <= bar.Width(), "Vitals [scale_percent]% labels overlap their values")
			var/list/expected_labels = scale < 1 ? list("WP","HP","KI","STA") : list("WILLPOWER","HEALTH","ENERGY","STAMINA")
			nexusSmokeAssert(row.primary_text.rendered_text in expected_labels, "Vitals [scale_percent]% truncated a status label")
		nexusSmokeAssert(panel.energy_row.detail_text.rendered_text == "(8000) 100%", "Vitals [scale_percent]% clipped or wrapped the current energy amount")
		nexusSmokeAssert(buffs.alpha == 255 && findtext(buffs.header_text.text_value, "Focus") && findtext(buffs.first_row_text.rendered_text, "BP 1.18x"), "Buffs [scale_percent]% lost the active Focus summary")
		nexusSmokeAssert(buff_backdrop.Width() == backdrop.Width() && buffs.pixel_y >= backdrop.Height() + 4, "Buffs [scale_percent]% overlaps the vitals frame")
		nexusSmokeAssert(buffs.header_text.pixel_y + buffs.header_text.maptext_height <= buff_backdrop.Height() && buffs.first_row_text.pixel_y + buffs.first_row_text.maptext_height <= buffs.header_text.pixel_y && buffs.second_row_text.pixel_y + buffs.second_row_text.maptext_height <= buffs.first_row_text.pixel_y, "Buffs [scale_percent]% clips or overlaps its text rows")
		for(var/obj/NexusHud/ActiveModifierText/text_row in buffs.vis_contents)
			if(text_row.text_value) assertNexusHudBitmapText(text_row)
		var/icon/row_preview = icon('src/Icons/UI/NexusHudGlyphs.dmi',"8-32")
		row_preview.Crop(1,1,bar.Width(),4*(bar.Height()+4))
		var/preview_y = 1
		for(var/obj/NexusHud/VitalRow/row in list(panel.stamina_row,panel.energy_row,panel.health_row,panel.willpower_row))
			row_preview.Blend(row.icon,ICON_OVERLAY,1,preview_y)
			for(var/obj/NexusHudBitmapText/label in row.vis_contents)
				row_preview.Blend(label.icon,ICON_OVERLAY,label.pixel_x+1,preview_y+label.pixel_y)
			preview_y += bar.Height()+4
		fcopy(row_preview,"VitalsTextSmoke[scale_percent].png")
		for(var/list/energy_case in list(list(222,99.9),list(0,0),list(987654,100),list(1.0e9,99.9)))
			panel.energy_row.update("ENERGY",energy_case[2],"", "#37cfff",scale,energy_case[1])
			assertNexusHudBitmapText(panel.energy_row.detail_text)
			nexusSmokeAssert(panel.energy_row.detail_text.rendered_text == panel.energy_row.detail_text.text_value && findtext(panel.energy_row.detail_text.rendered_text,"[energy_case[2]]%"),"Vitals [scale_percent]% truncated energy [energy_case[1]] / [energy_case[2]]%: [panel.energy_row.detail_text.rendered_text]")
	// Live value/name changes, narrow layouts, overflow, and clearing an active buff.
	focus.name = "<Focus> & a very long custom combat buff name"
	focus.buff_spd = 1.35
	focus.buff_reg = 1.2
	focus.buff_ki = 1.1
	focus.buff_str = 1.2
	focus.buff_dur = 1.3
	focus.buff_for = 1.4
	focus.buff_res = 1.5
	panel.update(owner)
	nexusSmokeAssert(findtext(panel.active_modifiers_readout.header_text.text_value, "<Focus> &") && findtext(panel.active_modifiers_readout.first_row_text.text_value, "SPD 1.35x"), "Buff text is stale or does not preserve literal names")
	for(var/columns in list(20, 35, 46, 60))
		var/list/summary = owner.getNexusActiveHudModifierSummary(8, columns)
		nexusSmokeAssert(length(summary["title"]) + 8 <= columns && length(summary["first_row"]) <= columns && length(summary["second_row"]) <= columns && findtext(summary["second_row"], "MORE"), "Buff summary overflows [columns] columns or silently loses extra stats")
	owner.current_buff = null
	focus.suffix = null
	owner.bp_mult -= focus.buff_bp - 1
	panel.update(owner)
	var/obj/NexusHud/ActiveModifiersReadout/cleared_buffs = panel.active_modifiers_readout
	nexusSmokeAssert(!cleared_buffs.alpha && !cleared_buffs.header_text.alpha && !cleared_buffs.first_row_text.alpha && !cleared_buffs.second_row_text.alpha && !cleared_buffs.header_text.icon && !cleared_buffs.first_row_text.icon && !cleared_buffs.second_row_text.icon, "Deactivated buff left a blank panel or stale text")
	del(focus)
	del(panel)
	del(owner)

proc/assertNexusHudBitmapText(obj/NexusHudBitmapText/label)
	nexusSmokeAssert(label && label.icon && !label.maptext && label.rendered_text,"HUD text has no rendered glyphs or still depends on maptext")
	nexusSmokeAssert(label.text_width <= label.maptext_width && label.text_height <= label.maptext_height,"HUD glyphs exceed their measured text box")
	var/icon/raster = icon(label.icon)
	nexusSmokeAssert(raster.Width() == label.maptext_width && raster.Height() == label.maptext_height,"HUD text raster does not match its layout box")
	var/visible_pixel = FALSE
	for(var/py = 1, py <= raster.Height() && !visible_pixel, py++)
		for(var/px = 1, px <= raster.Width(), px++)
			var/pixel = raster.GetPixel(px,py)
			if(pixel && pixel != "#00000000")
				visible_pixel = TRUE
				break
	nexusSmokeAssert(visible_pixel,"HUD text is entirely transparent despite a nonempty label")

proc/runNexusHudBitmapTextSmokeTests()
	var/obj/NexusHudBitmapText/label = new
	for(var/list/fixture in list(list("BUILD CATALOG",16,176,20),list("Science",12,60,14),list("(8000) 100%",12,96,14),list("(8000) 100%",8,63,11),list("<A> & B",12,100,16),list("Ação / É água",12,150,20)))
		label.maptext_width = fixture[3]
		label.maptext_height = fixture[4]
		label.setBitmapText(fixture[1],fixture[2],"#eee3cf","left",TRUE)
		assertNexusHudBitmapText(label)
		nexusSmokeAssert(label.rendered_text == fixture[1],"A standard HUD label was truncated")
	label.maptext_width = 100
	label.maptext_height = 20
	label.setBitmapText("Long custom blueprint names must end with visible dots",12)
	nexusSmokeAssert(findtext(label.rendered_text,"...") && label.text_width <= 100,"Long HUD labels are clipped instead of deliberately shortened")
	label.setBitmapText("Line one\nLine two",8)
	nexusSmokeAssert(!findtext(label.text_value,"\n"),"HUD labels can wrap through input line breaks")
	var/icon/unchanged_icon = label.icon
	label.setBitmapText("Line one\nLine two",8)
	nexusSmokeAssert(label.icon == unchanged_icon,"An unchanged HUD label was rebuilt")
	for(var/index = 1, index <= 520, index++) label.setBitmapText("[index]%",12)
	nexusSmokeAssert(nexus_hud_text_icon_cache.len <= 512,"Changing numeric readouts grows the text cache without limit")
	label.setBitmapText("")
	nexusSmokeAssert(!label.icon && !label.rendered_text,"Clearing a HUD label left stale glyphs")
	del(label)
	world.log << "HUD_BITMAP_TEXT_SMOKE_PASSED: actual glyph pixels, metrics, literal text, energy, truncation, bounded cache"
