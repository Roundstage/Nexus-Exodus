# Viltrum / Earth rebuild handoff — 2026-09-06

> 2026-09-07: [Runtime shoreline fix](EarthRuntimeCliffFix.md) prevents the legacy
> zone decorator from replacing Earth water with Wall7, flooding nearby land,
> or painting old edge/wave overlays over authored banks.

> 2026-09-07: [Interior teleport fix](InteriorTeleportFix.md) protects runtime
> map order from Dream Maker re-registration and validates door destinations.

> Latest Earth revision: [EarthNaturalLandmarks.md](EarthNaturalLandmarks.md).
> Explorable mountains, dunes and a forest waterfall built entirely from turfs;
> no remote buildings or old terrain stairs. The city and current spawns remain.

> Latest Earth revision: [EarthWilderness.md](EarthWilderness.md). One western
> city, six remote shelters, no intercontinental roads, connected rivers, and
> preservation of the user's subsequent city edits and relocated spawn points.

> Current Earth delivery: [EarthCityRebuild.md](EarthCityRebuild.md). Ordinary
> neighboring houses, separate interiors, continuous riverbanks and asphalt
> bridges are applied and pass the full startup smoke on 2026-09-06. The counts,
> hashes and original exact-water preservation statements below are historical;
> the latest bounded river correction changes 290 terrain cells. Viltrum's
> exterior design remains pending after the user's rejection. This older report
> is retained as history and does not certify the current in-game appearance.

The scripted rebuild and automated integration are delivered for both planets.
The user approved the revised Viltrum style and explicitly chose to preserve
Earth's continents and adapt the proposed atlas. StrongDMM and interactive
gameplay/day-night/scanner review remain deferred; the brief's manual acceptance
criteria are not certified by the offline atlas.

## Delivered

- Fifty editable 100x100 local-Z=1 chunks, two deterministic 500x500 outputs,
  original global Z20/Z21 and map include order.
- Viltrum: capital, residences, palace, science, training, arena, shipyards,
  fabrication, energy works, polar citadel, islands, ruins and outposts.
  Original slice plus expansion: 42 public interiors and 60 destinations.
- Earth: west city by the unchanged Human spawn and landing, eastern suburbs,
  port/industry, rural and coastal settlements, northern arctic station, central
  preserve, jungle and southern oasis settlements: 42 interiors, 52 destinations.
- Full-block structural roofs, decorative wall faces, genuine alpha furniture.
  Five Viltrum animated door styles, 25 panels in five public entrance groups.
- Original Viltrum native Aseprite kit, curated existing Earth art and original
  quiet asphalt/concrete materials. No ClassicBlunder imports were necessary.
- Both 21x21 arrival zones preserved; Earth's 20 spawn stacks, 21 waterfall cells
  and all original grass stairs preserved. Every baseline water cell remains
  water, water-marked bridge or inaccessible ocean boundary.
- Recovered and retained all 2,152 manual Viltrum tile edits before expansion.
- Eight-tile solid boundary belts. Roof/boundary Enter blocks flight bypass;
  mob SafeTeleport resolves boundary destinations to the existing landing.
  Arbitrary direct loc assignments are not covered by the SafeTeleport hook.

## Evidence

| Check | Result |
| --- | --- |
| BYOND 516.1686 full compile | 0 errors, 0 warnings |
| Full startup smoke | Versioned and Clean pass; no startup runtimes |
| Deterministic chunk/parser/overwrite suite | 10 groups per planet |
| Viltrum graph and geometry | Rooms, alternate entries, combat, all 40 seams and manual edits pass |
| Earth graph and preservation | All rooms/20 spawns connected, alternate entries, land seams, biomes, arrival and falls pass |
| Asset metadata audit | 7 manifests, 11 native sources, 12 DMIs, 103 states, 113 frames pass |
| Naming | No source/asset path issues; legacy identifiers remain |
| Strict asset references | Existing bare logo path in UIStuff.dm:91 still fails; no new missing/ambiguous/case errors |
| Editor compatibility | Headless individual-chunk parser passes; no StrongDMM opened |
| Offline visual review | Updated 25-chunk atlases and representative player-scale chunks inspected |

Machine-readable evidence: PlanetAssetChecks.json, ViltrumSliceChecks.json,
ViltrumWorldChecks.json, SuperEarthWorldChecks.json and each planet's Metadata.json.
Counts are serialized DMM atoms, not constructor-created runtime populations:
Viltrum 250,000 turfs / 231 objects / 0 mobs; Earth 250,000 / 499 / 0.

## Scope and remaining manual review

Interiors are public RP fixtures; a clinic, shop, factory or reactor label does not
add healing, trading, crafting or a new power economy. Doors have temporary
transition/close timers, no idle processing loop or active lights. Furnishings
remain intentionally sparse to preserve combat space and atom budget.

The atlas uses actual first-frame terrain and supported furnishing sprites;
legacy vegetation overlays, auto-borders, animations, lighting and runtime
scanner rendering require gameplay review. Test high-speed fighting, all-direction
door use and day/night seams in game when the user resumes that review.
The existing space icon is retained. Smaller transition/corner and specialized
prop variants from the aspirational asset list are not all implemented.

Edit chunks and native art, then assemble/export. One-time authoring scripts retain
guarded historical inputs and are not general regeneration commands.
See Viltrum.md and SuperEarth.md for supported commands and geographic atlas.
No commit, deployment or changes to unrelated dirty UI work were performed.
