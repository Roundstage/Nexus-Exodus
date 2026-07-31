mob/proc/Demon(interactive_options=1)
	Race="Demon"
	incline_age=12
	incline_mod=0.4
	if(interactive_options) alert(src,"Demons are born in hell and are the enemy of the Kais. Demons can live forever as long \
	as they periodicly visit hell, which will replenish their youth. High demon ranks are given the \
	Soul Contract ability, which can take the souls of other players and have much control over them.")
	Zombie_Immune=1
	Gravity_Mod=1.2
	sp_mod=1
	mastery_mod=2
	Demonic=1
	bp_mod=Get_race_starting_bp_mod()
	Decline=30
	Decline_Rate=10 //It's 10 because they decline fast if they leave hell, hell keeps them young
	Intelligence=0.6
	Regenerate=0
	Lungs=0
	leech_rate=1
	med_mod=3
	zenkai_mod=0.5
	if(START_WITH_RACIAL_SKILLS)
		contents.Add(new/obj/Attacks/Genki_Dama/Death_Ball,new/obj/Attacks/Charge,\
		new/obj/Attacks/Beam,new/obj/Fly,new/obj/Absorb)
	base_bp=2000
	hbtc_bp=rand(0,300)
	ascension_bp*=0.9
	stun_resistance_mod=1.2
