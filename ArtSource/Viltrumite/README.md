# Viltrumite skin variants

The character creator offers Male, Female, and Bulk bodies in White, Tan, and Black, all with blue irises, for Viltrumite and Half-Viltrumite.

## Originals

- `Originals/Female.dmi`: user-supplied `Femalebase.dmi`, received 2026-09-23.
- `Originals/Bulk.dmi`: user-supplied `ViltrumBulk.dmi`, received 2026-09-23.
- `Originals/Male.dmi`: user-supplied `Humanbase.dmi`, received 2026-09-23. Despite its source filename, this is the dedicated non-Bulk male Viltrumite base. It replaces the previous generic human male artwork in all three male variants.
- `Archive/MaleGeneric.dmi`: the superseded source, copied from `src/Icons/PlayerIcons/BaseIcons/NewHumanIconsFromGuppinas/BaseHumanPale.dmi`, retained only for provenance.

Originals remain byte-identical to their sources. No image generation is used.

## Rebuild

Run `node tools/RecolorViltrumiteSkins.cjs`. Add `--preview` with `sharp` available to generate the contact sheet. Output DMIs live in `src/Icons/PlayerIcons/BaseIcons/Viltrumite/`; the preview and validation manifest live in `artifacts/ViltrumiteSkins/`.

The script edits only the PNG `PLTE` chunk and its checksum. Compressed pixel indices, transparency, dimensions and every DMI metadata byte remain unchanged, including duplicate idle/walking state names, movement flags, original frame delays and hotspots. Each result is re-read and checked against its source. Female has 78 direction/frame tiles, Bulk 45, and Male 66; padding tiles remain untouched. Previews locate the stationary idle state in each source instead of assuming atlas tile order.

Tan is a modest warm darkening of White; Dark uses a deeper brown ramp with distinct shading levels. The Dark variant keeps the existing `Black` filename and catalog identifier for compatibility. All original skin shades retain separate palette steps, including the supplied Male base's two deepest skin shadows. Blue eyes use `#0000cc` and `#0099ff`, matching the supplied Bulk sprite's existing blue eye entries. Male's two brown iris shades are converted to these blues; its black brows and closed eyelids remain black. Original clothing, white/gray sclera and transparent palette entries are unchanged.

Existing saved characters are not migrated or recolored. These assets are offered for new creation; custom imports remain available. Interactive BYOND review remains with the user.
