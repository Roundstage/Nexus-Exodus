# Roleplay Tenkaichi Port Inventory

Roleplay Tenkaichi was provided by its original developer for continued development and selective integration into Nexus Exodus. Imported systems are adapted to Nexus save, inventory, combat, Technology, Milestone, and admin contracts rather than copied as parallel legacy subsystems.

## Smithing assets

The forge, pickaxe, Tin/Silver ore, Bardock armor, hammer, sledgehammer, mage staff, Trunks sword, katana, long katana, and short sword DMIs were imported under `src/Icons/` with an `RT` prefix. Existing Nexus files that were byte-identical to Tenkaichi art are reused instead of duplicated, including the other sword and armor designs.

## Runtime adaptation

- `src/Code/Technology/Professions.dm` owns profession XP and mined material stacks.
- `src/Code/Technology/ForgedEquipment.dm` owns visual catalogs, material branches, forge interactions, equipment recalculation, and test verbs.
- Weapon and armor appearance IDs persist independently of material IDs, so improving an item never replaces it with the basic DU sword or armor.
- Admin Level 3 can use `Test Tenkaichi Smithing` for a complete material/forge setup or `Give Tenkaichi Equipment` for a specific tier and design.
