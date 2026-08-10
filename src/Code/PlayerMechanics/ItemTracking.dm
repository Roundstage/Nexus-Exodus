mob/var/tmp/list/item_list=new
obj/items/var/tmp/nexus_move_revision

obj/items/New()
	spawn if(ismob(loc))
		var/mob/M=loc
		M.item_list+=src
		M.Restore_hotbar_from_IDs()

obj/items/Move()
	var/atom/original_location = loc
	if(ismob(loc))
		var/mob/m=loc
		m.item_list-=src
		m.hotbar-=src
		m.item_list=remove_nulls(m.item_list)
		m.Restore_hotbar_from_IDs()
		if(m) m.ShikonAura()
	. = ..()
	if(. && loc != original_location) nexus_move_revision++
	if(ismob(loc))
		var/mob/m=loc
		m.item_list+=src
		m.Restore_hotbar_from_IDs()
		if(m) m.ShikonAura()
