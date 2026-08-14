# Visual Effects

## Overview
Standalone visual effects such as rock debris, Harambe event visuals, rising rock animations, and the Alien Time Stop domain.

## Files
- `src/Code/VisualEffects/Big Rocks.dm`
- `src/Code/VisualEffects/Harambe.dm`
- `src/Code/VisualEffects/PlayerAppearanceManager.dm`
- `src/Code/VisualEffects/rising rocks 2019.dm`
- Time Stop domain helpers live beside the legacy Time Freeze type path in `src/Code/ProjectileSystem/Blasts.dm`, avoiding an additional Dream Maker include dependency.

## Proc Reference

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
