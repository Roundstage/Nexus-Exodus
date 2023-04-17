mob/proc/cycle_energies()
    var/mob/player = src
    while(TRUE)
        for(var/name in player.energies)
            var/Energy/energy = player.energies[name]
            energy.cycle_energy()
        sleep(10)

mob/proc/update_logging_system()
    var/mob/player = src
    while(TRUE)
        player.Write_chatlogs()
        sleep(100)

mob/proc/update_cultivation()
    var/mob/player = src
    while(TRUE)
        cultivate(player)
        sleep(10)

mob/proc/try_to_apply_burn_effect()
    var/mob/player = src
    while(TRUE)
        player.try_applying_burn_effect()
        sleep(10)

mob/proc/try_to_heal_combat_ko()
    var/mob/victim = src
    while(TRUE)
        victim.try_healing_combat_ko(victim)
        sleep(10)

mob/proc/execute_player_actions()
    var/mob/player = src
    spawn(1)
        player.try_to_apply_burn_effect()
    spawn(1)
        player.try_to_heal_combat_ko()
    spawn(1)
        player.cycle_energies()
    spawn(1)
        player.update_logging_system()
    spawn(1)
        player.update_cultivation()

var/list/already_started = list()
proc/LogicLoop()
    while (TRUE)
        for(var/mob/player in players)
            if(!(player in already_started))
                already_started += player
                player.execute_player_actions()

        sleep(10) //sleep(world.tick_lag)
        //if(world.tick_usage > 80) sleep(world.tick_lag)
    

