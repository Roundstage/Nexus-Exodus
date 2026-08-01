var/list/nexus_action_button_icon_cache = list()

proc/getNexusActionButtonIcon(active, accent_color)
	var/cache_key = "[active]-[accent_color]"
	if(nexus_action_button_icon_cache[cache_key]) return nexus_action_button_icon_cache[cache_key]
	var/icon/button_icon = icon('UserNamesBarsUi.png')
	button_icon.Scale(128, 28)
	button_icon.DrawBox(active ? "#202c3b" : "#111821", 1, 1, 128, 28)
	button_icon.DrawBox(active ? accent_color : "#455164", 1, 1, 4, 28)
	button_icon.DrawBox(active ? accent_color : "#2c3747", 1, 1, 128, 2)
	button_icon.DrawBox(active ? accent_color : "#2c3747", 1, 27, 128, 28)
	button_icon.DrawBox(active ? "#35475b" : "#1a2430", 5, 3, 126, 26)
	nexus_action_button_icon_cache[cache_key] = button_icon
	return button_icon

client/var/tmp/list/nexus_action_buttons

mob/proc/hasCompleteActionHud()
	if(!client || !islist(client.nexus_action_buttons) || client.nexus_action_buttons.len != 3) return FALSE
	var/list/found_actions = list()
	for(var/obj/NexusHud/ActionButton/button in client.nexus_action_buttons)
		if(button && button.action_id) found_actions[button.action_id] = TRUE
	return found_actions["lethal"] && found_actions["rp_mode"] && found_actions["character"]

mob/proc/rebuildActionHud()
	if(!client) return
	if(islist(client.nexus_action_buttons))
		for(var/obj/NexusHud/ActionButton/old_button in client.nexus_action_buttons)
			client.screen -= old_button
			del(old_button)
	client.nexus_action_buttons = list(
		new /obj/NexusHud/ActionButton/Lethal(src),
		new /obj/NexusHud/ActionButton/RPMode(src),
		new /obj/NexusHud/ActionButton/Character(src))

mob/proc/initializeActionHud()
	if(!client || !playerCharacter) return
	winset(src, "button24", "is-visible=false")
	winset(src, "button26", "is-visible=false")
	winset(src, "button62", "is-visible=false")
	winset(src, "LETHAL", "is-visible=false")
	winset(src, "lethalcombat", "is-visible=false")
	if(!hasCompleteActionHud()) rebuildActionHud()
	for(var/obj/NexusHud/ActionButton/button in client.nexus_action_buttons)
		if(!(button in client.screen)) client.screen += button
	refreshActionHud()

mob/proc/refreshActionHud()
	if(!client || !playerCharacter) return
	if(!hasCompleteActionHud())
		initializeActionHud()
		return
	for(var/obj/NexusHud/ActionButton/button in client.nexus_action_buttons)
		if(!(button in client.screen)) client.screen += button
		button.update(src)

mob/proc/removeActionHud()
	if(!client || !islist(client.nexus_action_buttons)) return
	for(var/obj/NexusHud/ActionButton/button in client.nexus_action_buttons)
		client.screen -= button
		del(button)
	client.nexus_action_buttons = null

obj/NexusHud/ActionButton
	mouse_opacity = 2
	layer = 110
	maptext_x = 10
	maptext_y = 7
	maptext_width = 108
	maptext_height = 16
	var/tmp/mob/owner
	var/action_id
	var/accent_color = "#8fa5bd"

	New(mob/new_owner)
		. = ..()
		owner = new_owner
		update(owner)

	proc/isActive(mob/character)
		return FALSE

	proc/getLabel(mob/character)
		return uppertext(action_id)

	proc/update(mob/character)
		if(!character) return
		owner = character
		var/active = isActive(character)
		icon = getNexusActionButtonIcon(active, accent_color)
		var/text_color = active ? "#ffffff" : "#aeb9c8"
		maptext = "<div style='font-family:Arial;font-size:10px;font-weight:bold;letter-spacing:1px;color:[text_color];text-align:center;text-shadow:1px 1px #000'>[getLabel(character)]</div>"

	Click(location, control, params)
		if(!owner || usr != owner || !owner.client) return
		switch(action_id)
			if("lethal") owner.toggleLethalIntent()
			if("rp_mode") owner.toggleRPMode()
			if("character") owner.showCharacterSheet()
		owner.refreshActionHud()

	Lethal
		action_id = "lethal"
		accent_color = "#ff4d5f"
		screen_loc = "EAST-3:-8,NORTH:-4"
		desc = "Toggle lethal intent."

		isActive(mob/character)
			return character.sparring_mode == LETHAL_COMBAT

		getLabel(mob/character)
			return character.sparring_mode == LETHAL_COMBAT ? "LETHAL  ON" : "LETHAL  OFF"

	RPMode
		action_id = "rp_mode"
		accent_color = "#ff9b54"
		screen_loc = "EAST-3:-8,NORTH-1:-4"
		desc = "Toggle RP Mode. While active, combat interaction is blocked."

		isActive(mob/character)
			return character.rp_mode

		getLabel(mob/character)
			return character.rp_mode ? "RP MODE  ON" : "RP MODE  OFF"

	Character
		action_id = "character"
		accent_color = "#62c8ff"
		screen_loc = "EAST-3:-8,NORTH-2:-4"
		desc = "Open the detailed character sheet."

		getLabel(mob/character)
			return "CHARACTER"
