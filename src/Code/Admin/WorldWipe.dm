var/nexus_full_wipe_pending = FALSE
var/const/NEXUS_FULL_WIPE_MARKER = ".nexus-full-wipe.json"

proc/isNexusWipeFixtureRoot(runtime_root)
	return !runtime_root || (world.params["nexus_smoke_tests"] && findtext(runtime_root, "data/.wipe-smoke/") == 1 && !findtext(runtime_root, "..") && copytext(runtime_root, -1) == "/")

proc/getNexusFullWipePreservedPaths(environment = nexus_runtime_environment)
	var/list/paths = list("data/Logs/", "data/Bugs", "data/ProfileImages/.profile-media-inspector.ready")
	if(normalizeNexusRuntimeEnvironment(environment) == "live") paths += "data/Playtest/"
	else paths.Add("data/Save/", "data/Feats/", "data/PlanetControl")
	return paths

proc/getNexusFullWipeRootPaths()
	// Misc includes leagues, banks, rare-race grants, Grand Regent and world progression.
	return list("Misc", "Year", "Hero", "Ranks", "Jobs", "STORY", "CustomDecors", "DBZ Character Saves/", "data/")

proc/getNexusWipeAdministrationFields()
	return list("Status_Message", "banned_from_hosting", "prohibited_admins", "exempt_from_host_check", "Allow_Ban_Votes", "can_admin_vote", "voting_allowed", "maxBanTime", "allow_guests", "Max_Players", "OOC", "show_names_in_ooc", "admins_build_free", "admins_can_go_in_void", "admins_can_build_in_void", "auto_reboot_hours")

proc/preserveNexusWipeAdministration(runtime_root = "")
	if(!isNexusWipeFixtureRoot(runtime_root)) return FALSE
	// Keep the previous snapshot on a retry after Misc has already been deleted.
	if(!fexists("[runtime_root]Misc")) return TRUE
	var/savefile/settings = new("[runtime_root]Misc")
	var/list/administration = list()
	for(var/field in getNexusWipeAdministrationFields())
		if(field in settings)
			var/value
			settings[field] >> value
			administration[field] = value
	var/savefile/snapshot = new("[runtime_root]WipeAdministration")
	snapshot["settings"] << administration
	snapshot.Flush()
	return fexists("[runtime_root]WipeAdministration")

proc/loadNexusWipeAdministration(runtime_root = "")
	if(!isNexusWipeFixtureRoot(runtime_root) || !fexists("[runtime_root]WipeAdministration")) return
	var/savefile/snapshot = new("[runtime_root]WipeAdministration")
	var/list/administration
	snapshot["settings"] >> administration
	if(!islist(administration)) return
	for(var/field in getNexusWipeAdministrationFields())
		if(field in administration) global.vars[field] = administration[field]

proc/deleteNexusWipePath(relative_path, list/preserved_paths, runtime_root = "")
	if(!isNexusWipeFixtureRoot(runtime_root)) return FALSE
	if(relative_path in preserved_paths) return TRUE
	var/path = "[runtime_root][relative_path]"
	if(copytext(relative_path, -1) == "/")
		// Retain directories so upload services and save writers keep valid locations.
		for(var/entry in flist(path))
			if(!deleteNexusWipePath("[relative_path][entry]", preserved_paths, runtime_root)) return FALSE
		return TRUE
	if(!fexists(path)) return TRUE
	if(!fdel(path) || fexists(path))
		world.log << "NEXUS_FULL_WIPE_FAILED path=[relative_path]"
		return FALSE
	return TRUE

proc/clearNexusFullWipeState(environment = nexus_runtime_environment, runtime_root = "")
	if(!isNexusWipeFixtureRoot(runtime_root)) return FALSE
	if(!preserveNexusWipeAdministration(runtime_root)) return FALSE
	var/list/preserved_paths = getNexusFullWipePreservedPaths(environment)
	for(var/path in getNexusFullWipeRootPaths())
		if(!deleteNexusWipePath(path, preserved_paths, runtime_root)) return FALSE
	// The election file mixes an in-world role with administrative authority.
	if(fexists("[runtime_root]Votes"))
		var/savefile/votes = new("[runtime_root]Votes")
		votes["RP President"] << null
		votes.Flush()
	return TRUE

proc/queueNexusFullWipe(environment = nexus_runtime_environment, runtime_root = "")
	if(!isNexusWipeFixtureRoot(runtime_root)) return FALSE
	var/marker_path = "[runtime_root][NEXUS_FULL_WIPE_MARKER]"
	if(fexists(marker_path)) return FALSE
	var/list/request = list("version" = 1, "environment" = normalizeNexusRuntimeEnvironment(environment), "requested_at" = world.realtime)
	if(!text2file(json_encode(request), marker_path)) return FALSE
	return fexists(marker_path)

proc/applyPendingNexusFullWipe(environment = nexus_runtime_environment, runtime_root = "")
	if(!isNexusWipeFixtureRoot(runtime_root)) return FALSE
	var/marker_path = "[runtime_root][NEXUS_FULL_WIPE_MARKER]"
	if(!fexists(marker_path)) return TRUE
	var/list/request
	try
		request = json_decode(file2text(marker_path))
	catch
		return FALSE
	if(!islist(request) || request["version"] != 1 || request["environment"] != normalizeNexusRuntimeEnvironment(environment)) return FALSE
	try
		if(!clearNexusFullWipeState(environment, runtime_root)) return FALSE
	catch(var/exception/error)
		world.log << "NEXUS_FULL_WIPE_FAILED [error.name]"
		return FALSE
	if(!fdel(marker_path) || fexists(marker_path)) return FALSE
	world.log << "NEXUS_FULL_WIPE_COMPLETED environment=[normalizeNexusRuntimeEnvironment(environment)]"
	return TRUE

mob/Admin4/verb/pwipeSettings()
	set name = "Pwipe Settings"
	set category = "Admin"
	alert(src, "Pwipe always resets all characters, Feats, progression, economy, factions, ranks, items, player construction and world history. Administration, bans, rules and logs are preserved.", "Full wipe")

mob/Admin4/verb/pwipe()
	set name = "Pwipe"
	set category = "Admin"
	if(alert(src, "Permanently reset ALL gameplay data and restart the world? This includes Feats, factions, Grand Regent, items and player construction. Administration, bans, rules and logs will remain.", "Full wipe", "Cancel", "Wipe everything") != "Wipe everything") return
	if(!client || AdminLevel() < 4) return
	admin_blame(src, "[key] requested a full gameplay wipe.", TRUE)
	if(!Wipe()) src << "The full wipe could not be scheduled. Check the server log and any pending wipe request."

proc/Wipe()
	if(nexus_full_wipe_pending) return FALSE
	if(!queueNexusFullWipe())
		world.log << "NEXUS_FULL_WIPE_FAILED could not persist wipe request"
		return FALSE
	nexus_full_wipe_pending = TRUE
	player_saving_on = FALSE
	can_login = FALSE
	// Keep operational changes; gameplay saves are discarded at the next startup.
	saveAdmins()
	saveBan()
	saveRules()
	saveNotes()
	saveLogin()
	saveVote()
	saveMisc()
	world << "<font color=yellow>A full wipe has been scheduled. All gameplay data will be reset on restart in 10 seconds."
	spawn(100) world.Reboot()
	return TRUE
