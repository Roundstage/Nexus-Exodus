# Integrated buff appearances

Unmodified DMI resources copied from the owner-supplied Roleplay-Tenkaichi repository. These are persistent character effects; hotbar artwork and activation bursts remain separate.

`VisualEffects/PresetBuffAppearance.dm` restores the original Focus electricity, Muscle/Magic Force auras, halos, Channel and Ultimate effects, plus Four Horsemen auras. Combat Mathematics and the Nexus stance/Bleeding Edge presets have no dedicated persistent source sprite; they reuse the calculation cloak and tinted Muscle Force/Bushido art. The commented RPT Pestilence appearance supplies its aura and flies. Large effects use centered or source-authored offsets. Buff stats and costs remain Nexus values.

The appearance manager reconstructs these layers from the active skills on rebuild and load, removes saved duplicates, and clears them on deactivation. Custom buff overlays and equipment retain their existing behavior.

| Nexus file | RPT source under `Icons/` |
| --- | --- |
| RTFocusElectricity.dmi | Aura Icons/blue elec.dmi |
| RTMuscleAura.dmi | Aura Icons/Judgement_fitted.dmi |
| RTMagicAura.dmi | Aura Icons/blackflameaura.dmi |
| RTDemonicHalo.dmi | Misc Icons/Effects/Halo Custom 2.dmi |
| RTAngelicHalo.dmi | Misc Icons/Effects/Halo Custom.dmi |
| RTChannel.dmi | Aura Icons/ChannelIcon.dmi |
| RTBlueCloak.dmi | Aura Icons/Blue Cloak.dmi |
| RTPinkCloak.dmi | Aura Icons/Pink Cloak.dmi |
| RTPurpleCloak.dmi | Aura Icons/Purple Cloak.dmi |
| RTGodspeedElectricity.dmi | Aura Icons/SSj3ElectricTobiUchiha.dmi |
| RTFistsOfFury.dmi | Technique Icons/GaoGaoFists.dmi |
| RTArcanePower.dmi | Arcane Power (1).dmi |
| RTRisingRocks.dmi | Misc Icons/Effects/Rising Rocks.dmi |
| RTBestialCloak.dmi | Aura Icons/LSSJ CLOAK.dmi |
| RTBushido.dmi | Technique Icons/SatsuiAura2.dmi |
| RTBurningFists.dmi | Technique Icons/Flaming fists.dmi |
| RTCalculationCloak.dmi | Aura Icons/Power Cloak.dmi |
| RTWar.dmi | Technique Icons/War.dmi |
| RTDarkAura.dmi | Aura Icons/Death.dmi |
| RTPaleAura.dmi | Aura Icons/PaleAura.dmi |
| RTRedAura.dmi | Aura Icons/SSRAura1.dmi |
| RTFlies.dmi | Misc Icons/Effects/Flies.dmi |
