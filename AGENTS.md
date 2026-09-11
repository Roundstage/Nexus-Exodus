# Repository Guidelines

## Project Structure & Module Organization
- `DU.dme` is the Dream Maker environment and the source of truth for compiled files. Add new code files to the `// BEGIN_INCLUDE` block.
- `src/Code/` contains game logic, grouped by subsystem (Combat, Movement, World Mechanics, etc.).
- `src/Icons/`, `src/Images/`, `src/Sound/` hold assets; `src/Maps/` contains `.dmm` maps.
- `UI.dmf` defines the client skin. `data/` holds runtime saves and logs (avoid committing ad-hoc changes).

## Build, Test, and Development Commands
- Full baseline: run `.\tools\Invoke-ByondSmoke.ps1` from PowerShell. It pins BYOND 516.1686, compiles, and runs clean and versioned startup tests in a temporary directory.
- Headless local compile: run `.\tools\Invoke-ByondSmoke.ps1 -CompileOnly`. This never starts Dream Daemon or opens a local server.
- Naming audit: run `.\tools\Test-NamingConventions.ps1`; add `-Detailed` for individual violations, `-PathStrict` to enforce paths, and `-Strict` once the identifier migration is complete.
- Asset reference audit: run `.\tools\Test-AssetReferences.ps1 -Strict` to reject missing, ambiguous, or incorrectly cased first-party asset references.
- Manual build: open `DU.dme` with BYOND 516.1686 and select `Build > Compile`.
- Run locally: open the compiled `.dmb` in Dream Daemon or use Dream Maker's `Run`.
- Release: package the matching `.dmb` and `.rsc` files plus required runtime data.

## Coding Style & Naming Conventions
- Language is BYOND DM. Use tabs for indentation and keep proc blocks compact.
- Functions/procs use `camelCase`, types/classes use `PascalCase`, and variables use `snake_case`.
- File names use `PascalCase` with no spaces (e.g., `src/Code/Combat/SpeedDelay.dm`).
- Directory names use `CamelCase` with no spaces; keep code grouped by subsystem.
- Do not create catch-all source files such as `Unsorted*.dm`, `TEMP.dm`, `Testing.dm`, or compiled note/TODO files. Every runtime definition must live in a subsystem file whose name describes its responsibility.
- If you add assets, mirror existing folder structure and update references in `.dm` or `.dmf`.

## Testing Guidelines
- User direction, 2026-09-11: leave visual and interactive BYOND verification to the user. Do not launch or control Dream Seeker or Dream Maker UI to inspect interfaces or gameplay.
- CI and `tools/Invoke-ByondSmoke.ps1` require zero compiler warnings, no startup runtimes, and passing startup assertions.
- Exercise affected gameplay manually after the automated baseline passes.
- Check runtime output/logs in `data/Logs`, `data/Bugs`, and `Errors.log`.

## Legacy & Refactor Notes
- This is a legacy BYOND codebase dating back to 2017; refactors should be incremental and well-scoped.
- The main proc reference for agents lives under `docs/procs/` (per subsystem). Update it when behavior changes.

## Persistent Mapping Decisions
- User direction, 2026-09-06: architectural turf art must occupy the entire 32x32 tile, not resemble a small freestanding prop on a floor. The initial Viltrum wall sprite was rejected for this reason.
- User clarification, 2026-09-06: **roofs are the actual walls** in this game's mapping convention: solid, collision-bearing, sight-blocking structural turfs. **Walls are decorative facade faces**, not the building's structural enclosure. Do not interpret roofs as overhead overlays covering playable interiors; put roof turfs on the structural perimeter and leave interior floor tiles walkable.
- Viltrum furnishings must have transparent backgrounds and be reusable objects over any underlying turf. Never bake a floor/background into benches, planters, banners, statues, tables or other furnishings. Define object collision separately from the transparent art.
- Generate and validate planet maps with scripts. StrongDMM inspection and interactive gameplay review are deferred at the user's request to conserve resources.
- User direction, 2026-09-06: preserve Super Earth's existing continents and adapt the proposed atlas. Keep the western Human spawn and natural landing; do not create an urban island in oceanic C3 solely to follow the original atlas.
- Latest city direction, 2026-09-06: the user rejected both the open rectangular buildings and the isolated generated tower/house objects as they look poor in game. Use ordinary house sprites packed next to each other in coherent city blocks, aligned to a common sidewalk frontage. Research references and validate one small neighborhood at player scale before expanding. Do not reuse the rejected tower sheet as the residential visual target. See docs/Maps/CityDesignReferences.md.
- Accessible buildings must use doors leading to separate interiors, as explicitly selected by the user; do not substitute same-map exterior cutaways.
- Runtime map includes must stay outside and ABOVE `// BEGIN_INCLUDE` in `DU.dme`, ordered Map2018, Space2018, Viltrum, SuperEarth, CityInteriors (global Z1-15, Z16-19, Z20, Z21, Z22). Dream Maker can register maps alphabetically inside its generated block; BYOND honors the first include. Putting the protected list after that block lets editor saves swap planet/interior Z levels. Run `node tools/MapAssembly/TestRuntimeMapOrder.cjs` after environment changes; smoke validates the compiler's actual map load order.
- User correction, 2026-09-06: author terrain and continuous riverbank corridors before city streets/lots. Avoid roads clipped by water, isolated texture rectangles and arbitrary bridge/pier fragments. Preserve spawn locations and arrival safety while allowing their ground art to change for coherent transitions. See docs/Maps/RiverCityReferences.md.
- User correction, 2026-09-06: the western Earth city is the planet's only major city. Preserve its approved neighborhood. The east continent and desert are wilderness with only isolated shelters and minimal local paths; remove intercontinental roads, ocean causeways and purposeless road stubs. Do not require every continent or racial spawn to connect to the city by walking. River water must be composed as a complete union before banks are painted, so bank segments never cut earlier water segments.

- Latest natural-terrain direction, 2026-09-06: remove remaining isolated Earth buildings outside the approved city and never place the old terrain stairs (`Stairs_Grass` / `EarthRiverSteps`) again. Mountains, dunes and waterfalls must be made entirely from 32x32 terrain tiles, with walkable terraces and continuous natural ramps so players can climb and explore. Do not use whole-landform objects like house exteriors. Structural rock faces follow the solid, opaque roof convention; cave entrances may use invisible travel triggers to separate playable interiors. Preserve the city, latest spawn locations and continuous rivers.

- Keep reserved Dream Maker block markers out of explanatory comments in DU.dme. A casual mention of `BEGIN_INCLUDE` before the real marker caused an editor save to erase the protected map preamble; TestRuntimeMapOrder.cjs now rejects this.
- Super Earth's authored riverbanks, bridges and coasts must not be rewritten by the legacy runtime cliff generator. Keep `area/SuperEarth.auto_cliffs = FALSE`; checking only turf subtypes misses manually placed legacy ground. `GenerateCliffs` must respect protected areas at the source and both possible destination tiles.
- Keep Super Earth's `auto_edges` and `auto_waves` area policies FALSE too. The runtime `GenerateEdges` and `GenerateShoreWaves` calls otherwise paint old edge/surf overlays over authored riverbanks. Check the policy inside these procs so direct calls are covered; preserve existing overlays and authored water animations.

## Commit & Pull Request Guidelines
- Follow existing prefixes from history: `Fix:`, `Feat:`, `Refactor:`, `Patch:` plus a short, sentence-case summary.
- PRs should include: a concise description, testing notes, linked issues (if any), and screenshots for UI/map changes.

## Security & Configuration Tips
- `SECRETS.dm` stores hub credentials and admin levels. Keep secrets empty or local; do not commit real passwords.
