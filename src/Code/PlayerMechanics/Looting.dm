mob/proc/getInjureLootError(mob/target, obj/loot)
	var/error = getInjureActionError(target, "Steal")
	if(error) return error
	if(!loot || loot.loc != target) return "That item is no longer held by the target."
	if(istype(loot, /obj/Resources))
		var/obj/Resources/resources = loot
		return resources.Value > 0 ? null : "There are no resources left to steal."
	if(!istype(loot, /obj/items) || !(loot in target.item_list)) return "Only inventory items can be stolen."
	var/obj/items/item = loot
	if(!item.Givable) return "This item is bound and cannot be transferred."
	if(item.suffix == "Installed" || (item.suffix && item.suffix != "Equipped" && !item.Can_Drop_With_Suffix)) return "This item must be uninstalled or deactivated first."
	if(istype(item, /obj/items/Force_Field)) return "An active personal force field cannot be transferred."
	if(item.isNexusTradeOfferedBy(target)) return "That item is currently locked in a trade."
	if(item_count() >= MaxItems()) return "Your inventory is full."
	return null

mob/proc/getInjureLootChoices(mob/target, include_resources = FALSE)
	var/list/items = list()
	if(getInjureActionError(target, "Steal")) return items
	for(var/obj/items/item in target.item_list)
		if(!getInjureLootError(target, item)) items += item
	if(include_resources)
		var/obj/Resources/resources = target.GetResourceObject()
		if(resources && !getInjureLootError(target, resources)) items += resources
	return items

mob/proc/promptInjureSteal(mob/target)
	if(!client) return FALSE
	var/list/items = getInjureLootChoices(target)
	if(!items.len)
		src << "No items can be stolen from this target right now."
		return FALSE
	var/obj/items/item = input(src, "Choose one item to steal from [target]. Equipped items are removed from their owner first.", "Steal") as null|anything in items
	if(!item || !(item in items)) return FALSE
	return stealInjureLoot(target, item)

// Use native equipment toggles so legacy stat multipliers are reversed exactly once.
mob/proc/toggleInjureLootEquipment(obj/items/item)
	if(!item || item.loc != src) return
	if(istype(item, /obj/items/Sword)) Apply_Sword(item)
	else if(istype(item, /obj/items/Armor)) Apply_Armor(item)
	else if(istype(item, /obj/items/Gloves/Forged)) applyForgedGloves(item)
	else if(istype(item, /obj/items/Mask/Forged)) applyForgedMask(item)
	else
		Clothes_Equip(item)
		if(istype(item, /obj/items/Weights)) weights_obj = item.suffix ? item : null
		if(istype(item, /obj/items/Scouter)) Scouter = item.suffix ? item : null

mob/proc/stealInjureLoot(mob/target, obj/loot)
	// Both the verb and legacy loot clicks revalidate here after any open prompt.
	var/error = getInjureLootError(target, loot)
	if(error)
		src << error
		return FALSE
	if(istype(loot, /obj/Resources))
		var/obj/Resources/resources = loot
		var/amount = resources.Value
		gainNexusResources(amount, "stolen resources")
		resources.Value = 0
		resources.Update_value()
		recordInjureOutcome(target, "Steal", "[src] steals [Commas(amount)] resources from [target].")
		return TRUE
	var/obj/items/item = loot
	var/was_equipped = item.suffix == "Equipped"
	if(was_equipped) target.toggleInjureLootEquipment(item)
	if(!item.Move(src) || item.loc != src)
		if(was_equipped && item && item.loc == target) target.toggleInjureLootEquipment(item)
		src << "The item could not be transferred."
		return FALSE
	if(target.Scouter == item) target.Scouter = null
	if(target.weights_obj == item) target.weights_obj = null
	target.rebuildPlayerAppearance("item stolen")
	rebuildPlayerAppearance("item received by theft")
	target.Restore_hotbar_from_IDs()
	Restore_hotbar_from_IDs()
	recordInjureOutcome(target, "Steal", "[src] steals [item] from [target].")
	return TRUE
