# WebClient compatibility report

## Executive summary

- Decision: No-Go for the legacy BYOND WebClient
- Blockers: BYOND identity request returns HTTP 403 and the protocol closes with authentication code 9
- Recommendation: Pivot the Linux launcher to Dream Seeker through Wine/Lutris, or replace the legacy WebClient

## Builds tested

| Commit | Launcher | BYOND | Server |
| --- | --- | --- | --- |
| Working tree | 0.1.0 Linux packages | 516.1686 | Docker, healthy on `127.0.0.1:50000` |

## Environments

| OS | GPU | Driver | Session | Package |
| --- | --- | --- | --- | --- |
| Linux Mint 22.3 x86_64 | AMD/ATI device 1902 | System default | X11 | AppImage, DEB, RPM |

## Results

| Case | Result | Evidence | Defect |
| --- | --- | --- | --- |
| Frontend unit tests and production build | Pass | Vitest 3.2.7; TypeScript and Vite 7.3.6 build | None |
| Dependency audit | Pass | `npm audit`: zero known vulnerabilities | None |
| Windows Rust type/lint validation | Pass | `cargo check`; Clippy with warnings denied | None |
| Linux Rust tests and lint | Pass | 3/3 tests; Clippy with warnings denied in the builder image | None |
| BYOND Docker build and startup | Pass | BYOND 516.1686; zero compiler errors/warnings; container health check passing | None |
| WebClient HTTP endpoint | Pass | `GET http://localhost:50000/play`: HTTP 200; main JavaScript resource served | None |
| Linux native packaging | Pass | AppImage, DEB and RPM generated for x86_64 | None |
| Linux AppImage startup | Pass | Process remained alive for the 15-second X11 smoke window and was stopped by the test timeout | Optional host GTK/GVFS modules emitted warnings |
| Static security implementation | Pass in source | Exact host/scheme validation; game capability is empty; commands check caller label | Requires runtime attack test |
| Browser WebClient authentication | Fail | Chrome and Firefox open the socket and load all resources; BYOND identity request returns 403, followed by `Quit: code 9` | BLOCKER |
| Browser local-network access | Pass | Firefox prompts for and grants access to `http://127.0.0.1:50000/query` | None |
| WC-001 through WC-012 | Blocked | Authentication closes the socket before gameplay begins | BLOCKER |
| LN-001 through LN-010 | Partial | Linux build/startup covered; Windows and macOS packages not executed | BLOCKER |

## Performance

| Metric | Browser | Tauri | Difference |
| --- | ---: | ---: | ---: |
| Connection time | Pending | Pending | Pending |
| Idle memory | Pending | Pending | Pending |
| 60-minute memory | Pending | Pending | Pending |

## Security

- Remote IPC: no capabilities; custom commands also enforce the `launcher` label
- Navigation: exact host allowlist, HTTPS in production, loopback HTTP in development
- Logs: host and correlation ID only; no URL query string

## Incompatibilities

| Feature | Severity | Workaround |
| --- | --- | --- |
| Legacy BYOND WebClient authentication | BLOCKER | No repository-side workaround; use Dream Seeker or a replacement client |
| BYOND wrapper is HTTPS while the local game endpoint is HTTP | BLOCKER | Modern browsers apply mixed-content and local-network-access controls |
| Legacy advertising script is HTTP/blocked | MAJOR | Not required for rendering, but demonstrates that the hosted wrapper is incompatible with current browser security defaults |
| Optional GTK/GVFS module version warnings when starting AppImage | MINOR | Prefer the DEB package on Debian-based systems, or start the AppImage with a clean module environment |

## Go/No-Go

No-Go for the legacy WebClient path. Compilation, Docker startup, resource delivery, Linux packaging, launcher startup, and browser local-network permission pass. Chrome and Firefox both load the game resources, but the BYOND identity request is rejected with HTTP 403 and the WebClient closes with authentication code 9. The subsequent zero-sized WebGL framebuffer warnings occur after disconnection and are not the root cause.
