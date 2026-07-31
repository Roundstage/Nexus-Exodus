[CmdletBinding()]
param(
	[string]$OutputPath = (Join-Path $PSScriptRoot "..\docs\Balance\SkillDamageBalance.xlsx")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Escape-Xml([object]$Value) {
	if ($null -eq $Value) { return "" }
	return [System.Security.SecurityElement]::Escape([string]$Value)
}

function Get-ColumnName([int]$Index) {
	$name = ""
	while ($Index -gt 0) {
		$Index--
		$name = [char](65 + ($Index % 26)) + $name
		$Index = [math]::Floor($Index / 26)
	}
	return $name
}

function New-Cell([object]$Value, [int]$Style = 0) {
	return [pscustomobject]@{ Value = $Value; Style = $Style; Formula = $null }
}

function New-FormulaCell([string]$Formula, [int]$Style = 4) {
	return [pscustomobject]@{ Value = 0; Style = $Style; Formula = $Formula }
}

function Add-Row([System.Collections.Generic.List[object]]$Rows, [object[]]$Cells) {
	$Rows.Add($Cells) | Out-Null
}

function New-Sheet([string]$Name, [double[]]$Widths, [int]$FreezeRows = 1) {
	return [pscustomobject]@{
		Name = $Name
		Widths = $Widths
		FreezeRows = $FreezeRows
		Rows = [System.Collections.Generic.List[object]]::new()
	}
}

function ConvertTo-WorksheetXml($Sheet) {
	$culture = [System.Globalization.CultureInfo]::InvariantCulture
	$builder = [System.Text.StringBuilder]::new()
	[void]$builder.Append('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
	[void]$builder.Append('<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">')
	if ($Sheet.FreezeRows -gt 0) {
		$topRow = $Sheet.FreezeRows + 1
		[void]$builder.Append("<sheetViews><sheetView workbookViewId=`"0`"><pane ySplit=`"$($Sheet.FreezeRows)`" topLeftCell=`"A$topRow`" activePane=`"bottomLeft`" state=`"frozen`"/></sheetView></sheetViews>")
	}
	[void]$builder.Append('<sheetFormatPr defaultRowHeight="15"/><cols>')
	for ($i = 0; $i -lt $Sheet.Widths.Count; $i++) {
		$column = $i + 1
		$width = $Sheet.Widths[$i].ToString("0.##", $culture)
		[void]$builder.Append("<col min=`"$column`" max=`"$column`" width=`"$width`" customWidth=`"1`"/>")
	}
	[void]$builder.Append('</cols><sheetData>')
	for ($rowIndex = 0; $rowIndex -lt $Sheet.Rows.Count; $rowIndex++) {
		$rowNumber = $rowIndex + 1
		[void]$builder.Append("<row r=`"$rowNumber`">")
		$cells = $Sheet.Rows[$rowIndex]
		for ($columnIndex = 0; $columnIndex -lt $cells.Count; $columnIndex++) {
			$cell = $cells[$columnIndex]
			if ($null -eq $cell) { continue }
			$reference = "$(Get-ColumnName ($columnIndex + 1))$rowNumber"
			$styleAttribute = if ($cell.Style -gt 0) { " s=`"$($cell.Style)`"" } else { "" }
			if ($cell.Formula) {
				$formula = Escape-Xml $cell.Formula
				[void]$builder.Append("<c r=`"$reference`"$styleAttribute><f>$formula</f><v>0</v></c>")
			} elseif ($cell.Value -is [int] -or $cell.Value -is [long] -or $cell.Value -is [double] -or $cell.Value -is [decimal]) {
				$value = ([convert]::ToDouble($cell.Value)).ToString("0.###############", $culture)
				[void]$builder.Append("<c r=`"$reference`"$styleAttribute><v>$value</v></c>")
			} else {
				$value = Escape-Xml $cell.Value
				[void]$builder.Append("<c r=`"$reference`" t=`"inlineStr`"$styleAttribute><is><t xml:space=`"preserve`">$value</t></is></c>")
			}
		}
		[void]$builder.Append('</row>')
	}
	[void]$builder.Append('</sheetData>')
	if ($Sheet.Rows.Count -gt 1 -and $Sheet.Widths.Count -gt 0) {
		$lastColumn = Get-ColumnName $Sheet.Widths.Count
		[void]$builder.Append("<autoFilter ref=`"A2:$lastColumn$($Sheet.Rows.Count)`"/>")
	}
	[void]$builder.Append('<pageMargins left="0.3" right="0.3" top="0.5" bottom="0.5" header="0.2" footer="0.2"/></worksheet>')
	return $builder.ToString()
}

function Add-ZipEntry([System.IO.Compression.ZipArchive]$Archive, [string]$Path, [string]$Content) {
	$entry = $Archive.CreateEntry($Path, [System.IO.Compression.CompressionLevel]::Optimal)
	$stream = $entry.Open()
	$writer = [System.IO.StreamWriter]::new($stream, [System.Text.UTF8Encoding]::new($false))
	try { $writer.Write($Content) } finally { $writer.Dispose(); $stream.Dispose() }
}

$sheets = [System.Collections.Generic.List[object]]::new()

$readme = New-Sheet "README" @(24, 110, 30) 2
Add-Row $readme.Rows @((New-Cell "Nexus Exodus Skill Damage Balance" 2), (New-Cell "Code-backed workbook generated from the current combat implementation." 2))
Add-Row $readme.Rows @((New-Cell "Section" 1), (New-Cell "Details" 1), (New-Cell "Primary source" 1))
Add-Row $readme.Rows @((New-Cell "Purpose" 6), (New-Cell "Compare current skill damage under repeatable attacker/defender scenarios. Yellow cells are scenario inputs; green cells are formulas." 5), (New-Cell "Repository combat code" 5))
Add-Row $readme.Rows @((New-Cell "Scope" 6), (New-Cell "Includes standard melee, special melee, rocks, projectiles, beams, custom AoE/execution skills, race profiles, modules, powerup, anger, cyber BP and transformations." 5), (New-Cell "Skill Catalog and Modifiers sheets" 5))
Add-Row $readme.Rows @((New-Cell "Damage basis" 6), (New-Cell "Factors are equal-stat percentages. Physical damage uses Strength/Endurance; Ki uses Force/Resistance; both use BP^0.5 and the bounded stat term (2*source/(source+guard))^0.85. Offense/Defense affect hit outcomes only." 5), (New-Cell "Combat/DamageScaling.dm" 5))
Add-Row $readme.Rows @((New-Cell "BP pipeline" 6), (New-Cell "The BP Pipeline sheet exposes the major ordering stages. The game has additional situational branches; use current Effective BP in Combatants when exact runtime BP is known." 5), (New-Cell "BackgroundCode/StatLoop.dm:95-242" 5))
Add-Row $readme.Rows @((New-Cell "Powerup and anger" 6), (New-Cell "Current mixture is additive: anger/100 + BPpcnt/100 - 1 + Super Kaioken addition. It is not anger multiplied by powerup." 5), (New-Cell "BackgroundCode/StatLoop.dm:25-49" 5))
Add-Row $readme.Rows @((New-Cell "Cyber BP" 6), (New-Cell "With current cyber_bp_cuts_natural_bp_by=0, any cyber BP replaces natural BP before cyber contribution is added. Overdrive multiplies cyber contribution by 1.5." 5), (New-Cell "BackgroundCode/StatLoop.dm:183-193" 5))
Add-Row $readme.Rows @((New-Cell "Ki speed" 6), (New-Cell "Non-beam Ki projectiles use a 0.5 decisecond cadence at 60 FPS. Beam and Spirit Bomb delays remain skill-specific." 5), (New-Cell "ProjectileSystem/Blasts.dm; SkillControllers.dm" 5))
Add-Row $readme.Rows @((New-Cell "Usage" 6), (New-Cell "1. Set Combatants inputs. 2. Adjust BP Pipeline and copy its result if needed. 3. Review standardized skills in Damage Calculator. 4. Use Skill Catalog for custom formulas and timing." 5), (New-Cell "This workbook" 5))
$sheets.Add($readme) | Out-Null

$settings = New-Sheet "Settings" @(32, 18, 22, 72) 2
Add-Row $settings.Rows @((New-Cell "Combat Constants" 2), (New-Cell "Value" 2), (New-Cell "Unit" 2), (New-Cell "Source" 2))
Add-Row $settings.Rows @((New-Cell "Constant" 1), (New-Cell "Code default" 1), (New-Cell "Meaning" 1), (New-Cell "Source" 1))
$settingRows = @(
	@("Base melee damage", 2.5, "damage", "GlobalCombatSettings.dm"),
	@("Melee power", 1, "multiplier", "GlobalCombatSettings.dm"),
	@("Ki power", 1, "multiplier", "GlobalCombatSettings.dm"),
	@("BP exponent", 0.5, "ratio exponent", "GlobalCombatSettings.dm:52"),
	@("Combat stat exponent", 0.85, "bounded ratio exponent", "Combat/DamageScaling.dm"),
	@("Legacy Strength exponent", 0.45, "unused by balanced damage", "GlobalCombatSettings.dm"),
	@("Legacy Force exponent", 0.7, "unused by balanced damage", "GlobalCombatSettings.dm"),
	@("Legacy inferior Force exponent", 0.45, "unused by balanced damage", "GlobalCombatSettings.dm"),
	@("Off/Def damage term", 1, "accuracy only", "Combat/DamageScaling.dm"),
	@("Damage budget enabled", 1, "boolean", "Combat/DamageScaling.dm"),
	@("Critical damage multiplier", 1.25, "manual melee multiplier", "Combat/Melee.dm"),
	@("Raw beam damage window", 3, "damage windows", "ProjectileSystem/BeamCore.dm"),
	@("Beam leading multiplier", 0.85, "multiplier", "ProjectileSystem/Projectiles.dm"),
	@("Beam post-force multiplier", 0.6, "multiplier", "ProjectileSystem/Projectiles.dm"),
	@("Owner resistance penalty", 1, "scenario default", "ProjectileSystem/Projectiles.dm"),
	@("Ki projectile cadence", 0.5, "deciseconds", "ProjectileSystem/Blasts.dm"),
	@("World FPS", 60, "frames/second", "Application/Movement/MovementInput.dm"),
	@("Android incoming damage", 0.55, "multiplier", "BackgroundCode/StatLoop.dm"),
	@("Legendary incoming damage", 0.9, "multiplier", "BackgroundCode/StatLoop.dm"),
	@("Jiren incoming damage", 1, "multiplier", "BackgroundCode/StatLoop.dm")
)
foreach ($row in $settingRows) { Add-Row $settings.Rows @((New-Cell $row[0]), (New-Cell $row[1] 3), (New-Cell $row[2]), (New-Cell $row[3] 5)) }
$sheets.Add($settings) | Out-Null

$combatants = New-Sheet "Combatants" @(14, 18, 14, 14, 16, 12, 12, 12, 12, 12, 12, 12, 12, 12, 20) 3
Add-Row $combatants.Rows @((New-Cell "Combat Scenario Inputs" 2), (New-Cell "Enter runtime-effective values for the attacker and defender." 2))
Add-Row $combatants.Rows @((New-Cell "Yellow cells are editable. Incoming multiplier is applied after standard skill math." 6))
Add-Row $combatants.Rows @((New-Cell "Role" 1), (New-Cell "Race" 1), (New-Cell "Base BP" 1), (New-Cell "BP Mult" 1), (New-Cell "Effective BP" 1), (New-Cell "BPpcnt" 1), (New-Cell "Anger" 1), (New-Cell "Str" 1), (New-Cell "End" 1), (New-Cell "Pow" 1), (New-Cell "Res" 1), (New-Cell "Off" 1), (New-Cell "Def" 1), (New-Cell "Eff" 1), (New-Cell "Incoming Dmg Mult" 1))
Add-Row $combatants.Rows @((New-Cell "Attacker"), (New-Cell "Human" 3), (New-Cell 1000 3), (New-Cell 1 3), (New-Cell 1000 3), (New-Cell 100 3), (New-Cell 100 3), (New-Cell 100 3), (New-Cell 100 3), (New-Cell 100 3), (New-Cell 100 3), (New-Cell 100 3), (New-Cell 100 3), (New-Cell 1 3), (New-Cell 1 3))
Add-Row $combatants.Rows @((New-Cell "Defender"), (New-Cell "Human" 3), (New-Cell 1000 3), (New-Cell 1 3), (New-Cell 1000 3), (New-Cell 100 3), (New-Cell 100 3), (New-Cell 100 3), (New-Cell 100 3), (New-Cell 100 3), (New-Cell 100 3), (New-Cell 100 3), (New-Cell 100 3), (New-Cell 1 3), (New-Cell 1 3))
Add-Row $combatants.Rows @((New-Cell "Powerup + anger mix" 6), (New-FormulaCell "G4/100+F4/100-1"), (New-Cell "Attacker additive BP mixture" 5))
$sheets.Add($combatants) | Out-Null

$bpPipeline = New-Sheet "BP Pipeline" @(18, 13, 11, 10, 12, 15, 15, 13, 12, 12, 18, 14, 14, 18, 18, 18, 12, 18, 18, 18) 3
Add-Row $bpPipeline.Rows @((New-Cell "BP Pipeline Scenario" 2), (New-Cell "Major ordered stages from get_bp(); situational branches are documented on README." 2))
Add-Row $bpPipeline.Rows @((New-Cell "Yellow = input; green = formula." 6))
Add-Row $bpPipeline.Rows @((New-Cell "Scenario" 1), (New-Cell "Base BP" 1), (New-Cell "BP Mult" 1), (New-Cell "Body" 1), (New-Cell "SSJ Mult" 1), (New-Cell "Static Adds" 1), (New-Cell "Transform Add" 1), (New-Cell "HP/Ki Mult" 1), (New-Cell "Powerup %" 1), (New-Cell "Anger %" 1), (New-Cell "Super Kaioken Add" 1), (New-Cell "Pre-Cyber Mult" 1), (New-Cell "Cyber BP" 1), (New-Cell "Natural Cut if Cyber" 1), (New-Cell "Body Swap Cyber" 1), (New-Cell "Overdrive Cyber" 1), (New-Cell "Late Mult" 1), (New-Cell "Natural Pre-Cyber" 1), (New-Cell "Cyber Contribution" 1), (New-Cell "Effective BP" 1))
Add-Row $bpPipeline.Rows @((New-Cell "Attacker"), (New-Cell 1000 3), (New-Cell 1 3), (New-Cell 1 3), (New-Cell 1 3), (New-Cell 0 3), (New-Cell 0 3), (New-Cell 1 3), (New-Cell 100 3), (New-Cell 100 3), (New-Cell 0 3), (New-Cell 1 3), (New-Cell 0 3), (New-Cell 0 3), (New-Cell 1 3), (New-Cell 1 3), (New-Cell 1 3), (New-FormulaCell "((B4*C4*D4*E4)+F4+G4)*H4*(I4/100+J4/100-1+K4)*L4"), (New-FormulaCell "M4*O4*P4"), (New-FormulaCell "(R4*IF(M4>0,N4,1)+S4)*Q4"))
Add-Row $bpPipeline.Rows @((New-Cell "Examples" 6), (New-Cell "SSJ Mult: 1.35 / 1.8225 / 2.73375 / 2.916. Overdrive Cyber: 1.5. God final multiplier: 1.3. Android with cyber usually uses Natural Cut 0." 5))
$sheets.Add($bpPipeline) | Out-Null

$races = New-Sheet "Race Profiles" @(18, 20, 12, 50, 24, 14, 14, 14, 14, 72) 2
Add-Row $races.Rows @((New-Cell "Race Profiles" 2), (New-Cell "Creation budgets, notable presets and damage-relevant traits." 2))
Add-Row $races.Rows @((New-Cell "Race" 1), (New-Cell "Class/Trait" 1), (New-Cell "Budget" 1), (New-Cell "Starting modifiers" 1), (New-Cell "Primary caps" 1), (New-Cell "Regen cap" 1), (New-Cell "Recovery cap" 1), (New-Cell "Anger cap" 1), (New-Cell "Incoming damage" 1), (New-Cell "Damage-relevant notes/source" 1))
$raceRows = @(
	@("Human", "Standard", 72, "All primary 1", "2.5", 1.2, 2, 150, 1, "Early Third Eye; high mature ascension; no direct skill damage override"),
	@("Spirit Doll", "Standard", 72, "All primary 1", "4", 1.2, 2.4, 130, 1, "Human-derived utility; direct skill damage overrides removed"),
	@("Saiyan", "Standard", 33, "Str 1.2; End 1.4; Pow 1.2; Res 1.4; Spd 1.2; Regen 1.6", "2", 1.6, 1.6, "140-180", 1, "SSJ pipeline and static BP additions"),
	@("Saiyan", "Low Class", 37, "End 1.5; Res 1.5; Regen 1.6", "2", 1.6, 1.6, 140, 1, "Class allocation variant"),
	@("Saiyan", "Elite", 34, "Str 1.5; Pow 1.5; Spd 1.6", "2", 1.6, 1.6, 160, 1, "Class allocation variant"),
	@("Saiyan", "Legendary", 34, "End 1.8; Res 1.8", "2.5", 3.6, 2.2, 180, 0.9, "Exceptional sustainable tier; racial BP 1.65 and LSSJ form"),
	@("Half Saiyan", "Standard", 44, "All primary 1", "2.5", 1.6, 2.4, 400, 1, "SSJ access; high anger cap"),
	@("Alien", "Standard", 75, "Primary 0.8; Regen/Recovery 0.6", "5", 4, 3, 150, 1, "Shifter can gain stretchy limbs"),
	@("Alien", "Apex Genome option", 75, "As Alien plus option", "5", 4, 3, 150, 1, "Normalized Standard tier: effective BP x0.95; cannot anger; soft cap x0.75"),
	@("Android", "Chassis / Infiltrator", 61, "Force 0.8; Regen/Recovery 0.6", "5", 3, 3, "N/A", 0.55, "Exceptional external tier; cyber BP replacement/Overdrive pipeline"),
	@("Demigod", "Standard", 24, "Str 2; End 1.5; Res 1.5", "Energy 4; others 2", 3, 3, 200, 1, "Starts with Zanzoken when racial skills enabled"),
	@("Makyo", "Standard", 48, "End 1.7; Spd 1.7", "Energy 2.5; others 2", 2, 1.6, 150, 1, "Giant Form gets larger BP addition"),
	@("Namekian", "Standard", 45, "Defense 1.5; Regen 3", "4", 4, 1.6, 130, 1, "Stretchy arms 500 px; Zanzoken racial grant"),
	@("Bio-Android", "Exceptional", 31, "Spd 1.4; Res 1.4; Regen 2", "2.5", 6, 2, 200, 0.89, "Perfect Form late BP x1.6; racial BP x1.1; stretchy arms 500 px"),
	@("Majin", "Exceptional", 34, "Regen 2; Recovery 2; End/Res x0.77 then Regen x2.5", "3", 999, 2.4, 160, 0.96, "Racial BP 1.13; Majin buff bp_mult +0.2; attack drain +0.5"),
	@("Kai", "Standard", 42, "Energy 1.3; Spd 1.5; Recovery 2", "5", 1, 3, 120, 1, "High energy/speed profile"),
	@("Frost Lord", "Standard/Cooler", 29, "End/Res/Spd 1.5", "Energy 2.5; combat 1.9; Off/Def 2", 1, 1.4, 130, 1, "Four additive forms; Gold and God Ki paths"),
	@("Demon", "Standard", 44, "All primary 1", "2", 4, 1.6, 200, 1, "BP x 1 + 0.1 per collected soul"),
	@("Tsujin", "Standard", 55, "All primary 1", "2.5", 1, 2, 150, 1, "Standard damage pipeline")
)
foreach ($row in $raceRows) {
	$cells = @(); foreach ($value in $row) { $cells += New-Cell $value $(if ($value -is [string] -and $value.Length -gt 30) { 5 } else { 0 }) }; Add-Row $races.Rows $cells
}
$sheets.Add($races) | Out-Null

function New-PrimaryStats($energy, $strength, $endurance, $speed, $force, $resistance, $offense, $defense) {
	return [ordered]@{
		Energy = [double]$energy; Strength = [double]$strength; Endurance = [double]$endurance; Speed = [double]$speed
		Force = [double]$force; Resistance = [double]$resistance; Offense = [double]$offense; Defense = [double]$defense
	}
}

function New-PrimaryCaps($defaultCap, $energy = 0, $strength = 0, $endurance = 0, $speed = 0, $force = 0, $resistance = 0, $offense = 0, $defense = 0) {
	$caps = New-PrimaryStats $defaultCap $defaultCap $defaultCap $defaultCap $defaultCap $defaultCap $defaultCap $defaultCap
	$overrides = @($energy, $strength, $endurance, $speed, $force, $resistance, $offense, $defense)
	$ids = @("Energy", "Strength", "Endurance", "Speed", "Force", "Resistance", "Offense", "Defense")
	for ($i = 0; $i -lt $ids.Count; $i++) { if ($overrides[$i] -gt 0) { $caps[$ids[$i]] = [double]$overrides[$i] } }
	return $caps
}

function New-RaceBalanceProfile($race, $variant, $tier, $startingBp, $currentPassiveBp, $proposedPassiveBp, $budget, $preset, $caps, $regen, $recovery, $currentIncoming, $proposedIncoming, $notes, $postEnergy = 1, $postEndurance = 1, $postResistance = 1) {
	return [pscustomobject]@{
		Race = $race; Variant = $variant; Tier = $tier; StartingBp = [double]$startingBp
		CurrentPassiveBp = [double]$currentPassiveBp; ProposedPassiveBp = [double]$proposedPassiveBp; Budget = [int]$budget
		Preset = $preset; Caps = $caps; Regen = [double]$regen; Recovery = [double]$recovery
		CurrentIncoming = [double]$currentIncoming; ProposedIncoming = [double]$proposedIncoming; Notes = $notes
		PostEnergy = [double]$postEnergy; PostEndurance = [double]$postEndurance; PostResistance = [double]$postResistance
	}
}

function Get-NeutralRaceStats($profile) {
	$stats = [ordered]@{}
	$ids = @($profile.Preset.Keys)
	foreach ($id in $ids) { $stats[$id] = [double]$profile.Preset[$id] }
	$remaining = $profile.Budget
	while ($remaining -gt 0) {
		$allocated = $false
		foreach ($id in $ids) {
			if ($remaining -le 0) { break }
			if ($stats[$id] -ge $profile.Caps[$id] - 0.0001) { continue }
			$stats[$id] = [math]::Round($stats[$id] + 0.1, 10)
			$remaining--
			$allocated = $true
		}
		if (-not $allocated) { throw "Race balance profile cannot spend its budget: $($profile.Race) / $($profile.Variant)" }
	}
	$stats.Energy *= $profile.PostEnergy
	$stats.Endurance *= $profile.PostEndurance
	$stats.Resistance *= $profile.PostResistance
	return $stats
}

$caps2 = New-PrimaryCaps 2
$caps25 = New-PrimaryCaps 2.5
$caps3 = New-PrimaryCaps 3
$caps4 = New-PrimaryCaps 4
$caps5 = New-PrimaryCaps 5
$raceBalanceProfiles = @(
	(New-RaceBalanceProfile "Human" "Adaptability" "Standard" 1.33 1 1 72 (New-PrimaryStats 1 1 1 1 1 1 1 1) $caps25 1 1 1 1 "Baseline; target-equivalent to untransformed Saiyan"),
	(New-RaceBalanceProfile "Spirit Doll" "Awakened Soul" "Standard" 1.197 1 1 72 (New-PrimaryStats 1 1 1 1 1 1 1 1) $caps4 1 1 1 1 "Human-derived utility profile; direct racial damage bonuses removed"),
	(New-RaceBalanceProfile "Saiyan" "Warrior Blood" "Standard" 2 1 0.77 33 (New-PrimaryStats 1 1.2 1.4 1.2 1.2 1.4 1 1) $caps2 1.6 1 1 1 "Base untransformed target must remain within 5% of Human"),
	(New-RaceBalanceProfile "Saiyan" "Low Class" "Standard" 2 1 0.77 37 (New-PrimaryStats 1 1 1.5 1 1 1.5 1 1) $caps2 1.6 1 1 1 "Defensive base profile; easier SSJ progression excluded here"),
	(New-RaceBalanceProfile "Saiyan" "Elite" "Standard" 2 1 0.77 34 (New-PrimaryStats 1 1.5 1 1.6 1.5 1 1 1) $caps2 1 1 1 1 "Offensive base profile; starting techniques excluded here"),
	(New-RaceBalanceProfile "Half Saiyan" "Hybrid Potential" "Standard" 2.5 1 0.69 44 (New-PrimaryStats 1 1 1 1 1 1 1 1) $caps25 1 1 1 1 "High anger and transformations are reported separately"),
	(New-RaceBalanceProfile "Legendary Saiyan" "Legendary Berserker" "Exceptional" 2 1.55 1.65 34 (New-PrimaryStats 1 1 1.8 1 1 1.8 1 1) $caps25 1 1 0.6 0.9 "Creation diagnostic; sustainable LSSJ target is authoritative" 2.5),
	(New-RaceBalanceProfile "Alien" "Scholar" "Standard" 1.55 1 1 75 (New-PrimaryStats 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8) $caps5 0.6 0.6 1 1 "Utility profile"),
	(New-RaceBalanceProfile "Alien" "Predator" "Standard" 1.55 1 1 75 (New-PrimaryStats 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8) $caps5 1.1 0.6 1 1 "Regeneration, precognition and zenkai utility"),
	(New-RaceBalanceProfile "Alien" "Shifter" "Standard" 1.55 1 1 75 (New-PrimaryStats 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8) $caps5 0.6 0.6 1 1 "Giant Form drift fixed; transformations excluded from base row"),
	(New-RaceBalanceProfile "Alien" "Apex Genome" "Standard" 1.55 1.8 0.95 75 (New-PrimaryStats 0.8 0.8 0.8 0.8 0.8 0.8 0.8 0.8) $caps5 1.1 0.6 0.6 1 "Jiren package normalized because Alien is not an exceptional tier"),
	(New-RaceBalanceProfile "Android" "Chassis / Infiltrator" "Exceptional" 1 1 1.35 61 (New-PrimaryStats 1 1 1 1 0.8 1 1 1) $caps5 0.6 0.6 0.66 0.55 "Cyber BP and modules excluded from base row; no anger"),
	(New-RaceBalanceProfile "Bio-Android" "Adaptive Genome" "Exceptional" 2.1 1 1.1 31 (New-PrimaryStats 1 1 1 1.4 1 1.4 1 1) $caps25 2 1 1 0.89 "Forms and absorption excluded from base row"),
	(New-RaceBalanceProfile "Demigod" "Divine Heritage" "Standard" 2.5 1 0.66 24 (New-PrimaryStats 1 2 1.5 1 1 1.5 1 1) (New-PrimaryCaps 2 4) 1 1 1 1 "High BP offset by the smallest discretionary budget"),
	(New-RaceBalanceProfile "Demon" "Soulbound" "Standard" 1.85 1 1 44 (New-PrimaryStats 1 1 1 1 1 1 1 1) $caps2 1 1 1 1 "Soul scaling must remain bounded outside this base row"),
	(New-RaceBalanceProfile "Frost Lord" "Imperial Heir" "Standard" 2.1 1 0.8 29 (New-PrimaryStats 1 1 1.5 1.5 1 1.5 1 1) (New-PrimaryCaps 2 2.5 1.9 1.9 1.9 1.9 1.9) 1 1 1 1 "Standard Frost forms excluded from base row"),
	(New-RaceBalanceProfile "Frost Lord" "Cooler" "Exceptional" 2.1 1 0.76 29 (New-PrimaryStats 1 1 1.5 1.5 1 1.5 1 1) (New-PrimaryCaps 2 2.5 1.9 1.9 1.9 1.9 1.9) 1 1 1 0.89 "Creation diagnostic; fifth-form sustainable target is authoritative"),
	(New-RaceBalanceProfile "Kai" "Guardian" "Standard" 1.8 1 1 42 (New-PrimaryStats 1.3 1 1 1.5 1 1 1 1) $caps5 1 2 1 1 "Recovery and support utility"),
	(New-RaceBalanceProfile "Makyo" "Starborn" "Standard" 1.85 1 0.77 48 (New-PrimaryStats 1 1 1.7 1.7 1 1 1 1) (New-PrimaryCaps 2 2.5) 1 1 1 1 "Makyo Star recovery excluded from direct power index"),
	(New-RaceBalanceProfile "Majin" "Primal Fragment" "Exceptional" 2.55 1 1.13 34 (New-PrimaryStats 1 1 1 1 1 1 1 1) $caps3 5 2 1 0.96 "Creation diagnostic; sustainable row includes Majin buff" 1 0.77 0.77),
	(New-RaceBalanceProfile "Namekian" "Dragon Clan" "Standard" 1.65 1 1 45 (New-PrimaryStats 1 1 1 1 1 1 1 1.5) $caps4 3 1 1 1 "Fusion excluded from base row"),
	(New-RaceBalanceProfile "Tsujin" "Engineer" "Standard" 1.28 1 1 55 (New-PrimaryStats 1 1 1 1 1 1 1 1) $caps25 1 1 1 1 "Technology utility excluded from base row")
)

$raceBalance = New-Sheet "Race Balance" @(18, 24, 14, 12, 13, 15, 15, 16, 16, 10, 11, 11, 11, 11, 11, 11, 11, 11, 12, 12, 15, 15, 14, 14, 14, 14, 70) 2
Add-Row $raceBalance.Rows @((New-Cell "Race Balance Comparison" 2), (New-Cell "Creation-only diagnostic. Use Progression Balance for authoritative mature, sustainable, endgame, burst and external-progression comparisons." 2))
Add-Row $raceBalance.Rows @(
	(New-Cell "Race" 1), (New-Cell "Variant" 1), (New-Cell "Tier" 1), (New-Cell "Target" 1), (New-Cell "Starting BP" 1),
	(New-Cell "Current passive BP" 1), (New-Cell "Proposed passive BP" 1), (New-Cell "Current effective BP" 1), (New-Cell "Proposed effective BP" 1), (New-Cell "Budget" 1),
	(New-Cell "Energy" 1), (New-Cell "Strength" 1), (New-Cell "Endurance" 1), (New-Cell "Speed" 1), (New-Cell "Force" 1), (New-Cell "Resistance" 1),
	(New-Cell "Offense" 1), (New-Cell "Defense" 1), (New-Cell "Regeneration" 1), (New-Cell "Recovery" 1),
	(New-Cell "Current incoming" 1), (New-Cell "Proposed incoming" 1), (New-Cell "Current index" 1), (New-Cell "Proposed index" 1),
	(New-Cell "Target delta" 1), (New-Cell "Status" 1), (New-Cell "Scope / notes" 1)
)

foreach ($profile in $raceBalanceProfiles) {
	$stats = Get-NeutralRaceStats $profile
	$rowNumber = $raceBalance.Rows.Count + 1
	$target = if ($profile.Tier -eq "Exceptional") { 125 } else { 100 }
	$currentBp = "E$rowNumber*F$rowNumber"
	$proposedBp = "E$rowNumber*G$rowNumber"
	$currentMeleeOut = "POWER(H$rowNumber/`$H`$3,0.5)*POWER(2*L$rowNumber/(L$rowNumber+`$M`$3),0.85)"
	$currentKiOut = "POWER(H$rowNumber/`$H`$3,0.5)*POWER(2*O$rowNumber/(O$rowNumber+`$P`$3),0.85)"
	$currentMeleeIn = "POWER(`$H`$3/H$rowNumber,0.5)*POWER(2*`$L`$3/(`$L`$3+M$rowNumber),0.85)*U$rowNumber"
	$currentKiIn = "POWER(`$H`$3/H$rowNumber,0.5)*POWER(2*`$O`$3/(`$O`$3+P$rowNumber),0.85)*U$rowNumber"
	$proposedMeleeOut = "POWER(I$rowNumber/`$I`$3,0.5)*POWER(2*L$rowNumber/(L$rowNumber+`$M`$3),0.85)"
	$proposedKiOut = "POWER(I$rowNumber/`$I`$3,0.5)*POWER(2*O$rowNumber/(O$rowNumber+`$P`$3),0.85)"
	$proposedMeleeIn = "POWER(`$I`$3/I$rowNumber,0.5)*POWER(2*`$L`$3/(`$L`$3+M$rowNumber),0.85)*V$rowNumber"
	$proposedKiIn = "POWER(`$I`$3/I$rowNumber,0.5)*POWER(2*`$O`$3/(`$O`$3+P$rowNumber),0.85)*V$rowNumber"
	$utility = "POWER(N$rowNumber/`$N`$3,0.2)*POWER(Q$rowNumber/`$Q`$3,0.1)*POWER(R$rowNumber/`$R`$3,0.1)*POWER(S$rowNumber/`$S`$3,0.1)"
	$currentIndex = "100*SQRT(((($currentMeleeOut)+($currentKiOut))/2)*($utility)/((($currentMeleeIn)+($currentKiIn))/2))"
	$proposedIndex = "100*SQRT(((($proposedMeleeOut)+($proposedKiOut))/2)*($utility)/((($proposedMeleeIn)+($proposedKiIn))/2))"
	Add-Row $raceBalance.Rows @(
		(New-Cell $profile.Race), (New-Cell $profile.Variant), (New-Cell $profile.Tier), (New-Cell $target), (New-Cell $profile.StartingBp 3),
		(New-Cell $profile.CurrentPassiveBp 3), (New-Cell $profile.ProposedPassiveBp 3), (New-FormulaCell $currentBp), (New-FormulaCell $proposedBp), (New-Cell $profile.Budget),
		(New-Cell $stats.Energy 3), (New-Cell $stats.Strength 3), (New-Cell $stats.Endurance 3), (New-Cell $stats.Speed 3), (New-Cell $stats.Force 3), (New-Cell $stats.Resistance 3),
		(New-Cell $stats.Offense 3), (New-Cell $stats.Defense 3), (New-Cell $profile.Regen 3), (New-Cell $profile.Recovery 3),
		(New-Cell $profile.CurrentIncoming 3), (New-Cell $profile.ProposedIncoming 3), (New-FormulaCell $currentIndex), (New-FormulaCell $proposedIndex),
		(New-FormulaCell "X$rowNumber-D$rowNumber"), (New-FormulaCell "IF(ABS(Y$rowNumber/D$rowNumber)<=0.1,`"IN BAND`",`"REVIEW`")"), (New-Cell $profile.Notes 5)
	)
}
$sheets.Add($raceBalance) | Out-Null

$progression = New-Sheet "Progression Balance" @(18, 24, 13, 13, 16, 14, 15, 34, 15, 34, 18, 34, 15, 24, 30, 58, 58, 18) 2
Add-Row $progression.Rows @((New-Cell "Race Progression Balance" 2), (New-Cell "R is equal relative natural progression: natural BP divided by the mature growth modifier. S2 is the best sustainable racial package; S3 separates God/endgame; S4 is a 180-second burst; S5 documents cyber, absorption and fusion." 2))
Add-Row $progression.Rows @(
	(New-Cell "Race" 1), (New-Cell "Variant" 1), (New-Cell "Tier" 1), (New-Cell "S0 creation BP/R" 1), (New-Cell "Mature growth mod" 1), (New-Cell "Racial combat mult" 1), (New-Cell "S1 mature BP/R" 1),
	(New-Cell "S2 sustainable package" 1), (New-Cell "S2 BP/R" 1), (New-Cell "S3 common endgame" 1), (New-Cell "S3 BP/R" 1), (New-Cell "S4 burst package" 1), (New-Cell "S4 BP/R" 1),
	(New-Cell "Powerup soft-cap modifier" 1), (New-Cell "Stat limits" 1), (New-Cell "Racial abilities included" 1), (New-Cell "S5 external progression" 1), (New-Cell "Screening status" 1)
)
function Add-ProgressionRow($race, $variant, $tier, $creation, $growth, $racial, $mature, $sustainable, $sustainableBp, $endgame, $endgameBp, $burst, $burstBp, $powerup, $limits, $abilities, $external, $status) {
	Add-Row $progression.Rows @(
		(New-Cell $race), (New-Cell $variant), (New-Cell $tier), (New-Cell $creation 3), (New-Cell $growth 3), (New-Cell $racial 3), (New-Cell $mature 3),
		(New-Cell $sustainable 5), (New-Cell $sustainableBp 3), (New-Cell $endgame 5), (New-Cell $endgameBp 3), (New-Cell $burst 5), (New-Cell $burstBp 3),
		(New-Cell $powerup 5), (New-Cell $limits 5), (New-Cell $abilities 5), (New-Cell $external 5), (New-Cell $status)
	)
}
Add-ProgressionRow "Human" "Adaptability" "Standard" 1.33 21.603 1 21.603 "Ascension + Third Eye (available early)" 25.923 "Same; Human has no stronger native primary" 25.923 "Third Eye + Limit Breaker" 36.725 "1.0 x 27*KiMod^0.9" "Primary caps 2.5; large 72-point budget" "Third Eye, early mastery/meditation utility, broad learnability" "Mystic/Fire Fist are shared learned buffs and reported separately" "IN BAND"
Add-ProgressionRow "Spirit Doll" "Awakened Soul" "Standard" 1.197 16.907 1 16.907 "Mature untransformed" 16.907 "Shared learned buffs" 16.907 "Limit Breaker" 25.36 "1.0" "Primary caps 4; recovery 2.4" "Human-derived utility; no direct damage override" "Shared buffs" "UTILITY LOW BP"
Add-ProgressionRow "Saiyan" "Warrior / Low / Elite" "Standard" 1.54 11 0.77 8.47 "Mastered SSJ4" 24.699 "SSB + God Ki" "14.86 + God BP" "SSJ4 + Limit Breaker" 37.049 "SSJ4 x1.3; form soft caps also apply" "Primary caps 2; class-specific stat presets" "Saiyan Power, anger, tail/Oozaru, permanent post-SSJ growth" "God BP; fusion" "IN BAND"
Add-ProgressionRow "Half Saiyan" "Hybrid Potential" "Standard" 1.725 11 0.69 7.59 "Mastered SSJ4" 22.132 "SSB + God Ki" "13.32 + God BP" "SSJ4 + Limit Breaker" 33.198 "SSJ4 x1.3" "Primary caps 2.5; anger cap 400" "Saiyan Power, transformations, highest anger ceiling" "God BP; fusion" "IN BAND"
Add-ProgressionRow "Legendary Saiyan" "Legendary Berserker" "Exceptional" 3.3 11 1.65 18.15 "Legendary SSJ1" 33.079 "Legendary SSJ1; Mystic lowers drain but adds no LSSJ BP" 33.079 "LSSJ + Limit Breaker" 49.619 "x0.83 from always-angry package" "End/Res preset 1.8; primary caps 2.5" "Growing LSSJ static BP, knockback/stun resistance, regeneration" "God BP; fusion" "EXCEPTIONAL 33R"
Add-ProgressionRow "Alien" "Scholar / Predator" "Standard" 1.55 22.542 1 22.542 "Mature untransformed" 22.542 "Selected 100-AP utility package" 22.542 "Limit Breaker if purchased" 33.813 "1.0" "Primary caps 5; Powerup depends on selected Energy" "100-AP abilities: time freeze, precog, absorb, zenkai, regen, mastery and others" "Absorption only when purchased" "IN BAND"
Add-ProgressionRow "Alien" "Shifter options" "Standard" 1.55 22.542 1 22.542 "Giant Form" 27.051 "One-primary rule prevents Giant + Alien Transform stacking" 27.051 "Giant + Limit Breaker" 38.321 "1.0" "Primary caps 5" "Custom AP package; stretchy arms, imitation and movement utility" "Absorption only when purchased" "HIGH STANDARD"
Add-ProgressionRow "Alien" "Apex Genome option" "Standard" 1.473 22.542 0.95 21.415 "Mature Apex Genome" 21.415 "Same" 21.415 "Limit Breaker if purchased separately within AP budget" 32.122 "x0.75; no anger" "Primary caps 5" "Knockback/stun resistance, no anger; 50 AP opportunity cost" "Cannot simultaneously buy every Alien utility" "IN BAND"
Add-ProgressionRow "Android" "Chassis / Infiltrator" "Exceptional" 1.35 "External" 1.35 "Cyber replaces natural" "Cyber cap with normal modules" "External" "Overdrive / module package" "External" "Overdrive x1.5 cyber" "External" "27*KiMod^0.9; no anger" "Primary caps 5; Force starts 0.8" "Modules, shields, absorb, rebuild, infinite lifespan; incoming 0.55" "Knowledge*Intelligence^0.1*cyber_bp_mod*1.8*tools*1.1; must be scenario input" "S5 REQUIRED"
Add-ProgressionRow "Bio-Android" "Adaptive Genome" "Exceptional" 2.31 18.785 1.1 20.664 "Perfect Form x1.6" 33.062 "Absorption progression excluded from equal-R base" 33.062 "Perfect + Limit Breaker" 49.593 "1.0" "Primary caps 2.5; Spd/Res preset 1.4" "Regeneration, absorption, permanent body evolution, stun resistance" "Sequential absorption gap closure" "EXCEPTIONAL 33R"
Add-ProgressionRow "Demigod" "Divine Heritage" "Standard" 1.65 30.056 0.66 19.837 "Mature untransformed" 19.837 "Shared learned buffs" 19.837 "Limit Breaker" 29.756 "1.0" "Energy cap 4; others 2; only 24 points" "Early Zanzoken and high ascension scaling" "God/shared buffs" "IN BAND"
Add-ProgressionRow "Demon" "Soulbound" "Standard" 1.85 18.785 1 18.785 "Three effective souls x1.3" 24.421 "Same" 24.421 "Three souls + Limit Breaker" 36.632 "1.0" "Primary caps 2; regen cap 4" "Soul Energy, capped soul BP, death utility" "External soul acquisition capped at three" "IN BAND"
Add-ProgressionRow "Frost Lord" "Imperial Heir" "Standard" 1.68 18.785 0.8 15.028 "Final Form additions" 22.242 "Gold + God Ki" "37.59 + God BP" "Final + Limit Breaker" 33.363 "1.0" "Combat caps 1.9; Energy 2.5" "Spawns with all native forms; Death Ball path" "Gold/God BP" "IN BAND"
Add-ProgressionRow "Frost Lord" "Cooler" "Exceptional" 1.596 18.785 0.76 14.276 "Fifth Form additions" 33.12 "Gold + God Ki" "55.97 + God BP" "Fifth + Limit Breaker" 49.68 "1.0" "Combat caps 1.9; Energy 2.5" "Fifth form, rare creation lineage, expanded racial skill package" "Gold/God BP" "EXCEPTIONAL 33R"
Add-ProgressionRow "Kai" "Guardian" "Standard" 1.8 24.421 1 24.421 "Mature untransformed" 24.421 "God/support progression" 24.421 "Limit Breaker" 36.632 "1.0" "Primary caps 5; Energy 1.3; Speed 1.5" "High recovery, afterlife and support utility" "God/shared buffs" "IN BAND"
Add-ProgressionRow "Makyo" "Starborn" "Standard" 1.425 18.785 0.77 14.465 "Makyo Giant (bp_mult +0.5)" 21.697 "Makyo Star uptime scenario separate" 21.697 "Giant + Limit Breaker (bp_mult 2.0 total)" 28.93 "1.0" "Energy cap 2.5; others 2" "Makyo Star, Giant stat package" "Celestial uptime" "IN BAND"
Add-ProgressionRow "Majin" "Primal Fragment" "Exceptional" 2.882 24.421 1.13 27.596 "Majin buff (bp_mult +0.2)" 33.115 "Same sustainable package" 33.115 "Majin + Limit Breaker (bp_mult 1.7 total)" 46.913 "1.0" "Primary caps 3; post-allocation End/Res x0.77" "Extreme regeneration, stretchy arms, imitation, Majin buff cost penalty" "Absorption/fusion if externally acquired" "EXCEPTIONAL 33R"
Add-ProgressionRow "Namekian" "Dragon Clan" "Standard" 1.65 18.785 1 18.785 "Mature untransformed" 18.785 "Fusion scenario separate" 18.785 "Limit Breaker" 28.178 "1.0" "Primary caps 4; Defense preset 1.5" "Regeneration, 500px arms, Namekian fusion, Zanzoken" "Namekian fusion" "UTILITY LOW BP"
Add-ProgressionRow "Tsujin" "Engineer" "Standard" 1.28 15.028 1 15.028 "Mature untransformed" 15.028 "Technology progression separate" 15.028 "Limit Breaker" 22.542 "1.0" "Primary caps 2.5; 55-point budget" "Technology and knowledge economy" "Technology equipment/cyber" "S5 UTILITY"
$sheets.Add($progression) | Out-Null

$modifiers = New-Sheet "Modifiers" @(22, 34, 18, 84, 18, 78) 2
Add-Row $modifiers.Rows @((New-Cell "Modules, Transformations and Buffs" 2), (New-Cell "Only active damage/BP/stat/cost effects are listed; dead branches are explicitly flagged." 2))
Add-Row $modifiers.Rows @((New-Cell "Kind" 1), (New-Cell "Name / type" 1), (New-Cell "Pipeline phase" 1), (New-Cell "Exact effect" 1), (New-Cell "Status" 1), (New-Cell "Source" 1))
$modifierRows = @(
	@("Module", "Giant Version", "Stats", "Str/End/Res x1.3; Spd x0.5", "Active", "Technology/Cybernetics.dm:84-90"),
	@("Module", "Body Swap", "Cyber BP", "End/Res/Def x0.95; cyber contribution x0.67", "Compiled; Cost 0", "Technology/Cybernetics.dm:92-103; StatLoop.dm:67-69"),
	@("Module", "Scrap Absorb", "Cyber BP", "Temporarily adds 0.5 x scrap cyber BP for 900 ticks", "Active; Android", "Technology/Cybernetics.dm:118-123,1489-1566"),
	@("Module", "Force Field", "Incoming", "Enables cyber force field while Ki >=10%; intercepts projectiles and melee through shield paths", "Active", "Technology/Cybernetics.dm:159-163; Projectiles.dm"),
	@("Module", "Blast Absorb", "Incoming/Cost", "Absorbs qualifying front Ki blasts; natural shield cost x1.25", "Active", "Technology/Cybernetics.dm:170-181"),
	@("Module", "Rebuild", "Outgoing", "Self Destruct damage x0.5", "Active", "Combat/Skills.dm:2402-2407"),
	@("Module", "Generator", "Stats/Cost", "max Ki, Ki and Eff x2.5; regen/recovery x0.5; skill drains scale with sqrt(max Ki)", "Active", "Technology/Cybernetics.dm:198-207"),
	@("Module", "Overdrive", "Cyber BP", "Cyber contribution x1.5 while active; Health -1.5 every 20 ticks", "Active", "Technology/Cybernetics.dm:1429-1452; StatLoop.dm:188"),
	@("Module", "Brute", "Stats", "Str x1.3; regen/recovery x0.5", "Active", "Technology/Cybernetics.dm:228-232"),
	@("Module", "Cybernetic Armor", "Stats", "End/Res x1.2; regen/recovery x0.5", "Active", "Technology/Cybernetics.dm:246-255"),
	@("Module", "Cyber Charge", "Skill grant", "Grants 10% Ki projectile; OffMult 2; explosion 1; drain 10", "Active", "Cybernetics.dm:257-260; SkillEngine.dm:536-565"),
	@("Module", "Laser Beam", "Skill grant", "Grants WaveMult 1.1 beam; MoveDelay 1; range 60", "Active", "Cybernetics.dm:262-266; Beams.dm"),
	@("Module", "Time Normalizer", "Stats/Cost", "max Ki/Ki/Eff x0.9; Pow x0.95; regen x0.85", "Active", "Technology/Cybernetics.dm:268-277"),
	@("Transformation", "Power Control", "BP", "Additive BP mix uses anger/100 + BPpcnt/100 - 1 + Super Kaioken addition", "Active", "BackgroundCode/StatLoop.dm:25-49"),
	@("Transformation", "Giant Form", "BP/Stats", "bp_mult +0.2 (Makyo total +0.5); Str/End/Res x1.25; Off/Def/Spd x0.75", "Active; revert BP drift bug", "Combat/Skills.dm:1-100"),
	@("Transformation", "Limit Breaker", "BP/Stats", "bp_mult +0.5; Off/regen/recovery x3; timed revert KOs user", "Active", "Combat/Skills.dm:102-168"),
	@("Buff", "Third Eye", "BP", "bp_mult +0.2; available early to Humans; mature Human ascension is modeled separately", "Active", "PlayerMechanics/Ascension.dm:760-821"),
	@("Transformation", "Kaioken", "BP", "Normal form adds capped base-BP-derived amount; Super Kaioken adds 0.7 to powerup/anger mix", "Active", "Transformations/Kaioken.dm"),
	@("Transformation", "Ultra Super Saiyan", "BP/Stats", "bp_mult +0.4; Str/End x1.3; Res x1.2; Eff x0.67", "Compiled; no normal grant found", "PlayerMechanics/Ascension.dm:45-131"),
	@("Transformation", "SSJ 1/2/3/4", "BP", "SSJ multipliers 1.35 / 1.8225 / 2.73375 / 2.916 plus static BP additions", "Active", "PlayerMechanics/Ascension.dm"),
	@("Transformation", "Mystic", "BP/Stats/Cost", "Spd x1.1; SSJ BP x1.15; energy drain accumulator -0.3; anger boost x0.85", "Active", "Combat/Skills.dm:2953-3019"),
	@("Buff", "Fire Fist", "Outgoing", "All melee damage x1.2; 40% burn application chance", "Active", "Combat/Skills.dm:3020-3085; Melee.dm"),
	@("Buff", "Majin", "BP/Cost", "bp_mult +0.2; max anger x1.2; attack drain accumulator +0.5", "Active", "Combat/Skills.dm:3152-3213"),
	@("Transformation", "Great Ape", "BP/Stats", "bp_mult +2.5 plus additive BP; Str/End/Res x1.3; Def/Spd x0.1", "Active", "Races/Oozaru.dm"),
	@("Transformation", "God Ki", "BP", "Adds mastery-scaled God BP and final total BP x1.3", "Active", "PlayerMechanics/GodKi.dm; StatLoop.dm"),
	@("Transformation", "SSG / SSB / Gold", "BP/Stats", "Pre-cyber BP x1.25 / x1.35 / x1.3; enables God Ki branches", "Active", "Races/Saiyan/SsGodRed.dm; SSBlue.dm; Icer/GoldIcer.dm"),
	@("Transformation", "Bio forms", "Late BP", "Late BP multiplier x0.5 / x1 / x1.3 / x1.6", "Active", "Races/BioAndroid/Bios.dm"),
	@("Transformation", "Ultra Instinct", "BP/Stats/Cost", "bp_mult +0.7; Spd/Off/Def x3; dodge stamina /4; melee costs +8 stamina", "Active", "Races/UltraInstinct.dm"),
	@("Status", "Android", "BP/Incoming", "Natural BP x1.35 before cyber replacement; incoming TakeDamage x0.55; cannot anger", "Active", "StatLoop.dm; Races/Android/Android.dm"),
	@("Status", "Legendary always angry", "BP/Incoming", "Racial combat BP x1.65; incoming TakeDamage x0.9", "Active", "StatLoop.dm; Combat/Melee.dm"),
	@("Status", "Jiren Alien", "BP/Incoming", "Normalized Standard package: BP x0.95; incoming x1; cannot anger; powerup soft cap x0.75", "Active", "Races/AlienStarterMoves.dm; StatLoop.dm")
)
foreach ($row in $modifierRows) { Add-Row $modifiers.Rows @((New-Cell $row[0]), (New-Cell $row[1]), (New-Cell $row[2]), (New-Cell $row[3] 5), (New-Cell $row[4]), (New-Cell $row[5] 5)) }
$sheets.Add($modifiers) | Out-Null

$catalog = New-Sheet "Skill Catalog" @(24, 40, 26, 18, 14, 10, 13, 20, 13, 13, 34, 13, 30, 46, 76) 2
Add-Row $catalog.Rows @((New-Cell "Current Damage Skill Catalog" 2), (New-Cell "Numeric factor means melee multiplier, projectile percent, or beam WaveMult according to Model." 2))
Add-Row $catalog.Rows @((New-Cell "Skill" 1), (New-Cell "Type path" 1), (New-Cell "Status" 1), (New-Cell "Model" 1), (New-Cell "Factor" 1), (New-Cell "Hits" 1), (New-Cell "MoveDelay" 1), (New-Cell "Explosion" 1), (New-Cell "Drain" 1), (New-Cell "Cooldown s" 1), (New-Cell "Charge / timing" 1), (New-Cell "Range" 1), (New-Cell "Race override" 1), (New-Cell "Known issue / note" 1), (New-Cell "Source" 1))
function Add-SkillRow($name, $path, $status, $model, $factor, $hits, $moveDelay, $explosion, $drain, $cooldown, $charge, $range, $race, $issue, $source) {
	Add-Row $catalog.Rows @((New-Cell $name), (New-Cell $path 5), (New-Cell $status), (New-Cell $model), (New-Cell $factor), (New-Cell $hits), (New-Cell $moveDelay), (New-Cell $explosion), (New-Cell $drain), (New-Cell $cooldown), (New-Cell $charge 5), (New-Cell $range), (New-Cell $race 5), (New-Cell $issue 5), (New-Cell $source 5))
}
Add-SkillRow "Manual Attack" "/obj/Manual_Attack" "Global action" "Physical" 2.5 1 0 0 "GMD(24)" 0 "Melee delay" 1 "None" "Rear and critical multipliers are capped at 1.25" "Combat/Melee.dm"
Add-SkillRow "Lunge" "/obj/Lunge" "Standalone verb/hotbar" "Physical" 5 1 0 0 "3x GMD(24)" "Lunge refire" "Windup + travel" 19 "None" "Explicit factor; no hidden base multiplier" "Combat/Melee.dm"
Add-SkillRow "Wolf Fang Fist" "/obj/WolfFangFist" "Learnable" "Physical" 1 5 0 0 "20 stamina on total miss" 20 "Windup + advancing combo" 19 "None" "Five-hit budget 5" "SkillEngine.dm; Melee/WolfFangFist.dm"
Add-SkillRow "Hundred Crack Fist" "/obj/Hokuto_Shinken" "Learnable" "Physical" 0.25 24 0 0 "Ki becomes 20% after cast" 0 "6.2s windup; 0.3s/strike" 15 "None" "Exactly 24 attempts; budget 6" "Combat/HokutoShinken.dm"
Add-SkillRow "Dash Attack" "/obj/Dash_Attack" "Learnable" "Physical" "2-8" 1 0 0 "145*sqrt(maxKi/3000)" 10 "Up to 25 steps" 25 "None" "Factor scales 0.25 per completed step; no second BP ratio" "Application/Combat/SkillEngine.dm"
Add-SkillRow "Dropkick" "/obj/Dropkick" "Learnable" "Physical" 8 2 0 0 "25 stamina" 30 "Windup + travel" 19 "None" "Two hits: 5 and 3" "Application/Combat/SkillEngine.dm"
Add-SkillRow "Pressure Punch" "/obj/PressurePunch" "Learnable" "Physical" 6 1 0 0 0 12 "2s" 3 "None" "No flat damage; calculated against the victim" "Combat/Melee/PressurePunch.dm"
Add-SkillRow "Roundhouse Kick" "/obj/RoundhouseKick" "Learnable" "Physical" 4 1 0 0 0 12 "1s" 3 "None" "No flat damage; calculated against the victim" "Combat/Melee/RoundhouseKick.dm"
Add-SkillRow "Rock Throw - Powerful" "/obj/RockThrow" "Learnable" "Physical" 3 1 0 0 40 3 "Instant target resolve" 10 "None" "Strength versus Endurance" "Combat/RockThrow.dm"
Add-SkillRow "Rock Throw - Rapid" "/obj/RockThrow" "Learnable mode" "Physical" 1 1 0 0 16 0 "Instant target resolve" 8 "None" "No cooldown" "Combat/RockThrow.dm"
Add-SkillRow "Rock Slide" "/obj/RockSlide" "Learnable" "Melee" 0.8 5 0 0 150 12 "Up to 15 searches" 8 "None" "Now calculates damage against each victim" "Combat/RockThrow.dm"
Add-SkillRow "Rock Tomb" "/obj/RockTomb" "Learnable" "Physical" 5 1 0 0 100 15 "Instant target resolve" 12 "None" "Mastered splash affects secondary targets only" "Combat/RockThrow.dm"
Add-SkillRow "Blast" "/obj/Attacks/Blast" "Learnable" "Ki" "0.35-0.5" "1-4" 0 "Optional equal splash" "Dynamic" "Dynamic" "No charge" 47 "None" "Shared factor budget 4" "ProjectileSystem/Blasts.dm; SkillEngine.dm"
Add-SkillRow "Big Bang Attack" "/obj/Attacks/Big_Bang_Attack" "Learnable" "Ki" 22 2 0 "22 splash" 80 0 "18*SD(.4)" 60 "None" "22 direct + 22 splash; budget 44" "SkillEngine.dm"
Add-SkillRow "Charge" "/obj/Attacks/Charge" "Learnable" "Ki" 4 2 0 "4 splash" 20 0 "7.5*SD(.6)" 47 "None" "4 direct + 4 splash" "SkillEngine.dm"
Add-SkillRow "Cyber Charge" "/obj/Attacks/Cyber_Charge" "Module grant" "Ki" 2.5 2 0 "2.5 splash" 10 0 "5*SD(.6)" 100 "None" "2.5 direct + 2.5 splash" "SkillEngine.dm; Cybernetics.dm"
Add-SkillRow "Kienzan" "/obj/Attacks/Kienzan" "Learnable" "Ki" 6 1 0 0 100 0 "12*SD(.3)" 180 "None" "Piercing, guided and owner-immune" "SkillEngine.dm; Blasts.dm"
Add-SkillRow "Sokidan" "/obj/Attacks/Sokidan" "Learnable" "Ki" 3.5 2 0 "3.5 splash" 20 2 "7*SD(.7)" 180 "None" "Guided, owner-immune; budget 7" "SkillEngine.dm; SkillControllers.dm"
Add-SkillRow "Spin Blast" "/obj/Attacks/Spin_Blast" "Learnable" "Ki" 0.5 4 0 "Visual only" 10 0 "No charge" 100 "None" "Four shots" "ProjectileSystem/Blasts.dm"
Add-SkillRow "Makosen" "/obj/Attacks/Makosen" "Learnable" "Ki" 0.4 20 0 0 150 0 "14*SD(.4)" 35 "None" "Nondeflectable barrage capped at 20" "SkillEngine.dm; Blasts.dm"
Add-SkillRow "Scatter Shot" "/obj/Attacks/Scatter_Shot" "Learnable" "Ki" 0.3 "Dynamic" 0 "0.3 splash" 30 60 "0.3ds between shots" 70 "None" "Shared factor budget 18 per victim" "SkillEngine.dm; Blasts.dm"
Add-SkillRow "Genocide" "/obj/Attacks/Genocide" "Learnable" "Ki" 0.25 12 0 0 3 0 "5ds between shots" 500 "None" "Activation capped at 12" "ProjectileSystem/Blasts.dm"
Add-SkillRow "Buster Barrage" "/obj/Attacks/Buster_Barrage" "Learnable" "Ki" 0.4 20 0 "10% equal splash" 9 0 "Per-shot interval" 250 "None" "20 shots; shared budget 16" "ProjectileSystem/Blasts.dm"
Add-SkillRow "Attack Barrier" "/obj/Attacks/Attack_Barrier" "Learnable" "Ki" 0.2 20 0 0 6 0 "Initial delay" 3 "None" "Activation capped at 20 orbs" "ProjectileSystem/Blasts.dm; SkillEngine.dm"
Add-SkillRow "Noob Ray" "/obj/Attacks/Noob_Ray" "Unobtainable normally" "Ki Beam" 52 1 1 0 "Recalculated 500.8" 0 "Beam toggle" 50 "None" "Highest factor; only acquisition is commented" "ProjectileSystem/Beams.dm"
Add-SkillRow "Cyber Laser" "/obj/Attacks/Laser_Beam" "Module grant" "Ki Beam" 4 1 1 0 "Recalculated 27.2" 0 "Beam toggle" 60 "None" "Cumulative beam budget 4" "ProjectileSystem/Beams.dm"
Add-SkillRow "Beam" "/obj/Attacks/Beam" "Learnable" "Ki Beam" 3 1 1.5 0 "Recalculated 4.3" 0 "Beam toggle" 40 "None" "Cumulative beam budget 3" "ProjectileSystem/Beams.dm"
Add-SkillRow "Death Beam" "/obj/Attacks/Ray" "Learnable/granted" "Ki Beam" 3 1 1 0 "Recalculated 5" 0 "Beam toggle" 30 "None" "Cumulative beam budget 3" "ProjectileSystem/Beams.dm"
Add-SkillRow "Makankosappo" "/obj/Attacks/Piercer" "Learnable/granted" "Ki Beam" 5 1 1 0 "Recalculated 13.7" 0 "Beam toggle" 60 "None" "Shield pierce; no range damage growth" "ProjectileSystem/Beams.dm"
Add-SkillRow "Kamehameha" "/obj/Attacks/Kamehameha" "Granted" "Ki Beam" 8 1 1.5 0 "Recalculated 12.9" 0 "Beam toggle" 40 "None" "Cumulative beam budget 8" "ProjectileSystem/Beams.dm"
Add-SkillRow "Dodompa" "/obj/Attacks/Dodompa" "Granted" "Ki Beam" 5 1 1.2 0 "Recalculated 8.6" 0 "Beam toggle" 32 "None" "Range affects utility only" "ProjectileSystem/Beams.dm"
Add-SkillRow "Final Flash" "/obj/Attacks/Final_Flash" "Granted" "Ki Beam" 12 1 2 0 "Recalculated 21.2" 0 "Beam toggle" 60 "None" "Cumulative beam budget 12" "ProjectileSystem/Beams.dm"
Add-SkillRow "Galick Gun" "/obj/Attacks/Garlic_Gun" "Granted" "Ki Beam" 7 1 1.8 0 "Recalculated 9" 0 "Beam toggle" 40 "None" "Cumulative beam budget 7" "ProjectileSystem/Beams.dm"
Add-SkillRow "Masenko" "/obj/Attacks/Masenko" "Granted" "Ki Beam" 6 1 1.4 0 "Recalculated 9.1" 0 "Beam toggle" 32 "None" "Range affects utility only" "ProjectileSystem/Beams.dm"
Add-SkillRow "Explosion" "/obj/Attacks/Explosion" "Learnable" "Ki AoE" 3 1 0 5 150 "2*SD(.35)" "No charge" 20 "None" "Force versus Resistance" "SkillEngine.dm"
Add-SkillRow "Shockwave" "/obj/Attacks/Shockwave" "Learnable" "Hybrid AoE" 0.5 7 0 10 15 "7*SD(.25)" "No charge" 10 "None" "Half physical and half Ki per pulse" "SkillEngine.dm"
Add-SkillRow "Kikoho" "/obj/Attacks/Kikoho" "Granted" "Ki" 7 1 0 0 100 0 "0.5*(5+11*SD(.4))" 11 "None" "Instant hit; separate self-damage pool +24" "Combat/KiSkills/Kikoho2016.dm"
Add-SkillRow "Omega Bomb" "/obj/Attacks/Genki_Dama" "Granted" "Ki charge" "4-15" 2 0 5 1000 90 "25-100% charge" 100 "None" "Equal direct+splash; total 8-30" "Combat/KiSkills/SpiritBomb2016.dm"
Add-SkillRow "Death Ball" "/obj/Attacks/Genki_Dama/Death_Ball" "Learnable/granted" "Ki charge" "2.5-10" 1 0 0 750 0 "25-100% charge" 100 "None" "Explicit capped interpolation" "Combat/KiSkills/DeathBall2017.dm"
Add-SkillRow "Supernova" "/obj/Attacks/Genki_Dama/Supernova" "Learnable/granted" "Ki charge" "2-5" 2 0 5 500 0 "25-100% charge" 100 "None" "Equal direct+splash; total 4-10" "Combat/KiSkills/Supernova.dm"
Add-SkillRow "Final Explosion" "/obj/Final_Explosion" "Learnable" "Ki AoE" "1-5" 5 0 "Charge-scaled radius" 0 0 "Total 5-25" "Dynamic" "None" "Five stacks; visual range decoupled from damage" "Combat/KiSkills/FinalExplosion.dm"
Add-SkillRow "Self Destruct" "/obj/Self_Destruct" "Learnable/granted" "Ki AoE" 30 1 0 10 "Caster dies" 1200 "No charge" 10 "None" "Rebuild/Regenerate x0.5; no repeated anger hit" "Combat/Skills.dm"
Add-SkillRow "Hakai" "/obj/Hakai" "Granted" "Execution" 0 1 0 0 "25% current Ki" 30 "About 8.5s" 20 "None" "Requires BP >=2.2x target; still forced death" "Combat/KiSkills/Hakai.dm"
Add-SkillRow "Planet Destroy" "/obj/Planet_Destroy" "Learnable/granted" "World Ki hazard" 2 10 0 "Radius 2 events" 0 "Planet 21600" "70*SD(.3)" "Planet" "None" "Shared per-victim hazard budget 20" "WorldMechanics/PlanetDestroy.dm"
$sheets.Add($catalog) | Out-Null

$calculator = New-Sheet "Damage Calculator" @(24, 18, 12, 10, 12, 16, 16, 16, 16, 15, 18, 18, 18, 18) 3
Add-Row $calculator.Rows @((New-Cell "Standardized Damage Calculator" 2), (New-Cell "Uses Combatants rows 4-5 and Settings constants. Custom formulas remain in Skill Catalog." 2))
Add-Row $calculator.Rows @((New-Cell "Outputs exclude dodge/shield/safezone and situational rear/KO/one-shot modifiers." 6))
Add-Row $calculator.Rows @((New-Cell "Skill" 1), (New-Cell "Model" 1), (New-Cell "Factor" 1), (New-Cell "Hits" 1), (New-Cell "MoveDelay" 1), (New-Cell "BP Ratio Term" 1), (New-Cell "Stat Ratio Term" 1), (New-Cell "Off/Def Term" 1), (New-Cell "Segment %" 1), (New-Cell "Per Hit" 1), (New-Cell "Raw Total" 1), (New-Cell "Melee Crit %" 1), (New-Cell "Expected Total" 1), (New-Cell "Notes" 1))
$damageRows = @(
	@("Manual Attack", "Physical", 2.5, 1, 0, "Before rear/critical"), @("Lunge", "Physical", 5, 1, 0, ""),
	@("Wolf Fang Fist", "Physical", 1, 5, 0, "5-hit maximum"), @("Hundred Crack Fist", "Physical", 0.25, 24, 0, "Exact sequence"),
	@("Rock Throw - Powerful", "Physical", 3, 1, 0, ""), @("Rock Throw - Rapid", "Physical", 1, 1, 0, ""),
	@("Rock Slide", "Physical", 0.8, 5, 0, "Maximum hits"), @("Rock Tomb", "Physical", 5, 1, 0, "Primary target"),
	@("Big Bang Attack", "Ki", 22, 2, 0, "Direct plus splash"), @("Charge", "Ki", 4, 2, 0, "Direct plus splash"),
	@("Cyber Charge", "Ki", 2.5, 2, 0, "Direct plus splash"), @("Kienzan", "Ki", 6, 1, 0, "Owner-immune"),
	@("Sokidan", "Ki", 3.5, 2, 0, "Direct plus splash; owner-immune"), @("Spin Blast", "Ki", 0.5, 4, 0, "Direct only"),
	@("Makosen", "Ki", 0.4, 20, 0, "Emission cap"), @("Scatter Shot", "Ki", 0.3, 40, 0, "Budget caps actual total at 18"),
	@("Buster Barrage", "Ki", 0.4, 20, 0, "Budget caps actual total at 16"), @("Attack Barrier", "Ki", 0.2, 20, 0, "Emission cap"),
	@("Noob Ray", "Ki", 52, 1, 0, "Cumulative beam factor"), @("Cyber Laser", "Ki", 4, 1, 0, "Cumulative beam factor"),
	@("Beam", "Ki", 3, 1, 0, "Cumulative beam factor"), @("Death Beam", "Ki", 3, 1, 0, "Cumulative beam factor"),
	@("Makankosappo", "Ki", 5, 1, 0, "Cumulative beam factor"), @("Kamehameha", "Ki", 8, 1, 0, "Cumulative beam factor"),
	@("Dodompa", "Ki", 5, 1, 0, "Cumulative beam factor"), @("Final Flash", "Ki", 12, 1, 0, "Cumulative beam factor"),
	@("Galick Gun", "Ki", 7, 1, 0, "Cumulative beam factor"), @("Masenko", "Ki", 6, 1, 0, "Cumulative beam factor")
)
foreach ($entry in $damageRows) {
	$rowNumber = $calculator.Rows.Count + 1
	$bpFormula = "POWER(Combatants!`$E`$4/Combatants!`$E`$5,Settings!`$B`$6)"
	$strFormula = "IF(B$rowNumber=`"Physical`",POWER(2*Combatants!`$H`$4/(Combatants!`$H`$4+Combatants!`$I`$5),Settings!`$B`$7),POWER(2*Combatants!`$J`$4/(Combatants!`$J`$4+Combatants!`$K`$5),Settings!`$B`$7))"
	$defFormula = "1"
	$segmentFormula = "0"
	$perHitFormula = "C$rowNumber*F$rowNumber*G$rowNumber*Combatants!`$O`$5"
	$critFormula = "0"
	$expectedFormula = "K$rowNumber"
	Add-Row $calculator.Rows @((New-Cell $entry[0]), (New-Cell $entry[1]), (New-Cell $entry[2] 3), (New-Cell $entry[3] 3), (New-Cell $entry[4] 3), (New-FormulaCell $bpFormula), (New-FormulaCell $strFormula), (New-FormulaCell $defFormula), (New-FormulaCell $segmentFormula), (New-FormulaCell $perHitFormula), (New-FormulaCell "J$rowNumber*D$rowNumber"), (New-FormulaCell $critFormula), (New-FormulaCell $expectedFormula), (New-Cell $entry[5] 5))
}
$sheets.Add($calculator) | Out-Null

$validation = New-Sheet "Validation" @(28, 18, 18, 18, 72) 2
Add-Row $validation.Rows @((New-Cell "Validation Scenarios" 2), (New-Cell "Equal-BP/equal-stat expected raw values before crit and situational modifiers." 2))
Add-Row $validation.Rows @((New-Cell "Scenario" 1), (New-Cell "Expected" 1), (New-Cell "Workbook result" 1), (New-Cell "Difference" 1), (New-Cell "Reason" 1))
$validationRows = @(
	@("Manual Attack equal stats", 2.5, 4, "Explicit physical factor"),
	@("Lunge equal stats", 5, 5, "Explicit physical factor"),
	@("Wolf Fang per hit", 1, 6, "Per-hit factor"),
	@("Wolf Fang five hits", 5, 6, "Per hit x5"),
	@("Hundred Crack per hit", 0.25, 7, "Per-hit factor"),
	@("Hundred Crack minimum total", 6, 7, "Per hit x24"),
	@("Rock Throw powerful", 3, 8, "Explicit physical factor"),
	@("Charge direct plus splash", 8, 13, "4 x2"),
	@("Big Bang direct plus splash", 44, 12, "22 x2")
)
foreach ($row in $validationRows) {
	$resultFormula = if ($row[0] -like "*five hits*") { "'Damage Calculator'!J$($row[2])*5" } elseif ($row[0] -like "*minimum total*") { "'Damage Calculator'!J$($row[2])*24" } elseif ($row[0] -like "*plus splash*") { "'Damage Calculator'!J$($row[2])*2" } else { "'Damage Calculator'!J$($row[2])" }
	$rowNumber = $validation.Rows.Count + 1
	Add-Row $validation.Rows @((New-Cell $row[0]), (New-Cell $row[1]), (New-FormulaCell $resultFormula), (New-FormulaCell "C$rowNumber-B$rowNumber"), (New-Cell $row[3] 5))
}
$sheets.Add($validation) | Out-Null

$sources = New-Sheet "Sources" @(44, 100) 2
Add-Row $sources.Rows @((New-Cell "Primary Source Index" 2), (New-Cell "Repository-relative paths and modeled responsibility." 2))
Add-Row $sources.Rows @((New-Cell "Path" 1), (New-Cell "Modeled data" 1))
$sourceRows = @(
	@("src/Code/Combat/DamageScaling.dm", "Central BP/stat formula and per-target factor budgets"),
	@("src/Code/CoreFunctions/Vars/GlobalCombatSettings.dm", "Base damage, BP/stat exponents and global combat constants"),
	@("src/Code/Combat/Melee.dm", "Melee damage, accuracy, crit, skill drain and incoming TakeDamage modifiers"),
	@("src/Code/ProjectileSystem/Projectiles.dm", "Direct projectile, explosion, beam collision and shield formulas"),
	@("src/Code/ProjectileSystem/BeamCore.dm", "Beam segment percent, range behavior and drain"),
	@("src/Code/ProjectileSystem/Beams.dm", "Beam WaveMult, MoveDelay, range and deflection parameters"),
	@("src/Code/ProjectileSystem/Blasts.dm", "Projectile skill parameters and normalized 0.5ds Ki cadence"),
	@("src/Code/Application/Combat/SkillEngine.dm", "Current cast paths, projectile percentages and melee special routing"),
	@("src/Code/Application/Combat/SkillControllers.dm", "Sokidan/Kienzan guided movement"),
	@("src/Code/Combat/RockThrow.dm", "Rock skill damage, cost, cooldown and targeting"),
	@("src/Code/Combat/HokutoShinken.dm", "Hundred Crack Fist hit count and per-hit multiplier"),
	@("src/Code/BackgroundCode/StatLoop.dm", "get_bp ordering, powerup, anger, cyber and late multipliers"),
	@("src/Code/Technology/Cybernetics.dm", "Module stat effects, Overdrive and cyber skill grants"),
	@("src/Code/CharacterCreation/NexusCharacterCreation.dm", "Race creation budgets and presets"),
	@("src/Code/CoreFunctions/StatPoints.dm", "Race caps and additional profile data"),
	@("src/Code/PlayerMechanics/Ascension.dm", "SSJ, USSJ, Third Eye and Frost form effects"),
	@("src/Code/PlayerMechanics/GodKi.dm", "God BP formula and mastery scaling"),
	@("src/Code/Races/UltraInstinct.dm", "Ultra Instinct BP/stat/cost effects"),
	@("src/Code/Combat/KiSkills", "Spirit Bomb family, Kikoho, Final Explosion and Hakai custom formulas")
)
foreach ($row in $sourceRows) { Add-Row $sources.Rows @((New-Cell $row[0] 5), (New-Cell $row[1] 5)) }
$sheets.Add($sources) | Out-Null

$outputDirectory = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $outputDirectory)) { throw "Workbook parent directory does not exist: $outputDirectory" }
if (Test-Path -LiteralPath $OutputPath) { Remove-Item -LiteralPath $OutputPath -Force }

$stylesXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <fonts count="4">
    <font><sz val="10"/><name val="Aptos"/></font>
    <font><b/><color rgb="FFFFFFFF"/><sz val="10"/><name val="Aptos"/></font>
    <font><b/><color rgb="FFFFFFFF"/><sz val="14"/><name val="Aptos Display"/></font>
    <font><b/><color rgb="FF16324F"/><sz val="10"/><name val="Aptos"/></font>
  </fonts>
  <fills count="6">
    <fill><patternFill patternType="none"/></fill>
    <fill><patternFill patternType="gray125"/></fill>
    <fill><patternFill patternType="solid"><fgColor rgb="FF173B57"/><bgColor indexed="64"/></patternFill></fill>
    <fill><patternFill patternType="solid"><fgColor rgb="FFFFE7A3"/><bgColor indexed="64"/></patternFill></fill>
    <fill><patternFill patternType="solid"><fgColor rgb="FFDFF3E4"/><bgColor indexed="64"/></patternFill></fill>
    <fill><patternFill patternType="solid"><fgColor rgb="FFE8F1F8"/><bgColor indexed="64"/></patternFill></fill>
  </fills>
  <borders count="2">
    <border><left/><right/><top/><bottom/><diagonal/></border>
    <border><left style="thin"><color rgb="FFD0D7DE"/></left><right style="thin"><color rgb="FFD0D7DE"/></right><top style="thin"><color rgb="FFD0D7DE"/></top><bottom style="thin"><color rgb="FFD0D7DE"/></bottom><diagonal/></border>
  </borders>
  <cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>
  <cellXfs count="7">
    <xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0"><alignment vertical="top"/></xf>
    <xf numFmtId="0" fontId="1" fillId="2" borderId="1" xfId="0" applyFill="1" applyFont="1"><alignment vertical="center" wrapText="1"/></xf>
    <xf numFmtId="0" fontId="2" fillId="2" borderId="1" xfId="0" applyFill="1" applyFont="1"><alignment vertical="center" wrapText="1"/></xf>
    <xf numFmtId="0" fontId="3" fillId="3" borderId="1" xfId="0" applyFill="1"><alignment vertical="top"/></xf>
    <xf numFmtId="0" fontId="3" fillId="4" borderId="1" xfId="0" applyFill="1"><alignment vertical="top"/></xf>
    <xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0"><alignment vertical="top" wrapText="1"/></xf>
    <xf numFmtId="0" fontId="3" fillId="5" borderId="1" xfId="0" applyFill="1"><alignment vertical="top" wrapText="1"/></xf>
  </cellXfs>
  <cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>
</styleSheet>
'@

$stream = [System.IO.File]::Open($OutputPath, [System.IO.FileMode]::CreateNew)
$archive = [System.IO.Compression.ZipArchive]::new($stream, [System.IO.Compression.ZipArchiveMode]::Create, $false)
try {
	$contentTypes = [System.Text.StringBuilder]::new()
	[void]$contentTypes.Append('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/><Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/><Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>')
	for ($i = 1; $i -le $sheets.Count; $i++) { [void]$contentTypes.Append("<Override PartName=`"/xl/worksheets/sheet$i.xml`" ContentType=`"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml`"/>") }
	[void]$contentTypes.Append('</Types>')
	Add-ZipEntry $archive "[Content_Types].xml" $contentTypes.ToString()
	Add-ZipEntry $archive "_rels/.rels" '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/><Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/></Relationships>'

	$workbook = [System.Text.StringBuilder]::new()
	[void]$workbook.Append('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><bookViews><workbookView/></bookViews><sheets>')
	$workbookRels = [System.Text.StringBuilder]::new()
	[void]$workbookRels.Append('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">')
	for ($i = 0; $i -lt $sheets.Count; $i++) {
		$sheetId = $i + 1
		$relationshipId = $i + 1
		$name = Escape-Xml $sheets[$i].Name
		[void]$workbook.Append("<sheet name=`"$name`" sheetId=`"$sheetId`" r:id=`"rId$relationshipId`"/>")
		[void]$workbookRels.Append("<Relationship Id=`"rId$relationshipId`" Type=`"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet`" Target=`"worksheets/sheet$sheetId.xml`"/>")
		Add-ZipEntry $archive "xl/worksheets/sheet$sheetId.xml" (ConvertTo-WorksheetXml $sheets[$i])
	}
	$styleRelationshipId = $sheets.Count + 1
	[void]$workbook.Append('</sheets><calcPr calcId="191029" fullCalcOnLoad="1" forceFullCalc="1"/></workbook>')
	[void]$workbookRels.Append("<Relationship Id=`"rId$styleRelationshipId`" Type=`"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles`" Target=`"styles.xml`"/></Relationships>")
	Add-ZipEntry $archive "xl/workbook.xml" $workbook.ToString()
	Add-ZipEntry $archive "xl/_rels/workbook.xml.rels" $workbookRels.ToString()
	Add-ZipEntry $archive "xl/styles.xml" $stylesXml
	$timestamp = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
	Add-ZipEntry $archive "docProps/core.xml" "<?xml version=`"1.0`" encoding=`"UTF-8`" standalone=`"yes`"?><cp:coreProperties xmlns:cp=`"http://schemas.openxmlformats.org/package/2006/metadata/core-properties`" xmlns:dc=`"http://purl.org/dc/elements/1.1/`" xmlns:dcterms=`"http://purl.org/dc/terms/`" xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`"><dc:title>Nexus Exodus Skill Damage Balance</dc:title><dc:creator>OpenCode</dc:creator><dcterms:created xsi:type=`"dcterms:W3CDTF`">$timestamp</dcterms:created><dcterms:modified xsi:type=`"dcterms:W3CDTF`">$timestamp</dcterms:modified></cp:coreProperties>"
	Add-ZipEntry $archive "docProps/app.xml" "<?xml version=`"1.0`" encoding=`"UTF-8`" standalone=`"yes`"?><Properties xmlns=`"http://schemas.openxmlformats.org/officeDocument/2006/extended-properties`" xmlns:vt=`"http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes`"><Application>Nexus Exodus Balance Generator</Application><TitlesOfParts><vt:vector size=`"$($sheets.Count)`" baseType=`"lpstr`">$([string]::Join('', @($sheets | ForEach-Object { "<vt:lpstr>$(Escape-Xml $_.Name)</vt:lpstr>" })))</vt:vector></TitlesOfParts></Properties>"
} finally {
	$archive.Dispose()
	$stream.Dispose()
}

$validationStream = [System.IO.File]::OpenRead($OutputPath)
$validationArchive = [System.IO.Compression.ZipArchive]::new($validationStream, [System.IO.Compression.ZipArchiveMode]::Read, $false)
try {
	$requiredEntries = @("[Content_Types].xml", "xl/workbook.xml", "xl/styles.xml", "xl/worksheets/sheet1.xml")
	foreach ($entryName in $requiredEntries) {
		if (-not $validationArchive.GetEntry($entryName)) { throw "Generated workbook is missing $entryName" }
	}
} finally {
	$validationArchive.Dispose()
	$validationStream.Dispose()
}

Get-Item -LiteralPath $OutputPath
