mob/proc/try_applying_burn_effect()
    var/mob/player = src

    if(!player.isBurning) return
    var/regen_before_effect     = player.regen
    var/regen_after_effect       = regen_before_effect * 0.7

    while(player.BurnStack > 0)
        player << "You are burning!"

        player.Health       -= 3
        player.regen        = regen_after_effect
        player.BurnStack    -= 1

        if(player.Health == 0)
            player.KO("You have been knockout by the Burns, ouch!", allow_anger=1)
        
        sleep(20)


    player.regen = regen_before_effect;
    player << "You aren't burning anymore."
    player.isBurning = FALSE
