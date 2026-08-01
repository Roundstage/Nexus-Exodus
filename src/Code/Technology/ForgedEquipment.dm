datum/ForgedMaterial
	var
		id
		name
		required_level = 1
		ore_type
		ore_cost = 3
		previous_material_id
		weapon_damage = 1.2
		armor_protection = 1.2
		armor_heaviness = 1.08
		energy_weapon = FALSE

	New(new_id, new_name, new_level, new_ore_type, new_cost, new_previous_id, new_damage, new_protection, new_heaviness, new_energy_weapon = FALSE)
		id = new_id
		name = new_name
		required_level = new_level
		ore_type = new_ore_type
		ore_cost = new_cost
		previous_material_id = new_previous_id
		weapon_damage = new_damage
		armor_protection = new_protection
		armor_heaviness = new_heaviness
		energy_weapon = new_energy_weapon

datum/ForgedWeaponStyle
	var
		id
		name
		icon_file
		damage_multiplier = 1
		energy_weapon = FALSE
		description

	New(new_id, new_name, new_icon, new_damage_multiplier, new_energy_weapon, new_description)
		id = new_id
		name = new_name
		icon_file = new_icon
		damage_multiplier = new_damage_multiplier
		energy_weapon = new_energy_weapon
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
		forged_material_catalog["copper"] = new /datum/ForgedMaterial("copper", "Copper", 1, /obj/items/Ore/Copper, 3, null, 1.2, 1.2, 1.08)
		forged_material_catalog["bronze"] = new /datum/ForgedMaterial("bronze", "Bronze", 4, /obj/items/Ore/Tin, 3, "copper", 1.28, 1.28, 1.12)
		forged_material_catalog["iron"] = new /datum/ForgedMaterial("iron", "Iron", 8, /obj/items/Ore/Iron, 4, "bronze", 1.38, 1.42, 1.22)
		forged_material_catalog["silver"] = new /datum/ForgedMaterial("silver", "Silver", 14, /obj/items/Ore/Silver, 4, "bronze", 1.42, 1.4, 1.1)
		forged_material_catalog["mythril"] = new /datum/ForgedMaterial("mythril", "Mythril", 20, /obj/items/Ore/Mythril, 5, "iron", 1.52, 1.48, 1.04)
		forged_material_catalog["auracite"] = new /datum/ForgedMaterial("auracite", "Auracite", 30, /obj/items/Ore/Auracite, 5, "silver", 1.64, 1.68, 1.12, TRUE)
		forged_material_catalog["masterwork"] = new /datum/ForgedMaterial("masterwork", "Masterwork", 35, /obj/items/Ore/HeartOfTheMountain, 1, "mythril", 1.68, 1.62, 1.08)
	if(!islist(forged_weapon_style_catalog) || !forged_weapon_style_catalog.len)
		forged_weapon_style_catalog = list()
		forged_weapon_style_catalog["trunks"] = new /datum/ForgedWeaponStyle("trunks", "Trunks Sword", 'RTSwordTrunks.dmi', 1, FALSE, "The balanced Tenkaichi sword profile.")
		forged_weapon_style_catalog["knight"] = new /datum/ForgedWeaponStyle("knight", "Knight Sword", 'RTIronSword.dmi', 1.02, FALSE, "A broad, reliable knight blade.")
		forged_weapon_style_catalog["demon"] = new /datum/ForgedWeaponStyle("demon", "Demon Sword", 'RTCopperSword.dmi', 1.04, FALSE, "An aggressive curved blade.")
		forged_weapon_style_catalog["katana"] = new /datum/ForgedWeaponStyle("katana", "Katana", 'RTKatana2.dmi', 1.03, FALSE, "A fast single-edged sword.")
		forged_weapon_style_catalog["long_katana"] = new /datum/ForgedWeaponStyle("long_katana", "Long Katana", 'RTKatana.dmi', 1.05, FALSE, "A longer blade that trades handling for reach.")
		forged_weapon_style_catalog["short_sword"] = new /datum/ForgedWeaponStyle("short_sword", "Short Sword", 'RTShortSword.dmi', 0.94, FALSE, "A compact and easy-to-handle weapon.")
		forged_weapon_style_catalog["rebellion"] = new /datum/ForgedWeaponStyle("rebellion", "Rebellion", 'ItemSword1.dmi', 1.06, FALSE, "A heavy ornamental blade.")
		forged_weapon_style_catalog["buster"] = new /datum/ForgedWeaponStyle("buster", "Buster Sword", 'ItemBusterSword.dmi', 1.09, FALSE, "A massive blade with exceptional impact.")
		forged_weapon_style_catalog["great_sword"] = new /datum/ForgedWeaponStyle("great_sword", "Great Sword", 'ItemGreatSword.dmi', 1.1, FALSE, "The heaviest Tenkaichi sword profile.")
		forged_weapon_style_catalog["flame"] = new /datum/ForgedWeaponStyle("flame", "Flame Sword", 'RTMythrilSword.dmi', 1.02, TRUE, "A blade shaped to conduct energy.")
		forged_weapon_style_catalog["samurai"] = new /datum/ForgedWeaponStyle("samurai", "Samurai Sword", 'RTAuraciteSword.dmi', 1.04, FALSE, "An ornate samurai blade.")
		forged_weapon_style_catalog["hammer"] = new /datum/ForgedWeaponStyle("hammer", "War Hammer", 'RTHammer.dmi', 1.08, FALSE, "A smith's hammer adapted for combat.")
		forged_weapon_style_catalog["sledgehammer"] = new /datum/ForgedWeaponStyle("sledgehammer", "Sledgehammer", 'RTSledgehammer.dmi', 1.1, FALSE, "A brutal two-handed striking weapon.")
		forged_weapon_style_catalog["mage_staff"] = new /datum/ForgedWeaponStyle("mage_staff", "Mage Staff", 'RTMageStaff.dmi', 0.96, TRUE, "A staff designed to channel energy through its core.")
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
		options["[style.name] - [style.description]"] = style
	var/choice = input(src, "Choose the weapon design. Its appearance will survive every material upgrade.", title) as null|anything in options
	if(isnull(choice)) return
	return options[choice]

mob/proc/chooseForgedArmorStyle(title = "Forge Armor")
	initializeForgedEquipmentCatalogs()
	var/list/options = list()
	for(var/style_id in forged_armor_style_catalog)
		var/datum/ForgedArmorStyle/style = forged_armor_style_catalog[style_id]
		options[style.name] = style
	var/choice = input(src, "Choose the armor design. Its appearance will survive every material upgrade.", title) as null|anything in options
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

mob/proc/craftForgedWeapon()
	syncProfessionProgression()
	var/datum/ForgedMaterial/material
	initializeForgedEquipmentCatalogs()
	material = forged_material_catalog["copper"]
	var/ore_cost = max(1, material.ore_cost - getMilestoneRank("master_blacksmith"))
	if(!consumeOre(material.ore_type, ore_cost))
		src << "You need [ore_cost] Copper ore to forge a weapon."
		return
	var/datum/ForgedWeaponStyle/style = chooseForgedWeaponStyle()
	if(!style)
		addMinedOre(material.ore_type, ore_cost)
		return
	var/obj/items/Sword/Forged/weapon = new(src)
	weapon.forged_material_id = material.id
	weapon.forged_style_id = style.id
	applyMasterBlacksmithQuality(weapon)
	weapon.refreshForgedWeapon()
	gainProfessionExperience("Smithing", 18, "forging [weapon]", announce = TRUE)
	player_view(15, src) << "<font color=#e0bd83>[src] forges [weapon]."
	return weapon

mob/proc/craftForgedArmor()
	syncProfessionProgression()
	initializeForgedEquipmentCatalogs()
	var/datum/ForgedMaterial/material = forged_material_catalog["copper"]
	var/ore_cost = max(1, 4 - getMilestoneRank("master_blacksmith"))
	if(!consumeOre(material.ore_type, ore_cost))
		src << "You need [ore_cost] Copper ore to forge armor."
		return
	var/datum/ForgedArmorStyle/style = chooseForgedArmorStyle()
	if(!style)
		addMinedOre(material.ore_type, ore_cost)
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
	if(istype(equipment, /obj/items/Sword/Forged))
		var/obj/items/Sword/Forged/weapon = equipment
		current_material_id = weapon.forged_material_id
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
		options["[material.name] - [ore_cost] [ore_example.ore_name] - Smithing [material.required_level]"] = material
		del(ore_example)
	if(!options.len)
		src << "Your Smithing level is too low for [equipment]'s next material upgrade."
		return
	var/choice = input(src, "Choose how to improve [equipment]. Bronze branches into Iron/Mythril/Masterwork or Silver/Auracite.", "Improve Equipment") as null|anything in options
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

mob/proc/openSmithingMenu(obj/Forge/forge)
	if(!forge || getdist(src, forge) > 1 || KO || rp_mode) return
	syncProfessionProgression()
	var/choice = input(src, "Smithing level [smithing_level]. What do you want to do?", "Tenkaichi Forge") in list("Cancel", "Forge Weapon", "Forge Armor", "Improve Equipment", "Forge Pickaxe", "View Material Paths")
	switch(choice)
		if("Forge Weapon") craftForgedWeapon()
		if("Forge Armor") craftForgedArmor()
		if("Improve Equipment") openForgeUpgradeMenu(forge)
		if("Forge Pickaxe")
			var/ore_cost = max(1, 3 - getMilestoneRank("master_blacksmith"))
			if(!consumeOre(/obj/items/Ore/Copper, ore_cost))
				src << "You need [ore_cost] Copper ore to forge a pickaxe."
				return
			var/obj/items/Digging/TenkaichiPickaxe/pickaxe = new(src)
			gainProfessionExperience("Smithing", 15, "forging [pickaxe]", announce = TRUE)
			player_view(15, src) << "<font color=#e0bd83>[src] forges [pickaxe]."
		if("View Material Paths")
			src << "<b>Tenkaichi material paths:</b> Copper + Tin -> Bronze; Bronze + Iron -> Iron; Iron + Mythril -> Mythril; Mythril + Heart of the Mountain -> Masterwork; Bronze + Silver -> Silver; Silver + Auracite -> Auracite."

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
		usr << "<b>Tenkaichi material paths:</b> Copper -> Bronze -> Iron -> Mythril -> Masterwork, or Copper -> Bronze -> Silver -> Auracite."

obj/items/Sword/Forged
	Cost = 0
	can_change_icon = 0
	Stealable = 1
	var/forged_material_id = "copper"
	var/forged_style_id = "trunks"
	var/master_blacksmith_quality = FALSE

	New()
		. = ..()
		refreshForgedWeapon()

	proc/refreshForgedWeapon()
		initializeForgedEquipmentCatalogs()
		var/datum/ForgedMaterial/material = forged_material_catalog[forged_material_id]
		var/datum/ForgedWeaponStyle/style = forged_weapon_style_catalog[forged_style_id]
		if(!material) material = forged_material_catalog["copper"]
		if(!style) style = forged_weapon_style_catalog["trunks"]
		forged_material_id = material.id
		forged_style_id = style.id
		name = "[material.name] [style.name]"
		icon = style.icon_file
		Damage = min(2, material.weapon_damage * style.damage_multiplier * (master_blacksmith_quality ? 1.05 : 1))
		Style = material.energy_weapon || style.energy_weapon ? "Energy" : "Physical"
		Sword_Desc()

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

	New()
		. = ..()
		refreshForgedArmor()

	proc/refreshForgedArmor()
		initializeForgedEquipmentCatalogs()
		var/datum/ForgedMaterial/material = forged_material_catalog[forged_material_id]
		var/datum/ForgedArmorStyle/style = forged_armor_style_catalog[forged_style_id]
		if(!material) material = forged_material_catalog["copper"]
		if(!style) style = forged_armor_style_catalog["classic"]
		forged_material_id = material.id
		forged_style_id = style.id
		name = "[material.name] [style.name]"
		icon = style.icon_file
		Armor = min(2, material.armor_protection * (master_blacksmith_quality ? 1.05 : 1))
		heaviness = material.armor_heaviness
		Armor_Desc()

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
