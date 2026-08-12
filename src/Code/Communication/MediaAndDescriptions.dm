mob/var
	block_music
	player_desc = ""
	player_profile_name = ""
	player_profile_title = ""
	player_profile_portrait_direction = SOUTH
	player_profile_markup_version = 0

#define NEXUS_PLAYER_DESCRIPTION_LIMIT 3000
#define NEXUS_PLAYER_PROFILE_NAME_LIMIT 60
#define NEXUS_PLAYER_PROFILE_TITLE_LIMIT 80

mob/var/tmp
	last_nexus_profile_editor_open = 0
	last_nexus_profile_save = 0
	last_nexus_profile_view = 0

proc/normalizeNexusPlayerDescription(description)
	if(!istext(description)) return ""
	var/source_text = copytext("[description]", 1, 12001)
	source_text = replacetext(source_text, "[ascii2text(13)]\n", "\n")
	source_text = replacetext(source_text, ascii2text(13), "\n")
	var/plain_text = ""
	var/source_length = length(source_text)
	var/index = 1
	while(index <= source_length && length(plain_text) < NEXUS_PLAYER_DESCRIPTION_LIMIT)
		var/character = copytext(source_text, index, index + 1)
		if(character == "<")
			var/tag_end = findtext(source_text, ">", index + 1)
			if(tag_end)
				var/tag_text = lowertext(copytext(source_text, index + 1, tag_end))
				if(tag_text == "br" || tag_text == "br/" || tag_text == "/p" || tag_text == "/div" || tag_text == "/li") plain_text += "\n"
				index = tag_end + 1
				continue
		var/character_code = text2ascii(character)
		if(character_code < 32)
			if(character == "\n") plain_text += character
			else if(character == "\t") plain_text += " "
			index++
			continue
		plain_text += character
		index++
	plain_text = replacetext(plain_text, "&nbsp;", " ")
	plain_text = replacetext(plain_text, "&quot;", "\"")
	plain_text = replacetext(plain_text, "&#39;", "'")
	plain_text = replacetext(plain_text, "&lt;", "<")
	plain_text = replacetext(plain_text, "&gt;", ">")
	plain_text = replacetext(plain_text, "&amp;", "&")
	while(findtext(plain_text, "\n\n\n")) plain_text = replacetext(plain_text, "\n\n\n", "\n\n")
	return copytext(plain_text, 1, NEXUS_PLAYER_DESCRIPTION_LIMIT + 1)

proc/renderNexusPlayerDescription(description, markup_version = 1)
	var/normalized_description = normalizeNexusPlayerDescription(description)
	if(text2num("[markup_version]") >= 1) return renderNexusEmoteMarkup(normalized_description)
	return replacetext(html_encode(normalized_description), "\n", "<br>")

proc/normalizeNexusPlayerProfileLine(value, maximum_length)
	var/plain_text = normalizeNexusPlayerDescription(value)
	plain_text = replacetext(plain_text, "\n", " ")
	while(findtext(plain_text, "  ")) plain_text = replacetext(plain_text, "  ", " ")
	while(length(plain_text) && copytext(plain_text, 1, 2) == " ") plain_text = copytext(plain_text, 2)
	while(length(plain_text) && copytext(plain_text, length(plain_text), length(plain_text) + 1) == " ") plain_text = copytext(plain_text, 1, length(plain_text))
	return copytext(plain_text, 1, max(1, maximum_length) + 1)

proc/normalizeNexusPlayerProfileDirection(direction_value)
	direction_value = text2num("[direction_value]")
	if(direction_value in list(NORTH, SOUTH, EAST, WEST)) return direction_value
	return SOUTH

proc/getNexusPlayerProfileDirectionName(direction_value)
	switch(normalizeNexusPlayerProfileDirection(direction_value))
		if(NORTH) return "Back"
		if(EAST) return "Right"
		if(WEST) return "Left"
	return "Front"

proc/getNexusPlayerProfileDisplayName(mob/subject)
	if(!subject) return "Unknown Character"
	var/profile_name = normalizeNexusPlayerProfileLine(subject.player_profile_name, NEXUS_PLAYER_PROFILE_NAME_LIMIT)
	if(profile_name) return profile_name
	return normalizeNexusPlayerProfileLine(subject.name, NEXUS_PLAYER_PROFILE_NAME_LIMIT)

proc/encodeNexusHtmlAttribute(value)
	var/encoded_value = html_encode("[value]")
	encoded_value = replacetext(encoded_value, "'", "&#39;")
	encoded_value = replacetext(encoded_value, "\"", "&quot;")
	return encoded_value

mob/proc/isNexusProfileEditingBlocked()
	for(var/obj/Imitation/imitation_skill in contents)
		if(imitation_skill.imitating) return TRUE
	return FALSE

mob/proc/canPersistNexusPlayerProfile()
	return playerCharacter && !dbz_character && !is_saitama && Savable && player_saving_on && key && displaykey && getNexusCharacterSavePath()

mob/proc/isNexusPlayerProfileTextPersisted()
	var/save_path = getNexusCharacterSavePath()
	if(!save_path || !fexists(save_path)) return FALSE
	var/savefile/profile_save = new(save_path)
	var/saved_description
	var/saved_name
	var/saved_title
	var/saved_direction
	var/saved_markup_version
	profile_save["player_desc"] >> saved_description
	profile_save["player_profile_name"] >> saved_name
	profile_save["player_profile_title"] >> saved_title
	profile_save["player_profile_portrait_direction"] >> saved_direction
	profile_save["player_profile_markup_version"] >> saved_markup_version
	return "[saved_description]" == "[player_desc]" && "[saved_name]" == "[player_profile_name]" && "[saved_title]" == "[player_profile_title]" && text2num("[saved_direction]") == player_profile_portrait_direction && text2num("[saved_markup_version]") == player_profile_markup_version

client/var/tmp/datum/NexusPlayerDescriptionEditor/nexus_description_editor

datum/NexusPlayerDescriptionEditor
	var/tmp
		mob/owner
		busy = FALSE
		render_generation = 0
		feedback = ""
		feedback_error = FALSE
		pending_upload_ticket = ""
		draft_active = FALSE
		draft_description = ""
		draft_profile_name = ""
		draft_profile_title = ""
		draft_portrait_direction = SOUTH

	New(mob/new_owner)
		. = ..()
		owner = new_owner

	Del()
		if(owner && owner.client)
			if(length(pending_upload_ticket) && owner.client.nexus_profile_art_upload_window == src)
				owner.client.cancelNexusProfileArtUploadState()
			owner << browse(null, "window=NexusDescriptionEditor")
			if(owner.client.nexus_description_editor == src) owner.client.nexus_description_editor = null
		owner = null
		. = ..()

	proc/hasLiveOwner()
		return owner && owner.client && owner.canPersistNexusPlayerProfile() && !owner.isNexusProfileEditingBlocked() && owner.client.nexus_description_editor == src

	proc/canUse()
		return !busy && hasLiveOwner() && usr == owner

	proc/captureDraft(list/href_list)
		if(!islist(href_list)) return FALSE
		draft_description = normalizeNexusPlayerDescription(href_list["description"])
		draft_profile_name = normalizeNexusPlayerProfileLine(href_list["profile_name"], NEXUS_PLAYER_PROFILE_NAME_LIMIT)
		draft_profile_title = normalizeNexusPlayerProfileLine(href_list["profile_title"], NEXUS_PLAYER_PROFILE_TITLE_LIMIT)
		draft_portrait_direction = normalizeNexusPlayerProfileDirection(href_list["portrait_direction"])
		draft_active = TRUE
		return TRUE

	proc/applyDraft()
		if(!owner || !draft_active) return FALSE
		owner.player_desc = draft_description
		owner.player_profile_name = draft_profile_name
		owner.player_profile_title = draft_profile_title
		owner.player_profile_portrait_direction = draft_portrait_direction
		owner.player_profile_markup_version = 1
		return TRUE

	proc/captureOwnerProfileTextState()
		if(!owner) return null
		return list(
			"description" = owner.player_desc,
			"name" = owner.player_profile_name,
			"title" = owner.player_profile_title,
			"direction" = owner.player_profile_portrait_direction,
			"markup_version" = owner.player_profile_markup_version
		)

	proc/restoreOwnerProfileTextState(list/profile_state)
		if(!owner || !islist(profile_state)) return FALSE
		owner.player_desc = profile_state["description"]
		owner.player_profile_name = profile_state["name"]
		owner.player_profile_title = profile_state["title"]
		owner.player_profile_portrait_direction = profile_state["direction"]
		owner.player_profile_markup_version = profile_state["markup_version"]
		return TRUE

	proc/finishAction(message, is_error = FALSE)
		busy = FALSE
		feedback = "[message]"
		feedback_error = !!is_error
		if(hasLiveOwner()) show()

	proc/buildHtml(list/portrait_resources)
		var/current_name = draft_active ? draft_profile_name : (owner ? owner.player_profile_name : "")
		var/current_title = draft_active ? draft_profile_title : (owner ? owner.player_profile_title : "")
		var/current_description = draft_active ? draft_description : (owner ? owner.player_desc : "")
		var/current_direction_value = draft_active ? draft_portrait_direction : (owner ? owner.player_profile_portrait_direction : SOUTH)
		var/safe_name = encodeNexusHtmlAttribute(normalizeNexusPlayerProfileLine(current_name, NEXUS_PLAYER_PROFILE_NAME_LIMIT))
		var/safe_actual_name = encodeNexusHtmlAttribute(normalizeNexusPlayerProfileLine(owner ? owner.name : "Character", NEXUS_PLAYER_PROFILE_NAME_LIMIT))
		var/safe_title = encodeNexusHtmlAttribute(normalizeNexusPlayerProfileLine(current_title, NEXUS_PLAYER_PROFILE_TITLE_LIMIT))
		var/safe_value = html_encode(normalizeNexusPlayerDescription(current_description))
		var/current_direction = normalizeNexusPlayerProfileDirection(current_direction_value)
		var/has_stored_art = owner && owner.hasNexusPlayerProfileArtArtifact()
		var/has_custom_art = owner && owner.hasNexusPlayerProfileCustomArt() && length(portrait_resources["custom"])
		var/using_custom_art = has_custom_art && owner.player_profile_portrait_mode == "custom"
		var/current_portrait = using_custom_art ? portrait_resources["custom"] : (portrait_resources ? portrait_resources["[current_direction]"] : "")
		var/current_portrait_class = using_custom_art ? "custom-art" : "sprite-art hud-sprite"
		var/direction_options = ""
		var/portrait_script = ""
		for(var/profile_direction in list(SOUTH, WEST, EAST, NORTH))
			var/direction_key = "[profile_direction]"
			var/direction_name = getNexusPlayerProfileDirectionName(profile_direction)
			var/selected = profile_direction == current_direction ? " selected" : ""
			direction_options += "<option value='[profile_direction]'[selected]>[uppertext(direction_name)]</option>"
			if(length(portrait_script)) portrait_script += ","
			portrait_script += "'[profile_direction]':'[portrait_resources[direction_key]]'"
		var/direction_disabled = using_custom_art ? " disabled" : ""
		var/direction_name = using_custom_art ? "" : " name='portrait_direction'"
		var/direction_hidden = using_custom_art ? "<input type='hidden' name='portrait_direction' value='[current_direction]'>" : ""
		var/source_actions = ""
		if(has_stored_art)
			if(has_custom_art)
				if(using_custom_art) source_actions += "<button class='hud-button submit-action' type='submit' onclick=\"return setProfileAction('use_sprite')\">USE LIVE SPRITE</button>"
				else source_actions += "<button class='hud-button submit-action' type='submit' onclick=\"return setProfileAction('use_custom')\">USE CUSTOM ART</button>"
			source_actions += "<button class='hud-button submit-action' type='submit' onclick=\"return setProfileAction('upload_art')\">REPLACE IMAGE</button><button class='hud-button danger submit-action' type='submit' onclick=\"if(!confirm('Permanently delete the custom art for this character slot?'))return false;return setProfileAction('delete_art')\">DELETE ART</button>"
		else
			source_actions = "<button class='hud-button submit-action' type='submit' onclick=\"return setProfileAction('upload_art')\">UPLOAD IMAGE</button>"
		var/source_status = using_custom_art ? "CUSTOM ART / PLAYER-UPLOADED" : "LIVE SPRITE / CURRENT APPEARANCE"
		var/safe_feedback = html_encode(feedback)
		var/feedback_html = length(safe_feedback) ? "<div class='feedback [feedback_error ? "error" : "success"]'>[safe_feedback]</div>" : ""
		var/color_swatches = getNexusEmoteColorSwatchesHtml()
		return {"<!doctype html><html><head><meta charset='utf-8'><title>Character Profile</title><style>[getNexusHudBrowserCss("bronze")]
		.shell{max-width:1180px;margin:0 auto}.header{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:14px 18px;margin-bottom:10px}.header-copy{display:flex;flex-direction:column;gap:4px}.feedback{margin:0 0 10px;padding:9px 12px;border:1px solid}.feedback.success{color:#8de5a1;border-color:#3b7650;background:#102619}.feedback.error{color:#ff9aab;border-color:#853b4a;background:#2a1117}.workspace{display:grid;grid-template-columns:minmax(360px,.72fr) minmax(420px,1fr);gap:10px}.panel{padding:14px}.panel h2{margin:0 0 10px;padding:8px 10px;font-size:13px}.field{display:block;margin:0 0 11px}.field span{display:block;margin-bottom:5px}.field input,.field select{width:100%;padding:9px}.source-panel{margin:0 0 11px;padding:10px}.source-status{display:block;margin-bottom:8px}.source-actions{display:flex;gap:7px;flex-wrap:wrap}.source-note{display:block;margin-top:8px;font-size:9px;line-height:1.45}.toolbar{display:flex;align-items:center;gap:6px;flex-wrap:wrap;margin:0 0 8px;padding:8px}.toolbar button{min-width:34px;height:30px}.swatch{min-width:28px!important;width:28px;padding:0!important}.custom-color{width:42px!important;height:30px;padding:2px!important}.editor{display:block;width:100%;height:300px;padding:12px;resize:vertical;font-size:13px;line-height:1.55}.profile-card{min-height:570px;padding:18px}.profile-head{display:grid;grid-template-columns:190px 1fr;gap:16px;align-items:center;padding-bottom:16px;margin-bottom:16px;border-bottom:2px solid #715735}.portrait{width:190px;height:220px;padding:8px;display:flex;align-items:center;justify-content:center}.portrait img{width:auto;height:auto;max-width:170px;max-height:200px;object-fit:contain}.portrait.sprite-art img{image-rendering:pixelated}.portrait.custom-art img{image-rendering:auto}.portrait-source{display:block;margin-top:8px;font-size:9px}.profile-title{display:block;margin-bottom:8px;font-size:11px}.profile-name{display:block;font-size:22px}.profile-identity{display:block;margin-top:8px;font-size:9px}.profile-body{line-height:1.65;overflow-wrap:anywhere}.empty{color:#8f7958}.footer{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-top:10px;padding:12px 14px}.actions{display:flex;gap:8px}.hud-button{padding:9px 14px}.counter{font-size:11px}@media(max-width:850px){.workspace{grid-template-columns:1fr}.profile-card{min-height:400px}}@media(max-width:520px){.profile-head{grid-template-columns:1fr}.portrait{margin:0 auto}}
		</style></head><body class='nexus-hud'><form id='profileForm' class='shell hud-shell' action='byond://' method='get' onsubmit='return lockProfileForm()'><input type='hidden' name='src' value='\ref[src]'><input id='profileAction' type='hidden' name='action' value='save'><input type='hidden' name='generation' value='[render_generation]'><header class='header hud-frame'><div class='header-copy'><b class='hud-title'>PROFILE BUILDER</b><span class='hud-muted'>Upload a bounded PNG/JPEG or use the live sprite. External image links stay plain text and are never loaded for other players.</span></div><a class='hud-button danger' href='byond://?src=\ref[src]&action=close&generation=[render_generation]'>CLOSE</a></header>[feedback_html]<main class='workspace'><section class='panel hud-card'><h2 class='hud-section-title'>IDENTITY</h2><label class='field'><span class='hud-label'>PROFILE NAME</span><input id='profileName' name='profile_name' maxlength='[NEXUS_PLAYER_PROFILE_NAME_LIMIT]' value='[safe_name]' oninput='updatePreview()' placeholder='Name or nickname shown on this profile'></label><label class='field'><span class='hud-label'>TITLE</span><input id='profileTitle' name='profile_title' maxlength='[NEXUS_PLAYER_PROFILE_TITLE_LIMIT]' value='[safe_title]' oninput='updatePreview()' placeholder='A short epithet, role, or calling'></label><h2 class='hud-section-title'>PORTRAIT SOURCE</h2><div class='source-panel hud-panel'><b id='portraitSource' class='source-status hud-accent'>[source_status]</b><div class='source-actions'>[source_actions]</div><span class='source-note hud-muted'>PNG or JPEG &middot; 1&ndash;400 KiB &middot; maximum 256&times;256 &middot; made public to profile viewers. Raw files retain metadata such as EXIF/GPS; remove private metadata before uploading. Uploading also saves the fields currently in this builder.</span></div><label class='field'><span class='hud-label'>LIVE SPRITE ANGLE</span>[direction_hidden]<select id='portraitDirection'[direction_name] onchange='updatePortrait()'[direction_disabled]>[direction_options]</select></label><h2 class='hud-section-title'>BIOGRAPHY</h2><div class='toolbar hud-panel'><button class='hud-button' type='button' onclick="wrap('\[b]','\[/b]')"><b>B</b></button><button class='hud-button' type='button' onclick="wrap('\[i]','\[/i]')"><i>I</i></button><button class='hud-button' type='button' onclick="wrap('\[u]','\[/u]')"><u>U</u></button>[color_swatches]<input id='customColor' class='custom-color' type='color' value='#66d9ef' title='Custom color'><button class='hud-button' type='button' onclick='applyCustomColor()'>COLOR</button></div><textarea id='description' class='editor' name='description' maxlength='[NEXUS_PLAYER_DESCRIPTION_LIMIT]' autofocus oninput='updatePreview()' placeholder='Describe appearance, mannerisms, history, and details other players may notice...'>[safe_value]</textarea></section><section class='profile-card hud-card'><div class='profile-head'><div id='portraitFrame' class='portrait [current_portrait_class]'><img id='portrait' src='[current_portrait]' alt='Character portrait' onerror='profilePortraitFallback(this)'></div><div><span id='previewTitle' class='profile-title hud-accent'></span><b id='previewName' class='profile-name hud-title'></b><span id='actualIdentity' data-name='[safe_actual_name]' class='profile-identity hud-muted'>IN-GAME IDENTITY: [safe_actual_name]</span><span class='portrait-source hud-muted'>[source_status]</span></div></div><div id='previewBody' class='profile-body'></div></section></main><footer class='footer hud-frame'><div class='counter hud-muted'><b id='count'>0</b> / [NEXUS_PLAYER_DESCRIPTION_LIMIT] characters &middot; Supported: bold, italic, underline, color</div><div class='actions'><button class='hud-button' type='button' onclick='clearBiography()'>CLEAR BIO</button><button id='saveProfile' class='hud-button submit-action' type='submit' onclick=\"return setProfileAction('save')\">SAVE PROFILE</button></div></footer></form><script>
		var editor=document.getElementById('description'),preview=document.getElementById('previewBody'),count=document.getElementById('count'),actualName=document.getElementById('actualIdentity').getAttribute('data-name'),palette=\['#f5f7fa','#ffd166','#ff667a','#ff9f43','#69db7c','#66d9ef','#74a7ff','#bd93f9','#ff79c6'\],portraitResources={[portrait_script]};function escapeHtml(value){return value.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}function replaceToken(value,token,replacement){return value.split(token).join(replacement);}function renderMarkup(value){var rendered=escapeHtml(value).replace(/\\n/g,'<br>');rendered=replaceToken(rendered,'\[b]','<b>');rendered=replaceToken(rendered,'\[/b]','</b>');rendered=replaceToken(rendered,'\[i]','<i>');rendered=replaceToken(rendered,'\[/i]','</i>');rendered=replaceToken(rendered,'\[u]','<u>');rendered=replaceToken(rendered,'\[/u]','</u>');for(var i=0;i<palette.length;i++){var color=palette\[i];rendered=replaceToken(rendered,'\[color='+color+']','<span style=\"color:'+color+'\">');}var custom=document.getElementById('customColor').value.toLowerCase();rendered=replaceToken(rendered,'\[color='+custom+']','<span style=\"color:'+custom+'\">');rendered=replaceToken(rendered,'\[/color]','</span>');return rendered;}function updatePreview(){var value=editor.value;count.innerHTML=value.length;document.getElementById('previewName').innerHTML=escapeHtml(document.getElementById('profileName').value||actualName);document.getElementById('previewTitle').innerHTML=escapeHtml(document.getElementById('profileTitle').value);preview.innerHTML=value?renderMarkup(value):'<span class=\"empty\">No public biography has been written.</span>';}function updatePortrait(){var direction=document.getElementById('portraitDirection').value;document.getElementById('portrait').src=portraitResources\[direction]||'[current_portrait]';}function wrap(openTag,closeTag){editor.focus();var start=typeof editor.selectionStart==='number'?editor.selectionStart:editor.value.length,end=typeof editor.selectionEnd==='number'?editor.selectionEnd:start,selected=editor.value.substring(start,end);editor.value=editor.value.substring(0,start)+openTag+selected+closeTag+editor.value.substring(end);editor.selectionStart=start+openTag.length;editor.selectionEnd=start+openTag.length+selected.length;updatePreview();}function colorText(color){wrap('\[color='+color+']','\[/color]');}function applyCustomColor(){var color=document.getElementById('customColor').value.toLowerCase();if(palette.indexOf(color)<0)palette.push(color);colorText(color);}function clearBiography(){editor.value='';updatePreview();editor.focus();}function submitProfile(){var button=document.getElementById('saveProfile');if(button.disabled)return false;button.disabled=true;button.innerHTML='SAVING...';return true;}updatePortrait();updatePreview();
		function setProfileAction(actionValue){document.getElementById('profileAction').value=actionValue;return true;}function lockProfileForm(){var buttons=document.getElementsByClassName('submit-action');for(var i=0;i<buttons.length;i++)buttons\[i].disabled=true;return true;}var customPortrait='[portrait_resources["custom"]]',usingCustom=[using_custom_art ? "true" : "false"];function profilePortraitFallback(image){if(!usingCustom||image.getAttribute('data-fallback')==='1')return;usingCustom=false;image.setAttribute('data-fallback','1');var direction=document.getElementById('portraitDirection').value;image.src=portraitResources\[direction\]||'';document.getElementById('portraitFrame').className='portrait sprite-art hud-sprite';document.getElementById('portraitSource').innerHTML='LIVE SPRITE FALLBACK';}updatePortrait=function(){var direction=document.getElementById('portraitDirection').value;document.getElementById('portrait').src=usingCustom?customPortrait:(portraitResources\[direction\]||'[current_portrait]');};updatePortrait();
		</script></body></html>"}

	proc/show()
		if(!owner || !owner.client || !owner.playerCharacter || owner.isNexusProfileEditingBlocked())
			del(src)
			return
		prepareNexusHudBrowserResources(owner)
		render_generation++
		var/list/portrait_resources = list()
		var/owner_portrait_id = md5("\ref[owner]")
		for(var/profile_direction in list(SOUTH, WEST, EAST, NORTH))
			var/resource_name = "nexus_profile_editor_[owner_portrait_id]_[profile_direction].png"
			owner << browse_rsc(getNexusCharacterPortraitIcon(owner, profile_direction), resource_name)
			portrait_resources["[profile_direction]"] = resource_name
		var/custom_art = owner.getNexusPlayerProfileCustomArtFile(FALSE)
		if(custom_art)
			var/custom_resource_name = owner.getNexusPlayerProfileCustomArtResourceName("nexus_profile_editor_art")
			owner << browse_rsc(custom_art, custom_resource_name)
			portrait_resources["custom"] = custom_resource_name
		owner << browse(buildHtml(portrait_resources), "window=NexusDescriptionEditor;size=1180x760;can_resize=true;can_close=false")

	Topic(href, list/href_list)
		if(!canUse()) return
		var/submitted_generation = text2num(href_list["generation"])
		if(submitted_generation != render_generation) return
		switch(href_list["action"])
			if("save")
				if(!captureDraft(href_list)) return
				if(owner.last_nexus_profile_save && world.time - owner.last_nexus_profile_save < 20)
					finishAction("Please wait a moment before saving the profile again.", TRUE)
					return
				busy = TRUE
				var/profile_changed = owner.player_desc != draft_description || owner.player_profile_name != draft_profile_name || owner.player_profile_title != draft_profile_title || normalizeNexusPlayerProfileDirection(owner.player_profile_portrait_direction) != draft_portrait_direction || owner.player_profile_markup_version != 1
				if(!profile_changed)
					owner << "Your profile already matches these values."
					del(src)
					return
				var/list/old_profile_state = captureOwnerProfileTextState()
				applyDraft()
				owner.last_nexus_profile_save = world.time
				owner.save()
				if(!owner.isNexusPlayerProfileTextPersisted())
					restoreOwnerProfileTextState(old_profile_state)
					owner.save()
					var/rollback_verified = owner.isNexusPlayerProfileTextPersisted()
					finishAction(rollback_verified ? "The character save could not be verified. Your previous profile was restored; try again." : "Persistent storage could not be verified. Your previous profile remains active in this session; contact an administrator before logging out.", TRUE)
					return
				owner << "<font color=#7fe08a>Your character profile was saved.</font>"
				del(src)
			if("upload_art")
				if(!captureDraft(href_list)) return
				uploadProfileArt()
			if("use_sprite")
				if(!captureDraft(href_list)) return
				useProfileArt(FALSE)
			if("use_custom")
				if(!captureDraft(href_list)) return
				useProfileArt(TRUE)
			if("delete_art")
				if(!captureDraft(href_list)) return
				deleteProfileArt()
			if("close")
				del(src)

mob/verb/StopAllSounds()
	set category = "Other"
	set name = "Stop All Sounds"
	src << sound(null)

mob/verb/Set_Player_Description()
	set category = "Other"
	set name = "Character Profile"
	if(!client || !playerCharacter) return
	if(!canPersistNexusPlayerProfile())
		src << "Character Profile is unavailable while this character cannot be saved."
		return
	if(isNexusProfileEditingBlocked())
		src << "You cannot edit your profile while imitating another character."
		return
	if(client.nexus_description_editor)
		if(client.nexus_description_editor.busy)
			src << "Wait for the current profile action to finish."
			return
		del(client.nexus_description_editor)
		return
	if(last_nexus_profile_editor_open && world.time - last_nexus_profile_editor_open < 10) return
	last_nexus_profile_editor_open = world.time
	client.nexus_description_editor = new /datum/NexusPlayerDescriptionEditor(src)
	client.nexus_description_editor.show()
