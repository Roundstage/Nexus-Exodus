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
- CI and `tools/Invoke-ByondSmoke.ps1` require zero compiler warnings, no startup runtimes, and passing startup assertions.
- Exercise affected gameplay manually after the automated baseline passes.
- Check runtime output/logs in `data/Logs`, `data/Bugs`, and `Errors.log`.

## Legacy & Refactor Notes
- This is a legacy BYOND codebase dating back to 2017; refactors should be incremental and well-scoped.
- The main proc reference for agents lives under `docs/procs/` (per subsystem). Update it when behavior changes.

## Commit & Pull Request Guidelines
- Follow existing prefixes from history: `Fix:`, `Feat:`, `Refactor:`, `Patch:` plus a short, sentence-case summary.
- PRs should include: a concise description, testing notes, linked issues (if any), and screenshots for UI/map changes.

## Security & Configuration Tips
- `SECRETS.dm` stores hub credentials and admin levels. Keep secrets empty or local; do not commit real passwords.
