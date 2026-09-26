mob/NexusSmokeTest/StatScaling
	proc/setStatBuild(list/build, scale = 1)
		for(var/stat_name in build) vars[stat_name] = build[stat_name] * scale

proc/runNexusStatScalingSmokeTests()
	var/mob/NexusSmokeTest/StatScaling/player = new
	var/list/balanced_build = list("Str" = 100, "End" = 100, "Spd" = 100, "Pow" = 100, "Res" = 100, "Off" = 100, "Def" = 100)
	var/list/specialized_build = list("Str" = 180, "End" = 120, "Spd" = 200, "Pow" = 90, "Res" = 80, "Off" = 140, "Def" = 160)
	var/list/builds = list(balanced_build, specialized_build)
	var/list/severities = list(0.2, 0.3, 0.4, 0.5, 0.75, 1)
	for(var/list/build in builds)
		player.setStatBuild(build)
		var/list/base_delays = list()
		for(var/severity in severities) base_delays += player.Speed_delay_mult(severity)
		var/base_critical = player.GetCriticalChance()
		var/base_movement = player.getMovementMaximumVelocity(NORTH)
		var/base_melee = player.Get_melee_delay()
		var/base_flash_step = player.Get_flash_step_delay()
		for(var/scale in list(10, 1000000, 1e30, 1e36))
			player.setStatBuild(build, scale)
			nexusSmokeAssert(nexusIsFiniteNumber(player.Speed_delay_mult()) && nexusIsFiniteNumber(player.GetCriticalChance()), "large finite stats produced invalid combat rates")
			for(var/index in 1 to severities.len)
				nexusSmokeAssertNear(player.Speed_delay_mult(severities[index]), base_delays[index], 0.0001, "uniform stat growth changed a speed-based action delay")
			nexusSmokeAssertNear(player.GetCriticalChance(), base_critical, 0.0001, "uniform stat growth increased critical chance")
			nexusSmokeAssertNear(player.getMovementMaximumVelocity(NORTH), base_movement, 0.0001, "uniform stat growth increased movement speed")
			// TickMult probabilistically rounds adjacent ticks; the input delays above are deterministic.
			nexusSmokeAssertNear(player.Get_melee_delay(), base_melee, world.tick_lag + 0.0001, "uniform stat growth changed melee delay beyond tick rounding")
			nexusSmokeAssertNear(player.Get_flash_step_delay(), base_flash_step, world.tick_lag + 0.0001, "uniform stat growth changed Flash Step delay beyond tick rounding")
			nexusSmokeAssert(player.Spd == build["Spd"] * scale && player.Off == build["Off"] * scale, "rate normalization rewrote saved stats")
			nexusSmokeAssert(player.getMilestonePhysicalDamageStat() == player.Str && player.getMilestoneEffectiveOffense() == player.Off, "rate normalization changed damage or accuracy-contest stats")

	// Exercise the actual gain path, without enabling gains on the server.
	player.setStatBuild(balanced_build)
	var/base_delay = player.Speed_delay_mult()
	var/base_critical = player.GetCriticalChance()
	var/previous_gain = Base_Stat_Gain
	var/previous_record = Stat_Record
	var/list/previous_settings = Stat_Settings
	Base_Stat_Gain = 7000
	Stat_Record = 100
	Stat_Settings = list("No cap" = 1)
	for(var/index in 1 to 100) player.Balanced_Stat_Gain()
	Base_Stat_Gain = previous_gain
	Stat_Record = previous_record
	Stat_Settings = previous_settings
	nexusSmokeAssert(player.Spd > 100 && player.Off > 100, "balanced training fixture did not gain stats")
	nexusSmokeAssertNear(player.Speed_delay_mult(), base_delay, 0.0001, "balanced training accelerated combat")
	nexusSmokeAssertNear(player.GetCriticalChance(), base_critical, 0.0001, "balanced training increased critical chance")
	nexusSmokeAssertNear(base_critical, 4.04, 0.0001, "balanced build lost its starter critical chance")

	player.setStatBuild(balanced_build)
	player.Spd = 200
	nexusSmokeAssert(player.Speed_delay_mult() < base_delay, "Speed specialization no longer improves cadence")
	player.Spd = 1e30
	var/specialist_delay = player.Speed_delay_mult()
	player.Spd = 1e37
	nexusSmokeAssert(nexusIsFiniteNumber(specialist_delay) && specialist_delay > 0, "Speed specialization produced an invalid or zero delay")
	nexusSmokeAssertNear(player.Speed_delay_mult(), specialist_delay, 0.0001, "extreme Speed specialization has no finite limit")
	player.setStatBuild(balanced_build)
	player.Off = 200
	nexusSmokeAssert(player.GetCriticalChance() > base_critical, "Offense specialization no longer improves critical chance")
	player.Off = 1e37
	nexusSmokeAssertNear(player.GetCriticalChance(), 28.04, 0.0001, "raw Offense exceeded its build-share critical limit")

	// Effective-only effects apply above the raw build denominator.
	player.setStatBuild(balanced_build)
	player.milestones_owned = list("versatile_training" = 2, "unencumbered_combatant" = 1)
	nexusSmokeAssert(player.Speed_delay_mult() < base_delay && player.GetCriticalChance() > base_critical, "normalization canceled effective stat milestones")
	player.milestones_owned = list()
	player.nexus_wing_clip_until = world.time + 100
	nexusSmokeAssert(player.Speed_delay_mult() > base_delay, "normalization canceled Wing Clip")
	player.nexus_wing_clip_until = 0
	player.nexus_sand_throw_until = world.time + 100
	nexusSmokeAssert(player.GetCriticalChance() < base_critical, "normalization canceled Sand Throw")
	player.nexus_sand_throw_until = 0
	player.nexus_electric_dot_until = world.time + 100
	nexusSmokeAssert(player.Speed_delay_mult() > base_delay && player.GetCriticalChance() < base_critical, "normalization canceled the electric stat penalty")
	player.nexus_electric_dot_until = 0
	player.arcane_accelerated_until = world.time + 100
	nexusSmokeAssertNear(player.Speed_delay_mult(), base_delay * 0.8, 0.0001, "normalization canceled Accelerate")
	player.arcane_accelerated_until = 0
	player.Spd *= 1.2
	player.Off *= 1.25
	nexusSmokeAssert(player.Speed_delay_mult() < base_delay && player.GetCriticalChance() > base_critical, "normalization canceled a Speed/Offense build buff")
	player.setStatBuild(balanced_build)

	// Weapon Strength must not dilute Speed/Offense; flat critical bonuses still stack.
	var/obj/items/Sword/sword = new(player)
	sword.Damage = 2
	sword.suffix = "Equipped"
	player.equipped_sword = sword
	player.Str *= sword.Damage
	nexusSmokeAssertNear(player.Speed_delay_mult(), base_delay, 0.0001, "weapon Strength diluted the speed rating")
	nexusSmokeAssertNear(player.GetCriticalChance(), base_critical, 0.0001, "weapon Strength diluted the critical rating")
	sword.is_silver = TRUE
	player.milestones_owned = list("keen_edge" = 3)
	player.setNexusStance("critical_edge", 100)
	var/mob/NexusSmokeTest/target = new
	var/obj/items/Armor/Forged/armor = new(target)
	armor.forged_critical_resistance = 8
	armor.suffix = "Equipped"
	target.armor_obj = armor
	nexusSmokeAssertNear(player.GetCriticalChance(), base_critical + 4 + 9 + 15, 0.0001, "normalization changed Silver, Keen Edge or Critical Edge bonuses")
	nexusSmokeAssertNear(player.GetCriticalChance(target), base_critical + 4 + 9 + 15 - 8, 0.0001, "normalization bypassed forged armor critical resistance")
	player.clearNexusStance()
	player.milestones_owned = list()
	player.equipped_sword = null
	del(sword)
	player.setStatBuild(balanced_build)
	nexusSmokeAssert(player.GetCriticalChance(target) == 0, "armor critical resistance produced a negative chance")
	del(armor)
	del(target)

	for(var/stat_name in balanced_build) player.vars[stat_name] = 0
	nexusSmokeAssert(nexusIsFiniteNumber(player.Speed_delay_mult()) && player.Speed_delay_mult() > 0 && nexusIsFiniteNumber(player.GetCriticalChance()), "zero stats caused invalid rate calculations")
	player.Spd = -100
	player.Off = -100
	nexusSmokeAssert(nexusIsFiniteNumber(player.Speed_delay_mult()) && nexusIsFiniteNumber(player.GetCriticalChance()), "negative stats caused invalid rate calculations")
	player.Spd = 1.#INF
	player.Off = 1.#INF
	nexusSmokeAssert(nexusIsFiniteNumber(player.Speed_delay_mult()) && nexusIsFiniteNumber(player.GetCriticalChance()), "non-finite stats escaped the rate guard")
	del(player)
	world.log << "NEXUS_STAT_SCALING_TESTS_PASSED: build proportions, large stats, training, movement, cadence, critical bonuses and debuffs"
