Seal
    var
        sealed = FALSE
        duration = 0
        last_seal_change = 0
        seal_reason = ""
        unseal_reason = "Unsealed by default."

    proc
        Seal(reason, duration)
            src.sealed              = TRUE
            src.duration            = duration
            src.last_seal_change    = world.time
        
        Unseal(reason)
            src.sealed              = FALSE
            src.duration            =  0
            src.last_seal_change    = world.time

        Cycle_Seal(seal_change = 1)
            if(!src.sealed) return

            src.duration -= seal_change

            if(src.duration <= 0)
                src.Unseal("Seal duration expired.")

EnergySchedule
    var
        operation
        amount
        duration
        reason
    New(operation, amount = 1, duration = 1, reason)
        src.operation   = operation
        src.amount      = amount
        src.duration    = duration
        src.reason      = reason

Energy
    var
        name                    = "Default Energy"
        description             = "Default Energy Description"
        quantity                = 100
        maximum                 = 100
        increases_naturally     = TRUE

        modifier                = 1.0
        list/modifier_reasons   = list()
        list/schedule           = list()

        Seal/seal               = new()


    New(name, maximum = 100, modifier = 1.0, increases_naturally = TRUE)
        src.name                = name
        src.quantity            = maximum
        src.maximum             = maximum
        src.modifier            = modifier
        src.increases_naturally = increases_naturally
    
    proc
        increase(amount = 1)
            if(seal.sealed) return

            quantity += amount

            if(quantity > maximum)
                quantity = maximum
        
        decrease(amount = 1)
            quantity -= amount

            if(quantity < 0)
                quantity = 0

        increase_maxiumum(amount = 1)
            maximum += amount
        
        decrease_maximum(amount = 1)
            maximum -= amount

            if(maximum < 0)
                maximum = 0

        schedule_decrease(amount = 1, duration = 1, reason = "Scheduled decrease")
            if(length(schedule) > 20)
                schedule -= schedule[1]

            if(duration > 6000)         duration = 6000

            var/EnergySchedule/task = new(
                "decrease",
                amount,
                duration,
                reason
            )

            schedule.Add(task)

        schedule_increase(amount = 1, duration = 1, reason = "Scheduled increase")
            if(length(schedule) > 20)
                schedule -= schedule[1]
            if(duration > 6000)         duration = 6000
            
            var/EnergySchedule/task = new(
                "increase",
                amount,
                duration,
                reason
            )
            schedule.Add(task)

        cycle_energy()
            if(seal.sealed) 
                seal.Cycle_Seal()
                return

            for(var/EnergySchedule/task in schedule)
                var/operation   = task.operation
                var/amount      = task.amount

                if(operation == "decrease")
                    decrease(amount)

                if(operation == "increase")
                    increase(amount)

                task.duration -= 1
                if(task.duration <= 0)
                    schedule.Remove(task)
                    del(task)


            if(quantity < maximum && increases_naturally)
                schedule_increase(0.5, reason = "Natural recovery")

// ############################################################################################
// Energy definitions

var/list/GLOBAL_ENERGY_TYPES = list(
    "Mental Energy" 	= new /Energy("Mental Energy"),
    "Soul Energy"   	= new /Energy("Soul Energy"),
    "Spirit Energy" 	= new /Energy("Spirit Energy"),
    "Qi"     	        = new /Energy("Qi Energy", increases_naturally = FALSE)
)

mob/proc/has_energy_type(energy_type)
    if(energy_type in src.energies)
        return TRUE
    return FALSE

mob/proc/give_energy_type(mob/player, energy_type, amount = 100, maximum = 100, modifier = 100)
    if(energy_type in player.energies)
        return

    if(!GLOBAL_ENERGY_TYPES[energy_type])
        return

    var/Energy/new_energy = new /Energy(energy_type, amount, maximum, modifier)

    player.energies[energy_type] = new_energy

mob/proc/remove_energy_type(mob/player, energy_type)
    player.energies -= energy_type

mob/Admin2/verb/GiveEnergyTypeToPlayer(mob/player in players)
    set category = "Admin"
    set name = "Give an energy type to a player"
    set desc = "Give an energy type to a player"

    var/list/available_energies = list()

    for(var/energy_type in GLOBAL_ENERGY_TYPES)
        if(!player.energies[energy_type])
            available_energies.Add(energy_type)

    var/energy   = input("Select an energy type to unlock.") as null|anything in available_energies

    give_energy_type(player, energy, 100, 100, 1)
    admin_blame(src, "[src.ckey] gave [energy] to [player]")

mob/Admin2/verb/RemoveEnergyTypeFromPlayer(mob/player in players)
    set category = "Admin"
    set name = "Remove an energy type from a player"
    set desc = "Remove an energy type from a player"

    var/list/available_energies = list()

    for(var/energy_type in player.energies)
        available_energies.Add(energy_type)

    var/Energy/energy = input("Select an energy type to remove.") as null|anything in available_energies

    remove_energy_type(player, energy)
    admin_blame(src, "[src.ckey] removed [energy] from [player]")

