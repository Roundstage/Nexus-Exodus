mob/var/tmp
	mob/flash_step_mob
	flash_stepping
	turf/last_cave_entered
	last_cave_entered_time=0
	last_hit_by_beam = -999999

mob/proc
	Set_flash_step_mob(mob/m)
		flash_step_mob=m

	Can_flash_step()
		if(!CanInputMove()) return
		if(!Can_Move()||grabbedObject||grabber||dash_attacking||beaming||charging_beam||Beam_stunned()||\
		flash_stepping || Frozen) return

		if(dash_attacking || Shadow_Sparring) return
		if(Charging_or_Streaming()) return
		if(!can_zanzoken||stun_level) return
		if(grabbedObject) return
		if(Beam_stunned()) return

		return 1

	Get_flash_step_target(mob/m)
		m = getSelectedTarget(m, max_dist = 50)
		if(Is_valid_flash_step_target(m)) return m

	Is_valid_flash_step_target(mob/m)
		if(!m||m==src) return
		if(m.last_cave_entered&&m.last_cave_entered.z==z&&getdist(src,m.last_cave_entered)<20)
			//if(viewable(src,m.last_cave_entered))
			SafeTeleport(m.last_cave_entered)
			m.last_cave_entered.Enter(src)
			return 1
		if(m==flash_step_mob&&m.z==z&&getdist(src,m)<50) return 1
		if(m!=flash_step_mob&&m.z==z&&getdist(src,m)<22&&(get_dir(src,m) in list(dir,turn(dir,45),turn(dir,-45))))
			return 1

	Manually_find_flash_step_target()
		var/mob/m = getSelectedTarget(max_dist = 22)
		if(Is_valid_flash_step_target(m)) return m

	Get_flash_step_delay()
		var/n=TickMult(Speed_delay_mult(severity=0.5) * 2.5)
		return n

	Flash_Step()
		var/stam_drain = tapwarp_stam_drain
		if(!Can_flash_step() || stamina < stam_drain) return
		if(!getZanzokenSkill())
			src<<"This ability requires zanzoken"
			return

		/*if(!flash_step_mob || !Is_valid_flash_step_target(flash_step_mob))
			flash_step_mob = Get_flash_step_target(Opponent)
		if(!flash_step_mob) return*/

		flash_step_mob=LungeTarget()
		if(!flash_step_mob) return

		var/turf/old_loc = loc
		if(!TapWarpToMob(flash_step_mob)) return
		AddStamina(-stam_drain)
		last_tap_warp = world.time
		AfterImage(50, loc_override = old_loc)
		player_view(15,src)<<sound('Teleport.ogg',volume=15)
		flick('Zanzoken.dmi',src)
		dir=get_dir(src,flash_step_mob)
		var/defend_chance=66 * (flash_step_mob.Def / Def)
		if(prob(defend_chance)) flash_step_mob.dir=get_dir(flash_step_mob,src)
