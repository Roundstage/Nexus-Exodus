mob/var/tmp/list/item_list=new

obj/items/New()
	spawn if(ismob(loc))
		var/mob/M=loc
		M.item_list+=src
		M.Restore_hotbar_from_IDs()

obj/items/Move()
	if(ismob(loc))
		var/mob/m=loc
		m.item_list-=src
		m.hotbar-=src
		m.item_list=remove_nulls(m.item_list)
		m.Restore_hotbar_from_IDs()
		if(m) m.ShikonAura()
	. = ..()
	if(ismob(loc))
		var/mob/m=loc
		m.item_list+=src
		m.Restore_hotbar_from_IDs()
		if(m) m.ShikonAura()
