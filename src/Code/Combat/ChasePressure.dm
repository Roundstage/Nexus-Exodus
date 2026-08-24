mob/var/tmp
	being_chased=0
	chaser_mob
	last_chase_from_outside_gym=0 //world.time
var
	chase_start_dist=14

mob/proc/Opponent_move_slower_if_you_are_chasing_them()
	set waitfor=0
	var/mob/m = last_mob_attacked

	var/attack_time = 0
	if(m && (key in m.attack_log)) attack_time = m.attack_log[key][1]

	if(m && m!= src && ismob(m) && current_area == m.current_area && !m.KB && world.time - m.last_knockbacked > 25)
		if(world.time - attack_time < 160 && getdist(src,m) >= chase_start_dist)
			if(get_dir(src,m) in list(dir,turn(dir,45),turn(dir,-45)))
				m.being_chased = world.time

				if(getdist(lord_freeza_obj,m) >= 25) last_chase_from_outside_gym = world.time

				m.chaser_mob=src

mob/proc/Being_chased()
	var/mob/c = chaser_mob
	if(c)
		if(getdist(src,c) >= chase_start_dist || world.time - being_chased < 25)
			if(!(get_dir(src,c) in list(dir,turn(dir,45),turn(dir,-45))) || world.time - being_chased < 17)
				if(world.time - being_chased < 60) return 1
			else being_chased=0
		else being_chased=0
