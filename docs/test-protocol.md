# Nexus Exodus launcher test protocol

## Build identity

Record the game commit, launcher commit, BYOND version, server endpoint host, launcher package and whether the test uses automatic `UI.dmf` conversion or a custom `.dms`.

## Environment

Record OS version, kernel, CPU, GPU, driver, X11/Wayland, display scale, monitor count and WebView/browser version. Never include URL query strings, cookies or credentials.

## Gate A — standalone WebClient

Run these cases in a supported standalone browser before testing Tauri:

| ID | Case | Pass condition |
| --- | --- | --- |
| WC-001 | Clean session connection | Login/guest flow reaches character selection without Dream Seeker. |
| WC-002 | Character lifecycle | Create, select and enter the world without a broken prompt or grid. |
| WC-003 | Movement | Eight directions, repeat and release work for ten minutes. |
| WC-004 | Focus recovery | Alt-tab while holding every cardinal key; movement always stops. |
| WC-005 | Combat | Target, team indicator, melee, Ki, dodge and guard remain usable. |
| WC-006 | Chat | Command input, channels, links, colors and icons work. |
| WC-007 | Dynamic panels | Stats, build, inventory, crafting, forge and trade work. |
| WC-008 | Browser topics | Every tested `byond://` action reaches the intended DM handler once. |
| WC-009 | Rendering | Maptext, overlays, lighting, filters and animations are legible. |
| WC-010 | Audio | Music starts after interaction and simultaneous effects play. |
| WC-011 | Reboot | Server reboot produces recovery or an actionable reconnect state. |
| WC-012 | Endurance | Sixty minutes without crash, black frame or stuck input. |

Stop and classify any gameplay blocker before packaging work continues.

## Gate B — launcher security and lifecycle

| ID | Case | Pass condition |
| --- | --- | --- |
| LN-001 | Invalid scheme | `file:`, `javascript:`, `byond:` top-level and production HTTP URLs are rejected. |
| LN-002 | Invalid host | Non-allowlisted hosts and lookalike subdomains are rejected. |
| LN-003 | Embedded credentials | URLs containing username or password are rejected. |
| LN-004 | Single game window | A second click focuses the existing window. |
| LN-005 | Remote IPC | Calls to every registered command from game content are refused. |
| LN-006 | Navigation | Top-level navigation outside the exact allowlist is blocked. |
| LN-007 | External fallback | The validated URL opens once in the system browser. |
| LN-008 | Sanitization | Logs and copied diagnostics contain no query, cookie or token. |
| LN-009 | Recovery | Closing the game window allows it to be opened again. |
| LN-010 | Launcher exit | Exiting the launcher leaves no child process/window. |

## Platform matrix

At minimum execute both gates on Windows 11/WebView2, Fedora/Wayland/WebKitGTK and Ubuntu/WebKitGTK. Add Windows 10 and proprietary NVIDIA configurations as risk coverage. AppImage, DEB and RPM must also be opened on clean installations rather than only the build host.

## Defect record

For each failure record case ID, severity (`BLOCKER`, `HIGH`, `MEDIUM`, `LOW`), exact environment, reproduction steps, expected/actual behavior, sanitized logs and screenshot/video evidence. Do not replace a failed case with a fallback result; record both separately.
