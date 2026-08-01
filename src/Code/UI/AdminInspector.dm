client/var/tmp/datum/NexusAdminInspector/nexus_admin_inspector

proc/getNexusAdminVariableCategory(variable_name, variable_value)
	if(islist(variable_value)) return "Collections"
	var/lower_name = lowertext("[variable_name]")
	for(var/keyword in list("name", "key", "race", "class", "gender", "age", "desc", "alignment", "display"))
		if(findtext(lower_name, keyword)) return "Identity"
	for(var/keyword in list("health", "stamina", "willpower", "anger", "bp", "str", "end", "spd", "pow", "res", "off", "def", "damage", "armor", "combat", "ko", "attack", "defend"))
		if(findtext(lower_name, keyword)) return "Combat"
	for(var/keyword in list("level", "experience", "mastery", "knowledge", "tech", "milestone", "mining", "smithing", "gain", "mod"))
		if(findtext(lower_name, keyword)) return "Progression"
	for(var/keyword in list("icon", "overlay", "underlay", "color", "alpha", "pixel", "transform", "layer", "appearance", "invisibility"))
		if(findtext(lower_name, keyword)) return "Appearance"
	for(var/keyword in list("loc", "area", "dir", "step", "bound", "density", "opacity", "x", "y", "z"))
		if(findtext(lower_name, keyword)) return "Position"
	for(var/keyword in list("client", "ckey", "address", "computer", "admin", "save", "password"))
		if(findtext(lower_name, keyword)) return "System"
	return "Other"

proc/getNexusAdminVariableDisplay(variable_value)
	if(islist(variable_value))
		var/list/value_list = variable_value
		var/preview = "[value_list.len] entries"
		var/shown = 0
		for(var/entry in value_list)
			if(shown >= 4) break
			preview += " | [entry]"
			if(!isnull(value_list[entry])) preview += ": [value_list[entry]]"
			shown++
		return preview
	return Value(variable_value)

proc/getNexusAdminVariableType(variable_value)
	if(isnull(variable_value)) return "null"
	if(isnum(variable_value)) return "number"
	if(istext(variable_value)) return "text"
	if(islist(variable_value)) return "list"
	if(ispath(variable_value)) return "path"
	if(istype(variable_value, /datum)) return "[variable_value:type]"
	return "value"

datum/NexusAdminInspector
	var/tmp/mob/owner
	var/tmp/atom/target

	New(mob/new_owner, atom/new_target)
		. = ..()
		owner = new_owner
		target = new_target

	Del()
		if(owner && owner.client && owner.client.nexus_admin_inspector == src)
			owner.client.nexus_admin_inspector = null
		. = ..()

	proc/canUse()
		return owner && owner.client && owner.AdminLevel() >= 3 && target

	proc/editVariable(variable_name)
		if(!canUse() || !(variable_name in target.vars)) return
		if(ismob(target) && target:client && variable_name in list("x", "y", "z", "loc"))
			owner << "Position variables on connected players cannot be edited from this inspector."
			return
		var/original = target.vars[variable_name]
		var/value_type = input(owner, "Edit [variable_name] on [target]", "Admin Inspector") as null|anything in list("Number", "Text", "File", "Empty List", "Nothing")
		if(!value_type) return
		switch(value_type)
			if("Nothing") target.vars[variable_name] = null
			if("Text") target.vars[variable_name] = input(owner, "New text value", variable_name, target.vars[variable_name]) as text
			if("Number") target.vars[variable_name] = input(owner, "New numeric value", variable_name, target.vars[variable_name]) as num
			if("File") target.vars[variable_name] = input(owner, "New file value", variable_name, target.vars[variable_name]) as file
			if("Empty List") target.vars[variable_name] = new/list
		owner.admin_blame(owner, "[owner.key] edited [variable_name] from [original] to [target.vars[variable_name]] on [target]")

	proc/editMutation(mutation_id)
		if(!canUse() || !ismob(target) || !CHARACTER_MUTATIONS[mutation_id]) return
		var/mob/character = target
		if(!islist(character.character_mutations)) character.character_mutations = list()
		var/current_percent = max(0, text2num("[character.character_mutations[mutation_id]]"))
		var/new_percent = input(owner, "Set [mutation_id] on [character] from 0% to 30%. Use 0 to remove it.", "Character Mutation", current_percent) as null|num
		if(isnull(new_percent)) return
		new_percent = Clamp(round(new_percent), 0, 30)
		if(!character.setCharacterMutationValue(mutation_id, new_percent))
			owner << "The mutation could not be changed."
			return
		owner.admin_blame(owner, "[owner.key] changed [character]'s [mutation_id] mutation from [current_percent]% to [new_percent]%")

	proc/buildMutationPanel()
		if(!ismob(target)) return ""
		var/mob/character = target
		var/mutation_rows = ""
		for(var/mutation_id in CHARACTER_MUTATIONS)
			var/datum/CharacterMutation/mutation = CHARACTER_MUTATIONS[mutation_id]
			var/current_percent = islist(character.character_mutations) ? max(0, text2num("[character.character_mutations[mutation_id]]")) : 0
			var/state_class = current_percent ? "mutation owned" : "mutation"
			mutation_rows += "<a class='[state_class]' href='byond://?src=\ref[src]&action=set_mutation&mutation=[mutation_id]'><b>[html_encode(mutation.stat)]</b><small>[html_encode(mutation_id)]</small><span>[current_percent]%</span></a>"
		var/rarity = character.mutation_rarity ? "[character.mutation_rarity]" : "None"
		return "<section class='mutation-panel'><div><h2>Character Mutations</h2><p>Rarity: <b>[html_encode(rarity)]</b>. Select a mutation to add, adjust, or remove it without stacking its previous stat modifier.</p></div><div class='mutation-grid'>[mutation_rows]</div></section>"

	proc/buildListHtml(variable_name)
		if(!canUse() || !(variable_name in target.vars) || !islist(target.vars[variable_name])) return ""
		var/list/value_list = target.vars[variable_name]
		var/list_rows = ""
		var/index = 0
		for(var/entry in value_list)
			index++
			var/associated_value = value_list[entry]
			list_rows += "<tr><td>[index]</td><td>[html_encode("[entry]")]</td><td>[html_encode("[associated_value]")]</td></tr>"
		if(!list_rows) list_rows = "<tr><td colspan='3'>This list is empty.</td></tr>"
		return {"<!doctype html><html><head><meta charset='utf-8'><title>Admin List Inspector</title><style>
		*{box-sizing:border-box}body{margin:0;padding:16px;background:#080c12;color:#e9eef6;font:13px Arial,sans-serif}a{color:#75caef;text-decoration:none}h1{margin:0 0 4px}p{color:#8fa0b6}table{width:100%;border-collapse:collapse;margin-top:15px}th,td{padding:8px;border-bottom:1px solid #263345;text-align:left;vertical-align:top;word-break:break-word}th{color:#91a4bd;background:#111b28}.back{display:inline-block;padding:8px 12px;border:1px solid #49657a;background:#142433}
		</style></head><body><a class='back' href='byond://?src=\ref[src]&action=back'>BACK TO ALL VARIABLES</a><h1>[html_encode(variable_name)]</h1><p>[value_list.len] complete list entries from [html_encode("[target]")].</p><table><thead><tr><th>#</th><th>Entry / key</th><th>Associated value</th></tr></thead><tbody>[list_rows]</tbody></table></body></html>"}

	proc/buildHtml()
		if(!canUse()) return ""
		var/mutation_panel = buildMutationPanel()
		var/list/category_order = list("Identity", "Combat", "Progression", "Appearance", "Position", "Collections", "System", "Other")
		var/list/variable_names = list()
		for(var/variable_name in target.vars)
			if("[variable_name]" in editFilter) continue
			variable_names += "[variable_name]"
		variable_names = dd_sortedtextlist(variable_names)
		var/rows_html = ""
		for(var/category in category_order)
			for(var/variable_name in variable_names)
				var/variable_value = target.vars[variable_name]
				if(getNexusAdminVariableCategory(variable_name, variable_value) != category) continue
				var/display_value = getNexusAdminVariableDisplay(variable_value)
				var/search_key = lowertext("[category] [variable_name] [display_value]")
				var/runtime_type = getNexusAdminVariableType(variable_value)
				var/display_html = html_encode("[display_value]")
				if(islist(variable_value)) display_html += " <a class='list-link' href='byond://?src=\ref[src]&action=view_list&var=[variable_name]'>VIEW ALL</a>"
				rows_html += "<tr data-category='[category]' data-search='[html_encode(search_key)]'><td><span class='category'>[category]</span></td><td><a href='byond://?src=\ref[src]&action=edit&var=[variable_name]'>[html_encode(variable_name)]</a></td><td>[display_html]</td><td><small>[html_encode(runtime_type)]</small></td></tr>"
		return {"<!doctype html><html><head><meta charset='utf-8'><title>Admin Inspector</title><style>
		*{box-sizing:border-box}html,body{margin:0;height:100%;background:#080c12;color:#e9eef6;font:13px Arial,sans-serif}.shell{height:100%;display:flex;flex-direction:column;background:radial-gradient(circle at 80% 0,#273344,#0b111a 48%,#06090e)}.header{padding:14px 18px;border-bottom:1px solid #435067;background:rgba(12,18,28,.96)}.header-top{display:flex;align-items:center;gap:10px}.header h1{font-size:20px;margin:0 auto 0 0;letter-spacing:1px}.header h1 small{display:block;color:#8491a5;font-size:10px;font-weight:normal;margin-top:3px}.close{color:#ffad8f;text-decoration:none;border:1px solid #68463e;padding:7px 10px}.search{width:100%;margin-top:12px;padding:10px;border:1px solid #48566e;background:#101824;color:#fff;outline:none}.filters{display:flex;gap:5px;flex-wrap:wrap;margin-top:8px}.filters button{padding:6px 9px;border:1px solid #3d4960;background:#121b29;color:#b9c5d5;cursor:pointer}.filters button.active{border-color:#70bde2;color:#fff;background:#193042}.mutation-panel{display:grid;grid-template-columns:230px 1fr;gap:12px;padding:12px 18px;border-bottom:1px solid #35445a;background:#0d1621}.mutation-panel h2{margin:0 0 5px;font-size:14px}.mutation-panel p{margin:0;color:#8fa0b4;font-size:11px}.mutation-grid{display:grid;grid-template-columns:repeat(4,minmax(145px,1fr));gap:5px}.mutation{position:relative;display:block;padding:7px 42px 7px 8px;border:1px solid #2d3b4e;background:#101a27;color:#99a8bb;text-decoration:none}.mutation.owned{border-color:#ae7ada;background:#241a32;color:#f0dcff}.mutation b,.mutation small{display:block}.mutation small{font-size:9px;color:#718196}.mutation span{position:absolute;right:8px;top:12px;font:bold 12px Consolas}.content{flex:1;min-height:0;overflow:auto;padding:0 14px 16px}table{width:100%;border-collapse:collapse;table-layout:fixed}th{position:sticky;top:0;background:#101824;color:#93a3ba;text-align:left;padding:9px;border-bottom:1px solid #46536a;font-size:10px;text-transform:uppercase}th:nth-child(1){width:120px}th:nth-child(2){width:240px}th:nth-child(4){width:180px}td{padding:8px 9px;border-bottom:1px solid #1e2937;vertical-align:top;word-wrap:break-word}tr:hover td{background:#101d2a}td a{color:#71c8ef;text-decoration:none;font-weight:bold}.list-link{display:inline-block;margin-left:8px;padding:2px 5px;border:1px solid #486174;font-size:9px}.category{display:inline-block;padding:3px 6px;border-left:3px solid #b28a58;background:#171d25;color:#d8c39c;font-size:9px;text-transform:uppercase}td small{color:#718096;font-family:Consolas,monospace}.empty{padding:30px;color:#77869b;text-align:center}
		</style></head><body><div class='shell'><div class='header'><div class='header-top'><h1>[html_encode("[target]")]<small>[html_encode("[target.type]")] / [variable_names.len] editable variables</small></h1><a class='close' href='byond://?src=\ref[src]&action=close'>CLOSE</a></div><input id='search' class='search' placeholder='Search variable, value or category...' oninput='applyFilters()'><div class='filters'><button class='active' data-filter='All' onclick='setCategory(this)'>All</button><button data-filter='Identity' onclick='setCategory(this)'>Identity</button><button data-filter='Combat' onclick='setCategory(this)'>Combat</button><button data-filter='Progression' onclick='setCategory(this)'>Progression</button><button data-filter='Appearance' onclick='setCategory(this)'>Appearance</button><button data-filter='Position' onclick='setCategory(this)'>Position</button><button data-filter='Collections' onclick='setCategory(this)'>Collections</button><button data-filter='System' onclick='setCategory(this)'>System</button><button data-filter='Other' onclick='setCategory(this)'>Other</button></div></div>[mutation_panel]<div class='content'><table><thead><tr><th>Category</th><th>Variable</th><th>Current value</th><th>Runtime type</th></tr></thead><tbody>[rows_html]</tbody></table></div></div><script>
		var activeCategory='All';function setCategory(button){activeCategory=button.getAttribute('data-filter');var buttons=document.querySelectorAll('.filters button');for(var i=0;i<buttons.length;i++)buttons.item(i).className='';button.className='active';applyFilters();}function applyFilters(){var query=document.getElementById('search').value.toLowerCase();var rows=document.querySelectorAll('tbody tr');for(var i=0;i<rows.length;i++){var row=rows.item(i);var categoryOk=activeCategory==='All'||row.getAttribute('data-category')===activeCategory;var searchOk=!query||row.getAttribute('data-search').indexOf(query)>=0;row.style.display=categoryOk&&searchOk?'table-row':'none';}}
		</script></body></html>"}

	proc/show()
		if(!canUse())
			if(owner) owner << "The Admin Inspector requires Admin Level 3 and a valid target."
			del(src)
			return
		owner << browse(buildHtml(), "window=NexusAdminInspector;size=1180x760;can_resize=true;can_close=true")

	Topic(href, list/href_list)
		if(!canUse() || usr != owner) return
		switch(href_list["action"])
			if("edit") editVariable(href_list["var"])
			if("set_mutation") editMutation(href_list["mutation"])
			if("view_list")
				owner << browse(buildListHtml(href_list["var"]), "window=NexusAdminInspector;size=1180x760;can_resize=true;can_close=true")
				return
			if("back")
				show()
				return
			if("close")
				owner << browse(null, "window=NexusAdminInspector")
				del(src)
				return
		show()

mob/proc/showNexusAdminInspector(atom/target)
	if(!client) return
	if(AdminLevel() < 3)
		src << "The Admin Inspector requires Admin Level 3."
		return
	if(!target)
		src << "The Admin Inspector needs a valid target."
		return
	if(client.nexus_admin_inspector) del(client.nexus_admin_inspector)
	client.nexus_admin_inspector = new /datum/NexusAdminInspector(src, target)
	client.nexus_admin_inspector.show()
	admin_blame(src, "[key] opened the structured admin inspector for [target]")
