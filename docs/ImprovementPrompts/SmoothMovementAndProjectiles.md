# Improvement Prompt: Smooth Movement, Lazy-Follow Projectiles, and Save Performance

This document distills a design discussion (Roundstage x Zackbleus, FR) into actionable improvements for Nexus-Exodus. It is written as a prompt so an agent can implement it directly.

## 1. Smooth Movement with Inertia (Acceleration + Velocity + Friction)

**Goal:** Make player movement feel smoother with momentum, without feeling floaty.

Current state: Nexus uses pixel-vector movement (`vector_step`, `tryNexusVectorMoveWithGapNudge`) with a per-tick pixel speed and glide size. There is no explicit acceleration or velocity vector.

**Recommended approach (FR-style):**
- Add two vectors per mob: an `acceleration` vector and a `velocity` vector.
- Each input frame: acceleration adds into velocity; the mob's actual move distance is derived from velocity.
- At the end of each movement frame, apply friction to the velocity vector (`velocity *= friction_factor`).
- Use a HIGH friction factor (FR uses a high amount). Too low = floaty/sluggish; too high = no inertia.
- Direction changes should keep a little bit of the previous velocity (that is the whole point of the feel).

**Implementation notes:**
- Keep the existing gap-nudge alignment/collision system intact. The alignment library already fixes "bumping into walls and getting stuck when not aligned"; do not regress it.
- Tunables should be global vars (see existing `vector_move_*` globals in `src/Code/Application/Movement/MovementInput.dm`): e.g. `vector_accel`, `vector_friction`, `vector_max_velocity`.
- Verify by running `.\tools\Invoke-ByondSmoke.ps1` for a clean compile + startup.

## 2. Lazy-Follow Projectiles (Bezier-Style Guided Blasts)

**Goal:** Guided blasts should chase the target briefly, then lock their flight path so the player can dodge by moving, while slowed targets still get hit.

Current state: `obj/Blast/proc/followSelectedTarget()` homes perfectly at the target every tick. `BlastVectorWalk()` flies a straight line. There is no "lazy follow" mode.

**Recommended approach (FR "lazy follow"):**
- Add a new `obj/Blast/proc/BlastLazyFollow(mob/target)` flight mode.
- Phase 1 (lock-on, ~0.5s): the blast's end-point tracks the target closely (this is the "follow the guy" phase).
- Phase 2 (locked): after ~0.5s, the blast's end-point is fixed in place. The fixed end-point then **slowly drifts toward the enemy** (this is the "lazy follow" drift). It is NOT a perfect follow.
- The blast itself flies along a curve toward that drifting end-point, i.e., the trajectory smooths like a bezier: keep the previous heading and only steer toward the end-point by a limited angle per tick.

**Implementation notes:**
- Add vars on `obj/Blast`: `lazy_follow_target`, `lazy_follow_end_x/y`, `lazy_follow_lock_time`, `lazy_follow_drift` (pixels per tick toward enemy), `lazy_follow_steer_limit` (max heading change per tick).
- Add a `SKILL_HOMING_LAZY` mode constant in `src/Code/Domain/Combat/SkillBehaviors.dm` and wire it through `datum/SkillEngine/applyHomingSettings()` and `castBlast()`-style paths so skills can opt in.
- Keep the straight-flight and perfect-follow modes available; add lazy-follow as a third option.

## 3. Big Spheres: Circle-Within-Hitbox Collision

**Goal:** Supernova, Genki Dama, and other large spheres should hit as a circle, not a square of tiles.

Current state: `obj/Blast/proc/Move()` (in `src/Code/ProjectileSystem/Projectiles.dm`) loops `orange(Size, src)` and bumps anything in that tile square. Skills also historically checked tiles, which breaks under pixel movement.

**Recommended approach (FR):**
- Keep a large tile-hitbox (`orange(Size, src)`) as the cheap broad-phase.
- Then do a precise distance check against the blast center (bound center to bound center, pixel distance) and only register hits within the circle radius (`Size`).
- This makes the actual hit area a circle inscribed in the tile hitbox.

**Implementation notes:**
- Add a helper on `obj/Blast`, e.g. `withinBlastCircle(atom/A)`, returning true when the pixel distance from the blast's bound center to `A`'s bound center is `<= Size` (in tiles/pixels appropriately).
- Apply the distance check inside `Move()` before `Bump()`.
- For skill damage loops that currently iterate tiles (Supernova `max_dmg_range`, SpiritBomb `Size`), prefer iterating mobs with a distance check instead of relying on `orange()` squares.

## 4. Map Save Performance: ID-Based + Chunking + RLE (No Database)

**Goal:** Eliminate the lag spike when saving/loading worlds with huge player builds (30k+ tiles, entire cities).

Current state: `mapSave()`/`mapLoad()` in `src/Code/Building/Build.dm` already chunk into segments of 20k and store type/health/builder/x/y/z/fly_over lists. This is decent but still writes full type paths and per-tile rows; item/inventory saves (in `Saving.dm`) remain heavy.

**Recommended approach (FR, no DB needed):**
- Give every unique turf type a short integer ID; save a compact ID list plus a lookup table. This shrinks the "Types" list dramatically.
- Add RLE (run-length encoding) for consecutive identical tile entries within a chunk to compress repeated structures.
- Consider a single in-RAM "map list of IDs" as the source of truth (FR uses a global `voxel_map`); saving = writing that list; loading = reading the list and placing turfs by ID.
- Do NOT replace filesaves with a database. Databases are only justified when RAM is the constraint. Loading into RAM at runtime (a global list) is faster and simpler for BYOND.
- Keep the per-player `.sav` files; optimize the world/item/map saves.

## 5. Asset Sourcing (out of scope for code)

For tilesets/icons: itch.io and opengameart.org. Player icons and bespoke sprites are often authored by hand. Not a code change.

## Verification

- Run `.\tools\Invoke-ByondSmoke.ps1 -CompileOnly` for a headless clean compile.
- Run the full `.\tools\Invoke-ByondSmoke.ps1` baseline.
- Run `.\tools\Test-NamingConventions.ps1` and `.\tools\Test-AssetReferences.ps1 -Strict`.
- Manually test: dash movement feel, guided blast dodging, Supernova hit area, and a full saveWorld/restart with a large build.
