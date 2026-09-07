mob/proc/Get_spawns(excludeShips = 0)

	if(Teleport_nulled())
		var/list/L=new
		for(var/obj/Spawn/s in Spawn_List)
			var/area/a=locate(/area) in range(0,s)
			if(excludeShips && a && a.type == /area/ship_area) continue
			if(a==get_area()) L+=s
		return L


	var/list/L=new
	if(Earth_Only)
		for(var/obj/Spawn/s in Spawn_List) if(s.z==1)
			L+=s
			break
	else
		if(Spawn_Bind) for(var/obj/Spawn/s in Spawn_List)
			if(s.z&&s.desc==Spawn_Bind&&!s.is_on_destroyed_planet())
				var/area/a = s.get_area()
				if(excludeShips && a && a.type == /area/ship_area) continue
				L+=s
		if(!L.len) L = getSuperEarthRacialSpawns(Race)
		if(!L.len)
			for(var/obj/Spawn/s in Spawn_List) if(s.z&&!s.is_on_destroyed_planet())
				var/area/a = s.get_area()
				if(excludeShips && a && a.type == /area/ship_area) continue
				if(s.name == getRaceSpawnName(Race)) L+=s
		// Disabled homeworlds must not send new Viltrumites back to Saiyan spawns.
		if(!L.len && isViltrumiteSpawnRace(Race) && ("Viltrum" in disabled_planets))
			for(var/obj/Spawn/s in Spawn_List)
				if(s.z == Z_LEVEL_EARTH && s.name == "Human" && !s.is_on_destroyed_planet()) L += s
	return L

proc/getRaceSpawnName(race_name)
	switch(race_name)
		if("Kanassan") return "Alien"
		if("Heran") return "Saiyan"
		if("Viltrumite", "Half-Viltrumite") return "Viltrumite"
	return race_name

mob/proc/Go_to_spawn(First_time = 0, butNotInShipArea, choose_random = 0)
	if(world.maxz<5)
		SafeTeleport(locate(1,1,1))
		return

	if(override_spawn[1] != 0 && override_spawn[2] != 0 && override_spawn[3] != 0)
		SafeTeleport(locate(override_spawn[1], override_spawn[2], override_spawn[3]))

		Planet_Gravity()
		if(gravity_mastered<Gravity) gravity_mastered=Clamp(Gravity,1,15)

		return

	var/list/spawns = Get_spawns(excludeShips = butNotInShipArea)
	if(!spawns.len)
		src<<"There are no spawns for your race, you have been sent to space."
		SafeTeleport(locate(12,496,17))
		return
	var/list/spawn_names=new
	for(var/obj/o in spawns) spawn_names += o.desc
	var/spawn_name
	if(client&&spawn_names.len>1&&!choose_random)
		spawn_name=input(src,"Choose your starting location") in spawn_names
	else spawn_name=pick(spawn_names)
	var/obj/Spawn/s
	for(var/obj/o in spawns) if(o.desc==spawn_name) s=o

	SafeTeleport(s.loc)
	if(!Spawn_Bind) Spawn_Bind=s.desc

	//if(!Teleport_nulled())
	for(var/obj/Spawn_Redirector/SR in s.loc)
		if(SR.respawn_x)
			SafeTeleport(locate(SR.respawn_x,SR.respawn_y,SR.respawn_z))
			for(var/obj/Spawn/s2 in range(0,src)) if(!Spawn_Bind) Spawn_Bind=s2.desc

	if(First_time)
		if(s.desc=="Earth Demon (Weaker)")
			bp_mod=1.4
			gravity_mastered=1
			base_bp=rand(1,150)
			Decline=20
			Decline_Rate=0.25
			Intelligence=0.6
		if(s.desc=="Jungle Planet")
			base_bp*=2
			max_ki=1000*Eff
			if(gravity_mastered<30) gravity_mastered=30
		Planet_Gravity()
		if(gravity_mastered<Gravity) gravity_mastered=Clamp(Gravity,1,15)

proc/Race_Count(R,Z) //retursn how many of this race are on a given z plane
	var/A=0
	for(var/mob/P in players) if(P.Race==R) if(!Z||Z==P.z) A++
	return A

mob/proc/Race_Z() //return the z plane that most of this race is located on
	var/list/L
	for(var/mob/P in players) if(P.Race==Race&&P!=src&&P.z&&!P.Dead)
		if(!L) L=new/list
		L+=P.z
	if(!L) return
	return Found_Most(L)

mob/proc
	Gender()
		gender = "male"
		if(!(Race in list("Bio-Android","Namekian","Android")))
			var/Choice=alert(src,"Choose a gender","","Male","Female")
			switch(Choice)
				if("Female") gender="female"
				if("Male") gender="male"

mob/proc
	Human_Skins()
		//if(gender == "male") icon = pick('BaseHumanPale.dmi', 'BaseHumanTan.dmi', 'BaseHumanDark.dmi')
		//if(gender == "female") icon = pick('NewPaleFemale.dmi', 'NewTanFemale.dmi', 'NewBlackFemale.dmi')
		//return
		if(gender=="male") switch(alert(src,"Choose your skin color","Options","Pale","Tan","Dark"))
			if("Pale") icon='src/Icons/PlayerIcons/BaseIcons/NewHumanIconsFromGuppinas/BaseHumanPale.dmi'
			if("Tan") icon='src/Icons/PlayerIcons/BaseIcons/NewHumanIconsFromGuppinas/BaseHumanTan.dmi'
			if("Dark") icon='src/Icons/PlayerIcons/BaseIcons/NewHumanIconsFromGuppinas/BaseHumanDark.dmi'
		else switch(alert(src,"Choose your skin color","Options","Pale","Tan","Dark"))
			if("Pale") icon='src/Icons/PlayerIcons/BaseIcons/ExGenesisHumans/NewPaleFemale.dmi'
			if("Tan") icon='src/Icons/PlayerIcons/BaseIcons/ExGenesisHumans/NewTanFemale.dmi'
			if("Dark") icon='src/Icons/PlayerIcons/BaseIcons/ExGenesisHumans/NewBlackFemale.dmi'
	Skin()
		var/Colorable
		Gender()
		if(Race=="Alien") Grid(Alien_Icons)
		else if(Race=="Frost Lord") icer_Icons()
		else if(Race=="Bio-Android")
			switch(input(src,"What color body?") in list("Green","Blue"))
				if("Green") icon='src/Icons/PlayerIcons/BaseIcons/CellLarva.dmi'
				if("Blue") icon='src/Icons/PlayerIcons/BaseIcons/CellLarvaBlue.dmi'
		else if(Race=="Android")
			switch(input(src,"Android or Human icon?") in list("Android","Human"))
				if("Android")
					Choose_Android_Icon()
					Colorable=1
				if("Human")
					Human_Skins()
					Colorable=0
		else if(Class=="Spirit Doll")
			//icon='SpiritDoll.dmi'
			icon='src/Icons/PlayerIcons/BaseIcons/ExGenesis1212012/WhiteKaio.dmi'
		else if(Race=="Makyo") icon='src/Icons/PlayerIcons/BaseIcons/Makyojin2.dmi'
		else if(Race in list("Phrexian","Kai"))
			if(gender=="male") icon='src/Icons/PlayerIcons/BaseIcons/CustomMale.dmi'
			else icon='src/Icons/PlayerIcons/BaseIcons/CustomFemale.dmi'
			Colorable=1
			switch(input(src,"What icon do you want?") in list("Custom","Human","Avatar"))
				if("Human")
					Human_Skins()
					Colorable=0
				if("Avatar") icon='src/Icons/PlayerIcons/BaseIcons/Avatar.dmi'
		else if(Race=="Demon")
			Grid(Demon_Icons)
			Colorable=1
		else if(Race=="Majin")
			if(gender == "male")
				icon='src/Icons/PlayerIcons/BaseIcons/Majin.dmi'
				Colorable=1
			else icon = 'src/Icons/PlayerIcons/BaseIcons/FemaleMajin.dmi'
		else if(Race in list("Namekian","Ancient Namekian"))
			icon='src/Icons/PlayerIcons/BaseIcons/NamekYoung.dmi'
			/*switch(input(src,"Choose your skin color") in list("Light Green","Green","Dark Green","Dragon Clan","Foreign Namekian"))
				if("Light Green") icon+=rgb(30,30,30)
				if("Dark Green") icon-=rgb(30,30,30)
				if("Dragon Clan") icon+=rgb(10,10,10)
				if("Foreign Namekian") icon-=rgb(10,10,10)*/
		else
			Human_Skins()
			if(Race=="Demigod") icon+=rgb(60,60,60)
		if(Colorable)
			var/A = input(src,"Choose a color for your character's icon. Select Cancel to have no added color") as color|null
			if(A) icon += A
			base_icon_color = A
		if(arm_stretch&&arm_stretch_icon=='src/Icons/Unsorted/GenericArm.dmi') Auto_color_arm_stretch_icon()

mob/var/base_icon_color

var/list/Alien_Icons=new

obj/Alien_Icons
	Givable=0
	Makeable=0
	proc/Choose()
		usr.icon=icon
		if(istype(src,/obj/Alien_Icons/Human)) usr.Human_Skins()
		if(usr) usr.Tabs="Customize Stats"
		usr.Hide_Main_Grid()
	Alien1 icon='src/Icons/PlayerIcons/BaseIcons/AlienBeetle.dmi'
	Alien2 icon='src/Icons/PlayerIcons/BaseIcons/AlienPikkon.dmi'
	Alien3 icon='src/Icons/PlayerIcons/BaseIcons/AlienKanassa.dmi'
	Alien4 icon='src/Icons/PlayerIcons/BaseIcons/AlienGuldo.dmi'
	Alien5 icon='src/Icons/PlayerIcons/BaseIcons/AlienBass.dmi'
	Alien6 icon='src/Icons/PlayerIcons/BaseIcons/AlienBurter.dmi'
	Alien7 icon='src/Icons/PlayerIcons/BaseIcons/RaceGinyu.dmi'
	Alien8 icon='src/Icons/PlayerIcons/BaseIcons/RaceKui.dmi'
	Alien9 icon='src/Icons/PlayerIcons/BaseIcons/Alien1.dmi'
	Alien10 icon='src/Icons/PlayerIcons/BaseIcons/Alien2.dmi'
	Alien11 icon='src/Icons/PlayerIcons/BaseIcons/Alien3.dmi'
	Alien12 icon='src/Icons/PlayerIcons/BaseIcons/Immecka.dmi'
	Alien13 icon='src/Icons/PlayerIcons/BaseIcons/Yukenojin.dmi'
	Alien14 icon='src/Icons/PlayerIcons/BaseIcons/Baseniojin.dmi'
	Alien15 icon='src/Icons/PlayerIcons/BaseIcons/Konatsu.dmi'
	Alien16 icon='src/Icons/PlayerIcons/BaseIcons/Kanassan.dmi'
	Alien17 icon='src/Icons/PlayerIcons/BaseIcons/Yardrat.dmi'
	Alien18 icon='src/Icons/PlayerIcons/BaseIcons/Makyojin2.dmi'
	Alien19 icon='src/Icons/PlayerIcons/BaseIcons/Alien5.dmi'
	Alien20 icon='src/Icons/PlayerIcons/BaseIcons/Alien4.dmi'
	Alien21 icon='src/Icons/PlayerIcons/BaseIcons/Alien6.dmi'
	Alien22 icon='src/Icons/PlayerIcons/BaseIcons/Alien7.dmi'
	Alien23 icon='src/Icons/PlayerIcons/BaseIcons/Alien8.dmi'
	Alien24 icon='src/Icons/PlayerIcons/BaseIcons/Alien9.dmi'
	Alien25 icon='src/Icons/PlayerIcons/BaseIcons/Alien10.dmi'
	Alien26 icon='src/Icons/PlayerIcons/BaseIcons/AlienFrog.dmi'
	Alien27 icon='src/Icons/PlayerIcons/BaseIcons/AlienHive.dmi'
	Alien28 icon='src/Icons/PlayerIcons/BaseIcons/DemonIfrit.dmi'
	//Alien29 icon='Blob.dmi'
	Alien30 icon='src/Icons/PlayerIcons/BaseIcons/KidAlien.dmi'
	Alien31 icon='src/Icons/PlayerIcons/BaseIcons/FatGuy.dmi'
	Alien32 icon='src/Icons/PlayerIcons/BaseIcons/Antumb.dmi'
	Alien33 icon = 'src/Icons/PlayerIcons/BaseIcons/CLOWN.dmi'
	Alien34 icon = 'src/Icons/PlayerIcons/BaseIcons/Pennywise.dmi'
	Alien35 icon = 'src/Icons/PlayerIcons/BaseIcons/BeerusGodOfDestruction.dmi'
	Alien36 icon = 'src/Icons/PlayerIcons/BaseIcons/Jiren23.dmi'
	Human suffix="Look like a Human"

var/icon/Blob='src/Icons/PlayerIcons/BaseIcons/Blob.dmi' //To keep Blob.dmi in the rsc now that its not an alien icon

var/list/Demon_Icons=new

obj/Demon_Icons
	Givable=0
	Makeable=0
	proc/Choose(mob/P)
		P.icon=icon
		if(istype(src,/obj/Demon_Icons/Human)) P.Human_Skins()
		if(P) P.Tabs="Customize Stats"
		usr.Hide_Main_Grid()
	Demon1 icon='src/Icons/PlayerIcons/BaseIcons/Demon1.dmi'
	Demon2 icon='src/Icons/PlayerIcons/BaseIcons/Demon2.dmi'
	Demon3 icon='src/Icons/PlayerIcons/BaseIcons/Hades.dmi'
	Demon4 icon='src/Icons/PlayerIcons/BaseIcons/Alien2.dmi'
	Demon5 icon='src/Icons/PlayerIcons/BaseIcons/Alien3.dmi'
	Demon6 icon='src/Icons/PlayerIcons/BaseIcons/Demon4.dmi'
	Demon7 icon='src/Icons/PlayerIcons/BaseIcons/Demon5.dmi'
	Demon8 icon='src/Icons/PlayerIcons/BaseIcons/Demon6.dmi'
	Demon9 icon='src/Icons/PlayerIcons/BaseIcons/Demon6Female.dmi'
	Demon10 icon='src/Icons/PlayerIcons/BaseIcons/Demon7.dmi'
	Demon11 icon='src/Icons/PlayerIcons/BaseIcons/Darkrai2.dmi'
	Demon12 icon='src/Icons/PlayerIcons/BaseIcons/DemonJanemba.dmi'
	Demon13 icon='src/Icons/PlayerIcons/BaseIcons/DemonUberVampire.dmi'
	Demon14 icon='src/Icons/PlayerIcons/BaseIcons/DemonWolf.dmi'
	Demon15 icon='src/Icons/PlayerIcons/BaseIcons/DemonElemental.dmi'
	Demon16 icon='src/Icons/PlayerIcons/BaseIcons/AlienSkully.dmi'
	Demon17 icon='src/Icons/PlayerIcons/BaseIcons/AlienTattoo.dmi'
	Demon18 icon='src/Icons/PlayerIcons/BaseIcons/DemonDeath.dmi'
	Demon19 icon='src/Icons/PlayerIcons/BaseIcons/AlienHive.dmi'
	Demon20 icon='src/Icons/PlayerIcons/BaseIcons/DemonIfrit.dmi'
	Demon21 icon='src/Icons/PlayerIcons/BaseIcons/Blob.dmi'
	Demon22 icon='src/Icons/PlayerIcons/BaseIcons/Antumb.dmi'
	Demon23 icon='src/Icons/PlayerIcons/BaseIcons/HollowKing.dmi'
	Demon24 icon='src/Icons/PlayerIcons/BaseIcons/Satan.dmi'
	Demon25 icon='src/Icons/PlayerIcons/BaseIcons/ExGenesis1212012/MakaioshinBase.dmi'
	Demon26 icon='src/Icons/PlayerIcons/BaseIcons/ExGenesis1212012/Lucifer.dmi'
	Demon27 icon='src/Icons/PlayerIcons/BaseIcons/ExGenesis1212012/PossessedSpiritDoll.dmi'
	Demon28 icon='src/Icons/PlayerIcons/BaseIcons/JaganTransformation.dmi'
	Human suffix="Look like a Human"
mob/proc/icer_Icons()
	var/list/L=new
	if(!IsCooler)
		for(var/B in typesof(/obj/Icer)) L+=new B
		while(!Form4Icon)
			Grid(L)
			if(!Form4Icon)
				alert(src,"You must continue choosing icons for all your transformations")
	else
		for(var/B in typesof(/obj/Icer)) L+=new B
		while(!Form5Icon)
			Grid(L)
			if(!Form5Icon)
				alert(src,"You must continue choosing icons for all your transformations")
obj/Icer
	name="Icon"
	Givable=0
	Makeable=0
	Click()
		if(!usr.Form1Icon)
			alert("First form icon chosen. Now choose 2nd form.")
			usr.icon=icon
			usr.Form1Icon=icon
		else if(!usr.Form2Icon)
			alert("Second form icon chosen. Now choose 3rd form.")
			usr.Form2Icon=icon
		else if(!usr.Form3Icon)
			alert("Third form icon chosen. Now choose Final Form.")
			usr.Form3Icon=icon
		else if(!usr.Form4Icon)
			usr.Form4Icon=icon
			usr.Hide_Main_Grid()
		else if (usr.IsCooler)
			alert("Final form icon chosen. Now you go even beyond.")
			usr.Form5Icon=icon
			usr.Hide_Main_Grid()
	C30 icon='src/Icons/PlayerIcons/BaseIcons/C1.dmi'
	C31 icon='src/Icons/PlayerIcons/BaseIcons/C2.dmi'
	C32 icon='src/Icons/PlayerIcons/BaseIcons/C3.dmi'
	C33 icon='src/Icons/PlayerIcons/BaseIcons/C4.dmi'
	C34 icon='src/Icons/PlayerIcons/BaseIcons/C5.dmi'
	C35 icon='src/Icons/PlayerIcons/BaseIcons/C6.dmi'
	C36 icon='src/Icons/PlayerIcons/BaseIcons/C7.dmi'
	C37 icon='src/Icons/PlayerIcons/BaseIcons/C8.dmi'
	C38 icon='src/Icons/PlayerIcons/BaseIcons/C9.dmi'
	C39 icon='src/Icons/PlayerIcons/BaseIcons/C10.dmi'
	C40 icon='src/Icons/PlayerIcons/BaseIcons/C11.dmi'
	C1 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingFrieza1002.dmi'
	C2 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingFrieza100.dmi'
	C3 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingFrieza1003.dmi'
	C4 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingFrieza2.dmi'
	C5 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingFriezaForm22.dmi'
	C6 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingFriezaForm2.dmi'
	C7 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingFriezaForm32.dmi'
	C8 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingFriezaForm3.dmi'
	C9 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingFriezaForm42.dmi'
	C10 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingFriezaForm4.dmi'
	C11 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingFrieza.dmi'
	C12 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingKold2.dmi'
	C13 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingKoldForm2.dmi'
	C14 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingKold.dmi'
	C15 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingKoola2.dmi'
	C16 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingKoolaForm2.dmi'
	C17 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingKoolaForm32.dmi'
	C18 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingKoolaForm3.dmi'
	C19 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingKoolaForm43.dmi'
	C20 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingKoolaForm4.dmi'
	C21 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingKoola.dmi'
	C22 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingKuriza.dmi'
	C23 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingKoolaExpand.dmi'
	C24 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingKoolaExpand2.dmi'
	C25 icon='src/Icons/PlayerIcons/BaseIcons/Changeling1Large.dmi'
	C26 icon='src/Icons/PlayerIcons/BaseIcons/Changeling5Frieza.dmi'
	C27 icon='src/Icons/PlayerIcons/BaseIcons/Changeling5Kold.dmi'
	C28 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingFriezaForm43.dmi'
	C29 icon='src/Icons/PlayerIcons/BaseIcons/ChangelingFriezaBe.dmi'
mob/proc/Choose_Hair(force_hair)
	if(force_hair)
		DBZ_hair(force_hair)
		return
	if(dbz_character)
		src<<"Wish Orbs characters can not change their hair"
		return

	if((Race in list("Majin","Bio-Android","Namekian","Android","Frost Lord"))&&!icon) return
	switch(alert(src,"Custom icon?","Options","Default","Custom"))
		if("Custom")
			var/icon/I
			if(!beginNexusLegacyUploadPrompt())
				src << "Finish the active file prompt before choosing a hair icon."
				return
			I = input(src,"Choose an icon") as icon
			endNexusLegacyUploadPrompt()

			if(IconTooBig(I)) I=null

			var/obj/Hairs/newhair = new/obj/Hairs/CustomHair
			newhair.icon = I

			Apply_Hair(src, newhair)
		else
			Grid(Hairs)

mob/proc/RandomHair()
	if(dbz_character) return
	if(Race in list("Majin","Bio-Android","Namekian","Android","Frost Lord")) return
	var/obj/Hairs/h = pick(Hairs)
	var/clr = rgb(1,1,1)
	if(Race != "Saiyan")
		if(prob(50)) clr = rgb(rand(0,255), rand(0,255), rand(0,255))
	Apply_Hair(src, h, clr)

proc/Apply_Hair(mob/P,obj/Hairs/O,force_color)
	if(!P || !O) return
	var/Had_Tail
	if(P.Tail) Had_Tail=1
	P.Tail_Remove()
	P.overlays.Remove(P.hair, P.ssjhair, P.ussjhair, P.ssjfphair, P.ssj2hair, P.ssj3hair, P.ssj4hair, P.ssj_blue_hair, P.ssj_god_hair)
	P.overlays -= 'src/Icons/PlayerIcons/Hair/Ssj3Mastered.dmi'
	P.base_hair=null
	P.hair=O.icon
	P.ssjhair=O.SSj_Hair
	P.ussjhair=O.USSj_Hair
	P.ssjfphair=O.SSjFP_Hair
	P.ssj2hair=O.SSj2_Hair
	P.ssj3hair=O.SSj3_Hair

	//P.ssj3hair = 'HairGokuSSj3Old.dmi' //override because apparently old ssj3 hair looks better

	P.Hair_Base=P.hair
	P.Hair_Age=P.Age
	P.ssj4hair=null
	P.ssj_blue_hair = null
	P.ssj_god_hair = null
	P.royalBlueHair = null
	if(O.icon)

		//SSJ BLUE HAIR
		var/icon/ssjb_hair = new(O.SSj_Hair)
		var/ssb_color = rgb(0,0,102)
		ssjb_hair.MapColors(ssb_color, "#ffffff", "#000000")
		ssjb_hair -= rgb(255,0,0)
		P.ssj_blue_hair = ssjb_hair

		P.AssignRoyalBlueHair()

		P.ssj_god_hair = O.icon + rgb(200,0,0)

		if(force_color) P.HairColor=force_color
		else if(!P.dbz_character) if((P.Race!="Saiyan"&&P.hair)||(P.Race=="Saiyan"&&P.icon))
			P.HairColor=input(P,"Choose a hair color. Hit Cancel to have default color.") as color|null
		if(P.HairColor) P.hair+=P.HairColor
		P.ssj4hair='src/Icons/PlayerIcons/Hair/HairSSj4.dmi'
		if(P.HairColor) P.ssj4hair+=P.HairColor
		P.base_hair=P.hair
		P.overlays+=P.hair
	if(Had_Tail) P.Tail_Add()
	P.SSj_Hair()
	//P<<"You have selected [O]"

mob/proc/Choose_Android_Icon()
	Android_Icons()
	Grid(Android_Icons)
	while(Grid()) sleep(1)
var/list/Android_Icons
proc/Android_Icons() if(!Android_Icons)
	Android_Icons=new/list
	for(var/V in list('src/Icons/PlayerIcons/BaseIcons/Android.dmi','src/Icons/PlayerIcons/BaseIcons/Androids/AndroidBlackout.dmi','src/Icons/PlayerIcons/BaseIcons/Androids/AndroidSkeletor.dmi','src/Icons/PlayerIcons/BaseIcons/Androids/AndroidSpider.dmi',\
	'src/Icons/PlayerIcons/BaseIcons/Androids/BaseAndroid1.dmi','src/Icons/PlayerIcons/BaseIcons/Androids/BaseAndroid2.dmi','src/Icons/PlayerIcons/BaseIcons/Androids/AndroidProxy.dmi'))
		var/obj/Base_Icon/O=new
		O.icon=V
		Android_Icons+=O
obj/Base_Icon
	Makeable=0
	Givable=0
	Savable=0
	Click()
		usr.icon=icon
		usr<<"Character icon chosen"
		usr.Hide_Main_Grid()
