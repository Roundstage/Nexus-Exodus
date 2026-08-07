# Open Combat Asset Library

This library is the approved home for third-party combat VFX and old-school anime SFX. New combat effects should reuse these DMI states and sound-bank categories before adding another asset with the same purpose.

## Safety and provenance

The source downloads were inspected on 2026-08-05 before import. Archive paths were normalized and checked for traversal, encryption, executable content, suspicious compression ratios, and unexpected file types. The archives contain only WAV, PNG, and license/readme text files. Microsoft Defender platform `4.18.26070.9-0` reported no threats for every supplied archive and standalone PNG.

| Source download | SHA-256 |
| --- | --- |
| `Helton Yan's Old-School Shonen SFX.zip` | `4C3D795D374204C572BBAC2EB93C8013A14A7F9811A7A366559C6ABD0B1662B8` |
| `PixelSimulations.zip` | `0EDB63452B2A1B963005AD381B83E1A4C00BBAFC45BE6CCA23C1353B18B45D7A` |
| `smoke_shok_wave.rar` | `73C3218FB6E9D0CC77D0F17159933893F24E629E70729424E8278FF72BA55BDE` |
| `Foozle_2DE0001_Pixel_Magic_Effects.zip` | `0C04AB8EE856988B55885A92305D5382459CC855B2A6361C417BB11606F41E9A` |

Antivirus and structural checks reduce risk but do not constitute a mathematical guarantee. Only the converted game assets are stored in the repository; the original archives are not committed.

## Visual effects

All approved visual resources live in `src/Icons/Effects/OpenCombat`. They are real BYOND DMI files with explicit state, frame, delay, and cell-size metadata.

| DMI | Cell | States |
| --- | ---: | --- |
| `AimExplosions32.dmi` | 32x32 | `blast_orange`, `blast_blue`, `explosion_orange`, `explosion_blue` |
| `AimExplosions64.dmi` | 64x64 | `foam_burst`, `explosion`, `realistic_orange`, `realistic_green`, `realistic_red` |
| `FoozleMagic64.dmi` | 64x64 | `earth_spike`, `explosion`, `fire_ball`, `molten_spear`, `portal`, `rocks`, `tornado`, `water`, `water_geyser`, `wind` |
| `PixelSimulations16.dmi` | 16x16 | `explosion5`, `flame2`, `flame2_loop`, `flame3`, `flame3_loop` |
| `PixelSimulations64.dmi` | 64x64 | `explosion1` through `explosion6`, `flame1`, `flame1_loop`, `flame3`, `flame3_loop`, `gas_explosion`, `gas_leak`, `gas_leak_loop` |
| `SmokeShockwaves128.dmi` | 128x128 | `big`, `middle`, `small` |

The original Foozle and Aim sequences are preserved frame-for-frame. Pixel Simulations sequences longer than 32 frames are sampled uniformly to at most 32 frames while the DMI delay is scaled to preserve total animation time. Only the 106-pixel shockwave source is imported; its three sequences are sampled uniformly to 24 frames and centered, without interpolation, in 128x128 cells. This avoids shipping redundant 284/426/852-pixel copies and keeps the result suitable for BYOND transforms.

`getNexusOpenCombatIcon(library_name)` returns a registered DMI resource. Valid library names are `aim_32`, `aim_64`, `foozle_magic_64`, `pixel_simulations_16`, `pixel_simulations_64`, and `smoke_shockwaves_128`.

## Sound effects

The complete 720-effect library lives in `src/Sound/SoundEffects/Combat/Shonen`. Each of the 120 source WAV files contained six consecutive variations. Importing separated those variations at their equal authored boundaries, retained a short decay margin, removed only edge silence below the import threshold, resampled from 96 kHz to 48 kHz with high-quality band-limited resampling, and encoded stereo Ogg Vorbis. The result is 21.74 MiB instead of 976 MiB of WAV data.

| `getNexusShonenSound()` key | Files |
| --- | ---: |
| `ability_charge` | 114 |
| `ability_ready` | 48 |
| `ability_release` | 90 |
| `dodge` | 54 |
| `electric` | 24 |
| `explosions` | 66 |
| `falling` | 36 |
| `flight` | 30 |
| `jump` | 30 |
| `land` | 66 |
| `melee` | 66 |
| `melee_gore` | 36 |
| `swings` | 30 |
| `throws` | 30 |

The helper returns one random compiled resource from the requested category. Keep category selection semantic: impact sounds belong to `melee` or `melee_gore`, movement whooshes to `swings`, `dodge`, or `flight`, ki preparation to `ability_charge`/`ability_ready`, and released attacks to `ability_release` or `explosions`.

## Current gameplay mappings

- Beam raw-damage impacts: randomized `pixel_simulations_64` states `explosion1` through `explosion5`, with `explosions` audio.
- Super Explosive Wave and Earthquake: `smoke_shockwaves_128` states `big` and `middle`; intercepted hostile blasts use `aim_32` state `blast_blue`.
- Headbutt, Axe Kick, March of Fury, Consecutive Normal Punches, Guard Break, Wing Clip and Blue Comet Special: explicit `aim_32` orange/blue impact states with semantic Shonen cast and impact categories.
- Arcane spells: `foozle_magic_64` for menu icons, casting actors and projectile impacts. Do not substitute unrelated item sprites for these spell icons.

## Licenses

- Helton Yan's *FREE Retro Anime Sound Effects* is CC BY 4.0. Nexus Exodus credits Helton Yan and records the splitting, trimming, resampling, and format conversion above as modifications. Attribution must remain when the game or these derived OGG files are redistributed.
- Limofeus's *Pixel Simulations*, Foozle's *Pixel Magic Effects*, and Aim studios' *Explosions - Pixel Art* are CC0.
- morningkingdom's *Shock Wave / Smoke* is marked CC0 on the download page, which also asks that the work not be used for AI training. Nexus Exodus honors that additional request: the asset is approved only for ordinary game/VFX use and redistribution with this notice.

Source links and the public-facing credit lines are retained in `docs/AssetCredits.md`.
