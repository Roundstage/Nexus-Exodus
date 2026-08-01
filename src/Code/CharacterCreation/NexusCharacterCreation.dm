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
		"time_freeze" = list("name" = "Time Freeze", "cost" = 25, "description" = "Grants Time Freeze."),
		"limit_breaker" = list("name" = "Limit Breaker", "cost" = 15, "description" = "Grants the Limit Breaker burst."),
		"absorb" = list("name" = "Absorb", "cost" = 20, "description" = "Grants absorption."),
		"precognition" = list("name" = "Precognition", "cost" = 25, "description" = "Enables precognition."),
		"death_regeneration" = list("name" = "Death Regeneration", "cost" = 25, "description" = "Adds 0.5 regeneration."),
		"starting_sp" = list("name" = "Starting SP", "cost" = 10, "description" = "Adds starting skill points."),
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
		"apex_genome" = list("name" = "Apex Genome", "cost" = 50, "description" = "Control-focused Jiren package; disables anger."),
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

proc/nexusValidateFrostFormOptions(list/form_ids, cooler)
	if(!islist(form_ids)) return FALSE
	var/list/options = nexusFrostIconOptions()
	var/required_forms = cooler ? 5 : 4
	for(var/form_index in 1 to required_forms)
		if(!options[form_ids[form_index]]) return FALSE
	return TRUE

proc/nexusValidateStarterClothing(list/selected_ids)
	if(!islist(selected_ids) || selected_ids.len > nexus_starter_clothing_limit) return FALSE
	var/list/options = nexusStarterClothingOptions()
	for(var/clothing_id in selected_ids) if(!options[clothing_id]) return FALSE
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
		if("Bio-Android") traits["bio_adaptation"] = nexusTrait("Adaptive Genome", "Absorption and regeneration drive future evolution.")
		if("Demigod") traits["demigod_heritage"] = nexusTrait("Divine Heritage", "Exceptional potential balanced by slow adaptation.")
		if("Demon") traits["demon_soulbound"] = nexusTrait("Soulbound", "Demonic regeneration and access to Soul Energy.")
		if("Frost Lord")
			traits["frost_heir"] = nexusTrait("Imperial Heir", "Standard Frost Lord transformation lineage.")
			if(cooler_available) traits["frost_cooler"] = nexusTrait("Ascendant Strain", "An exceptionally rare fifth-form lineage.")
		if("Kai") traits["kai_guardian"] = nexusTrait("Guardian", "Mystic energy control, recovery, and afterlife techniques.")
		if("Makyo") traits["makyo_starborn"] = nexusTrait("Starborn", "Power responds strongly to the Makyo Star cycle.")
		if("Majin") traits["majin_fragment"] = nexusTrait("Primal Fragment", "A regenerative fragment descended from primordial Majin matter.")
		if("Namekian") traits["namek_dragon_clan"] = nexusTrait("Dragon Clan", "Regeneration, spiritual techniques, and Namekian fusion.")
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

proc/nexusCreationStatProfile(race_name, trait_id)
	var/profile_id = "[race_name]|[trait_id]"
	if(NEXUS_CREATION_STAT_PROFILES[profile_id]) return NEXUS_CREATION_STAT_PROFILES[profile_id]
	var/mob/NexusCreationPreview/preview = new
	preview.initializeNexusRaceByTrait(race_name, trait_id)
	preview.Points = 44 + preview.RaceBonusStatPoints()
	preview.C = preview
	preview.ApplyRaceBuild()
	var/budget = preview.Points
	var/list/caps = list()
	for(var/stat_id in NEXUS_CREATION_STATS)
		var/stat_name = NEXUS_CREATION_STATS[stat_id]
		var/cap = 0
		if(!(preview.Android && stat_name == "Anger"))
			while(cap < budget && !preview.StatRaceCapped(stat_name))
				preview.raiseNexusCreationStat(stat_name)
				cap++
		caps[stat_id] = cap
	del(preview)
	var/list/profile = list("budget" = budget, "caps" = caps)
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
			if("starting_sp") src.Experience += round(15 * SP_Multiplier ** 0.5)
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

mob/proc/applyNexusAppearance(selected_race, gender_choice, body_icon_id, obj/Hairs/hair_choice, hair_color, list/frost_form_ids)
	if(selected_race in list("Bio-Android", "Namekian", "Android")) src.gender = "male"
	else if(gender_choice == "female") src.gender = "female"
	else src.gender = "male"
	if(!istext(hair_color) || length(hair_color) != 7 || copytext(hair_color, 1, 2) != "#" || !ReadRGB(hair_color)) hair_color = "#2b1b14"

	var/list/icon_options = nexusRaceIconOptions(selected_race)
	var/selected_icon = icon_options[body_icon_id]
	if(!selected_icon)
		for(var/icon_id in icon_options)
			selected_icon = icon_options[icon_id]
			break
	src.icon = selected_icon
	src.base_icon_color = null
	if(selected_race == "Frost Lord")
		var/list/frost_options = nexusFrostIconOptions()
		src.Form1Icon = selected_icon
		if(frost_form_ids)
			src.Form2Icon = frost_options[frost_form_ids[2]]
			src.Form3Icon = frost_options[frost_form_ids[3]]
			src.Form4Icon = frost_options[frost_form_ids[4]]
			if(src.IsCooler) src.Form5Icon = frost_options[frost_form_ids[5]]
	if(selected_race == "Demigod") src.icon += rgb(60,60,60)
	if(src.arm_stretch && src.arm_stretch_icon == 'GenericArm.dmi') src.Auto_color_arm_stretch_icon()

	var/can_have_hair = !(selected_race in list("Majin", "Bio-Android", "Namekian", "Frost Lord"))
	if(selected_race == "Android" && findtext(body_icon_id, "android_human_") != 1) can_have_hair = FALSE
	if(can_have_hair && hair_choice) Apply_Hair(src, hair_choice, hair_color)

mob/proc/applyNexusStarterClothing(list/selected_ids)
	var/list/options = nexusStarterClothingOptions()
	var/priority = 500
	for(var/clothing_id in selected_ids)
		var/clothing_type = options[clothing_id]
		if(!clothing_type) continue
		var/obj/items/Clothes/item = new clothing_type(src)
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

mob/proc/commitNexusCharacter(selected_race, requested_name, gender_choice, alignment_choice, requested_age, race_trait, body_icon_id, obj/Hairs/hair_choice, hair_color, list/stat_allocation, cooler_available, list/alien_options, list/frost_form_ids, list/starter_clothing)
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
	if(!icon_options[body_icon_id]) return FALSE
	if(race_trait == "android_chassis" && findtext(body_icon_id, "android_human_") == 1) return FALSE
	if(race_trait == "android_infiltrator" && findtext(body_icon_id, "android_human_") != 1) return FALSE
	if(selected_race == "Alien" && !nexusValidateAlienOptions(alien_options)) return FALSE
	if(selected_race == "Frost Lord")
		if(!islist(frost_form_ids)) return FALSE
		frost_form_ids[1] = body_icon_id
		if(!nexusValidateFrostFormOptions(frost_form_ids, race_trait == "frost_cooler")) return FALSE
	if(!nexusValidateStarterClothing(starter_clothing)) return FALSE
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
	src.applyNexusAppearance(selected_race, gender_choice, body_icon_id, hair_choice, hair_color, frost_form_ids)
	src.applyNexusStarterClothing(starter_clothing)
	src.name = safe_name
	src.setNexusCharacterAge(requested_age)
	src.Race_Starting_Stats()
	src.Go_to_spawn(First_time = 1, choose_random = 1)
	if(src.formod >= 2 || src.Pow >= 200)
		src.contents += new /obj/Meditate_Level_2
		if(src.max_ki / src.Eff < 1000) src.max_ki *= 2
	if(prob(Cured_Vampire_Ratio() * 100)) src.Former_Vampire = 1
	src.FinishNewCharacterSetup()
	src.stat_version = cur_stat_ver
	src.LoadFeats()
	src.character_made_time = world.realtime
	if(src.Race == "Android" || src.Race == "Majin")
		src.max_ki = energy_cap * src.Eff
		src.Ki = src.max_ki
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

	New(client/owner, datum/host, list/viewers)
		cooler_available = prob(1)
		hair_options = list()
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
		if(player && player.client && !player.playerCharacter)
			spawn() player.ShowNexusLoginPrompt()

	canDisplayForm(client/C)
		. = ..()
		if(!.) return
		var/mob/player = src.getHost()
		if(!player || C.mob != player || player.playerCharacter) return FALSE

	Link(list/href_list, client/C)
		var/mob/player = src.getHost()
		if(!player || C.mob != player || player.playerCharacter) return
		if(href_list["action"] != "create") return
		var/list/stat_allocation = list()
		for(var/stat_id in NEXUS_CREATION_STATS)
			stat_allocation[stat_id] = href_list["stat_[stat_id]"]
		var/obj/Hairs/hair_choice = hair_options[href_list["hair_id"]]
		var/list/alien_options = nexusParseIdList(href_list["alien_options"])
		var/list/frost_form_ids = list(href_list["body_icon_id"], href_list["frost_form_2"], href_list["frost_form_3"], href_list["frost_form_4"], href_list["frost_form_5"])
		var/list/starter_clothing = nexusParseIdList(href_list["clothing_ids"])
		if(player.commitNexusCharacter(href_list["selected_race"], href_list["character_name"], href_list["gender"], href_list["alignment"], href_list["age"], href_list["race_trait"], href_list["body_icon_id"], hair_choice, href_list["hair_color"], stat_allocation, cooler_available, alien_options, frost_form_ids, starter_clothing))
			del(src)
		else
			error_message = "The character could not be created. Review the name, trait, icon, and attribute points."
			RefreshPage()

	GenerateBody()
		var/mob/player = src.getHost()
		if(!player) return
		src.LoadResource('NexusExodus.dmi', "nexus_creator_backdrop.png")
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
				icons_html += "<label class=\"portrait-choice\"><input type=\"radio\" name=\"body_icon_id\" value=\"[icon_id]\" onchange=\"updateAppearance()\"><span><img src=\"[html_encode(icon_alias)]\"></span></label>"
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
				var/profile_budget = profile["budget"]
				var/list/cap_entries = list()
				for(var/stat_id in NEXUS_CREATION_STATS)
					cap_entries += "[stat_id]:[caps[stat_id]]"
				var/cap_text = dd_list2text(cap_entries, ",")
				var/safe_profile_id = nexusJsString("[race_name]|[trait_id]")
				profile_entries += "\"[safe_profile_id]\":{budget:[profile_budget],caps:{[cap_text]}}"
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

		var/frost_select_options = ""
		var/frost_option_index
		for(var/frost_icon_id in nexusFrostIconOptions())
			frost_option_index++
			frost_select_options += "<option value=\"[frost_icon_id]\">Style [frost_option_index]</option>"
		var/frost_options_html = "<div class=\"frost-form-grid\"><label class=\"frost-form-card\"><b>Second Form</b><span class=\"frost-form-preview\"><img id=\"frostPreview2\"></span><select name=\"frost_form_2\" onchange=\"updateFrostPreviews()\">[frost_select_options]</select></label><label class=\"frost-form-card\"><b>Third Form</b><span class=\"frost-form-preview\"><img id=\"frostPreview3\"></span><select name=\"frost_form_3\" onchange=\"updateFrostPreviews()\">[frost_select_options]</select></label><label class=\"frost-form-card\"><b>Final Form</b><span class=\"frost-form-preview\"><img id=\"frostPreview4\"></span><select name=\"frost_form_4\" onchange=\"updateFrostPreviews()\">[frost_select_options]</select></label><label class=\"frost-form-card\" id=\"frostFifthOption\"><b>Fifth Form</b><span class=\"frost-form-preview\"><img id=\"frostPreview5\"></span><select name=\"frost_form_5\" onchange=\"updateFrostPreviews()\">[frost_select_options]</select></label></div>"

		var/clothing_html = ""
		var/list/starter_clothing_options = nexusStarterClothingOptions()
		for(var/clothing_id in starter_clothing_options)
			var/clothing_type = starter_clothing_options[clothing_id]
			var/obj/items/Clothes/clothing = new clothing_type
			var/clothing_flight_state = nexusPreviewIconState(clothing.icon, "Flight")
			var/list/direction_entries = list()
			for(var/direction_name in preview_directions)
				var/direction = preview_directions[direction_name]
				var/clothing_alias = nexusBrowserIconUrl(clothing.icon, clothing.icon_state, direction)
				direction_entries += "[direction_name]:'[nexusJsString(clothing_alias)]'"
				if(clothing_flight_state)
					var/clothing_flight_alias = nexusBrowserIconUrl(clothing.icon, clothing_flight_state, direction)
					direction_entries += "[direction_name]_flight:'[nexusJsString(clothing_flight_alias)]'"
			clothing_preview_entries += "\"[nexusJsString(clothing_id)]\":{[dd_list2text(direction_entries, ",")]}"
			var/clothing_alias = nexusBrowserIconUrl(clothing.icon, clothing.icon_state, SOUTH)
			clothing_html += "<label class=\"clothing-choice\"><input type=\"checkbox\" data-clothing-id=\"[clothing_id]\" onchange=\"updateClothing(this)\"><span><img src=\"[html_encode(clothing_alias)]\"><small>[html_encode(clothing.name)]</small></span></label>"
			del(clothing)

		var/stats_html = ""
		for(var/stat_id in NEXUS_CREATION_STATS)
			var/stat_name = NEXUS_CREATION_STATS[stat_id]
			stats_html += "<div class=\"stat-row\"><span>[stat_name]</span><button type=\"button\" onclick=\"adjustStat('[stat_id]',-1)\">-</button><input id=\"stat_[stat_id]\" name=\"stat_[stat_id]\" value=\"0\" readonly><button type=\"button\" onclick=\"adjustStat('[stat_id]',1)\">+</button></div>"

		var/error_html = error_message ? "<div class=\"form-error\">[html_encode(error_message)]</div>" : ""
		var/age_control = allow_age_choosing ? "<label class=\"field-label\">Age<input name=\"age\" type=\"number\" min=\"0\" max=\"1000\" value=\"18\"></label>" : "<input name=\"age\" type=\"hidden\" value=\"0\">"
		var/alignment_control = "<input name=\"alignment\" type=\"hidden\" value=\"Good\">"
		if(alignment_on) alignment_control = "<div class=\"field-label\">Alignment</div><div class=\"toggle-row\"><label><input type=\"radio\" name=\"alignment\" value=\"Good\" checked><span>Good</span></label><label><input type=\"radio\" name=\"alignment\" value=\"Evil\"><span>Evil</span></label></div>"

		var/body = {"
			<form action="byond://" method="get" id="creatorForm">
				<input type="hidden" name="src" value="\ref[src]"><input type="hidden" name="action" value="create"><input type="hidden" name="alien_options" id="alienOptions"><input type="hidden" name="clothing_ids" id="clothingIds">
				<div class="menu-frame">
					<div class="menu-title"><span>Character Creation</span><em id="stageTitle">1 / 5 - Lineage</em></div>
					<div class="stage-strip"><span data-step="0">Lineage</span><span data-step="1">Race</span><span data-step="2">Appearance</span><span data-step="3">Attributes</span><span data-step="4">Review</span></div>
					<div class="wizard-content">
						<section class="wizard-stage" data-stage="0"><div class="menu-columns stage-lineage"><section class="panel race-menu"><h2>Lineage</h2><div class="race-scroll">[race_list_html]</div></section><section class="panel character-menu wide-panel"><h2>Racial Identity</h2><h3>Trait / Preset</h3>[trait_panels_html]<div id="raceDescription" class="description"></div></section></div></section>
						<section class="wizard-stage" data-stage="1"><section class="panel full-panel"><h2>Racial Specialization</h2><div class="stage-scroll"><div id="alienOptionPanel"><div class="level-strip"><span>Alien Ability Points</span><b id="alienPoints">100</b></div><p>Select any combination costing up to 100 AP. The lineage trait from the previous stage is only a preset and can be customized.</p><div class="option-grid">[alien_options_html]</div></div><div id="frostOptionPanel"><p>Choose every form independently. Fifth Form appears only for the rare Ascendant Strain.</p>[frost_options_html]</div><div id="genericRaceOptions" class="empty-stage">This lineage has no extra creation choices.</div></div></section></section>
						<section class="wizard-stage" data-stage="2"><div class="menu-columns appearance-layout"><section class="panel preview-panel"><h2>Live Preview</h2><div class="preview-shell"><div id="previewStack" class="preview-stack"><img id="previewBody"><div id="previewClothes"></div><img id="previewHair"></div></div><div class="preview-controls"><button type="button" onclick="rotatePreview(-1)">Rotate Left</button><button type="button" onclick="toggleFlight()">Ground / Flight</button><button type="button" onclick="rotatePreview(1)">Rotate Right</button></div><small id="previewState">South / Ground</small></section><section class="panel character-menu"><h2>Identity & Body</h2><div class="stage-scroll"><div class="identity-grid"><label class="field-label wide">Name<input name="character_name" maxlength="49" autocomplete="off" placeholder="Character name"></label>[age_control]</div><div class="toggle-row"><label><input type="radio" name="gender" value="male" checked><span>Male</span></label><label><input type="radio" name="gender" value="female"><span>Female</span></label></div>[alignment_control]<h3>Body</h3>[icon_panels_html]<div id="hairSection"><h3>Hair</h3><div class="hair-grid">[hairs_html]</div><label class="field-label">Hair Color<input name="hair_color" type="color" value="#2b1b14"></label></div></div></section><section class="panel clothing-panel"><h2>Optional Clothing</h2><div class="level-strip"><span>Selected</span><b id="clothingCount">0 / [nexus_starter_clothing_limit]</b></div><div class="clothing-grid">[clothing_html]</div></section></div></section>
						<section class="wizard-stage" data-stage="3"><section class="panel full-panel attributes-menu"><h2>Attributes</h2><div class="level-strip"><span>Points Remaining</span><b id="pointsRemaining">0</b></div><div class="stats staged-stats">[stats_html]</div></section></section>
						<section class="wizard-stage" data-stage="4"><section class="panel full-panel review-panel"><h2>Review</h2><div id="reviewSummary"></div>[error_html]<button class="confirm journey-button" type="submit">Begin Journey</button></section></section>
					</div>
					<div class="wizard-nav"><button id="backButton" type="button" onclick="goStage(-1)">Back</button><button id="nextButton" type="button" onclick="goStage(1)">Next</button></div>
				</div>
			</form>
		"}

		var/css = {"
			*{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:hidden}body{font-family:Georgia,'Times New Roman',serif;color:#f7e4bd;background:#3a241b url('nexus_creator_backdrop.png') center/cover no-repeat}body:before{content:'';position:fixed;inset:0;background:rgba(38,20,15,.48)}input,button{font:inherit}.menu-frame{position:relative;margin:18px auto;width:calc(100% - 36px);height:calc(100vh - 36px);padding:10px;background:linear-gradient(135deg,rgba(80,45,35,.96),rgba(45,25,21,.96));border:2px solid #c5a269;box-shadow:0 0 0 3px #42271e,0 12px 45px #170c09}.menu-title{height:42px;display:flex;align-items:center;justify-content:space-between;padding:0 16px;background:linear-gradient(#654438,#402820);border:1px solid #bb9661;box-shadow:inset 0 0 12px #24120e;text-shadow:1px 2px #1b0d09}.menu-title span{font-size:20px;font-weight:bold}.menu-title em{font-size:11px;letter-spacing:2px;color:#d5b983}.menu-columns{display:grid;grid-template-columns:210px minmax(430px,1fr) 285px;gap:8px;height:calc(100% - 50px);margin-top:8px}.panel{min-width:0;overflow:hidden;background:linear-gradient(145deg,rgba(92,57,46,.94),rgba(58,34,29,.96));border:1px solid #c2a06c;box-shadow:inset 0 0 0 2px #3b221b,inset 0 0 20px rgba(20,8,5,.55)}h2{height:31px;margin:0;padding:6px 10px;background:linear-gradient(90deg,#6f4b3e,#493028);border-bottom:1px solid #c09b65;font-size:14px;text-shadow:1px 1px #1a0b08}h3{font-size:12px;color:#e8c98f;margin:10px 0 5px;border-bottom:1px solid #9b744e;padding-bottom:3px}.race-scroll{height:calc(100% - 31px);overflow:auto;padding:5px}.race-entry{display:block;margin-bottom:3px}.race-entry input{position:absolute;opacity:0}.race-entry span{display:flex;align-items:center;height:43px;padding:3px 7px;border:1px solid transparent;color:#f2dbb5}.race-entry img{width:34px;height:34px;object-fit:contain;image-rendering:pixelated;margin-right:8px;background:#3a201a;border:1px solid #805b40}.race-entry input:checked+span,.race-entry span:hover{background:linear-gradient(90deg,#bc8d4c,#6a4332);border-color:#e5c47f;color:#fff}.race-entry input:checked+span:before{content:'>';margin-right:5px;color:#fff4be}.character-menu{overflow:auto;padding:0 10px 12px}.identity-grid{display:grid;grid-template-columns:1fr 100px;gap:8px;margin-top:8px}.field-label{display:block;font-size:11px;color:#e3c58f;margin:6px 0}.field-label input{display:block;width:100%;margin-top:3px;padding:6px;color:#fff2d7;background:#3c241e;border:1px solid #9d7954;outline:none}.toggle-row{display:flex;gap:5px;margin:6px 0}.toggle-row label{flex:1}.toggle-row input{position:absolute;opacity:0}.toggle-row span{display:block;text-align:center;padding:5px;border:1px solid #8b6748;background:#422921}.toggle-row input:checked+span{background:linear-gradient(#b08450,#765035);border-color:#f0d08d;color:#fff}.icon-panel,.trait-panel{display:none}.portrait-grid{display:grid;grid-template-columns:repeat(8,1fr);gap:4px;max-height:112px;overflow:auto;padding:4px;background:rgba(42,23,18,.45)}.portrait-choice input,.hair-choice input,.trait-choice input{position:absolute;opacity:0}.portrait-choice span,.hair-choice span{display:flex;align-items:center;justify-content:center;height:48px;background:#42271f;border:1px solid #7f5b40}.portrait-choice img,.hair-choice img{max-width:44px;max-height:44px;image-rendering:pixelated}.portrait-choice input:checked+span,.hair-choice input:checked+span{border:2px solid #f0d48d;background:#7a5034;box-shadow:0 0 7px #e0b66a}.trait-choice{display:block;margin:4px 0}.trait-choice span{display:block;padding:6px 8px;background:rgba(57,32,26,.78);border:1px solid #7e5b43}.trait-choice b,.trait-choice small{display:block}.trait-choice b{font-size:12px;color:#f0d59d}.trait-choice small{font:10px Arial,sans-serif;color:#d4bfa3;margin-top:2px}.trait-choice input:checked+span{background:linear-gradient(90deg,#9d7143,#5b392c);border-color:#e3c47f}.hair-grid{display:grid;grid-template-columns:repeat(10,1fr);gap:3px;max-height:105px;overflow:auto}.hair-choice span{height:42px;font-size:10px}.description{font:11px Arial,sans-serif;color:#ead7b9;margin-top:8px;padding:7px;background:rgba(40,21,17,.55);border-left:3px solid #d0a867}.attributes-menu{padding:0 9px 10px}.level-strip{display:flex;justify-content:space-between;margin:8px 0;padding:7px 9px;background:#3e251e;border:1px solid #936c49;color:#e9cd99}.level-strip b{color:#fff6c5}.stats{border-top:1px solid #95704d}.stat-row{display:grid;grid-template-columns:1fr 28px 38px 28px;align-items:center;min-height:36px;border-bottom:1px solid rgba(195,157,103,.34);font-size:12px}.stat-row button{height:25px;border:1px solid #9d764e;background:#5b3829;color:#f5dfb9;cursor:pointer}.stat-row input{width:34px;text-align:center;border:0;background:transparent;color:#fff6c8;font-weight:bold}.form-error{margin:8px 0;padding:7px;background:#6d2d28;border:1px solid #d98a70;font:11px Arial,sans-serif}.confirm{width:100%;margin-top:10px;padding:9px;border:1px solid #f0d28e;background:linear-gradient(#b6884e,#70452e);color:#fff7d7;font-weight:bold;text-shadow:1px 1px #2d170f;cursor:pointer}.confirm:hover{background:linear-gradient(#c99b59,#815239)}@media(max-width:900px){.menu-columns{grid-template-columns:170px 1fr}.attributes-menu{grid-column:1/3;max-height:270px;overflow:auto}.menu-frame{height:auto;min-height:calc(100vh - 20px);margin:10px}.menu-columns{height:auto}html,body{overflow:auto}}
		"}
		css += {"
			.stage-strip{height:34px;display:flex;gap:4px;margin-top:8px}.stage-strip span{flex:1;text-align:center;padding:8px 4px;background:#3d2821;border:1px solid #76563d;font-size:11px;color:#a98c68}.stage-strip span.active{background:#88603e;color:#fff1ce;border-color:#d0ac70}.wizard-content{height:calc(100% - 126px);margin-top:8px}.wizard-stage{display:none;height:100%}.wizard-stage.active{display:block}.wizard-stage .menu-columns{height:100%;margin-top:0}.stage-lineage{grid-template-columns:250px 1fr}.wide-panel{grid-column:span 2}.full-panel{height:100%}.stage-scroll{height:calc(100% - 31px);overflow:auto;padding:12px}.wizard-nav{height:42px;display:flex;justify-content:space-between;align-items:end}.wizard-nav button,.preview-controls button{padding:7px 14px;color:#f7e4bd;background:#5e3e31;border:1px solid #b98e58}.wizard-nav button:hover,.preview-controls button:hover{background:#80583f}.option-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:6px}.option-card input,.clothing-choice input{position:absolute;opacity:0}.option-card span{display:block;min-height:68px;padding:8px;background:#3a261f;border:1px solid #725038}.option-card input:checked+span{background:#694a35;border-color:#e0bd76;box-shadow:inset 0 0 10px #26140e}.option-card b{display:flex;justify-content:space-between}.option-card em{font-size:10px;color:#e7c371}.option-card small{display:block;margin-top:5px;color:#cbb99b}.frost-form-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px}.frost-form-grid label{display:flex;flex-direction:column;gap:4px}.frost-form-grid select{background:#2d1d18;color:#f3dfba;border:1px solid #94704b;padding:7px}.empty-stage{padding:30px;text-align:center;color:#bca98d}.appearance-layout{grid-template-columns:260px minmax(360px,1fr) 300px}.preview-panel{text-align:center}.preview-shell{height:360px;display:flex;align-items:center;justify-content:center;background:radial-gradient(circle,#574237,#211613 70%);border-bottom:1px solid #8f6a45}.preview-stack{position:relative;width:192px;height:256px;transform:scale(2);transform-origin:center}.preview-stack img,.preview-stack #previewClothes img{position:absolute;inset:0;margin:auto;width:auto;height:auto;image-rendering:pixelated}.preview-controls{display:flex;justify-content:center;gap:4px;padding:12px 4px}.preview-controls button{font-size:10px;padding:6px}.clothing-grid{height:calc(100% - 66px);overflow:auto;display:grid;grid-template-columns:repeat(3,1fr);gap:4px;padding:6px}.clothing-choice span{display:flex;min-height:72px;flex-direction:column;align-items:center;justify-content:center;padding:3px;background:#36231d;border:1px solid #654633;text-align:center}.clothing-choice input:checked+span{background:#725039;border-color:#dfbd79}.clothing-choice img{width:42px;height:42px;object-fit:contain;image-rendering:pixelated}.clothing-choice small{font-size:9px}.staged-stats{display:grid;grid-template-columns:1fr 1fr;gap:6px 18px;max-width:760px;margin:18px auto}.review-panel{padding-bottom:20px}.review-panel #reviewSummary{margin:25px auto;max-width:720px;padding:20px;background:#33221d;border:1px solid #9b754f;line-height:1.8}.journey-button{display:block;margin:20px auto;width:280px}.form-error{max-width:720px;margin:10px auto}.character-menu .stage-scroll{overflow:auto}@media(max-width:900px){.appearance-layout{grid-template-columns:210px 1fr}.clothing-panel{grid-column:span 2}.option-grid{grid-template-columns:1fr 1fr}}
		"}
		css += {"
			.preview-shell{overflow:hidden}.preview-stack{width:192px;height:192px;transform:none;pointer-events:none}.preview-stack>img,#previewClothes,#previewClothes>img{position:absolute;top:0;right:0;bottom:0;left:0;width:192px;height:192px;margin:auto;object-fit:contain;image-rendering:pixelated;pointer-events:none}.preview-controls{position:relative;z-index:2}.preview-controls button:disabled{opacity:.45;cursor:not-allowed}.frost-form-card{display:grid!important;grid-template-columns:96px 1fr;grid-template-rows:auto 1fr;gap:5px 10px;padding:8px;background:#38251f;border:1px solid #76523b}.frost-form-card>b{grid-column:1 / 3}.frost-form-preview{grid-row:2;display:flex;align-items:center;justify-content:center;width:96px;height:96px;background:radial-gradient(circle,#5b4438,#211613);border:1px solid #806044}.frost-form-preview img{width:88px;height:88px;object-fit:contain;image-rendering:pixelated}.frost-form-card select{align-self:center;min-width:0}
		"}

		var/js = {"
			var profiles={[dd_list2text(profile_entries, ",")]};
			var statIds=\['energy','strength','endurance','speed','force','resistance','offense','defense','regeneration','recovery','anger'\];
			var descriptions={[dd_list2text(description_entries, ",")]};
			var bodyPreviews={[dd_list2text(body_preview_entries, ",")]};
			var hairPreviews={[dd_list2text(hair_preview_entries, ",")]};
			var clothingPreviews={[dd_list2text(clothing_preview_entries, ",")]};
			var alienPresets={[dd_list2text(alien_preset_entries, ",")]};
			var stageNames=\['Lineage','Race Specialization','Appearance','Attributes','Review'\],currentStage=0,previewDirections=\['south','west','north','east'\],previewDirection=0,previewFlight=false;
			function checkedValue(name){var nodes=document.getElementsByName(name);for(var i=0;i<nodes.length;i++){if(nodes\[i\].checked)return nodes\[i\].value;}return '';}
			function setVisible(selector,race){var nodes=document.querySelectorAll(selector);for(var i=0;i<nodes.length;i++){nodes\[i\].style.display=nodes\[i\].getAttribute('data-race')==race?'block':'none';}}
			function selectFirst(selector,race){var box=document.querySelector(selector+'\[data-race="'+race+'"\]');if(!box)return;var input=box.querySelector('input');if(input)input.checked=true;}
			function selectRace(race){setVisible('.icon-panel',race);setVisible('.trait-panel',race);var allIcons=document.getElementsByName('body_icon_id');for(var i=0;i<allIcons.length;i++)allIcons\[i\].checked=false;var allTraits=document.getElementsByName('race_trait');for(var j=0;j<allTraits.length;j++)allTraits\[j\].checked=false;selectFirst('.icon-panel',race);selectFirst('.trait-panel',race);document.getElementById('raceDescription').textContent=descriptions\[race\]||'';document.getElementById('alienOptionPanel').style.display=race=='Alien'?'block':'none';document.getElementById('frostOptionPanel').style.display=race=='Frost Lord'?'block':'none';document.getElementById('genericRaceOptions').style.display=(race!='Alien'&&race!='Frost Lord')?'block':'none';traitChanged();}
			function currentProfile(){return profiles\[checkedValue('selected_race')+'|'+checkedValue('race_trait')\];}
			function traitChanged(){var race=checkedValue('selected_race'),trait=checkedValue('race_trait');if(race=='Android'){var panel=document.querySelector('.icon-panel\[data-race="Android"\]'),icons=panel?panel.getElementsByTagName('input'):null,wantHuman=trait=='android_infiltrator';if(icons){for(var i=0;i<icons.length;i++){var isHuman=icons\[i\].value.indexOf('android_human_')===0;if((wantHuman&&isHuman)||(!wantHuman&&!isHuman)){icons\[i\].checked=true;break;}}}}if(race=='Alien')applyAlienPreset(trait);document.getElementById('frostFifthOption').style.display=trait=='frost_cooler'?'grid':'none';resetStats();updateAppearance();updateFrostPreviews();}
			function updateHairVisibility(){var race=checkedValue('selected_race'),icon=checkedValue('body_icon_id'),hidden='|Majin|Bio-Android|Namekian|Frost Lord|'.indexOf('|'+race+'|')>=0||(race=='Android'&&icon.indexOf('android_human_')!==0);document.getElementById('hairSection').style.display=hidden?'none':'block';if(hidden){var none=document.querySelector('input\[name="hair_id"\]\[value="none"\]');if(none)none.checked=true;}}
			function updatePoints(){var profile=currentProfile();if(!profile)return;var used=0;for(var i=0;i<statIds.length;i++)used+=parseInt(document.getElementById('stat_'+statIds\[i\]).value||0);document.getElementById('pointsRemaining').innerHTML=profile.budget-used;}
			function resetStats(){var profile=currentProfile();if(!profile)return;for(var i=0;i<statIds.length;i++)document.getElementById('stat_'+statIds\[i\]).value=0;updatePoints();}
			function adjustStat(id,delta){var profile=currentProfile();if(!profile)return;var input=document.getElementById('stat_'+id),value=parseInt(input.value||0),remaining=parseInt(document.getElementById('pointsRemaining').innerHTML||0);if(delta>0&&remaining>0&&value<profile.caps\[id\])input.value=value+1;if(delta<0&&value>0)input.value=value-1;updatePoints();}
			function applyAlienPreset(trait){var wanted=alienPresets\[trait\]||\[\],nodes=document.querySelectorAll('\[data-alien-option\]');for(var i=0;i<nodes.length;i++)nodes\[i\].checked=wanted.indexOf(nodes\[i\].getAttribute('data-alien-option'))>=0;updateAlienPoints();}
			function updateAlienPoints(){var nodes=document.querySelectorAll('\[data-alien-option\]'),used=0,ids=\[\];for(var i=0;i<nodes.length;i++){if(nodes\[i\].checked){used+=parseInt(nodes\[i\].getAttribute('data-cost')||0);ids.push(nodes\[i\].getAttribute('data-alien-option'));}}document.getElementById('alienPoints').textContent=100-used;document.getElementById('alienPoints').style.color=used>100?'#ff7777':'';document.getElementById('alienOptions').value=ids.join(',');}
			function selectedClothing(){var nodes=document.querySelectorAll('\[data-clothing-id\]'),ids=\[\];for(var i=0;i<nodes.length;i++)if(nodes\[i\].checked)ids.push(nodes\[i\].getAttribute('data-clothing-id'));return ids;}
			function updateClothing(changed){var ids=selectedClothing();if(ids.length>[nexus_starter_clothing_limit]&&changed){changed.checked=false;ids=selectedClothing();}document.getElementById('clothingIds').value=ids.join(',');document.getElementById('clothingCount').textContent=ids.length+' / [nexus_starter_clothing_limit]';updatePreview();}
			function updateAppearance(){updateHairVisibility();updatePreview();}
			function updatePreview(){var dir=previewDirections\[previewDirection\],bodyId=checkedValue('body_icon_id'),body=bodyPreviews\[bodyId\],bodyImg=document.getElementById('previewBody');if(body&&previewFlight&&!body.canFlight)previewFlight=false;var pose=previewFlight?'_flight':'';if(body)bodyImg.src=body\[dir+pose\]||body\[dir\];var hairId=checkedValue('hair_id'),hair=hairPreviews\[hairId\],hairImg=document.getElementById('previewHair');if(hair&&document.getElementById('hairSection').style.display!='none'){hairImg.src=hair\[dir+pose\]||hair\[dir\];hairImg.style.display='block';}else hairImg.style.display='none';var clothes=document.getElementById('previewClothes');clothes.innerHTML='';var ids=selectedClothing();for(var i=0;i<ids.length;i++){var data=clothingPreviews\[ids\[i\]\];if(!data)continue;var img=document.createElement('img');img.src=data\[dir+pose\]||data\[dir\];clothes.appendChild(img);}var flightButton=document.querySelector('.preview-controls button:nth-child(2)'),canFlight=body&&body.canFlight;flightButton.disabled=!canFlight;flightButton.title=canFlight?'Toggle between ground and flight poses':'This body icon has no Flight state';document.getElementById('previewState').textContent=dir.charAt(0).toUpperCase()+dir.slice(1)+' / '+(previewFlight?'Flight':'Ground')+(canFlight?'':' (Flight unavailable)');}
			function rotatePreview(delta){previewDirection=(previewDirection+delta+previewDirections.length)%previewDirections.length;updatePreview();}
			function toggleFlight(){var body=bodyPreviews\[checkedValue('body_icon_id')\];if(!body||!body.canFlight)return;previewFlight=!previewFlight;updatePreview();}
			function updateFrostPreviews(){for(var form=2;form<=5;form++){var select=document.getElementsByName('frost_form_'+form)\[0\],image=document.getElementById('frostPreview'+form);if(!select||!image)continue;var data=bodyPreviews\[select.value\];if(data)image.src=data.south;}}
			function validateStage(){if(currentStage==1&&checkedValue('selected_race')=='Alien'&&parseInt(document.getElementById('alienPoints').textContent)<0){alert('Alien choices can cost at most 100 AP.');return false;}if(currentStage==2&&!document.querySelector('input\[name="character_name"\]').value.trim()){alert('Enter a character name.');return false;}if(currentStage==3&&parseInt(document.getElementById('pointsRemaining').textContent)!=0){alert('Spend every attribute point before continuing.');return false;}return true;}
			function buildReview(){var clothing=selectedClothing().length,alienSpent=100-parseInt(document.getElementById('alienPoints').textContent||100),summary='<h3>'+document.querySelector('input\[name="character_name"\]').value+'</h3><p><b>Lineage:</b> '+checkedValue('selected_race')+' / '+checkedValue('race_trait')+'</p><p><b>Body:</b> '+checkedValue('body_icon_id')+'</p><p><b>Starting clothes:</b> '+clothing+'</p>';if(checkedValue('selected_race')=='Alien')summary+='<p><b>Alien AP spent:</b> '+alienSpent+' / 100</p>';document.getElementById('reviewSummary').innerHTML=summary;}
			function showStage(){var stages=document.querySelectorAll('.wizard-stage'),steps=document.querySelectorAll('.stage-strip span');for(var i=0;i<stages.length;i++)stages\[i\].className='wizard-stage'+(i==currentStage?' active':'');for(var j=0;j<steps.length;j++)steps\[j\].className=j==currentStage?'active':'';document.getElementById('stageTitle').textContent=(currentStage+1)+' / 5 - '+stageNames\[currentStage\];document.getElementById('backButton').style.visibility=currentStage?'visible':'hidden';document.getElementById('nextButton').style.display=currentStage==4?'none':'block';if(currentStage==4)buildReview();}
			function goStage(delta){if(delta>0&&!validateStage())return;currentStage=Math.max(0,Math.min(4,currentStage+delta));showStage();}
			window.onload=function(){var races=document.getElementsByName('selected_race');if(races.length){races\[0\].checked=true;selectRace(races\[0\].value);}updateClothing();showStage();};
		"}
		page_css = "[css][getNexusRpgBrowserCss()]"
		UpdatePage(body, js)
