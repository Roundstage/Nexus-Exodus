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
		if(!L.len)
			for(var/obj/Spawn/s in Spawn_List) if(s.z&&!s.is_on_destroyed_planet())
				var/area/a = s.get_area()
				if(excludeShips && a && a.type == /area/ship_area) continue
				if(s.name == getRaceSpawnName(Race)) L+=s
	return L

proc/getRaceSpawnName(race_name)
	switch(race_name)
		if("Kanassan") return "Alien"
		if("Heran") return "Saiyan"
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
			if("Pale") icon='BaseHumanPale.dmi'
			if("Tan") icon='BaseHumanTan.dmi'
			if("Dark") icon='BaseHumanDark.dmi'
		else switch(alert(src,"Choose your skin color","Options","Pale","Tan","Dark"))
			if("Pale") icon='NewPaleFemale.dmi'
			if("Tan") icon='NewTanFemale.dmi'
			if("Dark") icon='NewBlackFemale.dmi'
	Skin()
		var/Colorable
		Gender()
		if(Race=="Alien") Grid(Alien_Icons)
		else if(Race=="Frost Lord") icer_Icons()
		else if(Race=="Bio-Android")
			switch(input(src,"What color body?") in list("Green","Blue"))
				if("Green") icon='CellLarva.dmi'
				if("Blue") icon='CellLarvaBlue.dmi'
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
			icon='WhiteKaio.dmi'
		else if(Race=="Makyo") icon='Makyojin2.dmi'
		else if(Race in list("Phrexian","Kai"))
			if(gender=="male") icon='CustomMale.dmi'
			else icon='CustomFemale.dmi'
			Colorable=1
			switch(input(src,"What icon do you want?") in list("Custom","Human","Avatar"))
				if("Human")
					Human_Skins()
					Colorable=0
				if("Avatar") icon='Avatar.dmi'
		else if(Race=="Demon")
			Grid(Demon_Icons)
			Colorable=1
		else if(Race=="Majin")
			if(gender == "male")
				icon='Majin.dmi'
				Colorable=1
			else icon = 'FemaleMajin.dmi'
		else if(Race in list("Namekian","Ancient Namekian"))
			icon='NamekYoung.dmi'
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
		if(arm_stretch&&arm_stretch_icon=='GenericArm.dmi') Auto_color_arm_stretch_icon()

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
	Alien1 icon='AlienBeetle.dmi'
	Alien2 icon='AlienPikkon.dmi'
	Alien3 icon='AlienKanassa.dmi'
	Alien4 icon='AlienGuldo.dmi'
	Alien5 icon='AlienBass.dmi'
	Alien6 icon='AlienBurter.dmi'
	Alien7 icon='RaceGinyu.dmi'
	Alien8 icon='RaceKui.dmi'
	Alien9 icon='Alien1.dmi'
	Alien10 icon='Alien2.dmi'
	Alien11 icon='Alien3.dmi'
	Alien12 icon='Immecka.dmi'
	Alien13 icon='Yukenojin.dmi'
	Alien14 icon='Baseniojin.dmi'
	Alien15 icon='Konatsu.dmi'
	Alien16 icon='Kanassan.dmi'
	Alien17 icon='Yardrat.dmi'
	Alien18 icon='Makyojin2.dmi'
	Alien19 icon='Alien5.dmi'
	Alien20 icon='Alien4.dmi'
	Alien21 icon='Alien6.dmi'
	Alien22 icon='Alien7.dmi'
	Alien23 icon='Alien8.dmi'
	Alien24 icon='Alien9.dmi'
	Alien25 icon='Alien10.dmi'
	Alien26 icon='AlienFrog.dmi'
	Alien27 icon='AlienHive.dmi'
	Alien28 icon='DemonIfrit.dmi'
	//Alien29 icon='Blob.dmi'
	Alien30 icon='KidAlien.dmi'
	Alien31 icon='FatGuy.dmi'
	Alien32 icon='Antumb.dmi'
	Alien33 icon = 'CLOWN.dmi'
	Alien34 icon = 'Pennywise.dmi'
	Alien35 icon = 'BeerusGodOfDestruction.dmi'
	Alien36 icon = 'Jiren23.dmi'
	Human suffix="Look like a Human"

var/icon/Blob='Blob.dmi' //To keep Blob.dmi in the rsc now that its not an alien icon

var/list/Demon_Icons=new

obj/Demon_Icons
	Givable=0
	Makeable=0
	proc/Choose(mob/P)
		P.icon=icon
		if(istype(src,/obj/Demon_Icons/Human)) P.Human_Skins()
		if(P) P.Tabs="Customize Stats"
		usr.Hide_Main_Grid()
	Demon1 icon='Demon1.dmi'
	Demon2 icon='Demon2.dmi'
	Demon3 icon='Hades.dmi'
	Demon4 icon='Alien2.dmi'
	Demon5 icon='Alien3.dmi'
	Demon6 icon='Demon4.dmi'
	Demon7 icon='Demon5.dmi'
	Demon8 icon='Demon6.dmi'
	Demon9 icon='Demon6Female.dmi'
	Demon10 icon='Demon7.dmi'
	Demon11 icon='Darkrai2.dmi'
	Demon12 icon='DemonJanemba.dmi'
	Demon13 icon='DemonUberVampire.dmi'
	Demon14 icon='DemonWolf.dmi'
	Demon15 icon='DemonElemental.dmi'
	Demon16 icon='AlienSkully.dmi'
	Demon17 icon='AlienTattoo.dmi'
	Demon18 icon='DemonDeath.dmi'
	Demon19 icon='AlienHive.dmi'
	Demon20 icon='DemonIfrit.dmi'
	Demon21 icon='Blob.dmi'
	Demon22 icon='Antumb.dmi'
	Demon23 icon='HollowKing.dmi'
	Demon24 icon='Satan.dmi'
	Demon25 icon='MakaioshinBase.dmi'
	Demon26 icon='Lucifer.dmi'
	Demon27 icon='PossessedSpiritDoll.dmi'
	Demon28 icon='JaganTransformation.dmi'
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
	C30 icon='C1.dmi'
	C31 icon='C2.dmi'
	C32 icon='C3.dmi'
	C33 icon='C4.dmi'
	C34 icon='C5.dmi'
	C35 icon='C6.dmi'
	C36 icon='C7.dmi'
	C37 icon='C8.dmi'
	C38 icon='C9.dmi'
	C39 icon='C10.dmi'
	C40 icon='C11.dmi'
	C1 icon='ChangelingFrieza1002.dmi'
	C2 icon='ChangelingFrieza100.dmi'
	C3 icon='ChangelingFrieza1003.dmi'
	C4 icon='ChangelingFrieza2.dmi'
	C5 icon='ChangelingFriezaForm22.dmi'
	C6 icon='ChangelingFriezaForm2.dmi'
	C7 icon='ChangelingFriezaForm32.dmi'
	C8 icon='ChangelingFriezaForm3.dmi'
	C9 icon='ChangelingFriezaForm42.dmi'
	C10 icon='ChangelingFriezaForm4.dmi'
	C11 icon='ChangelingFrieza.dmi'
	C12 icon='ChangelingKold2.dmi'
	C13 icon='ChangelingKoldForm2.dmi'
	C14 icon='ChangelingKold.dmi'
	C15 icon='ChangelingKoola2.dmi'
	C16 icon='ChangelingKoolaForm2.dmi'
	C17 icon='ChangelingKoolaForm32.dmi'
	C18 icon='ChangelingKoolaForm3.dmi'
	C19 icon='ChangelingKoolaForm43.dmi'
	C20 icon='ChangelingKoolaForm4.dmi'
	C21 icon='ChangelingKoola.dmi'
	C22 icon='ChangelingKuriza.dmi'
	C23 icon='ChangelingKoolaExpand.dmi'
	C24 icon='ChangelingKoolaExpand2.dmi'
	C25 icon='Changeling1Large.dmi'
	C26 icon='Changeling5Frieza.dmi'
	C27 icon='Changeling5Kold.dmi'
	C28 icon='ChangelingFriezaForm43.dmi'
	C29 icon='ChangelingFriezaBe.dmi'
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

var/list/Hairs=new

proc/Fill_Hair_List() for(var/A in typesof(/obj/Hairs)) if(A!=/obj/Hairs) Hairs+=new A

obj/Hairs
	Givable=0
	Makeable=0
	var/SSj_Hair
	var/USSj_Hair
	var/SSjFP_Hair
	var/SSj2_Hair
	var/SSj3_Hair
	Bald/Click() Apply_Hair(usr,src)
	Hair1
		New()
			icon='HairShaggy.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair_Caulifla
		New()
			icon = 'CauliflaHair.dmi'
			SSj_Hair = 'CauliflaHairSSJ.dmi'
			USSj_Hair = 'CauliflaHairUSSJ.dmi'
			SSjFP_Hair = 'CauliflaHairSSjFP.dmi'
			SSj2_Hair = 'CauliflaHairSsj2.dmi'
			SSj3_Hair = SSj2_Hair
		Click() Apply_Hair(usr,src)
	Hair_Kale
		New()
			icon='KaleHair.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair2
		New()
			icon='HairRen.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair3
		New()
			icon='HairShortFemale.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair4
		New()
			icon='HairPonytail.dmi'
			SSj_Hair='HairPonytailSSJ.dmi'
			USSj_Hair=SSj_Hair
			SSjFP_Hair='HairPonytailSsjfp.dmi'
			SSj2_Hair=SSj_Hair
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair5
		New()
			icon='HairFemalePonytail.dmi'
			SSj_Hair = 'HairFemalePonyTailSSj.dmi'
			USSj_Hair=SSj_Hair
			SSjFP_Hair='HairFemalePonyTailSSj.dmi'
			SSj2_Hair='HairFemalePonyTailSSj.dmi'
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair6
		New()
			icon='HairMessy.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair7
		New()
			icon='HairBushy.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair8
		New()
			icon='HairBrownHeadband.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair9
		New()
			icon='HairBlueMale.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair10
		New()
			icon='HairCloud.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(180,180,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair11
		New()
			icon='HairSuper17.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair12
		New()
			icon='HairKidd.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair13
		New()
			icon='HairMuse.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair14
		New()
			icon='HairGoku.dmi'
			SSj_Hair='HairGokuSSj.dmi'
			USSj_Hair='HairGokuUSSj.dmi'
			SSjFP_Hair='HairGokuSSjFP.dmi'
			SSj2_Hair='HairGokuUSSj.dmi'
			SSj3_Hair='HairGokuSSj3Old.dmi'
		Click() Apply_Hair(usr,src)
	Hair15
		New()
			icon='HairVegetaTobiUchiha.dmi'
			SSj_Hair='HairVegetaSSj.dmi'
			USSj_Hair='HairVegetaUSSj.dmi'
			SSjFP_Hair='HairVegetaSSjFPOld.dmi'
			SSj2_Hair='HairVegetaSSj.dmi'
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair16
		New()
			icon='HairRaditz.dmi'
			SSj_Hair='HairRaditzSSj.dmi'
			USSj_Hair='HairGokuSSj3Old.dmi'
			SSjFP_Hair='HairRaditzSSjFP.dmi'
			SSj2_Hair='HairRaditzSSj.dmi'
			SSj3_Hair='HairGokuSSj3Old.dmi'
		Click() Apply_Hair(usr,src)
	Hair17
		New()
			icon='HairFutureGohan.dmi'
			SSj_Hair='HairGohanSSj.dmi'
			USSj_Hair='HairGohanUSSj.dmi'
			SSjFP_Hair='HairGohanSSjFPOriginal.dmi'
			SSj2_Hair='HairGohanSSj.dmi'
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair18
		New()
			icon='HairGohan.dmi'
			SSj_Hair='HairGohanSSj.dmi'
			USSj_Hair='HairGohanUSSj.dmi'
			SSjFP_Hair='HairGohanSSjFP.dmi'
			SSj2_Hair='HairGohanSSj.dmi'
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair19
		New()
			icon='HairLong.dmi'
			SSj_Hair='HairTrunksSSj.dmi'
			USSj_Hair='HairTrunksUSSj.dmi'
			SSjFP_Hair='HairLongSSjFP.dmi'
			SSj2_Hair='HairTrunksSSj.dmi'
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair20
		New()
			icon='HairKidGohan.dmi'
			SSj_Hair='HairKidGohanSSj.dmi'
			USSj_Hair='HairKidGohanUSSj.dmi'
			SSjFP_Hair='HairKidGohanSSjFP.dmi'
			SSj2_Hair='HairKidGohanSSj2.dmi'
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair21
		New()
			icon='HairKylin2.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair='HairFemaleLongSSj.dmi'
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair22
		New()
			icon='HairKylin3.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair23
		New()
			icon='HairAfroLegacy.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair=SSj_Hair
		Click() Apply_Hair(usr,src)
	Hair24
		New()
			icon='HairKylin1.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair25
		New()
			icon='HairBroly.dmi'
			SSj_Hair='HairBrolySSj.dmi'
			USSj_Hair='HairBrolyLssj.dmi'
			SSjFP_Hair=SSj_Hair+rgb(15,15,15)
			SSj2_Hair=SSj_Hair
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair26
		New()
			icon='HairFemaleLong2.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair='HairFemaleLongSSj.dmi'
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair27
		New()
			icon='HairLong.dmi'
			SSj_Hair='HairTrunksSSj.dmi'
			USSj_Hair='HairTrunksUSSj.dmi'
			SSjFP_Hair='HairLongSSjFP.dmi'
			SSj2_Hair='HairTrunksSSj.dmi'
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair28
		New()
			icon='HairGoten.dmi'
			SSj_Hair='HairGokuSSj.dmi'
			USSj_Hair='HairGokuUSSj.dmi'
			SSjFP_Hair='HairGokuSSjFP.dmi'
			SSj2_Hair='HairGokuSSj.dmi'
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair29
		New()
			icon='HairGTTrunks.dmi'
			SSj_Hair='HairTrunksSSj.dmi'
			USSj_Hair='HairGokuUSSj.dmi'
			SSjFP_Hair='HairLongSSjFP.dmi'
			SSj2_Hair='HairTrunksSSj.dmi'
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair30
		New()
			icon='HairGTVegeta.dmi'
			SSj_Hair='HairGTVegetaSSj.dmi'
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair='HairGTVegetaSSj.dmi'
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair31
		New()
			icon='HairMohawk.dmi'
			SSj_Hair='HairMohawkSSj.dmi'
			USSj_Hair='HairTrunksUSSj.dmi'
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair='HairMohawkSSj.dmi'
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair32
		New()
			icon='HairSpike.dmi'
			SSj_Hair='HairSpikeSSj.dmi'
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=SSj_Hair
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair33
		New()
			icon='HairYamcha.dmi'
			SSj_Hair='HairYamchaSSj.dmi'
			USSj_Hair=SSj_Hair
			SSjFP_Hair=SSj_Hair+rgb(15,15,15)
			SSj2_Hair=SSj_Hair
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair34
		New()
			icon='HairVegetaJunior.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair35
		New()
			icon='HairLan.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair36
		New()
			icon='BlackSSJhair.dmi'
			SSj_Hair='HairGokuSSj.dmi'
			USSj_Hair='HairGokuUSSj.dmi'
			SSjFP_Hair='HairGokuSSjFP.dmi'
			SSj2_Hair='HairGokuUSSj.dmi'
			SSj3_Hair='HairGokuSSj3.dmi'
		Click() Apply_Hair(usr,src)
	Hair37
		New()
			icon='VegitoHairPVP.dmi'
			SSj_Hair='HairGokuUSSj.dmi'
			USSj_Hair='HairGokuUSSj.dmi'
			SSjFP_Hair='VegitoHairPVPSSjFP.dmi'
			SSj2_Hair='HairGokuUSSj.dmi'
			SSj3_Hair='HairGokuSSj3.dmi'
		Click() Apply_Hair(usr,src)
	Hair38
		New()
			icon='MezuHair.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSsj4Gogeta.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair39
		New()
			icon='HairStylishBlack.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSsj4Gogeta.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair40
		New()
			icon='HopeFfxiiiHair.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair41
		New()
			icon='HairSsj4Gogeta.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairGokuSSj3.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair42
		New()
			icon='HairHitsugaya.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair43
		New()
			icon='LongFemaleHair.dmi'
			SSj_Hair='LongFemaleHairSsj.dmi'
			USSj_Hair=SSj_Hair
			SSjFP_Hair=SSj_Hair+rgb(20,20,20)
			SSj2_Hair=SSj_Hair
			SSj3_Hair='HairGokuSSj3.dmi'
		Click() Apply_Hair(usr,src)
	Hair44
		New()
			icon='HairVegeta.dmi'
			SSj_Hair='HairVegetaSSj.dmi'
			USSj_Hair='HairVegetaUSSj.dmi'
			SSjFP_Hair='HairVegetaSSjFPOld.dmi'
			SSj2_Hair='HairVegetaSSj.dmi'
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	Hair45
		New()
			icon='HairFemaleLong.dmi'
			SSj_Hair='HairYamchaSSj.dmi'
			USSj_Hair='HairBrolyLssj.dmi'
			SSjFP_Hair=SSj_Hair+rgb(15,15,15)
			SSj2_Hair=SSj_Hair
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)
	CustomHair
		New()
			icon='HairFemaleLong.dmi'
			SSj_Hair=icon+rgb(150,150,0)
			USSj_Hair=SSj_Hair
			SSjFP_Hair=icon+rgb(160,160,80)
			SSj2_Hair=icon+rgb(160,160,20)
			SSj3_Hair='HairSSj4.dmi'+rgb(160,150,30)
		Click() Apply_Hair(usr,src)

proc/Apply_Hair(mob/P,obj/Hairs/O,force_color)
	var/Had_Tail
	if(P.Tail) Had_Tail=1
	P.Tail_Remove()
	P.overlays-=P.hair
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
		P.ssj4hair='HairSSj4.dmi'
		if(P.HairColor) P.ssj4hair+=P.HairColor
		P.base_hair=P.hair
		P.overlays+=P.hair
	if(Had_Tail) P.Tail_Add()
	//P<<"You have selected [O]"

mob/proc/Choose_Android_Icon()
	Android_Icons()
	Grid(Android_Icons)
	while(Grid()) sleep(1)
var/list/Android_Icons
proc/Android_Icons() if(!Android_Icons)
	Android_Icons=new/list
	for(var/V in list('Android.dmi','AndroidBlackout.dmi','AndroidSkeletor.dmi','AndroidSpider.dmi',\
	'BaseAndroid1.dmi','BaseAndroid2.dmi','AndroidProxy.dmi'))
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
