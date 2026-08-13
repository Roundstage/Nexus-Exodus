var/roundhouse_kick_damage_factor = 13

obj
	RoundhouseKick
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
			RoundhouseKick()

		verb
			RoundhouseKick()
				set category = "Skills"
				usr.RoundhouseKick()

mob/var
	tmp
		last_RoundhouseKick= 0

mob
	proc
		RoundhouseKickFX()
			set waitfor=0
			var/obj/Effect/e = GetEffect()
			e.loc = loc
			e.icon = 'PressureKick.dmi'
			CenterIcon(e)
			var/anim_time = 10
			animate(e, transform * 3, alpha = 235, time = anim_time)
			player_view(15,src) << sound('Strongpunch.ogg', volume = 60)
			sleep(10)
			del(e)

		RoundhouseKick()
			if(world.time<last_RoundhouseKick+(120))
				var/minutes_left=(last_RoundhouseKick+(120)-world.time)/(10*60)
				usr<<"You can not use Roundhouse Kick for another [round(minutes_left)] minutes and [round((minutes_left*60)%60)] \
				seconds"
				return
			if(!CanMeleeFromOtherCauses()) return //this checks if anything OTHER than you currently doing attacks is also stopping you from being able to melee
			if(usr.cant_blast()) return
			last_RoundhouseKick = world.time
			player_view(15, src) << sound('Throw.ogg', volume = 60)
			sleep(10)
			RoundhouseKickFX()
			var/mob/target = getSelectedTarget(max_dist = 3)
			if(target)
				for(var/mob/M in list(target))
					var/dmg = getPhysicalCombatDamage(M, roundhouse_kick_damage_factor)
					var/knockback = get_melee_knockback_distance(M)
					if(M != usr)
						usr << "You rotate a powerful kick that knocks [M] away!"
						M.Knockback(usr, knockback, omega_kb = 1)
						M << "You are knocked back by [usr]!"
						var/hp_before_dmg_hits = M.Health
						M.TakeDamage(dmg, 1.5, attacker = src, attack_name = "Roundhouse Kick")
						if(dmg >= 100 + hp_before_dmg_hits) M.KO(src, allow_anger = 0)
						else if(dmg >= hp_before_dmg_hits) M.KO(src)
						return
			else
				usr << "You rotate a powerful kick, but there is no one to hit!"
			return
