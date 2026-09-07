# SSJ1 awakening — Aseprite

## Active choreography

The unmastered SSJ1 opening lasts **22 seconds**. Mastery progressively shortens it to a quiet **0.6-second** transition. Custom `ssj_opening` selections retain their existing behavior.

- 0–3 seconds: gradual dimming, aura growth and initial lift.
- 3–18.5 seconds: original/gold hair crossfades and additive hair glow; increasingly frequent falling lightning; expanding ground shockwaves with distortion.
- 18.5–20.5 seconds: golden hair locks in, strongest aura and final shockwaves.
- 20.5–22 seconds: aura, hair glow and levitation settle.

Twelve expanding elliptical shockwaves are scheduled at zero mastery; their density and intensity fall with mastery, and mastered openings have none. Charge, electric and impact sounds use existing Aura3, Electric01V1 and Kiplosion assets on three isolated per-observer channels. Departure and cleanup release the channels and temporary lighting/filter state. No damage is applied by these VFX.

Aura and hair visuals attach to the actor through vis_contents. The aura is positioned using the visible body bounds, and its scale preserves the foot anchor, including during levitation. Existing saved/custom aura choices remain supported; new default aura items use GoldenAura.dmi.

## Sources and outputs

- CreateGoldenAura.lua → GoldenAura.aseprite / GoldenAuraSheet.png: 24 transparent 96×128 flame frames, 50 ms per frame, 1.2-second loop. Bottom-left foot anchor: (48,12).
- ExportGoldenAuraDmi.cjs → src/Icons/Ki/GoldenAura.dmi, preserving pixels.
- CreateFallingLightning.lua → FallingLightning.aseprite / FallingLightningSheet.png: four 32×192 strikes, six frames each; height is revealed downward over the first frames.
- ExportFallingLightningDmi.cjs → src/Icons/Ki/Electricity/FallingLightning.dmi.
- BuildAwakening.lua runs the Aseprite generation scripts.
- Previous short lightning sprites remain available as TransformationLightning.aseprite / TransformationLightning.dmi.

Pixel Composer files and GoldenAura.lua are abandoned drafts, not active build inputs.

## Preview and validation

AwakeningCharacterPreview.gif is a **silent Aseprite layout/timing preview**, using real BYOND-exported body and hair frames. Its lighting, strikes and shockwaves approximate the composition; it is not a live-client recording or a sound demonstration. PreviewAwakeningCharacter.lua converts indexed inputs to RGB and crops the first body frame before composition.

BYOND 516.1686 compile and clean/versioned startup smoke tests cover visible-body anchoring, at least 20 seconds duration, temporary attachments on interruption, overlapping dimmers and cleanup. Final audiovisual timing in a live client still requires a playtest. The strict asset audit retains the unrelated pre-existing logo BarePath in UIStuff.dm; all new asset references resolve.

## Mastery and daylight
SSJ1 visual mastery is clamped from ssjdrain=150 to max_ss_mastery=300; the Full Power unlock also selects mastered visuals. Duration falls smoothly from 22 seconds to 0.6 seconds. Mastered openings crossfade hair without darkening, levitation, lightning, shockwaves or charge sounds. Partial mastery reduces their intensity and density. Shockwaves use the expanding elliptical ring from the 22-second version.

A separate additive golden halo renders on the world overlay plane above ambient lighting, alongside the existing light emitter. It persists while SSJ1 is active, including daytime, and becomes smaller/subtler with mastery. Normal and saved SSJ1 aura sprites shrink to 45% and reduce opacity at full mastery. Reversion removes the halo. Aseprite previews from the prior iteration show only the unmastered choreography and do not demonstrate this daylight layer.

Latest lighting correction: the golden halo explicitly uses gradient state "1". Temporary dimming recomposes the client's existing ambient color without re-resolving an area fallback; peak dimming is 22%, not 72%. The elliptical expanding shockwave is restored. Tests inspect actual gradient pixels and verify day/night color composition. Live-client appearance still needs visual confirmation.

`GoldenGlow.aseprite` / `CreateGoldenGlow.lua` export `src/Icons/Ki/GoldenGlow.png`: a 256×256 warm radial glow with fully transparent borders. This replaces the black-backed lighting mask previously reused by the visible daylight halo, which produced a dark rectangle. The regular Nexus emitter is unchanged. Tests now inspect all four borders of the exported halo for transparency.

Current night-preservation approach: cinematic dimming uses a separate black screen layer on plane 14 beneath Nexus lighting. No SSJ sequence code calls ambient refresh/sync/set. The weather/night plane remains untouched throughout the opening and cleanup. The layer only reduces brightness, by at most 22%, and is released after the sequence. This supersedes the earlier ambient-recomposition approach.
