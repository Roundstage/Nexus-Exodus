mob/var/tmp/last_kill_from_freeza_for_cowardice = 0

mob/var/tmp
	has_delay=1 //this var/is now pointless i believe. Move() no longer has a delay inside of it. its been replaced in Allow_Move()

	same_loc_after_move
	same_dir_after_move

	last_move=0

mob/proc/Moving_auto_attack()
	set waitfor=0
	if(Auto_Attack) Melee(from_auto_attack=1)

mob/var/tmp/last_sz_move_check = -999

mob/proc/PlayerPreMove()
	set waitfor=0
	if(last_move == world.time) return //because there can be multiple moves in the same tick in certain scenarios and some things dont need to be called repeatedly in the same tick
	//FreezaRunnerCowardKill() //checks if a runner has ran into the gym for safety, freeza then kills them for being a coward
	Gravity_Update()
	Cease_training()

atom/var/tmp
	oldLoc
	newLoc

//this system is to stop Sphax using an actual teleport hack to teleport anywhere he wants even inside people's houses
atom/movable/var/tmp
	canTeleport = 0
	lastCanTeleport = 0

atom/movable/proc
	//only this proc can teleport people because it will set the canTeleport flag first so the game knows its legit
	//the game will not allow position changes more than 1 tile if this proc was not used to do it
	SafeTeleport(turf/t, allowSameTick)
		//JUST DISABLE THE WHOLE SYSTEM IT HAS SOME BUGS I DONT FEEL LIKE FIXING LIKE WHEN PODS BLOW UP WITH YOU IN IT YOU GET SENT TO VOID FOR NO APPARENT REASON
		oldLoc = t
		newLoc = t
		loc = t
		return





		//there are bugs that occur now with beam placement when firing a beam and other things so instead of fixing those im just gonna let them
		//go to the position
		if(!ismob(src))
			loc = t
			return
		//prevent an infinite loop, which does exist somewhere, and crashes the server
		if(lastCanTeleport == world.time && !allowSameTick)
			return
		lastCanTeleport = world.time
		canTeleport = world.time

		/*if(isturf(t))
			Move(t)
		//we do this in case t = null. Move(null) does nothing. but if we are trying to set someone's loc = null, it still needs to respond to that
		//also we now do it in case its anything other than a turf, like we are putting a mob inside a obj or something
		else
			oldLoc = t
			newLoc = t
			loc = t*/
		oldLoc = t
		newLoc = t
		loc = t

		canTeleport = 0

	//checks if the current movement is a valid movement
	LegitMove(turf/prevLoc, turf/newLoc)
		if(canTeleport == world.time || get_dist(newLoc, prevLoc) <= 1)
			return 1

mob/proc/PlayerPostMove(old_loc)
	set waitfor=0
	oldLoc = old_loc
	newLoc = loc
	if(last_move != world.time)
		Moving_auto_attack()
	Update_grab()
	if(last_move != world.time) UpdateStepSpeed()
	FinalExplosionFollowOnMove()
	if(loc != old_loc)
		if(world.time - last_sz_move_check > 6)
			Safezone()
			last_sz_move_check = world.time
		Save_Location()
		Opponent_move_slower_if_you_are_chasing_them()
		Edge_Check(old_loc)
		if(!KB && Target && istype(Target,/obj/Build)) Build_Lay(Target,src)
		if(prob(10) && is_on_destroyed_planet()) SafeTeleport(locate(x, y, 16))
		ExplodeLandMines()
		update_area()

mob/proc/NPCPostMove(old_loc)
	set waitfor=0
	if(last_move == world.time) return //because there can be multiple moves in the same tick in certain scenarios and some things dont need to be called repeatedly in the same tick
	//ResetStepXY()
	if(loc != old_loc)
		if(prob(5)) update_area()

proc/XYtoDir(x, y) //takes an x and y and decides if this movement is NSEW SW NW NE or SE
	if(x > 0)
		if(y > 0) return NORTHEAST
		if(y < 0) return SOUTHEAST
		return EAST
	if(x < 0)
		if(y > 0) return NORTHWEST
		if(y < 0) return SOUTHWEST
		return WEST
	if(y > 0) return NORTH
	if(y < 0) return SOUTH
