mob/var
	tmp
		last_RockThrow = 0
		last_RockSlide = 0
		last_RockTomb = 0

obj
	RockThrow
		desc = "You throw a rock at your opponent and deal damage with your strength."
		icon = 'ResourceRocks.dmi'
		Cost_To_Learn = 15
		Teach_Timer = 1
		student_point_cost = 15
		repeat_macro = 0
		can_hotbar = 1
		hotbar_type = "Blast"
		
		var/spread_mode = 0 // 0 = single powerful rock, 1 = rapid fire mode

		verb/Hotbar_use()
			set waitfor = 0
			set hidden = 1
			RockThrow()

		verb
			RockThrow()
				set category = "Skills"
				usr.RockThrow()
				
	RockSlide
		desc = "You throw lots of rocks at your opponent and deal damage with your strength. Each projectile is slightly weaker than Rock Throw."
		icon = 'RisingRocks.dmi'
		Cost_To_Learn = 35
		Teach_Timer = 1
		student_point_cost = 35
		repeat_macro = 0
		can_hotbar = 1
		hotbar_type = "Blast"

		verb/Hotbar_use()
			set waitfor = 0
			set hidden = 1
			RockSlide()

		verb
			RockSlide()
				set category = "Skills"
				usr.RockSlide()

	RockTomb
		desc = "You throw a massive rock at your opponent and deal heavy damage with your strength. When mastered this rock explodes!"
		icon = 'RockExplosion.dmi'
		Cost_To_Learn = 50
		Teach_Timer = 1
		student_point_cost = 50
		repeat_macro = 0
		can_hotbar = 1
		hotbar_type = "Blast"
		
		var/mastered = 0

		verb/Hotbar_use()
			set waitfor = 0
			set hidden = 1
			RockTomb()

		verb
			RockTomb()
				set category = "Skills"
				usr.RockTomb()

mob
	proc
		RockThrowFX()
			set waitfor = 0
			var/obj/Effect/e = GetEffect()
			e.loc = loc
			e.icon = 'Dust.dmi'
			CenterIcon(e)
			animate(e, transform * 1.5, alpha = 180, time = 8)
			player_view(15, src) << sound('Throw.ogg', volume = 50)
			sleep(12)
			del(e)

		RockThrow()
			var/obj/RockThrow/skill = locate() in usr
			if(!skill) return
			
			if(!skill.spread_mode)
				// Single powerful rock mode
				if(world.time < last_RockThrow + (30))
					var/seconds_left = (last_RockThrow + (30) - world.time) / 10
					usr << "You can not use Rock Throw for another [round(seconds_left)] seconds"
					return
				if(usr.Ki < 45) return
				if(!CanMeleeFromOtherCauses()) return
				if(usr.cant_blast()) return
				
				last_RockThrow = world.time
				usr.Ki = max(0, usr.Ki - 40)
				
				flick("Blast", usr)
				RockThrowFX()
				
				var/mob/target = getSelectedTarget(max_dist = 10, dir_angle = usr.dir, angle_limit = 30)
				if(target)
					var/dmg = getPhysicalCombatDamage(target, 3)
					var/knockback = get_melee_knockback_distance(target)
					usr << "You throw a rock at [target]!"
					target << "[usr] throws a rock at you!"
					target.TakeDamage(dmg, 1.5)
					target.Knockback(usr, knockback)
					return
				else
					usr << "You throw a rock, but there is no one to hit!"
			else
				// Rapid fire mode
				if(usr.Ki < 16) return
				if(!CanMeleeFromOtherCauses()) return
				if(usr.cant_blast()) return
				
				usr.Ki = max(0, usr.Ki - 16)
				
				flick("Blast", usr)
				
				var/mob/target = getSelectedTarget(max_dist = 8, dir_angle = usr.dir, angle_limit = 30)
				if(target)
					var/dmg = getPhysicalCombatDamage(target, 1)
					var/knockback = get_melee_knockback_distance(target) * 0.5
					usr << "You throw a small rock at [target]!"
					target << "[usr] throws a small rock at you!"
					target.TakeDamage(dmg, 1.0)
					target.Knockback(usr, knockback)
					return
				else
					usr << "You throw a rock, but there is no one to hit!"

		RockSlideFX()
			set waitfor = 0
			var/obj/Effect/e = GetEffect()
			e.loc = loc
			e.icon = 'Dust.dmi'
			CenterIcon(e)
			animate(e, transform * 2, alpha = 220, time = 15)
			sleep(20)
			del(e)

		RockSlide()
			if(world.time < last_RockSlide + (120))
				var/minutes_left = (last_RockSlide + (120) - world.time) / (10 * 60)
				usr << "You can not use Rock Slide for another [round(minutes_left)] minutes and [round((minutes_left * 60) % 60)] seconds"
				return
			if(usr.Ki < 175) return
			if(!CanMeleeFromOtherCauses()) return
			if(usr.cant_blast()) return
			
			last_RockSlide = world.time
			usr.Ki = max(0, usr.Ki - 150)
			
			flick("Blast", usr)
			RockSlideFX()
			
			var/amount = 7 + round(usr.BP / 1000000) // Base skill level based on BP
			if(amount > 15) amount = 15
			var/hits = 0
			
			while(amount > 0 && hits < 5) // Limit hits to prevent spam
				var/search_angle = pick(-45, -30, -15, 0, 15, 30, 45)
				var/search_dir = turn(usr.dir, search_angle)
				var/list/targets = FindTargets(search_dir, angle_limit = 15, max_dist = 8)
				
				if(targets)
					for(var/mob/M in targets)
						if(M != usr && hits < 5)
							var/dmg = getPhysicalCombatDamage(M, 0.8)
							var/knockback = get_melee_knockback_distance(M) * 0.7
							usr << "A rock from your slide hits [M]!"
							M << "A rock from [usr]'s slide hits you!"
							M.TakeDamage(dmg, 1.2)
							M.Knockback(usr, knockback)
							hits++
							break
				
				amount--
				sleep(1)
			
			if(hits == 0)
				usr << "Your rock slide hits nothing but air!"

		RockTombFX()
			set waitfor = 0
			var/obj/Effect/e = GetEffect()
			e.loc = loc
			e.icon = 'Explosion.dmi'
			CenterIcon(e)
			animate(e, transform * 3, alpha = 255, time = 20)
			sleep(25)
			del(e)

		RockTomb()
			if(world.time < last_RockTomb + (150))
				var/minutes_left = (last_RockTomb + (150) - world.time) / (10 * 60)
				usr << "You can not use Rock Tomb for another [round(minutes_left)] minutes and [round((minutes_left * 60) % 60)] seconds"
				return
			if(usr.Ki < 125) return
			if(!CanMeleeFromOtherCauses()) return
			if(usr.cant_blast()) return
			
			var/obj/RockTomb/skill = locate() in usr
			if(!skill) return
			
			last_RockTomb = world.time
			usr.Ki = max(0, usr.Ki - 100)
			
			flick("Blast", usr)
			
			var/mob/target = getSelectedTarget(max_dist = 12, dir_angle = usr.dir, angle_limit = 45)
			if(target)
				var/dmg = getPhysicalCombatDamage(target, 5)
				var/knockback = get_melee_knockback_distance(target) * 1.5

				if(skill.mastered)
					usr << "You hurl a massive explosive rock at [target]!"
					target << "[usr] hurls a massive explosive rock at you!"
					spawn(20) RockTombFX() // Delayed explosion effect

					// Area damage for mastered version
					for(var/mob/area_target in range(2, target))
						if(area_target != usr && area_target != target)
							area_target.TakeDamage(dmg * 0.3, 1.0)
							area_target.Knockback(usr, knockback * 0.5)
							area_target << "You are caught in the rock explosion!"
				else
					usr << "You hurl a massive rock at [target]!"
					target << "[usr] hurls a massive rock at you!"

				var/hp_before_dmg = target.Health
				target.TakeDamage(dmg, 2.0)
				target.Knockback(usr, knockback, omega_kb = 1)

				if(dmg >= 200 + hp_before_dmg) target.KO(src, allow_anger = 0)
				else if(dmg >= hp_before_dmg) target.KO(src)
				return
			else
				usr << "You throw a massive rock, but there is no one to hit!"
