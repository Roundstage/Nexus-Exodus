mob/proc/update_area()
	set waitfor = 0
	var/turf/t = base_loc()

	if(!t && current_area)
		current_area.mob_list -= src
		current_area.player_list -= src
		current_area.npc_list -= src
		current_area = null

	if(t && isturf(t))
		var/area/a = t.loc
		if(a != current_area)

			movement_port.areaUpdateSenseTargets(a) //tell old area we left it

			if(current_area)
				current_area.mob_list -= src
				current_area.player_list -= src
				current_area.npc_list -= src

				current_area.mob_list = remove_nulls(current_area.mob_list)
				current_area.player_list = remove_nulls(current_area.player_list)
				current_area.npc_list = remove_nulls(current_area.npc_list)

			a.mob_list += src
			var/has_client = movement_port.hasClient(src)
			if(has_client) a.player_list += src
			else a.npc_list += src
			current_area = a
			if(has_client && client) client.syncNexusLighting(a)

			movement_port.startCoreLoops(src, a)
			movement_port.finalRealmLoop(src)
			CheckAirMask()
			CheckSpaceDie()

			if(a.type == /area/Battlegrounds && has_client)
				last_battleground_entry = world.time
				last_battleground_defeat = world.time //reset your ranking among the battleground fighters
				movement_port.verifyBattlegroundMaster(src)

			movement_port.areaUpdateSenseTargets(current_area) //tell new area we entered it

			for(var/obj/items/Dragon_Ball/db in item_list) if(db.loc == src)
				if(!current_area || current_area.type != db.Home) db.Land()

mob
	var
		has_air_mask
		air_mask
	proc
		CheckAirMask()
			var/obj/items/Spacesuit/s
			for(s in item_list) break
			if(s)
				if(current_area)
					if(current_area.type == /area/Space)
						if(!air_mask)
							air_mask=1
							overlays-=s.icon
							overlays+=s.icon
					else if(air_mask)
						air_mask=0
						overlays-=s.icon
			else
				air_mask=0

		CheckSpaceDie()
			set waitfor=0
			sleep(5)
			var/special_protection
			
			for(var/obj/items/Amulet/deadzone_protection in item_list)
				special_protection=1
				break
			for(var/obj/items/Holy_Pendant in item_list)
				special_protection=1
				break
				
			while(current_area && current_area.type == /area/Space)
				if(air_mask || Lungs || Regenerate || special_protection)
				else
					var/turf/t = loc
					if(t && isturf(t) && t.type == /turf/Other/Stars)
						SpaceDamage()
				sleep(10)

		SpaceDamage()
			var/shield = (shield_obj && shield_obj.Using)
			var/dmg = 9
			if(shield && Ki >= max_ki / 100 * dmg)
				Ki -= max_ki / 100 * dmg
			else Health-=dmg
			if(Health<=0)
				SaitamaBloodEffect()
				Death("Space",lose_hero=0,lose_immortality=0)
				update_area()

mob/var/tmp/area/current_area
area/var/tmp/list
	mob_list=new
	player_list=new
	npc_list=new
