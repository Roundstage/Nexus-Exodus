mob/var
	stun_level = 0
	stun_time = 0
	tmp
		stun_loop
		stun_immunity = 0

mob/proc
	ApplyStun(time = 8, no_immunity, stun_power = 1) //10 = 1 second
		if(rp_mode) return
		if(!stun_stops_movement) no_immunity = 1 //because stun is just a slowdown it dont need an immunity time in this case
		if(knockback_immune && !no_immunity) return
		if(world.time < stun_immunity && !no_immunity) return
		stun_power *= arbitraryStunPower
		time *= global_stun_mod * arbitraryStunTime
		time = ToOne(time / stun_resistance_mod)
		if(time > 240) time = 240 //prevent ridiculously long stuns that could perma stun someone
		if(stun_level < stun_power) stun_level = stun_power
		if(stun_time < time) stun_time = time
		StunDecay()

	Stunned()
		if(stun_level > 0 || Frozen) return 1

	StunDecay()
		set waitfor=0
		if(stun_loop) return
		stun_loop = 1
		overlays -= 'StunOverlay.dmi'
		overlays += 'StunOverlay.dmi'
		while(stun_time > 0)
			stun_time -= world.tick_lag
			sleep(world.tick_lag)
			stun_immunity = world.time + 13
		overlays -= 'StunOverlay.dmi'
		stun_level = 0
		stun_loop = 0
