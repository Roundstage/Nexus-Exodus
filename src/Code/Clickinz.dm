mob/var/tmp/list/Lootables
mob/var/tmp/mob/injure_loot_target

obj/Cancel_Loot
	name="Cancel"
	Click()
		usr.Lootables = null
		usr.injure_loot_target = null

mob/proc/DisplayItemCost(obj/o)
	set waitfor=0
	sleep(5)
	if(world.time - last_double_click > 10)
		src << "[o] costs [Commas(Item_cost(src, o))] resources for you to make"



mob/var/tmp
	last_double_click = 0

client/DblClick(obj/A, location, control, params)
	if(nexus_build_window && nexus_build_window.consumesMapClick(A,location,control)) return
	mob.last_double_click = world.time
	var/mob/player = usr
	player.TryCreateScienceItem(A)

client/Click(obj/A, location, control, params)
	var/mob/player = usr
	if(nexus_build_window && nexus_build_window.consumesMapClick(A,location,control)) return
	if(player.isTechnologyReferenceClick(A))
		mob.DisplayItemCost(A)
	else if(mob && mob.Lootables && isobj(A) && (A in mob.Lootables) && !istype(A, /obj/Cancel_Loot))
		mob.stealInjureLoot(mob.injure_loot_target, A)
		mob.Lootables = null
		mob.injure_loot_target = null
	else if(A in Alien_Icons) A:Choose(usr)
	else if(A in Demon_Icons) A:Choose(usr)
	else . = ..()







mob/proc/Zanzoken_Drain(N=1)
	N = Clamp(30 / Zanzoken, 1, 1.#INF)
	if(N>max_ki) N=max_ki
	return N

obj/After_Image
	Savable = 0
	mouse_opacity = 0
	attackable = 0
	New()
		flick('src/Icons/Effects/Zanzoken.dmi',src)
	Del()
		alpha = 255
		. = ..()

mob/proc/AfterImage(T = 65, Pixel = 0, turf/loc_override)
	set waitfor=0
	var/turf/t = loc
	if(loc_override) t = loc_override
	if(!(locate(/obj/After_Image) in t))
		var/obj/After_Image/A = GetCachedObject(/obj/After_Image, t)
		A.pixel_x=rand(-Pixel,Pixel)
		A.pixel_y=rand(-Pixel,Pixel)
		A.dir=dir
		A.icon=icon
		A.overlays=overlays
		A.underlays=underlays
		A.invisibility=invisibility
		animate(A, alpha = 0, time = T, easing = CUBIC_EASING)
		Timed_Delete(A, T + world.tick_lag)

mob/var/Zanzoken=1

mob/proc/Charging_or_Streaming()
	if(charging_beam||beaming) return 1
	for(var/obj/Attacks/A in ki_attacks) if(A.charging||A.streaming) return 1

obj/var/tmp/last_use = 0

turf/Click(turf/T, control, params) if(isturf(T))
	if(usr.Disabled()) return
	if(usr.move)
		if(usr.client.eye!=usr) return
		if(usr in src) return

		//EXPLOSION
		if(!usr.attack_barrier_obj || !usr.attack_barrier_obj.Firing_Attack_Barrier)
			for(var/obj/Attacks/Explosion/K in usr.ki_attacks) if(K.On)
				if(skill_engine && skill_engine.handleExplosionClick(usr, T, K)) return
		if(locate(/obj/Turfs/Door) in src) return

		if(usr.CanInputMove() && (!usr.attack_barrier_obj || !usr.attack_barrier_obj.Firing_Attack_Barrier))
			var/obj/Zanzoken/A = usr.getZanzokenSkill()
			if(A && !T.density&&(!T.Water||usr.Flying)&&usr.Ki>=usr.Zanzoken_Drain())

				var/stam_drain = 6
				if(usr.Being_chased()) stam_drain *= 2
				if(usr.stamina < stam_drain) return

				if(usr.dash_attacking) return
				if(usr.BeamStruggling()) return
				if(usr.Charging_or_Streaming()) return
				if(!usr.can_zanzoken||usr.stun_level) return
				if(usr.grabbedObject) return
				if(usr.Beam_stunned()) return
				if(usr.ki_shield_on()) return
				for(var/mob/M in T) if(M.density) return
				for(var/obj/O in T) if(O.density) return
				//if(usr.Dash_Attack(T)) return
				for(var/obj/Attacks/At in usr.ki_attacks) if(At.charging||At.streaming||At.Using) return
				if(T.z == usr.z && get_dist(T, usr) <= 20 && viewable(usr, T))
					var/list/click_offsets = usr.getZanzokenClickOffsets(T, params)
					if(!click_offsets) return
					A.Skill_Increase(1,usr)

					usr.AddStamina(-stam_drain)

					player_view(10,usr)<<sound('Teleport.ogg',volume=15)
					flick('src/Icons/Effects/Zanzoken.dmi',usr)
					usr.stand_still_time = world.time
					var/OldDir=usr.dir
					usr.AfterImage()
					//var/directional_modifier=1
					//if(get_dir(usr,T) in list(turn(usr.dir,180),turn(usr.dir,135),turn(usr.dir,225)))
					//	directional_modifier=2
					var/distance_mod=1
					if(getdist(usr,T)>6) distance_mod+=(getdist(usr,T)-6)*0.15
					if(usr.senzu_overload) distance_mod++
					var/old_t=src
					usr.teleportToZanzokenClick(T, click_offsets)
					usr.last_input_move = world.time
					usr.Check_if_kiting(old_t)
					usr.dir=OldDir
					usr.Zanzoken_Mastery(0.5)
					usr.Ki-=usr.Zanzoken_Drain()
					//usr.can_zanzoken=0
					var/health_mod=(100/Clamp(usr.Health,1,100))**0.4 //affects zanzo speed
					if(health_mod>5) health_mod=5
					if(health_mod<1) health_mod=1
					//spawn(TickMult(usr.speed_ratio()**0.5*15*health_mod*directional_modifier*distance_mod)) if(usr) usr.can_zanzoken=1
					return

			//wtf according to this code it would let you teleport literally anywhere even into people's bases right? that makes no sense thats why
			//commented it out like this. dont feel like recoding it
			/*if(usr.client.eye==usr) if(!usr.KO && !usr.BeamStruggling()) for(var/obj/Shunkan_Ido/A in usr) if(A.Level>=20)
				if(!T.density&&!T.Water)
					player_view(10,usr)<<sound('Teleport.ogg',volume=15)
					flick('Zanzoken.dmi',usr)
					usr.stand_still_time = world.time
					usr.SafeTeleport(locate(x,y,z))*/

mob/var/tmp/can_zanzoken=1

mob/Click()
	if(src != usr && playerCharacter && (client || empty_player) && KO && (src in view(1, usr)))
		if(usr.promptNexusPlanetControlSeizure(src)) return
	if(client&&KO&&src!=usr&&(src in view(1)))
		var/error = usr.getInjureActionError(src, "Steal")
		if(error)
			usr << error
			return
		var/list/loot_session = usr.getInjureLootChoices(src, include_resources = TRUE)
		if(!loot_session.len) return
		var/obj/Cancel_Loot/cancel = new
		loot_session += cancel
		usr.Lootables = loot_session
		usr.injure_loot_target = src
		while(src && usr && usr.Lootables == loot_session && !usr.getInjureActionError(src, "Steal")) sleep(4)
		if(usr && usr.Lootables == loot_session)
			usr.Lootables = null
			usr.injure_loot_target = null
		del(cancel)
		return
	if(Class!="Legendary Saiyan"&&!ssj&&SSj4Able&&!usr.selected_target&&src==usr&&!transing&&!KO)
		SSj4()
		return
	if(usr.selected_target == src || usr == src && usr.selected_target) usr.setSelectedTarget(null)
	else
		for(var/obj/items/Scouter/O in usr.item_list) if(O.suffix)
			player_view(10,usr)<<sound('Scouterbeeps.ogg',volume=35)
			spawn(30) if(usr) player_view(10,usr)<<sound(pick('Scouter.ogg','Scouterend.ogg'),volume=35)
			break
		if(src != usr) usr.setSelectedTarget(src)
