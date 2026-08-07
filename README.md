# Nexus Exodus

Nexus Exodus is a BYOND-based sandbox with PVP and RP features.

This game has a lot of features. Transformations (such as Super Saiyan), customisation (stat builds), construction (the sandbox part comes here), and a lot of smaller things. 

New characters use a classic-inspired brown and gold creator with current lineage selection, catalog-backed body and hair choices, race-exclusive traits, and manual allocation of all eleven starting attributes. Race initialization is split into file-per-race modules under `src/Code/Races`, while global, world, combat, and mob variables are grouped under `src/Code/CoreFunctions/Vars`.

## Build and smoke test

Nexus Exodus is pinned to [BYOND 516.1685](https://www.byond.com/download/build/516/516.1685_byond.zip). Other compiler builds are rejected by `DU.dme`.

Run the complete compile and startup baseline from PowerShell:

```powershell
.\tools\Invoke-ByondSmoke.ps1
```

For a non-interactive local compile that never starts Dream Daemon, use `.\tools\Invoke-ByondSmoke.ps1 -CompileOnly`. Runtime smoke tests remain enabled by default and in CI.

The script downloads the official BYOND archive, verifies its SHA-256, copies the working tree to a temporary directory, compiles with zero warnings, and observes startup with both versioned and clean runtime data. The checkout is not modified.

Use `-KeepTemp` to preserve the temporary build or `-DataMode Versioned`/`-DataMode Clean` to run one data mode.

## Manual development

Install BYOND 516.1685, open `DU.dme` in Dream Maker, and select `Build > Compile`. A runnable build consists of both `DU.dmb` and `DU.rsc`.

Start the compiled world in Dream Daemon or use Dream Maker's `Run` command. Do not enable `NEXUS_DEV_TOOLS` in distributed builds.
