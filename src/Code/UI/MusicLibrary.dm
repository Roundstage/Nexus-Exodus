client/var/tmp/datum/NexusMusicLibraryWindow/nexus_music_library_window

proc/formatNexusPlayerMusicBytes(byte_count)
	if(!isnum(byte_count) || byte_count < 0) return "0 B"
	if(byte_count >= 1024 * 1024) return "[round(byte_count / 1024 / 1024, 0.01)] MiB"
	if(byte_count >= 1024) return "[round(byte_count / 1024, 0.1)] KiB"
	return "[round(byte_count)] B"

proc/formatNexusPlayerMusicDuration(duration_seconds)
	if(!nexusIsFiniteNumber(duration_seconds) || duration_seconds < 0) return "--:--"
	var/whole_seconds = max(0, round(duration_seconds))
	var/minutes = round(whole_seconds / 60)
	var/remaining_seconds = whole_seconds - minutes * 60
	return "[minutes]:[remaining_seconds < 10 ? "0" : ""][remaining_seconds]"

datum/NexusMusicLibraryWindow
	var/tmp/mob/owner
	var/account_key = ""
	var/render_generation
	var/busy
	var/feedback = ""
	var/feedback_error
	var/pending_upload_ticket = ""

	New(mob/new_owner)
		. = ..()
		owner = new_owner
		if(owner) account_key = ckey(owner.key)

	Del()
		if(owner)
			if(owner.client && owner.client.nexus_music_validation_window == src)
				owner.client.cancelNexusPlayerMusicValidation()
			if(owner.client && length(pending_upload_ticket) && owner.client.nexus_music_upload_window == src)
				owner.client.cancelNexusPlayerMusicUploadState()
			owner << browse(null, "window=NexusMusicLibrary")
			if(owner.client && owner.client.nexus_music_library_window == src)
				owner.client.nexus_music_library_window = null
		owner = null
		. = ..()

	proc/canUse()
		return owner && owner.client && owner.playerCharacter && usr == owner && owner.client.nexus_music_library_window == src && ckey(owner.key) == account_key

	proc/hasLiveOwner()
		return owner && owner.client && owner.playerCharacter && owner.client.nexus_music_library_window == src && ckey(owner.key) == account_key

	proc/getLibrary()
		if(!hasLiveOwner()) return null
		return getNexusPlayerMusicLibrary(account_key)

	proc/setFeedback(message, is_error = FALSE)
		feedback = "[message]"
		feedback_error = is_error

	proc/finishAction(message = "", is_error = FALSE)
		busy = FALSE
		if(length(message)) setFeedback(message, is_error)
		if(hasLiveOwner()) show()

	proc/buildCustomTrackCards(datum/NexusPlayerMusicLibrary/library)
		var/html = ""
		for(var/datum/NexusPlayerMusicTrack/track in library.tracks)
			var/uploaded_text = track.uploaded_at ? time2text(track.uploaded_at, "MMM DD, YYYY") : "UNKNOWN DATE"
			var/track_title = html_encode(track.title)
			var/track_size = formatNexusPlayerMusicBytes(track.byte_size)
			var/ready = track.isReady()
			var/validation_text = ready ? "READY &middot; [formatNexusPlayerMusicDuration(track.duration_seconds)]" : "PENDING DECODER CHECK"
			var/primary_action = ready ? "<a class='hud-button play' href='byond://?src=\ref[src]&action=play_custom&id=[track.id]&generation=[render_generation]'>PLAY NEARBY</a>" : "<a class='hud-button validate' href='byond://?src=\ref[src]&action=validate&id=[track.id]&generation=[render_generation]'>VALIDATE</a>"
			html += {"<article class='track hud-card'>
				<div class='track-icon hud-sprite'>OGG</div>
				<div class='track-copy'><span class='hud-label'>PERSONAL TRACK</span><b>[track_title]</b><small>[track_size] &middot; uploaded [uploaded_text]</small><span class='validation [ready ? "ready" : "pending"]'>[validation_text]</span></div>
				<div class='track-actions'>[primary_action]<a class='hud-button' href='byond://?src=\ref[src]&action=rename&id=[track.id]&generation=[render_generation]'>RENAME</a><a class='hud-button danger' href='byond://?src=\ref[src]&action=delete&id=[track.id]&generation=[render_generation]'>DELETE</a></div>
			</article>"}
		if(!length(html))
			html = "<div class='empty hud-panel'><b>NO PERSONAL TRACKS</b><span>Upload an OGG/Vorbis file to build your action-music library.</span></div>"
		return html

	proc/buildBuiltInTrackCards()
		var/html = ""
		var/list/catalog = getNexusBuiltInMusicCatalog()
		for(var/track_id in catalog)
			var/list/track = catalog[track_id]
			if(!islist(track)) continue
			html += {"<article class='track hud-card builtin'>
				<div class='track-icon hud-sprite'>NX</div>
				<div class='track-copy'><span class='hud-label'>SERVER TRACK</span><b>[html_encode(track["title"])]</b><small>Bundled with Nexus Exodus</small></div>
				<div class='track-actions'><a class='hud-button play' href='byond://?src=\ref[src]&action=play_builtin&id=[track_id]&generation=[render_generation]'>PLAY NEARBY</a></div>
			</article>"}
		return html

	proc/buildHtml()
		var/datum/NexusPlayerMusicLibrary/library = getLibrary()
		if(!library) return ""
		var/total_bytes = library.getTotalBytes()
		var/cooldown_ticks = owner.getNexusPlayerMusicPlaybackCooldownTicks()
		var/cooldown_text = cooldown_ticks > 0 ? "[round(cooldown_ticks / 10, 0.1)]s" : "READY"
		var/mute_text = owner.block_music ? "MUTED" : "ENABLED"
		var/mute_action = owner.block_music ? "UNMUTE MUSIC" : "MUTE MUSIC"
		var/storage_limit_text = formatNexusPlayerMusicBytes(nexus_player_music_max_total_bytes)
		var/file_limit_text = formatNexusPlayerMusicBytes(nexus_player_music_max_file_bytes)
		var/session_minutes = round(nexus_player_music_session_limit / 10 / 60, 0.1)
		var/upload_action = isNexusPlayerMusicGuestKey(owner.key) ? "<span class='hud-button disabled'>UPLOAD REQUIRES ACCOUNT</span>" : "<a class='hud-button' href='byond://?src=\ref[src]&action=upload&generation=[render_generation]'>UPLOAD OGG</a>"
		var/feedback_html = length(feedback) ? "<div class='feedback hud-panel [feedback_error ? "error" : "success"]'>[html_encode(feedback)]</div>" : ""
		var/custom_tracks = buildCustomTrackCards(library)
		var/built_in_tracks = buildBuiltInTrackCards()
		return {"<!doctype html><html><head><meta charset='utf-8'><title>Music Library</title><style>[getNexusHudBrowserCss("bronze")]
		*{box-sizing:border-box}html,body{margin:0;min-height:100%;background:#120d08;color:#f3dfb7;font:12px Arial,sans-serif}.shell{min-height:100vh;padding:12px;background:radial-gradient(circle at 78% 4%,#3b2514 0,#1d140d 32%,#0e0a07 78%)}
		.nexus-hud .header{position:sticky;top:0;z-index:4;padding:12px}.top{display:flex;align-items:center;gap:8px}.title{margin-right:auto}.title b{display:block;font-size:22px;letter-spacing:2px}.title small{display:block;margin-top:3px}.toolbar{display:flex;gap:6px;flex-wrap:wrap}.hud-button{display:inline-block;padding:9px 11px;text-decoration:none}.hud-button.disabled{opacity:.48;cursor:not-allowed}.hud-button.play{border-color:#d3a552!important;color:#ffe3a0!important}.hud-button.validate{border-color:#6ca5ca!important;color:#bde5ff!important}.status{display:grid;grid-template-columns:repeat(4,1fr);gap:7px;margin-top:9px}.status>div{padding:8px 10px}.status small,.status b{display:block}.status b{margin-top:4px;font:16px Consolas,monospace}.feedback{margin:9px 0 0;padding:9px 12px;border-left:4px solid #62c883!important}.feedback.error{border-left-color:#ef6372!important;color:#ffc0c7}.feedback.success{color:#baf1c8}
		.section{margin-top:10px;padding:10px}.section-head{display:flex;align-items:flex-end;justify-content:space-between;margin-bottom:7px}.section-head h2{margin:0}.section-head span{font-size:10px}.track-list{display:grid;gap:7px}.track{display:grid;grid-template-columns:54px minmax(220px,1fr) auto;gap:10px;align-items:center;padding:9px}.track-icon{width:48px;height:48px;display:flex;align-items:center;justify-content:center;color:#ffcf6f;font:bold 12px Consolas,monospace}.track-copy b,.track-copy span,.track-copy small{display:block}.track-copy b{margin:4px 0;font-size:14px}.track-copy small{color:#ad9877}.validation{margin-top:5px;font:9px Consolas,monospace;letter-spacing:1px}.validation.ready{color:#7fe0a1}.validation.pending{color:#8eccef}.track-actions{display:flex;gap:5px;flex-wrap:wrap;justify-content:flex-end}.builtin{border-left:3px solid #96703d!important}.empty{padding:18px;text-align:center}.empty b,.empty span{display:block}.empty span{margin-top:6px;color:#a58d68}.safety{margin-top:10px;padding:10px 12px;line-height:1.5}.safety b{color:#ffd47f}.safety code{color:#e9bd6b}.busy{opacity:.65;pointer-events:none}@media(max-width:760px){.status{grid-template-columns:1fr 1fr}.track{grid-template-columns:46px 1fr}.track-icon{width:40px;height:40px}.track-actions{grid-column:1/3;justify-content:flex-start}.top{align-items:flex-start;flex-wrap:wrap}.toolbar{width:100%}}
		</style></head><body class='nexus-hud'><main class='shell [busy ? "busy" : ""]'>
		<header class='header hud-frame'><div class='top'><div class='title'><b class='hud-title'>MUSIC LIBRARY</b><small class='hud-muted'>Personal action tracks / nearby playback</small></div><div class='toolbar'>[upload_action]<a class='hud-button' href='byond://?src=\ref[src]&action=stop_self&generation=[render_generation]'>STOP FOR ME</a><a class='hud-button' href='byond://?src=\ref[src]&action=stop_broadcast&generation=[render_generation]'>STOP MY BROADCAST</a><a class='hud-button' href='byond://?src=\ref[src]&action=toggle_mute&generation=[render_generation]'>[mute_action]</a><a class='hud-button' href='byond://?src=\ref[src]&action=refresh&generation=[render_generation]'>REFRESH</a><a class='hud-button danger' href='byond://?src=\ref[src]&action=close&generation=[render_generation]'>CLOSE</a></div></div>
		<div class='status'><div class='hud-panel'><small class='hud-label'>TRACKS</small><b>[library.tracks.len] / [nexus_player_music_max_tracks]</b></div><div class='hud-panel'><small class='hud-label'>STORAGE</small><b>[formatNexusPlayerMusicBytes(total_bytes)] / [storage_limit_text]</b></div><div class='hud-panel'><small class='hud-label'>BROADCAST</small><b>[cooldown_text]</b></div><div class='hud-panel'><small class='hud-label'>RECEIVING</small><b>[mute_text]</b></div></div>[feedback_html]</header>
		<section class='section hud-frame'><div class='section-head'><h2 class='hud-section-title'>MY TRACKS</h2><span class='hud-muted'>[file_limit_text] each &middot; [nexus_player_music_max_tracks] per account</span></div><div class='track-list'>[custom_tracks]</div></section>
		<section class='section hud-frame'><div class='section-head'><h2 class='hud-section-title'>SERVER TRACKS</h2><span class='hud-muted'>Built-in music remains available</span></div><div class='track-list'>[built_in_tracks]</div></section>
		<footer class='safety hud-frame'><b>CONTROLLED PLAYBACK:</b> uploads are limited before transfer, SHA-1 fingerprinted, stored under a server-generated ID and never rendered as remote HTML. Personal tracks remain quarantined until a muted DreamSeeker compatibility probe reports a matching file and at most [session_minutes] minutes. Playback uses one isolated channel and is forcibly stopped at that limit. This client probe is not server-side transcoding or proof that arbitrary media is safe; operators must continue treating uploads as untrusted files.</footer>
		</main></body></html>"}

	proc/show()
		if(!hasLiveOwner())
			del(src)
			return
		render_generation++
		prepareNexusHudBrowserResources(owner)
		owner << browse(buildHtml(), "window=NexusMusicLibrary;size=1040x720;can_resize=true;can_close=false")

	proc/clearUploadState(client/upload_client, ticket)
		if(!upload_client) return
		if(pending_upload_ticket == ticket) pending_upload_ticket = ""
		upload_client.clearNexusPlayerMusicUploadState(ticket)

	proc/uploadTrack()
		if(!canUse() || busy) return
		var/datum/NexusPlayerMusicLibrary/library = getLibrary()
		if(!library) return
		if(isNexusPlayerMusicGuestKey(owner.key))
			finishAction("Guest accounts cannot upload persistent music. Sign in with a registered BYOND account first.", TRUE)
			return
		if(owner.client.isNexusUploadBrokerBusy())
			finishAction("Finish or cancel the existing file prompt before starting another upload.", TRUE)
			return
		if(library.tracks.len >= nexus_player_music_max_tracks)
			finishAction("Your library already has five tracks.", TRUE)
			return
		busy = TRUE
		var/client/upload_client = owner.client
		var/ticket = md5("music-upload|[account_key]|[world.realtime]|[world.time]|[render_generation]|[rand(1, 2147483647)]")
		pending_upload_ticket = ticket
		upload_client.nexus_music_upload_state = "awaiting"
		upload_client.nexus_music_upload_window = src
		upload_client.nexus_music_upload_ticket = ticket
		upload_client.nexus_music_upload_account_key = account_key
		upload_client.nexus_music_upload_expires = world.time + nexus_player_music_upload_ticket_lifetime
		upload_client.nexus_music_upload_accepted_ticket = ""
		upload_client.nexus_music_upload_filename = ""
		upload_client.nexus_music_upload_size = 0
		show()
		var/uploaded_file = input(owner, "Choose an OGG/Vorbis file. The transfer is rejected before upload if it exceeds 5 MiB.", "Upload Action Music") as file|null
		var/upload_was_accepted = upload_client && upload_client.nexus_music_upload_state == "accepted" && upload_client.nexus_music_upload_accepted_ticket == ticket && upload_client.nexus_music_upload_accepted_window == src
		var/original_name = upload_was_accepted ? upload_client.nexus_music_upload_filename : ""
		var/authorized_size = upload_was_accepted ? upload_client.nexus_music_upload_size : 0
		clearUploadState(upload_client, ticket)
		if(!canUse() || owner.client != upload_client)
			busy = FALSE
			return
		if(!uploaded_file || !upload_was_accepted)
			finishAction("Upload canceled or rejected before transfer.", TRUE)
			return
		if(length(uploaded_file) != authorized_size)
			finishAction("The uploaded file did not match its authorized size.", TRUE)
			return
		var/list/inspection = inspectNexusPlayerMusicUpload(uploaded_file, original_name)
		if(!inspection["ok"])
			finishAction(inspection["error"], TRUE)
			return
		var/requested_title = input(owner, "Choose the title shown to nearby players. Paths and original filenames are never published.", "Track Title", "Custom Track") as text|null
		if(!canUse() || owner.client != upload_client)
			busy = FALSE
			return
		if(isnull(requested_title))
			finishAction("Upload canceled before storage.", TRUE)
			return
		library = getLibrary()
		var/list/store_result = library.addUpload(uploaded_file, requested_title, inspection)
		if(!store_result["ok"])
			finishAction(store_result["error"], TRUE)
			return
		var/datum/NexusPlayerMusicTrack/track = store_result["track"]
		validateTrack(track.id, TRUE)

	proc/validateTrack(track_id, action_in_progress = FALSE)
		if(!canUse()) return
		if(!action_in_progress)
			if(busy) return
			busy = TRUE
		var/datum/NexusPlayerMusicLibrary/library = getLibrary()
		var/datum/NexusPlayerMusicTrack/track = library ? library.findTrack(track_id) : null
		if(!track)
			finishAction("That track no longer belongs to your library.", TRUE)
			return
		if(track.isReady())
			finishAction("[track.title] is already validated ([formatNexusPlayerMusicDuration(track.duration_seconds)]).")
			return
		var/cooldown_ticks = library.getValidationCooldownTicks()
		if(cooldown_ticks > 0)
			var/pending_prefix = action_in_progress ? "[track.title] was uploaded and remains PENDING. " : ""
			finishAction("[pending_prefix]Wait [round(cooldown_ticks / 10, 0.1)] seconds before another decoder check.", TRUE)
			return
		var/global_cooldown_ticks = max(0, nexus_player_music_next_global_validation_time - world.time)
		if(global_cooldown_ticks > 0)
			var/global_pending_prefix = action_in_progress ? "[track.title] was uploaded and remains PENDING. " : ""
			finishAction("[global_pending_prefix]The decoder-validation channel is busy. Try again in a moment.", TRUE)
			return
		var/expected_hash = track.content_hash
		var/expected_title = track.title
		var/path = library.getTrackPath(track.id)
		var/client/validation_client = owner.client
		if(!library.isTrackFileValid(track, TRUE))
			finishAction("The stored track failed its integrity check and cannot be validated.", TRUE)
			return
		library.recordValidationAttempt()
		setFeedback("DreamSeeker is checking [expected_title]. This can take a few seconds.")
		show()
		var/list/validation_result = validation_client.validateNexusPlayerMusicFile(file(path), src, track.id, expected_hash)
		if(!canUse() || owner.client != validation_client)
			busy = FALSE
			return
		library = getLibrary()
		track = library ? library.findTrack(track_id) : null
		if(!track || track.content_hash != expected_hash)
			finishAction("The selected track changed during decoder validation.", TRUE)
			return
		if(!islist(validation_result) || !validation_result["ok"] || validation_result["track_id"] != track.id || validation_result["hash"] != expected_hash)
			var/validation_error = islist(validation_result) && length(validation_result["error"]) ? validation_result["error"] : "DreamSeeker could not decode this track."
			finishAction("[expected_title] was stored but remains PENDING. [validation_error] Retry or delete it.", TRUE)
			return
		if(!library.isTrackFileValid(track, TRUE))
			finishAction("The stored track changed during decoder validation and remains quarantined.", TRUE)
			return
		var/duration_seconds = validation_result["duration"]
		if(!nexusIsFiniteNumber(duration_seconds) || duration_seconds <= 0)
			finishAction("[expected_title] was stored, but DreamSeeker could not decode it. It remains quarantined; retry or delete it.", TRUE)
			return
		var/maximum_duration = nexus_player_music_max_duration_seconds
		if(duration_seconds > maximum_duration)
			finishAction("[expected_title] is [formatNexusPlayerMusicDuration(duration_seconds)] long and exceeds the [formatNexusPlayerMusicDuration(maximum_duration)] limit. It remains quarantined.", TRUE)
			return
		if(!library.markTrackValidated(track.id, expected_hash, duration_seconds))
			finishAction("The decoder check passed, but its result could not be saved.", TRUE)
			return
		finishAction("[expected_title] was validated ([formatNexusPlayerMusicDuration(duration_seconds)]) and is ready to play.")

	proc/playBuiltIn(track_id)
		var/list/catalog = getNexusBuiltInMusicCatalog()
		var/list/track = catalog[track_id]
		if(!islist(track))
			finishAction("That server track does not exist.", TRUE)
			return
		var/list/play_result = owner.broadcastNexusPlayerMusic(track["file"], track["title"], "builtin:[track_id]")
		if(!play_result["ok"])
			finishAction(play_result["error"], TRUE)
			return
		finishAction("[track["title"]] is playing for [play_result["listeners"]] nearby listener[play_result["listeners"] == 1 ? "" : "s"].")

	proc/playCustom(track_id)
		var/datum/NexusPlayerMusicLibrary/library = getLibrary()
		var/datum/NexusPlayerMusicTrack/track = library ? library.findTrack(track_id) : null
		if(!track)
			finishAction("That track no longer belongs to your library.", TRUE)
			return
		var/list/play_result = owner.broadcastNexusCustomTrack(track.id)
		if(!play_result["ok"])
			finishAction(play_result["error"], TRUE)
			return
		finishAction("[track.title] is playing for [play_result["listeners"]] nearby listener[play_result["listeners"] == 1 ? "" : "s"].")

	proc/renameTrack(track_id)
		if(busy) return
		var/datum/NexusPlayerMusicLibrary/library = getLibrary()
		var/datum/NexusPlayerMusicTrack/track = library ? library.findTrack(track_id) : null
		if(!track)
			finishAction("That track no longer belongs to your library.", TRUE)
			return
		busy = TRUE
		show()
		var/expected_hash = track.content_hash
		var/new_title = input(owner, "Enter a new display title (maximum [nexus_player_music_title_limit] bytes).", "Rename Track", track.title) as text|null
		if(!canUse())
			busy = FALSE
			return
		library = getLibrary()
		track = library ? library.findTrack(track_id) : null
		if(!track || track.content_hash != expected_hash)
			finishAction("The selected track changed while the prompt was open.", TRUE)
			return
		if(isnull(new_title))
			finishAction("Rename canceled.")
			return
		var/error = library.renameTrack(track_id, new_title)
		if(length(error)) finishAction(error, TRUE)
		else finishAction("Track renamed to [normalizeNexusPlayerMusicTitle(new_title)].")

	proc/deleteTrack(track_id)
		if(busy) return
		var/datum/NexusPlayerMusicLibrary/library = getLibrary()
		var/datum/NexusPlayerMusicTrack/track = library ? library.findTrack(track_id) : null
		if(!track)
			finishAction("That track no longer belongs to your library.", TRUE)
			return
		busy = TRUE
		show()
		var/expected_hash = track.content_hash
		var/expected_title = track.title
		if(alert(owner, "Delete [expected_title] from your account library? This cannot be undone.", "Delete Track", "Keep", "Delete") != "Delete")
			finishAction("Track kept.")
			return
		if(!canUse())
			busy = FALSE
			return
		library = getLibrary()
		track = library ? library.findTrack(track_id) : null
		if(!track || track.content_hash != expected_hash)
			finishAction("The selected track changed while confirmation was open.", TRUE)
			return
		owner.stopNexusPlayerMusicTrack("custom:[account_key]:[track.id]")
		var/error = library.deleteTrack(track.id)
		if(length(error)) finishAction(error, TRUE)
		else finishAction("[expected_title] was deleted from your library.")

	Topic(href, list/href_list)
		if(!canUse()) return
		var/request_generation = text2num(href_list["generation"])
		if(request_generation != render_generation) return
		var/action = href_list["action"]
		if(busy) return
		switch(action)
			if("upload") uploadTrack()
			if("play_builtin") playBuiltIn(href_list["id"])
			if("play_custom") playCustom(href_list["id"])
			if("validate") validateTrack(href_list["id"])
			if("rename") renameTrack(href_list["id"])
			if("delete") deleteTrack(href_list["id"])
			if("stop_self")
				owner.stopNexusPlayerMusicForSelf(FALSE)
				finishAction("Player music stopped for you; game effects remain active.")
			if("stop_broadcast")
				owner.stopNexusPlayerMusicBroadcast(FALSE)
				finishAction("Your current music broadcast was stopped.")
			if("toggle_mute")
				owner.block_music = !owner.block_music
				if(owner.block_music) owner.stopNexusPlayerMusicForSelf(FALSE)
				owner.save_player_settings()
				finishAction(owner.block_music ? "Nearby player music is now muted." : "Nearby player music is now enabled.")
			if("refresh")
				feedback = ""
				show()
			if("close") del(src)

mob/proc/showNexusMusicLibrary()
	if(!client || !playerCharacter) return
	if(client.isNexusUploadBrokerBusy())
		src << "Finish or cancel the active file prompt first."
		return
	if(client.nexus_music_library_window) del(client.nexus_music_library_window)
	client.nexus_music_library_window = new /datum/NexusMusicLibraryWindow(src)
	client.nexus_music_library_window.show()

mob/proc/toggleNexusMusicLibrary()
	if(!client || !playerCharacter) return
	if(client.isNexusUploadBrokerBusy())
		src << "Finish or cancel the active file prompt first."
		return
	if(client.nexus_music_library_window)
		if(client.nexus_music_library_window.busy)
			src << "Wait for the current music-library action to finish."
			return
		del(client.nexus_music_library_window)
		return
	showNexusMusicLibrary()

mob/verb/Play_Music()
	set name = "Music Library"
	set category = "Other"
	toggleNexusMusicLibrary()

mob/verb/Stop_Player_Music()
	set name = "Stop Player Music"
	set category = "Other"
	stopNexusPlayerMusicForSelf()
