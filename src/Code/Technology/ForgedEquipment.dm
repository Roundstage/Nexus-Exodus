datum/ForgedMaterial
	var
		id
		name
		required_level = 1
		ore_type
		ore_cost = 3
		previous_material_id
		weapon_damage = 1.2
		weapon_bp_bonus = 0.12
		armor_protection = 1.2
		armor_heaviness = 1.08
		armor_bp_bonus = 0.08
		energy_weapon = FALSE
		description

	New(new_id, new_name, new_level, new_ore_type, new_cost, new_previous_id, new_damage, new_weapon_bp_bonus, new_protection, new_heaviness, new_armor_bp_bonus, new_energy_weapon = FALSE, new_description = "")
		id = new_id
		name = new_name
		required_level = new_level
		ore_type = new_ore_type
		ore_cost = new_cost
		previous_material_id = new_previous_id
		weapon_damage = new_damage
		weapon_bp_bonus = new_weapon_bp_bonus
		armor_protection = new_protection
		armor_heaviness = new_heaviness
		armor_bp_bonus = new_armor_bp_bonus
		energy_weapon = new_energy_weapon
		description = new_description

datum/ForgedWeaponStyle
	var
		id
		name
		equipment_name = "Sword"
		icon_file
		description

	New(new_id, new_name, new_equipment_name, new_icon, new_description)
		id = new_id
		name = new_name
		equipment_name = new_equipment_name
		icon_file = new_icon
		description = new_description

datum/ForgedArmorStyle
	var
		id
		name
		icon_file

	New(new_id, new_name, new_icon)
		id = new_id
		name = new_name
		icon_file = new_icon

var/list/forged_material_catalog
var/list/forged_weapon_style_catalog
var/list/forged_armor_style_catalog

proc/initializeForgedEquipmentCatalogs()
	if(!islist(forged_material_catalog) || !forged_material_catalog.len)
		forged_material_catalog = list()
		forged_material_catalog["copper"] = new /datum/ForgedMaterial("copper", "Copper", 1, /obj/items/Ore/Copper, 3, null, 1.2, 0.12, 1.2, 1.08, 0.08, FALSE, "Accessible and balanced, but comparatively soft.")
		forged_material_catalog["bronze"] = new /datum/ForgedMaterial("bronze", "Bronze", 4, /obj/items/Ore/Tin, 3, "copper", 1.28, 0.18, 1.28, 1.12, 0.12, FALSE, "A durable copper alloy with moderate weight.")
		forged_material_catalog["iron"] = new /datum/ForgedMaterial("iron", "Iron", 8, /obj/items/Ore/Iron, 4, "bronze", 1.38, 0.28, 1.42, 1.22, 0.22, FALSE, "Heavy and powerful; excellent direct impact at a mobility cost.")
		forged_material_catalog["silver"] = new /datum/ForgedMaterial("silver", "Silver", 14, /obj/items/Ore/Silver, 4, "bronze", 1.42, 0.22, 1.4, 1.1, 0.16, FALSE, "A refined anti-undead branch with good handling and critical potential.")
		forged_material_catalog["mythril"] = new /datum/ForgedMaterial("mythril", "Mythril", 20, /obj/items/Ore/Mythril, 5, "iron", 1.52, 0.32, 1.48, 1.04, 0.2, FALSE, "Exceptionally light for its strength; retains far more mobility than iron.")
		forged_material_catalog["auracite"] = new /datum/ForgedMaterial("auracite", "Auracite", 30, /obj/items/Ore/Auracite, 5, "silver", 1.64, 0.38, 1.68, 1.12, 0.28, TRUE, "Energy-reactive crystal metal with the strongest specialized protection.")
		forged_material_catalog["masterwork"] = new /datum/ForgedMaterial("masterwork", "Masterwork", 35, /obj/items/Ore/HeartOfTheMountain, 1, "mythril", 1.68, 0.42, 1.62, 1.08, 0.32, FALSE, "The peak physical alloy: enormous BP reinforcement without iron's weight.")
	if(!islist(forged_weapon_style_catalog) || !forged_weapon_style_catalog.len)
		forged_weapon_style_catalog = list()
		forged_weapon_style_catalog["trunks"] = new /datum/ForgedWeaponStyle("trunks", "Trunks", "Sword", 'RTSwordTrunks.dmi', "A compact Tenkaichi sword skin.")
		forged_weapon_style_catalog["knight"] = new /datum/ForgedWeaponStyle("knight", "Knight", "Sword", 'RTIronSword.dmi', "A broad knight sword skin.")
		forged_weapon_style_catalog["demon"] = new /datum/ForgedWeaponStyle("demon", "Demon", "Sword", 'RTCopperSword.dmi', "A curved demonic sword skin.")
		forged_weapon_style_catalog["katana"] = new /datum/ForgedWeaponStyle("katana", "Katana", "Katana", 'RTKatana2.dmi', "A single-edged katana skin.")
		forged_weapon_style_catalog["long_katana"] = new /datum/ForgedWeaponStyle("long_katana", "Long Katana", "Katana", 'RTKatana.dmi', "An extended katana skin.")
		forged_weapon_style_catalog["short_sword"] = new /datum/ForgedWeaponStyle("short_sword", "Short Sword", "Short Sword", 'RTShortSword.dmi', "A compact short-blade skin.")
		forged_weapon_style_catalog["rebellion"] = new /datum/ForgedWeaponStyle("rebellion", "Rebellion", "Sword", 'ItemSword1.dmi', "The Rebellion appearance; visual only.")
		forged_weapon_style_catalog["buster"] = new /datum/ForgedWeaponStyle("buster", "Buster", "Great Sword", 'ItemBusterSword.dmi', "The Buster appearance; visual only.")
		forged_weapon_style_catalog["great_sword"] = new /datum/ForgedWeaponStyle("great_sword", "Great Sword", "Great Sword", 'ItemGreatSword.dmi', "A massive great-sword skin.")
		forged_weapon_style_catalog["flame"] = new /datum/ForgedWeaponStyle("flame", "Flame", "Sword", 'RTMythrilSword.dmi', "A flame-shaped sword skin; material determines damage type.")
		forged_weapon_style_catalog["samurai"] = new /datum/ForgedWeaponStyle("samurai", "Samurai", "Katana", 'RTAuraciteSword.dmi', "An ornate samurai blade skin.")
		forged_weapon_style_catalog["hammer"] = new /datum/ForgedWeaponStyle("hammer", "War Hammer", "War Hammer", 'RTHammer.dmi', "A forged war-hammer skin.")
		forged_weapon_style_catalog["sledgehammer"] = new /datum/ForgedWeaponStyle("sledgehammer", "Sledgehammer", "Sledgehammer", 'RTSledgehammer.dmi', "A two-handed sledgehammer skin.")
		forged_weapon_style_catalog["mage_staff"] = new /datum/ForgedWeaponStyle("mage_staff", "Mage Staff", "Staff", 'RTMageStaff.dmi', "A mage-staff skin; Auracite supplies energy conduction.")
	if(!islist(forged_armor_style_catalog) || !forged_armor_style_catalog.len)
		forged_armor_style_catalog = list()
		forged_armor_style_catalog["classic"] = new /datum/ForgedArmorStyle("classic", "Classic Armor", 'RTCopperArmor.dmi')
		forged_armor_style_catalog["battle_2"] = new /datum/ForgedArmorStyle("battle_2", "Tenkaichi Armor II", 'Armor2.dmi')
		forged_armor_style_catalog["battle_3"] = new /datum/ForgedArmorStyle("battle_3", "Tenkaichi Armor III", 'Armor3.dmi')
		forged_armor_style_catalog["battle_4"] = new /datum/ForgedArmorStyle("battle_4", "Tenkaichi Armor IV", 'Armor4.dmi')
		forged_armor_style_catalog["battle_5"] = new /datum/ForgedArmorStyle("battle_5", "Tenkaichi Armor V", 'Armor5.dmi')
		forged_armor_style_catalog["battle_6"] = new /datum/ForgedArmorStyle("battle_6", "Tenkaichi Armor VI", 'Armor6.dmi')
		forged_armor_style_catalog["battle_7"] = new /datum/ForgedArmorStyle("battle_7", "Tenkaichi Armor VII", 'Armor7.dmi')
		forged_armor_style_catalog["bardock"] = new /datum/ForgedArmorStyle("bardock", "Bardock Armor", 'RTBardockArmor.dmi')
		forged_armor_style_catalog["turles"] = new /datum/ForgedArmorStyle("turles", "Turles Armor", 'TurlesArmor.dmi')
		forged_armor_style_catalog["nappa"] = new /datum/ForgedArmorStyle("nappa", "Nappa Armor", 'NappaArmor.dmi')
		forged_armor_style_catalog["azure"] = new /datum/ForgedArmorStyle("azure", "Azure Armor", 'RTIronArmor.dmi')
		forged_armor_style_catalog["mythril"] = new /datum/ForgedArmorStyle("mythril", "Mythril Armor", 'RTMythrilArmor.dmi')
		forged_armor_style_catalog["auracite"] = new /datum/ForgedArmorStyle("auracite", "Auracite Armor", 'RTAuraciteArmor.dmi')

proc/getForgedMaterialUpgradeOptions(current_material_id)
	initializeForgedEquipmentCatalogs()
	var/list/options = list()
	for(var/material_id in forged_material_catalog)
		var/datum/ForgedMaterial/material = forged_material_catalog[material_id]
		if(material.previous_material_id == current_material_id) options += material
	return options

mob/proc/chooseForgedWeaponStyle(title = "Forge Weapon")
	initializeForgedEquipmentCatalogs()
	var/list/options = list()
	for(var/style_id in forged_weapon_style_catalog)
		var/datum/ForgedWeaponStyle/style = forged_weapon_style_catalog[style_id]
		options["[style.name] skin - [style.description]"] = style
	var/choice = input(src, "Choose a cosmetic skin. Material alone determines combat statistics and remains independent from this appearance.", title) as null|anything in options
	if(isnull(choice)) return
	return options[choice]

mob/proc/chooseForgedArmorStyle(title = "Forge Armor")
	initializeForgedEquipmentCatalogs()
	var/list/options = list()
	for(var/style_id in forged_armor_style_catalog)
		var/datum/ForgedArmorStyle/style = forged_armor_style_catalog[style_id]
		options["[style.name] skin"] = style
	var/choice = input(src, "Choose a cosmetic skin. Material alone determines protection and weight.", title) as null|anything in options
	if(isnull(choice)) return
	return options[choice]

mob/proc/applyMasterBlacksmithQuality(obj/items/item)
	if(!item || !getMilestoneRank("master_blacksmith")) return
	if(istype(item, /obj/items/Sword/Forged))
		var/obj/items/Sword/Forged/sword = item
		sword.master_blacksmith_quality = TRUE
		sword.refreshForgedWeapon()
	else if(istype(item, /obj/items/Armor/Forged))
		var/obj/items/Armor/Forged/armor = item
		armor.master_blacksmith_quality = TRUE
		armor.refreshForgedArmor()

mob/proc/craftForgedWeapon(style_id)
	syncProfessionProgression()
	var/datum/ForgedMaterial/material
	initializeForgedEquipmentCatalogs()
	material = forged_material_catalog["copper"]
	var/datum/ForgedWeaponStyle/style = forged_weapon_style_catalog[style_id]
	if(!style) style = chooseForgedWeaponStyle()
	if(!style) return
	var/ore_cost = max(1, material.ore_cost - getMilestoneRank("master_blacksmith"))
	if(!consumeOre(material.ore_type, ore_cost))
		src << "You need [ore_cost] Copper ore to forge a weapon."
		return
	var/obj/items/Sword/Forged/weapon = new(src)
	weapon.forged_material_id = material.id
	weapon.forged_style_id = style.id
	applyMasterBlacksmithQuality(weapon)
	weapon.refreshForgedWeapon()
	gainProfessionExperience("Smithing", 18, "forging [weapon]", announce = TRUE)
	player_view(15, src) << "<font color=#e0bd83>[src] forges [weapon]."
	return weapon

mob/proc/craftForgedArmor(style_id)
	syncProfessionProgression()
	initializeForgedEquipmentCatalogs()
	var/datum/ForgedMaterial/material = forged_material_catalog["copper"]
	var/datum/ForgedArmorStyle/style = forged_armor_style_catalog[style_id]
	if(!style) style = chooseForgedArmorStyle()
	if(!style) return
	var/ore_cost = max(1, 4 - getMilestoneRank("master_blacksmith"))
	if(!consumeOre(material.ore_type, ore_cost))
		src << "You need [ore_cost] Copper ore to forge armor."
		return
	var/obj/items/Armor/Forged/armor = new(src)
	armor.forged_material_id = material.id
	armor.forged_style_id = style.id
	applyMasterBlacksmithQuality(armor)
	armor.refreshForgedArmor()
	gainProfessionExperience("Smithing", 22, "forging [armor]", announce = TRUE)
	player_view(15, src) << "<font color=#e0bd83>[src] forges [armor]."
	return armor

mob/proc/upgradeForgedEquipment(obj/items/equipment)
	if(!equipment || equipment.loc != src) return
	if(equipment.suffix)
		src << "Remove [equipment] before improving it."
		return
	var/current_material_id
	var/is_weapon = FALSE
	if(istype(equipment, /obj/items/Sword/Forged))
		var/obj/items/Sword/Forged/weapon = equipment
		current_material_id = weapon.forged_material_id
		is_weapon = TRUE
	else if(istype(equipment, /obj/items/Armor/Forged))
		var/obj/items/Armor/Forged/armor = equipment
		current_material_id = armor.forged_material_id
	else
		src << "Only equipment made by the Tenkaichi forge can use this upgrade chain."
		return
	var/list/upgrades = getForgedMaterialUpgradeOptions(current_material_id)
	if(!upgrades.len)
		src << "[equipment] has reached the end of its material path."
		return
	var/list/options = list()
	for(var/datum/ForgedMaterial/material in upgrades)
		if(smithing_level < material.required_level) continue
		var/ore_cost = max(1, material.ore_cost - getMilestoneRank("master_blacksmith"))
		var/obj/items/Ore/ore_example = new material.ore_type
		var/stat_summary
		if(is_weapon)
			stat_summary = "+[round(material.weapon_bp_bonus * 100)]% attack BP / [round(material.weapon_damage, 0.01)]x sharpness"
		else
			stat_summary = "+[round(material.armor_bp_bonus * 100)]% endurance BP / [round(material.armor_protection, 0.01)]x protection / [round(material.armor_heaviness, 0.01)]x weight"
		options["[material.name] - [stat_summary] - [ore_cost] [ore_example.ore_name] - Smithing [material.required_level]"] = material
		del(ore_example)
	if(!options.len)
		src << "Your Smithing level is too low for [equipment]'s next material upgrade."
		return
	var/choice = input(src, "Choose [equipment]'s new material module. The cosmetic skin will not change. Bronze branches into Iron/Mythril/Masterwork or Silver/Auracite.", "Improve Equipment") as null|anything in options
	if(isnull(choice)) return
	var/datum/ForgedMaterial/new_material = options[choice]
	var/final_cost = max(1, new_material.ore_cost - getMilestoneRank("master_blacksmith"))
	if(!consumeOre(new_material.ore_type, final_cost))
		var/obj/items/Ore/ore_example = new new_material.ore_type
		src << "You need [final_cost] [ore_example.ore_name] to improve [equipment]."
		del(ore_example)
		return
	if(istype(equipment, /obj/items/Sword/Forged))
		var/obj/items/Sword/Forged/weapon = equipment
		weapon.forged_material_id = new_material.id
		weapon.refreshForgedWeapon()
	else
		var/obj/items/Armor/Forged/armor = equipment
		armor.forged_material_id = new_material.id
		armor.refreshForgedArmor()
	gainProfessionExperience("Smithing", 20 + new_material.required_level * 2, "improving [equipment] to [new_material.name]", announce = TRUE)
	player_view(15, src) << "<font color=#e0bd83>[src] improves [equipment] with [new_material.name]."

mob/proc/openForgeUpgradeMenu(obj/Forge/forge)
	if(!forge || getdist(src, forge) > 1) return
	var/list/options = list()
	for(var/obj/items/Sword/Forged/weapon in item_list) options += weapon
	for(var/obj/items/Armor/Forged/armor in item_list) options += armor
	if(!options.len)
		src << "You are not carrying Tenkaichi-forged equipment."
		return
	var/obj/items/equipment = input(src, "Choose equipment to improve. Its design, quality and combat style are preserved.", "Improve Equipment") as null|obj in options
	if(equipment) upgradeForgedEquipment(equipment)

proc/getForgeBrowserCss()
	return {"
	<style>
	*{box-sizing:border-box}html,body{margin:0;min-height:100%;background:#100d09;color:#ead7ad;font:13px 'Courier New',monospace}body{padding:10px}.shell{max-width:1050px;margin:auto}.header,.panel{border:3px ridge #8e6b36;background:#21180f;box-shadow:4px 4px #080604}.header{padding:12px;margin-bottom:10px}.header h1{margin:0;color:#ffd784;font-size:20px;letter-spacing:2px}.header p{margin:6px 0 0;color:#c7ad7d}.actions,.styles{display:grid;grid-template-columns:repeat(3,minmax(190px,1fr));gap:8px}.action,.style{display:block;position:relative;border:3px outset #8e6b36;background:#332416;color:#f3dba6;text-decoration:none;padding:12px;min-height:92px}.action:hover,.style:hover{background:#49321b;border-color:#d2a352}.action b,.action span,.style b,.style span,.style small{display:block}.action b,.style b{font-size:15px;color:#ffe5a7}.action span,.style small{margin-top:7px;color:#bfa778;line-height:1.35}.style{min-height:190px;text-align:center}.style img{display:block;width:96px;height:96px;object-fit:contain;image-rendering:pixelated;margin:0 auto 8px;background:#0b0907;border:2px inset #74562d}.tag{display:inline-block!important;margin:0 0 7px;padding:3px 6px;background:#15100b;border:1px solid #75552c;color:#d6b271!important;font-size:10px}.panel{padding:10px;margin-top:10px}.panel h2{margin:0 0 8px;color:#ffd784;font-size:15px}.guide{width:100%;border-collapse:collapse}.guide th,.guide td{border:1px solid #69502e;padding:7px;text-align:left;vertical-align:top}.guide th{background:#3b2917;color:#ffd784}.guide tr:nth-child(even){background:#271c12}.good{color:#9ee39e}.warn{color:#efc978}.nav{display:flex;gap:7px;margin-top:9px}.button{display:inline-block;padding:7px 11px;border:3px outset #8e6b36;background:#3a2918;color:#ffe1a0;text-decoration:none;font-weight:bold}.button:active{border-style:inset}.hint{padding:8px;border:1px dashed #7a5c34;color:#cdb483;margin-top:9px}@media(max-width:760px){.actions,.styles{grid-template-columns:repeat(2,1fr)}.guide{font-size:11px}}
	</style>"}

proc/buildForgeMaterialGuideHtml()
	initializeForgedEquipmentCatalogs()
	var/html = "<table class='guide'><tr><th>Material / path</th><th>Weapon</th><th>Armor</th><th>Identity</th></tr>"
	for(var/material_id in forged_material_catalog)
		var/datum/ForgedMaterial/material = forged_material_catalog[material_id]
		var/path_text = "Starting material"
		if(material.previous_material_id)
			var/datum/ForgedMaterial/previous = forged_material_catalog[material.previous_material_id]
			path_text = "Upgrade from [previous ? previous.name : material.previous_material_id]"
		var/weight_text = "Medium"
		if(material.armor_heaviness <= 1.05) weight_text = "Very light"
		else if(material.armor_heaviness >= 1.18) weight_text = "Heavy"
		else if(material.armor_heaviness >= 1.1) weight_text = "Moderate"
		var/damage_type = material.energy_weapon ? "Energy" : "Physical"
		html += "<tr><td><b>[material.name]</b><br>Smithing [material.required_level]<br><small>[path_text]</small></td><td>+[round(material.weapon_bp_bonus * 100)]% attack BP<br>[round(material.weapon_damage, 0.01)]x sharpness<br>[damage_type]</td><td>+[round(material.armor_bp_bonus * 100)]% endurance BP<br>[round(material.armor_protection, 0.01)]x protection<br>[weight_text] ([round(material.armor_heaviness, 0.01)]x)</td><td>[html_encode(material.description)]</td></tr>"
	return html + "</table>"

mob/proc/openForgeStyleBrowser(obj/Forge/forge, equipment_kind)
	if(!forge || getdist(src, forge) > 1 || KO || rp_mode) return
	initializeForgedEquipmentCatalogs()
	var/styles_html = ""
	if(equipment_kind == "weapon")
		for(var/style_id in forged_weapon_style_catalog)
			var/datum/ForgedWeaponStyle/style = forged_weapon_style_catalog[style_id]
			var/resource_name = "nexus_forge_weapon_[style.id].png"
			src << browse_rsc(icon(style.icon_file), resource_name)
			styles_html += "<a class='style' href='byond://?src=\ref[forge]&forge_action=craft_weapon&style=[style.id]'><span class='tag'>COSMETIC SKIN</span><img src='[resource_name]'><b>[html_encode(style.name)]</b><small>Creates: Copper [html_encode(style.equipment_name)]</small><small>[html_encode(style.description)]</small></a>"
	else
		for(var/style_id in forged_armor_style_catalog)
			var/datum/ForgedArmorStyle/style = forged_armor_style_catalog[style_id]
			var/resource_name = "nexus_forge_armor_[style.id].png"
			src << browse_rsc(icon(style.icon_file), resource_name)
			styles_html += "<a class='style' href='byond://?src=\ref[forge]&forge_action=craft_armor&style=[style.id]'><span class='tag'>COSMETIC SKIN</span><img src='[resource_name]'><b>[html_encode(style.name)]</b><small>Creates: Copper Armor</small><small>Protection and weight come exclusively from the material.</small></a>"
	var/title = equipment_kind == "weapon" ? "Weapon Appearance" : "Armor Appearance"
	var/html = "<html><head>[getForgeBrowserCss()]</head><body><div class='shell'><div class='header'><h1>[title]</h1><p>Choose the sprite only. Named designs such as Rebellion are not unique weapons and grant no hidden statistics.</p><div class='nav'><a class='button' href='byond://?src=\ref[forge]&forge_action=menu'>BACK TO FORGE</a><a class='button' href='byond://?src=\ref[forge]&forge_action=guide'>MATERIAL GUIDE</a></div></div><div class='styles'>[styles_html]</div></div></body></html>"
	src << browse(html, "window=nexus_forge;size=1050x760;can_resize=true")

mob/proc/openForgeMaterialGuide(obj/Forge/forge)
	if(!forge || getdist(src, forge) > 1) return
	var/html = "<html><head>[getForgeBrowserCss()]</head><body><div class='shell'><div class='header'><h1>Forging Material Guide</h1><p>Material controls every combat statistic. The selected icon remains cosmetic through all upgrades.</p><div class='nav'><a class='button' href='byond://?src=\ref[forge]&forge_action=menu'>BACK TO FORGE</a></div></div><div class='panel'><h2>Material branches and effects</h2>[buildForgeMaterialGuideHtml()]<div class='hint'>Direct path: Copper - Bronze - Iron - Mythril - Masterwork. Specialized path: Copper - Bronze - Silver - Auracite. Mythril is the lightest advanced armor; Auracite converts forged weapons to Energy damage.</div></div></div></body></html>"
	src << browse(html, "window=nexus_forge;size=1050x760;can_resize=true")

mob/proc/openSmithingMenu(obj/Forge/forge)
	if(!forge || getdist(src, forge) > 1 || KO || rp_mode) return
	syncProfessionProgression()
	var/weapon_cost = max(1, 3 - getMilestoneRank("master_blacksmith"))
	var/armor_cost = max(1, 4 - getMilestoneRank("master_blacksmith"))
	var/html = "<html><head>[getForgeBrowserCss()]</head><body><div class='shell'><div class='header'><h1>Tenkaichi Forge</h1><p>Smithing level [smithing_level]. Equipment is modular: material determines performance, while the selected design is visual only.</p></div><div class='actions'><a class='action' href='byond://?src=\ref[forge]&forge_action=weapon'><b>FORGE WEAPON</b><span>[weapon_cost] Copper ore. Opens the visual skin gallery.</span></a><a class='action' href='byond://?src=\ref[forge]&forge_action=armor'><b>FORGE ARMOR</b><span>[armor_cost] Copper ore. Opens the visual skin gallery.</span></a><a class='action' href='byond://?src=\ref[forge]&forge_action=upgrade'><b>IMPROVE EQUIPMENT</b><span>Upgrade material while preserving the icon.</span></a><a class='action' href='byond://?src=\ref[forge]&forge_action=pickaxe'><b>FORGE PICKAXE</b><span>[weapon_cost] Copper ore.</span></a><a class='action' href='byond://?src=\ref[forge]&forge_action=guide'><b>MATERIAL GUIDE</b><span>Compare BP reinforcement, protection and weight.</span></a><a class='action' href='byond://?src=\ref[forge]&forge_action=close'><b>CLOSE</b><span>Return to the game.</span></a></div><div class='panel'><h2>Quick material comparison</h2>[buildForgeMaterialGuideHtml()]</div></div></body></html>"
	src << browse(html, "window=nexus_forge;size=1050x760;can_resize=true")

mob/proc/craftTenkaichiPickaxe()
	var/ore_cost = max(1, 3 - getMilestoneRank("master_blacksmith"))
	if(!consumeOre(/obj/items/Ore/Copper, ore_cost))
		src << "You need [ore_cost] Copper ore to forge a pickaxe."
		return FALSE
	var/obj/items/Digging/TenkaichiPickaxe/pickaxe = new(src)
	gainProfessionExperience("Smithing", 15, "forging [pickaxe]", announce = TRUE)
	player_view(15, src) << "<font color=#e0bd83>[src] forges [pickaxe]."
	return TRUE

obj/Forge
	name = "Tenkaichi Forge"
	desc = "A Roleplay Tenkaichi forge used to create and improve persistent weapon and armor designs."
	icon = 'RTForge.dmi'
	density = 1
	Health = 100000
	Cost = 250000
	Savable = 1
	takes_gradual_damage = 1
	science = 1
	science_level = 3
	science_path = "Engineering"

	verb/Smith()
		set src in oview(1)
		usr.openSmithingMenu(src)

	verb/Material_Paths()
		set name = "View Material Paths"
		set src in oview(1)
		usr.openForgeMaterialGuide(src)

	Topic(href, list/href_list)
		. = ..()
		if(!usr || getdist(usr, src) > 1 || usr.KO || usr.rp_mode) return
		var/forge_action = href_list["forge_action"]
		switch(forge_action)
			if("menu") usr.openSmithingMenu(src)
			if("weapon") usr.openForgeStyleBrowser(src, "weapon")
			if("armor") usr.openForgeStyleBrowser(src, "armor")
			if("guide") usr.openForgeMaterialGuide(src)
			if("upgrade")
				usr.openForgeUpgradeMenu(src)
				usr.openSmithingMenu(src)
			if("pickaxe")
				usr.craftTenkaichiPickaxe()
				usr.openSmithingMenu(src)
			if("craft_weapon")
				usr.craftForgedWeapon(href_list["style"])
				usr.openSmithingMenu(src)
			if("craft_armor")
				usr.craftForgedArmor(href_list["style"])
				usr.openSmithingMenu(src)
			if("close") usr << browse(null, "window=nexus_forge")

obj/items/Sword/Forged
	Cost = 0
	can_change_icon = 0
	Stealable = 1
	var/forged_material_id = "copper"
	var/forged_style_id = "trunks"
	var/master_blacksmith_quality = FALSE
	var/forged_attack_bp_bonus = 0.12

	New()
		. = ..()
		refreshForgedWeapon()
		spawn(1) if(src) refreshForgedWeapon()

	proc/refreshForgedWeapon()
		initializeForgedEquipmentCatalogs()
		var/datum/ForgedMaterial/material = forged_material_catalog[forged_material_id]
		var/datum/ForgedWeaponStyle/style = forged_weapon_style_catalog[forged_style_id]
		if(!material) material = forged_material_catalog["copper"]
		if(!style) style = forged_weapon_style_catalog["trunks"]
		forged_material_id = material.id
		forged_style_id = style.id
		name = "[material.name] [style.equipment_name]"
		icon = style.icon_file
		Damage = min(2, material.weapon_damage * (master_blacksmith_quality ? 1.05 : 1))
		forged_attack_bp_bonus = min(0.5, material.weapon_bp_bonus + (master_blacksmith_quality ? 0.03 : 0))
		Style = material.energy_weapon ? "Energy" : "Physical"
		is_silver = material.id == "silver"
		Sword_Desc()
		desc += "<br>Material: [material.name]<br>Appearance: [style.name] skin (cosmetic)<br>Attack BP reinforcement: +[round(forged_attack_bp_bonus * 100)]%<br>Damage type: [Style]<br>[material.description]"

	verb/Improve_At_Forge()
		set name = "Improve at Forge"
		set src in usr
		var/obj/Forge/nearby_forge
		for(var/obj/Forge/forge in oview(1, usr))
			nearby_forge = forge
			break
		if(!nearby_forge)
			usr << "Stand beside a Tenkaichi Forge to improve this weapon."
			return
		usr.upgradeForgedEquipment(src)

	Copper
		forged_material_id = "copper"
		forged_style_id = "demon"

	Iron
		forged_material_id = "iron"
		forged_style_id = "knight"

	Mythril
		forged_material_id = "mythril"
		forged_style_id = "flame"

	Auracite
		forged_material_id = "auracite"
		forged_style_id = "samurai"

obj/items/Armor/Forged
	Cost = 0
	can_change_icon = 0
	Stealable = 1
	armor_ver = 2
	var/forged_material_id = "copper"
	var/forged_style_id = "classic"
	var/master_blacksmith_quality = FALSE
	var/forged_defense_bp_bonus = 0.08

	New()
		. = ..()
		refreshForgedArmor()
		spawn(1) if(src) refreshForgedArmor()

	proc/refreshForgedArmor()
		initializeForgedEquipmentCatalogs()
		var/datum/ForgedMaterial/material = forged_material_catalog[forged_material_id]
		var/datum/ForgedArmorStyle/style = forged_armor_style_catalog[forged_style_id]
		if(!material) material = forged_material_catalog["copper"]
		if(!style) style = forged_armor_style_catalog["classic"]
		forged_material_id = material.id
		forged_style_id = style.id
		name = "[material.name] Armor"
		icon = style.icon_file
		Armor = min(2, material.armor_protection * (master_blacksmith_quality ? 1.05 : 1))
		heaviness = material.armor_heaviness
		forged_defense_bp_bonus = min(0.4, material.armor_bp_bonus + (master_blacksmith_quality ? 0.03 : 0))
		Armor_Desc()
		desc += "<br>Material: [material.name]<br>Appearance: [style.name] skin (cosmetic)<br>Endurance BP reinforcement: +[round(forged_defense_bp_bonus * 100)]%<br>Weight: [round(heaviness, 0.01)]x<br>[material.description]"

	verb/Improve_At_Forge()
		set name = "Improve at Forge"
		set src in usr
		var/obj/Forge/nearby_forge
		for(var/obj/Forge/forge in oview(1, usr))
			nearby_forge = forge
			break
		if(!nearby_forge)
			usr << "Stand beside a Tenkaichi Forge to improve this armor."
			return
		usr.upgradeForgedEquipment(src)

	Copper
		forged_material_id = "copper"
		forged_style_id = "classic"

	Iron
		forged_material_id = "iron"
		forged_style_id = "azure"

	Mythril
		forged_material_id = "mythril"
		forged_style_id = "mythril"

	Auracite
		forged_material_id = "auracite"
		forged_style_id = "auracite"

mob/proc/getForgedWeaponAttackBP()
	var/effective_bp = BP
	var/obj/items/Sword/Forged/weapon = using_sword()
	if(istype(weapon) && weapon.Health > 0)
		effective_bp *= 1 + max(0, weapon.forged_attack_bp_bonus)
	return effective_bp

mob/proc/getForgedArmorEnduranceBP()
	var/effective_bp = BP
	if(istype(armor_obj, /obj/items/Armor/Forged) && armor_obj.suffix && armor_obj.Health > 0)
		var/obj/items/Armor/Forged/armor = armor_obj
		effective_bp *= 1 + max(0, armor.forged_defense_bp_bonus)
	return effective_bp

obj/items/Digging/TenkaichiPickaxe
	name = "Tenkaichi Pickaxe"
	desc = "The Roleplay Tenkaichi mining pickaxe. Equip it to improve excavation yield."
	icon = 'RTPickaxe.dmi'
	DigMult = 5
	Cost = 0
	Stealable = 1

	verb/Hotbar_use()
		set hidden = 1
		Click()

	Click()
		if(src in usr)
			for(var/obj/items/Digging/tool in usr.item_list)
				if(tool != src && tool.suffix) tool.suffix = null
			suffix = suffix ? null : "Equipped"

mob/Admin3/verb/testTenkaichiSmithing(mob/character in players)
	set name = "Test Tenkaichi Smithing"
	set category = "Admin"
	if(AdminLevel() < 3 || !character) return
	character.mining_experience = getProfessionExperienceForLevel(50)
	character.smithing_experience = getProfessionExperienceForLevel(50)
	character.syncProfessionProgression()
	for(var/ore_type in list(/obj/items/Ore/Copper, /obj/items/Ore/Tin, /obj/items/Ore/Iron, /obj/items/Ore/Silver, /obj/items/Ore/Mythril, /obj/items/Ore/Auracite, /obj/items/Ore/HeartOfTheMountain))
		character.addMinedOre(ore_type, 40)
	var/turf/forge_location = get_step(character, SOUTH)
	if(!forge_location) forge_location = character.loc
	new /obj/Forge(forge_location)
	admin_blame(src, "[key] prepared [character] to test the Tenkaichi smithing progression.")
	src << "[character] received level 50 Mining/Smithing, every material, and a forge."

mob/Admin3/verb/giveTenkaichiEquipment(mob/character in players)
	set name = "Give Tenkaichi Equipment"
	set category = "Admin"
	if(AdminLevel() < 3 || !character) return
	initializeForgedEquipmentCatalogs()
	var/equipment_kind = input(src, "Choose the equipment family to test.", "Tenkaichi Equipment") in list("Cancel", "Weapon", "Armor", "Pickaxe")
	if(equipment_kind == "Cancel") return
	if(equipment_kind == "Pickaxe")
		new /obj/items/Digging/TenkaichiPickaxe(character)
		admin_blame(src, "[key] gave [character] a Tenkaichi Pickaxe.")
		return
	var/list/material_options = list()
	for(var/material_id in forged_material_catalog)
		var/datum/ForgedMaterial/material = forged_material_catalog[material_id]
		material_options[material.name] = material
	var/material_choice = input(src, "Choose the material tier.", "Tenkaichi Equipment") as null|anything in material_options
	if(isnull(material_choice)) return
	var/datum/ForgedMaterial/selected_material = material_options[material_choice]
	if(equipment_kind == "Weapon")
		var/datum/ForgedWeaponStyle/weapon_style = chooseForgedWeaponStyle("Give Tenkaichi Equipment")
		if(!weapon_style) return
		var/obj/items/Sword/Forged/weapon = new(character)
		weapon.forged_material_id = selected_material.id
		weapon.forged_style_id = weapon_style.id
		weapon.refreshForgedWeapon()
		admin_blame(src, "[key] gave [character] [weapon].")
	else
		var/datum/ForgedArmorStyle/armor_style = chooseForgedArmorStyle("Give Tenkaichi Equipment")
		if(!armor_style) return
		var/obj/items/Armor/Forged/armor = new(character)
		armor.forged_material_id = selected_material.id
		armor.forged_style_id = armor_style.id
		armor.refreshForgedArmor()
		admin_blame(src, "[key] gave [character] [armor].")
