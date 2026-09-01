var/const/NEXUS_PLANET_CONTROL_SAVE_VERSION = 3
var/const/NEXUS_PLANET_TAX_MAX_PERCENT = 25
var/const/NEXUS_PLANET_CONTROL_OFFICER_RANK = 6
var/const/NEXUS_PLANET_CONTROL_CLAIM_RANK = 7
var/const/NEXUS_PLANET_CONTROL_ABANDONMENT_TICKS = 72 * 60 * 60 * 10

var/list/nexus_planet_controls = list()
var/tmp/nexus_planet_controls_dirty = FALSE

datum/NexusPlanetControl
	var
		planet_id
		planet_name
		controller_league_id
		controller_league_name
		controller_leader_key
		holder_account_id
		holder_key
		holder_slot = 1
		holder_character_made_time = 0
		holder_name
		holder_last_seen = 0
		abandoned_at = 0
		resource_tax_rate = 0
		essence_tax_rate = 0
		resource_treasury = 0
		essence_treasury = 0
		captured_at = 0
		ownership_revision = 0
		state_revision = 0
		tmp/capture_locked = FALSE

	New(new_planet_id, new_planet_name)
		planet_id = lowertext("[new_planet_id]")
		planet_name = "[new_planet_name]"
		normalize()

	proc/normalize()
		planet_id = lowertext(copytext("[planet_id]", 1, 65))
		planet_name = copytext("[planet_name]", 1, 81)
		controller_league_id = copytext("[controller_league_id]", 1, 201)
		controller_league_name = normalizeNexusLeagueInlineText(controller_league_name, NEXUS_LEAGUE_NAME_LIMIT)
		controller_leader_key = copytext("[controller_leader_key]", 1, 81)
		holder_account_id = ckey(holder_account_id)
		holder_key = copytext("[holder_key]", 1, 81)
		holder_slot = clampNexusCharacterSlot(holder_slot)
		if(!nexusIsFiniteNumber(holder_character_made_time) || holder_character_made_time < 0) holder_character_made_time = 0
		holder_name = normalizeNexusLeagueInlineText(holder_name, 80)
		if(!nexusIsFiniteNumber(holder_last_seen) || holder_last_seen < 0) holder_last_seen = 0
		if(!nexusIsFiniteNumber(abandoned_at) || abandoned_at < 0) abandoned_at = 0
		if(!nexusIsFiniteNumber(resource_tax_rate)) resource_tax_rate = 0
		if(!nexusIsFiniteNumber(essence_tax_rate)) essence_tax_rate = 0
		resource_tax_rate = Clamp(round(resource_tax_rate, 0.1), 0, NEXUS_PLANET_TAX_MAX_PERCENT)
		essence_tax_rate = Clamp(round(essence_tax_rate, 0.1), 0, NEXUS_PLANET_TAX_MAX_PERCENT)
		if(!nexusIsFiniteNumber(resource_treasury)) resource_treasury = 0
		if(!nexusIsFiniteNumber(essence_treasury)) essence_treasury = 0
		resource_treasury = max(0, round(resource_treasury, 0.000001))
		essence_treasury = max(0, round(essence_treasury, 0.1))
		if(!nexusIsFiniteNumber(captured_at) || captured_at < 0) captured_at = 0
		if(!nexusIsFiniteNumber(ownership_revision) || ownership_revision < 0) ownership_revision = 0
		if(!nexusIsFiniteNumber(state_revision) || state_revision < 0) state_revision = 0
		ownership_revision = round(ownership_revision)
		state_revision = round(state_revision)
		if(!controller_league_id)
			controller_league_name = null
			controller_leader_key = null
			holder_account_id = null
			holder_key = null
			holder_slot = 1
			holder_character_made_time = 0
			holder_name = null
			holder_last_seen = 0
			abandoned_at = 0
			resource_tax_rate = 0
			essence_tax_rate = 0
			resource_treasury = 0
			essence_treasury = 0
			captured_at = 0

	proc/isClaimed()
		return !!controller_league_id

	proc/isHolder(mob/player)
		if(!player || !isClaimed()) return FALSE
		if(player.getNexusPlanetControlAccountId() != holder_account_id) return FALSE
		if(clampNexusCharacterSlot(player.active_character_slot) != holder_slot) return FALSE
		return player.character_made_time == holder_character_made_time

	proc/isHolderPresent()
		if(!isClaimed()) return FALSE
		for(var/mob/player in players)
			if(player.playerCharacter && !player.Dead && (player.client || player.empty_player) && isHolder(player) && player.hasNexusLeagueMembership(controller_league_id)) return TRUE
		return FALSE

	proc/isAbandoned()
		if(!isClaimed()) return FALSE
		if(abandoned_at) return TRUE
		var/last_presence = max(holder_last_seen, captured_at)
		if(world.realtime >= last_presence + NEXUS_PLANET_CONTROL_ABANDONMENT_TICKS) return TRUE
		return FALSE

	proc/orphanController()
		if(!isClaimed()) return FALSE
		holder_account_id = null
		holder_key = null
		holder_slot = 1
		holder_character_made_time = 0
		holder_name = "No active holder"
		holder_last_seen = world.realtime
		abandoned_at = world.realtime
		ownership_revision++
		state_revision++
		return TRUE

	proc/clearController()
		controller_league_id = null
		controller_league_name = null
		controller_leader_key = null
		holder_account_id = null
		holder_key = null
		holder_slot = 1
		holder_character_made_time = 0
		holder_name = null
		holder_last_seen = 0
		abandoned_at = 0
		resource_tax_rate = 0
		essence_tax_rate = 0
		resource_treasury = 0
		essence_treasury = 0
		captured_at = 0
		ownership_revision++
		state_revision++
		return TRUE

	proc/setController(mob/player, obj/League/league, reset_taxes = TRUE)
		if(!player || !league || league.loc != player || !league.league_id) return FALSE
		controller_league_id = "[league.league_id]"
		controller_league_name = normalizeNexusLeagueInlineText(league.name, NEXUS_LEAGUE_NAME_LIMIT)
		controller_leader_key = copytext("[league.league_leader]", 1, 81)
		holder_account_id = player.getNexusPlanetControlAccountId()
		holder_key = copytext("[player.key ? player.key : player.displaykey]", 1, 81)
		holder_slot = clampNexusCharacterSlot(player.active_character_slot)
		holder_character_made_time = player.character_made_time
		holder_name = normalizeNexusLeagueInlineText(player.name, 80)
		captured_at = world.realtime
		holder_last_seen = world.realtime
		abandoned_at = 0
		ownership_revision++
		state_revision++
		if(reset_taxes)
			resource_tax_rate = 0
			essence_tax_rate = 0
		normalize()
		return TRUE

mob/var
	heran_refuses_planetary_taxes = FALSE
	nexus_planet_control_context_id
	list/nexus_planet_resource_tax_remainders = list()
	list/nexus_planet_essence_tax_remainders = list()
	tmp/last_nexus_planet_tax_notice = -100
	tmp/nexus_planet_control_teleport_context_override
	tmp/nexus_planet_control_has_teleport_context_override = FALSE

proc/getNexusPlanetControlSavePath(environment = nexus_runtime_environment)
	return normalizeNexusRuntimeEnvironment(environment) == "playtest" ? "data/Playtest/PlanetControl" : "data/PlanetControl"

proc/resolveNexusPlanetControlRegionByPosition(z_level, player_x, player_y)
	if(!isnum(z_level) || !isnum(player_x) || !isnum(player_y)) return null
	var/list/manifest = getNexusPlanetMapRegionManifest()
	for(var/region_id in manifest)
		var/list/region = manifest[region_id]
		if(!islist(region) || region["z_level"] != z_level) continue
		if(player_x < region["min_x"] || player_x > region["max_x"] || player_y < region["min_y"] || player_y > region["max_y"]) continue
		return region.Copy()
	return null

proc/getNexusPlanetControlShipRegion(turf/interior_turf)
	if(!interior_turf) return null
	var/obj/Controls/nearest_controls
	var/nearest_distance = 1.#INF
	for(var/obj/Controls/controls in ship_controls)
		if(!controls.z || controls.z != interior_turf.z) continue
		var/control_distance = getdist(controls, interior_turf)
		if(control_distance < nearest_distance)
			nearest_controls = controls
			nearest_distance = control_distance
	var/obj/Ships/Ship/exterior_ship = nearest_controls ? nearest_controls.find_ship() : null
	if(!exterior_ship) return null
	return getNexusPlanetControlRegion(exterior_ship)

mob/proc/setNexusPlanetControlTeleportContext(planet_id)
	nexus_planet_control_teleport_context_override = getNexusPlanetMapRegion(planet_id) ? planet_id : null
	nexus_planet_control_has_teleport_context_override = TRUE
	return TRUE

mob/proc/updateNexusPlanetControlContextForTeleport(atom/destination)
	var/turf/destination_turf = destination ? destination.base_loc() : null
	var/area/destination_area = destination_turf ? destination_turf.loc : null
	if(!destination_turf || !destination_area || !isarea(destination_area))
		nexus_planet_control_has_teleport_context_override = FALSE
		nexus_planet_control_teleport_context_override = null
		nexus_planet_control_context_id = null
		return FALSE
	if(nexus_planet_control_has_teleport_context_override)
		var/context_override = nexus_planet_control_teleport_context_override
		nexus_planet_control_has_teleport_context_override = FALSE
		nexus_planet_control_teleport_context_override = null
		if(getNexusPlanetMapRegion(context_override))
			nexus_planet_control_context_id = context_override
			return TRUE
		if(istype(destination_area, /area/Mining_Cave))
			nexus_planet_control_context_id = null
			return FALSE
	var/list/region = resolveNexusPlanetMapRegion(destination_turf.z, destination_area.type, destination_turf.x, destination_turf.y)
	if(!region && istype(destination_area, /area/Inside)) region = resolveNexusPlanetControlRegionByPosition(destination_turf.z, destination_turf.x, destination_turf.y)
	if(!region && istype(destination_area, /area/ship_area)) region = getNexusPlanetControlShipRegion(destination_turf)
	if(region)
		nexus_planet_control_context_id = region["region_id"]
		return TRUE
	if(istype(destination_area, /area/Mining_Cave))
		var/cave_anchor_context_id
		var/cave_anchor_context_conflict = FALSE
		for(var/mob/cave_anchor in destination_turf)
			if(cave_anchor == src || !cave_anchor.playerCharacter) continue
			var/anchor_context_id = getNexusPlanetMapRegion(cave_anchor.nexus_planet_control_context_id) ? cave_anchor.nexus_planet_control_context_id : getNexusPlanetControlId(cave_anchor)
			if(!getNexusPlanetMapRegion(anchor_context_id)) continue
			if(!cave_anchor_context_id) cave_anchor_context_id = anchor_context_id
			else if(cave_anchor_context_id != anchor_context_id) cave_anchor_context_conflict = TRUE
		if(cave_anchor_context_id && !cave_anchor_context_conflict)
			nexus_planet_control_context_id = cave_anchor_context_id
			return TRUE
		if(getNexusPlanetMapRegion(nexus_planet_control_context_id)) return TRUE
		var/turf/source_turf = base_loc()
		var/area/source_area = source_turf ? source_turf.loc : null
		var/list/source_region = source_turf && source_area ? resolveNexusPlanetMapRegion(source_turf.z, source_area.type, source_turf.x, source_turf.y) : null
		if(source_region)
			nexus_planet_control_context_id = source_region["region_id"]
			return TRUE
	nexus_planet_control_context_id = null
	return FALSE

proc/getNexusPlanetControlRegion(atom/source)
	if(!source) return null
	var/turf/source_turf = source.base_loc()
	if(!source_turf) return null
	var/area/source_area = source_turf.loc
	if(!source_area || !isarea(source_area)) return null
	var/list/region = resolveNexusPlanetMapRegion(source_turf.z, source_area.type, source_turf.x, source_turf.y)
	var/mob/player = ismob(source) ? source : null
	if(region)
		if(player) player.nexus_planet_control_context_id = region["region_id"]
		return region
	if(!player) return null
	if(istype(source_area, /area/Inside))
		region = resolveNexusPlanetControlRegionByPosition(source_turf.z, source_turf.x, source_turf.y)
		if(region)
			player.nexus_planet_control_context_id = region["region_id"]
			return region
	if(istype(source_area, /area/ship_area))
		region = getNexusPlanetControlShipRegion(source_turf)
		if(region)
			player.nexus_planet_control_context_id = region["region_id"]
			return region
	if(istype(source_area, /area/Mining_Cave))
		if(getNexusPlanetMapRegion(player.nexus_planet_control_context_id))
			return getNexusPlanetMapRegion(player.nexus_planet_control_context_id)
		var/turf/entrance = player.last_cave_entered
		var/area/entrance_area = entrance ? entrance.loc : null
		if(entrance && entrance_area && isarea(entrance_area))
			var/list/entrance_region = resolveNexusPlanetMapRegion(entrance.z, entrance_area.type, entrance.x, entrance.y)
			if(entrance_region)
				player.nexus_planet_control_context_id = entrance_region["region_id"]
				return entrance_region
	return null

mob/proc/rememberNexusCaveControlPlanet(atom/entrance, atom/destination)
	var/turf/entrance_turf = entrance ? entrance.base_loc() : null
	var/area/entrance_area = entrance_turf ? entrance_turf.loc : null
	var/turf/destination_turf = destination ? destination.base_loc() : null
	var/area/destination_area = destination_turf ? destination_turf.loc : null
	if(!entrance_turf || !entrance_area || !isarea(entrance_area) || !destination_area || !istype(destination_area, /area/Mining_Cave))
		nexus_planet_control_context_id = null
		setNexusPlanetControlTeleportContext(null)
		return FALSE
	var/list/region = resolveNexusPlanetMapRegion(entrance_turf.z, entrance_area.type, entrance_turf.x, entrance_turf.y)
	if(!region)
		if(istype(entrance_area, /area/Mining_Cave) && getNexusPlanetMapRegion(nexus_planet_control_context_id))
			setNexusPlanetControlTeleportContext(nexus_planet_control_context_id)
			return TRUE
		nexus_planet_control_context_id = null
		setNexusPlanetControlTeleportContext(null)
		return FALSE
	nexus_planet_control_context_id = region["region_id"]
	setNexusPlanetControlTeleportContext(nexus_planet_control_context_id)
	return TRUE

proc/getNexusPlanetControlId(atom/source)
	var/list/region = getNexusPlanetControlRegion(source)
	return islist(region) ? region["region_id"] : null

proc/initializeNexusPlanetControls()
	if(!islist(nexus_planet_controls)) nexus_planet_controls = list()
	var/list/manifest = getNexusPlanetMapRegionManifest()
	for(var/planet_id in manifest)
		var/list/region = manifest[planet_id]
		var/datum/NexusPlanetControl/control = nexus_planet_controls[planet_id]
		if(!istype(control))
			control = new /datum/NexusPlanetControl(planet_id, region["planet_name"])
			nexus_planet_controls[planet_id] = control
		else
			control.planet_id = planet_id
			control.planet_name = region["planet_name"]
			control.normalize()
	return nexus_planet_controls

proc/getNexusPlanetControl(planet_id, create_if_missing = TRUE)
	planet_id = lowertext("[planet_id]")
	if(!planet_id) return null
	if(create_if_missing) initializeNexusPlanetControls()
	var/datum/NexusPlanetControl/control = nexus_planet_controls[planet_id]
	return istype(control) ? control : null

proc/getNexusPlanetControlsHeldBy(mob/player)
	var/list/held_controls = list()
	if(!player) return held_controls
	initializeNexusPlanetControls()
	var/list/manifest = getNexusPlanetMapRegionManifest()
	for(var/planet_id in manifest)
		var/datum/NexusPlanetControl/control = getNexusPlanetControl(planet_id, FALSE)
		if(control && control.isHolder(player)) held_controls += control
	return held_controls

mob/proc/getCurrentNexusPlanetControl()
	return getNexusPlanetControl(getNexusPlanetControlId(src), FALSE)

mob/proc/getNexusPlanetControlAccountId()
	var/account_key = key ? key : displaykey
	return ckey(account_key)

mob/proc/getNexusLeagueBadgeById(league_id)
	if(!league_id) return null
	for(var/obj/League/league in src)
		if(league.loc == src && league.league_id == league_id) return league
	return null

mob/proc/hasNexusLeagueMembership(league_id)
	return !!getNexusLeagueBadgeById(league_id)

mob/proc/getNexusControlLeagueChoices(excluded_league_id, leaders_only = FALSE)
	var/list/choices = list()
	var/list/seen_ids = list()
	for(var/obj/League/league in src)
		if(league.loc != src || !league.league_id || league.league_id == excluded_league_id) continue
		if(leaders_only && league.league_rank < NEXUS_PLANET_CONTROL_CLAIM_RANK) continue
		if(seen_ids[league.league_id]) continue
		seen_ids[league.league_id] = TRUE
		choices += league
	return choices

mob/proc/isNexusPlanetaryTaxExempt(datum/NexusPlanetControl/control)
	if(!control || !control.isClaimed()) return TRUE
	if(hasNexusLeagueMembership(control.controller_league_id)) return TRUE
	return Race == "Heran" && heran_refuses_planetary_taxes

mob/proc/notifyNexusPlanetaryTax(datum/NexusPlanetControl/control, resource_tax, essence_tax, reason)
	if(!control || (!resource_tax && !essence_tax) || world.time < last_nexus_planet_tax_notice + 100) return
	last_nexus_planet_tax_notice = world.time
	var/list/parts = list()
	if(resource_tax) parts += "[Commas(resource_tax)] resources"
	if(essence_tax) parts += "[round(essence_tax, 0.1)] Arcane Essence"
	var/reason_text = normalizeNexusLeagueInlineText(reason, 80)
	if(!reason_text) reason_text = "income"
	src << "<font color=#e7bd72>[control.controller_league_name] withheld [jointext(parts, " and ")] in [control.planet_name] taxes from your [reason_text]."

mob/proc/getNexusPlanetTaxRemainder(datum/NexusPlanetControl/control, currency)
	if(!control) return 0
	var/rate = currency == "resources" ? control.resource_tax_rate : control.essence_tax_rate
	var/remainder_key = "[control.planet_id]|[control.ownership_revision]|[rate]"
	var/list/remainders
	if(currency == "resources")
		if(!islist(nexus_planet_resource_tax_remainders)) nexus_planet_resource_tax_remainders = list()
		remainders = nexus_planet_resource_tax_remainders
	else
		if(!islist(nexus_planet_essence_tax_remainders)) nexus_planet_essence_tax_remainders = list()
		remainders = nexus_planet_essence_tax_remainders
	var/remainder = remainders[remainder_key]
	return nexusIsFiniteNumber(remainder) && remainder > 0 ? remainder : 0

mob/proc/setNexusPlanetTaxRemainder(datum/NexusPlanetControl/control, currency, remainder)
	if(!control || !nexusIsFiniteNumber(remainder)) return FALSE
	var/rate = currency == "resources" ? control.resource_tax_rate : control.essence_tax_rate
	var/remainder_key = "[control.planet_id]|[control.ownership_revision]|[rate]"
	var/list/remainders
	if(currency == "resources")
		if(!islist(nexus_planet_resource_tax_remainders)) nexus_planet_resource_tax_remainders = list()
		remainders = nexus_planet_resource_tax_remainders
	else
		if(!islist(nexus_planet_essence_tax_remainders)) nexus_planet_essence_tax_remainders = list()
		remainders = nexus_planet_essence_tax_remainders
	var/list/stale_keys = list()
	var/planet_key_prefix = "[control.planet_id]|"
	for(var/old_key in remainders)
		if(old_key != remainder_key && findtext("[old_key]", planet_key_prefix) == 1) stale_keys += old_key
	if(stale_keys.len) remainders -= stale_keys
	remainder = max(0, round(remainder, 0.000001))
	if(remainder) remainders[remainder_key] = remainder
	else remainders -= remainder_key
	return TRUE

mob/proc/applyNexusPlanetaryIncomeTax(resource_gross = 0, essence_gross = 0, reason = "income", datum/NexusPlanetControl/control_override)
	if(!nexusIsFiniteNumber(resource_gross) || resource_gross < 0) resource_gross = 0
	if(!nexusIsFiniteNumber(essence_gross) || essence_gross < 0) essence_gross = 0
	essence_gross = round(essence_gross, 0.1)
	var/list/result = list(
		"resource_gross" = resource_gross,
		"resource_tax" = 0,
		"resource_net" = resource_gross,
		"essence_gross" = essence_gross,
		"essence_tax" = 0,
		"essence_net" = essence_gross
	)
	var/datum/NexusPlanetControl/control = control_override
	if(!control) control = getCurrentNexusPlanetControl()
	if(!control || !control.isClaimed() || control.isAbandoned() || isNexusPlanetaryTaxExempt(control)) return result
	var/resource_tax = 0
	if(resource_gross > 0 && control.resource_tax_rate > 0)
		var/resource_exact_tax = resource_gross * control.resource_tax_rate / 100 + getNexusPlanetTaxRemainder(control, "resources")
		var/resource_collectable_tax = floor((resource_exact_tax + 0.0000000001) * 1000000) / 1000000
		var/resource_collectable_gross = floor((resource_gross + 0.0000000001) * 1000000) / 1000000
		resource_tax = min(resource_collectable_gross, resource_collectable_tax)
		setNexusPlanetTaxRemainder(control, "resources", resource_exact_tax - resource_tax)
	var/essence_tax = 0
	if(essence_gross > 0 && control.essence_tax_rate > 0)
		var/essence_exact_tax = essence_gross * control.essence_tax_rate / 100 + getNexusPlanetTaxRemainder(control, "essence")
		essence_tax = min(essence_gross, floor((essence_exact_tax + 0.0000001) * 10) / 10)
		setNexusPlanetTaxRemainder(control, "essence", essence_exact_tax - essence_tax)
	result["resource_tax"] = resource_tax
	result["resource_net"] = resource_gross - resource_tax
	result["essence_tax"] = essence_tax
	result["essence_net"] = round(essence_gross - essence_tax, 0.1)
	if(resource_tax || essence_tax)
		control.resource_treasury = round(control.resource_treasury + resource_tax, 0.000001)
		control.essence_treasury = round(control.essence_treasury + essence_tax, 0.1)
		control.state_revision++
		nexus_planet_controls_dirty = TRUE
		notifyNexusPlanetaryTax(control, resource_tax, essence_tax, reason)
	return result

mob/proc/gainNexusResources(amount, reason = "resource income")
	if(!nexusIsFiniteNumber(amount) || amount <= 0 || !GetResourceObject()) return 0
	var/list/tax_result = applyNexusPlanetaryIncomeTax(resource_gross = amount, reason = reason)
	var/net_amount = tax_result["resource_net"]
	Alter_Res(net_amount)
	return net_amount

mob/proc/collectNexusResourceBag(obj/Resources/resource_bag, reason = "collected resources")
	if(!resource_bag || !nexusIsFiniteNumber(resource_bag.Value) || resource_bag.Value <= 0 || !GetResourceObject()) return 0
	var/amount = resource_bag.Value
	var/exempt_amount = nexusIsFiniteNumber(resource_bag.nexus_tax_exempt_value) ? Clamp(resource_bag.nexus_tax_exempt_value, 0, amount) : 0
	var/taxable_amount = max(0, amount - exempt_amount)
	var/credited = 0
	if(exempt_amount) credited += Alter_Res(exempt_amount)
	if(taxable_amount) credited += gainNexusResources(taxable_amount, reason)
	resource_bag.Value = 0
	resource_bag.nexus_tax_exempt_value = 0
	return credited

mob/proc/absorbNexusResourceBagBalance(obj/Resources/resource_bag)
	var/obj/Resources/balance = GetResourceObject()
	if(!balance || !resource_bag || !nexusIsFiniteNumber(resource_bag.Value) || resource_bag.Value <= 0) return 0
	var/amount = resource_bag.Value
	var/exempt_amount = nexusIsFiniteNumber(resource_bag.nexus_tax_exempt_value) ? Clamp(resource_bag.nexus_tax_exempt_value, 0, amount) : 0
	Alter_Res(amount)
	balance.nexus_tax_exempt_value = Clamp(balance.nexus_tax_exempt_value + exempt_amount, 0, balance.Value)
	resource_bag.Value = 0
	resource_bag.nexus_tax_exempt_value = 0
	return amount

mob/proc/dropNexusResourceBalance(turf/drop_location)
	var/obj/Resources/balance = GetResourceObject()
	if(!balance || balance.Value <= 0 || !drop_location) return null
	var/amount = balance.Value
	var/obj/Resources/resource_bag = GetCachedObject(/obj/Resources, drop_location)
	resource_bag.Value = amount
	resource_bag.nexus_tax_exempt_value = Clamp(balance.nexus_tax_exempt_value, 0, amount)
	resource_bag.Update_value()
	Alter_Res(-amount)
	balance.nexus_tax_exempt_value = 0
	return resource_bag

proc/announceNexusPlanetControl(datum/NexusPlanetControl/control, message, global_announcement = FALSE)
	if(!control || !message) return
	if(global_announcement)
		world << message
		return
	for(var/mob/player in players)
		if(getNexusPlanetControlId(player) == control.planet_id) player << message

proc/announceNexusLeagueControl(league_id, message)
	if(!league_id || !message) return
	for(var/mob/player in players)
		if(player.hasNexusLeagueMembership(league_id)) player << message

proc/syncNexusBraalControlRuler()
	var/datum/NexusPlanetControl/braal_control = getNexusPlanetControl("braal", FALSE)
	king_of_Braal = braal_control && braal_control.isClaimed() && !braal_control.isAbandoned() ? braal_control.holder_key : null
	for(var/mob/player in players) player.CheckKingOfBraalVerbs()

proc/materializeExpiredNexusPlanetControls(persist = FALSE)
	initializeNexusPlanetControls()
	var/materialized = FALSE
	for(var/planet_id in nexus_planet_controls)
		var/datum/NexusPlanetControl/control = nexus_planet_controls[planet_id]
		if(!control || !control.isClaimed() || control.abandoned_at || !control.isAbandoned()) continue
		control.orphanController()
		materialized = TRUE
	if(!materialized) return FALSE
	nexus_planet_controls_dirty = TRUE
	syncNexusBraalControlRuler()
	if(persist) saveNexusPlanetControls()
	return TRUE

mob/proc/refreshNexusPlanetControlPresence(persist = FALSE, materialize_expired = TRUE)
	if(!playerCharacter || Dead) return FALSE
	initializeNexusPlanetControls()
	var/updated = materialize_expired ? materializeExpiredNexusPlanetControls(persist = FALSE) : FALSE
	for(var/planet_id in nexus_planet_controls)
		var/datum/NexusPlanetControl/control = nexus_planet_controls[planet_id]
		if(control && control.isHolder(src) && hasNexusLeagueMembership(control.controller_league_id))
			control.holder_last_seen = world.realtime
			control.state_revision++
			updated = TRUE
	if(!updated) return FALSE
	nexus_planet_controls_dirty = TRUE
	if(persist) saveNexusPlanetControls()
	return TRUE

mob/proc/orphanNexusPlanetControlsOnDeath(persist = TRUE)
	if(!playerCharacter) return FALSE
	initializeNexusPlanetControls()
	var/orphaned = FALSE
	for(var/planet_id in nexus_planet_controls)
		var/datum/NexusPlanetControl/control = nexus_planet_controls[planet_id]
		if(control && control.isHolder(src))
			control.orphanController()
			orphaned = TRUE
	if(!orphaned) return FALSE
	nexus_planet_controls_dirty = TRUE
	syncNexusBraalControlRuler()
	if(persist) saveNexusPlanetControls()
	return TRUE

proc/releaseNexusPlanetControlsForCharacter(character_key, character_slot, persist = TRUE)
	var/account_id = ckey(character_key)
	if(!account_id) return FALSE
	initializeNexusPlanetControls()
	character_slot = clampNexusCharacterSlot(character_slot)
	var/released = FALSE
	for(var/planet_id in nexus_planet_controls)
		var/datum/NexusPlanetControl/control = nexus_planet_controls[planet_id]
		if(!control || !control.isClaimed()) continue
		if(control.holder_account_id == account_id && control.holder_slot == character_slot)
			control.orphanController()
			released = TRUE
	if(!released) return FALSE
	nexus_planet_controls_dirty = TRUE
	syncNexusBraalControlRuler()
	if(persist) saveNexusPlanetControls()
	return TRUE

mob/proc/canNexusPlanetControlHolderDepartLeague(league_id)
	if(!league_id) return TRUE
	for(var/datum/NexusPlanetControl/control in getNexusPlanetControlsHeldBy(src))
		if(control.controller_league_id == league_id && (KO || Dead)) return FALSE
	return TRUE

mob/proc/orphanNexusPlanetControlForLeagueDeparture(league_id, persist = TRUE, announce = TRUE)
	if(!league_id) return FALSE
	initializeNexusPlanetControls()
	var/updated = FALSE
	for(var/planet_id in nexus_planet_controls)
		var/datum/NexusPlanetControl/control = nexus_planet_controls[planet_id]
		if(control && control.controller_league_id == league_id && control.isHolder(src))
			var/former_holder_name = control.holder_name
			control.orphanController()
			if(announce) announceNexusPlanetControl(control, "<font color=#e7bd72>[former_holder_name] left [control.controller_league_name]. [control.planet_name]'s control is now abandoned and may be claimed.", global_announcement = TRUE)
			updated = TRUE
	if(!updated) return FALSE
	nexus_planet_controls_dirty = TRUE
	syncNexusBraalControlRuler()
	if(persist) saveNexusPlanetControls()
	return TRUE

proc/resetNexusPlanetControls(persist = TRUE)
	nexus_planet_controls = list()
	initializeNexusPlanetControls()
	nexus_planet_controls_dirty = TRUE
	syncNexusBraalControlRuler()
	if(persist) saveNexusPlanetControls()
	return TRUE

mob/proc/claimNexusPlanetControl(obj/League/league, announce = TRUE, persist = TRUE, allow_abandoned = FALSE)
	if(!league || league.loc != src || league.league_rank < NEXUS_PLANET_CONTROL_CLAIM_RANK || !league.league_id) return FALSE
	if(KO || rp_mode || Dead || !playerCharacter) return FALSE
	var/datum/NexusPlanetControl/control = getCurrentNexusPlanetControl()
	if(!control) return FALSE
	var/replacing_abandoned_control = control.isClaimed()
	if(replacing_abandoned_control && (!allow_abandoned || !control.isAbandoned())) return FALSE
	if(!control.setController(src, league, reset_taxes = TRUE)) return FALSE
	nexus_planet_controls_dirty = TRUE
	if(control.planet_id == "braal") syncNexusBraalControlRuler()
	if(persist) saveNexusPlanetControls()
	if(announce)
		var/action_text = replacing_abandoned_control ? "claimed the abandoned control of" : "now rules"
		announceNexusPlanetControl(control, "<font color=#ffd36a><font size=3>[control.controller_league_name], represented by [control.holder_name], [action_text] [control.planet_name].", global_announcement = TRUE)
	return TRUE

mob/proc/getNexusPlanetControlSeizureError(mob/target, datum/NexusPlanetControl/control, obj/League/league, expected_ownership_revision)
	if(!target || target == src) return "There is no valid ruler to defeat."
	if(!playerCharacter || KO || rp_mode || Dead) return "You cannot seize control in your current state."
	if(tournament_override(fighters_can = 0, show_message = 0)) return "Planetary control cannot be seized during a tournament."
	if(!target.playerCharacter || target.Dead || !target.KO) return "The ruler is no longer an eligible knocked-out character."
	target.normalizeWillpower()
	if(target.willpower > 0) return "The ruler still has Willpower."
	if(Safezone || target.Safezone) return "Planetary control cannot be seized in a safe zone."
	if(!control || !control.isClaimed() || !control.isHolder(target)) return "That character no longer holds this control point."
	if(!isnull(expected_ownership_revision) && control.ownership_revision != expected_ownership_revision) return "The control point changed hands before you could seize it."
	var/turf/actor_turf = base_loc()
	var/turf/target_turf = target.base_loc()
	if(!actor_turf || !target_turf || actor_turf.z != target_turf.z || getdist(actor_turf, target_turf) > 1 || !viewable(actor_turf, target_turf, 1, 0)) return "You must remain beside the defeated ruler."
	if(hasNexusLeagueMembership(control.controller_league_id)) return "Members of the ruling league cannot seize its point for another league."
	if(!league || league.loc != src || !league.league_id || league.league_id == control.controller_league_id) return "Your selected league is no longer eligible."
	return null

mob/proc/seizeNexusPlanetControl(mob/target, datum/NexusPlanetControl/control, obj/League/league, expected_ownership_revision, announce = TRUE, persist = TRUE)
	if(!control || control.capture_locked) return FALSE
	control.capture_locked = TRUE
	var/error = getNexusPlanetControlSeizureError(target, control, league, expected_ownership_revision)
	if(error)
		control.capture_locked = FALSE
		if(client) src << error
		return FALSE
	var/old_league_id = control.controller_league_id
	var/old_league_name = control.controller_league_name
	var/old_holder_name = control.holder_name
	if(!control.setController(src, league, reset_taxes = TRUE))
		control.capture_locked = FALSE
		return FALSE
	control.capture_locked = FALSE
	nexus_planet_controls_dirty = TRUE
	if(control.planet_id == "braal") syncNexusBraalControlRuler()
	if(persist) saveNexusPlanetControls()
	if(announce)
		var/message = "<font color=#ff9b68><font size=3>[src] seized [control.planet_name] from [old_holder_name] of [old_league_name]. [control.controller_league_name] now rules the planet."
		announceNexusPlanetControl(control, message, global_announcement = TRUE)
		world.log << "PLANET_CONTROL: planet=[control.planet_id] old_league=[old_league_id] new_league=[control.controller_league_id] old_holder=[old_holder_name] new_holder=[control.holder_name]"
	return TRUE

mob/proc/promptNexusPlanetControlSeizure(mob/target)
	if(!client || !playerCharacter || !target || !target.KO || target.Dead) return FALSE
	target.normalizeWillpower()
	if(target.willpower > 0) return FALSE
	var/list/eligible_controls = list()
	for(var/datum/NexusPlanetControl/held_control in getNexusPlanetControlsHeldBy(target))
		if(!hasNexusLeagueMembership(held_control.controller_league_id)) eligible_controls += held_control
	if(!eligible_controls.len) return FALSE
	var/datum/NexusPlanetControl/control
	if(eligible_controls.len == 1)
		control = eligible_controls[1]
	else
		var/list/control_options = list("Cancel")
		var/list/controls_by_option = list()
		for(var/datum/NexusPlanetControl/held_control in eligible_controls)
			var/option = "[held_control.planet_name] — [held_control.controller_league_name]"
			while(controls_by_option[option]) option += " #"
			control_options += option
			controls_by_option[option] = held_control
		var/control_choice = input(src, "Which control point will you seize from [target]?", "Planetary Control") in control_options
		if(!control_choice || control_choice == "Cancel") return TRUE
		control = controls_by_option[control_choice]
	if(!control || !control.isHolder(target)) return TRUE
	var/list/leagues = getNexusControlLeagueChoices(control.controller_league_id)
	if(!leagues.len) return FALSE
	if(tournament_override(fighters_can = 0)) return TRUE
	var/expected_revision = control.ownership_revision
	var/action
	if(target.client) action = alert(src, "[target] has no Willpower and carries [control.planet_name]'s control point for [control.controller_league_name].", "Planetary Control", "Seize", "Loot", "Cancel")
	else action = alert(src, "[target] has no Willpower and carries [control.planet_name]'s control point for [control.controller_league_name].", "Planetary Control", "Seize", "Cancel")
	if(action == "Loot") return FALSE
	if(action != "Seize") return TRUE
	var/obj/League/selected_league
	if(leagues.len == 1)
		selected_league = leagues[1]
	else
		var/list/options = list("Cancel")
		var/list/leagues_by_option = list()
		for(var/obj/League/league in leagues)
			var/option = "[normalizeNexusLeagueInlineText(league.name, NEXUS_LEAGUE_NAME_LIMIT)] (rank [league.league_rank])"
			while(leagues_by_option[option]) option += " #"
			options += option
			leagues_by_option[option] = league
		var/league_choice = input(src, "Which league will rule [control.planet_name]?", "Seize Control") in options
		if(!league_choice || league_choice == "Cancel") return TRUE
		selected_league = leagues_by_option[league_choice]
	if(alert(src, "Seize [control.planet_name] for [selected_league]? Existing tax rates will be cleared; the captured treasury remains with the point.", "Confirm Conquest", "Cancel", "Seize") != "Seize") return TRUE
	seizeNexusPlanetControl(target, control, selected_league, expected_revision)
	return TRUE

mob/proc/canManageNexusPlanetControl(datum/NexusPlanetControl/control)
	if(!control || !control.isClaimed() || control.isAbandoned()) return FALSE
	var/obj/League/league = getNexusLeagueBadgeById(control.controller_league_id)
	if(!league) return FALSE
	return control.isHolder(src) || league.league_rank >= NEXUS_PLANET_CONTROL_OFFICER_RANK

mob/proc/setNexusPlanetControlTax(datum/NexusPlanetControl/control, currency, rate)
	if(!nexusIsFiniteNumber(rate) || !canManageNexusPlanetControl(control) || getNexusPlanetControlId(src) != control.planet_id) return FALSE
	rate = Clamp(round(rate, 0.1), 0, NEXUS_PLANET_TAX_MAX_PERCENT)
	if(currency == "resources") control.resource_tax_rate = rate
	else if(currency == "essence") control.essence_tax_rate = rate
	else return FALSE
	control.state_revision++
	nexus_planet_controls_dirty = TRUE
	saveNexusPlanetControls()
	announceNexusPlanetControl(control, "<font color=#e7bd72>[control.controller_league_name] set [currency == "resources" ? "the resource" : "the Arcane Essence"] income tax in [control.planet_name] to [rate]%.")
	return TRUE

mob/proc/withdrawNexusPlanetControlTreasury(datum/NexusPlanetControl/control, currency, amount)
	if(!nexusIsFiniteNumber(amount) || amount <= 0 || !canManageNexusPlanetControl(control) || getNexusPlanetControlId(src) != control.planet_id) return FALSE
	if(currency == "resources")
		amount = min(round(amount, 0.000001), control.resource_treasury)
		if(amount <= 0 || !GetResourceObject()) return FALSE
		control.resource_treasury -= amount
		Alter_Res(amount)
	else if(currency == "essence")
		amount = min(round(amount, 0.1), control.essence_treasury)
		if(amount <= 0) return FALSE
		control.essence_treasury = round(control.essence_treasury - amount, 0.1)
		arcane_essence = round(arcane_essence + amount, 0.1)
	else return FALSE
	control.state_revision++
	nexus_planet_controls_dirty = TRUE
	saveNexusPlanetControls()
	announceNexusLeagueControl(control.controller_league_id, "<font color=#e7bd72>[src] withdrew [currency == "resources" ? Commas(amount) : round(amount, 0.1)] [currency == "resources" ? "resources" : "Arcane Essence"] from [control.planet_name]'s treasury.")
	return TRUE

proc/getNexusPlanetControlStatusLine(datum/NexusPlanetControl/control, include_treasury = FALSE)
	if(!control) return "Unknown control point"
	if(!control.isClaimed()) return "[control.planet_name]: unclaimed"
	var/status
	if(control.isAbandoned()) status = "[control.planet_name]: abandoned and claimable — former ruler [control.controller_league_name]; taxation suspended"
	else status = "[control.planet_name]: [control.controller_league_name], governed by [control.holder_name] — Resources [control.resource_tax_rate]%, Arcane Essence [control.essence_tax_rate]%"
	if(include_treasury) status += " — Treasury [Commas(control.resource_treasury)] resources / [round(control.essence_treasury, 0.1)] essence"
	return status

mob/proc/showNexusPlanetControlOverview()
	initializeNexusPlanetControls()
	src << "<font color=#ffd36a><b>Planetary control points:</b>"
	var/list/manifest = getNexusPlanetMapRegionManifest()
	for(var/planet_id in manifest)
		var/datum/NexusPlanetControl/control = getNexusPlanetControl(planet_id, FALSE)
		src << getNexusPlanetControlStatusLine(control, control && hasNexusLeagueMembership(control.controller_league_id))

mob/proc/openNexusPlanetControlMenu()
	if(!client || !playerCharacter || usr != src) return
	initializeNexusPlanetControls()
	var/datum/NexusPlanetControl/control = getCurrentNexusPlanetControl()
	if(control) src << "<font color=#ffd36a>[getNexusPlanetControlStatusLine(control, hasNexusLeagueMembership(control.controller_league_id))]"
	else src << "There is no planetary control point in this area."
	var/list/options = list("Cancel", "View all control points")
	var/list/claim_leagues = list()
	var/control_is_claimable = control && (!control.isClaimed() || control.isAbandoned())
	if(control_is_claimable && !KO && !rp_mode && !Dead)
		claim_leagues = getNexusControlLeagueChoices(null, leaders_only = TRUE)
		if(claim_leagues.len) options += control.isClaimed() ? "Claim abandoned control point" : "Claim this control point"
	if(control && canManageNexusPlanetControl(control))
		options += "Set resource tax"
		options += "Set Arcane Essence tax"
		if(control.resource_treasury > 0) options += "Withdraw resources"
		if(control.essence_treasury > 0) options += "Withdraw Arcane Essence"
	if(Race == "Heran") options += heran_refuses_planetary_taxes ? "Pay planetary taxes" : "Refuse planetary taxes"
	var/choice = input(src, "Planetary control", "Control Point") in options
	switch(choice)
		if("View all control points")
			showNexusPlanetControlOverview()
		if("Claim this control point", "Claim abandoned control point")
			var/claiming_abandoned_control = control.isClaimed()
			var/obj/League/selected_league
			if(claim_leagues.len == 1) selected_league = claim_leagues[1]
			else
				var/list/league_options = list("Cancel")
				var/list/leagues_by_option = list()
				for(var/obj/League/league in claim_leagues)
					var/option = "[normalizeNexusLeagueInlineText(league.name, NEXUS_LEAGUE_NAME_LIMIT)] (rank [league.league_rank])"
					while(leagues_by_option[option]) option += " #"
					league_options += option
					leagues_by_option[option] = league
				var/league_choice = input(src, "Choose the league that will claim [control.planet_name].", "Claim Control") in league_options
				if(!league_choice || league_choice == "Cancel") return
				selected_league = leagues_by_option[league_choice]
			if(alert(src, "Claim [control.planet_name] for [selected_league]?", "Claim Control", "Cancel", "Claim") == "Claim") claimNexusPlanetControl(selected_league, allow_abandoned = claiming_abandoned_control)
		if("Set resource tax", "Set Arcane Essence tax")
			var/currency = choice == "Set resource tax" ? "resources" : "essence"
			var/current_rate = currency == "resources" ? control.resource_tax_rate : control.essence_tax_rate
			var/new_rate = input(src, "Set the [currency == "resources" ? "resource" : "Arcane Essence"] income tax (0-[NEXUS_PLANET_TAX_MAX_PERCENT]%).", "Tax Rate", current_rate) as null|num
			if(!isnull(new_rate)) setNexusPlanetControlTax(control, currency, new_rate)
		if("Withdraw resources", "Withdraw Arcane Essence")
			var/currency = choice == "Withdraw resources" ? "resources" : "essence"
			var/available = currency == "resources" ? control.resource_treasury : control.essence_treasury
			var/amount = input(src, "Withdraw how much? Available: [available].", "Planetary Treasury", available) as null|num
			if(!isnull(amount)) withdrawNexusPlanetControlTreasury(control, currency, amount)
		if("Refuse planetary taxes")
			if(Race != "Heran") return
			heran_refuses_planetary_taxes = TRUE
			src << "You will now refuse planetary taxes while you remain a Heran."
		if("Pay planetary taxes")
			if(Race != "Heran") return
			heran_refuses_planetary_taxes = FALSE
			src << "You will now pay planetary taxes normally."

mob/verb/Planetary_Control()
	set category = "Other"
	openNexusPlanetControlMenu()

proc/saveNexusPlanetControls(save_path = null)
	if(!save_path) save_path = getNexusPlanetControlSavePath()
	initializeNexusPlanetControls()
	var/savefile/control_save = new(save_path)
	control_save["version"] << NEXUS_PLANET_CONTROL_SAVE_VERSION
	var/list/manifest = getNexusPlanetMapRegionManifest()
	for(var/planet_id in manifest)
		var/datum/NexusPlanetControl/control = getNexusPlanetControl(planet_id, FALSE)
		if(!control) continue
		control.normalize()
		var/base_path = "controls/[planet_id]"
		control_save["[base_path]/controller_league_id"] << control.controller_league_id
		control_save["[base_path]/controller_league_name"] << control.controller_league_name
		control_save["[base_path]/controller_leader_key"] << control.controller_leader_key
		control_save["[base_path]/holder_account_id"] << control.holder_account_id
		control_save["[base_path]/holder_key"] << control.holder_key
		control_save["[base_path]/holder_slot"] << control.holder_slot
		control_save["[base_path]/holder_character_made_time"] << control.holder_character_made_time
		control_save["[base_path]/holder_name"] << control.holder_name
		control_save["[base_path]/holder_last_seen"] << control.holder_last_seen
		control_save["[base_path]/abandoned_at"] << control.abandoned_at
		control_save["[base_path]/resource_tax_rate"] << control.resource_tax_rate
		control_save["[base_path]/essence_tax_rate"] << control.essence_tax_rate
		control_save["[base_path]/resource_treasury"] << control.resource_treasury
		control_save["[base_path]/essence_treasury"] << control.essence_treasury
		control_save["[base_path]/captured_at"] << control.captured_at
		control_save["[base_path]/ownership_revision"] << control.ownership_revision
		control_save["[base_path]/state_revision"] << control.state_revision
	control_save.Flush()
	nexus_planet_controls_dirty = FALSE
	return TRUE

proc/loadNexusPlanetControls(save_path = null)
	if(!save_path) save_path = getNexusPlanetControlSavePath()
	var/list/loaded_controls = list()
	var/list/manifest = getNexusPlanetMapRegionManifest()
	var/savefile/control_save
	if(fexists(save_path)) control_save = new(save_path)
	var/control_save_version = 0
	if(control_save) control_save["version"] >> control_save_version
	for(var/planet_id in manifest)
		var/list/region = manifest[planet_id]
		var/datum/NexusPlanetControl/control = new(planet_id, region["planet_name"])
		if(control_save)
			var/base_path = "controls/[planet_id]"
			control_save["[base_path]/controller_league_id"] >> control.controller_league_id
			control_save["[base_path]/controller_league_name"] >> control.controller_league_name
			control_save["[base_path]/controller_leader_key"] >> control.controller_leader_key
			control_save["[base_path]/holder_account_id"] >> control.holder_account_id
			control_save["[base_path]/holder_key"] >> control.holder_key
			control_save["[base_path]/holder_slot"] >> control.holder_slot
			control_save["[base_path]/holder_character_made_time"] >> control.holder_character_made_time
			control_save["[base_path]/holder_name"] >> control.holder_name
			control_save["[base_path]/holder_last_seen"] >> control.holder_last_seen
			control_save["[base_path]/abandoned_at"] >> control.abandoned_at
			control_save["[base_path]/resource_tax_rate"] >> control.resource_tax_rate
			control_save["[base_path]/essence_tax_rate"] >> control.essence_tax_rate
			control_save["[base_path]/resource_treasury"] >> control.resource_treasury
			control_save["[base_path]/essence_treasury"] >> control.essence_treasury
			control_save["[base_path]/captured_at"] >> control.captured_at
			control_save["[base_path]/ownership_revision"] >> control.ownership_revision
			control_save["[base_path]/state_revision"] >> control.state_revision
		control.normalize()
		if(control.isClaimed() && (control_save_version < 2 || !control.holder_last_seen)) control.holder_last_seen = world.realtime
		loaded_controls[planet_id] = control
	nexus_planet_controls = loaded_controls
	nexus_planet_controls_dirty = FALSE
	syncNexusBraalControlRuler()
	return TRUE

proc/nexusPlanetControlSaveLoop()
	set waitfor = FALSE
	while(TRUE)
		sleep(3000)
		materializeExpiredNexusPlanetControls()
		for(var/mob/player in players) player.refreshNexusPlanetControlPresence(materialize_expired = FALSE)
		if(nexus_planet_controls_dirty) saveNexusPlanetControls()
