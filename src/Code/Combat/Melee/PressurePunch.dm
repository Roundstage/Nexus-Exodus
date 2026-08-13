var/pressure_punch_cooldown_ticks = 90
var/pressure_punch_charge_ticks = 10
var/pressure_punch_damage_factor = 16

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
			e.vector_speed = 64
			vector_step_dir(e, e.dir, e.vector_speed)
			e.icon = 'PressurePunch.dmi'
			var/anim_time = 10
			e.transform *=3
			animate(e, transform * 3, alpha = 235, time = anim_time)
			player_view(15,src) << sound('PressurePunch.mp3', volume = 100)
			sleep(10)
			del(e)

		PressurePunch()
			if(world.time < last_pressurePunch + pressure_punch_cooldown_ticks)
				var/minutes_left = (last_pressurePunch + pressure_punch_cooldown_ticks - world.time) / (10 * 60)
				src << "You can not use Pressure Punch for another [round(minutes_left)] minutes and [round((minutes_left*60)%60)] \
				seconds"
				return
			if(!CanMeleeFromOtherCauses()) return //this checks if anything OTHER than you currently doing attacks is also stopping you from being able to melee
			if(cant_blast()) return
			last_pressurePunch = world.time
			player_view(15,src) << sound('PressurePunchCharge.mp3', volume = 60)
			sleep(pressure_punch_charge_ticks)
			var/mob/target = getSelectedTarget(max_dist = 3, dir_angle = dir, angle_limit = 33)
			PressurePunchFX()
			if(target)
				for(var/mob/M in list(target))
					var/dmg = getPhysicalCombatDamage(M, pressure_punch_damage_factor)
					var/knockback = get_melee_knockback_distance(M) * 10
					if(M != src)
						src << "You concentrate your energy into a powerful punch that knocks [M] away!"
						M.Knockback(src, knockback, omega_kb = 1)
						M << "You are knocked back by [src]!"
						var/hp_before_dmg_hits = M.Health
						M.TakeDamage(dmg, 1.5, attacker = src, attack_name = "Pressure Punch")
						if(dmg >= 100 + hp_before_dmg_hits) M.KO(src, allow_anger = 0)
						else if(dmg >= hp_before_dmg_hits) M.KO(src)
						return
			else
				src << "You concentrate your energy into a powerful punch, but there is no one to hit!"
			return
