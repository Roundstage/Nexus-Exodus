mob/NexusSmokeTest/ServerSettingsAdmin
	var/test_admin_level = 4
	AdminLevel()
		return test_admin_level

proc/runServerSettingsPersistenceSmokeTests()
	if(!world.params["nexus_smoke_tests"]) return
	var/list/save_paths = list("Misc", "GAIN", "Year", "Votes", "CustomDecors")
	var/list/existing_paths = list()
	for(var/save_path in save_paths)
		if(fexists(save_path))
			existing_paths += save_path
			nexusSmokeAssert(fcopy(save_path, "data/.server-settings-smoke-[save_path]"), "could not back up server settings fixture")
	var/list/aliases = list("deadzone_pressure_reduces_bp" = "DEADZONE_PRESSURE_ON", "limitbreak_mastery" = "CAN_MASTER_LIMIT_BREAK", "limitbreak_maximum_mastery" = "LIMIT_BREAK_MAX_MASTERY", "limitbreak_minimum_duration" = "LIMIT_BREAK_MIN_DURATION", "limitbreak_maximum_duration" = "LIMIT_BREAK_MAX_DURATION")
	var/list/changes = list(
		"Gain" = 2.5, "Year" = 12.5, "feats_on" = 1,
		"RP_President" = "Server settings smoke", "defaultScreenSize" = 31, "CAN_BREAK_TURFS" = 0,
		"SENSE_SYSTEM_SHOW_STAT_BUILD" = 1, "SENSE_SYSTEM_SHOW_VAGUE_INFO" = 0,
		"battleground_master_bp_mult" = 3.5, "START_WITH_RACIAL_SKILLS" = 0,
		"force_32_pix_movement" = 1, "demon_hell_boost" = 2.5, "kai_heaven_boost" = 2.75,
		"KO_SYSTEM_FULL_HEAL_IN_SPAR" = 0, "speedDelayMultMod" = 1.75, "bp_exponent" = 0.75,
		"one_shot_start" = 6, "global_beam_deflect_mod" = 0.5, "hakai_cooldown" = 125,
		"max_turf_str" = 25, "Gun_Power" = 2.25)
	var/list/original_values = list()
	var/mob/NexusSmokeTest/ServerSettingsAdmin/admin = new
	var/list/categories = getNexusServerSettingCategories()
	for(var/category in categories)
		var/form_path = categories[category]
		var/upForm/model = new form_path(null, admin, list(), TRUE)
		var/list/settings = model.form_vars["admin"]
		for(var/setting_name in settings)
			var/variable_name = aliases[setting_name] || setting_name
			nexusSmokeAssert(variable_name in global.vars, "unknown server setting binding: [setting_name]")
			original_values[variable_name] = global.vars[variable_name]
			if(setting_name in changes)
				nexusSmokeAssert(!model.ProcessVariable("admin", setting_name, "[changes[setting_name]]"), "server setting rejected: [setting_name]")
			else if(islist(settings[setting_name]))
				var/list/changed_list = settings[setting_name]:Copy()
				changed_list += "Server settings smoke"
				model.setFormVar("admin", setting_name, changed_list)
		var/list/expected = settings.Copy()
		// This is the real commit path shared by the HUD panel and legacy forms.
		model.FormSetTempVars("admin")
		del(model)
		var/savefile/misc = new("Misc")
		for(var/setting_name in expected)
			var/variable_name = aliases[setting_name] || setting_name
			if(!(setting_name in list("Gain", "Year", "RP_President")))
				nexusSmokeAssert(variable_name in misc, "server setting is missing from Misc: [setting_name]")
			global.vars[variable_name] = original_values[variable_name]
		misc = null
		// No saveWorld, shutdown hook, or autosave occurs before this reload.
		loadGain()
		loadYear()
		loadVote()
		loadMisc()
		model = new form_path(null, admin, list(), TRUE)
		var/list/reloaded = model.form_vars["admin"]
		for(var/setting_name in expected)
			nexusSmokeAssert(json_encode(reloaded[setting_name]) == json_encode(expected[setting_name]), "server setting reset after reload: [category]/[setting_name]")
		del(model)

	// Explicitly enabled features must survive the defaults migration on reload.
	nexusSmokeAssert(feats_on == 1, "feature defaults overwrote a persisted panel choice")
	var/upForm/combat = new /upForm/admin_combat(null, admin, list(), TRUE)
	combat.ProcessVariable("admin", "speedDelayMultMod", "3.25")
	admin.test_admin_level = 3
	combat.FormSetTempVars("admin")
	nexusSmokeAssert(speedDelayMultMod == 1.75, "revoked admin permissions allowed a settings commit")
	admin.test_admin_level = 4
	nexus_full_wipe_pending = TRUE
	combat.FormSetTempVars("admin")
	nexusSmokeAssert(speedDelayMultMod == 1.75 && !saveNexusServerSettings(), "settings commit bypassed a pending full wipe")
	nexus_full_wipe_pending = FALSE
	del(combat)

	// A pre-fix Misc must leave absent settings at their in-memory defaults.
	var/savefile/legacy = new("Misc")
	legacy.dir.Remove("speedDelayMultMod", "max_turf_str")
	legacy.Flush()
	legacy = null
	speedDelayMultMod = 2.25
	max_turf_str = 30
	loadMisc()
	nexusSmokeAssert(speedDelayMultMod == 2.25 && max_turf_str == 30, "legacy settings without new fields overwrote defaults")

	for(var/variable_name in original_values) global.vars[variable_name] = original_values[variable_name]
	for(var/save_path in save_paths)
		fdel(save_path)
		if(save_path in existing_paths)
			nexusSmokeAssert(fcopy("data/.server-settings-smoke-[save_path]", save_path), "could not restore server settings fixture")
			fdel("data/.server-settings-smoke-[save_path]")
	del(admin)
	world.log << "NEXUS_SERVER_SETTINGS_TESTS_PASSED: six categories, immediate save/reload, legacy fields, lists, permissions and wipe guard"
