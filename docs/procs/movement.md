# Movement

## Overview
Auto-generated first-pass proc summaries based on signature names. Refine descriptions during refactors.

## Files
- `src/Code/Application/Movement/MovementAlignment.dm`
- `src/Code/Application/Movement/MovementCollision.dm`
- `src/Code/Application/Movement/MovementInput.dm`
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
- Purpose: Handle bump logic.
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
- Purpose: Return computed vector move distance in pixels.
- Returns: computed value (see implementation).
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
- Side effects: updates movement input state; Ctrl no longer triggers Zanzoken.

#### mob/proc/HotbarUseHandler
- Signature: `mob/proc/HotbarUseHandler(d)`
- Inputs: d
- Purpose: Handle hotbar use handler.
- Returns: none (implicit).
- Side effects: see implementation.

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
- Purpose: Handle move dir.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/move_loop
- Signature: `mob/proc/move_loop()`
- Inputs: None
- Purpose: Handle move loop.
- Returns: none (implicit).
- Side effects: see implementation.

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

### src/Code/Interface/Movement/PixelMoving.dm

#### mob/Admin4/verb/fps
- Signature: `mob/Admin4/verb/fps()`
- Inputs: None
- Purpose: Handle fps.
- Returns: none (implicit).
- Side effects: see implementation.
