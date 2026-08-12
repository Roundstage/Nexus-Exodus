mob/proc/Android(interactive_options=1)
	Race="Android"
	incline_age=0.1
	incline_mod=0.3
	if(interactive_options) alert(src,"Androids are highly customizable. You can use science to create 'modules' which you can install on an \
	Android to alter its abilities and stats. You can choose Androids during creation, or make a blank Android body \
	at any time using Science in-game, and mind transfer into it. There is no difference except that choosing during \
	creation means you will spawn on the 'Android Ship'.")
	Gravity_Mod=1.5
	sp_mod=1
	mastery_mod=5
	Android=1
	disableAnger()
	bp_mod=Get_race_starting_bp_mod()
	Decline=100
	Decline_Rate=10
	Intelligence=1
	knowledge_cap_rate=0.8
	Regenerate=0
	Lungs=1
	gravity_mastered=20
	leech_rate=0.5
	med_mod=4
	zenkai_mod=0
	base_bp=100
	Knowledge=600
	Zanzoken=100
	ascension_bp*=1.1
	stun_resistance_mod=0.9
