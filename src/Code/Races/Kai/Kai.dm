mob/proc/Kai(interactive_options=1)
	Race="Kai"
	incline_age=16
	incline_mod=0.15
	Zombie_Immune=1
	Gravity_Mod=1
	gravity_mastered=25
	sp_mod=2
	if(interactive_options) alert(src,"Kais are guardians of the afterlife and living world. They are the natural enemy of Demons, they \
	may have come from a common ancestor, but Kais evolved in the positive energy of Heaven, and Demons in the \
	negative energy of hell.")
	mastery_mod=1.6
	bp_mod=Get_race_starting_bp_mod()
	Decline=100
	Decline_Rate=0.5
	Intelligence=0.6
	Regenerate=0
	Lungs=0
	leech_rate=2
	med_mod=4
	zenkai_mod=0.25
	if(START_WITH_RACIAL_SKILLS)
		contents.Add(new/obj/Attacks/Sokidan,new/obj/Reincarnation,new/obj/Attacks/Charge,new/obj/Attacks/Beam,\
		new/obj/Fly,new/obj/Power_Control,new/obj/Observe,new/obj/Telepathy)
	base_bp=2000
	hbtc_bp=rand(1300,1900)
	ascension_bp*=1
