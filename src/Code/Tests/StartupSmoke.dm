mob/NexusSmokeTest
	New()
		return

obj/Ships/Ship/NexusControlSmoke
	New()
		ships ||= list()
		ships |= src

	Del()
		ships -= src
		loc = null

obj/Controls/NexusControlSmoke
	New()
		ship_controls ||= list()
		ship_controls |= src

	Del()
		ship_controls -= src
		loc = null

mob/NexusSmokeTest/TradeHotbarProbe
	var/trade_restore_calls

	Restore_hotbar_from_IDs()
		if(skip_restore_hotbar) return
		trade_restore_calls++

mob/NexusSmokeTest/AngerKoProbe
	TryToKoNPC(mob/attacker, mob/victim)
		return

mob/NexusSmokeTest/DotKnockoutProbe
	var/observed_combat_mode_override
	var/mob/observed_dot_attacker

	KO(mob/attacker, allow_anger = TRUE, combat_ko_handled = FALSE, mob/victim = src, combat_mode_override)
		observed_dot_attacker = attacker
		observed_combat_mode_override = combat_mode_override
		src.KO = TRUE

datum/NexusTradeSmokeSession
	parent_type = /datum/NexusTradeSession

	getSessionError(require_joined = TRUE)
		return null

obj/items/NexusTradeFailMove
	var/fail_next_move

	Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
		if(fail_next_move)
			fail_next_move = FALSE
			return FALSE
		return ..()

mob/NexusSmokeTest/VectorMovement
	MobCross(mob/A)
		return

mob/NexusSmokeTest/InertialMovement
	getMovementMaximumVelocity(d = NORTH)
		return 30

mob/NexusSmokeTest/MovementAccumulator
	var/physics_step_count = 0
	var/physics_duration_total = 0

	processMovementPhysicsStep(input_direction, duration_deciseconds)
		physics_step_count++
		physics_duration_total += duration_deciseconds

mob/NexusSmokeTest/ForcedMovementProbe
	var/observe_next_move = FALSE
	var/observe_next_safe_teleport = FALSE
	var/observed_forced_move = FALSE
	var/observed_forced_teleport = FALSE
	var/forced_move_had_inertia = FALSE
	var/forced_teleport_had_inertia = FALSE

	Move(turf/NewLoc, Dir = 0, step_x = 0, step_y = 0)
		if(observe_next_move)
			observe_next_move = FALSE
			observed_forced_move = TRUE
			forced_move_had_inertia = movementVelocityMagnitude() || movement_acceleration_x || movement_acceleration_y || vector_fraction_x || vector_fraction_y
		return ..()

	SafeTeleport(turf/t, allowSameTick)
		if(observe_next_safe_teleport)
			observe_next_safe_teleport = FALSE
			observed_forced_teleport = TRUE
			forced_teleport_had_inertia = movementVelocityMagnitude() || movement_acceleration_x || movement_acceleration_y || vector_fraction_x || vector_fraction_y
		return ..()

mob/NexusSmokeTest/ForcedMovementProbe/DashImpact
	get_melee_accuracy(mob/target)
		return 0

mob/NexusSmokeTest/CometReversalProbe
	var/comet_approach_calls = 0
	var/atom/movable/comet_approach_target
	var/comet_approach_max_distance_pixels = 0
	var/comet_approach_stop_distance_pixels = 0
	var/comet_approach_require_selected_target = TRUE
	var/comet_approach_hold_ticks = 0
	var/comet_approach_result = NEXUS_SKILL_MOTION_INTERRUPTED
	var/comet_finisher_calls = 0
	var/mob/comet_finisher_target

	runNexusSkillApproach(atom/movable/target, maximum_distance_pixels, stop_distance_pixels = 32, max_velocity = skill_motion_default_max_velocity, acceleration = skill_motion_default_acceleration, deceleration = skill_motion_default_deceleration, afterimage_interval = 0.5, require_selected_target = TRUE, datum/NexusSkillMotionResult/result_capture)
		comet_approach_calls++
		comet_approach_target = target
		comet_approach_max_distance_pixels = maximum_distance_pixels
		comet_approach_stop_distance_pixels = stop_distance_pixels
		comet_approach_require_selected_target = require_selected_target
		if(comet_approach_hold_ticks > 0) sleep(comet_approach_hold_ticks)
		return comet_approach_result

	resolveNexusTechniqueHit(mob/target, obj/Attacks/NexusMeleeTechnique/technique, damage_multiplier = 1, force_hit = FALSE, defensive_evasion_resolved = FALSE)
		comet_finisher_calls++
		comet_finisher_target = target
		return TRUE

mob/NexusSmokeTest/InertialTeleport
	var/turf/nexus_smoke_teleport_destination

	getMovementMaximumVelocity(d = NORTH)
		return 10

	Move(turf/NewLoc, Dir = 0, step_x = 0, step_y = 0)
		if(nexus_smoke_teleport_destination)
			var/turf/destination = nexus_smoke_teleport_destination
			nexus_smoke_teleport_destination = null
			SafeTeleport(destination)
			return TRUE
		return ..()

mob/NexusSmokeTest/InertialFacing
	var/observed_facing_direction
	var/observed_physical_direction
	var/observed_post_move_direction

	Move(turf/NewLoc, Dir = 0, step_x = 0, step_y = 0)
		observed_facing_direction = dir
		observed_physical_direction = Dir
		return ..()

	NPCPostMove(old_loc)
		observed_post_move_direction = dir

turf/NexusSmokeVectorBlocker
	density = 1
	opacity = 0

turf/NexusSmokeTest
	density = 0
	opacity = 0
	FlyOverAble = 1

obj/NexusSmokeSkillAction
	Skill = 1
	hotbar_type = "Ability"
	can_hotbar = 1
	var/use_count = 0

	verb/Hotbar_use()
		set hidden = 1
		use_count++

proc/nexusSmokeAssert(condition, message)
	if(!condition)
		CRASH("Nexus smoke test failed: [message]")

proc/nexusSmokeAssertNear(actual, expected, tolerance, message)
	if(!isnum(actual) || abs(actual - expected) > tolerance)
		CRASH("Nexus smoke test failed: [message] (expected [expected], received [actual])")

proc/runNexusPlayerMusicSmokeTests()
	nexusSmokeAssert(nexus_player_music_channel == 1024 && nexus_player_music_validation_channel == 1023 && nexus_player_music_range == 22 && nexus_player_music_max_duration_seconds == 300 && nexus_player_music_session_limit == 3000, "player music does not use isolated channels, its nearby range, or the five-minute cap")
	nexusSmokeAssert(nexus_player_music_max_file_bytes == 5 * 1024 * 1024 && nexus_player_music_max_tracks == 5 && nexus_player_music_max_total_bytes == 20 * 1024 * 1024, "player music upload quotas changed unexpectedly")
	var/global_music_budget_path = getNexusPlayerMusicGlobalBudgetPath()
	if(!fexists(global_music_budget_path))
		nexus_player_music_global_budget_loaded = FALSE
		nexus_player_music_global_budget_day = ""
		nexus_player_music_global_budget_bytes = null
		nexus_player_music_global_stored_bytes = null
		loadNexusPlayerMusicGlobalBudget()
		nexusSmokeAssert(nexus_player_music_global_budget_bytes == 0 && nexus_player_music_global_stored_bytes == 0, "a clean server initializes the player-music archive as already full")
		var/datum/NexusPlayerMusicLibrary/clean_music_quota_test = new("nexusmusicclean")
		clean_music_quota_test.loaded = TRUE
		clean_music_quota_test.upload_budget_day = getNexusPlayerMusicDayKey()
		nexusSmokeAssert(!length(clean_music_quota_test.getUploadAuthorizationError(nexus_player_music_min_file_bytes)), "a clean server rejects its first valid-size music upload")
		del(clean_music_quota_test)
	nexusSmokeAssert(text2path("/datum/NexusPlayerMusicLibrary") && text2path("/datum/NexusMusicLibraryWindow"), "player music library data or browser controller is missing")
	nexusSmokeAssert(text2path("/mob/verb/Play_Music") && text2path("/mob/verb/Stop_Player_Music") && !text2path("/mob/verb/Stream_Music_to_Everyone_Nearby"), "safe player music verbs are missing or the unsafe remote streamer still exists")
	var/obj/Play_Music/music_hotbar_test = new
	nexusSmokeAssert(music_hotbar_test.can_hotbar && music_hotbar_test.hotbar_type == "Other", "the existing Play Music hotkey no longer opens the library")
	del(music_hotbar_test)
	nexusSmokeAssert(isNexusPlayerMusicUploadName("action.ogg") && isNexusPlayerMusicUploadName("ACTION.OGG") && !isNexusPlayerMusicUploadName("action.ogg.exe"), "music upload extension preflight is not fail-closed")
	nexusSmokeAssert(isNexusPlayerMusicAccountKey("smokemusic") && !isNexusPlayerMusicAccountKey("../smokemusic"), "music account paths accept traversal characters")
	var/smoke_track_id = md5("nexus-player-music-smoke")
	nexusSmokeAssert(isNexusPlayerMusicHex(smoke_track_id, 32) && getNexusPlayerMusicTrackPath("smokemusic", smoke_track_id) == "data/PlayerMusic/smokemusic/[smoke_track_id].ogg" && !getNexusPlayerMusicTrackPath("../smokemusic", smoke_track_id), "music track paths are not derived exclusively from safe server identifiers")
	var/sanitized_music_title = normalizeNexusPlayerMusicTitle("  <script>Battle\nTheme</script>  ")
	nexusSmokeAssert(sanitized_music_title == "scriptBattle Theme/script" && length(sanitized_music_title) <= nexus_player_music_title_limit, "music titles retain HTML or control characters")
	var/list/built_in_music = getNexusBuiltInMusicCatalog()
	nexusSmokeAssert(built_in_music.len == 7 && islist(built_in_music["iron_lotus"]) && built_in_music["iron_lotus"]["file"] == 'IronLotus.ogg', "built-in action music was not preserved in the new library")
	var/list/valid_music_inspection = inspectNexusPlayerMusicUpload('IronLotus.ogg', "IronLotus.ogg")
	nexusSmokeAssert(valid_music_inspection["ok"] && valid_music_inspection["bytes"] > nexus_player_music_min_file_bytes && isNexusPlayerMusicHex(valid_music_inspection["hash"], 40), "known-good OGG music fails upload preflight")
	var/list/disguised_music_inspection = inspectNexusPlayerMusicUpload('IronLotus.ogg', "IronLotus.ogg.exe")
	nexusSmokeAssert(!disguised_music_inspection["ok"], "a disguised non-OGG filename passes upload inspection")
	var/sound/query_sound = sound('IronLotus.ogg', repeat = TRUE, channel = nexus_player_music_validation_channel, volume = 0)
	query_sound.len = 300
	var/sound/wrong_query_sound = sound('CarnivalMeme.ogg', repeat = TRUE, channel = nexus_player_music_validation_channel, volume = 0)
	wrong_query_sound.len = 120
	nexusSmokeAssert(getNexusPlayerMusicQueryDuration(list(wrong_query_sound, query_sound), 'IronLotus.ogg', nexus_player_music_validation_channel) == 300, "decoder telemetry accepts the wrong file or loses the expected duration")
	query_sound.len = 0
	nexusSmokeAssert(!getNexusPlayerMusicQueryDuration(list(query_sound), 'IronLotus.ogg', nexus_player_music_validation_channel), "zero-length decoder telemetry is accepted")
	del(query_sound)
	del(wrong_query_sound)
	var/music_smoke_account = "nexusmusicsmoke"
	var/music_smoke_directory = "data/PlayerMusic/[music_smoke_account]/"
	if(fexists(music_smoke_directory)) fdel(music_smoke_directory)
	var/datum/NexusPlayerMusicLibrary/music_save_test = new(music_smoke_account)
	music_save_test.loaded = TRUE
	music_save_test.upload_budget_day = getNexusPlayerMusicDayKey()
	music_save_test.upload_budget_bytes = 1234
	music_save_test.last_upload_time = max(1, world.realtime - 20)
	music_save_test.last_play_time = max(1, world.realtime - 10)
	music_save_test.last_validation_time = max(1, world.realtime - 5)
	var/datum/NexusPlayerMusicTrack/music_track_test = new
	music_track_test.id = md5("nexus-player-music-ready-smoke")
	music_track_test.title = "Smoke Track"
	music_track_test.byte_size = valid_music_inspection["bytes"]
	music_track_test.content_hash = valid_music_inspection["hash"]
	music_track_test.uploaded_at = world.realtime
	music_save_test.tracks += music_track_test
	var/music_smoke_track_path = music_save_test.getTrackPath(music_track_test.id)
	nexusSmokeAssert(fcopy('IronLotus.ogg', music_smoke_track_path), "player music smoke resource could not be copied into quarantine")
	nexusSmokeAssert(reconcileNexusPlayerMusicStoredBytes() >= music_track_test.byte_size, "player music archive reconciliation ignores a stored or orphaned OGG")
	nexusSmokeAssert(!music_track_test.isReady(), "a newly uploaded track bypasses decoder quarantine")
	nexusSmokeAssert(!music_save_test.markTrackValidated(music_track_test.id, music_track_test.content_hash, 0) && !music_save_test.markTrackValidated(music_track_test.id, music_track_test.content_hash, 300.1), "invalid decoder durations can mark a track ready")
	nexusSmokeAssert(music_save_test.markTrackValidated(music_track_test.id, music_track_test.content_hash, 180) && music_track_test.isReady(), "complete decoder metadata does not mark a track ready")
	music_track_test.validated_hash = sha1("different music")
	nexusSmokeAssert(!music_track_test.isReady(), "a divergent validation fingerprint leaves a track ready")
	music_track_test.validated_hash = music_track_test.content_hash
	music_track_test.validation_version = 0
	nexusSmokeAssert(!music_track_test.isReady(), "stale decoder policy metadata leaves a track ready")
	music_track_test.clearValidation()
	nexusSmokeAssert(!music_track_test.isReady() && music_save_test.isTrackMetadataValid(music_track_test), "stale decoder metadata cannot migrate back to a pending track")
	nexusSmokeAssert(music_save_test.markTrackValidated(music_track_test.id, music_track_test.content_hash, 180), "a migrated pending track cannot be revalidated")
	nexusSmokeAssert(music_save_test.save(), "player music metadata could not be persisted")
	var/datum/NexusPlayerMusicLibrary/music_load_test = new(music_smoke_account)
	music_load_test.load()
	var/datum/NexusPlayerMusicTrack/reloaded_music_track = music_load_test.findTrack(music_track_test.id)
	nexusSmokeAssert(music_load_test.upload_budget_bytes == 1234 && music_load_test.last_upload_time == music_save_test.last_upload_time && music_load_test.last_play_time == music_save_test.last_play_time && music_load_test.last_validation_time == music_save_test.last_validation_time, "player music account budgets or cooldowns do not survive reload")
	nexusSmokeAssert(reloaded_music_track && reloaded_music_track.isReady() && reloaded_music_track.duration_seconds == 180 && reloaded_music_track.validated_hash == reloaded_music_track.content_hash && reloaded_music_track.validation_version == nexus_player_music_validation_version, "ready decoder metadata does not survive library reload")
	del(music_save_test)
	del(music_load_test)
	if(fexists(music_smoke_track_path)) fdel(music_smoke_track_path)
	if(fexists(music_smoke_directory)) fdel(music_smoke_directory)

proc/runNexusProfileArtSmokeTests()
	nexusSmokeAssert(nexus_profile_art_max_file_bytes == 8 * 1024 * 1024 && nexus_profile_art_max_dimension == 3840 && nexus_profile_art_max_pixels == 3840 * 2160 && nexus_profile_art_daily_account_bytes == 24 * 1024 * 1024, "profile-art upload bounds changed unexpectedly")
	var/profile_art_budget_path = getNexusProfileArtBudgetPath()
	if(!fexists(profile_art_budget_path))
		nexus_profile_art_budget_loaded = FALSE
		nexus_profile_art_budget_day = ""
		nexus_profile_art_global_daily_bytes = null
		nexus_profile_art_global_stored_bytes = null
		nexus_profile_art_account_daily_bytes = null
		loadNexusProfileArtBudget()
		nexusSmokeAssert(nexus_profile_art_global_daily_bytes == 0 && nexus_profile_art_global_stored_bytes == 0 && islist(nexus_profile_art_account_daily_bytes) && !length(getNexusProfileArtUploadAuthorizationError("profileartclean", 1, nexus_profile_art_min_file_bytes)), "a clean server initializes the profile-art budget as already full")
	nexusSmokeAssert(isNexusProfileArtUploadName("portrait.png") && isNexusProfileArtUploadName("PORTRAIT.PNG") && isNexusProfileArtUploadName("portrait.jpg") && isNexusProfileArtUploadName("portrait.JPEG") && isNexusProfileArtUploadName("portrait.webp") && isNexusProfileArtUploadName("PORTRAIT.WEBP") && isNexusProfileArtUploadName("portrait.webm") && isNexusProfileArtUploadName("PORTRAIT.WEBM") && !isNexusProfileArtUploadName("portrait.webp.exe") && !isNexusProfileArtUploadName("portrait.webm.exe") && !isNexusProfileArtUploadName("portrait.gif") && !isNexusProfileArtUploadName("portrait.dmi"), "profile-art filename preflight does not enforce the PNG/JPEG/WEBP/WEBM allowlist")
	var/profile_art_inspection_ticket = md5("nexus-profile-art-inspection-smoke")
	nexusSmokeAssert(isNexusProfileArtInspectionTicket(profile_art_inspection_ticket) && getNexusProfileArtInspectionRequestPath(profile_art_inspection_ticket) == "data/ProfileImages/.inspect-[profile_art_inspection_ticket].request" && getNexusProfileArtInspectionResultPath(profile_art_inspection_ticket) == "data/ProfileImages/.inspect-[profile_art_inspection_ticket].result" && !isNexusProfileArtInspectionTicket("../[profile_art_inspection_ticket]"), "profile-art binary inspection paths are not derived exclusively from a validated ticket")
	var/profile_art_inspector_ready_path = "data/ProfileImages/.profile-media-inspector.ready"
	var/profile_art_created_fake_inspector = !fexists(profile_art_inspector_ready_path)
	var/profile_art_inspection_upload_path = "data/ProfileImages/.upload-profileartsmoke-slot1-[profile_art_inspection_ticket].webp"
	var/profile_art_inspection_bytes = 72040
	var/profile_art_inspection_hash = sha1("nexus-profile-art-inspection-result-smoke")
	if(profile_art_created_fake_inspector)
		nexusSmokeAssert(text2file("smoke\n", profile_art_inspector_ready_path), "profile-art smoke could not stage its local binary-inspector readiness marker")
		var/profile_art_inspection_request_path = getNexusProfileArtInspectionRequestPath(profile_art_inspection_ticket)
		var/profile_art_inspection_result_path = getNexusProfileArtInspectionResultPath(profile_art_inspection_ticket)
		spawn
			for(var/profile_art_inspector_tick = 1, profile_art_inspector_tick <= nexus_profile_art_external_inspection_timeout, profile_art_inspector_tick++)
				if(fexists(profile_art_inspection_request_path))
					var/list/profile_art_fake_request_fields = splittext(replacetext(file2text(profile_art_inspection_request_path), ascii2text(13), ""), "\n")
					var/profile_art_fake_expected_hash = profile_art_fake_request_fields.len >= 4 ? profile_art_fake_request_fields[4] : ""
					text2file("status=ok&format=webp&bytes=72040&width=360&height=543&hash=[profile_art_fake_expected_hash]", profile_art_inspection_result_path)
					break
				sleep(1)
	else
		var/profile_art_inspection_source_path = "data/ProfileImages/profile-media-inspector-smoke.webp"
		nexusSmokeAssert(fexists(profile_art_inspection_source_path) && fcopy(profile_art_inspection_source_path, profile_art_inspection_upload_path), "the external profile-art inspector started without a usable WEBP smoke fixture")
		profile_art_inspection_bytes = length(file(profile_art_inspection_upload_path))
		profile_art_inspection_hash = sha1(file(profile_art_inspection_upload_path))
	var/list/profile_art_external_inspection = inspectNexusProfileArtExternally(profile_art_inspection_upload_path, "webp", profile_art_inspection_ticket, profile_art_inspection_bytes, profile_art_inspection_hash)
	nexusSmokeAssert(profile_art_external_inspection["ok"] && profile_art_external_inspection["width"] == 360 && profile_art_external_inspection["height"] == 543, "profile-art request/result inspection protocol rejected a bound matching WEBP response")
	if(profile_art_created_fake_inspector) fdel(profile_art_inspector_ready_path)
	else
		fdel(profile_art_inspection_upload_path)
		fdel("data/ProfileImages/profile-media-inspector-smoke.webp")
	var/profile_art_fixture_hash = sha1("nexus-profile-art-generation-smoke")
	nexusSmokeAssert(getNexusPlayerProfileImagePathForKey("Smoke Key", 2, profile_art_fixture_hash, "png") == "data/ProfileImages/smokekey-slot2-[profile_art_fixture_hash].png" && getNexusPlayerProfileImagePathForKey("Smoke Key", 2, profile_art_fixture_hash, "jpeg") == "data/ProfileImages/smokekey-slot2-[profile_art_fixture_hash].jpg" && getNexusPlayerProfileImagePathForKey("Smoke Key", 2, profile_art_fixture_hash, "webp") == "data/ProfileImages/smokekey-slot2-[profile_art_fixture_hash].webp" && getNexusPlayerProfileImagePathForKey("Smoke Key", 2, profile_art_fixture_hash, "webm") == "data/ProfileImages/smokekey-slot2-[profile_art_fixture_hash].webm" && !getNexusPlayerProfileImagePathForKey("../Smoke Key", 0, profile_art_fixture_hash, "png") && getNexusPlayerProfileImagePathFromSaveName("smokekey-slot3.sav") == "data/ProfileImages/smokekey-slot3.dmi" && !getNexusPlayerProfileImagePathFromSaveName("../smokekey-slot3.sav"), "profile-art generation paths are not derived exclusively from a validated account, slot, hash, and format")
	var/list/profile_art_webp_vp8_raw = list(82, 73, 70, 70, 22, 0, 0, 0, 87, 69, 66, 80, 86, 80, 56, 32, 10, 0, 0, 0, 0, 0, 0, 157, 1, 42, 104, 1, 31, 2)
	var/list/profile_art_webp_vp8l_raw = list(82, 73, 70, 70, 18, 0, 0, 0, 87, 69, 66, 80, 86, 80, 56, 76, 5, 0, 0, 0, 47, 127, 194, 119, 0, 0)
	var/list/profile_art_webp_vp8x_raw = list(82, 73, 70, 70, 22, 0, 0, 0, 87, 69, 66, 80, 86, 80, 56, 88, 10, 0, 0, 0, 0, 0, 0, 0, 255, 4, 0, 207, 2, 0)
	var/list/profile_art_webp_vp8_dimensions = getNexusWebpDimensionsFromRaw(profile_art_webp_vp8_raw)
	var/list/profile_art_webp_vp8l_dimensions = getNexusWebpDimensionsFromRaw(profile_art_webp_vp8l_raw)
	var/list/profile_art_webp_vp8x_dimensions = getNexusWebpDimensionsFromRaw(profile_art_webp_vp8x_raw)
	nexusSmokeAssert(getNexusProfileArtSignatureFormatFromRaw(profile_art_webp_vp8_raw) == "webp" && islist(profile_art_webp_vp8_dimensions) && profile_art_webp_vp8_dimensions["width"] == 360 && profile_art_webp_vp8_dimensions["height"] == 543, "profile-art lossy WEBP signature or VP8 dimensions are not recognized")
	nexusSmokeAssert(getNexusProfileArtSignatureFormatFromRaw(profile_art_webp_vp8l_raw) == "webp" && islist(profile_art_webp_vp8l_dimensions) && profile_art_webp_vp8l_dimensions["width"] == 640 && profile_art_webp_vp8l_dimensions["height"] == 480, "profile-art lossless WEBP signature or VP8L dimensions are not recognized")
	nexusSmokeAssert(getNexusProfileArtSignatureFormatFromRaw(profile_art_webp_vp8x_raw) == "webp" && islist(profile_art_webp_vp8x_dimensions) && profile_art_webp_vp8x_dimensions["width"] == 1280 && profile_art_webp_vp8x_dimensions["height"] == 720, "profile-art extended WEBP signature or VP8X dimensions are not recognized")
	var/list/profile_art_webm_raw = list(26, 69, 223, 163, 119, 101, 98, 109, 224, 136, 176, 130, 7, 128, 186, 130, 4, 56)
	var/list/profile_art_webm_dimensions = getNexusWebmDimensionsFromRaw(profile_art_webm_raw)
	var/profile_art_webm_signature = getNexusProfileArtSignatureFormatFromRaw(profile_art_webm_raw)
	var/profile_art_webm_width = islist(profile_art_webm_dimensions) ? profile_art_webm_dimensions["width"] : 0
	var/profile_art_webm_height = islist(profile_art_webm_dimensions) ? profile_art_webm_dimensions["height"] : 0
	nexusSmokeAssert(profile_art_webm_signature == "webm" && profile_art_webm_width == 1920 && profile_art_webm_height == 1080, "profile-art WEBM signature or EBML dimensions are not recognized (signature=[profile_art_webm_signature], width=[profile_art_webm_width], height=[profile_art_webm_height], bytes=[length(profile_art_webm_raw)])")
	nexusSmokeAssert(isNexusProfileArtDimensionsValid(3840, 2160) && isNexusProfileArtDimensionsValid(2160, 3840) && !isNexusProfileArtDimensionsValid(3841, 2160) && !isNexusProfileArtDimensionsValid(3840, 2161) && !isNexusProfileArtDimensionsValid(3840, 3840), "profile-art 4K landscape/portrait bounds are invalid")
	var/profile_art_png_source = "data/ProfileImages/.profile-art-smoke-source.png"
	var/profile_art_jpg_source = "data/ProfileImages/.profile-art-smoke-source.jpg"
	fdel(profile_art_png_source)
	fdel(profile_art_jpg_source)
	nexusSmokeAssert(fcopy('Slime64.png', profile_art_png_source) && fcopy('Ability.jpg', profile_art_jpg_source), "known-good PNG/JPEG resources could not be staged for raw profile-art smoke coverage")
	var/profile_art_png_hash = sha1(file(profile_art_png_source))
	var/profile_art_jpg_hash = sha1(file(profile_art_jpg_source))
	nexusSmokeAssert(getNexusProfileArtSignatureFormat(file(profile_art_png_source)) == "png" && getNexusProfileArtSignatureFormat(file(profile_art_jpg_source)) == "jpg" && isNexusProfileArtHash(profile_art_png_hash) && isNexusProfileArtHash(profile_art_jpg_hash), "profile-art content signatures or raw fingerprints do not recognize valid PNG/JPEG files")
	var/icon/profile_art_png_probe = icon(file(profile_art_png_source), "", SOUTH, 1, FALSE)
	var/icon/profile_art_jpg_probe = icon(file(profile_art_jpg_source), "", SOUTH, 1, FALSE)
	nexusSmokeAssert(profile_art_png_probe && profile_art_jpg_probe && profile_art_png_probe.Width() <= nexus_profile_art_max_dimension && profile_art_png_probe.Height() <= nexus_profile_art_max_dimension && profile_art_jpg_probe.Width() <= nexus_profile_art_max_dimension && profile_art_jpg_probe.Height() <= nexus_profile_art_max_dimension, "known-good raw PNG/JPEG files fail the bounded transient decode probe")
	var/profile_art_png_account = "profileartsmoke"
	var/profile_art_jpg_account = "profileartsmokejpg"
	var/profile_art_png_path = getNexusPlayerProfileImagePathForKey(profile_art_png_account, 1, profile_art_png_hash, "png")
	var/profile_art_jpg_path = getNexusPlayerProfileImagePathForKey(profile_art_jpg_account, 1, profile_art_jpg_hash, "jpg")
	deleteNexusPlayerProfileImageForKey(profile_art_png_account, 1)
	deleteNexusPlayerProfileImageForKey(profile_art_jpg_account, 1)
	loadNexusProfileArtBudget()
	var/profile_art_stored_before = nexus_profile_art_global_stored_bytes
	nexusSmokeAssert(fcopy(profile_art_png_source, profile_art_png_path) && fcopy(profile_art_jpg_source, profile_art_jpg_path), "raw profile art cannot be committed to immutable account-slot-hash generations")
	var/profile_art_generation_bytes = length(file(profile_art_png_path)) + length(file(profile_art_jpg_path))
	noteNexusProfileArtStoredDelta(profile_art_generation_bytes)
	nexusSmokeAssert(sha1(file(profile_art_png_path)) == profile_art_png_hash && sha1(file(profile_art_jpg_path)) == profile_art_jpg_hash && getNexusProfileArtSignatureFormat(file(profile_art_png_path)) == "png" && getNexusProfileArtSignatureFormat(file(profile_art_jpg_path)) == "jpg", "stored profile art no longer matches the exact uploaded PNG/JPEG bytes")
	var/profile_art_reconciled_with_generations = reconcileNexusProfileArtStoredBytes(FALSE)
	nexusSmokeAssert(profile_art_reconciled_with_generations >= profile_art_stored_before + profile_art_generation_bytes, "raw profile-art reconciliation does not count valid PNG/JPEG generations")
	nexus_profile_art_global_stored_bytes = profile_art_reconciled_with_generations
	nexusSmokeAssert(deleteNexusPlayerProfileImageForKey(profile_art_png_account, 1) && deleteNexusPlayerProfileImageForKey(profile_art_jpg_account, 1) && !fexists(profile_art_png_path) && !fexists(profile_art_jpg_path), "raw profile-art slot deletion does not remove PNG/JPEG generations")
	nexus_profile_art_global_stored_bytes = reconcileNexusProfileArtStoredBytes()
	nexusSmokeAssert(nexus_profile_art_global_stored_bytes == profile_art_stored_before, "raw profile-art deletion does not restore the reconciled archive counter")
	var/profile_art_orphan_path = getNexusPlayerProfileImagePathForKey("profileartorphan", 1, profile_art_png_hash, "png")
	fdel(getNexusCharacterSavePathForKey("profileartorphan", 1))
	nexusSmokeAssert(fcopy(profile_art_png_source, profile_art_orphan_path), "profile-art orphan cleanup fixture could not be created")
	noteNexusProfileArtStoredDelta(length(file(profile_art_orphan_path)))
	nexus_profile_art_global_stored_bytes = reconcileNexusProfileArtStoredBytes()
	nexusSmokeAssert(nexus_profile_art_global_stored_bytes == profile_art_stored_before && !fexists(profile_art_orphan_path), "profile-art reconciliation does not remove a generation whose character slot no longer exists")
	fdel(profile_art_png_source)
	fdel(profile_art_jpg_source)

	var/profile_persistence_path = "nexus-smoke-profile.sav"
	fdel(profile_persistence_path)
	var/mob/NexusSmokeTest/profile_persistence_test = new
	var/savefile/profile_persistence_save = new(profile_persistence_path)
	profile_persistence_test.Write(profile_persistence_save)
	profile_persistence_test.writeNexusPlayerProfileTextSaveFields(profile_persistence_save)
	profile_persistence_test.writeNexusPlayerProfileArtSaveFields(profile_persistence_save)
	profile_persistence_save.Flush()
	profile_persistence_save = null
	nexusSmokeAssert(profile_persistence_test.isNexusPlayerProfileTextPersisted(profile_persistence_path) && profile_persistence_test.isNexusPlayerProfileArtMetadataPersisted(profile_persistence_path), "initial SOUTH/empty/live-sprite profile values do not survive a fresh savefile read")
	profile_persistence_test.player_desc = "Persisted profile smoke"
	profile_persistence_test.player_profile_name = "Smoke Profile"
	profile_persistence_test.player_profile_title = "Persistence Probe"
	profile_persistence_test.player_profile_portrait_direction = NORTH
	profile_persistence_test.player_profile_markup_version = 1
	profile_persistence_test.player_profile_portrait_mode = "custom"
	profile_persistence_test.player_profile_art_hash = sha1("nexus-profile-persistence-smoke")
	profile_persistence_test.player_profile_art_format = "webp"
	profile_persistence_test.player_profile_art_bytes = 72040
	profile_persistence_test.player_profile_art_width = 360
	profile_persistence_test.player_profile_art_height = 543
	profile_persistence_test.player_profile_art_version = nexus_profile_art_policy_version
	profile_persistence_save = new(profile_persistence_path)
	profile_persistence_test.Write(profile_persistence_save)
	profile_persistence_test.writeNexusPlayerProfileTextSaveFields(profile_persistence_save)
	profile_persistence_test.writeNexusPlayerProfileArtSaveFields(profile_persistence_save)
	profile_persistence_save.Flush()
	profile_persistence_save = null
	nexusSmokeAssert(profile_persistence_test.isNexusPlayerProfileTextPersisted(profile_persistence_path) && profile_persistence_test.isNexusPlayerProfileArtMetadataPersisted(profile_persistence_path), "non-default profile text or WEBP metadata does not survive immediate savefile reopen")
	profile_persistence_test.player_desc = initial(profile_persistence_test.player_desc)
	profile_persistence_test.player_profile_name = initial(profile_persistence_test.player_profile_name)
	profile_persistence_test.player_profile_title = initial(profile_persistence_test.player_profile_title)
	profile_persistence_test.player_profile_portrait_direction = initial(profile_persistence_test.player_profile_portrait_direction)
	profile_persistence_test.player_profile_markup_version = initial(profile_persistence_test.player_profile_markup_version)
	profile_persistence_test.clearNexusPlayerProfileArtMetadata()
	profile_persistence_save = new(profile_persistence_path)
	profile_persistence_test.Write(profile_persistence_save)
	profile_persistence_test.writeNexusPlayerProfileTextSaveFields(profile_persistence_save)
	profile_persistence_test.writeNexusPlayerProfileArtSaveFields(profile_persistence_save)
	profile_persistence_save.Flush()
	profile_persistence_save = null
	nexusSmokeAssert(profile_persistence_test.isNexusPlayerProfileTextPersisted(profile_persistence_path) && profile_persistence_test.isNexusPlayerProfileArtMetadataPersisted(profile_persistence_path), "resetting a profile to SOUTH/empty/live-sprite values leaves stale savefile fields")
	del(profile_persistence_test)
	fdel(profile_persistence_path)

proc/nexusSmokeStatAllocation(list/profile)
	var/list/allocation = list()
	var/list/caps = profile["caps"]
	var/remaining = profile["budget"]
	for(var/stat_id in NEXUS_CREATION_STATS) allocation[stat_id] = 0
	while(remaining > 0)
		var/allocated
		for(var/stat_id in NEXUS_CREATION_STATS)
			if(remaining <= 0) break
			if(allocation[stat_id] >= caps[stat_id]) continue
			allocation[stat_id]++
			remaining--
			allocated = TRUE
		if(!allocated) CRASH("Unable to build a valid smoke-test stat allocation")
	return allocation

proc/runNexusPlanetMapScannerSmokeTests()
	var/list/planet_map_manifest = getNexusPlanetMapRegionManifest()
	var/list/desert_map_region = getNexusPlanetMapRegion("desert")
	var/list/jungle_map_region = getNexusPlanetMapRegion("jungle")
	var/list/android_map_region = getNexusPlanetMapRegion("android")
	var/list/atlantis_map_region = getNexusPlanetMapRegion("atlantis")
	nexusSmokeAssert(planet_map_manifest.len == 9 && desert_map_region["area_type"] == /area/Desert && jungle_map_region["area_type"] == /area/Jungle && android_map_region["area_type"] == /area/Android && atlantis_map_region["z_level"] == 11, "planet-map manifest is missing a canonical surface or places Atlantis on the wrong z-level")
	nexusSmokeAssert(desert_map_region["max_x"] == 250 && desert_map_region["max_y"] == 250 && jungle_map_region["min_y"] == 251 && jungle_map_region["max_x"] == 250 && android_map_region["min_x"] == 251 && android_map_region["min_y"] == 251, "shared z=14 planet regions overlap or have invalid bounds")
	var/list/resolved_desert_map_region = resolveNexusPlanetMapRegion(14, /area/Desert, 120, 170)
	var/list/resolved_jungle_map_region = resolveNexusPlanetMapRegion(14, /area/Jungle, 220, 280)
	var/list/resolved_android_map_region = resolveNexusPlanetMapRegion(14, /area/Android, 290, 270)
	var/list/resolved_atlantis_map_region = resolveNexusPlanetMapRegion(11, /area/Atlantis, 118, 132)
	nexusSmokeAssert(resolved_desert_map_region["region_id"] == "desert" && resolved_jungle_map_region["region_id"] == "jungle" && resolved_android_map_region["region_id"] == "android" && resolved_atlantis_map_region["region_id"] == "atlantis", "canonical planet entry coordinates resolve to the wrong surface")
	nexusSmokeAssert(resolveNexusPlanetMapRegion(1, /area/Earth, 250, 250)["region_id"] == "earth" && resolveNexusPlanetMapRegion(3, /area/Namekian, 250, 250)["region_id"] == "namekian" && resolveNexusPlanetMapRegion(4, /area/Braal, 250, 250)["region_id"] == "braal" && resolveNexusPlanetMapRegion(8, /area/Arconia, 250, 250)["region_id"] == "arconia" && resolveNexusPlanetMapRegion(12, /area/Ice, 250, 250)["region_id"] == "ice", "a canonical single-z planet no longer resolves at its arrival coordinates")
	nexusSmokeAssert(!resolveNexusPlanetMapRegion(14, /area/Jungle, 400, 400) && !resolveNexusPlanetMapRegion(4, /area/Atlantis, 419, 102) && !resolveNexusPlanetMapRegion(2, /area/Mining_Cave, 250, 250) && !resolveNexusPlanetMapRegion(16, /area/Space, 250, 250) && !resolveNexusPlanetMapRegion(11, /area/Inside, 250, 250) && !resolveNexusPlanetMapRegion(11, /area/Final_Realm, 250, 250), "planet-map manifest exposes an unused quadrant, portal, cave, space, or interior realm")
	var/desert_map_cache_key = getNexusPlanetMapCacheKey(14, /area/Desert, "desert")
	var/jungle_map_cache_key = getNexusPlanetMapCacheKey(14, /area/Jungle, "jungle")
	var/android_map_cache_key = getNexusPlanetMapCacheKey(14, /area/Android, "android")
	nexusSmokeAssert(desert_map_cache_key && jungle_map_cache_key && android_map_cache_key && desert_map_cache_key != jungle_map_cache_key && jungle_map_cache_key != android_map_cache_key, "shared-z planet scans do not have isolated cache identities")
	var/datum/NexusPlanetMapScan/planet_map_region_contract = new(desert_map_region)
	nexusSmokeAssert(planet_map_region_contract.min_x == 1 && planet_map_region_contract.min_y == 1 && planet_map_region_contract.max_x == 250 && planet_map_region_contract.max_y == 250 && planet_map_region_contract.total_tiles == 62500, "planet-map scan did not inherit exact manifest bounds and work total")
	del(planet_map_region_contract)
	var/turf/planet_map_raster_turf
	for(var/turf/planet_map_candidate in world)
		var/area/planet_map_candidate_area = planet_map_candidate.loc
		if(planet_map_candidate.z == 1 && planet_map_candidate_area && planet_map_candidate_area.type == /area/Earth)
			planet_map_raster_turf = planet_map_candidate
			break
	nexusSmokeAssert(planet_map_raster_turf, "planet-map raster smoke test could not locate an Earth turf")
	var/list/earth_map_region = getNexusPlanetMapRegion("earth")
	var/datum/NexusPlanetMapScan/planet_map_raster_scan = new(earth_map_region)
	planet_map_raster_scan.min_x = planet_map_raster_turf.x
	planet_map_raster_scan.max_x = planet_map_raster_turf.x
	planet_map_raster_scan.min_y = planet_map_raster_turf.y
	planet_map_raster_scan.max_y = planet_map_raster_turf.y
	planet_map_raster_scan.render_total_tiles = 1
	planet_map_raster_scan.total_tiles = 1
	nexusSmokeAssert(planet_map_raster_scan.renderMap() && planet_map_raster_scan.map_icon && planet_map_raster_scan.map_icon.Width() == 1 && planet_map_raster_scan.map_icon.Height() == 1, "planet-map rasterizer did not produce its exact one-tile crop")
	nexusSmokeAssert(planet_map_raster_scan.matching_tiles == 1 && planet_map_raster_scan.tiles_scanned == 1 && planet_map_raster_scan.unique_appearances == 1 && planet_map_raster_scan.map_icon.GetPixel(1, 1), "planet-map rasterizer omitted matching terrain, metrics, or output color")
	planet_map_raster_scan.status = "ready"
	var/earth_map_cache_key = getNexusPlanetMapCacheKey(1, /area/Earth, "earth")
	var/datum/NexusPlanetMapScan/previous_earth_map_scan = nexus_planet_map_scan_cache[earth_map_cache_key]
	nexus_planet_map_scan_cache[earth_map_cache_key] = planet_map_raster_scan
	var/mob/NexusSmokeTest/planet_map_cache_viewer_a = new(planet_map_raster_turf)
	var/mob/NexusSmokeTest/planet_map_cache_viewer_b = new(planet_map_raster_turf)
	var/list/planet_map_cache_state_a = planet_map_cache_viewer_a.requestNexusPlanetMapScan()
	var/list/planet_map_cache_state_b = planet_map_cache_viewer_b.requestNexusPlanetMapScan()
	nexusSmokeAssert(planet_map_cache_state_a["status"] == "ready" && planet_map_cache_state_b["status"] == "ready" && planet_map_cache_state_a["scan_id"] == planet_map_cache_state_b["scan_id"] && getNexusPlanetMapScan(1, /area/Earth, "earth") == planet_map_raster_scan, "multiple players do not reuse the same ready planet-map cache")
	if(previous_earth_map_scan) nexus_planet_map_scan_cache[earth_map_cache_key] = previous_earth_map_scan
	else nexus_planet_map_scan_cache -= earth_map_cache_key
	del(planet_map_cache_viewer_a)
	del(planet_map_cache_viewer_b)
	del(planet_map_raster_scan)

proc/runNexusPlanetaryControlSmokeTests()
	set background = TRUE
	var/turf/control_turf
	var/turf/adjacent_turf
	var/turf/remote_control_turf
	var/turf/remote_adjacent_turf
	var/turf/mining_cave_turf
	var/turf/nonplanet_cave_entrance_turf
	for(var/turf/candidate in world)
		var/area/candidate_area = candidate.loc
		if(!candidate_area) continue
		if(!mining_cave_turf && istype(candidate_area, /area/Mining_Cave)) mining_cave_turf = candidate
		if(!nonplanet_cave_entrance_turf && istype(candidate_area, /area/Hell)) nonplanet_cave_entrance_turf = candidate
		if(!control_turf && candidate.z == Z_LEVEL_EARTH && candidate_area.type == /area/Earth)
			for(var/direction in list(NORTH, SOUTH, EAST, WEST))
				var/turf/neighbor = get_step(candidate, direction)
				var/area/neighbor_area = neighbor ? neighbor.loc : null
				if(neighbor && neighbor_area && neighbor_area.type == /area/Earth)
					control_turf = candidate
					adjacent_turf = neighbor
					break
		if(!remote_control_turf && candidate.z == Z_LEVEL_Namekian && candidate_area.type == /area/Namekian)
			for(var/direction in list(NORTH, SOUTH, EAST, WEST))
				var/turf/neighbor = get_step(candidate, direction)
				var/area/neighbor_area = neighbor ? neighbor.loc : null
				if(neighbor && neighbor_area && neighbor_area.type == /area/Namekian)
					remote_control_turf = candidate
					remote_adjacent_turf = neighbor
					break
		if(control_turf && remote_control_turf && mining_cave_turf && nonplanet_cave_entrance_turf) break
	nexusSmokeAssert(control_turf && adjacent_turf && remote_control_turf && remote_adjacent_turf && mining_cave_turf && nonplanet_cave_entrance_turf, "planetary control smoke test could not find its Earth, Namekian, cave, or nonplanet test turfs")

	var/list/original_controls = nexus_planet_controls
	var/original_controls_dirty = nexus_planet_controls_dirty
	var/original_king_of_braal = king_of_Braal
	nexus_planet_controls = list()
	initializeNexusPlanetControls()
	var/datum/NexusPlanetControl/control = getNexusPlanetControl("earth", FALSE)

	var/mob/NexusSmokeTest/ruler = new(control_turf)
	ruler.playerCharacter = TRUE
	ruler.displaykey = "Control Ruler"
	ruler.active_character_slot = 1
	ruler.character_made_time = 101
	ruler.name = "Ruler"
	var/obj/League/ruling_league = new
	ruling_league.league_id = "nexus-control-ruling-id"
	ruling_league.name = "Same Name League"
	ruling_league.league_leader = "Control Ruler"
	ruling_league.league_rank = 7
	ruling_league.Move(ruler)
	nexusSmokeAssert(control.setController(ruler, ruling_league), "a valid league ruler could not take an unclaimed control point")
	control.resource_tax_rate = 20
	control.essence_tax_rate = 25

	var/mob/NexusSmokeTest/taxpayer = new(control_turf)
	taxpayer.playerCharacter = TRUE
	taxpayer.displaykey = "Control Taxpayer"
	taxpayer.active_character_slot = 1
	taxpayer.character_made_time = 202
	taxpayer.name = "Taxpayer"
	taxpayer.Race = "Human"
	new /obj/Resources(taxpayer)
	nexusSmokeAssert(taxpayer.gainNexusResources(100, "smoke income") == 80 && taxpayer.Res() == 80 && control.resource_treasury == 20, "resource income tax did not withhold the configured amount into the planetary treasury")
	nexusSmokeAssert(taxpayer.gainArcaneEssence(10, "smoke essence") == 7.5 && taxpayer.arcane_essence == 7.5 && taxpayer.arcane_essence_lifetime == 10 && control.essence_treasury == 2.5, "Arcane Essence income tax changed lifetime gains or failed to withhold into the treasury")
	var/list/unclaimed_fractional_income = taxpayer.applyNexusPlanetaryIncomeTax(resource_gross = 0.25, control_override = getNexusPlanetControl("namekian", FALSE))
	nexusSmokeAssertNear(unclaimed_fractional_income["resource_net"], 0.25, 0.000001, "planetary tax quantized fractional Resource income on an unclaimed planet")
	var/datum/NexusPlanetControl/expired_control = getNexusPlanetControl("namekian", FALSE)
	nexusSmokeAssert(expired_control.setController(ruler, ruling_league), "the absence-expiration test could not create a held control point")
	expired_control.resource_tax_rate = 25
	expired_control.resource_treasury = 77.125
	expired_control.captured_at = world.realtime - NEXUS_PLANET_CONTROL_ABANDONMENT_TICKS - 10
	expired_control.holder_last_seen = expired_control.captured_at
	var/expired_ownership_revision = expired_control.ownership_revision
	nexusSmokeAssert(materializeExpiredNexusPlanetControls(persist = FALSE) && expired_control.isAbandoned() && !expired_control.holder_account_id && expired_control.ownership_revision == expired_ownership_revision + 1, "a 72-hour absence did not become an irreversible abandoned control point")
	var/list/expired_tax_result = taxpayer.applyNexusPlanetaryIncomeTax(resource_gross = 100, control_override = expired_control)
	nexusSmokeAssert(!expired_tax_result["resource_tax"] && expired_control.resource_treasury == 77.125, "a control point materialized as abandoned continued collecting tax or lost its treasury")
	ruler.refreshNexusPlanetControlPresence(persist = FALSE)
	nexusSmokeAssert(expired_control.isAbandoned() && !expired_control.holder_account_id, "an expired holder reactivated planetary control by returning online")
	expired_control.clearController()
	var/mob/NexusSmokeTest/micro_taxpayer = new(control_turf)
	micro_taxpayer.playerCharacter = TRUE
	micro_taxpayer.displaykey = "Control Micro Taxpayer"
	micro_taxpayer.Race = "Human"
	new /obj/Resources(micro_taxpayer)
	var/resource_treasury_before_micro_income = control.resource_treasury
	var/essence_treasury_before_micro_income = control.essence_treasury
	for(var/resource_tick = 1, resource_tick <= 10, resource_tick++) micro_taxpayer.gainNexusResources(1, "micro resource income")
	for(var/essence_tick = 1, essence_tick <= 40, essence_tick++) micro_taxpayer.gainArcaneEssence(0.1, "micro essence income")
	nexusSmokeAssertNear(micro_taxpayer.Res(), 8, 0.000001, "fractional Resource tax remainders changed the expected net micro-income")
	nexusSmokeAssertNear(control.resource_treasury, resource_treasury_before_micro_income + 2, 0.00001, "fractional Resource tax remainders let repeated micro-income evade the configured rate")
	nexusSmokeAssertNear(micro_taxpayer.arcane_essence, 3, 0.001, "fractional Arcane Essence tax remainders changed the expected net micro-income")
	nexusSmokeAssertNear(micro_taxpayer.arcane_essence_lifetime, 4, 0.001, "micro-income taxation reduced lifetime Arcane Essence progression")
	nexusSmokeAssertNear(control.essence_treasury, essence_treasury_before_micro_income + 1, 0.001, "repeated micro Arcane Essence income evaded planetary tax")
	nexusSmokeAssert(!micro_taxpayer.nexus_planet_resource_tax_remainders.len && !micro_taxpayer.nexus_planet_essence_tax_remainders.len, "settled fractional tax remainder keys were retained indefinitely")
	micro_taxpayer.loc = mining_cave_turf
	micro_taxpayer.last_cave_entered = null
	micro_taxpayer.nexus_planet_control_context_id = "earth"
	var/resource_treasury_before_cave_income = control.resource_treasury
	nexusSmokeAssert(getNexusPlanetControlId(micro_taxpayer) == "earth", "a persisted cave origin no longer resolves to its surface planet after relog")
	nexusSmokeAssertNear(micro_taxpayer.gainNexusResources(10, "cave income"), 8, 0.000001, "planetary tax changed the expected net cave income")
	nexusSmokeAssertNear(control.resource_treasury, resource_treasury_before_cave_income + 2, 0.000001, "planetary tax could be bypassed by earning resources after relogging in a cave")
	micro_taxpayer.rememberNexusCaveControlPlanet(control_turf, mining_cave_turf)
	nexusSmokeAssert(micro_taxpayer.nexus_planet_control_context_id == "earth", "a controlled-planet cave entrance did not record its tax jurisdiction")
	micro_taxpayer.rememberNexusCaveControlPlanet(nonplanet_cave_entrance_turf, mining_cave_turf)
	nexusSmokeAssert(!micro_taxpayer.nexus_planet_control_context_id, "a nonplanet cave entrance reused stale planetary tax jurisdiction")
	micro_taxpayer.nexus_planet_control_context_id = "earth"
	var/mob/NexusSmokeTest/cave_anchor = new(mining_cave_turf)
	cave_anchor.playerCharacter = TRUE
	cave_anchor.nexus_planet_control_context_id = "earth"
	micro_taxpayer.nexus_planet_control_context_id = "namekian"
	micro_taxpayer.setNexusPlanetControlTeleportContext(getNexusPlanetControlId(cave_anchor))
	micro_taxpayer.SafeTeleport(cave_anchor.base_loc())
	nexusSmokeAssert(micro_taxpayer.nexus_planet_control_context_id == "earth", "teleporting directly to a character in a cave did not propagate the target's planetary jurisdiction")
	micro_taxpayer.SafeTeleport(control_turf)
	del(cave_anchor)
	var/obj/ArcanePortal/cave_portal_entry = new(control_turf)
	var/obj/ArcanePortal/cave_portal_exit = new(mining_cave_turf)
	var/obj/ArcanePortal/cave_portal_decoy = new(mining_cave_turf)
	cave_portal_entry.partner = cave_portal_exit
	cave_portal_exit.partner = cave_portal_entry
	cave_portal_entry.nexus_planet_control_context_id = "earth"
	cave_portal_exit.nexus_planet_control_context_id = "earth"
	cave_portal_decoy.nexus_planet_control_context_id = "namekian"
	micro_taxpayer.last_cave_entered = remote_control_turf
	micro_taxpayer.nexus_planet_control_context_id = "namekian"
	micro_taxpayer.last_arcane_portal_use = world.time - 100
	cave_portal_entry.Crossed(micro_taxpayer)
	nexusSmokeAssert(micro_taxpayer.base_loc() == mining_cave_turf && micro_taxpayer.nexus_planet_control_context_id == "earth" && getNexusPlanetControlId(micro_taxpayer) == "earth", "an exact arcane portal endpoint did not override a stacked endpoint or stale cave entrance with its bound planetary jurisdiction")
	micro_taxpayer.SafeTeleport(control_turf)
	micro_taxpayer.last_cave_entered = null
	del(cave_portal_entry)
	del(cave_portal_exit)
	del(cave_portal_decoy)
	micro_taxpayer.nexus_planet_control_context_id = "earth"
	micro_taxpayer.SafeTeleport(mining_cave_turf)
	var/obj/items/Transporter_Pad/cave_telepad = new(micro_taxpayer)
	cave_telepad.Move(mining_cave_turf)
	nexusSmokeAssert(cave_telepad.getNexusPlanetControlContextId() == "earth", "a telepad installed in a mining cave did not retain its installer's planetary jurisdiction")
	micro_taxpayer.SafeTeleport(control_turf)
	del(cave_telepad)
	new /area/ship_area(mining_cave_turf)
	var/obj/Ships/Ship/NexusControlSmoke/current_exterior_ship = new(control_turf)
	var/obj/Ships/Ship/NexusControlSmoke/stale_exterior_ship = new(remote_control_turf)
	var/obj/Controls/NexusControlSmoke/current_interior_controls = new(mining_cave_turf)
	current_exterior_ship.Ship = 910001
	stale_exterior_ship.Ship = 910002
	current_interior_controls.Ship = current_exterior_ship.Ship
	micro_taxpayer.Ship = stale_exterior_ship
	micro_taxpayer.loc = mining_cave_turf
	nexusSmokeAssert(getNexusPlanetControlId(micro_taxpayer) == "earth", "a stale piloted-ship pointer overrode the controls belonging to the current ship interior")
	micro_taxpayer.Ship = null
	micro_taxpayer.loc = control_turf
	del(current_interior_controls)
	del(current_exterior_ship)
	del(stale_exterior_ship)
	new /area/Mining_Cave(mining_cave_turf)
	new /area/Inside(control_turf)
	var/resource_treasury_before_inside_income = control.resource_treasury
	nexusSmokeAssert(getNexusPlanetControlId(micro_taxpayer) == "earth", "a planet-local interior escaped its surface planet's control jurisdiction")
	nexusSmokeAssertNear(micro_taxpayer.gainNexusResources(10, "interior income"), 8, 0.000001, "planetary tax changed the expected net interior income")
	nexusSmokeAssertNear(control.resource_treasury, resource_treasury_before_inside_income + 2, 0.000001, "planetary tax could be bypassed by earning resources inside a building")
	new /area/Earth(control_turf)
	micro_taxpayer.Alter_Res(10)
	var/resources_before_death_drop = micro_taxpayer.Res()
	var/treasury_before_death_drop = control.resource_treasury
	micro_taxpayer.Drop_Rsc(10)
	var/obj/Resources/death_drop
	for(var/obj/Resources/candidate_drop in control_turf)
		if(candidate_drop.Value == 10 && candidate_drop.nexus_tax_exempt_value == 10)
			death_drop = candidate_drop
			break
	nexusSmokeAssert(death_drop && micro_taxpayer.Res() == resources_before_death_drop - 10, "a death Resource drop lost its already-taxed provenance or failed to debit the balance")
	micro_taxpayer.collectNexusResourceBag(death_drop, "recovered death resources")
	nexusSmokeAssertNear(micro_taxpayer.Res(), resources_before_death_drop, 0.000001, "recollecting a death Resource drop changed the existing balance")
	nexusSmokeAssertNear(control.resource_treasury, treasury_before_death_drop, 0.000001, "recollecting a death Resource drop taxed the same balance twice")
	del(death_drop)
	var/obj/Resources/transfer_bag = new(control_turf)
	transfer_bag.Value = 10
	transfer_bag.nexus_tax_exempt_value = 10
	var/obj/Resources/taxable_bag = new(control_turf)
	taxable_bag.Value = 10
	nexusSmokeAssert(transfer_bag.absorbNexusResourceBag(taxable_bag), "resource bags with different tax provenance could not be merged")
	var/micro_resources_before_transfer_pickup = micro_taxpayer.Res()
	var/treasury_before_transfer_pickup = control.resource_treasury
	micro_taxpayer.collectNexusResourceBag(transfer_bag, "transferred resources")
	nexusSmokeAssertNear(micro_taxpayer.Res(), micro_resources_before_transfer_pickup + 18, 0.000001, "merged resource bags changed the expected net pickup")
	nexusSmokeAssertNear(control.resource_treasury, treasury_before_transfer_pickup + 2, 0.000001, "merged resource bags lost taxable-versus-transfer provenance")
	del(transfer_bag)
	del(taxable_bag)

	var/mob/NexusSmokeTest/member = new(control_turf)
	member.playerCharacter = TRUE
	member.displaykey = "Control Member"
	member.Race = "Human"
	new /obj/Resources(member)
	var/obj/League/member_badge = new
	member_badge.league_id = ruling_league.league_id
	member_badge.name = ruling_league.name
	member_badge.league_rank = 1
	member_badge.Move(member)
	var/resource_treasury_before_member = control.resource_treasury
	var/essence_treasury_before_member = control.essence_treasury
	member.gainNexusResources(100, "member income")
	member.gainArcaneEssence(10, "member essence")
	nexusSmokeAssert(member.Res() == 100 && member.arcane_essence == 10 && control.resource_treasury == resource_treasury_before_member && control.essence_treasury == essence_treasury_before_member, "a member of the ruling league was taxed")

	var/obj/League/same_name_badge = new
	same_name_badge.league_id = "nexus-control-unrelated-id"
	same_name_badge.name = ruling_league.name
	same_name_badge.Move(taxpayer)
	var/list/same_name_tax = taxpayer.applyNexusPlanetaryIncomeTax(resource_gross = 50, control_override = control)
	nexusSmokeAssert(same_name_tax["resource_tax"] == 10, "a different league with the same display name received the controller exemption")

	taxpayer.Race = "Heran"
	taxpayer.heran_refuses_planetary_taxes = FALSE
	var/list/heran_default_tax = taxpayer.applyNexusPlanetaryIncomeTax(essence_gross = 10, control_override = control)
	taxpayer.heran_refuses_planetary_taxes = TRUE
	var/list/heran_refusal_tax = taxpayer.applyNexusPlanetaryIncomeTax(essence_gross = 10, control_override = control)
	taxpayer.Race = "Human"
	var/list/non_heran_refusal_tax = taxpayer.applyNexusPlanetaryIncomeTax(essence_gross = 10, control_override = control)
	nexusSmokeAssert(heran_default_tax["essence_tax"] == 2.5 && !heran_refusal_tax["essence_tax"] && non_heran_refusal_tax["essence_tax"] == 2.5, "Heran tax refusal is automatic, ineffective, or honored by a non-Heran")

	var/mob/NexusSmokeTest/conqueror = new(adjacent_turf)
	conqueror.playerCharacter = TRUE
	conqueror.displaykey = "Control Conqueror"
	conqueror.active_character_slot = 2
	conqueror.character_made_time = 303
	conqueror.name = "Conqueror"
	var/obj/League/conquering_league = new
	conquering_league.league_id = "nexus-control-conquering-id"
	conquering_league.name = "Conquering League"
	conquering_league.league_rank = 1
	conquering_league.Move(conqueror)
	var/mob/NexusSmokeTest/wrong_slot_ruler = new(control_turf)
	wrong_slot_ruler.playerCharacter = TRUE
	wrong_slot_ruler.displaykey = ruler.displaykey
	wrong_slot_ruler.active_character_slot = 2
	wrong_slot_ruler.character_made_time = ruler.character_made_time
	nexusSmokeAssert(!control.isHolder(wrong_slot_ruler), "another character slot on the ruler account was accepted as the control holder")

	ruler.KO = TRUE
	ruler.willpower = 5
	ruler.loc = remote_control_turf
	conqueror.loc = remote_adjacent_turf
	var/list/ruler_control_points = getNexusPlanetControlsHeldBy(ruler)
	nexusSmokeAssert((control in ruler_control_points) && getNexusPlanetControlId(ruler) == "namekian", "an off-world ruler did not continue carrying the original planet's control point")
	var/ownership_revision_before_capture = control.ownership_revision
	nexusSmokeAssert(conqueror.getNexusPlanetControlSeizureError(ruler, control, conquering_league, ownership_revision_before_capture), "a KO ruler with remaining Willpower could lose planetary control")
	ruler.KO = FALSE
	ruler.willpower = 0
	nexusSmokeAssert(conqueror.getNexusPlanetControlSeizureError(ruler, control, conquering_league, ownership_revision_before_capture), "a conscious zero-Willpower ruler could lose planetary control")
	ruler.KO = TRUE
	var/original_tournament_state = Tournament
	var/obj/Fighter_Spot/control_capture_tournament_spot = new(conqueror.loc)
	Tournament = TRUE
	nexusSmokeAssert(conqueror.getNexusPlanetControlSeizureError(ruler, control, conquering_league, ownership_revision_before_capture), "the final conquest validator allowed control capture after a tournament began")
	Fighter_Spots -= control_capture_tournament_spot
	del(control_capture_tournament_spot)
	Tournament = original_tournament_state
	var/captured_resource_treasury = control.resource_treasury
	var/captured_essence_treasury = control.essence_treasury
	nexusSmokeAssert(conqueror.seizeNexusPlanetControl(ruler, control, conquering_league, ownership_revision_before_capture, announce = FALSE, persist = FALSE), "a valid adjacent conqueror could not seize control from a KO zero-Willpower ruler")
	nexusSmokeAssert(control.controller_league_id == conquering_league.league_id && control.isHolder(conqueror) && control.ownership_revision == ownership_revision_before_capture + 1 && !control.resource_tax_rate && !control.essence_tax_rate, "successful conquest did not atomically replace the faction and holder or reset tax policy")
	nexusSmokeAssert(control.resource_treasury == captured_resource_treasury && control.essence_treasury == captured_essence_treasury, "conquest destroyed or duplicated the captured planetary treasury")
	nexusSmokeAssert(!conqueror.seizeNexusPlanetControl(ruler, control, conquering_league, ownership_revision_before_capture, announce = FALSE, persist = FALSE), "the same ownership revision could be captured more than once")
	conqueror.KO = TRUE
	nexusSmokeAssert(!conqueror.canNexusPlanetControlHolderDepartLeague(conquering_league.league_id), "a knocked-out holder could leave or be expelled from its league to invalidate conquest")
	conqueror.KO = FALSE
	var/treasury_before_departure = control.resource_treasury
	nexusSmokeAssert(conqueror.orphanNexusPlanetControlForLeagueDeparture(conquering_league.league_id, persist = FALSE, announce = FALSE), "a conscious departing holder could not abandon its control point")
	nexusSmokeAssert(control.isClaimed() && control.isAbandoned() && control.resource_treasury == treasury_before_departure, "league departure erased ownership or treasury instead of preserving an immediately claimable abandoned point")
	control.resource_tax_rate = 25
	var/list/abandoned_tax_result = taxpayer.applyNexusPlanetaryIncomeTax(resource_gross = 100, control_override = control)
	nexusSmokeAssert(!abandoned_tax_result["resource_tax"] && control.resource_treasury == treasury_before_departure && !conqueror.canManageNexusPlanetControl(control), "an abandoned point continued collecting tax or accepting treasury management")

	var/smoke_control_save_path = "nexus-smoke-planet-control.sav"
	if(fexists(smoke_control_save_path)) fdel(smoke_control_save_path)
	control.resource_tax_rate = 12.5
	control.essence_tax_rate = 7.5
	control.resource_treasury = 54321
	control.essence_treasury = 98.7
	saveNexusPlanetControls(smoke_control_save_path)
	control.controller_league_name = "Corrupted Runtime Value"
	control.resource_treasury = 0
	loadNexusPlanetControls(smoke_control_save_path)
	var/datum/NexusPlanetControl/loaded_control = getNexusPlanetControl("earth", FALSE)
	nexusSmokeAssert(loaded_control.controller_league_id == conquering_league.league_id, "planetary control league identity failed its persistence round trip ([loaded_control.controller_league_id])")
	nexusSmokeAssert(loaded_control.controller_league_name == conquering_league.name, "planetary control league name failed its persistence round trip ([loaded_control.controller_league_name])")
	nexusSmokeAssert(loaded_control.resource_tax_rate == 12.5 && loaded_control.essence_tax_rate == 7.5, "planetary control tax rates failed their persistence round trip ([loaded_control.resource_tax_rate]/[loaded_control.essence_tax_rate])")
	nexusSmokeAssert(loaded_control.resource_treasury == 54321, "planetary control resource treasury failed its persistence round trip ([loaded_control.resource_treasury])")
	nexusSmokeAssertNear(loaded_control.essence_treasury, 98.7, 0.001, "planetary control Arcane Essence treasury failed its persistence round trip")
	if(fexists(smoke_control_save_path)) fdel(smoke_control_save_path)

	del(wrong_slot_ruler)
	del(conqueror)
	del(member)
	del(micro_taxpayer)
	del(taxpayer)
	del(ruler)
	nexus_planet_controls = original_controls
	nexus_planet_controls_dirty = original_controls_dirty
	king_of_Braal = original_king_of_braal

proc/runNexusGhostCopySmoke()
	var/mob/NexusSmokeTest/ghost_copy_source = new
	ghost_copy_source.name = "Ghost Copy Source"
	ghost_copy_source.icon = 'BaseHumanPale.dmi'
	ghost_copy_source.pixel_x = 3
	ghost_copy_source.pixel_y = -2
	ghost_copy_source.overlays += image('RTIronSword.dmi')
	var/obj/Blast/ghost_copy_contract = new
	nexusSmokeAssert(ghost_copy_contract.applyNexusCharacterCopyAppearance(ghost_copy_source) && ghost_copy_contract.icon == ghost_copy_source.icon && ghost_copy_contract.pixel_x == 3 && ghost_copy_contract.pixel_y == -2 && ghost_copy_contract.overlays.len == ghost_copy_source.overlays.len, "Super Ghost Kamikaze projectile does not copy the caster body and equipped silhouette")
	del(ghost_copy_contract)
	del(ghost_copy_source)

proc/runNexusAndroidGiantAppearanceSmoke()
	var/mob/NexusSmokeTest/android_giant_scale_test = new
	android_giant_scale_test.Android = 1
	android_giant_scale_test.icon = 'BaseHumanPale.dmi'
	android_giant_scale_test.pixel_x = 4
	android_giant_scale_test.pixel_y = -3
	var/matrix/android_giant_base_transform = matrix()
	android_giant_base_transform.c = 6
	android_giant_base_transform.f = -4
	android_giant_scale_test.transform = android_giant_base_transform
	var/obj/items/Clothes/ShortSleeveShirt/android_giant_shirt = new(android_giant_scale_test)
	android_giant_shirt.suffix = "Equipped"
	var/obj/items/Sword/Forged/android_giant_sword = new(android_giant_scale_test)
	android_giant_sword.suffix = "Equipped"
	var/obj/items/Armor/Forged/android_giant_armor = new(android_giant_scale_test)
	android_giant_armor.suffix = "Equipped"
	var/obj/items/Mask/Forged/android_giant_mask = new(android_giant_scale_test)
	android_giant_mask.suffix = "Equipped"
	android_giant_scale_test.rebuildPlayerAppearance("android giant setup")
	var/datum/PlayerAppearanceManager/android_giant_manager = android_giant_scale_test.player_appearance_manager
	nexusSmokeAssert(android_giant_manager.rendered_appearances.len == 4, "Android equipment setup did not compose clothing, sword, armor and mask")
	var/obj/Module/Giant_Version_New/android_giant_module = new(android_giant_scale_test)
	android_giant_module.suffix = "Installed"
	android_giant_scale_test.syncNexusAndroidGiantAppearance()
	var/matrix/android_giant_active_transform = matrix(android_giant_scale_test.transform)
	nexusSmokeAssertNear(android_giant_active_transform.a, 42 / 32, 0.001, "Android Giant Version did not scale the complete character silhouette")
	nexusSmokeAssertNear(android_giant_active_transform.c, 6, 0.001, "Android Giant Version moved the character's horizontal transform anchor")
	nexusSmokeAssertNear(android_giant_active_transform.f, -4, 0.001, "Android Giant Version moved the character's vertical transform anchor")
	nexusSmokeAssert(android_giant_scale_test.pixel_x == 4 && android_giant_scale_test.pixel_y == -3, "Android Giant Version changed the character's pixel anchor")
	var/android_giant_scaled_equipment = 0
	for(var/image/android_equipment_image in android_giant_manager.rendered_appearances)
		var/matrix/android_equipment_transform = matrix(android_equipment_image.transform)
		if((android_equipment_image.appearance_flags & RESET_TRANSFORM) && abs(android_equipment_transform.a - (42 / 32)) <= 0.001 && abs(android_equipment_transform.c - 6) <= 0.001 && abs(android_equipment_transform.f + 4) <= 0.001)
			android_giant_scaled_equipment++
	nexusSmokeAssert(android_giant_scaled_equipment == 4, "Android Giant Version did not resize clothing, sword, armor and mask with the body")
	nexusSmokeAssert(android_giant_scale_test.getNexusCombatHitboxWidth() == 32 && android_giant_scale_test.getNexusCombatHitboxHeight() == 34, "Android Giant Version did not install its rectangular combat hitbox")
	android_giant_scale_test.normalizeNexusCharacterVisualScale()
	android_giant_scale_test.syncNexusAndroidGiantAppearance()
	var/matrix/android_giant_relog_transform = matrix(android_giant_scale_test.transform)
	nexusSmokeAssertNear(android_giant_relog_transform.a, 42 / 32, 0.001, "Android Giant Version visual scale multiplied again during relog normalization")
	android_giant_module.suffix = null
	android_giant_scale_test.syncNexusAndroidGiantAppearance()
	var/matrix/android_giant_reverted_transform = matrix(android_giant_scale_test.transform)
	nexusSmokeAssertNear(android_giant_reverted_transform.a, 1, 0.001, "Android Giant Version did not restore the base character scale")
	nexusSmokeAssertNear(android_giant_reverted_transform.c, 6, 0.001, "Android Giant Version did not restore the horizontal transform anchor")
	nexusSmokeAssertNear(android_giant_reverted_transform.f, -4, 0.001, "Android Giant Version did not restore the vertical transform anchor")
	del(android_giant_scale_test)

proc/runNexusLargeBlastDamageCollisionSmoke(turf/blast_origin, turf/edge_target_turf, obj/Attacks/Genki_Dama/omega_bomb_balance, obj/Attacks/Genki_Dama/Supernova/supernova_balance)
	var/mob/NexusSmokeTest/large_blast_owner = new(blast_origin)
	large_blast_owner.BP = 100
	large_blast_owner.Pow = 100
	large_blast_owner.Off = 100
	large_blast_owner.Spd = 100
	large_blast_owner.BPpcnt = 100
	var/mob/NexusSmokeTest/genki_edge_target = new(edge_target_turf)
	genki_edge_target.BP = 100
	genki_edge_target.Res = 100
	genki_edge_target.Health = 100
	var/obj/Blast/Genki_Dama/genki_edge_projectile = new(blast_origin)
	genki_edge_projectile.setStats(large_blast_owner, Percent = omega_bomb_balance.sb_max_dmg, Off_Mult = 10, Explosion = omega_bomb_balance.sb_explosion_size, \
		explosion_percent = omega_bomb_balance.sb_max_dmg, max_damage_factor = omega_bomb_balance.sb_max_dmg * 2)
	genki_edge_projectile.from_attack = omega_bomb_balance
	genki_edge_projectile.Size = omega_bomb_balance.max_dmg_range
	var/genki_damage_radius = genki_edge_projectile.getNexusProjectileCollisionRadiusPixels()
	genki_edge_projectile.Size = 0
	var/genki_physical_radius = genki_edge_projectile.getNexusProjectileCollisionRadiusPixels()
	genki_edge_projectile.Size = omega_bomb_balance.max_dmg_range
	var/genki_center_x = genki_edge_projectile.nexusCollisionCenterXPixels()
	var/genki_center_y = genki_edge_projectile.nexusCollisionCenterYPixels()
	nexusSmokeAssert(!nexusCircleIntersectsHitbox(genki_center_x, genki_center_y, genki_physical_radius, genki_edge_target) && nexusCircleIntersectsHitbox(genki_center_x, genki_center_y, genki_damage_radius, genki_edge_target), "Genki Dama edge-contact fixture is not outside the physical bound and inside authored Size")
	nexusSmokeAssert(genki_edge_projectile.explosion_damage_factor == 30 && genki_edge_projectile.damage_budget.max_factor_per_target == 60, "Genki Dama runtime projectile lost its 30 direct plus 30 splash budget")
	genki_edge_projectile.Explosive = 0
	genki_edge_projectile.Deflectable = 0
	genki_edge_projectile.dir = EAST
	genki_edge_projectile.nexus_collision_sweep_active = TRUE
	genki_edge_projectile.nexus_collision_sweep_start_x = genki_center_x
	genki_edge_projectile.nexus_collision_sweep_start_y = genki_center_y
	genki_edge_projectile.nexus_collision_sweep_end_x = genki_center_x
	genki_edge_projectile.nexus_collision_sweep_end_y = genki_center_y
	genki_edge_projectile.BlastMobCross(genki_edge_target, override_delete = TRUE)
	nexusSmokeAssertNear(genki_edge_target.Health, 70, 0.0001, "Genki Dama did not apply its full direct factor to a target inside Size but outside its physical bound")
	nexusSmokeAssert(genki_edge_projectile.damage_budget.used_factor_by_target[genki_edge_target] == 30, "Genki Dama direct contact did not preserve the remaining 30-factor splash budget")
	del(genki_edge_projectile)
	del(genki_edge_target)
	var/mob/NexusSmokeTest/supernova_edge_target = new(edge_target_turf)
	supernova_edge_target.BP = 100
	supernova_edge_target.Res = 100
	supernova_edge_target.Health = 100
	var/obj/Blast/Genki_Dama/supernova_edge_projectile = new(blast_origin)
	supernova_edge_projectile.setStats(large_blast_owner, Percent = supernova_balance.sb_max_dmg, Off_Mult = 10, Explosion = supernova_balance.sb_explosion_size, \
		explosion_percent = supernova_balance.sb_max_dmg, max_damage_factor = supernova_balance.sb_max_dmg * 2)
	supernova_edge_projectile.from_attack = supernova_balance
	supernova_edge_projectile.Size = supernova_balance.max_dmg_range
	var/supernova_damage_radius = supernova_edge_projectile.getNexusProjectileCollisionRadiusPixels()
	supernova_edge_projectile.Size = 0
	var/supernova_physical_radius = supernova_edge_projectile.getNexusProjectileCollisionRadiusPixels()
	supernova_edge_projectile.Size = supernova_balance.max_dmg_range
	var/supernova_center_x = supernova_edge_projectile.nexusCollisionCenterXPixels()
	var/supernova_center_y = supernova_edge_projectile.nexusCollisionCenterYPixels()
	nexusSmokeAssert(!nexusCircleIntersectsHitbox(supernova_center_x, supernova_center_y, supernova_physical_radius, supernova_edge_target) && nexusCircleIntersectsHitbox(supernova_center_x, supernova_center_y, supernova_damage_radius, supernova_edge_target), "Supernova edge-contact fixture is not outside the physical bound and inside authored Size")
	nexusSmokeAssert(supernova_edge_projectile.explosion_damage_factor == 18 && supernova_edge_projectile.damage_budget.max_factor_per_target == 36, "Supernova runtime projectile lost its 18 direct plus 18 splash budget")
	supernova_edge_projectile.Explosive = 0
	supernova_edge_projectile.Deflectable = 0
	supernova_edge_projectile.dir = EAST
	supernova_edge_projectile.nexus_collision_sweep_active = TRUE
	supernova_edge_projectile.nexus_collision_sweep_start_x = supernova_center_x
	supernova_edge_projectile.nexus_collision_sweep_start_y = supernova_center_y
	supernova_edge_projectile.nexus_collision_sweep_end_x = supernova_center_x
	supernova_edge_projectile.nexus_collision_sweep_end_y = supernova_center_y
	supernova_edge_projectile.BlastMobCross(supernova_edge_target, override_delete = TRUE)
	nexusSmokeAssertNear(supernova_edge_target.Health, 82, 0.0001, "Supernova did not apply its full direct factor to a target inside Size but outside its physical bound")
	nexusSmokeAssert(supernova_edge_projectile.damage_budget.used_factor_by_target[supernova_edge_target] == 18, "Supernova direct contact did not preserve the remaining 18-factor splash budget")
	del(supernova_edge_projectile)
	del(supernova_edge_target)
	del(large_blast_owner)

proc/runNexusCometReversalMultiBeamSmoke(turf/counter_turf, turf/adjacent_source_turf)
	var/mob/NexusSmokeTest/CometReversalProbe/counter_user = new(counter_turf)
	counter_user.BP = 100
	counter_user.Str = 100
	counter_user.End = 100
	counter_user.Res = 100
	counter_user.Def = 100
	counter_user.Off = 100
	counter_user.Spd = 100
	counter_user.BPpcnt = 100
	counter_user.Health = 100
	counter_user.dir = EAST
	counter_user.comet_approach_hold_ticks = 4
	counter_user.comet_approach_result = NEXUS_SKILL_MOTION_REACHED
	var/obj/Attacks/NexusMeleeTechnique/CometReversal/comet_reversal = new(counter_user)
	var/mob/NexusSmokeTest/beam_owner = new(adjacent_source_turf)
	beam_owner.BP = 100
	beam_owner.Pow = 100
	beam_owner.Off = 100
	beam_owner.Spd = 100
	beam_owner.BPpcnt = 100
	beam_owner.Health = 100
	var/obj/Attacks/Beam/first_beam_attack = new(beam_owner)
	first_beam_attack.streaming = TRUE
	beam_owner.beaming = TRUE
	beam_owner.current_beam = first_beam_attack
	var/obj/Blast/first_beam_segment = new(counter_turf)
	first_beam_segment.setStats(beam_owner, Percent = 10, Off_Mult = 1, Explosion = 0)
	first_beam_segment.Beam = TRUE
	first_beam_segment.Beam_Delay = 1
	first_beam_segment.Deflectable = FALSE
	first_beam_segment.beam_impact_mode = BEAM_IMPACT_LOCK
	first_beam_segment.from_attack = first_beam_attack
	first_beam_segment.dir = WEST
	beam_owner.my_beam_objs += first_beam_segment
	first_beam_attack.beam_objects += first_beam_segment
	counter_user.setNexusStance("comet_reversal", comet_reversal.counter_window_ticks)
	var/counter_health_before = counter_user.Health
	first_beam_segment.Beam()
	sleep(1)
	var/rush_guard_until = counter_user.active_nexus_stance_until
	nexusSmokeAssert(counter_user.Health == counter_health_before && counter_user.hasNexusStance("comet_reversal") && counter_user.nexus_comet_reversal_triggered && counter_user.comet_approach_calls == 1 && counter_user.comet_approach_target == beam_owner && !counter_user.comet_finisher_calls, "the first real beam did not start one protected Comet Reversal approach before damage")
	nexusSmokeAssert(!first_beam_attack.streaming && !beam_owner.beaming && !beam_owner.current_beam && !beam_owner.my_beam_objs.len && !first_beam_attack.beam_objects.len && !first_beam_segment.z, "Comet Reversal did not tear down the first real beam through BeamStop")
	var/obj/Attacks/Beam/second_beam_attack = new(beam_owner)
	second_beam_attack.streaming = TRUE
	beam_owner.beaming = TRUE
	beam_owner.current_beam = second_beam_attack
	var/obj/Blast/second_beam_segment = new(counter_turf)
	second_beam_segment.setStats(beam_owner, Percent = 10, Off_Mult = 1, Explosion = 0)
	second_beam_segment.Beam = TRUE
	second_beam_segment.Beam_Delay = 1
	second_beam_segment.Deflectable = FALSE
	second_beam_segment.beam_impact_mode = BEAM_IMPACT_LOCK
	second_beam_segment.from_attack = second_beam_attack
	second_beam_segment.dir = WEST
	beam_owner.my_beam_objs += second_beam_segment
	second_beam_attack.beam_objects += second_beam_segment
	second_beam_segment.Beam()
	sleep(1)
	nexusSmokeAssert(counter_user.Health == counter_health_before && counter_user.hasNexusStance("comet_reversal") && counter_user.active_nexus_stance_until == rush_guard_until, "a second real beam damaged through or extended the active Comet Reversal rush guard")
	nexusSmokeAssert(!second_beam_attack.streaming && !beam_owner.beaming && !beam_owner.current_beam && !beam_owner.my_beam_objs.len && !second_beam_attack.beam_objects.len && !second_beam_segment.z, "Comet Reversal did not tear down the second real beam from the same enemy")
	nexusSmokeAssert(counter_user.comet_approach_calls == 1 && counter_user.comet_approach_target == beam_owner && !counter_user.comet_finisher_calls, "a second beam retargeted Comet Reversal or launched an extra approach or finisher")
	sleep(4)
	nexusSmokeAssert(!counter_user.hasNexusStance("comet_reversal") && !counter_user.nexus_comet_reversal_triggered && counter_user.comet_approach_calls == 1 && counter_user.comet_finisher_calls == 1 && counter_user.comet_finisher_target == beam_owner, "Comet Reversal did not end its beam guard with exactly one finisher against the first owner")
	var/obj/Attacks/Beam/post_rush_beam_attack = new(beam_owner)
	post_rush_beam_attack.streaming = TRUE
	beam_owner.beaming = TRUE
	beam_owner.current_beam = post_rush_beam_attack
	var/obj/Blast/post_rush_beam_segment = new(counter_turf)
	post_rush_beam_segment.Beam = TRUE
	post_rush_beam_segment.Owner = beam_owner
	post_rush_beam_segment.from_attack = post_rush_beam_attack
	nexusSmokeAssert(!counter_user.tryNexusCometReversal(post_rush_beam_segment) && counter_user.comet_approach_calls == 1 && counter_user.comet_finisher_calls == 1, "Comet Reversal still intercepts beams or repeats its offense after the rush guard ends")
	counter_user.setNexusStance("comet_reversal", comet_reversal.counter_window_ticks)
	counter_user.comet_approach_hold_ticks = 0
	counter_user.comet_approach_result = NEXUS_SKILL_MOTION_INTERRUPTED
	var/finisher_calls_before_interruption = counter_user.comet_finisher_calls
	nexusSmokeAssert(counter_user.tryNexusCometReversal(post_rush_beam_segment), "Comet Reversal could not start its interrupted-approach regression case")
	sleep(1)
	nexusSmokeAssert(counter_user.comet_finisher_calls == finisher_calls_before_interruption && !counter_user.hasNexusStance("comet_reversal"), "an interrupted Comet Reversal approach granted an adjacency finisher")
	beam_owner.current_beam = null
	beam_owner.beaming = FALSE
	post_rush_beam_attack.streaming = FALSE
	del(post_rush_beam_segment)
	del(second_beam_segment)
	del(first_beam_segment)
	del(beam_owner)
	del(counter_user)

proc/runNexusCometReversalSmoke(turf/counter_turf, turf/adjacent_source_turf, turf/distant_source_turf)
	var/mob/NexusSmokeTest/CometReversalProbe/counter_user = new(counter_turf)
	counter_user.BP = 100
	counter_user.Str = 100
	counter_user.End = 100
	counter_user.Res = 100
	counter_user.Def = 100
	counter_user.Off = 100
	counter_user.Spd = 100
	counter_user.BPpcnt = 100
	counter_user.Health = 100
	counter_user.max_ki = 10000
	counter_user.Ki = 10000
	counter_user.dir = EAST
	var/obj/Attacks/NexusMeleeTechnique/CometReversal/comet_reversal = new(counter_user)
	nexusSmokeAssert(getNexusWeaponAttackTypes().len == 14 && getNexusUnarmedAttackTypes().len == 16, "Nexus physical attack catalog is incomplete")
	nexusSmokeAssert(getProgressionUnarmedAttackTypes().len == 21, "the Unarmed progression catalog omits Comet Reversal, legacy physical attacks, or still duplicates foundational Dash Attack")
	nexusSmokeAssert(comet_reversal.behavior == "beam_counter" && comet_reversal.requires_unarmed && comet_reversal.damage_multiplier == 2 && comet_reversal.energy_cost == 24 && comet_reversal.cooldown_ticks == 100 && comet_reversal.dash_range == 32 && comet_reversal.counter_window_ticks == 12 && comet_reversal.rush_guard_ticks == 35 && comet_reversal.hotbar_type == "Melee" && !comet_reversal.repeat_macro, "Comet Reversal lost its timing, cost, range, damage or unarmed hotbar contract")
	var/mob/NexusSmokeTest/beam_owner = new(distant_source_turf)
	beam_owner.BP = 100
	beam_owner.Pow = 100
	beam_owner.Off = 100
	beam_owner.Spd = 100
	beam_owner.BPpcnt = 100
	var/obj/Attacks/Beam/beam_attack = new(beam_owner)
	beam_attack.streaming = TRUE
	beam_owner.beaming = TRUE
	beam_owner.current_beam = beam_attack
	var/obj/Blast/front_beam_segment = new(counter_turf)
	front_beam_segment.Beam = TRUE
	front_beam_segment.Owner = beam_owner
	front_beam_segment.from_attack = beam_attack
	front_beam_segment.dir = WEST
	counter_user.setNexusStance("comet_reversal", comet_reversal.counter_window_ticks)
	nexusSmokeAssert(counter_user.canTriggerNexusCometReversal(front_beam_segment), "Comet Reversal rejects a live hostile beam owner inside its frontal arc")
	counter_user.dir = WEST
	nexusSmokeAssert(!counter_user.canTriggerNexusCometReversal(front_beam_segment) && counter_user.hasNexusStance("comet_reversal"), "a beam owner behind Comet Reversal consumes or triggers its stance")
	counter_user.dir = EAST
	front_beam_segment.Beam = FALSE
	nexusSmokeAssert(!counter_user.tryNexusCometReversal(front_beam_segment) && counter_user.hasNexusStance("comet_reversal"), "a non-beam projectile triggers or consumes Comet Reversal")
	front_beam_segment.Beam = TRUE
	var/obj/Attacks/Beam/self_beam_attack = new(counter_user)
	self_beam_attack.streaming = TRUE
	counter_user.current_beam = self_beam_attack
	var/obj/Blast/self_beam_segment = new(counter_turf)
	self_beam_segment.Beam = TRUE
	self_beam_segment.Owner = counter_user
	self_beam_segment.from_attack = self_beam_attack
	nexusSmokeAssert(!counter_user.canTriggerNexusCometReversal(self_beam_segment) && counter_user.hasNexusStance("comet_reversal"), "a character's own beam can trigger or consume Comet Reversal")
	counter_user.current_beam = null
	del(self_beam_segment)
	del(self_beam_attack)
	var/mob/NexusSmokeTest/second_beam_owner = new(distant_source_turf)
	var/obj/Attacks/Beam/second_beam_attack = new(second_beam_owner)
	second_beam_attack.streaming = TRUE
	second_beam_owner.beaming = TRUE
	second_beam_owner.current_beam = second_beam_attack
	var/obj/Blast/second_beam_segment = new(counter_turf)
	second_beam_segment.Beam = TRUE
	second_beam_segment.Owner = second_beam_owner
	second_beam_segment.from_attack = second_beam_attack
	second_beam_segment.dir = WEST
	var/comet_trigger_time = world.time
	nexusSmokeAssert(counter_user.tryNexusCometReversal(front_beam_segment) && counter_user.hasNexusStance("comet_reversal") && counter_user.nexus_comet_reversal_triggered && counter_user.active_nexus_stance_until == comet_trigger_time + comet_reversal.rush_guard_ticks, "Comet Reversal does not enter its bounded rush guard synchronously on the first valid beam")
	var/comet_rush_guard_until = counter_user.active_nexus_stance_until
	nexusSmokeAssert(counter_user.tryNexusCometReversal(second_beam_segment) && counter_user.hasNexusStance("comet_reversal") && counter_user.active_nexus_stance_until == comet_rush_guard_until, "one Comet Reversal rush failed to intercept a second frontal beam or let that beam extend its guard")
	sleep(1)
	nexusSmokeAssert(counter_user.comet_approach_calls == 1 && counter_user.comet_approach_target == beam_owner, "one Comet Reversal window launched more than one approach or pursued the wrong beam owner")
	nexusSmokeAssert(counter_user.comet_approach_max_distance_pixels == 32 * world.icon_size && counter_user.comet_approach_stop_distance_pixels == world.icon_size && !counter_user.comet_approach_require_selected_target, "Comet Reversal lost its collision-valid thirty-two-tile unselected approach contract")
	nexusSmokeAssert(!counter_user.comet_finisher_calls, "Comet Reversal granted a finisher without reaching adjacency")
	nexusSmokeAssert(!counter_user.hasNexusStance("comet_reversal") && !counter_user.nexus_comet_reversal_triggered && !counter_user.tryNexusCometReversal(second_beam_segment) && counter_user.comet_approach_calls == 1, "Comet Reversal still intercepts beams or launches another approach after its rush ends")
	counter_user.setNexusStance("comet_reversal", comet_reversal.counter_window_ticks)
	var/obj/Blast/nonbeam_projectile = new(counter_turf)
	nonbeam_projectile.setStats(beam_owner, Percent = 1, Off_Mult = 10, Explosion = 0)
	nonbeam_projectile.Deflectable = FALSE
	var/nonbeam_health_before = counter_user.Health
	nonbeam_projectile.BlastMobCross(counter_user, override_delete = TRUE)
	nexusSmokeAssert(counter_user.Health < nonbeam_health_before && counter_user.hasNexusStance("comet_reversal"), "ordinary projectiles no longer damage through or incorrectly consume Comet Reversal")
	counter_user.clearNexusStance()
	del(nonbeam_projectile)
	del(second_beam_segment)
	del(front_beam_segment)
	del(second_beam_owner)
	del(beam_owner)
	del(counter_user)

	runNexusCometReversalMultiBeamSmoke(counter_turf, adjacent_source_turf)
	var/comet_reversal_progression_id = getProgressionNodeIdForType(/obj/Attacks/NexusMeleeTechnique/CometReversal)
	var/guard_break_progression_id = getProgressionNodeIdForType(/obj/Attacks/NexusMeleeTechnique/GuardBreak)
	var/datum/ProgressionNode/comet_reversal_progression_node = progression_node_catalog[comet_reversal_progression_id]
	nexusSmokeAssert(comet_reversal_progression_node && comet_reversal_progression_node.category == "Combat" && comet_reversal_progression_node.branch == "Unarmed" && comet_reversal_progression_node.tier == 4 && comet_reversal_progression_node.cost == getScaledProgressionExperience(20) && (guard_break_progression_id in comet_reversal_progression_node.prerequisites), "Comet Reversal is not a tier-four Unarmed purchase costing 20 after Guard Break")

proc/runNexusActionCycleSmoke()
	var/mob/NexusSmokeTest/action_cycle_player = new
	action_cycle_player.Spd = 10
	var/low_stat_move_pixels = action_cycle_player.GetVectorMovePixels(NORTH)
	action_cycle_player.Spd = 10000
	var/high_stat_move_pixels = action_cycle_player.GetVectorMovePixels(NORTH)
	nexusSmokeAssert(high_stat_move_pixels > low_stat_move_pixels && high_stat_move_pixels <= vector_move_base_pixels_per_second * vector_move_speed_stat_maximum * world.tick_lag, "vector movement does not apply its bounded Speed-stat multiplier")
	action_cycle_player.next_health_bar_update = 25
	action_cycle_player.process_player_action_cycle(FALSE)
	nexusSmokeAssert(action_cycle_player.next_health_bar_update == 25, "headless player action cycle unexpectedly mutated the client HUD throttle")
	var/Energy/action_cycle_energy = new /Energy("Action Cycle", 20)
	action_cycle_energy.quantity = 10
	action_cycle_player.energies = list("Action Cycle" = action_cycle_energy)
	action_cycle_player.process_player_action_cycle(FALSE)
	nexusSmokeAssert(action_cycle_energy.schedule.len == 1, "consolidated player action cycle did not schedule natural energy recovery")
	del(action_cycle_player)
	var/obj/test/texthandling/text_test = new
	text_test.dd_list2text_test()
	del(text_test)

proc/runStartupSmokeTests(soul_contract_count_before)
	var/legacy_description = "<p>A quiet <b>traveler</b>.</p><script>alert('x')</script>\n&lt;visible text&gt;"
	var/normalized_description = normalizeNexusPlayerDescription(legacy_description)
	var/rendered_description = renderNexusPlayerDescription(legacy_description)
	nexusSmokeAssert(normalized_description == "A quiet traveler.\nalert('x')\n<visible text>" && !findtext(normalized_description, "<script") && !findtext(normalized_description, "<b>"), "legacy player descriptions retain executable HTML")
	nexusSmokeAssert(findtext(rendered_description, "&lt;visible text&gt;") && !findtext(rendered_description, "<script") && !findtext(rendered_description, "<b>"), "player profile rendering does not escape plain-text content")
	var/rich_profile_description = renderNexusPlayerDescription("\[color=#66d9ef]\[b]Scholar\[/b]\[/color] and \[i]wanderer\[/i]. <img src=x onerror=alert(1)>")
	nexusSmokeAssert(findtext(rich_profile_description, "<span style='color:#66d9ef'><b>Scholar</b></span>") && findtext(rich_profile_description, "<i>wanderer</i>") && !findtext(rich_profile_description, "<img") && !findtext(rich_profile_description, "onerror"), "player profiles lost safe roleplay markup or retained raw HTML")
	var/legacy_bracket_description = renderNexusPlayerDescription("\[b]literal legacy brackets\[/b]", 0)
	nexusSmokeAssert(findtext(legacy_bracket_description, "\[b]literal legacy brackets\[/b]") && !findtext(legacy_bracket_description, "<b>"), "legacy profiles interpret bracket text as rich markup before opt-in migration")
	nexusSmokeAssert(normalizeNexusPlayerProfileLine("<b>  The\nWanderer  </b>", 12) == "The Wanderer" && normalizeNexusPlayerProfileDirection(999) == SOUTH && normalizeNexusPlayerProfileDirection(WEST) == WEST, "profile title/name bounds or portrait-direction validation regressed")
	nexusSmokeAssert(encodeNexusHtmlAttribute("' onfocus='alert(1)") == "&#39; onfocus=&#39;alert(1)", "profile form fields do not escape single-quoted HTML attributes")
	var/oversized_description = ""
	for(var/description_index = 1, description_index <= NEXUS_PLAYER_DESCRIPTION_LIMIT + 100, description_index++) oversized_description += "x"
	nexusSmokeAssert(length(normalizeNexusPlayerDescription(oversized_description)) == NEXUS_PLAYER_DESCRIPTION_LIMIT, "player descriptions do not enforce their server-side length limit")
	var/legacy_league_notes = "<p>Mission <b>ready</b></p><br>&lt;safe&gt;<img src=x onerror=alert(1)>"
	var/normalized_league_notes = normalizeNexusLeagueNotes(legacy_league_notes)
	var/rendered_league_notes = renderNexusLeagueNotes("<script>Unsafe League</script>", legacy_league_notes)
	nexusSmokeAssert(findtext(normalized_league_notes, "Mission ready") && findtext(normalized_league_notes, "<safe>") && !findtext(normalized_league_notes, "<b>") && !findtext(normalized_league_notes, "<img"), "legacy league notes were not migrated to plain text")
	nexusSmokeAssert(findtext(rendered_league_notes, "&lt;safe&gt;") && !findtext(rendered_league_notes, "<script>") && !findtext(rendered_league_notes, "<img"), "league notes render unescaped player HTML")
	var/oversized_league_notes = ""
	for(var/league_note_index = 1, league_note_index <= NEXUS_LEAGUE_NOTES_LIMIT + 100, league_note_index++) oversized_league_notes += "x"
	nexusSmokeAssert(length(normalizeNexusLeagueNotes(oversized_league_notes)) == NEXUS_LEAGUE_NOTES_LIMIT, "league notes do not enforce their server-side length limit")
	nexusSmokeAssert(normalizeNexusLeagueInlineText("&lt;script&gt;Unsafe&lt;/script&gt;", NEXUS_LEAGUE_NAME_LIMIT) == "scriptUnsafe/script" && length(normalizeNexusLeagueDescription(oversized_league_notes)) == NEXUS_LEAGUE_DESCRIPTION_LIMIT, "league names or descriptions retain executable markup or exceed their limits")
	nexusSmokeAssert(NEXUS_ADMIN_ITEM_PICKER_LEVEL == 2 && normalizeNexusAdminItemPickerMode("give") == "give" && normalizeNexusAdminItemPickerMode("make") == "make" && !normalizeNexusAdminItemPickerMode("spawn") && !normalizeNexusAdminItemPickerMode("GIVE"), "Admin item picker permissions or strict modes regressed")
	nexusSmokeAssert(text2path("/datum/NexusPlayerDescriptionEditor") && getNexusApplicationIconSkinValue() == "'Slime64.png'", "the safe description editor or compiled application icon contract is missing")
	var/mob/NexusSmokeTest/profile_builder_test = new
	profile_builder_test.name = "Actual Identity"
	profile_builder_test.player_profile_name = "The Azure Pilgrim"
	profile_builder_test.player_profile_title = "Walker Between Worlds"
	profile_builder_test.player_desc = "\[b]Safe biography\[/b]"
	profile_builder_test.player_profile_portrait_direction = EAST
	var/datum/NexusPlayerDescriptionEditor/profile_builder = new(profile_builder_test)
	var/list/profile_portrait_resources = list("[SOUTH]" = "front.png", "[WEST]" = "left.png", "[EAST]" = "right.png", "[NORTH]" = "back.png")
	var/profile_builder_html = profile_builder.buildHtml(profile_portrait_resources)
	nexusSmokeAssert(findtext(profile_builder_html, "name='profile_name'") && findtext(profile_builder_html, "name='profile_title'") && findtext(profile_builder_html, "name='portrait_direction'") && findtext(profile_builder_html, "name='generation'") && findtext(profile_builder_html, "The Azure Pilgrim") && findtext(profile_builder_html, "right.png") && findtext(profile_builder_html, "wrap('\[b]','\[/b]')") && findtext(profile_builder_html, "UPLOAD MEDIA") && findtext(profile_builder_html, "PNG, JPEG, WEBP, or WEBM") && findtext(profile_builder_html, "3840&times;2160") && findtext(profile_builder_html, "EXIF/GPS") && findtext(profile_builder_html, "<video id='portraitVideo'") && findtext(profile_builder_html, "profilePortraitFallback") && findtext(profile_builder_html, "setProfileAction('upload_art')") && !findtext(profile_builder_html, "<img src='http"), "the profile builder omits structured identity, WEBP/WEBM/4K upload, privacy/fallback, stale-form, portrait, or rich-text controls")
	del(profile_builder)
	del(profile_builder_test)
	nexusSmokeAssert(NEXUS_DEFAULT_NPCS_ENABLED == 0 && NEXUS_DEFAULT_FEATS_ENABLED == 0 && NEXUS_DEFAULT_TOURNAMENT_INTERVAL_MINUTES == 0, "optional NPC, Feat, or automatic Tournament systems are not disabled by default")
	nexusSmokeAssert(nexus_server_feature_defaults_version >= NEXUS_SERVER_FEATURE_DEFAULTS_VERSION, "server feature-default migration did not run")
	var/obj/reset_vars_test = new
	reset_vars_test.alpha = 12
	ResetVars(reset_vars_test)
	nexusSmokeAssert(reset_vars_test.alpha == initial(reset_vars_test.alpha), "object pooling cannot reset non-mob movable state")
	del(reset_vars_test)
	var/obj/object_cache_test = new
	CacheObject(object_cache_test)
	var/obj/reused_object_cache_test = GetCachedObject(/obj, null)
	nexusSmokeAssert(reused_object_cache_test == object_cache_test && !reused_object_cache_test.cached, "bounded generic object cache did not reuse its LIFO entry")
	reused_object_cache_test.reallyDelete = TRUE
	del(reused_object_cache_test)
	var/PriorityQueue/path_queue_test = new /PriorityQueue(/pathnode/proc/cmp)
	path_queue_test.Enqueue(new /pathnode(null, null, 4, 0))
	path_queue_test.Enqueue(new /pathnode(null, null, 1, 0))
	path_queue_test.Enqueue(new /pathnode(null, null, 3, 0))
	var/pathnode/lowest_path_node = path_queue_test.Dequeue()
	var/pathnode/middle_path_node = path_queue_test.Dequeue()
	nexusSmokeAssert(lowest_path_node.g == 1 && middle_path_node.g == 3, "pathfinding priority queue lost min-heap ordering")
	nexusSmokeAssert(getTargetRating(0, 1) > getTargetRating(15, 1) && getTargetRating(0, 1) > getTargetRating(0, 8), "linear target rating does not prefer aligned nearby targets")
	var/list/null_cleanup_test = list("first", null, "last")
	remove_nulls(null_cleanup_test)
	nexusSmokeAssert(null_cleanup_test.len == 2 && null_cleanup_test[1] == "first" && null_cleanup_test[2] == "last", "runtime null cleanup changed surviving list order")
	nexusSmokeAssert(getMapSavePath(1) == "data/Map1" && getMapSavePath(2) == "data/Map2", "segmented map saves do not remain under data/")
	var/garbage_queue_size_before = garbage_collect.len
	var/obj/garbage_queue_test = new
	nexusSmokeAssert(queueObjectForGarbageCollection(garbage_queue_test), "a disposable object could not enter the garbage queue")
	nexusSmokeAssert(!queueObjectForGarbageCollection(garbage_queue_test), "the garbage queue accepted a duplicate object")
	nexusSmokeAssert(garbage_collect.len == garbage_queue_size_before + 1, "the garbage queue size is inconsistent")
	nexusSmokeAssert(GarbageCollect(1) == 1 && garbage_collect.len == garbage_queue_size_before, "incremental garbage collection did not drain its budget")
	garbage_queue_test = null
	nexusSmokeAssert(text2path("/datum/NexusTradeSession") && text2path("/mob/verb/secureTrade"), "secure player trading types are missing")
	var/mob/NexusSmokeTest/trade_owner = new
	var/mob/NexusSmokeTest/trade_partner = new
	var/obj/items/trade_stack_item = new(trade_owner)
	if(!(trade_stack_item in trade_owner.item_list)) trade_owner.item_list += trade_stack_item
	trade_stack_item.name = "Stacked Trade Item"
	trade_stack_item.Givable = TRUE
	trade_stack_item.Can_Drop_With_Suffix = TRUE
	trade_stack_item.suffix = "12"
	var/datum/NexusTradeSmokeSession/trade_contract = new(trade_owner, trade_partner, FALSE)
	trade_contract.invitation_accepted = TRUE
	trade_contract.phase = "offer"
	var/trade_item_verb_count = trade_stack_item.verbs.len
	nexusSmokeAssert(trade_contract.addItem(trade_owner, trade_stack_item), "secure trade could not add a valid item through its normal offer path")
	nexusSmokeAssert(trade_stack_item.isNexusTradeOfferedBy(trade_owner) && !trade_stack_item.canUseAfterNexusTradeYield(trade_owner) && !trade_owner.isNexusHotkeyObjectAvailable(trade_stack_item) && trade_stack_item.nexus_trade_suspended_verbs && trade_stack_item.verbs.len < trade_item_verb_count, "an actively offered item remains usable through its verbs, yielding helper, or hotkey dispatch")
	nexusSmokeAssert(trade_contract.removeItem(trade_owner, trade_stack_item), "secure trade could not remove an offered item")
	nexusSmokeAssert(!trade_stack_item.isNexusTradeOfferedBy(trade_owner) && trade_stack_item.canUseAfterNexusTradeYield(trade_owner) && !trade_stack_item.nexus_trade_suspended_verbs && trade_stack_item.verbs.len == trade_item_verb_count, "removing an item from a trade does not restore ordinary item use and verbs")
	nexusSmokeAssert(!trade_contract.getItemError(trade_stack_item, trade_owner), "secure trading rejects a transferable stack-count suffix")
	trade_stack_item.suffix = "Equipped"
	nexusSmokeAssert(!!trade_contract.getItemError(trade_stack_item, trade_owner), "secure trading accepts an equipped item")
	trade_stack_item.suffix = null
	var/obj/items/Armor/trade_common_armor = new(trade_owner)
	var/obj/items/Sword/trade_common_sword = new(trade_owner)
	var/obj/items/Gun/trade_common_gun = new(trade_owner)
	var/obj/items/Ammo/trade_common_ammo = new(trade_owner)
	var/obj/items/Shuriken/trade_common_shuriken = new(trade_owner)
	var/obj/items/Sword/Forged/trade_common_forged_weapon = new(trade_owner)
	var/obj/items/Simulator/trade_common_simulator = new(trade_owner)
	var/obj/items/Gravity/trade_common_gravity = new(trade_owner)
	var/obj/items/Stun_Controls/trade_common_stun_controls = new(trade_owner)
	var/list/common_trade_items = list(trade_common_armor, trade_common_sword, trade_common_gun, trade_common_ammo, trade_common_shuriken, trade_common_forged_weapon, trade_common_simulator, trade_common_gravity, trade_common_stun_controls)
	for(var/obj/items/common_trade_item in common_trade_items)
		if(!(common_trade_item in trade_owner.item_list)) trade_owner.item_list += common_trade_item
		var/common_item_error = trade_contract.getItemError(common_trade_item, trade_owner)
		nexusSmokeAssert(!common_item_error, "secure trading rejects guarded ordinary equipment [common_trade_item.type]: [common_item_error]")
	trade_common_gun.Firing = TRUE
	nexusSmokeAssert(!!trade_contract.getItemError(trade_common_gun, trade_owner), "secure trading accepts a gun during its asynchronous refire cycle")
	trade_common_gun.Firing = FALSE
	trade_common_gun.nexus_customization_pending = TRUE
	nexusSmokeAssert(!!trade_contract.getItemError(trade_common_gun, trade_owner), "secure trading accepts an incompletely calibrated gun")
	trade_common_gun.nexus_customization_pending = FALSE
	trade_common_ammo.Reloading = TRUE
	nexusSmokeAssert(!!trade_contract.getItemError(trade_common_ammo, trade_owner), "secure trading accepts ammunition during an asynchronous reload")
	trade_common_ammo.Reloading = FALSE
	trade_common_gravity.upgrading = trade_owner
	nexusSmokeAssert(!!trade_contract.getItemError(trade_common_gravity, trade_owner), "secure trading accepts a gravity generator while its upgrade prompt is active")
	trade_common_gravity.upgrading = null
	trade_common_stun_controls.cant_stun = 1
	nexusSmokeAssert(!!trade_contract.getItemError(trade_common_stun_controls, trade_owner), "secure trading accepts stun controls while their asynchronous cooldown is active")
	trade_common_stun_controls.cant_stun = 0
	var/obj/items/Robotics_Tools/trade_legacy_robotics_tools = new(trade_owner)
	if(!(trade_legacy_robotics_tools in trade_owner.item_list)) trade_owner.item_list += trade_legacy_robotics_tools
	nexusSmokeAssert(!!trade_contract.getItemError(trade_legacy_robotics_tools, trade_owner), "secure trading accepts the intentionally deferred Robotics Tools interaction state machine")
	var/stack_fingerprint = getNexusTradeItemFingerprint(trade_stack_item)
	trade_stack_item.name = "Mutated Trade Item"
	nexusSmokeAssert(stack_fingerprint != getNexusTradeItemFingerprint(trade_stack_item), "trade item state seals ignore visible item mutations")
	trade_stack_item.name = 1
	var/number_name_fingerprint = getNexusTradeScalarFingerprint(trade_stack_item)
	trade_stack_item.name = "1"
	nexusSmokeAssert(number_name_fingerprint != getNexusTradeScalarFingerprint(trade_stack_item), "trade scalar seals collide between numeric and text values")
	trade_stack_item.name = "Line one\nLine two"
	var/newline_name_fingerprint = getNexusTradeScalarFingerprint(trade_stack_item)
	trade_stack_item.name = "Line one"
	nexusSmokeAssert(newline_name_fingerprint != getNexusTradeScalarFingerprint(trade_stack_item), "trade scalar seals do not safely distinguish embedded newlines")
	trade_stack_item.name = "Mutated Trade Item"
	var/obj/items/Pod_Race_Computer/trade_race_computer = new(trade_owner)
	if(!(trade_race_computer in trade_owner.item_list)) trade_owner.item_list += trade_race_computer
	trade_race_computer.Racer_List = list("smoke_racer")
	trade_race_computer.Bets = list("smoke_bet" = 25)
	var/race_computer_disclosure = getNexusTradeItemDisclosure(trade_race_computer)
	nexusSmokeAssert(findtext(race_computer_disclosure, "Racer_List") && findtext(race_computer_disclosure, "smoke_racer") && findtext(race_computer_disclosure, "Bets") && findtext(race_computer_disclosure, "smoke_bet"), "ordinary stateful item saved lists are absent from secure trade review")
	nexusSmokeAssert(!trade_contract.getItemError(trade_race_computer, trade_owner), "a guarded ordinary stateful item is rejected by secure saved-list inspection")
	var/race_computer_fingerprint = getNexusTradeItemFingerprint(trade_race_computer)
	trade_race_computer.Bets["smoke_bet"] = 26
	nexusSmokeAssert(race_computer_fingerprint != getNexusTradeItemFingerprint(trade_race_computer), "ordinary offered-item saved-list mutations do not invalidate the secure trade seal")
	trade_race_computer.Bets["smoke_bet"] = 25
	var/obj/items/DNA_Container/trade_dna_container = new(trade_owner)
	if(!(trade_dna_container in trade_owner.item_list)) trade_owner.item_list += trade_dna_container
	var/mob/NexusSmokeTest/trade_dna_clone = new
	trade_dna_clone.name = "Stored Smoke Clone"
	trade_dna_clone.Str = 4321
	trade_dna_clone.milestones_owned = list("dna_edge" = 2)
	var/obj/Attacks/Genki_Dama/Death_Ball/trade_dna_component = new(trade_dna_clone)
	trade_dna_component.Cost = 17
	trade_dna_container.Clone = trade_dna_clone
	nexusSmokeAssert(trade_dna_container.canUseCloneAfterNexusTradeYield(trade_owner, trade_dna_clone), "an owned DNA Container clone payload fails its guarded-use contract")
	nexusSmokeAssert(trade_contract.addItem(trade_owner, trade_dna_container) && !trade_dna_container.canUseCloneAfterNexusTradeYield(trade_owner, trade_dna_clone), "an offered DNA Container remains usable as a delayed genetics payload")
	nexusSmokeAssert(trade_contract.removeItem(trade_owner, trade_dna_container), "DNA Container guard smoke could not restore the item from its offer")
	trade_dna_container.Move(trade_partner)
	nexusSmokeAssert(!trade_dna_container.canUseCloneAfterNexusTradeYield(trade_owner, trade_dna_clone) && trade_dna_container.canUseCloneAfterNexusTradeYield(trade_partner, trade_dna_clone), "a stale genetics prompt can still read a DNA Container after ownership transfers")
	trade_dna_container.Move(trade_owner)
	var/dna_disclosure = getNexusTradeItemDisclosure(trade_dna_container)
	nexusSmokeAssert(findtext(dna_disclosure, "Clone") && findtext(dna_disclosure, "/mob/NexusSmokeTest") && findtext(dna_disclosure, "Str</b>: 4321") && findtext(dna_disclosure, "dna_edge") && findtext(dna_disclosure, "/obj/Attacks/Genki_Dama/Death_Ball"), "filled DNA container review omits its saved Clone scalar/list/component payload")
	nexusSmokeAssert(!trade_contract.getItemError(trade_dna_container, trade_owner), "a representative filled DNA container is rejected by secure saved-reference inspection")
	var/dna_clone_scalar_fingerprint = getNexusTradeItemFingerprint(trade_dna_container)
	trade_dna_clone.Str = 4322
	nexusSmokeAssert(dna_clone_scalar_fingerprint != getNexusTradeItemFingerprint(trade_dna_container), "DNA Clone scalar mutation does not invalidate the secure trade seal")
	trade_dna_clone.Str = 4321
	var/dna_clone_list_fingerprint = getNexusTradeItemFingerprint(trade_dna_container)
	trade_dna_clone.milestones_owned["dna_edge"] = 3
	nexusSmokeAssert(dna_clone_list_fingerprint != getNexusTradeItemFingerprint(trade_dna_container), "DNA Clone saved-list mutation does not invalidate the secure trade seal")
	trade_dna_clone.milestones_owned["dna_edge"] = 2
	var/dna_clone_component_fingerprint = getNexusTradeItemFingerprint(trade_dna_container)
	trade_dna_component.Cost = 18
	nexusSmokeAssert(dna_clone_component_fingerprint != getNexusTradeItemFingerprint(trade_dna_container), "DNA Clone component mutation does not invalidate the secure trade seal")
	trade_dna_component.Cost = 17
	var/dna_clone_replacement_fingerprint = getNexusTradeItemFingerprint(trade_dna_container)
	var/mob/NexusSmokeTest/trade_replacement_clone = new
	trade_replacement_clone.name = "Stored Smoke Clone"
	trade_replacement_clone.Str = 4321
	trade_replacement_clone.milestones_owned = list("dna_edge" = 2)
	new /obj/Attacks/Genki_Dama/Death_Ball(trade_replacement_clone)
	trade_dna_container.Clone = trade_replacement_clone
	nexusSmokeAssert(dna_clone_replacement_fingerprint != getNexusTradeItemFingerprint(trade_dna_container), "replacing a DNA Container Clone payload does not invalidate the secure trade seal")
	trade_dna_container.Clone = trade_dna_clone
	var/obj/items/ArcaneSatchel/trade_satchel = new(trade_owner)
	if(!(trade_satchel in trade_owner.item_list)) trade_owner.item_list += trade_satchel
	var/obj/items/MagicVault/trade_nested_vault = new(trade_satchel)
	trade_nested_vault.name = "Nested Smoke Vault"
	trade_nested_vault.stored_essence = 9.4
	trade_nested_vault.Password = "<nested&code>"
	var/obj/items/Pod_Race_Computer/trade_nested_race_computer = new(trade_satchel)
	trade_nested_race_computer.Racer_List = list("nested_racer")
	trade_nested_race_computer.Bets = list("nested_bet" = 10)
	var/satchel_disclosure = getNexusTradeItemDisclosure(trade_satchel)
	nexusSmokeAssert(findtext(satchel_disclosure, "CONTAINER CONTENTS (2 OBJECTS)") && findtext(satchel_disclosure, "Nested Smoke Vault") && findtext(satchel_disclosure, "/obj/items/MagicVault") && findtext(satchel_disclosure, "stored_essence</b>: 9.4") && findtext(satchel_disclosure, "nested_racer") && findtext(satchel_disclosure, "nested_bet") && !findtext(satchel_disclosure, "<nested&code>"), "secure trade review omits or fails to encode nested container scalar/list state")
	var/satchel_fingerprint = getNexusTradeItemFingerprint(trade_satchel)
	trade_nested_race_computer.Bets["nested_bet"] = 11
	nexusSmokeAssert(satchel_fingerprint != getNexusTradeItemFingerprint(trade_satchel), "nested saved-list mutation does not invalidate the secure container trade seal")
	trade_nested_race_computer.Bets["nested_bet"] = 10
	trade_nested_vault.Move(trade_owner)
	nexusSmokeAssert(satchel_fingerprint != getNexusTradeItemFingerprint(trade_satchel), "removing a nested container item does not invalidate the secure trade seal")
	trade_nested_vault.Move(trade_satchel)
	trade_satchel.Move(trade_partner)
	nexusSmokeAssert(!trade_satchel.canRetrieveItem(trade_owner, trade_nested_vault) && trade_satchel.canRetrieveItem(trade_partner, trade_nested_vault), "a stale satchel retrieval can still remove contents after ownership transfers")
	trade_satchel.Move(trade_owner)
	var/obj/items/trade_nested_restricted_item = new(trade_satchel)
	trade_nested_restricted_item.Givable = FALSE
	var/nested_bound_error = trade_contract.getItemError(trade_satchel, trade_owner)
	nexusSmokeAssert(findtext(nested_bound_error, "bound"), "a container can bypass secure trade restrictions for a nested Givable=0 item")
	trade_nested_restricted_item.Givable = TRUE
	trade_nested_restricted_item.suffix = "Active"
	trade_nested_restricted_item.Can_Drop_With_Suffix = FALSE
	var/nested_status_error = trade_contract.getItemError(trade_satchel, trade_owner)
	nexusSmokeAssert(findtext(nested_status_error, "current status is active"), "a container can bypass secure trade restrictions for a nested active-status item")
	del(trade_nested_restricted_item)
	var/obj/items/Force_Field/trade_nested_force_field = new(trade_satchel)
	var/nested_force_field_error = trade_contract.getItemError(trade_satchel, trade_owner)
	nexusSmokeAssert(findtext(nested_force_field_error, "Force fields"), "a container can bypass the direct secure-trade restriction on Force Fields")
	del(trade_nested_force_field)
	var/obj/items/ArcaneSatchel/trade_deep_satchel = new(trade_owner)
	if(!(trade_deep_satchel in trade_owner.item_list)) trade_owner.item_list += trade_deep_satchel
	var/obj/deep_container = trade_deep_satchel
	for(var/depth_index = 1, depth_index <= 9, depth_index++)
		deep_container = new /obj/items/ArcaneSatchel(deep_container)
	var/deep_container_error = trade_contract.getItemError(trade_deep_satchel, trade_owner)
	nexusSmokeAssert(findtext(deep_container_error, "depth limit"), "secure trade accepts container contents beyond its bounded traversal depth")
	var/obj/items/MagicVault/trade_magic_vault = new(trade_owner)
	if(!(trade_magic_vault in trade_owner.item_list)) trade_owner.item_list += trade_magic_vault
	var/atom/trade_vault_original_location = trade_magic_vault.loc
	var/trade_vault_original_revision = trade_magic_vault.nexus_trade_location_revision
	nexusSmokeAssert(trade_magic_vault.beginNexusVaultInteraction(trade_owner, trade_vault_original_location, trade_vault_original_revision) && trade_magic_vault.canContinueNexusVaultInteraction(trade_owner, trade_vault_original_location, trade_vault_original_revision), "a carried Magic Vault cannot establish a guarded prompt interaction")
	nexusSmokeAssert(!!trade_contract.getItemError(trade_magic_vault, trade_owner), "secure trading accepts a Magic Vault while a password or balance prompt is active")
	trade_magic_vault.Move(trade_partner)
	nexusSmokeAssert(!trade_magic_vault.canContinueNexusVaultInteraction(trade_owner, trade_vault_original_location, trade_vault_original_revision), "a Magic Vault prompt remains valid after the vault changes ownership")
	trade_magic_vault.endNexusVaultInteraction(trade_owner)
	trade_magic_vault.Move(trade_owner)
	nexusSmokeAssert(!trade_magic_vault.nexus_trade_prompt_pending && !trade_contract.getItemError(trade_magic_vault, trade_owner), "ending a stale Magic Vault prompt does not restore ordinary secure-trade eligibility")
	trade_magic_vault.stored_essence = 12.3
	trade_magic_vault.Password = "<vault&code>"
	var/magic_vault_disclosure = getNexusTradeItemDisclosure(trade_magic_vault)
	nexusSmokeAssert(findtext(magic_vault_disclosure, "MAGIC VAULT VALUE") && findtext(magic_vault_disclosure, "Stored Arcane Essence: 12.3") && findtext(magic_vault_disclosure, "Access code:") && findtext(magic_vault_disclosure, "stored_essence</b>: 12.3") && !findtext(magic_vault_disclosure, "<vault&code>"), "secure trade review omits or fails to encode a Magic Vault's stored value and access code")
	var/obj/items/Android_Blueprint/trade_blueprint = new(trade_owner)
	if(!(trade_blueprint in trade_owner.item_list)) trade_owner.item_list += trade_blueprint
	trade_blueprint.Move(trade_partner)
	nexusSmokeAssert(!trade_blueprint.canAssignSelectedDesign(trade_owner) && trade_blueprint.canAssignSelectedDesign(trade_partner), "a stale Android blueprint design prompt can still mutate the blueprint after ownership transfers")
	trade_blueprint.Move(trade_owner)
	var/blank_blueprint_disclosure = getNexusTradeItemDisclosure(trade_blueprint)
	nexusSmokeAssert(findtext(blank_blueprint_disclosure, "Blank / no stored design") && findtext(blank_blueprint_disclosure, "/obj/items/Android_Blueprint"), "trade review does not disclose a blank Android blueprint's exact identity")
	var/mob/NexusSmokeTest/trade_android_design = new
	trade_android_design.name = "Smoke Android Design"
	trade_android_design.Race = "Android"
	trade_android_design.Class = "Balanced"
	trade_android_design.normalize_energy_types()
	var/Energy/trade_android_energy = trade_android_design.energies["Mental Energy"]
	nexusSmokeAssert(trade_android_energy && trade_android_energy.seal, "normalized Android trade fixture has no persisted Energy/Seal state")
	trade_android_energy.seal.seal_reason = "<energy&seal>"
	var/EnergySchedule/trade_android_schedule = new("increase", 2, 3, "<schedule&reason>")
	trade_android_energy.schedule += trade_android_schedule
	trade_android_design.Str = 1234
	trade_android_design.strmod = 1.23
	trade_android_design.End = 2345
	trade_android_design.endmod = 1.34
	trade_android_design.Spd = 3456
	trade_android_design.spdmod = 1.45
	trade_android_design.Pow = 4567
	trade_android_design.formod = 1.56
	trade_android_design.Res = 5678
	trade_android_design.resmod = 1.67
	trade_android_design.Off = 6789
	trade_android_design.offmod = 1.78
	trade_android_design.Def = 7890
	trade_android_design.defmod = 1.89
	trade_android_design.Decline = 321
	trade_android_design.milestones_owned = list("keen_edge" = 2)
	trade_android_design.character_mutations = list("reactive_guard" = 7)
	trade_android_design.Ranks = list(/obj/Attacks/Blast = 1)
	var/obj/Module/Generator/trade_generator_module = new(trade_android_design)
	trade_generator_module.suffix = "Installed"
	var/obj/Module/Drone_AI/trade_drone_module = new(trade_android_design)
	trade_drone_module.suffix = "Installed"
	trade_drone_module.Password = "<seller&code>"
	var/obj/Module/Combat_Mathematics/trade_combat_mathematics_module = new(trade_android_design)
	trade_combat_mathematics_module.suffix = "Installed"
	var/obj/Buff/Preset/CombatMathematics/trade_module_buff
	for(var/obj/Buff/Preset/CombatMathematics/module_buff in trade_combat_mathematics_module.Abilities)
		trade_module_buff = module_buff
		break
	nexusSmokeAssert(trade_module_buff, "Combat Mathematics trade fixture has no replicated module ability")
	trade_module_buff.buff_attributes = list("transformation")
	var/obj/Attacks/Genki_Dama/Death_Ball/trade_stored_death_ball = new(trade_android_design)
	trade_blueprint.Body = trade_android_design
	var/filled_blueprint_disclosure = getNexusTradeItemDisclosure(trade_blueprint)
	nexusSmokeAssert(findtext(filled_blueprint_disclosure, "Replicated combat core") && findtext(filled_blueprint_disclosure, "STR 1234 (1.23x)") && findtext(filled_blueprint_disclosure, "/obj/Module/Generator") && findtext(filled_blueprint_disclosure, "Energy 2.5x") && findtext(filled_blueprint_disclosure, "Regeneration 0.5x"), "trade review omits replicated Android combat stats or module effects")
	nexusSmokeAssert(findtext(filled_blueprint_disclosure, "FULL REPLICATED SCALAR CONFIGURATION") && findtext(filled_blueprint_disclosure, "Decline</b>: 321"), "trade review omits a saved Android design field outside the curated combat summary")
	nexusSmokeAssert(findtext(filled_blueprint_disclosure, "FULL SAVED LIST CONFIGURATION") && findtext(filled_blueprint_disclosure, "milestones_owned") && findtext(filled_blueprint_disclosure, "keen_edge") && findtext(filled_blueprint_disclosure, "character_mutations") && findtext(filled_blueprint_disclosure, "reactive_guard") && findtext(filled_blueprint_disclosure, "Ranks") && findtext(filled_blueprint_disclosure, "/obj/Attacks/Blast"), "trade review omits saved Android milestone, mutation, or path-keyed list configuration")
	nexusSmokeAssert(findtext(filled_blueprint_disclosure, "/Energy") && findtext(filled_blueprint_disclosure, "/Seal") && findtext(filled_blueprint_disclosure, "/EnergySchedule") && findtext(filled_blueprint_disclosure, "quantity</b>: 100") && !findtext(filled_blueprint_disclosure, "<energy&seal>") && !findtext(filled_blueprint_disclosure, "<schedule&reason>"), "trade review omits or fails to encode normalized Android Energy, Seal, or schedule datum state")
	nexusSmokeAssert(findtext(filled_blueprint_disclosure, "REPLICATED MODULE ABILITIES") && findtext(filled_blueprint_disclosure, "/obj/Buff/Preset/CombatMathematics") && findtext(filled_blueprint_disclosure, "buff_attributes") && findtext(filled_blueprint_disclosure, "transformation"), "trade review omits saved list configuration from a replicated module ability")
	nexusSmokeAssert(findtext(filled_blueprint_disclosure, "/obj/Module/Drone_AI") && findtext(filled_blueprint_disclosure, "Access code / frequency:") && findtext(filled_blueprint_disclosure, "seller may still know this code") && !findtext(filled_blueprint_disclosure, "<seller&code>"), "trade review omits or fails to HTML-encode an Android module access code warning")
	nexusSmokeAssert(trade_stored_death_ball.clonable && !trade_stored_death_ball.Cost && findtext(filled_blueprint_disclosure, "REPLICATED DIRECT COMPONENTS / ABILITIES") && findtext(filled_blueprint_disclosure, "/obj/Attacks/Genki_Dama/Death_Ball") && findtext(filled_blueprint_disclosure, "Replicated with this design"), "trade review hides a zero-cost clonable skill stored in an Android blueprint")
	nexusSmokeAssert(!trade_contract.getItemError(trade_blueprint, trade_owner), "a representative filled Android blueprint is rejected by secure saved-list inspection")
	var/blueprint_list_fingerprint = getNexusTradeItemFingerprint(trade_blueprint)
	trade_android_design.milestones_owned["keen_edge"] = 3
	nexusSmokeAssert(blueprint_list_fingerprint != getNexusTradeItemFingerprint(trade_blueprint), "trade seals ignore saved Android milestone-list mutations")
	trade_android_design.milestones_owned["keen_edge"] = 2
	var/blueprint_path_key_fingerprint = getNexusTradeItemFingerprint(trade_blueprint)
	trade_android_design.Ranks[/obj/Attacks/Blast] = 2
	nexusSmokeAssert(blueprint_path_key_fingerprint != getNexusTradeItemFingerprint(trade_blueprint), "trade seals ignore path-keyed saved-list association mutations")
	trade_android_design.Ranks[/obj/Attacks/Blast] = 1
	var/blueprint_ability_list_fingerprint = getNexusTradeItemFingerprint(trade_blueprint)
	trade_module_buff.buff_attributes += "giant"
	nexusSmokeAssert(blueprint_ability_list_fingerprint != getNexusTradeItemFingerprint(trade_blueprint), "trade seals ignore replicated module-ability saved-list mutations")
	trade_module_buff.buff_attributes -= "giant"
	var/blueprint_energy_fingerprint = getNexusTradeItemFingerprint(trade_blueprint)
	trade_android_energy.seal.duration = 17
	nexusSmokeAssert(blueprint_energy_fingerprint != getNexusTradeItemFingerprint(trade_blueprint), "trade seals ignore a normalized Android's nested Energy/Seal datum mutation")
	trade_android_energy.seal.duration = 0
	var/blueprint_fingerprint = getNexusTradeItemFingerprint(trade_blueprint)
	trade_android_design.Class = "Changed Design"
	nexusSmokeAssert(blueprint_fingerprint != getNexusTradeItemFingerprint(trade_blueprint), "trade seals ignore Android blueprint design mutations")
	var/obj/items/Android_Blueprint/trade_object_blueprint = new(trade_owner)
	if(!(trade_object_blueprint in trade_owner.item_list)) trade_owner.item_list += trade_object_blueprint
	var/obj/items/Gun/trade_gun_design = new
	trade_gun_design.name = "Configured Smoke Gun"
	trade_gun_design.Cost = 5000
	trade_gun_design.Total_Cost = 900
	trade_gun_design.bp_mod = 3.25
	trade_gun_design.Max_Ammo = 42
	trade_gun_design.Range = 17
	trade_gun_design.Deviation = 73
	trade_gun_design.Password = "gun-access"
	trade_object_blueprint.Body = trade_gun_design
	var/object_blueprint_disclosure = getNexusTradeItemDisclosure(trade_object_blueprint)
	nexusSmokeAssert(findtext(object_blueprint_disclosure, "Replicated object configuration") && findtext(object_blueprint_disclosure, "/obj/items/Gun") && findtext(object_blueprint_disclosure, "Damage scale: 3.25") && findtext(object_blueprint_disclosure, "Maximum ammo: 42") && findtext(object_blueprint_disclosure, "Range: 17") && findtext(object_blueprint_disclosure, "Access code / frequency: gun-access"), "trade review omits consequential replicated object-blueprint configuration")
	nexusSmokeAssert(findtext(object_blueprint_disclosure, "FULL REPLICATED SCALAR CONFIGURATION") && findtext(object_blueprint_disclosure, "Deviation</b>: 73"), "trade review's full object configuration omits a saved scalar field outside the concise summary")
	nexusSmokeAssert(!trade_contract.getItemError(trade_object_blueprint, trade_owner), "a representative configured object blueprint is rejected by secure saved-list inspection")
	trade_contract.invitation_accepted = TRUE
	trade_contract.phase = "offer"
	trade_contract.accepted_a = TRUE
	trade_contract.accepted_b = TRUE
	trade_contract.final_a = TRUE
	trade_contract.final_b = TRUE
	var/trade_revision = trade_contract.revision
	trade_contract.resetConfirmations("smoke mutation")
	nexusSmokeAssert(trade_contract.revision == trade_revision + 1 && !trade_contract.accepted_a && !trade_contract.accepted_b && !trade_contract.final_a && !trade_contract.final_b && trade_contract.phase == "offer", "trade offer mutation does not clear both confirmation stages")
	trade_owner.arcane_essence = 10
	trade_contract.setCurrencyOffer(trade_owner, "essence", 3.14)
	nexusSmokeAssertNear(trade_contract.essence_a, 3.1, 0.001, "trade Arcane Essence offers are not normalized to one decimal place")
	var/obj/items/trade_partner_item = new(trade_partner)
	if(!(trade_partner_item in trade_partner.item_list)) trade_partner.item_list += trade_partner_item
	trade_partner_item.name = "Partner Trade Item"
	trade_partner_item.Givable = TRUE
	var/obj/Resources/trade_owner_resources = new(trade_owner)
	var/obj/Resources/trade_partner_resources = new(trade_partner)
	trade_owner.resource_obj = trade_owner_resources
	trade_partner.resource_obj = trade_partner_resources
	trade_owner_resources.Value = 100
	trade_partner_resources.Value = 40
	trade_owner.arcane_essence = 10
	trade_partner.arcane_essence = 5
	trade_contract.offer_a = list(trade_stack_item)
	trade_contract.offer_b = list(trade_partner_item)
	trade_contract.resources_a = 25
	trade_contract.resources_b = 10
	trade_contract.essence_a = 4
	trade_contract.essence_b = 1.5
	trade_contract.phase = "confirm"
	trade_contract.confirmation_revision = trade_contract.revision
	trade_contract.confirmation_fingerprint = trade_contract.getOfferFingerprint()
	trade_contract.final_a = TRUE
	trade_contract.final_b = TRUE
	trade_owner.skip_restore_hotbar = TRUE
	trade_partner.skip_restore_hotbar = FALSE
	var/trade_commit_result = trade_contract.commitTrade()
	var/trade_commit_error = trade_contract ? trade_contract.last_error : "none"
	nexusSmokeAssert(trade_stack_item.loc == trade_partner && (trade_stack_item in trade_partner.item_list) && trade_partner_item.loc == trade_owner && (trade_partner_item in trade_owner.item_list), "atomic trade commit did not swap both offered items through ownership tracking (result [trade_commit_result], error [trade_commit_error], locations [trade_stack_item.loc] / [trade_partner_item.loc])")
	nexusSmokeAssert(trade_owner_resources.Value == 85 && trade_partner_resources.Value == 55, "atomic trade commit produced incorrect Resource balances")
	nexusSmokeAssert(trade_owner.arcane_essence == 7.5 && trade_partner.arcane_essence == 7.5, "atomic trade commit produced incorrect Arcane Essence balances")
	nexusSmokeAssert(trade_owner.skip_restore_hotbar && !trade_partner.skip_restore_hotbar, "atomic trade commit did not restore the traders' hotbar batching guards")
	nexusSmokeAssert(!trade_owner.nexus_trade_session && !trade_partner.nexus_trade_session, "completed trade left an active session attached to a trader")
	del(trade_owner)
	del(trade_partner)
	del(trade_android_design)
	del(trade_gun_design)
	var/mob/NexusSmokeTest/TradeHotbarProbe/trade_rollback_owner = new
	var/mob/NexusSmokeTest/TradeHotbarProbe/trade_rollback_partner = new
	var/obj/items/trade_rollback_item = new(trade_rollback_owner)
	var/obj/items/NexusTradeFailMove/trade_failed_item = new(trade_rollback_owner)
	if(!(trade_rollback_item in trade_rollback_owner.item_list)) trade_rollback_owner.item_list += trade_rollback_item
	if(!(trade_failed_item in trade_rollback_owner.item_list)) trade_rollback_owner.item_list += trade_failed_item
	trade_failed_item.fail_next_move = TRUE
	var/obj/Resources/trade_rollback_owner_resources = new(trade_rollback_owner)
	var/obj/Resources/trade_rollback_partner_resources = new(trade_rollback_partner)
	trade_rollback_owner.resource_obj = trade_rollback_owner_resources
	trade_rollback_partner.resource_obj = trade_rollback_partner_resources
	trade_rollback_owner_resources.Value = 70
	trade_rollback_partner_resources.Value = 20
	trade_rollback_owner.arcane_essence = 6
	trade_rollback_partner.arcane_essence = 1
	var/datum/NexusTradeSmokeSession/trade_rollback_contract = new(trade_rollback_owner, trade_rollback_partner, FALSE)
	trade_rollback_contract.invitation_accepted = TRUE
	trade_rollback_contract.offer_a = list(trade_rollback_item, trade_failed_item)
	trade_rollback_contract.resources_a = 30
	trade_rollback_contract.essence_a = 2
	trade_rollback_contract.phase = "confirm"
	trade_rollback_contract.confirmation_revision = trade_rollback_contract.revision
	trade_rollback_contract.confirmation_fingerprint = trade_rollback_contract.getOfferFingerprint()
	trade_rollback_contract.final_a = TRUE
	trade_rollback_contract.final_b = TRUE
	trade_rollback_owner.skip_restore_hotbar = FALSE
	trade_rollback_partner.skip_restore_hotbar = FALSE
	trade_rollback_contract.commitTrade()
	nexusSmokeAssert(trade_rollback_item.loc == trade_rollback_owner && (trade_rollback_item in trade_rollback_owner.item_list) && trade_failed_item.loc == trade_rollback_owner && (trade_failed_item in trade_rollback_owner.item_list), "failed atomic trade did not roll transferred items back to their original owner")
	nexusSmokeAssert(trade_rollback_owner_resources.Value == 70 && trade_rollback_partner_resources.Value == 20 && trade_rollback_owner.arcane_essence == 6 && trade_rollback_partner.arcane_essence == 1, "failed atomic trade changed a currency balance")
	nexusSmokeAssert(!trade_rollback_owner.skip_restore_hotbar && !trade_rollback_partner.skip_restore_hotbar && trade_rollback_owner.trade_restore_calls == 1 && trade_rollback_partner.trade_restore_calls == 1, "failed atomic trade did not restore batching guards and refresh both hotbars")
	nexusSmokeAssert(trade_rollback_owner.nexus_trade_session == trade_rollback_contract && trade_rollback_partner.nexus_trade_session == trade_rollback_contract && trade_rollback_contract.phase == "offer" && !trade_rollback_contract.accepted_a && !trade_rollback_contract.accepted_b, "failed atomic trade did not return both traders to offer review")
	del(trade_rollback_contract)
	del(trade_rollback_owner)
	del(trade_rollback_partner)
	nexusSmokeAssert(text2path("/datum/NexusEmoteEditor") && text2path("/datum/NexusPlayerLogViewer"), "emote editor or player log viewer datum is missing")
	runNexusPlayerMusicSmokeTests()
	runNexusProfileArtSmokeTests()
	runNexusPlaytestRewardSmokeTests()
	nexusSmokeAssert(text2path("/mob/verb/ViewSelfSayWindow"), "player log viewer verb is missing")
	nexusSmokeAssert(normalizeNexusChatChannel("COMBAT") == "combat" && normalizeNexusChatChannel("invalid") == "all", "chat channel normalization is invalid")
	nexusSmokeAssert(!nexusChatChannelAppearsInAll("combat") && nexusChatChannelAppearsInAll("ic") && nexusChatChannelAppearsInAll("ooc"), "Combat messages still leak into the All roleplay feed")
	var/chat_separator_html = getNexusChatMessageSeparatorHtml()
	nexusSmokeAssert(findtext(chat_separator_html, "<hr") && findtext(chat_separator_html, "width:100%") && !findtext(chat_separator_html, "----------"), "chat messages do not use a full-width horizontal separator")
	var/legacy_chat_markup_html = closeNexusLegacyChatMarkup("<font color=#FFFF00><b>Legacy system notice")
	var/legacy_chat_entry_html = getNexusChatEntryHtml("<font color=#FFFF00><b>Legacy system notice")
	nexusSmokeAssert(legacy_chat_markup_html == "<font color=#FFFF00><b>Legacy system notice</b></font>" && closeNexusLegacyChatMarkup("<font color=#FFFF00><b>Balanced</b></font>") == "<font color=#FFFF00><b>Balanced</b></font>" && legacy_chat_entry_html == "<div class='chat-entry'><font color=#FFFF00><b>Legacy system notice</b></font></div>", "legacy chat formatting markup can leak beyond its entry into later HUD controls")
	nexusSmokeAssert(text2path("/datum/NexusChatHud") && text2path("/obj/HudWindow"), "HudLib chat types are missing")
	nexusSmokeAssert(text2path("/datum/NexusCharacterSelect"), "three-slot character selector is missing")
	nexusSmokeAssert(NEXUS_CHARACTER_SLOT_LIMIT == 3, "character slot limit is not three")
	nexusSmokeAssert(text2path("/client/proc/returnToNexusReconnectLobby"), "reconnect-to-character-select handoff is missing")
	var/mob/NexusSmokeTest/reconnect_character_test = new
	var/obj/reconnect_location_test = new
	reconnect_character_test.loc = reconnect_location_test
	reconnect_character_test.playerCharacter = TRUE
	nexusSmokeAssert(reconnect_character_test.isNexusReconnectCharacter() && getNexusInitialConnectViewWidth(reconnect_character_test, 61) == 0, "a reconnected live character can still receive the oversized title-screen view")
	reconnect_character_test.playerCharacter = FALSE
	nexusSmokeAssert(!reconnect_character_test.isNexusReconnectCharacter() && getNexusInitialConnectViewWidth(reconnect_character_test, 61) == 61, "a lobby mob no longer receives the title-screen view")
	del(reconnect_character_test)
	del(reconnect_location_test)
	nexusSmokeAssert(getNexusMouseZoomViewWidth(37, 1, 39) == 35, "mouse-wheel up does not zoom the map in by one bounded step")
	nexusSmokeAssert(getNexusMouseZoomViewWidth(37, -1, 39) == 39, "mouse-wheel down does not zoom the map out by one bounded step")
	nexusSmokeAssert(getNexusMouseZoomViewWidth(1, 1, 39) == 1 && getNexusMouseZoomViewWidth(39, -1, 39) == 39, "mouse-wheel zoom exceeds the Screen_Size view-width bounds")
	nexusSmokeAssert(getNexusMouseZoomViewWidth(10, 1, 39) == 8 && getNexusMouseZoomViewWidth(10, -1, 39) == 12, "mouse-wheel zoom changes direction inside the legacy Screen_Size range")
	var/list/map_zoom_planes = getNexusMapZoomPlanes()
	var/obj/NexusMapZoomPlaneMaster/map_zoom_master = new
	var/obj/fixed_zoom_target = new
	fixed_zoom_target.plane = NEXUS_FIXED_HUD_PLANE
	nexusSmokeAssert(getNexusMapRenderWidth(TRUE, 13, 39) == 39 && getNexusMapRenderWidth(FALSE, 61, 39) == 61, "live map zoom changes client.view or constrains the title screen")
	nexusSmokeAssert(getNexusMapZoomScale(39, 39) == 1 && getNexusMapZoomScale(13, 39) == 3 && getNexusMapRenderHeight(39, 1920, 1080) == 22, "map-only zoom does not preserve its fixed render envelope or aspect ratio")
	nexusSmokeAssert((0 in map_zoom_planes) && (NEXUS_WORLD_OVERLAY_PLANE in map_zoom_planes) && !(NEXUS_FIXED_HUD_PLANE in map_zoom_planes), "map-only zoom includes the fixed HUD plane or omits world planes")
	nexusSmokeAssert((map_zoom_master.appearance_flags & PLANE_MASTER) && (map_zoom_master.appearance_flags & PIXEL_SCALE) && (map_zoom_master.appearance_flags & NO_CLIENT_COLOR) && map_zoom_master.mouse_opacity == 1 && map_zoom_master.screen_loc == "1,1", "map-only zoom plane master breaks rendering, color, or world mouse input")
	nexusSmokeAssert(nexusMouseWheelCanZoomMap("mapwindow.map", map_zoom_master) && !nexusMouseWheelCanZoomMap("mapwindow.map", fixed_zoom_target) && !nexusMouseWheelCanZoomMap("nexuschatwindow.chat", map_zoom_master), "mouse wheel zoom captures fixed HUD or browser controls")
	del(map_zoom_master)
	del(fixed_zoom_target)
	nexusSmokeAssert(getNexusCharacterSavePathForKey("Smoke Key", 1) == "data/Save/smokekey-slot1.sav", "slot-one save path is invalid")
	nexusSmokeAssert(getNexusCharacterSavePathForKey("Smoke Key", 3) == "data/Save/smokekey-slot3.sav", "slot-three save path is invalid")
	nexusSmokeAssert(getNexusCharacterSavePathForKey("Smoke Key", 4) == getNexusCharacterSavePathForKey("Smoke Key", 3), "character slot clamping is invalid")
	nexusSmokeAssert(getNexusCharacterSavePathForKey("Smoke Key", 1, "playtest") == "data/Playtest/Save/smokekey-slot1.sav" && getNexusFeatSavePathForKey("Smoke Key", 2, "playtest") == "data/Playtest/Feats/smokekey-slot2.sav", "playtest character persistence is not namespaced away from live saves")
	var/list/live_wipe_roots = getNexusWipePersistenceRoots(TRUE, "live")
	var/list/playtest_wipe_roots = getNexusWipePersistenceRoots(TRUE, "playtest")
	var/list/playtest_save_only_wipe_roots = getNexusWipePersistenceRoots(FALSE, "playtest")
	nexusSmokeAssert(live_wipe_roots.len == 2 && ("data/Save/" in live_wipe_roots) && ("data/Feats/" in live_wipe_roots), "live pwipe does not target both active persistence roots")
	nexusSmokeAssert(playtest_wipe_roots.len == 2 && ("data/Playtest/Save/" in playtest_wipe_roots) && ("data/Playtest/Feats/" in playtest_wipe_roots), "playtest pwipe targets live persistence or omits active playtest data")
	nexusSmokeAssert(playtest_save_only_wipe_roots.len == 1 && ("data/Playtest/Save/" in playtest_save_only_wipe_roots), "pwipe cannot preserve Feats while deleting the active character root")
	nexusSmokeAssert(text2path("/mob/Admin4/verb/pwipe"), "level-four pwipe verb is missing")
	nexusSmokeAssert(isNexusSaveEnvironmentCompatible(null, "live") && !isNexusSaveEnvironmentCompatible(null, "playtest") && !isNexusSaveEnvironmentCompatible("playtest", "live") && isNexusSaveEnvironmentCompatible("playtest", "playtest"), "character save environment markers permit cross-environment loading")
	nexusSmokeAssert(findtext(getNexusRpgBrowserCss(), "border-radius:0") && findtext(getNexusRpgBrowserCss(), "Courier New"), "shared rustic browser theme is missing")
	var/rich_emote_test = renderNexusEmoteMarkup("<script>\[color=#ff667a]\[b]Hit\[/b]\[/color]")
	nexusSmokeAssert(findtext(rich_emote_test, "&lt;script&gt;") && findtext(rich_emote_test, "<span style='color:#ff667a'><b>Hit</b></span>"), "safe rich emote markup did not render correctly")
	nexusSmokeAssert(!findtext(rich_emote_test, "<script>"), "rich emote markup allowed raw HTML")
	var/formatted_emote_test = buildNexusEmoteMessage("Smoke", rich_emote_test, "Normal")
	nexusSmokeAssert(findtext(formatted_emote_test, "<br><br>") && findtext(formatted_emote_test, "color:#ff667a"), "roleplay title spacing or inline colors were lost")
	var/emote_swatches_test = getNexusEmoteColorSwatchesHtml()
	nexusSmokeAssert(findtext(emote_swatches_test, "background:#f5f7fa!important") && findtext(emote_swatches_test, "background:#ff667a!important") && findtext(emote_swatches_test, "background:#bd93f9!important"), "rustic browser theme can override emote editor color swatches")
	var/fifty_word_test = ""
	for(var/word_index = 1, word_index <= 50, word_index++) fifty_word_test += word_index == 1 ? "word" : " word"
	nexusSmokeAssert(countNexusWords(fifty_word_test) == 50 && countNexusWords("one\ttwo\nthree") == 3, "Say overhead word limit does not count whitespace-delimited words")
	var/combat_log_test = buildNexusCombatLogMessage("Attacker", "Target", "Kienzan", 42, 3, "Health", 58)
	nexusSmokeAssert(findtext(combat_log_test, "Kienzan") && findtext(combat_log_test, "Attacker") && findtext(combat_log_test, "Target") && findtext(combat_log_test, "3 hits / 42 total"), "combat log summary omits attack, participants, or multi-hit damage")
	var/precise_combat_amount = formatNexusCombatAmount(12.34)
	var/precise_combat_log = buildNexusCombatLogMessage("Attacker", "Target", "Precision Test", 12.34, 1, "Health", 87.66)
	nexusSmokeAssert(precise_combat_amount == "12.34" && findtext(precise_combat_log, "12.34 damage") && findtext(precise_combat_log, "87.66% Health remaining"), "damage indicators and combat logs do not share hundredth precision (amount=[precise_combat_amount]; log=[precise_combat_log])")
	var/datum/NexusCombatLogBatch/combat_log_batch_test = new(null, null, "Beam", "Health")
	combat_log_batch_test.addDamage(7, 93)
	combat_log_batch_test.addDamage(5, 88)
	nexusSmokeAssert(combat_log_batch_test.total_damage == 12 && combat_log_batch_test.hit_count == 2 && combat_log_batch_test.remaining_value == 88, "combat damage batching does not aggregate repeated hits")
	del(combat_log_batch_test)
	nexusSmokeAssert(!text2path("/mob/verb/viewAdminLogs"), "admin log viewer is exposed to ordinary mobs")
	nexusSmokeAssert(!text2path("/mob/verb/viewAllAdminLogs"), "combined admin log viewer is exposed to ordinary mobs")
	nexusSmokeAssert(text2path("/mob/Admin1/verb/viewAdminLogs"), "admin log viewer is missing from the admin verb tree")
	nexusSmokeAssert(text2path("/mob/Admin1/verb/viewAllAdminLogs"), "combined admin log viewer is missing from the admin verb tree")
	nexusSmokeAssert(!text2path("/mob/verb/spawnCombatDummy"), "combat dummy spawner is exposed to ordinary mobs")
	nexusSmokeAssert(text2path("/mob/Admin2/verb/spawnCombatDummy"), "combat dummy spawner is missing from the admin verb tree")
	nexusSmokeAssert(text2path("/mob/Admin2/verb/controlCombatDummy"), "combat dummy controller is missing from the admin verb tree")
	nexusSmokeAssert(text2path("/obj/DamageIndicator"), "damage indicator type is missing")
	nexusSmokeAssert(text2path("/obj/NexusHud/VitalsPanel"), "main vitals HUD type is missing")
	nexusSmokeAssert(text2path("/obj/NexusLighting/PlaneMaster") && text2path("/obj/NexusLighting/Emitter"), "screen lighting plane types are missing")
	nexusSmokeAssert(text2path("/mob/verb/toggleNexusLighting") && text2path("/mob/Admin2/verb/testNexusLighting"), "lighting control verbs are missing")
	nexusSmokeAssert(text2path("/mob/Admin2/verb/setMaximumDarkness") && text2path("/mob/Admin2/verb/testNexusGlow") && text2path("/mob/Admin2/verb/testNexusBlast"), "dedicated lighting test verbs are missing")
	nexusSmokeAssert(text2path("/mob/Admin2/verb/testNexusBeamLighting") && text2path("/mob/Admin2/verb/testNexusLightVariations") && text2path("/mob/Admin2/verb/testNexusTurfOcclusion"), "beam, flicker, or turf-collision lighting test verbs are missing")
	nexusSmokeAssert(text2path("/obj/Effect/NexusLightingTestBlast"), "harmless lighting test blast is missing")
	var/obj/NexusLighting/PlaneMaster/lighting_plane = new
	var/obj/NexusLighting/Emitter/lighting_emitter = new
	var/obj/LightSource/static_light = new
	var/icon/lighting_mask = icon('NexusLightGradient.dmi', "10")
	var/list/lighting_states = icon_states('NexusLightGradient.dmi')
	var/list/lighting_center_rgb = rgb2num(lighting_mask.GetPixel(128, 128))
	var/list/lighting_half_rgb = rgb2num(lighting_mask.GetPixel(64, 128))
	var/list/lighting_edge_rgb = rgb2num(lighting_mask.GetPixel(2, 128))
	nexusSmokeAssert(lighting_plane.plane == 15 && lighting_plane.blend_mode == BLEND_MULTIPLY && (lighting_plane.appearance_flags & PLANE_MASTER), "night screen is not a multiplicative plane master")
	nexusSmokeAssert(lighting_emitter.plane == 15 && lighting_emitter.blend_mode == BLEND_ADD, "dynamic glow is not additive on the lighting plane")
	nexusSmokeAssert(lighting_mask.Width() == 256 && lighting_mask.Height() == 256 && ("1" in lighting_states) && ("10" in lighting_states), "configurable lighting gradient is corrupt or incomplete")
	nexusSmokeAssert(lighting_center_rgb[1] > lighting_half_rgb[1] && lighting_half_rgb[1] > lighting_edge_rgb[1], "lighting falloff is not encoded in additive RGB intensity")
	lighting_emitter.configureNexusEmitter("#ffffff", 1, 200, 'NexusLightGradient.dmi', TRUE, 10)
	nexusSmokeAssert(lighting_emitter.core_visual && lighting_emitter.range_tiles == 1 && lighting_emitter.gradient_offset == 10 && lighting_emitter.icon_state == "10" && lighting_emitter.core_visual.icon_state == "1", "layered glow did not apply its requested gradient profile")
	nexusSmokeAssert(lighting_emitter.alpha < lighting_emitter.core_visual.alpha && lighting_emitter.base_core_scale < lighting_emitter.base_range_scale, "layered glow does not have a compact core and softer ranged falloff")
	nexusSmokeAssert(round(getNexusGlowRangeScale(1) * 256 / world.icon_size, 0.1) == 1, "glow size no longer maps to total tile diameter")
	lighting_emitter.configureNexusEmitter("#ffffff", 1.1, 145, 'NexusLightGradient.dmi', TRUE, 4, "small_blast")
	nexusSmokeAssert(lighting_emitter.variation_style == "small_blast" && lighting_emitter.variation_enabled && lighting_emitter.range_tiles == 1.1, "small-blast flicker profile was not applied")
	nexusSmokeAssert(static_light.plane == 15 && static_light.getRenderedAlpha() == 210 && static_light.core_visual, "legacy light sources were not adapted to layered screen lighting")
	var/turf/mobile_light_start = locate(445, 3, 2)
	var/turf/mobile_light_destination = mobile_light_start ? get_step(mobile_light_start, WEST) : null
	nexusSmokeAssert(mobile_light_start && mobile_light_destination, "startup map has no turfs for attached light regression testing")
	var/obj/mobile_light_owner = new(mobile_light_start)
	mobile_light_owner.GiveLightSource(size = 2, max_alpha = 40, auto_fade = 0)
	sleep(1)
	var/obj/LightSource/mobile_attached_light = mobile_light_owner.light_obj
	nexusSmokeAssert(mobile_attached_light && mobile_attached_light.light_origin == mobile_light_owner && (mobile_attached_light in mobile_light_owner.vis_contents), "item light source is not visually attached to its owner")
	mobile_light_owner.SafeTeleport(mobile_light_destination)
	nexusSmokeAssert(mobile_attached_light.getNexusLightOriginTurf() == mobile_light_destination, "attached item light did not follow its moved owner")
	del(mobile_light_owner)
	nexusSmokeAssert(!(mobile_attached_light in light_sources), "deleting a lit item left an orphaned light source")
	var/list/blue_glow_profile = getNexusTransformationGlowProfile("saiyan_blue")
	var/list/test_ambient_matrix = getNexusAmbientMatrix(rgb(16, 22, 38, 255))
	nexusSmokeAssert(islist(test_ambient_matrix) && test_ambient_matrix[4] == "#0000" && blue_glow_profile["color"] == "#42d9ff" && blue_glow_profile["alpha"] >= 200, "ambient alpha reset or transformation glow profiles are invalid")
	var/mob/NexusSmokeTest/lighting_owner = new
	var/obj/NexusLighting/Emitter/action_glow = lighting_owner.setNexusActionGlow("#ffffff", 1, 255, 'NexusLightGradient.dmi', 10, "charge")
	var/obj/NexusLighting/Emitter/aura_glow = lighting_owner.setNexusAuraGlow("#76dfff", 3, 190, 'NexusLightGradient.dmi', 8, "aura")
	nexusSmokeAssert(action_glow && (action_glow in lighting_owner.vis_contents) && action_glow.gradient_offset == 10, "independent beam/action glow was not attached with its requested falloff")
	nexusSmokeAssert(aura_glow && aura_glow != action_glow && (aura_glow in lighting_owner.vis_contents) && aura_glow.variation_style == "aura", "independent aura flicker was not attached")
	lighting_owner.clearNexusActionGlow()
	nexusSmokeAssert(!lighting_owner.nexus_action_glow, "independent beam/action glow was not cleared")
	lighting_owner.clearNexusAuraGlow()
	nexusSmokeAssert(!lighting_owner.nexus_aura_glow, "independent aura glow was not cleared")
	var/obj/Blast/small_light_projectile = new
	var/obj/Attacks/Buster_Barrage/small_light_attack = new
	small_light_projectile.percent_damage = 0.4
	small_light_projectile.from_attack = small_light_attack
	var/list/small_light_profile = getNexusProjectileLightProfile(small_light_projectile)
	var/obj/Blast/large_light_projectile = new
	var/obj/Attacks/Big_Bang_Attack/large_light_attack = new
	large_light_projectile.percent_damage = 22
	large_light_projectile.Explosive = 4
	large_light_projectile.from_attack = large_light_attack
	var/list/large_light_profile = getNexusProjectileLightProfile(large_light_projectile)
	var/large_icon_diameter = getNexusProjectileVisualDiameter(large_light_attack.icon)
	nexusSmokeAssert(large_icon_diameter >= world.icon_size && getNexusProjectileVisualDiameter(large_light_attack.icon) == large_icon_diameter, "projectile icon diameter cache is unstable")
	var/obj/Blast/beam_light_projectile = new
	beam_light_projectile.Beam = 1
	beam_light_projectile.Owner = lighting_owner
	var/list/beam_light_profile = getNexusProjectileLightProfile(beam_light_projectile)
	nexusSmokeAssert(small_light_profile["variation"] == "small_blast" && small_light_profile["size"] <= 1.15, "small blasts do not receive a compact flickering light")
	nexusSmokeAssert(large_light_profile["variation"] == "blast" && large_light_profile["size"] >= 4.2 && large_light_profile["size"] > small_light_profile["size"], "large blasts do not receive their larger light profile")
	nexusSmokeAssert(beam_light_profile["variation"] == "beam" && beam_light_profile["size"] <= 2 && beam_light_profile["alpha"] < large_light_profile["alpha"], "beam segments do not receive a compact trail-light profile")
	small_light_projectile.Is_Ki = 0
	nexusSmokeAssert(!getNexusProjectileLightProfile(small_light_projectile), "physical projectiles incorrectly emit ki lighting")
	var/turf/light_collision_source
	var/turf/light_collision_wall
	var/turf/light_collision_shadow
	for(var/turf/candidate_light_source in world)
		var/turf/candidate_light_wall = get_step(candidate_light_source, EAST)
		var/turf/candidate_light_shadow = candidate_light_wall ? get_step(candidate_light_wall, EAST) : null
		if(candidate_light_wall && candidate_light_shadow)
			light_collision_source = candidate_light_source
			light_collision_wall = candidate_light_wall
			light_collision_shadow = candidate_light_shadow
			break
	nexusSmokeAssert(light_collision_source && light_collision_wall && light_collision_shadow, "startup map has no turf line for light-collision tests")
	lighting_owner.SafeTeleport(light_collision_source)
	lighting_owner.current_area = light_collision_source.loc
	nexusSmokeAssert(lighting_owner in mob_view(0, light_collision_source), "short-range native spatial query omitted a same-turf mob")
	lighting_owner.SafeTeleport(null)
	lighting_owner.current_area = null
	var/original_light_source_density = light_collision_source.density
	var/original_light_source_opacity = light_collision_source.opacity
	var/original_light_wall_density = light_collision_wall.density
	var/original_light_wall_opacity = light_collision_wall.opacity
	var/original_light_shadow_density = light_collision_shadow.density
	var/original_light_shadow_opacity = light_collision_shadow.opacity
	light_collision_source.density = 0
	light_collision_source.opacity = 0
	light_collision_wall.density = 1
	light_collision_wall.opacity = 1
	light_collision_shadow.density = 0
	light_collision_shadow.opacity = 0
	var/list/cardinal_light_ray = traceGridRay(light_collision_source, light_collision_shadow)
	nexusSmokeAssert(cardinal_light_ray.len == 2 && cardinal_light_ray[1] == light_collision_wall && cardinal_light_ray[2] == light_collision_shadow, "shared grid ray does not traverse a cardinal line deterministically")
	var/pathfinder/astar/pathfinder_contract = new
	nexusSmokeAssert(!(light_collision_wall in pathfinder_contract.neighbors(light_collision_source)), "A* neighbor generation accepted a dense blocking turf")
	var/list/same_turf_path = pathfinder_contract.search(light_collision_source, light_collision_source)
	nexusSmokeAssert(islist(same_turf_path) && !same_turf_path.len, "bounded A* does not return an empty path for an identical start and destination")
	nexusSmokeAssert(nexusLightCanReach(light_collision_source, light_collision_wall), "light does not illuminate the visible face of a blocking turf")
	nexusSmokeAssert(!nexusLightCanReach(light_collision_source, light_collision_shadow), "dense opaque turf does not cast a lighting shadow")
	var/light_collision_key = getNexusLightOcclusionCacheKey(light_collision_source, 6)
	var/icon/light_collision_mask = getNexusLightOcclusionMask(light_collision_source, 6, light_collision_key)
	nexusSmokeAssert(light_collision_mask && light_collision_mask.GetPixel(171, 129), "light collision mask removed the blocking turf face")
	nexusSmokeAssert(!light_collision_mask.GetPixel(214, 129), "light collision mask did not clear pixels behind a blocking turf")
	var/obj/NexusLighting/Emitter/occluded_emitter = new(light_collision_source)
	occluded_emitter.configureNexusEmitter("#ffffff", 6, 220, 'NexusLightGradient.dmi', FALSE, 10, "charge")
	nexusSmokeAssert(occluded_emitter.filters && occluded_emitter.occlusion_mask_key == light_collision_key, "eligible light emitter did not apply its turf alpha mask")
	light_collision_source.density = original_light_source_density
	light_collision_source.opacity = original_light_source_opacity
	light_collision_wall.density = original_light_wall_density
	light_collision_wall.opacity = original_light_wall_opacity
	light_collision_shadow.density = original_light_shadow_density
	light_collision_shadow.opacity = original_light_shadow_opacity
	del(occluded_emitter)
	del(small_light_projectile)
	del(small_light_attack)
	del(large_light_projectile)
	del(large_light_attack)
	del(beam_light_projectile)
	del(lighting_plane)
	del(lighting_emitter)
	del(static_light)
	del(lighting_owner)
	nexusSmokeAssert(text2path("/obj/NexusHud/ActionButton/Lethal") && text2path("/obj/NexusHud/ActionButton/RPMode") && text2path("/obj/NexusHud/ActionButton/Character"), "top-right action HUD is incomplete")
	var/icon/action_button_icon = getNexusActionButtonIcon(TRUE, "#ff4d5f")
	nexusSmokeAssert(action_button_icon.Width() == 108 && action_button_icon.Height() == 20, "action HUD button has invalid dimensions")
	nexusSmokeAssert(text2path("/obj/NexusHud/ShortcutButton/Inventory") && text2path("/obj/NexusHud/ShortcutButton/Skills") && text2path("/obj/NexusHud/ShortcutButton/Progression") && text2path("/obj/NexusHud/ShortcutButton/Milestones") && text2path("/obj/NexusHud/ShortcutButton/Build") && text2path("/obj/NexusHud/ShortcutButton/Sense") && text2path("/obj/NexusHud/ShortcutButton/World") && text2path("/obj/NexusHud/ShortcutButton/Chat") && text2path("/obj/NexusHud/ShortcutButton/Hotkeys") && text2path("/obj/NexusHud/ShortcutButton/Menu") && text2path("/obj/NexusHud/ShortcutButton/Admin"), "top shortcut HUD is incomplete")
	nexusSmokeAssert(!text2path("/obj/NexusHud/ShortcutButton/Command"), "obsolete CMD shortcut is still in the navbar")
	nexusSmokeAssert(!text2path("/obj/NexusHud/ShortcutButton/Map") && !text2path("/mob/verb/planetMap") && text2path("/mob/Admin1/verb/planetMap"), "planet map is not restricted to an admin verb")
	var/mob/NexusSmokeTest/unauthenticated_shortcut_owner = new
	var/list/unauthenticated_shortcut_types = unauthenticated_shortcut_owner.getNexusShortcutTypes()
	nexusSmokeAssert(unauthenticated_shortcut_types.len == 9, "non-admin shortcut HUD did not return to its nine-button contract")
	del(unauthenticated_shortcut_owner)
	var/list/no_admin_verb_paths = getNexusAdminVerbPaths(0)
	var/list/level_one_admin_verb_paths = getNexusAdminVerbPaths(1)
	nexusSmokeAssert(!(/mob/Admin1/verb/planetMap in no_admin_verb_paths) && (/mob/Admin1/verb/planetMap in level_one_admin_verb_paths), "admin verb catalog does not grant Planet Map exclusively at Admin Level 1+")
	var/mob/NexusSmokeTest/admin_map_verb_contract = new
	admin_map_verb_contract.grantAdminVerbsForLevel(1)
	nexusSmokeAssert(/mob/Admin1/verb/planetMap in admin_map_verb_contract.verbs, "Admin Level 1 does not receive the Planet Map verb")
	admin_map_verb_contract.Remove_Admin()
	nexusSmokeAssert(!(/mob/Admin1/verb/planetMap in admin_map_verb_contract.verbs), "removing admin did not revoke the Planet Map verb")
	del(admin_map_verb_contract)
	nexusSmokeAssert(text2path("/datum/NexusPlayerMenu") && text2path("/datum/NexusCharacterSheetWindow") && text2path("/datum/NexusInterfaceSettings") && text2path("/datum/NexusPlanetMapWindow") && text2path("/datum/NexusPlanetMapScan"), "replacement player menu, live Character sheet, interface settings, or planet map is missing")
	nexusSmokeAssert(text2path("/mob/proc/toggleNexusPlayerMenu") && text2path("/mob/proc/toggleProgressionTrees") && text2path("/mob/proc/toggleCharacterSheet") && text2path("/mob/proc/toggleNexusHotkeyEditor") && text2path("/mob/proc/toggleNexusAdminPanel") && text2path("/mob/proc/toggleNexusPlanetMap") && text2path("/mob/proc/requestNexusPlanetMapScan"), "top HUD windows are missing their same-icon close toggles or scanner")
	var/live_browser_script_test = getNexusLiveBrowserScript(null, 37)
	nexusSmokeAssert(nexus_live_browser_refresh_ticks == 10 && nexus_live_browser_heartbeat_milliseconds == 1000 && nexus_live_browser_scroll_idle_ticks == 20 && findtext(live_browser_script_test, "action:'heartbeat'") && findtext(live_browser_script_test, "nexusLiveRestoreScrollY=37") && findtext(live_browser_script_test, "sessionStorage") && findtext(live_browser_script_test, "nexusLiveOnScroll") && findtext(live_browser_script_test, "setTimeout(nexusPublishLiveScroll,80)") && findtext(live_browser_script_test, "beforeunload") && findtext(getNexusLiveBrowserScript(null, nexus_live_browser_scroll_placeholder), nexus_live_browser_scroll_placeholder), "live browser refresh cadence, immediate scroll handoff, stateful restoration, or heartbeat is missing")
	nexusSmokeAssert(text2path("/mob/verb/focusNexusCommand"), "Return-key CMD routing verb is missing")
	nexusSmokeAssert(!text2path("/mob/proc/Stat_NexusSkills") && !text2path("/mob/proc/Stat_NexusOther") && !text2path("/mob/proc/Stat_NexusAdmin"), "synthetic statpanels duplicate native Skills, Other, or Admin tabs")
	nexusSmokeAssert(normalizeNexusInterfaceLayout("side_tabs") == "side_tabs" && normalizeNexusInterfaceLayout("invalid") == "overlay", "interface layout normalization is invalid")
	nexusSmokeAssert(text2path("/obj/Effect/NexusSayText") && text2path("/obj/Effect/NexusTypingIndicator"), "short Say messages or typing feedback are missing their overhead actors")
	var/mob/NexusSmokeTest/overhead_layout_test = new
	overhead_layout_test.icon = 'Healthbar.dmi'
	nexusSmokeAssert(getNexusOverheadVitalsBasePixelY(overhead_layout_test) == -12 && getNexusTypingIndicatorPixelY(overhead_layout_test) == 12 && getNexusOverheadFeedbackPixelY(overhead_layout_test) == 46, "Say text, typing, character, and lower vitals are not vertically ordered")
	nexusSmokeAssert(getNexusTypingIndicatorPixelY(overhead_layout_test) + 32 < getNexusOverheadFeedbackPixelY(overhead_layout_test) && getNexusTypingIndicatorPixelY(overhead_layout_test) + 22 > GetHeight(overhead_layout_test.icon), "typing is not below Say text and above the character")
	nexusSmokeAssert(getNexusOverheadPercentagePixelY(overhead_layout_test) == -25 && getNexusOverheadPercentagePixelY(overhead_layout_test) + 12 < getNexusOverheadVitalsBasePixelY(overhead_layout_test), "Sense percentage is not below the overhead vitals")
	overhead_layout_test.setNexusOverheadVitalsOffset(6, 12)
	nexusSmokeAssert(getNexusOverheadVitalsBasePixelX(overhead_layout_test) == 6 && getNexusOverheadVitalsBasePixelY(overhead_layout_test) == 0 && getNexusOverheadPercentagePixelY(overhead_layout_test) == -13 && getNexusTypingIndicatorPixelY(overhead_layout_test) == 12, "custom vitals offsets do not keep Sense below the bars and typing above the character")
	del(overhead_layout_test)
	var/icon/shortcut_button_icon = getNexusShortcutButtonIcon("inventory", FALSE, "#d6aa5d")
	var/icon/shortcut_bar_icon = getNexusShortcutBarIcon(9)
	nexusSmokeAssert(shortcut_button_icon.Width() == 26 && shortcut_button_icon.Height() == 26, "shortcut HUD button has invalid dimensions")
	nexusSmokeAssert(shortcut_bar_icon.Width() == 260 && shortcut_bar_icon.Height() == 34, "shortcut HUD backing strip has invalid dimensions")
	nexusSmokeAssert(normalizeNexusPlanetMapStatus("queued") == "scanning" && normalizeNexusPlanetMapStatus("READY") == "ready" && normalizeNexusPlanetMapStatus("unknown") == "unavailable", "planet-map browser status normalization is invalid")
	nexusSmokeAssertNear(getNexusPlanetMapMarkerPercent(1.5, 1, 10), 5, 0.01, "planet-map west-edge marker placement is invalid")
	nexusSmokeAssertNear(getNexusPlanetMapMarkerPercent(10.5, 1, 10), 95, 0.01, "planet-map east-edge marker placement is invalid")
	nexusSmokeAssertNear(getNexusPlanetMapMarkerPercent(1.5, 1, 10, TRUE), 95, 0.01, "planet-map north-up Y inversion is invalid")
	var/list/planet_map_browser_state = list(
		"status" = "idle",
		"message" = "Ready to scan this location.",
		"planet_name" = "Earth",
		"area_name" = "Earth",
		"min_x" = 1,
		"min_y" = 1,
		"max_x" = 10,
		"max_y" = 10,
		"map_width" = 10,
		"map_height" = 10,
		"progress" = 0,
		"tiles_scanned" = 0,
		"total_tiles" = 100,
		"elapsed_ticks" = 0,
		"elapsed_ms" = 0,
		"tiles_per_second" = 0,
		"yield_count" = 0,
		"unique_appearances" = 0,
		"peak_tick_usage" = 0)
	var/datum/NexusPlanetMapWindow/planet_map_browser_test = new
	var/planet_map_browser_html = planet_map_browser_test.buildHtml(planet_map_browser_state, "")
	nexusSmokeAssert(findtext(planet_map_browser_html, "PLANETARY MAP") && findtext(planet_map_browser_html, "function updateMarker") && findtext(planet_map_browser_html, "tilesPerSecond") && findtext(planet_map_browser_html, "peakTickUsage") && findtext(planet_map_browser_html, "Runtime turf changes may appear") && findtext(planet_map_browser_html, ">SCAN</a>") && !findtext(planet_map_browser_html, ">CANCEL</a>"), "planet-map browser lost its scan, live marker, telemetry, cache, or privacy contract")
	var/list/failed_planet_map_browser_state = planet_map_browser_state.Copy()
	failed_planet_map_browser_state["status"] = "failed"
	var/failed_planet_map_browser_html = planet_map_browser_test.buildHtml(failed_planet_map_browser_state, "")
	nexusSmokeAssert(findtext(failed_planet_map_browser_html, ">SCAN</a>"), "a failed planet-map scan cannot be retried from the browser")
	del(planet_map_browser_test)
	runNexusPlanetMapScannerSmokeTests()
	runNexusPlanetaryControlSmokeTests()
	var/bronze_hud_browser_css = getNexusHudBrowserCss("bronze")
	var/blue_hud_browser_css = getNexusHudBrowserCss("blue")
	nexusSmokeAssert(findtext(bronze_hud_browser_css, "body.nexus-hud") && findtext(bronze_hud_browser_css, ".hud-frame:before") && findtext(bronze_hud_browser_css, "#c6a15c") && findtext(bronze_hud_browser_css, "#9a7440"), "player browsers lost the chat/action-button frame, bolt, or bronze edge contract")
	nexusSmokeAssert(findtext(bronze_hud_browser_css, "@font-face") && findtext(bronze_hud_browser_css, "Nexus Silkscreen") && findtext(bronze_hud_browser_css, "SilkscreenRegular.ttf") && findtext(bronze_hud_browser_css, "SilkscreenBold.ttf"), "native HUD browsers lost the embedded pixel-font contract")
	nexusSmokeAssert(findtext(blue_hud_browser_css, "#405a70") && findtext(blue_hud_browser_css, "#72c6eb") && findtext(blue_hud_browser_css, ".hud-button.danger"), "admin browsers lost the Server Panel edge, accent, or close-button contract")
	var/icon/hud_canvas_reference = icon('UserNamesBarsUi.png')
	var/icon/lethal_hud_reference = icon('LethalHud.dmi')
	var/icon/rp_mode_hud_reference = icon('RPModeHud.dmi')
	nexusSmokeAssert(hud_canvas_reference.Width() == 315 && hud_canvas_reference.Height() == 125, "UserNamesBarsUi.png is no longer the expected native HUD drawing canvas")
	nexusSmokeAssert(lethal_hud_reference.Width() == 32 && lethal_hud_reference.Height() == 32 && rp_mode_hud_reference.Width() == 48 && rp_mode_hud_reference.Height() == 32, "LethalHud.dmi or RPModeHud.dmi lost its documented frame dimensions")
	var/obj/NexusHud/ActionButton/Lethal/lethal_button = new
	var/obj/NexusHud/ActionButton/RPMode/rp_mode_button = new
	var/obj/NexusHud/ActionButton/Character/character_button = new
	var/obj/NexusHud/ShortcutButton/Inventory/inventory_button = new
	var/obj/NexusHud/ShortcutButton/Progression/progression_button = new
	var/obj/NexusHud/ShortcutButton/Milestones/milestones_button = new
	var/obj/NexusHud/ShortcutButton/Build/build_button = new
	var/obj/NexusHud/ShortcutButton/Menu/menu_button = new
	var/obj/NexusHud/SplitformButton/splitform_button = new
	nexusSmokeAssert(lethal_button.plane == NEXUS_FIXED_HUD_PLANE, "action HUD is not isolated from map-only zoom")
	nexusSmokeAssert(inventory_button.plane == NEXUS_FIXED_HUD_PLANE && inventory_button.action_id == "inventory", "shortcut HUD is not isolated or addressable")
	nexusSmokeAssert(progression_button.action_id == "progression" && milestones_button.action_id == "milestones" && build_button.action_id == "build", "progression, milestone, or build shortcut is not addressable")
	nexusSmokeAssert(menu_button.action_id == "menu", "Escape-menu shortcut is not addressable")
	nexusSmokeAssert(splitform_button.plane == NEXUS_FIXED_HUD_PLANE, "splitform controls still share the zoomed world atom")
	nexusSmokeAssert(lethal_button.screen_loc == "RIGHT:-8,TOP:-8" && rp_mode_button.screen_loc == "RIGHT:-8,TOP:-32" && character_button.screen_loc == "RIGHT:-8,TOP:-56", "action HUD buttons are not pixel-anchored in the upper-right corner")
	nexusSmokeAssert(!lethal_button.loc && !rp_mode_button.loc && !character_button.loc, "action HUD buttons leaked into an atom's contents")
	del(lethal_button)
	del(rp_mode_button)
	del(character_button)
	del(inventory_button)
	del(progression_button)
	del(milestones_button)
	del(build_button)
	del(menu_button)
	del(splitform_button)
	nexusSmokeAssert(text2path("/mob/Admin3/verb/giveMutation") && text2path("/mob/Admin3/verb/rollMutations"), "admin mutation verbs are missing")
	nexusSmokeAssert(text2path("/mob/Admin3/verb/giveNexusAttacks") && text2path("/mob/Admin3/verb/testNexusCombatEffects"), "Nexus attack or audiovisual testing verb is missing")
	nexusSmokeAssert(getNexusBeamAttackTypes().len == 12 && getNexusSpecialStyleAttackTypes().len == 8, "Nexus special-style catalog is incomplete")
	nexusSmokeAssert(getNexusRockAttackTypes().len == 3, "Nexus rock-technique testing catalog is incomplete")
	var/obj/Attacks/NexusMeleeTechnique/Slice/nexus_slice = new
	var/obj/Attacks/NexusMeleeTechnique/BurningSlash/nexus_combo = new
	var/obj/Attacks/NexusMeleeTechnique/IaiSlash/nexus_iai = new
	var/obj/Attacks/NexusMeleeTechnique/SwordStab/nexus_stab = new
	var/obj/Attacks/NexusMeleeTechnique/MegatonThrow/nexus_throw = new
	var/obj/Attacks/NexusMeleeTechnique/MarchOfFury/nexus_march = new
	var/obj/Attacks/NexusMeleeTechnique/TexasSmash/nexus_texas_smash = new
	var/obj/Attacks/NexusMeleeTechnique/ExplodingHeartStrike/nexus_exploding_heart = new
	var/obj/Attacks/NexusMeleeTechnique/PileDriver/nexus_pile_driver = new
	var/obj/Attacks/NexusMeleeTechnique/UppercutCombo/nexus_uppercut = new
	var/obj/Attacks/NexusMeleeTechnique/KickbackCombo/nexus_kickback = new
	var/obj/Attacks/NexusMeleeTechnique/Headbutt/nexus_headbutt = new
	var/obj/Attacks/NexusMeleeTechnique/AxeKick/nexus_axe_kick = new
	var/obj/Attacks/NexusMeleeTechnique/ConsecutiveNormalPunches/nexus_consecutive_punches = new
	var/obj/Attacks/NexusStance/nexus_guard_break = new /obj/Attacks/NexusMeleeTechnique/GuardBreak
	var/obj/Attacks/NexusMeleeTechnique/WingClip/nexus_wing_clip = new
	var/obj/Attacks/NexusMeleeTechnique/SandThrow/nexus_sand_throw = new
	var/obj/Attacks/NexusMeleeTechnique/BlueCometSpecial/nexus_blue_comet = new
	var/obj/Attacks/NexusMeleeTechnique/BurningShot/nexus_burning_shot = new
	var/obj/Attacks/NexusStance/nexus_critical_edge = new /obj/Attacks/NexusMeleeTechnique/CriticalEdge
	var/obj/Attacks/NexusStance/Block/nexus_block_stance = new
	var/obj/Attacks/NexusMeleeTechnique/WindHowl/nexus_wind_howl = new
	var/obj/Attacks/RoleplayBeam/BusterCannon/nexus_beam = new
	var/obj/Attacks/NexusSpecialStyle/SuperGhostKamikaze/nexus_ghosts = new
	var/obj/Attacks/NexusAreaTechnique/SuperExplosiveWave/nexus_explosive_wave = new
	var/obj/Attacks/NexusAreaTechnique/Earthquake/nexus_earthquake = new
	nexusSmokeAssert(nexus_slice.requires_weapon && nexus_slice.hotbar_type == "Melee", "Nexus weapon technique does not enforce equipment")
	nexusSmokeAssert(nexus_slice.icon == 'src/Icons/Effects/CC0/SwordSlash.dmi' && (nexus_slice.getCastSound() in nexus_sword_swing_light_sounds) && (nexus_slice.getImpactSound() in nexus_sword_impact_sounds), "Nexus weapon techniques are missing their animated hotbar icons or CC0 sword audio")
	nexusSmokeAssert(nexus_combo.extra_hits == 2 && nexus_combo.extra_hit_multiplier == 0.45 && nexus_combo.damage_multiplier == 1.8 && !nexus_combo.getOpeningKnockbackDistance(3), "Burning Slash is not a contact-safe multi-hit technique")
	nexusSmokeAssert(nexus_iai.behavior == "iai_dash" && nexus_iai.dash_range == 6 && nexus_iai.damage_multiplier == 4, "Iai Slash is not a pass-through line attack")
	nexusSmokeAssert(nexus_stab.line_reach == 2 && nexus_stab.knockback_multiplier == 0 && nexus_stab.damage_multiplier == 4.5, "Sword Stab does not pierce the tile behind its target")
	nexusSmokeAssert(nexus_throw.behavior == "grapple_throw" && nexus_march.behavior == "march", "Nexus grapple or advancing melee behavior is missing")
	nexusSmokeAssert(nexus_march.requires_unarmed && nexus_texas_smash.damage_multiplier == 7 && nexus_exploding_heart.damage_multiplier == 4.5 && nexus_exploding_heart.bleed_fraction == 0.15, "peak Unarmed techniques lost their sustained, raw-impact or bleeding damage profiles")
	nexusSmokeAssertNear(nexus_march.getTotalDamageMultiplier(), 7.2, 0.0001, "March of Fury lost its sustained damage profile")
	nexusSmokeAssert(nexus_pile_driver.icon == 'RTGrappleImpact.dmi' && nexus_throw.icon_state == "2", "Nexus grapple techniques are missing their original effect icons")
	nexusSmokeAssert(nexus_uppercut.icon == 'RTUppercut.dmi' && nexus_kickback.icon == 'RTSweepingKick.dmi', "Nexus combo techniques are missing their original effect icons")
	nexusSmokeAssert(nexus_pile_driver.getImpactSound() == 'RockImpactHeavy1.ogg' && (nexus_kickback.getImpactSound() in nexus_shonen_sound_bank["melee"]), "Nexus grapple or kick techniques are missing their adapted impact audio")
	nexusSmokeAssert(nexus_headbutt.effect_icon_state == "explosion_orange" && nexus_axe_kick.effect_icon_state == "blast_orange" && nexus_march.effect_icon_state == "blast_blue" && nexus_consecutive_punches.effect_icon_state == "blast_orange", "core Unarmed strikes are missing their open combat impact animations")
	nexusSmokeAssert(nexus_wing_clip.effect_icon_state == "blast_blue" && nexus_blue_comet.effect_icon_state == "blast_blue" && (nexus_guard_break.getImpactSound() in nexus_shonen_sound_bank["electric"]), "control stances or speed strikes are missing their distinct VFX or electric audio")
	nexusSmokeAssertNear(nexus_uppercut.getTotalDamageMultiplier(), 5.5, 0.0001, "Uppercut Combo damage budget is below its three-hit investment")
	nexusSmokeAssert(!nexus_uppercut.getOpeningKnockbackDistance(4) && nexus_uppercut.getComboFinisherKnockbackDistance() == 2, "Uppercut Combo can still knock its target out of the sequence before the launcher")
	nexusSmokeAssertNear(nexus_burning_shot.getTotalDamageMultiplier(), 5.5, 0.0001, "Burning Shot damage budget is below its multi-hit investment")
	nexusSmokeAssert(nexus_burning_shot.getComboFinisherKnockbackDistance() == 1, "Burning Shot does not defer its native knockback to the final hit")
	nexusSmokeAssertNear(nexus_blue_comet.getTotalDamageMultiplier(), 6.12, 0.0001, "Blue Comet damage budget is below its five-hit investment")
	nexusSmokeAssertNear(nexus_consecutive_punches.getTotalDamageMultiplier(), 6.9, 0.0001, "Consecutive Normal Punches lost its six-hit damage budget")
	nexusSmokeAssert(nexus_consecutive_punches.sequence_hits == 6 && nexus_consecutive_punches.sequence_hit_multiplier == 0.5, "Consecutive Normal Punches lost its six-hit sequence")
	nexusSmokeAssert(nexus_guard_break.requires_unarmed && nexus_wing_clip.requires_unarmed && nexus_sand_throw.requires_unarmed && nexus_critical_edge.requires_weapon && nexus_headbutt.getAccuracyBonus() == nexus_unarmed_technique_accuracy_bonus, "stance and Unarmed equipment requirements diverged from their authored trees")
	nexusSmokeAssert(nexus_beam.hotbar_type == "Beam" && nexus_beam.damage_factor == 24, "Buster Cannon is not routed as a balanced beam")
	nexusSmokeAssert(nexus_wind_howl.behavior == "radial" && nexus_wind_howl.damage_multiplier == 2.5 && nexus_wind_howl.splash_radius == 3 && nexus_wind_howl.splash_target_limit == 12, "Wind Howl is not a targetless three-tile area attack")
	nexusSmokeAssert(nexus_ghosts.ghost_count == 3 && nexus_ghosts.ghost_damage_factor == 6 && nexus_ghosts.locked_homing, "Super Ghost Kamikaze Attack lost its bounded character-copy homing profile")
	runNexusGhostCopySmoke()
	nexusSmokeAssert(istype(nexus_explosive_wave, /obj/Attacks/Shockwave) && istype(nexus_earthquake, /obj/Attacks/Shockwave), "the ported area techniques no longer derive from Shockwave")
	nexusSmokeAssert(nexus_explosive_wave.radius == 4 && nexus_explosive_wave.area_damage_factor == 12 && nexus_explosive_wave.hotbar_type == "Defensive" && nexus_explosive_wave.intercepts_blasts && nexus_explosive_wave.knockback_distance == 4, "Super Explosive Wave lost its defensive blast interception or repulsion profile")
	nexusSmokeAssert(nexus_earthquake.radius == 5 && nexus_earthquake.area_damage_factor == 10 && nexus_earthquake.physical_damage && nexus_earthquake.ground_only && nexus_earthquake.pull_distance == 3 && !nexus_earthquake.knockback_distance, "Earthquake lost its ground-only inward shockwave behavior")
	var/mob/NexusSmokeTest/wave_owner = new
	var/mob/NexusSmokeTest/wave_enemy = new
	wave_owner.loc = locate(445, 3, 2)
	wave_enemy.loc = get_step(wave_owner, EAST)
	var/obj/Blast/hostile_wave_blast = new(wave_enemy.loc)
	hostile_wave_blast.Owner = wave_enemy
	var/obj/Blast/friendly_wave_blast = new(wave_enemy.loc)
	friendly_wave_blast.Owner = wave_owner
	var/obj/Blast/hostile_beam_segment = new(wave_enemy.loc)
	hostile_beam_segment.Owner = wave_enemy
	hostile_beam_segment.Beam = 1
	nexusSmokeAssert(nexus_explosive_wave.interceptAreaBlasts(wave_owner) == 1 && !hostile_wave_blast.z && friendly_wave_blast.z && hostile_beam_segment.z, "Super Explosive Wave did not isolate hostile non-beam projectiles")
	del(friendly_wave_blast)
	del(hostile_beam_segment)
	del(wave_enemy)
	del(wave_owner)
	nexusSmokeAssert(pressure_punch_cooldown_ticks == 90 && pressure_punch_charge_ticks == 10 && pressure_punch_damage_factor == 16 && roundhouse_kick_damage_factor == 13, "legacy charged Unarmed strikes lost their speed or damage budgets")
	var/obj/Attacks/NexusSpecialStyle/WallOfFlame/nexus_flame_wall = new
	var/obj/Attacks/NexusSpecialStyle/ChargedProjectile/DragonNova/nexus_dragon_nova = new
	var/obj/Attacks/NexusSpecialStyle/ChargedProjectile/SkyBreak/nexus_sky_break = new
	var/obj/Attacks/NexusSpecialStyle/ChargedProjectile/EchoingSlash/nexus_echoing_slash = new
	nexusSmokeAssert(nexus_guard_break.hotbar_type == "Buff" && nexus_guard_break.stance_id == "guard_break" && nexus_guard_break.duration_ticks == 100 && nexus_guard_break.stance_charges == 3 && nexus_guard_break.cooldown_ticks == 250, "Guard Break is not a bounded three-hit stance")
	nexusSmokeAssert(nexus_critical_edge.hotbar_type == "Buff" && nexus_critical_edge.stance_id == "critical_edge" && nexus_critical_edge.duration_ticks == 120 && nexus_critical_edge.cooldown_ticks == 300, "Critical Edge is not a weapon-exclusive critical stance")
	nexusSmokeAssert(nexus_block_stance.stance_id == "block" && nexus_block_stance.duration_ticks == 80 && nexus_block_stance.cooldown_ticks == 240, "Block is not a bounded defensive stance")
	nexusSmokeAssert(nexus_wing_clip.behavior == "radial" && nexus_wing_clip.unavoidable && nexus_wing_clip.splash_radius == 2 && nexus_wing_clip.splash_damage_multiplier == 0.75 && nexus_wing_clip.knockback_multiplier == 2, "Wing Clip lost its unavoidable area control profile")
	nexusSmokeAssert(nexus_sand_throw.behavior == "radial" && nexus_sand_throw.unavoidable && !nexus_sand_throw.damage_multiplier && nexus_sand_throw.splash_radius == 2, "Sand Throw is not an unavoidable non-damaging area debuff")
	var/mob/NexusSmokeTest/nexus_stance_contract = new
	var/mob/NexusSmokeTest/nexus_debuff_contract = new
	nexus_stance_contract.setNexusStance("block", 80)
	nexusSmokeAssert(nexus_stance_contract.getNexusBlockIncomingDamageMultiplier() == 0.7 && nexus_stance_contract.getNexusBlockBlastEvasionBonus() == 20 && nexus_stance_contract.getNexusStanceStrengthMultiplier() == 0.8 && nexus_stance_contract.getNexusStanceForceMultiplier() == 0.8 && nexus_stance_contract.getNexusStanceDefenseMultiplier() == 0.8, "Block does not apply its final damage, blast evasion or stat tradeoffs")
	nexus_stance_contract.setNexusStance("guard_break", 100, 3)
	nexusSmokeAssert(nexus_stance_contract.hasNexusStance("guard_break") && !nexus_stance_contract.hasNexusStance("block") && nexus_stance_contract.active_nexus_stance_charges == 3, "Nexus stances are not mutually exclusive or charge bounded")
	nexus_debuff_contract.applyNexusGuardBreakDebuff()
	nexus_debuff_contract.applyNexusGuardBreakDebuff()
	nexus_debuff_contract.applyNexusGuardBreakDebuff()
	nexus_debuff_contract.applyNexusGuardBreakDebuff()
	nexus_debuff_contract.applyNexusWingClipDebuff()
	nexus_debuff_contract.applyNexusSandThrowDebuff()
	nexusSmokeAssert(nexus_debuff_contract.getNexusGuardBreakDefenseMultiplier() == 0.7 && nexus_debuff_contract.getNexusWingClipSpeedMultiplier() == 0.75 && nexus_debuff_contract.getNexusSandThrowStatMultiplier() == 0.8, "stance control debuffs lost their caps or effective stat reductions")
	del(nexus_debuff_contract)
	del(nexus_stance_contract)
	nexusSmokeAssert(nexus_flame_wall.field_duration == 150, "Wall of Flame is not a persistent field style")
	nexusSmokeAssert(nexus_dragon_nova.projectile_damage_factor == 18 && nexus_dragon_nova.icon == 'RTDragonNova.dmi', "Dragon Nova is missing its integrated balance or icon")
	nexusSmokeAssert(nexus_sky_break.strength_scaled && nexus_sky_break.requires_weapon && nexus_sky_break.weapon_projectile && nexus_sky_break.icon == 'RTSkyBreak.dmi', "Sky Break is not a weapon-gated physical sword projectile")
	nexusSmokeAssert(nexus_sky_break.impact_effect_icon == 'src/Icons/Effects/CC0/SwordSlash.dmi' && nexus_echoing_slash.weapon_projectile && nexus_echoing_slash.explosion_size == 0, "ported sword waves still use generic blast presentation")
	nexusSmokeAssert(nexus_echoing_slash.icon == 'RTEchoingSlash.dmi' && nexus_echoing_slash.projectile_damage_factor == 14, "Echoing Slash is missing its integrated projectile art or adapted balance")
	var/obj/ArcaneSpell/Projectile/Fireball/arcane_fireball_vfx = new
	var/obj/ArcaneSpell/Projectile/FrostBolt/arcane_frost_vfx = new
	var/obj/ArcaneSpell/Projectile/LightningBolt/arcane_lightning_vfx = new
	nexusSmokeAssert(arcane_fireball_vfx.icon == 'src/Icons/Effects/OpenCombat/FoozleMagic64.dmi' && arcane_fireball_vfx.icon_state == "fire_ball" && arcane_fireball_vfx.impact_effect_state == "explosion" && arcane_fireball_vfx.damage_percent == 8 && arcane_fireball_vfx.projectile_status_effect == "fire" && arcane_fireball_vfx.projectile_status_duration == 80 && arcane_fireball_vfx.projectile_status_damage_percent == 2, "Fireball is missing its authored magic presentation or fire DoT")
	nexusSmokeAssert(arcane_frost_vfx.icon_state == "water" && arcane_frost_vfx.impact_effect_state == "water_geyser" && arcane_frost_vfx.damage_percent == 8 && arcane_lightning_vfx.icon_state == "wind" && arcane_lightning_vfx.impact_sound_category == "electric" && arcane_lightning_vfx.damage_percent == 10 && arcane_lightning_vfx.projectile_status_effect == "electric" && arcane_lightning_vfx.projectile_status_duration == 60 && arcane_lightning_vfx.projectile_status_damage_percent == 1, "Frost Bolt or Lightning Bolt is missing its elemental magic presentation or electric DoT")
	var/mob/NexusSmokeTest/nexus_status_contract = new
	nexus_status_contract.Race = "Human"
	nexus_status_contract.Health = 100
	nexusSmokeAssert(nexus_status_contract.applyNexusFireDot(null, 80, 2) && nexus_status_contract.getNexusFireRegenerationMultiplier() == 0.3 && (nexus_status_contract in nexus_status_effect_mobs), "fire DoT does not suppress regeneration or register with the shared controller")
	nexus_status_contract.processNexusStatusEffects(nexus_status_contract.nexus_fire_dot_until)
	nexusSmokeAssert(nexus_status_contract.Health == 92, "fire DoT did not deal exactly four maximum-Health ticks over eight seconds")
	nexus_status_contract.clearNexusStatusEffects()
	nexus_status_contract.Health = 100
	nexusSmokeAssert(nexus_status_contract.applyNexusElectricDot(null, 60, 1) && nexus_status_contract.getNexusElectricStatMultiplier() == 0.85, "electric DoT does not suppress Accuracy, Reflex and Speed")
	nexus_status_contract.processNexusStatusEffects(nexus_status_contract.nexus_electric_dot_until)
	nexusSmokeAssert(nexus_status_contract.Health == 97, "electric DoT did not deal exactly three maximum-Health ticks over six seconds")
	nexus_status_contract.clearNexusStatusEffects()
	nexus_status_contract.Health = 100
	nexus_status_contract.stun_level = 0
	nexusSmokeAssert(nexus_status_contract.applyNexusPoisonDot(null, 120, 2), "poison milestone DoT was rejected for a normal target")
	nexus_status_contract.processNexusStatusEffects(nexus_status_contract.nexus_poison_dot_until)
	nexusSmokeAssert(nexus_status_contract.Health == 88, "poison DoT did not deal exactly 12% maximum Health over twelve seconds")
	nexus_status_contract.clearNexusStatusEffects()
	nexusSmokeAssert(!(nexus_status_contract in nexus_status_effect_mobs), "cleared DoTs remain registered in the shared status controller")
	del(nexus_status_contract)
	var/mob/NexusSmokeTest/skill_examine_owner = new
	var/obj/Attacks/NexusMeleeTechnique/Slice/menu_skill_contract = new(skill_examine_owner)
	var/obj/NexusSmokeSkillAction/menu_action_contract = new(skill_examine_owner)
	var/obj/Buff/Preset/MuscleForce/menu_buff_contract = new(skill_examine_owner)
	var/obj/Giant_Form/menu_transformation_contract = new(skill_examine_owner)
	var/obj/Great_Ape/menu_great_ape_contract = new(skill_examine_owner)
	var/obj/items/Gloves/Forged/Science/menu_item_contract = new(skill_examine_owner)
	skill_examine_owner.arcane_essence = 12.5
	if(!islist(skill_examine_owner.item_list)) skill_examine_owner.item_list = list()
	if(!(menu_item_contract in skill_examine_owner.item_list)) skill_examine_owner.item_list += menu_item_contract
	var/datum/NexusPlayerMenu/skill_examine_contract = new(skill_examine_owner, "skills")
	var/rendered_skill_contract = skill_examine_contract.buildSkills()
	var/rendered_inventory_contract = skill_examine_contract.buildInventory()
	nexusSmokeAssert(isNexusTechniqueObject(menu_skill_contract) && !isNexusTechniqueObject(menu_item_contract) && findtext(rendered_skill_contract, "[menu_skill_contract]") && !findtext(rendered_skill_contract, "[menu_item_contract]") && findtext(rendered_inventory_contract, "[menu_item_contract]"), "player Skills does not isolate true Skill objects from inventory items")
	nexusSmokeAssert(findtext(rendered_inventory_contract, "12.5 Arcane Essence"), "player Inventory does not show the authoritative Arcane Essence balance")
	nexusSmokeAssert(findtext(rendered_inventory_contract, "action=drop_item") && findtext(rendered_inventory_contract, ">DROP</a>"), "player Inventory cards omit the explicit drop action")
	nexusSmokeAssert(findtext(rendered_skill_contract, "action=use_skill") && findtext(rendered_skill_contract, "action=examine_skill"), "Skills cards omit their USE or EXAMINE action")
	nexusSmokeAssert(skill_examine_contract.useOwnedSkill(menu_action_contract) && menu_action_contract.use_count == 1, "Skills USE did not route through canonical hotkey execution")
	var/list/menu_buff_effect_contract = skill_examine_contract.getSkillEffectData(menu_buff_contract)
	nexusSmokeAssert(menu_buff_effect_contract["heading"] == "BUFF EFFECT" && findtext(menu_buff_effect_contract["stat_changes"], "Strength +20%") && findtext(menu_buff_effect_contract["stat_changes"], "Endurance +12%"), "skill examination omits concrete custom/preset buff multipliers")
	menu_buff_contract.buff_attributes += "transformation"
	menu_buff_effect_contract = skill_examine_contract.getSkillEffectData(menu_buff_contract)
	var/list/menu_transformation_effect_contract = skill_examine_contract.getSkillEffectData(menu_transformation_contract)
	var/list/menu_great_ape_effect_contract = skill_examine_contract.getSkillEffectData(menu_great_ape_contract)
	nexusSmokeAssert(menu_buff_effect_contract["heading"] == "TRANSFORMATION EFFECT" && findtext(menu_buff_effect_contract["summary"], "primary transformation") && findtext(menu_transformation_effect_contract["summary"], "25%"), "skill examination omits transformation-attribute or form behavior")
	nexusSmokeAssert(findtext(menu_great_ape_effect_contract["stat_changes"], "Battle Power multiplier +2.5") && findtext(menu_great_ape_effect_contract["stat_changes"], "Speed -90%") && findtext(menu_great_ape_effect_contract["attributes"], "tail") && findtext(menu_great_ape_effect_contract["attributes"], "3-minute cooldown") && findtext(menu_great_ape_effect_contract["upkeep"], "automatically seeks"), "Great Ape examination omits its concrete multipliers, activation requirements, cooldown, or uncontrolled behavior")
	skill_examine_owner.BP = 100
	skill_examine_owner.Pow = 120
	skill_examine_owner.Spd = 100
	skill_examine_owner.Class = "Human"
	skill_examine_owner.alignment = "Good"
	skill_examine_owner.milestones_owned = list("weapon_training" = 2, "swordsman" = 1, "ki_manipulation" = 2, "versatile_training" = 1)
	var/obj/items/Sword/menu_damage_weapon = new(skill_examine_owner)
	menu_damage_weapon.Damage = 1.6
	menu_damage_weapon.Style = "Energy"
	menu_damage_weapon.is_silver = TRUE
	menu_damage_weapon.suffix = "Equipped"
	skill_examine_owner.equipped_sword = menu_damage_weapon
	skill_examine_owner.Str = 100 * menu_damage_weapon.Damage
	var/list/menu_damage_contract = skill_examine_contract.getSkillDamageData(menu_skill_contract)
	var/menu_raw_damage_contract = skill_examine_contract.getUnresistedSkillDamage(menu_skill_contract, menu_damage_contract)
	nexusSmokeAssert(menu_damage_contract["preview_profile"] == "nexus_melee" && nexusIsFiniteNumber(menu_raw_damage_contract) && menu_raw_damage_contract > menu_damage_contract["factor"], "skill examination did not calculate a complete Nexus melee damage preview")
	var/mob/NexusSmokeTest/menu_neutral_target = new
	menu_neutral_target.BP = skill_examine_owner.BP
	menu_neutral_target.End = 0
	menu_neutral_target.Res = 0
	menu_neutral_target.Class = "Human"
	menu_neutral_target.alignment = "Good"
	skill_examine_owner.dir = EAST
	menu_neutral_target.dir = NORTH
	var/menu_runtime_melee_damage = skill_examine_owner.get_melee_damage(menu_neutral_target) * menu_damage_contract["factor"]
	nexusSmokeAssertNear(menu_raw_damage_contract, menu_runtime_melee_damage, 0.0001, "Nexus preview diverges from a neutral runtime melee hit")
	nexusSmokeAssertNear(skill_examine_owner.getUnresistedPhysicalCombatDamage(3), skill_examine_owner.getPhysicalCombatDamage(menu_neutral_target, 3), 0.0001, "neutral physical preview diverges from runtime combat damage")
	nexusSmokeAssertNear(skill_examine_owner.getUnresistedKiCombatDamage(3), skill_examine_owner.getKiCombatDamage(menu_neutral_target, 3), 0.0001, "neutral Ki preview diverges from runtime combat damage")
	nexusSmokeAssertNear(skill_examine_owner.getUnresistedHybridCombatDamage(3), skill_examine_owner.getHybridCombatDamage(menu_neutral_target, 3), 0.0001, "neutral hybrid preview diverges from runtime combat damage")
	nexusSmokeAssertNear(skill_examine_owner.getUnresistedWeaponCombatDamage(3), skill_examine_owner.getWeaponCombatDamage(menu_neutral_target, 3), 0.0001, "neutral weapon preview omits runtime sword, style, silver, forged-BP, or milestone modifiers")
	var/original_ki_power = ki_power
	ki_power = 1.25
	var/list/sky_break_preview_data = skill_examine_contract.getSkillDamageData(nexus_sky_break)
	var/sky_break_preview_damage = skill_examine_contract.getUnresistedSkillDamage(nexus_sky_break, sky_break_preview_data)
	var/obj/Blast/sky_break_runtime_projectile = new
	sky_break_runtime_projectile.setStats(skill_examine_owner, Percent = nexus_sky_break.projectile_damage_factor, Off_Mult = 1.2, Explosion = nexus_sky_break.explosion_size, explosion_percent = nexus_sky_break.projectile_damage_factor, max_damage_factor = sky_break_preview_data["factor"])
	sky_break_runtime_projectile.strength_scaled = TRUE
	sky_break_runtime_projectile.weapon_scaled = TRUE
	var/sky_break_direct_factor = sky_break_runtime_projectile.reserveDamageFactor(menu_neutral_target, sky_break_runtime_projectile.percent_damage)
	var/sky_break_explosion_factor = sky_break_runtime_projectile.reserveDamageFactor(menu_neutral_target, sky_break_runtime_projectile.explosion_damage_factor)
	var/sky_break_runtime_damage = sky_break_runtime_projectile.getProjectileCombatDamage(menu_neutral_target, sky_break_direct_factor)
	sky_break_runtime_damage += sky_break_runtime_projectile.getProjectileCombatDamage(menu_neutral_target, sky_break_explosion_factor)
	nexusSmokeAssert(sky_break_preview_data["preview_profile"] == "weapon_projectile", "strength-scaled ChargedProjectile did not select its weapon runtime preview")
	nexusSmokeAssert(sky_break_direct_factor > nexus_sky_break.projectile_damage_factor && sky_break_explosion_factor < nexus_sky_break.projectile_damage_factor && sky_break_direct_factor + sky_break_explosion_factor == sky_break_preview_data["projectile_budget_factor"], "weapon ChargedProjectile smoke did not exercise scaled direct and shared-budget splash reservations")
	nexusSmokeAssertNear(sky_break_preview_damage, sky_break_runtime_damage, 0.0001, "weapon ChargedProjectile preview diverges from its neutral direct-plus-explosion runtime damage")
	del(sky_break_runtime_projectile)
	var/list/dragon_nova_preview_data = skill_examine_contract.getSkillDamageData(nexus_dragon_nova)
	var/dragon_nova_preview_damage = skill_examine_contract.getUnresistedSkillDamage(nexus_dragon_nova, dragon_nova_preview_data)
	var/obj/Blast/dragon_nova_runtime_projectile = new
	dragon_nova_runtime_projectile.setStats(skill_examine_owner, Percent = nexus_dragon_nova.projectile_damage_factor, Off_Mult = 1, Explosion = nexus_dragon_nova.explosion_size, explosion_percent = nexus_dragon_nova.projectile_damage_factor, max_damage_factor = dragon_nova_preview_data["factor"])
	var/dragon_nova_direct_factor = dragon_nova_runtime_projectile.reserveDamageFactor(menu_neutral_target, dragon_nova_runtime_projectile.percent_damage)
	var/dragon_nova_explosion_factor = dragon_nova_runtime_projectile.reserveDamageFactor(menu_neutral_target, dragon_nova_runtime_projectile.explosion_damage_factor)
	var/dragon_nova_runtime_damage = dragon_nova_runtime_projectile.getProjectileCombatDamage(menu_neutral_target, dragon_nova_direct_factor)
	dragon_nova_runtime_damage += dragon_nova_runtime_projectile.getProjectileCombatDamage(menu_neutral_target, dragon_nova_explosion_factor)
	nexusSmokeAssert(dragon_nova_preview_data["preview_profile"] == "ki_projectile" && dragon_nova_direct_factor > nexus_dragon_nova.projectile_damage_factor && dragon_nova_explosion_factor < nexus_dragon_nova.projectile_damage_factor && dragon_nova_direct_factor + dragon_nova_explosion_factor == dragon_nova_preview_data["projectile_budget_factor"], "Ki ChargedProjectile smoke did not exercise scaled direct and shared-budget splash reservations")
	nexusSmokeAssertNear(dragon_nova_preview_damage, dragon_nova_runtime_damage, 0.0001, "Ki ChargedProjectile preview diverges from its neutral direct-plus-explosion runtime damage")
	del(dragon_nova_runtime_projectile)
	var/obj/Attacks/Attack_Barrier/menu_projectile_contract = new(skill_examine_owner)
	var/obj/Attacks/Kikoho/menu_direct_ki_contract = new(skill_examine_owner)
	var/obj/Final_Explosion/menu_raw_ki_contract = new(skill_examine_owner)
	var/list/menu_projectile_damage_data = skill_examine_contract.getSkillDamageData(menu_projectile_contract)
	var/list/menu_direct_ki_damage_data = skill_examine_contract.getSkillDamageData(menu_direct_ki_contract)
	var/list/menu_raw_ki_damage_data = skill_examine_contract.getSkillDamageData(menu_raw_ki_contract)
	var/obj/Blast/menu_runtime_ki_projectile = new
	menu_runtime_ki_projectile.setStats(skill_examine_owner, Percent = menu_projectile_damage_data["projectile_direct_factor"], Off_Mult = 1, Explosion = 0)
	var/menu_runtime_ki_projectile_damage = menu_runtime_ki_projectile.getProjectileCombatDamage(menu_neutral_target, menu_runtime_ki_projectile.percent_damage)
	nexusSmokeAssertNear(skill_examine_contract.getUnresistedSkillDamage(menu_projectile_contract, menu_projectile_damage_data), menu_runtime_ki_projectile_damage, 0.0001, "ordinary projectile preview omits setStats Ki-power or forged-Ki scaling")
	del(menu_runtime_ki_projectile)
	var/obj/Attacks/Blast/menu_basic_blast_contract = new(skill_examine_owner)
	menu_basic_blast_contract.Blast_Count = basic_blast_max_volley_size
	menu_basic_blast_contract.blast_refire = 1
	menu_basic_blast_contract.Explosive = 0
	var/list/menu_basic_blast_damage_data = skill_examine_contract.getSkillDamageData(menu_basic_blast_contract)
	var/menu_basic_blast_per_shot = menu_basic_blast_contract.getBasicBlastDamageFactor()
	var/datum/CombatDamageBudget/menu_basic_blast_budget = new(menu_basic_blast_damage_data["projectile_budget_factor"])
	var/obj/Blast/menu_basic_blast_runtime = new
	menu_basic_blast_runtime.setStats(skill_examine_owner, Percent = menu_basic_blast_per_shot, Off_Mult = 1, Explosion = 0, shared_budget = menu_basic_blast_budget)
	var/menu_basic_blast_runtime_factor = 0
	for(var/basic_blast_index = 1, basic_blast_index <= menu_basic_blast_contract.Blast_Count, basic_blast_index++)
		menu_basic_blast_runtime_factor += menu_basic_blast_runtime.reserveDamageFactor(menu_neutral_target, menu_basic_blast_runtime.percent_damage)
	var/menu_basic_blast_runtime_damage = menu_basic_blast_runtime.getProjectileCombatDamage(menu_neutral_target, menu_basic_blast_runtime_factor)
	nexusSmokeAssertNear(menu_basic_blast_damage_data["projectile_direct_factor"], menu_basic_blast_per_shot * menu_basic_blast_contract.Blast_Count, 0.0001, "basic Blast preview does not aggregate its current volley size and refire factor")
	nexusSmokeAssert(menu_basic_blast_damage_data["factor"] < skill_blast_total_factor && !menu_basic_blast_damage_data["projectile_explosion_factor"], "nonexplosive basic Blast preview incorrectly reports the shared budget ceiling or a splash hit")
	nexusSmokeAssertNear(skill_examine_contract.getUnresistedSkillDamage(menu_basic_blast_contract, menu_basic_blast_damage_data), menu_basic_blast_runtime_damage, 0.0001, "nonexplosive basic Blast preview diverges from its current runtime volley")
	menu_basic_blast_runtime.damage_budget = null
	del(menu_basic_blast_budget)
	del(menu_basic_blast_runtime)
	menu_basic_blast_contract.blast_refire = 0.2
	menu_basic_blast_contract.Explosive = 1
	var/list/menu_explosive_blast_damage_data = skill_examine_contract.getSkillDamageData(menu_basic_blast_contract)
	menu_basic_blast_per_shot = menu_basic_blast_contract.getBasicBlastDamageFactor()
	var/datum/CombatDamageBudget/menu_explosive_blast_budget = new(menu_explosive_blast_damage_data["projectile_budget_factor"])
	var/obj/Blast/menu_explosive_blast_runtime = new
	menu_explosive_blast_runtime.setStats(skill_examine_owner, Percent = menu_basic_blast_per_shot, Off_Mult = 1, Explosion = 1, explosion_percent = menu_basic_blast_per_shot, shared_budget = menu_explosive_blast_budget)
	var/menu_explosive_blast_runtime_factor = 0
	for(var/explosive_blast_index = 1, explosive_blast_index <= menu_basic_blast_contract.Blast_Count, explosive_blast_index++)
		menu_explosive_blast_runtime_factor += menu_explosive_blast_runtime.reserveDamageFactor(menu_neutral_target, menu_explosive_blast_runtime.percent_damage)
	menu_explosive_blast_runtime_factor += menu_explosive_blast_runtime.reserveDamageFactor(menu_neutral_target, menu_explosive_blast_runtime.explosion_damage_factor)
	var/menu_explosive_blast_runtime_damage = menu_explosive_blast_runtime.getProjectileCombatDamage(menu_neutral_target, menu_explosive_blast_runtime_factor)
	nexusSmokeAssertNear(menu_explosive_blast_damage_data["projectile_explosion_factor"], menu_basic_blast_per_shot, 0.0001, "explosive basic Blast preview lost its one center-projectile splash")
	nexusSmokeAssertNear(menu_explosive_blast_runtime_factor, skill_blast_total_factor, 0.0001, "explosive basic Blast runtime reservations escaped the shared budget cap")
	nexusSmokeAssertNear(skill_examine_contract.getUnresistedSkillDamage(menu_basic_blast_contract, menu_explosive_blast_damage_data), menu_explosive_blast_runtime_damage, 0.0001, "explosive basic Blast preview diverges from its current runtime volley")
	menu_explosive_blast_runtime.damage_budget = null
	del(menu_explosive_blast_budget)
	del(menu_explosive_blast_runtime)
	var/list/menu_ghost_damage_data = skill_examine_contract.getSkillDamageData(nexus_ghosts)
	var/datum/CombatDamageBudget/menu_ghost_budget = new(menu_ghost_damage_data["projectile_budget_factor"])
	var/obj/Blast/menu_ghost_runtime = new
	menu_ghost_runtime.setStats(skill_examine_owner, Percent = nexus_ghosts.ghost_damage_factor, Off_Mult = 1.5, Explosion = 1, explosion_percent = 0, shared_budget = menu_ghost_budget)
	var/menu_ghost_runtime_factor = 0
	for(var/ghost_index = 1, ghost_index <= nexus_ghosts.ghost_count, ghost_index++)
		menu_ghost_runtime_factor += menu_ghost_runtime.reserveDamageFactor(menu_neutral_target, menu_ghost_runtime.percent_damage)
	var/menu_ghost_runtime_damage = menu_ghost_runtime.getProjectileCombatDamage(menu_neutral_target, menu_ghost_runtime_factor)
	nexusSmokeAssert(menu_ghost_damage_data["preview_profile"] == "ki_projectile" && menu_ghost_damage_data["factor"] == nexus_ghosts.ghost_count * nexus_ghosts.ghost_damage_factor, "Super Ghost Kamikaze preview does not expose its fixed shared projectile budget")
	nexusSmokeAssertNear(skill_examine_contract.getUnresistedSkillDamage(nexus_ghosts, menu_ghost_damage_data), menu_ghost_runtime_damage, 0.0001, "Super Ghost Kamikaze preview diverges from three neutral runtime hits sharing one budget")
	menu_ghost_runtime.damage_budget = null
	del(menu_ghost_budget)
	del(menu_ghost_runtime)
	nexusSmokeAssertNear(skill_examine_contract.getUnresistedSkillDamage(menu_direct_ki_contract, menu_direct_ki_damage_data), skill_examine_owner.getUnresistedKiCombatDamage(menu_direct_ki_damage_data["factor"]), 0.0001, "direct Ki preview incorrectly inherited projectile setStats scaling")
	ki_power = original_ki_power
	var/menu_raw_ki_damage = skill_examine_contract.getUnresistedSkillDamage(menu_raw_ki_contract, menu_raw_ki_damage_data)
	var/menu_expected_raw_ki_damage = calculateScaledCombatDamage(menu_raw_ki_damage_data["factor"], skill_examine_owner.BP, skill_examine_owner.BP, skill_examine_owner.Pow, 0)
	nexusSmokeAssert(menu_raw_ki_damage_data["preview_profile"] == "raw_ki", "Final Explosion did not select its raw BP/Force preview profile")
	nexusSmokeAssertNear(menu_raw_ki_damage, menu_expected_raw_ki_damage, 0.0001, "Final Explosion preview incorrectly inherited forged or milestone Ki helpers")
	var/mob/NexusSmokeTest/menu_resistant_target = new
	menu_resistant_target.BP = 1000000000
	menu_resistant_target.End = 1000000000
	menu_resistant_target.Res = 1000000000
	skill_examine_owner.Target = menu_resistant_target
	nexusSmokeAssertNear(skill_examine_contract.getUnresistedSkillDamage(menu_skill_contract, menu_damage_contract), menu_raw_damage_contract, 0.0001, "skill examination damage depends on selected-target BP or resistance")
	del(menu_resistant_target)
	del(menu_neutral_target)
	skill_examine_owner.loc = locate(1, 1, 1)
	var/mob/NexusSmokeTest/sense_examine_target = new(skill_examine_owner.loc)
	nexusSmokeAssert(skill_examine_contract.canInspectSenseTarget(sense_examine_target), "Sense EXAMINE rejected a readable character in the same area")
	del(sense_examine_target)
	nexusSmokeAssert(findtext(rendered_skill_contract, "nexus_atom_") && findtext(rendered_inventory_contract, "nexus_atom_") && !findtext(rendered_inventory_contract, "nexus_pixel_"), "Inventory or Skills replaced an in-game object sprite with a generated category pictogram")
	var/live_player_menu_html = skill_examine_contract.buildHtml()
	nexusSmokeAssert(!findtext(live_player_menu_html, "LIVE / 1s") && !findtext(live_player_menu_html, "Live server state") && findtext(live_player_menu_html, "action:'heartbeat'") && findtext(live_player_menu_html, "body class='nexus-hud'") && findtext(live_player_menu_html, "hud-frame") && findtext(live_player_menu_html, "hud-sprite") && findtext(live_player_menu_html, "#c6a15c"), "Inventory, Sense, Skills, and World menu shell exposes refresh internals or lost the native bronze HUD component contract")
	skill_examine_contract.recordHeartbeat(61)
	nexusSmokeAssert(skill_examine_contract.last_scroll_y == 61, "player menu live refresh does not retain browser scroll position")
	nexusSmokeAssert(!skill_examine_contract.hasLiveOwner() && !skill_examine_contract.isBrowserOpen(), "a detached player menu can keep its live refresh lifecycle running")
	var/list/dragon_nova_damage_data = skill_examine_contract.getSkillDamageData(nexus_dragon_nova)
	var/list/iai_damage_data = skill_examine_contract.getSkillDamageData(nexus_iai)
	var/list/echoing_slash_damage_data = skill_examine_contract.getSkillDamageData(nexus_echoing_slash)
	nexusSmokeAssert(dragon_nova_damage_data["factor"] == 36 && dragon_nova_damage_data["model"] == "Ki", "skill examination does not expose Dragon Nova's full direct/splash budget")
	nexusSmokeAssert(iai_damage_data["model"] == "Physical" && findtext(iai_damage_data["requirements"], "Weapon equipped"), "skill examination omits Iai Slash damage model or weapon requirement")
	nexusSmokeAssert(echoing_slash_damage_data["factor"] == 14 && findtext(echoing_slash_damage_data["range"], "direct impact"), "skill examination treats Echoing Slash as an explosive blast")
	del(skill_examine_contract)
	del(skill_examine_owner)
	del(nexus_slice)
	del(nexus_combo)
	del(nexus_iai)
	del(nexus_stab)
	del(nexus_throw)
	del(nexus_march)
	del(nexus_texas_smash)
	del(nexus_exploding_heart)
	del(nexus_pile_driver)
	del(nexus_uppercut)
	del(nexus_kickback)
	del(nexus_burning_shot)
	del(nexus_critical_edge)
	del(nexus_beam)
	del(nexus_guard_break)
	del(nexus_flame_wall)
	del(nexus_dragon_nova)
	del(nexus_sky_break)
	del(nexus_echoing_slash)
	var/turf/attack_movement_origin
	var/turf/attack_movement_destination
	var/turf/attack_movement_pass_through
	for(var/turf/candidate_origin in world)
		var/turf/candidate_destination = get_step(candidate_origin, EAST)
		var/turf/candidate_pass_through = candidate_destination ? get_step(candidate_destination, EAST) : null
		if(!candidate_origin.density && candidate_destination && !candidate_destination.density && candidate_pass_through && !candidate_pass_through.density)
			var/blocked_pair = FALSE
			for(var/atom/movable/blocker in candidate_origin) if(blocker.density) blocked_pair = TRUE
			for(var/atom/movable/blocker in candidate_destination) if(blocker.density) blocked_pair = TRUE
			for(var/atom/movable/blocker in candidate_pass_through) if(blocker.density) blocked_pair = TRUE
			if(!blocked_pair)
				attack_movement_origin = candidate_origin
				attack_movement_destination = candidate_destination
				attack_movement_pass_through = candidate_pass_through
				break
	nexusSmokeAssert(attack_movement_origin && attack_movement_destination && attack_movement_pass_through, "startup map has no open line for attack movement tests")
	var/mob/NexusSmokeTest/dash_movement_test = new
	dash_movement_test.SafeTeleport(attack_movement_origin)
	dash_movement_test.dash_attacking = TRUE
	dash_movement_test.attack_forced_movement = TRUE
	nexusSmokeAssert(step(dash_movement_test, EAST) && dash_movement_test.loc == attack_movement_destination, "Dash Attack cannot move while its attack lock is active")
	del(dash_movement_test)
	var/mob/NexusSmokeTest/ForcedMovementProbe/DashImpact/targeted_dash_user = new
	var/mob/NexusSmokeTest/targeted_dash_target = new
	targeted_dash_user.SafeTeleport(attack_movement_origin)
	targeted_dash_target.SafeTeleport(attack_movement_destination)
	targeted_dash_user.BP = 100
	targeted_dash_user.Str = 100
	targeted_dash_user.Off = 0
	targeted_dash_user.max_ki = 3000
	targeted_dash_user.Ki = 3000
	targeted_dash_user.movement_velocity_x = 4
	targeted_dash_user.movement_acceleration_y = 2
	targeted_dash_user.vector_fraction_x = 0.4
	targeted_dash_user.vector_fraction_y = -0.4
	targeted_dash_user.observe_next_move = TRUE
	targeted_dash_target.BP = 100
	targeted_dash_target.End = 100
	targeted_dash_target.Def = 1000000
	targeted_dash_target.Health = 100
	targeted_dash_target.max_ki = 1000
	targeted_dash_target.Ki = 1000
	targeted_dash_user.setSelectedTarget(targeted_dash_target, FALSE)
	var/obj/Dash_Attack/targeted_dash_skill = new(targeted_dash_user)
	var/targeted_dash_start_x = targeted_dash_user.Px(0)
	var/targeted_dash_expected_damage = targeted_dash_user.getPhysicalCombatDamage(targeted_dash_target, skill_dash_attack_min_factor)
	nexusSmokeAssert(targeted_dash_expected_damage > 0 && !targeted_dash_target.Shielding(), "Dash Attack test setup produced no physical damage or an unexpected shield: damage=[targeted_dash_expected_damage], shielding=[targeted_dash_target.Shielding()]")
	nexusSmokeAssert(skill_engine.castDashAttack(targeted_dash_user, targeted_dash_skill) && targeted_dash_user.last_skill_motion_pixels > world.icon_size && targeted_dash_user.last_skill_motion_pixels <= world.icon_size * 2 + 1 && (targeted_dash_target in targeted_dash_user.last_skill_motion_contacts), "Dash Attack did not accelerate through its selected opponent")
	nexusSmokeAssert(targeted_dash_target.Health < 100, "Dash Attack contact did not damage an opponent that cannot melee-dodge: health=[targeted_dash_target.Health], expected_damage=[targeted_dash_expected_damage], evaded=[targeted_dash_target in targeted_dash_user.last_skill_motion_evaded_contacts]")
	nexusSmokeAssert(targeted_dash_user.observed_forced_move && targeted_dash_user.Px(0) > targeted_dash_start_x + world.icon_size && !targeted_dash_user.movementVelocityMagnitude() && !targeted_dash_user.active_skill_motion, "Dash Attack did not use an isolated vector motion or left movement inertia active")
	del(targeted_dash_skill)
	del(targeted_dash_target)
	del(targeted_dash_user)
	var/mob/NexusSmokeTest/energy_recovery_test = new
	energy_recovery_test.Ki = 50
	energy_recovery_test.max_ki = 100
	energy_recovery_test.BPpcnt = 200
	nexusSmokeAssert(energy_recovery_test.Can_recover_ki(energy_recovery_test.max_ki), "Power Up still blocks passive Energy recovery")
	var/obj/Buff/energy_recovery_buff = new(energy_recovery_test)
	energy_recovery_buff.suffix = "Active"
	energy_recovery_buff.buff_bp = 1.5
	energy_recovery_test.current_buff = energy_recovery_buff
	energy_recovery_test.buff_transform_bp = 100
	nexusSmokeAssert(energy_recovery_test.Can_recover_ki(energy_recovery_test.max_ki), "an active BP buff still blocks passive Energy recovery instead of relying on its drain")
	del(energy_recovery_buff)
	del(energy_recovery_test)
	var/mob/NexusSmokeTest/technique_targeting_test = new
	var/mob/NexusSmokeTest/technique_target = new
	technique_targeting_test.SafeTeleport(attack_movement_origin)
	technique_target.SafeTeleport(attack_movement_destination)
	technique_targeting_test.dir = EAST
	nexusSmokeAssert(technique_targeting_test.getNexusTechniqueTarget(1) == technique_target, "adjacent Nexus combos require manual target selection")
	technique_targeting_test.grabbedObject = technique_target
	technique_target.grabber = technique_targeting_test
	technique_targeting_test.last_melee_attack = -1000
	nexusSmokeAssert(technique_targeting_test.canUseNexusGrappleTechnique(), "a valid grab still blocks Pile Driver and Megaton Throw")
	nexusSmokeAssert(!technique_target.CanMeleeFromOtherCauses() && technique_target.cant_blast(), "a grabbed player can still attack instead of struggling free")
	technique_targeting_test.ReleaseGrab()
	del(technique_targeting_test)
	del(technique_target)
	var/mob/NexusSmokeTest/vector_pickup_test = new(attack_movement_origin)
	var/obj/Resources/vector_resource_test = new(attack_movement_destination)
	vector_resource_test.step_y = 31
	var/list/vector_pickup_targets = vector_pickup_test.getNearbyVectorPickupTargets(world.icon_size)
	nexusSmokeAssert(vector_resource_test in vector_pickup_targets, "vector pickup radius still requires exact tile alignment")
	del(vector_resource_test)
	del(vector_pickup_test)
	var/mob/NexusSmokeTest/movement_physics_test = new
	nexusSmokeAssert((vector_movement_inertia_enabled == 0 || vector_movement_inertia_enabled == 1) && vector_movement_acceleration_per_decisecond > 0 && vector_movement_velocity_retention_per_decisecond >= 0 && vector_movement_velocity_retention_per_decisecond < 1 && vector_movement_stop_velocity > 0 && vector_movement_physics_step_deciseconds > 0 && vector_movement_cardinal_gap_ratio >= 0 && vector_movement_cardinal_gap_ratio < 1, "vector movement inertia tuning is invalid")
	nexusSmokeAssert(skill_motion_default_acceleration > 0 && skill_motion_default_deceleration > 0 && skill_motion_default_max_velocity > 0 && skill_motion_stop_velocity > 0 && skill_motion_stall_frames >= 1, "skill-motion acceleration tuning is invalid")
	var/mob/NexusSmokeTest/skill_acceleration_test = new
	var/datum/NexusSkillMotion/skill_acceleration_motion = new(skill_acceleration_test, null, EAST, 100, 0, 80, 160, 200, 0, 0, FALSE)
	skill_acceleration_test.active_skill_motion = skill_acceleration_motion
	skill_acceleration_motion.updateDesiredVelocity(0.1)
	nexusSmokeAssertNear(skill_acceleration_test.skill_movement_velocity_x, 16, 0.0001, "skill motion did not ramp its first acceleration step")
	nexusSmokeAssertNear(skill_acceleration_test.skill_movement_velocity_y, 0, 0.0001, "cardinal skill acceleration leaked into its perpendicular axis")
	skill_acceleration_motion.updateDesiredVelocity(0.1)
	nexusSmokeAssertNear(skill_acceleration_test.skill_movement_velocity_x, 32, 0.0001, "skill motion did not retain and build velocity")
	skill_acceleration_test.skill_movement_velocity_x = 0
	skill_acceleration_test.skill_movement_velocity_y = 0
	skill_acceleration_motion.movement_direction = NORTHEAST
	skill_acceleration_motion.updateDesiredVelocity(0.1)
	nexusSmokeAssertNear(skill_acceleration_test.skill_movement_velocity_x, 16 / sqrt(2), 0.0001, "diagonal skill acceleration changed its horizontal magnitude")
	nexusSmokeAssertNear(skill_acceleration_test.skill_movement_velocity_y, 16 / sqrt(2), 0.0001, "diagonal skill acceleration changed its vertical magnitude")
	skill_acceleration_test.skill_movement_velocity_x = 0
	skill_acceleration_test.skill_movement_velocity_y = 0
	var/datum/NexusSkillMotion/arbitrary_vector_motion = new(skill_acceleration_test, null, 0, 100, 0, 100, 100, 200, 0, 0, FALSE, FALSE, 3, 4)
	skill_acceleration_test.active_skill_motion = arbitrary_vector_motion
	arbitrary_vector_motion.updateDesiredVelocity(0.1)
	nexusSmokeAssertNear(skill_acceleration_test.skill_movement_velocity_x, 6, 0.0001, "arbitrary-angle skill acceleration snapped its horizontal component to an eight-way direction")
	nexusSmokeAssertNear(skill_acceleration_test.skill_movement_velocity_y, 8, 0.0001, "arbitrary-angle skill acceleration snapped its vertical component to an eight-way direction")
	skill_acceleration_test.skill_motion_generation++
	var/datum/NexusSkillMotion/fresh_skill_motion = new(skill_acceleration_test, null, NORTH, 100, 0, 80, 160, 200, 0, 0, FALSE)
	skill_acceleration_test.active_skill_motion = fresh_skill_motion
	nexusSmokeAssert(!skill_acceleration_test.ownsNexusSkillMotion(skill_acceleration_motion) && skill_acceleration_test.ownsNexusSkillMotion(fresh_skill_motion), "a stale skill motion can still own or clear a newer motion")
	skill_acceleration_test.cancelNexusSkillMotion("smoke")
	del(skill_acceleration_motion)
	del(arbitrary_vector_motion)
	del(fresh_skill_motion)
	del(skill_acceleration_test)
	var/mob/NexusSmokeTest/skill_budget_test = new(attack_movement_origin)
	var/mob/NexusSmokeTest/skill_budget_target = new(attack_movement_pass_through)
	skill_budget_test.setSelectedTarget(skill_budget_target, FALSE)
	var/datum/NexusSkillMotion/tracking_budget_motion = new(skill_budget_test, skill_budget_target, EAST, 10, 0, 80, 160, 200, 0, 0, FALSE, TRUE)
	skill_budget_test.active_skill_motion = tracking_budget_motion
	tracking_budget_motion.moved_pixels = 10
	tracking_budget_motion.budget_pixels = 10
	nexusSmokeAssert(!tracking_budget_motion.goalReached() && tracking_budget_motion.travelBudgetExhausted(), "a tracking skill reports success after only exhausting its travel budget")
	skill_budget_test.cancelNexusSkillMotion("smoke")
	del(tracking_budget_motion)
	del(skill_budget_target)
	del(skill_budget_test)
	var/mob/NexusSmokeTest/skill_metric_subject = new(attack_movement_origin)
	var/mob/NexusSmokeTest/skill_metric_cardinal_target = new(attack_movement_origin)
	var/mob/NexusSmokeTest/skill_metric_diagonal_target = new(attack_movement_origin)
	skill_metric_cardinal_target.step_x = 4 * world.icon_size
	skill_metric_diagonal_target.step_x = 4 * world.icon_size
	skill_metric_diagonal_target.step_y = 4 * world.icon_size
	var/datum/NexusSkillMotion/cardinal_metric_motion = new(skill_metric_subject, skill_metric_cardinal_target, EAST, 4 * world.icon_size, world.icon_size, 80, 160, 200, 0, 0, FALSE)
	var/datum/NexusSkillMotion/diagonal_metric_motion = new(skill_metric_subject, skill_metric_diagonal_target, NORTHEAST, 4 * world.icon_size, world.icon_size, 80, 160, 200, 0, 0, FALSE)
	nexusSmokeAssertNear(cardinal_metric_motion.remainingPixels(), 3 * world.icon_size, 0.0001, "cardinal tracking motion has the wrong physical distance to melee range")
	nexusSmokeAssertNear(diagonal_metric_motion.remainingPixels(), 3 * world.icon_size * sqrt(2), 0.0001, "diagonal tracking motion consumes a shorter tile budget than cardinal travel")
	del(cardinal_metric_motion)
	del(diagonal_metric_motion)
	del(skill_metric_diagonal_target)
	del(skill_metric_cardinal_target)
	del(skill_metric_subject)
	var/mob/NexusSmokeTest/skill_line_test = new(attack_movement_origin)
	var/skill_line_start_x = skill_line_test.Px(0)
	var/datum/NexusSkillMotionResult/skill_line_result = new
	nexusSmokeAssert(skill_line_test.runNexusSkillLine(EAST, 48, 80, 160, 200, 0, 0, FALSE, skill_line_result) && !skill_line_test.active_skill_motion, "a straight skill motion did not finish or release ownership")
	nexusSmokeAssert(skill_line_result.valid && skill_line_result.reached && skill_line_result.generation > 0 && !skill_line_result.contacted_mobs.len, "owned skill motion did not return generation-bound telemetry")
	nexusSmokeAssertNear(skill_line_test.Px(0) - skill_line_start_x, 48, 1, "straight skill motion did not respect its pixel distance")
	nexusSmokeAssertNear(skill_line_test.last_skill_motion_pixels, 48, 1, "skill motion distance telemetry diverged from actual travel")
	nexusSmokeAssert(!skill_line_test.skillMotionVelocityMagnitude() && !skill_line_test.movementVelocityMagnitude(), "finished skill motion leaked velocity into normal movement")
	var/datum/NexusSkillMotion/stop_motion_test = new(skill_line_test, null, EAST, 80, 0, 80, 160, 200, 0, 0, FALSE)
	skill_line_test.active_skill_motion = stop_motion_test
	skill_line_test.skill_movement_velocity_x = 20
	skill_line_test.StopMovement()
	nexusSmokeAssert(!skill_line_test.active_skill_motion && !skill_line_test.skillMotionVelocityMagnitude(), "StopMovement did not cancel an owned skill motion")
	del(stop_motion_test)
	del(skill_line_result)
	del(skill_line_test)
	nexusSmokeAssert(skill_auto_dodge_distance_pixels == world.icon_size && skill_auto_dodge_max_velocity > 0 && skill_auto_dodge_acceleration > 0 && skill_auto_dodge_deceleration > 0, "automatic projectile-dodge vector tuning is invalid")
	var/mob/NexusSmokeTest/automatic_vector_dodge_test = new(attack_movement_origin)
	var/automatic_vector_dodge_start_x = automatic_vector_dodge_test.Px(0)
	nexusSmokeAssert(automatic_vector_dodge_test.tryNexusVectorDodge(EAST), "an unobstructed automatic projectile dodge could not start")
	sleep(TickMult(1))
	nexusSmokeAssertNear(automatic_vector_dodge_test.Px(0) - automatic_vector_dodge_start_x, skill_auto_dodge_distance_pixels, 1, "automatic projectile dodge did not complete its accelerated vector distance")
	nexusSmokeAssert(!automatic_vector_dodge_test.active_skill_motion && !automatic_vector_dodge_test.skillMotionVelocityMagnitude(), "automatic projectile dodge leaked skill-motion ownership or velocity")
	del(automatic_vector_dodge_test)
	nexusSmokeAssert(defensive_dash_distance_pixels == world.icon_size * 7 && defensive_dash_cooldown_deciseconds == 6 && defensive_dash_stamina_cost == 3 && defensive_dash_max_velocity == 360 && defensive_dash_acceleration == 1440 && defensive_dash_deceleration == 2400 && defensive_dash_evasion_window_deciseconds == 1.5 && defensive_dash_velocity_transfer == 0.2 && defensive_dash_afterimage_interval == 0.25, "short-dash distance, timing, cost, or acceleration tuning drifted")
	var/obj/Evade/short_dash_action = new
	nexusSmokeAssert(short_dash_action.can_hotbar && short_dash_action.name == "Short Dash" && !short_dash_action.repeat_macro, "short dash is not exposed as a non-repeating defensive hotbar action")
	del(short_dash_action)
	var/mob/NexusSmokeTest/defensive_dash_test = new(attack_movement_origin)
	var/datum/NexusSkillMotion/defensive_dash_motion = new(defensive_dash_test, null, EAST, defensive_dash_distance_pixels, 0, defensive_dash_max_velocity, defensive_dash_acceleration, defensive_dash_deceleration, 0, 0, FALSE)
	defensive_dash_motion.updateDesiredVelocity(vector_movement_physics_step_deciseconds)
	nexusSmokeAssertNear(defensive_dash_test.skill_movement_velocity_x, 240, 0.001, "short dash does not deliver its intended first-frame acceleration burst")
	defensive_dash_motion.updateDesiredVelocity(vector_movement_physics_step_deciseconds)
	nexusSmokeAssertNear(defensive_dash_test.skill_movement_velocity_x, defensive_dash_max_velocity, 0.001, "short dash does not reach its velocity cap on the second physics step")
	defensive_dash_motion.moved_pixels = defensive_dash_distance_pixels - 20
	defensive_dash_motion.budget_pixels = defensive_dash_distance_pixels - 20
	defensive_dash_test.skill_movement_velocity_x = defensive_dash_max_velocity
	defensive_dash_motion.updateDesiredVelocity(vector_movement_physics_step_deciseconds)
	nexusSmokeAssertNear(defensive_dash_test.skill_movement_velocity_x, sqrt(2 * defensive_dash_deceleration * 20), 0.001, "short dash did not apply its high-rate late braking profile")
	defensive_dash_motion.moved_pixels = 0
	defensive_dash_motion.budget_pixels = 0
	defensive_dash_test.skill_movement_velocity_x = 0
	defensive_dash_test.active_skill_motion = defensive_dash_motion
	defensive_dash_test.defensive_dashing = TRUE
	defensive_dash_test.defensive_dash_evasion_until = world.time + 10
	defensive_dash_motion.moved_pixels = 1
	var/obj/Blast/defensive_dash_projectile = new
	nexusSmokeAssert(defensive_dash_test.isDefensiveDashEvading(defensive_dash_projectile), "an active moving short dash cannot evade an eligible direct blast")
	defensive_dash_projectile.Explosive = 1
	nexusSmokeAssert(!defensive_dash_test.isDefensiveDashEvading(defensive_dash_projectile), "short dash incorrectly evades explosive blasts")
	defensive_dash_projectile.Explosive = 0
	defensive_dash_projectile.Beam = 1
	nexusSmokeAssert(!defensive_dash_test.isDefensiveDashEvading(defensive_dash_projectile), "short dash incorrectly evades beam segments")
	defensive_dash_projectile.Beam = 0
	defensive_dash_projectile.Size = 2
	nexusSmokeAssert(!defensive_dash_test.isDefensiveDashEvading(defensive_dash_projectile), "short dash incorrectly evades large area projectiles")
	defensive_dash_projectile.Size = 0
	defensive_dash_motion.moved_pixels = 0
	nexusSmokeAssert(!defensive_dash_test.isDefensiveDashEvading(defensive_dash_projectile), "a dash blocked before moving still received its evasion window")
	defensive_dash_test.skill_motion_internal_move = defensive_dash_motion
	nexusSmokeAssert(defensive_dash_test.isDefensiveDashEvading(defensive_dash_projectile), "the first requested short-dash displacement has no direct-hit evasion")
	defensive_dash_test.skill_motion_internal_move = null
	defensive_dash_motion.moved_pixels = 1
	var/mob/NexusSmokeTest/skill_contact_recorder = new
	skill_contact_recorder.SafeTeleport(defensive_dash_test.loc)
	skill_contact_recorder.step_x = defensive_dash_test.step_x
	skill_contact_recorder.step_y = defensive_dash_test.step_y
	var/datum/NexusSkillMotion/skill_contact_motion = new(skill_contact_recorder, null, EAST, world.icon_size, 0, 80, 160, 200, 0, 0, TRUE)
	skill_contact_recorder.active_skill_motion = skill_contact_motion
	nexusSmokeAssert(skill_contact_motion.pass_mobs && defensive_dash_test.loc == skill_contact_recorder.loc && bounds_dist(skill_contact_recorder, defensive_dash_test) <= 0, "short-dash contact snapshot test actors do not physically overlap")
	nexusSmokeAssert(defensive_dash_test.isDefensiveDashEvading(), "short-dash contact snapshot expired before contact collection")
	skill_contact_motion.collectContacts()
	nexusSmokeAssert(defensive_dash_test in skill_contact_motion.contacted_mobs, "skill motion did not record an overlapping pass-through contact")
	nexusSmokeAssert(defensive_dash_test in skill_contact_motion.evaded_contacts, "skill motion did not snapshot short-dash evasion at contact time")
	defensive_dash_test.defensive_dashing = FALSE
	nexusSmokeAssert(defensive_dash_test in skill_contact_motion.evaded_contacts, "recorded skill contact changed retroactively after the dash ended")
	defensive_dash_test.defensive_dashing = TRUE
	skill_contact_recorder.cancelNexusSkillMotion("smoke")
	del(skill_contact_motion)
	del(skill_contact_recorder)
	var/mob/NexusSmokeTest/defensive_dash_attacker = new(attack_movement_destination)
	var/obj/Attacks/NexusMeleeTechnique/IaiSlash/defensive_dash_technique = new
	nexusSmokeAssert(!defensive_dash_attacker.resolveNexusTechniqueHit(defensive_dash_test, defensive_dash_technique), "short dash did not evade a direct Nexus melee technique")
	nexusSmokeAssert(defensive_dash_attacker.resolveNexusTechniqueHit(defensive_dash_test, defensive_dash_technique, force_hit = TRUE), "short dash incorrectly evaded a forced area/grapple technique")
	del(defensive_dash_technique)
	del(defensive_dash_attacker)
	defensive_dash_test.cancelNexusSkillMotion("smoke")
	defensive_dash_test.defensive_dashing = FALSE
	del(defensive_dash_projectile)
	del(defensive_dash_motion)
	del(defensive_dash_test)
	movement_physics_test.east = 1
	movement_physics_test.west = 1
	nexusSmokeAssert(!movement_physics_test.move_dir(), "opposing horizontal movement inputs do not cancel")
	movement_physics_test.north = 1
	nexusSmokeAssert(movement_physics_test.move_dir() == NORTH, "a cancelled horizontal axis overrides valid vertical movement input")
	movement_physics_test.south = 1
	nexusSmokeAssert(!movement_physics_test.move_dir(), "opposing movement inputs do not cancel on both axes")
	movement_physics_test.north = 0
	movement_physics_test.south = 0
	movement_physics_test.east = 0
	movement_physics_test.west = 0
	movement_physics_test.accelerateMovementVelocity(1, 0, 2, 10)
	nexusSmokeAssertNear(movement_physics_test.movement_velocity_x, 2, 0.0001, "movement acceleration was not added before the first displacement")
	movement_physics_test.retainMovementVelocity(0.5, 0.001)
	nexusSmokeAssertNear(movement_physics_test.movement_velocity_x, 1, 0.0001, "movement friction was not applied after the first displacement")
	movement_physics_test.accelerateMovementVelocity(1, 0, 2, 10)
	nexusSmokeAssertNear(movement_physics_test.movement_velocity_x, 3, 0.0001, "held movement input does not build retained velocity")
	movement_physics_test.retainMovementVelocity(0.5, 0.001)
	nexusSmokeAssertNear(movement_physics_test.movement_velocity_x, 1.5, 0.0001, "held movement velocity retention is invalid")
	movement_physics_test.resetMovementPhysics()
	movement_physics_test.movement_velocity_x = 3
	movement_physics_test.accelerateMovementVelocity(0, 1, 2, 10)
	nexusSmokeAssertNear(movement_physics_test.movement_velocity_x, 3, 0.0001, "a ninety-degree turn discarded prior horizontal velocity")
	nexusSmokeAssertNear(movement_physics_test.movement_velocity_y, 2, 0.0001, "a ninety-degree turn did not add vertical acceleration")
	movement_physics_test.retainMovementVelocity(0.5, 0.001)
	nexusSmokeAssertNear(movement_physics_test.movement_velocity_x, 1.5, 0.0001, "turn friction discarded horizontal carry")
	nexusSmokeAssertNear(movement_physics_test.movement_velocity_y, 1, 0.0001, "turn friction discarded vertical carry")
	movement_physics_test.resetMovementPhysics()
	movement_physics_test.movement_velocity_x = 3
	movement_physics_test.accelerateMovementVelocity(-1, 0, 2, 10)
	nexusSmokeAssertNear(movement_physics_test.movement_velocity_x, 1, 0.0001, "reversal input replaced rather than opposed prior velocity")
	movement_physics_test.retainMovementVelocity(0.5, 0.001)
	movement_physics_test.accelerateMovementVelocity(-1, 0, 2, 10)
	nexusSmokeAssertNear(movement_physics_test.movement_velocity_x, -1.5, 0.0001, "reversal input did not cancel retained velocity before crossing into the new direction")
	movement_physics_test.resetMovementPhysics()
	movement_physics_test.accelerateMovementVelocity(1, 1, 2, 10)
	nexusSmokeAssertNear(movement_physics_test.movement_velocity_x, sqrt(2), 0.0001, "diagonal acceleration changed its horizontal direction or magnitude")
	nexusSmokeAssertNear(movement_physics_test.movement_velocity_y, sqrt(2), 0.0001, "diagonal acceleration changed its vertical direction or magnitude")
	movement_physics_test.movement_velocity_x = 4
	movement_physics_test.movement_velocity_y = 4
	movement_physics_test.clampMovementVelocity(5)
	nexusSmokeAssertNear(movement_physics_test.movement_velocity_x, 5 / sqrt(2), 0.0001, "movement velocity clamp changed its horizontal direction")
	nexusSmokeAssertNear(movement_physics_test.movement_velocity_y, 5 / sqrt(2), 0.0001, "movement velocity clamp changed its vertical direction")
	movement_physics_test.movement_velocity_x = 4
	movement_physics_test.movement_velocity_y = 0
	movement_physics_test.accelerateMovementVelocity(1, 0, 2, 5)
	nexusSmokeAssertNear(movement_physics_test.movement_velocity_x, 5, 0.0001, "movement acceleration exceeded the vector speed cap")
	movement_physics_test.movement_velocity_x = 3
	movement_physics_test.movement_velocity_y = 4
	movement_physics_test.last_vector_move_attempted = TRUE
	movement_physics_test.last_vector_move_requested_x = 3
	movement_physics_test.last_vector_move_requested_y = 4
	movement_physics_test.last_vector_move_actual_x = 0
	movement_physics_test.last_vector_move_actual_y = 4
	movement_physics_test.resolveMovementVelocityCollision()
	nexusSmokeAssert(!movement_physics_test.movement_velocity_x && movement_physics_test.movement_velocity_y == 4, "wall collision did not remove only the blocked velocity component")
	movement_physics_test.movement_velocity_x = 3
	movement_physics_test.movement_velocity_y = 4
	movement_physics_test.last_vector_move_attempted = TRUE
	movement_physics_test.last_vector_move_requested_x = 3
	movement_physics_test.last_vector_move_requested_y = 4
	movement_physics_test.vector_fraction_x = 0.4
	movement_physics_test.last_vector_move_actual_x = 1
	movement_physics_test.last_vector_move_actual_y = 4
	movement_physics_test.resolveMovementVelocityCollision()
	nexusSmokeAssert(!movement_physics_test.movement_velocity_x && !movement_physics_test.vector_fraction_x && movement_physics_test.movement_velocity_y == 4, "partial wall contact retained blocked-axis velocity or fractional carry")
	movement_physics_test.movement_velocity_x = 3
	movement_physics_test.movement_velocity_y = 4
	movement_physics_test.last_vector_move_attempted = FALSE
	movement_physics_test.last_vector_move_requested_x = 0
	movement_physics_test.last_vector_move_requested_y = 0
	movement_physics_test.last_vector_move_actual_x = 0
	movement_physics_test.last_vector_move_actual_y = 0
	movement_physics_test.resolveMovementVelocityCollision()
	nexusSmokeAssert(movement_physics_test.movement_velocity_x == 3 && movement_physics_test.movement_velocity_y == 4, "fractional-only movement was misread as a collision")
	nexusSmokeAssertNear(movement_physics_test.movementDurationRetention(0.25, 0.5), 0.5, 0.0001, "movement retention is not exponential over decisecond durations")
	nexusSmokeAssertNear(movement_physics_test.movementDurationRetention(0.25, 0.5) ** 2, movement_physics_test.movementDurationRetention(0.25, 1), 0.0001, "movement retention changes with frame subdivision")
	movement_physics_test.movement_velocity_x = 0.001
	movement_physics_test.movement_velocity_y = 0
	movement_physics_test.movement_acceleration_x = 1
	movement_physics_test.vector_fraction_x = 0.4
	movement_physics_test.nexus_gap_nudge_direction = NORTH
	movement_physics_test.nexus_gap_nudge_input_direction = EAST
	movement_physics_test.nexus_gap_nudge_target_offset = 3
	movement_physics_test.glide_size = 4
	movement_physics_test.applyMovementFrameFriction()
	nexusSmokeAssert(!movement_physics_test.movement_velocity_x && !movement_physics_test.movement_acceleration_x && !movement_physics_test.vector_fraction_x && !movement_physics_test.nexus_gap_nudge_direction && !movement_physics_test.nexus_gap_nudge_input_direction && !movement_physics_test.nexus_gap_nudge_target_offset && !movement_physics_test.glide_size, "movement friction did not settle and clear subpixel inertial state")
	movement_physics_test.movement_acceleration_x = 1
	movement_physics_test.movement_acceleration_y = 2
	movement_physics_test.movement_velocity_x = 3
	movement_physics_test.movement_velocity_y = 4
	movement_physics_test.movement_last_frame_pixels = 5
	movement_physics_test.movement_physics_time_accumulator = 0.12
	movement_physics_test.vector_fraction_x = 0.49
	movement_physics_test.vector_fraction_y = -0.49
	movement_physics_test.nexus_gap_nudge_direction = NORTH
	movement_physics_test.nexus_gap_nudge_input_direction = EAST
	movement_physics_test.nexus_gap_nudge_target_offset = 3
	movement_physics_test.glide_size = 6
	movement_physics_test.step_x = 5
	movement_physics_test.step_y = 7
	movement_physics_test.resetMovementPhysics()
	nexusSmokeAssert(!movement_physics_test.movement_acceleration_x && !movement_physics_test.movement_acceleration_y && !movement_physics_test.movement_velocity_x && !movement_physics_test.movement_velocity_y && !movement_physics_test.movement_last_frame_pixels && !movement_physics_test.movement_physics_time_accumulator && !movement_physics_test.vector_fraction_x && !movement_physics_test.vector_fraction_y && !movement_physics_test.nexus_gap_nudge_direction && !movement_physics_test.nexus_gap_nudge_input_direction && !movement_physics_test.nexus_gap_nudge_target_offset && !movement_physics_test.glide_size, "movement physics reset left inertial state behind")
	nexusSmokeAssert(movement_physics_test.step_x == 5 && movement_physics_test.step_y == 7, "movement physics reset changed pixel position")
	movement_physics_test.north = 1
	movement_physics_test.keys_down = list("north")
	movement_physics_test.move_looping = 1
	movement_physics_test.movement_velocity_y = 3
	movement_physics_test.vector_fraction_y = 0.4
	var/stop_movement_generation = movement_physics_test.movement_loop_generation
	movement_physics_test.StopMovement()
	nexusSmokeAssert(!movement_physics_test.north && !movement_physics_test.keys_down.len && !movement_physics_test.move_looping && movement_physics_test.movement_loop_generation > stop_movement_generation && !movement_physics_test.movement_velocity_y && !movement_physics_test.vector_fraction_y, "StopMovement did not invalidate the old loop and perform a hard inertial reset")
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(), "headless movement physics did not reject a mob without a client")
	var/turf/vector_gap_origin
	var/turf/vector_gap_west
	var/turf/vector_gap_east
	var/turf/vector_gap_second_east
	var/turf/vector_gap_north
	var/turf/vector_gap_northwest
	var/turf/vector_gap_northeast
	var/turf/vector_gap_second_northeast
	for(var/turf/candidate_gap_origin in world)
		var/turf/candidate_gap_west = get_step(candidate_gap_origin, WEST)
		var/turf/candidate_gap_east = get_step(candidate_gap_origin, EAST)
		var/turf/candidate_gap_second_east = candidate_gap_east ? get_step(candidate_gap_east, EAST) : null
		var/turf/candidate_gap_north = get_step(candidate_gap_origin, NORTH)
		var/turf/candidate_gap_northwest = candidate_gap_west ? get_step(candidate_gap_west, NORTH) : null
		var/turf/candidate_gap_northeast = candidate_gap_east ? get_step(candidate_gap_east, NORTH) : null
		var/turf/candidate_gap_second_northeast = candidate_gap_second_east ? get_step(candidate_gap_second_east, NORTH) : null
		var/list/candidate_gap_turfs = list(candidate_gap_origin, candidate_gap_west, candidate_gap_east, candidate_gap_second_east, candidate_gap_north, candidate_gap_northwest, candidate_gap_northeast, candidate_gap_second_northeast)
		var/gap_region_blocked = FALSE
		for(var/turf/candidate_gap_turf in candidate_gap_turfs)
			if(!candidate_gap_turf || candidate_gap_turf.density)
				gap_region_blocked = TRUE
				break
			for(var/atom/movable/gap_region_obstacle in candidate_gap_turf)
				if(gap_region_obstacle.density)
					gap_region_blocked = TRUE
					break
			if(gap_region_blocked) break
		if(!gap_region_blocked)
			vector_gap_origin = candidate_gap_origin
			vector_gap_west = candidate_gap_west
			vector_gap_east = candidate_gap_east
			vector_gap_second_east = candidate_gap_second_east
			vector_gap_north = candidate_gap_north
			vector_gap_northwest = candidate_gap_northwest
			vector_gap_northeast = candidate_gap_northeast
			vector_gap_second_northeast = candidate_gap_second_northeast
			break
	nexusSmokeAssert(vector_gap_origin && vector_gap_west && vector_gap_east && vector_gap_second_east && vector_gap_north && vector_gap_northwest && vector_gap_northeast && vector_gap_second_northeast, "startup map has no open region for vector collision tests")
	var/mob/NexusSmokeTest/ForcedMovementProbe/knockback_movement_test = new(vector_gap_origin)
	var/mob/NexusSmokeTest/knockback_movement_source = new(vector_gap_west)
	knockback_movement_test.max_ki = 1000000
	knockback_movement_test.Ki = 1000000
	knockback_movement_test.Flying = TRUE
	knockback_movement_test.movement_velocity_x = 4
	knockback_movement_test.movement_acceleration_y = 2
	knockback_movement_test.vector_fraction_x = 0.4
	knockback_movement_test.vector_fraction_y = -0.4
	knockback_movement_test.observe_next_move = TRUE
	knockback_movement_test.Knockback(knockback_movement_source, Distance = 1, dirt_trail = FALSE, override_dir = EAST, bypass_immunity = TRUE)
	nexusSmokeAssert(knockback_movement_test.observed_forced_move && !knockback_movement_test.forced_move_had_inertia, "knockback carried normal movement inertia into its first forced displacement")
	del(knockback_movement_source)
	del(knockback_movement_test)
	movement_physics_test.SafeTeleport(vector_gap_origin)
	movement_physics_test.move = 1
	movement_physics_test.input_disabled = 0
	movement_physics_test.KO = 0
	movement_physics_test.KB = 0
	movement_physics_test.lunge_attacking = 0
	movement_physics_test.evading = 0
	movement_physics_test.dash_attacking = 0
	movement_physics_test.attack_forced_movement = 0
	movement_physics_test.in_dragon_rush = 0
	movement_physics_test.dragon_rush_attack_active = null
	movement_physics_test.strangling = 0
	movement_physics_test.cant_move_due_to_hakai = 0
	movement_physics_test.shockwaving = 0
	movement_physics_test.Giving_Power = 0
	movement_physics_test.moving_charge = 0
	movement_physics_test.blocking = 0
	movement_physics_test.power_attacking = 0
	movement_physics_test.Regeneration_Skill = 0
	movement_physics_test.Shadow_Sparring = 0
	movement_physics_test.last_hit_by_beam = -999
	movement_physics_test.beam_struggling = -999
	nexusSmokeAssert(!movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "normal headless movement state is incorrectly suspended")
	movement_physics_test.KO = 1
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "knockout does not suspend normal movement physics")
	movement_physics_test.KO = 0
	movement_physics_test.KB = 1
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "knockback does not suspend normal movement physics")
	movement_physics_test.KB = 0
	movement_physics_test.lunge_attacking = 1
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "lunge movement does not suspend normal movement physics")
	movement_physics_test.lunge_attacking = 0
	movement_physics_test.evading = 1
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "evasion movement does not suspend normal movement physics")
	movement_physics_test.evading = 0
	movement_physics_test.dash_attacking = 1
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "dash movement does not suspend normal movement physics")
	movement_physics_test.dash_attacking = 0
	movement_physics_test.attack_forced_movement = 1
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "attack-forced movement does not suspend normal movement physics")
	movement_physics_test.attack_forced_movement = 0
	movement_physics_test.in_dragon_rush = 1
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "Dragon Rush does not suspend normal movement physics")
	movement_physics_test.in_dragon_rush = 0
	movement_physics_test.dragon_rush_attack_active = "Wolf Fang Fist"
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "Wolf Fang Fist forced steps do not suspend normal movement physics")
	movement_physics_test.dragon_rush_attack_active = null
	var/obj/Ships/movement_physics_ship = new
	movement_physics_test.Ship = movement_physics_ship
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "ship control does not suspend character movement physics")
	movement_physics_test.Ship = null
	del(movement_physics_ship)
	var/obj/Drivable_Car/movement_physics_car = new
	movement_physics_test.car = movement_physics_car
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "car control does not suspend character movement physics")
	movement_physics_test.car = null
	del(movement_physics_car)
	var/mob/NexusSmokeTest/movement_physics_grabber = new
	movement_physics_test.grabber = movement_physics_grabber
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "being grabbed does not suspend retained movement")
	movement_physics_test.grabber = null
	del(movement_physics_grabber)
	var/obj/Great_Ape/movement_physics_ape = new
	movement_physics_ape.suffix = "active"
	movement_physics_test.Great_Ape_obj = movement_physics_ape
	movement_physics_test.Great_Ape_control = 0
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "an uncontrolled Great Ape does not suspend normal movement physics")
	movement_physics_test.Great_Ape_obj = null
	del(movement_physics_ape)
	movement_physics_test.beam_struggling = world.time
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "beam struggling does not suspend retained movement")
	movement_physics_test.beam_struggling = -999
	movement_physics_test.last_hit_by_beam = world.time
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "beam stun does not suspend retained movement")
	movement_physics_test.last_hit_by_beam = -999
	movement_physics_test.last_bank_bump = max(1, world.time)
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "the bank interaction cooldown does not suspend retained movement")
	movement_physics_test.last_bank_bump = 0
	movement_physics_test.active_prompts += "bank"
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "an open bank prompt does not suspend retained movement")
	movement_physics_test.active_prompts -= "bank"
	movement_physics_test.move = 0
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "the standard movement lock does not suspend normal movement physics")
	movement_physics_test.move = 1
	movement_physics_test.input_disabled = 1
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "input locking does not suspend normal movement physics")
	movement_physics_test.input_disabled = 0
	movement_physics_test.strangling = 1
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "strangling does not suspend retained movement")
	movement_physics_test.strangling = 0
	movement_physics_test.cant_move_due_to_hakai = 1
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "Hakai immobilization does not suspend retained movement")
	movement_physics_test.cant_move_due_to_hakai = 0
	movement_physics_test.shockwaving = 1
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "shockwave casting does not suspend retained movement")
	movement_physics_test.shockwaving = 0
	movement_physics_test.Giving_Power = 1
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "power transfer does not suspend retained movement")
	movement_physics_test.Giving_Power = 0
	movement_physics_test.moving_charge = 1
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "moving charge does not suspend retained movement")
	movement_physics_test.dir = NORTH
	movement_physics_test.handleMovementPhysicsLockedInput(EAST)
	nexusSmokeAssert(movement_physics_test.dir == EAST && movement_physics_test.moving_charge == 1, "movement input did not turn an active moving charge before advancing it")
	movement_physics_test.handleMovementPhysicsLockedInput(EAST)
	nexusSmokeAssert(movement_physics_test.moving_charge == 2, "repeated movement input did not advance an aligned moving charge")
	nexusSmokeAssert(!movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "an aligned moving charge did not restore its legacy movement window")
	movement_physics_test.moving_charge = 0
	movement_physics_test.blocking = 1
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "blocking does not suspend retained movement")
	movement_physics_test.dir = NORTH
	movement_physics_test.handleMovementPhysicsLockedInput(WEST)
	nexusSmokeAssert(movement_physics_test.dir == WEST, "blocked movement input no longer updates defensive facing")
	movement_physics_test.blocking = 0
	movement_physics_test.power_attacking = 1
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "power attack charging does not suspend retained movement")
	movement_physics_test.power_attacking = 0
	movement_physics_test.Regeneration_Skill = 1
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "active regeneration does not suspend retained movement")
	movement_physics_test.Regeneration_Skill = 0
	movement_physics_test.Shadow_Sparring = 1
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "Shadow Sparring does not suspend retained movement")
	movement_physics_test.Shadow_Sparring = 0
	var/obj/movement_physics_container = new(vector_gap_origin)
	movement_physics_test.loc = movement_physics_container
	nexusSmokeAssert(movement_physics_test.movementPhysicsSuspended(ignore_client = TRUE), "non-turf containment does not suspend normal movement physics")
	movement_physics_test.SafeTeleport(vector_gap_origin)
	del(movement_physics_container)
	nexusSmokeAssertNear(movement_physics_test.getMovementMaximumVelocity(NORTH), movement_physics_test.getMovementMaximumVelocity(NORTHEAST), 0.0001, "normalized diagonal movement has a lower maximum velocity than cardinal movement")
	var/normal_movement_velocity = movement_physics_test.getMovementMaximumVelocity(NORTH)
	movement_physics_test.movement_velocity_x = normal_movement_velocity
	movement_physics_test.movement_velocity_y = 0
	movement_physics_test.setWalkingMode(TRUE, FALSE)
	nexusSmokeAssertNear(movement_physics_test.getMovementMaximumVelocity(NORTH), vector_walk_speed_pixels_per_second, 0.0001, "Walk mode does not apply its precise movement-speed cap")
	nexusSmokeAssert(movement_physics_test.movementVelocityMagnitude() <= vector_walk_speed_pixels_per_second && vector_walk_speed_pixels_per_second < normal_movement_velocity, "enabling Walk mode did not immediately clamp existing movement momentum")
	movement_physics_test.setWalkingMode(FALSE, FALSE)
	nexusSmokeAssertNear(movement_physics_test.getMovementMaximumVelocity(NORTH), normal_movement_velocity, 0.0001, "disabling Walk mode did not restore normal movement speed")
	nexusSmokeAssert(movement_physics_test.getMovementGapDirection(7, 0.1) == EAST && movement_physics_test.getMovementGapDirection(7, 7) == NORTHEAST, "inertial gap probing does not distinguish near-cardinal carry from deliberate diagonal travel")
	var/mob/NexusSmokeTest/MovementAccumulator/movement_accumulator_test = new(vector_gap_origin)
	var/queued_physics_remainder = vector_movement_physics_step_deciseconds * 0.5
	movement_accumulator_test.movement_physics_time_accumulator = vector_movement_physics_step_deciseconds * 3 + queued_physics_remainder - max(0, world.tick_lag)
	movement_accumulator_test.processMovementPhysicsFrame(EAST)
	nexusSmokeAssert(movement_accumulator_test.physics_step_count == 3, "the fixed movement accumulator did not process every queued physics substep")
	nexusSmokeAssertNear(movement_accumulator_test.physics_duration_total, vector_movement_physics_step_deciseconds * 3, 0.0001, "fixed movement substeps used inconsistent durations")
	nexusSmokeAssertNear(movement_accumulator_test.movement_physics_time_accumulator, queued_physics_remainder, 0.0001, "the fixed movement accumulator discarded its fractional remainder")
	del(movement_accumulator_test)
	movement_physics_test.movement_velocity_x = 4
	movement_physics_test.movement_acceleration_x = 2
	movement_physics_test.vector_fraction_x = 0.4
	movement_physics_test.step_x = 5
	movement_physics_test.step_y = -3
	var/datum/NexusSkillMotion/teleport_motion_test = new(movement_physics_test, null, EAST, 80, 0, 80, 160, 200, 0, 0, FALSE)
	movement_physics_test.active_skill_motion = teleport_motion_test
	movement_physics_test.skill_movement_velocity_x = 20
	var/teleport_generation = movement_physics_test.movement_teleport_generation
	movement_physics_test.SafeTeleport(vector_gap_north)
	nexusSmokeAssert(movement_physics_test.loc == vector_gap_north && movement_physics_test.movement_teleport_generation > teleport_generation && !movement_physics_test.movement_velocity_x && !movement_physics_test.movement_acceleration_x && !movement_physics_test.vector_fraction_x && !movement_physics_test.active_skill_motion && !movement_physics_test.skillMotionVelocityMagnitude(), "SafeTeleport carried normal or skill movement inertia into its destination")
	nexusSmokeAssert(movement_physics_test.step_x == 5 && movement_physics_test.step_y == -3, "SafeTeleport reset the destination pixel offsets")
	del(teleport_motion_test)
	movement_physics_test.movement_velocity_y = 4
	movement_physics_test.vector_fraction_y = 0.4
	movement_physics_test.AlterInputDisabled(1)
	nexusSmokeAssert(!movement_physics_test.movement_velocity_y && !movement_physics_test.vector_fraction_y, "input locking did not clear normal movement inertia")
	movement_physics_test.AlterInputDisabled(-1)
	movement_physics_test.loc = null
	del(movement_physics_test)
	var/mob/NexusSmokeTest/InertialMovement/inertial_frame_test = new(vector_gap_origin)
	inertial_frame_test.east = 1
	var/inertial_frame_start_x = inertial_frame_test.Px(0)
	var/inertial_frame_acceleration = min(30, 30 * vector_movement_acceleration_per_decisecond * vector_movement_physics_step_deciseconds)
	var/inertial_frame_requested_x = inertial_frame_acceleration * vector_movement_physics_step_deciseconds
	var/inertial_frame_retention = inertial_frame_test.movementDurationRetention(vector_movement_velocity_retention_per_decisecond, vector_movement_physics_step_deciseconds)
	nexusSmokeAssert(inertial_frame_acceleration > vector_movement_stop_velocity, "movement inertia tuning cannot produce a testable first frame")
	inertial_frame_test.movement_physics_time_accumulator = vector_movement_physics_step_deciseconds - world.tick_lag
	inertial_frame_test.processMovementPhysicsFrame(EAST)
	nexusSmokeAssert(inertial_frame_test.Px(0) - inertial_frame_start_x == round(inertial_frame_requested_x), "the production movement frame did not displace using pre-friction velocity")
	nexusSmokeAssertNear(inertial_frame_test.movement_velocity_x, inertial_frame_acceleration * inertial_frame_retention, 0.0001, "the production movement frame did not retain velocity after displacement")
	nexusSmokeAssert(inertial_frame_test.movement_last_frame_pixels == abs(inertial_frame_test.Px(0) - inertial_frame_start_x), "the production movement frame did not report actual displacement")
	inertial_frame_test.east = 0
	var/inertial_coast_start_x = inertial_frame_test.Px(0)
	var/inertial_coast_velocity = inertial_frame_test.movement_velocity_x
	var/inertial_coast_expected_x = round(inertial_frame_test.vector_fraction_x + inertial_coast_velocity * vector_movement_physics_step_deciseconds)
	inertial_frame_test.movement_physics_time_accumulator = vector_movement_physics_step_deciseconds - world.tick_lag
	inertial_frame_test.processMovementPhysicsFrame(0)
	nexusSmokeAssert(inertial_frame_test.Px(0) - inertial_coast_start_x == inertial_coast_expected_x && inertial_frame_test.movement_acceleration_x == 0, "releasing movement input did not coast on retained velocity without new acceleration")
	nexusSmokeAssertNear(inertial_frame_test.movement_velocity_x, inertial_coast_velocity * inertial_frame_retention, 0.0001, "release coasting did not apply exactly one additional frame of retention")
	inertial_frame_test.loc = null
	del(inertial_frame_test)
	var/mob/NexusSmokeTest/InertialTeleport/inertial_teleport_test = new(vector_gap_origin)
	inertial_teleport_test.nexus_smoke_teleport_destination = vector_gap_north
	inertial_teleport_test.movement_velocity_x = 6
	inertial_teleport_test.vector_fraction_x = 0.9
	var/inertial_teleport_generation = inertial_teleport_test.movement_teleport_generation
	inertial_teleport_test.movement_physics_time_accumulator = vector_movement_physics_step_deciseconds - world.tick_lag
	inertial_teleport_test.processMovementPhysicsFrame(0)
	nexusSmokeAssert(inertial_teleport_test.loc == vector_gap_north && inertial_teleport_test.movement_teleport_generation > inertial_teleport_generation && !inertial_teleport_test.movement_velocity_x && !inertial_teleport_test.movement_last_frame_pixels, "same-map teleport during an inertial Move was processed as collision displacement (loc [inertial_teleport_test.loc], expected [vector_gap_north], generation [inertial_teleport_test.movement_teleport_generation]/[inertial_teleport_generation], velocity [inertial_teleport_test.movement_velocity_x], frame [inertial_teleport_test.movement_last_frame_pixels])")
	inertial_teleport_test.loc = null
	del(inertial_teleport_test)
	var/mob/NexusSmokeTest/InertialFacing/inertial_facing_test = new(vector_gap_origin)
	inertial_facing_test.dir = WEST
	inertial_facing_test.tryNexusInertiaMove(3, 0)
	nexusSmokeAssert(inertial_facing_test.observed_facing_direction == WEST && inertial_facing_test.observed_physical_direction == EAST && inertial_facing_test.observed_post_move_direction == WEST && inertial_facing_test.dir == WEST, "inertial collision direction leaked into gameplay-facing movement state or post-move callbacks")
	inertial_facing_test.loc = null
	del(inertial_facing_test)
	var/mob/NexusSmokeTest/VectorMovement/vector_collision_test = new(vector_gap_origin)
	vector_collision_test.max_ki = 1000000
	vector_collision_test.Ki = 1000000
	vector_collision_test.dir = EAST
	vector_collision_test.step_x = 28
	vector_collision_test.step_y = 0
	vector_collision_test.vector_fraction_x = 0
	vector_collision_test.vector_fraction_y = 0
	var/partial_vector_turf_type = vector_gap_second_east.type
	vector_gap_second_east = new /turf/NexusSmokeVectorBlocker(vector_gap_second_east)
	var/partial_vector_result = vector_step(vector_collision_test, dir_to_angle_0_360(EAST), 7)
	nexusSmokeAssert(partial_vector_result && !vector_collision_test.last_vector_move_complete && vector_collision_test.last_vector_move_actual_x > 0 && vector_collision_test.last_vector_move_actual_x < vector_collision_test.last_vector_move_requested_x, "vector movement still treats a truthy partial collision as a complete step")
	vector_gap_second_east = new partial_vector_turf_type(vector_gap_second_east)
	vector_collision_test.SafeTeleport(vector_gap_origin)
	vector_collision_test.configureNexusVectorCollisionBounds()
	nexusSmokeAssert(vector_collision_test.bound_x == 4 && vector_collision_test.bound_y == 4 && vector_collision_test.bound_width == 24 && vector_collision_test.bound_height == 24, "vector player collision bounds are not centered inside the 32-pixel sprite")
	vector_collision_test.dir = EAST
	vector_collision_test.step_x = 0
	vector_collision_test.step_y = 8
	vector_collision_test.vector_fraction_x = 0
	vector_collision_test.vector_fraction_y = 0
	var/doorway_edge_turf_type = vector_gap_northeast.type
	vector_gap_northeast = new /turf/NexusSmokeVectorBlocker(vector_gap_northeast)
	vector_collision_test.dir = WEST
	var/inertial_doorway_start_x = vector_collision_test.Px(0)
	var/inertial_doorway_start_y = vector_collision_test.Py(0)
	var/inertial_doorway_nudge_result = vector_collision_test.tryNexusInertiaMove(7, 0.1)
	nexusSmokeAssert(inertial_doorway_nudge_result && !vector_collision_test.last_vector_move_attempted && vector_collision_test.Px(0) == inertial_doorway_start_x && vector_collision_test.Py(0) == inertial_doorway_start_y - 1 && vector_collision_test.nexus_gap_nudge_direction == SOUTH && vector_collision_test.dir == WEST, "inertial doorway correction followed facing/input intent or changed visible facing")
	vector_collision_test.SafeTeleport(vector_gap_origin)
	vector_collision_test.dir = EAST
	vector_collision_test.step_x = 0
	vector_collision_test.step_y = 8
	vector_collision_test.vector_fraction_x = 0
	vector_collision_test.vector_fraction_y = 0
	var/doorway_start_x = vector_collision_test.Px(0)
	var/doorway_start_y = vector_collision_test.Py(0)
	var/doorway_nudge_result = vector_collision_test.tryNexusVectorMoveWithGapNudge(EAST, 7)
	nexusSmokeAssert(doorway_nudge_result && !vector_collision_test.last_vector_move_attempted && vector_collision_test.Px(0) == doorway_start_x && vector_collision_test.Py(0) == doorway_start_y - 1 && vector_collision_test.nexus_gap_nudge_direction == SOUTH, "vector movement did not preflight and nudge an off-center character before reaching a doorway corner (result [doorway_nudge_result], position [vector_collision_test.Px(0)],[vector_collision_test.Py(0)], start [doorway_start_x],[doorway_start_y], step [vector_collision_test.step_x],[vector_collision_test.step_y])")
	var/doorway_alignment_attempts = 0
	while(vector_collision_test.Px(0) == doorway_start_x && doorway_alignment_attempts < 16)
		sleep(world.tick_lag)
		vector_collision_test.tryNexusVectorMoveWithGapNudge(EAST, 7)
		doorway_alignment_attempts++
	nexusSmokeAssert(vector_collision_test.Px(0) >= doorway_start_x + 7 && vector_collision_test.Py(0) < doorway_start_y, "an off-center vector character did not converge on and advance through a one-tile doorway after [doorway_alignment_attempts] corrections")
	vector_gap_northeast = new doorway_edge_turf_type(vector_gap_northeast)
	vector_collision_test.SafeTeleport(vector_gap_origin)
	vector_collision_test.dir = EAST
	vector_collision_test.step_x = 0
	vector_collision_test.step_y = 0
	vector_collision_test.vector_fraction_x = 0
	vector_collision_test.vector_fraction_y = 0
	var/solid_vector_turf_type = vector_gap_east.type
	vector_gap_east = new /turf/NexusSmokeVectorBlocker(vector_gap_east)
	vector_collision_test.dir = NORTHEAST
	vector_collision_test.movement_velocity_x = 7
	vector_collision_test.movement_velocity_y = 7
	vector_collision_test.vector_fraction_x = 0.4
	var/inertial_wall_start_x = vector_collision_test.Px(0)
	var/inertial_wall_start_y = vector_collision_test.Py(0)
	var/inertial_wall_slide_result = vector_collision_test.tryNexusInertiaMove(7, 7)
	var/inertial_wall_delta_x = vector_collision_test.Px(0) - inertial_wall_start_x
	var/inertial_wall_delta_y = vector_collision_test.Py(0) - inertial_wall_start_y
	nexusSmokeAssert(inertial_wall_slide_result && inertial_wall_delta_x > 0 && inertial_wall_delta_x < 7 && inertial_wall_delta_y == 7 && !vector_collision_test.movement_velocity_x && vector_collision_test.movement_velocity_y == 7 && !vector_collision_test.vector_fraction_x, "partial inertial wall contact did not complete the open tangent and clear the blocked-axis carry (result [inertial_wall_slide_result], delta [inertial_wall_delta_x],[inertial_wall_delta_y], velocity [vector_collision_test.movement_velocity_x],[vector_collision_test.movement_velocity_y], requested [vector_collision_test.last_vector_move_requested_x],[vector_collision_test.last_vector_move_requested_y], actual [vector_collision_test.last_vector_move_actual_x],[vector_collision_test.last_vector_move_actual_y])")
	var/inertial_wall_follow_x = vector_collision_test.Px(0)
	var/inertial_wall_follow_y = vector_collision_test.Py(0)
	sleep(world.tick_lag)
	var/inertial_wall_follow_result = vector_collision_test.tryNexusInertiaMove(0, 7)
	nexusSmokeAssert(inertial_wall_follow_result && (vector_collision_test.Py(0) > inertial_wall_follow_y || vector_collision_test.Px(0) < inertial_wall_follow_x) && vector_collision_test.movement_velocity_y == 7, "retained wall-tangent velocity neither advanced nor corrected away from the wall on the next frame (result [inertial_wall_follow_result], position [vector_collision_test.Px(0)],[vector_collision_test.Py(0)], start [inertial_wall_follow_x],[inertial_wall_follow_y], nudge [vector_collision_test.nexus_gap_nudge_direction])")
	vector_collision_test.SafeTeleport(vector_gap_origin)
	vector_collision_test.dir = NORTHEAST
	vector_collision_test.step_x = 0
	vector_collision_test.step_y = 0
	vector_collision_test.vector_fraction_x = 0.4
	vector_collision_test.vector_fraction_y = 0.4
	vector_collision_test.movement_velocity_x = 7
	vector_collision_test.movement_velocity_y = 7
	var/corner_north_turf_type = vector_gap_north.type
	vector_gap_north = new /turf/NexusSmokeVectorBlocker(vector_gap_north)
	var/inertial_corner_start_x = vector_collision_test.Px(0)
	var/inertial_corner_start_y = vector_collision_test.Py(0)
	var/inertial_corner_result = vector_collision_test.tryNexusInertiaMove(7, 7)
	var/inertial_corner_delta_x = vector_collision_test.Px(0) - inertial_corner_start_x
	var/inertial_corner_delta_y = vector_collision_test.Py(0) - inertial_corner_start_y
	nexusSmokeAssert(inertial_corner_result && inertial_corner_delta_x > 0 && inertial_corner_delta_x < 7 && inertial_corner_delta_y > 0 && inertial_corner_delta_y < 7 && !vector_collision_test.movement_velocity_x && !vector_collision_test.movement_velocity_y && !vector_collision_test.vector_fraction_x && !vector_collision_test.vector_fraction_y, "an inertial L-corner retained blocked velocity or fractional pressure (result [inertial_corner_result], delta [inertial_corner_delta_x],[inertial_corner_delta_y], velocity [vector_collision_test.movement_velocity_x],[vector_collision_test.movement_velocity_y])")
	vector_gap_north = new corner_north_turf_type(vector_gap_north)
	vector_collision_test.SafeTeleport(vector_gap_origin)
	vector_collision_test.dir = EAST
	vector_collision_test.step_x = 0
	vector_collision_test.step_y = 0
	vector_collision_test.vector_fraction_x = 0
	vector_collision_test.vector_fraction_y = 0
	var/solid_wall_start_x = vector_collision_test.Px(0)
	var/solid_wall_start_y = vector_collision_test.Py(0)
	var/solid_wall_contact_result = vector_collision_test.tryNexusVectorMoveWithGapNudge(EAST, 7)
	nexusSmokeAssert(solid_wall_contact_result && vector_collision_test.Px(0) > solid_wall_start_x && vector_collision_test.Py(0) == solid_wall_start_y, "vector movement did not preserve the partial step that reaches a wall")
	solid_wall_start_x = vector_collision_test.Px(0)
	solid_wall_start_y = vector_collision_test.Py(0)
	nexusSmokeAssert(!vector_collision_test.tryNexusVectorMoveWithGapNudge(EAST, 7) && vector_collision_test.Px(0) == solid_wall_start_x && vector_collision_test.Py(0) == solid_wall_start_y, "holding vector movement against a solid wall causes positional jitter")
	vector_collision_test.dir = NORTHEAST
	var/diagonal_slide_result = vector_collision_test.tryNexusVectorMoveWithGapNudge(NORTHEAST, 7)
	nexusSmokeAssert(diagonal_slide_result && vector_collision_test.Px(0) == solid_wall_start_x && vector_collision_test.Py(0) > solid_wall_start_y, "diagonal vector movement does not slide along a wall (result [diagonal_slide_result], position [vector_collision_test.Px(0)],[vector_collision_test.Py(0)], start [solid_wall_start_x],[solid_wall_start_y], step [vector_collision_test.step_x],[vector_collision_test.step_y], requested [vector_collision_test.last_vector_move_requested_x],[vector_collision_test.last_vector_move_requested_y], actual [vector_collision_test.last_vector_move_actual_x],[vector_collision_test.last_vector_move_actual_y])")
	vector_gap_east = new solid_vector_turf_type(vector_gap_east)
	del(vector_collision_test)
	var/mob/NexusSmokeTest/rock_wall_caster = new(vector_gap_origin)
	var/mob/NexusSmokeTest/rock_wall_target = new(vector_gap_second_east)
	var/rock_wall_turf_type = vector_gap_east.type
	vector_gap_east = new /turf/NexusSmokeVectorBlocker(vector_gap_east)
	var/turf/blocked_rock_impact = rock_wall_caster.showRockSkillProjectile(rock_wall_target, 'RTRockThrow.dmi', null, 1)
	nexusSmokeAssert(!blocked_rock_impact, "a vector rock projectile crossed a dense wall and reported a remote impact")
	vector_gap_east = new rock_wall_turf_type(vector_gap_east)
	del(rock_wall_target)
	del(rock_wall_caster)
	nexusSmokeAssert(hudPercentage(50, 200) == 25, "HUD percentage calculation is invalid")
	nexusSmokeAssert(hudPercentage(50, 0) == 0, "HUD percentage did not guard a zero maximum")
	nexusSmokeAssert(nexusIsFiniteNumber(50) && !nexusIsFiniteNumber(1.#INF), "finite-number validation is invalid")
	var/mob/NexusSmokeTest/vitals_owner = new
	vitals_owner.icon = 'BaseHumanPale.dmi'
	vitals_owner.Ki = 8000
	vitals_owner.max_ki = 8000
	vitals_owner.willpower = 50
	vitals_owner.max_willpower = 100
	var/obj/NexusHud/VitalsPanel/vitals_panel = new
	vitals_panel.initialize(vitals_owner)
	var/obj/NexusHud/OverheadHealthBar/overhead_zoom_bar = new
	nexusSmokeAssert(vitals_panel.screen_loc == "LEFT:8,BOTTOM:8" && vitals_panel.plane == NEXUS_FIXED_HUD_PLANE && (vitals_panel.appearance_flags & RESET_TRANSFORM), "main vitals HUD is not fixed inside the lower-left corner or isolated from character scaling")
	nexusSmokeAssert(overhead_zoom_bar.plane == NEXUS_WORLD_OVERLAY_PLANE, "world-space overhead vitals no longer follow map-only zoom")
	del(overhead_zoom_bar)
	vitals_panel.setScreenPosition(92, 62)
	nexusSmokeAssert(vitals_panel.screen_loc == "LEFT:92,BOTTOM:62" && vitals_owner.nexus_main_vitals_x == 92 && vitals_owner.nexus_main_vitals_y == 62, "main vitals HUD drag positioning is not retained by its owner")
	var/datum/NexusInterfaceSettings/interface_settings_contract = new(vitals_owner)
	nexusSmokeAssert(findtext(interface_settings_contract.buildHtml(), "action=hud_move") && findtext(interface_settings_contract.buildHtml(), "action=hud_set"), "interface settings are missing HUD position controls")
	del(interface_settings_contract)
	var/mob/NexusSmokeTest/chat_contract_owner = new
	chat_contract_owner.nexus_interface_layout = "side_tabs"
	var/datum/NexusChatHud/chat_hud_contract = new(chat_contract_owner)
	var/obj/HudWindow/chat_transform_contract = new
	nexusSmokeAssert(chat_transform_contract.appearance_flags & RESET_TRANSFORM, "overlay chat elements inherit Giant or Larva character scaling")
	del(chat_transform_contract)
	var/chat_panel_html = chat_hud_contract.buildHtml()
	var/chat_output_fixture = "<span data-test='a&b;c'>Message &amp; combat; log</span>"
	var/chat_output_payload = encodeNexusBrowserFunctionArgument(chat_output_fixture)
	nexusSmokeAssert(!findtext(chat_output_payload, "<span") && !findtext(chat_output_payload, "&b;") && json_decode(url_decode(chat_output_payload)) == chat_output_fixture, "side chat JavaScript payload exposes raw HTML argument delimiters or cannot round-trip safely")
	nexusSmokeAssert(chat_hud_contract.getVisibleMessageCount() == 36 && findtext(chat_panel_html, "action=channel&id=all") && !findtext(chat_panel_html, "CMD BAR BELOW") && !findtext(chat_panel_html, "ENTER TO FOCUS OR RETURN TO MAP"), "side chat panel is missing paging/channels or retained the obsolete CMD hint")
	var/chat_footer_source_position = findtext(chat_panel_html, "<nav class='footer'>")
	var/chat_messages_source_position = findtext(chat_panel_html, "<section class='hud-panel messages'")
	nexusSmokeAssert(findtext(chat_panel_html, ".footer{order:4}") && findtext(chat_panel_html, ".footer .hud-button{display:flex;flex:1 1 25%;width:25%") && findtext(chat_panel_html, ".messages{order:3;") && findtext(chat_panel_html, ".nexus-hud .messages,.nexus-hud .messages *{font-family:'Courier New',monospace!important;font-variant:normal!important;text-transform:none!important}") && findtext(chat_panel_html, ".chat-entry{display:block;width:100%") && chat_footer_source_position && chat_messages_source_position && chat_footer_source_position < chat_messages_source_position && findtext(chat_panel_html, "body.className='nexus-hud'") && findtext(chat_panel_html, "function updateMessages(payload)") && findtext(chat_panel_html, "JSON.parse(payload)") && !findtext(chat_panel_html, "<img"), "side chat controls are not isolated from message markup, safely updateable, lowercase-readable, or evenly distributed")
	chat_contract_owner.nexus_interface_layout = "overlay"
	nexusSmokeAssert(chat_hud_contract.getVisibleMessageCount() >= 4, "overlay chat visible message calculation is invalid")
	del(chat_hud_contract)
	del(chat_contract_owner)
	nexusSmokeAssert(vitals_panel.vis_contents.len == 9 && vitals_panel.alpha == 255, "main vitals HUD composition is incomplete")
	var/icon/main_vitals_icon = getVitalsPanelIcon()
	var/icon/main_vitals_bar = getVitalsBarIcon(50, "#46d369")
	var/icon/power_gauge = getPowerGaugeIcon(50, FALSE)
	var/icon/active_modifiers_icon = getActiveModifiersPanelIcon()
	nexusSmokeAssert(vitals_panel.icon, "main vitals HUD did not retain its generated backdrop")
	nexusSmokeAssert(main_vitals_icon.Width() == 296 && main_vitals_icon.Height() == 136, "main vitals HUD has invalid dimensions")
	nexusSmokeAssert(main_vitals_bar.Width() == 168 && main_vitals_bar.Height() == 19, "main vitals bar has invalid dimensions")
	nexusSmokeAssert(power_gauge.Width() == 7 && power_gauge.Height() == 72, "main vitals power gauge has invalid dimensions")
	nexusSmokeAssert(active_modifiers_icon.Width() == 296 && active_modifiers_icon.Height() == 38, "active modifier strip has invalid dimensions")
	nexusSmokeAssert(!text2path("/obj/NexusHud/VitalRow/Power"), "redundant horizontal power bar still exists")
	nexusSmokeAssert(findtext(vitals_panel.willpower_row.detail_text.maptext, "50%") && vitals_panel.willpower_row.pixel_y > vitals_panel.health_row.pixel_y, "Willpower percentage is not rendered above Health")
	nexusSmokeAssert(findtext(vitals_panel.willpower_row.maptext, "WILLPOWER") && findtext(vitals_panel.health_row.maptext, "HEALTH") && findtext(vitals_panel.energy_row.maptext, "ENERGY") && findtext(vitals_panel.stamina_row.maptext, "STAMINA"), "main vitals HUD is missing status labels")
	nexusSmokeAssert(findtext(vitals_panel.energy_row.detail_text.maptext, "(8000) 100%") && vitals_panel.energy_row.detail_alignment == "right", "Energy does not use the (ki) percentage% format")
	nexusSmokeAssert(!findtext(vitals_panel.power_readout.maptext, "<br>"), "power readout still renders duplicate lines")
	nexusSmokeAssert(vitals_panel.active_modifiers_readout.alpha == 0 && vitals_panel.active_modifiers_readout.vis_contents.len == 3, "active modifier strip is visible without an active buff or is missing its fixed text rows")
	var/obj/Buff/Focus/hud_focus = new(vitals_owner)
	hud_focus.suffix = "Active"
	vitals_owner.current_buff = hud_focus
	vitals_owner.bp_mult += hud_focus.buff_bp - 1
	var/list/focus_modifier_data = vitals_owner.getNexusActiveHudModifiers()
	var/list/focus_modifiers = focus_modifier_data["modifiers"]
	nexusSmokeAssertNear(focus_modifiers["BP"], 1.18, 0.001, "Focus BP is not represented by the active modifier HUD")
	nexusSmokeAssertNear(focus_modifiers["SPD"], 1.2, 0.001, "Focus speed is not represented by the active modifier HUD")
	nexusSmokeAssertNear(focus_modifiers["REC"], 1.1, 0.001, "Focus recovery is not represented by the active modifier HUD")
	vitals_panel.update(vitals_owner)
	nexusSmokeAssert(vitals_panel.active_modifiers_readout.alpha == 255 && findtext(vitals_panel.active_modifiers_readout.header_text.maptext, "Focus") && findtext(vitals_panel.active_modifiers_readout.first_row_text.maptext, "BP 1.18x"), "active modifier strip did not render the live Focus summary")
	nexusSmokeAssert(vitals_panel.active_modifiers_readout.header_text.pixel_y > vitals_panel.active_modifiers_readout.first_row_text.pixel_y && vitals_panel.active_modifiers_readout.first_row_text.pixel_y > vitals_panel.active_modifiers_readout.second_row_text.pixel_y, "active modifier text rows can overlap vertically")
	nexusSmokeAssert(!findtext(vitals_panel.active_modifiers_readout.header_text.maptext, "<br>") && !findtext(vitals_panel.active_modifiers_readout.first_row_text.maptext, "<br>"), "active modifier strip still depends on unreliable multiline maptext")
	vitals_owner.current_buff = null
	hud_focus.suffix = null
	vitals_owner.bp_mult -= hud_focus.buff_bp - 1
	del(hud_focus)
	vitals_owner.ssj = 1
	vitals_owner.ssj_bp_mult = 1.35
	vitals_owner.base_bp = 10000000
	vitals_owner.ismystic = TRUE
	var/list/stacked_modifier_summary = vitals_owner.getNexusActiveHudModifierSummary()
	var/list/stacked_modifier_data = vitals_owner.getNexusActiveHudModifiers()
	var/list/stacked_modifiers = stacked_modifier_data["modifiers"]
	nexusSmokeAssert(findtext(stacked_modifier_summary["title"], "Super Saiyan") && findtext(stacked_modifier_summary["title"], "Mystic"), "stacked transformation and Mystic names are missing from the HUD summary")
	nexusSmokeAssertNear(stacked_modifiers["SPD"], 1.1, 0.001, "Mystic speed is missing from a stacked HUD summary")
	nexusSmokeAssertNear(stacked_modifiers["PWR"], 1.2, 0.001, "Mystic power-up speed is missing from a stacked HUD summary")
	del(vitals_panel)
	del(vitals_owner)
	for(var/beam_type in typesof(/obj/Attacks))
		if(initial(beam_type:hotbar_type) == "Beam")
			nexusSmokeAssert(skill_engine.isBeamSkill(beam_type), "beam skill is not routed through SkillEngine: [beam_type]")
	var/obj/Attacks/Piercer/beam_skill = new
	nexusSmokeAssert(beam_skill.beam_impact_mode == BEAM_IMPACT_EXPLOSIVE, "beam skill did not default to raw damage mode")
	nexusSmokeAssert(!text2path("/obj/Attacks/verb/beamImpactMode"), "obsolete per-skill beam mode verb still exists")
	nexusSmokeAssert(text2path("/mob/verb/kiSettings"), "central Ki Settings verb is missing")
	var/mob/NexusSmokeTest/beam_mode_player = new
	nexusSmokeAssert(beam_mode_player.beam_impact_mode == BEAM_IMPACT_EXPLOSIVE, "player beam mode did not default to raw damage")
	var/obj/Blast/beam_impact_segment = new
	nexusSmokeAssert(beam_impact_segment.getBeamDamageWindow(world.tick_lag) == beam_raw_damage_mod, "raw beam impact does not use immediate damage")
	beam_impact_segment.percent_damage = 10
	nexusSmokeAssert(beam_impact_segment.getExplosiveBeamKnockbackDistance(null) >= 5, "explosive beam impact has no knockback profile")
	beam_impact_segment.beam_impact_mode = BEAM_IMPACT_LOCK
	nexusSmokeAssert(beam_impact_segment.getBeamDamageWindow(world.tick_lag) == world.tick_lag, "beam lock does not retain tick damage")
	var/mob/NexusSmokeTest/beam_impact_target = new
	beam_mode_player.loc = locate(445, 3, 2)
	beam_impact_target.loc = get_step(beam_mode_player, EAST)
	var/obj/Attacks/Beam/streaming_beam = new(beam_mode_player)
	streaming_beam.streaming = 1
	beam_mode_player.beaming = 1
	beam_mode_player.current_beam = streaming_beam
	beam_impact_segment.loc = beam_impact_target.loc
	beam_impact_segment.Owner = beam_mode_player
	beam_impact_segment.from_attack = streaming_beam
	beam_impact_segment.beam_impact_mode = BEAM_IMPACT_EXPLOSIVE
	beam_impact_segment.dir = EAST
	var/obj/Blast/trailing_beam_segment = new(beam_mode_player.loc)
	trailing_beam_segment.Owner = beam_mode_player
	trailing_beam_segment.Beam = 1
	beam_mode_player.my_beam_objs.Add(beam_impact_segment, trailing_beam_segment)
	streaming_beam.beam_objects.Add(beam_impact_segment, trailing_beam_segment)
	beam_impact_segment.showExplosiveBeamImpact(beam_impact_target, force_mob_impact = 1)
	nexusSmokeAssert(beam_impact_target.last_knockbacked > 0 && beam_impact_target.knock_dir == EAST, "raw beam explosion did not knock its target in the beam direction")
	nexusSmokeAssert(!streaming_beam.streaming && !beam_mode_player.beaming, "raw player impact did not stop the streaming beam")
	nexusSmokeAssert(!streaming_beam.beam_objects.len && !beam_mode_player.my_beam_objs.len, "raw player impact did not clear beam segment lists")
	nexusSmokeAssert(!beam_impact_segment.z && !trailing_beam_segment.z, "raw player impact left beam segments on the map")
	var/list/explosion_light_profile = getNexusExplosionLightProfile(5)
	nexusSmokeAssert(explosion_light_profile["size"] >= 8 && explosion_light_profile["alpha"] == 255 && explosion_light_profile["variation"] == "blast", "large explosions do not emit a strong flickering light")
	nexusSmokeAssert(text2path("/obj/NexusLighting/ExplosionPulse"), "explosions are missing their transient light actor")
	var/obj/Attacks/Blast/nonbeam_skill = new
	var/obj/Blast/named_impact_projectile = new
	named_impact_projectile.from_attack = nonbeam_skill
	named_impact_projectile.percent_damage = 4
	nexusSmokeAssert(named_impact_projectile.getNexusProjectileImpactIcon() == 'src/Icons/NexusIntegrated/Attacks/Effects/RTImpact.dmi', "named damaging projectiles without custom art receive no shared impact VFX")
	del(named_impact_projectile)
	del(beam_impact_target)
	del(beam_mode_player)
	del(nonbeam_skill)
	del(beam_skill)
	var/icon/infinite_void_icon = icon('src/Icons/Effects/AlienInfiniteVoid.dmi', "void")
	var/list/infinite_void_states = icon_states('src/Icons/Effects/AlienInfiniteVoid.dmi')
	var/obj/Attacks/Time_Freeze/infinite_void_skill = new
	var/mob/NexusSmokeTest/infinite_void_user = new
	var/mob/NexusSmokeTest/infinite_void_target = new
	infinite_void_user.SafeTeleport(locate(445, 3, 2))
	infinite_void_target.SafeTeleport(get_step(infinite_void_user, EAST))
	infinite_void_user.BP = 100
	infinite_void_user.Pow = 100
	infinite_void_target.BP = 100
	infinite_void_target.Res = 100
	infinite_void_target.attackable = TRUE
	var/normal_void_stun = infinite_void_user.getAlienInfiniteVoidStunTicks(infinite_void_target)
	infinite_void_target.paralysis_immune = 1
	var/normalized_void_stun = infinite_void_user.getAlienInfiniteVoidStunTicks(infinite_void_target)
	var/obj/AlienInfiniteVoidVisual/infinite_void_visual = new
	nexusSmokeAssert(infinite_void_icon.Width() == 512 && infinite_void_icon.Height() == 512 && ("void" in infinite_void_states), "Time Stop domain is not a renderable 512x512 DMI with its required void state")
	nexusSmokeAssert(infinite_void_skill.name == "Time Stop" && infinite_void_skill.domain_radius == 8 && infinite_void_skill.domain_windup == 8, "Alien Time Freeze did not retain the Time Stop identity or area contract")
	nexusSmokeAssert(infinite_void_visual.icon_state == "void" && infinite_void_visual.plane == NEXUS_WORLD_OVERLAY_PLANE && infinite_void_visual.layer == 98 && infinite_void_visual.appearance_flags == PIXEL_SCALE, "Time Stop has no dedicated above-lighting visual actor")
	nexusSmokeAssert(normal_void_stun == 60 && normalized_void_stun == max(6, round(normal_void_stun * 0.25)), "Time Stop stun scaling or Time Normalizer mitigation is invalid")
	infinite_void_target.paralysis_immune = 0
	nexusSmokeAssert(infinite_void_user.canHitAlienInfiniteVoidTarget(infinite_void_target), "Time Stop rejected a valid same-area target")
	infinite_void_target.rp_mode = TRUE
	nexusSmokeAssert(!infinite_void_user.canHitAlienInfiniteVoidTarget(infinite_void_target), "Time Stop can stun an RP Mode target")
	infinite_void_target.rp_mode = FALSE
	infinite_void_target.Safezone = TRUE
	nexusSmokeAssert(!infinite_void_user.canHitAlienInfiniteVoidTarget(infinite_void_target), "Time Stop can stun a Safezone target")
	infinite_void_visual.reallyDelete = TRUE
	del(infinite_void_visual)
	del(infinite_void_skill)
	del(infinite_void_target)
	del(infinite_void_user)
	var/obj/RockThrow/rock_throw_skill = new
	var/obj/RockSlide/rock_slide_skill = new
	var/obj/RockTomb/rock_tomb_skill = new
	nexusSmokeAssert(rock_throw_skill.icon == 'RTRockThrow.dmi' && GetWidth(rock_throw_skill.icon) == 64 && rock_slide_skill.icon == 'RisingRocks.dmi' && rock_tomb_skill.icon == 'RTRockTomb.dmi' && GetWidth(rock_tomb_skill.icon) == 62, "rock skills are missing their differentiated technique icons")
	nexusSmokeAssert(rock_throw_skill.hotbar_type == "Blast" && rock_slide_skill.hotbar_type == "Blast" && rock_tomb_skill.hotbar_type == "Blast", "rock skills use an unsupported hotbar category")
	nexusSmokeAssert(text2path("/obj/Effect/RockSkillProjectile"), "rock attacks are missing their visible projectile actor")
	nexusSmokeAssert(text2path("/obj/Effect/RockSkillDebris") && nexus_rock_launch_sounds.len == 2 && nexus_rock_impact_sounds.len == 3 && nexus_rock_heavy_impact_sounds.len == 2 && nexus_rock_break_sounds.len == 3, "rock attacks are missing their CC0 audio or debris profiles")
	nexusSmokeAssert(text2path("/obj/Effect/NexusTechniqueText"), "Nexus techniques are missing their floating combat announcement actor")
	var/icon/critical_spark_icon = getNexusCriticalSparkIcon()
	nexusSmokeAssert(text2path("/obj/Effect/NexusCriticalCore") && text2path("/obj/Effect/NexusCriticalSpark") && text2path("/obj/Effect/NexusCriticalText"), "critical hits are missing their Black Flash effect actors")
	nexusSmokeAssert(critical_spark_icon && GetWidth(critical_spark_icon) == 96 && GetHeight(critical_spark_icon) == 96 && nexus_critical_impact_sounds.len == 2, "critical hits are missing their generated spark or layered audio profile")
	var/obj/Attacks/NexusMeleeTechnique/Slice/sword_slice_skill = new
	nexusSmokeAssert(sword_slice_skill.icon == 'src/Icons/Effects/CC0/SwordSlash.dmi' && sword_slice_skill.icon_state == "slash" && GetWidth(sword_slice_skill.icon) == 64 && GetHeight(sword_slice_skill.icon) == 47, "weapon skills are missing the animated CC0 slash icon")
	nexusSmokeAssert(nexus_sword_swing_light_sounds.len == 2 && nexus_sword_swing_heavy_sounds.len == 2 && nexus_sword_impact_sounds.len == 6 && (sword_slice_skill.getCastSound() in nexus_sword_swing_light_sounds) && (sword_slice_skill.getImpactSound() in nexus_sword_impact_sounds), "weapon skills are missing their CC0 swing and impact profiles")
	del(rock_throw_skill)
	del(rock_slide_skill)
	del(rock_tomb_skill)
	del(sword_slice_skill)
	var/obj/Lunge/lunge_action = new
	nexusSmokeAssert(lunge_action.can_hotbar && /obj/Lunge/verb/lunge in lunge_action.verbs, "Lunge is not available as a standalone action")
	nexusSmokeAssert(text2path("/mob/Admin2/verb/orderCombatDummyLunge") && text2path("/obj/NexusHud/DragonRushPrompt"), "Dragon Rush dummy control or direction prompt is missing")
	nexusSmokeAssert(text2path("/obj/NexusHud/BeamClashPrompt") && text2path("/obj/BeamClashMarker"), "Beam Clash prompt or center marker is missing")
	del(lunge_action)
	nexusSmokeAssert(wolf_fang_hit_damage_mult == 3 && wolf_fang_knockback_distance == 3 && wolf_fang_accuracy_bonus == 15 && !getWolfFangFinisherKnockback(4, 5) && getWolfFangFinisherKnockback(5, 5) == 3, "Wolf Fang Fist does not preserve contact until its finisher")
	nexusSmokeAssert(hundred_crack_min_hits == 24 && hundred_crack_hit_damage_mult == 0.75, "Hundred Crack Fist lost its sustained damage budget")
	nexusSmokeAssert(base_melee_damage == 2.5 && combat_damage_bp_exponent == 1 && combat_damage_stat_exponent == 0.85, "central combat damage constants are invalid")
	nexusSmokeAssert(skill_blast_total_factor == 0.6 && skill_big_bang_damage_factor == 28 && skill_charge_damage_factor == 8 && skill_cyber_charge_damage_factor == 6, "core projectile factors diverged from the balance workbook")
	nexusSmokeAssert(basic_blast_base_refire_deciseconds == 0.75 && basic_blast_default_volley_size == 3 && basic_blast_max_volley_size == 3 && basic_blast_damage_scale == 0.3 && basic_blast_energy_scale == 0.2 && basic_blast_angle_spacing_degrees == 6 && basic_blast_angle_jitter_degrees == 2 && basic_blast_owner_active_limit == 24 && basic_blast_global_active_limit == 256 && basic_blast_volley_configuration_version == 1, "rapid basic-blast volley tuning is invalid")
	nexusSmokeAssertNear(basic_blast_default_volley_size / basic_blast_base_refire_deciseconds, 4, 0.0001, "rapid basic blasts exceed the former maximum launch rate")
	nexusSmokeAssertNear(basic_blast_default_volley_size * basic_blast_energy_scale / basic_blast_base_refire_deciseconds, 0.8, 0.0001, "rapid basic blasts do not preserve the intended lower sustained Energy cost")
	var/obj/Attacks/Blast/basic_blast_math_test = new
	basic_blast_math_test.blast_refire = 1
	basic_blast_math_test.Spread = 1
	nexusSmokeAssertNear(basic_blast_math_test.getBasicBlastDamageFactor(), 0.105, 0.0001, "fast basic-blast pellet damage is not reduced by seventy percent")
	nexusSmokeAssert(basic_blast_math_test.getBasicBlastAngleOffset(1, 3) == -6 && basic_blast_math_test.getBasicBlastAngleOffset(2, 3) == 0 && basic_blast_math_test.getBasicBlastAngleOffset(3, 3) == 6, "basic-blast volley is not centered around its aim angle")
	basic_blast_math_test.blast_refire = 0.2
	nexusSmokeAssertNear(basic_blast_math_test.getBasicBlastDamageFactor(), 0.15, 0.0001, "slow basic-blast pellet damage lost its configured power curve")
	del(basic_blast_math_test)
	var/mob/NexusSmokeTest/basic_blast_migration_owner = new
	var/obj/Attacks/Blast/basic_blast_migration_skill = new(basic_blast_migration_owner)
	basic_blast_migration_owner.basic_blast_volley_version = 0
	basic_blast_migration_skill.Blast_Count = 1
	nexusSmokeAssert(basic_blast_migration_owner.migrateBasicBlastVolley(basic_blast_migration_skill) && basic_blast_migration_skill.Blast_Count == 3 && basic_blast_migration_owner.basic_blast_volley_version == basic_blast_volley_configuration_version, "legacy single-shot Blast defaults did not migrate to the rapid volley")
	basic_blast_migration_skill.Blast_Count = 1
	nexusSmokeAssert(!basic_blast_migration_owner.migrateBasicBlastVolley(basic_blast_migration_skill) && basic_blast_migration_skill.Blast_Count == 1, "basic-blast volley migration overwrote a post-migration player choice")
	del(basic_blast_migration_skill)
	del(basic_blast_migration_owner)
	nexusSmokeAssert(skill_makosen_damage_factor == 1.5 && skill_makosen_total_factor == 24 && skill_scatter_shot_damage_factor == 0.5 && skill_scatter_shot_total_factor == 30, "barrage factors diverged from the balance workbook")
	nexusSmokeAssert(skill_attack_barrier_damage_factor == 0.75 && skill_shockwave_damage_factor == 1.5 && skill_explosion_damage_factor == 12, "AoE factors diverged from the balance workbook")
	nexusSmokeAssert(skill_attack_barrier_max_orbs == 20 && skill_shockwave_pulses == 7 && skill_wall_of_flame_pulse_factor == 2 && skill_wall_of_flame_max_pulses == 6, "multi-hit area skill budgets diverged from the balance workbook")
	nexusSmokeAssert(skill_spin_blast_damage_factor == 2 && skill_spin_blast_projectiles == 4 && skill_genocide_damage_factor == 1.25 && skill_genocide_max_projectiles == 12 && skill_buster_barrage_damage_factor == 0.75 && skill_buster_barrage_total_factor == 24 && skill_buster_barrage_max_projectiles == 20, "rapid projectile skill budgets diverged from the balance workbook")
	nexusSmokeAssert(skill_lunge_damage_factor == 8 && skill_dragon_rush_damage_factor == 8 && skill_rock_throw_powerful_damage_factor == 8 && skill_rock_throw_rapid_damage_factor == 2 && skill_rock_slide_damage_factor == 0.8 && skill_rock_slide_max_hits == 15 && skill_rock_tomb_damage_factor == 14, "physical utility skill factors diverged from the balance workbook")
	nexusSmokeAssert(skill_dash_attack_min_factor == 5 && skill_dash_attack_max_factor == 18 && skill_dash_attack_step_factor == 0.55, "Dash Attack factor curve diverged from the balance contract")
	nexusSmokeAssert(!text2path("/mob/proc/PowerupDamageGrabber"), "ordinary Power Control aura can still damage a nearby grabber")
	nexusSmokeAssert(skill_dropkick_opening_factor == 11 && skill_dropkick_finisher_factor == 7 && skill_sokidan_damage_factor == 12 && skill_sokidan_total_factor == 24 && skill_kienzan_damage_factor == 18, "special skill factors diverged from the balance workbook")
	nexusSmokeAssert(skill_kikoho_damage_factor == 24 && skill_kikoho_self_damage_percent == 6 && skill_kikoho_damage_factor >= skill_kikoho_self_damage_percent * 3, "Kikoho no longer rewards its self-damage risk")
	var/mob/NexusSmokeTest/kikoho_attacker = new
	var/mob/NexusSmokeTest/kikoho_target = new
	kikoho_attacker.BP = 100
	kikoho_attacker.Pow = 100
	kikoho_target.BP = 100
	kikoho_target.Res = 100
	nexusSmokeAssertNear(kikoho_attacker.KikohoDamageTo(kikoho_target), skill_kikoho_damage_factor, 0.0001, "Kikoho runtime target damage diverged from its configured factor")
	del(kikoho_target)
	del(kikoho_attacker)
	nexusSmokeAssert(skill_final_explosion_initial_factor == 10 && skill_final_explosion_max_factor == 40 && skill_self_destruct_damage_factor == 45 && skill_planet_destroy_event_factor == 3 && skill_planet_destroy_total_factor == 30, "finisher skill factors diverged from the balance workbook")
	nexusSmokeAssert(skill_sokidan_total_factor >= base_melee_damage * 8 && skill_kienzan_damage_factor >= base_melee_damage * 7 && skill_makosen_total_factor >= base_melee_damage * 9, "invested Ki skills fell back below their intended basic-attack equivalents")
	nexusSmokeAssert(beam_skill_cooldown_ticks == 30 && beam_clash_winner_damage_mult == 1.35 && beam_clash_input_mult == 1.15, "beam cooldown or clash damage tuning is invalid")
	nexusSmokeAssert(calculateScaledCombatDamage(10, 100, 100, 100, 100) == 10, "equal-stat central damage did not preserve its factor")
	nexusSmokeAssert(calculateScaledCombatDamage(3, 13000, 200, 100, 100) == 195, "a 65x BP advantage cannot make a standard beam immediately decisive")
	nexusSmokeAssert(!calculateScaledCombatDamage(10, 100, 100, 0, 100), "zero offensive stat still caused damage")
	var/superior_stat_damage = calculateScaledCombatDamage(10, 100, 100, 200, 100)
	var/inferior_stat_damage = calculateScaledCombatDamage(10, 100, 100, 100, 200)
	nexusSmokeAssert(superior_stat_damage > 12 && superior_stat_damage < 13, "superior stat scaling escaped its expected bound")
	nexusSmokeAssert(inferior_stat_damage > 7 && inferior_stat_damage < 7.2, "defensive stat scaling escaped its expected bound")
	var/datum/CombatDamageBudget/test_damage_budget = new(7)
	var/mob/NexusSmokeTest/budget_target = new
	nexusSmokeAssert(test_damage_budget.reserveFactor(budget_target, 3.5) == 3.5 && test_damage_budget.reserveFactor(budget_target, 5) == 3.5, "per-target damage budget exceeded its cap")
	nexusSmokeAssert(!createBeamDamageBudget(BEAM_IMPACT_LOCK, 7), "Beam Lock still has a cumulative damage threshold")
	var/datum/CombatDamageBudget/explosive_beam_budget = createBeamDamageBudget(BEAM_IMPACT_EXPLOSIVE, 7)
	nexusSmokeAssert(explosive_beam_budget && explosive_beam_budget.max_factor_per_target == 7, "explosive beams lost their per-target damage budget")
	del(budget_target)
	var/mob/NexusSmokeTest/projectile_owner = new
	projectile_owner.BP = 100
	projectile_owner.Pow = 100
	projectile_owner.Off = 100
	projectile_owner.Spd = 100
	projectile_owner.BPpcnt = 100
	var/mob/NexusSmokeTest/basic_blast_owner = new(attack_movement_origin)
	basic_blast_owner.BP = 100
	basic_blast_owner.Pow = 100
	basic_blast_owner.Off = 100
	basic_blast_owner.Spd = 100
	basic_blast_owner.BPpcnt = 100
	basic_blast_owner.max_ki = 100000
	basic_blast_owner.Ki = 100000
	basic_blast_owner.dir = EAST
	var/obj/Attacks/Blast/basic_blast_skill = new(basic_blast_owner)
	basic_blast_skill.Blast_Count = 3
	basic_blast_skill.blast_refire = 1
	basic_blast_skill.Explosive = 1
	basic_blast_skill.Stun = 1
	basic_blast_skill.Shockwave = 1
	basic_blast_skill.Recalculate_blast_drain()
	var/basic_blast_drain = basic_blast_skill.getBasicBlastProjectileDrain(basic_blast_owner)
	var/basic_blast_ki_before = basic_blast_owner.Ki
	var/basic_blast_global_before = global_basic_blast_active_count
	nexusSmokeAssert(skill_engine.castBlast(basic_blast_owner, basic_blast_skill), "an affordable rapid basic-blast volley could not fire")
	var/list/basic_blast_volley = list()
	for(var/obj/Blast/basic_projectile in all_blast_objs)
		if(basic_projectile.in_use && basic_projectile.basic_blast_slot_owner == basic_blast_owner && basic_projectile.from_attack == basic_blast_skill) basic_blast_volley += basic_projectile
	nexusSmokeAssert(basic_blast_volley.len == 3 && basic_blast_owner.basic_blast_active_count == 3 && global_basic_blast_active_count == basic_blast_global_before + 3, "basic-blast volley did not reserve exactly three bounded projectile slots")
	nexusSmokeAssertNear(basic_blast_ki_before - basic_blast_owner.Ki, basic_blast_drain * 3, 0.01, "basic-blast volley did not charge exact per-projectile Energy")
	var/basic_blast_utility_projectiles = 0
	var/datum/CombatDamageBudget/basic_blast_shared_budget
	for(var/obj/Blast/basic_projectile in basic_blast_volley)
		nexusSmokeAssertNear(basic_projectile.percent_damage, 0.105, 0.0001, "rapid basic blast spawned with its former per-projectile damage")
		if(!basic_blast_shared_budget) basic_blast_shared_budget = basic_projectile.damage_budget
		nexusSmokeAssert(basic_projectile.damage_budget == basic_blast_shared_budget && basic_projectile.damage_budget.max_factor_per_target == 0.6, "basic-blast volley did not share its per-target damage budget")
		if(basic_projectile.Explosive || basic_projectile.Stun || basic_projectile.Shockwave) basic_blast_utility_projectiles++
	nexusSmokeAssert(basic_blast_utility_projectiles == 1, "explosion, stun, or knockback utility was duplicated across every blast pellet")
	for(var/obj/Blast/basic_projectile in basic_blast_volley) del(basic_projectile)
	nexusSmokeAssert(!basic_blast_owner.basic_blast_active_count && global_basic_blast_active_count == basic_blast_global_before, "basic-blast cache cleanup leaked active projectile slots")
	var/obj/Blast/reused_basic_blast = get_cached_blast()
	nexusSmokeAssert(!reused_basic_blast.basic_blast_slot_owner, "a pooled blast retained its prior basic-blast owner slot")
	del(reused_basic_blast)
	var/mob/NexusSmokeTest/basic_blast_other_owner = new
	var/obj/Blast/basic_blast_slot_test = get_cached_blast()
	var/basic_blast_slot_global_before = global_basic_blast_active_count
	nexusSmokeAssert(basic_blast_slot_test.registerBasicBlastSlot(basic_blast_owner) && basic_blast_slot_test.registerBasicBlastSlot(basic_blast_owner), "basic-blast slot registration is not idempotent for its owner")
	nexusSmokeAssert(basic_blast_owner.basic_blast_active_count == 1 && global_basic_blast_active_count == basic_blast_slot_global_before + 1, "idempotent slot registration incremented counters more than once")
	nexusSmokeAssert(!basic_blast_slot_test.registerBasicBlastSlot(basic_blast_other_owner) && !basic_blast_other_owner.basic_blast_active_count, "an active basic-blast slot changed owners")
	nexusSmokeAssert(basic_blast_slot_test.releaseBasicBlastSlot() && !basic_blast_slot_test.releaseBasicBlastSlot() && !basic_blast_owner.basic_blast_active_count && global_basic_blast_active_count == basic_blast_slot_global_before, "basic-blast slot release is not idempotent")
	del(basic_blast_slot_test)
	del(basic_blast_other_owner)
	var/mob/NexusSmokeTest/deleted_basic_blast_owner = new
	var/obj/Blast/deleted_owner_slot_test = get_cached_blast()
	var/deleted_owner_global_before = global_basic_blast_active_count
	nexusSmokeAssert(deleted_owner_slot_test.registerBasicBlastSlot(deleted_basic_blast_owner), "basic-blast slot could not register for owner-deletion cleanup")
	del(deleted_basic_blast_owner)
	nexusSmokeAssert(!deleted_owner_slot_test.basic_blast_slot_owner && deleted_owner_slot_test.basic_blast_slot_registered, "deleted blast owner erased the independent slot-registration sentinel")
	nexusSmokeAssert(deleted_owner_slot_test.releaseBasicBlastSlot() && global_basic_blast_active_count == deleted_owner_global_before && !deleted_owner_slot_test.releaseBasicBlastSlot(), "deleted blast owner leaked or double-released the global projectile slot")
	del(deleted_owner_slot_test)
	del(basic_blast_skill)
	del(basic_blast_owner)
	var/mob/NexusSmokeTest/low_ki_blast_owner = new(attack_movement_origin)
	low_ki_blast_owner.BP = 100
	low_ki_blast_owner.Pow = 100
	low_ki_blast_owner.Off = 100
	low_ki_blast_owner.Spd = 100
	low_ki_blast_owner.BPpcnt = 100
	low_ki_blast_owner.max_ki = 100000
	low_ki_blast_owner.dir = EAST
	var/obj/Attacks/Blast/low_ki_blast_skill = new(low_ki_blast_owner)
	low_ki_blast_skill.Blast_Count = 3
	low_ki_blast_skill.blast_refire = 1
	low_ki_blast_skill.Recalculate_blast_drain()
	var/low_ki_projectile_drain = low_ki_blast_skill.getBasicBlastProjectileDrain(low_ki_blast_owner)
	low_ki_blast_owner.Ki = low_ki_projectile_drain * 2.5
	nexusSmokeAssert(skill_engine.castBlast(low_ki_blast_owner, low_ki_blast_skill), "an affordable partial basic-blast volley could not fire")
	var/list/low_ki_blast_volley = list()
	for(var/obj/Blast/basic_projectile in all_blast_objs)
		if(basic_projectile.in_use && basic_projectile.basic_blast_slot_owner == low_ki_blast_owner && basic_projectile.from_attack == low_ki_blast_skill) low_ki_blast_volley += basic_projectile
	nexusSmokeAssert(low_ki_blast_volley.len == 2 && low_ki_blast_owner.Ki >= 0, "basic-blast affordability rounded up or allowed negative Energy")
	nexusSmokeAssertNear(low_ki_blast_owner.Ki, low_ki_projectile_drain * 0.5, 0.01, "partial basic-blast volley charged for a projectile it could not afford")
	for(var/obj/Blast/basic_projectile in low_ki_blast_volley) del(basic_projectile)
	del(low_ki_blast_skill)
	del(low_ki_blast_owner)
	var/mob/NexusSmokeTest/capped_blast_owner = new(attack_movement_origin)
	capped_blast_owner.BP = 100
	capped_blast_owner.Pow = 100
	capped_blast_owner.Off = 100
	capped_blast_owner.Spd = 100
	capped_blast_owner.BPpcnt = 100
	capped_blast_owner.max_ki = 100000
	capped_blast_owner.Ki = 100000
	capped_blast_owner.dir = EAST
	var/obj/Attacks/Blast/capped_blast_skill = new(capped_blast_owner)
	capped_blast_skill.Blast_Count = 3
	capped_blast_skill.blast_refire = 1
	capped_blast_skill.Recalculate_blast_drain()
	var/capped_blast_drain = capped_blast_skill.getBasicBlastProjectileDrain(capped_blast_owner)
	var/capped_blast_ki_before = capped_blast_owner.Ki
	capped_blast_owner.basic_blast_active_count = basic_blast_owner_active_limit
	nexusSmokeAssert(!skill_engine.castBlast(capped_blast_owner, capped_blast_skill) && capped_blast_owner.Ki == capped_blast_ki_before && !capped_blast_owner.attacking, "a full owner projectile cap still charged or entered attack state")
	capped_blast_owner.basic_blast_active_count = basic_blast_owner_active_limit - 1
	nexusSmokeAssert(skill_engine.castBlast(capped_blast_owner, capped_blast_skill), "one free basic-blast slot could not fire a partial volley")
	var/list/capped_blast_volley = list()
	for(var/obj/Blast/basic_projectile in all_blast_objs)
		if(basic_projectile.in_use && basic_projectile.basic_blast_slot_owner == capped_blast_owner && basic_projectile.from_attack == capped_blast_skill) capped_blast_volley += basic_projectile
	nexusSmokeAssert(capped_blast_volley.len == 1 && capped_blast_owner.basic_blast_active_count == basic_blast_owner_active_limit, "owner cap did not clamp the volley to its one free slot")
	nexusSmokeAssertNear(capped_blast_ki_before - capped_blast_owner.Ki, capped_blast_drain, 0.01, "owner-capped volley charged for blocked projectiles")
	for(var/obj/Blast/basic_projectile in capped_blast_volley) del(basic_projectile)
	capped_blast_owner.basic_blast_active_count = 0
	del(capped_blast_skill)
	del(capped_blast_owner)
	var/mob/NexusSmokeTest/barrier_lifecycle_owner = new(attack_movement_origin)
	var/mob/NexusSmokeTest/barrier_lifecycle_new_owner = new(attack_movement_destination)
	var/obj/Attacks/Attack_Barrier/barrier_lifecycle_skill = new(barrier_lifecycle_owner)
	barrier_lifecycle_skill.Firing_Attack_Barrier = TRUE
	barrier_lifecycle_owner.attack_barrier_obj = barrier_lifecycle_skill
	barrier_lifecycle_owner.attack_barrier_blasts = 1
	var/obj/Blast/barrier_lifecycle_blast = get_cached_blast()
	barrier_lifecycle_blast.Owner = barrier_lifecycle_owner
	barrier_lifecycle_blast.loc = attack_movement_origin
	barrier_lifecycle_blast.dir = EAST
	barrier_lifecycle_blast.attack_barrier_loop()
	barrier_lifecycle_blast.cache_blast()
	var/obj/Blast/barrier_reused_blast = get_cached_blast()
	nexusSmokeAssert(barrier_reused_blast == barrier_lifecycle_blast, "attack-barrier lifecycle test did not reacquire the pooled projectile")
	barrier_reused_blast.Owner = barrier_lifecycle_new_owner
	barrier_reused_blast.loc = attack_movement_origin
	var/barrier_reused_x = barrier_reused_blast.Px(0)
	var/barrier_reused_y = barrier_reused_blast.Py(0)
	sleep(TickMult(2))
	nexusSmokeAssert(!barrier_lifecycle_owner.attack_barrier_blasts && !barrier_lifecycle_new_owner.attack_barrier_blasts, "stale attack-barrier cleanup decremented the wrong owner's counter")
	nexusSmokeAssert(barrier_reused_blast.in_use && barrier_reused_blast.Owner == barrier_lifecycle_new_owner && barrier_reused_blast.Px(0) == barrier_reused_x && barrier_reused_blast.Py(0) == barrier_reused_y, "stale attack-barrier loop moved or deleted a reused projectile")
	barrier_reused_blast.Owner = null
	del(barrier_reused_blast)
	del(barrier_lifecycle_skill)
	del(barrier_lifecycle_new_owner)
	del(barrier_lifecycle_owner)
	var/obj/Blast/big_bang_projectile = new
	big_bang_projectile.setStats(projectile_owner, Percent = skill_big_bang_damage_factor, Explosion = 4, explosion_percent = skill_big_bang_damage_factor, max_damage_factor = skill_big_bang_damage_factor * 2)
	nexusSmokeAssert(big_bang_projectile.percent_damage == 28 && big_bang_projectile.explosion_damage_factor == 28 && big_bang_projectile.damage_budget.max_factor_per_target == 56, "Big Bang direct/splash budget is invalid")
	var/obj/Attacks/Final_Flash/final_flash_skill = new
	var/obj/Attacks/Noob_Ray/noob_ray_skill = new
	nexusSmokeAssert(final_flash_skill.damage_factor == 24 && noob_ray_skill.damage_factor == 52, "beam damage factors are invalid")
	var/strongest_progression_beam_factor = 0
	for(var/progression_beam_type in getNexusBeamAttackTypes())
		strongest_progression_beam_factor = max(strongest_progression_beam_factor, initial(progression_beam_type:damage_factor))
	nexusSmokeAssert(final_flash_skill.damage_factor == strongest_progression_beam_factor, "Final Flash is not the strongest raw-damage beam in Combat/Ki")
	var/makankosappo_type = /obj/Attacks/Piercer
	nexusSmokeAssert(initial(makankosappo_type:shield_pierce_mult) == 2.3, "Makankosappo lost its high shield-penetration profile")
	var/list/expected_beam_factors = list(
		/obj/Attacks/Noob_Ray = 52,
		/obj/Attacks/Laser_Beam = 12,
		/obj/Attacks/Beam = 10,
		/obj/Attacks/Ray = 12,
		/obj/Attacks/Piercer = 16,
		/obj/Attacks/Kamehameha = 18,
		/obj/Attacks/Dodompa = 13,
		/obj/Attacks/Final_Flash = 24,
		/obj/Attacks/Garlic_Gun = 17,
		/obj/Attacks/Masenko = 15)
	for(var/beam_type in expected_beam_factors)
		nexusSmokeAssert(initial(beam_type:damage_factor) == expected_beam_factors[beam_type], "beam factor diverged from the balance workbook: [beam_type]")
	var/obj/Attacks/Genki_Dama/omega_bomb_balance = new
	var/obj/Attacks/Genki_Dama/Death_Ball/death_ball_balance = new
	var/obj/Attacks/Genki_Dama/Supernova/supernova_balance = new
	var/obj/Blast/Genki_Dama/genki_projectile_lifecycle = new
	genki_projectile_lifecycle.Size = 4
	nexusSmokeAssert(omega_bomb_balance.sb_initial_dmg == 8 && omega_bomb_balance.sb_max_dmg == 30, "Genki Dama charge curve diverged from its tier-ten damage budget")
	nexusSmokeAssert(death_ball_balance.sb_initial_dmg == 8 && death_ball_balance.sb_max_dmg == 28, "Death Ball charge curve diverged from the balance workbook")
	nexusSmokeAssert(supernova_balance.sb_initial_dmg == 6 && supernova_balance.sb_max_dmg == 18, "Supernova charge curve diverged from the balance workbook")
	nexusSmokeAssert(genki_projectile_lifecycle.in_use, "new Genki Dama projectiles are inactive and cannot enter guided movement")
	nexusSmokeAssert(genki_projectile_lifecycle.getBlastCollisionRadiusPixels() == 4 * world.icon_size, "large blast collision radius no longer matches its authored Size in tiles")
	nexusSmokeAssert(genki_projectile_lifecycle.getNexusProjectileCollisionRadiusPixels() == 4 * world.icon_size, "large blast damage resolution discarded its authored Size radius")
	runNexusLargeBlastDamageCollisionSmoke(attack_movement_origin, attack_movement_pass_through, omega_bomb_balance, supernova_balance)
	var/mob/NexusSmokeTest/combat_geometry_target = new(attack_movement_origin)
	var/combat_geometry_center_x = combat_geometry_target.nexusCollisionCenterXPixels()
	var/combat_geometry_center_y = combat_geometry_target.nexusCollisionCenterYPixels()
	var/combat_geometry_half_width = combat_geometry_target.getNexusCombatHitboxWidth() * 0.5
	var/combat_geometry_half_height = combat_geometry_target.getNexusCombatHitboxHeight() * 0.5
	nexusSmokeAssert(nexusCircleIntersectsHitbox(combat_geometry_center_x + combat_geometry_half_width + 5, combat_geometry_center_y, 5, combat_geometry_target), "circular skill hitbox misses a rectangle edge contact")
	nexusSmokeAssert(!nexusCircleIntersectsHitbox(combat_geometry_center_x + combat_geometry_half_width + 5, combat_geometry_center_y + combat_geometry_half_height + 5, 5, combat_geometry_target), "circular skill hitbox still treats a square corner as a circle hit")
	nexusSmokeAssert(nexusCapsuleIntersectsHitbox(combat_geometry_center_x - 40, combat_geometry_center_y, combat_geometry_center_x + 40, combat_geometry_center_y, 2, combat_geometry_target), "beam capsule misses a rectangular character on its center line")
	nexusSmokeAssert(!nexusCapsuleIntersectsHitbox(combat_geometry_center_x - 40, combat_geometry_center_y + combat_geometry_half_height + 6, combat_geometry_center_x + 40, combat_geometry_center_y + combat_geometry_half_height + 6, 2, combat_geometry_target), "beam capsule hits a character outside its cylindrical radius")
	combat_geometry_target.setNexusCombatHitboxSource("smoke", 48, 60)
	nexusSmokeAssert(combat_geometry_target.getNexusCombatHitboxWidth() == 48 && combat_geometry_target.getNexusCombatHitboxHeight() == 60 && (combat_geometry_target in nexus_expanded_combat_hitbox_mobs), "transformation did not expand the rectangular combat hitbox")
	combat_geometry_target.setNexusCombatHitboxSource("smoke")
	nexusSmokeAssert(combat_geometry_target.getNexusCombatHitboxWidth() == combat_geometry_target.bound_width && combat_geometry_target.getNexusCombatHitboxHeight() == combat_geometry_target.bound_height && !(combat_geometry_target in nexus_expanded_combat_hitbox_mobs), "rectangular combat hitbox did not return to physical bounds")
	var/obj/Blast/beam_contact_segment_one = new
	var/obj/Blast/beam_contact_segment_two = new
	beam_contact_segment_one.Beam = 1
	beam_contact_segment_two.Beam = 1
	beam_contact_segment_one.Owner = projectile_owner
	beam_contact_segment_two.Owner = projectile_owner
	beam_contact_segment_one.from_attack = final_flash_skill
	beam_contact_segment_two.from_attack = final_flash_skill
	nexusSmokeAssert(combat_geometry_target.claimNexusBeamContact(beam_contact_segment_one) && !combat_geometry_target.claimNexusBeamContact(beam_contact_segment_two), "overlapping cylindrical beam segments can damage the same target more than once per tick")
	del(beam_contact_segment_two)
	del(beam_contact_segment_one)
	del(combat_geometry_target)
	del(big_bang_projectile)
	del(final_flash_skill)
	del(noob_ray_skill)
	del(omega_bomb_balance)
	del(death_ball_balance)
	del(supernova_balance)
	del(genki_projectile_lifecycle)
	nexusSmokeAssert(ki_projectile_step_delay == 0.5, "Ki projectile cadence is not normalized for 60 FPS")
	var/obj/Attacks/Sokidan/sokidan_skill = new
	var/datum/SkillDefinition/sokidan_definition = skill_engine.getDefinitionForObj(sokidan_skill)
	nexusSmokeAssert(sokidan_definition && sokidan_definition.control_delay == ki_projectile_step_delay, "Sokidan does not use the normalized Ki projectile cadence")
	var/datum/SkillController/GuidedBlast/guided_controller = skill_controller_registry.get(SKILL_CONTROLLER_GUIDED_BLAST)
	var/datum/SkillController/GuidedBomb/guided_bomb_controller = skill_controller_registry.get(SKILL_CONTROLLER_GUIDED_BOMB)
	projectile_owner.dir = NORTH
	projectile_owner.last_direction_pressed = EAST
	nexusSmokeAssert(guided_controller && guided_controller.getControlDirection(projectile_owner) == EAST, "guided blasts are not checking and moving toward the same direction")
	projectile_owner.last_direction_pressed = 0
	nexusSmokeAssert(guided_controller.getControlDirection(projectile_owner) == NORTH && guided_bomb_controller && guided_bomb_controller.getControlDirection(projectile_owner) == NORTH, "guided blasts or bombs have no facing-direction fallback")
	var/obj/Blast/kienzan_projectile = new
	kienzan_projectile.slice_attack = 1
	kienzan_projectile.Piercer = 1
	kienzan_projectile.setStats(projectile_owner, Percent = skill_kienzan_damage_factor, Off_Mult = 15, owner_immunity = 1)
	nexusSmokeAssert(!kienzan_projectile.damage_budget, "Kienzan still exhausts a one-hit damage budget")
	kienzan_projectile.applyPiercingDamageDecay()
	nexusSmokeAssert(kienzan_projectile.percent_damage == skill_kienzan_damage_factor * skill_kienzan_pierce_decay, "Kienzan does not lose damage after piercing a target")
	del(kienzan_projectile)
	del(sokidan_skill)
	del(projectile_owner)
	var/mob/NexusSmokeTest/rp_combat_test = new
	rp_combat_test.Race = "Human"
	rp_combat_test.max_ki = 1000
	nexusSmokeAssert(rp_combat_test.instantTransmissionWarpCost() == 2.5, "Instant Transmission directional Energy cost is invalid")
	rp_combat_test.Health = 100
	rp_combat_test.anger = 100
	rp_combat_test.max_anger = 200
	rp_combat_test.TakeDamage(25)
	nexusSmokeAssertNear(rp_combat_test.Health, 75, 0.01, "damage application changed during gradual anger buildup")
	nexusSmokeAssertNear(rp_combat_test.anger, 125, 0.01, "anger does not build proportionally as health is lost")
	var/mob/NexusSmokeTest/anger_attacker = new
	var/mob/NexusSmokeTest/AngerKoProbe/normal_anger_test = new
	normal_anger_test.Race = "Human"
	normal_anger_test.Health = 0
	normal_anger_test.max_ki = 1000
	normal_anger_test.Ki = 0
	normal_anger_test.max_anger = 200
	nexusSmokeAssert(normal_anger_test.canPossessAnger() && normal_anger_test.TryToCauseAnger(anger_attacker, normal_anger_test), "ordinary races cannot trigger their Anger second wind")
	nexusSmokeAssert(normal_anger_test.Health == 100 && normal_anger_test.Ki == normal_anger_test.max_ki && normal_anger_test.anger == normal_anger_test.max_anger && normal_anger_test.has_angered_before_ko, "Anger second wind does not restore full Health and Energy or lock its one use")
	normal_anger_test.Health = 0
	normal_anger_test.Ki = 0
	nexusSmokeAssert(!normal_anger_test.TryToCauseAnger(anger_attacker, normal_anger_test) && normal_anger_test.Health == 0 && normal_anger_test.Ki == 0, "Anger second wind can trigger more than once in one combat cycle")
	normal_anger_test.last_attacked_time = max(1, world.time)
	normal_anger_test.Calm()
	normal_anger_test.Health = 0
	normal_anger_test.Ki = 0
	nexusSmokeAssert(normal_anger_test.has_angered_before_ko && !normal_anger_test.TryToCauseAnger(anger_attacker, normal_anger_test), "calming during active combat rearms the Anger second wind")
	normal_anger_test.last_attacked_time = world.time - KO_SYSTEM_OUT_OF_COMBAT_TIMER - 1
	normal_anger_test.Calm()
	nexusSmokeAssert(!normal_anger_test.has_angered_before_ko && normal_anger_test.TryToCauseAnger(anger_attacker, normal_anger_test), "leaving combat does not rearm the Anger second wind")
	normal_anger_test.KO(anger_attacker, allow_anger = FALSE, combat_ko_handled = TRUE)
	sleep(1)
	nexusSmokeAssert(normal_anger_test.KO && !normal_anger_test.has_angered_before_ko, "a real KO does not reset the Anger second-wind cycle")
	normal_anger_test.UnKO()
	sleep(1)
	normal_anger_test.Health = 0
	normal_anger_test.Ki = 0
	nexusSmokeAssert(normal_anger_test.TryToCauseAnger(anger_attacker, normal_anger_test), "Anger second wind remains locked after recovering from a real KO")
	var/mob/NexusSmokeTest/android_anger_test = new
	android_anger_test.Race = "Android"
	android_anger_test.Android = TRUE
	var/mob/NexusSmokeTest/lssj_anger_test = new
	lssj_anger_test.Class = "Legendary Saiyan"
	var/mob/NexusSmokeTest/jiren_anger_test = new
	jiren_anger_test.jirenAlien = TRUE
	var/list/angerless_archetypes = list(android_anger_test, lssj_anger_test, jiren_anger_test)
	for(var/mob/NexusSmokeTest/angerless_test in angerless_archetypes)
		angerless_test.Health = 0
		angerless_test.anger = 175
		angerless_test.max_anger = 250
		nexusSmokeAssert(!angerless_test.canPossessAnger() && !angerless_test.can_anger(), "Android, LSSJ, or Jiren can still gain Anger")
		nexusSmokeAssert(angerless_test.anger == 100 && angerless_test.max_anger == 100 && angerless_test.Anger_mult() == 1, "an Angerless archetype retained Anger stats or power")
		nexusSmokeAssert(!angerless_test.TryToCauseAnger(anger_attacker, angerless_test) && angerless_test.Health == 0, "an Angerless archetype received an Anger second wind")
	del(anger_attacker)
	del(normal_anger_test)
	del(android_anger_test)
	del(lssj_anger_test)
	del(jiren_anger_test)
	var/mob/NexusSmokeTest/kaioken_upkeep_test = new
	kaioken_upkeep_test.base_bp = 100
	kaioken_upkeep_test.max_ki = 1000
	kaioken_upkeep_test.Ki = 1000
	kaioken_upkeep_test.Health = 60
	kaioken_upkeep_test.willpower = 100
	kaioken_upkeep_test.God_Fist_level = 2
	kaioken_upkeep_test.super_God_Fist = TRUE
	var/kaioken_willpower_cost = kaioken_upkeep_test.getGodFistWillpowerDrain()
	nexusSmokeAssert(kaioken_willpower_cost > 0 && kaioken_willpower_cost <= 0.14, "Kaioken Willpower upkeep is zero or exceeds its low-drain cap")
	nexusSmokeAssert(kaioken_upkeep_test.applyGodFistUpkeep(), "Kaioken rejected affordable Willpower upkeep")
	nexusSmokeAssertNear(kaioken_upkeep_test.Health, 60, 0.001, "Kaioken still drains Health")
	nexusSmokeAssertNear(kaioken_upkeep_test.willpower, 100 - kaioken_willpower_cost, 0.001, "Kaioken did not drain its calculated Willpower upkeep")
	nexusSmokeAssert(kaioken_upkeep_test.Ki < 1000, "Kaioken stopped draining Energy")
	kaioken_upkeep_test.willpower = 1
	nexusSmokeAssert(!kaioken_upkeep_test.applyGodFistUpkeep() && kaioken_upkeep_test.willpower == 1 && !kaioken_upkeep_test.God_Fist_level, "Kaioken did not stop safely at its Willpower reserve")
	del(kaioken_upkeep_test)
	rp_combat_test.setRPMode(TRUE, announce = FALSE)
	nexusSmokeAssert(!rp_combat_test.CanInputMove() && rp_combat_test.rp_mode_input_lock, "RP Mode did not fully lock movement input")
	var/mob/NexusSmokeTest/rp_grabber_test = new
	nexusSmokeAssert(!rp_grabber_test.canGrabMovable(rp_combat_test) && !rp_grabber_test.CanExtendoGrab(rp_combat_test), "RP Mode can still be targeted by a normal or tail-extending grab")
	rp_combat_test.TakeDamage(25)
	nexusSmokeAssertNear(rp_combat_test.Health, 75, 0.01, "RP Mode did not protect its user from damage")
	nexusSmokeAssert(rp_combat_test.cant_blast(), "RP Mode still allows energy attacks")
	rp_combat_test.ApplyStun(time = 20, no_immunity = TRUE, stun_power = 2)
	nexusSmokeAssert(!rp_combat_test.stun_level, "RP Mode still allows combat stuns")
	rp_combat_test.setRPMode(FALSE, announce = FALSE)
	nexusSmokeAssert(!rp_combat_test.rp_mode_input_lock && !rp_combat_test.input_disabled, "leaving RP Mode did not release its movement lock")
	nexusSmokeAssert(!rp_combat_test.has_entered_combat(victim = rp_combat_test), "a never-attacked player is incorrectly considered in combat")
	rp_combat_test.Health = 50
	rp_combat_test.willpower = 100
	rp_combat_test.last_attacked_time = world.time
	rp_combat_test.applyRegenerationHealth(20)
	nexusSmokeAssert(rp_combat_test.Health == 70 && rp_combat_test.willpower == 100, "casual combat regeneration consumed Willpower")
	rp_combat_test.enterLethalCombat()
	rp_combat_test.applyRegenerationHealth(10, drains_willpower = FALSE)
	nexusSmokeAssert(rp_combat_test.Health == 80 && rp_combat_test.willpower == 100, "auto-repair incorrectly consumes Willpower")
	rp_combat_test.applyRegenerationHealth(10)
	nexusSmokeAssert(rp_combat_test.Health == 90 && rp_combat_test.willpower == 97.5, "lethal combat regeneration does not consume Willpower")
	rp_combat_test.SetSparringMode(LETHAL_COMBAT, FALSE)
	nexusSmokeAssert(rp_combat_test.sparring_mode == LETHAL_COMBAT && rp_combat_test.Fatal, "lethal intent did not enable fatal damage")
	rp_combat_test.SetSparringMode(CASUAL_COMBAT, FALSE)
	nexusSmokeAssert(rp_combat_test.sparring_mode == CASUAL_COMBAT && !rp_combat_test.Fatal, "casual intent did not disable fatal damage")
	var/mob/NexusSmokeTest/delayed_dot_attacker = new
	var/mob/NexusSmokeTest/DotKnockoutProbe/delayed_dot_victim = new
	delayed_dot_attacker.SetSparringMode(CASUAL_COMBAT, FALSE)
	delayed_dot_victim.Health = 1
	delayed_dot_victim.willpower = 100
	nexusSmokeAssert(delayed_dot_victim.applyNexusFireDot(delayed_dot_attacker, 20, 2) && delayed_dot_victim.nexus_fire_dot_combat_mode == CASUAL_COMBAT, "delayed fire did not snapshot casual combat intent")
	delayed_dot_attacker.SetSparringMode(LETHAL_COMBAT, FALSE)
	delayed_dot_victim.processNexusStatusEffects(delayed_dot_victim.nexus_fire_dot_until)
	nexusSmokeAssert(delayed_dot_victim.KO && delayed_dot_victim.observed_dot_attacker == delayed_dot_attacker && delayed_dot_victim.observed_combat_mode_override == CASUAL_COMBAT, "a casual DoT did not preserve its snapshotted combat intent after the source changed mode")
	var/mob/NexusSmokeTest/DotKnockoutProbe/source_less_dot_victim = new
	source_less_dot_victim.Health = 1
	source_less_dot_victim.willpower = 100
	nexusSmokeAssert(source_less_dot_victim.applyNexusFireDot(null, 20, 2) && source_less_dot_victim.nexus_fire_dot_combat_mode == CASUAL_COMBAT, "source-less delayed damage did not fail safe to casual intent")
	source_less_dot_victim.processNexusStatusEffects(source_less_dot_victim.nexus_fire_dot_until)
	nexusSmokeAssert(source_less_dot_victim.KO && !source_less_dot_victim.observed_dot_attacker && source_less_dot_victim.observed_combat_mode_override == CASUAL_COMBAT, "source-less DoT did not fail safe to a casual knockout")
	del(source_less_dot_victim)
	del(delayed_dot_victim)
	del(delayed_dot_attacker)
	rp_combat_test.willpower = 100
	rp_combat_test.enterLethalCombat()
	rp_combat_test.drainWillpower(rp_combat_test.getLethalKoDrain(), "Smoke test", announce = FALSE)
	nexusSmokeAssert(rp_combat_test.willpower == 70 && rp_combat_test.isInLethalCombat(), "lethal combat did not drain and track Willpower")
	rp_combat_test.KO = TRUE
	rp_combat_test.rp_mode = TRUE
	rp_combat_test.ko_recovery_ready_at = world.time
	nexusSmokeAssert(rp_combat_test.willpowerGetUp(), "Willpower could not raise a ready lethal-KO player")
	nexusSmokeAssert(!rp_combat_test.KO && !rp_combat_test.rp_mode && rp_combat_test.Health == 70, "Willpower get-up restored an invalid combat state")
	var/mob/NexusSmokeTest/willpower_break_test = new
	willpower_break_test.willpower = 5
	willpower_break_test.drainWillpower(5, "Smoke test", announce = FALSE)
	nexusSmokeAssert(willpower_break_test.KO && willpower_break_test.rp_mode && willpower_break_test.ko_is_lethal, "zero Willpower entered RP Mode without causing a knockout")
	del(willpower_break_test)
	del(rp_grabber_test)
	var/mob/NexusSmokeTest/milestone_test = new
	milestone_test.Age = 20
	milestone_test.syncMilestoneProgression(silent = TRUE)
	nexusSmokeAssert(milestone_test.milestone_points == MILESTONE_STARTING_POINTS, "legacy milestone initialization did not grant its starter budget")
	nexusSmokeAssert(milestone_test.purchaseMilestone("iron_will") && milestone_test.getMilestoneRank("iron_will") == 1, "milestone purchase did not persist its rank")
	nexusSmokeAssert(milestone_test.getMaxWillpower() == 110, "Iron Will did not raise maximum Willpower")
	milestone_test.milestone_last_year = floor(Year) - 1
	milestone_test.syncMilestoneProgression(silent = TRUE)
	nexusSmokeAssert(milestone_test.total_milestone_points == MILESTONE_STARTING_POINTS + 1, "yearly Milestone Point progression did not advance")
	milestone_test.milestone_points = 20
	nexusSmokeAssert(milestone_test.purchaseMilestone("rapid_recovery") && milestone_test.purchaseMilestone("steadfast_spirit"), "independent Milestone list picks could not be purchased directly")
	milestone_test.milestones_owned["unarmed_mastery"] = 2
	milestone_test.milestones_owned["deft_hands"] = 4
	milestone_test.milestones_owned["bleeding_edge"] = 1
	milestone_test.milestones_owned["thundering_blows"] = 1
	milestone_test.milestones_owned["burning_fists"] = 1
	milestone_test.milestones_owned["venomous_intent"] = 1
	milestone_test.milestones_owned["crushing_resolve"] = 1
	milestone_test.milestones_owned["this_drill_will_pierce_the_heavens"] = 1
	milestone_test.Str = 100
	milestone_test.End = 60
	milestone_test.Pow = 120
	milestone_test.Res = 70
	milestone_test.Off = 40
	milestone_test.Def = 50
	milestone_test.Spd = 80
	milestone_test.milestones_owned["versatile_training"] = 2
	milestone_test.milestones_owned["momentum_damage"] = 1
	milestone_test.milestones_owned["keen_edge"] = 2
	milestone_test.milestones_owned["sweeping_impact"] = 1
	milestone_test.milestones_owned["echoing_assault"] = 2
	milestone_test.milestones_owned["unencumbered_combatant"] = 1
	milestone_test.ensureMilestoneCombatRewards()
	nexusSmokeAssertNear(milestone_test.getMilestoneMeleeDamageMultiplier(null, FALSE), 1.05, 0.001, "Unarmed Mastery did not affect unarmed damage")
	nexusSmokeAssertNear(milestone_test.getMilestoneMeleeAccuracyBonus(null), 10, 0.001, "Deft Hands did not grant flat melee accuracy")
	nexusSmokeAssertNear(milestone_test.getMilestoneGuardMultiplier(), 0.9, 0.001, "This Drill Will Pierce the Heavens did not penetrate guard stats")
	nexusSmokeAssertNear(milestone_test.getMilestonePhysicalDamageStat(), 124.8, 0.001, "Momentum Damage or Versatile Training did not diversify physical scaling")
	nexusSmokeAssertNear(milestone_test.getMilestoneKiDamageStat(), 145.6, 0.001, "Momentum Damage or Versatile Training did not diversify ki scaling")
	nexusSmokeAssertNear(milestone_test.getMilestoneEffectiveOffense(), 47.84, 0.001, "Unencumbered Combatant did not increase armorless and weaponless Offense")
	nexusSmokeAssertNear(milestone_test.getMilestoneEffectiveDefense(), 59.8, 0.001, "Unencumbered Combatant did not increase armorless and weaponless Defense")
	nexusSmokeAssert(milestone_test.getMilestoneCriticalChanceBonus() == 6 && milestone_test.getMilestoneMeleeAreaRadius() == 3 && milestone_test.getMilestoneDoubleAttackChance() == 16, "critical, three-tile melee area or double-attack milestones are inactive")
	var/mob/NexusSmokeTest/fire_lord_target = new
	fire_lord_target.BurnStack = 4
	milestone_test.milestones_owned["fire_lord"] = 1
	nexusSmokeAssertNear(milestone_test.getMilestoneFireLordBonus(fire_lord_target, "Wall of Flame"), 0.2, 0.001, "Fire Lord does not scale fire damage from the target's Burn stacks")
	nexusSmokeAssertNear(milestone_test.getMilestoneFireLordBonus(fire_lord_target, "Melee Attack"), 0, 0.001, "Fire Lord incorrectly buffs non-fire attacks")
	del(fire_lord_target)
	nexusSmokeAssert((locate(/obj/FireFist) in milestone_test) && (locate(/obj/MilestoneTechnique/BleedingEdge) in milestone_test) && (locate(/obj/MilestoneTechnique/ThunderingBlows) in milestone_test) && (locate(/obj/MilestoneTechnique/VenomousIntent) in milestone_test) && (locate(/obj/MilestoneTechnique/CrushingResolve) in milestone_test), "combat milestone techniques were not granted or restored")
	initializeProgressionTreeCatalog()
	runNexusCometReversalSmoke(attack_movement_origin, attack_movement_destination, attack_movement_pass_through)
	var/list/progression_categories = list()
	for(var/progression_node_id in progression_node_catalog)
		var/datum/ProgressionNode/progression_node = progression_node_catalog[progression_node_id]
		progression_categories[progression_node.category] = TRUE
		for(var/prerequisite_id in progression_node.prerequisites)
			var/datum/ProgressionNode/prerequisite_node = progression_node_catalog[prerequisite_id]
			nexusSmokeAssert(!prerequisite_node || prerequisite_node.tier < progression_node.tier, "a progression prerequisite shares or exceeds its child's display tier: [prerequisite_id] -> [progression_node.id]")
	for(var/milestone_id in milestone_catalog)
		var/datum/MilestoneDefinition/milestone_node = milestone_catalog[milestone_id]
		nexusSmokeAssert(!milestone_node.prerequisites.len, "Milestone still depends on a talent-tree prerequisite: [milestone_node.id]")
	nexusSmokeAssert(progression_node_catalog.len >= 200 && progression_categories.len == 6 && milestone_catalog.len >= 49, "unified progression catalog is missing skills, talents or a primary category")
	nexusSmokeAssert(milestone_catalog["bleeding_edge"] && milestone_catalog["burning_fists"] && milestone_catalog["fire_lord"] && milestone_catalog["this_drill_will_pierce_the_heavens"] && milestone_catalog["venomous_intent"] && milestone_catalog["crushing_resolve"], "the signature integrated combat Milestones are missing")
	nexusSmokeAssert(milestone_catalog["versatile_training"] && milestone_catalog["sweeping_impact"] && milestone_catalog["echoing_assault"] && milestone_catalog["keen_edge"] && milestone_catalog["unencumbered_combatant"], "the build-diversifying Milestones are missing")
	var/datum/ProgressionNode/kai_hakai_node = progression_node_catalog[getRacialProgressionNodeId("Kaioshin", /obj/Hakai)]
	var/datum/ProgressionNode/demon_hakai_node = progression_node_catalog[getRacialProgressionNodeId("Daimao", /obj/Hakai)]
	nexusSmokeAssert(kai_hakai_node && demon_hakai_node && kai_hakai_node.tier == 10 && demon_hakai_node.tier == 10 && kai_hakai_node.cost == 600 && demon_hakai_node.cost == 600, "Hakai is not the tier-ten apex of both Kaioshin and Daimao on the scaled XP curve")
	nexusSmokeAssert(kai_hakai_node.prerequisites.len > 0 && demon_hakai_node.prerequisites.len > 0, "racial Hakai has no visible final-rank prerequisites")
	var/datum/ProgressionNode/ghost_progression_node = progression_node_catalog[getProgressionNodeIdForType(/obj/Attacks/NexusSpecialStyle/SuperGhostKamikaze)]
	var/datum/ProgressionNode/explosive_wave_progression_node = progression_node_catalog[getProgressionNodeIdForType(/obj/Attacks/NexusAreaTechnique/SuperExplosiveWave)]
	var/datum/ProgressionNode/earthquake_progression_node = progression_node_catalog[getProgressionNodeIdForType(/obj/Attacks/NexusAreaTechnique/Earthquake)]
	var/explosive_wave_shockwave_prerequisite_id = getProgressionNodeIdForType(/obj/Attacks/Shockwave)
	nexusSmokeAssert(ghost_progression_node && ghost_progression_node.branch == "Ki" && ghost_progression_node.tier == 8 && explosive_wave_progression_node && explosive_wave_progression_node.branch == "Ki" && explosive_wave_progression_node.prerequisites.len == 1 && explosive_wave_progression_node.prerequisites[1] == explosive_wave_shockwave_prerequisite_id && earthquake_progression_node && earthquake_progression_node.branch == "Physical", "ported integrated techniques are missing, routed incorrectly, or Super Explosive Wave no longer unlocks from Shockwave")
	nexusSmokeAssert(progression_node_catalog["mining_prospector"]:tier == 1 && progression_node_catalog["mining_tin"]:tier == 2 && progression_node_catalog["mining_iron"]:tier == 3 && progression_node_catalog["mining_silver"]:tier == 4 && progression_node_catalog["mining_mythril"]:tier == 4 && progression_node_catalog["mining_auracite"]:tier == 5 && progression_node_catalog["mining_heart"]:tier == 5, "Prospecting nodes are not distributed across their authored tier branches")
	nexusSmokeAssert(progression_node_catalog["smithing_apprentice"]:tier == 1 && progression_node_catalog["smithing_bronze"]:tier == 2 && progression_node_catalog["smithing_iron"]:tier == 3 && progression_node_catalog["smithing_silver"]:tier == 3 && progression_node_catalog["smithing_mythril"]:tier == 4 && progression_node_catalog["smithing_auracite"]:tier == 4 && progression_node_catalog["smithing_masterwork"]:tier == 5, "Smithing material nodes are not distributed across their authored tier branches")
	var/list/specialized_science_counts = list()
	for(var/obj/technology in tech_list)
		if(!(technology.science_path in list("Engineering", "Robotics", "Genetics"))) continue
		var/level_key = "[technology.science_path]|[technology.science_level]"
		specialized_science_counts[level_key] = specialized_science_counts[level_key] ? specialized_science_counts[level_key] + 1 : 1
	for(var/science_branch in list("Engineering", "Robotics", "Genetics"))
		var/distributed_total = 0
		for(var/science_level = 5, science_level <= 8, science_level++)
			var/level_count = specialized_science_counts["[science_branch]|[science_level]"]
			nexusSmokeAssert(level_count > 0, "[science_branch] has no technology distributed to Technology Level [science_level]")
			distributed_total += level_count
		nexusSmokeAssert(specialized_science_counts["[science_branch]|5"] * 2 < distributed_total, "[science_branch] remains overcrowded at Technology Level 5")
	nexusSmokeAssert(!milestone_catalog["ub_godspeed"] && !progression_node_catalog["combat_buffs_advanced"] && !progression_node_catalog["combat_buffs_mastery"], "Ultimate Buffs or obsolete straight-list gateways remain in Milestones")
	var/godspeed_progression_id = getProgressionNodeIdForType(/obj/Buff/Ultimate/Godspeed)
	var/high_tension_progression_id = getProgressionNodeIdForType(/obj/Buff/Ultimate/HighTension)
	var/datum/ProgressionNode/godspeed_progression_node = progression_node_catalog[godspeed_progression_id]
	var/datum/ProgressionNode/high_tension_progression_node = progression_node_catalog[high_tension_progression_id]
	nexusSmokeAssert(godspeed_progression_node && high_tension_progression_node && godspeed_progression_node.category == "Combat" && godspeed_progression_node.branch == "Buffs" && godspeed_progression_node.tier == 5 && godspeed_progression_node.exclusive_group == "ultimate_buff", "Ultimate Buffs are not Combat/Buffs tier-five capstones")
	var/focus_progression_id = getProgressionNodeIdForType(/obj/Buff/Focus)
	var/defensive_stance_progression_id = getProgressionNodeIdForType(/obj/Buff/Preset/DefensiveStance)
	var/angelic_grace_progression_id = getProgressionNodeIdForType(/obj/Buff/Preset/AngelicGrace)
	var/datum/ProgressionNode/defensive_stance_progression_node = progression_node_catalog[defensive_stance_progression_id]
	var/datum/ProgressionNode/angelic_grace_progression_node = progression_node_catalog[angelic_grace_progression_id]
	nexusSmokeAssert((focus_progression_id in defensive_stance_progression_node.prerequisites) && (defensive_stance_progression_id in angelic_grace_progression_node.prerequisites) && (angelic_grace_progression_id in godspeed_progression_node.prerequisites), "Buff progression does not form a meaningful multi-tier path")
	var/beam_progression_id = getProgressionNodeIdForType(/obj/Attacks/Beam)
	var/kamehameha_progression_id = getProgressionNodeIdForType(/obj/Attacks/Kamehameha)
	var/final_flash_progression_id = getProgressionNodeIdForType(/obj/Attacks/Final_Flash)
	var/tyrant_lancer_progression_id = getProgressionNodeIdForType(/obj/Attacks/RoleplayBeam/TyrantLancer)
	var/makankosappo_progression_id = getProgressionNodeIdForType(/obj/Attacks/Piercer)
	var/datum/ProgressionNode/beam_progression_node = progression_node_catalog[beam_progression_id]
	var/datum/ProgressionNode/kamehameha_progression_node = progression_node_catalog[kamehameha_progression_id]
	var/datum/ProgressionNode/final_flash_progression_node = progression_node_catalog[final_flash_progression_id]
	var/datum/ProgressionNode/tyrant_lancer_progression_node = progression_node_catalog[tyrant_lancer_progression_id]
	var/datum/ProgressionNode/makankosappo_progression_node = progression_node_catalog[makankosappo_progression_id]
	nexusSmokeAssert(beam_progression_node.branch == "Foundation" && beam_progression_node.tier == 4 && kamehameha_progression_node.branch == "Beam" && kamehameha_progression_node.tier == 6 && final_flash_progression_node.branch == "Beam" && final_flash_progression_node.tier == 8 && (kamehameha_progression_id in final_flash_progression_node.prerequisites), "Final Flash does not rise from foundational Beam through the dedicated raw-power Beam path")
	nexusSmokeAssert(tyrant_lancer_progression_node.branch == "Beam" && tyrant_lancer_progression_node.tier == 7 && makankosappo_progression_node.branch == "Beam" && makankosappo_progression_node.tier == 8 && (tyrant_lancer_progression_id in makankosappo_progression_node.prerequisites), "Makankosappo does not cap the dedicated shield-piercing Beam path")
	for(var/beam_skill_type in getNexusBeamAttackTypes())
		var/datum/ProgressionNode/dedicated_beam_node = progression_node_catalog[getProgressionNodeIdForType(beam_skill_type)]
		var/expected_beam_branch = beam_skill_type == /obj/Attacks/Beam ? "Foundation" : "Beam"
		nexusSmokeAssert(dedicated_beam_node && dedicated_beam_node.branch == expected_beam_branch, "beam skill is outside Foundation or the dedicated Beam tree: [beam_skill_type]")
	var/power_control_progression_id = getProgressionNodeIdForType(/obj/Power_Control)
	var/blast_progression_id = getProgressionNodeIdForType(/obj/Attacks/Blast)
	var/lunge_progression_id = getProgressionNodeIdForType(/obj/Lunge)
	var/fly_progression_id = getProgressionNodeIdForType(/obj/Fly)
	var/shield_progression_id = getProgressionNodeIdForType(/obj/Shield)
	var/meditate_two_progression_id = getProgressionNodeIdForType(/obj/Meditate_Level_2)
	var/charge_progression_id = getProgressionNodeIdForType(/obj/Attacks/Charge)
	var/shockwave_progression_id = getProgressionNodeIdForType(/obj/Attacks/Shockwave)
	var/dash_attack_progression_id = getProgressionNodeIdForType(/obj/Dash_Attack)
	var/zanzoken_progression_id = getProgressionNodeIdForType(/obj/Zanzoken)
	var/custom_buff_progression_id = getProgressionNodeIdForType(/obj/Buff)
	var/sokidan_progression_id = getProgressionNodeIdForType(/obj/Attacks/Sokidan)
	var/list/foundation_progression_ids = list(power_control_progression_id, blast_progression_id, lunge_progression_id, fly_progression_id, shield_progression_id, meditate_two_progression_id, charge_progression_id, shockwave_progression_id, dash_attack_progression_id, zanzoken_progression_id, custom_buff_progression_id, beam_progression_id, sokidan_progression_id)
	for(var/foundation_progression_id in foundation_progression_ids)
		var/datum/ProgressionNode/foundation_progression_node = progression_node_catalog[foundation_progression_id]
		nexusSmokeAssert(foundation_progression_node && foundation_progression_node.category == "Combat" && foundation_progression_node.branch == "Foundation" && !foundation_progression_node.external_unlock, "a universal combat skill is missing from purchasable Foundation: [foundation_progression_id]")
	var/datum/ProgressionNode/shield_progression_node = progression_node_catalog[shield_progression_id]
	var/datum/ProgressionNode/meditate_two_progression_node = progression_node_catalog[meditate_two_progression_id]
	var/datum/ProgressionNode/shockwave_progression_node = progression_node_catalog[shockwave_progression_id]
	var/datum/ProgressionNode/dash_foundation_node = progression_node_catalog[dash_attack_progression_id]
	var/datum/ProgressionNode/zanzoken_progression_node = progression_node_catalog[zanzoken_progression_id]
	var/datum/ProgressionNode/sokidan_progression_node = progression_node_catalog[sokidan_progression_id]
	nexusSmokeAssert(shield_progression_node && (power_control_progression_id in shield_progression_node.prerequisites) && (blast_progression_id in shield_progression_node.prerequisites), "Shield does not require both ki regulation and basic projection")
	nexusSmokeAssert(meditate_two_progression_node && (power_control_progression_id in meditate_two_progression_node.prerequisites) && meditate_two_progression_node.tier == 3, "Meditate Level 2 is missing from the Combat Foundation ki-control path")
	nexusSmokeAssert(shockwave_progression_node && shockwave_progression_node.tier == 3 && (power_control_progression_id in shockwave_progression_node.prerequisites) && (blast_progression_id in shockwave_progression_node.prerequisites), "Shockwave is missing from the Combat Foundation radial-force path")
	nexusSmokeAssert(dash_foundation_node && zanzoken_progression_node && (lunge_progression_id in dash_foundation_node.prerequisites) && (fly_progression_id in zanzoken_progression_node.prerequisites) && (dash_attack_progression_id in zanzoken_progression_node.prerequisites), "Foundation movement does not progress from Lunge and Flight into Dash Attack and Zanzoken")
	nexusSmokeAssert(sokidan_progression_node && (power_control_progression_id in sokidan_progression_node.prerequisites) && (beam_progression_id in sokidan_progression_node.prerequisites), "Sokidan does not require ki control and sustained projection")
	var/genki_progression_id = getProgressionNodeIdForType(/obj/Attacks/Genki_Dama)
	var/kaioken_progression_id = getProgressionNodeIdForType(/obj/God_Fist)
	var/datum/ProgressionNode/genki_progression_node = progression_node_catalog[genki_progression_id]
	var/datum/ProgressionNode/kaioken_progression_node = progression_node_catalog[kaioken_progression_id]
	nexusSmokeAssert(genki_progression_node && genki_progression_node.branch == "Ki" && genki_progression_node.tier == 10 && (sokidan_progression_id in genki_progression_node.prerequisites), "Genki Dama is not the tier-ten Ki damage capstone")
	nexusSmokeAssert(kaioken_progression_node && kaioken_progression_node.branch == "Buffs" && kaioken_progression_node.tier == 10, "Kaioken is not a tier-ten Buff capstone")
	nexusSmokeAssert(getProgressionBaseActiveExperiencePerHour() == 20, "hourly Progression XP is not calibrated to 20 XP on the 10x scale")
	nexusSmokeAssert(getProgressionTierLifetimeRequirement(5) == 720 && getProgressionTierLifetimeRequirement(10) == 3300, "scaled Progression lifetime gates diverged from the original time targets")
	var/foundation_progression_cost = progression_node_catalog["combat_foundation_root"].cost
	for(var/foundation_cost_id in foundation_progression_ids)
		var/datum/ProgressionNode/foundation_cost_node = progression_node_catalog[foundation_cost_id]
		foundation_progression_cost += foundation_cost_node.cost
	nexusSmokeAssert(foundation_progression_cost == 840, "Combat Foundation no longer includes its complete scaled progression budget")
	var/mob/NexusSmokeTest/tier_gate_test = new
	tier_gate_test.progression_experience = 10000
	tier_gate_test.progression_lifetime_experience = 3299
	var/datum/ProgressionNode/tier_ten_gate_test = new("tier_ten_smoke", "Tier Ten Smoke", "", "Combat", "Ki", 10, 1)
	nexusSmokeAssert(tier_ten_gate_test.cost == 10 && findtext(tier_gate_test.getProgressionNodeLockReason(tier_ten_gate_test), "3300 lifetime"), "tier ten ignored its scaled cost or lifetime Progression XP gate")
	tier_gate_test.progression_lifetime_experience = 3300
	nexusSmokeAssert(!tier_gate_test.getProgressionNodeLockReason(tier_ten_gate_test), "tier ten remained time-locked after reaching its lifetime target")
	del(tier_ten_gate_test)
	del(tier_gate_test)
	var/mob/NexusSmokeTest/roleplay_session_test = new
	roleplay_session_test.progression_roleplay_session_started_time = world.time - (30 * 60 * 10)
	roleplay_session_test.progression_roleplay_session_last_time = world.time
	roleplay_session_test.progression_roleplay_session_messages = 6
	roleplay_session_test.progression_roleplay_session_words = 120
	roleplay_session_test.progression_roleplay_session_participants = list("partner" = TRUE)
	var/roleplay_session_smoke_reward = roleplay_session_test.tryAwardProgressionRoleplaySession()
	nexusSmokeAssert(roleplay_session_smoke_reward == 30 && roleplay_session_test.progression_roleplay_sessions_completed == 1, "a qualified roleplay session did not grant its scaled single-session award: reward [roleplay_session_smoke_reward], start [roleplay_session_test.progression_roleplay_session_started_time], now [world.time], messages [roleplay_session_test.progression_roleplay_session_messages], words [roleplay_session_test.progression_roleplay_session_words], partners [roleplay_session_test.progression_roleplay_session_participants.len]")
	nexusSmokeAssert(roleplay_session_test.tryAwardProgressionRoleplaySession() == 0 && roleplay_session_test.progression_chat_experience == 30, "a roleplay session paid more than once")
	roleplay_session_test.resetProgressionRoleplaySession()
	roleplay_session_test.progression_roleplay_session_started_time = world.time - (10 * 60 * 10)
	roleplay_session_test.progression_roleplay_session_messages = 20
	roleplay_session_test.progression_roleplay_session_words = 500
	roleplay_session_test.progression_roleplay_session_participants = list("partner" = TRUE)
	nexusSmokeAssert(roleplay_session_test.tryAwardProgressionRoleplaySession() == 0, "an undersized roleplay session bypassed the minimum duration")
	del(roleplay_session_test)
	var/mob/NexusSmokeTest/hourly_progression_test = new
	hourly_progression_test.progression_experience_scale_version = 1
	var/hourly_progression_now = world.realtime
	hourly_progression_test.progression_last_passive_realtime = hourly_progression_now - 3 * 36000
	var/hourly_progression_reward = hourly_progression_test.updatePassiveProgression(announce = FALSE)
	nexusSmokeAssert(hourly_progression_reward == 60 && hourly_progression_test.progression_experience == 60 && hourly_progression_test.progression_passive_experience == 60 && hourly_progression_test.progression_last_passive_realtime == hourly_progression_now, "three elapsed offline hours did not pay the same 20 XP/hour as online time")
	del(hourly_progression_test)
	var/mob/NexusSmokeTest/progression_scale_migration_test = new
	progression_scale_migration_test.progression_experience = 12
	progression_scale_migration_test.progression_lifetime_experience = 25
	progression_scale_migration_test.progression_chat_experience = 3
	progression_scale_migration_test.progression_passive_experience = 2
	nexusSmokeAssert(progression_scale_migration_test.migrateProgressionExperienceScale() && progression_scale_migration_test.progression_experience == 120 && progression_scale_migration_test.progression_lifetime_experience == 250 && progression_scale_migration_test.progression_chat_experience == 30 && progression_scale_migration_test.progression_passive_experience == 20, "existing Progression XP balances did not migrate to the 10x scale")
	nexusSmokeAssert(!progression_scale_migration_test.migrateProgressionExperienceScale() && progression_scale_migration_test.progression_experience == 120, "Progression XP scale migration applied more than once")
	del(progression_scale_migration_test)
	var/obj/Attacks/Genki_Dama/genki_damage_test = new
	var/obj/Attacks/NexusSpecialStyle/ChargedProjectile/DragonNova/dragon_nova_damage_test = new
	nexusSmokeAssert(genki_damage_test.sb_max_dmg * 2 > dragon_nova_damage_test.projectile_damage_factor * 2, "Genki Dama does not have the largest authored player projectile damage budget")
	del(dragon_nova_damage_test)
	del(genki_damage_test)
	var/list/excluded_combat_progression_types = list(
		/obj/Majin, /obj/Keep_Body, /obj/Demon_Contract, /obj/Attacks/Cyber_Charge, /obj/Attacks/Laser_Beam,
		/obj/Mystic, /obj/Observe, /obj/Invisibility, /obj/Make_Swarm, /obj/Make_Fruit, /obj/Attacks/Time_Freeze,
		/obj/Hakai, /obj/Make_Holy_Pendant, /obj/MilestoneTechnique, /obj/Buff/Preset/CombatMathematics,
		/obj/Buff/Preset/BleedingEdge, /obj/Focusin_revert, /obj/Overdrive, /obj/Great_Ape, /obj/ArcaneSpell,
		/obj/ArcaneSpell/Projectile, /obj/MakeAmulet, /obj/Make_Dragon_Balls, /obj/Namekian_Fusion, /obj/Third_Eye,
		/obj/Unlock_Potential, /obj/Bind, /obj/Shunkan_Ido, /obj/FireFist)
	for(var/excluded_combat_type in excluded_combat_progression_types)
		nexusSmokeAssert(!progression_node_catalog[getProgressionNodeIdForType(excluded_combat_type)], "rank, module, milestone, magic or utility reward leaked into Combat progression: [excluded_combat_type]")
	for(var/progression_node_id in progression_node_catalog)
		var/datum/ProgressionNode/combat_skill_node = progression_node_catalog[progression_node_id]
		if(combat_skill_node.category != "Combat" || combat_skill_node.reward_kind != "skill") continue
		nexusSmokeAssert(isProgressionCombatSkillType(combat_skill_node.reward_type) && !combat_skill_node.external_unlock, "non-combat or external-only object leaked into the purchasable Combat catalog: [combat_skill_node.reward_type]")
	for(var/rock_skill_type in getNexusRockAttackTypes())
		var/datum/ProgressionNode/rock_progression_node = progression_node_catalog[getProgressionNodeIdForType(rock_skill_type)]
		nexusSmokeAssert(rock_progression_node && rock_progression_node.branch == "Physical", "physical rock technique was categorized as Ki: [rock_skill_type]")
	for(var/weapon_wave_type in list(/obj/Attacks/NexusSpecialStyle/ChargedProjectile/EchoingSlash, /obj/Attacks/NexusSpecialStyle/ChargedProjectile/SkyBreak))
		var/datum/ProgressionNode/weapon_wave_node = progression_node_catalog[getProgressionNodeIdForType(weapon_wave_type)]
		nexusSmokeAssert(weapon_wave_node && weapon_wave_node.branch == "Weapon" && initial(weapon_wave_type:weapon_projectile), "sword wave is not a weapon-scaled Weapon-tree technique: [weapon_wave_type]")
	var/consecutive_punches_progression_id = getProgressionNodeIdForType(/obj/Attacks/NexusMeleeTechnique/ConsecutiveNormalPunches)
	var/march_of_fury_progression_id = getProgressionNodeIdForType(/obj/Attacks/NexusMeleeTechnique/MarchOfFury)
	var/pile_driver_progression_id = getProgressionNodeIdForType(/obj/Attacks/NexusMeleeTechnique/PileDriver)
	var/texas_smash_progression_id = getProgressionNodeIdForType(/obj/Attacks/NexusMeleeTechnique/TexasSmash)
	var/critical_edge_progression_id = getProgressionNodeIdForType(/obj/Attacks/NexusMeleeTechnique/CriticalEdge)
	var/guard_break_progression_id = getProgressionNodeIdForType(/obj/Attacks/NexusMeleeTechnique/GuardBreak)
	var/exploding_heart_progression_id = getProgressionNodeIdForType(/obj/Attacks/NexusMeleeTechnique/ExplodingHeartStrike)
	var/datum/ProgressionNode/march_of_fury_progression_node = progression_node_catalog[march_of_fury_progression_id]
	var/datum/ProgressionNode/texas_smash_progression_node = progression_node_catalog[texas_smash_progression_id]
	var/datum/ProgressionNode/exploding_heart_progression_node = progression_node_catalog[exploding_heart_progression_id]
	nexusSmokeAssert(march_of_fury_progression_node.tier == 5 && (consecutive_punches_progression_id in march_of_fury_progression_node.prerequisites), "March of Fury does not cap the authored Unarmed combo path")
	nexusSmokeAssert(texas_smash_progression_node.tier == 5 && (pile_driver_progression_id in texas_smash_progression_node.prerequisites), "Texas Smash does not cap the authored Unarmed impact path")
	var/datum/ProgressionNode/critical_edge_progression_node = progression_node_catalog[critical_edge_progression_id]
	nexusSmokeAssert(critical_edge_progression_node && critical_edge_progression_node.branch == "Weapon" && critical_edge_progression_node.tier == 4, "Critical Edge is not a Weapon-tree stance")
	nexusSmokeAssert(exploding_heart_progression_node.tier == 5 && (guard_break_progression_id in exploding_heart_progression_node.prerequisites), "Exploding Heart Strike does not cap the authored Unarmed control path")
	for(var/legacy_unarmed_type in list(/obj/PressurePunch, /obj/RoundhouseKick, /obj/Dropkick, /obj/WolfFangFist, /obj/Hokuto_Shinken))
		var/legacy_unarmed_id = getProgressionNodeIdForType(legacy_unarmed_type)
		var/datum/ProgressionNode/legacy_unarmed_node = progression_node_catalog[legacy_unarmed_id]
		nexusSmokeAssert(legacy_unarmed_node && legacy_unarmed_node.category == "Combat" && legacy_unarmed_node.branch == "Unarmed", "legacy physical attack is missing from Combat/Unarmed: [legacy_unarmed_type]")
	var/datum/ProgressionNode/dropkick_progression_node = progression_node_catalog[getProgressionNodeIdForType(/obj/Dropkick)]
	var/datum/ProgressionNode/hundred_crack_progression_node = progression_node_catalog[getProgressionNodeIdForType(/obj/Hokuto_Shinken)]
	nexusSmokeAssert(dash_foundation_node.tier == 3 && dropkick_progression_node.tier == 5 && hundred_crack_progression_node.tier == 5, "Dash Attack did not move to Foundation or peak Unarmed attacks lost their capstone tiers")
	var/datum/ProgressionNode/alchemy_circle_progression_node = progression_node_catalog["magic_transmutation_circle"]
	nexusSmokeAssert(alchemy_circle_progression_node && !("magic_attunement" in alchemy_circle_progression_node.prerequisites), "high-tier Magic still bypasses its branch choices")
	nexusSmokeAssert(typesof(/obj/Buff/Preset).len == 13 && typesof(/obj/Buff/Ultimate).len == 7, "integrated Nexus buff catalog is incomplete")
	nexusSmokeAssert(typesof(/obj/Peebag).len >= 10, "integrated Nexus Punching Bag or Magic Goo tiers are incomplete")
	nexusSmokeAssert(magic_research_catalog["magic_goo_4"] && magic_research_catalog["transmutation_circle"] && magic_research_catalog["philosophers_stone"], "Nexus Alchemy research is incomplete")
	initializeArcaneFormulaCatalog()
	nexusSmokeAssert(arcane_formula_catalog.len == 42, "the complete Nexus arcane formula catalog was not registered")
	for(var/arcane_formula_id in arcane_formula_catalog)
		nexusSmokeAssert(magic_research_catalog[arcane_formula_id], "an arcane formula has no Magic progression node: [arcane_formula_id]")
	var/datum/MagicResearchNode/shikon_research_node = magic_research_catalog["shikon_jewel"]
	var/datum/ArcaneFormula/shikon_formula = arcane_formula_catalog["shikon_jewel"]
	nexusSmokeAssert(shikon_research_node && shikon_research_node.branch == "Artifacts" && shikon_research_node.required_level == 9, "Shikon Jewel is not registered as high-tier Artifacts research")
	nexusSmokeAssert(shikon_formula && shikon_formula.construct_type == /obj/items/Shikon_Jewel && shikon_formula.required_circle_tier == 2 && shikon_formula.essence_cost >= 500, "Shikon Jewel does not use a high-tier arcane crafting ritual")
	nexusSmokeAssert(magic_research_catalog["fireball"] && magic_research_catalog["frost_nova"] && magic_research_catalog["earth_prison"] && magic_research_catalog["create_portal"] && magic_research_catalog["enchant"], "ported integrated spell research is incomplete")
	var/mob/NexusSmokeTest/arcane_defense_test = new
	arcane_defense_test.End = 12
	arcane_defense_test.Res = 8
	arcane_defense_test.arcane_defense_stat_empowered_until = world.time + 100
	nexusSmokeAssertNear(arcane_defense_test.getArcaneEmpoweredEndurance(), 18, 0.001, "Empowered Defenses did not increase effective Endurance by 50%")
	nexusSmokeAssertNear(arcane_defense_test.getArcaneEmpoweredResistance(), 12, 0.001, "Empowered Defenses did not increase effective Resistance by 50%")
	del(arcane_defense_test)
	var/turf/arcane_spell_origin
	for(var/turf/candidate_spell_origin in world)
		if(candidate_spell_origin.x <= 5 || candidate_spell_origin.x > world.maxx - 5 || candidate_spell_origin.y <= 5 || candidate_spell_origin.y > world.maxy - 5) continue
		var/open_perimeter = TRUE
		for(var/test_x = candidate_spell_origin.x - 5, test_x <= candidate_spell_origin.x + 5 && open_perimeter, test_x++)
			for(var/test_y = candidate_spell_origin.y - 5, test_y <= candidate_spell_origin.y + 5, test_y++)
				if(test_x != candidate_spell_origin.x - 5 && test_x != candidate_spell_origin.x + 5 && test_y != candidate_spell_origin.y - 5 && test_y != candidate_spell_origin.y + 5) continue
				var/turf/perimeter_tile = locate(test_x, test_y, candidate_spell_origin.z)
				if(!perimeter_tile || perimeter_tile.density)
					open_perimeter = FALSE
					break
		if(open_perimeter)
			arcane_spell_origin = candidate_spell_origin
			break
	nexusSmokeAssert(arcane_spell_origin, "startup map has no open perimeter for Arcane spell tests")
	var/mob/NexusSmokeTest/arcane_spell_caster = new(arcane_spell_origin)
	arcane_spell_caster.BP = 100
	var/mob/NexusSmokeTest/frost_nova_target = new(get_step(arcane_spell_origin, EAST))
	frost_nova_target.BP = 100
	frost_nova_target.Health = 100
	var/obj/ArcaneSpell/FrostNova/frost_nova_contract = new
	nexusSmokeAssert(frost_nova_contract.applyNova(arcane_spell_caster) == 1 && frost_nova_target.Health < 100 && frost_nova_target.stun_level > 0 && frost_nova_target.stun_time >= 15, "Frost Nova did not damage and stun a clientless area target")
	var/obj/ArcaneSpell/EarthPrison/earth_prison_contract = new
	var/list/prison_walls = earth_prison_contract.createPerimeter(arcane_spell_caster, 5, 0)
	nexusSmokeAssert(prison_walls.len == 40, "Earth Prison did not create the complete five-tile square perimeter")
	for(var/obj/ArcaneEarthBarrier/prison_wall in prison_walls)
		nexusSmokeAssert(max(abs(prison_wall.x - arcane_spell_origin.x), abs(prison_wall.y - arcane_spell_origin.y)) == 5, "Earth Prison created a wall outside its square perimeter")
		del(prison_wall)
	var/mob/NexusSmokeTest/gravity_well_target = new(arcane_spell_origin)
	gravity_well_target.Gravity_Update()
	var/gravity_before_well = gravity_well_target.Gravity
	var/obj/ArcaneGravityWell/gravity_well_contract = new(arcane_spell_origin)
	gravity_well_contract.gravity_level = max(7, gravity_before_well + 1)
	gravity_well_contract.activate(0)
	nexusSmokeAssert(gravity_well_target.Gravity == gravity_well_contract.gravity_level && arcane_spell_origin.arcane_gravity == gravity_well_contract.gravity_level, "Gravity Well did not apply gravity through the native turf gravity contract")
	del(gravity_well_contract)
	gravity_well_target.Gravity_Update()
	nexusSmokeAssert(gravity_well_target.Gravity == gravity_before_well && !arcane_spell_origin.arcane_gravity, "Gravity Well did not restore native gravity after expiring")
	del(gravity_well_target)
	del(earth_prison_contract)
	del(frost_nova_contract)
	del(frost_nova_target)
	del(arcane_spell_caster)
	var/has_tier_six_bag_design = FALSE
	var/has_translator_design = FALSE
	var/has_mutagen_design = FALSE
	var/has_sequencer_design = FALSE
	var/has_code_injector_design = FALSE
	var/has_power_armor_design = FALSE
	var/has_prospecting_design = FALSE
	var/has_combat_mathematics_module = FALSE
	var/has_cyber_charge_module = FALSE
	var/has_cyber_laser_module = FALSE
	var/has_overdrive_module = FALSE
	for(var/obj/technology in tech_list)
		if(technology.type == /obj/Peebag/Tier6) has_tier_six_bag_design = TRUE
		if(technology.type == /obj/items/UniversalTranslator) has_translator_design = TRUE
		if(technology.type == /obj/items/MutagenInjector) has_mutagen_design = TRUE
		if(technology.type == /obj/items/GeneticSequencer) has_sequencer_design = TRUE
		if(technology.type == /obj/items/SelfReplicatingCodeInjector) has_code_injector_design = TRUE
		if(technology.type == /obj/items/Armor/PowerArmor) has_power_armor_design = TRUE
		if(technology.type == /obj/items/ProspectingToolkit) has_prospecting_design = TRUE
		if(technology.type == /obj/Module/Cyber_Charge) has_cyber_charge_module = TRUE
		if(technology.type == /obj/Module/Laser_Beam) has_cyber_laser_module = TRUE
		if(technology.type == /obj/Module/Overdrive) has_overdrive_module = TRUE
		if(technology.type == /obj/Module/Combat_Mathematics)
			var/obj/Module/Combat_Mathematics/combat_mathematics_module = technology
			for(var/obj/module_ability in combat_mathematics_module.Abilities)
				if(module_ability.type == /obj/Buff/Preset/CombatMathematics) has_combat_mathematics_module = TRUE
	nexusSmokeAssert(has_tier_six_bag_design && has_translator_design, "Nexus training or translation technology was not registered")
	nexusSmokeAssert(has_mutagen_design && has_sequencer_design && has_code_injector_design, "Nexus Genetics or Robotics technology was not registered")
	nexusSmokeAssert(has_power_armor_design && has_prospecting_design, "expanded Nexus engineering technology was not registered")
	nexusSmokeAssert(has_combat_mathematics_module && has_cyber_charge_module && has_cyber_laser_module && has_overdrive_module, "module-exclusive combat abilities are missing a Robotics module")
	var/mob/NexusSmokeTest/language_speaker = new
	language_speaker.Race = "Saiyan"
	language_speaker.syncNexusLanguages()
	var/mob/NexusSmokeTest/language_listener = new
	language_listener.Race = "Human"
	language_listener.syncNexusLanguages()
	nexusSmokeAssert(language_speaker.spoken_language == "saiyan" && language_speaker.getKnownLanguageMastery("saiyan") == 100, "racial language initialization failed")
	var/garbled_saiyan = language_speaker.renderSpokenLanguageFor(language_listener, "Kakarot returns before sunset", allow_learning = FALSE)
	nexusSmokeAssert(garbled_saiyan != "Kakarot returns before sunset", "an untrained listener understood a foreign language")
	language_listener.known_languages["saiyan"] = 100
	nexusSmokeAssert(language_speaker.renderSpokenLanguageFor(language_listener, "Kakarot returns", allow_learning = FALSE) == "Kakarot returns", "a fluent listener could not understand a known language")
	var/obj/items/MagicCircle/smoke_circle = new(language_listener)
	language_listener.item_list += smoke_circle
	nexusSmokeAssert(language_listener.getArcaneMeditationMultiplier() == 1.5, "Magic Circle did not amplify Arcane Essence meditation")
	var/obj/items/PhilosophersStone/smoke_stone = new(language_listener)
	language_listener.item_list += smoke_stone
	nexusSmokeAssert(language_listener.getPhilosophersStoneRegenerationBonus() == 0.5, "Philosopher's Stone did not grant its regeneration bonus")
	var/obj/Peebag/MagicGoo/Tier4/smoke_goo = new
	nexusSmokeAssert(smoke_goo.training_tier == 4 && smoke_goo.training_gain_multiplier == 2.25 && smoke_goo.magic_training_equipment, "Magic Goo IV is not configured as peak magic training equipment")
	del(smoke_goo)
	del(language_listener)
	del(language_speaker)
	var/mob/NexusSmokeTest/progression_test = new
	progression_test.Experience = 25
	new /obj/Attacks/NexusMeleeTechnique/Slice(progression_test)
	progression_test.syncProgressionTrees(silent = TRUE)
	var/slice_progression_id = progression_test.getProgressionNodeIdForReward(/obj/Attacks/NexusMeleeTechnique/Slice)
	nexusSmokeAssert(progression_test.Experience == 0 && progression_test.progression_experience == 250 && progression_test.hasProgressionNode(slice_progression_id), "legacy Skill Points or learned skills were not migrated into scaled progression")
	progression_test.progression_experience = 4000
	progression_test.progression_lifetime_experience = 4000
	nexusSmokeAssert(progression_test.purchaseProgressionNode("combat_foundation_root"), "Combat Foundation gateway could not be purchased")
	nexusSmokeAssert(progression_test.purchaseProgressionNode(power_control_progression_id) && progression_test.purchaseProgressionNode(blast_progression_id) && progression_test.purchaseProgressionNode(lunge_progression_id), "tier-two Combat Foundation skills could not be purchased")
	nexusSmokeAssert(progression_test.purchaseProgressionNode(fly_progression_id) && progression_test.purchaseProgressionNode(shield_progression_id) && progression_test.purchaseProgressionNode(charge_progression_id) && progression_test.purchaseProgressionNode(shockwave_progression_id) && progression_test.purchaseProgressionNode(dash_attack_progression_id), "tier-three Combat Foundation skills could not be purchased")
	nexusSmokeAssert(progression_test.purchaseProgressionNode(zanzoken_progression_id) && progression_test.purchaseProgressionNode(custom_buff_progression_id) && progression_test.purchaseProgressionNode(beam_progression_id), "tier-four Combat Foundation skills could not be purchased")
	nexusSmokeAssert(progression_test.purchaseProgressionNode(sokidan_progression_id) && progression_test.hasExactProgressionRewardObject(/obj/Lunge) && progression_test.hasExactProgressionRewardObject(/obj/Buff) && progression_test.hasExactProgressionRewardObject(/obj/Attacks/Shockwave) && progression_test.hasExactProgressionRewardObject(/obj/Attacks/Sokidan), "Combat Foundation did not grant Shockwave or reach Sokidan with exact reward objects")
	nexusSmokeAssert(progression_test.purchaseProgressionNode("combat_buffs_root"), "combat branch gateway could not be purchased")
	var/muscle_force_id = progression_test.getProgressionNodeIdForReward(/obj/Buff/Preset/MuscleForce)
	nexusSmokeAssert(progression_test.purchaseProgressionNode(muscle_force_id) && (locate(/obj/Buff/Preset/MuscleForce) in progression_test), "progression purchase did not grant its preset buff")
	var/offensive_stance_id = progression_test.getProgressionNodeIdForReward(/obj/Buff/Preset/OffensiveStance)
	var/demonic_fury_id = progression_test.getProgressionNodeIdForReward(/obj/Buff/Preset/DemonicFury)
	nexusSmokeAssert(progression_test.purchaseProgressionNode(offensive_stance_id) && progression_test.purchaseProgressionNode(demonic_fury_id), "the offensive Buff path could not reach its capstone tier")
	nexusSmokeAssert(progression_test.purchaseProgressionNode(focus_progression_id) && progression_test.purchaseProgressionNode(defensive_stance_progression_id) && progression_test.purchaseProgressionNode(angelic_grace_progression_id), "the defensive Buff path could not reach its capstone tier")
	nexusSmokeAssert(progression_test.purchaseProgressionNode(godspeed_progression_id) && (locate(/obj/Buff/Ultimate/Godspeed) in progression_test), "the Combat/Buffs capstone did not grant Godspeed")
	nexusSmokeAssert(!progression_test.purchaseProgressionNode(high_tension_progression_id), "a character purchased more than one Ultimate Buff capstone")
	progression_test.smithing_level = 35
	nexusSmokeAssert(!progression_test.hasSmithingMaterialUnlock("bronze"), "Smithing level bypassed its progression node")
	nexusSmokeAssert(progression_test.purchaseProgressionNode("smithing_apprentice") && progression_test.purchaseProgressionNode("smithing_bronze") && progression_test.hasSmithingMaterialUnlock("bronze"), "Smithing material prerequisite chain did not unlock")
	var/datum/NexusProgressionTreeWindow/tree_navigation_test = new(progression_test, "Magic")
	var/list/divination_entries = tree_navigation_test.collectVisibleEntries()
	var/total_magic_entries = 0
	for(var/progression_node_id in progression_node_catalog)
		var/datum/ProgressionNode/magic_progression_node = progression_node_catalog[progression_node_id]
		if(magic_progression_node.category == "Magic") total_magic_entries++
	nexusSmokeAssert(tree_navigation_test.branch_filter == "Divination" && divination_entries.len > 1 && divination_entries.len < total_magic_entries, "progression navigation did not limit its initial render to one branch")
	tree_navigation_test.search_query = "Philosopher"
	var/list/searched_magic_entries = tree_navigation_test.collectVisibleEntries()
	var/found_philosophers_stone = FALSE
	for(var/datum/ProgressionNode/searched_node in searched_magic_entries)
		if(searched_node.id == "magic_philosophers_stone") found_philosophers_stone = TRUE
	nexusSmokeAssert(found_philosophers_stone && searched_magic_entries.len < total_magic_entries, "progression search did not return the matching node with a bounded result graph")
	del(tree_navigation_test)
	var/mob/NexusSmokeTest/racial_tree_owner = new
	racial_tree_owner.Race = "Kai"
	var/datum/NexusProgressionTreeWindow/racial_navigation_test = new(racial_tree_owner, "Racial")
	var/list/kai_racial_entries = racial_navigation_test.collectVisibleEntries()
	var/racial_entries_match_owner = kai_racial_entries.len > 1
	for(var/datum/ProgressionNode/racial_entry in kai_racial_entries)
		if(racial_entry.required_racial_track != "Kaioshin") racial_entries_match_owner = FALSE
	nexusSmokeAssert(racial_navigation_test.branch_filter == "Kaioshin" && racial_entries_match_owner, "Racial progression exposed another race's rank curriculum")
	nexusSmokeAssert(findtext(racial_tree_owner.getProgressionNodeLockReason(demon_hakai_node), "Daimao"), "server-side racial validation allowed a Kai to access Daimao Hakai")
	var/racial_window_html = racial_navigation_test.buildHtml()
	nexusSmokeAssert(findtext(racial_window_html, ">RACIAL</a>") && findtext(racial_window_html, "KAIOSHIN"), "the Racial tab or owner-specific branch is missing from Progression")
	del(racial_navigation_test)
	del(racial_tree_owner)
	var/datum/NexusProgressionTreeWindow/combat_navigation_test = new(progression_test, "Combat")
	nexusSmokeAssert(combat_navigation_test.branch_filter == "Foundation", "Combat progression does not open on the universal Foundation branch")
	var/combat_graph_html = combat_navigation_test.buildGraph()
	nexusSmokeAssert(!findtext(combat_graph_html, "<rect class='joint") && findtext(combat_graph_html, " C ") && !findtext(combat_graph_html, " V "), "Combat progression graph did not adopt smooth direct connections")
	nexusSmokeAssert(findtext(combat_graph_html, "data-from='combat_foundation_root' data-to='[power_control_progression_id]'"), "Combat progression lost the semantic Foundation-to-Power Control connection")
	combat_navigation_test.branch_filter = "Buffs"
	var/list/buffs_graph_entries = combat_navigation_test.collectVisibleEntries()
	var/list/buffs_graph_layout = combat_navigation_test.buildGraphLayout(buffs_graph_entries)
	var/list/buffs_graph_positions = buffs_graph_layout["positions"]
	var/list/buffs_branch_tops = buffs_graph_layout["branch_tops"]
	var/list/buffs_branch_heights = buffs_graph_layout["branch_heights"]
	var/all_progression_nodes_inside_lanes = TRUE
	for(var/datum/ProgressionNode/buffs_graph_node in buffs_graph_entries)
		var/list/buffs_graph_position = buffs_graph_positions[buffs_graph_node.id]
		var/branch_top = buffs_branch_tops[buffs_graph_node.branch]
		var/branch_bottom = branch_top + buffs_branch_heights[buffs_graph_node.branch]
		if(!islist(buffs_graph_position) || buffs_graph_position["y"] < branch_top || buffs_graph_position["y"] + 122 > branch_bottom)
			all_progression_nodes_inside_lanes = FALSE
	nexusSmokeAssert(all_progression_nodes_inside_lanes, "progression placed a root or prerequisite outside its declared branch lane")
	combat_navigation_test.branch_filter = "Ki"
	var/list/ki_graph_entries = combat_navigation_test.collectVisibleEntries()
	var/kienzan_progression_id = getProgressionNodeIdForType(/obj/Attacks/Kienzan)
	var/big_bang_progression_id = getProgressionNodeIdForType(/obj/Attacks/Big_Bang_Attack)
	var/datum/ProgressionNode/big_bang_progression_node = progression_node_catalog[big_bang_progression_id]
	var/ki_graph_html = combat_navigation_test.buildGraph()
	nexusSmokeAssert(big_bang_progression_node && big_bang_progression_node.prerequisites.len == 1 && big_bang_progression_node.prerequisites[1] == kienzan_progression_id, "Big Bang Attack has prerequisites other than Kienzan")
	nexusSmokeAssert(findtext(ki_graph_html, "data-from='[kienzan_progression_id]' data-to='[big_bang_progression_id]'") && findtext(ki_graph_html, " C ") && findtext(ki_graph_html, "REQ: KIENZAN") && findtext(ki_graph_html, "node-cost hud-panel'>100 XP"), "Ki graph does not visibly identify the exact Big Bang Attack connection, prerequisite and scaled XP cost")
	for(var/datum/ProgressionNode/ki_tier_two_node in ki_graph_entries)
		if(ki_tier_two_node.branch == "Ki" && ki_tier_two_node.tier == 2 && ki_tier_two_node.id != kienzan_progression_id)
			nexusSmokeAssert(!findtext(ki_graph_html, "data-from='[ki_tier_two_node.id]' data-to='[big_bang_progression_id]'"), "an unrelated Ki tier-two node visually connects to Big Bang Attack")
	nexusSmokeAssert(!findtext(ki_graph_html, "data-route-x=") && !findtext(ki_graph_html, "class='joint"), "Ki graph still renders the ambiguous orthogonal route channels or square connector joints")
	combat_navigation_test.branch_filter = "Foundation"
	var/combat_window_html = combat_navigation_test.buildHtml()
	nexusSmokeAssert(findtext(combat_window_html, "body class='nexus-hud'") && findtext(combat_window_html, "header hud-frame") && findtext(combat_window_html, "hud-sprite") && findtext(combat_window_html, "#c6a15c") && findtext(combat_window_html, "CLICK + DRAG TO MOVE") && findtext(combat_window_html, "nexusInitGraphPan") && findtext(combat_window_html, "nexusFocusGraphConnections") && findtext(combat_window_html, "overflow:hidden;cursor:move"), "Progression did not adopt the native bronze HUD components, real-sprite frame, connection focus or draggable canvas")
	del(combat_navigation_test)
	var/datum/NexusProgressionTreeWindow/milestone_list_test = new(progression_test, "Milestones")
	var/list/all_milestone_entries = milestone_list_test.collectVisibleEntries()
	var/milestone_list_html = milestone_list_test.buildGraph()
	var/milestone_navigation_html = milestone_list_test.buildTreeNavigation()
	nexusSmokeAssert(all_milestone_entries.len == milestone_catalog.len && findtext(milestone_list_html, "milestone-list") && !findtext(milestone_list_html, "connections") && !findtext(milestone_list_html, "milestone-branch") && !findtext(milestone_navigation_html, "branch-tab"), "Milestones are not rendered as one uncategorized independent list")
	del(milestone_list_test)
	var/datum/NexusBuildWindow/build_catalog_test = new(progression_test)
	var/list/floor_blueprints = build_catalog_test.getBlueprints(FALSE)
	var/build_category_isolated = floor_blueprints.len > 0
	for(var/obj/Build/floor_blueprint in floor_blueprints)
		if(floor_blueprint.build_category != BUILD_FLOOR) build_category_isolated = FALSE
	nexusSmokeAssert(build_catalog_test.category == "Floors" && build_category_isolated, "the M-key build catalog did not default to an isolated Floors category")
	var/obj/Build/first_floor_blueprint = floor_blueprints[1]
	build_catalog_test.search_query = lowertext(build_catalog_test.getDisplayName(first_floor_blueprint))
	nexusSmokeAssert(first_floor_blueprint in build_catalog_test.getBlueprints(), "build catalog search hid an exact blueprint match")
	del(build_catalog_test)
	del(progression_test)
	var/mob/NexusSmokeTest/ultimate_migration_test = new
	ultimate_migration_test.milestone_progression_version = 1
	ultimate_migration_test.milestones_owned["ub_bushido"] = 1
	ultimate_migration_test.syncMilestoneProgression(silent = TRUE)
	var/bushido_progression_id = ultimate_migration_test.getProgressionNodeIdForReward(/obj/Buff/Ultimate/Bushido)
	nexusSmokeAssert(ultimate_migration_test.hasProgressionNode(bushido_progression_id) && (locate(/obj/Buff/Ultimate/Bushido) in ultimate_migration_test), "legacy Ultimate Buff milestones were not migrated to Combat/Buffs capstones")
	del(ultimate_migration_test)
	initializeForgedEquipmentCatalogs()
	nexusSmokeAssert(forged_material_catalog.len == 8 && forged_material_catalog["normal"] && forged_material_catalog["masterwork"] && forged_material_catalog["auracite"], "Nexus material catalog is incomplete or Normal is not its base tier")
	nexusSmokeAssert(forged_material_catalog["silver"]:critical_chance_bonus == 4 && forged_material_catalog["silver"]:critical_resistance == 4 && forged_material_catalog["auracite"]:critical_chance_bonus == 7 && forged_material_catalog["auracite"]:critical_resistance == 8, "Silver or Auracite lost its authored critical chance or armor resistance")
	nexusSmokeAssert(forged_weapon_style_catalog.len == 29 && forged_weapon_style_catalog["hammer"] && forged_weapon_style_catalog["mage_staff"] && forged_weapon_style_catalog["kingdom_key"], "Nexus weapon catalog or legacy DU appearances are incomplete")
	nexusSmokeAssert(forged_armor_style_catalog.len == 27 && forged_armor_style_catalog["bardock"] && forged_armor_style_catalog["phoenix"], "Nexus armor catalog or legacy DU appearances are incomplete")
	nexusSmokeAssert(forged_glove_style_catalog.len == 4 && forged_glove_style_catalog["classic"] && forged_glove_style_catalog["boxing"], "Nexus unarmed glove catalog is incomplete")
	nexusSmokeAssert(forged_mask_style_catalog.len == 3 && forged_mask_style_catalog["normal"] && forged_mask_style_catalog["ninja"], "Nexus Ki mask catalog is incomplete")
	var/mob/NexusSmokeTest/profession_test = new
	profession_test.gainProfessionExperience("Mining", getProfessionExperienceForLevel(6), "Smoke test")
	nexusSmokeAssert(profession_test.mining_level == 6, "Mining experience did not advance profession levels")
	profession_test.milestones_owned["mining_expert"] = 1
	nexusSmokeAssertNear(profession_test.getMiningYieldMultiplier(), 1.65, 0.001, "Mining Expert did not increase mining yield")
	var/obj/WorldOreDeposit/ore_deposit_test = new
	ore_deposit_test.configureOre(/obj/items/Ore/Auracite)
	nexusSmokeAssert(world_ore_target_count == 600 && world_ore_regular_deposit_min == 12 && world_ore_regular_deposit_max == 20 && world_ore_base_extraction_yield == 5 && world_ore_generation_interval == 1800, "world ore abundance tuning diverged from its configured contract")
	nexusSmokeAssert(getWorldOreAbundanceMultiplier(/obj/items/Ore/Copper) == 3 && getWorldOreAbundanceMultiplier(/obj/items/Ore/Tin) == 2.5 && getWorldOreAbundanceMultiplier(/obj/items/Ore/Iron) == 2 && getWorldOreAbundanceMultiplier(/obj/items/Ore/Silver) == 1.5 && getWorldOreAbundanceMultiplier(/obj/items/Ore/Mythril) == 1.25 && getWorldOreAbundanceMultiplier(/obj/items/Ore/Auracite) == 1, "basic ore veins do not retain their tiered abundance advantage")
	nexusSmokeAssert(getMiningExperienceForOreYield(7) == 7, "Mining XP is no longer proportional to ore extracted")
	nexusSmokeAssert(getIncidentalMiningOreYield(1) == 3 && getIncidentalMiningOreYield(16) == 12 && getIncidentalMiningOreYield(100) == 20 && getIncidentalMiningOreYield(1000) == 20, "cave-digging tools no longer convert extraction strength into bounded ore quantity")
	nexusSmokeAssert(ore_deposit_test.required_mining_level == 30 && ore_deposit_test.ore_type == /obj/items/Ore/Auracite && ore_deposit_test.icon == 'RTAuraciteOre.dmi' && ore_deposit_test.ore_amount >= world_ore_regular_deposit_min && ore_deposit_test.ore_amount <= world_ore_regular_deposit_max, "world Auracite deposits are not configured, abundant or level-gated")
	var/copper_deposit_amount = getWorldOreDepositAmount(/obj/items/Ore/Copper)
	nexusSmokeAssert(copper_deposit_amount >= 36 && copper_deposit_amount <= 60, "Copper veins lost their expanded basic-ore capacity")
	var/obj/WorldOreDeposit/heart_deposit_test = new
	heart_deposit_test.configureOre(/obj/items/Ore/HeartOfTheMountain)
	nexusSmokeAssert(heart_deposit_test.ore_amount == world_ore_heart_deposit_amount && world_ore_heart_deposit_amount == 3, "Heart of the Mountain deposits lost their increased fixed yield")
	del(heart_deposit_test)
	del(ore_deposit_test)
	profession_test.milestones_owned["master_blacksmith"] = 1
	var/obj/items/Sword/Forged/smoke_sword = new(profession_test)
	profession_test.applyMasterBlacksmithQuality(smoke_sword)
	nexusSmokeAssertNear(smoke_sword.Damage, 1.155, 0.001, "Master Blacksmith did not improve Normal forged equipment")
	nexusSmokeAssert(findtext(smoke_sword.name, "Masterwork") == 1 && findtext(smoke_sword.desc, "Masterwork enchantment"), "an enchanted forged item does not visibly expose its applied quality")
	var/obj/items/Sword/Forged/rebellion_skin_test = new(profession_test)
	rebellion_skin_test.forged_style_id = "rebellion"
	rebellion_skin_test.refreshForgedWeapon()
	nexusSmokeAssert(rebellion_skin_test.name == "Normal Sword" && rebellion_skin_test.icon == 'ItemSword1.dmi' && rebellion_skin_test.forged_attack_bp_bonus == 0.06, "Rebellion is not a cosmetic skin on a Normal material-named weapon")
	var/obj/items/Sword/Forged/ScienceHammer/normal_hammer_test = new(profession_test)
	nexusSmokeAssert(normal_hammer_test.name == "Normal War Hammer" && normal_hammer_test.forged_material_id == "normal" && normal_hammer_test.icon == 'RTHammer.dmi', "Science Hammer is not a Normal upgradeable forged weapon")
	var/obj/items/Sword/Forged/mythril_weapon_test = new(profession_test)
	mythril_weapon_test.forged_material_id = "mythril"
	mythril_weapon_test.forged_style_id = "rebellion"
	mythril_weapon_test.refreshForgedWeapon()
	nexusSmokeAssert(mythril_weapon_test.name == "Mythril Sword" && mythril_weapon_test.forged_attack_bp_bonus == 0.32 && mythril_weapon_test.Damage == 1.52, "Mythril weapon modules did not determine the forged weapon statistics")
	var/obj/items/Armor/Forged/mythril_armor_test = new(profession_test)
	mythril_armor_test.forged_material_id = "mythril"
	mythril_armor_test.forged_style_id = "bardock"
	mythril_armor_test.refreshForgedArmor()
	nexusSmokeAssert(mythril_armor_test.name == "Mythril Armor" && mythril_armor_test.heaviness == 1.04 && mythril_armor_test.forged_defense_bp_bonus == 0.2, "Mythril armor did not retain its lightweight defensive module")
	var/obj/items/Gloves/Forged/mythril_gloves_test = new(profession_test)
	mythril_gloves_test.forged_material_id = "mythril"
	mythril_gloves_test.forged_style_id = "hero"
	mythril_gloves_test.refreshForgedGloves()
	nexusSmokeAssert(mythril_gloves_test.name == "Mythril Gloves" && mythril_gloves_test.icon == 'OpmGloves.dmi' && mythril_gloves_test.forged_attack_bp_bonus == 0.32, "Mythril gloves did not retain their modular unarmed statistics and appearance")
	var/obj/items/Mask/Forged/mythril_mask_test = new(profession_test)
	mythril_mask_test.forged_material_id = "mythril"
	mythril_mask_test.forged_style_id = "ninja"
	mythril_mask_test.refreshForgedMask()
	nexusSmokeAssert(mythril_mask_test.name == "Mythril Mask" && mythril_mask_test.icon == 'ClothesNinjaMask.dmi' && mythril_mask_test.forged_ki_damage_multiplier == 1.24 && mythril_mask_test.forged_ki_bp_bonus == 0.32, "Mythril mask did not retain its modular Ki damage, blast BP and appearance")
	var/obj/items/Sword/Forged/silver_critical_weapon_test = new(profession_test)
	silver_critical_weapon_test.forged_material_id = "silver"
	silver_critical_weapon_test.refreshForgedWeapon()
	silver_critical_weapon_test.suffix = "Equipped"
	profession_test.equipped_sword = silver_critical_weapon_test
	nexusSmokeAssert(profession_test.getForgedCriticalChanceBonus() == 4, "an equipped Silver weapon does not increase critical chance")
	silver_critical_weapon_test.suffix = null
	profession_test.equipped_sword = null
	var/obj/items/Gloves/Forged/auracite_critical_gloves_test = new(profession_test)
	auracite_critical_gloves_test.forged_material_id = "auracite"
	auracite_critical_gloves_test.refreshForgedGloves()
	auracite_critical_gloves_test.suffix = "Equipped"
	profession_test.equipped_gloves = auracite_critical_gloves_test
	nexusSmokeAssert(profession_test.getForgedCriticalChanceBonus() == 7, "equipped Auracite gloves do not increase critical chance")
	var/obj/items/Armor/Forged/auracite_critical_armor_test = new(profession_test)
	auracite_critical_armor_test.forged_material_id = "auracite"
	auracite_critical_armor_test.refreshForgedArmor()
	auracite_critical_armor_test.suffix = "Equipped"
	profession_test.armor_obj = auracite_critical_armor_test
	nexusSmokeAssert(profession_test.getForgedArmorCriticalResistance() == 8, "equipped Auracite armor does not resist critical chance")
	auracite_critical_gloves_test.suffix = null
	profession_test.equipped_gloves = null
	auracite_critical_armor_test.suffix = null
	profession_test.armor_obj = null
	profession_test.BP = 1000
	mythril_weapon_test.suffix = "Equipped"
	profession_test.equipped_sword = mythril_weapon_test
	nexusSmokeAssertNear(profession_test.getForgedWeaponAttackBP(), 1320, 0.001, "forged weapon BP was not added to melee attack power")
	mythril_armor_test.suffix = "Equipped"
	profession_test.armor_obj = mythril_armor_test
	nexusSmokeAssertNear(profession_test.getForgedArmorEnduranceBP(), 1200, 0.001, "forged armor BP was not added to endurance defense")
	mythril_gloves_test.suffix = "Equipped"
	profession_test.equipped_gloves = mythril_gloves_test
	nexusSmokeAssertNear(profession_test.getForgedUnarmedAttackBP(), 1320, 0.001, "forged gloves BP was not added to unarmed attack power")
	mythril_mask_test.suffix = "Equipped"
	profession_test.equipped_forged_mask = mythril_mask_test
	nexusSmokeAssertNear(profession_test.getForgedKiAttackBP(), 1320, 0.001, "forged mask BP was not added to blast attack power")
	nexusSmokeAssertNear(profession_test.getForgedKiDamageMultiplier(), 1.24, 0.001, "forged mask did not increase Ki damage")
	var/obj/Blast/mask_blast_test = new
	mask_blast_test.setStats(profession_test, 2)
	nexusSmokeAssertNear(mask_blast_test.BP, 1320, 0.001, "a Ki blast did not capture the equipped mask's BP reinforcement")
	nexusSmokeAssertNear(mask_blast_test.percent_damage, 2 * ki_power * 1.24, 0.001, "a Ki blast did not capture the equipped mask's Ki damage multiplier")
	var/obj/Blast/mask_bullet_test = new
	mask_bullet_test.setStats(profession_test, 2, bullet = TRUE)
	nexusSmokeAssertNear(mask_bullet_test.BP, 1000, 0.001, "a physical bullet incorrectly received forged mask BP")
	del(mask_blast_test)
	del(mask_bullet_test)
	var/list/normal_upgrades = getForgedMaterialUpgradeOptions("normal")
	var/list/copper_upgrades = getForgedMaterialUpgradeOptions("copper")
	var/list/bronze_upgrades = getForgedMaterialUpgradeOptions("bronze")
	nexusSmokeAssert(normal_upgrades.len == 1 && normal_upgrades[1]:id == "copper" && copper_upgrades.len == 1 && bronze_upgrades.len == 2, "Normal does not upgrade to Copper before the Nexus material branches")
	initializeNexusAdminActions()
	nexusSmokeAssert(nexus_admin_action_catalog.len >= 20 && nexus_admin_action_catalog["give_item"] && nexus_admin_action_catalog["reward"] && nexus_admin_action_catalog["legacy_command"], "Nexus Admin Panel command catalog is incomplete")
	nexusSmokeAssert(/mob/AdminEssentials/verb/managePlayer in typesof(/mob/AdminEssentials/verb), "contextual Manage Player command is missing")
	var/mob/NexusSmokeTest/admin_verb_test = new
	admin_verb_test.grantAdminVerbsForLevel(4)
	nexusSmokeAssert((/mob/Admin1/verb/teleport in admin_verb_test.verbs) && (/mob/Admin2/verb/giveItem in admin_verb_test.verbs) && (/mob/Admin3/verb/edit in admin_verb_test.verbs) && (/mob/Admin4/verb/serverControlPanel in admin_verb_test.verbs) && (/mob/Admin4/verb/pwipe in admin_verb_test.verbs), "legacy admin verbs, including pwipe, are not retained cumulatively for CMD and the Admin tab")
	del(admin_verb_test)
	var/list/server_setting_categories = getNexusServerSettingCategories()
	nexusSmokeAssert(server_setting_categories.len == 6 && server_setting_categories["Progression"] == /upForm/admin_gains && server_setting_categories["Science"] == /upForm/admin_science, "HUD Server Panel categories are incomplete")
	var/upForm/headless_server_settings = new /upForm/admin_gains(null, profession_test, list(), TRUE)
	var/list/headless_progression_settings = headless_server_settings.form_vars["admin"]
	nexusSmokeAssert(headless_server_settings.headless_mode && islist(headless_progression_settings) && headless_progression_settings.len >= 30, "HUD Server Panel could not load headless legacy setting bindings")
	nexusSmokeAssert(("adapt_mod" in headless_progression_settings) && getNexusServerSettingNameDisplay("adapt_mod") == "adapt_mod", "HUD Server Panel rows do not preserve their editable variable names")
	del(headless_server_settings)
	var/list/inspector_list_test = list(1000, list("nested"), "mode" = "test")
	nexusSmokeAssert(findtext(getNexusAdminVariableDisplay(inspector_list_test), "3 entries"), "Admin Inspector could not preview mixed list values")
	nexusSmokeAssert(!profession_test.canAccessTechnology(profession_test) && !profession_test.canAccessTechnology(profession_test.loc), "Technology access accepted a non-object click target")
	nexusSmokeAssert(!profession_test.isTechnologyReferenceClick(smoke_sword), "An inventory item was intercepted as a Technology catalog reference")
	profession_test.player_tech_level = 1
	var/obj/items/Sword/Forged/Science/science_weapon_reference_test = new(profession_test)
	science_weapon_reference_test.referenceObject = TRUE
	nexusSmokeAssert(profession_test.isTechnologyReferenceClick(science_weapon_reference_test), "A modular Science weapon reference did not receive its specialized click handling")
	del(science_weapon_reference_test)
	var/datum/NexusCharacterSheetWindow/character_sheet_contract = new(profession_test)
	character_sheet_contract.recordHeartbeat(84)
	nexusSmokeAssert(!character_sheet_contract.hasLiveOwner() && !character_sheet_contract.isBrowserOpen(), "a detached Character sheet can keep its live refresh lifecycle running")
	profession_test.milestones_owned = list("iron_will" = 1)
	var/obj/items/Clothes/ShortSleeveShirt/character_clothing_test = new(profession_test)
	character_clothing_test.name = "Smoke Test Shirt"
	character_clothing_test.suffix = "Equipped"
	var/character_sheet_html = profession_test.buildCharacterSheetHtml("portrait.png", character_sheet_contract, character_sheet_contract.last_scroll_y)
	nexusSmokeAssert(findtext(character_sheet_html, "Player dossier") && findtext(character_sheet_html, "Mining") && findtext(character_sheet_html, "Milestones") && findtext(character_sheet_html, "Mask") && !findtext(character_sheet_html, "Clothing & Equipment") && !findtext(character_sheet_html, "Smoke Test Shirt") && !findtext(character_sheet_html, "panel-title-icon") && !findtext(character_sheet_html, "card-pixel-icon") && findtext(character_sheet_html, "body class='nexus-hud'") && findtext(character_sheet_html, "topbar hud-frame") && findtext(character_sheet_html, "hud-sprite") && findtext(character_sheet_html, "#c6a15c"), "detailed Character sheet is incomplete or diverges from the native bronze HUD component contract")
	nexusSmokeAssert(findtext(character_sheet_html, "Iron Will") && !findtext(character_sheet_html, "Will of Fire"), "Character sheet did not limit Milestones to ranks owned by the character")
	nexusSmokeAssert(!findtext(character_sheet_html, "LIVE / 1s") && findtext(character_sheet_html, "action:'heartbeat'") && findtext(character_sheet_html, "action=refresh_character_sheet") && findtext(character_sheet_html, "onclick='nexusStoreLiveScroll()'") && findtext(character_sheet_html, "nexusLiveRestoreScrollY=84") && findtext(character_sheet_html, "sessionStorage") && findtext(character_sheet_html, "nexusLiveOnScroll") && findtext(character_sheet_html, ".skill-list,.milestone-list{max-height:none;overflow:visible}"), "Character sheet exposes refresh internals or does not preserve scroll for its manual refresh")
	profession_test.icon = 'BaseHumanPale.dmi'
	profession_test.rebuildPlayerAppearance("Character portrait test")
	var/icon/base_character_portrait = icon(profession_test.icon, profession_test.icon_state, SOUTH)
	var/icon/dressed_character_portrait = getNexusCharacterPortraitIcon(profession_test, SOUTH)
	var/portrait_includes_overlays = base_character_portrait.Width() != dressed_character_portrait.Width() || base_character_portrait.Height() != dressed_character_portrait.Height()
	if(!portrait_includes_overlays)
		for(var/portrait_x in 1 to base_character_portrait.Width())
			for(var/portrait_y in 1 to base_character_portrait.Height())
				if(base_character_portrait.GetPixel(portrait_x, portrait_y) != dressed_character_portrait.GetPixel(portrait_x, portrait_y)) portrait_includes_overlays = TRUE
	nexusSmokeAssert(portrait_includes_overlays, "Character portrait exported the naked base icon instead of composing equipped clothing overlays")
	del(character_sheet_contract)
	del(profession_test)
	var/mob/NexusSmokeTest/technology_progression_test = new
	technology_progression_test.Knowledge = 701
	technology_progression_test.syncTechnologyProgression(silent = TRUE)
	nexusSmokeAssert(technology_progression_test.player_tech_level == 5, "Knowledge migration did not derive Technology Level 5")
	nexusSmokeAssert(technology_progression_test.getTechnologyPathSlots() == 1, "Technology Level 5 did not award a specialization slot")
	nexusSmokeAssert(getTechnologyCraftExperienceForLevel(1) == 5 && getTechnologyCraftExperienceForLevel(4) == 29 && getTechnologyCraftExperienceForLevel(7) == 100, "Science crafting XP no longer follows the target crafts-per-level curve")
	var/knowledge_before_magic = technology_progression_test.Knowledge
	technology_progression_test.magic_experience = magic_level_thresholds[magic_level_thresholds.len]
	technology_progression_test.syncMagicProgression(silent = TRUE)
	nexusSmokeAssert(technology_progression_test.magic_level == magic_level_thresholds.len && magic_research_catalog.len >= 18, "Magic research did not reach or register its complete tree")
	nexusSmokeAssert((locate(/obj/Attacks/Explosion) in technology_progression_test) && technology_progression_test.Knowledge == knowledge_before_magic, "Magic progression failed to grant its capstone or modified Knowledge")
	del(technology_progression_test)
	del(milestone_test)
	del(rp_combat_test)
	var/list/zanzoken_verbs = list(\
		/obj/Zanzoken/verb/zanzokenNorth,\
		/obj/Zanzoken/verb/zanzokenNortheast,\
		/obj/Zanzoken/verb/zanzokenEast,\
		/obj/Zanzoken/verb/zanzokenSoutheast,\
		/obj/Zanzoken/verb/zanzokenSouth,\
		/obj/Zanzoken/verb/zanzokenSouthwest,\
		/obj/Zanzoken/verb/zanzokenWest,\
		/obj/Zanzoken/verb/zanzokenNorthwest)
	nexusSmokeAssert(zanzoken_verbs.len == 8, "Zanzoken does not expose all eight directional verbs")
	var/mob/NexusSmokeTest/warp_player = new
	warp_player.BP = 100
	warp_player.Pow = 100
	var/obj/Blast/owner_immune_blast = new
	owner_immune_blast.Owner = warp_player
	owner_immune_blast.owner_immune = 1
	owner_immune_blast.deflected = 1
	owner_immune_blast.projectile_creation_time = world.time - 100
	nexusSmokeAssert(owner_immune_blast.BlastMobCross(warp_player) == 1 && warp_player.Health == initial(warp_player.Health), "guided blast owner immunity failed after reflection")
	del(owner_immune_blast)
	nexusSmokeAssert(warp_player.armStretchRangeTiles(500) == 16, "stretchy-arm pixel range is not converted to tiles")
	nexusSmokeAssert(tapwarp_stam_drain == 5, "Flash Step and directional Zanzoken no longer share their stamina cost")
	for(var/warp_offset in 0 to 6)
		new /turf/NexusSmokeTest(locate(445 - warp_offset, 3, 2))
	var/turf/warp_start = locate(445, 3, 2)
	nexusSmokeAssert(warp_start, "directional Zanzoken smoke test turf is missing")
	warp_player.loc = warp_start
	initializeNexusHotkeyActionRegistry()
	nexusSmokeAssert(nexus_hotkey_action_registry.len == 18, "directional movement, Cycle Target or Toggle Walk hotkey action registry is incomplete")
	var/datum/NexusHotkeyAction/zanzoken_action = getNexusHotkeyAction("zanzoken_north")
	var/datum/NexusHotkeyAction/short_dash_directional_action = getNexusHotkeyAction("short_dash_north")
	var/datum/NexusHotkeyAction/cycle_target_action = getNexusHotkeyAction("cycle_target")
	var/datum/NexusHotkeyAction/toggle_walk_action = getNexusHotkeyAction("toggle_walk")
	nexusSmokeAssert(!warp_player.hasZanzokenSkill() && !zanzoken_action.isAvailable(warp_player), "Zanzoken action is available without its skill")
	nexusSmokeAssert(short_dash_directional_action && short_dash_directional_action.isAvailable(warp_player) && short_dash_directional_action.hotbar_type == "Defensive", "directional Short Dash is not a universal defensive hotkey action")
	nexusSmokeAssert(cycle_target_action && cycle_target_action.isAvailable(warp_player) && cycle_target_action.hotbar_type == "Targeting", "Cycle Target is not exposed as a universal targeting hotkey action")
	nexusSmokeAssert(toggle_walk_action && toggle_walk_action.isAvailable(warp_player) && toggle_walk_action.hotbar_type == "Movement", "Toggle Walk is not exposed as a universal movement hotkey action")
	nexusSmokeAssert(toggle_walk_action.execute(warp_player) && warp_player.walking_mode && toggle_walk_action.execute(warp_player) && !warp_player.walking_mode, "Toggle Walk hotkey action did not switch walking mode in both directions")
	var/datum/NexusHotkeyEditor/empty_hotkey_editor = new(warp_player)
	var/empty_hotkey_html = warp_player.buildNexusHotkeyEditorHtml(empty_hotkey_editor)
	nexusSmokeAssert(!findtext(empty_hotkey_html, "Zanzoken: North"), "hotkey editor lists Zanzoken without its skill")
	nexusSmokeAssert(findtext(empty_hotkey_html, "Short Dash: North") && findtext(empty_hotkey_html, "Short Dash: Northwest") && findtext(empty_hotkey_html, "Cycle Target") && findtext(empty_hotkey_html, "Toggle Walk"), "hotkey editor does not expose all universal movement and targeting actions")
	nexusSmokeAssert(findtext(empty_hotkey_html, "XKB keyboard layout") && findtext(empty_hotkey_html, "us(dvorak)") && findtext(empty_hotkey_html, "double tap"), "hotkey editor is missing XKB layouts or double-tap controls")
	nexusSmokeAssert(findtext(empty_hotkey_html, "class='navigation'") && findtext(empty_hotkey_html, "&uarr;") && findtext(empty_hotkey_html, "page_up") && findtext(empty_hotkey_html, "min-width:1380px"), "hotkey editor is missing its full-size navigation and arrow-key block")
	var/obj/Zanzoken/zanzoken_skill = new(warp_player)
	nexusSmokeAssert(warp_player.getZanzokenSkill() == zanzoken_skill && zanzoken_action.isAvailable(warp_player), "owned Zanzoken was not activated")
	nexusSmokeAssert(/obj/Zanzoken/verb/flashStep in zanzoken_skill.verbs, "Flash Step is not exposed by the learnable Zanzoken skill")
	for(var/zanzoken_verb in zanzoken_verbs)
		nexusSmokeAssert(zanzoken_verb in zanzoken_skill.verbs, "owned Zanzoken is missing a directional verb")
	warp_player.nexus_hotkey_bindings["CTRL+Numpad7"] = list("kind" = "action", "action id" = "zanzoken_north")
	warp_player.nexus_hotkey_bindings["ALT+Numpad9"] = list("kind" = "action", "action id" = "short_dash_north")
	nexusSmokeAssert(warp_player.resolveNexusHotkeyBinding("CTRL+Numpad7") == zanzoken_action, "Zanzoken directional action could not be bound")
	nexusSmokeAssert(warp_player.resolveNexusHotkeyBinding("ALT+Numpad9") == short_dash_directional_action, "Short Dash directional action could not be rebound independently of movement keys")
	nexusSmokeAssert(canonicalNexusHotkey("Numpad7", TRUE, TRUE, TRUE) == "CTRL+SHIFT+ALT+Numpad7", "modifier or numpad hotkey canonicalization is invalid")
	nexusSmokeAssert(canonicalNexusHotkey("Space", tap_count = 2) == "DOUBLE:Space" && getNexusHotkeyBase("DOUBLE:CTRL+Space") == "Space", "double-tap hotkey canonicalization is invalid")
	nexusSmokeAssert(canonicalNexusHotkey("North") == "North" && getNexusUnixHotkeyName("North") == "up", "arrow keys are not valid Unix/XKB hotkeys")
	var/ctrl_north_down_command = getNexusHotkeyDownMacroCommand("CTRL+North", "North")
	var/north_up_command = getNexusHotkeyUpMacroCommand("North")
	nexusSmokeAssert(findtext(ctrl_north_down_command, "KeyDown \"north\"") && findtext(ctrl_north_down_command, "nexusHotkeyDown \"CTRL+North\" \"North\"") && findtext(north_up_command, "KeyUp \"north\"") && findtext(north_up_command, "nexusHotkeyUp \"North\""), "bound arrow macros no longer preserve movement and their hotkey action together")
	nexusSmokeAssert(normalizeNexusMacroInputKey("north") == "north" && normalizeNexusMacroInputKey("Numpad9") == "Numpad9" && !normalizeNexusMacroInputKey("NORTH") && !normalizeNexusMacroInputKey("A;world-reboot") && !normalizeNexusMacroInputKey("12345678901234567"), "movement macro input is not governed by an exact bounded allowlist")
	var/mob/NexusSmokeTest/macro_guard_test = new
	var/accepted_macro_events = 0
	for(var/macro_event_index = 1, macro_event_index <= NEXUS_MACRO_EVENT_LIMIT, macro_event_index++)
		if(macro_guard_test.acceptNexusMacroInput("A", 100)) accepted_macro_events++
	nexusSmokeAssert(accepted_macro_events == NEXUS_MACRO_EVENT_LIMIT && !macro_guard_test.acceptNexusMacroInput("A", 100) && macro_guard_test.nexus_macro_input_blocked_until == 100 + NEXUS_MACRO_EVENT_WINDOW, "movement macro event burst limit can be bypassed")
	nexusSmokeAssert(macro_guard_test.acceptNexusMacroInput("A", 100 + NEXUS_MACRO_EVENT_WINDOW), "movement macro rate limit does not recover after its bounded window")
	macro_guard_test.keys_down = list("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "malicious-key")
	macro_guard_test.sanitizeNexusHeldMacroKeys()
	nexusSmokeAssert(macro_guard_test.keys_down.len == NEXUS_MACRO_HELD_KEY_CAP && !("Q" in macro_guard_test.keys_down) && !("malicious-key" in macro_guard_test.keys_down), "held movement macro state is unbounded or retains rejected keys")
	del(macro_guard_test)
	nexusSmokeAssert(getNexusHotkeyDownMacroCommand("CTRL+A", "A") == "nexusHotkeyDown \"CTRL+A\" \"A\"", "Ctrl hotkey macro arguments are not safely quoted")
	nexusSmokeAssert(getNexusUnixHotkeyName("DOUBLE:Space") == "space + space" && getNexusUnixHotkeyName("CTRL+Numpad1") == "ctrl_l + kp_1", "Unix/XKB hotkey labels are invalid")
	nexusSmokeAssert(normalizeNexusKeyboardLayout("FR") == "fr" && normalizeNexusKeyboardLayout("unsupported") == "us", "XKB keyboard layout normalization is invalid")
	var/list/french_layout_rows = getNexusKeyboardLayoutRows("fr")
	var/list/french_layout_first_row = french_layout_rows[1]
	nexusSmokeAssert(french_layout_first_row[1] == "A" && french_layout_first_row[2] == "Z", "French XKB layout does not expose an AZERTY row")
	var/obj/Manual_Attack/manual_attack_action = new(warp_player)
	manual_attack_action.hotbar_id = "nexus-smoke-action"
	var/list/manual_binding = list("kind" = "object", "object id" = manual_attack_action.hotbar_id, "object type" = manual_attack_action.type, "display name" = "Manual Attack")
	warp_player.nexus_hotkey_bindings["ALT+F3"] = manual_binding
	warp_player.nexus_hotkey_bindings["Numpad1"] = manual_binding.Copy()
	warp_player.nexus_hotkey_bindings["Space"] = manual_binding.Copy()
	var/obj/Lunge/double_tap_lunge_action = new(warp_player)
	double_tap_lunge_action.hotbar_id = "nexus-smoke-double-lunge"
	warp_player.nexus_hotkey_bindings["DOUBLE:Space"] = list("kind" = "object", "object id" = double_tap_lunge_action.hotbar_id, "object type" = double_tap_lunge_action.type, "display name" = "Lunge")
	nexusSmokeAssert(warp_player.resolveNexusHotkeyBinding("ALT+F3") == manual_attack_action, "object hotkey action did not resolve")
	nexusSmokeAssert(warp_player.resolveNexusHotkeyBinding("Numpad1") == manual_attack_action, "one action could not be assigned to multiple keys")
	var/first_space_binding = warp_player.getNexusHotkeyBindingIdForPress("Space", FALSE, 100)
	var/second_space_binding = warp_player.getNexusHotkeyBindingIdForPress("Space", FALSE, 103)
	nexusSmokeAssert(first_space_binding == "Space" && second_space_binding == "DOUBLE:Space", "single and double Space bindings are not dispatched independently")
	nexusSmokeAssert(warp_player.resolveNexusHotkeyBinding(first_space_binding) == manual_attack_action && warp_player.resolveNexusHotkeyBinding(second_space_binding) == double_tap_lunge_action, "Space and Space + Space do not resolve to their configured actions")
	nexusSmokeAssert(warp_player.getNexusHotkeyBindingIdForPress("Space", TRUE, 104) == "Space", "held-key repetition incorrectly triggered a double-tap action")
	del(zanzoken_skill)
	nexusSmokeAssert(!warp_player.hasZanzokenSkill() && !warp_player.resolveNexusHotkeyBinding("CTRL+Numpad7"), "Zanzoken binding remained active after losing the skill")
	nexusSmokeAssert(warp_player.resolveNexusHotkeyBinding("ALT+Numpad9") == short_dash_directional_action, "Short Dash binding incorrectly depends on Zanzoken ownership")
	del(manual_attack_action)
	del(double_tap_lunge_action)
	del(empty_hotkey_editor)
	var/turf/expected_warp_turf = locate(440, 3, 2)
	nexusSmokeAssert(warp_player.TapWarpToDir(WEST), "directional Zanzoken failed on a valid path")
	nexusSmokeAssert(warp_player.loc == expected_warp_turf && get_dist(warp_start, warp_player) == 5, "directional Zanzoken exceeded its five-tile limit")
	del(warp_player)
	var/mob/CombatDummy/combat_dummy = new
	combat_dummy.Health = 100
	combat_dummy.updateOverheadHealthHud()
	nexusSmokeAssert(overheadHealthColor(100) == "#46d369", "full overhead health is not green")
	combat_dummy.Health = 60
	combat_dummy.updateOverheadHealthHud()
	nexusSmokeAssert(overheadHealthColor(60) == "#f2c94c", "60 percent overhead health is not yellow")
	combat_dummy.Health = 49
	combat_dummy.updateOverheadHealthHud()
	nexusSmokeAssert(overheadHealthColor(49) == "#ef4758", "low overhead health is not red")
	var/icon/overhead_icon = getOverheadHealthIcon(49)
	var/icon/overhead_energy_icon = getOverheadVitalIcon(50, "#37cfff")
	var/icon/overhead_willpower_icon = getOverheadVitalIcon(50, "#b983ff")
	nexusSmokeAssert(overhead_icon.Width() == 32 && overhead_icon.Height() == 3, "overhead health icon has invalid dimensions")
	nexusSmokeAssert(overhead_energy_icon.Width() == 32 && overhead_energy_icon.Height() == 3 && overhead_willpower_icon.Width() == 32 && overhead_willpower_icon.Height() == 3, "overhead Energy/Willpower icons have invalid dimensions")
	nexusSmokeAssert(combat_dummy.overhead_health_hud && combat_dummy.overhead_energy_hud && combat_dummy.overhead_willpower_hud, "overhead vitals HUD is incomplete")
	nexusSmokeAssert(combat_dummy.overhead_energy_hud.pixel_y < combat_dummy.overhead_health_hud.pixel_y && combat_dummy.overhead_health_hud.pixel_y < combat_dummy.overhead_willpower_hud.pixel_y, "overhead vitals HUD is not ordered Willpower, Health, Energy from top to bottom")
	nexusSmokeAssert(combat_dummy.attackable, "combat dummy is not targetable")
	nexusSmokeAssert(text2path("/mob/verb/selectTarget") && text2path("/mob/verb/clearTarget") && text2path("/mob/verb/cycleTarget"), "player target selection verbs are missing")
	var/icon/target_marker_icon = getSelectedTargetMarkerIcon()
	nexusSmokeAssert(target_marker_icon.Width() == 32 && target_marker_icon.Height() == 32, "selected target marker has invalid dimensions")
	nexusSmokeAssert(text2path("/mob/verb/manageCombatTeam"), "combat team management verb is missing")
	var/icon/combat_team_marker_icon = getNexusCombatTeamMarkerIcon()
	nexusSmokeAssert(combat_team_marker_icon.Width() == 32 && combat_team_marker_icon.Height() == 32 && combat_team_marker_icon.GetPixel(16, 3) && !combat_team_marker_icon.GetPixel(16, 24), "combat team marker is not a compact downward arrow")
	var/mob/NexusSmokeTest/combat_team_leader = new
	combat_team_leader.name = "Team Leader"
	var/datum/CombatTeam/combat_team_contract = new(combat_team_leader)
	var/list/combat_team_contract_members = list(combat_team_leader)
	for(var/member_index = 1, member_index < NEXUS_COMBAT_TEAM_LIMIT, member_index++)
		var/mob/NexusSmokeTest/combat_team_member = new
		combat_team_member.name = "Team Member [member_index]"
		combat_team_contract_members += combat_team_member
		nexusSmokeAssert(combat_team_contract.addMember(combat_team_member, FALSE), "combat team rejected a member below its five-player limit")
	var/mob/NexusSmokeTest/combat_team_overflow_member = new
	nexusSmokeAssert(combat_team_contract.members.len == NEXUS_COMBAT_TEAM_LIMIT && !combat_team_contract.addMember(combat_team_overflow_member, FALSE), "combat team exceeded its five-player limit")
	var/mob/NexusSmokeTest/combat_team_successor = combat_team_contract.members[2]
	nexusSmokeAssert(combat_team_leader.isCombatTeammate(combat_team_successor), "combat team membership is not reciprocal")
	combat_team_contract.removeMember(combat_team_leader, null, FALSE)
	nexusSmokeAssert(combat_team_contract.leader == combat_team_successor && !combat_team_leader.combat_team, "combat team leadership did not transfer after the leader left")
	combat_team_contract.disband(combat_team_successor, FALSE)
	for(var/mob/NexusSmokeTest/combat_team_test_member in combat_team_contract_members)
		nexusSmokeAssert(!combat_team_test_member.combat_team, "disbanded combat team retained a member reference")
		del(combat_team_test_member)
	del(combat_team_overflow_member)
	var/mob/NexusSmokeTest/targeting_player = new
	var/turf/targeting_turf = locate(445, 3, 2)
	nexusSmokeAssert(targeting_turf, "targeting smoke test turf is missing")
	targeting_player.loc = targeting_turf
	combat_dummy.loc = get_step(targeting_turf, EAST)
	nexusSmokeAssert(combat_dummy.loc && combat_dummy.loc != targeting_turf, "adjacent targeting smoke test turf is missing")
	var/mob/CombatDummy/cycle_combat_dummy = new(get_step(combat_dummy.loc, EAST))
	nexusSmokeAssert(targeting_player.cycleSelectedTarget(10, FALSE) == combat_dummy && targeting_player.cycleSelectedTarget(10, FALSE) == cycle_combat_dummy && targeting_player.cycleSelectedTarget(10, FALSE) == combat_dummy, "Cycle Target does not advance through nearby targets in distance order and wrap around")
	cycle_combat_dummy.Safezone = TRUE
	targeting_player.setSelectedTarget(null, FALSE)
	nexusSmokeAssert(targeting_player.cycleSelectedTarget(10, FALSE) == combat_dummy, "Cycle Target included a protected Safezone target")
	cycle_combat_dummy.Safezone = FALSE
	targeting_player.setSelectedTarget(combat_dummy, FALSE)
	nexusSmokeAssert(targeting_player.selected_target == combat_dummy && targeting_player.Target == combat_dummy, "combat dummy selection was not recorded")
	nexusSmokeAssert(targeting_player.getSelectedTarget(require_view = FALSE) == combat_dummy, "selected combat dummy was not returned by targeting API")
	targeting_player.dir = WEST
	nexusSmokeAssert(!targeting_player.getSelectedTarget(require_view = FALSE, dir_angle = WEST, angle_limit = 30), "directional targeting ignored its angle limit")
	nexusSmokeAssert(targeting_player.selected_target == combat_dummy, "contextual angle failure cleared the selected target")
	targeting_player.dir = EAST
	nexusSmokeAssert(targeting_player.getSelectedTarget(require_view = FALSE, dir_angle = EAST, angle_limit = 30) == combat_dummy, "directional targeting rejected a target in front")
	combat_dummy.invisibility = targeting_player.see_invisible + 1
	nexusSmokeAssert(!targeting_player.getSelectedTarget(require_view = FALSE) && !targeting_player.selected_target, "invisible target remained selected")
	combat_dummy.invisibility = 0
	targeting_player.setSelectedTarget(null, FALSE)
	nexusSmokeAssert(!targeting_player.selected_target && !targeting_player.LungeTarget(), "lunge acquired a target without explicit selection")
	var/obj/Blast/targeting_blast = new
	targeting_blast.Owner = targeting_player
	targeting_blast.loc = targeting_turf
	nexusSmokeAssert(!targeting_blast.GetBlastHomingTarget(), "blast homing acquired a target without explicit selection")
	targeting_blast.Owner = null
	targeting_blast.loc = null
	del(targeting_blast)
	del(cycle_combat_dummy)
	del(targeting_player)
	nexusSmokeAssert(!combat_dummy.Savable && !combat_dummy.Savable_NPC, "combat dummy can persist into world saves")
	nexusSmokeAssert(combat_dummy.icon == 'BaseHumanPale.dmi', "combat dummy does not use a player body")
	nexusSmokeAssert(!(combat_dummy.overhead_health_hud in combat_dummy.contents) && !(combat_dummy.overhead_energy_hud in combat_dummy.contents) && !(combat_dummy.overhead_willpower_hud in combat_dummy.contents), "combat dummy HUD was added to serializable contents")
	var/savefile/dummy_hud_save = new("nexus-smoke-dummy-hud.sav")
	combat_dummy.Write(dummy_hud_save)
	nexusSmokeAssert((combat_dummy.overhead_health_hud in combat_dummy.vis_contents) && (combat_dummy.overhead_energy_hud in combat_dummy.vis_contents) && (combat_dummy.overhead_willpower_hud in combat_dummy.vis_contents), "combat dummy HUD was not restored after serialization")
	var/mob/NexusSmokeTest/hud_loaded_mob = new
	hud_loaded_mob.Read(dummy_hud_save)
	nexusSmokeAssert(!(locate(/obj/NexusHud) in hud_loaded_mob.contents), "overhead HUD leaked into serialized mob contents")
	nexusSmokeAssert(!(locate(/obj/NexusHud) in hud_loaded_mob.vis_contents), "overhead HUD leaked into serialized visual contents")
	del(hud_loaded_mob)
	combat_dummy.Health = 100
	combat_dummy.TakeDamage(12.5)
	nexusSmokeAssert(combat_dummy.Health == 87.5, "combat dummy did not receive normal combat damage")
	combat_dummy.bleed_damage = 10
	combat_dummy.TakeDamage(200)
	nexusSmokeAssert(combat_dummy.Health == 100 && !combat_dummy.KO && !combat_dummy.Dead, "combat dummy did not reset after damage-only defeat")
	nexusSmokeAssert(!combat_dummy.bleed_damage, "combat dummy retained bleed damage after defeat")
	combat_dummy.setBattlePower(2000)
	combat_dummy.setPowerup(150)
	nexusSmokeAssert(combat_dummy.base_bp == 2000 && combat_dummy.BP == 3000, "combat dummy power controller values are inconsistent")
	del(combat_dummy)
	var/mob/NexusSmokeTest/player = new
	var/mob/NexusSmokeTest/mutation_player = new
	var/mob/NexusSmokeTest/other_mutation_player = new
	mutation_player.rollCharacterMutations("Anomaly")
	nexusSmokeAssert(mutation_player.character_mutations.len == CHARACTER_MUTATIONS.len, "Anomaly mutation did not affect every stat")
	nexusSmokeAssert(mutation_player.mutation_rarity == "Anomaly", "forced mutation rarity was not recorded")
	nexusSmokeAssert(!other_mutation_player.character_mutations.len, "character mutation lists are shared between mobs")
	for(var/mutation_id in mutation_player.character_mutations)
		nexusSmokeAssert(CHARACTER_MUTATIONS[mutation_id], "mutation randomizer produced an unknown mutation")
		nexusSmokeAssert(mutation_player.character_mutations[mutation_id] >= 1 && mutation_player.character_mutations[mutation_id] <= 30, "Anomaly mutation exceeded its percentage bounds")
	var/mob/NexusSmokeTest/common_mutation_player = new
	common_mutation_player.rollCharacterMutations("Common")
	nexusSmokeAssert(common_mutation_player.character_mutations.len == 1, "Common mutation affected more than one stat")
	for(var/mutation_id in common_mutation_player.character_mutations)
		nexusSmokeAssert(common_mutation_player.character_mutations[mutation_id] <= 10, "Common mutation exceeded 10 percent")
	var/mob/NexusSmokeTest/uncommon_mutation_player = new
	uncommon_mutation_player.rollCharacterMutations("Uncommon")
	nexusSmokeAssert(uncommon_mutation_player.character_mutations.len == 1, "Uncommon mutation affected more than one stat")
	for(var/mutation_id in uncommon_mutation_player.character_mutations)
		nexusSmokeAssert(uncommon_mutation_player.character_mutations[mutation_id] <= 20, "Uncommon mutation exceeded 20 percent")
	var/mob/NexusSmokeTest/rare_mutation_player = new
	rare_mutation_player.rollCharacterMutations("Rare")
	nexusSmokeAssert(rare_mutation_player.character_mutations.len in list(2, 3), "Rare mutation did not affect two or three stats")
	for(var/mutation_id in rare_mutation_player.character_mutations)
		nexusSmokeAssert(rare_mutation_player.character_mutations[mutation_id] <= 20, "Rare mutation exceeded 20 percent")
	var/mob/NexusSmokeTest/legacy_mutation_player = new
	legacy_mutation_player.character_mutations = list("adaptive_musculature")
	legacy_mutation_player.mutation_save_version = 1
	legacy_mutation_player.normalizeCharacterMutations()
	nexusSmokeAssert(legacy_mutation_player.character_mutations["adaptive_musculature"] == 10, "legacy mutation ID was not migrated")
	del(legacy_mutation_player)
	del(rare_mutation_player)
	del(uncommon_mutation_player)
	del(common_mutation_player)
	mutation_player.character_mutations = list("adaptive_musculature" = 10, "accelerated_reflexes" = 20)
	mutation_player.mutation_rarity = "Rare"
	var/old_strength_mod = mutation_player.strmod
	var/old_speed_mod = mutation_player.spdmod
	mutation_player.applyCharacterMutations()
	nexusSmokeAssert(round(mutation_player.strmod, 0.01) == round(old_strength_mod * 1.1, 0.01), "strength mutation percentage was not applied")
	nexusSmokeAssert(round(mutation_player.spdmod, 0.01) == round(old_speed_mod * 1.2, 0.01), "speed mutation percentage was not applied")
	other_mutation_player.normalizeCharacterMutations()
	nexusSmokeAssert(other_mutation_player.mutation_save_version == CHARACTER_MUTATION_SAVE_VERSION, "legacy mutation state was not migrated")
	nexusSmokeAssert(!other_mutation_player.character_mutations.len, "legacy character received a retroactive mutation")
	var/mob/NexusSmokeTest/admin_mutation_player = new
	admin_mutation_player.Str = 100
	admin_mutation_player.strmod = 1
	admin_mutation_player.mutation_save_version = CHARACTER_MUTATION_SAVE_VERSION
	nexusSmokeAssert(admin_mutation_player.setCharacterMutationValue("adaptive_musculature", 10), "admin mutation setter rejected a valid mutation")
	nexusSmokeAssertNear(admin_mutation_player.Str, 110, 0.001, "admin mutation setter did not apply its stat modifier")
	nexusSmokeAssertNear(admin_mutation_player.strmod, 1.1, 0.001, "admin mutation setter did not apply its growth modifier")
	nexusSmokeAssert(admin_mutation_player.mutation_rarity == "Common", "admin mutation setter did not derive rarity")
	admin_mutation_player.setCharacterMutationValue("adaptive_musculature", 20)
	nexusSmokeAssertNear(admin_mutation_player.Str, 120, 0.001, "editing an admin mutation stacked its previous modifier")
	admin_mutation_player.setCharacterMutationValue("adaptive_musculature", 0)
	nexusSmokeAssertNear(admin_mutation_player.Str, 100, 0.001, "removing an admin mutation did not restore its stat")
	nexusSmokeAssert(!admin_mutation_player.character_mutations.len && !admin_mutation_player.mutation_rarity, "removing the last admin mutation left stale state")
	nexusSmokeAssert(admin_mutation_player.rerollCharacterMutations("Rare"), "admin mutation reroll rejected a valid forced rarity")
	nexusSmokeAssert(admin_mutation_player.mutation_rarity == "Rare" && admin_mutation_player.character_mutations.len >= 2 && admin_mutation_player.character_mutations.len <= 3, "admin mutation reroll produced an invalid Rare result")
	nexusSmokeAssert(admin_mutation_player.clearCharacterMutations(), "admin mutation clear failed")
	nexusSmokeAssert(!admin_mutation_player.character_mutations.len && !admin_mutation_player.mutation_rarity, "admin mutation clear left stale state")
	del(admin_mutation_player)
	var/mob/NexusSmokeTest/mutagen_player = new
	mutagen_player.Race = "Human"
	mutagen_player.mutation_save_version = CHARACTER_MUTATION_SAVE_VERSION
	nexusSmokeAssert(mutagen_player.awakenRandomMutation(5, 5, 2, FALSE), "organic mutagen did not awaken its first mutation")
	nexusSmokeAssert(mutagen_player.awakenRandomMutation(5, 5, 2, FALSE), "organic mutagen did not awaken its second mutation")
	nexusSmokeAssert(mutagen_player.character_mutations.len == 2 && !mutagen_player.awakenRandomMutation(5, 5, 2, FALSE), "organic mutagen bypassed its two-mutation safety limit")
	for(var/mutation_id in mutagen_player.character_mutations)
		nexusSmokeAssert(mutagen_player.character_mutations[mutation_id] == 5, "mutagen applied a value outside its requested test range")
	var/mob/NexusSmokeTest/android_mutagen_player = new
	android_mutagen_player.Race = "Android"
	android_mutagen_player.mutation_save_version = CHARACTER_MUTATION_SAVE_VERSION
	nexusSmokeAssert(!android_mutagen_player.awakenRandomMutation(5, 5, 2, FALSE), "organic mutagen altered an Android core")
	nexusSmokeAssert(android_mutagen_player.awakenRandomMutation(5, 5, 2, TRUE) && android_mutagen_player.character_mutations.len == 1, "self-replicating code did not awaken an Android mutation")
	var/mob/NexusSmokeTest/angerless_mutation_player = new
	angerless_mutation_player.Class = "Legendary Saiyan"
	angerless_mutation_player.max_anger = 200
	angerless_mutation_player.mutation_rarity = "Common"
	angerless_mutation_player.mutation_save_version = CHARACTER_MUTATION_SAVE_VERSION
	angerless_mutation_player.character_mutations = list("volatile_potential" = 10)
	angerless_mutation_player.normalizeCharacterMutations()
	nexusSmokeAssert(!angerless_mutation_player.character_mutations["volatile_potential"] && angerless_mutation_player.max_anger == 100 && !angerless_mutation_player.setCharacterMutationValue("volatile_potential", 10), "an Angerless lineage retained or accepted an Anger mutation")
	del(angerless_mutation_player)
	del(android_mutagen_player)
	del(mutagen_player)
	del(other_mutation_player)
	del(mutation_player)
	var/mob/NexusSmokeTest/creation_player = new
	creation_player.Race(force_race = "Human", interactive_options = 0)
	creation_player.rollCharacterMutations("None")
	var/list/human_profile = nexusCreationStatProfile("Human", "human_adaptability")
	var/list/human_allocation = nexusSmokeStatAllocation(human_profile)
	nexusSmokeAssert(nexusValidateStatAllocation(human_profile, human_allocation), "manual Human allocation failed validation")
	var/list/saiyan_creation_profile = nexusCreationStatProfile("Saiyan", "saiyan_warrior")
	var/list/saiyan_racial_points = saiyan_creation_profile["racial_points"]
	var/list/saiyan_base_values = saiyan_creation_profile["base"]
	nexusSmokeAssert(saiyan_racial_points["strength"] == 2 && saiyan_racial_points["endurance"] == 4 && saiyan_racial_points["regeneration"] == 3, "Saiyan lineage points are absent from the creation profile")
	nexusSmokeAssert(saiyan_base_values["strength"] > 1 && saiyan_base_values["endurance"] > 1, "Saiyan race values do not include its free lineage build")
	var/list/makyo_creation_profile = nexusCreationStatProfile("Makyo", "makyo_starborn")
	var/list/makyo_creation_caps = makyo_creation_profile["caps"]
	nexusSmokeAssert(makyo_creation_caps["endurance"] >= 10 && makyo_creation_caps["speed"] >= 10 && makyo_creation_caps["anger"] > 0, "free Makyo lineage points consumed manual allocation room or disabled Anger")
	var/list/lssj_creation_profile = nexusCreationStatProfile("Legendary Saiyan", "legendary_berserker")
	var/list/android_creation_profile = nexusCreationStatProfile("Android", "android_chassis")
	var/list/lssj_creation_caps = lssj_creation_profile["caps"]
	var/list/android_creation_caps = android_creation_profile["caps"]
	nexusSmokeAssert(lssj_creation_caps["anger"] == 0 && android_creation_caps["anger"] == 0, "an Angerless fixed lineage exposes Anger allocation")
	nexusSmokeAssert(!nexusCreationCanAllocateAnger("Alien", list("apex_genome" = TRUE)) && nexusCreationCanAllocateAnger("Alien", list()), "Apex Alien Anger allocation validation is inconsistent")
	creation_player.Racial_Stats(Start_Redo_Stats = 0, modless_check = 0, stat_allocation = human_allocation)
	nexusSmokeAssert(!creation_player.Points, "automatic character stats left unspent points")
	nexusSmokeAssert(creation_player.Max_Points > 0, "automatic character stats did not initialize the point budget")
	nexusSmokeAssert(human_profile["caps"]["offense"] < human_profile["budget"], "Offense has no creation cap")
	nexusSmokeAssert(human_profile["caps"]["defense"] < human_profile["budget"], "Defense has no creation cap")
	creation_player.applyNexusAppearance("Human", "female", "human_f_dark", null, "#223344")
	nexusSmokeAssert(creation_player.icon, "Nexus character appearance did not assign an icon")
	var/mob/NexusSmokeTest/spirit_doll = new
	spirit_doll.Doll(interactive_options = 0)
	nexusSmokeAssert(spirit_doll.Class == "Spirit Doll", "Spirit Doll class was not initialized")
	nexusSmokeAssert(spirit_doll.bp_mod == human_bp_mod * 0.9, "Spirit Doll BP modifier ignored its class")
	var/mob/NexusSmokeTest/frost_lord = new
	frost_lord.Icer(interactive_options = 0, force_cooler = 1)
	nexusSmokeAssert(frost_lord.IsCooler && frost_lord.Class == "Cooler", "forced Cooler lineage was not initialized")
	nexusSmokeAssert(frost_lord.racialCombatBPMult() == 0.76 && frost_lord.racialDamageTakenMult() == cooler_dmg_taken_mult, "Cooler sustainable exceptional package was not applied")
	var/mob/NexusSmokeTest/saiyan_balance_test = new
	saiyan_balance_test.Race = "Saiyan"
	nexusSmokeAssert(saiyan_balance_test.racialCombatBPMult() == 0.77, "base Saiyan escaped Human-equivalent combat BP")
	saiyan_balance_test.Class = "Legendary Saiyan"
	nexusSmokeAssert(saiyan_balance_test.racialCombatBPMult() == 1.65 && saiyan_balance_test.racialDamageTakenMult() == 0.9, "Legendary Saiyan sustainable exceptional package is inconsistent")
	var/mob/NexusSmokeTest/android_balance_test = new
	android_balance_test.Race = "Android"
	nexusSmokeAssert(android_balance_test.racialCombatBPMult() == 1.35 && android_balance_test.racialDamageTakenMult() == 0.55, "Android exceptional package is inconsistent")
	var/mob/NexusSmokeTest/bio_balance_test = new
	bio_balance_test.Race = "Bio-Android"
	nexusSmokeAssert(bio_balance_test.racialCombatBPMult() == 1.1 && bio_balance_test.racialDamageTakenMult() == 0.89, "Bio-Android exceptional package is inconsistent")
	var/mob/NexusSmokeTest/majin_balance_test = new
	majin_balance_test.Race = "Majin"
	nexusSmokeAssert(majin_balance_test.racialCombatBPMult() == 1.13 && majin_balance_test.racialDamageTakenMult() == 0.96, "Majin sustainable exceptional package is inconsistent")
	nexusSmokeAssert(third_eye_bp_add == 0.2, "Third Eye BP no longer matches its 1.2x description")
	nexusSmokeAssert(jirenAlienBPMult == 0.95 && jirenTakeDmgMult == 1 && jirenAlienPowerupMult == 0.75, "Alien Apex Genome escaped the Standard-tier package")
	var/old_makyo_star_state = Makyo_Star
	Makyo_Star = FALSE
	var/list/race_balance_cases = list(
		list("Human", "Human", null, FALSE, FALSE, 1.33, 1),
		list("Spirit Doll", "Human", "Spirit Doll", FALSE, FALSE, 1.197, 1),
		list("Saiyan", "Saiyan", null, FALSE, FALSE, 1.54, 1),
		list("Half Saiyan", "Half Saiyan", null, FALSE, FALSE, 1.725, 1),
		list("Legendary Saiyan", "Saiyan", "Legendary Saiyan", FALSE, FALSE, 3.3, 0.9),
		list("Alien", "Alien", null, FALSE, FALSE, 1.55, 1),
		list("Alien Apex Genome", "Alien", null, TRUE, FALSE, 1.4725, 1),
		list("Android", "Android", null, FALSE, FALSE, 1.35, 0.55),
		list("Bio-Android", "Bio-Android", null, FALSE, FALSE, 2.31, 0.89),
		list("Demigod", "Demigod", null, FALSE, FALSE, 1.65, 1),
		list("Demon", "Demon", null, FALSE, FALSE, 1.85, 1),
		list("Frost Lord", "Frost Lord", null, FALSE, FALSE, 1.68, 1),
		list("Cooler", "Frost Lord", "Cooler", FALSE, TRUE, 1.596, 0.89),
		list("Kai", "Kai", null, FALSE, FALSE, 1.8, 1),
		list("Kanassan", "Kanassan", "Seer", FALSE, FALSE, 1.75, 1),
		list("Heran", "Heran", "Space Pirate", FALSE, FALSE, 2.05, 1),
		list("Makyo", "Makyo", null, FALSE, FALSE, 1.739, 1),
		list("Majin", "Majin", null, FALSE, FALSE, 2.8815, 0.96),
		list("Namekian", "Namekian", null, FALSE, FALSE, 1.65, 1),
		list("Tsujin", "Tsujin", null, FALSE, FALSE, 1.28, 1))
	for(var/list/balance_case in race_balance_cases)
		var/mob/NexusSmokeTest/race_balance_test = new
		race_balance_test.Race = balance_case[2]
		race_balance_test.Class = balance_case[3]
		race_balance_test.jirenAlien = balance_case[4]
		race_balance_test.IsCooler = balance_case[5]
		var/effective_creation_bp = race_balance_test.Get_race_starting_bp_mod() * race_balance_test.racialCombatBPMult()
		nexusSmokeAssertNear(effective_creation_bp, balance_case[6], 0.0001, "creation BP package diverged from the balance workbook: [balance_case[1]]")
		nexusSmokeAssertNear(race_balance_test.racialDamageTakenMult(), balance_case[7], 0.0001, "incoming damage package diverged from the balance workbook: [balance_case[1]]")
		del(race_balance_test)
	Makyo_Star = TRUE
	var/mob/NexusSmokeTest/makyo_star_balance_test = new
	makyo_star_balance_test.Race = "Makyo"
	nexusSmokeAssertNear(makyo_star_balance_test.racialCombatBPMult(), 1.08, 0.0001, "Makyo Star combat bonus is missing or excessive")
	del(makyo_star_balance_test)
	Makyo_Star = old_makyo_star_state
	var/list/expected_creation_budgets = list(
		"Human|human_adaptability" = 72,
		"Spirit Doll|doll_awakened" = 72,
		"Saiyan|saiyan_warrior" = 33,
		"Saiyan|saiyan_low_class" = 37,
		"Saiyan|saiyan_elite" = 34,
		"Half Saiyan|half_saiyan_hybrid" = 44,
		"Legendary Saiyan|legendary_berserker" = 34,
		"Alien|alien_scholar" = 75,
		"Alien|alien_predator" = 75,
		"Alien|alien_shifter" = 75,
		"Alien|alien_anomaly" = 75,
		"Android|android_chassis" = 61,
		"Android|android_infiltrator" = 61,
		"Android|android_progenitor" = 61,
		"Bio-Android|bio_adaptation" = 31,
		"Demigod|demigod_heritage" = 24,
		"Demon|demon_soulbound" = 44,
		"Frost Lord|frost_heir" = 29,
		"Frost Lord|frost_cooler" = 29,
		"Kai|kai_guardian" = 42,
		"Kanassan|kanassan_seer" = 44,
		"Heran|heran_pirate" = 37,
		"Makyo|makyo_starborn" = 48,
		"Majin|majin_fragment" = 34,
		"Namekian|namek_dragon_clan" = 45,
		"Namekian|namek_ancient" = 45,
		"Tsujin|tsujin_engineer" = 55)
	for(var/profile_id in expected_creation_budgets)
		var/list/profile_parts = splittext(profile_id, "|")
		var/list/balance_profile = nexusCreationStatProfile(profile_parts[1], profile_parts[2])
		nexusSmokeAssert(balance_profile["budget"] == expected_creation_budgets[profile_id], "creation budget diverged from the balance workbook: [profile_id]")
	var/mob/NexusSmokeTest/ported_race_test = new
	ported_race_test.Kanassan(FALSE)
	nexusSmokeAssert(ported_race_test.Race == "Kanassan" && ported_race_test.precog && (locate(/obj/Telepathy) in ported_race_test), "Kanassan template lacks its psionic identity")
	ported_race_test.Heran(FALSE)
	nexusSmokeAssert(ported_race_test.Race == "Heran" && ported_race_test.Class == "Space Pirate" && ported_race_test.zenkai_mod == 1 && (locate(/obj/HeranTransformation) in ported_race_test), "Heran template lacks its combat-growth identity or racial transformation")
	ported_race_test.Namekian(FALSE)
	ported_race_test.applyAncientNamekianLineage()
	nexusSmokeAssert(ported_race_test.Class == "Ancient" && (locate(/obj/Materialization) in ported_race_test), "Ancient Namekian lineage was not applied")
	ported_race_test.Android(FALSE)
	ported_race_test.applyAncientProgenitorLineage()
	nexusSmokeAssert(ported_race_test.Class == "Ancient Progenitor" && ported_race_test.Knowledge >= 900 && (locate(/obj/Advanced_Sense) in ported_race_test), "Ancient Progenitor lineage was not applied")
	del(ported_race_test)
	var/datum/PlanetaryClock/planet_clock_test = new("smoke")
	planet_clock_test.hours_of_day = 15
	planet_clock_test.hours_of_night = 9
	planet_clock_test.is_day = TRUE
	planet_clock_test.hours_remaining = 1
	planet_clock_test.advanceHour()
	nexusSmokeAssert(!planet_clock_test.is_day && planet_clock_test.hours_remaining == 9 && nexus_planetary_hour_ticks >= 3000, "planetary clock did not synchronize a longer day/night phase")
	del(planet_clock_test)
	var/legendary_sustainable_bp = 11 * 1.35 * 1.35 * lssj_combat_bp_mult
	var/bio_sustainable_bp = base_ascension_mod * 1.265 * bio_android_combat_bp_mult * 1.6
	var/majin_sustainable_bp = base_ascension_mod * 1.265 * 1.3 * majin_combat_bp_mult * 1.2
	nexusSmokeAssert(legendary_sustainable_bp > 33 && legendary_sustainable_bp < 33.2, "Legendary sustainable progression escaped the Exceptional target")
	nexusSmokeAssert(bio_sustainable_bp > 33 && bio_sustainable_bp < 33.2, "Bio-Android sustainable progression escaped the Exceptional target")
	nexusSmokeAssert(majin_sustainable_bp > 33 && majin_sustainable_bp < 33.2, "Majin sustainable progression escaped the Exceptional target")
	var/list/alien_definitions = nexusAlienOptionDefinitions()
	nexusSmokeAssert(alien_definitions.len == 23, "Alien point-buy catalog is incomplete")
	nexusSmokeAssert(nexusValidateAlienOptions(nexusAlienPresetOptions("alien_scholar")) && nexusValidateAlienOptions(nexusAlienPresetOptions("alien_predator")) && nexusValidateAlienOptions(nexusAlienPresetOptions("alien_shifter")) && nexusValidateAlienOptions(nexusAlienPresetOptions("alien_anomaly")), "an Alien preset exceeds its 100 AP budget")
	nexusSmokeAssert(!nexusValidateAlienOptions(list("genius" = TRUE, "time_freeze" = TRUE, "precognition" = TRUE, "apex_genome" = TRUE)), "Alien point-buy accepted more than 100 AP")
	var/mob/NexusSmokeTest/alien_point_buy_test = new
	alien_point_buy_test.Alien(interactive_options = 0)
	alien_point_buy_test.bp_loss_from_low_ki = 1
	alien_point_buy_test.bp_loss_from_low_hp = 1
	alien_point_buy_test.applyNexusAlienOptions(list("genius", "limit_breaker", "stretchy_arms", "low_ki_resistance", "low_health_resistance"))
	nexusSmokeAssert(alien_point_buy_test.Intelligence == 1 && (locate(/obj/Limit_Breaker) in alien_point_buy_test) && alien_point_buy_test.arm_stretch, "Alien point-buy effects were not applied")
	nexusSmokeAssert(alien_point_buy_test.bp_loss_from_low_ki == 1 / 3 && alien_point_buy_test.bp_loss_from_low_hp == 1 / 3, "Alien low-resource resistance was not applied")
	var/mob/NexusSmokeTest/apex_alien_anger_test = new
	apex_alien_anger_test.Alien(interactive_options = 0)
	apex_alien_anger_test.max_anger = 250
	apex_alien_anger_test.anger = 200
	apex_alien_anger_test.applyNexusAlienOptions(list("apex_genome"))
	nexusSmokeAssert(apex_alien_anger_test.jirenAlien && !apex_alien_anger_test.canPossessAnger() && apex_alien_anger_test.max_anger == 100 && apex_alien_anger_test.anger == 100, "Apex Genome did not remove Anger")
	var/list/frost_icon_options = nexusFrostIconOptions()
	nexusSmokeAssert(frost_icon_options.len >= 40, "Frost Lord creation does not expose the complete form catalog")
	var/list/frost_form_ids = list()
	for(var/frost_icon_id in frost_icon_options)
		frost_form_ids += frost_icon_id
		if(frost_form_ids.len == 5) break
	nexusSmokeAssert(nexusValidateFrostFormOptions(frost_form_ids, TRUE), "Cooler form-slot validation rejected the full five-form selection")
	frost_lord.applyNexusAppearance("Frost Lord", "male", frost_form_ids[1], null, null, frost_form_ids)
	nexusSmokeAssert(frost_lord.Form1Icon == frost_icon_options[frost_form_ids[1]] && frost_lord.Form5Icon == frost_icon_options[frost_form_ids[5]], "Frost Lord form icons were not assigned independently")
	var/list/custom_frost_test_icons = list(null, null, null, null, null)
	var/list/custom_frost_test_ids = list("custom_body", "custom_frost_2", "custom_frost_3", "custom_frost_4", "custom_frost_5")
	for(var/custom_frost_index in 1 to 5) custom_frost_test_icons[custom_frost_index] = icon(frost_icon_options[frost_form_ids[custom_frost_index]])
	nexusSmokeAssert(nexusValidateFrostFormOptions(custom_frost_test_ids, TRUE, custom_frost_test_icons), "valid custom Frost Lord form set was rejected")
	frost_lord.applyNexusAppearance("Frost Lord", "male", "custom_body", null, null, custom_frost_test_ids, custom_frost_test_icons[1], custom_frost_test_icons)
	nexusSmokeAssert(frost_lord.Form1Icon == custom_frost_test_icons[1] && frost_lord.Form5Icon == custom_frost_test_icons[5], "custom Frost Lord forms were not assigned to their independent slots")
	var/list/starter_clothing_options = nexusStarterClothingOptions()
	nexusSmokeAssert(starter_clothing_options.len >= 80, "starter clothing catalog is unexpectedly incomplete")
	var/succubus_flight_state = nexusPreviewIconState('Succubus.dmi', "flight")
	var/human_flight_state = nexusPreviewIconState('BaseHumanPale.dmi', "flight")
	var/succubus_preview_url = nexusBrowserIconUrl('Succubus.dmi', succubus_flight_state, WEST)
	var/cape_preview_url = nexusBrowserIconUrl('ItemPiccoloCape.dmi', "", NORTH)
	var/icon/naraku_preview_frame = nexusExtractPreviewFrame('ClothesNaraku.dmi', "", SOUTH)
	var/icon/angel_wings_preview_frame = nexusExtractPreviewFrame('AngelWings.dmi', "", SOUTH)
	nexusSmokeAssert(succubus_flight_state == "Flight", "starter clothing preview did not resolve Flight case-insensitively")
	nexusSmokeAssert(human_flight_state == "Flight", "standard Human preview has no selectable Flight state")
	nexusSmokeAssert(findtext(succubus_preview_url, "?dir=[WEST]&frame=1") && findtext(succubus_preview_url, "&state=Flight"), "Succubus preview does not select one directional Flight frame")
	nexusSmokeAssert(findtext(cape_preview_url, "?dir=[NORTH]&frame=1") && !findtext(cape_preview_url, "&moving="), "native browser previews unexpectedly force a movement variant")
	nexusSmokeAssert(nexusPreviewIconMoving('ClothesNaraku.dmi', "", SOUTH) && nexusPreviewIconMoving('AngelWings.dmi', "", SOUTH), "Naraku or Angel Wings movement-only state was not detected")
	nexusSmokeAssert(naraku_preview_frame.Width() == 32 && naraku_preview_frame.Height() == 32 && nexusPreviewFrameHasPixels(naraku_preview_frame) && angel_wings_preview_frame.Width() == 32 && angel_wings_preview_frame.Height() == 32 && nexusPreviewFrameHasPixels(angel_wings_preview_frame), "Naraku or Angel Wings preview was not extracted to one visible frame")
	var/list/starter_clothing_ids = list()
	for(var/clothing_id in starter_clothing_options)
		starter_clothing_ids[clothing_id] = TRUE
		if(starter_clothing_ids.len == 2) break
	nexusSmokeAssert(nexusValidateStarterClothing(starter_clothing_ids), "valid starter clothing was rejected")
	var/list/excess_clothing_ids = list()
	for(var/clothing_id in starter_clothing_options)
		excess_clothing_ids[clothing_id] = TRUE
		if(excess_clothing_ids.len > nexus_starter_clothing_limit) break
	nexusSmokeAssert(!nexusValidateStarterClothing(excess_clothing_ids), "starter clothing exceeded its selection limit")
	var/icon/custom_body_test_icon = icon('BaseHumanTan.dmi')
	var/icon/custom_clothing_test_icon = icon('GokuSuit.dmi')
	var/list/custom_clothing_test_icons = list(null, null, null, null)
	custom_clothing_test_icons[1] = custom_clothing_test_icon
	var/list/custom_clothing_test_ids = list("custom_clothing_1" = TRUE)
	nexusSmokeAssert(nexusCustomIconIsValid(custom_body_test_icon), "valid custom character icon was rejected")
	nexusSmokeAssert(nexusValidateStarterClothing(custom_clothing_test_ids, custom_clothing_test_icons), "valid custom starter clothing layer was rejected")
	var/mob/NexusSmokeTest/custom_appearance_test = new
	custom_appearance_test.icon = custom_body_test_icon
	custom_appearance_test.applyNexusStarterClothing(custom_clothing_test_ids, custom_clothing_test_icons)
	var/obj/items/Clothes/CustomClothing/custom_creation_clothing = locate(/obj/items/Clothes/CustomClothing) in custom_appearance_test
	nexusSmokeAssert(custom_creation_clothing && custom_creation_clothing.suffix == "Equipped" && custom_creation_clothing.appearance_managed, "custom creation clothing was not equipped through the appearance manager")
	var/mob/NexusSmokeTest/appearance_test = new
	var/obj/items/Clothes/ShortSleeveShirt/appearance_shirt_1 = new(appearance_test)
	var/obj/items/Clothes/ShortSleeveShirt/appearance_shirt_2 = new(appearance_test)
	appearance_shirt_1.suffix = "Equipped"
	appearance_shirt_2.suffix = "Equipped"
	appearance_shirt_1.appearance_priority = 700
	appearance_shirt_2.appearance_priority = 300
	appearance_test.rebuildPlayerAppearance("startup test")
	var/datum/PlayerAppearanceManager/test_appearance_manager = appearance_test.player_appearance_manager
	var/list/ordered_appearance_entries = test_appearance_manager.sortedEntries()
	nexusSmokeAssert(test_appearance_manager.rendered_appearances.len == 2 && test_appearance_manager.rendered_appearances[1] != test_appearance_manager.rendered_appearances[2], "identical clothing icons do not have independent overlay ownership")
	nexusSmokeAssert(ordered_appearance_entries[1]:source == appearance_shirt_2, "overlay priority did not produce deterministic ordering")
	test_appearance_manager.rendered_appearances = list()
	appearance_test.rebuildPlayerAppearance("simulated relog")
	var/matching_equipment_appearances
	for(var/appearance_value in appearance_test.overlays)
		if(test_appearance_manager.appearanceMatchesEquipment(appearance_value, appearance_shirt_1)) matching_equipment_appearances++
	nexusSmokeAssert(test_appearance_manager.rendered_appearances.len == 2 && matching_equipment_appearances == 2, "relog-style orphaned equipment images were duplicated instead of rebuilt")
	var/login_rebuild_generation = test_appearance_manager.rebuild_generation
	appearance_test.normalizePrimaryTransformation()
	nexusSmokeAssert(test_appearance_manager.rebuild_generation == login_rebuild_generation + 1 && test_appearance_manager.last_rebuild_reason == "transformation login", "login normalization did not rebuild managed overlays")
	var/equipment_rebuild_generation = test_appearance_manager.rebuild_generation
	appearance_test.Clothes_Equip(appearance_shirt_1)
	nexusSmokeAssert(test_appearance_manager.rebuild_generation == equipment_rebuild_generation + 1 && test_appearance_manager.rendered_appearances.len == 1, "equipment changes did not rebuild managed overlays")
	appearance_test.Clothes_Equip(appearance_shirt_1)
	initializeNexusTransformationRegistry()
	nexusSmokeAssert(nexus_transformation_registry.len >= 16, "primary transformation registry is incomplete")
	var/mob/NexusSmokeTest/transformation_state_test = new
	transformation_state_test.Race = "Saiyan"
	transformation_state_test.ssj = 3
	transformation_state_test.using_giant_form = TRUE
	nexusSmokeAssert(transformation_state_test.countPrimaryTransformations() == 2 && transformation_state_test.detectPrimaryTransformation() == "giant", "legacy simultaneous transformation detection failed")
	nexusSmokeAssert(getSsjEyeOverlay(FALSE) != getSsjEyeOverlay(TRUE), "mastered and unmastered Super Saiyan eye overlays are identical")
	var/mob/NexusSmokeTest/heran_transformation_test = new
	heran_transformation_test.Heran(FALSE)
	heran_transformation_test.icon = 'src/Icons/PlayerIcons/BaseIcons/Heran/HeranSpacePirate.dmi'
	heran_transformation_test.base_bp = 2000000
	heran_transformation_test.hbtc_bp = 500000
	heran_transformation_test.unlockedBP = 250000
	heran_transformation_test.BP = 3000000
	heran_transformation_test.effectiveBaseBp = 3000000
	heran_transformation_test.max_ki = 1000
	heran_transformation_test.Ki = 1000
	var/heran_natural_bp = heran_transformation_test.base_bp + heran_transformation_test.hbtc_bp + heran_transformation_test.unlockedBP
	var/expected_ssj1_add = heran_natural_bp * 0.35 + heran_transformation_test.getSsjTierOneBasePowerAdd()
	var/icon/heran_original_icon = heran_transformation_test.icon
	nexusSmokeAssert(heran_transformation_test.getHeranTransformationEquivalentBPAdd() == expected_ssj1_add, "Heran transformation is not exactly capped to the standard Super Saiyan 1 gain")
	nexusSmokeAssert(heran_transformation_test.getHeranTransformationNaturalBPAdd() + heran_transformation_test.getHeranTransformationStaticBPAdd() == expected_ssj1_add, "Heran transformation does not preserve the standard SSJ ordering around potential and temporary modifiers")
	nexusSmokeAssert(heran_transformation_test.activateHeranTransformation(FALSE), "eligible Heran could not activate their racial transformation")
	nexusSmokeAssert(heran_transformation_test.heran_transformed && heran_transformation_test.detectPrimaryTransformation() == "heran_transformation" && heran_transformation_test.countPrimaryTransformations() == 1, "Heran transformation was not registered as one canonical primary form")
	nexusSmokeAssert(heran_natural_bp + heran_transformation_test.getActiveHeranTransformationBPAdd() == heran_natural_bp * 1.35 + heran_transformation_test.getSsjTierOneBasePowerAdd(), "Heran additive BP exceeded or fell below equivalent Super Saiyan 1 power")
	nexusSmokeAssert(heran_transformation_test.icon == 'src/Icons/PlayerIcons/BaseIcons/Heran/HeranBojack.dmi' && getNexusTransformationGlowProfile("heran_transformation")["color"] == "#42e58f", "Heran transformation art or glow was not applied")
	heran_transformation_test.revertHeranTransformation(FALSE)
	nexusSmokeAssert(!heran_transformation_test.heran_transformed && !heran_transformation_test.heran_transformation_bp_add && heran_transformation_test.icon == heran_original_icon, "Heran transformation left permanent BP or appearance state after reversion")
	var/mob/NexusSmokeTest/giant_form_test = new
	giant_form_test.Race = "Makyo"
	giant_form_test.bp_mult = 1
	var/obj/items/Clothes/ShortSleeveShirt/giant_form_shirt = new(giant_form_test)
	giant_form_shirt.suffix = "Equipped"
	giant_form_test.rebuildPlayerAppearance("giant form setup")
	var/obj/NexusHud/OverheadHealthBar/giant_hud_contract = new
	var/obj/Effect/NexusTypingIndicator/giant_typing_contract = new
	var/obj/Effect/NexusSayText/giant_say_contract = new
	nexusSmokeAssert((giant_hud_contract.appearance_flags & RESET_TRANSFORM) && (giant_typing_contract.appearance_flags & RESET_TRANSFORM) && (giant_say_contract.appearance_flags & RESET_TRANSFORM), "world-attached vitals or communication overlays inherit Giant or Larva scaling")
	giant_form_test.Enable_giant_form()
	giant_form_test.Disable_giant_form()
	var/datum/PlayerAppearanceManager/giant_appearance_manager = giant_form_test.player_appearance_manager
	var/giant_equipment_appearances
	for(var/appearance_value in giant_form_test.overlays)
		if(giant_appearance_manager.appearanceMatchesEquipment(appearance_value, giant_form_shirt)) giant_equipment_appearances++
	nexusSmokeAssert(round(giant_form_test.bp_mult, 0.001) == 1, "Giant Form left a permanent BP multiplier")
	nexusSmokeAssert(giant_appearance_manager.rendered_appearances.len == 1 && giant_equipment_appearances == 1 && findtext(giant_appearance_manager.last_rebuild_reason, "giant disabled"), "Giant Form did not rebuild exactly one copy of equipped clothing")
	var/mob/NexusSmokeTest/scaled_giant_form_test = new
	scaled_giant_form_test.Race = "Human"
	scaled_giant_form_test.icon = 'BaseHumanPale.dmi'
	scaled_giant_form_test.bp_mult = 1
	var/obj/items/Clothes/ShortSleeveShirt/scaled_giant_form_shirt = new(scaled_giant_form_test)
	scaled_giant_form_shirt.suffix = "Equipped"
	scaled_giant_form_test.rebuildPlayerAppearance("scaled giant setup")
	var/datum/PlayerAppearanceManager/scaled_giant_manager = scaled_giant_form_test.player_appearance_manager
	var/image/scaled_giant_clothing_image = scaled_giant_manager.rendered_appearances[1]
	nexusSmokeAssert(scaled_giant_clothing_image && (scaled_giant_clothing_image.appearance_flags & RESET_TRANSFORM), "equipped clothing is not isolated from double character resize")
	scaled_giant_form_test.Enable_giant_form()
	sleep(7)
	var/matrix/scaled_giant_active_transform = matrix(scaled_giant_form_test.transform)
	var/matrix/scaled_giant_clothing_transform = matrix(scaled_giant_clothing_image.transform)
	nexusSmokeAssertNear(scaled_giant_active_transform.a, 2, 0.001, "non-Makyo Giant Form did not scale the complete character silhouette")
	nexusSmokeAssertNear(scaled_giant_clothing_transform.a, 2, 0.001, "equipped clothing did not receive the Giant Form body transform")
	nexusSmokeAssert(scaled_giant_form_test.getNexusCombatHitboxWidth() == 48 && scaled_giant_form_test.getNexusCombatHitboxHeight() == 48, "Giant Form did not install its rectangular combat hitbox")
	scaled_giant_form_test.normalizeNexusCharacterVisualScale()
	var/matrix/scaled_giant_relog_transform = matrix(scaled_giant_form_test.transform)
	nexusSmokeAssertNear(scaled_giant_relog_transform.a, 2, 0.001, "Giant Form visual scale multiplied again during relog normalization")
	scaled_giant_form_test.Disable_giant_form()
	sleep(16)
	var/matrix/scaled_giant_reverted_transform = matrix(scaled_giant_form_test.transform)
	nexusSmokeAssertNear(scaled_giant_reverted_transform.a, 1, 0.001, "Giant Form did not restore the base character scale")
	nexusSmokeAssert(scaled_giant_form_test.getNexusCombatHitboxWidth() == scaled_giant_form_test.bound_width && scaled_giant_form_test.getNexusCombatHitboxHeight() == scaled_giant_form_test.bound_height, "Giant Form left an expanded combat hitbox after revert")
	runNexusAndroidGiantAppearanceSmoke()
	var/mob/NexusSmokeTest/great_ape_appearance_test = new
	great_ape_appearance_test.Race = "Saiyan"
	great_ape_appearance_test.icon = 'BaseHumanPale.dmi'
	great_ape_appearance_test.pixel_x = 5
	great_ape_appearance_test.pixel_y = 7
	var/obj/Great_Ape/great_ape_contract = new(great_ape_appearance_test)
	great_ape_contract.suffix = "Active"
	great_ape_contract.icon = great_ape_appearance_test.icon
	great_ape_appearance_test.Great_Ape_obj = great_ape_contract
	great_ape_appearance_test.great_ape_base_pixel_x = 5
	great_ape_appearance_test.great_ape_base_pixel_y = 7
	great_ape_appearance_test.great_ape_base_pixel_recorded = TRUE
	great_ape_appearance_test.icon = 'OozaruHayate.dmi'
	great_ape_appearance_test.normalizePrimaryTransformation()
	nexusSmokeAssert(great_ape_appearance_test.getNexusCombatHitboxWidth() == 60 && great_ape_appearance_test.getNexusCombatHitboxHeight() == 72 && great_ape_appearance_test.pixel_x == Icon_Center_X('OozaruHayate.dmi') && great_ape_appearance_test.pixel_y == Icon_Center_Y('OozaruHayate.dmi'), "Oozaru relog normalization lost its centered icon or rectangular hitbox")
	great_ape_appearance_test.Great_Ape_revert()
	nexusSmokeAssert(great_ape_appearance_test.icon == 'BaseHumanPale.dmi' && great_ape_appearance_test.pixel_x == 5 && great_ape_appearance_test.pixel_y == 7 && great_ape_appearance_test.getNexusCombatHitboxWidth() == great_ape_appearance_test.bound_width, "Oozaru revert did not restore the base icon anchor and hitbox")
	del(giant_hud_contract)
	del(giant_typing_contract)
	del(giant_say_contract)
	del(giant_form_test)
	del(great_ape_appearance_test)
	del(scaled_giant_form_test)
	del(heran_transformation_test)
	del(transformation_state_test)
	del(appearance_test)
	del(custom_appearance_test)
	del(apex_alien_anger_test)
	del(alien_point_buy_test)
	del(majin_balance_test)
	del(bio_balance_test)
	del(android_balance_test)
	del(saiyan_balance_test)
	del(frost_lord)
	del(spirit_doll)
	del(creation_player)
	for(var/race_name in Race_List())
		var/list/traits = nexusRaceTraitOptions(race_name, player, 1)
		for(var/trait_id in traits)
			var/list/profile = nexusCreationStatProfile(race_name, trait_id)
			var/list/caps = profile["caps"]
			var/total_capacity
			for(var/stat_id in NEXUS_CREATION_STATS)
				nexusSmokeAssert(isnum(caps[stat_id]), "creation profile contains a nonnumeric cap: [race_name]/[trait_id]/[stat_id]")
				total_capacity += caps[stat_id]
			nexusSmokeAssert(total_capacity >= profile["budget"], "creation profile cannot spend its full budget: [race_name]/[trait_id]")

	player.give_energy_type("Mental Energy", amount = 25, maximum = 200, modifier = 1.5)

	var/Energy/mental_energy = player.get_energy("Mental Energy")
	nexusSmokeAssert(mental_energy, "Mental Energy was not created")
	nexusSmokeAssert(mental_energy.quantity == 25, "Mental Energy quantity is invalid")
	nexusSmokeAssert(mental_energy.maximum == 200, "Mental Energy maximum is invalid")
	nexusSmokeAssert(mental_energy.modifier == 1.5, "Mental Energy modifier is invalid")

	player.give_energy_type("Mental Energy")
	nexusSmokeAssert(player.get_energy("Mental Energy") == mental_energy, "duplicate energy replaced the existing datum")
	player.give_energy_type("Unknown Energy")
	nexusSmokeAssert(!player.get_energy("Unknown Energy"), "an unknown energy type was created")

	player.energies["Qi"] = new /Energy("Qi Energy")
	player.character_mutations = list("reactive_guard" = 7)
	player.mutation_rarity = "Common"
	player.mutation_save_version = CHARACTER_MUTATION_SAVE_VERSION
	player.Race = "Demon"
	player.energy_save_version = 0
	player.player_profile_name = "The Archivist"
	player.player_profile_title = "Keeper of Safe Markup"
	player.player_desc = "\[color=#74a7ff]\[i]A persisted profile.\[/i]\[/color]"
	player.player_profile_portrait_direction = NORTH
	player.player_profile_markup_version = 1
	player.player_profile_portrait_mode = "custom"
	player.player_profile_art_hash = sha1("nexus-profile-art-serialization-smoke")
	player.player_profile_art_format = "jpg"
	player.player_profile_art_bytes = 4096
	player.player_profile_art_width = 192
	player.player_profile_art_height = 224
	player.player_profile_art_version = nexus_profile_art_policy_version
	var/savefile/energy_save = new("nexus-smoke-energy.sav")
	player.Write(energy_save)
	var/mob/NexusSmokeTest/loaded_player = new
	loaded_player.Read(energy_save)
	loaded_player.normalize_energy_types()
	nexusSmokeAssert(loaded_player.get_energy("Mental Energy").quantity == 25, "energy state did not survive serialization")
	nexusSmokeAssert(loaded_player.get_energy("Soul Energy"), "legacy Demon did not receive Soul Energy")
	nexusSmokeAssert(!loaded_player.get_energy("Qi"), "legacy Qi energy was not removed after deserialization")
	nexusSmokeAssert(loaded_player.energy_save_version == ENERGY_SAVE_VERSION, "energy save migration version was not recorded")
	nexusSmokeAssert(loaded_player.character_mutations["reactive_guard"] == 7, "character mutation did not survive serialization")
	nexusSmokeAssert(loaded_player.mutation_rarity == "Common", "character mutation rarity did not survive serialization")
	nexusSmokeAssert(loaded_player.player_profile_name == player.player_profile_name && loaded_player.player_profile_title == player.player_profile_title && loaded_player.player_desc == player.player_desc && loaded_player.player_profile_portrait_direction == NORTH && loaded_player.player_profile_markup_version == 1 && loaded_player.player_profile_portrait_mode == "custom" && loaded_player.player_profile_art_hash == player.player_profile_art_hash && loaded_player.player_profile_art_format == "jpg" && loaded_player.player_profile_art_bytes == 4096 && loaded_player.player_profile_art_width == 192 && loaded_player.player_profile_art_height == 224 && loaded_player.player_profile_art_version == nexus_profile_art_policy_version, "structured player profile or raw custom-art metadata did not survive character serialization")
	loaded_player.remove_energy_type("Mental Energy")
	loaded_player.normalize_energy_types()
	nexusSmokeAssert(!loaded_player.get_energy("Mental Energy"), "completed migration restored an intentionally removed energy")
	nexusSmokeAssert(!GLOBAL_ENERGY_TYPES["Qi"], "Qi remains registered")

	var/list/expected_technology_types = list()
	for(var/technology_type in typesof(/obj))
		if(initial(technology_type:Cost))
			expected_technology_types += technology_type
	nexusSmokeAssert(tech_list.len == expected_technology_types.len, "technology catalog has an unexpected entry count")
	nexusSmokeAssert(soul_contracts.len == soul_contract_count_before, "technology initialization created a Contract Soul")
	var/legacy_sword_recipe_disabled = FALSE
	var/legacy_armor_recipe_disabled = FALSE
	var/obj/items/Sword/legacy_sword_reference
	var/obj/items/Armor/legacy_armor_reference
	var/obj/Forge/forge_science_reference
	var/obj/items/Gloves/Forged/Science/normal_gloves_reference
	var/obj/items/Shikon_Jewel/shikon_science_reference
	var/list/forged_science_replacements = list()
	for(var/obj/technology in tech_list)
		nexusSmokeAssert(technology.Cost, "technology catalog contains an object without Cost")
		nexusSmokeAssert(technology.referenceObject, "technology catalog entry is not marked as a reference")
		nexusSmokeAssert(!istype(technology, /obj/Contract_Soul), "Contract Soul was added to the technology catalog")
		nexusSmokeAssert(technology.type in expected_technology_types, "technology was instantiated more than once: [technology.type]")
		if(technology.type == /obj/items/Sword)
			legacy_sword_recipe_disabled = !technology.science
			legacy_sword_reference = technology
		else if(technology.type == /obj/items/Armor)
			legacy_armor_recipe_disabled = !technology.science
			legacy_armor_reference = technology
		else if(technology.type == /obj/Forge)
			forge_science_reference = technology
		else if(technology.type == /obj/items/Shikon_Jewel)
			shikon_science_reference = technology
		else if(technology.type in list(/obj/items/Sword/Forged/Science, /obj/items/Sword/Forged/ScienceHammer, /obj/items/Gloves/Forged/Science, /obj/items/Mask/Forged/Science))
			if(technology.science && technology.science_level == 1) forged_science_replacements += technology.type
			if(technology.type == /obj/items/Gloves/Forged/Science) normal_gloves_reference = technology
		expected_technology_types -= technology.type
	nexusSmokeAssert(!expected_technology_types.len, "technology catalog is missing eligible types: [expected_technology_types.Join(", ")]")
	nexusSmokeAssert(legacy_sword_recipe_disabled && legacy_armor_recipe_disabled, "legacy DU Sword or Armor is still enabled in Science")
	nexusSmokeAssert(forged_science_replacements.len == 4, "Science did not replace legacy equipment with Normal Sword, Hammer, Gloves and Mask")
	nexusSmokeAssert(shikon_science_reference && !shikon_science_reference.science && isRetiredScienceEquipment(shikon_science_reference) && !progression_node_catalog[getProgressionScienceNodeIdForType(/obj/items/Shikon_Jewel)], "Shikon Jewel remains available through Science")
	var/datum/ProgressionNode/forge_progression_node = progression_node_catalog[getProgressionScienceNodeIdForType(/obj/Forge)]
	nexusSmokeAssert(forge_science_reference && forge_science_reference.science_level == 3 && !forge_science_reference.science_path && forge_progression_node && forge_progression_node.branch == "Foundation", "Nexus Forge is not discoverable in the Science Foundation")
	var/mob/NexusSmokeTest/science_equipment_migration_test = new
	science_equipment_migration_test.player_tech_level = 1
	science_equipment_migration_test.progression_tree_version = 1
	science_equipment_migration_test.individual_science_items = list(legacy_sword_reference, legacy_armor_reference)
	science_equipment_migration_test.syncProgressionTrees(silent = TRUE)
	nexusSmokeAssert(science_equipment_migration_test.hasProgressionReward(/obj/items/Sword/Forged/Science) && science_equipment_migration_test.hasProgressionReward(/obj/items/Sword/Forged/ScienceHammer) && science_equipment_migration_test.hasProgressionReward(/obj/items/Gloves/Forged/Science) && science_equipment_migration_test.hasProgressionReward(/obj/items/Mask/Forged/Science), "existing Technology progression did not migrate to the four Normal Science equipment recipes")
	nexusSmokeAssert(!science_equipment_migration_test.canAccessTechnology(legacy_sword_reference) && !science_equipment_migration_test.canAccessTechnology(legacy_armor_reference), "legacy DU equipment remained accessible through saved individual Science overrides")
	var/mob/NexusSmokeTest/shikon_research_migration_test = new
	shikon_research_migration_test.progression_tree_version = NEXUS_PROGRESSION_VERSION
	shikon_research_migration_test.magic_progression_version = 1
	shikon_research_migration_test.progression_nodes_owned = list()
	shikon_research_migration_test.progression_nodes_owned[getProgressionScienceNodeIdForType(/obj/items/Shikon_Jewel)] = 1
	shikon_research_migration_test.individual_science_items = list(shikon_science_reference)
	shikon_research_migration_test.syncMagicProgression(silent = TRUE)
	nexusSmokeAssert(shikon_research_migration_test.hasProgressionNode("magic_shikon_jewel") && !shikon_research_migration_test.hasProgressionNode(getProgressionScienceNodeIdForType(/obj/items/Shikon_Jewel)) && !scienceBlueprintListContainsType(shikon_research_migration_test.individual_science_items, /obj/items/Shikon_Jewel), "legacy Shikon Science ownership did not migrate to Magic")
	del(shikon_research_migration_test)
	var/obj/items/Gloves/Forged/Science/saved_gloves_copy_a = new
	var/obj/items/Gloves/Forged/Science/saved_gloves_copy_b = new
	saved_gloves_copy_a.referenceObject = TRUE
	saved_gloves_copy_b.referenceObject = TRUE
	science_equipment_migration_test.individual_science_items = list(saved_gloves_copy_a, saved_gloves_copy_b, normal_gloves_reference)
	var/datum/NexusBuildWindow/science_catalog_deduplication_test = new(science_equipment_migration_test)
	var/normal_gloves_catalog_entries = 0
	for(var/obj/blueprint in science_catalog_deduplication_test.getScienceBlueprints())
		if(blueprint.type == /obj/items/Gloves/Forged/Science) normal_gloves_catalog_entries++
	nexusSmokeAssert(normal_gloves_catalog_entries == 1, "Science catalog renders duplicate blueprints of the same type")
	del(science_catalog_deduplication_test)
	var/removed_science_duplicates = science_equipment_migration_test.normalizeIndividualScienceItems()
	nexusSmokeAssert(removed_science_duplicates == 2 && length(science_equipment_migration_test.individual_science_items) == 1 && science_equipment_migration_test.individual_science_items[1] == normal_gloves_reference, "saved Science blueprints were not deduplicated and rebound to the canonical technology reference")
	science_equipment_migration_test.individual_science_items = list(saved_gloves_copy_a)
	var/datum/ProgressionNode/normal_gloves_progression_node = progression_node_catalog[getProgressionScienceNodeIdForType(/obj/items/Gloves/Forged/Science)]
	science_equipment_migration_test.applyProgressionNodeReward(normal_gloves_progression_node, announce = FALSE)
	science_equipment_migration_test.applyProgressionNodeReward(normal_gloves_progression_node, announce = FALSE)
	nexusSmokeAssert(length(science_equipment_migration_test.individual_science_items) == 1 && scienceBlueprintListContainsType(science_equipment_migration_test.individual_science_items, /obj/items/Gloves/Forged/Science), "reapplying a loaded Science reward duplicated its blueprint reference")
	del(saved_gloves_copy_a)
	del(saved_gloves_copy_b)
	del(science_equipment_migration_test)
	if(tech_list.len)
		var/obj/technology_search_test = tech_list[1]
		nexusSmokeAssert(technology_search_test in searchTechnologyCatalog(technology_search_test.name), "technology prefix index cannot find a registered recipe")
	if(Builds.len)
		var/obj/Build/build_search_test = Builds[1]
		nexusSmokeAssert(build_search_test in getBuildCatalogForCategory(build_search_test.build_category), "build category index omitted a registered recipe")
		nexusSmokeAssert(build_search_test in searchBuildCatalog(build_search_test.name, build_search_test.build_category), "build prefix index cannot find a registered recipe")
	runNexusActionCycleSmoke()

	del(loaded_player)
	del(player)
	world.log << "NEXUS_SMOKE_TESTS_PASSED"
