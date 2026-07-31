/*mob/verb/FixMe()
	set category = "Other"
	transform = matrix()*/

obj
	Dropkick
		desc = "Channel all your energy into 1 kick, stunning your oponnent and causing a massive damage."

		Cost_To_Learn = 20
		Teach_Timer = 1
		student_point_cost = 20
		repeat_macro=0
		can_hotbar = 1
		hotbar_type = "Melee"

		verb/Hotbar_use()
			set waitfor=0
			set hidden=1
			Dropkick()

		verb
			Dropkick()
				set category = "Skills"
				if(skill_engine) skill_engine.castSkill(usr, src)

mob/var
	tmp
		last_dropkick = 0
		last_dropkick_debuff_triggered = 0

mob
	proc
		DropkickBPDebuff()
			if(world.time - last_dropkick_debuff_triggered < 300) return 0.01
			return 1

		DropkickFX()
			set waitfor=0
			var/obj/Effect/e = GetEffect()
			e.icon = 'SwirlingWhiteEnergy.png'
			CenterIcon(e)
			e.SafeTeleport(loc)
			e.transform *= 2
			var/fx_time = 5
			animate(e, transform = transform * 0.001, time = fx_time, easing = SINE_EASING)
			sleep(fx_time + 1)
			del(e)

		Dropkick()
			if(skill_engine) return skill_engine.castDropkick(src)
			return 0

		DropkickCancelled(mob/m, moved = 1)
			if(!m || selected_target != m || getdist(src,m) <= 1 || !moved || !viewable(src,m,35))
				return 1
