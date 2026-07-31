mob/var
	block_music
	player_desc = ""

mob/verb/Stream_Music_to_Everyone_Nearby()
	set category = "Other"
	set name = "Stream Music to Everyone Nearby"
	var/url = input("Enter the sound file link", "Sound file")
	if(world.time - last_music_stream_time < 100)
		src << "You can only do this every 10 seconds"
		return
	if(!findtext(url, "vocaroo"))
		src << "You must paste a Vocaroo link. Go to Vocaroo.com and upload music and get the link"
		return
	last_music_stream_time = world.time
	var/list/ips = new

	for(var/mob/m in player_view(22,src))
		if(m.client && !(m.client.address in ips))
			if(m.block_music)
				m << "<font color=cyan>[src] tried to play music, but you blocked it."
			else
				m << "<font color=cyan>[src] played music for you"
				m << browse("<audio id='musicplayer' autoplay><source src='[url]' /></audio>", "window=InvisBrowser.invisbrowser")
				ips += m.client.address

mob/verb/StopAllSounds()
	set category = "Other"
	set name = "Stop All Sounds"
	src << sound(null)

mob/verb/Set_Player_Description()
	set category = "Other"
	player_desc = input(usr, "Here you write a description of your character for RP purposes and anyone who clicks you will be able to read it", "Player Description", usr.player_desc) as message
