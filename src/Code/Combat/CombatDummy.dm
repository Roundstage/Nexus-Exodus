mob/CombatDummy
	name = "Combat Dummy"
	icon = 'BaseHumanPale.dmi'
	Race = "Human"
	Health = 100
	base_bp = 1000
	BP = 1000
	Str = 100
	End = 100
	Spd = 100
	Pow = 100
	Res = 100
	Off = 100
	Def = 100
	max_ki = 1000
	Ki = 1000
	max_stamina = 100
	stamina = 100
	BPpcnt = 100
	Savable = 0
	Savable_NPC = 0
	Spawn_Timer = 0
	attackable = 1
	Docile = 1

	New()
		. = ..()
		initializeVitalsHud()

	Del()
		removeVitalsHud()
		. = ..()

	shouldShowOverheadHealthHud()
		return TRUE

	proc/setBattlePower(value)
		if(!nexusIsFiniteNumber(value)) return FALSE
		base_bp = max(1, value)
		BP = base_bp * max(BPpcnt, 0.01) / 100
		return TRUE

	proc/setPowerup(value)
		if(!nexusIsFiniteNumber(value)) return FALSE
		BPpcnt = max(0.01, value)
		BP = base_bp * BPpcnt / 100
		return TRUE

	proc/resetCombatDummy()
		bleed_damage = 0
		Poisoned = 0
		Health = 100
		Ki = max_ki
		stamina = max_stamina
		KO = FALSE
		Dead = FALSE
		Frozen = FALSE
		move = 1
		icon_state = initial(icon_state)
		updateOverheadHealthHud()

	TakeDamage(dmg = 0, stun_damage_mod = 0.6, knockback = 0, mob/attacker, attack_name)
		. = ..()
		if(Health <= 0) resetCombatDummy()

	KO(mob/attacker, allow_anger = TRUE, combat_ko_handled = FALSE, mob/victim = src)
		resetCombatDummy()

	Death(mob/attacker, force_death = 0, drone_sd = 0, lose_hero = 1, lose_immortality = 1)
		resetCombatDummy()

mob/Admin2/verb/spawnCombatDummy()
	set name = "Spawn Combat Dummy"
	set category = "Admin"
	var/turf/spawn_loc = get_step(src, dir)
	if(!spawn_loc || spawn_loc.density) spawn_loc = base_loc()
	if(!spawn_loc) return
	var/mob/CombatDummy/dummy = new(spawn_loc)
	dummy.update_area()
	admin_blame(src, "[key] spawned a combat dummy at [dummy.x],[dummy.y],[dummy.z].")
	openCombatDummyController(dummy)

mob/Admin2/verb/controlCombatDummy(mob/CombatDummy/dummy in world)
	set name = "Control Combat Dummy"
	set category = "Admin"
	openCombatDummyController(dummy)

mob/proc/openCombatDummyController(mob/CombatDummy/dummy)
	if(AdminLevel() < 2 || !dummy) return
	while(src && client && dummy && AdminLevel() >= 2)
		var/choice = input(src, "Choose a value to configure on [dummy].", "Combat Dummy Controller") as null|anything in list(
			"Battle Power", "Combat Stats", "Health", "Energy", "Stamina", "Powerup", "Restore", "Rename", "Delete")
		if(!choice || !dummy || AdminLevel() < 2) return
		switch(choice)
			if("Battle Power")
				var/new_bp = input(src, "Set the dummy's base battle power.", "Battle Power", dummy.base_bp) as null|num
				if(isnull(new_bp)) continue
				if(!dummy || AdminLevel() < 2) return
				if(!dummy.setBattlePower(new_bp))
					alert(src, "Battle Power must be a finite number.")
					continue
				admin_blame(src, "[key] set [dummy]'s base battle power to [dummy.base_bp].")
			if("Combat Stats")
				var/stat_name = input(src, "Choose a combat stat.", "Combat Stats") as null|anything in list(
					"Strength", "Endurance", "Speed", "Force", "Resistance", "Offense", "Defense")
				if(!stat_name) continue
				if(!dummy || AdminLevel() < 2) return
				var/current_value
				switch(stat_name)
					if("Strength") current_value = dummy.Str
					if("Endurance") current_value = dummy.End
					if("Speed") current_value = dummy.Spd
					if("Force") current_value = dummy.Pow
					if("Resistance") current_value = dummy.Res
					if("Offense") current_value = dummy.Off
					if("Defense") current_value = dummy.Def
				var/new_value = input(src, "Set [stat_name].", stat_name, current_value) as null|num
				if(isnull(new_value)) continue
				if(!dummy || AdminLevel() < 2) return
				if(!nexusIsFiniteNumber(new_value))
					alert(src, "[stat_name] must be a finite number.")
					continue
				new_value = max(0.01, new_value)
				switch(stat_name)
					if("Strength") dummy.Str = new_value
					if("Endurance") dummy.End = new_value
					if("Speed") dummy.Spd = new_value
					if("Force") dummy.Pow = new_value
					if("Resistance") dummy.Res = new_value
					if("Offense") dummy.Off = new_value
					if("Defense") dummy.Def = new_value
				admin_blame(src, "[key] set [dummy]'s [stat_name] to [new_value].")
			if("Health")
				var/new_health = input(src, "Set current health percentage.", "Health", dummy.Health) as null|num
				if(isnull(new_health)) continue
				if(!dummy || AdminLevel() < 2) return
				if(!nexusIsFiniteNumber(new_health))
					alert(src, "Health must be a finite number.")
					continue
				dummy.Health = Clamp(new_health, 0, 100)
				dummy.updateOverheadHealthHud()
				admin_blame(src, "[key] set [dummy]'s health to [dummy.Health] percent.")
			if("Energy")
				var/new_max_energy = input(src, "Set maximum Energy.", "Energy", dummy.max_ki) as null|num
				if(isnull(new_max_energy)) continue
				if(!dummy || AdminLevel() < 2) return
				if(!nexusIsFiniteNumber(new_max_energy))
					alert(src, "Maximum Energy must be a finite number.")
					continue
				new_max_energy = max(1, new_max_energy)
				var/new_energy = input(src, "Set current Energy.", "Energy", min(dummy.Ki, new_max_energy)) as null|num
				if(isnull(new_energy)) continue
				if(!dummy || AdminLevel() < 2) return
				if(!nexusIsFiniteNumber(new_energy))
					alert(src, "Current Energy must be a finite number.")
					continue
				dummy.max_ki = new_max_energy
				dummy.Ki = Clamp(new_energy, 0, dummy.max_ki)
				admin_blame(src, "[key] set [dummy]'s Energy to [dummy.Ki]/[dummy.max_ki].")
			if("Stamina")
				var/new_max_stamina = input(src, "Set maximum stamina.", "Stamina", dummy.max_stamina) as null|num
				if(isnull(new_max_stamina)) continue
				if(!dummy || AdminLevel() < 2) return
				if(!nexusIsFiniteNumber(new_max_stamina))
					alert(src, "Maximum stamina must be a finite number.")
					continue
				new_max_stamina = max(1, new_max_stamina)
				var/new_stamina = input(src, "Set current stamina.", "Stamina", min(dummy.stamina, new_max_stamina)) as null|num
				if(isnull(new_stamina)) continue
				if(!dummy || AdminLevel() < 2) return
				if(!nexusIsFiniteNumber(new_stamina))
					alert(src, "Current stamina must be a finite number.")
					continue
				dummy.max_stamina = new_max_stamina
				dummy.stamina = Clamp(new_stamina, 0, dummy.max_stamina)
				admin_blame(src, "[key] set [dummy]'s stamina to [dummy.stamina]/[dummy.max_stamina].")
			if("Powerup")
				var/new_powerup = input(src, "Set powerup percentage. Values above 100 are allowed.", "Powerup", dummy.BPpcnt) as null|num
				if(isnull(new_powerup)) continue
				if(!dummy || AdminLevel() < 2) return
				if(!dummy.setPowerup(new_powerup))
					alert(src, "Powerup must be a finite number.")
					continue
				admin_blame(src, "[key] set [dummy]'s powerup to [dummy.BPpcnt] percent.")
			if("Restore")
				if(!dummy || AdminLevel() < 2) return
				dummy.resetCombatDummy()
				admin_blame(src, "[key] restored [dummy].")
			if("Rename")
				var/new_name = input(src, "Set the dummy's display name.", "Rename Dummy", dummy.name) as null|text
				if(isnull(new_name)) continue
				if(!dummy || AdminLevel() < 2) return
				new_name = copytext(html_encode(new_name), 1, 51)
				if(!length(new_name)) continue
				dummy.name = new_name
				admin_blame(src, "[key] renamed a combat dummy to [dummy.name].")
			if("Delete")
				if(alert(src, "Delete [dummy]?", "Combat Dummy Controller", "No", "Yes") != "Yes") continue
				if(!dummy || AdminLevel() < 2) return
				admin_blame(src, "[key] deleted [dummy].")
				del(dummy)
				return
