var/Map_Loaded
var/const/MAP_SAVE_SEGMENT_SIZE = 20000

proc/getMapSavePath(segment = 1)
	segment = max(1, round(segment))
	return "data/Map[segment]"

proc/writeMapSaveSegment(segment, list/types, list/healths, list/builders, list/xs, list/ys, list/zs, list/fly_over, list/build_edges = null, list/build_elevations = null)
	var/savefile/f = new(getMapSavePath(segment))
	f["Types"] << types
	f["Healths"] << healths
	f["Builders"] << builders
	f["Xs"] << xs
	f["Ys"] << ys
	f["Zs"] << zs
	f["FlyOver"] << fly_over
	f["BuildEdges"] << build_edges
	f["BuildElevations"] << build_elevations

proc/writeMapSaveManifest(segment_count)
	var/savefile/manifest = new("data/MapManifest")
	manifest["SegmentCount"] << segment_count

proc/getMapSaveSegmentCount()
	if(!fexists("data/MapManifest")) return 0
	var/savefile/manifest = new("data/MapManifest")
	var/segment_count
	manifest["SegmentCount"] >> segment_count
	return max(0, round(segment_count))

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
	var/segments_written = 0
	var/list/types=new
	var/list/healths=new
	//var/list/Levels=new
	var/list/builders=new
	var/list/xs=new
	var/list/ys=new
	var/list/zs=new
	var/list/fly_over=new
	var/list/build_edges=new
	var/list/build_elevations=new
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
		build_edges += a.build_edges_enabled
		build_elevations += a.build_elevation
		amount+=1
		if(amount % MAP_SAVE_SEGMENT_SIZE == 0)
			writeMapSaveSegment(e, types, healths, builders, xs, ys, zs, fly_over, build_edges, build_elevations)
			segments_written = e
			e ++
			types=new
			healths=new
			//Levels=new
			builders=new
			xs=new
			ys=new
			zs=new
			fly_over=new
			build_edges=new
			build_elevations=new

	if(amount % MAP_SAVE_SEGMENT_SIZE != 0 || !segments_written)
		writeMapSaveSegment(e, types, healths, builders, xs, ys, zs, fly_over, build_edges, build_elevations)
		segments_written = e

	writeMapSaveManifest(segments_written)

	world<<"Map Saved ([amount])"

proc/mapLoad()
	//set background = 1
	Map_Loaded=1
	if(fexists("data/Map1"))
		var/amount=0
		var/debug_amount= 0
		var/e=1
		var/segment_count = getMapSaveSegmentCount()
		load
		if(segment_count && e > segment_count)
			goto end
		var/map_path = getMapSavePath(e)
		if(!fexists(map_path))
			goto end
		var/savefile/f=new(map_path)
		sleep(1)
		var/list/types=f["Types"]
		var/list/healths=f["Healths"]
		var/list/builders=f["Builders"]
		var/list/xs=f["Xs"]
		var/list/ys=f["Ys"]
		var/list/zs=f["Zs"]
		var/list/fly_over=f["FlyOver"]
		var/list/build_edges=f["BuildEdges"]
		var/list/build_elevations=f["BuildElevations"]

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
			t.build_edges_enabled = islist(build_edges) && amount <= build_edges.len && build_edges[amount]
			t.build_elevation = getSavedBuildElevation(build_elevations,amount)
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

			if(amount == MAP_SAVE_SEGMENT_SIZE)
				sleep(world.tick_lag)
				break

		if(amount == MAP_SAVE_SEGMENT_SIZE)
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
	var/list/build_edges=f["BuildEdges"]
	var/list/build_elevations=f["BuildElevations"]
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
		t.build_edges_enabled = islist(build_edges) && amount <= build_edges.len && build_edges[amount]
		t.build_elevation = getSavedBuildElevation(build_elevations,amount)
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
	for(var/turf/t in Turfs) t.refreshBuildEdges()
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
var/list/builds_by_category = new
var/list/build_search_index = new

proc/getCatalogSearchTokens(search_text)
	var/normalized_text = lowertext("[search_text]")
	for(var/separator in list("/", "\\", "-", "_", ".", ":", "(", ")", "\[", "]"))
		normalized_text = replacetext(normalized_text, separator, " ")
	var/list/tokens = list()
	for(var/token in dd_text2list(normalized_text, " "))
		if(length(token) < 2 || (token in tokens)) continue
		tokens += token
	return tokens

proc/registerCatalogSearchEntry(list/search_index, atom/entry, search_text)
	if(!islist(search_index) || !entry) return
	for(var/token in getCatalogSearchTokens(search_text))
		for(var/prefix_length = 2, prefix_length <= length(token), prefix_length++)
			var/prefix = copytext(token, 1, prefix_length + 1)
			if(!islist(search_index[prefix])) search_index[prefix] = list()
			var/list/prefix_entries = search_index[prefix]
			if(!(entry in prefix_entries)) prefix_entries += entry

proc/searchCatalogIndex(list/search_index, query, list/category_entries, maximum_results = 100)
	maximum_results = max(1, round(maximum_results))
	var/list/query_tokens = getCatalogSearchTokens(query)
	if(!query_tokens.len)
		var/list/unfiltered_results = islist(category_entries) ? category_entries.Copy() : list()
		if(unfiltered_results.len > maximum_results) unfiltered_results.Cut(maximum_results + 1)
		return unfiltered_results
	var/list/results
	for(var/token in query_tokens)
		var/list/token_entries = search_index[token]
		if(!islist(token_entries)) return list()
		if(!islist(results)) results = token_entries.Copy()
		else
			for(var/atom/entry in results.Copy())
				if(!(entry in token_entries)) results -= entry
	if(!islist(results)) return list()
	for(var/atom/entry in results.Copy())
		if(islist(category_entries) && !(entry in category_entries)) results -= entry
	if(results.len > maximum_results) results.Cut(maximum_results + 1)
	return results

proc/rebuildBuildCatalogIndexes()
	builds_by_category = list()
	build_search_index = list()
	for(var/obj/Build/build_entry in Builds)
		var/category_key = "category-[build_entry.build_category]"
		if(!islist(builds_by_category[category_key])) builds_by_category[category_key] = list()
		var/list/category_entries = builds_by_category[category_key]
		category_entries += build_entry
		registerCatalogSearchEntry(build_search_index, build_entry, "[build_entry.name] [build_entry.Creates]")

proc/getBuildCatalogForCategory(build_category)
	var/list/category_entries = builds_by_category["category-[build_category]"]
	return islist(category_entries) ? category_entries : list()

proc/searchBuildCatalog(query, build_category = null, maximum_results = 100)
	var/list/category_entries
	if(!isnull(build_category)) category_entries = getBuildCatalogForCategory(build_category)
	else category_entries = Builds
	return searchCatalogIndex(build_search_index, query, category_entries, maximum_results)

proc/addBuilds()
	for(var/a in typesof(/turf))
		var/turf/c=new a(locate(1,1,1))
		if(c) if(c.Buildable && c.type!=/turf&&c.type!=/turf/warp)
			var/obj/Build/b=new
			b.build_category = c.build_category
			b.icon=c.icon
			b.icon_state=c.icon_state
			b.Creates=c.type
			b.dir=c.dir
			b.pixel_x=c.pixel_x
			b.pixel_y=c.pixel_y
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
			c.dir=b.dir
			c.pixel_x=b.pixel_x
			c.pixel_y=b.pixel_y
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
			c.dir=b.dir
			c.pixel_x=b.pixel_x
			c.pixel_y=b.pixel_y
			c.name="[b.name]-B"
			Builds+=c
	for(var/a in typesof(/obj/Edges))
		var/obj/b=new a
		if(b) if(b.Buildable&&b.type!=/obj/Trees)
			var/obj/Build/c=new
			c.icon=b.icon
			c.icon_state=b.icon_state
			c.Creates=b.type
			c.dir=b.dir
			c.pixel_x=b.pixel_x
			c.pixel_y=b.pixel_y
			c.name="[b.name]-B"
			Builds+=c
	for(var/a in typesof(/obj/Surf))
		var/obj/b=new a
		if(b) if(b.Buildable&&b.type!=/obj/Trees)
			var/obj/Build/c=new
			c.icon=b.icon
			c.icon_state=b.icon_state
			c.Creates=b.type
			c.dir=b.dir
			c.pixel_x=b.pixel_x
			c.pixel_y=b.pixel_y
			c.name="[b.name]-B"
			Builds+=c
	rebuildBuildCatalogIndexes()

mob/var/tmp/turf_lay_cost=0

obj/Build
	var
		Creates

	Click()
		if(usr) usr.selectBuildBlueprint(src)

mob/proc/selectBuildBlueprint(obj/Build/build)
	if(!build || !(build in Builds) || !is_out_of_combat(src)) return FALSE
	if(client)
		if(!client.nexus_build_window) client.nexus_build_window = new(src)
		if(!client.nexus_build_window.active) client.nexus_build_window.show()
		return client.nexus_build_window.selectBlueprint(build)
	build_brush = build
	return TRUE

mob/proc/turfLayCost()
	var/n = 1000 * 1.6**(Turfs.len/10000)
	n=round(n,1000)
	if(n>100000) n=100000
	if(IsAdmin() && admins_build_free) return 0
	return n * building_price_mult

mob/proc/stopBuildingThings()
	build_brush = null
	if(client && client.nexus_build_window)
		client.nexus_build_window.cancelStroke()
		client.nexus_build_window.refreshStatus()

proc/isInVoid(mob/m)
	if(!m) return
	var/turf/t = m.base_loc()
	if(!t) return 1
	if(t.type == /turf/Other/Blank) return 1

proc/buildLay(obj/Build/o,mob/p,turf/destination, decorate = TRUE, datum/NexusBuildWindow/session = null, obj/CustomDecorBlueprint/custom = null)
	if(!p || p.KO || !destination) return
	if(session && session.owner != p) return
	if(custom)
		if(!customBuildAllowed || !(custom in customDecors) || (custom.creator != p.ckey && !p.IsAdmin())) return
	else if(!o || !(o in Builds)) return
	var/owner_key = p.getBuildOwnerKey()
	if(!owner_key) return
	var/owner_ckey = ckey(owner_key)
	var/build_type = custom ? /obj/Turfs/Custom : o.Creates
	if(!p.is_out_of_combat(victim = p))
		p.stopBuildingThings()
		return
	if(!p.canReachBuildTile(destination)) return

	if(p.AtBattlegrounds() || istype(destination.loc,/area/Battlegrounds))
		p << "You can not build here"
		p.stopBuildingThings()
		return

	var/turf/t2 = destination
	if(!t2 || !isturf(t2))
		p.stopBuildingThings()
		return

	var/turf/true_loc=destination
	if(!true_loc.Builder && true_loc && isturf(true_loc) && true_loc.z==5 && true_loc.type!=/turf/Other/Sky2)
		var/turf/death_spawn=locate(death_x,death_y,death_z)
		if(get_dist(true_loc,death_spawn) < checkpointBuildDist)
			p<<"Building is not allowed here except on the clouds"
			p.stopBuildingThings()
			return

	if(destination.type == /turf/Other/Blank)
		if(!can_build_in_void && !p.IsAdmin())
			p.stopBuildingThings()
			return
		if(!admins_can_build_in_void && p.IsAdmin())
			p.stopBuildingThings()
			return

	if(prison_exit&&p.z==prison_exit.z&&getdist(destination,prison_exit)<=20)
		p<<"You can not build this close to the prison exit"
		p.stopBuildingThings()
		return

	if(istype(destination.loc,/area/tournament_area))
		p<<"Building here is impossible"
		p.stopBuildingThings()
		return

	if(istype(destination.loc,/area/God_Ki_Realm))
		p<<"Building here is impossible"
		p.stopBuildingThings()
		return

	if(istype(destination.loc,/area/Braal_Core))
		p<<"Building here is impossible"
		p.stopBuildingThings()
		return

	for(var/obj/Fighter_Spot/f in Fighter_Spots) if(f.z==p.locz()&&getdist(f,destination)<=12)
		p<<"You can not build near the tournament"
		p.stopBuildingThings()
		return

	var/res_cost = custom ? customDecorBuildCost : p.turfLayCost()
	if(p.z == Z_LEVEL_SPACE && res_cost != 0) res_cost += 10000 * building_price_mult

	if(res_cost != 0)
		var/obj/Spawn/s
		for(s in Spawn_List) if(!s.Builder&&s.z==p.z&&getdist(s,destination)<=20) break
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

	for(var/turf/t in range(0,destination))
		if(t.Builder && t.Builder!=owner_key && p.maxTurfUpgrade()<t.Health*0.95)
			p<<"You can not build over this person's turfs because it was built with knowledge too far \
			beyond yours."
			p.stopBuildingThings()
			return
		if(istype(t,/turf/Teleporter))
			p<<"You can not build this close to entrances"
			p.stopBuildingThings()
			return
		if(locate(/obj/Bank) in t) return

	for(var/obj/Turfs/Door/d in range(0,destination)) if(d.Password==7125)
		p<<"You can not build over the time chamber door"
		p.stopBuildingThings()
		return

	if(!Built_Objs) initializeBuiltObjs()
	var/atom/D=destination
	if(!D.loc) return
	var/blocked_by_turret = FALSE

	for(var/obj/Turret/T in view(15,D)) if(T.z&&T.z==D.z&&getdist(T,D)<=15&&T.Password)
		var/has_pass = FALSE
		for(var/obj/items/Door_Pass/i in p.item_list) if(istype(i, /obj/items/AdvancedDoorPass) || i.Password==T.Password) has_pass = TRUE
		if(!has_pass) blocked_by_turret = TRUE
	if(blocked_by_turret)
		p<<"You cannot build this close to turrets that want to attack you"
		return

	//for(var/obj/Controls/N in view(1,locate(D.x,D.y,D.z)))
	//	P<<"You cannot build this close to ship controls"
	//	return
	for(var/obj/Warper/w in view(1,locate(D.x,D.y,D.z)))
		p<<"You cannot build this close to warpers."
		return
	if(!D) return

	if(ispath(build_type,/obj))
		var/object_count = 0
		for(var/obj/existing in destination) object_count++
		if(object_count >= 4) return
	var/build_elevation = destination.build_elevation
	if(decorate && p.build_auto_cliffs && ispath(build_type,/turf))
		var/turf/material = build_type
		if(!initial(material.Water) && !initial(material.density) && initial(material.build_category) == BUILD_GROUND && initial(material.auto_cliff))
			build_elevation = session && !isnull(session.stroke_elevation) ? session.stroke_elevation : build_elevation+1
	var/atom/c = new build_type(destination)

	if(!c) return
	c.Builder=owner_key
	if(isobj(c))


		if(!(owner_ckey in Built_Objs)) Built_Objs[ckey(owner_key)]=new/list
		var/list/L=Built_Objs[ckey(owner_key)]
		L+=c
		Built_Objs[ckey(owner_key)]=L

		c:Spawn_Timer=0
		if(istype(c,/obj/Turfs/Sign)||istype(c,/obj/Turfs/Glass))
			c.Bolted=owner_key

	if(istype(c,/obj/Turfs/Door))
		var/new_password = session ? session.door_password : input(p,"Enter a password or leave blank") as text
		if(!c) return
		c.Password=new_password
		if(isobj(c)) c:Grabbable=0



	if(istype(c,/obj/Turfs/Sign))
		var/txt = session ? session.sign_text : input(p,"What do you want to write on the sign?","options") as text
		if(!c) return
		c.maptext = txt
		c.maptext="<b><font color=cyan>[c.maptext]"
	if(custom)
		c.name = custom.name
		c.icon = custom.icon
		c.icon_state = custom.icon_state
		c.desc = custom.desc
		c.alpha = custom.alpha
		c.pixel_x = custom.pixel_x
		c.pixel_y = custom.pixel_y
		c.density = custom.density
		c:clickMsg = custom.clickMsg
		c.layer = custom.layer
		custom.lastUsed = world.realtime
	if(session && isobj(c)) c.dir = session.brush_direction
	if(!isturf(c)) c.Savable=1
	else
		c.Savable=0
		//new/area/Inside(locate(P.x,P.y,P.z))
		for(var/obj/Edges/e in c) del(e)
		for(var/obj/Surf/e in c) del(e)
		for(var/obj/Trees/e in c) del(e)
		for(var/obj/Turfs/e in c) del(e)
		Turfs+=c

		if(!(owner_key in built_turfs)) built_turfs[owner_key]=new/list
		var/list/l=built_turfs[owner_key]
		l+=c
		built_turfs[owner_key]=l

		c:build_elevation = build_elevation
		c:build_edges_enabled = decorate && p.build_auto_edges
		GenerateFeaturesOnBuildLay(c)

	p.Alter_Res(-res_cost)
	if(isturf(c))
		if(!session || !session.committing)
			if(decorate && p.build_auto_cliffs) p.placeBuildCliff(c,TRUE)
			refreshBuildEdgesAround(c)
	return c




var/list/Built_Objs

proc/initializeBuiltObjs()
	Built_Objs = new/list
	for(var/obj/Turfs/t)
		if(t.Builder && t.Savable)
			if(!(ckey(t.Builder) in Built_Objs)) Built_Objs[ckey(t.Builder)] = new/list
			var/list/l = Built_Objs[ckey(t.Builder)]
			l += t
			Built_Objs[ckey(t.Builder)] = l
