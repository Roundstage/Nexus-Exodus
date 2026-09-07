# Nexus Exodus BYONDexe Launcher POC

## Status

Approved for BYONDexe discovery and standalone validation. Steam, Proton, WebClient, Tauri, account migration, automatic updating, and public release are outside this POC.

## Goal

Validate the official BYONDexe package as an external standalone Windows client for Nexus Exodus. The player must be able to start the branded executable without installing or navigating the BYOND Pager and connect to an isolated Nexus playtest server.

The previous WebClient approach remains abandoned. This POC does not repeat that architecture and does not add a browser-hosted launcher.

## Technical decisions

- Use the official BYONDexe package and its included README files as the source of truth.
- Do not enforce a compiler build in `DU.dme`.
- Record the Dream Maker, Dream Daemon, client runtime, and BYONDexe versions independently for every artifact.
- Start with BYONDexe directly. Do not add another launcher process during this POC.
- Use the existing isolated playtest server and playtest save roots. Never run destructive compatibility tests against live data.
- Keep `SECRETS.dm`, the BYONDexe distribution key, and generated private configuration outside Git.

## Phase 0 — Package and access discovery

1. Obtain the official BYONDexe archive without executing its binaries.
2. Record the source URL, download date, SHA-256, archive contents, and executable signatures when available.
3. Read all included README files and document the supported configuration, package layout, redistribution rules, dependencies, Hub association, and distribution-key workflow.
4. Confirm access to the Nexus Hub Distribution key without printing, copying into documentation, or committing it.
5. Determine whether a game compiled with the repository baseline can be packaged with the selected BYONDexe release. If not, validate a newer compiler with the existing zero-warning compile and startup smoke tests before changing the baseline.

Output: `docs/ByondExePackageInventory.md` and a GO/BLOCKED decision for building the first internal executable.

## Phase 1 — Reproducible standalone build

Create a staging script that:

1. accepts an explicit clean source commit and selected BYOND tool versions;
2. creates an ephemeral directory outside the repository;
3. stages only sanitized client inputs;
4. receives the distribution key without command-line exposure;
5. generates the Dream Maker distribution package through the documented workflow;
6. runs BYONDexe without modifying vendor files;
7. fails if required inputs or expected outputs are missing;
8. records hashes and a version manifest;
9. removes key-bearing configuration in `finally`, including after failure;
10. verifies that local Hub credentials and unrelated server secrets are absent from the distributable artifact.

Do not use an existing `DU.dmb`, `DU.rsc`, or `DU.dyn.rsc` from the repository root as a build input.

## Gate A — Standalone viability

Required scenarios:

- Windows profile without BYOND installed;
- first execution with an empty BYOND user directory;
- execution with BYOND already installed;
- path and username containing spaces and accented characters;
- no administrative privileges;
- WebView2 present and WebView2 absent;
- server online, offline, full, and rebooting;
- cold resource cache, warm cache, and interrupted first download;
- authenticated BYOND account creating, saving, closing, reopening, and loading the same character;
- guest access only as a disposable diagnostic flow;
- second execution and recovery after a failed execution.

Approval requires all P0 cases to pass, no BLOCKER or HIGH defects, no modification outside the documented BYOND/client directories, and enough diagnostics to distinguish package, dependency, network, and server failures.

## Gate B — Nexus compatibility

Compare the standalone client with ordinary Dream Seeker against the same playtest server commit. Cover movement and held keys, combat, targeting, teams, HUD, stat panels, browser controls, `browse()`/`browse_rsc()`, `winset()`/`winget()`/`winshow()`/`winclone()`, character creation, saving/loading, map transitions, audio, overlays, filters, particles, lighting, scaling, focus changes, and reconnection.

Record cold-start time, warm-start time, resource-download size, time to character selection, CPU, memory, FPS in a repeatable combat scenario, and crashes. Each case must identify environment, preconditions, steps, expected result, evidence, severity, and final state: PASS, FAIL, BLOCKED, or NOT RUN.

## Deliverables

1. Official package inventory and README summary.
2. Sanitized configuration templates.
3. Reproducible staging/build script.
4. Internal standalone executable and complete artifact manifest.
5. Clean-profile Windows report.
6. Nexus compatibility report against Dream Seeker.
7. Defect list with severity and reproduction steps.
8. Final `POC-GO-BYONDEXE`, `POC-NO-GO-BYONDEXE`, or `BLOCKED` decision.

## Explicit exclusions

- Steam APIs, App ID, Overlay, license checks, achievements, or Steam distribution;
- Proton, SteamOS, or native Linux support;
- WebClient or browser-hosted game client;
- Tauri or another wrapper around BYONDexe;
- automatic updater, installer, code signing, telemetry, or crash reporting;
- public beta or commercial publication;
- final Nexus account system or Steam-to-Nexus identity binding.
