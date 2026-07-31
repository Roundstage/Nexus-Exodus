mob/proc/Demigod(interactive_options=1)
	Race="Demigod"
	incline_age=13
	incline_mod=0.3
	Gravity_Mod=1
	sp_mod=1
	mastery_mod=1
	if(interactive_options) alert(src,"Demigods are a race with very high potential for power, but who take a very long time to reach \
	that potential. In other words, they have high BP gain, but leech BP very slow, and master skills slow.")
	bp_mod=Get_race_starting_bp_mod()
	Decline=30
	Decline_Rate=2
	Intelligence=0.6
	Regenerate=0
	Lungs=0
	leech_rate=1
	med_mod=1
	zenkai_mod=1
	base_bp=200
	hbtc_bp=rand(700,900)
	if(START_WITH_RACIAL_SKILLS)
		contents.Add(new/obj/Meditate_Level_2,new/obj/Heal,new/obj/Shadow_Spar,new/obj/Zanzoken)
	ascension_bp*=0.8
