# Viltrumite Wipe Plan

## Implementation status

The race/creator foundation is implemented: standard Viltrumite, Royal Blood, one unique Grand Regent creation followed by admin-only succession, birth-gated Half-Viltrumite and Royal Hybrid inheritance, saved lineage metadata, five-percent hidden Scourge genetics, guaranteed Royal/Regent immunity, Viltrumite language, balance hooks, and race-restricted starter clothing with three initial DMI outfits. Full and Half-Viltrumites temporarily resolve to the Saiyan spawn until the dedicated Viltrum surface exists. Both have Intelligence `1`, no natural decline, and no finite lifespan. The Earth/Viltrum 500x500 map replacement, one-way discovery/invasion progression, and contagious forced-death Scourge event remain later phases.

## Scope

This wipe reduces the living world to two large planetary surfaces plus space:

- Earth houses every non-Viltrumite race.
- Viltrum houses Viltrumites and all Half-Viltrumites born after the wipe begins.
- Space separates the populations until players unlock interplanetary travel and Viltrum can invade Earth.

The first implementation should establish the maps, spawn rules, race packages, rare bloodlines, hybrid rules, and creation clothing filters. Custom Viltrumite body and clothing art can replace placeholders later without changing the underlying race design.

## Non-negotiable design goals

1. Standard Viltrumites have high natural BP and health regeneration but low discretionary combat stats.
2. The Grand Regent is an Exceptional-tier apex character.
3. At creation and during the early wipe, the Grand Regent must be competitive with the strongest changeling package used for the Icer era.
4. At mature sustainable progression, the Grand Regent must be competitive with the wipe's Legendary Saiyan.
5. The balance model must cover the Grand Regent facing Legendary Saiyan and Cooler at the same time during the Earth-Viltrum war.
6. Grand Regents have no Anger and cannot allocate points to Anger, receive Anger mutations, or trigger Anger effects.
7. Royal Blood is a stat-focused rare lineage, not a weaker copy of the Grand Regent.
8. Half-Viltrumites trade some immediate Viltrumite power for stronger stats and long-term flexibility. Royal hybrid ancestry improves that package.
9. Viltrumite creation shows only Viltrumite-approved starter clothing.
10. Space access must be gated by progression or a world event. Distance alone is not a reliable gate.
11. The Scourge Virus exists as a last-resort weapon against Viltrumite genetics. Only characters with Scourge immunity survive its complete course; Royal lineages and the Grand Regent are always immune.

## Current balance model

`docs/Balance/SkillDamageBalance.xlsx` is the authoritative live model. `docs/Balance/RaceBalance.md` defines two tiers:

| Tier | Target index | Allowed band |
|---|---:|---:|
| Standard | 100 | 90-110 |
| Exceptional | 125 | 112.5-137.5 |

The workbook treats creation as diagnostic and compares mature characters at equal relative natural progression, `R`. The authoritative sustainable stage is S2.

Current reference packages:

| Profile | Effective creation BP coefficient | Incoming damage | S2 sustainable BP/R | Important context |
|---|---:|---:|---:|---|
| Human | 1.33 | 1.00 | 25.923 | Standard baseline with high stat budget |
| Saiyan | 1.54 | 1.00 | 24.699 in mastered SSJ4 | Standard, transformation-dependent |
| Half Saiyan | 1.725 | 1.00 | 22.132 in mastered SSJ4 | Standard with very high Anger ceiling |
| Legendary Saiyan | 3.30 | 0.90 | 33.079 in Legendary SSJ1 | Exceptional, no Anger |
| Frost Lord | 1.68 | 1.00 | 22.242 in Final Form | Standard changeling |
| Cooler | 1.596 before form additions | 0.89 | 33.120 in Fifth Form | Exceptional changeling benchmark |
| Bio-Android | 2.31 | 0.89 | 33.062 in Perfect Form | Exceptional with regeneration and absorption |
| Majin | 2.8815 | 0.96 | 33.115 with Majin buff | Exceptional with extreme regeneration |
| Android | 1.35 natural; cyber progression external | 0.55 | Scenario-dependent | Exceptional because of cyber BP, modules, and resistance |

The existing Exceptional sustainable target is therefore approximately `33R`. Legendary Saiyan, Cooler, Bio-Android, and Majin intentionally converge near this value through different mechanics.

### Relevant live hooks

- `Get_race_starting_bp_mod()` defines the persisted race BP growth modifier.
- `racialCombatBPMult()` applies a centralized combat-only BP multiplier.
- `racialDamageTakenMult()` applies passive incoming-damage tuning.
- `ApplyRaceBuild()` and `RaceBonusStatPoints()` define free racial stats and discretionary creation budget.
- `StatRaceCapped()` and its helpers define per-stat racial caps.
- `canPossessAnger()` and `disableAnger()` govern creation allocation, mutations, Anger gain, and runtime normalization.
- `nexusCreationStatProfile()` exposes the real initialized race package in the character creator.
- Startup smoke tests pin creation budgets, BP coefficients, incoming-damage multipliers, and sustainable Exceptional targets.

## Regeneration terminology

The code has three separate concepts which must not be confused:

- `regen`: ordinary health regeneration.
- `recov`: Ki and energy recovery.
- `Regenerate`: death regeneration, used by races that can rebuild or return after an otherwise lethal defeat.

Viltrumites should receive high `regen`, not automatic death regeneration. `Regenerate` should remain `0` unless a later design explicitly introduces Viltrumite resurrection. This prevents high healing from compounding with Grand Regent resistance into an unintended tier above LSSJ and Cooler.

## Proposed race structure

Use one initially selectable race plus a hybrid race produced through post-start family play, with saved lineage metadata:

- `Viltrumite`
  - `Standard`
  - `Royal Blood`
  - `Grand Regent`
- `Half-Viltrumite`
  - `Human Hybrid`
  - `Royal Hybrid`

Do not expose the Grand Regent as a separate race. It should be a rare trait/class under Viltrumite so all shared Viltrumite rules remain centralized.

Half-Viltrumite must not appear as a selectable race when the wipe begins. The lineage becomes available only through valid Human-Viltrumite parentage after play has started. Every Half-Viltrumite begins on Viltrum regardless of the Human parent's origin.

Add a saved lineage identifier such as `viltrumite_lineage` instead of inferring ancestry from display names. Suggested values are `standard`, `royal`, `grand_regent`, `hybrid`, and `royal_hybrid`. Keep `Class` populated for compatibility with existing UI and admin systems, but use the lineage identifier for rules that must survive future class or title changes.

## Provisional balance packages

These values are starting hypotheses for workbook modeling and matchup tests. They are not final tuning values.

### Standard Viltrumite

Target: upper Standard tier, approximately index 103-110.

Suggested initial package:

| Dimension | Provisional direction |
|---|---|
| Starting BP modifier | Approximately 2.3-2.5 |
| Combat BP multiplier | Reduce the raw modifier to approximately 1.65-1.75 effective creation BP |
| Incoming damage | 1.00 |
| Creation budget | Approximately 30-36 points |
| Primary caps | Approximately 2.0, with no broad high-stat exception |
| Health regeneration | High baseline and cap, initially model around 1.8-2.2 baseline and 3.0-3.6 cap |
| Recovery | Moderate; do not give both top-tier health regeneration and top-tier Ki recovery |
| Anger | Normal but modest, initially cap near 130-150 |
| Environment | `Lungs = 1`; strong gravity mastery; no natural decline or lifespan limit |
| Transformations | None |

A useful first numeric trial is `bp_mod = 2.4` with `racialCombatBPMult = 0.70`, producing an effective creation coefficient of `1.68`, equal to the current standard Frost Lord before form additions. The Viltrumite then trades Frost transformations for better persistent health regeneration and physical utility.

The high persisted BP modifier preserves the fantasy that scanners see a naturally powerful race. The centralized combat multiplier prevents that fantasy from silently placing every Viltrumite in the Exceptional tier.

### Royal Blood

Target: top of Standard tier, or a narrowly bounded intermediate package below Exceptional.

Royal Blood should primarily improve stats:

- Increase discretionary creation budget relative to standard Viltrumites.
- Raise selected primary caps, preferably Strength, Endurance, Resistance, Offense, and Defense.
- Add only a small BP increase, if any.
- Keep incoming damage at `1.00` unless tests show that the lineage cannot reach its intended position.
- Preserve Anger unless later lore requires otherwise.
- Do not give Grand Regent damage resistance.

Royal Blood can be obtained through the rare creation result or inherited through the player-family system. A child receives Royal ancestry only from a Royal Blood parent. The Grand Regent title and package do not count as inheritable Royal Blood.

Initial modeling should compare a 40-46 point Royal budget with 2.3-2.5 selected caps against Human, Half Saiyan, Heran, and Demigod. If Royal Blood exceeds index 110 at S0 or S2, reduce free stats or BP before adding passive resistance.

### Half-Viltrumite

Target: Standard tier with better stats and lower immediate BP than a full Viltrumite.

Suggested direction:

- Effective creation BP below standard Viltrumite, approximately 1.50-1.65.
- Creation budget around 42-48.
- Primary caps around 2.3-2.5.
- Health regeneration below full Viltrumite but above Human.
- Better recovery, mastery, or adaptability than full Viltrumites.
- Normal Anger. Avoid Half-Saiyan's extreme 400 Anger ceiling.
- Space breathing should be retained unless the setting intentionally makes the human side dominant.
- No Grand Regent inheritance through ordinary hybrid creation.
- A child of the Grand Regent and a Human is always a normal Half-Viltrumite. The child inherits neither the Grand Regent package nor Royal Hybrid status from the Regent.
- Every hybrid starts on Viltrum and no hybrids exist at initial wipe launch.

### Royal Hybrid

Target: upper Standard tier and clearly stronger than a normal Half-Viltrumite without reaching the Grand Regent.

Suggested direction:

- Selected caps and free stats above the normal hybrid.
- Small BP increase over the normal hybrid.
- No passive damage resistance at first.
- Rare availability tied to Royal Blood ancestry or an explicit rare creation result.
- Keep the package below the lower bound of Exceptional at all ordinary sustainable stages.
- Royal Hybrid is inherited from a Royal Blood parent and is always immune to the Scourge Virus.

### Grand Regent

Target: Exceptional tier, with two mandatory benchmarks.

#### Benchmark A: early-wipe changeling parity

At creation and early progression, a Grand Regent must be competitive with the strongest Icer-era changeling package. The test must use the changeling's strongest sustainable native form, not its untransformed creation coefficient.

Acceptance target:

- Grand Regent versus forced Cooler/changeling at matched allocation and intended early-wipe progression.
- Damage output, incoming damage, and time-to-defeat should remain within approximately 5-10% across mirrored physical and Ki builds.
- Run tests both with equal displayed BP and with each lineage's natural creation BP so stat and formula differences remain visible.

#### Benchmark B: mature LSSJ parity

At equal relative natural progression, a Grand Regent's best sustainable package should land near `33R`, matching LSSJ's `33.079R` target.

Acceptance target:

- Sustainable BP/R between approximately 31.5 and 34.5 during initial tuning.
- Final matchup performance within approximately 5% of LSSJ for neutral builds and within 10% for specialized builds.
- Incoming damage multiplier begins at `0.90`, exactly matching current LSSJ resistance.
- No Anger allocation, mutation, gain, or second wind.
- No normal transformation multiplier.
- No stacking of a separate Grand Regent buff that pushes the package beyond the benchmark.

One useful initial mathematical trial is:

```text
Grand Regent creation coefficient = Viltrumite bp_mod 2.4 * Grand Regent combat multiplier 1.375 = 3.30
Grand Regent S2 target = mature natural coefficient 24.0 * 1.375 = 33.0R
```

This exactly matches LSSJ's current creation coefficient and sustainable target before stat and regeneration effects. The mature natural coefficient must be produced through the normal ascension/growth model, not written as a second hidden combat multiplier.

Because the Grand Regent also has Viltrumite health regeneration, numeric BP equality does not guarantee matchup equality. If the Regent consistently outlasts LSSJ and Cooler, tune in this order:

1. Reduce Grand Regent health regeneration toward standard Viltrumite levels.
2. Reduce free defensive stats or their caps.
3. Slightly reduce the Grand Regent combat multiplier.
4. Change incoming damage away from `0.90` only as a last resort, because LSSJ-like resistance is part of the lineage identity.

Do not compensate by granting LSSJ-style transformation growth to the Regent. Its identity is stable, always-available apex power.

## Faction-war balance

The wipe is an all-out war between Earth and Viltrum. Race balance therefore needs two layers:

- Individual balance determines whether one lineage invalidates another in ordinary encounters.
- Faction balance determines whether either planet can assemble a viable military force from its expected population and rare lineages.

The Grand Regent may face Legendary Saiyan and Cooler simultaneously. This should be an explicit coalition benchmark, but it should not make the Regent numerically equal to their combined power in every situation. A Regent tuned to reliably defeat both apex opponents alone would dominate either one in a duel and would likely exceed the current Exceptional tier once regeneration and Viltrumite allies are included.

Recommended war target:

- The Grand Regent is approximately even with either LSSJ or Cooler in a clean duel.
- Against LSSJ and Cooler together, the Grand Regent has a credible chance to win, can survive sustained focus, and can create meaningful pressure on both opponents.
- LSSJ plus Cooler should remain a dangerous matchup rather than a guaranteed Regent victory. Initial playtest tuning should seek a meaningful Regent win rate rather than predetermined defeat or dominance.
- The Grand Regent should not be rapidly deleted before Viltrumite reinforcements can affect the battle.
- Grand Regent plus one or two capable standard or Royal Viltrumites should be a credible match for LSSJ plus Cooler.
- The full faction result should depend on army composition, coordination, resources, equipment, terrain, and objectives rather than one lineage deciding the war alone.

This target should initially be achieved through Viltrumite durability and recovery rather than doubling the Regent's BP. BP directly affects damage output and several combat thresholds, so excessive BP would make the Regent oppressive in every smaller encounter. Controlled anti-focus mechanics can be considered only if ordinary durability cannot produce a healthy war encounter. Any such mechanic must activate only when multiple independent hostile players are attacking and must have a strict cap; it must never become a permanent duel bonus.

The war model should record expected roster assumptions for each test, including:

- Total active players on Earth and Viltrum
- Number of standard fighters per side
- Availability of LSSJ, Cooler, Grand Regent, Royal Blood, and Royal Hybrids
- Expected equipment and progression stage
- Whether the battle occurs on Earth, Viltrum, or in space
- Defensive structures and planetary-control bonuses
- Respawn, recovery, and travel time after defeat

Population rules are part of balance. The intended Viltrum apex roster is one Grand Regent and approximately three Royal Blood Viltrumites, while Earth can field more distinct rare lineages, including LSSJ and Cooler. The Regent therefore needs a credible chance in the LSSJ-plus-Cooler matchup, and the Royals provide the rest of Viltrum's elite force. The solution should still avoid an unlimited Grand Regent multiplier that makes smaller encounters meaningless.

## Scourge Virus

The Scourge Virus is a strategic last resort for the Earth-Viltrum war. It is not an ordinary combat debuff or a routine craftable poison. Deployment should be a major world event with visible consequences, counterplay before release, and strict authorization.

### Biological scope

The initial susceptibility contract is:

| Character | Result |
|---|---|
| Standard Viltrumite without the survival mutation | Fatal infection |
| Standard Viltrumite with the survival mutation | Survives and becomes immune |
| Royal Blood Viltrumite | Always survives; innately immune |
| Grand Regent | Always survives; innately immune |
| Half-Viltrumite without the survival mutation | Susceptible by default |
| Half-Viltrumite with the survival mutation | Survives and becomes immune |
| Royal Hybrid | Always survives; Royal ancestry grants full immunity |
| Non-Viltrumite | Cannot contract the Viltrumite-targeted disease |

Royal immunity should come from the saved lineage identifier, not `Class` text alone. Grand Regent immunity should be checked explicitly even if the Regent is also considered Royal in the lore.

### Survival mutation

Add a named persistent mutation such as `scourge_resistance`. It should be rolled once when an eligible Viltrumite or Half-Viltrumite character is created and saved permanently.

The existing `CHARACTER_MUTATIONS` system currently models percentage-based stat mutations. Every registered mutation is expected to have a stat and to apply a numeric multiplier. Scourge resistance is binary and race-restricted, so implementation must either:

1. Extend `datum/CharacterMutation` with a mutation kind, allowed races, and non-stat effects; or
2. Create a separate saved Viltrumite genetic-trait list dedicated to binary lineage mutations.

The second option is safer for the first implementation. It avoids changing the meaning of the existing rarity categories, mutation counts, admin stat editor, mutagen limits, and percentage normalization. Suggested saved state:

```text
viltrumite_genetic_version
viltrumite_genetic_traits = list("scourge_resistance" = TRUE)
```

Use one centralized proc such as `hasScourgeImmunity()`:

```text
immune when lineage is grand_regent
or lineage is royal
or lineage is royal_hybrid
or viltrumite_genetic_traits contains scourge_resistance
```

Do not infer immunity from high Resistance, regeneration, BP, equipment, current health, or mutation rarity. Those can modify symptom timing only if later desired; they must not change the final survival result.

The resistance roll should be cached and committed exactly once. Reopening character creation, reconnecting, reincarnating, or entering a disease zone must not reroll it. An admin test initializer should be able to force immune and susceptible characters deterministically.

The natural `scourge_resistance` chance is 5% for eligible ordinary Viltrumites and Half-Viltrumites. A 5% roll has a 35.8% chance of producing no mutation survivor among twenty ordinary Viltrumites, so guaranteed Royal and Grand Regent survivors are important to continuity.

### Disease architecture

Do not reuse `Zombie_Virus` as the Scourge state. The zombie system is a numeric infection strength tied to health loss, zombie conversion, body conversion, and planet-wide antivirus behavior. The Scourge needs its own saved infection state and lifecycle.

Suggested state:

```text
scourge_status = unexposed | incubating | symptomatic | critical | recovered | immune
scourge_exposure_time
scourge_stage_time
scourge_source_id
scourge_strain_version
```

Suggested progression:

1. **Exposure:** a valid release source exposes susceptible Viltrumite genetics within its configured scope.
2. **Incubation:** the carrier receives limited or ambiguous feedback and may transport the virus.
3. **Symptoms:** health regeneration, recovery, movement, BP availability, or combat stats deteriorate in clearly communicated steps.
4. **Critical:** ordinary healing cannot reverse the disease and the character is visibly near death.
5. **Resolution:** immune characters recover and become marked immune; susceptible characters receive the configured fatal outcome.

Immunity must resolve before symptoms and damage are applied. Royals, Royal Hybrids, Grand Regents, and mutation survivors may still receive a short exposure notification, but they should not enter a damaging infection loop.

Use one subsystem or scheduled disease controller rather than starting an unbounded loop per exposure. The controller should process a bounded batch per tick, survive reconnects through saved timestamps, and stop cleanly after recovery or death.

### Transmission and deployment

The Scourge spreads contagiously between characters. It does not infect an entire planet immediately on release. The initial weapon or carrier creates the first exposure, after which infected Viltrumites and Half-Viltrumites can transmit it through the configured proximity or contact rule during contagious stages.

A deployable Scourge source should require a unique story/admin item, a long interruptible activation, a global warning, and an audit log. It must not be available through ordinary crafting, duplication, trading, materialization, or generic item spawning.

Recommended release contract:

- The source records who armed and released it.
- Deployment announces the release location and a countdown without converting the entire planet into an exposure zone.
- Destroying or disarming the source before release prevents exposure.
- Release is idempotent; repeated clicks cannot create duplicate disease controllers.
- Tournament, battleground, login, character-creation, and afterlife areas are excluded.
- Planet identity uses the existing planet-region/control resolver so caves, buildings, and ships follow explicit policy rather than raw Z-level assumptions.
- Newly arriving characters are safe unless they encounter an active contagious carrier or the initial release source.
- Leaving the planet after infection does not clear the saved disease.
- Carrier-to-carrier transmission must use a cooldown or exposure ledger so one nearby player cannot be processed repeatedly every tick.
- The contagious window, proximity, contact rules, and whether ships can carry the outbreak between planets must be explicit settings.

### Fatal outcome and continuity

The final outcome for a susceptible character is forced death so Viltrumite healing or death regeneration cannot defeat the virus. Record Scourge as the cause and call the existing forced-death path. Do not delete savefiles or convert the result into wipe-level character retirement. This keeps the event auditable and preserves the server's ordinary afterlife and character-data rules.

After a release, Viltrumite faction continuity is guaranteed by Royal Blood, Royal Hybrids, and the Grand Regent. Mutation survivors create the small non-Royal remnant. The system should publish aggregate survivor counts only after the event resolves. No player-facing scan, laboratory test, character sheet, or administrator-triggered public message may reveal an ordinary character's survival mutation before exposure.

No cure can be developed during this wipe. Survival is exclusively genetic. Admin recovery may clear an infection caused by a bug or accidental test, but it is an operational safeguard and must not exist as an obtainable in-world cure.

### Balance impact

Scourge immunity is strategic value, not ordinary combat power. Do not charge stat points or reduce BP for the mutation. Its value exists only if the last-resort event occurs.

The virus changes faction-war assumptions:

- Earth can threaten Viltrum without defeating every Viltrumite directly.
- Viltrum has a reason to protect laboratories, launch facilities, intelligence, and Royal continuity.
- Royals and the Grand Regent become post-Scourge leadership anchors.
- Ordinary immune Viltrumites become rare strategic survivors without receiving an additional combat bonus.
- A Scourge victory should not automatically end every objective; surviving Viltrumites must retain a playable path.

## Rare lineage availability

The code currently uses several different rare mechanisms:

- Legendary Saiyan is removed while another LSSJ exists, during the first ten minutes after reboot, and during a ten-minute creation cooldown.
- Cooler is exposed through a rare availability result and otherwise remains hidden.
- Ancient lineages cache a 5% candidate roll and also enforce an online population ratio.
- Elite Saiyan checks minimum population and an online ratio.

Recommended Grand Regent policy:

- Cache the eligibility roll on the creation mob so reopening the creator cannot reroll it.
- Allow exactly one Grand Regent slot unless an administrator changes the event policy.
- Once assigned, the slot never reopens automatically because of logout, death, permanent death, character deletion, or inactivity.
- Only an explicit, audit-logged administrator succession action can transfer or reopen the slot.
- Do not derive slot availability from the online player list or preview mobs.
- Provide a private admin test override without changing the production one-slot succession policy.
- Provide a forced initializer for deterministic startup and combat tests.
- Persist the assigned account/character identity outside the online population list so server reboots cannot accidentally create a second Regent.

Recommended Royal Blood policy:

- Cached rare creation roll, tuned to produce approximately three initial Royal Blood Viltrumites for the expected launch population.
- Support Royal Blood inheritance through player families after creation.
- Track creation and inherited Royals against the same intended active roster so inheritance cannot silently create an unlimited apex population.
- Separate admin override.
- Royal Hybrid availability uses saved ancestry from a Royal Blood parent. Grand Regent parentage always produces a normal hybrid instead.

## Character creation changes

The current creator needs updates in these areas:

1. Add both races to `Race_List()` and `InitializeRaceTemplate()`.
2. Add race descriptions, icon options, and lineage traits.
3. Add forced trait parameters or a more general trait initializer for tests.
4. Treat Grand Regent as Angerless in `nexusCreationCanAllocateAnger()` and the central Anger contract.
5. Add creation stat profiles through the normal initialized preview path.
6. Validate rare traits again during commit so a stale browser page cannot bypass population rules.
7. Add saved lineage metadata and normalize older or invalid values on load.
8. Add a review-screen label that uses the display name rather than the raw trait identifier.

### Clothing filter

The starter catalog currently enumerates every `/obj/items/Clothes` subtype and exposes the same list to every race. Add metadata on clothing objects, for example:

```text
starter_collection = "general"
starter_races = null
```

Viltrumite clothing can use `starter_collection = "viltrumite"` and `starter_races = list("Viltrumite", "Half-Viltrumite")`.

The creator should build and validate clothing options for the selected race. Server-side validation must use the same filter; hiding options in HTML is not sufficient. For the wipe:

- Full Viltrumites see only Viltrumite-approved clothing.
- Half-Viltrumites see Viltrumite clothing when their post-start character is created and always begin on Viltrum.
- Other races must not see Viltrumite military or royal starter clothing.
- Royal and Grand Regent attire may require lineage metadata in addition to race metadata.
- Custom clothing uploads remain enabled for Viltrumite and Half-Viltrumite creation. Uploaded layers count as the character's Viltrumite clothing and remain subject to the normal icon validation and four-layer limit.

Suggested initial collections:

- Viltrumite civilian
- Viltrumite military
- Viltrumite officer
- Royal
- Grand Regent

## World and map architecture

The current world uses fifteen surface/interior Z-levels in `Map2018.dmm` plus four space Z-levels in `Space2018.dmm`. Planet code assumes 500x500 coordinates in several places. Space planet objects contain destination coordinates and navigation requirements. Planet maps, planetary control, areas, destruction, restoration, resources, clocks, dragon balls, spawn filtering, and teleport routing all depend on explicit registries or type switches.

The wipe should use dedicated constants rather than reusing misleading legacy names:

- `Z_LEVEL_EARTH`
- `Z_LEVEL_VILTRUM`
- `Z_LEVEL_SPACE`
- Any required interiors or caves after the two primary surfaces are stable

### Earth surface plan

Earth must support almost the entire non-Viltrumite player population. Use one full 500x500 surface on one Z-level.

Required regions:

- Central neutral city and primary social hub
- Multiple race/community districts or satellite settlements
- Technology and industrial region
- Wilderness and resource belts separating settlements
- Mountain or high-gravity training region
- Ocean/coastal region
- Hidden caves and ruins
- At least three invasion-capable landing corridors
- Several spawn points so population does not stack on one tile cluster
- Defensible planetary-control location that does not trap new players inside a ruler's base

Avoid assigning one permanent biome to each race. Earth should encourage travel and conflict between communities rather than reproduce the old planet separation inside a single map.

### Viltrum surface plan

Viltrum should communicate military hierarchy and scarcity rather than copy Earth with red terrain.

Use one full 500x500 surface on one Z-level.

Required regions:

- Imperial capital
- Grand Regent headquarters or throne
- Royal district
- Military academy and sparring grounds
- Civilian settlement
- Harsh wilderness
- Dangerous fauna or NPC territory
- Historical ruins or burial grounds
- Industrial/resource zone
- Space program and launch complex
- Hidden route or research chain used to unlock Earth travel
- Multiple return/defense landing zones for later invasions

The Grand Regent spawn should not provide exclusive access to all Viltrumite resources or the only path off-world.

### Space plan

Space is a progression layer, not only a travel map.

- Place Earth and Viltrum far enough apart to make ships meaningful after access opens.
- Gate the necessary navigation level, ship component, coordinates, or launch authorization.
- Keep admin and recovery paths so stranded players can be restored safely.
- Viltrum discovers and reaches Earth first. Earth cannot independently discover or navigate to Viltrum before first contact unlocks that knowledge.
- Add landmarks, hazards, and at least one neutral point of interest so space has gameplay after the invasion begins.
- Ensure both planet objects have correct surface arrival coordinates and map icons.

Earth is the only Dragon Ball planet. Viltrum has no Dragon Balls, and no Viltrumite-area type may enter the Dragon Ball spawn pool.

## Code integration inventory

Expected code touchpoints:

| Area | Primary files |
|---|---|
| Race templates | `src/Code/Races/Viltrumite/Viltrumite.dm`, `src/Code/Races/HalfViltrumite/HalfViltrumite.dm` |
| Race registration and availability | `src/Code/CoreFunctions/MainWorld.dm`, `src/Code/CoreFunctions/Main.dm` |
| BP and resistance | `src/Code/Races/Shared/RaceProgression.dm`, `src/Code/BackgroundCode/StatLoop.dm`, `src/Code/CoreFunctions/Vars/GlobalCombatSettings.dm` |
| Stats and caps | `src/Code/CoreFunctions/StatPoints.dm` |
| Anger contract | `src/Code/PlayerMechanics/Death.dm`, creation and mutation callers |
| Character creator | `src/Code/CharacterCreation/NexusCharacterCreation.dm` |
| Clothing | `src/Code/PlayerMechanics/Clothes.dm` and Viltrumite clothing subtype file |
| Scourge disease | New `src/Code/WorldMechanics/Diseases/ScourgeVirus.dm` subsystem |
| Scourge genetic immunity | New Viltrumite genetic-trait file or an extension of `src/Code/CharacterCreation/CharacterMutations.dm` |
| Scourge deployment/admin controls | Disease subsystem plus `src/Code/Admin/AdminPanel.dm` and a restricted event item definition |
| Z constants | `src/Code/CoreFunctions/Vars/WorldConstants.dm` |
| Areas and planetary environment | `src/Code/WorldMechanics/WeatherDayNight/Areas.dm` |
| Space planet objects and travel | `src/Code/WorldMechanics/Space.dm` |
| Spawns | Map-placed `/obj/Spawn` objects and `getRaceSpawnName()` only if aliases are needed |
| Planet map/scanning | `src/Code/UI/PlanetMapScanner.dm` |
| Planetary control | `src/Code/WorldMechanics/PlanetaryControl.dm` |
| Destruction/restoration | `src/Code/WorldMechanics/PlanetDestroy.dm` |
| Maps | `src/Maps/Map2018.dmm`, `src/Maps/Space2018.dmm`, or replacement wipe map files |
| Build includes | `DU.dme` |
| Runtime assertions | `src/Code/Tests/StartupSmoke.dm` |
| Numeric model | `docs/Balance/SkillDamageBalance.xlsx` generator and `docs/Balance/RaceBalance.md` |
| Proc reference | Relevant files under `docs/procs/` |

## Implementation sequence

### Phase 1: balance model before gameplay code

1. Add provisional rows for all five Viltrumite profiles to the race and progression balance sheets.
2. Model S0 through S5, including the Regent's no-Anger rule and health regeneration.
3. Lock the Grand Regent's two benchmark scenarios.
4. Select starting coefficients only after the rows land in their intended bands.

### Phase 2: race foundation

1. Add race files and saved lineage metadata.
2. Register races and templates.
3. Add standard and hybrid stats, caps, BP, environment traits, and lifespan.
4. Add Royal and Grand Regent trait application.
5. Add rare eligibility, cached rolls, population rules, admin overrides, and forced test initializers.

### Phase 3: creator and clothing

1. Add race descriptions, body placeholders, and traits.
2. Add race-aware clothing metadata, rendering, and server validation.
3. Preserve validated custom clothing uploads for Viltrumites and Half-Viltrumites.
4. Add lineage-aware royal and Regent clothing.
5. Keep Half-Viltrumite unavailable at wipe launch and connect later hybrid creation to the family system.

### Phase 4: map foundation

1. Establish one 500x500 Earth Z-level, one 500x500 Viltrum Z-level, and the final space constants.
2. Build terrain, areas, and spawns for Earth and Viltrum.
3. Add planet objects and space positions.
4. Register scan regions and planetary-control regions.
5. Wire destruction, restoration, gravity, atmosphere, clocks, resources, and teleport routes.

### Phase 5: discovery and invasion

1. Add the one-way discovery gate so Viltrum can find Earth first and Earth cannot find Viltrum independently before first contact.
2. Add progression feedback so players know what advances discovery.
3. Add first-contact and invasion landing behavior.
4. Verify recovery paths for destroyed planets, failed travel, and stranded ships.

### Phase 6: Scourge Virus

1. Add saved binary Viltrumite genetic traits and roll/migration rules.
2. Add the centralized immunity resolver with guaranteed Royal and Grand Regent immunity.
3. Add the saved disease state machine and bounded processing controller.
4. Add deterministic initial exposure and contagious character-to-character transmission APIs.
5. Add the restricted deployment source, countdown, cancellation, announcements, and audit logs.
6. Integrate forced death with existing death policy without deleting character saves.
7. Add admin inspection, forced exposure, operational infection reset for recovery from bugs, and event test controls. Do not add an in-world cure.

### Phase 7: art replacement

1. Add custom full-blood and hybrid body icons.
2. Add civilian, military, officer, royal, and Regent clothing.
3. Replace placeholders without changing saved lineage identifiers.
4. Run strict asset-reference and case audits.

## Required balance tests

Add deterministic startup assertions for:

- Standard Viltrumite effective creation BP and incoming damage.
- Standard Viltrumite creation budget, free stats, and every cap.
- Half-Viltrumite and Royal Hybrid packages.
- Royal Blood remaining below Exceptional bounds.
- Grand Regent effective creation coefficient near `3.30` for the first trial.
- Grand Regent incoming damage equal to `0.90` for the first trial.
- Grand Regent S2 sustainable BP near `33R`.
- Grand Regent inability to allocate or gain Anger.
- Grand Regent inability to roll or retain an Anger mutation.
- Cached rare rolls not changing when the creator is reopened.
- Grand Regent assignment persisting across logout, death, deletion, inactivity, and reboot.
- Only an audit-logged admin succession action reopening or transferring the Grand Regent slot.
- Royal creation and family-inheritance rules, including the intended approximately three-Royal launch roster.
- Grand Regent-Human parentage producing a normal Half-Viltrumite rather than a Royal Hybrid.
- Forced test initialization bypassing rarity without affecting production selection.
- Viltrumite clothing accepted for Viltrumites.
- General clothing rejected during full Viltrumite creation.
- Viltrumite military clothing rejected for other races.
- Valid custom clothing uploads remaining available to Viltrumites and Half-Viltrumites.
- Half-Viltrumite being unavailable at wipe launch and becoming available only through valid post-start family play.
- Viltrumite and post-start Half-Viltrumite spawn resolution to the temporary Saiyan spawn, then to Viltrum when its map lands.
- Earth and Viltrum planet-map region resolution.
- Space planet arrival coordinates and navigation gates.
- Earth navigation to Viltrum remaining locked until Viltrum initiates first contact.
- Dragon Balls spawning on Earth and never on Viltrum.
- Planetary control, destruction, and restoration support for both planets.
- Only Viltrumites and Half-Viltrumites can contract the Scourge Virus.
- Grand Regents, Royal Blood Viltrumites, and Royal Hybrids always resolve immune.
- An ordinary Viltrumite survives only when the saved `scourge_resistance` mutation is present.
- The ordinary survival mutation roll is exactly 5% and occurs once.
- Reopening creation, reconnecting, reincarnating, or repeated exposure never rerolls immunity.
- Immune exposure never enters a damaging symptom stage.
- Susceptible infection advances through every configured stage and reaches the configured fatal outcome.
- Disease timestamps resume correctly after saving and loading.
- Leaving the release planet does not cure an infected character.
- Infection spreads through configured character contact and does not instantly infect a whole planet.
- Excluded maps and areas cannot be contaminated.
- Duplicate release attempts do not create duplicate controllers or apply stages twice.
- The source actor, location, planet, strain, and release time are audit logged.
- Admin recovery can clear a mistaken infection without altering the character's genetic roll.
- No player-accessible cure, immunity test, or pre-release mutation detector exists.
- Susceptible terminal infection invokes forced death and bypasses regeneration.

Add matchup scenarios beyond startup assertions:

| Scenario | Builds | Measurement |
|---|---|---|
| Grand Regent vs Cooler | Neutral, physical, Ki | Damage per hit, hit rate, time-to-KO, time-to-defeat |
| Grand Regent vs LSSJ | Neutral, physical, Ki | Same metrics at equal `R` and normal powerup |
| Grand Regent vs LSSJ and Cooler | Neutral and specialized apex builds | Credible Regent win chance, focus-fire survival, pressure on each target, time-to-first-KO, escape capability |
| Grand Regent plus two Viltrumites vs LSSJ and Cooler | Expected war builds | Small-unit win rate, casualty rate, battle duration |
| Earth warband vs Viltrumite warband | Expected population ratios | Objective control, reinforcement time, casualties, resource cost |
| Standard Viltrumite vs Human | Neutral round-robin | Standard-tier index and duel result |
| Standard Viltrumite vs Saiyan | Untransformed and sustainable form | Early disadvantage and later matchup |
| Royal vs Half-Viltrumite | Neutral and specialized | Stat advantage without tier escape |
| Royal Hybrid vs Royal | Neutral and specialized | Hybrid flexibility versus full-blood BP |
| Grand Regent focus fire | Two and three Standard opponents | Regeneration and resistance under team pressure |

Regeneration must be tested under continuous damage. Out-of-combat healing measurements are not enough to determine combat durability.

## Map acceptance checks

- Both surfaces compile and start without warnings or runtimes.
- Every selectable race has at least one valid, non-dense spawn.
- All non-Viltrumite races resolve to Earth.
- Viltrumites and post-start Half-Viltrumites resolve to Viltrum after the temporary Saiyan-spawn bridge is removed.
- No ordinary creation route spawns a player in space.
- Players cannot reach the opposing planet before the intended gate opens.
- Planet scanners render both complete surfaces without exposing unrelated interiors.
- Planet control resolves correctly in surface areas, caves, buildings, ships, and telepads.
- Planet destruction moves ships and players to valid recovery locations.
- Resource placement supports the expected population without concentrating all high-value materials beside one faction.
- Earth has multiple viable invasion approaches.
- Viltrum's ruler location is contestable and does not block ordinary progression.
- Earth and Viltrum each occupy exactly one 500x500 surface Z-level.
- Viltrum reaches Earth first; Earth cannot discover Viltrum independently before first contact.
- Viltrum contains no Dragon Balls or valid Dragon Ball spawn areas.

## Confirmed wipe decisions

1. The Grand Regent slot reopens or transfers only through administrator succession.
2. Royal Blood is available through both rare creation and player-family inheritance.
3. A Grand Regent's Human child is a normal Half-Viltrumite and does not inherit Royal Hybrid status.
4. No Half-Viltrumites exist at wipe launch. Every hybrid born later begins on Viltrum.
5. Viltrumite and Half-Viltrumite custom clothing uploads remain enabled.
6. Viltrum discovers Earth and begins first contact. Earth cannot independently discover Viltrum beforehand.
7. Only Earth has Dragon Balls.
8. Earth and Viltrum each use one 500x500 surface Z-level.
9. Ordinary eligible Viltrumites and Half-Viltrumites have a fixed 5% chance to roll `scourge_resistance`.
10. Every Royal Hybrid has guaranteed Scourge immunity.
11. Terminal Scourge infection causes forced death so regeneration cannot prevent the outcome.
12. The Scourge spreads contagiously between characters rather than infecting an entire planet immediately.
13. Players cannot detect the survival mutation before release.
14. No cure can be developed; survival is exclusively genetic for the wipe.
15. The Grand Regent must have a credible chance against LSSJ and Cooler together because Earth has more rare apex lineages. The intended Viltrum apex roster is one Grand Regent and approximately three Royals.
