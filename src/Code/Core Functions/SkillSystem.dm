mob/proc/get_energy(type)
    if(src.energies && src.energies[type])
        return src.energies[type]
    return FALSE

Skill
    var
        name
        description
        energy_type
        cost
        cooldown
        can_hotbar  = TRUE
        hotbar_type = "Melee"

    New(name, description, energy_type, cooldown, cost, can_hotbar = TRUE, hotbar_type = "Melee")
        src.name = name
        src.description = description
        src.energy_type = energy_type
        src.cooldown = cooldown
        src.cost = cost
        src.can_hotbar = can_hotbar
        src.hotbar_type = hotbar_type

    proc
        Trigger()
            var/mob/player = usr
            player << "You use [src.name] for [src.cost] [src.energy_type]. You now have"
            return 

        Activate()
            if(CanActivate())
                src.Trigger()

        Deactivate()
            return

        CanActivate()
            var/mob/player      = usr
            var/Energy/energy   = player.get_energy(src.energy_type)
            if(!energy) return FALSE
            var/quantity        = energy.quantity

            if(energy.seal.sealed)
                player << "Your [src.energy_type] is sealed, so you can't use [src.name]."
                return FALSE

            if(src.cooldown > 0)
                player << "[src.name] is on cooldown. ([round(src.cooldown/10, 1)] seconds remaining."
                return FALSE

            if(quantity < src.cost)
                player << "You don't have enough [src.energy_type] to use [src.name] ([quantity]/[src.cost])."
                return FALSE

            return TRUE



            

            
                

    
    
