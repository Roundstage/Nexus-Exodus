#define NEXUS_LANGUAGE_VERSION 1
#define NEXUS_LANGUAGE_REPEAT_DELAY 600

datum/NexusLanguage
	var
		id
		name
		difficulty = 1
		list/syllables = list("ka", "ra", "ta", "en")

	New(new_id, new_name, new_difficulty, list/new_syllables)
		id = new_id
		name = new_name
		difficulty = max(0.1, new_difficulty)
		if(islist(new_syllables) && new_syllables.len) syllables = new_syllables.Copy()

var/list/nexus_language_catalog

proc/initializeNexusLanguageCatalog()
	if(islist(nexus_language_catalog) && nexus_language_catalog.len) return
	nexus_language_catalog = list()
	nexus_language_catalog["common"] = new /datum/NexusLanguage("common", "Common", 1, list("ta", "na", "ri", "ko", "se", "va"))
	nexus_language_catalog["earth"] = new /datum/NexusLanguage("earth", "Earthling", 1.5, list("al", "ter", "mon", "ri", "en", "us"))
	nexus_language_catalog["saiyan"] = new /datum/NexusLanguage("saiyan", "Saiyan", 1, list("ka", "ra", "to", "ba", "za", "gor"))
	nexus_language_catalog["namekian"] = new /datum/NexusLanguage("namekian", "Namekian", 3, list("na", "mek", "po", "ru", "den", "sa"))
	nexus_language_catalog["demonic"] = new /datum/NexusLanguage("demonic", "Demonic", 5, list("gra", "zul", "vak", "esh", "mor", "dra"))
	nexus_language_catalog["old_tongue"] = new /datum/NexusLanguage("old_tongue", "Old Tongue", 15, list("ae", "thar", "iel", "or", "uun", "keth"))
	nexus_language_catalog["kai"] = new /datum/NexusLanguage("kai", "Kaian", 5, list("shin", "kai", "ora", "sei", "lum", "io"))
	nexus_language_catalog["yardrat"] = new /datum/NexusLanguage("yardrat", "Yardratian", 4, list("yar", "dra", "ti", "vo", "zen", "pol"))
	nexus_language_catalog["arconian"] = new /datum/NexusLanguage("arconian", "Arconian", 2, list("ar", "con", "ia", "vek", "sol", "tri"))
	nexus_language_catalog["heran"] = new /datum/NexusLanguage("heran", "Heran", 1.5, list("he", "ran", "vo", "shi", "kal", "er"))
	nexus_language_catalog["kanassan"] = new /datum/NexusLanguage("kanassan", "Kanassan", 3, list("ka", "nas", "san", "ori", "vek", "tu"))
	nexus_language_catalog["tsufurian"] = new /datum/NexusLanguage("tsufurian", "Tsufurian", 3, list("tsu", "fur", "jin", "tek", "li", "on"))
	nexus_language_catalog["viltrumite"] = new /datum/NexusLanguage("viltrumite", "Viltrumite", 2, list("vil", "trum", "tha", "rag", "vek", "nar"))
	nexus_language_catalog["machine"] = new /datum/NexusLanguage("machine", "Machine Code", 20, list("01", "10", "7f", "a0", "sys", "bit"))

proc/getNexusLanguageDefinition(language_id)
	initializeNexusLanguageCatalog()
	return nexus_language_catalog[language_id]

proc/getNexusLanguageDisplayName(language_id, mob/owner)
	if(owner && owner.custom_language_id == language_id && owner.custom_language_name) return owner.custom_language_name
	if(owner && islist(owner.learned_language_names) && owner.learned_language_names[language_id]) return owner.learned_language_names[language_id]
	var/datum/NexusLanguage/language = getNexusLanguageDefinition(language_id)
	return language ? language.name : "Unknown Language"

proc/getNexusLanguageDifficulty(language_id, mob/owner)
	if(owner && owner.custom_language_id == language_id) return 10
	var/datum/NexusLanguage/language = getNexusLanguageDefinition(language_id)
	return language ? language.difficulty : 10

proc/getNexusLanguageSyllables(language_id)
	var/datum/NexusLanguage/language = getNexusLanguageDefinition(language_id)
	if(language) return language.syllables
	return list("ae", "ka", "ri", "zul", "en", "tor")

proc/getNexusHexValue(character)
	var/position = findtext("0123456789abcdef", lowertext(character))
	return max(0, position - 1)

proc/getNexusLanguageWordScore(word, language_id)
	var/hash = md5("[language_id]|[lowertext(word)]")
	return ((getNexusHexValue(copytext(hash, 1, 2)) * 16) + getNexusHexValue(copytext(hash, 2, 3))) / 255 * 100

proc/cipherNexusLanguageWord(word, language_id)
	if(!length(word)) return word
	var/ending = ""
	var/last_character = copytext(word, length(word), 0)
	if(last_character in list(".", ",", "!", "?", ";", ":"))
		ending = last_character
		word = copytext(word, 1, length(word))
	if(!length(word)) return ending
	var/list/syllables = getNexusLanguageSyllables(language_id)
	var/hash = md5("cipher|[language_id]|[lowertext(word)]")
	var/syllable_count = Clamp(round(length(word) / 3), 1, 4)
	var/result = ""
	for(var/index = 1, index <= syllable_count, index++)
		var/hash_position = ((index - 1) % 30) + 1
		var/value = getNexusHexValue(copytext(hash, hash_position, hash_position + 1))
		result += syllables[(value % syllables.len) + 1]
	var/first_character = copytext(word, 1, 2)
	if(first_character == uppertext(first_character)) result = "[uppertext(copytext(result, 1, 2))][copytext(result, 2)]"
	return "[result][ending]"

proc/renderNexusLanguageText(raw_text, language_id, understanding)
	understanding = Clamp(understanding, 0, 100)
	if(understanding >= 100) return raw_text
	var/list/words = Text_2_List("[raw_text]", " ")
	var/list/rendered_words = list()
	for(var/word in words)
		if(getNexusLanguageWordScore(word, language_id) <= understanding) rendered_words += word
		else rendered_words += cipherNexusLanguageWord(word, language_id)
	return List_2_Text(rendered_words, " ")

mob/var
	list/known_languages = list()
	list/learned_language_names = list()
	spoken_language = null
	language_system_version = 0
	custom_language_id = null
	custom_language_name = null
	language_teach_cooldown = 0
	tmp/list/language_exposure_cooldowns = list()

mob/proc/addStartingLanguage(language_id, mastery = 100)
	if(!islist(known_languages)) known_languages = list()
	if(!islist(learned_language_names)) learned_language_names = list()
	known_languages[language_id] = max(text2num("[known_languages[language_id]]"), mastery)
	if(!spoken_language) spoken_language = language_id

mob/proc/getKnownLanguageMastery(language_id)
	if(!islist(known_languages)) known_languages = list()
	var/mastery = text2num("[known_languages[language_id]]")
	return Clamp(mastery, 0, 100)

mob/proc/assignRacialLanguages()
	switch(Race)
		if("Android", "Bio-Android")
			addStartingLanguage("machine")
			addStartingLanguage("common")
		if("Human") addStartingLanguage("earth")
		if("Saiyan") addStartingLanguage("saiyan")
		if("Half Saiyan")
			addStartingLanguage("saiyan")
			addStartingLanguage("earth")
		if("Viltrumite") addStartingLanguage("viltrumite")
		if("Half-Viltrumite")
			addStartingLanguage("viltrumite")
			addStartingLanguage("earth")
		if("Namekian") addStartingLanguage("namekian")
		if("Demon")
			addStartingLanguage("demonic")
			addStartingLanguage("old_tongue")
		if("Majin") addStartingLanguage("demonic")
		if("Kai")
			addStartingLanguage("kai")
			addStartingLanguage("old_tongue")
		if("Makyo")
			addStartingLanguage("demonic")
			addStartingLanguage("arconian")
		if("Heran") addStartingLanguage("heran")
		if("Kanassan") addStartingLanguage("kanassan")
		if("Tsujin")
			addStartingLanguage("tsufurian")
			addStartingLanguage("saiyan")
		if("Yardrat") addStartingLanguage("yardrat")
		if("Alien") addStartingLanguage("arconian")
		else addStartingLanguage("common")

mob/proc/syncNexusLanguages(silent = TRUE)
	initializeNexusLanguageCatalog()
	if(!islist(known_languages)) known_languages = list()
	if(language_system_version < NEXUS_LANGUAGE_VERSION || !known_languages.len)
		assignRacialLanguages()
		language_system_version = NEXUS_LANGUAGE_VERSION
		if(!silent) src << "Your racial languages have been restored. Use Languages in the Other tab to manage them."
	if(custom_language_id && custom_language_name) known_languages[custom_language_id] = max(100, getKnownLanguageMastery(custom_language_id))
	if(!spoken_language || !getKnownLanguageMastery(spoken_language))
		for(var/language_id in known_languages)
			spoken_language = language_id
			break
	return spoken_language

mob/proc/getLanguageLearningMultiplier()
	return 1 + getMilestoneRank("language_savant") * 0.25

mob/proc/improveNexusLanguage(language_id, raw_amount, mob/source_speaker)
	if(!language_id || raw_amount <= 0 || source_speaker == src) return 0
	syncNexusLanguages()
	var/difficulty = getNexusLanguageDifficulty(language_id, source_speaker)
	var/gained = raw_amount / max(1, difficulty) * getLanguageLearningMultiplier()
	var/old_mastery = getKnownLanguageMastery(language_id)
	if(old_mastery >= 100) return 0
	var/new_mastery = min(100, old_mastery + gained)
	known_languages[language_id] = new_mastery
	var/language_name = getNexusLanguageDisplayName(language_id, source_speaker)
	if(language_name && language_name != "Unknown Language") learned_language_names[language_id] = language_name
	if(!old_mastery)
		src << "<font color=#8ed7ff>You begin to recognize [getNexusLanguageDisplayName(language_id, source_speaker)]."
	if(new_mastery >= 100 && old_mastery < 100)
		src << "<font color=#8ed7ff>You have mastered [getNexusLanguageDisplayName(language_id, source_speaker)]."
	return new_mastery - old_mastery

mob/proc/canGainLanguageExposure(mob/speaker, language_id, raw_text)
	if(!speaker || speaker == src || !client) return FALSE
	if(!islist(language_exposure_cooldowns)) language_exposure_cooldowns = list()
	if(language_exposure_cooldowns.len > 80) language_exposure_cooldowns = list()
	var/exposure_key = "[ckey(speaker.key)]|[language_id]|[md5(lowertext(raw_text))]"
	var/last_exposure = text2num("[language_exposure_cooldowns[exposure_key]]")
	if(last_exposure && world.time - last_exposure < NEXUS_LANGUAGE_REPEAT_DELAY) return FALSE
	language_exposure_cooldowns[exposure_key] = world.time
	return TRUE

mob/proc/hasLanguageTranslationDevice(as_speaker = FALSE)
	if(locate(/obj/items/UniversalTranslator) in item_list) return TRUE
	if(!as_speaker && locate(/obj/items/StoneOfUnderstanding) in item_list) return TRUE
	if(!as_speaker && locate(/obj/items/PhilosophersStone) in item_list) return TRUE
	return FALSE

mob/proc/renderSpokenLanguageFor(mob/listener, raw_text, allow_learning = TRUE)
	syncNexusLanguages()
	if(!listener) return raw_text
	listener.syncNexusLanguages()
	var/speaker_mastery = getKnownLanguageMastery(spoken_language)
	var/listener_mastery = listener.getKnownLanguageMastery(spoken_language)
	if(hasLanguageTranslationDevice(as_speaker = TRUE) || listener.hasLanguageTranslationDevice()) listener_mastery = 100
	var/understanding = min(speaker_mastery, listener_mastery)
	if(allow_learning && listener.canGainLanguageExposure(src, spoken_language, raw_text))
		var/word_count = countNexusWords(raw_text)
		listener.improveNexusLanguage(spoken_language, min(1.5, 0.08 * word_count), src)
	return renderNexusLanguageText(raw_text, spoken_language, understanding)

mob/proc/getPublicSpokenLanguageText(raw_text)
	syncNexusLanguages()
	if(spoken_language == "common" || hasLanguageTranslationDevice(as_speaker = TRUE)) return raw_text
	return renderNexusLanguageText(raw_text, spoken_language, 0)

mob/proc/formatNexusSpokenMessage(mob/listener, raw_text, speech_verb = "says")
	var/language_name = getNexusLanguageDisplayName(spoken_language, src)
	var/rendered_text = renderSpokenLanguageFor(listener, raw_text)
	return "<span style='font-size:10pt;color:[TextColor];font-family:Walk The Moon'><b>\[[html_encode(language_name)]\]</b> [html_encode(name)] [speech_verb], [html_encode(rendered_text)]</span>"

mob/proc/teachNexusLanguage()
	syncNexusLanguages()
	if(world.realtime < language_teach_cooldown)
		src << "You need more time before teaching another language lesson."
		return
	var/list/language_options = list("Cancel")
	var/list/id_by_label = list()
	for(var/language_id in known_languages)
		var/mastery = getKnownLanguageMastery(language_id)
		if(mastery < 50) continue
		var/label = "[getNexusLanguageDisplayName(language_id, src)] ([round(mastery)]%)"
		language_options += label
		id_by_label[label] = language_id
	var/language_choice = input(src, "Which language do you want to teach?", "Language Lesson") in language_options
	if(!language_choice || language_choice == "Cancel") return
	var/list/targets = list("Cancel")
	for(var/mob/target in oview(5, src)) if(target.client) targets += target
	var/mob/student = input(src, "Teach [language_choice] to whom?", "Language Lesson") in targets
	if(!student || student == "Cancel") return
	var/language_id = id_by_label[language_choice]
	student.improveNexusLanguage(language_id, 25, src)
	language_teach_cooldown = world.realtime + 3000
	player_view(8, src) << "[src] gives [student] a lesson in [getNexusLanguageDisplayName(language_id, src)]."

mob/proc/createCustomNexusLanguage()
	if(!getMilestoneRank("custom_language"))
		src << "Unlock Custom Language in the Milestone tree first."
		return FALSE
	if(custom_language_id)
		src << "You have already created [custom_language_name]."
		return FALSE
	var/new_name = input(src, "Name your custom language. Keep the name setting-appropriate.", "Custom Language") as text|null
	new_name = copytext("[new_name]", 1, 33)
	if(!length(new_name)) return FALSE
	custom_language_name = new_name
	custom_language_id = "custom_[ckey(key)]_[copytext(md5(lowertext(new_name)), 1, 9)]"
	known_languages[custom_language_id] = 100
	learned_language_names[custom_language_id] = custom_language_name
	spoken_language = custom_language_id
	src << "You establish [custom_language_name] as a language and begin speaking it."
	return TRUE

mob/verb/languages()
	set name = "Languages"
	set category = "Other"
	syncNexusLanguages(silent = FALSE)
	var/list/options = list("Cancel", "Teach a Language")
	if(getMilestoneRank("custom_language") && !custom_language_id) options += "Create Custom Language"
	var/list/id_by_label = list()
	for(var/language_id in known_languages)
		var/label = "Speak [getNexusLanguageDisplayName(language_id, src)] ([round(getKnownLanguageMastery(language_id), 0.1)]%)"
		options += label
		id_by_label[label] = language_id
	var/choice = input(src, "Currently speaking [getNexusLanguageDisplayName(spoken_language, src)].", "Languages") in options
	if(!choice || choice == "Cancel") return
	if(choice == "Teach a Language")
		teachNexusLanguage()
		return
	if(choice == "Create Custom Language")
		createCustomNexusLanguage()
		return
	var/language_id = id_by_label[choice]
	if(language_id)
		spoken_language = language_id
		src << "You will now speak [getNexusLanguageDisplayName(language_id, src)]."

#undef NEXUS_LANGUAGE_REPEAT_DELAY
