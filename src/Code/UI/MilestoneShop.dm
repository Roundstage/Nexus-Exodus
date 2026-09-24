// Presentation only: prices, ranks and exclusive choices come from the live catalog.
proc/getMilestoneShopCategoryIconKind(category)
	switch(category)
		if("Resolve") return "vitals"
		if("Combat") return "buff"
		if("Martial Arts") return "gloves"
		if("Weapon") return "skills"
		if("Ki") return "blast"
		if("Survival") return "armor"
		if("Fire") return "ability"
		if("Growth") return "training"
		if("Culture") return "logs"
		if("Scholarship") return "science"
		if("Craft") return "smithing"
	return "milestones"

var/list/milestone_shop_art_layout
var/list/milestone_shop_art_cache = list()
client/var/tmp/list/milestone_shop_art_resources = list()

proc/getMilestoneShopIcon(milestone_id)
	if(milestone_shop_art_cache[milestone_id]) return milestone_shop_art_cache[milestone_id]
	if(!milestone_shop_art_layout) milestone_shop_art_layout = json_decode(file2text('src/Images/Milestones/MilestoneIcons.json'))
	var/list/art_ids = milestone_shop_art_layout["ids"]
	var/art_index = art_ids.Find(milestone_id)
	if(!art_index) return getNexusPixelInterfaceIcon("milestones")
	var/cell_size = milestone_shop_art_layout["size"]
	var/columns = milestone_shop_art_layout["columns"]
	var/icon/art = icon('src/Images/Milestones/MilestoneIcons.png')
	var/left = ((art_index - 1) % columns) * cell_size
	var/top = art.Height() - round((art_index - 1) / columns) * cell_size
	art.Crop(left + 1, top - cell_size + 1, left + cell_size, top)
	milestone_shop_art_cache[milestone_id] = art
	return art

proc/getMilestoneShopIconResource(mob/viewer, milestone_id)
	var/resource_name = "nexus_milestone_[milestone_id].png"
	if(viewer && viewer.client)
		if(!islist(viewer.client.milestone_shop_art_resources)) viewer.client.milestone_shop_art_resources = list()
		if(!viewer.client.milestone_shop_art_resources[resource_name])
			viewer << browse_rsc(getMilestoneShopIcon(milestone_id), resource_name)
			viewer.client.milestone_shop_art_resources[resource_name] = TRUE
	return resource_name

client/var/tmp/datum/NexusMilestoneShopWindow/nexus_milestone_shop

datum/NexusMilestoneShopWindow
	var/tmp/mob/owner
	var/tmp/milestone_shop_notice = ""

	New(mob/new_owner)
		. = ..()
		owner = new_owner

	Del()
		if(owner && owner.client)
			owner << browse(null, "window=NexusMilestones")
			if(owner.client.nexus_milestone_shop == src) owner.client.nexus_milestone_shop = null
		owner = null
		. = ..()

	proc/canUse()
		return owner && owner.client && owner.playerCharacter && usr == owner

	proc/show()
		if(!owner || !owner.client || !owner.playerCharacter)
			del(src)
			return
		owner << browse(buildMilestoneShopHtml(), "window=NexusMilestones;size=1280x820;can_resize=true;can_close=true")

	Topic(href, list/href_list)
		if(!canUse()) return
		switch(href_list["action"])
			if("milestone") purchaseMilestoneShopEntry(href_list["node"], href_list["rank"])
			if("close")
				del(src)
				return
			else return
		show()

	proc/buildMilestoneShopData()
		initializeMilestoneCatalog()
		var/list/entries = list()
		var/list/categories = list("Builds")
		var/list/category_icons = list("All" = getNexusPixelInterfaceIconResource(owner, "milestones"))
		var/damage_style = ""
		for(var/milestone_id in milestone_catalog)
			var/datum/MilestoneDefinition/milestone = milestone_catalog[milestone_id]
			var/rank = owner.getMilestoneRank(milestone_id)
			var/reason = owner.getMilestoneLockReason(milestone)
			var/datum/MilestoneDefinition/chosen = owner.getMilestoneExclusiveChoice(milestone)
			var/state = rank >= milestone.max_rank ? "owned" : (reason ? "locked" : "available")
			if(milestone.exclusive_group == "secondary_damage_stat" && rank) damage_style = milestone.name
			if(!(milestone.branch in categories)) categories += milestone.branch
			category_icons[milestone.branch] = getNexusPixelInterfaceIconResource(owner, getMilestoneShopCategoryIconKind(milestone.branch))
			entries += list(list(
				"id" = milestone.id, "name" = milestone.name, "description" = milestone.description,
				"category" = milestone.branch, "cost" = milestone.cost, "rank" = rank, "maxRank" = milestone.max_rank,
				"state" = state, "reason" = reason ? reason : "", "exclusiveGroup" = milestone.exclusive_group,
				"exclusiveChoice" = chosen ? chosen.id : "", "icon" = getMilestoneShopIconResource(owner, milestone.id)
			))
		return list("ref" = "\ref[src]", "character" = "[owner.name]", "race" = "[owner.Race]",
			"points" = owner.milestone_points, "earned" = owner.total_milestone_points, "cap" = NEXUS_MILESTONE_POINT_CAP,
			"damageStyle" = damage_style, "entries" = entries, "categories" = categories, "categoryIcons" = category_icons, "notice" = milestone_shop_notice)

	proc/buildMilestoneShopHtml()
		prepareNexusHudBrowserResources(owner)
		if(owner && owner.client)
			owner << browse_rsc('src/Code/UI/Browser/MilestoneShop.css', "MilestoneShop.css")
			owner << browse_rsc('src/Code/UI/Browser/MilestoneShop.js', "MilestoneShop.js")
		var/encoded_config = url_encode(json_encode(buildMilestoneShopData()))
		// Decode form spaces before percent escapes so literal bonus signs remain intact.
		return {"<!doctype html><html><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'><title>Nexus Milestones</title><style>[getNexusHudBrowserCss("bronze")]</style><link rel='stylesheet' href='MilestoneShop.css'></head><body class='nexus-hud milestone-shop'><script>window.milestoneShopConfig=JSON.parse(decodeURIComponent('[encoded_config]'.split('+').join(' ')));</script><script src='MilestoneShop.js'></script></body></html>"}

	// Topic checks the owner first. The rank snapshot also rejects double clicks and stale purchases.
	proc/purchaseMilestoneShopEntry(milestone_id, expected_rank)
		initializeMilestoneCatalog()
		var/datum/MilestoneDefinition/milestone = milestone_catalog[milestone_id]
		if(!milestone || !istext(expected_rank) || expected_rank != "[owner.getMilestoneRank(milestone_id)]")
			milestone_shop_notice = "Your Milestones changed. Review the current rank before purchasing."
			return FALSE
		if(!owner.purchaseMilestone(milestone_id))
			milestone_shop_notice = owner.getMilestoneLockReason(milestone)
			if(!milestone_shop_notice) milestone_shop_notice = "This Milestone is already at maximum rank."
			return FALSE
		milestone_shop_notice = "Purchased [milestone.name], rank [owner.getMilestoneRank(milestone_id)]/[milestone.max_rank]."
		return TRUE

mob/proc/showMilestoneShop()
	if(!client || !playerCharacter) return
	syncMilestoneProgression(silent = TRUE)
	if(client.nexus_milestone_shop) del(client.nexus_milestone_shop)
	client.nexus_milestone_shop = new /datum/NexusMilestoneShopWindow(src)
	client.nexus_milestone_shop.show()

mob/proc/toggleMilestoneShop()
	if(!client || !playerCharacter) return
	if(client.nexus_milestone_shop)
		del(client.nexus_milestone_shop)
		return
	showMilestoneShop()
