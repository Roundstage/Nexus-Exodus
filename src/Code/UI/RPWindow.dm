proc/nexusIsValidRichTextColor(color_value)
	color_value = lowertext("[color_value]")
	if(length(color_value) != 7 || copytext(color_value, 1, 2) != "#") return FALSE
	var/valid_characters = "0123456789abcdef"
	for(var/character_index = 2, character_index <= 7, character_index++)
		if(!findtext(valid_characters, copytext(color_value, character_index, character_index + 1))) return FALSE
	return TRUE

proc/encodeNexusRichTextFragment(fragment)
	fragment = html_encode("[fragment]")
	fragment = replacetext(fragment, ascii2text(13), "")
	return replacetext(fragment, "\n", "<br>")

proc/getNexusRichTextTagReplacement(tag_text)
	var/lower_tag = lowertext("[tag_text]")
	switch(lower_tag)
		if("b") return "<b>"
		if("/b") return "</b>"
		if("i") return "<i>"
		if("/i") return "</i>"
		if("u") return "<u>"
		if("/u") return "</u>"
		if("/color") return "</span>"
		if("br") return "<br>"
	if(findtext(lower_tag, "color=") == 1)
		var/color_value = copytext(lower_tag, 7)
		if(nexusIsValidRichTextColor(color_value)) return "<span style='color:[color_value]'>"
	return null

proc/renderNexusEmoteMarkup(raw_text)
	raw_text = copytext("[raw_text]", 1, 5001)
	var/rendered_text = ""
	var/list/open_tags = list()
	var/cursor = 1
	var/text_length = length(raw_text)
	while(cursor <= text_length)
		var/tag_start = findtext(raw_text, "\[", cursor)
		if(!tag_start)
			rendered_text += encodeNexusRichTextFragment(copytext(raw_text, cursor))
			break
		if(tag_start > cursor) rendered_text += encodeNexusRichTextFragment(copytext(raw_text, cursor, tag_start))
		var/tag_end = findtext(raw_text, "\]", tag_start + 1)
		if(!tag_end)
			rendered_text += encodeNexusRichTextFragment(copytext(raw_text, tag_start))
			break
		var/tag_text = copytext(raw_text, tag_start + 1, tag_end)
		var/replacement = getNexusRichTextTagReplacement(tag_text)
		var/lower_tag = lowertext("[tag_text]")
		var/tag_id
		var/is_closing_tag
		if(lower_tag in list("b", "i", "u")) tag_id = lower_tag
		else if(findtext(lower_tag, "color=") == 1 && replacement) tag_id = "color"
		else if(lower_tag in list("/b", "/i", "/u", "/color"))
			tag_id = copytext(lower_tag, 2)
			is_closing_tag = TRUE
		if(is_closing_tag && (!open_tags.len || open_tags[open_tags.len] != tag_id)) replacement = null
		if(replacement)
			rendered_text += replacement
			if(tag_id)
				if(is_closing_tag) open_tags.Cut(open_tags.len, open_tags.len + 1)
				else open_tags += tag_id
			cursor = tag_end + 1
		else
			rendered_text += "&#91;"
			cursor = tag_start + 1
	for(var/tag_index = open_tags.len, tag_index >= 1, tag_index--)
		switch(open_tags[tag_index])
			if("b") rendered_text += "</b>"
			if("i") rendered_text += "</i>"
			if("u") rendered_text += "</u>"
			if("color") rendered_text += "</span>"
	return rendered_text

client/var/tmp
	datum/NexusEmoteEditor/nexus_emote_editor
	datum/NexusPlayerLogViewer/nexus_player_log_viewer

datum/NexusEmoteEditor
	var/tmp/mob/owner

	New(mob/new_owner)
		. = ..()
		owner = new_owner

	Del()
		if(owner && owner.client)
			owner << browse(null, "window=NexusEmoteEditor")
			if(owner.client.nexus_emote_editor == src) owner.client.nexus_emote_editor = null
		owner = null
		. = ..()

	proc/canUse()
		return owner && owner.client && usr == owner

	proc/buildHtml()
		var/owner_name = owner ? html_encode("[owner]") : "Character"
		return {"<!doctype html><html><head><meta charset='utf-8'><title>Emote Editor</title><style>
		*{box-sizing:border-box}html,body{margin:0;height:100%;background:#080c12;color:#e9f0f7;font:13px Arial,sans-serif}.shell{height:100%;display:grid;grid-template-rows:auto auto 1fr auto;background:radial-gradient(circle at 90% 0,#25364a,#0b121b 48%,#070a0f)}.header{display:flex;align-items:center;gap:12px;padding:15px 18px;border-bottom:1px solid #40536a;background:rgba(10,16,24,.96)}.title{margin-right:auto}.title b{display:block;font-size:21px;letter-spacing:1.5px}.title span{display:block;color:#8295aa;font-size:10px;text-transform:uppercase;margin-top:2px}.identity{padding:7px 10px;border-left:3px solid #ffd166;background:#151d29;color:#ffdca0}.close{padding:8px 11px;border:1px solid #68494b;color:#ffb0aa;text-decoration:none}.toolbar{display:flex;align-items:center;gap:6px;flex-wrap:wrap;padding:10px 14px;border-bottom:1px solid #2a394b;background:#0d151f}.toolbar button,.toolbar select,.toolbar input{height:30px;border:1px solid #40536a;background:#111d2a;color:#e8f0f8}.toolbar button{min-width:34px;padding:0 10px;cursor:pointer}.toolbar button:hover{border-color:#71c7ec;background:#183148}.swatch{min-width:28px!important;width:28px;padding:0!important}.custom-color{width:40px;padding:2px}.workspace{min-height:0;display:grid;grid-template-columns:1fr 1fr;gap:10px;padding:12px}.pane{min-height:0;display:flex;flex-direction:column;border:1px solid #314257;background:#0b121b}.pane h2{margin:0;padding:9px 11px;border-bottom:1px solid #314257;color:#8dc7e3;font-size:10px;letter-spacing:1px;text-transform:uppercase}.editor{width:100%;height:100%;min-height:300px;resize:none;border:0;outline:0;padding:14px;background:#0a1018;color:#f2f5f8;font:14px/1.55 Consolas,monospace}.preview{height:100%;min-height:300px;overflow:auto;padding:15px;background:#0a1018;font:14px/1.55 Arial,sans-serif}.emote-card{border-left:4px solid #ffd166;padding:12px;background:#111b27}.emote-name{padding-bottom:8px;margin-bottom:9px;border-bottom:1px solid #34465b;color:#ffd166;font-weight:bold;letter-spacing:.8px}.footer{display:flex;align-items:center;gap:10px;padding:11px 14px;border-top:1px solid #34465b;background:#0c141e}.counter{margin-right:auto;color:#8295aa}.hint{color:#65798f;font-size:10px}.post{padding:10px 22px;border:1px solid #5fb8d9;background:#173249;color:#fff;font-weight:bold;cursor:pointer}.post:hover{background:#214661}@media(max-width:760px){.workspace{grid-template-columns:1fr}.preview-pane{display:none}}
		</style></head><body><form class='shell' action='byond://' method='get'><input type='hidden' name='src' value='\ref[src]'><input type='hidden' name='action' value='submit'><div class='header'><div class='title'><b>EMOTE EDITOR</b><span>Rich roleplay composition with safe color markup</span></div><div class='identity'>[owner_name]</div><a class='close' href='byond://?src=\ref[src]&action=close'>CLOSE</a></div><div class='toolbar'><button type='button' onclick="wrap('\[b]','\[/b]')"><b>B</b></button><button type='button' onclick="wrap('\[i]','\[/i]')"><i>I</i></button><button type='button' onclick="wrap('\[u]','\[/u]')"><u>U</u></button><button type='button' class='swatch' style='background:#f5f7fa' title='White' onclick="colorText('#f5f7fa')"></button><button type='button' class='swatch' style='background:#ffd166' title='Gold' onclick="colorText('#ffd166')"></button><button type='button' class='swatch' style='background:#ff667a' title='Red' onclick="colorText('#ff667a')"></button><button type='button' class='swatch' style='background:#ff9f43' title='Orange' onclick="colorText('#ff9f43')"></button><button type='button' class='swatch' style='background:#69db7c' title='Green' onclick="colorText('#69db7c')"></button><button type='button' class='swatch' style='background:#66d9ef' title='Cyan' onclick="colorText('#66d9ef')"></button><button type='button' class='swatch' style='background:#74a7ff' title='Blue' onclick="colorText('#74a7ff')"></button><button type='button' class='swatch' style='background:#bd93f9' title='Purple' onclick="colorText('#bd93f9')"></button><button type='button' class='swatch' style='background:#ff79c6' title='Pink' onclick="colorText('#ff79c6')"></button><input id='customColor' class='custom-color' type='color' value='#66d9ef' title='Custom color'><button type='button' onclick='applyCustomColor()'>APPLY COLOR</button><select name='mode'><option value='Normal'>Normal RP</option><option value='Character Development'>Character Development</option></select></div><div class='workspace'><section class='pane'><h2>Text and markup</h2><textarea id='emoteText' class='editor' name='text' maxlength='5000' autofocus placeholder='Describe what your character does... Select text and use the toolbar to add colors or emphasis.' oninput='updatePreview()'></textarea></section><section class='pane preview-pane'><h2>Live preview</h2><div class='preview'><div class='emote-card'><div class='emote-name'>[owner_name]</div><div id='preview'></div></div></div></section></div><div class='footer'><div class='counter'><b id='wordCount'>0</b> words &middot; <b id='charCount'>0</b>/5000 characters</div><div class='hint'>Supported: color, bold, italic and underline. Raw HTML is never accepted.</div><button class='post' type='submit'>POST EMOTE</button></div></form><script>
		var editor=document.getElementById('emoteText');var preview=document.getElementById('preview');var palette=\['#f5f7fa','#ffd166','#ff667a','#ff9f43','#69db7c','#66d9ef','#74a7ff','#bd93f9','#ff79c6'\];
		function escapeHtml(value){return value.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}
		function replaceToken(value,token,replacement){return value.split(token).join(replacement);}
		function renderMarkup(value){var rendered=escapeHtml(value).replace(/\\n/g,'<br>');rendered=replaceToken(rendered,'\[b]','<b>');rendered=replaceToken(rendered,'\[/b]','</b>');rendered=replaceToken(rendered,'\[i]','<i>');rendered=replaceToken(rendered,'\[/i]','</i>');rendered=replaceToken(rendered,'\[u]','<u>');rendered=replaceToken(rendered,'\[/u]','</u>');for(var i=0;i<palette.length;i++){var color=palette\[i];rendered=replaceToken(rendered,'\[color='+color+']','<span style="color:'+color+'">');}var custom=document.getElementById('customColor').value.toLowerCase();rendered=replaceToken(rendered,'\[color='+custom+']','<span style="color:'+custom+'">');rendered=replaceToken(rendered,'\[/color]','</span>');return rendered;}
		function updatePreview(){var value=editor.value;var words=value.trim()?value.trim().split(/\\s+/).length:0;document.getElementById('wordCount').innerHTML=words;document.getElementById('charCount').innerHTML=value.length;preview.innerHTML=renderMarkup(value);}
		function wrap(openTag,closeTag){editor.focus();var start=typeof editor.selectionStart==='number'?editor.selectionStart:editor.value.length;var end=typeof editor.selectionEnd==='number'?editor.selectionEnd:start;var selected=editor.value.substring(start,end);editor.value=editor.value.substring(0,start)+openTag+selected+closeTag+editor.value.substring(end);editor.selectionStart=start+openTag.length;editor.selectionEnd=start+openTag.length+selected.length;updatePreview();}
		function colorText(color){wrap('\[color='+color+']','\[/color]');}function applyCustomColor(){var color=document.getElementById('customColor').value.toLowerCase();if(palette.indexOf(color)<0)palette.push(color);colorText(color);}updatePreview();
		</script></body></html>"}

	proc/show()
		if(!owner || !owner.client)
			del(src)
			return
		owner << browse(buildHtml(), "window=NexusEmoteEditor;size=980x680;can_resize=true;can_close=true")

	Topic(href, list/href_list)
		if(!canUse()) return
		switch(href_list["action"])
			if("submit")
				if(owner.submitNexusEmote(href_list["text"], href_list["mode"])) del(src)
			if("close") del(src)

datum/NexusPlayerLogViewer
	var/tmp
		mob/owner
		active_channel = "all"

	New(mob/new_owner, channel = "all")
		. = ..()
		owner = new_owner
		active_channel = normalizeNexusChatChannel(channel)

	Del()
		if(owner && owner.client)
			owner << browse(null, "window=NexusPlayerLogs")
			if(owner.client.nexus_player_log_viewer == src) owner.client.nexus_player_log_viewer = null
		owner = null
		. = ..()

	proc/canUse()
		return owner && owner.client && usr == owner

	proc/getPendingEntries(channel)
		if(!owner) return ""
		channel = normalizeNexusChatChannel(channel)
		var/list/entries
		if(channel == "all") entries = owner.unwritten_chatlogs
		else
			owner.initializeNexusChannelLogs()
			entries = owner.nexus_unwritten_channel_logs[channel]
		var/pending_html = ""
		if(islist(entries)) for(var/entry in entries) pending_html += entry
		return pending_html

	proc/buildHtml()
		active_channel = normalizeNexusChatChannel(active_channel)
		var/log_html = ""
		var/current_path = getNexusChannelLogPath(owner.ckey, active_channel)
		if(fexists(file(current_path))) log_html += file2text(file(current_path))
		log_html += getPendingEntries(active_channel)
		if(!log_html) log_html = "<div class='empty'>No [getNexusChatChannelLabel(active_channel)] entries have been recorded yet.</div>"
		var/tabs = ""
		for(var/channel in list("all", "combat", "ic", "ooc"))
			var/tab_class = channel == active_channel ? "tab active" : "tab"
			tabs += "<a class='[tab_class]' href='byond://?src=\ref[src]&action=channel&channel=[channel]'>[getNexusChatChannelLabel(channel)]</a>"
		return {"<!doctype html><html><head><meta charset='utf-8'><title>Own Logs</title><style>
		*{box-sizing:border-box}html,body{margin:0;min-height:100%;background:#080c12;color:#e8eef5;font:12px Arial,sans-serif}.header{position:sticky;top:0;z-index:2;padding:13px 16px;border-bottom:1px solid #3a4d63;background:#0b121b}.top{display:flex;align-items:center;gap:10px}.title{margin-right:auto}.title b{display:block;font-size:19px;letter-spacing:1.3px}.title span{color:#8092a7;font-size:10px}.close{padding:7px 10px;border:1px solid #68494b;color:#ffb0aa;text-decoration:none}.tabs{display:flex;gap:5px;margin-top:10px}.tab{padding:7px 13px;border:1px solid #34465a;background:#101a26;color:#91a6bc;text-decoration:none}.tab.active{border-color:#67b9dc;background:#173147;color:#fff}.search{width:100%;margin-top:9px;padding:9px;border:1px solid #3c5067;background:#09111a;color:#fff}.entries{padding:12px}.entries table{width:100%;margin-bottom:5px;border:1px solid #253548;background:#0d1621;border-collapse:collapse}.entries td{padding:8px;vertical-align:top}.entries td:first-child{width:150px!important;color:#8195aa!important}.empty{padding:50px;text-align:center;color:#718399}.hidden{display:none}
		</style></head><body><div class='header'><div class='top'><div class='title'><b>YOUR LOGS / [getNexusChatChannelLabel(active_channel)]</b><span>Current file plus messages waiting to be written</span></div><a class='close' href='byond://?src=\ref[src]&action=close'>CLOSE</a></div><div class='tabs'>[tabs]</div><input id='search' class='search' placeholder='Search attacker, target, technique or message...' oninput='filterLogs()'></div><div id='entries' class='entries'>[log_html]</div><script>function filterLogs(){var query=document.getElementById('search').value.toLowerCase();var rows=document.getElementById('entries').getElementsByTagName('table');for(var i=0;i<rows.length;i++){rows\[i].style.display=!query||rows\[i].innerText.toLowerCase().indexOf(query)>=0?'table':'none';}}window.scrollTo(0,document.body.scrollHeight);</script></body></html>"}

	proc/show()
		if(!owner || !owner.client)
			del(src)
			return
		owner << browse(buildHtml(), "window=NexusPlayerLogs;size=960x700;can_resize=true;can_close=true")

	Topic(href, list/href_list)
		if(!canUse()) return
		switch(href_list["action"])
			if("channel")
				active_channel = normalizeNexusChatChannel(href_list["channel"])
				show()
			if("close") del(src)

mob/proc/showNexusEmoteEditor()
	if(!client) return
	if(client.nexus_emote_editor) del(client.nexus_emote_editor)
	client.nexus_emote_editor = new /datum/NexusEmoteEditor(src)
	client.nexus_emote_editor.show()

mob/proc/submitNexusEmote(raw_text, emote_mode = "Normal")
	if(!client || !can_say) return FALSE
	raw_text = copytext("[raw_text]", 1, 5001)
	if(!length(raw_text))
		src << "Write something before posting the emote."
		return FALSE
	if(emote_mode != "Character Development") emote_mode = "Normal"
	var/rendered_text = renderNexusEmoteMarkup(raw_text)
	if(!rendered_text) return FALSE
	can_say = 0
	Say_Spark()
	var/mode_badge = emote_mode == "Character Development" ? "<span style='color:#79d9ff'>CHARACTER DEVELOPMENT</span>" : "<span style='color:#8ca0b7'>ROLEPLAY EMOTE</span>"
	var/message = "<div style='margin:4px 0;padding:9px 11px;border-left:3px solid #ffd166;background:#101923;color:#edf3fa;font:10pt Arial,sans-serif'><div style='margin-bottom:7px;padding-bottom:6px;border-bottom:1px solid #35485d'><b style='color:#ffd166'>[html_encode(name)]</b> &nbsp; [mode_badge]</div><div style='line-height:1.5'>[rendered_text]</div></div>"
	for(var/mob/recipient in Say_Recipients()) recipient.receiveNexusChatMessage(message, "ic", key)
	if(emote_mode == "Character Development") PostDevelopmentRPWindow(message, key)
	else PostEmoteRPWindow(message, key)
	End_Say()
	return TRUE

mob/proc/showNexusPlayerLogs(channel = "all")
	if(!client) return
	if(client.nexus_player_log_viewer) del(client.nexus_player_log_viewer)
	client.nexus_player_log_viewer = new /datum/NexusPlayerLogViewer(src, channel)
	client.nexus_player_log_viewer.show()

mob
	proc
		ViewEmoteWindow(mob/admin, mob/player, unwritten, type = "Emote", path = "emotelogs", overwrite_ckey = "none")
			var/name = player
			var/ckey = player.ckey
			if(overwrite_ckey != "none")
				ckey = overwrite_ckey
				name = overwrite_ckey == "all" ? "All" : overwrite_ckey

			var/View={"
				<html>
					<head>
						<title>[name] [type] Log</title>
							<meta charset="UTF-8">
					</head>
					
					<body bgcolor="#000000">
						<font size=6><font color="#0099FF">
							<b>
					</body>
				<html>
			"}

			var/XXX=file("data/Logs/[path]/[ckey]Current.html")
			if(fexists(XXX))
				var/list/File_List = list("Cancel")
				//var/last_line = ""

				for(var/File in flist("data/Logs/[path]/[ckey]"))
					File_List+=File
				if(admin)
					var/File = input(admin, "Which [type] log do you want to view?") in File_List
					if(!File || File=="Cancel") return

					var/emotefile = file2text(file("data/Logs/[path]/[File]"))
					View += emotefile

					if(player && overwrite_ckey != "none")
						for(var/log in unwritten)
							View += log

					admin << "Viewing [File]"
					admin << browse(View,"window=Log;size=800x600")
					
					if(overwrite_ckey == "none")
						admin_blame(admin, "[admin] Opens [name]'s [type] log")
			else
				admin << "No logs found for [ckey]"
	verb
		ViewSelfRPWindow()
			var/mob/M = src
			set category="Other"
			set name="View own RP Window"
			ViewEmoteWindow(src, M, M.unwritten_emotelogs, "Emote", "emotelogs", M.ckey)
			
		ViewSelfDevelopmentRPWindow()
			var/mob/M = src
			set category="Other"
			set name="View own Development RP Window"

			ViewEmoteWindow(src, M, M.unwritten_emotelogs, "Development Emote", "emotelogs_dev", M.ckey)
			
		ViewSelfSayWindow()
			set category="Other"
			set name="View Own Logs"
			showNexusPlayerLogs("all")
mob
	proc
		PostEmoteRPWindow(text as text, key)
			for(var/mob/M in Say_Recipients())
				M.EmoteLog(text, key, "emotelogs")
	proc
		PostDevelopmentRPWindow(text as text, key)
			for(var/mob/M in Say_Recipients())
				M.EmoteLog(text, key, "emotelogs_dev")
				M.EmoteLog(text, key, "emotelogs")

mob/verb/ViewDescription(mob/A)
	set name="View Description"
	set category="Other"
	
	if(!A)
		return
	if(!A.player_desc)
		return

	var/html = "[A.player_desc]"

	usr << browse(html, "window=[A];size=800x600;name=[A]")

mob/var/tmp
	last_emotelog_write=0
	unwritten_emotelogs = list()
	waiting_for_emotelog_write = FALSE


mob/proc
	EmoteLog(info, the_key, type="emotelogs", needs_client = TRUE)
		if(!client && needs_client) return
		if(!last_emotelog_write)
			last_emotelog_write=world.time //prevent writing unecessarily when someone has just logged in
		var/log_entry = {"
			<table>
				<tr style="color: white; font-size: 10pt">
					<td style="width: 25%; border-right: 1px solid gray">
						<span style='color: white; font-size: 10pt'>
							[time2text(world.timeofday,"DD/MM/YY hh:mm:ss")] <br> [the_key]
						</span>
					</td>

					<td style="width: 75%">
						<span style='color: white; font-size: 10pt'>
							[info]
						</span>
					</td>
				</tr>
			</table>
			"}

		unwritten_emotelogs += log_entry
		if(world.time-last_emotelog_write < 100) // 10 seconds
			Write_emotelogs(type=type)

	Write_emotelogs(allow_splits=1, type, log = "")
		if(!key) return
		last_emotelog_write = world.time

		var/f = file("data/Logs/[type]/[ckey]Current.html")

		for(var/entry in unwritten_emotelogs)
			text2file(entry, f)

		if(allow_splits) Split_EmoteFile(ckey, type)
		unwritten_emotelogs = list()

proc/Split_EmoteFile(the_key, type)
	set waitfor=0
	var/f=file("data/Logs/[type]/[the_key]Current.html")
	if(fexists(f))
		if(length(f)>=100*1024) //100 MB
			var/Y=length(flist("data/Logs/[type]/"))
			fcopy(f,"data/Logs/[type]/[the_key][Y].html")
			fdel(f)
