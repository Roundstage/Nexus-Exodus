mob/proc/Icer(interactive_options=1,force_cooler=0)
	Race="Frost Lord"
	incline_age=10
	incline_mod=0.3
	Gravity_Mod=3
	sp_mod=1
	mastery_mod=3
	if(interactive_options) alert(src,"Frost Lords are a lizard-like race born on an icy planet furthest from all other races. They are \
	born with extreme power, and have the ability to shapeshift into new forms which increase their power even further.")
	bp_mod=Get_race_starting_bp_mod()
	Decline=50
	Decline_Rate=1
	Intelligence=0.3
	knowledge_cap_rate=2
	Regenerate=0
	Lungs=1
	leech_rate=1
	med_mod=1
	zenkai_mod=0.5
	gravity_mastered = 25
	if(START_WITH_RACIAL_SKILLS)
		contents.Add(new/obj/Attacks/Genki_Dama/Death_Ball,new/obj/Attacks/Explosion,new/obj/Attacks/Ray,\
		new/obj/Power_Control,new/obj/Attacks/Blast,new/obj/Attacks/Charge,new/obj/Fly,new/obj/Attacks/Beam)
	base_bp=300
	hbtc_bp=rand(900,1200)
	ascension_bp*=1.35
	stun_resistance_mod=0.9
	if(force_cooler)
		Cooler()
	else if(interactive_options && prob(1))
		switch(alert(src,"Do you want to be an Cooler Icer? This choice only appears in 1% \
		of Icers, making you very especial. You will be stronger than a normal Icer and have an additional transformation",\
		"options","No","Yes"))
			if("Yes") Cooler()
