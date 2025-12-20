mob/var/tmp/lastResetStepXY = 0
mob/var/tmp/stepSizeLabel = 32 //for displaying in tabs

mob/proc/AlignToTile()
	set waitfor=0
	if(!client) return
	if(last_north_up == world.time)
		if(step_y > 0)
			var/dist_to_next_tile = abs(32 - step_y)
			LerpToTile(NORTH, dist_to_next_tile)
	if(last_east_up == world.time)
		if(step_x > 0)
			var/dist_to_next_tile = abs(32 - step_x)
			LerpToTile(EAST, dist_to_next_tile)
	if(last_south_up == world.time)
		LerpToTile(SOUTH, step_y)
	if(last_west_up == world.time)
		LerpToTile(WEST, step_x)

mob/proc/LerpToTile(d, dist)
	set waitfor=0
	if(dist == 0) return
	while(dist > 0)
		var/step_dist = dist
		if(step_dist < 0) step_dist = 0
		if(step_dist > dist) step_dist = dist
		dist -= step_dist
		var/prevDir = dir
		step(src, d, step_dist)
		dir = prevDir
		sleep(world.tick_lag)

mob/proc/ResetStepXY()
	if(lastResetStepXY == world.time) return //prevent infinite step() loops
	lastResetStepXY = world.time
	var/prevDir = dir
	if(step_x > 16) step(src, EAST, 32 - step_x)
	if(step_y > 16) step(src, NORTH, 32 - step_y)
	if(step_x) step(src, WEST, step_x)
	if(step_y) step(src, SOUTH, step_y)
	dir = prevDir

mob/proc/NpcAlignToTile(d)
	set waitfor=0
	if(d != NORTH && d != NORTHWEST && d != NORTHEAST)
		if(d != SOUTH && d != SOUTHEAST && d != SOUTHWEST)
			if(step_y > 0)
				var/dist_to_next_tile = abs(32 - step_y)
				LerpToTile(NORTH, dist_to_next_tile)
	if(d != EAST && d != NORTHEAST && d != SOUTHEAST)
		if(d != WEST && d != SOUTHWEST && d != NORTHWEST)
			if(step_x > 0)
				var/dist_to_next_tile = abs(32 - step_x)
				LerpToTile(EAST, dist_to_next_tile)
	if(d != SOUTH && d != SOUTHEAST && d != SOUTHWEST)
		if(d != NORTH && d != NORTHWEST && d != NORTHEAST)
			LerpToTile(SOUTH, step_y)
	if(d != WEST && d != SOUTHWEST && d != NORTHWEST)
		if(d != EAST && d != NORTHEAST && d != SOUTHEAST)
			LerpToTile(WEST, step_x)

mob/proc/UpdateStepSpeed()
	set waitfor=0
	if(last_move == world.time) return

	if(force_32_pix_movement)
		step_size = 32
		step_x = 0
		step_y = 0
		return

	if(ultra_instinct)
		step_size = 32
		return

	var/minSpeed = 16
	var/lowMaxAdd = 10
	var/normalSpeed = minSpeed + lowMaxAdd
	var/ratio = Spd / avg_speed
	var/speed = minSpeed
	if(ratio < 1)
		speed += ratio * lowMaxAdd
	else
		speed = normalSpeed
		speed += (ratio - 1) * 6
	stepSizeLabel = speed
	var/delay_mult = GetInputMoveDelay(move_dir(), raw_mult_only = 1)
	speed /= delay_mult
	speed *= 20 / world.fps
	if(speed > 32) speed = 32
	step_size = speed
