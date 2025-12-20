# Combat

## Overview
Auto-generated first-pass proc summaries based on signature names. Refine descriptions during refactors.

## Files
- `src/Code/Combat/BleedDamage.dm`
- `src/Code/Combat/Buffs.dm`
- `src/Code/Combat/Evasion.dm`
- `src/Code/Combat/HokutoShinken.dm`
- `src/Code/Combat/Injuries.dm`
- `src/Code/Combat/Ki Skills/DeathBall2017.dm`
- `src/Code/Combat/Ki Skills/FinalExplosion.dm`
- `src/Code/Combat/Ki Skills/FusionSystem.dm`
- `src/Code/Combat/Ki Skills/Hakai.dm`
- `src/Code/Combat/Ki Skills/Kikoho2016.dm`
- `src/Code/Combat/Ki Skills/Sense 2017/Sense.dm`
- `src/Code/Combat/Ki Skills/SolarFlare.dm`
- `src/Code/Combat/Ki Skills/SpiritBomb2016.dm`
- `src/Code/Combat/Ki Skills/Supernova.dm`
- `src/Code/Combat/Math/CombatMath.dm`
- `src/Code/Combat/MegatonThrow.dm`
- `src/Code/Combat/Melee.dm`
- `src/Code/Combat/Melee/DragonRush.dm`
- `src/Code/Combat/Melee/PressurePunch.dm`
- `src/Code/Combat/Melee/RoundhouseKick.dm`
- `src/Code/Combat/Melee/SuperDropkick.dm`
- `src/Code/Combat/Melee/WolfFangFist.dm`
- `src/Code/Combat/RareDeathEffects.dm`
- `src/Code/Combat/RevengeSystem.dm`
- `src/Code/Combat/RockThrow.dm`
- `src/Code/Combat/Skills.dm`
- `src/Code/Combat/SpeedDelay.dm`
- `src/Code/Combat/SplitForms.dm`
- `src/Code/Combat/Targeting/Targeting.dm`
- `src/Code/Combat/Targeting/TargetingWrappers.dm`

## Proc Reference

### src/Code/Combat/BleedDamage.dm

#### mob/proc/BleedDamage
- Signature: `BleedDamage(n = 0)`
- Inputs: n = 0
- Purpose: Handle bleed damage.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BleedLoop
- Signature: `BleedLoop()`
- Inputs: None
- Purpose: Handle bleed loop.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Buffs.dm

#### mob/proc/Buff_Drain_Loop
- Signature: `mob/proc/Buff_Drain_Loop()`
- Inputs: None
- Purpose: Handle buff drain loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/buffed
- Signature: `mob/proc/buffed()`
- Inputs: None
- Purpose: Handle buffed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/buffed_with_bp
- Signature: `mob/proc/buffed_with_bp()`
- Inputs: None
- Purpose: Handle buffed with bp.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Buff/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Buff/Del
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

#### verb/Buff
- Signature: `verb/Buff()`
- Inputs: None
- Purpose: Handle buff.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Buff_Options
- Signature: `verb/Buff_Options()`
- Inputs: None
- Purpose: Handle buff options.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Buffless_recovery
- Signature: `Buffless_recovery()`
- Inputs: None
- Purpose: Handle buffless recovery.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BufflessKiMod
- Signature: `BufflessKiMod()`
- Inputs: None
- Purpose: Handle buffless ki mod.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Buff_Enable
- Signature: `Buff_Enable(obj/Buff/O) if(!O.being_edited&&!Redoing_Stats)`
- Inputs: obj/Buff/O
- Purpose: Handle buff enable.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Rebuff_timer_countdown
- Signature: `Rebuff_timer_countdown()`
- Inputs: None
- Purpose: Handle rebuff timer countdown.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Buff_Disable
- Signature: `Buff_Disable(obj/Buff/O) if(O&&O.suffix)`
- Inputs: obj/Buff/O
- Purpose: Handle buff disable.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/buff_point
- Signature: `mob/verb/buff_point(posneg as text, buff_stat as text) //posneg = "-1" | "1". verb called thru skin`
- Inputs: posneg as text, buff_stat as text
- Purpose: Handle buff point.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/buff_done
- Signature: `mob/verb/buff_done() //verb called thru skin`
- Inputs: None
- Purpose: Handle buff done.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Refresh_Buff_Window
- Signature: `mob/proc/Refresh_Buff_Window(obj/Buff/B) if(client)`
- Inputs: obj/Buff/B
- Purpose: Handle refresh buff window.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Trans_Graphics
- Signature: `Trans_Graphics(list/L) if(L) for(var/V in L)`
- Inputs: list/L
- Purpose: Handle trans graphics.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Add_Trans_Effects
- Signature: `Add_Trans_Effects(list/L)`
- Inputs: list/L
- Purpose: Add Trans Effects.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Remove_Trans_Effects
- Signature: `Remove_Trans_Effects(list/L)`
- Inputs: list/L
- Purpose: Remove Trans Effects.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/Combat/Evasion.dm

#### mob/verb/Evade
- Signature: `Evade()`
- Inputs: None
- Purpose: Handle evade.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Delay_between_double_tap_dashes
- Signature: `Delay_between_double_tap_dashes()`
- Inputs: None
- Purpose: Handle delay between double tap dashes.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Dash_Evade
- Signature: `Dash_Evade(d,from_double_tap)`
- Inputs: d, from_double_tap
- Purpose: Handle dash evade.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Evade_meter_refill_loop
- Signature: `Evade_meter_refill_loop()`
- Inputs: None
- Purpose: Handle evade meter refill loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drain_evade_meter
- Signature: `Drain_evade_meter(mob/m, mult=1, is_melee=1) //is_melee determines if wearing a sword affects evasion`
- Inputs: mob/m, mult=1, is_melee=1
- Purpose: Handle drain evade meter.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Fill_evade_meter
- Signature: `Fill_evade_meter(mob/m,mult)`
- Inputs: mob/m, mult
- Purpose: Handle fill evade meter.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Evade_meter_requirement
- Signature: `Evade_meter_requirement(mob/m, mult=1, is_melee=1)`
- Inputs: mob/m, mult=1, is_melee=1
- Purpose: Handle evade meter requirement.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Evade_lunge
- Signature: `Evade_lunge(mob/m,dir_override,from_double_tap)`
- Inputs: mob/m, dir_override, from_double_tap
- Purpose: Handle evade lunge.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Start_evading
- Signature: `Start_evading()`
- Inputs: None
- Purpose: Start evading.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Start_blocking
- Signature: `Start_blocking()`
- Inputs: None
- Purpose: Start blocking.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Get_idle_state
- Signature: `Get_idle_state()`
- Inputs: None
- Purpose: Return idle state.
- Returns: computed value (see implementation).
- Side effects: none expected.

### src/Code/Combat/HokutoShinken.dm

#### obj/Hokuto_Shinken/New
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

#### verb/Hundred_Crack_Fist
- Signature: `verb/Hundred_Crack_Fist()`
- Inputs: None
- Purpose: Handle hundred crack fist.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Hokuto_Shinken_Effects
- Signature: `mob/proc/Hokuto_Shinken_Effects(mob/P)`
- Inputs: mob/P
- Purpose: Handle hokuto shinken effects.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Add_Hokuto_Shinken_Energy
- Signature: `mob/proc/Add_Hokuto_Shinken_Energy(mob/P) if(ismob(P)) if(!(locate(/obj/Hokuto_Shinken_Energy) in P))`
- Inputs: mob/P
- Purpose: Add Hokuto Shinken Energy.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/Combat/Injuries.dm

#### mob/verb/Injure
- Signature: `mob/verb/Injure()`
- Inputs: None
- Purpose: Handle injure.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Injury_Options
- Signature: `Injury_Options(mob/P)`
- Inputs: mob/P
- Purpose: Handle injury options.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Inflict_Injury
- Signature: `Inflict_Injury(mob/P,obj/Injuries/I)`
- Inputs: mob/P, obj/Injuries/I
- Purpose: Handle inflict injury.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Add_Injury_Overlays
- Signature: `mob/proc/Add_Injury_Overlays()`
- Inputs: None
- Purpose: Add Injury Overlays.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Blood_Color
- Signature: `mob/proc/Blood_Color()`
- Inputs: None
- Purpose: Handle blood color.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Injuries/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Injuries/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Ki Skills/DeathBall2017.dm

#### obj/Attacks/Genki_Dama/Death_Ball/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Attacks/Genki_Dama/Death_Ball/Hotbar_use
- Signature: `Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Death_Ball
- Signature: `verb/Death_Ball()`
- Inputs: None
- Purpose: Handle death ball.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Ki Skills/FinalExplosion.dm

#### mob/proc/FinalExplosionFollowOnMove
- Signature: `mob/proc/FinalExplosionFollowOnMove()`
- Inputs: None
- Purpose: Handle final explosion follow on move.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Final_Explosion/verb/Hotbar_use
- Signature: `Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Final_Explosion/verb/Final_Explosion
- Signature: `Final_Explosion()`
- Inputs: None
- Purpose: Handle final explosion.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Final_Explosion
- Signature: `Final_Explosion()`
- Inputs: None
- Purpose: Handle final explosion.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DoFinalExplosion
- Signature: `DoFinalExplosion()`
- Inputs: None
- Purpose: Perform Final Explosion.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BeginChargingFinalExplosion
- Signature: `BeginChargingFinalExplosion()`
- Inputs: None
- Purpose: Handle begin charging final explosion.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FinalExplosionDamage
- Signature: `FinalExplosionDamage()`
- Inputs: None
- Purpose: Handle final explosion damage.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FinalExplosionChargeupGraphics
- Signature: `FinalExplosionChargeupGraphics()`
- Inputs: None
- Purpose: Handle final explosion chargeup graphics.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FinalExplosionGraphics
- Signature: `FinalExplosionGraphics()`
- Inputs: None
- Purpose: Handle final explosion graphics.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/FinalExplosionDamage
- Signature: `FinalExplosionDamage(mob/user, dmg_percent = 0, wait_time = 0, wall_break_power = 1, user_bp = 1, user_force = 1)`
- Inputs: mob/user, dmg_percent = 0, wait_time = 0, wall_break_power = 1, user_bp = 1, user_force = 1
- Purpose: Handle final explosion damage.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ShieldDamageReduction
- Signature: `ShieldDamageReduction()`
- Inputs: None
- Purpose: Handle shield damage reduction.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Ki Skills/FusionSystem.dm

#### obj/Fusion_Dance/verb/Fusion_Dance
- Signature: `Fusion_Dance(var/mob/M in orange(usr,1))`
- Inputs: var/mob/M in orange(usr, 1
- Purpose: Handle fusion dance.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Potara/verb/Throw_Potara
- Signature: `Throw_Potara(var/mob/M in player_view(usr,15))`
- Inputs: var/mob/M in player_view(usr, 15
- Purpose: Handle throw potara.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Fusion_Proc
- Signature: `Fusion_Proc(mob/A,mob/B,var/perm) //perm=0 means dance, perm=1 means potara. A=passive B=in control`
- Inputs: mob/A, mob/B, var/perm
- Purpose: Handle fusion proc.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Unfuse
- Signature: `Unfuse(mob/A)`
- Inputs: mob/A
- Purpose: Handle unfuse.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Splice_Overlays
- Signature: `Splice_Overlays(mob/A,mob/B)`
- Inputs: mob/A, mob/B
- Purpose: Handle splice overlays.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Fusion_Success
- Signature: `Fusion_Success(var/mob/A,var/mob/B)`
- Inputs: var/mob/A, var/mob/B
- Purpose: Handle fusion success.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Learn_Fusion
- Signature: `Learn_Fusion()`
- Inputs: None
- Purpose: Handle learn fusion.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Make_Potara
- Signature: `Make_Potara()`
- Inputs: None
- Purpose: Handle make potara.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Ki Skills/Hakai.dm

#### mob/proc/CanUseHakai
- Signature: `CanUseHakai()`
- Inputs: None
- Purpose: Return whether Use Hakai.
- Returns: boolean flag.
- Side effects: none expected.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hakai
- Signature: `verb/Hakai()`
- Inputs: None
- Purpose: Handle hakai.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BeginHakai
- Signature: `BeginHakai(mob/m)`
- Inputs: mob/m
- Purpose: Handle begin hakai.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/StrongEnoughToHakai
- Signature: `StrongEnoughToHakai(mob/m)`
- Inputs: mob/m
- Purpose: Handle strong enough to hakai.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/CheckHakaiDeleteCharacter
- Signature: `proc/CheckHakaiDeleteCharacter(mob/m)`
- Inputs: mob/m
- Purpose: Check Hakai Delete Character.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/HakaiOverlay
- Signature: `proc/HakaiOverlay(mob/m, hakai_time = 50)`
- Inputs: mob/m, hakai_time = 50
- Purpose: Handle hakai overlay.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Ki Skills/Kikoho2016.dm

#### mob/proc/IsValidKikohoTarget
- Signature: `mob/proc/IsValidKikohoTarget(mob/m)`
- Inputs: mob/m
- Purpose: Return whether Valid Kikoho Target.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/GetKikohoTarget
- Signature: `mob/proc/GetKikohoTarget()`
- Inputs: None
- Purpose: Return Kikoho Target.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Kikoho
- Signature: `verb/Kikoho()`
- Inputs: None
- Purpose: Handle kikoho.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/KikohoCrater
- Signature: `KikohoCrater(turf/t)`
- Inputs: turf/t
- Purpose: Handle kikoho crater.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/KikohoExplosion
- Signature: `KikohoExplosion(turf/t)`
- Inputs: turf/t
- Purpose: Handle kikoho explosion.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/KikohoDust
- Signature: `KikohoDust(turf/t)`
- Inputs: turf/t
- Purpose: Handle kikoho dust.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/KikohoRocks
- Signature: `KikohoRocks(turf/t)`
- Inputs: turf/t
- Purpose: Handle kikoho rocks.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/StopBeaming
- Signature: `StopBeaming()`
- Inputs: None
- Purpose: Stop Beaming.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/CancelAllAttacks
- Signature: `CancelAllAttacks()`
- Inputs: None
- Purpose: Handle cancel all attacks.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GetHitByKikoho
- Signature: `GetHitByKikoho(mob/a) //a = attacker`
- Inputs: mob/a
- Purpose: Return Hit By Kikoho.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/KikohoKnockAwayNonTargets
- Signature: `KikohoKnockAwayNonTargets(mob/t) //t = target, usr = firer`
- Inputs: mob/t
- Purpose: Handle kikoho knock away non targets.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/KikohoDamageLoop
- Signature: `KikohoDamageLoop()`
- Inputs: None
- Purpose: Handle kikoho damage loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/KikohoDamageTo
- Signature: `KikohoDamageTo(mob/m)`
- Inputs: mob/m
- Purpose: Handle kikoho damage to.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FireKikoho
- Signature: `FireKikoho(obj/Attacks/Kikoho/k)`
- Inputs: obj/Attacks/Kikoho/k
- Purpose: Handle fire kikoho.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/KikohoRefire
- Signature: `KikohoRefire(mult = 1)`
- Inputs: mult = 1
- Purpose: Handle kikoho refire.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/KikohoAtmosphereEffect
- Signature: `KikohoAtmosphereEffect()`
- Inputs: None
- Purpose: Handle kikoho atmosphere effect.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/KikohoChargeupEffect
- Signature: `KikohoChargeupEffect(grow_til = 0.5)`
- Inputs: grow_til = 0.5
- Purpose: Handle kikoho chargeup effect.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/KikohoOrangeAtmosphere
- Signature: `KikohoOrangeAtmosphere()`
- Inputs: None
- Purpose: Handle kikoho orange atmosphere.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Crater/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Crater/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Crater/proc/KikohoCraterDeleteCheck
- Signature: `KikohoCraterDeleteCheck()`
- Inputs: None
- Purpose: Handle kikoho crater delete check.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Flash/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Rock/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Rock/proc/KikohoRock
- Signature: `KikohoRock()`
- Inputs: None
- Purpose: Handle kikoho rock.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Rock/proc/KikohoRockFlyOff
- Signature: `KikohoRockFlyOff()`
- Inputs: None
- Purpose: Handle kikoho rock fly off.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Dust/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Dust/proc/KikohoDust
- Signature: `KikohoDust()`
- Inputs: None
- Purpose: Handle kikoho dust.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Explosion/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Explosion/proc/KikohoExplosion
- Signature: `KikohoExplosion()`
- Inputs: None
- Purpose: Handle kikoho explosion.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Ki Skills/Sense 2017/Sense.dm

#### mob/verb/Toggle_Sense_Overlay
- Signature: `mob/verb/Toggle_Sense_Overlay()`
- Inputs: None
- Purpose: Toggle Sense Overlay.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### obj/Screen_Indicator/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Screen_Indicator/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Screen_Indicator/proc/SenseArrowMatchAppearance
- Signature: `SenseArrowMatchAppearance(update_overlays = 1)`
- Inputs: update_overlays = 1
- Purpose: Handle sense arrow match appearance.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Screen_Indicator/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/UpdateSenseArrowPositionsLoop
- Signature: `UpdateSenseArrowPositionsLoop()`
- Inputs: None
- Purpose: Update Sense Arrow Positions Loop.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/UpdateSenseArrowPositions
- Signature: `UpdateSenseArrowPositions()`
- Inputs: None
- Purpose: Update Sense Arrow Positions.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/UpdateSenseArrowPosition
- Signature: `UpdateSenseArrowPosition(obj/Screen_Indicator/si, instant_update = 0)`
- Inputs: obj/Screen_Indicator/si, instant_update = 0
- Purpose: Update Sense Arrow Position.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/SenseArrowDistanceMod
- Signature: `SenseArrowDistanceMod(obj/Screen_Indicator/si)`
- Inputs: obj/Screen_Indicator/si
- Purpose: Handle sense arrow distance mod.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/UpdateSenseArrowSizeBasedOnPower
- Signature: `UpdateSenseArrowSizeBasedOnPower(obj/Screen_Indicator/si)`
- Inputs: obj/Screen_Indicator/si
- Purpose: Update Sense Arrow Size Based On Power.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/RemoveSenseArrow
- Signature: `RemoveSenseArrow(obj/Screen_Indicator/si)`
- Inputs: obj/Screen_Indicator/si
- Purpose: Remove Sense Arrow.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/AddSenseArrow
- Signature: `AddSenseArrow(obj/Screen_Indicator/si, clr)`
- Inputs: obj/Screen_Indicator/si, clr
- Purpose: Add Sense Arrow.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/RemoveAllSenseArrows
- Signature: `RemoveAllSenseArrows()`
- Inputs: None
- Purpose: Remove All Sense Arrows.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/UpdateSenseArrowList
- Signature: `UpdateSenseArrowList(area/a)`
- Inputs: area/a
- Purpose: Update Sense Arrow List.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/GetSenseArrowColor
- Signature: `GetSenseArrowColor(mob/m)`
- Inputs: mob/m
- Purpose: Return Sense Arrow Color.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/GetSenseArrowColorByRace
- Signature: `GetSenseArrowColorByRace(race, class)`
- Inputs: race, class
- Purpose: Return Sense Arrow Color By Race.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### area/proc/AreaUpdateSenseTargets
- Signature: `AreaUpdateSenseTargets()`
- Inputs: None
- Purpose: Handle area update sense targets.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GetNewScreenIndicator
- Signature: `GetNewScreenIndicator()`
- Inputs: None
- Purpose: Return New Screen Indicator.
- Returns: computed value (see implementation).
- Side effects: none expected.

### src/Code/Combat/Ki Skills/SolarFlare.dm

#### mob/proc/TrySolarFlare
- Signature: `TrySolarFlare()`
- Inputs: None
- Purpose: Handle try solar flare.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanSolarFlare
- Signature: `CanSolarFlare()`
- Inputs: None
- Purpose: Return whether Solar Flare.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/SolarFlare
- Signature: `SolarFlare()`
- Inputs: None
- Purpose: Handle solar flare.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GetSolarFlareRangeMod
- Signature: `GetSolarFlareRangeMod()`
- Inputs: None
- Purpose: Return Solar Flare Range Mod.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/GetSolarFlareAffectees
- Signature: `GetSolarFlareAffectees(dist = 1)`
- Inputs: dist = 1
- Purpose: Return Solar Flare Affectees.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/SolarFlareAffectMobs
- Signature: `SolarFlareAffectMobs(list/mobs, dist = 1)`
- Inputs: list/mobs, dist = 1
- Purpose: Handle solar flare affect mobs.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SolarFlareScreenOverlay
- Signature: `SolarFlareScreenOverlay(mob/a) //a = attacker`
- Inputs: mob/a
- Purpose: Handle solar flare screen overlay.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SolarFlareFX
- Signature: `SolarFlareFX(list/mobs, dist = 1)`
- Inputs: list/mobs, dist = 1
- Purpose: Handle solar flare fx.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SolarFlareHurtVampires
- Signature: `SolarFlareHurtVampires(list/mobs)`
- Inputs: list/mobs
- Purpose: Handle solar flare hurt vampires.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SolarFlareHurtVampire
- Signature: `SolarFlareHurtVampire(mob/m) //m = attacker`
- Inputs: mob/m
- Purpose: Handle solar flare hurt vampire.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Ki Skills/SpiritBomb2016.dm

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Genki_Dama
- Signature: `verb/Genki_Dama()`
- Inputs: None
- Purpose: Handle genki dama.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blast/Genki_Dama/proc/SpiritBombGoOffSomewhere
- Signature: `SpiritBombGoOffSomewhere()`
- Inputs: None
- Purpose: Handle spirit bomb go off somewhere.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombSpawnLoc
- Signature: `SpiritBombSpawnLoc(y_offset = 6)`
- Inputs: y_offset = 6
- Purpose: Handle spirit bomb spawn loc.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanSpiritBomb
- Signature: `CanSpiritBomb(why = 0, obj/Attacks/Genki_Dama/sb)`
- Inputs: why = 0, obj/Attacks/Genki_Dama/sb
- Purpose: Return whether Spirit Bomb.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/TrySpiritBomb2017
- Signature: `TrySpiritBomb2017(obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Attacks/Genki_Dama/sb
- Purpose: Handle try spirit bomb2017.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBomb2017
- Signature: `SpiritBomb2017(obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Attacks/Genki_Dama/sb
- Purpose: Handle spirit bomb2017.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombThrow
- Signature: `SpiritBombThrow(obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Attacks/Genki_Dama/sb
- Purpose: Handle spirit bomb throw.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombGuidedMovement
- Signature: `SpiritBombGuidedMovement()`
- Inputs: None
- Purpose: Handle spirit bomb guided movement.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/LastSpiritBombValid
- Signature: `LastSpiritBombValid()`
- Inputs: None
- Purpose: Handle last spirit bomb valid.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombBegin
- Signature: `SpiritBombBegin(obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Attacks/Genki_Dama/sb
- Purpose: Handle spirit bomb begin.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombEnergyParticlesGatherLoop
- Signature: `SpiritBombEnergyParticlesGatherLoop(obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb
- Purpose: Handle spirit bomb energy particles gather loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DoSomeSpiritBombParticles
- Signature: `DoSomeSpiritBombParticles(obj/particle, turf/dest, amount = 5, list/from)`
- Inputs: obj/particle, turf/dest, amount = 5, list/from
- Purpose: Perform Some Spirit Bomb Particles.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombSizeGrow
- Signature: `SpiritBombSizeGrow(obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb
- Purpose: Handle spirit bomb size grow.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombSpin
- Signature: `SpiritBombSpin(obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb
- Purpose: Handle spirit bomb spin.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombInterrupted
- Signature: `SpiritBombInterrupted()`
- Inputs: None
- Purpose: Handle spirit bomb interrupted.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombInterrupt
- Signature: `SpiritBombInterrupt(obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb
- Purpose: Handle spirit bomb interrupt.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombDone
- Signature: `SpiritBombDone(obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Attacks/Genki_Dama/sb
- Purpose: Handle spirit bomb done.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombChargeTime
- Signature: `SpiritBombChargeTime(obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Attacks/Genki_Dama/sb
- Purpose: Handle spirit bomb charge time.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombPowerGrow
- Signature: `SpiritBombPowerGrow(obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb
- Purpose: Handle spirit bomb power grow.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Ki Skills/Supernova.dm

#### obj/Attacks/Genki_Dama/Supernova/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Attacks/Genki_Dama/Supernova/Hotbar_use
- Signature: `Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Supernova
- Signature: `verb/Supernova()`
- Inputs: None
- Purpose: Handle supernova.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Math/CombatMath.dm

#### proc/AccuracyFormula
- Signature: `proc/AccuracyFormula(mob/Offender,mob/Defender,KiManip=0,Chance=WorldDefaultAcc)`
- Inputs: mob/Offender, mob/Defender, KiManip=0, Chance=WorldDefaultAcc
- Purpose: Handle accuracy formula.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DamageFormula
- Signature: `proc/DamageFormula(mob/Offender,mob/Defender,Strength=1,Force=0,Speed=0,Offense=0,DamageType="Physical",BaselineDamage=2,FlatDamage=0,UsesWeapon=1,IgnoresEnd=0)`
- Inputs: mob/Offender, mob/Defender, Strength=1, Force=0, Speed=0, Offense=0, DamageType="Physical", BaselineDamage=2, FlatDamage=0, UsesWeapon=1, IgnoresEnd=0
- Purpose: Handle damage formula.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/KiDamageFormula
- Signature: `proc/KiDamageFormula(mob/Offender,mob/Defender,Strength=1,Force=0,Speed=0,Offense=0,DamageType="Physical",BaselineDamage=3,FlatDamage=0,UsesWeapon=1,IgnoresEnd=0)`
- Inputs: mob/Offender, mob/Defender, Strength=1, Force=0, Speed=0, Offense=0, DamageType="Physical", BaselineDamage=3, FlatDamage=0, UsesWeapon=1, IgnoresEnd=0
- Purpose: Handle ki damage formula.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Knockback
- Signature: `mob/proc/Knockback(Distance,mob/P,Direction=get_dir(P,src),KB_Damage=1) spawn if(src)//Some abilities won't damage upon KB`
- Inputs: Distance, mob/P, Direction=get_dir(P, src
- Purpose: Handle knockback.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/MegatonThrow.dm

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/PocketSand/verb/PocketSand
- Signature: `PocketSand()`
- Inputs: None
- Purpose: Handle pocket sand.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/ExplodingHeartStrike/verb/ExplodingHeartStrike
- Signature: `ExplodingHeartStrike()`
- Inputs: None
- Purpose: Handle exploding heart strike.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/MegatonThrow/verb/MegatonThrow
- Signature: `MegatonThrow()`
- Inputs: None
- Purpose: Handle megaton throw.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PocketSandFX
- Signature: `PocketSandFX()`
- Inputs: None
- Purpose: Handle pocket sand fx.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PocketSand
- Signature: `PocketSand()`
- Inputs: None
- Purpose: Handle pocket sand.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ExplodingHeartStrikeFX
- Signature: `ExplodingHeartStrikeFX()`
- Inputs: None
- Purpose: Handle exploding heart strike fx.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ExplodingHeartStrike
- Signature: `ExplodingHeartStrike()`
- Inputs: None
- Purpose: Handle exploding heart strike.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MegatonThrow
- Signature: `MegatonThrow()`
- Inputs: None
- Purpose: Handle megaton throw.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MegatonToss
- Signature: `MegatonToss(mob/M)`
- Inputs: mob/M
- Purpose: Handle megaton toss.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Melee.dm

#### mob/proc/GetSpeedDamageDecrease
- Signature: `mob/proc/GetSpeedDamageDecrease()`
- Inputs: None
- Purpose: Return Speed Damage Decrease.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Opponent
- Signature: `mob/proc/Opponent(timeLimit = 65)`
- Inputs: timeLimit = 65
- Purpose: Handle opponent.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/setOpponent
- Signature: `mob/proc/setOpponent(mob/M)`
- Inputs: mob/M
- Purpose: Set Opponent.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/ShouldMeleeInjureSelf
- Signature: `ShouldMeleeInjureSelf(mob/m)`
- Inputs: mob/m
- Purpose: Handle should melee injure self.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MeleeInjureSelfCheck
- Signature: `MeleeInjureSelfCheck(mob/m)`
- Inputs: mob/m
- Purpose: Handle melee injure self check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MeleeInjureSelf
- Signature: `MeleeInjureSelf()`
- Inputs: None
- Purpose: Handle melee injure self.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MeleeInjury2017
- Signature: `MeleeInjury2017()`
- Inputs: None
- Purpose: Handle melee injury2017.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GetArmOrLegInjury
- Signature: `proc/GetArmOrLegInjury()`
- Inputs: None
- Purpose: Return Arm Or Leg Injury.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/AllAttacksDamageModifiers
- Signature: `mob/proc/AllAttacksDamageModifiers(mob/target) //target = who you are attacking`
- Inputs: mob/target
- Purpose: Handle all attacks damage modifiers.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/TakeDamage
- Signature: `mob/proc/TakeDamage(dmg = 0, stun_damage_mod = 0.6, knockback = 0)`
- Inputs: dmg = 0, stun_damage_mod = 0.6, knockback = 0
- Purpose: Handle take damage.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PowerupDamageGrabber
- Signature: `mob/proc/PowerupDamageGrabber(n = 1) //multiply by n for "damage per second" regardless of call rate`
- Inputs: n = 1
- Purpose: Handle powerup damage grabber.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Fill_power_attack_meter
- Signature: `Fill_power_attack_meter()`
- Inputs: None
- Purpose: Handle fill power attack meter.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Can_power_attack
- Signature: `Can_power_attack()`
- Inputs: None
- Purpose: Return whether power attack.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Power_attack_chargeup_time
- Signature: `Power_attack_chargeup_time(mob/m)`
- Inputs: mob/m
- Purpose: Handle power attack chargeup time.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Trying_to_power_attack
- Signature: `Trying_to_power_attack()`
- Inputs: None
- Purpose: Handle trying to power attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_lunge_drawback_graphic
- Signature: `proc/Get_lunge_drawback_graphic()`
- Inputs: None
- Purpose: Return lunge drawback graphic.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### obj/Lunge_Graphic/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Lunge_Graphic/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Lunge_stick_to
- Signature: `proc/Lunge_stick_to(mob/center)`
- Inputs: mob/center
- Purpose: Handle lunge stick to.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Lunge_go
- Signature: `proc/Lunge_go(mob/center)`
- Inputs: mob/center
- Purpose: Handle lunge go.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Can_lunge
- Signature: `mob/proc/Can_lunge()`
- Inputs: None
- Purpose: Return whether lunge.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Lunge_refire
- Signature: `mob/proc/Lunge_refire()`
- Inputs: None
- Purpose: Handle lunge refire.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Lunge_toward
- Signature: `mob/proc/Lunge_toward(mob/m)`
- Inputs: mob/m
- Purpose: Handle lunge toward.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Lunge_step_delay
- Signature: `mob/proc/Lunge_step_delay()`
- Inputs: None
- Purpose: Handle lunge step delay.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Mob_in_front
- Signature: `mob/proc/Mob_in_front()`
- Inputs: None
- Purpose: Handle mob in front.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Cancel_lunge
- Signature: `mob/proc/Cancel_lunge()`
- Inputs: None
- Purpose: Handle cancel lunge.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Do_lunge_drawback_animation
- Signature: `mob/proc/Do_lunge_drawback_animation()`
- Inputs: None
- Purpose: Perform lunge drawback animation.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Get_lunge_distance
- Signature: `mob/proc/Get_lunge_distance()`
- Inputs: None
- Purpose: Return lunge distance.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Get_lunge_targeting_distance
- Signature: `mob/proc/Get_lunge_targeting_distance()`
- Inputs: None
- Purpose: Return lunge targeting distance.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### atom/movable/proc/At_forward_half
- Signature: `atom/movable/proc/At_forward_half(mob/m)`
- Inputs: mob/m
- Purpose: Handle at forward half.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/find_melee_target
- Signature: `mob/proc/find_melee_target(mob/O,from_auto_attack)`
- Inputs: mob/O, from_auto_attack
- Purpose: Handle find melee target.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Defense_damage_reduction
- Signature: `proc/Defense_damage_reduction(mob/attacker,mob/defender)`
- Inputs: mob/attacker, mob/defender
- Purpose: Handle defense damage reduction.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/get_melee_damage
- Signature: `mob/proc/get_melee_damage(mob/m, count_sword = 1, for_strangle, allow_one_shot = 1, swordMod = 1)`
- Inputs: mob/m, count_sword = 1, for_strangle, allow_one_shot = 1, swordMod = 1
- Purpose: Return melee damage.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/verb/ToggleBreakingThings
- Signature: `mob/verb/ToggleBreakingThings()`
- Inputs: None
- Purpose: Toggle Breaking Things.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/verb/ToggleSparringMode
- Signature: `mob/verb/ToggleSparringMode()`
- Inputs: None
- Purpose: Toggle Sparring Mode.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/SetSparringMode
- Signature: `mob/proc/SetSparringMode(mode = sparring_mode, show_message = TRUE)`
- Inputs: mode = sparring_mode, show_message = TRUE
- Purpose: Set Sparring Mode.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/AlertSparringMode
- Signature: `mob/proc/AlertSparringMode(var/mob/attacker, var/mob/victim)`
- Inputs: var/mob/attacker, var/mob/victim
- Purpose: Handle alert sparring mode.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/WallBreakPower
- Signature: `mob/proc/WallBreakPower()`
- Inputs: None
- Purpose: Handle wall break power.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/teststatrating
- Signature: `mob/proc/teststatrating()`
- Inputs: None
- Purpose: Handle teststatrating.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/testwallbreakpower
- Signature: `mob/Admin5/verb/testwallbreakpower(mob/m in world)`
- Inputs: mob/m in world
- Purpose: Handle testwallbreakpower.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Is_wall_breaker
- Signature: `mob/proc/Is_wall_breaker()`
- Inputs: None
- Purpose: Return whether wall breaker.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/Admin5/verb/constant_max_speed
- Signature: `mob/Admin5/verb/constant_max_speed()`
- Inputs: None
- Purpose: Handle constant max speed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/const_max_speed
- Signature: `proc/const_max_speed()`
- Inputs: None
- Purpose: Handle const max speed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/fight
- Signature: `mob/verb/fight(mob/a in world)`
- Inputs: mob/a in world
- Purpose: Handle fight.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Speed_accuracy_mult
- Signature: `mob/proc/Speed_accuracy_mult(mob/defender)`
- Inputs: mob/defender
- Purpose: Handle speed accuracy mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Acc_mult
- Signature: `proc/Acc_mult(n=1)`
- Inputs: n=1
- Purpose: Handle acc mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DodgeStamCost
- Signature: `mob/proc/DodgeStamCost(mob/attacker)`
- Inputs: mob/attacker
- Purpose: Handle dodge stam cost.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/get_melee_accuracy
- Signature: `mob/proc/get_melee_accuracy(mob/m)`
- Inputs: mob/m
- Purpose: Return melee accuracy.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/GetSkillDrain
- Signature: `mob/proc/GetSkillDrain(mod = 1, is_energy = 0)`
- Inputs: mod = 1, is_energy = 0
- Purpose: Return Skill Drain.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/get_melee_knockback_distance
- Signature: `mob/proc/get_melee_knockback_distance(mob/m)`
- Inputs: mob/m
- Purpose: Return melee knockback distance.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/get_melee_sounds
- Signature: `mob/proc/get_melee_sounds(knockback_dist=0)`
- Inputs: knockback_dist=0
- Purpose: Return melee sounds.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/using_sword
- Signature: `mob/proc/using_sword()`
- Inputs: None
- Purpose: Handle using sword.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/if_target_is_splitform_then_target_attacks_you
- Signature: `mob/proc/if_target_is_splitform_then_target_attacks_you(mob/target)`
- Inputs: mob/target
- Purpose: Handle if target is splitform then target attacks you.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/zombie_melee_infection
- Signature: `mob/proc/zombie_melee_infection(mob/target)`
- Inputs: mob/target
- Purpose: Handle zombie melee infection.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Combo_recharge
- Signature: `mob/proc/Combo_recharge()`
- Inputs: None
- Purpose: Handle combo recharge.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Combo_recharge_time
- Signature: `mob/proc/Combo_recharge_time()`
- Inputs: None
- Purpose: Handle combo recharge time.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Combo_drain
- Signature: `mob/proc/Combo_drain(mob/a,mob/d)`
- Inputs: mob/a, mob/d
- Purpose: Handle combo drain.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/combo_teleport
- Signature: `mob/proc/combo_teleport(mob/m)`
- Inputs: mob/m
- Purpose: Handle combo teleport.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/if_target_is_npc_target_attacks_you
- Signature: `mob/proc/if_target_is_npc_target_attacks_you(mob/target)`
- Inputs: mob/target
- Purpose: Handle if target is npc target attacks you.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Toggle_strangling
- Signature: `mob/proc/Toggle_strangling()`
- Inputs: None
- Purpose: Toggle strangling.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Get_melee_delay
- Signature: `mob/proc/Get_melee_delay(mult=1,injuries_matter=1)`
- Inputs: mult=1, injuries_matter=1
- Purpose: Return melee delay.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Reset_melee
- Signature: `mob/proc/Reset_melee()`
- Inputs: None
- Purpose: Handle reset melee.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MeleeFollowupAttackCheck
- Signature: `mob/proc/MeleeFollowupAttackCheck()`
- Inputs: None
- Purpose: Handle melee followup attack check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/LungeAttack
- Signature: `mob/proc/LungeAttack()`
- Inputs: None
- Purpose: Handle lunge attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Melee
- Signature: `mob/proc/Melee(obj/O, from_auto_attack, force_power_attack, lunge_allowed = 0)`
- Inputs: obj/O, from_auto_attack, force_power_attack, lunge_allowed = 0
- Purpose: Handle melee.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MeleeAutoDodge
- Signature: `mob/proc/MeleeAutoDodge(mob/attacker)`
- Inputs: mob/attacker
- Purpose: Handle melee auto dodge.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanMeleeDodge
- Signature: `mob/proc/CanMeleeDodge(mob/attacker)`
- Inputs: mob/attacker
- Purpose: Return whether Melee Dodge.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/CanBlastDeflect
- Signature: `mob/proc/CanBlastDeflect(mob/attacker)`
- Inputs: mob/attacker
- Purpose: Return whether Blast Deflect.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Dodge_animation
- Signature: `mob/proc/Dodge_animation()`
- Inputs: None
- Purpose: Handle dodge animation.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Play_Melee_Sound
- Signature: `proc/Play_Melee_Sound(sound_range=10,mob/origin,sound_file,sound_volume=20)`
- Inputs: sound_range=10, mob/origin, sound_file, sound_volume=20
- Purpose: Handle play melee sound.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Melee_Shockwave_Repel
- Signature: `mob/proc/Melee_Shockwave_Repel(mob/target) //target = the person you just attacked, so we can exclude them from the repel`
- Inputs: mob/target
- Purpose: Handle melee shockwave repel.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MeleeRepelMob
- Signature: `MeleeRepelMob(mob/m, kb_pow = 1)`
- Inputs: mob/m, kb_pow = 1
- Purpose: Handle melee repel mob.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GetCriticalChance
- Signature: `mob/proc/GetCriticalChance()`
- Inputs: None
- Purpose: Return Critical Chance.
- Returns: computed value (see implementation).
- Side effects: none expected.

### src/Code/Combat/Melee/DragonRush.dm

#### mob/proc/CheckLungeDragonRush
- Signature: `CheckLungeDragonRush(mob/a, mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Check Lunge Dragon Rush.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DragonRushAnimationLoop
- Signature: `DragonRushAnimationLoop()`
- Inputs: None
- Purpose: Handle dragon rush animation loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DragonRushSFXLoop
- Signature: `DragonRushSFXLoop()`
- Inputs: None
- Purpose: Handle dragon rush sfxloop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/EndDragonRush
- Signature: `EndDragonRush()`
- Inputs: None
- Purpose: Handle end dragon rush.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/StartDragonRushVars
- Signature: `StartDragonRushVars()`
- Inputs: None
- Purpose: Start Dragon Rush Vars.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/PressedTowardEnemy
- Signature: `PressedTowardEnemy(mob/m)`
- Inputs: mob/m
- Purpose: Handle pressed toward enemy.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/WrongPressTowardEnemy
- Signature: `WrongPressTowardEnemy(mob/m)`
- Inputs: mob/m
- Purpose: Handle wrong press toward enemy.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/NewDragonRushLoc
- Signature: `NewDragonRushLoc(mob/m)`
- Inputs: mob/m
- Purpose: Handle new dragon rush loc.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FindNewDragonRushLoc
- Signature: `FindNewDragonRushLoc()`
- Inputs: None
- Purpose: Handle find new dragon rush loc.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DragonRushPointsToWin
- Signature: `DragonRushPointsToWin(mob/b)`
- Inputs: mob/b
- Purpose: Handle dragon rush points to win.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/IsValidDragonRushLoc
- Signature: `IsValidDragonRushLoc(turf/t)`
- Inputs: turf/t
- Purpose: Return whether Valid Dragon Rush Loc.
- Returns: boolean flag.
- Side effects: none expected.

#### proc/StartDragonRush
- Signature: `StartDragonRush(mob/a, mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Start Dragon Rush.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/DragonRushLoop
- Signature: `DragonRushLoop(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Handle dragon rush loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GetDragonRushWinner
- Signature: `GetDragonRushWinner(mob/a,mob/b,a_points = 0,b_points = 0)`
- Inputs: mob/a, mob/b, a_points = 0, b_points = 0
- Purpose: Return Dragon Rush Winner.
- Returns: computed value (see implementation).
- Side effects: none expected.

### src/Code/Combat/Melee/PressurePunch.dm

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/PressurePunch/verb/PressurePunch
- Signature: `PressurePunch()`
- Inputs: None
- Purpose: Handle pressure punch.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PressurePunchFX
- Signature: `PressurePunchFX()`
- Inputs: None
- Purpose: Handle pressure punch fx.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PressurePunch
- Signature: `PressurePunch()`
- Inputs: None
- Purpose: Handle pressure punch.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Melee/RoundhouseKick.dm

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/RoundhouseKick/verb/RoundhouseKick
- Signature: `RoundhouseKick()`
- Inputs: None
- Purpose: Handle roundhouse kick.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RoundhouseKickFX
- Signature: `RoundhouseKickFX()`
- Inputs: None
- Purpose: Handle roundhouse kick fx.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RoundhouseKick
- Signature: `RoundhouseKick()`
- Inputs: None
- Purpose: Handle roundhouse kick.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Melee/SuperDropkick.dm

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Dropkick/verb/Dropkick
- Signature: `Dropkick()`
- Inputs: None
- Purpose: Handle dropkick.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DropkickBPDebuff
- Signature: `DropkickBPDebuff()`
- Inputs: None
- Purpose: Handle dropkick bpdebuff.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DropkickFX
- Signature: `DropkickFX()`
- Inputs: None
- Purpose: Handle dropkick fx.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Dropkick
- Signature: `Dropkick()`
- Inputs: None
- Purpose: Handle dropkick.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DropkickCancelled
- Signature: `DropkickCancelled(mob/m, moved = 1)`
- Inputs: mob/m, moved = 1
- Purpose: Handle dropkick cancelled.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Melee/WolfFangFist.dm

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/WolfFangFist/verb/WolfFangFist
- Signature: `WolfFangFist()`
- Inputs: None
- Purpose: Handle wolf fang fist.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/WolfFangFistVFX
- Signature: `WolfFangFistVFX()`
- Inputs: None
- Purpose: Handle wolf fang fist vfx.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/WolfFangFist
- Signature: `WolfFangFist()`
- Inputs: None
- Purpose: Handle wolf fang fist.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/WolfFangFistCancelled
- Signature: `WolfFangFistCancelled(mob/victim, moved = 1)`
- Inputs: mob/victim, moved = 1
- Purpose: Handle wolf fang fist cancelled.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/RareDeathEffects.dm

#### mob/proc/Rare_death_check
- Signature: `mob/proc/Rare_death_check(mob/m) //m = the original mob. src = the body`
- Inputs: mob/m
- Purpose: Handle rare death check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BloodEffectsWaitForZero
- Signature: `mob/proc/BloodEffectsWaitForZero()`
- Inputs: None
- Purpose: Handle blood effects wait for zero.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Blood_splatter_effects
- Signature: `mob/proc/Blood_splatter_effects()`
- Inputs: None
- Purpose: Handle blood splatter effects.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/RevengeSystem.dm

#### mob/proc/GetRevengeInfo
- Signature: `GetRevengeInfo(mob/m)`
- Inputs: mob/m
- Purpose: Return Revenge Info.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/GetRevengeDmgMod
- Signature: `GetRevengeDmgMod(mob/m)`
- Inputs: mob/m
- Purpose: Return Revenge Dmg Mod.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/TryGiveRevengeAgainst
- Signature: `TryGiveRevengeAgainst(mob/m, effectMod = 1, timer = 12000)`
- Inputs: mob/m, effectMod = 1, timer = 12000
- Purpose: Handle try give revenge against.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GiveRevengeAgainst
- Signature: `GiveRevengeAgainst(mob/m, effectMod = 1, timer = 12000)`
- Inputs: mob/m, effectMod = 1, timer = 12000
- Purpose: Handle give revenge against.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/RockThrow.dm

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/RockThrow/verb/RockThrow
- Signature: `RockThrow()`
- Inputs: None
- Purpose: Handle rock throw.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/RockThrow/verb/Ki_Settings
- Signature: `Ki_Settings()`
- Inputs: None
- Purpose: Handle ki settings.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/RockSlide/verb/RockSlide
- Signature: `RockSlide()`
- Inputs: None
- Purpose: Handle rock slide.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/RockTomb/verb/RockTomb
- Signature: `RockTomb()`
- Inputs: None
- Purpose: Handle rock tomb.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RockThrowFX
- Signature: `RockThrowFX()`
- Inputs: None
- Purpose: Handle rock throw fx.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RockThrow
- Signature: `RockThrow()`
- Inputs: None
- Purpose: Handle rock throw.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RockSlideFX
- Signature: `RockSlideFX()`
- Inputs: None
- Purpose: Handle rock slide fx.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RockSlide
- Signature: `RockSlide()`
- Inputs: None
- Purpose: Handle rock slide.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RockTombFX
- Signature: `RockTombFX()`
- Inputs: None
- Purpose: Handle rock tomb fx.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RockTomb
- Signature: `RockTomb()`
- Inputs: None
- Purpose: Handle rock tomb.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Skills.dm

#### obj/Giant_Form/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Giant_Form/Del
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

#### verb/Giant_Form
- Signature: `verb/Giant_Form()`
- Inputs: None
- Purpose: Handle giant form.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Toggle_giant_form
- Signature: `Toggle_giant_form(obj/Giant_Form/g)`
- Inputs: obj/Giant_Form/g
- Purpose: Toggle giant form.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Enable_giant_form
- Signature: `Enable_giant_form(obj/Giant_Form/g)`
- Inputs: obj/Giant_Form/g
- Purpose: Handle enable giant form.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Disable_giant_form
- Signature: `Disable_giant_form(icon_change=1)`
- Inputs: icon_change=1
- Purpose: Handle disable giant form.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Limit_Breaker/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Limit_Breaker/Del
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

#### verb/Limit_Breaker
- Signature: `verb/Limit_Breaker()`
- Inputs: None
- Purpose: Handle limit breaker.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Limit_Revert
- Signature: `mob/proc/Limit_Revert() if(limit_breaker_on)`
- Inputs: None
- Purpose: Handle limit revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hide_Energy/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/delete_self
- Signature: `proc/delete_self()`
- Inputs: None
- Purpose: Delete self.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### verb/Hide_Energy
- Signature: `verb/Hide_Energy()`
- Inputs: None
- Purpose: Handle hide energy.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Dash_Attack
- Signature: `verb/Dash_Attack()`
- Inputs: None
- Purpose: Handle dash attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Dash_Attack
- Signature: `mob/proc/Dash_Attack()`
- Inputs: None
- Purpose: Handle dash attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DashAttackPart2
- Signature: `mob/proc/DashAttackPart2(mob/a, KB_Distance) //a = attacker`
- Inputs: mob/a, KB_Distance
- Purpose: Handle dash attack part2.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Forget_Skill
- Signature: `mob/verb/Forget_Skill()`
- Inputs: None
- Purpose: Handle forget skill.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Destroy_Soul_Contracts
- Signature: `mob/proc/Destroy_Soul_Contracts(soul_percent=100)`
- Inputs: soul_percent=100
- Purpose: Handle destroy soul contracts.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Contract_Soul /Appears in the Souls tab/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Contract_Soul /Appears in the Souls tab/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Contract_Soul /Appears in the Souls tab/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Soul_Contract_Update
- Signature: `proc/Soul_Contract_Update(mob/M) if(M)`
- Inputs: mob/M
- Purpose: Handle soul contract update.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Update_soul_contracts
- Signature: `mob/proc/Update_soul_contracts()`
- Inputs: None
- Purpose: Update soul contracts.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### verb/Soul_Contract
- Signature: `verb/Soul_Contract()`
- Inputs: None
- Purpose: Handle soul contract.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Soul_Contract
- Signature: `mob/proc/Soul_Contract(obj/Demon_Contract/SC)`
- Inputs: obj/Demon_Contract/SC
- Purpose: Handle soul contract.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Soul_Weapon
- Signature: `verb/Soul_Weapon()`
- Inputs: None
- Purpose: Handle soul weapon.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Soul_Weapon
- Signature: `mob/proc/Soul_Weapon(obj/Soul_Weapon/soul_weapon)`
- Inputs: obj/Soul_Weapon/soul_weapon
- Purpose: Handle soul weapon.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Soul_Attack
- Signature: `verb/Soul_Attack()`
- Inputs: None
- Purpose: Handle soul attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Soul_Attack
- Signature: `mob/proc/Soul_Attack(obj/Soul_Attack/Soul_Attack, range_y, range_x, duration)`
- Inputs: obj/Soul_Attack/Soul_Attack, range_y, range_x, duration
- Purpose: Handle soul attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Meditate_Level_2/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Sense/New
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

#### verb/Shadow_Spar
- Signature: `verb/Shadow_Spar()`
- Inputs: None
- Purpose: Handle shadow spar.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Timed_Delete
- Signature: `proc/Timed_Delete(obj/O,T=100)`
- Inputs: obj/O, T=100
- Purpose: Handle timed delete.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Rising_Aura
- Signature: `proc/Rising_Aura(obj/T,N=50)`
- Inputs: obj/T, N=50
- Purpose: Handle rising aura.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Rising_Aura/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Offsets
- Signature: `proc/Offsets(Offset=16)`
- Inputs: Offset=16
- Purpose: Handle offsets.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Aura_Walk
- Signature: `proc/Aura_Walk()`
- Inputs: None
- Purpose: Handle aura walk.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Regenerate
- Signature: `verb/Regenerate()`
- Inputs: None
- Purpose: Handle regenerate.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Give_Power
- Signature: `verb/Give_Power()`
- Inputs: None
- Purpose: Handle give power.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Give_Power
- Signature: `mob/proc/Give_Power(obj/Give_Power/G)`
- Inputs: obj/Give_Power/G
- Purpose: Handle give power.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Give_power_refill_loop
- Signature: `mob/proc/Give_power_refill_loop()`
- Inputs: None
- Purpose: Handle give power refill loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Zanzoken/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Combo_Toggle
- Signature: `verb/Combo_Toggle()`
- Inputs: None
- Purpose: Handle combo toggle.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Keep_Body/New
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

#### verb/Keep_Body
- Signature: `verb/Keep_Body()`
- Inputs: None
- Purpose: Handle keep body.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Shield/New
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

#### verb/Shield
- Signature: `verb/Shield()`
- Inputs: None
- Purpose: Handle shield.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Toggle_ki_shield
- Signature: `mob/proc/Toggle_ki_shield(obj/Shield/s)`
- Inputs: obj/Shield/s
- Purpose: Toggle ki shield.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/CanUseKiShield
- Signature: `mob/proc/CanUseKiShield()`
- Inputs: None
- Purpose: Return whether Use Ki Shield.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/UsingGuidedAttack
- Signature: `mob/proc/UsingGuidedAttack()`
- Inputs: None
- Purpose: Handle using guided attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Shield_Revert
- Signature: `mob/proc/Shield_Revert()`
- Inputs: None
- Purpose: Handle shield revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Make_Power_Fruit
- Signature: `verb/Make_Power_Fruit()`
- Inputs: None
- Purpose: Handle make power fruit.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Curse/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Curse/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/bind_check
- Signature: `proc/bind_check()`
- Inputs: None
- Purpose: Handle bind check.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/bind_power
- Signature: `proc/bind_power(mob/m)`
- Inputs: mob/m
- Purpose: Handle bind power.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/bind_time
- Signature: `proc/bind_time(mob/m)`
- Inputs: mob/m
- Purpose: Handle bind time.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Bind_Someone
- Signature: `verb/Bind_Someone()`
- Inputs: None
- Purpose: Handle bind someone.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/UnBind_Someone
- Signature: `verb/UnBind_Someone()`
- Inputs: None
- Purpose: Handle un bind someone.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Examine_List
- Signature: `proc/Examine_List()`
- Inputs: None
- Purpose: Handle examine list.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Examine
- Signature: `mob/verb/Examine(obj/A in Examine_List())`
- Inputs: obj/A in Examine_List(
- Purpose: Handle examine.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Strongest_Person
- Signature: `proc/Strongest_Person(mob/M)`
- Inputs: mob/M
- Purpose: Handle strongest person.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/strongest_person_proportionate
- Signature: `proc/strongest_person_proportionate(mob/m)`
- Inputs: mob/m
- Purpose: Handle strongest person proportionate.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Absorb
- Signature: `verb/Absorb()`
- Inputs: None
- Purpose: Handle absorb.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/power_absorb_mod
- Signature: `power_absorb_mod()`
- Inputs: None
- Purpose: Handle power absorb mod.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/knowledge_absorb_mod
- Signature: `knowledge_absorb_mod()`
- Inputs: None
- Purpose: Handle knowledge absorb mod.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Absorb
- Signature: `mob/proc/Absorb(mob/M, force_absorb)`
- Inputs: mob/M, force_absorb
- Purpose: Handle absorb.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/can_absorb
- Signature: `mob/proc/can_absorb(mob/M)`
- Inputs: mob/M
- Purpose: Return whether absorb.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/SI_Choices
- Signature: `mob/proc/SI_Choices()`
- Inputs: None
- Purpose: Handle si choices.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Cant_SI
- Signature: `mob/proc/Cant_SI(mob/A,show_message=1)`
- Inputs: mob/A, show_message=1
- Purpose: Handle cant si.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SI_disadvantage_mult
- Signature: `mob/proc/SI_disadvantage_mult(mob/m)`
- Inputs: mob/m
- Purpose: Handle si disadvantage mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Update_SI_disadvantage
- Signature: `mob/proc/Update_SI_disadvantage(mob/m)`
- Inputs: mob/m
- Purpose: Update SI disadvantage.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Instant_Transmission
- Signature: `verb/Instant_Transmission(mob/A in usr.SI_Choices())`
- Inputs: mob/A in usr.SI_Choices(
- Purpose: Handle instant transmission.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Cant_Kai_Teleport
- Signature: `mob/proc/Cant_Kai_Teleport(destination)`
- Inputs: destination
- Purpose: Handle cant kai teleport.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Planet_has_teleport_nullifier
- Signature: `proc/Planet_has_teleport_nullifier(planet,mob/reciever)`
- Inputs: planet, mob/reciever
- Purpose: Handle planet has teleport nullifier.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_kt_spawn
- Signature: `proc/Get_kt_spawn(area_name)`
- Inputs: area_name
- Purpose: Return kt spawn.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Kai_Teleport
- Signature: `verb/Kai_Teleport()`
- Inputs: None
- Purpose: Handle kai teleport.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/IncreaseGod_FistLevel
- Signature: `mob/proc/IncreaseGod_FistLevel()`
- Inputs: None
- Purpose: Handle increase god fist level.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PowerUpGoNextForm
- Signature: `mob/proc/PowerUpGoNextForm()`
- Inputs: None
- Purpose: Handle power up go next form.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Power_up
- Signature: `mob/proc/Power_up()`
- Inputs: None
- Purpose: Handle power up.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Power_Control/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Power_Control/Del
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

#### verb/Power_Up
- Signature: `verb/Power_Up()`
- Inputs: None
- Purpose: Handle power up.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Power_Down
- Signature: `verb/Power_Down()`
- Inputs: None
- Purpose: Handle power down.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/CenterIcon
- Signature: `proc/CenterIcon(obj/O,Icon,x_only)`
- Inputs: obj/O, Icon, x_only
- Purpose: Handle center icon.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Icon_Center_X
- Signature: `proc/Icon_Center_X(O)`
- Inputs: O
- Purpose: Handle icon center x.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Icon_Center_Y
- Signature: `proc/Icon_Center_Y(O)`
- Inputs: O
- Purpose: Handle icon center y.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Scaled_Icon
- Signature: `proc/Scaled_Icon(O,X,Y)`
- Inputs: O, X, Y
- Purpose: Handle scaled icon.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GetWidth
- Signature: `proc/GetWidth(O)`
- Inputs: O
- Purpose: Return Width.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/GetHeight
- Signature: `proc/GetHeight(O)`
- Inputs: O
- Purpose: Return Height.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### obj/Auras/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stop_Powering_Up
- Signature: `mob/proc/Stop_Powering_Up()`
- Inputs: None
- Purpose: Stop Powering Up.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/InitSuperGod_FistAura
- Signature: `proc/InitSuperGod_FistAura()`
- Inputs: None
- Purpose: Initialize Super God Fist Aura.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ShouldUseSuperGod_Fist
- Signature: `mob/proc/ShouldUseSuperGod_Fist()`
- Inputs: None
- Purpose: Handle should use super god fist.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CheckSuperGod_Fist
- Signature: `mob/proc/CheckSuperGod_Fist()`
- Inputs: None
- Purpose: Check Super God Fist.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Aura_Overlays
- Signature: `mob/proc/Aura_Overlays(remove_only)`
- Inputs: remove_only
- Purpose: Handle aura overlays.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Add_Sparks
- Signature: `mob/proc/Add_Sparks()`
- Inputs: None
- Purpose: Add Sparks.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### obj/Fly/New
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

#### verb/Fly
- Signature: `verb/Fly()`
- Inputs: None
- Purpose: Handle fly.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Layer_Update
- Signature: `mob/proc/Layer_Update()`
- Inputs: None
- Purpose: Handle layer update.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Fly
- Signature: `mob/proc/Fly(obj/Fly/F)`
- Inputs: obj/Fly/F
- Purpose: Handle fly.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Land
- Signature: `mob/proc/Land()`
- Inputs: None
- Purpose: Handle land.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Random_Fart
- Signature: `proc/Random_Fart()`
- Inputs: None
- Purpose: Handle random fart.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/Self_Destruct_Lightning
- Signature: `turf/proc/Self_Destruct_Lightning(B) if(B)`
- Inputs: B
- Purpose: Handle self destruct lightning.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Self_Destruct
- Signature: `verb/Self_Destruct()`
- Inputs: None
- Purpose: Handle self destruct.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_self_destruct_damage
- Signature: `proc/Get_self_destruct_damage(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Return self destruct damage.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/AOE_auto_dodge
- Signature: `mob/proc/AOE_auto_dodge(mob/attacker,turf/origin,min_dist=7,max_dist=10)`
- Inputs: mob/attacker, turf/origin, min_dist=7, max_dist=10
- Purpose: Handle aoe auto dodge.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Revive_Someone
- Signature: `verb/Revive_Someone()`
- Inputs: None
- Purpose: Handle revive someone.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Heal
- Signature: `verb/Heal()`
- Inputs: None
- Purpose: Handle heal.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/potential_mod
- Signature: `mob/proc/potential_mod()`
- Inputs: None
- Purpose: Handle potential mod.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Unlock_Potential
- Signature: `verb/Unlock_Potential()`
- Inputs: None
- Purpose: Handle unlock potential.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Solar_Flare
- Signature: `verb/Solar_Flare()`
- Inputs: None
- Purpose: Handle solar flare.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Taiyoken_Blindness_Timer
- Signature: `mob/proc/Taiyoken_Blindness_Timer()`
- Inputs: None
- Purpose: Handle taiyoken blindness timer.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Rift_Teleport
- Signature: `verb/Rift_Teleport()`
- Inputs: None
- Purpose: Handle rift teleport.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Imitate_Player
- Signature: `verb/Imitate_Player()`
- Inputs: None
- Purpose: Handle imitate player.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Invisibility
- Signature: `verb/Invisibility()`
- Inputs: None
- Purpose: Handle invisibility.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/precog_loop
- Signature: `mob/proc/precog_loop()`
- Inputs: None
- Purpose: Handle precog loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Observe_List
- Signature: `mob/proc/Observe_List()`
- Inputs: None
- Purpose: Handle observe list.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Observe
- Signature: `verb/Observe(atom/A in usr.Observe_List())`
- Inputs: atom/A in usr.Observe_List(
- Purpose: Handle observe.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/Observe
- Signature: `mob/Admin1/verb/Observe(atom/A in Observe_List())`
- Inputs: atom/A in Observe_List(
- Purpose: Handle observe.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Get_Observe
- Signature: `mob/proc/Get_Observe(mob/M) if(client)`
- Inputs: mob/M
- Purpose: Return Observe.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Materialize
- Signature: `verb/Materialize()`
- Inputs: None
- Purpose: Handle materialize.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Mystic/New
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

#### verb/Mystic
- Signature: `verb/Mystic()`
- Inputs: None
- Purpose: Handle mystic.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Mystic_Revert
- Signature: `mob/proc/Mystic_Revert() if(ismystic)`
- Inputs: None
- Purpose: Handle mystic revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/FireFist/New
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

#### verb/FireFist
- Signature: `verb/FireFist()`
- Inputs: None
- Purpose: Handle fire fist.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FireFist_Revert
- Signature: `mob/proc/FireFist_Revert() {`
- Inputs: None
- Purpose: Handle fire fist revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FireFistLoop
- Signature: `mob/proc/FireFistLoop(){`
- Inputs: None
- Purpose: Handle fire fist loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FireFistDrain
- Signature: `mob/proc/FireFistDrain(){`
- Inputs: None
- Purpose: Handle fire fist drain.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/SaiyanPower/New
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

#### verb/SaiyanPower
- Signature: `verb/SaiyanPower()`
- Inputs: None
- Purpose: Handle saiyan power.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SaiyanPower_Revert
- Signature: `mob/proc/SaiyanPower_Revert() {`
- Inputs: None
- Purpose: Handle saiyan power revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Majin/New
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

#### verb/Majin
- Signature: `verb/Majin()`
- Inputs: None
- Purpose: Handle majin.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Majin_Revert
- Signature: `mob/proc/Majin_Revert() if(ismajin)`
- Inputs: None
- Purpose: Handle majin revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Restore_Youth
- Signature: `verb/Restore_Youth()`
- Inputs: None
- Purpose: Handle restore youth.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/InBattleCantEnterCave
- Signature: `mob/proc/InBattleCantEnterCave()`
- Inputs: None
- Purpose: Handle in battle cant enter cave.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/RankChat
- Signature: `verb/RankChat(A as text)`
- Inputs: A as text
- Purpose: Handle rank chat.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/SpeedDelay.dm

#### mob/proc/Speed_delay_mult
- Signature: `mob/proc/Speed_delay_mult(severity = 1)`
- Inputs: severity = 1
- Purpose: Handle speed delay mult.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/SplitForms.dm

#### proc/Get_cached_splitform
- Signature: `proc/Get_cached_splitform()`
- Inputs: None
- Purpose: Return cached splitform.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/SplitformDestroyedByCheck
- Signature: `SplitformDestroyedByCheck(mob/m)`
- Inputs: mob/m
- Purpose: Handle splitform destroyed by check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MaxSplitforms
- Signature: `MaxSplitforms()`
- Inputs: None
- Purpose: Handle max splitforms.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Splitform/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Splitform/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/SimDestroyedBy
- Signature: `proc/SimDestroyedBy(mob/m)`
- Inputs: mob/m
- Purpose: Handle sim destroyed by.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Auto_Attack_Enemy
- Signature: `proc/Auto_Attack_Enemy()`
- Inputs: None
- Purpose: Handle auto attack enemy.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Fly_Check
- Signature: `proc/Fly_Check()`
- Inputs: None
- Purpose: Handle fly check.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/BP_Loop
- Signature: `proc/BP_Loop()`
- Inputs: None
- Purpose: Handle bp loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Attack_Loop
- Signature: `proc/Attack_Loop()`
- Inputs: None
- Purpose: Handle attack loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Death_Loop
- Signature: `proc/Death_Loop()`
- Inputs: None
- Purpose: Handle death loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Target_Loop
- Signature: `proc/Target_Loop()`
- Inputs: None
- Purpose: Handle target loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Follow_Loop
- Signature: `proc/Follow_Loop()`
- Inputs: None
- Purpose: Handle follow loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Splitform/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/SplitForm
- Signature: `verb/SplitForm()`
- Inputs: None
- Purpose: Handle split form.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/TrySplitform
- Signature: `TrySplitform()`
- Inputs: None
- Purpose: Handle try splitform.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanSplitform
- Signature: `CanSplitform()`
- Inputs: None
- Purpose: Return whether Splitform.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/CreateSplitform
- Signature: `CreateSplitform()`
- Inputs: None
- Purpose: Create Splitform.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Sim_Destroy_Loop
- Signature: `mob/proc/Sim_Destroy_Loop()`
- Inputs: None
- Purpose: Handle sim destroy loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade_health
- Signature: `verb/Upgrade_health()`
- Inputs: None
- Purpose: Handle upgrade health.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Bolt
- Signature: `verb/Bolt()`
- Inputs: None
- Purpose: Handle bolt.
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

#### proc/Create_simulated_fighter
- Signature: `proc/Create_simulated_fighter(mob/m)`
- Inputs: mob/m
- Purpose: Create simulated fighter.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Destroy_simulated_fighters
- Signature: `proc/Destroy_simulated_fighters(mob/m)`
- Inputs: mob/m
- Purpose: Handle destroy simulated fighters.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Toggle_simulated_fighter
- Signature: `proc/Toggle_simulated_fighter(mob/m)`
- Inputs: mob/m
- Purpose: Toggle simulated fighter.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### obj/items/Simulator/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SimBump
- Signature: `mob/proc/SimBump(obj/items/Simulator/s)`
- Inputs: obj/items/Simulator/s
- Purpose: Handle sim bump.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Make_Simulated_Fighter
- Signature: `mob/proc/Make_Simulated_Fighter(obj/items/Simulator/Sim,sim_str=1,sim_dura=1)`
- Inputs: obj/items/Simulator/Sim, sim_str=1, sim_dura=1
- Purpose: Handle make simulated fighter.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Sim_Loop
- Signature: `mob/proc/Sim_Loop()`
- Inputs: None
- Purpose: Handle sim loop.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Targeting/Targeting.dm

#### atom/movable/proc/FindTarget
- Signature: `FindTarget(dir_angle=NORTH, angle_limit=33, max_dist=9, prefer_auto_target=1)`
- Inputs: dir_angle=NORTH, angle_limit=33, max_dist=9, prefer_auto_target=1
- Purpose: Handle find target.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/IsValidTarget
- Signature: `IsValidTarget(mob/m, max_dist=10)`
- Inputs: mob/m, max_dist=10
- Purpose: Return whether Valid Target.
- Returns: boolean flag.
- Side effects: none expected.

#### atom/movable/proc/FindTargets
- Signature: `FindTargets(dir_angle=NORTH, angle_limit=33, max_dist=9, prefer_auto_target=0)`
- Inputs: dir_angle=NORTH, angle_limit=33, max_dist=9, prefer_auto_target=0
- Purpose: Handle find targets.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/pixel_dir
- Signature: `proc/pixel_dir(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Handle pixel dir.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/pixel_dir_old
- Signature: `proc/pixel_dir_old(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Handle pixel dir old.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/num_between
- Signature: `proc/num_between(n,Min,Max)`
- Inputs: n, Min, Max
- Purpose: Handle num between.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/angle_to_dir
- Signature: `proc/angle_to_dir(ang)`
- Inputs: ang
- Purpose: Handle angle to dir.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ShortestDegreesBetweenAngles
- Signature: `proc/ShortestDegreesBetweenAngles(start=0,end=0) //tells the shortest path from one angle to another, if going backwards thru zero is faster it'll show that`
- Inputs: start=0, end=0
- Purpose: Handle shortest degrees between angles.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/BubbleSort
- Signature: `proc/BubbleSort(list/l)`
- Inputs: list/l
- Purpose: Handle bubble sort.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Targeting/TargetingWrappers.dm

#### mob/proc/FindHakaiTarget
- Signature: `mob/proc/FindHakaiTarget()`
- Inputs: None
- Purpose: Handle find hakai target.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/IsViableHakaiTarget
- Signature: `mob/proc/IsViableHakaiTarget(mob/m, max_dist = 5)`
- Inputs: mob/m, max_dist = 5
- Purpose: Return whether Viable Hakai Target.
- Returns: boolean flag.
- Side effects: none expected.

#### obj/Blast/proc/GetBlastHomingTarget
- Signature: `obj/Blast/proc/GetBlastHomingTarget(d, angle)`
- Inputs: d, angle
- Purpose: Return Blast Homing Target.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Is_viable_lunge_target
- Signature: `mob/proc/Is_viable_lunge_target(mob/m)`
- Inputs: mob/m
- Purpose: Return whether viable lunge target.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/LungeTarget
- Signature: `mob/proc/LungeTarget(dist_override)`
- Inputs: dist_override
- Purpose: Handle lunge target.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FindWarpTarget
- Signature: `FindWarpTarget(dir_angle=NORTH, angle_limit=44, max_dist=10, prefer_auto_target=0)`
- Inputs: dir_angle=NORTH, angle_limit=44, max_dist=10, prefer_auto_target=0
- Purpose: Handle find warp target.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/IsValidWarpTarget
- Signature: `IsValidWarpTarget(mob/m, max_dist=10)`
- Inputs: mob/m, max_dist=10
- Purpose: Return whether Valid Warp Target.
- Returns: boolean flag.
- Side effects: none expected.
