mob/proc/Doll(interactive_options=1)
	if(interactive_options) alert(src,"Spirit Dolls are puppets who were given souls, their stats are based off Humans, with \
	a few changes. They are the only race that can fly forever without energy drain.")
	Class = "Spirit Doll"
	Human()
	incline_age=10
	incline_mod=0.3
	Intelligence*=0.8
	med_mod*=4
	mastery_mod*=thirdEyeMasteryMult //same as third eye human since they dont get third eye
	Decline=35
	Decline_Rate=2
	if(START_WITH_RACIAL_SKILLS)
		if(!(locate(/obj/Fly) in src))
			contents+=new/obj/Fly
