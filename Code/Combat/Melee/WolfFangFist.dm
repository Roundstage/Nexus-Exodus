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
				usr.WolfFangFist()

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
			if(world.time<last_WolfFangFist+(200))
				var/minutes_left=(last_WolfFangFist+(200)-world.time)/(10*60)
				usr<<"You can not use Wolf fang fist for another [round(minutes_left)] minutes and [round((minutes_left*60)%60)] \
				seconds"
				return
			if(!CanMeleeFromOtherCauses()) return //this checks if anything OTHER than you currently doing attacks is also stopping you from being able to melee
			var/mob/victim = LungeTarget()
			if(!victim)
				src << "No target found"
				return
			attacking = 1
			last_WolfFangFist = world.time

			player_view(35,src) << sound('wolf_howl.mp3', volume = 35)
			Do_lunge_drawback_animation()
			sleep(TickMult(2 + Get_melee_delay(mult = 2)))

			var/flying = Flying
			Fly()

			var/targ_dist = getdist(src,victim)
			var/max_dist = targ_dist + 20
			for(var/s in 1 to max_dist)
				AfterImage(20)
				var/success = step_towards(src, victim.base_loc(), 32)
				if(WolfFangFistCancelled(victim, success))
					break
				else sleep(world.tick_lag)

			if(!flying) Land()

			//flick("Attack",src)

			var/hit = prob(get_melee_accuracy(victim) * 2)
			if(getdist(src,victim) > 1) hit = 0
			if(!hit) player_view(15,src) << sound('meleemiss3.ogg', volume = 35)
			ScreenShake(Amount = 15, Offset = 8)

			if(!(victim && hit))
				AddStamina(-(20))
				return

			player_view(15,src) << sound('strongpunch.ogg', volume = 30)
			flick("Attack",src)
			victim.ScreenShake(Amount = 15, Offset = 8)
			var/dmg = get_melee_damage(victim, count_sword = 0) * 1.3
			victim.TakeDamage(dmg, 1);
			var/hp_before_dmg = victim.Health;
			if(dmg >= 100 + hp_before_dmg) victim.KO(src, allow_anger = 1)
			else if(dmg >= hp_before_dmg) victim.KO(src)
			var/remaining_dmg = dmg - hp_before_dmg
			if(remaining_dmg > 0) victim.TakeDamage(remaining_dmg, 1)
			var/hitcount = 0
			for(var/hits in 0 to numberOfHits)
				var/hited = prob(get_melee_accuracy(victim))
				if(!hited)
					player_view(15,src) << sound('meleemiss3.ogg', volume = 35)
					continue;
				hitcount++;
				player_view(15,src) << sound('strongpunch.ogg', volume = 60)
				flick("Attack",src)
				victim.TakeDamage(dmg, 1)
				var/hp_before_dmg_hits = victim.Health
				if(dmg >= 100 + hp_before_dmg_hits) victim.KO(src, allow_anger = 1)
				else if(dmg >= hp_before_dmg_hits) victim.KO(src)
				var/remaining_dmg_hits = dmg - hp_before_dmg_hits
				if(remaining_dmg_hits > 0) victim.TakeDamage(remaining_dmg_hits, 1)
				sleep(1)
			attacking = 0
			world << "You have hit'em [hitcount] times"
			sleep(2)
			if(victim)
				var/base_dist = 0
				var/dist = base_dist * (BP / victim.BP)**0.5 * (End / victim.Str)**0.5
				dist = Clamp(dist, 0, base_dist * 3)
				victim.Knockback(src, Distance = dist, bypass_immunity = 1, from_lunge = 1)

		WolfFangFistCancelled(mob/victim, moved = 1)
			if(!victim || getdist(src,victim) <= 1 || !moved || !viewable(src,victim,35))
				return 1