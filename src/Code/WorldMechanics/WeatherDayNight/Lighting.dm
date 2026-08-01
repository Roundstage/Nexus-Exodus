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
#define NEXUS_GLOW_MASK_DIAMETER 256
#define NEXUS_GLOW_DEFAULT_OFFSET 7

proc/getNexusGlowRangeScale(size_tiles)
	return max(0.25, size_tiles) * world.icon_size / NEXUS_GLOW_MASK_DIAMETER

proc/getNexusAmbientMatrix(ambient_color)
	if(!ambient_color) ambient_color = rgb(255, 255, 255, 255)
	return list(null, null, null, "#0000", ambient_color)

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

proc/getNexusAttackGlowColor(obj/Attacks/attack)
	if(!attack) return "#59d8ff"
	if(istype(attack, /obj/Attacks/Final_Flash) || istype(attack, /obj/Attacks/Masenko) || istype(attack, /obj/Attacks/Kienzan)) return "#fff176"
	if(istype(attack, /obj/Attacks/Garlic_Gun) || istype(attack, /obj/Attacks/RoleplayBeam/TyrantLancer)) return "#b56cff"
	if(istype(attack, /obj/Attacks/RoleplayBeam/DoubleSunday)) return "#ff4d5f"
	if(istype(attack, /obj/Attacks/RoleplayBeam/PhotonFlash)) return "#ffe96b"
	if(istype(attack, /obj/Attacks/RoleplayBeam/BusterCannon)) return "#4ca8ff"
	return "#59d8ff"

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
		icon = 'NexusLightGradient.dmi'
		plane = NEXUS_LIGHTING_PLANE
		layer = FLOAT_LAYER
		blend_mode = BLEND_ADD
		appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE | NO_CLIENT_COLOR
		alpha = 60
		var/tmp
			image/core_visual
			range_tiles = 2
			light_intensity = 180
			variation_enabled = TRUE
			gradient_offset = NEXUS_GLOW_DEFAULT_OFFSET
			base_outer_alpha = 60
			base_core_alpha = 148
			base_range_scale = 0.25
			base_core_scale = 0.1

		New()
			. = ..()
			core_visual = image(icon = icon)
			core_visual.blend_mode = BLEND_ADD
			core_visual.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE | NO_CLIENT_COLOR
			overlays += core_visual
			configureNexusEmitter("#ffffff", 2, 180, icon, FALSE)

		Del()
			animate(src)
			if(core_visual) animate(core_visual)
			core_visual = null
			. = ..()

		proc/configureNexusEmitter(light_color = "#ffffff", new_range_tiles = 2, new_intensity = 180, light_icon = 'NexusLightGradient.dmi', enable_variation = TRUE, new_gradient_offset = NEXUS_GLOW_DEFAULT_OFFSET)
			animate(src)
			if(core_visual) animate(core_visual)
			range_tiles = Clamp(new_range_tiles, 0.25, 12)
			light_intensity = Clamp(new_intensity, 0, 255)
			variation_enabled = enable_variation
			gradient_offset = round(Clamp(new_gradient_offset, 1, 10))
			icon = light_icon
			icon_state = light_icon == 'NexusLightGradient.dmi' ? "[gradient_offset]" : ""
			color = light_color
			base_range_scale = getNexusGlowRangeScale(range_tiles)
			base_core_scale = base_range_scale * 0.42
			base_outer_alpha = Clamp(round(light_intensity * 0.42), 1, 120)
			base_core_alpha = Clamp(round(light_intensity * 0.78), 1, 220)
			alpha = base_outer_alpha
			transform = matrix() * base_range_scale
			if(core_visual)
				core_visual.icon = light_icon
				core_visual.icon_state = light_icon == 'NexusLightGradient.dmi' ? "1" : ""
				core_visual.color = light_color
				core_visual.alpha = base_core_alpha
				core_visual.transform = matrix() * base_core_scale
			if(enable_variation && light_intensity > 0)
				var/variation_time = rand(7, 11)
				animate(src, alpha = max(1, round(base_outer_alpha * 0.9)), transform = matrix() * base_range_scale * 1.025, time = variation_time, loop = -1, easing = SINE_EASING)
				animate(src, alpha = base_outer_alpha, transform = matrix() * base_range_scale, time = variation_time, easing = SINE_EASING)
				if(core_visual)
					animate(core_visual, alpha = max(1, round(base_core_alpha * 0.92)), transform = matrix() * base_core_scale * 0.96, time = variation_time + 1, loop = -1, easing = SINE_EASING)
					animate(core_visual, alpha = base_core_alpha, transform = matrix() * base_core_scale, time = variation_time + 1, easing = SINE_EASING)
			return src

atom/movable
	var/tmp
		obj/NexusLighting/Emitter/nexus_glow
		obj/NexusLighting/Emitter/nexus_action_glow
		nexus_action_glow_generation = 0

	proc
		setNexusGlow(light_color = "#ffffff", size = 2, light_alpha = 180, light_icon = 'NexusLightGradient.dmi', gradient_offset = NEXUS_GLOW_DEFAULT_OFFSET)
			if(!nexus_glow)
				nexus_glow = new
				vis_contents += nexus_glow
			nexus_glow.configureNexusEmitter(light_color, size, light_alpha, light_icon, TRUE, gradient_offset)
			CenterIcon(nexus_glow)
			return nexus_glow

		clearNexusGlow()
			if(!nexus_glow) return
			vis_contents -= nexus_glow
			del(nexus_glow)
			nexus_glow = null

		setNexusActionGlow(light_color = "#ffffff", size = 2, light_alpha = 180, light_icon = 'NexusLightGradient.dmi', gradient_offset = NEXUS_GLOW_DEFAULT_OFFSET)
			nexus_action_glow_generation++
			if(!nexus_action_glow)
				nexus_action_glow = new
				vis_contents += nexus_action_glow
			nexus_action_glow.configureNexusEmitter(light_color, size, light_alpha, light_icon, TRUE, gradient_offset)
			CenterIcon(nexus_action_glow)
			return nexus_action_glow

		clearNexusActionGlow()
			nexus_action_glow_generation++
			if(!nexus_action_glow) return
			vis_contents -= nexus_action_glow
			del(nexus_action_glow)
			nexus_action_glow = null

		pulseNexusGlow(light_color = "#ffffff", size = 2, light_alpha = 180, duration = 8, light_icon = 'NexusLightGradient.dmi', gradient_offset = NEXUS_GLOW_DEFAULT_OFFSET)
			set waitfor = 0
			var/obj/NexusLighting/Emitter/pulse = new
			pulse.configureNexusEmitter(light_color, size, light_alpha, light_icon, FALSE, gradient_offset)
			CenterIcon(pulse)
			vis_contents += pulse
			var/range_scale = pulse.base_range_scale
			animate(pulse, alpha = 0, transform = matrix() * range_scale * 1.18, time = max(1, duration), easing = SINE_EASING)
			if(pulse.core_visual) animate(pulse.core_visual, alpha = 0, transform = matrix() * pulse.base_core_scale * 1.18, time = max(1, duration), easing = SINE_EASING)
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

obj/Effect/NexusLightingTestBlast
	name = "lighting test blast"
	icon = 'Blast11.dmi'
	density = 0
	mouse_opacity = 0
	Grabbable = 0
	Savable = 0

	Del()
		clearNexusGlow()
		. = ..()

mob/proc/launchNexusLightingTestBlast()
	set waitfor = 0
	if(!loc) return
	var/obj/Effect/NexusLightingTestBlast/test_blast = new(loc)
	test_blast.dir = dir
	test_blast.pixel_x = pixel_x
	test_blast.pixel_y = pixel_y
	test_blast.setNexusGlow("#59d8ff", 3.2, 255)
	player_view(10, src) << sound('Blast.wav', volume = 20)
	for(var/flight_step = 1, flight_step <= 14 && test_blast, flight_step++)
		if(!step(test_blast, test_blast.dir)) break
		sleep(2)
	if(test_blast)
		test_blast.pulseNexusGlow("#c8f7ff", 4.5, 255, 8)
		sleep(8)
		if(test_blast) del(test_blast)

mob/Admin2/verb/setMaximumDarkness()
	set name = "Set Maximum Darkness"
	set category = "Admin"
	if(!current_area)
		src << "You must be inside an area to test maximum darkness."
		return
	current_area.nexus_lighting_transition_id++
	current_area.is_day = FALSE
	current_area.hours_til_switch = max(1, current_area.hours_of_night)
	current_area.current_ambient_color = rgb(0, 0, 0, 255)
	FadeInLights(current_area)
	updateAreaNexusLighting(current_area, current_area.current_ambient_color)
	src << "Maximum darkness applied instantly to [current_area]. Use Change Day Night or Test Lighting > Day to restore daylight."

mob/Admin2/verb/testNexusGlow()
	set name = "Test Glow"
	set category = "Admin"
	var/light_size = input(src, "Choose the total light diameter in tiles (0.5 to 12). A size of 1 covers one tile.", "Test Glow", 1) as num|null
	if(isnull(light_size)) return
	light_size = Clamp(light_size, 0.5, 12)
	var/gradient_offset = input(src, "Choose the gradient offset (1 to 10). 1 is a tight falloff; 10 fades slowly across the selected size.", "Test Glow", 10) as num|null
	if(isnull(gradient_offset)) return
	gradient_offset = round(Clamp(gradient_offset, 1, 10))
	setNexusActionGlow("#ffffff", light_size, 255, 'NexusLightGradient.dmi', gradient_offset)
	var/test_generation = nexus_action_glow_generation
	src << "A maximum-intensity white glow with a [light_size]-tile diameter and gradient offset [gradient_offset] will remain attached to you for 10 seconds."
	spawn(100) if(src && nexus_action_glow_generation == test_generation) clearNexusActionGlow()

mob/Admin2/verb/testNexusBlast()
	set name = "Test Lighting Blast"
	set category = "Admin"
	launchNexusLightingTestBlast()

mob/Admin2/verb/testNexusLighting()
	set name = "Test Lighting"
	set category = "Admin"
	if(!client) return
	var/choice = input(src, "Choose a lighting test for your current area.", "Nexus Lighting") in list("Cancel", "Maximum Darkness", "Night", "Day", "White Glow", "Lighting Blast", "Warm Attack Glow", "Blue Transformation Glow", "Toggle Personal Lighting")
	switch(choice)
		if("Maximum Darkness") setMaximumDarkness()
		if("Night")
			if(current_area) current_area.FadeToNight()
		if("Day")
			if(current_area) current_area.FadeToDay()
		if("White Glow") testNexusGlow()
		if("Lighting Blast") testNexusBlast()
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
		parent_type = /obj/NexusLighting/Emitter
		icon = 'NexusLightGradient.dmi'
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
			light_range = 1
			light_icon_resource = 'NexusLightGradient.dmi'
			light_gradient_offset = NEXUS_GLOW_DEFAULT_OFFSET
			tmp/light_transition_generation = 0

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
				light_transition_generation++
				animate(src)
				animate(src, alpha = 0, time = n, easing = SINE_EASING)
				if(core_visual)
					animate(core_visual)
					animate(core_visual, alpha = 0, time = n, easing = SINE_EASING)

			FadeInLight(n = 100)
				set waitfor=0
				light_transition_generation++
				var/transition_generation = light_transition_generation
				configureNexusEmitter(color, light_range, getRenderedAlpha(), light_icon_resource, FALSE, light_gradient_offset)
				var/outer_target = base_outer_alpha
				var/core_target = base_core_alpha
				alpha = 0
				if(core_visual) core_visual.alpha = 0
				animate(src, alpha = outer_target, time = n, easing = SINE_EASING)
				if(core_visual) animate(core_visual, alpha = core_target, time = n, easing = SINE_EASING)
				sleep(n)
				if(src && transition_generation == light_transition_generation)
					configureNexusEmitter(color, light_range, getRenderedAlpha(), light_icon_resource, TRUE, light_gradient_offset)
					CenterIcon(src)

	proc
		RemoveLightSource()
			if(light_obj) del(light_obj)

		GiveLightSource(size = 1, max_alpha = 60, light_color = rgb(255,255,255), auto_fade = 1, light_icon = 'NexusLightGradient.dmi', gradient_offset = NEXUS_GLOW_DEFAULT_OFFSET)
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

			light_obj = l
			if(max_alpha) l.max_alpha = max_alpha
			l.fade_with_day = auto_fade
			l.light_range = size
			l.light_icon_resource = light_icon
			l.light_gradient_offset = round(Clamp(gradient_offset, 1, 10))

			var/area/a = get_area()
			var/show_light = !a || !a.is_day || !l.fade_with_day
			l.configureNexusEmitter(light_color, size, l.getRenderedAlpha(), light_icon, show_light, l.light_gradient_offset)
			CenterIcon(l)
			if(!show_light)
				animate(l)
				l.alpha = 0
				if(l.core_visual)
					animate(l.core_visual)
					l.core_visual.alpha = 0
