// Cosmetic snapshots are bounded to the approach and never control movement or hits.
mob/proc/runViltrumiteVisualApproach(mob/target, distance_pixels, max_velocity, acceleration, deceleration, afterimage_interval)
	var/list/trail_active = list(TRUE)
	spawn()
		for(var/sample = 1, sample <= 12, sample++)
			if(!src || !trail_active[1] || !isturf(base_loc())) break
			var/obj/Effect/ghost = GetEffect()
			ghost.appearance = appearance
			ghost.mouse_opacity = 0
			ghost.density = FALSE
			ghost.color = "#dceeff"
			ghost.alpha = 105
			ghost.layer = MOB_LAYER - 0.05
			ghost.SafeTeleport(base_loc())
			animate(ghost, alpha = 0, time = 3)
			spawn(4)
				if(ghost) del(ghost)
			sleep(max(1, afterimage_interval))
	var/result = runNexusSkillApproach(target, distance_pixels, world.icon_size, max_velocity, acceleration, deceleration, 0)
	trail_active[1] = FALSE
	return result

proc/showViltrumitePressureImpact(mob/target, heavy = FALSE)
	if(!target) return
	showNexusOpenCombatEffect(target, "aim_32", "explosion_orange", heavy ? 2.2 : 1.2, "#fff2de", 230, BLEND_ADD, 1, 0.3)
	showNexusOpenCombatEffect(target, "smoke_shockwaves_128", "middle", 0.18, "#eaf4ff", heavy ? 210 : 145, BLEND_ADD, 2, heavy ? 0.9 : 0.4)
