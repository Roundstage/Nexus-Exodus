# Admin

## Overview
Auto-generated first-pass proc summaries based on signature names. Refine descriptions during refactors.

## Files
- `src/Code/Admin/Admin.dm`
- `src/Code/Admin/AdminV2.dm`
- `src/Code/Admin/AdminVerbs.dm`

## Proc Reference

### src/Code/Admin/Admin.dm

#### mob/Admin4/verb/Toggle_Admin_Inf_Knowledge_For_Self
- Signature: `mob/Admin4/verb/Toggle_Admin_Inf_Knowledge_For_Self()`
- Inputs: None
- Purpose: Toggle Admin Inf Knowledge For Self.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/TrainingTimeLogin
- Signature: `TrainingTimeLogin()`
- Inputs: None
- Purpose: Handle training time login.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/TrainingTimeRestoreLoop
- Signature: `TrainingTimeRestoreLoop()`
- Inputs: None
- Purpose: Handle training time restore loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/TrainingTimeDrainLoop
- Signature: `TrainingTimeDrainLoop()`
- Inputs: None
- Purpose: Handle training time drain loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/LimitTrainingMsg
- Signature: `proc/LimitTrainingMsg()`
- Inputs: None
- Purpose: Handle limit training msg.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/CheckDeleteHellAltar
- Signature: `proc/CheckDeleteHellAltar(wait = 0)`
- Inputs: wait = 0
- Purpose: Check Delete Hell Altar.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ToggleBraalGym
- Signature: `proc/ToggleBraalGym(wait = 0)`
- Inputs: wait = 0
- Purpose: Toggle Braal Gym.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin5/verb/afk5
- Signature: `mob/Admin5/verb/afk5()`
- Inputs: None
- Purpose: Handle afk5.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/KickAFKPlayer
- Signature: `mob/proc/KickAFKPlayer(afkTime = 1800, noAdmins = 1)`
- Inputs: afkTime = 1800, noAdmins = 1
- Purpose: Handle kick afkplayer.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/LogoutWait
- Signature: `mob/proc/LogoutWait(waitTime = 1)`
- Inputs: waitTime = 1
- Purpose: Handle logout wait.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/Show_Ships
- Signature: `mob/Admin5/verb/Show_Ships()`
- Inputs: None
- Purpose: Handle show ships.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/AutoBPResetLoop
- Signature: `proc/AutoBPResetLoop()`
- Inputs: None
- Purpose: Handle auto bpreset loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Set_Dodging_and_Deflecting_Mode
- Signature: `mob/Admin4/verb/Set_Dodging_and_Deflecting_Mode()`
- Inputs: None
- Purpose: Set Dodging and Deflecting Mode.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/UpdateHighestPlayerCount
- Signature: `UpdateHighestPlayerCount()`
- Inputs: None
- Purpose: Update Highest Player Count.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin4/verb/Set_Void_Rules
- Signature: `mob/Admin4/verb/Set_Void_Rules()`
- Inputs: None
- Purpose: Set Void Rules.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin3/verb/Fix_Resource_Bug
- Signature: `mob/Admin3/verb/Fix_Resource_Bug()`
- Inputs: None
- Purpose: Handle fix resource bug.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ResetResourcesCheck
- Signature: `mob/proc/ResetResourcesCheck()`
- Inputs: None
- Purpose: Handle reset resources check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/Destroy_Built_Objs_Of_This_Person
- Signature: `mob/Admin3/verb/Destroy_Built_Objs_Of_This_Person(obj/t in world)`
- Inputs: obj/t in world
- Purpose: Handle destroy built objs of this person.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/Destroy_Turfs_Of_This_Person
- Signature: `mob/Admin3/verb/Destroy_Turfs_Of_This_Person(turf/t in world)`
- Inputs: turf/t in world
- Purpose: Handle destroy turfs of this person.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DestroyTurfsOfPersonNoWait
- Signature: `proc/DestroyTurfsOfPersonNoWait(turf/t)`
- Inputs: turf/t
- Purpose: Handle destroy turfs of person no wait.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/BP_Equalizer/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/Create_BP_Equalizer_Here
- Signature: `mob/Admin3/verb/Create_BP_Equalizer_Here()`
- Inputs: None
- Purpose: Create BP Equalizer Here.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/GetBPEqualizer
- Signature: `GetBPEqualizer()`
- Inputs: None
- Purpose: Return BPEqualizer.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/ObeyBPEqualizer
- Signature: `ObeyBPEqualizer()`
- Inputs: None
- Purpose: Handle obey bpequalizer.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Convert_Walls_to_New_Owner
- Signature: `mob/Admin4/verb/Convert_Walls_to_New_Owner(turf/t in world)`
- Inputs: turf/t in world
- Purpose: Handle convert walls to new owner.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DuplicateModulesBugFix
- Signature: `mob/proc/DuplicateModulesBugFix() //fix a bug where people found out how to install the same type of module repeatedly`
- Inputs: None
- Purpose: Handle duplicate modules bug fix.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Invis_Browser
- Signature: `mob/Admin4/verb/Invis_Browser()`
- Inputs: None
- Purpose: Handle invis browser.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Override_All_Spawns
- Signature: `mob/Admin4/verb/Override_All_Spawns()`
- Inputs: None
- Purpose: Handle override all spawns.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Delete_blank_mobs_loop
- Signature: `proc/Delete_blank_mobs_loop()`
- Inputs: None
- Purpose: Delete blank mobs loop.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin5/verb/Common_types_test
- Signature: `mob/Admin5/verb/Common_types_test()`
- Inputs: None
- Purpose: Handle common types test.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Make_dragon_balls_active_now
- Signature: `mob/Admin4/verb/Make_dragon_balls_active_now()`
- Inputs: None
- Purpose: Handle make dragon balls active now.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/SetDragonBallWishCooldown
- Signature: `mob/Admin3/verb/SetDragonBallWishCooldown()`
- Inputs: None
- Purpose: Set Dragon Ball Wish Cooldown.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin4/verb/Zombie_info
- Signature: `mob/Admin4/verb/Zombie_info()`
- Inputs: None
- Purpose: Handle zombie info.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Zombie_locs
- Signature: `mob/Admin4/verb/Zombie_locs()`
- Inputs: None
- Purpose: Handle zombie locs.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Pwipe_vote_settings
- Signature: `mob/Admin4/verb/Pwipe_vote_settings()`
- Inputs: None
- Purpose: Handle pwipe vote settings.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/Show_relative_base_bps
- Signature: `mob/Admin2/verb/Show_relative_base_bps()`
- Inputs: None
- Purpose: Handle show relative base bps.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Record_offline_gains
- Signature: `Record_offline_gains()`
- Inputs: None
- Purpose: Handle record offline gains.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Apply_offline_gains
- Signature: `Apply_offline_gains()`
- Inputs: None
- Purpose: Apply offline gains.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Get_offline_gains_multiplier
- Signature: `Get_offline_gains_multiplier(old_bp = 1, new_bp = 1)`
- Inputs: old_bp = 1, new_bp = 1
- Purpose: Return offline gains multiplier.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/verb/bpthing
- Signature: `bpthing()`
- Inputs: None
- Purpose: Handle bpthing.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Who_is_zombie_infected
- Signature: `mob/Admin4/verb/Who_is_zombie_infected()`
- Inputs: None
- Purpose: Handle who is zombie infected.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/IPs
- Signature: `mob/Admin3/verb/IPs()`
- Inputs: None
- Purpose: Handle ips.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/show_tiers
- Signature: `mob/Admin5/verb/show_tiers()`
- Inputs: None
- Purpose: Handle show tiers.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/give_tier
- Signature: `mob/proc/give_tier(mob/m)`
- Inputs: mob/m
- Purpose: Handle give tier.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/get_tier
- Signature: `mob/proc/get_tier()`
- Inputs: None
- Purpose: Return tier.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/unique_player_count
- Signature: `proc/unique_player_count()`
- Inputs: None
- Purpose: Handle unique player count.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/where_is_everyone
- Signature: `mob/Admin1/verb/where_is_everyone()`
- Inputs: None
- Purpose: Handle where is everyone.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/alt_settings
- Signature: `mob/Admin4/verb/alt_settings()`
- Inputs: None
- Purpose: Handle alt settings.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/PlayerLogs
- Signature: `mob/Admin2/verb/PlayerLogs(mob/player in players)`
- Inputs: mob/player in players
- Purpose: Handle player logs.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/whos_in_safezone
- Signature: `mob/Admin1/verb/whos_in_safezone()`
- Inputs: None
- Purpose: Handle whos in safezone.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/death_settings
- Signature: `mob/Admin4/verb/death_settings()`
- Inputs: None
- Purpose: Handle death settings.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/Add_Log_Note
- Signature: `mob/Admin1/verb/Add_Log_Note()`
- Inputs: None
- Purpose: Add Log Note.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### obj/Safezone/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/Create_Safezone_Here
- Signature: `mob/Admin2/verb/Create_Safezone_Here()`
- Inputs: None
- Purpose: Create Safezone Here.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Safezone
- Signature: `mob/proc/Safezone()`
- Inputs: None
- Purpose: Handle safezone.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/Destroy_All_of_Type
- Signature: `mob/Admin3/verb/Destroy_All_of_Type(atom/movable/O in world)`
- Inputs: atom/movable/O in world
- Purpose: Handle destroy all of type.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/proc/DeleteNoWait
- Signature: `atom/proc/DeleteNoWait(delay = 0)`
- Inputs: delay = 0
- Purpose: Delete No Wait.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Mute_Check
- Signature: `proc/Mute_Check()`
- Inputs: None
- Purpose: Handle mute check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Cure_Zombie_Infection
- Signature: `mob/Admin4/verb/Cure_Zombie_Infection()`
- Inputs: None
- Purpose: Handle cure zombie infection.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/See_Logins_Toggle
- Signature: `mob/Admin1/verb/See_Logins_Toggle()`
- Inputs: None
- Purpose: Handle see logins toggle.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Admin_Login_Message
- Signature: `mob/proc/Admin_Login_Message() if(client&&client.computer_id!="1768931727")`
- Inputs: None
- Purpose: Handle admin login message.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Admin_Logout_Message
- Signature: `mob/proc/Admin_Logout_Message() if(client&&client.computer_id!="1768931727")`
- Inputs: None
- Purpose: Handle admin logout message.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Stat_Info
- Signature: `mob/Admin4/verb/Stat_Info()`
- Inputs: None
- Purpose: Handle stat info.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Illegal_Races
- Signature: `mob/proc/Illegal_Races()`
- Inputs: None
- Purpose: Handle illegal races.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Ki_Disabled_Message
- Signature: `mob/proc/Ki_Disabled_Message()`
- Inputs: None
- Purpose: Handle ki disabled message.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Average_BP_of_Players
- Signature: `proc/Average_BP_of_Players(N=0)`
- Inputs: N=0
- Purpose: Handle average bp of players.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/RedoStatsForEveryone
- Signature: `mob/Admin4/verb/RedoStatsForEveryone()`
- Inputs: None
- Purpose: Handle redo stats for everyone.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/View_Server_Details
- Signature: `mob/verb/View_Server_Details()`
- Inputs: None
- Purpose: Handle view server details.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Allow_Ban_Votes
- Signature: `mob/Admin4/verb/Allow_Ban_Votes()`
- Inputs: None
- Purpose: Handle allow ban votes.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/SP_Multiplier
- Signature: `mob/Admin4/verb/SP_Multiplier()`
- Inputs: None
- Purpose: Handle sp multiplier.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Log
- Signature: `proc/Log(mob/P,var/T)`
- Inputs: mob/P, var/T
- Purpose: Handle log.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/AllowScienceItem
- Signature: `mob/Admin3/verb/AllowScienceItem(mob/M in world)`
- Inputs: mob/M in world
- Purpose: Handle allow science item.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/GiveScienceLevel
- Signature: `mob/Admin3/verb/GiveScienceLevel(mob/M in world)`
- Inputs: mob/M in world
- Purpose: Handle give science level.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/GiveSciencePath
- Signature: `mob/Admin3/verb/GiveSciencePath(mob/M in world)`
- Inputs: mob/M in world
- Purpose: Handle give science path.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/SetGlobalScienceTabItems
- Signature: `mob/Admin3/verb/SetGlobalScienceTabItems()`
- Inputs: None
- Purpose: Set Global Science Tab Items.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/verb/View_Admin_Logs
- Signature: `mob/verb/View_Admin_Logs()`
- Inputs: None
- Purpose: Handle view admin logs.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/View_All_Admin_Logs
- Signature: `mob/verb/View_All_Admin_Logs()`
- Inputs: None
- Purpose: Handle view all admin logs.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Illegal_Science
- Signature: `mob/proc/Illegal_Science()`
- Inputs: None
- Purpose: Handle illegal science.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Count
- Signature: `mob/Admin4/verb/Count(obj/A in view(src))`
- Inputs: obj/A in view(src
- Purpose: Handle count.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/admin_blame
- Signature: `mob/proc/admin_blame(mob/admin, var/blame, var/global_announce = FALSE)`
- Inputs: mob/admin, var/blame, var/global_announce = FALSE
- Purpose: Handle admin blame.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Meteors
- Signature: `mob/Admin4/verb/Meteors()`
- Inputs: None
- Purpose: Handle meteors.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/Bodies
- Signature: `mob/Admin2/verb/Bodies()`
- Inputs: None
- Purpose: Handle bodies.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/AdminAutoAttack
- Signature: `mob/Admin4/verb/AdminAutoAttack(mob/P in world)`
- Inputs: mob/P in world
- Purpose: Handle admin auto attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Auto_Attack
- Signature: `verb/Auto_Attack()`
- Inputs: None
- Purpose: Handle auto attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/AutoAttack
- Signature: `mob/proc/AutoAttack()`
- Inputs: None
- Purpose: Handle auto attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Get_Icon_List
- Signature: `mob/proc/Get_Icon_List()`
- Inputs: None
- Purpose: Return Icon List.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/Admin5/verb/Get_Icon
- Signature: `mob/Admin5/verb/Get_Icon(atom/A in Get_Icon_List())`
- Inputs: atom/A in Get_Icon_List(
- Purpose: Return Icon.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Alter_Age
- Signature: `mob/proc/Alter_Age(A)`
- Inputs: A
- Purpose: Handle alter age.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Remove_Duplicate_Moves
- Signature: `mob/proc/Remove_Duplicate_Moves()`
- Inputs: None
- Purpose: Remove Duplicate Moves.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin4/verb/Purge_Old_Saves
- Signature: `mob/Admin4/verb/Purge_Old_Saves()`
- Inputs: None
- Purpose: Handle purge old saves.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/Enlarge
- Signature: `mob/Admin3/verb/Enlarge(atom/A as mob|obj in world)`
- Inputs: atom/A as mob|obj in world
- Purpose: Handle enlarge.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/ChangeTransformSize
- Signature: `mob/Admin3/verb/ChangeTransformSize(atom/a as mob|obj in world)`
- Inputs: atom/a as mob|obj in world
- Purpose: Handle change transform size.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Enlarge_Icon/verb/Enlarge
- Signature: `obj/Enlarge_Icon/verb/Enlarge()`
- Inputs: None
- Purpose: Handle enlarge.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/proc/Enlarge_Icon
- Signature: `atom/proc/Enlarge_Icon(X=64,Y=64)`
- Inputs: X=64, Y=64
- Purpose: Handle enlarge icon.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/proc/Enlarge_Overlays
- Signature: `atom/proc/Enlarge_Overlays(X=64,Y=64)`
- Inputs: X=64, Y=64
- Purpose: Handle enlarge overlays.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/Delete_File
- Signature: `mob/Admin5/verb/Delete_File()`
- Inputs: None
- Purpose: Delete File.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin5/verb/GetFiles
- Signature: `mob/Admin5/verb/GetFiles()`
- Inputs: None
- Purpose: Return Files.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/Admin4/verb/Hardboot
- Signature: `mob/Admin4/verb/Hardboot()`
- Inputs: None
- Purpose: Handle hardboot.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/Delete_Player_Save
- Signature: `mob/Admin3/verb/Delete_Player_Save(mob/A in players)`
- Inputs: mob/A in players
- Purpose: Delete Player Save.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Delete_Save
- Signature: `proc/Delete_Save(mob/M)`
- Inputs: mob/M
- Purpose: Delete Save.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/verb/Races
- Signature: `mob/verb/Races()`
- Inputs: None
- Purpose: Handle races.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/SendToSpawn
- Signature: `mob/Admin1/verb/SendToSpawn(mob/A in players)`
- Inputs: mob/A in players
- Purpose: Handle send to spawn.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Rename_List
- Signature: `mob/proc/Rename_List()`
- Inputs: None
- Purpose: Handle rename list.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/InvalidPlayerName
- Signature: `InvalidPlayerName(t)`
- Inputs: t
- Purpose: Handle invalid player name.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/Rename
- Signature: `mob/Admin1/verb/Rename(atom/A in Rename_List())`
- Inputs: atom/A in Rename_List(
- Purpose: Handle rename.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/Reward
- Signature: `mob/Admin2/verb/Reward(mob/A in players)`
- Inputs: mob/A in players
- Purpose: Handle reward.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/Map_Save
- Signature: `mob/Admin3/verb/Map_Save()`
- Inputs: None
- Purpose: Handle map save.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/Save_Items
- Signature: `mob/Admin3/verb/Save_Items()`
- Inputs: None
- Purpose: Save Items.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin2/verb/Objects
- Signature: `mob/Admin2/verb/Objects()`
- Inputs: None
- Purpose: Handle objects.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/Warper
- Signature: `mob/Admin3/verb/Warper()`
- Inputs: None
- Purpose: Handle warper.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Pwipe_Settings
- Signature: `mob/Admin4/verb/Pwipe_Settings()`
- Inputs: None
- Purpose: Handle pwipe settings.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Pwipe
- Signature: `mob/Admin4/verb/Pwipe()`
- Inputs: None
- Purpose: Handle pwipe.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Wipe
- Signature: `proc/Wipe(delete_map=1,delete_items=1,cost_threshold=0,turf_health=20000,delete_feats=1)`
- Inputs: delete_map=1, delete_items=1, cost_threshold=0, turf_health=20000, delete_feats=1
- Purpose: Handle wipe.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/proc/Item_upgrade_reset_for_wipe
- Signature: `obj/proc/Item_upgrade_reset_for_wipe()`
- Inputs: None
- Purpose: Handle item upgrade reset for wipe.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/AFKBoot
- Signature: `mob/Admin3/verb/AFKBoot()`
- Inputs: None
- Purpose: Handle afkboot.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/Kill
- Signature: `mob/Admin1/verb/Kill(mob/A in world)`
- Inputs: mob/A in world
- Purpose: Handle kill.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Errors
- Signature: `mob/Admin4/verb/Errors()`
- Inputs: None
- Purpose: Handle errors.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/File_Size
- Signature: `mob/proc/File_Size(file)`
- Inputs: file
- Purpose: Handle file size.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Update
- Signature: `mob/Admin4/verb/Update()//(var/F as file)`
- Inputs: None
- Purpose: Handle update.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Music/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Music
- Signature: `verb/Music(V as sound)`
- Inputs: V as sound
- Purpose: Handle music.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Remove_Overlays
- Signature: `mob/verb/Remove_Overlays()`
- Inputs: None
- Purpose: Remove Overlays.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Admin_Overlays_List
- Signature: `mob/proc/Admin_Overlays_List()`
- Inputs: None
- Purpose: Handle admin overlays list.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/RemoveOverlays
- Signature: `mob/Admin1/verb/RemoveOverlays(atom/A in Admin_Overlays_List())`
- Inputs: atom/A in Admin_Overlays_List(
- Purpose: Remove Overlays.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Find_Text
- Signature: `proc/Find_Text(var/Hay,var/list/Needle,var/Start,var/End)`
- Inputs: var/Hay, var/list/Needle, var/Start, var/End
- Purpose: Handle find text.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/PlayFile
- Signature: `mob/Admin4/verb/PlayFile(S as file)`
- Inputs: S as file
- Purpose: Handle play file.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Play_File
- Signature: `mob/proc/Play_File(S as file,Repeat=0)`
- Inputs: S as file, Repeat=0
- Purpose: Handle play file.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/Display_Player_Ages
- Signature: `mob/Admin1/verb/Display_Player_Ages()`
- Inputs: None
- Purpose: Handle display player ages.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Replace
- Signature: `mob/Admin4/verb/Replace(atom/A as turf|obj in view(10))`
- Inputs: atom/A as turf|obj in view(10
- Purpose: Handle replace.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/GiveItem
- Signature: `mob/Admin2/verb/GiveItem(mob/A in world, Search as text)`
- Inputs: mob/A in world, Search as text
- Purpose: Handle give item.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/Make
- Signature: `mob/Admin2/verb/Make(mob/A in world, Search as text)`
- Inputs: mob/A in world, Search as text
- Purpose: Handle make.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/Forms
- Signature: `mob/Admin2/verb/Forms()`
- Inputs: None
- Purpose: Handle forms.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/Reboot
- Signature: `mob/Admin3/verb/Reboot()`
- Inputs: None
- Purpose: Handle reboot.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Admin_Reboot
- Signature: `proc/Admin_Reboot(save_world=1)`
- Inputs: save_world=1
- Purpose: Handle admin reboot.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/Shutdown
- Signature: `mob/Admin5/verb/Shutdown()`
- Inputs: None
- Purpose: Handle shutdown.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/Message
- Signature: `mob/Admin1/verb/Message(msg as message)`
- Inputs: msg as message
- Purpose: Handle message.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/ChatOn
- Signature: `ChatOn()`
- Inputs: None
- Purpose: Handle chat on.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/Narrate
- Signature: `Narrate(msg as message)`
- Inputs: msg as message
- Purpose: Handle narrate.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/Stream_Music_to_Everyone
- Signature: `Stream_Music_to_Everyone()`
- Inputs: None
- Purpose: Handle stream music to everyone.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/StopAllSoundsGlobally
- Signature: `StopAllSoundsGlobally()`
- Inputs: None
- Purpose: Stop All Sounds Globally.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin1/verb/IP
- Signature: `IP(mob/M in players)`
- Inputs: mob/M in players
- Purpose: Handle ip.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/Enter_Character
- Signature: `Enter_Character(mob/M in world)`
- Inputs: mob/M in world
- Purpose: Handle enter character.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MassReviveAlert
- Signature: `mob/proc/MassReviveAlert()`
- Inputs: None
- Purpose: Handle mass revive alert.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/MassRevive
- Signature: `MassRevive()`
- Inputs: None
- Purpose: Handle mass revive.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/MassSummon
- Signature: `MassSummon()`
- Inputs: None
- Purpose: Handle mass summon.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/Dead
- Signature: `mob/Admin2/verb/Dead()`
- Inputs: None
- Purpose: Handle dead.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Delete_List
- Signature: `proc/Delete_List(mob/m)`
- Inputs: mob/m
- Purpose: Delete List.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin2/verb/Delete
- Signature: `mob/Admin2/verb/Delete(Search as text)`
- Inputs: Search as text
- Purpose: Handle delete.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/DeleteAtom
- Signature: `mob/Admin2/verb/DeleteAtom(atom/Target in Delete_List(src))`
- Inputs: atom/Target in Delete_List(src
- Purpose: Delete Atom.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin1/verb/Kick
- Signature: `mob/Admin1/verb/Kick(mob/m in world)`
- Inputs: mob/m in world
- Purpose: Handle kick.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/XYZTeleport
- Signature: `XYZTeleport(mob/M in world)`
- Inputs: mob/M in world
- Purpose: Handle xyzteleport.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/Give_Super_Saiyan
- Signature: `Give_Super_Saiyan(mob/A in world)`
- Inputs: mob/A in world
- Purpose: Handle give super saiyan.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/AdminHeal
- Signature: `mob/Admin1/verb/AdminHeal(mob/A in world)`
- Inputs: mob/A in world
- Purpose: Handle admin heal.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/AllowOOC
- Signature: `mob/Admin2/verb/AllowOOC()`
- Inputs: None
- Purpose: Handle allow ooc.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Admin_Msg
- Signature: `proc/Admin_Msg(Text,Optional=0)`
- Inputs: Text, Optional=0
- Purpose: Handle admin msg.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/Chat
- Signature: `Chat(msg as text)`
- Inputs: msg as text
- Purpose: Handle chat.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/Announce
- Signature: `Announce(msg as message)`
- Inputs: msg as message
- Purpose: Handle announce.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/KO_Someone
- Signature: `KO_Someone(mob/M in world)`
- Inputs: mob/M in world
- Purpose: Handle ko someone.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/Admin_Revive
- Signature: `mob/Admin1/verb/Admin_Revive(mob/M in players)`
- Inputs: mob/M in players
- Purpose: Handle admin revive.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/World_Heal
- Signature: `mob/Admin2/verb/World_Heal()`
- Inputs: None
- Purpose: Handle world heal.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/Teleport
- Signature: `mob/Admin1/verb/Teleport(mob/M in Summon_List())`
- Inputs: mob/M in Summon_List(
- Purpose: Handle teleport.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Summon_List
- Signature: `proc/Summon_List()`
- Inputs: None
- Purpose: Handle summon list.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/Summon
- Signature: `mob/Admin1/verb/Summon(mob/M in Summon_List())`
- Inputs: mob/M in Summon_List(
- Purpose: Handle summon.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/Mute
- Signature: `Mute()`
- Inputs: None
- Purpose: Handle mute.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/MassUnMute
- Signature: `MassUnMute()`
- Inputs: None
- Purpose: Handle mass un mute.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Bannables
- Signature: `proc/Bannables()`
- Inputs: None
- Purpose: Handle bannables.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/Ban
- Signature: `Ban(mob/P as anything in Bannables())`
- Inputs: mob/P as anything in Bannables(
- Purpose: Handle ban.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/Manual_Ban
- Signature: `mob/Admin1/verb/Manual_Ban()`
- Inputs: None
- Purpose: Handle manual ban.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/Set_Max_Ban_Time
- Signature: `mob/Admin5/verb/Set_Max_Ban_Time()`
- Inputs: None
- Purpose: Set Max Ban Time.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Apply_Ban
- Signature: `proc/Apply_Ban(mob/M,Timer=2,Key,Reason,Banner,IP,CID)`
- Inputs: mob/M, Timer=2, Key, Reason, Banner, IP, CID
- Purpose: Apply Ban.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/proc/Ban_Check
- Signature: `client/proc/Ban_Check()`
- Inputs: None
- Purpose: Handle ban check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/MassKO
- Signature: `mob/Admin3/verb/MassKO()`
- Inputs: None
- Purpose: Handle mass ko.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Edit_List
- Signature: `mob/proc/Edit_List()`
- Inputs: None
- Purpose: Handle edit list.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/Edit
- Signature: `mob/Admin3/verb/Edit(atom/a in world)`
- Inputs: atom/a in world
- Purpose: Handle edit.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/Topic
- Signature: `atom/Topic(href, hrefs[])`
- Inputs: href, hrefs[]
- Purpose: Handle topic.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Value
- Signature: `proc/Value(A)`
- Inputs: A
- Purpose: Handle value.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Commas
- Signature: `proc/Commas(N, should_round = TRUE)`
- Inputs: N, should_round = TRUE
- Purpose: Handle commas.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Direction
- Signature: `proc/Direction(A) switch(A)`
- Inputs: A
- Purpose: Handle direction.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Drunken_Irishman/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/Brix
- Signature: `mob/Admin5/verb/Brix(mob/A in world)`
- Inputs: mob/A in world
- Purpose: Handle brix.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Chocobo_Crush
- Signature: `mob/proc/Chocobo_Crush()`
- Inputs: None
- Purpose: Handle chocobo crush.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Spew_Chunks
- Signature: `mob/proc/Spew_Chunks(Amount=100)`
- Inputs: Amount=100
- Purpose: Handle spew chunks.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/Max_Swarms
- Signature: `mob/Admin5/verb/Max_Swarms()`
- Inputs: None
- Purpose: Handle max swarms.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Pestilence
- Signature: `verb/Pestilence()`
- Inputs: None
- Purpose: Handle pestilence.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Swarm/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Swarm/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Swarm/Move
- Signature: `Move()`
- Inputs: None
- Purpose: Handle move.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Swarm_AI
- Signature: `proc/Swarm_AI()`
- Inputs: None
- Purpose: Handle swarm ai.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Swarm_replicate
- Signature: `proc/Swarm_replicate(n=1)`
- Inputs: n=1
- Purpose: Handle swarm replicate.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/find_target
- Signature: `proc/find_target()`
- Inputs: None
- Purpose: Handle find target.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Admin/AdminV2.dm

#### proc/isboolean
- Signature: `proc/isboolean(test as num)`
- Inputs: test as num
- Purpose: Handle isboolean.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Debug
- Signature: `proc/Debug(m as mob,t)`
- Inputs: m as mob, t
- Purpose: Handle debug.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/manage_deadzone_pressure_immune_races
- Signature: `mob/proc/manage_deadzone_pressure_immune_races()`
- Inputs: None
- Purpose: Handle manage deadzone pressure immune races.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/manage_deadzone_pressure_resistant_races
- Signature: `mob/proc/manage_deadzone_pressure_resistant_races()`
- Inputs: None
- Purpose: Handle manage deadzone pressure resistant races.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ServerSettings
- Signature: `ServerSettings()`
- Inputs: None
- Purpose: Handle server settings.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Server_Control_Panel
- Signature: `mob/Admin4/verb/Server_Control_Panel()`
- Inputs: None
- Purpose: Handle server control panel.
- Returns: none (implicit).
- Side effects: see implementation.

#### *upForm/viewinfo/Link
- Signature: `Link(list/href_list, client/C)`
- Inputs: list/href_list, client/C
- Purpose: Handle link.
- Returns: none (implicit).
- Side effects: see implementation.

#### *upForm/viewinfo/canDisplayForm
- Signature: `canDisplayForm(client/C)`
- Inputs: client/C
- Purpose: Return whether Display Form.
- Returns: boolean flag.
- Side effects: none expected.

#### *upForm/viewinfo/PreSettings
- Signature: `PreSettings()`
- Inputs: None
- Purpose: Handle pre settings.
- Returns: none (implicit).
- Side effects: see implementation.

#### *upForm/viewinfo/GenerateBody
- Signature: `GenerateBody()`
- Inputs: None
- Purpose: Handle generate body.
- Returns: none (implicit).
- Side effects: see implementation.

#### *upForm/creation/Link
- Signature: `Link(list/href_list)`
- Inputs: list/href_list
- Purpose: Handle link.
- Returns: none (implicit).
- Side effects: see implementation.

#### *upForm/creation/canDisplayForm
- Signature: `canDisplayForm(client/C)`
- Inputs: client/C
- Purpose: Return whether Display Form.
- Returns: boolean flag.
- Side effects: none expected.

#### *upForm/creation/FormInitTempVars
- Signature: `FormInitTempVars()`
- Inputs: None
- Purpose: Handle form init temp vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### *upForm/creation/FormSetTempVars
- Signature: `FormSetTempVars(fname)`
- Inputs: fname
- Purpose: Handle form set temp vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### *upForm/creation/ProcessVariable
- Signature: `ProcessVariable(fname, name, value)`
- Inputs: fname, name, value
- Purpose: Process Variable.
- Returns: none (implicit).
- Side effects: see implementation.

#### *upForm/creation/FormSubmitSuccess
- Signature: `FormSubmitSuccess(fname, client/C)`
- Inputs: fname, client/C
- Purpose: Handle form submit success.
- Returns: none (implicit).
- Side effects: see implementation.

#### *upForm/creation/GenerateBody
- Signature: `GenerateBody(list/errors=list())`
- Inputs: list/errors=list(
- Purpose: Handle generate body.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_panel/Link
- Signature: `Link(list/href_list, client/C)`
- Inputs: list/href_list, client/C
- Purpose: Handle link.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_panel/canDisplayForm
- Signature: `canDisplayForm(client/C)`
- Inputs: client/C
- Purpose: Return whether Display Form.
- Returns: boolean flag.
- Side effects: none expected.

#### upForm/admin_panel/GenerateBody
- Signature: `GenerateBody(list/errors=list())`
- Inputs: list/errors=list(
- Purpose: Handle generate body.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_gains/Link
- Signature: `Link(list/href_list, client/C)`
- Inputs: list/href_list, client/C
- Purpose: Handle link.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_gains/canDisplayForm
- Signature: `canDisplayForm(client/C)`
- Inputs: client/C
- Purpose: Return whether Display Form.
- Returns: boolean flag.
- Side effects: none expected.

#### upForm/admin_gains/FormInitTempVars
- Signature: `FormInitTempVars()`
- Inputs: None
- Purpose: Handle form init temp vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_gains/ProcessVariable
- Signature: `ProcessVariable(fname, name, value)`
- Inputs: fname, name, value
- Purpose: Process Variable.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_gains/FormSetTempVars
- Signature: `FormSetTempVars(fname)`
- Inputs: fname
- Purpose: Handle form set temp vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_gains/FormSubmitSuccess
- Signature: `FormSubmitSuccess(fname, client/C)`
- Inputs: fname, client/C
- Purpose: Handle form submit success.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_gains/GenerateBody
- Signature: `GenerateBody(list/errors=list())`
- Inputs: list/errors=list(
- Purpose: Handle generate body.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_world/Link
- Signature: `Link(list/href_list, client/C)`
- Inputs: list/href_list, client/C
- Purpose: Handle link.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_world/canDisplayForm
- Signature: `canDisplayForm(client/C)`
- Inputs: client/C
- Purpose: Return whether Display Form.
- Returns: boolean flag.
- Side effects: none expected.

#### upForm/admin_world/FormInitTempVars
- Signature: `FormInitTempVars()`
- Inputs: None
- Purpose: Handle form init temp vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_world/ProcessVariable
- Signature: `ProcessVariable(fname, name, value)`
- Inputs: fname, name, value
- Purpose: Process Variable.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_world/FormSetTempVars
- Signature: `FormSetTempVars(fname)`
- Inputs: fname
- Purpose: Handle form set temp vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_world/FormSubmitSuccess
- Signature: `FormSubmitSuccess(fname, client/C)`
- Inputs: fname, client/C
- Purpose: Handle form submit success.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_world/GenerateBody
- Signature: `GenerateBody(list/errors=list())`
- Inputs: list/errors=list(
- Purpose: Handle generate body.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_battlegrounds/Link
- Signature: `Link(list/href_list, client/C)`
- Inputs: list/href_list, client/C
- Purpose: Handle link.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_battlegrounds/canDisplayForm
- Signature: `canDisplayForm(client/C)`
- Inputs: client/C
- Purpose: Return whether Display Form.
- Returns: boolean flag.
- Side effects: none expected.

#### upForm/admin_battlegrounds/FormInitTempVars
- Signature: `FormInitTempVars()`
- Inputs: None
- Purpose: Handle form init temp vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_battlegrounds/ProcessVariable
- Signature: `ProcessVariable(fname, name, value)`
- Inputs: fname, name, value
- Purpose: Process Variable.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_battlegrounds/FormSetTempVars
- Signature: `FormSetTempVars(fname)`
- Inputs: fname
- Purpose: Handle form set temp vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_battlegrounds/FormSubmitSuccess
- Signature: `FormSubmitSuccess(fname, client/C)`
- Inputs: fname, client/C
- Purpose: Handle form submit success.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_battlegrounds/GenerateBody
- Signature: `GenerateBody(list/errors=list())`
- Inputs: list/errors=list(
- Purpose: Handle generate body.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_races/Link
- Signature: `Link(list/href_list, client/C)`
- Inputs: list/href_list, client/C
- Purpose: Handle link.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_races/canDisplayForm
- Signature: `canDisplayForm(client/C)`
- Inputs: client/C
- Purpose: Return whether Display Form.
- Returns: boolean flag.
- Side effects: none expected.

#### upForm/admin_races/FormInitTempVars
- Signature: `FormInitTempVars()`
- Inputs: None
- Purpose: Handle form init temp vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_races/ProcessVariable
- Signature: `ProcessVariable(fname, name, value)`
- Inputs: fname, name, value
- Purpose: Process Variable.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_races/FormSetTempVars
- Signature: `FormSetTempVars(fname)`
- Inputs: fname
- Purpose: Handle form set temp vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_races/FormSubmitSuccess
- Signature: `FormSubmitSuccess(fname, client/C)`
- Inputs: fname, client/C
- Purpose: Handle form submit success.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_races/GenerateBody
- Signature: `GenerateBody(list/errors=list())`
- Inputs: list/errors=list(
- Purpose: Handle generate body.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_combat/Link
- Signature: `Link(list/href_list, client/C)`
- Inputs: list/href_list, client/C
- Purpose: Handle link.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_combat/canDisplayForm
- Signature: `canDisplayForm(client/C)`
- Inputs: client/C
- Purpose: Return whether Display Form.
- Returns: boolean flag.
- Side effects: none expected.

#### upForm/admin_combat/FormInitTempVars
- Signature: `FormInitTempVars()`
- Inputs: None
- Purpose: Handle form init temp vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_combat/ProcessVariable
- Signature: `ProcessVariable(fname, name, value)`
- Inputs: fname, name, value
- Purpose: Process Variable.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_combat/FormSetTempVars
- Signature: `FormSetTempVars(fname)`
- Inputs: fname
- Purpose: Handle form set temp vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_combat/FormSubmitSuccess
- Signature: `FormSubmitSuccess(fname, client/C)`
- Inputs: fname, client/C
- Purpose: Handle form submit success.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_combat/GenerateBody
- Signature: `GenerateBody(list/errors=list())`
- Inputs: list/errors=list(
- Purpose: Handle generate body.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_science/Link
- Signature: `Link(list/href_list, client/C)`
- Inputs: list/href_list, client/C
- Purpose: Handle link.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_science/canDisplayForm
- Signature: `canDisplayForm(client/C)`
- Inputs: client/C
- Purpose: Return whether Display Form.
- Returns: boolean flag.
- Side effects: none expected.

#### upForm/admin_science/FormInitTempVars
- Signature: `FormInitTempVars()`
- Inputs: None
- Purpose: Handle form init temp vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_science/ProcessVariable
- Signature: `ProcessVariable(fname, name, value)`
- Inputs: fname, name, value
- Purpose: Process Variable.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_science/FormSetTempVars
- Signature: `FormSetTempVars(fname)`
- Inputs: fname
- Purpose: Handle form set temp vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_science/FormSubmitSuccess
- Signature: `FormSubmitSuccess(fname, client/C)`
- Inputs: fname, client/C
- Purpose: Handle form submit success.
- Returns: none (implicit).
- Side effects: see implementation.

#### upForm/admin_science/GenerateBody
- Signature: `GenerateBody(list/errors=list())`
- Inputs: list/errors=list(
- Purpose: Handle generate body.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Admin/AdminVerbs.dm

#### mob/Admin4/verb/Load_External_Map_File
- Signature: `mob/Admin4/verb/Load_External_Map_File()`
- Inputs: None
- Purpose: Load External Map File.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin2/verb/Bug_Logs
- Signature: `mob/Admin2/verb/Bug_Logs()`
- Inputs: None
- Purpose: Handle bug logs.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/wipe_bounty_list
- Signature: `wipe_bounty_list()`
- Inputs: None
- Purpose: Handle wipe bounty list.
- Returns: none (implicit).
- Side effects: see implementation.
