var/Map_Loaded

/*proc/Save_Map()
	var/turf_count=0
	var/list/turf_info=new
	for(var/turf/t in Turfs)
		turf_count++
		turf_info[turf_count]=list("Type"=t.type,"Health"=t.Health,"Builder"=t.Builder,"x"=t.x,"y"=t.y,\
		"z"=t.z,"Flyable"=t.FlyOverAble)*/

proc/mapSave()
	//set background = 1
	var/amount=0
	var/e=1
	var/savefile/f=new("data/Map[e]")
	var/list/types=new
	var/list/healths=new
	//var/list/Levels=new
	var/list/builders=new
	var/list/xs=new
	var/list/ys=new
	var/list/zs=new
	var/list/fly_over=new
	for(var/turf/a in Turfs) if(a.Builder)
		types+=a.type

		//Healths+="[num2text(round(A.Health),100)]"
		healths += a.Health

		//Levels+="[num2text(A.Level,100)]"
		builders+=a.Builder
		xs+=a.x
		ys+=a.y
		zs+=a.z
		fly_over+=a.FlyOverAble
		amount+=1
		if(amount % 20000 == 0)
			f["Types"]<<types
			f["Healths"]<<healths
			//F["Levels"]<<Levels
			f["Builders"]<<builders
			f["Xs"]<<xs
			f["Ys"]<<ys
			f["Zs"]<<zs
			f["FlyOver"]<<fly_over
			e ++
			f=new("Map[e]")
			types=new
			healths=new
			//Levels=new
			builders=new
			xs=new
			ys=new
			zs=new
			fly_over=new

	if(amount % 20000 != 0)
		f["Types"]<<types
		f["Healths"]<<healths
		//F["Levels"]<<Levels
		f["Builders"]<<builders
		f["Xs"]<<xs
		f["Ys"]<<ys
		f["Zs"]<<zs
		f["FlyOver"]<<fly_over

	world<<"Map Saved ([amount])"

proc/mapLoad()
	//set background = 1
	Map_Loaded=1
	if(fexists("data/Map1"))
		var/amount=0
		var/debug_amount= 0
		var/e=1
		load
		if(!fexists("data/Map[e]"))
			goto end
		var/savefile/f=new("data/Map[e]")
		sleep(1)
		var/list/types=f["Types"]
		var/list/healths=f["Healths"]
		var/list/builders=f["Builders"]
		var/list/xs=f["Xs"]
		var/list/ys=f["Ys"]
		var/list/zs=f["Zs"]
		var/list/fly_over=f["FlyOver"]

		clients << "Map Load Stage 1 Begin"
		sleep(5)

		amount = 0
		for(var/a in types)
			amount+=1
			debug_amount += 1
			var/turf/t = new a(locate(xs[amount], ys[amount], zs[amount]))

			t.Health = healths[amount]
			if(t.Health == "inf") t.Health = 1.#INF
			if(istext(t.Health)) t.Health = text2num(t.Health)

			t.Builder = builders[amount]
			t.FlyOverAble = text2num(fly_over[amount])
			Turfs += t

			if(!(t.Builder in built_turfs)) built_turfs[t.Builder] = new/list
			var/list/l = built_turfs[t.Builder]
			l += t
			built_turfs[t.Builder] = l

			for(var/obj/o in t)
				if(!o.Builder && (o.type in list(/obj/Edges, /obj/Surf, /obj/Trees, /obj/Turfs)))
					o.reallyDelete = 1
					o.respawn_on_delete = 0
					o.DeleteNoWait();
					o.SafeTeleport(null)

			if(amount == 20000)
				sleep(world.tick_lag)
				break

		if(amount == 20000)
			e ++
			goto load

		end
		world<<"Map Loaded ([debug_amount] in [e] Files.)"

		GenerateFeaturesOnPlayerTurfsOnMapLoad()

//load an external map file on top of everything that is already loaded, this is for like if admins are building special admin buildings on another server
//and they want to then put what they built into the main player server they can just load it on top of that using the map files externally and also so
//they dont have to shut down the server to do it
proc/mapLoadExternal(savefile/f)
	if(!f)
		clients << "No file was passed"
		return
	f = new(f)
	var/amount=0
	var/debug_amount= 0
	sleep(1)
	var/list/types=f["Types"]
	var/list/healths=f["Healths"]
	var/list/builders=f["Builders"]
	var/list/xs=f["Xs"]
	var/list/ys=f["Ys"]
	var/list/zs=f["Zs"]
	var/list/fly_over=f["FlyOver"]
	sleep(5)
	amount = 0
	for(var/a in types)
		amount+=1
		debug_amount += 1
		var/turf/t = new a(locate(xs[amount], ys[amount], zs[amount]))
		t.Health = healths[amount]
		if(t.Health == "inf") t.Health = 1.#INF
		if(istext(t.Health)) t.Health = text2num(t.Health)
		t.Builder = builders[amount]
		t.FlyOverAble = text2num(fly_over[amount])
		Turfs += t
		if(!(t.Builder in built_turfs)) built_turfs[t.Builder] = new/list
		var/list/l = built_turfs[t.Builder]
		l += t
		built_turfs[t.Builder] = l
		for(var/obj/o in t)
			if(!o.Builder && (o.type in list(/obj/Edges, /obj/Surf, /obj/Trees, /obj/Turfs)))
				o.reallyDelete = 1
				o.respawn_on_delete = 0
				o.DeleteNoWait();
				o.SafeTeleport(null)
	world<<"<font color=yellow>External map loaded (+[debug_amount] turfs)"

var/Turf_Strength = 2 //this many times the upgrade value
var/max_turf_str = 10

mob/proc/maxTurfUpgrade()
	var/n = Knowledge * Turf_Strength * (Intelligence() ** wall_INT_scaling)
	n *= 1 //arbitrary
	return n

mob/var/tmp/last_wall_upgrade=0 //world.time

turf/proc
	makeDenseAll(mob/m)
		set background=1
		if(m&&world.time>m.last_wall_upgrade+10)
			spawn(1) if(m) m.last_wall_upgrade=world.time
			/*spawn for(var/turf/T in built_turfs[Builder])
				if(T.density)
					T.FlyOverAble = 0*/
			//m.last_wall_upgrade=world.time
			if(Builder in built_turfs)
				for(var/turf/t in built_turfs[Builder])
					if(t.density)
						t.FlyOverAble = 0
		else m<<"You can only do this once every 1 seconds (to prevent lag)"

	upgradeAll(mob/m,display_message=0,for_free=0)
		set background=1

		//if an admin does it, ask first, cuz it may be to inf health on accident
		if(m && m.client && m.Knowledge > Tech_BP * 2)
			switch(alert(m,"Upgrade [Builder]'s Wall Beyond the Knowledge Cap?","Options","No","Yes"))
				if("No") return

		if(m && world.time > m.last_wall_upgrade + 10)

			spawn(1) if(m) m.last_wall_upgrade=world.time
			//m.last_wall_upgrade = world.time

			var/max_upgrade=m.maxTurfUpgrade()
			var/cost=round(1000/m.Intelligence())
			if(m.Res()<cost&&!for_free)
				m<<"You need at least [Commas(cost)]$ to upgrade a wall"
				return
			m.Alter_Res(-cost)
			player_view(15,m)<<"[usr] upgrades [Builder]'s walls to [Commas(max_upgrade)] battle power, if they were below that \
			amount already. (Cost: [Commas(cost)]$)"

			/*spawn for(var/turf/T in built_turfs[Builder]) if(T.Health<Max_Upgrade)
				T.Health=Max_Upgrade
				//sleep(1)
			spawn
				if(ckey(Builder) in Built_Objs)
					var/list/L=Built_Objs[ckey(Builder)]
					for(var/obj/o in L) if(o.Health<Max_Upgrade) o.Health=Max_Upgrade*/
			if(Builder in built_turfs)
				for(var/turf/t in built_turfs[Builder]) if(t.Health<max_upgrade)
					t.Health=max_upgrade
			if(ckey(Builder) in Built_Objs)
				var/list/l=Built_Objs[ckey(Builder)]
				for(var/obj/o in l) if(o.Health<max_upgrade) o.Health=max_upgrade

		else if(display_message) m<<"You can only do this once every 1 seconds (to prevent lag)"

turf/verb/upgrade()
	set name = "Upgrade"
	set src in view(1)
	if(!Builder)
		usr<<"You can only use this on things built by players"
		return
	if(!usr.Intelligence())
		usr<<"You do not have any intelligence to do this"
		return
	if(!Built_Objs) initializeBuiltObjs()
	var/list/options=list("Upgrade and make dense all","Upgrade all")
	if(Builder==usr.key)
		if(FlyOverAble) options+="Make dense all"
		else options+="Make undense all"
	switch(input("Options") in options)
		if("Upgrade and make dense all")
			makeDenseAll(usr)
			upgradeAll(usr,display_message=0)
		if("Make dense all") makeDenseAll(usr)
		if("Make undense all")
			if(Builder in built_turfs)
				var/list/l=built_turfs[Builder]
				for(var/turf/t in l) t.FlyOverAble = 1
		if("Upgrade all") upgradeAll(usr)






var/list/Turfs=new
var/list/built_turfs=new //newer, includes directories by key
turf/var/FlyOverAble=1
atom/var/Buildable=1

var/list/Builds=new

proc/addBuilds()
	for(var/a in typesof(/turf))
		var/turf/c=new a(locate(1,1,1))
		if(c) if(c.Buildable && c.type!=/turf&&c.type!=/turf/warp)
			var/obj/Build/b=new
			b.build_category = c.build_category
			b.icon=c.icon
			b.icon_state=c.icon_state
			b.Creates=c.type
			b.name="[c.name]-B"
			Builds+=b
		del(c)
	for(var/a in typesof(/obj/Turfs))
		var/obj/b=new a
		if(b) if(b.Buildable && b.type!=/obj/Turfs && b.build_category != BUILD_CUSTOM)
			var/obj/Build/c=new
			c.build_category = BUILD_DECOR
			c.icon=b.icon
			c.icon_state=b.icon_state
			c.Creates=b.type
			c.name="[b.name]-B"
			Builds+=c
	for(var/a in typesof(/obj/Trees))
		var/obj/b=new a
		if(b) if(b.Buildable&&b.type!=/obj/Trees)
			var/obj/Build/c=new
			c.build_category = BUILD_TREES
			c.icon=b.icon
			c.icon_state=b.icon_state
			c.Creates=b.type
			c.name="[b.name]-B"
			Builds+=c
	for(var/a in typesof(/obj/Edges))
		var/obj/b=new a
		if(b) if(b.Buildable&&b.type!=/obj/Trees)
			var/obj/Build/c=new
			c.icon=b.icon
			c.icon_state=b.icon_state
			c.Creates=b.type
			c.name="[b.name]-B"
			Builds+=c
	for(var/a in typesof(/obj/Surf))
		var/obj/b=new a
		if(b) if(b.Buildable&&b.type!=/obj/Trees)
			var/obj/Build/c=new
			c.icon=b.icon
			c.icon_state=b.icon_state
			c.Creates=b.type
			c.name="[b.name]-B"
			Builds+=c

mob/var/tmp/turf_lay_cost=0

obj/Build
	var
		Creates

	Click()
		if(!usr.is_out_of_combat(victim = usr))
			var/combat_timer = round((KO_SYSTEM_OUT_OF_COMBAT_TIMER - usr.get_time_out_of_combat(victim = usr)) / 10, 1)
			usr << "You can not build while in combat. You will be able to build again in [combat_timer] seconds."
			return
		if(usr.Target==src)
			usr<<"You have deselected [src]"
			usr.Target=null
			return
		usr.turf_lay_cost = usr.turfLayCost()
		buildLay(src,usr)
		if(usr.Target!=src)
			usr.Target=src
			usr<<"You have selected [src]"
			usr<<"It will cost [Commas(usr.turfLayCost())] resources per tile you build. This cost will go up later based on how much tiles \
			have been built by all players."
		if(usr.client) winset(usr,"mapwindow.map","focus=true")
		if(usr.client) winset(usr,"mainwindow.map","focus=true")

mob/proc/turfLayCost()
	var/n = 1000 * 1.6**(Turfs.len/10000)
	n=round(n,1000)
	if(n>100000) n=100000
	if(IsAdmin() && admins_build_free) return 0
	return n * building_price_mult

mob/proc/stopBuildingThings()
	Target = null

proc/isInVoid(mob/m)
	if(!m) return
	var/turf/t = m.base_loc()
	if(!t) return 1
	if(t.type == /turf/Other/Blank) return 1

proc/buildLay(obj/Build/o,mob/p) if(!p.KO) //Type to build, player who is building it, location to put it
	set waitfor=0

	if(p.AtBattlegrounds())
		p << "You can not build here"
		p.stopBuildingThings()
		return

	var/turf/t2 = p.loc
	if(!t2 || !isturf(t2))
		p.stopBuildingThings()
		return

	var/turf/true_loc=p.base_loc()
	if(!true_loc.Builder && true_loc && isturf(true_loc) && true_loc.z==5 && true_loc.type!=/turf/Other/Sky2)
		var/turf/death_spawn=locate(death_x,death_y,death_z)
		if(get_dist(true_loc,death_spawn) < checkpointBuildDist)
			p<<"Building is not allowed here except on the clouds"
			p.Target=null
			return

	if(isInVoid(p))
		if(!can_build_in_void && !p.IsAdmin())
			p.stopBuildingThings()
			return
		if(!admins_can_build_in_void && p.IsAdmin())
			p.stopBuildingThings()
			return

	if(prison_exit&&p.z==prison_exit.z&&getdist(p,prison_exit)<=20)
		p<<"You can not build this close to the prison exit"
		p.stopBuildingThings()
		return

	if(istype(p.get_area(),/area/tournament_area))
		p<<"Building here is impossible"
		p.stopBuildingThings()
		return

	if(istype(p.get_area(),/area/God_Ki_Realm))
		p<<"Building here is impossible"
		p.stopBuildingThings()
		return

	if(istype(p.get_area(),/area/Braal_Core))
		p<<"Building here is impossible"
		p.stopBuildingThings()
		return

	for(var/obj/Fighter_Spot/f in Fighter_Spots) if(f.z==p.locz()&&getdist(f,p)<=12)
		p<<"You can not build near the tournament"
		p.stopBuildingThings()
		return

	var/res_cost = p.turf_lay_cost
	if(p.z == Z_LEVEL_SPACE && res_cost != 0) res_cost += 10000 * building_price_mult

	if(res_cost != 0)
		var/obj/Spawn/s
		for(s in Spawn_List) if(!s.Builder&&s.z==p.z&&getdist(s,p)<=20) break
		if(s)
			res_cost += 100000 * building_price_mult
			if(p.Res()<res_cost)
				p<<"It costs [res_cost] resources per tile to build this close to a non-player made spawn"
				p.stopBuildingThings()
				return

	if(p.Res()<res_cost)
		p<<"You need [res_cost] resources per tile you build"
		p.stopBuildingThings()
		return

	for(var/turf/t in range(0,p))
		if(t.Builder && t.Builder!=p.key && p.maxTurfUpgrade()<t.Health*0.95)
			p<<"You can not build over this person's turfs because it was built with knowledge too far \
			beyond yours."
			p.stopBuildingThings()
			return
		if(istype(t,/turf/Teleporter))
			p<<"You can not build this close to entrances"
			p.stopBuildingThings()
			return
		if(locate(/obj/Bank) in t) return

	for(var/obj/Turfs/Door/d in range(0,p)) if(d.Password==7125)
		p<<"You can not build over the time chamber door"
		p.stopBuildingThings()
		return

	if(!Built_Objs) initializeBuiltObjs()
	var/atom/D=p
	if(p.Ship) D=p.Ship
	if(!D.loc) return
	var/Turrets

	for(var/obj/Turret/T in Turrets) if(T.z&&T.z==D.z&&getdist(T,D)<=15&&T.Password)
		Turrets=1
		for(var/obj/items/Door_Pass/i in p.item_list) if(i.Password==T.Password) Turrets=0
	if(Turrets)
		p<<"You cannot build this close to turrets that want to attack you"
		return

	//for(var/obj/Controls/N in view(1,locate(D.x,D.y,D.z)))
	//	P<<"You cannot build this close to ship controls"
	//	return
	for(var/obj/Warper/w in view(1,locate(D.x,D.y,D.z)))
		p<<"You cannot build this close to warpers."
		return
	if(!D) return

	var/atom/c
	if(copytext(o.Creates,1,6) == "/turf")
		//C = new O.Creates(locate(D.x,D.y,D.z), skip_auto_gen = 1)
		c = new o.Creates(locate(D.x,D.y,D.z))
	else c = new o.Creates(locate(D.x,D.y,D.z))

	if(!c) return
	c.Builder=p.key
	if(isobj(c))

		p.stopBuildingThings() //so you only place 1 per click instead of til you untoggle it

		if(!(p.ckey in Built_Objs)) Built_Objs[ckey(p.key)]=new/list
		var/list/L=Built_Objs[ckey(p.key)]
		L+=c
		Built_Objs[ckey(p.key)]=L

		c:Spawn_Timer=0
		if(istype(c,/obj/Turfs/Sign)||istype(c,/obj/Turfs/Glass))
			c.Bolted=p.key
		var/turf_objects=0
		for(var/obj/k in range(0,p)) if(!(locate(k) in p)) turf_objects+=1
		if(turf_objects>4)
			p<<"Nothing more can be placed here."
			del(c)
			return

	if(istype(c,/obj/Turfs/Door))
		var/new_password=input(p,"Enter a password or leave blank") as text
		if(!c) return
		c.Password=new_password
		if(isobj(c)) c:Grabbable=0

		p.stopBuildingThings() //Only build 1 door at a time

	if(istype(c,/obj/Turfs/Sign))
		var/txt = input(p,"What do you want to write on the sign?","options") as text
		if(!c) return
		c.maptext = txt
		c.maptext="<b><font color=cyan>[c.maptext]"
	if(!isturf(c)) c.Savable=1
	else
		c.Savable=0
		//new/area/Inside(locate(P.x,P.y,P.z))
		for(var/obj/Edges/e in c) del(e)
		for(var/obj/Surf/e in c) del(e)
		for(var/obj/Trees/e in c) del(e)
		for(var/obj/Turfs/e in c) del(e)
		Turfs+=c

		if(!(p.key in built_turfs)) built_turfs[p.key]=new/list
		var/list/l=built_turfs[p.key]
		l+=c
		built_turfs[p.key]=l

		GenerateFeaturesOnBuildLay(c)

	p.Alter_Res(-res_cost)




var/list/Built_Objs

proc/initializeBuiltObjs()
	Built_Objs = new/list
	for(var/obj/Turfs/t)
		if(t.Builder && t.Savable)
			if(!(ckey(t.Builder) in Built_Objs)) Built_Objs[ckey(t.Builder)] = new/list
			var/list/l = Built_Objs[ckey(t.Builder)]
			l += t
			Built_Objs[ckey(t.Builder)] = l
