# Transformations

## Overview
Primary transformation registry/controller plus Kaioken ("God Fist") drain and boost logic. A mob may have one primary transformation; Third Eye, Mystic, Fire Fist, Saiyan Power, Majin, Kaioken, and Limit Breaker remain explicit secondary/burst categories.

## Files
- `src/Code/Transformations/Kaioken.dm`
- `src/Code/Transformations/TransformationSystem.dm`

## Proc Reference

### proc/initializeNexusTransformationRegistry()
- Purpose: Register stable IDs, labels, families, and stages for Saiyan, divine Saiyan, Frost, Giant, Oozaru, Alien, and Ultra Instinct primaries.

### mob/proc/detectPrimaryTransformation()
- Purpose: Convert current legacy flags (`ssj`, `Form`, God forms, Giant, Oozaru, transformation buff) into one stable active ID.

### mob/proc/preparePrimaryTransformation(transformation_id)
- Purpose: Revert an incompatible current primary before a legacy activation proc applies the requested form.

### mob/proc/requestPrimaryTransformation(transformation_id)
- Purpose: Validate and directly transition to an unlocked form. SSJ2/SSJ3 and Frost stages can be selected directly instead of always climbing or dropping to base manually.

### mob/proc/revertPrimaryTransformations(reason)
- Purpose: Remove all primary-form families while preserving separately categorized buffs.

### mob/proc/normalizePrimaryTransformation()
- Purpose: Reconstruct canonical state on login and clean legacy saves containing simultaneous primaries.

### mob/proc/updateTransformationGlow()
- Purpose: Map the active canonical transformation to a persistent colored light emitter and remove it on reversion. Saiyan, divine, Frost, Giant, Great Ape, Alien, and Ultra Instinct families have distinct profiles.

### mob/verb/transform and mob/verb/revertTransformation
- Purpose: Player-facing verbs for direct form selection and full primary reversion.

### mob/proc/God_Fist_loop()
- Purpose: Apply periodic Kaioken drains and boost growth while active.
- Side effects: modifies `God_Fist_boost`, `Health`, `Ki`, aura overlays; can kill the mob.

### mob/proc/God_Fist_bp()
- Purpose: Compute extra BP contributed by Kaioken.
- Returns: BP bonus scaled by boost, base BP, and modifiers.

### mob/proc/God_Fist_mult()
- Purpose: Compute the Kaioken multiplier for BP.
- Returns: multiplier based on `God_Fist_bp()` or `super_God_Fist_mult`.

### mob/proc/God_FistStop()
- Purpose: Disable Kaioken and clear aura overlays.
- Side effects: resets `God_Fist_level` and `super_God_Fist`, then restores the primary transformation's glow if one remains.

### obj/God_Fist/New()
- Purpose: Cache the Kaioken object on the owning mob after creation.

### obj/God_Fist/verb/Hotbar_use()
- Purpose: Hotbar wrapper for `God_Fist_Toggle()`.

### obj/God_Fist/verb/God_Fist_Toggle()
- Purpose: Toggle Kaioken on/off with safety checks (UI, forms, limit breaker).
- Side effects: calls `mob/God_Fist` or `mob/God_Fist_Revert`.

### mob/proc/God_Fist(obj/God_Fist/K)
- Purpose: Enable Kaioken usage and prompt the user.
- Side effects: sets `K.Using`.

### mob/proc/God_Fist_Revert(obj/God_Fist/K)
- Purpose: Disable Kaioken and clear `K.Using`.
- Side effects: calls `God_FistStop()`.

### mob/proc/Body_Parts(Amount = 5, Range = 1)
- Purpose: Spawn a number of gore chunks around the mob.
- Inputs: `Amount` (count), `Range` (view radius).

### proc/get_body_part(turf/t)
- Purpose: Fetch or spawn a pooled `obj/Body_Part` and place it on a turf.
- Side effects: uses `body_part_cache`, schedules deletion.

### obj/Body_Part/New()
- Purpose: Randomize pixel offsets and orientation for gore chunks.

### obj/Body_Part/Del()
- Purpose: Return the chunk to a cache and clear its location.
