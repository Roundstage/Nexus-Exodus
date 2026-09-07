# Earth runtime shoreline fix — 2026-09-07

The old zone decorator was replacing shoreline water with Wall7 as players
entered a region. It also replaced the next southern tile with water, damaging
roads, riverbanks and other authored terrain. The source is GenerateCliffs in
src/Code/MapCode/AutoEdge.dm, called by QuadrantGenerator.dm at runtime.

SuperEarth now disables automatic cliffs through its area policy. The check
covers every turf type, including legacy ground placed manually in Dream Maker.
Both potential replacement destinations are checked before writing, preventing
an adjacent unprotected area from modifying a protected bank. Existing maps
retain their configured cliff generation.

Follow-up: GenerateEdges and GenerateShoreWaves were also active in those same
runtime zone passes. They painted legacy edge and surf overlays over authored
riverbank art even after destructive cliffs were disabled. SuperEarth now also
sets auto_edges and auto_waves to FALSE at area level. The procs themselves
enforce this policy, including direct calls and wave metadata across an area
boundary. Existing overlays and authored water animations are preserved;
ambient-occlusion shadows and other maps' decoration remain enabled.

The regression test runs actual BYOND decoration across all 16 Earth zones and
compares all 250,000 terrain cells before and after. It also covers direct calls,
edge/wave overlays and metadata, cross-area boundaries and legacy behavior.
No map was regenerated or edited;
the user's current SuperEarth.dmm remains SHA256
9f2197326e3a4445bbe71c635830b0c27a953b29df67bf79831016d26c6aafcc.

Validation: BYOND 516.1686 compiled with zero errors and warnings; both versioned
and clean startup smoke runs passed. The runtime regression preserved all
250,000 cells across 16 zones and directly exercised 990 shorelines. Building
entry/return, rivers and natural climbing routes passed after decoration.
The environment-order regression and naming path audit also passed; the latter
still reports the repository's existing legacy identifier warnings.

Restart the running world using the rebuilt DU.dmb to load the corrected code
and authored terrain. Automatically generated cliffs have no Builder and are
excluded from the normal player-construction save.
