/*
shared light source. if too many light objects are close together it looks very bad, they should share 1 giant light object, with a
pixel offset aligned to their average pixel location (x * 32 and y * 32)
	if someone moves one of the torches, just re-average the locations of the ones sharing it, or if it is moved too far take it out
	of the shared light and give it back its own light
*/

var/list
	light_sources = new
	nexus_projectile_icon_diameters = new
	nexus_light_occlusion_mask_cache = new

var/nexus_projectile_glow_serial_counter = 0
var/nexus_static_light_occlusion_updates_running = FALSE
var/nexus_light_turf_occlusion_enabled = TRUE

#define NEXUS_LIGHTING_PLANE 15
#define NEXUS_HUD_PLANE 20
#define NEXUS_GLOW_MASK_DIAMETER 256
#define NEXUS_GLOW_DEFAULT_OFFSET 7
#define NEXUS_LIGHT_OCCLUSION_MINIMUM_SIZE 1.5
#define NEXUS_LIGHT_OCCLUSION_CACHE_LIMIT 160
#define NEXUS_LIGHT_VARIATION_STEADY "steady"
#define NEXUS_LIGHT_VARIATION_SMALL_BLAST "small_blast"
#define NEXUS_LIGHT_VARIATION_BLAST "blast"
#define NEXUS_LIGHT_VARIATION_BEAM "beam"
#define NEXUS_LIGHT_VARIATION_BEAM_SOURCE "beam_source"
#define NEXUS_LIGHT_VARIATION_AURA "aura"
#define NEXUS_LIGHT_VARIATION_CHARGE "charge"

proc/getNexusGlowRangeScale(size_tiles)
	return max(0.25, size_tiles) * world.icon_size / NEXUS_GLOW_MASK_DIAMETER

proc/getNexusLightTurf(atom/source_atom)
	var/atom/current_atom = source_atom
	while(current_atom && !isturf(current_atom))
		current_atom = current_atom.loc
	return isturf(current_atom) ? current_atom : null

proc/nexusTurfBlocksLight(turf/target_turf)
	if(!target_turf || target_turf.density || target_turf.opacity) return TRUE
	for(var/obj/blocker in target_turf)
		if(blocker.opacity) return TRUE
	return FALSE

proc/nexusLightCanReach(turf/source_turf, turf/target_turf)
	if(!source_turf || !target_turf || source_turf.z != target_turf.z) return FALSE
	if(source_turf == target_turf) return TRUE
	var/turf/current_turf = source_turf
	var/maximum_steps = get_dist(source_turf, target_turf) + 1
	for(var/line_step = 1, line_step <= maximum_steps, line_step++)
		var/turf/next_turf = get_step(current_turf, get_dir(current_turf, target_turf))
		if(!next_turf) return FALSE
		if(next_turf == target_turf) return TRUE
		if(nexusTurfBlocksLight(next_turf)) return FALSE
		current_turf = next_turf
	return FALSE

proc/getNexusLightOcclusionCacheKey(turf/source_turf, size_tiles)
	if(!source_turf) return null
	var/mask_size = Clamp(size_tiles, NEXUS_LIGHT_OCCLUSION_MINIMUM_SIZE, 12)
	var/radius = max(1, round(mask_size / 2 + 0.5))
	var/blocker_signature = ""
	for(var/y_offset = -radius, y_offset <= radius, y_offset++)
		for(var/x_offset = -radius, x_offset <= radius, x_offset++)
			var/turf/sample_turf = locate(source_turf.x + x_offset, source_turf.y + y_offset, source_turf.z)
			blocker_signature += nexusTurfBlocksLight(sample_turf) ? "1" : "0"
	return "[round(mask_size, 0.05)]|[blocker_signature]"

proc/getNexusLightOcclusionMask(turf/source_turf, size_tiles, cache_key)
	if(!source_turf) return null
	if(!cache_key) cache_key = getNexusLightOcclusionCacheKey(source_turf, size_tiles)
	var/icon/cached_mask = nexus_light_occlusion_mask_cache[cache_key]
	if(cached_mask) return cached_mask

	var/mask_size = Clamp(size_tiles, NEXUS_LIGHT_OCCLUSION_MINIMUM_SIZE, 12)
	var/radius = max(1, round(mask_size / 2 + 0.5))
	var/tile_pixel_size = NEXUS_GLOW_MASK_DIAMETER / mask_size
	var/pixel_center = (NEXUS_GLOW_MASK_DIAMETER + 1) / 2
	var/icon/occlusion_mask = icon('NexusLightGradient.dmi', "10")
	occlusion_mask.DrawBox(null, 1, 1, NEXUS_GLOW_MASK_DIAMETER, NEXUS_GLOW_MASK_DIAMETER)
	for(var/y_offset = -radius, y_offset <= radius, y_offset++)
		for(var/x_offset = -radius, x_offset <= radius, x_offset++)
			var/turf/sample_turf = locate(source_turf.x + x_offset, source_turf.y + y_offset, source_turf.z)
			if(!sample_turf || !nexusLightCanReach(source_turf, sample_turf)) continue
			var/x1 = Clamp(round(pixel_center + (x_offset - 0.5) * tile_pixel_size), 1, NEXUS_GLOW_MASK_DIAMETER)
			var/y1 = Clamp(round(pixel_center + (y_offset - 0.5) * tile_pixel_size), 1, NEXUS_GLOW_MASK_DIAMETER)
			var/x2 = Clamp(round(pixel_center + (x_offset + 0.5) * tile_pixel_size), 1, NEXUS_GLOW_MASK_DIAMETER)
			var/y2 = Clamp(round(pixel_center + (y_offset + 0.5) * tile_pixel_size), 1, NEXUS_GLOW_MASK_DIAMETER)
			occlusion_mask.DrawBox(rgb(255, 255, 255, 255), min(x1, x2), min(y1, y2), max(x1, x2), max(y1, y2))

	if(nexus_light_occlusion_mask_cache.len >= NEXUS_LIGHT_OCCLUSION_CACHE_LIMIT)
		nexus_light_occlusion_mask_cache = new/list
	nexus_light_occlusion_mask_cache[cache_key] = occlusion_mask
	return occlusion_mask

proc/startNexusStaticLightOcclusionUpdates()
	set waitfor = 0
	if(nexus_static_light_occlusion_updates_running) return
	nexus_static_light_occlusion_updates_running = TRUE
	while(light_sources.len)
		for(var/obj/LightSource/static_light in light_sources)
			if(static_light) static_light.refreshNexusLightOcclusion()
		sleep(30)
	nexus_static_light_occlusion_updates_running = FALSE

proc/getNexusProjectileVisualDiameter(icon_resource)
	if(!icon_resource) return world.icon_size
	var/cache_key = "[icon_resource]"
	if(nexus_projectile_icon_diameters[cache_key]) return nexus_projectile_icon_diameters[cache_key]
	var/icon/visual_icon = icon(icon_resource)
	var/visual_diameter = max(visual_icon.Width(), visual_icon.Height())
	nexus_projectile_icon_diameters[cache_key] = visual_diameter
	return visual_diameter

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
	if(istype(attack, /obj/Attacks/Genki_Dama/Death_Ball)) return "#b767ff"
	if(istype(attack, /obj/Attacks/Genki_Dama/Supernova)) return "#ff9b3d"
	if(istype(attack, /obj/Attacks/Genki_Dama)) return "#76e8ff"
	if(istype(attack, /obj/Attacks/Big_Bang_Attack)) return "#559dff"
	if(istype(attack, /obj/Attacks/Buster_Barrage)) return "#72ff8c"
	if(istype(attack, /obj/Attacks/Sokidan)) return "#d8fbff"
	return "#59d8ff"

proc/getNexusProjectileLightProfile(obj/Blast/projectile)
	if(!projectile || !projectile.Is_Ki) return null
	var/obj/Attacks/attack = istype(projectile.from_attack, /obj/Attacks) ? projectile.from_attack : null
	var/light_color = getNexusAttackGlowColor(attack)
	var/visual_diameter = getNexusProjectileVisualDiameter(projectile.icon)
	var/visual_tiles = max(0.5, visual_diameter / world.icon_size)

	if(projectile.Beam)
		var/beam_scale = 1
		if(ismob(projectile.Owner))
			var/mob/beam_owner = projectile.Owner
			beam_scale = beam_owner.get_beam_size()
		return list(
			"color" = light_color,
			"size" = Clamp(0.85 + max(visual_tiles, beam_scale) * 0.35, 1.1, 2),
			"alpha" = Clamp(round(105 + beam_scale * 18), 115, 155),
			"offset" = 6,
			"variation" = NEXUS_LIGHT_VARIATION_BEAM)

	if(istype(projectile, /obj/Blast/Genki_Dama))
		return list(
			"color" = light_color,
			"size" = Clamp(3 + projectile.Size * 0.22, 3, 7.5),
			"alpha" = 245,
			"offset" = 10,
			"variation" = NEXUS_LIGHT_VARIATION_BLAST)

	var/light_size
	var/light_alpha
	var/gradient_offset
	var/variation_style
	if(projectile.percent_damage <= 0.6 || visual_tiles <= 0.75)
		light_size = Clamp(0.85 + visual_tiles * 0.3, 0.95, 1.2)
		light_alpha = 145
		gradient_offset = 4
		variation_style = NEXUS_LIGHT_VARIATION_SMALL_BLAST
	else if(projectile.percent_damage <= 3)
		light_size = Clamp(1.25 + visual_tiles * 0.35, 1.4, 1.8)
		light_alpha = 175
		gradient_offset = 6
		variation_style = NEXUS_LIGHT_VARIATION_SMALL_BLAST
	else if(projectile.percent_damage <= 8 && projectile.Explosive <= 2)
		light_size = Clamp(1.65 + visual_tiles * 0.4, 1.9, 2.5)
		light_alpha = 205
		gradient_offset = 7
		variation_style = NEXUS_LIGHT_VARIATION_BLAST
	else
		light_size = Clamp(2.4 + visual_tiles * 0.55 + projectile.Explosive * 0.18, 2.8, 4.4)
		light_alpha = 235
		gradient_offset = 9
		variation_style = NEXUS_LIGHT_VARIATION_BLAST

	if(istype(attack, /obj/Attacks/Buster_Barrage) || istype(attack, /obj/Attacks/Makosen) || istype(attack, /obj/Attacks/Scatter_Shot) || istype(attack, /obj/Attacks/Attack_Barrier))
		light_size = min(light_size, 1.15)
		light_alpha = min(light_alpha, 155)
		gradient_offset = 4
		variation_style = NEXUS_LIGHT_VARIATION_SMALL_BLAST
	else if(istype(attack, /obj/Attacks/Kienzan) || istype(attack, /obj/Attacks/Sokidan))
		light_size = max(light_size, 2.35)
		light_alpha = max(light_alpha, 220)
		gradient_offset = 8
	else if(istype(attack, /obj/Attacks/Big_Bang_Attack))
		light_size = max(light_size, 4.2)
		light_alpha = 245
		gradient_offset = 10
	else if(istype(attack, /obj/Attacks/Charge))
		light_size = max(light_size, 2.65)
		light_alpha = max(light_alpha, 225)
		gradient_offset = 8

	return list(
		"color" = light_color,
		"size" = light_size,
		"alpha" = light_alpha,
		"offset" = gradient_offset,
		"variation" = variation_style)

proc/getNexusAuraGlowProfile(mob/player)
	if(!player) return null
	if(player.God_Fist_level || player.super_God_Fist)
		return list("color" = player.super_God_Fist ? "#ff5570" : "#ff293d", "size" = 3.3, "alpha" = 205)
	var/list/transformation_profile = getNexusTransformationGlowProfile(player.detectPrimaryTransformation())
	if(transformation_profile)
		return list(
			"color" = transformation_profile["color"],
			"size" = max(2.6, transformation_profile["size"] + 0.35),
			"alpha" = max(165, round(transformation_profile["alpha"] * 0.85)))
	return list("color" = "#76dfff", "size" = 2.65, "alpha" = 175)

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
			atom/movable/light_origin
			range_tiles = 2
			light_intensity = 180
			variation_enabled = TRUE
			variation_style = NEXUS_LIGHT_VARIATION_STEADY
			gradient_offset = NEXUS_GLOW_DEFAULT_OFFSET
			base_outer_alpha = 60
			base_core_alpha = 148
			base_range_scale = 0.25
			base_core_scale = 0.1
			occlusion_mask_key
			core_occlusion_mask_key

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
			filters = null
			if(core_visual) core_visual.filters = null
			light_origin = null
			core_visual = null
			. = ..()

		proc/getNexusLightOriginTurf()
			if(light_origin) return getNexusLightTurf(light_origin)
			return getNexusLightTurf(src)

		proc/shouldUseNexusLightOcclusion()
			if(!nexus_light_turf_occlusion_enabled || light_intensity <= 0 || range_tiles < NEXUS_LIGHT_OCCLUSION_MINIMUM_SIZE) return FALSE
			if(variation_style == NEXUS_LIGHT_VARIATION_SMALL_BLAST || variation_style == NEXUS_LIGHT_VARIATION_BEAM) return FALSE
			return TRUE

		proc/clearNexusLightOcclusion()
			filters = null
			if(core_visual) core_visual.filters = null
			occlusion_mask_key = null
			core_occlusion_mask_key = null

		proc/refreshNexusLightOcclusion(force_update = FALSE)
			var/turf/origin_turf = getNexusLightOriginTurf()
			if(!origin_turf || !shouldUseNexusLightOcclusion())
				clearNexusLightOcclusion()
				return

			var/new_mask_key = getNexusLightOcclusionCacheKey(origin_turf, range_tiles)
			if(force_update || new_mask_key != occlusion_mask_key)
				var/icon/outer_mask = getNexusLightOcclusionMask(origin_turf, range_tiles, new_mask_key)
				filters = outer_mask ? list(filter(type = "alpha", icon = outer_mask)) : null
				occlusion_mask_key = new_mask_key

			var/core_range_tiles = range_tiles * 0.42
			if(!core_visual) return
			if(core_range_tiles < NEXUS_LIGHT_OCCLUSION_MINIMUM_SIZE)
				core_visual.filters = null
				core_occlusion_mask_key = null
				return
			var/new_core_mask_key = getNexusLightOcclusionCacheKey(origin_turf, core_range_tiles)
			if(force_update || new_core_mask_key != core_occlusion_mask_key)
				var/icon/core_mask = getNexusLightOcclusionMask(origin_turf, core_range_tiles, new_core_mask_key)
				core_visual.filters = core_mask ? list(filter(type = "alpha", icon = core_mask)) : null
				core_occlusion_mask_key = new_core_mask_key

		proc/configureNexusEmitter(light_color = "#ffffff", new_range_tiles = 2, new_intensity = 180, light_icon = 'NexusLightGradient.dmi', enable_variation = TRUE, new_gradient_offset = NEXUS_GLOW_DEFAULT_OFFSET, new_variation_style = NEXUS_LIGHT_VARIATION_STEADY)
			animate(src)
			if(core_visual) animate(core_visual)
			range_tiles = Clamp(new_range_tiles, 0.25, 12)
			light_intensity = Clamp(new_intensity, 0, 255)
			variation_enabled = enable_variation
			variation_style = new_variation_style || NEXUS_LIGHT_VARIATION_STEADY
			gradient_offset = round(Clamp(new_gradient_offset, 1, 10))
			icon = light_icon
			icon_state = light_icon == 'NexusLightGradient.dmi' ? "[gradient_offset]" : ""
			color = light_color
			base_range_scale = getNexusGlowRangeScale(range_tiles)
			base_core_scale = base_range_scale * 0.42
			base_outer_alpha = Clamp(round(light_intensity * 0.42), 1, 120)
			base_core_alpha = Clamp(round(light_intensity * 0.78), 1, 220)
			if(variation_style == NEXUS_LIGHT_VARIATION_BEAM)
				base_core_scale = base_range_scale * 0.3
				base_outer_alpha = Clamp(round(light_intensity * 0.32), 1, 90)
				base_core_alpha = Clamp(round(light_intensity * 0.5), 1, 125)
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
				var/outer_alpha_ratio = 0.9
				var/outer_scale_ratio = 1.025
				var/core_alpha_ratio = 0.92
				var/core_scale_ratio = 0.96
				switch(variation_style)
					if(NEXUS_LIGHT_VARIATION_SMALL_BLAST)
						variation_time = rand(2, 4)
						outer_alpha_ratio = 0.7
						outer_scale_ratio = 1.08
						core_alpha_ratio = 0.82
						core_scale_ratio = 0.93
					if(NEXUS_LIGHT_VARIATION_BLAST)
						variation_time = rand(3, 6)
						outer_alpha_ratio = 0.8
						outer_scale_ratio = 1.055
						core_alpha_ratio = 0.87
						core_scale_ratio = 0.95
					if(NEXUS_LIGHT_VARIATION_BEAM)
						variation_time = rand(2, 4)
						outer_alpha_ratio = 0.84
						outer_scale_ratio = 1.025
						core_alpha_ratio = 0.88
						core_scale_ratio = 0.97
					if(NEXUS_LIGHT_VARIATION_BEAM_SOURCE)
						variation_time = rand(2, 5)
						outer_alpha_ratio = 0.7
						outer_scale_ratio = 1.1
						core_alpha_ratio = 0.78
						core_scale_ratio = 0.92
					if(NEXUS_LIGHT_VARIATION_AURA)
						variation_time = rand(3, 6)
						outer_alpha_ratio = 0.66
						outer_scale_ratio = 1.085
						core_alpha_ratio = 0.74
						core_scale_ratio = 0.91
					if(NEXUS_LIGHT_VARIATION_CHARGE)
						variation_time = rand(2, 5)
						outer_alpha_ratio = 0.58
						outer_scale_ratio = 1.12
						core_alpha_ratio = 0.68
						core_scale_ratio = 0.89
				animate(src, alpha = max(1, round(base_outer_alpha * outer_alpha_ratio)), transform = matrix() * base_range_scale * outer_scale_ratio, time = variation_time, loop = -1, easing = SINE_EASING)
				animate(src, alpha = base_outer_alpha, transform = matrix() * base_range_scale, time = variation_time, easing = SINE_EASING)
				if(core_visual)
					animate(core_visual, alpha = max(1, round(base_core_alpha * core_alpha_ratio)), transform = matrix() * base_core_scale * core_scale_ratio, time = variation_time + 1, loop = -1, easing = SINE_EASING)
					animate(core_visual, alpha = base_core_alpha, transform = matrix() * base_core_scale, time = variation_time + 1, easing = SINE_EASING)
			refreshNexusLightOcclusion(TRUE)
			return src

atom/movable
	var/tmp
		obj/NexusLighting/Emitter/nexus_glow
		obj/NexusLighting/Emitter/nexus_action_glow
		obj/NexusLighting/Emitter/nexus_aura_glow
		nexus_action_glow_generation = 0
		nexus_aura_glow_generation = 0
		nexus_light_occlusion_tracking = FALSE
		turf/nexus_light_occlusion_last_turf
		nexus_light_occlusion_next_refresh = 0

	proc
		hasNexusOccludingLight()
			if(istype(src, /obj/NexusLighting/Emitter))
				var/obj/NexusLighting/Emitter/emitter = src
				return emitter.shouldUseNexusLightOcclusion()
			if(nexus_glow && nexus_glow.shouldUseNexusLightOcclusion()) return TRUE
			if(nexus_action_glow && nexus_action_glow.shouldUseNexusLightOcclusion()) return TRUE
			if(nexus_aura_glow && nexus_aura_glow.shouldUseNexusLightOcclusion()) return TRUE
			return FALSE

		refreshAttachedNexusLightOcclusion(force_update = FALSE)
			if(istype(src, /obj/NexusLighting/Emitter))
				var/obj/NexusLighting/Emitter/emitter = src
				emitter.refreshNexusLightOcclusion(force_update)
				return
			if(nexus_glow) nexus_glow.refreshNexusLightOcclusion(force_update)
			if(nexus_action_glow) nexus_action_glow.refreshNexusLightOcclusion(force_update)
			if(nexus_aura_glow) nexus_aura_glow.refreshNexusLightOcclusion(force_update)

		startNexusLightOcclusionTracking()
			set waitfor = 0
			if(nexus_light_occlusion_tracking || !hasNexusOccludingLight()) return
			nexus_light_occlusion_tracking = TRUE
			nexus_light_occlusion_last_turf = null
			nexus_light_occlusion_next_refresh = 0
			while(src && hasNexusOccludingLight())
				var/turf/current_turf = getNexusLightTurf(src)
				if(current_turf != nexus_light_occlusion_last_turf || world.time >= nexus_light_occlusion_next_refresh)
					refreshAttachedNexusLightOcclusion()
					nexus_light_occlusion_last_turf = current_turf
					nexus_light_occlusion_next_refresh = world.time + 10
				sleep(2)
			nexus_light_occlusion_tracking = FALSE
			nexus_light_occlusion_last_turf = null

		setNexusGlow(light_color = "#ffffff", size = 2, light_alpha = 180, light_icon = 'NexusLightGradient.dmi', gradient_offset = NEXUS_GLOW_DEFAULT_OFFSET, variation_style = NEXUS_LIGHT_VARIATION_STEADY)
			if(!nexus_glow)
				nexus_glow = new
				vis_contents += nexus_glow
			nexus_glow.light_origin = src
			nexus_glow.configureNexusEmitter(light_color, size, light_alpha, light_icon, TRUE, gradient_offset, variation_style)
			CenterIcon(nexus_glow)
			startNexusLightOcclusionTracking()
			return nexus_glow

		clearNexusGlow()
			if(!nexus_glow) return
			vis_contents -= nexus_glow
			del(nexus_glow)
			nexus_glow = null

		setNexusActionGlow(light_color = "#ffffff", size = 2, light_alpha = 180, light_icon = 'NexusLightGradient.dmi', gradient_offset = NEXUS_GLOW_DEFAULT_OFFSET, variation_style = NEXUS_LIGHT_VARIATION_STEADY)
			nexus_action_glow_generation++
			if(!nexus_action_glow)
				nexus_action_glow = new
				vis_contents += nexus_action_glow
			nexus_action_glow.light_origin = src
			nexus_action_glow.configureNexusEmitter(light_color, size, light_alpha, light_icon, TRUE, gradient_offset, variation_style)
			CenterIcon(nexus_action_glow)
			startNexusLightOcclusionTracking()
			return nexus_action_glow

		clearNexusActionGlow()
			nexus_action_glow_generation++
			if(!nexus_action_glow) return
			vis_contents -= nexus_action_glow
			del(nexus_action_glow)
			nexus_action_glow = null

		setNexusAuraGlow(light_color = "#ffffff", size = 2, light_alpha = 180, light_icon = 'NexusLightGradient.dmi', gradient_offset = NEXUS_GLOW_DEFAULT_OFFSET, variation_style = NEXUS_LIGHT_VARIATION_AURA)
			nexus_aura_glow_generation++
			if(!nexus_aura_glow)
				nexus_aura_glow = new
				vis_contents += nexus_aura_glow
			nexus_aura_glow.light_origin = src
			nexus_aura_glow.configureNexusEmitter(light_color, size, light_alpha, light_icon, TRUE, gradient_offset, variation_style)
			CenterIcon(nexus_aura_glow)
			startNexusLightOcclusionTracking()
			return nexus_aura_glow

		clearNexusAuraGlow()
			nexus_aura_glow_generation++
			if(!nexus_aura_glow) return
			vis_contents -= nexus_aura_glow
			del(nexus_aura_glow)
			nexus_aura_glow = null

		pulseNexusGlow(light_color = "#ffffff", size = 2, light_alpha = 180, duration = 8, light_icon = 'NexusLightGradient.dmi', gradient_offset = NEXUS_GLOW_DEFAULT_OFFSET)
			set waitfor = 0
			var/obj/NexusLighting/Emitter/pulse = new
			pulse.light_origin = src
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
	setNexusGlow(profile["color"], profile["size"], profile["alpha"], 'NexusLightGradient.dmi', 8, NEXUS_LIGHT_VARIATION_AURA)

obj/Blast/proc/updateNexusProjectileGlow()
	var/list/profile = getNexusProjectileLightProfile(src)
	if(!profile)
		clearNexusGlow()
		return
	if(nexus_glow && nexus_glow.color == profile["color"] && abs(nexus_glow.range_tiles - profile["size"]) < 0.01 && nexus_glow.light_intensity == profile["alpha"] && nexus_glow.gradient_offset == profile["offset"] && nexus_glow.variation_style == profile["variation"])
		return nexus_glow
	return setNexusGlow(profile["color"], profile["size"], profile["alpha"], 'NexusLightGradient.dmi', profile["offset"], profile["variation"])

mob/proc/startNexusKiCharge(obj/attack, charge_scale = 1)
	charge_scale = Clamp(charge_scale, 0.5, 2.5)
	var/obj/Attacks/ki_attack = istype(attack, /obj/Attacks) ? attack : null
	return setNexusActionGlow(getNexusAttackGlowColor(ki_attack), 1.9 + charge_scale * 0.85, 175 + round(charge_scale * 25), 'NexusLightGradient.dmi', 8, NEXUS_LIGHT_VARIATION_CHARGE)

mob/proc/startNexusBeamGlow(obj/Attacks/attack)
	return setNexusActionGlow(getNexusAttackGlowColor(attack), 3.5, 225, 'NexusLightGradient.dmi', 8, NEXUS_LIGHT_VARIATION_BEAM_SOURCE)

mob/proc/updateNexusAuraGlow()
	var/list/profile = getNexusAuraGlowProfile(src)
	if(!profile)
		clearNexusAuraGlow()
		return
	return setNexusAuraGlow(profile["color"], profile["size"], profile["alpha"], 'NexusLightGradient.dmi', 8, NEXUS_LIGHT_VARIATION_AURA)

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

mob/proc/launchNexusLightingTestBlast(light_size = 2.3, light_alpha = 215, variation_style = NEXUS_LIGHT_VARIATION_BLAST)
	set waitfor = 0
	if(!loc) return
	var/obj/Effect/NexusLightingTestBlast/test_blast = new(loc)
	test_blast.dir = dir
	test_blast.pixel_x = pixel_x
	test_blast.pixel_y = pixel_y
	test_blast.setNexusGlow("#59d8ff", light_size, light_alpha, 'NexusLightGradient.dmi', variation_style == NEXUS_LIGHT_VARIATION_SMALL_BLAST ? 4 : 8, variation_style)
	player_view(10, src) << sound('Blast.wav', volume = 20)
	for(var/flight_step = 1, flight_step <= 14 && test_blast, flight_step++)
		if(!step(test_blast, test_blast.dir)) break
		sleep(2)
	if(test_blast)
		test_blast.pulseNexusGlow("#c8f7ff", 4.5, 255, 8)
		sleep(8)
		if(test_blast) del(test_blast)

mob/proc/launchNexusLightingTestBeam()
	set waitfor = 0
	if(!loc) return
	var/turf/beam_loc = loc
	for(var/beam_step = 1, beam_step <= 14, beam_step++)
		beam_loc = get_step(beam_loc, dir)
		if(!beam_loc || beam_loc.density) break
		var/obj/Effect/NexusLightingTestBlast/segment = new(beam_loc)
		segment.dir = dir
		segment.setNexusGlow("#59d8ff", 1.25, 135, 'NexusLightGradient.dmi', 6, NEXUS_LIGHT_VARIATION_BEAM)
		spawn(45) if(segment) del(segment)
		sleep(1)

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

mob/Admin2/verb/testNexusBeamLighting()
	set name = "Test Lighting Beam"
	set category = "Admin"
	launchNexusLightingTestBeam()

mob/Admin2/verb/testNexusLightVariations()
	set name = "Test Light Variations"
	set category = "Admin"
	var/choice = input(src, "Choose a flicker profile. Attached profiles remain for 10 seconds.", "Light Variations") in list("Cancel", "Small Blast", "Standard Blast", "Beam Trail", "Beam Source", "Aura", "Ki Charge")
	switch(choice)
		if("Small Blast") launchNexusLightingTestBlast(1.05, 145, NEXUS_LIGHT_VARIATION_SMALL_BLAST)
		if("Standard Blast") launchNexusLightingTestBlast()
		if("Beam Trail") launchNexusLightingTestBeam()
		if("Beam Source") setNexusActionGlow("#59d8ff", 3.5, 225, 'NexusLightGradient.dmi', 8, NEXUS_LIGHT_VARIATION_BEAM_SOURCE)
		if("Aura") setNexusAuraGlow("#76dfff", 3, 190, 'NexusLightGradient.dmi', 8, NEXUS_LIGHT_VARIATION_AURA)
		if("Ki Charge") setNexusActionGlow("#59d8ff", 2.75, 210, 'NexusLightGradient.dmi', 8, NEXUS_LIGHT_VARIATION_CHARGE)
	if(choice in list("Beam Source", "Ki Charge"))
		var/action_generation = nexus_action_glow_generation
		spawn(100) if(src && nexus_action_glow_generation == action_generation) clearNexusActionGlow()
	else if(choice == "Aura")
		var/aura_generation = nexus_aura_glow_generation
		spawn(100) if(src && nexus_aura_glow_generation == aura_generation) clearNexusAuraGlow()

mob/Admin2/verb/testNexusTurfOcclusion()
	set name = "Test Turf Light Collision"
	set category = "Admin"
	if(!loc)
		src << "You must be on the map to test turf light collision."
		return
	nexus_light_turf_occlusion_enabled = TRUE
	setMaximumDarkness()
	setNexusActionGlow("#fff4cf", 7, 255, 'NexusLightGradient.dmi', 10, NEXUS_LIGHT_VARIATION_CHARGE)
	var/test_generation = nexus_action_glow_generation
	src << "A seven-tile test light will follow you for 20 seconds. Walk beside walls and closed opaque doors: their visible face is lit, but tiles behind them remain dark."
	spawn(200) if(src && nexus_action_glow_generation == test_generation) clearNexusActionGlow()

mob/Admin2/verb/testNexusLighting()
	set name = "Test Lighting"
	set category = "Admin"
	if(!client) return
	var/choice = input(src, "Choose a lighting test for your current area.", "Nexus Lighting") in list("Cancel", "Maximum Darkness", "Night", "Day", "White Glow", "Turf Light Collision", "Lighting Blast", "Beam Lighting", "Light Variations", "Warm Attack Glow", "Blue Transformation Glow", "Toggle Personal Lighting")
	switch(choice)
		if("Maximum Darkness") setMaximumDarkness()
		if("Night")
			if(current_area) current_area.FadeToNight()
		if("Day")
			if(current_area) current_area.FadeToDay()
		if("White Glow") testNexusGlow()
		if("Turf Light Collision") testNexusTurfOcclusion()
		if("Lighting Blast") testNexusBlast()
		if("Beam Lighting") testNexusBeamLighting()
		if("Light Variations") testNexusLightVariations()
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
			startNexusStaticLightOcclusionUpdates()

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
			startNexusStaticLightOcclusionUpdates()
			if(!show_light)
				animate(l)
				l.alpha = 0
				if(l.core_visual)
					animate(l.core_visual)
					l.core_visual.alpha = 0
