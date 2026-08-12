# Asset Credits

## Branding

- `src/Icons/UI/NexusExodusLogo.png` is an original Nexus Exodus wordmark generated with OpenAI's built-in image-generation tool on 2026-08-05, then chroma-keyed locally to transparent PNG. Its bronze, gunmetal, rivet, and cyan-energy construction is the canonical game logo and contains no third-party franchise mark.
- `src/Images/Slime64.png` now contains the original simplified Nexus Exodus application mark derived from that wordmark with OpenAI's built-in image-generation tool on 2026-08-05. It was chroma-keyed and reduced to a transparent 64x64 pixel-art icon. Only the legacy, already tracked filename remains for Dream Maker skin compatibility; all former third-party slime artwork was replaced.

## Character transformations

- `src/Icons/PlayerIcons/BaseIcons/Heran/HeranBojack.dmi` and `HeranBojackFemale.dmi` preserve the male/asexual and female `Bojack Expand` transformation sheets supplied by their original developer with authorization for continued use. Nexus Exodus keeps stable, space-free paths and uses them only for the integrated Heran Transformation.

## Lighting

- `src/Code/WorldMechanics/WeatherDayNight/NexusLightGradient.dmi` is derived from `Circular 1 - 256x256.png` in [300+ Gradient Textures](https://opengameart.org/content/gradient-texture-pack) by Screaming Brain Studios, released under CC0.
- Nexus Exodus normalizes the source luminance into additive RGB intensity, feathers the outer edge, and packages ten falloff profiles as BYOND DMI states `1` through `10`.

## Combat effects

- `src/Icons/Effects/AlienInfiniteVoid.dmi` is original pixel-art generated for Nexus Exodus with OpenAI's image-generation tool on 2026-08-05, then chroma-keyed, nearest-neighbor resized, and packaged as a transparent 512x512 BYOND DMI with the explicit `void` state. It depicts an abstract cosmic domain and intentionally contains no character likeness, logo, text, or recognizable anime symbol.
- `src/Icons/Effects/CC0/SwordSlash.dmi` packages the nine 64x47 frames from [Pixel art sword slash effect](https://opengameart.org/content/pixel-art-sword-slash-effect) by tbbk, released under CC0. The original pixels are unchanged; Nexus Exodus adds BYOND DMI metadata and applies per-technique color at runtime.
- `src/Sound/SoundEffects/Combat/Weapons/SwordSwing*.ogg` selects four sounds from [Swishes Sound Pack](https://opengameart.org/content/swishes-sound-pack) by artisticdude, released under CC0. The selected 24-bit WAV files were converted to mono Ogg Vorbis for BYOND playback and package size.
- `src/Sound/SoundEffects/Combat/Weapons/SwordImpact*.ogg` selects six sounds from [20 Sword Sound Effects](https://opengameart.org/content/20-sword-sound-effects-attacks-and-clashes) by StarNinjas, released under CC0.
- `src/Sound/SoundEffects/Combat/Earth/RockImpact*.ogg` and `RockBreak*.ogg` select stone impacts, falls, and fractures from [75 CC0 breaking / falling / hit SFX](https://opengameart.org/content/75-cc0-breaking-falling-hit-sfx) by rubberduck, released under CC0.
- `src/Sound/SoundEffects/Combat/Earth/RockRumble.ogg` comes from [Moving Boulder](https://opengameart.org/content/moving-boulder) by themightyglider, released under CC0. `RockLaunch*.ogg` uses two additional CC0 swishes from artisticdude's pack above.
- `src/Sound/SoundEffects/Combat/Shonen/**/*.ogg` is derived from [FREE Retro Anime Sound Effects](https://heltonyan.itch.io/retroanimesfx) by Helton Yan, licensed under CC BY 4.0. Nexus Exodus separated each six-variation source WAV, trimmed edge silence, resampled the audio from 96 kHz to 48 kHz, and converted it to Ogg Vorbis. Credit to Helton Yan and this modification notice must remain with redistributed copies.
- `src/Icons/Effects/OpenCombat/PixelSimulations16.dmi` and `PixelSimulations64.dmi` package [Pixel Simulations](https://limofeus.itch.io/pixel-simulations) by Limofeus, released under CC0. Long sequences are sampled uniformly and their DMI delays preserve the original total sequence timing.
- `src/Icons/Effects/OpenCombat/FoozleMagic64.dmi` packages [Pixel Magic Effects](https://foozlecc.itch.io/pixel-magic-sprite-effects), commissioned from lordfitoi and distributed by Foozle under CC0.
- `src/Icons/Effects/OpenCombat/AimExplosions32.dmi` and `AimExplosions64.dmi` package [Explosions - Pixel Art](https://aim-studios.itch.io/explosions-pixel-art) by Aim studios, released under CC0.
- `src/Icons/Effects/OpenCombat/SmokeShockwaves128.dmi` adapts the 106-pixel sequences from [Shock Wave / Smoke](https://morningkingdom.itch.io/shock-wave-smoke) by morningkingdom. The page marks the pack CC0 and separately prohibits AI training; Nexus Exodus retains that restriction for this asset. Frames are sampled uniformly and centered in 128x128 DMI cells without interpolation.
