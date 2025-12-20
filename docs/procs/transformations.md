# Transformations

## Overview
Kaioken ("God Fist") transformation logic, including drain, boosts, and gore effects.

## Files
- `src/Code/Transformations/Kaioken.dm`

## Proc Reference

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
- Side effects: resets `God_Fist_level` and `super_God_Fist`.

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
