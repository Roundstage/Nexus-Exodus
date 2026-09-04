# Admin

## Overview
Administrative commands and management flows. Administrators receive a searchable full control panel and a compact player-focused quick panel. `Manage Player` appears on a clicked player's context menu and opens that quick panel with the player already selected. The normal command/right-click surface is otherwise limited to both panel launchers plus Teleport, Summon, AdminHeal, Admin Revive, and Admin Inspector; any other legacy verb can be exposed individually through the searchable legacy palette. The structured inspector remains the complete variable, collection, and mutation editor.

## Files
- `src/Code/Admin/Admin.dm`
- `src/Code/Admin/AdminV2.dm`
- `src/Code/Admin/AdminVerbs.dm`
- `src/Code/Admin/AdminPanel.dm`
- `src/Code/Admin/ServerPanel.dm`
- `src/Code/Admin/CombatTesting.dm`
- `src/Code/Admin/EffectDiagnostics.dm`
- `src/Code/Admin/TensDiagnostics.dm`

## Proc Reference

### src/Code/Admin/AdminVerbs.dm

- `giveMutation(character)` grants or updates one mutation at 1% through 30% for a playable character.
- `rollMutations(character)` replaces the target's live mutation modifiers using either the natural rarity roll or a forced rarity.

### src/Code/Admin/AdminPanel.dm

- `initializeNexusAdminActions()` registers permission-aware commands by Player, Movement, Character, Items, Smithing, Development, Logs, Testing, Server, and Legacy categories.
- `showNexusAdminPanel(compact, selected_target)` opens the full or quick searchable panel with the blue native-HUD components used by Server Control and keeps one selected player as the target for successive actions. Commands remain text-first rather than receiving unrelated generated category artwork.
- `toggleNexusAdminPanel(compact)` closes the active admin panel when its top shortcut is pressed again, or opens it when absent.
- `openItemPicker(mode, search)` searches item type paths without instantiating hundreds of reference objects; both browsing and item creation revalidate admin level 2, accept only the exact `give` or `make` mode, and reject protected non-givable results.
- `openRewardMenu()` and `applyReward(reward_type)` replace the legacy Reward flow with audited BP, BP Mod, Energy, Resources, Skill Points, Milestone Points, Technology XP, Mining XP, and Smithing XP controls.
- `runLegacyCommand()` searches all verbs available to the administrator's level without removing them from CMD or their original Admin tab categories.
- `Admin Panel`, `Quick Admin`, `Manage Player`, and `Admin Inspector` are the permanent administration launchers.

### src/Code/Admin/ServerPanel.dm

- `showNexusServerPanel()` opens the level-4 Server Control Panel in a large, resizable browser window.
- `datum/NexusServerPanel/render()` provides six category tabs, a persistent text search input, pagination, and direct editing for every setting bound by the existing administration models. Each clickable row renders the variable name and current value in separate labeled columns so the edited setting is always identifiable. Combat settings include `speedDelayMultMod`, the global movement-speed delay multiplier; larger values make movement and speed-based combat actions slower.
- `createSettingsModel()` uses a headless upForm model only for its complete setting bindings and validation; no legacy browser window is created.
- Number and text settings retain their legacy conversion and validation. List settings use dedicated add/remove controls, and every mutation is written to the admin audit log.

### src/Code/Admin/Admin.dm

#### mob/Admin4/verb/toggleAdminInfKnowledgeForSelf
- Signature: `mob/Admin4/verb/toggleAdminInfKnowledgeForSelf()`
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

#### mob/Admin5/verb/showShips
- Signature: `mob/Admin5/verb/showShips()`
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

#### mob/Admin4/verb/setDodgingAndDeflectingMode
- Signature: `mob/Admin4/verb/setDodgingAndDeflectingMode()`
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

#### mob/Admin4/verb/setVoidRules
- Signature: `mob/Admin4/verb/setVoidRules()`
- Inputs: None
- Purpose: Set Void Rules.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin3/verb/fixResourceBug
- Signature: `mob/Admin3/verb/fixResourceBug()`
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

#### mob/Admin3/verb/destroyBuiltObjsOfThisPerson
- Signature: `mob/Admin3/verb/destroyBuiltObjsOfThisPerson(obj/t in world)`
- Inputs: obj/t in world
- Purpose: Handle destroy built objs of this person.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/destroyTurfsOfThisPerson
- Signature: `mob/Admin3/verb/destroyTurfsOfThisPerson(turf/t in world)`
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

#### mob/Admin3/verb/createBpEqualizerHere
- Signature: `mob/Admin3/verb/createBpEqualizerHere()`
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

#### mob/Admin4/verb/convertWallsToNewOwner
- Signature: `mob/Admin4/verb/convertWallsToNewOwner(turf/t in world)`
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

#### mob/Admin4/verb/invisBrowser
- Signature: `mob/Admin4/verb/invisBrowser()`
- Inputs: None
- Purpose: Handle invis browser.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/overrideAllSpawns
- Signature: `mob/Admin4/verb/overrideAllSpawns()`
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

#### mob/Admin5/verb/commonTypesTest
- Signature: `mob/Admin5/verb/commonTypesTest()`
- Inputs: None
- Purpose: Handle common types test.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/makeDragonBallsActiveNow
- Signature: `mob/Admin4/verb/makeDragonBallsActiveNow()`
- Inputs: None
- Purpose: Handle make dragon balls active now.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/setDragonBallWishCooldown
- Signature: `mob/Admin3/verb/setDragonBallWishCooldown()`
- Inputs: None
- Purpose: Set Dragon Ball Wish Cooldown.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin4/verb/zombieInfo
- Signature: `mob/Admin4/verb/zombieInfo()`
- Inputs: None
- Purpose: Handle zombie info.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/zombieLocs
- Signature: `mob/Admin4/verb/zombieLocs()`
- Inputs: None
- Purpose: Handle zombie locs.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/pwipeVoteSettings
- Signature: `mob/Admin4/verb/pwipeVoteSettings()`
- Inputs: None
- Purpose: Handle pwipe vote settings.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/showRelativeBaseBps
- Signature: `mob/Admin2/verb/showRelativeBaseBps()`
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

#### mob/Admin4/verb/whoIsZombieInfected
- Signature: `mob/Admin4/verb/whoIsZombieInfected()`
- Inputs: None
- Purpose: Handle who is zombie infected.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/ips
- Signature: `mob/Admin3/verb/ips()`
- Inputs: None
- Purpose: Handle ips.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/showTiers
- Signature: `mob/Admin5/verb/showTiers()`
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

#### mob/Admin1/verb/whereIsEveryone
- Signature: `mob/Admin1/verb/whereIsEveryone()`
- Inputs: None
- Purpose: Handle where is everyone.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/altSettings
- Signature: `mob/Admin4/verb/altSettings()`
- Inputs: None
- Purpose: Handle alt settings.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/playerLogs
- Signature: `mob/Admin2/verb/playerLogs(mob/player in players)`
- Inputs: mob/player in players
- Purpose: Handle player logs.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/whosInSafezone
- Signature: `mob/Admin1/verb/whosInSafezone()`
- Inputs: None
- Purpose: Handle whos in safezone.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/deathSettings
- Signature: `mob/Admin4/verb/deathSettings()`
- Inputs: None
- Purpose: Handle death settings.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/addLogNote
- Signature: `mob/Admin1/verb/addLogNote()`
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

#### mob/Admin2/verb/createSafezoneHere
- Signature: `mob/Admin2/verb/createSafezoneHere()`
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

#### mob/Admin3/verb/destroyAllOfType
- Signature: `mob/Admin3/verb/destroyAllOfType(atom/movable/O in world)`
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

#### mob/Admin4/verb/cureZombieInfection
- Signature: `mob/Admin4/verb/cureZombieInfection()`
- Inputs: None
- Purpose: Handle cure zombie infection.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/seeLoginsToggle
- Signature: `mob/Admin1/verb/seeLoginsToggle()`
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

#### mob/Admin4/verb/statInfo
- Signature: `mob/Admin4/verb/statInfo()`
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

#### mob/Admin4/verb/redoStatsForEveryone
- Signature: `mob/Admin4/verb/redoStatsForEveryone()`
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

#### mob/Admin4/verb/allowBanVotes
- Signature: `mob/Admin4/verb/allowBanVotes()`
- Inputs: None
- Purpose: Handle allow ban votes.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/spMultiplier
- Signature: `mob/Admin4/verb/spMultiplier()`
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

#### mob/Admin3/verb/allowScienceItem
- Signature: `mob/Admin3/verb/allowScienceItem(mob/M in world)`
- Inputs: mob/M in world
- Purpose: Handle allow science item.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/giveScienceLevel
- Signature: `mob/Admin3/verb/giveScienceLevel(mob/M in world)`
- Inputs: mob/M in world
- Purpose: Handle give science level.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/giveSciencePath
- Signature: `mob/Admin3/verb/giveSciencePath(mob/M in world)`
- Inputs: mob/M in world
- Purpose: Handle give science path.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/setGlobalScienceTabItems
- Signature: `mob/Admin3/verb/setGlobalScienceTabItems()`
- Inputs: None
- Purpose: Set Global Science Tab Items.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Illegal_Science
- Signature: `mob/proc/Illegal_Science()`
- Inputs: None
- Purpose: Handle illegal science.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/count
- Signature: `mob/Admin4/verb/count(obj/A in view(src))`
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

#### mob/Admin4/verb/meteors
- Signature: `mob/Admin4/verb/meteors()`
- Inputs: None
- Purpose: Handle meteors.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/bodies
- Signature: `mob/Admin2/verb/bodies()`
- Inputs: None
- Purpose: Handle bodies.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/adminAutoAttack
- Signature: `mob/Admin4/verb/adminAutoAttack(mob/P in world)`
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
- Purpose: Repeatedly melee only the explicitly selected target while it remains in range.
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

#### mob/Admin5/verb/getIcon
- Signature: `mob/Admin5/verb/getIcon(atom/A in Get_Icon_List())`
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

#### mob/Admin4/verb/purgeOldSaves
- Signature: `mob/Admin4/verb/purgeOldSaves()`
- Inputs: None
- Purpose: Purge character saves inactive for two days while preserving character-slot migration markers.
- Returns: none (implicit).
- Side effects: deletes each expired character file and its matching per-slot feat file.

#### mob/Admin3/verb/enlarge
- Signature: `mob/Admin3/verb/enlarge(atom/A as mob|obj in world)`
- Inputs: atom/A as mob|obj in world
- Purpose: Handle enlarge.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/changeTransformSize
- Signature: `mob/Admin3/verb/changeTransformSize(atom/a as mob|obj in world)`
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

#### mob/Admin5/verb/deleteFile
- Signature: `mob/Admin5/verb/deleteFile()`
- Inputs: None
- Purpose: Delete File.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin5/verb/getFiles
- Signature: `mob/Admin5/verb/getFiles()`
- Inputs: None
- Purpose: Return Files.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/Admin4/verb/hardboot
- Signature: `mob/Admin4/verb/hardboot()`
- Inputs: None
- Purpose: Handle hardboot.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/deletePlayerSave
- Signature: `mob/Admin3/verb/deletePlayerSave(mob/A in players)`
- Inputs: mob/A in players
- Purpose: Delete Player Save.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Delete_Save
- Signature: `proc/Delete_Save(mob/M)`
- Inputs: mob/M
- Purpose: Delete the target's active character slot.
- Returns: none (implicit).
- Side effects: deletes the live mob, selected character file, and matching feat file.

#### mob/verb/Races
- Signature: `mob/verb/Races()`
- Inputs: None
- Purpose: Handle races.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/sendToSpawn
- Signature: `mob/Admin1/verb/sendToSpawn(mob/A in players)`
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

#### mob/Admin1/verb/rename
- Signature: `mob/Admin1/verb/rename(atom/A in Rename_List())`
- Inputs: atom/A in Rename_List(
- Purpose: Handle rename.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/reward
- Signature: `mob/Admin2/verb/reward(mob/A in players)`
- Inputs: mob/A in players
- Purpose: Handle reward.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/mapSaveCommand
- Signature: `mob/Admin3/verb/mapSaveCommand()`
- Inputs: None
- Purpose: Handle map save.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/saveItemsCommand
- Signature: `mob/Admin3/verb/saveItemsCommand()`
- Inputs: None
- Purpose: Save Items.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin2/verb/objects
- Signature: `mob/Admin2/verb/objects()`
- Inputs: None
- Purpose: Handle objects.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/warper
- Signature: `mob/Admin3/verb/warper()`
- Inputs: None
- Purpose: Handle warper.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/pwipeSettings
- Signature: `mob/Admin4/verb/pwipeSettings()`
- Inputs: None
- Purpose: Handle pwipe settings.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/pwipe
- Signature: `mob/Admin4/verb/pwipe()`
- Inputs: confirmed administrator action and the persisted pwipe settings.
- Purpose: Delete player persistence from the active live or isolated playtest namespace, then schedule a server reboot.
- Returns: none (implicit).
- Side effects: records the administrator action and invokes the destructive wipe workflow.

#### proc/Wipe
- Signature: `proc/Wipe(delete_map=1,delete_items=1,cost_threshold=0,turf_health=20000,delete_feats=1)`
- Inputs: delete_map=1, delete_items=1, cost_threshold=0, turf_health=20000, delete_feats=1
- Purpose: Reset configured world state and delete character persistence from the current runtime environment without crossing between live and playtest roots.
- Returns: none (implicit).
- Side effects: disables player saving, resets planetary ownership, rates, and treasuries, removes configured map/item/Feat/profile/DBZ data, sends a non-blocking warning to connected players, and schedules a reboot after 30 seconds.

#### obj/proc/Item_upgrade_reset_for_wipe
- Signature: `obj/proc/Item_upgrade_reset_for_wipe()`
- Inputs: None
- Purpose: Handle item upgrade reset for wipe.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/afkBoot
- Signature: `mob/Admin3/verb/afkBoot()`
- Inputs: None
- Purpose: Handle afkboot.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/kill
- Signature: `mob/Admin1/verb/kill(mob/A in world)`
- Inputs: mob/A in world
- Purpose: Handle kill.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/errors
- Signature: `mob/Admin4/verb/errors()`
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

#### mob/Admin4/verb/update
- Signature: `mob/Admin4/verb/update()//(var/F as file)`
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

#### mob/Admin1/verb/removeOverlays
- Signature: `mob/Admin1/verb/removeOverlays(atom/A in Admin_Overlays_List())`
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

#### mob/Admin4/verb/playFile
- Signature: `mob/Admin4/verb/playFile(S as file)`
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

#### mob/Admin1/verb/displayPlayerAges
- Signature: `mob/Admin1/verb/displayPlayerAges()`
- Inputs: None
- Purpose: Handle display player ages.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/replace
- Signature: `mob/Admin4/verb/replace(atom/A as turf|obj in view(10))`
- Inputs: atom/A as turf|obj in view(10
- Purpose: Handle replace.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/giveItem
- Signature: `mob/Admin2/verb/giveItem(mob/A in world, Search as text)`
- Inputs: mob/A in world, Search as text
- Purpose: Handle give item.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/make
- Signature: `mob/Admin2/verb/make(mob/A in world, Search as text)`
- Inputs: mob/A in world, Search as text
- Purpose: Handle make.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/forms
- Signature: `mob/Admin2/verb/forms()`
- Inputs: None
- Purpose: Handle forms.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/reboot
- Signature: `mob/Admin3/verb/reboot()`
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

#### mob/Admin5/verb/shutdownServer
- Signature: `mob/Admin5/verb/shutdownServer()`
- Inputs: None
- Purpose: Handle shutdown.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/sendMessage
- Signature: `mob/Admin1/verb/sendMessage(msg as message)`
- Inputs: msg as message
- Purpose: Handle message.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/chatOn
- Signature: `chatOn()`
- Inputs: None
- Purpose: Handle chat on.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/narrate
- Signature: `narrate(msg as message)`
- Inputs: msg as message
- Purpose: Handle narrate.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/streamMusicToEveryone
- Signature: `streamMusicToEveryone()`
- Inputs: None
- Purpose: Handle stream music to everyone.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/stopAllSoundsGlobally
- Signature: `stopAllSoundsGlobally()`
- Inputs: None
- Purpose: Stop All Sounds Globally.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin1/verb/ip
- Signature: `ip(mob/M in players)`
- Inputs: mob/M in players
- Purpose: Handle ip.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/enterCharacter
- Signature: `enterCharacter(mob/M in world)`
- Inputs: mob/M in world
- Purpose: Copy a target's active character slot and feat progression into the admin's active slot before loading it.
- Returns: none (implicit).
- Side effects: overwrites the admin's selected slot without mutating the target's save identity.

#### mob/proc/MassReviveAlert
- Signature: `mob/proc/MassReviveAlert()`
- Inputs: None
- Purpose: Handle mass revive alert.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/massRevive
- Signature: `massRevive()`
- Inputs: None
- Purpose: Handle mass revive.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/massSummon
- Signature: `massSummon()`
- Inputs: None
- Purpose: Handle mass summon.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/dead
- Signature: `mob/Admin2/verb/dead()`
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

#### mob/Admin2/verb/delete
- Signature: `mob/Admin2/verb/delete(Search as text)`
- Inputs: Search as text
- Purpose: Handle delete.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/deleteAtom
- Signature: `mob/Admin2/verb/deleteAtom(atom/Target in Delete_List(src))`
- Inputs: atom/Target in Delete_List(src
- Purpose: Delete Atom.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin1/verb/kick
- Signature: `mob/Admin1/verb/kick(mob/m in world)`
- Inputs: mob/m in world
- Purpose: Handle kick.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/xyzTeleport
- Signature: `xyzTeleport(mob/M in world)`
- Inputs: mob/M in world
- Purpose: Handle xyzteleport.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/giveSuperSaiyan
- Signature: `giveSuperSaiyan(mob/A in world)`
- Inputs: mob/A in world
- Purpose: Handle give super saiyan.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/adminHeal
- Signature: `mob/Admin1/verb/adminHeal(mob/A in world)`
- Inputs: mob/A in world
- Purpose: Handle admin heal.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/allowOOC
- Signature: `mob/Admin2/verb/allowOOC()`
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

#### mob/Admin1/verb/chat
- Signature: `chat(msg as text)`
- Inputs: msg as text
- Purpose: Handle chat.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/announce
- Signature: `announce(msg as message)`
- Inputs: msg as message
- Purpose: Handle announce.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/koSomeone
- Signature: `koSomeone(mob/M in world)`
- Inputs: mob/M in world
- Purpose: Handle ko someone.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/adminRevive
- Signature: `mob/Admin1/verb/adminRevive(mob/M in players)`
- Inputs: mob/M in players
- Purpose: Handle admin revive.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/worldHeal
- Signature: `mob/Admin2/verb/worldHeal()`
- Inputs: None
- Purpose: Handle world heal.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/teleport
- Signature: `mob/Admin1/verb/teleport(mob/M in Summon_List())`
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

#### mob/Admin1/verb/summon
- Signature: `mob/Admin1/verb/summon(mob/M in Summon_List())`
- Inputs: mob/M in Summon_List(
- Purpose: Handle summon.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/mute
- Signature: `mute()`
- Inputs: None
- Purpose: Handle mute.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/massUnMute
- Signature: `massUnMute()`
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

#### mob/Admin1/verb/ban
- Signature: `ban(mob/P as anything in Bannables())`
- Inputs: mob/P as anything in Bannables(
- Purpose: Handle ban.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/manualBan
- Signature: `mob/Admin1/verb/manualBan()`
- Inputs: None
- Purpose: Handle manual ban.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/setMaxBanTime
- Signature: `mob/Admin5/verb/setMaxBanTime()`
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

#### mob/Admin3/verb/massKo
- Signature: `mob/Admin3/verb/massKo()`
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

#### mob/Admin3/verb/edit
- Signature: `mob/Admin3/verb/edit(atom/a in world)`
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

#### mob/Admin5/verb/brix
- Signature: `mob/Admin5/verb/brix(mob/A in world)`
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

#### mob/Admin5/verb/maxSwarms
- Signature: `mob/Admin5/verb/maxSwarms()`
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

#### mob/Admin4/verb/serverControlPanel
- Signature: `mob/Admin4/verb/serverControlPanel()`
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

#### mob/Admin4/verb/loadExternalMapFile
- Signature: `mob/Admin4/verb/loadExternalMapFile()`
- Inputs: None
- Purpose: Load External Map File.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin2/verb/bugLogs
- Signature: `mob/Admin2/verb/bugLogs()`
- Inputs: None
- Purpose: Handle bug logs.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/viewRpWindow
- Signature: `viewRpWindow(mob/M in players)`
- Inputs: mob/M in players
- Purpose: View a player's RP log.
- Returns: none (implicit).
- Side effects: reads and displays RP log files.

#### mob/Admin1/verb/viewDevelopmentRpWindow
- Signature: `viewDevelopmentRpWindow(mob/M in players)`
- Inputs: mob/M in players
- Purpose: View a player's development RP log.
- Returns: none (implicit).
- Side effects: reads and displays development RP log files.

#### mob/Admin1/verb/viewAdminLogs
- Signature: `viewAdminLogs()`
- Inputs: None
- Purpose: View the log for a selected administrator.
- Returns: none (implicit).
- Side effects: reads and displays admin log files.

#### mob/Admin1/verb/viewAllAdminLogs
- Signature: `viewAllAdminLogs()`
- Inputs: None
- Purpose: View the combined administrator log.
- Returns: none (implicit).
- Side effects: reads and displays admin log files.

#### mob/Admin4/verb/wipeBountyList
- Signature: `wipeBountyList()`
- Inputs: None
- Purpose: Handle wipe bounty list.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Admin/NexusAttackTesting.dm

#### mob/Admin3/verb/giveNexusAttacks
- Signature: `giveNexusAttacks(mob/character in players)`
- Inputs: connected target player and an interactive package selection.
- Purpose: Grant weapon, unarmed, rock, persistent special-style, beam or complete Nexus attack packages without duplicating owned attacks. Generic blast reskins are intentionally excluded.
- Returns: none (implicit).
- Side effects: creates skill objects in the target inventory and writes an admin audit entry.

#### mob/Admin3/verb/testNexusCombatEffects
- Signature: `testNexusCombatEffects()`
- Inputs: interactive sword, sword-wave, rock, maximum explosion-light or explosive-beam knockback profile.
- Purpose: Preview shared audiovisual combat profiles and verify beam knockback without damaging a player.
- Returns: none (implicit).
- Side effects: creates only short-lived preview effects, sounds and an automatically removed combat dummy; it is also searchable in the structured Admin Panel.

#### proc/grantNexusAttackTypes
- Signature: `proc/grantNexusAttackTypes(mob/character, list/attack_types)`
- Inputs: target character and list of attack type paths.
- Purpose: Instantiate only missing attacks for repeatable development testing.
- Returns: count of newly granted attacks.
- Side effects: adds attack objects to the character.

#### proc/getNexusRockAttackTypes
- Signature: `proc/getNexusRockAttackTypes()`
- Inputs: none.
- Purpose: Return Rock Throw, Rock Slide and Rock Tomb as a dedicated Nexus audiovisual testing package.
- Returns: list of three attack object type paths.
- Side effects: none.
