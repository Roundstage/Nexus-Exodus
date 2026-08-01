# Roleplay Tenkaichi attack assets

These assets were imported from the sibling `Roleplay-Tenkaichi` project with the project owner's authorization. They are intentionally isolated from the legacy DU asset root and renamed with `RT` prefixes to prevent ambiguous BYOND resource references.

The attack port contains 47 new native Nexus skill types backed by 29 imported icons. The admin testing catalog exposes 59 entries because it also includes twelve compatible attacks that Nexus already provided. Ported skills are not automatically inserted into normal character progression yet; use **Give Tenkaichi Attacks** from the searchable Admin Panel to grant Weapon, Unarmed, Beams, Ranged or All packages.

Original mechanics that depend on Tenkaichi-only splitform actors, persistent field controllers or its damage formulas are represented by bounded Nexus melee contexts or projectile volleys. This keeps dodge, guard, RPMode, lethal/KO handling, central damage budgets, collision and projectile cleanup authoritative in Nexus.
