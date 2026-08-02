# Projectile System

## Overview
Projectile movement, collision, beam segments, and damage behavior.

`obj/Blast/applyPiercingDamageDecay()` updates both the legacy flat damage and the active `percent_damage` factor. This is required for Kienzan-style piercing projectiles after central damage resolution moved away from `Damage`.

Every Beam skill receives a three-second per-skill cooldown when charging starts and whenever `BeamStop()` completes. Explosive beams retain a per-target factor budget, while Beam Lock deliberately has no cumulative damage ceiling and keeps ticking until the stream ends or the victim escapes. Beam clashes report the pressure ratio, place a lit impact marker at the collision turf, show each owner a directional mash prompt, grant a 1.15x pressure pulse for current correct input, and grant the winning beam a single 1.35x damage-factor bonus. `obj/Blast/strength_scaled` routes weapon-launched projectiles such as Sky Break and Echoing Slash through physical Strength-versus-Endurance resolution. Explosive beam impacts calculate a power-relative knockback before immediately tearing down the stream.

Configured projectile-impact art, color and audio are carried on `obj/Blast`, including cached and shrapnel projectiles. This gives physical cutting waves sword impacts without routing them through generic blast sounds, while explosive Ki techniques retain their own presentation. Named skill projectiles with a damage factor of at least 3 receive a shared RPT impact effect when they do not define specialized art; small barrage shots are intentionally excluded.

## Files
- `src/Code/ProjectileSystem/BeamCore.dm`
- `src/Code/ProjectileSystem/Beams.dm`
- `src/Code/ProjectileSystem/Blasts.dm`
- `src/Code/ProjectileSystem/ProjectileCore.dm`
- `src/Code/ProjectileSystem/Projectiles.dm`

## Proc Reference

### src/Code/ProjectileSystem/BeamCore.dm

#### obj/proc/beam_move_loop
- Signature: `obj/proc/beam_move_loop(mob/m)`
- Inputs: mob/m
- Purpose: Handle beam move loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/get_beam_size
- Signature: `mob/proc/get_beam_size()`
- Inputs: None
- Purpose: Return beam size.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/BeamSizeLoop
- Signature: `mob/proc/BeamSizeLoop(obj/Attacks/a)`
- Inputs: obj/Attacks/a
- Purpose: Handle beam size loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BeamStream
- Signature: `mob/proc/BeamStream(obj/Attacks/A)`
- Inputs: obj/Attacks/A
- Purpose: Begin beam streaming and intensify the caster's attack-colored action glow.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BeamStreamLoop
- Signature: `mob/proc/BeamStreamLoop(obj/Attacks/A)`
- Inputs: obj/Attacks/A
- Purpose: Generate and advance the continuous beam body. Every energy segment receives a compact, low-intensity emitter, producing a light trail that follows the complete beam without giving each tile a blast-sized halo.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BeamCharge
- Signature: `mob/proc/BeamCharge(obj/Attacks/A)`
- Inputs: obj/Attacks/A
- Purpose: Begin charging a beam and attach an independent attack-colored glow without replacing transformation light.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BeamStop
- Signature: `mob/proc/BeamStop(obj/Attacks/A, immediate = 0, obj/Blast/impact_segment)`
- Inputs: beam skill, immediate teardown flag, and optional contacting segment.
- Purpose: Stop beam state; raw player impacts use immediate teardown instead of the legacy delayed tail animation.
- Returns: none (implicit).
- Side effects: clears charging, streaming, beam segments, and the temporary beam glow.

#### mob/proc/deleteBeamSegmentsImmediately
- Signature: `mob/proc/deleteBeamSegmentsImmediately(obj/Attacks/A, obj/Blast/impact_segment)`
- Inputs: beam skill and contacting segment, which is deleted by the collision handler.
- Purpose: Clear owner and attack segment lists and remove every trailing segment from the map in the same tick.
- Returns: none (implicit).
- Side effects: cancels segment damage loops and schedules every remaining segment for deletion.

#### mob/proc/BeamStopThing2
- Signature: `mob/proc/BeamStopThing2()`
- Inputs: None
- Purpose: Handle beam stop thing2.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Beam_Macro
- Signature: `mob/proc/Beam_Macro(obj/Attacks/O)`
- Inputs: obj/Attacks/O
- Purpose: Handle beam macro.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Attacks/proc/calculate_beam_drain
- Signature: `obj/Attacks/proc/calculate_beam_drain()`
- Inputs: None
- Purpose: Calculate beam drain.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### obj/Attacks/proc/calculate_beam_drain
- Signature: `obj/Attacks/proc/calculate_beam_drain()`
- Inputs: None
- Purpose: Calculate beam drain.
- Returns: computed value (see implementation).
- Side effects: none expected.

### src/Code/ProjectileSystem/Beams.dm

#### mob/verb/kiSettings
- Signature: `mob/verb/kiSettings()`
- Inputs: None.
- Purpose: Configure the player's global beam behavior and Rock Throw mode when that skill is owned.
- Returns: none (implicit).
- Side effects: persists `Raw Damage` or `Beam Lock` on the player; Raw Damage is the default.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Noob_Ray
- Signature: `verb/Noob_Ray()`
- Inputs: None
- Purpose: Handle noob ray.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Zanzoken_Mastery
- Signature: `mob/proc/Zanzoken_Mastery(N=0.1)`
- Inputs: N=0.1
- Purpose: Handle zanzoken mastery.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/proc/Skill_Increase
- Signature: `obj/proc/Skill_Increase(Amount=1,mob/P)`
- Inputs: Amount=1, mob/P
- Purpose: Handle skill increase.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Laser
- Signature: `verb/Laser()`
- Inputs: None
- Purpose: Handle laser.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Beam
- Signature: `verb/Beam()`
- Inputs: None
- Purpose: Handle beam.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/DeathBeam
- Signature: `verb/DeathBeam()`
- Inputs: None
- Purpose: Handle death beam.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Makankosappo
- Signature: `verb/Makankosappo()`
- Inputs: None
- Purpose: Handle makankosappo.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Kamehameha
- Signature: `verb/Kamehameha()`
- Inputs: None
- Purpose: Handle kamehameha.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Dodompa
- Signature: `verb/Dodompa()`
- Inputs: None
- Purpose: Handle dodompa.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Final_Flash
- Signature: `verb/Final_Flash()`
- Inputs: None
- Purpose: Handle final flash.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Galic_Gun
- Signature: `verb/Galic_Gun()`
- Inputs: None
- Purpose: Handle galic gun.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Masenko
- Signature: `verb/Masenko()`
- Inputs: None
- Purpose: Handle masenko.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Attacks/proc/BeamDescription
- Signature: `obj/Attacks/proc/BeamDescription()`
- Inputs: None
- Purpose: Handle beam description.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/ProjectileSystem/Blasts.dm

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Buster_Barrage
- Signature: `verb/Buster_Barrage()`
- Inputs: None
- Purpose: Handle buster barrage.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Buster_Barrage
- Signature: `mob/proc/Buster_Barrage(obj/Attacks/Buster_Barrage/B)`
- Inputs: obj/Attacks/Buster_Barrage/B
- Purpose: Fire the green energy barrage with compact per-shot lighting and a temporary green firing aura.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/proc/Buster_Barrage_Move
- Signature: `obj/proc/Buster_Barrage_Move()`
- Inputs: None
- Purpose: Handle buster barrage move.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Attack_Barrier
- Signature: `verb/Attack_Barrier()`
- Inputs: None
- Purpose: Handle attack barrier.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blast/proc/attack_barrier_loop
- Signature: `obj/Blast/proc/attack_barrier_loop()`
- Inputs: None
- Purpose: Handle attack barrier loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MaxAttackBarrierBlasts
- Signature: `mob/proc/MaxAttackBarrierBlasts()`
- Inputs: None
- Purpose: Handle max attack barrier blasts.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/UsingAttackBarrier
- Signature: `mob/proc/UsingAttackBarrier()`
- Inputs: None
- Purpose: Handle using attack barrier.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Attack_Barrier
- Signature: `mob/proc/Attack_Barrier(obj/Attacks/Attack_Barrier/B)`
- Inputs: obj/Attacks/Attack_Barrier/B
- Purpose: Handle attack barrier.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Ki_Toggle
- Signature: `mob/verb/Ki_Toggle()`
- Inputs: None
- Purpose: Handle ki toggle.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/proc/AssignIconSize
- Signature: `obj/proc/AssignIconSize()`
- Inputs: None
- Purpose: Handle assign icon size.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blasts/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Aura_Choices/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Charges/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Attacks/Blast/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Blast_Options
- Signature: `verb/Blast_Options()`
- Inputs: None
- Purpose: Handle blast options.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Recalculate_blast_drain
- Signature: `proc/Recalculate_blast_drain()`
- Inputs: None
- Purpose: Handle recalculate blast drain.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Blast
- Signature: `verb/Blast()`
- Inputs: None
- Purpose: Handle blast.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Blast_macro
- Signature: `mob/verb/Blast_macro()`
- Inputs: None
- Purpose: Handle blast macro.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/blast_fire_loop
- Signature: `mob/proc/blast_fire_loop()`
- Inputs: None
- Purpose: Handle blast fire loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/get_blast_refire
- Signature: `mob/proc/get_blast_refire()`
- Inputs: None
- Purpose: Return blast refire.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/get_shuriken_refire
- Signature: `mob/proc/get_shuriken_refire()`
- Inputs: None
- Purpose: Return shuriken refire.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Blast_Fire
- Signature: `mob/proc/Blast_Fire(obj/Attacks/Blast/B)`
- Inputs: obj/Attacks/Blast/B
- Purpose: Handle blast fire.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blast/proc/BlastAutoTargetGo
- Signature: `obj/Blast/proc/BlastAutoTargetGo(boundWidth = 32, boundHeight = 32, vectorSpeed = 44, angleLimit = 18, dist = 47, randomAngle = 0)`
- Inputs: projectile bounds, speed, selected-target cone, distance, and random angle.
- Purpose: Aim once at the owner's selected target when valid, otherwise fire straight.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blast/proc/stopProjectileFlight
- Signature: `obj/Blast/proc/stopProjectileFlight()`
- Inputs: None.
- Purpose: Cancel engine walking and invalidate any custom flight loop for a cached blast.
- Returns: none (implicit).
- Side effects: advances the flight generation and stops `walk()`.

#### obj/Blast/proc/startKiProjectileWalk
- Signature: `obj/Blast/proc/startKiProjectileWalk(move_dir, delay_override = 0)`
- Inputs: direction and optional cadence.
- Purpose: Move non-beam Ki projectiles at their vector speed every 0.5 deciseconds while preserving legacy movement for beams, bullets, and non-Ki projectiles.
- Returns: none (asynchronous).
- Side effects: replaces the active projectile flight loop.

#### obj/Blast/proc/BlastVectorWalk
- Signature: `obj/Blast/proc/BlastVectorWalk(angle = 0)`
- Inputs: angle = 0
- Purpose: Move a straight Ki projectile at its vector speed every 0.5 deciseconds.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blast/proc/followSelectedTarget
- Signature: `obj/Blast/proc/followSelectedTarget(mob/target)`
- Inputs: explicitly selected target captured at fire time.
- Purpose: Home at the projectile's vector speed and 0.5-decisecond cadence while that same target remains selected; never acquire a replacement.
- Returns: none (asynchronous).
- Side effects: moves and may bump the blast.

#### obj/Blast/proc/Blast_Move
- Signature: `obj/Blast/proc/Blast_Move(obj/Attacks/Blast/b,mob/m, skip_first_delay)`
- Inputs: obj/Attacks/Blast/b, mob/m, skip_first_delay
- Purpose: Handle blast move.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Disabled
- Signature: `mob/proc/Disabled()`
- Inputs: None
- Purpose: Handle disabled.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Big_Bang
- Signature: `verb/Big_Bang()`
- Inputs: None
- Purpose: Handle big bang.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Charge
- Signature: `verb/Charge()`
- Inputs: None
- Purpose: Handle charge.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blast/proc/blast_walk
- Signature: `obj/Blast/proc/blast_walk(delay=ki_projectile_step_delay,start_dir)`
- Inputs: optional cadence and starting direction.
- Purpose: Route straight blast movement through the normalized Ki projectile flight loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Attacks/New
- Signature: `obj/Attacks/New()`
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

#### verb/CyberCharge
- Signature: `verb/CyberCharge()`
- Inputs: None
- Purpose: Handle cyber charge.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Kienzan
- Signature: `verb/Kienzan()`
- Inputs: None
- Purpose: Handle kienzan.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/SpinBlast
- Signature: `verb/SpinBlast()`
- Inputs: None
- Purpose: Handle spin blast.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Makosen
- Signature: `verb/Makosen()`
- Inputs: None
- Purpose: Handle makosen.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Time_Freeze_Energy/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/TF_Delete
- Signature: `proc/TF_Delete()`
- Inputs: None
- Purpose: Handle tf delete.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Fill_Active_Freezes_List
- Signature: `mob/proc/Fill_Active_Freezes_List()`
- Inputs: None
- Purpose: Handle fill active freezes list.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Time_Freeze
- Signature: `verb/Time_Freeze()`
- Inputs: None
- Purpose: Handle time freeze.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Attacks/Explosion/New
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

#### verb/Explosion_Toggle
- Signature: `verb/Explosion_Toggle()`
- Inputs: None
- Purpose: Handle explosion toggle.
- Returns: none (implicit).
- Side effects: see implementation.

#### *mob/proc/TryScatterShot
- Signature: `TryScatterShot(obj/Attacks/Scatter_Shot/s)`
- Inputs: obj/Attacks/Scatter_Shot/s
- Purpose: Handle try scatter shot.
- Returns: none (implicit).
- Side effects: see implementation.

#### *mob/proc/CanScatterShot
- Signature: `CanScatterShot(obj/Attacks/Scatter_Shot/s)`
- Inputs: obj/Attacks/Scatter_Shot/s
- Purpose: Return whether Scatter Shot.
- Returns: boolean flag.
- Side effects: none expected.

#### *mob/proc/StopScatterShotting
- Signature: `StopScatterShotting(obj/Attacks/Scatter_Shot/s)`
- Inputs: obj/Attacks/Scatter_Shot/s
- Purpose: Stop Scatter Shotting.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### *mob/proc/ScatterShotInterrupted
- Signature: `ScatterShotInterrupted(obj/Attacks/Scatter_Shot/s, ignore_low_ki)`
- Inputs: obj/Attacks/Scatter_Shot/s, ignore_low_ki
- Purpose: Handle scatter shot interrupted.
- Returns: none (implicit).
- Side effects: see implementation.

#### *mob/proc/ScatterShot
- Signature: `ScatterShot(obj/Attacks/Scatter_Shot/s)`
- Inputs: obj/Attacks/Scatter_Shot/s
- Purpose: Handle scatter shot.
- Returns: none (implicit).
- Side effects: see implementation.

#### *mob/proc/FireScatterShotsLoop
- Signature: `FireScatterShotsLoop(obj/Attacks/Scatter_Shot/s)`
- Inputs: obj/Attacks/Scatter_Shot/s
- Purpose: Handle fire scatter shots loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### *mob/proc/NewScatterShotBlast
- Signature: `NewScatterShotBlast(mob/m, obj/Attacks/Scatter_Shot/s)`
- Inputs: mob/m, obj/Attacks/Scatter_Shot/s
- Purpose: Handle new scatter shot blast.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blast/proc/ScatterShotGoTo
- Signature: `ScatterShotGoTo(turf/t)`
- Inputs: turf/t
- Purpose: Handle scatter shot go to.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blast/proc/ScatterShotInterruptedFlyOff
- Signature: `ScatterShotInterruptedFlyOff()`
- Inputs: None
- Purpose: Handle scatter shot interrupted fly off.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blast/proc/ScatterShotAttackTarget
- Signature: `ScatterShotAttackTarget()`
- Inputs: None
- Purpose: Handle scatter shot attack target.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Attacks/Scatter_Shot/New
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

#### verb/Scatter_Shot
- Signature: `verb/Scatter_Shot()`
- Inputs: None
- Purpose: Handle scatter shot.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Sokidan
- Signature: `verb/Sokidan()`
- Inputs: None
- Purpose: Handle sokidan.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Genocide
- Signature: `verb/Genocide()`
- Inputs: None
- Purpose: Charge and fire the guided Genocide volley, including a temporary charge light and compact automatic lights on its projectiles.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Small_crater
- Signature: `proc/Small_crater(turf/t)`
- Inputs: turf/t
- Purpose: Handle small crater.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Crater/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Crater/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Crater/proc/SmallCraterDel
- Signature: `SmallCraterDel()`
- Inputs: None
- Purpose: Handle small crater del.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/BigCrater
- Signature: `proc/BigCrater(turf/pos, maxSize, growTime, fadeTime, minRangeFromOtherCraters)`
- Inputs: turf/pos, maxSize, growTime, fadeTime, minRangeFromOtherCraters
- Purpose: Handle big crater.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/BigCrater/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/BigCrater/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/BigCrater/proc/CraterNew
- Signature: `CraterNew()`
- Inputs: None
- Purpose: Handle crater new.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/BigCrater/proc/CraterDeleteTimer
- Signature: `CraterDeleteTimer()`
- Inputs: None
- Purpose: Handle crater delete timer.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/BigCrater/proc/BigCraterDel
- Signature: `BigCraterDel()`
- Inputs: None
- Purpose: Handle big crater del.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Shockwave
- Signature: `verb/Shockwave()`
- Inputs: None
- Purpose: Handle shockwave.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/ProjectileSystem/ProjectileCore.dm

#### obj/Ability/proc/SetCooldown
- Signature: `SetCooldown(mob/m)`
- Inputs: mob/m
- Purpose: Set Cooldown.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### obj/Ability/Blast/TestBlast/verb/Hotbar_use
- Signature: `Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Ability/Blast/TestBlast/verb/TestBlast
- Signature: `TestBlast()`
- Inputs: None
- Purpose: Home the test projectile only toward the explicitly selected target.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/ProjectileSystem/Projectiles.dm

#### obj/Blast/proc/getNexusCombatAttackName
- Signature: `getNexusCombatAttackName()`
- Purpose: Resolve a projectile's player-facing combat-log label from `from_attack`, with beam, bullet, explosive, and generic Ki fallbacks.

Projectile Health, natural shield, cyber force-field, explosion, beam, and bleeding hit paths pass their owner and resolved attack name into the centralized combat log.

#### obj/Blast/proc/applyPiercingDamageDecay
- Signature: `obj/Blast/proc/applyPiercingDamageDecay()`
- Inputs: None.
- Purpose: Decay legacy piercing damage and Kienzan's active central damage factor after a successful hit.
- Returns: none (implicit).
- Side effects: mutates projectile damage for its next collision.

#### obj/Blast/proc/setStats
- Signature: `obj/Blast/proc/setStats(mob/P, Percent=1, Off_Mult=1, Explosion=0, bullet=0, homing_mod = 1, explosion_percent = 0, max_damage_factor = 0, owner_immunity = 0, datum/CombatDamageBudget/shared_budget)`
- Inputs: owner snapshot, direct factor, accuracy, radius, projectile type, homing, independent splash factor, optional budget, owner immunity, and optional shared budget.
- Purpose: Snapshot projectile combat stats while keeping direct damage, splash damage, cast budget and owner collision behavior independent, then queue automatic visual-light profiling after the caller assigns its attack and sprite.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### obj/Blast/proc/queueNexusProjectileGlowUpdate
- Signature: `queueNexusProjectileGlowUpdate()`
- Purpose: Defer light profiling by one tick so legacy callers can finish assigning `from_attack`, `icon`, beam state, and location. A monotonic serial prevents an old cached-projectile callback from modifying a reused blast.
- Returns: none (implicit).
- Side effects: schedules `updateNexusProjectileGlow()`.

#### proc/fill_cached_blasts
- Signature: `proc/fill_cached_blasts()`
- Inputs: None
- Purpose: Handle fill cached blasts.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/get_cached_blast
- Signature: `proc/get_cached_blast()`
- Inputs: None
- Purpose: Return cached blast.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### obj/Blast/proc/cache_blast
- Signature: `obj/Blast/proc/cache_blast()`
- Inputs: None
- Purpose: Handle cache blast.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blast/Del
- Signature: `obj/Blast/Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blast/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Update_transform_size
- Signature: `proc/Update_transform_size(new_size=1)`
- Inputs: new_size=1
- Purpose: Update transform size.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Shrapnel
- Signature: `proc/Shrapnel() if(Shrapnel)`
- Inputs: None
- Purpose: Handle shrapnel.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blast/Move
- Signature: `Move()`
- Inputs: None
- Purpose: Handle move.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/CheckBlastHomingTarget
- Signature: `proc/CheckBlastHomingTarget()`
- Inputs: None
- Purpose: Retain the existing homing target only while it remains the owner's current selection and geometrically viable; never reacquire.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Is_viable_homing_target
- Signature: `proc/Is_viable_homing_target(mob/m)`
- Inputs: mob/m
- Purpose: Return whether viable homing target.
- Returns: boolean flag.
- Side effects: none expected.

#### proc/Blast_Homing
- Signature: `proc/Blast_Homing()`
- Inputs: None
- Purpose: Handle blast homing.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Beam_Appearance
- Signature: `proc/Beam_Appearance()`
- Inputs: None
- Purpose: Handle beam appearance.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Update_diagonal_overlays
- Signature: `proc/Update_diagonal_overlays()`
- Inputs: None
- Purpose: Update diagonal overlays.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/reserveDamageFactor
- Signature: `proc/reserveDamageFactor(mob/target, requested_factor)`
- Inputs: target and event factor.
- Purpose: Reserve factor from the projectile's shared per-target cast budget.
- Returns: available factor.
- Side effects: updates the shared budget.

#### proc/getProjectileCombatDamage
- Signature: `proc/getProjectileCombatDamage(mob/target, factor)`
- Inputs: target and reserved factor.
- Purpose: Apply physical scaling for bullets or Ki scaling for energy projectiles.
- Returns: percentage damage.
- Side effects: none.

#### proc/Shield
- Signature: `proc/Shield(mob/A, requested_factor)`
- Inputs: target and direct/splash factor.
- Purpose: Apply the centralized damage curve and cast budget to item, cybernetic and natural shields.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GetSuckedIntoBeam
- Signature: `proc/GetSuckedIntoBeam(mob/m)`
- Inputs: mob/m
- Purpose: Return Sucked Into Beam.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### obj/Blast/proc/showExplosiveBeamImpact
- Signature: `showExplosiveBeamImpact(atom/impact_target, force_mob_impact = 0)`
- Inputs: contacted atom and optional player-impact override.
- Purpose: Produce a violent raw-damage explosion and immediately stop a streaming beam after player contact.
- Returns: 1 when explosive mode consumed the beam segment, otherwise 0.
- Side effects: creates size-4 explosion graphics and strong transient light, a 256px shockwave, power-relative target knockback, screen shake and sound; calls `BeamStop()` for streaming attacks and deletes the contacting segment.

#### obj/Blast/proc/getExplosiveBeamKnockbackDistance
- Signature: `getExplosiveBeamKnockbackDistance(mob/impact_mob)`
- Inputs: optional directly contacted mob.
- Purpose: Scale explosive-beam knockback from the beam's damage factor, then apply the normal attacker/defender relative-power adjustment and safety clamps.
- Returns: integer knockback distance from 3 to 15 tiles.
- Side effects: none.

#### obj/Blast/proc/showConfiguredProjectileImpact
- Signature: `showConfiguredProjectileImpact(atom/impact_target)`
- Inputs: mob, object or turf contacted by a projectile.
- Purpose: Render an attack-configured impact DMI, colored light pulse and sound before collision teardown.
- Returns: none (asynchronous).
- Side effects: creates and removes one cached visual effect and broadcasts the configured local sound.

#### obj/Blast/proc/getNexusProjectileImpactIcon
- Signature: `getNexusProjectileImpactIcon()`
- Purpose: Prefer attack-specific impact art, otherwise select the shared RPT impact for named projectiles at or above the anti-spam damage threshold.
- Returns: icon resource or null.
- Side effects: none.

#### obj/Blast/proc/getBeamDamageWindow
- Signature: `getBeamDamageWindow(loop_delay)`
- Inputs: normal streaming tick duration.
- Purpose: Use `beam_raw_damage_mod` for one-hit Raw Damage or preserve the tick duration for Beam Lock.
- Returns: damage time scale.
- Side effects: none.

#### proc/Beam
- Signature: `proc/Beam()`
- Inputs: None
- Purpose: Apply immediate raw impact or sustained lock damage and resolve projectile clashes.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Explode
- Signature: `proc/Explode()`
- Inputs: None
- Purpose: Apply the independent explosion factor through the central damage formula and shared per-target budget.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/BlastCross
- Signature: `proc/BlastCross(mob/m, override_dir, override_delete)`
- Inputs: mob/m, override_dir, override_delete
- Purpose: Handle blast cross.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/BlastMobCross
- Signature: `proc/BlastMobCross(mob/m, override_dir, override_delete)`
- Inputs: mob/m, override_dir, override_delete
- Purpose: Resolve accuracy/deflection, preserve explicit owner immunity, reserve direct factor and apply centralized physical or Ki damage.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blast/Bump
- Signature: `Bump(mob/A,override_dir,override_delete)`
- Inputs: mob/A, override_dir, override_delete
- Purpose: Handle bump.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blast/proc/Bounce_Dir
- Signature: `Bounce_Dir()`
- Inputs: None
- Purpose: Handle bounce dir.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/proc/Shockwave_Knockback
- Signature: `obj/proc/Shockwave_Knockback(Amount,turf/A)`
- Inputs: Amount, turf/A
- Purpose: Handle shockwave knockback.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Shockwave_Knockback
- Signature: `mob/proc/Shockwave_Knockback(Amount,turf/A, bypass_immunity)`
- Inputs: Amount, turf/A, bypass_immunity
- Purpose: Handle shockwave knockback.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/BeamStruggleWinning
- Signature: `BeamStruggleWinning(obj/Blast/a, obj/Blast/b)`
- Inputs: obj/Blast/a, obj/Blast/b
- Purpose: Handle beam struggle winning.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blast/proc/BeamStrugglePower
- Signature: `obj/Blast/proc/BeamStrugglePower()`
- Inputs: None
- Purpose: Handle beam struggle power.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/ProjectileSystem/TenkaichiBeams.dm

#### obj/Attacks/RoleplayBeam/proc/useRoleplayBeam
- Signature: `useRoleplayBeam(mob/user)`
- Inputs: beam user.
- Purpose: Route the four missing Roleplay Tenkaichi beam families through `SkillEngine.castSkill()` and the native beam lifecycle.
- Returns: none (implicit).
- Side effects: starts, streams or stops Double Sunday, Photon Flash, Tyrant Lancer or Buster Cannon.
