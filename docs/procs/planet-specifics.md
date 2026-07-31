# Planet Specifics

## Overview
Auto-generated first-pass proc summaries based on signature names. Refine descriptions during refactors.

## Files
- `src/Code/PlanetSpecifics/HellEffects.dm`
- `src/Code/PlanetSpecifics/MiningCave.dm`
- `src/Code/PlanetSpecifics/PlanetVegetaFitness.dm`
- `src/Code/PlanetSpecifics/Prison.dm`
- `src/Code/PlanetSpecifics/SaiyanKing/SaiyanArmyNPCs.dm`
- `src/Code/PlanetSpecifics/SaiyanKing/SaiyanKing.dm`
- `src/Code/PlanetSpecifics/TimeChamber.dm`

## Proc Reference

### src/Code/PlanetSpecifics/HellEffects.dm

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Make_Holy_Pendant
- Signature: `verb/Make_Holy_Pendant()`
- Inputs: None
- Purpose: Handle make holy pendant.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Hell_Immune
- Signature: `mob/proc/Hell_Immune()`
- Inputs: None
- Purpose: Handle hell immune.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Scary_Effects
- Signature: `mob/proc/Scary_Effects() while(1)`
- Inputs: None
- Purpose: Handle scary effects.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Random_Scary_Image
- Signature: `mob/proc/Random_Scary_Image() if(client)`
- Inputs: None
- Purpose: Handle random scary image.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Freddy_Kreuger_Image
- Signature: `mob/proc/Freddy_Kreuger_Image()`
- Inputs: None
- Purpose: Handle freddy kreuger image.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/scare
- Signature: `mob/Admin5/verb/scare()`
- Inputs: None
- Purpose: Handle scare.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Hell_Michael_Jackson
- Signature: `mob/proc/Hell_Michael_Jackson() while(1)`
- Inputs: None
- Purpose: Handle hell michael jackson.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Hell_Diarea
- Signature: `mob/proc/Hell_Diarea() while(1)`
- Inputs: None
- Purpose: Handle hell diarea.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Map_Confusion
- Signature: `mob/proc/Map_Confusion() while(1)`
- Inputs: None
- Purpose: Handle map confusion.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Map_Confusion
- Signature: `proc/Map_Confusion(mob/P) while(src&&P)`
- Inputs: mob/P
- Purpose: Handle map confusion.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlanetSpecifics/MiningCave.dm

#### turf/Mining_Rock/Enter
- Signature: `Enter(atom/A)`
- Inputs: atom/A
- Purpose: Handle enter.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Mining_Rock/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/MiningRockRespawn
- Signature: `MiningRockRespawn()`
- Inputs: None
- Purpose: Handle mining rock respawn.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlanetSpecifics/PlanetVegetaFitness.dm

#### mob/proc/FreezaRunnerCowardKill
- Signature: `FreezaRunnerCowardKill()`
- Inputs: None
- Purpose: Handle freeza runner coward kill.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Planet_Braal_Fitness_Objects/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Planet_Braal_Fitness_Objects/Lord_Freeza_Death_Ball_Graphic/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Planet_Braal_Fitness_Objects/Lord_Freeza/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Lord_Freeza_kill_someone
- Signature: `proc/Lord_Freeza_kill_someone(mob/m,msg)`
- Inputs: mob/m, msg
- Purpose: Handle lord freeza kill someone.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Death_ball_kill
- Signature: `proc/Death_ball_kill(mob/m,idle_timer=40)`
- Inputs: mob/m, idle_timer=40
- Purpose: Handle death ball kill.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Lord_Freeza_loop
- Signature: `proc/Lord_Freeza_loop()`
- Inputs: None
- Purpose: Handle lord freeza loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Lord_Freeza_nuke
- Signature: `proc/Lord_Freeza_nuke()`
- Inputs: None
- Purpose: Handle lord freeza nuke.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Freeza_detonate
- Signature: `proc/Freeza_detonate(nuke_bp=0,turf/origin,range=30)`
- Inputs: nuke_bp=0, turf/origin, range=30
- Purpose: Handle freeza detonate.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlanetSpecifics/Prison.dm

#### proc/Prisoner_Mark
- Signature: `proc/Prisoner_Mark()`
- Inputs: None
- Purpose: Handle prisoner mark.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Prison_Time_Remaining
- Signature: `Prison_Time_Remaining()`
- Inputs: None
- Purpose: Handle prison time remaining.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Imprison
- Signature: `Imprison() if(!Prisoner())`
- Inputs: None
- Purpose: Handle imprison.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Send_Bounty_Drone
- Signature: `proc/Send_Bounty_Drone()`
- Inputs: None
- Purpose: Handle send bounty drone.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DeployDroneNoWait
- Signature: `proc/DeployDroneNoWait(mob/M,mob/Redeploy,turf/drone_loc,mob/deployer)`
- Inputs: mob/M, mob/Redeploy, turf/drone_loc, mob/deployer
- Purpose: Handle deploy drone no wait.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Deploy_Drone
- Signature: `proc/Deploy_Drone(mob/M,mob/Redeploy,turf/drone_loc,mob/deployer)`
- Inputs: mob/M, mob/Redeploy, turf/drone_loc, mob/deployer
- Purpose: Handle deploy drone.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Bounty_Drone/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Bounty_Drone/Move
- Signature: `Move()`
- Inputs: None
- Purpose: Handle move.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Bounty_Drone/proc/Bounty_Drone
- Signature: `Bounty_Drone()`
- Inputs: None
- Purpose: Handle bounty drone.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Bounty_Drone/proc/Bounty_Ray
- Signature: `Bounty_Ray()`
- Inputs: None
- Purpose: Handle bounty ray.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlanetSpecifics/SaiyanKing/SaiyanArmyNPCs.dm

#### proc/RandomHumanIcon
- Signature: `RandomHumanIcon()`
- Inputs: None
- Purpose: Handle random human icon.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/RandomHairIcon
- Signature: `RandomHairIcon()`
- Inputs: None
- Purpose: Handle random hair icon.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Saiyan_Army/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Saiyan_Army/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlanetSpecifics/SaiyanKing/SaiyanKing.dm

#### proc/SpawnKingBraalThrone
- Signature: `SpawnKingBraalThrone()`
- Inputs: None
- Purpose: Spawn King Braal Throne.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/StartupSpawnKingBraalThrone
- Signature: `StartupSpawnKingBraalThrone()`
- Inputs: None
- Purpose: Handle startup spawn king braal throne.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/KOV/verb/KOV_Guide
- Signature: `KOV_Guide()`
- Inputs: None
- Purpose: Handle kov guide.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/KOV/verb/KOV_Message
- Signature: `KOV_Message()`
- Inputs: None
- Purpose: Handle kov message.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/KOV/verb/KOV_Spawn_Saiyan_NPC
- Signature: `KOV_Spawn_Saiyan_NPC()`
- Inputs: None
- Purpose: Handle kov spawn saiyan npc.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/KOV/verb/KOV_Recall_All_Soldiers
- Signature: `KOV_Recall_All_Soldiers()`
- Inputs: None
- Purpose: Handle kov recall all soldiers.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/KOV/verb/KOV_Delete_All_Soldiers
- Signature: `KOV_Delete_All_Soldiers()`
- Inputs: None
- Purpose: Handle kov delete all soldiers.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CheckKingOfBraalVerbs
- Signature: `CheckKingOfBraalVerbs()`
- Inputs: None
- Purpose: Check King Of Braal Verbs.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/King_of_Braal_Throne/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/King_of_Braal_Throne/proc/KOV_ThroneOffPlanetCheck
- Signature: `KOV_ThroneOffPlanetCheck()`
- Inputs: None
- Purpose: Handle kov throne off planet check.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/King_of_Braal_Throne/proc/KOV_ThroneTellPeopleWhoKingLoop
- Signature: `KOV_ThroneTellPeopleWhoKingLoop()`
- Inputs: None
- Purpose: Handle kov throne tell people who king loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BumpKingBraalThrone
- Signature: `BumpKingBraalThrone()`
- Inputs: None
- Purpose: Handle bump king braal throne.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BecomeKingBraal
- Signature: `BecomeKingBraal()`
- Inputs: None
- Purpose: Handle become king braal.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/PlanetBraalMsg
- Signature: `PlanetBraalMsg(t)`
- Inputs: t
- Purpose: Handle planet braal msg.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlanetSpecifics/TimeChamber.dm

#### proc/HBTC_Timer
- Signature: `proc/HBTC_Timer() while(1)`
- Inputs: None
- Purpose: Handle hbtc timer.
- Returns: none (implicit).
- Side effects: see implementation.
