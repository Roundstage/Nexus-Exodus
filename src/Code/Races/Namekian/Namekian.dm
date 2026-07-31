mob/proc/Namekian(interactive_options=1)
	Race="Namekian"
	incline_age=5
	incline_mod=0.25
	arm_stretch=1
	arm_stretch_range=500
	Gravity_Mod=0.7
	sp_mod=1.3
	mastery_mod=2
	if(interactive_options) alert(src,"Namekians are a mostly peaceful race but also strong warriors with very unique racial \
	abilities such as making Wish Orbs, fusing with other Namekians, having another Namekian as their \
	'counterpart' for shared power, stretching their arms out really \
	far, and unique racial stats that can be seen in the Race Guide in the Other tab. Namekians are \
	probably one of the most unique races.")
	bp_mod=Get_race_starting_bp_mod()
	Decline=80
	Decline_Rate=0.65
	Intelligence=0.6
	knowledge_cap_rate=1
	Lungs=0
	gravity_mastered=4
	leech_rate=2
	med_mod=6 //we hardcoded this to be nerfed. check at the end of new/load for the real Namekian mod
	zenkai_mod=0.25
	Regenerate=0.3
	if(START_WITH_RACIAL_SKILLS)
		contents.Add(new/obj/SplitForm,new/obj/Meditate_Level_2,new/obj/Attacks/Blast,new/obj/Attacks/Charge,\
		new/obj/Attacks/Beam,new/obj/Fly,new/obj/Regeneration,new/obj/Zanzoken,new/obj/Power_Control,\
		new/obj/Attacks/Piercer)
	base_bp=rand(80,120)
	ascension_bp*=0.7
	stun_resistance_mod=2
