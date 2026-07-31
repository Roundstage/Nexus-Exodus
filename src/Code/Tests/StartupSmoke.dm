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
	nexusSmokeAssert(!text2path("/mob/verb/viewAdminLogs"), "admin log viewer is exposed to ordinary mobs")
	nexusSmokeAssert(!text2path("/mob/verb/viewAllAdminLogs"), "combined admin log viewer is exposed to ordinary mobs")
	nexusSmokeAssert(text2path("/mob/Admin1/verb/viewAdminLogs"), "admin log viewer is missing from the admin verb tree")
	nexusSmokeAssert(text2path("/mob/Admin1/verb/viewAllAdminLogs"), "combined admin log viewer is missing from the admin verb tree")
	nexusSmokeAssert(!text2path("/mob/verb/spawnCombatDummy"), "combat dummy spawner is exposed to ordinary mobs")
	nexusSmokeAssert(text2path("/mob/Admin2/verb/spawnCombatDummy"), "combat dummy spawner is missing from the admin verb tree")
	nexusSmokeAssert(text2path("/mob/Admin2/verb/controlCombatDummy"), "combat dummy controller is missing from the admin verb tree")
	nexusSmokeAssert(text2path("/obj/DamageIndicator"), "damage indicator type is missing")
	nexusSmokeAssert(text2path("/obj/NexusHud/VitalsPanel"), "main vitals HUD type is missing")
	nexusSmokeAssert(hudPercentage(50, 200) == 25, "HUD percentage calculation is invalid")
	nexusSmokeAssert(hudPercentage(50, 0) == 0, "HUD percentage did not guard a zero maximum")
	nexusSmokeAssert(nexusIsFiniteNumber(50) && !nexusIsFiniteNumber(1.#INF), "finite-number validation is invalid")
	var/obj/NexusHud/VitalsPanel/vitals_panel = new
	nexusSmokeAssert(vitals_panel.screen_loc == "LEFT:8,BOTTOM:8", "main vitals HUD is not fully inside the lower-left corner")
	vitals_panel.setScreenPosition(92, 62)
	nexusSmokeAssert(vitals_panel.screen_loc == "LEFT:92,BOTTOM:62", "main vitals HUD drag positioning is invalid")
	var/mob/NexusSmokeTest/vitals_owner = new
	vitals_owner.icon = 'BaseHumanPale.dmi'
	vitals_owner.Ki = 80
	vitals_owner.max_ki = 100
	vitals_panel.initialize(vitals_owner)
	nexusSmokeAssert(vitals_panel.vis_contents.len == 7 && vitals_panel.alpha == 255, "main vitals HUD composition is incomplete")
	var/icon/main_vitals_icon = getVitalsPanelIcon()
	var/icon/main_vitals_bar = getVitalsBarIcon(50, "#46d369")
	var/icon/power_gauge = getPowerGaugeIcon(50, FALSE)
	nexusSmokeAssert(vitals_panel.icon, "main vitals HUD did not retain its generated backdrop")
	nexusSmokeAssert(main_vitals_icon.Width() == 380 && main_vitals_icon.Height() == 160, "main vitals HUD has invalid dimensions")
	nexusSmokeAssert(main_vitals_bar.Width() == 220 && main_vitals_bar.Height() == 24, "main vitals bar has invalid dimensions")
	nexusSmokeAssert(power_gauge.Width() == 9 && power_gauge.Height() == 96, "main vitals power gauge has invalid dimensions")
	nexusSmokeAssert(!text2path("/obj/NexusHud/VitalRow/Power"), "redundant horizontal power bar still exists")
	nexusSmokeAssert(findtext(vitals_panel.energy_row.detail_text.maptext, "(80) 80%") && vitals_panel.energy_row.detail_alignment == "right", "Energy amount and percentage are not rendered together on the right")
	nexusSmokeAssert(!findtext(vitals_panel.power_readout.maptext, "<br>"), "power readout still renders duplicate lines")
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
	var/obj/Blast/trailing_beam_segment = new(beam_mode_player.loc)
	trailing_beam_segment.Owner = beam_mode_player
	trailing_beam_segment.Beam = 1
	beam_mode_player.my_beam_objs.Add(beam_impact_segment, trailing_beam_segment)
	streaming_beam.beam_objects.Add(beam_impact_segment, trailing_beam_segment)
	beam_impact_segment.showExplosiveBeamImpact(beam_impact_target, force_mob_impact = 1)
	nexusSmokeAssert(!streaming_beam.streaming && !beam_mode_player.beaming, "raw player impact did not stop the streaming beam")
	nexusSmokeAssert(!streaming_beam.beam_objects.len && !beam_mode_player.my_beam_objs.len, "raw player impact did not clear beam segment lists")
	nexusSmokeAssert(!beam_impact_segment.z && !trailing_beam_segment.z, "raw player impact left beam segments on the map")
	var/obj/Attacks/Blast/nonbeam_skill = new
	del(beam_impact_target)
	del(beam_mode_player)
	del(nonbeam_skill)
	del(beam_skill)
	var/obj/RockThrow/rock_throw_skill = new
	var/obj/RockSlide/rock_slide_skill = new
	var/obj/RockTomb/rock_tomb_skill = new
	nexusSmokeAssert(rock_throw_skill.icon == 'ResourceRocks.dmi' && rock_slide_skill.icon == 'RisingRocks.dmi' && rock_tomb_skill.icon == 'RockExplosion.dmi', "rock skills are missing their icons")
	nexusSmokeAssert(rock_throw_skill.hotbar_type == "Blast" && rock_slide_skill.hotbar_type == "Blast" && rock_tomb_skill.hotbar_type == "Blast", "rock skills use an unsupported hotbar category")
	del(rock_throw_skill)
	del(rock_slide_skill)
	del(rock_tomb_skill)
	var/obj/Lunge/lunge_action = new
	nexusSmokeAssert(lunge_action.can_hotbar && /obj/Lunge/verb/lunge in lunge_action.verbs, "Lunge is not available as a standalone action")
	del(lunge_action)
	nexusSmokeAssert(wolf_fang_hit_damage_mult == 1 && wolf_fang_knockback_distance == 3, "Wolf Fang Fist combo tuning is invalid")
	nexusSmokeAssert(hundred_crack_min_hits == 24 && hundred_crack_hit_damage_mult == 0.25, "Hundred Crack Fist remains an execution instead of a damage combo")
	nexusSmokeAssert(base_melee_damage == 2.5 && combat_damage_bp_exponent == 0.5 && combat_damage_stat_exponent == 0.85, "central combat damage constants are invalid")
	nexusSmokeAssert(calculateScaledCombatDamage(10, 100, 100, 100, 100) == 10, "equal-stat central damage did not preserve its factor")
	nexusSmokeAssert(!calculateScaledCombatDamage(10, 100, 100, 0, 100), "zero offensive stat still caused damage")
	var/superior_stat_damage = calculateScaledCombatDamage(10, 100, 100, 200, 100)
	var/inferior_stat_damage = calculateScaledCombatDamage(10, 100, 100, 100, 200)
	nexusSmokeAssert(superior_stat_damage > 12 && superior_stat_damage < 13, "superior stat scaling escaped its expected bound")
	nexusSmokeAssert(inferior_stat_damage > 7 && inferior_stat_damage < 7.2, "defensive stat scaling escaped its expected bound")
	var/datum/CombatDamageBudget/test_damage_budget = new(7)
	var/mob/NexusSmokeTest/budget_target = new
	nexusSmokeAssert(test_damage_budget.reserveFactor(budget_target, 3.5) == 3.5 && test_damage_budget.reserveFactor(budget_target, 5) == 3.5, "per-target damage budget exceeded its cap")
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
	del(big_bang_projectile)
	del(projectile_owner)
	del(final_flash_skill)
	del(noob_ray_skill)
	nexusSmokeAssert(ki_projectile_step_delay == 0.5, "Ki projectile cadence is not normalized for 60 FPS")
	var/obj/Attacks/Sokidan/sokidan_skill = new
	var/datum/SkillDefinition/sokidan_definition = skill_engine.getDefinitionForObj(sokidan_skill)
	nexusSmokeAssert(sokidan_definition && sokidan_definition.control_delay == ki_projectile_step_delay, "Sokidan does not use the normalized Ki projectile cadence")
	del(sokidan_skill)
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
	var/obj/Zanzoken/zanzoken_skill = new(warp_player)
	nexusSmokeAssert(warp_player.getZanzokenSkill() == zanzoken_skill && zanzoken_action.isAvailable(warp_player), "owned Zanzoken was not activated")
	nexusSmokeAssert(/obj/Zanzoken/verb/flashStep in zanzoken_skill.verbs, "Flash Step is not exposed by the learnable Zanzoken skill")
	for(var/zanzoken_verb in zanzoken_verbs)
		nexusSmokeAssert(zanzoken_verb in zanzoken_skill.verbs, "owned Zanzoken is missing a directional verb")
	warp_player.nexus_hotkey_bindings["CTRL+Numpad7"] = list("kind" = "action", "action id" = "zanzoken_north")
	nexusSmokeAssert(warp_player.resolveNexusHotkeyBinding("CTRL+Numpad7") == zanzoken_action, "Zanzoken directional action could not be bound")
	nexusSmokeAssert(canonicalNexusHotkey("Numpad7", TRUE, TRUE, TRUE) == "CTRL+SHIFT+ALT+Numpad7", "modifier or numpad hotkey canonicalization is invalid")
	var/obj/Manual_Attack/manual_attack_action = new(warp_player)
	manual_attack_action.hotbar_id = "nexus-smoke-action"
	var/list/manual_binding = list("kind" = "object", "object id" = manual_attack_action.hotbar_id, "object type" = manual_attack_action.type, "display name" = "Manual Attack")
	warp_player.nexus_hotkey_bindings["ALT+F3"] = manual_binding
	warp_player.nexus_hotkey_bindings["Numpad1"] = manual_binding.Copy()
	nexusSmokeAssert(warp_player.resolveNexusHotkeyBinding("ALT+F3") == manual_attack_action, "object hotkey action did not resolve")
	nexusSmokeAssert(warp_player.resolveNexusHotkeyBinding("Numpad1") == manual_attack_action, "one action could not be assigned to multiple keys")
	del(zanzoken_skill)
	nexusSmokeAssert(!warp_player.hasZanzokenSkill() && !warp_player.resolveNexusHotkeyBinding("CTRL+Numpad7"), "Zanzoken binding remained active after losing the skill")
	del(manual_attack_action)
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
	nexusSmokeAssert(overhead_icon.Width() == 32 && overhead_icon.Height() == 5, "overhead health icon has invalid dimensions")
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
	nexusSmokeAssert(!(combat_dummy.overhead_health_hud in combat_dummy.contents), "combat dummy HUD was added to serializable contents")
	var/savefile/dummy_hud_save = new("nexus-smoke-dummy-hud.sav")
	combat_dummy.Write(dummy_hud_save)
	nexusSmokeAssert(combat_dummy.overhead_health_hud in combat_dummy.vis_contents, "combat dummy HUD was not restored after serialization")
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
