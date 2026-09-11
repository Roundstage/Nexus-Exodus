# Build catalog and vitals rendering investigation

Date: 2026-09-11. Scope: the native build catalog, main vitals labels/values, power percentage and active-buff strip. Interactive Dream Seeker/Dream Maker verification is reserved for the user.

## Finding and correction

The screenshots demonstrate a rendering failure, not merely an unattractive arrangement: a wide title wraps into two clipped lines, short category names disappear or truncate, and the energy amount overlaps its percentage. Earlier changes to HTML tags, line heights and rectangle dimensions did not establish that the client would actually draw the text. Compilation and string/geometry assertions were insufficient evidence of visual correctness.

The affected controls now render cached glyph icons using the project's existing Silkscreen font. The server measures the exact glyph advances and visible ink bounds, chooses among three native font sizes and constructs a single-line raster. Long descriptive labels receive explicit ellipsis. Status lines are separate objects. Energy has a measured label column and a separate value column. No client HTML/CSS text layout participates in these particular controls.

This eliminates the unverified text-layout dependency. It does **not** establish which client font, CSS parser behavior, map scaling setting or interaction between them produced the original screenshots. That precise client-side cause remains unconfirmed because no interactive client reproduction was performed.

## Research and evidence

### BYOND's rendering contract

`maptext` uses a limited HTML/CSS renderer inside explicit width/height bounds. A CSS declaration being present in a string does not establish that the resulting glyphs fit those bounds. The reference also documents `client.MeasureText()`, which measures rendered text for a particular client, and `client.RenderIcon()`, which can render appearances including maptext. These would be appropriate ways to validate a maptext-based implementation with an actual client. A server-side rectangle assertion is not equivalent. [BYOND maptext reference](https://www.byond.com/docs/ref/info.html#/atom/var/maptext), [MeasureText](https://www.byond.com/docs/ref/info.html#/client/proc/MeasureText), [RenderIcon](https://www.byond.com/docs/ref/info.html#/client/proc/RenderIcon).

BYOND 516 release notes document relevant historical failures: 516.1670 fixed previously ineffective `white-space`; 516.1672 fixed a font-family parsing regression affecting maptext styles; 516.1673 corrected excessive line clipping during vertical overflow. Nexus pins 516.1686, which follows those fixes. Therefore these notes explain why browser-style assumptions need verification, but **do not prove** that any of those fixed bugs caused this incident. [Official 516 release notes](https://www.byond.com/docs/notes/516.html).

### Fourth Fate's implementation

The examined revision is `ca513d9b428f0a53f4c46cb94b699f49a2fc5b67`. Its builder uses persistent native HUD objects, dedicated pixel-font choices (`monogram` at 12pt and `Pixel Operator 8` at 6pt), explicit text rectangles and a sprite palette. The title and dropdown receive independently chosen dimensions and offsets; the palette uses five columns with a 40px step around native sprites. Its inventory HUD follows the same font-oriented approach. The useful lesson is deliberate typography and geometry within reusable controls, rather than repeatedly rebuilding a browser document. [Fourth Fate build HUD](https://github.com/Antenora/ClassicBlunder/blob/ca513d9b428f0a53f4c46cb94b699f49a2fc5b67/_Reworks/Building/build_hud.dm), [inventory HUD](https://github.com/Antenora/ClassicBlunder/blob/ca513d9b428f0a53f4c46cb94b699f49a2fc5b67/_1CodeFolder/InventoryHUD.dm).

Fourth Fate still uses maptext; it does not use the new Nexus bitmap renderer. The Nexus implementation adopts explicit sizing and reuse while retaining Nexus assets, permissions and brush behavior. No Fourth Fate art or font files were copied into this change.

### Other native HUD references

TGstation centralizes its maptext styles, uses defined pixel-font sizes and exposes measurement helpers. This supports treating native text as a distinct rendering contract rather than assuming browser CSS behavior. The BYOND pixel-font resource discussion also describes why nominal font size, glyph dimensions and ascent/descent do not necessarily coincide. [TGstation text definitions](https://github.com/tgstation/tgstation/blob/master/code/__DEFINES/text.dm), [BYOND pixel-font resource](https://www.byond.com/forum/post/1935723).

The glyph generator uses separate advance and ink measurements: advance determines the next glyph's horizontal position, while the ink bounding box determines visible extent. This distinction is part of Pillow's documented font API. Per-character bounds prevent a normal ASCII title from inheriting the tallest unused accented glyph's line height. [Pillow ImageFont documentation](https://pillow.readthedocs.io/en/stable/reference/ImageFont.html).

## Options assessed

| Approach | Benefit | Remaining problem / decision |
| --- | --- | --- |
| Further CSS/line-height adjustments | Small change | Repeats an unverified rendering path after several failed attempts. Rejected as the primary fix. |
| Dedicated maptext fonts plus client measurement | Conventional native HUD technique, like Fourth Fate | Requires client-dependent measurement and client verification to establish this fix. Viable for future rich text, but not selected for these constrained labels. |
| Embedded browser panel | Mature text layout | Would replace the native palette and require extra work around focus, pointer routing and redraw behavior. Not needed to correct these labels. |
| Cached glyph icons | Exact server-side pixels and dimensions; no font installation or HTML parser dependency | Selected for the limited build/vitals/buff text scope. Requires generated font assets, cache management and an explicit supported character set. |

## Implemented behavior

- `tools/BuildHudFont.py` derives 573 single-frame glyphs from `src/Fonts/SilkscreenRegular.ttf`: ASCII and Latin-1 at 8, 12 and 16px. Alpha is binary, so glyph edges remain solid. The atlas and metrics are checked into the project; Python/Pillow are development dependencies only. The existing OFL license remains alongside the source font. [Silkscreen project and license background](https://github.com/googlefonts/silkscreen).
- `HudBitmapText.dm` measures and composes glyphs at integer coordinates with a one-pixel dark shadow. Labels are literal text, so `<...>` does not become markup. Newlines/tabs are normalized; unsupported characters use `?`. This character-set limitation applies to these HUD labels, not chat or general game text.
- Unchanged label updates retain their icon. Glyphs are shared, and changing word/value images use a bounded 512-entry cache. This avoids recreating text during repeated status refreshes and prevents an unlimited history of energy values accumulating in memory.
- The normal build panel remains 220x448 logical pixels, with an opaque background and 25 native 32px thumbnails. Nine categories now occupy three sufficiently wide rows. The title, search, toggles, brush actions, grid, pagination, selection details and footer occupy separate rectangles. Smaller viewports reduce grid rows before scaling the panel.
- Vitals below 100% use `WP`, `HP`, `KI`, `STA`; larger layouts retain full names. The numeric column begins after the measured label plus a gap. Energy preserves `(amount) percent%`; only an amount too wide even at 8px is abbreviated with K/M/B/T. If a fractional suffix is still too wide, its decimal precision is reduced. The numeric game state and percentage calculation are unchanged.
- Buff rows and the power percentage use the same renderer. Deactivating the last buff clears both its glyph icons and its background. The whole composed HUD is not transformed to resize text; glyph size is chosen explicitly.
- The new DM file is included in `DU.dme`. The protected map include order remains intact.

## Verification and review artifacts

The new checks examine actual icon pixels, not only HTML strings. Runtime assertions require a nontransparent glyph raster with width/height matching its box; standard labels must retain their full text; long descriptions must use visible ellipsis. They also check unchanged-icon reuse and cache bounds.

The vitals fixture exercises 50%, 75%, 100%, 125% and 150%, plus returning to an earlier scale. It checks label/value separation, exact `(8000) 100%` output, fractional percentages, zero/large energy values, buff visibility and overflow. The build fixture checks multiple viewport sizes down to 210x260, opaque coverage, no overlapping controls, hidden-slot input exclusion, native thumbnails and reused controls. Existing construction fixtures exercise placement at the cursor, dragging, costs, cancellation and protected terrain policies.

The smoke run exports the build palette and five vitals strips from the **actual runtime icon objects**. These are deterministic composition previews, not Dream Seeker screenshots. Animated thumbnails are reduced to one frame in the build review export only; the game can still animate them. Review copies live in `artifacts/BuildHud/`.

| Check | Result |
| --- | --- |
| `python tools/BuildHudFont.py --check` | Passed: 573 glyphs, matching atlas/metrics and visible sample text. |
| `node tools/MapAssembly/TestRuntimeMapOrder.cjs` | Passed: protected order, editor-save regression and Z1–22 spans. |
| `tools/Test-AssetReferences.ps1 -Strict` | Passed: 3,725 active references across 403 files; zero issues. |
| `tools/Test-NamingConventions.ps1` | Non-strict audit completed: zero path/file issues; 6,177 existing-style identifier findings across the working tree. Identifier migration remains outside this fix. |
| `tools/Invoke-ByondSmoke.ps1 -KeepTemp` | Passed with BYOND 516.1686: zero compiler errors/warnings, versioned and clean startup assertions passed, and no runtime errors during the observation periods. Includes the fractional/large-energy regression cases. |
| Interactive Dream Seeker / Dream Maker | Not performed, per the user's instruction. |

The user's in-game review should confirm text visibility at their display/map scaling, panel dragging and resizing, category/search/selection changes, cursor painting and live energy/buff updates. Passing headless tests establishes the generated pixels and server behavior; it does not justify claiming that those client behaviors have already been observed.

Final smoke run: `Nexus-Exodus-smoke-c721934cb29440728a2be8d59158a0ba` in the local temporary directory. The checked-in previews were copied from this passing run. Build preview SHA-256: `00e3e2a37e9127c835bb6ed8d45bf25d4e691695b5cab155d7cc1c8be71e2a19`.
