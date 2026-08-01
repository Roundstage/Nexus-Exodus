/*
add:
	crickets at night
	birds and butterflies during day
	npcs that only come out during night or day. predators at night and peaceful at day. and enhanced versions like giant night Greenster npc

	"Natural Events"
		earthquakes (can unearth resources)
		lightning storms
		meteor strikes (esp on Braal), can get resources from meteors, esp if a big asteroid falls
		wildfires
		tsunamis

	also make it affect torches/fire/lights because i saw Zeex do a cool effect where he just makes a white transparent
		pulsating circle and places it over the torch then turns the game to night and it looks really nice
*/
mob/Admin2/verb/changeDayNight(turf/t in world)
	set name = "Change Day Night"
	set category = null

	var/area/a = t.get_area()

	if(!a)
		src << "Right click any tile on a planet to use this command"
		return

	switch(alert(usr,"Make to Day or Night?","Options","Cancel","Day","Night"))
		if("Cancel") return
		if("Day") a.FadeToDay()
		if("Night") a.FadeToNight()

	var/hours = input(usr,"How many game hours? 1 game hour is 2 real minutes") as num
	a.hours_til_switch = hours

area
	var
		has_daynight_cycle = 1
		is_day = 1
		hours_of_day = 15
		hours_of_night = 9
		day_color = rgb(255,255,255,0)
		night_color = rgb(0,30,100,70)
		dawndusk_color = rgb(255,200,0,60)
		day_ambient_color = rgb(255, 255, 255, 255)
		night_ambient_color = rgb(16, 22, 38, 255)
		dawndusk_ambient_color = rgb(105, 88, 72, 255)
		current_ambient_color = rgb(255, 255, 255, 255)
		day_fade_time = 500
		night_fade_time = 1000
		hours_til_switch = 1
		tmp/nexus_lighting_transition_id = 0

		has_fireflies = 1
		firefly_color

	proc
		DayNightLoop()
			set waitfor=0
			icon = null
			color = null
			current_ambient_color = is_day ? day_ambient_color : night_ambient_color
			if(!daynight_enabled)
				return
			while(1)
				hours_til_switch--
				if(hours_til_switch <= 0)
					is_day = !is_day
					hours_til_switch = (is_day ? hours_of_day : hours_of_night)
					if(hours_til_switch > 0)
						if(is_day)
							FadeToDay()
						else
							FadeToNight()
				sleep(2 * 600)

		FadeToNight()
			set waitfor=0
			is_day = FALSE
			nexus_lighting_transition_id++
			var/transition_id = nexus_lighting_transition_id

			FadeInLights(src)
			ToggleAreaFireflies(src, 1)
			current_ambient_color = dawndusk_ambient_color
			updateAreaNexusLighting(src, dawndusk_ambient_color, night_fade_time / 2)
			sleep(night_fade_time / 2)
			if(transition_id != nexus_lighting_transition_id) return
			current_ambient_color = night_ambient_color
			updateAreaNexusLighting(src, night_ambient_color, night_fade_time / 2)

		FadeToDay()
			set waitfor=0
			is_day = TRUE
			nexus_lighting_transition_id++
			var/transition_id = nexus_lighting_transition_id

			FadeOutLights(src)
			ToggleAreaFireflies(src, 0)
			current_ambient_color = dawndusk_ambient_color
			updateAreaNexusLighting(src, dawndusk_ambient_color, day_fade_time / 2)
			sleep(day_fade_time / 2)
			if(transition_id != nexus_lighting_transition_id) return
			current_ambient_color = day_ambient_color
			updateAreaNexusLighting(src, day_ambient_color, day_fade_time / 2)
