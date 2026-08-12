//input state for movement and hotbar macros
#define NEXUS_MACRO_INPUT_MAX_LENGTH 16
#define NEXUS_MACRO_HELD_KEY_CAP 16
#define NEXUS_MACRO_EVENT_WINDOW 10
#define NEXUS_MACRO_EVENT_LIMIT 64

proc/normalizeNexusMacroInputKey(key_value)
	if(!istext(key_value) || !length(key_value) || length(key_value) > NEXUS_MACRO_INPUT_MAX_LENGTH) return
	if(key_value in list("north", "south", "east", "west")) return key_value
	if(islist(nexus_hotkey_base_keys) && key_value in nexus_hotkey_base_keys) return key_value

mob/var/tmp
	north=0
	south=0
	east=0
	west=0
	move_looping
	movement_loop_generation = 0
	list/keys_down=new
	last_direction_pressed = NORTH
	nexus_macro_input_window_started = 0
	nexus_macro_input_events = 0
	nexus_macro_input_blocked_until = 0

mob/var/tmp
	last_keydown_time=0
	last_spacebar_down = 0

	last_directional_keydown_time=0
	last_directional_key_down

	last_north_down = 0
	last_south_down = 0
	last_east_down = 0
	last_west_down = 0

	last_north_up = 0
	last_south_up = 0
	last_east_up = 0
	last_west_up = 0

obj/var/repeat_macro

mob/proc/acceptNexusMacroInput(key_value, event_time = world.time)
	if(!normalizeNexusMacroInputKey(key_value) || !isnum(event_time)) return FALSE
	if(nexus_macro_input_blocked_until && event_time < nexus_macro_input_blocked_until) return FALSE
	if(event_time < nexus_macro_input_window_started || event_time - nexus_macro_input_window_started >= NEXUS_MACRO_EVENT_WINDOW)
		nexus_macro_input_window_started = event_time
		nexus_macro_input_events = 0
		nexus_macro_input_blocked_until = 0
	if(nexus_macro_input_events >= NEXUS_MACRO_EVENT_LIMIT)
		nexus_macro_input_blocked_until = event_time + NEXUS_MACRO_EVENT_WINDOW
		StopMovement()
		return FALSE
	nexus_macro_input_events++
	return TRUE

mob/proc/sanitizeNexusHeldMacroKeys()
	var/list/safe_keys = list()
	if(islist(keys_down))
		for(var/key_value in keys_down)
			var/normalized_key = normalizeNexusMacroInputKey(key_value)
			if(!normalized_key || normalized_key in safe_keys) continue
			if(safe_keys.len >= NEXUS_MACRO_HELD_KEY_CAP) break
			safe_keys += normalized_key
	keys_down = safe_keys

mob/proc/Macro_direction()
	if(north>=world.time && east>=world.time) return NORTHEAST
	if(north>=world.time && west>=world.time) return NORTHWEST
	if(south>=world.time && east>=world.time) return SOUTHEAST
	if(south>=world.time && west>=world.time) return SOUTHWEST
	if(north>=world.time) return NORTH
	if(south>=world.time) return SOUTH
	if(west>=world.time) return WEST
	if(east>=world.time) return EAST

mob/proc/HandleKeyDown(d)
	set waitfor=0
	set instant=1
	if(nexus_hotkey_editor_open) return
	d = normalizeNexusMacroInputKey(d)
	if(!d) return
	sanitizeNexusHeldMacroKeys()
	var/was_key_held = (d in keys_down)
	if(!was_key_held && keys_down.len >= NEXUS_MACRO_HELD_KEY_CAP) return

	/*if(!(d in list("north","south","east","west")))
		if(last_keydown_time==world.time) return
		last_keydown_time=world.time*/

	if(d == "Space") last_spacebar_down = world.time

	switch(d)
		if("north")
			north=world.time
			last_north_down = world.time
		if("south")
			south=world.time
			last_south_down = world.time
		if("east")
			east=world.time
			last_east_down = world.time
		if("west")
			west=world.time
			last_west_down = world.time
	//world<<"KeyDown time: [world.time]"

	for(var/v in 1 to 3)
		keys_down-=d

	keys_down+=d
	if(d in list("north","south","east","west"))

		if(Digging)
			Digging = 0
			movement_port.sendMessage(src, "You have stopped digging")

		if(Regeneration_Skill)
			Regeneration_Skill = 0
			movement_port.sendMessage(src, "You stop regenerating")

		last_directional_keydown_time = world.time
		last_directional_key_down = d

		move_loop()
	else
		HotbarUseHandler(d, null, was_key_held)

mob/proc/HotbarUseHandler(d, held_key, was_key_held = FALSE)
	set waitfor=0
	set instant = 1
	if(!held_key) held_key = d
	var/binding_id = getNexusHotkeyBindingIdForPress(d, was_key_held)
	var/hotkey_action = resolveNexusHotkeyBinding(binding_id)
	if(!hotkey_action && binding_id == d) hotkey_action = Get_hotbar_obj_by_key_pressed(d)
	if(!hotkey_action) return
	active_nexus_hotkey_actions[held_key] = hotkey_action
	active_nexus_hotkey_combinations[held_key] = binding_id
	while((held_key in keys_down) && active_nexus_hotkey_combinations[held_key] == binding_id)
		if(!executeNexusHotkeyAction(hotkey_action)) return
		if(!nexusHotkeyActionRepeats(hotkey_action))
			keys_down -= held_key
			return
		sleep(world.tick_lag)

mob/proc/HotbarKeyUpHandler(d)
	set waitfor=0
	set instant = 1
	var/o = active_nexus_hotkey_actions[d]
	active_nexus_hotkey_actions -= d
	active_nexus_hotkey_combinations -= d
	if(!o) o = Get_hotbar_obj_by_key_pressed(d)
	if(isobj(o))
		var/obj/hotkey_object = o
		if(hotkey_object.can_hotbar && hotkey_object.is_for_moving)
			ReleaseKey(hotkey_object.move_macro_dir)

mob/proc/HandleKeyUp(d)
	set waitfor=0
	set instant=1
	d = normalizeNexusMacroInputKey(d)
	if(!d) return
	sanitizeNexusHeldMacroKeys()
	//world<<"KeyUp time: [world.time]"
	var/active_combination = active_nexus_hotkey_combinations[d]

	ReleaseKey(d)

	if(!(d in list("north","south","east","west")))
		HotbarKeyUpHandler(d)

	if(d == "Space" && (!active_combination || active_combination == "Space") && world.time - last_spacebar_down < 3)
		MeleeFollowupAttackCheck()

mob/proc/ReleaseKey(d)
	set waitfor = 0
	set instant = 1
	for(var/v in 1 to 3)
		keys_down -= d
	switch(d)
		if("north")
			last_north_up = world.time
			north = 0
		if("south")
			last_south_up = world.time
			south = 0
		if("west")
			last_west_up = world.time
			west = 0
		if("east")
			last_east_up = world.time
			east = 0
	AlignToTile()

mob/proc/move_dir()
	return XYtoDir(getMovementInputX(), getMovementInputY())


/*mob/var/tmp/pixel_offset_loop

mob/proc
	ClientPixelOffsetLoop()
		set waitfor=0
		if(pixel_offset_loop) return
		pixel_offset_loop=1

		while(client && (client.pixel_x!=0 || client.pixel_y!=0))
			client.pixel_x *= 0.85
			client.pixel_y *= 0.85
			sleep(world.tick_lag)

		pixel_offset_loop=0*/

mob/proc/move_loop()
	set waitfor=0
	if(move_looping) return
	move_looping=1
	movement_loop_generation++
	var/loop_generation = movement_loop_generation
	var/using_vector = UsingVectorMovement()
	var/last_using_inertia = usingMovementInertia()
	var/first_step=1
	if(!Shadow_Sparring && !using_vector) sleep(world.tick_lag)
	while(loop_generation == movement_loop_generation && (hasMovementInput() || (usingMovementInertia() && hasMovementMomentum())))
		var/using_inertia = usingMovementInertia()
		if(using_inertia != last_using_inertia)
			resetMovementPhysics()
			last_using_inertia = using_inertia
		var/d = move_dir()
		var/vector_speed
		var/turf/prev_loc
		var/prevDir

		if(d) last_direction_pressed = d

		if(using_inertia)
			var/can_move
			if(d)
				can_move = Allow_Move(d)
				handleMovementPhysicsLockedInput(d)
				if(movementPhysicsSuspended(validate_standard_movement = FALSE)) can_move = FALSE
			else can_move = !movementPhysicsSuspended()
			if(can_move && z)
				prev_loc = base_loc()
				prevDir = dir
				if(d) dir = d
				processMovementPhysicsFrame(d)
				if(movement_port.clientShiftDown(src)) dir = prevDir //strafing
				if(prev_loc != base_loc()) last_input_move = world.time
				if(d) UpdateNextInputMoveTime(d)
			else
				resetMovementPhysics(clear_glide = FALSE)
		else if(d && Allow_Move(d) && z)
			prev_loc = base_loc()
			prevDir = dir
			if(UsingVectorMovement())
				dir = d
				vector_speed = GetVectorMovePixels(d)
				glide_size = GetVectorGlideSize(vector_speed)
				tryNexusVectorMoveWithGapNudge(d, vector_speed)
			if(movement_port.clientShiftDown(src)) dir = prevDir //strafing
			if(prev_loc != base_loc()) last_input_move = world.time
			UpdateNextInputMoveTime(d)
		if(using_inertia) sleep(world.tick_lag)
		else if(first_step && !Shadow_Sparring) sleep(world.tick_lag * 2)
		else sleep(world.tick_lag)

		first_step=0

		if(north==2) north=0
		if(south==2) south=0
		if(east==2) east=0
		if(west==2) west=0

	if(!usingMovementInertia()) resetMovementPhysics()
	if(loop_generation == movement_loop_generation) move_looping=0

mob/proc/StopMovement()
	cancelNexusSkillMotion("stop")
	north = 0
	south = 0
	east = 0
	west = 0
	keys_down = new
	movement_loop_generation++
	move_looping = 0
	resetMovementPhysics()
