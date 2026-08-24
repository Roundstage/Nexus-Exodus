# Misc

## Overview
Legacy miscellaneous features that still have a specific, isolated responsibility. Catch-all runtime files are forbidden; new definitions belong to a named subsystem file.

## Files
- `src/Code/Misc/FrameRateConstantTrick.dm`
- `src/Code/Misc/InstaLeech.dm`
- `src/Code/Misc/Jackson.dm`
- `src/Code/Misc/Saitama.dm`
- `src/Code/Misc/Trolls.dm`
- `src/Code/Misc/Trolls2.dm`
- `src/Code/Misc/Utilities.dm`

## Catch-all cleanup

The compiled `Unsorted2.dm`, `TEMP.dm`, `Testing.dm`, `Notes.dm`, `Notes2019.dm`, and `TensVerbs.dm` files were removed. Their active definitions now live in responsibility-specific files:

| Responsibility | Files |
|---|---|
| Administration and diagnostics | `src/Code/Admin/EffectDiagnostics.dm`, `src/Code/Admin/TensDiagnostics.dm` |
| Movement | `src/Code/Application/Movement/FlashStep.dm`, `src/Code/Application/Movement/PixelMovementInitialization.dm`, `src/Code/Interface/Movement/MovementInputPrompt.dm` |
| Combat | `src/Code/Combat/ChasePressure.dm`, `src/Code/Combat/NoxianGuillotine.dm`, `src/Code/Combat/ResourcePenalties.dm`, `src/Code/Combat/Shielding.dm` |
| Lifecycle and core state | `src/Code/Infrastructure/MobLifecycle.dm`, `src/Code/Infrastructure/ObjectLifecycle.dm`, `src/Code/CoreFunctions/TickTiming.dm`, `src/Code/CoreFunctions/Vars/AtomCoreVars.dm` |
| Map, races, projectiles, and UI | `src/Code/MapCode/JaggedEdgeFillers.dm`, `src/Code/Races/Shared/RaceStatsOnlyMode.dm`, `src/Code/ProjectileSystem/BeamRedirector.dm`, `src/Code/ProjectileSystem/ProjectileCombatModifiers.dm`, `src/Code/UI/LegacyTabs.dm` |
| Visual effects | `src/Code/VisualEffects/AppearanceBounds.dm`, `src/Code/VisualEffects/EffectCache.dm`, `src/Code/VisualEffects/ExplosionEffects.dm`, `src/Code/VisualEffects/FlipAnimation.dm`, `src/Code/VisualEffects/KiWater.dm` |

Disabled scratch tests and comment-only notes were intentionally removed from the build.

## Proc Reference

### src/Code/Misc/FrameRateConstantTrick.dm

#### client/proc/MaxFPSTrick
- Signature: `MaxFPSTrick()`
- Inputs: None
- Purpose: Handle max fpstrick.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Misc/InstaLeech.dm

#### mob/proc/Omega_KB
- Signature: `mob/proc/Omega_KB() for(var/obj/Omega_KB/S in src) if(S.Enabled)`
- Inputs: None
- Purpose: Handle omega kb.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Set_Omega_Knockback_Distance
- Signature: `verb/Set_Omega_Knockback_Distance()`
- Inputs: None
- Purpose: Set Omega Knockback Distance.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### verb/Omega_Knockback
- Signature: `verb/Omega_Knockback()`
- Inputs: None
- Purpose: Handle omega knockback.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Insta_Leech
- Signature: `verb/Insta_Leech()`
- Inputs: None
- Purpose: Handle insta leech.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Misc/Jackson.dm

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Michael_Jackson_Dance
- Signature: `mob/proc/Michael_Jackson_Dance()`
- Inputs: None
- Purpose: Handle michael jackson dance.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MJ_Immune
- Signature: `mob/proc/MJ_Immune()`
- Inputs: None
- Purpose: Handle mj immune.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/MJ_Dance
- Signature: `proc/MJ_Dance()`
- Inputs: None
- Purpose: Handle mj dance.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Michael_Jackson/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Michael_Jackson/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Dance_Effects
- Signature: `mob/proc/Dance_Effects()`
- Inputs: None
- Purpose: Handle dance effects.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/MJ_Stars
- Signature: `turf/proc/MJ_Stars()`
- Inputs: None
- Purpose: Handle mj stars.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Skeleton/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/MJ/Bump
- Signature: `Bump(atom/A)`
- Inputs: atom/A
- Purpose: Handle bump.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/MJ/Asteroid/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/MJ/Asteroid/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/MJ/Meteor/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/MJ/Meteor/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Misc/Saitama.dm

#### mob/Admin4/verb/makeSaitama
- Signature: `mob/Admin4/verb/makeSaitama(mob/m in world)`
- Inputs: mob/m in world
- Purpose: Handle make saitama.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/enableSaitamaRotations
- Signature: `mob/Admin4/verb/enableSaitamaRotations()`
- Inputs: None
- Purpose: Handle enable saitama rotations.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/SaitamaRotationLoop
- Signature: `SaitamaRotationLoop()`
- Inputs: None
- Purpose: Handle saitama rotation loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/FindNewSaitama
- Signature: `FindNewSaitama()`
- Inputs: None
- Purpose: Handle find new saitama.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DeleteSaitama
- Signature: `DeleteSaitama()`
- Inputs: None
- Purpose: Delete Saitama.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/BecomeSaitama
- Signature: `BecomeSaitama(hours=1)`
- Inputs: hours=1
- Purpose: Handle become saitama.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SaitamaLoop
- Signature: `SaitamaLoop()`
- Inputs: None
- Purpose: Handle saitama loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/SaitamaTurfHit
- Signature: `turf/proc/SaitamaTurfHit(d)`
- Inputs: d
- Purpose: Handle saitama turf hit.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SaitamaBloodEffect
- Signature: `mob/proc/SaitamaBloodEffect(blood_range = 4, blood_chance = 67)`
- Inputs: blood_range = 4, blood_chance = 67
- Purpose: Handle saitama blood effect.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Misc/Trolls.dm

#### mob/Admin5/verb/oldTroll
- Signature: `mob/Admin5/verb/oldTroll()`
- Inputs: None
- Purpose: Handle old troll.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Troll/proc/Troll_Blast_Response
- Signature: `mob/Troll/proc/Troll_Blast_Response() while(src)`
- Inputs: None
- Purpose: Handle troll blast response.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Troll/proc/Troll_Beam_Response
- Signature: `mob/Troll/proc/Troll_Beam_Response() while(src)`
- Inputs: None
- Purpose: Handle troll beam response.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Troll/New
- Signature: `New() spawn(10) if(src&&!(src in Make_List))`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Troll_Initialize
- Signature: `proc/Troll_Initialize()`
- Inputs: None
- Purpose: Handle troll initialize.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Troll_Grab_Struggle
- Signature: `proc/Troll_Grab_Struggle() while(src)`
- Inputs: None
- Purpose: Handle troll grab struggle.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Troll_Zanzoken
- Signature: `proc/Troll_Zanzoken() while(src)`
- Inputs: None
- Purpose: Handle troll zanzoken.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Troll_Spam
- Signature: `proc/Troll_Spam()`
- Inputs: None
- Purpose: Handle troll spam.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Troll_Name
- Signature: `proc/Troll_Name()`
- Inputs: None
- Purpose: Handle troll name.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Troll_Stats
- Signature: `proc/Troll_Stats() while(src)`
- Inputs: None
- Purpose: Handle troll stats.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Troll_Message
- Signature: `proc/Troll_Message()`
- Inputs: None
- Purpose: Handle troll message.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Troll_Target
- Signature: `proc/Troll_Target() while(src)`
- Inputs: None
- Purpose: Handle troll target.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Troll_Fly
- Signature: `proc/Troll_Fly()`
- Inputs: None
- Purpose: Handle troll fly.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Troll_Stand
- Signature: `proc/Troll_Stand()`
- Inputs: None
- Purpose: Handle troll stand.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Troll_Action
- Signature: `proc/Troll_Action() while(src)`
- Inputs: None
- Purpose: Handle troll action.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Troll_Attack
- Signature: `proc/Troll_Attack()`
- Inputs: None
- Purpose: Handle troll attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Troll_Run
- Signature: `proc/Troll_Run()`
- Inputs: None
- Purpose: Handle troll run.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Troll_Wander
- Signature: `proc/Troll_Wander()`
- Inputs: None
- Purpose: Handle troll wander.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Misc/Trolls2.dm

#### mob/Admin4/verb/newtroll
- Signature: `mob/Admin4/verb/newtroll()`
- Inputs: None
- Purpose: Handle newtroll.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GetRandomTextColor
- Signature: `GetRandomTextColor()`
- Inputs: None
- Purpose: Return Random Text Color.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/RandomInsultName
- Signature: `RandomInsultName()`
- Inputs: None
- Purpose: Handle random insult name.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/TrollRespawn
- Signature: `mob/proc/TrollRespawn()`
- Inputs: None
- Purpose: Handle troll respawn.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/new_troll_ai
- Signature: `new_troll_ai()`
- Inputs: None
- Purpose: Handle new troll ai.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/LeagueInviteTroll
- Signature: `LeagueInviteTroll(mob/inviter, leagueName)`
- Inputs: mob/inviter, leagueName
- Purpose: Handle league invite troll.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/CantTalkFor
- Signature: `CantTalkFor(t)`
- Inputs: t
- Purpose: Handle cant talk for.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/TrollRunAwayMode
- Signature: `TrollRunAwayMode()`
- Inputs: None
- Purpose: Handle troll run away mode.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/TrollGotAttacked
- Signature: `TrollGotAttacked(mob/m)`
- Inputs: mob/m
- Purpose: Handle troll got attacked.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/OtherTrollsTargeting
- Signature: `OtherTrollsTargeting(mob/m)`
- Inputs: mob/m
- Purpose: Handle other trolls targeting.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/find_player
- Signature: `find_player()`
- Inputs: None
- Purpose: Handle find player.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/invalid_player
- Signature: `invalid_player()`
- Inputs: None
- Purpose: Handle invalid player.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/running_away
- Signature: `running_away()`
- Inputs: None
- Purpose: Handle running away.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/PlayerListSpoof
- Signature: `PlayerListSpoof()`
- Inputs: None
- Purpose: Handle player list spoof.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/GetTrollKey
- Signature: `GetTrollKey()`
- Inputs: None
- Purpose: Return Troll Key.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/new_troll/proc/troll_name
- Signature: `troll_name()`
- Inputs: None
- Purpose: Handle troll name.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/troll_leech
- Signature: `troll_leech()`
- Inputs: None
- Purpose: Handle troll leech.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/troll_regen
- Signature: `troll_regen()`
- Inputs: None
- Purpose: Handle troll regen.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/detect_blasting
- Signature: `detect_blasting()`
- Inputs: None
- Purpose: Handle detect blasting.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/grab_struggle
- Signature: `grab_struggle()`
- Inputs: None
- Purpose: Handle grab struggle.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/troll_actions
- Signature: `troll_actions()`
- Inputs: None
- Purpose: Handle troll actions.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/in_combat
- Signature: `in_combat()`
- Inputs: None
- Purpose: Handle in combat.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/CombatTimerDecreaseLoop
- Signature: `CombatTimerDecreaseLoop()`
- Inputs: None
- Purpose: Handle combat timer decrease loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/TrollMeleeMoveLoop
- Signature: `TrollMeleeMoveLoop()`
- Inputs: None
- Purpose: Handle troll melee move loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/MeleeMoveStep
- Signature: `MeleeMoveStep(turf/attackerLoc)`
- Inputs: turf/attackerLoc
- Purpose: Handle melee move step.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/troll_fight
- Signature: `troll_fight()`
- Inputs: None
- Purpose: Handle troll fight.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/TrollZanzo
- Signature: `TrollZanzo(turf/t)`
- Inputs: turf/t
- Purpose: Handle troll zanzo.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/get_troll_angry_message
- Signature: `get_troll_angry_message()`
- Inputs: None
- Purpose: Return troll angry message.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/new_troll/proc/start_talking
- Signature: `start_talking()`
- Inputs: None
- Purpose: Start talking.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/new_troll/proc/stop_beaming
- Signature: `stop_beaming()`
- Inputs: None
- Purpose: Stop beaming.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/new_troll/proc/interrupted
- Signature: `interrupted(checkTargetReached = 1)`
- Inputs: checkTargetReached = 1
- Purpose: Handle interrupted.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/untrain
- Signature: `untrain()`
- Inputs: None
- Purpose: Handle untrain.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/TrollTargetedPlayer
- Signature: `TrollTargetedPlayer()`
- Inputs: None
- Purpose: Handle troll targeted player.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/new_troll/proc/troll_step
- Signature: `troll_step()`
- Inputs: None
- Purpose: Handle troll step.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/destroy_turf
- Signature: `turf/proc/destroy_turf()`
- Inputs: None
- Purpose: Handle destroy turf.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/same_area
- Signature: `proc/same_area(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Handle same area.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/respond_anyway
- Signature: `mob/proc/respond_anyway(msg)`
- Inputs: msg
- Purpose: Handle respond anyway.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/NameMentioned
- Signature: `mob/proc/NameMentioned(msg)`
- Inputs: msg
- Purpose: Handle name mentioned.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/TrollNickName
- Signature: `mob/proc/TrollNickName(n = "")`
- Inputs: n = ""
- Purpose: Handle troll nick name.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/TrollSay
- Signature: `mob/proc/TrollSay(msg)`
- Inputs: msg
- Purpose: Handle troll say.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/troll_respond
- Signature: `mob/proc/troll_respond(msg)`
- Inputs: msg
- Purpose: Handle troll respond.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/mispell
- Signature: `proc/mispell(name, uppercase=1, wrong_vowel=0.1, drop_letter=0.1, swap_letter=0.1)`
- Inputs: name, uppercase=1, wrong_vowel=0.1, drop_letter=0.1, swap_letter=0.1
- Purpose: Handle mispell.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/is_symbol
- Signature: `proc/is_symbol(t)`
- Inputs: t
- Purpose: Return whether symbol.
- Returns: boolean flag.
- Side effects: none expected.

### Procedures relocated from the former catch-all module

These legacy proc summaries are retained for reference. Their implementations now live in the Admin, Combat, Communication, CoreFunctions, PlayerMechanics, Technology, and WorldMechanics modules listed in the subsystem documentation.

#### mob/verb/StopAllSounds
- Signature: `mob/verb/StopAllSounds()`
- Inputs: None
- Purpose: Emergency legacy control that stops all sounds. Normal player-music control uses `Stop_Player_Music()` and reserved channel 1024 instead.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### obj/proc/MakeImmovableIndestructable
- Signature: `obj/proc/MakeImmovableIndestructable()`
- Inputs: None
- Purpose: Handle make immovable indestructable.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Set_Player_Description
- Signature: `mob/verb/Set_Player_Description()`
- Inputs: None
- Purpose: Toggle the structured Profile Builder for a self-authored name, title, live sprite or bounded raw PNG/JPEG/WEBP/WEBM upload up to the 4K pixel budget, and safely formatted biography instead of accepting arbitrary HTML or remote image URLs.
- Returns: none (implicit).
- Side effects: opens or closes `NexusDescriptionEditor`; actions normalize, bound, and persist profile identity, portrait source/direction, custom-art metadata, and biography fields.

#### proc/View
- Signature: `proc/View(r,c)`
- Inputs: r, c
- Purpose: Handle view.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Missile
- Signature: `proc/Missile(t,s,e)`
- Inputs: t, s, e
- Purpose: Handle missile.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_step
- Signature: `proc/Get_step(mob/m,D)`
- Inputs: mob/m, D
- Purpose: Return step.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/Admin5/verb/altAutoFightTest
- Signature: `mob/Admin5/verb/altAutoFightTest(mob/m in world)`
- Inputs: mob/m in world
- Purpose: Handle alt auto fight test.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/battleTest
- Signature: `mob/Admin5/verb/battleTest()`
- Inputs: None
- Purpose: Handle battle test.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/fight_copy_of_self
- Signature: `fight_copy_of_self()`
- Inputs: None
- Purpose: Handle fight copy of self.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Random_stat_change
- Signature: `mob/proc/Random_stat_change()`
- Inputs: None
- Purpose: Handle random stat change.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/setTransformSize
- Signature: `mob/Admin5/verb/setTransformSize(mob/m in world)`
- Inputs: mob/m in world
- Purpose: Set transform size.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/blast_view
- Signature: `proc/blast_view(dist=10, atom/center)`
- Inputs: search distance and any map-backed center atom.
- Purpose: Return active same-area projectiles, using BYOND's native spatial query for common short ranges and the area projectile index for long ranges.
- Returns: projectile list.
- Side effects: none.

#### proc/player_range
- Signature: `proc/player_range(range=20, atom/center)`
- Inputs: search range and any map-backed center atom.
- Purpose: Return same-area players with a hybrid native-spatial/area-index query.
- Returns: player list.
- Side effects: none.

#### proc/player_view
- Signature: `proc/player_view(range = 20, atom/center, seePastDenseObjs = 1)`
- Inputs: search range, center atom, and dense-object visibility policy.
- Purpose: Return visible same-area players with a hybrid native-spatial/area-index query.
- Returns: player list.
- Side effects: none.

#### proc/mob_view
- Signature: `proc/mob_view(range=20, atom/center, seePastDenseObjs = 1)`
- Inputs: search range, center atom, and dense-object visibility policy.
- Purpose: Return visible same-area mobs with a hybrid native-spatial/area-index query.
- Returns: mob list.
- Side effects: none.

#### proc/npc_view
- Signature: `proc/npc_view(range=20, atom/center, seePastDenseObjs = 1)`
- Inputs: search range, center atom, and dense-object visibility policy.
- Purpose: Return visible same-area NPCs with a hybrid native-spatial/area-index query.
- Returns: NPC list.
- Side effects: none.

#### proc/viewable
- Signature: `proc/viewable(atom/a, atom/b, max_dist = 5000, seePastDenseObjs = 1)`
- Inputs: two atoms, a maximum tile distance, and whether dense non-opaque objects can be seen through.
- Purpose: Test line of sight using an early-exit supercover grid walk so corners and diagonal paths are handled consistently without allocating a turf list.
- Returns: boolean visibility.
- Side effects: none.

#### proc/gridRayCanReach
- Signature: `proc/gridRayCanReach(atom/start_atom, atom/end_atom, ray_mode = GRID_RAY_VISIBILITY, see_past_dense_objects = TRUE)`
- Purpose: Walk every touched grid cell and stop at the first visibility or lighting blocker.
- Returns: boolean reachability, with the target-facing blocking tile still visible.
- Side effects: none.

#### proc/nexusGridRayTileBlocks
- Signature: `proc/nexusGridRayTileBlocks(turf/ray_turf, ray_mode, see_past_dense_objects = TRUE)`
- Purpose: Apply the shared visibility or lighting blocker policy to one traversed turf.
- Returns: boolean blocker state.

#### proc/traceGridRay
- Signature: `proc/traceGridRay(atom/start_atom, atom/end_atom, include_start = FALSE)`
- Purpose: Materialize the deterministic supercover path for diagnostics and tests; runtime visibility uses `gridRayCanReach()`.
- Returns: ordered turf list.
- Side effects: none.

#### obj/Toxic_Waste_Barrel/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Toxic_Waste_Barrel/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Toxic_Cloud/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Toxic_Cloud/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/Spread_toxic_clouds
- Signature: `atom/movable/proc/Spread_toxic_clouds()`
- Inputs: None
- Purpose: Handle spread toxic clouds.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Geiger_sound_loop
- Signature: `mob/proc/Geiger_sound_loop()`
- Inputs: None
- Purpose: Handle geiger sound loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Radiation_loop
- Signature: `mob/proc/Radiation_loop()`
- Inputs: None
- Purpose: Handle radiation loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ApplyStun
- Signature: `ApplyStun(time = 8, no_immunity, stun_power = 1) //10 = 1 second`
- Inputs: time = 8, no_immunity, stun_power = 1
- Purpose: Apply Stun.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stunned
- Signature: `Stunned()`
- Inputs: None
- Purpose: Handle stunned.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/StunDecay
- Signature: `StunDecay()`
- Inputs: None
- Purpose: Handle stun decay.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Priest/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Priest/Click
- Signature: `Click()`
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

#### mob/proc/Divorce
- Signature: `mob/proc/Divorce()`
- Inputs: None
- Purpose: Handle divorce.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Kilt_by_redneck
- Signature: `mob/proc/Kilt_by_redneck()`
- Inputs: None
- Purpose: Handle kilt by redneck.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Add_relog_log
- Signature: `mob/proc/Add_relog_log()`
- Inputs: None
- Purpose: Add relog log.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Spam_relogger
- Signature: `mob/proc/Spam_relogger()`
- Inputs: None
- Purpose: Handle spam relogger.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Remove_all_nulls
- Signature: `proc/Remove_all_nulls()`
- Inputs: None
- Purpose: Periodically prune deleted references from selected runtime registries and area indexes.
- Returns: none (implicit).
- Side effects: compacts runtime lists while deliberately leaving positional hotkey lists untouched.

#### mob/Admin5/verb/testMobList
- Signature: `mob/Admin5/verb/testMobList(area/a in world)`
- Inputs: area/a in world
- Purpose: Handle test mob list.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/New
- Signature: `obj/items/New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/items/Move
- Signature: `obj/items/Move()`
- Inputs: None
- Purpose: Handle move.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Car/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Car_AI
- Signature: `proc/Car_AI()`
- Inputs: None
- Purpose: Handle car ai.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Car/Move
- Signature: `Move()`
- Inputs: None
- Purpose: Handle move.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Car/Bump
- Signature: `Bump(mob/m)`
- Inputs: mob/m
- Purpose: Handle bump.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/carWreckFrequency
- Signature: `mob/Admin4/verb/carWreckFrequency()`
- Inputs: None
- Purpose: Handle car wreck frequency.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Car_wreck_loop
- Signature: `proc/Car_wreck_loop()`
- Inputs: None
- Purpose: Handle car wreck loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Car_wreck
- Signature: `proc/Car_wreck(mob/m)`
- Inputs: mob/m
- Purpose: Handle car wreck.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/carTest
- Signature: `mob/Admin4/verb/carTest(mob/m in world)`
- Inputs: mob/m in world
- Purpose: Handle car test.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Change_car_icon
- Signature: `verb/Change_car_icon()`
- Inputs: None
- Purpose: Handle change car icon.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Drivable_Car/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Drivable_Car/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Car_loop
- Signature: `proc/Car_loop()`
- Inputs: None
- Purpose: Handle car loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Drivable_Car/Move
- Signature: `Move()`
- Inputs: None
- Purpose: Handle move.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Drivable_Car/Bump
- Signature: `Bump(mob/m)`
- Inputs: mob/m
- Purpose: Handle bump.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Misc/Utilities.dm

#### proc/parse
- Signature: `parse(string, separator)`
- Inputs: string, separator
- Purpose: Handle parse.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ClientColorFlick
- Signature: `ClientColorFlick(rgb)`
- Inputs: rgb
- Purpose: Handle client color flick.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ClientColorInvertFlick
- Signature: `ClientColorInvertFlick()`
- Inputs: None
- Purpose: Handle client color invert flick.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/proc/SetTransformSize
- Signature: `atom/proc/SetTransformSize(n = 1)`
- Inputs: n = 1
- Purpose: Set Transform Size.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/PointArrow
- Signature: `proc/PointArrow(obj/Arrow, atom/Target, MinDistance, ArrowDistance, instant_update = 0, dist_mod = 1, do_rotation = 1)`
- Inputs: obj/Arrow, atom/Target, MinDistance, ArrowDistance, instant_update = 0, dist_mod = 1, do_rotation = 1
- Purpose: Handle point arrow.
- Returns: none (implicit).
- Side effects: see implementation.

#### datum/NexusVectorKinematics
- Signature: `new(new_max_velocity = 32, new_acceleration = 32, initial_direction, initial_speed_ratio = 0)`
- Inputs: velocity cap, acceleration, optional initial direction, and initial fraction of maximum speed.
- Purpose: Maintain allocation-light X/Y velocity for accelerated projectiles and other movable skill actors.
- Side effects: stores mutable velocity state on the datum.

#### datum/NexusVectorKinematics/proc/steerToward
- Signature: `steerToward(delta_x, delta_y, duration_deciseconds = 1)`
- Purpose: Accelerate the current velocity toward an arbitrary displacement vector without exceeding acceleration or maximum speed.
- Returns: resulting speed magnitude.

#### datum/NexusVectorKinematics/proc/steerTowardAtom
- Signature: `steerTowardAtom(atom/movable/subject, atom/movable/target, duration_deciseconds = 1, move_away = FALSE)`
- Purpose: Steer toward or away from another movable using pixel-center displacement.
- Returns: resulting speed magnitude.

#### datum/NexusVectorKinematics/proc/distanceToAtom
- Signature: `distanceToAtom(atom/movable/subject, atom/movable/target)`
- Purpose: Return Euclidean pixel-center distance between two movables.

#### datum/NexusVectorKinematics/proc/steerTowardDirection
- Signature: `steerTowardDirection(movement_direction, duration_deciseconds = 1)`
- Purpose: Steer toward a BYOND direction while preserving continuous velocity between direction changes.
- Returns: resulting speed magnitude.

#### datum/NexusVectorKinematics/proc/advance
- Signature: `advance(atom/movable/subject, duration_deciseconds = 1, maximum_distance = -1)`
- Purpose: Advance a movable through `vector_step()`, limit optional travel, and remove only collision-blocked velocity components.
- Returns: the underlying vector-movement result.
- Side effects: moves the subject, updates collision telemetry, and clears blocked fractional carry.

#### atom/movable/proc/MoveByAngle
- Signature: `atom/movable/proc/MoveByAngle(ang=0)`
- Inputs: ang=0
- Purpose: Handle move by angle.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/vector_step_toward
- Signature: `proc/vector_step_toward(mob/a,mob/b,step_speed)`
- Inputs: mob/a, mob/b, step_speed
- Purpose: Handle vector step toward.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/vector_step
- Signature: `proc/vector_step(atom/movable/a, ang = 0, step_speed, requested_x, requested_y, movement_direction)`
- Inputs: movable atom, angle and speed, or optional explicit X/Y displacement components and physical collision direction.
- Purpose: Move by an angle or arbitrary vector components while preserving fractional pixels, bounded substeps, requested-versus-actual collision telemetry, and a collision direction independent of visible facing.
- Returns: the final native `Move()` result or null when no whole-pixel move was attempted.
- Side effects: updates position, fractional carry, and vector collision telemetry.

#### proc/vector_step_dir
- Signature: `proc/vector_step_dir(atom/movable/a, d, step_speed)`
- Inputs: atom/movable/a, d, step_speed
- Purpose: Handle vector step by direction.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/get_global_angle
- Signature: `proc/get_global_angle(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Return global angle.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/arctanD
- Signature: `proc/arctanD(x,y)`
- Inputs: x, y
- Purpose: Handle arctan d.
- Returns: none (implicit).
- Side effects: see implementation.
