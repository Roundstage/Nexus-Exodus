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

## Viltrum map rebuild (2026-09-06)

The initial and revised Viltrum kits were generated with OpenAI's built-in image-generation tool for Nexus Exodus. The user-supplied cyan/teal planet image was used for palette and mood, not copied into production sprites. Generated originals and native Aseprite sheets are under `ArtSource/Viltrum`; current per-state source/destination mappings and hashes are in `ViltrumRevision.json`, with initial mappings in `ViltrumExport.json`.

Normalization crops equal cells, resizes to 32x32 with nearest-neighbor sampling and writes DMI metadata. The furnishing generator returned RGB checkerboards twice; `NormalizeViltrumCutouts.py` removes connected bright neutral background while preserving outlined ivory objects, then imports actual alpha cutouts into Aseprite. `ViltrumMaterialProof.png` shows the eight objects over three floors. Original and rejected sources remain; source art is never overwritten by --force.

No ClassicBlunder assets or layouts were imported in this phase. The user confirmed direct developer permission on 2026-09-06 for selective future reuse from https://github.com/Antenora/ClassicBlunder at commit f31a9dafed198530838d7762bf9c10ace2ed9187. This is project-specific authorization, not a public license. Future imports require original paths and SHA-256 in `docs/Maps/ClassicBlunderAssetImport.json`.

### Viltrum capital and landscape expansion (2026-09-06)

Original built-in OpenAI image_gen art: eight capital furnishings and sixteen
landscape/floor textures. Native sources:
`ArtSource/Viltrum/ViltrumCapitalObjects.aseprite` and
`ArtSource/Viltrum/ViltrumLandscape.aseprite`; production DMIs with corresponding
names under `src/Icons/Turfs/Viltrum`. Export manifests contain source SHA-256,
state mappings, frame dimensions and transparency. Original generated PNGs and
prompt/normalization notes are retained in `ArtSource/Viltrum/ExpansionBrief.md`.
No ClassicBlunder assets were imported for this expansion.

### Viltrum doors and Earth additions (2026-09-06)

ViltrumDoors.aseprite contains original built-in OpenAI image_gen artwork:
five styles, four poses each. ExportViltrumDoors.py packages twenty named states
and thirty animation frames in src/Icons/Turfs/Viltrum/ViltrumDoors.dmi.
ArtSource/Viltrum/ViltrumDoorExport.json records the source hash and pose mapping;
ExpansionBrief.md documents normalization and the prompt brief.

EarthCityAdditions.aseprite selects 28 states from existing Nexus Exodus assets,
including Celianna architecture, FloorsLAWL, Tiles1212011, domestic furniture and
lab equipment. This is repackaging of existing project art, not a claim of new
authorship or a new license. ArtSource/Earth/EarthCityExport.json records exact
original paths, hashes, states/cells and production mappings. Original assets are
unchanged; legacy binary DMI decoding used an isolated BYOND helper.

EarthStreetAdditions.aseprite contains four original built-in OpenAI image_gen
road/concrete materials; original PNG, source hashes and exports are retained in
ArtSource/Earth. EarthCity.dmi and EarthStreets.dmi are under src/Icons/Turfs/Earth.
See ArtSource/Earth/Provenance.md for prompts, conversion and export details.
No ClassicBlunder assets or layouts were imported in either world rebuild.

### Earth neighborhood and river correction (2026-09-06)

EarthNeighborhoodHouses, EarthNeighborhoodServices, EarthNeighborhoodProps and
EarthRiverMaterials are original artwork generated using OpenAI's built-in
image_gen for Nexus Exodus. Generated originals, exact prompts, alpha extraction
notes and native Aseprite sources are retained under ArtSource/Earth. Houses and
services normalize to 160x192 and 224x192; props use transparent 64x96 cells.

EarthNeighborhoodDetails is original native Aseprite pixel work for roads,
sidewalks, curbs, bridge parapets and small fixtures. EarthRiverTerrain combines
the generated material swatches into native edge/corner transition states.
EarthBuildingTiles losslessly repackages the house/service art into structural
32x32 crops; it adds no external artwork. Corresponding export manifests record
native hashes, state mappings and production paths under src/Icons/Turfs/Earth.

LimeZu, finalbossblues, RPG Maker, Waterfront Toronto, FHWA, Tiled and Red Blob
references informed visual/terrain planning only. No asset pack was purchased
or imported in this revision. Existing interior furniture retains the project
credits recorded above. See ArtSource/Earth/Provenance.md and
docs/Maps/RiverCityReferences.md for provenance and research details.

### Earth explorable natural terrain — 2026-09-06

EarthNaturalMaterialsOriginal.png is an original built-in image_gen material
atlas, retained with its prompt and native Aseprite source. EarthNaturalTiles
contains native modular terrain, natural ramps, a six-tile cave arch and
continuous dune shading. All 1,582 DMI states are fully opaque 32x32 terrain.
Dune transitions incorporate the existing Turf1.dmi `light desert` material;
its inherited project provenance is unchanged. No whole-landform concept sprite
or external reference artwork is placed on the map. NPS and official RPG Maker
pages informed the landform design; sources are recorded in
docs/Maps/EarthNaturalLandmarksReferences.md.
