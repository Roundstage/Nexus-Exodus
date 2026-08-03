obj/Resources
	cache_for_reuse = 1
	reset_vars_on_cache = 1
obj/After_Image/cache_for_reuse = 1
obj/Shadow_Spar_Overlay/cache_for_reuse = 1
obj/Door_kill_blood/cache_for_reuse = 1
obj/SpaceDebris/cache_for_reuse = 1
obj/Bounty_Picture/cache_for_reuse = 1
obj/stretch_arm/cache_for_reuse = 1

obj/var
	cache_for_reuse
	reset_vars_on_cache
	cached

var/list/cached_objects = new
var/object_cache_retention_limit_per_type = 250

proc
	GetCachedObject(obj_type, pos)
		if(!obj_type) return
		if("[obj_type]" in cached_objects)
			var/list/l = cached_objects["[obj_type]"]
			while(l && l.len)
				var/obj/o = l[l.len]
				l.len--
				if(!o) continue
				if(pos) o.Move(pos)
				o.New()
				o.cached = 0
				return o
		var/obj/o = new obj_type
		if(pos) o.Move(pos)
		return o

	CacheObject(obj/o)
		if(!o || o.cached) return
		animate(o) //stop all animations
		o.SafeTeleport(null)
		if(o.reset_vars_on_cache) ResetVars(o)
		var/list/type_cache = cached_objects["[o.type]"]
		if(!islist(type_cache))
			type_cache = list()
			cached_objects["[o.type]"] = type_cache
		if(type_cache.len >= object_cache_retention_limit_per_type)
			o.reallyDelete = TRUE
			o.DeleteNoWait()
			return
		ResetVars(o)
		o.cached = 1
		type_cache += o
