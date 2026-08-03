mob/proc/try_applying_burn_effect()
	set waitfor = 0
	if(!isBurning || burn_effect_running) return
	burn_effect_running = TRUE
	var/regen_before_effect = regen
	var/regen_after_effect = regen_before_effect * 0.7

	while(src && BurnStack > 0)
		src << "You are burning!"
		Health -= 3
		regen = regen_after_effect
		BurnStack--

		if(Health == 0) KO("You have been knockout by the Burns, ouch!", allow_anger = 1)
		sleep(20)

	if(src)
		regen = regen_before_effect
		src << "You aren't burning anymore."
		isBurning = FALSE
		burn_effect_running = FALSE
