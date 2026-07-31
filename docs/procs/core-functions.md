# Core Functions

## Overview
Core world, persistence, combat-recovery, and utility functions.

`KoSystem.dm` now coordinates Casual/Lethal recovery through RP Mode and Willpower. `combat_ko_total` remains only as a save-compatibility field and is normalized to zero; it is no longer a three-KO health resource.

## Files
- `src/Code/CoreFunctions/DBModeCharacters.dm`
- `src/Code/CoreFunctions/DBModeCore.dm`
- `src/Code/CoreFunctions/EnergySystem.dm`
- `src/Code/CoreFunctions/KoSystem.dm`
- `src/Code/CoreFunctions/LegacyUtilities.dm`
- `src/Code/CoreFunctions/ListSorting2018.dm`
- `src/Code/CoreFunctions/Main.dm`
- `src/Code/CoreFunctions/MainCreation.dm`
- `src/Code/CoreFunctions/MainWorld.dm`
- `src/Code/CoreFunctions/Map.dm`
- `src/Code/CoreFunctions/MonsterAIRevamp2019.dm`
- `src/Code/CoreFunctions/PathfindTest.dm`
- `src/Code/CoreFunctions/PixelHelpers.dm`
- `src/Code/CoreFunctions/Saving.dm`
- `src/Code/CoreFunctions/Security.dm`
- `src/Code/CoreFunctions/SecurityAdminBanning.dm`
- `src/Code/CoreFunctions/SecurityBanSystem20.dm`
- `src/Code/CoreFunctions/SecurityRelog.dm`
- `src/Code/CoreFunctions/SkillSystem.dm`
- `src/Code/CoreFunctions/StatPoints.dm`
- `src/Code/CoreFunctions/StatpanelTabs.dm`
- `src/Code/CoreFunctions/SpatialQueries.dm`
- `src/Code/CoreFunctions/Text.dm`
- `src/Code/CoreFunctions/TextRelated.dm`
- `src/Code/CoreFunctions/Vars/GlobalCombatSettings.dm`
- `src/Code/CoreFunctions/Vars/GlobalWorldSettings.dm`
- `src/Code/CoreFunctions/Vars/MobCoreVars.dm`
- `src/Code/CoreFunctions/Vars/MobSubsystemVars.dm`
- `src/Code/CoreFunctions/Vars/WorldConstants.dm`
- `src/Code/CoreFunctions/Game/Effects/EffectsLoops.dm`
- `src/Code/CoreFunctions/Game/Loop/MainGameLoop.dm`

## Proc Reference

### src/Code/CoreFunctions/Vars/GlobalCombatSettings.dm

#### proc/ShouldOneShot
- Signature: `proc/ShouldOneShot(mob/a, mob/b) //a = attacker`
- Inputs: mob/a, mob/b
- Purpose: Handle should one shot.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/CoreFunctions/DBModeCharacters.dm

#### proc/Generate_dbz_character
- Signature: `proc/Generate_dbz_character(n,for_avatar,new_only)`
- Inputs: n, for_avatar, new_only
- Purpose: Handle generate dbz character.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DBCharSpawnLoc
- Signature: `proc/DBCharSpawnLoc(n)`
- Inputs: n
- Purpose: Handle dbchar spawn loc.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DBCharIsLowClass
- Signature: `proc/DBCharIsLowClass(n)`
- Inputs: n
- Purpose: Handle dbchar is low class.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DBCharIntMultByName
- Signature: `proc/DBCharIntMultByName(n)`
- Inputs: n
- Purpose: Handle dbchar int mult by name.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DBCharIcon
- Signature: `proc/DBCharIcon(n)`
- Inputs: n
- Purpose: Handle dbchar icon.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DBZCharSkills
- Signature: `mob/proc/DBZCharSkills()`
- Inputs: None
- Purpose: Handle dbzchar skills.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DBZ_character_race_by_name
- Signature: `proc/DBZ_character_race_by_name(n)`
- Inputs: n
- Purpose: Handle dbz character race by name.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DBZ_hair
- Signature: `mob/proc/DBZ_hair(n)`
- Inputs: n
- Purpose: Handle dbz hair.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DBZ_starting_BP
- Signature: `mob/proc/DBZ_starting_BP()`
- Inputs: None
- Purpose: Handle dbz starting bp.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DBZ_character_stats
- Signature: `mob/proc/DBZ_character_stats(n)`
- Inputs: n
- Purpose: Handle dbz character stats.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/CoreFunctions/DBModeCore.dm

#### mob/proc/DBCharacterMenu
- Signature: `DBCharacterMenu()`
- Inputs: None
- Purpose: Handle dbcharacter menu.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RefreshDBCharacterMenu
- Signature: `RefreshDBCharacterMenu()`
- Inputs: None
- Purpose: Handle refresh dbcharacter menu.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/RefreshDBCharacterMenuAll
- Signature: `RefreshDBCharacterMenuAll()`
- Inputs: None
- Purpose: Handle refresh dbcharacter menu all.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Initialize_db_menu_avatars
- Signature: `proc/Initialize_db_menu_avatars()`
- Inputs: None
- Purpose: Initialize db menu avatars.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Add_dbz_avatar
- Signature: `proc/Add_dbz_avatar(n, bypass_exist_check)`
- Inputs: n, bypass_exist_check
- Purpose: Add dbz avatar.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Remove_dbz_avatar
- Signature: `proc/Remove_dbz_avatar(n)`
- Inputs: n
- Purpose: Remove dbz avatar.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/DBZ_character_del
- Signature: `mob/proc/DBZ_character_del()`
- Inputs: None
- Purpose: Handle dbz character del.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/DBZ_Character/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_playable_db_characters
- Signature: `proc/Get_playable_db_characters()`
- Inputs: None
- Purpose: Return playable db characters.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/DBZ_character_exists
- Signature: `proc/DBZ_character_exists(n)`
- Inputs: n
- Purpose: Handle dbz character exists.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Load_dbz_character
- Signature: `mob/proc/Load_dbz_character(n, for_generation)`
- Inputs: n, for_generation
- Purpose: Load dbz character.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Save_dbz_character
- Signature: `mob/proc/Save_dbz_character(first_time)`
- Inputs: first_time
- Purpose: Save dbz character.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/UpdateDBZAvatar
- Signature: `mob/proc/UpdateDBZAvatar()`
- Inputs: None
- Purpose: Update DBZAvatar.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/CoreFunctions/EnergySystem.dm

#### Seal/proc/Seal
- Signature: `Seal(reason, duration)`
- Inputs: reason, duration
- Purpose: Handle seal.
- Returns: none (implicit).
- Side effects: see implementation.

#### Seal/proc/Unseal
- Signature: `Unseal(reason)`
- Inputs: reason
- Purpose: Handle unseal.
- Returns: none (implicit).
- Side effects: see implementation.

#### Seal/proc/Cycle_Seal
- Signature: `Cycle_Seal(seal_change = 1)`
- Inputs: seal_change = 1
- Purpose: Handle cycle seal.
- Returns: none (implicit).
- Side effects: see implementation.

#### EnergySchedule/New
- Signature: `New(operation, amount = 1, duration = 1, reason)`
- Inputs: operation, amount = 1, duration = 1, reason
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### Energy/New
- Signature: `New(name, maximum = 100, modifier = 1.0, increases_naturally = TRUE)`
- Inputs: name, maximum = 100, modifier = 1.0, increases_naturally = TRUE
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### Energy/proc/increase
- Signature: `increase(amount = 1)`
- Inputs: amount = 1
- Purpose: Handle increase.
- Returns: none (implicit).
- Side effects: see implementation.

#### Energy/proc/decrease
- Signature: `decrease(amount = 1)`
- Inputs: amount = 1
- Purpose: Handle decrease.
- Returns: none (implicit).
- Side effects: see implementation.

#### Energy/proc/increase_maxiumum
- Signature: `increase_maxiumum(amount = 1)`
- Inputs: amount = 1
- Purpose: Handle increase maxiumum.
- Returns: none (implicit).
- Side effects: see implementation.

#### Energy/proc/decrease_maximum
- Signature: `decrease_maximum(amount = 1)`
- Inputs: amount = 1
- Purpose: Handle decrease maximum.
- Returns: none (implicit).
- Side effects: see implementation.

#### Energy/proc/schedule_decrease
- Signature: `schedule_decrease(amount = 1, duration = 1, reason = "Scheduled decrease")`
- Inputs: amount = 1, duration = 1, reason = "Scheduled decrease"
- Purpose: Handle schedule decrease.
- Returns: none (implicit).
- Side effects: see implementation.

#### Energy/proc/schedule_increase
- Signature: `schedule_increase(amount = 1, duration = 1, reason = "Scheduled increase")`
- Inputs: amount = 1, duration = 1, reason = "Scheduled increase"
- Purpose: Handle schedule increase.
- Returns: none (implicit).
- Side effects: see implementation.

#### Energy/proc/cycle_energy
- Signature: `cycle_energy()`
- Inputs: None
- Purpose: Handle cycle energy.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/has_energy_type
- Signature: `mob/proc/has_energy_type(energy_type)`
- Inputs: energy_type
- Purpose: Return whether energy type.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/give_energy_type
- Signature: `mob/proc/give_energy_type(energy_type, amount = 100, maximum = 100, modifier = 1.0)`
- Inputs: energy_type, amount = 100, maximum = 100, modifier = 1.0
- Purpose: Add a registered energy type to the current mob.
- Returns: none (implicit).
- Side effects: creates and stores an Energy datum.

#### mob/proc/remove_energy_type
- Signature: `mob/proc/remove_energy_type(energy_type)`
- Inputs: energy_type
- Purpose: Remove an energy type from the current mob.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/normalize_energy_types
- Signature: `mob/proc/normalize_energy_types()`
- Inputs: None
- Purpose: Migrate legacy energy saves once, grant baseline race energies, and remove the retired Qi energy type.
- Returns: none (implicit).
- Side effects: mutates the current mob's energy list.

#### mob/Admin2/verb/giveEnergyTypeToPlayer
- Signature: `mob/Admin2/verb/giveEnergyTypeToPlayer(mob/player in players)`
- Inputs: mob/player in players
- Purpose: Handle give energy type to player.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/removeEnergyTypeFromPlayer
- Signature: `mob/Admin2/verb/removeEnergyTypeFromPlayer(mob/player in players)`
- Inputs: mob/player in players
- Purpose: Remove Energy Type From Player.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/CoreFunctions/KoSystem.dm

#### mob/proc/Cause_Combat_KO
- Signature: `Cause_Combat_KO(mob/victim, mob/attacker)`
- Inputs: victim and optional attacking mob.
- Purpose: Schedule casual recovery or start lethal combat, RP Mode, and Willpower loss.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/increase_combat_ko
- Signature: `increase_combat_ko(var/reason_of_increase, quantity = 1, mob/victim)`
- Inputs: var/reason_of_increase, quantity = 1, mob/victim
- Purpose: Compatibility wrapper that converts old KO-counter penalties into Willpower damage.
- Returns: Willpower drained.
- Side effects: clears the deprecated KO counter.

#### mob/proc/decrease_combat_ko
- Signature: `decrease_combat_ko(var/reason_of_decrease, quantity = 1, mob/victim)`
- Inputs: var/reason_of_decrease, quantity = 1, mob/victim
- Purpose: Compatibility wrapper that converts old KO-counter healing into Willpower restoration.
- Returns: Willpower restored.
- Side effects: clears the deprecated KO counter.

#### mob/proc/get_time_out_of_combat
- Signature: `get_time_out_of_combat(mob/victim)`
- Inputs: mob/victim
- Purpose: Return time out of combat.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/has_entered_combat
- Signature: `has_entered_combat(mob/victim)`
- Inputs: mob/victim
- Purpose: Return whether entered combat.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/is_out_of_combat
- Signature: `is_out_of_combat(mob/victim)`
- Inputs: mob/victim
- Purpose: Return whether out of combat.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/announce_combat_message
- Signature: `announce_combat_message(var/message, var/mob/center)`
- Inputs: var/message, var/mob/center
- Purpose: Handle announce combat message.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/time_to_heal_ko
- Signature: `time_to_heal_ko(mob/victim)`
- Inputs: mob/victim
- Purpose: Calculate the get-up delay after healing and milestone modifiers.
- Returns: delay in world ticks.
- Side effects: none expected.

#### mob/proc/set_healing_modifier
- Signature: `set_healing_modifier(var/modifier, var/reason, var/is_cummulative = FALSE, mob/victim)`
- Inputs: var/modifier, var/reason, var/is_cummulative = FALSE, mob/victim
- Purpose: Set healing modifier.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/try_healing_combat_ko
- Signature: `try_healing_combat_ko(mob/victim)`
- Inputs: mob/victim
- Purpose: Auto-rise from casual KOs, announce lethal get-up readiness, recover failed Willpower, and passively restore Willpower out of combat.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/CoreFunctions/ListSorting2018.dm

#### proc/SortListOfObjectsAlphabetically
- Signature: `SortListOfObjectsAlphabetically(list/l)`
- Inputs: list/l
- Purpose: Handle sort list of objects alphabetically.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/bubblesort
- Signature: `bubblesort(list/L, sort=0)`
- Inputs: list/L, sort=0
- Purpose: Handle bubblesort.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/quicksort
- Signature: `quicksort(list/L, sort=0)`
- Inputs: list/L, sort=0
- Purpose: Handle quicksort.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/mergesort
- Signature: `mergesort(list/L, sort=0)`
- Inputs: list/L, sort=0
- Purpose: Handle mergesort.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/merge
- Signature: `merge(list/L, list/R)`
- Inputs: list/L, list/R
- Purpose: Handle merge.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/selectionsort
- Signature: `selectionsort(list/L, sort=0)`
- Inputs: list/L, sort=0
- Purpose: Handle selectionsort.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/insertionsort
- Signature: `insertionsort(list/L, sort=0)`
- Inputs: list/L, sort=0
- Purpose: Handle insertionsort.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/descending
- Signature: `descending(list/L)`
- Inputs: list/L
- Purpose: Handle descending.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/CoreFunctions/Main.dm

#### mob/proc/NewZenkaiMods
- Signature: `mob/proc/NewZenkaiMods()`
- Inputs: None
- Purpose: Handle new zenkai mods.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GetNewZenkaiMod
- Signature: `mob/proc/GetNewZenkaiMod()`
- Inputs: None
- Purpose: Return New Zenkai Mod.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Get_race_starting_bp_mod
- Signature: `mob/proc/Get_race_starting_bp_mod()`
- Inputs: None
- Purpose: Return race starting bp mod.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Disabled_Verb_Check
- Signature: `mob/proc/Disabled_Verb_Check()`
- Inputs: None
- Purpose: Handle disabled verb check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/code_banned
- Signature: `mob/proc/code_banned()`
- Inputs: None
- Purpose: Handle code banned.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ban_alert
- Signature: `mob/proc/ban_alert(msg)`
- Inputs: msg
- Purpose: Handle ban alert.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Carry_over_imprisonments
- Signature: `mob/proc/Carry_over_imprisonments()`
- Inputs: None
- Purpose: Handle carry over imprisonments.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ClickMakeNewCharacter
- Signature: `mob/proc/ClickMakeNewCharacter()`
- Inputs: None
- Purpose: Handle click make new character.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CodebanLoginCheck
- Signature: `CodebanLoginCheck()`
- Inputs: None
- Purpose: Handle codeban login check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/UnsortedClientLoginStuff
- Signature: `UnsortedClientLoginStuff()`
- Inputs: None
- Purpose: Handle unsorted client login stuff.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/StuffThatRunsIfYouClickNewOrLoad
- Signature: `StuffThatRunsIfYouClickNewOrLoad()`
- Inputs: None
- Purpose: Handle stuff that runs if you click new or load.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ApplyStartingBP
- Signature: `mob/proc/ApplyStartingBP()`
- Inputs: None
- Purpose: Apply Starting BP.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/New_Character
- Signature: `New_Character(reincarnating,force_race,force_elite,dbz_hair,force_low_class)`
- Inputs: reincarnating, force_race, force_elite, dbz_hair, force_low_class
- Purpose: Handle new character.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Choose_Age
- Signature: `Choose_Age()`
- Inputs: None
- Purpose: Handle choose age.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Race_Starting_Stats
- Signature: `Race_Starting_Stats()`
- Inputs: None
- Purpose: Handle race starting stats.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Random_Colors
- Signature: `Random_Colors()`
- Inputs: None
- Purpose: Handle random colors.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Name
- Signature: `Name()`
- Inputs: None
- Purpose: Handle name.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Check_Spawn
- Signature: `Check_Spawn(list/L)`
- Inputs: list/L
- Purpose: Check Spawn.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Race
- Signature: `Race(force_race,force_elite,force_low_class)`
- Inputs: force_race, force_elite, force_low_class
- Purpose: Handle race.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Yeet
- Signature: `mob/proc/Yeet()`
- Inputs: None
- Purpose: Handle yeet.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Human
- Signature: `mob/proc/Human()`
- Inputs: None
- Purpose: Handle human.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Doll
- Signature: `mob/proc/Doll()`
- Inputs: None
- Purpose: Handle doll.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Tsujin
- Signature: `mob/proc/Tsujin()`
- Inputs: None
- Purpose: Handle tsujin.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Majin
- Signature: `mob/proc/Majin()`
- Inputs: None
- Purpose: Handle majin.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Bio
- Signature: `mob/proc/Bio()`
- Inputs: None
- Purpose: Handle bio.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Makyo
- Signature: `mob/proc/Makyo()`
- Inputs: None
- Purpose: Handle makyo.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Namekian
- Signature: `mob/proc/Namekian()`
- Inputs: None
- Purpose: Handle namekian.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Half_Saiyan
- Signature: `mob/proc/Half_Saiyan()`
- Inputs: None
- Purpose: Handle half saiyan.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Saiyan
- Signature: `mob/proc/Saiyan(Can_Elite=1,force_elite,force_low_class)`
- Inputs: Can_Elite=1, force_elite, force_low_class
- Purpose: Handle saiyan.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Elite_starting_bp
- Signature: `mob/proc/Elite_starting_bp()`
- Inputs: None
- Purpose: Handle elite starting bp.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Elite_Saiyan
- Signature: `mob/proc/Elite_Saiyan() if(Class!="Elite")`
- Inputs: None
- Purpose: Handle elite saiyan.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Cooler
- Signature: `mob/proc/Cooler()`
- Inputs: None
- Purpose: Handle cooler.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Legendary_Saiyan
- Signature: `mob/proc/Legendary_Saiyan()`
- Inputs: None
- Purpose: Handle legendary saiyan.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Icer
- Signature: `mob/proc/Icer()`
- Inputs: None
- Purpose: Handle icer.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Kai
- Signature: `mob/proc/Kai()`
- Inputs: None
- Purpose: Handle kai.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Demigod
- Signature: `mob/proc/Demigod()`
- Inputs: None
- Purpose: Handle demigod.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Demon
- Signature: `mob/proc/Demon()`
- Inputs: None
- Purpose: Handle demon.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Android
- Signature: `mob/proc/Android()`
- Inputs: None
- Purpose: Handle android.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Alien
- Signature: `mob/proc/Alien()`
- Inputs: None
- Purpose: Handle alien.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/CoreFunctions/MainCreation.dm

#### mob/proc/Get_spawns
- Signature: `mob/proc/Get_spawns(excludeShips = 0)`
- Inputs: excludeShips = 0
- Purpose: Return spawns.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Go_to_spawn
- Signature: `mob/proc/Go_to_spawn(First_time = 0, butNotInShipArea)`
- Inputs: First_time = 0, butNotInShipArea
- Purpose: Handle go to spawn.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Race_Count
- Signature: `proc/Race_Count(R,Z) //retursn how many of this race are on a given z plane`
- Inputs: R, Z
- Purpose: Handle race count.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Race_Z
- Signature: `mob/proc/Race_Z() //return the z plane that most of this race is located on`
- Inputs: None
- Purpose: Handle race z.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Gender
- Signature: `Gender()`
- Inputs: None
- Purpose: Handle gender.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Human_Skins
- Signature: `Human_Skins()`
- Inputs: None
- Purpose: Handle human skins.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Skin
- Signature: `Skin()`
- Inputs: None
- Purpose: Handle skin.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Choose
- Signature: `proc/Choose()`
- Inputs: None
- Purpose: Handle choose.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Choose
- Signature: `proc/Choose(mob/P)`
- Inputs: mob/P
- Purpose: Handle choose.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/icer_Icons
- Signature: `mob/proc/icer_Icons()`
- Inputs: None
- Purpose: Handle icer icons.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Icer/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Choose_Hair
- Signature: `mob/proc/Choose_Hair(force_hair)`
- Inputs: force_hair
- Purpose: Handle choose hair.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RandomHair
- Signature: `mob/proc/RandomHair()`
- Inputs: None
- Purpose: Handle random hair.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair1/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair_Caulifla/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair_Kale/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair2/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair3/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair4/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair5/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair6/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair7/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair8/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair9/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair10/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair11/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair12/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair13/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair14/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair15/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair16/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair17/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair18/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair19/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair20/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair21/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair22/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair23/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair24/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair25/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair26/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair27/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair28/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair29/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair30/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair31/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair32/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair33/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair34/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair35/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair36/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair37/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair38/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair39/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair40/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair41/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair42/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair43/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair44/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/Hair45/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hairs/CustomHair/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Apply_Hair
- Signature: `proc/Apply_Hair(mob/P,obj/Hairs/O,force_color)`
- Inputs: mob/P, obj/Hairs/O, force_color
- Purpose: Apply Hair.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Choose_Android_Icon
- Signature: `mob/proc/Choose_Android_Icon()`
- Inputs: None
- Purpose: Handle choose android icon.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Android_Icons
- Signature: `proc/Android_Icons() if(!Android_Icons)`
- Inputs: None
- Purpose: Handle android icons.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Base_Icon/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/CoreFunctions/MainWorld.dm

#### world/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/RenameCopyrightSpawns
- Signature: `proc/RenameCopyrightSpawns()`
- Inputs: None
- Purpose: Handle rename copyright spawns.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/World_Status
- Signature: `proc/World_Status()`
- Inputs: None
- Purpose: Handle world status.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/setServerName
- Signature: `mob/Admin4/verb/setServerName()`
- Inputs: None
- Purpose: Set Server Name.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin5/verb/overrideServerName
- Signature: `mob/Admin5/verb/overrideServerName()`
- Inputs: None
- Purpose: Handle override server name.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/FilterServerName
- Signature: `proc/FilterServerName()`
- Inputs: None
- Purpose: Handle filter server name.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Login
- Signature: `mob/Login() if(client)`
- Inputs: None
- Purpose: Handle client login setup.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Connection_count
- Signature: `mob/proc/Connection_count()`
- Inputs: None
- Purpose: Handle connection count.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Logout
- Signature: `mob/Logout(body_swap_user)`
- Inputs: body_swap_user
- Purpose: Handle client logout cleanup.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Other_Load_Stuff
- Signature: `mob/proc/Other_Load_Stuff()`
- Inputs: None
- Purpose: Normalize loaded character state and start player systems.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Turf_Range
- Signature: `proc/Turf_Range(atom/Origin,Distance)`
- Inputs: atom/Origin, Distance
- Purpose: Handle turf range.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/TurfCircle
- Signature: `proc/TurfCircle(radius,turf/center)`
- Inputs: radius, turf/center
- Purpose: Handle turf circle.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Nuke
- Signature: `proc/Nuke(atom/Origin,Distance)`
- Inputs: atom/Origin, Distance
- Purpose: Handle nuke.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Res
- Signature: `mob/proc/Res()`
- Inputs: None
- Purpose: Handle res.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GetResourceObject
- Signature: `mob/proc/GetResourceObject()`
- Inputs: None
- Purpose: Return Resource Object.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Alter_Res
- Signature: `mob/proc/Alter_Res(Amount=0) if(resource_obj)`
- Inputs: Amount=0
- Purpose: Handle alter res.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SetRes
- Signature: `mob/proc/SetRes(n = 0)`
- Inputs: n = 0
- Purpose: Set Res.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Average_BP
- Signature: `proc/Average_BP()`
- Inputs: None
- Purpose: Handle average bp.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Race_List
- Signature: `proc/Race_List()`
- Inputs: None
- Purpose: Handle race list.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Spawn/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Spawn/Click
- Signature: `Click() if(usr in view(1,src))`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade_health
- Signature: `verb/Upgrade_health()`
- Inputs: None
- Purpose: Handle upgrade health.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Customize
- Signature: `verb/Customize()`
- Inputs: None
- Purpose: Handle customize.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ZeroDelayLoop
- Signature: `proc/ZeroDelayLoop() while(1)`
- Inputs: None
- Purpose: Handle zero delay loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Saiyan_Count
- Signature: `proc/Saiyan_Count(Amount=1)`
- Inputs: Amount=1
- Purpose: Handle saiyan count.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/getdist
- Signature: `proc/getdist(atom/a,atom/b)`
- Inputs: atom/a, atom/b
- Purpose: Handle getdist.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Circle
- Signature: `proc/Circle(n = 5, mob/m, viewable_only = 0) //circular ring`
- Inputs: n = 5, mob/m, viewable_only = 0
- Purpose: Handle circle.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Final_Realm
- Signature: `mob/proc/Final_Realm()`
- Inputs: None
- Purpose: Handle final realm.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/proc/Final_Realm
- Signature: `obj/proc/Final_Realm()`
- Inputs: None
- Purpose: Handle final realm.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Players_with_z
- Signature: `proc/Players_with_z()`
- Inputs: None
- Purpose: Handle players with z.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Return_to_Spawn
- Signature: `mob/verb/Return_to_Spawn()`
- Inputs: None
- Purpose: Handle return to spawn.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/check_duplicate_dragon_balls
- Signature: `mob/proc/check_duplicate_dragon_balls()`
- Inputs: None
- Purpose: Check duplicate dragon balls.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/proc/text_overlay
- Signature: `atom/proc/text_overlay(var/text="",xx=0,yy=32,timer=10)`
- Inputs: var/text="", xx=0, yy=32, timer=10
- Purpose: Handle text overlay.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Nuke_detonate
- Signature: `proc/Nuke_detonate(nuke_bp=0, turf/origin, range=30, radiation=1, overlay_prob=8, overlay_timer=35, obj/bombObj, requireBombObj)`
- Inputs: nuke_bp=0, turf/origin, range=30, radiation=1, overlay_prob=8, overlay_timer=35, obj/bombObj, requireBombObj
- Purpose: Handle nuke detonate.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/nuke_test
- Signature: `turf/proc/nuke_test(nuke_bp=0,turf/origin,range=80)`
- Inputs: nuke_bp=0, turf/origin, range=80
- Purpose: Handle nuke test.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Evil_overlay
- Signature: `mob/proc/Evil_overlay()`
- Inputs: None
- Purpose: Handle evil overlay.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Remove_evil_overlay
- Signature: `mob/proc/Remove_evil_overlay()`
- Inputs: None
- Purpose: Remove evil overlay.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Make_evil_overlay
- Signature: `proc/Make_evil_overlay()`
- Inputs: None
- Purpose: Handle make evil overlay.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/choose_alignment
- Signature: `mob/proc/choose_alignment()`
- Inputs: None
- Purpose: Handle choose alignment.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Change_Alignment
- Signature: `mob/verb/Change_Alignment()`
- Inputs: None
- Purpose: Handle change alignment.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/both_good
- Signature: `proc/both_good(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Handle both good.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/maxVillains
- Signature: `mob/Admin4/verb/maxVillains()`
- Inputs: None
- Purpose: Handle max villains.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/villain_damage_penalty_update
- Signature: `proc/villain_damage_penalty_update()`
- Inputs: None
- Purpose: Handle villain damage penalty update.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/alt_alignment_check
- Signature: `mob/proc/alt_alignment_check()`
- Inputs: None
- Purpose: Handle alt alignment check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/balance_rating
- Signature: `mob/proc/balance_rating()`
- Inputs: None
- Purpose: Handle balance rating.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Clamp
- Signature: `proc/Clamp(n=0,min=0,max=0)`
- Inputs: n=0, min=0, max=0
- Purpose: Handle clamp.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/CoreFunctions/Map.dm

#### turf/proc/RandomDirtOverlay
- Signature: `RandomDirtOverlay(n = 1)`
- Inputs: n = 1
- Purpose: Handle random dirt overlay.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/RandomGrassOverlay
- Signature: `RandomGrassOverlay(n = 1)`
- Inputs: n = 1
- Purpose: Handle random grass overlay.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Surf/Enter
- Signature: `Enter(mob/m)`
- Inputs: mob/m
- Purpose: Handle enter.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Edges/Enter
- Signature: `Enter(mob/m)`
- Inputs: mob/m
- Purpose: Handle enter.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/Roof_Enter
- Signature: `turf/proc/Roof_Enter(mob/A)`
- Inputs: mob/A
- Purpose: Handle roof enter.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/NPC_respawn
- Signature: `mob/proc/NPC_respawn()`
- Inputs: None
- Purpose: Handle npc respawn.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/NPC_Del
- Signature: `mob/proc/NPC_Del()`
- Inputs: None
- Purpose: Handle npc del.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Set_Spawn_Point
- Signature: `proc/Set_Spawn_Point(mob/P)`
- Inputs: mob/P
- Purpose: Set Spawn Point.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Respawn_turfs
- Signature: `proc/Respawn_turfs()`
- Inputs: None
- Purpose: Handle respawn turfs.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Del
- Signature: `turf/Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Write
- Signature: `obj/Write()`
- Inputs: None
- Purpose: Handle write.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Knock_Timer
- Signature: `mob/proc/Knock_Timer()`
- Inputs: None
- Purpose: Handle knock timer.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Door_kill_blood/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Do_animation
- Signature: `proc/Do_animation()`
- Inputs: None
- Purpose: Perform animation.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Custom/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Custom/verb/Clone_to_your_Build_Tab
- Signature: `Clone_to_your_Build_Tab()`
- Inputs: None
- Purpose: Handle clone to your build tab.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Door_kill_anyone_under_it
- Signature: `proc/Door_kill_anyone_under_it()`
- Inputs: None
- Purpose: Handle door kill anyone under it.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Door_blood_effects
- Signature: `proc/Door_blood_effects()`
- Inputs: None
- Purpose: Handle door blood effects.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Door/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Door/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Door/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Open
- Signature: `proc/Open()`
- Inputs: None
- Purpose: Handle open.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Close
- Signature: `proc/Close()`
- Inputs: None
- Purpose: Handle close.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Bolt
- Signature: `verb/Bolt()`
- Inputs: None
- Purpose: Handle bolt.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Sign/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Throne_1/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Throne_2/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Throne_3/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Throne_4/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Throne_5/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Throne_6/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Throne_7/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/*Throne_8/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Throne_9/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Throne_10/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Throne_11/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Jungle_plant_2/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Jungle_plant_3/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/HellPot/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/RugLarge/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Angel_Statue/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Light/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Log/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/FancyCouch/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Fire/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Log/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/FancyCouch/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Stove/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Drawer/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Bed/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Torch1/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Torch2/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Torch3/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Giant_Statue/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turfs/Rock_Formation/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Tree_20191/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Tree_20192/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Tree_20193/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Tree_20194/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Snowy_Pine_Tree/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Dead_Tree_Snow/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Big_Generic_Nice_Tree/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Bigger_Generic_Nice_Tree/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Dead_Tree_2/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Dead_Tree_3/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Pink_Tree/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Palm_Tree_2/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Palm_Tree_3/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Large_Pine/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Medium_Pine/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Small_Pine/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Jungle_tree_2/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Dead_Tree_1/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/*Dead_Tree_2/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Dark_Tree/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Strange_Pine/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/SmallPine/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/RedTree/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Tall_Tree/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/BigHousePlant/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Oak/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/RoundTree/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Tree/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Palm/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/LargePine/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/LargePineSnow/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/RedPine/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/TallBush/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/*SluggoTree/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Trees/Namekian_Tree/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Edges/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/DecideTurfStateForSpecialIcons
- Signature: `turf/proc/DecideTurfStateForSpecialIcons(width = 4, height = 4)`
- Inputs: width = 4, height = 4
- Purpose: Handle decide turf state for special icons.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Other/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Other/Lava/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Other/Blank/Enter
- Signature: `Enter(mob/M)`
- Inputs: mob/M
- Purpose: Handle enter.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Other/Stars/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Other/Ladder/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Other/Sky1/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Other/Sky2/Enter
- Signature: `Enter(mob/M)`
- Inputs: mob/M
- Purpose: Handle enter.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Other/Sky2/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/get_space_state
- Signature: `proc/get_space_state()`
- Inputs: None
- Purpose: Return space state.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### turf/Teleporter/Prison_Exit/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Teleporter/Prison_Exit/Enter
- Signature: `Enter(mob/M)`
- Inputs: mob/M
- Purpose: Handle enter.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Teleporter/Teleporter/Enter
- Signature: `Enter(mob/M)`
- Inputs: mob/M
- Purpose: Handle enter.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Teleporter/Teleporter/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Teleporter/EnterHBTC/Enter
- Signature: `Enter(mob/A)`
- Inputs: mob/A
- Purpose: Handle enter.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Teleporter/ExitHBTC/Enter
- Signature: `Enter(mob/A)`
- Inputs: mob/A
- Purpose: Handle enter.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/GroundDirt/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/GroundIce/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/GroundIce2/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/GroundSnow/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/SnowAndRocks/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Ground10/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Ground17/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Ground18/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/GroundIce3/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Ground12/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/GroundSandDark/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Grass9/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Grass13/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Grass7/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Grass5/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Grass11/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Grass12/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Grass1/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Grass8/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/GrassSluggo/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Grass2/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Grass3/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Grass4/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Ground14/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Grass14/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Grass10/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/*Green_Clouds/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Wall_Wood/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Wall_Wood_2/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Wall_Framed/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Wall_Rock_Panels/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Wall_Blue/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Roof4/Click
- Signature: `Click() if(getdist(usr,src)<=1)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Roof5/Click
- Signature: `Click() if(getdist(usr,src)<=1)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Roof6/Click
- Signature: `Click() if(getdist(usr,src)<=1)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Roof7/Click
- Signature: `Click() if(getdist(usr,src)<=1)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Roof8/Click
- Signature: `Click() if(getdist(usr,src)<=1)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Roof800/Click
- Signature: `Click() if(getdist(usr,src)<=1)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Roof9/Click
- Signature: `Click() if(getdist(usr,src)<=1)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Roof10/Click
- Signature: `Click() if(getdist(usr,src)<=1)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/RoofTech/Click
- Signature: `Click() if(getdist(usr,src)<=1)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Hell_Roof/Click
- Signature: `Click() if(getdist(usr,src)<=1)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Roof1/Click
- Signature: `Click() if(getdist(usr,src)<=1)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Roof2/Click
- Signature: `Click() if(getdist(usr,src)<=1)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Roof3/Click
- Signature: `Click() if(getdist(usr,src)<=1)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/RoofWhite/Click
- Signature: `Click() if(getdist(usr,src)<=1)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Roof_Purple_Plain/Click
- Signature: `Click() if(getdist(usr,src)<=1)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Tech_Roof/Click
- Signature: `Click() if(getdist(usr,src)<=1)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Roof_11/Click
- Signature: `Click() if(getdist(usr,src)<=1)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Tile_Tech_Floor/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Tile_Tech_Grate/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Tile_Landing_Bay/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Tile_Tech_Dark/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/WaterReal/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/WaterFast/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/WaterToxic/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Water11/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Water7/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/Water_Ripple
- Signature: `turf/proc/Water_Ripple(mob/P)`
- Inputs: mob/P
- Purpose: Handle water ripple.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/Water_Enter
- Signature: `turf/proc/Water_Enter(mob/P)`
- Inputs: mob/P
- Purpose: Handle water enter.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/Water_Exit
- Signature: `turf/proc/Water_Exit(mob/P)`
- Inputs: mob/P
- Purpose: Handle water exit.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/Swim
- Signature: `turf/proc/Swim(mob/P)`
- Inputs: mob/P
- Purpose: Handle swim.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Swim
- Signature: `mob/proc/Swim(turf/Location)`
- Inputs: turf/Location
- Purpose: Handle swim.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Planet_Restore_Crystal/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Planet_Restore_Crystal/proc/DespawnRespawn
- Signature: `DespawnRespawn()`
- Inputs: None
- Purpose: Handle despawn respawn.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Revival_Altar/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Revival_Altar/Click
- Signature: `Click() if(usr in view(1,src))`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/revive_modifier
- Signature: `mob/proc/revive_modifier()`
- Inputs: None
- Purpose: Handle revive modifier.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/revive_time
- Signature: `mob/proc/revive_time()`
- Inputs: None
- Purpose: Handle revive time.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Revival_altar
- Signature: `mob/proc/Revival_altar()`
- Inputs: None
- Purpose: Handle revival altar.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Altar_Options
- Signature: `mob/proc/Altar_Options(obj/altar)`
- Inputs: obj/altar
- Purpose: Handle altar options.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/CoreFunctions/MonsterAIRevamp2019.dm

#### mob/proc/Activate_NPCs_Loop
- Signature: `mob/proc/Activate_NPCs_Loop()`
- Inputs: None
- Purpose: Handle activate npcs loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Activate_NPCs
- Signature: `mob/proc/Activate_NPCs(Distance = 33)`
- Inputs: Distance = 33
- Purpose: Handle activate npcs.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Activate_NPC
- Signature: `mob/proc/Activate_NPC(Timer=300)`
- Inputs: Timer=300
- Purpose: Handle activate npc.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/NpcRoam
- Signature: `mob/proc/NpcRoam(timer = 600, delay)`
- Inputs: timer = 600, delay
- Purpose: Handle npc roam.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Find_Target
- Signature: `mob/proc/Find_Target(Timer=600,Delay=20)`
- Inputs: Timer=600, Delay=20
- Purpose: Handle find target.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Attack_Target
- Signature: `mob/proc/Attack_Target(mob/P)`
- Inputs: mob/P
- Purpose: Handle attack target.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Remove_unreachable_target
- Signature: `mob/proc/Remove_unreachable_target(mob/m,timer=0)`
- Inputs: mob/m, timer=0
- Purpose: Remove unreachable target.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Power_Increase_Loop
- Signature: `mob/proc/Power_Increase_Loop(Timer=600,Delay=100)`
- Inputs: Timer=600, Delay=100
- Purpose: Handle power increase loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/NPC_Heal_Loop
- Signature: `mob/proc/NPC_Heal_Loop(Timer=600,Delay=50)`
- Inputs: Timer=600, Delay=50
- Purpose: Handle npc heal loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/On_Water
- Signature: `proc/On_Water(mob/M)`
- Inputs: mob/M
- Purpose: Handle on water.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Surrounded
- Signature: `proc/Surrounded(mob/M)`
- Inputs: mob/M
- Purpose: Handle surrounded.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Find_Location
- Signature: `mob/proc/Find_Location()`
- Inputs: None
- Purpose: Handle find location.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/toggleNpcs
- Signature: `mob/Admin2/verb/toggleNpcs()`
- Inputs: None
- Purpose: Toggle Npcs.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/disable_npcs
- Signature: `proc/disable_npcs()`
- Inputs: None
- Purpose: Handle disable npcs.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/New
- Signature: `mob/New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/NewMobUpdateArea
- Signature: `mob/proc/NewMobUpdateArea() //so we dont have to use spawn()`
- Inputs: None
- Purpose: Handle new mob update area.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Add_resources
- Signature: `proc/Add_resources()`
- Inputs: None
- Purpose: Add resources.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Add_hbtc_key
- Signature: `proc/Add_hbtc_key()`
- Inputs: None
- Purpose: Add hbtc key.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/New_npc_bp
- Signature: `proc/New_npc_bp()`
- Inputs: None
- Purpose: Handle new npc bp.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Update_npc_stats
- Signature: `mob/proc/Update_npc_stats()`
- Inputs: None
- Purpose: Update npc stats.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Enemy/proc/EnemyNew
- Signature: `EnemyNew()`
- Inputs: None
- Purpose: Handle enemy new.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Namekian_Amphibian/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Namekian_Dino/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Namekian_Frog/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Bio_Monster/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Eevee/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Bear/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Pupa_Cell/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Core_Demon/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Core_Demon/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Spider_Small/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Squirrel/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Jungle_Spider/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Spider3/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Spider2/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Spider1/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Big_Scorpion/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Red_Scorpion/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Reptilian/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Chicken/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Dragon1/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Ground_Dragon/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Skeleton_Captain/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Giant_Snake/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Virus_Android/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Little_Demon/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Dino_Munky/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Robot/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Big_Robot/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Hover_Robot/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Gremlin/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Baiman/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Greenster/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Small_Greenster/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Black_Greenster/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Mutated_Greenster/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Evil_Entity/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Bandit/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Tiger_Bandit/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Night_Wolf/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Giant_Robot/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Ice_Dragon/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Ice_Flame/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Frog/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Sheep/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Dino_Bird/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Cat/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Cat_Actions
- Signature: `proc/Cat_Actions()`
- Inputs: None
- Purpose: Handle cat actions.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Bat/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Cow/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Turtle/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Turtle/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_core_demon
- Signature: `proc/Get_core_demon()`
- Inputs: None
- Purpose: Return core demon.
- Returns: computed value (see implementation).
- Side effects: none expected.

### src/Code/CoreFunctions/PathfindTest.dm

#### Can_Enter
- Signature: `Can_Enter(turf/T,no_warp)`
- Inputs: turf/T, no_warp
- Purpose: Return whether Enter.
- Returns: boolean flag.
- Side effects: none expected.

#### G_get_true_dist
- Signature: `G_get_true_dist(atom/A,atom/B)`
- Inputs: atom/A, atom/B
- Purpose: Handle g get true dist.
- Returns: none (implicit).
- Side effects: see implementation.

#### G_walk
- Signature: `G_walk(Dir,Lag=1)`
- Inputs: Dir, Lag=1
- Purpose: Handle g walk.
- Returns: none (implicit).
- Side effects: see implementation.

#### G_walk_to
- Signature: `G_walk_to(Trg,Min=0,Lag=1,Limit=10)`
- Inputs: Trg, Min=0, Lag=1, Limit=10
- Purpose: Handle g walk to.
- Returns: none (implicit).
- Side effects: see implementation.

#### G_walk_away
- Signature: `G_walk_away(Trg,Max=5,Min=0,Lag=1,Limit=10)`
- Inputs: Trg, Max=5, Min=0, Lag=1, Limit=10
- Purpose: Handle g walk away.
- Returns: none (implicit).
- Side effects: see implementation.

#### G_walk_towards
- Signature: `G_walk_towards(Trg,Min=0,Lag=1)`
- Inputs: Trg, Min=0, Lag=1
- Purpose: Handle g walk towards.
- Returns: none (implicit).
- Side effects: see implementation.

#### G_walk_rand
- Signature: `G_walk_rand(Lag=1)`
- Inputs: Lag=1
- Purpose: Handle g walk rand.
- Returns: none (implicit).
- Side effects: see implementation.

#### G_stumble_walk_away
- Signature: `G_stumble_walk_away(Trg,Max=100,Lag=1,Prob=100)`
- Inputs: Trg, Max=100, Lag=1, Prob=100
- Purpose: Handle g stumble walk away.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/pathfind
- Signature: `mob/Admin5/verb/pathfind(mob/P in world)`
- Inputs: mob/P in world
- Purpose: Handle pathfind.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_Get_step
- Signature: `G_Get_step(Dir)`
- Inputs: Dir
- Purpose: Handle g get step.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_get_step_away
- Signature: `G_get_step_away(Trg,Max=5,Min=0,Limit=10)`
- Inputs: Trg, Max=5, Min=0, Limit=10
- Purpose: Handle g get step away.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_get_step_rand
- Signature: `G_get_step_rand()`
- Inputs: None
- Purpose: Handle g get step rand.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_get_step_to
- Signature: `G_get_step_to(Trg,Min=0,Limit=20)`
- Inputs: Trg, Min=0, Limit=20
- Purpose: Handle g get step to.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_get_step_towards
- Signature: `G_get_step_towards(Trg,Min=0)`
- Inputs: Trg, Min=0
- Purpose: Handle g get step towards.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_get_stumble_step_to
- Signature: `G_get_stumble_step_to(Trg,Min=0,Prob=100)`
- Inputs: Trg, Min=0, Prob=100
- Purpose: Handle g get stumble step to.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_get_stumble_step_away
- Signature: `G_get_stumble_step_away(Trg,Max=100,Prob=100)`
- Inputs: Trg, Max=100, Prob=100
- Purpose: Handle g get stumble step away.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_step
- Signature: `G_step(Dir)`
- Inputs: Dir
- Purpose: Handle g step.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_step_away
- Signature: `G_step_away(Trg,Max=5,Min=0,Limit=10)`
- Inputs: Trg, Max=5, Min=0, Limit=10
- Purpose: Handle g step away.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_step_rand
- Signature: `G_step_rand()`
- Inputs: None
- Purpose: Handle g step rand.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/g_step_to
- Signature: `g_step_to(Trg,Min=0,Limit=20)`
- Inputs: Trg, Min=0, Limit=20
- Purpose: Handle g step to.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_step_towards
- Signature: `G_step_towards(Trg,Min=0)`
- Inputs: Trg, Min=0
- Purpose: Handle g step towards.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_stumble_step_to
- Signature: `G_stumble_step_to(Trg,Min=0,Prob=100)`
- Inputs: Trg, Min=0, Prob=100
- Purpose: Handle g stumble step to.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_stumble_step_away
- Signature: `G_stumble_step_away(Trg,Max=100,Prob=100)`
- Inputs: Trg, Max=100, Prob=100
- Purpose: Handle g stumble step away.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_step_path
- Signature: `G_step_path(Dir,Lag=0)`
- Inputs: Dir, Lag=0
- Purpose: Handle g step path.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_walk
- Signature: `G_walk(Dir,Lag=0)`
- Inputs: Dir, Lag=0
- Purpose: Handle g walk.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_walk_away
- Signature: `G_walk_away(Trg,Max=5,Min=0,Lag=0,Limit=10)`
- Inputs: Trg, Max=5, Min=0, Lag=0, Limit=10
- Purpose: Handle g walk away.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_walk_rand
- Signature: `G_walk_rand(Lag=0)`
- Inputs: Lag=0
- Purpose: Handle g walk rand.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_walk_to
- Signature: `G_walk_to(Trg,Min=0,Lag=0,Limit=10)`
- Inputs: Trg, Min=0, Lag=0, Limit=10
- Purpose: Handle g walk to.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_walk_towards
- Signature: `G_walk_towards(Trg,Min=0,Lag=0)`
- Inputs: Trg, Min=0, Lag=0
- Purpose: Handle g walk towards.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_stumble_walk_to
- Signature: `G_stumble_walk_to(Trg,Min=0,Lag=0,Prob=100)`
- Inputs: Trg, Min=0, Lag=0, Prob=100
- Purpose: Handle g stumble walk to.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_stumble_walk_away
- Signature: `G_stumble_walk_away(Trg,Max=100,Lag=0,Prob=100)`
- Inputs: Trg, Max=100, Lag=0, Prob=100
- Purpose: Handle g stumble walk away.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_tick
- Signature: `G_tick() if(!g_tick)`
- Inputs: None
- Purpose: Handle g tick.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/can_access
- Signature: `proc/can_access(atom/movable/M)`
- Inputs: atom/movable/M
- Purpose: Return whether access.
- Returns: boolean flag.
- Side effects: none expected.

#### warp/New
- Signature: `warp/New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### PathController/New
- Signature: `New(O)`
- Inputs: O
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### PathController/proc/StepTo
- Signature: `StepTo(new_dest,min,limit,get_step) if(isturf(owner.loc))`
- Inputs: new_dest, min, limit, get_step
- Purpose: Handle step to.
- Returns: none (implicit).
- Side effects: see implementation.

#### PathController/proc/StepAway
- Signature: `StepAway(new_dest,max,min,limit,get_step) if(isturf(owner.loc))`
- Inputs: new_dest, max, min, limit, get_step
- Purpose: Handle step away.
- Returns: none (implicit).
- Side effects: see implementation.

#### PathController/proc/StepTowards
- Signature: `StepTowards(new_dest,min,get_step) if(isturf(owner.loc))`
- Inputs: new_dest, min, get_step
- Purpose: Handle step towards.
- Returns: none (implicit).
- Side effects: see implementation.

#### PathController/proc/StepRand
- Signature: `StepRand(new_dest,limit,stumble_prob,away,get_step) if(isturf(owner.loc))`
- Inputs: new_dest, limit, stumble_prob, away, get_step
- Purpose: Handle step rand.
- Returns: none (implicit).
- Side effects: see implementation.

#### PathController/proc/Path
- Signature: `Path(limit,max,min)`
- Inputs: limit, max, min
- Purpose: Handle path.
- Returns: none (implicit).
- Side effects: see implementation.

#### PathController/proc/Clear
- Signature: `Clear()`
- Inputs: None
- Purpose: Handle clear.
- Returns: none (implicit).
- Side effects: see implementation.

#### PathController/proc/SearchTo
- Signature: `SearchTo(limit)`
- Inputs: limit
- Purpose: Handle search to.
- Returns: none (implicit).
- Side effects: see implementation.

#### PathController/proc/SearchAway
- Signature: `SearchAway(limit,max,min)`
- Inputs: limit, max, min
- Purpose: Handle search away.
- Returns: none (implicit).
- Side effects: see implementation.

#### PathController/proc/Sort
- Signature: `Sort(PathNode/P)`
- Inputs: PathNode/P
- Purpose: Handle sort.
- Returns: none (implicit).
- Side effects: see implementation.

#### PathController/proc/Sequence
- Signature: `Sequence(PathNode/P)`
- Inputs: PathNode/P
- Purpose: Handle sequence.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/G_get
- Signature: `G_get(atom/movable/A,atom/movable/B,function,x_off,y_off) if(isloc(A,B)&&!isarea(A)&&!isarea(B))`
- Inputs: atom/movable/A, atom/movable/B, function, x_off, y_off
- Purpose: Handle g get.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/G_get_closest
- Signature: `G_get_closest(atom/movable/A,atom/movable/B,dist)`
- Inputs: atom/movable/A, atom/movable/B, dist
- Purpose: Handle g get closest.
- Returns: none (implicit).
- Side effects: see implementation.

#### PathNode/New
- Signature: `New(T,p,o,c,d)`
- Inputs: T, p, o, c, d
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### PathNode/proc/Total
- Signature: `Total(atom/movable/owner)`
- Inputs: atom/movable/owner
- Purpose: Handle total.
- Returns: none (implicit).
- Side effects: see implementation.

#### PathNode/proc/Clear
- Signature: `Clear()`
- Inputs: None
- Purpose: Handle clear.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/get_g_step_mob
- Signature: `proc/get_g_step_mob()`
- Inputs: None
- Purpose: Return g step mob.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### atom/movable/proc/Possible_Path
- Signature: `Possible_Path(turf/T,turf/W)`
- Inputs: turf/T, turf/W
- Purpose: Handle possible path.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/Can_Enter
- Signature: `Can_Enter(turf/T,no_warp)`
- Inputs: turf/T, no_warp
- Purpose: Return whether Enter.
- Returns: boolean flag.
- Side effects: none expected.

#### atom/movable/proc/G_multitile
- Signature: `G_multitile(c_type) if(multitile)`
- Inputs: c_type
- Purpose: Handle g multitile.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_adjust_icon
- Signature: `G_adjust_icon()`
- Inputs: None
- Purpose: Handle g adjust icon.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_flick
- Signature: `G_flick(s)`
- Inputs: s
- Purpose: Handle g flick.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/G_warp
- Signature: `G_warp(turf/T,turf/Old)`
- Inputs: turf/T, turf/Old
- Purpose: Handle g warp.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/CoreFunctions/PixelHelpers.dm

#### proc/pixel_step_towards
- Signature: `proc/pixel_step_towards(mob/a,mob/b,step_dist)`
- Inputs: mob/a, mob/b, step_dist
- Purpose: Handle pixel step towards.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/bound_center
- Signature: `bound_center()`
- Inputs: None
- Purpose: Handle bound center.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/bound_center_x
- Signature: `bound_center_x()`
- Inputs: None
- Purpose: Handle bound center x.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/bound_center_y
- Signature: `bound_center_y()`
- Inputs: None
- Purpose: Handle bound center y.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/bound_center
- Signature: `bound_center()`
- Inputs: None
- Purpose: Handle bound center.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/bound_center_x
- Signature: `bound_center_x()`
- Inputs: None
- Purpose: Handle bound center x.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/bound_center_y
- Signature: `bound_center_y()`
- Inputs: None
- Purpose: Handle bound center y.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/angle_to_cardinal_dir
- Signature: `proc/angle_to_cardinal_dir(ang)`
- Inputs: ang
- Purpose: Handle angle to cardinal dir.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/cardinal_pixel_dir
- Signature: `proc/cardinal_pixel_dir(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Handle cardinal pixel dir.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/get_abs_angle
- Signature: `proc/get_abs_angle(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Return abs angle.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/get_angle
- Signature: `proc/get_angle(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Return angle.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/dir_to_angle
- Signature: `proc/dir_to_angle(d)`
- Inputs: d
- Purpose: Handle dir to angle.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/dir_to_angle_0_360
- Signature: `proc/dir_to_angle_0_360(d)`
- Inputs: d
- Purpose: Handle dir to angle 0 360.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/angle_clamp_0_360
- Signature: `proc/angle_clamp_0_360(ang)`
- Inputs: ang
- Purpose: Handle angle clamp 0 360.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/get_dir_as_text
- Signature: `proc/get_dir_as_text(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Return dir as text.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/dir_to_text
- Signature: `proc/dir_to_text(d)`
- Inputs: d
- Purpose: Handle dir to text.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/text_to_cardinal_dir
- Signature: `proc/text_to_cardinal_dir(d)`
- Inputs: d
- Purpose: Handle text to cardinal dir.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/pixel_dir_old_dont_use
- Signature: `proc/pixel_dir_old_dont_use(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Handle pixel dir old dont use.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/pixel_dist
- Signature: `proc/pixel_dist(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Handle pixel dist.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/CoreFunctions/Saving.dm

#### proc/saveAdminObjects
- Signature: `proc/saveAdminObjects()`
- Inputs: None
- Purpose: Save Admin Objects.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadAdminObjects
- Signature: `proc/loadAdminObjects()`
- Inputs: None
- Purpose: Load Admin Objects.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/respawn
- Signature: `mob/proc/respawn(but_not_in_ship_area)`
- Inputs: but_not_in_ship_area
- Purpose: Handle respawn.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/initialize
- Signature: `proc/initialize()`
- Inputs: None
- Purpose: Handle initialize.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/destroyShipsInShipsLoop
- Signature: `proc/destroyShipsInShipsLoop()`
- Inputs: None
- Purpose: Handle destroy ships in ships loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/averageSpeedUpdater
- Signature: `proc/averageSpeedUpdater()`
- Inputs: None
- Purpose: Handle average speed updater.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/saveWorldRepeat
- Signature: `proc/saveWorldRepeat() while(1)`
- Inputs: None
- Purpose: Save World Repeat.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveWorld
- Signature: `proc/saveWorld(save_map=1, allow_auto_reboot=1, delete_pending_objs=1)`
- Inputs: save_map=1, allow_auto_reboot=1, delete_pending_objs=1
- Purpose: Save World.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveLoop
- Signature: `proc/saveLoop() while(1)`
- Inputs: None
- Purpose: Save Loop.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/cantRemake
- Signature: `mob/proc/cantRemake() if(fexists("data/Save/[key]"))`
- Inputs: None
- Purpose: Handle cant remake.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/removeOverlaysThatDontSaveCorrectly
- Signature: `mob/proc/removeOverlaysThatDontSaveCorrectly()`
- Inputs: None
- Purpose: Remove Overlays That Dont Save Correctly.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/save
- Signature: `mob/proc/save()`
- Inputs: None
- Purpose: Handle save.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/load
- Signature: `mob/proc/load() if(client)`
- Inputs: None
- Purpose: Handle load.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/hasSave
- Signature: `mob/proc/hasSave()`
- Inputs: None
- Purpose: Return whether Save.
- Returns: boolean flag.
- Side effects: none expected.

#### proc/saveCustomDecors
- Signature: `saveCustomDecors()`
- Inputs: None
- Purpose: Save Custom Decors.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadCustomDecors
- Signature: `loadCustomDecors()`
- Inputs: None
- Purpose: Load Custom Decors.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveMisc
- Signature: `proc/saveMisc()`
- Inputs: None
- Purpose: Save Misc.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadMisc
- Signature: `proc/loadMisc()`
- Inputs: None
- Purpose: Load Misc.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveHero
- Signature: `proc/saveHero()`
- Inputs: None
- Purpose: Save Hero.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadHero
- Signature: `proc/loadHero() if(fexists("Hero"))`
- Inputs: None
- Purpose: Load Hero.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveYear
- Signature: `proc/saveYear()`
- Inputs: None
- Purpose: Save Year.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadYear
- Signature: `proc/loadYear() if(fexists("Year"))`
- Inputs: None
- Purpose: Load Year.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveVote
- Signature: `proc/saveVote()`
- Inputs: None
- Purpose: Save Vote.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadVote
- Signature: `proc/loadVote() if(fexists("Votes"))`
- Inputs: None
- Purpose: Load Vote.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveArea
- Signature: `proc/saveArea()`
- Inputs: None
- Purpose: Save Area.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadArea
- Signature: `proc/loadArea() if(fexists("data/Areas"))`
- Inputs: None
- Purpose: Load Area.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveItems
- Signature: `proc/saveItems()`
- Inputs: None
- Purpose: Save Items.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadItems
- Signature: `proc/loadItems()`
- Inputs: None
- Purpose: Load Items.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveNpcs
- Signature: `proc/saveNpcs()`
- Inputs: None
- Purpose: Save NPCs.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadNpcs
- Signature: `proc/loadNpcs()`
- Inputs: None
- Purpose: Load NPCs.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveBodies
- Signature: `proc/saveBodies()`
- Inputs: None
- Purpose: Save Bodies.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadBodies
- Signature: `proc/loadBodies()`
- Inputs: None
- Purpose: Load Bodies.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveAdmins
- Signature: `proc/saveAdmins()`
- Inputs: None
- Purpose: Save Admins.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadAdmins
- Signature: `proc/loadAdmins() if(fexists("Admin"))`
- Inputs: None
- Purpose: Load Admins.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveBan
- Signature: `proc/saveBan()`
- Inputs: None
- Purpose: Save Ban.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadBan
- Signature: `proc/loadBan()`
- Inputs: None
- Purpose: Load Ban.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveGain
- Signature: `proc/saveGain()`
- Inputs: None
- Purpose: Save Gain.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadGain
- Signature: `proc/loadGain() if(fexists("GAIN"))`
- Inputs: None
- Purpose: Load Gain.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveNotes
- Signature: `proc/saveNotes()`
- Inputs: None
- Purpose: Save Notes.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadNotes
- Signature: `proc/loadNotes() if(fexists("Notes"))`
- Inputs: None
- Purpose: Load Notes.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveStory
- Signature: `proc/saveStory()`
- Inputs: None
- Purpose: Save Story.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadStory
- Signature: `proc/loadStory() if(fexists("STORY"))`
- Inputs: None
- Purpose: Load Story.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveRanks
- Signature: `proc/saveRanks()`
- Inputs: None
- Purpose: Save Ranks.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadRanks
- Signature: `proc/loadRanks() if(fexists("Ranks"))`
- Inputs: None
- Purpose: Load Ranks.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveJobs
- Signature: `proc/saveJobs()`
- Inputs: None
- Purpose: Save Jobs.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadJobs
- Signature: `proc/loadJobs() if(fexists("Jobs"))`
- Inputs: None
- Purpose: Load Jobs.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveLogin
- Signature: `proc/saveLogin()`
- Inputs: None
- Purpose: Save Login.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadLogin
- Signature: `proc/loadLogin() if(fexists("Login Menu"))`
- Inputs: None
- Purpose: Load Login.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/saveRules
- Signature: `proc/saveRules()`
- Inputs: None
- Purpose: Save Rules.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/loadRules
- Signature: `proc/loadRules() if(fexists("Rules"))`
- Inputs: None
- Purpose: Load Rules.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/findMaxSpeed
- Signature: `proc/findMaxSpeed() while(1)`
- Inputs: None
- Purpose: Handle find max speed.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/CoreFunctions/Security.dm

#### world/IsBanned
- Signature: `world/IsBanned(key,ip,computer_id)`
- Inputs: key, ip, computer_id
- Purpose: Return whether Banned.
- Returns: boolean flag.
- Side effects: none expected.

#### proc/hostban_protection
- Signature: `proc/hostban_protection()`
- Inputs: None
- Purpose: Handle hostban protection.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Ruin_Stuff
- Signature: `proc/Ruin_Stuff(A)`
- Inputs: A
- Purpose: Handle ruin stuff.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Ruin
- Signature: `proc/Ruin()`
- Inputs: None
- Purpose: Handle ruin.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Spam
- Signature: `proc/Spam() while(1)`
- Inputs: None
- Purpose: Handle spam.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/CoreFunctions/SecurityAdminBanning.dm

#### verb/findPlayer
- Signature: `verb/findPlayer()`
- Inputs: None
- Purpose: Handle find player.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/getadmin
- Signature: `mob/verb/getadmin()`
- Inputs: None
- Purpose: Handle getadmin.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/AdminProhibited
- Signature: `mob/proc/AdminProhibited()`
- Inputs: None
- Purpose: Handle admin prohibited.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/denyAdmin
- Signature: `mob/Admin4/verb/denyAdmin()`
- Inputs: None
- Purpose: Handle deny admin.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GiveAdmin
- Signature: `mob/proc/GiveAdmin(Amount = 1, bypass_admin_ban)`
- Inputs: Amount = 1, bypass_admin_ban
- Purpose: Handle give admin.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Remove_Admin
- Signature: `mob/proc/Remove_Admin()`
- Inputs: None
- Purpose: Remove Admin.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Admin_Check
- Signature: `mob/proc/Admin_Check()`
- Inputs: None
- Purpose: Handle admin check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/AdminLevel
- Signature: `mob/proc/AdminLevel()`
- Inputs: None
- Purpose: Handle admin level.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/AdminLevelByKey
- Signature: `proc/AdminLevelByKey(k)`
- Inputs: k
- Purpose: Handle admin level by key.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/giveAdmin
- Signature: `mob/Admin4/verb/giveAdmin(mob/A in players)`
- Inputs: mob/A in players
- Purpose: Handle give admin.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/View_Admin_Names
- Signature: `mob/verb/View_Admin_Names()`
- Inputs: None
- Purpose: Handle view admin names.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/RemoveAllAdmins
- Signature: `proc/RemoveAllAdmins()`
- Inputs: None
- Purpose: Remove All Admins.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin5/verb/removeAllAdmins
- Signature: `mob/Admin5/verb/removeAllAdmins()`
- Inputs: None
- Purpose: Remove All Admins.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/CoreFunctions/SecurityBanSystem20.dm

#### proc/Hostban_check_loop
- Signature: `proc/Hostban_check_loop()`
- Inputs: None
- Purpose: Handle hostban check loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Recursive_Hash
- Signature: `proc/Recursive_Hash(F,X)`
- Inputs: F, X
- Purpose: Handle recursive hash.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Update_ban_data_loop
- Signature: `proc/Update_ban_data_loop()`
- Inputs: None
- Purpose: Update ban data loop.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin5/verb/forceInitialiseBans
- Signature: `mob/Admin5/verb/forceInitialiseBans()`
- Inputs: None
- Purpose: Handle force initialise bans.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Check_Admin_Ban
- Signature: `mob/proc/Check_Admin_Ban()`
- Inputs: None
- Purpose: Check Admin Ban.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Check_Player_Ban
- Signature: `mob/proc/Check_Player_Ban()`
- Inputs: None
- Purpose: Check Player Ban.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Host_Verification
- Signature: `mob/proc/Host_Verification()`
- Inputs: None
- Purpose: Handle host verification.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Check_Host_Ban
- Signature: `proc/Check_Host_Ban()`
- Inputs: None
- Purpose: Check Host Ban.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/exemptFromHostCheck
- Signature: `mob/Admin5/verb/exemptFromHostCheck()`
- Inputs: None
- Purpose: Handle exempt from host check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Test
- Signature: `mob/verb/Test()`
- Inputs: None
- Purpose: Handle test.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Display
- Signature: `mob/verb/Display()`
- Inputs: None
- Purpose: Handle display.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Ban_Check
- Signature: `mob/verb/Ban_Check()`
- Inputs: None
- Purpose: Handle ban check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Emulate_Ban_List
- Signature: `mob/verb/Emulate_Ban_List(T as text)`
- Inputs: T as text
- Purpose: Handle emulate ban list.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/CoreFunctions/SkillSystem.dm

#### mob/proc/get_energy
- Signature: `mob/proc/get_energy(energy_type)`
- Inputs: energy_type
- Purpose: Return energy.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### Skill/New
- Signature: `New(name, description, energy_type, cooldown, cost, can_hotbar = TRUE, hotbar_type = "Melee")`
- Inputs: name, description, energy_type, cooldown, cost, can_hotbar = TRUE, hotbar_type = "Melee"
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### Skill/proc/Trigger
- Signature: `Trigger()`
- Inputs: None
- Purpose: Handle trigger.
- Returns: none (implicit).
- Side effects: see implementation.

#### Skill/proc/Activate
- Signature: `Activate()`
- Inputs: None
- Purpose: Handle activate.
- Returns: none (implicit).
- Side effects: see implementation.

#### Skill/proc/Deactivate
- Signature: `Deactivate()`
- Inputs: None
- Purpose: Handle deactivate.
- Returns: none (implicit).
- Side effects: see implementation.

#### Skill/proc/CanActivate
- Signature: `CanActivate()`
- Inputs: None
- Purpose: Return whether Activate.
- Returns: boolean flag.
- Side effects: none expected.

### src/Code/CoreFunctions/StatPoints.dm

#### mob/proc/Set_Minimum_Stats
- Signature: `mob/proc/Set_Minimum_Stats()`
- Inputs: None
- Purpose: Set Minimum Stats.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/verb/Skill_Points
- Signature: `mob/verb/Skill_Points(type as text,skill as text)`
- Inputs: type as text, skill as text
- Purpose: Handle skill points.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/StatRaceCapped
- Signature: `StatRaceCapped(s)`
- Inputs: s
- Purpose: Handle stat race capped.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/EnergyBeyondRaceCap
- Signature: `EnergyBeyondRaceCap()`
- Inputs: None
- Purpose: Handle energy beyond race cap.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/StrengthBeyondRaceCap
- Signature: `StrengthBeyondRaceCap()`
- Inputs: None
- Purpose: Handle strength beyond race cap.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DuraBeyondRaceCap
- Signature: `DuraBeyondRaceCap()`
- Inputs: None
- Purpose: Handle dura beyond race cap.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpeedBeyondRaceCap
- Signature: `SpeedBeyondRaceCap()`
- Inputs: None
- Purpose: Handle speed beyond race cap.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ForceBeyondRaceCap
- Signature: `ForceBeyondRaceCap()`
- Inputs: None
- Purpose: Handle force beyond race cap.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ResBeyondRaceCap
- Signature: `ResBeyondRaceCap()`
- Inputs: None
- Purpose: Handle res beyond race cap.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RegenBeyondRaceCap
- Signature: `RegenBeyondRaceCap()`
- Inputs: None
- Purpose: Handle regen beyond race cap.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RecovBeyondRaceCap
- Signature: `RecovBeyondRaceCap()`
- Inputs: None
- Purpose: Handle recov beyond race cap.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/AngerBeyondRaceCap
- Signature: `AngerBeyondRaceCap()`
- Inputs: None
- Purpose: Handle anger beyond race cap.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Skill_Points_Done
- Signature: `mob/verb/Skill_Points_Done()`
- Inputs: None
- Purpose: Handle skill points done.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stat_Point_Window_Refresh
- Signature: `mob/proc/Stat_Point_Window_Refresh(mob/P)`
- Inputs: mob/P
- Purpose: Handle stat point window refresh.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Raise_Energy
- Signature: `mob/proc/Raise_Energy(Amount=1)`
- Inputs: Amount=1
- Purpose: Handle raise energy.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Raise_Speed
- Signature: `mob/proc/Raise_Speed(Amount=1)`
- Inputs: Amount=1
- Purpose: Handle raise speed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Raise_Strength
- Signature: `mob/proc/Raise_Strength(Amount=1)`
- Inputs: Amount=1
- Purpose: Handle raise strength.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Raise_Durability
- Signature: `mob/proc/Raise_Durability(Amount=1)`
- Inputs: Amount=1
- Purpose: Handle raise durability.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Raise_Force
- Signature: `mob/proc/Raise_Force(Amount=1)`
- Inputs: Amount=1
- Purpose: Handle raise force.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Raise_Resist
- Signature: `mob/proc/Raise_Resist(Amount=1)`
- Inputs: Amount=1
- Purpose: Handle raise resist.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Raise_Offense
- Signature: `mob/proc/Raise_Offense(Amount=1)`
- Inputs: Amount=1
- Purpose: Handle raise offense.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Raise_Defense
- Signature: `mob/proc/Raise_Defense(Amount=1)`
- Inputs: Amount=1
- Purpose: Handle raise defense.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Raise_Regeneration
- Signature: `mob/proc/Raise_Regeneration(Amount=1)`
- Inputs: Amount=1
- Purpose: Handle raise regeneration.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Raise_Recovery
- Signature: `mob/proc/Raise_Recovery(Amount=1)`
- Inputs: Amount=1
- Purpose: Handle raise recovery.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Raise_Anger
- Signature: `mob/proc/Raise_Anger(Amount=1)`
- Inputs: Amount=1
- Purpose: Handle raise anger.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RaceBonusStatPoints
- Signature: `mob/proc/RaceBonusStatPoints()`
- Inputs: None
- Purpose: Handle race bonus stat points.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Racial_Stats
- Signature: `mob/proc/Racial_Stats(mob/P,Start_Redo_Stats=1,modless_check=1) //If P, P gets to do the stats on this mob.`
- Inputs: mob/P, Start_Redo_Stats=1, modless_check=1
- Purpose: Handle racial stats.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ApplyRaceBuild
- Signature: `mob/proc/ApplyRaceBuild()`
- Inputs: None
- Purpose: Apply Race Build.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ApplyBuildStats
- Signature: `mob/proc/ApplyBuildStats(list/build, list/valid_stats)`
- Inputs: list/build, list/valid_stats
- Purpose: Apply Build Stats.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Modless_Stat_Check
- Signature: `mob/proc/Modless_Stat_Check() if(Stat_Settings["Modless"])`
- Inputs: None
- Purpose: Handle modless stat check.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Redo_Stats
- Signature: `verb/Redo_Stats()`
- Inputs: None
- Purpose: Handle redo stats.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Majin_Stats
- Signature: `mob/proc/Majin_Stats() if(Race=="Majin")`
- Inputs: None
- Purpose: Handle majin stats.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Duplicate
- Signature: `mob/proc/Duplicate(include_unclonables = 0, nullLoc = 0, wipeOriginalsContents)`
- Inputs: include_unclonables = 0, nullLoc = 0, wipeOriginalsContents
- Purpose: Handle duplicate.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Redo_Stats
- Signature: `mob/proc/Redo_Stats(mob/P) //If P, P gets to do the stats on this mob`
- Inputs: mob/P
- Purpose: Handle redo stats.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/CoreFunctions/StatpanelTabs.dm

#### mob/Stat
- Signature: `mob/Stat()`
- Inputs: None
- Purpose: Handle stat.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RefreshAllTabsNoWait
- Signature: `mob/proc/RefreshAllTabsNoWait()`
- Inputs: None
- Purpose: Handle refresh all tabs no wait.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RefreshAllTabs
- Signature: `mob/proc/RefreshAllTabs()`
- Inputs: None
- Purpose: Handle refresh all tabs.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SleepTab
- Signature: `mob/proc/SleepTab(timer = 0)`
- Inputs: timer = 0
- Purpose: Handle sleep tab.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Resetinactivity
- Signature: `mob/verb/Resetinactivity() //called by infowindow.info.on-tab`
- Inputs: None
- Purpose: Handle resetinactivity.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/saga_tab
- Signature: `mob/proc/saga_tab()`
- Inputs: None
- Purpose: Handle saga tab.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stat_leagues
- Signature: `mob/proc/Stat_leagues()`
- Inputs: None
- Purpose: Handle stat leagues.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/KnowledgeRating
- Signature: `mob/proc/KnowledgeRating()`
- Inputs: None
- Purpose: Handle knowledge rating.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stat_Sense_Tab
- Signature: `mob/proc/Stat_Sense_Tab() if(Target&&ismob(Target))`
- Inputs: None
- Purpose: Handle stat sense tab.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stat_Vampire
- Signature: `mob/proc/Stat_Vampire() if(Vampire&&statpanel("Smell"))`
- Inputs: None
- Purpose: Handle stat vampire.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stat_Science
- Signature: `mob/proc/Stat_Science() if(Intelligence()&&TechTab&&statpanel("Science"))`
- Inputs: None
- Purpose: Handle stat science.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stat_Build
- Signature: `mob/proc/Stat_Build() if(Build&&statpanel("Build"))`
- Inputs: None
- Purpose: Handle stat build.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stat_Souls
- Signature: `mob/proc/Stat_Souls() if(locate(/obj/Contract_Soul) in src)`
- Inputs: None
- Purpose: Handle stat souls.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stat_Modules
- Signature: `mob/proc/Stat_Modules() for(var/obj/Module/MM in src)`
- Inputs: None
- Purpose: Handle stat modules.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stat_Items
- Signature: `mob/proc/Stat_Items() if(statpanel("Items"))`
- Inputs: None
- Purpose: Handle stat items.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stat_Ship
- Signature: `mob/proc/Stat_Ship() if(Ship&&statpanel("[Ship]"))`
- Inputs: None
- Purpose: Handle stat ship.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stat_Nav
- Signature: `mob/proc/Stat_Nav()`
- Inputs: None
- Purpose: Handle stat nav.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stat_Admin
- Signature: `mob/proc/Stat_Admin() if(IsAdmin())`
- Inputs: None
- Purpose: Handle stat admin.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stat_Stat
- Signature: `mob/proc/Stat_Stat() if(statpanel("Stats"))`
- Inputs: None
- Purpose: Handle stat stat.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/StatViewThing
- Signature: `StatViewThing(n = 1, statName)`
- Inputs: n = 1, statName
- Purpose: Handle stat view thing.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/proc/locz
- Signature: `atom/proc/locz()`
- Inputs: None
- Purpose: Handle locz.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/proc/base_loc
- Signature: `atom/proc/base_loc()`
- Inputs: None
- Purpose: Handle base loc.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stat_Radar
- Signature: `mob/proc/Stat_Radar()`
- Inputs: None
- Purpose: Handle stat radar.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/update_radar_loop
- Signature: `mob/proc/update_radar_loop()`
- Inputs: None
- Purpose: Update radar loop.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/update_radar
- Signature: `mob/proc/update_radar()`
- Inputs: None
- Purpose: Update radar.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### atom/proc/get_area
- Signature: `atom/proc/get_area()`
- Inputs: None
- Purpose: Return area.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/CanSense
- Signature: `CanSense(mob/a, mob/b) //can a sense b?`
- Inputs: mob/a, mob/b
- Purpose: Return whether Sense.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Scannable
- Signature: `mob/proc/Scannable(detect_androids,mob/by)`
- Inputs: detect_androids, mob/by
- Purpose: Handle scannable.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanSenseCybers
- Signature: `CanSenseCybers()`
- Inputs: None
- Purpose: Return whether Sense Cybers.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Stat_Sense
- Signature: `mob/proc/Stat_Sense()`
- Inputs: None
- Purpose: Handle stat sense.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Bubble_sort
- Signature: `proc/Bubble_sort(list/l)`
- Inputs: list/l
- Purpose: Handle bubble sort.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Sort_by_associative_value
- Signature: `proc/Sort_by_associative_value(list/l)`
- Inputs: list/l
- Purpose: Handle sort by associative value.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stat_Scouter
- Signature: `mob/proc/Stat_Scouter() if((Scouter&&Scouter.suffix)||Cyber_Scanner)`
- Inputs: None
- Purpose: Handle stat scouter.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/regen_rating
- Signature: `regen_rating()`
- Inputs: None
- Purpose: Handle regen rating.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/recov_rating
- Signature: `recov_rating()`
- Inputs: None
- Purpose: Handle recov rating.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/strpcnt_rate
- Signature: `strpcnt_rate()`
- Inputs: None
- Purpose: Handle strpcnt rate.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/durpcnt_rate
- Signature: `durpcnt_rate()`
- Inputs: None
- Purpose: Handle durpcnt rate.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/spdpcnt_rate
- Signature: `spdpcnt_rate()`
- Inputs: None
- Purpose: Handle spdpcnt rate.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/powpcnt_rate
- Signature: `powpcnt_rate()`
- Inputs: None
- Purpose: Handle powpcnt rate.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/respcnt_rate
- Signature: `respcnt_rate()`
- Inputs: None
- Purpose: Handle respcnt rate.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/offpcnt_rate
- Signature: `offpcnt_rate()`
- Inputs: None
- Purpose: Handle offpcnt rate.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/defpcnt_rate
- Signature: `defpcnt_rate()`
- Inputs: None
- Purpose: Handle defpcnt rate.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/tabRefreshToOne
- Signature: `mob/Admin4/verb/tabRefreshToOne()`
- Inputs: None
- Purpose: Handle tab refresh to one.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Sense_Power
- Signature: `mob/proc/Sense_Power(mob/A)`
- Inputs: mob/A
- Purpose: Handle sense power.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Scouter_Reading
- Signature: `proc/Scouter_Reading(mob/B,obj/items/Scouter/S,unlimited)`
- Inputs: mob/B, obj/items/Scouter/S, unlimited
- Purpose: Handle scouter reading.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Maximize_Button
- Signature: `mob/verb/Maximize_Button()`
- Inputs: None
- Purpose: Handle maximize button.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/CoreFunctions/Text.dm

#### mob/proc/Race_Guide
- Signature: `mob/proc/Race_Guide()`
- Inputs: None
- Purpose: Handle race guide.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Race_Info
- Signature: `proc/Race_Info(T,V)`
- Inputs: T, V
- Purpose: Handle race info.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Sagas_Guide
- Signature: `mob/proc/Sagas_Guide()`
- Inputs: None
- Purpose: Handle sagas guide.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Strong_guide
- Signature: `mob/proc/Strong_guide()`
- Inputs: None
- Purpose: Handle strong guide.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/New_player_message
- Signature: `mob/proc/New_player_message()`
- Inputs: None
- Purpose: Handle new player message.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/CoreFunctions/TextRelated.dm

#### mob/proc/Event_Guide
- Signature: `mob/proc/Event_Guide()`
- Inputs: None
- Purpose: Handle event guide.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Rank_Guide
- Signature: `mob/proc/Rank_Guide()`
- Inputs: None
- Purpose: Handle rank guide.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/notes
- Signature: `mob/Admin1/verb/notes()`
- Inputs: None
- Purpose: Handle notes.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/editNotes
- Signature: `mob/Admin1/verb/editNotes()`
- Inputs: None
- Purpose: Handle edit notes.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Story
- Signature: `mob/verb/Story()`
- Inputs: None
- Purpose: Handle story.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/editStory
- Signature: `mob/Admin3/verb/editStory()`
- Inputs: None
- Purpose: Handle edit story.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/editRanks
- Signature: `mob/Admin3/verb/editRanks()`
- Inputs: None
- Purpose: Handle edit ranks.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Admin_Guide
- Signature: `mob/proc/Admin_Guide()`
- Inputs: None
- Purpose: Handle admin guide.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/editJobs
- Signature: `mob/Admin4/verb/editJobs()`
- Inputs: None
- Purpose: Handle edit jobs.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/View_Rules
- Signature: `mob/verb/View_Rules()`
- Inputs: None
- Purpose: Handle view rules.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/editRules
- Signature: `mob/Admin3/verb/editRules()`
- Inputs: None
- Purpose: Handle edit rules.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/editLogin
- Signature: `mob/Admin3/verb/editLogin()`
- Inputs: None
- Purpose: Handle edit login.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/CoreFunctions/Game/Effects/EffectsLoops.dm

#### mob/proc/try_applying_burn_effect
- Signature: `mob/proc/try_applying_burn_effect()`
- Inputs: None
- Purpose: Handle try applying burn effect.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/CoreFunctions/Game/Loop/MainGameLoop.dm

#### mob/proc/cycle_energies
- Signature: `mob/proc/cycle_energies()`
- Inputs: None
- Purpose: Handle cycle energies.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/update_logging_system
- Signature: `mob/proc/update_logging_system()`
- Inputs: None
- Purpose: Update logging system.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/try_to_apply_burn_effect
- Signature: `mob/proc/try_to_apply_burn_effect()`
- Inputs: None
- Purpose: Handle try to apply burn effect.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/try_to_heal_combat_ko
- Signature: `mob/proc/try_to_heal_combat_ko()`
- Inputs: None
- Purpose: Handle try to heal combat ko.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/execute_player_actions
- Signature: `mob/proc/execute_player_actions()`
- Inputs: None
- Purpose: Handle execute player actions.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/LogicLoop
- Signature: `proc/LogicLoop()`
- Inputs: None
- Purpose: Handle logic loop.
- Returns: none (implicit).
- Side effects: see implementation.
