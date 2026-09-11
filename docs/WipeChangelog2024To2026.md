# Nexus Exodus — Wipe Changelog (2024–2026)

Compiled from the current branch after the March 21, 2024 `new-wipe-fixed` merge (`cfd0bf0`) through September 7, 2026 (`b656e83`). This is a player-facing summary: repeated fixes, code moves, build tooling, and internal test work are consolidated rather than listed commit by commit.

The sections below are intentionally split into Discord-sized posts.

## Discord post 1/6 — The new wipe

**NEXUS EXODUS — NEW WIPE CHANGELOG (2024–2026)**

This is the largest update Nexus Exodus has received since the last wipe. Movement, combat, progression, crafting, UI, races, planets, faction warfare, presentation, and server stability have all been rebuilt or substantially expanded.

**Headline changes**
- Brand-new 500×500 surfaces for Earth and Viltrum, plus rebuilt public interiors, regional landmarks, settlements, wilderness, resource zones, and invasion/landing routes.
- Viltrumites join the game with Royal Blood, Grand Regent, and future Half-Viltrumite lineage systems.
- A unified progression system now covers Combat, Racial skills, Magic, Science, Mining, Smithing, and Milestones.
- Movement now runs at 60 FPS with smooth vector/pixel movement, better diagonals, collision, dashing, warping, and projectile alignment.
- Combat received new attacks, rebalanced damage and power gaps, clashes, targeting, Ki Weapons, team support, audiovisual feedback, and many restored/fixed skills.
- A completely refreshed interface adds character slots, a permanent command panel, configurable layouts, modern hotkeys, live menus, separated chat/combat logs, and clearer HUD feedback.

Everything below breaks down what changed.

## Discord post 2/6 — Worlds, factions, and the wipe setting

**EARTH & VILTRUM**
- Earth is now the home of every non-Viltrumite race. Its western metropolis is the wipe’s only major city, with houses, hospital, shops, civic spaces, workshops, port, farms, and dedicated interiors.
- Earth’s wilderness now has continuous rivers and banks, bridges, forests, an arctic mountain, desert dunes, waterfalls, caves, remote shelters, and fully tiled climbable terrain.
- Viltrum includes an imperial capital, palace, residences, science and military districts, academy, arena, shipyards, fabrication and energy facilities, polar regions, islands, ruins, outposts, and public interiors.
- Structural boundaries, roofs, doors, coastlines, landing areas, spawns, planet scanning, destruction/restoration, and travel handling were rebuilt and hardened.

**THE VILTRUMITE WAR**
- Viltrumites have their own stats, language, clothing, progression, combat techniques, recovery traits, royal lineages, and homeworld.
- Grand Regent is a single persistent apex role with controlled admin succession. Royal Blood is rare and can pass through valid family ancestry.
- Half-Viltrumites are not available at launch; they enter through post-start Human/Viltrumite family play and begin on Viltrum.
- Earth cannot navigate to Viltrum before first contact; Viltrum is intended to discover and reach Earth first.
- The Scourge Virus creates a persistent, contact-driven strategic threat to susceptible Viltrumites. Royals are immune, while ordinary Viltrumites have a one-time rare genetic resistance roll. There is no player cure.

## Discord post 3/6 — Progression, crafting, and economy

**UNIFIED PROGRESSION**
- Progression XP replaces the old spendable Experience model. It comes from active RP, elapsed hours (including offline time), professions, crafting, wishes, and admin rewards.
- A single progression browser now organizes Combat, Racial, Magic, Science, Mining, Smithing, and independent Milestones into clear branches and tiers.
- Combat progression now grows from fundamentals such as Power Control, Blast, Lunge, Flight, Shield, Charge, and Dash Attack into advanced beams, physical styles, weapon skills, buffs, and controlled Ki.
- Racial trees show only the curriculum appropriate to the character’s lineage and spawn world. Existing valid skills and research migrate into the new system.
- Milestones add focused build options for martial arts, weapons, Ki, survival, fire, criticals, stat specialization, area attacks, double hits, and unencumbered fighting.

**MINING, SMITHING, MAGIC & SCIENCE**
- Planets now contain finite, replenishing deposits of Copper, Tin, Iron, Silver, Mythril, Auracite, and Heart of the Mountain.
- Smithing adds material-based swords, war hammers, gloves, masks, and armor. Appearance is cosmetic; material and quality determine real combat stats.
- Magic adds Arcane Essence, 41 workshop formulas, circles, transmutation, portals, enchanted equipment, elixirs, artifacts, constructs, and new offensive/support spells.
- Science adds tiered training bags, genetics, mutation tools, repair/upgrade kits, medical and prospecting tools, Power Armor, Android components, and more.

## Discord post 4/6 — Combat and movement

**COMBAT OVERHAUL**
- Rebalanced power-gap scaling, melee, Force, offensive skills, criticals, clashes, knockback, attack speed, damage caps, and team pressure.
- New target cycling and improved Sense/targeting make fights easier to read and control.
- Five-player combat teams are supported with team-aware combat behavior.
- Ki Weapons now form a full progression branch: Ki Fist, Ki Sword, Ki Hammer, Spirit Sword, and five proficiency stages from Normal to Masterwork.
- Added or restored a large attack library, including Dragon Nova, Sky Break, Echoing Slash, Rock Throw/Slide/Tomb, Black Flash, Wind Howl, Earthquake, Evasive Barrage, Sphere of Destruction, Super Explosive Wave, Super Ghost Kamikaze Attack, advanced beams, magic spells, and Viltrumite techniques.
- Dragon Rush, Dash Attack, Pressure Punch, Roundhouse Kick, Wolf Fang Fist, Super Dropkick, beams, guided attacks, giant forms, ghost homing, and large energy spheres received major fixes.
- Attacks can no longer be fired through invalid frozen/Dragon Rush states, and launch movement/turning behavior is more consistent.

**MOVEMENT**
- The game now runs at 60 FPS with smooth vector-based movement instead of the old tile-feeling movement path.
- Diagonal speed, input stacking, walls, flight collision, attack movement locks, projectile origins, dashes, knockback, tap-warping, and movement recovery were corrected.
- Walk mode was added for precise movement, alongside configurable single-press and double-tap bindings.

## Discord post 5/6 — UI, roleplay, and presentation

**NEW INTERFACE**
- The legacy login flow was replaced with a character-slot menu and cleaner creation/entry transitions.
- Chat moved into a side panel with separated IC/OOC-style channels and combat logs; lowercase text is preserved and live updates no longer flash the window.
- The permanent CMD panel provides actions and contextual inspection without relying on crowded legacy tabs.
- Interface layouts can be configured, and player menus refresh live.
- The new hotkey editor supports visual keyboard layouts, modifiers, single presses, double taps, searching, and persistent custom bindings.
- The HUD gained pixel-art shortcuts, clearer vitals, active stat modifiers, separate modifier rows, accurate damage numbers, and improved overhead typing/emote/feedback stacking.
- Profile pages support persistent custom portraits, including high-resolution WEBP and WEBM art, with account identity hidden from public profiles.

**PRESENTATION & ROLEPLAY**
- Dynamic lighting was rebuilt with smoother falloff, attack-specific colors, and terrain-aware occlusion.
- Combat gained new impact, sword, rock, explosion, electricity, flight, dodge, throw, swing, and gore visuals/audio.
- Super Saiyan transformations, earthquakes, explosive waves, large attacks, and melee techniques received new or upgraded effects.
- Racial languages now persist and have learnable fluency. Unknown speech is translated partially, with teaching, racial tongues, custom languages, Universal Translators, and magical translation items.
- Qualified multiplayer RP sessions now grant progression while filtering spam, repeated text, OOC, and isolated monologues.

## Discord post 6/6 — Balance, control, and stability

**PLANETARY CONTROL**
- Each canonical planet has a persistent control point that a qualified League leader can claim.
- Rulers can set Resource and Arcane Essence taxes up to 25%, manage a persistent treasury, and appoint a character as governor.
- Planets can be conquered by defeating and seizing control from the governor. Death, deletion, League departure, or prolonged absence can leave a world abandoned and claimable.
- Tax handling follows planet jurisdiction into local interiors, caves, landed ships, and portals without double-taxing transfers or recollected money.

**BALANCE & FIXES**
- Race stats and caps were comprehensively reviewed; Saiyan, Half-Saiyan, Namekian, Bio-Android, Changeling/Cooler, Makyo, Giant Form, Vampire, Alien, and other packages received fixes or rebalancing.
- Critical attacks were rebuilt and made visible in stats; they no longer bypass Reflex incorrectly.
- Soul Contract, Time Freeze, Makyo spawning, Anger KO recovery, Energy recovery, inventory clicking, character reconnects, equipment scaling, and many long-standing combat/runtime bugs were fixed.
- Alternate-character progression rewards were removed to reduce alt abuse.
- Runtime systems, object cleanup, spatial searches, pathfinding, projectile/targeting work, map persistence, and server loops were optimized.
- The project moved to BYOND 516 and gained automated compile/startup coverage, safer save separation for playtests, hardened wipe cleanup, and extensive checks for maps, assets, progression, combat, and persistence.

Welcome to the new wipe. Choose a side, build your character, and make history.

## Internal audit notes (not intended for Discord)

- Cutoff: exclusive of `cfd0bf0`, the March 21, 2024 merge titled `Merge pull request #1 from Roundstage/new-wipe-fixed`.
- Endpoint: inclusive of `b656e83`, September 7, 2026.
- Commit traversal: current branch, first-parent history, preventing duplicated parallel branch commits from being counted twice.
- The final September 2026 map state supersedes intermediate map iterations. The changelog describes the current result, not rejected or overwritten map drafts.
- Infrastructure-only changes (repository reorganization, filename casing, CI/download fallbacks, Docker packaging, documentation, and test scaffolding) are summarized under stability.
- Manual StrongDMM and live gameplay review were explicitly deferred. Automated BYOND 516.1686 compilation and startup smoke checks passed at the latest documented map handoff.
