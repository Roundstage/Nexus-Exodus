# Player Mechanics

## Overview
Player state, progression, roleplay combat, and character lifecycle mechanics.

The former cumulative KO counter is deprecated. Casual defeats recover automatically; lethal defeats enter RP Mode, drain Willpower, and require `willpowerGetUp()` after the recovery delay. Anger now grows through `gainAngerFromDamage()` as health is lost and no longer restores Health or Ki. Milestones, Technology Levels, Mining, and Smithing are persistent, player-driven progressions that migrate old saves lazily.

## Files
- `src/Code/PlayerMechanics/Aging.dm`
- `src/Code/PlayerMechanics/Ascension.dm`
- `src/Code/PlayerMechanics/Clothes.dm`
- `src/Code/PlayerMechanics/Cooking.dm`
- `src/Code/PlayerMechanics/Crandal.dm`
- `src/Code/PlayerMechanics/Customize.dm`
- `src/Code/PlayerMechanics/Death.dm`
- `src/Code/PlayerMechanics/Debuffs.dm`
- `src/Code/PlayerMechanics/Diarea.dm`
- `src/Code/PlayerMechanics/Faction.dm`
- `src/Code/PlayerMechanics/Feats.dm`
- `src/Code/PlayerMechanics/GodKi.dm`
- `src/Code/PlayerMechanics/GodKiTraining.dm`
- `src/Code/PlayerMechanics/Grabbing.dm`
- `src/Code/PlayerMechanics/Inventory.dm`
- `src/Code/PlayerMechanics/ItemTracking.dm`
- `src/Code/PlayerMechanics/Learn.dm`
- `src/Code/PlayerMechanics/Marriage.dm`
- `src/Code/PlayerMechanics/Milestones.dm`
- `src/Code/PlayerMechanics/OldKoSystem.dm`
- `src/Code/PlayerMechanics/Ranks.dm`
- `src/Code/PlayerMechanics/Reincarnation.dm`
- `src/Code/PlayerMechanics/RPCombat.dm`
- `src/Code/PlayerMechanics/Teach.dm`
- `src/Code/PlayerMechanics/TechnologyProgression.dm`
- `src/Code/PlayerMechanics/Train.dm`
- `src/Code/PlayerMechanics/Voting.dm`
- `src/Code/PlayerMechanics/Zenkai.dm`

## Proc Reference

### Roleplay combat and progression

- `gainAngerFromDamage(applied_damage)` converts actual health loss into proportional Anger without healing.
- `setRPMode(enabled, announce)` blocks outgoing melee/ki plus incoming combat damage, stuns, and displacement while active.
- `willpowerGetUp(force)` spends the remaining combat state to rise at Health equal to current Willpower.
- `syncMilestoneProgression(silent)` grants the five-point migration budget and one point per later game year.
- `purchaseMilestone(milestone_id)` validates cost/rank and persists the purchased rank.
- `syncTechnologyProgression(silent)` converts Knowledge growth into Technology XP and levels 1–8.
- `refreshTechnologyUnlocks(announce)` grants science items allowed by level and selected path.
- `Liberal Arts Degree`, `Mining Expert`, `Rapid Deployment`, and `Master Blacksmith` are Roleplay Tenkaichi milestone ports adapted to Nexus progression contracts.
- `refreshCombatStatusOverlays()` keeps the imported Lethal and RP Mode character icons synchronized with the action HUD.

### src/Code/PlayerMechanics/Aging.dm

#### mob/proc/Apply_racial_aging_variables
- Signature: `mob/proc/Apply_racial_aging_variables()`
- Inputs: None
- Purpose: Apply racial aging variables.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/Ascension.dm

#### mob/proc/ssj_power
- Signature: `mob/proc/ssj_power()`
- Inputs: None
- Purpose: Handle ssj power.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Ultra_Super_Saiyan/New
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

#### verb/Toggle_Ultra_Super_Saiyan
- Signature: `verb/Toggle_Ultra_Super_Saiyan()`
- Inputs: None
- Purpose: Toggle Ultra Super Saiyan.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/USSj
- Signature: `mob/proc/USSj()`
- Inputs: None
- Purpose: Handle ussj.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ascension_mod
- Signature: `ascension_mod()`
- Inputs: None
- Purpose: Handle ascension mod.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/AscendedBPMod
- Signature: `AscendedBPMod()`
- Inputs: None
- Purpose: Handle ascended bpmod.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Ascension_BP_Req
- Signature: `Ascension_BP_Req()`
- Inputs: None
- Purpose: Handle ascension bp req.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Ascension_loop
- Signature: `proc/Ascension_loop()`
- Inputs: None
- Purpose: Handle ascension loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/has_ssj_req
- Signature: `mob/proc/has_ssj_req(mod=1)`
- Inputs: mod=1
- Purpose: Return whether ssj req.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/has_ssj2_req
- Signature: `mob/proc/has_ssj2_req(mod=1)`
- Inputs: mod=1
- Purpose: Return whether ssj2 req.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/has_ssj3_req
- Signature: `mob/proc/has_ssj3_req(mod=1)`
- Inputs: mod=1
- Purpose: Return whether ssj3 req.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/OldTransGraphicsNoWait
- Signature: `mob/proc/OldTransGraphicsNoWait()`
- Inputs: None
- Purpose: Handle old trans graphics no wait.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Old_Trans_Graphics
- Signature: `mob/proc/Old_Trans_Graphics()`
- Inputs: None
- Purpose: Handle old trans graphics.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Make_Shockwave
- Signature: `proc/Make_Shockwave(mob/Origin,Range=7,Icon,sw_icon_size=256)`
- Inputs: mob/Origin, Range=7, Icon, sw_icon_size=256
- Purpose: Handle make shockwave.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_shockwave_graphic
- Signature: `proc/Get_shockwave_graphic()`
- Inputs: None
- Purpose: Return shockwave graphic.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### obj/Shockwave_Graphic/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Shockwave_Graphic/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ShockwaveGo2
- Signature: `proc/ShockwaveGo2(trans_size = 1)`
- Inputs: trans_size = 1
- Purpose: Handle shockwave go2.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Shockwave_go
- Signature: `proc/Shockwave_go(sw_size=256)`
- Inputs: sw_size=256
- Purpose: Handle shockwave go.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ScreenShake
- Signature: `ScreenShake(Amount = 10, Offset = 8)`
- Inputs: Amount = 10, Offset = 8
- Purpose: Handle screen shake.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/AssignSSjMults
- Signature: `mob/proc/AssignSSjMults()`
- Inputs: None
- Purpose: Handle assign ssj mults.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Revert
- Signature: `mob/proc/Revert()`
- Inputs: None
- Purpose: Legacy racial revert adapter; removes the applicable current stage and resynchronizes canonical primary/appearance state.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SSj_Hair
- Signature: `mob/proc/SSj_Hair()`
- Inputs: None
- Purpose: Resolve current Saiyan hair, tail, and blue unmastered or green mastered eye overlays.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SSj
- Signature: `mob/proc/SSj() if(!transing&&!ssj&&!IsGreatApe())`
- Inputs: None
- Purpose: Handle ssj.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SSj2
- Signature: `mob/proc/SSj2() if(!transing&&ssj==1&&Class!="Legendary Saiyan")`
- Inputs: None
- Purpose: Handle ssj2.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SSj3
- Signature: `mob/proc/SSj3() if(!transing&&ssj==2)`
- Inputs: None
- Purpose: Handle ssj3.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Super_Saiyan_4_Description/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SSj4
- Signature: `mob/proc/SSj4() if(!IsGreatApe() && !transing && !ssj && !ismystic)`
- Inputs: None
- Purpose: Handle ssj4.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Frost_Lord_Forms
- Signature: `mob/proc/Frost_Lord_Forms() if(Race=="Frost Lord")`
- Inputs: None
- Purpose: Advance one Frost stage; standard Final and Cooler Fifth can advance to Gold when requirements pass.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Frost_Lord_Form_Addition
- Signature: `mob/proc/Frost_Lord_Form_Addition(form)`
- Inputs: form
- Purpose: Handle frost lord form addition.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/icer_Revert
- Signature: `mob/proc/icer_Revert()`
- Inputs: None
- Purpose: Handle icer revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Third_Eye/Del
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

#### verb/Toggle_Third_Eye
- Signature: `verb/Toggle_Third_Eye()`
- Inputs: None
- Purpose: Toggle Third Eye.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Third_Eye
- Signature: `mob/proc/Third_Eye()`
- Inputs: None
- Purpose: Apply the documented `bp_mult +0.2` Human focus buff plus meditation/mastery effects.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Third_Eye_Revert
- Signature: `mob/proc/Third_Eye_Revert()`
- Inputs: None
- Purpose: Handle third eye revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### area/proc/SSj_Darkness
- Signature: `area/proc/SSj_Darkness()`
- Inputs: None
- Purpose: Handle ssj darkness.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SSj_Lightning
- Signature: `mob/proc/SSj_Lightning()`
- Inputs: None
- Purpose: Handle ssj lightning.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ssj_inspire_loop
- Signature: `mob/proc/ssj_inspire_loop()`
- Inputs: None
- Purpose: Handle ssj inspire loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ssj_drain_loop
- Signature: `mob/proc/ssj_drain_loop()`
- Inputs: None
- Purpose: Handle ssj drain loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/NoWaitAlert
- Signature: `NoWaitAlert(txt)`
- Inputs: txt
- Purpose: Handle no wait alert.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/Clothes.dm

#### proc/PopulateClothesChoices
- Signature: `proc/PopulateClothesChoices()`
- Inputs: None
- Purpose: Handle populate clothes choices.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Clothes_Equip
- Signature: `mob/proc/Clothes_Equip(obj/A) if(A.loc==src)`
- Inputs: obj/A
- Purpose: Handle clothes equip.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Clothes_Proc
- Signature: `mob/proc/Clothes_Proc(obj/A)`
- Inputs: obj/A
- Purpose: Handle clothes proc.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/Cooking.dm

#### obj/proc/Fire_Cook
- Signature: `obj/proc/Fire_Cook() for(var/mob/Body/A in range(1,src)) if(!A.Cooked)`
- Inputs: None
- Purpose: Handle fire cook.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Cook_Check
- Signature: `proc/Cook_Check(mob/A) //Checks if a fire is nearby to make A cook`
- Inputs: mob/A
- Purpose: Handle cook check.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Cook
- Signature: `proc/Cook(mob/Body/A) if(!A.Cooked)`
- Inputs: mob/Body/A
- Purpose: Handle cook.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Grave/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Bury
- Signature: `verb/Bury()`
- Inputs: None
- Purpose: Handle bury.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Body/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/Crandal.dm

#### mob/proc/Player_Rename_List
- Signature: `mob/proc/Player_Rename_List()`
- Inputs: None
- Purpose: Handle player rename list.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Colorfy/verb/Add_Color_to_Item
- Signature: `obj/Colorfy/verb/Add_Color_to_Item(obj/O as obj in view(usr))`
- Inputs: obj/O as obj in view(usr
- Purpose: Add Color to Item.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin2/verb/addColorToSomething
- Signature: `mob/Admin2/verb/addColorToSomething(obj/O as obj|mob|turf in view(usr))`
- Inputs: obj/O as obj|mob|turf in view(usr
- Purpose: Add Color to Something.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Colorize
- Signature: `mob/proc/Colorize(obj/O)`
- Inputs: obj/O
- Purpose: Handle colorize.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/proc/Multiply_Color
- Signature: `atom/proc/Multiply_Color(B)`
- Inputs: B
- Purpose: Handle multiply color.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/MultiplyIconColor
- Signature: `proc/MultiplyIconColor(icon/i, c = rgb(255,255,255))`
- Inputs: icon/i, c = rgb(255, 255, 255
- Purpose: Handle multiply icon color.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Change_Icon_List
- Signature: `mob/proc/Change_Icon_List()`
- Inputs: None
- Purpose: Handle change icon list.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/IconTooBig
- Signature: `proc/IconTooBig(icon/i)`
- Inputs: icon/i
- Purpose: Handle icon too big.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/IconTooBigMsg
- Signature: `proc/IconTooBigMsg(result)`
- Inputs: result
- Purpose: Handle icon too big msg.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Add_Custom_Overlay_To_Self
- Signature: `verb/Add_Custom_Overlay_To_Self(icon/I as icon)`
- Inputs: icon/I as icon
- Purpose: Add Custom Overlay To Self.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### verb/Change_Icon
- Signature: `verb/Change_Icon(atom/O in usr.Change_Icon_List())`
- Inputs: atom/O in usr.Change_Icon_List(
- Purpose: Handle change icon.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Rename
- Signature: `verb/Rename(atom/movable/O in usr.Player_Rename_List())`
- Inputs: atom/movable/O in usr.Player_Rename_List(
- Purpose: Handle rename.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Copy_Someones_Icon
- Signature: `verb/Copy_Someones_Icon(mob/A in world)`
- Inputs: mob/A in world
- Purpose: Handle copy someones icon.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Go_To_Planet
- Signature: `verb/Go_To_Planet()`
- Inputs: None
- Purpose: Handle go to planet.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Go_To_Planet
- Signature: `verb/Go_To_Planet()`
- Inputs: None
- Purpose: Handle go to planet.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/Customize.dm

#### mob/proc/ChangeIcerFormIcon
- Signature: `mob/proc/ChangeIcerFormIcon(form = 1)`
- Inputs: form = 1
- Purpose: Handle change icer form icon.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Set_tab_font_size
- Signature: `mob/proc/Set_tab_font_size(font_size=8)`
- Inputs: font_size=8
- Purpose: Set tab font size.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/verb/Settings
- Signature: `mob/verb/Settings()`
- Inputs: None
- Purpose: Handle settings.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Get_Hair
- Signature: `mob/proc/Get_Hair()`
- Inputs: None
- Purpose: Return Hair.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Get_Clothes
- Signature: `mob/proc/Get_Clothes()`
- Inputs: None
- Purpose: Return Clothes.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Text_Size
- Signature: `Text_Size()`
- Inputs: None
- Purpose: Handle text size.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Text_Color
- Signature: `Text_Color()`
- Inputs: None
- Purpose: Handle text color.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DetermineViewSize
- Signature: `DetermineViewSize(forceWidth)`
- Inputs: forceWidth
- Purpose: Handle determine view size.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Screen_Size
- Signature: `mob/proc/Screen_Size()`
- Inputs: None
- Purpose: Handle screen size.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Fullscreen_Toggle
- Signature: `mob/proc/Fullscreen_Toggle()`
- Inputs: None
- Purpose: Handle fullscreen toggle.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/FullscreenToggle
- Signature: `mob/verb/FullscreenToggle() //for the skin`
- Inputs: None
- Purpose: Handle fullscreen toggle.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Fullscreen_Check
- Signature: `mob/proc/Fullscreen_Check(skipAlert) if(client)`
- Inputs: skipAlert
- Purpose: Handle fullscreen check.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/Death.dm

#### mob/proc/FixCantMoveDueToKiAttack
- Signature: `mob/proc/FixCantMoveDueToKiAttack()`
- Inputs: None
- Purpose: Handle fix cant move due to ki attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FullHeal
- Signature: `mob/proc/FullHeal()`
- Inputs: None
- Purpose: Handle full heal.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/SSj_Online
- Signature: `proc/SSj_Online()`
- Inputs: None
- Purpose: Handle ssj online.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/SSj2_Online
- Signature: `proc/SSj2_Online()`
- Inputs: None
- Purpose: Handle ssj2 online.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/SSj3_Online
- Signature: `proc/SSj3_Online()`
- Inputs: None
- Purpose: Handle ssj3 online.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_Warp
- Signature: `proc/Get_Warp(mob/M,mob/P,Dir) if(Dir)`
- Inputs: mob/M, mob/P, Dir
- Purpose: Return Warp.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/Get_Warp_Destination
- Signature: `proc/Get_Warp_Destination(mob/M,mob/P)`
- Inputs: mob/M, mob/P
- Purpose: Return Warp Destination.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Warp_To
- Signature: `mob/proc/Warp_To(turf/B,mob/M) if(B)`
- Inputs: turf/B, mob/M
- Purpose: Handle warp to.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/cant_blast
- Signature: `mob/proc/cant_blast(ignore_attack_check)`
- Inputs: ignore_attack_check
- Purpose: Handle cant blast.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/can_melee
- Signature: `mob/proc/can_melee(trying_to_power_attack)`
- Inputs: trying_to_power_attack
- Purpose: Return whether melee.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/CanMeleeFromOtherCauses
- Signature: `mob/proc/CanMeleeFromOtherCauses()`
- Inputs: None
- Purpose: Return whether Melee From Other Causes.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Get_attack_gains
- Signature: `mob/proc/Get_attack_gains()`
- Inputs: None
- Purpose: Return attack gains.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/SparGainsAmount
- Signature: `SparGainsAmount()`
- Inputs: None
- Purpose: Handle spar gains amount.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Attack_gain_loop
- Signature: `mob/proc/Attack_gain_loop()`
- Inputs: None
- Purpose: Handle attack gain loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/TimedOverlay
- Signature: `proc/TimedOverlay(turf/t, time = 100, Icon)`
- Inputs: turf/t, time = 100, Icon
- Purpose: Handle timed overlay.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/TempTurfOverlay
- Signature: `turf/proc/TempTurfOverlay(image/i,timer=30)`
- Inputs: image/i, timer=30
- Purpose: Handle temp turf overlay.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/KnockbackNoWait
- Signature: `mob/proc/KnockbackNoWait(mob/A,Distance=10,dirt_trail=1,override_dir,bypass_immunity,from_lunge, omega_kb) //A is the Attacker who knockbacked src`
- Inputs: mob/A, Distance=10, dirt_trail=1, override_dir, bypass_immunity, from_lunge, omega_kb
- Purpose: Handle knockback no wait.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Knockback
- Signature: `mob/proc/Knockback(mob/A,Distance=10,dirt_trail=1,override_dir,bypass_immunity,from_lunge, omega_kb) //A is the Attacker who knockbacked src`
- Inputs: mob/A, Distance=10, dirt_trail=1, override_dir, bypass_immunity, from_lunge, omega_kb
- Purpose: Handle knockback.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/KB_Destroy
- Signature: `mob/proc/KB_Destroy(mob/A,Dir) //A is the Attacker`
- Inputs: mob/A, Dir
- Purpose: Handle kb destroy.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SetLastAttackedTime
- Signature: `mob/proc/SetLastAttackedTime(mob/a) //a = attacker`
- Inputs: mob/a
- Purpose: Set Last Attacked Time.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/third_eye
- Signature: `mob/proc/third_eye()`
- Inputs: None
- Purpose: Handle third eye.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/can_anger
- Signature: `mob/proc/can_anger()`
- Inputs: None
- Purpose: Return whether anger.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/anger
- Signature: `mob/proc/anger(anger_mult=1,ssj_possible=1,reason) if(can_anger())`
- Inputs: anger_mult=1, ssj_possible=1, reason
- Purpose: Handle anger.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Calm
- Signature: `mob/proc/Calm()`
- Inputs: None
- Purpose: Handle calm.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drop_Rsc
- Signature: `mob/proc/Drop_Rsc(n=0) if(n)`
- Inputs: n=0
- Purpose: Handle drop rsc.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drop_Stealables
- Signature: `mob/proc/Drop_Stealables()`
- Inputs: None
- Purpose: Handle drop stealables.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ObserveDeathSpot
- Signature: `mob/proc/ObserveDeathSpot()`
- Inputs: None
- Purpose: Handle observe death spot.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Death
- Signature: `mob/proc/Death(mob/Z,Force_Death=0,drone_sd=0,lose_hero=1,lose_immortality=1)`
- Inputs: mob/Z, Force_Death=0, drone_sd=0, lose_hero=1, lose_immortality=1
- Purpose: Handle death.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Spam_kill_timer
- Signature: `mob/proc/Spam_kill_timer()`
- Inputs: None
- Purpose: Handle spam kill timer.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Revive
- Signature: `mob/proc/Revive()`
- Inputs: None
- Purpose: Handle revive.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Dust/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Dust/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Dust
- Signature: `proc/Dust(mob/a, start_size = 0.01, end_size = 1, time = 25, start_alpha = 255, easing = LINEAR_EASING, start_delay = 0)`
- Inputs: mob/a, start_size = 0.01, end_size = 1, time = 25, start_alpha = 255, easing = LINEAR_EASING, start_delay = 0
- Purpose: Handle dust.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/Destroy
- Signature: `turf/proc/Destroy()`
- Inputs: None
- Purpose: Handle destroy.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Beam_stunned
- Signature: `Beam_stunned(skip_immunity_check)`
- Inputs: skip_immunity_check
- Purpose: Handle beam stunned.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BeamStunImmune
- Signature: `BeamStunImmune()`
- Inputs: None
- Purpose: Handle beam stun immune.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/StruggleAgainstBeamStun
- Signature: `StruggleAgainstBeamStun()`
- Inputs: None
- Purpose: Handle struggle against beam stun.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BeamStruggling
- Signature: `BeamStruggling(timer = 30)`
- Inputs: timer = 30
- Purpose: Handle beam struggling.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Allow_Move
- Signature: `mob/proc/Allow_Move(D)`
- Inputs: D
- Purpose: Handle allow move.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Grab_Struggle
- Signature: `proc/Grab_Struggle(D)`
- Inputs: D
- Purpose: Handle grab struggle.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Being_strangled
- Signature: `mob/proc/Being_strangled()`
- Inputs: None
- Purpose: Handle being strangled.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PunchGraphics
- Signature: `mob/proc/PunchGraphics()`
- Inputs: None
- Purpose: Handle punch graphics.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Blast
- Signature: `mob/proc/Blast()`
- Inputs: None
- Purpose: Handle blast.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ResetVars
- Signature: `proc/ResetVars(mob/m)`
- Inputs: mob/m
- Purpose: Handle reset vars.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_cached_body
- Signature: `proc/Get_cached_body()`
- Inputs: None
- Purpose: Return cached body.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Leave_Body
- Signature: `mob/proc/Leave_Body()`
- Inputs: None
- Purpose: Handle leave body.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/makeBodies
- Signature: `mob/Admin4/verb/makeBodies()`
- Inputs: None
- Purpose: Handle make bodies.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Punch_Machine
- Signature: `mob/proc/Punch_Machine()`
- Inputs: None
- Purpose: Handle punch machine.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Peebagging
- Signature: `mob/proc/Peebagging()`
- Inputs: None
- Purpose: Handle peebagging.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Peebag
- Signature: `mob/proc/Peebag()`
- Inputs: None
- Purpose: Handle peebag.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/reviveOrbSettings
- Signature: `mob/Admin4/verb/reviveOrbSettings()`
- Inputs: None
- Purpose: Handle revive orb settings.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Auto_revive_loop
- Signature: `proc/Auto_revive_loop()`
- Inputs: None
- Purpose: Handle auto revive loop.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/Debuffs.dm

#### mob/proc/Check_if_kiting
- Signature: `Check_if_kiting(turf/old_loc)`
- Inputs: turf/old_loc
- Purpose: Check if kiting.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Reset_kiting
- Signature: `Reset_kiting()`
- Inputs: None
- Purpose: Handle reset kiting.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Good_teaming_with_evil_check
- Signature: `Good_teaming_with_evil_check()`
- Inputs: None
- Purpose: Handle good teaming with evil check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Most_recent_attack_time
- Signature: `Most_recent_attack_time(mob/a,mob/d)`
- Inputs: mob/a, mob/d
- Purpose: Handle most recent attack time.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Log_attack
- Signature: `Log_attack(mob/t)`
- Inputs: mob/t
- Purpose: Handle log attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Good_attacking_good_against_their_will
- Signature: `Good_attacking_good_against_their_will(mob/t)`
- Inputs: mob/t
- Purpose: Handle good attacking good against their will.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Good_attack_good_loop
- Signature: `Good_attack_good_loop()`
- Inputs: None
- Purpose: Handle good attack good loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Good_attacking_good
- Signature: `Good_attacking_good()`
- Inputs: None
- Purpose: Handle good attacking good.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Extrapolated_target_is
- Signature: `Extrapolated_target_is(mob/m,hit_req=5,min_time=60,max_time=360)`
- Inputs: mob/m, hit_req=5, min_time=60, max_time=360
- Purpose: Handle extrapolated target is.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Clear_backlog_loop
- Signature: `Clear_backlog_loop()`
- Inputs: None
- Purpose: Handle clear backlog loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Check_if_being_teamed
- Signature: `Check_if_being_teamed(mob/a) //src = person being attacked. a = attacker`
- Inputs: mob/a
- Purpose: Check if being teamed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Set_possible_teamer_list
- Signature: `Set_possible_teamer_list(mob/M) //M is the attacker. called in setOpponent()`
- Inputs: mob/M
- Purpose: Set possible teamer list.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Is_teaming
- Signature: `Is_teaming(mob/m,call_is_teaming=1) //src = attacker, m = person being attacked`
- Inputs: mob/m, call_is_teaming=1
- Purpose: Return whether teaming.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Is_teamer
- Signature: `Is_teamer()`
- Inputs: None
- Purpose: Return whether teamer.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Teamer_loop
- Signature: `Teamer_loop()`
- Inputs: None
- Purpose: Handle teamer loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Fear_dmg_mult
- Signature: `Fear_dmg_mult()`
- Inputs: None
- Purpose: Handle fear dmg mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Is_runner
- Signature: `Is_runner()`
- Inputs: None
- Purpose: Return whether runner.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Get_chaser_from_key
- Signature: `Get_chaser_from_key()`
- Inputs: None
- Purpose: Return chaser from key.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Set_chaser
- Signature: `Set_chaser(mob/m) //m is the attacker`
- Inputs: mob/m
- Purpose: Set chaser.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Chase_loop
- Signature: `Chase_loop()`
- Inputs: None
- Purpose: Handle chase loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Chase_over
- Signature: `Chase_over()`
- Inputs: None
- Purpose: Handle chase over.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/stand_still_time
- Signature: `stand_still_time()`
- Inputs: None
- Purpose: Handle stand still time.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Remove_fear
- Signature: `Remove_fear() if(fearful)`
- Inputs: None
- Purpose: Remove fear.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/PlayerMechanics/Diarea.dm

#### mob/proc/Diarea
- Signature: `mob/proc/Diarea(Contagious=1,Other_Chance=0,Invis=0) if(prob(Diarea+Other_Chance))`
- Inputs: Contagious=1, Other_Chance=0, Invis=0
- Purpose: Handle diarea.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/proc/Turd_walk
- Signature: `obj/proc/Turd_walk(d)`
- Inputs: d
- Purpose: Handle turd walk.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Shit_decrease_loop
- Signature: `mob/proc/Shit_decrease_loop()`
- Inputs: None
- Purpose: Handle shit decrease loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_new_turd
- Signature: `proc/Get_new_turd()`
- Inputs: None
- Purpose: Return new turd.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### obj/Turd/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turd/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Turd/proc/HorsePoop
- Signature: `HorsePoop()`
- Inputs: None
- Purpose: Handle horse poop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin3/verb/massDiarea
- Signature: `mob/Admin3/verb/massDiarea()`
- Inputs: None
- Purpose: Handle mass diarea.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/Faction.dm

#### obj/Faction/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FactionUpdate
- Signature: `mob/proc/FactionUpdate() for(var/obj/Faction/F in src) for(var/mob/M in view(src))`
- Inputs: None
- Purpose: Handle faction update.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/Feats.dm

#### mob/proc/GiveAllFeats
- Signature: `GiveAllFeats()`
- Inputs: None
- Purpose: Handle give all feats.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BPFeatsCompletionPercent
- Signature: `BPFeatsCompletionPercent()`
- Inputs: None
- Purpose: Handle bpfeats completion percent.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CheckBlankFeats
- Signature: `CheckBlankFeats() //fixes the blank feats bug hopefully`
- Inputs: None
- Purpose: Check Blank Feats.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SaveFeats
- Signature: `SaveFeats()`
- Inputs: None
- Purpose: Save Feats.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/LoadFeats
- Signature: `LoadFeats()`
- Inputs: None
- Purpose: Load Feats.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/CheckBankFeats
- Signature: `CheckBankFeats()`
- Inputs: None
- Purpose: Check Bank Feats.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CheckStudentFeat
- Signature: `CheckStudentFeat(mob/m) //m = student`
- Inputs: mob/m
- Purpose: Check Student Feat.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GiveFeat
- Signature: `GiveFeat(f = "Feat Name")`
- Inputs: f = "Feat Name"
- Purpose: Handle give feat.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/UpdateFeatMultipliers
- Signature: `UpdateFeatMultipliers()`
- Inputs: None
- Purpose: Update Feat Multipliers.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/ViewFeats
- Signature: `ViewFeats()`
- Inputs: None
- Purpose: Handle view feats.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FeatWindow
- Signature: `FeatWindow()`
- Inputs: None
- Purpose: Handle feat window.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/GodKi.dm

#### proc/GodOnline
- Signature: `GodOnline()`
- Inputs: None
- Purpose: Handle god online.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanTurnGodKiOn
- Signature: `CanTurnGodKiOn()`
- Inputs: None
- Purpose: Return whether Turn God Ki On.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/CanTurnGodKiOff
- Signature: `CanTurnGodKiOff()`
- Inputs: None
- Purpose: Return whether Turn God Ki Off.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/HasGodKiReq
- Signature: `HasGodKiReq()`
- Inputs: None
- Purpose: Return whether God Ki Req.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/HasGodKiBPReq
- Signature: `HasGodKiBPReq()`
- Inputs: None
- Purpose: Return whether God Ki BPReq.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/IsGod
- Signature: `IsGod()`
- Inputs: None
- Purpose: Return whether God.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/God_BP
- Signature: `God_BP()`
- Inputs: None
- Purpose: Handle god bp.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RaiseGodKi
- Signature: `RaiseGodKi(a=0)`
- Inputs: a=0
- Purpose: Handle raise god ki.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BecomeGod
- Signature: `BecomeGod()`
- Inputs: None
- Purpose: Handle become god.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/GodKiTraining.dm

#### proc/GodKiRealmKillLoop
- Signature: `GodKiRealmKillLoop()`
- Inputs: None
- Purpose: Handle god ki realm kill loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/LeechGodKi
- Signature: `LeechGodKi(mob/m)`
- Inputs: mob/m
- Purpose: Handle leech god ki.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GodKiRealmDeathCheck
- Signature: `GodKiRealmDeathCheck()`
- Inputs: None
- Purpose: Handle god ki realm death check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GodKiRealmGains
- Signature: `GodKiRealmGains(n=1)`
- Inputs: n=1
- Purpose: Handle god ki realm gains.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/InGodKiRealm
- Signature: `InGodKiRealm()`
- Inputs: None
- Purpose: Handle in god ki realm.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/God_Realm_Portal/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/God_Realm_Portal/proc/GodRealmPortalAppear
- Signature: `GodRealmPortalAppear()`
- Inputs: None
- Purpose: Handle god realm portal appear.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/Grabbing.dm

#### mob/proc/item_count
- Signature: `mob/proc/item_count()`
- Inputs: None
- Purpose: Handle item count.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ReleaseGrab
- Signature: `mob/proc/ReleaseGrab()`
- Inputs: None
- Purpose: Handle release grab.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Grab
- Signature: `mob/verb/Grab()`
- Inputs: None
- Purpose: Handle grab.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Grabbed_by_tail
- Signature: `mob/proc/Grabbed_by_tail()`
- Inputs: None
- Purpose: Handle grabbed by tail.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/remove_nulls
- Signature: `proc/remove_nulls(list/l)`
- Inputs: list/l
- Purpose: Remove nulls.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Extendo_module
- Signature: `Extendo_module()`
- Inputs: None
- Purpose: Handle extendo module.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/armStretchRangeTiles
- Signature: `armStretchRangeTiles(range_pixels)`
- Inputs: arm range in pixels.
- Purpose: Convert legacy racial/module arm ranges to rounded tile counts for path scanning.
- Returns: at least one tile.
- Side effects: none expected.

#### mob/proc/GetArmStretchTarget
- Signature: `GetArmStretchTarget(grab_dist = 10)`
- Inputs: grab_dist = 10
- Purpose: Prefer an eligible selected mob in the forward vector cone, then search the forward and side rays.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/GetArmStretchTargets
- Signature: `GetArmStretchTargets(grab_dist = 10, turf/start_pos, direction)`
- Inputs: grab_dist = 10, turf/start_pos, direction
- Purpose: Return Arm Stretch Targets.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/CanExtendoGrab
- Signature: `CanExtendoGrab(atom/movable/m)`
- Inputs: movable mob or object.
- Purpose: Return whether Extendo Grab.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Get_arm_state
- Signature: `Get_arm_state(obj/old_arm,obj/new_arm)`
- Inputs: obj/old_arm, obj/new_arm
- Purpose: Return arm state.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Grab_failed
- Signature: `Grab_failed(atom/movable/m, list/arms, step_number=0, grab_dist=0, obj/last_arm, turf/starting_loc)`
- Inputs: target, arm list, progress, maximum range, last segment, and starting turf.
- Purpose: Handle grab failed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Destroy_arms
- Signature: `Destroy_arms(list/arms)`
- Inputs: list/arms
- Purpose: Handle destroy arms.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Get_next_arm_position
- Signature: `Get_next_arm_position(obj/old_arm,atom/movable/m)`
- Inputs: previous arm segment and movable target.
- Purpose: Return next arm position.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Stretch_arm_to
- Signature: `Stretch_arm_to(atom/movable/m,grab_dist=10)`
- Inputs: movable target and pixel range.
- Purpose: Extend and retract cached arm segments using normalized range while copying vector offsets during the pull.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Update_grab
- Signature: `mob/proc/Update_grab()`
- Inputs: None
- Purpose: Update grab.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Update_grab_loop
- Signature: `mob/proc/Update_grab_loop()`
- Inputs: None
- Purpose: Update grab loop.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/PlayerMechanics/Inventory.dm

#### obj/Brain_Scrambler/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Set
- Signature: `verb/Set()`
- Inputs: None
- Purpose: Handle set.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Bolt
- Signature: `verb/Bolt()`
- Inputs: None
- Purpose: Handle bolt.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Brain_scrambled
- Signature: `mob/proc/Brain_scrambled()`
- Inputs: None
- Purpose: Handle brain scrambled.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/EMP_mine_loop
- Signature: `mob/proc/EMP_mine_loop()`
- Inputs: None
- Purpose: Handle emp mine loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/EMP_Mine/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/EMP_Mine/Del
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

#### proc/EMP_detonate
- Signature: `proc/EMP_detonate()`
- Inputs: None
- Purpose: Handle emp detonate.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Giant_Teleport_Nullifier/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Set_allowed_frequencies
- Signature: `verb/Set_allowed_frequencies()`
- Inputs: None
- Purpose: Set allowed frequencies.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### verb/Set
- Signature: `verb/Set()`
- Inputs: None
- Purpose: Handle set.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Bolt
- Signature: `verb/Bolt()`
- Inputs: None
- Purpose: Handle bolt.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Teleport_nulled
- Signature: `mob/proc/Teleport_nulled(frequency)`
- Inputs: frequency
- Purpose: Handle teleport nulled.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Teleport_Nullifier/New
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

#### verb/Set
- Signature: `verb/Set()`
- Inputs: None
- Purpose: Handle set.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Wall_upgrader_bot/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Bolt
- Signature: `verb/Bolt()`
- Inputs: None
- Purpose: Handle bolt.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Wall_bot_loop
- Signature: `proc/Wall_bot_loop()`
- Inputs: None
- Purpose: Handle wall bot loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Resource_Destroyer/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Set
- Signature: `verb/Set()`
- Inputs: None
- Purpose: Handle set.
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

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/proc/Scrap_value
- Signature: `obj/proc/Scrap_value()`
- Inputs: None
- Purpose: Handle scrap value.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade_health
- Signature: `verb/Upgrade_health()`
- Inputs: None
- Purpose: Handle upgrade health.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Set_spawn
- Signature: `verb/Set_spawn()`
- Inputs: None
- Purpose: Set spawn.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

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

#### verb/Use
- Signature: `verb/Use() if(src in usr)`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Orbital_Cannon/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Regenerate_damage
- Signature: `proc/Regenerate_damage()`
- Inputs: None
- Purpose: Handle regenerate damage.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/orbital_cannon
- Signature: `proc/orbital_cannon()`
- Inputs: None
- Purpose: Handle orbital cannon.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/orbital_strike
- Signature: `proc/orbital_strike(obj/target,obj/Orbital_Cannon/self)`
- Inputs: obj/target, obj/Orbital_Cannon/self
- Purpose: Handle orbital strike.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/get_planet_obj
- Signature: `proc/get_planet_obj()`
- Inputs: None
- Purpose: Return planet obj.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### verb/Settings
- Signature: `verb/Settings()`
- Inputs: None
- Purpose: Handle settings.
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

#### obj/Ki_Field_Generator/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Bolt
- Signature: `verb/Bolt()`
- Inputs: None
- Purpose: Handle bolt.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Radar/New
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

#### obj/items/Radar/Click
- Signature: `Click() if(src in usr)`
- Inputs: None
- Purpose: Handle click.
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

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/sword_mult
- Signature: `mob/proc/sword_mult()`
- Inputs: None
- Purpose: Handle sword mult.
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

#### verb/Bolt
- Signature: `verb/Bolt()`
- Inputs: None
- Purpose: Handle bolt.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Devil_Mat/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Devil_Mat
- Signature: `mob/proc/Devil_Mat(loop_delay=1)`
- Inputs: loop_delay=1
- Purpose: Handle devil mat.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Choose_Player
- Signature: `mob/proc/Choose_Player(T,alignment_req)`
- Inputs: T, alignment_req
- Purpose: Handle choose player.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Update_Bounties
- Signature: `proc/Update_Bounties()`
- Inputs: None
- Purpose: Update Bounties.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Has_Bounty
- Signature: `mob/proc/Has_Bounty()`
- Inputs: None
- Purpose: Return whether Bounty.
- Returns: boolean flag.
- Side effects: none expected.

#### proc/Find_Bounty
- Signature: `proc/Find_Bounty(V)`
- Inputs: V
- Purpose: Handle find bounty.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Online_Bounties
- Signature: `proc/Online_Bounties()`
- Inputs: None
- Purpose: Handle online bounties.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Claimable_Bounties
- Signature: `proc/Claimable_Bounties(mob/m)`
- Inputs: mob/m
- Purpose: Handle claimable bounties.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Retract_Bounties
- Signature: `mob/proc/Retract_Bounties()`
- Inputs: None
- Purpose: Handle retract bounties.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/On_Built_Turf
- Signature: `mob/proc/On_Built_Turf()`
- Inputs: None
- Purpose: Handle on built turf.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Apply_Bounty
- Signature: `proc/Apply_Bounty(price=0,bounty_note,the_key,maker,expiry=120,bonus=0)`
- Inputs: price=0, bounty_note, the_key, maker, expiry=120, bonus=0
- Purpose: Apply Bounty.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Auto_bounty_evil
- Signature: `proc/Auto_bounty_evil()`
- Inputs: None
- Purpose: Handle auto bounty evil.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Bounty_Computer/New
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

#### verb/Bolt
- Signature: `verb/Bolt()`
- Inputs: None
- Purpose: Handle bolt.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Bounty_Computer/Click
- Signature: `Click()`
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

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Medical_Scan/Click
- Signature: `Click() if(usr in view(1,src))`
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

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Bio_Field_Generator/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Bio_Field_Generator
- Signature: `proc/Bio_Field_Generator()`
- Inputs: None
- Purpose: Handle bio field generator.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Bolt
- Signature: `verb/Bolt()`
- Inputs: None
- Purpose: Handle bolt.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Count_Racers
- Signature: `proc/Count_Racers()`
- Inputs: None
- Purpose: Handle count racers.
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

#### obj/items/Pod_Race_Computer/Click
- Signature: `Click() if((usr in view(1,src))||(usr.Ship in view(1,src)))`
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

#### verb/Autopilot
- Signature: `verb/Autopilot()`
- Inputs: None
- Purpose: Handle autopilot.
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

#### obj/items/Resource_Vaccuum/Click
- Signature: `Click() if(src in usr)`
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

#### obj/items/Door_Pass/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Clone_Tank
- Signature: `mob/proc/Clone_Tank() if(client) for(var/obj/items/Cloning_Tank/T in cloning_tanks) if(T.z&&T.Password==key&&Dead)`
- Inputs: None
- Purpose: Handle clone tank.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Cloning_Tank/New
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

#### obj/items/Cloning_Tank/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
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

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Force_Field_Desc
- Signature: `proc/Force_Field_Desc()`
- Inputs: None
- Purpose: Handle force field desc.
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

#### mob/proc/Force_Field
- Signature: `mob/proc/Force_Field(Icon='ForceField.dmi',C=rgb(100,200,250,120),State="")`
- Inputs: Icon='ForceField.dmi', C=rgb(100, 200, 250, 120
- Purpose: Handle force field.
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

#### verb/Transmit
- Signature: `verb/Transmit(msg as text) for(var/mob/P in players)`
- Inputs: msg as text
- Purpose: Handle transmit.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Stun_Chip/New
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
- Signature: `verb/Use(mob/A in view(1,usr))`
- Inputs: mob/A in view(1, usr
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Remove
- Signature: `verb/Remove(mob/A in view(1,usr))`
- Inputs: mob/A in view(1, usr
- Purpose: Handle remove.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Stun_Chip/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Stun_Chip/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
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

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Transporter_Pad/New
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

#### proc/Transport
- Signature: `proc/Transport()`
- Inputs: None
- Purpose: Handle transport.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Set
- Signature: `verb/Set()`
- Inputs: None
- Purpose: Handle set.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Reset_DNA_Verification
- Signature: `verb/Reset_DNA_Verification()`
- Inputs: None
- Purpose: Handle reset dna verification.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Transport
- Signature: `proc/Transport()`
- Inputs: None
- Purpose: Handle transport.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Set_frequency
- Signature: `verb/Set_frequency()`
- Inputs: None
- Purpose: Set frequency.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

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

#### mob/proc/LSD
- Signature: `mob/proc/LSD()`
- Inputs: None
- Purpose: Handle lsd.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/proc/LSD_Monster
- Signature: `obj/proc/LSD_Monster(mob/P)`
- Inputs: mob/P
- Purpose: Handle lsd monster.
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

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/PDA/New
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

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Well/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/max_weight
- Signature: `mob/proc/max_weight()`
- Inputs: None
- Purpose: Handle max weight.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Cache_equipped_weights
- Signature: `mob/proc/Cache_equipped_weights()`
- Inputs: None
- Purpose: Handle cache equipped weights.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/weights
- Signature: `mob/proc/weights()`
- Inputs: None
- Purpose: Handle weights.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/weight_name
- Signature: `proc/weight_name()`
- Inputs: None
- Purpose: Handle weight name.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Weights/New
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

#### obj/items/Weights/Click
- Signature: `Click() if(src in usr)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Choose_Weights_Icon
- Signature: `verb/Choose_Weights_Icon()`
- Inputs: None
- Purpose: Handle choose weights icon.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade_health
- Signature: `verb/Upgrade_health()`
- Inputs: None
- Purpose: Handle upgrade health.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Regenerator/New
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

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Bolt
- Signature: `verb/Bolt()`
- Inputs: None
- Purpose: Handle bolt.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Apply_Armor
- Signature: `mob/proc/Apply_Armor(obj/items/Armor/A) if(A.loc==src)`
- Inputs: obj/items/Armor/A
- Purpose: Apply Armor.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Armor/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Armor/New
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

#### obj/items/Armor/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/heavy_boost
- Signature: `proc/heavy_boost()`
- Inputs: None
- Purpose: Handle heavy boost.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Customize
- Signature: `verb/Customize()`
- Inputs: None
- Purpose: Handle customize.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Armor_Icons
- Signature: `proc/Armor_Icons()`
- Inputs: None
- Purpose: Handle armor icons.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MaxItems
- Signature: `mob/proc/MaxItems() //max items you can carry`
- Inputs: None
- Purpose: Handle max items.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/verb/Drop
- Signature: `obj/items/verb/Drop()`
- Inputs: None
- Purpose: Handle drop.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Scouter/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Scouter/Click
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

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Scouter/verb/Transmit
- Signature: `Transmit(msg as text) for(var/mob/P in players)`
- Inputs: msg as text
- Purpose: Handle transmit.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Sword_Icons
- Signature: `proc/Sword_Icons()`
- Inputs: None
- Purpose: Handle sword icons.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Sword/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Sword/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Customize
- Signature: `verb/Customize()`
- Inputs: None
- Purpose: Handle customize.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Sword/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Apply_Sword
- Signature: `mob/proc/Apply_Sword(obj/items/Sword/S)`
- Inputs: obj/items/Sword/S
- Purpose: Apply Sword.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Digging/Shovel/Click
- Signature: `Click() if(src in usr)`
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

#### obj/items/Digging/Hand_Drill/Click
- Signature: `Click() if(src in usr)`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Digging
- Signature: `mob/proc/Digging(Amount=1)`
- Inputs: Amount=1
- Purpose: Handle digging.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Dig_for_Resources
- Signature: `mob/verb/Dig_for_Resources()`
- Inputs: None
- Purpose: Handle dig for resources.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade_health
- Signature: `verb/Upgrade_health()`
- Inputs: None
- Purpose: Handle upgrade health.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Hover_Chair/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Hover_Chair/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/EatSensu
- Signature: `mob/proc/EatSensu(mob/user, obj/o)`
- Inputs: mob/user, obj/o
- Purpose: Handle eat sensu.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Senzu/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Senzu/Del
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

#### verb/Throw
- Signature: `verb/Throw(mob/M in oview(usr))`
- Inputs: mob/M in oview(usr
- Purpose: Handle throw.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Senzu_grow
- Signature: `proc/Senzu_grow()`
- Inputs: None
- Purpose: Handle senzu grow.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Senzu_pickup
- Signature: `proc/Senzu_pickup()`
- Inputs: None
- Purpose: Handle senzu pickup.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Senzu_timer_countdown
- Signature: `mob/proc/Senzu_timer_countdown()`
- Inputs: None
- Purpose: Handle senzu timer countdown.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Senzu_overload_countdown
- Signature: `mob/proc/Senzu_overload_countdown()`
- Inputs: None
- Purpose: Handle senzu overload countdown.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ShikonAura
- Signature: `ShikonAura()`
- Inputs: None
- Purpose: Handle shikon aura.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Shikon_Jewel/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Shikon_Jewel/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Original_Icon
- Signature: `proc/Original_Icon() while(src)`
- Inputs: None
- Purpose: Handle original icon.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Assemble
- Signature: `verb/Assemble()`
- Inputs: None
- Purpose: Handle assemble.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/get_inject
- Signature: `mob/proc/get_inject(bypass_forced_check)`
- Inputs: bypass_forced_check
- Purpose: Return inject.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Focusin_Revert
- Signature: `verb/Focusin_Revert()`
- Inputs: None
- Purpose: Handle focusin revert.
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

#### mob/proc/focusin_loop
- Signature: `mob/proc/focusin_loop()`
- Inputs: None
- Purpose: Handle focusin loop.
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

#### mob/proc/Steroid_Loop
- Signature: `mob/proc/Steroid_Loop()`
- Inputs: None
- Purpose: Handle steroid loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Steroid_Stats
- Signature: `mob/proc/Steroid_Stats()`
- Inputs: None
- Purpose: Handle steroid stats.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Undo_Steroid_Stats
- Signature: `mob/proc/Undo_Steroid_Stats()`
- Inputs: None
- Purpose: Handle undo steroid stats.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Roid_Power
- Signature: `mob/proc/Roid_Power(Amount)`
- Inputs: Amount
- Purpose: Handle roid power.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/Learn.dm

#### proc/Initialize_Learnable_Skills_List
- Signature: `proc/Initialize_Learnable_Skills_List()`
- Inputs: None
- Purpose: Initialize Learnable Skills List.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RemoveAbsorbFromNonZorbRacesIfZorbIsIllegal
- Signature: `mob/proc/RemoveAbsorbFromNonZorbRacesIfZorbIsIllegal()`
- Inputs: None
- Purpose: Remove Absorb From Non Zorb Races If Zorb Is Illegal.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin4/verb/manageLearnableSkills
- Signature: `mob/Admin4/verb/manageLearnableSkills()`
- Inputs: None
- Purpose: Handle manage learnable skills.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Delete_excess_buffs
- Signature: `mob/proc/Delete_excess_buffs()`
- Inputs: None
- Purpose: Delete excess buffs.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Buff_count
- Signature: `mob/proc/Buff_count() //how many custom buffs they have`
- Inputs: None
- Purpose: Handle buff count.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Learn
- Signature: `mob/verb/Learn()`
- Inputs: None
- Purpose: Handle learn.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CostToLearn
- Signature: `mob/proc/CostToLearn(obj/o)`
- Inputs: obj/o
- Purpose: Handle cost to learn.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RaceSkillLearnDifficultyMod
- Signature: `mob/proc/RaceSkillLearnDifficultyMod(obj/o)`
- Inputs: obj/o
- Purpose: Handle race skill learn difficulty mod.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/learn_new_buff_attribute
- Signature: `mob/proc/learn_new_buff_attribute()`
- Inputs: None
- Purpose: Handle learn new buff attribute.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Prison_Bot/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/OldKoSystem.dm

#### mob/proc/anger_chance
- Signature: `mob/proc/anger_chance(mod=1)`
- Inputs: mod=1
- Purpose: Handle anger chance.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/InTournament
- Signature: `mob/proc/InTournament()`
- Inputs: None
- Purpose: Handle in tournament.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ShouldAnger
- Signature: `mob/proc/ShouldAnger(mob/target)`
- Inputs: mob/target
- Purpose: Handle should anger.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/TryToCauseAnger
- Signature: `mob/proc/TryToCauseAnger(mob/Attacker, mob/Victim)`
- Inputs: mob/Attacker, mob/Victim
- Purpose: Handle try to cause anger.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/TryToAnnounceBattlegroundsDefeat
- Signature: `mob/proc/TryToAnnounceBattlegroundsDefeat(mob/Attacker, mob/Victim)`
- Inputs: mob/Attacker, mob/Victim
- Purpose: Handle try to announce battlegrounds defeat.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/LogKoData
- Signature: `mob/proc/LogKoData(mob/Victim, mob/Attacker)`
- Inputs: mob/Victim, mob/Attacker
- Purpose: Handle log ko data.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ResetStatsToDefault
- Signature: `mob/proc/ResetStatsToDefault(mob/Victim)`
- Inputs: mob/Victim
- Purpose: Handle reset stats to default.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/StopDoingActions
- Signature: `mob/proc/StopDoingActions(mob/Victim)`
- Inputs: mob/Victim
- Purpose: Stop Doing Actions.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/TryToRevertSSJ
- Signature: `mob/proc/TryToRevertSSJ(mob/Victim)`
- Inputs: mob/Victim
- Purpose: Handle try to revert ssj.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/TryToKoNPC
- Signature: `mob/proc/TryToKoNPC(mob/Attacker, mob/Victim)`
- Inputs: mob/Attacker, mob/Victim
- Purpose: Handle try to ko npc.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MinimumHeal
- Signature: `mob/proc/MinimumHeal(mob/Victim)`
- Inputs: mob/Victim
- Purpose: Handle minimum heal.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/TryToKillWithPoison
- Signature: `mob/proc/TryToKillWithPoison(mob/Victim)`
- Inputs: mob/Victim
- Purpose: Handle try to kill with poison.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/TryToCauseAngerDueToKo
- Signature: `mob/proc/TryToCauseAngerDueToKo(mob/Victim)`
- Inputs: mob/Victim
- Purpose: Handle try to cause anger due to ko.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/KO
- Signature: `mob/proc/KO(mob/Attacker, allow_anger=TRUE, combat_ko_handled = FALSE, mob/Victim = src)`
- Inputs: mob/Attacker, allow_anger=TRUE, combat_ko_handled = FALSE, mob/Victim = src
- Purpose: Handle ko.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/UnKO
- Signature: `mob/proc/UnKO() if(KO)`
- Inputs: None
- Purpose: Handle un ko.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/Ranks.dm

#### mob/proc/Give_Rank
- Signature: `mob/proc/Give_Rank(mob/A)`
- Inputs: mob/A
- Purpose: Handle give rank.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/autoRank
- Signature: `mob/Admin4/verb/autoRank()`
- Inputs: None
- Purpose: Handle auto rank.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Rank_taken
- Signature: `proc/Rank_taken(rank)`
- Inputs: rank
- Purpose: Handle rank taken.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Rank_Check
- Signature: `mob/proc/Rank_Check()`
- Inputs: None
- Purpose: Handle rank check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Race_can_have_rank
- Signature: `mob/proc/Race_can_have_rank(rank)`
- Inputs: rank
- Purpose: Handle race can have rank.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/give_hbtc_key
- Signature: `mob/proc/give_hbtc_key()`
- Inputs: None
- Purpose: Handle give hbtc key.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Guardian
- Signature: `Guardian(mob/P)`
- Inputs: mob/P
- Purpose: Handle guardian.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Popo
- Signature: `Popo(mob/P)`
- Inputs: mob/P
- Purpose: Handle popo.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Korin
- Signature: `Korin(mob/P)`
- Inputs: mob/P
- Purpose: Handle korin.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Turtle_Hermit
- Signature: `Turtle_Hermit(mob/P)`
- Inputs: mob/P
- Purpose: Handle turtle hermit.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Crane_Hermit
- Signature: `Crane_Hermit(mob/P)`
- Inputs: mob/P
- Purpose: Handle crane hermit.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Earth_Teacher
- Signature: `Earth_Teacher(mob/P)`
- Inputs: mob/P
- Purpose: Handle earth teacher.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Elder
- Signature: `Elder(mob/P)`
- Inputs: mob/P
- Purpose: Handle elder.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Namekian_Teacher
- Signature: `Namekian_Teacher(mob/P)`
- Inputs: mob/P
- Purpose: Handle namekian teacher.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Elite_Alien
- Signature: `Elite_Alien(mob/P)`
- Inputs: mob/P
- Purpose: Handle elite alien.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Yardrat_Master
- Signature: `Yardrat_Master(mob/P)`
- Inputs: mob/P
- Purpose: Handle yardrat master.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Alien_Skill_Master
- Signature: `Alien_Skill_Master(mob/P)`
- Inputs: mob/P
- Purpose: Handle alien skill master.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Ice_Skill_Master
- Signature: `Ice_Skill_Master(mob/P)`
- Inputs: mob/P
- Purpose: Handle ice skill master.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Android_Skill_Master
- Signature: `Android_Skill_Master(mob/P)`
- Inputs: mob/P
- Purpose: Handle android skill master.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Kaioshin
- Signature: `Kaioshin(mob/P)`
- Inputs: mob/P
- Purpose: Handle kaioshin.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/North_Kai
- Signature: `North_Kai(mob/P)`
- Inputs: mob/P
- Purpose: Handle north kai.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Cardinal_Kai
- Signature: `Cardinal_Kai(mob/P)`
- Inputs: mob/P
- Purpose: Handle cardinal kai.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Kaio_Helper
- Signature: `Kaio_Helper(mob/P)`
- Inputs: mob/P
- Purpose: Handle kaio helper.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Daimaou
- Signature: `Daimaou(mob/P)`
- Inputs: mob/P
- Purpose: Handle daimaou.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Demon_Master
- Signature: `Demon_Master(mob/P)`
- Inputs: mob/P
- Purpose: Handle demon master.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Carrot_Man
- Signature: `mob/proc/Carrot_Man(mob/P)`
- Inputs: mob/P
- Purpose: Handle carrot man.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Braal
- Signature: `mob/proc/Braal(mob/P)`
- Inputs: mob/P
- Purpose: Handle braal.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Blowhan
- Signature: `mob/proc/Blowhan(mob/P)`
- Inputs: mob/P
- Purpose: Handle blowhan.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Piccolo
- Signature: `mob/proc/Piccolo(mob/P)`
- Inputs: mob/P
- Purpose: Handle piccolo.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Trunks
- Signature: `mob/proc/Trunks(mob/P)`
- Inputs: mob/P
- Purpose: Handle trunks.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Tien
- Signature: `mob/proc/Tien(mob/P)`
- Inputs: mob/P
- Purpose: Handle tien.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Yamcha
- Signature: `mob/proc/Yamcha(mob/P)`
- Inputs: mob/P
- Purpose: Handle yamcha.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Krillin
- Signature: `mob/proc/Krillin(mob/P)`
- Inputs: mob/P
- Purpose: Handle krillin.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Chaotsu
- Signature: `mob/proc/Chaotsu(mob/P)`
- Inputs: mob/P
- Purpose: Handle chaotsu.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Freeza
- Signature: `mob/proc/Freeza(mob/P)`
- Inputs: mob/P
- Purpose: Handle freeza.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Cell
- Signature: `mob/proc/Cell(mob/P)`
- Inputs: mob/P
- Purpose: Handle cell.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Majin_Buu
- Signature: `mob/proc/Majin_Buu(mob/P)`
- Inputs: mob/P
- Purpose: Handle majin buu.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Z_Character_Masteries
- Signature: `mob/proc/Z_Character_Masteries()`
- Inputs: None
- Purpose: Handle z character masteries.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/Reincarnation.dm

#### obj/Reincarnation/New
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

#### verb/Reincarnate
- Signature: `verb/Reincarnate()`
- Inputs: None
- Purpose: Handle reincarnate.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Reincarnate
- Signature: `mob/proc/Reincarnate(mob/m, reincarnation_age = 0) //m = offerer`
- Inputs: mob/m, reincarnation_age = 0
- Purpose: Handle reincarnate.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Revert_All
- Signature: `mob/proc/Revert_All()`
- Inputs: None
- Purpose: Handle revert all.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/Teach.dm

#### mob/proc/RaiseStudentPoints
- Signature: `RaiseStudentPoints(mob/m, amount=0)`
- Inputs: mob/m, amount=0
- Purpose: Handle raise student points.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/set_next_knowledge_teach
- Signature: `set_next_knowledge_teach(n=1)`
- Inputs: n=1
- Purpose: Set next knowledge teach.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/CanTeachGlobal
- Signature: `CanTeachGlobal(msg)`
- Inputs: msg
- Purpose: Return whether Teach Global.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/CanTeachMob
- Signature: `CanTeachMob(mob/m, msg)`
- Inputs: mob/m, msg
- Purpose: Return whether Teach Mob.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/TeachProc
- Signature: `TeachProc()`
- Inputs: None
- Purpose: Handle teach proc.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/TeachMob
- Signature: `TeachMob(mob/m)`
- Inputs: mob/m
- Purpose: Handle teach mob.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/HasEnoughStudentPointsFrom
- Signature: `HasEnoughStudentPointsFrom(obj/o, mob/teacher)`
- Inputs: obj/o, mob/teacher
- Purpose: Return whether Enough Student Points From.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/CanTeachSkillTo
- Signature: `CanTeachSkillTo(mob/m, obj/o)`
- Inputs: mob/m, obj/o
- Purpose: Return whether Teach Skill To.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/StudentPointCost
- Signature: `StudentPointCost(obj/o)`
- Inputs: obj/o
- Purpose: Handle student point cost.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/RaceCanHaveUnlockPotential
- Signature: `proc/RaceCanHaveUnlockPotential(r)`
- Inputs: r
- Purpose: Handle race can have unlock potential.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Teach
- Signature: `Teach()`
- Inputs: None
- Purpose: Handle teach.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/proc/update_teach_timer
- Signature: `obj/proc/update_teach_timer()`
- Inputs: None
- Purpose: Update teach timer.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/PlayerMechanics/Train.dm

#### mob/proc/Peebag_Gains
- Signature: `mob/proc/Peebag_Gains(delay = 10) //delay is how often they were allowed to punch the peebag`
- Inputs: delay = 10
- Purpose: Handle peebag gains.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/bpGainTest
- Signature: `mob/Admin5/verb/bpGainTest()`
- Inputs: None
- Purpose: Handle bp gain test.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Majin_attack_gain
- Signature: `mob/proc/Majin_attack_gain(n=1,mob/o,apply_hbtc_gains=1,include_weights=1)`
- Inputs: n=1, mob/o, apply_hbtc_gains=1, include_weights=1
- Purpose: Handle majin attack gain.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Attack_Gain
- Signature: `mob/proc/Attack_Gain(N = 1, mob/leech, apply_hbtc_gains = 1, include_weights = 1, skip_leech, skipBPGains)`
- Inputs: N = 1, mob/leech, apply_hbtc_gains = 1, include_weights = 1, skip_leech, skipBPGains
- Purpose: Handle attack gain.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Med_Stats
- Signature: `mob/proc/Med_Stats(Amount=1)`
- Inputs: Amount=1
- Purpose: Handle med stats.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Train_Stats
- Signature: `mob/proc/Train_Stats(Amount=1)`
- Inputs: Amount=1
- Purpose: Handle train stats.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Shadow_Spar_Gains
- Signature: `mob/proc/Shadow_Spar_Gains()`
- Inputs: None
- Purpose: Handle shadow spar gains.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Flying_Gain
- Signature: `mob/proc/Flying_Gain(gain_mod=1)`
- Inputs: gain_mod=1
- Purpose: Handle flying gain.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Show_BP_Gains
- Signature: `mob/verb/Show_BP_Gains()`
- Inputs: None
- Purpose: Handle show bp gains.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/reporter_loop
- Signature: `mob/proc/reporter_loop()`
- Inputs: None
- Purpose: Handle reporter loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GravityGainsMult
- Signature: `mob/proc/GravityGainsMult()`
- Inputs: None
- Purpose: Handle gravity gains mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RecordHighestBPEverGotten
- Signature: `mob/proc/RecordHighestBPEverGotten()`
- Inputs: None
- Purpose: Handle record highest bpever gotten.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Raise_BP
- Signature: `mob/proc/Raise_BP(Amount=1,apply_hbtc_gains=1)`
- Inputs: Amount=1, apply_hbtc_gains=1
- Purpose: Handle raise bp.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/hero_leechable
- Signature: `proc/hero_leechable(mob/m)`
- Inputs: mob/m
- Purpose: Handle hero leechable.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Raise_Ki
- Signature: `mob/proc/Raise_Ki(Amount=1)`
- Inputs: Amount=1
- Purpose: Handle raise ki.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Decline_Energy_Gain
- Signature: `mob/proc/Decline_Energy_Gain()`
- Inputs: None
- Purpose: Handle decline energy gain.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Refresh_Stat_Record
- Signature: `proc/Refresh_Stat_Record() while(1)`
- Inputs: None
- Purpose: Handle refresh stat record.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Balanced_Stat_Gain
- Signature: `mob/proc/Balanced_Stat_Gain()`
- Inputs: None
- Purpose: Handle balanced stat gain.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stat_Gain
- Signature: `mob/proc/Stat_Gain()`
- Inputs: None
- Purpose: Handle stat gain.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Raise_Stats
- Signature: `mob/proc/Raise_Stats(Amount=1,F) //F = Stat Focus`
- Inputs: Amount=1, F
- Purpose: Handle raise stats.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Is_Lowest_Stat
- Signature: `mob/proc/Is_Lowest_Stat(N=1)`
- Inputs: N=1
- Purpose: Return whether Lowest Stat.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Rearrange_Mode_Check
- Signature: `mob/proc/Rearrange_Mode_Check()`
- Inputs: None
- Purpose: Handle rearrange mode check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stat_Avg
- Signature: `mob/proc/Stat_Avg() //The max stats someone has reached on the server`
- Inputs: None
- Purpose: Handle stat avg.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Stat_Focus
- Signature: `mob/verb/Stat_Focus()`
- Inputs: None
- Purpose: Handle stat focus.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Leech
- Signature: `mob/proc/Leech(mob/P,N=1,no_adapt=0,give_as_hbtc_bp=0,android_matters=1,weights_count=1)`
- Inputs: mob/P, N=1, no_adapt=0, give_as_hbtc_bp=0, android_matters=1, weights_count=1
- Purpose: Handle leech.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Can_Train
- Signature: `mob/proc/Can_Train()`
- Inputs: None
- Purpose: Return whether Train.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/verb/Train_verb
- Signature: `Train_verb()`
- Inputs: None
- Purpose: Handle train verb.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Med_verb
- Signature: `Med_verb()`
- Inputs: None
- Purpose: Handle med verb.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Meditate
- Signature: `mob/proc/Meditate(from_ai_train)`
- Inputs: from_ai_train
- Purpose: Handle meditate.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Train
- Signature: `mob/proc/Train(from_ai_train)`
- Inputs: from_ai_train
- Purpose: Handle train.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Med_Gain
- Signature: `mob/proc/Med_Gain(Amount=1)`
- Inputs: Amount=1
- Purpose: Handle med gain.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Train_Gain
- Signature: `mob/proc/Train_Gain(Amount=1)`
- Inputs: Amount=1
- Purpose: Handle train gain.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Bolt
- Signature: `verb/Bolt()`
- Inputs: None
- Purpose: Handle bolt.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Shadow_Spar
- Signature: `mob/proc/Shadow_Spar()`
- Inputs: None
- Purpose: Handle shadow spar.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stop_Shadow_Sparring
- Signature: `mob/proc/Stop_Shadow_Sparring()`
- Inputs: None
- Purpose: Stop Shadow Sparring.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/RandomSSColor
- Signature: `proc/RandomSSColor()`
- Inputs: None
- Purpose: Handle random sscolor.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Shadow_Spar_Loop
- Signature: `mob/proc/Shadow_Spar_Loop()`
- Inputs: None
- Purpose: Handle shadow spar loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Auto_Shadow_Spar/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/Voting.dm

#### proc/Player_Count
- Signature: `proc/Player_Count()`
- Inputs: None
- Purpose: Handle player count.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/unique_players
- Signature: `proc/unique_players()`
- Inputs: None
- Purpose: Handle unique players.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Rate_Server
- Signature: `mob/proc/Rate_Server(N=0)`
- Inputs: N=0
- Purpose: Handle rate server.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Server_Rating
- Signature: `proc/Server_Rating()`
- Inputs: None
- Purpose: Handle server rating.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Update_Already_Voted_List
- Signature: `proc/Update_Already_Voted_List()`
- Inputs: None
- Purpose: Update Already Voted List.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Can_Vote
- Signature: `mob/proc/Can_Vote(obj/Voting/V)`
- Inputs: obj/Voting/V
- Purpose: Return whether Vote.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Council_Check
- Signature: `mob/proc/Council_Check()`
- Inputs: None
- Purpose: Handle council check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Add_Council
- Signature: `mob/proc/Add_Council()`
- Inputs: None
- Purpose: Add Council.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Remove_Council
- Signature: `mob/proc/Remove_Council()`
- Inputs: None
- Purpose: Remove Council.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Online_Council_Members
- Signature: `proc/Online_Council_Members()`
- Inputs: None
- Purpose: Handle online council members.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Offline_Council_Members
- Signature: `proc/Offline_Council_Members()`
- Inputs: None
- Purpose: Handle offline council members.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Council_Chat
- Signature: `verb/Council_Chat(A as text)`
- Inputs: A as text
- Purpose: Handle council chat.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Boost
- Signature: `verb/Boost()`
- Inputs: None
- Purpose: Handle boost.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/President_Options
- Signature: `verb/President_Options()`
- Inputs: None
- Purpose: Handle president options.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RP_President
- Signature: `mob/proc/RP_President()`
- Inputs: None
- Purpose: Handle rp president.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Add_Voting
- Signature: `mob/proc/Add_Voting()`
- Inputs: None
- Purpose: Add Voting.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Voting
- Signature: `verb/Voting()`
- Inputs: None
- Purpose: Handle voting.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/PlayerMechanics/Zenkai.dm

#### mob/Admin5/verb/testZenkai
- Signature: `mob/Admin5/verb/testZenkai(mob/m in world)`
- Inputs: mob/m in world
- Purpose: Handle test zenkai.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Zenkai
- Signature: `mob/proc/Zenkai(n=1)`
- Inputs: n=1
- Purpose: Handle zenkai.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/zenkai_reset
- Signature: `mob/proc/zenkai_reset()`
- Inputs: None
- Purpose: Handle zenkai reset.
- Returns: none (implicit).
- Side effects: see implementation.
