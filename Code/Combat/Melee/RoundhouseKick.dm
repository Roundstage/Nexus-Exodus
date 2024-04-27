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
			player_view(15,src) << sound('strongpunch.ogg', volume = 60)
			sleep(10)
			del(e)

		RoundhouseKick()
			if(world.time<last_RoundhouseKick+(120))
				var/minutes_left=(last_RoundhouseKick+(120)-world.time)/(10*60)
				usr<<"You can not use Roundhouse Kick for another [round(minutes_left)] minutes and [round((minutes_left*60)%60)] \
				seconds"
				return
			if(!CanMeleeFromOtherCauses()) return //this checks if anything OTHER than you currently doing attacks is also stopping you from being able to melee
			last_RoundhouseKick = world.time
			player_view(15, src) << sound('throw.ogg', volume = 60)
			sleep(10)
			RoundhouseKickFX()
			var/list/targets = FindTargets(usr.dir,angle_limit=360, max_dist=3)
			if(targets)
				for(var/mob/M in targets)
					var/dmg = get_melee_damage(usr, count_sword = 0) * 1.6
					var/knockback = get_melee_knockback_distance(usr);
					if(M != usr)
						usr << "You rotate a powerful kick that knocks [M] away!"
						M.Knockback(usr, knockback, omega_kb = 1)
						M << "You are knocked back by [usr]!"
						var/hp_before_dmg_hits = M.Health
						M.TakeDamage(dmg, 1.5)
						if(dmg >= 100 + hp_before_dmg_hits) M.KO(src, allow_anger = 0)
						else if(dmg >= hp_before_dmg_hits) M.KO(src)
						return
			else
				usr << "You rotate a powerful kick, but there is no one to hit!"
			return