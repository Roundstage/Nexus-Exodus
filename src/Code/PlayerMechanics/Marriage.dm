mob/var/tmp/spouse_key

obj/Priest
	desc="Click this priest to get married"
	Cost=0
	density=1
	icon='Android.dmi'
	Health=50000
	takes_gradual_damage=1
	Makeable=1
	New()
		overlays-='ClothesTuxedo.dmi'
		overlays+='ClothesTuxedo.dmi'
		. = ..()
	Click()
		if(getdist(usr,src)>1) return

		if(usr.spouse_key&&Get_by_key(usr.spouse_key))
			usr.Divorce()
			return

		var/list/mobs=list("Cancel")
		for(var/mob/m in range(1,src)) if(m!=usr&&m.client) mobs+=m
		if(mobs.len<=2) mobs-="Cancel"
		var/mob/m=input(usr,"Which person do you want to marry?") in mobs
		if(!m)
			usr<<"Someone else must be with you if you want to get married"
			return
		if(m=="Cancel") return
		if(getdist(usr,src)>1)
			usr<<"You moved. Try again"
			return
		if(getdist(m,src)>1)
			usr<<"They moved. Try again"
			return
		m.spouse_key=usr.key
		player_view(center=src)<<"<font color=red>[usr] and [m] are now married"
		spawn if(m) alert(m,"[usr] has married you. If you wish to file for divorce click the priest npc")
	verb/Bolt()
		set src in oview(1)
		usr.Bolt(src)
	verb/Upgrade()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence()*15
			if(Health<max_health)
				player_view(center=usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"

mob/proc/Divorce()
	var/mob/m=Get_by_key(spouse_key)
	if(!m)
		spouse_key=null
		return
	spouse_key=null
	alert(src,"Apparently this does nothing")

// Legacy event retained for save and admin compatibility.
mob/proc/Kilt_by_redneck()
	move=0
	var/turf/t=base_loc()
	for(var/v in 1 to 30)
		if(Get_step(t,WEST)) t=Get_step(t,WEST)
		else break
	var/mob/m=new(t)
	m.name="REDNECK"
	m.icon='Farmer.dmi'
	m.TextColor="green"
	m.attackable=0
	m.BP=1.#INF
	Timed_Delete(m,10*600)
	for(var/v in 1 to 100)
		if(!m) return
		m.SafeTeleport(Get_step(m,get_dir(m,src)))
		if(getdist(m,src)<=5&&(src in view(5,m))) break
		sleep(2)
	if(!m) return
	m.Say("SON I AM DISAPPOINT")
	sleep(35)
	m.Say("GAWD hates QUEEROSEXUALS boy")
	sleep(35)
	m.Say("LARD JEEZUS PLEASE RAIN THE HELLFIRE DOWN UPON THESE HEATHEN SCUM")
	sleep(35)
	for(var/mob/a in player_view(20,m)) a.ScreenShake(300)
	sleep(35)
	m.Say("CLEANSE THEIR SOULS OF THE SIN KNOWN AS HOMOSEXUALITY AND LET THEM BURN IN HELL FOR ALL ETERNITY")
	sleep(35)
	spawn while(m)
		sleep(55)
		if(m) m.Say("ALAHEAHLALEHAHELUAEHALEEIOEALELIAEIOAEHLALEAHELALHAHLEHAHLAHLEALLEHALHE")
		if(prob(15)) break
	sleep(60)
	t=base_loc()
	for(var/v in 1 to 4)
		if(Get_step(t,NORTH)) t=Get_step(t,NORTH)
		else break
	var/mob/jesus=new(t)
	jesus.icon='Jesus.dmi'
	jesus.name="JEEZUS"
	jesus.BP=1.#INF
	jesus.attackable=0
	Timed_Delete(jesus,10*600)
	player_view(15,src)<<"<font color=yellow>A WILD JEEZUS APPEARS"
	sleep(40)
	jesus.Emote("rains hellfires down upon the heathens!!")
	sleep(30)
	var/list/turfs=new
	for(var/turf/t2 in view(7,src)) turfs+=t2
	for(var/v in 1 to 90)
		t=pick(turfs)
		Explosion_Graphics(t,5)
		for(var/mob/m2 in view(4,t)) if(m2.client)
			m2.TakeDamage(4)
			if(m2.Health<=0) m2.Death("JEEZUS")
		sleep(1)
	sleep(40)
	jesus.Emote("and the redneck return to heaven")
	sleep(35)
	Explosion_Graphics(jesus.loc,5)
	del(jesus)
	Explosion_Graphics(m.loc,5)
	del(m)
	move=1
