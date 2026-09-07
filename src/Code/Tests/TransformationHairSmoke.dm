proc/runTransformationHairSmokeTests()
	var/obj/Hairs/Hair_Caulifla/caulifla = new
	nexusSmokeAssert(caulifla.SSj3_Hair == caulifla.SSj2_Hair && caulifla.SSj2_Hair, "Caulifla lost her shared SSJ2/SSJ3 hair")
	var/obj/Hairs/Hair14/goku = new
	nexusSmokeAssert(goku.SSj_Hair == 'src/Icons/PlayerIcons/Hair/HairGokuSSj.dmi' && goku.SSj3_Hair == 'src/Icons/PlayerIcons/Hair/HairGokuSSj3Old.dmi', "Goku's authored transformation hair changed")
	var/obj/Hairs/Bald/bald = new
	nexusSmokeAssert(!bald.icon && !bald.SSj_Hair && !bald.SSj3_Hair, "Bald hair generated transformation sprites")
	for(var/hair_type in typesof(/obj/Hairs) - /obj/Hairs - /obj/Hairs/Bald)
		var/obj/Hairs/style = new hair_type
		nexusSmokeAssert(style.icon && style.SSj_Hair && style.USSj_Hair && style.SSjFP_Hair && style.SSj2_Hair && style.SSj3_Hair, "[hair_type] has an unresolved transformation variant")
		del(style)
	var/mob/NexusSmokeTest/player = new
	player.hair = 'src/Icons/PlayerIcons/Hair/HairGoku.dmi' + rgb(20, 30, 40)
	player.ssjhair = goku.SSj_Hair
	player.ssjfphair = goku.SSjFP_Hair
	player.ussjhair = goku.USSj_Hair
	player.ssj3hair = 'src/Icons/PlayerIcons/Hair/HairGokuSSj3.dmi'
	player.ssj = 1
	player.has_ss_full_power = FALSE
	nexusSmokeAssert(player.getActiveTransformationHair() == player.ssjhair, "SSJ1 does not select the unmastered hair")
	nexusSmokeAssert(player.getTransformationHair("base") == player.hair && player.ssj == 1, "Hair preview loses the original color or changes transformation state")
	player.has_ss_full_power = TRUE
	nexusSmokeAssert(player.getActiveTransformationHair() == player.ssjfphair, "Full Power hair selection regressed")
	player.is_ussj = TRUE
	nexusSmokeAssert(player.getActiveTransformationHair() == player.ussjhair, "USSJ hair priority regressed")
	player.ismystic = TRUE
	nexusSmokeAssert(player.getActiveTransformationHair() == player.hair, "Mystic should retain the original hair")
	player.is_ssg = TRUE
	player.is_ssj_blue = TRUE
	nexusSmokeAssert(player.getActiveTransformationHairKey() == "blue", "Blue no longer takes priority over God and Mystic")
	player.ultra_instinct = TRUE
	nexusSmokeAssert(player.getActiveTransformationHair() == player.hair, "Ultra Instinct no longer takes priority over other hair variants")
	player.ultra_instinct = FALSE
	player.is_ssj_blue = FALSE
	player.is_ssg = FALSE
	player.ismystic = FALSE
	player.ssj = 3
	player.ssj3drain = 300
	nexusSmokeAssert(player.getActiveTransformationHair() == 'src/Icons/PlayerIcons/Hair/Ssj3Mastered.dmi', "Mastered Goku SSJ3 hair exception regressed")
	player.ssj3drain = 299
	nexusSmokeAssert(player.getActiveTransformationHair() == player.ssj3hair, "Unmastered SSJ3 uses the mastered sprite")
	player.ssj = 0
	nexusSmokeAssert(player.getActiveTransformationHair() == player.hair, "Reverting does not restore the original colored hair")
	player.ssj_blue_hair = goku.SSj_Hair
	player.ssj_god_hair = goku.SSj_Hair
	player.royalBlueHair = goku.SSj_Hair
	Apply_Hair(player, bald)
	nexusSmokeAssert(!player.hair && !player.ssjhair && !player.ssj_blue_hair && !player.ssj_god_hair && !player.royalBlueHair, "Selecting Bald retains a previous transformation's hair")
	del(player)
	del(caulifla)
	del(goku)
	del(bald)

proc/runSsjAwakeningSmokeTests()
	var/list/scene_dimmers = list("one" = 0.78, "two" = 0.9)
	nexusSmokeAssert(getNexusAwakeningDimmerAlpha(scene_dimmers) == 56, "Cinematic darkness must be capped at 22 percent")
	scene_dimmers -= "one"
	nexusSmokeAssert(getNexusAwakeningDimmerAlpha(scene_dimmers) == 25, "Removing one cinematic must preserve the other dimmer")
	scene_dimmers.Cut()
	nexusSmokeAssert(getNexusAwakeningDimmerAlpha(scene_dimmers) == 0, "No cinematic may leave darkening behind")
	var/obj/NexusAwakeningDimmer/scene_dimmer = new
	nexusSmokeAssert(scene_dimmer.plane < 15 && scene_dimmer.blend_mode == BLEND_DEFAULT, "Cinematic dimmer must darken beneath the existing lighting plane")
	var/icon/dimmer_tile = icon(scene_dimmer.icon)
	nexusSmokeAssert(dimmer_tile.GetPixel(16, 16) == "#000000", "Cinematic dimmer must only darken, never brighten")
	del(scene_dimmer)
	var/list/dimmers = list("first" = 0.5, "second" = 0.25)
	nexusSmokeAssert(getNexusAwakeningAmbient("#808080", dimmers) == rgb(32, 32, 32), "Overlapping awakenings must use the darkest light modifier")
	dimmers -= "second"
	nexusSmokeAssert(getNexusAwakeningAmbient("#808080", dimmers) == rgb(64, 64, 64), "Finishing one awakening must preserve the remaining modifier")
	dimmers.Cut()
	nexusSmokeAssert(getNexusAwakeningAmbient("#808080", dimmers) == "#808080", "Finishing all awakenings must restore ambient light")
	var/mob/NexusSmokeTest/player = new
	player.pixel_y = 7
	player.ssj = 1
	var/datum/NexusSsjAwakening/effect = new
	effect.actor = player
	effect.original_pixel_y = 7
	player.nexus_ssj_awakening = effect
	effect.cleanup()
	effect.cleanup()
	nexusSmokeAssert(!player.nexus_ssj_awakening && player.pixel_y == 7 && player.ssj == 1, "Awakening cleanup must be idempotent and preserve gameplay state")
	var/icon/aura = icon('src/Icons/Ki/GoldenAura.dmi')
	nexusSmokeAssert(aura.Width() == 96 && aura.Height() == 128, "Golden aura frame dimensions changed")
	var/icon/body = icon('src/Icons/Ki/GoldenAura.dmi', "", SOUTH, 1)
	body.DrawBox(null, 1, 1, body.Width(), body.Height())
	body.DrawBox("#ffffff", 11, 8, 31, 40)
	player.icon = body
	player.dir = SOUTH
	var/list/feet = getNexusAwakeningAnchor(player)
	nexusSmokeAssert(feet[1] == 20.5 && feet[2] == 7, "Awakening anchor must follow visible body bounds instead of tile center")
	nexusSmokeAssert(getNexusAwakeningDuration() >= 200, "SSJ1 awakening must last at least twenty seconds")
	var/datum/NexusSsjAwakening/interrupted = new
	interrupted.cancelled = TRUE
	var/previous_visuals = player.vis_contents.len
	nexusSmokeAssert(!interrupted.playSequence(player), "Interrupted awakening must not report completion")
	nexusSmokeAssert(player.vis_contents.len == previous_visuals && !player.nexus_ssj_awakening && player.pixel_y == 7, "Interrupted awakening leaked attached hair, aura or levitation")
	var/icon/strike = icon('src/Icons/Ki/Electricity/FallingLightning.dmi')
	nexusSmokeAssert(strike.Height() == 192, "Falling lightning must span six tiles vertically")
	fcopy(icon('src/Icons/PlayerIcons/Hair/HairGoku.dmi', "", SOUTH, 1), "SsjPreviewBaseHair.png")
	fcopy(icon('src/Icons/PlayerIcons/Hair/HairGokuSSj.dmi', "", SOUTH, 1), "SsjPreviewGoldHair.png")
	fcopy(icon('src/Icons/PlayerIcons/BaseIcons/NewHumanIconsFromGuppinas/BaseHumanPale.dmi', "", SOUTH, 1), "SsjPreviewBody.png")
	player.ssjdrain = 150
	player.has_ss_full_power = FALSE
	nexusSmokeAssert(getNexusAwakeningDuration(player) == 220, "First awakening should keep its long buildup")
	player.ssjdrain = 225
	var/partial_duration = getNexusAwakeningDuration(player)
	nexusSmokeAssert(partial_duration > 6 && partial_duration < 220, "Partial mastery should shorten the opening")
	player.ssjdrain = 300
	nexusSmokeAssert(getNexusAwakeningDuration(player) == 6, "Mastered SSJ should transform effortlessly")
	player.ssjdrain = 150
	player.has_ss_full_power = TRUE
	nexusSmokeAssert(getNexusSsjVisualMastery(player) == 1, "Full Power unlock must select mastered visuals")
	player.has_ss_full_power = FALSE
	player.updateTransformationGlow()
	nexusSmokeAssert(player.nexus_glow && player.nexus_ssj_daylight_glow, "SSJ needs both a light emitter and a visible daylight glow")
	nexusSmokeAssert(player.nexus_ssj_daylight_glow.plane == NEXUS_WORLD_OVERLAY_PLANE && player.nexus_ssj_daylight_glow.blend_mode == BLEND_ADD, "Daylight glow must render above ambient lighting")
	var/icon/daylight_frame = icon(player.nexus_ssj_daylight_glow.icon, player.nexus_ssj_daylight_glow.icon_state, SOUTH, 1)
	nexusSmokeAssert(player.nexus_ssj_daylight_glow.icon_state in icon_states(player.nexus_ssj_daylight_glow.icon), "Daylight glow selected a missing icon state")
	nexusSmokeAssert(nexusPreviewFrameHasPixels(daylight_frame), "Daylight glow must contain visible gradient pixels")
	for(var/edge_pixel = 1, edge_pixel <= 256, edge_pixel++)
		nexusSmokeAssert(!daylight_frame.GetPixel(edge_pixel, 1) && !daylight_frame.GetPixel(edge_pixel, 256) && !daylight_frame.GetPixel(1, edge_pixel) && !daylight_frame.GetPixel(256, edge_pixel), "Visible SSJ halo must have transparent borders, not an opaque black rectangle")
	nexusSmokeAssert(daylight_frame.GetPixel(128, 128), "Visible SSJ halo must retain its bright center")
	var/list/day_dimmer = list("awakening" = 0.78)
	var/list/day_channels = rgb2num(getNexusAwakeningAmbient("#ffffff", day_dimmer))
	nexusSmokeAssert(day_channels[1] >= 198 && day_channels[1] <= 200, "Daytime awakening should dim only slightly")
	var/list/night_channels = rgb2num(getNexusAwakeningAmbient("#182030", day_dimmer))
	nexusSmokeAssert(night_channels[1] <= 24 && night_channels[2] <= 32 && night_channels[3] <= 48, "Awakening must never brighten the night ambient")
	day_dimmer.Cut()
	nexusSmokeAssert(getNexusAwakeningAmbient("#182030", day_dimmer) == "#182030", "Ending an awakening must preserve night ambient")
	var/unmastered_alpha = player.nexus_ssj_daylight_glow.alpha
	player.ssjdrain = 300
	player.updateNexusSsjDaylightGlow()
	nexusSmokeAssert(player.nexus_ssj_daylight_glow.alpha > 0 && player.nexus_ssj_daylight_glow.alpha < unmastered_alpha, "Mastered SSJ should retain a subtler golden glow")
	player.ssj = 0
	player.updateTransformationGlow()
	nexusSmokeAssert(!player.nexus_ssj_daylight_glow && !player.nexus_glow, "Reversion must remove both SSJ glow layers")
	del(player)
