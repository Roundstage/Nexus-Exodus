// A 22-second SSJ1 awakening. The datum owns all temporary visual state.
client/var/tmp/list/nexus_awakening_dimmers
client/var/tmp/list/nexus_awakening_sound_channels
client/var/tmp/obj/NexusAwakeningDimmer/nexus_awakening_dimmer

proc/getNexusAwakeningDimmerAlpha(list/dimmers)
	var/strength = 1
	for(var/key in dimmers) strength = min(strength, dimmers[key])
	return round(255 * (1 - Clamp(strength, 0.78, 1)))

// Only darkens the world beneath the existing lighting plane. Never rewrites ambient.
obj/NexusAwakeningDimmer
	plane = 14
	layer = FLOAT_LAYER
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	mouse_opacity = 0
	Savable = 0
	Grabbable = 0
	attackable = 0
	alpha = 0
	New()
		..()
		var/icon/tile = icon('src/Icons/Ki/GoldenGlow.png')
		tile.Scale(32, 32)
		tile.DrawBox("#000000", 1, 1, 32, 32)
		icon = tile

client/proc/refreshNexusAwakeningDimmer()
	var/target_alpha = nexus_lighting_enabled ? getNexusAwakeningDimmerAlpha(nexus_awakening_dimmers) : 0
	if(!target_alpha && !length(nexus_awakening_dimmers))
		if(nexus_awakening_dimmer)
			screen -= nexus_awakening_dimmer
			del(nexus_awakening_dimmer)
		return
	if(!nexus_awakening_dimmer)
		nexus_awakening_dimmer = new
		screen += nexus_awakening_dimmer
	animate(nexus_awakening_dimmer, alpha = target_alpha, time = 3)

proc/getNexusAwakeningAmbient(ambient_color, list/dimmers)
	if(!length(dimmers)) return ambient_color
	var/strength = 1
	for(var/key in dimmers) strength = min(strength, dimmers[key])
	var/list/channels = rgb2num(ambient_color)
	return rgb(channels[1] * strength, channels[2] * strength, channels[3] * strength)

proc/getNexusSsjVisualMastery(mob/player)
	if(!player) return 0
	if(player.has_ss_full_power) return 1
	return Clamp((player.ssjdrain - 150) / max(1, max_ss_mastery - 150), 0, 1)

proc/getNexusAwakeningDuration(mob/player)
	var/mastery = getNexusSsjVisualMastery(player)
	return round(6 + 214 * (1 - mastery) ** 2)

mob/var/tmp/obj/NexusAwakeningEffect/nexus_ssj_daylight_glow
mob/var/tmp/nexus_ssj_daylight_key

mob/proc/updateNexusSsjDaylightGlow()
	if(ssj != 1 || ismystic || ultra_instinct || is_ssj_blue || is_ssg)
		if(nexus_ssj_daylight_glow)
			vis_contents -= nexus_ssj_daylight_glow
			del(nexus_ssj_daylight_glow)
		return
	var/visual_key = "\ref[icon]|[icon_state]|[dir]|[round(getNexusSsjVisualMastery(src) * 100)]"
	if(nexus_ssj_daylight_glow && nexus_ssj_daylight_key == visual_key) return
	nexus_ssj_daylight_key = visual_key
	if(!nexus_ssj_daylight_glow)
		nexus_ssj_daylight_glow = new(src)
		nexus_ssj_daylight_glow.icon = 'src/Icons/Ki/GoldenGlow.png'
		nexus_ssj_daylight_glow.icon_state = ""
		nexus_ssj_daylight_glow.blend_mode = BLEND_ADD
		nexus_ssj_daylight_glow.plane = NEXUS_WORLD_OVERLAY_PLANE
		nexus_ssj_daylight_glow.color = "#ffffff"
		vis_contents += nexus_ssj_daylight_glow
	var/list/feet = getNexusAwakeningAnchor(src)
	var/icon/glow_icon = icon(nexus_ssj_daylight_glow.icon)
	nexus_ssj_daylight_glow.pixel_x = feet[1] - glow_icon.Width() / 2
	nexus_ssj_daylight_glow.pixel_y = feet[2] + 16 - glow_icon.Height() / 2
	var/mastery = getNexusSsjVisualMastery(src)
	nexus_ssj_daylight_glow.transform = matrix() * (0.38 - mastery * 0.2)
	nexus_ssj_daylight_glow.alpha = 120 - mastery * 75

// BYOND coordinates use the bottom-left pixel. Find the visible body's feet and center.
proc/getNexusAwakeningAnchor(mob/player)
	if(!player || !player.icon) return list(16, 0)
	var/icon/body = icon(player.icon, player.icon_state, player.dir, 1)
	var/left = body.Width() + 1
	var/right = 0
	var/bottom = body.Height() + 1
	for(var/x = 1, x <= body.Width(), x++)
		for(var/y = 1, y <= body.Height(), y++)
			if(!body.GetPixel(x, y)) continue
			left = min(left, x)
			right = max(right, x)
			bottom = min(bottom, y)
	if(!right) return list(body.Width() / 2, 0)
	return list((left + right - 1) / 2, bottom - 1)

obj/NexusAwakeningEffect
	icon = null
	Savable = 0
	Grabbable = 0
	attackable = 0
	Nukable = 0
	density = 0
	mouse_opacity = 0
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
	Del()
		clearNexusGlow()
		..()

mob/var/tmp/datum/NexusSsjAwakening/nexus_ssj_awakening

datum/NexusSsjAwakening
	var/mob/actor
	var/obj/NexusAwakeningEffect/aura
	var/obj/NexusAwakeningEffect/base_hair
	var/obj/NexusAwakeningEffect/golden_hair
	var/obj/NexusAwakeningEffect/hair_glow
	var/list/observers = list()
	var/list/sound_channels = list()
	var/list/distortion_planes = list()
	var/list/distortion_filters = list()
	var/list/transient_effects = list()
	var/original_pixel_y
	var/list/anchor
	var/intensity = 1
	var/cancelled = FALSE
	var/finished = FALSE

	proc/attachEffect(icon_file, layer_offset)
		var/obj/NexusAwakeningEffect/effect = new(actor)
		effect.icon = icon_file
		effect.layer = actor.layer + layer_offset
		effect.plane = actor.plane
		effect.vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE
		actor.vis_contents += effect
		return effect

	proc/playSequence(mob/player, duration = 220)
		duration = getNexusAwakeningDuration(player)
		intensity = 1 - getNexusSsjVisualMastery(player)
		actor = player
		original_pixel_y = actor.pixel_y
		anchor = getNexusAwakeningAnchor(actor)
		actor.nexus_ssj_awakening = src
		actor.updateNexusSsjDaylightGlow()
		aura = attachEffect('src/Icons/Ki/GoldenAura.dmi', -0.05)
		aura.pixel_x = anchor[1] - 48
		aura.pixel_y = anchor[2] - 12
		aura.alpha = 0
		// Matrix translation keeps the feet fixed as the aura grows from below.
		aura.transform = matrix(0.3, 0, 0, 0, 0.3, -36.4)
		aura.setNexusGlow("#ffcb46", 1, 0)
		base_hair = attachEffect(actor.getTransformationHair("base"), 0.01)
		golden_hair = attachEffect(actor.getActiveTransformationHair(), 0.02)
		golden_hair.alpha = 0
		hair_glow = attachEffect(actor.getActiveTransformationHair(), 0.03)
		hair_glow.blend_mode = BLEND_ADD
		hair_glow.color = "#fff1b0"
		hair_glow.filters += filter(type = "blur", size = 1.5)
		hair_glow.alpha = 0
		actor.overlays -= actor.getTransformationHair("base")
		actor.overlays -= actor.getTransformationHair("ssj")
		if(intensity <= 0)
			animate(base_hair, alpha = 0, time = duration)
			animate(golden_hair, alpha = 255, time = duration)
			sleep(duration)
			if(!actor || actor.ssj != 1 || actor.KO || actor.Dead) cancelled = TRUE
			cleanup()
			return !cancelled
		var/turf/start_turf = getNexusLightTurf(actor)
		var/had_client = !!actor.client
		var/start_time = world.time
		var/next_strike = 35
		var/next_sound = 0
		var/next_observer_update = 0
		var/list/shock_times = list(35, 65, 90, 112, 130, 146, 160, 172, 182, 190, 196, 203)
		var/shock_index = 1
		while(actor && !cancelled && world.time - start_time < duration)
			var/elapsed = (world.time - start_time) * 220 / duration
			if(actor.ssj != 1 || actor.KO || actor.Dead || getNexusLightTurf(actor) != start_turf || (had_client && !actor.client))
				cancelled = TRUE
				break
			var/power = min(1, elapsed / 190)
			if(elapsed >= next_observer_update)
				updateObservers(elapsed >= 205 ? 1 - 0.22 * intensity * (220 - elapsed) / 15 : 1 - power * 0.22 * intensity)
				next_observer_update = elapsed + 10
			var/gold = elapsed < 25 ? 0 : (1 + sin((elapsed - 25) * (6 + power * 11))) / 2
			if(elapsed >= 185) gold = 1
			animate(base_hair, alpha = 255 * (1 - gold), time = 2)
			animate(golden_hair, alpha = 255 * gold, color = gold > 0.85 ? "#fffbd8" : "#ffffff", time = 2)
			animate(hair_glow, alpha = 200 * gold * gold * (elapsed >= 205 ? (220 - elapsed) / 15 : 1), time = 2)
			var/scale = 0.3 + power * 0.7 * intensity
			var/aura_alpha = elapsed < 25 ? elapsed : 55 + power * 160 + gold * 30
			if(elapsed >= 205) aura_alpha = max(0, 230 * (220 - elapsed) / 15)
			animate(aura, alpha = aura_alpha * intensity, transform = matrix(scale, 0, 0, 0, scale, -52 * (1 - scale)), time = 2)
			aura.setNexusGlow("#ffd45a", 1 + power * 3, (35 + power * 145 + gold * 35) * (elapsed >= 205 ? (220 - elapsed) / 15 : 1))
			var/lift = (power * 7 + sin(elapsed * 6) * power) * (elapsed >= 205 ? (220 - elapsed) / 15 : 1)
			animate(actor, pixel_y = original_pixel_y + lift * intensity, time = 2, flags = ANIMATION_PARALLEL)
			if(intensity > 0.25 && elapsed >= next_strike && elapsed < 207)
				spawnLightning(power * intensity)
				next_strike = elapsed + max(9, 30 - power * 22)
			if(shock_index <= shock_times.len && elapsed >= shock_times[shock_index])
				if(intensity > 0.25 && shock_index % max(1, round(1 / intensity)) == 0)
					spawnShockwave(power * intensity)
					pulseDistortion(power * intensity)
					playSound('src/Sound/SoundEffects/Combat/Kiplosion.ogg', (20 + power * 35) * intensity, 1)
				shock_index++
			if(elapsed >= next_sound && elapsed < 185)
				playSound('src/Sound/SoundEffects/Combat/Aura3.ogg', (18 + power * 30) * intensity)
				next_sound = elapsed + 45
			sleep(2)
		if(!actor) cancelled = TRUE
		cleanup()
		return !cancelled

	proc/updateObservers(strength)
		for(var/client/observer in observers.Copy())
			if(!observer.mob || observer.mob.z != actor.z || get_dist(observer.mob, actor) > 12)
				releaseObserver(observer)
		for(var/mob/witness in viewers(12, actor))
			if(!witness.client) continue
			var/client/observer = witness.client
			if(!(observer in observers))
				if(!observer.nexus_awakening_sound_channels) observer.nexus_awakening_sound_channels = list()
				for(var/channel = 800, channel < 980, channel += 3)
					if(observer.nexus_awakening_sound_channels["[channel]"]) continue
					observer.nexus_awakening_sound_channels["[channel]"] = src
					sound_channels[observer] = channel
					break
			observers |= observer
			if(!observer.nexus_awakening_dimmers) observer.nexus_awakening_dimmers = list()
			observer.nexus_awakening_dimmers[src] = strength
			observer.refreshNexusAwakeningDimmer()

	proc/playSound(sound_file, volume, sound_slot = 0)
		for(var/client/observer in observers)
			var/channel = sound_channels[observer]
			if(channel) observer << sound(sound_file, volume = volume, wait = 0, channel = channel + sound_slot)

	proc/spawnLightning(power)
		if(!actor) return
		var/obj/NexusAwakeningEffect/bolt = new(getNexusLightTurf(actor))
		transient_effects += bolt
		bolt.icon = 'src/Icons/Ki/Electricity/FallingLightning.dmi'
		bolt.icon_state = "lightning[rand(0, 3)]"
		bolt.pixel_x = actor.pixel_x + anchor[1] - 16 + pick(-1, 1) * rand(18, 55)
		bolt.pixel_y = original_pixel_y + anchor[2] - 4
		bolt.layer = actor.layer + 0.2
		bolt.plane = actor.plane
		bolt.setNexusGlow("#fff0b0", 2 + power, 220)
		playSound('src/Sound/SoundEffects/Combat/Shonen/Electric/Electric01V1.ogg', 25 + power * 30, 2)
		spawn(4)
			transient_effects -= bolt
			if(bolt) del(bolt)

	proc/spawnShockwave(power)
		if(!actor || shockwaves_off) return
		var/obj/NexusAwakeningEffect/ring = new(getNexusLightTurf(actor))
		transient_effects += ring
		ring.icon = 'src/Icons/Unsorted/Shockwave2016.png'
		var/icon/frame = icon(ring.icon)
		ring.pixel_x = actor.pixel_x + anchor[1] - frame.Width() / 2
		ring.pixel_y = original_pixel_y + anchor[2] - frame.Height() / 2
		ring.layer = actor.layer - 0.1
		ring.plane = actor.plane
		ring.color = "#ffe9a6"
		ring.alpha = 210
		ring.transform = matrix() * 0.04
		var/matrix/expanded = matrix()
		expanded.Scale(0.6 + power * 1.5, 0.3 + power * 0.65)
		animate(ring, transform = expanded, alpha = 0, time = 9, easing = SINE_EASING)
		spawn(10)
			transient_effects -= ring
			if(ring) del(ring)

	proc/pulseDistortion(power)
		for(var/client/observer in observers)
			if(!islist(observer.nexus_map_zoom_plane_masters)) continue
			for(var/plane_key in observer.nexus_map_zoom_plane_masters)
				var/obj/plane_master = observer.nexus_map_zoom_plane_masters[plane_key]
				if(!plane_master) continue
				var/index = distortion_planes.Find(plane_master)
				if(!index)
					plane_master.filters += filter(type = "wave", x = 0, y = 64, size = 0, offset = 0)
					distortion_planes += plane_master
					distortion_filters += plane_master.filters[plane_master.filters.len]
					index = distortion_planes.len
				var/wave_filter = distortion_filters[index]
				animate(wave_filter, offset = 0, size = 0.5 + power * 2, time = 0)
				animate(offset = 1, size = 0, time = 8)

	proc/releaseObserver(client/observer)
		var/channel = sound_channels[observer]
		if(channel)
			for(var/slot = 0, slot < 3, slot++) observer << sound(null, channel = channel + slot)
			observer.nexus_awakening_sound_channels -= "[channel]"
			sound_channels -= observer
		observer.nexus_awakening_dimmers -= src
		observer.refreshNexusAwakeningDimmer()
		if(islist(observer.nexus_map_zoom_plane_masters))
			for(var/plane_key in observer.nexus_map_zoom_plane_masters)
				var/obj/plane_master = observer.nexus_map_zoom_plane_masters[plane_key]
				var/index = distortion_planes.Find(plane_master)
				if(!index) continue
				plane_master.filters -= distortion_filters[index]
				distortion_planes.Cut(index, index + 1)
				distortion_filters.Cut(index, index + 1)
		observers -= observer

	proc/cleanup()
		if(finished) return
		finished = TRUE
		for(var/client/observer in observers.Copy()) releaseObserver(observer)
		for(var/i = 1, i <= distortion_planes.len, i++)
			var/obj/plane_master = distortion_planes[i]
			if(plane_master) plane_master.filters -= distortion_filters[i]
		for(var/obj/effect in transient_effects) del(effect)
		for(var/obj/effect in list(aura, base_hair, golden_hair, hair_glow))
			if(!effect) continue
			if(actor) actor.vis_contents -= effect
			del(effect)
		if(actor)
			if(cancelled && actor.nexus_ssj_daylight_glow)
				actor.vis_contents -= actor.nexus_ssj_daylight_glow
				del(actor.nexus_ssj_daylight_glow)
			animate(actor, pixel_y = original_pixel_y, time = 0, flags = ANIMATION_PARALLEL)
			actor.overlays -= actor.getTransformationHair("base")
			actor.overlays -= actor.getTransformationHair("ssj")
			actor.SSj_Hair()
			if(actor.nexus_ssj_awakening == src) actor.nexus_ssj_awakening = null
		observers.Cut()
		distortion_planes.Cut()
		distortion_filters.Cut()
		transient_effects.Cut()
		actor = null
