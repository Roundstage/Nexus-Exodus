mob/Move(turf/NewLoc, Dir = 0, step_x = 0, step_y = 0)
	if(!KB && IsAttackMovementLocked()) return 0 //Robust movement lock
	//return ..()

	/*
	I TURNED THIS OFF BECAUSE IT MAKES IT WHEN A SPACEPOD BLOWS UP WITH YOU IN IT YOU GET SENT TO THE VOID AND I JUST DONT WANNA DEAL WITH FIXING IT
	//trying to prevent Sphax's teleport hack
	if(client) //just trying to save some cpu but may need to run it on all if this doesnt stop Sphax and his teleport hack
		if(!LegitMove(loc, NewLoc))
			loc = newLoc
			return
		if(newLoc && canTeleport != world.time && loc != newLoc)
			loc = newLoc
			return
	*/

	var/turf/old_loc = loc

	//this is a teleport because it is more than a 1 tile step. so skip all the other code and just put them there because the default behavior of
	//Move() really interferes by changing their direction and stuff for no reason
	var/isTeleport
	if(isturf(NewLoc) && (get_dist(loc, NewLoc) > 1 || old_loc.z != NewLoc.z)) isTeleport = 1
	if(!isturf(NewLoc)) isTeleport = 1
	if(!isturf(loc)) isTeleport = 1
	if(isTeleport)
		oldLoc = loc
		newLoc = NewLoc
		loc = NewLoc
		return



	if(client) PlayerPreMove()

	//this is some code im testing as an alternative to AlignToTile(), where whenever you move, any direction you are NOT moving in will try to lerp
	//back to perfect alignment
	/*if(client) //it could be for npcs later but just in case of performance issues lets do players only at first
		var/d = Dir //this should work, if not use XYtoDir(step_x, step_y)
		var/adjustment_speed = 4 //if you up this, the adjustment will have more of a jolt, but if you lower it then it will take longer to reach alignment
		if(d == NORTH || d == SOUTH) //if im moving just north then the east/west has permission to gradually lerp back to tile alignment
			if(src.step_x != 0)
				if(src.step_x < 16) //we are closer to the left tile
					var/amount = adjustment_speed
					if(amount > src.step_x) amount = src.step_x
					step_x -= amount
				else //we are closer to the right tile
					var/amount = adjustment_speed
					if(amount > 32 - src.step_x) amount = 32 - src.step_x
					step_x += amount
		if(d == EAST || d == WEST)
			if(src.step_y != 0)
				if(src.step_y < 16)
					var/amount = adjustment_speed
					if(amount > src.step_y) amount = src.step_y
					step_y -= amount
				else
					var/amount = adjustment_speed
					if(amount > 32 - src.step_y) amount = 32 - src.step_y
					step_y += amount*/

		//ESSENTIALLY THIS ALL WORKS BUT IT HAS SOME JITTERING I WANT TO FIX BEFORE ENABLING IT AGAIN
		/*if(d == NORTHEAST) //the concept here is based on our misalignment, we will trade some velocity from the x and give it to the y if for example the
		//y was more misaligned from the center of the tile than the x was. so we dont increase overall speed just shift some to reach alignment
			if(src.step_x != 0 || src.step_y != 0)
				var
					x_dist = abs(32 - src.step_x)
					y_dist = abs(32 - src.step_y)
				if(x_dist > y_dist)
					var/amount = adjustment_speed
					if(amount > x_dist) amount = x_dist
					step_x += amount
					step_y -= amount
				else
					var/amount = adjustment_speed
					if(amount > y_dist) amount = y_dist
					step_x -= amount
					step_y += amount

		if(d == NORTHWEST)
			if(src.step_x != 0 || src.step_y != 0)
				var
					x_dist = src.step_x //how from from off-center this axis is
					y_dist = abs(32 - src.step_y)
				if(x_dist > y_dist) //x is more misaligned than y
					var/amount = adjustment_speed
					if(amount > x_dist) amount = x_dist
					step_x -= amount
					step_y -= amount
				else
					var/amount = adjustment_speed
					if(amount > y_dist) amount = y_dist
					step_y += amount
					step_x += amount
		if(d == SOUTHWEST)
			if(src.step_x != 0 || src.step_y != 0)
				var
					x_dist = src.step_x //how from from off-center this axis is
					y_dist = src.step_y
				if(x_dist > y_dist) //x is more misaligned than y
					var/amount = adjustment_speed
					if(amount > x_dist) amount = x_dist
					step_x -= amount
					step_y += amount
				else
					var/amount = adjustment_speed
					if(amount > y_dist) amount = y_dist
					step_x += amount
					step_y -= amount
		if(d == SOUTHEAST)
			if(src.step_x != 0 || src.step_y != 0)
				var
					x_dist = abs(32 - src.step_x) //how from from off-center this axis is
					y_dist = src.step_y
				if(x_dist > y_dist) //x is more misaligned than y
					var/amount = adjustment_speed
					if(amount > x_dist) amount = x_dist
					step_x += amount
					step_y += amount
				else
					var/amount = adjustment_speed
					if(amount > y_dist) amount = y_dist
					step_x -= amount
					step_y -= amount*/
		//Dir = XYtoDir(step_x, step_y) //not sure if necessary
	//----------

	if(!client || KB || lunge_attacking || evading) . = ..()
	else if(Can_Move()) . = ..()

	if(client) PlayerPostMove(old_loc)
	else NPCPostMove(old_loc)

	last_move = world.time
