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

var/list/overhead_health_icon_cache = list()
var/list/vitals_bar_icon_cache = list()
var/list/power_gauge_icon_cache = list()
var/icon/vitals_panel_icon

proc/overheadHealthColor(health_percent)
	if(health_percent < 50) return "#ef4758"
	if(health_percent <= 60) return "#f2c94c"
	return "#46d369"

proc/getOverheadHealthIcon(health_percent)
	health_percent = Clamp(health_percent, 0, 100)
	var/fill_width = round(health_percent * 0.32)
	var/health_color = overheadHealthColor(health_percent)
	var/cache_key = "[health_color]-[fill_width]"
	if(overhead_health_icon_cache[cache_key]) return overhead_health_icon_cache[cache_key]
	var/icon/health_icon = icon('Healthbar.dmi', "100")
	health_icon.Scale(32, 5)
	health_icon.DrawBox("#171b22", 1, 1, 32, 5)
	if(fill_width) health_icon.DrawBox(health_color, 1, 1, fill_width, 5)
	overhead_health_icon_cache[cache_key] = health_icon
	return health_icon

proc/getVitalsPanelIcon()
	if(vitals_panel_icon) return vitals_panel_icon
	vitals_panel_icon = icon('UserNamesBarsUi.png')
	vitals_panel_icon.Scale(380, 160)
	vitals_panel_icon.DrawBox(rgb(9, 14, 22, 220), 1, 1, 380, 160)
	vitals_panel_icon.DrawBox("#354052", 1, 1, 380, 2)
	vitals_panel_icon.DrawBox("#354052", 1, 159, 380, 160)
	vitals_panel_icon.DrawBox("#354052", 1, 1, 2, 160)
	vitals_panel_icon.DrawBox("#354052", 379, 1, 380, 160)
	return vitals_panel_icon

proc/getVitalsBarIcon(percent, accent_color)
	if(!nexusIsFiniteNumber(percent)) percent = 0
	percent = round(Clamp(percent, 0, 100))
	var/fill_width = round(percent * 2.12)
	var/cache_key = "[accent_color]-[fill_width]"
	if(vitals_bar_icon_cache[cache_key]) return vitals_bar_icon_cache[cache_key]
	var/icon/bar_icon = icon('UserNamesBarsUi.png')
	bar_icon.Scale(220, 24)
	bar_icon.DrawBox("#111923", 1, 1, 220, 24)
	bar_icon.DrawBox("#293443", 5, 3, 216, 21)
	if(fill_width) bar_icon.DrawBox(accent_color, 5, 3, 4 + fill_width, 21)
	bar_icon.DrawBox(accent_color, 1, 1, 4, 24)
	vitals_bar_icon_cache[cache_key] = bar_icon
	return bar_icon

proc/getPowerGaugeIcon(percent, over_limit)
	if(!nexusIsFiniteNumber(percent)) percent = 0
	percent = round(Clamp(percent, 0, 100))
	var/fill_height = round(percent * 0.9)
	var/cache_key = "[over_limit]-[fill_height]"
	if(power_gauge_icon_cache[cache_key]) return power_gauge_icon_cache[cache_key]
	var/gauge_color = over_limit ? "#ff5c45" : "#b983ff"
	var/icon/gauge_icon = icon('UserNamesBarsUi.png')
	gauge_icon.Scale(9, 96)
	gauge_icon.DrawBox("#101722", 1, 1, 9, 96)
	gauge_icon.DrawBox("#2a3341", 3, 3, 7, 92)
	if(fill_height) gauge_icon.DrawBox(gauge_color, 3, 3, 7, 2 + fill_height)
	gauge_icon.DrawBox(over_limit ? "#ffb09f" : "#e8dcff", 1, 93, 9, 96)
	power_gauge_icon_cache[cache_key] = gauge_icon
	return gauge_icon

mob/var/tmp/obj/NexusHud/OverheadHealthBar/overhead_health_hud
client/var/tmp/obj/NexusHud/VitalsPanel/main_vitals_hud

mob/Write(savefile/save_file)
	var/hud_attached = overhead_health_hud && (overhead_health_hud in vis_contents)
	if(hud_attached) vis_contents -= overhead_health_hud
	. = ..()
	if(hud_attached && overhead_health_hud) vis_contents += overhead_health_hud

mob/proc/shouldShowOverheadHealthHud()
	return client && playerCharacter

mob/proc/initializeVitalsHud()
	if(!shouldShowOverheadHealthHud()) return
	if(!overhead_health_hud)
		overhead_health_hud = new
		overhead_health_hud.initialize(src)
	if(!(overhead_health_hud in vis_contents)) vis_contents += overhead_health_hud
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

mob/proc/setVitalsHudVisibility(visible)
	if(!client) return
	winset(src, "Bars", "is-visible=false")
	if(visible)
		if(!client.main_vitals_hud) initializeMainVitalsHud()
		if(client.main_vitals_hud && !(client.main_vitals_hud in client.screen)) client.screen += client.main_vitals_hud
	else if(client.main_vitals_hud) client.screen -= client.main_vitals_hud

mob/proc/updateOverheadHealthHud()
	if(!shouldShowOverheadHealthHud()) return
	if(!overhead_health_hud) initializeVitalsHud()
	if(overhead_health_hud) overhead_health_hud.update(src)

mob/proc/removeVitalsHud()
	if(overhead_health_hud)
		vis_contents -= overhead_health_hud
		del(overhead_health_hud)
		overhead_health_hud = null
	if(client && client.main_vitals_hud)
		client.screen -= client.main_vitals_hud
		del(client.main_vitals_hud)
		client.main_vitals_hud = null

obj/NexusHud
	Savable = 0
	Grabbable = 0
	attackable = 0
	density = 0
	mouse_opacity = 0
	layer = 99

	OverheadHealthBar
		pixel_x = 0
		var/tmp/owner_icon

		proc/initialize(mob/owner)
			if(owner && owner.icon) pixel_y = max(32, GetHeight(owner.icon)) + 2
			else pixel_y = 34
			if(owner) owner_icon = owner.icon
			update(owner)

		proc/update(mob/owner)
			if(!owner) return
			var/health_percent = Clamp(hudPercentage(owner.Health), 0, 100)
			icon = getOverheadHealthIcon(health_percent)
			if(owner.icon && owner.icon != owner_icon)
				pixel_y = max(32, GetHeight(owner.icon)) + 2
				owner_icon = owner.icon

	VitalsPanel
		alpha = 255
		mouse_opacity = 2
		screen_loc = "LEFT:8,BOTTOM:8"
		var/tmp/screen_x = 8
		var/tmp/screen_y = 8
		var/tmp/drag_mouse_x
		var/tmp/drag_mouse_y
		var/tmp/drag_start_x
		var/tmp/drag_start_y
		var/tmp/obj/NexusHud/CharacterPortrait/portrait
		var/tmp/obj/NexusHud/VitalRow/health_row
		var/tmp/obj/NexusHud/VitalRow/energy_row
		var/tmp/obj/NexusHud/VitalRow/stamina_row
		var/tmp/obj/NexusHud/PowerGauge/left_power_gauge
		var/tmp/obj/NexusHud/PowerGauge/right_power_gauge
		var/tmp/obj/NexusHud/PowerReadout/power_readout

		proc/initialize(mob/owner)
			icon = getVitalsPanelIcon()
			portrait = new
			health_row = new /obj/NexusHud/VitalRow/Health
			energy_row = new /obj/NexusHud/VitalRow/Energy
			stamina_row = new /obj/NexusHud/VitalRow/Stamina
			left_power_gauge = new /obj/NexusHud/PowerGauge/Left
			right_power_gauge = new /obj/NexusHud/PowerGauge/Right
			power_readout = new
			vis_contents.Add(portrait, left_power_gauge, right_power_gauge, power_readout, health_row, energy_row, stamina_row)
			update(owner)

		proc/update(mob/owner)
			if(!owner || !portrait) return
			portrait.update(owner)
			var/health_percent = hudPercentage(owner.Health)
			var/energy_percent = hudPercentage(owner.Ki, owner.max_ki)
			var/stamina_percent = hudPercentage(owner.stamina, owner.max_stamina)
			var/energy_current = nexusIsFiniteNumber(owner.Ki) ? max(owner.Ki, 0) : 0
			var/current_power = nexusIsFiniteNumber(owner.BPpcnt) ? max(owner.BPpcnt, 0) : 0
			var/soft_cap_excess = owner.powerup_soft_cap()
			if(!nexusIsFiniteNumber(soft_cap_excess) || soft_cap_excess <= 0) soft_cap_excess = 1
			var/soft_cap = 100 + soft_cap_excess
			var/over_limit = current_power > soft_cap
			var/gauge_percent = Clamp((current_power - 100) / soft_cap_excess * 100, 0, 100)
			health_row.update("HEALTH", health_percent, "[health_percent]%", "#ff4d6d")
			energy_row.update("", energy_percent, "([energy_current]) [energy_percent]%", "#37cfff")
			stamina_row.update("STAMINA", stamina_percent, "[stamina_percent]%", "#f6c453")
			left_power_gauge.update(gauge_percent, over_limit)
			right_power_gauge.update(gauge_percent, over_limit)
			power_readout.update(round(current_power, 0.1), round(soft_cap, 0.1), over_limit)

		proc/setScreenPosition(new_x, new_y)
			screen_x = max(0, round(new_x))
			screen_y = max(0, round(new_y))
			screen_loc = "LEFT:[screen_x],BOTTOM:[screen_y]"

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

		Del()
			for(var/obj/hud_object in vis_contents) del(hud_object)
			. = ..()

	CharacterPortrait
		pixel_x = 54
		pixel_y = 55
		layer = 101

		proc/update(mob/owner)
			appearance = owner.appearance
			plane = initial(plane)
			layer = 101
			icon_w = 0
			icon_z = 0
			pixel_w = 0
			pixel_z = 0
			pixel_x = 54
			pixel_y = 55
			alpha = 255
			mouse_opacity = 0
			invisibility = 0
			dir = SOUTH
			underlays = null
			appearance_flags = RESET_ALPHA | PIXEL_SCALE | KEEP_TOGETHER
			var/matrix/portrait_transform = matrix()
			portrait_transform.Scale(2.35, 2.65)
			transform = portrait_transform

	PowerGauge
		pixel_y = 49
		layer = 103
		appearance_flags = RESET_ALPHA

		proc/update(percent, over_limit)
			icon = getPowerGaugeIcon(percent, over_limit)

		Left
			pixel_x = 5

		Right
			pixel_x = 132

	PowerReadout
		pixel_x = 15
		pixel_y = 9
		layer = 104
		appearance_flags = RESET_ALPHA
		maptext_width = 114
		maptext_height = 16

		proc/update(power_percent, soft_cap, over_limit)
			var/status_color = over_limit ? "#ff705c" : "#cda8ff"
			maptext = "<div style='font-family:Arial;text-align:center;text-shadow:1px 1px #000'><b style='font-size:11px;color:[status_color]'>[power_percent]%</b></div>"

	VitalDetail
		pixel_x = 60
		pixel_y = 7
		layer = 103
		appearance_flags = RESET_ALPHA
		maptext_width = 152
		maptext_height = 13

	VitalRow
		maptext_x = 8
		maptext_y = 7
		maptext_width = 58
		maptext_height = 13
		pixel_x = 150
		layer = 102
		appearance_flags = RESET_ALPHA
		var/tmp/obj/NexusHud/VitalDetail/detail_text
		var/detail_alignment = "right"

		New()
			. = ..()
			detail_text = new
			vis_contents += detail_text
			switch(type)
				if(/obj/NexusHud/VitalRow/Health) pixel_y = 112
				if(/obj/NexusHud/VitalRow/Energy)
					pixel_y = 76
					detail_text.pixel_x = 8
					detail_text.maptext_width = 204
				if(/obj/NexusHud/VitalRow/Stamina) pixel_y = 40

		proc/update(label, percent, detail, accent_color)
			icon = getVitalsBarIcon(percent, accent_color)
			maptext = "<span style='font-family:Arial;font-size:9px;font-weight:bold;color:#f5f7fa;white-space:nowrap;text-shadow:1px 1px #000'>[label]</span>"
			detail_text.maptext = "<div style='font-family:Arial;font-size:9px;font-weight:bold;color:#f5f7fa;text-align:[detail_alignment];white-space:nowrap;text-shadow:1px 1px #000'>[detail]</div>"

		Del()
			if(detail_text) del(detail_text)
			. = ..()

		Health
		Energy
			detail_alignment = "right"
		Stamina
