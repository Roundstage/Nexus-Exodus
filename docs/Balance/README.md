# Skill Damage Balance

`SkillDamageBalance.xlsx` models the current combat formulas and skill parameters.

## Contents

- Standard melee, special melee, rock, Ki projectile, beam, AoE, and execution skills.
- Editable attacker and defender scenarios.
- The major `get_bp()` stages, including powerup, anger, cyber BP, and Overdrive.
- Race profiles, modules, transformations, incoming damage modifiers, costs, cooldowns, and source references.
- Formula-backed damage comparison and equal-stat validation sheets.

## Regeneration

Run `./tools/New-SkillDamageBalanceWorkbook.ps1` from PowerShell. The generator does not require Excel, Python, or third-party modules.

The workbook requests a full formula recalculation when opened. Yellow cells are inputs and green cells are calculated values.
