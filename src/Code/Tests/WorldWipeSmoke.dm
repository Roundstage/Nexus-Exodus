proc/runWorldWipeSmokeTests()
	for(var/environment in list("live", "playtest"))
		var/runtime_root = "data/.wipe-smoke/[environment]/"
		var/character_path = "[getNexusCharacterSaveRoot(environment)]/old-slot1.sav"
		var/feat_path = "[getNexusFeatSaveRoot(environment)]/old-slot1.sav"
		var/list/deleted_paths = list(
			"Year", "Hero", "Ranks", "Jobs", "STORY", "CustomDecors",
			"DBZ Character Saves/old.sav", character_path, feat_path,
			"data/Map1", "data/Map3", "data/MapManifest", "data/Map Backup",
			"data/Admin Placed Objects", "data/ItemSave", "data/NPCs", "data/Bodies",
			"data/Areas", "data/Blueprint", getNexusPlanetControlSavePath(environment),
			"data/ProfileImages/old.webp", "data/ProfileImages/upload-budget.sav",
			"data/PlayerMusic/old/track.ogg", "data/HotkeyBackups/old",
			"data/FutureGameplayState/nested/state.sav")
		var/other_environment = environment == "live" ? "playtest" : "live"
		var/list/preserved_paths = list(
			"Admin", "BANS", "Rules", "Notes", "Login Menu", "GAIN", "Errors.log",
			"data/Logs/Admin/audit.log", "data/Logs/Chat/chat.log", "data/Bugs",
			"data/ProfileImages/.profile-media-inspector.ready",
			"[getNexusCharacterSaveRoot(other_environment)]/other-slot1.sav",
			"[getNexusFeatSaveRoot(other_environment)]/other-slot1.sav",
			getNexusPlanetControlSavePath(other_environment))
		for(var/path in deleted_paths)
			nexusSmokeAssert(text2file("old gameplay", "[runtime_root][path]"), "wipe fixture could not write [path]")
		for(var/path in preserved_paths)
			nexusSmokeAssert(text2file("operational sentinel", "[runtime_root][path]"), "wipe fixture could not write preserved [path]")
		var/savefile/settings = new("[runtime_root]Misc")
		settings["prohibited_admins"] << list("restricted-admin")
		settings["banned_from_hosting"] << "restricted-host"
		settings["bank_list"] << list("old-account" = 99999)
		settings["viltrumite_grand_regent_account"] << "old-regent"
		settings.Flush()
		settings = null
		var/savefile/votes = new("[runtime_root]Votes")
		votes["RP President"] << "old-character"
		votes["Head Admin"] << "admin-account"
		votes["Vote Banned"] << list("banned-account")
		votes.Flush()
		votes = null
		nexusSmokeAssert(queueNexusFullWipe(environment, runtime_root), "full wipe request was not persisted")
		nexusSmokeAssert(!queueNexusFullWipe(environment, runtime_root), "duplicate full wipe request overwrote the first")
		nexusSmokeAssert(!applyPendingNexusFullWipe(other_environment, runtime_root) && fexists("[runtime_root]Misc"), "wipe crossed runtime environments")
		nexusSmokeAssert(applyPendingNexusFullWipe(environment, runtime_root), "pending full wipe failed")
		nexusSmokeAssert(!fexists("[runtime_root]Misc"), "full wipe retained global gameplay settings")
		var/savefile/admin_snapshot = new("[runtime_root]WipeAdministration")
		var/list/administration
		admin_snapshot["settings"] >> administration
		admin_snapshot = null
		nexusSmokeAssert(islist(administration) && ("restricted-admin" in administration["prohibited_admins"]) && administration["banned_from_hosting"] == "restricted-host", "wipe lost moderation restrictions stored in Misc")
		nexusSmokeAssert(!("bank_list" in administration) && !("viltrumite_grand_regent_account" in administration), "wipe retained economy or Grand Regent in the administrative snapshot")
		var/list/old_prohibited_admins = prohibited_admins
		var/old_host_restriction = banned_from_hosting
		loadNexusWipeAdministration(runtime_root)
		nexusSmokeAssert(("restricted-admin" in prohibited_admins) && banned_from_hosting == "restricted-host", "fresh-world load did not restore preserved moderation")
		prohibited_admins = old_prohibited_admins
		banned_from_hosting = old_host_restriction
		nexusSmokeAssert(queueNexusFullWipe(environment, runtime_root) && applyPendingNexusFullWipe(environment, runtime_root), "full wipe could not retry with already deleted gameplay files")
		admin_snapshot = new("[runtime_root]WipeAdministration")
		admin_snapshot["settings"] >> administration
		admin_snapshot = null
		nexusSmokeAssert(administration["banned_from_hosting"] == "restricted-host", "wipe retry replaced the preserved moderation snapshot")
		for(var/path in deleted_paths)
			nexusSmokeAssert(!fexists("[runtime_root][path]"), "full wipe retained gameplay state [path]")
		for(var/path in preserved_paths)
			nexusSmokeAssert(findtext(file2text("[runtime_root][path]"), "operational sentinel") == 1, "full wipe removed operational/other-environment state [path]")
		votes = new("[runtime_root]Votes")
		var/president
		var/head_admin
		var/list/vote_bans
		votes["RP President"] >> president
		votes["Head Admin"] >> head_admin
		votes["Vote Banned"] >> vote_bans
		votes = null
		nexusSmokeAssert(!president && head_admin == "admin-account" && ("banned-account" in vote_bans), "wipe did not clear the in-world president while preserving administrative votes")
		text2file("new character", "[runtime_root][character_path]")
		nexusSmokeAssert(applyPendingNexusFullWipe(environment, runtime_root) && fexists("[runtime_root][character_path]"), "completed wipe ran again on the new world")
		text2file("invalid json", "[runtime_root][NEXUS_FULL_WIPE_MARKER]")
		nexusSmokeAssert(!applyPendingNexusFullWipe(environment, runtime_root) && fexists("[runtime_root][character_path]"), "malformed wipe request was allowed to erase data")
		fdel("[runtime_root][NEXUS_FULL_WIPE_MARKER]")
	nexusSmokeAssert(!clearNexusFullWipeState("live", "../") && !queueNexusFullWipe("live", "data/../"), "wipe fixture allowed an unsafe root")
	world.log << "NEXUS_FULL_WIPE_TESTS_PASSED"
