mob/NexusSmokeTest
	New()
		return

turf/NexusSmokeTest
	density = 0
	opacity = 0
	FlyOverAble = 1

proc/nexusSmokeAssert(condition, message)
	if(!condition)
		CRASH("Nexus smoke test failed: [message]")

proc/nexusSmokeAssertNear(actual, expected, tolerance, message)
	if(!isnum(actual) || abs(actual - expected) > tolerance)
		CRASH("Nexus smoke test failed: [message] (expected [expected], received [actual])")

proc/nexusSmokeStatAllocation(list/profile)
	var/list/allocation = list()
	var/list/caps = profile["caps"]
	var/remaining = profile["budget"]
	for(var/stat_id in NEXUS_CREATION_STATS) allocation[stat_id] = 0
	while(remaining > 0)
		var/allocated
		for(var/stat_id in NEXUS_CREATION_STATS)
			if(remaining <= 0) break
			if(allocation[stat_id] >= caps[stat_id]) continue
			allocation[stat_id]++
			remaining--
			allocated = TRUE
		if(!allocated) CRASH("Unable to build a valid smoke-test stat allocation")
	return allocation

proc/runStartupSmokeTests(soul_contract_count_before)
	nexusSmokeAssert(text2path("/datum/NexusEmoteEditor") && text2path("/datum/NexusPlayerLogViewer"), "emote editor or player log viewer datum is missing")
	nexusSmokeAssert(text2path("/mob/verb/ViewSelfSayWindow"), "player log viewer verb is missing")
	nexusSmokeAssert(normalizeNexusChatChannel("COMBAT") == "combat" && normalizeNexusChatChannel("invalid") == "all", "chat channel normalization is invalid")
	var/chat_separator_html = getNexusChatMessageSeparatorHtml()
	nexusSmokeAssert(findtext(chat_separator_html, "<hr") && findtext(chat_separator_html, "width:100%") && !findtext(chat_separator_html, "----------"), "chat messages do not use a full-width horizontal separator")
	nexusSmokeAssert(text2path("/datum/NexusChatHud") && text2path("/obj/HudWindow"), "HudLib chat types are missing")
	nexusSmokeAssert(text2path("/datum/NexusCharacterSelect"), "three-slot character selector is missing")
	nexusSmokeAssert(NEXUS_CHARACTER_SLOT_LIMIT == 3, "character slot limit is not three")
	nexusSmokeAssert(text2path("/client/proc/returnToNexusReconnectLobby"), "reconnect-to-character-select handoff is missing")
	var/mob/NexusSmokeTest/reconnect_character_test = new
	var/obj/reconnect_location_test = new
	reconnect_character_test.loc = reconnect_location_test
	reconnect_character_test.playerCharacter = TRUE
	nexusSmokeAssert(reconnect_character_test.isNexusReconnectCharacter() && getNexusInitialConnectViewWidth(reconnect_character_test, 61) == 0, "a reconnected live character can still receive the oversized title-screen view")
	reconnect_character_test.playerCharacter = FALSE
	nexusSmokeAssert(!reconnect_character_test.isNexusReconnectCharacter() && getNexusInitialConnectViewWidth(reconnect_character_test, 61) == 61, "a lobby mob no longer receives the title-screen view")
	del(reconnect_character_test)
	del(reconnect_location_test)
	nexusSmokeAssert(getNexusCharacterSavePathForKey("Smoke Key", 1) == "data/Save/smokekey-slot1.sav", "slot-one save path is invalid")
	nexusSmokeAssert(getNexusCharacterSavePathForKey("Smoke Key", 3) == "data/Save/smokekey-slot3.sav", "slot-three save path is invalid")
	nexusSmokeAssert(getNexusCharacterSavePathForKey("Smoke Key", 4) == getNexusCharacterSavePathForKey("Smoke Key", 3), "character slot clamping is invalid")
	nexusSmokeAssert(findtext(getNexusRpgBrowserCss(), "border-radius:0") && findtext(getNexusRpgBrowserCss(), "Courier New"), "shared rustic browser theme is missing")
	var/rich_emote_test = renderNexusEmoteMarkup("<script>\[color=#ff667a]\[b]Hit\[/b]\[/color]")
	nexusSmokeAssert(findtext(rich_emote_test, "&lt;script&gt;") && findtext(rich_emote_test, "<span style='color:#ff667a'><b>Hit</b></span>"), "safe rich emote markup did not render correctly")
	nexusSmokeAssert(!findtext(rich_emote_test, "<script>"), "rich emote markup allowed raw HTML")
	var/formatted_emote_test = buildNexusEmoteMessage("Smoke", rich_emote_test, "Normal")
	nexusSmokeAssert(findtext(formatted_emote_test, "<br><br>") && findtext(formatted_emote_test, "color:#ff667a"), "roleplay title spacing or inline colors were lost")
	var/emote_swatches_test = getNexusEmoteColorSwatchesHtml()
	nexusSmokeAssert(findtext(emote_swatches_test, "background:#f5f7fa!important") && findtext(emote_swatches_test, "background:#ff667a!important") && findtext(emote_swatches_test, "background:#bd93f9!important"), "rustic browser theme can override emote editor color swatches")
	var/fifty_word_test = ""
	for(var/word_index = 1, word_index <= 50, word_index++) fifty_word_test += word_index == 1 ? "word" : " word"
	nexusSmokeAssert(countNexusWords(fifty_word_test) == 50 && countNexusWords("one\ttwo\nthree") == 3, "Say overhead word limit does not count whitespace-delimited words")
	var/combat_log_test = buildNexusCombatLogMessage("Attacker", "Target", "Kienzan", 42, 3, "Health", 58)
	nexusSmokeAssert(findtext(combat_log_test, "Kienzan") && findtext(combat_log_test, "Attacker") && findtext(combat_log_test, "Target") && findtext(combat_log_test, "3 hits / 42 total"), "combat log summary omits attack, participants, or multi-hit damage")
	var/precise_combat_amount = formatNexusCombatAmount(12.34)
	var/precise_combat_log = buildNexusCombatLogMessage("Attacker", "Target", "Precision Test", 12.34, 1, "Health", 87.66)
	nexusSmokeAssert(precise_combat_amount == "12.34" && findtext(precise_combat_log, "12.34 damage") && findtext(precise_combat_log, "87.66% Health remaining"), "damage indicators and combat logs do not share hundredth precision (amount=[precise_combat_amount]; log=[precise_combat_log])")
	var/datum/NexusCombatLogBatch/combat_log_batch_test = new(null, null, "Beam", "Health")
	combat_log_batch_test.addDamage(7, 93)
	combat_log_batch_test.addDamage(5, 88)
	nexusSmokeAssert(combat_log_batch_test.total_damage == 12 && combat_log_batch_test.hit_count == 2 && combat_log_batch_test.remaining_value == 88, "combat damage batching does not aggregate repeated hits")
	del(combat_log_batch_test)
	nexusSmokeAssert(!text2path("/mob/verb/viewAdminLogs"), "admin log viewer is exposed to ordinary mobs")
	nexusSmokeAssert(!text2path("/mob/verb/viewAllAdminLogs"), "combined admin log viewer is exposed to ordinary mobs")
	nexusSmokeAssert(text2path("/mob/Admin1/verb/viewAdminLogs"), "admin log viewer is missing from the admin verb tree")
	nexusSmokeAssert(text2path("/mob/Admin1/verb/viewAllAdminLogs"), "combined admin log viewer is missing from the admin verb tree")
	nexusSmokeAssert(!text2path("/mob/verb/spawnCombatDummy"), "combat dummy spawner is exposed to ordinary mobs")
	nexusSmokeAssert(text2path("/mob/Admin2/verb/spawnCombatDummy"), "combat dummy spawner is missing from the admin verb tree")
	nexusSmokeAssert(text2path("/mob/Admin2/verb/controlCombatDummy"), "combat dummy controller is missing from the admin verb tree")
	nexusSmokeAssert(text2path("/obj/DamageIndicator"), "damage indicator type is missing")
	nexusSmokeAssert(text2path("/obj/NexusHud/VitalsPanel"), "main vitals HUD type is missing")
	nexusSmokeAssert(text2path("/obj/NexusLighting/PlaneMaster") && text2path("/obj/NexusLighting/Emitter"), "screen lighting plane types are missing")
	nexusSmokeAssert(text2path("/mob/verb/toggleNexusLighting") && text2path("/mob/Admin2/verb/testNexusLighting"), "lighting control verbs are missing")
	nexusSmokeAssert(text2path("/mob/Admin2/verb/setMaximumDarkness") && text2path("/mob/Admin2/verb/testNexusGlow") && text2path("/mob/Admin2/verb/testNexusBlast"), "dedicated lighting test verbs are missing")
	nexusSmokeAssert(text2path("/mob/Admin2/verb/testNexusBeamLighting") && text2path("/mob/Admin2/verb/testNexusLightVariations") && text2path("/mob/Admin2/verb/testNexusTurfOcclusion"), "beam, flicker, or turf-collision lighting test verbs are missing")
	nexusSmokeAssert(text2path("/obj/Effect/NexusLightingTestBlast"), "harmless lighting test blast is missing")
	var/obj/NexusLighting/PlaneMaster/lighting_plane = new
	var/obj/NexusLighting/Emitter/lighting_emitter = new
	var/obj/LightSource/static_light = new
	var/icon/lighting_mask = icon('NexusLightGradient.dmi', "10")
	var/list/lighting_states = icon_states('NexusLightGradient.dmi')
	var/list/lighting_center_rgb = rgb2num(lighting_mask.GetPixel(128, 128))
	var/list/lighting_half_rgb = rgb2num(lighting_mask.GetPixel(64, 128))
	var/list/lighting_edge_rgb = rgb2num(lighting_mask.GetPixel(2, 128))
	nexusSmokeAssert(lighting_plane.plane == 15 && lighting_plane.blend_mode == BLEND_MULTIPLY && (lighting_plane.appearance_flags & PLANE_MASTER), "night screen is not a multiplicative plane master")
	nexusSmokeAssert(lighting_emitter.plane == 15 && lighting_emitter.blend_mode == BLEND_ADD, "dynamic glow is not additive on the lighting plane")
	nexusSmokeAssert(lighting_mask.Width() == 256 && lighting_mask.Height() == 256 && ("1" in lighting_states) && ("10" in lighting_states), "configurable lighting gradient is corrupt or incomplete")
	nexusSmokeAssert(lighting_center_rgb[1] > lighting_half_rgb[1] && lighting_half_rgb[1] > lighting_edge_rgb[1], "lighting falloff is not encoded in additive RGB intensity")
	lighting_emitter.configureNexusEmitter("#ffffff", 1, 200, 'NexusLightGradient.dmi', TRUE, 10)
	nexusSmokeAssert(lighting_emitter.core_visual && lighting_emitter.range_tiles == 1 && lighting_emitter.gradient_offset == 10 && lighting_emitter.icon_state == "10" && lighting_emitter.core_visual.icon_state == "1", "layered glow did not apply its requested gradient profile")
	nexusSmokeAssert(lighting_emitter.alpha < lighting_emitter.core_visual.alpha && lighting_emitter.base_core_scale < lighting_emitter.base_range_scale, "layered glow does not have a compact core and softer ranged falloff")
	nexusSmokeAssert(round(getNexusGlowRangeScale(1) * 256 / world.icon_size, 0.1) == 1, "glow size no longer maps to total tile diameter")
	lighting_emitter.configureNexusEmitter("#ffffff", 1.1, 145, 'NexusLightGradient.dmi', TRUE, 4, "small_blast")
	nexusSmokeAssert(lighting_emitter.variation_style == "small_blast" && lighting_emitter.variation_enabled && lighting_emitter.range_tiles == 1.1, "small-blast flicker profile was not applied")
	nexusSmokeAssert(static_light.plane == 15 && static_light.getRenderedAlpha() == 210 && static_light.core_visual, "legacy light sources were not adapted to layered screen lighting")
	var/list/blue_glow_profile = getNexusTransformationGlowProfile("saiyan_blue")
	var/list/test_ambient_matrix = getNexusAmbientMatrix(rgb(16, 22, 38, 255))
	nexusSmokeAssert(islist(test_ambient_matrix) && test_ambient_matrix[4] == "#0000" && blue_glow_profile["color"] == "#42d9ff" && blue_glow_profile["alpha"] >= 200, "ambient alpha reset or transformation glow profiles are invalid")
	var/mob/NexusSmokeTest/lighting_owner = new
	var/obj/NexusLighting/Emitter/action_glow = lighting_owner.setNexusActionGlow("#ffffff", 1, 255, 'NexusLightGradient.dmi', 10, "charge")
	var/obj/NexusLighting/Emitter/aura_glow = lighting_owner.setNexusAuraGlow("#76dfff", 3, 190, 'NexusLightGradient.dmi', 8, "aura")
	nexusSmokeAssert(action_glow && (action_glow in lighting_owner.vis_contents) && action_glow.gradient_offset == 10, "independent beam/action glow was not attached with its requested falloff")
	nexusSmokeAssert(aura_glow && aura_glow != action_glow && (aura_glow in lighting_owner.vis_contents) && aura_glow.variation_style == "aura", "independent aura flicker was not attached")
	lighting_owner.clearNexusActionGlow()
	nexusSmokeAssert(!lighting_owner.nexus_action_glow, "independent beam/action glow was not cleared")
	lighting_owner.clearNexusAuraGlow()
	nexusSmokeAssert(!lighting_owner.nexus_aura_glow, "independent aura glow was not cleared")
	var/obj/Blast/small_light_projectile = new
	var/obj/Attacks/Buster_Barrage/small_light_attack = new
	small_light_projectile.percent_damage = 0.4
	small_light_projectile.from_attack = small_light_attack
	var/list/small_light_profile = getNexusProjectileLightProfile(small_light_projectile)
	var/obj/Blast/large_light_projectile = new
	var/obj/Attacks/Big_Bang_Attack/large_light_attack = new
	large_light_projectile.percent_damage = 22
	large_light_projectile.Explosive = 4
	large_light_projectile.from_attack = large_light_attack
	var/list/large_light_profile = getNexusProjectileLightProfile(large_light_projectile)
	var/large_icon_diameter = getNexusProjectileVisualDiameter(large_light_attack.icon)
	nexusSmokeAssert(large_icon_diameter >= world.icon_size && getNexusProjectileVisualDiameter(large_light_attack.icon) == large_icon_diameter, "projectile icon diameter cache is unstable")
	var/obj/Blast/beam_light_projectile = new
	beam_light_projectile.Beam = 1
	beam_light_projectile.Owner = lighting_owner
	var/list/beam_light_profile = getNexusProjectileLightProfile(beam_light_projectile)
	nexusSmokeAssert(small_light_profile["variation"] == "small_blast" && small_light_profile["size"] <= 1.15, "small blasts do not receive a compact flickering light")
	nexusSmokeAssert(large_light_profile["variation"] == "blast" && large_light_profile["size"] >= 4.2 && large_light_profile["size"] > small_light_profile["size"], "large blasts do not receive their larger light profile")
	nexusSmokeAssert(beam_light_profile["variation"] == "beam" && beam_light_profile["size"] <= 2 && beam_light_profile["alpha"] < large_light_profile["alpha"], "beam segments do not receive a compact trail-light profile")
	small_light_projectile.Is_Ki = 0
	nexusSmokeAssert(!getNexusProjectileLightProfile(small_light_projectile), "physical projectiles incorrectly emit ki lighting")
	var/turf/light_collision_source
	var/turf/light_collision_wall
	var/turf/light_collision_shadow
	for(var/turf/candidate_light_source in world)
		var/turf/candidate_light_wall = get_step(candidate_light_source, EAST)
		var/turf/candidate_light_shadow = candidate_light_wall ? get_step(candidate_light_wall, EAST) : null
		if(candidate_light_wall && candidate_light_shadow)
			light_collision_source = candidate_light_source
			light_collision_wall = candidate_light_wall
			light_collision_shadow = candidate_light_shadow
			break
	nexusSmokeAssert(light_collision_source && light_collision_wall && light_collision_shadow, "startup map has no turf line for light-collision tests")
	var/original_light_source_density = light_collision_source.density
	var/original_light_source_opacity = light_collision_source.opacity
	var/original_light_wall_density = light_collision_wall.density
	var/original_light_wall_opacity = light_collision_wall.opacity
	var/original_light_shadow_density = light_collision_shadow.density
	var/original_light_shadow_opacity = light_collision_shadow.opacity
	light_collision_source.density = 0
	light_collision_source.opacity = 0
	light_collision_wall.density = 1
	light_collision_wall.opacity = 1
	light_collision_shadow.density = 0
	light_collision_shadow.opacity = 0
	nexusSmokeAssert(nexusLightCanReach(light_collision_source, light_collision_wall), "light does not illuminate the visible face of a blocking turf")
	nexusSmokeAssert(!nexusLightCanReach(light_collision_source, light_collision_shadow), "dense opaque turf does not cast a lighting shadow")
	var/light_collision_key = getNexusLightOcclusionCacheKey(light_collision_source, 6)
	var/icon/light_collision_mask = getNexusLightOcclusionMask(light_collision_source, 6, light_collision_key)
	nexusSmokeAssert(light_collision_mask && light_collision_mask.GetPixel(171, 129), "light collision mask removed the blocking turf face")
	nexusSmokeAssert(!light_collision_mask.GetPixel(214, 129), "light collision mask did not clear pixels behind a blocking turf")
	var/obj/NexusLighting/Emitter/occluded_emitter = new(light_collision_source)
	occluded_emitter.configureNexusEmitter("#ffffff", 6, 220, 'NexusLightGradient.dmi', FALSE, 10, "charge")
	nexusSmokeAssert(occluded_emitter.filters && occluded_emitter.occlusion_mask_key == light_collision_key, "eligible light emitter did not apply its turf alpha mask")
	light_collision_source.density = original_light_source_density
	light_collision_source.opacity = original_light_source_opacity
	light_collision_wall.density = original_light_wall_density
	light_collision_wall.opacity = original_light_wall_opacity
	light_collision_shadow.density = original_light_shadow_density
	light_collision_shadow.opacity = original_light_shadow_opacity
	del(occluded_emitter)
	del(small_light_projectile)
	del(small_light_attack)
	del(large_light_projectile)
	del(large_light_attack)
	del(beam_light_projectile)
	del(lighting_plane)
	del(lighting_emitter)
	del(static_light)
	del(lighting_owner)
	nexusSmokeAssert(text2path("/obj/NexusHud/ActionButton/Lethal") && text2path("/obj/NexusHud/ActionButton/RPMode") && text2path("/obj/NexusHud/ActionButton/Character"), "top-right action HUD is incomplete")
	var/icon/action_button_icon = getNexusActionButtonIcon(TRUE, "#ff4d5f")
	nexusSmokeAssert(action_button_icon.Width() == 108 && action_button_icon.Height() == 20, "action HUD button has invalid dimensions")
	nexusSmokeAssert(text2path("/obj/NexusHud/ShortcutButton/Inventory") && text2path("/obj/NexusHud/ShortcutButton/Skills") && text2path("/obj/NexusHud/ShortcutButton/Sense") && text2path("/obj/NexusHud/ShortcutButton/World") && text2path("/obj/NexusHud/ShortcutButton/Chat") && text2path("/obj/NexusHud/ShortcutButton/Hotkeys") && text2path("/obj/NexusHud/ShortcutButton/Menu") && text2path("/obj/NexusHud/ShortcutButton/Admin"), "top shortcut HUD is incomplete")
	nexusSmokeAssert(!text2path("/obj/NexusHud/ShortcutButton/Command"), "obsolete CMD shortcut is still in the navbar")
	nexusSmokeAssert(text2path("/datum/NexusPlayerMenu") && text2path("/datum/NexusInterfaceSettings"), "replacement player menu or interface settings is missing")
	nexusSmokeAssert(text2path("/mob/verb/focusNexusCommand"), "Return-key CMD routing verb is missing")
	nexusSmokeAssert(!text2path("/mob/proc/Stat_NexusSkills") && !text2path("/mob/proc/Stat_NexusOther") && !text2path("/mob/proc/Stat_NexusAdmin"), "synthetic statpanels duplicate native Skills, Other, or Admin tabs")
	nexusSmokeAssert(normalizeNexusInterfaceLayout("side_tabs") == "side_tabs" && normalizeNexusInterfaceLayout("invalid") == "overlay", "interface layout normalization is invalid")
	nexusSmokeAssert(text2path("/obj/Effect/NexusSayText") && text2path("/obj/Effect/NexusTypingIndicator"), "short Say messages or typing feedback are missing their overhead actors")
	var/mob/NexusSmokeTest/overhead_layout_test = new
	overhead_layout_test.icon = 'Healthbar.dmi'
	nexusSmokeAssert(getNexusOverheadVitalsBasePixelY(overhead_layout_test) == -12 && getNexusTypingIndicatorPixelY(overhead_layout_test) == 12 && getNexusOverheadFeedbackPixelY(overhead_layout_test) == 46, "Say text, typing, character, and lower vitals are not vertically ordered")
	nexusSmokeAssert(getNexusTypingIndicatorPixelY(overhead_layout_test) + 32 < getNexusOverheadFeedbackPixelY(overhead_layout_test) && getNexusTypingIndicatorPixelY(overhead_layout_test) + 22 > GetHeight(overhead_layout_test.icon), "typing is not below Say text and above the character")
	nexusSmokeAssert(getNexusOverheadPercentagePixelY(overhead_layout_test) == -25 && getNexusOverheadPercentagePixelY(overhead_layout_test) + 12 < getNexusOverheadVitalsBasePixelY(overhead_layout_test), "Sense percentage is not below the overhead vitals")
	overhead_layout_test.setNexusOverheadVitalsOffset(6, 12)
	nexusSmokeAssert(getNexusOverheadVitalsBasePixelX(overhead_layout_test) == 6 && getNexusOverheadVitalsBasePixelY(overhead_layout_test) == 0 && getNexusOverheadPercentagePixelY(overhead_layout_test) == -13 && getNexusTypingIndicatorPixelY(overhead_layout_test) == 12, "custom vitals offsets do not keep Sense below the bars and typing above the character")
	del(overhead_layout_test)
	var/icon/shortcut_button_icon = getNexusShortcutButtonIcon("inventory", FALSE, "#d6aa5d")
	var/icon/shortcut_bar_icon = getNexusShortcutBarIcon(6)
	nexusSmokeAssert(shortcut_button_icon.Width() == 26 && shortcut_button_icon.Height() == 26, "shortcut HUD button has invalid dimensions")
	nexusSmokeAssert(shortcut_bar_icon.Width() == 176 && shortcut_bar_icon.Height() == 34, "shortcut HUD backing strip has invalid dimensions")
	var/obj/NexusHud/ActionButton/Lethal/lethal_button = new
	var/obj/NexusHud/ActionButton/RPMode/rp_mode_button = new
	var/obj/NexusHud/ActionButton/Character/character_button = new
	var/obj/NexusHud/ShortcutButton/Inventory/inventory_button = new
	var/obj/NexusHud/ShortcutButton/Menu/menu_button = new
	nexusSmokeAssert(lethal_button.plane == 20, "action HUD is not isolated above the lighting plane")
	nexusSmokeAssert(inventory_button.plane == 20 && inventory_button.action_id == "inventory", "shortcut HUD is not isolated or addressable")
	nexusSmokeAssert(menu_button.action_id == "menu", "Escape-menu shortcut is not addressable")
	nexusSmokeAssert(lethal_button.screen_loc == "RIGHT:-8,TOP:-8" && rp_mode_button.screen_loc == "RIGHT:-8,TOP:-32" && character_button.screen_loc == "RIGHT:-8,TOP:-56", "action HUD buttons are not pixel-anchored in the upper-right corner")
	nexusSmokeAssert(!lethal_button.loc && !rp_mode_button.loc && !character_button.loc, "action HUD buttons leaked into an atom's contents")
	del(lethal_button)
	del(rp_mode_button)
	del(character_button)
	del(inventory_button)
	del(menu_button)
	nexusSmokeAssert(text2path("/mob/Admin3/verb/giveMutation") && text2path("/mob/Admin3/verb/rollMutations"), "admin mutation verbs are missing")
	nexusSmokeAssert(text2path("/mob/Admin3/verb/giveTenkaichiAttacks") && text2path("/mob/Admin3/verb/testTenkaichiCombatEffects"), "Tenkaichi attack or audiovisual testing verb is missing")
	nexusSmokeAssert(getTenkaichiWeaponAttackTypes().len == 11 && getTenkaichiUnarmedAttackTypes().len == 15, "Tenkaichi physical attack catalog is incomplete")
	nexusSmokeAssert(getTenkaichiBeamAttackTypes().len == 12 && getTenkaichiSpecialStyleAttackTypes().len == 5, "Tenkaichi special-style catalog is incomplete")
	nexusSmokeAssert(getTenkaichiRockAttackTypes().len == 3, "Tenkaichi rock-technique testing catalog is incomplete")
	var/obj/Attacks/TenkaichiMeleeTechnique/Slice/tenkaichi_slice = new
	var/obj/Attacks/TenkaichiMeleeTechnique/BurningSlash/tenkaichi_combo = new
	var/obj/Attacks/TenkaichiMeleeTechnique/IaiSlash/tenkaichi_iai = new
	var/obj/Attacks/TenkaichiMeleeTechnique/SwordStab/tenkaichi_stab = new
	var/obj/Attacks/TenkaichiMeleeTechnique/MegatonThrow/tenkaichi_throw = new
	var/obj/Attacks/TenkaichiMeleeTechnique/MarchOfFury/tenkaichi_march = new
	var/obj/Attacks/TenkaichiMeleeTechnique/PileDriver/tenkaichi_pile_driver = new
	var/obj/Attacks/TenkaichiMeleeTechnique/UppercutCombo/tenkaichi_uppercut = new
	var/obj/Attacks/TenkaichiMeleeTechnique/KickbackCombo/tenkaichi_kickback = new
	var/obj/Attacks/RoleplayBeam/BusterCannon/tenkaichi_beam = new
	nexusSmokeAssert(tenkaichi_slice.requires_weapon && tenkaichi_slice.hotbar_type == "Melee", "Tenkaichi weapon technique does not enforce equipment")
	nexusSmokeAssert(tenkaichi_slice.icon == 'src/Icons/Effects/CC0/SwordSlash.dmi' && (tenkaichi_slice.getCastSound() in nexus_sword_swing_light_sounds) && (tenkaichi_slice.getImpactSound() in nexus_sword_impact_sounds), "Tenkaichi weapon techniques are missing their animated hotbar icons or CC0 sword audio")
	nexusSmokeAssert(tenkaichi_combo.extra_hits == 2 && tenkaichi_combo.extra_hit_multiplier == 0.45, "Burning Slash is not a multi-hit technique")
	nexusSmokeAssert(tenkaichi_iai.behavior == "iai_dash" && tenkaichi_iai.dash_range == 6, "Iai Slash is not a pass-through line attack")
	nexusSmokeAssert(tenkaichi_stab.line_reach == 2 && tenkaichi_stab.knockback_multiplier == 0, "Sword Stab does not pierce the tile behind its target")
	nexusSmokeAssert(tenkaichi_throw.behavior == "grapple_throw" && tenkaichi_march.behavior == "march", "Tenkaichi grapple or advancing melee behavior is missing")
	nexusSmokeAssert(tenkaichi_pile_driver.icon == 'RTGrappleImpact.dmi' && tenkaichi_throw.icon_state == "2", "Tenkaichi grapple techniques are missing their original effect icons")
	nexusSmokeAssert(tenkaichi_uppercut.icon == 'RTUppercut.dmi' && tenkaichi_kickback.icon == 'RTSweepingKick.dmi', "Tenkaichi combo techniques are missing their original effect icons")
	nexusSmokeAssert(tenkaichi_pile_driver.getImpactSound() == 'BigCrash.ogg' && tenkaichi_kickback.getImpactSound() == 'Strongkick.ogg', "Tenkaichi grapple and kick techniques are missing their adapted impact audio")
	nexusSmokeAssert(tenkaichi_beam.hotbar_type == "Beam" && tenkaichi_beam.damage_factor == 11, "Buster Cannon is not routed as a balanced beam")
	var/obj/Attacks/TenkaichiMeleeTechnique/GuardBreak/tenkaichi_guard_break = new
	var/obj/Attacks/TenkaichiSpecialStyle/WallOfFlame/tenkaichi_flame_wall = new
	var/obj/Attacks/TenkaichiSpecialStyle/ChargedProjectile/DragonNova/tenkaichi_dragon_nova = new
	var/obj/Attacks/TenkaichiSpecialStyle/ChargedProjectile/SkyBreak/tenkaichi_sky_break = new
	var/obj/Attacks/TenkaichiSpecialStyle/ChargedProjectile/EchoingSlash/tenkaichi_echoing_slash = new
	nexusSmokeAssert(tenkaichi_guard_break.breaks_guard && tenkaichi_guard_break.stun_ticks == 6, "Guard Break does not bypass active melee guard")
	nexusSmokeAssert(tenkaichi_flame_wall.field_duration == 150, "Wall of Flame is not a persistent field style")
	nexusSmokeAssert(tenkaichi_dragon_nova.projectile_damage_factor == 12 && tenkaichi_dragon_nova.icon == 'RTDragonNova.dmi', "Dragon Nova is missing its RPT balance or icon")
	nexusSmokeAssert(tenkaichi_sky_break.strength_scaled && tenkaichi_sky_break.requires_weapon && tenkaichi_sky_break.weapon_projectile && tenkaichi_sky_break.icon == 'RTSkyBreak.dmi', "Sky Break is not a weapon-gated physical sword projectile")
	nexusSmokeAssert(tenkaichi_sky_break.impact_effect_icon == 'src/Icons/Effects/CC0/SwordSlash.dmi' && tenkaichi_echoing_slash.weapon_projectile && tenkaichi_echoing_slash.explosion_size == 0, "ported sword waves still use generic blast presentation")
	nexusSmokeAssert(tenkaichi_echoing_slash.icon == 'RTEchoingSlash.dmi' && tenkaichi_echoing_slash.projectile_damage_factor == 7, "Echoing Slash is missing its RPT projectile art or adapted balance")
	var/mob/NexusSmokeTest/skill_examine_owner = new
	var/datum/NexusPlayerMenu/skill_examine_contract = new(skill_examine_owner, "skills")
	var/list/dragon_nova_damage_data = skill_examine_contract.getSkillDamageData(tenkaichi_dragon_nova)
	var/list/iai_damage_data = skill_examine_contract.getSkillDamageData(tenkaichi_iai)
	var/list/echoing_slash_damage_data = skill_examine_contract.getSkillDamageData(tenkaichi_echoing_slash)
	nexusSmokeAssert(dragon_nova_damage_data["factor"] == 24 && dragon_nova_damage_data["model"] == "Ki", "skill examination does not expose Dragon Nova's full direct/splash budget")
	nexusSmokeAssert(iai_damage_data["model"] == "Physical" && findtext(iai_damage_data["requirements"], "Weapon equipped"), "skill examination omits Iai Slash damage model or weapon requirement")
	nexusSmokeAssert(echoing_slash_damage_data["factor"] == 7 && findtext(echoing_slash_damage_data["range"], "direct impact"), "skill examination treats Echoing Slash as an explosive blast")
	del(skill_examine_contract)
	del(skill_examine_owner)
	del(tenkaichi_slice)
	del(tenkaichi_combo)
	del(tenkaichi_iai)
	del(tenkaichi_stab)
	del(tenkaichi_throw)
	del(tenkaichi_march)
	del(tenkaichi_pile_driver)
	del(tenkaichi_uppercut)
	del(tenkaichi_kickback)
	del(tenkaichi_beam)
	del(tenkaichi_guard_break)
	del(tenkaichi_flame_wall)
	del(tenkaichi_dragon_nova)
	del(tenkaichi_sky_break)
	del(tenkaichi_echoing_slash)
	var/turf/attack_movement_origin
	var/turf/attack_movement_destination
	for(var/turf/candidate_origin in world)
		var/turf/candidate_destination = get_step(candidate_origin, EAST)
		if(!candidate_origin.density && candidate_destination && !candidate_destination.density)
			var/blocked_pair = FALSE
			for(var/atom/movable/blocker in candidate_origin) if(blocker.density) blocked_pair = TRUE
			for(var/atom/movable/blocker in candidate_destination) if(blocker.density) blocked_pair = TRUE
			if(!blocked_pair)
				attack_movement_origin = candidate_origin
				attack_movement_destination = candidate_destination
				break
	nexusSmokeAssert(attack_movement_origin && attack_movement_destination, "startup map has no open pair for attack movement tests")
	var/mob/NexusSmokeTest/dash_movement_test = new
	dash_movement_test.SafeTeleport(attack_movement_origin)
	dash_movement_test.dash_attacking = TRUE
	dash_movement_test.attack_forced_movement = TRUE
	nexusSmokeAssert(step(dash_movement_test, EAST) && dash_movement_test.loc == attack_movement_destination, "Dash Attack cannot move while its attack lock is active")
	del(dash_movement_test)
	var/mob/NexusSmokeTest/technique_targeting_test = new
	var/mob/NexusSmokeTest/technique_target = new
	technique_targeting_test.SafeTeleport(attack_movement_origin)
	technique_target.SafeTeleport(attack_movement_destination)
	technique_targeting_test.dir = EAST
	nexusSmokeAssert(technique_targeting_test.getTenkaichiTechniqueTarget(1) == technique_target, "adjacent Tenkaichi combos require manual target selection")
	technique_targeting_test.grabbedObject = technique_target
	technique_target.grabber = technique_targeting_test
	technique_targeting_test.last_melee_attack = -1000
	nexusSmokeAssert(technique_targeting_test.canUseTenkaichiGrappleTechnique(), "a valid grab still blocks Pile Driver and Megaton Throw")
	nexusSmokeAssert(!technique_target.CanMeleeFromOtherCauses() && technique_target.cant_blast(), "a grabbed player can still attack instead of struggling free")
	technique_targeting_test.ReleaseGrab()
	del(technique_targeting_test)
	del(technique_target)
	nexusSmokeAssert(hudPercentage(50, 200) == 25, "HUD percentage calculation is invalid")
	nexusSmokeAssert(hudPercentage(50, 0) == 0, "HUD percentage did not guard a zero maximum")
	nexusSmokeAssert(nexusIsFiniteNumber(50) && !nexusIsFiniteNumber(1.#INF), "finite-number validation is invalid")
	var/mob/NexusSmokeTest/vitals_owner = new
	vitals_owner.icon = 'BaseHumanPale.dmi'
	vitals_owner.Ki = 8000
	vitals_owner.max_ki = 8000
	vitals_owner.willpower = 50
	vitals_owner.max_willpower = 100
	var/obj/NexusHud/VitalsPanel/vitals_panel = new
	vitals_panel.initialize(vitals_owner)
	nexusSmokeAssert(vitals_panel.screen_loc == "LEFT:8,BOTTOM:8", "main vitals HUD is not fully inside the lower-left corner")
	vitals_panel.setScreenPosition(92, 62)
	nexusSmokeAssert(vitals_panel.screen_loc == "LEFT:92,BOTTOM:62" && vitals_owner.nexus_main_vitals_x == 92 && vitals_owner.nexus_main_vitals_y == 62, "main vitals HUD drag positioning is not retained by its owner")
	var/datum/NexusInterfaceSettings/interface_settings_contract = new(vitals_owner)
	nexusSmokeAssert(findtext(interface_settings_contract.buildHtml(), "action=hud_move") && findtext(interface_settings_contract.buildHtml(), "action=hud_set"), "interface settings are missing HUD position controls")
	del(interface_settings_contract)
	var/mob/NexusSmokeTest/chat_contract_owner = new
	chat_contract_owner.nexus_interface_layout = "side_tabs"
	var/datum/NexusChatHud/chat_hud_contract = new(chat_contract_owner)
	var/chat_panel_html = chat_hud_contract.buildHtml()
	nexusSmokeAssert(chat_hud_contract.getVisibleMessageCount() == 36 && findtext(chat_panel_html, "CMD BAR BELOW") && findtext(chat_panel_html, "action=channel&id=all"), "side chat panel is missing paging, channels, or its integrated CMD hint")
	nexusSmokeAssert(findtext(chat_panel_html, ".footer{display:flex") && findtext(chat_panel_html, ".footer .button{flex:1 1 0"), "side chat actions can wrap into vertical rows")
	chat_contract_owner.nexus_interface_layout = "overlay"
	nexusSmokeAssert(chat_hud_contract.getVisibleMessageCount() >= 4, "overlay chat visible message calculation is invalid")
	del(chat_hud_contract)
	del(chat_contract_owner)
	nexusSmokeAssert(vitals_panel.vis_contents.len == 9 && vitals_panel.alpha == 255, "main vitals HUD composition is incomplete")
	var/icon/main_vitals_icon = getVitalsPanelIcon()
	var/icon/main_vitals_bar = getVitalsBarIcon(50, "#46d369")
	var/icon/power_gauge = getPowerGaugeIcon(50, FALSE)
	var/icon/active_modifiers_icon = getActiveModifiersPanelIcon()
	nexusSmokeAssert(vitals_panel.icon, "main vitals HUD did not retain its generated backdrop")
	nexusSmokeAssert(main_vitals_icon.Width() == 296 && main_vitals_icon.Height() == 136, "main vitals HUD has invalid dimensions")
	nexusSmokeAssert(main_vitals_bar.Width() == 168 && main_vitals_bar.Height() == 19, "main vitals bar has invalid dimensions")
	nexusSmokeAssert(power_gauge.Width() == 7 && power_gauge.Height() == 72, "main vitals power gauge has invalid dimensions")
	nexusSmokeAssert(active_modifiers_icon.Width() == 296 && active_modifiers_icon.Height() == 38, "active modifier strip has invalid dimensions")
	nexusSmokeAssert(!text2path("/obj/NexusHud/VitalRow/Power"), "redundant horizontal power bar still exists")
	nexusSmokeAssert(findtext(vitals_panel.willpower_row.detail_text.maptext, "50%") && vitals_panel.willpower_row.pixel_y > vitals_panel.health_row.pixel_y, "Willpower percentage is not rendered above Health")
	nexusSmokeAssert(findtext(vitals_panel.willpower_row.maptext, "WILLPOWER") && findtext(vitals_panel.health_row.maptext, "HEALTH") && findtext(vitals_panel.energy_row.maptext, "ENERGY") && findtext(vitals_panel.stamina_row.maptext, "STAMINA"), "main vitals HUD is missing status labels")
	nexusSmokeAssert(findtext(vitals_panel.energy_row.detail_text.maptext, "(8000) 100%") && vitals_panel.energy_row.detail_alignment == "right", "Energy does not use the (ki) percentage% format")
	nexusSmokeAssert(!findtext(vitals_panel.power_readout.maptext, "<br>"), "power readout still renders duplicate lines")
	nexusSmokeAssert(vitals_panel.active_modifiers_readout.alpha == 0, "active modifier strip is visible without an active buff")
	var/obj/Buff/Focus/hud_focus = new(vitals_owner)
	hud_focus.suffix = "Active"
	vitals_owner.current_buff = hud_focus
	vitals_owner.bp_mult += hud_focus.buff_bp - 1
	var/list/focus_modifier_data = vitals_owner.getNexusActiveHudModifiers()
	var/list/focus_modifiers = focus_modifier_data["modifiers"]
	nexusSmokeAssertNear(focus_modifiers["BP"], 1.18, 0.001, "Focus BP is not represented by the active modifier HUD")
	nexusSmokeAssertNear(focus_modifiers["SPD"], 1.2, 0.001, "Focus speed is not represented by the active modifier HUD")
	nexusSmokeAssertNear(focus_modifiers["REC"], 1.1, 0.001, "Focus recovery is not represented by the active modifier HUD")
	vitals_panel.update(vitals_owner)
	nexusSmokeAssert(vitals_panel.active_modifiers_readout.alpha == 255 && findtext(vitals_panel.active_modifiers_readout.maptext, "Focus") && findtext(vitals_panel.active_modifiers_readout.maptext, "BP 1.18x"), "active modifier strip did not render the live Focus summary")
	vitals_owner.current_buff = null
	hud_focus.suffix = null
	vitals_owner.bp_mult -= hud_focus.buff_bp - 1
	del(hud_focus)
	vitals_owner.ssj = 1
	vitals_owner.ssj_bp_mult = 1.35
	vitals_owner.base_bp = 10000000
	vitals_owner.ismystic = TRUE
	var/list/stacked_modifier_summary = vitals_owner.getNexusActiveHudModifierSummary()
	var/list/stacked_modifier_data = vitals_owner.getNexusActiveHudModifiers()
	var/list/stacked_modifiers = stacked_modifier_data["modifiers"]
	nexusSmokeAssert(findtext(stacked_modifier_summary["title"], "Super Saiyan") && findtext(stacked_modifier_summary["title"], "Mystic"), "stacked transformation and Mystic names are missing from the HUD summary")
	nexusSmokeAssertNear(stacked_modifiers["SPD"], 1.1, 0.001, "Mystic speed is missing from a stacked HUD summary")
	nexusSmokeAssertNear(stacked_modifiers["PWR"], 1.2, 0.001, "Mystic power-up speed is missing from a stacked HUD summary")
	del(vitals_panel)
	del(vitals_owner)
	for(var/beam_type in typesof(/obj/Attacks))
		if(initial(beam_type:hotbar_type) == "Beam")
			nexusSmokeAssert(skill_engine.isBeamSkill(beam_type), "beam skill is not routed through SkillEngine: [beam_type]")
	var/obj/Attacks/Piercer/beam_skill = new
	nexusSmokeAssert(beam_skill.beam_impact_mode == BEAM_IMPACT_EXPLOSIVE, "beam skill did not default to raw damage mode")
	nexusSmokeAssert(!text2path("/obj/Attacks/verb/beamImpactMode"), "obsolete per-skill beam mode verb still exists")
	nexusSmokeAssert(text2path("/mob/verb/kiSettings"), "central Ki Settings verb is missing")
	var/mob/NexusSmokeTest/beam_mode_player = new
	nexusSmokeAssert(beam_mode_player.beam_impact_mode == BEAM_IMPACT_EXPLOSIVE, "player beam mode did not default to raw damage")
	var/obj/Blast/beam_impact_segment = new
	nexusSmokeAssert(beam_impact_segment.getBeamDamageWindow(world.tick_lag) == beam_raw_damage_mod, "raw beam impact does not use immediate damage")
	beam_impact_segment.percent_damage = 10
	nexusSmokeAssert(beam_impact_segment.getExplosiveBeamKnockbackDistance(null) >= 5, "explosive beam impact has no knockback profile")
	beam_impact_segment.beam_impact_mode = BEAM_IMPACT_LOCK
	nexusSmokeAssert(beam_impact_segment.getBeamDamageWindow(world.tick_lag) == world.tick_lag, "beam lock does not retain tick damage")
	var/mob/NexusSmokeTest/beam_impact_target = new
	beam_mode_player.loc = locate(445, 3, 2)
	beam_impact_target.loc = get_step(beam_mode_player, EAST)
	var/obj/Attacks/Beam/streaming_beam = new(beam_mode_player)
	streaming_beam.streaming = 1
	beam_mode_player.beaming = 1
	beam_mode_player.current_beam = streaming_beam
	beam_impact_segment.loc = beam_impact_target.loc
	beam_impact_segment.Owner = beam_mode_player
	beam_impact_segment.from_attack = streaming_beam
	beam_impact_segment.beam_impact_mode = BEAM_IMPACT_EXPLOSIVE
	beam_impact_segment.dir = EAST
	var/obj/Blast/trailing_beam_segment = new(beam_mode_player.loc)
	trailing_beam_segment.Owner = beam_mode_player
	trailing_beam_segment.Beam = 1
	beam_mode_player.my_beam_objs.Add(beam_impact_segment, trailing_beam_segment)
	streaming_beam.beam_objects.Add(beam_impact_segment, trailing_beam_segment)
	beam_impact_segment.showExplosiveBeamImpact(beam_impact_target, force_mob_impact = 1)
	nexusSmokeAssert(beam_impact_target.last_knockbacked > 0 && beam_impact_target.knock_dir == EAST, "raw beam explosion did not knock its target in the beam direction")
	nexusSmokeAssert(!streaming_beam.streaming && !beam_mode_player.beaming, "raw player impact did not stop the streaming beam")
	nexusSmokeAssert(!streaming_beam.beam_objects.len && !beam_mode_player.my_beam_objs.len, "raw player impact did not clear beam segment lists")
	nexusSmokeAssert(!beam_impact_segment.z && !trailing_beam_segment.z, "raw player impact left beam segments on the map")
	var/list/explosion_light_profile = getNexusExplosionLightProfile(5)
	nexusSmokeAssert(explosion_light_profile["size"] >= 8 && explosion_light_profile["alpha"] == 255 && explosion_light_profile["variation"] == "blast", "large explosions do not emit a strong flickering light")
	nexusSmokeAssert(text2path("/obj/NexusLighting/ExplosionPulse"), "explosions are missing their transient light actor")
	var/obj/Attacks/Blast/nonbeam_skill = new
	var/obj/Blast/named_impact_projectile = new
	named_impact_projectile.from_attack = nonbeam_skill
	named_impact_projectile.percent_damage = 4
	nexusSmokeAssert(named_impact_projectile.getNexusProjectileImpactIcon() == 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTImpact.dmi', "named damaging projectiles without custom art receive no shared impact VFX")
	del(named_impact_projectile)
	del(beam_impact_target)
	del(beam_mode_player)
	del(nonbeam_skill)
	del(beam_skill)
	var/obj/RockThrow/rock_throw_skill = new
	var/obj/RockSlide/rock_slide_skill = new
	var/obj/RockTomb/rock_tomb_skill = new
	nexusSmokeAssert(rock_throw_skill.icon == 'RTRockThrow.dmi' && GetWidth(rock_throw_skill.icon) == 64 && rock_slide_skill.icon == 'RisingRocks.dmi' && rock_tomb_skill.icon == 'RTRockTomb.dmi' && GetWidth(rock_tomb_skill.icon) == 62, "rock skills are missing their differentiated technique icons")
	nexusSmokeAssert(rock_throw_skill.hotbar_type == "Blast" && rock_slide_skill.hotbar_type == "Blast" && rock_tomb_skill.hotbar_type == "Blast", "rock skills use an unsupported hotbar category")
	nexusSmokeAssert(text2path("/obj/Effect/RockSkillProjectile"), "rock attacks are missing their visible projectile actor")
	nexusSmokeAssert(text2path("/obj/Effect/RockSkillDebris") && nexus_rock_launch_sounds.len == 2 && nexus_rock_impact_sounds.len == 3 && nexus_rock_heavy_impact_sounds.len == 2 && nexus_rock_break_sounds.len == 3, "rock attacks are missing their CC0 audio or debris profiles")
	nexusSmokeAssert(text2path("/obj/Effect/TenkaichiTechniqueText"), "Tenkaichi techniques are missing their floating combat announcement actor")
	var/icon/critical_spark_icon = getNexusCriticalSparkIcon()
	nexusSmokeAssert(text2path("/obj/Effect/NexusCriticalCore") && text2path("/obj/Effect/NexusCriticalSpark") && text2path("/obj/Effect/NexusCriticalText"), "critical hits are missing their Black Flash effect actors")
	nexusSmokeAssert(critical_spark_icon && GetWidth(critical_spark_icon) == 96 && GetHeight(critical_spark_icon) == 96 && nexus_critical_impact_sounds.len == 2, "critical hits are missing their generated spark or layered audio profile")
	var/obj/Attacks/TenkaichiMeleeTechnique/Slice/sword_slice_skill = new
	nexusSmokeAssert(sword_slice_skill.icon == 'src/Icons/Effects/CC0/SwordSlash.dmi' && sword_slice_skill.icon_state == "slash" && GetWidth(sword_slice_skill.icon) == 64 && GetHeight(sword_slice_skill.icon) == 47, "weapon skills are missing the animated CC0 slash icon")
	nexusSmokeAssert(nexus_sword_swing_light_sounds.len == 2 && nexus_sword_swing_heavy_sounds.len == 2 && nexus_sword_impact_sounds.len == 6 && (sword_slice_skill.getCastSound() in nexus_sword_swing_light_sounds) && (sword_slice_skill.getImpactSound() in nexus_sword_impact_sounds), "weapon skills are missing their CC0 swing and impact profiles")
	del(rock_throw_skill)
	del(rock_slide_skill)
	del(rock_tomb_skill)
	del(sword_slice_skill)
	var/obj/Lunge/lunge_action = new
	nexusSmokeAssert(lunge_action.can_hotbar && /obj/Lunge/verb/lunge in lunge_action.verbs, "Lunge is not available as a standalone action")
	nexusSmokeAssert(text2path("/mob/Admin2/verb/orderCombatDummyLunge") && text2path("/obj/NexusHud/DragonRushPrompt"), "Dragon Rush dummy control or direction prompt is missing")
	nexusSmokeAssert(text2path("/obj/NexusHud/BeamClashPrompt") && text2path("/obj/BeamClashMarker"), "Beam Clash prompt or center marker is missing")
	del(lunge_action)
	nexusSmokeAssert(wolf_fang_hit_damage_mult == 1 && wolf_fang_knockback_distance == 3, "Wolf Fang Fist combo tuning is invalid")
	nexusSmokeAssert(hundred_crack_min_hits == 24 && hundred_crack_hit_damage_mult == 0.25, "Hundred Crack Fist remains an execution instead of a damage combo")
	nexusSmokeAssert(base_melee_damage == 2.5 && combat_damage_bp_exponent == 1 && combat_damage_stat_exponent == 0.85, "central combat damage constants are invalid")
	nexusSmokeAssert(skill_blast_total_factor == 4 && skill_big_bang_damage_factor == 22 && skill_charge_damage_factor == 4 && skill_cyber_charge_damage_factor == 2.5, "core projectile factors diverged from the balance workbook")
	nexusSmokeAssert(skill_makosen_damage_factor == 0.4 && skill_makosen_total_factor == 8 && skill_scatter_shot_damage_factor == 0.3 && skill_scatter_shot_total_factor == 18, "barrage factors diverged from the balance workbook")
	nexusSmokeAssert(skill_attack_barrier_damage_factor == 0.2 && skill_shockwave_damage_factor == 0.5 && skill_explosion_damage_factor == 3, "AoE factors diverged from the balance workbook")
	nexusSmokeAssert(skill_dash_attack_min_factor == 2 && skill_dash_attack_max_factor == 8 && skill_dash_attack_step_factor == 0.25, "Dash Attack factor curve diverged from the balance workbook")
	nexusSmokeAssert(skill_dropkick_opening_factor == 5 && skill_dropkick_finisher_factor == 3 && skill_sokidan_damage_factor == 3.5 && skill_sokidan_total_factor == 7 && skill_kienzan_damage_factor == 6, "special skill factors diverged from the balance workbook")
	nexusSmokeAssert(beam_skill_cooldown_ticks == 30 && beam_clash_winner_damage_mult == 1.35 && beam_clash_input_mult == 1.15, "beam cooldown or clash damage tuning is invalid")
	nexusSmokeAssert(calculateScaledCombatDamage(10, 100, 100, 100, 100) == 10, "equal-stat central damage did not preserve its factor")
	nexusSmokeAssert(calculateScaledCombatDamage(3, 13000, 200, 100, 100) == 195, "a 65x BP advantage cannot make a standard beam immediately decisive")
	nexusSmokeAssert(!calculateScaledCombatDamage(10, 100, 100, 0, 100), "zero offensive stat still caused damage")
	var/superior_stat_damage = calculateScaledCombatDamage(10, 100, 100, 200, 100)
	var/inferior_stat_damage = calculateScaledCombatDamage(10, 100, 100, 100, 200)
	nexusSmokeAssert(superior_stat_damage > 12 && superior_stat_damage < 13, "superior stat scaling escaped its expected bound")
	nexusSmokeAssert(inferior_stat_damage > 7 && inferior_stat_damage < 7.2, "defensive stat scaling escaped its expected bound")
	var/datum/CombatDamageBudget/test_damage_budget = new(7)
	var/mob/NexusSmokeTest/budget_target = new
	nexusSmokeAssert(test_damage_budget.reserveFactor(budget_target, 3.5) == 3.5 && test_damage_budget.reserveFactor(budget_target, 5) == 3.5, "per-target damage budget exceeded its cap")
	nexusSmokeAssert(!createBeamDamageBudget(BEAM_IMPACT_LOCK, 7), "Beam Lock still has a cumulative damage threshold")
	var/datum/CombatDamageBudget/explosive_beam_budget = createBeamDamageBudget(BEAM_IMPACT_EXPLOSIVE, 7)
	nexusSmokeAssert(explosive_beam_budget && explosive_beam_budget.max_factor_per_target == 7, "explosive beams lost their per-target damage budget")
	del(budget_target)
	var/mob/NexusSmokeTest/projectile_owner = new
	projectile_owner.BP = 100
	projectile_owner.Pow = 100
	projectile_owner.Off = 100
	projectile_owner.Spd = 100
	projectile_owner.BPpcnt = 100
	var/obj/Blast/big_bang_projectile = new
	big_bang_projectile.setStats(projectile_owner, Percent = 22, Explosion = 4, explosion_percent = 22, max_damage_factor = 44)
	nexusSmokeAssert(big_bang_projectile.percent_damage == 22 && big_bang_projectile.explosion_damage_factor == 22 && big_bang_projectile.damage_budget.max_factor_per_target == 44, "Big Bang direct/splash budget is invalid")
	var/obj/Attacks/Final_Flash/final_flash_skill = new
	var/obj/Attacks/Noob_Ray/noob_ray_skill = new
	nexusSmokeAssert(final_flash_skill.damage_factor == 12 && noob_ray_skill.damage_factor == 52, "beam damage factors are invalid")
	var/list/expected_beam_factors = list(
		/obj/Attacks/Noob_Ray = 52,
		/obj/Attacks/Laser_Beam = 4,
		/obj/Attacks/Beam = 3,
		/obj/Attacks/Ray = 3,
		/obj/Attacks/Piercer = 5,
		/obj/Attacks/Kamehameha = 8,
		/obj/Attacks/Dodompa = 5,
		/obj/Attacks/Final_Flash = 12,
		/obj/Attacks/Garlic_Gun = 7,
		/obj/Attacks/Masenko = 6)
	for(var/beam_type in expected_beam_factors)
		nexusSmokeAssert(initial(beam_type:damage_factor) == expected_beam_factors[beam_type], "beam factor diverged from the balance workbook: [beam_type]")
	var/obj/Attacks/Genki_Dama/omega_bomb_balance = new
	var/obj/Attacks/Genki_Dama/Death_Ball/death_ball_balance = new
	var/obj/Attacks/Genki_Dama/Supernova/supernova_balance = new
	nexusSmokeAssert(omega_bomb_balance.sb_initial_dmg == 4 && omega_bomb_balance.sb_max_dmg == 15, "Omega Bomb charge curve diverged from the balance workbook")
	nexusSmokeAssert(death_ball_balance.sb_initial_dmg == 2.5 && death_ball_balance.sb_max_dmg == 10, "Death Ball charge curve diverged from the balance workbook")
	nexusSmokeAssert(supernova_balance.sb_initial_dmg == 2 && supernova_balance.sb_max_dmg == 5, "Supernova charge curve diverged from the balance workbook")
	del(big_bang_projectile)
	del(final_flash_skill)
	del(noob_ray_skill)
	del(omega_bomb_balance)
	del(death_ball_balance)
	del(supernova_balance)
	nexusSmokeAssert(ki_projectile_step_delay == 0.5, "Ki projectile cadence is not normalized for 60 FPS")
	var/obj/Attacks/Sokidan/sokidan_skill = new
	var/datum/SkillDefinition/sokidan_definition = skill_engine.getDefinitionForObj(sokidan_skill)
	nexusSmokeAssert(sokidan_definition && sokidan_definition.control_delay == ki_projectile_step_delay, "Sokidan does not use the normalized Ki projectile cadence")
	var/datum/SkillController/GuidedBlast/guided_controller = skill_controller_registry.get(SKILL_CONTROLLER_GUIDED_BLAST)
	projectile_owner.dir = NORTH
	projectile_owner.last_direction_pressed = EAST
	nexusSmokeAssert(guided_controller && guided_controller.getControlDirection(projectile_owner) == EAST, "guided blasts are not checking and moving toward the same direction")
	projectile_owner.last_direction_pressed = 0
	nexusSmokeAssert(guided_controller.getControlDirection(projectile_owner) == NORTH, "guided blasts have no facing-direction fallback")
	var/obj/Blast/kienzan_projectile = new
	kienzan_projectile.slice_attack = 1
	kienzan_projectile.Piercer = 1
	kienzan_projectile.setStats(projectile_owner, Percent = skill_kienzan_damage_factor, Off_Mult = 15, owner_immunity = 1)
	nexusSmokeAssert(!kienzan_projectile.damage_budget, "Kienzan still exhausts a one-hit damage budget")
	kienzan_projectile.applyPiercingDamageDecay()
	nexusSmokeAssert(kienzan_projectile.percent_damage == skill_kienzan_damage_factor * skill_kienzan_pierce_decay, "Kienzan does not lose damage after piercing a target")
	del(kienzan_projectile)
	del(sokidan_skill)
	del(projectile_owner)
	var/mob/NexusSmokeTest/rp_combat_test = new
	rp_combat_test.Race = "Human"
	rp_combat_test.max_ki = 1000
	nexusSmokeAssert(rp_combat_test.instantTransmissionWarpCost() == 2.5, "Instant Transmission directional Energy cost is invalid")
	rp_combat_test.Health = 100
	rp_combat_test.anger = 100
	rp_combat_test.max_anger = 200
	rp_combat_test.TakeDamage(25)
	nexusSmokeAssertNear(rp_combat_test.Health, 75, 0.01, "damage application changed during gradual anger buildup")
	nexusSmokeAssertNear(rp_combat_test.anger, 125, 0.01, "anger does not build proportionally as health is lost")
	rp_combat_test.setRPMode(TRUE, announce = FALSE)
	nexusSmokeAssert(!rp_combat_test.CanInputMove() && rp_combat_test.rp_mode_input_lock, "RP Mode did not fully lock movement input")
	var/mob/NexusSmokeTest/rp_grabber_test = new
	nexusSmokeAssert(!rp_grabber_test.canGrabMovable(rp_combat_test) && !rp_grabber_test.CanExtendoGrab(rp_combat_test), "RP Mode can still be targeted by a normal or tail-extending grab")
	rp_combat_test.TakeDamage(25)
	nexusSmokeAssertNear(rp_combat_test.Health, 75, 0.01, "RP Mode did not protect its user from damage")
	nexusSmokeAssert(rp_combat_test.cant_blast(), "RP Mode still allows energy attacks")
	rp_combat_test.ApplyStun(time = 20, no_immunity = TRUE, stun_power = 2)
	nexusSmokeAssert(!rp_combat_test.stun_level, "RP Mode still allows combat stuns")
	rp_combat_test.setRPMode(FALSE, announce = FALSE)
	nexusSmokeAssert(!rp_combat_test.rp_mode_input_lock && !rp_combat_test.input_disabled, "leaving RP Mode did not release its movement lock")
	nexusSmokeAssert(!rp_combat_test.has_entered_combat(victim = rp_combat_test), "a never-attacked player is incorrectly considered in combat")
	rp_combat_test.Health = 50
	rp_combat_test.willpower = 100
	rp_combat_test.last_attacked_time = world.time
	rp_combat_test.applyRegenerationHealth(20)
	nexusSmokeAssert(rp_combat_test.Health == 70 && rp_combat_test.willpower == 100, "casual combat regeneration consumed Willpower")
	rp_combat_test.enterLethalCombat()
	rp_combat_test.applyRegenerationHealth(10, drains_willpower = FALSE)
	nexusSmokeAssert(rp_combat_test.Health == 80 && rp_combat_test.willpower == 100, "auto-repair incorrectly consumes Willpower")
	rp_combat_test.applyRegenerationHealth(10)
	nexusSmokeAssert(rp_combat_test.Health == 90 && rp_combat_test.willpower == 97.5, "lethal combat regeneration does not consume Willpower")
	rp_combat_test.SetSparringMode(LETHAL_COMBAT, FALSE)
	nexusSmokeAssert(rp_combat_test.sparring_mode == LETHAL_COMBAT && rp_combat_test.Fatal, "lethal intent did not enable fatal damage")
	rp_combat_test.SetSparringMode(CASUAL_COMBAT, FALSE)
	nexusSmokeAssert(rp_combat_test.sparring_mode == CASUAL_COMBAT && !rp_combat_test.Fatal, "casual intent did not disable fatal damage")
	rp_combat_test.willpower = 100
	rp_combat_test.enterLethalCombat()
	rp_combat_test.drainWillpower(rp_combat_test.getLethalKoDrain(), "Smoke test", announce = FALSE)
	nexusSmokeAssert(rp_combat_test.willpower == 70 && rp_combat_test.isInLethalCombat(), "lethal combat did not drain and track Willpower")
	rp_combat_test.KO = TRUE
	rp_combat_test.rp_mode = TRUE
	rp_combat_test.ko_recovery_ready_at = world.time
	nexusSmokeAssert(rp_combat_test.willpowerGetUp(), "Willpower could not raise a ready lethal-KO player")
	nexusSmokeAssert(!rp_combat_test.KO && !rp_combat_test.rp_mode && rp_combat_test.Health == 70, "Willpower get-up restored an invalid combat state")
	var/mob/NexusSmokeTest/willpower_break_test = new
	willpower_break_test.willpower = 5
	willpower_break_test.drainWillpower(5, "Smoke test", announce = FALSE)
	nexusSmokeAssert(willpower_break_test.KO && willpower_break_test.rp_mode && willpower_break_test.ko_is_lethal, "zero Willpower entered RP Mode without causing a knockout")
	del(willpower_break_test)
	del(rp_grabber_test)
	var/mob/NexusSmokeTest/milestone_test = new
	milestone_test.Age = 20
	milestone_test.syncMilestoneProgression(silent = TRUE)
	nexusSmokeAssert(milestone_test.milestone_points == MILESTONE_STARTING_POINTS, "legacy milestone initialization did not grant its starter budget")
	nexusSmokeAssert(milestone_test.purchaseMilestone("iron_will") && milestone_test.getMilestoneRank("iron_will") == 1, "milestone purchase did not persist its rank")
	nexusSmokeAssert(milestone_test.getMaxWillpower() == 110, "Iron Will did not raise maximum Willpower")
	milestone_test.milestone_points = 20
	nexusSmokeAssert(milestone_test.purchaseMilestone("ub_godspeed") && (locate(/obj/Buff/Ultimate/Godspeed) in milestone_test), "Ultimate Buff milestone did not grant Godspeed")
	nexusSmokeAssert(!milestone_test.purchaseMilestone("ub_high_tension"), "a character purchased more than one Ultimate Buff")
	milestone_test.milestone_last_year = floor(Year) - 1
	milestone_test.syncMilestoneProgression(silent = TRUE)
	nexusSmokeAssert(milestone_test.total_milestone_points == MILESTONE_STARTING_POINTS + 1, "yearly Milestone Point progression did not advance")
	initializeForgedEquipmentCatalogs()
	nexusSmokeAssert(forged_material_catalog.len == 7 && forged_material_catalog["masterwork"] && forged_material_catalog["auracite"], "Tenkaichi material catalog is incomplete")
	nexusSmokeAssert(forged_weapon_style_catalog.len == 14 && forged_weapon_style_catalog["hammer"] && forged_weapon_style_catalog["mage_staff"], "Tenkaichi weapon catalog is incomplete")
	nexusSmokeAssert(forged_armor_style_catalog.len == 13 && forged_armor_style_catalog["bardock"], "Tenkaichi armor catalog is incomplete")
	var/mob/NexusSmokeTest/profession_test = new
	profession_test.gainProfessionExperience("Mining", getProfessionExperienceForLevel(6), "Smoke test")
	nexusSmokeAssert(profession_test.mining_level == 6, "Mining experience did not advance profession levels")
	profession_test.milestones_owned["mining_expert"] = 1
	nexusSmokeAssertNear(profession_test.getMiningYieldMultiplier(), 1.65, 0.001, "Mining Expert did not increase mining yield")
	var/obj/WorldOreDeposit/ore_deposit_test = new
	ore_deposit_test.configureOre(/obj/items/Ore/Auracite)
	nexusSmokeAssert(ore_deposit_test.required_mining_level == 30 && ore_deposit_test.ore_type == /obj/items/Ore/Auracite && ore_deposit_test.icon == 'RTAuraciteOre.dmi', "world Auracite deposits are not configured or level-gated")
	del(ore_deposit_test)
	profession_test.milestones_owned["master_blacksmith"] = 1
	var/obj/items/Sword/Forged/smoke_sword = new(profession_test)
	profession_test.applyMasterBlacksmithQuality(smoke_sword)
	nexusSmokeAssertNear(smoke_sword.Damage, 1.26, 0.001, "Master Blacksmith did not improve forged equipment")
	var/obj/items/Sword/Forged/rebellion_skin_test = new(profession_test)
	rebellion_skin_test.forged_style_id = "rebellion"
	rebellion_skin_test.refreshForgedWeapon()
	nexusSmokeAssert(rebellion_skin_test.name == "Copper Sword" && rebellion_skin_test.icon == 'ItemSword1.dmi' && rebellion_skin_test.forged_attack_bp_bonus == 0.12, "Rebellion is not a cosmetic skin on a material-named weapon")
	var/obj/items/Sword/Forged/mythril_weapon_test = new(profession_test)
	mythril_weapon_test.forged_material_id = "mythril"
	mythril_weapon_test.forged_style_id = "rebellion"
	mythril_weapon_test.refreshForgedWeapon()
	nexusSmokeAssert(mythril_weapon_test.name == "Mythril Sword" && mythril_weapon_test.forged_attack_bp_bonus == 0.32 && mythril_weapon_test.Damage == 1.52, "Mythril weapon modules did not determine the forged weapon statistics")
	var/obj/items/Armor/Forged/mythril_armor_test = new(profession_test)
	mythril_armor_test.forged_material_id = "mythril"
	mythril_armor_test.forged_style_id = "bardock"
	mythril_armor_test.refreshForgedArmor()
	nexusSmokeAssert(mythril_armor_test.name == "Mythril Armor" && mythril_armor_test.heaviness == 1.04 && mythril_armor_test.forged_defense_bp_bonus == 0.2, "Mythril armor did not retain its lightweight defensive module")
	profession_test.BP = 1000
	mythril_weapon_test.suffix = "Equipped"
	profession_test.equipped_sword = mythril_weapon_test
	nexusSmokeAssertNear(profession_test.getForgedWeaponAttackBP(), 1320, 0.001, "forged weapon BP was not added to melee attack power")
	mythril_armor_test.suffix = "Equipped"
	profession_test.armor_obj = mythril_armor_test
	nexusSmokeAssertNear(profession_test.getForgedArmorEnduranceBP(), 1200, 0.001, "forged armor BP was not added to endurance defense")
	var/list/copper_upgrades = getForgedMaterialUpgradeOptions("copper")
	var/list/bronze_upgrades = getForgedMaterialUpgradeOptions("bronze")
	nexusSmokeAssert(copper_upgrades.len == 1 && bronze_upgrades.len == 2, "Tenkaichi material upgrade paths are incomplete")
	initializeNexusAdminActions()
	nexusSmokeAssert(nexus_admin_action_catalog.len >= 20 && nexus_admin_action_catalog["give_item"] && nexus_admin_action_catalog["reward"] && nexus_admin_action_catalog["legacy_command"], "Nexus Admin Panel command catalog is incomplete")
	nexusSmokeAssert(/mob/AdminEssentials/verb/managePlayer in typesof(/mob/AdminEssentials/verb), "contextual Manage Player command is missing")
	var/mob/NexusSmokeTest/admin_verb_test = new
	admin_verb_test.grantAdminVerbsForLevel(4)
	nexusSmokeAssert((/mob/Admin1/verb/teleport in admin_verb_test.verbs) && (/mob/Admin2/verb/giveItem in admin_verb_test.verbs) && (/mob/Admin3/verb/edit in admin_verb_test.verbs) && (/mob/Admin4/verb/serverControlPanel in admin_verb_test.verbs), "legacy admin verbs are not retained cumulatively for CMD and the Admin tab")
	del(admin_verb_test)
	var/list/server_setting_categories = getNexusServerSettingCategories()
	nexusSmokeAssert(server_setting_categories.len == 6 && server_setting_categories["Progression"] == /upForm/admin_gains && server_setting_categories["Science"] == /upForm/admin_science, "HUD Server Panel categories are incomplete")
	var/upForm/headless_server_settings = new /upForm/admin_gains(null, profession_test, list(), TRUE)
	var/list/headless_progression_settings = headless_server_settings.form_vars["admin"]
	nexusSmokeAssert(headless_server_settings.headless_mode && islist(headless_progression_settings) && headless_progression_settings.len >= 30, "HUD Server Panel could not load headless legacy setting bindings")
	del(headless_server_settings)
	var/list/inspector_list_test = list(1000, list("nested"), "mode" = "test")
	nexusSmokeAssert(findtext(getNexusAdminVariableDisplay(inspector_list_test), "3 entries"), "Admin Inspector could not preview mixed list values")
	nexusSmokeAssert(!profession_test.canAccessTechnology(profession_test) && !profession_test.canAccessTechnology(profession_test.loc), "Technology access accepted a non-object click target")
	nexusSmokeAssert(!profession_test.isTechnologyReferenceClick(smoke_sword), "An inventory item was intercepted as a Technology catalog reference")
	profession_test.player_tech_level = 1
	smoke_sword.referenceObject = TRUE
	nexusSmokeAssert(profession_test.isTechnologyReferenceClick(smoke_sword), "A Technology catalog reference did not receive its specialized click handling")
	smoke_sword.referenceObject = FALSE
	var/character_sheet_html = profession_test.buildCharacterSheetHtml("portrait.png")
	nexusSmokeAssert(findtext(character_sheet_html, "Detailed DU assessment") && findtext(character_sheet_html, "Mining") && findtext(character_sheet_html, "Milestones"), "detailed Character sheet is incomplete")
	del(profession_test)
	var/mob/NexusSmokeTest/technology_progression_test = new
	technology_progression_test.Knowledge = 701
	technology_progression_test.syncTechnologyProgression(silent = TRUE)
	nexusSmokeAssert(technology_progression_test.player_tech_level == 5, "Knowledge migration did not derive Technology Level 5")
	nexusSmokeAssert(technology_progression_test.getTechnologyPathSlots() == 1, "Technology Level 5 did not award a specialization slot")
	var/knowledge_before_magic = technology_progression_test.Knowledge
	technology_progression_test.magic_experience = magic_level_thresholds[magic_level_thresholds.len]
	technology_progression_test.syncMagicProgression(silent = TRUE)
	nexusSmokeAssert(technology_progression_test.magic_level == magic_level_thresholds.len && magic_research_catalog.len == 9, "Magic research did not reach or register its complete tree")
	nexusSmokeAssert((locate(/obj/Attacks/Explosion) in technology_progression_test) && technology_progression_test.Knowledge == knowledge_before_magic, "Magic progression failed to grant its capstone or modified Knowledge")
	del(technology_progression_test)
	del(milestone_test)
	del(rp_combat_test)
	var/list/zanzoken_verbs = list(\
		/obj/Zanzoken/verb/zanzokenNorth,\
		/obj/Zanzoken/verb/zanzokenNortheast,\
		/obj/Zanzoken/verb/zanzokenEast,\
		/obj/Zanzoken/verb/zanzokenSoutheast,\
		/obj/Zanzoken/verb/zanzokenSouth,\
		/obj/Zanzoken/verb/zanzokenSouthwest,\
		/obj/Zanzoken/verb/zanzokenWest,\
		/obj/Zanzoken/verb/zanzokenNorthwest)
	nexusSmokeAssert(zanzoken_verbs.len == 8, "Zanzoken does not expose all eight directional verbs")
	var/mob/NexusSmokeTest/warp_player = new
	warp_player.BP = 100
	warp_player.Pow = 100
	var/obj/Blast/owner_immune_blast = new
	owner_immune_blast.Owner = warp_player
	owner_immune_blast.owner_immune = 1
	owner_immune_blast.deflected = 1
	owner_immune_blast.projectile_creation_time = world.time - 100
	nexusSmokeAssert(owner_immune_blast.BlastMobCross(warp_player) == 1 && warp_player.Health == initial(warp_player.Health), "guided blast owner immunity failed after reflection")
	del(owner_immune_blast)
	nexusSmokeAssert(warp_player.armStretchRangeTiles(500) == 16, "stretchy-arm pixel range is not converted to tiles")
	nexusSmokeAssert(tapwarp_stam_drain == 5, "Flash Step and directional Zanzoken no longer share their stamina cost")
	for(var/warp_offset in 0 to 6)
		new /turf/NexusSmokeTest(locate(445 - warp_offset, 3, 2))
	var/turf/warp_start = locate(445, 3, 2)
	nexusSmokeAssert(warp_start, "directional Zanzoken smoke test turf is missing")
	warp_player.loc = warp_start
	initializeNexusHotkeyActionRegistry()
	nexusSmokeAssert(nexus_hotkey_action_registry.len == 8, "Zanzoken hotkey action registry is incomplete")
	var/datum/NexusHotkeyAction/zanzoken_action = getNexusHotkeyAction("zanzoken_north")
	nexusSmokeAssert(!warp_player.hasZanzokenSkill() && !zanzoken_action.isAvailable(warp_player), "Zanzoken action is available without its skill")
	var/datum/NexusHotkeyEditor/empty_hotkey_editor = new(warp_player)
	var/empty_hotkey_html = warp_player.buildNexusHotkeyEditorHtml(empty_hotkey_editor)
	nexusSmokeAssert(!findtext(empty_hotkey_html, "Zanzoken: North"), "hotkey editor lists Zanzoken without its skill")
	nexusSmokeAssert(findtext(empty_hotkey_html, "XKB keyboard layout") && findtext(empty_hotkey_html, "us(dvorak)") && findtext(empty_hotkey_html, "double tap"), "hotkey editor is missing XKB layouts or double-tap controls")
	nexusSmokeAssert(findtext(empty_hotkey_html, "class='navigation'") && findtext(empty_hotkey_html, "&uarr;") && findtext(empty_hotkey_html, "page_up") && findtext(empty_hotkey_html, "min-width:1380px"), "hotkey editor is missing its full-size navigation and arrow-key block")
	var/obj/Zanzoken/zanzoken_skill = new(warp_player)
	nexusSmokeAssert(warp_player.getZanzokenSkill() == zanzoken_skill && zanzoken_action.isAvailable(warp_player), "owned Zanzoken was not activated")
	nexusSmokeAssert(/obj/Zanzoken/verb/flashStep in zanzoken_skill.verbs, "Flash Step is not exposed by the learnable Zanzoken skill")
	for(var/zanzoken_verb in zanzoken_verbs)
		nexusSmokeAssert(zanzoken_verb in zanzoken_skill.verbs, "owned Zanzoken is missing a directional verb")
	warp_player.nexus_hotkey_bindings["CTRL+Numpad7"] = list("kind" = "action", "action id" = "zanzoken_north")
	nexusSmokeAssert(warp_player.resolveNexusHotkeyBinding("CTRL+Numpad7") == zanzoken_action, "Zanzoken directional action could not be bound")
	nexusSmokeAssert(canonicalNexusHotkey("Numpad7", TRUE, TRUE, TRUE) == "CTRL+SHIFT+ALT+Numpad7", "modifier or numpad hotkey canonicalization is invalid")
	nexusSmokeAssert(canonicalNexusHotkey("Space", tap_count = 2) == "DOUBLE:Space" && getNexusHotkeyBase("DOUBLE:CTRL+Space") == "Space", "double-tap hotkey canonicalization is invalid")
	nexusSmokeAssert(canonicalNexusHotkey("North") == "North" && getNexusUnixHotkeyName("North") == "up", "arrow keys are not valid Unix/XKB hotkeys")
	nexusSmokeAssert(getNexusUnixHotkeyName("DOUBLE:Space") == "space + space" && getNexusUnixHotkeyName("CTRL+Numpad1") == "ctrl_l + kp_1", "Unix/XKB hotkey labels are invalid")
	nexusSmokeAssert(normalizeNexusKeyboardLayout("FR") == "fr" && normalizeNexusKeyboardLayout("unsupported") == "us", "XKB keyboard layout normalization is invalid")
	var/list/french_layout_rows = getNexusKeyboardLayoutRows("fr")
	var/list/french_layout_first_row = french_layout_rows[1]
	nexusSmokeAssert(french_layout_first_row[1] == "A" && french_layout_first_row[2] == "Z", "French XKB layout does not expose an AZERTY row")
	var/obj/Manual_Attack/manual_attack_action = new(warp_player)
	manual_attack_action.hotbar_id = "nexus-smoke-action"
	var/list/manual_binding = list("kind" = "object", "object id" = manual_attack_action.hotbar_id, "object type" = manual_attack_action.type, "display name" = "Manual Attack")
	warp_player.nexus_hotkey_bindings["ALT+F3"] = manual_binding
	warp_player.nexus_hotkey_bindings["Numpad1"] = manual_binding.Copy()
	warp_player.nexus_hotkey_bindings["Space"] = manual_binding.Copy()
	var/obj/Lunge/double_tap_lunge_action = new(warp_player)
	double_tap_lunge_action.hotbar_id = "nexus-smoke-double-lunge"
	warp_player.nexus_hotkey_bindings["DOUBLE:Space"] = list("kind" = "object", "object id" = double_tap_lunge_action.hotbar_id, "object type" = double_tap_lunge_action.type, "display name" = "Lunge")
	nexusSmokeAssert(warp_player.resolveNexusHotkeyBinding("ALT+F3") == manual_attack_action, "object hotkey action did not resolve")
	nexusSmokeAssert(warp_player.resolveNexusHotkeyBinding("Numpad1") == manual_attack_action, "one action could not be assigned to multiple keys")
	var/first_space_binding = warp_player.getNexusHotkeyBindingIdForPress("Space", FALSE, 100)
	var/second_space_binding = warp_player.getNexusHotkeyBindingIdForPress("Space", FALSE, 103)
	nexusSmokeAssert(first_space_binding == "Space" && second_space_binding == "DOUBLE:Space", "single and double Space bindings are not dispatched independently")
	nexusSmokeAssert(warp_player.resolveNexusHotkeyBinding(first_space_binding) == manual_attack_action && warp_player.resolveNexusHotkeyBinding(second_space_binding) == double_tap_lunge_action, "Space and Space + Space do not resolve to their configured actions")
	nexusSmokeAssert(warp_player.getNexusHotkeyBindingIdForPress("Space", TRUE, 104) == "Space", "held-key repetition incorrectly triggered a double-tap action")
	del(zanzoken_skill)
	nexusSmokeAssert(!warp_player.hasZanzokenSkill() && !warp_player.resolveNexusHotkeyBinding("CTRL+Numpad7"), "Zanzoken binding remained active after losing the skill")
	del(manual_attack_action)
	del(double_tap_lunge_action)
	del(empty_hotkey_editor)
	var/turf/expected_warp_turf = locate(440, 3, 2)
	nexusSmokeAssert(warp_player.TapWarpToDir(WEST), "directional Zanzoken failed on a valid path")
	nexusSmokeAssert(warp_player.loc == expected_warp_turf && get_dist(warp_start, warp_player) == 5, "directional Zanzoken exceeded its five-tile limit")
	del(warp_player)
	var/mob/CombatDummy/combat_dummy = new
	combat_dummy.Health = 100
	combat_dummy.updateOverheadHealthHud()
	nexusSmokeAssert(overheadHealthColor(100) == "#46d369", "full overhead health is not green")
	combat_dummy.Health = 60
	combat_dummy.updateOverheadHealthHud()
	nexusSmokeAssert(overheadHealthColor(60) == "#f2c94c", "60 percent overhead health is not yellow")
	combat_dummy.Health = 49
	combat_dummy.updateOverheadHealthHud()
	nexusSmokeAssert(overheadHealthColor(49) == "#ef4758", "low overhead health is not red")
	var/icon/overhead_icon = getOverheadHealthIcon(49)
	var/icon/overhead_energy_icon = getOverheadVitalIcon(50, "#37cfff")
	var/icon/overhead_willpower_icon = getOverheadVitalIcon(50, "#b983ff")
	nexusSmokeAssert(overhead_icon.Width() == 32 && overhead_icon.Height() == 3, "overhead health icon has invalid dimensions")
	nexusSmokeAssert(overhead_energy_icon.Width() == 32 && overhead_energy_icon.Height() == 3 && overhead_willpower_icon.Width() == 32 && overhead_willpower_icon.Height() == 3, "overhead Energy/Willpower icons have invalid dimensions")
	nexusSmokeAssert(combat_dummy.overhead_health_hud && combat_dummy.overhead_energy_hud && combat_dummy.overhead_willpower_hud, "overhead vitals HUD is incomplete")
	nexusSmokeAssert(combat_dummy.overhead_energy_hud.pixel_y < combat_dummy.overhead_health_hud.pixel_y && combat_dummy.overhead_health_hud.pixel_y < combat_dummy.overhead_willpower_hud.pixel_y, "overhead vitals HUD is not ordered Willpower, Health, Energy from top to bottom")
	nexusSmokeAssert(combat_dummy.attackable, "combat dummy is not targetable")
	nexusSmokeAssert(text2path("/mob/verb/selectTarget") && text2path("/mob/verb/clearTarget"), "player target selection verbs are missing")
	var/icon/target_marker_icon = getSelectedTargetMarkerIcon()
	nexusSmokeAssert(target_marker_icon.Width() == 32 && target_marker_icon.Height() == 32, "selected target marker has invalid dimensions")
	var/mob/NexusSmokeTest/targeting_player = new
	var/turf/targeting_turf = locate(445, 3, 2)
	nexusSmokeAssert(targeting_turf, "targeting smoke test turf is missing")
	targeting_player.loc = targeting_turf
	combat_dummy.loc = get_step(targeting_turf, EAST)
	nexusSmokeAssert(combat_dummy.loc && combat_dummy.loc != targeting_turf, "adjacent targeting smoke test turf is missing")
	targeting_player.setSelectedTarget(combat_dummy, FALSE)
	nexusSmokeAssert(targeting_player.selected_target == combat_dummy && targeting_player.Target == combat_dummy, "combat dummy selection was not recorded")
	nexusSmokeAssert(targeting_player.getSelectedTarget(require_view = FALSE) == combat_dummy, "selected combat dummy was not returned by targeting API")
	targeting_player.dir = WEST
	nexusSmokeAssert(!targeting_player.getSelectedTarget(require_view = FALSE, dir_angle = WEST, angle_limit = 30), "directional targeting ignored its angle limit")
	nexusSmokeAssert(targeting_player.selected_target == combat_dummy, "contextual angle failure cleared the selected target")
	targeting_player.dir = EAST
	nexusSmokeAssert(targeting_player.getSelectedTarget(require_view = FALSE, dir_angle = EAST, angle_limit = 30) == combat_dummy, "directional targeting rejected a target in front")
	combat_dummy.invisibility = targeting_player.see_invisible + 1
	nexusSmokeAssert(!targeting_player.getSelectedTarget(require_view = FALSE) && !targeting_player.selected_target, "invisible target remained selected")
	combat_dummy.invisibility = 0
	targeting_player.setSelectedTarget(null, FALSE)
	nexusSmokeAssert(!targeting_player.selected_target && !targeting_player.LungeTarget(), "lunge acquired a target without explicit selection")
	var/obj/Blast/targeting_blast = new
	targeting_blast.Owner = targeting_player
	targeting_blast.loc = targeting_turf
	nexusSmokeAssert(!targeting_blast.GetBlastHomingTarget(), "blast homing acquired a target without explicit selection")
	targeting_blast.Owner = null
	targeting_blast.loc = null
	del(targeting_blast)
	del(targeting_player)
	nexusSmokeAssert(!combat_dummy.Savable && !combat_dummy.Savable_NPC, "combat dummy can persist into world saves")
	nexusSmokeAssert(combat_dummy.icon == 'BaseHumanPale.dmi', "combat dummy does not use a player body")
	nexusSmokeAssert(!(combat_dummy.overhead_health_hud in combat_dummy.contents) && !(combat_dummy.overhead_energy_hud in combat_dummy.contents) && !(combat_dummy.overhead_willpower_hud in combat_dummy.contents), "combat dummy HUD was added to serializable contents")
	var/savefile/dummy_hud_save = new("nexus-smoke-dummy-hud.sav")
	combat_dummy.Write(dummy_hud_save)
	nexusSmokeAssert((combat_dummy.overhead_health_hud in combat_dummy.vis_contents) && (combat_dummy.overhead_energy_hud in combat_dummy.vis_contents) && (combat_dummy.overhead_willpower_hud in combat_dummy.vis_contents), "combat dummy HUD was not restored after serialization")
	var/mob/NexusSmokeTest/hud_loaded_mob = new
	hud_loaded_mob.Read(dummy_hud_save)
	nexusSmokeAssert(!(locate(/obj/NexusHud) in hud_loaded_mob.contents), "overhead HUD leaked into serialized mob contents")
	nexusSmokeAssert(!(locate(/obj/NexusHud) in hud_loaded_mob.vis_contents), "overhead HUD leaked into serialized visual contents")
	del(hud_loaded_mob)
	combat_dummy.Health = 100
	combat_dummy.TakeDamage(12.5)
	nexusSmokeAssert(combat_dummy.Health == 87.5, "combat dummy did not receive normal combat damage")
	combat_dummy.bleed_damage = 10
	combat_dummy.TakeDamage(200)
	nexusSmokeAssert(combat_dummy.Health == 100 && !combat_dummy.KO && !combat_dummy.Dead, "combat dummy did not reset after damage-only defeat")
	nexusSmokeAssert(!combat_dummy.bleed_damage, "combat dummy retained bleed damage after defeat")
	combat_dummy.setBattlePower(2000)
	combat_dummy.setPowerup(150)
	nexusSmokeAssert(combat_dummy.base_bp == 2000 && combat_dummy.BP == 3000, "combat dummy power controller values are inconsistent")
	del(combat_dummy)
	var/mob/NexusSmokeTest/player = new
	var/mob/NexusSmokeTest/mutation_player = new
	var/mob/NexusSmokeTest/other_mutation_player = new
	mutation_player.rollCharacterMutations("Anomaly")
	nexusSmokeAssert(mutation_player.character_mutations.len == CHARACTER_MUTATIONS.len, "Anomaly mutation did not affect every stat")
	nexusSmokeAssert(mutation_player.mutation_rarity == "Anomaly", "forced mutation rarity was not recorded")
	nexusSmokeAssert(!other_mutation_player.character_mutations.len, "character mutation lists are shared between mobs")
	for(var/mutation_id in mutation_player.character_mutations)
		nexusSmokeAssert(CHARACTER_MUTATIONS[mutation_id], "mutation randomizer produced an unknown mutation")
		nexusSmokeAssert(mutation_player.character_mutations[mutation_id] >= 1 && mutation_player.character_mutations[mutation_id] <= 30, "Anomaly mutation exceeded its percentage bounds")
	var/mob/NexusSmokeTest/common_mutation_player = new
	common_mutation_player.rollCharacterMutations("Common")
	nexusSmokeAssert(common_mutation_player.character_mutations.len == 1, "Common mutation affected more than one stat")
	for(var/mutation_id in common_mutation_player.character_mutations)
		nexusSmokeAssert(common_mutation_player.character_mutations[mutation_id] <= 10, "Common mutation exceeded 10 percent")
	var/mob/NexusSmokeTest/uncommon_mutation_player = new
	uncommon_mutation_player.rollCharacterMutations("Uncommon")
	nexusSmokeAssert(uncommon_mutation_player.character_mutations.len == 1, "Uncommon mutation affected more than one stat")
	for(var/mutation_id in uncommon_mutation_player.character_mutations)
		nexusSmokeAssert(uncommon_mutation_player.character_mutations[mutation_id] <= 20, "Uncommon mutation exceeded 20 percent")
	var/mob/NexusSmokeTest/rare_mutation_player = new
	rare_mutation_player.rollCharacterMutations("Rare")
	nexusSmokeAssert(rare_mutation_player.character_mutations.len in list(2, 3), "Rare mutation did not affect two or three stats")
	for(var/mutation_id in rare_mutation_player.character_mutations)
		nexusSmokeAssert(rare_mutation_player.character_mutations[mutation_id] <= 20, "Rare mutation exceeded 20 percent")
	var/mob/NexusSmokeTest/legacy_mutation_player = new
	legacy_mutation_player.character_mutations = list("adaptive_musculature")
	legacy_mutation_player.mutation_save_version = 1
	legacy_mutation_player.normalizeCharacterMutations()
	nexusSmokeAssert(legacy_mutation_player.character_mutations["adaptive_musculature"] == 10, "legacy mutation ID was not migrated")
	del(legacy_mutation_player)
	del(rare_mutation_player)
	del(uncommon_mutation_player)
	del(common_mutation_player)
	mutation_player.character_mutations = list("adaptive_musculature" = 10, "accelerated_reflexes" = 20)
	mutation_player.mutation_rarity = "Rare"
	var/old_strength_mod = mutation_player.strmod
	var/old_speed_mod = mutation_player.spdmod
	mutation_player.applyCharacterMutations()
	nexusSmokeAssert(round(mutation_player.strmod, 0.01) == round(old_strength_mod * 1.1, 0.01), "strength mutation percentage was not applied")
	nexusSmokeAssert(round(mutation_player.spdmod, 0.01) == round(old_speed_mod * 1.2, 0.01), "speed mutation percentage was not applied")
	other_mutation_player.normalizeCharacterMutations()
	nexusSmokeAssert(other_mutation_player.mutation_save_version == CHARACTER_MUTATION_SAVE_VERSION, "legacy mutation state was not migrated")
	nexusSmokeAssert(!other_mutation_player.character_mutations.len, "legacy character received a retroactive mutation")
	var/mob/NexusSmokeTest/admin_mutation_player = new
	admin_mutation_player.Str = 100
	admin_mutation_player.strmod = 1
	admin_mutation_player.mutation_save_version = CHARACTER_MUTATION_SAVE_VERSION
	nexusSmokeAssert(admin_mutation_player.setCharacterMutationValue("adaptive_musculature", 10), "admin mutation setter rejected a valid mutation")
	nexusSmokeAssertNear(admin_mutation_player.Str, 110, 0.001, "admin mutation setter did not apply its stat modifier")
	nexusSmokeAssertNear(admin_mutation_player.strmod, 1.1, 0.001, "admin mutation setter did not apply its growth modifier")
	nexusSmokeAssert(admin_mutation_player.mutation_rarity == "Common", "admin mutation setter did not derive rarity")
	admin_mutation_player.setCharacterMutationValue("adaptive_musculature", 20)
	nexusSmokeAssertNear(admin_mutation_player.Str, 120, 0.001, "editing an admin mutation stacked its previous modifier")
	admin_mutation_player.setCharacterMutationValue("adaptive_musculature", 0)
	nexusSmokeAssertNear(admin_mutation_player.Str, 100, 0.001, "removing an admin mutation did not restore its stat")
	nexusSmokeAssert(!admin_mutation_player.character_mutations.len && !admin_mutation_player.mutation_rarity, "removing the last admin mutation left stale state")
	nexusSmokeAssert(admin_mutation_player.rerollCharacterMutations("Rare"), "admin mutation reroll rejected a valid forced rarity")
	nexusSmokeAssert(admin_mutation_player.mutation_rarity == "Rare" && admin_mutation_player.character_mutations.len >= 2 && admin_mutation_player.character_mutations.len <= 3, "admin mutation reroll produced an invalid Rare result")
	nexusSmokeAssert(admin_mutation_player.clearCharacterMutations(), "admin mutation clear failed")
	nexusSmokeAssert(!admin_mutation_player.character_mutations.len && !admin_mutation_player.mutation_rarity, "admin mutation clear left stale state")
	del(admin_mutation_player)
	del(other_mutation_player)
	del(mutation_player)
	var/mob/NexusSmokeTest/creation_player = new
	creation_player.Race(force_race = "Human", interactive_options = 0)
	creation_player.rollCharacterMutations("None")
	var/list/human_profile = nexusCreationStatProfile("Human", "human_adaptability")
	var/list/human_allocation = nexusSmokeStatAllocation(human_profile)
	nexusSmokeAssert(nexusValidateStatAllocation(human_profile, human_allocation), "manual Human allocation failed validation")
	creation_player.Racial_Stats(Start_Redo_Stats = 0, modless_check = 0, stat_allocation = human_allocation)
	nexusSmokeAssert(!creation_player.Points, "automatic character stats left unspent points")
	nexusSmokeAssert(creation_player.Max_Points > 0, "automatic character stats did not initialize the point budget")
	nexusSmokeAssert(human_profile["caps"]["offense"] < human_profile["budget"], "Offense has no creation cap")
	nexusSmokeAssert(human_profile["caps"]["defense"] < human_profile["budget"], "Defense has no creation cap")
	creation_player.applyNexusAppearance("Human", "female", "human_f_dark", null, "#223344")
	nexusSmokeAssert(creation_player.icon, "Nexus character appearance did not assign an icon")
	var/mob/NexusSmokeTest/spirit_doll = new
	spirit_doll.Doll(interactive_options = 0)
	nexusSmokeAssert(spirit_doll.Class == "Spirit Doll", "Spirit Doll class was not initialized")
	nexusSmokeAssert(spirit_doll.bp_mod == human_bp_mod * 0.9, "Spirit Doll BP modifier ignored its class")
	var/mob/NexusSmokeTest/frost_lord = new
	frost_lord.Icer(interactive_options = 0, force_cooler = 1)
	nexusSmokeAssert(frost_lord.IsCooler && frost_lord.Class == "Cooler", "forced Cooler lineage was not initialized")
	nexusSmokeAssert(frost_lord.racialCombatBPMult() == 0.76 && frost_lord.racialDamageTakenMult() == cooler_dmg_taken_mult, "Cooler sustainable exceptional package was not applied")
	var/mob/NexusSmokeTest/saiyan_balance_test = new
	saiyan_balance_test.Race = "Saiyan"
	nexusSmokeAssert(saiyan_balance_test.racialCombatBPMult() == 0.77, "base Saiyan escaped Human-equivalent combat BP")
	saiyan_balance_test.Class = "Legendary Saiyan"
	nexusSmokeAssert(saiyan_balance_test.racialCombatBPMult() == 1.65 && saiyan_balance_test.racialDamageTakenMult() == 0.9, "Legendary Saiyan sustainable exceptional package is inconsistent")
	var/mob/NexusSmokeTest/android_balance_test = new
	android_balance_test.Race = "Android"
	nexusSmokeAssert(android_balance_test.racialCombatBPMult() == 1.35 && android_balance_test.racialDamageTakenMult() == 0.55, "Android exceptional package is inconsistent")
	var/mob/NexusSmokeTest/bio_balance_test = new
	bio_balance_test.Race = "Bio-Android"
	nexusSmokeAssert(bio_balance_test.racialCombatBPMult() == 1.1 && bio_balance_test.racialDamageTakenMult() == 0.89, "Bio-Android exceptional package is inconsistent")
	var/mob/NexusSmokeTest/majin_balance_test = new
	majin_balance_test.Race = "Majin"
	nexusSmokeAssert(majin_balance_test.racialCombatBPMult() == 1.13 && majin_balance_test.racialDamageTakenMult() == 0.96, "Majin sustainable exceptional package is inconsistent")
	nexusSmokeAssert(third_eye_bp_add == 0.2, "Third Eye BP no longer matches its 1.2x description")
	nexusSmokeAssert(jirenAlienBPMult == 0.95 && jirenTakeDmgMult == 1 && jirenAlienPowerupMult == 0.75, "Alien Apex Genome escaped the Standard-tier package")
	var/old_makyo_star_state = Makyo_Star
	Makyo_Star = FALSE
	var/list/race_balance_cases = list(
		list("Human", "Human", null, FALSE, FALSE, 1.33, 1),
		list("Spirit Doll", "Human", "Spirit Doll", FALSE, FALSE, 1.197, 1),
		list("Saiyan", "Saiyan", null, FALSE, FALSE, 1.54, 1),
		list("Half Saiyan", "Half Saiyan", null, FALSE, FALSE, 1.725, 1),
		list("Legendary Saiyan", "Saiyan", "Legendary Saiyan", FALSE, FALSE, 3.3, 0.9),
		list("Alien", "Alien", null, FALSE, FALSE, 1.55, 1),
		list("Alien Apex Genome", "Alien", null, TRUE, FALSE, 1.4725, 1),
		list("Android", "Android", null, FALSE, FALSE, 1.35, 0.55),
		list("Bio-Android", "Bio-Android", null, FALSE, FALSE, 2.31, 0.89),
		list("Demigod", "Demigod", null, FALSE, FALSE, 1.65, 1),
		list("Demon", "Demon", null, FALSE, FALSE, 1.85, 1),
		list("Frost Lord", "Frost Lord", null, FALSE, FALSE, 1.68, 1),
		list("Cooler", "Frost Lord", "Cooler", FALSE, TRUE, 1.596, 0.89),
		list("Kai", "Kai", null, FALSE, FALSE, 1.8, 1),
		list("Kanassan", "Kanassan", "Seer", FALSE, FALSE, 1.75, 1),
		list("Heran", "Heran", "Space Pirate", FALSE, FALSE, 2.05, 1),
		list("Makyo", "Makyo", null, FALSE, FALSE, 1.739, 1),
		list("Majin", "Majin", null, FALSE, FALSE, 2.8815, 0.96),
		list("Namekian", "Namekian", null, FALSE, FALSE, 1.65, 1),
		list("Tsujin", "Tsujin", null, FALSE, FALSE, 1.28, 1))
	for(var/list/balance_case in race_balance_cases)
		var/mob/NexusSmokeTest/race_balance_test = new
		race_balance_test.Race = balance_case[2]
		race_balance_test.Class = balance_case[3]
		race_balance_test.jirenAlien = balance_case[4]
		race_balance_test.IsCooler = balance_case[5]
		var/effective_creation_bp = race_balance_test.Get_race_starting_bp_mod() * race_balance_test.racialCombatBPMult()
		nexusSmokeAssertNear(effective_creation_bp, balance_case[6], 0.0001, "creation BP package diverged from the balance workbook: [balance_case[1]]")
		nexusSmokeAssertNear(race_balance_test.racialDamageTakenMult(), balance_case[7], 0.0001, "incoming damage package diverged from the balance workbook: [balance_case[1]]")
		del(race_balance_test)
	Makyo_Star = TRUE
	var/mob/NexusSmokeTest/makyo_star_balance_test = new
	makyo_star_balance_test.Race = "Makyo"
	nexusSmokeAssertNear(makyo_star_balance_test.racialCombatBPMult(), 1.08, 0.0001, "Makyo Star combat bonus is missing or excessive")
	del(makyo_star_balance_test)
	Makyo_Star = old_makyo_star_state
	var/list/expected_creation_budgets = list(
		"Human|human_adaptability" = 72,
		"Spirit Doll|doll_awakened" = 72,
		"Saiyan|saiyan_warrior" = 33,
		"Saiyan|saiyan_low_class" = 37,
		"Saiyan|saiyan_elite" = 34,
		"Half Saiyan|half_saiyan_hybrid" = 44,
		"Legendary Saiyan|legendary_berserker" = 34,
		"Alien|alien_scholar" = 75,
		"Alien|alien_predator" = 75,
		"Alien|alien_shifter" = 75,
		"Alien|alien_anomaly" = 75,
		"Android|android_chassis" = 61,
		"Android|android_infiltrator" = 61,
		"Android|android_progenitor" = 61,
		"Bio-Android|bio_adaptation" = 31,
		"Demigod|demigod_heritage" = 24,
		"Demon|demon_soulbound" = 44,
		"Frost Lord|frost_heir" = 29,
		"Frost Lord|frost_cooler" = 29,
		"Kai|kai_guardian" = 42,
		"Kanassan|kanassan_seer" = 44,
		"Heran|heran_pirate" = 37,
		"Makyo|makyo_starborn" = 48,
		"Majin|majin_fragment" = 34,
		"Namekian|namek_dragon_clan" = 45,
		"Namekian|namek_ancient" = 45,
		"Tsujin|tsujin_engineer" = 55)
	for(var/profile_id in expected_creation_budgets)
		var/list/profile_parts = splittext(profile_id, "|")
		var/list/balance_profile = nexusCreationStatProfile(profile_parts[1], profile_parts[2])
		nexusSmokeAssert(balance_profile["budget"] == expected_creation_budgets[profile_id], "creation budget diverged from the balance workbook: [profile_id]")
	var/mob/NexusSmokeTest/ported_race_test = new
	ported_race_test.Kanassan(FALSE)
	nexusSmokeAssert(ported_race_test.Race == "Kanassan" && ported_race_test.precog && (locate(/obj/Telepathy) in ported_race_test), "Kanassan template lacks its psionic identity")
	ported_race_test.Heran(FALSE)
	nexusSmokeAssert(ported_race_test.Race == "Heran" && ported_race_test.Class == "Space Pirate" && ported_race_test.zenkai_mod == 1, "Heran template lacks its combat-growth identity")
	ported_race_test.Namekian(FALSE)
	ported_race_test.applyAncientNamekianLineage()
	nexusSmokeAssert(ported_race_test.Class == "Ancient" && (locate(/obj/Materialization) in ported_race_test), "Ancient Namekian lineage was not applied")
	ported_race_test.Android(FALSE)
	ported_race_test.applyAncientProgenitorLineage()
	nexusSmokeAssert(ported_race_test.Class == "Ancient Progenitor" && ported_race_test.Knowledge >= 900 && (locate(/obj/Advanced_Sense) in ported_race_test), "Ancient Progenitor lineage was not applied")
	del(ported_race_test)
	var/datum/PlanetaryClock/planet_clock_test = new("smoke")
	planet_clock_test.hours_of_day = 15
	planet_clock_test.hours_of_night = 9
	planet_clock_test.is_day = TRUE
	planet_clock_test.hours_remaining = 1
	planet_clock_test.advanceHour()
	nexusSmokeAssert(!planet_clock_test.is_day && planet_clock_test.hours_remaining == 9 && nexus_planetary_hour_ticks >= 3000, "planetary clock did not synchronize a longer day/night phase")
	del(planet_clock_test)
	var/legendary_sustainable_bp = 11 * 1.35 * 1.35 * lssj_combat_bp_mult
	var/bio_sustainable_bp = base_ascension_mod * 1.265 * bio_android_combat_bp_mult * 1.6
	var/majin_sustainable_bp = base_ascension_mod * 1.265 * 1.3 * majin_combat_bp_mult * 1.2
	nexusSmokeAssert(legendary_sustainable_bp > 33 && legendary_sustainable_bp < 33.2, "Legendary sustainable progression escaped the Exceptional target")
	nexusSmokeAssert(bio_sustainable_bp > 33 && bio_sustainable_bp < 33.2, "Bio-Android sustainable progression escaped the Exceptional target")
	nexusSmokeAssert(majin_sustainable_bp > 33 && majin_sustainable_bp < 33.2, "Majin sustainable progression escaped the Exceptional target")
	var/list/alien_definitions = nexusAlienOptionDefinitions()
	nexusSmokeAssert(alien_definitions.len == 23, "Alien point-buy catalog is incomplete")
	nexusSmokeAssert(nexusValidateAlienOptions(nexusAlienPresetOptions("alien_scholar")) && nexusValidateAlienOptions(nexusAlienPresetOptions("alien_predator")) && nexusValidateAlienOptions(nexusAlienPresetOptions("alien_shifter")) && nexusValidateAlienOptions(nexusAlienPresetOptions("alien_anomaly")), "an Alien preset exceeds its 100 AP budget")
	nexusSmokeAssert(!nexusValidateAlienOptions(list("genius" = TRUE, "time_freeze" = TRUE, "precognition" = TRUE, "apex_genome" = TRUE)), "Alien point-buy accepted more than 100 AP")
	var/mob/NexusSmokeTest/alien_point_buy_test = new
	alien_point_buy_test.Alien(interactive_options = 0)
	alien_point_buy_test.bp_loss_from_low_ki = 1
	alien_point_buy_test.bp_loss_from_low_hp = 1
	alien_point_buy_test.applyNexusAlienOptions(list("genius", "limit_breaker", "stretchy_arms", "low_ki_resistance", "low_health_resistance"))
	nexusSmokeAssert(alien_point_buy_test.Intelligence == 1 && (locate(/obj/Limit_Breaker) in alien_point_buy_test) && alien_point_buy_test.arm_stretch, "Alien point-buy effects were not applied")
	nexusSmokeAssert(alien_point_buy_test.bp_loss_from_low_ki == 1 / 3 && alien_point_buy_test.bp_loss_from_low_hp == 1 / 3, "Alien low-resource resistance was not applied")
	var/list/frost_icon_options = nexusFrostIconOptions()
	nexusSmokeAssert(frost_icon_options.len >= 40, "Frost Lord creation does not expose the complete form catalog")
	var/list/frost_form_ids = list()
	for(var/frost_icon_id in frost_icon_options)
		frost_form_ids += frost_icon_id
		if(frost_form_ids.len == 5) break
	nexusSmokeAssert(nexusValidateFrostFormOptions(frost_form_ids, TRUE), "Cooler form-slot validation rejected the full five-form selection")
	frost_lord.applyNexusAppearance("Frost Lord", "male", frost_form_ids[1], null, null, frost_form_ids)
	nexusSmokeAssert(frost_lord.Form1Icon == frost_icon_options[frost_form_ids[1]] && frost_lord.Form5Icon == frost_icon_options[frost_form_ids[5]], "Frost Lord form icons were not assigned independently")
	var/list/starter_clothing_options = nexusStarterClothingOptions()
	nexusSmokeAssert(starter_clothing_options.len >= 80, "starter clothing catalog is unexpectedly incomplete")
	var/succubus_flight_state = nexusPreviewIconState('Succubus.dmi', "flight")
	var/human_flight_state = nexusPreviewIconState('BaseHumanPale.dmi', "flight")
	var/succubus_preview_url = nexusBrowserIconUrl('Succubus.dmi', succubus_flight_state, WEST)
	var/cape_preview_url = nexusBrowserIconUrl('ItemPiccoloCape.dmi', "", NORTH)
	nexusSmokeAssert(succubus_flight_state == "Flight", "starter clothing preview did not resolve Flight case-insensitively")
	nexusSmokeAssert(human_flight_state == "Flight", "standard Human preview has no selectable Flight state")
	nexusSmokeAssert(findtext(succubus_preview_url, "?dir=[WEST]&frame=1") && findtext(succubus_preview_url, "&state=Flight"), "Succubus preview does not select one directional Flight frame")
	nexusSmokeAssert(findtext(cape_preview_url, "?dir=[NORTH]&frame=1") && !findtext(cape_preview_url, "moving=0"), "moving-only Cape preview can fall back to its full sprite sheet")
	var/list/starter_clothing_ids = list()
	for(var/clothing_id in starter_clothing_options)
		starter_clothing_ids[clothing_id] = TRUE
		if(starter_clothing_ids.len == 2) break
	nexusSmokeAssert(nexusValidateStarterClothing(starter_clothing_ids), "valid starter clothing was rejected")
	var/list/excess_clothing_ids = list()
	for(var/clothing_id in starter_clothing_options)
		excess_clothing_ids[clothing_id] = TRUE
		if(excess_clothing_ids.len > nexus_starter_clothing_limit) break
	nexusSmokeAssert(!nexusValidateStarterClothing(excess_clothing_ids), "starter clothing exceeded its selection limit")
	var/mob/NexusSmokeTest/appearance_test = new
	var/obj/items/Clothes/ShortSleeveShirt/appearance_shirt_1 = new(appearance_test)
	var/obj/items/Clothes/ShortSleeveShirt/appearance_shirt_2 = new(appearance_test)
	appearance_shirt_1.suffix = "Equipped"
	appearance_shirt_2.suffix = "Equipped"
	appearance_shirt_1.appearance_priority = 700
	appearance_shirt_2.appearance_priority = 300
	appearance_test.rebuildPlayerAppearance("startup test")
	var/datum/PlayerAppearanceManager/test_appearance_manager = appearance_test.player_appearance_manager
	var/list/ordered_appearance_entries = test_appearance_manager.sortedEntries()
	nexusSmokeAssert(test_appearance_manager.rendered_appearances.len == 2 && test_appearance_manager.rendered_appearances[1] != test_appearance_manager.rendered_appearances[2], "identical clothing icons do not have independent overlay ownership")
	nexusSmokeAssert(ordered_appearance_entries[1]:source == appearance_shirt_2, "overlay priority did not produce deterministic ordering")
	initializeNexusTransformationRegistry()
	nexusSmokeAssert(nexus_transformation_registry.len >= 15, "primary transformation registry is incomplete")
	var/mob/NexusSmokeTest/transformation_state_test = new
	transformation_state_test.Race = "Saiyan"
	transformation_state_test.ssj = 3
	transformation_state_test.using_giant_form = TRUE
	nexusSmokeAssert(transformation_state_test.countPrimaryTransformations() == 2 && transformation_state_test.detectPrimaryTransformation() == "giant", "legacy simultaneous transformation detection failed")
	nexusSmokeAssert(getSsjEyeOverlay(FALSE) != getSsjEyeOverlay(TRUE), "mastered and unmastered Super Saiyan eye overlays are identical")
	var/mob/NexusSmokeTest/giant_form_test = new
	giant_form_test.Race = "Makyo"
	giant_form_test.bp_mult = 1
	giant_form_test.Enable_giant_form()
	giant_form_test.Disable_giant_form()
	nexusSmokeAssert(round(giant_form_test.bp_mult, 0.001) == 1, "Giant Form left a permanent BP multiplier")
	del(giant_form_test)
	del(transformation_state_test)
	del(appearance_test)
	del(alien_point_buy_test)
	del(majin_balance_test)
	del(bio_balance_test)
	del(android_balance_test)
	del(saiyan_balance_test)
	del(frost_lord)
	del(spirit_doll)
	del(creation_player)
	for(var/race_name in Race_List())
		var/list/traits = nexusRaceTraitOptions(race_name, player, 1)
		for(var/trait_id in traits)
			var/list/profile = nexusCreationStatProfile(race_name, trait_id)
			var/list/caps = profile["caps"]
			var/total_capacity
			for(var/stat_id in NEXUS_CREATION_STATS)
				nexusSmokeAssert(isnum(caps[stat_id]), "creation profile contains a nonnumeric cap: [race_name]/[trait_id]/[stat_id]")
				total_capacity += caps[stat_id]
			nexusSmokeAssert(total_capacity >= profile["budget"], "creation profile cannot spend its full budget: [race_name]/[trait_id]")

	player.give_energy_type("Mental Energy", amount = 25, maximum = 200, modifier = 1.5)

	var/Energy/mental_energy = player.get_energy("Mental Energy")
	nexusSmokeAssert(mental_energy, "Mental Energy was not created")
	nexusSmokeAssert(mental_energy.quantity == 25, "Mental Energy quantity is invalid")
	nexusSmokeAssert(mental_energy.maximum == 200, "Mental Energy maximum is invalid")
	nexusSmokeAssert(mental_energy.modifier == 1.5, "Mental Energy modifier is invalid")

	player.give_energy_type("Mental Energy")
	nexusSmokeAssert(player.get_energy("Mental Energy") == mental_energy, "duplicate energy replaced the existing datum")
	player.give_energy_type("Unknown Energy")
	nexusSmokeAssert(!player.get_energy("Unknown Energy"), "an unknown energy type was created")

	player.energies["Qi"] = new /Energy("Qi Energy")
	player.character_mutations = list("reactive_guard" = 7)
	player.mutation_rarity = "Common"
	player.mutation_save_version = CHARACTER_MUTATION_SAVE_VERSION
	player.Race = "Demon"
	player.energy_save_version = 0
	var/savefile/energy_save = new("nexus-smoke-energy.sav")
	player.Write(energy_save)
	var/mob/NexusSmokeTest/loaded_player = new
	loaded_player.Read(energy_save)
	loaded_player.normalize_energy_types()
	nexusSmokeAssert(loaded_player.get_energy("Mental Energy").quantity == 25, "energy state did not survive serialization")
	nexusSmokeAssert(loaded_player.get_energy("Soul Energy"), "legacy Demon did not receive Soul Energy")
	nexusSmokeAssert(!loaded_player.get_energy("Qi"), "legacy Qi energy was not removed after deserialization")
	nexusSmokeAssert(loaded_player.energy_save_version == ENERGY_SAVE_VERSION, "energy save migration version was not recorded")
	nexusSmokeAssert(loaded_player.character_mutations["reactive_guard"] == 7, "character mutation did not survive serialization")
	nexusSmokeAssert(loaded_player.mutation_rarity == "Common", "character mutation rarity did not survive serialization")
	loaded_player.remove_energy_type("Mental Energy")
	loaded_player.normalize_energy_types()
	nexusSmokeAssert(!loaded_player.get_energy("Mental Energy"), "completed migration restored an intentionally removed energy")
	nexusSmokeAssert(!GLOBAL_ENERGY_TYPES["Qi"], "Qi remains registered")

	var/list/expected_technology_types = list()
	for(var/technology_type in typesof(/obj))
		if(initial(technology_type:Cost))
			expected_technology_types += technology_type
	nexusSmokeAssert(tech_list.len == expected_technology_types.len, "technology catalog has an unexpected entry count")
	nexusSmokeAssert(soul_contracts.len == soul_contract_count_before, "technology initialization created a Contract Soul")
	for(var/obj/technology in tech_list)
		nexusSmokeAssert(technology.Cost, "technology catalog contains an object without Cost")
		nexusSmokeAssert(technology.referenceObject, "technology catalog entry is not marked as a reference")
		nexusSmokeAssert(!istype(technology, /obj/Contract_Soul), "Contract Soul was added to the technology catalog")
		nexusSmokeAssert(technology.type in expected_technology_types, "technology was instantiated more than once: [technology.type]")
		expected_technology_types -= technology.type
	nexusSmokeAssert(!expected_technology_types.len, "technology catalog is missing eligible types")
	var/obj/test/texthandling/text_test = new
	text_test.dd_list2text_test()
	del(text_test)

	del(loaded_player)
	del(player)
	world.log << "NEXUS_SMOKE_TESTS_PASSED"
