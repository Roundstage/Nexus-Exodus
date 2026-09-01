# Clickinz

Clicking the exact planetary governor while adjacent now checks the planetary-control conquest path before ordinary KO looting. The server revalidates KO, zero Willpower, holder identity, region, distance, League membership, and ownership revision after all prompts; logged-out KO bodies remain eligible during their normal world-body window.

## Overview
Auto-generated first-pass proc summaries based on signature names. Refine descriptions during refactors.

## Files
- `src/Code/Clickinz.dm`

## Proc Reference

### src/Code/Clickinz.dm

#### mob/proc/DisplayItemCost
- Signature: `mob/proc/DisplayItemCost(obj/o)`
- Inputs: obj/o
- Purpose: Handle display item cost.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/DblClick
- Signature: `client/DblClick(obj/A)`
- Inputs: obj/A
- Purpose: Handle dbl click.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/Click
- Signature: `client/Click(obj/A, location, control, params)`
- Inputs: obj/A, location, control, params
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Zanzoken_Drain
- Signature: `mob/proc/Zanzoken_Drain(N=1)`
- Inputs: N=1
- Purpose: Handle zanzoken drain.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/After_Image/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/After_Image/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/AfterImage
- Signature: `mob/proc/AfterImage(T = 65, Pixel = 0, turf/loc_override)`
- Inputs: T = 65, Pixel = 0, turf/loc_override
- Purpose: Handle after image.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Charging_or_Streaming
- Signature: `mob/proc/Charging_or_Streaming()`
- Inputs: None
- Purpose: Handle charging or streaming.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Click
- Signature: `turf/Click(turf/T) if(isturf(T))`
- Inputs: turf/T
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Click
- Signature: `mob/Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.
