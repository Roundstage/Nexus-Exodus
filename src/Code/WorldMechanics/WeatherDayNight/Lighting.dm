/*
shared light source. if too many light objects are close together it looks very bad, they should share 1 giant light object, with a
pixel offset aligned to their average pixel location (x * 32 and y * 32)
	if someone moves one of the torches, just re-average the locations of the ones sharing it, or if it is moved too far take it out
	of the shared light and give it back its own light
*/

var/list
	light_sources = new

#define NEXUS_LIGHTING_PLANE 15
#define NEXUS_HUD_PLANE 20

proc/getNexusAmbientMatrix(ambient_color)
	if(!ambient_color) ambient_color = rgb(255, 255, 255, 255)
	return list(null, null, null, null, ambient_color)

proc/updateAreaNexusLighting(area/a, ambient_color, fade_time = 0)
	if(!a || !islist(a.player_list)) return
	for(var/mob/player in a.player_list)
		if(player && player.client) player.client.setNexusAmbient(ambient_color, fade_time)

proc/getNexusTransformationGlowProfile(transformation_id)
	if(!transformation_id) return null
	switch(transformation_id)
		if("saiyan_ssj1") return list("color" = "#ffd84a", "size" = 2.7, "alpha" = 155)
		if("saiyan_ssj2") return list("color" = "#fff071", "size" = 3, "alpha" = 175)
		if("saiyan_ssj3") return list("color" = "#ffe05c", "size" = 3.4, "alpha" = 195)
		if("saiyan_ssj4") return list("color" = "#ff5a43", "size" = 3.2, "alpha" = 180)
		if("saiyan_god") return list("color" = "#ff4055", "size" = 3.1, "alpha" = 190)
		if("saiyan_blue") return list("color" = "#42d9ff", "size" = 3.4, "alpha" = 205)
		if("frost_second") return list("color" = "#b783ff", "size" = 2.4, "alpha" = 125)
		if("frost_third") return list("color" = "#b26dff", "size" = 2.7, "alpha" = 145)
		if("frost_final") return list("color" = "#a85bff", "size" = 3, "alpha" = 165)
		if("frost_fifth") return list("color" = "#8e63ff", "size" = 3.3, "alpha" = 185)
		if("frost_gold") return list("color" = "#ffd35a", "size" = 3.5, "alpha" = 205)
		if("giant") return list("color" = "#ff9b55", "size" = 4.5, "alpha" = 150)
		if("great_ape") return list("color" = "#ff8b45", "size" = 4.8, "alpha" = 155)
		if("alien_transform") return list("color" = "#ef72ff", "size" = 3.2, "alpha" = 175)
		if("ultra_instinct") return list("color" = "#d9f5ff", "size" = 3.7, "alpha" = 215)
	return null

client
	var
		nexus_lighting_enabled = TRUE
		tmp/obj/NexusLighting/PlaneMaster/nexus_lighting_plane

	proc
		initializeNexusLighting()
			if(!nexus_lighting_plane) nexus_lighting_plane = new
			if(!(nexus_lighting_plane in screen)) screen += nexus_lighting_plane
			syncNexusLighting()

		removeNexusLighting()
			if(!nexus_lighting_plane) return
			screen -= nexus_lighting_plane
			del(nexus_lighting_plane)
			nexus_lighting_plane = null

		setNexusAmbient(ambient_color, fade_time = 0)
			if(!nexus_lighting_plane) initializeNexusLighting()
			if(!nexus_lighting_plane) return
			if(!nexus_lighting_enabled) ambient_color = rgb(255, 255, 255, 255)
			var/list/ambient_matrix = getNexusAmbientMatrix(ambient_color)
			animate(nexus_lighting_plane)
			if(fade_time > 0)
				animate(nexus_lighting_plane, color = ambient_matrix, time = fade_time, easing = SINE_EASING)
			else nexus_lighting_plane.color = ambient_matrix

		syncNexusLighting(area/target_area)
			if(!target_area && mob) target_area = mob.current_area
			var/ambient_color = rgb(255, 255, 255, 255)
			if(target_area && target_area.has_daynight_cycle)
				ambient_color = target_area.current_ambient_color
			setNexusAmbient(ambient_color)

obj/NexusLighting
	Savable = 0
	Grabbable = 0
	attackable = 0
	density = 0
	mouse_opacity = 0

	PlaneMaster
		screen_loc = "1,1"
		plane = NEXUS_LIGHTING_PLANE
		blend_mode = BLEND_MULTIPLY
		appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR
		color = list(null, null, null, null, "#ffffffff")

	Emitter
		icon = 'TorchLightCircle.dmi'
		plane = NEXUS_LIGHTING_PLANE
		layer = FLOAT_LAYER
		blend_mode = BLEND_ADD
		appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE | NO_CLIENT_COLOR
		alpha = 180

atom/movable
	var/tmp/obj/NexusLighting/Emitter/nexus_glow

	proc
		setNexusGlow(light_color = "#ffffff", size = 2, light_alpha = 180, light_icon = 'TorchLightCircle.dmi')
			if(!nexus_glow)
				nexus_glow = new
				vis_contents += nexus_glow
			nexus_glow.icon = light_icon
			nexus_glow.color = light_color
			nexus_glow.alpha = Clamp(light_alpha, 0, 255)
			nexus_glow.transform = matrix() * max(0.1, size) * 0.18
			CenterIcon(nexus_glow)
			return nexus_glow

		clearNexusGlow()
			if(!nexus_glow) return
			vis_contents -= nexus_glow
			del(nexus_glow)
			nexus_glow = null

		pulseNexusGlow(light_color = "#ffffff", size = 2, light_alpha = 180, duration = 8, light_icon = 'TorchLightCircle.dmi')
			set waitfor = 0
			var/obj/NexusLighting/Emitter/pulse = new
			pulse.icon = light_icon
			pulse.color = light_color
			pulse.alpha = Clamp(light_alpha, 0, 255)
			pulse.transform = matrix() * max(0.1, size) * 0.18
			CenterIcon(pulse)
			vis_contents += pulse
			animate(pulse, alpha = 0, transform = matrix() * max(0.1, size + 0.7) * 0.18, time = max(1, duration), easing = SINE_EASING)
			sleep(max(1, duration))
			if(pulse)
				vis_contents -= pulse
				del(pulse)

mob/proc/updateTransformationGlow()
	var/list/profile = getNexusTransformationGlowProfile(detectPrimaryTransformation())
	if(!profile)
		clearNexusGlow()
		return
	setNexusGlow(profile["color"], profile["size"], profile["alpha"])

mob/verb/toggleNexusLighting()
	set name = "Toggle Lighting"
	set category = "Other"
	if(!client) return
	client.nexus_lighting_enabled = !client.nexus_lighting_enabled
	client.syncNexusLighting()
	var/state_text = client.nexus_lighting_enabled ? "enabled" : "disabled"
	src << "Dynamic lighting [state_text]."

mob/Admin2/verb/testNexusLighting()
	set name = "Test Lighting"
	set category = "Admin"
	if(!client) return
	var/choice = input(src, "Choose a lighting test for your current area.", "Nexus Lighting") in list("Cancel", "Night", "Day", "Warm Attack Glow", "Blue Transformation Glow", "Toggle Personal Lighting")
	switch(choice)
		if("Night")
			if(current_area) current_area.FadeToNight()
		if("Day")
			if(current_area) current_area.FadeToDay()
		if("Warm Attack Glow") pulseNexusGlow("#ff7a35", 4, 230, 50)
		if("Blue Transformation Glow") pulseNexusGlow("#42d9ff", 4, 230, 50)
		if("Toggle Personal Lighting") toggleNexusLighting()

proc
	FadeOutLights(area/a)
		set waitfor=0
		if(!a) return
		for(var/obj/LightSource/l in light_sources)
			if(!l.fade_with_day) continue
			var/area/a2 = l.get_area()
			if(a == a2) l.FadeOutLight(a.day_fade_time * 1.8)

	FadeInLights(area/a)
		set waitfor=0
		if(!a) return
		for(var/obj/LightSource/l in light_sources)
			if(!l.fade_with_day) continue
			var/area/a2 = l.get_area()
			if(a == a2) l.FadeInLight(a.night_fade_time * 1.8)

atom
	var
		tmp
			obj/LightSource/light_obj
	proc
		FadeLightOut(time = 0)
			if(!light_obj) return
			light_obj.FadeOutLight(time)

		FadeLightIn(time = 0)
			if(!light_obj) return
			light_obj.FadeInLight(time)

obj
	LightSource
		icon = 'TorchLightCircle.dmi'
		density = 0
		Savable = 0
		plane = NEXUS_LIGHTING_PLANE
		layer = FLOAT_LAYER
		blend_mode = BLEND_ADD
		appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE | NO_CLIENT_COLOR
		alpha = 0
		mouse_opacity = 0 //mouse ignores this so you can click things under it

		var
			max_alpha = 70
			fade_with_day = 1

		New()
			. = ..()
			MakeImmovableIndestructable()
			light_sources += src

		Del()
			light_sources -= src
			. = ..()

		proc
			getRenderedAlpha()
				return Clamp(max_alpha * 3, 0, 235)

			FadeOutLight(n = 100)
				set waitfor=0
				animate(src)
				animate(src, alpha = 0, time = n, easing = SINE_EASING)

			FadeInLight(n = 100)
				set waitfor=0
				animate(src)
				animate(src, alpha = getRenderedAlpha(), time = n, easing = SINE_EASING)

	proc
		RemoveLightSource()
			if(light_obj) del(light_obj)

		GiveLightSource(size = 1, max_alpha = 60, light_color = rgb(255,255,255), auto_fade = 1, light_icon = 'TorchLightCircle.dmi')
			set waitfor=0

			//too many lights on screen can crash people. so dont add a light if too many nearby objects already have lights
			var/nearbyLights = 0
			for(var/obj/ls in light_sources)
				if(ls.z == z && get_dist(ls, src) <= 15)
					nearbyLights++
			if(nearbyLights >= 15) return

			var/obj/LightSource/l
			if(light_obj) l = light_obj
			else l = new(loc)

			l.icon = light_icon
			l.transform = matrix() * size * 0.14
			CenterIcon(l)
			light_obj = l
			if(max_alpha) l.max_alpha = max_alpha
			l.color = light_color
			l.fade_with_day = auto_fade

			var/area/a = get_area()
			if(a)
				if(a.is_day && l.fade_with_day) l.alpha = 0
				else l.alpha = l.getRenderedAlpha() //just set the light to max all at once now
