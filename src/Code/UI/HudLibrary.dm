var/list/nexus_hud_library_icon_cache = list()
var/list/nexus_pixel_interface_icon_cache = list()

client/var/tmp/list/nexus_pixel_interface_resources = list()
client/var/tmp/list/nexus_browser_atom_icon_resources = list()

proc/getNexusHudLibraryIcon(width, height, background_color = "#101923", border_color = "#40556b", accent_color = "")
	width = max(1, round(width))
	height = max(1, round(height))
	var/cache_key = "[width]x[height]-[background_color]-[border_color]-[accent_color]"
	if(nexus_hud_library_icon_cache[cache_key]) return nexus_hud_library_icon_cache[cache_key]
	var/icon/panel_icon = icon('UserNamesBarsUi.png')
	panel_icon.Scale(width, height)
	panel_icon.DrawBox(background_color, 1, 1, width, height)
	panel_icon.DrawBox("#160f0a", 1, 1, width, 2)
	panel_icon.DrawBox("#160f0a", 1, height - 1, width, height)
	panel_icon.DrawBox("#160f0a", 1, 1, 2, height)
	panel_icon.DrawBox("#160f0a", width - 1, 1, width, height)
	if(width >= 6 && height >= 6)
		panel_icon.DrawBox(border_color, 3, 3, width - 2, 3)
		panel_icon.DrawBox(border_color, 3, height - 2, width - 2, height - 2)
		panel_icon.DrawBox(border_color, 3, 3, 3, height - 2)
		panel_icon.DrawBox(border_color, width - 2, 3, width - 2, height - 2)
	if(width >= 12 && height >= 12)
		for(var/bolt_x in list(5, width - 4))
			for(var/bolt_y in list(5, height - 4)) panel_icon.DrawBox("#c6a15c", bolt_x, bolt_y, bolt_x + 1, bolt_y + 1)
	if(accent_color) panel_icon.DrawBox(accent_color, 1, 1, 4, height)
	nexus_hud_library_icon_cache[cache_key] = panel_icon
	return panel_icon

proc/getNexusPixelInterfaceIcon(icon_kind)
	icon_kind = lowertext("[icon_kind]")
	if(icon_kind in list("item", "items")) icon_kind = "inventory"
	if(icon_kind in list("combat", "melee", "weapon")) icon_kind = "skills"
	if(icon_kind in list("character", "profile")) icon_kind = "player"
	if(icon_kind in list("development", "science")) icon_kind = "science"
	if(icon_kind in list("log", "legacy")) icon_kind = "logs"
	if(nexus_pixel_interface_icon_cache[icon_kind]) return nexus_pixel_interface_icon_cache[icon_kind]
	var/icon/pixel_icon = icon('UserNamesBarsUi.png')
	pixel_icon.Scale(32, 32)
	pixel_icon.DrawBox("#0d0906", 1, 1, 32, 32)
	pixel_icon.DrawBox("#2a2016", 3, 3, 30, 30)
	pixel_icon.DrawBox("#9b7441", 3, 29, 30, 30)
	pixel_icon.DrawBox("#9b7441", 3, 3, 4, 30)
	pixel_icon.DrawBox("#120d08", 3, 3, 30, 4)
	pixel_icon.DrawBox("#120d08", 29, 3, 30, 30)
	pixel_icon.DrawBox("#d6aa5d", 5, 27, 6, 28)
	pixel_icon.DrawBox("#d6aa5d", 27, 27, 28, 28)
	var/accent = "#d6aa5d"
	switch(icon_kind)
		if("sense") accent = "#6fd8e8"
		if("world") accent = "#69c98f"
		if("resource") accent = "#efbd4d"
		if("blast") accent = "#62cfff"
		if("beam") accent = "#69e5ff"
		if("ability") accent = "#bf8dff"
		if("buff") accent = "#78d782"
		if("training") accent = "#e7815f"
		if("movement") accent = "#68c7ef"
		if("magic") accent = "#c57cff"
		if("science") accent = "#55d5c7"
		if("mining") accent = "#cf9b65"
		if("smithing") accent = "#ef9a55"
		if("logs") accent = "#d9c7a2"
		if("testing") accent = "#8ee168"
		if("server") accent = "#72aee8"
		if("progression") accent = "#55d89a"
		if("milestones") accent = "#f2c451"
		if("vitals") accent = "#f06472"
		if("gloves") accent = "#dca66b"
		if("armor") accent = "#8cb2ca"
		if("mask") accent = "#d7cfb4"
	switch(icon_kind)
		if("inventory")
			pixel_icon.DrawBox(accent, 9, 9, 24, 22)
			pixel_icon.DrawBox("#3a2919", 11, 11, 22, 20)
			pixel_icon.DrawBox(accent, 12, 22, 21, 25)
			pixel_icon.DrawBox("#2a2016", 14, 22, 19, 24)
			pixel_icon.DrawBox("#f4d58e", 15, 15, 18, 17)
		if("skills")
			for(var/blade_step = 0, blade_step < 12, blade_step++) pixel_icon.DrawBox(accent, 9 + blade_step, 8 + blade_step, 10 + blade_step, 9 + blade_step)
			pixel_icon.DrawBox("#f4e7c4", 20, 20, 23, 23)
			pixel_icon.DrawBox("#a86d39", 7, 8, 12, 10)
			pixel_icon.DrawBox("#6f4428", 7, 5, 9, 9)
		if("sense")
			pixel_icon.DrawBox(accent, 7, 15, 25, 18)
			pixel_icon.DrawBox(accent, 10, 12, 22, 21)
			pixel_icon.DrawBox("#101923", 12, 14, 20, 19)
			pixel_icon.DrawBox("#f2e3aa", 15, 15, 18, 18)
		if("world")
			pixel_icon.DrawBox(accent, 8, 8, 24, 24)
			pixel_icon.DrawBox("#13251d", 10, 10, 22, 22)
			pixel_icon.DrawBox(accent, 15, 9, 17, 23)
			pixel_icon.DrawBox(accent, 9, 15, 23, 17)
		if("resource")
			pixel_icon.DrawBox(accent, 13, 7, 19, 25)
			pixel_icon.DrawBox(accent, 10, 11, 22, 21)
			pixel_icon.DrawBox("#fff0a3", 14, 15, 17, 21)
		if("blast")
			pixel_icon.DrawBox(accent, 14, 7, 18, 25)
			pixel_icon.DrawBox(accent, 7, 14, 25, 18)
			pixel_icon.DrawBox("#e9fbff", 12, 12, 20, 20)
		if("beam")
			pixel_icon.DrawBox(accent, 6, 14, 26, 18)
			pixel_icon.DrawBox("#e9fbff", 9, 15, 23, 17)
			pixel_icon.DrawBox(accent, 22, 11, 26, 21)
		if("ability")
			pixel_icon.DrawBox(accent, 13, 8, 19, 24)
			pixel_icon.DrawBox(accent, 9, 12, 23, 20)
			pixel_icon.DrawBox("#f0dcff", 14, 13, 18, 19)
		if("buff")
			pixel_icon.DrawBox(accent, 14, 8, 18, 22)
			pixel_icon.DrawBox(accent, 10, 18, 22, 22)
			pixel_icon.DrawBox(accent, 12, 21, 20, 25)
		if("training")
			pixel_icon.DrawBox(accent, 7, 14, 25, 18)
			pixel_icon.DrawBox(accent, 6, 10, 9, 22)
			pixel_icon.DrawBox(accent, 23, 10, 26, 22)
		if("movement")
			pixel_icon.DrawBox(accent, 7, 14, 23, 18)
			pixel_icon.DrawBox(accent, 17, 9, 25, 23)
		if("player")
			pixel_icon.DrawBox(accent, 13, 19, 19, 25)
			pixel_icon.DrawBox(accent, 10, 9, 22, 19)
			pixel_icon.DrawBox("#f2d49b", 15, 21, 17, 23)
		if("gloves")
			pixel_icon.DrawBox(accent, 7, 9, 14, 21)
			pixel_icon.DrawBox(accent, 18, 9, 25, 21)
			pixel_icon.DrawBox("#f2d49b", 9, 18, 12, 23)
			pixel_icon.DrawBox("#f2d49b", 20, 18, 23, 23)
		if("armor")
			pixel_icon.DrawBox(accent, 9, 9, 23, 24)
			pixel_icon.DrawBox("#1a2730", 13, 11, 19, 21)
			pixel_icon.DrawBox(accent, 6, 18, 10, 24)
			pixel_icon.DrawBox(accent, 22, 18, 26, 24)
		if("mask")
			pixel_icon.DrawBox(accent, 9, 9, 23, 24)
			pixel_icon.DrawBox("#19140f", 12, 17, 15, 19)
			pixel_icon.DrawBox("#19140f", 18, 17, 21, 19)
			pixel_icon.DrawBox("#19140f", 15, 11, 18, 14)
		if("science")
			pixel_icon.DrawBox(accent, 14, 7, 18, 25)
			pixel_icon.DrawBox(accent, 8, 14, 24, 18)
			pixel_icon.DrawBox("#e5fffb", 15, 15, 17, 17)
			pixel_icon.DrawBox(accent, 8, 8, 11, 11)
			pixel_icon.DrawBox(accent, 21, 21, 24, 24)
		if("magic")
			pixel_icon.DrawBox(accent, 14, 7, 18, 25)
			pixel_icon.DrawBox(accent, 8, 14, 24, 18)
			pixel_icon.DrawBox("#f4dfff", 12, 12, 20, 20)
		if("mining")
			for(var/pick_step = 0, pick_step < 12, pick_step++) pixel_icon.DrawBox("#b87b4a", 10 + pick_step, 7 + pick_step, 12 + pick_step, 9 + pick_step)
			pixel_icon.DrawBox(accent, 8, 20, 24, 23)
		if("smithing")
			pixel_icon.DrawBox(accent, 8, 19, 21, 24)
			pixel_icon.DrawBox("#a76637", 17, 7, 21, 21)
			pixel_icon.DrawBox("#f0bd74", 6, 8, 25, 11)
		if("logs")
			pixel_icon.DrawBox(accent, 9, 7, 23, 25)
			pixel_icon.DrawBox("#30271c", 11, 9, 21, 23)
			for(var/log_y in list(12, 16, 20)) pixel_icon.DrawBox(accent, 13, log_y, 20, log_y + 1)
		if("testing")
			pixel_icon.DrawBox(accent, 14, 18, 18, 25)
			pixel_icon.DrawBox(accent, 10, 8, 22, 18)
			pixel_icon.DrawBox("#d8ffc7", 12, 10, 20, 14)
		if("server")
			pixel_icon.DrawBox(accent, 8, 8, 24, 24)
			pixel_icon.DrawBox("#162332", 10, 10, 22, 22)
			for(var/server_y in list(12, 17, 22)) pixel_icon.DrawBox(accent, 11, server_y, 20, server_y + 1)
		if("progression")
			pixel_icon.DrawBox(accent, 7, 14, 25, 18)
			pixel_icon.DrawBox(accent, 15, 7, 18, 25)
			pixel_icon.DrawBox("#d9ffe9", 7, 8, 10, 11)
			pixel_icon.DrawBox("#d9ffe9", 15, 22, 18, 25)
			pixel_icon.DrawBox("#d9ffe9", 23, 8, 26, 11)
		if("milestones")
			pixel_icon.DrawBox(accent, 14, 7, 18, 25)
			pixel_icon.DrawBox(accent, 7, 14, 25, 18)
			pixel_icon.DrawBox("#fff2ae", 11, 11, 21, 21)
		if("vitals")
			pixel_icon.DrawBox(accent, 8, 15, 24, 21)
			pixel_icon.DrawBox(accent, 11, 10, 21, 23)
			pixel_icon.DrawBox("#ffd6dc", 14, 16, 18, 19)
		else
			pixel_icon.DrawBox(accent, 11, 10, 21, 22)
			pixel_icon.DrawBox("#2a2016", 14, 13, 18, 19)
	nexus_pixel_interface_icon_cache[icon_kind] = pixel_icon
	return pixel_icon

proc/getNexusPixelInterfaceIconResource(mob/viewer, icon_kind)
	icon_kind = lowertext("[icon_kind]")
	var/resource_name = "nexus_pixel_[md5(icon_kind)].png"
	if(viewer && viewer.client)
		if(!islist(viewer.client.nexus_pixel_interface_resources)) viewer.client.nexus_pixel_interface_resources = list()
		if(!viewer.client.nexus_pixel_interface_resources[resource_name])
			viewer << browse_rsc(getNexusPixelInterfaceIcon(icon_kind), resource_name)
			viewer.client.nexus_pixel_interface_resources[resource_name] = TRUE
	return resource_name

proc/getNexusBrowserAtomIconResource(mob/viewer, atom/subject)
	if(!subject || !subject.icon) return null
	var/icon_direction = subject.dir ? subject.dir : SOUTH
	var/cache_key = "[subject.icon]|[subject.icon_state]|[icon_direction]|[subject.color]|[subject.alpha]"
	var/resource_name = "nexus_atom_[md5(cache_key)].png"
	if(viewer && viewer.client)
		if(!islist(viewer.client.nexus_browser_atom_icon_resources)) viewer.client.nexus_browser_atom_icon_resources = list()
		if(!viewer.client.nexus_browser_atom_icon_resources[resource_name])
			var/icon/preview = icon(subject.icon, subject.icon_state, icon_direction)
			if(istext(subject.color) && length(subject.color)) preview.Blend(subject.color, ICON_MULTIPLY)
			viewer << browse_rsc(preview, resource_name)
			viewer.client.nexus_browser_atom_icon_resources[resource_name] = TRUE
	return resource_name

proc/blendNexusCharacterPortraitLayer(icon/portrait, appearance_value, direction, blend_mode)
	if(!portrait || !appearance_value || !appearance_value:icon) return
	var/icon/layer_icon = icon(appearance_value:icon, appearance_value:icon_state, direction)
	if(!layer_icon) return
	if(istext(appearance_value:color) && length(appearance_value:color)) layer_icon.Blend(appearance_value:color, ICON_MULTIPLY)
	if(isnum(appearance_value:alpha) && appearance_value:alpha < 255) layer_icon.ChangeOpacity(max(0, appearance_value:alpha) / 255)
	portrait.Blend(layer_icon, blend_mode, 1 + appearance_value:pixel_x, 1 + appearance_value:pixel_y)

proc/getNexusCharacterPortraitIcon(atom/subject, direction = SOUTH)
	if(!subject || !subject.icon) return null
	var/icon/portrait = icon(subject.icon, subject.icon_state, direction)
	if(istext(subject.color) && length(subject.color)) portrait.Blend(subject.color, ICON_MULTIPLY)
	if(isnum(subject.alpha) && subject.alpha < 255) portrait.ChangeOpacity(max(0, subject.alpha) / 255)
	for(var/underlay_value in subject.underlays)
		blendNexusCharacterPortraitLayer(portrait, underlay_value, direction, ICON_UNDERLAY)
	for(var/overlay_value in subject.overlays)
		blendNexusCharacterPortraitLayer(portrait, overlay_value, direction, ICON_OVERLAY)
	return portrait

proc/getNexusSkillInterfaceIconKind(hotbar_type)
	var/type_text = lowertext("[hotbar_type]")
	if(findtext(type_text, "beam")) return "beam"
	if(findtext(type_text, "blast")) return "blast"
	if(findtext(type_text, "buff")) return "buff"
	if(findtext(type_text, "training")) return "training"
	if(findtext(type_text, "melee")) return "skills"
	return "ability"

proc/getNexusRpgBrowserCss()
	return {"
	*{border-radius:0!important;box-shadow:none!important}html,body{background:#17130f!important;background-image:none!important;color:#e8d4aa!important;font-family:'Courier New',monospace!important}body:before{display:none!important}.shell,.menu-frame,.header,.toolbar,.footer,.workspace,.content,.entries,.results,.catalog,.topbar{background-color:#211a13!important;background-image:none!important}.panel,.pane,.card,.action,.action-card,.keyboard,.key,.numpad,.reward,.result,.progress-card,.milestone,.milestone-card,.skill-card,.stat-row,.meter,.portrait,.emote-card,.status>div,.mutation,.mutation-panel,.review-panel #reviewSummary,.option-card span,.trait-choice span,.race-entry span,.portrait-choice span,.hair-choice span,.clothing-choice span,.frost-form-card,.preview-shell,.frost-form-preview{background:#2b2117!important;background-image:none!important;border:2px solid #715735!important;outline:1px solid #120d08!important}.header,.menu-title,.panel h2,.pane h2,h1,h2,h3,thead,.stage-strip span.active{background:#3a2a1b!important;background-image:none!important;color:#f0d497!important;border-color:#a27c45!important;text-shadow:1px 1px #0b0805!important}.title b,.menu-title span,h1{letter-spacing:1px!important}.button,button,a.button,a.tab,.top-button,.filters button,.toolbar button,.post,.confirm,.journey-button,.preview-controls button,.wizard-nav button,.close,.back,.play,.create,.delete{background:#49351f!important;background-image:none!important;border:2px outset #9a7440!important;color:#f2d79e!important;font-family:'Courier New',monospace!important;font-weight:bold!important;text-transform:uppercase!important;text-decoration:none!important}.button:hover,button:hover,a.button:hover,a.tab:hover,.top-button:hover,.filters button:hover,.toolbar button:hover,.post:hover,.confirm:hover,.close:hover,.back:hover{background:#624825!important;color:#fff2c2!important}.button:active,button:active,a.button:active,a.tab:active,.top-button:active,.filters button:active{border-style:inset!important}.active,.tab.active,.filters button.active,.stage-strip span.active{background:#76542a!important;color:#fff3bf!important;border-color:#d4ad65!important}input,textarea,select,.editor,.search{background:#120f0c!important;color:#f3dfb6!important;border:2px inset #6e5738!important;font-family:'Courier New',monospace!important}.preview,.stage-scroll,.race-scroll,.clothing-grid{background:#18130e!important}.badge,.identity,.target,.level-strip,.mode{background:#302317!important;border:1px solid #8d6b3c!important;color:#eacb8f!important}table{border-collapse:separate!important;border-spacing:1px!important;background:#17110c!important}td,th{border:1px solid #4e3b27!important;background:#251c14!important}img{image-rendering:pixelated!important}.hint,small,.title span,.counter,.description,.footer{color:#bca47c!important}::-webkit-scrollbar{width:14px;height:14px}::-webkit-scrollbar-track{background:#17110c;border:1px solid #4b3824}::-webkit-scrollbar-thumb{background:#6b4e2d;border:2px outset #9b7441}
	html,body{background-image:linear-gradient(90deg,rgba(214,170,93,.025) 1px,transparent 1px),linear-gradient(rgba(214,170,93,.025) 1px,transparent 1px)!important;background-size:8px 8px!important;font-family:'Fixedsys','Lucida Console','Courier New',monospace!important}.panel,.pane,.card,.action,.action-card,.progress-card,.milestone,.milestone-card,.skill-card,.stat-row,.meter,.portrait,.status>div{box-shadow:inset 2px 2px #3d2e1d,inset -2px -2px #160f0a,2px 2px 0 #0d0906!important}.button,button,a.button,a.tab,.top-button,.filters button,.toolbar button,.close,.back{font-family:'Fixedsys','Lucida Console','Courier New',monospace!important;box-shadow:2px 2px 0 #100b07!important}.button:active,button:active,a.button:active,a.tab:active,.top-button:active,.filters button:active{box-shadow:none!important}.pixel-ui-icon{width:32px;height:32px;image-rendering:pixelated;flex:0 0 32px}.pixel-ui-icon.small{width:20px;height:20px;flex-basis:20px}
	"}

proc/prepareNexusHudBrowserResources(mob/viewer)
	if(!viewer || !viewer.client) return FALSE
	if(viewer.client.nexus_hud_font_resources_ready) return TRUE
	viewer << browse_rsc('src/Fonts/SilkscreenRegular.ttf', "SilkscreenRegular.ttf")
	viewer << browse_rsc('src/Fonts/SilkscreenBold.ttf', "SilkscreenBold.ttf")
	viewer.client.nexus_hud_font_resources_ready = TRUE
	return TRUE

proc/getNexusHudBrowserCss(theme = "bronze")
	theme = lowertext("[theme]")
	var/page_color = "#17130f"
	var/panel_color = "#2b2117"
	var/panel_alt_color = "#251c14"
	var/outer_color = "#120d08"
	var/border_color = "#715735"
	var/edge_color = "#9a7440"
	var/accent_color = "#d2aa61"
	var/text_color = "#ead7b0"
	var/heading_color = "#f0d497"
	var/muted_color = "#bca47c"
	var/button_color = "#49351f"
	var/active_color = "#725027"
	var/bolt_color = "#c6a15c"
	if(theme == "blue" || theme == "admin")
		page_color = "#05090d"
		panel_color = "#101923"
		panel_alt_color = "#0d151e"
		outer_color = "#020406"
		border_color = "#304456"
		edge_color = "#405a70"
		accent_color = "#72c6eb"
		text_color = "#dce9f2"
		heading_color = "#f2f7fb"
		muted_color = "#9fb1c3"
		button_color = "#101923"
		active_color = "#193044"
	return {"
	@font-face{font-family:'Nexus Silkscreen';src:url('SilkscreenRegular.ttf') format('truetype');font-style:normal;font-weight:400;font-display:block}@font-face{font-family:'Nexus Silkscreen';src:url('SilkscreenBold.ttf') format('truetype');font-style:normal;font-weight:700;font-display:block}*{box-sizing:border-box;border-radius:0!important}html,body{margin:0;min-height:100%;background:[page_color];color:[text_color];font-family:'Nexus Silkscreen','Fixedsys','Lucida Console','Courier New',monospace}body.nexus-hud{background:[page_color];image-rendering:pixelated}.nexus-hud,.nexus-hud *{font-family:'Nexus Silkscreen','Fixedsys','Lucida Console','Courier New',monospace!important}.nexus-hud b,.nexus-hud strong{font-weight:700!important}.nexus-hud .hud-shell{min-height:100vh;padding:8px;background:[page_color]}.nexus-hud .hud-frame,.nexus-hud .hud-card{position:relative;background:[panel_color]!important;border:2px solid [outer_color]!important;outline:1px solid [border_color]!important;box-shadow:inset 0 0 0 2px [border_color],2px 2px 0 #000!important}.nexus-hud .hud-frame:before,.nexus-hud .hud-frame:after,.nexus-hud .hud-card:before,.nexus-hud .hud-card:after{content:'';position:absolute;z-index:3;left:4px;right:4px;height:2px;border-left:2px solid [bolt_color];border-right:2px solid [bolt_color];pointer-events:none}.nexus-hud .hud-frame:before,.nexus-hud .hud-card:before{top:4px}.nexus-hud .hud-frame:after,.nexus-hud .hud-card:after{bottom:4px}.nexus-hud .hud-panel{background:[panel_alt_color]!important;border:2px solid [outer_color]!important;box-shadow:inset 0 0 0 2px [border_color]!important}.nexus-hud .hud-title{color:[heading_color]!important;font-weight:bold;text-shadow:2px 2px #000;letter-spacing:1px}.nexus-hud .hud-muted{color:[muted_color]!important}.nexus-hud .hud-accent{color:[accent_color]!important}.nexus-hud .hud-button,.nexus-hud a.hud-button,.nexus-hud button.hud-button,.nexus-hud .hud-tab{position:relative;display:inline-block;background:[button_color]!important;border:2px solid [outer_color]!important;outline:1px solid [edge_color]!important;box-shadow:inset 0 0 0 1px [border_color],2px 2px 0 #000!important;color:[text_color]!important;font-weight:bold;text-transform:uppercase;text-decoration:none;text-align:center}.nexus-hud .hud-button:before,.nexus-hud .hud-tab:before{content:'';position:absolute;left:3px;right:3px;top:3px;height:2px;border-left:2px solid [bolt_color];border-right:2px solid [bolt_color];pointer-events:none}.nexus-hud .hud-button:hover,.nexus-hud .hud-tab:hover{background:[active_color]!important;color:[heading_color]!important;outline-color:[accent_color]!important}.nexus-hud .hud-button:active,.nexus-hud .hud-tab:active{transform:translate(1px,1px);box-shadow:inset 0 0 0 2px [outer_color]!important}.nexus-hud .hud-tab.active{background:[active_color]!important;color:[heading_color]!important;outline-color:[accent_color]!important;box-shadow:inset 3px 0 [accent_color],inset 0 0 0 1px [border_color],2px 2px 0 #000!important}.nexus-hud .hud-button.danger{background:#241718!important;outline-color:#7e4646!important;color:#ffd8d4!important;box-shadow:inset 3px 0 #e26767,2px 2px 0 #000!important}.nexus-hud .hud-sprite{display:flex;align-items:center;justify-content:center;background:[outer_color]!important;border:2px solid [outer_color]!important;outline:1px solid [border_color]!important;box-shadow:inset 0 0 0 2px [panel_alt_color]!important;overflow:hidden;image-rendering:pixelated}.nexus-hud .hud-sprite img{object-fit:contain;image-rendering:pixelated}.nexus-hud .hud-label{color:[accent_color]!important;font-size:9px;text-transform:uppercase;letter-spacing:.4px}.nexus-hud .hud-section-title{position:relative;margin:0;background:[panel_color]!important;border:2px solid [outer_color]!important;box-shadow:inset 4px 0 [accent_color],inset 0 0 0 2px [border_color]!important;color:[heading_color]!important;text-transform:uppercase;text-shadow:1px 1px #000}.nexus-hud input,.nexus-hud textarea,.nexus-hud select{background:[outer_color]!important;border:2px inset [edge_color]!important;color:[text_color]!important}.nexus-hud ::-webkit-scrollbar{width:14px;height:14px}.nexus-hud ::-webkit-scrollbar-track{background:[outer_color];border:1px solid [border_color]}.nexus-hud ::-webkit-scrollbar-thumb{background:[button_color];border:2px outset [edge_color]}
	"}

client/var/tmp
	datum/NexusHudWindow/nexus_hud_window
	datum/NexusChatHud/nexus_chat_hud
	datum/NexusInterfaceSettings/nexus_interface_settings
	list/nexus_chat_history
	nexus_hud_font_resources_ready = FALSE

obj/HudWindow
	mouse_opacity = 2
	plane = NEXUS_FIXED_HUD_PLANE
	layer = 120
	appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM
	var/tmp/datum/NexusHudWindow/window
	var/tmp/action_id

	Click(location, control, params)
		if(!window || !window.canInteract()) return
		window.handleAction(action_id)

datum/NexusHudWindow
	var/tmp/mob/owner
	var/tmp/list/elements = list()

	New(mob/new_owner)
		. = ..()
		owner = new_owner

	Del()
		clearElements()
		if(owner && owner.client && owner.client.nexus_hud_window == src)
			owner.client.nexus_hud_window = null
		. = ..()

	proc/canInteract()
		return owner && owner.client && usr == owner

	proc/clearElements()
		if(!islist(elements)) elements = list()
		for(var/obj/hud_object in elements)
			if(owner && owner.client) owner.client.screen -= hud_object
			del(hud_object)
		elements.Cut()

	proc/addElement(label, action_id, x, y, width, height, background_color = "#101923", border_color = "#40556b", accent_color = "", text_color = "#edf3fa", text_alignment = "left", font_size = 9, mouse_enabled = TRUE)
		return addElementAt(label, action_id, "LEFT:[round(x)],TOP:-[round(y)]", width, height, background_color, border_color, accent_color, text_color, text_alignment, font_size, mouse_enabled)

	proc/addElementAt(label, action_id, screen_location, width, height, background_color = "#101923", border_color = "#40556b", accent_color = "", text_color = "#edf3fa", text_alignment = "left", font_size = 9, mouse_enabled = TRUE)
		if(!owner || !owner.client) return
		var/obj/hud_object = new /obj/HudWindow
		hud_object.vars["window"] = src
		hud_object.vars["action_id"] = action_id
		hud_object.icon = getNexusHudLibraryIcon(width, height, background_color, border_color, accent_color)
		hud_object.screen_loc = screen_location
		hud_object.maptext_x = text_alignment == "left" ? 9 : 0
		hud_object.maptext_y = max(1, round((height - font_size - 2) / 2))
		hud_object.maptext_width = text_alignment == "left" ? width - 16 : width
		hud_object.maptext_height = height
		hud_object.maptext = "<div style='font-family:Courier New;font-size:[font_size]px;font-weight:bold;color:[text_color];text-align:[text_alignment];white-space:nowrap;text-shadow:1px 1px #000'>[label]</div>"
		hud_object.mouse_opacity = mouse_enabled ? 2 : 1
		elements += hud_object
		owner.client.screen += hud_object
		return hud_object

	proc/handleAction(action_id)
		return

mob/var
	nexus_chat_hud_x = 312
	nexus_chat_hud_width = 500
	nexus_chat_hud_height = 210
	nexus_chat_hud_collapsed = FALSE
	nexus_interface_layout = "overlay"
	nexus_legacy_tab_skills = TRUE
	nexus_legacy_tab_other = TRUE
	nexus_legacy_tab_items = TRUE
	nexus_legacy_tab_world = TRUE
	nexus_legacy_tab_admin = TRUE

proc/normalizeNexusInterfaceLayout(layout_id)
	if(layout_id == "side_tabs") return "side_tabs"
	return "overlay"

proc/getNexusChatMessageSeparatorHtml()
	return "<hr class='nexus-message-separator' size='1' color='#4b3927' style='display:block;width:100%;height:0;margin:5px 0;border:0;border-top:1px dashed #4b3927'>"

proc/closeNexusLegacyChatMarkup(message)
	var/rendered_message = "[message]"
	var/lower_message = lowertext(rendered_message)
	var/list/contained_tags = list("a", "b", "big", "blockquote", "center", "div", "em", "font", "i", "p", "small", "span", "strike", "strong", "sub", "sup", "table", "tbody", "td", "tfoot", "th", "thead", "tr", "u")
	var/list/open_tags = list()
	var/search_position = 1
	while(search_position <= length(lower_message))
		var/tag_start = findtext(lower_message, "<", search_position)
		if(!tag_start) break
		var/tag_end = findtext(lower_message, ">", tag_start + 1)
		if(!tag_end) break
		var/name_start = tag_start + 1
		while(name_start < tag_end && copytext(lower_message, name_start, name_start + 1) in list(" ", "\t", "\n")) name_start++
		var/is_closing_tag = copytext(lower_message, name_start, name_start + 1) == "/"
		if(is_closing_tag) name_start++
		var/name_end = name_start
		while(name_end < tag_end && findtext("abcdefghijklmnopqrstuvwxyz0123456789", copytext(lower_message, name_end, name_end + 1))) name_end++
		var/tag_name = copytext(lower_message, name_start, name_end)
		if(tag_name in contained_tags)
			if(is_closing_tag)
				for(var/open_index = open_tags.len, open_index >= 1, open_index--)
					if(open_tags[open_index] != tag_name) continue
					open_tags.Cut(open_index, open_index + 1)
					break
			else
				open_tags += tag_name
		search_position = tag_end + 1
	for(var/open_index = open_tags.len, open_index >= 1, open_index--)
		rendered_message += "</[open_tags[open_index]]>"
	return rendered_message

proc/getNexusChatEntryHtml(message)
	return "<div class='chat-entry'>[closeNexusLegacyChatMarkup(message)]</div>"

proc/nexusChatChannelAppearsInAll(channel)
	return normalizeNexusChatChannel(channel) != "combat"

client/proc/initializeNexusChatHistory()
	if(!islist(nexus_chat_history)) nexus_chat_history = list()
	for(var/channel in list("all", "combat", "ic", "ooc"))
		if(!islist(nexus_chat_history[channel])) nexus_chat_history[channel] = list()

client/proc/operator<<(out, target, window)
	if(istext(out) && !window && mob && mob.playerCharacter)
		initializeNexusChatHistory()
		var/list/all_entries = nexus_chat_history["all"]
		all_entries += "<span style='color:#d4ad65'>\[SYSTEM\]</span> [out]"
		while(all_entries.len > 300) all_entries.Cut(1, 2)
		if(nexus_chat_hud)
			nexus_chat_hud.scroll_offset = 0
			nexus_chat_hud.refreshMessages()
		mob.ChatLog(out, mob.key, "all")
		return
	return ..()

client/proc/receiveNexusHudChatMessage(message, channel = "all")
	if(!message) return
	initializeNexusChatHistory()
	channel = normalizeNexusChatChannel(channel)
	if(nexusChatChannelAppearsInAll(channel))
		var/list/all_entries = nexus_chat_history["all"]
		all_entries += "<span style='color:#9b815c'>\[[uppertext(channel)]\]</span> [message]"
		while(all_entries.len > 300) all_entries.Cut(1, 2)
	if(channel != "all")
		var/list/channel_entries = nexus_chat_history[channel]
		channel_entries += message
		while(channel_entries.len > 300) channel_entries.Cut(1, 2)
	if(nexus_chat_hud)
		nexus_chat_hud.scroll_offset = 0
		nexus_chat_hud.refreshMessages()

datum/NexusChatHud
	parent_type = /datum/NexusHudWindow
	var/tmp
		active_channel = "all"
		is_visible = TRUE
		scroll_offset = 0
		side_attach_generation = 0
		obj/HudWindow/message_panel

	Del()
		if(owner && owner.client)
			owner << browse(null, "window=nexuschatwindow.chat")
			if(owner.client.nexus_chat_hud == src) owner.client.nexus_chat_hud = null
		. = ..()

	proc/getVisibleMessageCount()
		if(owner && normalizeNexusInterfaceLayout(owner.nexus_interface_layout) == "side_tabs") return 36
		if(!owner) return 4
		return max(4, round((owner.nexus_chat_hud_height - 70) / 18))

	proc/buildMessageHtml()
		if(!owner || !owner.client) return ""
		owner.client.initializeNexusChatHistory()
		var/list/entries = owner.client.nexus_chat_history[active_channel]
		if(!islist(entries) || !entries.len) return "<span style='color:#8f7b5e'>No [uppertext(active_channel)] messages yet.</span>"
		var/visible_count = getVisibleMessageCount()
		var/end_index = max(1, entries.len - scroll_offset)
		var/start_index = max(1, end_index - visible_count + 1)
		var/rendered = ""
		for(var/entry_index = start_index, entry_index <= end_index, entry_index++)
			if(length(rendered)) rendered += getNexusChatMessageSeparatorHtml()
			rendered += getNexusChatEntryHtml(entries[entry_index])
		return rendered

	proc/getRightAnchoredLocation(panel_width, local_x, element_width, bottom_y)
		var/right_offset = 8 + panel_width - local_x - element_width
		return "RIGHT:-[right_offset],BOTTOM:[bottom_y]"

	proc/buildLink(label, action_id, class_name = "button")
		return "<a class='[class_name]' href='byond://?src=\ref[src]&action=[action_id]'>[html_encode(label)]</a>"

	proc/buildIconLink(label, action_id, icon_kind, class_name = "hud-button")
		var/icon_resource = getNexusPixelInterfaceIconResource(owner, icon_kind)
		return "<a class='[class_name]' href='byond://?src=\ref[src]&action=[action_id]'><img src='[icon_resource]' alt=''>[html_encode(label)]</a>"

	proc/buildHtml()
		prepareNexusHudBrowserResources(owner)
		var/tabs = ""
		var/list/chat_channels = list("all", "combat", "ic", "ooc")
		for(var/channel in chat_channels)
			var/tab_class = channel == active_channel ? "hud-tab active" : "hud-tab"
			tabs += buildLink(uppertext(channel), "channel&id=[channel]", tab_class)
		var/footer = buildLink("SAY", "say", "hud-button")
		footer += buildLink("OOC", "ooc", "hud-button")
		footer += buildLink("EMOTE", "emote", "hud-button")
		footer += buildLink("LOGS", "logs", "hud-button")
		return {"<!doctype html><html><head><meta charset='utf-8'><title>Nexus Chat</title><style>[getNexusHudBrowserCss("bronze")]
		html,body{width:100%;height:100%;overflow:hidden;font-size:10px}.chat-shell{height:100vh;display:flex;flex-direction:column;padding:6px;gap:5px}.chat-head{display:flex;align-items:center;gap:5px;flex:0 0 37px;padding:4px 7px}.chat-head .title-copy{display:flex;flex:1;min-width:0;flex-direction:column}.chat-head .hud-title{font-size:11px}.chat-head .hud-muted{font-size:7px}.chat-head .hud-button{padding:5px 7px;font-size:8px}.tabs,.footer{display:flex;width:100%;gap:5px;flex:0 0 31px;min-height:31px;overflow:hidden}.tabs .hud-tab{display:flex;flex:1 1 0;min-width:0;align-items:center;justify-content:center;padding:4px 2px}.footer{order:4}.footer .hud-button{display:flex;flex:1 1 25%;width:25%;min-width:0;align-items:center;justify-content:center;padding:4px 2px}.messages{order:3;flex:1 1 auto;min-height:0;padding:9px;overflow-y:auto;color:#ead7b0;font-size:9px;line-height:1.45}
		.chat-entry{display:block;width:100%;min-width:0;overflow-wrap:anywhere}
		</style><script>function nexusScrollMessages(){var panel=document.getElementById('messages');if(panel)panel.scrollTop=panel.scrollHeight;}function updateMessages(content){var panel=document.getElementById('messages');if(!panel)return;panel.innerHTML=content;nexusScrollMessages();}window.onload=function(){document.body.className='nexus-hud';nexusScrollMessages();}</script></head><body><main class='hud-shell chat-shell'><header class='hud-frame chat-head'><span class='title-copy'><b class='hud-title'>CHAT / [uppertext(active_channel)]</b><small class='hud-muted'>NEXUS COMMUNICATION LINK</small></span>[buildLink("UP", "scroll_up", "hud-button")][buildLink("DOWN", "scroll_down", "hud-button")][buildLink("HIDE", "hide", "hud-button danger")]</header><nav class='tabs'>[tabs]</nav><nav class='footer'>[footer]</nav><section class='hud-panel messages' id='messages'>[buildMessageHtml()]</section></main></body></html>"}

	proc/attachSidePanel()
		if(!owner || !owner.client) return
		var/show_tabs = owner.hasEnabledNexusLegacyTabs()
		winset(owner, "mainwindow.mainvsplit", "left=mapwindow;right=rpane;splitter=74")
		winset(owner, "rpane", "is-visible=true")
		winset(owner, "rpane.button9", "is-visible=true;text='Settings';command=Settings")
		winset(owner, "rpane.tabbutton", "is-visible=[show_tabs ? "true" : "false"]")
		if(show_tabs)
			winset(owner, "rpane.rpanewindow", "left=infowindow;right=nexuschatwindow;splitter=46")
			winset(owner, "infowindow", "is-visible=true")
			owner.tabs_hidden = FALSE
		else
			winset(owner, "rpane.rpanewindow", "left=;right=nexuschatwindow;splitter=0")
			winset(owner, "infowindow", "is-visible=false")
			owner.tabs_hidden = TRUE
		winset(owner, "nexuschatwindow", "is-visible=true")
		winset(owner, "nexuschatwindow.chat", "is-visible=false")
		winset(owner, "nexuschatwindow.command", "is-visible=true")
		for(var/window_id in list("outputwindow", "chat", "chat2", "chat3")) winset(owner, window_id, "is-visible=false")
		queueSideBrowserRefresh()

	proc/refreshSideBrowser()
		if(!is_visible || !owner || !owner.client || !owner.playerCharacter) return
		if(normalizeNexusInterfaceLayout(owner.nexus_interface_layout) != "side_tabs") return
		winset(owner, "nexuschatwindow", "is-visible=true")
		winset(owner, "nexuschatwindow.chat", "is-visible=true")
		owner << browse(buildHtml(), "window=nexuschatwindow.chat")

	proc/queueSideBrowserRefresh()
		side_attach_generation++
		var/expected_generation = side_attach_generation
		spawn(1)
			if(src && expected_generation == side_attach_generation) refreshSideBrowser()
		spawn(5)
			if(src && expected_generation == side_attach_generation) refreshSideBrowser()

	proc/attachOverlay()
		if(!owner || !owner.client) return
		side_attach_generation++
		owner << browse(null, "window=nexuschatwindow.chat")
		winset(owner, "mainwindow.mainvsplit", "left=mapwindow;right=;splitter=100")
		winset(owner, "mapwindow", "is-visible=true")
		winset(owner, "mapwindow.map", "is-visible=true")
		winset(owner, "mpane.mpanewindow", "right=;splitter=100")
		for(var/window_id in list("rpane", "infowindow", "nexuschatwindow", "outputwindow", "chat", "chat2", "chat3")) winset(owner, window_id, "is-visible=false")

	proc/attachTabsOnly()
		if(!owner || !owner.client) return
		side_attach_generation++
		owner << browse(null, "window=nexuschatwindow.chat")
		winset(owner, "mainwindow.mainvsplit", "left=mapwindow;right=rpane;splitter=74")
		winset(owner, "rpane", "is-visible=true")
		winset(owner, "rpane.rpanewindow", "left=infowindow;right=;splitter=100")
		winset(owner, "infowindow", "is-visible=true")
		winset(owner, "nexuschatwindow", "is-visible=false")
		owner.tabs_hidden = FALSE

	proc/refreshOverlay()
		if(!owner || !owner.client) return
		var/panel_y = 8
		var/panel_width = Clamp(round(owner.nexus_chat_hud_width), 360, 820)
		var/panel_height = Clamp(round(owner.nexus_chat_hud_height), 130, 460)
		owner.nexus_chat_hud_width = panel_width
		owner.nexus_chat_hud_height = panel_height
		if(owner.nexus_chat_hud_collapsed) panel_height = 24
		addElementAt("", null, getRightAnchoredLocation(panel_width, 0, panel_width, panel_y), panel_width, panel_height, "#201810", "#765a35", "", "#ead39f", "left", 9, FALSE)
		var/header_y = panel_y + panel_height - 22
		var/control_width = 21
		var/list/header_actions = list("scroll_up" = "^", "scroll_down" = "v", "width_down" = "W-", "width_up" = "W+", "height_down" = "H-", "height_up" = "H+", "collapse" = owner.nexus_chat_hud_collapsed ? "+" : "_")
		var/control_x = panel_width - 4 - (header_actions.len * control_width)
		addElementAt("CHAT / [uppertext(active_channel)]", null, getRightAnchoredLocation(panel_width, 4, max(60, control_x - 4), header_y), max(60, control_x - 4), 20, "#382719", "#8f6c3b", "#d2aa61", "#f1d69c", "left", 9, FALSE)
		for(var/action_id in header_actions)
			addElementAt(header_actions[action_id], action_id, getRightAnchoredLocation(panel_width, control_x, control_width, header_y), control_width, 20, "#46321d", "#987140", "", "#f2d8a0", "center", 8)
			control_x += control_width
		if(owner.nexus_chat_hud_collapsed) return
		var/tab_y = panel_y + panel_height - 43
		var/tab_width = round((panel_width - 8) / 4)
		var/tab_x = 4
		for(var/channel in list("all", "combat", "ic", "ooc"))
			var/is_active = channel == active_channel
			addElementAt(uppertext(channel), "channel:[channel]", getRightAnchoredLocation(panel_width, tab_x, tab_width, tab_y), tab_width, 19, is_active ? "#725027" : "#302319", is_active ? "#d2aa61" : "#725735", is_active ? "#e0bd74" : "", is_active ? "#fff0bd" : "#cbb389", "center", 8)
			tab_x += tab_width
		var/footer_height = 22
		var/message_y = panel_y + footer_height
		var/message_height = max(40, panel_height - 68)
		message_panel = addElementAt("", null, getRightAnchoredLocation(panel_width, 4, panel_width - 8, message_y), panel_width - 8, message_height, "#130f0b", "#574128", "", "#ead7b0", "left", 8, FALSE)
		message_panel.maptext_x = 7
		message_panel.maptext_y = 5
		message_panel.maptext_width = panel_width - 22
		message_panel.maptext_height = message_height - 10
		message_panel.maptext = "<div style='font-family:Courier New;font-size:8px;color:#ead7b0'>[buildMessageHtml()]</div>"
		var/list/footer_actions = list("cmd" = "CMD", "say" = "SAY", "ooc" = "OOC", "emote" = "EMOTE", "logs" = "LOGS")
		var/footer_width = round((panel_width - 8) / footer_actions.len)
		var/footer_x = 4
		for(var/action_id in footer_actions)
			addElementAt(footer_actions[action_id], action_id, getRightAnchoredLocation(panel_width, footer_x, footer_width, panel_y + 2), footer_width, 18, "#3c2b1a", "#846238", "", "#ead09a", "center", 8)
			footer_x += footer_width

	proc/applyLayout()
		clearElements()
		if(!owner || !owner.client) return
		owner.nexus_interface_layout = normalizeNexusInterfaceLayout(owner.nexus_interface_layout)
		if(!is_visible)
			if(owner.nexus_interface_layout == "side_tabs" && owner.hasEnabledNexusLegacyTabs()) attachTabsOnly()
			else attachOverlay()
			winset(owner, "mapwindow.map", "focus=true")
			return
		if(owner.nexus_interface_layout == "side_tabs") attachSidePanel()
		else attachOverlay()
		refresh()

	proc/refresh()
		clearElements()
		message_panel = null
		if(!is_visible || !owner || !owner.client || !owner.playerCharacter) return
		if(normalizeNexusInterfaceLayout(owner.nexus_interface_layout) == "side_tabs") refreshSideBrowser()
		else refreshOverlay()

	proc/refreshMessages()
		if(!is_visible || !owner || !owner.client || !owner.playerCharacter) return
		if(normalizeNexusInterfaceLayout(owner.nexus_interface_layout) == "side_tabs")
			owner << output(buildMessageHtml(), "nexuschatwindow.chat:updateMessages")
			return
		if(message_panel && message_panel in elements)
			message_panel.maptext = "<div style='font-family:Courier New;font-size:8px;color:#ead7b0'>[buildMessageHtml()]</div>"
			return
		refresh()

	handleAction(action_id)
		if(!owner || !owner.client) return
		if(findtext(action_id, "channel:") == 1)
			active_channel = normalizeNexusChatChannel(copytext(action_id, 9))
			scroll_offset = 0
		else switch(action_id)
			if("scroll_up")
				owner.client.initializeNexusChatHistory()
				var/list/entries = owner.client.nexus_chat_history[active_channel]
				scroll_offset = min(max(0, entries.len - 1), scroll_offset + getVisibleMessageCount())
			if("scroll_down") scroll_offset = max(0, scroll_offset - getVisibleMessageCount())
			if("width_down") owner.nexus_chat_hud_width = max(360, owner.nexus_chat_hud_width - 64)
			if("width_up") owner.nexus_chat_hud_width = min(820, owner.nexus_chat_hud_width + 64)
			if("height_down") owner.nexus_chat_hud_height = max(130, owner.nexus_chat_hud_height - 48)
			if("height_up") owner.nexus_chat_hud_height = min(460, owner.nexus_chat_hud_height + 48)
			if("collapse") owner.nexus_chat_hud_collapsed = !owner.nexus_chat_hud_collapsed
			if("cmd") owner.showNexusCommandPrompt()
			if("say") spawn() owner.Say()
			if("ooc") spawn() owner.GlobalSay()
			if("emote") owner.showNexusEmoteEditor()
			if("logs") owner.showNexusPlayerLogs(active_channel)
			if("hide")
				setVisible(FALSE)
				return
		refresh()

	Topic(href, list/href_list)
		if(!owner || !owner.client || usr != owner) return
		var/action_id = href_list["action"]
		if(action_id == "channel")
			active_channel = normalizeNexusChatChannel(href_list["id"])
			scroll_offset = 0
			refresh()
			return
		handleAction(action_id)

	proc/setVisible(new_visibility)
		is_visible = !!new_visibility
		if(owner && owner.client) owner.client.show_chatbox = is_visible
		applyLayout()

mob/proc/hasEnabledNexusLegacyTabs()
	return nexus_legacy_tab_skills || nexus_legacy_tab_other || nexus_legacy_tab_items || (IsAdmin() && (nexus_legacy_tab_world || nexus_legacy_tab_admin))

mob/proc/isNexusLegacyTabEnabled(tab_id)
	if(normalizeNexusInterfaceLayout(nexus_interface_layout) != "side_tabs") return FALSE
	switch(lowertext(tab_id))
		if("skills") return nexus_legacy_tab_skills
		if("other") return nexus_legacy_tab_other
		if("items") return nexus_legacy_tab_items
		if("world") return IsAdmin() && nexus_legacy_tab_world
		if("admin") return IsAdmin() && nexus_legacy_tab_admin
	return FALSE

datum/NexusInterfaceSettings
	var/tmp/mob/owner

	New(mob/new_owner)
		. = ..()
		owner = new_owner

	Del()
		if(owner)
			owner << browse(null, "window=NexusInterfaceSettings")
			if(owner.client && owner.client.nexus_interface_settings == src) owner.client.nexus_interface_settings = null
		owner = null
		. = ..()

	proc/buildToggle(label, description, action_id, enabled)
		return "<a class='option [enabled ? "active" : ""]' href='byond://?src=\ref[src]&action=toggle&id=[action_id]'><b>[html_encode(label)]</b><span>[html_encode(description)]</span><em>[enabled ? "ON" : "OFF"]</em></a>"

	proc/buildHudControls()
		return {"<div class='hud-grid'><article class='hud-control'><b>OVERHEAD VITALS</b><span>Offset X [owner.nexus_overhead_vitals_offset_x] / Y [owner.nexus_overhead_vitals_offset_y]. Moves the bars below the character together with the Sense percentage.</span><div class='nudge'><a href='byond://?src=\ref[src]&action=hud_move&id=overhead_left'>LEFT</a><a href='byond://?src=\ref[src]&action=hud_move&id=overhead_right'>RIGHT</a><a href='byond://?src=\ref[src]&action=hud_move&id=overhead_up'>UP</a><a href='byond://?src=\ref[src]&action=hud_move&id=overhead_down'>DOWN</a><a href='byond://?src=\ref[src]&action=hud_set&id=overhead'>SET X/Y</a><a href='byond://?src=\ref[src]&action=hud_reset&id=overhead'>RESET</a></div></article><article class='hud-control'><b>MAIN VITALS PANEL</b><span>Position X [owner.nexus_main_vitals_x] / Y [owner.nexus_main_vitals_y]. You can also drag the panel directly during play.</span><div class='nudge'><a href='byond://?src=\ref[src]&action=hud_move&id=main_left'>LEFT</a><a href='byond://?src=\ref[src]&action=hud_move&id=main_right'>RIGHT</a><a href='byond://?src=\ref[src]&action=hud_move&id=main_up'>UP</a><a href='byond://?src=\ref[src]&action=hud_move&id=main_down'>DOWN</a><a href='byond://?src=\ref[src]&action=hud_set&id=main'>SET X/Y</a><a href='byond://?src=\ref[src]&action=hud_reset&id=main'>RESET</a></div></article></div>"}

	proc/buildHtml()
		var/overlay_active = owner.nexus_interface_layout == "overlay"
		var/side_active = owner.nexus_interface_layout == "side_tabs"
		var/tab_options = buildToggle("Skills", "Techniques in a native clickable tab.", "skills", owner.nexus_legacy_tab_skills)
		tab_options += buildToggle("Other", "Stats, Sense, science and miscellaneous information.", "other", owner.nexus_legacy_tab_other)
		tab_options += buildToggle("Items", "Inventory objects with native click and context actions.", "items", owner.nexus_legacy_tab_items)
		if(owner.IsAdmin())
			tab_options += buildToggle("World", "Connected characters and world information.", "world", owner.nexus_legacy_tab_world)
			tab_options += buildToggle("Admin", "Administrative targets and inspection access.", "admin", owner.nexus_legacy_tab_admin)
		var/hud_controls = buildHudControls()
		return {"<!doctype html><html><head><meta charset='utf-8'><title>Interface Settings</title><style>[getNexusRpgBrowserCss()]
		*{box-sizing:border-box}html,body{margin:0;min-height:100%;font:12px 'Courier New',monospace}.shell{padding:12px}.head{display:flex;align-items:center;border:3px ridge #84643a;padding:10px}.head h1{margin:0 auto 0 0;font-size:18px}.close{padding:7px 10px}.layouts,.options,.hud-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:8px;margin-top:9px}.layout,.option,.hud-control{position:relative;display:block;min-height:88px;padding:12px;border:3px ridge #735631;background:#2b2117;color:#e8d4aa;text-decoration:none}.layout,.option{padding-right:70px}.layout.active,.option.active{border-color:#d0a65d;background:#4a351e}.layout b,.layout span,.option b,.option span,.hud-control b,.hud-control span{display:block}.layout b,.option b,.hud-control b{color:#f0d497;font-size:14px}.layout span,.option span,.hud-control span{margin-top:7px;color:#bca47c;line-height:1.4}.layout em,.option em{position:absolute;right:12px;top:12px;color:#ffe6a8;font-style:normal;font-weight:bold}.section{margin-top:12px;padding:8px;border:2px solid #715735;background:#211a13}.section h2{margin:0 0 8px;padding:7px;font-size:13px}.nudge{display:grid;grid-template-columns:repeat(3,1fr);gap:5px;margin-top:10px}.nudge a{padding:6px 3px;border:2px outset #9a7440;background:#49351f;color:#f2d79e;text-align:center;text-decoration:none;font-weight:bold}.note{margin-top:9px;padding:8px;border-left:4px solid #a77a3f;color:#bca47c}@media(max-width:650px){.layouts,.options,.hud-grid{grid-template-columns:1fr}}
		</style></head><body><main class='shell'><header class='head'><h1>INTERFACE &amp; HUD SETTINGS</h1><a class='close' href='byond://?src=\ref[src]&action=close'>CLOSE</a></header><div class='layouts'><a class='layout [overlay_active ? "active" : ""]' href='byond://?src=\ref[src]&action=layout&id=overlay'><b>CLASSIC OVERLAY</b><span>Compact rustic chat over the map, with resize controls and CMD below it.</span><em>[overlay_active ? "ACTIVE" : "SELECT"]</em></a><a class='layout [side_active ? "active" : ""]' href='byond://?src=\ref[src]&action=layout&id=side_tabs'><b>SIDE + TABS</b><span>Native tabs above a smaller chat and permanent CMD bar outside the map.</span><em>[side_active ? "ACTIVE" : "SELECT"]</em></a></div><section class='section'><h2>HUD POSITION</h2>[hud_controls]<div class='note'>Overhead adjustments move the three bars and Sense percentage together. Typing and Say always remain above the character. All positions are saved for this account.</div></section><section class='section'><h2>LEGACY TAB CATEGORIES</h2><div class='options'>[tab_options]</div><div class='note'>These switches control the legacy categories shown in Side + Tabs mode. Preferences are saved for this account.</div></section></main></body></html>"}

	proc/show()
		if(!owner || !owner.client)
			del(src)
			return
		owner << browse(buildHtml(), "window=NexusInterfaceSettings;size=760x620;can_resize=true;can_close=true")

	Topic(href, list/href_list)
		if(!owner || !owner.client || usr != owner) return
		var/layout_changed = FALSE
		switch(href_list["action"])
			if("layout")
				owner.nexus_interface_layout = normalizeNexusInterfaceLayout(href_list["id"])
				layout_changed = TRUE
			if("toggle")
				layout_changed = TRUE
				switch(href_list["id"])
					if("skills") owner.nexus_legacy_tab_skills = !owner.nexus_legacy_tab_skills
					if("other") owner.nexus_legacy_tab_other = !owner.nexus_legacy_tab_other
					if("items") owner.nexus_legacy_tab_items = !owner.nexus_legacy_tab_items
					if("world") owner.nexus_legacy_tab_world = !owner.nexus_legacy_tab_world
					if("admin") if(owner.IsAdmin()) owner.nexus_legacy_tab_admin = !owner.nexus_legacy_tab_admin
			if("hud_move")
				switch(href_list["id"])
					if("overhead_left") owner.setNexusOverheadVitalsOffset(owner.nexus_overhead_vitals_offset_x - 4, owner.nexus_overhead_vitals_offset_y)
					if("overhead_right") owner.setNexusOverheadVitalsOffset(owner.nexus_overhead_vitals_offset_x + 4, owner.nexus_overhead_vitals_offset_y)
					if("overhead_up") owner.setNexusOverheadVitalsOffset(owner.nexus_overhead_vitals_offset_x, owner.nexus_overhead_vitals_offset_y + 4)
					if("overhead_down") owner.setNexusOverheadVitalsOffset(owner.nexus_overhead_vitals_offset_x, owner.nexus_overhead_vitals_offset_y - 4)
					if("main_left") owner.setNexusMainVitalsPosition(owner.nexus_main_vitals_x - 8, owner.nexus_main_vitals_y)
					if("main_right") owner.setNexusMainVitalsPosition(owner.nexus_main_vitals_x + 8, owner.nexus_main_vitals_y)
					if("main_up") owner.setNexusMainVitalsPosition(owner.nexus_main_vitals_x, owner.nexus_main_vitals_y + 8)
					if("main_down") owner.setNexusMainVitalsPosition(owner.nexus_main_vitals_x, owner.nexus_main_vitals_y - 8)
			if("hud_set")
				var/current_x = href_list["id"] == "overhead" ? owner.nexus_overhead_vitals_offset_x : owner.nexus_main_vitals_x
				var/current_y = href_list["id"] == "overhead" ? owner.nexus_overhead_vitals_offset_y : owner.nexus_main_vitals_y
				var/new_x = input(owner, "Horizontal pixel position or offset.", "HUD X", current_x) as num|null
				if(isnull(new_x)) return
				var/new_y = input(owner, "Vertical pixel position or offset.", "HUD Y", current_y) as num|null
				if(isnull(new_y)) return
				if(href_list["id"] == "overhead") owner.setNexusOverheadVitalsOffset(new_x, new_y)
				else owner.setNexusMainVitalsPosition(new_x, new_y)
			if("hud_reset")
				if(href_list["id"] == "overhead") owner.setNexusOverheadVitalsOffset(0, 0)
				else owner.setNexusMainVitalsPosition(8, 8)
			if("close")
				owner.save_player_settings()
				del(src)
				return
		if(layout_changed) owner.applyNexusInterfaceLayout()
		owner.save_player_settings()
		show()

mob/proc/showNexusInterfaceSettings()
	if(!client || !playerCharacter) return
	if(client.nexus_interface_settings) del(client.nexus_interface_settings)
	client.nexus_interface_settings = new /datum/NexusInterfaceSettings(src)
	client.nexus_interface_settings.show()

mob/proc/applyNexusInterfaceLayout()
	if(!client || !playerCharacter) return
	nexus_interface_layout = normalizeNexusInterfaceLayout(nexus_interface_layout)
	if(!client.nexus_chat_hud) initializeNexusChatHud()
	else client.nexus_chat_hud.applyLayout()

mob/proc/hideNexusLegacyInterface()
	if(!client) return
	winset(src, "Bars", "is-visible=false")
	if(client.nexus_chat_hud) client.nexus_chat_hud.applyLayout()
	else
		winset(src, "mainwindow.mainvsplit", "left=mapwindow;right=;splitter=100")
		for(var/window_id in list("rpane", "infowindow", "nexuschatwindow", "outputwindow", "chat", "chat2", "chat3")) winset(src, window_id, "is-visible=false")

mob/proc/initializeNexusChatHud()
	if(!client || !playerCharacter) return
	if(client.nexus_chat_hud) del(client.nexus_chat_hud)
	client.nexus_chat_hud = new /datum/NexusChatHud(src)
	client.nexus_chat_hud.setVisible(client.show_chatbox)

mob/proc/toggleNexusChatHud()
	if(!client || !playerCharacter) return
	if(!client.nexus_chat_hud) initializeNexusChatHud()
	else client.nexus_chat_hud.setVisible(!client.nexus_chat_hud.is_visible)
