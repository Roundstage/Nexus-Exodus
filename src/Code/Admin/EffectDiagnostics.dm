mob/Admin5/verb
	diagnoseEffectIcons()
		set name = "Diagnose Effect Icons"
		set category = "Admin"
		var/list/l = new
		var/noIcon = 0
		for(var/obj/Effect/e in world)
			if(e.icon)
				var/iconTxt = "[e.icon]"
				if(!(iconTxt in l))
					l += iconTxt
					l[iconTxt] = 0
				l[iconTxt] = l[iconTxt] + 1
			else noIcon++
		src << "[noIcon] Effects have no icon"
		var/list/mentioned = new
		for(var/v in l)
			if(!(v in mentioned))
				mentioned += v
				src << "[l[v]] Effects have the [v] icon"
