mob/proc/Alien(interactive_options=1)
	Race="Alien"
	base_bp = rand(1800,2200)
	incline_age=11
	incline_mod=0.2
	if(interactive_options) alert(src,"Alien is any other unknown race in the universe. They are more customizable than other races")
	Gravity_Mod=1
	sp_mod=1.3
	mastery_mod=2
	Knowledge=600
	knowledge_cap_rate=1.5
	bp_mod=Get_race_starting_bp_mod()
	Decline=60
	Decline_Rate=0.5
	Intelligence=0.6
	Regenerate=0
	Lungs=0
	leech_rate=1.2
	med_mod=1
	zenkai_mod=1
	if(START_WITH_RACIAL_SKILLS)
		contents.Add(new/obj/Fly,new/obj/Attacks/Charge,new/obj/Attacks/Beam)
	ascension_bp*=1
