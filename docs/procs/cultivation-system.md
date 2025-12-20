# Cultivation System

## Overview
Auto-generated first-pass proc summaries based on signature names. Refine descriptions during refactors.

## Files
- `src/Code/Cultivation System/Cultivation.dm`

## Proc Reference

### src/Code/Cultivation System/Cultivation.dm

#### mob/proc/is_cultivator
- Signature: `is_cultivator(mob/player)`
- Inputs: mob/player
- Purpose: Return whether cultivator.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/cultivate
- Signature: `cultivate(mob/player)`
- Inputs: mob/player
- Purpose: Handle cultivate.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/select_cultivation_technique
- Signature: `select_cultivation_technique(mob/player)`
- Inputs: mob/player
- Purpose: Handle select cultivation technique.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stat_Cultivation
- Signature: `Stat_Cultivation()`
- Inputs: None
- Purpose: Handle stat cultivation.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/cultivate_from_meditation
- Signature: `cultivate_from_meditation(mob/player)`
- Inputs: mob/player
- Purpose: Handle cultivate from meditation.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/breakthrough
- Signature: `breakthrough(mob/player, reason)`
- Inputs: mob/player, reason
- Purpose: Handle breakthrough.
- Returns: none (implicit).
- Side effects: see implementation.

#### CultivationRealm/New
- Signature: `New(name, desc = "", stages)`
- Inputs: name, desc = "", stages
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### CultivationStage/New
- Signature: `New(name = "Stage", level = 1, progress = 0, bottleneck = 100)`
- Inputs: name = "Stage", level = 1, progress = 0, bottleneck = 100
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/TurnIntoACultivator
- Signature: `mob/Admin4/verb/TurnIntoACultivator(mob/player in players)`
- Inputs: mob/player in players
- Purpose: Handle turn into acultivator.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin4/verb/RemoveCultivation
- Signature: `mob/Admin4/verb/RemoveCultivation(mob/player in players)`
- Inputs: mob/player in players
- Purpose: Remove Cultivation.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/Admin4/verb/GiveCultivationTechnique
- Signature: `mob/Admin4/verb/GiveCultivationTechnique(mob/player in players)`
- Inputs: mob/player in players
- Purpose: Handle give cultivation technique.
- Returns: none (implicit).
- Side effects: see implementation.
