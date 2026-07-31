#define TRANSFORMATION_STATE_VERSION 1

datum/TransformationDefinition
	var/id
	var/display_name
	var/family
	var/stage

	New(new_id, new_display_name, new_family, new_stage)
		id = new_id
		display_name = new_display_name
		family = new_family
		stage = new_stage

var/list/nexus_transformation_registry

proc/initializeNexusTransformationRegistry()
	if(nexus_transformation_registry) return
	nexus_transformation_registry = list()
	var/list/definitions = list(
		list("saiyan_ssj1", "Super Saiyan", "saiyan", 1),
		list("saiyan_ssj2", "Super Saiyan 2", "saiyan", 2),
		list("saiyan_ssj3", "Super Saiyan 3", "saiyan", 3),
		list("saiyan_ssj4", "Super Saiyan 4", "saiyan", 4),
		list("saiyan_god", "Super Saiyan God", "saiyan_divine", 1),
		list("saiyan_blue", "Super Saiyan Blue", "saiyan_divine", 2),
		list("frost_second", "Frost Lord Second Form", "frost", 1),
		list("frost_third", "Frost Lord Third Form", "frost", 2),
		list("frost_final", "Frost Lord Final Form", "frost", 3),
		list("frost_fifth", "Cooler Fifth Form", "frost", 4),
		list("frost_gold", "Golden Frost Lord", "frost", 5),
		list("giant", "Giant Form", "giant", 1),
		list("great_ape", "Great Ape", "oozaru", 1),
		list("alien_transform", "Alien Transformation", "alien", 1),
		list("ultra_instinct", "Ultra Instinct", "ultra_instinct", 1)
	)
	for(var/list/definition_data in definitions)
		var/datum/TransformationDefinition/definition = new(definition_data[1], definition_data[2], definition_data[3], definition_data[4])
		nexus_transformation_registry[definition.id] = definition

mob/var
	active_primary_transformation
	transformation_state_version

mob/proc/detectPrimaryTransformation()
	if(ultra_instinct) return "ultra_instinct"
	if(is_ssj_blue) return "saiyan_blue"
	if(is_ssg) return "saiyan_god"
	if(is_gold_form) return "frost_gold"
	if(IsGreatApe()) return "great_ape"
	if(using_giant_form) return "giant"
	if(ssj) return "saiyan_ssj[ssj]"
	if(Race == "Frost Lord" && Form)
		switch(Form)
			if(1) return "frost_second"
			if(2) return "frost_third"
			if(3) return "frost_final"
			if(4) return "frost_fifth"
	if(current_buff && current_buff.suffix && ("transformation" in current_buff.buff_attributes)) return "alien_transform"
	return null

mob/proc/countPrimaryTransformations()
	var/count
	if(ultra_instinct) count++
	if(is_ssj_blue) count++
	if(is_ssg) count++
	if(is_gold_form) count++
	if(IsGreatApe()) count++
	if(using_giant_form) count++
	if(ssj) count++
	if(Race == "Frost Lord" && Form && !is_gold_form) count++
	if(current_buff && current_buff.suffix && ("transformation" in current_buff.buff_attributes)) count++
	return count

mob/proc/syncActivePrimaryTransformation(reason = "state change")
	active_primary_transformation = detectPrimaryTransformation()
	transformation_state_version = TRANSFORMATION_STATE_VERSION
	rebuildPlayerAppearance("transformation [reason]")

mob/proc/revertPrimaryTransformations(reason = "manual")
	if(ultra_instinct) clearUltraInstinctState()
	if(is_ssj_blue) SSj_Blue_Revert()
	if(is_ssg) SSG_Revert()
	if(is_gold_form) GoldFormRevert()
	if(IsGreatApe()) Great_Ape_revert()
	if(using_giant_form) Disable_giant_form()
	if(current_buff && current_buff.suffix && ("transformation" in current_buff.buff_attributes)) Buff_Disable(current_buff)
	if(Race == "Frost Lord") while(Form) icer_Revert()
	if(ssj) Revert()
	active_primary_transformation = null
	transformation_state_version = TRANSFORMATION_STATE_VERSION
	rebuildPlayerAppearance("primary revert [reason]")

mob/proc/preparePrimaryTransformation(transformation_id)
	var/current_id = detectPrimaryTransformation()
	if(current_id && current_id != transformation_id) revertPrimaryTransformations("switch to [transformation_id]")
	active_primary_transformation = transformation_id
	transformation_state_version = TRANSFORMATION_STATE_VERSION
	return TRUE

mob/proc/canRequestPrimaryTransformation(transformation_id)
	switch(transformation_id)
		if("base") return TRUE
		if("saiyan_ssj1") return Race in list("Saiyan", "Half Saiyan") && SSjAble && SSjAble <= Year && has_ssj_req()
		if("saiyan_ssj2") return Race in list("Saiyan", "Half Saiyan") && Class != "Legendary Saiyan" && SSj2Able && SSj2Able <= Year && has_ssj2_req()
		if("saiyan_ssj3") return Race in list("Saiyan", "Half Saiyan") && SSj3Able && SSj3Able <= Year && has_ssj3_req()
		if("saiyan_ssj4") return Race == "Saiyan" && SSj4Able && SSj4Able <= Year
		if("saiyan_god") return Race in list("Saiyan", "Half Saiyan") && has_ssg_req()
		if("saiyan_blue") return Has_SSB_Req() && has_god_ki && god_mode_on
		if("frost_second", "frost_third", "frost_final") return Race == "Frost Lord"
		if("frost_fifth") return Race == "Frost Lord" && IsCooler
		if("frost_gold") return Race == "Frost Lord" && HasGoldFormReq()
		if("giant") return !!(locate(/obj/Giant_Form) in src)
	return FALSE

mob/proc/requestPrimaryTransformation(transformation_id)
	if(KO || transing || Redoing_Stats) return FALSE
	if(!canRequestPrimaryTransformation(transformation_id))
		src << "You do not meet the requirements for that transformation."
		return FALSE
	if(transformation_id == "base")
		revertPrimaryTransformations("requested base")
		return TRUE
	if(detectPrimaryTransformation() == transformation_id) return TRUE
	revertPrimaryTransformations("direct transition")
	switch(transformation_id)
		if("saiyan_ssj1") SSj()
		if("saiyan_ssj2")
			SSj()
			SSj2()
		if("saiyan_ssj3")
			SSj()
			SSj2()
			SSj3()
		if("saiyan_ssj4") SSj4()
		if("saiyan_god") SSG()
		if("saiyan_blue") SSj_Blue()
		if("frost_second") Frost_Lord_Forms()
		if("frost_third")
			Frost_Lord_Forms()
			Frost_Lord_Forms()
		if("frost_final")
			for(var/stage in 1 to 3) Frost_Lord_Forms()
		if("frost_fifth")
			for(var/stage in 1 to 4) Frost_Lord_Forms()
		if("frost_gold")
			var/target_stage = IsCooler ? 4 : 3
			for(var/stage in 1 to target_stage) Frost_Lord_Forms()
			PowerUpToGoldForm()
		if("giant") Enable_giant_form(locate(/obj/Giant_Form) in src)
	syncActivePrimaryTransformation("direct request")
	return detectPrimaryTransformation() == transformation_id

mob/proc/availablePrimaryTransformations()
	initializeNexusTransformationRegistry()
	var/list/result = list("Base / Revert" = "base")
	for(var/transformation_id in nexus_transformation_registry)
		if(!canRequestPrimaryTransformation(transformation_id)) continue
		var/datum/TransformationDefinition/definition = nexus_transformation_registry[transformation_id]
		result[definition.display_name] = transformation_id
	return result

mob/proc/normalizePrimaryTransformation()
	var/detected_id = detectPrimaryTransformation()
	if(countPrimaryTransformations() > 1)
		var/restore_id = detected_id
		revertPrimaryTransformations("login conflict cleanup")
		if(restore_id && canRequestPrimaryTransformation(restore_id)) requestPrimaryTransformation(restore_id)
	else
		active_primary_transformation = detected_id
		transformation_state_version = TRANSFORMATION_STATE_VERSION
	rebuildPlayerAppearance("transformation login")

mob/verb/Transform()
	set category = "Skills"
	var/list/options = availablePrimaryTransformations()
	var/selection = input(src, "Choose one primary transformation. Selecting another form replaces the current one.", "Transform") in options
	if(!selection) return
	requestPrimaryTransformation(options[selection])

mob/verb/Revert_Transformation()
	set category = "Skills"
	revertPrimaryTransformations("verb")

#undef TRANSFORMATION_STATE_VERSION
