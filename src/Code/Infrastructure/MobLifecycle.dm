mob/Del()
	leaveCombatTeam(null, FALSE)
	if(current_area)
		current_area.mob_list-=src
		current_area.player_list-=src
		current_area.npc_list-=src
		current_area=null
	if(grabber) grabber.ReleaseGrab()
	DBZ_character_del()
	Drop_dragonballs()
	DropShikon()
	//Target=null
	if(!perma_delete && Spawn_Timer && istype(src,/mob/Enemy) && !istype(src,/mob/Enemy/Zombie)) NPC_Del()

	else if(type==/mob/Enemy/Core_Demon&&icon==initial(icon))
		FullHeal()
		inactive_core_demons-=src
		inactive_core_demons+=src
		SafeTeleport(null)
		if(grabber) grabber.ReleaseGrab()

	else if(type==/mob/Body)
		var/mob/Body/b=src
		if(!b.Cooked&&NPC_Leave_Body) Body_Parts()
		if(src in cached_bodies)
			SafeTeleport(null)
			if(grabber) grabber.ReleaseGrab()
		else if(cached_bodies.len < cached_body_retention_limit)
			cached_bodies+=src
			SafeTeleport(null)
			if(grabber) grabber.ReleaseGrab()
		else . = ..()

	else if(type==/mob/Splitform)
		//i dont feel like fixing splitform caching right now, it works but part of their AI keeps going for some reason so when you create one sometimes itll fly off
		//trying to find the previous target or something i suppose. so instead of reusing just get a new one each time
		/*if(grabber) grabber.ReleaseGrab()
		SafeTeleport(null)
		FullHeal()
		Target=null
		var/mob/Splitform/sf=src
		sf.Mode = null
		splitform_cache-=src
		splitform_cache+=src*/
		if(Maker && ismob(Maker))
			Maker.splitform_list -= src
		. = ..()

	else
		/*Tens("\
		mob deleted:<br>\
		name: [src]<br>\
		type: [type]<br>\
		key: [key]<br>\
		loc: [x],[y],[z]\
		<br>\
		")*/
		//if(key)
		for(var/obj/o in contents)
			nulledPlayerObjects++
			pending_object_delete_list += o
			//garbage_collect += o //we are going to see what happens if we use the GarbageCollect() system we made instead of the pending_object_delete_list,
				//but the above still works fine if we want to go back to it
			//the difference is that pending_object_delete_list will gradually delete an object like every sleep(5) whereas GarbageCollect deletes all
			//of the objects at once every like minute or so. which is better? i do not yet know. (maybe even use both)
		contents = null
		drone_module = null //just wondering if this reference is why deleting drones lags so bad
		. = ..()

var/nulledPlayerObjects = 0
