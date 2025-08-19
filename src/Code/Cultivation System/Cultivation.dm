mob     
    var/CultivationRealm/CurrentRealm
    var/is_already_on_maximum = FALSE
    var/cultivation_technique

mob
    proc
        is_cultivator(mob/player)
            if(!player.has_energy_type("Qi")) return FALSE
            if(!player.CurrentRealm) return FALSE
            return TRUE

        cultivate(mob/player)
            if(!is_cultivator(player)) return
            // if(!player.cultivation_technique)
            //     select_cultivation_technique(player)

            if(player.Action == "Meditating")
                cultivate_from_meditation(player)

        select_cultivation_technique(mob/player)
            var/choice = input(player, "Select a cultivation technique.", "Cultivation") 
            if(!choice) return

            player.cultivation_technique = choice
            player << "You have selected [choice] as your cultivation technique."

        Stat_Cultivation()
            var/mob/player = src
            if(is_cultivator(player))
                if(statpanel("Cultivation"))
                
                var/CultivationRealm/Realm = player.CurrentRealm
                var/CultivationStage/stage = Realm.Stage
                var/Energy/Qi = player.energies["Qi"]

                stat("Realm", Realm.Name)
                stat("Stage", stage.Name)
                stat("Progress", "[stage.Progress]/[stage.Bottleneck]")
                stat("Qi", "[Qi.quantity]/[Qi.maximum]")

                if(player.third_eye)
                    stat("Meditation Modifier", "[player.med_mod]x")

                if(player.cultivation_technique)
                    stat("Cultivation Technique", player.cultivation_technique)

                if(stage.Level == 9)
                    if(is_already_on_maximum)
                        stat("Breakthrough", "You have reached the highest stage in the [Realm.Name] cultivation realm.")


        cultivate_from_meditation(mob/player)
            var/Energy/Qi = player.energies["Qi"]
            var/CultivationStage/stage = player.CurrentRealm.Stage

            var/cultivation_mod = player.med_mod
            if(player.third_eye)
                cultivation_mod /= 2

            Qi.schedule_increase(1 * cultivation_mod)
            stage.Progress += 0.5 * cultivation_mod
            if(stage.Progress >= stage.Bottleneck)
                stage.Progress = stage.Bottleneck


            player.CurrentRealm.Stage = stage

            if(stage.Progress >= stage.Bottleneck)
                if(!is_already_on_maximum)
                    breakthrough(player, "meditating")

        breakthrough(mob/player, reason)
            var/CultivationStage/stage = player.CurrentRealm.Stage
            var/message
            var/Energy/Qi = player.energies["Qi"]
            var/cultivation_mod = player.med_mod
            
            if(player.third_eye)
                cultivation_mod /= 2

            switch(reason)
                if("meditating")
                    if(stage.Level <= 3)
                        if(cultivation_mod < 3)
                            cultivation_mod += 0.10
                    else if(stage.Level <= 6)
                        if(cultivation_mod < 4)
                            cultivation_mod += 0.25
                    else if(stage.Level < 9)
                        cultivation_mod += 0.5
                    else if(stage.Level == 9)
                        cultivation_mod += 1.5

            if(cultivation_mod > 8)
                player.med_mod = 8
            else
                if(player.third_eye)
                    player.med_mod = cultivation_mod * 2
                else
                    player.med_mod = cultivation_mod
            
            switch(stage.Level)
                if(1)
                    Qi.maximum += 100
                if(2)
                    Qi.maximum += 150
                if(3)
                    Qi.maximum += 250
                if(4)
                    Qi.maximum += 400
                if(5)
                    Qi.maximum += 800
                if(6)
                    Qi.maximum += 1500
                if(7)
                    Qi.maximum += 4700
                if(8)
                    Qi.maximum += 8000
                if(9)
                    Qi.maximum += 14000

            if(Qi.maximum > 30000)
                Qi.maximum = 30000  


            if(stage.Level == 9)
                message = "You have reached the highest stage in the [player.CurrentRealm.Name] cultivation realm."
                player << message
                player.ChatLog(message, player.ckey)
                is_already_on_maximum = TRUE

                // pass the player to the next realm
                player.CurrentRealm = CULTIVATION_REALMS["Qi Gathering"]
                player.CurrentRealm.Stage = player.CurrentRealm.Stages[1]
                
                return
            else
                message = "You have reached stage [stage.Name], in the [player.CurrentRealm.Name] cultivation realm due to [reason]."
                
                player << message
                player.ChatLog(message, player.ckey)

                stage = player.CurrentRealm.Stages[stage.Level + 1]
                player.CurrentRealm.Stage = stage
                

var
    CULTIVATION_REALMS = list(
        "Body Refining" = new /CultivationRealm("Body Refining", "The refinement of the skin, muscle and bone in preparation for creating a Dantian.", list(
            new /CultivationStage("Skin Strengthening", 1, 0, 100),
            new /CultivationStage("Pore Opening", 2, 0, 250),
            new /CultivationStage("Impurity Removal", 3, 0, 500),
            new /CultivationStage("Muscle Toning", 4, 0, 2000),
            new /CultivationStage("Tendon Enhancement", 5, 0, 2500),
            new /CultivationStage("Muscle Activation", 6, 0, 3000),
            new /CultivationStage("Bone Hardening", 7, 0, 7000),
            new /CultivationStage("Marrow Refinement", 8, 0, 10000),
            new /CultivationStage("Dantian Formation", 9, 0, 50000),
        )),
        "Qi Gathering" = new /CultivationRealm("Qi Gathering", "The gathering of Qi in the Dantian.", list(
            new /CultivationStage("Spiritual Awareness", 1, 0, 100),
            new /CultivationStage("Energy Gathering", 2, 0, 250),
            new /CultivationStage("Essence Condensation", 3, 0, 500),
            new /CultivationStage("Insight Awakening", 4, 0, 2000),
            new /CultivationStage("Mental Strenghtening", 5, 0, 2500),
            new /CultivationStage("Essence Manipulation", 6, 0, 3000),
            new /CultivationStage("Body Washing", 7, 0, 7000),
            new /CultivationStage("Qi Sealing", 8, 0, 10000),
            new /CultivationStage("Spirit Harmonisation", 9, 0, 50000),
        )),
    )

CultivationRealm
    var
        Name
        Desc = ""
        list/Stages
        Stage

    New(name, desc = "", stages)
        src.Name        = name
        src.Desc        = desc
        src.Stages      = stages
        src.Stage       = stages[1]

CultivationStage
    var
        Name
        Level
        Progress
        Bottleneck

    New(name = "Stage", level = 1, progress = 0, bottleneck = 100)
        src.Name                = name
        src.Level               =  level
        src.Progress            = progress
        src.Bottleneck          = bottleneck

        
mob/Admin4/verb/TurnIntoACultivator(mob/player in players)
    set category = "Admin"
    set name = "Turn Into A Cultivator"
    set desc = "Turns a player into a cultivator."

    if(!player.has_energy_type("Qi"))
        player.give_energy_type("Qi")

    var/CultivationRealm/realm_definition = CULTIVATION_REALMS["Body Refining"]

    var/CultivationRealm/Realm = new /CultivationRealm(realm_definition.Name, realm_definition.Desc, realm_definition.Stages)
    player.CurrentRealm = Realm
    player.Stat_Cultivation()

    player << "You have been turned into a cultivator."
    admin_blame(src, "[src.ckey] turned [player] into a cultivator.")

mob/Admin4/verb/RemoveCultivation(mob/player in players)
    set category = "Admin"
    set name = "Remove Cultivation"
    set desc = "Removes a player's cultivation."

    if(player.has_energy_type("Qi"))
        player.remove_energy_type("Qi")

    player.CurrentRealm = null
    player.Stat_Cultivation()

    player << "You have been removed from cultivation."
    admin_blame(src, "[src.ckey] removed [player] from cultivation.")

mob/Admin4/verb/GiveCultivationTechnique(mob/player in players)
    set category = "Admin"
    set name = "Give Cultivation Technique"
    set desc = "Gives a player a cultivation technique."

    select_cultivation_technique(player)
    admin_blame(src, "[src.ckey] gave [player] a cultivation technique.")