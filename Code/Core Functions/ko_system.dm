mob
    var/tmp
        healing_modifier                = 1
        has_healing_modifier_changed    = FALSE
        is_waiting_for_healing          = FALSE
        last_combat_timeout_message     = 0
        has_angered_before_ko           = FALSE
        is_healing_something            = FALSE

    proc
        Cause_Combat_KO(var/mob/victim, var/mob/attacker)
            var/cause_of_ko_spar    = "[victim] was defeated by [attacker] during a [CASUAL_COMBAT]."
            var/cause_of_ko_lethal  = "[victim] was defeated by [attacker] during a [LETHAL_COMBAT]."

            // Check for casual instead of lethal since other sources of KO's don't have a 
            // sparring mode, and they should always be lethal
            if(attacker.sparring_mode == CASUAL_COMBAT)
                announce_combat_message(cause_of_ko_spar, center = victim)
                return
            else
                increase_combat_ko(cause_of_ko_lethal, victim = victim)

        increase_combat_ko(var/reason_of_increase, quantity = 1, mob/victim)
            var/mob/attacker = usr

            victim.combat_ko_total += quantity

            if(victim.combat_ko_total  >= KO_SYSTEM_UNCONSCIOUS_KO)
                victim.combat_ko_total  = KO_SYSTEM_UNCONSCIOUS_KO
                reason_of_increase   = "[reason_of_increase] [victim] is now unconscious. "
                
                victim.KO(attacker, allow_anger = FALSE, combat_ko_handled = TRUE)

            victim.is_waiting_for_healing = FALSE

            var/indicator_arrow = "<span style='color: red;'>↑</span>"
            var/ko_message = "[reason_of_increase] ([victim.combat_ko_total]/[KO_SYSTEM_UNCONSCIOUS_KO] KO's)[indicator_arrow]."

            victim.has_angered_before_ko   = FALSE
            victim.Calm()
            
            victim.announce_combat_message(ko_message, center = victim)

        decrease_combat_ko(var/reason_of_decrease, quantity = 1, mob/victim)
            var/original_ko_total = victim.combat_ko_total
            victim.combat_ko_total -= quantity
            
            if(victim.combat_ko_total < 0)
                victim.combat_ko_total = 0

            var/indicator_arrow = "<span style='color: green;'>↓</span>"
            var/ko_message = "[reason_of_decrease] ([original_ko_total] -> [victim.combat_ko_total]/[KO_SYSTEM_UNCONSCIOUS_KO] KO's)[indicator_arrow]."

            victim.announce_combat_message(ko_message, center = victim)

        get_time_out_of_combat(mob/victim)
            return world.time - victim.last_attacked_time

        has_entered_combat(mob/victim)
            if(victim.get_time_out_of_combat(victim = victim) <= KO_SYSTEM_OUT_OF_COMBAT_TIMER)
                return TRUE
            return FALSE

        is_out_of_combat(mob/victim)
            if(victim.combat_ko_total >= KO_SYSTEM_UNCONSCIOUS_KO && victim.KO)
                return TRUE

            if(!victim.has_entered_combat(victim = victim))
                return TRUE

            return FALSE

        announce_combat_message(var/message, var/mob/center)
            for(var/mob/observer in view(44, center))
                observer << "[message]"
                observer.ChatLog("[message]", observer.key)
        
        time_to_heal_ko(mob/victim)
            var/time_to_heal = 1
            
            if(victim.combat_ko_total >= KO_SYSTEM_UNCONSCIOUS_KO)
                time_to_heal = KO_SYSTEM_UNCONSCIOUS_KO_DURATION
            else 
                time_to_heal = KO_SYSTEM_NORMAL_KO_DURATION

            time_to_heal = time_to_heal * healing_modifier
            
            // Z level 10 is the HBTC (Hyperbolic Time Chamber),
            // so we reduce heal to reflect that time passes faster there.
            // TODO: this should be done as a healing modifier instead.
            if(victim.z == Z_LEVEL_HBTC) 
                time_to_heal /= 6

            return time_to_heal
        
        set_healing_modifier(var/modifier, var/reason, var/is_cummulative = FALSE, mob/victim)
            if(modifier == victim.healing_modifier)
                return
            if(modifier <= 0)
                return

            if(is_cummulative)
                victim.healing_modifier *= modifier

            var/modifier_change_reason = "[victim]'s total time to heal has been modified from [victim.healing_modifier] to [modifier]x due to [reason]."

            victim.healing_modifier                 = modifier
            victim.has_healing_modifier_changed     = TRUE

            announce_combat_message(modifier_change_reason, center = victim)

        heal_spar_ko(mob/victim, time_to_heal)
            var/spar_ko_message = "[victim] will come up from their defeat in [round(time_to_heal/10, 1)] seconds."
            var/healed_message  = "[victim] comes back up from their defeat in a [CASUAL_COMBAT]."
            announce_combat_message(spar_ko_message, center = victim)

            sleep(time_to_heal)

            announce_combat_message(healed_message, center = victim)

            victim.UnKO()
            victim.has_angered_before_ko = FALSE
            if(KO_SYSTEM_FULL_HEAL_IN_SPAR)
                victim.FullHeal()

        initiate_healing(mob/victim, time_to_heal, healed_message)
            var/elapsed_time = 0
            var/close_to_healing_threshold = time_to_heal - 100
            var/on_threshold = FALSE

            // We can't use Spawn() here as it is possible for the player to have their healing time reduced by external factors.
            // For example, the player could be dragged to a regenerator, have someone heal them, and so on.
            if(victim.is_healing_something)
                return
            victim.is_healing_something = TRUE
            while(elapsed_time < time_to_heal)
                elapsed_time += 10

                if(!is_out_of_combat(victim = victim))
                    var/attack_message = "[victim] has been disrupted from healing their last combat KO."
                    announce_combat_message(attack_message, center = victim)
                    return
                if(victim.has_healing_modifier_changed)
                    var/new_time_to_heal                = victim.time_to_heal_ko(victim = victim)

                    var/current_percentage_healed       = (elapsed_time / time_to_heal) * 100
                    var/new_percentage_healed           = (elapsed_time / new_time_to_heal) * 100

                    var/current_remaining               = 100 - (100 - current_percentage_healed)
                    var/new_remaining                   = 100 - (100 - new_percentage_healed)

                    var/ponderated_remaining_percentage = 100 - (100 - (current_remaining + new_remaining)/2)
                    var/new_elapsed                     = (ponderated_remaining_percentage * new_time_to_heal) / 100

                    var/update_message = {"\
                        [victim]'s total time to heal has changed. They will now heal in [round(new_time_to_heal / 10, 1)] seconds.\
                        As they had healed [round(current_percentage_healed, 1)]% of their previous healing time,\
                        their new progress is now [round(ponderated_remaining_percentage, 1)]% ([round(new_elapsed/10, 1)] out of [round(new_time_to_heal / 10, 1)] seconds).\
                    "}

                    elapsed_time                = round(new_elapsed, 1)
                    time_to_heal                = new_time_to_heal
                    close_to_healing_threshold  = new_time_to_heal - 100

                    announce_combat_message(update_message, center = victim)

                    victim.has_healing_modifier_changed = FALSE
                
                if(elapsed_time % KO_SYSTEM_HEAL_ANNOUNCE_TIMER == 0 || elapsed_time >= close_to_healing_threshold)
                    if(!on_threshold)
                        var/time_remaining          = round((time_to_heal - elapsed_time) / 10, 1)
                        var/time_remaining_message  = "[victim] will heal in [time_remaining] seconds."

                        announce_combat_message(time_remaining_message, center = victim)
                        on_threshold = TRUE

                sleep(10)

            if(victim.combat_ko_total >= KO_SYSTEM_UNCONSCIOUS_KO)
                // Don't heal the player since they are severely injured and the fight should already be over
                // death regen does still heal the player though
                victim.UnKO()

                // Players only suffer Zenkai after near death
                victim.Zenkai()
            else
                victim.FullHeal()

            victim.is_waiting_for_healing = FALSE
            victim.is_healing_something = FALSE
            victim.has_angered_before_ko = FALSE
            victim.decrease_combat_ko(healed_message, victim = victim)

        try_healing_combat_ko(mob/victim)
            var/time_to_heal            = victim.time_to_heal_ko(victim = victim)
            var/time_to_heal_message    = "[victim] will heal from their latest Combat KO ([victim.combat_ko_total]) in [round(time_to_heal / 10, 1)] seconds."
            var/healed_message          = "[victim] has healed from their latest Combat KO."

            if(victim.is_out_of_combat(victim = victim))
                victim.has_angered_before_ko = FALSE
                victim.Calm()

            if(victim.combat_ko_total <= 0 && victim.KO)
                heal_spar_ko(victim, time_to_heal)
                return
            if(victim.combat_ko_total <= 0)
                return

            if(victim.is_out_of_combat(victim = victim))
                if(victim.is_waiting_for_healing) return
                victim.is_waiting_for_healing = TRUE

                announce_combat_message(time_to_heal_message, center = victim)
                initiate_healing(victim, time_to_heal, healed_message)
                
            else 
                // Triggers when a player is still in combat, but has been KO'd
                if(victim.KO && !is_waiting_for_healing)
                    var/unko_message = "[victim] will get up in [round(time_to_heal / 10, 1)] seconds."
                    healed_message = "[victim] got up after being defeated."

                    announce_combat_message(unko_message, center = victim)

                    is_waiting_for_healing = TRUE
                    sleep(time_to_heal)
                    victim.has_angered_before_ko = FALSE
                    victim.FullHeal()
                    announce_combat_message(healed_message, center = victim)

                    is_waiting_for_healing = FALSE
                else
                    var/time_until_healing = round((KO_SYSTEM_OUT_OF_COMBAT_TIMER - victim.get_time_out_of_combat(victim = victim)) / 10, 1)
                    if(time_until_healing <  0) 
                        time_until_healing = 0
                        return

                    if(last_combat_timeout_message + 300 > world.time)
                        return
                    victim << "You are still considered in combat, and cannot heal from your last Combat KO. You will be able to heal in [time_until_healing] seconds."
                    last_combat_timeout_message = world.time

