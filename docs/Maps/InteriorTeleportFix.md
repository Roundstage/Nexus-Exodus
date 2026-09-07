# Super Earth interior teleport fix — 2026-09-07

Dream Maker registered all five maps alphabetically inside DU.dme's generated
include block, ahead of the old protected list at the bottom. BYOND used those
first occurrences: CityInteriors loaded first and Viltrum occupied Z22. Earth
door coordinates still targeted Z22, sending players onto Viltrum terrain.

The canonical map list now appears before the generated include block. Keep the
reserved BEGIN_INCLUDE marker out of explanatory comments: an earlier comment
containing it caused another editor save to erase the preamble. The regression
check now rejects that misleading marker too.
The resulting map ranges are Map2018 Z1-15, Space2018 Z16-19,
Viltrum Z20, SuperEarth Z21 and CityInteriors Z22. The editor's existing duplicate
registrations remain harmless because those files are already included.

Building and cave doors now validate destination area and region before moving
a player. An entrance must reach its planet's CityInterior at Z22; an exit must
return to the matching surface. Incorrect destinations fail without teleporting.
No map geometry, interior coordinates or spawn placements were changed.

Regression coverage exercises all 29 Earth building doors against a deliberately
incorrect Viltrum landing, restores their real destinations and crosses entry
and exit thresholds. Cave round trips and planet context remain covered. The
map-order check models editor re-registration; the compiler output is also
checked for the exact runtime map sequence. A running server needs to reload
the corrected compiled world before these changes take effect.

Validation: BYOND 516.1686 compiled with zero errors/warnings; both versioned
and clean startup tests passed. The repository's DU.dmb was also rebuilt with
the corrected map order. All 66 retained building interiors still pass their
connectivity, furniture and exact-return checks.
