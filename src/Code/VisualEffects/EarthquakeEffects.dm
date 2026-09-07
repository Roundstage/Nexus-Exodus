// Authored in Aseprite; source and repeatable DMI export live in artifacts/Earthquake.
proc/showNexusEarthquakeEffect(mob/user, radius)
	if(!user || !isturf(user.base_loc())) return
	var/turf/origin = user.base_loc()
	var/obj/Effect/effect = GetEffect()
	effect.icon = 'src/Icons/Effects/Earthquake.dmi'
	effect.icon_state = "earthquake"
	effect.blend_mode = BLEND_DEFAULT
	effect.appearance_flags |= PIXEL_SCALE
	effect.layer = MOB_LAYER - 0.1
	effect.SafeTeleport(origin)
	// The outer pressure front has a 72px horizontal radius in the source.
	var/effect_scale = max(0.1, radius * world.icon_size / 72)
	effect.transform = matrix() * effect_scale
	// Scale around the cell center, then align the authored ground anchor (80,75).
	effect.pixel_x = user.nexusCollisionCenterXPixels() - (origin.x - 1) * world.icon_size - 80
	effect.pixel_y = user.nexusCollisionCenterYPixels() - (origin.y - 1) * world.icon_size - 64 + 11 * effect_scale
	flick("earthquake", effect)
	// The sprite includes its own collapse and dissipation: do not grow or fade it twice.
	spawn(12)
		if(effect) del(effect)
	return effect
