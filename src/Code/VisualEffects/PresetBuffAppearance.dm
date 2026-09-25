// Original RPT resources are separate from hotbar artwork and transient activation bursts.
proc/getPresetBuffAppearances()
	var/static/list/catalog = list(
		"/obj/Buff/Focus" = list(list('src/Icons/NexusIntegrated/Buffs/RTFocusElectricity.dmi', 0, 0, null, 255)),
		"/obj/Buff/Preset/MuscleForce" = list(list('src/Icons/NexusIntegrated/Buffs/RTMuscleAura.dmi', 0, 0, null, 255)),
		"/obj/Buff/Preset/CombatMathematics" = list(list('src/Icons/NexusIntegrated/Buffs/RTCalculationCloak.dmi', -32, -32, null, 200)),
		"/obj/Buff/Preset/MagicForce" = list(list('src/Icons/NexusIntegrated/Buffs/RTMagicAura.dmi', -19, -19, null, 255)),
		"/obj/Buff/Preset/OffensiveStance" = list(list('src/Icons/NexusIntegrated/Buffs/RTMuscleAura.dmi', 0, 0, "#ff8060", 255)),
		"/obj/Buff/Preset/DefensiveStance" = list(list('src/Icons/NexusIntegrated/Buffs/RTMuscleAura.dmi', 0, 0, "#74a7ff", 255)),
		"/obj/Buff/Preset/BleedingEdge" = list(list('src/Icons/NexusIntegrated/Buffs/RTBushido.dmi', 0, 0, "#ff304f", 255)),
		"/obj/Buff/Preset/BurningFist" = list(list('src/Icons/NexusIntegrated/Buffs/RTBurningFists.dmi', 0, 0, null, 255)),
		"/obj/Buff/Preset/DemonicFury" = list(list('src/Icons/NexusIntegrated/Buffs/RTDemonicHalo.dmi', 0, 0, null, 255)),
		"/obj/Buff/Preset/AngelicGrace" = list(list('src/Icons/NexusIntegrated/Buffs/RTAngelicHalo.dmi', 0, 0, null, 255)),
		"/obj/Buff/Preset/Channel" = list(list('src/Icons/NexusIntegrated/Buffs/RTChannel.dmi', 0, 0, null, 255), list('src/Icons/NexusIntegrated/Buffs/RTBlueCloak.dmi', -32, -32, null, 200)),
		"/obj/Buff/Ultimate/HighTension" = list(list('src/Icons/NexusIntegrated/Buffs/RTMuscleAura.dmi', 0, 0, null, 255), list('src/Icons/NexusIntegrated/Buffs/RTPinkCloak.dmi', -32, -32, null, 200)),
		"/obj/Buff/Ultimate/Godspeed" = list(list('src/Icons/NexusIntegrated/Buffs/RTGodspeedElectricity.dmi', 0, 0, null, 255), list('src/Icons/NexusIntegrated/Buffs/RTPurpleCloak.dmi', -32, -32, null, 200)),
		"/obj/Buff/Ultimate/FistsOfFury" = list(list('src/Icons/NexusIntegrated/Buffs/RTFistsOfFury.dmi', 0, 0, null, 255)),
		"/obj/Buff/Ultimate/ArcanePower" = list(list('src/Icons/NexusIntegrated/Buffs/RTArcanePower.dmi', 0, 0, null, 255)),
		"/obj/Buff/Ultimate/BestialWrath" = list(list('src/Icons/NexusIntegrated/Buffs/RTRisingRocks.dmi', 0, 0, null, 255), list('src/Icons/NexusIntegrated/Buffs/RTBestialCloak.dmi', -32, -32, null, 200)),
		"/obj/Buff/Ultimate/Bushido" = list(list('src/Icons/NexusIntegrated/Buffs/RTBushido.dmi', 0, 0, null, 255)),
		"/obj/DemonBuff/Famine" = list(list('src/Icons/NexusIntegrated/Buffs/RTDarkAura.dmi', -48, -10, null, 175)),
		"/obj/DemonBuff/War" = list(list('src/Icons/NexusIntegrated/Buffs/RTWar.dmi', -32, 0, null, 255), list('src/Icons/NexusIntegrated/Buffs/RTRedAura.dmi', -48, -10, null, 175)),
		"/obj/DemonBuff/Pestilence" = list(list('src/Icons/NexusIntegrated/Buffs/RTDarkAura.dmi', -48, -10, "#83b85b", 175), list('src/Icons/NexusIntegrated/Buffs/RTFlies.dmi', 0, 0, null, 255)),
		"/obj/DemonBuff/Death" = list(list('src/Icons/NexusIntegrated/Buffs/RTPaleAura.dmi', -48, -10, null, 175)))
	return catalog

datum/PlayerAppearanceManager/proc/syncPresetBuffs()
	clearCategory("preset_buff")
	if(!owner) return
	var/list/catalog = getPresetBuffAppearances()
	// Saved overlays survive while manager handles are transient. Remove by dedicated resource.
	var/static/list/buff_icons
	if(!buff_icons)
		buff_icons = list()
		for(var/buff_type in catalog)
			for(var/list/visual in catalog[buff_type]) buff_icons |= visual[1]
	var/list/stale = list()
	for(var/appearance_value in owner.overlays)
		if(appearance_value:icon in buff_icons) stale += appearance_value
	owner.overlays -= stale
	var/list/active_skills = list()
	for(var/obj/Buff/buff in owner)
		if(buff.suffix && catalog["[buff.type]"]) active_skills += buff
	if(owner.active_demon_buff)
		var/obj/DemonBuff/demon_buff = locate(owner.active_demon_buff) in owner
		if(demon_buff) active_skills += demon_buff
	for(var/obj/skill in active_skills)
		var/index = 0
		for(var/list/visual in catalog["[skill.type]"])
			index++
			setSlot("preset_buff:\ref[skill]:[index]", "preset_buff", 710, visual[1], skill, "", visual[2], visual[3], visual[4], visual[5])
