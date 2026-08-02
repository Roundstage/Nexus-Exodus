mob/proc/Kanassan(interactive_options = 1)
	Race = "Kanassan"
	Class = "Seer"
	incline_age = 12
	incline_mod = 0.3
	Gravity_Mod = 0.9
	sp_mod = 1.5
	mastery_mod = 2.5
	bp_mod = Get_race_starting_bp_mod()
	Decline = 55
	Decline_Rate = 0.8
	Intelligence = 0.9
	knowledge_cap_rate = 1.05
	Regenerate = 0.1
	Lungs = 0
	leech_rate = 2
	med_mod = 3
	zenkai_mod = 0.25
	gravity_mastered = 5
	precog = 1
	base_bp = rand(60, 100)
	ascension_bp *= 0.9
	stun_resistance_mod = 1.4
	if(interactive_options)
		alert(src, "Kanassans are psionic seers whose awareness, defense, and energy control reward prediction instead of brute force.")
	if(START_WITH_RACIAL_SKILLS)
		contents.Add(new /obj/Sense, new /obj/Advanced_Sense, new /obj/Telepathy, new /obj/Attacks/Blast, new /obj/Attacks/Charge)
