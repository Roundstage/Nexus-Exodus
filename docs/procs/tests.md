# Tests

## Overview
Startup assertions run only when Dream Daemon receives the `nexus_smoke_tests` world parameter. The PowerShell smoke runner enables this parameter in an isolated temporary world.

The startup suite covers admin log access paths, combat-dummy verb isolation and reset behavior, explicit dummy selection, compact vitals/action and dual-layout chat contracts, interface preference normalization, the permission-aware pixel shortcut strip with chat-integrated CMD and classic-menu access, icon-backed player menus, skill examination damage/requirements, roleplay spacing/color preservation, the 50-word overhead Say contract, grabbed-player attack rejection, the rustic shared browser theme, three-slot path isolation and clamping, labeled vitals and exact Energy formatting, stacked overhead Health/Energy/Willpower bars, multiplicative night lighting, additive glow planes, projectile/beam/aura flicker profiles, mutation admin verbs, reversible mutation editing/rerolling, synchronized lethal intent, immobile RP Mode, combat-regeneration Willpower drain, Mining/Smithing progression, forged quality, Character-sheet content, central combat balance, beam cooldown/clash tuning, Dragon Nova/Sky Break, skill routing, character creation, serialization, technology catalog invariants, and text handling. It runs against both versioned and clean runtime data in the full smoke baseline.

For headless compile coverage, `.\tools\Invoke-ByondSmoke.ps1 -CompileOnly` compiles the complete environment with BYOND 516.1685, requires zero errors and warnings plus both `DU.dmb` and `DU.rsc`, and does not start Dream Daemon. The default command performs the same compile before running startup assertions.

## Files
- `src/Code/Tests/StartupSmoke.dm`

## Proc Reference

### src/Code/Tests/StartupSmoke.dm

#### mob/NexusSmokeTest/New
- Signature: `New()`
- Inputs: None
- Purpose: Create an isolated mob without normal player initialization.
- Returns: none (implicit).
- Side effects: none expected.

#### proc/nexusSmokeAssert
- Signature: `proc/nexusSmokeAssert(condition, message)`
- Inputs: condition, message
- Purpose: Stop the smoke run with a runtime diagnostic when an invariant fails.
- Returns: none (implicit).
- Side effects: calls `CRASH()` on failure.

#### proc/nexusSmokeStatAllocation
- Signature: `proc/nexusSmokeStatAllocation(list/profile)`
- Inputs: a creation profile containing `budget` and `caps`.
- Purpose: Build a complete manual allocation by distributing points across all eleven `NEXUS_CREATION_STATS` without exceeding any cached cap.
- Returns: an associative stat-ID-to-point-count list whose total equals the profile budget.
- Side effects: calls `CRASH()` if the supplied profile has insufficient total capacity.

#### proc/runStartupSmokeTests
- Signature: `proc/runStartupSmokeTests(soul_contract_count_before)`
- Inputs: soul_contract_count_before
- Purpose: Validate admin access paths, combat/HUD/skill invariants, roleplay combat, professions, Character-sheet content, creator allocation and appearance, serialization and migration, technology catalog invariants, and text handling.
- Returns: none (implicit).
- Side effects: creates and deletes test mobs and writes the success marker to `world.log`.

## Admin Coverage
- Verifies both admin-log viewers are absent from `/mob/verb` and present under `/mob/Admin1/verb`.
- Verifies cumulative legacy admin verbs and the Tenkaichi package sizes (including the dedicated rock package), hotbar/impact icon mapping, weapon/kick/grapple audio profiles, adjacent targeting fallback, valid-grab execution, Dash Attack controlled movement, original Rock Throw/Rock Tomb/Dragon Nova/Sky Break art, Strength projectile scaling, visible projectile and floating-text actors, persistent Wall of Flame and beam routing.
- Verifies the lighting plane master and ambient alpha reset, additive emitters, all ten states and decreasing RGB intensity of the valid 256x256 CC0-derived gradient DMI, total tile-diameter conversion, configurable falloff, range-relative compact-core composition, distinct action/aura cleanup, cached projectile-icon sizing, small-versus-large projectile profiles, compact beam-trail intensity, physical-projectile exclusion, all flicker test verbs, adapted legacy light intensity, HUD plane isolation, and a representative transformation glow profile.

## Character-Creation Coverage
- Forces Anomaly and verifies all 11 registered internal stats are selected independently with percentages in `1..30`.
- Forces Common and verifies exactly one entry with a maximum of 10%; forces Uncommon and verifies exactly one with a maximum of 20%; forces Rare and verifies two or three entries with a maximum of 20%.
- Verifies mutation lists are not shared between mobs and every rolled ID exists in `CHARACTER_MUTATIONS`.
- Applies 10% Strength and 20% Speed entries and verifies multiplicative `1.1` and `1.2` modifier changes.
- Migrates a version-1 ID-only list to a version-2 associative entry at 10%, records the current schema version, and verifies an empty legacy character receives no retroactive entry.
- Serializes and reloads a 7% Common entry and its rarity alongside energy state.
- Builds the cached Human/Adaptability profile, creates a complete eleven-stat manual allocation, validates it, applies it through `Racial_Stats(..., stat_allocation=...)`, and verifies no points remain and `Max_Points` was initialized.
- Verifies Human Offense and Defense creation caps are below the full Human budget.
- Iterates every `Race_List()` race and every race-exclusive trait returned with Cooler enabled; every one of the eleven caps must be numeric and the profile's total cap capacity must be at least its budget.
- Applies a selected Human female body resource and verifies that the creator appearance path assigns an icon.
- Verifies Spirit Doll class/BP identity and forced Cooler class/variant initialization.
- Verifies the Human-equivalent base Saiyan multiplier, all five Exceptional BP/incoming packages, and the normalized Alien Apex Genome package.
- Verifies all 23 Alien AP definitions, every preset under 100 AP, rejection above 100 AP, and representative option effects.
- Verifies at least forty Frost icons, five-slot Cooler validation, independent Form1/Form5 assignment, and at least eighty starter clothes with the four-item limit.
- Verifies independent ownership for identical clothing icons, deterministic priority ordering, the primary transformation registry/conflict detector, SSJ eye-color states, and sustainable Exceptional progression coefficients.

The tier checks use `forced_rarity`; they verify tier shape and bounds without making the smoke suite probabilistic. Mutation information remains internal test state and must never be rendered or messaged to players.
