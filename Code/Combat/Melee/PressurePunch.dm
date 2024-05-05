obj
	PressurePunch
		desc = "Concentrate your energy into a powerful punch that can knock back enemies."

		Cost_To_Learn = 20
		Teach_Timer = 1
		student_point_cost = 20
		repeat_macro=0
		can_hotbar = 1
		hotbar_type = "Melee"

		verb/Hotbar_use()
			set waitfor=0
			set hidden=1
			PressurePunch()

		verb
			PressurePunch()
				set category = "Skills"
				usr.PressurePunch()

mob/var
	tmp
		last_pressurePunch = 0

mob
	proc
		PressurePunchFX()
			set waitfor=0
			var/obj/Effect/e = GetEffect()
			e.loc = loc
			e.dir = dir
			e.step_size = 64
			step(e, e.dir)
			e.icon = 'PressurePunch.dmi'
			var/anim_time = 10
			e.transform *=3
			animate(e, transform * 3, alpha = 235, time = anim_time)
			player_view(15,src) << sound('pressurePunch.mp3', volume = 100)
			sleep(10)
			del(e)

		PressurePunch()
			if(world.time<last_pressurePunch+(120))
				var/minutes_left=(last_pressurePunch+(120)-world.time)/(10*60)
				usr<<"You can not use Pressure Punchfor another [round(minutes_left)] minutes and [round((minutes_left*60)%60)] \
				seconds"
				return
			if(!CanMeleeFromOtherCauses()) return //this checks if anything OTHER than you currently doing attacks is also stopping you from being able to melee
			last_pressurePunch = world.time
			player_view(15,src) << sound('pressurePunchCharge.mp3', volume = 60)
			sleep(20)
			var/list/targets = FindTargets(usr.dir,angle_limit=33, max_dist=3)
			PressurePunchFX()
			if(targets)
				for(var/mob/M in targets)
					var/dmg = get_melee_damage(usr, count_sword = 0) * 2.5
					var/knockback = get_melee_knockback_distance(usr);
					if(M != usr)
						usr << "You concentrate your energy into a powerful punch that knocks [M] away!"
						M.Knockback(usr, knockback, omega_kb = 1)
						M << "You are knocked back by [usr]!"
						var/hp_before_dmg_hits = M.Health
						M.TakeDamage(dmg, 1.5)
						if(dmg >= 100 + hp_before_dmg_hits) M.KO(src, allow_anger = 0)
						else if(dmg >= hp_before_dmg_hits) M.KO(src)
						return
			else
				usr << "You concentrate your energy into a powerful punch, but there is no one to hit!"
			return