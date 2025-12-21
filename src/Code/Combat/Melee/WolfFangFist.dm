/*mob/verb/FixMe()
	set category = "Other"
	transform = matrix()*/

obj
	WolfFangFist
		desc = "Lunges at your oponent and land a highspeed damaging sequence."

		Cost_To_Learn = 20
		Teach_Timer = 1
		student_point_cost = 20
		repeat_macro=0
		can_hotbar = 1
		hotbar_type = "Melee"

		verb/Hotbar_use()
			set waitfor=0
			set hidden=1
			WolfFangFist()

		verb
			WolfFangFist()
				set category = "Skills"
				if(skill_engine) skill_engine.castSkill(usr, src)

mob
    var
        tmp
            last_WolfFangFist = 0
            numberOfHits = 5

mob
	proc
		WolfFangFistVFX()
			set waitfor=0
			var/obj/Effect/e = GetEffect()
			e.icon = 'WolfFang3.dmi'
			sleep(1)
			del(e)

		WolfFangFist()
			if(skill_engine) return skill_engine.castWolfFangFist(src)
			return 0

		WolfFangFistCancelled(mob/victim, moved = 1)
			if(!victim || getdist(src,victim) <= 1 || !moved || !viewable(src,victim,35))
				return 1
