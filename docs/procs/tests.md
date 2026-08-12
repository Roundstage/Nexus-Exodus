# Tests

## Overview
Startup assertions run only when Dream Daemon receives the `nexus_smoke_tests` world parameter. The PowerShell smoke runner enables this parameter in an isolated temporary world. Player-music coverage pins the dedicated playback/validation channels, range and five-minute cap, upload/library quotas, clean-server first-upload authorization, safe account/track paths, title sanitization, one-extension policy, retained hotkey/server catalog, removal of the remote HTML streamer, preflight of a known-good compiled OGG resource, rejection of a disguised filename, exact-file decoder-telemetry filtering, bounded archive reconciliation, PENDING/READY duration/hash/policy boundaries, and persistence of account upload/playback/validation budgets plus ready metadata. Profile-art coverage pins PNG/JPEG/WEBP/WEBM preflight, WEBP RIFF signature plus VP8/VP8L/VP8X dimension extraction, WEBM EBML signature and dimension extraction, landscape/portrait 4K pixel bounds, safe account/slot/hash/inspection-request paths, byte bounds, exact raw-byte and SHA-1 preservation, format-correct resource aliases, generation cleanup, builder upload/playback/fallback controls, custom-art format/metadata serialization, immediate close-and-reopen verification, and non-default-to-SOUTH/empty/live-sprite reset persistence. The Docker build separately runs the binary inspector's synthetic WEBP/WEBM self-test before publishing the runtime image.

The startup suite covers opt-in defaults for NPCs, Feats, and automatic Tournaments; safe player-profile legacy migration, allowlisted rich markup, HTML text/attribute escaping, field limits, four-angle portrait selection, structured builder controls, profile serialization, and the compiled application-icon skin contract; admin log access paths, combat-dummy verb isolation and reset behavior, explicit dummy selection, compact vitals/action and dual-layout chat contracts, Combat-feed isolation, interface preference normalization, the permission-aware pixel shortcut strip with same-icon window toggles plus direct Progression, Milestones, Build, chat-integrated CMD and classic-menu access, modifier-safe arrow hotkeys, immediate and stateful browser scroll restoration, runtime object-sprite export, strict Skill-versus-item isolation, player-menu and Character-sheet removal of visible refresh internals, manual Character refresh, owned-only Character Milestones and dressed composite portraits, exact labeled prerequisites, smooth direct prerequisite curves with hover/focus highlighting, uncategorized Milestones and draggable progression navigation, canonical skill-tab activation plus target-independent unresisted damage, canonical melee/weapon/Ki parity, projectile direct-and-splash shared-budget reservation, requirements, and concrete buff/transformation effect examination, roleplay spacing/color preservation and theme-safe editor swatches, the 50-word overhead Say contract, grabbed-player attack rejection, pixel-radius vector pickups, wall-excluding obstacle steering, the rustic shared browser theme, three-slot path isolation and clamping, reconnect lobby handoff and title-view isolation, labeled vitals and exact Energy formatting, Say above Typing above the character plus player-positionable lower bars ordered Willpower/Health/Energy and Sense percentage beneath them, persisted main-vitals placement, multiplicative night lighting, additive glow planes, movable attached lights, projectile/beam/aura/explosion flicker profiles, generated Black Flash critical effects, mutation admin verbs, reversible mutation editing/rerolling, synchronized lethal intent, damage-free ordinary aura, RP Mode grab immunity, lethal-only regeneration drain, zero-Willpower KO, Android/LSSJ/Jiren Anger exclusion and stale-state normalization, nonlethal Kaioken Willpower upkeep, Mining/Smithing progression, Normal-to-Copper forged weapon/glove/mask/armor quality, Science Foundation forge access, Meditate Level 2 and Shockwave Foundation access, mask blast/Ki scaling and Science replacement recipes, relog/equipment/Giant Form overlay reconstruction, one-tick targeted Dash Attack pass-through, linear power-gap combat balance, uncapped Beam Lock, beam-clash marker/input tuning, restored Dragon Rush cadence, full navigation hotkeys, Dragon Nova/Sky Break/Echoing Slash, skill routing, character creation, serialization, technology catalog invariants, and text handling. It runs against both versioned and clean runtime data in the full smoke baseline.

UI regression coverage also pins the embedded Silkscreen pixel-font resources, scoped bronze player and blue admin HUD contracts, the 2x2 `#c6a15c` bolt recipe, runtime atom-sprite rendering, and the canonical frame sizes of `UserNamesBarsUi.png`, `LethalHud.dmi`, and `RPModeHud.dmi`.

For headless compile coverage, `.\tools\Invoke-ByondSmoke.ps1 -CompileOnly` compiles the complete environment with BYOND 516.1686, requires zero errors and warnings plus both `DU.dmb` and `DU.rsc`, and does not start Dream Daemon. The default command performs the same compile before running startup assertions.

Pass `-ProfileMediaInspectorPythonPath <python>` to the smoke runner to start the Docker profile-media inspector beside each temporary world and exercise the real DM-to-inspector request/result protocol with a binary WEBP fixture. Without that option, the DM suite uses an isolated fake responder to keep the ordinary BYOND-only baseline dependency-free.

## Playtest rewards

Self-service player rewards are disabled by default and fail closed in a live runtime. A dedicated, isolated playtest runtime must start with both exact world parameters `nexus_environment=playtest` and `nexus_playtest_rewards=1`. Within that immutable playtest environment, a level-four administrator can disable or re-enable the verbs for the current session with **Toggle Playtest Rewards**. Unknown parameter values fail closed, and the admin toggle cannot convert a running live server into a playtest server.

Playtest character and Feat files use the separate `data/Playtest/Save` and `data/Playtest/Feats` namespaces and carry an environment marker that prevents cross-loading. The host must still run the playtest from its own complete runtime directory: world items and server state exist outside character saves, so a live runtime directory must never be reused for a playtest. Promote no playtest persistence back to live; migrate any approved cosmetic later through an explicit allowlist.

While enabled, six verbs appear in the **Playtest** category: the complete reward bundle, Resources plus Arcane Essence (the game's mana currency), Progression XP, Milestone Points, normalized combat-stat and Energy capping, and relative base-BP matching. Currency and Progression grants are fixed, versioned, saved, and claimable once per character. Milestones stop at the authoritative 22-point lifetime cap. The stat operation raises all seven combat stats to the server-observed cap and base Energy to `energy_cap`, preserving the character's Efficiency multiplier and refilling current Energy. Stat and BP operations only raise permanent values; BP uses the strongest relative base recorded this wipe plus the current online scan, and Androids receive equivalent cybernetic BP instead of invalid natural BP. Every verb is self-only, accepts no player-supplied value, is rate-limited, rechecks server authorization, and writes an audit record.

## Files
- `src/Code/Tests/PlaytestVerbs.dm`
- `src/Code/Tests/StartupSmoke.dm`

### src/Code/Tests/PlaytestVerbs.dm

- `configureNexusPlaytestRewards()` reads the exact server-owned opt-in and synchronizes the isolated verb set.
- `claimNexusPlaytestCurrencies()`, `claimNexusPlaytestProgression()`, and `claimNexusPlaytestMilestones()` apply bounded, persistent self-service rewards.
- `capNexusPlaytestStats()` caps seven combat stats plus Efficiency-scaled Energy, and `applyNexusPlaytestRelativeBaseBP()` caps BP without accepting client-authored numbers.
- `runNexusPlaytestRewardSmokeTests()` covers fail-closed activation, one-time grants, the 22-point lifetime cap, stat normalization, and Android BP behavior.

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
- Verifies cumulative legacy admin verbs and the Nexus package sizes (including the dedicated rock package), hotbar/impact icon mapping, weapon/kick/grapple audio profiles, adjacent targeting fallback, valid-grab execution, Dash Attack controlled movement, original Rock Throw/Rock Tomb/Dragon Nova/Sky Break/Echoing Slash art, Strength projectile scaling, sword-wave presentation, shared named-projectile impact fallback, visible projectile and floating-text actors, persistent Wall of Flame and beam routing.
- Verifies the lighting plane master and ambient alpha reset, additive emitters, all ten states and decreasing RGB intensity of the valid 256x256 CC0-derived gradient DMI, total tile-diameter conversion, configurable falloff, range-relative compact-core composition, distinct action/aura cleanup, cached projectile-icon sizing, small-versus-large projectile profiles, compact beam-trail intensity, physical-projectile exclusion, large explosion-light intensity/flicker, explosive-beam knockback, all flicker test verbs, adapted legacy light intensity, HUD plane isolation, and a representative transformation glow profile.

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
- Verifies every Heran owns one transformation, its activation is one canonical primary state, its male integrated body and green glow apply, reversion restores the original body with zero residual BP, and its additive result equals rather than exceeds standard SSJ1.

The tier checks use `forced_rarity`; they verify tier shape and bounds without making the smoke suite probabilistic. Mutation information remains internal test state and must never be rendered or messaged to players.

Map-zoom coverage verifies bounded wheel direction, the fixed render-envelope scale, mouse-enabled world plane masters, exclusion of the fixed HUD plane, and separation of screen-space vitals/buttons from world-space overhead bars.

## Progression and Milestone coverage

- Verifies all six Progression categories, every racial node's lower-tier prerequisite, owner-only Kaioshin rendering, server-side rejection of Daimao nodes for a Kai, and tier-ten/60-XP Hakai apex nodes for both Kaioshin and Daimao.
- Verifies targetless three-tile Wind Howl, accelerated Pressure Punch, three budgeted Super Ghost projectiles, defensive four-tile Super Explosive Wave blast interception/repulsion, and ground-only five-tile Earthquake inward pull configuration. It also verifies Shockwave inheritance and that the restored skills are registered in their authored Ki or Physical branches.
- Verifies explicit Open Combat impact states and semantic sound banks for the repaginated Unarmed skills, plus elemental Foozle icons/impact states for Fireball, Frost Bolt and Lightning Bolt.
- Verifies Versatile Training stat multiplication, mutually exclusive Momentum damage scaling, conditional weaponless/armorless Offense and Defense, three-tile melee area, double-attack chance, critical chance, and Fire Lord's target Burn-stack calculation.
- Verifies zero-argument Skill-menu dispatch, same-area Sense examination authorization, equal-BP/zero-defense parity for canonical melee, physical, Ki, hybrid, weapon, and projectile previews, runtime-ordered direct/splash reservation through shared projectile budgets, custom raw damage profiles, concrete Great Ape effects, 50% effective Empowered Defense stats, Frost Nova damage/stun against clientless targets, Earth Prison's complete 40-wall perimeter, Gravity Well turf application/restoration, and visible masterwork enchantment results.

## Alien Time Stop coverage

- Verifies the renderable 512x512 Time Stop domain DMI and its explicit `void` state, dedicated above-lighting visual actor, eight-tile radius, eight-tick windup, equal-stat six-second pre-modifier stun, 75% Time Normalizer mitigation, and rejection of RP Mode and Safezone targets.
