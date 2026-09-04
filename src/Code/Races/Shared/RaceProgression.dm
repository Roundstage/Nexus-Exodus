mob/proc/NewZenkaiMods()
	zenkai_mod = GetNewZenkaiMod()

mob/proc/GetNewZenkaiMod()
	switch(Race)
		if("Half Saiyan") return 1
		if("Saiyan") return 1
		if("Viltrumite", "Half-Viltrumite") return 0
		if("Human") return 0
		if("Tsujin") return 0
		if("Majin") return 0
		if("Bio-Android") return 1
		if("Makyo") return 0
		if("Kanassan") return 0
		if("Heran") return 1
		if("Namekian") return 0
		if("Frost Lord") return 0
		if("Kai") return 0
		if("Demigod") return 0
		if("Demon") return 0.5
		if("Android") return 0
		if("Alien")
			if(alien_zenkai) return 1
			return 0
	return 0

var/human_bp_mod = 1.33

mob/proc/Get_race_starting_bp_mod()
	if(Class == "Spirit Doll") return human_bp_mod * 0.9
	switch(Race)
		if("Yeet") return 1
		if("Half Saiyan") return 2.5
		if("Saiyan") return 2
		if("Viltrumite") return 2.4
		if("Half-Viltrumite") return 2.2
		if("Human") return human_bp_mod
		if("Tsujin") return 1.28
		if("Majin") return new_majin_bp_mod
		if("Bio-Android") return 2.1
		if("Makyo") return 1.85
		if("Kanassan") return 1.75
		if("Heran") return 2.05
		if("Namekian") return 1.65
		if("Frost Lord") return 2.1
		if("Kai") return 1.8
		if("Demigod") return 2.5
		if("Demon") return 1.85
		if("Android") return 1
		if("Alien") return 1.55
	return 1.5

//set these in the actual race proc eventually
var/majin_new_regen=1.5
var/new_majin_bp_mod=2.55
var/cur_majin_stat_version = 2

var/cur_stat_ver = 1005 //move this to 1003 next time because 1002 is taken, we rolled this back

var/next_lssj=0

mob/proc/ApplyStartingBP()
	if(base_bp < Start_BP * bp_mod) base_bp = Start_BP * bp_mod
