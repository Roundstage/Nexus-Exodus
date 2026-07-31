mob/proc/Bio(interactive_options=1)
	Race="Bio-Android"
	incline_age=3
	incline_mod=1
	if(interactive_options) alert(src,"Bio Androids are organic androids which are designed to be superior to normal organic life, whether \
	this is true is debatable. They can absorb mechanical androids to reach new forms which boost their power \
	immensely.")
	Gravity_Mod=1
	sp_mod=1
	mastery_mod=2
	bp_mod=Get_race_starting_bp_mod()
	Decline=20
	Decline_Rate=2
	Intelligence=1
	knowledge_cap_rate=1.3
	Regenerate=1.5
	Lungs=1
	leech_rate=1
	med_mod=1
	zenkai_mod=2
	gravity_mastered=25
	arm_stretch=1
	arm_stretch_icon='GenericArm.dmi'
	arm_stretch_range=500
	if(START_WITH_RACIAL_SKILLS)
		contents.Add(new/obj/Attacks/Genki_Dama/Death_Ball,new/obj/Attacks/Blast,new/obj/Attacks/Charge,\
		new/obj/Attacks/Beam,new/obj/Fly,new/obj/Absorb)
	base_bp=500
	hbtc_bp=rand(1500,1900)
	if(base_bp < highest_relative_base_bp * bp_mod * 0.4) base_bp = highest_relative_base_bp * bp_mod * 0.4
	Knowledge=600
	ascension_bp *= 1.3
	stun_resistance_mod=2
