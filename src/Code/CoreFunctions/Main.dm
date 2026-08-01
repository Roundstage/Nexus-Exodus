mob/proc/Disabled_Verb_Check()
	if(Train_Disabled) verbs-=/mob/verb/Train_verb
	if(Learn_Disabled) verbs-=/mob/verb/Learn
	if(!alignment_on)
		verbs-=/mob/verb/Change_Alignment
		//verbs-=/mob/verb/Mark_Someone_as_Evil

mob/proc/code_banned()
	return 0
mob/proc/ban_alert(msg)
	//spawn alert(src,msg)
	src<<msg
mob/proc/Carry_over_imprisonments()
	var/save_path = getNexusCharacterSavePath()
	if(!save_path || !fexists(save_path)) return
	var/savefile/F=new(save_path)
	F["Imprisonments"]>>Imprisonments

mob/proc/ClickMakeNewCharacter()
	return src.openNexusCharacterCreator()

mob/proc
	CodebanLoginCheck()
		set waitfor=0
		if(code_banned())
			sleep(10)
			del(src)

	UnsortedClientLoginStuff()
		set waitfor=0
		if(alts=="disallowed")
			if(client) for(var/mob/m in players) if(m!=src&&m.client&&m.client.address==client.address)
				src<<"<font color=red><font size=4>Alts are not allowed on this server"
				sleep(15)
				del(src)
				return
		if(alts=="allowed only if seperate computers")
			if(client) for(var/mob/m in players) if(m!=src&&m.client)
				if(m.client.address==client.address&&m.client.computer_id==client.computer_id)
					src<<"<font color=red><font size=4>Alts are only allowed if using seperate computers"
					sleep(15)
					del(src)
					return
		if(!dbz_character_mode)
			sleep(100)
			//src<<"<font color=yellow>AI training automaticly loaded your character"
			//load()

	StuffThatRunsIfYouClickNewOrLoad()
		set waitfor=0
		if(!client) return
		last_logon = world.time
		playerCharacter = 1
		hideNexusLegacyInterface()
		src << sound(0)
		spawn(200) Great_Ape_revert()
		if(Race=="Namekian") verbs+=typesof(/mob/Namekian/verb)
		load_player_settings()
		Check_if_counterpart_is_alive_or_dead()
		if(Frozen)
			src<<"<font color=yellow>You logged in paralyzed. You will stop being paralyzed in 30 seconds."
			spawn(300) if(src) Frozen=0
		if(!(locate(/obj/Auras) in src))
			contents+=new/obj/Auras
		if(!(locate(/obj/Crandal) in src)) contents+=new/obj/Crandal
		if(!(locate(/obj/Colorfy) in src)) contents+=new/obj/Colorfy
		Fill_Active_Freezes_List()
		Disabled_Verb_Check()
		if(!name||name=="") name=key
		if(!Mob_ID) Mob_ID=get_mob_id()
		if(Race=="Demon"&&!(locate(/obj/Demon_Contract) in src)) contents+=new/obj/Demon_Contract
		//if(key=="Super Saiyan X") if(!(locate(/obj/SSX_Planet) in src)) contents+=new/obj/SSX_Planet
		//if(key=="Sonku") if(!(locate(/obj/Sonku_Planet) in src)) contents+=new/obj/Sonku_Planet
		Remove_Duplicate_Moves()
		RP_President()
		Add_Voting()
		//Fullscreen_Check()
		if(!(locate(/obj/Auto_Attack) in src)) contents+=new/obj/Auto_Attack
		//CenterIcon(src)
		Rearrange_Mode_Check()
		Council_Check()
		Age_Update()
		Safezone()
		check_duplicate_dragon_balls()
		get_tier()
		alt_alignment_check()
		logged_in_on_destroyed_planet_check()
		Update_tab_button_text()
		//fix halfies having 0 base bp and bp mod
		if(base_bp<1) base_bp=1
		if(bp_mod<0.1) bp_mod=0.1
		if(Race=="Majin") Undo_all_t_injections()
		Calm() //because if they relog angry they can stay perma anger instead of just a short burst
		Evil_overlay()
		Delete_excess_buffs()
		if(last_anger>world.time) last_anger=0

		if(Race=="Majin"&&Regenerate==2) Regenerate=majin_new_regen
		if(Race=="Majin"&&bp_mod==2.35) bp_mod=new_majin_bp_mod

		/*if(Race=="Majin" && majin_stat_version <= cur_majin_stat_version)
			alert(src,"Due to recent changes to Majins, you must now redo your stats before you can do anything")
			Redo_Stats()*/

		if(stat_version < cur_stat_ver)
			alert(src,"Due to recent changes in the stat system you must now redo your stats before you can do anything")
			Redo_Stats()
		stat_version = cur_stat_ver

		if(regen<=0||recov<=0)
			src<<"<font size=6><font color=red>Your character was deleted for using the Android stat bug"
			sleep(1)
			Delete_Save(src)

		//Get_Packs(delay = 20)

		Rank_Check()

		if(sagas)
			hero_seniority_check()
			villain_seniority_check()

		//TO FIX A BUG WHERE I GAVE MYSELF INF KNOWLEDGE THEN PEOPLE WITH TECH PACK LEECHED IT. REMOVE ANY TIME
		if(Knowledge>Tech_BP) Knowledge=Tech_BP

		Add_hotbar_proxies()
		Warp=0 //no combos
		if(Race == "Demon" || Race == "Majin")
			if(!(locate(/obj/Imitation) in src)) contents+=new/obj/Imitation

		majin_stat_version=999
		UpdateFeatMultipliers()
		DuplicateModulesBugFix()
		AssignSSjMults()

		if(client) client.fps = client_fps

		SSj_Blue_Logon_Check()
		SSG_Logon_Check()
		GoldFormLogonCheck()
		BioAndroidLogon()
		RemoveAbsorbFromNonZorbRacesIfZorbIsIllegal()

		if(Stat_Focus == "Energy") Stat_Focus = "Balanced" //because there is no longer an energy focus option as it is annoying and useless too think about it
		ShikonAura()
		glide_size = 0
		ResetResourcesCheck()
		NewZenkaiMods()
		ApplyStartingBP()
		FixCantMoveDueToKiAttack()

		if(Race == "Majin")
			if(!(locate(/obj/Goo_Trap) in src))
				contents += new/obj/Goo_Trap

		CheckKingOfBraalVerbs()
		UltraInstinctRevert()

		if(!(locate(/obj/Resources) in src))
			contents += GetCachedObject(/obj/Resources)
			src << "Resource Bag was missing. New resource bag given to [src]"
		DetermineViewSize()

		if(LoginResetBP())
		else Apply_offline_gains()

		if(cyber_bp < 0) cyber_bp = 0 //there was a bug to give someone -infinity cyber bp
		InitHelperQuests()
		if(!give_countdown_verb) verbs -= /mob/verb/Countdown
		if(!give_whisper_verb) verbs -= /mob/verb/Whisper

		winset(src, "statsOverlay", "is-visible=false")
		winset(src, "Bars", "is-visible=false")
		winset(src, "mainwindow.map", "is-visible=true")
		winset(src, "mapwindow.map", "is-visible=true")
		winset(src, "mainwindow", "image=;")
		hideNexusLegacyInterface()
		initializeVitalsHud()
		initializeActionHud()
		initializeNexusChatHud()
		if(client) client.initializeNexusLighting()
		SetSparringMode(sparring_mode, FALSE)

		//this is for the GameJolt Launcher thing. but i had to disable it because if you enter this as your key in the buy packs window it wont work
		//if(key == displaykey && findtext(key, "guest")) displaykey = "[name]-G"

		LoadCharacterHotkeyThing()
		empty_player = 0
		Update_soul_contracts()
		Admin_Check()
		LimitTrainingMsg()
		TrainingTimeLogin()
		if(client) client.DeleteTitleScreen()
		if(jirenAlien) stun_resistance_mod = jirenStunResist
		normalizePrimaryTransformation()

proc/get_mob_id() return rand(1,999999999)
mob/proc
	New_Character(reincarnating,force_race,force_elite,dbz_hair,force_low_class)
		if(force_elite) force_low_class = 0 //cant be both

		Race(force_race=force_race,force_elite=force_elite,force_low_class=force_low_class)
		if(!reincarnating && !dbz_character) rollCharacterMutations()
		else normalizeCharacterMutations()
		//Race(force_race = "Saiyan", force_elite=force_elite,force_low_class=force_low_class)

		bp_loss_from_low_ki=Get_bp_loss_from_low_ki()
		bp_loss_from_low_hp=Get_bp_loss_from_low_hp()

		Racial_Stats()

		if(alignment_on) choose_alignment()
		if(!dbz_character&&Race!="Yeet")
			Skin()

			if(Race=="Alien") Alien_Stuff()

		Choose_Hair(force_hair=dbz_hair)

		if(!dbz_character)
			Name()
			Choose_Age()
			if(!reincarnating) Race_Starting_Stats()
			Go_to_spawn(First_time=1)
			if(formod>=2||Pow>=200)
				contents+=new/obj/Meditate_Level_2
				if(max_ki/Eff<1000) max_ki*=2 //so reincarnaters dont keep doubling ki
			if(prob(Cured_Vampire_Ratio()*100))
				src<<"One of your parents was cured of the vampire virus and is now immune, you were born immune as a \
				result."
				Former_Vampire=1
		FinishNewCharacterSetup()

	FinishNewCharacterSetup()
		switch(src.Race)
			if("Demon")
				src.give_energy_type("Soul Energy")

		src.give_energy_type("Mental Energy")
		src.energy_save_version = ENERGY_SAVE_VERSION


		Player_Loops()

		New_player_message()

		LogYear=Year
		Ki=max_ki
		contents += GetCachedObject(/obj/Resources)
		if(Race in list("Saiyan","Half Saiyan"))
			if(!Tail) Tail_Add()
			contents+=new/obj/Great_Ape
		Savable=1
		Already_Voted[key]=(world.realtime/10/60/60)+6
		if(client&&!client.preload_rsc) src<<"<font size=2><font color=yellow>If this is your first time playing, \
		the game will try to load new resources (icons, sound, etc) as you come across them, which can cause you \
		a bit of lag as they download, but they only have to download once."
		src << "<font color=cyan><font size=2>Spacebar is punch, and Y toggles auto-punch, but you can only punch when there is a target in front of you, for now"
		Mate_Check()
		if(!dbz_character) Born_Vampire_Check()
		if(base_bp<1) base_bp=1
		spawn(20) Tabs = 1 //i didnt want the tabs to try to load in at the exact same time the map is trying to load in. it crashes people maybe. too much
		spawn(40) if(client) client.show_verb_panel = 1
			//data at once
		era=era_resets

		if(OnRestrictedMap()) GoToDeathSpawn()

	Choose_Age()
		var/N=0
		if(allow_age_choosing)
			N=input(src,"What age do you want to start as? This is mostly for people wanting to start past their \
			decline age, which has various penalties and advantages. Your decline age is [Decline]","Choose age",0) as num
		if(N<0) N=0
		if(N>1000) N=1000
		N=round(N,0.1)
		BirthYear=Year-N
		Age=N
		real_age=N
		spawn(600) if(src&&Age>Lifespan()) Die()

	Race_Starting_Stats()
		max_ki*=Eff**0.5
		spawn(20) Random_Colors()

	Random_Colors()
		var/Color=rgb(rand(0,255),rand(0,255),rand(0,255))
		if(0) //PLAYERS VOTED FOR NO STARTING ABILITIES BUT WANTED SP 3x AS FAST
			var/obj/Attacks/Blast/A=new
			var/obj/Attacks/Charge/B=new
			var/obj/Attacks/Beam/C=new
			A.icon=pick('Asset1.dmi','Asset12.dmi','Asset17.dmi','Asset18.dmi','Asset19.dmi','Asset21.dmi','Asset22.dmi','Asset24.dmi','Asset25.dmi')
			B.icon=pick('Asset11.dmi','Asset20.dmi','Asset26.dmi','Asset27.dmi','Asset31.dmi','Asset4.dmi')
			C.icon=pick('Beam1.dmi','Beam2.dmi','Beam3.dmi','Beam6.dmi')
			A.icon+=Color
			B.icon+=Color
			C.icon+=Color
			contents.Add(A,B,C)
		if(BlastCharge) BlastCharge+=Color
		for(var/obj/Auras/D in src) D.icon+=Color

	Name()
		if(!client) return
		name = input(src, "Name? (50 letter limit)") as text
		name = copytext(name, 1, 50)
		name = html_encode(name)
		if(InvalidPlayerName(name))
			name = "No Name"
			Name()

	Check_Spawn(list/L)
		if(world.maxz<5) return L
		for(var/A in L)
			var/Spawn
			for(var/obj/Spawn/S in Spawn_List)
				if(S.name == A && !S.is_on_destroyed_planet())
					var/turf/t=S.loc
					if(t&&isturf(t)&&!t.density)
						Spawn=1
						break
			for(var/mob/m in players) if(m.z) for(var/obj/Mate/m2 in m) if(m2.Waiting&&m2.Race==A)
				Spawn=1
				break
			if(!Spawn) L-=A
		return L
	GetAvailableCharacterRaces(show_cap_alert = 0)
		var/list/Races=Race_List()
		for(var/V in Illegal_Races) if(V in Races) Races-=V

		if(!SSj_Online())
			var/Frost_Lords = 0
			for(var/mob/m in players) if(m.Race=="Frost Lord") Frost_Lords++
			Frost_Lords /= Clamp(Player_Count(),1,1.#INF)
			if(Frost_Lords > 5 / 100)
				if(!icer_common_race)
					Races-="Frost Lord"

		Races = Check_Spawn(Races) //Removes the entry from the list if there is no spawn for it

		for(var/mob/P in players)
			if(P.Class == "Legendary Saiyan" || world.time < 10 * 600 || world.realtime < next_lssj)
				if(!lssj_common_race)
					Races-="Legendary Saiyan"
		//if(key=="EXGenesis") Races+= "Yeet"
		var/Saiyans=0
		var/other=0
		for(var/mob/m in players) if(m.z&&m.client&&m.Race)
			if(m.Race in list("Half Saiyan","Saiyan")) Saiyans++
			else other++

		if(Saiyans) //so it cant be 0
			var/Saiyan_percent=Saiyans/(other+Saiyans)*100
			if(Saiyan_percent>max_Saiyan_percent)
				Races-="Saiyan"
				Races-="Half Saiyan"
				Races-="Legendary Saiyan"
				if(show_cap_alert) alert(src,"The percentage of players playing Saiyan has exceeded the cap set by admins. Saiyan \
				has been removed from the race selection. The max percent of Saiyan allowed is [max_Saiyan_percent]%")
		return Races

	InitializeRaceTemplate(force_race,force_elite,force_low_class,interactive_options=1,force_cooler=0,force_normal_class=0)
		switch(force_race)
			if("Yeet") Yeet()
			if("Human") Human()
			if("Alien") Alien(interactive_options)
			if("Majin") Majin(interactive_options)
			if("Bio-Android") Bio(interactive_options)
			if("Android") Android(interactive_options)
			if("Makyo") Makyo(interactive_options)
			if("Kai") Kai(interactive_options)
			if("Spirit Doll") Doll(interactive_options)
			if("Tsujin") Tsujin(interactive_options)
			if("Namekian") Namekian(interactive_options)
			if("Saiyan") Saiyan(Can_Elite=interactive_options,force_elite=force_elite,force_low_class=force_low_class,force_normal_class=force_normal_class)
			if("Half Saiyan") Half_Saiyan()
			if("Frost Lord") Icer(interactive_options,force_cooler)
			if("Demon") Demon(interactive_options)
			if("Demigod") Demigod(interactive_options)
			if("Legendary Saiyan") Legendary_Saiyan()
		ascension_bp *= bp_mod

	Race(force_race,force_elite,force_low_class,interactive_options=1,force_cooler=0,force_normal_class=0)
		var/list/Races = GetAvailableCharacterRaces(show_cap_alert = interactive_options)

		if(!force_race)
			force_race = input(src,"Choose a race. The most popular are at the top") in Races

		InitializeRaceTemplate(force_race,force_elite,force_low_class,interactive_options,force_cooler,force_normal_class)
		if(force_race == "Legendary Saiyan") next_lssj = world.realtime + (10 * 60 * 600)
