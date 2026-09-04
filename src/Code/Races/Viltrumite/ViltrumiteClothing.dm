obj/items/Clothes
	var/list/nexus_starter_races

	proc/canUseAsNexusStarter(race_name)
		if(islist(nexus_starter_races) && nexus_starter_races.len) return race_name in nexus_starter_races
		return !(race_name in list("Viltrumite", "Half-Viltrumite"))

	ViltrumiteSoldierRobe
		name = "Viltrumite Soldier Robe"
		icon = 'src/Icons/PlayerIcons/Clothes/Viltrumite/ViltrumiteSoldierRobe.dmi'
		nexus_starter_races = list("Viltrumite", "Half-Viltrumite")
		Click() usr.Clothes_Proc(src)

	ViltrumiteRoyalRobe
		name = "Viltrumite Royal Robe"
		icon = 'src/Icons/PlayerIcons/Clothes/Viltrumite/ViltrumiteRoyalRobe.dmi'
		nexus_starter_races = list("Viltrumite", "Half-Viltrumite")
		Click() usr.Clothes_Proc(src)

	ViltrumiteCape
		name = "Viltrumite Cape"
		icon = 'src/Icons/PlayerIcons/Clothes/Viltrumite/ViltrumiteCape.dmi'
		nexus_starter_races = list("Viltrumite", "Half-Viltrumite")
		Click() usr.Clothes_Proc(src)
