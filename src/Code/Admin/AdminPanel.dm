client/var/tmp/datum/NexusAdminPanel/nexus_admin_panel

datum/NexusAdminAction
	var
		id
		name
		category
		description
		minimum_level = 1
		requires_target = FALSE
		quick_action = FALSE
		dangerous = FALSE

	New(new_id, new_name, new_category, new_description, new_level = 1, new_requires_target = FALSE, new_quick_action = FALSE, new_dangerous = FALSE)
		id = new_id
		name = new_name
		category = new_category
		description = new_description
		minimum_level = new_level
		requires_target = new_requires_target
		quick_action = new_quick_action
		dangerous = new_dangerous

var/list/nexus_admin_action_catalog

proc/initializeNexusAdminActions()
	if(islist(nexus_admin_action_catalog) && nexus_admin_action_catalog.len) return
	nexus_admin_action_catalog = list()
	nexus_admin_action_catalog["select_target"] = new /datum/NexusAdminAction("select_target", "Select Player", "Player", "Choose the player used by target-based commands.", 1, FALSE, TRUE)
	nexus_admin_action_catalog["character"] = new /datum/NexusAdminAction("character", "View Character", "Player", "Open the selected player's detailed DU character assessment.", 1, TRUE, TRUE)
	nexus_admin_action_catalog["teleport"] = new /datum/NexusAdminAction("teleport", "Teleport To", "Movement", "Teleport to the selected player.", 1, TRUE, TRUE)
	nexus_admin_action_catalog["summon"] = new /datum/NexusAdminAction("summon", "Summon", "Movement", "Summon the selected player to you.", 1, TRUE, TRUE)
	nexus_admin_action_catalog["heal"] = new /datum/NexusAdminAction("heal", "Heal", "Player", "Fully heal the selected player and optionally clear injuries.", 1, TRUE, TRUE)
	nexus_admin_action_catalog["revive"] = new /datum/NexusAdminAction("revive", "Revive", "Player", "Revive and remove KO from the selected player.", 1, TRUE, TRUE)
	nexus_admin_action_catalog["reward"] = new /datum/NexusAdminAction("reward", "Reward Player", "Player", "Grant progression, resources or character growth through the refactored reward menu.", 2, TRUE, TRUE)
	nexus_admin_action_catalog["inspect"] = new /datum/NexusAdminAction("inspect", "Admin Inspector", "Development", "Search and edit every runtime variable, collection and mutation.", 3, TRUE, TRUE)
	nexus_admin_action_catalog["give_item"] = new /datum/NexusAdminAction("give_item", "Give Item", "Items", "Search the item type catalog and give one result to the selected player.", 2, TRUE, TRUE)
	nexus_admin_action_catalog["make_object"] = new /datum/NexusAdminAction("make_object", "Create Object", "Items", "Search the object catalog and create one at your location.", 2)
	nexus_admin_action_catalog["give_mutation"] = new /datum/NexusAdminAction("give_mutation", "Give Mutation", "Character", "Add or adjust a mutation on the selected player.", 3, TRUE, TRUE)
	nexus_admin_action_catalog["roll_mutations"] = new /datum/NexusAdminAction("roll_mutations", "Roll Mutations", "Character", "Reroll the selected player's mutation package.", 3, TRUE)
	nexus_admin_action_catalog["give_tenkaichi"] = new /datum/NexusAdminAction("give_tenkaichi", "Give Tenkaichi Equipment", "Smithing", "Give any ported material and weapon or armor design for testing.", 3, TRUE, TRUE)
	nexus_admin_action_catalog["test_tenkaichi"] = new /datum/NexusAdminAction("test_tenkaichi", "Test Tenkaichi Smithing", "Smithing", "Grant profession levels, every ore and spawn a forge for the selected player.", 3, TRUE)
	nexus_admin_action_catalog["give_tenkaichi_attacks"] = new /datum/NexusAdminAction("give_tenkaichi_attacks", "Give Tenkaichi Attacks", "Testing", "Give melee, weapon, special-style or beam Roleplay Tenkaichi packages for testing.", 3, TRUE, TRUE)
	nexus_admin_action_catalog["test_combat_effects"] = new /datum/NexusAdminAction("test_combat_effects", "Test Combat Effects", "Testing", "Preview sword, stone, explosion-light and explosive-beam knockback effects without dealing damage.", 3, FALSE, TRUE)
	nexus_admin_action_catalog["player_logs"] = new /datum/NexusAdminAction("player_logs", "Player Logs", "Logs", "Open the selected player's server logs.", 2, TRUE)
	nexus_admin_action_catalog["rp_logs"] = new /datum/NexusAdminAction("rp_logs", "Roleplay Window", "Logs", "View the selected player's roleplay history.", 1, TRUE)
	nexus_admin_action_catalog["development_logs"] = new /datum/NexusAdminAction("development_logs", "Development RP Window", "Logs", "View the selected player's development roleplay history.", 1, TRUE)
	nexus_admin_action_catalog["admin_logs"] = new /datum/NexusAdminAction("admin_logs", "Admin Logs", "Logs", "Choose and inspect an administrator's action log.", 1)
	nexus_admin_action_catalog["bug_logs"] = new /datum/NexusAdminAction("bug_logs", "Bug Logs", "Logs", "Open the current runtime bug collection.", 2)
	nexus_admin_action_catalog["server_settings"] = new /datum/NexusAdminAction("server_settings", "Server Settings", "Server", "Open the detailed persisted world, combat, science and progression settings.", 4)
	nexus_admin_action_catalog["toggle_ooc"] = new /datum/NexusAdminAction("toggle_ooc", "Toggle Server OOC", "Server", "Enable or disable the global OOC channel.", 2)
	nexus_admin_action_catalog["world_heal"] = new /datum/NexusAdminAction("world_heal", "World Heal", "Server", "Fully heal every connected player.", 2, FALSE, FALSE, TRUE)
	nexus_admin_action_catalog["save_world"] = new /datum/NexusAdminAction("save_world", "Save World", "Server", "Persist the current world state immediately.", 3, FALSE, FALSE, TRUE)
	nexus_admin_action_catalog["reboot"] = new /datum/NexusAdminAction("reboot", "Reboot Server", "Server", "Run the confirmed server reboot workflow.", 3, FALSE, FALSE, TRUE)
	nexus_admin_action_catalog["battle_test"] = new /datum/NexusAdminAction("battle_test", "Battle Test", "Testing", "Open the automated combat test setup.", 5)
	nexus_admin_action_catalog["legacy_command"] = new /datum/NexusAdminAction("legacy_command", "Legacy Verb Finder", "Legacy", "Search every legacy admin verb without hiding it from CMD or the Admin tab.", 1)

proc/getNexusAdminVerbPaths(admin_level)
	var/list/paths = list()
	if(admin_level >= 1) paths += typesof(/mob/Admin1/verb)
	if(admin_level >= 2) paths += typesof(/mob/Admin2/verb)
	if(admin_level >= 3) paths += typesof(/mob/Admin3/verb)
	if(admin_level >= 4) paths += typesof(/mob/Admin4/verb)
	if(admin_level >= 5) paths += typesof(/mob/Admin5/verb)
	return paths

proc/getNexusAdminVerbCommand(verb_path)
	var/path_text = "[verb_path]"
	var/last_separator = 0
	for(var/index = 1, index <= length(path_text), index++)
		if(copytext(path_text, index, index + 1) == "/") last_separator = index
	return copytext(path_text, last_separator + 1)

datum/NexusAdminPanel
	var/tmp/mob/owner
	var/tmp/mob/target
	var/tmp/compact = FALSE
	var/tmp/list/item_candidates
	var/tmp/item_picker_mode = "give"

	New(mob/new_owner, compact_mode = FALSE, mob/new_target)
		. = ..()
		owner = new_owner
		compact = compact_mode
		target = new_target && new_target.client ? new_target : new_owner

	Del()
		if(owner)
			owner << browse(null, "window=NexusAdminItems")
			owner << browse(null, "window=NexusAdminReward")
		if(owner && owner.client && owner.client.nexus_admin_panel == src)
			owner.client.nexus_admin_panel = null
		. = ..()

	proc/canUse(required_level = 1)
		return owner && owner.client && owner.AdminLevel() >= required_level

	proc/requireTarget()
		if(target && target.client) return TRUE
		owner << "Select a connected player before using this command."
		return FALSE

	proc/selectTarget()
		var/list/options = list()
		for(var/mob/player in players)
			if(player.client) options += player
		var/mob/selection = input(owner, "Choose the active administration target.", "Admin Panel", target) as null|mob in options
		if(selection) target = selection

	proc/showTargetCharacter()
		if(!requireTarget()) return
		var/portrait_resource = "nexus_admin_character_[ckey(target.key)]_[world.time].png"
		var/icon/portrait_icon = icon(target.icon, target.icon_state, SOUTH)
		owner << browse_rsc(portrait_icon, portrait_resource)
		owner << browse(target.buildCharacterSheetHtml(portrait_resource), "window=NexusAdminCharacter;size=1180x760;can_resize=true")

	proc/openRewardMenu()
		if(!requireTarget()) return
		var/html = {"<!doctype html><html><head><meta charset='utf-8'><title>Reward Player</title><style>[getNexusRpgBrowserCss()]
		*{box-sizing:border-box}body{margin:0;background:radial-gradient(circle at 80% 0,#26374b,#0b121c 48%,#06090e);color:#edf3fa;font:13px Arial,sans-serif}.header{padding:16px 18px;border-bottom:1px solid #455a72;background:#0a1019}.header h1{margin:0 0 5px;font-size:21px}.header p{margin:0;color:#93a5b9}.target{color:#ffd19c}.grid{display:grid;grid-template-columns:repeat(2,minmax(260px,1fr));gap:8px;padding:14px}.reward{min-height:82px;padding:12px;border:1px solid #30475d;background:linear-gradient(145deg,#111f2c,#0b141e);color:#e7f1fa;text-decoration:none}.reward:hover{border-color:#75c9ed;background:#142b3d}.reward b,.reward span{display:block}.reward b{font-size:14px;margin-bottom:6px}.reward span{color:#8fa4b9;line-height:1.35}.footer{padding:0 14px 14px}.back{display:inline-block;padding:9px 13px;border:1px solid #607790;color:#dceaf5;text-decoration:none}@media(max-width:680px){.grid{grid-template-columns:1fr}}
		</style></head><body><div class='header'><h1>Reward <span class='target'>[html_encode("[target] ([target.key])")]</span></h1><p>Direct, audited progression controls. This menu does not invoke the legacy Reward verb.</p></div><div class='grid'>
		<a class='reward' href='byond://?src=\ref[src]&action=apply_reward&type=bp'><b>Battle Power</b><span>Set absolute base BP with online relative maximum and average context.</span></a>
		<a class='reward' href='byond://?src=\ref[src]&action=apply_reward&type=bp_mod'><b>BP Modifier</b><span>Set the character's permanent BP growth modifier.</span></a>
		<a class='reward' href='byond://?src=\ref[src]&action=apply_reward&type=energy'><b>Base Energy</b><span>Set base Energy while preserving the character's Efficiency multiplier.</span></a>
		<a class='reward' href='byond://?src=\ref[src]&action=apply_reward&type=resources'><b>Resources</b><span>Add construction and technology resources.</span></a>
		<a class='reward' href='byond://?src=\ref[src]&action=apply_reward&type=skill_points'><b>Skill Points</b><span>Add up to 10,000 skill points at a time.</span></a>
		<a class='reward' href='byond://?src=\ref[src]&action=apply_reward&type=milestone_points'><b>Milestone Points</b><span>Add spendable perk points and update the lifetime total.</span></a>
		<a class='reward' href='byond://?src=\ref[src]&action=apply_reward&type=technology_xp'><b>Technology XP</b><span>Advance Technology Level and refresh available unlocks.</span></a>
		<a class='reward' href='byond://?src=\ref[src]&action=apply_reward&type=mining_xp'><b>Mining XP</b><span>Advance the Tenkaichi mining profession.</span></a>
		<a class='reward' href='byond://?src=\ref[src]&action=apply_reward&type=smithing_xp'><b>Smithing XP</b><span>Advance the Tenkaichi smithing profession.</span></a>
		</div><div class='footer'><a class='back' href='byond://?src=\ref[src]&action=reward_back'>BACK TO PLAYER PANEL</a></div></body></html>"}
		owner << browse(html, "window=NexusAdminReward;size=760x680;can_resize=true")

	proc/applyReward(reward_type)
		if(!requireTarget() || !canUse(2)) return
		var/amount
		switch(reward_type)
			if("skill_points")
				amount = input(owner, "How many Skill Points should [target] receive?", "Reward Player", 1) as null|num
				if(isnull(amount)) return
				amount = Clamp(round(amount), 0, 10000)
				target.Experience += amount
			if("resources")
				amount = input(owner, "How many Resources should [target] receive?", "Reward Player", 1000) as null|num
				if(isnull(amount) || amount < 0) return
				target.Alter_Res(amount)
			if("bp")
				var/relative_max = 0
				var/relative_average = 0
				var/player_count = 0
				for(var/mob/player in players)
					if(!player.client || player.bp_mod <= 0) continue
					var/relative_bp = player.base_bp / player.bp_mod
					relative_max = max(relative_max, relative_bp)
					relative_average += relative_bp
					player_count++
				if(player_count) relative_average /= player_count
				relative_max *= target.bp_mod
				relative_average *= target.bp_mod
				amount = input(owner, "Current BP: [Commas(target.base_bp)]\nRelative online max: [Commas(relative_max)]\nRelative online average: [Commas(relative_average)]", "Set [target]'s Battle Power", target.base_bp) as null|num
				if(isnull(amount)) return
				amount = Clamp(amount, 0, 10000000000000)
				if(amount == target.base_bp) return
				target.base_bp = amount
			if("bp_mod")
				var/max_mod = 0
				var/average_mod = 0
				var/player_count = 0
				for(var/mob/player in players)
					if(!player.client) continue
					max_mod = max(max_mod, player.bp_mod)
					average_mod += player.bp_mod
					player_count++
				if(player_count) average_mod /= player_count
				amount = input(owner, "Current BP Mod: [target.bp_mod]x\nOnline max: [max_mod]x\nOnline average: [round(average_mod, 0.01)]x", "Set [target]'s BP Modifier", target.bp_mod) as null|num
				if(isnull(amount) || amount <= 0 || amount == target.bp_mod) return
				target.bp_mod = amount
			if("energy")
				var/base_energy = target.Eff > 0 ? target.max_ki / target.Eff : target.max_ki
				amount = input(owner, "Set base Energy. Efficiency ([target.Eff]x) is applied automatically.", "Set [target]'s Base Energy", base_energy) as null|num
				if(isnull(amount) || amount < 1) return
				target.max_ki = amount * max(target.Eff, 0.01)
				target.Ki = min(target.Ki, target.max_ki)
			if("milestone_points")
				amount = input(owner, "How many Milestone Points should [target] receive?", "Reward Player", 1) as null|num
				if(isnull(amount) || amount < 0) return
				amount = round(amount)
				target.milestone_points += amount
				target.total_milestone_points += amount
			if("technology_xp")
				amount = input(owner, "How much Technology XP should [target] receive?", "Reward Player", 50) as null|num
				if(isnull(amount) || amount < 0) return
				target.gainTechnologyExperience(amount, "admin reward", announce = TRUE)
			if("mining_xp", "smithing_xp")
				var/profession = reward_type == "mining_xp" ? "Mining" : "Smithing"
				amount = input(owner, "How much [profession] XP should [target] receive?", "Reward Player", 50) as null|num
				if(isnull(amount) || amount < 0) return
				target.gainProfessionExperience(profession, amount, "admin reward", announce = TRUE)
			else return
		owner.admin_blame(owner, "[owner.key] rewarded [target.key] with [amount] [reward_type] through the contextual Admin Panel.")
		owner << "Rewarded [target] with [amount] [reward_type]."

	proc/openItemPicker(mode = "give", search = "")
		if(mode == "give" && !requireTarget()) return
		item_picker_mode = mode
		item_candidates = list()
		var/query = lowertext(search)
		var/results = ""
		var/result_count = 0
		for(var/item_type in typesof(/obj/items))
			var/path_text = "[item_type]"
			if(query && !findtext(lowertext(path_text), query)) continue
			result_count++
			if(result_count > 250) break
			var/index_key = "[result_count]"
			item_candidates[index_key] = item_type
			var/category = "Other"
			var/lower_path = lowertext(path_text)
			if(findtext(lower_path, "/sword") || findtext(lower_path, "/gun") || findtext(lower_path, "/weapon")) category = "Weapons"
			else if(findtext(lower_path, "/armor") || findtext(lower_path, "/clothes")) category = "Armor & Clothes"
			else if(findtext(lower_path, "/ore") || findtext(lower_path, "/digging") || findtext(lower_path, "/technology")) category = "Technology"
			else if(findtext(lower_path, "senzu") || findtext(lower_path, "food") || findtext(lower_path, "drink")) category = "Consumables"
			results += "<a class='result' data-search='[html_encode(lower_path)]' href='byond://?src=\ref[src]&action=create_item&index=[index_key]'><b>[html_encode(path_text)]</b><span>[category]</span></a>"
		if(!results) results = "<p class='empty'>No item types matched this search.</p>"
		var/mode_title = mode == "give" ? "Give item to [target]" : "Create object at your location"
		var/html = {"<!doctype html><html><head><meta charset='utf-8'><title>Admin Item Picker</title><style>[getNexusRpgBrowserCss()]
		*{box-sizing:border-box}body{margin:0;background:#070c12;color:#eaf1f8;font:13px Arial,sans-serif}.header{position:sticky;top:0;padding:15px;background:#101a27;border-bottom:1px solid #40536a}.header h1{margin:0 0 4px;font-size:19px}.header p{margin:0 0 12px;color:#8fa2b8}.search-row{display:flex;gap:7px}.search-row input{flex:1;padding:10px;background:#09111b;border:1px solid #486078;color:#fff}.button{padding:10px 13px;border:1px solid #55738c;background:#172a3a;color:#dceefe;text-decoration:none}.results{display:grid;grid-template-columns:repeat(2,minmax(280px,1fr));gap:6px;padding:12px}.result{display:flex;align-items:center;gap:8px;padding:9px;border:1px solid #26384a;background:#0d1722;color:#dcecf8;text-decoration:none;word-break:break-all}.result:hover{border-color:#6bb9dd;background:#122435}.result b{margin-right:auto}.result span{white-space:nowrap;color:#7fb5cf;font-size:9px;text-transform:uppercase}.empty{padding:20px;color:#8091a5}@media(max-width:760px){.results{grid-template-columns:1fr}}
		</style></head><body><div class='header'><h1>[html_encode(mode_title)]</h1><p>Searches type paths without constructing hundreds of reference objects. Showing at most 250 matches.</p><form class='search-row' action='byond://' method='get'><input type='hidden' name='src' value='\ref[src]'><input type='hidden' name='action' value='item_search'><input type='hidden' name='mode' value='[mode]'><input type='text' name='query' value='[html_encode(search)]' placeholder='Search sword, armor, senzu, forge...'><input class='button' type='submit' value='SEARCH'><a class='button' href='byond://?src=\ref[src]&action=back'>BACK</a></form></div><div class='results'>[results]</div></body></html>"}
		owner << browse(html, "window=NexusAdminItems;size=980x720;can_resize=true")

	proc/createSelectedItem(index_key)
		if(!islist(item_candidates)) return
		var/item_type = item_candidates[index_key]
		if(!ispath(item_type, /obj/items)) return
		var/obj/items/new_item
		if(item_picker_mode == "give")
			if(!requireTarget()) return
			new_item = new item_type(target)
		else
			new_item = new item_type(owner.loc)
		if(!new_item || !new_item.Givable)
			if(new_item) del(new_item)
			owner << "That item type is protected and cannot be created through the panel."
			return
		if(item_picker_mode == "give")
			owner.admin_blame(owner, "[owner.key] gave [target.key] [new_item] through the Admin Panel.")
			owner << "Created [new_item] in [target]'s inventory."
		else
			owner.admin_blame(owner, "[owner.key] created [new_item] through the Admin Panel.")
			owner << "Created [new_item] at your location."

	proc/runLegacyCommand()
		var/search = input(owner, "Search the admin verbs available at your level. Every verb remains available through CMD and its original Admin tab category.", "Legacy Verb Finder") as null|text
		if(isnull(search)) return
		var/list/options = list()
		for(var/verb_path in getNexusAdminVerbPaths(owner.AdminLevel()))
			var/path_text = "[verb_path]"
			if(search && !findtext(lowertext(path_text), lowertext(search))) continue
			options[path_text] = verb_path
		if(!options.len)
			owner << "No legacy admin command matched '[search]'."
			return
		var/selection = input(owner, "Choose a legacy verb to locate its CMD name.", "Legacy Verb Finder") as null|anything in options
		if(isnull(selection)) return
		var/selected_path = options[selection]
		owner.verbs += selected_path
		var/command_name = getNexusAdminVerbCommand(selected_path)
		owner << "Legacy verb '[command_name]' is available through CMD and its original Admin tab category."
		owner.admin_blame(owner, "[owner.key] located [selected_path] through the Legacy Verb Finder.")

	proc/runAction(action_id)
		initializeNexusAdminActions()
		var/datum/NexusAdminAction/action = nexus_admin_action_catalog[action_id]
		if(!action || !canUse(action.minimum_level)) return
		if(action.requires_target && !requireTarget()) return
		switch(action_id)
			if("select_target") selectTarget()
			if("character") showTargetCharacter()
			if("teleport")
				owner.admin_blame(owner, "[owner.key] teleported to [target] through the Admin Panel.")
				owner.SafeTeleport(target.loc)
			if("summon")
				owner.admin_blame(owner, "[owner.key] summoned [target] through the Admin Panel.")
				target.SafeTeleport(owner.loc)
			if("heal") call(owner, /mob/Admin1/verb/adminHeal)(target)
			if("revive") call(owner, /mob/Admin1/verb/adminRevive)(target)
			if("reward")
				openRewardMenu()
				return
			if("inspect") owner.showNexusAdminInspector(target)
			if("give_item")
				openItemPicker("give")
				return
			if("make_object")
				openItemPicker("make")
				return
			if("give_mutation") call(owner, /mob/Admin3/verb/giveMutation)(target)
			if("roll_mutations") call(owner, /mob/Admin3/verb/rollMutations)(target)
			if("give_tenkaichi") call(owner, /mob/Admin3/verb/giveTenkaichiEquipment)(target)
			if("test_tenkaichi") call(owner, /mob/Admin3/verb/testTenkaichiSmithing)(target)
			if("give_tenkaichi_attacks") call(owner, /mob/Admin3/verb/giveTenkaichiAttacks)(target)
			if("test_combat_effects") call(owner, /mob/Admin3/verb/testTenkaichiCombatEffects)()
			if("player_logs") call(owner, /mob/Admin2/verb/playerLogs)(target)
			if("rp_logs") call(owner, /mob/Admin1/verb/viewRpWindow)(target)
			if("development_logs") call(owner, /mob/Admin1/verb/viewDevelopmentRpWindow)(target)
			if("admin_logs") call(owner, /mob/Admin1/verb/viewAdminLogs)()
			if("bug_logs") call(owner, /mob/Admin2/verb/bugLogs)()
			if("server_settings")
				owner << browse(null, "window=NexusAdminPanel")
				owner << browse(null, "window=NexusQuickAdmin")
				owner.showNexusServerPanel()
				return
			if("toggle_ooc") call(owner, /mob/Admin2/verb/allowOOC)()
			if("world_heal") call(owner, /mob/Admin2/verb/worldHeal)()
			if("save_world")
				if(alert(owner, "Save the current world state now?", "Admin Panel", "Save", "Cancel") == "Save")
					saveWorld()
					owner.admin_blame(owner, "[owner.key] saved the world through the Admin Panel.")
			if("reboot") call(owner, /mob/Admin3/verb/reboot)()
			if("battle_test") call(owner, /mob/Admin5/verb/battleTest)()
			if("legacy_command") runLegacyCommand()

	proc/buildHtml()
		initializeNexusAdminActions()
		var/action_html = ""
		var/list/category_order = list("Player", "Movement", "Character", "Items", "Smithing", "Development", "Logs", "Testing", "Server", "Legacy")
		for(var/category in category_order)
			for(var/action_id in nexus_admin_action_catalog)
				var/datum/NexusAdminAction/action = nexus_admin_action_catalog[action_id]
				if(action.category != category || owner.AdminLevel() < action.minimum_level) continue
				if(compact && !action.quick_action) continue
				var/card_class = action.dangerous ? "action danger" : "action"
				var/search_key = lowertext("[action.name] [action.category] [action.description]")
				action_html += "<a class='[card_class]' data-category='[action.category]' data-search='[html_encode(search_key)]' href='byond://?src=\ref[src]&action=run&id=[action.id]'><span>[html_encode(action.category)] / LV [action.minimum_level]</span><b>[html_encode(action.name)]</b><small>[html_encode(action.description)]</small></a>"
		var/target_name = target && target.client ? "[target] ([target.key])" : "No player selected"
		var/player_count = 0
		for(var/mob/player in players) if(player.client) player_count++
		var/title = compact ? "QUICK ADMIN" : "NEXUS ADMIN CONTROL"
		var/window_note = compact ? "Fast player operations" : "Searchable development and server command center"
		return {"<!doctype html><html><head><meta charset='utf-8'><title>[title]</title><style>[getNexusRpgBrowserCss()]
		*{box-sizing:border-box}html,body{margin:0;height:100%;background:#070b11;color:#edf3fa;font:13px Arial,sans-serif}.shell{min-height:100%;background:radial-gradient(circle at 80% 0,#26374b,#0b121c 48%,#06090e)}.header{position:sticky;top:0;z-index:2;padding:14px 18px;border-bottom:1px solid #455a72;background:rgba(10,16,25,.97)}.top{display:flex;align-items:center;gap:10px}.title{margin-right:auto}.title b{display:block;font-size:20px;letter-spacing:1.5px}.title span{color:#8496ad;font-size:10px;text-transform:uppercase}.badge{padding:7px 9px;border:1px solid #516a82;background:#112131;color:#bcd0df}.badge.target{border-color:#9a7146;color:#ffd19c}.close{padding:8px 10px;border:1px solid #714842;color:#ffb3a7;text-decoration:none}.search{width:100%;margin-top:11px;padding:10px;border:1px solid #4b6179;background:#0c1520;color:#fff}.filters{display:flex;gap:5px;flex-wrap:wrap;margin-top:7px}.filters button{padding:5px 8px;border:1px solid #37485d;background:#0f1926;color:#9fb0c5;cursor:pointer}.filters button.active{border-color:#6ab9dd;background:#173044;color:#fff}.status{display:grid;grid-template-columns:repeat(4,1fr);gap:6px;padding:10px 14px;border-bottom:1px solid #263547}.status div{padding:8px;border-left:3px solid #547c94;background:#0e1924}.status small{display:block;color:#75889e;text-transform:uppercase;font-size:9px}.status b{display:block;margin-top:3px}.actions{display:grid;grid-template-columns:repeat([compact ? 2 : 3],minmax(220px,1fr));gap:7px;padding:12px}.action{min-height:92px;padding:11px;border:1px solid #2d4054;background:linear-gradient(145deg,#101c29,#0b131d);color:#e4eef8;text-decoration:none}.action:hover{border-color:#71c7ec;background:#14283a}.action.danger{border-color:#70443f}.action.danger:hover{border-color:#e17a6d}.action span,.action b,.action small{display:block}.action span{color:#72bad9;font-size:9px;text-transform:uppercase}.action b{margin:7px 0 5px;font-size:14px}.action small{color:#899bb0;line-height:1.35}.empty{padding:30px;color:#76889e;text-align:center}@media(max-width:850px){.actions{grid-template-columns:repeat(2,1fr)}.status{grid-template-columns:repeat(2,1fr)}}
		</style></head><body><div class='shell'><div class='header'><div class='top'><div class='title'><b>[title]</b><span>[window_note]</span></div><div class='badge'>ADMIN LV [owner.AdminLevel()]</div><div class='badge target'>TARGET: [html_encode(target_name)]</div><a class='close' href='byond://?src=\ref[src]&action=close'>CLOSE</a></div><input id='search' class='search' placeholder='Search command, category or purpose...' oninput='applyFilters()'><div class='filters'><button class='active' data-filter='All' onclick='setCategory(this)'>All</button><button data-filter='Player' onclick='setCategory(this)'>Player</button><button data-filter='Movement' onclick='setCategory(this)'>Movement</button><button data-filter='Character' onclick='setCategory(this)'>Character</button><button data-filter='Items' onclick='setCategory(this)'>Items</button><button data-filter='Smithing' onclick='setCategory(this)'>Smithing</button><button data-filter='Development' onclick='setCategory(this)'>Development</button><button data-filter='Logs' onclick='setCategory(this)'>Logs</button><button data-filter='Server' onclick='setCategory(this)'>Server</button><button data-filter='Legacy' onclick='setCategory(this)'>Legacy</button></div></div><div class='status'><div><small>Players</small><b>[player_count] online</b></div><div><small>World year</small><b>[Year]</b></div><div><small>OOC</small><b>[OOC ? "Enabled" : "Disabled"]</b></div><div><small>Tournament</small><b>[Tournament ? "Active" : "Inactive"]</b></div></div><div class='actions'>[action_html]</div></div><script>var activeCategory='All';function setCategory(button){activeCategory=button.getAttribute('data-filter');var buttons=document.querySelectorAll('.filters button');for(var i=0;i<buttons.length;i++)buttons.item(i).className='';button.className='active';applyFilters();}function applyFilters(){var query=document.getElementById('search').value.toLowerCase();var cards=document.querySelectorAll('.action');for(var i=0;i<cards.length;i++){var card=cards.item(i);var categoryOk=activeCategory==='All'||card.getAttribute('data-category')===activeCategory;var searchOk=!query||card.getAttribute('data-search').indexOf(query)>=0;card.style.display=categoryOk&&searchOk?'block':'none';}}</script></body></html>"}

	proc/show()
		if(!canUse())
			if(owner) owner << "The Admin Panel requires an active admin account."
			del(src)
			return
		var/window_name = compact ? "NexusQuickAdmin" : "NexusAdminPanel"
		var/window_size = compact ? "720x650" : "1120x760"
		owner << browse(buildHtml(), "window=[window_name];size=[window_size];can_resize=true;can_close=true")

	Topic(href, list/href_list)
		if(!canUse() || usr != owner) return
		switch(href_list["action"])
			if("run")
				runAction(href_list["id"])
				if(href_list["id"] == "server_settings") return
			if("item_search")
				openItemPicker(href_list["mode"], href_list["query"])
				return
			if("create_item")
				createSelectedItem(href_list["index"])
				openItemPicker(item_picker_mode)
				return
			if("apply_reward")
				applyReward(href_list["type"])
				openRewardMenu()
				return
			if("reward_back")
				owner << browse(null, "window=NexusAdminReward")
				show()
				return
			if("back")
				owner << browse(null, "window=NexusAdminItems")
				show()
				return
			if("close")
				owner << browse(null, "window=NexusAdminPanel")
				owner << browse(null, "window=NexusQuickAdmin")
				del(src)
				return
		show()

mob/proc/showNexusAdminPanel(compact = FALSE, mob/selected_target)
	if(!client || !IsAdmin()) return
	if(client.nexus_admin_panel) del(client.nexus_admin_panel)
	client.nexus_admin_panel = new /datum/NexusAdminPanel(src, compact, selected_target)
	client.nexus_admin_panel.show()

mob/AdminEssentials/verb/adminPanel()
	set name = "Admin Panel"
	set category = "Admin"
	showNexusAdminPanel(FALSE)

mob/AdminEssentials/verb/quickAdminPanel()
	set name = "Quick Admin"
	set category = "Admin"
	showNexusAdminPanel(TRUE)

mob/AdminEssentials/verb/managePlayer(mob/selected_player in players)
	set name = "Manage Player"
	set category = "Admin"
	if(!selected_player || !selected_player.client) return
	showNexusAdminPanel(TRUE, selected_player)

mob/AdminEssentials/verb/adminInspector()
	set name = "Admin Inspector"
	set category = "Admin"
	if(AdminLevel() < 3) return
	var/atom/target = input(src, "Choose anything in the world to inspect.", "Admin Inspector") as null|anything in Edit_List()
	if(target) showNexusAdminInspector(target)
