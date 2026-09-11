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
		icon = 'src/Icons/UI/CharBubble.dmi'
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
			icon = 'src/Icons/UI/Healthbar.dmi'
			icon_state = "100"
			getStat = "health"
		stamBar
			icon = 'src/Icons/UI/Stambar.dmi'
			icon_state = "100"
			getStat = "stamina"
		kiBar
			icon = 'src/Icons/UI/Kibar.dmi'
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
var/list/vitals_panel_icon_cache = list()
var/list/active_modifiers_panel_icon_cache = list()

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
	var/icon/vital_icon = icon('src/Icons/UI/Healthbar.dmi', "100")
	vital_icon.Scale(32, 3)
	vital_icon.DrawBox("#21170f", 1, 1, 32, 3)
	if(fill_width) vital_icon.DrawBox(accent_color, 1, 1, fill_width, 3)
	overhead_vital_icon_cache[cache_key] = vital_icon
	return vital_icon

// Draw at the final pixel size. Scaling a KEEP_TOGETHER group rasterizes its text.
proc/createNexusVitalsBackdrop(panel_width, panel_height, panel_alpha)
	var/icon/panel_icon = icon('src/Icons/Unsorted/UserNamesBarsUi.png')
	panel_icon.Scale(panel_width, panel_height)
	panel_icon.DrawBox(rgb(31, 23, 15, panel_alpha), 1, 1, panel_width, panel_height)
	panel_icon.DrawBox("#140e09", 1, 1, panel_width, 2)
	panel_icon.DrawBox("#140e09", 1, panel_height - 1, panel_width, panel_height)
	panel_icon.DrawBox("#140e09", 1, 1, 2, panel_height)
	panel_icon.DrawBox("#140e09", panel_width - 1, 1, panel_width, panel_height)
	panel_icon.DrawBox("#826039", 3, 3, panel_width - 2, 3)
	panel_icon.DrawBox("#826039", 3, panel_height - 2, panel_width - 2, panel_height - 2)
	for(var/bolt_x in list(5, panel_width - 5))
		for(var/bolt_y in list(5, panel_height - 5)) panel_icon.DrawBox("#c6a15c", bolt_x, bolt_y, bolt_x, bolt_y)
	return panel_icon

proc/getVitalsPanelIcon(scale = 1)
	var/cache_key = "[scale]"
	if(!vitals_panel_icon_cache[cache_key])
		vitals_panel_icon_cache[cache_key] = createNexusVitalsBackdrop(round(296 * scale), round(136 * scale), 232)
	return vitals_panel_icon_cache[cache_key]

proc/getVitalsBarIcon(percent, accent_color, scale = 1)
	if(!nexusIsFiniteNumber(percent)) percent = 0
	percent = round(Clamp(percent, 0, 100))
	var/bar_width = round(168 * scale)
	var/bar_height = max(13, round(19 * scale))
	var/inset = max(2, round(4 * scale))
	var/fill_width = round(percent / 100 * (bar_width - 2 * inset))
	var/cache_key = "[accent_color]-[scale]-[fill_width]"
	if(vitals_bar_icon_cache[cache_key]) return vitals_bar_icon_cache[cache_key]
	var/icon/bar_icon = icon('src/Icons/Unsorted/UserNamesBarsUi.png')
	bar_icon.Scale(bar_width, bar_height)
	bar_icon.DrawBox("#1a120c", 1, 1, bar_width, bar_height)
	bar_icon.DrawBox("#46321f", inset + 1, 3, bar_width - inset, bar_height - 3)
	if(fill_width) bar_icon.DrawBox(accent_color, inset + 1, 3, inset + fill_width, bar_height - 3)
	bar_icon.DrawBox(accent_color, 1, 1, inset, bar_height)
	vitals_bar_icon_cache[cache_key] = bar_icon
	return bar_icon

proc/getPowerGaugeIcon(percent, over_limit, scale = 1)
	if(!nexusIsFiniteNumber(percent)) percent = 0
	percent = round(Clamp(percent, 0, 100))
	var/gauge_width = max(4, round(7 * scale))
	var/gauge_height = round(72 * scale)
	var/fill_height = round(percent / 100 * (gauge_height - 6))
	var/cache_key = "[over_limit]-[scale]-[fill_height]"
	if(power_gauge_icon_cache[cache_key]) return power_gauge_icon_cache[cache_key]
	var/gauge_color = over_limit ? "#ff5c45" : "#b983ff"
	var/icon/gauge_icon = icon('src/Icons/Unsorted/UserNamesBarsUi.png')
	gauge_icon.Scale(gauge_width, gauge_height)
	gauge_icon.DrawBox("#1a120c", 1, 1, gauge_width, gauge_height)
	gauge_icon.DrawBox("#5b4227", 2, 3, gauge_width - 1, gauge_height - 4)
	if(fill_height) gauge_icon.DrawBox(gauge_color, 2, 3, gauge_width - 1, 2 + fill_height)
	gauge_icon.DrawBox(over_limit ? "#ffb09f" : "#e8dcff", 1, gauge_height - 3, gauge_width, gauge_height)
	power_gauge_icon_cache[cache_key] = gauge_icon
	return gauge_icon

proc/getNexusVitalsFontSize(scale)
	return scale < 0.75 ? 8 : (scale >= 1.5 ? 16 : 12)

proc/getActiveModifiersPanelIcon(scale = 1)
	var/cache_key = "[scale]"
	if(!active_modifiers_panel_icon_cache[cache_key])
		var/panel_height = 3 * (getNexusVitalsFontSize(scale) + 4) + 8
		active_modifiers_panel_icon_cache[cache_key] = createNexusVitalsBackdrop(round(296 * scale), panel_height, 242)
	return active_modifiers_panel_icon_cache[cache_key]

proc/getNexusHudEnergyText(amount, percent, width)
	var/full_text = "([amount]) [percent]%"
	if(measureNexusHudText(full_text,8)+1 <= width) return full_text
	var/shortest_text = full_text
	var/list/units = list("T" = 1.0e12,"B" = 1.0e9,"M" = 1.0e6,"K" = 1000)
	for(var/unit in units)
		if(amount < units[unit]) continue
		// A fractional suffix can still be too wide at 50%; reserve the entire percentage.
		for(var/precision in list(0.1,1))
			var/compact_text = "([round(amount/units[unit],precision)][unit]) [percent]%"
			if(measureNexusHudText(compact_text,8)+1 <= width) return compact_text
			if(measureNexusHudText(compact_text,8) < measureNexusHudText(shortest_text,8)) shortest_text = compact_text
	return shortest_text

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

mob/proc/getNexusActiveHudModifierSummary(maximum_stats = 8, maximum_columns = 46)
	var/list/modifier_data = getNexusActiveHudModifiers()
	var/list/names = modifier_data["names"]
	var/list/modifiers = modifier_data["modifiers"]
	if(!names.len) return list("active" = FALSE, "title" = "", "first_row" = "", "second_row" = "")

	var/title = jointext(names, " + ")
	var/title_columns = max(12, maximum_columns - 8)
	if(length(title) > title_columns) title = "[copytext(title, 1, title_columns - 2)]..."
	var/list/stat_fragments = list()
	var/hidden_stats = 0
	for(var/stat_id in nexus_hud_modifier_order)
		var/multiplier = modifiers[stat_id]
		if(!nexusIsFiniteNumber(multiplier) || abs(multiplier - 1) < 0.005) continue
		if(stat_fragments.len < maximum_stats) stat_fragments += "[stat_id] [formatNexusHudMultiplier(multiplier)]"
		else hidden_stats++
	var/list/first_fragments = list()
	var/list/second_fragments = list()
	var/list/current_row = first_fragments
	for(var/fragment in stat_fragments)
		var/row_width = length(jointext(current_row, " | "))
		if(current_row.len && (current_row.len >= 4 || row_width + 3 + length(fragment) > maximum_columns)) current_row = second_fragments
		row_width = length(jointext(current_row, " | "))
		if(row_width + (current_row.len ? 3 : 0) + length(fragment) <= maximum_columns) current_row += fragment
		else hidden_stats++
	if(hidden_stats)
		while(second_fragments.len && length(jointext(second_fragments, " | ")) + 3 + length("+[hidden_stats] MORE") > maximum_columns)
			second_fragments.Cut(second_fragments.len)
			hidden_stats++
		second_fragments += "+[hidden_stats] MORE"
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
	nexus_main_vitals_x = 0
	nexus_main_vitals_y = 0
	nexus_main_vitals_scale = 75

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

mob/proc/setNexusMainVitalsScale(value)
	nexus_main_vitals_scale = Clamp(round(classicNumber(value, 75)), 50, 150)
	if(client && client.main_vitals_hud) client.main_vitals_hud.applyScale(nexus_main_vitals_scale)

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
	appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM

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
		appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM
		alpha = 255
		mouse_opacity = 2
		screen_loc = "LEFT:0,BOTTOM:0"
		var/tmp/mob/panel_owner
		var/tmp/hud_scale = 0
		var/tmp/screen_x = 0
		var/tmp/screen_y = 0
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
			applyScale(owner.nexus_main_vitals_scale, FALSE)
			portrait.update(owner, hud_scale)
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
			willpower_row.update("WILLPOWER", willpower_percent, "[willpower_percent]%", "#b983ff", hud_scale)
			health_row.update("HEALTH", health_percent, "[health_percent]%", "#ff4d6d", hud_scale)
			energy_row.update("ENERGY", energy_percent, "([energy_current]) [energy_percent]%", "#37cfff", hud_scale, energy_current)
			stamina_row.update("STAMINA", stamina_percent, "[stamina_percent]%", "#f6c453", hud_scale)
			left_power_gauge.update(gauge_percent, over_limit, hud_scale)
			right_power_gauge.update(gauge_percent, over_limit, hud_scale)
			power_readout.update(round(current_power, 0.1), round(soft_cap, 0.1), over_limit, hud_scale)
			active_modifiers_readout.update(owner)

		proc/applyScale(percent, refresh = TRUE)
			var/scale = Clamp(round(classicNumber(percent, 75)), 50, 150) / 100
			if(hud_scale == scale || !portrait) return
			hud_scale = scale
			transform = null
			pixel_x = 0
			pixel_y = 0
			icon = getVitalsPanelIcon(scale)
			left_power_gauge.pixel_x = round(4 * scale)
			right_power_gauge.pixel_x = round(105 * scale)
			left_power_gauge.pixel_y = round(40 * scale)
			right_power_gauge.pixel_y = round(40 * scale)
			power_readout.pixel_x = round(8 * scale)
			power_readout.pixel_y = max(4, round(6 * scale))
			power_readout.maptext_width = round(99 * scale)
			power_readout.maptext_height = getNexusVitalsFontSize(scale) + 4
			willpower_row.applyScale(scale, 111)
			health_row.applyScale(scale, 85)
			energy_row.applyScale(scale, 59)
			stamina_row.applyScale(scale, 33)
			active_modifiers_readout.applyScale(scale)
			if(refresh && panel_owner) update(panel_owner)

		DblClick()
			if(usr == panel_owner) panel_owner.showClassicWidget("stats")

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

		proc/update(mob/owner, scale = 1)
			appearance = owner.appearance
			plane = initial(plane)
			layer = 101
			icon_w = 0
			icon_z = 0
			pixel_w = 0
			pixel_z = 0
			// The icon's transform is centered on its original 32px footprint.
			pixel_x = round(56 * scale - 16)
			pixel_y = round(61 * scale - 16)
			alpha = 255
			mouse_opacity = 0
			invisibility = 0
			dir = SOUTH
			underlays = null
			appearance_flags = RESET_ALPHA | RESET_TRANSFORM | KEEP_TOGETHER
			var/matrix/portrait_transform = matrix()
			portrait_transform.Scale(1.9 * scale, 2.05 * scale)
			transform = portrait_transform

	PowerGauge
		pixel_y = 40
		layer = 103
		appearance_flags = RESET_ALPHA | RESET_TRANSFORM

		proc/update(percent, over_limit, scale = 1)
			icon = getPowerGaugeIcon(percent, over_limit, scale)

		Left
			pixel_x = 4

		Right
			pixel_x = 105

	PowerReadout
		parent_type = /obj/NexusHudBitmapText
		pixel_x = 8
		pixel_y = 6
		layer = 104
		appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | PIXEL_SCALE
		maptext_width = 99
		maptext_height = 16

		proc/update(power_percent, soft_cap, over_limit, scale = 1)
			var/status_color = over_limit ? "#ff705c" : "#cda8ff"
			setBitmapText("[power_percent]%", getNexusVitalsFontSize(scale), status_color, "center", TRUE)

	ActiveModifiersReadout
		pixel_x = 0
		pixel_y = 140
		layer = 105
		appearance_flags = RESET_ALPHA | RESET_TRANSFORM
		var/tmp/obj/NexusHud/ActiveModifierText/header_text
		var/tmp/obj/NexusHud/ActiveModifierText/first_row_text
		var/tmp/obj/NexusHud/ActiveModifierText/second_row_text
		var/tmp/maximum_columns = 46

		New()
			. = ..()
			icon = getActiveModifiersPanelIcon()
			header_text = new /obj/NexusHud/ActiveModifierText/Header
			first_row_text = new /obj/NexusHud/ActiveModifierText/FirstRow
			second_row_text = new /obj/NexusHud/ActiveModifierText/SecondRow
			vis_contents.Add(header_text, first_row_text, second_row_text)
			applyScale(1)
			setVisible(FALSE)

		proc/applyScale(scale)
			pixel_y = round(136 * scale) + 4
			icon = getActiveModifiersPanelIcon(scale)
			var/font_size = getNexusVitalsFontSize(scale)
			var/row_height = font_size + 4
			for(var/obj/NexusHud/ActiveModifierText/text_row in vis_contents)
				text_row.font_size = font_size
				text_row.pixel_x = 8
				text_row.maptext_x = 0
				text_row.maptext_width = round(296 * scale) - 16
				text_row.maptext_height = row_height
			maximum_columns = max(20, round(header_text.maptext_width / measureNexusHudText("M",font_size)))
			header_text.pixel_y = 4 + 2 * row_height
			first_row_text.pixel_y = 4 + row_height
			second_row_text.pixel_y = 4

		proc/setVisible(visible)
			var/new_alpha = visible ? 255 : 0
			alpha = new_alpha
			if(header_text) header_text.alpha = new_alpha
			if(first_row_text) first_row_text.alpha = new_alpha
			if(second_row_text) second_row_text.alpha = new_alpha

		proc/update(mob/owner)
			if(!owner) return
			var/list/summary = owner.getNexusActiveHudModifierSummary(8, maximum_columns)
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
		parent_type = /obj/NexusHudBitmapText
		pixel_x = 0
		layer = 106
		appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | PIXEL_SCALE
		maptext_x = 10
		maptext_width = 276
		maptext_height = 15
		var/text_color = "#cda8ff"
		var/font_size = 11
		var/font_weight = "normal"

		proc/setText(value)
			setBitmapText(value, font_size, text_color)

		Header
			pixel_y = 25
			text_color = "#f2d79e"
			font_weight = "bold"

		FirstRow
			pixel_y = 14

		SecondRow
			pixel_y = 4

	VitalDetail
		parent_type = /obj/NexusHudBitmapText
		pixel_x = 52
		pixel_y = 4
		layer = 103
		appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | PIXEL_SCALE
		maptext_width = 108
		maptext_height = 11

	VitalRow
		maptext_x = 6
		maptext_y = 4
		maptext_width = 52
		maptext_height = 11
		pixel_x = 120
		layer = 102
		appearance_flags = RESET_ALPHA | RESET_TRANSFORM
		var/tmp/obj/NexusHud/VitalDetail/detail_text
		var/tmp/obj/NexusHudBitmapText/primary_text
		var/detail_alignment = "right"
		var/tmp/text_font_size = 9

		New()
			. = ..()
			primary_text = new
			primary_text.layer = 103
			detail_text = new
			vis_contents.Add(primary_text,detail_text)
			switch(type)
				if(/obj/NexusHud/VitalRow/Willpower) pixel_y = 111
				if(/obj/NexusHud/VitalRow/Health) pixel_y = 85
				if(/obj/NexusHud/VitalRow/Energy) pixel_y = 59
				if(/obj/NexusHud/VitalRow/Stamina) pixel_y = 33

		proc/applyScale(scale, row_y)
			pixel_x = round(120 * scale)
			pixel_y = round(row_y * scale)
			text_font_size = getNexusVitalsFontSize(scale)
			maptext_x = max(3, round(6 * scale))
			maptext_y = 1
			maptext_height = max(11,round(19 * scale)-2)
			detail_text.pixel_y = maptext_y
			detail_text.maptext_height = maptext_height

		proc/update(label, percent, detail, accent_color, scale = 1, energy_amount = null)
			icon = getVitalsBarIcon(percent, accent_color, scale)
			maptext = null
			if(scale < 1)
				switch(label)
					if("WILLPOWER") label = "WP"
					if("HEALTH") label = "HP"
					if("ENERGY") label = "KI"
					if("STAMINA") label = "STA"
			maptext_width = measureNexusHudText(label,text_font_size)+1
			primary_text.pixel_x = maptext_x
			primary_text.pixel_y = maptext_y
			primary_text.maptext_width = maptext_width
			primary_text.maptext_height = maptext_height
			primary_text.setBitmapText(label,text_font_size,"#fff1d4")
			detail_text.pixel_x = maptext_x+maptext_width+4
			detail_text.maptext_width = round(168*scale)-detail_text.pixel_x-max(2,round(4*scale))
			if(!isnull(energy_amount)) detail = getNexusHudEnergyText(energy_amount,percent,detail_text.maptext_width)
			detail_text.setBitmapText(detail,text_font_size,"#fff1d4",detail_alignment,TRUE)

		Del()
			if(primary_text) del(primary_text)
			if(detail_text) del(detail_text)
			. = ..()

		Willpower
		Health
		Energy
			detail_alignment = "right"
		Stamina
