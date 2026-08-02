mob/proc/Heran(interactive_options = 1)
	Race = "Heran"
	Class = "Space Pirate"
	incline_age = 10
	incline_mod = 0.35
	Gravity_Mod = 1.2
	sp_mod = 1.2
	mastery_mod = 1.7
	bp_mod = Get_race_starting_bp_mod()
	Decline = 45
	Decline_Rate = 1
	Intelligence = 0.6
	knowledge_cap_rate = 0.9
	Regenerate = 0.1
	Lungs = 0
	leech_rate = 2.5
	med_mod = 1.4
	zenkai_mod = 1
	gravity_mastered = 12
	base_bp = rand(90, 130)
	ascension_bp *= 0.95
	stun_resistance_mod = 1.8
	if(interactive_options)
		alert(src, "Herans are durable space pirates who favor strength, pressure, and combat growth over technical or mystical development.")
	if(START_WITH_RACIAL_SKILLS)
		contents.Add(new /obj/Attacks/Blast, new /obj/Attacks/Charge, new /obj/Fly, new /obj/Dash_Attack)
