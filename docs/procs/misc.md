# Misc

## Overview
Auto-generated first-pass proc summaries based on signature names. Refine descriptions during refactors.

## Files
- `src/Code/Misc/60FPSCONSTANTTRICK.dm`
- `src/Code/Misc/InstaLeech.dm`
- `src/Code/Misc/Jackson.dm`
- `src/Code/Misc/Saitama.dm`
- `src/Code/Misc/TEMP.dm`
- `src/Code/Misc/TensVerbs.dm`
- `src/Code/Misc/Testing.dm`
- `src/Code/Misc/Trolls.dm`
- `src/Code/Misc/Trolls2.dm`
- `src/Code/Misc/Unsorted.dm`
- `src/Code/Misc/Unsorted2.dm`
- `src/Code/Misc/Utilities.dm`

## Proc Reference

### src/Code/Misc/60FPSCONSTANTTRICK.dm

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

#### mob/Admin4/verb/MakeSaitama
- Signature: `mob/Admin4/verb/MakeSaitama(mob/m in world)`
- Inputs: mob/m in world
- Purpose: Handle make saitama.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/Enable_Saitama_Rotations
- Signature: `mob/Admin4/verb/Enable_Saitama_Rotations()`
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

### src/Code/Misc/TEMP.dm

#### mob/proc/View_update_logs
- Signature: `mob/proc/View_update_logs()`
- Inputs: None
- Purpose: Handle view update logs.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Toggle_tabs
- Signature: `mob/verb/Toggle_tabs()`
- Inputs: None
- Purpose: Toggle tabs.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Update_tab_button_text
- Signature: `mob/proc/Update_tab_button_text(button_visible=1)`
- Inputs: button_visible=1
- Purpose: Update tab button text.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### obj/Noxian_Guillotine/verb/Noxian_Guillotine
- Signature: `Noxian_Guillotine()`
- Inputs: None
- Purpose: Handle noxian guillotine.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Is_Darius
- Signature: `Is_Darius()`
- Inputs: None
- Purpose: Return whether Darius.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Apply_Bleed
- Signature: `Apply_Bleed()`
- Inputs: None
- Purpose: Apply Bleed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Bleed_Graphics
- Signature: `Bleed_Graphics()`
- Inputs: None
- Purpose: Handle bleed graphics.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Bleed_Damage
- Signature: `Bleed_Damage()`
- Inputs: None
- Purpose: Handle bleed damage.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/For_Noxus
- Signature: `For_Noxus()`
- Inputs: None
- Purpose: Handle for noxus.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Misc/TensVerbs.dm

#### mob/proc/alter_resources
- Signature: `alter_resources()`
- Inputs: None
- Purpose: Handle alter resources.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/alter_intelligence
- Signature: `alter_intelligence()`
- Inputs: None
- Purpose: Handle alter intelligence.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Misc/Testing.dm

#### mob/proc/Flip
- Signature: `mob/proc/Flip()`
- Inputs: None
- Purpose: Handle flip.
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

### src/Code/Misc/Unsorted.dm

#### mob/verb/Stream_Music_to_Everyone_Nearby
- Signature: `mob/verb/Stream_Music_to_Everyone_Nearby()`
- Inputs: None
- Purpose: Handle stream music to everyone nearby.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/StopAllSounds
- Signature: `mob/verb/StopAllSounds()`
- Inputs: None
- Purpose: Stop All Sounds.
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
- Purpose: Set Player Description.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

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

#### mob/Admin5/verb/Alt_Auto_Fight_Test
- Signature: `mob/Admin5/verb/Alt_Auto_Fight_Test(mob/m in world)`
- Inputs: mob/m in world
- Purpose: Handle alt auto fight test.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/Battle_test
- Signature: `mob/Admin5/verb/Battle_test()`
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

#### mob/Admin5/verb/Set_transform_size
- Signature: `mob/Admin5/verb/Set_transform_size(mob/m in world)`
- Inputs: mob/m in world
- Purpose: Set transform size.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/blast_view
- Signature: `proc/blast_view(dist=10,mob/center)`
- Inputs: dist=10, mob/center
- Purpose: Handle blast view.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/player_range
- Signature: `proc/player_range(range=20,mob/center)`
- Inputs: range=20, mob/center
- Purpose: Handle player range.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/player_view
- Signature: `proc/player_view(range = 20, mob/center, seePastDenseObjs = 1)`
- Inputs: range = 20, mob/center, seePastDenseObjs = 1
- Purpose: Handle player view.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/mob_view
- Signature: `proc/mob_view(range=20,mob/center, seePastDenseObjs = 1)`
- Inputs: range=20, mob/center, seePastDenseObjs = 1
- Purpose: Handle mob view.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/npc_view
- Signature: `proc/npc_view(range=20,mob/center, seePastDenseObjs = 1)`
- Inputs: range=20, mob/center, seePastDenseObjs = 1
- Purpose: Handle npc view.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/viewable
- Signature: `proc/viewable(mob/a, mob/b, max_dist = 5000, seePastDenseObjs = 1)`
- Inputs: mob/a, mob/b, max_dist = 5000, seePastDenseObjs = 1
- Purpose: Handle viewable.
- Returns: none (implicit).
- Side effects: see implementation.

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
- Purpose: Remove all nulls.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin5/verb/Test_mob_list
- Signature: `mob/Admin5/verb/Test_mob_list(area/a in world)`
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

#### mob/Admin4/verb/Car_wreck_frequency
- Signature: `mob/Admin4/verb/Car_wreck_frequency()`
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

#### mob/Admin4/verb/car_test
- Signature: `mob/Admin4/verb/car_test(mob/m in world)`
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

### src/Code/Misc/Unsorted2.dm

#### obj/Move
- Signature: `obj/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)`
- Inputs: NewLoc, Dir = 0, step_x = 0, step_y = 0
- Purpose: Handle move.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/proc/ObjectRespawn
- Signature: `obj/proc/ObjectRespawn()`
- Inputs: None
- Purpose: Handle object respawn.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/Diagnose_Deleted_Objects
- Signature: `mob/Admin5/verb/Diagnose_Deleted_Objects()`
- Inputs: None
- Purpose: Handle diagnose deleted objects.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Del
- Signature: `obj/Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GarbageCollect
- Signature: `proc/GarbageCollect()`
- Inputs: None
- Purpose: Handle garbage collect.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GarbageCollectLoop
- Signature: `proc/GarbageCollectLoop()`
- Inputs: None
- Purpose: Handle garbage collect loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DeletePendingObjectsLoop
- Signature: `proc/DeletePendingObjectsLoop()`
- Inputs: None
- Purpose: Delete Pending Objects Loop.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/DeletePendingObjects
- Signature: `proc/DeletePendingObjects()`
- Inputs: None
- Purpose: Delete Pending Objects.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Del
- Signature: `mob/Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ActivatePixelMovement
- Signature: `ActivatePixelMovement()`
- Inputs: None
- Purpose: Handle activate pixel movement.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/UpdateRaceStatsOnlyModeStatsLoop
- Signature: `UpdateRaceStatsOnlyModeStatsLoop()`
- Inputs: None
- Purpose: Update Race Stats Only Mode Stats Loop.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/UpdateRaceStatsOnlyModeStats
- Signature: `UpdateRaceStatsOnlyModeStats()`
- Inputs: None
- Purpose: Update Race Stats Only Mode Stats.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Input
- Signature: `mob/proc/Input(mob/m,msg,title,default,_type,list/l)`
- Inputs: mob/m, msg, title, default, _type, list/l
- Purpose: Handle input.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Opponent_move_slower_if_you_are_chasing_them
- Signature: `mob/proc/Opponent_move_slower_if_you_are_chasing_them()`
- Inputs: None
- Purpose: Handle opponent move slower if you are chasing them.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Being_chased
- Signature: `mob/proc/Being_chased()`
- Inputs: None
- Purpose: Handle being chased.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/TickMult
- Signature: `proc/TickMult(n=1)`
- Inputs: n=1
- Purpose: Handle tick mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ToOne
- Signature: `proc/ToOne(delay = 1)`
- Inputs: delay = 1
- Purpose: Handle to one.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Get_bp_loss_from_low_ki
- Signature: `Get_bp_loss_from_low_ki()`
- Inputs: None
- Purpose: Return bp loss from low ki.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Get_bp_loss_from_low_hp
- Signature: `Get_bp_loss_from_low_hp()`
- Inputs: None
- Purpose: Return bp loss from low hp.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Set_flash_step_mob
- Signature: `Set_flash_step_mob(mob/m)`
- Inputs: mob/m
- Purpose: Set flash step mob.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Can_flash_step
- Signature: `Can_flash_step()`
- Inputs: None
- Purpose: Return whether flash step.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Get_flash_step_target
- Signature: `Get_flash_step_target(mob/m)`
- Inputs: mob/m
- Purpose: Return flash step target.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Is_valid_flash_step_target
- Signature: `Is_valid_flash_step_target(mob/m)`
- Inputs: mob/m
- Purpose: Return whether valid flash step target.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Manually_find_flash_step_target
- Signature: `Manually_find_flash_step_target()`
- Inputs: None
- Purpose: Handle manually find flash step target.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Get_flash_step_delay
- Signature: `Get_flash_step_delay()`
- Inputs: None
- Purpose: Return flash step delay.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Flash_Step
- Signature: `Flash_Step()`
- Inputs: None
- Purpose: Handle flash step.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/test_overlays
- Signature: `mob/Admin5/verb/test_overlays()`
- Inputs: None
- Purpose: Handle test overlays.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/ki_water
- Signature: `turf/proc/ki_water(d)`
- Inputs: d
- Purpose: Handle ki water.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/relative_kb_dist
- Signature: `mob/proc/relative_kb_dist(obj/Blast/b,kb_dist=1)`
- Inputs: obj/Blast/b, kb_dist=1
- Purpose: Handle relative kb dist.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Get_blast_homing_chance
- Signature: `mob/proc/Get_blast_homing_chance(mod = 1)`
- Inputs: mod = 1
- Purpose: Return blast homing chance.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### obj/beam_redirector /when beams are deflected this object is placed down at the spot where it was/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/the_loop
- Signature: `proc/the_loop()`
- Inputs: None
- Purpose: Handle the loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/Diagnose_Effect_Icons
- Signature: `Diagnose_Effect_Icons()`
- Inputs: None
- Purpose: Handle diagnose effect icons.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GetEffect
- Signature: `proc/GetEffect()`
- Inputs: None
- Purpose: Return Effect.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### obj/Effect/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_explosion
- Signature: `proc/Get_explosion()`
- Inputs: None
- Purpose: Return explosion.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/Explosion
- Signature: `proc/Explosion()`
- Inputs: None
- Purpose: Handle explosion.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Explosion/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Initialize_explosion_icons
- Signature: `proc/Initialize_explosion_icons()`
- Inputs: None
- Purpose: Initialize explosion icons.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Explosion_Graphics
- Signature: `proc/Explosion_Graphics(obj/O,Distance=1,not_used=0)`
- Inputs: obj/O, Distance=1, not_used=0
- Purpose: Handle explosion graphics.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Explosion_Count
- Signature: `proc/Explosion_Count(list/L)`
- Inputs: list/L
- Purpose: Handle explosion count.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/Make_Damaged_Ground
- Signature: `turf/proc/Make_Damaged_Ground(Amount=1) if(!Water)`
- Inputs: Amount=1
- Purpose: Handle make damaged ground.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/Remove_Damaged_Ground
- Signature: `turf/proc/Remove_Damaged_Ground(image/I)`
- Inputs: image/I
- Purpose: Remove Damaged Ground.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Shielding
- Signature: `mob/proc/Shielding()`
- Inputs: None
- Purpose: Handle shielding.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/check_lose_tail
- Signature: `mob/proc/check_lose_tail(dmg=0,obj/culprit)`
- Inputs: dmg=0, obj/culprit
- Purpose: Check lose tail.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_projectile_shockwave_size
- Signature: `proc/Get_projectile_shockwave_size(obj/Blast/b)`
- Inputs: obj/Blast/b
- Purpose: Return projectile shockwave size.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Apply_force_field_damage
- Signature: `mob/proc/Apply_force_field_damage(obj/items/Force_Field/FF,dmg=0)`
- Inputs: obj/items/Force_Field/FF, dmg=0
- Purpose: Apply force field damage.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Tens
- Signature: `proc/Tens(t)`
- Inputs: t
- Purpose: Handle tens.
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
- Signature: `proc/vector_step(mob/a, ang = 0, step_speed)`
- Inputs: mob/a, ang = 0, step_speed
- Purpose: Handle vector step.
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
