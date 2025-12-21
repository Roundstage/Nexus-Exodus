atom/movable/proc/MovementCrossDecision(atom/movable/a)
	//a = object attempting to cross (such as the player)
	//src = the object 'a' is trying to cross
	if(a == src) return 1
	if(!density) return null

	if(ismob(src))
		var/mob/src_m = src
		if(ismob(a))
			var/mob/m = a
			//this is so npcs can never overlap a player because its wonky looking and makes fighting them hard
			//maybe it should only be limited to mob/Enemy but idk right now
			if(!m.client) return 0
			if(m.client && istype(src_m, /mob/Enemy)) return 0 //this is so a flying player can not overlap a nonflying Enemy, because its just annoying for the player to
				//fight npcs when flying if they are flying through them because the npc cant fly
			if(!src_m.KB && m.Flying && !src_m.Flying)
				//src << "1"
				return 1
		if(isobj(a))
			if(istype(a, /obj/Blast))
				var/obj/Blast/b = a
				if(b.blast_go_over_owner && b.Owner == src_m) return 1

	if(istype(src, /obj/Blast))
		var/obj/Blast/src_b = src
		if(istype(a, /obj/Blast))
			var/obj/Blast/b = a
			if(b.pass_over_owners_blasts && b.Owner == src_b.Owner) return 1
		if(ismob(a))
			if(a.dir == src_b.dir) return 1 //you can cross over blasts as long as it is from behind
	else if(isobj(src))
		var/obj/src_o = src
		if(ismob(a))
			var/mob/m = a
			if(!istype(src_o, /obj/Turfs/Door))
				if(m.Flying || m.lunge_attacking || m.evading) return 1

	if(istype(a,/obj/Blast))
		var/obj/Blast/b = a
		if(b.BlastCross(src)) return 1
	if(ismob(a))
		var/mob/m = a
		if(m.MobCross(src)) return 1
	return null

atom/var
	can_side_step = 1
	canSideStep = 1

mob/proc/SideStep(obj/o)
	if(!o) return
	if(!can_side_step || !canSideStep) return
	if(!o.can_side_step || !o.canSideStep) return
	var/turf/old_loc = loc
	var/list/dirs = list(turn(dir,90), turn(dir,-90))
	for(var/d in dirs)
		step(src, d)
		if(loc != old_loc) return

mob/proc/BumpKnockbackDestroyObjectCheck(obj/o)
	if(!o || !KB) return
	if(!isobj(o)) return
	if(!o.density) return
	if(!isnum(o.Health)) return
	if(o.Health == 1.#INF) return
	if(!knockbacker_bp || knockbacker_bp < o.Health) return
	Dust(o, end_size = 1, time = 10)
	del(o)

mob/proc/MovementBump(atom/A)
	if(!A || A == src) return
	if(isobj(A))
		BumpKnockbackDestroyObjectCheck(A)
	if(last_bump != world.time)
		last_bump = world.time
		last_bumped_obj = A

turf/proc/MovementEnterResult(mob/m, return_value)
	return return_value

mob/proc/DoorPasswordAlert(obj/Turfs/Door/d)
	set waitfor=0
	if(!d || !client) return
	if(!(src in range(1,d))) return
	if("door" in active_prompts) return
	active_prompts += "door"
	var/pw = input(src,"Enter the door password","Door") as text
	if(!d)
		active_prompts -= "door"
		return
	if(pw == d.Password)
		d.Open()
	else
		src<<"Access denied"
	active_prompts -= "door"

mob/proc/MobCross(mob/A)
	if(A == src) return 1

	if(istype(A,/obj/items/Simulator))
		SimBump(A)

	// non-solid objects allow crossing
	if(!A.density)
		return 1

	var/return_value = 0

	// door handling extracted
	var/door_result = _mobcross_handle_door(A)
	if(door_result)
		return 1
	else if(door_result == 0)
		return 0

	BumpKnockbackDestroyObjectCheck(A)

	if(A && last_bumped_obj == A && A != src && A.density)
		if(!ismob(A) && !istype(A,/obj/Blast))
			if(!(locate(/mob) in A.loc))
				SideStep(A)

	if(A && A.type == /obj/King_of_Braal_Throne)
		BumpKingBraalThrone()

	// blast-specific checks extracted
	var/blast_result = _mobcross_handle_blast(A)
	if(blast_result) return 1

	A.ExplodeLandMines()

	// other object-specific handlers
	if(istype(A,/obj/Planet_Restore_Crystal))
		var/obj/Planet_Restore_Crystal/prc = A
		if(!destroyed_planets.len)
			src<<"There are no destroyed planets right now to restore"
		else
			var/planet = pick(destroyed_planets)
			player_view(15,src)<<"[planet] has been restored"
			spawn restore_planet(planet)
			prc.DespawnRespawn()

	if(istype(A,/obj/items/Regenerator))
		Regenerator_loop(A)
		if(grabbedObject && ismob(grabbedObject))
			grabbedObject.SafeTeleport(loc)
			grabbedObject.Regenerator_loop(A)
		return_value = 1

	if(istype(A,/obj/Kaioshin_Portal))
		var/obj/Kaioshin_Portal/KP=A
		if(KP.icon)
			if(Teleport_nulled())
				src<<"A teleport nullifier prevents the portal from working"
			else
				SafeTeleport(locate(250,250,13))
				spawn if(KP) KP.Become_inactive()

	if(istype(A,/obj/Bank))
		Bank_Options(A)

	if(istype(A,/obj/Ship_exit))
		var/obj/Ship_exit/Se=A
		for(var/obj/Controls/C in range(6,Se))
			C.Exit_Ship(src,Se)

	if(istype(A,/obj/Final_Realm_Portal))
		SafeTeleport(locate(rand(163,173),rand(183,193),5))

	if(istype(A,/obj/God_Realm_Portal) && A.invisibility == 0 && client)
		SafeTeleport(locate(385,114,11))

	if(istype(A,/obj/Warper))
		var/obj/Warper/B=A
		SafeTeleport(locate(B.gotox,B.gotoy,B.gotoz))

	if(istype(A,/obj/Ships/Ship))
		var/obj/Ships/Ship/B=A
		var/turf/t=Get_step(B,SOUTHEAST)
		if(!t||loc==t||B.bound_width==32)
			for(var/obj/Controls/C in ship_controls) if(C.Ship==B.Ship)
				player_view(15,src)<<"[src] enters the [A]"
				if(!B.Last_Entry) src<<"<font color=yellow>Computer: Welcome. You are the first one to enter this ship."
				else if(Year-B.Last_Entry>=1) src<<"<font color=yellow>Computer: Welcome, you are the first person to enter this \
				ship in the past [round(Year-B.Last_Entry,0.1)] years"
				B.Last_Entry=Year
				for(var/obj/Ship_exit/Se in range(5,C))
					SafeTeleport(locate(Se.x,Se.y,Se.z))
					break

	if(ismob(A))
		if(type == /mob/Splitform && !A.KO) Melee(A)
		if(!client && type != /mob/Troll && !istype(src, /mob/new_troll) && type != /mob/Splitform)
			if(Health < 100 || !Docile)
				if(istype(src,/mob/Enemy) && istype(A,/mob/Enemy)) //mob dont attack mob
				else if(!drone_module)
					Melee(A)

		if(IsGreatApe()) Melee(A)

	if(istype(A,/obj/Planets)) Bump_Planet(A,src)

	if(istype(src,/mob/Enemy) && world.time - src:last_npc_turf_attack > 50)
		if(!client&&isobj(A)&&!istype(A,/obj/Edges)&&istype(src,/mob/Enemy/Zombie))
			src:last_npc_turf_attack=world.time
			Melee(A)
		if(!client&&isturf(A)&&A.density&&istype(src,/mob/Enemy/Zombie))
			src:last_npc_turf_attack=world.time
			Melee(A)

	if(istype(A,/obj/Controls))
		var/obj/Controls/C=A
		C.Ship_Options(src)

	if(!client && !return_value)
		if(last_bump != world.time)
			var/prevDir = dir
			ResetStepXY()
			dir = prevDir

	if(!return_value)
		last_bump = world.time
		if(A) last_bumped_obj = A

	return return_value

// Helper: door handling for MobCross. Returns 1 = allowed, 0 = blocked, null = not a door
mob/proc/_mobcross_handle_door(atom/A)
	if(!istype(A, /obj/Turfs/Door)) return
	var/obj/Turfs/Door/d = A
	if(isturf(d)) d = locate(/obj/Turfs/Door) in d
	if(!d) return
	if(client && InBattleCantEnterCave()) return
	var/needs_password = 1
	if(drone_module && drone_module.Password == d.Password)
		d.Open()
		return 1
	for(var/obj/items/Door_Pass/dp in item_list)
		if(dp.Password == d.Password)
			d.Open()
			return 1
	for(var/obj/items/Door_Hacker/dh in item_list)
		if(dh.BP >= d.Health)
			player_view(15,d)<<"[src] hacks the door and it opens"
			d.Open()
			return 1
	if(d.is_hbtc_door && anyone_can_enter_hbtc) needs_password = 0
	if(needs_password && client && d.Password && !KB)
		DoorPasswordAlert(d)
	if(!d.Password || (d.is_hbtc_door && anyone_can_enter_hbtc))
		d.Open()
		return 1
	return 0

// Helper: blast-specific crossing rules. Returns 1 if allowed, null otherwise
mob/proc/_mobcross_handle_blast(atom/A)
	if(!istype(A,/obj/Blast)) return
	var/obj/Blast/b = A
	if(b.BlastCross(src)) return 1
	if(b.Owner && b.Owner == src && b.blast_go_over_owner)
		var/turf/t = get_step(src,dir)
		if(t && !t.density) return 1
	return
