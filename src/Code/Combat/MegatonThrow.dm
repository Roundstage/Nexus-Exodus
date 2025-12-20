
mob/var
	tmp
		PSand = 0
		last_PocketSand = 0
		last_ExplodingHeartStrike = 0
		last_MegatonThrow = 0

obj
	PocketSand
		desc = "Launch a cheap attack against an opponent's eyes by throwing sand at them. Reduces their Offense and Defense by 10% if it hits for 15 seconds as well as staggering them."
		Cost_To_Learn = 20
		Teach_Timer = 1
		student_point_cost = 20
		repeat_macro = 0
		can_hotbar = 1
		hotbar_type = "Melee"

		verb/Hotbar_use()
			set waitfor = 0
			set hidden = 1
			PocketSand()

		verb
			PocketSand()
				set category = "Skills"
				usr.PocketSand()

	ExplodingHeartStrike
		desc = "Launch an attack against an opponent that deals delayed damage but has bonus offense damage, staggers and damages their chest. (3s delay)"
		Cost_To_Learn = 40
		Teach_Timer = 1
		student_point_cost = 40
		repeat_macro = 0
		can_hotbar = 1
		hotbar_type = "Melee"

		verb/Hotbar_use()
			set waitfor = 0
			set hidden = 1
			ExplodingHeartStrike()

		verb
			ExplodingHeartStrike()
				set category = "Skills"
				usr.ExplodingHeartStrike()

	MegatonThrow
		desc = "While grabbing an opponent, leap into the air and then throw them to the ground, causing good damage."
		Cost_To_Learn = 30
		Teach_Timer = 1
		student_point_cost = 30
		repeat_macro = 0
		can_hotbar = 1
		hotbar_type = "Melee"

		verb/Hotbar_use()
			set waitfor = 0
			set hidden = 1
			MegatonThrow()

		verb
			MegatonThrow()
				set category = "Skills"
				usr.MegatonThrow()

mob
	proc
		PocketSandFX()
			set waitfor = 0
			var/obj/Effect/e = GetEffect()
			e.loc = loc
			e.icon = 'dust.dmi'
			CenterIcon(e)
			var/anim_time = 10
			animate(e, transform * 2, alpha = 200, time = anim_time)
			//player_view(15, src) << sound('throw.ogg', volume = 40)
			sleep(15)
			del(e)

		PocketSand()
			if(world.time < last_PocketSand + (60))
				var/minutes_left = (last_PocketSand + (60) - world.time) / (10 * 60)
				usr << "You can not use Pocket Sand for another [round(minutes_left)] minutes and [round((minutes_left * 60) % 60)] seconds"
				return
			if(!CanMeleeFromOtherCauses()) return
			if(usr.cant_blast()) return
			last_PocketSand = world.time
			
			flick("Attack", usr)
			PocketSandFX()
			
			var/list/targets = FindTargets(usr.dir, angle_limit = 90, max_dist = 1)
			if(targets)
				for(var/mob/M in targets)
					if(M != usr)
						var/dmg = get_melee_damage(usr, count_sword = 0) * 0.8
						var/knockback = get_melee_knockback_distance(usr) * 0.5
						
						if(prob(70)) // Hit chance
							usr << "You throw sand at [M]'s eyes!"
							M << "Sand gets in your eyes from [usr]!"
							M.PSand = 150 // 15 seconds debuff
							M.TakeDamage(dmg, 1.0)
							M.Knockback(usr, knockback)
							player_view(6, M) << "[usr] throws sand at [M]'s eyes."
						else
							usr << "[M] dodges your sand attack!"
							M << "You dodge [usr]'s sand attack!"
							player_view(6, M) << pick(sound('meleemiss1.ogg'), sound('meleemiss2.ogg'), sound('meleemiss3.ogg'))
						return
			else
				usr << "You throw sand, but there is no one to hit!"

		ExplodingHeartStrikeFX()
			set waitfor = 0
			var/obj/Effect/e = GetEffect()
			e.loc = loc
			e.icon = 'explosion.dmi'
			CenterIcon(e)
			var/anim_time = 20
			animate(e, transform * 2.5, alpha = 255, time = anim_time)
			//player_view(15, src) << sound('explosion.ogg', volume = 50)
			sleep(20)
			del(e)

		ExplodingHeartStrike()
			if(world.time < last_ExplodingHeartStrike + (180))
				var/minutes_left = (last_ExplodingHeartStrike + (180) - world.time) / (10 * 60)
				usr << "You can not use Exploding Heart Strike for another [round(minutes_left)] minutes and [round((minutes_left * 60) % 60)] seconds"
				return
			if(!CanMeleeFromOtherCauses()) return
			if(usr.cant_blast()) return
			last_ExplodingHeartStrike = world.time
			
			flick("Attack", usr)
			
			var/list/targets = FindTargets(usr.dir, angle_limit = 90, max_dist = 1)
			if(targets)
				for(var/mob/M in targets)
					if(M != usr)
						var/dmg = (get_melee_damage(usr, count_sword = 0) * 1.5) + 50
						
						if(prob(70)) // Hit chance
							usr << "You strike [M]'s pressure point!"
							M << "[usr] strikes a critical point on your body!"
							
							// Delayed damage effect
							spawn(30) // 3 second delay
								if(M && usr)
									ExplodingHeartStrikeFX()
									var/hp_before_dmg = M.Health
									M.TakeDamage(dmg, 2.0)
									if(dmg >= 150 + hp_before_dmg) M.KO(src, allow_anger = 0)
									else if(dmg >= hp_before_dmg) M.KO(src)
									usr << "Your delayed strike takes effect on [M]!"
									M << "The delayed strike from [usr] explodes inside you!"
						else
							usr << "[M] dodges your strike!"
							M << "You dodge [usr]'s pressure point strike!"
							player_view(6, M) << pick(sound('meleemiss1.ogg'), sound('meleemiss2.ogg'), sound('meleemiss3.ogg'))
						return
			else
				usr << "You strike at the air, but there is no one to hit!"

		MegatonThrow()
			if(world.time < last_MegatonThrow + (90))
				var/minutes_left = (last_MegatonThrow + (90) - world.time) / (10 * 60)
				usr << "You can not use Megaton Throw for another [round(minutes_left)] minutes and [round((minutes_left * 60) % 60)] seconds"
				return
			if(!CanMeleeFromOtherCauses()) return
			if(usr.cant_blast()) return
			
			// Check if grabbing someone
			var/mob/grabbed_target = null
			for(var/mob/M in get_step(usr, usr.dir))
				if(M != usr)
					grabbed_target = M
					break
			
			if(!grabbed_target)
				usr << "You need to be next to someone to grab and throw them!"
				return
				
			last_MegatonThrow = world.time
			MegatonToss(grabbed_target)

		MegatonToss(mob/M)
			set waitfor = 0
			if(!M) return
			
			var/dmg = (get_melee_damage(usr, count_sword = 0) * 2.0) + 75
			var/knockback = get_melee_knockback_distance(usr) * 2
			
			if(prob(80)) // High success rate for throws
				usr << "You grab [M] and leap into the air!"
				M << "[usr] grabs you and leaps into the air!"
				
				// Visual effects
				underlays += 'Shadow.dmi'
				M.underlays += 'Shadow.dmi'
				
				// Leap up animation
				spawn()
					var/i = 0
					while(i < 16)
						M.pixel_y += 6
						pixel_y += 6
						i++
						sleep(1)
				
				sleep(16)
				
				// Throw down animation
				spawn()
					var/i = 0
					while(i < 12)
						M.pixel_y -= 8
						i++
						sleep(1)
				
				sleep(8)
				
				// User comes down
				spawn()
					var/i = 0
					while(i < 12)
						pixel_y -= 8
						i++
						sleep(1)
				
				sleep(12)
				
				// Clean up effects
				underlays -= 'Shadow.dmi'
				M.underlays -= 'Shadow.dmi'
				
				// Apply damage and knockback
				//player_view(10, M) << sound('crash.ogg', volume = 70)
				usr << "You slam [M] into the ground!"
				M << "[usr] slams you into the ground!"
				
				var/hp_before_dmg = M.Health
				M.TakeDamage(dmg, 2.5)
				M.Knockback(usr, knockback, omega_kb = 1)
				
				if(dmg >= 200 + hp_before_dmg) M.KO(src, allow_anger = 0)
				else if(dmg >= hp_before_dmg) M.KO(src)
			else
				usr << "[M] breaks free from your grab!"
				M << "You break free from [usr]'s grab!"
				player_view(6, M) << pick(sound('meleemiss1.ogg'), sound('meleemiss2.ogg'), sound('meleemiss3.ogg'))