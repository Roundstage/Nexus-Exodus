# Roleplay Tenkaichi Port Inventory

Roleplay Tenkaichi was provided by its original developer for continued development and selective integration into Nexus Exodus. Imported systems are adapted to Nexus save, inventory, combat, Technology, Milestone, and admin contracts rather than copied as parallel legacy subsystems.

## Smithing assets

The forge, pickaxe, Tin/Silver ore, Bardock armor, hammer, sledgehammer, mage staff, Trunks sword, katana, long katana, and short sword DMIs were imported under `src/Icons/` with an `RT` prefix. Existing Nexus files that were byte-identical to Tenkaichi art are reused instead of duplicated, including the other sword and armor designs.

The RPT Magic Goo, tiered Punching Bag, Magic Circle, alchemical circle, and enchantment-item DMIs are preserved under `src/Icons/RoleplayTenkaichi/Magic/` and `src/Icons/RoleplayTenkaichi/Technology/`. Filenames use the Nexus `RT` prefix and contain no spaces.

## Runtime adaptation

- `src/Code/Technology/Professions.dm` owns profession XP and mined material stacks.
- `src/Code/Technology/ForgedEquipment.dm` owns visual catalogs, material branches, forge interactions, equipment recalculation, and test verbs.
- Weapon and armor appearance IDs persist independently of material IDs, so improving an item never replaces it with the basic DU sword or armor.
- Rebellion, Buster, Bardock, and other named designs are cosmetic skins. The actual objects are material-named (`Copper Sword`, `Mythril Sword`, `Auracite Armor`) and receive every statistic from their material module.
- Forged swords add a bounded material-dependent share of the wielder's BP to melee attack calculations. Forged armor adds a bounded share of the wearer's BP to physical endurance calculations, in addition to Nexus Protection and weight effects.
- The forge uses a resizable pixel-styled browser with 96px icon previews and an in-window guide explaining every material, upgrade branch, BP bonus, damage type, protection value, and weight.
- Admin Level 3 can use `Test Tenkaichi Smithing` for a complete material/forge setup or `Give Tenkaichi Equipment` for a specific tier and design.

## Combat presentation

- Rock Throw and Rock Slide use the original animated `bouldertest2.dmi`, imported as `RTRockThrow.dmi`; Rock Tomb uses the original directional `Meteor.dmi`, imported as `RTRockTomb.dmi`.
- Dragon Nova uses the original `16.dmi` projectile art as `RTDragonNova.dmi`. Sky Break uses the original `blackslash.dmi` as `RTSkyBreak.dmi`; Echoing Slash uses `RTEchoingSlash.dmi`. Both sword waves require an equipped weapon, resolve Strength against Endurance, and use sword swings, impacts and slash VFX instead of generic blast audio.
- Rock Slide restores the RPT 7-to-15 projectile cadence instead of the previous five-hit cap; Rock Throw and Rock Tomb use factors 3.5 and 8 respectively, retaining Nexus damage caps and audiovisual feedback.
- The **Give Tenkaichi Attacks** admin verb exposes dedicated Rock Techniques and Special Styles packages containing the adapted skills for immediate testing. **Test Combat Effects** previews sword waves, rocks, maximum explosion light and explosive-beam knockback.
- Imported melee impact art also supplies each technique's hotbar icon. Casts use Nexus attack animations, floating names, spectator messages and weapon/unarmed/grapple sound profiles; impacts animate, fade and create heavy shockwaves where appropriate.
- Wall of Flame uses Nexus cast text, fire audio, field fade-in and first-contact burn feedback. Ported beams and Buster Barrage continue through their native Nexus engines, which already own charge, firing and impact presentation.

## Races, buffs, and research

- Kanassans and Herans are native Nexus creation choices with RPT-inspired identities, Nexus stat caps, spawn aliases, Sense colors, starter skills, and imported Heran base icons.
- Ancient Namekian and Ancient Progenitor are rare lineages rather than duplicate races. They preserve Namekian and Android systems while adding bounded arcane/regenerative or sensor/science packages. Both normally use cached 5% creation rolls with an online population limit; `ancient_namekian_common_race` can expose Ancient Namekians for events and tests.
- Makyo now has a useful 0.94x baseline combat modifier and a bounded 1.08x Makyo Star modifier. Star recovery no longer heals rapidly or overfills Ki, removing the old invincible/useless swing.
- Focus, fixed presets, and six mutually exclusive Ultimate Buffs use Nexus `obj/Buff`. Ultimate Buffs are the mutually exclusive tier-five capstones of Combat -> Buffs; old `ub_*` milestone ownership migrates automatically to the matching capstone. Combat Mathematics is granted only by its Robotics module, while Bleeding Edge is granted only by its Milestone. `Test Tenkaichi Buffs` still grants the full implementation catalog for test characters.
- Science keeps Nexus Knowledge and Technology Level requirements while exposing every registered design in Foundation, Engineering, Robotics, and Genetics tree branches.
- Magic keeps its separate meditation levels and exposes Divination, Restoration, Warding, Evocation, Conjuration, Enchantment, Constructs, Artifacts, and Alchemy branches in the unified tree.

## Unified progression

- Progression XP replaces spendable legacy Experience and is awarded by qualified roleplay sessions, active non-AFK online time, profession milestones, crafting, wishes, and explicit admin rewards. A roleplay session requires at least 30 minutes, six substantive contributions, 120 contributed words, and a recently active player partner; it pays once, while OOC, Global, repeated text, isolated monologues, and message spam pay nothing.
- Science, Magic, Mining, Smithing, and Combat share a browser with connected tier columns and authored branch choices. Combat is divided into Foundation, Buffs, Ki, Beam, Physical, Unarmed, and Weapon. Milestones use a searchable independent-pick list in the same window instead of prerequisite lines.
- Combat opens on a universal Foundation curriculum: Power Control, Blast and Lunge lead into Fly, Shield, Charge and Dash Attack; these develop into Zanzoken, Custom Buff and Beam before culminating in guided Sokidan. The ordering follows Dragon Ball's progression from ki regulation and basic emission into movement, defense, sustained waves and controlled projectiles.
- Existing learned skills and research migrate as owned. Rank, race, module, milestone, magic, crafting, transformation, quest, and event rewards are omitted from Combat rather than presented as purchasable skills.
- Milestones are independent ranked purchases grouped into a filterable list; none requires another Milestone. Ultimate Buffs belong exclusively to the Combat -> Buffs tree.
- Named sustained waves have a dedicated Beam specialization rooted in the universal Beam skill. Rock Throw, Rock Slide, and Rock Tomb use the Physical branch. Echoing Slash and Sky Break use Weapon progression and the weapon damage calculation.
- Kaioken and Genki Dama are tier-ten purchases. Genki Dama has the largest bounded player-projectile damage budget; Cyber Charge, Cyber Laser, Overdrive, and Combat Mathematics remain module-only.
- Lifetime Progression XP gates the tier frontiers independently from spendable XP: tiers 1-10 require 0, 6, 18, 42, 72, 105, 150, 210, 270, and 330 lifetime XP. Active non-AFK time grants two XP per hour; a qualified roleplay session grants three XP. This targets the complete 74-XP Combat Foundation near 24 engaged hours and a focused first tier-ten route near 110 hours, around the midpoint of a 60-90 day wipe for a regular player.
- The combat Milestone catalog now ports 24 RPT talents across Martial Arts, Weapon, Ki, Survival, and Fire paths. Signature rewards include Burning Fists / Fire Fist, Bleeding Edge, Thundering Blows, Fire Lord, Smolder, Energy Marksmanship, Concentrated Fire, and This Drill Will Pierce the Heavens; their effects use Nexus damage scaling, targeting, Precognition, homing, bleed, burn, stun, and hotbar contracts.

## Complete magic and expanded science

- Science registers six Punching Bag tiers. Each higher design has its own Technology Level/path requirement, resource cost, original RPT icon, and bounded bag-training multiplier.
- The active RPT magic-project list is represented by 41 Arcane Workshop formulas. This includes all four Magic Goo tiers; circles; Philosopher's Stone; Stone of Understanding; weapons, armor and training gear; Mana Pylon; Spell Book; containers; Magic Door and Vault; Simulation Crystal; Scanner, Locator, Disguise and Crystal Ball; Enchanted Doll; Upgrade Kit; fishing lure; six elixirs; and four permanent-use books.
- The RPT spell set adds Fireball, Frost Bolt, Lightning Bolt, Frost Nova, Earth Prison, Empowered Attacks, Empowered Defenses, Accelerate, Rejuvenate, Gravity Well, Create Portal, and Enchant. Each is a purchased Magic-tree reward and uses Nexus damage, target, cooldown, VFX, audio, regeneration, speed, and save contracts.
- Magic-focused meditation gathers persistent Arcane Essence. A carried or nearby Magic Circle multiplies essence gathering by 1.5; a Transmutation Circle doubles it.
- A nearby Mana Pylon adds another 25% essence multiplier. Magic Gauntlets and Orb of Mastery increase Magic XP, while the ported elixirs feed the authoritative Nexus regeneration, energy-recovery, and roleplay-XP paths.
- Transmutation Circles exchange resources for Arcane Essence or convert four units of a lower ore into one advanced ore. The advanced circle is also required for peak Magic Goo and Philosopher's Stone rituals.
- Philosopher's Stone requires the Magic capstone, 500 Arcane Essence, a Transmutation Circle, and one Heart of the Mountain. Carrying it grants the RPT `+0.5 Regeneration` effect and perfect language comprehension.
- Genetics adds organic Mutagen Injectors with the RPT two-mutation limit, Android-only Self-Replicating Code Injectors, a reusable Genetic Sequencer/stabilizer, selective Mutation Suppressant, and permanent Adamantine Skeleton treatment. Mutation changes go through the native percentage-based mutation API rather than maintaining a second mutation model.
- Additional adapted science designs include Repair and Upgrade Kits, Medical Assessment, Prospecting Toolkit, Advanced Door Pass, Healing Pylon, Power Armor, Android Upgrade Components and an Android repair chassis. Existing Nexus equivalents remain authoritative for cloning, regenerators, gravity, transporters, force fields, cloaking, ships, pods, bombs, guns, scanners, turrets and communications.
- `Test Tenkaichi Research` grants every Magic branch; `Test Tenkaichi Science` grants the ported genetics and engineering test package.

## Languages

- Characters receive persistent racial languages on migration. Supported languages include Common, Earthling, Saiyan, Namekian, Demonic, Old Tongue, Kaian, Yardratian, Arconian, Heran, Kanassan, Tsufurian, and Machine Code.
- Say, Whisper, and Communicator transmissions render separately for every listener. Unknown words are replaced by deterministic language-specific syllables, while partial fluency reveals a stable share of the message.
- Listening to unique speech and receiving lessons increases fluency according to language difficulty. Repeat-message suppression prevents a speaker/listener pair from farming the same line.
- Universal Translators are Engineering designs. Stones of Understanding and Philosopher's Stones translate for their bearer; a Universal Translator also translates its owner's outgoing speech.
- Language Savant and Custom Language are Culture milestones. The latter creates one persistent player language that can be learned and taught like a racial language.

## World resources and planetary time

- Resource-bearing planetary areas are populated with visible Copper, Tin, Iron, Silver, Mythril, Auracite, and Heart of the Mountain deposits. Deposits enforce Mining levels, contain finite stacks, award Mining XP, and are replenished by a Year-Speed-aware world loop.
- `Seed World Ore Deposits` tops up the distribution without removing existing deposits.
- Day/night state is owned by a shared `PlanetaryClock` per area/planet type. All players on that planet receive the same phase; different planets retain independent ratios and colors.
- One planetary hour lasts five real minutes at Year Speed 1 by default and scales inversely with `Year_Speed`. Standard planetary days are longer than nights. Admins can inspect phase, set phase, and tune hour length.
