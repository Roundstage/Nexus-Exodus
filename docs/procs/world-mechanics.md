# World Mechanics

## Overview
Auto-generated first-pass proc summaries based on signature names. Refine descriptions during refactors.

## Files
- `src/Code/WorldMechanics/BPResets.dm`
- `src/Code/WorldMechanics/BaseOrbs.dm`
- `src/Code/WorldMechanics/Battleground.dm`
- `src/Code/WorldMechanics/DeadZone.dm`
- `src/Code/WorldMechanics/DragonBalls.dm`
- `src/Code/WorldMechanics/Gravity.dm`
- `src/Code/WorldMechanics/Leagues.dm`
- `src/Code/WorldMechanics/LeaguesMainVillain.dm`
- `src/Code/WorldMechanics/OrbitingPlanet.dm`
- `src/Code/WorldMechanics/PlanetDestroy.dm`
- `src/Code/WorldMechanics/Sagas.dm`
- `src/Code/WorldMechanics/Space.dm`
- `src/Code/WorldMechanics/Tournament.dm`
- `src/Code/WorldMechanics/Vehicles.dm`
- `src/Code/WorldMechanics/WeatherDayNight/Areas.dm`
- `src/Code/WorldMechanics/WeatherDayNight/DayNight.dm`
- `src/Code/WorldMechanics/WeatherDayNight/Fireflies.dm`
- `src/Code/WorldMechanics/WeatherDayNight/Lighting.dm`
- `src/Code/WorldMechanics/Years.dm`

## Proc Reference

### src/Code/WorldMechanics/BPResets.dm

#### mob/Admin4/verb/resetBpToEarlyLevels
- Signature: `mob/Admin4/verb/resetBpToEarlyLevels()`
- Inputs: None
- Purpose: Handle reset bp to early levels.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ResetBP
- Signature: `proc/ResetBP()`
- Inputs: None
- Purpose: Handle reset bp.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/eraResetTestInformation
- Signature: `mob/Admin5/verb/eraResetTestInformation()`
- Inputs: None
- Purpose: Handle era reset test information.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/LoginResetBP
- Signature: `mob/proc/LoginResetBP()`
- Inputs: None
- Purpose: Handle login reset bp.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/WorldMechanics/BaseOrbs.dm

#### obj/Base_Orb/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Base_Orb/BP_Orb/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/NearBPOrb
- Signature: `NearBPOrb()`
- Inputs: None
- Purpose: Handle near bporb.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GenerateBPOrbs
- Signature: `GenerateBPOrbs()`
- Inputs: None
- Purpose: Handle generate bporbs.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GetRandomOrbLoc
- Signature: `GetRandomOrbLoc()`
- Inputs: None
- Purpose: Return Random Orb Loc.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/Admin4/verb/toggleBpOrbs
- Signature: `mob/Admin4/verb/toggleBpOrbs()`
- Inputs: None
- Purpose: Toggle BP Orbs.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/WorldMechanics/Battleground.dm

#### mob/proc/SpawnAtBattleGroundChoice
- Signature: `SpawnAtBattleGroundChoice()`
- Inputs: None
- Purpose: Spawn At Battle Ground Choice.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/GoToBattlegrounds
- Signature: `GoToBattlegrounds()`
- Inputs: None
- Purpose: Handle go to battlegrounds.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/AtBattlegrounds
- Signature: `AtBattlegrounds()`
- Inputs: None
- Purpose: Handle at battlegrounds.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BattlegroundDefeat
- Signature: `BattlegroundDefeat(mob/defeater)`
- Inputs: mob/defeater
- Purpose: Handle battleground defeat.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FindNewBattlegroundMaster
- Signature: `FindNewBattlegroundMaster(mob/new_master)`
- Inputs: mob/new_master
- Purpose: Handle find new battleground master.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/VerifyBattlegroundMaster
- Signature: `VerifyBattlegroundMaster()`
- Inputs: None
- Purpose: Handle verify battleground master.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BattlegroundMessage
- Signature: `BattlegroundMessage(t = "")`
- Inputs: t = ""
- Purpose: Handle battleground message.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/WorldMechanics/DeadZone.dm

#### obj/Portal_Graphic/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Become_inactive
- Signature: `proc/Become_inactive()`
- Inputs: None
- Purpose: Handle become inactive.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kaioshin_Portal/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Final_Realm_Portal/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Final_Realm_Portal
- Signature: `proc/Final_Realm_Portal() while(src)`
- Inputs: None
- Purpose: Handle final realm portal.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/DeadZone/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/proc/Dead_Zone
- Signature: `obj/proc/Dead_Zone() while(src)`
- Inputs: None
- Purpose: Handle dead zone.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Make_DeadZone_Amulet
- Signature: `verb/Make_DeadZone_Amulet()`
- Inputs: None
- Purpose: Handle make dead zone amulet.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use() if(!using)`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/WorldMechanics/DragonBalls.dm

#### mob/proc/Drop_dragonballs
- Signature: `mob/proc/Drop_dragonballs()`
- Inputs: None
- Purpose: Handle drop dragonballs.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DropShikon
- Signature: `mob/proc/DropShikon()`
- Inputs: None
- Purpose: Handle drop shikon.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/EnableDragonBallsLoop
- Signature: `proc/EnableDragonBallsLoop()`
- Inputs: None
- Purpose: Handle enable dragon balls loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ClosePowerGapBy
- Signature: `mob/proc/ClosePowerGapBy(amount=0.5, include_hbtc = 1)`
- Inputs: amount=0.5, include_hbtc = 1
- Purpose: Handle close power gap by.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/WishForPower
- Signature: `mob/proc/WishForPower(amount=0.5, no_strongest_increase)`
- Inputs: amount=0.5, no_strongest_increase
- Purpose: Handle wish for power.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/testWishForPower
- Signature: `mob/Admin5/verb/testWishForPower()`
- Inputs: None
- Purpose: Handle test wish for power.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Make_Dragon_Balls
- Signature: `verb/Make_Dragon_Balls()`
- Inputs: None
- Purpose: Handle make dragon balls.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/check_dragonballs
- Signature: `proc/check_dragonballs()`
- Inputs: None
- Purpose: Check dragonballs.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Dragon_Ball/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Alter_wishes
- Signature: `proc/Alter_wishes(n=-1)`
- Inputs: n=-1
- Purpose: Handle alter wishes.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DBs_Gathered
- Signature: `proc/DBs_Gathered()`
- Inputs: None
- Purpose: Handle dbs gathered.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DB_Planet_Check
- Signature: `proc/DB_Planet_Check()`
- Inputs: None
- Purpose: Handle db planet check.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Land
- Signature: `proc/Land()`
- Inputs: None
- Purpose: Handle land.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Scatter
- Signature: `proc/Scatter()`
- Inputs: None
- Purpose: Handle scatter.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Inert
- Signature: `proc/Inert(t=1)`
- Inputs: t=1
- Purpose: Handle inert.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/SetDBPixelOffsets
- Signature: `proc/SetDBPixelOffsets()`
- Inputs: None
- Purpose: Set DBPixel Offsets.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Drop_All
- Signature: `verb/Drop_All()`
- Inputs: None
- Purpose: Handle drop all.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Wish
- Signature: `verb/Wish()`
- Inputs: None
- Purpose: Handle wish.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Dragon_Ball/proc/End_Wishes
- Signature: `obj/items/Dragon_Ball/proc/End_Wishes()`
- Inputs: None
- Purpose: Handle end wishes.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Toggle_immortality
- Signature: `mob/proc/Toggle_immortality()`
- Inputs: None
- Purpose: Toggle immortality.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/WorldMechanics/Gravity.dm

#### mob/proc/Start_Gravity_Loops
- Signature: `mob/proc/Start_Gravity_Loops()`
- Inputs: None
- Purpose: Start Gravity Loops.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Gravity_Mastery
- Signature: `mob/proc/Gravity_Mastery()`
- Inputs: None
- Purpose: Handle gravity mastery.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Gravity_Damage
- Signature: `mob/proc/Gravity_Damage()`
- Inputs: None
- Purpose: Handle gravity damage.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Gravity_Update_Loop
- Signature: `mob/proc/Gravity_Update_Loop()`
- Inputs: None
- Purpose: Handle gravity update loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Gravity_Update
- Signature: `mob/proc/Gravity_Update()`
- Inputs: None
- Purpose: Handle gravity update.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Planet_Gravity
- Signature: `mob/proc/Planet_Gravity()`
- Inputs: None
- Purpose: Handle planet gravity.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Gravity/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade_health
- Signature: `verb/Upgrade_health()`
- Inputs: None
- Purpose: Handle upgrade health.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Deactivate
- Signature: `proc/Deactivate()`
- Inputs: None
- Purpose: Handle deactivate.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Gravity/Click
- Signature: `Click() if(usr in range(1,src))`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Bolt
- Signature: `verb/Bolt()`
- Inputs: None
- Purpose: Handle bolt.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Bolt
- Signature: `mob/proc/Bolt(obj/O)`
- Inputs: obj/O
- Purpose: Handle bolt.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/WorldMechanics/Leagues.dm

#### mob/verb/Create_League
- Signature: `mob/verb/Create_League()`
- Inputs: None
- Purpose: Create League.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Same_league_cant_kill
- Signature: `proc/Same_league_cant_kill(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Handle same league cant kill.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/League_turret_IDs
- Signature: `mob/proc/League_turret_IDs()`
- Inputs: None
- Purpose: Handle league turret ids.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Get_league_drone_IDs
- Signature: `mob/proc/Get_league_drone_IDs()`
- Inputs: None
- Purpose: Return league drone IDs.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Get_league_nully_IDs
- Signature: `mob/proc/Get_league_nully_IDs()`
- Inputs: None
- Purpose: Return league nully IDs.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### obj/League/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/League/proc/league_update_loop
- Signature: `league_update_loop()`
- Inputs: None
- Purpose: Handle league update loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/League/proc/update_league
- Signature: `update_league()`
- Inputs: None
- Purpose: Update league.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### obj/League/proc/league_announce
- Signature: `league_announce(msg)`
- Inputs: msg
- Purpose: Handle league announce.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/league_chat
- Signature: `verb/league_chat(msg as text)`
- Inputs: msg as text
- Purpose: Handle league chat.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/League/Click
- Signature: `Click() if(src in usr)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/WorldMechanics/LeaguesMainVillain.dm

#### proc/Count_villain_league_members
- Signature: `proc/Count_villain_league_members()`
- Inputs: None
- Purpose: Handle count villain league members.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Count_villain_league_unique_members
- Signature: `proc/Count_villain_league_unique_members()`
- Inputs: None
- Purpose: Handle count villain league unique members.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Villain_league_damage_multiplier
- Signature: `mob/proc/Villain_league_damage_multiplier(mob/target)`
- Inputs: mob/target
- Purpose: Handle villain league damage multiplier.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Villain_league_member_count_loop
- Signature: `proc/Villain_league_member_count_loop()`
- Inputs: None
- Purpose: Handle villain league member count loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Villain_league_paycheck_amount
- Signature: `proc/Villain_league_paycheck_amount()`
- Inputs: None
- Purpose: Handle villain league paycheck amount.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/League_paychecks
- Signature: `proc/League_paychecks()`
- Inputs: None
- Purpose: Handle league paychecks.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/WorldMechanics/OrbitingPlanet.dm

#### obj/Orbiter/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Orbiter/proc/Orbit
- Signature: `Orbit()`
- Inputs: None
- Purpose: Handle orbit.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/WorldMechanics/PlanetDestroy.dm

#### mob/Admin3/verb/restorePlanet
- Signature: `mob/Admin3/verb/restorePlanet()`
- Inputs: None
- Purpose: Handle restore planet.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Planet_Destroy/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Planet_Destroy
- Signature: `verb/Planet_Destroy()`
- Inputs: None
- Purpose: Handle planet destroy.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_lightning_strike
- Signature: `proc/Get_lightning_strike()`
- Inputs: None
- Purpose: Return lightning strike.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/Lightning_strike
- Signature: `proc/Lightning_strike()`
- Inputs: None
- Purpose: Handle lightning strike.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Lightning_Strike/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Lightning_Strike/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/can_planet_destroy
- Signature: `mob/proc/can_planet_destroy()`
- Inputs: None
- Purpose: Return whether planet destroy.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/Admin4/verb/disablePlanet
- Signature: `mob/Admin4/verb/disablePlanet()`
- Inputs: None
- Purpose: Handle disable planet.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/hide_destroyed_planets
- Signature: `proc/hide_destroyed_planets(planet)`
- Inputs: planet
- Purpose: Handle hide destroyed planets.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/unhide_restored_planets
- Signature: `proc/unhide_restored_planets(planet)`
- Inputs: planet
- Purpose: Handle unhide restored planets.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/destroy_planet
- Signature: `proc/destroy_planet(planet, power = 1, force = 1)`
- Inputs: planet, snapshotted attacker BP, and snapshotted Force.
- Purpose: Destroy the planet while limiting random player hazards to ten factor-2 hits, or factor 20 per victim, through the central Ki formula.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/restore_planet
- Signature: `proc/restore_planet(planet)`
- Inputs: planet
- Purpose: Handle restore planet.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/restore_all_planets
- Signature: `proc/restore_all_planets()`
- Inputs: None
- Purpose: Handle restore all planets.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/proc/is_on_destroyed_planet
- Signature: `atom/proc/is_on_destroyed_planet()`
- Inputs: None
- Purpose: Return whether on destroyed planet.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/logged_in_on_destroyed_planet_check
- Signature: `mob/proc/logged_in_on_destroyed_planet_check() if(is_on_destroyed_planet())`
- Inputs: None
- Purpose: Handle logged in on destroyed planet check.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Ship_on_destroyed_planet_loop
- Signature: `proc/Ship_on_destroyed_planet_loop()`
- Inputs: None
- Purpose: Handle ship on destroyed planet loop.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/WorldMechanics/Sagas.dm

#### proc/find_new_hero
- Signature: `find_new_hero(mob/old_hero)`
- Inputs: mob/old_hero
- Purpose: Handle find new hero.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/find_new_villain
- Signature: `find_new_villain(mob/old_villain,mob/villain_killer)`
- Inputs: mob/old_villain, mob/villain_killer
- Purpose: Handle find new villain.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/sagas_bonus
- Signature: `sagas_bonus(mob/a,mob/b) //a = attacker. b = defender`
- Inputs: mob/a, mob/b
- Purpose: Handle sagas bonus.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ToggleIgnoreHero
- Signature: `ToggleIgnoreHero()`
- Inputs: None
- Purpose: Toggle Ignore Hero.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/ToggleIgnoreVillain
- Signature: `ToggleIgnoreVillain()`
- Inputs: None
- Purpose: Toggle Ignore Villain.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/ChangeAlignment
- Signature: `ChangeAlignment(a = "Good")`
- Inputs: a = "Good"
- Purpose: Handle change alignment.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Hero_eligible
- Signature: `Hero_eligible()`
- Inputs: None
- Purpose: Handle hero eligible.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Villain_eligible
- Signature: `Villain_eligible()`
- Inputs: None
- Purpose: Handle villain eligible.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/killing_spree_loop
- Signature: `killing_spree_loop()`
- Inputs: None
- Purpose: Handle killing spree loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/villain_timer
- Signature: `villain_timer()`
- Inputs: None
- Purpose: Handle villain timer.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/hero_seniority_check
- Signature: `hero_seniority_check()`
- Inputs: None
- Purpose: Handle hero seniority check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/villain_seniority_check
- Signature: `villain_seniority_check()`
- Inputs: None
- Purpose: Handle villain seniority check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/hero_death
- Signature: `hero_death(mob/killer) if(key && hero == key&&sagas)`
- Inputs: mob/killer
- Purpose: Handle hero death.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/villain_death
- Signature: `villain_death(mob/m) if(key && villain==key && sagas)`
- Inputs: mob/m
- Purpose: Handle villain death.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/reset_villain_stuff
- Signature: `reset_villain_stuff()`
- Inputs: None
- Purpose: Handle reset villain stuff.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/remove_villain_verbs
- Signature: `remove_villain_verbs()`
- Inputs: None
- Purpose: Remove villain verbs.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/add_villain_verbs
- Signature: `add_villain_verbs()`
- Inputs: None
- Purpose: Add villain verbs.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/training_period
- Signature: `training_period(mob/d) //d = defender. src = attacker`
- Inputs: mob/d
- Purpose: Handle training period.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/can_threaten
- Signature: `can_threaten()`
- Inputs: None
- Purpose: Return whether threaten.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/villain/verb/Threaten_Hero
- Signature: `Threaten_Hero()`
- Inputs: None
- Purpose: Handle threaten hero.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/WorldMechanics/Space.dm

#### proc/Get_ship_interior
- Signature: `proc/Get_ship_interior()`
- Inputs: None
- Purpose: Return ship interior.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/Admin4/verb/planets
- Signature: `mob/Admin4/verb/planets()`
- Inputs: None
- Purpose: Handle planets.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Planets/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Planets/Earth/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Planets/Namekian/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Planets/Braal/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Planets/Arconia/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Planets/Ice/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Planets/Desert/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Planets/Jungle/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Planets/Android/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Bump_Planet
- Signature: `proc/Bump_Planet(obj/Planets/Planet,obj/Ships/Bumper)`
- Inputs: obj/Planets/Planet, obj/Ships/Bumper
- Purpose: Handle bump planet.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/Ship_Interior_Reset
- Signature: `turf/proc/Ship_Interior_Reset(nonce, turf/Loc)`
- Inputs: nonce, turf/Loc
- Purpose: Handle ship interior reset.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Ship_exit/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Controls/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/check_ship_hiders
- Signature: `proc/check_ship_hiders()`
- Inputs: None
- Purpose: Check ship hiders.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/find_ship
- Signature: `proc/find_ship()`
- Inputs: None
- Purpose: Handle find ship.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Ship_Interior_Reset
- Signature: `proc/Ship_Interior_Reset(turf/Loc)`
- Inputs: turf/Loc
- Purpose: Handle ship interior reset.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Ship_Options
- Signature: `proc/Ship_Options(mob/M) if(M.client&&(M in view(1,src)))`
- Inputs: mob/M
- Purpose: Handle ship options.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Exit_Ship
- Signature: `proc/Exit_Ship(mob/M,obj/origin) if(M in view(1,origin))`
- Inputs: mob/M, obj/origin
- Purpose: Handle exit ship.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/max_ship_upgrade
- Signature: `mob/proc/max_ship_upgrade()`
- Inputs: None
- Purpose: Handle max ship upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Toggle_Comms
- Signature: `verb/Toggle_Comms()`
- Inputs: None
- Purpose: Toggle Comms.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### verb/Mount_Weapon
- Signature: `verb/Mount_Weapon()`
- Inputs: None
- Purpose: Handle mount weapon.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Repair
- Signature: `verb/Repair()`
- Inputs: None
- Purpose: Handle repair.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Refuel
- Signature: `verb/Refuel() //Add fuel to the ship`
- Inputs: None
- Purpose: Handle refuel.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Ships/Move
- Signature: `Move(NewLoc,Dir=0,step_x=0,step_y=0)`
- Inputs: NewLoc, Dir=0, step_x=0, step_y=0
- Purpose: Handle move.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Pod_Edge_Check
- Signature: `proc/Pod_Edge_Check(turf/Former_Location)`
- Inputs: turf/Former_Location
- Purpose: Handle pod edge check.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Door_Check
- Signature: `proc/Door_Check(turf/Former_Location) for(var/obj/Turfs/Door/A in loc) if(A.density)`
- Inputs: turf/Former_Location
- Purpose: Handle door check.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Fuel
- Signature: `proc/Fuel()`
- Inputs: None
- Purpose: Handle fuel.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Ship_Weapon_Fire
- Signature: `proc/Ship_Weapon_Fire()`
- Inputs: None
- Purpose: Handle ship weapon fire.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/MoveReset
- Signature: `proc/MoveReset()`
- Inputs: None
- Purpose: Handle move reset.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Ships/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Ships/Bump
- Signature: `Bump(obj/A)`
- Inputs: obj/A
- Purpose: Handle bump.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Ships/Ship/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Ships/Ship/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Ships/Spacepod/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Ships/Spacepod/Move
- Signature: `Move()`
- Inputs: None
- Purpose: Handle move.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Pod_Trail
- Signature: `proc/Pod_Trail()`
- Inputs: None
- Purpose: Handle pod trail.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Set_DNA_Verification
- Signature: `verb/Set_DNA_Verification()`
- Inputs: None
- Purpose: Set DNA Verification.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Move_Randomly
- Signature: `verb/Move_Randomly()`
- Inputs: None
- Purpose: Handle move randomly.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Ships/Spacepod/Click
- Signature: `Click(location)`
- Inputs: location
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/Pod_Trail
- Signature: `turf/proc/Pod_Trail()`
- Inputs: None
- Purpose: Handle pod trail.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Liftoff
- Signature: `proc/Liftoff(obj/Ships/O) for(var/area/B in range(0,O))`
- Inputs: obj/Ships/O
- Purpose: Handle liftoff.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/SpaceDebris/Bump
- Signature: `Bump(atom/A)`
- Inputs: atom/A
- Purpose: Handle bump.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Meteor_fly
- Signature: `proc/Meteor_fly(move_delay = 1)`
- Inputs: move_delay = 1
- Purpose: Handle meteor fly.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/SpaceDebris/Asteroid/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/SpaceDebris/Asteroid/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/SpaceDebris/Meteor/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/SpaceDebris/Meteor/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/WorldMechanics/Tournament.dm

#### obj/Tournament_Controls/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Tournament_Controls/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin2/verb/setTournamentInterval
- Signature: `mob/Admin2/verb/setTournamentInterval()`
- Inputs: None
- Purpose: Set Tournament Interval.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin2/verb/startTournament
- Signature: `mob/Admin2/verb/startTournament()`
- Inputs: None
- Purpose: Start Tournament.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Tournament_Loop
- Signature: `proc/Tournament_Loop()`
- Inputs: None
- Purpose: Handle tournament loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Tournament_Alt
- Signature: `mob/proc/Tournament_Alt(list/L)`
- Inputs: list/L
- Purpose: Handle tournament alt.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Join_Prompt
- Signature: `proc/Join_Prompt()`
- Inputs: None
- Purpose: Handle join prompt.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_Fighter_Locations
- Signature: `proc/Get_Fighter_Locations(list/L)`
- Inputs: list/L
- Purpose: Return Fighter Locations.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### obj/Fighter_Spot /You place 2 of these at the appropriate spots in the arena, it's where the 2 opponents spawn/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/proc/tournament_override
- Signature: `atom/proc/tournament_override(fighters_can=1,show_message=1) //used to override attacks and such during a tournament`
- Inputs: fighters_can=1, show_message=1
- Purpose: Handle tournament override.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Find_Tourny_Chair
- Signature: `mob/proc/Find_Tourny_Chair()`
- Inputs: None
- Purpose: Handle find tourny chair.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Shuffle
- Signature: `proc/Shuffle(list/L)`
- Inputs: list/L
- Purpose: Handle shuffle.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Tourny_Range
- Signature: `mob/proc/Tourny_Range(r=25)`
- Inputs: r=25
- Purpose: Handle tourny range.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Detect_tournament_runners
- Signature: `proc/Detect_tournament_runners()`
- Inputs: None
- Purpose: Handle detect tournament runners.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Dragged_out
- Signature: `mob/proc/Dragged_out()`
- Inputs: None
- Purpose: Handle dragged out.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Tournament
- Signature: `proc/Tournament(Prize=0,Deathmatch) if(!Tournament)`
- Inputs: Prize=0, Deathmatch
- Purpose: Handle tournament.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Lost_the_fight_against
- Signature: `mob/proc/Lost_the_fight_against(mob/m, fight_time=0)`
- Inputs: mob/m, fight_time=0
- Purpose: Handle lost the fight against.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/WorldMechanics/WeatherDayNight/Areas.dm

#### proc/RestrictedMapLoop
- Signature: `RestrictedMapLoop()`
- Inputs: None
- Purpose: Handle restricted map loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/OnRestrictedMap
- Signature: `OnRestrictedMap()`
- Inputs: None
- Purpose: Handle on restricted map.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GoToDeathSpawn
- Signature: `GoToDeathSpawn()`
- Inputs: None
- Purpose: Handle go to death spawn.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GoToBindSpawn
- Signature: `GoToBindSpawn()`
- Inputs: None
- Purpose: Handle go to bind spawn.
- Returns: none (implicit).
- Side effects: see implementation.

#### area/Enter
- Signature: `Enter(mob/m)`
- Inputs: mob/m
- Purpose: Handle enter.
- Returns: none (implicit).
- Side effects: see implementation.

#### area/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Poison_gas_loop
- Signature: `proc/Poison_gas_loop()`
- Inputs: None
- Purpose: Handle poison gas loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Space_meteors_loop
- Signature: `proc/Space_meteors_loop(delay_override=0)`
- Inputs: delay_override=0
- Purpose: Handle space meteors loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### area/Space/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### area/Braal_Core/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Weather
- Signature: `proc/Weather() while(1)`
- Inputs: None
- Purpose: Handle weather.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/WorldMechanics/WeatherDayNight/DayNight.dm

#### mob/Admin2/verb/changeDayNight
- Signature: `mob/Admin2/verb/changeDayNight(turf/t in world)`
- Inputs: turf/t in world
- Purpose: Handle change day night.
- Returns: none (implicit).
- Side effects: see implementation.

#### area/proc/DayNightLoop
- Signature: `DayNightLoop()`
- Inputs: None
- Purpose: Handle day night loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### area/proc/FadeToNight
- Signature: `FadeToNight()`
- Inputs: None.
- Purpose: Transition clients in the area through dusk into the area's dark ambient color.
- Returns: none (implicit).
- Side effects: enables local light sources and fireflies and invalidates older overlapping transitions.

#### area/proc/FadeToDay
- Signature: `FadeToDay()`
- Inputs: None.
- Purpose: Transition clients in the area through dawn back to neutral daylight.
- Returns: none (implicit).
- Side effects: fades local light sources and fireflies and invalidates older overlapping transitions.

### src/Code/WorldMechanics/WeatherDayNight/Fireflies.dm

#### proc/GenerateFireflyIcons
- Signature: `GenerateFireflyIcons()`
- Inputs: None
- Purpose: Handle generate firefly icons.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ScatterFirefliesRandomlyOnMap
- Signature: `ScatterFirefliesRandomlyOnMap()`
- Inputs: None
- Purpose: Handle scatter fireflies randomly on map.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/RandomFireflyLocation
- Signature: `RandomFireflyLocation()`
- Inputs: None
- Purpose: Handle random firefly location.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ToggleAreaFireflies
- Signature: `ToggleAreaFireflies(area/a, tog = 0)`
- Inputs: area/a, tog = 0
- Purpose: Toggle Area Fireflies.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### obj/Fireflies/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Fireflies/proc/FirefliesFadeIn
- Signature: `FirefliesFadeIn(timer = 300, delay = 0)`
- Inputs: timer = 300, delay = 0
- Purpose: Handle fireflies fade in.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Fireflies/proc/FirefliesFadeOut
- Signature: `FirefliesFadeOut(timer = 300, delay = 0)`
- Inputs: timer = 300, delay = 0
- Purpose: Handle fireflies fade out.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Fireflies/proc/DecideOnOrOff
- Signature: `DecideOnOrOff()`
- Inputs: None
- Purpose: Handle decide on or off.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Fireflies/proc/GenerateFireflies
- Signature: `GenerateFireflies()`
- Inputs: None
- Purpose: Handle generate fireflies.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Fireflies/proc/AddFirefliesToList
- Signature: `AddFirefliesToList()`
- Inputs: None
- Purpose: Add Fireflies To List.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/WorldMechanics/WeatherDayNight/Lighting.dm

#### proc/getNexusAmbientMatrix
- Signature: `getNexusAmbientMatrix(ambient_color)`
- Purpose: Build the BYOND color matrix used by the multiplicative client lighting plane.

#### proc/updateAreaNexusLighting
- Signature: `updateAreaNexusLighting(area/a, ambient_color, fade_time = 0)`
- Purpose: Apply an ambient transition only to clients currently inside an area.

#### client/proc/initializeNexusLighting
- Signature: `initializeNexusLighting()`
- Purpose: Add one plane-master darkness screen to the client and synchronize it to the current area.

#### client/proc/syncNexusLighting
- Signature: `syncNexusLighting(area/target_area)`
- Purpose: Select neutral daylight or the current area's night color, respecting the client's lighting toggle.

#### atom/movable/proc/setNexusGlow
- Signature: `setNexusGlow(light_color = "#ffffff", size = 2, light_alpha = 180, light_icon = 'TorchLightCircle.dmi')`
- Purpose: Attach one reusable additive light emitter to a moving atom.

#### atom/movable/proc/pulseNexusGlow
- Signature: `pulseNexusGlow(light_color = "#ffffff", size = 2, light_alpha = 180, duration = 8, light_icon = 'TorchLightCircle.dmi')`
- Purpose: Render and automatically remove a short impact or charge light pulse.

#### atom/movable/proc/setNexusActionGlow
- Signature: `setNexusActionGlow(light_color = "#ffffff", size = 2, light_alpha = 180, light_icon = 'TorchLightCircle.dmi')`
- Purpose: Attach a second reusable emitter for beam charging and temporary actions without replacing a transformation glow.

#### mob/verb/toggleNexusLighting
- Signature: `toggleNexusLighting()`
- Purpose: Let a player disable or enable dynamic screen lighting locally.

#### mob/Admin2/verb/testNexusLighting
- Signature: `testNexusLighting()`
- Purpose: Test day/night transitions and representative attack/transformation glows without granting skills.

#### mob/Admin2/verb/setMaximumDarkness
- Signature: `setMaximumDarkness()`
- Purpose: Apply full black ambient light to the current area immediately so additive emitters can be inspected in isolation.

#### mob/Admin2/verb/testNexusGlow
- Signature: `testNexusGlow()`
- Purpose: Attach a maximum-intensity white test glow to the admin for ten seconds.

#### mob/Admin2/verb/testNexusBlast
- Signature: `testNexusBlast()`
- Purpose: Launch a harmless cyan projectile with persistent flight light and an impact pulse.

#### proc/FadeOutLights
- Signature: `FadeOutLights(area/a)`
- Inputs: area/a
- Purpose: Handle fade out lights.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/FadeInLights
- Signature: `FadeInLights(area/a)`
- Inputs: area/a
- Purpose: Handle fade in lights.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/proc/FadeLightOut
- Signature: `FadeLightOut(time = 0)`
- Inputs: time = 0
- Purpose: Handle fade light out.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/proc/FadeLightIn
- Signature: `FadeLightIn(time = 0)`
- Inputs: time = 0
- Purpose: Handle fade light in.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/LightSource/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/LightSource/proc/FadeOutLight
- Signature: `FadeOutLight(n = 100)`
- Inputs: n = 100
- Purpose: Handle fade out light.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/LightSource/proc/FadeInLight
- Signature: `FadeInLight(n = 100)`
- Inputs: n = 100
- Purpose: Handle fade in light.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/proc/RemoveLightSource
- Signature: `RemoveLightSource()`
- Inputs: None
- Purpose: Remove Light Source.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### obj/proc/GiveLightSource
- Signature: `GiveLightSource(size = 1, max_alpha = 60, light_color = rgb(255,255,255), auto_fade = 1, light_icon = 'TorchLightCircle.dmi')`
- Inputs: size = 1, max_alpha = 60, light_color = rgb(255, 255, 255
- Purpose: Handle give light source.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/WorldMechanics/Years.dm

#### mob/Admin4/verb/yearSpeed
- Signature: `mob/Admin4/verb/yearSpeed()`
- Inputs: None
- Purpose: Handle year speed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Years
- Signature: `proc/Years()`
- Inputs: None
- Purpose: Handle years.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Gray_Hair
- Signature: `mob/proc/Gray_Hair() if(!buffed())`
- Inputs: None
- Purpose: Handle gray hair.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Age_Update
- Signature: `mob/proc/Age_Update()`
- Inputs: None
- Purpose: Handle age update.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/decline_gains
- Signature: `mob/proc/decline_gains()`
- Inputs: None
- Purpose: Handle decline gains.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/decline_body_divisor
- Signature: `mob/proc/decline_body_divisor()`
- Inputs: None
- Purpose: Handle decline body divisor.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Body
- Signature: `mob/proc/Body()`
- Inputs: None
- Purpose: Handle body.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Lifespan
- Signature: `mob/proc/Lifespan()`
- Inputs: None
- Purpose: Handle lifespan.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Update_Decline
- Signature: `mob/proc/Update_Decline() if(!buffed())`
- Inputs: None
- Purpose: Update Decline.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Die
- Signature: `mob/proc/Die() if(!Immortal&&!Dead) //from old age`
- Inputs: None
- Purpose: Handle die.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Add_Decline
- Signature: `mob/proc/Add_Decline(N=0)`
- Inputs: N=0
- Purpose: Add Decline.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Mult_Decline
- Signature: `mob/proc/Mult_Decline(N=1)`
- Inputs: N=1
- Purpose: Handle mult decline.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Mate
- Signature: `verb/Mate()`
- Inputs: None
- Purpose: Handle mate.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Can_Mate
- Signature: `mob/proc/Can_Mate()`
- Inputs: None
- Purpose: Return whether Mate.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Mate
- Signature: `mob/proc/Mate(obj/Mate/M)`
- Inputs: obj/Mate/M
- Purpose: Handle mate.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Mate_Graphics
- Signature: `mob/proc/Mate_Graphics(mob/M)`
- Inputs: mob/M
- Purpose: Handle mate graphics.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Mate_Check
- Signature: `mob/proc/Mate_Check()`
- Inputs: None
- Purpose: Handle mate check.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Found_Most
- Signature: `proc/Found_Most(var/list/L) if(L&&L.len)`
- Inputs: var/list/L
- Purpose: Handle found most.
- Returns: none (implicit).
- Side effects: see implementation.
