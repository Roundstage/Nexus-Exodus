var/list/Saiyan_armor_icons = list('src/Icons/PlayerIcons/Clothes/Armor/ArmorBardock.dmi','src/Icons/PlayerIcons/Clothes/Armor/Armor2.dmi','src/Icons/PlayerIcons/Clothes/Armor/Armor3.dmi','src/Icons/PlayerIcons/Clothes/Armor/Armor4.dmi','src/Icons/PlayerIcons/Clothes/Armor/Armor5.dmi',
	'src/Icons/PlayerIcons/Clothes/Armor/Armor7.dmi','src/Icons/PlayerIcons/Clothes/Armor/ArmorElite.dmi','src/Icons/PlayerIcons/Clothes/Armor/ArmorRit1.dmi','src/Icons/PlayerIcons/Clothes/Armor/ArmorRit2.dmi','src/Icons/PlayerIcons/Clothes/Armor/NappaArmor.dmi','src/Icons/PlayerIcons/TobiUchihaIcons/RaditzArmorTobiUchiha.dmi',\
	'src/Icons/PlayerIcons/TobiUchihaIcons/TurlesArmorTobiUchiha.dmi','src/Icons/PlayerIcons/TobiUchihaIcons/WtfArmor.dmi','src/Icons/PlayerIcons/TobiUchihaIcons/RedArmor.dmi','src/Icons/PlayerIcons/TobiUchihaIcons/BlueArmor.dmi')

proc
	RandomHumanIcon()
		return pick('src/Icons/PlayerIcons/BaseIcons/NewHumanIconsFromGuppinas/BaseHumanPale.dmi','src/Icons/PlayerIcons/BaseIcons/NewHumanIconsFromGuppinas/BaseHumanTan.dmi','src/Icons/PlayerIcons/BaseIcons/NewHumanIconsFromGuppinas/BaseHumanDark.dmi',\
		'src/Icons/PlayerIcons/BaseIcons/ExGenesisHumans/NewPaleFemale.dmi','src/Icons/PlayerIcons/BaseIcons/ExGenesisHumans/NewTanFemale.dmi','src/Icons/PlayerIcons/BaseIcons/ExGenesisHumans/NewBlackFemale.dmi')

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
