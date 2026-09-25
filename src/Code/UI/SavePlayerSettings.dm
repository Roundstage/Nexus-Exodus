/*
last char name
aura/blast/charging icon
ssj1/2/3/4 opening graphics
*/
mob/proc
	save_player_settings()
		if(!client || !z) return
		if(client.connection != "seeker") return //i think web connections and such are corrupting their file and erasing their hotkeys
		var/savefile/f = new()
		f["ViewX"]<<ViewX
		f["ViewY"]<<ViewY
		f["ignore_votes"]<<ignore_votes
		f["OOCon"]<<OOCon
		f["Fullscreen"]<<Fullscreen
		f["See_Logins"]<<See_Logins
		f["AdminOn"]<<AdminOn
		f["Build"]<<Build
		f["TechTab"]<<TechTab
		f["ignore_leagues"]<<ignore_leagues
		f["ignore_contracts"]<<ignore_contracts
		f["TextSize"]<<TextSize
		f["TextColor"]<<TextColor
		f["sort_sense_by"]<<sort_sense_by
		f["block_music"] << block_music
		f["nexus_interface_layout"] << normalizeNexusInterfaceLayout(nexus_interface_layout)
		f["nexus_classic_layout"] << nexus_classic_layout
		f["nexus_classic_viewport"] << nexus_classic_viewport
		f["nexus_overhead_vitals_offset_x"] << normalizeNexusHudOffset(nexus_overhead_vitals_offset_x)
		f["nexus_overhead_vitals_offset_y"] << normalizeNexusHudOffset(nexus_overhead_vitals_offset_y)
		f["nexus_main_vitals_x"] << max(0, round(nexus_main_vitals_x))
		f["nexus_main_vitals_y"] << max(0, round(nexus_main_vitals_y))
		f["nexus_main_vitals_scale"] << nexus_main_vitals_scale

		//if(hotbar_ids.len && client.connection == "seeker")
		//	f["hotbar_ids"]<<hotbar_ids
		Hotkey_server_backup_save()

		client.Export(f)

	load_player_settings()
		if(!client) return

		var/file_exists = client.Import()
		if(!file_exists)
			for(var/v in 1 to 5)
				if(!file_exists && client)
					file_exists = client.Import()
					sleep(20)
				else break
		if(!file_exists || !client) return
		var/savefile/f = new(file_exists)
		if(!f) return

		f["ViewX"]>>ViewX
		f["ViewY"]>>ViewY
		f["ignore_votes"]>>ignore_votes
		f["OOCon"]>>OOCon
		f["Fullscreen"]>>Fullscreen
		f["See_Logins"]>>See_Logins
		f["AdminOn"]>>AdminOn
		f["Build"]>>Build
		f["TechTab"]>>TechTab
		f["ignore_leagues"]>>ignore_leagues
		f["ignore_contracts"]>>ignore_contracts
		f["TextSize"]>>TextSize
		f["TextColor"]>>TextColor
		if("sort_sense_by" in f) f["sort_sense_by"]>>sort_sense_by
		if("block_music" in f) f["block_music"] >> block_music
		if("nexus_interface_layout" in f) f["nexus_interface_layout"] >> nexus_interface_layout
		if("nexus_classic_layout" in f) f["nexus_classic_layout"] >> nexus_classic_layout
		if("nexus_classic_viewport" in f) f["nexus_classic_viewport"] >> nexus_classic_viewport
		if("nexus_overhead_vitals_offset_x" in f) f["nexus_overhead_vitals_offset_x"] >> nexus_overhead_vitals_offset_x
		if("nexus_overhead_vitals_offset_y" in f) f["nexus_overhead_vitals_offset_y"] >> nexus_overhead_vitals_offset_y
		if("nexus_main_vitals_x" in f) f["nexus_main_vitals_x"] >> nexus_main_vitals_x
		if("nexus_main_vitals_y" in f) f["nexus_main_vitals_y"] >> nexus_main_vitals_y
		if("nexus_main_vitals_scale" in f) f["nexus_main_vitals_scale"] >> nexus_main_vitals_scale
		setNexusMainVitalsScale(nexus_main_vitals_scale)
		nexus_interface_layout = normalizeNexusInterfaceLayout(nexus_interface_layout)
		nexus_overhead_vitals_offset_x = normalizeNexusHudOffset(nexus_overhead_vitals_offset_x)
		nexus_overhead_vitals_offset_y = normalizeNexusHudOffset(nexus_overhead_vitals_offset_y)
		nexus_main_vitals_x = max(0, round(nexus_main_vitals_x))
		nexus_main_vitals_y = max(0, round(nexus_main_vitals_y))

		//if("hotbar_ids" in f)
		//	f["hotbar_ids"] >> hotbar_ids

		DetermineViewSize()
		Fullscreen_Check()

		Restore_hotbar_from_IDs()
		hideNexusNativeTabs()
