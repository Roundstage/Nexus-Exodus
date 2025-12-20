# Repository Guidelines

## Project Structure & Module Organization
- `DU.dme` is the Dream Maker environment; it includes all `.dm` sources. Add new code files to the `// BEGIN_INCLUDE` block.
- `src/Code/` contains game logic, grouped by subsystem (Combat, Movement, World Mechanics, etc.).
- `src/Icons/`, `src/Images/`, `src/Sound/` hold assets; `src/Maps/` contains `.dmm` maps.
- `UI.dmf` defines the client skin. `data/` holds runtime saves and logs (avoid committing ad-hoc changes).

## Build, Test, and Development Commands
- Build (BYOND 516): open `DU.dme` in Dream Maker -> `Build > Compile` (produces a `.dmb`).
- Run locally: open the compiled `.dmb` in Dream Daemon or use Dream Maker's `Run`.
- Release: package the `.dmb` plus required assets from `src/` and `data/` as needed.

## Coding Style & Naming Conventions
- Language is BYOND DM. Use tabs for indentation and keep proc blocks compact.
- Match nearby conventions: procs often `PascalCase()` while vars mix `snake_case` and `lowerCamelCase`.
- Keep file names descriptive and aligned with their subsystem (e.g., `src/Code/Combat/Melee.dm`).
- If you add assets, mirror existing folder structure and update references in `.dm` or `.dmf`.

## Testing Guidelines
- No automated test suite is present. Validate changes manually:
  - Compile without warnings.
  - Exercise the affected feature in-game.
  - Check runtime output/logs (see `data/Logs` and `data/Bugs`).

## Legacy & Refactor Notes
- This is a legacy BYOND codebase dating back to 2017; refactors should be incremental and well-scoped.
- The main proc reference for agents lives under `docs/procs/` (per subsystem). Update it when behavior changes.

## Commit & Pull Request Guidelines
- Follow existing prefixes from history: `Fix:`, `Feat:`, `Refactor:`, `Patch:` plus a short, sentence-case summary.
- PRs should include: a concise description, testing notes, linked issues (if any), and screenshots for UI/map changes.

## Security & Configuration Tips
- `SECRETS.dm` stores hub credentials and admin levels. Keep secrets empty or local; do not commit real passwords.
