# Visual Effects

## Overview
Standalone visual effects such as rock debris, Harambe event visuals, and rising rock animations.

## Files
- `src/Code/VisualEffects/Big Rocks.dm`
- `src/Code/VisualEffects/Harambe.dm`
- `src/Code/VisualEffects/PlayerAppearanceManager.dm`
- `src/Code/VisualEffects/rising rocks 2019.dm`

## Proc Reference

### datum/PlayerAppearanceManager
- Purpose: Own player equipment overlay slots, source identity, stable priorities, and isolated rendered images.
- Behavior: removes legacy item-icon entries, derives equipped sources, sorts by priority/category/slot, rebuilds once, and re-adds injuries above equipment.

### mob/proc/rebuildPlayerAppearance(reason)
- Purpose: Reconstruct managed overlays after login, equipment changes, body swap, or primary transformation changes.
- Side effects: removes prior manager-owned images and replaces them with fresh per-player images.

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
