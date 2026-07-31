mob/proc/Majin(interactive_options=1)
	Race="Majin"
	incline_age=0.1
	incline_mod=0.3
	if(interactive_options) alert(src,"Majins are very hard to kill because they are made out of a gooey substance and will regenerate unless \
	every bit of them is destroyed. They are extremely fast healers. \
	The original Majin Buu was created hundreds of years ago, and was eventually destroyed thanks to some of \
	Earth's greatest heroes. But unknown to them, microscopic particles of the Majin still \
	survived. The particles were badly damaged and mutated, but they were slowly regenerating. \
	The original Majin Buu could not be reformed, instead, decades later each colony of particles regenerated \
	into a seperate, weaker, and mutated version of the original. Although weaker, they were still some of the \
	strongest creatures in existance, and very evil. They would wreak havoc far and wide, and would cause more \
	destruction in numbers than the original ever did.")
	arm_stretch=1
	arm_stretch_icon='GenericArm.dmi'
	arm_stretch_range=150
	Gravity_Mod=1
	sp_mod=3
	mastery_mod=5
	Demonic=1
	bp_mod=Get_race_starting_bp_mod()
	Decline=20
	Decline_Rate=5
	Intelligence=0.3
	knowledge_cap_rate=1
	Regenerate=1.5
	Lungs=1
	leech_rate=3
	med_mod=1
	zenkai_mod=1
	if(START_WITH_RACIAL_SKILLS)
		contents.Add(new/obj/Attacks/Genki_Dama/Death_Ball,new/obj/Attacks/Spin_Blast,new/obj/Attacks/Blast,new/obj/Attacks/Charge,\
	new/obj/Attacks/Beam,new/obj/Fly,new/obj/Absorb,new/obj/Shadow_Spar)
	base_bp=1500
	gravity_mastered=20
	ascension_bp*=1
