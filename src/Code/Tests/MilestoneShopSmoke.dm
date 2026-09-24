proc/runMilestoneShopSmokeTests()
	initializeMilestoneCatalog()
	var/list/styles = list("momentum_damage", "precision_damage", "fortified_damage")
	var/list/physical_stats = list(120, 110, 112)
	var/list/ki_stats = list(140, 130, 134)
	for(var/style_index = 1, style_index <= styles.len, style_index++)
		var/mob/customer = new
		customer.milestone_points = 22
		customer.total_milestone_points = 22
		customer.Str = 100
		customer.Pow = 120
		customer.Spd = 80
		customer.Off = 40
		customer.End = 60
		customer.Res = 70
		var/chosen_id = styles[style_index]
		var/datum/NexusMilestoneShopWindow/shop = new(customer)
		nexusSmokeAssert(!shop.canUse(), "Milestone shop accepted a caller without an owner client")
		nexusSmokeAssert(shop.purchaseMilestoneShopEntry(chosen_id, "0"), "Milestone shop rejected a first damage style")
		var/remaining = customer.milestone_points
		for(var/other_id in styles)
			if(other_id == chosen_id) continue
			nexusSmokeAssert(!customer.purchaseMilestone(other_id) && !shop.purchaseMilestoneShopEntry(other_id, "0"), "A second damage style bypassed authoritative exclusivity")
			nexusSmokeAssert(!customer.getMilestoneRank(other_id) && customer.milestone_points == remaining, "Rejected damage style consumed MP or granted ownership")
			var/datum/MilestoneDefinition/other = milestone_catalog[other_id]
			nexusSmokeAssert(customer.getMilestoneExclusiveChoice(other) == milestone_catalog[chosen_id], "Shop and purchase validation disagree about the chosen damage style")
		nexusSmokeAssertNear(customer.getMilestonePhysicalDamageStat(), physical_stats[style_index], 0.001, "Physical damage combined exclusive styles or used the wrong secondary stat")
		nexusSmokeAssertNear(customer.getMilestoneKiDamageStat(), ki_stats[style_index], 0.001, "Ki damage combined exclusive styles or used the wrong secondary stat")
		nexusSmokeAssert(!shop.purchaseMilestoneShopEntry(chosen_id, "0") && customer.milestone_points == remaining, "Replayed shop purchase spent MP twice")
		nexusSmokeAssert(shop.purchaseMilestoneShopEntry("versatile_training", "0") && shop.purchaseMilestoneShopEntry("keen_edge", "0"), "Damage-style selection incorrectly locked unrelated Milestones")
		nexusSmokeAssert(shop.purchaseMilestoneShopEntry("versatile_training", "1"), "Milestone shop prevented a valid rank upgrade")
		remaining = customer.milestone_points
		nexusSmokeAssert(!shop.purchaseMilestoneShopEntry("versatile_training", "1") && !shop.purchaseMilestoneShopEntry("iron_will", null) && !shop.purchaseMilestoneShopEntry("missing_milestone", "0") && customer.milestone_points == remaining, "Shop accepted a stale, missing or invalid purchase snapshot")
		var/list/data = shop.buildMilestoneShopData()
		var/list/entries = data["entries"]
		nexusSmokeAssert(entries.len == milestone_catalog.len && data["points"] == remaining && data["cap"] == NEXUS_MILESTONE_POINT_CAP, "Milestone shop copied or truncated its authoritative catalog or balance")
		var/exclusive_count = 0
		for(var/list/entry in entries)
			var/datum/MilestoneDefinition/definition = milestone_catalog[entry["id"]]
			nexusSmokeAssert(entry["cost"] == definition.cost && entry["maxRank"] == definition.max_rank && entry["description"] == definition.description && entry["icon"], "Shop lost a live Milestone definition or Nexus illustration")
			if(entry["exclusiveGroup"] != "secondary_damage_stat") continue
			exclusive_count++
			nexusSmokeAssert(entry["exclusiveChoice"] == chosen_id && entry["state"] == (entry["id"] == chosen_id ? "owned" : "locked"), "Shop failed to distinguish the chosen style and blocked alternatives")
		nexusSmokeAssert(exclusive_count == 3, "Damage-style shop group must contain exactly the three existing choices")
		customer.milestone_points = 0
		nexusSmokeAssert(!shop.purchaseMilestoneShopEntry("iron_will", "0") && !customer.getMilestoneRank("iron_will"), "Shop allowed an unaffordable purchase")
		customer.name = "</script><script>unexpected()</script>"
		var/html = shop.buildMilestoneShopHtml()
		nexusSmokeAssert(!findtext(html, customer.name) && findtext(html, "decodeURIComponent") && findtext(html, "MilestoneShop.css"), "Milestone shop did not safely encode character data")
		del(shop)
		del(customer)
