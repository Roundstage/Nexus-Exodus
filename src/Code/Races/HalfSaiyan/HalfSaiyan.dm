mob/proc/Half_Saiyan()
	Race="Half Saiyan"
	incline_age-=1
	incline_mod=0.3
	Gravity_Mod=0.7
	sp_mod=1
	mastery_mod=2
	Knowledge=300
	//alert(src,"Half Saiyans are a mix between Humans and Saiyans")
	bp_mod=Get_race_starting_bp_mod()
	Decline=20
	Decline_Rate=1
	Intelligence=1
	knowledge_cap_rate=1
	Regenerate=0
	Lungs=0
	leech_rate=1
	med_mod=2
	zenkai_mod=2
	ssjat=rand(500000,700000)
	ssj2at=rand(72000000,102000000)
	ssj3at=rand(450000000,550000000)
	ssjdrain /= 10
	ssjmod*=4
	ssj2mod*=2
	ssj3mod*=1.5
	base_bp=5
	if(START_WITH_RACIAL_SKILLS)
		contents.Add(new/obj/Attacks/Masenko)
