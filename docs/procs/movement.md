# Movement

## Overview
Movement input, collision, environmental traversal, accelerated skill travel, and short-range warp behavior. `CanInputMove()` treats RP Mode as an absolute player movement lock. Instant Transmission now has a directional eight-tile warp path that reuses Zanzoken placement and visuals while consuming Energy rather than Stamina. Normal client movement uses allocation-free acceleration and velocity components: normalized input adds acceleration, velocity supplies arbitrary-angle pixel displacement, collision removes only blocked components, and duration-scaled retention is applied after movement. A fixed 60 Hz physics accumulator keeps ramp and coast behavior stable if the server FPS changes. Releasing input therefore preserves a short amount of carry while a velocity-unit cutoff settles each residual component; hard locks, forced movement, teleports, login changes, and `StopMovement()` clear all carry. Physical travel direction is passed to collision without replacing the player's input-facing direction. Vector players use centered 24-by-24 physical bounds inside their unchanged 32-pixel sprite, providing four pixels of wall and doorway clearance without overriding custom-sized actors. Vector input records requested and actual pixel displacement so a truthy partial `Move()` is still recognized as a collision. `tryNexusVectorMoveWithGapNudge()` and `tryNexusInertiaMove()` probe cardinal and near-cardinal travel before moving, then use a stable one-pixel perpendicular correction to align characters with nearby gaps and doorways; deliberate diagonal displacement falls back to its unobstructed axis for wall sliding. `NexusSkillMotion` gives lunges, rushes, pass-through attacks, pulls, manual evasions, and automatic projectile dodges the same fixed-step acceleration, braking, collision telemetry, target cancellation, and ownership-safe cleanup. Short Dash uses that core for a seven-tile (224-pixel) defensive burst with near-immediate acceleration, late high-rate braking, 20% exit-velocity transfer, and a selective 1.5-decisecond dodge window. Its eight directional actions are independently remappable through the same hotkey registry as Zanzoken; there is no hardcoded Ctrl-direction trigger. Zanzoken remains the longer intentional warp. The gap-search behavior is adapted with credit from [Woo/Tyruswoo's Gap-Nudge Movement v3.3](https://secure.byond.com/developer/Woo/GapNudgeMovement).

## Files
- `src/Code/Application/Movement/MovementAlignment.dm`
- `src/Code/Application/Movement/MovementCollision.dm`
- `src/Code/Application/Movement/MovementInput.dm`
- `src/Code/Application/Movement/MovementPhysics.dm`
- `src/Code/Application/Movement/SkillMovementPhysics.dm`
- `src/Code/Application/Movement/DefensiveDash.dm`
- `src/Code/Application/Movement/MovementValidation.dm`
- `src/Code/Application/Movement/MovementEnvironment.dm`
- `src/Code/Application/Movement/MovementMacros.dm`
- `src/Code/Application/Movement/MovementFlow.dm`
- `src/Code/Application/Movement/MovementPixelUtils.dm`
- `src/Code/Application/Movement/MovementWarp.dm`
- `src/Code/Domain/Movement/MovementPorts.dm`
- `src/Code/Interface/Movement/Cross.dm`
- `src/Code/Interface/Movement/Move.dm`
- `src/Code/Interface/Movement/MoveMacros.dm`
- `src/Code/Interface/Movement/ClientInput.dm`
- `src/Code/Interface/Movement/PixelMoving.dm`
- `src/Code/Infrastructure/Movement/MovementPortsByond.dm`

## Proc Reference

### src/Code/Application/Movement/SkillMovementPhysics.dm

#### datum/NexusSkillMotion/proc/executeMotion
- Signature: `datum/NexusSkillMotion/proc/executeMotion()`
- Purpose: Integrate an owned skill movement on the shared fixed physics step until its target or pixel goal is reached, or until collision, target, teleport, KO, or ownership state interrupts it.
- Returns: `NEXUS_SKILL_MOTION_REACHED` only when the declared goal is reached; otherwise `NEXUS_SKILL_MOTION_INTERRUPTED`.
- Side effects: updates pixel position, skill velocity, collision telemetry, afterimages, and contacted-mob collection.

#### datum/NexusSkillMotionResult
- Purpose: Carry generation-bound completion, physical distance, contact, and contact-time Short Dash evasion telemetry back to exactly one skill caller.
- Side effects: prevents a superseded asynchronous motion from consuming a newer motion's global telemetry.

#### mob/proc/cancelNexusSkillMotion
- Signature: `mob/proc/cancelNexusSkillMotion(reason)`
- Purpose: Invalidate the current skill-motion generation and clear only the movement state still owned by that generation.
- Returns: none (implicit).
- Side effects: clears active/internal motion ownership, skill velocity, and optional gap-nudge state.

#### mob/proc/runNexusSkillMotion
- Signature: `mob/proc/runNexusSkillMotion(atom/movable/target, movement_direction, max_distance_pixels, stop_distance_pixels = 0, max_velocity = skill_motion_default_max_velocity, acceleration = skill_motion_default_acceleration, deceleration = skill_motion_default_deceleration, afterimage_interval = 0.5, velocity_transfer = 0, pass_mobs = FALSE, require_selected_target = FALSE, datum/NexusSkillMotionResult/result_capture, movement_vector_x = 0, movement_vector_y = 0)`
- Purpose: Start one ownership-safe accelerated skill movement toward a live target or along a fixed direction.
- Returns: reached/interrupted result from the owned motion.
- Side effects: cancels older motion, suspends normal inertia, optionally records pass-through contacts, and can transfer bounded exit velocity back to normal movement.

#### mob/proc/runNexusSkillLine
- Signature: `mob/proc/runNexusSkillLine(movement_direction, distance_pixels, max_velocity = skill_motion_default_max_velocity, acceleration = skill_motion_default_acceleration, deceleration = skill_motion_default_deceleration, afterimage_interval = 0.5, velocity_transfer = 0, pass_mobs = FALSE, datum/NexusSkillMotionResult/result_capture)`
- Purpose: Run a straight accelerated skill movement for an exact pixel budget.
- Returns: reached/interrupted result.

#### mob/proc/runNexusSkillVector
- Signature: `mob/proc/runNexusSkillVector(direction_x, direction_y, distance_pixels, max_velocity = skill_motion_default_max_velocity, acceleration = skill_motion_default_acceleration, deceleration = skill_motion_default_deceleration, afterimage_interval = 0.5, velocity_transfer = 0, pass_mobs = FALSE, datum/NexusSkillMotionResult/result_capture)`
- Purpose: Run a straight accelerated motion along exact arbitrary X/Y components, allowing off-axis attacks such as Dash Attack to intersect their intended target instead of snapping to an eight-way heading.
- Returns: reached/interrupted result.

#### mob/proc/runNexusSkillApproach
- Signature: `mob/proc/runNexusSkillApproach(atom/movable/target, maximum_distance_pixels, stop_distance_pixels = 32, max_velocity = skill_motion_default_max_velocity, acceleration = skill_motion_default_acceleration, deceleration = skill_motion_default_deceleration, afterimage_interval = 0.5, require_selected_target = TRUE, datum/NexusSkillMotionResult/result_capture)`
- Purpose: Accelerate toward a tracked target, brake at the requested contact distance, and normally cancel if the player's selected target changes.
- Returns: reached/interrupted result.

#### mob/proc/canStartNexusVectorDodge
- Signature: `mob/proc/canStartNexusVectorDodge(movement_direction)`
- Purpose: Validate a one-tile automatic projectile-dodge direction and its immediate collision destination.
- Returns: boolean flag.

#### mob/proc/runNexusVectorDodge
- Signature: `mob/proc/runNexusVectorDodge(movement_direction)`
- Purpose: Run the accepted automatic dodge asynchronously through the accelerated skill-motion core without blocking projectile collision resolution.
- Returns: none (asynchronous).

#### mob/proc/tryNexusVectorDodge
- Signature: `mob/proc/tryNexusVectorDodge(movement_direction)`
- Purpose: Validate and queue the vector dodge used by Ultra Instinct and precognition against beams and blasts.
- Returns: true when a dodge motion was accepted.

### src/Code/Application/Movement/DefensiveDash.dm

#### mob/proc/canDefensiveDash
- Signature: `mob/proc/canDefensiveDash(direction_override)`
- Purpose: Validate direction, movement ownership, combat locks, cooldown, and Stamina for Short Dash.
- Returns: boolean flag.

#### mob/proc/isDefensiveDashEvading
- Signature: `mob/proc/isDefensiveDashEvading(obj/Blast/projectile)`
- Purpose: Return whether the active Short Dash may evade a direct melee hit or an eligible small, non-beam, non-explosive projectile during its short dodge window.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/tryDefensiveDash
- Signature: `mob/proc/tryDefensiveDash(direction_override)`
- Purpose: Commit the 3-Stamina, 0.6-second-cooldown Short Dash and run its seven-tile (224-pixel) accelerated vector burst with a sharp late brake and limited exit inertia.
- Returns: reached/interrupted result asynchronously.
- Side effects: spends Stamina, starts cooldown and selective dodge timing, emits afterimage/audio feedback, and transfers a bounded fraction of exit velocity.

### src/Code/Application/Movement/MovementAlignment.dm

#### mob/proc/AlignToTile
- Signature: `mob/proc/AlignToTile()`
- Inputs: None
- Purpose: Handle align to tile.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/LerpToTile
- Signature: `mob/proc/LerpToTile(d, dist)`
- Inputs: d, dist
- Purpose: Handle lerp to tile.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ResetStepXY
- Signature: `mob/proc/ResetStepXY()`
- Inputs: None
- Purpose: Handle reset step xy.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/NpcAlignToTile
- Signature: `mob/proc/NpcAlignToTile(d)`
- Inputs: d
- Purpose: Handle npc align to tile.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/UpdateStepSpeed
- Signature: `mob/proc/UpdateStepSpeed()`
- Inputs: None
- Purpose: Update Step Speed.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/Application/Movement/MovementCollision.dm

#### atom/movable/proc/MovementCrossDecision
- Signature: `atom/movable/proc/MovementCrossDecision(atom/movable/a)`
- Inputs: atom/movable/a
- Purpose: Handle movement cross decision for movable atoms.
- Returns: boolean flag or null to fall through.
- Side effects: none expected.

#### mob/proc/SideStep
- Signature: `mob/proc/SideStep(obj/o)`
- Inputs: obj/o
- Purpose: Handle side step.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BumpKnockbackDestroyObjectCheck
- Signature: `BumpKnockbackDestroyObjectCheck(obj/o)`
- Inputs: obj/o
- Purpose: Handle bump knockback destroy object check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MovementBump
- Signature: `mob/proc/MovementBump(atom/A)`
- Inputs: atom/A
- Purpose: Record the current collision target and apply knockback destruction checks for objects.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/MovementEnterResult
- Signature: `turf/proc/MovementEnterResult(mob/m, return_value)`
- Inputs: mob/m, return_value
- Purpose: Update enter result for movement.
- Returns: boolean flag.
- Side effects: see implementation.

#### mob/proc/DoorPasswordAlert
- Signature: `mob/proc/DoorPasswordAlert(obj/Turfs/Door/d)`
- Inputs: obj/Turfs/Door/d
- Purpose: Handle door password alert.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MobCross
- Signature: `mob/proc/MobCross(mob/A)`
- Inputs: mob/A
- Purpose: Handle mob cross.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Application/Movement/MovementInput.dm

#### mob/proc/configureNexusVectorCollisionBounds
- Signature: `configureNexusVectorCollisionBounds()`
- Purpose: Center the standard player collider at 24 by 24 pixels while preserving custom bounds.
- Returns: none (implicit).
- Side effects: updates `bound_x`, `bound_y`, `bound_width`, and `bound_height` for default-sized vector players.

#### mob/proc/nexusVectorDensityCount
- Signature: `nexusVectorDensityCount(fraction_x, fraction_y, fraction_width = 0, fraction_height = 0, offset_x = 0, offset_y = 0, extra_width = 0, extra_height = 0)`
- Purpose: Count relevant dense atoms in an offset portion of the mob's bounds without attempting speculative movement.
- Returns: dense atom count, or `-1` at a map edge.

#### mob/proc/findNexusGapNudgeDirection
- Signature: `findNexusGapNudgeDirection(move_direction, lookahead_pixels = 1, list/candidates)`
- Purpose: Select and retain a bounded perpendicular direction toward the only open half of the requested path, reusing a preflight candidate list when available.
- Returns: a cardinal nudge direction or null.

#### mob/proc/tryNexusVectorMoveWithGapNudge
- Signature: `tryNexusVectorMoveWithGapNudge(move_direction, movement_pixels)`
- Purpose: Perform a vector step, distinguish full movement from partial collision, and resolve nearby gaps or diagonal wall slides.
- Returns: a truthy value when either requested or corrective movement occurred.

#### mob/proc/GetInputMoveDelay
- Signature: `GetInputMoveDelay(d = NORTH, raw_mult_only)`
- Inputs: d = NORTH, raw_mult_only
- Purpose: Return Input Move Delay.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/UsingVectorMovement
- Signature: `UsingVectorMovement()`
- Inputs: None
- Purpose: Return whether vector movement is enabled for the mob.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/GetVectorMovePixels
- Signature: `GetVectorMovePixels(d = NORTH)`
- Inputs: d = NORTH
- Purpose: Return vector movement distance from the configured base speed, bounded Speed-stat multiplier, movement conditions, and tick duration.
- Returns: pixels to advance during the current vector step.
- Side effects: none expected.

#### mob/proc/getVectorMaximumVelocity
- Signature: `getVectorMaximumVelocity(d = NORTH, apply_diagonal_penalty = FALSE)`
- Inputs: direction and whether to preserve the legacy diagonal delay.
- Purpose: Return a true pixels-per-decisecond speed cap before tick scaling, per-frame floors, or legacy displacement caps.
- Returns: non-negative movement velocity.
- Side effects: none expected.

#### mob/proc/GetVectorMovementStatMultiplier
- Signature: `GetVectorMovementStatMultiplier()`
- Inputs: None
- Purpose: Convert the combat Speed delay curve into a bounded movement multiplier while preserving the configured average base speed.
- Returns: multiplier between `vector_move_speed_stat_minimum` and `vector_move_speed_stat_maximum`.
- Side effects: none expected.

#### mob/proc/VectorMoveDir
- Signature: `VectorMoveDir(d, loop_mult = 1)`
- Inputs: d, loop_mult = 1
- Purpose: Move the mob using vector movement for a direction.
- Returns: boolean flag or null.
- Side effects: mutates game state and/or world resources.

#### mob/proc/GetVectorMoveLoopMult
- Signature: `GetVectorMoveLoopMult(speed)`
- Inputs: speed
- Purpose: Return loop multiplier for vector movement based on speed.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/GetVectorGlideSize
- Signature: `GetVectorGlideSize(speed)`
- Inputs: speed
- Purpose: Return glide size for vector movement smoothing.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/UpdateNextInputMoveTime
- Signature: `UpdateNextInputMoveTime(d = NORTH)`
- Inputs: d = NORTH
- Purpose: Update Next Input Move Time.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/CanInputMove
- Signature: `CanInputMove()`
- Inputs: None
- Purpose: Return whether Input Move.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/AlterInputDisabled
- Signature: `AlterInputDisabled(n = 1)`
- Inputs: n = 1
- Purpose: Handle alter input disabled.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FearSlowDown
- Signature: `FearSlowDown()`
- Inputs: None
- Purpose: Handle fear slow down.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/HealthSlowdown
- Signature: `HealthSlowdown()`
- Inputs: None
- Purpose: Handle health slowdown.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Application/Movement/MovementPhysics.dm

#### mob/proc/resetMovementPhysics
- Signature: `resetMovementPhysics(clear_fraction = TRUE, clear_glide = TRUE)`
- Purpose: Clear normal-player acceleration and velocity, optionally clearing fractional pixel carry and glide interpolation without changing `step_x` or `step_y` position.
- Returns: none (implicit).
- Side effects: clears inertial movement and any active gap-nudge target.

#### mob/proc/accelerateMovementVelocity
- Signature: `accelerateMovementVelocity(input_x, input_y, acceleration_delta, max_velocity)`
- Purpose: Normalize input, add this frame's acceleration to retained velocity, and clamp the result by vector magnitude.
- Returns: the resulting velocity magnitude.
- Side effects: updates acceleration and velocity components.

#### mob/proc/retainMovementVelocity
- Signature: `retainMovementVelocity(retention, stop_velocity = -1)`
- Purpose: Apply a bounded retention multiplier and independently snap sufficiently small velocity components to zero.
- Returns: the retained velocity magnitude.
- Side effects: updates velocity components.

#### mob/proc/movementDurationRetention
- Signature: `movementDurationRetention(retention_per_decisecond, duration_deciseconds)`
- Purpose: Convert the configured per-decisecond retention into an exponential duration multiplier so movement decay remains stable when tick rate changes.
- Returns: a retention multiplier between zero and one.
- Side effects: none expected.

#### mob/proc/getMovementGapDirection
- Signature: `getMovementGapDirection(movement_x, movement_y)`
- Purpose: Quantize velocity with a small dominant-axis tolerance so residual turn carry keeps cardinal doorway correction while intentional diagonals remain diagonal.
- Returns: a cardinal or diagonal direction, or null for a zero vector.
- Side effects: none expected.

#### mob/proc/resolveMovementVelocityCollision
- Signature: `resolveMovementVelocityCollision()`
- Purpose: Compare requested and actual vector displacement, clearing only velocity components blocked by collision.
- Returns: none (implicit).
- Side effects: projects movement velocity along unblocked wall axes.

#### mob/proc/handleMovementPhysicsLockedInput
- Signature: `handleMovementPhysicsLockedInput(input_direction)`
- Purpose: Preserve directional skill interactions such as beam/grab struggling, moving-charge advancement, dash steering, defensive facing, and ship/car control while character displacement is suspended.
- Returns: none (implicit).
- Side effects: may update skill state or facing without moving the mob.

#### mob/proc/movementPhysicsHardLocked
- Signature: `movementPhysicsHardLocked()`
- Purpose: Detect vehicles, forced techniques, combat ownership, beam/grab states, and active bank interaction that must discard normal locomotion inertia.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/movementPhysicsSuspended
- Signature: `movementPhysicsSuspended(ignore_client = FALSE, validate_standard_movement = TRUE)`
- Purpose: Reject normal inertia while input is unavailable or `movementPhysicsHardLocked()` gives another system ownership of movement.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/tryNexusInertiaMove
- Signature: `tryNexusInertiaMove(movement_x, movement_y)`
- Purpose: Resolve arbitrary X/Y velocity through native vector stepping while preserving doorway nudges, partial-collision detection, and wall sliding.
- Returns: boolean flag or null.
- Side effects: moves the mob and may project blocked velocity.

#### mob/proc/processMovementPhysicsFrame
- Signature: `processMovementPhysicsFrame(input_direction)`
- Purpose: Accumulate elapsed server time and run bounded fixed-duration normal-movement physics steps.
- Returns: boolean flag or null.
- Side effects: updates movement physics, position, and glide interpolation.

#### mob/proc/processMovementPhysicsStep
- Signature: `processMovementPhysicsStep(input_direction, duration_deciseconds)`
- Purpose: Run one fixed acceleration, movement, collision, and friction step for normal client locomotion.
- Returns: boolean flag or null.
- Side effects: updates movement physics, position, and glide interpolation.

### src/Code/Application/Movement/MovementValidation.dm

#### mob/proc/Can_Move
- Signature: `mob/proc/Can_Move()`
- Inputs: None
- Purpose: Return whether Move.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Allow_Move
- Signature: `mob/proc/Allow_Move(D)`
- Inputs: D
- Purpose: Handle allow move.
- Returns: boolean flag.
- Side effects: see implementation.

#### mob/proc/_allow_move_handle_kiting_and_finalize
- Signature: `mob/proc/_allow_move_handle_kiting_and_finalize(D)`
- Inputs: D
- Purpose: Handle kiting checks and update directional state.
- Returns: boolean flag.
- Side effects: see implementation.

#### mob/proc/_allow_move_prechecks
- Signature: `mob/proc/_allow_move_prechecks(D)`
- Inputs: D
- Purpose: Handle allow move prechecks.
- Returns: boolean flag.
- Side effects: see implementation.

#### mob/proc/Edge_Check
- Signature: `mob/proc/Edge_Check(turf/old_loc)`
- Inputs: turf/old_loc
- Purpose: Handle edge check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Save_Location
- Signature: `mob/proc/Save_Location() if(z&&!Regenerating)`
- Inputs: None
- Purpose: Save Location.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Cease_training
- Signature: `mob/proc/Cease_training()`
- Inputs: None
- Purpose: Handle cease training.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Application/Movement/MovementEnvironment.dm

#### mob/proc/update_area
- Signature: `mob/proc/update_area()`
- Inputs: None
- Purpose: Update area.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/CheckAirMask
- Signature: `CheckAirMask()`
- Inputs: None
- Purpose: Check Air Mask.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CheckSpaceDie
- Signature: `CheckSpaceDie()`
- Inputs: None
- Purpose: Check Space Die.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpaceDamage
- Signature: `SpaceDamage()`
- Inputs: None
- Purpose: Handle space damage.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Application/Movement/MovementMacros.dm

#### mob/proc/Macro_direction
- Signature: `mob/proc/Macro_direction()`
- Inputs: None
- Purpose: Handle macro direction.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/HandleKeyDown
- Signature: `mob/proc/HandleKeyDown(d)`
- Inputs: d
- Purpose: Handle key down.
- Returns: none (implicit).
- Side effects: updates movement input state without hardcoding Zanzoken or Short Dash to modifier-direction combinations.

#### mob/proc/HotbarUseHandler
- Signature: `mob/proc/HotbarUseHandler(d, held_key, was_key_held = FALSE)`
- Inputs: canonical trigger combination, physical held-key identity, and held/repeat state.
- Purpose: Resolve a single-press or double-tap binding before executing its hotbar action.
- Returns: none (implicit).
- Side effects: tracks the active resolved binding until key-up.

#### mob/proc/HotbarKeyUpHandler
- Signature: `mob/proc/HotbarKeyUpHandler(d)`
- Inputs: d
- Purpose: Handle hotbar key up handler.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/HandleKeyUp
- Signature: `mob/proc/HandleKeyUp(d)`
- Inputs: d
- Purpose: Release movement/hotbar state and allow a quick Space melee follow-up without triggering Lunge.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ReleaseKey
- Signature: `mob/proc/ReleaseKey(d)`
- Inputs: d
- Purpose: Handle release key.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/move_dir
- Signature: `mob/proc/move_dir()`
- Inputs: None
- Purpose: Resolve held cardinal keys into an eight-way direction while cancelling opposing axes.
- Returns: a BYOND direction or null.
- Side effects: none expected.

#### mob/proc/move_loop
- Signature: `mob/proc/move_loop()`
- Inputs: None
- Purpose: Run fixed-cadence normal movement while input or retained velocity remains, preserving aim/strafe direction and suspending during forced movement.
- Returns: none (implicit).
- Side effects: updates position, input timing, velocity, facing, and loop-generation state.

#### mob/proc/StopMovement
- Signature: `mob/proc/StopMovement()`
- Inputs: None
- Purpose: Cancel held input and invalidate the active movement coroutine before clearing all normal inertial state.
- Returns: none (implicit).
- Side effects: clears keys, acceleration, velocity, fractional carry, gap nudging, and glide interpolation.

### src/Code/Application/Movement/MovementFlow.dm

#### mob/proc/Moving_auto_attack
- Signature: `mob/proc/Moving_auto_attack()`
- Inputs: None
- Purpose: Handle moving auto attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PlayerPreMove
- Signature: `mob/proc/PlayerPreMove()`
- Inputs: None
- Purpose: Handle player pre move.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/SafeTeleport
- Signature: `SafeTeleport(turf/t, allowSameTick)`
- Inputs: turf/t, allowSameTick
- Purpose: Handle safe teleport.
- Returns: none (implicit).
- Side effects: see implementation.

#### atom/movable/proc/LegitMove
- Signature: `LegitMove(turf/prevLoc, turf/newLoc)`
- Inputs: turf/prevLoc, turf/newLoc
- Purpose: Handle legit move.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PlayerPostMove
- Signature: `mob/proc/PlayerPostMove(old_loc)`
- Inputs: old_loc
- Purpose: Handle player post move.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/NPCPostMove
- Signature: `mob/proc/NPCPostMove(old_loc)`
- Inputs: old_loc
- Purpose: Handle npcpost move.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/XYtoDir
- Signature: `proc/XYtoDir(x, y) //takes an x and y and decides if this movement is NSEW SW NW NE or SE`
- Inputs: x, y
- Purpose: Handle xyto dir.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Application/Movement/MovementPixelUtils.dm

#### proc/Get_Pixel
- Signature: `proc/Get_Pixel(mob/O,x,y)`
- Inputs: mob/O, x, y
- Purpose: Return Pixel.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/Generate_Bounding_Box
- Signature: `proc/Generate_Bounding_Box(obj/O,Test)`
- Inputs: obj/O, Test
- Purpose: Handle generate bounding box.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Application/Movement/MovementWarp.dm

#### mob/proc/TapWarpCantMoveTime
- Signature: `TapWarpCantMoveTime()`
- Inputs: None
- Purpose: Handle tap warp cant move time.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanTapWarp
- Signature: `CanTapWarp()`
- Inputs: None
- Purpose: Return whether Tap Warp, using actual `/obj/Zanzoken` ownership rather than an unvalidated cached pointer.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/directionalZanzoken
- Signature: `directionalZanzoken(d)`
- Inputs: one of the eight map directions.
- Purpose: Warp to and attack the selected opponent when it is within five tiles and the requested direction cone; otherwise move up to five tiles in that direction.
- Returns: none (asynchronous).
- Side effects: drains five stamina, creates the standard effects, and may perform one adjacent melee attack.

#### mob/proc/DoubleTapWarp
- Signature: `DoubleTapWarp(d)`
- Inputs: d
- Purpose: Warp around the explicitly selected target when valid; otherwise preserve directional warp without auto-attacking another mob.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/TapWarpToMob
- Signature: `TapWarpToMob(mob/m)`
- Inputs: mob/m
- Purpose: Move to a valid adjacent turf while matching the target's vector offsets and facing it.
- Returns: 1 on success, otherwise null.
- Side effects: updates location, `step_x`, `step_y`, and direction.

#### mob/proc/ValidWarpTurf
- Signature: `ValidWarpTurf(turf/t)`
- Inputs: turf/t
- Purpose: Reject blank, opaque, dense, or dense-object destinations.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/TapWarpToDir
- Signature: `TapWarpToDir(d, warp_dist = 5)`
- Inputs: direction and maximum distance.
- Purpose: Move to the furthest valid turf along a directional path.
- Returns: 1 when at least one tile was crossed, otherwise null.
- Side effects: teleports the mob and faces it in the requested direction.

### src/Code/Domain/Movement/MovementPorts.dm

#### datum/MovementPort/proc/hasClient
- Signature: `datum/MovementPort/proc/hasClient(mob/m)`
- Inputs: mob/m
- Purpose: Return whether mob has client.
- Returns: boolean flag.
- Side effects: none expected.

#### datum/MovementPort/proc/clientCtrlDown
- Signature: `datum/MovementPort/proc/clientCtrlDown(mob/m)`
- Inputs: mob/m
- Purpose: Return whether Ctrl is held.
- Returns: boolean flag.
- Side effects: none expected.

#### datum/MovementPort/proc/clientShiftDown
- Signature: `datum/MovementPort/proc/clientShiftDown(mob/m)`
- Inputs: mob/m
- Purpose: Return whether Shift is held.
- Returns: boolean flag.
- Side effects: none expected.

#### datum/MovementPort/proc/areaUpdateSenseTargets
- Signature: `datum/MovementPort/proc/areaUpdateSenseTargets(area/a)`
- Inputs: area/a
- Purpose: Update area sense targets.
- Returns: none (implicit).
- Side effects: mutates area state.

#### datum/MovementPort/proc/startCoreLoops
- Signature: `datum/MovementPort/proc/startCoreLoops(mob/m, area/a)`
- Inputs: mob/m, area/a
- Purpose: Start core loops for the area.
- Returns: none (implicit).
- Side effects: triggers core loop procs.

#### datum/MovementPort/proc/finalRealmLoop
- Signature: `datum/MovementPort/proc/finalRealmLoop(mob/m)`
- Inputs: mob/m
- Purpose: Run final realm loop.
- Returns: none (implicit).
- Side effects: triggers realm loop proc.

#### datum/MovementPort/proc/verifyBattlegroundMaster
- Signature: `datum/MovementPort/proc/verifyBattlegroundMaster(mob/m)`
- Inputs: mob/m
- Purpose: Verify battleground master.
- Returns: none (implicit).
- Side effects: mutates battleground state.

#### datum/MovementPort/proc/sendMessage
- Signature: `datum/MovementPort/proc/sendMessage(mob/m, message)`
- Inputs: mob/m, message
- Purpose: Send a message to a mob.
- Returns: none (implicit).
- Side effects: sends output to client.

### src/Code/Interface/Movement/Cross.dm

#### atom/movable/Cross
- Signature: `Cross(atom/movable/a)`
- Inputs: atom/movable/a
- Purpose: Handle cross.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Bump
- Signature: `mob/Bump(mob/A)`
- Inputs: mob/A
- Purpose: Handle bump.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/Enter
- Signature: `turf/Enter(mob/m)`
- Inputs: mob/m
- Purpose: Handle enter.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Interface/Movement/Move.dm

#### mob/Move
- Signature: `mob/Move(turf/NewLoc, Dir = 0, step_x = 0, step_y = 0)`
- Inputs: turf/NewLoc, Dir = 0, step_x = 0, step_y = 0
- Purpose: Central movement implementation; attack locks reject ordinary movement while `attack_forced_movement` permits only skill-controlled steps such as Dash Attack.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Interface/Movement/MoveMacros.dm

#### mob/verb/KeyDown
- Signature: `mob/verb/KeyDown(d as text)`
- Inputs: d as text
- Purpose: Handle key down.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/KeyUp
- Signature: `mob/verb/KeyUp(d as text)`
- Inputs: d as text
- Purpose: Handle key up.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/SetCtrlStatus
- Signature: `SetCtrlStatus(status as text)`
- Inputs: status as text
- Purpose: Set Ctrl Status.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/verb/ShiftDown
- Signature: `ShiftDown()`
- Inputs: None
- Purpose: Handle shift down.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/ShiftUp
- Signature: `ShiftUp()`
- Inputs: None
- Purpose: Handle shift up.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Interface/Movement/ClientInput.dm

#### client/North
- Signature: `client/North()`
- Inputs: None
- Purpose: Handle client north input.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/South
- Signature: `client/South()`
- Inputs: None
- Purpose: Handle client south input.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/East
- Signature: `client/East()`
- Inputs: None
- Purpose: Handle client east input.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/West
- Signature: `client/West()`
- Inputs: None
- Purpose: Handle client west input.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/Northwest
- Signature: `client/Northwest()`
- Inputs: None
- Purpose: Handle client northwest input.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/Northeast
- Signature: `client/Northeast()`
- Inputs: None
- Purpose: Handle client northeast input.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/Southwest
- Signature: `client/Southwest()`
- Inputs: None
- Purpose: Handle client southwest input.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/Southeast
- Signature: `client/Southeast()`
- Inputs: None
- Purpose: Handle client southeast input.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/MouseWheel
- Signature: `client/MouseWheel(object, delta_x, delta_y, location, control, params)`
- Inputs: native BYOND mouse-wheel event data.
- Purpose: Route vertical wheel movement over bare/world content in `mapwindow.map` to the world-only zoom compositor. Targets on `NEXUS_FIXED_HUD_PLANE`, browsers, and other controls retain their normal behavior.
- Returns: none (implicit).
- Side effects: may update the player's bounded logical map view through `adjustMapZoom()`; it does not resize the live character's render envelope.

### src/Code/Interface/Movement/PixelMoving.dm

#### mob/Admin4/verb/fps
- Signature: `mob/Admin4/verb/fps()`
- Inputs: None
- Purpose: Handle fps.
- Returns: none (implicit).
- Side effects: see implementation.
