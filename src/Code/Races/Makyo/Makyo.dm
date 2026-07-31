mob/proc/Makyo(interactive_options=1)
	Race="Makyo"
	incline_age=8
	incline_mod=0.6
	Gravity_Mod=1.5
	sp_mod=1.3
	mastery_mod=2.5
	if(interactive_options) alert(src,"Makyos start on Earth, the most unique thing about them is that the Makyo \
	star passes by, and gives them a big power boost and nearly unlimited energy.")
	bp_mod=Get_race_starting_bp_mod()
	Decline=30
	Decline_Rate=1
	Intelligence=0.5
	knowledge_cap_rate=1
	Regenerate=0
	Lungs=0
	leech_rate=2
	med_mod=1
	zenkai_mod=0.5
	gravity_mastered=3
	if(START_WITH_RACIAL_SKILLS)
		contents.Add(new/obj/Attacks/Sokidan,new/obj/Fly,new/obj/Attacks/Charge)
	base_bp=rand(120,150)
	ascension_bp*=0.9
