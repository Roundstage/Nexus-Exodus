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
- Dragon Nova uses the original `16.dmi` projectile art as `RTDragonNova.dmi`. Sky Break uses the original `blackslash.dmi` as `RTSkyBreak.dmi` and is implemented as a weapon-gated projectile whose damage resolves from Strength against Endurance.
- Rock Slide restores the RPT 7-to-15 projectile cadence instead of the previous five-hit cap; Rock Throw and Rock Tomb use factors 3.5 and 8 respectively, retaining Nexus damage caps and audiovisual feedback.
- The **Give Tenkaichi Attacks** admin verb exposes a dedicated **Rock Techniques** package containing all three skills for immediate testing.
- Imported melee impact art also supplies each technique's hotbar icon. Casts use Nexus attack animations, floating names, spectator messages and weapon/unarmed/grapple sound profiles; impacts animate, fade and create heavy shockwaves where appropriate.
- Wall of Flame uses Nexus cast text, fire audio, field fade-in and first-contact burn feedback. Ported beams and Buster Barrage continue through their native Nexus engines, which already own charge, firing and impact presentation.
