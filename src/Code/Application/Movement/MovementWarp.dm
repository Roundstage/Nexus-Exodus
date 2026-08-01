//Remember to take some lessons from flash step code for this

var
	tapwarp_stam_drain = 5

mob/var/tmp
	last_tap_warp = 0
	obj/Shunkan_Ido/instant_transmission_obj

mob/proc
	getInstantTransmissionSkill()
		if(instant_transmission_obj && instant_transmission_obj.loc == src) return instant_transmission_obj
		instant_transmission_obj = locate(/obj/Shunkan_Ido) in src
		return instant_transmission_obj

	instantTransmissionWarpCost()
		return max(1, max_ki * 0.0025)

	CanInstantTransmissionWarp()
		if(!CanInputMove() || BeamStruggling() || UsingAttackBarrier()) return FALSE
		if(!getInstantTransmissionSkill()) return FALSE
		if(Ki < instantTransmissionWarpCost()) return FALSE
		return Can_flash_step()

	directionalInstantTransmission(d)
		set waitfor = 0
		if(!(d in list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))) return
		if(!CanInstantTransmissionWarp()) return
		var/turf/old_loc = loc
		var/mob/target = FindWarpTarget(dir_angle = d, angle_limit = 40, max_dist = 8, prefer_auto_target = 0)
		var/warped_to_target = target && TapWarpToMob(target)
		if(!warped_to_target && !TapWarpToDir(d, 8)) return
		Ki = max(0, Ki - instantTransmissionWarpCost())
		last_tap_warp = world.time
		AfterImage(60, loc_override = old_loc)
		flick('Zanzoken.dmi', src)
		player_view(20, src) << sound('Teleport.ogg', volume = 18)
		if(warped_to_target && target) Melee(target, from_auto_attack = 1)

	TapWarpCantMoveTime()
		return world.tick_lag * 2

	CanTapWarp()
		if(!CanInputMove()) return 0
		if(stamina < tapwarp_stam_drain) return 0
		if(BeamStruggling() || UsingAttackBarrier()) return 0
		if(!getZanzokenSkill()) return 0
		return Can_flash_step()

	directionalZanzoken(d)
		set waitfor=0
		if(!(d in list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))) return
		if(!CanTapWarp()) return
		var/turf/old_loc = loc
		var/mob/target = FindWarpTarget(dir_angle = d, angle_limit = 40, max_dist = 5, prefer_auto_target = 0)
		var/warped_to_target = target && TapWarpToMob(target)
		if(!warped_to_target && !TapWarpToDir(d, 5)) return
		last_tap_warp = world.time
		AddStamina(-tapwarp_stam_drain)
		AfterImage(50, loc_override = old_loc)
		flick('Zanzoken.dmi', src)
		player_view(20, src) << sound('Teleport.ogg', volume = 15)
		if(warped_to_target && target) Melee(target, from_auto_attack = 1)

	DoubleTapWarp(d)
		set waitfor=0
		if(!CanTapWarp()) return

		if(d)
			switch(d)
				if("north") dir = NORTH
				if("south") dir = SOUTH
				if("east") dir = EAST
				if("west") dir = WEST

		var/mob/m = FindWarpTarget(dir_angle = dir, angle_limit=40, max_dist=25, prefer_auto_target=0)
		var
			warped_to_mob_success
			warped_to_dir_success
			oloc = loc
		warped_to_mob_success = TapWarpToMob(m)
		if(!warped_to_mob_success) warped_to_dir_success = TapWarpToDir(dir)
		if(warped_to_mob_success || warped_to_dir_success)
			if(warped_to_mob_success && m) m.last_tap_warp = world.time
			last_tap_warp = world.time
			AddStamina(-tapwarp_stam_drain)
			AfterImage(50, loc_override = oloc)
			flick('Zanzoken.dmi',src)
			player_view(20,src) << sound('Teleport.ogg',volume=15)
			if(warped_to_mob_success && m) Melee(m, from_auto_attack=1)
			return 1

	TapWarpToMob(mob/m)
		if(!m) return
		var/list/warp_turfs = list(\
			get_step(m,NORTH),\
			get_step(m,SOUTH),\
			get_step(m,EAST),\
			get_step(m,WEST))

		warp_turfs.Remove(m.dir, turn(m.dir,45), turn(m.dir,-45))

		for(var/turf/t2 in warp_turfs) if(!ValidWarpTurf(t2)) warp_turfs -= t2
		if(!warp_turfs.len) return

		var/turf/t = get_step(m,m.dir)
		if(!ValidWarpTurf(t)) t = pick(warp_turfs)
		//these 2 lines above were simply 1 line: var/turf/t = pick(warp_turfs)

		SafeTeleport(t)
		step_x = m.step_x
		step_y = m.step_y
		dir = get_dir(src, m)
		return 1

	ValidWarpTurf(turf/t)
		if(!t || !isturf(t) || t.opacity || istype(t,/turf/Other/Blank)) return
		if(!t.FlyOverAble && t.density) return
		for(var/obj/o in t)
			if(o.density || istype(o,/obj/Turfs/Door) && o.opacity) return
		return 1

	TapWarpToDir(d, warp_dist = 5)
		var/turf/start_loc = loc
		var/turf/t = start_loc
		if(!t || !isturf(t)) return
		for(var/v in 1 to warp_dist)
			var/turf/new_t = get_step(t,d)
			if(ValidWarpTurf(new_t))
				t = new_t
			else break
		if(t == start_loc) return
		SafeTeleport(t)

		dir = d

		return 1
