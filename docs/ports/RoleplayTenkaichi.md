# Roleplay Tenkaichi Port Inventory

Roleplay Tenkaichi was provided by its original developer for continued development and selective integration into Nexus Exodus. Imported systems are adapted to Nexus save, inventory, combat, Technology, Milestone, and admin contracts rather than copied as parallel legacy subsystems.

## Smithing assets

The forge, pickaxe, Tin/Silver ore, Bardock armor, hammer, sledgehammer, mage staff, Trunks sword, katana, long katana, and short sword DMIs were imported under `src/Icons/` with an `RT` prefix. Existing Nexus files that were byte-identical to Tenkaichi art are reused instead of duplicated, including the other sword and armor designs.

## Runtime adaptation

- `src/Code/Technology/Professions.dm` owns profession XP and mined material stacks.
- `src/Code/Technology/ForgedEquipment.dm` owns visual catalogs, material branches, forge interactions, equipment recalculation, and test verbs.
- Weapon and armor appearance IDs persist independently of material IDs, so improving an item never replaces it with the basic DU sword or armor.
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
- Focus and six mutually exclusive Ultimate Buffs use Nexus `obj/Buff`; UBs are permanent Milestone choices. `Test Tenkaichi Buffs` grants the full catalog for test characters.
- Science keeps Nexus Knowledge as its authoritative source and exposes registered designs as Foundation, Engineering, Robotics, and Genetics branches. No Knowledge gain or cap formula was replaced.
- Magic is a separate meditation progression with Divination, Restoration, Warding, Conjuration, and Evocation branches. Its nine nodes grant compatible Nexus abilities instead of importing dependency-heavy RPT skill types verbatim.

## World resources and planetary time

- Resource-bearing planetary areas are populated with visible Copper, Tin, Iron, Silver, Mythril, Auracite, and Heart of the Mountain deposits. Deposits enforce Mining levels, contain finite stacks, award Mining XP, and are replenished by a Year-Speed-aware world loop.
- `Seed World Ore Deposits` tops up the distribution without removing existing deposits.
- Day/night state is owned by a shared `PlanetaryClock` per area/planet type. All players on that planet receive the same phase; different planets retain independent ratios and colors.
- One planetary hour lasts five real minutes at Year Speed 1 by default and scales inversely with `Year_Speed`. Standard planetary days are longer than nights. Admins can inspect phase, set phase, and tune hour length.
