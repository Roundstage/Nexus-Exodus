# Races

## Overview
The initializer identities below reflect the current modular race source. The existing supplementary proc reference remains a first-pass summary of legacy race mechanics. Android, Legendary Saiyan, Grand Regent, and the Jiren/Apex Alien specialization initialize without Anger; all other races retain the standard Anger system.

## Files
- `src/Code/Races/Alien/Alien.dm`
- `src/Code/Races/AlienStarterMoves.dm`
- `src/Code/Races/Android/Android.dm`
- `src/Code/Races/BioAndroid/Bios.dm`
- `src/Code/Races/BioAndroid/BioAndroid.dm`
- `src/Code/Races/Demigod/Demigod.dm`
- `src/Code/Races/Demon/Demon.dm`
- `src/Code/Races/FrostLord/Cooler.dm`
- `src/Code/Races/FrostLord/FrostLord.dm`
- `src/Code/Races/HalfSaiyan/HalfSaiyan.dm`
- `src/Code/Races/Human/Human.dm`
- `src/Code/Races/Icer/GoldIcer.dm`
- `src/Code/Races/Kai/Kai.dm`
- `src/Code/Races/Majin/Majin.dm`
- `src/Code/Races/Majins/GooTrap.dm`
- `src/Code/Races/Makyo/Makyo.dm`
- `src/Code/Races/Namekian/Namekian.dm`
- `src/Code/Races/Nameks.dm`
- `src/Code/Races/Oozaru.dm`
- `src/Code/Races/Saiyan/EliteSaiyan.dm`
- `src/Code/Races/Saiyan/LegendarySaiyan.dm`
- `src/Code/Races/Saiyan/RoyalBlue.dm`
- `src/Code/Races/Saiyan/Saiyan.dm`
- `src/Code/Races/Saiyan/SSBlue.dm`
- `src/Code/Races/Saiyan/SsGodRed.dm`
- `src/Code/Races/SpiritDoll/SpiritDoll.dm`
- `src/Code/Races/Tsujin/Tsujin.dm`
- `src/Code/Races/Viltrumite/Viltrumite.dm`
- `src/Code/Races/Viltrumite/ViltrumiteClothing.dm`
- `src/Code/Races/UltraInstinct.dm`
- `src/Code/Races/Shared/RaceProgression.dm`
- `src/Code/Races/Shared/RaceStatsOnlyMode.dm`
- `src/Code/Races/Yeet/Yeet.dm`

## Race Initializers
These modular initializers replace the former combined race implementation. "Not assigned" means the initializer leaves `Class` unset for a fresh character.

The shared dispatchers have these current signatures:

- `mob/proc/Race(force_race,force_elite,force_low_class,interactive_options=1,force_cooler=0,force_normal_class=0)` obtains the available-race list, opens the legacy chooser when `force_race` is absent, and delegates initialization.
- `mob/proc/InitializeRaceTemplate(force_race,force_elite,force_low_class,interactive_options=1,force_cooler=0,force_normal_class=0)` dispatches directly to the modular initializer and applies the initialized race's `bp_mod` to `ascension_bp`.

`force_normal_class` is forwarded only to Saiyan initialization. It prevents the random Low Class branch and interactive Elite offer when the creator selects the normal Warrior Blood trait; `force_elite` and `force_low_class` continue to select those explicit classes.

| File | Current initializer signature | Saved `Race` | Saved `Class` |
| --- | --- | --- | --- |
| `Alien/Alien.dm` | `mob/proc/Alien(interactive_options=1)` | `Alien` | Not assigned; the Nexus Alien population check may set `Elite` |
| `Android/Android.dm` | `mob/proc/Android(interactive_options=1)` | `Android` | Not assigned |
| `BioAndroid/BioAndroid.dm` | `mob/proc/Bio(interactive_options=1)` | `Bio-Android` | Not assigned |
| `Demigod/Demigod.dm` | `mob/proc/Demigod(interactive_options=1)` | `Demigod` | Not assigned |
| `Demon/Demon.dm` | `mob/proc/Demon(interactive_options=1)` | `Demon` | Not assigned |
| `FrostLord/Cooler.dm` | `mob/proc/Cooler()` | Retains `Frost Lord` | `Cooler` |
| `FrostLord/FrostLord.dm` | `mob/proc/Icer(interactive_options=1,force_cooler=0)` | `Frost Lord` | Not assigned, or `Cooler` when the variant is applied |
| `HalfSaiyan/HalfSaiyan.dm` | `mob/proc/Half_Saiyan()` | `Half Saiyan` | Not assigned |
| `Human/Human.dm` | `mob/proc/Human()` | `Human` | Not assigned |
| `Kai/Kai.dm` | `mob/proc/Kai(interactive_options=1)` | `Kai` | Not assigned |
| `Majin/Majin.dm` | `mob/proc/Majin(interactive_options=1)` | `Majin` | Not assigned |
| `Makyo/Makyo.dm` | `mob/proc/Makyo(interactive_options=1)` | `Makyo` | Not assigned |
| `Namekian/Namekian.dm` | `mob/proc/Namekian(interactive_options=1)` | `Namekian` | Not assigned |
| `Saiyan/EliteSaiyan.dm` | `mob/proc/Elite_Saiyan() if(Class!="Elite")` | Retains `Saiyan` | `Elite` |
| `Saiyan/LegendarySaiyan.dm` | `mob/proc/Legendary_Saiyan()` | `Saiyan` | `Legendary Saiyan` |
| `Saiyan/Saiyan.dm` | `mob/proc/Saiyan(Can_Elite=1,force_elite,force_low_class,force_normal_class=0)` | `Saiyan` | Not assigned, `Low Class`, or `Elite` |
| `SpiritDoll/SpiritDoll.dm` | `mob/proc/Doll(interactive_options=1)` | `Human` | `Spirit Doll` |
| `Tsujin/Tsujin.dm` | `mob/proc/Tsujin(interactive_options=1)` | `Tsujin` | Not assigned |
| `Viltrumite/Viltrumite.dm` | `mob/proc/Viltrumite()` | `Viltrumite` | `Viltrumite`, `Royal Blood`, or admin-designated `Grand Regent` |
| `Viltrumite/Viltrumite.dm` | `mob/proc/Half_Viltrumite()` | `Half-Viltrumite` | `Half-Viltrumite` or inherited `Royal Hybrid` |
| `Yeet/Yeet.dm` | `mob/proc/Yeet()` | `Yeet` | Not assigned |

`Races/_Shared/RaceProgression.dm` owns `NewZenkaiMods()`, `GetNewZenkaiMod()`, `Get_race_starting_bp_mod()`, and `ApplyStartingBP()` plus shared race/stat version constants. These declarations were moved out of `Main.dm` without changing their persisted variable names or behavior.

## Viltrumite lineage contract

`viltrumite_lineage` is the saved rules identifier (`standard`, `royal`, `grand_regent`, `hybrid`, or `royal_hybrid`); `Class` remains the compatible display/admin value. Standard Viltrumites use `2.4 * 0.70 = 1.68` effective creation BP, while the Grand Regent uses `2.4 * 1.375 = 3.30`, takes `0.90` incoming damage, and cannot possess Anger. Full and Half-Viltrumites have Intelligence `1`; their per-character `old_age_on` flag is disabled, so they receive neither natural decline penalties nor old-age death. This is distinct from combat immortality and does not grant death regeneration. Royal Blood increases free attributes and caps rather than passive damage resistance. Before the office has a holder, creation exposes one unique Grand Regent choice and atomically binds a successful character to account, slot, and creation timestamp. Afterward, only the audit-logged `setGrandRegent()` admin succession can transfer it and demote an online predecessor. Logout, death, and deletion never clear or reopen the office.

Half-Viltrumites appear in creation only while a matching pending family birth exists. Royal Blood, but not the Grand Regent office, can produce Royal Blood descendants or Royal Hybrids. Until the dedicated Viltrum map is added, both Viltrumite race names resolve through `getRaceSpawnName()` to the existing Saiyan spawn. The hidden `scourge_resistance` roll is made once at five percent; Royal Blood, Royal Hybrid, and Grand Regent lineages are unconditionally immune. Virus infection and forced-death progression are intentionally separate from this race foundation.

## Proc Reference

### src/Code/Races/AlienStarterMoves.dm

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

### src/Code/Races/BioAndroid/Bios.dm

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

### src/Code/Races/Icer/GoldIcer.dm

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

### src/Code/Races/Majins/GooTrap.dm

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
- Purpose: Revert Great Ape stats and art, restore the exact pre-form pixel anchor/overlays, and remove its enlarged combat hitbox.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Great_Ape
- Signature: `mob/proc/Great_Ape(Golden=0) if(!cyber_bp&&!has_modules()&&!IsGreatApe()&&Tail&&!ssj&&!Dead)`
- Inputs: Golden=0
- Purpose: Apply Great Ape stats and centered 96-pixel art while registering a 60-by-72 rectangular combat hitbox that remains anchored to the character's physical center.
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

### src/Code/Races/Saiyan/RoyalBlue.dm

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

### src/Code/Races/Saiyan/SSBlue.dm

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

### src/Code/Races/Saiyan/SsGodRed.dm

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

### src/Code/Races/UltraInstinct.dm

#### mob/Admin4/verb/goUltraInstinct
- Signature: `mob/Admin4/verb/goUltraInstinct(mob/m in world)`
- Inputs: mob/m in world
- Purpose: Handle go ultra instinct.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/massUltraInstinct
- Signature: `mob/Admin4/verb/massUltraInstinct()`
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
### integrated race adaptation

- `mob/proc/Kanassan(interactive_options)` initializes the psionic Kanassan race.
- `mob/proc/Heran(interactive_options)` initializes the combat-focused Heran race, its SSJ1-tier awakening threshold, and its racial transformation skill.
- `mob/proc/ensureHeranTransformation()` migrates existing Herans to exactly one owned transformation object.
- `mob/proc/hasHeranTransformationReq()` applies the standard Saiyan tier-one available/effective BP gate.
- `mob/proc/getHeranTransformationEquivalentBPAdd()` converts the full standard SSJ1 result into one additive BP gain; mastered full power uses the same decaying SSJ bonus and never exceeds its Saiyan equivalent.
- `mob/proc/getHeranTransformationNaturalBPAdd()` and `getHeranTransformationStaticBPAdd()` preserve SSJ1's exact calculation order around potential and other temporary multipliers while presenting the sum as one form gain.
- `mob/proc/activateHeranTransformation()` and `revertHeranTransformation()` apply and remove the integrated transformation body, temporary BP, Energy upkeep, lighting, HUD, appearance rebuild, and canonical primary-form state without permanent stat changes.
- `mob/proc/normalizeHeranTransformation()` restores skill, icon, BP cap, drain loop, and overlays on login.
- `mob/proc/heranTransformationDrainLoop()` mirrors standard SSJ1 mastery and Energy upkeep, becoming drainless at mastery.
- `mob/proc/canSelectAncientNamekian()` enforces the rare-lineage population/offer rule.
- `mob/proc/applyAncientNamekianLineage()` layers Ancient stats and skills onto the existing Namekian implementation.
- `mob/proc/applyAncientProgenitorLineage()` layers the rare sensor/science package onto an existing Android implementation.
- `mob/Admin4/verb/testRoleplayRacePort()` applies a ported template to a selected test character.
