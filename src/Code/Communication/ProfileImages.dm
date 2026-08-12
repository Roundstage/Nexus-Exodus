var/const/nexus_profile_art_policy_version = 2
var/const/nexus_profile_art_min_file_bytes = 1024
var/const/nexus_profile_art_max_file_bytes = 8 * 1024 * 1024
var/const/nexus_profile_art_max_artifact_bytes = nexus_profile_art_max_file_bytes
var/const/nexus_profile_art_max_dimension = 3840
var/const/nexus_profile_art_max_pixels = 3840 * 2160
var/const/nexus_profile_art_upload_ticket_lifetime = 1200
var/const/nexus_profile_art_upload_cooldown = 600
var/const/nexus_profile_art_daily_account_bytes = 24 * 1024 * 1024
var/const/nexus_profile_art_daily_global_bytes = 256 * 1024 * 1024
var/const/nexus_profile_art_global_max_stored_bytes = 1024 * 1024 * 1024
var/const/nexus_upload_broker_completion_guard = 20

var/nexus_profile_art_budget_loaded
var/nexus_profile_art_budget_day = ""
var/nexus_profile_art_global_daily_bytes
var/nexus_profile_art_global_stored_bytes
var/nexus_profile_art_storage_saturated
var/nexus_profile_art_cleanup_pending
var/list/nexus_profile_art_account_daily_bytes = list()
var/list/nexus_profile_art_account_next_upload_time = list()
var/nexus_profile_art_decode_active

mob/var
	player_profile_portrait_mode = "sprite"
	player_profile_art_hash = ""
	player_profile_art_format = ""
	player_profile_art_bytes = 0
	player_profile_art_width = 0
	player_profile_art_height = 0
	player_profile_art_version = 0

mob/var/tmp
	nexus_profile_art_runtime_hash = ""
	nexus_profile_force_sprite = FALSE

proc/isNexusProfileArtAccountKey(value)
	if(!istext(value) || !length(value) || length(value) > 64) return FALSE
	if(ckey(value) != value) return FALSE
	for(var/index = 1, index <= length(value), index++)
		var/character = copytext(value, index, index + 1)
		if(!findtext("abcdefghijklmnopqrstuvwxyz0123456789", character)) return FALSE
	return TRUE

proc/isNexusProfileArtHash(value)
	if(!istext(value) || length(value) != 40 || lowertext(value) != value) return FALSE
	for(var/index = 1, index <= length(value), index++)
		if(!findtext("0123456789abcdef", copytext(value, index, index + 1))) return FALSE
	return TRUE

proc/normalizeNexusProfileArtFormat(value)
	var/format = lowertext("[value]")
	if(format == "png") return "png"
	if(format == "jpg" || format == "jpeg") return "jpg"
	if(format == "webm") return "webm"
	return ""

proc/getNexusProfileArtUploadFormat(value)
	if(!istext(value) || !length(value) || length(value) > 260) return ""
	var/lower_name = lowertext(value)
	if(length(lower_name) > 4 && copytext(lower_name, length(lower_name) - 3) == ".png") return "png"
	if(length(lower_name) > 4 && copytext(lower_name, length(lower_name) - 3) == ".jpg") return "jpg"
	if(length(lower_name) > 5 && copytext(lower_name, length(lower_name) - 4) == ".jpeg") return "jpg"
	if(length(lower_name) > 5 && copytext(lower_name, length(lower_name) - 4) == ".webm") return "webm"
	return ""

proc/isNexusProfileArtUploadName(value)
	return length(getNexusProfileArtUploadFormat(value)) > 0

proc/getNexusProfileArtRawLength(raw_data)
	if(istext(raw_data) || islist(raw_data)) return length(raw_data)
	return 0

proc/getNexusProfileArtRawByte(raw_data, byte_index)
	if(islist(raw_data)) return raw_data[byte_index]
	if(istext(raw_data)) return text2ascii(raw_data, byte_index)
	return null

proc/nexusProfileArtRawContainsAscii(raw_data, needle, maximum_position)
	if(!istext(needle) || !length(needle)) return FALSE
	var/raw_length = min(getNexusProfileArtRawLength(raw_data), maximum_position)
	var/needle_length = length(needle)
	for(var/raw_index = 1, raw_index <= raw_length - needle_length + 1, raw_index++)
		var/matches = TRUE
		for(var/needle_index = 1, needle_index <= needle_length, needle_index++)
			if(getNexusProfileArtRawByte(raw_data, raw_index + needle_index - 1) != text2ascii(needle, needle_index))
				matches = FALSE
				break
		if(matches) return TRUE
	return FALSE

proc/getNexusProfileArtSignatureFormatFromRaw(raw_data)
	var/raw_length = getNexusProfileArtRawLength(raw_data)
	if(raw_length >= 8 && getNexusProfileArtRawByte(raw_data, 1) == 137 && getNexusProfileArtRawByte(raw_data, 2) == 80 && getNexusProfileArtRawByte(raw_data, 3) == 78 && getNexusProfileArtRawByte(raw_data, 4) == 71 && getNexusProfileArtRawByte(raw_data, 5) == 13 && getNexusProfileArtRawByte(raw_data, 6) == 10 && getNexusProfileArtRawByte(raw_data, 7) == 26 && getNexusProfileArtRawByte(raw_data, 8) == 10) return "png"
	if(raw_length >= 3 && getNexusProfileArtRawByte(raw_data, 1) == 255 && getNexusProfileArtRawByte(raw_data, 2) == 216 && getNexusProfileArtRawByte(raw_data, 3) == 255) return "jpg"
	if(raw_length >= 4 && getNexusProfileArtRawByte(raw_data, 1) == 26 && getNexusProfileArtRawByte(raw_data, 2) == 69 && getNexusProfileArtRawByte(raw_data, 3) == 223 && getNexusProfileArtRawByte(raw_data, 4) == 163 && nexusProfileArtRawContainsAscii(raw_data, "webm", min(raw_length, 4096))) return "webm"
	return ""

proc/getNexusProfileArtSignatureFormat(file_value)
	if(!isfile(file_value)) return ""
	var/raw_data
	try
		raw_data = file2text(file_value)
	catch(var/exception/read_error)
		if(read_error) raw_data = null
	var/signature_format = getNexusProfileArtSignatureFormatFromRaw(raw_data)
	if(length(signature_format)) return signature_format
	// BYOND may decline to expose binary resources through file2text. The strict
	// extension allowlist plus the transient native image decode remains the
	// fallback for still images in that runtime. WEBM remains fail-closed because
	// Dream Daemon cannot perform the native icon decode used below.
	var/fallback_format = getNexusProfileArtUploadFormat("[file_value]")
	return fallback_format == "webm" ? "" : fallback_format

proc/getNexusWebmUnsignedAt(raw_data, element_position, scan_limit)
	var/size_position = element_position + 1
	if(size_position > scan_limit) return 0
	var/size_first_byte = getNexusProfileArtRawByte(raw_data, size_position)
	var/size_marker = 128
	var/size_length = 1
	while(size_length <= 4 && !(size_first_byte & size_marker))
		size_marker = round(size_marker / 2)
		size_length++
	if(size_length > 4 || size_position + size_length - 1 > scan_limit) return 0
	var/payload_size = size_first_byte & (size_marker - 1)
	for(var/size_index = 1, size_index < size_length, size_index++)
		payload_size = payload_size * 256 + getNexusProfileArtRawByte(raw_data, size_position + size_index)
	var/payload_position = size_position + size_length
	if(payload_size < 1 || payload_size > 4 || payload_position + payload_size - 1 > scan_limit) return 0
	var/value = 0
	for(var/value_index = 0, value_index < payload_size, value_index++)
		value = value * 256 + getNexusProfileArtRawByte(raw_data, payload_position + value_index)
	return value

proc/getNexusWebmPayloadBoundsAt(raw_data, element_position, scan_limit)
	var/size_position = element_position + 1
	if(size_position > scan_limit) return null
	var/size_first_byte = getNexusProfileArtRawByte(raw_data, size_position)
	var/size_marker = 128
	var/size_length = 1
	while(size_length <= 8 && !(size_first_byte & size_marker))
		size_marker = round(size_marker / 2)
		size_length++
	if(size_length > 8 || size_position + size_length - 1 > scan_limit) return null
	var/payload_size = size_first_byte & (size_marker - 1)
	var/unknown_size = payload_size == size_marker - 1
	for(var/size_index = 1, size_index < size_length, size_index++)
		var/size_byte = getNexusProfileArtRawByte(raw_data, size_position + size_index)
		payload_size = payload_size * 256 + size_byte
		if(size_byte != 255) unknown_size = FALSE
	var/payload_position = size_position + size_length
	if(payload_position > scan_limit) return null
	var/payload_end = unknown_size ? scan_limit : min(scan_limit, payload_position + payload_size - 1)
	if(payload_end < payload_position) return null
	return list("start" = payload_position, "end" = payload_end)

proc/getNexusWebmDimensionsFromRaw(raw_data)
	if(getNexusProfileArtSignatureFormatFromRaw(raw_data) != "webm") return null
	var/scan_limit = min(getNexusProfileArtRawLength(raw_data), 1024 * 1024)
	for(var/byte_index = 5, byte_index <= scan_limit, byte_index++)
		if(getNexusProfileArtRawByte(raw_data, byte_index) != 224) continue
		var/list/video_bounds = getNexusWebmPayloadBoundsAt(raw_data, byte_index, scan_limit)
		if(!islist(video_bounds)) continue
		var/video_width = 0
		var/video_height = 0
		for(var/video_index = video_bounds["start"], video_index <= video_bounds["end"] && (!video_width || !video_height), video_index++)
			var/current_byte = getNexusProfileArtRawByte(raw_data, video_index)
			if(current_byte == 176 && !video_width) video_width = getNexusWebmUnsignedAt(raw_data, video_index, video_bounds["end"])
			else if(current_byte == 186 && !video_height) video_height = getNexusWebmUnsignedAt(raw_data, video_index, video_bounds["end"])
		if(video_width && video_height) return list("width" = video_width, "height" = video_height)
	return null

proc/getNexusWebmDimensions(file_value)
	if(!isfile(file_value)) return null
	var/raw_data
	try
		raw_data = file2text(file_value)
	catch(var/exception/read_error)
		if(read_error) raw_data = null
	return getNexusWebmDimensionsFromRaw(raw_data)

proc/isNexusProfileArtDimensionsValid(art_width, art_height)
	if(!nexusIsFiniteNumber(art_width) || !nexusIsFiniteNumber(art_height)) return FALSE
	if(art_width < 1 || art_height < 1 || art_width > nexus_profile_art_max_dimension || art_height > nexus_profile_art_max_dimension) return FALSE
	return art_width * art_height <= nexus_profile_art_max_pixels

proc/getNexusPlayerProfileImagePathForKey(character_key, slot = 1, content_hash = "", art_format = "")
	var/account_key = ckey(character_key)
	if(!isNexusProfileArtAccountKey(account_key)) return null
	var/slot_number = round(text2num("[slot]"))
	if(slot_number < 1 || slot_number > NEXUS_CHARACTER_SLOT_LIMIT) return null
	if(!length(content_hash) && !length(art_format)) return "data/ProfileImages/[account_key]-slot[slot_number].dmi"
	var/normalized_format = normalizeNexusProfileArtFormat(art_format)
	if(!isNexusProfileArtHash(content_hash) || !length(normalized_format)) return null
	return "data/ProfileImages/[account_key]-slot[slot_number]-[content_hash].[normalized_format]"

proc/getNexusProfileArtSaveIdentity(save_name)
	if(!istext(save_name) || !length(save_name)) return null
	var/lower_name = lowertext(save_name)
	for(var/slot = 1, slot <= NEXUS_CHARACTER_SLOT_LIMIT, slot++)
		var/suffix = "-slot[slot].sav"
		if(length(lower_name) <= length(suffix)) continue
		if(copytext(lower_name, length(lower_name) - length(suffix) + 1) != suffix) continue
		var/account_key = copytext(lower_name, 1, length(lower_name) - length(suffix) + 1)
		if(!isNexusProfileArtAccountKey(account_key)) return null
		return list("account_key" = account_key, "slot" = slot)
	return null

proc/getNexusPlayerProfileImagePathFromSaveName(save_name)
	var/list/identity = getNexusProfileArtSaveIdentity(save_name)
	if(!islist(identity)) return null
	return getNexusPlayerProfileImagePathForKey(identity["account_key"], identity["slot"])

proc/isNexusProfileArtStoredFileName(value)
	if(!istext(value) || !length(value)) return FALSE
	var/lower_name = lowertext(value)
	for(var/slot = 1, slot <= NEXUS_CHARACTER_SLOT_LIMIT, slot++)
		var/legacy_suffix = "-slot[slot].dmi"
		if(length(lower_name) > length(legacy_suffix) && copytext(lower_name, length(lower_name) - length(legacy_suffix) + 1) == legacy_suffix)
			var/legacy_key = copytext(lower_name, 1, length(lower_name) - length(legacy_suffix) + 1)
			if(isNexusProfileArtAccountKey(legacy_key)) return TRUE
		var/slot_marker = "-slot[slot]-"
		var/marker_position = findtext(lower_name, slot_marker)
		if(marker_position < 2) continue
		var/account_key = copytext(lower_name, 1, marker_position)
		if(!isNexusProfileArtAccountKey(account_key)) continue
		var/hash_start = marker_position + length(slot_marker)
		var/dot_position = findtext(lower_name, ".", hash_start)
		if(dot_position != hash_start + 40 || dot_position >= length(lower_name)) continue
		var/content_hash = copytext(lower_name, hash_start, dot_position)
		var/format = copytext(lower_name, dot_position + 1)
		if(isNexusProfileArtHash(content_hash) && length(normalizeNexusProfileArtFormat(format))) return TRUE
	return FALSE

proc/isNexusProfileArtFileForSlot(value, account_key, slot)
	if(!isNexusProfileArtStoredFileName(value) || !isNexusProfileArtAccountKey(account_key)) return FALSE
	var/lower_name = lowertext(value)
	var/base_name = "[account_key]-slot[slot]"
	return lower_name == "[base_name].dmi" || copytext(lower_name, 1, length(base_name) + 2) == "[base_name]-"

proc/getNexusProfileArtStoredIdentity(value)
	if(!isNexusProfileArtStoredFileName(value)) return null
	var/lower_name = lowertext(value)
	for(var/slot = 1, slot <= NEXUS_CHARACTER_SLOT_LIMIT, slot++)
		var/legacy_suffix = "-slot[slot].dmi"
		if(length(lower_name) > length(legacy_suffix) && copytext(lower_name, length(lower_name) - length(legacy_suffix) + 1) == legacy_suffix)
			var/legacy_key = copytext(lower_name, 1, length(lower_name) - length(legacy_suffix) + 1)
			if(isNexusProfileArtAccountKey(legacy_key)) return list("account_key" = legacy_key, "slot" = slot, "legacy" = TRUE, "hash" = "", "format" = "")
		var/slot_marker = "-slot[slot]-"
		var/marker_position = findtext(lower_name, slot_marker)
		if(marker_position < 2) continue
		var/account_key = copytext(lower_name, 1, marker_position)
		var/hash_start = marker_position + length(slot_marker)
		var/dot_position = findtext(lower_name, ".", hash_start)
		var/content_hash = dot_position ? copytext(lower_name, hash_start, dot_position) : ""
		var/format = dot_position ? normalizeNexusProfileArtFormat(copytext(lower_name, dot_position + 1)) : ""
		if(isNexusProfileArtAccountKey(account_key) && isNexusProfileArtHash(content_hash) && length(format)) return list("account_key" = account_key, "slot" = slot, "legacy" = FALSE, "hash" = content_hash, "format" = format)
	return null

proc/isNexusProfileArtTemporaryFileName(value)
	if(!istext(value) || length(value) < 1 || length(value) > 180) return FALSE
	var/lower_name = lowertext(value)
	if(copytext(lower_name, 1, 9) != ".upload-") return FALSE
	return getNexusProfileArtUploadFormat(lower_name) in list("png", "jpg", "webm")

proc/reconcileNexusProfileArtStoredBytes(prune_orphans = TRUE)
	nexus_profile_art_storage_saturated = FALSE
	nexus_profile_art_cleanup_pending = FALSE
	var/total_bytes = 0
	var/scanned_files = 0
	var/list/entries = flist("data/ProfileImages/")
	if(!islist(entries)) return 0
	for(var/entry in entries)
		if(isNexusProfileArtTemporaryFileName(entry))
			var/temporary_path = "data/ProfileImages/[entry]"
			if(fexists(temporary_path)) fdel(temporary_path)
			if(fexists(temporary_path))
				nexus_profile_art_cleanup_pending = TRUE
				world.log << "PROFILE_ART_TEMP_CLEANUP_PENDING path=[temporary_path]"
				scanned_files++
				var/temporary_bytes = length(file(temporary_path))
				if(nexusIsFiniteNumber(temporary_bytes) && temporary_bytes > 0) total_bytes += temporary_bytes
				if(scanned_files > 4096 || total_bytes >= nexus_profile_art_global_max_stored_bytes)
					nexus_profile_art_storage_saturated = TRUE
					return nexus_profile_art_global_max_stored_bytes
			continue
		if(!isNexusProfileArtStoredFileName(entry)) continue
		scanned_files++
		if(scanned_files > 4096)
			nexus_profile_art_storage_saturated = TRUE
			return nexus_profile_art_global_max_stored_bytes
		var/path = "data/ProfileImages/[entry]"
		var/list/identity = getNexusProfileArtStoredIdentity(entry)
		var/delete_orphan = !islist(identity)
		if(islist(identity))
			var/save_path = getNexusCharacterSavePathForKey(identity["account_key"], identity["slot"])
			if(!save_path || !fexists(save_path) || identity["legacy"])
				delete_orphan = TRUE
			else
				var/saved_hash
				var/save_read_succeeded = FALSE
				try
					var/savefile/profile_save = new(save_path)
					profile_save["player_profile_art_hash"] >> saved_hash
					save_read_succeeded = TRUE
				catch(var/exception/save_read_error)
					if(save_read_error) save_read_succeeded = FALSE
				// Preserve files when a save cannot be read. When it can, keep only the
				// generation claimed by its hash, even if other policy metadata is stale.
				delete_orphan = save_read_succeeded && (!isNexusProfileArtHash(saved_hash) || "[saved_hash]" != "[identity["hash"]]")
		if(prune_orphans && delete_orphan && fexists(path))
			fdel(path)
			if(fexists(path)) nexus_profile_art_cleanup_pending = TRUE
			else continue
		var/file_bytes = fexists(path) ? length(file(path)) : 0
		if(nexusIsFiniteNumber(file_bytes) && file_bytes > 0) total_bytes += file_bytes
		if(total_bytes >= nexus_profile_art_global_max_stored_bytes)
			nexus_profile_art_storage_saturated = TRUE
			return nexus_profile_art_global_max_stored_bytes
	return total_bytes

proc/cleanupNexusProfileArtUntrackedFile(path)
	if(!istext(path) || findtext(path, "data/ProfileImages/") != 1 || findtext(path, "..")) return FALSE
	if(!fexists(path)) return TRUE
	fdel(path)
	if(!fexists(path)) return TRUE
	loadNexusProfileArtBudget()
	// This helper can run between immutable-blob creation and metadata commit;
	// count everything without pruning an intentionally in-flight generation.
	nexus_profile_art_global_stored_bytes = reconcileNexusProfileArtStoredBytes(FALSE)
	saveNexusProfileArtBudget()
	world.log << "PROFILE_ART_TEMP_CLEANUP_PENDING path=[path]"
	return FALSE

proc/getNexusProfileArtBudgetPath()
	return "data/ProfileImages/upload-budget.sav"

proc/getNexusProfileArtDayKey()
	return time2text(world.realtime, "YYYY-MM-DD")

proc/rolloverNexusProfileArtBudget()
	var/current_day = getNexusProfileArtDayKey()
	if(nexus_profile_art_budget_day == current_day) return FALSE
	nexus_profile_art_budget_day = current_day
	nexus_profile_art_global_daily_bytes = 0
	nexus_profile_art_account_daily_bytes = list()
	return TRUE

proc/loadNexusProfileArtBudget()
	if(nexus_profile_art_budget_loaded)
		var/budget_changed = rolloverNexusProfileArtBudget()
		if(nexus_profile_art_cleanup_pending)
			// Runtime retries may overlap an upload between blob creation and its
			// metadata save. Retry temporary cleanup/counting without orphan GC;
			// full orphan pruning runs once at startup when no upload is in flight.
			nexus_profile_art_global_stored_bytes = reconcileNexusProfileArtStoredBytes(FALSE)
			budget_changed = TRUE
		if(budget_changed) saveNexusProfileArtBudget()
		return
	nexus_profile_art_budget_loaded = TRUE
	nexus_profile_art_account_daily_bytes = list()
	var/path = getNexusProfileArtBudgetPath()
	var/budget_file_exists = fexists(path)
	if(budget_file_exists)
		var/savefile/budget_file = new(path)
		budget_file["day"] >> nexus_profile_art_budget_day
		budget_file["global_daily_bytes"] >> nexus_profile_art_global_daily_bytes
		budget_file["account_daily_bytes"] >> nexus_profile_art_account_daily_bytes
	rolloverNexusProfileArtBudget()
	if(!nexusIsFiniteNumber(nexus_profile_art_global_daily_bytes) || nexus_profile_art_global_daily_bytes < 0) nexus_profile_art_global_daily_bytes = budget_file_exists ? nexus_profile_art_daily_global_bytes : 0
	if(!islist(nexus_profile_art_account_daily_bytes)) nexus_profile_art_account_daily_bytes = list()
	nexus_profile_art_global_stored_bytes = reconcileNexusProfileArtStoredBytes()

proc/saveNexusProfileArtBudget()
	if(!nexus_profile_art_budget_loaded) loadNexusProfileArtBudget()
	var/savefile/budget_file = new(getNexusProfileArtBudgetPath())
	budget_file["day"] << nexus_profile_art_budget_day
	budget_file["global_daily_bytes"] << nexus_profile_art_global_daily_bytes
	budget_file["account_daily_bytes"] << nexus_profile_art_account_daily_bytes
	budget_file["stored_bytes"] << nexus_profile_art_global_stored_bytes

proc/getNexusProfileArtUploadAuthorizationError(account_key, slot, file_size)
	loadNexusProfileArtBudget()
	if(!isNexusProfileArtAccountKey(account_key)) return "A registered BYOND account is required for persistent profile art."
	if(!getNexusPlayerProfileImagePathForKey(account_key, slot)) return "The character slot for this profile upload is invalid."
	if(!nexusIsFiniteNumber(file_size) || file_size < nexus_profile_art_min_file_bytes) return "The portrait file is empty or too small."
	if(file_size > nexus_profile_art_max_file_bytes) return "The portrait file exceeds the 8 MiB upload limit."
	var/account_used = nexus_profile_art_account_daily_bytes[account_key]
	if(!nexusIsFiniteNumber(account_used) || account_used < 0) account_used = 0
	if(account_used + file_size > nexus_profile_art_daily_account_bytes) return "This account has reached its 24 MiB daily profile-art upload limit."
	if(nexus_profile_art_global_daily_bytes + file_size > nexus_profile_art_daily_global_bytes) return "The server has reached its daily profile-art upload limit. Try again tomorrow."
	if(nexus_profile_art_global_stored_bytes + file_size > nexus_profile_art_global_max_stored_bytes) return "The server profile-art archive is full."
	return ""

proc/reserveNexusProfileArtUpload(account_key, slot, file_size)
	var/error = getNexusProfileArtUploadAuthorizationError(account_key, slot, file_size)
	if(length(error)) return error
	var/account_used = nexus_profile_art_account_daily_bytes[account_key]
	if(!nexusIsFiniteNumber(account_used) || account_used < 0) account_used = 0
	nexus_profile_art_account_daily_bytes[account_key] = account_used + file_size
	nexus_profile_art_global_daily_bytes += file_size
	nexus_profile_art_account_next_upload_time[account_key] = world.time + nexus_profile_art_upload_cooldown
	saveNexusProfileArtBudget()
	return ""

proc/noteNexusProfileArtStoredDelta(delta_bytes)
	loadNexusProfileArtBudget()
	if(!nexusIsFiniteNumber(delta_bytes)) return
	if(delta_bytes < 0 && nexus_profile_art_storage_saturated)
		nexus_profile_art_global_stored_bytes = reconcileNexusProfileArtStoredBytes()
		saveNexusProfileArtBudget()
		return
	nexus_profile_art_global_stored_bytes = Clamp(nexus_profile_art_global_stored_bytes + delta_bytes, 0, nexus_profile_art_global_max_stored_bytes)
	if(nexus_profile_art_global_stored_bytes >= nexus_profile_art_global_max_stored_bytes) nexus_profile_art_storage_saturated = TRUE
	saveNexusProfileArtBudget()

proc/deleteNexusPlayerProfileImageGenerationsForKey(character_key, slot = 1, keep_hash = "", keep_format = "")
	var/account_key = ckey(character_key)
	var/legacy_path = getNexusPlayerProfileImagePathForKey(account_key, slot)
	if(!legacy_path) return FALSE
	var/normalized_keep_format = normalizeNexusProfileArtFormat(keep_format)
	var/keep_path = isNexusProfileArtHash(keep_hash) && length(normalized_keep_format) ? getNexusPlayerProfileImagePathForKey(account_key, slot, keep_hash, normalized_keep_format) : ""
	loadNexusProfileArtBudget()
	var/deleted_bytes = 0
	var/all_deleted = TRUE
	var/list/entries = flist("data/ProfileImages/")
	if(!islist(entries)) return TRUE
	for(var/entry in entries)
		if(!isNexusProfileArtFileForSlot(entry, account_key, slot)) continue
		var/path = "data/ProfileImages/[entry]"
		if(length(keep_path) && lowertext(path) == lowertext(keep_path)) continue
		var/old_bytes = fexists(path) ? length(file(path)) : 0
		if(fexists(path)) fdel(path)
		if(fexists(path))
			all_deleted = FALSE
		else if(nexusIsFiniteNumber(old_bytes) && old_bytes > 0)
			deleted_bytes += old_bytes
	if(deleted_bytes > 0) noteNexusProfileArtStoredDelta(-deleted_bytes)
	if(!all_deleted)
		nexus_profile_art_cleanup_pending = TRUE
		world.log << "PROFILE_ART_CLEANUP_PENDING account=[account_key] slot=[slot]"
	return all_deleted

proc/deleteNexusPlayerProfileImageForKey(character_key, slot = 1)
	return deleteNexusPlayerProfileImageGenerationsForKey(character_key, slot)

proc/deleteNexusPlayerProfileImageForSaveName(save_name)
	var/list/identity = getNexusProfileArtSaveIdentity(save_name)
	if(!islist(identity)) return TRUE
	return deleteNexusPlayerProfileImageForKey(identity["account_key"], identity["slot"])

proc/resetNexusProfileArtBudgetAfterWipe()
	nexus_profile_art_budget_loaded = TRUE
	nexus_profile_art_budget_day = getNexusProfileArtDayKey()
	nexus_profile_art_global_daily_bytes = 0
	nexus_profile_art_global_stored_bytes = 0
	nexus_profile_art_storage_saturated = FALSE
	nexus_profile_art_cleanup_pending = FALSE
	nexus_profile_art_account_daily_bytes = list()
	nexus_profile_art_account_next_upload_time = list()

mob/proc/clearNexusPlayerProfileArtMetadata()
	player_profile_portrait_mode = "sprite"
	player_profile_art_hash = ""
	player_profile_art_format = ""
	player_profile_art_bytes = 0
	player_profile_art_width = 0
	player_profile_art_height = 0
	player_profile_art_version = 0
	nexus_profile_art_runtime_hash = ""

mob/proc/canPersistNexusPlayerProfileArt()
	return canPersistNexusPlayerProfile()

mob/proc/getNexusPlayerProfileImagePath()
	if(!key || dbz_character) return null
	return getNexusPlayerProfileImagePathForKey(key, active_character_slot, player_profile_art_hash, player_profile_art_format)

mob/proc/hasNexusPlayerProfileArtArtifact()
	if(!key || dbz_character) return FALSE
	var/account_key = ckey(key)
	if(!isNexusProfileArtAccountKey(account_key)) return FALSE
	var/list/entries = flist("data/ProfileImages/")
	if(!islist(entries)) return FALSE
	for(var/entry in entries)
		if(isNexusProfileArtFileForSlot(entry, account_key, active_character_slot)) return TRUE
	return FALSE

mob/proc/hasNexusPlayerProfileCustomArt()
	if(dbz_character || nexus_profile_force_sprite) return FALSE
	var/metadata_claimed = player_profile_portrait_mode == "custom" || length(player_profile_art_hash) || length(player_profile_art_format) || player_profile_art_bytes || player_profile_art_width || player_profile_art_height || player_profile_art_version
	if(!metadata_claimed) return FALSE
	if(player_profile_art_version != nexus_profile_art_policy_version) return FALSE
	if(!isNexusProfileArtHash(player_profile_art_hash)) return FALSE
	if(player_profile_art_format != normalizeNexusProfileArtFormat(player_profile_art_format) || !length(player_profile_art_format)) return FALSE
	if(!nexusIsFiniteNumber(player_profile_art_bytes) || player_profile_art_bytes < nexus_profile_art_min_file_bytes || player_profile_art_bytes > nexus_profile_art_max_artifact_bytes) return FALSE
	if(!isNexusProfileArtDimensionsValid(player_profile_art_width, player_profile_art_height)) return FALSE
	var/path = getNexusPlayerProfileImagePath()
	if(!path || !fexists(path) || length(file(path)) != player_profile_art_bytes) return FALSE
	if(nexus_profile_art_runtime_hash != player_profile_art_hash)
		if(sha1(file(path)) != player_profile_art_hash || getNexusProfileArtSignatureFormat(file(path)) != player_profile_art_format) return FALSE
		nexus_profile_art_runtime_hash = player_profile_art_hash
	return TRUE

mob/proc/isNexusPlayerProfileUsingCustomArt()
	return player_profile_portrait_mode == "custom" && hasNexusPlayerProfileCustomArt()

mob/proc/getNexusPlayerProfileCustomArtFile(require_selected = TRUE)
	if(require_selected && player_profile_portrait_mode != "custom") return null
	if(!hasNexusPlayerProfileCustomArt()) return null
	return file(getNexusPlayerProfileImagePath())

mob/proc/getNexusPlayerProfileCustomArtResourceName(prefix = "nexus_profile_art")
	if(!hasNexusPlayerProfileCustomArt()) return ""
	var/opaque_id = md5("\ref[src]|[player_profile_art_hash]|[nexus_profile_art_policy_version]")
	return "[prefix]_[opaque_id]_[player_profile_art_hash].[player_profile_art_format]"

mob/proc/isNexusPlayerProfileArtMetadataPersisted()
	var/save_path = getNexusCharacterSavePath()
	if(!save_path || !fexists(save_path)) return FALSE
	var/savefile/profile_save = new(save_path)
	var/saved_mode
	var/saved_hash
	var/saved_format
	var/saved_bytes
	var/saved_width
	var/saved_height
	var/saved_version
	profile_save["player_profile_portrait_mode"] >> saved_mode
	profile_save["player_profile_art_hash"] >> saved_hash
	profile_save["player_profile_art_format"] >> saved_format
	profile_save["player_profile_art_bytes"] >> saved_bytes
	profile_save["player_profile_art_width"] >> saved_width
	profile_save["player_profile_art_height"] >> saved_height
	profile_save["player_profile_art_version"] >> saved_version
	return "[saved_mode]" == "[player_profile_portrait_mode]" && "[saved_hash]" == "[player_profile_art_hash]" && "[saved_format]" == "[player_profile_art_format]" && text2num("[saved_bytes]") == player_profile_art_bytes && text2num("[saved_width]") == player_profile_art_width && text2num("[saved_height]") == player_profile_art_height && text2num("[saved_version]") == player_profile_art_version

proc/storeNexusPlayerProfileImage(mob/owner, uploaded_file, original_name, ticket)
	var/list/result = list("ok" = FALSE, "error" = "The selected profile image could not be processed.")
	if(!owner || !owner.client || !owner.canPersistNexusPlayerProfileArt() || !isfile(uploaded_file)) return result
	var/upload_format = getNexusProfileArtUploadFormat(original_name)
	if(!length(upload_format))
		result["error"] = "Only PNG, JPEG, and WEBM files are accepted."
		return result
	if(length(uploaded_file) < nexus_profile_art_min_file_bytes || length(uploaded_file) > nexus_profile_art_max_file_bytes)
		result["error"] = "The uploaded image no longer matches the permitted size."
		return result
	var/safe_ticket = lowertext("[ticket]")
	if(length(safe_ticket) != 32)
		result["error"] = "The upload ticket is invalid."
		return result
	for(var/ticket_index = 1, ticket_index <= length(safe_ticket), ticket_index++)
		if(!findtext("0123456789abcdef", copytext(safe_ticket, ticket_index, ticket_index + 1)))
			result["error"] = "The upload ticket is invalid."
			return result
	var/account_key = ckey(owner.key)
	var/slot = owner.active_character_slot
	if(!isNexusProfileArtAccountKey(account_key) || !getNexusPlayerProfileImagePathForKey(account_key, slot))
		result["error"] = "The character slot for this profile image is invalid."
		return result
	loadNexusProfileArtBudget()
	var/temp_path = "data/ProfileImages/.upload-[account_key]-slot[slot]-[safe_ticket].[upload_format]"
	if(!cleanupNexusProfileArtUntrackedFile(temp_path))
		result["error"] = "A stale profile-image upload could not be cleaned up. Try again later."
		return result
	if(!fcopy(uploaded_file, temp_path) || !fexists(temp_path))
		cleanupNexusProfileArtUntrackedFile(temp_path)
		result["error"] = "The original profile image could not be staged."
		return result
	var/artifact_bytes = length(file(temp_path))
	if(!nexusIsFiniteNumber(artifact_bytes) || artifact_bytes < nexus_profile_art_min_file_bytes || artifact_bytes > nexus_profile_art_max_artifact_bytes || artifact_bytes != length(uploaded_file))
		cleanupNexusProfileArtUntrackedFile(temp_path)
		result["error"] = "The staged image failed its size validation."
		return result
	var/signature_format = getNexusProfileArtSignatureFormat(file(temp_path))
	if(signature_format != upload_format)
		cleanupNexusProfileArtUntrackedFile(temp_path)
		result["error"] = "The file contents do not match the selected PNG, JPEG, or WEBM extension."
		return result
	var/image_width
	var/image_height
	if(upload_format == "webm")
		var/list/webm_dimensions = getNexusWebmDimensions(file(temp_path))
		if(islist(webm_dimensions))
			image_width = webm_dimensions["width"]
			image_height = webm_dimensions["height"]
	else
		if(nexus_profile_art_decode_active)
			cleanupNexusProfileArtUntrackedFile(temp_path)
			result["error"] = "Another profile image is being inspected. Try again in a moment."
			return result
		var/icon/decoded_image
		nexus_profile_art_decode_active = TRUE
		try
			decoded_image = icon(file(temp_path), "", SOUTH, 1, FALSE)
		catch(var/exception/decode_error)
			if(decode_error) decoded_image = null
		nexus_profile_art_decode_active = FALSE
		if(!decoded_image)
			cleanupNexusProfileArtUntrackedFile(temp_path)
			result["error"] = "Dream Daemon could not decode that image."
			return result
		image_width = decoded_image.Width()
		image_height = decoded_image.Height()
		decoded_image = null
	if(!isNexusProfileArtDimensionsValid(image_width, image_height))
		cleanupNexusProfileArtUntrackedFile(temp_path)
		result["error"] = "Portrait media must fit within 4K: at most 3840x2160 landscape or 2160x3840 portrait."
		return result
	var/content_hash = sha1(file(temp_path))
	if(!isNexusProfileArtHash(content_hash))
		cleanupNexusProfileArtUntrackedFile(temp_path)
		result["error"] = "The server could not fingerprint the image."
		return result
	var/final_path = getNexusPlayerProfileImagePathForKey(owner.key, owner.active_character_slot, content_hash, upload_format)
	if(!final_path)
		cleanupNexusProfileArtUntrackedFile(temp_path)
		result["error"] = "Profile art is unavailable for this character type."
		return result
	var/final_already_valid = fexists(final_path) && length(file(final_path)) == artifact_bytes && sha1(file(final_path)) == content_hash
	if(!final_already_valid && nexus_profile_art_global_stored_bytes + artifact_bytes > nexus_profile_art_global_max_stored_bytes)
		cleanupNexusProfileArtUntrackedFile(temp_path)
		result["error"] = "The server profile-art archive is full."
		return result
	if(fexists(final_path) && !final_already_valid)
		var/corrupt_bytes = length(file(final_path))
		fdel(final_path)
		if(fexists(final_path))
			cleanupNexusProfileArtUntrackedFile(temp_path)
			result["error"] = "A corrupt stored image could not be quarantined."
			return result
		if(nexusIsFiniteNumber(corrupt_bytes) && corrupt_bytes > 0) noteNexusProfileArtStoredDelta(-corrupt_bytes)
	if(!final_already_valid)
		if(!fcopy(temp_path, final_path) || !fexists(final_path) || length(file(final_path)) != artifact_bytes || sha1(file(final_path)) != content_hash || getNexusProfileArtSignatureFormat(file(final_path)) != upload_format)
			cleanupNexusProfileArtUntrackedFile(final_path)
			cleanupNexusProfileArtUntrackedFile(temp_path)
			result["error"] = "The original image could not be committed without modification."
			return result
		noteNexusProfileArtStoredDelta(artifact_bytes)
	cleanupNexusProfileArtUntrackedFile(temp_path)
	result["ok"] = TRUE
	result["error"] = ""
	result["hash"] = content_hash
	result["format"] = upload_format
	result["bytes"] = artifact_bytes
	result["width"] = image_width
	result["height"] = image_height
	return result

proc/copyNexusPlayerProfileImageForKeys(source_key, source_slot, destination_key, destination_slot, expected_hash)
	if(!isNexusProfileArtHash(expected_hash)) return FALSE
	var/source_format = ""
	var/source_path = ""
	for(var/format in list("png", "jpg", "webm"))
		var/candidate_path = getNexusPlayerProfileImagePathForKey(source_key, source_slot, expected_hash, format)
		if(candidate_path && fexists(candidate_path) && sha1(file(candidate_path)) == expected_hash && getNexusProfileArtSignatureFormat(file(candidate_path)) == format)
			source_format = format
			source_path = candidate_path
			break
	if(!length(source_path)) return FALSE
	var/destination_path = getNexusPlayerProfileImagePathForKey(destination_key, destination_slot, expected_hash, source_format)
	if(!destination_path) return FALSE
	if(source_path == destination_path) return TRUE
	loadNexusProfileArtBudget()
	var/source_bytes = length(file(source_path))
	var/destination_valid = fexists(destination_path) && length(file(destination_path)) == source_bytes && sha1(file(destination_path)) == expected_hash
	if(!destination_valid && nexus_profile_art_global_stored_bytes + source_bytes > nexus_profile_art_global_max_stored_bytes) return FALSE
	if(fexists(destination_path) && !destination_valid)
		var/old_bytes = length(file(destination_path))
		fdel(destination_path)
		if(fexists(destination_path)) return FALSE
		if(nexusIsFiniteNumber(old_bytes) && old_bytes > 0) noteNexusProfileArtStoredDelta(-old_bytes)
	if(!destination_valid)
		if(!fcopy(source_path, destination_path) || !fexists(destination_path) || length(file(destination_path)) != source_bytes || sha1(file(destination_path)) != expected_hash)
			if(fexists(destination_path)) fdel(destination_path)
			if(fexists(destination_path))
				nexus_profile_art_global_stored_bytes = reconcileNexusProfileArtStoredBytes()
				saveNexusProfileArtBudget()
			return FALSE
		noteNexusProfileArtStoredDelta(source_bytes)
	return TRUE

datum/NexusPlayerDescriptionEditor/proc/clearProfileArtUploadState(client/upload_client, ticket)
	if(pending_upload_ticket == ticket) pending_upload_ticket = ""
	if(upload_client) upload_client.clearNexusProfileArtUploadState(ticket)

datum/NexusPlayerDescriptionEditor/proc/uploadProfileArt()
	if(!canUse() || busy) return
	if(!owner.canPersistNexusPlayerProfileArt())
		finishAction("This character cannot persist custom profile art because character saving is unavailable.", TRUE)
		return
	var/account_key = ckey(owner.key)
	if(!isNexusProfileArtAccountKey(account_key) || isNexusPlayerMusicGuestKey(owner.key))
		finishAction("A registered BYOND account is required for persistent profile art.", TRUE)
		return
	if(owner.client.isNexusUploadBrokerBusy())
		finishAction("Finish or cancel the active file prompt before uploading profile art.", TRUE)
		return
	busy = TRUE
	var/client/upload_client = owner.client
	var/slot = owner.active_character_slot
	var/old_hash = owner.player_profile_art_hash
	var/old_format = owner.player_profile_art_format
	var/old_mode = owner.player_profile_portrait_mode
	var/old_bytes = owner.player_profile_art_bytes
	var/old_width = owner.player_profile_art_width
	var/old_height = owner.player_profile_art_height
	var/old_version = owner.player_profile_art_version
	var/old_runtime_hash = owner.nexus_profile_art_runtime_hash
	var/ticket = md5("profile-art|[account_key]|[slot]|[world.realtime]|[world.time]|[render_generation]|[rand(1, 2147483647)]")
	pending_upload_ticket = ticket
	upload_client.nexus_profile_art_upload_state = "awaiting"
	upload_client.nexus_profile_art_upload_window = src
	upload_client.nexus_profile_art_upload_ticket = ticket
	upload_client.nexus_profile_art_upload_account_key = account_key
	upload_client.nexus_profile_art_upload_slot = slot
	upload_client.nexus_profile_art_upload_generation = render_generation
	upload_client.nexus_profile_art_upload_expires = world.time + nexus_profile_art_upload_ticket_lifetime
	upload_client.nexus_profile_art_upload_accepted_ticket = ""
	upload_client.nexus_profile_art_upload_accepted_window = null
	upload_client.nexus_profile_art_upload_filename = ""
	upload_client.nexus_profile_art_upload_size = 0
	var/uploaded_file = input(owner, "Choose a PNG, JPEG, or WEBM between 1 KiB and 8 MiB, up to 4K (3840x2160 landscape or 2160x3840 portrait). The exact uploaded bytes are published to profile viewers.", "Upload Profile Art") as file|null
	var/upload_was_accepted = upload_client && upload_client.nexus_profile_art_upload_state == "accepted" && upload_client.nexus_profile_art_upload_accepted_ticket == ticket && upload_client.nexus_profile_art_upload_accepted_window == src
	var/original_name = upload_was_accepted ? upload_client.nexus_profile_art_upload_filename : ""
	var/authorized_size = upload_was_accepted ? upload_client.nexus_profile_art_upload_size : 0
	if(upload_was_accepted) upload_client.nexus_profile_art_upload_state = "processing"
	if(!hasLiveOwner() || owner.client != upload_client || ckey(owner.key) != account_key || owner.active_character_slot != slot)
		clearProfileArtUploadState(upload_client, ticket)
		busy = FALSE
		return
	if(!uploaded_file || !upload_was_accepted)
		clearProfileArtUploadState(upload_client, ticket)
		finishAction("Profile-art upload canceled or rejected before processing.", TRUE)
		return
	if(length(uploaded_file) != authorized_size)
		clearProfileArtUploadState(upload_client, ticket)
		finishAction("The uploaded image did not match its authorized size.", TRUE)
		return
	var/list/store_result = storeNexusPlayerProfileImage(owner, uploaded_file, original_name, ticket)
	clearProfileArtUploadState(upload_client, ticket)
	if(!hasLiveOwner() || owner.client != upload_client || ckey(owner.key) != account_key || owner.active_character_slot != slot)
		if(store_result["ok"]) deleteNexusPlayerProfileImageGenerationsForKey(account_key, slot, old_hash, old_format)
		busy = FALSE
		return
	if(!store_result["ok"])
		finishAction(store_result["error"], TRUE)
		return
	owner.player_profile_portrait_mode = "custom"
	owner.player_profile_art_hash = store_result["hash"]
	owner.player_profile_art_format = store_result["format"]
	owner.player_profile_art_bytes = store_result["bytes"]
	owner.player_profile_art_width = store_result["width"]
	owner.player_profile_art_height = store_result["height"]
	owner.player_profile_art_version = nexus_profile_art_policy_version
	owner.nexus_profile_art_runtime_hash = owner.player_profile_art_hash
	var/list/old_profile_text_state = captureOwnerProfileTextState()
	applyDraft()
	owner.last_nexus_profile_save = world.time
	owner.save()
	if(!owner.isNexusPlayerProfileArtMetadataPersisted() || !owner.isNexusPlayerProfileTextPersisted())
		owner.player_profile_portrait_mode = old_mode
		owner.player_profile_art_hash = old_hash
		owner.player_profile_art_format = old_format
		owner.player_profile_art_bytes = old_bytes
		owner.player_profile_art_width = old_width
		owner.player_profile_art_height = old_height
		owner.player_profile_art_version = old_version
		owner.nexus_profile_art_runtime_hash = old_runtime_hash
		restoreOwnerProfileTextState(old_profile_text_state)
		owner.save()
		var/rollback_verified = owner.isNexusPlayerProfileArtMetadataPersisted() && owner.isNexusPlayerProfileTextPersisted()
		if(rollback_verified) deleteNexusPlayerProfileImageGenerationsForKey(account_key, slot, old_hash, old_format)
		finishAction(rollback_verified ? "The image was validated, but the complete character profile save could not be verified. The previous profile was restored." : "Persistent storage could not be verified. Previous values remain active in this session and both image generations were preserved for recovery.", TRUE)
		return
	var/obsolete_deleted = deleteNexusPlayerProfileImageGenerationsForKey(account_key, slot, owner.player_profile_art_hash, owner.player_profile_art_format)
	finishAction(obsolete_deleted ? "Profile art uploaded without conversion and the current profile fields were saved." : "Profile art was saved, but an obsolete image could not be removed automatically.", !obsolete_deleted)

datum/NexusPlayerDescriptionEditor/proc/useProfileArt(use_custom)
	if(!canUse() || busy) return
	if(!owner.canPersistNexusPlayerProfileArt())
		finishAction("This character cannot persist profile-art changes because character saving is unavailable.", TRUE)
		return
	busy = TRUE
	if(use_custom && !owner.hasNexusPlayerProfileCustomArt())
		finishAction("No valid custom art is stored for this character slot.", TRUE)
		return
	var/old_mode = owner.player_profile_portrait_mode
	var/list/old_profile_text_state = captureOwnerProfileTextState()
	owner.player_profile_portrait_mode = use_custom ? "custom" : "sprite"
	applyDraft()
	owner.last_nexus_profile_save = world.time
	owner.save()
	if(!owner.isNexusPlayerProfileArtMetadataPersisted() || !owner.isNexusPlayerProfileTextPersisted())
		owner.player_profile_portrait_mode = old_mode
		restoreOwnerProfileTextState(old_profile_text_state)
		owner.save()
		var/rollback_verified = owner.isNexusPlayerProfileArtMetadataPersisted() && owner.isNexusPlayerProfileTextPersisted()
		finishAction(rollback_verified ? "The complete character profile save could not be verified, so the previous profile was restored." : "Persistent storage could not be verified. The previous portrait remains active in this session; contact an administrator before logging out.", TRUE)
		return
	finishAction(use_custom ? "Custom art is now shown on this character profile." : "The live character sprite is now shown on this profile. Your custom art remains stored.")

datum/NexusPlayerDescriptionEditor/proc/deleteProfileArt()
	if(!canUse() || busy) return
	if(!owner.canPersistNexusPlayerProfileArt())
		finishAction("This character cannot persist profile-art changes because character saving is unavailable.", TRUE)
		return
	if(!owner.hasNexusPlayerProfileArtArtifact())
		finishAction("No custom-art file is stored for this character slot.", TRUE)
		return
	busy = TRUE
	var/client/original_client = owner.client
	var/account_key = ckey(owner.key)
	var/slot = owner.active_character_slot
	var/expected_hash = owner.player_profile_art_hash
	var/choice = alert(owner, "Permanently delete the custom profile art for [owner.name] in slot [slot]? This cannot be undone.", "Delete Profile Art", "Delete", "Cancel")
	if(!hasLiveOwner() || owner.client != original_client || ckey(owner.key) != account_key || owner.active_character_slot != slot || owner.player_profile_art_hash != expected_hash)
		busy = FALSE
		return
	if(choice != "Delete")
		finishAction("Custom-art deletion canceled.")
		return
	var/old_mode = owner.player_profile_portrait_mode
	var/old_hash = owner.player_profile_art_hash
	var/old_format = owner.player_profile_art_format
	var/old_bytes = owner.player_profile_art_bytes
	var/old_width = owner.player_profile_art_width
	var/old_height = owner.player_profile_art_height
	var/old_version = owner.player_profile_art_version
	var/old_runtime_hash = owner.nexus_profile_art_runtime_hash
	var/list/old_profile_text_state = captureOwnerProfileTextState()
	owner.clearNexusPlayerProfileArtMetadata()
	applyDraft()
	owner.last_nexus_profile_save = world.time
	owner.save()
	if(!owner.isNexusPlayerProfileArtMetadataPersisted() || !owner.isNexusPlayerProfileTextPersisted())
		owner.player_profile_portrait_mode = old_mode
		owner.player_profile_art_hash = old_hash
		owner.player_profile_art_format = old_format
		owner.player_profile_art_bytes = old_bytes
		owner.player_profile_art_width = old_width
		owner.player_profile_art_height = old_height
		owner.player_profile_art_version = old_version
		owner.nexus_profile_art_runtime_hash = old_runtime_hash
		restoreOwnerProfileTextState(old_profile_text_state)
		owner.save()
		var/rollback_verified = owner.isNexusPlayerProfileArtMetadataPersisted() && owner.isNexusPlayerProfileTextPersisted()
		finishAction(rollback_verified ? "The complete profile save could not be verified, so the stored image and previous fields were preserved." : "Persistent storage could not be verified. The image was not deleted and previous values remain active in this session.", TRUE)
		return
	if(!deleteNexusPlayerProfileImageForKey(account_key, slot))
		finishAction("The profile now uses the live sprite, but an orphaned image could not be removed from server storage.", TRUE)
		return
	finishAction("Custom profile art was permanently deleted. The profile now uses the live sprite.")

client/var/tmp
	nexus_profile_art_upload_state = ""
	nexus_profile_art_upload_window
	nexus_profile_art_upload_ticket = ""
	nexus_profile_art_upload_account_key = ""
	nexus_profile_art_upload_slot = 0
	nexus_profile_art_upload_generation = 0
	nexus_profile_art_upload_expires = 0
	nexus_profile_art_upload_accepted_ticket = ""
	nexus_profile_art_upload_accepted_window
	nexus_profile_art_upload_filename = ""
	nexus_profile_art_upload_size = 0
	nexus_upload_broker_guard_until = 0
	nexus_upload_broker_guard_generation = 0
	nexus_legacy_upload_state = ""
	nexus_legacy_upload_prompt_count = 0
	nexus_legacy_upload_expires = 0

client/proc/armNexusUploadBrokerGuard(until_time)
	var/target_time = max(world.time + 1, round(text2num("[until_time]")))
	if(target_time <= nexus_upload_broker_guard_until) return TRUE
	nexus_upload_broker_guard_until = target_time
	nexus_upload_broker_guard_generation++
	var/guard_generation = nexus_upload_broker_guard_generation
	spawn(max(1, target_time - world.time + 1))
		if(!src || guard_generation != nexus_upload_broker_guard_generation || world.time < nexus_upload_broker_guard_until) return
		if(nexus_profile_art_upload_state == "cancelled" || nexus_profile_art_upload_state == "rejected") clearNexusProfileArtUploadState("", FALSE)
		if(nexus_music_upload_state == "cancelled" || nexus_music_upload_state == "rejected") clearNexusPlayerMusicUploadState("", FALSE)
		if(nexus_legacy_upload_state == "cancelled" || nexus_legacy_upload_state == "rejected") nexus_legacy_upload_state = ""
		if(nexus_legacy_upload_prompt_count && world.time >= nexus_legacy_upload_expires)
			nexus_legacy_upload_prompt_count = 0
			nexus_legacy_upload_expires = 0
	return TRUE

client/proc/isNexusUploadBrokerBusy(include_legacy = TRUE)
	if(length(nexus_profile_art_upload_state) || length(nexus_music_upload_state) || world.time < nexus_upload_broker_guard_until) return TRUE
	if(include_legacy && (length(nexus_legacy_upload_state) || (nexus_legacy_upload_prompt_count > 0 && world.time < nexus_legacy_upload_expires))) return TRUE
	return FALSE

mob/proc/beginNexusLegacyUploadPrompt()
	if(!client || client.isNexusUploadBrokerBusy()) return FALSE
	client.nexus_legacy_upload_prompt_count++
	client.nexus_legacy_upload_state = "awaiting"
	client.nexus_legacy_upload_expires = world.time + max(nexus_profile_art_upload_ticket_lifetime, nexus_player_music_upload_ticket_lifetime)
	return TRUE

mob/proc/endNexusLegacyUploadPrompt()
	if(!client) return FALSE
	client.nexus_legacy_upload_prompt_count = max(0, client.nexus_legacy_upload_prompt_count - 1)
	if(!client.nexus_legacy_upload_prompt_count)
		client.nexus_legacy_upload_state = ""
		client.nexus_legacy_upload_expires = 0
		client.armNexusUploadBrokerGuard(world.time + nexus_upload_broker_completion_guard)
	return TRUE

client/proc/cancelNexusLegacyUploadPrompts()
	if(nexus_legacy_upload_prompt_count <= 0) return FALSE
	var/guard_until = max(nexus_legacy_upload_expires, world.time + nexus_upload_broker_completion_guard)
	nexus_legacy_upload_state = "cancelled"
	nexus_legacy_upload_prompt_count = 0
	nexus_legacy_upload_expires = 0
	armNexusUploadBrokerGuard(guard_until)
	return TRUE

client/proc/clearNexusProfileArtUploadState(ticket = "", protect_late_callback = TRUE)
	if(length(ticket) && nexus_profile_art_upload_ticket != ticket && nexus_profile_art_upload_accepted_ticket != ticket) return FALSE
	if(protect_late_callback && length(nexus_profile_art_upload_state)) armNexusUploadBrokerGuard(world.time + nexus_upload_broker_completion_guard)
	nexus_profile_art_upload_state = ""
	nexus_profile_art_upload_window = null
	nexus_profile_art_upload_ticket = ""
	nexus_profile_art_upload_account_key = ""
	nexus_profile_art_upload_slot = 0
	nexus_profile_art_upload_generation = 0
	nexus_profile_art_upload_expires = 0
	nexus_profile_art_upload_accepted_ticket = ""
	nexus_profile_art_upload_accepted_window = null
	nexus_profile_art_upload_filename = ""
	nexus_profile_art_upload_size = 0
	return TRUE

client/proc/cancelNexusProfileArtUploadState()
	if(!length(nexus_profile_art_upload_state)) return FALSE
	var/guard_until = max(nexus_profile_art_upload_expires, world.time + nexus_upload_broker_completion_guard)
	nexus_profile_art_upload_state = "cancelled"
	nexus_profile_art_upload_window = null
	nexus_profile_art_upload_accepted_ticket = ""
	nexus_profile_art_upload_accepted_window = null
	nexus_profile_art_upload_filename = ""
	nexus_profile_art_upload_size = 0
	armNexusUploadBrokerGuard(guard_until)
	return TRUE

client/proc/rejectNexusProfileArtUpload(message)
	nexus_profile_art_upload_state = "rejected"
	nexus_profile_art_upload_accepted_ticket = ""
	nexus_profile_art_upload_accepted_window = null
	nexus_profile_art_upload_filename = ""
	nexus_profile_art_upload_size = 0
	armNexusUploadBrokerGuard(max(nexus_profile_art_upload_expires, world.time + nexus_upload_broker_completion_guard))
	if(length(message)) src << message
	return FALSE

client/proc/handleNexusProfileArtAllowUpload(filename, filelength)
	if(nexus_profile_art_upload_state != "awaiting")
		if(length(nexus_profile_art_upload_state) && nexus_profile_art_upload_state != "cancelled") clearNexusProfileArtUploadState("", FALSE)
		src << "A stale or duplicate profile-image upload was rejected. Try again from Character Profile."
		return FALSE
	var/ticket = nexus_profile_art_upload_ticket
	var/account_key = nexus_profile_art_upload_account_key
	var/slot = nexus_profile_art_upload_slot
	var/datum/NexusPlayerDescriptionEditor/upload_window = nexus_profile_art_upload_window
	nexus_profile_art_upload_state = "checking"
	nexus_profile_art_upload_accepted_ticket = ""
	nexus_profile_art_upload_accepted_window = null
	nexus_profile_art_upload_filename = ""
	nexus_profile_art_upload_size = 0
	if(!length(ticket) || world.time > nexus_profile_art_upload_expires || !upload_window || upload_window != nexus_description_editor || upload_window.pending_upload_ticket != ticket || upload_window.render_generation != nexus_profile_art_upload_generation || !mob || !mob.canPersistNexusPlayerProfileArt() || ckey(mob.key) != account_key || mob.active_character_slot != slot)
		return rejectNexusProfileArtUpload("The profile-image upload session expired.")
	if(!isNexusProfileArtUploadName(filename))
		return rejectNexusProfileArtUpload("Only files ending exactly in .png, .jpg, .jpeg, or .webm are accepted for profile art.")
	var/next_upload_time = nexus_profile_art_account_next_upload_time[account_key]
	if(nexusIsFiniteNumber(next_upload_time) && world.time < next_upload_time)
		return rejectNexusProfileArtUpload("Wait [round((next_upload_time - world.time) / 10, 0.1)] seconds before uploading profile art again.")
	var/error = reserveNexusProfileArtUpload(account_key, slot, filelength)
	if(length(error))
		return rejectNexusProfileArtUpload(error)
	nexus_profile_art_upload_state = "accepted"
	nexus_profile_art_upload_accepted_ticket = ticket
	nexus_profile_art_upload_accepted_window = upload_window
	nexus_profile_art_upload_filename = "[filename]"
	nexus_profile_art_upload_size = filelength
	return TRUE
