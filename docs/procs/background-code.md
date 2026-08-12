# Background Code

## Overview
Auto-generated first-pass proc summaries based on signature names. Refine descriptions during refactors.

## Files
- `src/Code/BackgroundCode/BugLogs.dm`
- `src/Code/BackgroundCode/JavascriptResolutionChecker.dm`
- `src/Code/BackgroundCode/ObjectCache.dm`
- `src/Code/BackgroundCode/SpecialAnnouncementsLoop.dm`
- `src/Code/BackgroundCode/StatLoop.dm`

## Proc Reference

### src/Code/BackgroundCode/BugLogs.dm

#### proc/gains_limiter
- Signature: `proc/gains_limiter()`
- Inputs: None
- Purpose: Handle gains limiter.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/LogBug
- Signature: `proc/LogBug(t, clr)`
- Inputs: t, clr
- Purpose: Handle log bug.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Wipebuglogs
- Signature: `proc/Wipebuglogs()`
- Inputs: None
- Purpose: Handle wipebuglogs.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Total_Res
- Signature: `mob/proc/Total_Res() //on you and in bank total`
- Inputs: None
- Purpose: Handle total res.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Monitor_Bugs
- Signature: `proc/Monitor_Bugs()`
- Inputs: None
- Purpose: Handle monitor bugs.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Save_Bugs
- Signature: `proc/Save_Bugs()`
- Inputs: None
- Purpose: Save Bugs.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Load_Bugs
- Signature: `proc/Load_Bugs() if(fexists("data/Bugs"))`
- Inputs: None
- Purpose: Load Bugs.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Bug_Keys
- Signature: `mob/proc/Bug_Keys()`
- Inputs: None
- Purpose: Handle bug keys.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/BackgroundCode/JavascriptResolutionChecker.dm

#### client/proc/JSresolutionCheck
- Signature: `JSresolutionCheck()`
- Inputs: None
- Purpose: Handle jsresolution check.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/Topic
- Signature: `client/Topic(href, href_list[])`
- Inputs: href, href_list[]
- Purpose: Handle topic.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/BackgroundCode/ObjectCache.dm

#### proc/GetCachedObject
- Signature: `GetCachedObject(obj_type, pos)`
- Inputs: obj_type, pos
- Purpose: Pop and reinitialize the most recently cached object of a type in O(1), or allocate when the cache is empty.
- Returns: reusable object.
- Side effects: removes one entry from the per-type cache.

#### proc/CacheObject
- Signature: `CacheObject(obj/o)`
- Inputs: obj/o
- Purpose: Reset and push an object into its bounded per-type cache, rejecting duplicates and deleting overflow.
- Returns: none (implicit).
- Side effects: detaches the object or schedules real deletion when `object_cache_retention_limit_per_type` is reached.

### src/Code/BackgroundCode/SpecialAnnouncementsLoop.dm

#### proc/SpecialAnnouncementsLoop
- Signature: `SpecialAnnouncementsLoop()`
- Inputs: None
- Purpose: Emit configured announcements at their own minute intervals and record the actual last-announced timestamp.
- Returns: none (implicit).
- Side effects: sends messages to connected clients and updates each announcement schedule.

#### mob/Admin2/verb/setLoopingAnouncement
- Signature: `mob/Admin2/verb/setLoopingAnouncement()`
- Inputs: None
- Purpose: Set Looping Anouncement.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/EncodeAnnouncement
- Signature: `EncodeAnnouncement(msg)`
- Inputs: msg
- Purpose: Handle encode announcement.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/BackgroundCode/StatLoop.dm

#### mob/proc/get_bp_loop
- Signature: `mob/proc/get_bp_loop()`
- Inputs: None
- Purpose: Return bp loop.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/UpdateBP
- Signature: `UpdateBP()`
- Inputs: None
- Purpose: Update BP.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Anger_mult
- Signature: `mob/proc/Anger_mult()`
- Inputs: None
- Purpose: Return the current Anger power multiplier while enforcing archetype eligibility.
- Returns: `1` for KO or Angerless archetypes; otherwise the configured current-Anger multiplier.
- Side effects: normalizes stale Anger values for Android, Legendary Saiyan, and Jiren/Apex Alien.

#### mob/proc/Powerup_mult
- Signature: `mob/proc/Powerup_mult()`
- Inputs: None
- Purpose: Handle powerup mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Anger_Powerup_SuperGod_Fist_Mix_Mult
- Signature: `mob/proc/Anger_Powerup_SuperGod_Fist_Mix_Mult(factor_powerup = 1)`
- Inputs: factor_powerup = 1
- Purpose: Handle anger powerup super god fist mix mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Dead_power
- Signature: `mob/proc/Dead_power()`
- Inputs: None
- Purpose: Handle dead power.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BodySwapBPMult
- Signature: `BodySwapBPMult()`
- Inputs: None
- Purpose: Handle body swap bpmult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/racialCombatBPMult
- Signature: `racialCombatBPMult()`
- Inputs: None
- Purpose: Return the dynamic combat-BP multiplier for Standard and Exceptional race packages without modifying persisted BP data.
- Returns: A positive BP multiplier.
- Side effects: None.

#### mob/proc/racialDamageTakenMult
- Signature: `racialDamageTakenMult()`
- Inputs: None
- Purpose: Return the dynamic incoming-damage multiplier for Exceptional race packages and Alien Apex Genome.
- Returns: A positive incoming-damage multiplier.
- Side effects: None.

#### mob/proc/effectiveBaseBPMult
- Signature: `effectiveBaseBPMult()`
- Inputs: None
- Purpose: Handle effective base bpmult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/get_bp
- Signature: `mob/proc/get_bp(factor_powerup=1)`
- Inputs: factor_powerup=1
- Purpose: Return BP through the ordered transformation pipeline; Demon soul contribution is capped at three effective souls (`1.3x`).
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/ApplyDeadzonePressure
- Signature: `mob/proc/ApplyDeadzonePressure(bp)`
- Inputs: bp
- Purpose: Apply Deadzone Pressure.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Player_Loops
- Signature: `mob/proc/Player_Loops(start_delay)`
- Inputs: start_delay
- Purpose: Handle player loops.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Intelligence
- Signature: `mob/proc/Intelligence()`
- Inputs: None
- Purpose: Handle intelligence.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RaceStamBonus
- Signature: `RaceStamBonus()`
- Inputs: None
- Purpose: Handle race stam bonus.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/StaminaRechargeLoop
- Signature: `StaminaRechargeLoop()`
- Inputs: None
- Purpose: Handle stamina recharge loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanRechargeStamina
- Signature: `CanRechargeStamina()`
- Inputs: None
- Purpose: Return whether Recharge Stamina.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/AddStamina
- Signature: `AddStamina(n = 1)`
- Inputs: n = 1
- Purpose: Add Stamina.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/DecideMaxStamina
- Signature: `DecideMaxStamina()`
- Inputs: None
- Purpose: Handle decide max stamina.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/StatStamMult
- Signature: `StatStamMult()`
- Inputs: None
- Purpose: Handle stat stam mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MajinLearnSkill
- Signature: `MajinLearnSkill()`
- Inputs: None
- Purpose: Handle majin learn skill.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SetOffenseAndDefenseToMatchSpeed
- Signature: `SetOffenseAndDefenseToMatchSpeed()`
- Inputs: None
- Purpose: Set Offense And Defense To Match Speed.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Start_core_loops
- Signature: `Start_core_loops()`
- Inputs: None
- Purpose: Start core loops.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Braals_core_feat_timer
- Signature: `Braals_core_feat_timer()`
- Inputs: None
- Purpose: Handle braals core feat timer.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Braals_core_music
- Signature: `Braals_core_music()`
- Inputs: None
- Purpose: Handle braals core music.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CoreMaxGainsMult
- Signature: `CoreMaxGainsMult()`
- Inputs: None
- Purpose: Handle core max gains mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CoreGainsMult
- Signature: `CoreGainsMult()`
- Inputs: None
- Purpose: Handle core gains mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/IfInSpacePodDestroyPod
- Signature: `IfInSpacePodDestroyPod()`
- Inputs: None
- Purpose: Handle if in space pod destroy pod.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Braals_core_gains
- Signature: `Braals_core_gains()`
- Inputs: None
- Purpose: Handle braals core gains.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Braals_core_enemy_spawner
- Signature: `Braals_core_enemy_spawner()`
- Inputs: None
- Purpose: Handle braals core enemy spawner.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Braals_core_explosions
- Signature: `Braals_core_explosions()`
- Inputs: None
- Purpose: Handle braals core explosions.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Braals_core_camera_shake
- Signature: `Braals_core_camera_shake()`
- Inputs: None
- Purpose: Handle braals core camera shake.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Braals_core_gas
- Signature: `Braals_core_gas()`
- Inputs: None
- Purpose: Handle braals core gas.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Core_demon_delete
- Signature: `proc/Core_demon_delete(mob/cd,t=120)`
- Inputs: mob/cd, t=120
- Purpose: Handle core demon delete.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/InCore
- Signature: `mob/proc/InCore()`
- Inputs: None
- Purpose: Handle in core.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Detect_good_people
- Signature: `mob/proc/Detect_good_people()`
- Inputs: None
- Purpose: Handle detect good people.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/update_area_loop
- Signature: `mob/proc/update_area_loop()`
- Inputs: None
- Purpose: Update area loop.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### area/tournament_area/Enter
- Signature: `Enter(mob/m)`
- Inputs: mob/m
- Purpose: Handle enter.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Refill_grab_power_loop
- Signature: `mob/proc/Refill_grab_power_loop()`
- Inputs: None
- Purpose: Handle refill grab power loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/calmness_timer
- Signature: `mob/proc/calmness_timer()`
- Inputs: None
- Purpose: Handle calmness timer.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/buff_transform_drain
- Signature: `mob/proc/buff_transform_drain()`
- Inputs: None
- Purpose: Handle buff transform drain.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Knowledge_gain_loop
- Signature: `mob/proc/Knowledge_gain_loop()`
- Inputs: None
- Purpose: Handle knowledge gain loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SI_List
- Signature: `mob/proc/SI_List(N=6000)`
- Inputs: N=6000
- Purpose: Handle si list.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Regenerator_loop
- Signature: `mob/proc/Regenerator_loop(obj/items/Regenerator/r)`
- Inputs: obj/items/Regenerator/r
- Purpose: Handle regenerator loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RegenGrabDrop
- Signature: `mob/proc/RegenGrabDrop()`
- Inputs: None
- Purpose: Handle regen grab drop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Network_Delay_Loop
- Signature: `mob/proc/Network_Delay_Loop() while(src)`
- Inputs: None
- Purpose: Handle network delay loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Namekian_regen_loop
- Signature: `mob/proc/Namekian_regen_loop()`
- Inputs: None
- Purpose: Handle namekian regen loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Nanite_repair_loop
- Signature: `mob/proc/Nanite_repair_loop()`
- Inputs: None
- Purpose: Handle nanite repair loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Injury_removal_loop
- Signature: `mob/proc/Injury_removal_loop()`
- Inputs: None
- Purpose: Handle injury removal loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Recover_energy_loop
- Signature: `proc/Recover_energy_loop()`
- Inputs: None
- Purpose: Handle recover energy loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Can_recover_health
- Signature: `Can_recover_health(health_limit=100)`
- Inputs: health_limit=100
- Purpose: Return whether recover health.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Can_recover_ki
- Signature: `Can_recover_ki(ki_limit=1.#INF)`
- Inputs: ki_limit=1.#INF
- Purpose: Return whether recover ki.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Logout_timer_countdown
- Signature: `mob/proc/Logout_timer_countdown()`
- Inputs: None
- Purpose: Handle logout timer countdown.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Recover_health_loop
- Signature: `proc/Recover_health_loop()`
- Inputs: None
- Purpose: Handle recover health loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Makyo_Star
- Signature: `mob/proc/Makyo_Star()`
- Inputs: None
- Purpose: Handle makyo star.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RegenMod
- Signature: `mob/proc/RegenMod()`
- Inputs: None
- Purpose: Handle regen mod.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DuraRegenMod
- Signature: `DuraRegenMod()`
- Inputs: None
- Purpose: Handle dura regen mod.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Immortality_zones
- Signature: `proc/Immortality_zones()`
- Inputs: None
- Purpose: Handle immortality zones.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Eye_Injury_Blindness
- Signature: `mob/proc/Eye_Injury_Blindness()`
- Inputs: None
- Purpose: Handle eye injury blindness.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/death_regen
- Signature: `mob/proc/death_regen(set_loc=1)`
- Inputs: set_loc=1
- Purpose: Handle death regen.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Bind_loop
- Signature: `proc/Bind_loop()`
- Inputs: None
- Purpose: Handle bind loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Fly_Drain
- Signature: `Fly_Drain()`
- Inputs: None
- Purpose: Handle fly drain.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MasterFly
- Signature: `MasterFly(amount = 1)`
- Inputs: amount = 1
- Purpose: Handle master fly.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Fly_loop
- Signature: `mob/proc/Fly_loop()`
- Inputs: None
- Purpose: Handle fly loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Alter_regen_mult
- Signature: `mob/proc/Alter_regen_mult(n=0)`
- Inputs: n=0
- Purpose: Handle alter regen mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Regen_mult_decrease
- Signature: `mob/proc/Regen_mult_decrease()`
- Inputs: None
- Purpose: Handle regen mult decrease.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Alter_recov_mult
- Signature: `mob/proc/Alter_recov_mult(n=0)`
- Inputs: n=0
- Purpose: Handle alter recov mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Recov_mult_decrease
- Signature: `mob/proc/Recov_mult_decrease()`
- Inputs: None
- Purpose: Handle recov mult decrease.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Faction_Update
- Signature: `mob/proc/Faction_Update()`
- Inputs: None
- Purpose: Handle faction update.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Overdrive_Loop
- Signature: `mob/proc/Overdrive_Loop()`
- Inputs: None
- Purpose: Handle overdrive loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Beam_Charge_Loop
- Signature: `mob/proc/Beam_Charge_Loop(obj/Attacks/A)`
- Inputs: obj/Attacks/A
- Purpose: Handle beam charge loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/powerup_speed
- Signature: `mob/proc/powerup_speed(n=1)`
- Inputs: n=1
- Purpose: Handle powerup speed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/powerup_soft_cap
- Signature: `mob/proc/powerup_soft_cap()`
- Inputs: None
- Purpose: Handle powerup soft cap.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/energy_mod_powerup_soft_cap
- Signature: `mob/proc/energy_mod_powerup_soft_cap()`
- Inputs: None
- Purpose: Handle energy mod powerup soft cap.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PowerupKnockbackEffect
- Signature: `mob/proc/PowerupKnockbackEffect(mob/m)`
- Inputs: mob/m
- Purpose: Handle powerup knockback effect.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PowerupScreenShakeLoop
- Signature: `mob/proc/PowerupScreenShakeLoop(obj/Power_Control/pc)`
- Inputs: obj/Power_Control/pc
- Purpose: Handle powerup screen shake loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PowerUpKnockAwayLoop
- Signature: `mob/proc/PowerUpKnockAwayLoop(obj/Power_Control/A)`
- Inputs: obj/Power_Control/A
- Purpose: Handle power up knock away loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Power_Control_Loop
- Signature: `mob/proc/Power_Control_Loop(obj/Power_Control/A)`
- Inputs: obj/Power_Control/A
- Purpose: Handle power control loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Charge_Drain
- Signature: `mob/proc/Charge_Drain()`
- Inputs: None
- Purpose: Handle charge drain.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Powerup_drain
- Signature: `proc/Powerup_drain()`
- Inputs: None
- Purpose: Handle powerup drain.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/frc_share
- Signature: `frc_share()`
- Inputs: None
- Purpose: Handle frc share.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/dur_share
- Signature: `dur_share()`
- Inputs: None
- Purpose: Handle dur share.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/res_share
- Signature: `res_share()`
- Inputs: None
- Purpose: Handle res share.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/spd_share
- Signature: `spd_share()`
- Inputs: None
- Purpose: Handle spd share.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/str_share
- Signature: `str_share()`
- Inputs: None
- Purpose: Handle str share.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/def_share
- Signature: `def_share()`
- Inputs: None
- Purpose: Handle def share.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Swordless_strength
- Signature: `mob/proc/Swordless_strength()`
- Inputs: None
- Purpose: Handle swordless strength.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MasterLimitBreak
- Signature: `mob/proc/MasterLimitBreak()`
- Inputs: None
- Purpose: Handle master limit break.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Limit_Breaker_Loop
- Signature: `mob/proc/Limit_Breaker_Loop()`
- Inputs: None
- Purpose: Handle limit breaker loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Final_realm_loop
- Signature: `mob/proc/Final_realm_loop()`
- Inputs: None
- Purpose: Handle final realm loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Ki_shield_revert_loop
- Signature: `mob/proc/Ki_shield_revert_loop()`
- Inputs: None
- Purpose: Handle ki shield revert loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Dig_loop
- Signature: `mob/proc/Dig_loop()`
- Inputs: None
- Purpose: Handle dig loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Poison_Loop
- Signature: `mob/proc/Poison_Loop()`
- Inputs: None
- Purpose: Handle poison loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Apply_poison
- Signature: `mob/proc/Apply_poison(n=1)`
- Inputs: n=1
- Purpose: Apply poison.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Poison_resist
- Signature: `mob/proc/Poison_resist()`
- Inputs: None
- Purpose: Handle poison resist.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Diarea_Loop
- Signature: `mob/proc/Diarea_Loop()`
- Inputs: None
- Purpose: Handle diarea loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Energy_Reduction_Loop
- Signature: `mob/proc/Energy_Reduction_Loop()`
- Inputs: None
- Purpose: Handle energy reduction loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Health_Reduction_Loop
- Signature: `mob/proc/Health_Reduction_Loop()`
- Inputs: None
- Purpose: Handle health reduction loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Meditate_gain_loop
- Signature: `mob/proc/Meditate_gain_loop()`
- Inputs: None
- Purpose: Handle meditate gain loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Train_Gain_Loop
- Signature: `mob/proc/Train_Gain_Loop()`
- Inputs: None
- Purpose: Handle train gain loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Raise_SP
- Signature: `mob/proc/Raise_SP(Amount)`
- Inputs: Amount
- Purpose: Handle raise sp.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/AddKi
- Signature: `AddKi(n = 0)`
- Inputs: n = 0
- Purpose: Add Ki.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/ki_mult
- Signature: `ki_mult()`
- Inputs: None
- Purpose: Handle ki mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/hp_mult
- Signature: `hp_mult()`
- Inputs: None
- Purpose: Handle hp mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/hp_ki_bp_loss_mult
- Signature: `hp_ki_bp_loss_mult()`
- Inputs: None
- Purpose: Handle hp ki bp loss mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/hp_mult
- Signature: `mob/proc/hp_mult()`
- Inputs: None
- Purpose: Handle hp mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SplitformCount
- Signature: `mob/proc/SplitformCount()`
- Inputs: None
- Purpose: Handle splitform count.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Dead_In_Living_World_Loop
- Signature: `mob/proc/Dead_In_Living_World_Loop()`
- Inputs: None
- Purpose: Handle dead in living world loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Is_In_Afterlife
- Signature: `proc/Is_In_Afterlife(mob/P)`
- Inputs: mob/P
- Purpose: Return whether In Afterlife.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Gravity_Health_Ratio
- Signature: `mob/proc/Gravity_Health_Ratio()`
- Inputs: None
- Purpose: Handle gravity health ratio.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Internally_Injured
- Signature: `mob/proc/Internally_Injured()`
- Inputs: None
- Purpose: Handle internally injured.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Health_bar_update_loop
- Signature: `proc/Health_bar_update_loop()`
- Inputs: None
- Purpose: Legacy global HUD polling fallback; startup now updates HUD state through each player's consolidated action cycle.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Update_health_bars
- Signature: `mob/proc/Update_health_bars()`
- Inputs: None
- Purpose: Refresh the lower-left client-screen vitals panel and compact overhead health HUD.
- Returns: none (implicit).
- Side effects: updates screen objects, maptext, and a world-space HUD object.

#### mob/proc/Update_evade_meter
- Signature: `mob/proc/Update_evade_meter()`
- Inputs: None
- Purpose: Update evade meter.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.
