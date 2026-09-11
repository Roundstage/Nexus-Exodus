# Visual Effects

`GetEffect()`/`Effect.Del()` and `Get_explosion()`/`Explosion.Del()` advance the shared deferred-delete generation and deduplicate pool releases. Explosion animation checks its generation after waits. `reallyDelete` removes either visual from its pool and performs actual deletion. Floating-text ownership still uses its separate animation generation, so replacing text animation does not silently postpone an independent lifetime timer.

## Overview
Standalone visual effects such as rock debris, Harambe event visuals, rising rock animations, and the Alien Time Stop domain.

## Files
- `src/Code/VisualEffects/AppearanceBounds.dm`
- `src/Code/VisualEffects/BigRocks.dm`
- `src/Code/VisualEffects/EffectCache.dm`
- `src/Code/VisualEffects/ExplosionEffects.dm`
- `src/Code/VisualEffects/FlipAnimation.dm`
- `src/Code/VisualEffects/Harambe.dm`
- `src/Code/VisualEffects/KiWater.dm`
- `src/Code/VisualEffects/PlayerAppearanceManager.dm`
- `src/Code/VisualEffects/RisingRocks2019.dm`
- Time Stop domain helpers live beside the legacy Time Freeze type path in `src/Code/ProjectileSystem/Blasts.dm`, avoiding an additional Dream Maker include dependency.

## Proc Reference

### obj/Effect/proc/runFloatingText
- Signature: `runFloatingText(duration = 10)`
- Purpose: Move a floating text effect upward at four-tick intervals until its deadline.
- Side effects: starts a nonblocking task owned by the effect, increments a temporary generation, and returns the effect to the cache on expiry. `Del()` invalidates the generation before caching, preventing an old task from moving or deleting a reused instance. Non-finite durations use the ten-tick default; negative durations expire immediately.

### proc/showAlienInfiniteVoidDomain
- Signature: `showAlienInfiniteVoidDomain(atom/center, duration = 70)`
- Purpose: Layer two centered copies of the original cosmic domain asset, expanding, counter-rotating, glowing, and collapsing them over a fixed map origin for seven seconds.
- Side effects: creates two dedicated plane-20 visual actors above map lighting and permanently deletes them after the animation; it deliberately bypasses the heterogeneous generic effect cache.

### mob/proc/canHitAlienInfiniteVoidTarget
- Purpose: Accept only living, attackable targets on the caster's Z-level that also pass the shared Nexus RP Mode and Safezone protections.

### mob/proc/getAlienInfiniteVoidStunTicks
- Purpose: Scale stun from caster BP/Force against target BP/Resistance, use a six-second equal-stat base before global stun modifiers, clamp it to 30–120 ticks, and apply a 75% Time Normalizer reduction with a six-tick floor.

### mob/proc/applyAlienInfiniteVoidStun
- Signature: `applyAlienInfiniteVoidStun(turf/origin, radius = 8)`
- Purpose: Resolve the domain against visible mobs in its circular area, including NPCs and combat dummies, using the standard combat stun system rather than persistent `Frozen` state.

### mob/proc/showAlienInfiniteVoidHit
- Purpose: Mark each affected target with the legacy time-ring overlay and a short violet glow without changing its equipment appearance stack.

### datum/PlayerAppearanceManager

Managed equipment appearances carry an explicit copy of the character body matrix and opt out of inheriting it a second time. This keeps clothing, forged swords, masks and armor synchronized through Giant Form and Android Giant Version even on clients that detach item appearances from the parent transform. Character scaling changes only the linear matrix components, preserving any existing translation and pixel anchor.
- Purpose: Own player equipment overlay slots, source identity, stable priorities, and isolated rendered images.
- Behavior: removes legacy raw item icons plus orphaned rendered equipment images by icon state and pixel offset, derives equipped sources, sorts by priority/category/slot, rebuilds once, and re-adds injuries above equipment. Signature cleanup is what makes the manager safe after a relog or a transformation temporarily stores and restores the mob overlay list.

### mob/proc/rebuildPlayerAppearance(reason)
- Purpose: Reconstruct managed overlays after login, equipment changes, body swap, or primary transformation changes.
- Side effects: removes both current manager-owned images and visually matching stale equipment images, then replaces them with fresh per-player images. It deliberately leaves unrelated transient combat effects intact.

### mob/verb/manageVisualLayers
- Purpose: Let a player move an equipped visual between priority 300 (back) and 700 (front) without directly splicing `overlays`.

### mob/verb/viewVisualLayers
- Purpose: Display final managed slot order, source, priority, and managed/raw overlay counts.

### proc/StartupScatterBigRocks()
- Purpose: Scatter large rock objects across the world after startup.
- Side effects: spawns `/obj/Big_Rock/Big_Rock1` across eligible turfs.

### proc/RockExplode(turf/t)
- Purpose: Play a rock explosion effect and sound at a turf.
- Side effects: creates and deletes an effect object, plays sound.

### obj/Big_Rock/New()
- Purpose: Initialize a large rock and randomize size/orientation.
- Side effects: calls `RockInit()`.

### obj/Big_Rock/Del()
- Purpose: Explode and respawn the rock after a delay.
- Side effects: calls `RockExplode`, teleports out/in, sleeps.

### obj/Big_Rock/proc/RockInit()
- Purpose: Randomize size, bounds, and transforms for a rock.
- Side effects: sets transforms, pixel offsets, and bounds.

### obj/Big_Rock/proc/RockXScale()
- Purpose: Apply a random horizontal scale for variety.

### obj/Big_Rock/proc/GenerateRockBounds()
- Purpose: Compute collision bounds based on rock size.

### atom/proc/InvertX()
- Purpose: Flip the atom's transform horizontally.

### obj/Harambe_Statue/New()
- Purpose: Spawn a temporary statue and schedule its deletion.

### obj/Harambe_Statue/proc/DeleteHarambe()
- Purpose: Delete the statue after a short delay.

### obj/Harambe/New()
- Purpose: Start Harambe ambient behavior on spawn.

### obj/Harambe/proc/HarambeStart()
- Purpose: Kick off Harambe's looping scream audio.

### obj/Harambe/proc/HarambeScream()
- Purpose: Loop the scream sound while Harambe exists.

### mob/proc/HarambeDeath()
- Purpose: Orchestrate the Harambe encounter sequence on a mob.
- Side effects: spawns Harambe, runs a scripted sequence, plays audio.

### mob/proc/HarambeSpawn(obj/Harambe/h)
- Purpose: Position Harambe above the victim's location.

### mob/proc/HarambeDescend(obj/Harambe/h)
- Purpose: Move Harambe down to the victim and play dialog/emotes.

### mob/proc/HarambeGrabAndRunAround(obj/Harambe/h)
- Purpose: Attach the victim to Harambe and move around randomly.
- Side effects: teleports the mob to Harambe's location repeatedly.

### mob/proc/HarambeTakeHimOut(obj/Harambe/h)
- Purpose: Finalize the sequence with dialog, gunshot, and corpse spawn.

### mob/proc/HarambeOhShit(obj/Dead_Harambe/dh)
- Purpose: Play the "oh shit" sound after the Harambe event.

### mob/verb/CustomRisingRockIcon()
- Purpose: Allow players to set a custom icon for rising rock effects.

### mob/proc/PowerupRisingRocks(obj/Power_Control/p)
- Purpose: Loop rising rock FX while powering up (currently disabled).

### mob/proc/RisingRocksTransformFXNoWait(...)
- Purpose: Fire rising rock FX without blocking the caller.

### mob/proc/RisingRocksTransformFX(...)
- Purpose: Spawn rising rock sessions around the mob.

### mob/proc/PlayerRisingRocks(...)
- Purpose: Create individual rising rocks around the player.

### proc/RisingRock(turf/pos, minVel, maxVel, fadeTime, hoverTime, mob/user)
- Purpose: Animate a single rock rising/spinning/descending with shadow.
- Side effects: spawns effect objects, uses `animate`, deletes after fade.

### atom/movable/proc/SpinLoop(spin_speed = 360, duration = 10)
- Purpose: Continuously rotate an object for a duration.

### atom/movable/proc/SpinNoWait(times = 1, angle = 90, duration = 10)
- Purpose: Non-blocking wrapper around `Spin()`.

### atom/movable/proc/Spin(times = 1, angle = 90, duration = 10)
- Purpose: Stepwise rotation animation, intended for stationary objects.

### proc/showNexusOpenCombatEffect
- Signature: `showNexusOpenCombatEffect(atom/target, library_name, effect_state, effect_scale = 1, effect_color, effect_alpha = 255, effect_blend_mode = BLEND_ADD, hold_ticks = 7, growth = 0.2)`
- Purpose: Play one documented Open Combat DMI state on a centered pooled effect actor with optional tint, scale, growth and fade.
- Side effects: allocates an effect through `GetEffect()`, animates it, then deletes/returns it through the existing effect lifecycle.

### proc/getNexusBeamImpactState
- Purpose: Select one of the approved `PixelSimulations64.dmi` explosion states for a beam impact.

### Transformation hair selection

`TransformationHair.dm`: `getTransformationHair(key)` reads the current saved/custom hair fields; `getActiveTransformationHairKey()` preserves Ultra Instinct, Blue, God, Mystic, USSJ and Full Power priorities. `getActiveTransformationHair()` retains the mastered Goku SSJ3 exception. `SSj_Hair()` applies this result while retaining existing tail/eye handling. The `base` key returns the actual original colored hair and `ssj` returns the golden variant for cinematic previews without changing gameplay transformation state.

## SSJ1 Aseprite opening
`datum/NexusSsjAwakening.playSequence` in `SuperSaiyanTransformation.dm` owns temporary aura/light objects, base/gold hair flicker, gentle lift, observer ambient modifiers and a brief world-plane wave filter. `cleanup` is idempotent and releases lighting/filter state even when the actor disappears. Aseprite sources and build scripts live in `artifacts/SuperSaiyan/`; runtime assets are `GoldenAura.dmi` and `TransformationLightning.dmi`. No Pixel Composer dependency remains.

The opening now lasts 22 seconds minimum. Aura and the two crossfading hair visuals are attached through `vis_contents`, inheriting the actor's direction and position. `getNexusAwakeningAnchor` scans the selected body frame's opaque bounds once at sequence creation. The flame asset's feet anchor is (48,12) in bottom-left coordinates, and its growth matrix preserves that point. Twelve expanding ground rings, increasingly frequent 192-pixel falling lightning and world-plane distortion accompany the crescendo. Three per-observer reserved sound channels separate charge, shockwave and electric samples; cleanup or leaving range stops only those channels. The final 1.5 seconds settle the lift, glow and aura. Tests cover a deliberately asymmetric body and interruption after creating the attached visuals.

SSJ1 effects now use `getNexusSsjVisualMastery` (drain 150–300, or Full Power). `getNexusAwakeningDuration(mob)` interpolates from 220 to 6 deciseconds. The mastered path only crossfades hair; it does not acquire observer lighting/sound state or spawn disruptive effects. `updateNexusSsjDaylightGlow` maintains a persistent additive halo above the ambient plane, in addition to the existing light emitter. It shrinks with mastery and is removed on reversion. Ground pulses use the expanding elliptical ring owned by the awakening datum.

Lighting correction: temporary awakening dimmers call `refreshNexusAmbient`, which recomposes the last raw ambient value received by the client instead of resolving the area's day/night flag again. Area/weather updates still replace that raw value normally. Peak dimming is now 22%, scaled down with mastery. The daylight halo explicitly selects gradient state "1"; the previous empty state had no visible pixels. The expanding elliptical shockwave from the 22-second version is restored.

The visible SSJ halo now uses `GoldenGlow.png`, authored by `CreateGoldenGlow.lua` in Aseprite, with a radial alpha falloff and fully transparent borders. The opaque black-backed `NexusLightGradient.dmi` remains exclusive to lighting emitters/masks and is no longer reused as a visible world overlay. Regression tests inspect every border pixel of the actual runtime halo asset and verify a visible center.

Awakening dimming is now an independent black screen layer on plane 14, beneath Nexus lighting (15). `refreshNexusAwakeningDimmer` only updates that layer's alpha, capped at 22%; it does not read, write, reset or animate the lighting plane or ambient color. `refreshNexusAmbient` no longer applies awakening modifiers. Removing the temporary layer cannot restore a white ambient over the night. Overlapping cinematics use the strongest dimmer and release only their own token.
