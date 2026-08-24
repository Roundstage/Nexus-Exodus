mob/var/tmp/turf/last_beam_kb_pos

mob/proc/relative_kb_dist(obj/Blast/b,kb_dist=1)
	if(!b||!b.Owner) return kb_dist
	var/original_kb_dist=kb_dist
	kb_dist*=(b.BP/BP)**1
	if(!b.Bullet) kb_dist*=(b.Force/Res)**0.5
	else kb_dist*=(b.Force/End)**0.5
	if(kb_dist>original_kb_dist*5) kb_dist=original_kb_dist*5
	kb_dist=ToOne(kb_dist)
	return kb_dist

mob/proc/Get_blast_homing_chance(mod = 1)
	var/n=3
	switch(Race)
		if("Namekian") n=55
		if("Android") n=70
		if("Kai") n=40
		if("Majin") n=40
		if("Human") n=40
		if("Tsujin") n=40
	if(Class=="Legendary Saiyan") n+=5
	if(Class=="Spirit Doll") n = 50
	n *= blast_homing_mod
	n *= mod
	return n


proc/Get_projectile_shockwave_size(obj/Blast/b)
	if(b.percent_damage>=60) return 512
	if(b.percent_damage>=30) return 256
	if(b.percent_damage>=12) return 128
	return 0
