mob/var/tmp
	last_allow_move_result = 0
	last_allow_move_result_time = 0
	last_bank_bump = 0
	last_directional_key_pressed
	last_cardinal_change = 0

mob/proc/Can_Move()
	if(KB || !move || Disabled()) return
	else return 1

mob/proc/Allow_Move(D)
	// Delegate to application-level movement service for centralized logic
	if(movement_service) return movement_service.AllowMove(src, D)
	// fallback to existing behavior if service missing
	Debug("Moving: Step 1.")
	if(_allow_move_prechecks(D)) return
	if(!Can_Move()) return
	if(icon_state=="KB"||KB||!move) return
	if(_allow_move_handle_kiting_and_finalize(D)) return

	return 1

// helper: handle kiting checks and finalize directional state updates
mob/proc/_allow_move_handle_kiting_and_finalize(D)
	if(is_kiting && Opponent(150))
		Check_if_kiting()
		if(is_kiting)
			if(D in list(get_dir(src,Opponent),turn(get_dir(src,Opponent),45),turn(get_dir(src,Opponent),-45)))
				Reset_kiting()

	last_allow_move_result=1

	if(D in list(NORTH,SOUTH))
		if(last_directional_key_pressed in list(EAST,WEST)) last_cardinal_change = world.time
	else if(D in list(EAST,WEST))
		if(last_directional_key_pressed in list(NORTH,SOUTH)) last_cardinal_change = world.time
	last_directional_key_pressed = D

	return 0

// Helper to encapsulate early-return checks for Allow_Move.
mob/proc/_allow_move_prechecks(D)
	if(UsingVectorMovement())
		if(!CanInputMove()) return 1
		return 0
	if(using_scattershot)
		dir = D
		return 1
	if(!CanInputMove()) return 1
	if(strangling) return 1
	if(cant_move_due_to_hakai) return 1

	if(world.time - last_bank_bump < 10) return 1

	if(world.time <= last_tap_warp + TapWarpCantMoveTime()) return 1

	if(!Ship && !UsingVectorMovement())
		if(world.time - last_allow_move_result_time < 3)
			return last_allow_move_result

	last_allow_move_result_time=world.time
	last_allow_move_result=0

	if(Race=="Majin"&&majin_stat_version <= cur_majin_stat_version) return 1
	if(stat_version<cur_stat_ver) return 1

	stand_still_time=world.time

	if(world.time-last_combo_teleport<=6)
		dir=D
		return 1

	if(lunge_attacking || evading) return 1

	if(IsGreatApe()&&!Great_Ape_control) return 1
	if(BeamStruggling() || shockwaving||Giving_Power) return 1
	if(!Shadow_Sparring&&!Ship) Cease_training()

	if(dash_attacking)
		if(D==turn(dir,90)) desired_dash_dir=turn(dir,45)
		if(D==turn(dir,-90)) desired_dash_dir=turn(dir,-45)
		return 1

	if(!allow_diagonal_movement)
		if(D in list(NORTHEAST,NORTHWEST,SOUTHWEST,SOUTHEAST)) return 1

	if(Beam_stunned())
		StruggleAgainstBeamStun()
		return 1

	if(!struggle_timer&&grabber&&!KO)
		spawn Grab_Struggle()
		return 1

	if(moving_charge==1)
		if(dir!=D)
			dir=D
			return 1
		else moving_charge=2

	if(attack_barrier_obj && attack_barrier_obj.Firing_Attack_Barrier)
		dir=D
		return 1

	for(var/obj/Attacks/A in ki_attacks) if(A.charging||A.streaming||A.Using)
		if(A.streaming) //if its a beam
			if(world.time - last_beam_turn > 12)
				last_beam_turn = world.time
				dir = D
				return 1
		else dir = D
		return 1

	for(var/obj/Blast/B in Get_step(src,D))
		if(B.dir!=turn(D,180)) step(B,B.dir)
		else if(B.density) return 1

	if(blocking || power_attacking || Regeneration_Skill)
		dir=D
		return 1

	if(Shadow_Sparring)
		dir=D
		return 1

	if(Ship)
		if(Ship.type==/obj/Ships/Spacepod && loc != Ship) SafeTeleport(Ship)
		if(!Ship.Moving&&Ship.Ki>0&&!KO)
			Ship.Move_Randomly=0
			Ship.Moving=1
			Ship.MoveReset()
			step(Ship,D)
			if(Ship) Ship.Fuel()
		return 1
	if(car) car.dir=D

	return 0

mob/proc/Edge_Check(turf/old_loc)
	set waitfor=0

	return //disabled til fixed

	if(!Flying)
		var/turf/T=Get_step(old_loc,dir)
		if(T)
			if(!T.Enter(src)) return
			for(var/obj/Edges/A in loc)
				Bump(A)
				if(A) if(!(A.dir in list(dir,turn(dir,90),turn(dir,-90),turn(dir,45),turn(dir,-45))))
					SafeTeleport(old_loc)
					break
			for(var/obj/Edges/A in old_loc)
				Bump(A)
				if(A) if(A.dir in list(dir,turn(dir,45),turn(dir,-45)))
					SafeTeleport(old_loc)
					break

mob/proc/Save_Location() if(z&&!Regenerating)
	saved_x=x
	saved_y=y
	saved_z=z

mob/proc/Cease_training()
	set waitfor=0
	if(Action=="Training") Train()
	if(Action=="Meditating") Meditate()
	//if(auto_train) AI_Train()
	if(Shadow_Sparring) Shadow_Spar()
