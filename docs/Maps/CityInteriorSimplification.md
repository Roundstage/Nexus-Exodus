# Empty city interiors — 2026-09-08

All 66 accessible Earth and Viltrum building interiors are intentionally empty.
Each room retains exactly one return portal beside its arrival point; furniture,
consoles, decorative objects and the redundant far-side exit were removed. The
separate sandstone cave is not a building and remains unchanged.

`ClearCityInteriorObjects.cjs` performs this normalization from the building
registry. `CityBuildingChecks.cjs` checks all 66 exterior/interior coordinate
pairs and rejects any future object inside a registered building room other than
its single return portal. Existing runtime validation still rejects a destination
whose planet area or Z-level does not match, so a mapped route cannot resolve to
space.
