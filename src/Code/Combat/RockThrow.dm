mob/var
	tmp
		last_RockThrow = 0
		last_RockSlide = 0
		last_RockTomb = 0

var/list/nexus_rock_launch_sounds = list('src/Sound/SoundEffects/Combat/Earth/RockLaunch1.ogg', 'src/Sound/SoundEffects/Combat/Earth/RockLaunch2.ogg')
var/list/nexus_rock_impact_sounds = list('src/Sound/SoundEffects/Combat/Earth/RockImpact1.ogg', 'src/Sound/SoundEffects/Combat/Earth/RockImpact2.ogg', 'src/Sound/SoundEffects/Combat/Earth/RockImpact3.ogg')
var/list/nexus_rock_heavy_impact_sounds = list('src/Sound/SoundEffects/Combat/Earth/RockImpactHeavy1.ogg', 'src/Sound/SoundEffects/Combat/Earth/RockImpactHeavy2.ogg')
var/list/nexus_rock_break_sounds = list('src/Sound/SoundEffects/Combat/Earth/RockBreak1.ogg', 'src/Sound/SoundEffects/Combat/Earth/RockBreak2.ogg', 'src/Sound/SoundEffects/Combat/Earth/RockBreak3.ogg')

obj
	RockThrow
		desc = "You throw a rock at your opponent and deal damage with your strength."
		icon = 'RTRockThrow.dmi'
		Cost_To_Learn = 15
		Teach_Timer = 1
		student_point_cost = 15
		repeat_macro = 0
		can_hotbar = 1
		hotbar_type = "Blast"
		
		var/spread_mode = 0 // 0 = single powerful rock, 1 = rapid fire mode

		verb/Hotbar_use()
			set waitfor = 0
			set hidden = 1
			RockThrow()

		verb
			RockThrow()
				set category = "Skills"
				usr.RockThrow()
				
	RockSlide
		desc = "You throw lots of rocks at your opponent and deal damage with your strength. Each projectile is slightly weaker than Rock Throw."
		icon = 'RisingRocks.dmi'
		Cost_To_Learn = 35
		Teach_Timer = 1
		student_point_cost = 35
		repeat_macro = 0
		can_hotbar = 1
		hotbar_type = "Blast"

		verb/Hotbar_use()
			set waitfor = 0
			set hidden = 1
			RockSlide()

		verb
			RockSlide()
				set category = "Skills"
				usr.RockSlide()

	RockTomb
		desc = "You throw a massive rock at your opponent and deal heavy damage with your strength. When mastered this rock explodes!"
		icon = 'RTRockTomb.dmi'
		Cost_To_Learn = 50
		Teach_Timer = 1
		student_point_cost = 50
		repeat_macro = 0
		can_hotbar = 1
		hotbar_type = "Blast"
		
		var/mastered = 0

		verb/Hotbar_use()
			set waitfor = 0
			set hidden = 1
			RockTomb()

		verb
			RockTomb()
				set category = "Skills"
				usr.RockTomb()

obj/Effect/RockSkillProjectile
	name = "hurled rock"
	density = 0
	mouse_opacity = 0
	Grabbable = 0

obj/Effect/RockSkillDebris
	name = "rock debris"
	density = 0
	mouse_opacity = 0
	Grabbable = 0
	icon = 'ResourceRocks.dmi'

	proc/scatter(heavy = FALSE, trail = FALSE)
		set waitfor = 0
		icon_state = "[rand(1, 4)]"
		pixel_x = rand(-7, 7)
		pixel_y = rand(-5, 7)
		alpha = trail ? 145 : 230
		var/start_scale = trail ? rand(24, 42) / 100 : rand(42, heavy ? 85 : 65) / 100
		transform = matrix() * start_scale
		var/travel_x = trail ? rand(-8, 8) : rand(heavy ? -42 : -25, heavy ? 42 : 25)
		var/travel_y = trail ? rand(-5, 5) : rand(heavy ? 24 : 14, heavy ? 58 : 38)
		animate(src, pixel_x = pixel_x + travel_x, pixel_y = pixel_y + travel_y, alpha = 0, transform = matrix() * (start_scale * 0.55), time = trail ? 4 : 7, easing = SINE_EASING)
		sleep(trail ? 4 : 7)
		if(src) del(src)

proc/showRockSkillDebris(turf/impact_turf, heavy = FALSE)
	if(!impact_turf) return
	var/fragment_count = heavy ? 9 : 5
	for(var/fragment_index = 1, fragment_index <= fragment_count, fragment_index++)
		var/obj/Effect/RockSkillDebris/debris = new(impact_turf)
		debris.scatter(heavy)

mob/proc/showRockSkillProjectile(mob/target, visual_icon, visual_state, visual_scale = 1)
	if(!target || !visual_icon) return
	var/obj/Effect/RockSkillProjectile/rock = new
	rock.icon = visual_icon
	if(visual_state) rock.icon_state = visual_state
	rock.SafeTeleport(loc)
	rock.dir = get_dir(src, target)
	CenterIcon(rock)
	rock.setNexusGlow("#d69a5a", 1.8 + visual_scale, 165)
	if(visual_scale != 1) rock.transform = matrix() * visual_scale
	var/maximum_steps = max(1, getdist(src, target) + 4)
	for(var/flight_step = 1, flight_step <= maximum_steps && rock && target, flight_step++)
		if(getdist(rock, target) <= 0) break
		var/turf/next_turf = get_step_towards(rock, target)
		if(!next_turf) break
		rock.SafeTeleport(next_turf)
		if(!(flight_step % 2))
			var/obj/Effect/RockSkillDebris/trail = new(rock.loc)
			trail.scatter(trail = TRUE)
		sleep(1)
	var/turf/impact_turf = target ? target.loc : rock.loc
	if(rock)
		rock.clearNexusGlow()
		del(rock)
	return impact_turf

mob/proc/showRockSkillImpact(mob/target, heavy = FALSE)
	set waitfor = 0
	if(!target) return
	var/obj/Effect/effect = GetEffect()
	effect.icon = heavy ? 'RTShockwave.dmi' : 'RTImpactHeavy.dmi'
	effect.SafeTeleport(target.loc)
	CenterIcon(effect)
	var/impact_scale = heavy ? 1.6 : 1
	effect.transform = matrix() * impact_scale
	effect.pulseNexusGlow(heavy ? "#ffb35a" : "#e0aa72", heavy ? 4.2 : 3, heavy ? 230 : 190, 8)
	flick(effect.icon, effect)
	animate(effect, transform = matrix() * (impact_scale + 0.4), alpha = 0, time = 7, easing = SINE_EASING)
	var/obj/Effect/rising_rocks = GetEffect()
	rising_rocks.icon = 'RisingRocks.dmi'
	rising_rocks.SafeTeleport(target.loc)
	CenterIcon(rising_rocks)
	rising_rocks.transform = matrix() * (heavy ? 1.5 : 0.9)
	flick(rising_rocks.icon, rising_rocks)
	animate(rising_rocks, alpha = 0, transform = matrix() * (heavy ? 1.9 : 1.2), time = 7, easing = SINE_EASING)
	showRockSkillDebris(target.loc, heavy)
	player_view(12, target) << sound(pick(heavy ? nexus_rock_heavy_impact_sounds : nexus_rock_impact_sounds), volume = heavy ? 48 : 34)
	if(heavy) player_view(12, target) << sound(pick(nexus_rock_break_sounds), volume = 34)
	if(heavy) Make_Shockwave(target, sw_icon_size = 128)
	sleep(8)
	if(effect) del(effect)
	if(rising_rocks) del(rising_rocks)

mob/proc/deliverRockThrowHit(mob/target, damage, knockback, visual_scale = 1)
	set waitfor = 0
	showRockSkillProjectile(target, 'RTRockThrow.dmi', null, visual_scale)
	if(!target || !canHitTenkaichiTechniqueTarget(target)) return
	showRockSkillImpact(target)
	target.TakeDamage(damage, 1.5, attacker = src, attack_name = "Rock Throw")
	target.Knockback(src, knockback)

mob/proc/deliverRockSlideHit(mob/target, damage, knockback)
	set waitfor = 0
	showRockSkillProjectile(target, 'RTRockThrow.dmi', null, 0.9)
	if(!target || !canHitTenkaichiTechniqueTarget(target)) return
	showRockSkillImpact(target)
	target.TakeDamage(damage, 1.2, attacker = src, attack_name = "Rock Slide")
	target.Knockback(src, knockback)

mob/proc/deliverRockTombHit(mob/target, damage, knockback, mastered)
	set waitfor = 0
	var/turf/impact_turf = showRockSkillProjectile(target, 'RTRockTomb.dmi', null, 1.25)
	if(!target || !canHitTenkaichiTechniqueTarget(target)) return
	showRockSkillImpact(target, heavy = TRUE)
	var/health_before_damage = target.Health
	if(mastered)
		RockTombFX(impact_turf)
		for(var/mob/area_target in range(2, target))
			if(area_target == src || area_target == target || !canHitTenkaichiTechniqueTarget(area_target)) continue
			area_target.TakeDamage(damage * 0.3, 1, attacker = src, attack_name = "Rock Tomb Explosion")
			area_target.Knockback(src, knockback * 0.5)
			area_target << "You are caught in the rock explosion!"
	target.TakeDamage(damage, 2, attacker = src, attack_name = "Rock Tomb")
	target.Knockback(src, knockback, omega_kb = 1)
	if(damage >= 200 + health_before_damage) target.KO(src, allow_anger = 0)
	else if(damage >= health_before_damage) target.KO(src)

mob
	proc
		RockThrowFX()
			set waitfor = 0
			var/obj/Effect/e = GetEffect()
			e.loc = loc
			e.icon = 'Dust.dmi'
			CenterIcon(e)
			animate(e, transform * 1.5, alpha = 180, time = 8)
			player_view(15, src) << sound(pick(nexus_rock_launch_sounds), volume = 38)
			sleep(12)
			del(e)

		RockThrow()
			var/obj/RockThrow/skill = locate() in usr
			if(!skill) return
			
			if(!skill.spread_mode)
				// Single powerful rock mode
				if(world.time < last_RockThrow + (30))
					var/seconds_left = (last_RockThrow + (30) - world.time) / 10
					usr << "You can not use Rock Throw for another [round(seconds_left)] seconds"
					return
				if(usr.Ki < 45) return
				if(!CanMeleeFromOtherCauses()) return
				if(usr.cant_blast()) return
				
				last_RockThrow = world.time
				usr.Ki = max(0, usr.Ki - 40)
				
				flick("Blast", usr)
				RockThrowFX()
				
				var/mob/target = getSelectedTarget(max_dist = 10, dir_angle = usr.dir, angle_limit = 30)
				if(target)
					var/dmg = getPhysicalCombatDamage(target, 3.5)
					var/knockback = get_melee_knockback_distance(target)
					usr << "You throw a rock at [target]!"
					target << "[usr] throws a rock at you!"
					showTenkaichiTechniqueAnnouncement("Rock Throw", "#d9b27c")
					spawn() deliverRockThrowHit(target, dmg, knockback)
					return
				else
					usr << "You throw a rock, but there is no one to hit!"
			else
				// Rapid fire mode
				if(usr.Ki < 16) return
				if(!CanMeleeFromOtherCauses()) return
				if(usr.cant_blast()) return
				
				usr.Ki = max(0, usr.Ki - 16)
				
				flick("Blast", usr)
				
				var/mob/target = getSelectedTarget(max_dist = 8, dir_angle = usr.dir, angle_limit = 30)
				if(target)
					var/dmg = getPhysicalCombatDamage(target, 1)
					var/knockback = get_melee_knockback_distance(target) * 0.5
					usr << "You throw a small rock at [target]!"
					target << "[usr] throws a small rock at you!"
					showTenkaichiTechniqueAnnouncement("Rock Throw", "#d9b27c")
					spawn() deliverRockThrowHit(target, dmg, knockback, 0.8)
					return
				else
					usr << "You throw a rock, but there is no one to hit!"

		RockSlideFX()
			set waitfor = 0
			var/obj/Effect/e = GetEffect()
			e.loc = loc
			e.icon = 'Dust.dmi'
			CenterIcon(e)
			animate(e, transform * 2, alpha = 220, time = 15)
			player_view(15, src) << sound('src/Sound/SoundEffects/Combat/Earth/RockRumble.ogg', volume = 46)
			player_view(15, src) << sound(pick(nexus_rock_launch_sounds), volume = 24)
			sleep(20)
			del(e)

		RockSlide()
			if(world.time < last_RockSlide + (120))
				var/minutes_left = (last_RockSlide + (120) - world.time) / (10 * 60)
				usr << "You can not use Rock Slide for another [round(minutes_left)] minutes and [round((minutes_left * 60) % 60)] seconds"
				return
			if(usr.Ki < 175) return
			if(!CanMeleeFromOtherCauses()) return
			if(usr.cant_blast()) return
			
			last_RockSlide = world.time
			usr.Ki = max(0, usr.Ki - 150)
			
			flick("Blast", usr)
			RockSlideFX()
			showTenkaichiTechniqueAnnouncement("Rock Slide", "#c99a63")
			
			var/amount = 7 + round(usr.BP / 1000000) // Base skill level based on BP
			if(amount > 15) amount = 15
			var/hits = 0
			
			while(amount > 0 && hits < 15)
				var/search_angle = pick(-45, -30, -15, 0, 15, 30, 45)
				var/search_dir = turn(usr.dir, search_angle)
				var/mob/target = FindTarget(search_dir, angle_limit = 15, max_dist = 8, prefer_auto_target = FALSE)
				if(target && target != usr && hits < 15)
					var/dmg = getPhysicalCombatDamage(target, 0.55)
					var/knockback = get_melee_knockback_distance(target) * 0.7
					usr << "A rock from your slide hits [target]!"
					target << "A rock from [usr]'s slide hits you!"
					spawn() deliverRockSlideHit(target, dmg, knockback)
					hits++
				
				amount--
				sleep(1)
			
			if(hits == 0)
				usr << "Your rock slide hits nothing but air!"

		RockTombFX(turf/impact_turf)
			set waitfor = 0
			var/obj/Effect/e = GetEffect()
			e.loc = impact_turf ? impact_turf : loc
			e.icon = 'RockExplosion.dmi'
			CenterIcon(e)
			flick(e.icon, e)
			e.transform = matrix() * 1.2
			animate(e, transform = matrix() * 1.8, alpha = 0, time = 12, easing = CUBIC_EASING)
			showRockSkillDebris(e.loc, heavy = TRUE)
			player_view(15, e) << sound(pick(nexus_rock_break_sounds), volume = 52)
			player_view(15, e) << sound(pick(nexus_rock_heavy_impact_sounds), volume = 42)
			sleep(20)
			del(e)

		RockTomb()
			if(world.time < last_RockTomb + (150))
				var/minutes_left = (last_RockTomb + (150) - world.time) / (10 * 60)
				usr << "You can not use Rock Tomb for another [round(minutes_left)] minutes and [round((minutes_left * 60) % 60)] seconds"
				return
			if(usr.Ki < 125) return
			if(!CanMeleeFromOtherCauses()) return
			if(usr.cant_blast()) return
			
			var/obj/RockTomb/skill = locate() in usr
			if(!skill) return
			
			last_RockTomb = world.time
			usr.Ki = max(0, usr.Ki - 100)
			
			flick("Blast", usr)
			showTenkaichiTechniqueAnnouncement("Rock Tomb", "#e0a15a", pick(nexus_rock_launch_sounds), 42)
			
			var/mob/target = getSelectedTarget(max_dist = 12, dir_angle = usr.dir, angle_limit = 45)
			if(target)
				var/dmg = getPhysicalCombatDamage(target, 8)
				var/knockback = get_melee_knockback_distance(target) * 1.5

				if(skill.mastered)
					usr << "You hurl a massive explosive rock at [target]!"
					target << "[usr] hurls a massive explosive rock at you!"
				else
					usr << "You hurl a massive rock at [target]!"
					target << "[usr] hurls a massive rock at you!"
				spawn() deliverRockTombHit(target, dmg, knockback, skill.mastered)
				return
			else
				usr << "You throw a massive rock, but there is no one to hit!"
