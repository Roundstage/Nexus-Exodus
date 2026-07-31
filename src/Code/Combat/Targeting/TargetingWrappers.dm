mob/proc/FindHakaiTarget()
	var/dist = 4
	var/mob/target = getSelectedTarget(max_dist = dist, dir_angle = dir, angle_limit = 33)
	if(IsViableHakaiTarget(target, dist)) return target

mob/proc/IsViableHakaiTarget(mob/m, max_dist = 5)
	if(!m) return
	if(m.type == /mob/Body) return
	if(m.Safezone) return
	if(alignment_on && both_good(src, m)) return
	if(Same_league_cant_kill(src, m)) return
	if(IsValidTarget(m, max_dist)) return 1





obj/Blast/proc/GetBlastHomingTarget(d, angle)
	if(!Owner) return
	var/mob/target = Owner.getSelectedTarget(max_dist = 30, dir_angle = d, angle_limit = angle)
	if(target && Is_viable_homing_target(target)) return target





var/lunge_angle_limit = 33

mob/proc/Is_viable_lunge_target(mob/m)
	if(m && ismob(m) && m!=src && get_dist(src,m)>0 && get_abs_angle(src,m) < lunge_angle_limit && At_forward_half(m) && viewable(src,m,Get_lunge_targeting_distance()))
		if(m.type != /mob/Body && !m.KO)
			return 1

mob/proc/LungeTarget(dist_override)
	var/dist = Get_lunge_targeting_distance()
	if(dist_override) dist = dist_override
	var/mob/target = getSelectedTarget(max_dist = dist)
	if(Is_viable_lunge_target(target)) return target

mob/proc
	//this is a wrapper function example of FindTargets for situations that need to check validity of targets using extra specifications
	FindWarpTarget(dir_angle=NORTH, angle_limit=44, max_dist=10, prefer_auto_target=0)
		var/mob/target = getSelectedTarget(max_dist = max_dist, dir_angle = dir_angle, angle_limit = angle_limit)
		if(IsValidWarpTarget(target, max_dist)) return target

	IsValidWarpTarget(mob/m, max_dist=10)
		if(!m) return
		if(m.KB || m.KO || m.type == /mob/Body) return
		if(IsValidTarget(m, max_dist)) return 1
