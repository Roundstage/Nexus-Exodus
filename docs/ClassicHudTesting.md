# Classic combat HUD — implementation and verification

Implemented on 2026-09-07 from `ClassicCombatHudPlan.md`.

## Player controls

- **Menu**: searchable Actions / Other, Playtest, Sagas, Factions, Stats and contextual information. World/Admin retain permission checks. **All native tabs** opens the existing Info pane, including original atom context menus.
- **Sense**: opens independent Sense and target monitors. Opening Inventory or Skills does not replace them. Detectable target health, energy, power and stat build update during combat; the server's existing Sense/build visibility rules apply.
- **Chat**: drag the header to move, drag an edge/corner to resize, scroll with the wheel. Incoming messages preserve history reading position. The new-message indicator returns to the bottom. Secondary composition/log controls are under the ellipsis.
- **MMO hotbars**: there is no application-imposed maximum number of bars or slots per bar. Each bar is an independent embedded control with its own name, slot list, columns, icon size, lock, visibility and position. Create/delete bars and add/remove slots through Hotkeys. Slot additions support +1 and +12 operations; these are increments, not capacity limits. Slots show the icon, abbreviated key and a circular cooldown/count. The narrow rail has a drag handle, **K** (Hotbar / Hotkeys) and **U/L** (unlock/lock). Lock prevents moving, resizing or changing actions directly on the bar. Right-click opens slot options. Drag skills/items from Inventory/Skills, or exact verbs from the command menu; BAR buttons and the editor provide click alternatives.
- **Hotkeys**: select any bar and slot, then drag or select a catalog action. The editor paginates 12 slots at a time so the key controls stay visible, irrespective of total slot count. Capture the real key combination or use the key selector and Ctrl/Shift/Alt controls; double tap is optional. Existing combinations require confirmation before replacement. Keys belong to slots; swapping actions changes which action that key executes. Multiple keys can activate one slot. Other existing shortcuts remain listed and functional. Columns have no fixed maximum: they may range from one to the number of slots in that bar. Icons remain square when resizing. Bars can be shown or hidden independently.
- **Stats**: Character → LIVE STATS, Menu → STATS, or double-clicking the vitals HUD opens an independent, searchable, live Stats panel. It includes all native Stats fields, including combat attributes when the legacy `classic_ui` flag is off. **Menu → Reset HUD** restores panel geometry and can reopen closed monitors.
- **Vitals**: default scale is 75%. Interface Settings → Main Vitals Panel offers 50%, 75%, 100%, 125% and 150%; position and scale persist. Frames and bars are drawn at their final pixel dimensions. Text uses cached bitmap glyphs at 8/12/16px; below 100% the labels use WP/HP/KI/STA. The buff strip reserves three full text rows and shortens names/stat summaries to fit its width, with `+N MORE` for additional modifiers.
- Panel geometry and vitals scale are account preferences. Hotbar actions/layout are character save fields and are backed up per character slot and creation timestamp, preventing a new character from inheriting deleted-character actions. Keyboard slot assignments use the existing account hotkey backup. Old bindings already represented on the bar migrate to slots; unrelated shortcuts are preserved.

## Automated verification

Run from the repository root:

```powershell
.\tools\Invoke-ByondSmoke.ps1
node tools/TestClassicHud.cjs
node tools/BuildClassicCommandCatalog.cjs --check
node tools/MapAssembly/TestRuntimeMapOrder.cjs
.\tools\Test-AssetReferences.ps1 -Strict
.\tools\Test-NamingConventions.ps1
```

`ClassicHudSmoke.dm` covers bounded geometry, preserving distinct monitor positions after a resolution change, world-time and real-time cooldowns, active toggles, missing optional state fields, slot migration/reorder/key identity, unbounded growth (more than three bars and 61 slots in one bar), stable IDs after removal, savefile roundtrip, pagination, removed verbs/items, complete Stats without legacy UI, vitals-scale bounds, missing-target capture cleanup and required categories. Timestamp comparisons tolerate fractional-tick floating-point subtraction; calendar/real-time values keep the clocks used by gameplay.

`TestClassicHud.cjs` renders the production CSS/JavaScript in Chromium. It checks at least eight readable short lines at 550×318, long-text reflow, no horizontal overflow, history anchoring, drag resize, radial cooldowns, dynamic bar IDs and slots beyond 36, slot reorder, command search/drag, lock, editor drag/search, modifier capture, conflict acknowledgement, bar creation/growth/selection and pagination, 860/600/380-pixel editor layouts and browser errors. `artifacts/ClassicHud/ChatMinimum.png` is a browser test capture, not a Dream Seeker screenshot.

The browser test needs Playwright and Chrome/Chromium. It accepts `NEXUS_PLAYWRIGHT_MODULE` and `NEXUS_BROWSER_EXECUTABLE` overrides; otherwise it uses an installed Playwright package and the standard Windows Chrome path (or Playwright's browser on other platforms).

The naming audit still reports the repository's unfinished legacy identifier migration; file, directory and asset naming checks are clean. The strict asset reference audit reported no missing, ambiguous or incorrectly cased references.

## Native BYOND verification

The disposable native fixture uses BYOND **516.1686**. It changes login and account exports only in a temporary source copy, supplies two test characters, enables readable builds in that copy, binds Pressure Punch to `1`, adds sample messages and varies target vitals. No production data directory or account settings are used for the fixture.

```powershell
node tools/PrepareClassicHudPreview.cjs
# Compile DU.dme in the printed temporary directory, then run its DMB on a free local port.
# Connect Dream Seeker to that local port. Do not compile/run the fixture in the live checkout.
```

**Earlier baseline, before this refinement:** verified in the client: independent Sense and live target build/vitals, embedded chat and bar, click and keyboard skill execution, real cooldown display, dragging/resizing the chat with text reflow, command menu and typing a bound key in its search without firing a skill. Native tests caught and fixed unsafe optional-field access in skill state and the attempt to swap default Info controls. The corrected native window displayed the original categories and the Other command list; `artifacts/ClassicHud/NativeTabs.png` records that check. The fallback reparents the original Info pane through a CHILD control, following BYOND's pane model.

`artifacts/ClassicHud/Native1920.png` records the native combat HUD with both monitors, chat and skills visible. The fixture also ran in a smaller restored window. Tests use synthetic characters: they do not certify every conditional faction/admin/item action or every server-specific skill combination. These still use native ownership, permission and execution paths.

### Latest refinement

2026-09-11: removed whole-panel `KEEP_TOGETHER`/`PIXEL_SCALE` shrinking and replaced the build, buff and vital labels with measured bitmap glyphs. The renderer uses the bundled Silkscreen font at fixed source sizes and a bounded cache; it preserves energy amounts and percentages while fitting the available width. `runNexusVitalsLayoutSmokeTests()` checks native dimensions and anchoring at 50/75/100/125/150%, text bounds, live Focus values, literal custom names, summary overflow, and clearing the strip after deactivation. See [BuildHudRenderingResearch.md](BuildHudRenderingResearch.md) for the final rendering approach and exported runtime previews. These headless checks do not certify Dream Seeker's visual rendering; verify labels, energy amounts, active buffs and drag placement in the client after rebuilding.

The independent dynamic MMO bars, replacement hotkey editor, Stats panel and vitals scaling compile and are covered by browser/startup tests. A disposable BYOND preview started without runtimes, but native capture failed twice with `foreground window did not report a process id`. The user explicitly requested continuing without native visual verification. Cross-window drag, modifier capture inside Dream Seeker and the final scaled HUD appearance therefore remain manual checks; earlier native screenshots do not certify this refinement.

`artifacts/ClassicHud/HotbarLayout.png` and `HotbarEditor.png` render the production HTML/CSS/JavaScript with **test data and existing repository icon samples**. They are component captures, not screenshots of the game. The new chrome uses embedded Silkscreen, square bronze frames, hard pixel edges and bolts; chat text retains compact readable typography.

## Integration notes

`DU.dme` includes the new HUD modules and smoke tests. Preserve the protected map preamble when saving in Dream Maker. The editor was closed during implementation after it rewrote the generated includes from an older project state.

The interface now uses 207 dedicated skill illustrations, including the eight approved sample artworks, through `SkillArtwork.dm` and its generated catalog. Hotbars and progression nodes share these resources; projectiles and world sprites retain their existing art. The [artwork manifest and audit](../artifacts/SkillArtwork/README.md) document coverage, originals and runtime assets. Category icons/abbreviations remain available for missing states. Future skills that keep cooldowns outside the existing timer fields need an adapter in `getClassicCooldown()`.

## Runtime optimization integration (2026-09-11)

Integrated main `198bb9b` while preserving the local HUD and city-interior changes. The safety stash remains available. The merge tree matches main before reapplying local work.

The Classic HUD now coalesces chat bursts for one tick and checks a history/layout signature before formatting the history again. Periodic updates skip collapsed controls; bars and target retain their five-tick cadence, while other panels use ten ticks. Explicit user refreshes and initial payloads bypass this periodic gate. Owned commands are scanned only in command sections and revalidated on execution. Slot shortcut labels use a fresh lookup per bar instead of scanning all bindings for every slot.

Startup assertions cover refresh cadence, explicit refresh, collapsed/reopened controls, multiple shortcut labels and shortcut removal. Existing browser tests cover chat history anchoring, resize, cooldowns, drag/reorder, and editor conflicts. The generated command catalog check accepts Windows CRLF without reporting false stale metadata.

No production CPU benchmark or new native Dream Seeker gameplay inspection was performed; reduced repeated work is established by the code paths and regression assertions, not a claimed CPU percentage.

Final validation: BYOND 516.1686 compiled with zero errors and warnings; both Versioned and Clean startup smoke scenarios passed without runtimes. Browser HUD tests, runtime map order, command catalog freshness, path naming audit, strict asset-reference audit and git diff whitespace checks passed. Legacy identifier naming counts remain informational.
