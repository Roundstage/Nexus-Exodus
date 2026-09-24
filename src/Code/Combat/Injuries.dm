mob/var/tmp/list/injury_list=new

mob/verb/Injure()
	set category = "Skills"
	var/mob/target = src
	for(var/mob/candidate in Get_step(src, dir)) if(candidate.client || candidate.empty_player) target = candidate
	Injury_Options(target)

proc/getInjureInjuryType(action)
	switch(action)
		if("Arm", "Delimb Arm") return /obj/Injuries/Arm
		if("Leg", "Delimb Leg") return /obj/Injuries/Leg
		if("Eye") return /obj/Injuries/Eye
		if("Internal") return /obj/Injuries/Internal
		if("Brain") return /obj/Injuries/Brain
		if("Dick") return /obj/Injuries/Dick
	return null

mob/proc/getInjureTargetError(mob/target, hostile = TRUE)
	if(!target) return "The target is no longer here."
	if(KO || rp_mode || (Frozen && !paralysis_immune)) return "You cannot act in your current condition."
	if(!isturf(loc) || !isturf(target.loc) || z != target.z || get_dist(src, target) > 1) return "You must remain beside the target."
	if(target != src && !target.KO) return "They must be knocked out."
	if(tournament_override(fighters_can = FALSE, show_message = FALSE)) return "You cannot do this near the tournament."
	if(hostile && target != src)
		if(alignment_on && both_good(src, target)) return "You cannot harm or steal from another good person."
		if(Same_league_cant_kill(src, target)) return "You cannot harm or steal from a fellow league member."
	return null

mob/proc/getInjureActionError(mob/target, action, permanent = FALSE)
	var/error = getInjureTargetError(target, hostile = action != "Mercy")
	if(error) return error
	var/injury_type = getInjureInjuryType(action)
	var/delimb = action == "Delimb Arm" || action == "Delimb Leg" || action == "Rip tail off"
	if(!injury_type && !delimb && !(action in list("Steal", "Humiliate", "Mercy", "Kill"))) return "Unknown Injure action."
	if(target == src && (action in list("Steal", "Humiliate", "Mercy", "Kill"))) return "Choose an enemy in front of you for this action."
	if((injury_type || delimb) && target.Race == "Majin") return "Majins are immune to physical injuries."
	if(action == "Rip tail off" && !target.Tail) return "They no longer have a tail."
	if(action == "Mercy") return null
	if(action == "Steal")
		if(Race == "Heran")
			if(target.willpower > 70) return "Herans can steal only when the target has 70 WP or less."
		else if(target.willpower >= 30) return "The target must have less than 30 WP to be robbed."
		return null
	if(action == "Kill")
		if(target.willpower != 0) return "Kill requires the target to have 0 WP."
		if(target.Dead) return "They are already dead."
		if(target.Safezone || target.Prisoner() || target.Clone_Tank() || target.BodySwapVictim()) return "They cannot be executed in their current protected state."
		return null
	var/wp_limit = (permanent || delimb) ? 50 : 60
	if(target.willpower >= wp_limit) return "[action] requires the target to have less than [wp_limit] WP."
	return null

mob/proc/getInjureOptions(mob/target)
	var/list/options = list("Cancel")
	if(!getInjureActionError(target, "Arm")) options += "Temporary injury (<60 WP)"
	if(!getInjureActionError(target, "Arm", TRUE)) options += "Permanent injury (<50 WP)"
	if(!getInjureActionError(target, "Delimb Arm")) options += "Delimb (<50 WP)"
	for(var/action in list("Steal", "Humiliate", "Mercy", "Kill"))
		if(!getInjureActionError(target, action)) options += action
	return options

mob/proc/Injury_Options(mob/target)
	if(!client) return
	var/list/options = getInjureOptions(target)
	if(options.len <= 1)
		src << "No Injure actions are available. Stay beside a knocked-out target: temporary injuries need <60 WP; permanent injuries and Delimb need <50 WP; Kill needs 0 WP; Steal needs [Race == "Heran" ? "70 WP or less" : "<30 WP"]."
		return
	var/action = input(src, "Choose an action on [target] ([round(target.willpower, 0.1)] WP). Injuries default to yourself if nobody is in front of you.", "Injure") as null|anything in options
	if(!action || action == "Cancel" || !(action in options)) return
	var/permanent = action == "Permanent injury (<50 WP)"
	if(action == "Temporary injury (<60 WP)" || permanent)
		action = input(src, "Which body part?", "Injure") as null|anything in list("Cancel", "Arm", "Leg", "Eye", "Internal", "Brain", "Dick")
	else if(action == "Delimb (<50 WP)")
		var/list/limbs = list("Cancel", "Delimb Arm", "Delimb Leg")
		if(target && target.Tail) limbs += "Rip tail off"
		action = input(src, "Which limb? This is a permanent injury, subject to normal injury healing.", "Delimb") as null|anything in limbs
	if(!action || action == "Cancel") return
	if(action == "Steal")
		promptInjureSteal(target)
		return
	if(action == "Kill")
		if(alert(src, "Attempt to kill [target]?", "Kill", "Cancel", "Kill") != "Kill") return
	applyInjureAction(target, action, permanent)

// Central RP outcome hook: alignment consequences will be added by the future alignment system.
mob/proc/recordInjureOutcome(mob/target, action, message)
	if(!target) return
	for(var/mob/viewer in player_view(15, src))
		viewer << message
		viewer.ChatLog(message, key)

mob/proc/applyInjureAction(mob/target, action, permanent = FALSE)
	var/error = getInjureActionError(target, action, permanent)
	if(error)
		src << error
		return FALSE
	var/injury_type = getInjureInjuryType(action)
	if(injury_type)
		var/delimb = action == "Delimb Arm" || action == "Delimb Leg"
		var/list/matching = list()
		for(var/obj/Injuries/existing in target.injury_list)
			if(existing.type == injury_type) matching += existing
		var/maximum = initial(injury_type:Max_Injuries)
		var/obj/Injuries/injury
		if(matching.len >= maximum)
			// Upgrading a temporary wound never creates a third arm, leg or eye injury.
			for(var/obj/Injuries/existing in matching)
				if((delimb && !existing.delimbed) || (permanent && existing.Wear_Off))
					injury = existing
					break
			if(!injury)
				src << "[target] already has the maximum number of these injuries."
				return FALSE
		else
			injury = new injury_type
			if(matching.len) injury.icon = injury.Alt_Icon
			injury.icon += target.Blood_Color()
			injury.loc = target
			target.injury_list |= injury
		injury.delimbed = delimb
		injury.Wear_Off = (permanent || delimb) ? 0 : Year + 0.5
		var/severity = (permanent || delimb) ? "permanent" : "temporary"
		recordInjureOutcome(target, action, delimb ? "[src] tears off one of [target]'s [action == "Delimb Arm" ? "arms" : "legs"]!" : "[src] inflicts a [severity] [injury] injury on [target].")
		target.Add_Injury_Overlays()
		target.Injury_removal_loop()
		target.Eye_Injury_Blindness()
		return TRUE
	switch(action)
		if("Rip tail off")
			recordInjureOutcome(target, action, "[src] rips [target]'s tail off!")
			target.Tail_Remove()
		if("Humiliate") recordInjureOutcome(target, action, "[src] humiliates the defeated [target].")
		if("Mercy") recordInjureOutcome(target, action, "[src] shows mercy to [target] and spares their life.")
		if("Kill")
			recordInjureOutcome(target, action, "[src] attempts to finish off [target]!")
			target.Death(src)
		else return FALSE
	return TRUE

// Legacy adapter; all mutations still pass through the post-prompt WP and proximity checks.
mob/proc/Inflict_Injury(mob/target, obj/Injuries/injury)
	if(!injury) return FALSE
	var/action
	for(var/candidate in list("Arm", "Leg", "Eye", "Internal", "Brain", "Dick"))
		if(getInjureInjuryType(candidate) == injury.type) action = candidate
	del(injury)
	if(!action || !client) return FALSE
	var/duration = input(src, "Temporary (<60 WP) or permanent (<50 WP) injury?", "Injure") as null|anything in list("Cancel", "Temporary", "Permanent")
	if(!duration || duration == "Cancel") return FALSE
	return applyInjureAction(target, action, duration == "Permanent")

mob/proc/Remove_Injury_Overlays() for(var/obj/Injuries/I in injury_list) overlays-=I.icon

mob/proc/Add_Injury_Overlays()
	Remove_Injury_Overlays()
	for(var/obj/Injuries/I in injury_list) overlays+=I.icon

mob/proc/Blood_Color()
	if(Race=="Alien") return rgb(105,165,0)
	if(Race=="Namekian") return rgb(150,0,115)
	if(Race=="Android") return rgb(0,0,150)
	if(Race=="Bio-Android") return rgb(0,0,150)
	if(Race=="Frost Lord") return rgb(150,0,115)
	if(Race=="Demon") return rgb(150,115,0)
	if(Race=="Makyo") return rgb(0,0,150)
	if(Race=="Majin") return rgb(150,0,75)
	return rgb(150,0,0)

obj/Injuries
	Del()
		var/mob/M=loc
		if(ismob(M))
			M.overlays-=icon
			M.injury_list-=src
			M.injury_list=remove_nulls(M.injury_list)
		. = ..()
	New()
		spawn(5) if(ismob(loc))
			var/mob/M=loc
			M.injury_list |= src
	Givable=0
	Makeable=0
	var/Wear_Off //If null, permanent injury. Otherwise it wears off when this year has been reached.
	var/Alt_Icon
	var/Max_Injuries=1
	var/delimbed = FALSE // Uses the existing limb penalties, appearance and regeneration/healing paths.
	Internal icon='src/Icons/PlayerIcons/Injuries/InternalInjury.dmi'
	Brain
	Dick icon='src/Icons/PlayerIcons/Injuries/GroinInjury.dmi'
	Eye
		icon='src/Icons/PlayerIcons/Injuries/EyeLInjury.dmi'
		Alt_Icon='src/Icons/PlayerIcons/Injuries/EyeRInjury.dmi'
		Max_Injuries=2
	Leg
		icon='src/Icons/PlayerIcons/Injuries/LegLInjury.dmi'
		Alt_Icon='src/Icons/PlayerIcons/Injuries/LegRInjury.dmi'
		Max_Injuries=2
	Arm
		icon='src/Icons/PlayerIcons/Injuries/ArmLInjury.dmi'
		Alt_Icon='src/Icons/PlayerIcons/Injuries/ArmRInjury.dmi'
		Max_Injuries=2
