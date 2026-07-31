var/list/Saiyan_armor_icons = list('ArmorBardock.dmi','Armor2.dmi','Armor3.dmi','Armor4.dmi','Armor5.dmi',
	'Armor7.dmi','ArmorElite.dmi','ArmorRit1.dmi','ArmorRit2.dmi','NappaArmor.dmi','RaditzArmorTobiUchiha.dmi',\
	'TurlesArmorTobiUchiha.dmi','WtfArmor.dmi','RedArmor.dmi','BlueArmor.dmi')

proc
	RandomHumanIcon()
		return pick('BaseHumanPale.dmi','BaseHumanTan.dmi','BaseHumanDark.dmi',\
		'NewPaleFemale.dmi','NewTanFemale.dmi','NewBlackFemale.dmi')

	RandomHairIcon()
		var/obj/h = pick(Hairs)
		return h.icon

var/list/Saiyan_soldiers = new

mob
	Saiyan_Army
		var
			init

		New()
			Saiyan_soldiers += src

			if(!init)
				icon = RandomHumanIcon()
				overlays += RandomHairIcon()
				overlays += pick(Saiyan_armor_icons) //temp
				init = 1

			. = ..()

		Del()
			Saiyan_soldiers -= src
			. = ..()

		Saiyan_Soldier
