mob/var
	tmp
		last_RockThrow = 0
		last_RockSlide = 0
		last_RockTomb = 0

obj
	RockThrow
		desc = "You throw a rock at your opponent and deal damage with your strength."
		Cost_To_Learn = 15
		Teach_Timer = 1
		student_point_cost = 15
		repeat_macro = 0
		can_hotbar = 1
		hotbar_type = "Ranged"
		
		var/spread_mode = 0 // 0 = single powerful rock, 1 = rapid fire mode

		verb/Hotbar_use()
			set waitfor = 0
			set hidden = 1
			RockThrow()

		verb
			RockThrow()
				set category = "Skills"
				usr.RockThrow()
				
			Ki_Settings()
				set category = "Other"
				switch(input("Do you want your Rock Throws to be similar to blast and have lower damage but no cooldown?") in list("Yes","No"))
					if("Yes") spread_mode = 1
					if("No") spread_mode = 0

	RockSlide
		desc = "You throw lots of rocks at your opponent and deal damage with your strength. Each projectile is slightly weaker than Rock Throw."
		Cost_To_Learn = 35
		Teach_Timer = 1
		student_point_cost = 35
		repeat_macro = 0
		can_hotbar = 1
		hotbar_type = "Ranged"

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
		Cost_To_Learn = 50
		Teach_Timer = 1
		student_point_cost = 50
		repeat_macro = 0
		can_hotbar = 1
		hotbar_type = "Ranged"
		
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
			e.icon = 'dust.dmi'
			CenterIcon(e)
			animate(e, transform * 1.5, alpha = 180, time = 8)
			player_view(15, src) << sound('throw.ogg', volume = 50)
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
				
				var/list/targets = FindTargets(usr.dir, angle_limit = 30, max_dist = 10)
				if(targets)
					for(var/mob/M in targets)
						if(M != usr)
							var/dmg = get_melee_damage(usr, count_sword = 0) * 1.2
							var/knockback = get_melee_knockback_distance(usr)
							usr << "You throw a rock at [M]!"
							M << "[usr] throws a rock at you!"
							M.TakeDamage(dmg, 1.5)
							M.Knockback(usr, knockback)
							return
				else
					usr << "You throw a rock, but there is no one to hit!"
//					player_view(6, usr) << sound('Blast1.wav', volume = 40)
			else
				// Rapid fire mode
				if(usr.Ki < 16) return
				if(!CanMeleeFromOtherCauses()) return
				if(usr.cant_blast()) return
				
				usr.Ki = max(0, usr.Ki - 16)
				
				flick("Blast", usr)
				
				var/list/targets = FindTargets(usr.dir, angle_limit = 30, max_dist = 8)
				if(targets)
					for(var/mob/M in targets)
						if(M != usr)
							var/dmg = get_melee_damage(usr, count_sword = 0) * 0.4
							var/knockback = get_melee_knockback_distance(usr) * 0.5
							usr << "You throw a small rock at [M]!"
							M << "[usr] throws a small rock at you!"
							M.TakeDamage(dmg, 1.0)
							M.Knockback(usr, knockback)
							return
				else
					usr << "You throw a rock, but there is no one to hit!"
//					player_view(6, usr) << sound('Blast2.wav', volume = 30)

		RockSlideFX()
			set waitfor = 0
			var/obj/Effect/e = GetEffect()
			e.loc = loc
			e.icon = 'dust.dmi'
			CenterIcon(e)
			animate(e, transform * 2, alpha = 220, time = 15)
//			player_view(15, src) << sound('rockslide.ogg', volume = 60)
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
							var/dmg = get_melee_damage(usr, count_sword = 0) * 0.8
							var/knockback = get_melee_knockback_distance(usr) * 0.7
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
			e.icon = 'explosion.dmi'
			CenterIcon(e)
			animate(e, transform * 3, alpha = 255, time = 20)
//			player_view(15, src) << sound('explosion.ogg', volume = 80)
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
			
			var/list/targets = FindTargets(usr.dir, angle_limit = 45, max_dist = 12)
			if(targets)
				for(var/mob/M in targets)
					if(M != usr)
						var/dmg = get_melee_damage(usr, count_sword = 0) * 2.0
						var/knockback = get_melee_knockback_distance(usr) * 1.5
						
						if(skill.mastered)
							dmg *= 1.25 // 25% bonus damage when mastered
							usr << "You hurl a massive explosive rock at [M]!"
							M << "[usr] hurls a massive explosive rock at you!"
							spawn(20) RockTombFX() // Delayed explosion effect
//							player_view(6, usr) << sound('meteor.ogg', volume = 70)
							
							// Area damage for mastered version
							for(var/mob/T in range(2, M))
								if(T != usr && T != M)
									T.TakeDamage(dmg * 0.3, 1.0)
									T.Knockback(usr, knockback * 0.5)
									T << "You are caught in the rock explosion!"
						else
							usr << "You hurl a massive rock at [M]!"
							M << "[usr] hurls a massive rock at you!"
//							player_view(6, usr) << sound('rockthrow.ogg', volume = 60)
						
						var/hp_before_dmg = M.Health
						M.TakeDamage(dmg, 2.0)
						M.Knockback(usr, knockback, omega_kb = 1)
						
						if(dmg >= 200 + hp_before_dmg) M.KO(src, allow_anger = 0)
						else if(dmg >= hp_before_dmg) M.KO(src)
						return
			else
				usr << "You throw a massive rock, but there is no one to hit!"