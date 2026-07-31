# Skill Damage Balance

The two workbooks have different roles:

- `exemplo_raças.xlsx` is the historical design reference for racial identity, stat emphasis, buffs, and the broader set of legacy race concepts. Tabs for races that are not returned by `Race_List()` are reference-only.
- `SkillDamageBalance.xlsx` is the authoritative numeric model for the races and skills compiled by the current project. When the workbooks disagree on a live combat value, use this workbook and its `Race Balance`, `Progression Balance`, `Skill Catalog`, and `Validation` sheets.

## Contents

- Standard melee, special melee, rock, Ki projectile, beam, AoE, and execution skills.
- Editable attacker and defender scenarios.
- The major `get_bp()` stages, including powerup, anger, cyber BP, and Overdrive.
- Race profiles, modules, transformations, incoming damage modifiers, costs, cooldowns, and source references.
- Formula-backed damage comparison and equal-stat validation sheets.

## Regeneration

Run `./tools/New-SkillDamageBalanceWorkbook.ps1` from PowerShell. The generator does not require Excel, Python, or third-party modules.

The workbook requests a full formula recalculation when opened. Yellow cells are inputs and green cells are calculated values.

## Runtime verification

`src/Code/Tests/StartupSmoke.dm` asserts the live creation budgets, effective racial BP and incoming-damage packages, central skill factors, beam factors, charged-skill ranges, and equal-stat damage curve. Run `./tools/Invoke-ByondSmoke.ps1` after changing either the model or the combat implementation.
