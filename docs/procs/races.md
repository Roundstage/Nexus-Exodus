# Races

## Overview
Auto-generated first-pass proc summaries based on signature names. Refine descriptions during refactors.

## Files
- `src/Code/Races/Alien Starter Moves.dm`
- `src/Code/Races/Bio Android/Bios.dm`
- `src/Code/Races/Icer/Gold Icer.dm`
- `src/Code/Races/Majins/Goo Trap.dm`
- `src/Code/Races/Nameks.dm`
- `src/Code/Races/Oozaru.dm`
- `src/Code/Races/Saiyan/Royal Blue.dm`
- `src/Code/Races/Saiyan/SS Blue.dm`
- `src/Code/Races/Saiyan/ss god red.dm`
- `src/Code/Races/Ultra Instinct.dm`

## Proc Reference

### src/Code/Races/Alien Starter Moves.dm

#### mob/proc/Auto_color_arm_stretch_icon
- Signature: `mob/proc/Auto_color_arm_stretch_icon()`
- Inputs: None
- Purpose: Handle auto color arm stretch icon.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Alien_Stuff
- Signature: `mob/proc/Alien_Stuff()`
- Inputs: None
- Purpose: Handle alien stuff.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Races/Bio Android/Bios.dm

#### mob/proc/BioFormCheck
- Signature: `BioFormCheck(mob/m)`
- Inputs: mob/m
- Purpose: Handle bio form check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanGetNextBioFormFrom
- Signature: `CanGetNextBioFormFrom(mob/m)`
- Inputs: mob/m
- Purpose: Return whether Get Next Bio Form From.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/BioNextForm
- Signature: `BioNextForm()`
- Inputs: None
- Purpose: Handle bio next form.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanBioRevert
- Signature: `CanBioRevert()`
- Inputs: None
- Purpose: Return whether Bio Revert.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/BioLarvaRevert
- Signature: `BioLarvaRevert()`
- Inputs: None
- Purpose: Handle bio larva revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BioEggGfx
- Signature: `BioEggGfx()`
- Inputs: None
- Purpose: Handle bio egg gfx.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BioBPMult
- Signature: `BioBPMult()`
- Inputs: None
- Purpose: Handle bio bpmult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BioAndroidLogon
- Signature: `BioAndroidLogon()`
- Inputs: None
- Purpose: Handle bio android logon.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/LarvaEvolveLoop
- Signature: `LarvaEvolveLoop()`
- Inputs: None
- Purpose: Handle larva evolve loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Bio_Android/verb/Revert_to_Larval_Form
- Signature: `Revert_to_Larval_Form()`
- Inputs: None
- Purpose: Handle revert to larval form.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Races/Icer/Gold Icer.dm

#### mob/proc/PowerUpToGoldForm
- Signature: `PowerUpToGoldForm()`
- Inputs: None
- Purpose: Handle power up to gold form.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/HasGoldFormReq
- Signature: `HasGoldFormReq()`
- Inputs: None
- Purpose: Return whether Gold Form Req.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/HasGoldFormBPReq
- Signature: `HasGoldFormBPReq()`
- Inputs: None
- Purpose: Return whether Gold Form BPReq.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Frost_LordUnlockGodKi
- Signature: `Frost_LordUnlockGodKi()`
- Inputs: None
- Purpose: Handle frost lord unlock god ki.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GoldForm
- Signature: `GoldForm()`
- Inputs: None
- Purpose: Handle gold form.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GoldFormRevert
- Signature: `GoldFormRevert()`
- Inputs: None
- Purpose: Handle gold form revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GoldFormDrain
- Signature: `GoldFormDrain()`
- Inputs: None
- Purpose: Handle gold form drain.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GoldFormLogonCheck
- Signature: `GoldFormLogonCheck()`
- Inputs: None
- Purpose: Handle gold form logon check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GoldIcerTransEffectSupernova
- Signature: `GoldIcerTransEffectSupernova()`
- Inputs: None
- Purpose: Handle gold icer trans effect supernova.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Races/Majins/Goo Trap.dm

#### obj/Goo_Trap/verb/Goo_Trap
- Signature: `Goo_Trap()`
- Inputs: None
- Purpose: Handle goo trap.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Goo_Trap/verb/Hotbar_use
- Signature: `Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GooTrap
- Signature: `GooTrap()`
- Inputs: None
- Purpose: Handle goo trap.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanMajinGoo
- Signature: `CanMajinGoo()`
- Inputs: None
- Purpose: Return whether Majin Goo.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/MajinGooExists
- Signature: `MajinGooExists()`
- Inputs: None
- Purpose: Handle majin goo exists.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DeleteMajinGoo
- Signature: `DeleteMajinGoo()`
- Inputs: None
- Purpose: Delete Majin Goo.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/GetGooSpeed
- Signature: `GetGooSpeed()`
- Inputs: None
- Purpose: Return Goo Speed.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/GetGooBP
- Signature: `GetGooBP()`
- Inputs: None
- Purpose: Return Goo BP.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### obj/Majin_Goo/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Majin_Goo/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Majin_Goo/proc/GooAI
- Signature: `GooAI()`
- Inputs: None
- Purpose: Handle goo ai.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Majin_Goo/proc/GooHide
- Signature: `GooHide()`
- Inputs: None
- Purpose: Handle goo hide.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Majin_Goo/proc/GooUnhide
- Signature: `GooUnhide()`
- Inputs: None
- Purpose: Handle goo unhide.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Majin_Goo/proc/GooWaitForTarget
- Signature: `GooWaitForTarget()`
- Inputs: None
- Purpose: Handle goo wait for target.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Majin_Goo/proc/FindGooTarget
- Signature: `FindGooTarget()`
- Inputs: None
- Purpose: Handle find goo target.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Majin_Goo/proc/IsViableGooTarget
- Signature: `IsViableGooTarget(mob/m)`
- Inputs: mob/m
- Purpose: Return whether Viable Goo Target.
- Returns: boolean flag.
- Side effects: none expected.

#### obj/Majin_Goo/proc/GooStrongerThanTarget
- Signature: `GooStrongerThanTarget(mob/m)`
- Inputs: mob/m
- Purpose: Handle goo stronger than target.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Majin_Goo/proc/GooAttackTarget
- Signature: `GooAttackTarget(mob/m)`
- Inputs: mob/m
- Purpose: Handle goo attack target.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Majin_Goo/proc/GooStickOnTarget
- Signature: `GooStickOnTarget(mob/m)`
- Inputs: mob/m
- Purpose: Handle goo stick on target.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Majin_Goo/proc/GooAbsorbTarget
- Signature: `GooAbsorbTarget(mob/m)`
- Inputs: mob/m
- Purpose: Handle goo absorb target.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanGooAbsorb
- Signature: `mob/proc/CanGooAbsorb(mob/M)`
- Inputs: mob/M
- Purpose: Return whether Goo Absorb.
- Returns: boolean flag.
- Side effects: none expected.

### src/Code/Races/Nameks.dm

#### mob/Namekian/verb/Reset_Counterpart
- Signature: `Reset_Counterpart()`
- Inputs: None
- Purpose: Handle reset counterpart.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Namekian/verb/Set_As_Counterpart
- Signature: `Set_As_Counterpart(mob/m in usr.Counterpart_list())`
- Inputs: mob/m in usr.Counterpart_list(
- Purpose: Set As Counterpart.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Tell_counterpart_i_died
- Signature: `Tell_counterpart_i_died()`
- Inputs: None
- Purpose: Handle tell counterpart i died.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Tell_counterpart_im_alive
- Signature: `Tell_counterpart_im_alive()`
- Inputs: None
- Purpose: Handle tell counterpart im alive.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Check_if_counterpart_is_alive_or_dead
- Signature: `Check_if_counterpart_is_alive_or_dead()`
- Inputs: None
- Purpose: Check if counterpart is alive or dead.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Counterpart_died_loop
- Signature: `Counterpart_died_loop()`
- Inputs: None
- Purpose: Handle counterpart died loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Match_counterpart_loop
- Signature: `Match_counterpart_loop()`
- Inputs: None
- Purpose: Handle match counterpart loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Match_counterpart
- Signature: `Match_counterpart()`
- Inputs: None
- Purpose: Handle match counterpart.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Counterpart_list
- Signature: `mob/proc/Counterpart_list()`
- Inputs: None
- Purpose: Handle counterpart list.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Namekian_Fusion
- Signature: `verb/Namekian_Fusion()`
- Inputs: None
- Purpose: Handle namekian fusion.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanNamekianFuse
- Signature: `mob/proc/CanNamekianFuse(mob/fuser, showmsg)`
- Inputs: mob/fuser, showmsg
- Purpose: Return whether Namekian Fuse.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Namekian_Fusion
- Signature: `mob/proc/Namekian_Fusion()`
- Inputs: None
- Purpose: Handle namekian fusion.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/testnfg
- Signature: `mob/Admin5/verb/testnfg()`
- Inputs: None
- Purpose: Handle testnfg.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Namekian_Fusion_Gfx
- Signature: `mob/proc/Namekian_Fusion_Gfx()`
- Inputs: None
- Purpose: Handle namekian fusion gfx.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Races/Oozaru.dm

#### mob/proc/Tail_Add
- Signature: `mob/proc/Tail_Add() if(Race in list("Saiyan","Half Saiyan"))`
- Inputs: None
- Purpose: Handle tail add.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Tail_Remove
- Signature: `mob/proc/Tail_Remove()`
- Inputs: None
- Purpose: Handle tail remove.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Great_Ape_power
- Signature: `mob/proc/Great_Ape_power()`
- Inputs: None
- Purpose: Handle great ape power.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Great_Ape_revert
- Signature: `mob/proc/Great_Ape_revert() if(IsGreatApe())`
- Inputs: None
- Purpose: Handle great ape revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Great_Ape
- Signature: `mob/proc/Great_Ape(Golden=0) if(!cyber_bp&&!has_modules()&&!IsGreatApe()&&Tail&&!ssj&&!Dead)`
- Inputs: Golden=0
- Purpose: Handle great ape.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Great_Ape_berserk_loop
- Signature: `mob/proc/Great_Ape_berserk_loop()`
- Inputs: None
- Purpose: Handle great ape berserk loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Great_Ape/New
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

#### verb/Great_Ape_Toggle
- Signature: `verb/Great_Ape_Toggle()`
- Inputs: None
- Purpose: Handle great ape toggle.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Races/Saiyan/Royal Blue.dm

#### mob/proc/CanRoyalBlue
- Signature: `CanRoyalBlue()`
- Inputs: None
- Purpose: Return whether Royal Blue.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/TryRoyalBlue
- Signature: `TryRoyalBlue()`
- Inputs: None
- Purpose: Handle try royal blue.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/AssignRoyalBlueHair
- Signature: `AssignRoyalBlueHair()`
- Inputs: None
- Purpose: Handle assign royal blue hair.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Races/Saiyan/SS Blue.dm

#### mob/proc/PowerUpToSSBlue
- Signature: `PowerUpToSSBlue()`
- Inputs: None
- Purpose: Handle power up to ssblue.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Has_SSB_Req
- Signature: `Has_SSB_Req()`
- Inputs: None
- Purpose: Return whether SSB Req.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/SSj_Blue
- Signature: `SSj_Blue()`
- Inputs: None
- Purpose: Handle ssj blue.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SSj_Blue_Revert
- Signature: `SSj_Blue_Revert()`
- Inputs: None
- Purpose: Handle ssj blue revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SSj_Blue_Drain
- Signature: `SSj_Blue_Drain()`
- Inputs: None
- Purpose: Handle ssj blue drain.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SSj_Blue_Logon_Check
- Signature: `SSj_Blue_Logon_Check()`
- Inputs: None
- Purpose: Handle ssj blue logon check.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Races/Saiyan/ss god red.dm

#### mob/proc/has_ssg_req
- Signature: `has_ssg_req()`
- Inputs: None
- Purpose: Return whether ssg req.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/SSG
- Signature: `mob/proc/SSG()`
- Inputs: None
- Purpose: Handle ssg.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SSG_Drain
- Signature: `SSG_Drain()`
- Inputs: None
- Purpose: Handle ssg drain.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SSG_Logon_Check
- Signature: `SSG_Logon_Check()`
- Inputs: None
- Purpose: Handle ssg logon check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SSG_Revert
- Signature: `SSG_Revert()`
- Inputs: None
- Purpose: Handle ssg revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Free_SP
- Signature: `Free_SP()`
- Inputs: None
- Purpose: Handle free sp.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Free_Resources
- Signature: `Free_Resources()`
- Inputs: None
- Purpose: Handle free resources.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Races/Ultra Instinct.dm

#### mob/Admin4/verb/GoUltraInstinct
- Signature: `mob/Admin4/verb/GoUltraInstinct(mob/m in world)`
- Inputs: mob/m in world
- Purpose: Handle go ultra instinct.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/MassUltraInstinct
- Signature: `mob/Admin4/verb/MassUltraInstinct()`
- Inputs: None
- Purpose: Handle mass ultra instinct.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GenerateUltraInstinctGraphics
- Signature: `GenerateUltraInstinctGraphics()`
- Inputs: None
- Purpose: Handle generate ultra instinct graphics.
- Returns: none (implicit).
- Side effects: see implementation.

#### */HasUltraInstinctRequirements
- Signature: `HasUltraInstinctRequirements()`
- Inputs: None
- Purpose: Return whether Ultra Instinct Requirements.
- Returns: boolean flag.
- Side effects: none expected.

#### */EnergyCapped
- Signature: `EnergyCapped()`
- Inputs: None
- Purpose: Handle energy capped.
- Returns: none (implicit).
- Side effects: see implementation.

#### */CheckTriggerUltraInstinct
- Signature: `CheckTriggerUltraInstinct()`
- Inputs: None
- Purpose: Check Trigger Ultra Instinct.
- Returns: none (implicit).
- Side effects: see implementation.

#### */UltraInstinct
- Signature: `UltraInstinct()`
- Inputs: None
- Purpose: Handle ultra instinct.
- Returns: none (implicit).
- Side effects: see implementation.

#### */UltraInstinctRevert
- Signature: `UltraInstinctRevert()`
- Inputs: None
- Purpose: Handle ultra instinct revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### */UltraInstinctSFX
- Signature: `UltraInstinctSFX()`
- Inputs: None
- Purpose: Handle ultra instinct sfx.
- Returns: none (implicit).
- Side effects: see implementation.

#### */UltraInstinctDestroyObstacles
- Signature: `UltraInstinctDestroyObstacles()`
- Inputs: None
- Purpose: Handle ultra instinct destroy obstacles.
- Returns: none (implicit).
- Side effects: see implementation.

#### */UltraInstinctSideStepLoop
- Signature: `UltraInstinctSideStepLoop()`
- Inputs: None
- Purpose: Handle ultra instinct side step loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### */UltraInstinctNoEscapeLoop
- Signature: `UltraInstinctNoEscapeLoop()`
- Inputs: None
- Purpose: Handle ultra instinct no escape loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/UltraInstinctGraphics
- Signature: `mob/proc/UltraInstinctGraphics()`
- Inputs: None
- Purpose: Handle ultra instinct graphics.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/UltraInstinctSwirlEffect
- Signature: `proc/UltraInstinctSwirlEffect(turf/pos, time = 100, start_size = 0.1, end_size = 5, easing = SINE_EASING, start_alpha = 211)`
- Inputs: turf/pos, time = 100, start_size = 0.1, end_size = 5, easing = SINE_EASING, start_alpha = 211
- Purpose: Handle ultra instinct swirl effect.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Ultra_Instinct_Rising_Aura
- Signature: `proc/Ultra_Instinct_Rising_Aura(obj/T,N=50)`
- Inputs: obj/T, N=50
- Purpose: Handle ultra instinct rising aura.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Rising_Aura_Ultra_Instinct/New
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
