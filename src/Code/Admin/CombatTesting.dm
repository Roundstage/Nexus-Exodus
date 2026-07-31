mob/Admin5/verb/altAutoFightTest(mob/m in world)
	set name = "Alt Auto Fight Test"
	if(!m.client) return

	Resetinactivity()
	m.Resetinactivity()

	sleep(50)

	spawn Power_up()
	spawn m.Power_up()

	while(!KO && !m.KO)
		Resetinactivity()
		m.Resetinactivity()

		var/d=get_dir(src,m)
		spawn(2) if(src && !KB) step(src,pick(d,turn(d,45),turn(d,-45)))
		if(!Shielding() && Health<=20 && Ki>=max_ki*0.5) Toggle_ki_shield()
		else if(Shielding() && Ki<max_ki*0.25) Toggle_ki_shield()

		d=get_dir(m,src)
		spawn(2) if(m && !m.KB) step(m,pick(d,turn(d,45),turn(d,-45)))
		if(!m.Shielding() && m.Health<=20 && m.Ki>=m.max_ki*0.5) m.Toggle_ki_shield()
		else if(m.Shielding() && m.Ki<m.max_ki*0.25) m.Toggle_ki_shield()

		var/list/guys=list(src,m)
		while(guys.len)
			var/mob/attacker=pick(guys)
			guys-=attacker
			attacker.Melee()

		sleep(world.tick_lag)

	if(Shielding()) Toggle_ki_shield()
	if(m.Shielding()) m.Toggle_ki_shield()
	FullHeal()
	m.FullHeal()
	Calm()
	m.Calm()
	last_anger=0
	m.last_anger=0
	anger_reasons=new/list
	m.anger_reasons=new/list
	Stop_Powering_Up()
	m.Stop_Powering_Up()

mob/Admin5/verb/battleTest()
	set name = "Battle test"
	var/mob/m=Duplicate(include_unclonables=1)
	m.SafeTeleport(loc)
	m.Player_Loops()
	sleep(30)
	m.fight_copy_of_self()

mob/var/battle_test
mob/var/battle_count=0

mob/proc/fight_copy_of_self()
	battle_count++
	world<<"battle #[battle_count]"
	battle_test=1
	Player_Loops()
	name="guy #[rand(1,999)]"
	var/mob/m=Duplicate(include_unclonables=1)
	Has_DNA=0
	m.Has_DNA=0

	if(prob(50)) for(var/obj/items/Sword/s in m)
		if(!s.suffix)
			s.Damage*=rand(80,120)/100
			s.Damage=Clamp(s.Damage,0.5,2)
			s.Style=pick("Energy","Physical")
		m.Apply_Sword(s)

	if(prob(50)) for(var/obj/items/Armor/a in m)
		if(!a.suffix)
			a.Armor*=rand(80,120)/100
			a.Armor=Clamp(a.Armor,1,2)
		m.Apply_Armor(a)

	m.Status_Running=0
	m.name="guy #[rand(1,999)]"
	m.battle_test=1
	players-=src
	players+=src
	players+=m
	m.SafeTeleport(loc)
	step_away(m,src)
	m.dir=get_dir(m,src)
	dir=get_dir(src,m)
	m.Random_stat_change()
	m.Player_Loops()
	sleep(30)
	spawn Power_up()
	spawn m.Power_up()
	while(!KO&&!m.KO)

		BP=get_bp()
		var/d=get_dir(src,m)
		spawn(2) if(src&&!KB) step(src,pick(d,turn(d,45),turn(d,-45)))
		if(!Shielding()&&Health<=25&&Ki>=max_ki*0.5) Toggle_ki_shield()
		else if(Shielding()&&Ki<=max_ki*0.25) Toggle_ki_shield()

		m.BP=m.get_bp()
		d=get_dir(m,src)
		spawn(2) if(m&&!m.KB) step(m,pick(d,turn(d,45),turn(d,-45)))
		if(!m.Shielding()&&m.Health<=25&&m.Ki>=m.max_ki*0.5) m.Toggle_ki_shield()
		else if(m.Shielding()&&m.Ki<=m.max_ki*0.25) m.Toggle_ki_shield()

		var/list/guys=list(src,m)
		while(guys.len)
			var/mob/attacker=pick(guys)
			guys-=attacker
			attacker.Melee()

		sleep(1)
	var/mob/winner
	var/mob/loser
	if(!KO)
		winner=src
		loser=m
	else
		winner=m
		loser=src
	if(Shielding()) Toggle_ki_shield()
	if(m.Shielding()) m.Toggle_ki_shield()
	FullHeal()
	m.FullHeal()
	Calm()
	m.Calm()
	last_anger=0
	m.last_anger=0
	Stop_Powering_Up()
	m.Stop_Powering_Up()
	spawn if(loser) del(loser)
	winner.fight_copy_of_self()

mob/proc/Random_stat_change()
	var/n=rand(110,140)/100
	var/list/stat_list=list("ki","str","dur","spd","pow","res","off","def","reg","rec","ang")
	if(regen<=0.5||regen>=6) stat_list-="reg"
	if(recov<=0.5||recov>=6) stat_list-="rec"
	if(max_anger<n*100||max_anger>300) stat_list-="ang"
	if(Eff<=0.6||Eff>=5) stat_list-="ki"
	//lower
	var/l=1-(n-1)
	switch(pick(stat_list))
		if("ki")
			Ki*=l
			max_ki*=l
			Eff*=l
		if("str") Str*=l
		if("dur") End*=l
		if("spd") Spd*=l
		if("pow") Pow*=l
		if("res")
			var/old_res=Res
			Res*=l
			world<<"resistance decreased from [round(old_res)] to [round(Res)]"
		if("off") Off*=l
		if("def") Def*=l
		if("reg") regen*=l
		if("rec") recov*=l
		if("ang") max_anger*=l
	//raise
	switch(pick(stat_list))
		if("ki")
			Ki*=n
			max_ki*=n
			Eff*=n
		if("str") Str*=n
		if("dur") End*=n
		if("spd") Spd*=n
		if("pow") Pow*=n
		if("res")
			var/old_res=Res
			Res*=n
			world<<"resistance increased from [round(old_res)] to [round(Res)]"
		if("off") Off*=n
		if("def") Def*=n
		if("reg") regen*=n
		if("rec") recov*=n
		if("ang") max_anger*=n

mob/Admin5/verb/setTransformSize(mob/m in world)
	set name = "Set transform size"
	set category="Admin"
	var/n=input("multiple") as num
	m.transform = matrix() * n

mob/Admin5/verb/testMobList(area/a in world)
	set name = "Test mob list"
	var/mob_count=0
	for(var/v in a.mob_list)
		src<<v
		if(ismob(v)) mob_count++
	src<<"mobs in list: [mob_count]"
	src<<"length of list: [a.mob_list.len]"
