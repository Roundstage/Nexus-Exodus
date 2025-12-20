
mob/verb/energyinfo()
	set name=".infoenergy"
	winset(src.client,"infocc","text=\"Energy represents the maximum ki that your character can hold.  Using attacks and skills drains this and certain buffs and transformations will drain it. Energy will increase your Recovery. Having lower energy will reduce your BP and it is used for some unlocks.\"")
mob/verb/bpinfo()
	set name=".infobp"
	winset(src.client,"infocc","text=\"Battle Power is a representation of a character's raw power.  This multiplies the effectiveness of your other stats.\"")
mob/verb/angerinfo()
	set name=".infoanger"
	winset(src.client,"infocc","text=\"Anger serves as a multiplier to your BP and builds up over time as you take damage. Witnessing a close friend or loved one die will also make you very angry.\"")
mob/verb/strinfo()
	set name=".infostr"
	winset(src.client,"infocc","text=\"Might represents your character's ability to inflict damage with ki and melee and affects the damage of all attacks. Might, which translates into Strength and Force, works against an opponent's Endurance. Each point in Might grants +1% damage or +0.24% damage to an alien.\"")
mob/verb/endinfo()
	set name=".infoend"
	winset(src.client,"infocc","text=\"Endurance represents your character's ability to resist damage. This reduces the damage of both melee and ki based attacks. Each point in Endurance grants +1% damage reduction or +0.24% damage reduction to an alien. \"")
mob/verb/spdinfo()
	set name=".infospd"
	winset(src.client,"infocc","text=\"Speed represents your character's agility and raw speed. 10% of your speed stat is added to offense and defense to help with accuracy and evasion.  Your speed mod determines your characters movement speed and attack speed, called Refire as well as affecting cooldown.\"")
mob/verb/offinfo()
	set name=".infooff"
	winset(src.client,"infocc","text=\"Offense represents your character's accuracy. Offense works against your opponent's Defense when trying to land melee and force attacks.\"")
mob/verb/definfo()
	set name=".infodef"
	winset(src.client,"infocc","text=\"Defense represents your character's evasion. Defense works against your opponent's Offense when trying to dodge or block an attack.\"")
mob/verb/regeninfo()
	set name=".inforegen"
	winset(src.client,"infocc","text=\"Regeneration represents your character's ability to passively heal its injuries over time.\"")
mob/verb/recovinfo()
	set name=".inforecov"
	winset(src.client,"infocc","text=\"Recovery represents your character's ability to passively regain energy over time.  It directly increases the maximum amount you can power up to.\"")

mob/var/tmp/InCreation=0
mob/proc
	New_Character(EC=0)
		InCreation=1
		PrepareForCreation()
	WipeCharacter()
		Precognition=0
		Sterile=0
		PointsSpent=0
		Asexual=0
		for(var/V in src.vars) V=initial(V)

	PrepareForCreation()
		if(InCreation)
			verbs += /mob/proc/racec
			verbs += /mob/proc/namec
			verbs += /mob/proc/agec
			verbs += /mob/proc/genderc
			verbs += /mob/proc/hairc
			verbs += /mob/proc/iconc
			verbs += /mob/proc/donec
			verbs += /mob/proc/bodyc
			verbs += /mob/proc/BackChar
			verbs += /mob/proc/Skill_Points
			Age = 0
			ImDoingStats=1
			winshow(client,"CharacterCreator",1)
			winset(client,"CharacterCreator","reset=true")
			winset(client,"CharacterCreator.date","text=\"[YearOutput()]\"")
			winset(client,"mapcc","is-default=true")
			loc=locate(rand(1,400),rand(1,400),16)
			winset(client,"namec","text=\"[src.name]\"")
			winset(client,"agec","text=\"Age [Age]\"")
		else
			ImDoingStats=0
			winshow(client,"CharacterCreator",0)
			winset(client,"mapcc","is-default=false")
			winset(client,"mapwindow.map","is-default=true")
			Stats()
			StatRank()
			if(!Offspring&&!Builder) Location()
			if(AllowRares.Find(src.ckey)) AllowRares-=src.ckey
			FixLearnList()
			Alien_Trans_Type()
			UpdateStats("All")
			if(src.Race == "Saiyan"|src.Race=="Half-Saiyan") Tail_Add()
			if(src.Race=="Alien")
				switch(input("Do you want this alien to reproduce Asexually?") in list("Yes","No"))
					if("Yes") Asexual=1
					if("No")  Asexual=0
			TextColorOOC = "#[rand(2,9)][rand(2,9)][rand(2,9)][rand(2,9)][rand(2,9)][rand(2,9)]"
			TextColor    = "#[rand(2,9)][rand(2,9)][rand(2,9)][rand(2,9)][rand(2,9)][rand(2,9)]"
			if(Offspring) if(Race!="Android"&&Race!="Spirit Doll"&&Race!="Bio-Android"&&Race!="Majin") contents+= new/Language/BabyTalk(100,src)
			HasCreated=1
			Savable=1
			GravMod=2
			ICanMate=1
			AgreedtoTerms=0
			LogYear=Year
			YearCreated=Year
			BirthYear=Year-Age
			BirthDate="[YearOutput()]"
			oicon=src.icon
			Ki = MaxKi
			PlanetGravity()
			if(Year>4.9&&!Offspring) GetStarterBoost()
			if(src.Delete)
				var/obj/O = src.Delete
				del(O)
			KiHitEffect+=rgb(rand(0,100),rand(0,100),rand(0,100))
			verbs -= /mob/proc/racec
			verbs -= /mob/proc/bodyc
			verbs -= /mob/proc/namec
			verbs -= /mob/proc/agec
			verbs -= /mob/proc/genderc
			verbs -= /mob/proc/hairc
			verbs -= /mob/proc/iconc
			verbs -= /mob/proc/donec
			verbs -= /mob/proc/BackChar
			verbs -= /mob/proc/Skill_Points
			if(Base<10*BPMod)Base=10*BPMod
			if(Confirm("Would you like to start with your stats 50% to the cap? (There is no downside to doing so)")) CapStats(0.5)
			src.Check_Incarnates()
			GetLanguage()
			if(Race=="Alien") spawn() AlienMPGet()
			if(Race=="Oni") P_BagG=7
			else P_BagG=5

			spawn(5)
				BeenGivenStartingGrav=0
				Gravity()
				StartingGrav()

			if(!usr.Confirm("I agree that I will follow the rules and conduct myself accordingly.")) del(src)
			else AgreedtoTerms = 1
			spawn(30) StoryPrompt()


	donec()
		set hidden=1
		if(SelectingRace == 1) return
		if(Race=="Undefined") return
		if(name==key||name=="player")
			usr<<"You must choose a name first."
			return
		if(Points)
			usr<<"You must spend all of your Points first."
			return
		if(PointsSpent+Points>Max_Points)
			usr<<"Impossible number of points spent.  Please reconnect and attempt again only spending the alloted amount."
			return
		if(HasCreated)
			winshow(client,"CharacterCreator",0)
			usr.verbs -= /mob/proc/donec
			usr.verbs -= /mob/proc/bodyc
			usr.verbs -= /mob/proc/Skill_Points
			return
		if(!icon)
			usr<<"You must choose an icon first."
			return
		if(!SelectedAge&&!Builder&&!HasCreated)if(Race!="Bio-Android"&&Race!="Majin")
			usr<<"You must choose your starting age first."
			return
		if(usr.Confirm("Create [name] the [Age] year old [gender] [Race]?")&&!SelectingRace)
			winshow(client,"CharacterCreator",0)
			InCreation=0
			PrepareForCreation()
			if(usr.ckey=="chewyy")
				src << "<b>JARVIS:</b><i> Welcome, Master Chewyy, applying your default settings.  Please standby."
				src << "<b>Settings being updated!</b>"
				usr.MultikeyApproved = 2
				src << "<i>Multikey setting updated...</i>"
				client.fps = 25
				src << "<i>FPS set...</i>"
				usr.ViewX = 18
				usr.ViewY = 12
				SetMapIconSize(64)
				ScreenConfigure()
				src << "<i>Screen Size adjusted...</i>"
				MacroType = 3
				usr<<"<i>Arrow Keys AND WASD used for movement.</i>"
				winset(client, "mainwindow", "macro = macro3")
				src << "<b>Settings updated. Have a good day, Master Chewyy.</b>"
			else Graphics_Options()
		else return

	createcheck() if(!InCreation&&!Redoing_Stats) winshow(client,"CharacterCreator",0)


	BackChar()
		set hidden=1
		if(Savable) return
		if(HasCreated) return
		winshow(client,"CharacterCreator",0)
		var/mob/player/A = new
		A.key = key
		A = src
		del(src)


	racec()
		set hidden=1
		if(!CanPing) return
		if(Offspring)
			src<<"You must reconnect after selecting an Offspring spot."
			del(src)
		SelectingRace = 1
		CanPing=0
		WipeCharacter()
		RacialPowerAdd=0
		contents=null
		Precognition=0
		MilestonePoints=0
		//for(var/Language/L in src) del(L)
		Asexual=0
		Class="Undefined Class"
		AlignmentNumber=0
		GeneticLearnList=list()
		LearnList=list()
		Race()
		BodyStatGive()
		Racial_Stats()
		winset(client,"raceD","text=\"[RaceDescription]\"")
		winset(client,"racec","text=\"[Race]\"")
		if(Offspring) Points=0
		if(Offspring) PrepareForCreation()
		winset(client,"learnD","text=\"Learn List: [GeneticLearnList.Join(", ")], [MasterLearnList.Join(", ")]\"")
		CanPing=1
		SelectingRace = 0

	bodyc()
		set hidden=1
		if(!Offspring) RedoBodySize()
		winset(client,"bodyc","text=\"[src.Size]\"")
	namec()
		set hidden=1
		Name()
		winset(client,"namec","text=\"[src.name]\"")
	agec()
		set hidden=1
		if(Offspring) return
		if(Race=="Undefined")
			usr<<"You must choose Race first."
			return
		AgeChoice()
		winset(client,"agec","text=\"Age [Age]\"")
	genderc()
		set hidden=1
		if(Race=="Undefined")
			usr<<"You must choose Race first."
			return
		Gender()
		winset(client,"genderc","text=\"[gender]\"")
	hairc()
		set hidden=1
		if(Race=="Undefined")
			usr<<"You must choose Race first."
			return
		Grid("Hair")
	iconc()
		set hidden=1
		if(Race=="Undefined")
			usr<<"You must choose Race first."
			return
		Skin()




	Stats()
		if(Year>19) if(!locate(/Language/Common) in src) contents+=new/Language/Common
		/*var/kiboost=Age*KiMod*2
		if(kiboost>500) kiboost=500
		BaseMaxKi+=kiboost*/
	AgeChoice()
		if(Race=="Android") return
		if(Race=="Bio-Android") return
		if(Race=="Majin") return
		if(Offspring) return
		var/AgeC = input(src,"Choose your starting age from 0 - [round(Decline)]. ([InclineAge] Incline Age | [round(Decline)] Decline Age)") as num
		if(AgeC<1) AgeC=1
		if(AgeC>Decline) AgeC=Decline
		AgeC=round(AgeC)
		AgeC=round(AgeC,1)
		Age=AgeC
		Real_Age=AgeC
		LogYear=Year
		SelectedAge = 1

	Name()
		var/newname = strip_html(copytext(input(src,"Name? ([MAX_NAME_LENGTH] character limit) Renaming is disabled. Choose a permanent name for your character."),1,MAX_NAME_LENGTH))
		real_name = sanitize_name(newname)
		name = newname
		if(!real_name) Name()
	Race()
		src.Signature = rand(100000,999999)
		var/list/A=new
		if(AllowSaiyan) A+="Saiyan"
		if(AllowTuffle) A+="Tuffle"
		if(AllowHuman) A+="Human"
		if(AllowMakyo) A+="Makyojin"
		if(AllowSD)
			for(var/obj/items/Enchanted_Doll/ED in world)
				A+="Spirit Doll"
				break
		if(AllowNamek) A+="Namekian"
		if(AllowAndroid)
			for(var/obj/items/Android_Chassis/AC in world)
				A+="Android"
				break
		if(AllowOni) A+="Oni"
		if(AllowDemon) A+="Demon"
		if(AllowKaio) A+="Kaio"
		if(AllowDemigod) A+="Demigod"
		if(AllowAlien) A+="Alien"
		if(AllowChangeling) A+="Changeling"
		if(AllowHeran) A+="Heran"
		if(AllowYardrat) A+="Yardrat"
		if(AllowKanassa) A+="Kanassa"
		var/TC
		var/SC
		for(var/mob/M in Players)
			TC++
			if(M.Race=="Saiyan") SC++
		if(SC>19) if(SC/TC>0.55&&!src.client.holder) if(!AllowRares.Find(src.ckey)) A-="Saiyan"
		if(src.client && src.client.holder && src.client.holder.level >= 5 || (AllowRares&&AllowRares.Find(src.ckey)) )	//Coder or above | Testserver on or not | Player allowed to pick a rare.    AllowRares.Find(src.client)
			A.Add("Majin","Bio-Android","Legendary Super Saiyan","Changeling","Demon","Kaio")
		for(var/obj/Baby/B in world) A+=B
		A = sortList(A)
		var/obj/Baby/C=input("Choose Race") in A
		if(!isobj(C)) //If no available child is found let them choose their own standard race.
			if(C=="Android") Android()
			else if(C=="Human") Human()
			else if(C=="Legendary Super Saiyan") LSSJ()
			else if(C=="Alien") Alien()
			else if(C=="Yardrat") Yardrat()
			else if(C=="Kanassa") Kanassa()
			else if(C=="Heran") SpacePirate()
			else if(C=="Majin") Majin()
			else if(C=="Bio-Android") Bio()
			else if(C=="Demigod") Demigod()
			else if(C=="Makyojin") Makyojin()
			else if(C=="Kaio") Kaio()
			else if(C=="Spirit Doll") Doll()
			else if(C=="Tuffle") Tuffle()
			else if(C=="Oni") Oni()
			else if(C=="Namekian") Namekian()
			else if(C=="Saiyan") Low()
			else if(C=="Ancient Namekian") AncientNamekian()
			else if(C=="Changeling")
				var/list/Changie_Choices=new
				if(src) if(client)
					Changie_Choices.Add("King Kold","Cooler")
					var/Choice=input("Choose your Changeling Class. Each has distinct advantages and disadvantages.") in Changie_Choices
					if(Choice=="King Kold") Kold()
					if(Choice=="Cooler") Cooler()
			else if(C=="Demon") Demon()
		else
			if(C.Password)
				var/PA=input(src,"[C] Password","New Character",null)
				if(PA!=C.Password) BackChar()
			if(C.Race=="Demon Contract")
				Builder=C.Builder
				Demon()
				Builder=C.Builder
				for(var/mob/M in Players) if(M.key==C.ParentKey||M.key==C.Parent2Key)
					src.MakeContact(M,100)
					M.MakeContact(src,100)
					for(var/Language/L in M) if(L.Mastery>=100) src.contents+=new L.LearnType(100,src)
				if(C.z) loc=locate(C.x,C.y,C.z)
				for(var/mob/P in Players) if(ckey(P.key)==Builder) loc=P.loc
				view(src)<<"[src] fulfills the contract!"
			else if(C.Race=="Artificial Angel")
				Builder=C.Builder
				Kaio()
				Builder=C.Builder
				for(var/mob/M in Players) if(M.key==C.ParentKey||M.key==C.Parent2Key)
					src.MakeContact(M,100)
					M.MakeContact(src,100)
					for(var/Language/L in M) if(L.Mastery>=100) src.contents+=new L.LearnType(100,src)
				if(C.z) loc=locate(C.x,C.y,C.z)
				for(var/mob/P in Players) if(ckey(P.key)==Builder) loc=P.loc
				view(src)<<"[src] comes to life!"
			else if(C.Race=="Bio-Android")
				Builder=C.Builder
				SelectedAge=1
				Bio()
				Builder=C.Builder
				for(var/mob/M in Players) if(M.key==C.ParentKey||M.key==C.Parent2Key)
					src.MakeContact(M,100)
					M.MakeContact(src,100)
					for(var/Language/L in M) if(L.Mastery>=100) src.contents+=new L.LearnType(100,src)
				if(C.z) loc=locate(C.x,C.y,C.z)
				for(var/mob/P in Players) if(ckey(P.key)==Builder) loc=P.loc
				view(src)<<"[src] comes to life!"
			else if(C.Race=="Majin")
				Builder=C.Builder
				SelectedAge=1
				Majin()
				Builder=C.Builder
				for(var/mob/M in Players) if(M.key==C.ParentKey||M.key==C.Parent2Key)
					src.MakeContact(M,100)
					M.MakeContact(src,100)
					for(var/Language/L in M) if(L.Mastery>=100) src.contents+=new L.LearnType(100,src)
				if(C.z) loc=locate(C.x,C.y,C.z)
				for(var/mob/P in Players) if(ckey(P.key)==Builder) loc=P.loc
				view(src)<<"[src] comes to life!"
			else
				Offspring=1
				SelectedAge=1
				alert(src,"Offspring do not get Stat Points.")
				HybridBaby(C)
				for(var/mob/M in Players) if(M.key==C.ParentKey||M.key==C.Parent2Key)
					src.MakeContact(M,100)
					M.MakeContact(src,100)
					for(var/Language/L in M) if(L.Mastery>=100) src.contents+=new L.LearnType(rand(40,60),src)
				Name()
				if(C.z)
					loc=locate(C.x,C.y,C.z)
					view(C)<<"[src] hatches out of the egg!"
				else
					var/mob/SpawnP=C.loc
					loc=SpawnP.loc
					view(SpawnP)<<"[src] is finally born from their parent [SpawnP]!"
			Delete = C



mob/proc/Location()
	if(global.TestServerOn) loc=locate(250,250,7)
	else
		if(Dead&&SeanceYear<Year) loc=locate(DEADX,DEADY,DEADZ)
		else
			switch(Race)
				if("Yardrat") loc=locate(GetSpawnX(YardratSpawn),GetSpawnY(YardratSpawn),GetSpawnZ(YardratSpawn))
				if("Demigod") loc=locate(GetSpawnX(DemigodSpawn),GetSpawnY(DemigodSpawn),GetSpawnZ(DemigodSpawn))
				if("Oni") loc=locate(GetSpawnX(OniSpawn),GetSpawnY(OniSpawn),GetSpawnZ(OniSpawn))
				if("Alien") loc=locate(GetSpawnX(AlienSpawn),GetSpawnY(AlienSpawn),GetSpawnZ(AlienSpawn))
				if("Human") loc=locate(GetSpawnX(HumanSpawn),GetSpawnY(HumanSpawn),GetSpawnZ(HumanSpawn))
				if("Tuffle") loc=locate(GetSpawnX(TuffleSpawn),GetSpawnY(TuffleSpawn),GetSpawnZ(TuffleSpawn))
				if("Namekian") loc=locate(GetSpawnX(NamekianSpawn),GetSpawnY(NamekianSpawn),GetSpawnZ(NamekianSpawn))
				if("Heran") loc=locate(GetSpawnX(HeranSpawn),GetSpawnY(HeranSpawn),GetSpawnZ(HeranSpawn))
				if("Saiyan") loc=locate(GetSpawnX(SaiyanSpawn),GetSpawnY(SaiyanSpawn),GetSpawnZ(SaiyanSpawn))
				if("Changeling") loc=locate(GetSpawnX(IcerSpawn),GetSpawnY(IcerSpawn),GetSpawnZ(IcerSpawn))
				if("Makyojin") loc=locate(GetSpawnX(MakyoSpawn),GetSpawnY(MakyoSpawn),GetSpawnZ(MakyoSpawn))
		spawn(10)
			BeenGivenStartingGrav=0
			Gravity()
			StartingGrav()
		//else if(Race=="Android") loc=locate(Android_SpawnX,Android_SpawnY,Android_SpawnZ)//android ship
	if(!z) loc=locate(1,1,1)


proc/GetSpawnX(spawnLoc) return text2num(copytext(spawnLoc,1,findtext(spawnLoc,",")))
proc/GetSpawnY(spawnLoc) return text2num(copytext(spawnLoc,findtext(spawnLoc,",")+1,findtext(spawnLoc,",",findtext(spawnLoc,",")+1)) )
proc/GetSpawnZ(spawnLoc) return text2num(copytext(spawnLoc,findtext(spawnLoc,",",findtext(spawnLoc,",")+1)+1))

/*
area/CustomSpawnChoose
	verb/Choose_Custom_Spawn()
		set category="Spawn Location"
		set src in range(1)
		usr.UsesSpawn=input("Choose your spawn point") in list("Namek","Icer","Arconia")
		if(usr.UsesSpawn=="Arconia") usr.UsesSpawn=pick("Arconia1","Arconia2")
		usr.Location()
		switch(usr.UsesSpawn)
			if("Arconia1")
				usr.contents+=new/Language/Arconian(100,usr)
			if("Arconia2")
				usr.contents+=new/Language/Arconian(100,usr)
			if("Namek")
				usr.contents+=new/Language/Namekian(100,usr)
			if("Icer")
				usr.GravMastered=20
				usr.contents+=new/Language/Common(100,usr)
			if("Earth")
				usr.contents+=new/Language/English(100,usr)
			if("Vegeta")
				usr.contents+=new/Language/Tuffle(100,usr)*/
mob/proc
	Alien_Trans_Type()
		if(Race=="Heran"||Race=="Half-Heran")
			BojackMult=1.5
			SuperBojackMult=1.25
			src << "Your people, the Space Pirates, have always imbued the peak of physical strength. As such you have a melee based transformation, one that is stronger than most."
		if(Race=="Changeling"||Race=="Half-Changeling") GetChangieTrans()
		if(Race=="Saiyan")
			if(Class=="Undefined Class")
				SSjMult=1.5
				SSj2Mult=1.3
			else if(Class=="Legendary")
				SSjMult = 1.5
				SSj2Mult= 1.55
				HasSSj = 1
		if(Race=="Half-Saiyan")
			SSjMult=1.5
			SSj2Mult=1.3
		if(Race=="Part-Saiyan")
			SSjMult=1.8

	Gender()
		if(Race=="Changeling"|Race=="Namekian"|Race=="Bio-Android"|Race=="Android"|Race=="Majin"||Asexual)
			Asexual=1
			gender="plural"
		else if(!Asexual)
			var/Choice=alert(src,"Choose a gender","","Male","Female")
			switch(Choice)
				if("Female") gender="female"
				if("Male") gender="male"
		//if(Asexual) gender="Asexual"
/*
	Human_Skins()
		if(gender=="male") Grid("CreationHumanM")
		else Grid("CreationHumanF")
*/
	Skin()
		var/Colorable
		if(Offspring == 1 && Age < 2)
			if(Race=="Changeling") Grid("CreationChangeling")
			else if(Race=="Namekian") icon='Kid Namekian.dmi'
			else
				if(gender=="female") icon='BabyGirl.dmi'
				else icon='BabyBoy.dmi'
		else switch(Race)
			if("Yardrat") Grid("CreationYardrat")
			if("Heran") Grid("CreationAlien")
			if("Kanassa") Grid("CreationKanassa")
			if("Changeling") Grid("CreationChangeling")
			if("Bio-Android") Grid("CreationBio")
			if("Android") Grid("CreationAndroid")
			if("Spirit Doll")Grid("CreationSD")
			if("Makyojin") Grid("CreationMakyo")
			if("Oni") Grid("CreationOni")
			if("Kaio") Grid("CreationKaio")
			if("Demon")Grid("CreationDemon")
			if("Majin") Grid("CreationMajin")
			if("Alien") Grid("CreationAlien")
			if("Namekian")Grid("CreationNamekian")
			else Grid("CreationHumanM")
		if(src.Race=="Alien"||src.Race=="Majin"||src.Race=="Demon"||src.Race=="Kaio"||src.Race=="Makyo") Colorable=1
		if(Colorable)
			var/A=input("Choose a color") as color|null
			var/icon/I = new(icon)
			if(A)
				I.MapColors(A,"#ffffff","#000000")
				I.MapColors(A,"#ffffff","#000000")
				I.MapColors(A,"#ffffff","#000000")
			icon=I
