// Four Horsemen bonuses from the original rank skills, in a separate Mystic-style slot.
// These are skills, never editable /obj/Buff instances or Combat-tree capstones.
mob/var/active_demon_buff
mob/var/tmp/demon_buff_drain_running = FALSE

proc/getDemonRankBuffType(rank_name)
	switch(rank_name)
		if("Famine") return /obj/DemonBuff/Famine
		if("War") return /obj/DemonBuff/War
		if("Pestilence") return /obj/DemonBuff/Pestilence
		if("Death") return /obj/DemonBuff/Death
	return null

obj/DemonBuff
	Skill = TRUE
	teachable = TRUE
	Teach_Timer = 9
	student_point_cost = 100
	hotbar_type = "Buff"
	can_hotbar = TRUE
	clonable = FALSE
	var
		bp_bonus = 0.4
		strength_mult = 1
		force_mult = 1
		offense_mult = 1
		endurance_mult = 1
		defense_mult = 1
		regeneration_mult = 1
		recovery_mult = 1
		aura_color = "#a080bf"

	verb/Hotbar_use()
		set waitfor = FALSE
		set hidden = TRUE
		usr.toggleDemonBuff(src)

	Del()
		var/mob/owner = loc
		if(ismob(owner) && owner.active_demon_buff == type) owner.revertDemonBuff()
		. = ..()

	Famine
		name = "Famine"
		desc = "Aura of Famine: +40% BP, x1.3 Regeneration and x1.4 Recovery. Drains 0.5% of maximum Energy per second. Shares a slot with War, Pestilence, Death, Mystic and Majin; compatible with custom buffs. Can be taught."
		regeneration_mult = 1.3
		recovery_mult = 1.4
		aura_color = "#9670bb"
		verb/famine()
			set name = "Famine"
			set category = "Skills"
			usr.toggleDemonBuff(src)

	War
		name = "War"
		desc = "Aura of War: +40% BP, x1.3 Strength and Force, and x1.25 Offense. Drains 0.5% of maximum Energy per second. Shares a slot with Famine, Pestilence, Death, Mystic and Majin; compatible with custom buffs. Can be taught."
		strength_mult = 1.3
		force_mult = 1.3
		offense_mult = 1.25
		aura_color = "#dc4c4c"
		verb/war()
			set name = "War"
			set category = "Skills"
			usr.toggleDemonBuff(src)

	Pestilence
		name = "Pestilence"
		desc = "Aura of Pestilence: +40% BP, x1.4 Endurance and Defense. Drains 0.5% of maximum Energy per second. Shares a slot with Famine, War, Death, Mystic and Majin; compatible with custom buffs. Can be taught."
		endurance_mult = 1.4
		defense_mult = 1.4
		aura_color = "#83b85b"
		verb/pestilence()
			set name = "Pestilence"
			set category = "Skills"
			usr.toggleDemonBuff(src)

	Death
		name = "Death"
		desc = "Aura of Death: +70% BP. Drains 0.5% of maximum Energy per second. Shares a slot with Famine, War, Pestilence, Mystic and Majin; compatible with custom buffs. Can be taught."
		bp_bonus = 0.7
		aura_color = "#dad9cf"
		verb/death()
			set name = "Death"
			set category = "Skills"
			usr.toggleDemonBuff(src)

mob/proc/canActivateDemonBuff(obj/DemonBuff/skill)
	if(!skill || skill.loc != src || !getDemonRankBuffType(initial(skill.name))) return FALSE
	return !Redoing_Stats && !KO && !ismystic && !ismajin && !active_demon_buff && Ki > 0

mob/proc/toggleDemonBuff(obj/DemonBuff/skill)
	if(!skill || skill.loc != src) return FALSE
	if(active_demon_buff == skill.type)
		revertDemonBuff()
		return TRUE
	if(!canActivateDemonBuff(skill))
		src << "Deactivate your current demon aura, Mystic or Majin first. You must be conscious, have Energy and finish choosing your stats."
		return FALSE
	active_demon_buff = skill.type
	applyDemonBuffStats(active_demon_buff, TRUE)
	runDemonBuffDrain()
	if(client) showNexusTechniqueAnnouncement(skill.name, skill.aura_color, null, 30)
	src << "You are now using the [skill.name] buff."
	return TRUE

// Use type defaults for both directions, so teaching and saved object edits cannot alter balance.
mob/proc/applyDemonBuffStats(buff_type, activating)
	if(!ispath(buff_type, /obj/DemonBuff)) return
	var/direction = activating ? 1 : -1
	bp_mult += initial(buff_type:bp_bonus) * direction
	Str *= initial(buff_type:strength_mult) ** direction
	strmod *= initial(buff_type:strength_mult) ** direction
	Pow *= initial(buff_type:force_mult) ** direction
	formod *= initial(buff_type:force_mult) ** direction
	Off *= initial(buff_type:offense_mult) ** direction
	offmod *= initial(buff_type:offense_mult) ** direction
	End *= initial(buff_type:endurance_mult) ** direction
	endmod *= initial(buff_type:endurance_mult) ** direction
	Def *= initial(buff_type:defense_mult) ** direction
	defmod *= initial(buff_type:defense_mult) ** direction
	regen *= initial(buff_type:regeneration_mult) ** direction
	recov *= initial(buff_type:recovery_mult) ** direction

mob/proc/revertDemonBuff()
	if(!active_demon_buff) return
	var/buff_type = active_demon_buff
	active_demon_buff = null
	applyDemonBuffStats(buff_type, FALSE)
	src << "You have stopped using your demon aura."

mob/proc/drainDemonBuff()
	if(!active_demon_buff) return
	if(!(locate(active_demon_buff) in src) || ismystic || ismajin)
		revertDemonBuff()
		return
	Ki = max(0, Ki - max_ki * 0.005)
	if(Ki <= 0) revertDemonBuff()

mob/proc/runDemonBuffDrain()
	set waitfor = FALSE
	if(demon_buff_drain_running) return
	demon_buff_drain_running = TRUE
	while(active_demon_buff)
		sleep(10)
		if(!src) return
		drainDemonBuff()
	demon_buff_drain_running = FALSE

mob/proc/normalizeDemonBuff()
	if(!active_demon_buff) return
	// Saved stats already contain the multipliers; never reapply them at login.
	if(!ispath(active_demon_buff, /obj/DemonBuff))
		active_demon_buff = null
		return
	if(!(locate(active_demon_buff) in src) || ismystic || ismajin)
		revertDemonBuff()
		return
	runDemonBuffDrain()
