client
	dir=NORTH
	show_verb_panel=0
	show_map=0
	default_verb_category=null
	perspective=EYE_PERSPECTIVE
	//script="<STYLE>BODY {background: #000000; color: #CCCCCC; font-size: 1; font-weight: bold; font-family: 'Papyrus'}</STYLE>"
	script="<STYLE>BODY {background: #000000; color: #CCCCCC; font-size: 2; font-weight: bold}</STYLE>"

var/list/clients = new

client/Del()
	clients -= src
	removeNexusLighting()
	if(nexus_character_select)
		del(nexus_character_select)
		nexus_character_select = null
	if(nexus_chat_hud)
		del(nexus_chat_hud)
		nexus_chat_hud = null
	if(nexus_interface_settings)
		del(nexus_interface_settings)
		nexus_interface_settings = null
	if(nexus_hud_window)
		del(nexus_hud_window)
		nexus_hud_window = null
	if(selected_target_marker)
		images -= selected_target_marker
		del(selected_target_marker)
		selected_target_marker = null
	if(main_vitals_hud)
		screen -= main_vitals_hud
		del(main_vitals_hud)
		main_vitals_hud = null
	. = ..()

client/var/tmp/datum/NexusCharacterSelect/nexus_character_select

datum/NexusCharacterSelect
	var/tmp/mob/owner

	New(mob/new_owner)
		. = ..()
		owner = new_owner

	Del()
		if(owner && owner.client)
			owner << browse(null, "window=NexusCharacterSelect")
			if(owner.client.nexus_character_select == src) owner.client.nexus_character_select = null
		owner = null
		. = ..()

	proc/canUse()
		return owner && owner.client && usr == owner && !owner.playerCharacter

	proc/buildHtml()
		if(!owner) return ""
		owner.ensureNexusCharacterSlots()
		var/slot_html = ""
		for(var/slot = 1, slot <= NEXUS_CHARACTER_SLOT_LIMIT, slot++)
			var/list/slot_info = owner.getNexusCharacterSlotInfo(slot)
			var/is_occupied = slot_info["exists"]
			var/slot_state = is_occupied ? "occupied" : "empty"
			var/last_used_text = "AVAILABLE"
			if(is_occupied && slot_info["last_used"])
				last_used_text = time2text(slot_info["last_used"], "MMM DD, YYYY")
			var/actions = is_occupied ? "<a class='play' href='byond://?src=\ref[src]&action=play&slot=[slot]'>ENTER WORLD</a><a class='delete' href='byond://?src=\ref[src]&action=delete&slot=[slot]'>DELETE</a>" : "<a class='create' href='byond://?src=\ref[src]&action=create&slot=[slot]'>CREATE CHARACTER</a>"
			slot_html += "<section class='slot [slot_state]'><div class='slot-number'>[slot]</div><div class='slot-copy'><small>CHARACTER SLOT [slot]</small><h2>[html_encode(slot_info["name"])]</h2><p>[html_encode(slot_info["race"])]</p><em>[last_used_text]</em></div><div class='slot-actions'>[actions]</div></section>"
		return {"<!doctype html><html><head><meta charset='utf-8'><title>Nexus Exodus</title><style>[getNexusRpgBrowserCss()]
		*{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:auto}.gate{min-height:100%;padding:22px;background:#17130f}.frame{max-width:920px;min-height:560px;margin:0 auto;border:4px ridge #9f7945;background:#211910;outline:3px solid #090604}.crest{text-align:center;padding:18px 12px;border-bottom:3px double #a27a43;background:#302216}.crest h1{margin:0;font-size:29px;letter-spacing:4px}.crest p{margin:6px 0 0;color:#bda477}.account{display:flex;justify-content:space-between;padding:9px 14px;border-bottom:1px solid #74552f;background:#1a140e;color:#c8ae7d}.slots{display:grid;gap:10px;padding:16px}.slot{position:relative;min-height:116px;display:grid;grid-template-columns:86px 1fr auto;align-items:center;gap:12px;padding:12px;border:3px ridge #775a34;background:#2a2016}.slot.empty{filter:saturate(.65)}.slot-number{width:64px;height:64px;padding-top:15px;border:3px double #b58b4d;background:#16110c;color:#e6c37e;text-align:center;font:bold 26px 'Courier New',monospace}.slot-copy small{color:#a88a5d;letter-spacing:2px}.slot-copy h2{margin:4px 0;padding:0;background:none!important;border:0!important;font-size:21px}.slot-copy p{margin:0 0 7px;color:#d0bb91}.slot-copy em{font-size:10px;color:#8f7958;font-style:normal}.slot-actions{display:flex;gap:7px;align-items:center}.slot-actions a{display:block;min-width:120px;padding:10px 12px;text-align:center;text-decoration:none}.play,.create{border:3px outset #b58a4b;background:#51391e;color:#f4d99b}.delete{min-width:70px!important;border:3px outset #844b3e;background:#3a211b;color:#e8a89b}.footnote{padding:10px 16px;border-top:1px solid #735530;color:#9f8965;text-align:center;font-size:10px}@media(max-width:700px){.gate{padding:6px}.slot{grid-template-columns:60px 1fr}.slot-number{width:50px;height:50px;padding-top:11px}.slot-actions{grid-column:1/3;justify-content:flex-end}.crest h1{font-size:22px}}
		</style></head><body><main class='gate'><div class='frame'><header class='crest'><h1>NEXUS EXODUS</h1><p>Choose the soul that will cross the Nexus</p></header><div class='account'><span>ACCOUNT</span><b>[html_encode(owner.key)]</b></div><div class='slots'>[slot_html]</div><div class='footnote'>Three independent characters per account. Progress and feats are stored per slot.</div></div></main></body></html>"}

	proc/show()
		if(!owner || !owner.client || owner.playerCharacter)
			del(src)
			return
		owner << browse(buildHtml(), "window=NexusCharacterSelect;size=960x720;can_resize=true;can_close=false")

	Topic(href, list/href_list)
		if(!canUse()) return
		var/slot = clampNexusCharacterSlot(href_list["slot"])
		switch(href_list["action"])
			if("create")
				if(owner.hasSave(slot)) return
				var/mob/player = owner
				if(player.NewClicked(slot)) del(src)
				else show()
			if("play")
				if(!owner.hasSave(slot))
					show()
					return
				var/mob/player = owner
				if(player.LoadClicked(slot)) del(src)
				else show()
			if("delete")
				if(!owner.hasSave(slot)) return
				var/list/slot_info = owner.getNexusCharacterSlotInfo(slot)
				if(alert(owner, "Permanently delete [slot_info["name"]] from slot [slot]? This cannot be undone.", "Delete Character", "Keep Character", "Delete Forever") != "Delete Forever") return
				owner.deleteNexusCharacterSlot(slot)
				show()

client
	var
		tmp
			startViewX = 61 //we have these high for the title screen because it affects the resolution that the title screen is presented at. set it to 5x5 youll see its
				//very pixelated
			startViewY = 61
			show_chatbox = 1
			show_settings_window = 0
			show_stats = 1
			show_tabs = 1
			show_bars = 1
			show_input = 0
			helpAlertCount = 0
			helpAlertShowing = 0
			uiOrganizationMode = 0
			uiHidden = 0
			image/titleScreenImg //this client's title screen image that has been scaled to fit their resolution

client/proc
	DisplayTitleScreen()
		set waitfor=0
		while(!resolutionInitialized) sleep(1)
		mob.loc = locate(445,3,2)
		var/icon/i2 = icon('NexusExodus.dmi')
		sleep(5) //just seeing if this fixes the bug where Width()/Height() fails sometimes
		var
			w = i2.Width()
			h = i2.Height()
		if(!w || !h)
			world.log << "ERROR: Width or height of title screen came out as zero!"
			//sleep(5)
			//DisplayTitleScreen()
			return
		else
			var/image/i = image(icon = i2, loc = mob, layer = 10, pixel_x = -(w - 32) * 0.5, pixel_y = -(h - 32) * 0.5)
			titleScreenImg = i
			var/matrix/m = matrix(i.transform)
			var/yScale = (((mob.ViewY * 2) + 1) * 32) / h
			m.Scale(yScale * 0.5, yScale * 0.5)
			i.transform = m
			images += i

	DeleteTitleScreen()
		set waitfor=0
		if(!titleScreenImg) return
		del(titleScreenImg)

client/New()
	JSresolutionCheck()
	clients += src
	. = ..()
	mob.DetermineViewSize(forceWidth = startViewX)
	fps = client_fps
	MaxFPSTrick()
	if(connection == "telnet") mob = new/mob

	var/newTitle = "Nexus Exodus"
	winset(src, "mainwindow", "title=\"[newTitle]\"")

	if(!mob || !mob.loc) //in theory this should work, so if you were punched and just relog back into your character, i hope, then we shouldnt do any of this stuff?
		winset(src, "TabScience.grid1", "show-names=true")
		winset(src, "mainwindow.helpAlert", "is-visible=false")
		//winset(src, "mainwindow.helpAlert", "titlebar=false")
		if(!classic_ui)
			winset(src, "settingsButtons", "is-visible=false")
			winset(src, "Bars", "is-visible=false")
			winset(src, "statsOverlay", "is-visible=false")
			winset(src, "infowindow", "is-visible=false")
			winset(src, "outputwindow", "is-visible=false")
			winset(src, "outputwindow", "titlebar=false")
			winset(src, "infowindow", "titlebar=false")
			winset(src, "statsOverlay", "titlebar=false")
			winset(src, "settingsButtons", "titlebar=false")
			winset(src, "inputWindow", "titlebar=false")
			winset(src, "newButton", "titlebar=false")
			winset(src, "loadButton", "titlebar=false")
			winset(src, "Bars", "titlebar=false")
			winset(src, "newButton", "is-visible=false")
			winset(src, "loadButton", "is-visible=false")
			winset(src, "mainwindow.map", "is-visible=false")
			winset(src, "inputWindow", "is-visible=false")
		else
			//almost none of these seem to work in regards to hiding the draggable divider thing we were trying to accomplish on the login screen
			//not sure which to remove now, i forgot to do it at the time
			winset(src, "mainwindow.mainvsplit", "right=") //turns off tabs+output making the map take up the full screen
			winset(src, "mainwindow.map", "is-visible=true")
			winset(src,"Bars","is-visible=false")
			winset(src,"infowindow","is-visible=false")
			winset(src,"outputwindow","is-visible=false")
			winset(src,"rpane.rpanewindow","is-visible=false")
			winset(src,"mainwindow.mainvssplit","is-visible=false")
			DisplayTitleScreen()
		if(mob) mob.hideNexusLegacyInterface()
		if(mob)
			//var/musics = list('RoyalBlueTheme.ogg', 'UltraInstinctTheme1.ogg', 'GokuSpiritBombTheme.ogg')
			var/musics = list('CarnivalMeme.ogg')
			src << sound(pick(musics), volume = 20, repeat = 1)
			
			mob.DetectNewLoadButtonClick()
			mob.Fullscreen_Check(skipAlert = 1)
			mob.CodebanLoginCheck()
			mob.UnsortedClientLoginStuff()

mob
	verb
		//gets rid of the tabs and output so that you only see the map but you cant see what anyone is saying but its "true fullscreen"
		HideAllUI()
			set hidden = 1
			client.uiHidden = !client.uiHidden
			if(client.nexus_chat_hud) client.nexus_chat_hud.setVisible(!client.uiHidden)

mob/proc
	StatOverlayUpdateLoop()
		set waitfor=0
		if(classic_ui) return
		while(src)
			if(client && client.show_stats)
				var/bp_mod_display_mult = 1
				if(NearBPOrb()) bp_mod_display_mult *= bp_orb_increase
				var/bpGainVal = round(bp_mod * weights() * GravityGainsMult() * bp_mod_display_mult,0.01)
				winset(src, "statsOverlay.bpGainValue", "text='[bpGainVal]x'")
				winset(src, "statsOverlay.energyValue", "text='[round(max_ki)] ([Eff]x gains)'")
				winset(src, "statsOverlay.strengthValue", "text='[StatViewThing(Swordless_strength(), "Str")]'")
				winset(src, "statsOverlay.duraValue", "text='[StatViewThing(End, "End")]'")
				winset(src, "statsOverlay.forceValue", "text='[StatViewThing(Pow, "Pow")]'")
				winset(src, "statsOverlay.resistValue", "text='[StatViewThing(Res, "Res")]'")
				winset(src, "statsOverlay.speedValue", "text='[StatViewThing(Spd, "Spd")]'")
				winset(src, "statsOverlay.accValue", "text='[StatViewThing(Off, "Off")]'")
				winset(src, "statsOverlay.refValue", "text='[StatViewThing(Def, "Def")]'")
				var/regenLabel = (regen + Regen_Mult - 1)
				winset(src, "statsOverlay.regValue", "text='[round(regenLabel, 0.01)]x'")
				winset(src, "statsOverlay.recValue", "text='[round(recov + Recov_Mult-1,0.01)]x'")
				winset(src, "statsOverlay.angerValue", "text='[max_anger / 100]x'")
			sleep(30)

mob/verb
	ToggleChatbox()
		set hidden = 1
		if(!client) return
		client.show_chatbox = !client.show_chatbox
		if(!client.nexus_chat_hud && client.show_chatbox) initializeNexusChatHud()
		else if(client.nexus_chat_hud) client.nexus_chat_hud.setVisible(client.show_chatbox)

	SettingsButtonClicked()
		set hidden = 1
		Settings()

	PressEscape()
		set hidden = 1
		if(winget(src, "mainwindow.helpAlert", "is-visible") == "true")
			HideHelpAlert()
			return
		if(classic_ui)
			Settings()
			return
		ToggleSettingsWindow()

	ToggleSettingsWindow()
		set hidden = 1
		if(!client) return
		client.show_settings_window = !client.show_settings_window
		var/bool = "true"
		if(!client.show_settings_window) bool = "false"
		winset(src, "settingsButtons", "is-visible=[bool]")

	ToggleStatsOverlay()
		set hidden = 1
		if(!client) return
		client.show_stats = !client.show_stats
		var/bool = "true"
		if(!client.show_stats) bool = "false"
		winset(src, "statsOverlay", "is-visible=[bool]")

	ToggleTabs()
		set hidden = 1
		if(!client || !playerCharacter) return
		showCharacterSheet()

	ToggleBars()
		set hidden = 1
		if(!client) return
		client.show_bars = !client.show_bars
		setVitalsHudVisibility(client.show_bars)

	ViewGuides()
		set hidden = 1
		while(src && client)
			switch(input(src,"Which guide do you want to view?") in list("Cancel","Basic Guides","Detailed Race Stats","Alignment/Sagas Guide","How to get strong faster"))
				if("Cancel") break
				if("Basic Guides") Guide()
				if("Detailed Race Stats") Race_Guide()
				if("Alignment/Sagas Guide") Sagas_Guide()
				if("How to get strong faster") Strong_guide()

	ViewHotkeys()
		set hidden = 1
		Show_hotbar_grid()

	ToggleInterfaceOrganizationMode()
		set hidden = 1
		if(classic_ui) return
		client.uiOrganizationMode = !client.uiOrganizationMode
		var/titlebar = "true"
		if(!client.uiOrganizationMode) titlebar = "false"
		winset(src, "statsOverlay", "titlebar=[titlebar]")
		winset(src, "Bars", "titlebar=[titlebar]")
		winset(src, "outputwindow", "titlebar=[titlebar]")
		winset(src, "infowindow", "titlebar=[titlebar]")

		winset(src, "statsOverlay", "can-resize=[titlebar]")
		winset(src, "Bars", "can-resize=[titlebar]")
		winset(src, "outputwindow", "can-resize=[titlebar]")
		winset(src, "infowindow", "can-resize=[titlebar]")

	PressEnter()
		set hidden = 1
		if(!client || !playerCharacter) return
		spawn() Say()

	//keep in mind BYOND is calling this more than once when you click maximize for some reason
	//its calling it like 3-5 times per resize
	//so what we could do is not really running a lot of the code if the new size is the same as the old size (hopefully but its untested)
	MainWindowResized()
		set hidden = 1
		src << "Window Resized"

	/*testxxx()
		var/resolution = GetWindowSize()
		var/outputSize = GetWindowSize("outputwindow")
		var/posx = resolution[1] - outputSize[1]
		var/posy = resolution[2] - outputSize[2]
		winset(src, "outputwindow", "pos=[posx],[posy]")*/

mob/proc
	GetWindowSize(e = "mainwindow.resizeLabel")
		if(e == "mainwindow") e = "mainwindow.resizeLabel" //we have to use this trick with an invisible fullscreen label because byond's normal way doesnt work
		var/wg = winget(src, e, "size")
		var/l = dd_text2list(wg, "x")
		l[1] = text2num(l[1])
		l[2] = text2num(l[2])
		return l

	GetWindowPos(e = "mainwindow")
		var/wg = winget(src, e, "pos")
		var/l = dd_text2list(wg, ",")
		l[1] = text2num(l[1])
		l[2] = text2num(l[2])
		return l

	HelpAlertShowing()
		if(client && client.helpAlertShowing) return 1
		return 0

	NewCharHelpAlerts()
		set waitfor=0
		//if(classic_ui) return
		while(HelpAlertShowing()) sleep(10) //just wait for any other potential interfering alerts to go away before beginning
		HelpAlert("Alerts such as this will sometimes appear to help you. Press Escape to get rid of them.", 1.#INF)
		while(HelpAlertShowing()) sleep(10)
		if(!classic_ui) HelpAlert("Use F1 through F5 to toggle the Chatbox, Stats Overlay, Tabs Overlay, Health Bars, and Hotkeys Menu", 1.#INF)
		while(HelpAlertShowing()) sleep(10)
		if(!classic_ui) HelpAlert("Press Escape to view the Main Menu where you can adjust settings and exit the game", 1.#INF)
		else HelpAlert("Press Escape to view the Main Menu where you can adjust settings", 1.#INF)
		while(HelpAlertShowing()) sleep(10)
		HelpAlert("You can view the guides by clicking this alert or later through the Main Menu", 1.#INF, "ViewGuides")
		while(HelpAlertShowing()) sleep(10)
		HelpAlert("You can view what the controls are by clicking this alert or pressing F5 at any time", 1.#INF, "ViewHotkeys")
		while(HelpAlertShowing()) sleep(10)
		HelpAlert("B = Global Chat. V = Chat to players in sight. E = Use items in your inventory or in front of your character. \
		T = Grab items or players in front of you. Space = Punch (when something is in front of you to punch that is). Tab = Toggle Auto Attack \
		(automatically punch anyone who gets in front of you). X = Learn new skills.", 1.#INF)
		while(HelpAlertShowing()) sleep(10)
		if(!classic_ui) HelpAlert("Press Ctrl+F1 to be able to drag user interface elements where you want them to be. Press again to stop.", 1.#INF)

	DetectNewLoadButtonClick()
		set waitfor=0
		ShowNexusLoginPrompt()

	NewClicked(selected_slot = 0)
		if(playerCharacter) return
		ensureNexusCharacterSlots()
		if(!selected_slot)
			for(var/slot = 1, slot <= NEXUS_CHARACTER_SLOT_LIMIT, slot++)
				if(!hasSave(slot))
					selected_slot = slot
					break
		if(!selected_slot || hasSave(selected_slot))
			alert(src, "All three character slots are occupied.")
			ShowNexusLoginPrompt()
			return
		active_character_slot = clampNexusCharacterSlot(selected_slot)
		var/creator_opened = ClickMakeNewCharacter()
		if(!creator_opened && client && !client.nexus_character_select)
			ShowNexusLoginPrompt()
		return creator_opened

	LoadClicked(selected_slot = 0)
		if(playerCharacter) return
		ensureNexusCharacterSlots()
		if(!selected_slot)
			for(var/slot = 1, slot <= NEXUS_CHARACTER_SLOT_LIMIT, slot++)
				if(hasSave(slot))
					selected_slot = slot
					break
		if(!selected_slot || !hasSave(selected_slot))
			ShowNexusLoginPrompt()
			return
		active_character_slot = clampNexusCharacterSlot(selected_slot)
		if(load())
			hideNexusLegacyInterface()
			StuffThatRunsIfYouClickNewOrLoad()
			return 1
		return FALSE

	ShowNexusLoginPrompt()
		if(playerCharacter) return
		while(!can_login || world.time < 100) sleep(10)
		ensureNexusCharacterSlots()
		if(!client) return
		if(client.nexus_character_select) del(client.nexus_character_select)
		client.nexus_character_select = new /datum/NexusCharacterSelect(src)
		client.nexus_character_select.show()
