# Technology

## Overview
Auto-generated first-pass proc summaries based on signature names. Refine descriptions during refactors.

## Files
- `src/Code/Technology/BodySwap.dm`
- `src/Code/Technology/Bombs.dm`
- `src/Code/Technology/CyberDrones.dm`
- `src/Code/Technology/Cybernetics.dm`
- `src/Code/Technology/GunCustomization.dm`
- `src/Code/Technology/Guns.dm`
- `src/Code/Technology/LandMine.dm`
- `src/Code/Technology/NewDrones.dm`
- `src/Code/Technology/Shurikens.dm`
- `src/Code/Technology/SmokeBomb.dm`
- `src/Code/Technology/Technology.dm`
- `src/Code/Technology/Vampires.dm`
- `src/Code/Technology/Zombies.dm`

## Proc Reference

### src/Code/Technology/BodySwap.dm

#### proc/Switch_Bodies
- Signature: `proc/Switch_Bodies(mob/A,mob/P,save_override)`
- Inputs: mob/A, mob/P, save_override
- Purpose: Handle switch bodies.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ActiveBodySwapsNullLocLoop
- Signature: `proc/ActiveBodySwapsNullLocLoop()`
- Inputs: None
- Purpose: Handle active body swaps null loc loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BodySwapVictim
- Signature: `mob/proc/BodySwapVictim()`
- Inputs: None
- Purpose: Handle body swap victim.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/RecordActiveBodySwap
- Signature: `RecordActiveBodySwap(mob/temp_body, mob/user, mob/other_player)`
- Inputs: mob/temp_body, mob/user, mob/other_player
- Purpose: Handle record active body swap.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Body_Swap
- Signature: `verb/Body_Swap()`
- Inputs: None
- Purpose: Handle body swap.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BodySwapTimeLimitLoop
- Signature: `mob/proc/BodySwapTimeLimitLoop()`
- Inputs: None
- Purpose: Handle body swap time limit loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/body_swapped
- Signature: `mob/proc/body_swapped()`
- Inputs: None
- Purpose: Handle body swapped.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Bebi_Undo
- Signature: `mob/proc/Bebi_Undo(logout) //Undoes the effects of Bebi taking over someone's body`
- Inputs: logout
- Purpose: Handle bebi undo.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Logout_and_delete_bebi
- Signature: `mob/proc/Logout_and_delete_bebi(mob/m)`
- Inputs: mob/m
- Purpose: Handle logout and delete bebi.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Technology/Bombs.dm

#### area/proc/Area_Nuke
- Signature: `area/proc/Area_Nuke() if(icon!='Lightning flash.dmi')`
- Inputs: None
- Purpose: Handle area nuke.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Nuke_Icons
- Signature: `proc/Nuke_Icons(obj/F)`
- Inputs: obj/F
- Purpose: Handle nuke icons.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/Nuke
- Signature: `turf/proc/Nuke(BP,Force,Range,Amount)`
- Inputs: BP, Force, Range, Amount
- Purpose: Handle nuke.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Nuke_Walk
- Signature: `proc/Nuke_Walk()`
- Inputs: None
- Purpose: Handle nuke walk.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blast/Fireball/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Nuke_Attack_Mobs
- Signature: `proc/Nuke_Attack_Mobs()`
- Inputs: None
- Purpose: Handle nuke attack mobs.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Nuke_Attack_Objs
- Signature: `proc/Nuke_Attack_Objs()`
- Inputs: None
- Purpose: Handle nuke attack objs.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Nuke_Attack_Turf
- Signature: `proc/Nuke_Attack_Turf()`
- Inputs: None
- Purpose: Handle nuke attack turf.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blast/Fireball/Move
- Signature: `Move()`
- Inputs: None
- Purpose: Handle move.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade_health
- Signature: `verb/Upgrade_health()`
- Inputs: None
- Purpose: Handle upgrade health.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Nuke/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Mount
- Signature: `verb/Mount()`
- Inputs: None
- Purpose: Handle mount.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Detonate
- Signature: `proc/Detonate()`
- Inputs: None
- Purpose: Handle detonate.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Set
- Signature: `verb/Set()`
- Inputs: None
- Purpose: Handle set.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Arm
- Signature: `verb/Arm()`
- Inputs: None
- Purpose: Handle arm.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Timed_Detonation
- Signature: `proc/Timed_Detonation()`
- Inputs: None
- Purpose: Handle timed detonation.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Proximity_Detonation
- Signature: `proc/Proximity_Detonation()`
- Inputs: None
- Purpose: Handle proximity detonation.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Remote_Detonation
- Signature: `proc/Remote_Detonation()`
- Inputs: None
- Purpose: Handle remote detonation.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Nuke/Sonic_Bomb/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Combat_Status
- Signature: `Combat_Status(mob/M) // 1 = In Combat, 0 = Not in Combat`
- Inputs: mob/M
- Purpose: Handle combat status.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Technology/CyberDrones.dm

#### mob/proc/Drone_initialize
- Signature: `mob/proc/Drone_initialize()`
- Inputs: None
- Purpose: Handle drone initialize.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drone_self_repair
- Signature: `mob/proc/Drone_self_repair()`
- Inputs: None
- Purpose: Handle drone self repair.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drone_bug_thingy
- Signature: `mob/proc/Drone_bug_thingy()`
- Inputs: None
- Purpose: Handle drone bug thingy.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drone_Blast_Response
- Signature: `mob/proc/Drone_Blast_Response() while(src)`
- Inputs: None
- Purpose: Handle drone blast response.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drone_Beam_Response
- Signature: `mob/proc/Drone_Beam_Response() while(src)`
- Inputs: None
- Purpose: Handle drone beam response.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drone_Grab_Struggle
- Signature: `mob/proc/Drone_Grab_Struggle() while(src)`
- Inputs: None
- Purpose: Handle drone grab struggle.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drone_Attack_Gain_Loop
- Signature: `mob/proc/Drone_Attack_Gain_Loop() while(src)`
- Inputs: None
- Purpose: Handle drone attack gain loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drone_get_bp_loop
- Signature: `mob/proc/Drone_get_bp_loop() while(src)`
- Inputs: None
- Purpose: Handle drone get bp loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/drone_master_msg
- Signature: `mob/proc/drone_master_msg(t)`
- Inputs: t
- Purpose: Handle drone master msg.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drone_Attack
- Signature: `mob/proc/Drone_Attack(mob/P,lethal)`
- Inputs: mob/P, lethal
- Purpose: Handle drone attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Key_Passwords
- Signature: `mob/proc/Key_Passwords()`
- Inputs: None
- Purpose: Handle key passwords.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Master_is_near
- Signature: `mob/proc/Master_is_near()`
- Inputs: None
- Purpose: Handle master is near.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Is_drone_master
- Signature: `mob/proc/Is_drone_master(mob/m)`
- Inputs: mob/m
- Purpose: Return whether drone master.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Drone_can_break_this_wall
- Signature: `mob/proc/Drone_can_break_this_wall(turf/t)`
- Inputs: turf/t
- Purpose: Handle drone can break this wall.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/drone_step
- Signature: `mob/proc/drone_step(mob/P,ignore_master,from_drone_attack,avoid_caves=1)`
- Inputs: mob/P, ignore_master, from_drone_attack, avoid_caves=1
- Purpose: Handle drone step.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Players_at_Z
- Signature: `proc/Players_at_Z(A)`
- Inputs: A
- Purpose: Handle players at z.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_Criminal
- Signature: `proc/Get_Criminal(list/L,list/B)`
- Inputs: list/L, list/B
- Purpose: Return Criminal.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Detect_Illegal_Activity
- Signature: `mob/proc/Detect_Illegal_Activity()`
- Inputs: None
- Purpose: Handle detect illegal activity.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Duplicate_Target
- Signature: `mob/proc/Duplicate_Target(obj/O) for(var/mob/P in mob_view(15,src))`
- Inputs: obj/O
- Purpose: Handle duplicate target.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Illegal_Activity_Bypass
- Signature: `mob/proc/Illegal_Activity_Bypass()`
- Inputs: None
- Purpose: Handle illegal activity bypass.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drone_exit_ship
- Signature: `mob/proc/Drone_exit_ship(mob/master,obj/Ship_exit/exit)`
- Inputs: mob/master, obj/Ship_exit/exit
- Purpose: Handle drone exit ship.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drone_get_in_ship
- Signature: `mob/proc/Drone_get_in_ship(mob/master,obj/Ships/Ship/ship)`
- Inputs: mob/master, obj/Ships/Ship/ship
- Purpose: Handle drone get in ship.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drone_Assemble
- Signature: `mob/proc/Drone_Assemble(turf/T,mob/P)`
- Inputs: turf/T, mob/P
- Purpose: Handle drone assemble.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Collect_Resources
- Signature: `mob/proc/Collect_Resources(Max,mob/P)`
- Inputs: Max, mob/P
- Purpose: Handle collect resources.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Vaccuum_resources
- Signature: `mob/proc/Vaccuum_resources(display_message=1)`
- Inputs: display_message=1
- Purpose: Handle vaccuum resources.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Steal_Resources
- Signature: `mob/proc/Steal_Resources(Max,mob/P)`
- Inputs: Max, mob/P
- Purpose: Handle steal resources.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drone_steal_from_player
- Signature: `mob/proc/Drone_steal_from_player(mob/m)`
- Inputs: mob/m
- Purpose: Handle drone steal from player.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Binded_at_bind_spawn
- Signature: `mob/proc/Binded_at_bind_spawn()`
- Inputs: None
- Purpose: Handle binded at bind spawn.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drone_Genocide
- Signature: `mob/proc/Drone_Genocide(R,mob/P) //R=Race to kill`
- Inputs: R, mob/P
- Purpose: Handle drone genocide.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Get_Drone_AI
- Signature: `mob/proc/Get_Drone_AI()`
- Inputs: None
- Purpose: Return Drone AI.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Drone_Patrol
- Signature: `mob/proc/Drone_Patrol(mob/PP)`
- Inputs: mob/PP
- Purpose: Handle drone patrol.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Cancel_Orders
- Signature: `mob/proc/Cancel_Orders(mob/P)`
- Inputs: mob/P
- Purpose: Handle cancel orders.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Get_max_cyber_bp_upgrade
- Signature: `mob/proc/Get_max_cyber_bp_upgrade(race)`
- Inputs: race
- Purpose: Return max cyber bp upgrade.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Drone_Options
- Signature: `mob/proc/Drone_Options(obj/Cybernetics_Computer/R) while(src&&R)`
- Inputs: obj/Cybernetics_Computer/R
- Purpose: Handle drone options.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drone_Self_Destruct
- Signature: `mob/proc/Drone_Self_Destruct()`
- Inputs: None
- Purpose: Handle drone self destruct.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Choosable_Drones
- Signature: `mob/proc/Choosable_Drones(M="Drone Options",F)`
- Inputs: M="Drone Options", F
- Purpose: Handle choosable drones.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Mob_Count
- Signature: `proc/Mob_Count(list/L)`
- Inputs: list/L
- Purpose: Handle mob count.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drone_Frequency
- Signature: `mob/proc/Drone_Frequency()`
- Inputs: None
- Purpose: Handle drone frequency.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_Drones
- Signature: `proc/Get_Drones(list/L,F)`
- Inputs: list/L, F
- Purpose: Return Drones.
- Returns: computed value (see implementation).
- Side effects: none expected.

### src/Code/Technology/Cybernetics.dm

#### mob/proc/GrabAbsorber
- Signature: `mob/proc/GrabAbsorber()`
- Inputs: None
- Purpose: Handle grab absorber.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/HasRebuildRequirements
- Signature: `mob/proc/HasRebuildRequirements()`
- Inputs: None
- Purpose: Return whether Rebuild Requirements.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/AlreadyHasModule
- Signature: `mob/proc/AlreadyHasModule(t)`
- Inputs: t
- Purpose: Handle already has module.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Firewall
- Signature: `mob/proc/Firewall(mob/P)`
- Inputs: mob/P
- Purpose: Handle firewall.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Generator_reduction
- Signature: `mob/proc/Generator_reduction(is_melee)`
- Inputs: is_melee
- Purpose: Handle generator reduction.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Set
- Signature: `verb/Set() if(src in usr)`
- Inputs: None
- Purpose: Handle set.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Module/Drone_AI/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Module/Blast_Absorb/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Set
- Signature: `verb/Set() if(src in usr)`
- Inputs: None
- Purpose: Handle set.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Module/Generator/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Module/Brute /OLD/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Module/Armor /OLD/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Module/Armor_New/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Module/Grab_Absorb/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Enable_Module
- Signature: `proc/Enable_Module(mob/P)`
- Inputs: mob/P
- Purpose: Handle enable module.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Disable_Module
- Signature: `proc/Disable_Module(mob/P)`
- Inputs: mob/P
- Purpose: Handle disable module.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Module/Click
- Signature: `Click() if(src in usr)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Drop
- Signature: `verb/Drop()`
- Inputs: None
- Purpose: Handle drop.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Module/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Module/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/cyber_bp_Loop
- Signature: `mob/proc/cyber_bp_Loop()`
- Inputs: None
- Purpose: Handle cyber bp loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/has_modules
- Signature: `mob/proc/has_modules()`
- Inputs: None
- Purpose: Return whether modules.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Is_Cybernetic
- Signature: `mob/proc/Is_Cybernetic()`
- Inputs: None
- Purpose: Return whether Cybernetic.
- Returns: boolean flag.
- Side effects: none expected.

#### obj/Cybernetics_Computer/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Choose_Mob
- Signature: `mob/proc/Choose_Mob(T="Choose someone",list/L)`
- Inputs: T="Choose someone", list/L
- Purpose: Handle choose mob.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/StatModByTag
- Signature: `StatModByTag(t)`
- Inputs: t
- Purpose: Handle stat mod by tag.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Android_Starting_Stats
- Signature: `mob/proc/Android_Starting_Stats()`
- Inputs: None
- Purpose: Handle android starting stats.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DroneCount
- Signature: `proc/DroneCount()`
- Inputs: None
- Purpose: Handle drone count.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Android_Blueprint/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DeleteBlueprintedShips
- Signature: `proc/DeleteBlueprintedShips()`
- Inputs: None
- Purpose: Delete Blueprinted Ships.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### verb/Reset
- Signature: `verb/Reset()`
- Inputs: None
- Purpose: Handle reset.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use() if(src in usr)`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/get_obj_copy
- Signature: `proc/get_obj_copy(obj/o)`
- Inputs: obj/o
- Purpose: Return obj copy.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/Save_Obj
- Signature: `proc/Save_Obj(obj/O) if(O)`
- Inputs: obj/O
- Purpose: Save Obj.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Load_Obj
- Signature: `proc/Load_Obj(obj/O) if(O)`
- Inputs: obj/O
- Purpose: Load Obj.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Can_alter_drone
- Signature: `mob/proc/Can_alter_drone(mob/drone,display_message=1)`
- Inputs: mob/drone, display_message=1
- Purpose: Return whether alter drone.
- Returns: boolean flag.
- Side effects: none expected.

#### obj/items/Robotics_Tools/New
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

#### verb/Use
- Signature: `verb/Use() if(src in usr)`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Absorb_Blast
- Signature: `mob/proc/Absorb_Blast(obj/Blast/B)`
- Inputs: obj/Blast/B
- Purpose: Handle absorb blast.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Overdrive
- Signature: `verb/Overdrive()`
- Inputs: None
- Purpose: Handle overdrive.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Overdrive
- Signature: `mob/proc/Overdrive()`
- Inputs: None
- Purpose: Handle overdrive.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Overdrive_Revert
- Signature: `mob/proc/Overdrive_Revert() if(Overdrive)`
- Inputs: None
- Purpose: Handle overdrive revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Clone
- Signature: `mob/proc/Clone()`
- Inputs: None
- Purpose: Handle clone.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Scrap_Absorb
- Signature: `verb/Scrap_Absorb()`
- Inputs: None
- Purpose: Handle scrap absorb.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Android_Scraps/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Android_Scraps/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Scrap_Absorb_Revert_Timer
- Signature: `mob/proc/Scrap_Absorb_Revert_Timer(obj/Scrap_Absorb/A)`
- Inputs: obj/Scrap_Absorb/A
- Purpose: Handle scrap absorb revert timer.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Scrap_Absorb_Revert
- Signature: `mob/proc/Scrap_Absorb_Revert(obj/Scrap_Absorb/A)`
- Inputs: obj/Scrap_Absorb/A
- Purpose: Handle scrap absorb revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Spread_Scraps
- Signature: `proc/Spread_Scraps(mob/m)`
- Inputs: mob/m
- Purpose: Handle spread scraps.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Scraps_Exist
- Signature: `mob/proc/Scraps_Exist()`
- Inputs: None
- Purpose: Handle scraps exist.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Scraps_Assemble
- Signature: `proc/Scraps_Assemble(obj/T)`
- Inputs: obj/T
- Purpose: Handle scraps assemble.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Technology/GunCustomization.dm

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Customize_Gun_Stats
- Signature: `mob/proc/Customize_Gun_Stats(obj/items/Gun/G)`
- Inputs: obj/items/Gun/G
- Purpose: Handle customize gun stats.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Gun_Window_Refresh
- Signature: `mob/proc/Gun_Window_Refresh(obj/items/Gun/G)`
- Inputs: obj/items/Gun/G
- Purpose: Handle gun window refresh.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Gun/proc/Set_Default_Gun_Stats
- Signature: `obj/items/Gun/proc/Set_Default_Gun_Stats()`
- Inputs: None
- Purpose: Set Default Gun Stats.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### obj/items/Gun/proc/Gun_Stat_Lowest
- Signature: `obj/items/Gun/proc/Gun_Stat_Lowest(A)`
- Inputs: A
- Purpose: Handle gun stat lowest.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Customize_Gun
- Signature: `mob/verb/Customize_Gun(O as text,S as text) //O=Operator (+ or -), S=Stat`
- Inputs: O as text, S as text
- Purpose: Handle customize gun.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Gun_Points_Done
- Signature: `mob/verb/Gun_Points_Done()`
- Inputs: None
- Purpose: Handle gun points done.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Gun_Icon/Click
- Signature: `obj/Gun_Icon/Click() if(usr.Gun)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Bullet_Icons/Click
- Signature: `obj/Bullet_Icons/Click() if(usr.Gun)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Initialize_Gun_Icons
- Signature: `proc/Initialize_Gun_Icons()`
- Inputs: None
- Purpose: Initialize Gun Icons.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Grid
- Signature: `mob/proc/Grid(list/L, obj/items/Gun/G, update_only, show_names = 1)`
- Inputs: list/L, obj/items/Gun/G, update_only, show_names = 1
- Purpose: Handle grid.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Hide_Main_Grid
- Signature: `mob/verb/Hide_Main_Grid()`
- Inputs: None
- Purpose: Handle hide main grid.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/weights_icon/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Technology/Guns.dm

#### mob/Admin3/verb/DestroyTurretsOfThisPerson
- Signature: `mob/Admin3/verb/DestroyTurretsOfThisPerson(obj/Turret/t in Turrets)`
- Inputs: obj/Turret/t in Turrets
- Purpose: Handle destroy turrets of this person.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Turret_loop
- Signature: `proc/Turret_loop()`
- Inputs: None
- Purpose: Handle turret loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turret/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turret/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turret/Click
- Signature: `Click() if(usr in range(1,src))`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Turret_Target
- Signature: `proc/Turret_Target()`
- Inputs: None
- Purpose: Handle turret target.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Turret_Fire_Loop
- Signature: `proc/Turret_Fire_Loop()`
- Inputs: None
- Purpose: Handle turret fire loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DoTurretFireCooldown
- Signature: `proc/DoTurretFireCooldown(Turret_Refire)`
- Inputs: Turret_Refire
- Purpose: Perform Turret Fire Cooldown.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Turret_Fire
- Signature: `proc/Turret_Fire(mob/P)`
- Inputs: mob/P
- Purpose: Handle turret fire.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/proc/Turret_Missile_Is_On_Target
- Signature: `obj/proc/Turret_Missile_Is_On_Target(mob/P)`
- Inputs: mob/P
- Purpose: Handle turret missile is on target.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/View
- Signature: `verb/View()`
- Inputs: None
- Purpose: Handle view.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Update_Gun_Description
- Signature: `proc/Update_Gun_Description()`
- Inputs: None
- Purpose: Update Gun Description.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### obj/items/Gun/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Gun/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Customize
- Signature: `verb/Customize()`
- Inputs: None
- Purpose: Handle customize.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Calibrate_Gun_Stats
- Signature: `proc/Calibrate_Gun_Stats()`
- Inputs: None
- Purpose: Handle calibrate gun stats.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Shoot
- Signature: `verb/Shoot()`
- Inputs: None
- Purpose: Handle shoot.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Gun_Fire
- Signature: `proc/Gun_Fire(mob/P)`
- Inputs: mob/P
- Purpose: Handle gun fire.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Ammo/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Reload
- Signature: `proc/Reload(mob/M,obj/items/Gun/G)`
- Inputs: mob/M, obj/items/Gun/G
- Purpose: Handle reload.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Technology/LandMine.dm

#### obj/items/Land_Mine/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Land_Mine/verb/Hotbar_use
- Signature: `Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Land_Mine/verb/Use
- Signature: `Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanDeployLandMine
- Signature: `CanDeployLandMine()`
- Inputs: None
- Purpose: Return whether Deploy Land Mine.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/PlaceLandMine
- Signature: `PlaceLandMine()`
- Inputs: None
- Purpose: Handle place land mine.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Land_Mine/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Land_Mine/proc/LandMineExplode
- Signature: `LandMineExplode(from_del=0, delay=0)`
- Inputs: from_del=0, delay=0
- Purpose: Handle land mine explode.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/TakeLandMineDamage
- Signature: `TakeLandMineDamage()`
- Inputs: None
- Purpose: Handle take land mine damage.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/proc/ExplodeLandMines
- Signature: `atom/proc/ExplodeLandMines()`
- Inputs: None
- Purpose: Handle explode land mines.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/LandMineEffect/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/LandMineEffect/proc/LandMineEffect
- Signature: `LandMineEffect()`
- Inputs: None
- Purpose: Handle land mine effect.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Technology/NewDrones.dm

#### mob/proc/Get_drone_module
- Signature: `mob/proc/Get_drone_module()`
- Inputs: None
- Purpose: Return drone module.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Drone_initialize_new
- Signature: `mob/proc/Drone_initialize_new()`
- Inputs: None
- Purpose: Handle drone initialize new.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drone_AI
- Signature: `mob/proc/Drone_AI()`
- Inputs: None
- Purpose: Handle drone ai.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/get_path
- Signature: `proc/get_path(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Return path.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/Admin5/verb/pathtest
- Signature: `mob/Admin5/verb/pathtest(mob/m in world)`
- Inputs: mob/m in world
- Purpose: Handle pathtest.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Technology/Shurikens.dm

#### obj/items/Shuriken/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Shuriken
- Signature: `verb/Shuriken()`
- Inputs: None
- Purpose: Handle shuriken.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ShurikenOverlayEffect
- Signature: `ShurikenOverlayEffect(icon/i)`
- Inputs: icon/i
- Purpose: Handle shuriken overlay effect.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RemoveShurikenOverlay
- Signature: `RemoveShurikenOverlay(image/i, t = 0)`
- Inputs: image/i, t = 0
- Purpose: Remove Shuriken Overlay.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/TakeOffShurikenOverlaysOnSave
- Signature: `TakeOffShurikenOverlaysOnSave()`
- Inputs: None
- Purpose: Handle take off shuriken overlays on save.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ReApplyShurikenOverlaysOnSave
- Signature: `ReApplyShurikenOverlaysOnSave()`
- Inputs: None
- Purpose: Handle re apply shuriken overlays on save.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Technology/SmokeBomb.dm

#### obj/items/Smoke_Bomb/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Smoke_Bomb/verb/Hotbar_use
- Signature: `Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Smoke_Bomb/verb/Use
- Signature: `Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanThrowSmokeBomb
- Signature: `CanThrowSmokeBomb()`
- Inputs: None
- Purpose: Return whether Throw Smoke Bomb.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/ThrowSmokeBomb
- Signature: `ThrowSmokeBomb()`
- Inputs: None
- Purpose: Handle throw smoke bomb.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GetSmokeBombEffect
- Signature: `GetSmokeBombEffect()`
- Inputs: None
- Purpose: Return Smoke Bomb Effect.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/DoSmokeBombEffect
- Signature: `DoSmokeBombEffect(turf/t)`
- Inputs: turf/t
- Purpose: Perform Smoke Bomb Effect.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/flash_bang/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/flash_bang/verb/Hotbar_use
- Signature: `Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/flash_bang/verb/Use
- Signature: `Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanThrowFlashbang
- Signature: `CanThrowFlashbang()`
- Inputs: None
- Purpose: Return whether Throw Flashbang.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/ThrowFlashbang
- Signature: `ThrowFlashbang()`
- Inputs: None
- Purpose: Handle throw flashbang.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DoFlashbangEffect
- Signature: `DoFlashbangEffect(turf/t)`
- Inputs: turf/t
- Purpose: Perform Flashbang Effect.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Technology/Technology.dm

#### mob/proc/TryCreateScienceItem
- Signature: `mob/proc/TryCreateScienceItem(obj/A)`
- Inputs: obj/A
- Purpose: Handle try create science item.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Store_item_check
- Signature: `mob/proc/Store_item_check(obj/o)`
- Inputs: obj/o
- Purpose: Handle store item check.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Bank/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Clear_banked_items
- Signature: `mob/Admin4/verb/Clear_banked_items()`
- Inputs: None
- Purpose: Handle clear banked items.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Bank_Options
- Signature: `mob/proc/Bank_Options(obj/Bank/bank)`
- Inputs: obj/Bank/bank
- Purpose: Handle bank options.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Random_resource_drops
- Signature: `proc/Random_resource_drops()`
- Inputs: None
- Purpose: Handle random resource drops.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Planet_Resources
- Signature: `proc/Planet_Resources(N=1)`
- Inputs: N=1
- Purpose: Handle planet resources.
- Returns: none (implicit).
- Side effects: see implementation.

#### area/proc/Resources_destroyed
- Signature: `area/proc/Resources_destroyed()`
- Inputs: None
- Purpose: Handle resources destroyed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Upgrade_Settings
- Signature: `mob/Admin4/verb/Upgrade_Settings()`
- Inputs: None
- Purpose: Handle upgrade settings.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Tech_BP
- Signature: `proc/Tech_BP()`
- Inputs: None
- Purpose: Handle tech bp.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Avg_Force
- Signature: `proc/Avg_Force(N=0)`
- Inputs: N=0
- Purpose: Handle avg force.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Avg_Res
- Signature: `proc/Avg_Res(n=0)`
- Inputs: n=0
- Purpose: Handle avg res.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Avg_Str
- Signature: `proc/Avg_Str(n=0)`
- Inputs: n=0
- Purpose: Handle avg str.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Avg_Offense
- Signature: `proc/Avg_Offense(N=0)`
- Inputs: N=0
- Purpose: Handle avg offense.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Add_Technology
- Signature: `proc/Add_Technology()`
- Inputs: None
- Purpose: Add Technology.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Can_Make_Technology
- Signature: `proc/Can_Make_Technology(mob/P,obj/O)`
- Inputs: mob/P, obj/O
- Purpose: Return whether Make Technology.
- Returns: boolean flag.
- Side effects: none expected.

#### proc/Item_cost
- Signature: `proc/Item_cost(mob/P,obj/O)`
- Inputs: mob/P, obj/O
- Purpose: Handle item cost.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Resources/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Resources/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Update_value
- Signature: `proc/Update_value()`
- Inputs: None
- Purpose: Update value.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### verb/Drop
- Signature: `verb/Drop()`
- Inputs: None
- Purpose: Handle drop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GetResourceBagSize
- Signature: `GetResourceBagSize(n)`
- Inputs: n
- Purpose: Return Resource Bag Size.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/Resources_Loop
- Signature: `proc/Resources_Loop()`
- Inputs: None
- Purpose: Handle resources loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/allocate_drills
- Signature: `proc/allocate_drills(max_percent=1)`
- Inputs: max_percent=1
- Purpose: Handle allocate drills.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/shuffle
- Signature: `proc/shuffle(list/orig,var/divider=1)`
- Inputs: list/orig, var/divider=1
- Purpose: Handle shuffle.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Drill/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Drill/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Drill
- Signature: `proc/Drill()`
- Inputs: None
- Purpose: Handle drill.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Drill/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Technology/Vampires.dm

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Sunlight_Generator/Click
- Signature: `Click() if(usr in view(1,src))`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Sunlight_Cure
- Signature: `mob/proc/Sunlight_Cure()`
- Inputs: None
- Purpose: Handle sunlight cure.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Sunfield/New
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

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Bite
- Signature: `verb/Bite()`
- Inputs: None
- Purpose: Handle bite.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Vampire_Bite/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Vampire_Bite
- Signature: `mob/proc/Vampire_Bite(mob/P,obj/Vampire_Bite/V)`
- Inputs: mob/P, obj/Vampire_Bite/V
- Purpose: Handle vampire bite.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Become_Vampire_Monster
- Signature: `mob/proc/Become_Vampire_Monster() if(Vampire&&!Vampire_Monster)`
- Inputs: None
- Purpose: Handle become vampire monster.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Become_Vampire
- Signature: `mob/proc/Become_Vampire() if(!Vampire&&!Former_Vampire)`
- Inputs: None
- Purpose: Handle become vampire.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Vampire_Cure
- Signature: `mob/proc/Vampire_Cure() if(Vampire)`
- Inputs: None
- Purpose: Handle vampire cure.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Vampire_Revert
- Signature: `mob/proc/Vampire_Revert() if(Vampire)`
- Inputs: None
- Purpose: Handle vampire revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Vampire_Infection_Rise
- Signature: `mob/proc/Vampire_Infection_Rise()`
- Inputs: None
- Purpose: Handle vampire infection rise.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Cured_Vampire_Ratio
- Signature: `mob/proc/Cured_Vampire_Ratio(N=0) //Shows the ratio of people online that are former vampires`
- Inputs: N=0
- Purpose: Handle cured vampire ratio.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Born_Vampire_Check
- Signature: `mob/proc/Born_Vampire_Check(N=0) if(Player_Count())`
- Inputs: N=0
- Purpose: Handle born vampire check.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Living_Players
- Signature: `proc/Living_Players(N=0)`
- Inputs: N=0
- Purpose: Handle living players.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Technology/Zombies.dm

#### mob/proc/InfectedPlayerHitDeadBodyItBecomesZombie
- Signature: `InfectedPlayerHitDeadBodyItBecomesZombie(mob/Body/dead_body)`
- Inputs: mob/Body/dead_body
- Purpose: Handle infected player hit dead body it becomes zombie.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Mutate
- Signature: `mob/proc/Mutate(A)`
- Inputs: A
- Purpose: Handle mutate.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Zombie_Drop
- Signature: `mob/proc/Zombie_Drop()`
- Inputs: None
- Purpose: Handle zombie drop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Undo_all_t_injections
- Signature: `Undo_all_t_injections()`
- Inputs: None
- Purpose: Handle undo all t injections.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Apply_t_injections
- Signature: `Apply_t_injections(list/l)`
- Inputs: list/l
- Purpose: Apply t injections.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Apply_t_spider
- Signature: `Apply_t_spider(remove=0)`
- Inputs: remove=0
- Purpose: Apply t spider.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Apply_t_scorpion
- Signature: `Apply_t_scorpion(remove=0)`
- Inputs: remove=0
- Purpose: Apply t scorpion.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Apply_t_snake
- Signature: `Apply_t_snake(remove=0)`
- Inputs: remove=0
- Purpose: Apply t snake.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Apply_t_recovery
- Signature: `Apply_t_recovery(remove=0)`
- Inputs: remove=0
- Purpose: Apply t recovery.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Apply_t_regeneration
- Signature: `Apply_t_regeneration(remove=0)`
- Inputs: remove=0
- Purpose: Apply t regeneration.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Apply_t_undying
- Signature: `Apply_t_undying(remove=0)`
- Inputs: remove=0
- Purpose: Apply t undying.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ClearTFusion
- Signature: `mob/proc/ClearTFusion()`
- Inputs: None
- Purpose: Handle clear tfusion.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use(mob/A in view(1,usr)) if(A) if(A==usr||A.Frozen||A.KO)`
- Inputs: mob/A in view(1, usr
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Zombie_Virus_Loop
- Signature: `mob/proc/Zombie_Virus_Loop()`
- Inputs: None
- Purpose: Handle zombie virus loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Zombie_virus_activated
- Signature: `mob/proc/Zombie_virus_activated()`
- Inputs: None
- Purpose: Handle zombie virus activated.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Zombies
- Signature: `mob/proc/Zombies(Can_Mutate=1,timer=150)`
- Inputs: Can_Mutate=1, timer=150
- Purpose: Handle zombies.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/zombie_reproduce
- Signature: `mob/proc/zombie_reproduce()`
- Inputs: None
- Purpose: Handle zombie reproduce.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Zombie_mutate_loop
- Signature: `proc/Zombie_mutate_loop()`
- Inputs: None
- Purpose: Handle zombie mutate loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Zombie_reproduce_loop
- Signature: `proc/Zombie_reproduce_loop()`
- Inputs: None
- Purpose: Handle zombie reproduce loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Zombie_Initialize
- Signature: `mob/proc/Zombie_Initialize()`
- Inputs: None
- Purpose: Handle zombie initialize.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Zombie_update_area
- Signature: `mob/proc/Zombie_update_area()`
- Inputs: None
- Purpose: Handle zombie update area.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Zombie_Copy
- Signature: `mob/proc/Zombie_Copy()`
- Inputs: None
- Purpose: Handle zombie copy.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CalculateZombieBP
- Signature: `CalculateZombieBP(from_body = 0)`
- Inputs: from_body = 0
- Purpose: Calculate Zombie BP.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Zombie_Door_Attack
- Signature: `mob/proc/Zombie_Door_Attack()`
- Inputs: None
- Purpose: Handle zombie door attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/cache_zombie
- Signature: `mob/proc/cache_zombie()`
- Inputs: None
- Purpose: Handle cache zombie.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/get_cached_zombie
- Signature: `proc/get_cached_zombie()`
- Inputs: None
- Purpose: Return cached zombie.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/Enemy/Zombie/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Enemy/Zombie/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/StartSuperAntivirusAtLocation
- Signature: `proc/StartSuperAntivirusAtLocation(turf/t)`
- Inputs: turf/t
- Purpose: Start Super Antivirus At Location.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Enemy/Zombie/proc/InfectWithSuperAntivirus
- Signature: `mob/Enemy/Zombie/proc/InfectWithSuperAntivirus(delay = 0)`
- Inputs: delay = 0
- Purpose: Handle infect with super antivirus.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DestroyAllInfectedBodiesOnPlanet
- Signature: `proc/DestroyAllInfectedBodiesOnPlanet(area/a)`
- Inputs: area/a
- Purpose: Handle destroy all infected bodies on planet.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/CureAllInfectedPlayersOnPlanet
- Signature: `proc/CureAllInfectedPlayersOnPlanet(area/a)`
- Inputs: area/a
- Purpose: Handle cure all infected players on planet.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GetZombiesOnPlanet
- Signature: `proc/GetZombiesOnPlanet(area/a)`
- Inputs: area/a
- Purpose: Return Zombies On Planet.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Synthesize
- Signature: `verb/Synthesize()`
- Inputs: None
- Purpose: Handle synthesize.
- Returns: none (implicit).
- Side effects: see implementation.
