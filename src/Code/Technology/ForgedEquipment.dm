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
		ki_damage_multiplier = 1
		ki_bp_bonus = 0
		energy_weapon = FALSE
		description

	New(new_id, new_name, new_level, new_ore_type, new_cost, new_previous_id, new_damage, new_weapon_bp_bonus, new_protection, new_heaviness, new_armor_bp_bonus, new_energy_weapon = FALSE, new_description = "", new_ki_damage_multiplier = 1, new_ki_bp_bonus = 0)
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
		ki_damage_multiplier = new_ki_damage_multiplier
		ki_bp_bonus = new_ki_bp_bonus
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

datum/ForgedGloveStyle
	var
		id
		name
		equipment_name = "Gloves"
		icon_file
		icon_state

	New(new_id, new_name, new_equipment_name, new_icon, new_icon_state = "")
		id = new_id
		name = new_name
		equipment_name = new_equipment_name
		icon_file = new_icon
		icon_state = new_icon_state

datum/ForgedMaskStyle
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
var/list/forged_glove_style_catalog
var/list/forged_mask_style_catalog

proc/initializeForgedEquipmentCatalogs()
	if(!islist(forged_material_catalog) || !forged_material_catalog.len)
		forged_material_catalog = list()
		forged_material_catalog["normal"] = new /datum/ForgedMaterial("normal", "Normal", 1, /obj/items/Ore/Copper, 1, null, 1.1, 0.06, 1.1, 1.04, 0.04, FALSE, "Untreated forged equipment ready to receive its first material upgrade.", 1.05, 0.05)
		forged_material_catalog["copper"] = new /datum/ForgedMaterial("copper", "Copper", 1, /obj/items/Ore/Copper, 3, "normal", 1.2, 0.12, 1.2, 1.08, 0.08, FALSE, "Accessible and balanced, but comparatively soft.", 1.08, 0.12)
		forged_material_catalog["bronze"] = new /datum/ForgedMaterial("bronze", "Bronze", 4, /obj/items/Ore/Tin, 3, "copper", 1.28, 0.18, 1.28, 1.12, 0.12, FALSE, "A durable copper alloy with moderate weight.", 1.12, 0.18)
		forged_material_catalog["iron"] = new /datum/ForgedMaterial("iron", "Iron", 8, /obj/items/Ore/Iron, 4, "bronze", 1.38, 0.28, 1.42, 1.22, 0.22, FALSE, "Heavy and powerful; excellent direct impact at a mobility cost.", 1.18, 0.28)
		forged_material_catalog["silver"] = new /datum/ForgedMaterial("silver", "Silver", 14, /obj/items/Ore/Silver, 4, "bronze", 1.42, 0.22, 1.4, 1.1, 0.16, FALSE, "A refined anti-undead branch with good handling and critical potential.", 1.2, 0.22)
		forged_material_catalog["mythril"] = new /datum/ForgedMaterial("mythril", "Mythril", 20, /obj/items/Ore/Mythril, 5, "iron", 1.52, 0.32, 1.48, 1.04, 0.2, FALSE, "Exceptionally light for its strength; retains far more mobility than iron.", 1.24, 0.32)
		forged_material_catalog["auracite"] = new /datum/ForgedMaterial("auracite", "Auracite", 30, /obj/items/Ore/Auracite, 5, "silver", 1.64, 0.38, 1.68, 1.12, 0.28, TRUE, "Energy-reactive crystal metal with the strongest specialized protection.", 1.32, 0.38)
		forged_material_catalog["masterwork"] = new /datum/ForgedMaterial("masterwork", "Masterwork", 35, /obj/items/Ore/HeartOfTheMountain, 1, "mythril", 1.68, 0.42, 1.62, 1.08, 0.32, FALSE, "The peak physical alloy: enormous BP reinforcement without iron's weight.", 1.36, 0.42)
	if(!islist(forged_weapon_style_catalog) || !forged_weapon_style_catalog.len)
		forged_weapon_style_catalog = list()
		forged_weapon_style_catalog["trunks"] = new /datum/ForgedWeaponStyle("trunks", "Trunks", "Sword", 'RTSwordTrunks.dmi', "A compact Nexus sword skin.")
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
		forged_weapon_style_catalog["du_sword_2"] = new /datum/ForgedWeaponStyle("du_sword_2", "DU Sword II", "Sword", 'Sword2.dmi', "A legacy DU sword appearance.")
		forged_weapon_style_catalog["du_sword_1"] = new /datum/ForgedWeaponStyle("du_sword_1", "DU Sword I", "Sword", 'Sword1.dmi', "A legacy DU sword appearance.")
		forged_weapon_style_catalog["du_katana_2"] = new /datum/ForgedWeaponStyle("du_katana_2", "DU Katana II", "Katana", 'ItemKatana2.dmi', "A legacy DU katana appearance.")
		forged_weapon_style_catalog["du_katana"] = new /datum/ForgedWeaponStyle("du_katana", "DU Katana", "Katana", 'ItemKatana.dmi', "A legacy DU katana appearance.")
		forged_weapon_style_catalog["du_short_sword"] = new /datum/ForgedWeaponStyle("du_short_sword", "DU Short Sword", "Short Sword", 'ShortSword.dmi', "A legacy DU short-sword appearance.")
		forged_weapon_style_catalog["dual_blaze"] = new /datum/ForgedWeaponStyle("dual_blaze", "Dual Blaze", "Dual Blades", 'ItemDualBlazeSword.dmi', "A legacy DU dual-blade appearance.")
		forged_weapon_style_catalog["dual_electric"] = new /datum/ForgedWeaponStyle("dual_electric", "Dual Electric", "Dual Blades", 'ItemDualElectricSword.dmi', "A legacy DU dual-blade appearance.")
		forged_weapon_style_catalog["legacy_flame"] = new /datum/ForgedWeaponStyle("legacy_flame", "Legacy Flame", "Sword", 'SwordFlameComplete.dmi', "A legacy DU flame-sword appearance.")
		forged_weapon_style_catalog["twin_katanas"] = new /datum/ForgedWeaponStyle("twin_katanas", "Twin Katanas", "Dual Katanas", 'Sword2Katanas.dmi', "A legacy DU paired-katana appearance.")
		forged_weapon_style_catalog["legacy_samurai"] = new /datum/ForgedWeaponStyle("legacy_samurai", "Legacy Samurai", "Katana", 'SwordSamurai.dmi', "A legacy DU samurai appearance.")
		forged_weapon_style_catalog["legacy_trunks"] = new /datum/ForgedWeaponStyle("legacy_trunks", "Legacy Trunks", "Sword", 'SwordTrunks.dmi', "The original DU Trunks sword appearance.")
		forged_weapon_style_catalog["false_neoblade"] = new /datum/ForgedWeaponStyle("false_neoblade", "False Neoblade", "Sword", 'Falseneoblade.dmi', "A legacy DU sword appearance.")
		forged_weapon_style_catalog["kingdom_key"] = new /datum/ForgedWeaponStyle("kingdom_key", "Kingdom Key", "Keyblade", 'KingdomKey.dmi', "A legacy DU key-shaped appearance.")
		forged_weapon_style_catalog["ki_sword"] = new /datum/ForgedWeaponStyle("ki_sword", "Ki Sword", "Sword", 'KiSword.dmi', "A legacy DU energy-blade appearance; material still determines damage type.")
		forged_weapon_style_catalog["yin_yang"] = new /datum/ForgedWeaponStyle("yin_yang", "Yin Yang", "Sword", 'YinYang.dmi', "A legacy DU sword appearance.")
	if(!islist(forged_armor_style_catalog) || !forged_armor_style_catalog.len)
		forged_armor_style_catalog = list()
		forged_armor_style_catalog["classic"] = new /datum/ForgedArmorStyle("classic", "Classic Armor", 'RTCopperArmor.dmi')
		forged_armor_style_catalog["battle_2"] = new /datum/ForgedArmorStyle("battle_2", "Nexus Armor II", 'Armor2.dmi')
		forged_armor_style_catalog["battle_3"] = new /datum/ForgedArmorStyle("battle_3", "Nexus Armor III", 'Armor3.dmi')
		forged_armor_style_catalog["battle_4"] = new /datum/ForgedArmorStyle("battle_4", "Nexus Armor IV", 'Armor4.dmi')
		forged_armor_style_catalog["battle_5"] = new /datum/ForgedArmorStyle("battle_5", "Nexus Armor V", 'Armor5.dmi')
		forged_armor_style_catalog["battle_6"] = new /datum/ForgedArmorStyle("battle_6", "Nexus Armor VI", 'Armor6.dmi')
		forged_armor_style_catalog["battle_7"] = new /datum/ForgedArmorStyle("battle_7", "Nexus Armor VII", 'Armor7.dmi')
		forged_armor_style_catalog["bardock"] = new /datum/ForgedArmorStyle("bardock", "Bardock Armor", 'RTBardockArmor.dmi')
		forged_armor_style_catalog["turles"] = new /datum/ForgedArmorStyle("turles", "Turles Armor", 'TurlesArmor.dmi')
		forged_armor_style_catalog["nappa"] = new /datum/ForgedArmorStyle("nappa", "Nappa Armor", 'NappaArmor.dmi')
		forged_armor_style_catalog["azure"] = new /datum/ForgedArmorStyle("azure", "Azure Armor", 'RTIronArmor.dmi')
		forged_armor_style_catalog["mythril"] = new /datum/ForgedArmorStyle("mythril", "Mythril Armor", 'RTMythrilArmor.dmi')
		forged_armor_style_catalog["auracite"] = new /datum/ForgedArmorStyle("auracite", "Auracite Armor", 'RTAuraciteArmor.dmi')
		forged_armor_style_catalog["du_armor_1"] = new /datum/ForgedArmorStyle("du_armor_1", "DU Armor I", 'Armor1.dmi')
		forged_armor_style_catalog["white_male"] = new /datum/ForgedArmorStyle("white_male", "White Armor", 'WhiteMaleArmor.dmi')
		forged_armor_style_catalog["legacy_bardock"] = new /datum/ForgedArmorStyle("legacy_bardock", "Legacy Bardock Armor", 'ArmorBardock.dmi')
		forged_armor_style_catalog["dynasty_red"] = new /datum/ForgedArmorStyle("dynasty_red", "Red Dynasty Armor", 'GinsDynastyArmorRed.dmi')
		forged_armor_style_catalog["phoenix_makyo"] = new /datum/ForgedArmorStyle("phoenix_makyo", "Makyo Phoenix Armor", 'PhoenixFullMakyo.dmi')
		forged_armor_style_catalog["phoenix_moonlight"] = new /datum/ForgedArmorStyle("phoenix_moonlight", "Moonlight Phoenix Armor", 'PhoenixFullMoonlight.dmi')
		forged_armor_style_catalog["phoenix_negative_makyo"] = new /datum/ForgedArmorStyle("phoenix_negative_makyo", "Negative Makyo Phoenix Armor", 'PhoenixFullNegativeMakyo.dmi')
		forged_armor_style_catalog["phoenix_negative"] = new /datum/ForgedArmorStyle("phoenix_negative", "Negative Phoenix Armor", 'PhoenixFullNegative.dmi')
		forged_armor_style_catalog["phoenix"] = new /datum/ForgedArmorStyle("phoenix", "Phoenix Armor", 'PhoenixFull.dmi')
		forged_armor_style_catalog["wtf"] = new /datum/ForgedArmorStyle("wtf", "WTF Armor", 'WtfArmor.dmi')
		forged_armor_style_catalog["blue"] = new /datum/ForgedArmorStyle("blue", "Blue Armor", 'BlueArmor.dmi')
		forged_armor_style_catalog["red"] = new /datum/ForgedArmorStyle("red", "Red Armor", 'RedArmor.dmi')
		forged_armor_style_catalog["raditz_tobi"] = new /datum/ForgedArmorStyle("raditz_tobi", "Raditz Tobi Armor", 'RaditzArmorTobiUchiha.dmi')
		forged_armor_style_catalog["turles_tobi"] = new /datum/ForgedArmorStyle("turles_tobi", "Turles Tobi Armor", 'TurlesArmorTobiUchiha.dmi')
	if(!islist(forged_glove_style_catalog) || !forged_glove_style_catalog.len)
		forged_glove_style_catalog = list()
		forged_glove_style_catalog["classic"] = new /datum/ForgedGloveStyle("classic", "Classic", "Gloves", 'ClothesGloves.dmi')
		forged_glove_style_catalog["saiyan"] = new /datum/ForgedGloveStyle("saiyan", "Saiyan", "Gloves", 'ClothesSaiyanGloves.dmi')
		forged_glove_style_catalog["hero"] = new /datum/ForgedGloveStyle("hero", "Hero", "Gloves", 'OpmGloves.dmi')
		forged_glove_style_catalog["boxing"] = new /datum/ForgedGloveStyle("boxing", "Arcane Boxing", "Boxing Gloves", 'RTEnchantmentItems.dmi', "RoS")
	if(!islist(forged_mask_style_catalog) || !forged_mask_style_catalog.len)
		forged_mask_style_catalog = list()
		forged_mask_style_catalog["normal"] = new /datum/ForgedMaskStyle("normal", "Normal Mask", 'Mask.dmi')
		forged_mask_style_catalog["ninja"] = new /datum/ForgedMaskStyle("ninja", "Ninja Mask", 'ClothesNinjaMask.dmi')
		forged_mask_style_catalog["ninja_2"] = new /datum/ForgedMaskStyle("ninja_2", "Ninja Mask II", 'ClothesNinjaMask2.dmi')

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

mob/proc/chooseForgedGloveStyle(title = "Forge Gloves")
	initializeForgedEquipmentCatalogs()
	var/list/options = list()
	for(var/style_id in forged_glove_style_catalog)
		var/datum/ForgedGloveStyle/style = forged_glove_style_catalog[style_id]
		options["[style.name] skin"] = style
	var/choice = input(src, "Choose a cosmetic skin. Material alone determines the unarmed BP reinforcement.", title) as null|anything in options
	if(isnull(choice)) return
	return options[choice]

mob/proc/chooseForgedMaskStyle(title = "Forge Mask")
	initializeForgedEquipmentCatalogs()
	var/list/options = list()
	for(var/style_id in forged_mask_style_catalog)
		var/datum/ForgedMaskStyle/style = forged_mask_style_catalog[style_id]
		options["[style.name] skin"] = style
	var/choice = input(src, "Choose a cosmetic skin. Material determines both Ki damage and blast BP reinforcement.", title) as null|anything in options
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
	else if(istype(item, /obj/items/Gloves/Forged))
		var/obj/items/Gloves/Forged/gloves = item
		gloves.master_blacksmith_quality = TRUE
		gloves.refreshForgedGloves()
	else if(istype(item, /obj/items/Mask/Forged))
		var/obj/items/Mask/Forged/mask = item
		mask.master_blacksmith_quality = TRUE
		mask.refreshForgedMask()

mob/proc/craftForgedWeapon(style_id)
	syncProfessionProgression()
	syncProgressionTrees(silent = TRUE)
	if(!hasSmithingMaterialUnlock("copper"))
		src << "Unlock Forge Apprentice in the Smithing progression tree first."
		return
	var/datum/ForgedMaterial/material
	initializeForgedEquipmentCatalogs()
	material = forged_material_catalog["normal"]
	var/datum/ForgedWeaponStyle/style = forged_weapon_style_catalog[style_id]
	if(!style) style = chooseForgedWeaponStyle()
	if(!style) return
	var/ore_cost = max(1, material.ore_cost - getSmithingOreDiscount())
	if(!consumeOre(material.ore_type, ore_cost))
		src << "You need [ore_cost] Copper ore to forge a normal weapon frame."
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
	syncProgressionTrees(silent = TRUE)
	if(!hasSmithingMaterialUnlock("copper"))
		src << "Unlock Forge Apprentice in the Smithing progression tree first."
		return
	initializeForgedEquipmentCatalogs()
	var/datum/ForgedMaterial/material = forged_material_catalog["normal"]
	var/datum/ForgedArmorStyle/style = forged_armor_style_catalog[style_id]
	if(!style) style = chooseForgedArmorStyle()
	if(!style) return
	var/ore_cost = max(1, material.ore_cost + 1 - getSmithingOreDiscount())
	if(!consumeOre(material.ore_type, ore_cost))
		src << "You need [ore_cost] Copper ore to forge a normal armor frame."
		return
	var/obj/items/Armor/Forged/armor = new(src)
	armor.forged_material_id = material.id
	armor.forged_style_id = style.id
	applyMasterBlacksmithQuality(armor)
	armor.refreshForgedArmor()
	gainProfessionExperience("Smithing", 22, "forging [armor]", announce = TRUE)
	player_view(15, src) << "<font color=#e0bd83>[src] forges [armor]."
	return armor

mob/proc/craftForgedGloves(style_id)
	syncProfessionProgression()
	syncProgressionTrees(silent = TRUE)
	if(!hasSmithingMaterialUnlock("copper"))
		src << "Unlock Forge Apprentice in the Smithing progression tree first."
		return
	initializeForgedEquipmentCatalogs()
	var/datum/ForgedMaterial/material = forged_material_catalog["normal"]
	var/datum/ForgedGloveStyle/style = forged_glove_style_catalog[style_id]
	if(!style) style = chooseForgedGloveStyle()
	if(!style) return
	var/ore_cost = max(1, material.ore_cost - getSmithingOreDiscount())
	if(!consumeOre(material.ore_type, ore_cost))
		src << "You need [ore_cost] Copper ore to forge normal gloves."
		return
	var/obj/items/Gloves/Forged/gloves = new(src)
	gloves.forged_material_id = material.id
	gloves.forged_style_id = style.id
	applyMasterBlacksmithQuality(gloves)
	gloves.refreshForgedGloves()
	gainProfessionExperience("Smithing", 18, "forging [gloves]", announce = TRUE)
	player_view(15, src) << "<font color=#e0bd83>[src] forges [gloves]."
	return gloves

mob/proc/craftForgedMask(style_id)
	syncProfessionProgression()
	syncProgressionTrees(silent = TRUE)
	if(!hasSmithingMaterialUnlock("copper"))
		src << "Unlock Forge Apprentice in the Smithing progression tree first."
		return
	initializeForgedEquipmentCatalogs()
	var/datum/ForgedMaterial/material = forged_material_catalog["normal"]
	var/datum/ForgedMaskStyle/style = forged_mask_style_catalog[style_id]
	if(!style) style = chooseForgedMaskStyle()
	if(!style) return
	var/ore_cost = max(1, material.ore_cost - getSmithingOreDiscount())
	if(!consumeOre(material.ore_type, ore_cost))
		src << "You need [ore_cost] Copper ore to forge a normal mask frame."
		return
	var/obj/items/Mask/Forged/mask = new(src)
	mask.forged_material_id = material.id
	mask.forged_style_id = style.id
	applyMasterBlacksmithQuality(mask)
	mask.refreshForgedMask()
	gainProfessionExperience("Smithing", 18, "forging [mask]", announce = TRUE)
	player_view(15, src) << "<font color=#e0bd83>[src] forges [mask]."
	return mask

mob/proc/upgradeForgedEquipment(obj/items/equipment)
	if(!equipment || !equipment.canUseAfterNexusTradeYield(src)) return
	if(equipment.suffix)
		src << "Remove [equipment] before improving it."
		return
	var/current_material_id
	var/is_weapon = FALSE
	var/is_gloves = FALSE
	var/is_mask = FALSE
	if(istype(equipment, /obj/items/Sword/Forged))
		var/obj/items/Sword/Forged/weapon = equipment
		current_material_id = weapon.forged_material_id
		is_weapon = TRUE
	else if(istype(equipment, /obj/items/Armor/Forged))
		var/obj/items/Armor/Forged/armor = equipment
		current_material_id = armor.forged_material_id
	else if(istype(equipment, /obj/items/Gloves/Forged))
		var/obj/items/Gloves/Forged/gloves = equipment
		current_material_id = gloves.forged_material_id
		is_gloves = TRUE
	else if(istype(equipment, /obj/items/Mask/Forged))
		var/obj/items/Mask/Forged/mask = equipment
		current_material_id = mask.forged_material_id
		is_mask = TRUE
	else
		src << "Only equipment made by the Nexus forge can use this upgrade chain."
		return
	var/list/upgrades = getForgedMaterialUpgradeOptions(current_material_id)
	if(!upgrades.len)
		src << "[equipment] has reached the end of its material path."
		return
	var/list/options = list()
	for(var/datum/ForgedMaterial/material in upgrades)
		if(smithing_level < material.required_level) continue
		if(!hasSmithingMaterialUnlock(material.id)) continue
		var/ore_cost = max(1, material.ore_cost - getSmithingOreDiscount())
		var/obj/items/Ore/ore_example = new material.ore_type
		var/stat_summary
		if(is_weapon)
			stat_summary = "+[round(material.weapon_bp_bonus * 100)]% attack BP / [round(material.weapon_damage, 0.01)]x sharpness"
		else if(is_gloves)
			stat_summary = "+[round(material.weapon_bp_bonus * 100)]% unarmed attack BP"
		else if(is_mask)
			stat_summary = "+[round(material.ki_bp_bonus * 100)]% blast BP / [round((material.ki_damage_multiplier - 1) * 100)]% Ki damage"
		else
			stat_summary = "+[round(material.armor_bp_bonus * 100)]% endurance BP / [round(material.armor_protection, 0.01)]x protection / [round(material.armor_heaviness, 0.01)]x weight"
		options["[material.name] - [stat_summary] - [ore_cost] [ore_example.ore_name] - Smithing [material.required_level]"] = material
		del(ore_example)
	if(!options.len)
		src << "Your Smithing level is too low for [equipment]'s next material upgrade."
		return
	var/choice = input(src, "Choose [equipment]'s new material module. The cosmetic skin will not change. Bronze branches into Iron/Mythril/Masterwork or Silver/Auracite.", "Improve Equipment") as null|anything in options
	if(isnull(choice) || !(choice in options) || !equipment.canUseAfterNexusTradeYield(src)) return
	var/datum/ForgedMaterial/new_material = options[choice]
	if(!new_material || !(new_material in upgrades)) return
	var/final_cost = max(1, new_material.ore_cost - getSmithingOreDiscount())
	if(!consumeOre(new_material.ore_type, final_cost))
		var/obj/items/Ore/ore_example = new new_material.ore_type
		src << "You need [final_cost] [ore_example.ore_name] to improve [equipment]."
		del(ore_example)
		return
	if(istype(equipment, /obj/items/Sword/Forged))
		var/obj/items/Sword/Forged/weapon = equipment
		weapon.forged_material_id = new_material.id
		weapon.refreshForgedWeapon()
	else if(istype(equipment, /obj/items/Armor/Forged))
		var/obj/items/Armor/Forged/armor = equipment
		armor.forged_material_id = new_material.id
		armor.refreshForgedArmor()
	else if(istype(equipment, /obj/items/Gloves/Forged))
		var/obj/items/Gloves/Forged/gloves = equipment
		gloves.forged_material_id = new_material.id
		gloves.refreshForgedGloves()
	else
		var/obj/items/Mask/Forged/mask = equipment
		mask.forged_material_id = new_material.id
		mask.refreshForgedMask()
	gainProfessionExperience("Smithing", 20 + new_material.required_level * 2, "improving [equipment] to [new_material.name]", announce = TRUE)
	player_view(15, src) << "<font color=#e0bd83>[src] improves [equipment] with [new_material.name]."

mob/proc/openForgeUpgradeMenu(obj/Forge/forge)
	if(!forge || getdist(src, forge) > 1) return
	var/list/options = list()
	for(var/obj/items/Sword/Forged/weapon in item_list) options += weapon
	for(var/obj/items/Armor/Forged/armor in item_list) options += armor
	for(var/obj/items/Gloves/Forged/gloves in item_list) options += gloves
	for(var/obj/items/Mask/Forged/mask in item_list) options += mask
	if(!options.len)
		src << "You are not carrying Nexus-forged equipment."
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
	var/html = "<table class='guide'><tr><th>Material / path</th><th>Weapon / gloves</th><th>Mask</th><th>Armor</th><th>Identity</th></tr>"
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
		html += "<tr><td><b>[material.name]</b><br>Smithing [material.required_level]<br><small>[path_text]</small></td><td>+[round(material.weapon_bp_bonus * 100)]% attack BP<br>[round(material.weapon_damage, 0.01)]x weapon sharpness<br>[damage_type] weapon</td><td>+[round(material.ki_bp_bonus * 100)]% blast BP<br>+[round((material.ki_damage_multiplier - 1) * 100)]% Ki damage</td><td>+[round(material.armor_bp_bonus * 100)]% endurance BP<br>[round(material.armor_protection, 0.01)]x protection<br>[weight_text] ([round(material.armor_heaviness, 0.01)]x)</td><td>[html_encode(material.description)]</td></tr>"
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
			styles_html += "<a class='style' href='byond://?src=\ref[forge]&forge_action=craft_weapon&style=[style.id]'><span class='tag'>COSMETIC SKIN</span><img src='[resource_name]'><b>[html_encode(style.name)]</b><small>Creates: Normal [html_encode(style.equipment_name)]</small><small>[html_encode(style.description)]</small></a>"
	else if(equipment_kind == "armor")
		for(var/style_id in forged_armor_style_catalog)
			var/datum/ForgedArmorStyle/style = forged_armor_style_catalog[style_id]
			var/resource_name = "nexus_forge_armor_[style.id].png"
			src << browse_rsc(icon(style.icon_file), resource_name)
			styles_html += "<a class='style' href='byond://?src=\ref[forge]&forge_action=craft_armor&style=[style.id]'><span class='tag'>COSMETIC SKIN</span><img src='[resource_name]'><b>[html_encode(style.name)]</b><small>Creates: Normal Armor</small><small>Protection and weight come exclusively from the material.</small></a>"
	else if(equipment_kind == "gloves")
		for(var/style_id in forged_glove_style_catalog)
			var/datum/ForgedGloveStyle/style = forged_glove_style_catalog[style_id]
			var/resource_name = "nexus_forge_gloves_[style.id].png"
			src << browse_rsc(icon(style.icon_file, style.icon_state), resource_name)
			styles_html += "<a class='style' href='byond://?src=\ref[forge]&forge_action=craft_gloves&style=[style.id]'><span class='tag'>COSMETIC SKIN</span><img src='[resource_name]'><b>[html_encode(style.name)]</b><small>Creates: Normal [html_encode(style.equipment_name)]</small><small>Provides unarmed BP reinforcement from its material.</small></a>"
	else
		for(var/style_id in forged_mask_style_catalog)
			var/datum/ForgedMaskStyle/style = forged_mask_style_catalog[style_id]
			var/resource_name = "nexus_forge_mask_[style.id].png"
			src << browse_rsc(icon(style.icon_file), resource_name)
			styles_html += "<a class='style' href='byond://?src=\ref[forge]&forge_action=craft_mask&style=[style.id]'><span class='tag'>COSMETIC SKIN</span><img src='[resource_name]'><b>[html_encode(style.name)]</b><small>Creates: Normal Mask</small><small>Material determines Ki damage and blast BP reinforcement.</small></a>"
	var/title = "Glove Appearance"
	if(equipment_kind == "weapon") title = "Weapon Appearance"
	else if(equipment_kind == "armor") title = "Armor Appearance"
	else if(equipment_kind == "mask") title = "Mask Appearance"
	var/html = "<html><head>[getForgeBrowserCss()]</head><body><div class='shell'><div class='header'><h1>[title]</h1><p>Choose the sprite only. Named designs such as Rebellion are not unique weapons and grant no hidden statistics.</p><div class='nav'><a class='button' href='byond://?src=\ref[forge]&forge_action=menu'>BACK TO FORGE</a><a class='button' href='byond://?src=\ref[forge]&forge_action=guide'>MATERIAL GUIDE</a></div></div><div class='styles'>[styles_html]</div></div></body></html>"
	src << browse(html, "window=nexus_forge;size=1050x760;can_resize=true")

mob/proc/openForgeMaterialGuide(obj/Forge/forge)
	if(!forge || getdist(src, forge) > 1) return
	var/html = "<html><head>[getForgeBrowserCss()]</head><body><div class='shell'><div class='header'><h1>Forging Material Guide</h1><p>Material controls every combat statistic. The selected icon remains cosmetic through all upgrades.</p><div class='nav'><a class='button' href='byond://?src=\ref[forge]&forge_action=menu'>BACK TO FORGE</a></div></div><div class='panel'><h2>Material branches and effects</h2>[buildForgeMaterialGuideHtml()]<div class='hint'>Every item begins at Normal. Direct path: Normal - Copper - Bronze - Iron - Mythril - Masterwork. Specialized path: Normal - Copper - Bronze - Silver - Auracite. Mythril is the lightest advanced armor; Auracite converts forged weapons to Energy damage.</div></div></div></body></html>"
	src << browse(html, "window=nexus_forge;size=1050x760;can_resize=true")

mob/proc/openSmithingMenu(obj/Forge/forge)
	if(!forge || getdist(src, forge) > 1 || KO || rp_mode) return
	syncProfessionProgression()
	syncProgressionTrees(silent = TRUE)
	if(!hasSmithingMaterialUnlock("copper"))
		src << "Unlock Forge Apprentice in the Smithing progression tree first."
		showProgressionTrees("Smithing")
		return
	initializeForgedEquipmentCatalogs()
	var/datum/ForgedMaterial/base_material = forged_material_catalog["normal"]
	var/weapon_cost = max(1, base_material.ore_cost - getSmithingOreDiscount())
	var/armor_cost = max(1, base_material.ore_cost + 1 - getSmithingOreDiscount())
	var/html = "<html><head>[getForgeBrowserCss()]</head><body><div class='shell'><div class='header'><h1>Nexus Forge</h1><p>Smithing level [smithing_level]. Equipment begins at Normal; Copper is its first material upgrade. The selected design is visual only.</p></div><div class='actions'><a class='action' href='byond://?src=\ref[forge]&forge_action=weapon'><b>FORGE WEAPON</b><span>[weapon_cost] Copper ore for a Normal frame. Opens the visual skin gallery.</span></a><a class='action' href='byond://?src=\ref[forge]&forge_action=armor'><b>FORGE ARMOR</b><span>[armor_cost] Copper ore for a Normal frame. Opens the visual skin gallery.</span></a><a class='action' href='byond://?src=\ref[forge]&forge_action=gloves'><b>FORGE GLOVES</b><span>[weapon_cost] Copper ore for Normal gloves. Reinforces unarmed attacks.</span></a><a class='action' href='byond://?src=\ref[forge]&forge_action=mask'><b>FORGE MASK</b><span>[weapon_cost] Copper ore for a Normal mask. Reinforces Ki damage and blast BP.</span></a><a class='action' href='byond://?src=\ref[forge]&forge_action=upgrade'><b>IMPROVE EQUIPMENT</b><span>Upgrade Normal to Copper and beyond while preserving the icon.</span></a><a class='action' href='byond://?src=\ref[forge]&forge_action=pickaxe'><b>FORGE PICKAXE</b><span>3 Copper ore.</span></a><a class='action' href='byond://?src=\ref[forge]&forge_action=guide'><b>MATERIAL GUIDE</b><span>Compare BP reinforcement, Ki damage, protection and weight.</span></a><a class='action' href='byond://?src=\ref[forge]&forge_action=close'><b>CLOSE</b><span>Return to the game.</span></a></div><div class='panel'><h2>Quick material comparison</h2>[buildForgeMaterialGuideHtml()]</div></div></body></html>"
	src << browse(html, "window=nexus_forge;size=1050x760;can_resize=true")

mob/proc/craftNexusPickaxe()
	if(!hasSmithingMaterialUnlock("copper"))
		src << "Unlock Forge Apprentice in the Smithing progression tree first."
		return FALSE
	var/ore_cost = max(1, 3 - getSmithingOreDiscount())
	if(!consumeOre(/obj/items/Ore/Copper, ore_cost))
		src << "You need [ore_cost] Copper ore to forge a pickaxe."
		return FALSE
	var/obj/items/Digging/NexusPickaxe/pickaxe = new(src)
	gainProfessionExperience("Smithing", 15, "forging [pickaxe]", announce = TRUE)
	player_view(15, src) << "<font color=#e0bd83>[src] forges [pickaxe]."
	return TRUE

obj/Forge
	name = "Nexus Forge"
	desc = "A Nexus forge used to create and improve persistent weapon, glove, mask and armor designs."
	icon = 'RTForge.dmi'
	density = 1
	Health = 100000
	Cost = 250000
	Savable = 1
	takes_gradual_damage = 1
	science = 1
	science_level = 3

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
			if("gloves") usr.openForgeStyleBrowser(src, "gloves")
			if("mask") usr.openForgeStyleBrowser(src, "mask")
			if("guide") usr.openForgeMaterialGuide(src)
			if("upgrade")
				usr.openForgeUpgradeMenu(src)
				usr.openSmithingMenu(src)
			if("pickaxe")
				usr.craftNexusPickaxe()
				usr.openSmithingMenu(src)
			if("craft_weapon")
				usr.craftForgedWeapon(href_list["style"])
				usr.openSmithingMenu(src)
			if("craft_armor")
				usr.craftForgedArmor(href_list["style"])
				usr.openSmithingMenu(src)
			if("craft_gloves")
				usr.craftForgedGloves(href_list["style"])
				usr.openSmithingMenu(src)
			if("craft_mask")
				usr.craftForgedMask(href_list["style"])
				usr.openSmithingMenu(src)
			if("close") usr << browse(null, "window=nexus_forge")

obj/items/Sword/Forged
	Cost = 0
	can_change_icon = 1
	Stealable = 1
	var/forged_material_id = "normal"
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
		if(!material) material = forged_material_catalog["normal"]
		if(!style) style = forged_weapon_style_catalog["trunks"]
		forged_material_id = material.id
		forged_style_id = style.id
		var/quality_prefix = master_blacksmith_quality ? "Masterwork " : ""
		name = "[quality_prefix][material.name] [style.equipment_name]"
		icon = style.icon_file
		Damage = min(2, material.weapon_damage * (master_blacksmith_quality ? 1.05 : 1))
		forged_attack_bp_bonus = min(0.5, material.weapon_bp_bonus + (master_blacksmith_quality ? 0.03 : 0))
		Style = material.energy_weapon ? "Energy" : "Physical"
		is_silver = material.id == "silver"
		Sword_Desc()
		if(master_blacksmith_quality) desc += "<br>Quality: Masterwork enchantment (+5% weapon damage and +3% BP reinforcement)."
		desc += "<br>Material: [material.name]<br>Appearance: [style.name] skin (cosmetic)<br>Attack BP reinforcement: +[round(forged_attack_bp_bonus * 100)]%<br>Damage type: [Style]<br>[material.description]"

	proc/customizeForgedWeapon(mob/user)
		if(!canUseAfterNexusTradeYield(user)) return
		if(suffix)
			user << "You can not customize a weapon that is being worn."
			return
		var/datum/ForgedWeaponStyle/style = user.chooseForgedWeaponStyle("Customize Weapon")
		if(!style || !canUseAfterNexusTradeYield(user)) return
		forged_style_id = style.id
		refreshForgedWeapon()

	verb/Improve_At_Forge()
		set name = "Improve at Forge"
		set src in usr
		var/obj/Forge/nearby_forge
		for(var/obj/Forge/forge in oview(1, usr))
			nearby_forge = forge
			break
		if(!nearby_forge)
			usr << "Stand beside a Nexus Forge to improve this weapon."
			return
		usr.upgradeForgedEquipment(src)

	Science
		Cost = 50000
		science = 1
		science_level = 1
		forged_material_id = "normal"
		forged_style_id = "trunks"

	ScienceHammer
		Cost = 50000
		science = 1
		science_level = 1
		forged_material_id = "normal"
		forged_style_id = "hammer"

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
	can_change_icon = 1
	Stealable = 1
	armor_ver = 2
	var/forged_material_id = "normal"
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
		if(!material) material = forged_material_catalog["normal"]
		if(!style) style = forged_armor_style_catalog["classic"]
		forged_material_id = material.id
		forged_style_id = style.id
		var/quality_prefix = master_blacksmith_quality ? "Masterwork " : ""
		name = "[quality_prefix][material.name] Armor"
		icon = style.icon_file
		Armor = min(2, material.armor_protection * (master_blacksmith_quality ? 1.05 : 1))
		heaviness = material.armor_heaviness
		forged_defense_bp_bonus = min(0.4, material.armor_bp_bonus + (master_blacksmith_quality ? 0.03 : 0))
		Armor_Desc()
		if(master_blacksmith_quality) desc += "<br>Quality: Masterwork enchantment (+5% protection and +3% BP reinforcement)."
		desc += "<br>Material: [material.name]<br>Appearance: [style.name] skin (cosmetic)<br>Endurance BP reinforcement: +[round(forged_defense_bp_bonus * 100)]%<br>Weight: [round(heaviness, 0.01)]x<br>[material.description]"

	proc/customizeForgedArmor(mob/user)
		if(!canUseAfterNexusTradeYield(user)) return
		if(suffix)
			user << "You can not customize armor that is being worn."
			return
		var/datum/ForgedArmorStyle/style = user.chooseForgedArmorStyle("Customize Armor")
		if(!style || !canUseAfterNexusTradeYield(user)) return
		forged_style_id = style.id
		refreshForgedArmor()

	verb/Improve_At_Forge()
		set name = "Improve at Forge"
		set src in usr
		var/obj/Forge/nearby_forge
		for(var/obj/Forge/forge in oview(1, usr))
			nearby_forge = forge
			break
		if(!nearby_forge)
			usr << "Stand beside a Nexus Forge to improve this armor."
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

mob/var/tmp/obj/items/Gloves/Forged/equipped_gloves

mob/proc/applyForgedGloves(obj/items/Gloves/Forged/gloves)
	if(!gloves || gloves.loc != src) return
	for(var/obj/items/Gloves/Forged/other_gloves in item_list)
		if(other_gloves != gloves && other_gloves.suffix) Clothes_Equip(other_gloves)
	Clothes_Equip(gloves)
	if(gloves.suffix) equipped_gloves = gloves
	else if(equipped_gloves == gloves) equipped_gloves = null

mob/proc/usingForgedGloves()
	if(istype(equipped_gloves) && equipped_gloves.loc == src && equipped_gloves.suffix && equipped_gloves.Health > 0) return equipped_gloves
	equipped_gloves = null
	for(var/obj/items/Gloves/Forged/gloves in item_list)
		if(gloves.suffix && gloves.Health > 0)
			equipped_gloves = gloves
			return gloves

obj/items/Gloves/Forged
	Cost = 0
	Health = 10000000
	Stealable = 1
	clonable = 1
	can_change_icon = 1
	can_hotbar = 1
	hotbar_type = "Combat item"
	appearance_managed = TRUE
	var/forged_material_id = "normal"
	var/forged_style_id = "classic"
	var/master_blacksmith_quality = FALSE
	var/forged_attack_bp_bonus = 0.12

	New()
		. = ..()
		refreshForgedGloves()
		spawn(1) if(src)
			refreshForgedGloves()
			if(suffix && ismob(loc))
				var/mob/wearer = loc
				wearer.equipped_gloves = src

	Del()
		var/mob/wearer = loc
		if(ismob(wearer) && wearer.equipped_gloves == src)
			wearer.equipped_gloves = null
			suffix = null
		. = ..()
		if(ismob(wearer)) wearer.rebuildPlayerAppearance("forged gloves deleted")

	proc/refreshForgedGloves()
		initializeForgedEquipmentCatalogs()
		var/datum/ForgedMaterial/material = forged_material_catalog[forged_material_id]
		var/datum/ForgedGloveStyle/style = forged_glove_style_catalog[forged_style_id]
		if(!material) material = forged_material_catalog["normal"]
		if(!style) style = forged_glove_style_catalog["classic"]
		forged_material_id = material.id
		forged_style_id = style.id
		var/quality_prefix = master_blacksmith_quality ? "Masterwork " : ""
		name = "[quality_prefix][material.name] [style.equipment_name]"
		icon = style.icon_file
		icon_state = style.icon_state
		forged_attack_bp_bonus = min(0.5, material.weapon_bp_bonus + (master_blacksmith_quality ? 0.03 : 0))
		desc = "Forged gloves that reinforce unarmed attacks without counting as a sword.<br>Material: [material.name]<br>Appearance: [style.name] skin (cosmetic)<br>Unarmed attack BP reinforcement: +[round(forged_attack_bp_bonus * 100)]%<br>[material.description]"
		if(master_blacksmith_quality) desc += "<br>Quality: Masterwork enchantment (+3% BP reinforcement)."
		if(suffix && ismob(loc))
			var/mob/wearer = loc
			wearer.rebuildPlayerAppearance("forged gloves refreshed")

	verb/Hotbar_use()
		set hidden = 1
		Click()

	Click()
		if(src in usr)
			if(usr.Redoing_Stats)
				usr << "You can not use this while choosing stat mods."
				return
			usr.applyForgedGloves(src)

	verb/Customize()
		set src in usr
		var/mob/user = usr
		if(!canUseAfterNexusTradeYield(user)) return
		if(suffix)
			user << "You can not customize gloves that are being worn."
			return
		var/datum/ForgedGloveStyle/style = user.chooseForgedGloveStyle("Customize Gloves")
		if(!style || !canUseAfterNexusTradeYield(user)) return
		forged_style_id = style.id
		refreshForgedGloves()

	verb/Improve_At_Forge()
		set name = "Improve at Forge"
		set src in usr
		var/obj/Forge/nearby_forge
		for(var/obj/Forge/forge in oview(1, usr))
			nearby_forge = forge
			break
		if(!nearby_forge)
			usr << "Stand beside a Nexus Forge to improve these gloves."
			return
		usr.upgradeForgedEquipment(src)

	Science
		Cost = 50000
		science = 1
		science_level = 1
		forged_material_id = "normal"
		forged_style_id = "classic"

	Copper
		forged_material_id = "copper"
		forged_style_id = "classic"

	Iron
		forged_material_id = "iron"
		forged_style_id = "saiyan"

	Mythril
		forged_material_id = "mythril"
		forged_style_id = "hero"

	Auracite
		forged_material_id = "auracite"
		forged_style_id = "boxing"

mob/var/tmp/obj/items/Mask/Forged/equipped_forged_mask

mob/proc/applyForgedMask(obj/items/Mask/Forged/mask)
	if(!mask || mask.loc != src) return
	for(var/obj/items/Mask/Forged/other_mask in item_list)
		if(other_mask != mask && other_mask.suffix) Clothes_Equip(other_mask)
	Clothes_Equip(mask)
	if(mask.suffix) equipped_forged_mask = mask
	else if(equipped_forged_mask == mask) equipped_forged_mask = null

mob/proc/usingForgedMask()
	if(istype(equipped_forged_mask) && equipped_forged_mask.loc == src && equipped_forged_mask.suffix && equipped_forged_mask.Health > 0) return equipped_forged_mask
	equipped_forged_mask = null
	for(var/obj/items/Mask/Forged/mask in item_list)
		if(mask.suffix && mask.Health > 0)
			equipped_forged_mask = mask
			return mask

obj/items/Mask/Forged
	Cost = 0
	Health = 10000000
	Stealable = 1
	clonable = 1
	can_change_icon = 1
	can_hotbar = 1
	hotbar_type = "Combat item"
	appearance_managed = TRUE
	var/forged_material_id = "normal"
	var/forged_style_id = "normal"
	var/master_blacksmith_quality = FALSE
	var/forged_ki_damage_multiplier = 1.05
	var/forged_ki_bp_bonus = 0.05

	New()
		. = ..()
		refreshForgedMask()
		spawn(1) if(src)
			refreshForgedMask()
			if(suffix && ismob(loc))
				var/mob/wearer = loc
				wearer.equipped_forged_mask = src

	Del()
		var/mob/wearer = loc
		if(ismob(wearer) && wearer.equipped_forged_mask == src)
			wearer.equipped_forged_mask = null
			suffix = null
		. = ..()
		if(ismob(wearer)) wearer.rebuildPlayerAppearance("forged mask deleted")

	proc/refreshForgedMask()
		initializeForgedEquipmentCatalogs()
		var/datum/ForgedMaterial/material = forged_material_catalog[forged_material_id]
		var/datum/ForgedMaskStyle/style = forged_mask_style_catalog[forged_style_id]
		if(!material) material = forged_material_catalog["normal"]
		if(!style) style = forged_mask_style_catalog["normal"]
		forged_material_id = material.id
		forged_style_id = style.id
		var/quality_prefix = master_blacksmith_quality ? "Masterwork " : ""
		name = "[quality_prefix][material.name] Mask"
		icon = style.icon_file
		forged_ki_damage_multiplier = min(1.5, material.ki_damage_multiplier + (master_blacksmith_quality ? 0.03 : 0))
		forged_ki_bp_bonus = min(0.5, material.ki_bp_bonus + (master_blacksmith_quality ? 0.03 : 0))
		desc = "A forged mask that reinforces Ki attacks and the BP stored by blasts.<br>Material: [material.name]<br>Appearance: [style.name] skin (cosmetic)<br>Ki damage: +[round((forged_ki_damage_multiplier - 1) * 100)]%<br>Blast BP reinforcement: +[round(forged_ki_bp_bonus * 100)]%<br>[material.description]"
		if(master_blacksmith_quality) desc += "<br>Quality: Masterwork enchantment (+3% Ki damage and +3% BP reinforcement)."
		if(suffix && ismob(loc))
			var/mob/wearer = loc
			wearer.rebuildPlayerAppearance("forged mask refreshed")

	verb/Hotbar_use()
		set hidden = 1
		Click()

	Click()
		if(src in usr)
			if(usr.Redoing_Stats)
				usr << "You can not use this while choosing stat mods."
				return
			usr.applyForgedMask(src)

	verb/Customize()
		set src in usr
		var/mob/user = usr
		if(!canUseAfterNexusTradeYield(user)) return
		if(suffix)
			user << "You can not customize a mask that is being worn."
			return
		var/datum/ForgedMaskStyle/style = user.chooseForgedMaskStyle("Customize Mask")
		if(!style || !canUseAfterNexusTradeYield(user)) return
		forged_style_id = style.id
		refreshForgedMask()

	verb/Improve_At_Forge()
		set name = "Improve at Forge"
		set src in usr
		var/obj/Forge/nearby_forge
		for(var/obj/Forge/forge in oview(1, usr))
			nearby_forge = forge
			break
		if(!nearby_forge)
			usr << "Stand beside a Nexus Forge to improve this mask."
			return
		usr.upgradeForgedEquipment(src)

	Science
		Cost = 50000
		science = 1
		science_level = 1
		forged_material_id = "normal"
		forged_style_id = "normal"

	Copper
		forged_material_id = "copper"
		forged_style_id = "normal"

	Iron
		forged_material_id = "iron"
		forged_style_id = "ninja"

	Mythril
		forged_material_id = "mythril"
		forged_style_id = "ninja_2"

	Auracite
		forged_material_id = "auracite"
		forged_style_id = "normal"

mob/proc/getForgedWeaponAttackBP()
	var/effective_bp = BP
	var/obj/items/Sword/Forged/weapon = using_sword()
	if(istype(weapon) && weapon.Health > 0)
		effective_bp *= 1 + max(0, weapon.forged_attack_bp_bonus)
	return effective_bp

mob/proc/getForgedUnarmedAttackBP()
	var/effective_bp = BP
	var/obj/items/Gloves/Forged/gloves = usingForgedGloves()
	if(gloves) effective_bp *= 1 + max(0, gloves.forged_attack_bp_bonus)
	return effective_bp

mob/proc/getForgedKiAttackBP()
	var/effective_bp = BP
	var/obj/items/Mask/Forged/mask = usingForgedMask()
	if(mask) effective_bp *= 1 + max(0, mask.forged_ki_bp_bonus)
	return effective_bp

mob/proc/getForgedKiDamageMultiplier()
	var/obj/items/Mask/Forged/mask = usingForgedMask()
	if(mask) return max(1, mask.forged_ki_damage_multiplier)
	return 1

mob/proc/getForgedArmorEnduranceBP()
	var/effective_bp = BP
	if(istype(armor_obj, /obj/items/Armor/Forged) && armor_obj.suffix && armor_obj.Health > 0)
		var/obj/items/Armor/Forged/armor = armor_obj
		effective_bp *= 1 + max(0, armor.forged_defense_bp_bonus)
	return effective_bp

obj/items/Digging/NexusPickaxe
	name = "Nexus Pickaxe"
	desc = "The Nexus mining pickaxe. Equip it to improve excavation yield."
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

mob/Admin3/verb/testNexusSmithing(mob/character in players)
	set name = "Test Nexus Smithing"
	set category = "Admin"
	if(AdminLevel() < 3 || !character) return
	character.mining_experience = getProfessionExperienceForLevel(50)
	character.smithing_experience = getProfessionExperienceForLevel(50)
	character.syncProfessionProgression()
	character.syncProgressionTrees(silent = TRUE)
	for(var/node_id in progression_node_catalog)
		var/datum/ProgressionNode/node = progression_node_catalog[node_id]
		if(node.category in list("Mining", "Smithing")) character.progression_nodes_owned[node.id] = node.max_rank
	for(var/ore_type in list(/obj/items/Ore/Copper, /obj/items/Ore/Tin, /obj/items/Ore/Iron, /obj/items/Ore/Silver, /obj/items/Ore/Mythril, /obj/items/Ore/Auracite, /obj/items/Ore/HeartOfTheMountain))
		character.addMinedOre(ore_type, 40)
	var/turf/forge_location = get_step(character, SOUTH)
	if(!forge_location) forge_location = character.loc
	new /obj/Forge(forge_location)
	admin_blame(src, "[key] prepared [character] to test the Nexus smithing progression.")
	src << "[character] received level 50 Mining/Smithing, every material, and a forge."

mob/Admin3/verb/giveNexusEquipment(mob/character in players)
	set name = "Give Nexus Equipment"
	set category = "Admin"
	if(AdminLevel() < 3 || !character) return
	initializeForgedEquipmentCatalogs()
	var/equipment_kind = input(src, "Choose the equipment family to test.", "Nexus Equipment") in list("Cancel", "Weapon", "Armor", "Gloves", "Mask", "Pickaxe")
	if(equipment_kind == "Cancel") return
	if(equipment_kind == "Pickaxe")
		new /obj/items/Digging/NexusPickaxe(character)
		admin_blame(src, "[key] gave [character] a Nexus Pickaxe.")
		return
	var/list/material_options = list()
	for(var/material_id in forged_material_catalog)
		var/datum/ForgedMaterial/material = forged_material_catalog[material_id]
		material_options[material.name] = material
	var/material_choice = input(src, "Choose the material tier.", "Nexus Equipment") as null|anything in material_options
	if(isnull(material_choice)) return
	var/datum/ForgedMaterial/selected_material = material_options[material_choice]
	if(equipment_kind == "Weapon")
		var/datum/ForgedWeaponStyle/weapon_style = chooseForgedWeaponStyle("Give Nexus Equipment")
		if(!weapon_style) return
		var/obj/items/Sword/Forged/weapon = new(character)
		weapon.forged_material_id = selected_material.id
		weapon.forged_style_id = weapon_style.id
		weapon.refreshForgedWeapon()
		admin_blame(src, "[key] gave [character] [weapon].")
	else if(equipment_kind == "Armor")
		var/datum/ForgedArmorStyle/armor_style = chooseForgedArmorStyle("Give Nexus Equipment")
		if(!armor_style) return
		var/obj/items/Armor/Forged/armor = new(character)
		armor.forged_material_id = selected_material.id
		armor.forged_style_id = armor_style.id
		armor.refreshForgedArmor()
		admin_blame(src, "[key] gave [character] [armor].")
	else if(equipment_kind == "Gloves")
		var/datum/ForgedGloveStyle/glove_style = chooseForgedGloveStyle("Give Nexus Equipment")
		if(!glove_style) return
		var/obj/items/Gloves/Forged/gloves = new(character)
		gloves.forged_material_id = selected_material.id
		gloves.forged_style_id = glove_style.id
		gloves.refreshForgedGloves()
		admin_blame(src, "[key] gave [character] [gloves].")
	else
		var/datum/ForgedMaskStyle/mask_style = chooseForgedMaskStyle("Give Nexus Equipment")
		if(!mask_style) return
		var/obj/items/Mask/Forged/mask = new(character)
		mask.forged_material_id = selected_material.id
		mask.forged_style_id = mask_style.id
		mask.refreshForgedMask()
		admin_blame(src, "[key] gave [character] [mask].")
