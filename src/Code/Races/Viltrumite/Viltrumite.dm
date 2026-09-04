var
	viltrumite_combat_bp_mult = 0.7
	half_viltrumite_combat_bp_mult = 0.75
	grand_regent_combat_bp_mult = 1.375
	grand_regent_damage_taken_mult = 0.9
	viltrumite_royal_creation_chance = 5
	viltrumite_royal_online_limit = 3
	viltrumite_scourge_resistance_chance = 5
	viltrumite_grand_regent_account
	viltrumite_grand_regent_slot
	viltrumite_grand_regent_created_at

mob/var
	viltrumite_royal_candidate = -1
	viltrumite_lineage
	scourge_genetics_rolled
	scourge_resistance

mob/proc/isViltrumiteRace()
	return Race in list("Viltrumite", "Half-Viltrumite")

mob/proc/isViltrumiteRoyalLineage()
	return viltrumite_lineage in list("royal", "royal_hybrid", "grand_regent")

mob/proc/Viltrumite()
	Race = "Viltrumite"
	Class = "Viltrumite"
	viltrumite_lineage = "standard"
	incline_age = 12
	incline_mod = 0.25
	Gravity_Mod = 2
	sp_mod = 1
	mastery_mod = 1
	bp_mod = Get_race_starting_bp_mod()
	old_age_on = FALSE
	Intelligence = 1
	knowledge_cap_rate = 1
	Regenerate = 0
	Lungs = 1
	leech_rate = 1
	med_mod = 1
	zenkai_mod = 0
	gravity_mastered = 20
	base_bp = rand(400, 900)
	stun_resistance_mod = 1.15
	if(START_WITH_RACIAL_SKILLS)
		contents.Add(new/obj/Power_Control, new/obj/Fly, new/obj/Attacks/Blast, new/obj/Attacks/Charge)

mob/proc/Half_Viltrumite()
	Viltrumite()
	Race = "Half-Viltrumite"
	Class = "Half-Viltrumite"
	viltrumite_lineage = "hybrid"
	Intelligence = 1
	mastery_mod = 2
	Gravity_Mod = 1.5
	base_bp = rand(100, 400)

mob/proc/applyViltrumiteRoyalLineage(hybrid = FALSE)
	if(!isViltrumiteRace()) return FALSE
	Class = hybrid ? "Royal Hybrid" : "Royal Blood"
	viltrumite_lineage = hybrid ? "royal_hybrid" : "royal"
	scourge_genetics_rolled = TRUE
	scourge_resistance = TRUE
	return TRUE

mob/proc/applyGrandRegentLineage()
	if(Race != "Viltrumite") return FALSE
	Class = "Grand Regent"
	viltrumite_lineage = "grand_regent"
	scourge_genetics_rolled = TRUE
	scourge_resistance = TRUE
	normalizeCharacterMutations()
	disableAnger()
	return TRUE

mob/proc/canSelectViltrumiteRoyal()
	if(viltrumite_royal_candidate < 0) viltrumite_royal_candidate = prob(viltrumite_royal_creation_chance)
	if(!viltrumite_royal_candidate) return FALSE
	var/royal_count
	for(var/mob/player in players)
		if(player.Race == "Viltrumite" && player.Class == "Royal Blood") royal_count++
	return royal_count < viltrumite_royal_online_limit

mob/proc/canSelectGrandRegent()
	return !viltrumite_grand_regent_account

mob/proc/registerGrandRegentIdentity()
	if(Race != "Viltrumite" || Class != "Grand Regent" || !key || !character_made_time) return FALSE
	if(viltrumite_grand_regent_account) return isDesignatedGrandRegent()
	viltrumite_grand_regent_account = ckey(key)
	viltrumite_grand_regent_slot = clampNexusCharacterSlot(active_character_slot)
	viltrumite_grand_regent_created_at = character_made_time
	saveMisc()
	return TRUE

mob/proc/getWaitingHalfViltrumiteClass()
	for(var/mob/parent in players)
		for(var/obj/Mate/birth in parent)
			if(birth.Waiting && birth.Race == "Half-Viltrumite") return birth.Class || "Half-Viltrumite"
	return null

mob/proc/canCreateHalfViltrumite()
	return !!getWaitingHalfViltrumiteClass()

mob/proc/rollViltrumiteScourgeGenetics(forced_result = -1)
	if(!isViltrumiteRace()) return FALSE
	if(isViltrumiteRoyalLineage())
		scourge_genetics_rolled = TRUE
		scourge_resistance = TRUE
		return TRUE
	if(scourge_genetics_rolled) return !!scourge_resistance
	scourge_genetics_rolled = TRUE
	scourge_resistance = forced_result >= 0 ? !!forced_result : prob(viltrumite_scourge_resistance_chance)
	return !!scourge_resistance

mob/proc/isScourgeImmune()
	return isViltrumiteRoyalLineage() || !!scourge_resistance

mob/proc/isDesignatedGrandRegent()
	if(!key || !character_made_time) return FALSE
	return ckey(key) == viltrumite_grand_regent_account && clampNexusCharacterSlot(active_character_slot) == viltrumite_grand_regent_slot && character_made_time == viltrumite_grand_regent_created_at

mob/proc/normalizeViltrumiteLineage()
	if(!isViltrumiteRace()) return
	if(!viltrumite_lineage)
		switch(Class)
			if("Royal Blood") viltrumite_lineage = "royal"
			if("Royal Hybrid") viltrumite_lineage = "royal_hybrid"
			if("Grand Regent") viltrumite_lineage = "grand_regent"
			else viltrumite_lineage = Race == "Half-Viltrumite" ? "hybrid" : "standard"
	if(Race != "Viltrumite")
		if(viltrumite_lineage == "grand_regent")
			viltrumite_lineage = "hybrid"
			Class = "Half-Viltrumite"
		return
	if(isDesignatedGrandRegent())
		applyGrandRegentLineage()
	else if(Class == "Grand Regent")
		Class = "Viltrumite"
		viltrumite_lineage = "standard"
	if(isViltrumiteRoyalLineage())
		scourge_genetics_rolled = TRUE
		scourge_resistance = TRUE

mob/proc/getViltrumiteCreationStatCap(stat_name)
	var/is_royal = viltrumite_lineage in list("royal", "royal_hybrid")
	var/is_half = Race == "Half-Viltrumite"
	switch(stat_name)
		if("Energy") return is_royal ? 2.7 : (is_half ? 2.4 : 1.8)
		if("Strength", "Endurance", "Speed", "Force", "Resistance", "Offense", "Defense") return is_royal ? 2.7 : (is_half ? 2.3 : 1.8)
		if("Regeneration") return is_royal ? 4 : 3.6
		if("Recovery") return is_royal ? 2.4 : 2
		if("Anger") return is_half ? 220 : 140
	return 9999

mob/Admin4/verb/setGrandRegent(mob/character in players)
	set name = "Set Grand Regent"
	set category = "Admin"
	if(!character || character.Race != "Viltrumite" || !character.character_made_time)
		src << "Choose a completed Viltrumite character."
		return
	if(alert(src, "Transfer the permanent Grand Regent office to [character]?", "Grand Regent Succession", "Yes", "No") != "Yes") return
	for(var/mob/player in players)
		if(player != character && player.Class == "Grand Regent")
			player.Class = "Viltrumite"
			player.viltrumite_lineage = "standard"
			spawn() player.save()
	viltrumite_grand_regent_account = ckey(character.key)
	viltrumite_grand_regent_slot = clampNexusCharacterSlot(character.active_character_slot)
	viltrumite_grand_regent_created_at = character.character_made_time
	character.applyGrandRegentLineage()
	saveMisc()
	spawn() character.save()
	Log(src, "[key] transferred the Grand Regent office to [character] ([character.key], slot [character.active_character_slot]).")
	player_view(15, character) << "<font color=#d6b36a>[character] has been recognized as the Grand Regent of Viltrum."
