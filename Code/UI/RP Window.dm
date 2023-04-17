mob
	proc
		ViewEmoteWindow(mob/admin, mob/player, unwritten, type = "Emote", path = "emotelogs", overwrite_ckey = "none")
			var/name = player
			var/ckey = player.ckey
			if(overwrite_ckey != "none")
				ckey = overwrite_ckey
				name = "All"

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

			var/XXX=file("Logs/[path]/[ckey]Current.html")
			if(fexists(XXX))
				var/list/File_List = list("Cancel")
				var/last_line = ""

				for(var/File in flist("Logs/[path]/[ckey]"))
					File_List+=File
				if(admin)
					var/File = input(admin, "Which [type] log do you want to view?") in File_List
					if(!File || File=="Cancel") return

					var/emotefile = file2text(file("Logs/[path]/[File]"))
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
			var/mob/M = src
			set category="Other"
			set name="View own Chatlog"

			ViewEmoteWindow(src, M, M.unwritten_chatlogs, "Chatlog", "ChatLogs", M.ckey)
mob/Admin1
	verb
		ViewRPWindow(mob/M in players)
			set category="Admin"
			set name="View Player RP Window"
			ViewEmoteWindow(src, M, M.unwritten_emotelogs, "Emote", "emotelogs")
			
		ViewDevelopmentRPWindow(mob/M in players)
			set category="Admin"
			set name="View Player Development RP Window"

			ViewEmoteWindow(src, M, M.unwritten_emotelogs, "Development Emote", "emotelogs_dev")
mob
	proc
		PostEmoteRPWindow(text as text, key)
			for(var/mob/M in Say_Recipients())
				EmoteLog(text, key, "emotelogs")
	proc
		PostDevelopmentRPWindow(text as text, key)
			for(var/mob/M in Say_Recipients())
				EmoteLog(text, key, "emotelogs_dev")
				EmoteLog(text, key, "emotelogs")

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

		var/f = file("Logs/[type]/[ckey]Current.html")

		for(var/entry in unwritten_emotelogs)
			text2file(entry, f)

		if(allow_splits) Split_EmoteFile(ckey, type)
		unwritten_emotelogs = list()

proc/Split_EmoteFile(the_key, type)
	set waitfor=0
	var/f=file("Logs/[type]/[the_key]Current.html")
	if(fexists(f))
		if(length(f)>=100*1024) //100 MB
			var/Y=length(flist("Logs/[type]/"))
			fcopy(f,"Logs/[type]/[the_key][Y].html")
			fdel(f)
