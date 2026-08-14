#define APPEARANCE_PRIORITY_BACK 300
#define APPEARANCE_PRIORITY_BODY 500
#define APPEARANCE_PRIORITY_FRONT 700

datum/PlayerAppearanceEntry
	var/slot_key
	var/category
	var/priority = APPEARANCE_PRIORITY_BODY
	var/sequence
	var/obj/source
	var/appearance_icon
	var/icon_state
	var/pixel_x
	var/pixel_y
	var/color
	var/alpha = 255
	var/image/rendered

	proc/createRenderedAppearance(matrix/character_transform)
		var/image/result = image(icon = appearance_icon, icon_state = icon_state)
		result.pixel_x = pixel_x
		result.pixel_y = pixel_y
		result.color = color
		result.alpha = alpha
		// Keep equipment on the exact same transform as the body. Some clients detached item
		// appearances from the parent transform, leaving forged swords, masks and armor at 32px.
		// RESET_TRANSFORM prevents a second parent multiplication after applying the body matrix.
		result.appearance_flags |= RESET_TRANSFORM | PIXEL_SCALE
		if(character_transform) result.transform = matrix(character_transform)
		return result

datum/PlayerAppearanceManager
	var/mob/owner
	var/list/entries = list()
	var/list/rendered_appearances = list()
	var/next_sequence
	var/rebuilding
	var/rebuild_generation
	var/last_rebuild_reason

	New(mob/new_owner)
		owner = new_owner

	proc/setSlot(slot_key, category, priority, appearance_icon, obj/source, icon_state, pixel_x = 0, pixel_y = 0, color, alpha = 255)
		if(!slot_key || !appearance_icon) return
		var/datum/PlayerAppearanceEntry/entry = entries[slot_key]
		if(!entry)
			entry = new
			entry.slot_key = slot_key
			entry.sequence = ++next_sequence
			entries[slot_key] = entry
		entry.category = category
		entry.priority = priority
		entry.source = source
		entry.appearance_icon = appearance_icon
		entry.icon_state = icon_state
		entry.pixel_x = pixel_x
		entry.pixel_y = pixel_y
		entry.color = color
		entry.alpha = alpha

	proc/clearCategory(category)
		var/list/remove_keys = list()
		for(var/slot_key in entries)
			var/datum/PlayerAppearanceEntry/entry = entries[slot_key]
			if(entry.category == category) remove_keys += slot_key
		for(var/slot_key in remove_keys) entries -= slot_key

	proc/removeRenderedAppearances()
		if(!owner) return
		for(var/image/rendered in rendered_appearances) owner.overlays -= rendered
		rendered_appearances = list()

	proc/entryBefore(datum/PlayerAppearanceEntry/left, datum/PlayerAppearanceEntry/right)
		if(left.priority != right.priority) return left.priority < right.priority
		if(left.category != right.category) return "[left.category]" < "[right.category]"
		if(left.slot_key != right.slot_key) return "[left.slot_key]" < "[right.slot_key]"
		return left.sequence < right.sequence

	proc/sortedEntries()
		var/list/result = list()
		for(var/slot_key in entries)
			var/datum/PlayerAppearanceEntry/entry = entries[slot_key]
			var/inserted
			for(var/index in 1 to result.len)
				var/datum/PlayerAppearanceEntry/current = result[index]
				if(entryBefore(entry, current))
					result.Insert(index, entry)
					inserted = TRUE
					break
			if(!inserted) result += entry
		return result

	proc/isManagedEquipment(obj/items/item)
		if(!item) return FALSE
		if(item.appearance_managed) return TRUE
		if(istype(item, /obj/items/Clothes)) return TRUE
		if(istype(item, /obj/items/Weights)) return TRUE
		if(istype(item, /obj/items/Armor)) return TRUE
		if(istype(item, /obj/items/Scouter)) return TRUE
		if(istype(item, /obj/items/Sword)) return TRUE
		if(istype(item, /obj/items/Hover_Chair)) return TRUE
		return FALSE

	proc/appearanceMatchesEquipment(appearance_value, obj/items/item)
		if(!item || !item.icon) return FALSE
		if(appearance_value == item.icon) return TRUE
		if(!appearance_value || !appearance_value:icon) return FALSE
		if(appearance_value:icon != item.icon) return FALSE
		if("[appearance_value:icon_state]" != "[item.icon_state]") return FALSE
		if(appearance_value:pixel_x != item.pixel_x || appearance_value:pixel_y != item.pixel_y) return FALSE
		return TRUE

	proc/removeLegacyEquipmentAppearances()
		if(!owner) return
		var/list/managed_items = list()
		for(var/obj/items/item in owner.contents)
			if(!isManagedEquipment(item) || !item.icon) continue
			managed_items += item
		if(!managed_items.len) return
		var/list/remove_appearances = list()
		for(var/appearance_value in owner.overlays)
			for(var/obj/items/item in managed_items)
				if(!appearanceMatchesEquipment(appearance_value, item)) continue
				remove_appearances += appearance_value
				break
		for(var/appearance_value in remove_appearances)
			while(owner.overlays.Find(appearance_value)) owner.overlays -= appearance_value

	proc/syncEquipment()
		clearCategory("equipment")
		removeLegacyEquipmentAppearances()
		if(!owner) return
		if(owner.IsGreatApe() || (owner.using_giant_form && owner.Race == "Makyo")) return
		for(var/obj/items/item in owner.contents)
			if(!isManagedEquipment(item) || item.suffix != "Equipped" || !item.icon) continue
			item.appearance_managed = TRUE
			setSlot("equipment:\ref[item]", "equipment", item.appearance_priority, item.icon, item, item.icon_state, item.pixel_x, item.pixel_y, item.color, item.alpha)

	proc/rebuild(reason)
		if(rebuilding || !owner) return
		rebuilding = TRUE
		last_rebuild_reason = reason
		removeRenderedAppearances()
		syncEquipment()
		var/list/ordered_entries = sortedEntries()
		for(var/datum/PlayerAppearanceEntry/entry in ordered_entries)
			entry.rendered = entry.createRenderedAppearance(owner.transform)
			owner.overlays += entry.rendered
			rendered_appearances += entry.rendered
		owner.Add_Injury_Overlays()
		rebuild_generation++
		rebuilding = FALSE

	proc/setRenderedTransform(matrix/character_transform, animation_time = 0)
		if(!character_transform) return
		for(var/image/rendered in rendered_appearances)
			if(animation_time > 0)
				animate(rendered, transform = character_transform, time = animation_time, easing = CUBIC_EASING)
			else
				rendered.transform = matrix(character_transform)

obj/items/var
	appearance_managed
	appearance_priority = APPEARANCE_PRIORITY_BODY

mob/var/tmp/datum/PlayerAppearanceManager/player_appearance_manager

mob/var/tmp
	list/nexus_character_visual_scale_sources
mob/var/nexus_character_visual_scale = 1

mob/proc/normalizeNexusCharacterVisualScale()
	// datum.Write() persists the live transform. Adopt the scale already represented by that
	// matrix before restoring transient source ownership, otherwise relog would multiply it again.
	nexus_character_visual_scale_sources = list()
	var/adopted_scale = 1
	if(using_giant_form && Race != "Makyo")
		nexus_character_visual_scale_sources["giant_form"] = 2
		adopted_scale = 2
	for(var/obj/Module/module in contents)
		if(module.Giant && module.suffix)
			nexus_character_visual_scale_sources["android_giant"] = 42 / 32
			adopted_scale = max(adopted_scale, 42 / 32)
	if(!nexus_character_visual_scale_sources.len) nexus_character_visual_scale_sources = null
	nexus_character_visual_scale = adopted_scale
	return adopted_scale

mob/proc/getNexusCharacterVisualScale()
	var/effective_scale = 1
	if(nexus_character_visual_scale_sources)
		for(var/source_id in nexus_character_visual_scale_sources)
			var/source_scale = nexus_character_visual_scale_sources[source_id]
			if(isnum(source_scale)) effective_scale = max(effective_scale, source_scale)
	return effective_scale

mob/proc/setNexusCharacterVisualScaleSource(source_id, source_scale = 1, animation_time = 0)
	if(!source_id) return
	if(!nexus_character_visual_scale_sources) nexus_character_visual_scale_sources = list()
	if(source_scale > 1)
		nexus_character_visual_scale_sources[source_id] = source_scale
	else
		nexus_character_visual_scale_sources -= source_id
		if(!nexus_character_visual_scale_sources.len) nexus_character_visual_scale_sources = null
	var/old_scale = max(0.01, nexus_character_visual_scale)
	var/new_scale = getNexusCharacterVisualScale()
	if(abs(new_scale - old_scale) <= 0.0001) return new_scale
	var/matrix/target_transform = matrix(transform)
	var/scale_ratio = new_scale / old_scale
	// Scale only the linear portion. Multiplying the full matrix also scales an existing
	// translation and visibly moves custom Android bodies away from their original anchor.
	target_transform.a *= scale_ratio
	target_transform.b *= scale_ratio
	target_transform.d *= scale_ratio
	target_transform.e *= scale_ratio
	nexus_character_visual_scale = new_scale
	if(player_appearance_manager)
		player_appearance_manager.setRenderedTransform(target_transform, animation_time)
	if(animation_time > 0)
		animate(src, transform = target_transform, time = animation_time, easing = CUBIC_EASING)
	else
		transform = target_transform
	return new_scale

mob/proc/ensurePlayerAppearanceManager()
	if(!player_appearance_manager) player_appearance_manager = new(src)
	return player_appearance_manager

mob/proc/rebuildPlayerAppearance(reason = "state change")
	var/datum/PlayerAppearanceManager/manager = ensurePlayerAppearanceManager()
	manager.rebuild(reason)

mob/proc/setEquipmentAppearancePriority(obj/items/item, priority)
	if(!item || item.loc != src) return
	item.appearance_priority = Clamp(round(priority), APPEARANCE_PRIORITY_BACK, APPEARANCE_PRIORITY_FRONT)
	rebuildPlayerAppearance("equipment priority")

mob/verb/manageVisualLayers()
	set name = "Manage Visual Layers"
	set category = "Other"
	var/list/choices = list("Cancel")
	var/list/items_by_label = list()
	for(var/obj/items/item in contents)
		if(item.suffix != "Equipped") continue
		var/label = "[item] ([item.appearance_priority])"
		var/suffix_index = 2
		while(items_by_label[label])
			label = "[item] #[suffix_index] ([item.appearance_priority])"
			suffix_index++
		choices += label
		items_by_label[label] = item
	var/selection = input(src, "Choose an equipped overlay to move. Lower values render behind higher values.", "Visual layers") in choices
	if(selection == "Cancel") return
	var/obj/items/item = items_by_label[selection]
	if(!item || item.loc != src || item.suffix != "Equipped" || item.isNexusTradeOfferedBy(src)) return
	var/new_priority = input(src, "Priority from [APPEARANCE_PRIORITY_BACK] (back) to [APPEARANCE_PRIORITY_FRONT] (front).", "[item]", item.appearance_priority) as num|null
	if(isnull(new_priority) || item.loc != src || item.suffix != "Equipped" || item.isNexusTradeOfferedBy(src)) return
	setEquipmentAppearancePriority(item, new_priority)

mob/verb/viewVisualLayers()
	set name = "View Visual Layers"
	set category = "Other"
	var/datum/PlayerAppearanceManager/manager = ensurePlayerAppearanceManager()
	manager.syncEquipment()
	var/list/ordered_entries = manager.sortedEntries()
	var/html = "<html><body style='background:#17100d;color:#f3dfba;font-family:Verdana'><h2>Player overlay order</h2><p>Lower priorities render first.</p><table border=1 cellspacing=0 cellpadding=4><tr><th>#</th><th>Slot</th><th>Category</th><th>Priority</th><th>Source</th></tr>"
	var/index
	for(var/datum/PlayerAppearanceEntry/entry in ordered_entries)
		index++
		html += "<tr><td>[index]</td><td>[html_encode(entry.slot_key)]</td><td>[html_encode(entry.category)]</td><td>[entry.priority]</td><td>[entry.source ? html_encode("[entry.source]") : "-"]</td></tr>"
	html += "</table><p>Raw overlays: [overlays.len]. Managed overlays: [manager.rendered_appearances.len].</p></body></html>"
	src << browse(html, "window=visual_layers;size=720x520")

#undef APPEARANCE_PRIORITY_BACK
#undef APPEARANCE_PRIORITY_BODY
#undef APPEARANCE_PRIORITY_FRONT
