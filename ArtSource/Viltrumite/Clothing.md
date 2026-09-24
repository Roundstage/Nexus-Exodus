# Viltrumite clothing

Two additional transparent equipment DMIs are offered in the clothing catalog and in Viltrumite/Half-Viltrumite character creation:

- **Viltrumite Skirt Uniform**: a white/silver tunic with a continuous short pleated skirt, fitted to the supplied Female base. It is a separate outer layer to wear over the existing regular jumpsuit (Soldier Robe). The skirt ends above the knees. Its normal equipment priority is 600, above the default clothing priority of 500.
- **Viltrumite Bulk Jumpsuit**: a white/silver full-body suit fitted directly to every Bulk body frame. The wider belly, arms and legs retain the exact original silhouette; the face remains transparent. Collar, waist seam and boots use the existing uniform's charcoal palette.

The creator treats each item's declared appearance priority as a minimum, then uses selection order for ordinary layers. Its browser preview applies the same ordering. This keeps the skirt above the jumpsuit even when submitted first. Players can still adjust equipped layers with the existing appearance controls. `node tools/TestViltrumiteClothing.cjs` exercises the browser ordering; the Viltrumite startup smoke checks the equipped items with reversed selection order.

## Sources and generation

Run `node tools/BuildViltrumiteClothing.cjs` with `sharp` available. The script uses native pixels and preserves the complete target body's DMI Description, including movement flags, directions, delays, hotspots and duplicate idle/walking states. No whole-sheet resizing or image generation is used.

- `Originals/Bulk.dmi`: supplied Bulk body. The generated jumpsuit has 45 direction/frame tiles across nine states.
- `Originals/Female.dmi`: supplied Female body. The skirt uniform follows all 78 direction/frame tiles across nine states, including its four-frame idle animation.
- `Originals/RoyalRobe.dmi`: unmodified snapshot of the existing `ViltrumiteRoyalRobe.dmi`. The new uniform changes its red torso to the existing white/silver palette and shortens/joins the pleated panels. Source and target frames are matched by state name, movement flag, direction and animation frame, never by atlas tile number.

The generator re-reads each output, verifies exact frame pixel roundtrips and unchanged metadata, rejects empty clothing frames, and checks every Bulk clothing pixel against the corresponding body silhouette. `artifacts/ViltrumiteClothing/` contains the manifest, a contact sheet in all three skin tones, and full animation atlases. In-game visual/interactive review remains with the user.
