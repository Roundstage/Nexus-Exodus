var/list/admin_objects = new
var/const/NEXUS_CHARACTER_SLOT_LIMIT = 3

proc/clampNexusCharacterSlot(slot)
	return Clamp(round(text2num("[slot]")), 1, NEXUS_CHARACTER_SLOT_LIMIT)

proc/getNexusCharacterSaveRoot(environment = nexus_runtime_environment)
	return normalizeNexusRuntimeEnvironment(environment) == "playtest" ? "data/Playtest/Save" : "data/Save"

proc/getNexusFeatSaveRoot(environment = nexus_runtime_environment)
	return normalizeNexusRuntimeEnvironment(environment) == "playtest" ? "data/Playtest/Feats" : "data/Feats"

proc/getNexusWipePersistenceRoots(delete_feats = TRUE, environment = nexus_runtime_environment)
	var/list/roots = list("[getNexusCharacterSaveRoot(environment)]/")
	if(delete_feats) roots += "[getNexusFeatSaveRoot(environment)]/"
	return roots

proc/getNexusCharacterSavePathForKey(character_key, slot = 1, environment = nexus_runtime_environment)
	if(!character_key) return null
	return "[getNexusCharacterSaveRoot(environment)]/[ckey(character_key)]-slot[clampNexusCharacterSlot(slot)].sav"

proc/getNexusFeatSavePathForKey(character_key, slot = 1, environment = nexus_runtime_environment)
	if(!character_key) return null
	return "[getNexusFeatSaveRoot(environment)]/[ckey(character_key)]-slot[clampNexusCharacterSlot(slot)].sav"

proc/getNexusCharacterMigrationPathForKey(character_key, environment = nexus_runtime_environment)
	if(!character_key) return null
	return "[getNexusCharacterSaveRoot(environment)]/[ckey(character_key)]-slots.migrated.sav"

proc/isNexusSaveEnvironmentCompatible(saved_environment, environment = nexus_runtime_environment)
	var/expected_environment = normalizeNexusRuntimeEnvironment(environment)
	if(isnull(saved_environment) || !length("[saved_environment]")) return expected_environment == "live"
	return lowertext("[saved_environment]") == expected_environment

proc/isNexusCharacterSavePathEnvironmentCompatible(save_path, environment = nexus_runtime_environment)
	if(!save_path || !fexists(save_path)) return FALSE
	var/savefile/environment_save = new(save_path)
	var/saved_environment
	environment_save["NexusRuntimeEnvironment"] >> saved_environment
	return isNexusSaveEnvironmentCompatible(saved_environment, environment)

mob/var/tmp/active_character_slot = 1

mob/proc/getNexusCharacterSavePath(slot = active_character_slot)
	return getNexusCharacterSavePathForKey(key, slot)

mob/proc/getNexusFeatSavePath(slot = active_character_slot)
	return getNexusFeatSavePathForKey(key, slot)

mob/proc/ensureNexusCharacterSlots()
	if(!key) return
	active_character_slot = clampNexusCharacterSlot(active_character_slot)
	var/has_slotted_character = FALSE
	for(var/slot = 1, slot <= NEXUS_CHARACTER_SLOT_LIMIT, slot++)
		if(isNexusCharacterSavePathEnvironmentCompatible(getNexusCharacterSavePath(slot)))
			has_slotted_character = TRUE
			break
	var/legacy_save_path = "data/Save/[key]"
	var/migration_marker_path = getNexusCharacterMigrationPathForKey(key)
	if(nexus_runtime_environment == "live" && !has_slotted_character && !fexists(migration_marker_path) && fexists(legacy_save_path))
		var/slot_one_path = getNexusCharacterSavePath(1)
		fcopy(legacy_save_path, slot_one_path)
		var/savefile/migrated_save = new(slot_one_path)
		var/slot_name = "Existing Character"
		var/slot_race = "Unknown lineage"
		var/slot_last_used = 0
		migrated_save["name"] >> slot_name
		migrated_save["Race"] >> slot_race
		migrated_save["Last_Used"] >> slot_last_used
		migrated_save["NexusSlotName"] << slot_name
		migrated_save["NexusSlotRace"] << slot_race
		migrated_save["NexusSlotLastUsed"] << slot_last_used
		has_slotted_character = fexists(slot_one_path)
	if(has_slotted_character && !fexists(migration_marker_path))
		var/savefile/migration_marker = new(migration_marker_path)
		migration_marker["migration_complete"] << TRUE
	var/legacy_feat_path = "data/Feats/[key]"
	var/slot_one_feat_path = getNexusFeatSavePath(1)
	if(nexus_runtime_environment == "live" && fexists(getNexusCharacterSavePath(1)) && !fexists(slot_one_feat_path) && fexists(legacy_feat_path))
		fcopy(legacy_feat_path, slot_one_feat_path)

mob/proc/getNexusCharacterSlotInfo(slot)
	slot = clampNexusCharacterSlot(slot)
	var/list/slot_info = list("slot" = slot, "exists" = FALSE, "name" = "Empty Slot", "race" = "Create a new character", "last_used" = 0)
	var/save_path = getNexusCharacterSavePath(slot)
	if(!isNexusCharacterSavePathEnvironmentCompatible(save_path)) return slot_info
	var/savefile/character_save = new(save_path)
	var/slot_name
	var/slot_race
	var/slot_last_used
	character_save["NexusSlotName"] >> slot_name
	character_save["NexusSlotRace"] >> slot_race
	character_save["NexusSlotLastUsed"] >> slot_last_used
	if(!slot_name) character_save["name"] >> slot_name
	if(!slot_race) character_save["Race"] >> slot_race
	if(!slot_last_used) character_save["Last_Used"] >> slot_last_used
	slot_info["exists"] = TRUE
	slot_info["name"] = slot_name ? "[slot_name]" : "Existing Character"
	slot_info["race"] = slot_race ? "[slot_race]" : "Unknown lineage"
	slot_info["last_used"] = text2num("[slot_last_used]")
	return slot_info

mob/proc/deleteNexusCharacterSlot(slot)
	if(!key) return FALSE
	slot = clampNexusCharacterSlot(slot)
	releaseNexusPlanetControlsForCharacter(key, slot)
	var/save_path = getNexusCharacterSavePath(slot)
	var/feat_path = getNexusFeatSavePath(slot)
	var/profile_art_deleted = deleteNexusPlayerProfileImageForKey(key, slot)
	if(save_path && fexists(save_path)) fdel(save_path)
	if(feat_path && fexists(feat_path)) fdel(feat_path)
	return profile_art_deleted

proc/saveAdminObjects()
	//set background=1
	var/savefile/f = new("data/Admin Placed Objects")
	for(var/obj/o in admin_objects)
		o.saved_x = o.x
		o.saved_y = o.y
		o.saved_z = o.z
	f["admin_objects"] << admin_objects

proc/loadAdminObjects()
	if(fexists("Admin Placed Objects"))
		var/savefile/f = new("data/Admin Placed Objects")
		f["admin_objects"] >> admin_objects
		for(var/obj/o in admin_objects)
			o.x = o.saved_x
			o.y = o.saved_y
			o.z = o.saved_z






mob/proc/respawn(but_not_in_ship_area)
	Go_to_spawn(butNotInShipArea = but_not_in_ship_area)

var/can_login=0

proc/initialize()
	configureNexusPlaytestRewards()
	RestrictedMapLoop()
	initializeSkillEngine()
	AutoBPResetLoop()
	StartupScatterBigRocks()
	StartupSpawnKingBraalThrone()
	Delete_blank_mobs_loop()
	GarbageCollectLoop()
	Remove_all_nulls()
	GenerateBPOrbs()
	Zombie_reproduce_loop()
	Zombie_mutate_loop()
	fill_cached_blasts()
	check_dragonballs()
	hostban_protection()
	Hostban_check_loop()
	gains_limiter()
	Send_Bounty_Drone()
	Mute_Check()
	Auto_revive_loop()
	loadBan()
	world<<"Bans loaded"
	loadYear()
	world<<"Year loaded"
	loadAdmins()
	world<<"Admins loaded"
	loadGain()
	world<<"Gain loaded"
	loadStory()
	world<<"Story loaded"
	loadRules()
	world<<"Rules loaded"
	loadNotes()
	world<<"Notes loaded"
	loadLogin()
	world<<"Login loaded"
	loadRanks()
	world<<"Ranks loaded"
	loadHero()
	world<<"Hero loaded"
	loadJobs()
	world<<"Jobs loaded"
	loadVote()
	world<<"Voting loaded"
	loadMisc()
	world<<"Misc Loaded"
	loadNexusPlanetControls()
	world<<"Planetary control loaded"
	if(npcs_enabled) enable_npcs()
	else disable_npcs()
	if(world.maxz<5) Map_Loaded=1
	spawn(25) mapLoad()
	spawn(30) loadItems()
	spawn(35) loadAdminObjects()
	spawn(35) if(1)
		loadBodies()
		world<<"Bodies loaded"
	spawn(35)
		if(npcs_enabled)
			loadNpcs()
			world<<"NPCs loaded"
		else world<<"NPCs disabled; saved NPC load skipped"
	addBuilds()
	world<<"Builds added"
	loadNexusProfileArtBudget()
	world<<"Profile art reconciled"
	var/smoke_soul_contract_count
	if(world.params["nexus_smoke_tests"])
		smoke_soul_contract_count = soul_contracts.len
	Add_Technology()
	world<<"Technology added"
	if(world.params["nexus_smoke_tests"])
		runViltrumiteStartupSmokeTests()
		runEnergyRecoveryStartupSmokeTests()
		runStartupSmokeTests(smoke_soul_contract_count)
	Fill_Hair_List()
	world<<"Hair added"
	spawn Refresh_Stat_Record()
	Years()
	spawn saveWorldRepeat()
	spawn nexusPlanetControlSaveLoop()
	spawn Weather()
	spawn saveLoop()
	spawn Tech_BP()
	Resources_Loop()
	Random_resource_drops()
	startWorldOreGeneration()
	spawn ZeroDelayLoop()
	spawn HBTC_Timer()
	//Force_Update_Loop()
	Tournament_Loop()
	loadArea()
	world<<"Area loaded"
	spawn findMaxSpeed()
	Initialize_Gun_Icons()
	PopulateClothesChoices()
	for(var/a in typesof(/obj/Alien_Icons)) if(a!=/obj/Alien_Icons) Alien_Icons+=new a
	for(var/a in typesof(/obj/Demon_Icons)) if(a!=/obj/Demon_Icons) Demon_Icons+=new a
	//world<<"All files loaded."
	Monitor_Bugs()
	villain_damage_penalty_update()
	hide_destroyed_planets()
	Ship_on_destroyed_planet_loop()
	Initialize_db_menu_avatars()
	Car_wreck_loop()
	DeletePendingObjectsLoop()
	Wall_bot_loop()
	Auto_bounty_evil()
	Respawn_turfs()
	Villain_league_member_count_loop()
	League_paychecks()
	Turret_loop()
	Recover_health_loop()
	Recover_energy_loop()
	Immortality_zones()
	Ascension_loop()
	Bind_loop()
	Powerup_drain()
	Update_ban_data_loop()
	SaitamaRotationLoop()
	EnableDragonBallsLoop()

	ssj4_desc=new/obj/Super_Saiyan_4_Description

	spawn(10) can_login=1

	//because illegal science doesnt use objs any moer it uses types so clear old entries
	spawn(100) for(var/obj/o in Illegal_Science) Illegal_Science-=o

	spawn(100) if(fexists("LSX.log")) fdel("LSX.log")

	ActivatePixelMovement()
	ScatterFirefliesRandomlyOnMap()

	//GenerateMapFeatures()
	GenerateMapFeaturesByZone()
	GenerateUltraInstinctGraphics()
	averageSpeedUpdater()
	destroyShipsInShipsLoop()
	GodKiRealmKillLoop()
	//WebhubLoop()
	//InitFakePlayers()
	SpecialAnnouncementsLoop()
	ToggleBraalGym(wait = 300)
	CheckDeleteHellAltar(wait = 0)
	world << "Starting new Systems"
	spawn LogicLoop()
	world << "Started new KO System"
	world << "Started Effect System"
	world << "Started Energy System"
	if(world.params["nexus_smoke_tests"])
		world.log << "NEXUS_INITIALIZATION_COMPLETE"

obj/var/referenceObject = 0 //if this object is intended for the Science tab, Make verb, etc, it is a referenceObject

proc/destroyShipsInShipsLoop()
	set waitfor=0
	sleep(600)
	while(1)
		for(var/obj/Ships/Ship/s in ships)
			if(s.referenceObject) continue
			var/area/a = s.get_area()
			var/turf/t = s.base_loc()
			if(a)
				if(a.type == /area/ship_area || a.type == /area/Final_Realm || a.type == /area/God_Ki_Realm)
					del(s)
			if(s && t)
				if(t.type == /turf/Other/Blank)
					del(s)
		sleep(600)

var/avg_speed = 100

proc/averageSpeedUpdater()
	set waitfor=0
	while(1)
		var
			total_speed = 0
			total_players = 0
		for(var/mob/m in players)
			if(istype(m, /mob/new_troll)) continue
			if(m.z)
				total_speed += m.Spd
				total_players++
		if(!total_players)
			sleep(30)
			continue
		avg_speed = total_speed / total_players
		sleep(200)

proc/saveWorldRepeat() while(1)
	sleep(1.2 * 60 * 600)
	spawn saveWorld()

proc/saveWorld(save_map=1, allow_auto_reboot=1, delete_pending_objs=1)
	world<<"<font color=yellow><font size=3>Saving all items. Prepare for lag spike."
	sleep(5)
	GarbageCollect()
	saveAdmins()
	saveYear()
	saveGain()
	saveArea()
	saveMisc()
	saveNexusPlanetControls()
	saveVote()
	saveAdminObjects()
	if(save_map)
		mapSave()
		saveItems()
		saveBodies()
		saveNpcs()
	if(allow_auto_reboot && world.time>auto_reboot_hours * 60 * 60 * 10 && !Tournament)
		world << "<font size=3><font color=#FFFF00>A Scheduled Reboot is going to happen in 2 minutes."
		sleep(1200)
		Admin_Reboot(save_world=0)
	else
		if(delete_pending_objs) DeletePendingObjects()

proc/saveLoop() while(1)
	sleep(1200)
	for(var/mob/a in players)
		a.save()
		sleep(100)

mob/var/Can_Remake=1

mob/proc/cantRemake() if(fexists(getNexusCharacterSavePath()))
	var/savefile/f=new(getNexusCharacterSavePath())
	f["Can_Remake"]>>Can_Remake
	if(Can_Remake==0) return 1 //Cant use if(!Can_Vote) because if its 1 its the initial value and the entry is null

var/player_saving_on=1

mob/proc/removeOverlaysThatDontSaveCorrectly()
	Remove_Say_Spark()
	TakeOffShurikenOverlaysOnSave()
	Remove_evil_overlay()
	Aura_Overlays(remove_only=1)
	overlays-=BlastCharge
	overlays-=block_shield
	overlays-='SBombGivePower.dmi'
	overlays -= ssj_blue_idle_aura
	overlays -= ultra_instinct_idle_aura
	overlays -= gold_form_idle_aura
	overlays -= shikon_aura
	overlays -= grab_absorb_overlay
	overlays -= fireOverlay

mob/proc/save()
	if(is_saitama) return
	if(!player_saving_on) return
	if(key && displaykey && Savable)
		ensureNexusCharacterSlots()

		removeOverlaysThatDontSaveCorrectly()

		if(dbz_character)
			Save_dbz_character()
			return
		Record_offline_gains()

		var/turf/t = base_loc()
		if(t && !Regenerating)
			saved_x = t.x
			saved_y = t.y
			saved_z = t.z

		var/savefile/f=new(getNexusCharacterSavePath())
		f["Last_Used"]<<world.realtime
		Write(f)
		writeNexusPlayerProfileTextSaveFields(f)
		writeNexusPlayerProfileArtSaveFields(f)
		f["NexusRuntimeEnvironment"] << nexus_runtime_environment
		f["NexusSlotName"] << name
		f["NexusSlotRace"] << Race
		f["NexusSlotLastUsed"] << world.realtime
		// Profile actions reopen this path immediately to verify durability.
		f.Flush()
		f = null
		if(blocking) overlays+=block_shield
		Aura_Overlays()
		Evil_overlay()
		ShikonAura()
		ReApplyShurikenOverlaysOnSave()
		if(is_ssj_blue) overlays += ssj_blue_idle_aura
		if(ultra_instinct) overlays += ultra_instinct_idle_aura
		if(is_gold_form) overlays += gold_form_idle_aura
		if(grab_absorb_module && grabbedObject && strangling) overlays += grab_absorb_overlay

		SaveFeats()

mob/proc/load() if(client)
	ensureNexusCharacterSlots()
	var/save_path = getNexusCharacterSavePath()
	if(isNexusCharacterSavePathEnvironmentCompatible(save_path) && Map_Loaded)
		var/savefile/f = new(save_path)
		Read(f)
		SafeTeleport(locate(saved_x, saved_y, saved_z))
		Other_Load_Stuff()
		LoadFeats()
		if(client) client.DeleteTitleScreen()
		return 1
	else
		if(!Map_Loaded) alert(src,"You can not log in until the map loads.")
		else alert(src,"You do not have any characters on this server.")

mob/proc/hasSave(slot = active_character_slot)
	if(!key) return
	ensureNexusCharacterSlots()
	if(isNexusCharacterSavePathEnvironmentCompatible(getNexusCharacterSavePath(slot))) return 1

var/banned_from_hosting

proc
	saveCustomDecors()
		var/savefile/s = new("CustomDecors")
		s << customDecors

	loadCustomDecors()
		if(!fexists("CustomDecors")) return
		var/savefile/s = new("CustomDecors")
		s >> customDecors
		DeleteSpamCustomDecors()

proc/saveMisc()
	saveCustomDecors()
	var/savefile/s=new("Misc")
	s["Status_Message"]<<Status_Message
	s["PVP"]<<PVP
	s["Earth_Only"]<<Earth_Only
	s["Automate_Tech_Power"]<<Automate_Tech_Power
	s["Tech_BP"]<<Tech_BP
	s["Illegal_Science"]<<Illegal_Science

	Stat_Settings["Modless"] = 1 //fix bug

	s["Bounties"]<<Bounties
	s["Council"]<<Council
	s["SP_Multiplier"]<<SP_Multiplier
	s["Allow_Ban_Votes"]<<Allow_Ban_Votes
	s["Resource_Multiplier"]<<Resource_Multiplier
	s["Can_Pwipe_Vote"]<<Can_Pwipe_Vote
	s["BP_Cap"]<<BP_Cap
	s["Ki_Disabled"]<<Ki_Disabled
	s["Gun_Power"]<<Gun_Power
	s["Illegal_Races"]<<Illegal_Races
	s["Ki_Gain"]<<Ki_Gain
	s["Perma_Death"]<<Perma_Death
	s["Tournament_Timer"]<<Tournament_Timer
	s["Stat_Leech"]<<Stat_Leech
	s["Start_BP"]<<Start_BP
	s["Learn_Disabled"]<<Learn_Disabled
	s["Train_Disabled"]<<Train_Disabled
	s["Base_Stat_Gain"]<<Base_Stat_Gain
	s["Tournament_Prize"]<<Tournament_Prize
	s["auto_revive_timer"]<<auto_revive_timer
	s["Safezones"]<<Safezones
	s["Server_Ratings"]<<Server_Ratings
	s["Auto_Rank"]<<Auto_Rank
	s["Safezone_Distance"]<<Safezone_Distance
	s["Turf_Strength"]<<Turf_Strength
	s["KO_Time"]<<KO_Time
	s["Server_Regeneration"]<<Server_Regeneration
	s["Server_Recovery"]<<Server_Recovery
	s["SSj_Mastery"]<<SSj_Mastery
	s["ssj_easy"]<<ssj_easy
	s["Max_Players"]<<Max_Players
	s["Max_Zombies"]<<Max_Zombies
	s["Prison_Money"]<<Prison_Money
	s["reincarnation_loss"]<<reincarnation_loss
	s["banned_from_hosting"]<<banned_from_hosting
	s["death_setting"]<<death_setting
	s["max_gravity"]<<max_gravity
	s["reincarnation_recovery"]<<reincarnation_recovery
	//S["epic_list"]<<epic_list
	s["allow_age_choosing"]<<allow_age_choosing
	s["cyber_bp_mod"]<<cyber_bp_mod
	s["leech_strongest"]<<leech_strongest
	s["strongest_bp_gain_penalty"]<<strongest_bp_gain_penalty
	s["melee_power"]<<melee_power
	s["ki_power"]<<ki_power
	s["alignment_on"]<<alignment_on
	s["alts"]<<alts
	s["max_villains"]<<max_villains
	s["ssj_voting"]<<ssj_voting
	s["max_Saiyan_percent"]<<max_Saiyan_percent
	s["npcs_enabled"]<<npcs_enabled
	s["skill_tournament_chance"]<<skill_tournament_chance
	s["max_auto_leech"]<<max_auto_leech
	s["bp_tiers"]<<bp_tiers
	s["sagas"]<<sagas
	s["gain_tier_from_tournament"]<<gain_tier_from_tournament
	s["hero_training_gives_tier"]<<hero_training_gives_tier
	s["npcs_give_hbtc_keys"]<<npcs_give_hbtc_keys
	s["adapt_mod"]<<adapt_mod
	s["Illegal_learnables"]<<Illegal_learnables
	s["destroyed_planets"]<<destroyed_planets
	s["forced_injections"]<<forced_injections
	s["planet_destroy_immunity_time"]<<planet_destroy_immunity_time
	s["planet_destroy_bp_requirement"]<<planet_destroy_bp_requirement
	s["planet_destroy_uses"]<<planet_destroy_uses
	s["destroyable_planets"]<<destroyable_planets
	s["im_trapped_allowed"]<<im_trapped_allowed
	s["Tech_BP"]<<Tech_BP
	s["offline_gains"]<<offline_gains
	s["death_cures_vampires"]<<death_cures_vampires
	s["wall_INT_scaling"]<<wall_INT_scaling
	s["percent_of_wall_breakers"]<<percent_of_wall_breakers
	s["disabled_planets"]<<disabled_planets
	s["meteor_density"]<<meteor_density
	s["OOC"]<<OOC
	s["energy_cap"]<<energy_cap
	s["alt_limit"]<<alt_limit
	s["pwipe_vote_year"]<<pwipe_vote_year
	s["pwipe_vote_bp"]<<pwipe_vote_bp
	s["db_vampire_incurable"]<<db_vampire_incurable
	s["bank_list"]<<bank_list
	s["banked_items"]<<banked_items
	s["allow_diagonal_movement"]<<allow_diagonal_movement
	s["max_buff_bp"]<<max_buff_bp
	s["skill_tournament_bp_boost"]<<skill_tournament_bp_boost
	s["minimum_bounty"]<<minimum_bounty
	s["incline_on"]<<incline_on
	s["pwipe_delete_map"]<<pwipe_delete_map
	s["pwipe_turf_health"]<<pwipe_turf_health
	s["pwipe_delete_items"]<<pwipe_delete_items
	s["pwipe_cost_threshold"]<<pwipe_cost_threshold
	s["dbz_character_mode"]<<dbz_character_mode
	s["disabled_dbz_characters"]<<disabled_dbz_characters
	s["toxic_waste_on"]<<toxic_waste_on
	s["zombie_reproduce_mod"]<<zombie_reproduce_mod
	s["car_wreck_frequency"]<<car_wreck_frequency
	s["inspire_allowed"]<<inspire_allowed
	s["death_anger_gives_ssj"]<<death_anger_gives_ssj
	s["bp_soft_cap"]<<bp_soft_cap
	s["can_admin_vote"]<<can_admin_vote
	s["allow_guests"]<<allow_guests
	s["can_ignore_SI"]<<can_ignore_SI
	s["drone_instructions"]<<drone_instructions
	s["era_resets"]<<era_resets
	s["era_bp_division"]<<era_bp_division
	s["era_target_bp"]<<era_target_bp
	s["server_zenkai"]<<server_zenkai
	s["highest_era_bp"]<<highest_era_bp
	s["can_era_vote"]<<can_era_vote
	s["drop_items_on_death"]<<drop_items_on_death
	s["doors_kill"]<<doors_kill
	s["fps"]<<world.fps
	s["lose_resources_on_logout"]<<lose_resources_on_logout
	s["knowledge_cap_mod"]<<knowledge_cap_mod
	s["announce_dragon_balls"]<<announce_dragon_balls
	s["saitama_rotations"]<<saitama_rotations
	s["saitama_queue"]<<saitama_queue
	s["race_stats_only_mode"]<<race_stats_only_mode
	s["BASE_MOVE_DELAY"]<<BASE_MOVE_DELAY
	s["custom_buffs_allowed"]<<custom_buffs_allowed
	s["feats_on"]<<feats_on
	s["nexus_server_feature_defaults_version"]<<nexus_server_feature_defaults_version
	s["auto_reboot_hours"]<<auto_reboot_hours
	s["pwipe_delete_feats"]<<pwipe_delete_feats
	s["override_spawn"]<<override_spawn
	s["imitate_allowed"]<<imitate_allowed
	s["majin_auto_learn"]<<majin_auto_learn
	s["dead_power_loss"]<<dead_power_loss
	s["keep_body_loss"]<<keep_body_loss
	s["client_fps"] << client_fps
	s["zombie_power_mult"] << zombie_power_mult
	s["drone_genocide_off"] << drone_genocide_off
	s["drone_power"] << drone_power
	s["prohibited_admins"] << prohibited_admins
	s["voting_allowed"] << voting_allowed
	s["show_names_in_ooc"] << show_names_in_ooc
	s["can_cyber_KOd_people"] << can_cyber_KOd_people
	s["building_price_mult"] << building_price_mult
	s["admins_build_free"] << admins_build_free
	s["exempt_from_host_check"] << exempt_from_host_check
	s["pack_KT_allowed"] << pack_KT_allowed
	s["body_swap_time_limit"] << body_swap_time_limit
	s["max_screen_size"] << max_screen_size
	s["gta5_wasted"] << gta5_wasted
	s["resource_version"] << resource_version
	s["admin_allow_base_orbs"] << admin_allow_base_orbs
	s["limit_bind"] << limit_bind
	s["can_go_in_void"] << can_go_in_void
	s["can_build_in_void"] << can_build_in_void
	s["admins_can_go_in_void"] << admins_can_go_in_void
	s["admins_can_build_in_void"] << admins_can_build_in_void
	s["lower_stats_off"] << lower_stats_off
	s["king_of_Braal"] << king_of_Braal
	s["highest_player_count"] << highest_player_count
	s["dodging_mode"] << dodging_mode
	s["battleground_spawn_choice_on"] << battleground_spawn_choice_on
	s["auto_reset_bp_at"] << auto_reset_bp_at
	s["allow_dragon_rush"] << allow_dragon_rush
	s["global_stun_mod"] << global_stun_mod
	s["allow_ultra_instinct"] << allow_ultra_instinct
	s["explosions_off"] << explosions_off
	s["dust_off"] << dust_off
	s["shockwaves_off"] << shockwaves_off
	s["stun_stops_movement"] << stun_stops_movement
	s["allow_god_ki"] << allow_god_ki
	s["old_age_on"] << old_age_on
	s["lssj_common_race"] << lssj_common_race
	s["icer_common_race"] << icer_common_race
	s["all_rare_races_common"] << all_rare_races_common
	s["viltrumite_grand_regent_account"] << viltrumite_grand_regent_account
	s["viltrumite_grand_regent_slot"] << viltrumite_grand_regent_slot
	s["viltrumite_grand_regent_created_at"] << viltrumite_grand_regent_created_at
	s["helperQuestsOn"] << helperQuestsOn
	s["hakai_bp_advantage_needed"] << hakai_bp_advantage_needed
	s["hakai_wipes_character"] << hakai_wipes_character
	s["gravity_mastery_mod"] << gravity_mastery_mod
	s["anyone_can_enter_hbtc"] << anyone_can_enter_hbtc
	s["give_countdown_verb"] << give_countdown_verb
	s["give_whisper_verb"] << give_whisper_verb
	s["allow_good_bounties"] << allow_good_bounties
	s["hide_energy_enabled"] << hide_energy_enabled
	s["drone_limit"] << drone_limit
	//S["customDecors"] << customDecors //IT WAS A BIG MISTAKE TO SAVE THIS HERE BECAUSE IT MEANS THE MISC FILE CAN NO LONGER BE TRADED BETWEEN SERVERS
	s["godKiMasteryMod"] << godKiMasteryMod
	s["maxBanTime"] << maxBanTime
	s["customBuildAllowed"] << customBuildAllowed
	s["checkpointBuildDist"] << checkpointBuildDist
	s["anns"] << anns
	s["npcDensity"] << npcDensity
	s["knockback_mod"] << knockback_mod
	s["BraalGym"] << BraalGym
	s["hellAltar"] << hellAltar
	s["battlegroundSystem"] << battlegroundSystem
	s["trainingHours"] << trainingHours
	s["trainingRestoreHours"] << trainingRestoreHours
	s["hostAllowsPacksOnRP"] << hostAllowsPacksOnRP
	s["God_FistMod"] << God_FistMod

	s["SHOW_CHAR_NAME_ON_WHO"] << SHOW_CHAR_NAME_ON_WHO

	s["DEADZONE_PRESSURE_ON"] 							<< DEADZONE_PRESSURE_ON
	s["DEADZONE_PRESSURE_BPLOSS_RESISTANT_RACE"] 	<< DEADZONE_PRESSURE_BPLOSS_RESISTANT_RACE
	s["DEADZONE_PRESSURE_BPLOSS_LIVING"] 			<< DEADZONE_PRESSURE_BPLOSS_LIVING
	s["DEADZONE_PRESSURE_BPLOSS_KEEPBODY"] 			<< DEADZONE_PRESSURE_BPLOSS_KEEPBODY
	s["DEADZONE_PRESSURE_BPLOSS_DEAD"] 				<< DEADZONE_PRESSURE_BPLOSS_DEAD

	s["DEADZONE_PRESSURE_BPLOSS_IMMUNE_RACES"] 			<< DEADZONE_PRESSURE_BPLOSS_IMMUNE_RACES
	s["DEADZONE_PRESSURE_BPLOSS_RESISTANT_RACES"] 			<< DEADZONE_PRESSURE_BPLOSS_RESISTANT_RACES

	s["CAN_MASTER_LIMIT_BREAK"] 				<< CAN_MASTER_LIMIT_BREAK
	s["LIMIT_BREAK_MAX_MASTERY"] 				<< LIMIT_BREAK_MAX_MASTERY
	s["LIMIT_BREAK_MIN_DURATION"] 	<< LIMIT_BREAK_MIN_DURATION
	s["LIMIT_BREAK_MAX_DURATION"] 	<< LIMIT_BREAK_MAX_DURATION

	s["SENSE_SYSTEM_SHOW_VAGUE_INFO"] 				<< SENSE_SYSTEM_SHOW_VAGUE_INFO
	s["SENSE_SYSTEM_SHOW_STAT_BUILD"] 				<< SENSE_SYSTEM_SHOW_STAT_BUILD

	s["KO_SYSTEM_UNCONSCIOUS_KO"] 				<< KO_SYSTEM_UNCONSCIOUS_KO
	s["KO_SYSTEM_UNCONSCIOUS_KO_DURATION"] 		<< KO_SYSTEM_UNCONSCIOUS_KO_DURATION
	s["KO_SYSTEM_NORMAL_KO_DURATION"] 			<< KO_SYSTEM_NORMAL_KO_DURATION
	s["KO_SYSTEM_OUT_OF_COMBAT_TIMER"] 			<< KO_SYSTEM_OUT_OF_COMBAT_TIMER
	s["KO_SYSTEM_OUT_OF_COMBAT"] 				<< KO_SYSTEM_OUT_OF_COMBAT
	s["KO_SYSTEM_HEAL_ANNOUNCE_TIMER"] 			<< KO_SYSTEM_HEAL_ANNOUNCE_TIMER

	s["KO_SYSTEM_STATS_AFFECT_HEAL_TIME"] 		<< KO_SYSTEM_STATS_AFFECT_HEAL_TIME
	s["KO_SYSTEM_DEATH_REGEN_HEALS_KO"] 		<< KO_SYSTEM_DEATH_REGEN_HEALS_KO
	s["KO_SYSTEM_SURVIVE_IF_NONLETHAL"] 		<< KO_SYSTEM_SURVIVE_IF_NONLETHAL

	s["KO_SYSTEM_REGENERATOR_MODIFIER"] 		<< KO_SYSTEM_REGENERATOR_MODIFIER
	s["KO_SYSTEM_GIVEPOWER_MODIFIER"] 			<< KO_SYSTEM_GIVEPOWER_MODIFIER
	s["KO_SYSTEM_REGENERATE_MODIFIER"] 			<< KO_SYSTEM_REGENERATE_MODIFIER

	s["DO_VAMPIRES_NEED_TO_FEED"] 					<< DO_VAMPIRES_NEED_TO_FEED
	s["DO_VAMPIRES_INFECT_ON_BITE"] 				<< DO_VAMPIRES_INFECT_ON_BITE
	s["VAMPIRE_POWER_FALL_INTERVAL"] 				<< VAMPIRE_POWER_FALL_INTERVAL

	s["GLOBAL_SCIENCE_TAB_ITEMS"] 					<< GLOBAL_SCIENCE_TAB_ITEMS

	s["CLONING_SYSTEM_LIFESPAN_LOSS"] 				<< CLONING_SYSTEM_LIFESPAN_LOSS
	s["CLONING_SYSTEM_POTENTIAL_LOSS"] 				<< CLONING_SYSTEM_POTENTIAL_LOSS


	s["KO_SYSTEM_T_HEAL_USAGE_LIMIT"] 				<< KO_SYSTEM_T_HEAL_USAGE_LIMIT
	s["KO_SYSTEM_T_HEAL_FAIL_COOLDOWN"] 			<< KO_SYSTEM_T_HEAL_FAIL_COOLDOWN
	s["KO_SYSTEM_SENSU_COOLDOWN"] 					<< KO_SYSTEM_SENSU_COOLDOWN

	s["melee_delay_severity"] 						<< melee_delay_severity
	s["GLOBAL_MELEE_SPEED_OFFSET"] 					<< GLOBAL_MELEE_SPEED_OFFSET
	s["GLOBAL_ACCURACY_EXPONENT"] 					<< GLOBAL_ACCURACY_EXPONENT
proc/loadMisc()
	loadCustomDecors()
	if(!fexists("Misc"))
		applyNexusServerFeatureDefaultsMigration()
		return
	var/savefile/s=new("Misc")
	s["Status_Message"]>>Status_Message
	s["PVP"]>>PVP
	s["Earth_Only"]>>Earth_Only
	s["Automate_Tech_Power"]>>Automate_Tech_Power
	s["Tech_BP"]>>Tech_BP
	s["Illegal_Science"]>>Illegal_Science
	s["Bounties"]>>Bounties
	s["Council"]>>Council
	s["SP_Multiplier"]>>SP_Multiplier
	s["Allow_Ban_Votes"]>>Allow_Ban_Votes
	s["Resource_Multiplier"]>>Resource_Multiplier
	s["Can_Pwipe_Vote"]>>Can_Pwipe_Vote
	s["BP_Cap"]>>BP_Cap
	s["Ki_Disabled"]>>Ki_Disabled
	s["Gun_Power"]>>Gun_Power
	s["Illegal_Races"]>>Illegal_Races
	s["Ki_Gain"]>>Ki_Gain
	s["Perma_Death"]>>Perma_Death
	s["Tournament_Timer"]>>Tournament_Timer
	s["Stat_Leech"]>>Stat_Leech
	s["Start_BP"]>>Start_BP
	s["Learn_Disabled"]>>Learn_Disabled
	s["Train_Disabled"]>>Train_Disabled
	s["Base_Stat_Gain"]>>Base_Stat_Gain
	s["Tournament_Prize"]>>Tournament_Prize
	s["auto_revive_timer"]>>auto_revive_timer
	s["Safezones"]>>Safezones
	s["Server_Ratings"]>>Server_Ratings
	s["Auto_Rank"]>>Auto_Rank
	s["Safezone_Distance"]>>Safezone_Distance
	s["Turf_Strength"]>>Turf_Strength
	s["KO_Time"]>>KO_Time
	s["Server_Regeneration"]>>Server_Regeneration
	s["Server_Recovery"]>>Server_Recovery
	s["SSj_Mastery"]>>SSj_Mastery
	s["ssj_easy"]>>ssj_easy
	s["Max_Players"]>>Max_Players
	s["Max_Zombies"]>>Max_Zombies
	s["Prison_Money"]>>Prison_Money
	s["reincarnation_loss"]>>reincarnation_loss
	s["banned_from_hosting"]>>banned_from_hosting
	s["death_setting"]>>death_setting
	s["max_gravity"]>>max_gravity
	s["reincarnation_recovery"]>>reincarnation_recovery
	//S["epic_list"]>>epic_list
	s["allow_age_choosing"]>>allow_age_choosing
	s["cyber_bp_mod"]>>cyber_bp_mod
	s["leech_strongest"]>>leech_strongest
	s["strongest_bp_gain_penalty"]>>strongest_bp_gain_penalty
	s["melee_power"]>>melee_power
	s["ki_power"]>>ki_power
	s["alignment_on"]>>alignment_on
	s["alts"]>>alts
	s["max_villains"]>>max_villains
	s["ssj_voting"]>>ssj_voting
	s["max_Saiyan_percent"]>>max_Saiyan_percent
	s["npcs_enabled"]>>npcs_enabled
	s["skill_tournament_chance"]>>skill_tournament_chance
	s["max_auto_leech"]>>max_auto_leech
	s["bp_tiers"]>>bp_tiers
	s["sagas"]>>sagas
	s["gain_tier_from_tournament"]>>gain_tier_from_tournament
	s["hero_training_gives_tier"]>>hero_training_gives_tier
	s["npcs_give_hbtc_keys"]>>npcs_give_hbtc_keys
	s["adapt_mod"]>>adapt_mod
	s["Illegal_learnables"]>>Illegal_learnables
	s["destroyed_planets"]>>destroyed_planets
	s["forced_injections"]>>forced_injections
	s["planet_destroy_immunity_time"]>>planet_destroy_immunity_time
	s["planet_destroy_bp_requirement"]>>planet_destroy_bp_requirement
	s["planet_destroy_uses"]>>planet_destroy_uses
	s["destroyable_planets"]>>destroyable_planets
	s["im_trapped_allowed"]>>im_trapped_allowed
	s["Tech_BP"]>>Tech_BP
	s["offline_gains"]>>offline_gains
	s["death_cures_vampires"]>>death_cures_vampires
	s["wall_INT_scaling"]>>wall_INT_scaling
	s["percent_of_wall_breakers"]>>percent_of_wall_breakers
	s["disabled_planets"]>>disabled_planets
	s["meteor_density"]>>meteor_density
	s["OOC"]>>OOC
	s["energy_cap"]>>energy_cap
	s["alt_limit"]>>alt_limit
	s["pwipe_vote_year"]>>pwipe_vote_year
	s["pwipe_vote_bp"]>>pwipe_vote_bp
	s["db_vampire_incurable"]>>db_vampire_incurable
	s["bank_list"]>>bank_list
	s["banked_items"]>>banked_items
	s["allow_diagonal_movement"]>>allow_diagonal_movement
	s["max_buff_bp"]>>max_buff_bp
	s["skill_tournament_bp_boost"]>>skill_tournament_bp_boost
	s["minimum_bounty"]>>minimum_bounty
	s["incline_on"]>>incline_on
	s["pwipe_delete_map"]>>pwipe_delete_map
	s["pwipe_turf_health"]>>pwipe_turf_health
	s["pwipe_delete_items"]>>pwipe_delete_items
	s["pwipe_cost_threshold"]>>pwipe_cost_threshold
	s["dbz_character_mode"]>>dbz_character_mode
	s["disabled_dbz_characters"]>>disabled_dbz_characters
	s["toxic_waste_on"]>>toxic_waste_on
	s["zombie_reproduce_mod"]>>zombie_reproduce_mod
	s["car_wreck_frequency"]>>car_wreck_frequency
	s["inspire_allowed"]>>inspire_allowed
	s["death_anger_gives_ssj"]>>death_anger_gives_ssj
	s["bp_soft_cap"]>>bp_soft_cap

	s["SHOW_CHAR_NAME_ON_WHO"]>>SHOW_CHAR_NAME_ON_WHO

	s["DEADZONE_PRESSURE_ON"] >> DEADZONE_PRESSURE_ON
	s["DEADZONE_PRESSURE_BPLOSS_RESISTANT_RACE"] >> DEADZONE_PRESSURE_BPLOSS_RESISTANT_RACE
	s["DEADZONE_PRESSURE_BPLOSS_LIVING"] >> DEADZONE_PRESSURE_BPLOSS_LIVING
	s["DEADZONE_PRESSURE_BPLOSS_KEEPBODY"] >> DEADZONE_PRESSURE_BPLOSS_KEEPBODY
	s["DEADZONE_PRESSURE_BPLOSS_DEAD"] >> DEADZONE_PRESSURE_BPLOSS_DEAD
	s["DEADZONE_PRESSURE_BPLOSS_IMMUNE_RACES"] >> DEADZONE_PRESSURE_BPLOSS_IMMUNE_RACES
	s["DEADZONE_PRESSURE_BPLOSS_RESISTANT_RACES"] >> DEADZONE_PRESSURE_BPLOSS_RESISTANT_RACES

	s["CAN_MASTER_LIMIT_BREAK"] 				>> CAN_MASTER_LIMIT_BREAK
	s["LIMIT_BREAK_MAX_MASTERY"] 				>> LIMIT_BREAK_MAX_MASTERY
	s["LIMIT_BREAK_MIN_DURATION"] 	>> LIMIT_BREAK_MIN_DURATION
	s["LIMIT_BREAK_MAX_DURATION"] 	>> LIMIT_BREAK_MAX_DURATION

	s["SENSE_SYSTEM_SHOW_VAGUE_INFO"] 	>> SENSE_SYSTEM_SHOW_VAGUE_INFO
	s["SENSE_SYSTEM_SHOW_STAT_BUILD"] 	>> SENSE_SYSTEM_SHOW_STAT_BUILD

	s["DO_VAMPIRES_NEED_TO_FEED"] 		>> DO_VAMPIRES_NEED_TO_FEED
	s["DO_VAMPIRES_INFECT_ON_BITE"] 	>> DO_VAMPIRES_INFECT_ON_BITE
	s["VAMPIRE_POWER_FALL_INTERVAL"] 	>> VAMPIRE_POWER_FALL_INTERVAL

	s["GLOBAL_SCIENCE_TAB_ITEMS"] 		>> GLOBAL_SCIENCE_TAB_ITEMS

	s["KO_SYSTEM_UNCONSCIOUS_KO"] 			>> KO_SYSTEM_UNCONSCIOUS_KO
	s["KO_SYSTEM_UNCONSCIOUS_KO_DURATION"] 	>> KO_SYSTEM_UNCONSCIOUS_KO_DURATION
	s["KO_SYSTEM_NORMAL_KO_DURATION"] 		>> KO_SYSTEM_NORMAL_KO_DURATION
	s["KO_SYSTEM_OUT_OF_COMBAT_TIMER"] 		>> KO_SYSTEM_OUT_OF_COMBAT_TIMER
	s["KO_SYSTEM_OUT_OF_COMBAT"] 			>> KO_SYSTEM_OUT_OF_COMBAT
	s["KO_SYSTEM_HEAL_ANNOUNCE_TIMER"] 		>> KO_SYSTEM_HEAL_ANNOUNCE_TIMER

	s["KO_SYSTEM_STATS_AFFECT_HEAL_TIME"] 	>> KO_SYSTEM_STATS_AFFECT_HEAL_TIME
	s["KO_SYSTEM_DEATH_REGEN_HEALS_KO"] 	>> KO_SYSTEM_DEATH_REGEN_HEALS_KO
	s["KO_SYSTEM_SURVIVE_IF_NONLETHAL"] 	>> KO_SYSTEM_SURVIVE_IF_NONLETHAL

	s["KO_SYSTEM_REGENERATOR_MODIFIER"] 	>> KO_SYSTEM_REGENERATOR_MODIFIER
	s["KO_SYSTEM_GIVEPOWER_MODIFIER"] 		>> KO_SYSTEM_GIVEPOWER_MODIFIER
	s["KO_SYSTEM_REGENERATE_MODIFIER"] 		>> KO_SYSTEM_REGENERATE_MODIFIER

	s["CLONING_SYSTEM_LIFESPAN_LOSS"] 	>> CLONING_SYSTEM_LIFESPAN_LOSS
	s["CLONING_SYSTEM_POTENTIAL_LOSS"] 	>> CLONING_SYSTEM_POTENTIAL_LOSS

	s["KO_SYSTEM_T_HEAL_USAGE_LIMIT"] 	>> KO_SYSTEM_T_HEAL_USAGE_LIMIT
	s["KO_SYSTEM_T_HEAL_FAIL_COOLDOWN"] >> KO_SYSTEM_T_HEAL_FAIL_COOLDOWN
	s["KO_SYSTEM_SENSU_COOLDOWN"] 		>> KO_SYSTEM_SENSU_COOLDOWN
	s["melee_delay_severity"] 			>> melee_delay_severity
	s["GLOBAL_MELEE_SPEED_OFFSET"] 		>> GLOBAL_MELEE_SPEED_OFFSET
	s["GLOBAL_ACCURACY_EXPONENT"] 		>> GLOBAL_ACCURACY_EXPONENT

	if("can_admin_vote" in s) s["can_admin_vote"]>>can_admin_vote
	if("allow_guests" in s) s["allow_guests"]>>allow_guests
	if("can_ignore_SI" in s) s["can_ignore_SI"]>>can_ignore_SI
	if("drone_instructions" in s) s["drone_instructions"]>>drone_instructions
	if("era_resets" in s) s["era_resets"]>>era_resets
	if("era_bp_division" in s) s["era_bp_division"]>>era_bp_division
	if("era_target_bp" in s) s["era_target_bp"]>>era_target_bp
	if("server_zenkai" in s) s["server_zenkai"]>>server_zenkai
	if("highest_era_bp" in s) s["highest_era_bp"]>>highest_era_bp
	if("can_era_vote" in s) s["can_era_vote"]>>can_era_vote
	if("drop_items_on_death" in s) s["drop_items_on_death"]>>drop_items_on_death
	if("doors_kill" in s) s["doors_kill"]>>doors_kill
	if("fps" in s) s["fps"]>>world.fps
	if("lose_resources_on_logout" in s) s["lose_resources_on_logout"]>>lose_resources_on_logout
	if("knowledge_cap_mod" in s) s["knowledge_cap_mod"]>>knowledge_cap_mod
	if("announce_dragon_balls" in s) s["announce_dragon_balls"]>>announce_dragon_balls
	if("saitama_rotations" in s) s["saitama_rotations"]>>saitama_rotations
	if("saitama_queue" in s) s["saitama_queue"]>>saitama_queue
	if("race_stats_only_mode" in s) s["race_stats_only_mode"]>>race_stats_only_mode
	if("BASE_MOVE_DELAY" in s) s["BASE_MOVE_DELAY"]>>BASE_MOVE_DELAY
	if("custom_buffs_allowed" in s) s["custom_buffs_allowed"]>>custom_buffs_allowed
	if("feats_on" in s) s["feats_on"]>>feats_on
	if("nexus_server_feature_defaults_version" in s) s["nexus_server_feature_defaults_version"]>>nexus_server_feature_defaults_version
	if("auto_reboot_hours" in s) s["auto_reboot_hours"]>>auto_reboot_hours
	if("pwipe_delete_feats" in s) s["pwipe_delete_feats"]>>pwipe_delete_feats
	if("override_spawn" in s) s["override_spawn"]>>override_spawn
	if("imitate_allowed" in s) s["imitate_allowed"]>>imitate_allowed
	if("majin_auto_learn" in s) s["majin_auto_learn"]>>majin_auto_learn
	if("dead_power_loss" in s) s["dead_power_loss"]>>dead_power_loss
	if("keep_body_loss" in s) s["keep_body_loss"]>>keep_body_loss
	if("client_fps" in s) s["client_fps"] >> client_fps
	if("zombie_power_mult" in s) s["zombie_power_mult"] >> zombie_power_mult
	if("drone_genocide_off" in s) s["drone_genocide_off"] >> drone_genocide_off
	if("drone_power" in s) s["drone_power"] >> drone_power
	if("prohibited_admins" in s) s["prohibited_admins"] >> prohibited_admins
	if("voting_allowed" in s) s["voting_allowed"] >> voting_allowed
	if("show_names_in_ooc" in s) s["show_names_in_ooc"] >> show_names_in_ooc
	if("can_cyber_KOd_people" in s) s["can_cyber_KOd_people"] >> can_cyber_KOd_people
	if("building_price_mult" in s) s["building_price_mult"] >> building_price_mult
	if("admins_build_free" in s) s["admins_build_free"] >> admins_build_free
	if("exempt_from_host_check" in s) s["exempt_from_host_check"] >> exempt_from_host_check
	if("pack_KT_allowed" in s) s["pack_KT_allowed"] >> pack_KT_allowed
	if("body_swap_time_limit" in s) s["body_swap_time_limit"] >> body_swap_time_limit
	if("max_screen_size" in s) s["max_screen_size"] >> max_screen_size
	if("gta5_wasted" in s) s["gta5_wasted"] >> gta5_wasted
	if("resource_version" in s) s["resource_version"] >> resource_version
	if("admin_allow_base_orbs" in s) s["admin_allow_base_orbs"] >> admin_allow_base_orbs
	if("limit_bind" in s) s["limit_bind"] >> limit_bind
	if("can_go_in_void" in s) s["can_go_in_void"] >> can_go_in_void
	if("can_build_in_void" in s) s["can_build_in_void"] >> can_build_in_void
	if("admins_can_go_in_void" in s) s["admins_can_go_in_void"] >> admins_can_go_in_void
	if("admins_can_build_in_void" in s) s["admins_can_build_in_void"] >> admins_can_build_in_void
	if("lower_stats_off" in s) s["lower_stats_off"] >> lower_stats_off
	if("king_of_Braal" in s) s["king_of_Braal"] >> king_of_Braal
	if("highest_player_count" in s) s["highest_player_count"] >> highest_player_count
	if("dodging_mode" in s) s["dodging_mode"] >> dodging_mode
	if("battleground_spawn_choice_on" in s) s["battleground_spawn_choice_on"] >> battleground_spawn_choice_on
	if("auto_reset_bp_at" in s) s["auto_reset_bp_at"] >> auto_reset_bp_at
	if("allow_dragon_rush" in s) s["allow_dragon_rush"] >> allow_dragon_rush
	if("global_stun_mod" in s) s["global_stun_mod"] >> global_stun_mod
	if("allow_ultra_instinct" in s) s["allow_ultra_instinct"] >> allow_ultra_instinct
	if("explosions_off" in s) s["explosions_off"] >> explosions_off
	if("dust_off" in s) s["dust_off"] >> dust_off
	if("shockwaves_off" in s) s["shockwaves_off"] >> shockwaves_off
	if("stun_stops_movement" in s) s["stun_stops_movement"] >> stun_stops_movement
	if("allow_god_ki" in s) s["allow_god_ki"] >> allow_god_ki
	if("old_age_on" in s) s["old_age_on"] >> old_age_on
	if("lssj_common_race" in s) s["lssj_common_race"] >> lssj_common_race
	if("icer_common_race" in s) s["icer_common_race"] >> icer_common_race
	if("all_rare_races_common" in s) s["all_rare_races_common"] >> all_rare_races_common
	if("viltrumite_grand_regent_account" in s) s["viltrumite_grand_regent_account"] >> viltrumite_grand_regent_account
	if("viltrumite_grand_regent_slot" in s) s["viltrumite_grand_regent_slot"] >> viltrumite_grand_regent_slot
	if("viltrumite_grand_regent_created_at" in s) s["viltrumite_grand_regent_created_at"] >> viltrumite_grand_regent_created_at
	if("helperQuestsOn" in s) s["helperQuestsOn"] >> helperQuestsOn
	if("hakai_bp_advantage_needed" in s) s["hakai_bp_advantage_needed"] >> hakai_bp_advantage_needed
	if("hakai_wipes_character" in s) s["hakai_wipes_character"] >> hakai_wipes_character
	if("gravity_mastery_mod" in s) s["gravity_mastery_mod"] >> gravity_mastery_mod
	if("anyone_can_enter_hbtc" in s) s["anyone_can_enter_hbtc"] >> anyone_can_enter_hbtc
	if("give_countdown_verb" in s) s["give_countdown_verb"] >> give_countdown_verb
	if("give_whisper_verb" in s) s["give_whisper_verb"] >> give_whisper_verb
	if("allow_good_bounties" in s) s["allow_good_bounties"] >> allow_good_bounties
	if("hide_energy_enabled" in s) s["hide_energy_enabled"] >> hide_energy_enabled
	if("drone_limit" in s) s["drone_limit"] >> drone_limit
	if("anns" in s) s["anns"] >> anns

	//hopefully this entry will cease to exist in here from now on as if i am correct saveMisc() RECREATES the savefile each time it saves so
	//since saveMisc() no longer adds a customDecors entry, it wont be there anymore. but still be there for people who using the old one to safely transition
	if("customDecors" in s)
		s["customDecors"] >> customDecors
		//i had to put this here to get rid of spammed ones that were never changed from their initial icon
		DeleteSpamCustomDecors()

	if("godKiMasteryMod" in s) s["godKiMasteryMod"] >> godKiMasteryMod
	if("maxBanTime" in s) s["maxBanTime"] >> maxBanTime
	if("customBuildAllowed" in s) s["customBuildAllowed"] >> customBuildAllowed
	if("checkpointBuildDist" in s) s["checkpointBuildDist"] >> checkpointBuildDist
	if("npcDensity" in s) s["npcDensity"] >> npcDensity
	if("knockback_mod" in s) s["knockback_mod"] >> knockback_mod
	if("BraalGym" in s) s["BraalGym"] >> BraalGym
	if("hellAltar" in s) s["hellAltar"] >> hellAltar
	if("battlegroundSystem" in s) s["battlegroundSystem"] >> battlegroundSystem
	if("trainingHours" in s) s["trainingHours"] >> trainingHours
	if("trainingRestoreHours" in s) s["trainingRestoreHours"] >> trainingRestoreHours
	if("hostAllowsPacksOnRP" in s) s["hostAllowsPacksOnRP"] >> hostAllowsPacksOnRP
	if("God_FistMod" in s) s["God_FistMod"] >> God_FistMod
	applyNexusServerFeatureDefaultsMigration()

	//offline_gains = 1 //forced on. no more option for admins to turn it off
	//feats_on = 1 //forced on now (no. bad for rp to have forced on)
	pwipe_delete_feats = 0
	if(Turf_Strength > max_turf_str) Turf_Strength = max_turf_str

	if(auto_revive_timer < minReviveTimer) auto_revive_timer = minReviveTimer

	//if(banned_from_hosting) shutdown()

proc/saveHero()
	var/savefile/s=new("Hero")
	s<<hero
proc/loadHero() if(fexists("Hero"))
	var/savefile/s=new("Hero")
	s>>hero
proc/saveYear()
	var/savefile/s=new("Year")
	s["Year"]<<Year
	s["Speed"]<<Year_Speed
proc/loadYear() if(fexists("Year"))
	var/savefile/s=new("Year")
	s["Year"]>>Year
	s["Speed"]>>Year_Speed

proc/saveVote()
	var/savefile/s=new("Votes");s["Vote Banned"]<<Vote_Banned;s["RP President"]<<RP_President;s["Head Admin"]<<Head_Admin

proc/loadVote() if(fexists("Votes"))
	var/savefile/s=new("Votes");s["Vote Banned"]>>Vote_Banned;s["RP President"]>>RP_President;s["Head Admin"]>>Head_Admin

proc/saveArea()
	var/savefile/f=new("data/Areas")
	for(var/area/Checkpoint/a in all_areas)
		f["Checkpoint"]<<a.icon_state
		f["Checkpoint Value"]<<a.Value
		break
	for(var/area/Heaven/a in all_areas)
		f["Heaven"]<<a.icon_state
		f["Heaven Value"]<<a.Value
		break
	for(var/area/Hell/a in all_areas)
		f["Hell"]<<a.icon_state
		f["Hell Value"]<<a.Value
		break
	for(var/area/Space/a in all_areas)
		f["Space"]<<a.icon_state
		f["Space Value"]<<a.Value
		break
	for(var/area/Sonku/a in all_areas)
		f["Sonku"]<<a.icon_state
		f["Sonku Value"]<<a.Value
		break
	for(var/area/Earth/a in all_areas)
		f["Earth"]<<a.icon_state
		f["Earth Value"]<<a.Value
		break
	for(var/area/Namekian/a in all_areas)
		f["Namekian"]<<a.icon_state
		f["Namekian Value"]<<a.Value
		break
	for(var/area/Braal/a in all_areas)
		f["Braal"]<<a.icon_state
		f["Braal Value"]<<a.Value
		break
	for(var/area/Arconia/a in all_areas)
		f["Arconia"]<<a.icon_state
		f["Arconia Value"]<<a.Value
		break
	for(var/area/Ice/a in all_areas)
		f["Frost Lord"]<<a.icon_state
		f["Frost Lord Value"]<<a.Value
		break
	for(var/area/Android/a in all_areas)
		f["Android"]<<a.icon_state
		f["Android Value"]<<a.Value
		break
	for(var/area/Jungle/a in all_areas)
		f["Jungle"]<<a.icon_state
		f["Jungle Value"]<<a.Value
		break
	for(var/area/Desert/a in all_areas)
		f["Desert"]<<a.icon_state
		f["Desert Value"]<<a.Value
		break
	for(var/area/SSX/a in all_areas)
		f["SSX"]<<a.icon_state
		f["SSX Value"]<<a.Value
	for(var/area/Kaioshin/a in all_areas)
		f["Kaioshin"]<<a.icon_state
		f["Kaioshin Value"]<<a.Value
proc/loadArea() if(fexists("data/Areas"))
	var/savefile/f=new("data/Areas")
	for(var/area/Earth/a in all_areas)
		f["Earth"]>>a.icon_state
		f["Earth Value"]>>a.Value
	for(var/area/Namekian/a in all_areas)
		f["Namekian"]>>a.icon_state
		f["Namekian Value"]>>a.Value
	for(var/area/Braal/a in all_areas)
		f["Braal"]>>a.icon_state
		f["Braal Value"]>>a.Value
	for(var/area/Arconia/a in all_areas)
		f["Arconia"]>>a.icon_state
		f["Arconia Value"]>>a.Value
	for(var/area/Ice/a in all_areas)
		f["Frost Lord"]>>a.icon_state
		f["Frost Lord Value"]>>a.Value
	for(var/area/Jungle/a in all_areas)
		f["Jungle"]>>a.icon_state
		f["Jungle Value"]>>a.Value
	for(var/area/Desert/a in all_areas)
		f["Desert"]>>a.icon_state
		f["Desert Value"]>>a.Value
	for(var/area/Checkpoint/a in all_areas)
		f["Checkpoint"]>>a.icon_state
		f["Checkpoint Value"]>>a.Value
	for(var/area/Heaven/a in all_areas)
		f["Heaven"]>>a.icon_state
		f["Heaven Value"]>>a.Value
	for(var/area/Hell/a in all_areas)
		f["Hell"]>>a.icon_state
		f["Hell Value"]>>a.Value
	for(var/area/Space/a in all_areas)
		f["Space"]>>a.icon_state
		f["Space Value"]>>a.Value
	for(var/area/Sonku/a in all_areas)
		f["Sonku"]>>a.icon_state
		f["Sonku Value"]>>a.Value
	for(var/area/SSX/a in all_areas)
		f["SSX"]>>a.icon_state
		f["SSX Value"]>>a.Value
	for(var/area/Kaioshin/a in all_areas)
		f["Kaioshin"]>>a.icon_state
		f["Kaioshin Value"]>>a.Value

proc/saveItems()
	set background=1
	world<<"Saving items..."
	var/foundobjects=0
	var/savefile/f=new("data/ItemSave")
	var/list/l=new
	for(var/obj/a) if(a.Savable && a.z)
		if(!istype(a,/obj/Resources) || a:Value>=200000)
			foundobjects++
			a.saved_x=a.x
			a.saved_y=a.y
			a.saved_z=a.z
			l+=a
	f["SavedItems"]<<l
	world<<"Items saved ([foundobjects] items)"

proc/loadItems()
	var/amount=0
	if(fexists("data/ItemSave"))
		var/savefile/f=new("data/ItemSave")
		var/list/l=new
		f["SavedItems"]>>l
		for(var/obj/a in l)
			amount+=1
			a.SafeTeleport(locate(a.saved_x,a.saved_y,a.saved_z))
		for(var/mob/a in l)
			amount+=1
			a.SafeTeleport(locate(a.saved_x,a.saved_y,a.saved_z))
	world<<"Items Loaded ([amount])."

	for(var/obj/items/Senzu/s in senzus) s.Senzu_grow()

atom/var
	saved_x=1
	saved_y=1
	saved_z=1
mob/var/Savable_NPC
proc/saveNpcs()
	if(!npcs_enabled) return
	var/savefile/f=new("data/NPCs")
	var/list/l=new
	for(var/mob/b) if(b.z&&b.Savable_NPC&&!b.client&&!b.empty_player)
		b.saved_x=b.x
		b.saved_y=b.y
		b.saved_z=b.z
		l+=b
	f<<l
proc/loadNpcs()
	if(!npcs_enabled) return
	if(fexists("data/NPCs"))
		var/savefile/f=new("data/NPCs")
		var/list/l=new
		f>>l
		for(var/mob/b in l) b.SafeTeleport(locate(b.saved_x,b.saved_y,b.saved_z))
proc/saveBodies()
	var/savefile/f=new("data/Bodies")
	var/list/l=new
	for(var/mob/Body/b)
		if(b.z && b.displaykey && world.realtime < b.body_expire_time && b.body_expire_time)
			b.saved_x=b.x
			b.saved_y=b.y
			b.saved_z=b.z
			l+=b
		else if(b.z&&b.body_expire_time&&world.realtime>=b.body_expire_time) del(b)

	return //dont save dead bodies for now, seems uneccessary now that reboots happen very rarely

	clients << "[l.len] dead bodies saved"
	f<<l
proc/loadBodies()
	if(fexists("data/Bodies"))
		var/savefile/f=new("data/Bodies")
		var/list/l=new
		f>>l
		for(var/mob/b in l) b.SafeTeleport(locate(b.saved_x,b.saved_y,b.saved_z))
proc/saveAdmins()
	var/savefile/s=new("Admin");s["Admins"]<<Admins
proc/loadAdmins() if(fexists("Admin"))
	var/savefile/s=new("Admin");s["Admins"]>>Admins
proc/saveBan()
	var/savefile/s=new("BANS")
	s["Bans"]<<Bans
proc/loadBan()
	if(fexists("BANS"))
		var/savefile/s=new("BANS")
		s["Bans"]>>Bans
proc/saveGain()
	var/savefile/s=new("GAIN")
	s["GAIN"]<<Gain
proc/loadGain() if(fexists("GAIN"))
	var/savefile/s=new("GAIN")
	s["GAIN"]>>Gain
proc/saveNotes()
	var/savefile/s=new("Notes")
	s[""]<<Notes
proc/loadNotes() if(fexists("Notes"))
	var/savefile/s=new("Notes")
	s[""]>>Notes
proc/saveStory()
	var/savefile/s=new("STORY")
	s["Storyline"]<<Story
proc/loadStory() if(fexists("STORY"))
	var/savefile/s=new("STORY")
	s["Storyline"]>>Story
proc/saveRanks()
	var/savefile/s=new("Ranks")
	s["rank_window"]<<rank_window
proc/loadRanks() if(fexists("Ranks"))
	var/savefile/s=new("Ranks")
	if(s["rank_window"]) s["rank_window"]>>rank_window
proc/saveJobs()
	var/savefile/s=new("Jobs")
	s[""]<<Jobs
proc/loadJobs() if(fexists("Jobs"))
	var/savefile/s=new("Jobs")
	s[""]>>Jobs
proc/saveLogin()
	var/savefile/s=new("Login Menu")
	s[""]<<Version_Notes
proc/loadLogin() if(fexists("Login Menu"))
	var/savefile/s=new("Login Menu")
	s[""]>>Version_Notes
proc/saveRules()
	var/savefile/s=new("Rules")
	s["Rules"]<<Rules
proc/loadRules() if(fexists("Rules"))
	var/savefile/s=new("Rules")
	s["Rules"]>>Rules
proc/findMaxSpeed() while(1)
	var/amount=1
	for(var/mob/p in players) if(p.Spd>amount) amount=p.Spd
	Max_Speed=amount
	sleep(600)
