// Expanding energy shell authored in Aseprite: artifacts/ExplosiveWave.
proc/showNexusExplosiveWaveEffect(mob/user, radius)
	if(!user || !isturf(user.base_loc())) return
	var/turf/origin = user.base_loc()
	var/obj/Effect/effect = GetEffect()
	effect.icon = 'src/Icons/Effects/ExplosiveWave.dmi'
	effect.icon_state = "explosive_wave"
	effect.blend_mode = BLEND_DEFAULT
	effect.appearance_flags |= PIXEL_SCALE
	effect.layer = MOB_LAYER + 0.1
	effect.SafeTeleport(origin)
	// The shell expands to a 72px radius; its animation owns the expansion.
	effect.transform = matrix() * max(0.1, radius * world.icon_size / 72)
	effect.pixel_x = user.nexusCollisionCenterXPixels() - (origin.x - 1) * world.icon_size - 80
	effect.pixel_y = user.nexusCollisionCenterYPixels() - (origin.y - 1) * world.icon_size - 80
	flick("explosive_wave", effect)
	// Twenty frames at 25 fps, including the transparent tail.
	spawn(8)
		if(effect) del(effect)
	return effect
