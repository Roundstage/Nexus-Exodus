# Nexus Exodus Launcher prototype

This directory contains the isolated Tauri 2 proof of concept. It deliberately does not embed credentials, bypass TLS validation, or grant Tauri capabilities to the remote `game` window.

## Prerequisites

- Node.js 22 and npm
- Current stable Rust toolchain
- Tauri 2 Linux system dependencies, or WebView2 on Windows
- A confirmed BYOND WebClient URL

## Configure

Replace the development URL in `src-tauri/resources/launcher-config.json` for a test build. For a local per-user override, place `launcher-config.json` in the platform application configuration directory for `com.nexusexodus.launcher`.

Only exact hosts in `allowedGameHosts` are accepted. Production accepts HTTPS only; development additionally accepts HTTP loopback URLs. Usernames and passwords embedded in URLs are always rejected.

## Develop and test

Start the local Dream Daemon/WebClient from the repository root first:

```sh
./tools/Invoke-NexusLocalDocker.sh up
```

The bundled development configuration opens `http://localhost:50000/play`.
This endpoint is provided by Dream Daemon's WebClient mode; no separate local
HTTP server is required.

```sh
npm install
npm test
npm run tauri dev
```

For release packages:

```sh
npm run tauri build
```

On a Linux host with Docker, the complete native toolchain can remain isolated:

```sh
./tools/Build-NexusLauncherLinux.sh
```

AppImage, DEB and RPM outputs are exported to
`NexusExodusLauncher/artifacts/linux`.

Do not distribute a build until the manual WebClient protocol in `../docs/test-protocol.md` passes. The packaged default intentionally points to localhost and cannot accidentally connect to an unapproved server.

## Security model

- `launcher` loads packaged assets and has the minimum core Tauri capability.
- `game` is created in Rust, receives no capabilities, and is restricted by the same URL validator used by the external-browser fallback.
- Every custom Rust command independently rejects callers whose window label is not `launcher`.
- Logs contain the game host and a correlation ID, never the query string.
