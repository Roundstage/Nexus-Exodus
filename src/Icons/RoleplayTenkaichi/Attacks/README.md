# Roleplay Tenkaichi attack assets

These assets were imported from the sibling `Roleplay-Tenkaichi` project with the project owner's authorization. They are intentionally isolated from the legacy DU asset root and renamed with `RT` prefixes to prevent ambiguous BYOND resource references.

The attack port contains 47 new native Nexus skill types backed by 29 imported icons. The admin testing catalog exposes 59 entries because it also includes twelve compatible attacks that Nexus already provided. Ported skills are not automatically inserted into normal character progression yet; use **Give Tenkaichi Attacks** from the searchable Admin Panel to grant Weapon, Unarmed, Beams, Ranged or All packages.

Melee mechanics are adapted as native Nexus behaviors: grapple throws and slams require an active grab, line attacks retain their reach, advancing attacks pursue over time, and counters intercept an incoming melee strike. Wall of Flame uses a bounded persistent field controller. Generic blast reskins are kept out of the testing packages so dodge, guard, RPMode, lethal/KO handling and central damage scaling remain authoritative in Nexus.
