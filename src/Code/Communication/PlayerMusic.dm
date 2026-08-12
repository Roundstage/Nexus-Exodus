var/const/nexus_player_music_channel = 1024
var/const/nexus_player_music_validation_channel = 1023
var/const/nexus_player_music_volume = 50
var/const/nexus_player_music_range = 22
var/const/nexus_player_music_playback_cooldown = 300
var/const/nexus_player_music_upload_cooldown = 600
var/const/nexus_player_music_upload_ticket_lifetime = 1200
var/const/nexus_player_music_max_duration_seconds = 300
var/const/nexus_player_music_session_limit = nexus_player_music_max_duration_seconds * 10
var/const/nexus_player_music_listener_cooldown = 100
var/const/nexus_player_music_global_broadcast_cooldown = 10
var/const/nexus_player_music_validation_cooldown = 300
var/const/nexus_player_music_global_validation_cooldown = 10
var/const/nexus_player_music_min_file_bytes = 1024
var/const/nexus_player_music_max_file_bytes = 5 * 1024 * 1024
var/const/nexus_player_music_max_tracks = 5
var/const/nexus_player_music_max_total_bytes = 20 * 1024 * 1024
var/const/nexus_player_music_daily_account_bytes = 50 * 1024 * 1024
var/const/nexus_player_music_daily_global_bytes = 250 * 1024 * 1024
var/const/nexus_player_music_global_max_stored_bytes = 1024 * 1024 * 1024
var/const/nexus_player_music_library_cache_limit = 256
var/const/nexus_player_music_title_limit = 48
var/const/nexus_player_music_validation_version = 1
var/const/nexus_player_music_data_version = 3

var/list/nexus_player_music_libraries = list()
var/nexus_player_music_global_budget_loaded
var/nexus_player_music_global_budget_day = ""
var/nexus_player_music_global_budget_bytes
var/nexus_player_music_global_stored_bytes
var/nexus_player_music_next_global_broadcast_time
var/nexus_player_music_next_global_validation_time

proc/nexusTrimPlayerMusicText(value)
	var/text = "[value]"
	while(length(text) && copytext(text, 1, 2) == " ") text = copytext(text, 2)
	while(length(text) && copytext(text, length(text), length(text) + 1) == " ") text = copytext(text, 1, length(text))
	return text

proc/normalizeNexusPlayerMusicTitle(value)
	if(isnull(value)) return ""
	var/title = "[value]"
	title = replacetext(title, ascii2text(13), " ")
	title = replacetext(title, ascii2text(10), " ")
	title = replacetext(title, ascii2text(9), " ")
	title = replacetext(title, "<", "")
	title = replacetext(title, ">", "")
	while(findtext(title, "  ")) title = replacetext(title, "  ", " ")
	title = nexusTrimPlayerMusicText(title)
	if(length(title) > nexus_player_music_title_limit)
		title = copytext(title, 1, nexus_player_music_title_limit + 1)
		title = nexusTrimPlayerMusicText(title)
	return title

proc/isNexusPlayerMusicHex(value, expected_length)
	if(!istext(value) || length(value) != expected_length) return FALSE
	var/lower_value = lowertext(value)
	for(var/index = 1, index <= length(lower_value), index++)
		var/character = copytext(lower_value, index, index + 1)
		if(!findtext("0123456789abcdef", character)) return FALSE
	return lower_value == value

proc/isNexusPlayerMusicAccountKey(value)
	if(!istext(value) || !length(value) || length(value) > 64) return FALSE
	if(ckey(value) != value) return FALSE
	for(var/index = 1, index <= length(value), index++)
		var/character = copytext(value, index, index + 1)
		if(!findtext("abcdefghijklmnopqrstuvwxyz0123456789", character)) return FALSE
	return TRUE

proc/isNexusPlayerMusicUploadName(value)
	if(!istext(value) || !length(value) || length(value) > 260) return FALSE
	var/lower_name = lowertext(value)
	return length(lower_name) > 4 && copytext(lower_name, length(lower_name) - 3) == ".ogg"

proc/isNexusPlayerMusicGuestKey(value)
	var/lower_key = lowertext("[value]")
	return lower_key == "guest" || findtext(lower_key, "guest-") == 1

proc/getNexusPlayerMusicDayKey()
	return time2text(world.realtime, "YYYY-MM-DD")

proc/getNexusPlayerMusicMetadataPath(account_key)
	if(!isNexusPlayerMusicAccountKey(account_key)) return null
	return "data/PlayerMusic/[account_key]/library.sav"

proc/getNexusPlayerMusicTrackPath(account_key, track_id)
	if(!isNexusPlayerMusicAccountKey(account_key) || !isNexusPlayerMusicHex(track_id, 32)) return null
	return "data/PlayerMusic/[account_key]/[track_id].ogg"

proc/getNexusPlayerMusicGlobalBudgetPath()
	return "data/PlayerMusic/upload-budget.sav"

proc/reconcileNexusPlayerMusicStoredBytes()
	var/total_bytes = 0
	var/scanned_track_files = 0
	var/list/account_entries = flist("data/PlayerMusic/")
	if(!islist(account_entries)) return 0
	for(var/account_entry in account_entries)
		if(!istext(account_entry) || length(account_entry) < 2 || copytext(account_entry, length(account_entry)) != "/") continue
		var/account_key = copytext(account_entry, 1, length(account_entry))
		if(!isNexusPlayerMusicAccountKey(account_key)) continue
		var/list/track_entries = flist("data/PlayerMusic/[account_key]/")
		if(!islist(track_entries)) continue
		for(var/track_entry in track_entries)
			if(!isNexusPlayerMusicUploadName(track_entry)) continue
			var/track_id = copytext(track_entry, 1, length(track_entry) - 3)
			if(!isNexusPlayerMusicHex(track_id, 32) || track_entry != "[track_id].ogg") continue
			scanned_track_files++
			if(scanned_track_files > 4096) return nexus_player_music_global_max_stored_bytes
			var/track_path = getNexusPlayerMusicTrackPath(account_key, track_id)
			var/track_bytes = track_path && fexists(track_path) ? length(file(track_path)) : 0
			if(nexusIsFiniteNumber(track_bytes) && track_bytes > 0) total_bytes += track_bytes
			if(total_bytes >= nexus_player_music_global_max_stored_bytes) return nexus_player_music_global_max_stored_bytes
	return total_bytes

proc/loadNexusPlayerMusicGlobalBudget()
	if(nexus_player_music_global_budget_loaded) return
	nexus_player_music_global_budget_loaded = TRUE
	var/path = getNexusPlayerMusicGlobalBudgetPath()
	var/budget_file_exists = fexists(path)
	if(budget_file_exists)
		var/savefile/budget_file = new(path)
		budget_file["day"] >> nexus_player_music_global_budget_day
		budget_file["bytes"] >> nexus_player_music_global_budget_bytes
		budget_file["stored_bytes"] >> nexus_player_music_global_stored_bytes
	if(nexus_player_music_global_budget_day != getNexusPlayerMusicDayKey())
		nexus_player_music_global_budget_day = getNexusPlayerMusicDayKey()
		nexus_player_music_global_budget_bytes = 0
	if(!nexusIsFiniteNumber(nexus_player_music_global_budget_bytes) || nexus_player_music_global_budget_bytes < 0)
		nexus_player_music_global_budget_bytes = 0
	if(!nexusIsFiniteNumber(nexus_player_music_global_stored_bytes) || nexus_player_music_global_stored_bytes < 0)
		nexus_player_music_global_stored_bytes = budget_file_exists ? nexus_player_music_global_max_stored_bytes : 0
	nexus_player_music_global_stored_bytes = reconcileNexusPlayerMusicStoredBytes()
	nexus_player_music_global_stored_bytes = min(nexus_player_music_global_stored_bytes, nexus_player_music_global_max_stored_bytes)

proc/saveNexusPlayerMusicGlobalBudget()
	loadNexusPlayerMusicGlobalBudget()
	var/savefile/budget_file = new(getNexusPlayerMusicGlobalBudgetPath())
	budget_file["day"] << nexus_player_music_global_budget_day
	budget_file["bytes"] << nexus_player_music_global_budget_bytes
	budget_file["stored_bytes"] << nexus_player_music_global_stored_bytes

proc/getNexusBuiltInMusicCatalog()
	return list(
		"carnival_meme" = list("title" = "Carnival Meme", "file" = 'CarnivalMeme.ogg'),
		"asiyah_layer" = list("title" = "Asiyah Layer", "file" = 'AsiyahLayer.ogg'),
		"iron_lotus" = list("title" = "Iron Lotus", "file" = 'IronLotus.ogg'),
		"kiryu_g_ki_ll" = list("title" = "Kiryu G Ki Ll", "file" = 'KiryuGKiLl.ogg'),
		"blumenkranz" = list("title" = "Blumenkranz", "file" = 'Blumenkranz.ogg'),
		"scientific_triumph" = list("title" = "The Rumble of Scientific Triumph", "file" = 'TheRumbleOfScientificTriumph.ogg'),
		"cepheid_gaia" = list("title" = "Cepheid - Gaia", "file" = 'CepheidGaia.ogg')
	)

proc/inspectNexusPlayerMusicUpload(uploaded_file, original_name)
	var/list/result = list("ok" = FALSE, "error" = "The selected file could not be read.")
	if(!isfile(uploaded_file)) return result
	if(!isNexusPlayerMusicUploadName(original_name))
		result["error"] = "Only files ending in .ogg are accepted."
		return result
	var/file_size = length(uploaded_file)
	if(!isnum(file_size) || file_size < nexus_player_music_min_file_bytes)
		result["error"] = "The OGG file is empty or too small."
		return result
	if(file_size > nexus_player_music_max_file_bytes)
		result["error"] = "The OGG file exceeds the 5 MiB limit."
		return result
	var/content_hash = sha1(uploaded_file)
	if(!isNexusPlayerMusicHex(content_hash, 40))
		result["error"] = "The server could not fingerprint this upload."
		return result
	result["ok"] = TRUE
	result["error"] = ""
	result["bytes"] = file_size
	result["hash"] = content_hash
	return result

proc/getNexusPlayerMusicQueryDuration(list/playing_sounds, expected_file, expected_channel)
	if(!islist(playing_sounds) || !expected_file || !isnum(expected_channel)) return 0
	var/expected_file_text = "[expected_file]"
	for(var/sound/playing_sound in playing_sounds)
		if(playing_sound.channel != expected_channel) continue
		if(playing_sound.file != expected_file && "[playing_sound.file]" != expected_file_text) continue
		if(nexusIsFiniteNumber(playing_sound.len) && playing_sound.len > 0) return playing_sound.len
	return 0

datum/NexusPlayerMusicTrack
	var/id = ""
	var/title = ""
	var/byte_size
	var/content_hash = ""
	var/uploaded_at
	var/duration_seconds
	var/validated_at
	var/validated_hash = ""
	var/validation_version

	proc/isReady()
		return nexusIsFiniteNumber(duration_seconds) && duration_seconds >= 1 && duration_seconds <= nexus_player_music_max_duration_seconds && validated_hash == content_hash && nexusIsFiniteNumber(validated_at) && validated_at > 0 && validation_version == nexus_player_music_validation_version

	proc/clearValidation()
		duration_seconds = null
		validated_at = null
		validated_hash = ""
		validation_version = null

	proc/toSaveRow()
		return list(
			"id" = id,
			"title" = title,
			"bytes" = byte_size,
			"hash" = content_hash,
			"uploaded_at" = uploaded_at,
			"duration_seconds" = duration_seconds,
			"validated_at" = validated_at,
			"validated_hash" = validated_hash,
			"validation_version" = validation_version
		)

datum/NexusPlayerMusicLibrary
	var/account_key = ""
	var/list/tracks = list()
	var/loaded
	var/upload_budget_day = ""
	var/upload_budget_bytes
	var/last_upload_time
	var/last_play_time
	var/last_validation_time
	var/tmp/last_access_time

	New(new_account_key)
		. = ..()
		if(isNexusPlayerMusicAccountKey(new_account_key)) account_key = new_account_key

	proc/getMetadataPath()
		return getNexusPlayerMusicMetadataPath(account_key)

	proc/getTrackPath(track_id)
		return getNexusPlayerMusicTrackPath(account_key, track_id)

	proc/getTotalBytes()
		var/total_bytes = 0
		for(var/datum/NexusPlayerMusicTrack/track in tracks)
			if(isnum(track.byte_size) && track.byte_size > 0) total_bytes += track.byte_size
		return total_bytes

	proc/findTrack(track_id)
		if(!isNexusPlayerMusicHex(track_id, 32)) return null
		for(var/datum/NexusPlayerMusicTrack/track in tracks)
			if(track.id == track_id) return track
		return null

	proc/findTrackByHash(content_hash)
		if(!isNexusPlayerMusicHex(content_hash, 40)) return null
		for(var/datum/NexusPlayerMusicTrack/track in tracks)
			if(track.content_hash == content_hash) return track
		return null

	proc/isTrackMetadataValid(datum/NexusPlayerMusicTrack/track)
		if(!istype(track)) return FALSE
		if(!isNexusPlayerMusicHex(track.id, 32)) return FALSE
		if(!length(track.title) || normalizeNexusPlayerMusicTitle(track.title) != track.title) return FALSE
		if(!nexusIsFiniteNumber(track.byte_size) || track.byte_size < nexus_player_music_min_file_bytes || track.byte_size > nexus_player_music_max_file_bytes) return FALSE
		if(!isNexusPlayerMusicHex(track.content_hash, 40)) return FALSE
		if(!nexusIsFiniteNumber(track.uploaded_at) || track.uploaded_at < 0 || track.uploaded_at > world.realtime + 600) return FALSE
		if(!isnull(track.duration_seconds) && (!nexusIsFiniteNumber(track.duration_seconds) || track.duration_seconds < 0 || track.duration_seconds > nexus_player_music_max_duration_seconds)) return FALSE
		if(length(track.validated_hash) && track.validated_hash != track.content_hash) return FALSE
		if(!isnull(track.validated_at) && (!nexusIsFiniteNumber(track.validated_at) || track.validated_at < 0 || track.validated_at > world.realtime + 600)) return FALSE
		if(!isnull(track.validation_version) && track.validation_version != nexus_player_music_validation_version) return FALSE
		if(length(track.validated_hash) && !track.isReady()) return FALSE
		return TRUE

	proc/isTrackFileValid(datum/NexusPlayerMusicTrack/track, verify_hash = TRUE)
		if(!isTrackMetadataValid(track)) return FALSE
		var/path = getTrackPath(track.id)
		if(!path || !fexists(path)) return FALSE
		var/track_file = file(path)
		if(length(track_file) != track.byte_size) return FALSE
		if(verify_hash && sha1(track_file) != track.content_hash) return FALSE
		return TRUE

	proc/load()
		if(loaded) return
		loaded = TRUE
		tracks = list()
		upload_budget_day = getNexusPlayerMusicDayKey()
		upload_budget_bytes = 0
		last_upload_time = 0
		last_play_time = 0
		last_validation_time = 0
		if(!isNexusPlayerMusicAccountKey(account_key)) return
		var/path = getMetadataPath()
		if(!path || !fexists(path)) return
		var/savefile/library_file = new(path)
		var/version
		var/list/saved_tracks
		var/saved_upload_budget_day
		var/saved_upload_budget_bytes
		var/saved_last_upload_time
		var/saved_last_play_time
		var/saved_last_validation_time
		library_file["version"] >> version
		library_file["tracks"] >> saved_tracks
		library_file["upload_budget_day"] >> saved_upload_budget_day
		library_file["upload_budget_bytes"] >> saved_upload_budget_bytes
		library_file["last_upload_time"] >> saved_last_upload_time
		library_file["last_play_time"] >> saved_last_play_time
		library_file["last_validation_time"] >> saved_last_validation_time
		if(version != nexus_player_music_data_version) return
		upload_budget_day = istext(saved_upload_budget_day) ? saved_upload_budget_day : getNexusPlayerMusicDayKey()
		upload_budget_bytes = nexusIsFiniteNumber(saved_upload_budget_bytes) && saved_upload_budget_bytes >= 0 ? saved_upload_budget_bytes : nexus_player_music_daily_account_bytes
		last_upload_time = nexusIsFiniteNumber(saved_last_upload_time) && saved_last_upload_time >= 0 && saved_last_upload_time <= world.realtime + 600 ? saved_last_upload_time : world.realtime
		last_play_time = nexusIsFiniteNumber(saved_last_play_time) && saved_last_play_time >= 0 && saved_last_play_time <= world.realtime + 600 ? saved_last_play_time : world.realtime
		last_validation_time = nexusIsFiniteNumber(saved_last_validation_time) && saved_last_validation_time >= 0 && saved_last_validation_time <= world.realtime + 600 ? saved_last_validation_time : world.realtime
		var/current_day = getNexusPlayerMusicDayKey()
		if(upload_budget_day != current_day)
			upload_budget_day = current_day
			upload_budget_bytes = 0
		if(!islist(saved_tracks)) return
		var/list/seen_ids = list()
		var/list/seen_hashes = list()
		var/scanned_rows = 0
		for(var/row_value in saved_tracks)
			scanned_rows++
			if(scanned_rows > 50 || tracks.len >= nexus_player_music_max_tracks) break
			if(!islist(row_value)) continue
			var/list/row = row_value
			var/datum/NexusPlayerMusicTrack/track = new
			track.id = row["id"]
			track.title = row["title"]
			track.byte_size = row["bytes"]
			track.content_hash = row["hash"]
			track.uploaded_at = row["uploaded_at"]
			track.duration_seconds = row["duration_seconds"]
			track.validated_at = row["validated_at"]
			track.validated_hash = row["validated_hash"]
			track.validation_version = row["validation_version"]
			if((!isnull(track.duration_seconds) || !isnull(track.validated_at) || length(track.validated_hash) || !isnull(track.validation_version)) && !track.isReady())
				track.clearValidation()
			if(seen_ids[track.id] || seen_hashes[track.content_hash] || !isTrackFileValid(track, FALSE))
				del(track)
				continue
			if(getTotalBytes() + track.byte_size > nexus_player_music_max_total_bytes)
				del(track)
				continue
			seen_ids[track.id] = TRUE
			seen_hashes[track.content_hash] = TRUE
			tracks += track

	proc/save()
		if(!loaded || !isNexusPlayerMusicAccountKey(account_key)) return FALSE
		var/list/saved_tracks = list()
		for(var/datum/NexusPlayerMusicTrack/track in tracks)
			if(isTrackMetadataValid(track)) saved_tracks += list(track.toSaveRow())
		var/savefile/library_file = new(getMetadataPath())
		library_file["version"] << nexus_player_music_data_version
		library_file["tracks"] << saved_tracks
		library_file["upload_budget_day"] << upload_budget_day
		library_file["upload_budget_bytes"] << upload_budget_bytes
		library_file["last_upload_time"] << last_upload_time
		library_file["last_play_time"] << last_play_time
		library_file["last_validation_time"] << last_validation_time
		library_file.Flush()
		return TRUE

	proc/getUploadAuthorizationError(file_size)
		load()
		if(!nexusIsFiniteNumber(file_size) || file_size < nexus_player_music_min_file_bytes) return "The selected OGG is empty or too small."
		if(file_size > nexus_player_music_max_file_bytes) return "The selected OGG exceeds the 5 MiB limit."
		if(tracks.len >= nexus_player_music_max_tracks) return "Your music library already has five tracks."
		if(getTotalBytes() + file_size > nexus_player_music_max_total_bytes) return "This upload would exceed your 20 MiB library quota."
		if(last_upload_time && world.realtime < last_upload_time + nexus_player_music_upload_cooldown) return "Wait before starting another music upload."
		var/current_day = getNexusPlayerMusicDayKey()
		if(upload_budget_day != current_day)
			upload_budget_day = current_day
			upload_budget_bytes = 0
		if(upload_budget_bytes + file_size > nexus_player_music_daily_account_bytes) return "Your account has reached its music upload budget for today."
		loadNexusPlayerMusicGlobalBudget()
		if(nexus_player_music_global_budget_day != current_day)
			nexus_player_music_global_budget_day = current_day
			nexus_player_music_global_budget_bytes = 0
		if(nexus_player_music_global_budget_bytes + file_size > nexus_player_music_daily_global_bytes) return "The server has reached its music upload budget for today."
		if(nexus_player_music_global_stored_bytes + file_size > nexus_player_music_global_max_stored_bytes) return "The server music archive has reached its storage ceiling."
		return ""

	proc/reserveUpload(file_size)
		var/error = getUploadAuthorizationError(file_size)
		if(length(error)) return error
		upload_budget_bytes += file_size
		last_upload_time = world.realtime
		nexus_player_music_global_budget_bytes += file_size
		save()
		saveNexusPlayerMusicGlobalBudget()
		return ""

	proc/getPlaybackCooldownTicks()
		load()
		if(!last_play_time) return 0
		return max(0, last_play_time + nexus_player_music_playback_cooldown - world.realtime)

	proc/recordPlayback()
		last_play_time = world.realtime
		save()

	proc/getValidationCooldownTicks()
		load()
		if(!last_validation_time) return 0
		return max(0, last_validation_time + nexus_player_music_validation_cooldown - world.realtime)

	proc/recordValidationAttempt()
		last_validation_time = world.realtime
		save()

	proc/markTrackValidated(track_id, expected_hash, duration_seconds)
		var/datum/NexusPlayerMusicTrack/track = findTrack(track_id)
		if(!track || track.content_hash != expected_hash) return FALSE
		if(!nexusIsFiniteNumber(duration_seconds) || duration_seconds < 1 || duration_seconds > nexus_player_music_max_duration_seconds) return FALSE
		var/previous_duration = track.duration_seconds
		var/previous_validated_hash = track.validated_hash
		var/previous_validated_at = track.validated_at
		var/previous_validation_version = track.validation_version
		track.duration_seconds = round(duration_seconds, 0.1)
		track.validated_hash = track.content_hash
		track.validated_at = world.realtime
		track.validation_version = nexus_player_music_validation_version
		if(!save())
			track.duration_seconds = previous_duration
			track.validated_hash = previous_validated_hash
			track.validated_at = previous_validated_at
			track.validation_version = previous_validation_version
			return FALSE
		return TRUE

	proc/createTrackId(content_hash)
		for(var/attempt = 1, attempt <= 20, attempt++)
			var/candidate = md5("[account_key]|[content_hash]|[world.realtime]|[world.time]|[rand(1, 2147483647)]|[attempt]")
			if(isNexusPlayerMusicHex(candidate, 32) && !findTrack(candidate)) return candidate
		return null

	proc/addUpload(uploaded_file, title, list/inspection)
		load()
		var/list/result = list("ok" = FALSE, "error" = "The upload could not be stored.")
		var/safe_title = normalizeNexusPlayerMusicTitle(title)
		if(!length(safe_title))
			result["error"] = "Give the track a visible title."
			return result
		if(!islist(inspection) || !inspection["ok"]) return result
		var/file_size = inspection["bytes"]
		var/content_hash = inspection["hash"]
		if(!nexusIsFiniteNumber(file_size) || length(uploaded_file) != file_size || sha1(uploaded_file) != content_hash)
			result["error"] = "The upload changed while it was being processed."
			return result
		if(tracks.len >= nexus_player_music_max_tracks || getTotalBytes() + file_size > nexus_player_music_max_total_bytes)
			result["error"] = "Your library no longer has enough room for this track."
			return result
		if(findTrackByHash(content_hash))
			result["error"] = "That exact audio file is already in your library."
			return result
		loadNexusPlayerMusicGlobalBudget()
		if(nexus_player_music_global_stored_bytes + file_size > nexus_player_music_global_max_stored_bytes)
			result["error"] = "The server music archive reached its storage ceiling."
			return result
		var/track_id = createTrackId(content_hash)
		var/destination_path = getTrackPath(track_id)
		if(!destination_path || !fcopy(uploaded_file, destination_path)) return result
		var/stored_file = file(destination_path)
		if(length(stored_file) != file_size || sha1(stored_file) != content_hash)
			fdel(destination_path)
			result["error"] = "The stored copy failed its integrity check."
			return result
		var/datum/NexusPlayerMusicTrack/track = new
		track.id = track_id
		track.title = safe_title
		track.byte_size = file_size
		track.content_hash = content_hash
		track.uploaded_at = world.realtime
		tracks += track
		if(!save())
			tracks -= track
			fdel(destination_path)
			del(track)
			return result
		nexus_player_music_global_stored_bytes += file_size
		saveNexusPlayerMusicGlobalBudget()
		result["ok"] = TRUE
		result["error"] = ""
		result["track"] = track
		return result

	proc/renameTrack(track_id, requested_title)
		load()
		var/datum/NexusPlayerMusicTrack/track = findTrack(track_id)
		if(!track) return "That track no longer belongs to this library."
		var/safe_title = normalizeNexusPlayerMusicTitle(requested_title)
		if(!length(safe_title)) return "Give the track a visible title."
		track.title = safe_title
		save()
		return ""

	proc/deleteTrack(track_id)
		load()
		var/datum/NexusPlayerMusicTrack/track = findTrack(track_id)
		if(!track) return "That track no longer belongs to this library."
		var/path = getTrackPath(track.id)
		if(path && fexists(path) && !fdel(path)) return "The server could not remove the stored audio."
		loadNexusPlayerMusicGlobalBudget()
		nexus_player_music_global_stored_bytes = max(0, nexus_player_music_global_stored_bytes - track.byte_size)
		saveNexusPlayerMusicGlobalBudget()
		tracks -= track
		save()
		del(track)
		return ""

proc/getNexusPlayerMusicLibrary(account_key)
	if(!isNexusPlayerMusicAccountKey(account_key)) return null
	var/safe_account_key = account_key
	var/datum/NexusPlayerMusicLibrary/library = nexus_player_music_libraries[safe_account_key]
	if(!istype(library))
		trimNexusPlayerMusicLibraryCache()
		library = new(safe_account_key)
		nexus_player_music_libraries[safe_account_key] = library
	library.last_access_time = world.time
	library.load()
	return library

proc/isNexusPlayerMusicAccountOnline(account_key)
	if(!isNexusPlayerMusicAccountKey(account_key)) return FALSE
	for(var/client/player_client in clients)
		if(ckey(player_client.key) == account_key) return TRUE
	return FALSE

proc/trimNexusPlayerMusicLibraryCache()
	while(nexus_player_music_libraries.len >= nexus_player_music_library_cache_limit)
		var/oldest_account = ""
		var/oldest_access_time
		for(var/account_key in nexus_player_music_libraries)
			var/datum/NexusPlayerMusicLibrary/library = nexus_player_music_libraries[account_key]
			if(!istype(library) || isNexusPlayerMusicAccountOnline(account_key)) continue
			if(!length(oldest_account) || library.last_access_time < oldest_access_time)
				oldest_account = account_key
				oldest_access_time = library.last_access_time
		if(!length(oldest_account)) return
		var/datum/NexusPlayerMusicLibrary/oldest_library = nexus_player_music_libraries[oldest_account]
		nexus_player_music_libraries -= oldest_account
		if(oldest_library) del(oldest_library)

client/var/tmp
	nexus_music_upload_state = ""
	nexus_music_upload_window
	nexus_music_upload_ticket = ""
	nexus_music_upload_account_key = ""
	nexus_music_upload_expires
	nexus_music_upload_accepted_ticket = ""
	nexus_music_upload_accepted_window
	nexus_music_upload_filename = ""
	nexus_music_upload_size
	nexus_music_play_generation
	nexus_music_expiry_deadline
	nexus_music_expiry_worker
	nexus_music_last_start_time
	nexus_music_validation_generation
	nexus_music_validation_active
	nexus_music_validation_window
	nexus_music_validation_track_id = ""
	nexus_music_validation_hash = ""
	nexus_music_current_source = ""
	nexus_music_current_broadcast_token
	nexus_music_current_track_key = ""

client/proc/clearNexusPlayerMusicUploadState(ticket = "", protect_late_callback = TRUE)
	if(length(ticket) && nexus_music_upload_ticket != ticket && nexus_music_upload_accepted_ticket != ticket) return FALSE
	if(protect_late_callback && length(nexus_music_upload_state)) armNexusUploadBrokerGuard(world.time + nexus_upload_broker_completion_guard)
	nexus_music_upload_state = ""
	nexus_music_upload_window = null
	nexus_music_upload_ticket = ""
	nexus_music_upload_account_key = ""
	nexus_music_upload_expires = 0
	nexus_music_upload_accepted_ticket = ""
	nexus_music_upload_accepted_window = null
	nexus_music_upload_filename = ""
	nexus_music_upload_size = 0
	return TRUE

client/proc/cancelNexusPlayerMusicUploadState()
	if(!length(nexus_music_upload_state)) return FALSE
	var/guard_until = max(nexus_music_upload_expires, world.time + nexus_upload_broker_completion_guard)
	nexus_music_upload_state = "cancelled"
	nexus_music_upload_window = null
	nexus_music_upload_accepted_ticket = ""
	nexus_music_upload_accepted_window = null
	nexus_music_upload_filename = ""
	nexus_music_upload_size = 0
	armNexusUploadBrokerGuard(guard_until)
	return TRUE

client/proc/cancelNexusUploadBrokerContexts()
	if(nexus_music_library_window) del(nexus_music_library_window)
	if(length(nexus_music_upload_state)) cancelNexusPlayerMusicUploadState()
	if(nexus_description_editor) del(nexus_description_editor)
	if(length(nexus_profile_art_upload_state)) cancelNexusProfileArtUploadState()
	cancelNexusLegacyUploadPrompts()
	return TRUE

client/AllowUpload(filename, filelength)
	if(length(nexus_profile_art_upload_state)) return handleNexusProfileArtAllowUpload(filename, filelength)
	if(length(nexus_music_upload_state))
		if(nexus_music_upload_state != "awaiting")
			src << "A stale or duplicate music upload was rejected. Try again from Music Library."
			return FALSE
		return handleNexusPlayerMusicAllowUpload(filename, filelength)
	if(world.time < nexus_upload_broker_guard_until)
		src << "A stale or duplicate upload was rejected. Wait for the current file prompt to finish."
		return FALSE
	if(length(nexus_legacy_upload_state))
		if(nexus_legacy_upload_state != "awaiting" || nexus_legacy_upload_prompt_count <= 0 || world.time >= nexus_legacy_upload_expires)
			src << "A stale or duplicate legacy icon upload was rejected."
			return FALSE
		var/lower_name = lowertext("[filename]")
		var/allowed_icon_name = FALSE
		for(var/suffix in list(".dmi", ".png", ".jpg", ".jpeg", ".gif", ".bmp"))
			if(length(lower_name) > length(suffix) && copytext(lower_name, length(lower_name) - length(suffix) + 1) == suffix)
				allowed_icon_name = TRUE
				break
		if(!allowed_icon_name || !nexusIsFiniteNumber(filelength) || filelength < 1 || filelength > round(maxIconFileSize * 1024 * 1024))
			nexus_legacy_upload_state = "rejected"
			src << "The legacy icon upload was rejected before transfer."
			return FALSE
		nexus_legacy_upload_state = "accepted"
		return ..()
	if(mob && mob.IsAdmin()) return ..()
	src << "No authorized file prompt is active."
	return FALSE

client/proc/handleNexusPlayerMusicAllowUpload(filename, filelength)
	if(nexus_music_upload_state != "awaiting")
		src << "A stale or duplicate music upload was rejected. Try again from Music Library."
		return FALSE
	var/ticket = nexus_music_upload_ticket
	var/account_key = nexus_music_upload_account_key
	var/datum/NexusMusicLibraryWindow/upload_window = nexus_music_upload_window
	nexus_music_upload_state = "checking"
	nexus_music_upload_accepted_ticket = ""
	nexus_music_upload_accepted_window = null
	nexus_music_upload_filename = ""
	nexus_music_upload_size = 0
	if(!length(ticket) || world.time > nexus_music_upload_expires || !upload_window || upload_window != nexus_music_library_window || upload_window.pending_upload_ticket != ticket || upload_window.account_key != account_key || !mob || !mob.playerCharacter || ckey(mob.key) != account_key || isNexusPlayerMusicGuestKey(mob.key))
		clearNexusPlayerMusicUploadState()
		src << "The music upload session expired."
		return FALSE
	if(!isNexusPlayerMusicUploadName(filename))
		clearNexusPlayerMusicUploadState()
		src << "Only .ogg files are accepted by the music library."
		return FALSE
	var/datum/NexusPlayerMusicLibrary/library = getNexusPlayerMusicLibrary(account_key)
	if(!library)
		clearNexusPlayerMusicUploadState()
		src << "The music library is unavailable."
		return FALSE
	var/error = library.reserveUpload(filelength)
	if(length(error))
		clearNexusPlayerMusicUploadState()
		src << error
		return FALSE
	nexus_music_upload_state = "accepted"
	nexus_music_upload_accepted_ticket = ticket
	nexus_music_upload_accepted_window = upload_window
	nexus_music_upload_filename = "[filename]"
	nexus_music_upload_size = filelength
	return TRUE

client/proc/stopNexusPlayerMusic()
	nexus_music_play_generation++
	nexus_music_expiry_deadline = 0
	nexus_music_current_source = ""
	nexus_music_current_broadcast_token = 0
	nexus_music_current_track_key = ""
	src << sound(null, channel = nexus_player_music_channel)

client/proc/startNexusPlayerMusic(music_file, source_account, broadcast_token, track_key)
	if(!music_file || !mob || mob.block_music) return FALSE
	if(nexus_music_last_start_time && world.time < nexus_music_last_start_time + nexus_player_music_listener_cooldown) return FALSE
	stopNexusPlayerMusic()
	nexus_music_last_start_time = world.time
	nexus_music_play_generation++
	nexus_music_current_source = source_account
	nexus_music_current_broadcast_token = broadcast_token
	nexus_music_current_track_key = track_key
	var/sound/player_music = sound(music_file, repeat = FALSE, wait = FALSE, channel = nexus_player_music_channel, volume = nexus_player_music_volume)
	player_music.status = SOUND_STREAM
	src << player_music
	nexus_music_expiry_deadline = world.time + nexus_player_music_session_limit
	ensureNexusPlayerMusicExpiryWorker()
	return TRUE

client/proc/ensureNexusPlayerMusicExpiryWorker()
	set waitfor = FALSE
	if(nexus_music_expiry_worker) return
	nexus_music_expiry_worker = TRUE
	while(src && nexus_music_expiry_deadline)
		var/wait_ticks = max(1, nexus_music_expiry_deadline - world.time)
		sleep(wait_ticks)
		if(src && nexus_music_expiry_deadline && world.time >= nexus_music_expiry_deadline) stopNexusPlayerMusic()
	if(src) nexus_music_expiry_worker = FALSE

client/proc/cancelNexusPlayerMusicValidation()
	nexus_music_validation_generation++
	nexus_music_validation_active = FALSE
	nexus_music_validation_window = null
	nexus_music_validation_track_id = ""
	nexus_music_validation_hash = ""
	src << sound(null, channel = nexus_player_music_validation_channel)

client/proc/validateNexusPlayerMusicFile(music_file, datum/NexusMusicLibraryWindow/validation_window, track_id, expected_hash)
	var/list/result = list("ok" = FALSE, "error" = "DreamSeeker could not validate this track.", "duration" = 0, "track_id" = track_id, "hash" = expected_hash, "generation" = 0)
	if(!music_file || !mob || !mob.playerCharacter || !validation_window || validation_window != nexus_music_library_window || !isNexusPlayerMusicHex(track_id, 32) || !isNexusPlayerMusicHex(expected_hash, 40)) return result
	if(nexus_music_validation_active)
		result["error"] = "Another decoder check is already active."
		return result
	if(world.time < nexus_player_music_next_global_validation_time)
		result["error"] = "The decoder-validation channel is busy. Try again in a moment."
		return result
	nexus_player_music_next_global_validation_time = world.time + nexus_player_music_global_validation_cooldown
	nexus_music_validation_active = TRUE
	nexus_music_validation_generation++
	var/validation_generation = nexus_music_validation_generation
	result["generation"] = validation_generation
	nexus_music_validation_window = validation_window
	nexus_music_validation_track_id = track_id
	nexus_music_validation_hash = expected_hash
	src << sound(null, channel = nexus_player_music_validation_channel)
	var/sound/validation_sound = sound(music_file, repeat = TRUE, wait = FALSE, channel = nexus_player_music_validation_channel, volume = 0)
	validation_sound.status = SOUND_STREAM | SOUND_MUTE
	src << validation_sound
	var/duration_seconds = 0
	var/validation_deadline = world.time + 100
	for(var/attempt = 1, attempt <= 50 && world.time < validation_deadline, attempt++)
		sleep(2)
		if(!src || !nexus_music_validation_active || nexus_music_validation_generation != validation_generation || nexus_music_validation_window != validation_window || nexus_music_validation_track_id != track_id || nexus_music_validation_hash != expected_hash) break
		var/list/playing_sounds = SoundQuery()
		if(!src || !nexus_music_validation_active || nexus_music_validation_generation != validation_generation || nexus_music_validation_window != validation_window || nexus_music_validation_track_id != track_id || nexus_music_validation_hash != expected_hash) break
		duration_seconds = getNexusPlayerMusicQueryDuration(playing_sounds, music_file, nexus_player_music_validation_channel)
		if(duration_seconds > 0) break
	var/context_is_current = src && nexus_music_validation_active && nexus_music_validation_generation == validation_generation && nexus_music_validation_window == validation_window && nexus_music_validation_track_id == track_id && nexus_music_validation_hash == expected_hash
	if(context_is_current)
		src << sound(null, channel = nexus_player_music_validation_channel)
		nexus_music_validation_active = FALSE
		nexus_music_validation_window = null
		nexus_music_validation_track_id = ""
		nexus_music_validation_hash = ""
	if(context_is_current && nexusIsFiniteNumber(duration_seconds) && duration_seconds > 0)
		result["ok"] = TRUE
		result["error"] = ""
		result["duration"] = duration_seconds
	return result

mob/var/tmp
	nexus_music_broadcast_token
	nexus_music_transient_last_play_time

mob/proc/getNexusPlayerMusicAccountKey()
	return ckey(key)

mob/proc/getNexusPlayerMusicPlaybackCooldownTicks()
	if(isNexusPlayerMusicGuestKey(key))
		if(!nexus_music_transient_last_play_time) return 0
		return max(0, nexus_music_transient_last_play_time + nexus_player_music_playback_cooldown - world.time)
	var/datum/NexusPlayerMusicLibrary/library = getNexusPlayerMusicLibrary(getNexusPlayerMusicAccountKey())
	return library ? library.getPlaybackCooldownTicks() : nexus_player_music_playback_cooldown

mob/proc/stopNexusPlayerMusicForSelf(show_notice = TRUE)
	if(!client) return
	client.stopNexusPlayerMusic()
	if(show_notice) src << "Player music stopped. Game sound effects were left unchanged."

mob/proc/stopNexusPlayerMusicBroadcast(show_notice = TRUE)
	if(!client) return
	var/source_account = getNexusPlayerMusicAccountKey()
	nexus_music_broadcast_token++
	var/stopped_count = 0
	for(var/client/listener in clients)
		if(listener.nexus_music_current_source == source_account)
			listener.stopNexusPlayerMusic()
			stopped_count++
	if(show_notice) src << "Stopped your music broadcast for [stopped_count] listener[stopped_count == 1 ? "" : "s"]."

mob/proc/stopNexusPlayerMusicTrack(track_key)
	if(!length(track_key)) return
	for(var/client/listener in clients)
		if(listener.nexus_music_current_track_key == track_key) listener.stopNexusPlayerMusic()

mob/proc/broadcastNexusCustomTrack(track_id)
	var/list/result = list("ok" = FALSE, "error" = "The personal track could not be played.", "listeners" = 0)
	if(!client || !playerCharacter) return result
	if(isNexusPlayerMusicGuestKey(key))
		result["error"] = "A registered BYOND account is required for personal music."
		return result
	var/account_key = getNexusPlayerMusicAccountKey()
	var/datum/NexusPlayerMusicLibrary/library = getNexusPlayerMusicLibrary(account_key)
	var/datum/NexusPlayerMusicTrack/track = library ? library.findTrack(track_id) : null
	if(!track)
		result["error"] = "That track no longer belongs to your library."
		return result
	if(!track.isReady())
		result["error"] = "Validate this track with DreamSeeker before playing it for anyone."
		return result
	var/cooldown_ticks = getNexusPlayerMusicPlaybackCooldownTicks()
	if(cooldown_ticks > 0)
		result["error"] = "Wait [round(cooldown_ticks / 10, 0.1)] seconds before playing another track."
		return result
	if(world.time < nexus_player_music_next_global_broadcast_time)
		result["error"] = "The nearby music channel is busy. Try again in a moment."
		return result
	if(!library.isTrackFileValid(track, TRUE))
		result["error"] = "The stored track failed its integrity check and was not played."
		return result
	return broadcastNexusPlayerMusic(file(library.getTrackPath(track.id)), track.title, "custom:[account_key]:[track.id]")

mob/proc/broadcastNexusPlayerMusic(music_file, title, track_key)
	var/list/result = list("ok" = FALSE, "error" = "The music could not be played.", "listeners" = 0)
	if(!client || !playerCharacter || !music_file) return result
	var/account_key = getNexusPlayerMusicAccountKey()
	var/is_guest = isNexusPlayerMusicGuestKey(key)
	var/datum/NexusPlayerMusicLibrary/library
	if(!is_guest)
		library = getNexusPlayerMusicLibrary(account_key)
		if(!library) return result
	var/cooldown_ticks = getNexusPlayerMusicPlaybackCooldownTicks()
	if(cooldown_ticks > 0)
		result["error"] = "Wait [round(cooldown_ticks / 10, 0.1)] seconds before playing another track."
		return result
	if(world.time < nexus_player_music_next_global_broadcast_time)
		result["error"] = "The nearby music channel is busy. Try again in a moment."
		return result
	var/safe_title = normalizeNexusPlayerMusicTitle(title)
	if(!length(safe_title)) return result
	nexus_player_music_next_global_broadcast_time = world.time + nexus_player_music_global_broadcast_cooldown
	stopNexusPlayerMusicBroadcast(FALSE)
	nexus_music_broadcast_token++
	var/current_token = nexus_music_broadcast_token
	var/listener_count = 0
	for(var/mob/listener in player_view(nexus_player_music_range, src))
		if(!listener.client || listener.block_music) continue
		if(listener.client.startNexusPlayerMusic(music_file, account_key, current_token, track_key))
			listener_count++
			var/notice = "[html_encode("[src]")] played [html_encode(safe_title)]. Use Stop Player Music or STOP FOR ME in Music Library to stop it."
			listener << "<font color=cyan>[notice]"
			listener.ChatLog(notice, key)
	if(is_guest) nexus_music_transient_last_play_time = world.time
	else library.recordPlayback()
	result["ok"] = TRUE
	result["error"] = ""
	result["listeners"] = listener_count
	return result
