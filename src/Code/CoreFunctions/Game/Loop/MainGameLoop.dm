mob/var/tmp/player_action_loop_running = FALSE

mob/proc/process_player_action_cycle(run_background_tasks = FALSE)
	try_applying_burn_effect()
	try_healing_combat_ko(src)
	Update_health_bars()
	if(islist(energies))
		for(var/name in energies)
			var/Energy/energy = energies[name]
			if(energy) energy.cycle_energy()

	if(!run_background_tasks) return
	if(islist(unwritten_chatlogs) && unwritten_chatlogs.len) Write_chatlogs()
	syncTechnologyProgression(silent = FALSE)
	syncMagicProgression(silent = FALSE)
	syncMilestoneProgression(silent = FALSE)

mob/proc/execute_player_actions()
	set waitfor = 0
	if(player_action_loop_running) return
	player_action_loop_running = TRUE
	var/next_background_update = 0

	while(src && (src in players))
		var/run_background_tasks = world.time >= next_background_update
		process_player_action_cycle(run_background_tasks)
		if(run_background_tasks) next_background_update = world.time + 100
		sleep(10)

	player_action_loop_running = FALSE

proc/LogicLoop()
	while(TRUE)
		for(var/mob/player in players)
			if(player && !player.player_action_loop_running) player.execute_player_actions()
		sleep(10) //sleep(world.tick_lag)
		//if(world.tick_usage > 80) sleep(world.tick_lag)
