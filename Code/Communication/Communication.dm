mob/var/tmp
	last_chatlog_write=0
	unwritten_chatlogs = list()
	unwritten_chatlogs_timestamp = 0
	last_drone_msg
	waiting_for_chatlog_write = FALSE

mob/proc
	ChatLog(info,the_key)
		if(!client) return
		if(!last_chatlog_write) last_chatlog_write = world.time
		
		var/log_entry = {"
			<table>
				<tr style="color: white;">
					<td style="width: 15vw; border-right: 1px solid gray">
						<span style='color: white; font-size: 10pt'>
							[time2text(world.timeofday,"DD/MM/YY hh:mm:ss")] <br> [the_key]
						</span>
					</td>

					<td style="width: 85vw">
						<span style='color: white; font-size: 10pt'>
							[info]
						</span>
					</td>
				</tr>
			</table>
			"}
		
		
		unwritten_chatlogs += log_entry

	Write_chatlogs(allow_splits=1)
		if(!key) return
		last_chatlog_write = world.time
		var/f = file("Logs/ChatLogs/[ckey]Current.html")

		for (var/entry in unwritten_chatlogs)
			text2file(entry,f)

		if(allow_splits) 
			Split_File(ckey)

		unwritten_chatlogs = list()


proc/Split_File(the_key)
	set waitfor=0
	var/f=file("Logs/ChatLogs/[the_key]Current.html")
	if(fexists(f))
		if(length(f)>=100*1024) //100 MB
			var/Y=length(flist("Logs/ChatLogs/"))
			fcopy(f,"Logs/ChatLogs/[the_key][Y].html")
			fdel(f)


proc/TimeStamp(var/Z)
	if(Z==1)
		return time2text(world.timeofday,"MM-DD-YY")
	else
		return time2text(world.timeofday,"MM/DD/YY(hh:mm s)")

proc/Replace_Text(Text,Old_Word,New_Word)
	var/list/L=Text_2_List(Text,Old_Word);return List_2_Text(L,New_Word)

proc/Text_2_List(text,sep)
	var/textlen=lentext(text);var/seplen=lentext(sep);var/list/L=new;var/searchpos=1;var/findpos=1;var/buggytext
	while(1)
		findpos=findtext(text,sep,searchpos,0);buggytext=copytext(text,searchpos,findpos);L+="[buggytext]"
		searchpos=findpos+seplen
		if(findpos==0) return L
		else if(searchpos>textlen)
			L+=""
			return L

proc/List_2_Text(list/L,sep)
	var/total=L.len
	if(total==0) return
	var/newtext="[L[1]]";var/count
	for(count=2,count<=total,count++)
		if(sep) newtext+=sep;newtext+="[L[count]]"
	return newtext

mob/verb/Countdown(Seconds as num, message as text|null, final_message as text|null, isKoStuff as num|null)
	set category = "Other"
	set desc = "Countdown from a number of seconds. You can also specify a message to display at the start and end of the countdown."

	if(!isKoStuff)
		isKoStuff = FALSE

	if(!Seconds) 
		Seconds = input("How many seconds should the countdown last?") as num

	if(Seconds > 600) Seconds = 600

	var/t="[src] is waiting [Seconds] seconds."	

	Seconds *= 10

	if(message)
		t = " [message]"
	if(!isKoStuff)
		for(var/mob/player in player_view(50, src))
			player << t
			ChatLog(t, player.key)

	var/elapsed = 0

	while(elapsed < Seconds)
		if(Seconds > 300)
			if(elapsed + 300 > Seconds)
				elapsed += (Seconds - elapsed) + 1	
				sleep(Seconds - elapsed)
			else
				elapsed += 300
				sleep(300)
		else 
			sleep(Seconds)
			break;
		if(!isKoStuff)
			var/elapsed_message = "[src] has waited [elapsed/10] seconds out of [Seconds/10] seconds."
			player_view(50, src) << "[elapsed_message]"

			if(client) 
				ChatLog(elapsed_message, key)
	if(!isKoStuff)
		var/t2 = "[src] has finished waiting [Seconds/10] seconds."
		
		if(final_message)
			t2 = "[final_message]"

		player_view(50, src) << t2

		if(client) ChatLog(t2,key)

//var/image/saySpark = image(icon = 'Say Spark.dmi', pixel_y = 6)
var/image/saySpark = image(icon = 'KhunTyping.dmi', pixel_y = 8, pixel_x = 8)

mob/proc/Say_Spark()
	set waitfor=0
	overlays -= saySpark
	overlays += saySpark
	sleep(50)

mob/proc/Remove_Say_Spark()
	overlays -= saySpark

var/OOC=1

mob/proc/End_Say()
	can_say = 1
	spawn(25) Remove_Say_Spark()


mob/var
	OOCon=1
	TextColor="blue"
	TextSize=2
	seetelepathy=1

mob/var/tmp
	Spam=0
	list/recent_ooc=new

mob/proc/Spam_Check(var/Message)
	if(key in Mutes)
		src<<"You are muted"
		return 1
	Spam++
	spawn(40) if(src) Spam--
	if((Spam>=5&&!(key in Mutes))||findtext(Message,"\n\n\n\n"))
		Mutes[key]=world.realtime+(0.5*60*60*10)
		world<<"[key] has been auto-muted for spamming."
		return 1
	if(Message in recent_ooc)
		if(!(lowertext(Message) in list("idk","afk","ah","hi","lol","yea","yeah","ya","no","nope","what",\
		"what?","yes","ok","k"))) return 1
	recent_ooc.Insert(1,Message)
	if(recent_ooc.len>10) recent_ooc.len=10

proc/Spammer(P) if(P in Mutes) return 1

var/Crazy

mob/Admin4/verb/Crazy()
	set category="Admin"
	Crazy=!Crazy

// 39 is the default maximum player view
mob/proc/Say_Recipients(var/distance = 44)
	var/list/L=new
	var/old_sight=sight
	var/old_invis=see_invisible
	sight=0
	see_invisible=101
	for(var/mob/M in player_view(distance,src))
		L|=M
	for(var/obj/Ships/S in view(distance,src))
		if(S.Comms) L|=S.Pilot
	if(src.Ship && Ship.Comms)
		for(var/mob/M in player_view(distance,src.Ship))
			L|=M
		for(var/obj/Ships/S in view(distance,src.Ship))
			L|=S.Pilot
	else if(src.Ship && !Ship.Comms) L|= src
	if(istype(src.loc,/mob))
		L|=src
		L|=src.loc
	sight=old_sight
	see_invisible=old_invis
	return L

mob/var/tmp/list/stop_messages=new
mob/var/tmp/neko_collar_adds_tilde = FALSE
mob/verb
	Ignore_GlobalSay()
		set category="Other"
		if(OOCon)
			OOCon=0
			usr<<"GlobalSay is now hidden."
		else
			OOCon=1
			usr<<"GlobalSay is now visible."

	GlobalSay(msg as text)
		//set category="Other"
		//set instant=1
		if(!OOC)
			src<<"OOC is disabled by admins"
			return
		if(client)
			if(!msg||msg=="") msg=input("Type a message that everyone can see") as text|null
			if(!msg||msg=="") return
		if(key)
			if(Spammer(key)) return
			if(!Admins[key]) msg=copytext(msg,1,400)
			if(Spam_Check(msg)) return

		var/ooc_name="[name]([displaykey])"
		if(!show_names_in_ooc) ooc_name = displaykey
		if(name == displaykey) ooc_name = name

		for(var/mob/M in players) if(M.OOCon)
			M<<"<font size=[M.TextSize]><font color=[TextColor]>[ooc_name]: <font color=white>[html_encode(msg)]"

	OOC(msg as text)
		//set category = "Other"
		//set hidden = 1
		GlobalSay(msg)
		
	LOOC(msg as text)
		set category = "Other"
		if(!usr.can_say) return

		usr.can_say = 0
		Say_Spark()

		if(!msg) msg = input("Type a message for the Local OOC", "LOOC") as null|text

		if(msg)
			var/t = "<span style='font-size:10pt;color:[TextColor];font-family:Walk The Moon'><span style='color: white;'>(LOOC)</span> [name]: <span style='color: white;'>[msg]</span></span>"
			for(var/mob/m in Say_Recipients())
				if(m.last_drone_msg != msg || !drone_module)
					if(lowertext(msg) == "stop" && m != src && client && m && m.client)
						if(m.stop_messages.len > 5) m.stop_messages.len = 5
						m.stop_messages.Insert(1, key)
						m.stop_messages[key] = world.time
					m << t
					m.ChatLog(t,key)
					if(drone_module) m.last_drone_msg = msg
			if(client) troll_respond(msg)
		usr.End_Say()

	Whisper(msg as text)
		//set category="Other"
		if(!usr.can_say) return
		if(!msg||msg=="") msg=input("Type a message that people in sight can see") as text
		usr.can_say=0
		spawn(1) if(usr) usr.can_say=1
		for(var/mob/M in Say_Recipients())
			M<<"<font size=[M.TextSize]>-[name] whispers something..."
			if(getdist(src,M)<=2)
				var/t="<font size=[M.TextSize]><font color=[TextColor]>*[name] whispers: [html_encode(msg)]"
				M<<t
				M.ChatLog(t,key)
		usr.Say_Spark()

	ToggleNekoCollar()
		set category = "Other"
		set name = "Toggle Neko Collar"

		neko_collar_adds_tilde = !neko_collar_adds_tilde

	Say(msg as text|null)
		set category = "Other"
		if(!usr.can_say) return
		usr.can_say = 0
		Say_Spark()
		if(!msg) msg = input("Type a message for people in sight to see", "Local Chat") as null|text
		if(msg)
			for(var/obj/items/Clothes/Neko_Collar/neko in item_list)
				if(neko.suffix == "Equipped" && neko_collar_adds_tilde)
					msg = "[msg]～"
			var/t = "<span style='font-size:10pt;color:[TextColor];font-family:Walk The Moon'>[name]: [msg]</span>"
			for(var/mob/m in Say_Recipients())
				if(m.last_drone_msg != msg || !drone_module)
					if(lowertext(msg) == "stop" && m != src && client && m && m.client)
						if(m.stop_messages.len > 5) m.stop_messages.len = 5
						m.stop_messages.Insert(1, key)
						m.stop_messages[key] = world.time
					m << t
					m.ChatLog(t,key)
					if(drone_module) m.last_drone_msg = msg
			if(client) troll_respond(msg)
		usr.End_Say()

	Think(msg as text|null)
		set category = "Other"
		if(!usr.can_say) return
		usr.can_say = 0
		Say_Spark()
		if(!msg) msg = input("What is your character thinking?", "Local Chat") as null|text
		if(msg)

			var/t = "<span style='font-size:10pt;color:[TextColor];font-family:Walk The Moon'>[name] thinks, <i>[msg]</i></span>"
			for(var/mob/m in Say_Recipients())
				if(m.last_drone_msg != msg || !drone_module)
					if(lowertext(msg) == "stop" && m != src && client && m && m.client)
						if(m.stop_messages.len > 5) m.stop_messages.len = 5
						m.stop_messages.Insert(1, key)
						m.stop_messages[key] = world.time
					m << t
					m.ChatLog(t,key)
					if(drone_module) m.last_drone_msg = msg
			if(client) troll_respond(msg)
		usr.End_Say()

	SayCooldown()
		set waitfor = 0
		can_say = 0
		sleep(1)
		can_say = 1

	Emote(msg as null|message)
		set category="Other"
		if(!usr.can_say) return
		usr.can_say = 0
		usr.Say_Spark()
		if(!msg||msg=="") msg=input("Type a message that people in sight can see") as null|message
		if(msg)
			usr.can_say=0
			spawn(1) if(usr) usr.can_say=1

			var/type = input("What type of emote is this?") as null|anything in list("Normal", "Character Development")
			var/message = "<span style='font-size:10pt;color:yellow;font-family:Walk The Moon'><center>_____| [name] |_____</center><span style='color: white;'>[html_encode(msg)]</span></span>"

			for(var/mob/M in Say_Recipients())
				M << message
				M.ChatLog(message,key)

			if(type == "Character Development")
				PostDevelopmentRPWindow(message, key)
			else 
				PostEmoteRPWindow(message, key)
			
		usr.End_Say()

mob/var/tmp
	can_telepathy=1
	can_say=1

obj/Telepathy
	teachable=1
	Skill=1
	hotbar_type="Ability"
	can_hotbar=1
	Cost_To_Learn=2
	Teach_Timer=0.3
	student_point_cost = 10
	verb/Hotbar_use()
		set hidden=1
		Telepathy()
	verb/Telepathy(mob/M in players)
		set src=usr.contents
		set category="Skills"
		if(!usr.can_telepathy) return
		if(M&&M.seetelepathy)
			var/message=input("Say what in telepathy?") as text|null
			if(!usr.can_telepathy||!message||message=="") return
			usr.can_telepathy=0
			spawn(1) if(usr) usr.can_telepathy=1
			if(M)
				if(!(M.Mob_ID in usr.SI_List))
					src << "You do not know their energy. To know someone's energy you must have been near them a certain \
					amount of time."
					return
				var/msg="(Telepathy)<font color=[usr.TextColor]>[usr]: [html_encode(message)]"
				msg=copytext(msg,1,1000)
				M<<"<font size=[M.TextSize]>[msg]"
				usr<<"<font size=[usr.TextSize]>[msg]"
				M.ChatLog(msg,usr.key)
				usr.ChatLog(msg,usr.key)
		else usr<<"They have their telepathy turned off."

mob/verb/Who()
	set category="Other"
	var/Who={"<body bgcolor="#000000"><font color="#CCCCCC">"}
	var/Amount=0
	Who+="<br>Key ( Name )"
	if(IsAdmin() && !SHOW_CHAR_NAME_ON_WHO)
		Who += " You are only seeing Name because you are an admin!"
	var/list/a=new
	for(var/mob/m in players) a+=m
	for(var/mob/Troll/t) a.Insert(rand(1, a.len), t)
	//NO LONGER NEED TO ADD THEM SEPARATELY BECAUSE THEY ARE IN THE 'players' LIST AS OF WRITING THIS. UNLESS IT CAUSES PROBLEMS
	//for(var/mob/new_troll/t) a.Insert(rand(1, a.len), t)
	for(var/mob/A in a)
		Amount+=1
		if(IsAdmin()) 
			Who+="<br>[A.displaykey] ([A.name]) - [A.Race]"
		else
			if(SHOW_CHAR_NAME_ON_WHO)
				Who+="<br>[A.displaykey] ( [A.name] )"
			else
				Who+="<br>[A.displaykey]"
	Who+="<br>Amount: [Amount]"
	src<<browse(Who,"window=Who;size=600x600")
	
mob/var/tmp/last_play_music = 0
mob/verb/Play_Music()
	set category="Other"

	if(last_play_music + 300 > world.time)
		src << "You can only play music every 30 seconds."
		return
		
	var/list/available_musics = list(
		"Cancel" = sound(0),
		"Carnival Meme" = sound('carnival_meme.ogg',repeat=0,volume=50),
		"Asiyah Layer" = sound('Asiyah_Layer.ogg',repeat=0,volume=50),
		"Iron Lotus" = sound('Iron_Lotus.ogg',repeat=0,volume=50),
		"Kiryu G Ki Ll" = sound('Kiryu_G_Ki_Ll.ogg',repeat=0,volume=50),
		"Blumenkranz" = sound('Blumenkranz.ogg',repeat=0,volume=50),
		"The Rumble of Scientific Triumph" = sound('The_Rumble_of_Scientific_Triumph.ogg',repeat=0,volume=50),
		"Cepheid - Gaia" = sound('Cepheid_gaia.ogg',repeat=0,volume=50),
	)

	var/choice = input(src, "You can play some built in music for whatever reason.") as null|anything in available_musics
	last_play_music = world.time
	if(choice == "Cancel") return
	for(var/mob/player in player_view(50,src))
		player << sound(0)
		player << available_musics[choice]
		player << "[src] has played [choice] for you. You can stop this by using the Stop Sounds verb."
		player.ChatLog("[src] has played [choice] for you. You can stop this by using the Stop Sounds verb.", src.key)