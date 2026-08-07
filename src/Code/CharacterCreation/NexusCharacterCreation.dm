var/list/NEXUS_CREATION_STATS = list(
	"energy" = "Energy",
	"strength" = "Strength",
	"endurance" = "Endurance",
	"speed" = "Speed",
	"force" = "Force",
	"resistance" = "Resistance",
	"offense" = "Offense",
	"defense" = "Defense",
	"regeneration" = "Regeneration",
	"recovery" = "Recovery",
	"anger" = "Anger"
)
var/list/NEXUS_CREATION_STAT_PROFILES = list()
var/list/NEXUS_FROST_ICON_OPTIONS
var/list/NEXUS_STARTER_CLOTHING_OPTIONS
var/list/nexus_preview_icon_states = list()
var/list/nexus_preview_icon_movement = list()
var/nexus_starter_clothing_limit = 4

proc/nexusJsString(value)
	var/text = "[value]"
	text = replacetext(text, "\\", "\\\\")
	text = replacetext(text, "\"", "\\\"")
	text = replacetext(text, ascii2text(13), "")
	text = replacetext(text, "\n", "\\n")
	text = replacetext(text, "</", "<\\/")
	return text

proc/nexusPreviewIconState(icon_file, requested_state)
	if(!icon_file || !requested_state) return null
	var/list/states = nexus_preview_icon_states[icon_file]
	if(!islist(states))
		states = icon_states(icon_file)
		nexus_preview_icon_states[icon_file] = states
	for(var/state_name in states)
		if(lowertext("[state_name]") == lowertext("[requested_state]")) return "[state_name]"
	return null

proc/nexusPreviewFrameHasPixels(icon/frame_icon)
	if(!frame_icon) return FALSE
	for(var/pixel_x in 1 to frame_icon.Width())
		for(var/pixel_y in 1 to frame_icon.Height())
			if(frame_icon.GetPixel(pixel_x, pixel_y)) return TRUE
	return FALSE

proc/nexusPreviewIconMoving(icon_file, icon_state, direction)
	if(!icon_file) return FALSE
	var/cache_key = "\ref[icon_file]|[icon_state]|[direction]"
	if(cache_key in nexus_preview_icon_movement) return nexus_preview_icon_movement[cache_key]
	var/icon/still_frame = icon(icon_file, icon_state, direction, 1, FALSE)
	var/moving = FALSE
	if(!nexusPreviewFrameHasPixels(still_frame))
		var/icon/moving_frame = icon(icon_file, icon_state, direction, 1, TRUE)
		if(nexusPreviewFrameHasPixels(moving_frame)) moving = TRUE
	nexus_preview_icon_movement[cache_key] = moving
	return moving

proc/nexusExtractPreviewFrame(icon_file, icon_state, direction)
	if(!icon_file) return null
	var/moving = nexusPreviewIconMoving(icon_file, icon_state, direction)
	return icon(icon_file, icon_state, direction, 1, moving)

proc/nexusBrowserIconUrl(icon_file, icon_state, direction)
	if(!icon_file) return ""
	var/icon_ref = "\ref[icon_file]"
	var/result = "[icon_ref]?dir=[direction]&frame=1"
	result += "&state=[url_encode("[icon_state]")]"
	return result

proc/nexusFrostIconOptions()
	if(NEXUS_FROST_ICON_OPTIONS) return NEXUS_FROST_ICON_OPTIONS
	NEXUS_FROST_ICON_OPTIONS = list()
	var/icon_index
	for(var/icon_type in typesof(/obj/Icer))
		if(icon_type == /obj/Icer) continue
		var/obj/Icer/choice = new icon_type
		if(choice.icon)
			icon_index++
			NEXUS_FROST_ICON_OPTIONS["frost_form_[icon_index]"] = choice.icon
		del(choice)
	return NEXUS_FROST_ICON_OPTIONS

proc/nexusStarterClothingOptions()
	if(NEXUS_STARTER_CLOTHING_OPTIONS) return NEXUS_STARTER_CLOTHING_OPTIONS
	NEXUS_STARTER_CLOTHING_OPTIONS = list()
	var/clothing_index
	for(var/clothing_type in typesof(/obj/items/Clothes))
		if(clothing_type in list(/obj/items/Clothes, /obj/items/Clothes/CustomClothing)) continue
		var/obj/items/Clothes/choice = new clothing_type
		if(choice.icon)
			clothing_index++
			NEXUS_STARTER_CLOTHING_OPTIONS["clothing_[clothing_index]"] = clothing_type
		del(choice)
	return NEXUS_STARTER_CLOTHING_OPTIONS

proc/nexusAlienOptionDefinitions()
	return list(
		"genius" = list("name" = "Genius", "cost" = 25, "description" = "Raises Intelligence to 1."),
		"alien_transform" = list("name" = "Alien Transform", "cost" = 5, "description" = "A Ki-draining primary transformation."),
		"time_freeze" = list("name" = "Time Stop", "cost" = 25, "description" = "Expands an eight-tile cosmic field that stuns every valid target caught inside."),
		"limit_breaker" = list("name" = "Limit Breaker", "cost" = 15, "description" = "Grants the Limit Breaker burst."),
		"absorb" = list("name" = "Absorb", "cost" = 20, "description" = "Grants absorption."),
		"precognition" = list("name" = "Precognition", "cost" = 25, "description" = "Enables precognition."),
		"death_regeneration" = list("name" = "Death Regeneration", "cost" = 25, "description" = "Adds 0.5 regeneration."),
		"starting_sp" = list("name" = "Starting Progression XP", "cost" = 10, "description" = "Adds a scaled starting balance for the Progression Trees."),
		"zenkai" = list("name" = "Zenkai", "cost" = 15, "description" = "Enables Alien zenkai growth."),
		"meditation" = list("name" = "Meditation", "cost" = 15, "description" = "2.5x meditation BP gain."),
		"materialize" = list("name" = "Materialize", "cost" = 10, "description" = "Grants Materialization."),
		"mastery" = list("name" = "Skill Mastery", "cost" = 6, "description" = "5x skill mastery."),
		"lungs" = list("name" = "Breathe in Space", "cost" = 10, "description" = "Survive without air."),
		"split_form" = list("name" = "Split Form", "cost" = 10, "description" = "Grants Split Form."),
		"elite_bp" = list("name" = "Elite Alien BP", "cost" = 20, "description" = "Adds one era-scaled starting BP package."),
		"stretchy_arms" = list("name" = "Stretchy Arms", "cost" = 10, "description" = "Adds 150-pixel stretchy arms."),
		"blast_homing" = list("name" = "Blast Homing", "cost" = 12, "description" = "1.5x blast homing."),
		"low_ki_resistance" = list("name" = "Low-Ki Resistance", "cost" = 10, "description" = "One-third BP loss from low Ki."),
		"low_health_resistance" = list("name" = "Low-Health Resistance", "cost" = 10, "description" = "One-third BP loss from low Health."),
		"giant_form" = list("name" = "Giant Form", "cost" = 15, "description" = "Grants Giant Form."),
		"imitate" = list("name" = "Imitate", "cost" = 8, "description" = "Grants Imitation."),
		"apex_genome" = list("name" = "Apex Genome", "cost" = 50, "description" = "Control-focused Jiren package with an Anger second wind."),
		"unlock_potential" = list("name" = "Unlock Potential", "cost" = 25, "description" = "Grants Unlock Potential.")
	)

proc/nexusAlienPresetOptions(profile)
	switch(profile)
		if("alien_scholar") return list("genius", "time_freeze", "materialize", "mastery", "lungs", "split_form", "blast_homing")
		if("alien_predator") return list("absorb", "precognition", "death_regeneration", "zenkai", "meditation")
		if("alien_shifter") return list("alien_transform", "giant_form", "imitate", "low_ki_resistance", "low_health_resistance", "stretchy_arms", "blast_homing", "materialize", "lungs", "mastery")
		if("alien_anomaly") return list("apex_genome", "unlock_potential", "death_regeneration")
	return list()

proc/nexusParseIdList(value)
	var/list/result = list()
	if(!istext(value) || !length(value)) return result
	for(var/id in splittext(value, ","))
		if(!length(id) || result[id]) continue
		result[id] = TRUE
	return result

proc/nexusValidateAlienOptions(list/selected_options)
	if(!islist(selected_options)) return FALSE
	var/list/definitions = nexusAlienOptionDefinitions()
	var/total_cost
	for(var/option_id in selected_options)
		var/list/definition = definitions[option_id]
		if(!definition) return FALSE
		total_cost += definition["cost"]
	return total_cost <= 100

proc/nexusCustomIconIsValid(icon/icon_file)
	return icon_file && isicon(icon_file) && !IconTooBig(icon_file)

proc/nexusResolveFrostFormIcon(form_id, form_index, list/custom_form_icons)
	var/list/options = nexusFrostIconOptions()
	if(options[form_id]) return options[form_id]
	var/expected_custom_id = form_index == 1 ? "custom_body" : "custom_frost_[form_index]"
	if(form_id == expected_custom_id && islist(custom_form_icons))
		var/icon/custom_icon = custom_form_icons[form_index]
		if(nexusCustomIconIsValid(custom_icon)) return custom_icon
	return null

proc/nexusValidateFrostFormOptions(list/form_ids, cooler, list/custom_form_icons)
	if(!islist(form_ids)) return FALSE
	var/required_forms = cooler ? 5 : 4
	for(var/form_index in 1 to required_forms)
		if(!nexusResolveFrostFormIcon(form_ids[form_index], form_index, custom_form_icons)) return FALSE
	return TRUE

proc/nexusValidateStarterClothing(list/selected_ids, list/custom_clothing_icons)
	if(!islist(selected_ids) || selected_ids.len > nexus_starter_clothing_limit) return FALSE
	var/list/options = nexusStarterClothingOptions()
	for(var/clothing_id in selected_ids)
		if(options[clothing_id]) continue
		var/custom_index = round(text2num(copytext("[clothing_id]", length("custom_clothing_") + 1)))
		if(findtext("[clothing_id]", "custom_clothing_") != 1 || custom_index < 1 || custom_index > nexus_starter_clothing_limit) return FALSE
		if(!islist(custom_clothing_icons) || !nexusCustomIconIsValid(custom_clothing_icons[custom_index])) return FALSE
	return TRUE

mob/NexusCreationPreview
	New()
		return

mob/var/tmp
	character_creation_committing
	upForm/NexusCharacterCreator/nexus_character_creator

proc/nexusRaceIconOptions(race_name)
	switch(race_name)
		if("Human", "Saiyan", "Half Saiyan", "Legendary Saiyan", "Demigod", "Tsujin")
			return list(
				"human_m_pale" = 'BaseHumanPale.dmi', "human_m_tan" = 'BaseHumanTan.dmi', "human_m_dark" = 'BaseHumanDark.dmi',
				"human_f_pale" = 'NewPaleFemale.dmi', "human_f_tan" = 'NewTanFemale.dmi', "human_f_dark" = 'NewBlackFemale.dmi'
			)
		if("Spirit Doll")
			return list("doll_white" = 'WhiteKaio.dmi', "doll_possessed" = 'PossessedSpiritDoll.dmi', "doll_makai" = 'MakaioshinBase.dmi')
		if("Alien")
			return list(
				"alien_1" = 'Alien1.dmi', "alien_2" = 'Alien2.dmi', "alien_3" = 'Alien3.dmi', "alien_beetle" = 'AlienBeetle.dmi',
				"alien_pikkon" = 'AlienPikkon.dmi', "alien_kanassa" = 'AlienKanassa.dmi', "alien_guldo" = 'AlienGuldo.dmi', "alien_bass" = 'AlienBass.dmi',
				"alien_burter" = 'AlienBurter.dmi', "alien_ginyu" = 'RaceGinyu.dmi', "alien_kui" = 'RaceKui.dmi', "alien_jiren" = 'Jiren23.dmi'
			)
		if("Android")
			return list(
				"android_standard" = 'Android.dmi', "android_blackout" = 'AndroidBlackout.dmi', "android_skeleton" = 'AndroidSkeletor.dmi',
				"android_spider" = 'AndroidSpider.dmi', "android_base_1" = 'BaseAndroid1.dmi', "android_base_2" = 'BaseAndroid2.dmi',
				"android_proxy" = 'AndroidProxy.dmi', "android_human_pale" = 'BaseHumanPale.dmi', "android_human_tan" = 'BaseHumanTan.dmi'
			)
		if("Bio-Android")
			return list("bio_green" = 'CellLarva.dmi', "bio_blue" = 'CellLarvaBlue.dmi')
		if("Demon")
			return list(
				"demon_1" = 'Demon1.dmi', "demon_2" = 'Demon2.dmi', "demon_hades" = 'Hades.dmi', "demon_4" = 'Demon4.dmi',
				"demon_5" = 'Demon5.dmi', "demon_6" = 'Demon6.dmi', "demon_female" = 'Demon6Female.dmi', "demon_janemba" = 'DemonJanemba.dmi',
				"demon_ifrit" = 'DemonIfrit.dmi', "demon_lucifer" = 'Lucifer.dmi', "demon_satan" = 'Satan.dmi', "demon_wolf" = 'DemonWolf.dmi'
			)
		if("Frost Lord")
			return nexusFrostIconOptions()
		if("Kai")
			return list("kai_male" = 'CustomMale.dmi', "kai_female" = 'CustomFemale.dmi', "kai_avatar" = 'Avatar.dmi', "kai_white" = 'WhiteKaio.dmi')
		if("Kanassan")
			return list("kanassan_native" = 'Kanassan.dmi', "kanassan_alien" = 'AlienKanassa.dmi')
		if("Heran")
			return list(
				"heran_pirate" = 'src/Icons/PlayerIcons/BaseIcons/Heran/HeranSpacePirate.dmi',
				"heran_female" = 'src/Icons/PlayerIcons/BaseIcons/Heran/HeranFemale.dmi',
				"heran_female_blue" = 'src/Icons/PlayerIcons/BaseIcons/Heran/HeranFemaleBlue.dmi')
		if("Makyo")
			return list("makyo_1" = 'Makyojin2.dmi', "makyo_2" = 'Konatsu.dmi', "makyo_3" = 'KidAlien.dmi', "makyo_4" = 'Alien4.dmi')
		if("Majin")
			return list("majin_male" = 'Majin.dmi', "majin_female" = 'FemaleMajin.dmi')
		if("Namekian")
			return list("namek_young" = 'NamekYoung.dmi', "namek_adult" = 'NamekAdult.dmi', "namek_old" = 'NamekOld.dmi', "namek_foreign" = 'Namek2.dmi')
	return list("fallback" = 'BaseHumanPale.dmi')

proc/nexusTrait(name, description)
	return list("name" = name, "description" = description)

proc/nexusRaceTraitOptions(race_name, mob/player, cooler_available = 0)
	var/list/traits = list()
	switch(race_name)
		if("Human") traits["human_adaptability"] = nexusTrait("Adaptability", "No fixed specialty. Humans receive the largest free attribute pool.")
		if("Saiyan")
			traits["saiyan_warrior"] = nexusTrait("Warrior Blood", "Standard Saiyan lineage with balanced racial growth.")
			traits["saiyan_low_class"] = nexusTrait("Low Class", "Lower starting power with a more accessible transformation path.")
			if(player && player.canSelectEliteSaiyan()) traits["saiyan_elite"] = nexusTrait("Elite", "Rare high-class lineage with stronger starting techniques.")
		if("Half Saiyan") traits["half_saiyan_hybrid"] = nexusTrait("Hybrid Potential", "Human adaptability combined with Saiyan transformations and anger.")
		if("Legendary Saiyan") traits["legendary_berserker"] = nexusTrait("Legendary Berserker", "Extremely rare lineage with overwhelming latent power.")
		if("Alien")
			traits["alien_scholar"] = nexusTrait("Scholar", "Technology, mastery, materialization, and control abilities.")
			traits["alien_predator"] = nexusTrait("Predator", "Recovery, precognition, absorption, and combat growth.")
			traits["alien_shifter"] = nexusTrait("Shifter", "Transformations, imitation, stretchy limbs, and utility.")
			traits["alien_anomaly"] = nexusTrait("Apex Genome", "Extreme innate power with regeneration and unlocked potential.")
		if("Android")
			traits["android_chassis"] = nexusTrait("Synthetic Chassis", "A visibly mechanical body designed for modular upgrades.")
			traits["android_infiltrator"] = nexusTrait("Infiltrator Shell", "A human-like shell concealing an artificial core.")
			if(player && player.canSelectAncientProgenitor()) traits["android_progenitor"] = nexusTrait("Ancient Progenitor (Rare)", "A relic chassis with exceptional sensors, science aptitude, and system mastery.")
		if("Bio-Android") traits["bio_adaptation"] = nexusTrait("Adaptive Genome", "Absorption and regeneration drive future evolution.")
		if("Demigod") traits["demigod_heritage"] = nexusTrait("Divine Heritage", "Exceptional potential balanced by slow adaptation.")
		if("Demon") traits["demon_soulbound"] = nexusTrait("Soulbound", "Demonic regeneration and access to Soul Energy.")
		if("Frost Lord")
			traits["frost_heir"] = nexusTrait("Imperial Heir", "Standard Frost Lord transformation lineage.")
			if(cooler_available) traits["frost_cooler"] = nexusTrait("Ascendant Strain", "An exceptionally rare fifth-form lineage.")
		if("Kai") traits["kai_guardian"] = nexusTrait("Guardian", "Mystic energy control, recovery, and afterlife techniques.")
		if("Kanassan") traits["kanassan_seer"] = nexusTrait("Seer", "Precognition, telepathy, advanced sensing, and defensive energy control.")
		if("Heran") traits["heran_pirate"] = nexusTrait("Space Pirate", "Physical pressure, high durability, and strong combat growth.")
		if("Makyo") traits["makyo_starborn"] = nexusTrait("Starborn", "Power responds strongly to the Makyo Star cycle.")
		if("Majin") traits["majin_fragment"] = nexusTrait("Primal Fragment", "A regenerative fragment descended from primordial Majin matter.")
		if("Namekian")
			traits["namek_dragon_clan"] = nexusTrait("Dragon Clan", "Regeneration, spiritual techniques, and Namekian fusion.")
			if(player && player.canSelectAncientNamekian()) traits["namek_ancient"] = nexusTrait("Ancient Namekian (Rare)", "A rare arcane lineage with stronger regeneration, meditation, and mystical techniques.")
		if("Spirit Doll") traits["doll_awakened"] = nexusTrait("Awakened Soul", "A constructed body animated by a highly focused soul.")
		if("Tsujin") traits["tsujin_engineer"] = nexusTrait("Engineer", "Advanced knowledge and technology-focused development.")
	return traits

mob/proc/canSelectEliteSaiyan()
	if(world.time <= 3000) return FALSE
	var/saiyan_count = Saiyan_Count()
	if(saiyan_count < 10) return FALSE
	var/elite_count
	for(var/mob/player in players)
		if(player.Race == "Saiyan" && player.Class == "Elite") elite_count++
	return elite_count / saiyan_count < elite_chance / 100

mob/proc/initializeNexusRaceByTrait(race_name, trait_id)
	var/force_elite = trait_id == "saiyan_elite"
	var/force_low_class = trait_id == "saiyan_low_class"
	var/force_normal_class = trait_id == "saiyan_warrior"
	var/force_cooler = trait_id == "frost_cooler"
	src.InitializeRaceTemplate(race_name, force_elite, force_low_class, 0, force_cooler, force_normal_class)
	if(trait_id == "namek_ancient") src.applyAncientNamekianLineage()
	if(trait_id == "android_progenitor") src.applyAncientProgenitorLineage()

mob/proc/raiseNexusCreationStat(stat_name, amount = 1)
	switch(stat_name)
		if("Energy") src.Raise_Energy(amount)
		if("Strength") src.Raise_Strength(amount)
		if("Endurance") src.Raise_Durability(amount)
		if("Speed") src.Raise_Speed(amount)
		if("Force") src.Raise_Force(amount)
		if("Resistance") src.Raise_Resist(amount)
		if("Offense") src.Raise_Offense(amount)
		if("Defense") src.Raise_Defense(amount)
		if("Regeneration") src.Raise_Regeneration(amount)
		if("Recovery") src.Raise_Recovery(amount)
		if("Anger") src.Raise_Anger(amount)

proc/nexusCreationStatStep(stat_id)
	if(stat_id in list("regeneration", "recovery")) return 0.2
	return 0.1

mob/proc/getNexusCreationStatValue(stat_id)
	switch(stat_id)
		if("energy") return src.Eff
		if("strength") return src.strmod
		if("endurance") return src.endmod
		if("speed") return src.spdmod
		if("force") return src.formod
		if("resistance") return src.resmod
		if("offense") return src.offmod
		if("defense") return src.defmod
		if("regeneration") return src.regen
		if("recovery") return src.recov
		if("anger") return src.max_anger * 0.01
	return 0

proc/nexusCreationStatProfile(race_name, trait_id)
	var/profile_id = "[race_name]|[trait_id]"
	if(NEXUS_CREATION_STAT_PROFILES[profile_id]) return NEXUS_CREATION_STAT_PROFILES[profile_id]
	var/mob/NexusCreationPreview/preview = new
	preview.initializeNexusRaceByTrait(race_name, trait_id)
	var/list/template_values = list()
	for(var/stat_id in NEXUS_CREATION_STATS) template_values[stat_id] = preview.getNexusCreationStatValue(stat_id)
	preview.Points = 44 + preview.RaceBonusStatPoints()
	preview.C = preview
	preview.ApplyRaceBuild()
	var/budget = preview.Points
	var/list/base_values = list()
	var/list/racial_points = list()
	var/list/steps = list()
	for(var/stat_id in NEXUS_CREATION_STATS)
		var/stat_step = nexusCreationStatStep(stat_id)
		base_values[stat_id] = preview.getNexusCreationStatValue(stat_id)
		steps[stat_id] = stat_step
		racial_points[stat_id] = round((base_values[stat_id] - template_values[stat_id]) / stat_step, 0.1)
	del(preview)

	// The legacy allocator treats the initialized race values as the subtraction floor.
	// Free lineage points therefore do not consume the player's per-stat allocation room.
	var/mob/NexusCreationPreview/cap_preview = new
	cap_preview.initializeNexusRaceByTrait(race_name, trait_id)
	cap_preview.C = cap_preview
	var/list/caps = list()
	for(var/stat_id in NEXUS_CREATION_STATS)
		var/stat_name = NEXUS_CREATION_STATS[stat_id]
		var/cap = 0
		if(!(cap_preview.Android && stat_name == "Anger"))
			while(cap < budget && !cap_preview.StatRaceCapped(stat_name))
				cap_preview.raiseNexusCreationStat(stat_name)
				cap++
		caps[stat_id] = cap
	del(cap_preview)
	var/list/profile = list("budget" = budget, "caps" = caps, "base" = base_values, "racial_points" = racial_points, "steps" = steps)
	NEXUS_CREATION_STAT_PROFILES[profile_id] = profile
	return profile

proc/nexusValidateStatAllocation(list/profile, list/allocation)
	if(!islist(profile) || !islist(allocation)) return FALSE
	var/list/caps = profile["caps"]
	var/total
	for(var/stat_id in NEXUS_CREATION_STATS)
		var/amount = round(text2num("[allocation[stat_id]]"))
		if(amount < 0 || amount > caps[stat_id]) return FALSE
		total += amount
	return total == profile["budget"]

mob/proc/applyNexusStatAllocation(list/allocation)
	if(!islist(allocation)) return FALSE
	var/total
	for(var/stat_id in NEXUS_CREATION_STATS)
		var/amount = round(text2num("[allocation[stat_id]]"))
		if(amount < 0) return FALSE
		total += amount
	if(total != src.Points) return FALSE
	for(var/stat_id in NEXUS_CREATION_STATS)
		var/stat_name = NEXUS_CREATION_STATS[stat_id]
		var/amount = round(text2num("[allocation[stat_id]]"))
		while(amount > 0)
			src.raiseNexusCreationStat(stat_name)
			src.Points--
			amount--
	return src.Points == 0

mob/proc/canBeginNexusCharacterCreation()
	if(src.playerCharacter || src.character_creation_committing) return FALSE
	if(!can_login)
		alert(src, "Character creation is unavailable until the server finishes loading.")
		return FALSE
	if(race_stats_only_mode)
		alert(src, "Character creation is unavailable while race-stat preview mode is active.")
		return FALSE
	if(world.time < 50)
		alert(src, "You can not make a new character until at least 5 seconds have passed since the last reboot.")
		return FALSE
	if(src.cantRemake())
		alert(src, "You can not remake because you accepted a rank that is not allowed to remake. An admin must clear the restriction.")
		return FALSE
	if(Max_Players && Players_with_z() >= Max_Players)
		alert(src, "The server is at its [Max_Players] player limit. Try again after someone logs off.")
		return FALSE
	var/relog_time = src.Spam_relogger()
	if(relog_time)
		relog_time = round((relog_time - world.time) / 10)
		alert(src, "You are relogging too quickly. Wait [relog_time] seconds before creating a character.")
		return FALSE
	return TRUE

mob/proc/openNexusCharacterCreator()
	if(!src.client) return FALSE
	if(src.nexus_character_creator)
		src.nexus_character_creator.RefreshPage()
		return TRUE
	if(!src.canBeginNexusCharacterCreation()) return FALSE
	return !!upForm(src, src, /upForm/NexusCharacterCreator)

mob/proc/autoAllocateCharacterStats()
	var/list/stat_order = list("Energy", "Strength", "Endurance", "Speed", "Force", "Resistance", "Offense", "Defense")
	while(src.Points > 0)
		var/allocated
		for(var/stat_name in stat_order)
			if(src.Points <= 0) break
			if(src.StatRaceCapped(stat_name)) continue
			src.raiseNexusCreationStat(stat_name)
			src.Points--
			allocated = TRUE
		if(!allocated) CRASH("Unable to allocate [src.Points] character stat points")

mob/proc/applyNexusAlienOptions(list/selected_options)
	if(src.Race != "Alien") return
	var/starting_bp = max(round(Avg_Base * src.bp_mod), 6000)
	var/elite_aliens
	var/total_aliens
	for(var/mob/player in players)
		if(player.client && player.Race == "Alien")
			total_aliens++
			if(player.Class == "Elite") elite_aliens++
	if(world.time > 5 * 60 * 10 && total_aliens && (!elite_aliens || elite_aliens / total_aliens < 0.04))
		src.Class = "Elite"
		src.hbtc_bp += starting_bp

	for(var/option_id in selected_options)
		switch(option_id)
			if("genius") src.Intelligence = 1
			if("alien_transform")
				var/obj/Buff/transformation = new(src)
				transformation.teachable = 0
				transformation.name = "Alien transform"
				transformation.desc = "This transformation increases BP but drains energy"
				transformation.buff_attributes += "transformation"
				transformation.buff_overlays += 'AuraElectric.dmi' + rgb(80,180,80)
			if("time_freeze") src.contents += new /obj/Attacks/Time_Freeze
			if("limit_breaker") src.contents += new /obj/Limit_Breaker
			if("absorb") src.contents += new /obj/Absorb
			if("precognition") src.precog = 1
			if("death_regeneration") src.Regenerate += 0.5
			if("starting_sp") src.gainProgressionExperience(getScaledProgressionExperience(round(15 * SP_Multiplier ** 0.5)), "starting trait", announce = FALSE)
			if("zenkai")
				src.zenkai_mod = 1
				src.alien_zenkai = 1
			if("meditation") src.med_mod *= 2.5
			if("materialize") src.contents += new /obj/Materialization
			if("mastery") src.mastery_mod *= 5
			if("lungs") src.Lungs = 1
			if("split_form") src.contents += new /obj/SplitForm
			if("elite_bp") src.hbtc_bp += starting_bp
			if("stretchy_arms")
				src.arm_stretch = 1
				src.arm_stretch_icon = 'GenericArm.dmi'
				src.arm_stretch_range = 150
			if("blast_homing") src.blast_homing_mod *= 1.5
			if("low_ki_resistance") src.bp_loss_from_low_ki /= 3
			if("low_health_resistance") src.bp_loss_from_low_hp /= 3
			if("giant_form") src.contents += new /obj/Giant_Form
			if("imitate") src.contents += new /obj/Imitation
			if("apex_genome") src.jirenAlien = 1
			if("unlock_potential") src.contents += new /obj/Unlock_Potential

mob/proc/applyNexusAlienProfile(profile)
	applyNexusAlienOptions(nexusAlienPresetOptions(profile))

mob/proc/applyNexusAppearance(selected_race, gender_choice, body_icon_id, obj/Hairs/hair_choice, hair_color, list/frost_form_ids, icon/custom_body_icon, list/custom_frost_icons)
	if(selected_race in list("Bio-Android", "Namekian", "Android")) src.gender = "male"
	else if(gender_choice == "female") src.gender = "female"
	else src.gender = "male"
	if(!istext(hair_color) || length(hair_color) != 7 || copytext(hair_color, 1, 2) != "#" || !ReadRGB(hair_color)) hair_color = "#2b1b14"

	var/list/icon_options = nexusRaceIconOptions(selected_race)
	var/selected_icon = body_icon_id == "custom_body" && nexusCustomIconIsValid(custom_body_icon) ? custom_body_icon : icon_options[body_icon_id]
	if(!selected_icon)
		for(var/icon_id in icon_options)
			selected_icon = icon_options[icon_id]
			break
	src.icon = selected_icon
	src.base_icon_color = null
	if(selected_race == "Frost Lord")
		src.Form1Icon = selected_icon
		if(frost_form_ids)
			src.Form2Icon = nexusResolveFrostFormIcon(frost_form_ids[2], 2, custom_frost_icons)
			src.Form3Icon = nexusResolveFrostFormIcon(frost_form_ids[3], 3, custom_frost_icons)
			src.Form4Icon = nexusResolveFrostFormIcon(frost_form_ids[4], 4, custom_frost_icons)
			if(src.IsCooler) src.Form5Icon = nexusResolveFrostFormIcon(frost_form_ids[5], 5, custom_frost_icons)
	if(selected_race == "Demigod") src.icon += rgb(60,60,60)
	if(src.arm_stretch && src.arm_stretch_icon == 'GenericArm.dmi') src.Auto_color_arm_stretch_icon()

	var/can_have_hair = !(selected_race in list("Majin", "Bio-Android", "Namekian", "Frost Lord"))
	if(selected_race == "Android" && body_icon_id != "custom_body" && findtext(body_icon_id, "android_human_") != 1) can_have_hair = FALSE
	if(can_have_hair && hair_choice) Apply_Hair(src, hair_choice, hair_color)

mob/proc/applyNexusStarterClothing(list/selected_ids, list/custom_clothing_icons)
	var/list/options = nexusStarterClothingOptions()
	var/priority = 500
	var/icon/body_preview = icon(src.icon)
	for(var/clothing_id in selected_ids)
		var/clothing_type = options[clothing_id]
		var/obj/items/Clothes/item
		if(clothing_type)
			item = new clothing_type(src)
		else
			var/custom_index = round(text2num(copytext("[clothing_id]", length("custom_clothing_") + 1)))
			var/icon/custom_icon = islist(custom_clothing_icons) ? custom_clothing_icons[custom_index] : null
			if(!nexusCustomIconIsValid(custom_icon)) continue
			item = new /obj/items/Clothes/CustomClothing(src)
			item.name = "Custom Clothing [custom_index]"
			item.icon = custom_icon
		var/icon/clothing_preview = icon(item.icon)
		if(body_preview && clothing_preview && (clothing_preview.Width() != body_preview.Width() || clothing_preview.Height() != body_preview.Height()))
			clothing_preview.Scale(body_preview.Width(), body_preview.Height())
			item.icon = clothing_preview
		item.pixel_x = 0
		item.pixel_y = 0
		item.suffix = "Equipped"
		item.appearance_managed = TRUE
		item.appearance_priority = priority
		priority += 10
	rebuildPlayerAppearance("starter clothing")

mob/proc/setNexusCharacterAge(requested_age)
	var/starting_age = 0
	if(allow_age_choosing) starting_age = Clamp(round(text2num("[requested_age]"), 0.1), 0, 1000)
	src.BirthYear = Year - starting_age
	src.Age = starting_age
	src.real_age = starting_age
	spawn(600) if(src && src.Age > src.Lifespan()) src.Die()

mob/proc/commitNexusCharacter(selected_race, requested_name, gender_choice, alignment_choice, requested_age, race_trait, body_icon_id, obj/Hairs/hair_choice, hair_color, list/stat_allocation, cooler_available, list/alien_options, list/frost_form_ids, list/starter_clothing, icon/custom_body_icon, list/custom_clothing_icons, list/custom_frost_icons)
	if(!src.client || src.playerCharacter || src.character_creation_committing) return FALSE
	if(!can_login) return FALSE
	if(race_stats_only_mode) return FALSE
	if(src.cantRemake()) return FALSE
	if(Max_Players && Players_with_z() >= Max_Players) return FALSE
	var/list/available_races = src.GetAvailableCharacterRaces()
	if(!(selected_race in available_races)) return FALSE
	var/list/trait_options = nexusRaceTraitOptions(selected_race, src, cooler_available)
	if(!trait_options[race_trait]) return FALSE
	var/list/icon_options = nexusRaceIconOptions(selected_race)
	var/custom_body_selected = body_icon_id == "custom_body"
	if(custom_body_selected)
		if(!nexusCustomIconIsValid(custom_body_icon)) return FALSE
	else if(!icon_options[body_icon_id]) return FALSE
	if(!custom_body_selected && race_trait == "android_chassis" && findtext(body_icon_id, "android_human_") == 1) return FALSE
	if(!custom_body_selected && race_trait == "android_infiltrator" && findtext(body_icon_id, "android_human_") != 1) return FALSE
	if(selected_race == "Alien" && !nexusValidateAlienOptions(alien_options)) return FALSE
	if(selected_race == "Frost Lord")
		if(!islist(frost_form_ids)) return FALSE
		frost_form_ids[1] = body_icon_id
		if(custom_body_selected)
			if(!islist(custom_frost_icons)) custom_frost_icons = list(null, null, null, null, null)
			custom_frost_icons[1] = custom_body_icon
		if(!nexusValidateFrostFormOptions(frost_form_ids, race_trait == "frost_cooler", custom_frost_icons)) return FALSE
	if(!nexusValidateStarterClothing(starter_clothing, custom_clothing_icons)) return FALSE
	var/safe_name = html_encode(copytext("[requested_name]", 1, 50))
	if(InvalidPlayerName(safe_name)) return FALSE
	if(!(gender_choice in list("male", "female"))) gender_choice = "male"
	if(!(alignment_choice in list("Good", "Evil"))) alignment_choice = "Good"
	var/list/stat_profile = nexusCreationStatProfile(selected_race, race_trait)
	if(!nexusValidateStatAllocation(stat_profile, stat_allocation)) return FALSE

	src.character_creation_committing = TRUE
	src.initializeNexusRaceByTrait(selected_race, race_trait)
	src.rollCharacterMutations()
	src.bp_loss_from_low_ki = src.Get_bp_loss_from_low_ki()
	src.bp_loss_from_low_hp = src.Get_bp_loss_from_low_hp()
	if(!src.Racial_Stats(Start_Redo_Stats = 0, stat_allocation = stat_allocation))
		src.character_creation_committing = FALSE
		return FALSE
	if(selected_race == "Legendary Saiyan") next_lssj = world.realtime + (10 * 60 * 600)
	if(alignment_on) src.setInitialAlignment(alignment_choice)
	if(selected_race == "Alien") src.applyNexusAlienOptions(alien_options)
	src.applyNexusAppearance(selected_race, gender_choice, body_icon_id, hair_choice, hair_color, frost_form_ids, custom_body_icon, custom_frost_icons)
	src.applyNexusStarterClothing(starter_clothing, custom_clothing_icons)
	src.name = safe_name
	src.setNexusCharacterAge(requested_age)
	src.Race_Starting_Stats()
	src.Go_to_spawn(First_time = 1, choose_random = 1)
	if(src.formod >= 2 || src.Pow >= 200)
		src.contents += new /obj/Meditate_Level_2
		if(src.max_ki / src.Eff < 1000) src.max_ki *= 2
	if(prob(Cured_Vampire_Ratio() * 100)) src.Former_Vampire = 1
	src.FinishNewCharacterSetup()
	src.rebuildPlayerAppearance("completed character creation")
	src.stat_version = cur_stat_ver
	src.LoadFeats()
	src.character_made_time = world.realtime
	if(src.Race == "Android" || src.Race == "Majin")
		src.max_ki = energy_cap * src.Eff
		src.Ki = src.max_ki
	// StuffThatRunsIfYouClickNewOrLoad() is asynchronous. Mark the transition complete
	// before the creator is deleted so its close fallback cannot reopen character selection.
	src.playerCharacter = TRUE
	src.character_creation_committing = FALSE
	src.StuffThatRunsIfYouClickNewOrLoad()
	spawn(5) if(src) src.save()
	return TRUE

proc/nexusRaceDescription(race_name)
	switch(race_name)
		if("Human") return "Adaptable and ambitious inhabitants of Earth."
		if("Saiyan") return "Warrior lineage shaped by combat and transformation."
		if("Half Saiyan") return "Hybrid potential with powerful emotional growth."
		if("Legendary Saiyan") return "An exceptionally rare and unstable Saiyan bloodline."
		if("Alien") return "Unknown lineages with highly specialized adaptations."
		if("Android") return "Artificial bodies designed around modular upgrades."
		if("Bio-Android") return "Adaptive organisms driven by absorption and evolution."
		if("Demigod") return "Divine descendants with enormous long-term potential."
		if("Demon") return "Immortal denizens of Hell empowered by souls."
		if("Frost Lord") return "Imperial shapeshifters born with extreme power."
		if("Kai") return "Mystic guardians of the living world and afterlife."
		if("Kanassan") return "Psionic seers who excel at awareness and defensive control."
		if("Heran") return "Powerful space pirates driven by pressure and combat growth."
		if("Makyo") return "Star-bound fighters empowered by celestial cycles."
		if("Majin") return "Regenerative magical fragments of primordial chaos."
		if("Namekian") return "Spiritual warriors with regeneration and fusion."
		if("Spirit Doll") return "Constructed bodies awakened by focused souls."
		if("Tsujin") return "Technical specialists with advanced knowledge."
	return "A distinct lineage within the Nexus."

upForm/NexusCharacterCreator
	form_type = UPFORM_WINDOW
	window_title = "Nexus Exodus - Character Creation"
	window_size = "1180x760"
	window_params = UPFORM_CANNOT_CLOSE | UPFORM_CANNOT_MINIMIZE
	var
		error_message
		cooler_available
		list/hair_options
		icon/custom_body_icon
		list/custom_clothing_icons
		list/custom_frost_icons
		list/extracted_preview_resources
		pending_custom_selection

	New(client/owner, datum/host, list/viewers)
		cooler_available = prob(1)
		hair_options = list()
		custom_clothing_icons = list(null, null, null, null)
		custom_frost_icons = list(null, null, null, null, null)
		extracted_preview_resources = list()
		var/hair_index
		for(var/obj/Hairs/hair in Hairs)
			if(!hair.icon) continue
			hair_index++
			hair_options["hair_[hair_index]"] = hair
			if(hair_index >= 24) break
		var/mob/player = host
		if(player) player.nexus_character_creator = src
		..(owner, host, viewers)

	Del()
		var/mob/player = src.getHost()
		if(player && player.nexus_character_creator == src) player.nexus_character_creator = null
		..()
		if(player && player.client && !player.playerCharacter && !player.character_creation_committing)
			spawn() player.ShowNexusLoginPrompt()

	canDisplayForm(client/C)
		. = ..()
		if(!.) return
		var/mob/player = src.getHost()
		if(!player || C.mob != player || player.playerCharacter) return FALSE

	proc/getClothingPreviewUrl(icon_file, icon_state, direction)
		if(!nexusPreviewIconMoving(icon_file, icon_state, direction))
			return nexusBrowserIconUrl(icon_file, icon_state, direction)
		var/resource_key = "\ref[icon_file]|[icon_state]|[direction]"
		var/resource_name = "nexus_creator_clothing_[md5(resource_key)].png"
		if(!extracted_preview_resources[resource_name])
			var/icon/frame_icon = nexusExtractPreviewFrame(icon_file, icon_state, direction)
			if(!nexusPreviewFrameHasPixels(frame_icon)) return ""
			src.LoadResource(frame_icon, resource_name)
			extracted_preview_resources[resource_name] = TRUE
		return resource_name

	Link(list/href_list, client/C)
		var/mob/player = src.getHost()
		if(!player || C.mob != player || player.playerCharacter) return
		var/action_id = "[href_list["action"]]"
		if(action_id == "upload_body")
			var/icon/body_upload = input(player, "Choose a DMI or image for the character body. Maximum [maxIconW]x[maxIconH] and [maxIconFileSize] MB.", "Custom Body") as icon|null
			if(body_upload && nexusCustomIconIsValid(body_upload))
				custom_body_icon = body_upload
				pending_custom_selection = "body"
				error_message = null
			else if(body_upload)
				var/body_upload_error = IconTooBig(body_upload)
				error_message = body_upload_error ? IconTooBigMsg(body_upload_error) : "The selected body file is not a supported icon."
			RefreshPage()
			return
		if(action_id == "upload_clothing")
			var/clothing_index = Clamp(round(text2num("[href_list["slot"]]")), 1, nexus_starter_clothing_limit)
			var/icon/clothing_upload = input(player, "Choose an overlay DMI or image for clothing layer [clothing_index]. Maximum [maxIconW]x[maxIconH] and [maxIconFileSize] MB.", "Custom Clothing") as icon|null
			if(clothing_upload && nexusCustomIconIsValid(clothing_upload))
				custom_clothing_icons[clothing_index] = clothing_upload
				pending_custom_selection = "clothing_[clothing_index]"
				error_message = null
			else if(clothing_upload)
				var/clothing_upload_error = IconTooBig(clothing_upload)
				error_message = clothing_upload_error ? IconTooBigMsg(clothing_upload_error) : "The selected clothing file is not a supported icon."
			RefreshPage()
			return
		if(action_id == "upload_frost")
			var/form_index = Clamp(round(text2num("[href_list["slot"]]")), 2, 5)
			var/icon/frost_upload = input(player, "Choose a DMI or image for Frost Lord form [form_index]. Maximum [maxIconW]x[maxIconH] and [maxIconFileSize] MB.", "Custom Frost Form") as icon|null
			if(frost_upload && nexusCustomIconIsValid(frost_upload))
				custom_frost_icons[form_index] = frost_upload
				pending_custom_selection = "frost_[form_index]"
				error_message = null
			else if(frost_upload)
				var/frost_upload_error = IconTooBig(frost_upload)
				error_message = frost_upload_error ? IconTooBigMsg(frost_upload_error) : "The selected Frost form file is not a supported icon."
			RefreshPage()
			return
		if(action_id != "create") return
		var/list/stat_allocation = list()
		for(var/stat_id in NEXUS_CREATION_STATS)
			stat_allocation[stat_id] = href_list["stat_[stat_id]"]
		var/obj/Hairs/hair_choice = hair_options[href_list["hair_id"]]
		var/list/alien_options = nexusParseIdList(href_list["alien_options"])
		var/list/frost_form_ids = list(href_list["body_icon_id"], href_list["frost_form_2"], href_list["frost_form_3"], href_list["frost_form_4"], href_list["frost_form_5"])
		var/list/starter_clothing = nexusParseIdList(href_list["clothing_ids"])
		if(player.commitNexusCharacter(href_list["selected_race"], href_list["character_name"], href_list["gender"], href_list["alignment"], href_list["age"], href_list["race_trait"], href_list["body_icon_id"], hair_choice, href_list["hair_color"], stat_allocation, cooler_available, alien_options, frost_form_ids, starter_clothing, custom_body_icon, custom_clothing_icons, custom_frost_icons))
			del(src)
		else
			error_message = "The character could not be created. Review the name, trait, icon, and attribute points."
			RefreshPage()

	GenerateBody()
		var/mob/player = src.getHost()
		if(!player) return
		prepareNexusHudBrowserResources(player)
		if(custom_body_icon) src.LoadResource(custom_body_icon)
		for(var/custom_clothing_index in 1 to nexus_starter_clothing_limit)
			if(custom_clothing_icons[custom_clothing_index]) src.LoadResource(custom_clothing_icons[custom_clothing_index])
		for(var/custom_frost_index in 1 to 5)
			if(custom_frost_icons[custom_frost_index]) src.LoadResource(custom_frost_icons[custom_frost_index])
		var/list/available_races = player.GetAvailableCharacterRaces()
		var/race_list_html = ""
		var/icon_panels_html = ""
		var/trait_panels_html = ""
		var/list/profile_entries = list()
		var/list/description_entries = list()
		var/list/body_preview_entries = list()
		var/list/hair_preview_entries = list()
		var/list/clothing_preview_entries = list()
		var/list/preview_directions = list("south" = SOUTH, "north" = NORTH, "east" = EAST, "west" = WEST)
		var/first_race
		var/custom_body_preview_added
		for(var/race_name in available_races)
			if(!first_race) first_race = race_name
			var/safe_race_js = nexusJsString(race_name)
			var/safe_description_js = nexusJsString(nexusRaceDescription(race_name))
			description_entries += "\"[safe_race_js]\":\"[safe_description_js]\""
			var/list/icon_options = nexusRaceIconOptions(race_name)
			var/icons_html = ""
			var/first_icon_alias
			for(var/icon_id in icon_options)
				var/icon_file = icon_options[icon_id]
				var/flight_state = nexusPreviewIconState(icon_file, "Flight")
				var/list/direction_entries = list()
				for(var/direction_name in preview_directions)
					var/direction = preview_directions[direction_name]
					var/icon_alias = nexusBrowserIconUrl(icon_file, "", direction)
					direction_entries += "[direction_name]:'[nexusJsString(icon_alias)]'"
					if(flight_state)
						var/flight_alias = nexusBrowserIconUrl(icon_file, flight_state, direction)
						direction_entries += "[direction_name]_flight:'[nexusJsString(flight_alias)]'"
				body_preview_entries += "\"[nexusJsString(icon_id)]\":{canFlight:[flight_state ? "true" : "false"],[dd_list2text(direction_entries, ",")]}"
				var/icon_alias = nexusBrowserIconUrl(icon_file, "", SOUTH)
				if(!first_icon_alias) first_icon_alias = icon_alias
				icons_html += "<label class=\"portrait-choice\"><input type=\"radio\" name=\"body_icon_id\" value=\"[icon_id]\" data-owner-race=\"[html_encode(race_name)]\" onchange=\"updateAppearance()\"><span><img src=\"[html_encode(icon_alias)]\"></span></label>"
			if(custom_body_icon)
				var/custom_flight_state = nexusPreviewIconState(custom_body_icon, "Flight")
				var/list/custom_direction_entries = list()
				for(var/direction_name in preview_directions)
					var/direction = preview_directions[direction_name]
					var/custom_alias = nexusBrowserIconUrl(custom_body_icon, "", direction)
					custom_direction_entries += "[direction_name]:'[nexusJsString(custom_alias)]'"
					if(custom_flight_state)
						var/custom_flight_alias = nexusBrowserIconUrl(custom_body_icon, custom_flight_state, direction)
						custom_direction_entries += "[direction_name]_flight:'[nexusJsString(custom_flight_alias)]'"
				if(!custom_body_preview_added)
					body_preview_entries += "\"custom_body\":{canFlight:[custom_flight_state ? "true" : "false"],[dd_list2text(custom_direction_entries, ",")]}"
					custom_body_preview_added = TRUE
				var/custom_south_alias = nexusBrowserIconUrl(custom_body_icon, "", SOUTH)
				icons_html += "<label class=\"portrait-choice custom-choice\"><input type=\"radio\" name=\"body_icon_id\" value=\"custom_body\" data-owner-race=\"[html_encode(race_name)]\" onchange=\"updateAppearance()\"><span><img src=\"[html_encode(custom_south_alias)]\"><small>CUSTOM</small></span></label>"
			race_list_html += "<label class=\"race-entry\"><input type=\"radio\" name=\"selected_race\" value=\"[html_encode(race_name)]\" onchange=\"selectRace(this.value)\"><span><img src=\"[html_encode(first_icon_alias)]\"><b>[html_encode(race_name)]</b></span></label>"
			icon_panels_html += "<div class=\"icon-panel\" data-race=\"[html_encode(race_name)]\"><div class=\"portrait-grid\">[icons_html]</div></div>"

			var/list/trait_options = nexusRaceTraitOptions(race_name, player, cooler_available)
			var/traits_html = ""
			for(var/trait_id in trait_options)
				var/list/trait = trait_options[trait_id]
				var/trait_name = trait["name"]
				var/trait_description = trait["description"]
				traits_html += "<label class=\"trait-choice\"><input type=\"radio\" name=\"race_trait\" value=\"[trait_id]\" onchange=\"traitChanged()\"><span><b>[html_encode(trait_name)]</b><small>[html_encode(trait_description)]</small></span></label>"
				var/list/profile = nexusCreationStatProfile(race_name, trait_id)
				var/list/caps = profile["caps"]
				var/list/base_values = profile["base"]
				var/list/racial_points = profile["racial_points"]
				var/list/steps = profile["steps"]
				var/profile_budget = profile["budget"]
				var/list/cap_entries = list()
				var/list/base_entries = list()
				var/list/racial_entries = list()
				var/list/step_entries = list()
				for(var/stat_id in NEXUS_CREATION_STATS)
					cap_entries += "[stat_id]:[caps[stat_id]]"
					base_entries += "[stat_id]:[round(base_values[stat_id], 0.01)]"
					racial_entries += "[stat_id]:[round(racial_points[stat_id], 0.1)]"
					step_entries += "[stat_id]:[steps[stat_id]]"
				var/cap_text = dd_list2text(cap_entries, ",")
				var/safe_profile_id = nexusJsString("[race_name]|[trait_id]")
				profile_entries += "\"[safe_profile_id]\":{budget:[profile_budget],caps:{[cap_text]},base:{[dd_list2text(base_entries, ",")]},racialPoints:{[dd_list2text(racial_entries, ",")]},steps:{[dd_list2text(step_entries, ",")]}}"
			trait_panels_html += "<div class=\"trait-panel\" data-race=\"[html_encode(race_name)]\">[traits_html]</div>"

		var/hairs_html = "<label class=\"hair-choice\"><input type=\"radio\" name=\"hair_id\" value=\"none\" checked><span>None</span></label>"
		for(var/hair_id in hair_options)
			var/obj/Hairs/hair = hair_options[hair_id]
			var/hair_flight_state = nexusPreviewIconState(hair.icon, "Flight")
			var/list/direction_entries = list()
			for(var/direction_name in preview_directions)
				var/direction = preview_directions[direction_name]
				var/hair_alias = nexusBrowserIconUrl(hair.icon, hair.icon_state, direction)
				direction_entries += "[direction_name]:'[nexusJsString(hair_alias)]'"
				if(hair_flight_state)
					var/hair_flight_alias = nexusBrowserIconUrl(hair.icon, hair_flight_state, direction)
					direction_entries += "[direction_name]_flight:'[nexusJsString(hair_flight_alias)]'"
			hair_preview_entries += "\"[nexusJsString(hair_id)]\":{[dd_list2text(direction_entries, ",")]}"
			var/hair_alias = nexusBrowserIconUrl(hair.icon, hair.icon_state, SOUTH)
			hairs_html += "<label class=\"hair-choice\"><input type=\"radio\" name=\"hair_id\" value=\"[hair_id]\" onchange=\"updatePreview()\"><span><img src=\"[html_encode(hair_alias)]\" title=\"[html_encode(hair.name)]\"></span></label>"

		var/alien_options_html = ""
		var/list/alien_preset_entries = list()
		var/list/alien_definitions = nexusAlienOptionDefinitions()
		for(var/option_id in alien_definitions)
			var/list/definition = alien_definitions[option_id]
			var/option_cost = definition["cost"]
			var/option_name = html_encode(definition["name"])
			var/option_description = html_encode(definition["description"])
			alien_options_html += "<label class=\"option-card\"><input type=\"checkbox\" data-alien-option=\"[option_id]\" data-cost=\"[option_cost]\" onchange=\"updateAlienPoints()\"><span><b>[option_name] <em>[option_cost] AP</em></b><small>[option_description]</small></span></label>"
		for(var/profile_id in list("alien_scholar", "alien_predator", "alien_shifter", "alien_anomaly"))
			var/list/preset_options = nexusAlienPresetOptions(profile_id)
			var/list/quoted_options = list()
			for(var/option_id in preset_options) quoted_options += "'[nexusJsString(option_id)]'"
			alien_preset_entries += "'[nexusJsString(profile_id)]':\[[dd_list2text(quoted_options, ",")]\]"

		var/list/frost_form_names = list("2" = "Second Form", "3" = "Third Form", "4" = "Final Form", "5" = "Fifth Form")
		var/frost_options_html = "<div class=\"frost-form-grid\">"
		for(var/form_index in 2 to 5)
			var/frost_select_options = ""
			var/frost_option_index
			for(var/frost_icon_id in nexusFrostIconOptions())
				frost_option_index++
				frost_select_options += "<option value=\"[frost_icon_id]\">Style [frost_option_index]</option>"
			var/icon/custom_frost_icon = custom_frost_icons[form_index]
			if(custom_frost_icon)
				var/custom_frost_id = "custom_frost_[form_index]"
				frost_select_options += "<option value=\"[custom_frost_id]\">Custom Form [form_index]</option>"
				var/list/custom_frost_directions = list()
				for(var/direction_name in preview_directions)
					var/direction = preview_directions[direction_name]
					var/custom_frost_alias = nexusBrowserIconUrl(custom_frost_icon, "", direction)
					custom_frost_directions += "[direction_name]:'[nexusJsString(custom_frost_alias)]'"
					body_preview_entries += "\"[custom_frost_id]\":{canFlight:false,[dd_list2text(custom_frost_directions, ",")]}"
			var/fifth_form_id = form_index == 5 ? " id=\"frostFifthOption\"" : ""
			var/form_name = frost_form_names["[form_index]"]
			frost_options_html += "<section class=\"hud-card frost-form-card\"[fifth_form_id]><b>[form_name]</b><span class=\"hud-sprite frost-form-preview\"><img id=\"frostPreview[form_index]\"></span><div class=\"frost-form-controls\"><select name=\"frost_form_[form_index]\" onchange=\"updateFrostPreviews();saveCreatorState()\">[frost_select_options]</select><a class=\"hud-button upload-button\" href=\"byond://?src=\ref[src]&action=upload_frost&slot=[form_index]\" onclick=\"saveCreatorState()\">IMPORT ICON</a></div></section>"
		frost_options_html += "</div>"

		var/clothing_html = ""
		var/clothing_upload_html = ""
		var/list/starter_clothing_options = nexusStarterClothingOptions()
		for(var/clothing_id in starter_clothing_options)
			var/clothing_type = starter_clothing_options[clothing_id]
			var/obj/items/Clothes/clothing = new clothing_type
			var/clothing_flight_state = nexusPreviewIconState(clothing.icon, "Flight")
			var/list/direction_entries = list()
			for(var/direction_name in preview_directions)
				var/direction = preview_directions[direction_name]
				var/clothing_alias = src.getClothingPreviewUrl(clothing.icon, clothing.icon_state, direction)
				direction_entries += "[direction_name]:'[nexusJsString(clothing_alias)]'"
				if(clothing_flight_state)
					var/clothing_flight_alias = src.getClothingPreviewUrl(clothing.icon, clothing_flight_state, direction)
					direction_entries += "[direction_name]_flight:'[nexusJsString(clothing_flight_alias)]'"
			clothing_preview_entries += "\"[nexusJsString(clothing_id)]\":{[dd_list2text(direction_entries, ",")]}"
			var/clothing_alias = src.getClothingPreviewUrl(clothing.icon, clothing.icon_state, SOUTH)
			clothing_html += "<label class=\"clothing-choice\"><input type=\"checkbox\" data-clothing-id=\"[clothing_id]\" onchange=\"updateClothing(this)\"><span><img src=\"[html_encode(clothing_alias)]\"><small>[html_encode(clothing.name)]</small></span></label>"
			del(clothing)
		for(var/custom_index in 1 to nexus_starter_clothing_limit)
			clothing_upload_html += "<a class=\"hud-button upload-button\" href=\"byond://?src=\ref[src]&action=upload_clothing&slot=[custom_index]\" onclick=\"saveCreatorState()\">IMPORT LAYER [custom_index]</a>"
			var/icon/custom_clothing_icon = custom_clothing_icons[custom_index]
			if(!custom_clothing_icon) continue
			var/custom_clothing_id = "custom_clothing_[custom_index]"
			var/list/custom_clothing_directions = list()
			for(var/direction_name in preview_directions)
				var/direction = preview_directions[direction_name]
				var/custom_clothing_direction_alias = src.getClothingPreviewUrl(custom_clothing_icon, "", direction)
				custom_clothing_directions += "[direction_name]:'[nexusJsString(custom_clothing_direction_alias)]'"
			clothing_preview_entries += "\"[custom_clothing_id]\":{[dd_list2text(custom_clothing_directions, ",")]}"
			var/custom_clothing_alias = src.getClothingPreviewUrl(custom_clothing_icon, "", SOUTH)
			clothing_html = "<label class=\"clothing-choice custom-choice\"><input type=\"checkbox\" data-clothing-id=\"[custom_clothing_id]\" onchange=\"updateClothing(this)\"><span><img src=\"[html_encode(custom_clothing_alias)]\"><small>Custom Layer [custom_index]</small></span></label>[clothing_html]"

		var/stats_html = ""
		for(var/stat_id in NEXUS_CREATION_STATS)
			var/stat_name = NEXUS_CREATION_STATS[stat_id]
			stats_html += "<div class=\"hud-card stat-row\"><b class=\"stat-name\">[stat_name]</b><span class=\"stat-cell\"><small>RACE VALUE</small><strong id=\"base_[stat_id]\">0</strong></span><span class=\"stat-cell\"><small>LINEAGE</small><strong id=\"racial_[stat_id]\">+0 PTS</strong></span><span class=\"stat-allocator\"><small>YOUR BUILD</small><span><button class=\"hud-button\" type=\"button\" onclick=\"adjustStat('[stat_id]',-1)\">-</button><input id=\"stat_[stat_id]\" name=\"stat_[stat_id]\" value=\"0\" readonly><button class=\"hud-button\" type=\"button\" onclick=\"adjustStat('[stat_id]',1)\">+</button></span><em id=\"cap_[stat_id]\">CAP 0</em></span><span class=\"stat-cell final\"><small>FINAL VALUE</small><strong id=\"final_[stat_id]\">0</strong></span></div>"

		var/error_html = error_message ? "<div class=\"form-error\">[html_encode(error_message)]</div>" : ""
		var/age_control = allow_age_choosing ? "<label class=\"field-label\">Age<input name=\"age\" type=\"number\" min=\"0\" max=\"1000\" value=\"18\"></label>" : "<input name=\"age\" type=\"hidden\" value=\"0\">"
		var/alignment_control = "<input name=\"alignment\" type=\"hidden\" value=\"Good\">"
		if(alignment_on) alignment_control = "<div class=\"field-label\">Alignment</div><div class=\"toggle-row\"><label><input type=\"radio\" name=\"alignment\" value=\"Good\" checked><span>Good</span></label><label><input type=\"radio\" name=\"alignment\" value=\"Evil\"><span>Evil</span></label></div>"

		var/body = {"
			<form action="byond://" method="get" id="creatorForm" class="nexus-hud">
				<input type="hidden" name="src" value="\ref[src]"><input type="hidden" name="action" value="create"><input type="hidden" name="alien_options" id="alienOptions"><input type="hidden" name="clothing_ids" id="clothingIds">
				<div class="hud-frame menu-frame">
					<div class="hud-section-title menu-title"><span>CHARACTER CREATION</span><em id="stageTitle">1 / 5 - LINEAGE</em></div>
					<div class="stage-strip"><span class="hud-tab" data-step="0">Lineage</span><span class="hud-tab" data-step="1">Race</span><span class="hud-tab" data-step="2">Appearance</span><span class="hud-tab" data-step="3">Attributes</span><span class="hud-tab" data-step="4">Review</span></div>
					<div class="wizard-content">
						<section class="wizard-stage" data-stage="0"><div class="menu-columns stage-lineage"><section class="hud-card panel race-menu"><h2 class="hud-section-title">Lineage</h2><div class="race-scroll">[race_list_html]</div></section><section class="hud-card panel character-menu wide-panel"><h2 class="hud-section-title">Racial Identity</h2><h3>Trait / Preset</h3>[trait_panels_html]<div id="raceDescription" class="hud-panel description"></div></section></div></section>
						<section class="wizard-stage" data-stage="1"><section class="hud-card panel full-panel"><h2 class="hud-section-title">Racial Specialization</h2><div class="stage-scroll"><div id="alienOptionPanel"><div class="hud-panel level-strip alien-points-indicator" id="alienPointsIndicator"><span>Alien Points Remaining</span><b><strong id="alienPoints">100</strong> / 100 AP</b></div><p>Select any combination costing up to 100 AP. The lineage trait from the previous stage is only a preset and can be customized.</p><div class="option-grid">[alien_options_html]</div></div><div id="frostOptionPanel"><p>Choose every form independently. Every slot accepts a built-in sprite or your own icon. Fifth Form appears only for the Ascendant Strain.</p>[frost_options_html]</div><div id="genericRaceOptions" class="hud-panel empty-stage">This lineage has no extra creation choices.</div></div></section></section>
						<section class="wizard-stage" data-stage="2"><div class="menu-columns appearance-layout"><section class="hud-card panel preview-panel"><h2 class="hud-section-title">Composed Preview</h2><div class="hud-panel preview-shell"><canvas id="previewCanvas" width="32" height="32"></canvas></div><div class="preview-controls"><button class="hud-button" type="button" onclick="rotatePreview(-1)">Rotate Left</button><button class="hud-button" type="button" onclick="toggleFlight()">Ground / Flight</button><button class="hud-button" type="button" onclick="rotatePreview(1)">Rotate Right</button></div><small id="previewState">South / Ground</small><p class="preview-note">The body, equipped clothing layers and hair are rendered into one pixel canvas in game order.</p></section><section class="hud-card panel character-menu"><h2 class="hud-section-title">Identity & Body</h2><div class="stage-scroll"><div class="identity-grid"><label class="field-label wide">Name<input name="character_name" maxlength="49" autocomplete="off" placeholder="Character name"></label>[age_control]</div><div class="toggle-row"><label><input type="radio" name="gender" value="male" checked><span>Male</span></label><label><input type="radio" name="gender" value="female"><span>Female</span></label></div>[alignment_control]<div class="section-heading"><h3>Body</h3><a class="hud-button upload-button" href="byond://?src=\ref[src]&action=upload_body" onclick="saveCreatorState()">IMPORT CUSTOM BODY</a></div>[icon_panels_html]<div id="hairSection"><h3>Hair</h3><div class="hair-grid">[hairs_html]</div><label class="field-label">Hair Color<input name="hair_color" type="color" value="#2b1b14"></label></div></div></section><section class="hud-card panel clothing-panel"><h2 class="hud-section-title">Optional Clothing</h2><div class="hud-panel level-strip"><span>Equipped Layers</span><b id="clothingCount">0 / [nexus_starter_clothing_limit]</b></div><div class="custom-upload-grid">[clothing_upload_html]</div><div class="clothing-grid">[clothing_html]</div></section></div></section>
						<section class="wizard-stage" data-stage="3"><section class="hud-card panel full-panel attributes-menu"><h2 class="hud-section-title">Attributes</h2><div class="hud-panel level-strip"><span>Points Remaining</span><b id="pointsRemaining">0</b></div><div class="stat-legend"><span>Race Value is already active.</span><span>Lineage shows free racial points.</span><span>Your Build spends the remaining budget.</span></div><div class="stats staged-stats">[stats_html]</div></section></section>
						<section class="wizard-stage" data-stage="4"><section class="hud-card panel full-panel review-panel"><h2 class="hud-section-title">Review</h2><div id="reviewSummary" class="hud-panel"></div>[error_html]<button class="hud-button confirm journey-button" type="submit">Begin Journey</button></section></section>
					</div>
					<div class="wizard-nav"><button class="hud-button" id="backButton" type="button" onclick="goStage(-1)">Back</button><button class="hud-button" id="nextButton" type="button" onclick="goStage(1)">Next</button></div>
				</div>
			</form>
		"}

		var/css = {"
			*{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:hidden}body{font-family:Georgia,'Times New Roman',serif;color:#f7e4bd;background:#3a241b}body:before{content:'';position:fixed;inset:0;background:rgba(38,20,15,.48)}input,button{font:inherit}.menu-frame{position:relative;margin:18px auto;width:calc(100% - 36px);height:calc(100vh - 36px);padding:10px;background:linear-gradient(135deg,rgba(80,45,35,.96),rgba(45,25,21,.96));border:2px solid #c5a269;box-shadow:0 0 0 3px #42271e,0 12px 45px #170c09}.menu-title{height:42px;display:flex;align-items:center;justify-content:space-between;padding:0 16px;background:linear-gradient(#654438,#402820);border:1px solid #bb9661;box-shadow:inset 0 0 12px #24120e;text-shadow:1px 2px #1b0d09}.menu-title span{font-size:20px;font-weight:bold}.menu-title em{font-size:11px;letter-spacing:2px;color:#d5b983}.menu-columns{display:grid;grid-template-columns:210px minmax(430px,1fr) 285px;gap:8px;height:calc(100% - 50px);margin-top:8px}.panel{min-width:0;overflow:hidden;background:linear-gradient(145deg,rgba(92,57,46,.94),rgba(58,34,29,.96));border:1px solid #c2a06c;box-shadow:inset 0 0 0 2px #3b221b,inset 0 0 20px rgba(20,8,5,.55)}h2{height:31px;margin:0;padding:6px 10px;background:linear-gradient(90deg,#6f4b3e,#493028);border-bottom:1px solid #c09b65;font-size:14px;text-shadow:1px 1px #1a0b08}h3{font-size:12px;color:#e8c98f;margin:10px 0 5px;border-bottom:1px solid #9b744e;padding-bottom:3px}.race-scroll{height:calc(100% - 31px);overflow:auto;padding:5px}.race-entry{display:block;margin-bottom:3px}.race-entry input{position:absolute;opacity:0}.race-entry span{display:flex;align-items:center;height:43px;padding:3px 7px;border:1px solid transparent;color:#f2dbb5}.race-entry img{width:34px;height:34px;object-fit:contain;image-rendering:pixelated;margin-right:8px;background:#3a201a;border:1px solid #805b40}.race-entry input:checked+span,.race-entry span:hover{background:linear-gradient(90deg,#bc8d4c,#6a4332);border-color:#e5c47f;color:#fff}.race-entry input:checked+span:before{content:'>';margin-right:5px;color:#fff4be}.character-menu{overflow:auto;padding:0 10px 12px}.identity-grid{display:grid;grid-template-columns:1fr 100px;gap:8px;margin-top:8px}.field-label{display:block;font-size:11px;color:#e3c58f;margin:6px 0}.field-label input{display:block;width:100%;margin-top:3px;padding:6px;color:#fff2d7;background:#3c241e;border:1px solid #9d7954;outline:none}.toggle-row{display:flex;gap:5px;margin:6px 0}.toggle-row label{flex:1}.toggle-row input{position:absolute;opacity:0}.toggle-row span{display:block;text-align:center;padding:5px;border:1px solid #8b6748;background:#422921}.toggle-row input:checked+span{background:linear-gradient(#b08450,#765035);border-color:#f0d08d;color:#fff}.icon-panel,.trait-panel{display:none}.portrait-grid{display:grid;grid-template-columns:repeat(8,1fr);gap:4px;max-height:112px;overflow:auto;padding:4px;background:rgba(42,23,18,.45)}.portrait-choice input,.hair-choice input,.trait-choice input{position:absolute;opacity:0}.portrait-choice span,.hair-choice span{display:flex;align-items:center;justify-content:center;height:48px;background:#42271f;border:1px solid #7f5b40}.portrait-choice img,.hair-choice img{max-width:44px;max-height:44px;image-rendering:pixelated}.portrait-choice input:checked+span,.hair-choice input:checked+span{border:2px solid #f0d48d;background:#7a5034;box-shadow:0 0 7px #e0b66a}.trait-choice{display:block;margin:4px 0}.trait-choice span{display:block;padding:6px 8px;background:rgba(57,32,26,.78);border:1px solid #7e5b43}.trait-choice b,.trait-choice small{display:block}.trait-choice b{font-size:12px;color:#f0d59d}.trait-choice small{font:10px Arial,sans-serif;color:#d4bfa3;margin-top:2px}.trait-choice input:checked+span{background:linear-gradient(90deg,#9d7143,#5b392c);border-color:#e3c47f}.hair-grid{display:grid;grid-template-columns:repeat(10,1fr);gap:3px;max-height:105px;overflow:auto}.hair-choice span{height:42px;font-size:10px}.description{font:11px Arial,sans-serif;color:#ead7b9;margin-top:8px;padding:7px;background:rgba(40,21,17,.55);border-left:3px solid #d0a867}.attributes-menu{padding:0 9px 10px}.level-strip{display:flex;justify-content:space-between;margin:8px 0;padding:7px 9px;background:#3e251e;border:1px solid #936c49;color:#e9cd99}.level-strip b{color:#fff6c5}.stats{border-top:1px solid #95704d}.stat-row{display:grid;grid-template-columns:1fr 28px 38px 28px;align-items:center;min-height:36px;border-bottom:1px solid rgba(195,157,103,.34);font-size:12px}.stat-row button{height:25px;border:1px solid #9d764e;background:#5b3829;color:#f5dfb9;cursor:pointer}.stat-row input{width:34px;text-align:center;border:0;background:transparent;color:#fff6c8;font-weight:bold}.form-error{margin:8px 0;padding:7px;background:#6d2d28;border:1px solid #d98a70;font:11px Arial,sans-serif}.confirm{width:100%;margin-top:10px;padding:9px;border:1px solid #f0d28e;background:linear-gradient(#b6884e,#70452e);color:#fff7d7;font-weight:bold;text-shadow:1px 1px #2d170f;cursor:pointer}.confirm:hover{background:linear-gradient(#c99b59,#815239)}@media(max-width:900px){.menu-columns{grid-template-columns:170px 1fr}.attributes-menu{grid-column:1/3;max-height:270px;overflow:auto}.menu-frame{height:auto;min-height:calc(100vh - 20px);margin:10px}.menu-columns{height:auto}html,body{overflow:auto}}
		"}
		css += {"
			.stage-strip{height:34px;display:flex;gap:4px;margin-top:8px}.stage-strip span{flex:1;text-align:center;padding:8px 4px;background:#3d2821;border:1px solid #76563d;font-size:11px;color:#a98c68}.stage-strip span.active{background:#88603e;color:#fff1ce;border-color:#d0ac70}.wizard-content{height:calc(100% - 126px);margin-top:8px}.wizard-stage{display:none;height:100%}.wizard-stage.active{display:block}.wizard-stage .menu-columns{height:100%;margin-top:0}.stage-lineage{grid-template-columns:250px 1fr}.wide-panel{grid-column:span 2}.full-panel{height:100%}.stage-scroll{height:calc(100% - 31px);overflow:auto;padding:12px}.wizard-nav{height:42px;display:flex;justify-content:space-between;align-items:end}.wizard-nav button,.preview-controls button{padding:7px 14px;color:#f7e4bd;background:#5e3e31;border:1px solid #b98e58}.wizard-nav button:hover,.preview-controls button:hover{background:#80583f}.option-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:6px}.option-card input,.clothing-choice input{position:absolute;opacity:0}.option-card span{display:block;min-height:68px;padding:8px;background:#3a261f;border:1px solid #725038}.option-card input:checked+span{background:#694a35;border-color:#e0bd76;box-shadow:inset 0 0 10px #26140e}.option-card b{display:flex;justify-content:space-between}.option-card em{font-size:10px;color:#e7c371}.option-card small{display:block;margin-top:5px;color:#cbb99b}.frost-form-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px}.frost-form-grid label{display:flex;flex-direction:column;gap:4px}.frost-form-grid select{background:#2d1d18;color:#f3dfba;border:1px solid #94704b;padding:7px}.empty-stage{padding:30px;text-align:center;color:#bca98d}.appearance-layout{grid-template-columns:260px minmax(360px,1fr) 300px}.preview-panel{text-align:center}.preview-shell{height:360px;display:flex;align-items:center;justify-content:center;background:radial-gradient(circle,#574237,#211613 70%);border-bottom:1px solid #8f6a45}.preview-stack{position:relative;width:192px;height:256px;transform:scale(2);transform-origin:center}.preview-stack img,.preview-stack #previewClothes img{position:absolute;inset:0;margin:auto;width:auto;height:auto;image-rendering:pixelated}.preview-controls{display:flex;justify-content:center;gap:4px;padding:12px 4px}.preview-controls button{font-size:10px;padding:6px}.clothing-grid{height:calc(100% - 66px);overflow:auto;display:grid;grid-template-columns:repeat(3,1fr);gap:4px;padding:6px}.clothing-choice span{display:flex;min-height:72px;flex-direction:column;align-items:center;justify-content:center;padding:3px;background:#36231d;border:1px solid #654633;text-align:center}.clothing-choice input:checked+span{background:#725039;border-color:#dfbd79}.clothing-choice img{width:42px;height:42px;object-fit:contain;image-rendering:pixelated}.clothing-choice small{font-size:9px}.staged-stats{display:grid;grid-template-columns:1fr 1fr;gap:6px 18px;max-width:760px;margin:18px auto}.review-panel{padding-bottom:20px}.review-panel #reviewSummary{margin:25px auto;max-width:720px;padding:20px;background:#33221d;border:1px solid #9b754f;line-height:1.8}.journey-button{display:block;margin:20px auto;width:280px}.form-error{max-width:720px;margin:10px auto}.character-menu .stage-scroll{overflow:auto}@media(max-width:900px){.appearance-layout{grid-template-columns:210px 1fr}.clothing-panel{grid-column:span 2}.option-grid{grid-template-columns:1fr 1fr}}
		"}
		css += {"
			.preview-shell{overflow:hidden}.preview-stack{width:192px;height:192px;transform:none;pointer-events:none}.preview-stack>img,#previewClothes,#previewClothes>img{position:absolute;top:0;right:0;bottom:0;left:0;width:192px;height:192px;margin:auto;object-fit:contain;image-rendering:pixelated;pointer-events:none}.preview-controls{position:relative;z-index:2}.preview-controls button:disabled{opacity:.45;cursor:not-allowed}.frost-form-card{display:grid!important;grid-template-columns:96px 1fr;grid-template-rows:auto 1fr;gap:5px 10px;padding:8px;background:#38251f;border:1px solid #76523b}.frost-form-card>b{grid-column:1 / 3}.frost-form-preview{grid-row:2;display:flex;align-items:center;justify-content:center;width:96px;height:96px;background:radial-gradient(circle,#5b4438,#211613);border:1px solid #806044}.frost-form-preview img{width:88px;height:88px;object-fit:contain;image-rendering:pixelated}.frost-form-card select{align-self:center;min-width:0}
		"}
		css += {"
			body.nexus-hud{background-color:#17130f!important;background-image:linear-gradient(135deg,#17130f,#211a13 55%,#120d08)!important}.menu-frame{margin:10px auto;width:calc(100% - 20px);height:calc(100vh - 20px);padding:9px;background:#211a13!important;border:2px solid #120d08!important;outline:1px solid #715735!important;box-shadow:inset 0 0 0 2px #715735,3px 3px 0 #000!important}.menu-title{height:42px;padding:7px 14px;background:#3a2a1b!important;border:2px solid #120d08!important;box-shadow:inset 4px 0 #d2aa61,inset 0 0 0 2px #715735!important}.menu-title span{font-size:17px}.panel,.race-entry span,.portrait-choice span,.hair-choice span,.trait-choice span,.option-card span,.clothing-choice span,.frost-form-card,.review-panel #reviewSummary{background:#2b2117!important;background-image:none!important}.panel{border:2px solid #120d08!important;outline:1px solid #715735!important;box-shadow:inset 0 0 0 2px #715735,2px 2px 0 #000!important}h2.hud-section-title{height:31px;padding:7px 11px;font-size:12px}.race-entry span,.portrait-choice span,.hair-choice span,.trait-choice span,.option-card span,.clothing-choice span{border:2px solid #120d08!important;outline:1px solid #715735!important;box-shadow:inset 0 0 0 1px #715735!important}.race-entry input:checked+span,.race-entry span:hover,.portrait-choice input:checked+span,.hair-choice input:checked+span,.trait-choice input:checked+span,.option-card input:checked+span,.clothing-choice input:checked+span{background:#725027!important;outline-color:#d2aa61!important;box-shadow:inset 4px 0 #d2aa61!important}.portrait-choice span{position:relative;flex-direction:column}.portrait-choice small{position:absolute;right:2px;bottom:1px;color:#f0d497;font-size:6px}.section-heading{display:flex;align-items:end;justify-content:space-between;gap:7px}.section-heading h3{flex:1}.upload-button{padding:6px 8px;font-size:8px}.custom-upload-grid{display:grid;grid-template-columns:1fr 1fr;gap:5px;padding:6px}.custom-upload-grid .upload-button{display:block}.clothing-grid{height:calc(100% - 132px);background:#18130e!important}.preview-shell{height:350px;background:#120d08!important;box-shadow:inset 0 0 0 2px #715735!important}.preview-shell canvas{width:256px;height:256px;max-width:90%;max-height:90%;image-rendering:pixelated;image-rendering:crisp-edges}.preview-note{padding:4px 10px;color:#927b58;font-size:8px;line-height:1.4}.preview-controls .hud-button,.wizard-nav .hud-button{padding:7px 13px}.frost-form-preview{background:#120d08!important;background-image:none!important}.frost-form-controls{display:flex;flex-direction:column;justify-content:center;gap:7px}.frost-form-controls select{width:100%}.stat-legend{display:grid;grid-template-columns:repeat(3,1fr);gap:5px;max-width:1040px;margin:7px auto;color:#bca47c;font-size:8px}.stat-legend span{padding:6px;background:#251c14;border-left:3px solid #d2aa61}.staged-stats{display:grid;grid-template-columns:1fr;gap:6px;max-width:1040px;margin:8px auto 18px}.stat-row{display:grid;grid-template-columns:150px 1fr 1fr 1.4fr 1fr;align-items:stretch;min-height:58px;padding:6px 9px;background:#251c14!important}.stat-name{display:flex;align-items:center;color:#f0d497;font-size:11px}.stat-cell,.stat-allocator{display:flex;min-width:0;flex-direction:column;align-items:center;justify-content:center;border-left:1px solid #715735}.stat-cell small,.stat-allocator small{color:#bca47c;font-size:7px}.stat-cell strong{margin-top:5px;color:#ead7b0;font-size:12px}.stat-cell.final strong{color:#fff0bd}.stat-allocator>span{display:flex;align-items:center;justify-content:center;margin-top:3px}.stat-allocator .hud-button{width:28px;height:25px;padding:2px}.stat-allocator input{width:38px;height:25px;background:#120d08!important;border:1px solid #715735!important}.stat-allocator em{margin-top:2px;color:#927b58;font-size:7px}.form-error{background:#241718!important;border:2px solid #7e4646!important;color:#ffd8d4}.journey-button{padding:10px!important}@media(max-width:900px){.stat-row{grid-template-columns:110px repeat(4,1fr)}.appearance-layout{grid-template-columns:205px 1fr}.clothing-panel{grid-column:span 2}.preview-shell canvas{width:180px;height:180px}}
		"}
		css += {"
			.stage-lineage{grid-template-rows:minmax(0,1fr)!important}.stage-lineage .wide-panel{grid-column:auto!important}.stage-lineage .race-menu,.stage-lineage .character-menu{height:100%;min-height:0}.race-menu{display:flex;flex-direction:column}.race-menu>h2{flex:0 0 31px}.race-scroll{flex:1 1 auto;height:auto!important;min-height:0}.attributes-menu{overflow-y:auto!important;overflow-x:hidden!important;padding-bottom:24px!important}.appearance-layout{grid-template-rows:minmax(0,1fr)!important;min-height:0;overflow:hidden}.appearance-layout>.panel{height:100%;min-height:0}.preview-panel{min-width:0;overflow:hidden}.preview-shell{contain:strict!important}.preview-shell canvas{display:block!important;flex:none!important;width:256px!important;height:256px!important;contain:strict}.clothing-panel{display:flex!important;min-height:0;flex-direction:column}.clothing-panel>h2{flex:0 0 31px}.clothing-panel>.level-strip,.clothing-panel>.custom-upload-grid{flex:0 0 auto}.clothing-panel>.clothing-grid{flex:1 1 auto;height:auto!important;min-height:0;grid-auto-rows:80px;align-content:start}.clothing-choice{position:relative;display:block;min-width:0;height:80px;overflow:hidden}.clothing-choice>input{position:absolute!important;left:2px!important;top:2px!important;width:1px!important;height:1px!important;margin:0!important;opacity:0!important}.clothing-choice span{width:100%;height:76px!important;min-height:0!important;overflow:hidden}.clothing-choice img{display:block!important;width:42px!important;height:42px!important;min-width:42px!important;min-height:42px!important;max-width:42px!important;max-height:42px!important;flex:0 0 42px;object-fit:contain!important}.clothing-choice small{display:block;width:100%;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.alien-points-indicator{position:sticky!important;z-index:8;top:-12px;margin:0 -2px 10px!important;padding:10px 12px!important;background:#302317!important;border:2px solid #120d08!important;outline:1px solid #d2aa61!important;box-shadow:inset 4px 0 #d2aa61,0 4px 0 rgba(0,0,0,.65)!important;text-transform:uppercase}.alien-points-indicator b{font-size:12px;color:#f0d497!important}.alien-points-indicator strong{font-size:16px;color:#fff0bd}.alien-points-indicator.over-budget{outline-color:#e26767!important;box-shadow:inset 4px 0 #e26767,0 4px 0 rgba(0,0,0,.65)!important}.alien-points-indicator.over-budget b,.alien-points-indicator.over-budget strong{color:#ff8f86!important}.review-panel .journey-button{display:block!important;width:280px!important;margin:42px auto 0!important}.review-panel #reviewSummary{width:calc(100% - 48px)!important;max-width:720px!important;margin:25px auto!important}
		"}

		var/pending_custom_js = nexusJsString(pending_custom_selection)
		var/js = {"
			var profiles={[dd_list2text(profile_entries, ",")]};
			var statIds=\['energy','strength','endurance','speed','force','resistance','offense','defense','regeneration','recovery','anger'\];
			var descriptions={[dd_list2text(description_entries, ",")]};
			var bodyPreviews={[dd_list2text(body_preview_entries, ",")]};
			var hairPreviews={[dd_list2text(hair_preview_entries, ",")]};
			var clothingPreviews={[dd_list2text(clothing_preview_entries, ",")]};
			var alienPresets={[dd_list2text(alien_preset_entries, ",")]};
			var pendingCustomSelection='[pending_custom_js]',creatorStorageKey='nexus_creator_\ref[src]',previewImageCache={},previewRenderGeneration=0;
			var stageNames=\['Lineage','Race Specialization','Appearance','Attributes','Review'\],currentStage=0,previewDirections=\['south','west','north','east'\],previewDirection=0,previewFlight=false;
			function checkedValue(name){var nodes=document.getElementsByName(name);for(var i=0;i<nodes.length;i++){if(nodes\[i\].checked)return nodes\[i\].value;}return '';}
			function setVisible(selector,race){var nodes=document.querySelectorAll(selector);for(var i=0;i<nodes.length;i++){nodes\[i\].style.display=nodes\[i\].getAttribute('data-race')==race?'block':'none';}}
			function selectFirst(selector,race){var box=document.querySelector(selector+'\[data-race="'+race+'"\]');if(!box)return;var input=box.querySelector('input');if(input)input.checked=true;}
			function selectRace(race){setVisible('.icon-panel',race);setVisible('.trait-panel',race);var allIcons=document.getElementsByName('body_icon_id');for(var i=0;i<allIcons.length;i++)allIcons\[i\].checked=false;var allTraits=document.getElementsByName('race_trait');for(var j=0;j<allTraits.length;j++)allTraits\[j\].checked=false;selectFirst('.icon-panel',race);selectFirst('.trait-panel',race);document.getElementById('raceDescription').textContent=descriptions\[race\]||'';document.getElementById('alienOptionPanel').style.display=race=='Alien'?'block':'none';document.getElementById('frostOptionPanel').style.display=race=='Frost Lord'?'block':'none';document.getElementById('genericRaceOptions').style.display=(race!='Alien'&&race!='Frost Lord')?'block':'none';traitChanged();}
			function currentProfile(){return profiles\[checkedValue('selected_race')+'|'+checkedValue('race_trait')\];}
			function traitChanged(){var race=checkedValue('selected_race'),trait=checkedValue('race_trait');if(race=='Android'){var panel=document.querySelector('.icon-panel\[data-race="Android"\]'),icons=panel?panel.getElementsByTagName('input'):null,wantHuman=trait=='android_infiltrator';if(icons){for(var i=0;i<icons.length;i++){var isHuman=icons\[i\].value.indexOf('android_human_')===0;if((wantHuman&&isHuman)||(!wantHuman&&!isHuman)){icons\[i\].checked=true;break;}}}}if(race=='Alien')applyAlienPreset(trait);document.getElementById('frostFifthOption').style.display=trait=='frost_cooler'?'grid':'none';resetStats();updateAppearance();updateFrostPreviews();}
			function updateHairVisibility(){var race=checkedValue('selected_race'),icon=checkedValue('body_icon_id'),hidden='|Majin|Bio-Android|Namekian|Frost Lord|'.indexOf('|'+race+'|')>=0||(race=='Android'&&icon!='custom_body'&&icon.indexOf('android_human_')!==0);document.getElementById('hairSection').style.display=hidden?'none':'block';if(hidden){var none=document.querySelector('input\[name="hair_id"\]\[value="none"\]');if(none)none.checked=true;}}
			function formatStat(value){var rounded=Math.round(value*100)/100;return Math.abs(rounded-Math.round(rounded))<0.001?rounded.toFixed(1):String(rounded);}
			function updateStatDisplay(){var profile=currentProfile();if(!profile)return;for(var i=0;i<statIds.length;i++){var id=statIds\[i\],allocated=parseInt(document.getElementById('stat_'+id).value||0),base=Number(profile.base\[id\]||0),racial=Number(profile.racialPoints\[id\]||0),step=Number(profile.steps\[id\]||0);document.getElementById('base_'+id).textContent=formatStat(base);document.getElementById('racial_'+id).textContent=(racial>=0?'+':'')+formatStat(racial)+' PTS';document.getElementById('racial_'+id).style.color=racial?'#d2aa61':'#927b58';document.getElementById('final_'+id).textContent=formatStat(base+allocated*step);document.getElementById('cap_'+id).textContent='CAP '+profile.caps\[id\]+' PTS';}}
			function updatePoints(){var profile=currentProfile();if(!profile)return;var used=0;for(var i=0;i<statIds.length;i++)used+=parseInt(document.getElementById('stat_'+statIds\[i\]).value||0);document.getElementById('pointsRemaining').innerHTML=profile.budget-used;updateStatDisplay();}
			function resetStats(){var profile=currentProfile();if(!profile)return;for(var i=0;i<statIds.length;i++)document.getElementById('stat_'+statIds\[i\]).value=0;updatePoints();}
			function adjustStat(id,delta){var profile=currentProfile();if(!profile)return;var input=document.getElementById('stat_'+id),value=parseInt(input.value||0),remaining=parseInt(document.getElementById('pointsRemaining').innerHTML||0);if(delta>0&&remaining>0&&value<profile.caps\[id\])input.value=value+1;if(delta<0&&value>0)input.value=value-1;updatePoints();saveCreatorState();}
			function applyAlienPreset(trait){var wanted=alienPresets\[trait\]||\[\],nodes=document.querySelectorAll('\[data-alien-option\]');for(var i=0;i<nodes.length;i++)nodes\[i\].checked=wanted.indexOf(nodes\[i\].getAttribute('data-alien-option'))>=0;updateAlienPoints();}
			function updateAlienPoints(){var nodes=document.querySelectorAll('\[data-alien-option\]'),used=0,ids=\[\];for(var i=0;i<nodes.length;i++){if(nodes\[i\].checked){used+=parseInt(nodes\[i\].getAttribute('data-cost')||0);ids.push(nodes\[i\].getAttribute('data-alien-option'));}}var remaining=100-used,indicator=document.getElementById('alienPointsIndicator');document.getElementById('alienPoints').textContent=remaining;if(indicator)indicator.className='hud-panel level-strip alien-points-indicator'+(remaining<0?' over-budget':'');document.getElementById('alienOptions').value=ids.join(',');}
			function selectedClothing(){var nodes=document.querySelectorAll('\[data-clothing-id\]'),ids=\[\];for(var i=0;i<nodes.length;i++)if(nodes\[i\].checked)ids.push(nodes\[i\].getAttribute('data-clothing-id'));return ids;}
			function updateClothing(changed){var grid=document.querySelector('.clothing-grid'),savedScroll=grid?grid.scrollTop:0,ids=selectedClothing();if(ids.length>[nexus_starter_clothing_limit]){var remove=changed;if(!remove){var nodes=document.querySelectorAll('\[data-clothing-id\]');for(var i=0;i<nodes.length;i++)if(nodes\[i\].checked&&nodes\[i\].getAttribute('data-clothing-id').indexOf('custom_clothing_')!==0){remove=nodes\[i\];break;}if(!remove)for(var j=0;j<nodes.length;j++)if(nodes\[j\].checked){remove=nodes\[j\];break;}}if(remove)remove.checked=false;ids=selectedClothing();}document.getElementById('clothingIds').value=ids.join(',');document.getElementById('clothingCount').textContent=ids.length+' / [nexus_starter_clothing_limit]';updatePreview();if(grid){grid.scrollTop=savedScroll;setTimeout(function(){grid.scrollTop=savedScroll;},0);}}
			function updateAppearance(){updateHairVisibility();updatePreview();}
			function loadPreviewImage(url,done){if(!url){done(null);return;}var cached=previewImageCache\[url\];if(cached&&cached.complete){done(cached);return;}var image=new Image();previewImageCache\[url\]=image;image.onload=function(){done(image);};image.onerror=function(){done(null);};image.src=url;}
			function composePreview(urls){var generation=++previewRenderGeneration,loaded=new Array(urls.length),remaining=urls.length;if(!remaining)return;for(var i=0;i<urls.length;i++)(function(index){loadPreviewImage(urls\[index\],function(image){loaded\[index\]=image;if(--remaining||generation!=previewRenderGeneration)return;var body=loaded\[0\],canvas=document.getElementById('previewCanvas');if(!body||!canvas)return;var width=32,height=32;canvas.width=width;canvas.height=height;var context=canvas.getContext('2d');context.imageSmoothingEnabled=false;context.clearRect(0,0,width,height);for(var layer=0;layer<loaded.length;layer++)if(loaded\[layer\])context.drawImage(loaded\[layer\],0,0,width,height);});})(i);}
			function updatePreview(){var dir=previewDirections\[previewDirection\],bodyId=checkedValue('body_icon_id'),body=bodyPreviews\[bodyId\];if(body&&previewFlight&&!body.canFlight)previewFlight=false;var pose=previewFlight?'_flight':'',urls=\[body?(body\[dir+pose\]||body\[dir\]):''\],ids=selectedClothing();for(var i=0;i<ids.length;i++){var data=clothingPreviews\[ids\[i\]\];if(data)urls.push(data\[dir+pose\]||data\[dir\]);}var hairId=checkedValue('hair_id'),hair=hairPreviews\[hairId\];if(hair&&document.getElementById('hairSection').style.display!='none')urls.push(hair\[dir+pose\]||hair\[dir\]);composePreview(urls);var flightButton=document.querySelector('.preview-controls button:nth-child(2)'),canFlight=body&&body.canFlight;flightButton.disabled=!canFlight;flightButton.title=canFlight?'Toggle between ground and flight poses':'This body icon has no Flight state';document.getElementById('previewState').textContent=dir.charAt(0).toUpperCase()+dir.slice(1)+' / '+(previewFlight?'Flight':'Ground')+(canFlight?'':' (Flight unavailable)');}
			function rotatePreview(delta){previewDirection=(previewDirection+delta+previewDirections.length)%previewDirections.length;updatePreview();}
			function toggleFlight(){var body=bodyPreviews\[checkedValue('body_icon_id')\];if(!body||!body.canFlight)return;previewFlight=!previewFlight;updatePreview();}
			function updateFrostPreviews(){for(var form=2;form<=5;form++){var select=document.getElementsByName('frost_form_'+form)\[0\],image=document.getElementById('frostPreview'+form);if(!select||!image)continue;var data=bodyPreviews\[select.value\];if(data)image.src=data.south;}}
			function validateStage(){if(currentStage==1&&checkedValue('selected_race')=='Alien'&&parseInt(document.getElementById('alienPoints').textContent)<0){alert('Alien choices can cost at most 100 AP.');return false;}if(currentStage==2&&!document.querySelector('input\[name="character_name"\]').value.trim()){alert('Enter a character name.');return false;}if(currentStage==3&&parseInt(document.getElementById('pointsRemaining').textContent)!=0){alert('Spend every attribute point before continuing.');return false;}return true;}
			function buildReview(){var clothing=selectedClothing().length,alienSpent=100-parseInt(document.getElementById('alienPoints').textContent||100),summary='<h3>'+document.querySelector('input\[name="character_name"\]').value+'</h3><p><b>Lineage:</b> '+checkedValue('selected_race')+' / '+checkedValue('race_trait')+'</p><p><b>Body:</b> '+checkedValue('body_icon_id')+'</p><p><b>Starting clothes:</b> '+clothing+'</p>';if(checkedValue('selected_race')=='Alien')summary+='<p><b>Alien AP spent:</b> '+alienSpent+' / 100</p>';document.getElementById('reviewSummary').innerHTML=summary;}
			function showStage(){var stages=document.querySelectorAll('.wizard-stage'),steps=document.querySelectorAll('.stage-strip span');for(var i=0;i<stages.length;i++)stages\[i\].className='wizard-stage'+(i==currentStage?' active':'');for(var j=0;j<steps.length;j++)steps\[j\].className='hud-tab'+(j==currentStage?' active':'');document.getElementById('stageTitle').textContent=(currentStage+1)+' / 5 - '+stageNames\[currentStage\].toUpperCase();document.getElementById('backButton').style.visibility=currentStage?'visible':'hidden';document.getElementById('nextButton').style.display=currentStage==4?'none':'block';if(currentStage==4)buildReview();}
			function goStage(delta){if(delta>0&&!validateStage())return;currentStage=Math.max(0,Math.min(4,currentStage+delta));showStage();saveCreatorState();}
			function saveCreatorState(){try{var controls=document.querySelectorAll('#creatorForm input,#creatorForm select'),state={stage:currentStage,direction:previewDirection,flight:previewFlight,controls:\[\]};for(var i=0;i<controls.length;i++){var control=controls\[i\];if(control.name=='src'||control.name=='action')continue;state.controls.push({name:control.name||'',clothing:control.getAttribute('data-clothing-id')||'',owner:control.getAttribute('data-owner-race')||'',type:control.type||'',value:control.value,checked:!!control.checked});}sessionStorage.setItem(creatorStorageKey,JSON.stringify(state));}catch(error){}}
			function restoreCreatorState(){try{var raw=sessionStorage.getItem(creatorStorageKey);if(!raw)return false;var state=JSON.parse(raw),controls=document.querySelectorAll('#creatorForm input,#creatorForm select');for(var i=0;i<controls.length;i++){var control=controls\[i\],controlOwner=control.getAttribute('data-owner-race')||'';for(var j=0;j<state.controls.length;j++){var saved=state.controls\[j\],sameOwner=(saved.owner||'')==controlOwner,matches=sameOwner&&((saved.clothing&&saved.clothing==control.getAttribute('data-clothing-id'))||(!saved.clothing&&saved.name&&saved.name==control.name&&((control.type!='radio'&&control.type!='checkbox')||saved.value==control.value)));if(!matches)continue;if(control.type=='radio'||control.type=='checkbox')control.checked=!!saved.checked;else control.value=saved.value;break;}}currentStage=Math.max(0,Math.min(4,parseInt(state.stage||0)));previewDirection=Math.max(0,Math.min(3,parseInt(state.direction||0)));previewFlight=!!state.flight;return true;}catch(error){return false;}}
			function applyPendingCustomSelection(){if(!pendingCustomSelection)return;if(pendingCustomSelection=='body'){var bodies=document.getElementsByName('body_icon_id'),race=checkedValue('selected_race');for(var i=0;i<bodies.length;i++)if(bodies\[i\].value=='custom_body'&&bodies\[i\].getAttribute('data-owner-race')==race){bodies\[i\].checked=true;break;}}else if(pendingCustomSelection.indexOf('clothing_')==0){var clothing=document.querySelector('input\[data-clothing-id="custom_'+pendingCustomSelection+'"\]');if(clothing)clothing.checked=true;}else if(pendingCustomSelection.indexOf('frost_')==0){var form=pendingCustomSelection.split('_')\[1\],select=document.getElementsByName('frost_form_'+form)\[0\];if(select)select.value='custom_frost_'+form;}}
			function syncCreatorUi(){var race=checkedValue('selected_race'),trait=checkedValue('race_trait');setVisible('.icon-panel',race);setVisible('.trait-panel',race);document.getElementById('raceDescription').textContent=descriptions\[race\]||'';document.getElementById('alienOptionPanel').style.display=race=='Alien'?'block':'none';document.getElementById('frostOptionPanel').style.display=race=='Frost Lord'?'block':'none';document.getElementById('genericRaceOptions').style.display=(race!='Alien'&&race!='Frost Lord')?'block':'none';document.getElementById('frostFifthOption').style.display=trait=='frost_cooler'?'grid':'none';updateHairVisibility();updateAlienPoints();updateClothing();updatePoints();updateFrostPreviews();updatePreview();showStage();}
			window.onload=function(){document.body.className='nexus-hud';var races=document.getElementsByName('selected_race');if(races.length){races\[0\].checked=true;selectRace(races\[0\].value);}restoreCreatorState();applyPendingCustomSelection();syncCreatorUi();var form=document.getElementById('creatorForm');if(form)form.onchange=saveCreatorState;};
		"}
		var/hud_css = getNexusHudBrowserCss("bronze")
		page_css = "[hud_css][css]"
		UpdatePage(body, js)
		pending_custom_selection = null
