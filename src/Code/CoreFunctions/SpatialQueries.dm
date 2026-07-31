// Efficiently returns all active projectiles within range of center.
proc/blast_view(dist=10,mob/center)
	if(!center) return new/list
	var/area/a=center.get_area()
	if(!a) return new/list
	var/list/l=new
	for(var/obj/Blast/b in a.blast_objs) if(b.z&&b.z==center.locz()&&getdist(b,center)<=dist) l+=b
	return l

proc/player_range(range=20,mob/center)
	var/list/l=new
	var/area/a=locate(/area) in range(0,center)
	if(!a) return l
	for(var/mob/m in a.player_list) if(m.z==center.z&&getdist(m,center)<=range) l+=m
	return l

proc/player_view(range = 20, mob/center, seePastDenseObjs = 1)
	var/list/l=new
	var/area/a=locate(/area) in range(0,center)
	if(!a) return l
	for(var/mob/m in a.player_list) if(m&&m.z==center.z&&getdist(m,center)<=range&&viewable(m,center,5000,seePastDenseObjs)) l+=m
	return l

proc/mob_view(range=20,mob/center, seePastDenseObjs = 1)
	var/list/l=new
	var/area/a=locate(/area) in range(0,center)
	if(!a) return l
	for(var/mob/m in a.mob_list) if(m.z==center.z&&getdist(m,center)<=range&&viewable(m,center,5000,seePastDenseObjs)) l+=m
	return l

proc/npc_view(range=20,mob/center, seePastDenseObjs = 1)
	var/list/l=new
	var/area/a=locate(/area) in range(0,center)
	if(!a) return l
	for(var/mob/m in a.npc_list) if(m.z==center.z&&getdist(m,center)<=range&&viewable(m,center, 5000, seePastDenseObjs)) l+=m
	return l

proc/viewable(mob/a, mob/b, max_dist = 5000, seePastDenseObjs = 1)
	if(!a.z || !b.z || a.z != b.z) return
	a = a.base_loc()
	b = b.base_loc()
	if(a == b) return 1
	if(getdist(a,b) > max_dist) return
	var/turf/t = a

	while(t && t != b)
		max_dist--
		if(!max_dist) return 1
		t = get_step(t,get_dir(t,b))
		if(!t || t.opacity) return
		else for(var/obj/o in t)
			if(o.opacity) return
			if(!seePastDenseObjs && o.density) return

	if(!t || t != b) return
	return 1
