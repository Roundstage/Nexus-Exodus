obj/var/tmp
	leaves_big_crater
	big_explosion_on_delete

	respawn_on_delete
	respawn_timer = 3000
	respawn_only_if_no_builder
	respawn_only_if_not_built_by_player = 1
	reset_vars_on_respawn

obj/Turfs/big_explosion_on_delete = 1
obj/Trees/big_explosion_on_delete = 1

obj/Turfs
	respawn_on_delete = 1
	respawn_only_if_no_builder = 1

obj/Trees
	respawn_on_delete = 1
	respawn_only_if_no_builder = 1

obj/proc/ObjectRespawn()
	set waitfor=0
	if(reset_vars_on_respawn) ResetVars(src)
	var/turf/t = loc
	loc = null
	Move(locate(0,0,0))
	sleep(respawn_timer)
	loc = t

var
	outputDeletedObjects

mob/Admin5/verb/diagnoseDeletedObjects()
	set name = "Diagnose Deleted Objects"
	set category = "Admin"
	outputDeletedObjects = !outputDeletedObjects
	if(outputDeletedObjects)
		src << "You will now see all deleted objects"
	else
		src << "You will now not see all deleted objects"

obj/Del()
	//so when a player logs out it doesnt have to do all the laggy code below for their items & skills
	if(reallyDelete || ismob(loc) || world.time < 900)
		RemoveLightSource()
		. = ..()
		return

	if(z)
		if(leaves_big_crater) BigCrater(loc)
		if(big_explosion_on_delete && !Builder)
			//RockExplode(loc) //off only due to lag concerns
			Explosion_Graphics(loc, rand(3,4)) //more performant hopefully

		if(grabber)
			var/mob/m = grabber
			if(ismob(m)) m.ReleaseGrab()

	if(z && respawn_on_delete)
		if(respawn_only_if_no_builder)
			var/turf/t = loc
			if(t && isturf(t) && t.Builder)
				respawn_on_delete = 0
				del(src)
				return
		if(respawn_only_if_not_built_by_player)
			if(Builder)
				respawn_on_delete = 0
				del(src)
				return
		if(outputDeletedObjects) Tens("[type] deleted (RESPAWNING)")
		ObjectRespawn()
	else if(cache_for_reuse)
		if(outputDeletedObjects) Tens("[type] deleted (CACHING)")
		RemoveLightSource()
		CacheObject(src)
	else
		if(outputDeletedObjects) Tens("[type] deleted (QUEUED)")
		RemoveLightSource()
		queueObjectForGarbageCollection(src)

var/list/garbage_collect = new
var
	garbage_collection_batch_size = 25
	garbage_collection_interval = 10
	garbage_collection_total_scheduled = 0
	garbage_collection_head = 1
obj/var/tmp/deleted

proc/queueObjectForGarbageCollection(obj/o)
	if(!o || o.deleted) return FALSE
	o.loc = null
	o.deleted = TRUE
	garbage_collect += o
	return TRUE

proc/compactGarbageCollectionQueue(force_compaction = FALSE)
	if(!islist(garbage_collect)) garbage_collect = list()
	if(garbage_collection_head > garbage_collect.len)
		garbage_collect = list()
		garbage_collection_head = 1
	else if(garbage_collection_head > 1 && (force_compaction || garbage_collection_head > 200 && garbage_collection_head > garbage_collect.len / 2))
		garbage_collect.Cut(1, garbage_collection_head)
		garbage_collection_head = 1
	if(force_compaction) garbage_collect = remove_nulls(garbage_collect)

proc/GarbageCollect(max_objects)
	if(!islist(garbage_collect)) garbage_collect = list()
	if(!isnum(max_objects) || max_objects <= 0) max_objects = garbage_collection_batch_size
	max_objects = max(1, round(max_objects))
	var/objects_scheduled = 0
	var/entries_inspected = 0
	while(garbage_collection_head <= garbage_collect.len && entries_inspected < max_objects)
		var/obj/o = garbage_collect[garbage_collection_head]
		garbage_collect[garbage_collection_head] = null
		garbage_collection_head++
		entries_inspected++
		if(!o) continue
		o.reallyDelete = TRUE
		o.DeleteNoWait()
		objects_scheduled++
	compactGarbageCollectionQueue()
	garbage_collection_total_scheduled += objects_scheduled
	return objects_scheduled

proc/GarbageCollectLoop()
	set waitfor=0
	while(1)
		sleep(garbage_collection_interval)
		GarbageCollect()

var/list/pending_object_delete_list=new

obj/var/tmp/reallyDelete //tells obj/Del() to make this object truly be deleted instead of voided or cached or whatever else that would normally happen.

proc/DeletePendingObjectsLoop()
	set waitfor=0
	sleep(300)
	while(1)
		for(var/obj/o in pending_object_delete_list)
			pending_object_delete_list -= o
			o.reallyDelete = 1
			o.DeleteNoWait()
			sleep(5) //keep in mind sleep(10) would delete 60 objects per minute
		sleep(10)

proc/DeletePendingObjects()
	var/count = 0
	for(var/obj/o in pending_object_delete_list)
		o.reallyDelete = 1
		o.DeleteNoWait()
		count++
	clients << "[count] objects deleted"
	pending_object_delete_list = new/list
