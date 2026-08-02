proc/nexusCharacterNumber(value, precision = 0.01)
	if(!nexusIsFiniteNumber(value)) return "--"
	if(abs(value) >= 1000000) return Commas(value)
	return "[round(value, precision)]"

proc/nexusCharacterRow(label, value, detail = "", accent_color = "#64c9ff")
	return "<div class='stat-row' style='border-left-color:[accent_color]'><span>[html_encode(label)]</span><b>[html_encode("[value]")]</b><small>[html_encode("[detail]")]</small></div>"

client/var/tmp/datum/NexusCharacterSheetWindow/nexus_character_sheet

mob/proc/buildCharacterSkillCards()
	var/list/skill_names = list()
	var/list/skills_by_name = list()
	for(var/obj/skill in contents)
		if(!skill.hotbar_type) continue
		var/label = "[skill]"
		var/unique_label = label
		var/duplicate_index = 2
		while(skills_by_name[unique_label])
			unique_label = "[label] #[duplicate_index]"
			duplicate_index++
		skill_names += unique_label
		skills_by_name[unique_label] = skill
	skill_names = dd_sortedtextlist(skill_names)
	var/html = ""
	for(var/skill_name in skill_names)
		var/obj/skill = skills_by_name[skill_name]
		var/mastery_text = nexusIsFiniteNumber(skill.Mastery) ? "Mastery [round(skill.Mastery, 0.1)]%" : "Learned"
		html += "<div class='skill-card'><b>[html_encode("[skill]")]</b><span>[html_encode("[skill.hotbar_type]")]</span><em>[mastery_text]</em></div>"
	if(!html) html = "<p class='empty'>No techniques registered on this character.</p>"
	return html

mob/proc/buildCharacterMilestoneCards()
	initializeMilestoneCatalog()
	var/html = ""
	for(var/milestone_id in milestone_catalog)
		var/datum/MilestoneDefinition/milestone = milestone_catalog[milestone_id]
		var/rank = getMilestoneRank(milestone_id)
		var/state_class = rank ? "milestone owned" : "milestone"
		html += "<div class='[state_class]'><b>[html_encode(milestone.name)]</b><span>[rank]/[milestone.max_rank]</span><small>[html_encode(milestone.description)]</small></div>"
	return html

mob/proc/buildCharacterSheetHtml(portrait_resource, datum/topic_source = null, restore_scroll_y = 0)
	if(!topic_source) topic_source = src
	var/topic_reference = "\ref[topic_source]"
	var/live_window = topic_source != src
	var/live_script = live_window ? getNexusLiveBrowserScript(topic_source, restore_scroll_y) : ""
	syncMilestoneProgression(silent = TRUE)
	syncTechnologyProgression(silent = TRUE)
	syncProfessionProgression()
	var/health_percent = hudPercentage(Health)
	var/energy_percent = hudPercentage(Ki, max_ki)
	var/stamina_percent = hudPercentage(stamina, max_stamina)
	var/anger_percent = max_anger > 100 ? Clamp((anger - 100) / (max_anger - 100) * 100, 0, 100) : 0
	var/lethal_time = max(0, round((lethal_combat_until - world.time) / 10, 0.1))
	var/lethal_label = sparring_mode == LETHAL_COMBAT ? "Lethal intent" : "Casual intent"
	var/equipped_armor = armor_obj ? "[armor_obj]" : "None"
	var/equipped_weapon = equipped_sword ? "[equipped_sword]" : "Unarmed"
	var/path_text = islist(player_tech_paths) && length(player_tech_paths) ? jointext(player_tech_paths, ", ") : "None selected"
	var/class_text = Class ? "[Class]" : "No class"
	var/alignment_text = alignment ? "[alignment]" : "Unaligned"
	var/admin_button = IsAdmin() ? "<a class='top-button admin' href='byond://?src=[topic_reference]&action=open_admin_inspector'>ADMIN INSPECTOR</a>" : ""
	var/window_controls = live_window ? "<div class='mode live'>LIVE / 1s</div><a class='top-button' href='byond://?src=[topic_reference]&action=close'>CLOSE</a>" : "<a class='top-button' href='byond://?src=[topic_reference]&action=refresh_character_sheet'>REFRESH</a>"
	var/skill_cards = buildCharacterSkillCards()
	var/milestone_cards = buildCharacterMilestoneCards()
	var/stats_html = ""
	stats_html += nexusCharacterRow("Strength", nexusCharacterNumber(StatViewThing(Swordless_strength(), "Str")), "Raw [nexusCharacterNumber(Swordless_strength())] / Growth [nexusCharacterNumber(strmod)]x", "#ff7b6c")
	stats_html += nexusCharacterRow("Durability", nexusCharacterNumber(StatViewThing(End, "End")), "Raw [nexusCharacterNumber(End)] / Growth [nexusCharacterNumber(endmod)]x", "#f3ad58")
	stats_html += nexusCharacterRow("Force", nexusCharacterNumber(StatViewThing(Pow, "Pow")), "Raw [nexusCharacterNumber(Pow)] / Growth [nexusCharacterNumber(formod)]x", "#b584ff")
	stats_html += nexusCharacterRow("Resistance", nexusCharacterNumber(StatViewThing(Res, "Res")), "Raw [nexusCharacterNumber(Res)] / Growth [nexusCharacterNumber(resmod)]x", "#7c9cff")
	stats_html += nexusCharacterRow("Speed", nexusCharacterNumber(StatViewThing(Spd, "Spd")), "Raw [nexusCharacterNumber(Spd)] / Growth [nexusCharacterNumber(spdmod)]x", "#59d3b2")
	stats_html += nexusCharacterRow("Accuracy", nexusCharacterNumber(StatViewThing(Off, "Off")), "Raw [nexusCharacterNumber(Off)] / Growth [nexusCharacterNumber(offmod)]x", "#70c6ff")
	stats_html += nexusCharacterRow("Reflex", nexusCharacterNumber(StatViewThing(Def, "Def")), "Raw [nexusCharacterNumber(Def)] / Growth [nexusCharacterNumber(defmod)]x", "#4fd4e8")
	var/growth_html = ""
	growth_html += nexusCharacterRow("Regeneration", nexusCharacterNumber(regen + Regen_Mult - 1), "Recovery of Health", "#ff6688")
	growth_html += nexusCharacterRow("Recovery", nexusCharacterNumber(recov + Recov_Mult - 1), "Recovery of Energy and Stamina", "#55cfff")
	growth_html += nexusCharacterRow("Energy efficiency", "[nexusCharacterNumber(Eff)]x", "Energy gain modifier", "#69d9ff")
	growth_html += nexusCharacterRow("Anger capacity", "[nexusCharacterNumber(max_anger / 100)]x", "Current [round(anger)] / [round(max_anger)]", "#ff7b55")
	growth_html += nexusCharacterRow("Meditation", "[nexusCharacterNumber(med_mod)]x", "Meditation BP gain", "#c08cff")
	growth_html += nexusCharacterRow("Mastery", "[nexusCharacterNumber(mastery_mod)]x", "Technique mastery gain", "#97a9ff")

	return {"<!doctype html>
	<html><head><meta charset='utf-8'><title>Character</title><style>[getNexusRpgBrowserCss()]
	*{box-sizing:border-box}html,body{margin:0;min-height:100%;background:#071018;color:#eef6f2;font:13px Arial,sans-serif}body{background:radial-gradient(circle at 70% 10%,#244634 0,#10291f 30%,#09151a 68%,#050a0e 100%)}
	.shell{min-height:100vh;padding:12px}.topbar{height:52px;display:flex;align-items:center;gap:8px;padding:8px 12px;border:1px solid #8ebbb0;background:linear-gradient(90deg,rgba(24,54,46,.96),rgba(20,39,49,.96));box-shadow:inset 0 0 18px #07110f}.title{margin-right:auto}.title b{display:block;font:22px Georgia,serif;letter-spacing:2px}.title span{font-size:10px;color:#a9c9bf;text-transform:uppercase;letter-spacing:2px}.top-button{padding:9px 13px;border:1px solid #6f948d;background:#172b2b;color:#dcf5ed;text-decoration:none;font-weight:bold;font-size:10px;letter-spacing:1px}.top-button.admin{border-color:#d39a5d;color:#ffd7a7}.mode{padding:7px 10px;border-left:3px solid #4f7180;background:#101d24}.mode.lethal{border-color:#ff5366}.mode.rp{border-color:#ff9b54}
	.mode.live{border-color:#62c86f;color:#9ce8a5}
	.hero{display:grid;grid-template-columns:230px minmax(330px,1fr) minmax(300px,.8fr);gap:9px;margin-top:9px}.panel{border:1px solid #729d94;background:rgba(14,30,29,.9);box-shadow:inset 0 0 0 2px #0a1517,inset 0 0 24px rgba(0,0,0,.45)}.panel h2{margin:0;padding:8px 10px;background:linear-gradient(90deg,#294c42,#1d343a);border-bottom:1px solid #739d94;font:15px Georgia,serif;letter-spacing:1px}.panel-body{padding:9px}.profile{text-align:center}.portrait{height:150px;display:flex;align-items:center;justify-content:center;background:radial-gradient(circle,#315749,#102520 64%,#091313);border:1px solid #597f75;margin-bottom:8px}.portrait img{width:128px;height:128px;object-fit:contain;image-rendering:pixelated}.name{font:20px Georgia,serif;color:#fff2cb}.subtitle{color:#a9cabe;margin:3px 0 12px}.identity{display:grid;grid-template-columns:1fr 1fr;text-align:left;gap:5px}.identity div{padding:6px;background:#101f20;border-left:2px solid #527e75}.identity small{display:block;color:#77968f;font-size:9px;text-transform:uppercase}.identity b{font-size:12px}
	.meters{display:grid;gap:6px;margin-top:9px}.meter{position:relative;height:28px;background:#0a151b;border:1px solid #314c50;overflow:hidden}.meter i{display:block;height:100%;opacity:.72}.meter span{position:absolute;inset:0;padding:6px 8px;text-shadow:1px 1px #000;font-weight:bold}.stat-grid{display:grid;grid-template-columns:1fr 1fr;gap:6px}.stat-row{display:grid;grid-template-columns:1fr auto;min-height:47px;padding:7px 9px;border-left:3px solid;background:#101d21}.stat-row span{font-weight:bold}.stat-row b{font:17px Consolas,monospace;color:#fff}.stat-row small{grid-column:1/3;color:#829c9d;margin-top:3px}.section-grid{display:grid;grid-template-columns:1fr 1fr;gap:9px;margin-top:9px}.progress-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:6px}.progress-card{padding:10px;border:1px solid #365853;background:#10211f}.progress-card small{display:block;color:#86a39d;text-transform:uppercase;font-size:9px}.progress-card b{display:block;font:18px Consolas,monospace;margin:4px 0}.progress-card span{font-size:10px;color:#bad0c9}.skill-list{display:grid;grid-template-columns:repeat(3,1fr);gap:5px;max-height:320px;overflow:auto}.skill-card{padding:8px;border:1px solid #34514e;background:#101e22}.skill-card b,.skill-card span,.skill-card em{display:block}.skill-card span{color:#76cfe6;font-size:9px;text-transform:uppercase;margin:3px 0}.skill-card em{font-style:normal;color:#91aaa7;font-size:10px}.milestone-list{display:grid;grid-template-columns:repeat(2,1fr);gap:5px;max-height:320px;overflow:auto}.milestone{position:relative;padding:8px;border:1px solid #344741;background:#101a1c;opacity:.68}.milestone.owned{border-color:#b38b49;background:#2a2419;opacity:1}.milestone b{display:block;color:#f0d69c}.milestone span{position:absolute;right:8px;top:8px;color:#fff}.milestone small{display:block;margin-top:5px;color:#a8b5ad}.empty{color:#82968f}.footer{margin-top:9px;padding:8px;text-align:center;color:#6f8984;font-size:10px}@media(max-width:900px){.hero{grid-template-columns:210px 1fr}.hero>.panel:last-child{grid-column:1/3}.section-grid{grid-template-columns:1fr}.skill-list{grid-template-columns:repeat(2,1fr)}}
	</style>[live_script]</head><body><div class='shell'>
	<div class='topbar'><div class='title'><b>CHARACTER</b><span>Detailed DU assessment</span></div><div class='mode [sparring_mode == LETHAL_COMBAT ? "lethal" : ""]'>[lethal_label]</div><div class='mode [rp_mode ? "rp" : ""]'>RP Mode [rp_mode ? "ON" : "OFF"]</div>[admin_button][window_controls]</div>
	<div class='hero'><section class='panel profile'><h2>Profile</h2><div class='panel-body'><div class='portrait'><img src='[portrait_resource]'></div><div class='name'>[html_encode("[name]")]</div><div class='subtitle'>[html_encode("[Race]")] / [html_encode(class_text)]</div><div class='identity'><div><small>Alignment</small><b>[html_encode(alignment_text)]</b></div><div><small>Age</small><b>[round(Age)]</b></div><div><small>Gender</small><b>[html_encode("[gender]")]</b></div><div><small>Battle Power</small><b>[Commas(Scouter_Reading(src))]</b></div><div><small>Weapon</small><b>[html_encode(equipped_weapon)]</b></div><div><small>Armor</small><b>[html_encode(equipped_armor)]</b></div></div></div></section>
	<section class='panel'><h2>Combat Attributes</h2><div class='panel-body'><div class='stat-grid'>[stats_html]</div></div></section>
	<section class='panel'><h2>Vitals & Growth</h2><div class='panel-body'><div class='meters'><div class='meter'><i style='width:[Clamp(health_percent,0,100)]%;background:#e94d68'></i><span>Health [health_percent]%</span></div><div class='meter'><i style='width:[Clamp(energy_percent,0,100)]%;background:#36bfe8'></i><span>Energy [round(Ki)] / [round(max_ki)]</span></div><div class='meter'><i style='width:[Clamp(stamina_percent,0,100)]%;background:#e5b84e'></i><span>Stamina [stamina_percent]%</span></div><div class='meter'><i style='width:[Clamp(willpower/getMaxWillpower()*100,0,100)]%;background:#af78e8'></i><span>Willpower [round(willpower)] / [round(getMaxWillpower())]</span></div><div class='meter'><i style='width:[anger_percent]%;background:#e56a3d'></i><span>Anger [round(anger)] / [round(max_anger)]</span></div></div><div class='stat-grid' style='margin-top:7px'>[growth_html]</div></div></section></div>
	<div class='section-grid'><section class='panel'><h2>Progression</h2><div class='panel-body'><div class='progress-grid'><div class='progress-card'><small>Technology</small><b>Lv. [player_tech_level]</b><span>[round(technology_experience)] XP / [html_encode(path_text)]</span></div><div class='progress-card'><small>Mining</small><b>Lv. [mining_level]</b><span>[round(mining_experience)] / [getProfessionExperienceForLevel(mining_level + 1)] XP</span></div><div class='progress-card'><small>Smithing</small><b>Lv. [smithing_level]</b><span>[round(smithing_experience)] / [getProfessionExperienceForLevel(smithing_level + 1)] XP</span></div><div class='progress-card'><small>Knowledge</small><b>[Commas(Knowledge * Intelligence())]</b><span>[html_encode(KnowledgeRating())]</span></div><div class='progress-card'><small>Milestones</small><b>[milestone_points] MP</b><span>[total_milestone_points] earned</span></div><div class='progress-card'><small>Lethal pressure</small><b>[lethal_time]s</b><span>[isInLethalCombat() ? "Active" : "Clear"]</span></div></div></div></section><section class='panel'><h2>Milestones</h2><div class='panel-body'><div class='milestone-list'>[milestone_cards]</div></div></section></div>
	<section class='panel' style='margin-top:9px'><h2>Skills & Techniques</h2><div class='panel-body'><div class='skill-list'>[skill_cards]</div></div></section><div class='footer'>This sheet replaces the legacy Stats tab and reflects the current live character state.</div></div></body></html>"}

datum/NexusCharacterSheetWindow
	var/tmp/mob/owner
	var/tmp/live_refresh_loop
	var/tmp/last_browser_heartbeat
	var/tmp/last_scroll_y
	var/tmp/last_render_signature
	var/tmp/portrait_index

	New(mob/new_owner)
		. = ..()
		owner = new_owner
		last_browser_heartbeat = world.time

	Del()
		if(owner)
			owner << browse(null, "window=NexusCharacter")
			if(owner.client && owner.client.nexus_character_sheet == src) owner.client.nexus_character_sheet = null
		owner = null
		. = ..()

	proc/canUse()
		return owner && owner.client && owner.playerCharacter && usr == owner

	proc/hasLiveOwner()
		return owner && owner.client && owner.playerCharacter && owner.client.nexus_character_sheet == src

	proc/isBrowserOpen()
		if(!hasLiveOwner()) return FALSE
		var/window_visibility = winget(owner, "NexusCharacter", "is-visible")
		if(window_visibility == "false") return FALSE
		if(window_visibility == "true") return TRUE
		return world.time - last_browser_heartbeat <= 30

	proc/recordHeartbeat(scroll_y)
		last_browser_heartbeat = world.time
		var/numeric_scroll = text2num("[scroll_y]")
		if(isnum(numeric_scroll)) last_scroll_y = round(Clamp(numeric_scroll, 0, 100000))

	proc/getRenderSignature()
		var/appearance_signature = "[owner.icon]|[owner.icon_state]|[owner.dir]|[owner.overlays]|[owner.underlays]|[owner.color]|[owner.alpha]|[owner.transform]"
		var/html_signature = owner.buildCharacterSheetHtml("nexus_character_signature.png", src, 0)
		return md5("[appearance_signature]|[html_signature]")

	proc/startLiveRefresh()
		set waitfor = FALSE
		if(live_refresh_loop) return
		live_refresh_loop = TRUE
		while(src && hasLiveOwner())
			sleep(nexus_live_browser_refresh_ticks)
			if(!src || !hasLiveOwner() || !isBrowserOpen()) break
			show(FALSE)
		if(src)
			live_refresh_loop = FALSE
			del(src)

	proc/show(force_refresh = TRUE)
		if(!hasLiveOwner())
			del(src)
			return
		var/render_signature = getRenderSignature()
		if(!force_refresh && render_signature == last_render_signature) return
		last_render_signature = render_signature
		portrait_index++
		var/portrait_resource = "nexus_character_[ckey(owner.key)]_[portrait_index].png"
		var/icon/portrait_icon = icon(owner.icon, owner.icon_state, SOUTH)
		owner << browse_rsc(portrait_icon, portrait_resource)
		owner << browse(owner.buildCharacterSheetHtml(portrait_resource, src, last_scroll_y), "window=NexusCharacter;size=1180x760;can_resize=true;can_close=true")
		if(force_refresh) last_browser_heartbeat = world.time
		startLiveRefresh()

	Topic(href, list/href_list)
		if(!canUse()) return
		switch(href_list["action"])
			if("heartbeat")
				recordHeartbeat(href_list["scroll_y"])
				return
			if("refresh_character_sheet")
				show(TRUE)
				return
			if("open_admin_inspector")
				if(owner.AdminLevel() >= 3) owner.showNexusAdminInspector(owner)
				return
			if("close")
				del(src)
				return

mob/proc/showCharacterSheet()
	if(!client || !playerCharacter) return
	if(client.nexus_character_sheet) del(client.nexus_character_sheet)
	client.nexus_character_sheet = new /datum/NexusCharacterSheetWindow(src)
	client.nexus_character_sheet.show(TRUE)

mob/verb/characterSheet()
	set name = "Character"
	set category = "Other"
	showCharacterSheet()
