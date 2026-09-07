# BYONDexe 516.1687 Package Inventory

## Acquisition

- Source: `https://www.byond.com/download/build/516/516.1687_byondexe.zip`
- Downloaded: 2026-08-24
- Size: 7,405,533 bytes
- SHA-256: `fe2cb843ec8591269d7b0b43a1ae84b01dbd6edc2db4e22a7a0bbc03bd8b6c02`
- Inspection directory: temporary local storage outside the repository
- Execution status: no executable or DLL from the archive was run

The archive was downloaded over HTTPS from the official BYOND build archive. BYOND does not publish a separate checksum beside this download, so this locally recorded hash provides repeatability but is not an independently authenticated vendor checksum.

## Package contents

```text
byondexe/
├── byondexe.exe
├── byondexe.ini
├── install.nsh
├── README-CONFIG.txt
├── README.txt
├── verpatch.exe
└── setup/
    ├── livetest.html
    ├── bin/
    │   ├── byondcore.dll
    │   ├── byondext.dll
    │   ├── byondwin.dll
    │   ├── dd.exe
    │   ├── dreamseeker.exe
    │   ├── fmodex.dll
    │   ├── mydream.exe
    │   ├── steam_api.dll
    │   ├── WebView2Loader.dll
    │   └── directx/
    │       ├── DSETUP.dll
    │       ├── dsetup32.dll
    │       ├── DXSETUP.exe
    │       ├── dxupdate.cab
    │       ├── Jun2010_D3DCompiler_43_x86.cab
    │       └── Jun2010_d3dx9_43_x86.cab
    └── cfg/
        ├── hub.css
        └── hub.html
```

## Relevant binary metadata

| File | Version | Signature | SHA-256 |
| --- | --- | --- | --- |
| `byondexe.exe` | Not reported | Not signed | `d02847c9183e69600dce7632eaa87bb760ff1761a7fd892e611745748e3eea5f` |
| `verpatch.exe` | 1.0.9.22 | Not signed | `a8138a96dd8cc8ef15a545ecb41dede54ed1ebfc9260f133bcbffe47343ba077` |
| `setup/bin/mydream.exe` | 5.0.516.1687 | Not signed | `bf6c27e43680a29a85d5e09014629743651265d61fea08a1ddd086b2e18387d6` |
| `setup/bin/dreamseeker.exe` | 5.0.516.1687 | Not signed | `abfd4412e0e22d2e91fb919bd6c1bed449aaf0a909242ea73a63deb9f2f614fa` |
| `setup/bin/dd.exe` | 5.0.516.1687 | Not signed | `2e3815875c4dcf3c50de70c1c6e017849efe8697c428f02ab9ee77c306c8abf0` |
| `setup/bin/WebView2Loader.dll` | 1.0.2088.41 | Valid Microsoft signature | `93894609e3365b62fbb4d5b4219b4199a271888160669c33dbaadbbaf5aff087` |
| `setup/bin/steam_api.dll` | 06.28.18.86 | Valid Valve signature | `ce6f48938493b90ffa175fc93f2b8ee5189e5db81f1274d5b57c9841d6fe4179` |

The presence of `steam_api.dll` does not put Steam integration in scope and no Steam APIs will be added during this POC.

## Build contract from README.txt

The following `byondexe.ini` fields are mandatory:

- `key`: game-specific BYOND distribution key requested from BYOND Staff;
- `byond`: runtime `bin` directory;
- `include`: one or more directories embedded in the output;
- `exe`: name of the generated standalone executable.

The direct `exe` output is an installerless distributable. On first execution it extracts the actual executable into the BYOND user directory and launches it. Included `.rsc` files receive special first-load import handling.

Optional outputs include an update ZIP and an NSIS installer. Both are outside the current POC. `verpatch.exe` is used by BYONDexe to set company, product, and version resources.

## Local game package

`README-CONFIG.txt` requires a `hub.zip` for local installation. It must be the regular game package produced by Dream Maker and must contain the matching `.dmb`, `.rsc`, and any other required files. BYONDexe installs this ZIP locally and removes the ZIP after extraction.

The repository must not package an existing ignored root artifact. The `.dmb` and `.rsc` used for `hub.zip` must come from the same clean build and source commit.

## Account and launch configuration

Relevant `hub.ini` options are:

- `LoginFirst`: automatically use the last account or show login;
- `LoginOptional`: permits automatic guest login when true;
- `NoGuest`: disables guest login and overrides `LoginOptional`;
- `SkipSplash`: bypasses the splash only when guest login is allowed; the README explicitly discourages this when users need to log in;
- `AutoControlFreak`: defaults to true and overrides world settings; false preserves the world setting;
- `CommandLine`: passes additional Dream Seeker options;
- `DebugBrowser`: enables embedded browser diagnostics when true.

Initial Nexus hypothesis:

```ini
LoginFirst = true
LoginOptional = false
NoGuest = true
AutoControlFreak = false
DebugBrowser = false
```

This is not yet an approved configuration. It must be verified against the normal Dream Seeker login and input behavior. In particular, Nexus persistence is keyed by the authenticated BYOND key and the project has extensive runtime macro handling.

## Resource and browser observations

- A bundled `.rsc` can seed the local cache and avoid a redundant first download.
- `PreloadRscUrl` tracks the server resource URL and invalidates the local copy when the server changes it.
- The customization README still says the splash uses Internet Explorer, while this 516.1687 package includes `WebView2Loader.dll` and current BYOND 516 uses WebView2. Treat that sentence as stale documentation and test the actual runtime.
- BYOND credits in the About interface are required by the README and must not be removed by visual customization.

## Current blockers

1. A valid Nexus-specific BYOND distribution key has not been supplied to the build process.
2. The Dream Maker workflow for producing the Nexus `hub.zip` still needs to be exercised with a clean build.
3. Compatibility between the repository's tested compiler baseline and the 516.1687 client runtime must be demonstrated.
4. A multi-resolution Nexus `.ico` asset is not yet available.

No BYONDexe binary should be executed and no standalone should be generated until the distribution key and package authorization are confirmed.
