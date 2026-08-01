var
	kikoho_angle_limit = 67
	kikoho_target_dist = 11

mob/proc/IsValidKikohoTarget(mob/m)
	if(m && ismob(m) && m!=src && get_dist(src,m)>0 && get_abs_angle(src,m) < kikoho_angle_limit)
		if(At_forward_half(m) && viewable(src,m, kikoho_target_dist))
			if(m.type != /mob/Body)
				return 1

mob/proc/GetKikohoTarget(mob/expected_target)
	var/mob/target = getSelectedTarget(expected_target, max_dist = kikoho_target_dist)
	if(IsValidKikohoTarget(target)) return target

obj/Attacks/Kikoho
	Cost_To_Learn=0
	Teach_Timer=1
	student_point_cost = 50
	Drain=100
	desc="This attack damages and stuns and grounds whoever it hits. It is an invisible projectile that hits instantly and can not be \
	deflected, and can be spammed repeatedly. It damages the user over time stuns them also, and can kill them. It can not kill people with death regeneration. It can be countered by anything that knocks the person firing it away, \
	or time freezing them."
	repeat_macro=0

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		Kikoho()

	verb/Kikoho()
		set category="Skills"
		if(usr.Stunned()) 
			return
		if(skill_engine) skill_engine.castSkill(usr, src)

mob/var
	kikoho_damage = 0 //kikoho's damage over time to the user

	tmp
		kikoho_loop

var
	kikoho_self_dmg = 24 //% per shot over time
	list/kikoho_craters = new

proc
	KikohoCrater(turf/t)
		if(!isturf(t)) t = t.base_loc()

		var/obj/Kikoho_Effects/Kikoho_Crater/kc
		for(kc in kikoho_craters) if(kc.z == t.z && getdist(kc,t) < 5) break
		if(!kc) kc = new(t)
		else kc.loc = t

		var
			max_size = 2
		kc.crater_size = kc.crater_size + (max_size - kc.crater_size) * 0.18
		animate(kc, transform = matrix() * kc.crater_size, time = 4)

	KikohoExplosion(turf/t)
		if(!isturf(t)) t = t.base_loc()
		new/obj/Kikoho_Effects/Kikoho_Explosion(t)

	KikohoDust(turf/t)
		set waitfor=0
		if(!isturf(t)) t = t.base_loc()
		sleep(4)
		new/obj/Kikoho_Effects/Kikoho_Dust(t)

	KikohoRocks(turf/t)
		set waitfor=0
		if(!isturf(t)) t = t.base_loc()
		for(var/v in 1 to 18)
			new/obj/Kikoho_Effects/Kikoho_Rock(t)

mob/proc
	StopBeaming()
		set waitfor=0
		for(var/obj/Attacks/A in src) if(A.Wave && (A.charging || A.streaming))
			if(A.charging) Beam_Macro(A)
			sleep(2)
			if(A.streaming) Beam_Macro(A)

	//currently this only stops beams because we didnt feel like coding to stop all attacks
	CancelAllAttacks()
		StopBeaming()

	GetHitByKikoho(mob/a) //a = attacker
		set waitfor=0
		Land()
		if(BP < a.BP * 1.35) CancelAllAttacks()
		if(getdist(src,a) < 6) step(src,get_dir(a,src))

		icon_state = "KO"
		spawn(3) if(src)
			if(!KO)
				if(Flying) icon_state = "Flight"
				else icon_state = ""
			else icon_state = "KO"

		KikohoExplosion(src)
		KikohoDust(src)
		KikohoRocks(src)
		KikohoCrater(src)
		Make_Shockwave(src,sw_icon_size=256)

		var/stun = 16
		ApplyStun(time = stun, no_immunity = 1, stun_power = 6)
		a.ApplyStun(time = stun, no_immunity = 1, stun_power = 6)

		var/dmg = a.KikohoDamageTo(src)
		TakeDamage(dmg, attacker = a, attack_name = "Kikoho")
		if(Health <= 0) KO(a)

	KikohoKnockAwayNonTargets(mob/t) //t = target, usr = firer
		set waitfor=0
		for(var/mob/m in player_view(10,t)) if(m != t && m != usr)
			var
				kb_dist = 10 - get_dist(m,t)
			if(kb_dist > 0)
				spawn if(m) m.Knockback(t, 10)

	KikohoDamageLoop()
		set waitfor=0
		if(kikoho_loop) return
		kikoho_loop=1

		while(kikoho_damage > 0)
			var
				dmg_min = 2 //minimum damage per second
				dmg = dmg_min * RegenMod() * (kikoho_damage / kikoho_self_dmg)
			if(dmg < dmg_min) dmg = dmg_min
			Health -= dmg
			kikoho_damage -= dmg
			if(KO && Health <= 0) Death("kikoho",lose_hero=0,lose_immortality=0)
			sleep(10)

		kikoho_loop=0

	KikohoDamageTo(mob/m)
		return getKiCombatDamage(m, 7)

	FireKikoho(obj/Attacks/Kikoho/k)
		if(skill_engine) return skill_engine.castKikoho(src, k)
		return 0

	KikohoRefire(mult = 1)
		return mult * (5 + (11 * Speed_delay_mult(severity=0.4)))

	KikohoAtmosphereEffect()
		set waitfor=0
		for(var/mob/m in player_view(20,src))
			m.KikohoOrangeAtmosphere()

	KikohoChargeupEffect(grow_til = 0.5)
		set waitfor=0

		var/obj/Kikoho_Effects/Kikoho_Flash/f = new(loc)
		f.alpha = 0
		f.transform *= 4

		var/t = KikohoRefire()

		animate(f, transform = matrix() * 0.01, alpha = 255, time = t * grow_til, easing = SINE_EASING)
		sleep(t * grow_til)
		//animate(f, transform = matrix() * 0.01, time = t * (1 - grow_til))
		sleep(t * (1 - grow_til))
		del(f)

	KikohoOrangeAtmosphere()
		set waitfor=0
		if(!client) return
		animate(client, color = rgb(255,160,0), time = 15)
		sleep(15)
		if(client)
			animate(client, color = rgb(255,255,255), time = 60)

obj/Kikoho_Effects
	density=0
	Grabbable=0
	Health=1.#INF
	Dead_Zone_Immune=1
	can_blueprint=0
	Cloakable=0
	Knockable=0
	Savable=0
	Nukable=0

	Kikoho_Crater
		icon = 'KikohoCrater.dmi'

		var
			delete_time = 0 //the world.time it will delete itself
			crater_size = 0.01

		New()
			kikoho_craters += src
			CenterIcon(src)
			transform = matrix() * crater_size
			KikohoCraterDeleteCheck()

		Del()
			kikoho_craters -= src
			. = ..()

		proc
			KikohoCraterDeleteCheck()
				set waitfor=0
				sleep(10)
				if(!delete_time) delete_time = world.time + 600
				while(src)
					if(world.time > delete_time) del(src)
					sleep(100)

	Kikoho_Flash
		icon = 'Sunfield.dmi'
		layer = MOB_LAYER+2
		blend_mode = BLEND_ADD

		New()
			CenterIcon(src)
			transform = matrix() * 0.01

	Kikoho_Rock
		icon='Turf50.dmi'
		icon_state="1.9"

		New()
			pixel_x=rand(-16,16)
			pixel_y=rand(-16,16)
			KikohoRock()

		proc
			KikohoRock()
				set waitfor=0
				KikohoRockFlyOff()
				sleep(300)
				del(src)

			KikohoRockFlyOff()
				var
					dist = rand(3,12)
					_dir = pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHWEST,SOUTHEAST)
					spd = rand(87,113) / 100

				for(var/v in 1 to dist)
					var
						stepped
					if(prob(30))
						var/d = pick(turn(_dir,45),turn(_dir,-45))
						stepped = step(src,d)
					else stepped = step(src,_dir)

					if(!stepped) break
					else
						var/sleep_delay = world.tick_lag + ((v / dist) * world.tick_lag * 2)
						sleep(TickMult(sleep_delay * spd))

	Kikoho_Dust
		icon = 'KikohoDust.dmi'
		//blend_mode = BLEND_ADD
		layer = MOB_LAYER+1

		New()
			CenterIcon(src)
			pixel_y=0
			transform*=4
			KikohoDust()

		proc
			KikohoDust()
				set waitfor=0
				flick("dust2",src)
				sleep(5)
				del(src)

	Kikoho_Explosion
		blend_mode = BLEND_ADD
		icon = 'KikohoExplosion.dmi'
		layer = MOB_LAYER+1

		New()
			transform*=1.2
			CenterIcon(src)
			pixel_y = 0
			icon = null
			KikohoExplosion()

		proc
			KikohoExplosion()
				set waitfor=0
				flick('KikohoExplosion.dmi',src)
				sleep(14)
				del(src)
