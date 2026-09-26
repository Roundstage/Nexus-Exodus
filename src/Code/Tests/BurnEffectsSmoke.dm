mob/NexusSmokeTest/BurnHitProbe
	var/burn_hit_attempts = 0
	var/ignore_damage = FALSE

	tryApplyFireFistBurn(mob/target)
		burn_hit_attempts++
		// Deterministic probe of damaging-hit routing, independent of the random proc roll.
		if(isFireFist) return target.applyBurnEffect(src)
		return FALSE

	TakeDamage(dmg = 0, stun_damage_mod = 0.6, knockback = 0, mob/attacker, attack_name)
		if(ignore_damage) return 0
		return ..()

proc/runBurnEffectsSmokeTests()
	var/mob/NexusSmokeTest/source = new
	var/mob/NexusSmokeTest/target = new
	target.regen = 4
	var/normal_regen = target.RegenMod()
	nexusSmokeAssert("Burning" in icon_states('src/Icons/NexusIntegrated/Attacks/Effects/RTStatusEffects.dmi'), "RPT burn icon is missing its animated Burning state")
	nexusSmokeAssert(target.applyBurnEffect(source), "normal target rejected Burn")
	var/first_tick = target.burn_next_tick
	nexusSmokeAssert(target.BurnStack == 1 && target.isBurning && (target in nexus_status_effect_mobs), "Burn was not registered with an active stack")
	nexusSmokeAssertNear(target.RegenMod(), normal_regen * 0.7, 0.0001, "Burn does not reduce effective Health regeneration by 30%")
	nexusSmokeAssert(target.regen == 4 && target.Health == 100, "Burn changed a base stat or dealt damage before its first tick")
	target.applyBurnEffect(source)
	target.try_applying_burn_effect()
	nexusSmokeAssert(target.BurnStack == 2 && target.burn_next_tick == first_tick, "reapplying Burn reset the tick schedule or lost a stack")
	nexusSmokeAssertNear(target.RegenMod(), normal_regen * 0.7, 0.0001, "Burn stacks compounded the regeneration penalty")
	target.overlays.Cut()
	target.rebuildPlayerAppearance("burn smoke rebuild")
	target.rebuildPlayerAppearance("burn smoke repeat")
	nexusSmokeAssert(countAppearanceSmokeIcon(target, 'src/Icons/NexusIntegrated/Attacks/Effects/RTStatusEffects.dmi') == 1, "appearance rebuild lost or duplicated the burn overlay")

	var/savefile/burn_save = new
	target.Write(burn_save)
	var/mob/NexusSmokeTest/loaded = new
	loaded.Read(burn_save)
	nexusSmokeAssert(loaded.BurnStack == 2 && loaded.burn_effect_running && loaded.regen == 4, "save/load lost active Burn or saved reduced base regeneration")
	nexusSmokeAssert(countAppearanceSmokeIcon(loaded, 'src/Icons/NexusIntegrated/Attacks/Effects/RTStatusEffects.dmi') == 1, "save/load duplicated the burn overlay")
	loaded.clearNexusStatusEffects()
	del(loaded)

	target.processNexusStatusEffects(first_tick - 1)
	nexusSmokeAssert(target.Health == 100, "Burn ticked too early")
	target.processNexusStatusEffects(first_tick)
	target.processNexusStatusEffects(first_tick)
	nexusSmokeAssert(target.Health == 97 && target.BurnStack == 1, "Burn missed or duplicated its first 3-Health tick")
	target.regen = 6
	target.processNexusStatusEffects(first_tick + 20)
	nexusSmokeAssert(target.Health == 94 && !target.isBurning && !target.BurnStack && !(target in nexus_status_effect_mobs), "Burn did not expire after consuming its stacks")
	nexusSmokeAssert(target.regen == 6 && target.getBurnRegenerationMultiplier() == 1, "Burn expiry overwrote a regeneration change made during the effect")
	nexusSmokeAssert(!countAppearanceSmokeIcon(target, 'src/Icons/NexusIntegrated/Attacks/Effects/RTStatusEffects.dmi'), "Burn expiry left its overlay behind")

	for(var/protection in list("KO", "rp_mode", "Safezone"))
		target.vars[protection] = TRUE
		nexusSmokeAssert(!target.applyBurnEffect(source), "Burn ignored [protection] protection")
		target.vars[protection] = FALSE
		target.applyBurnEffect(source)
		var/health_before = target.Health
		target.vars[protection] = TRUE
		target.processNexusStatusEffects(target.burn_next_tick)
		nexusSmokeAssert(target.Health == health_before && !target.isBurning && target.getBurnRegenerationMultiplier() == 1, "active Burn did not clear under [protection]")
		target.vars[protection] = FALSE

	var/mob/NexusSmokeTest/DotKnockoutProbe/ko_target = new
	ko_target.Health = 2
	source.sparring_mode = LETHAL_COMBAT
	ko_target.applyBurnEffect(source)
	source.sparring_mode = CASUAL_COMBAT
	ko_target.processNexusStatusEffects(ko_target.burn_next_tick)
	nexusSmokeAssert(ko_target.KO && ko_target.Health == 0 && ko_target.observed_dot_attacker == source && ko_target.observed_combat_mode_override == LETHAL_COMBAT, "Burn crossing zero Health lost its attacker or original combat intent")
	nexusSmokeAssert(!ko_target.isBurning && !ko_target.burn_effect_running, "knockout left Burn running")
	del(ko_target)

	var/mob/NexusSmokeTest/BurnHitProbe/melee_source = new
	var/mob/NexusSmokeTest/BurnHitProbe/melee_target = new
	melee_source.isFireFist = TRUE
	melee_source.applyNexusTechniqueDamage(melee_target, 1, "Test melee", melee_hit = TRUE)
	nexusSmokeAssert(melee_source.burn_hit_attempts == 1 && melee_target.isBurning, "damaging melee techniques did not attempt Fire Fist Burn")
	melee_target.clearBurnEffect()
	melee_target.ignore_damage = TRUE
	melee_source.applyNexusTechniqueDamage(melee_target, 1, "Absorbed melee", melee_hit = TRUE)
	nexusSmokeAssert(melee_source.burn_hit_attempts == 1 && !melee_target.isBurning, "absorbed melee damage still attempted Fire Fist Burn")
	melee_target.ignore_damage = FALSE
	melee_source.applyNexusTechniqueDamage(melee_target, 1, "Ranged technique")
	nexusSmokeAssert(melee_source.burn_hit_attempts == 1 && !melee_target.isBurning, "ranged techniques inherited Fire Fist Burn")
	nexusSmokeAssert(!source.tryApplyFireFistBurn(target), "inactive Fire Fist applied Burn")
	del(melee_target)
	del(melee_source)
	del(target)
	del(source)
	world.log << "NEXUS_BURN_EFFECTS_TESTS_PASSED: RPT overlay, regeneration, stacking, expiry, save/load, protection, knockout and melee routing"
