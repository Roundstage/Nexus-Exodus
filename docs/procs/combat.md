# Combat

## Overview
Combat resolution, skill routing, damage, and attack-specific behavior.

Guided blasts use one resolved control direction for collision checks and movement, preventing Sokidan from stepping away from a contacted target. Kienzan has no one-hit per-target budget; every successful pierce multiplies its live damage factor by `skill_kienzan_pierce_decay` (currently 0.5), allowing repeated bounded hits. Fight to the Death now directly synchronizes `sparring_mode` and `Fatal`; there is no secondary non-lethal choice, and tournaments force Casual mode.

Sense tracking is persistent while Sense or a compatible scanner is owned. Client-local world images render each readable character's relative power percentage below their sprite, while appearance-matched arrows keep off-screen signatures discoverable. The replacement Sense menu adds sprite icons and exposes qualitative Strength, Endurance, Speed, Force, Resistance, Offense, and Defense ratings to Sense 3.

Dragon Rush accepts collisions between any two active Lunge, Wolf Fang Fist, or Dropkick approaches. Its original instant warp/input cadence is preserved, with a larger centered `UP`, `DOWN`, `LEFT`, or `RIGHT` prompt identifying the required key for each fighter. Combat dummies expose `Dummy Lunge At Me` for deterministic clash testing.

Weapon techniques use separate CC0 light/heavy swing and randomized blade-impact profiles instead of sharing the legacy two-sound pair. Each hit layers its imported Tenkaichi effect with a nine-frame pixel slash whose runtime tint identifies the technique. Rock Throw, Rock Slide, and Rock Tomb use CC0 launch, rumble, stone-impact, boulder-impact, and fracture profiles; moving rocks shed small fragments, impacts raise ground rocks, and heavy hits scatter larger debris.

Confirmed melee critical hits use the original `showNexusCriticalImpact()` presentation: a dark impact core, three independently rotated black/crimson spark ruptures generated at runtime, a short crimson light pulse, shockwave, screen shake, floating `BLACK FLASH` title, and layered physical/energy impact audio. `Test Combat Effects > Critical - Black Flash` previews the complete presentation without dealing damage.

## Files
- `src/Code/Application/Combat/SkillActors.dm`
- `src/Code/Application/Combat/SkillControllers.dm`
- `src/Code/Application/Combat/SkillEngine.dm`
- `src/Code/Combat/BleedDamage.dm`
- `src/Code/Combat/Buffs.dm`
- `src/Code/Combat/CombatDummy.dm`
- `src/Code/Combat/Evasion.dm`
- `src/Code/Combat/HokutoShinken.dm`
- `src/Code/Combat/Injuries.dm`
- `src/Code/Combat/KiSkills/DeathBall2017.dm`
- `src/Code/Combat/KiSkills/FinalExplosion.dm`
- `src/Code/Combat/KiSkills/FusionSystem.dm`
- `src/Code/Combat/KiSkills/Hakai.dm`
- `src/Code/Combat/KiSkills/Kikoho2016.dm`
- `src/Code/Combat/KiSkills/Sense2017/Sense.dm`
- `src/Code/Combat/KiSkills/SolarFlare.dm`
- `src/Code/Combat/KiSkills/SpiritBomb2016.dm`
- `src/Code/Combat/KiSkills/Supernova.dm`
- `src/Code/Combat/Math/CombatMath.dm`
- `src/Code/Combat/Melee.dm`
- `src/Code/Combat/Stun.dm`
- `src/Code/Combat/Melee/DragonRush.dm`
- `src/Code/Combat/Melee/PressurePunch.dm`
- `src/Code/Combat/Melee/RoundhouseKick.dm`
- `src/Code/Combat/Melee/SuperDropkick.dm`
- `src/Code/Combat/Melee/WolfFangFist.dm`
- `src/Code/Combat/RareDeathEffects.dm`
- `src/Code/Combat/RevengeSystem.dm`
- `src/Code/Combat/RockThrow.dm`
- `src/Code/Combat/Skills.dm`
- `src/Code/Combat/SpeedDelay.dm`
- `src/Code/Combat/SplitForms.dm`
- `src/Code/Combat/Targeting/Targeting.dm`
- `src/Code/Combat/Targeting/TargetingWrappers.dm`
- `src/Code/Domain/Combat/SkillBehaviors.dm`
- `src/Code/Domain/Combat/SkillCategories.dm`

## Proc Reference

### src/Code/Application/Combat/SkillEngine.dm

#### proc/initializeSkillEngine
- Signature: `initializeSkillEngine()`
- Inputs: None
- Purpose: Initialize the skill engine registry.
- Returns: none (implicit).
- Side effects: builds skill definitions.

#### datum/SkillRegistry/proc/register
- Signature: `datum/SkillRegistry/proc/register(datum/SkillDefinition/def)`
- Inputs: datum/SkillDefinition/def
- Purpose: Register a skill definition.
- Returns: none (implicit).
- Side effects: mutates registry state.

#### datum/SkillRegistry/proc/get
- Signature: `datum/SkillRegistry/proc/get(id)`
- Inputs: id
- Purpose: Fetch a skill definition by id.
- Returns: datum/SkillDefinition or null.
- Side effects: none expected.

#### datum/SkillRegistry/proc/all
- Signature: `datum/SkillRegistry/proc/all()`
- Inputs: None
- Purpose: Return all registered skill definitions.
- Returns: list of definitions.
- Side effects: none expected.

#### datum/SkillEngine/proc/bootstrap
- Signature: `datum/SkillEngine/proc/bootstrap()`
- Inputs: None
- Purpose: Build the skill registry.
- Returns: none (implicit).
- Side effects: mutates registry state.

#### datum/SkillEngine/proc/startLoop
- Signature: `datum/SkillEngine/proc/startLoop()`
- Inputs: None
- Purpose: Start the skill engine world loop.
- Returns: none (implicit).
- Side effects: spawns a loop that ticks actors.

#### datum/SkillEngine/proc/stopLoop
- Signature: `datum/SkillEngine/proc/stopLoop()`
- Inputs: None
- Purpose: Stop the skill engine world loop.
- Returns: none (implicit).
- Side effects: halts actor ticking.

#### datum/SkillEngine/proc/engineLoop
- Signature: `datum/SkillEngine/proc/engineLoop()`
- Inputs: None
- Purpose: Tick active skill actors and park the worker immediately when the registry becomes empty.
- Returns: none (implicit).
- Side effects: ticks active actors and clears `loop_running` while idle.

#### datum/SkillEngine/proc/registerActor
- Signature: `datum/SkillEngine/proc/registerActor(datum/SkillActor/actor)`
- Inputs: datum/SkillActor/actor
- Purpose: Register an actor once and wake the parked engine loop on demand.
- Returns: none (implicit).
- Side effects: adds to actor lists.

#### datum/SkillEngine/proc/removeActor
- Signature: `datum/SkillEngine/proc/removeActor(datum/SkillActor/actor)`
- Inputs: datum/SkillActor/actor
- Purpose: Remove an actor from the engine.
- Returns: none (implicit).
- Side effects: removes from actor lists.

#### datum/SkillEngine/proc/tickActors
- Signature: `datum/SkillEngine/proc/tickActors()`
- Inputs: None
- Purpose: Tick all active actors and cleanup completed ones.
- Returns: none (implicit).
- Side effects: mutates actor lists.

### src/Code/Application/Combat/SkillActors.dm

#### datum/SkillActorRegistry/proc/register
- Signature: `datum/SkillActorRegistry/proc/register(datum/SkillActor/actor)`
- Inputs: datum/SkillActor/actor
- Purpose: Register an actor globally.
- Returns: none (implicit).
- Side effects: mutates registry state.

#### datum/SkillActorRegistry/proc/unregister
- Signature: `datum/SkillActorRegistry/proc/unregister(datum/SkillActor/actor)`
- Inputs: datum/SkillActor/actor
- Purpose: Unregister an actor globally.
- Returns: none (implicit).
- Side effects: mutates registry state.

#### datum/SkillActor/proc/tick
- Signature: `datum/SkillActor/proc/tick(delta)`
- Inputs: delta
- Purpose: Update an actor for one engine tick.
- Returns: truthy when still active.
- Side effects: actor-specific.

#### datum/SkillActor/proc/cleanup
- Signature: `datum/SkillActor/proc/cleanup()`
- Inputs: None
- Purpose: Cleanup after actor removal.
- Returns: none (implicit).
- Side effects: actor-specific.
#### datum/SkillEngine/proc/registerLegacySkills
- Signature: `datum/SkillEngine/proc/registerLegacySkills()`
- Inputs: None
- Purpose: Register legacy skill objects into the registry.
- Returns: none (implicit).
- Side effects: mutates registry state.

#### datum/SkillEngine/proc/resolveCategory
- Signature: `datum/SkillEngine/proc/resolveCategory(path, hotbar_type)`
- Inputs: path, hotbar_type
- Purpose: Resolve the category for a skill type.
- Returns: category string.
- Side effects: none expected.

#### datum/SkillEngine/proc/getDefinitionForObj
- Signature: `datum/SkillEngine/proc/getDefinitionForObj(obj/skill_obj)`
- Inputs: obj/skill_obj
- Purpose: Fetch a registered skill definition by object type.
- Returns: datum/SkillDefinition or null.
- Side effects: none expected.

#### datum/SkillEngine/proc/resolveControllerType
- Signature: `datum/SkillEngine/proc/resolveControllerType(path, category)`
- Inputs: path, category
- Purpose: Resolve controller type for a category.
- Returns: controller string.
- Side effects: none expected.

#### datum/SkillEngine/proc/resolveHomingMode
- Signature: `datum/SkillEngine/proc/resolveHomingMode(path, category)`
- Inputs: path, category
- Purpose: Resolve homing mode for a category.
- Returns: homing mode string.
- Side effects: none expected.

#### datum/SkillEngine/proc/resolveHomingMod
- Signature: `datum/SkillEngine/proc/resolveHomingMod(path)`
- Inputs: path
- Purpose: Resolve homing modifier for a skill type.
- Returns: number.
- Side effects: none expected.

#### datum/SkillEngine/proc/resolveControlRange
- Signature: `datum/SkillEngine/proc/resolveControlRange(path, category)`
- Inputs: path, category
- Purpose: Resolve control range for a skill type.
- Returns: number.
- Side effects: none expected.

#### datum/SkillEngine/proc/resolveControlBumps
- Signature: `datum/SkillEngine/proc/resolveControlBumps(path, category)`
- Inputs: path, category
- Purpose: Resolve allowed bump count for guided control.
- Returns: number.
- Side effects: none expected.

#### datum/SkillEngine/proc/resolveControlDelay
- Signature: `datum/SkillEngine/proc/resolveControlDelay(category)`
- Inputs: category
- Purpose: Resolve the 0.5-decisecond non-beam Ki cadence for guided control.
- Returns: number.
- Side effects: none expected.

#### datum/SkillEngine/proc/resolveControlMaxSteps
- Signature: `datum/SkillEngine/proc/resolveControlMaxSteps(path, category)`
- Inputs: path, category
- Purpose: Resolve guided controller max steps for a skill type.
- Returns: number.
- Side effects: none expected.

#### datum/SkillEngine/proc/resolveControlAvoidOwner
- Signature: `datum/SkillEngine/proc/resolveControlAvoidOwner(path, category)`
- Inputs: path, category
- Purpose: Resolve whether guided control should avoid the owner.
- Returns: number (0/1).
- Side effects: none expected.

#### datum/SkillEngine/proc/resolveControlAvoidOwnerChance
- Signature: `datum/SkillEngine/proc/resolveControlAvoidOwnerChance(path, category)`
- Inputs: path, category
- Purpose: Resolve chance for owner-avoid steering.
- Returns: number.
- Side effects: none expected.

#### datum/SkillEngine/proc/resolveControlStopOnDeflect
- Signature: `datum/SkillEngine/proc/resolveControlStopOnDeflect(path, category)`
- Inputs: path, category
- Purpose: Resolve whether guided control stops on deflect.
- Returns: number (0/1).
- Side effects: none expected.

#### datum/SkillEngine/proc/applyHomingSettings
- Signature: `datum/SkillEngine/proc/applyHomingSettings(mob/user, obj/Blast/blast, datum/SkillDefinition/def, obj/skill_obj)`
- Inputs: mob/user, obj/Blast/blast, datum/SkillDefinition/def, obj/skill_obj
- Purpose: Apply homing settings and bind the user's current explicit target to a blast.
- Returns: none (implicit).
- Side effects: mutates blast homing values.

#### datum/SkillEngine/proc/controlBlast
- Signature: `datum/SkillEngine/proc/controlBlast(mob/user, obj/Blast/blast, obj/skill_obj, datum/SkillDefinition/def)`
- Inputs: mob/user, obj/Blast/blast, obj/skill_obj, datum/SkillDefinition/def
- Purpose: Execute a controller for a guided blast.
- Returns: 1 when handled, else 0.
- Side effects: steps blast movement and may call walk().

#### datum/SkillEngine/proc/castSkill
- Signature: `datum/SkillEngine/proc/castSkill(mob/user, obj/skill_obj)`
- Inputs: mob/user, obj/skill_obj
- Purpose: Route skill activation through the engine.
- Returns: 1 when handled, else 0.
- Side effects: consumes resources and spawns projectiles.

#### datum/SkillEngine/proc/castSokidan
- Signature: `datum/SkillEngine/proc/castSokidan(mob/user, obj/skill_obj)`
- Inputs: mob/user, obj/skill_obj
- Purpose: Execute Sokidan using engine-owned behavior.
- Returns: 1 on success, else 0.
- Side effects: spawns guided blast and updates cooldowns.

#### datum/SkillEngine/proc/castKienzan
- Signature: `datum/SkillEngine/proc/castKienzan(mob/user, obj/skill_obj)`
- Inputs: mob/user, obj/skill_obj
- Purpose: Execute Kienzan using engine-owned behavior.
- Returns: 1 on success, else 0.
- Side effects: spawns guided blast and handles control loop.

#### datum/SkillEngine/proc/isBeamSkill
- Signature: `datum/SkillEngine/proc/isBeamSkill(path)`
- Inputs: path
- Purpose: Identify every attack whose declared `hotbar_type` is `Beam`, including legacy and future beam types.
- Returns: 1 when beam type, else 0.
- Side effects: none expected.

#### datum/SkillEngine/proc/castBeam
- Signature: `datum/SkillEngine/proc/castBeam(mob/user, obj/Attacks/skill_obj)`
- Inputs: mob/user, obj/Attacks/skill_obj
- Purpose: Execute beam charge/stream/stop flow via engine.
- Returns: 1 on success, else 0.
- Side effects: drains Ki and spawns beam segments.

#### datum/SkillEngine/proc/castBlast
- Signature: `datum/SkillEngine/proc/castBlast(mob/user, obj/Attacks/Blast/skill_obj)`
- Inputs: mob/user, obj/Attacks/Blast/skill_obj
- Purpose: Fire basic blast patterns using engine logic and attach a cached, colored light source to each projectile.
- Returns: 1 on success, else 0.
- Side effects: drains Ki, spawns luminous blasts, updates refire.

#### datum/SkillEngine/proc/castBigBang
- Signature: `datum/SkillEngine/proc/castBigBang(mob/user, obj/Attacks/Big_Bang_Attack/skill_obj)`
- Inputs: mob/user, obj/Attacks/Big_Bang_Attack/skill_obj
- Purpose: Charge and fire Big Bang Attack.
- Returns: 1 on success, else 0.
- Side effects: spawns blast, plays VFX/SFX.

#### datum/SkillEngine/proc/castCharge
- Signature: `datum/SkillEngine/proc/castCharge(mob/user, obj/Attacks/Charge/skill_obj)`
- Inputs: mob/user, obj/Attacks/Charge/skill_obj
- Purpose: Charge and fire Charge blast.
- Returns: 1 on success, else 0.
- Side effects: spawns blast, plays VFX/SFX.

#### datum/SkillEngine/proc/castCyberCharge
- Signature: `datum/SkillEngine/proc/castCyberCharge(mob/user, obj/Attacks/Cyber_Charge/skill_obj)`
- Inputs: mob/user, obj/Attacks/Cyber_Charge/skill_obj
- Purpose: Execute Cyber Charge attack.
- Returns: 1 on success, else 0.
- Side effects: spawns blast, plays VFX/SFX.

#### datum/SkillEngine/proc/castMakosen
- Signature: `datum/SkillEngine/proc/castMakosen(mob/user, obj/Attacks/Makosen/skill_obj)`
- Inputs: mob/user, obj/Attacks/Makosen/skill_obj
- Purpose: Execute Makosen multi-shot burst.
- Returns: 1 on success, else 0.
- Side effects: spawns multiple blasts and drains Ki.

#### datum/SkillEngine/proc/castScatterShot
- Signature: `datum/SkillEngine/proc/castScatterShot(mob/user, obj/Attacks/Scatter_Shot/skill_obj)`
- Inputs: mob/user, obj/Attacks/Scatter_Shot/skill_obj
- Purpose: Execute Scatter Shot ring-and-collide behavior.
- Returns: 1 on success, else 0.
- Side effects: spawns multiple homing blasts.

#### datum/SkillEngine/proc/castAttackBarrier
- Signature: `datum/SkillEngine/proc/castAttackBarrier(mob/user, obj/Attacks/Attack_Barrier/skill_obj)`
- Inputs: mob/user, obj/Attacks/Attack_Barrier/skill_obj
- Purpose: Toggle Attack Barrier and emit barrier blasts.
- Returns: 1 on success, else 0.
- Side effects: spawns orbiting blasts and drains Ki.

#### datum/SkillEngine/proc/castShockwave
- Signature: `datum/SkillEngine/proc/castShockwave(mob/user, obj/Attacks/Shockwave/skill_obj)`
- Inputs: mob/user, obj/Attacks/Shockwave/skill_obj
- Purpose: Emit shockwave knockback and damage.
- Returns: 1 on success, else 0.
- Side effects: applies AoE damage/knockback and VFX.

#### datum/SkillEngine/proc/toggleExplosion
- Signature: `datum/SkillEngine/proc/toggleExplosion(mob/user, obj/Attacks/Explosion/skill_obj)`
- Inputs: mob/user, obj/Attacks/Explosion/skill_obj
- Purpose: Toggle Explosion click-cast mode.
- Returns: 1 on success, else 0.
- Side effects: updates skill state and notifies player.

#### datum/SkillEngine/proc/handleExplosionClick
- Signature: `datum/SkillEngine/proc/handleExplosionClick(mob/user, turf/target, obj/Attacks/Explosion/skill_obj)`
- Inputs: mob/user, turf/target, obj/Attacks/Explosion/skill_obj
- Purpose: Resolve Explosion ground-click behavior.
- Returns: 1 when explosion triggers, else 0.
- Side effects: spawns VFX, damages mobs/objects, drains Ki.

#### datum/SkillEngine/proc/castGenkiDama
- Signature: `datum/SkillEngine/proc/castGenkiDama(mob/user, obj/Attacks/Genki_Dama/skill_obj)`
- Inputs: mob/user, obj/Attacks/Genki_Dama/skill_obj
- Purpose: Execute Genki Dama family casting flow.
- Returns: 1 on success, else 0.
- Side effects: spawns and controls bomb blasts.

#### datum/SkillEngine/proc/castKikoho
- Signature: `datum/SkillEngine/proc/castKikoho(mob/user, obj/Attacks/Kikoho/skill_obj)`
- Inputs: mob/user, obj/Attacks/Kikoho/skill_obj
- Purpose: Execute Kikoho charge and hit logic.
- Returns: 1 on success, else 0.
- Side effects: applies damage, stun, and VFX.

#### datum/SkillEngine/proc/castDashAttack
- Signature: `datum/SkillEngine/proc/castDashAttack(mob/user, obj/Dash_Attack/skill_obj)`
- Inputs: mob/user, obj/Dash_Attack/skill_obj
- Purpose: Execute Dash Attack rush behavior while granting only the skill-controlled movement loop permission to bypass the attack movement lock.
- Returns: 1 on success, else 0.
- Side effects: moves user, applies melee damage and knockback.

#### datum/SkillEngine/proc/castWolfFangFist
- Signature: `datum/SkillEngine/proc/castWolfFangFist(mob/user, obj/WolfFangFist/skill_obj)`
- Inputs: mob/user, obj/WolfFangFist/skill_obj
- Purpose: Execute five advancing strikes, each dealing 0.8x melee damage and three-tile knockback.
- Returns: 1 on success, else 0.
- Side effects: advances after each landed hit, applies multi-hit melee damage, knockback, and VFX.

#### datum/SkillEngine/proc/castDropkick
- Signature: `datum/SkillEngine/proc/castDropkick(mob/user, obj/Dropkick/skill_obj)`
- Inputs: mob/user, obj/Dropkick/skill_obj
- Purpose: Execute Dropkick lunge attack.
- Returns: 1 on success, else 0.
- Side effects: applies heavy melee damage and stun.

#### datum/SkillEngine/proc/castShield
- Signature: `datum/SkillEngine/proc/castShield(mob/user, obj/Shield/skill_obj)`
- Inputs: mob/user, obj/Shield/skill_obj
- Purpose: Toggle the ki shield on/off via engine.
- Returns: 1 on success, else 0.
- Side effects: mutates shield state and overlays.

#### datum/SkillEngine/proc/castSolarFlare
- Signature: `datum/SkillEngine/proc/castSolarFlare(mob/user, obj/Taiyoken/skill_obj)`
- Inputs: mob/user, obj/Taiyoken/skill_obj
- Purpose: Execute Solar Flare effect sequence.
- Returns: 1 on success, else 0.
- Side effects: blinds nearby clients and plays VFX.

#### datum/SkillEngine/proc/castFinalExplosion
- Signature: `datum/SkillEngine/proc/castFinalExplosion(mob/user, obj/Final_Explosion/skill_obj)`
- Inputs: mob/user, obj/Final_Explosion/skill_obj
- Purpose: Toggle/execute Final Explosion charge and detonate.
- Returns: 1 on success, else 0.
- Side effects: drains energy, spawns VFX, deals AoE damage.

### src/Code/Application/Combat/SkillControllers.dm

#### datum/SkillControllerRegistry/proc/register
- Signature: `datum/SkillControllerRegistry/proc/register(datum/SkillController/controller)`
- Inputs: datum/SkillController/controller
- Purpose: Register a controller by id.
- Returns: none (implicit).
- Side effects: mutates registry state.

#### datum/SkillControllerRegistry/proc/get
- Signature: `datum/SkillControllerRegistry/proc/get(id)`
- Inputs: id
- Purpose: Fetch a controller by id.
- Returns: datum/SkillController or null.
- Side effects: none expected.

#### datum/SkillController/proc/execute
- Signature: `datum/SkillController/proc/execute(mob/user, obj/Blast/blast, datum/SkillDefinition/def, obj/source_skill)`
- Inputs: mob/user, obj/Blast/blast, datum/SkillDefinition/def, obj/source_skill
- Purpose: Execute controller-specific movement logic.
- Returns: none (implicit).
- Side effects: varies by controller.

#### datum/SkillController/GuidedBlast/proc/execute
- Signature: `datum/SkillController/GuidedBlast/proc/execute(mob/user, obj/Blast/blast, datum/SkillDefinition/def, obj/source_skill)`
- Inputs: mob/user, obj/Blast/blast, datum/SkillDefinition/def, obj/source_skill
- Purpose: Apply Sokidan-style guided control using the blast's vector speed and normalized Ki cadence.
- Returns: none (implicit).
- Side effects: steps blast movement and may delete it.

#### datum/SkillController/GuidedBlast/proc/getControlDirection
- Signature: `datum/SkillController/GuidedBlast/proc/getControlDirection(mob/user)`
- Inputs: controlling mob.
- Purpose: Resolve one valid eight-way direction shared by collision prediction and movement, with facing as fallback.
- Returns: BYOND direction constant.
- Side effects: none expected.

#### datum/SkillController/GuidedBomb/proc/execute
- Signature: `datum/SkillController/GuidedBomb/proc/execute(mob/user, obj/Blast/blast, datum/SkillDefinition/def, obj/source_skill)`
- Inputs: mob/user, obj/Blast/blast, datum/SkillDefinition/def, obj/source_skill
- Purpose: Apply Genki Dama-style guided control to a blast.
- Returns: none (implicit).
- Side effects: steps blast movement and may force detonation.

#### datum/SkillEngine/proc/resolveBehavior
- Signature: `datum/SkillEngine/proc/resolveBehavior(category)`
- Inputs: category
- Purpose: Resolve behavior type for a category.
- Returns: behavior string.
- Side effects: none expected.

#### datum/SkillEngine/proc/resolveMovement
- Signature: `datum/SkillEngine/proc/resolveMovement(category)`
- Inputs: category
- Purpose: Resolve movement type for a category.
- Returns: movement string.
- Side effects: none expected.

#### datum/SkillEngine/proc/resolveSizeClass
- Signature: `datum/SkillEngine/proc/resolveSizeClass(category)`
- Inputs: category
- Purpose: Resolve size class for a category.
- Returns: size string.
- Side effects: none expected.

#### datum/SkillEngine/proc/resolveControlMode
- Signature: `datum/SkillEngine/proc/resolveControlMode(category)`
- Inputs: category
- Purpose: Resolve control mode for a category.
- Returns: control string.
- Side effects: none expected.

#### datum/SkillEngine/proc/resolveIcon
- Signature: `datum/SkillEngine/proc/resolveIcon(path)`
- Inputs: path
- Purpose: Resolve the skill icon asset for a type.
- Returns: icon reference or null.
- Side effects: none expected.

#### datum/SkillEngine/proc/resolveDamage
- Signature: `datum/SkillEngine/proc/resolveDamage(path)`
- Inputs: path
- Purpose: Resolve base damage for a skill type.
- Returns: number.
- Side effects: none expected.

#### datum/SkillEngine/proc/resolveDamageAdd
- Signature: `datum/SkillEngine/proc/resolveDamageAdd(path)`
- Inputs: path
- Purpose: Resolve per-charge damage add for a skill type.
- Returns: number.
- Side effects: none expected.

#### datum/SkillEngine/proc/resolveMaxCharge
- Signature: `datum/SkillEngine/proc/resolveMaxCharge(path)`
- Inputs: path
- Purpose: Resolve max charge sizing/value for a skill type.
- Returns: number.
- Side effects: none expected.

#### datum/SkillEngine/proc/resolveChargeTime
- Signature: `datum/SkillEngine/proc/resolveChargeTime(path)`
- Inputs: path
- Purpose: Resolve charge time for a skill type.
- Returns: number.
- Side effects: none expected.

### src/Code/Combat/BleedDamage.dm

#### mob/proc/BleedDamage
- Signature: `BleedDamage(n = 0, mob/attacker, attack_name = "Bleed")`
- Inputs: queued bleed amount plus optional source and attack attribution.
- Purpose: Start the bleed loop while retaining combat-log attribution.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BleedLoop
- Signature: `BleedLoop()`
- Inputs: None
- Purpose: Handle bleed loop.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/CombatDummy.dm

#### mob/CombatDummy/New
- Signature: `New()`
- Inputs: None.
- Purpose: Initialize a passive, nonpersistent humanoid combat target and its overhead health HUD.
- Returns: initialized dummy.
- Side effects: attaches one overhead HUD object.

#### mob/CombatDummy/Del
- Signature: `Del()`
- Inputs: None.
- Purpose: Release the dummy's overhead HUD before deletion.
- Returns: parent deletion result.
- Side effects: deletes the attached visual object.

#### mob/CombatDummy/proc/setBattlePower
- Signature: `setBattlePower(value)`
- Inputs: desired base battle power.
- Purpose: Set base and effective BP while preserving the configured powerup percentage.
- Returns: none (implicit).
- Side effects: changes dummy combat power.

#### mob/CombatDummy/proc/setPowerup
- Signature: `setPowerup(value)`
- Inputs: desired powerup percentage; values above 100 are valid.
- Purpose: Set `BPpcnt` and recalculate effective BP.
- Returns: none (implicit).
- Side effects: changes dummy combat power.

#### mob/CombatDummy/proc/resetCombatDummy
- Signature: `resetCombatDummy()`
- Inputs: None.
- Purpose: Restore health, Energy, stamina, movement, and defeat state.
- Returns: none (implicit).
- Side effects: refreshes the overhead health HUD.

#### mob/Admin2/verb/spawnCombatDummy
- Signature: `spawnCombatDummy()`
- Inputs: None.
- Purpose: Spawn a combat dummy in front of the admin and immediately open its controller.
- Returns: none (implicit).
- Side effects: creates a nonsavable mob and writes an admin audit entry.

#### mob/Admin2/verb/controlCombatDummy
- Signature: `controlCombatDummy(mob/CombatDummy/dummy in world)`
- Inputs: an existing combat dummy.
- Purpose: Reopen the selected dummy's controller.
- Returns: none (implicit).
- Side effects: opens interactive prompts.

#### mob/proc/openCombatDummyController
- Signature: `openCombatDummyController(mob/CombatDummy/dummy)`
- Inputs: dummy to configure.
- Purpose: Configure BP, seven combat stats, health, Energy, stamina, powerup, name, restoration, or deletion.
- Returns: none (implicit).
- Side effects: validates Admin2 access and audits every mutation.

### src/Code/Combat/Buffs.dm

#### mob/proc/Buff_Drain_Loop
- Signature: `mob/proc/Buff_Drain_Loop()`
- Inputs: None
- Purpose: Handle buff drain loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/buffed
- Signature: `mob/proc/buffed()`
- Inputs: None
- Purpose: Handle buffed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/buffed_with_bp
- Signature: `mob/proc/buffed_with_bp()`
- Inputs: None
- Purpose: Handle buffed with bp.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Buff/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Buff/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Buff
- Signature: `verb/Buff()`
- Inputs: None
- Purpose: Handle buff.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Buff_Options
- Signature: `verb/Buff_Options()`
- Inputs: None
- Purpose: Handle buff options.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Buffless_recovery
- Signature: `Buffless_recovery()`
- Inputs: None
- Purpose: Handle buffless recovery.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BufflessKiMod
- Signature: `BufflessKiMod()`
- Inputs: None
- Purpose: Handle buffless ki mod.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Buff_Enable
- Signature: `Buff_Enable(obj/Buff/O) if(!O.being_edited&&!Redoing_Stats)`
- Inputs: obj/Buff/O
- Purpose: Handle buff enable.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Rebuff_timer_countdown
- Signature: `Rebuff_timer_countdown()`
- Inputs: None
- Purpose: Handle rebuff timer countdown.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Buff_Disable
- Signature: `Buff_Disable(obj/Buff/O) if(O&&O.suffix)`
- Inputs: obj/Buff/O
- Purpose: Handle buff disable.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/buff_point
- Signature: `mob/verb/buff_point(posneg as text, buff_stat as text) //posneg = "-1" | "1". verb called thru skin`
- Inputs: posneg as text, buff_stat as text
- Purpose: Handle buff point.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/buff_done
- Signature: `mob/verb/buff_done() //verb called thru skin`
- Inputs: None
- Purpose: Handle buff done.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Refresh_Buff_Window
- Signature: `mob/proc/Refresh_Buff_Window(obj/Buff/B) if(client)`
- Inputs: obj/Buff/B
- Purpose: Handle refresh buff window.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Trans_Graphics
- Signature: `Trans_Graphics(list/L) if(L) for(var/V in L)`
- Inputs: list/L
- Purpose: Handle trans graphics.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Add_Trans_Effects
- Signature: `Add_Trans_Effects(list/L)`
- Inputs: list/L
- Purpose: Add Trans Effects.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Remove_Trans_Effects
- Signature: `Remove_Trans_Effects(list/L)`
- Inputs: list/L
- Purpose: Remove Trans Effects.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/Combat/Evasion.dm

#### mob/verb/Evade
- Signature: `Evade()`
- Inputs: None
- Purpose: Handle evade.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Delay_between_double_tap_dashes
- Signature: `Delay_between_double_tap_dashes()`
- Inputs: None
- Purpose: Handle delay between double tap dashes.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Dash_Evade
- Signature: `Dash_Evade(d,from_double_tap)`
- Inputs: d, from_double_tap
- Purpose: Handle dash evade.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Evade_meter_refill_loop
- Signature: `Evade_meter_refill_loop()`
- Inputs: None
- Purpose: Handle evade meter refill loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Drain_evade_meter
- Signature: `Drain_evade_meter(mob/m, mult=1, is_melee=1) //is_melee determines if wearing a sword affects evasion`
- Inputs: mob/m, mult=1, is_melee=1
- Purpose: Handle drain evade meter.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Fill_evade_meter
- Signature: `Fill_evade_meter(mob/m,mult)`
- Inputs: mob/m, mult
- Purpose: Handle fill evade meter.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Evade_meter_requirement
- Signature: `Evade_meter_requirement(mob/m, mult=1, is_melee=1)`
- Inputs: mob/m, mult=1, is_melee=1
- Purpose: Handle evade meter requirement.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Evade_lunge
- Signature: `Evade_lunge(mob/m,dir_override,from_double_tap)`
- Inputs: mob/m, dir_override, from_double_tap
- Purpose: Handle evade lunge.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Start_evading
- Signature: `Start_evading()`
- Inputs: None
- Purpose: Start evading.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Start_blocking
- Signature: `Start_blocking()`
- Inputs: None
- Purpose: Start blocking.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Get_idle_state
- Signature: `Get_idle_state()`
- Inputs: None
- Purpose: Return idle state.
- Returns: computed value (see implementation).
- Side effects: none expected.

### src/Code/Combat/HokutoShinken.dm

#### obj/Hokuto_Shinken/New
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

#### verb/Hundred_Crack_Fist
- Signature: `verb/Hundred_Crack_Fist()`
- Inputs: None
- Purpose: Execute at least 24 rapid 0.45x melee attacks without an execution or user-KO outcome.
- Returns: none (implicit).
- Side effects: warps between eligible targets, applies ordinary cumulative damage, and spends most remaining Ki.

#### mob/proc/hundredCrackFistHit
- Signature: `mob/proc/hundredCrackFistHit(mob/target)`
- Inputs: eligible target.
- Purpose: Roll and apply one 0.45x melee strike in the Hundred Crack Fist sequence.
- Returns: 1 on hit, otherwise 0.
- Side effects: applies damage, opponent state, attack animation, and sound.

#### mob/proc/Hokuto_Shinken_Effects
- Signature: `mob/proc/Hokuto_Shinken_Effects(mob/P)`
- Inputs: mob/P
- Purpose: Remove obsolete legacy Hokuto markers without killing either combatant.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Add_Hokuto_Shinken_Energy
- Signature: `mob/proc/Add_Hokuto_Shinken_Energy(mob/P) if(ismob(P)) if(!(locate(/obj/Hokuto_Shinken_Energy) in P))`
- Inputs: mob/P
- Purpose: Add Hokuto Shinken Energy.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/Combat/Injuries.dm

#### mob/verb/Injure
- Signature: `mob/verb/Injure()`
- Inputs: None
- Purpose: Handle injure.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Injury_Options
- Signature: `Injury_Options(mob/P)`
- Inputs: mob/P
- Purpose: Handle injury options.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Inflict_Injury
- Signature: `Inflict_Injury(mob/P,obj/Injuries/I)`
- Inputs: mob/P, obj/Injuries/I
- Purpose: Handle inflict injury.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Add_Injury_Overlays
- Signature: `mob/proc/Add_Injury_Overlays()`
- Inputs: None
- Purpose: Add Injury Overlays.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Blood_Color
- Signature: `mob/proc/Blood_Color()`
- Inputs: None
- Purpose: Handle blood color.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Injuries/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Injuries/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/KiSkills/DeathBall2017.dm

#### obj/Attacks/Genki_Dama/Death_Ball/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Attacks/Genki_Dama/Death_Ball/Hotbar_use
- Signature: `Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Death_Ball
- Signature: `verb/Death_Ball()`
- Inputs: None
- Purpose: Handle death ball.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/KiSkills/FinalExplosion.dm

#### mob/proc/FinalExplosionFollowOnMove
- Signature: `mob/proc/FinalExplosionFollowOnMove()`
- Inputs: None
- Purpose: Handle final explosion follow on move.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Final_Explosion/verb/Hotbar_use
- Signature: `Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Final_Explosion/verb/Final_Explosion
- Signature: `Final_Explosion()`
- Inputs: None
- Purpose: Handle final explosion.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Final_Explosion
- Signature: `Final_Explosion()`
- Inputs: None
- Purpose: Handle final explosion.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DoFinalExplosion
- Signature: `DoFinalExplosion()`
- Inputs: None
- Purpose: Perform Final Explosion.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BeginChargingFinalExplosion
- Signature: `BeginChargingFinalExplosion()`
- Inputs: None
- Purpose: Begin Final Explosion charging and grow a warm, flickering action light alongside its visual power.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FinalExplosionDamage
- Signature: `FinalExplosionDamage()`
- Inputs: None
- Purpose: Handle final explosion damage.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FinalExplosionChargeupGraphics
- Signature: `FinalExplosionChargeupGraphics()`
- Inputs: None
- Purpose: Create the charge effect with an attached warm gradient light that follows the character.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FinalExplosionGraphics
- Signature: `FinalExplosionGraphics()`
- Inputs: None
- Purpose: Expand the Final Explosion effect and its light together, capped at the lighting system's twelve-tile testable range.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/FinalExplosionDamage
- Signature: `FinalExplosionDamage(mob/user, dmg_percent = 0, wait_time = 0, wall_break_power = 1, user_bp = 1, user_force = 1)`
- Inputs: mob/user, dmg_percent = 0, wait_time = 0, wall_break_power = 1, user_bp = 1, user_force = 1
- Purpose: Handle final explosion damage.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ShieldDamageReduction
- Signature: `ShieldDamageReduction()`
- Inputs: None
- Purpose: Handle shield damage reduction.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/KiSkills/FusionSystem.dm

#### obj/Fusion_Dance/verb/Fusion_Dance
- Signature: `Fusion_Dance(var/mob/M in orange(usr,1))`
- Inputs: var/mob/M in orange(usr, 1
- Purpose: Handle fusion dance.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Potara/verb/Throw_Potara
- Signature: `Throw_Potara(var/mob/M in player_view(usr,15))`
- Inputs: var/mob/M in player_view(usr, 15
- Purpose: Handle throw potara.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Fusion_Proc
- Signature: `Fusion_Proc(mob/A,mob/B,var/perm) //perm=0 means dance, perm=1 means potara. A=passive B=in control`
- Inputs: mob/A, mob/B, var/perm
- Purpose: Handle fusion proc.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Unfuse
- Signature: `Unfuse(mob/A)`
- Inputs: mob/A
- Purpose: Handle unfuse.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Splice_Overlays
- Signature: `Splice_Overlays(mob/A,mob/B)`
- Inputs: mob/A, mob/B
- Purpose: Handle splice overlays.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Fusion_Success
- Signature: `Fusion_Success(var/mob/A,var/mob/B)`
- Inputs: var/mob/A, var/mob/B
- Purpose: Handle fusion success.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Learn_Fusion
- Signature: `Learn_Fusion()`
- Inputs: None
- Purpose: Handle learn fusion.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Make_Potara
- Signature: `Make_Potara()`
- Inputs: None
- Purpose: Handle make potara.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/KiSkills/Hakai.dm

#### mob/proc/CanUseHakai
- Signature: `CanUseHakai()`
- Inputs: None
- Purpose: Return whether Use Hakai.
- Returns: boolean flag.
- Side effects: none expected.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hakai
- Signature: `verb/Hakai()`
- Inputs: None
- Purpose: Handle hakai.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BeginHakai
- Signature: `BeginHakai(mob/m)`
- Inputs: mob/m
- Purpose: Handle begin hakai.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/StrongEnoughToHakai
- Signature: `StrongEnoughToHakai(mob/m)`
- Inputs: mob/m
- Purpose: Handle strong enough to hakai.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/CheckHakaiDeleteCharacter
- Signature: `proc/CheckHakaiDeleteCharacter(mob/m)`
- Inputs: mob/m
- Purpose: Delete the victim's active character slot and matching feat progression when Hakai character wiping is enabled.
- Returns: none (implicit).
- Side effects: deletes the live mob and both slot-specific persistence files.

#### proc/HakaiOverlay
- Signature: `proc/HakaiOverlay(mob/m, hakai_time = 50)`
- Inputs: mob/m, hakai_time = 50
- Purpose: Handle hakai overlay.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/KiSkills/Kikoho2016.dm

#### mob/proc/IsValidKikohoTarget
- Signature: `mob/proc/IsValidKikohoTarget(mob/m)`
- Inputs: mob/m
- Purpose: Return whether Valid Kikoho Target.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/GetKikohoTarget
- Signature: `mob/proc/GetKikohoTarget(mob/expected_target)`
- Inputs: optional target captured before charge-up.
- Purpose: Validate only the current explicit target and prevent charge completion from switching victims.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Kikoho
- Signature: `verb/Kikoho()`
- Inputs: None
- Purpose: Handle kikoho.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/KikohoCrater
- Signature: `KikohoCrater(turf/t)`
- Inputs: turf/t
- Purpose: Handle kikoho crater.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/KikohoExplosion
- Signature: `KikohoExplosion(turf/t)`
- Inputs: turf/t
- Purpose: Handle kikoho explosion.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/KikohoDust
- Signature: `KikohoDust(turf/t)`
- Inputs: turf/t
- Purpose: Handle kikoho dust.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/KikohoRocks
- Signature: `KikohoRocks(turf/t)`
- Inputs: turf/t
- Purpose: Handle kikoho rocks.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/StopBeaming
- Signature: `StopBeaming()`
- Inputs: None
- Purpose: Stop Beaming.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/CancelAllAttacks
- Signature: `CancelAllAttacks()`
- Inputs: None
- Purpose: Handle cancel all attacks.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GetHitByKikoho
- Signature: `GetHitByKikoho(mob/a) //a = attacker`
- Inputs: mob/a
- Purpose: Return Hit By Kikoho.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/KikohoKnockAwayNonTargets
- Signature: `KikohoKnockAwayNonTargets(mob/t) //t = target, usr = firer`
- Inputs: mob/t
- Purpose: Handle kikoho knock away non targets.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/KikohoDamageLoop
- Signature: `KikohoDamageLoop()`
- Inputs: None
- Purpose: Handle kikoho damage loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/KikohoDamageTo
- Signature: `KikohoDamageTo(mob/m)`
- Inputs: mob/m
- Purpose: Return centralized Force-versus-Resistance Kikoho damage at factor `7`.
- Returns: percentage damage.
- Side effects: none.

#### mob/proc/FireKikoho
- Signature: `FireKikoho(obj/Attacks/Kikoho/k)`
- Inputs: obj/Attacks/Kikoho/k
- Purpose: Handle fire kikoho.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/KikohoRefire
- Signature: `KikohoRefire(mult = 1)`
- Inputs: mult = 1
- Purpose: Handle kikoho refire.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/KikohoAtmosphereEffect
- Signature: `KikohoAtmosphereEffect()`
- Inputs: None
- Purpose: Handle kikoho atmosphere effect.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/KikohoChargeupEffect
- Signature: `KikohoChargeupEffect(grow_til = 0.5)`
- Inputs: grow_til = 0.5
- Purpose: Handle kikoho chargeup effect.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/KikohoOrangeAtmosphere
- Signature: `KikohoOrangeAtmosphere()`
- Inputs: None
- Purpose: Handle kikoho orange atmosphere.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Crater/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Crater/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Crater/proc/KikohoCraterDeleteCheck
- Signature: `KikohoCraterDeleteCheck()`
- Inputs: None
- Purpose: Handle kikoho crater delete check.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Flash/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Rock/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Rock/proc/KikohoRock
- Signature: `KikohoRock()`
- Inputs: None
- Purpose: Handle kikoho rock.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Rock/proc/KikohoRockFlyOff
- Signature: `KikohoRockFlyOff()`
- Inputs: None
- Purpose: Handle kikoho rock fly off.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Dust/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Dust/proc/KikohoDust
- Signature: `KikohoDust()`
- Inputs: None
- Purpose: Handle kikoho dust.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Explosion/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Kikoho_Effects/Kikoho_Explosion/proc/KikohoExplosion
- Signature: `KikohoExplosion()`
- Inputs: None
- Purpose: Handle kikoho explosion.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/KiSkills/Sense2017/Sense.dm

#### mob/verb/Toggle_Sense_Overlay
- Signature: `mob/verb/Toggle_Sense_Overlay()`
- Inputs: None
- Purpose: Toggle Sense Overlay.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### obj/Screen_Indicator/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Screen_Indicator/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Return the indicator to the bounded Sense cache, or delete it when the retention limit is full.
- Returns: none (implicit).
- Side effects: clears target/location for cached indicators.

#### obj/Screen_Indicator/proc/SenseArrowMatchAppearance
- Signature: `SenseArrowMatchAppearance(update_overlays = 1)`
- Inputs: update_overlays = 1
- Purpose: Handle sense arrow match appearance.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Screen_Indicator/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/removeNexusSenseReadout
- Signature: `removeNexusSenseReadout(mob/target)`
- Purpose: Detach and forget one target's Sense percentage image.

#### mob/proc/ensureNexusSenseReadout
- Signature: `ensureNexusSenseReadout(mob/target)`
- Purpose: Create a target readout only when it is not already registered.

#### mob/proc/syncNexusSenseReadouts
- Signature: `syncNexusSenseReadouts(area/a)`
- Purpose: Incrementally reconcile readout membership instead of destroying and recreating every image.

#### mob/proc/UpdateSenseArrowPositionsLoop
- Signature: `UpdateSenseArrowPositionsLoop()`
- Inputs: None
- Purpose: Update Sense Arrow Positions Loop.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/UpdateSenseArrowPositions
- Signature: `UpdateSenseArrowPositions()`
- Inputs: None
- Purpose: Update Sense Arrow Positions.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/UpdateSenseArrowPosition
- Signature: `UpdateSenseArrowPosition(obj/Screen_Indicator/si, instant_update = 0)`
- Inputs: obj/Screen_Indicator/si, instant_update = 0
- Purpose: Update Sense Arrow Position.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/SenseArrowDistanceMod
- Signature: `SenseArrowDistanceMod(obj/Screen_Indicator/si)`
- Inputs: obj/Screen_Indicator/si
- Purpose: Handle sense arrow distance mod.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/UpdateSenseArrowSizeBasedOnPower
- Signature: `UpdateSenseArrowSizeBasedOnPower(obj/Screen_Indicator/si)`
- Inputs: obj/Screen_Indicator/si
- Purpose: Update Sense Arrow Size Based On Power.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/RemoveSenseArrow
- Signature: `RemoveSenseArrow(obj/Screen_Indicator/si)`
- Inputs: obj/Screen_Indicator/si
- Purpose: Remove Sense Arrow.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/AddSenseArrow
- Signature: `AddSenseArrow(obj/Screen_Indicator/si, clr)`
- Inputs: obj/Screen_Indicator/si, clr
- Purpose: Add Sense Arrow.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/RemoveAllSenseArrows
- Signature: `RemoveAllSenseArrows()`
- Inputs: None
- Purpose: Remove All Sense Arrows.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/UpdateSenseArrowList
- Signature: `UpdateSenseArrowList(area/a)`
- Inputs: area/a
- Purpose: Reconcile Sense arrows and readouts with the current area while preserving indicators for unchanged targets.
- Performance: membership scans run on the slower Sense refresh cadence; frequent visual refreshes only touch existing readouts.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/GetSenseArrowColor
- Signature: `GetSenseArrowColor(mob/m)`
- Inputs: mob/m
- Purpose: Return Sense Arrow Color.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/GetSenseArrowColorByRace
- Signature: `GetSenseArrowColorByRace(race, class)`
- Inputs: race, class
- Purpose: Return Sense Arrow Color By Race.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### area/proc/AreaUpdateSenseTargets
- Signature: `AreaUpdateSenseTargets()`
- Inputs: None
- Purpose: Coalesce area membership changes into a revision increment consumed independently by Sense observers.
- Returns: none (implicit).
- Side effects: increments `sense_target_revision`; it no longer rebuilds every player's indicators in one area-wide pass.

#### proc/GetNewScreenIndicator
- Signature: `GetNewScreenIndicator()`
- Inputs: None
- Purpose: Reuse a reset Sense indicator when available or allocate one when the bounded cache is empty.
- Returns: screen indicator object.
- Side effects: none expected.

### src/Code/Combat/KiSkills/SolarFlare.dm

#### mob/proc/TrySolarFlare
- Signature: `TrySolarFlare()`
- Inputs: None
- Purpose: Handle try solar flare.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanSolarFlare
- Signature: `CanSolarFlare()`
- Inputs: None
- Purpose: Return whether Solar Flare.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/SolarFlare
- Signature: `SolarFlare()`
- Inputs: None
- Purpose: Handle solar flare.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GetSolarFlareRangeMod
- Signature: `GetSolarFlareRangeMod()`
- Inputs: None
- Purpose: Return Solar Flare Range Mod.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/GetSolarFlareAffectees
- Signature: `GetSolarFlareAffectees(dist = 1)`
- Inputs: dist = 1
- Purpose: Return Solar Flare Affectees.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/SolarFlareAffectMobs
- Signature: `SolarFlareAffectMobs(list/mobs, dist = 1)`
- Inputs: list/mobs, dist = 1
- Purpose: Handle solar flare affect mobs.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SolarFlareScreenOverlay
- Signature: `SolarFlareScreenOverlay(mob/a) //a = attacker`
- Inputs: mob/a
- Purpose: Handle solar flare screen overlay.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SolarFlareFX
- Signature: `SolarFlareFX(list/mobs, dist = 1)`
- Inputs: list/mobs, dist = 1
- Purpose: Handle solar flare fx.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SolarFlareHurtVampires
- Signature: `SolarFlareHurtVampires(list/mobs)`
- Inputs: list/mobs
- Purpose: Handle solar flare hurt vampires.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SolarFlareHurtVampire
- Signature: `SolarFlareHurtVampire(mob/m) //m = attacker`
- Inputs: mob/m
- Purpose: Handle solar flare hurt vampire.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/KiSkills/SpiritBomb2016.dm

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Genki_Dama
- Signature: `verb/Genki_Dama()`
- Inputs: None
- Purpose: Handle genki dama.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Blast/Genki_Dama/proc/SpiritBombGoOffSomewhere
- Signature: `SpiritBombGoOffSomewhere()`
- Inputs: None
- Purpose: Handle spirit bomb go off somewhere.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombSpawnLoc
- Signature: `SpiritBombSpawnLoc(y_offset = 6)`
- Inputs: y_offset = 6
- Purpose: Handle spirit bomb spawn loc.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanSpiritBomb
- Signature: `CanSpiritBomb(why = 0, obj/Attacks/Genki_Dama/sb)`
- Inputs: why = 0, obj/Attacks/Genki_Dama/sb
- Purpose: Return whether Spirit Bomb.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/TrySpiritBomb2017
- Signature: `TrySpiritBomb2017(obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Attacks/Genki_Dama/sb
- Purpose: Handle try spirit bomb2017.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBomb2017
- Signature: `SpiritBomb2017(obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Attacks/Genki_Dama/sb
- Purpose: Handle spirit bomb2017.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombThrow
- Signature: `SpiritBombThrow(obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Attacks/Genki_Dama/sb
- Purpose: Handle spirit bomb throw.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombGuidedMovement
- Signature: `SpiritBombGuidedMovement()`
- Inputs: None
- Purpose: Handle spirit bomb guided movement.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/LastSpiritBombValid
- Signature: `LastSpiritBombValid()`
- Inputs: None
- Purpose: Handle last spirit bomb valid.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombBegin
- Signature: `SpiritBombBegin(obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Attacks/Genki_Dama/sb
- Purpose: Begin Spirit Bomb construction, attach the caster's charge light, and create the attack projectile whose own light grows through its automatic size profile.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombEnergyParticlesGatherLoop
- Signature: `SpiritBombEnergyParticlesGatherLoop(obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb
- Purpose: Handle spirit bomb energy particles gather loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DoSomeSpiritBombParticles
- Signature: `DoSomeSpiritBombParticles(obj/particle, turf/dest, amount = 5, list/from)`
- Inputs: obj/particle, turf/dest, amount = 5, list/from
- Purpose: Perform Some Spirit Bomb Particles.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombSizeGrow
- Signature: `SpiritBombSizeGrow(obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb
- Purpose: Handle spirit bomb size grow.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombSpin
- Signature: `SpiritBombSpin(obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb
- Purpose: Handle spirit bomb spin.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombInterrupted
- Signature: `SpiritBombInterrupted()`
- Inputs: None
- Purpose: Handle spirit bomb interrupted.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombInterrupt
- Signature: `SpiritBombInterrupt(obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb
- Purpose: Handle spirit bomb interrupt.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombDone
- Signature: `SpiritBombDone(obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Attacks/Genki_Dama/sb
- Purpose: End Spirit Bomb charging state and clear the caster's temporary action light.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombChargeTime
- Signature: `SpiritBombChargeTime(obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Attacks/Genki_Dama/sb
- Purpose: Handle spirit bomb charge time.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SpiritBombPowerGrow
- Signature: `SpiritBombPowerGrow(obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb)`
- Inputs: obj/Blast/Genki_Dama/b, obj/Attacks/Genki_Dama/sb
- Purpose: Handle spirit bomb power grow.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/KiSkills/Supernova.dm

#### obj/Attacks/Genki_Dama/Supernova/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Attacks/Genki_Dama/Supernova/Hotbar_use
- Signature: `Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Supernova
- Signature: `verb/Supernova()`
- Inputs: None
- Purpose: Handle supernova.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Math/CombatMath.dm

#### proc/AccuracyFormula
- Signature: `proc/AccuracyFormula(mob/Offender,mob/Defender,KiManip=0,Chance=WorldDefaultAcc)`
- Inputs: mob/Offender, mob/Defender, KiManip=0, Chance=WorldDefaultAcc
- Purpose: Handle accuracy formula.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DamageFormula
- Signature: `proc/DamageFormula(mob/Offender,mob/Defender,Strength=1,Force=0,Speed=0,Offense=0,DamageType="Physical",BaselineDamage=2,FlatDamage=0,UsesWeapon=1,IgnoresEnd=0)`
- Inputs: mob/Offender, mob/Defender, Strength=1, Force=0, Speed=0, Offense=0, DamageType="Physical", BaselineDamage=2, FlatDamage=0, UsesWeapon=1, IgnoresEnd=0
- Purpose: Handle damage formula.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/KiDamageFormula
- Signature: `proc/KiDamageFormula(mob/Offender,mob/Defender,Strength=1,Force=0,Speed=0,Offense=0,DamageType="Physical",BaselineDamage=3,FlatDamage=0,UsesWeapon=1,IgnoresEnd=0)`
- Inputs: mob/Offender, mob/Defender, Strength=1, Force=0, Speed=0, Offense=0, DamageType="Physical", BaselineDamage=3, FlatDamage=0, UsesWeapon=1, IgnoresEnd=0
- Purpose: Handle ki damage formula.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Knockback
- Signature: `mob/proc/Knockback(Distance,mob/P,Direction=get_dir(P,src),KB_Damage=1) spawn if(src)//Some abilities won't damage upon KB`
- Inputs: Distance, mob/P, Direction=get_dir(P, src
- Purpose: Handle knockback.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/DamageScaling.dm

#### proc/calculateScaledCombatDamage
- Signature: `proc/calculateScaledCombatDamage(factor = 0, attacker_bp = 0, defender_bp = 0, source_stat = 0, guard_stat = 0)`
- Inputs: parity damage factor, attacker/defender BP, and relevant offensive/defensive stats.
- Purpose: Apply the shared linear `BP ratio * (2*source/(source+guard))^0.85` curve. Equal-power damage is unchanged, while a 65x BP advantage turns a factor-3 standard beam into 195 raw damage before incoming racial modifiers.
- Returns: scaled percentage damage, or zero for a nonpositive factor, BP, or source stat.
- Side effects: none.

#### mob/proc/getPhysicalCombatDamage
- Signature: `mob/proc/getPhysicalCombatDamage(mob/target, factor = 0)`
- Forged armor contributes its material-specific BP reinforcement to the target's Endurance-side BP calculation.
- Inputs: target and parity factor.
- Purpose: Scale physical damage from Strength against Endurance.
- Returns: percentage damage.
- Side effects: none.

#### mob/proc/getKiCombatDamage
- Signature: `mob/proc/getKiCombatDamage(mob/target, factor = 0)`
- Inputs: target and parity factor.
- Purpose: Scale Ki damage from Force against Resistance.
- Returns: percentage damage.
- Side effects: none.

#### mob/proc/getHybridCombatDamage
- Signature: `mob/proc/getHybridCombatDamage(mob/target, factor = 0)`
- Inputs: target and total parity factor.
- Purpose: Split a factor evenly between physical and Ki scaling.
- Returns: combined percentage damage.
- Side effects: none.

#### datum/CombatDamageBudget/proc/reserveFactor
- Signature: `datum/CombatDamageBudget/proc/reserveFactor(mob/target, requested_factor = 0)`
- Inputs: target and requested parity factor.
- Purpose: Enforce a shared per-target cast budget across projectiles, beam ticks, impact and splash.
- Returns: the factor still available to the event.
- Side effects: records consumed factor for the target.

### src/Code/Combat/Melee.dm

#### mob/proc/GetSpeedDamageDecrease
- Signature: `mob/proc/GetSpeedDamageDecrease()`
- Inputs: None
- Purpose: Normalize per-hit melee damage so the `100 -> 200` Speed range produces about `1.35x`, rather than `2.327x`, sustained DPS.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Opponent
- Signature: `mob/proc/Opponent(timeLimit = 65)`
- Inputs: timeLimit = 65
- Purpose: Handle opponent.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/setOpponent
- Signature: `mob/proc/setOpponent(mob/M)`
- Inputs: mob/M
- Purpose: Set Opponent.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/ShouldMeleeInjureSelf
- Signature: `ShouldMeleeInjureSelf(mob/m)`
- Inputs: mob/m
- Purpose: Handle should melee injure self.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MeleeInjureSelfCheck
- Signature: `MeleeInjureSelfCheck(mob/m)`
- Inputs: mob/m
- Purpose: Handle melee injure self check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MeleeInjureSelf
- Signature: `MeleeInjureSelf()`
- Inputs: None
- Purpose: Handle melee injure self.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MeleeInjury2017
- Signature: `MeleeInjury2017()`
- Inputs: None
- Purpose: Handle melee injury2017.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GetArmOrLegInjury
- Signature: `proc/GetArmOrLegInjury()`
- Inputs: None
- Purpose: Return Arm Or Leg Injury.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/AllAttacksDamageModifiers
- Signature: `mob/proc/AllAttacksDamageModifiers(mob/target) //target = who you are attacking`
- Inputs: mob/target
- Purpose: Handle all attacks damage modifiers.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/TakeDamage
- Signature: `mob/proc/TakeDamage(dmg = 0, stun_damage_mod = 0.6, knockback = 0, mob/attacker, attack_name)`
- Inputs: raw damage, stun modifier, knockback metadata, optional attacker, and attack label.
- Purpose: Apply racial/stun modifiers and Health or shield damage, then publish the actual applied damage to the combat feed when attribution is available.
- Returns: applied Health damage, or zero when no Health was removed.
- Side effects: records lethal-combat pressure for both fighters when the attacker uses Lethal intent, then updates anger, damage indicators, overhead vitals, and batched combat logs.

#### mob/proc/PowerupDamageGrabber
- Signature: `mob/proc/PowerupDamageGrabber(n = 1) //multiply by n for "damage per second" regardless of call rate`
- Inputs: n = 1
- Purpose: Handle powerup damage grabber.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Fill_power_attack_meter
- Signature: `Fill_power_attack_meter()`
- Inputs: None
- Purpose: Handle fill power attack meter.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Can_power_attack
- Signature: `Can_power_attack()`
- Inputs: None
- Purpose: Return whether power attack.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Power_attack_chargeup_time
- Signature: `Power_attack_chargeup_time(mob/m)`
- Inputs: mob/m
- Purpose: Handle power attack chargeup time.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Trying_to_power_attack
- Signature: `Trying_to_power_attack()`
- Inputs: None
- Purpose: Handle trying to power attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_lunge_drawback_graphic
- Signature: `proc/Get_lunge_drawback_graphic()`
- Inputs: None
- Purpose: Return lunge drawback graphic.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### obj/Lunge_Graphic/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Lunge_Graphic/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Lunge_stick_to
- Signature: `proc/Lunge_stick_to(mob/center)`
- Inputs: mob/center
- Purpose: Handle lunge stick to.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Lunge_go
- Signature: `proc/Lunge_go(mob/center)`
- Inputs: mob/center
- Purpose: Handle lunge go.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Can_lunge
- Signature: `mob/proc/Can_lunge()`
- Inputs: None
- Purpose: Return whether lunge.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Lunge_refire
- Signature: `mob/proc/Lunge_refire()`
- Inputs: None
- Purpose: Handle lunge refire.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Lunge_toward
- Signature: `mob/proc/Lunge_toward(mob/m)`
- Inputs: mob/m
- Purpose: Handle lunge toward.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Lunge_step_delay
- Signature: `mob/proc/Lunge_step_delay()`
- Inputs: None
- Purpose: Handle lunge step delay.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Mob_in_front
- Signature: `mob/proc/Mob_in_front()`
- Inputs: None
- Purpose: Handle mob in front.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Cancel_lunge
- Signature: `mob/proc/Cancel_lunge()`
- Inputs: None
- Purpose: Handle cancel lunge.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Do_lunge_drawback_animation
- Signature: `mob/proc/Do_lunge_drawback_animation()`
- Inputs: None
- Purpose: Perform lunge drawback animation.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Get_lunge_distance
- Signature: `mob/proc/Get_lunge_distance()`
- Inputs: None
- Purpose: Return lunge distance.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Get_lunge_targeting_distance
- Signature: `mob/proc/Get_lunge_targeting_distance()`
- Inputs: None
- Purpose: Return lunge targeting distance.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### atom/movable/proc/At_forward_half
- Signature: `atom/movable/proc/At_forward_half(mob/m)`
- Inputs: mob/m
- Purpose: Handle at forward half.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/find_melee_target
- Signature: `mob/proc/find_melee_target(mob/O,from_auto_attack)`
- Inputs: mob/O, from_auto_attack
- Purpose: Handle find melee target.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Defense_damage_reduction
- Signature: `proc/Defense_damage_reduction(mob/attacker,mob/defender)`
- Inputs: mob/attacker, mob/defender
- Purpose: Legacy helper retained for compatibility; balanced damage paths do not call it because Offense and Defense affect hit outcomes only.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/get_melee_damage
- Signature: `mob/proc/get_melee_damage(mob/m, count_sword = 1, for_strangle, allow_one_shot = 1, swordMod = 1)`
- Inputs: mob/m, count_sword = 1, for_strangle, allow_one_shot = 1, swordMod = 1
- Purpose: Return centralized Strength-versus-Endurance melee damage with explicit factors (`2.5` basic and `5` Lunge), bounded speed normalization, and capped rear/critical bonuses.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/verb/ToggleBreakingThings
- Signature: `mob/verb/ToggleBreakingThings()`
- Inputs: None
- Purpose: Toggle Breaking Things.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/verb/ToggleSparringMode
- Signature: `mob/verb/ToggleSparringMode()`
- Inputs: None
- Purpose: Toggle Sparring Mode.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/SetSparringMode
- Signature: `mob/proc/SetSparringMode(mode = sparring_mode, show_message = TRUE)`
- Inputs: mode = sparring_mode, show_message = TRUE
- Purpose: Set Sparring Mode.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/AlertSparringMode
- Signature: `mob/proc/AlertSparringMode(var/mob/attacker, var/mob/victim)`
- Inputs: var/mob/attacker, var/mob/victim
- Purpose: Handle alert sparring mode.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/WallBreakPower
- Signature: `mob/proc/WallBreakPower()`
- Inputs: None
- Purpose: Handle wall break power.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/teststatrating
- Signature: `mob/proc/teststatrating()`
- Inputs: None
- Purpose: Handle teststatrating.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin5/verb/testwallbreakpower
- Signature: `mob/Admin5/verb/testwallbreakpower(mob/m in world)`
- Inputs: mob/m in world
- Purpose: Handle testwallbreakpower.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Is_wall_breaker
- Signature: `mob/proc/Is_wall_breaker()`
- Inputs: None
- Purpose: Return whether wall breaker.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/Admin5/verb/constantMaxSpeed
- Signature: `mob/Admin5/verb/constantMaxSpeed()`
- Inputs: None
- Purpose: Handle constant max speed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/const_max_speed
- Signature: `proc/const_max_speed()`
- Inputs: None
- Purpose: Handle const max speed.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/fight
- Signature: `mob/verb/fight(mob/a in world)`
- Inputs: mob/a in world
- Purpose: Handle fight.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Speed_accuracy_mult
- Signature: `mob/proc/Speed_accuracy_mult(mob/defender)`
- Inputs: mob/defender
- Purpose: Handle speed accuracy mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Acc_mult
- Signature: `proc/Acc_mult(n=1)`
- Inputs: n=1
- Purpose: Handle acc mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DodgeStamCost
- Signature: `mob/proc/DodgeStamCost(mob/attacker)`
- Inputs: mob/attacker
- Purpose: Handle dodge stam cost.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/get_melee_accuracy
- Signature: `mob/proc/get_melee_accuracy(mob/m)`
- Inputs: mob/m
- Purpose: Return melee accuracy.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/GetSkillDrain
- Signature: `mob/proc/GetSkillDrain(mod = 1, is_energy = 0)`
- Inputs: mod = 1, is_energy = 0
- Purpose: Return Skill Drain.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/get_melee_knockback_distance
- Signature: `mob/proc/get_melee_knockback_distance(mob/m)`
- Inputs: mob/m
- Purpose: Return melee knockback distance.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/get_melee_sounds
- Signature: `mob/proc/get_melee_sounds(knockback_dist=0)`
- Inputs: knockback_dist=0
- Purpose: Return melee sounds.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/using_sword
- Signature: `mob/proc/using_sword()`
- Inputs: None
- Purpose: Handle using sword.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/if_target_is_splitform_then_target_attacks_you
- Signature: `mob/proc/if_target_is_splitform_then_target_attacks_you(mob/target)`
- Inputs: mob/target
- Purpose: Handle if target is splitform then target attacks you.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/zombie_melee_infection
- Signature: `mob/proc/zombie_melee_infection(mob/target)`
- Inputs: mob/target
- Purpose: Handle zombie melee infection.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Combo_recharge
- Signature: `mob/proc/Combo_recharge()`
- Inputs: None
- Purpose: Handle combo recharge.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Combo_recharge_time
- Signature: `mob/proc/Combo_recharge_time()`
- Inputs: None
- Purpose: Handle combo recharge time.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Combo_drain
- Signature: `mob/proc/Combo_drain(mob/a,mob/d)`
- Inputs: mob/a, mob/d
- Purpose: Handle combo drain.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/combo_teleport
- Signature: `mob/proc/combo_teleport(mob/m)`
- Inputs: mob/m
- Purpose: Handle combo teleport.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/if_target_is_npc_target_attacks_you
- Signature: `mob/proc/if_target_is_npc_target_attacks_you(mob/target)`
- Inputs: mob/target
- Purpose: Handle if target is npc target attacks you.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Toggle_strangling
- Signature: `mob/proc/Toggle_strangling()`
- Inputs: None
- Purpose: Toggle strangling.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Get_melee_delay
- Signature: `mob/proc/Get_melee_delay(mult=1,injuries_matter=1)`
- Inputs: mult=1, injuries_matter=1
- Purpose: Return melee delay.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Reset_melee
- Signature: `mob/proc/Reset_melee()`
- Inputs: None
- Purpose: Handle reset melee.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MeleeFollowupAttackCheck
- Signature: `mob/proc/MeleeFollowupAttackCheck()`
- Inputs: None
- Purpose: Teleport-follow only when `last_mob_attacked` is still the explicitly selected target.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/LungeAttack
- Signature: `mob/proc/LungeAttack()`
- Inputs: None
- Purpose: Start a selected-target melee lunge from the standalone Lunge verb or hotbar action.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Melee
- Signature: `mob/proc/Melee(obj/O, from_auto_attack, force_power_attack, lunge_allowed = 0)`
- Inputs: obj/O, from_auto_attack, force_power_attack, lunge_allowed = 0
- Purpose: Handle melee.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MeleeAutoDodge
- Signature: `mob/proc/MeleeAutoDodge(mob/attacker)`
- Inputs: mob/attacker
- Purpose: Handle melee auto dodge.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanMeleeDodge
- Signature: `mob/proc/CanMeleeDodge(mob/attacker)`
- Inputs: mob/attacker
- Purpose: Return whether Melee Dodge.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/CanBlastDeflect
- Signature: `mob/proc/CanBlastDeflect(mob/attacker)`
- Inputs: mob/attacker
- Purpose: Return whether Blast Deflect.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Dodge_animation
- Signature: `mob/proc/Dodge_animation()`
- Inputs: None
- Purpose: Handle dodge animation.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Play_Melee_Sound
- Signature: `proc/Play_Melee_Sound(sound_range=10,mob/origin,sound_file,sound_volume=20)`
- Inputs: sound_range=10, mob/origin, sound_file, sound_volume=20
- Purpose: Handle play melee sound.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Melee_Shockwave_Repel
- Signature: `mob/proc/Melee_Shockwave_Repel(mob/target) //target = the person you just attacked, so we can exclude them from the repel`
- Inputs: mob/target
- Purpose: Handle melee shockwave repel.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MeleeRepelMob
- Signature: `MeleeRepelMob(mob/m, kb_pow = 1)`
- Inputs: mob/m, kb_pow = 1
- Purpose: Handle melee repel mob.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GetCriticalChance
- Signature: `mob/proc/GetCriticalChance()`
- Inputs: None
- Purpose: Return Critical Chance.
- Returns: computed value (see implementation).
- Side effects: none expected.

### src/Code/Combat/Melee/DragonRush.dm

#### mob/proc/CheckLungeDragonRush
- Signature: `CheckLungeDragonRush(mob/a, mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Check Lunge Dragon Rush.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DragonRushAnimationLoop
- Signature: `DragonRushAnimationLoop()`
- Inputs: None
- Purpose: Handle dragon rush animation loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DragonRushSFXLoop
- Signature: `DragonRushSFXLoop()`
- Inputs: None
- Purpose: Handle dragon rush sfxloop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/EndDragonRush
- Signature: `EndDragonRush()`
- Inputs: None
- Purpose: Handle end dragon rush.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/StartDragonRushVars
- Signature: `StartDragonRushVars()`
- Inputs: None
- Purpose: Start Dragon Rush Vars.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/PressedTowardEnemy
- Signature: `PressedTowardEnemy(mob/m)`
- Inputs: mob/m
- Purpose: Handle pressed toward enemy.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/WrongPressTowardEnemy
- Signature: `WrongPressTowardEnemy(mob/m)`
- Inputs: mob/m
- Purpose: Handle wrong press toward enemy.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/NewDragonRushLoc
- Signature: `NewDragonRushLoc(mob/m)`
- Inputs: mob/m
- Purpose: Handle new dragon rush loc.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FindNewDragonRushLoc
- Signature: `FindNewDragonRushLoc()`
- Inputs: None
- Purpose: Handle find new dragon rush loc.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DragonRushPointsToWin
- Signature: `DragonRushPointsToWin(mob/b)`
- Inputs: mob/b
- Purpose: Handle dragon rush points to win.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/IsValidDragonRushLoc
- Signature: `IsValidDragonRushLoc(turf/t)`
- Inputs: turf/t
- Purpose: Return whether Valid Dragon Rush Loc.
- Returns: boolean flag.
- Side effects: none expected.

#### proc/StartDragonRush
- Signature: `StartDragonRush(mob/a, mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Start Dragon Rush.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/DragonRushLoop
- Signature: `DragonRushLoop(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Handle dragon rush loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GetDragonRushWinner
- Signature: `GetDragonRushWinner(mob/a,mob/b,a_points = 0,b_points = 0)`
- Inputs: mob/a, mob/b, a_points = 0, b_points = 0
- Purpose: Return Dragon Rush Winner.
- Returns: computed value (see implementation).
- Side effects: none expected.

### src/Code/Combat/Melee/PressurePunch.dm

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/PressurePunch/verb/PressurePunch
- Signature: `PressurePunch()`
- Inputs: None
- Purpose: Handle pressure punch.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PressurePunchFX
- Signature: `PressurePunchFX()`
- Inputs: None
- Purpose: Handle pressure punch fx.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PressurePunch
- Signature: `PressurePunch()`
- Inputs: None
- Purpose: Handle pressure punch.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Melee/RoundhouseKick.dm

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/RoundhouseKick/verb/RoundhouseKick
- Signature: `RoundhouseKick()`
- Inputs: None
- Purpose: Handle roundhouse kick.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RoundhouseKickFX
- Signature: `RoundhouseKickFX()`
- Inputs: None
- Purpose: Handle roundhouse kick fx.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RoundhouseKick
- Signature: `RoundhouseKick()`
- Inputs: None
- Purpose: Handle roundhouse kick.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Melee/SuperDropkick.dm

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Dropkick/verb/Dropkick
- Signature: `Dropkick()`
- Inputs: None
- Purpose: Handle dropkick.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DropkickBPDebuff
- Signature: `DropkickBPDebuff()`
- Inputs: None
- Purpose: Handle dropkick bpdebuff.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DropkickFX
- Signature: `DropkickFX()`
- Inputs: None
- Purpose: Handle dropkick fx.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Dropkick
- Signature: `Dropkick()`
- Inputs: None
- Purpose: Handle dropkick.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DropkickCancelled
- Signature: `DropkickCancelled(mob/m, moved = 1)`
- Inputs: mob/m, moved = 1
- Purpose: Handle dropkick cancelled.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Melee/WolfFangFist.dm

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/WolfFangFist/verb/WolfFangFist
- Signature: `WolfFangFist()`
- Inputs: None
- Purpose: Handle wolf fang fist.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/WolfFangFistVFX
- Signature: `WolfFangFistVFX()`
- Inputs: None
- Purpose: Handle wolf fang fist vfx.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/WolfFangFist
- Signature: `WolfFangFist()`
- Inputs: None
- Purpose: Handle wolf fang fist.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/WolfFangFistCancelled
- Signature: `WolfFangFistCancelled(mob/victim, moved = 1)`
- Inputs: mob/victim, moved = 1
- Purpose: Handle wolf fang fist cancelled.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/RareDeathEffects.dm

#### mob/proc/Rare_death_check
- Signature: `mob/proc/Rare_death_check(mob/m) //m = the original mob. src = the body`
- Inputs: mob/m
- Purpose: Handle rare death check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/BloodEffectsWaitForZero
- Signature: `mob/proc/BloodEffectsWaitForZero()`
- Inputs: None
- Purpose: Handle blood effects wait for zero.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Blood_splatter_effects
- Signature: `mob/proc/Blood_splatter_effects()`
- Inputs: None
- Purpose: Handle blood splatter effects.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/RevengeSystem.dm

#### mob/proc/GetRevengeInfo
- Signature: `GetRevengeInfo(mob/m)`
- Inputs: mob/m
- Purpose: Return Revenge Info.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/GetRevengeDmgMod
- Signature: `GetRevengeDmgMod(mob/m)`
- Inputs: mob/m
- Purpose: Return Revenge Dmg Mod.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/TryGiveRevengeAgainst
- Signature: `TryGiveRevengeAgainst(mob/m, effectMod = 1, timer = 12000)`
- Inputs: mob/m, effectMod = 1, timer = 12000
- Purpose: Handle try give revenge against.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GiveRevengeAgainst
- Signature: `GiveRevengeAgainst(mob/m, effectMod = 1, timer = 12000)`
- Inputs: mob/m, effectMod = 1, timer = 12000
- Purpose: Handle give revenge against.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/RockThrow.dm

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/RockThrow/verb/RockThrow
- Signature: `RockThrow()`
- Inputs: None
- Purpose: Handle rock throw.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/RockSlide/verb/RockSlide
- Signature: `RockSlide()`
- Inputs: None
- Purpose: Handle rock slide.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/RockTomb/verb/RockTomb
- Signature: `RockTomb()`
- Inputs: None
- Purpose: Handle rock tomb.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RockThrowFX
- Signature: `RockThrowFX()`
- Inputs: None
- Purpose: Handle rock throw fx.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RockThrow
- Signature: `RockThrow()`
- Inputs: None
- Purpose: Resolve powerful or rapid selected-target rock damage using Strength-based melee math after the original animated Tenkaichi boulder reaches the target.
- Returns: none (implicit).
- Side effects: shows floating cast text, dust, throw and impact audio, animated impact art, damage and knockback.

#### mob/proc/RockSlideFX
- Signature: `RockSlideFX()`
- Inputs: None
- Purpose: Handle rock slide fx.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RockSlide
- Signature: `RockSlide()`
- Inputs: None
- Purpose: Search the forward spread and launch up to five original animated Tenkaichi boulders with victim-relative Strength-based hits.
- Returns: none (implicit).
- Side effects: shows cast text, earth audio, impact art, damage and knockback.

#### mob/proc/showRockSkillImpact
- Signature: `showRockSkillImpact(mob/target, heavy = FALSE)`
- Inputs: impact target and heavy-impact flag.
- Purpose: Display the adapted Nexus impact presentation shared by Rock Throw, Rock Slide and Rock Tomb.
- Returns: none (implicit).
- Side effects: selects CC0 stone audio, animates imported impact and rising-rock art, scatters debris, and creates a shockwave for Rock Tomb.

#### proc/showRockSkillDebris
- Signature: `showRockSkillDebris(turf/impact_turf, heavy = FALSE)`
- Inputs: impact turf and heavy-impact flag.
- Purpose: Scatter varied resource-rock sprites with size, offset, and travel variation.
- Returns: none (implicit).
- Side effects: creates short-lived debris actors; projectile trails use smaller, fainter instances.

#### mob/proc/RockTombFX
- Signature: `RockTombFX(turf/impact_turf)`
- Inputs: impact turf.
- Purpose: Render the imported rock explosion at the projectile impact rather than at the caster.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/RockTomb
- Signature: `RockTomb()`
- Inputs: None
- Purpose: Launch a visibly enlarged stone and defer direct and mastered area damage until impact.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/showRockSkillProjectile
- Signature: `showRockSkillProjectile(mob/target, visual_icon, visual_state, visual_scale)`
- Inputs: target and visual configuration.
- Purpose: Move a nondense visible rock actor from caster to target.
- Returns: impact turf.
- Side effects: creates and deletes a temporary visual actor and emits a restrained fragment trail.

### src/Code/Combat/Skills.dm

#### obj/Giant_Form/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Giant_Form/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Giant_Form
- Signature: `verb/Giant_Form()`
- Inputs: None
- Purpose: Handle giant form.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Toggle_giant_form
- Signature: `Toggle_giant_form(obj/Giant_Form/g)`
- Inputs: obj/Giant_Form/g
- Purpose: Toggle giant form.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Enable_giant_form
- Signature: `Enable_giant_form(obj/Giant_Form/g)`
- Inputs: obj/Giant_Form/g
- Purpose: Apply the reversible Giant Form BP/stat package.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Disable_giant_form
- Signature: `Disable_giant_form(icon_change=1)`
- Inputs: icon_change=1
- Purpose: Remove exactly the BP/stat package applied by Giant Form without leaving permanent `bp_mult` drift.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Limit_Breaker/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Limit_Breaker/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Limit_Breaker
- Signature: `verb/Limit_Breaker()`
- Inputs: None
- Purpose: Handle limit breaker.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Limit_Revert
- Signature: `mob/proc/Limit_Revert() if(limit_breaker_on)`
- Inputs: None
- Purpose: Handle limit revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Hide_Energy/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/delete_self
- Signature: `proc/delete_self()`
- Inputs: None
- Purpose: Delete self.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### verb/Hide_Energy
- Signature: `verb/Hide_Energy()`
- Inputs: None
- Purpose: Handle hide energy.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Dash_Attack
- Signature: `verb/Dash_Attack()`
- Inputs: None
- Purpose: Handle dash attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Dash_Attack
- Signature: `mob/proc/Dash_Attack()`
- Inputs: None
- Purpose: Handle dash attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DashAttackPart2
- Signature: `mob/proc/DashAttackPart2(mob/a, KB_Distance) //a = attacker`
- Inputs: mob/a, KB_Distance
- Purpose: Handle dash attack part2.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Forget_Skill
- Signature: `mob/verb/Forget_Skill()`
- Inputs: None
- Purpose: Handle forget skill.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Destroy_Soul_Contracts
- Signature: `mob/proc/Destroy_Soul_Contracts(soul_percent=100)`
- Inputs: soul_percent=100
- Purpose: Handle destroy soul contracts.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Contract_Soul /Appears in the Souls tab/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Contract_Soul /Appears in the Souls tab/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Contract_Soul /Appears in the Souls tab/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Soul_Contract_Update
- Signature: `proc/Soul_Contract_Update(mob/M) if(M)`
- Inputs: mob/M
- Purpose: Handle soul contract update.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Update_soul_contracts
- Signature: `mob/proc/Update_soul_contracts()`
- Inputs: None
- Purpose: Update soul contracts.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### verb/Soul_Contract
- Signature: `verb/Soul_Contract()`
- Inputs: None
- Purpose: Handle soul contract.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Soul_Contract
- Signature: `mob/proc/Soul_Contract(obj/Demon_Contract/SC)`
- Inputs: obj/Demon_Contract/SC
- Purpose: Handle soul contract.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Soul_Weapon
- Signature: `verb/Soul_Weapon()`
- Inputs: None
- Purpose: Handle soul weapon.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Soul_Weapon
- Signature: `mob/proc/Soul_Weapon(obj/Soul_Weapon/soul_weapon)`
- Inputs: obj/Soul_Weapon/soul_weapon
- Purpose: Handle soul weapon.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Soul_Attack
- Signature: `verb/Soul_Attack()`
- Inputs: None
- Purpose: Handle soul attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Soul_Attack
- Signature: `mob/proc/Soul_Attack(obj/Soul_Attack/Soul_Attack, range_y, range_x, duration)`
- Inputs: obj/Soul_Attack/Soul_Attack, range_y, range_x, duration
- Purpose: Handle soul attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Meditate_Level_2/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Sense/New
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

#### verb/Shadow_Spar
- Signature: `verb/Shadow_Spar()`
- Inputs: None
- Purpose: Handle shadow spar.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Timed_Delete
- Signature: `proc/Timed_Delete(obj/O,T=100)`
- Inputs: obj/O, T=100
- Purpose: Handle timed delete.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Rising_Aura
- Signature: `proc/Rising_Aura(obj/T,N=50)`
- Inputs: obj/T, N=50
- Purpose: Handle rising aura.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Rising_Aura/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Offsets
- Signature: `proc/Offsets(Offset=16)`
- Inputs: Offset=16
- Purpose: Handle offsets.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Aura_Walk
- Signature: `proc/Aura_Walk()`
- Inputs: None
- Purpose: Handle aura walk.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Regenerate
- Signature: `verb/Regenerate()`
- Inputs: None
- Purpose: Handle regenerate.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Give_Power
- Signature: `verb/Give_Power()`
- Inputs: None
- Purpose: Handle give power.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Give_Power
- Signature: `mob/proc/Give_Power(obj/Give_Power/G)`
- Inputs: obj/Give_Power/G
- Purpose: Handle give power.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Give_power_refill_loop
- Signature: `mob/proc/Give_power_refill_loop()`
- Inputs: None
- Purpose: Handle give power refill loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Zanzoken/New
- Signature: `New()`
- Inputs: None
- Purpose: Register the owned Zanzoken skill and synchronize conditional hotkey actions.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Combo_Toggle
- Signature: `verb/Combo_Toggle()`
- Inputs: None
- Purpose: Handle combo toggle.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/getZanzokenSkill
- Signature: `mob/proc/getZanzokenSkill()`
- Purpose: Return the directly owned `/obj/Zanzoken` and self-heal the temporary cache.
- Returns: owned skill object or null.
- Side effects: refreshes `zanzoken_obj`.

#### mob/proc/hasZanzokenSkill
- Signature: `mob/proc/hasZanzokenSkill()`
- Purpose: Authoritatively gate click warp, directional verbs, Flash Step, and registered hotkey actions.
- Returns: boolean.
- Side effects: may self-heal the cache.

#### obj/Zanzoken directional verbs
- Signature: `zanzokenNorth()`, `zanzokenNortheast()`, `zanzokenEast()`, `zanzokenSoutheast()`, `zanzokenSouth()`, `zanzokenSouthwest()`, `zanzokenWest()`, `zanzokenNorthwest()`
- Inputs: None.
- Purpose: Expose eight directional Zanzoken actions that attack a selected target inside the five-tile direction cone or fall back to fixed movement.
- Returns: none (implicit).
- Side effects: delegates to `directionalZanzoken()`.

#### obj/Zanzoken/verb/flashStep
- Signature: `flashStep()`
- Inputs: None.
- Purpose: Expose Flash Step in the Skills tab when Zanzoken is learned.
- Returns: none (implicit).
- Side effects: delegates to `Flash_Step()`.

#### obj/Keep_Body/New
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

#### verb/Keep_Body
- Signature: `verb/Keep_Body()`
- Inputs: None
- Purpose: Handle keep body.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Shield/New
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

#### verb/Shield
- Signature: `verb/Shield()`
- Inputs: None
- Purpose: Handle shield.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Toggle_ki_shield
- Signature: `mob/proc/Toggle_ki_shield(obj/Shield/s)`
- Inputs: obj/Shield/s
- Purpose: Toggle ki shield.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/CanUseKiShield
- Signature: `mob/proc/CanUseKiShield()`
- Inputs: None
- Purpose: Return whether Use Ki Shield.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/UsingGuidedAttack
- Signature: `mob/proc/UsingGuidedAttack()`
- Inputs: None
- Purpose: Handle using guided attack.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Shield_Revert
- Signature: `mob/proc/Shield_Revert()`
- Inputs: None
- Purpose: Handle shield revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Make_Power_Fruit
- Signature: `verb/Make_Power_Fruit()`
- Inputs: None
- Purpose: Handle make power fruit.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Curse/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Curse/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/bind_check
- Signature: `proc/bind_check()`
- Inputs: None
- Purpose: Handle bind check.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/bind_power
- Signature: `proc/bind_power(mob/m)`
- Inputs: mob/m
- Purpose: Handle bind power.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/bind_time
- Signature: `proc/bind_time(mob/m)`
- Inputs: mob/m
- Purpose: Handle bind time.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Bind_Someone
- Signature: `verb/Bind_Someone()`
- Inputs: None
- Purpose: Handle bind someone.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/UnBind_Someone
- Signature: `verb/UnBind_Someone()`
- Inputs: None
- Purpose: Handle un bind someone.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Examine_List
- Signature: `proc/Examine_List()`
- Inputs: None
- Purpose: Handle examine list.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Examine
- Signature: `mob/verb/Examine(obj/A in Examine_List())`
- Inputs: obj/A in Examine_List(
- Purpose: Handle examine.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Strongest_Person
- Signature: `proc/Strongest_Person(mob/M)`
- Inputs: mob/M
- Purpose: Handle strongest person.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/strongest_person_proportionate
- Signature: `proc/strongest_person_proportionate(mob/m)`
- Inputs: mob/m
- Purpose: Handle strongest person proportionate.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Absorb
- Signature: `verb/Absorb()`
- Inputs: None
- Purpose: Handle absorb.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/power_absorb_mod
- Signature: `power_absorb_mod()`
- Inputs: None
- Purpose: Handle power absorb mod.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/knowledge_absorb_mod
- Signature: `knowledge_absorb_mod()`
- Inputs: None
- Purpose: Handle knowledge absorb mod.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Absorb
- Signature: `mob/proc/Absorb(mob/M, force_absorb)`
- Inputs: mob/M, force_absorb
- Purpose: Handle absorb.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/can_absorb
- Signature: `mob/proc/can_absorb(mob/M)`
- Inputs: mob/M
- Purpose: Return whether absorb.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/SI_Choices
- Signature: `mob/proc/SI_Choices()`
- Inputs: None
- Purpose: Handle si choices.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Cant_SI
- Signature: `mob/proc/Cant_SI(mob/A,show_message=1)`
- Inputs: mob/A, show_message=1
- Purpose: Handle cant si.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SI_disadvantage_mult
- Signature: `mob/proc/SI_disadvantage_mult(mob/m)`
- Inputs: mob/m
- Purpose: Handle si disadvantage mult.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Update_SI_disadvantage
- Signature: `mob/proc/Update_SI_disadvantage(mob/m)`
- Inputs: mob/m
- Purpose: Update SI disadvantage.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Instant_Transmission
- Signature: `verb/Instant_Transmission(mob/A in usr.SI_Choices())`
- Inputs: mob/A in usr.SI_Choices(
- Purpose: Handle instant transmission.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Cant_Kai_Teleport
- Signature: `mob/proc/Cant_Kai_Teleport(destination)`
- Inputs: destination
- Purpose: Handle cant kai teleport.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Planet_has_teleport_nullifier
- Signature: `proc/Planet_has_teleport_nullifier(planet,mob/reciever)`
- Inputs: planet, mob/reciever
- Purpose: Handle planet has teleport nullifier.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_kt_spawn
- Signature: `proc/Get_kt_spawn(area_name)`
- Inputs: area_name
- Purpose: Return kt spawn.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Kai_Teleport
- Signature: `verb/Kai_Teleport()`
- Inputs: None
- Purpose: Handle kai teleport.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/IncreaseGod_FistLevel
- Signature: `mob/proc/IncreaseGod_FistLevel()`
- Inputs: None
- Purpose: Handle increase god fist level.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PowerUpGoNextForm
- Signature: `mob/proc/PowerUpGoNextForm()`
- Inputs: None
- Purpose: Handle power up go next form.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Power_up
- Signature: `mob/proc/Power_up()`
- Inputs: None
- Purpose: Handle power up.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Power_Control/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Power_Control/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Power_Up
- Signature: `verb/Power_Up()`
- Inputs: None
- Purpose: Handle power up.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Power_Down
- Signature: `verb/Power_Down()`
- Inputs: None
- Purpose: Handle power down.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/CenterIcon
- Signature: `proc/CenterIcon(obj/O,Icon,x_only)`
- Inputs: obj/O, Icon, x_only
- Purpose: Handle center icon.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Icon_Center_X
- Signature: `proc/Icon_Center_X(O)`
- Inputs: O
- Purpose: Handle icon center x.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Icon_Center_Y
- Signature: `proc/Icon_Center_Y(O)`
- Inputs: O
- Purpose: Handle icon center y.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Scaled_Icon
- Signature: `proc/Scaled_Icon(O,X,Y)`
- Inputs: O, X, Y
- Purpose: Handle scaled icon.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GetWidth
- Signature: `proc/GetWidth(O)`
- Inputs: O
- Purpose: Return Width.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/GetHeight
- Signature: `proc/GetHeight(O)`
- Inputs: O
- Purpose: Return Height.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### obj/Auras/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Stop_Powering_Up
- Signature: `mob/proc/Stop_Powering_Up()`
- Inputs: None
- Purpose: Stop Powering Up.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/InitSuperGod_FistAura
- Signature: `proc/InitSuperGod_FistAura()`
- Inputs: None
- Purpose: Initialize Super God Fist Aura.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ShouldUseSuperGod_Fist
- Signature: `mob/proc/ShouldUseSuperGod_Fist()`
- Inputs: None
- Purpose: Handle should use super god fist.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CheckSuperGod_Fist
- Signature: `mob/proc/CheckSuperGod_Fist()`
- Inputs: None
- Purpose: Check Super God Fist.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Aura_Overlays
- Signature: `mob/proc/Aura_Overlays(remove_only)`
- Inputs: remove_only
- Purpose: Synchronize legacy aura overlays with an independent attack-colored lighting emitter; removal clears only the aura layer and preserves transformation/action lights.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Add_Sparks
- Signature: `mob/proc/Add_Sparks()`
- Inputs: None
- Purpose: Add Sparks.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### obj/Fly/New
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

#### verb/Fly
- Signature: `verb/Fly()`
- Inputs: None
- Purpose: Handle fly.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Layer_Update
- Signature: `mob/proc/Layer_Update()`
- Inputs: None
- Purpose: Handle layer update.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Fly
- Signature: `mob/proc/Fly(obj/Fly/F)`
- Inputs: obj/Fly/F
- Purpose: Handle fly.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Land
- Signature: `mob/proc/Land()`
- Inputs: None
- Purpose: Handle land.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Random_Fart
- Signature: `proc/Random_Fart()`
- Inputs: None
- Purpose: Handle random fart.
- Returns: none (implicit).
- Side effects: see implementation.

#### turf/proc/Self_Destruct_Lightning
- Signature: `turf/proc/Self_Destruct_Lightning(B) if(B)`
- Inputs: B
- Purpose: Handle self destruct lightning.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Self_Destruct
- Signature: `verb/Self_Destruct()`
- Inputs: None
- Purpose: Handle self destruct.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_self_destruct_damage
- Signature: `proc/Get_self_destruct_damage(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Return centralized Force-versus-Resistance damage at factor `30`, reduced only when Regenerate/Rebuild removes the full sacrifice.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/AOE_auto_dodge
- Signature: `mob/proc/AOE_auto_dodge(mob/attacker,turf/origin,min_dist=7,max_dist=10)`
- Inputs: mob/attacker, turf/origin, min_dist=7, max_dist=10
- Purpose: Handle aoe auto dodge.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Revive_Someone
- Signature: `verb/Revive_Someone()`
- Inputs: None
- Purpose: Handle revive someone.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Heal
- Signature: `verb/Heal()`
- Inputs: None
- Purpose: Handle heal.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/potential_mod
- Signature: `mob/proc/potential_mod()`
- Inputs: None
- Purpose: Handle potential mod.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Unlock_Potential
- Signature: `verb/Unlock_Potential()`
- Inputs: None
- Purpose: Handle unlock potential.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Solar_Flare
- Signature: `verb/Solar_Flare()`
- Inputs: None
- Purpose: Handle solar flare.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Taiyoken_Blindness_Timer
- Signature: `mob/proc/Taiyoken_Blindness_Timer()`
- Inputs: None
- Purpose: Handle taiyoken blindness timer.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Rift_Teleport
- Signature: `verb/Rift_Teleport()`
- Inputs: None
- Purpose: Handle rift teleport.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Imitate_Player
- Signature: `verb/Imitate_Player()`
- Inputs: None
- Purpose: Handle imitate player.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Invisibility
- Signature: `verb/Invisibility()`
- Inputs: None
- Purpose: Handle invisibility.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/precog_loop
- Signature: `mob/proc/precog_loop()`
- Inputs: None
- Purpose: Handle precog loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Observe_List
- Signature: `mob/proc/Observe_List()`
- Inputs: None
- Purpose: Handle observe list.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Observe
- Signature: `verb/Observe(atom/A in usr.Observe_List())`
- Inputs: atom/A in usr.Observe_List(
- Purpose: Handle observe.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/observe
- Signature: `mob/Admin1/verb/observe(atom/A in Observe_List())`
- Inputs: atom/A in Observe_List(
- Purpose: Handle observe.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Get_Observe
- Signature: `mob/proc/Get_Observe(mob/M) if(client)`
- Inputs: mob/M
- Purpose: Return Observe.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Materialize
- Signature: `verb/Materialize()`
- Inputs: None
- Purpose: Handle materialize.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Mystic/New
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

#### verb/Mystic
- Signature: `verb/Mystic()`
- Inputs: None
- Purpose: Handle mystic.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Mystic_Revert
- Signature: `mob/proc/Mystic_Revert() if(ismystic)`
- Inputs: None
- Purpose: Handle mystic revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/FireFist/New
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

#### verb/FireFist
- Signature: `verb/FireFist()`
- Inputs: None
- Purpose: Handle fire fist.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FireFist_Revert
- Signature: `mob/proc/FireFist_Revert()`
- Inputs: None
- Purpose: Disable Fire Fist on `src`, remove its overlay, and rebuild managed player appearance.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FireFistLoop
- Signature: `mob/proc/FireFistLoop()`
- Inputs: None
- Purpose: Run exactly one guarded Fire Fist drain loop; login restarts it through `Player_Loops()`.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FireFistDrain
- Signature: `mob/proc/FireFistDrain()`
- Inputs: None
- Purpose: Handle fire fist drain.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/SaiyanPower/New
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

#### verb/SaiyanPower
- Signature: `verb/SaiyanPower()`
- Inputs: None
- Purpose: Handle saiyan power.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SaiyanPower_Revert
- Signature: `mob/proc/SaiyanPower_Revert()`
- Inputs: None
- Purpose: Remove the Saiyan Power package from `src` without relying on `usr`.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Majin/New
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

#### verb/Majin
- Signature: `verb/Majin()`
- Inputs: None
- Purpose: Handle majin.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Majin_Revert
- Signature: `mob/proc/Majin_Revert() if(ismajin)`
- Inputs: None
- Purpose: Handle majin revert.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Restore_Youth
- Signature: `verb/Restore_Youth()`
- Inputs: None
- Purpose: Handle restore youth.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Use
- Signature: `verb/Use()`
- Inputs: None
- Purpose: Handle use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/InBattleCantEnterCave
- Signature: `mob/proc/InBattleCantEnterCave()`
- Inputs: None
- Purpose: Handle in battle cant enter cave.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/RankChat
- Signature: `verb/RankChat(A as text)`
- Inputs: A as text
- Purpose: Handle rank chat.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/SpeedDelay.dm

#### mob/proc/Speed_delay_mult
- Signature: `mob/proc/Speed_delay_mult(severity = 1)`
- Inputs: severity = 1
- Purpose: Handle speed delay mult.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/SplitForms.dm

#### proc/Get_cached_splitform
- Signature: `proc/Get_cached_splitform()`
- Inputs: None
- Purpose: Return cached splitform.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/SplitformDestroyedByCheck
- Signature: `SplitformDestroyedByCheck(mob/m)`
- Inputs: mob/m
- Purpose: Handle splitform destroyed by check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/MaxSplitforms
- Signature: `MaxSplitforms()`
- Inputs: None
- Purpose: Handle max splitforms.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Splitform/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Splitform/Del
- Signature: `Del()`
- Inputs: None
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/SimDestroyedBy
- Signature: `proc/SimDestroyedBy(mob/m)`
- Inputs: mob/m
- Purpose: Handle sim destroyed by.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Auto_Attack_Enemy
- Signature: `proc/Auto_Attack_Enemy()`
- Inputs: None
- Purpose: Handle auto attack enemy.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Fly_Check
- Signature: `proc/Fly_Check()`
- Inputs: None
- Purpose: Handle fly check.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/BP_Loop
- Signature: `proc/BP_Loop()`
- Inputs: None
- Purpose: Handle bp loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Attack_Loop
- Signature: `proc/Attack_Loop()`
- Inputs: None
- Purpose: Handle attack loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Death_Loop
- Signature: `proc/Death_Loop()`
- Inputs: None
- Purpose: Handle death loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Target_Loop
- Signature: `proc/Target_Loop()`
- Inputs: None
- Purpose: Handle target loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Follow_Loop
- Signature: `proc/Follow_Loop()`
- Inputs: None
- Purpose: Handle follow loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Splitform/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/SplitForm
- Signature: `verb/SplitForm()`
- Inputs: None
- Purpose: Handle split form.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/TrySplitform
- Signature: `TrySplitform()`
- Inputs: None
- Purpose: Handle try splitform.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/CanSplitform
- Signature: `CanSplitform()`
- Inputs: None
- Purpose: Return whether Splitform.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/CreateSplitform
- Signature: `CreateSplitform()`
- Inputs: None
- Purpose: Create Splitform.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Sim_Destroy_Loop
- Signature: `mob/proc/Sim_Destroy_Loop()`
- Inputs: None
- Purpose: Handle sim destroy loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade_health
- Signature: `verb/Upgrade_health()`
- Inputs: None
- Purpose: Handle upgrade health.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Bolt
- Signature: `verb/Bolt()`
- Inputs: None
- Purpose: Handle bolt.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Upgrade
- Signature: `verb/Upgrade()`
- Inputs: None
- Purpose: Handle upgrade.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Create_simulated_fighter
- Signature: `proc/Create_simulated_fighter(mob/m)`
- Inputs: mob/m
- Purpose: Create simulated fighter.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### proc/Destroy_simulated_fighters
- Signature: `proc/Destroy_simulated_fighters(mob/m)`
- Inputs: mob/m
- Purpose: Handle destroy simulated fighters.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Toggle_simulated_fighter
- Signature: `proc/Toggle_simulated_fighter(mob/m)`
- Inputs: mob/m
- Purpose: Toggle simulated fighter.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### obj/items/Simulator/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/SimBump
- Signature: `mob/proc/SimBump(obj/items/Simulator/s)`
- Inputs: obj/items/Simulator/s
- Purpose: Handle sim bump.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Make_Simulated_Fighter
- Signature: `mob/proc/Make_Simulated_Fighter(obj/items/Simulator/Sim,sim_str=1,sim_dura=1)`
- Inputs: obj/items/Simulator/Sim, sim_str=1, sim_dura=1
- Purpose: Handle make simulated fighter.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Sim_Loop
- Signature: `mob/proc/Sim_Loop()`
- Inputs: None
- Purpose: Handle sim loop.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Targeting/Targeting.dm

#### proc/getSelectedTargetMarkerIcon
- Signature: `proc/getSelectedTargetMarkerIcon()`
- Inputs: None.
- Purpose: Lazily generate the cyan client-only lock-on marker.
- Returns: cached 32x32 icon.
- Side effects: initializes the marker icon on first use.

#### mob/proc/canSelectTarget
- Signature: `mob/proc/canSelectTarget(mob/candidate)`
- Inputs: candidate mob.
- Purpose: Reject self, bodies, hidden, nonattackable, or unplaced mobs.
- Returns: boolean.
- Side effects: none.

#### mob/proc/setSelectedTarget
- Signature: `mob/proc/setSelectedTarget(mob/new_target, announce = TRUE)`
- Inputs: new target and announcement flag.
- Purpose: Set or clear the authoritative combat lock and synchronize legacy sense state and the client marker.
- Returns: selected target or null.
- Side effects: updates `Target`, `selected_target`, `auto_target`, and `client.images`.

#### mob/proc/getSelectedTarget
- Signature: `mob/proc/getSelectedTarget(mob/expected_target, max_dist = 0, require_view = TRUE, allow_ko = FALSE, require_attackable = TRUE, dir_angle = 0, angle_limit = 0)`
- Inputs: optional expected target and contextual range, visibility, KO, attackable, direction, and cone constraints.
- Purpose: Validate only the explicit selection without searching for a fallback mob.
- Returns: selected mob when valid, otherwise null.
- Side effects: clears intrinsically invalid selections.

#### mob/verb/selectTarget
- Signature: `mob/verb/selectTarget()`
- Inputs: player choice from nearby visible player characters and combat dummies.
- Purpose: Open the explicit combat-target selector.
- Returns: none (implicit).
- Side effects: may set the selected target.

#### mob/verb/clearTarget
- Signature: `mob/verb/clearTarget()`
- Inputs: None.
- Purpose: Clear the explicit combat target and marker.
- Returns: none (implicit).
- Side effects: clears targeting state.

#### atom/movable/proc/FindTarget
- Signature: `FindTarget(dir_angle=NORTH, angle_limit=33, max_dist=9, prefer_auto_target=1)`
- Inputs: dir_angle=NORTH, angle_limit=33, max_dist=9, prefer_auto_target=1
- Purpose: Select the highest-rated valid target in a single linear scan without sorting all candidates.
- Returns: the best target, or null.
- Side effects: updates `auto_target`.

#### atom/movable/proc/IsValidTarget
- Signature: `IsValidTarget(mob/m, max_dist=10)`
- Inputs: mob/m, max_dist=10
- Purpose: Return whether Valid Target.
- Returns: boolean flag.
- Side effects: none expected.

#### atom/movable/proc/FindTargets
- Signature: `FindTargets(dir_angle=NORTH, angle_limit=33, max_dist=9, prefer_auto_target=0)`
- Inputs: dir_angle=NORTH, angle_limit=33, max_dist=9, prefer_auto_target=0
- Purpose: Legacy sorted angular scan retained for callers that explicitly require every candidate; single-target actions use `FindTarget()`.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/pixel_dir
- Signature: `proc/pixel_dir(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Handle pixel dir.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/pixel_dir_old
- Signature: `proc/pixel_dir_old(mob/a,mob/b)`
- Inputs: mob/a, mob/b
- Purpose: Handle pixel dir old.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/num_between
- Signature: `proc/num_between(n,Min,Max)`
- Inputs: n, Min, Max
- Purpose: Handle num between.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/angle_to_dir
- Signature: `proc/angle_to_dir(ang)`
- Inputs: ang
- Purpose: Handle angle to dir.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/ShortestDegreesBetweenAngles
- Signature: `proc/ShortestDegreesBetweenAngles(start=0,end=0) //tells the shortest path from one angle to another, if going backwards thru zero is faster it'll show that`
- Inputs: start=0, end=0
- Purpose: Handle shortest degrees between angles.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/TenkaichiMeleeTechniques.dm

#### mob/proc/showTenkaichiTechniqueAnnouncement
- Signature: `showTenkaichiTechniqueAnnouncement(technique_name, text_color, sound_file, sound_volume)`
- Inputs: visible technique name, presentation color and optional sound profile.
- Purpose: Apply Nexus-style floating cast text, spectator messaging and positional audio to an imported technique.
- Returns: none (implicit).
- Side effects: creates and deletes a temporary maptext actor and plays the selected sound.

#### obj/Attacks/TenkaichiMeleeTechnique/proc/playCastEffects
- Signature: `playCastEffects(mob/user)`
- Inputs: technique user.
- Purpose: Dispatch the shared attack animation, floating name, message and behavior-aware CC0 weapon or legacy unarmed/grapple cast audio.
- Returns: none (implicit).
- Side effects: changes transient animation state and creates audiovisual feedback.

#### obj/Attacks/TenkaichiMeleeTechnique/proc/showSwordSlashEffect
- Signature: `showSwordSlashEffect(mob/target, impact_scale = 1)`
- Inputs: hit target and calculated impact scale.
- Purpose: Layer the nine-frame CC0 pixel slash over the technique's original Tenkaichi effect with per-technique color and additive light.
- Returns: none (implicit).
- Side effects: creates and deletes one transient animated slash actor.

#### mob/proc/castTenkaichiMeleeTechnique
- Signature: `mob/proc/castTenkaichiMeleeTechnique(obj/Attacks/TenkaichiMeleeTechnique/technique)`
- Inputs: the owned Roleplay Tenkaichi technique object.
- Purpose: Validate equipment, RPMode, target, range, energy and cooldown before routing ordinary strikes through native `Melee()` and dispatching line dash, pursuit, delayed barrage, grapple and counter behaviors.
- Returns: boolean success flag.
- Side effects: may move through targets, pursue over time, consume a grab, prepare a riposte, spend energy or establish a one-use melee modifier context.

#### obj/Attacks/TenkaichiMeleeTechnique/proc/applyOnHit
- Signature: `applyOnHit(mob/attacker, mob/target, damage)`
- Inputs: attacker, primary target and damage produced by the native melee calculation.
- Purpose: Apply the adapted multi-hit, bleed, stun and front/radius effects after block and dodge resolution.
- Returns: none (implicit).
- Side effects: may damage secondary targets, apply crowd control, animate imported Tenkaichi effects and play technique-specific impact audio.

#### mob/proc/applyTenkaichiTechniqueDamage
- Signature: `mob/proc/applyTenkaichiTechniqueDamage(mob/target, damage)`
- Inputs: secondary target and native damage amount.
- Purpose: Resolve supplemental technique hits using Nexus KO, lethal, safe-zone and RPMode rules.
- Returns: boolean success flag.
- Side effects: changes target Health and may trigger KO or Death.

#### mob/proc/resolveTenkaichiTechniqueHit
- Signature: `mob/proc/resolveTenkaichiTechniqueHit(mob/target, obj/Attacks/TenkaichiMeleeTechnique/technique, damage_multiplier, force_hit)`
- Inputs: target, technique definition, optional damage multiplier and forced-hit flag.
- Purpose: Resolve specialized melee hits through Nexus accuracy, dodge, guard, damage, KO and lethal rules.
- Returns: boolean success flag.
- Side effects: may damage, bleed, stun or knock back the target.

#### mob/proc/tryTenkaichiRiposte
- Signature: `mob/proc/tryTenkaichiRiposte(mob/attacker)`
- Inputs: incoming melee attacker.
- Purpose: Consume a prepared Riposte and counter the incoming attack before its energy and damage resolution.
- Returns: boolean indicating whether the incoming attack was intercepted.
- Side effects: stuns and counterattacks the attacker.

#### mob/proc/getTenkaichiTechniqueTarget
- Signature: `mob/proc/getTenkaichiTechniqueTarget(maximum_range)`
- Inputs: maximum attack range.
- Purpose: Use the selected target when valid and fall back to the mob directly in front for adjacent combo skills.
- Returns: valid target mob or null.
- Side effects: none.

#### mob/proc/canUseTenkaichiGrappleTechnique
- Signature: `mob/proc/canUseTenkaichiGrappleTechnique()`
- Inputs: none.
- Purpose: Apply normal melee validation while allowing the active grab required by Pile Driver and Megaton Throw.
- Returns: boolean availability.
- Side effects: temporarily excludes `grabbedObject` only during synchronous validation.

### src/Code/Combat/TenkaichiSpecialStyles.dm

#### obj/Attacks/TenkaichiSpecialStyle/WallOfFlame/proc/useStyle
- Signature: `useStyle(mob/user)`
- Inputs: attack owner.
- Purpose: Create a five-tile persistent fire wall instead of approximating the technique as a projectile fan.
- Returns: boolean success flag.
- Side effects: spends energy, plays fire audio and cast text, and creates fading temporary flame-field controllers.

#### obj/Effect/TenkaichiFlameField/proc/processField
- Signature: `processField()`
- Inputs: none.
- Purpose: Apply bounded periodic Ki damage, burn and brief stun to enemies occupying the field.
- Returns: none (implicit).
- Side effects: damages each target at most six times and deletes the field when its duration ends.

#### proc/BubbleSort
- Signature: `proc/BubbleSort(list/l)`
- Inputs: list/l
- Purpose: Handle bubble sort.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/Combat/Targeting/TargetingWrappers.dm

#### mob/proc/FindHakaiTarget
- Signature: `mob/proc/FindHakaiTarget()`
- Inputs: None
- Purpose: Validate the selected target against Hakai restrictions.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/IsViableHakaiTarget
- Signature: `mob/proc/IsViableHakaiTarget(mob/m, max_dist = 5)`
- Inputs: mob/m, max_dist = 5
- Purpose: Return whether Viable Hakai Target.
- Returns: boolean flag.
- Side effects: none expected.

#### obj/Blast/proc/GetBlastHomingTarget
- Signature: `obj/Blast/proc/GetBlastHomingTarget(d, angle)`
- Inputs: d, angle
- Purpose: Return only the owner's selected target when viable for homing.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Is_viable_lunge_target
- Signature: `mob/proc/Is_viable_lunge_target(mob/m)`
- Inputs: mob/m
- Purpose: Return whether viable lunge target.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/LungeTarget
- Signature: `mob/proc/LungeTarget(dist_override)`
- Inputs: dist_override
- Purpose: Validate only the selected target for lunge, Wolf Fang Fist, Dropkick, Scatter Shot, and Flash Step.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/FindWarpTarget
- Signature: `FindWarpTarget(dir_angle=NORTH, angle_limit=44, max_dist=10, prefer_auto_target=0)`
- Inputs: dir_angle=NORTH, angle_limit=44, max_dist=10, prefer_auto_target=0
- Purpose: Validate only the selected target against warp range and directional cone.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/IsValidWarpTarget
- Signature: `IsValidWarpTarget(mob/m, max_dist=10)`
- Inputs: mob/m, max_dist=10
- Purpose: Return whether Valid Warp Target.
- Returns: boolean flag.
- Side effects: none expected.
