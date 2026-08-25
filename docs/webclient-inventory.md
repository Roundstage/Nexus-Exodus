# Nexus Exodus WebClient inventory

## Purpose

This inventory is the gate before treating the Tauri wrapper as a viable client. Counts were captured from the repository on 2026-08-24 and should be regenerated when the interface changes.

```sh
rg -o --glob '*.dm' '\bwinset\s*\(' src | wc -l
rg -o --glob '*.dm' '\bwinget\s*\(' src | wc -l
rg -o --glob '*.dm' '\bbrowse\s*\(' src | wc -l
rg -o --glob '*.dm' '\bbrowse_rsc\s*\(' src | wc -l
rg -c '^window "' UI.dmf
rg -c '^macro "' UI.dmf
rg -n '^\s*name = ".*\+(UP|REP)"' UI.dmf | wc -l
```

| Surface | Baseline | Compatibility concern |
| --- | ---: | --- |
| `winset()` calls | 226 | Control IDs and supported skin parameters must match. |
| `winget()` calls | 24 | Return values, focus, visibility and asynchronous behavior must match. |
| `browse()` calls | 92 | Popups, named controls, JavaScript and `byond://` callbacks must work. |
| `browse_rsc()` calls | 21 | Fonts, generated icons and resources must resolve in a browser session. |
| Windows in `UI.dmf` | 33 | WebClient conversion may not reproduce window/menu behavior exactly. |
| Macro sets | 3 | The selected macro set and repeat/release behavior are combat-critical. |
| `+UP`/`+REP` macro entries | 53 | Focus loss and key release require direct testing. |

## Critical contracts

### Input and movement

`UI.dmf` defines repeated movement and release verbs. A pass requires all cardinal and diagonal movement, repeat, release, modifier and focus-transition cases. A synthetic key event is not sufficient evidence; test with physical input and alt-tab.

### Map and layout

Gameplay uses `mapwindow.map` as the primary map and dynamically attaches `mapwindow`, `rpane`, `infowindow` and `nexuschatwindow` through `winset()`. The automatic `UI.dmf` conversion must be tested before activating a custom `.dms` skin.

### Browser controls

Named browser surfaces include character, build, inventory, trade, forge, player menu, admin and invisible helper controls. Several send `byond://` topics to `client.Topic()`. The launcher must not interpret those URLs itself; they must remain internal to the official WebClient.

### Dynamic UI

Grids, bars, labels, tabs, visibility and focus are updated from DM. At minimum validate character creation/selection, legacy tabs, target/team combat UI, command input, inventory, build, crafting and trade.

### Rendering and audio

Validate overlays, underlays, maptext, transforms, filters, lighting, simultaneous effects and music against a standalone browser baseline on the same machine.

## Spike order

1. Compile with BYOND 516.1686 without selecting `src/WebClient/NexusPrototype.dms`.
2. Enable WebClient on a private test Dream Daemon.
3. Test the server-provided WebClient URL in standalone Chrome/Edge and Firefox.
4. Record behavior of the automatic `UI.dmf` conversion.
5. Only if required, configure `NexusPrototype.dms` as a diagnostic skin and expand it control-by-control.
6. Once the browser baseline passes, repeat the same cases in WebView2 and WebKitGTK through the launcher.

## Known blockers before live validation

- The repository does not contain a confirmed WebClient URL or deployment configuration.
- The prototype `.dms` intentionally implements only map, info, command input and core movement macros; it is not a replacement for the current skin.
- Distribution and branding permission for the BYOND WebClient still requires written confirmation before public release.
