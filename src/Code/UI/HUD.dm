mob
	proc/DrawHUD(mob/M=usr)
		if(!M.client) return
		var/HUD/H
		for(H in M.client.screen)		//First, clear the client's screen so that we draw completely new items...
			M.client.screen.Remove(H)	//and don't just make new ones over the old.
		var/HUD/charAnchor = new /HUD/screenAnchor("WEST+1", "NORTH-1")
		M.client.screen.Add(charAnchor)
		charAnchor.vis_contents.Add(M.cBubble)
		DrawBars(M, 0)
		DrawBars(M, 1)
	proc/DrawBars(mob/M=usr, t=0)
		var/list/statScale = list(0.5*M.guiScale, 0.55*M.guiScale)
		var/bubScale = 1.2*M.guiScale
		if(!t)
			M.healthBar = new/HUD/statBar/healthBar(M, statScale[1], statScale[2])
			M.staminaBar = new/HUD/statBar/stamBar(M, statScale[1], statScale[2])
			M.kiBar = new/HUD/statBar/kiBar(M, statScale[1], statScale[2])
			M.kiBar.layer+=1
			M.cBubble.vis_contents.Add(M.healthBar)
			M.cBubble.vis_contents.Add(M.kiBar)
			M.cBubble.vis_contents.Add(M.staminaBar)
			M.cBubble.transform*=bubScale
			var/icon/cB = new(M.cBubble.icon)
			var/bW = cB.Width()*bubScale
			var/bH = cB.Height()*bubScale
			var/icon/sB = new(M.healthBar.icon)
			var/sH = sB.Height()*statScale[2]
			M.healthBar.pixel_x = bW/2-sH-1
			M.kiBar.pixel_x = bW/2-sH-1
			M.staminaBar.pixel_x = bW/2-sH-1
			M.healthBar.pixel_y = bH-(12*bubScale)-sH
			M.kiBar.pixel_y = M.healthBar.pixel_y-sH
			M.staminaBar.pixel_y = M.healthBar.pixel_y-(sH*2)
		else
			var/HUD/tAnchor = new /HUD/screenAnchor("EAST-1.5", "NORTH-1")
			M.client.screen.Add(tAnchor)
			tAnchor.vis_contents.Add(M.tBubble)
			M.tBubble.pixel_y=16
			M.tHealth = new/HUD/statBar/healthBar(M, statScale[1], -statScale[2], 1)
			M.tStamina = new/HUD/statBar/stamBar(M, statScale[1], -statScale[2], 1)
			M.tKi = new/HUD/statBar/kiBar(M, statScale[1], -statScale[2], 1)
			M.tKi.layer+=1
			M.tBubble.vis_contents.Add(M.tHealth)
			M.tBubble.vis_contents.Add(M.tKi)
			M.tBubble.vis_contents.Add(M.tStamina)
			M.tBubble.transform*=(0-bubScale)
			var/icon/cB = new(M.cBubble.icon)
			var/bW = cB.Width()*bubScale
			var/bH = cB.Height()*bubScale
			var/icon/sB = new(M.healthBar.icon)
			var/sH = sB.Height()*statScale[2]
			M.tHealth.pixel_x = -bW-sH-1
			M.tKi.pixel_x = -bW-sH-1
			M.tStamina.pixel_x = -bW-sH-1
			M.tHealth.pixel_y = bH-(28*bubScale)-sH
			M.tKi.pixel_y = M.tHealth.pixel_y-sH
			M.tStamina.pixel_y = M.tHealth.pixel_y-(sH*2)

	var
		HUD/healthBar
		HUD/kiBar
		HUD/staminaBar
		HUD/cBubble = new /HUD/charBubble
		HUD/tHealth
		HUD/tKi
		HUD/tStamina
		HUD/tBubble = new /HUD/charBubble
		guiScale = 1


HUD
	parent_type = /obj
	plane = NEXUS_FIXED_HUD_PLANE
	charBubble
		icon = 'CharBubble.dmi'
		layer = OBJ_LAYER + EFFECTS_LAYER + MOB_LAYER + 1

	screenAnchor
		New(screenX, screenY=null)
			if(screenY) screen_loc="[screenX],[screenY]"
			else screen_loc="[screenX]"

	statBar
		var/getStat

		New(mob/U, trX, trY, t=0)
			var/matrix/M = matrix()
			M.Scale(trX, trY)
			src.transform = M
			Update(U, t)

		proc/Update(mob/U, t=0)
			var/stat=1, statmax=1, maxpct=100
			var/mob/M
			var/pct
			if(U) M = U
			if(t && M) M = M.Target
			if(M)
				switch(getStat)
					if("health")
						stat = M.Health
						statmax = 100
						maxpct = 200
					if("Ki")
						stat = M.Ki
						statmax = M.max_ki
						maxpct = 300
					if("stamina")
						stat = M.stamina
						statmax = M.max_stamina
				pct = (stat/statmax) * 100
				if(pct < 0) pct = 0
				if(pct > maxpct) pct = maxpct
				icon_state = "[round(pct,10)]"
			else icon_state = "100"
			spawn(1) Update(U, t)

		healthBar
			icon = 'Healthbar.dmi'
			icon_state = "100"
			getStat = "health"
		stamBar
			icon = 'Stambar.dmi'
			icon_state = "100"
			getStat = "stamina"
		kiBar
			icon = 'Kibar.dmi'
			icon_state = "100"
			getStat = "Ki"

proc/hudPercentage(value, maximum = 100)
	if(value == 1.#INF) return 100
	if(!nexusIsFiniteNumber(value) || !nexusIsFiniteNumber(maximum) || maximum <= 0) return 0
	return max(0, round(value / maximum * 100, 0.1))

proc/nexusIsFiniteNumber(value)
	return isnum(value) && value == value && value != 1.#INF && value != -1.#INF

proc/screenLocationPixels(screen_location)
	if(!istext(screen_location)) return
	var/list/coordinates = dd_text2list(screen_location, ",")
	if(coordinates.len < 2) return
	var/list/x_parts = dd_text2list(coordinates[1], ":")
	var/list/y_parts = dd_text2list(coordinates[2], ":")
	var/screen_x = (text2num(x_parts[1]) - 1) * world.icon_size
	var/screen_y = (text2num(y_parts[1]) - 1) * world.icon_size
	if(x_parts.len > 1) screen_x += text2num(x_parts[2])
	if(y_parts.len > 1) screen_y += text2num(y_parts[2])
	return list(screen_x, screen_y)

var/list/overhead_vital_icon_cache = list()
var/list/vitals_bar_icon_cache = list()
var/list/power_gauge_icon_cache = list()
var/icon/vitals_panel_icon
var/icon/active_modifiers_panel_icon

var/list/nexus_hud_modifier_order = list(
	"BP", "SPD", "REC", "REGEN", "KI", "STR", "END", "FOR", "RES", "OFF", "DEF", "ANGER", "PWR", "MELEE", "MASTERY", "MEDITATION")

proc/overheadHealthColor(health_percent)
	if(health_percent < 50) return "#ef4758"
	if(health_percent <= 60) return "#f2c94c"
	return "#46d369"

proc/getOverheadHealthIcon(health_percent)
	return getOverheadVitalIcon(health_percent, overheadHealthColor(health_percent))

proc/getOverheadVitalIcon(percent, accent_color)
	percent = Clamp(percent, 0, 100)
	var/fill_width = round(percent * 0.32)
	var/cache_key = "[accent_color]-[fill_width]"
	if(overhead_vital_icon_cache[cache_key]) return overhead_vital_icon_cache[cache_key]
	var/icon/vital_icon = icon('Healthbar.dmi', "100")
	vital_icon.Scale(32, 3)
	vital_icon.DrawBox("#21170f", 1, 1, 32, 3)
	if(fill_width) vital_icon.DrawBox(accent_color, 1, 1, fill_width, 3)
	overhead_vital_icon_cache[cache_key] = vital_icon
	return vital_icon

proc/getVitalsPanelIcon()
	if(vitals_panel_icon) return vitals_panel_icon
	vitals_panel_icon = icon('UserNamesBarsUi.png')
	vitals_panel_icon.Scale(296, 136)
	vitals_panel_icon.DrawBox(rgb(31, 23, 15, 232), 1, 1, 296, 136)
	vitals_panel_icon.DrawBox("#140e09", 1, 1, 296, 3)
	vitals_panel_icon.DrawBox("#140e09", 1, 134, 296, 136)
	vitals_panel_icon.DrawBox("#140e09", 1, 1, 3, 136)
	vitals_panel_icon.DrawBox("#140e09", 294, 1, 296, 136)
	vitals_panel_icon.DrawBox("#826039", 4, 4, 293, 4)
	vitals_panel_icon.DrawBox("#826039", 4, 132, 293, 132)
	for(var/bolt_x in list(6, 289))
		for(var/bolt_y in list(6, 128)) vitals_panel_icon.DrawBox("#c6a15c", bolt_x, bolt_y, bolt_x + 1, bolt_y + 1)
	return vitals_panel_icon

proc/getVitalsBarIcon(percent, accent_color)
	if(!nexusIsFiniteNumber(percent)) percent = 0
	percent = round(Clamp(percent, 0, 100))
	var/fill_width = round(percent * 1.6)
	var/cache_key = "[accent_color]-[fill_width]"
	if(vitals_bar_icon_cache[cache_key]) return vitals_bar_icon_cache[cache_key]
	var/icon/bar_icon = icon('UserNamesBarsUi.png')
	bar_icon.Scale(168, 19)
	bar_icon.DrawBox("#1a120c", 1, 1, 168, 19)
	bar_icon.DrawBox("#46321f", 5, 3, 164, 16)
	if(fill_width) bar_icon.DrawBox(accent_color, 5, 3, 4 + fill_width, 16)
	bar_icon.DrawBox(accent_color, 1, 1, 4, 19)
	vitals_bar_icon_cache[cache_key] = bar_icon
	return bar_icon

proc/getPowerGaugeIcon(percent, over_limit)
	if(!nexusIsFiniteNumber(percent)) percent = 0
	percent = round(Clamp(percent, 0, 100))
	var/fill_height = round(percent * 0.66)
	var/cache_key = "[over_limit]-[fill_height]"
	if(power_gauge_icon_cache[cache_key]) return power_gauge_icon_cache[cache_key]
	var/gauge_color = over_limit ? "#ff5c45" : "#b983ff"
	var/icon/gauge_icon = icon('UserNamesBarsUi.png')
	gauge_icon.Scale(7, 72)
	gauge_icon.DrawBox("#1a120c", 1, 1, 7, 72)
	gauge_icon.DrawBox("#5b4227", 3, 3, 5, 68)
	if(fill_height) gauge_icon.DrawBox(gauge_color, 3, 3, 5, 2 + fill_height)
	gauge_icon.DrawBox(over_limit ? "#ffb09f" : "#e8dcff", 1, 69, 7, 72)
	power_gauge_icon_cache[cache_key] = gauge_icon
	return gauge_icon

proc/getActiveModifiersPanelIcon()
	if(active_modifiers_panel_icon) return active_modifiers_panel_icon
	active_modifiers_panel_icon = icon('UserNamesBarsUi.png')
	active_modifiers_panel_icon.Scale(296, 38)
	active_modifiers_panel_icon.DrawBox(rgb(31, 23, 15, 242), 1, 1, 296, 38)
	active_modifiers_panel_icon.DrawBox("#140e09", 1, 1, 296, 3)
	active_modifiers_panel_icon.DrawBox("#140e09", 1, 36, 296, 38)
	active_modifiers_panel_icon.DrawBox("#140e09", 1, 1, 3, 38)
	active_modifiers_panel_icon.DrawBox("#140e09", 294, 1, 296, 38)
	active_modifiers_panel_icon.DrawBox("#826039", 4, 4, 293, 4)
	active_modifiers_panel_icon.DrawBox("#826039", 4, 34, 293, 34)
	active_modifiers_panel_icon.DrawBox("#c6a15c", 6, 6, 7, 7)
	active_modifiers_panel_icon.DrawBox("#c6a15c", 289, 6, 290, 7)
	return active_modifiers_panel_icon

proc/addNexusHudModifier(list/modifiers, stat_id, multiplier)
	if(!islist(modifiers) || !istext(stat_id) || !nexusIsFiniteNumber(multiplier) || multiplier <= 0) return
	var/current_multiplier = modifiers[stat_id]
	if(!nexusIsFiniteNumber(current_multiplier) || current_multiplier <= 0) current_multiplier = 1
	modifiers[stat_id] = current_multiplier * multiplier

proc/addNexusHudModifierName(list/names, modifier_name)
	if(!islist(names) || !modifier_name) return
	modifier_name = copytext("[modifier_name]", 1, 49)
	if(modifier_name && !(modifier_name in names)) names += modifier_name

proc/formatNexusHudMultiplier(multiplier)
	if(!nexusIsFiniteNumber(multiplier)) return "1x"
	return "[round(multiplier, 0.01)]x"

mob/proc/getNexusActiveHudModifiers()
	var/list/names = list()
	var/list/modifiers = list()
	var/active_bp_addition = 0
	var/primary_id = detectPrimaryTransformation()

	if(is_ussj)
		addNexusHudModifierName(names, "Ultra Super Saiyan")
	else if(primary_id == "alien_transform" && current_buff && current_buff.suffix)
		addNexusHudModifierName(names, current_buff.name)
	else if(primary_id)
		initializeNexusTransformationRegistry()
		var/datum/TransformationDefinition/transformation = nexus_transformation_registry[primary_id]
		addNexusHudModifierName(names, transformation ? transformation.display_name : primary_id)

	var/natural_bp = max(base_bp + hbtc_bp + unlockedBP, 1)
	if(ssj)
		var/form_bp_multiplier = (natural_bp * max(ssj_bp_mult, 0.01) + max(ssj_power(), 0)) / natural_bp
		addNexusHudModifier(modifiers, "BP", form_bp_multiplier)
	if(heran_transformed)
		addNexusHudModifier(modifiers, "BP", 1 + getActiveHeranTransformationBPAdd() / natural_bp)
	if(is_ssg) addNexusHudModifier(modifiers, "BP", ssjg_bp_mult)
	if(is_ssj_blue) addNexusHudModifier(modifiers, "BP", ssj_blue_mult)
	if(is_gold_form) addNexusHudModifier(modifiers, "BP", gold_form_mult)
	if(Form && Race == "Frost Lord")
		var/frost_base = max(bp_mult * natural_bp, 1)
		addNexusHudModifier(modifiers, "BP", 1 + max(Frost_Lord_Form_Addition(), 0) / frost_base)

	if(is_ussj)
		active_bp_addition += ussj_bp
		addNexusHudModifier(modifiers, "KI", ussj_ki)
		addNexusHudModifier(modifiers, "STR", ussj_str)
		addNexusHudModifier(modifiers, "END", ussj_dur)
		addNexusHudModifier(modifiers, "SPD", ussj_spd)
		addNexusHudModifier(modifiers, "RES", ussj_res)
	if(ssj == 4)
		addNexusHudModifier(modifiers, "SPD", ssj4_speed_mult)
		addNexusHudModifier(modifiers, "REGEN", ssj4_regen_mult)
		addNexusHudModifier(modifiers, "REC", ssj4_recov_mult)
	if(is_ssg)
		addNexusHudModifier(modifiers, "SPD", ssjg_speed_mult)
		addNexusHudModifier(modifiers, "DEF", ssjg_def_mult)
		addNexusHudModifier(modifiers, "FOR", ssjg_for_mult)
		addNexusHudModifier(modifiers, "RES", ssjg_res_mult)
		addNexusHudModifier(modifiers, "REGEN", ssjg_regen_mult)
		addNexusHudModifier(modifiers, "REC", ssjg_recov_mult)
	if(ultra_instinct)
		active_bp_addition += ui_bp_mult_add
		addNexusHudModifier(modifiers, "SPD", ultra_instinct_speed)
		addNexusHudModifier(modifiers, "OFF", ultra_instinct_acc)
		addNexusHudModifier(modifiers, "DEF", ultra_instinct_ref)

	if(using_giant_form)
		active_bp_addition += Race == "Makyo" ? 0.3 : 0.2
		if(Race != "Makyo")
			addNexusHudModifier(modifiers, "STR", 1.25)
			addNexusHudModifier(modifiers, "END", 1.25)
			addNexusHudModifier(modifiers, "RES", 1.25)
			addNexusHudModifier(modifiers, "SPD", 0.75)
			addNexusHudModifier(modifiers, "OFF", 0.75)
			addNexusHudModifier(modifiers, "DEF", 0.75)
	if(IsGreatApe())
		active_bp_addition += oozaruBPMultAdd
		addNexusHudModifier(modifiers, "STR", 1.3)
		addNexusHudModifier(modifiers, "END", 1.3)
		addNexusHudModifier(modifiers, "RES", 1.3)
		addNexusHudModifier(modifiers, "SPD", 0.1)
		addNexusHudModifier(modifiers, "DEF", 0.1)

	if(ismystic)
		addNexusHudModifierName(names, "Mystic")
		addNexusHudModifier(modifiers, "SPD", 1.1)
		addNexusHudModifier(modifiers, "PWR", 1.2)
		if(ssj && Class != "Legendary Saiyan") addNexusHudModifier(modifiers, "BP", 1.15)
	if(current_buff && current_buff.suffix)
		addNexusHudModifierName(names, current_buff.name)
		active_bp_addition += current_buff.buff_bp - 1
		addNexusHudModifier(modifiers, "KI", current_buff.buff_ki)
		addNexusHudModifier(modifiers, "STR", current_buff.buff_str)
		addNexusHudModifier(modifiers, "END", current_buff.buff_dur)
		addNexusHudModifier(modifiers, "SPD", current_buff.buff_spd)
		addNexusHudModifier(modifiers, "FOR", current_buff.buff_for)
		addNexusHudModifier(modifiers, "RES", current_buff.buff_res)
		addNexusHudModifier(modifiers, "OFF", current_buff.buff_off)
		addNexusHudModifier(modifiers, "DEF", current_buff.buff_def)
		addNexusHudModifier(modifiers, "REGEN", current_buff.buff_reg)
		addNexusHudModifier(modifiers, "REC", current_buff.buff_rec)
		if("transformation" in current_buff.buff_attributes)
			var/transform_base = max(bp_mult * natural_bp, 1)
			var/transform_power = buff_transform_bp / Clamp(Powerup_mult() ** 0.7, 1, 1.#INF)
			addNexusHudModifier(modifiers, "BP", 1 + max(transform_power, 0) / transform_base)

	if(limit_breaker_on)
		addNexusHudModifierName(names, "Limit Breaker")
		active_bp_addition += 0.5
		addNexusHudModifier(modifiers, "REGEN", 3)
		addNexusHudModifier(modifiers, "REC", 3)
		addNexusHudModifier(modifiers, "OFF", 3)
	if(third_eye)
		addNexusHudModifierName(names, "Third Eye")
		active_bp_addition += third_eye_bp_add
		addNexusHudModifier(modifiers, "MEDITATION", 2)
		addNexusHudModifier(modifiers, "MASTERY", thirdEyeMasteryMult)
	if(ismajin)
		addNexusHudModifierName(names, "Majin")
		active_bp_addition += majin_skill_bp_add
		addNexusHudModifier(modifiers, "ANGER", majin_skill_anger_mult)
	if(isFireFist)
		addNexusHudModifierName(names, "Fire Fist")
		addNexusHudModifier(modifiers, "MELEE", 1.2)
	if(God_Fist_level || super_God_Fist)
		addNexusHudModifierName(names, super_God_Fist ? "Super Kaioken" : "Kaioken [God_Fist_level]")
		if(super_God_Fist) addNexusHudModifier(modifiers, "BP", super_God_Fist_mult)
		else
			var/kaioken_base = max(bp_mult * natural_bp, 1)
			addNexusHudModifier(modifiers, "BP", 1 + max(God_Fist_bp() * God_FistMod, 0) / kaioken_base)
	if(Overdrive)
		addNexusHudModifierName(names, "Overdrive")
		if(cyber_bp) addNexusHudModifier(modifiers, "BP", 1.5)
	if(Roid_Power)
		addNexusHudModifierName(names, "Steroids")
		addNexusHudModifier(modifiers, "BP", Roid_Power + 1)

	if(active_bp_addition)
		var/base_bp_multiplier = bp_mult - active_bp_addition
		var/bp_ratio = base_bp_multiplier > 0 ? bp_mult / base_bp_multiplier : 1 + active_bp_addition
		addNexusHudModifier(modifiers, "BP", bp_ratio)
	if(IsGreatApe())
		var/ape_base = max(bp_mult * natural_bp, 1)
		addNexusHudModifier(modifiers, "BP", 1 + max(Great_Ape_power(), 0) / ape_base)

	return list("names" = names, "modifiers" = modifiers)

mob/proc/getNexusActiveHudModifierSummary(maximum_stats = 8)
	var/list/modifier_data = getNexusActiveHudModifiers()
	var/list/names = modifier_data["names"]
	var/list/modifiers = modifier_data["modifiers"]
	if(!names.len) return list("active" = FALSE, "title" = "", "first_row" = "", "second_row" = "")

	var/title = jointext(names, " + ")
	if(length(title) > 46) title = "[copytext(title, 1, 44)]..."
	var/list/stat_fragments = list()
	var/hidden_stats = 0
	for(var/stat_id in nexus_hud_modifier_order)
		var/multiplier = modifiers[stat_id]
		if(!nexusIsFiniteNumber(multiplier) || abs(multiplier - 1) < 0.005) continue
		if(stat_fragments.len < maximum_stats) stat_fragments += "[stat_id] [formatNexusHudMultiplier(multiplier)]"
		else hidden_stats++
	if(hidden_stats && stat_fragments.len)
		stat_fragments[stat_fragments.len] = "+[hidden_stats + 1] MORE"

	var/split_at = min(4, stat_fragments.len)
	var/list/first_fragments = list()
	var/list/second_fragments = list()
	for(var/index in 1 to stat_fragments.len)
		if(index <= split_at) first_fragments += stat_fragments[index]
		else second_fragments += stat_fragments[index]
	return list(
		"active" = TRUE,
		"title" = title,
		"first_row" = jointext(first_fragments, " | "),
		"second_row" = jointext(second_fragments, " | "))

mob/var/tmp/obj/NexusHud/OverheadHealthBar/overhead_health_hud
mob/var/tmp/obj/NexusHud/OverheadHealthBar/Energy/overhead_energy_hud
mob/var/tmp/obj/NexusHud/OverheadHealthBar/Willpower/overhead_willpower_hud
mob/var/tmp/nexus_last_overhead_vitals_signature
client/var/tmp/obj/NexusHud/VitalsPanel/main_vitals_hud

mob/var
	nexus_overhead_vitals_offset_x = 0
	nexus_overhead_vitals_offset_y = 0
	nexus_main_vitals_x = 8
	nexus_main_vitals_y = 8

proc/normalizeNexusHudOffset(value)
	if(!nexusIsFiniteNumber(value)) return 0
	return round(Clamp(value, -128, 128))

proc/getNexusOverheadVitalsBasePixelX(mob/owner)
	if(!owner) return 0
	return normalizeNexusHudOffset(owner.nexus_overhead_vitals_offset_x)

proc/getNexusOverheadVitalsBasePixelY(mob/owner)
	var/vertical_offset = owner ? normalizeNexusHudOffset(owner.nexus_overhead_vitals_offset_y) : 0
	// Energy is the bottom row; -12 keeps the complete three-row stack below the sprite origin.
	return -12 + vertical_offset

proc/getNexusTypingIndicatorPixelY(mob/owner)
	// KhunTyping's visible ten pixels occupy the top of its 32px cell; keep them below Say text.
	return getNexusOverheadFeedbackPixelY(owner) - 34

proc/getNexusOverheadFeedbackPixelY(mob/owner)
	var/icon_height = owner && owner.icon ? max(32, GetHeight(owner.icon)) : 32
	// Reserve the typing bubble plus two clear pixels between the sprite, typing, and Say text.
	return icon_height + 14

proc/getNexusOverheadPercentagePixelY(mob/owner)
	// The 12px Sense readout ends one clear pixel below the bottom Energy row.
	return getNexusOverheadVitalsBasePixelY(owner) - 13

mob/proc/setNexusOverheadVitalsOffset(new_x, new_y)
	nexus_overhead_vitals_offset_x = normalizeNexusHudOffset(new_x)
	nexus_overhead_vitals_offset_y = normalizeNexusHudOffset(new_y)
	updateOverheadHealthHud()

mob/proc/setNexusMainVitalsPosition(new_x, new_y)
	nexus_main_vitals_x = max(0, round(new_x))
	nexus_main_vitals_y = max(0, round(new_y))
	if(client && client.main_vitals_hud)
		client.main_vitals_hud.setScreenPosition(nexus_main_vitals_x, nexus_main_vitals_y, FALSE)

mob/Write(savefile/save_file)
	var/list/detached_hud = list()
	for(var/obj/NexusHud/OverheadHealthBar/hud_bar in list(overhead_health_hud, overhead_energy_hud, overhead_willpower_hud))
		if(hud_bar && (hud_bar in vis_contents))
			vis_contents -= hud_bar
			detached_hud += hud_bar
	. = ..()
	for(var/obj/NexusHud/OverheadHealthBar/hud_bar in detached_hud)
		if(hud_bar) vis_contents += hud_bar

mob/proc/shouldShowOverheadHealthHud()
	return client && playerCharacter

mob/proc/initializeVitalsHud()
	if(!shouldShowOverheadHealthHud()) return
	if(!overhead_health_hud)
		overhead_health_hud = new
		overhead_health_hud.initialize(src)
	if(!overhead_energy_hud)
		overhead_energy_hud = new /obj/NexusHud/OverheadHealthBar/Energy
		overhead_energy_hud.initialize(src)
	if(!overhead_willpower_hud)
		overhead_willpower_hud = new /obj/NexusHud/OverheadHealthBar/Willpower
		overhead_willpower_hud.initialize(src)
	for(var/obj/NexusHud/OverheadHealthBar/hud_bar in list(overhead_health_hud, overhead_energy_hud, overhead_willpower_hud))
		if(!(hud_bar in vis_contents)) vis_contents += hud_bar
	updateOverheadHealthHud()
	initializeMainVitalsHud()

mob/proc/initializeMainVitalsHud()
	if(!client || !playerCharacter) return
	winset(src, "Bars", "is-visible=false")
	if(!client.main_vitals_hud)
		client.main_vitals_hud = new
		client.main_vitals_hud.initialize(src)
	if(client.show_bars)
		if(!(client.main_vitals_hud in client.screen)) client.screen += client.main_vitals_hud
	else client.screen -= client.main_vitals_hud
	client.main_vitals_hud.update(src)

mob/proc/updateMainVitalsHud()
	if(!client || !playerCharacter) return
	if(!client.main_vitals_hud) initializeMainVitalsHud()
	if(client.main_vitals_hud) client.main_vitals_hud.update(src)
	refreshActionHud()

mob/proc/setVitalsHudVisibility(visible)
	if(!client) return
	winset(src, "Bars", "is-visible=false")
	if(visible)
		if(!client.main_vitals_hud) initializeMainVitalsHud()
		if(client.main_vitals_hud && !(client.main_vitals_hud in client.screen)) client.screen += client.main_vitals_hud
	else if(client.main_vitals_hud) client.screen -= client.main_vitals_hud

mob/proc/updateOverheadHealthHud()
	if(!shouldShowOverheadHealthHud()) return
	if(!overhead_health_hud || !overhead_energy_hud || !overhead_willpower_hud) initializeVitalsHud()
	var/vitals_signature = "[hudPercentage(Health)]|[hudPercentage(Ki, max_ki)]|[hudPercentage(willpower, getMaxWillpower())]|[getNexusOverheadVitalsBasePixelX(src)]|[getNexusOverheadVitalsBasePixelY(src)]"
	if(vitals_signature == nexus_last_overhead_vitals_signature) return
	nexus_last_overhead_vitals_signature = vitals_signature
	if(overhead_health_hud) overhead_health_hud.update(src)
	if(overhead_energy_hud) overhead_energy_hud.update(src)
	if(overhead_willpower_hud) overhead_willpower_hud.update(src)

mob/proc/removeVitalsHud()
	nexus_last_overhead_vitals_signature = null
	if(overhead_health_hud)
		vis_contents -= overhead_health_hud
		del(overhead_health_hud)
		overhead_health_hud = null
	if(overhead_energy_hud)
		vis_contents -= overhead_energy_hud
		del(overhead_energy_hud)
		overhead_energy_hud = null
	if(overhead_willpower_hud)
		vis_contents -= overhead_willpower_hud
		del(overhead_willpower_hud)
		overhead_willpower_hud = null
	if(client && client.main_vitals_hud)
		client.screen -= client.main_vitals_hud
		del(client.main_vitals_hud)
		client.main_vitals_hud = null
	removeActionHud()

obj/NexusHud
	Savable = 0
	Grabbable = 0
	attackable = 0
	density = 0
	mouse_opacity = 0
	plane = NEXUS_FIXED_HUD_PLANE
	layer = 99

	OverheadHealthBar
		plane = NEXUS_WORLD_OVERLAY_PLANE
		pixel_x = 0
		var/tmp/owner_icon
		var/row_offset = 4

		proc/initialize(mob/owner)
			updatePosition(owner)
			if(owner) owner_icon = owner.icon
			update(owner)

		proc/updatePosition(mob/owner)
			pixel_x = getNexusOverheadVitalsBasePixelX(owner)
			pixel_y = getNexusOverheadVitalsBasePixelY(owner) + row_offset

		proc/update(mob/owner)
			if(!owner) return
			updatePosition(owner)
			if(istype(src, /obj/NexusHud/OverheadHealthBar/Energy))
				icon = getOverheadVitalIcon(hudPercentage(owner.Ki, owner.max_ki), "#37cfff")
			else if(istype(src, /obj/NexusHud/OverheadHealthBar/Willpower))
				icon = getOverheadVitalIcon(hudPercentage(owner.willpower, owner.getMaxWillpower()), "#b983ff")
			else icon = getOverheadHealthIcon(hudPercentage(owner.Health))
			if(owner.icon && owner.icon != owner_icon) owner_icon = owner.icon

		Energy
			row_offset = 0

		Willpower
			row_offset = 8

	VitalsPanel
		alpha = 255
		mouse_opacity = 2
		screen_loc = "LEFT:8,BOTTOM:8"
		var/tmp/mob/panel_owner
		var/tmp/screen_x = 8
		var/tmp/screen_y = 8
		var/tmp/drag_mouse_x
		var/tmp/drag_mouse_y
		var/tmp/drag_start_x
		var/tmp/drag_start_y
		var/tmp/obj/NexusHud/CharacterPortrait/portrait
		var/tmp/obj/NexusHud/VitalRow/willpower_row
		var/tmp/obj/NexusHud/VitalRow/health_row
		var/tmp/obj/NexusHud/VitalRow/energy_row
		var/tmp/obj/NexusHud/VitalRow/stamina_row
		var/tmp/obj/NexusHud/PowerGauge/left_power_gauge
		var/tmp/obj/NexusHud/PowerGauge/right_power_gauge
		var/tmp/obj/NexusHud/PowerReadout/power_readout
		var/tmp/obj/NexusHud/ActiveModifiersReadout/active_modifiers_readout

		proc/initialize(mob/owner)
			panel_owner = owner
			if(owner) setScreenPosition(owner.nexus_main_vitals_x, owner.nexus_main_vitals_y, FALSE)
			icon = getVitalsPanelIcon()
			portrait = new
			willpower_row = new /obj/NexusHud/VitalRow/Willpower
			health_row = new /obj/NexusHud/VitalRow/Health
			energy_row = new /obj/NexusHud/VitalRow/Energy
			stamina_row = new /obj/NexusHud/VitalRow/Stamina
			left_power_gauge = new /obj/NexusHud/PowerGauge/Left
			right_power_gauge = new /obj/NexusHud/PowerGauge/Right
			power_readout = new
			active_modifiers_readout = new
			vis_contents.Add(portrait, left_power_gauge, right_power_gauge, power_readout, willpower_row, health_row, energy_row, stamina_row, active_modifiers_readout)
			update(owner)

		proc/update(mob/owner)
			if(!owner || !portrait) return
			portrait.update(owner)
			var/max_willpower = owner.getMaxWillpower()
			var/willpower_percent = hudPercentage(owner.willpower, max_willpower)
			var/health_percent = hudPercentage(owner.Health)
			var/energy_percent = hudPercentage(owner.Ki, owner.max_ki)
			var/stamina_percent = hudPercentage(owner.stamina, owner.max_stamina)
			var/energy_current = nexusIsFiniteNumber(owner.Ki) ? round(max(owner.Ki, 0)) : 0
			var/current_power = nexusIsFiniteNumber(owner.BPpcnt) ? max(owner.BPpcnt, 0) : 0
			var/soft_cap_excess = owner.powerup_soft_cap()
			if(!nexusIsFiniteNumber(soft_cap_excess) || soft_cap_excess <= 0) soft_cap_excess = 1
			var/soft_cap = 100 + soft_cap_excess
			var/over_limit = current_power > soft_cap
			var/gauge_percent = Clamp((current_power - 100) / soft_cap_excess * 100, 0, 100)
			willpower_row.update("WILLPOWER", willpower_percent, "[willpower_percent]%", "#b983ff")
			health_row.update("HEALTH", health_percent, "[health_percent]%", "#ff4d6d")
			energy_row.update("ENERGY", energy_percent, "([energy_current]) [energy_percent]%", "#37cfff")
			stamina_row.update("STAMINA", stamina_percent, "[stamina_percent]%", "#f6c453")
			left_power_gauge.update(gauge_percent, over_limit)
			right_power_gauge.update(gauge_percent, over_limit)
			power_readout.update(round(current_power, 0.1), round(soft_cap, 0.1), over_limit)
			active_modifiers_readout.update(owner)

		proc/setScreenPosition(new_x, new_y, update_owner = TRUE)
			screen_x = max(0, round(new_x))
			screen_y = max(0, round(new_y))
			screen_loc = "LEFT:[screen_x],BOTTOM:[screen_y]"
			if(update_owner && panel_owner)
				panel_owner.nexus_main_vitals_x = screen_x
				panel_owner.nexus_main_vitals_y = screen_y

		proc/moveToMouse(screen_location)
			var/list/screen_pixels = screenLocationPixels(screen_location)
			if(!screen_pixels) return
			setScreenPosition(drag_start_x + screen_pixels[1] - drag_mouse_x, drag_start_y + screen_pixels[2] - drag_mouse_y)

		MouseDown(location, control, params)
			var/list/mouse_params = params2list(params)
			var/list/screen_pixels = screenLocationPixels(mouse_params["screen-loc"])
			if(!screen_pixels) return
			drag_mouse_x = screen_pixels[1]
			drag_mouse_y = screen_pixels[2]
			drag_start_x = screen_x
			drag_start_y = screen_y

		MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
			var/list/mouse_params = params2list(params)
			moveToMouse(mouse_params["screen-loc"])

		MouseDrop(over_object, src_location, over_location, src_control, over_control, params)
			var/list/mouse_params = params2list(params)
			moveToMouse(mouse_params["screen-loc"])
			if(panel_owner) panel_owner.save_player_settings()

		Del()
			for(var/obj/hud_object in vis_contents) del(hud_object)
			panel_owner = null
			. = ..()

	CharacterPortrait
		pixel_x = 40
		pixel_y = 45
		layer = 101

		proc/update(mob/owner)
			appearance = owner.appearance
			plane = initial(plane)
			layer = 101
			icon_w = 0
			icon_z = 0
			pixel_w = 0
			pixel_z = 0
			pixel_x = 40
			pixel_y = 45
			alpha = 255
			mouse_opacity = 0
			invisibility = 0
			dir = SOUTH
			underlays = null
			appearance_flags = RESET_ALPHA | PIXEL_SCALE | KEEP_TOGETHER
			var/matrix/portrait_transform = matrix()
			portrait_transform.Scale(1.9, 2.05)
			transform = portrait_transform

	PowerGauge
		pixel_y = 40
		layer = 103
		appearance_flags = RESET_ALPHA

		proc/update(percent, over_limit)
			icon = getPowerGaugeIcon(percent, over_limit)

		Left
			pixel_x = 4

		Right
			pixel_x = 105

	PowerReadout
		pixel_x = 8
		pixel_y = 6
		layer = 104
		appearance_flags = RESET_ALPHA
		maptext_width = 99
		maptext_height = 16

		proc/update(power_percent, soft_cap, over_limit)
			var/status_color = over_limit ? "#ff705c" : "#cda8ff"
			maptext = "<div style='font-family:Courier New;text-align:center;text-shadow:1px 1px #000'><b style='font-size:11px;color:[status_color]'>[power_percent]%</b></div>"

	ActiveModifiersReadout
		pixel_x = 0
		pixel_y = 140
		layer = 105
		appearance_flags = RESET_ALPHA
		var/tmp/obj/NexusHud/ActiveModifierText/header_text
		var/tmp/obj/NexusHud/ActiveModifierText/first_row_text
		var/tmp/obj/NexusHud/ActiveModifierText/second_row_text

		New()
			. = ..()
			icon = getActiveModifiersPanelIcon()
			header_text = new /obj/NexusHud/ActiveModifierText/Header
			first_row_text = new /obj/NexusHud/ActiveModifierText/FirstRow
			second_row_text = new /obj/NexusHud/ActiveModifierText/SecondRow
			vis_contents.Add(header_text, first_row_text, second_row_text)
			setVisible(FALSE)

		proc/setVisible(visible)
			var/new_alpha = visible ? 255 : 0
			alpha = new_alpha
			if(header_text) header_text.alpha = new_alpha
			if(first_row_text) first_row_text.alpha = new_alpha
			if(second_row_text) second_row_text.alpha = new_alpha

		proc/update(mob/owner)
			var/list/summary = owner.getNexusActiveHudModifierSummary()
			if(!summary["active"])
				setVisible(FALSE)
				if(header_text) header_text.setText("")
				if(first_row_text) first_row_text.setText("")
				if(second_row_text) second_row_text.setText("")
				return
			setVisible(TRUE)
			header_text.setText("BUFFS / [summary["title"]]")
			first_row_text.setText(summary["first_row"])
			second_row_text.setText(summary["second_row"])

		Del()
			if(header_text) del(header_text)
			if(first_row_text) del(first_row_text)
			if(second_row_text) del(second_row_text)
			. = ..()

	ActiveModifierText
		pixel_x = 0
		layer = 106
		appearance_flags = RESET_ALPHA
		maptext_x = 10
		maptext_width = 276
		maptext_height = 9
		var/text_color = "#cda8ff"
		var/font_size = 7
		var/font_weight = "normal"

		proc/setText(value)
			var/safe_value = html_encode("[value]")
			maptext = "<span style='font-family:Courier New;font-size:[font_size]px;font-weight:[font_weight];color:[text_color];white-space:nowrap;text-shadow:1px 1px #000'>[safe_value]</span>"

		Header
			pixel_y = 25
			text_color = "#f2d79e"
			font_weight = "bold"

		FirstRow
			pixel_y = 14

		SecondRow
			pixel_y = 4

	VitalDetail
		pixel_x = 52
		pixel_y = 4
		layer = 103
		appearance_flags = RESET_ALPHA
		maptext_width = 108
		maptext_height = 11

	VitalRow
		maptext_x = 6
		maptext_y = 4
		maptext_width = 52
		maptext_height = 11
		pixel_x = 120
		layer = 102
		appearance_flags = RESET_ALPHA
		var/tmp/obj/NexusHud/VitalDetail/detail_text
		var/detail_alignment = "right"

		New()
			. = ..()
			detail_text = new
			vis_contents += detail_text
			switch(type)
				if(/obj/NexusHud/VitalRow/Willpower) pixel_y = 111
				if(/obj/NexusHud/VitalRow/Health) pixel_y = 85
				if(/obj/NexusHud/VitalRow/Energy) pixel_y = 59
				if(/obj/NexusHud/VitalRow/Stamina) pixel_y = 33

		proc/update(label, percent, detail, accent_color)
			icon = getVitalsBarIcon(percent, accent_color)
			maptext = "<span style='font-family:Courier New;font-size:8px;font-weight:bold;color:#f0dbaf;white-space:nowrap;text-shadow:1px 1px #000'>[label]</span>"
			detail_text.maptext = "<div style='font-family:Courier New;font-size:8px;font-weight:bold;color:#f0dbaf;text-align:[detail_alignment];white-space:nowrap;text-shadow:1px 1px #000'>[detail]</div>"

		Del()
			if(detail_text) del(detail_text)
			. = ..()

		Willpower
		Health
		Energy
			detail_alignment = "right"
		Stamina
