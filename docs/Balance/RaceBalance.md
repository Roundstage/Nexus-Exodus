# Race Balance

`SkillDamageBalance.xlsx` contains a creation diagnostic in `Race Balance` and the authoritative staged comparison in `Progression Balance`. The staged sheet includes creation, mature growth, best sustainable racial form, common endgame/God state, 180-second burst, external progression, stat limits, maximum powerup modifiers, and racial abilities.

## Balance Policy

| Tier | Target index | Allowed band |
|---|---:|---:|
| Standard | 100 | 90-110 |
| Exceptional | 125 | 112.5-137.5 |

- Human is the index baseline at 100.
- Base, untransformed Saiyan must remain within 5% of Human.
- Standard lineages may trade BP for stats, but must remain inside the same overall band.
- Only Majin, Bio-Android, Legendary Saiyan, Cooler, and Android belong to the Exceptional tier.
- The highest and lowest Exceptional indices should remain within 10% of each other at the same progression stage.
- Random mutations remain excluded. Transformations, Third Eye, Saiyan Power, Mystic, Fire Fist, Majin, Limit Breaker, God Ki, cyber BP, absorption, and fusion are assigned to explicit progression stages instead of being hidden in the creation row.

## Tier Assignment

| Race or variant | Tier |
|---|---|
| Human | Standard |
| Spirit Doll | Standard |
| Saiyan, Low Class, Elite | Standard |
| Half Saiyan | Standard |
| Alien Scholar, Predator, Shifter, Apex Genome | Standard |
| Demigod | Standard |
| Demon | Standard |
| Frost Lord | Standard |
| Kai | Standard |
| Makyo | Standard |
| Namekian | Standard |
| Tsujin | Standard |
| Majin | Exceptional |
| Bio-Android | Exceptional |
| Legendary Saiyan | Exceptional |
| Cooler | Exceptional |
| Android | Exceptional |

## Index

The workbook gives every profile a neutral round-robin allocation using the same eight-stat order as character creation. It then compares both physical and Ki matchups against Human with the live damage curve:

```text
DamageFactor = (BP ratio)^1.00 * (2 * source / (source + guard))^0.85
```

The final screening index combines:

- physical output from Strength against Human Endurance;
- Ki output from Force against Human Resistance;
- physical and Ki damage received from Human;
- the passive incoming-damage multiplier;
- low-weight Speed, Offense, Defense, and Regeneration terms.

The index is a screening tool, not a replacement for matchup tests. A race that passes the base index can still fail because of a transformation, uncapped resource, execution, or utility package.

## Implemented Corrections

- Alien Apex Genome/Jiren was moved back to Standard: BP multiplier `1.8 -> 0.95`, incoming damage `0.6 -> 1`, powerup limit `0.3 -> 0.75`, knockback multiplier `0.5 -> 0.8`, and stun resistance `2.5 -> 1.25`.
- Base Saiyan combat BP uses `0.77x`, placing all three untransformed profiles within 1% of Human in the screening index.
- Half Saiyan, Demigod, standard Frost Lord, and Makyo use bounded combat-BP multipliers to bring their strong creation packages into the Standard band.
- Creation rows are diagnostic only. The authoritative comparison now uses equal relative progression and separates sustainable forms from God Ki, cyber BP, absorption, fusion, and burst buffs.
- Sustainable Exceptional BP coefficients converge near `33R`: Legendary Saiyan uses `1.65` racial BP, Bio-Android remains `1.1` before Perfect Form, Cooler uses `0.76` before its fifth-form additions, and Majin uses `1.13` with the Majin buff. Android remains an external-progression row because its cyber cap depends on Knowledge, Intelligence, tools, and era state.
- Third Eye now applies the documented `1.2x` BP (`bp_mult +0.2`) rather than the previous undocumented `1.3x`; Human still moves from one of the weakest creation BP profiles to one of the strongest mature Standard profiles after ascension.
- Giant Form no longer leaves a permanent `+0.5 bp_mult` after reverting.
- Demon soul BP growth is capped at three effective souls, or `1.3x`.
- Human-only and Spirit Doll-only direct damage multipliers were removed from balanced skills; racial identity should use utility, cost, control, or progression instead.

## Progression Stages

| Stage | Scope |
|---|---|
| S0 | Character creation package. Diagnostic only. |
| S1 | Mature and untransformed at equal relative natural progression `R`. |
| S2 | Best sustainable native racial form and native sustainable buff. |
| S3 | Common endgame or God state, with God BP reported explicitly. |
| S4 | A 180-second burst window, including Limit Breaker and comparable temporary buffs. |
| S5 | Cyber BP, absorption, fusion, equipment, tools, and other external progression. |

`R` is natural BP divided by the race's mature growth modifier. Human ascension, Saiyan's permanent post-SSJ growth, Third Eye, Saiyan Power, Frost forms available from spawn, maximum powerup penalties, and creation stat caps are therefore visible instead of being collapsed into an early-game score.

The remaining empirical pass is matchup data: form uptime, real Ki drain, hit rates at each Offense/Defense cap, Fire Fist burn uptime, Majin regeneration under pressure, Android module loadouts, absorption trajectories, and fusion availability.
