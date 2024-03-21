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
			e.icon = 'swirling white energy.png'
			sleep(1)
			del(e)

		WolfFangFist()
			if(world.time - last_dropkick < 200) return
			if(!CanMeleeFromOtherCauses()) return //this checks if anything OTHER than you currently doing attacks is also stopping you from being able to melee
			var/mob/m = LungeTarget()
			if(!m)
				src << "No target found"
				return
			attacking = 1
			last_dropkick = world.time

			player_view(15, src) << sound('throw.ogg', volume = 35)
			Do_lunge_drawback_animation()
			sleep(TickMult(2 + Get_melee_delay(mult = 2)))

			var/flying = Flying
			Fly()

			var/targ_dist = getdist(src,m)
			var/max_dist = targ_dist + 20
			for(var/s in 1 to max_dist)
				AfterImage(20)
				var/success = step_towards(src, m.base_loc(), 32)
				if(WolfFangFistCancelled(m, success)) break
				else sleep(world.tick_lag)

			if(!flying) Land()

			//flick("Attack",src)

			var/hit = prob(get_melee_accuracy(m) * 2)
			if(getdist(src,m) > 1) hit = 0
			if(!hit) player_view(15,src) << sound('meleemiss3.ogg', volume = 35)
			ScreenShake(Amount = 15, Offset = 8)

			if(!(m && hit)) 
				AddStamina(-(20))
				return

			player_view(15,src) << sound('strongpunch.ogg', volume = 30)
			flick("Attack",src)
			m.AlterInputDisabled(1)
			m.ScreenShake(Amount = 15, Offset = 8)
			var/dmg = get_melee_damage(m, count_sword = 0) * 1.3
			m.TakeDamage(dmg);
			var/hp_before_dmg = m.Health;
			if(dmg >= 100 + hp_before_dmg) m.KO(src, allow_anger = 1)
			else if(dmg >= hp_before_dmg) m.KO(src)
			var/remaining_dmg = dmg - hp_before_dmg
			if(remaining_dmg > 0) m.TakeDamage(remaining_dmg)
			dmg *= 1.5;
			var/hitcount = 0
			for(var/hits in 0 to numberOfHits)
				var/hited = prob(get_melee_accuracy(m) * 2)		
				if(!hited)
					player_view(15,src) << sound('meleemiss3.ogg', volume = 35)
					continue;
				hitcount += hits;
				player_view(15,src) << sound('strongpunch.ogg', volume = 60)
				flick("Attack",src)
				m.TakeDamage(dmg)
				var/hp_before_dmg_hits = m.Health
				if(dmg >= 100 + hp_before_dmg_hits) m.KO(src, allow_anger = 1)
				else if(dmg >= hp_before_dmg_hits) m.KO(src)
				var/remaining_dmg_hits = dmg - hp_before_dmg_hits
				if(remaining_dmg_hits > 0) m.TakeDamage(remaining_dmg_hits)
				sleep(1)

			world << "You have hit'em [hitcount] times"
			sleep(2)
			if(m)
				m.AlterInputDisabled(-1)
				var/base_dist = 0
				var/dist = base_dist * (BP / m.BP)**0.5 * (End / m.Str)**0.5
				dist = Clamp(dist, 0, base_dist * 3)
				m.Knockback(src, Distance = dist, bypass_immunity = 1, from_lunge = 1)

			AddStamina(-(20))

		WolfFangFistCancelled(mob/m, moved = 1)
			if(!m || getdist(src,m) <= 1 || !moved || !viewable(src,m,35))
				return 1