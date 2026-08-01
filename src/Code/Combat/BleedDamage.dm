mob/var
	bleed_damage = 0
	tmp
		bleed_loop
		last_bleed_apply = 0 //world.time
		mob/bleed_attacker
		bleed_attack_name = "Bleed"

mob/proc
	BleedDamage(n = 0, mob/attacker, attack_name = "Bleed")
		last_bleed_apply = world.time
		bleed_damage = n
		if(attacker) bleed_attacker = attacker
		if(attack_name) bleed_attack_name = "[attack_name]"
		BleedLoop()

	BleedLoop()
		set waitfor=0
		if(bleed_loop) return
		bleed_loop=1

		while(bleed_damage > 0)
			if(rp_mode)
				sleep(10)
				continue
			if(bleed_damage > 300) bleed_damage = 300
			var/dmg = 1 + (bleed_damage / 50)
			if(dmg < 1) dmg = 1
			if(dmg > 8) dmg = 8 //can only bleed out so fast
			if(KO) dmg *= 3
			if(dmg > bleed_damage) dmg = bleed_damage
			bleed_damage -= dmg
			Health -= dmg
			gainAngerFromDamage(dmg)
			showDamageIndicator(dmg, "#d93452")
			updateOverheadHealthHud()
			queueNexusCombatDamage(bleed_attacker, dmg, bleed_attack_name, "Health")
			if(Health <= 0) KO("low health")

			sleep(10)

			if(bleed_damage <= 0)
				bleed_damage = 0
				break
			if(world.time - last_bleed_apply > 100 * 10)
				bleed_damage = 0
				break

		bleed_loop=0
		bleed_attacker = null
		bleed_attack_name = "Bleed"
