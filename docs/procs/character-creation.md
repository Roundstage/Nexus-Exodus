# Character Creation

## Files
- `src/Code/CharacterCreation/CharacterMutations.dm`
- `src/Code/CharacterCreation/NexusCharacterCreation.dm`
- `src/Code/CoreFunctions/Main.dm`
- `src/Code/CoreFunctions/MainCreation.dm`
- `src/Code/CoreFunctions/StatPoints.dm`
- `src/Code/_libs/upform/lib.dm`

## Architecture
The RPG-style login selector registers up to three independent characters per account and binds the chosen slot before creation or loading. `mob/proc/ClickMakeNewCharacter()` then delegates to `openNexusCharacterCreator()`. The creator is a server-rendered `/upForm/NexusCharacterCreator`; it does not use the legacy sequence of blocking race, skin, hair, and stat prompts. `GenerateBody()` emits one backend form presented as five browser stages. `Link()` handles the final `action=create` plus validated custom body, clothing-layer, and Frost-form imports; `commitNexusCharacter()` still revalidates the complete submission before mutating the player mob.

The 1180x760 window cannot be closed or minimized through `upForm`. Its five stages are:

- **Lineage:** race and lineage trait/preset.
- **Race specialization:** Alien 100-AP point buy or independent Frost Lord form slots.
- **Appearance:** identity, body, hair, optional starter clothing, custom icon imports, and a composed direction/flight preview.
- **Attributes:** all eleven manual stats with race value, free lineage points, player allocation, final value, and server-derived point caps.
- **Review:** normalized selection summary and the final `Begin Journey` submission.

Race, body, and trait changes happen in the browser. Selecting a race shows only that race's body and trait panels, selects their first entries, updates the description, hair eligibility, and starter-clothing scope, and resets the allocation to zero. Changing a trait also resets the allocation because the cached budget and caps are keyed by both race and trait. Viltrumite and Half-Viltrumite creation hides every general catalog outfit and exposes only clothing whose `nexus_starter_races` includes that race; imported custom layers remain available. The server does not trust any of this browser state and recomputes the allowed race, trait, body, clothing, and stat profile at commit time.

The Alien specialization keeps a sticky `remaining / 100 AP` indicator visible while its perk catalog scrolls. It updates after every selection or preset change and enters an explicit red over-budget state before navigation is rejected.

Each stage owns a fixed, contained layout. The Lineage panels remain in one grid row, Attributes is the sole vertical scrolling surface for its stage, and Appearance contains oversized DMI layers inside the composed preview without allowing their intrinsic sheet size to collapse the clothing column. Clothing uses fixed 80px grid rows and hard-clamped 42px thumbnails, so selecting a full-tile outfit cannot stretch an implicit row or push the remaining catalog into blank scroll space. The review summary and `Begin Journey` action are centered independently of the shared inline HUD-button rule.

Race setup is dispatched directly through `InitializeRaceTemplate(..., interactive_options=0, ...)`, so the creator does not open initializer prompts. `Racial_Stats()` remains the owner of race builds and stat construction, but the Nexus path supplies the player's complete manual allocation.

## Current Proc Signatures
Argument names, order, type annotations, and defaults below match the current declarations.

### CharacterMutations.dm
- `datum/CharacterMutation/New(stat)` records the affected internal stat.
- `mob/proc/rollCharacterMutations(forced_rarity)` performs a one-time hidden rarity roll or accepts a forced rarity for internal tests.
- `mob/proc/normalizeCharacterMutations()` migrates and sanitizes loaded internal state without rolling.
- `mob/proc/getCharacterMutationRarity()` derives a compatible rarity from the current admin-editable mutation set.
- `mob/proc/applyCharacterMutationRatio(mutation_id, ratio)` adjusts the affected live stat and growth modifier by a reversible ratio.
- `mob/proc/setCharacterMutationValue(mutation_id, percent)` safely adds, changes, or removes an admin-managed mutation without stacking the previous bonus.
- `mob/proc/clearCharacterMutations()` reverses every current mutation modifier before clearing the saved mutation state.
- `mob/proc/rerollCharacterMutations(forced_rarity)` removes the old modifiers, rolls a new set, and applies the new modifiers to a live character.
- `mob/proc/applyCharacterMutations()` multiplicatively applies the saved percentages.

### NexusCharacterCreation.dm
- `proc/nexusJsString(value)` escapes a value for an inline JavaScript string.
- `proc/nexusPreviewIconState(icon_file, requested_state)` caches DMI state metadata and resolves state names case-insensitively.
- `proc/nexusPreviewFrameHasPixels(icon/frame_icon)` detects whether an extracted preview frame contains any visible pixel.
- `proc/nexusPreviewIconMoving(icon_file, icon_state, direction)` caches whether the requested pose must use its movement-state variant.
- `proc/nexusExtractPreviewFrame(icon_file, icon_state, direction)` extracts one visible stationary or movement frame as an icon.
- `proc/nexusBrowserIconUrl(icon_file, icon_state, direction)` builds the normal native BYOND browser icon reference restricted to one state, direction, and frame.
- `upForm/NexusCharacterCreator/proc/getClothingPreviewUrl(icon_file, icon_state, direction)` preserves the native reference for normal clothes but registers an extracted PNG resource for movement-only clothing.
- `mob/NexusCreationPreview/New()` creates a side-effect-free race/stat preview mob.
- `proc/nexusFrostIconOptions()` derives the complete forty-entry Frost form catalog from `/obj/Icer` types.
- `proc/nexusStarterClothingOptions()` derives stable form-local IDs for non-custom clothing types.
- `proc/nexusAlienOptionDefinitions()`, `nexusAlienPresetOptions()`, and `nexusValidateAlienOptions()` own Alien AP metadata, presets, and the authoritative 100-AP limit.
- `proc/nexusRaceIconOptions(race_name)` returns the allowed body ID-to-icon catalog for a race; Frost Lord delegates to the full form catalog.
- `proc/nexusTrait(name, description)` constructs a trait metadata list.
- `proc/nexusRaceTraitOptions(race_name, mob/player, cooler_available = 0)` returns the traits currently legal for that race and player.
- `mob/proc/canSelectEliteSaiyan()` checks current Elite Saiyan eligibility.
- `mob/proc/initializeNexusRaceByTrait(race_name, trait_id)` maps a validated trait to race initializer flags.
- `mob/proc/raiseNexusCreationStat(stat_name, amount = 1)` dispatches a creation stat name to its `Raise_*` proc.
- `proc/nexusCreationStatStep(stat_id)` and `mob/proc/getNexusCreationStatValue(stat_id)` normalize how allocation points and current race values are displayed.
- `proc/nexusCreationStatProfile(race_name, trait_id)` returns and caches the race/trait budget, point caps, post-lineage race values, free lineage-point deltas, and per-point increments.
- `proc/nexusCustomIconIsValid(icon/icon_file)`, `nexusResolveFrostFormIcon(...)`, and `nexusValidateFrostFormOptions(...)` enforce the normal `IconTooBig()` policy and resolve only creator-owned custom slots. `nexusValidateStarterClothing(list/selected_ids, list/custom_clothing_icons, race_name)` additionally enforces each catalog item's server-owned race scope.
- `proc/nexusValidateStatAllocation(list/profile, list/allocation)` validates all submitted amounts, caps, and the exact total.
- `mob/proc/applyNexusStatAllocation(list/allocation)` spends a validated allocation against the initialized mob's `Points`.
- `mob/proc/canBeginNexusCharacterCreation()` checks whether the creator may be opened.
- `mob/proc/openNexusCharacterCreator()` opens or refreshes the current mob's creator.
- `mob/proc/autoAllocateCharacterStats()` remains available for non-Nexus callers; the Nexus creator does not use it.
- `mob/proc/applyNexusAlienOptions(list/selected_options)` applies each validated AP option exactly once; `applyNexusAlienProfile(profile)` remains a preset wrapper.
- `mob/proc/applyNexusAppearance(..., list/frost_form_ids, icon/custom_body_icon, list/custom_frost_icons)` applies a validated catalog or custom body, optional hair, and every independently selected Frost form icon.
- `mob/proc/applyNexusStarterClothing(list/selected_ids, list/custom_clothing_icons)` creates, equips, prioritizes, and rebuilds up to four validated catalog or custom starting clothes. Each DMI is copied and scaled to the selected body's frame dimensions before equipment composition, and appearance is rebuilt again after `FinishNewCharacterSetup()` so setup cannot replace the equipped overlays.
- `mob/proc/setNexusCharacterAge(requested_age)` sets birth year and age under `allow_age_choosing`.
- `mob/proc/commitNexusCharacter(..., cooler_available, list/alien_options, list/frost_form_ids, list/starter_clothing, icon/custom_body_icon, list/custom_clothing_icons, list/custom_frost_icons)` validates and completes creation.
- `proc/nexusRaceDescription(race_name)` returns the short lineage description.
- `upForm/NexusCharacterCreator/New(client/owner, datum/host, list/viewers)` rolls form-local Cooler availability, builds the hair catalog, and registers the form on its host.
- `upForm/NexusCharacterCreator/InitSettings()` assigns the stable `NexusCharacterCreator` browser window name so a reconnect replaces the retained creator window instead of opening a duplicate instance.
- `upForm/NexusCharacterCreator/Del()` clears the host's form reference and returns only a genuinely cancelled, non-committing player to the three-slot selector.
- `upForm/NexusCharacterCreator/canDisplayForm(client/C)` restricts display to the uncommitted host mob.
- `upForm/NexusCharacterCreator/Link(list/href_list, client/C)` accepts creator-local icon imports through BYOND's file picker or resolves submitted fields and invokes the commit backend.
- `upForm/NexusCharacterCreator/GenerateBody()` renders the staged menu and its native icon-reference preview catalog.

### Related Race And Stat Procs
- `mob/proc/ClickMakeNewCharacter()` delegates the New Character action to the Nexus creator.
- `mob/proc/InitializeRaceTemplate(force_race,force_elite,force_low_class,interactive_options=1,force_cooler=0,force_normal_class=0)` dispatches to the modular initializer.
- `mob/proc/Race(force_race,force_elite,force_low_class,interactive_options=1,force_cooler=0,force_normal_class=0)` owns the legacy chooser and delegates initialization.
- `mob/proc/Racial_Stats(mob/P,Start_Redo_Stats=1,modless_check=1,auto_allocate=0,list/stat_allocation)` builds race stats and consumes either a submitted allocation, automatic allocation, or the legacy stat window.

## Resource Catalogs
`GenerateBody()` sends validated user imports through `upForm.LoadResource()`. Catalog body, hair, clothing, and Frost previews use BYOND's native browser icon references with `dir`, `frame`, and optional `state` query parameters. This avoids synchronous extraction and transmission of every directional frame when the creator opens.

- The creator uses its own bronze CSS surface and never stretches the primary logo or a title-screen image behind appearance controls.
- Body descriptors expose each cardinal direction and only expose Flight when the DMI contains that state.
- Hair and clothing descriptors use the same direction and pose resolver, falling back to their ground frame when they lack Flight.
- Normal body, hair, and clothing URLs retain BYOND's native state/direction/frame behavior. For a movement-only clothing pose, the creator instead extracts one visible frame on the server and registers it as a form-local PNG. This keeps sprites such as Cape, Naraku, and Angel Wings from exposing their complete horizontal DMI sheets without changing the URLs used by the rest of the catalog.
- The preview uses one pixelated canvas. It loads the selected directional body frame, scales each equipped clothing layer into the body's coordinate space exactly as `applyNexusStarterClothing()` does, then draws hair last. This prevents independently fitted HTML images from floating above or beside the body.
- The composed preview has an immutable 32x32 backing canvas inside a strictly contained display box. Clothing selection never changes canvas dimensions, item transforms, offsets, or authored scale. Its hidden checkbox is anchored inside the card, and the clothing grid restores its own scroll position after every selection so focus and asynchronous image completion cannot move or reflow the wizard.
- Wizard state is stored under a form-specific `sessionStorage` key before a BYOND file picker opens and restored when the form refreshes. A successful import selects its new body, clothing layer, or Frost slot without discarding identity, race, allocation, direction, or current stage.

## Visual And Custom-Icon Contract
The creator is a player surface and must use `getNexusHudBrowserCss("bronze")`, the bundled Silkscreen fonts, square hard-edged frames, `hud-frame`/`hud-card` corner bolts, and the bronze control palette documented in `docs/procs/ui.md`. Its background is structural CSS, not the primary logo. Do not reintroduce rounded cards, smooth ornamental gradients, generic web fonts, a stretched title image, or a separate creation-only visual language.

Custom files are creator-owned until commit and are never accepted merely because the browser submitted a custom-looking ID. Body uses the reserved `custom_body` ID. Clothing provides four independent `custom_clothing_1..4` overlay slots, still sharing the four-item starter limit. Frost Lord provides `custom_frost_2..5`, while a custom first form is the selected custom body. Every import must pass `isicon()` and `IconTooBig()` (currently 192x192 and 0.4 MB); invalid and stale IDs fail server validation. Custom clothing is materialized as `/obj/items/Clothes/CustomClothing` and enters `PlayerAppearanceManager` like catalog clothing. The chosen body, clothes, and Frost form icon resources are saved on their normal character/item fields, so the interface supports custom appearance without a parallel rendering-only representation.

### Body Icons
`nexusRaceIconOptions()` is the authoritative server catalog. The creator sends every entry for every currently available race and rejects a body ID that is not in the selected race's fresh catalog.

| Races | Body ID | Resource |
| --- | --- | --- |
| Human, Saiyan, Half Saiyan, Legendary Saiyan, Demigod, Tsujin | `human_m_pale` | `BaseHumanPale.dmi` |
| Same shared catalog | `human_m_tan` | `BaseHumanTan.dmi` |
| Same shared catalog | `human_m_dark` | `BaseHumanDark.dmi` |
| Same shared catalog | `human_f_pale` | `NewPaleFemale.dmi` |
| Same shared catalog | `human_f_tan` | `NewTanFemale.dmi` |
| Same shared catalog | `human_f_dark` | `NewBlackFemale.dmi` |
| Spirit Doll | `doll_white` | `WhiteKaio.dmi` |
| Spirit Doll | `doll_possessed` | `PossessedSpiritDoll.dmi` |
| Spirit Doll | `doll_makai` | `MakaioshinBase.dmi` |
| Alien | `alien_1` | `Alien1.dmi` |
| Alien | `alien_2` | `Alien2.dmi` |
| Alien | `alien_3` | `Alien3.dmi` |
| Alien | `alien_beetle` | `AlienBeetle.dmi` |
| Alien | `alien_pikkon` | `AlienPikkon.dmi` |
| Alien | `alien_kanassa` | `AlienKanassa.dmi` |
| Alien | `alien_guldo` | `AlienGuldo.dmi` |
| Alien | `alien_bass` | `AlienBass.dmi` |
| Alien | `alien_burter` | `AlienBurter.dmi` |
| Alien | `alien_ginyu` | `RaceGinyu.dmi` |
| Alien | `alien_kui` | `RaceKui.dmi` |
| Alien | `alien_jiren` | `Jiren23.dmi` |
| Android | `android_standard` | `Android.dmi` |
| Android | `android_blackout` | `AndroidBlackout.dmi` |
| Android | `android_skeleton` | `AndroidSkeletor.dmi` |
| Android | `android_spider` | `AndroidSpider.dmi` |
| Android | `android_base_1` | `BaseAndroid1.dmi` |
| Android | `android_base_2` | `BaseAndroid2.dmi` |
| Android | `android_proxy` | `AndroidProxy.dmi` |
| Android | `android_human_pale` | `BaseHumanPale.dmi` |
| Android | `android_human_tan` | `BaseHumanTan.dmi` |
| Bio-Android | `bio_green` | `CellLarva.dmi` |
| Bio-Android | `bio_blue` | `CellLarvaBlue.dmi` |
| Demon | `demon_1` | `Demon1.dmi` |
| Demon | `demon_2` | `Demon2.dmi` |
| Demon | `demon_hades` | `Hades.dmi` |
| Demon | `demon_4` | `Demon4.dmi` |
| Demon | `demon_5` | `Demon5.dmi` |
| Demon | `demon_6` | `Demon6.dmi` |
| Demon | `demon_female` | `Demon6Female.dmi` |
| Demon | `demon_janemba` | `DemonJanemba.dmi` |
| Demon | `demon_ifrit` | `DemonIfrit.dmi` |
| Demon | `demon_lucifer` | `Lucifer.dmi` |
| Demon | `demon_satan` | `Satan.dmi` |
| Demon | `demon_wolf` | `DemonWolf.dmi` |
| Frost Lord | `frost_form_1..40` | Complete `/obj/Icer` catalog; selected independently for base, second, third, final, and conditional Cooler fifth form. |
| Kai | `kai_male` | `CustomMale.dmi` |
| Kai | `kai_female` | `CustomFemale.dmi` |
| Kai | `kai_avatar` | `Avatar.dmi` |
| Kai | `kai_white` | `WhiteKaio.dmi` |
| Makyo | `makyo_1` | `Makyojin2.dmi` |
| Makyo | `makyo_2` | `Konatsu.dmi` |
| Makyo | `makyo_3` | `KidAlien.dmi` |
| Makyo | `makyo_4` | `Alien4.dmi` |
| Majin | `majin_male` | `Majin.dmi` |
| Majin | `majin_female` | `FemaleMajin.dmi` |
| Namekian | `namek_young` | `NamekYoung.dmi` |
| Namekian | `namek_adult` | `NamekAdult.dmi` |
| Namekian | `namek_old` | `NamekOld.dmi` |
| Namekian | `namek_foreign` | `Namek2.dmi` |

Unknown race names receive the internal `fallback` entry backed by `BaseHumanPale.dmi`, but normal creator races come from the known available-race list.

### Hair Icons
The form constructor walks the global `Hairs` objects, skips entries with no icon, and retains at most 24. It stores server-side object references under `hair_1` through `hair_24`; `Link()` resolves the submitted ID through that map, so clients cannot supply an arbitrary hair object. With the current declarations, the resource catalog is:

| Option | Hair type | Base resource |
| --- | --- | --- |
| `hair_1` | `Hair1` | `HairShaggy.dmi` |
| `hair_2` | `Hair_Caulifla` | `CauliflaHair.dmi` |
| `hair_3` | `Hair_Kale` | `KaleHair.dmi` |
| `hair_4` | `Hair2` | `HairRen.dmi` |
| `hair_5` | `Hair3` | `HairShortFemale.dmi` |
| `hair_6` | `Hair4` | `HairPonytail.dmi` |
| `hair_7` | `Hair5` | `HairFemalePonytail.dmi` |
| `hair_8` | `Hair6` | `HairMessy.dmi` |
| `hair_9` | `Hair7` | `HairBushy.dmi` |
| `hair_10` | `Hair8` | `HairBrownHeadband.dmi` |
| `hair_11` | `Hair9` | `HairBlueMale.dmi` |
| `hair_12` | `Hair10` | `HairCloud.dmi` |
| `hair_13` | `Hair11` | `HairSuper17.dmi` |
| `hair_14` | `Hair12` | `HairKidd.dmi` |
| `hair_15` | `Hair13` | `HairMuse.dmi` |
| `hair_16` | `Hair14` | `HairGoku.dmi` |
| `hair_17` | `Hair15` | `HairVegetaTobiUchiha.dmi` |
| `hair_18` | `Hair16` | `HairRaditz.dmi` |
| `hair_19` | `Hair17` | `HairFutureGohan.dmi` |
| `hair_20` | `Hair18` | `HairGohan.dmi` |
| `hair_21` | `Hair19` | `HairLong.dmi` |
| `hair_22` | `Hair20` | `HairKidGohan.dmi` |
| `hair_23` | `Hair21` | `HairKylin2.dmi` |
| `hair_24` | `Hair22` | `HairKylin3.dmi` |

The catalog also renders an explicit `none` choice. Hair is unavailable for Majin, Bio-Android, Namekian, and Frost Lord bodies. Android hair is available only with an `android_human_*` body. A valid selected hair is applied through `Apply_Hair()` with the submitted color; an invalid color shape falls back to `#2b1b14`.

## Race Traits
Each race has its own panel and only IDs returned by `nexusRaceTraitOptions()` are accepted. Alien's four traits are now convenience presets for the editable 100-AP stage, not fixed packages.

| Race | Trait ID | Menu label | Availability or effect |
| --- | --- | --- | --- |
| Human | `human_adaptability` | Adaptability | Standard Human initializer and the largest free attribute pool. |
| Saiyan | `saiyan_warrior` | Warrior Blood | Passes `force_normal_class=1`, preventing the initializer's random Low Class branch and interactive Elite prompt. |
| Saiyan | `saiyan_low_class` | Low Class | Passes `force_low_class=1`. |
| Saiyan | `saiyan_elite` | Elite | Present only while `canSelectEliteSaiyan()` passes; passes `force_elite=1`. |
| Half Saiyan | `half_saiyan_hybrid` | Hybrid Potential | Standard Half Saiyan initializer. |
| Legendary Saiyan | `legendary_berserker` | Legendary Berserker | Standard Legendary Saiyan initializer. |
| Alien | `alien_scholar` | Scholar | Intelligence and control/utility profile. |
| Alien | `alien_predator` | Predator | Absorption, precognition, regeneration, and combat-growth profile. |
| Alien | `alien_shifter` | Shifter | Transformation, imitation, arm-stretch, and utility profile. |
| Alien | `alien_anomaly` | Anomaly | `jirenAlien`, regeneration, and Unlock Potential profile. |
| Android | `android_chassis` | Synthetic Chassis | Requires a non-`android_human_*` body. |
| Android | `android_infiltrator` | Infiltrator Shell | Requires an `android_human_*` body. |
| Bio-Android | `bio_adaptation` | Adaptive Genome | Standard Bio-Android initializer. |
| Demigod | `demigod_heritage` | Divine Heritage | Standard Demigod initializer. |
| Demon | `demon_soulbound` | Soulbound | Standard Demon initializer. |
| Frost Lord | `frost_heir` | Imperial Heir | Standard Frost Lord initializer. |
| Frost Lord | `frost_cooler` | Ascendant Strain | Present only when the form-local 1% Cooler roll passed; passes `force_cooler=1`. |
| Kai | `kai_guardian` | Guardian | Standard Kai initializer. |
| Makyo | `makyo_starborn` | Starborn | Standard Makyo initializer. |
| Majin | `majin_fragment` | Primal Fragment | Standard Majin initializer. |
| Namekian | `namek_dragon_clan` | Dragon Clan | Standard Namekian initializer. |
| Spirit Doll | `doll_awakened` | Awakened Soul | Standard Spirit Doll initializer. |
| Tsujin | `tsujin_engineer` | Engineer | Standard Tsujin initializer. |

Elite Saiyan eligibility requires world time greater than 3000 ticks, at least ten Saiyans, and a current Elite-to-Saiyan ratio below `elite_chance / 100` (`elite_chance` is currently 8). The commit backend regenerates this trait map, so an Elite option that became illegal after rendering is rejected. Cooler availability is held on the server-side form datum and is passed directly to the backend rather than read from an href field.

Alien population promotion is independent of the selected AP options. After five minutes of world uptime, if at least one connected Alien exists and the connected Alien population has no Elite or is below 4% Elite, the new Alien becomes `Class = "Elite"` and receives `max(round(Avg_Base * bp_mod), 6000)` in `hbtc_bp`. The Scholar, Predator, Shifter, and Apex Genome buttons mark the legacy-equivalent 98/100/96/100 AP presets, after which every checkbox remains editable. Unspent AP is legal; unknown IDs and totals above 100 are rejected. Starting SP and paid Elite BP now charge their displayed 10/20 AP instead of preserving the old free-cost bug.

| Trait | Applied state |
| --- | --- |
| `alien_scholar` | Sets Intelligence to 1; grants Time Stop (the Alien Time Freeze path), Materialization, and Split Form; multiplies mastery by 5 and blast homing by 1.5; enables lungs. |
| `alien_predator` | Grants Absorb and precognition; adds 0.5 regeneration; sets `zenkai_mod` and `alien_zenkai` to 1; multiplies meditation by 2.5. |
| `alien_anomaly` | Sets the normalized Standard-tier `jirenAlien` package (`0.95x` combat BP, `1x` incoming damage, `0.75x` powerup limit, `0.8x` knockback, `1.25x` stun resistance), removes Anger, grants Unlock Potential, and adds 0.5 regeneration. |
| `alien_shifter` | Creates the non-teachable Alien transform buff; grants Giant Form, Imitation, and Materialization; divides low-ki and low-HP BP loss by 3; enables arm stretch and lungs; multiplies blast homing by 1.5 and mastery by 5. |

## Manual Stat Allocation
`NEXUS_CREATION_STATS` defines all eleven submitted stats in this order:

`Energy`, `Strength`, `Endurance`, `Speed`, `Force`, `Resistance`, `Offense`, `Defense`, `Regeneration`, `Recovery`, `Anger`.

Every point must be allocated manually before submission. The browser prevents increments above the current cap or beyond the remaining budget, but the server performs the authoritative checks.

### Cached Profiles
`NEXUS_CREATION_STAT_PROFILES` caches profiles globally under `"<race>|<trait>"`. On the first request for a key, `nexusCreationStatProfile()` creates a `/mob/NexusCreationPreview`, initializes the selected race and trait without interactive prompts, starts with `44 + RaceBonusStatPoints()`, and applies `ApplyRaceBuild()`. The resulting `Points` value is the profile budget.

For each stat, a separate cap preview starts from the initialized race state before `ApplyRaceBuild()`, then repeatedly calls `raiseNexusCreationStat()` until `StatRaceCapped()` becomes true or the number of increments reaches the whole budget. The resulting increment count is that stat's player-allocation cap. Free lineage points are calculated by another preview after `ApplyRaceBuild()` and therefore do not consume that manual room. Android and Legendary Saiyan Anger receive a zero profile cap. Apex Genome is a customizable Alien option rather than a fixed profile property, so the browser dynamically forces its Anger cap/allocation to zero when selected and the server independently rejects any submitted Apex Anger points. Profiles do not include hidden internal modifiers, so those modifiers cannot change or disclose the visible budget or caps. `GenerateBody()` embeds every rendered profile's budget and eleven caps into JavaScript.

Current fresh-character budgets are:

| Race/trait profile | Budget |
| --- | ---: |
| Human / Adaptability | 72 |
| Saiyan / Warrior Blood | 33 |
| Saiyan / Low Class | 37 |
| Saiyan / Elite | 34 |
| Half Saiyan / Hybrid Potential | 44 |
| Legendary Saiyan / Legendary Berserker | 34 |
| Alien / any Alien trait | 75 |
| Android / either Android trait | 61 |
| Bio-Android / Adaptive Genome | 31 |
| Demigod / Divine Heritage | 24 |
| Demon / Soulbound | 44 |
| Frost Lord / either Frost Lord trait | 29 |
| Kai / Guardian | 42 |
| Makyo / Starborn | 48 |
| Majin / Primal Fragment | 34 |
| Namekian / Dragon Clan | 45 |
| Spirit Doll / Awakened Soul | 72 |
| Tsujin / Engineer | 55 |

One allocation point changes Energy, Strength, Endurance, Speed, Force, Resistance, Offense, or Defense by 0.1; Regeneration or Recovery by 0.2; and Anger by 10. The caps are point counts derived from the initialized pre-lineage race state, not raw final-stat values. The displayed final value combines the post-lineage race value with the player's allocation.

### Server Validation And Application
`nexusValidateStatAllocation()` rounds the submitted numeric value for each of the eleven known IDs, rejects negative values and values above the cached cap, and requires their sum to equal the profile budget exactly. Extra fields do not become stats. `nexusCreationCanAllocateAnger()` adds the authoritative option-aware rejection for Android, Legendary Saiyan, and an Alien selection containing Apex Genome. After race initialization, `Racial_Stats(Start_Redo_Stats = 0, stat_allocation = stat_allocation)` reconstructs the same point budget and race build. `applyNexusStatAllocation()` independently rejects negative amounts or a total different from the mob's current `Points`, applies every increment through the appropriate `Raise_*` proc, decrements `Points`, and succeeds only at zero.

`Max_Points` and `Minimum_Stats` are captured after the race build and before the submitted allocation. The manual branch applies the allocation first and then the hidden internal modifiers. The old `autoAllocateCharacterStats()` helper covers only eight combat stats and is not called by the Nexus creator.

## Commit Flow And Validation
1. `canBeginNexusCharacterCreation()` rejects a loaded character or active commit. It requires `can_login`, rejects race-stat preview mode, enforces five seconds of world uptime, remake restrictions, the configured player cap, and relog throttling.
2. `openNexusCharacterCreator()` requires a client. It refreshes an existing creator or opens a single `/upForm/NexusCharacterCreator` owned and hosted by that mob.
3. Rare eligibility is resolved server-side. `all_rare_races_common` exposes every rare option globally; `grantNexusRareRace()` records per-account Legendary Saiyan, Frost Lord, Cooler, or Grand Regent access until `commitNexusCharacter()` successfully consumes the matching grant. Grand Regents created through either override are saved as non-exclusive rare lineages and do not claim or displace the persistent unique office.
4. The form constructor resolves Cooler from the global switch, an account grant, or one `prob(1)` roll, captures up to 24 real hair objects, and creates form-local custom clothing/Frost slot lists. `canDisplayForm()` permits only the host client's uncommitted mob.
5. `GenerateBody()` obtains a current race list, builds five stages, emits lightweight native icon references, and exposes creator-owned imports. Frost form slots show a visual south-facing preview beside each independent catalog/custom selector.
6. `Link()` validates `upload_body`, `upload_clothing`, and `upload_frost` through the normal icon limits and refreshes the preserved wizard, or handles `action=create`: it copies all eleven stats, parses comma-separated server IDs for Alien/clothing, builds the Frost slot list, resolves hair against the form-owned catalog, and passes only this form's custom resources plus the server-held Cooler flag to `commitNexusCharacter()`.
7. The backend requires the client and loading state to remain valid, rechecks `can_login`, preview mode, remake restrictions, and the player cap, and requires the selected race to remain in a fresh `GetAvailableCharacterRaces()` result.
8. The backend regenerates traits, bodies, Alien AP definitions, Frost form icons, and clothing types; it enforces Android compatibility, AP/clothing limits, required Frost slots, identity fields, and the exact stat allocation.
9. Only after validation does it lock the commit, initialize the race, set Apex Anger eligibility before hidden mutations roll, create hidden internal state, compute low-resource BP loss, run `Racial_Stats()`, and apply alignment, Alien options, appearance, starter clothing, name, and age.
10. It applies race starting stats, chooses a random valid spawn, completes standard setup, loads feats, initializes Android/Majin energy, consumes any matching rare grant, marks the player session complete before the asynchronous new/load bootstrap can close the creator, and schedules `save()` after five ticks. No hidden internal information is included in creator output or completion messages.
11. On success the form is deleted. On failure it displays a generic name/trait/icon/attribute error and refreshes without completing the character.

Names are truncated to 49 characters by `copytext(..., 1, 50)`, HTML-encoded, and checked by `InvalidPlayerName()`. Gender is forced to male for Bio-Android, Namekian, and Android; other races use female only when explicitly submitted, otherwise male. Alignment accepts only `Good` or `Evil` and defaults to Good. Age is clamped to `0..1000` only when age selection is enabled; otherwise it is zero.

The chosen body icon is assigned directly from the validated resource catalog or creator-owned custom body. Frost Lord requires four independently selected icons and Cooler requires five; each slot can resolve a validated custom icon, while Gold remains a separate later form. Demigod bodies receive the existing dark tint, compatible arm-stretch icons are recolored, and starting clothes are rendered through `PlayerAppearanceManager`.

## Hidden Mutation Schema Version 2
**Mutation information is internal-only and must never be rendered or messaged to players.** Do not add mutation rarity, IDs, percentages, summaries, roll results, or hints to the creator HTML, alerts, chat/output messages, player-facing logs, or completion flow. There is intentionally no player-facing summary proc.

`CHARACTER_MUTATION_SAVE_VERSION` is `2`. Each mob persists:

- `mutation_save_version`: schema/migration version.
- `mutation_rarity`: null, `Common`, `Uncommon`, `Rare`, or `Anomaly`.
- `character_mutations`: an associative list of internal mutation ID to integer percentage.

`CHARACTER_MUTATIONS` is an internal ID-to-`/datum/CharacterMutation` registry. Each datum stores only its affected stat:

| Internal ID | Affected stat |
| --- | --- |
| `energy_efficiency` | Energy |
| `adaptive_musculature` | Strength |
| `reinforced_frame` | Durability |
| `accelerated_reflexes` | Speed |
| `focused_core` | Force |
| `resilient_cells` | Resistance |
| `predatory_instinct` | Offense |
| `reactive_guard` | Defense |
| `regenerative_cells` | Regeneration |
| `accelerated_recovery` | Recovery |
| `volatile_potential` | Anger |

### Internal Roll Distribution
An unforced roll uses `rand(1, 100000)` and the following exact internal distribution:

| Roll | Internal result | Probability | Count | Percentage per selected stat |
| --- | --- | ---: | ---: | ---: |
| `251..100000` | None | 99.75% | 0 | N/A |
| `51..250` | Common | 0.20% | 1 | 1% to 10% |
| `11..50` | Uncommon | 0.04% | 1 | 1% to 20% |
| `2..10` | Rare | 0.009% | 2 or 3, chosen by `rand(2, 3)` | 1% to 20% |
| `1` | Anomaly | 0.001% | All 11 | 1% to 30% |

Selected IDs are distinct because each pick is removed from a temporary list. Angerless archetypes omit `volatile_potential` from the available pool, discard it during legacy normalization, and reject later attempts to assign it. Consequently, their Anomaly roll contains every eligible mutation rather than all eleven catalog entries. `forced_rarity` is used by internal tests; any value outside the four named tiers, including `"None"`, records the current version with no entries.

### Multiplicative Application
Each saved percentage uses `multiplier = 1 + percent / 100`; percentages are multiplicative, not additive stat steps. Application clamps the read percentage to `1..30` and changes these fields:

| Stat | Multiplied fields |
| --- | --- |
| Energy | `Eff`, `max_ki`, `Ki` |
| Strength | `strmod`, `Str` |
| Durability | `endmod`, `End` |
| Speed | `spdmod`, `Spd` |
| Force | `formod`, `Pow` |
| Resistance | `resmod`, `Res` |
| Offense | `offmod`, `Off` |
| Defense | `defmod`, `Def` |
| Regeneration | `regen` |
| Recovery | `recov` |
| Anger | `max_anger` |

For the Nexus manual-allocation branch, `Racial_Stats()` applies these percentages after the race build and submitted allocation. This keeps the internal roll out of profile budgets, profile caps, and creator rendering. Anger mutation application also rechecks `canPossessAnger()` and normalizes an ineligible character to `anger = max_anger = 100`. Application itself is multiplicative and is not an idempotent operation; callers must not apply it repeatedly to already-modified state.

### Migration And Idempotence
`rollCharacterMutations()` immediately returns when `mutation_save_version >= 2`, even when a forced rarity is supplied. A completed roll, including a no-result roll, therefore cannot be rerolled or replaced through this proc.

`normalizeCharacterMutations()` never rolls. For a pre-version-2 nonempty list, it converts known legacy IDs into associative `ID = percentage` entries. Missing, nonnumeric, or nonpositive legacy percentages become 10%; migrated values are rounded and clamped to `1..20`.

When rarity is missing or invalid, normalization infers it from the migrated data: all 11 known IDs become Anomaly; more than one becomes Rare; one entry above 10% becomes Uncommon; and any other single entry becomes Common. It then applies the tier's maximum count and percentage bounds:

| Inferred/saved tier | Maximum retained count | Normalized percentage bound |
| --- | ---: | ---: |
| Common | 1 | 1% to 10% |
| Uncommon | 1 | 1% to 20% |
| Rare | 3 | 1% to 20% |
| Anomaly | 11 | 1% to 30% |

Unknown IDs and nonpositive values are removed; excess entries are truncated in list order; valid percentages are rounded and clamped. An unrecognized tier with no inferable valid state clears both the list and rarity. An empty final list clears rarity. Every path records version 2. Repeating normalization after the first sanitized result leaves that result unchanged, and old characters with no entries remain empty rather than receiving a retroactive roll.

Normal `load()` performs `Read()` and then `Other_Load_Stuff()`, which calls normalization. Normal mob `Write()` serialization preserves the version, rarity, and associative ID/percentage list. The legacy `New_Character()` path rolls only for fresh non-reincarnating, non-DB characters; reincarnation and DB compatibility paths normalize instead. Spirit Doll continues to persist as `Race = "Human"`, `Class = "Spirit Doll"`; Cooler as `Race = "Frost Lord"`, `Class = "Cooler"`; and Saiyan variants as classes under `Race = "Saiyan"`.
