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
var/list/nexus_planetary_clocks = list()
var/nexus_planetary_hour_ticks = 3000

datum/PlanetaryClock
	var
		clock_key
		list/linked_areas = list()
		is_day = TRUE
		hours_remaining = 1
		hours_of_day = 15
		hours_of_night = 9
		tmp/loop_running = FALSE

	New(new_key, area/origin)
		clock_key = new_key
		if(origin)
			is_day = origin.is_day
			hours_remaining = max(1, origin.hours_til_switch)
			hours_of_day = max(1, origin.hours_of_day)
			hours_of_night = max(1, origin.hours_of_night)

	proc/addArea(area/target)
		if(!target || target in linked_areas) return
		linked_areas += target
		target.nexus_planetary_clock = src
		target.is_day = is_day
		target.hours_til_switch = hours_remaining
		target.current_ambient_color = is_day ? target.day_ambient_color : target.night_ambient_color
		startLoop()

	proc/startLoop()
		set waitfor = FALSE
		if(loop_running || !daynight_enabled) return
		loop_running = TRUE
		while(linked_areas.len)
			sleep(max(600, round(nexus_planetary_hour_ticks / max(0.1, Year_Speed))))
			advanceHour()
		loop_running = FALSE

	proc/advanceHour()
		hours_remaining--
		if(hours_remaining <= 0)
			is_day = !is_day
			hours_remaining = is_day ? hours_of_day : hours_of_night
			applyPhase(TRUE)
		else syncAreaClocks()

	proc/syncAreaClocks()
		linked_areas = remove_nulls(linked_areas)
		for(var/area/target in linked_areas)
			target.is_day = is_day
			target.hours_til_switch = hours_remaining

	proc/applyPhase(with_fade = TRUE)
		syncAreaClocks()
		for(var/area/target in linked_areas)
			if(!target.has_daynight_cycle) continue
			if(with_fade)
				if(is_day) target.FadeToDay()
				else target.FadeToNight()
			else
				target.current_ambient_color = is_day ? target.day_ambient_color : target.night_ambient_color
				updateAreaNexusLighting(target, target.current_ambient_color)

	proc/setPhase(day_phase, remaining_hours = 1)
		is_day = !!day_phase
		hours_remaining = max(1, round(remaining_hours))
		applyPhase(TRUE)

proc/getNexusPlanetaryClock(area/target)
	if(!target || !target.has_daynight_cycle) return null
	var/clock_key = "[target.type]"
	var/datum/PlanetaryClock/clock = nexus_planetary_clocks[clock_key]
	if(!clock)
		clock = new(clock_key, target)
		nexus_planetary_clocks[clock_key] = clock
	clock.addArea(target)
	return clock

mob/Admin2/verb/changeDayNight(turf/t in world)
	set name = "Change Day Night"
	set category = null

	var/area/a = t.get_area()

	if(!a)
		src << "Right click any tile on a planet to use this command"
		return

	var/phase_choice = alert(usr,"Set the shared clock for this planet to Day or Night?","Planetary Time","Cancel","Day","Night")
	switch(phase_choice)
		if("Cancel") return
	var/hours = input(usr,"How many game hours until the next phase? At Year Speed 1, one hour is [nexus_planetary_hour_ticks / 600] real minutes.", "Planetary Time", 1) as num
	a.setPlanetaryPhase(phase_choice == "Day", hours)

mob/Admin2/verb/inspectPlanetaryTime(turf/t in world)
	set name = "Inspect Planetary Time"
	set category = "Admin"
	var/area/target_area = t.get_area()
	var/datum/PlanetaryClock/clock = getNexusPlanetaryClock(target_area)
	if(!clock)
		src << "[target_area] has no day/night cycle."
		return
	src << "[target_area]: [clock.is_day ? "Day" : "Night"], [clock.hours_remaining] hours remaining, [clock.hours_of_day]h day/[clock.hours_of_night]h night, [clock.linked_areas.len] synchronized area instance(s)."

mob/Admin4/verb/setPlanetaryHourLength()
	set name = "Set Planetary Hour Length"
	set category = "Admin"
	var/minutes = input(src, "Real minutes per planetary hour at Year Speed 1.", "Planetary Clock", nexus_planetary_hour_ticks / 600) as num
	minutes = Clamp(minutes, 1, 30)
	nexus_planetary_hour_ticks = round(minutes * 600)
	src << "Planetary hours now last [minutes] real minutes at Year Speed 1 and scale inversely with Year Speed."

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
		tmp/datum/PlanetaryClock/nexus_planetary_clock

		has_fireflies = 1
		firefly_color

	proc
		DayNightLoop()
			set waitfor=0
			icon = null
			color = null
			current_ambient_color = is_day ? day_ambient_color : night_ambient_color
			if(daynight_enabled && has_daynight_cycle) getNexusPlanetaryClock(src)

		setPlanetaryPhase(day_phase, remaining_hours = 1)
			var/datum/PlanetaryClock/clock = getNexusPlanetaryClock(src)
			if(clock) clock.setPhase(day_phase, remaining_hours)

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
