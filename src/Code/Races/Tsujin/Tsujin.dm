mob/proc/Tsujin(interactive_options=1)
	if(interactive_options) alert(src,"Tsujins share the same planet as the Saiyan, and are very similar to Humans, but better with \
	technology and a bit less at fighting.")
	Human()
	Race="Tsujin"
	bp_mod=Get_race_starting_bp_mod()
	gravity_mastered=10
	base_bp=10
	Knowledge=600
	knowledge_cap_rate*=1.3
	stun_resistance_mod=1.6
