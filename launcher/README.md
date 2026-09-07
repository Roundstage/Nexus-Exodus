# Nexus Exodus launcher

This directory contains only the tracked, non-secret BYONDexe launcher skin and configuration.

Build the internal standalone executable from PowerShell:

```powershell
.\tools\Build-NexusLauncher.ps1 `
	-DistributionKeyPath C:\secure\nexus-distribution-key.txt
```

The key file must contain only the Nexus-specific BYOND Distribution Key on its first line. It is read into memory, written only to the ephemeral vendor configuration, and removed with the complete staging directory after the build. Never place the key file in this repository.

By default the script uses the pinned BYOND 516.1686 compiler cache and BYONDexe 516.1687 package cache created by the repository tooling. Explicit archive paths can be supplied for an offline or clean machine.

Output is written to the ignored `artifacts/launcher/<version>/` directory and contains the executable plus `manifest.json` and `SHA256SUMS.txt`.
