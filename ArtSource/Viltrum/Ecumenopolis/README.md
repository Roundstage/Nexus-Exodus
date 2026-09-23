# Viltrum city kit

Six original built-in image_gen building sprites, generated on 2026-09-14.
Generated/ retains the source images. Generation.json records prompts.
ScienceOpaqueOriginal.png is a rejected RGB background output; Science.png is
the image_gen alpha correction. No reference-pack artwork was downloaded.

The editable *.aseprite files are the authoritative runtime art sources.
ExportViltrumEcumenopolis.py exports them through headless Aseprite, attaches DMI
metadata, and losslessly cuts the structural 32px frames. It initializes missing
native files only with --initialize; existing native edits are never replaced.
Cropping alpha bounds and nearest-neighbor sampling establish the declared grid.

House anchors are southwest, pixel offsets zero, layer 5. Houses are 160×192;
Hospital/Science/Transit are 224×192; Civic is 256×320. The matching structural
tiles are southwest-up indexed state_x_y; shared pavement underlays fill the
transparent silhouette corners. Turfs provide full-footprint collision/opacity.
Buildings have no per-instance animation, lights or background processing loops.

Streets.aseprite extends the established native street-kit workflow with
CreateViltrumCityStreets.lua. Ground frames cover all 32×32 pixels; only threshold
and exit frames have transparent backgrounds. Established transparent Viltrum
planters/benches and the existing Earth tree are reused as separate static props.

Export.json records native hashes and runtime paths; Audit.json verifies every
pixel of every structural crop, dimensions, alpha and source hashes. The full
map contract and reproduction commands are in docs/Maps/ViltrumEcumenopolis.md.
