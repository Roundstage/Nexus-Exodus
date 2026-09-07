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
		icon = 'src/Icons/NexusIntegrated/Attacks/Blasts/RTRockThrow.dmi'
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
		icon = 'src/Icons/Effects/RisingRocks.dmi'
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
		icon = 'src/Icons/NexusIntegrated/Attacks/Blasts/RTRockTomb.dmi'
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

obj/Effect/RockSkillDebris
	name = "rock debris"
	density = 0
	mouse_opacity = 0
	Grabbable = 0
	icon = 'src/Icons/Effects/ResourceRocks.dmi'

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

obj/Blast/RockSkill
	name = "hurled rock"
	Can_Home = 0
	Deflectable = 1
	var/heavy_rock = FALSE

	showConfiguredProjectileImpact(atom/impact_target)
		..()
		if(impact_target) showRockSkillDebris(impact_target.base_loc(), heavy_rock)

mob/proc/launchRockSkillProjectile(obj/skill, visual_icon, damage_factor, move_dir, visual_scale = 1, max_distance = 12, explosion_size = 0, explosion_factor = 0, datum/CombatDamageBudget/shared_budget)
	if(!skill || !visual_icon || !move_dir) return
	var/obj/Blast/RockSkill/rock = new
	rock.setStats(src, Percent = damage_factor, Off_Mult = 1, Explosion = explosion_size, explosion_percent = explosion_factor, shared_budget = shared_budget)
	rock.Can_Home = 0
	rock.strength_scaled = TRUE
	rock.from_attack = skill
	rock.icon = visual_icon
	rock.dir = move_dir
	rock.Distance = max_distance
	rock.vector_speed = 32
	rock.Shockwave = damage_factor >= skill_rock_tomb_damage_factor ? 5 : 2
	rock.heavy_rock = visual_scale >= 1.2
	rock.projectile_impact_icon = rock.heavy_rock ? 'src/Icons/NexusIntegrated/Attacks/Effects/RTShockwave.dmi' : 'src/Icons/NexusIntegrated/Attacks/Effects/RTImpactHeavy.dmi'
	rock.projectile_impact_color = "#d69a5a"
	rock.projectile_impact_sound = pick(rock.heavy_rock ? nexus_rock_heavy_impact_sounds : nexus_rock_impact_sounds)
	rock.projectile_impact_sound_volume = rock.heavy_rock ? 48 : 34
	rock.SafeTeleport(loc)
	rock.step_x = step_x
	rock.step_y = step_y
	CenterIcon(rock)
	rock.Update_transform_size(visual_scale)
	rock.queueNexusProjectileGlowUpdate()
	rock.startKiProjectileWalk(move_dir)
	return rock

mob/proc/showRockSkillImpact(mob/target, heavy = FALSE)
	set waitfor = 0
	if(!target) return
	var/obj/Effect/effect = GetEffect()
	effect.icon = heavy ? 'src/Icons/NexusIntegrated/Attacks/Effects/RTShockwave.dmi' : 'src/Icons/NexusIntegrated/Attacks/Effects/RTImpactHeavy.dmi'
	effect.SafeTeleport(target.loc)
	CenterIcon(effect)
	var/impact_scale = heavy ? 1.6 : 1
	effect.transform = matrix() * impact_scale
	effect.pulseNexusGlow(heavy ? "#ffb35a" : "#e0aa72", heavy ? 4.2 : 3, heavy ? 230 : 190, 8)
	flick(effect.icon, effect)
	animate(effect, transform = matrix() * (impact_scale + 0.4), alpha = 0, time = 7, easing = SINE_EASING)
	var/obj/Effect/rising_rocks = GetEffect()
	rising_rocks.icon = 'src/Icons/Effects/RisingRocks.dmi'
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

mob
	proc
		RockThrowFX()
			set waitfor = 0
			var/obj/Effect/e = GetEffect()
			e.loc = loc
			e.icon = 'src/Icons/Effects/Dust.dmi'
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
				
				usr << "You throw a rock straight ahead!"
				showNexusTechniqueAnnouncement("Rock Throw", "#d9b27c")
				launchRockSkillProjectile(skill, skill.icon, skill_rock_throw_powerful_damage_factor, usr.dir, 1, 10)
			else
				// Rapid fire mode
				if(usr.Ki < 16) return
				if(!CanMeleeFromOtherCauses()) return
				if(usr.cant_blast()) return
				
				usr.Ki = max(0, usr.Ki - 16)
				
				flick("Blast", usr)
				
				usr << "You throw a small rock straight ahead!"
				showNexusTechniqueAnnouncement("Rock Throw", "#d9b27c")
				launchRockSkillProjectile(skill, skill.icon, skill_rock_throw_rapid_damage_factor, usr.dir, 0.8, 8)

		RockSlideFX()
			set waitfor = 0
			var/obj/Effect/e = GetEffect()
			e.loc = loc
			e.icon = 'src/Icons/Effects/Dust.dmi'
			CenterIcon(e)
			animate(e, transform * 2, alpha = 220, time = 15)
			player_view(15, src) << sound('src/Sound/SoundEffects/Combat/Earth/RockRumble.ogg', volume = 46)
			player_view(15, src) << sound(pick(nexus_rock_launch_sounds), volume = 24)
			sleep(20)
			del(e)

		RockSlide()
			var/obj/RockSlide/skill = locate() in usr
			if(!skill) return
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
			showNexusTechniqueAnnouncement("Rock Slide", "#c99a63")
			
			var/amount = 7 + round(usr.BP / 1000000) // Base skill level based on BP
			if(amount > skill_rock_slide_max_hits) amount = skill_rock_slide_max_hits
			var/datum/CombatDamageBudget/damage_budget = new(skill_rock_slide_damage_factor * skill_rock_slide_max_hits)
			
			while(amount > 0)
				var/obj/Blast/RockSkill/rock = launchRockSkillProjectile(skill, 'src/Icons/NexusIntegrated/Attacks/Blasts/RTRockThrow.dmi', skill_rock_slide_damage_factor, usr.dir, 0.9, 12, shared_budget = damage_budget)
				if(rock)
					rock.pixel_x += rand(-32, 32)
					rock.pixel_y += rand(-32, 32)
				amount--
				sleep(1)

		RockTombFX(turf/impact_turf)
			set waitfor = 0
			var/obj/Effect/e = GetEffect()
			e.loc = impact_turf ? impact_turf : loc
			e.icon = 'src/Icons/Effects/RockExplosion.dmi'
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
			showNexusTechniqueAnnouncement("Rock Tomb", "#e0a15a", pick(nexus_rock_launch_sounds), 42)
			
			usr << "You hurl a massive[skill.mastered ? " explosive" : ""] rock straight ahead!"
			var/explosion_factor = skill.mastered ? skill_rock_tomb_damage_factor * 0.3 : 0
			launchRockSkillProjectile(skill, skill.icon, skill_rock_tomb_damage_factor, usr.dir, 1.6, 12, skill.mastered ? 2 : 0, explosion_factor)
