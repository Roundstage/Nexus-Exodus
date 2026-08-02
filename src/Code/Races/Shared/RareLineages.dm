var/ancient_namekian_common_race = FALSE

mob/var/ancient_namekian_candidate = -1
mob/var/ancient_progenitor_candidate = -1

mob/proc/canSelectAncientNamekian()
	if(ancient_namekian_common_race) return TRUE
	if(ancient_namekian_candidate < 0)
		ancient_namekian_candidate = prob(5)
	if(!ancient_namekian_candidate) return FALSE
	var/namekian_count
	var/ancient_count
	for(var/mob/player in players)
		if(player.Race != "Namekian") continue
		namekian_count++
		if(player.Class == "Ancient") ancient_count++
	if(ancient_count && ancient_count / max(1, namekian_count) >= 0.1) return FALSE
	return TRUE

mob/proc/applyAncientNamekianLineage()
	if(Race != "Namekian") return FALSE
	Class = "Ancient"
	bp_mod = 1.85
	base_bp = max(base_bp, rand(105, 145))
	Intelligence = max(Intelligence, 0.8)
	med_mod = max(med_mod, 7)
	Regenerate += 0.35
	ascension_bp *= 1.08
	if(START_WITH_RACIAL_SKILLS)
		if(!(locate(/obj/Materialization) in src)) contents += new /obj/Materialization
		if(!(locate(/obj/Telepathy) in src)) contents += new /obj/Telepathy
		if(!(locate(/obj/Bind) in src)) contents += new /obj/Bind
	return TRUE

mob/proc/canSelectAncientProgenitor()
	if(ancient_progenitor_candidate < 0)
		ancient_progenitor_candidate = prob(5)
	if(!ancient_progenitor_candidate) return FALSE
	var/android_count
	var/progenitor_count
	for(var/mob/player in players)
		if(player.Race != "Android") continue
		android_count++
		if(player.Class == "Ancient Progenitor") progenitor_count++
	if(progenitor_count && progenitor_count / max(1, android_count) >= 0.1) return FALSE
	return TRUE

mob/proc/applyAncientProgenitorLineage()
	if(Race != "Android") return FALSE
	Class = "Ancient Progenitor"
	Knowledge = max(Knowledge, 900)
	Intelligence = max(Intelligence, 1.25)
	knowledge_cap_rate = max(knowledge_cap_rate, 1.05)
	mastery_mod = max(mastery_mod, 6)
	Gravity_Mod = max(Gravity_Mod, 1.8)
	ascension_bp *= 1.05
	if(START_WITH_RACIAL_SKILLS)
		if(!(locate(/obj/Sense) in src)) contents += new /obj/Sense
		if(!(locate(/obj/Advanced_Sense) in src)) contents += new /obj/Advanced_Sense
		if(!(locate(/obj/Observe) in src)) contents += new /obj/Observe
	return TRUE

mob/Admin4/verb/testRoleplayRacePort(mob/character in players)
	set name = "Test Roleplay Race Port"
	set category = "Admin"
	var/race_choice = input(src, "Apply which ported race template to [character]? This is intended for test characters.", "Race Port Test") in list("Cancel", "Kanassan", "Heran", "Makyo", "Ancient Namekian", "Ancient Progenitor")
	if(!race_choice || race_choice == "Cancel") return
	if(alert(src, "Replace [character]'s current racial template with [race_choice]?", "Race Port Test", "Yes", "No") != "Yes") return
	character.revert_all_buffs()
	switch(race_choice)
		if("Kanassan") character.Kanassan(FALSE)
		if("Heran") character.Heran(FALSE)
		if("Makyo") character.Makyo(FALSE)
		if("Ancient Namekian")
			character.Namekian(FALSE)
			character.applyAncientNamekianLineage()
		if("Ancient Progenitor")
			character.Android(FALSE)
			character.applyAncientProgenitorLineage()
	character.Racial_Stats(Start_Redo_Stats = 0, auto_allocate = 1)
	character.Race_Starting_Stats()
	character.FullHeal()
	src << "Applied [race_choice] to [character]."
