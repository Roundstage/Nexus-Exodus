/*mob/verb/FixMe()
	set category = "Other"
	transform = matrix()*/

var/wolf_fang_hit_damage_mult = 3
var/wolf_fang_knockback_distance = 3
var/wolf_fang_accuracy_bonus = 15

proc/getWolfFangFinisherKnockback(hit_count, planned_hits)
	if(planned_hits <= 0 || hit_count < planned_hits) return 0
	return wolf_fang_knockback_distance

obj
	WolfFangFist
		desc = "Lunges at your opponent with five advancing strikes. The sequence stays in contact and its final hit deals medium knockback."

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
		WolfFangFistVFX(mob/victim, finisher = FALSE)
			if(!isturf(base_loc())) return
			var/turf/origin = base_loc()
			var/obj/Effect/e = GetEffect()
			e.icon = 'src/Icons/VFX/WolfFangFist/WolfFang3.dmi'
			e.icon_state = "Attack"
			e.dir = victim ? get_dir(src, victim) : dir
			e.color = "#48bfff"
			e.blend_mode = BLEND_ADD
			e.layer = MOB_LAYER + 0.2
			e.appearance_flags |= PIXEL_SCALE
			e.SafeTeleport(origin)
			e.pixel_x = nexusCollisionCenterXPixels() - (origin.x - 1) * world.icon_size - 82
			e.pixel_y = nexusCollisionCenterYPixels() - (origin.y - 1) * world.icon_size - 82
			e.transform = matrix() * (finisher ? 2.4 : 1.6)
			flick("Attack", e)
			spawn(5)
				if(e) animate(e, alpha = 0, time = 1)
			spawn(7)
				if(e) del(e)
			return e

		WolfFangFist()
			if(skill_engine) return skill_engine.castWolfFangFist(src)
			return 0

		WolfFangFistCancelled(mob/victim, moved = 1)
			if(!victim || selected_target != victim || getdist(src,victim) <= 1 || !moved || !viewable(src,victim,35))
				return 1
