#define NEXUS_PLANET_MAP_SCAN_QUEUED "queued"
#define NEXUS_PLANET_MAP_SCAN_SCANNING "scanning"
#define NEXUS_PLANET_MAP_SCAN_READY "ready"
#define NEXUS_PLANET_MAP_SCAN_FAILED "failed"
#define NEXUS_PLANET_MAP_SCAN_ROWS_PER_YIELD 4
#define NEXUS_PLANET_MAP_SCAN_TICK_USAGE_LIMIT 35
#define NEXUS_PLANET_MAP_SCAN_TILE_USAGE_CHECK 128
#define NEXUS_PLANET_MAP_PHASE_QUEUED "queued"
#define NEXUS_PLANET_MAP_PHASE_RENDER "render"
#define NEXUS_PLANET_MAP_PHASE_COMPLETE "complete"
#define NEXUS_PLANET_MAP_PHASE_FAILED "failed"

var/list/nexus_planet_map_scan_cache = list()
var/list/nexus_planet_map_scan_queue = list()
var/datum/NexusPlanetMapScan/nexus_active_planet_map_scan
var/nexus_planet_map_scan_queue_running = FALSE
var/nexus_planet_map_scan_boot_token

client/var/tmp/list/nexus_planet_map_resource_tokens = list()

proc/getNexusPlanetMapBootToken()
	if(!nexus_planet_map_scan_boot_token)
		nexus_planet_map_scan_boot_token = md5("planet-map|[world.realtime]|[world.time]|[rand(1, 2147483647)]")
	return nexus_planet_map_scan_boot_token

proc/makeNexusPlanetMapRegion(region_id, planet_name, area_type, z_level, min_x, min_y, max_x, max_y)
	return list(
		"region_id" = "[region_id]",
		"planet_name" = "[planet_name]",
		"area_type" = area_type,
		"z_level" = z_level,
		"min_x" = min_x,
		"min_y" = min_y,
		"max_x" = max_x,
		"max_y" = max_y
	)

proc/getNexusPlanetMapRegionManifest()
	var/list/regions = list()
	regions["earth"] = makeNexusPlanetMapRegion("earth", "Earth", /area/Earth, 1, 1, 1, world.maxx, world.maxy)
	regions["namekian"] = makeNexusPlanetMapRegion("namekian", "Namekian", /area/Namekian, 3, 1, 1, world.maxx, world.maxy)
	regions["braal"] = makeNexusPlanetMapRegion("braal", "Braal", /area/Braal, 4, 1, 1, world.maxx, world.maxy)
	regions["atlantis"] = makeNexusPlanetMapRegion("atlantis", "Atlantis", /area/Atlantis, 11, 1, 1, 250, 250)
	regions["arconia"] = makeNexusPlanetMapRegion("arconia", "Arconia", /area/Arconia, 8, 1, 1, world.maxx, world.maxy)
	regions["ice"] = makeNexusPlanetMapRegion("ice", "Ice", /area/Ice, 12, 1, 1, world.maxx, world.maxy)
	regions["desert"] = makeNexusPlanetMapRegion("desert", "Desert", /area/Desert, 14, 1, 1, 250, 250)
	regions["jungle"] = makeNexusPlanetMapRegion("jungle", "Jungle", /area/Jungle, 14, 1, 251, 250, 500)
	regions["android"] = makeNexusPlanetMapRegion("android", "Android", /area/Android, 14, 251, 251, 500, 500)
	return regions

proc/getNexusPlanetMapRegion(region_id)
	region_id = lowertext("[region_id]")
	if(!length(region_id)) return null
	var/list/manifest = getNexusPlanetMapRegionManifest()
	var/list/region = manifest[region_id]
	return islist(region) ? region.Copy() : null

proc/resolveNexusPlanetMapRegion(z_level, area_type, player_x, player_y)
	if(!isnum(z_level) || z_level != round(z_level) || !ispath(area_type, /area) || !isnum(player_x) || !isnum(player_y)) return null
	var/list/manifest = getNexusPlanetMapRegionManifest()
	for(var/region_id in manifest)
		var/list/region = manifest[region_id]
		if(!islist(region) || region["z_level"] != z_level || region["area_type"] != area_type) continue
		if(player_x < region["min_x"] || player_x > region["max_x"] || player_y < region["min_y"] || player_y > region["max_y"]) continue
		return region.Copy()
	return null

proc/isNexusPlanetMapAreaType(area_type)
	if(!ispath(area_type, /area)) return FALSE
	var/list/manifest = getNexusPlanetMapRegionManifest()
	for(var/region_id in manifest)
		var/list/region = manifest[region_id]
		if(islist(region) && region["area_type"] == area_type) return TRUE
	return FALSE

proc/getNexusPlanetMapCacheKey(z_level, area_type, region_id)
	var/list/region
	if(region_id) region = getNexusPlanetMapRegion(region_id)
	else
		var/list/manifest = getNexusPlanetMapRegionManifest()
		for(var/candidate_id in manifest)
			var/list/candidate = manifest[candidate_id]
			if(islist(candidate) && candidate["z_level"] == z_level && candidate["area_type"] == area_type)
				region = candidate.Copy()
				break
	if(!islist(region) || region["z_level"] != z_level || region["area_type"] != area_type) return null
	var/resolved_region_id = region["region_id"]
	return "region:[resolved_region_id]|z:[z_level]|area:[area_type]"

proc/isValidNexusPlanetMapZ(z_level)
	if(!isnum(z_level)) return FALSE
	z_level = round(z_level)
	return z_level >= 1 && z_level <= world.maxz

proc/getNexusPlanetMapScan(z_level, area_type, region_id)
	var/cache_key = getNexusPlanetMapCacheKey(z_level, area_type, region_id)
	if(!cache_key) return null
	return nexus_planet_map_scan_cache[cache_key]

proc/getNexusPlanetMapQueuePosition(datum/NexusPlanetMapScan/scan)
	if(!scan) return 0
	if(scan == nexus_active_planet_map_scan) return 0
	var/position = nexus_planet_map_scan_queue.Find(scan)
	return position ? position : 0

proc/startNexusPlanetMapScanQueue()
	if(nexus_planet_map_scan_queue_running) return
	nexus_planet_map_scan_queue_running = TRUE
	spawn(0) processNexusPlanetMapScanQueue()

proc/processNexusPlanetMapScanQueue()
	set waitfor = FALSE
	while(nexus_planet_map_scan_queue.len)
		var/datum/NexusPlanetMapScan/scan = nexus_planet_map_scan_queue[1]
		nexus_planet_map_scan_queue.Cut(1, 2)
		if(!scan || scan.status != NEXUS_PLANET_MAP_SCAN_QUEUED) continue
		nexus_active_planet_map_scan = scan
		try
			scan.scanMap()
		catch(var/exception/scan_error)
			scan.fail("The map image could not be generated.")
			world.log << "Planet map scan failed for z=[scan.z_level]: [scan_error]"
		nexus_active_planet_map_scan = null
		sleep(world.tick_lag)
	nexus_planet_map_scan_queue_running = FALSE

proc/getNexusPlanetMapFallbackColor(turf/target)
	if(!target) return "#07090d"
	var/type_name = lowertext("[target.type]")
	if(findtext(type_name, "space") || findtext(type_name, "star")) return "#070b18"
	if(findtext(type_name, "water") || findtext(type_name, "ocean") || findtext(type_name, "river")) return "#245c78"
	if(findtext(type_name, "lava") || findtext(type_name, "magma") || findtext(type_name, "hell")) return "#8d2e1e"
	if(findtext(type_name, "snow") || findtext(type_name, "ice")) return "#b7d5d9"
	if(findtext(type_name, "sand") || findtext(type_name, "desert")) return "#b99655"
	if(findtext(type_name, "grass") || findtext(type_name, "jungle") || findtext(type_name, "plant")) return "#3f7244"
	if(findtext(type_name, "dirt") || findtext(type_name, "mud")) return "#72533a"
	if(findtext(type_name, "floor") || findtext(type_name, "tile")) return "#77736b"
	if(target.density) return "#4b4440"
	return "#303b31"

proc/getNexusPlanetMapTurfAppearanceKey(turf/target)
	if(!target) return "null"
	return "[target.type]|[target.icon]|[target.icon_state]|[target.dir]|[target.color]|[target.alpha]|[target.density]"

proc/getNexusPlanetMapTurfColor(turf/target, datum/NexusPlanetMapScan/scan)
	if(!target) return "#07090d"
	var/appearance_key = getNexusPlanetMapTurfAppearanceKey(target)
	var/cached_color = scan ? scan.turf_color_cache[appearance_key] : null
	if(cached_color) return cached_color
	var/map_color
	if(target.icon)
		try
			var/icon/turf_frame = icon(target.icon, target.icon_state, target.dir, 1, FALSE)
			if(istext(target.color) && length(target.color)) turf_frame.Blend(target.color, ICON_MULTIPLY)
			var/frame_width = max(1, turf_frame.Width())
			var/frame_height = max(1, turf_frame.Height())
			var/center_x = max(1, round(frame_width / 2))
			var/center_y = max(1, round(frame_height / 2))
			var/pixel_color = turf_frame.GetPixel(center_x, center_y)
			if(!pixel_color) pixel_color = turf_frame.GetPixel(max(1, round(frame_width / 4)), max(1, round(frame_height / 4)))
			if(!pixel_color) pixel_color = turf_frame.GetPixel(min(frame_width, round(frame_width * 0.75)), min(frame_height, round(frame_height * 0.75)))
			if(!pixel_color) pixel_color = turf_frame.GetPixel(max(1, round(frame_width / 4)), min(frame_height, round(frame_height * 0.75)))
			if(!pixel_color) pixel_color = turf_frame.GetPixel(min(frame_width, round(frame_width * 0.75)), max(1, round(frame_height / 4)))
			if(pixel_color)
				var/list/color_channels = rgb2num(pixel_color)
				if(color_channels && color_channels.len >= 3) map_color = rgb(color_channels[1], color_channels[2], color_channels[3])
		catch(var/exception)
			if(exception) map_color = null
	if(!map_color) map_color = getNexusPlanetMapFallbackColor(target)
	if(scan)
		scan.turf_color_cache[appearance_key] = map_color
		scan.unique_appearances = scan.turf_color_cache.len
	return map_color

proc/getNexusPlanetMapScanStats(z_level, area_type, region_id)
	var/datum/NexusPlanetMapScan/scan = getNexusPlanetMapScan(z_level, area_type, region_id)
	if(!scan) return null
	return scan.buildStats()

datum/NexusPlanetMapScan
	var/z_level
	var/area_type
	var/area_name
	var/planet_name
	var/region_id
	var/cache_key
	var/status = NEXUS_PLANET_MAP_SCAN_QUEUED
	var/phase = NEXUS_PLANET_MAP_PHASE_QUEUED
	var/icon/map_icon
	var/resource_name
	var/scan_id
	var/error_message
	var/min_x = 1
	var/min_y = 1
	var/max_x
	var/max_y
	var/render_tiles_scanned = 0
	var/render_total_tiles = 0
	var/matching_tiles = 0
	var/tiles_scanned = 0
	var/total_tiles = 0
	var/rows_scanned = 0
	var/yield_count = 0
	var/unique_appearances = 0
	var/peak_tick_usage = 0
	var/started_at = 0
	var/completed_at = 0
	var/elapsed_deciseconds = 0
	var/list/turf_color_cache = list()
	var/list/requesters = list()

	New(list/target_region)
		. = ..()
		if(!islist(target_region)) return
		region_id = target_region["region_id"]
		planet_name = target_region["planet_name"]
		z_level = target_region["z_level"]
		area_type = target_region["area_type"]
		area_name = isNexusPlanetMapAreaType(area_type) ? "[initial(area_type:name)]" : "Unknown"
		cache_key = getNexusPlanetMapCacheKey(z_level, area_type, region_id)
		min_x = target_region["min_x"]
		min_y = target_region["min_y"]
		max_x = target_region["max_x"]
		max_y = target_region["max_y"]
		render_total_tiles = max(0, max_x - min_x + 1) * max(0, max_y - min_y + 1)
		total_tiles = render_total_tiles
		var/region_hash = md5("[region_id]|[area_type]")
		scan_id = "[getNexusPlanetMapBootToken()]-z[z_level]-r[region_hash]"
		resource_name = "nexus_planet_map_[scan_id].png"

	proc/addRequester(mob/viewer)
		if(viewer && viewer.client && !(viewer in requesters)) requesters += viewer

	proc/removeRequester(mob/viewer)
		if(viewer) requesters -= viewer

	proc/updateElapsed()
		if(!started_at) return
		var/end_time = completed_at ? completed_at : world.time
		elapsed_deciseconds = max(0, end_time - started_at)

	proc/recordTickUsage()
		peak_tick_usage = max(peak_tick_usage, world.tick_usage)

	proc/yieldScan()
		recordTickUsage()
		yield_count++
		updateElapsed()
		sleep(world.tick_lag)

	proc/scanMap()
		if(status != NEXUS_PLANET_MAP_SCAN_QUEUED) return FALSE
		var/list/region = getNexusPlanetMapRegion(region_id)
		if(!islist(region) || region["z_level"] != z_level || region["area_type"] != area_type || !cache_key || !render_total_tiles || min_x < 1 || min_y < 1 || max_x > world.maxx || max_y > world.maxy)
			fail("This location does not have a scannable map.")
			return FALSE
		status = NEXUS_PLANET_MAP_SCAN_SCANNING
		started_at = world.time
		if(!started_at) started_at = 0.001
		if(!renderMap()) return FALSE
		completed_at = world.time
		updateElapsed()
		phase = NEXUS_PLANET_MAP_PHASE_COMPLETE
		status = NEXUS_PLANET_MAP_SCAN_READY
		notifyRequesters(TRUE)
		return TRUE

	proc/renderMap()
		phase = NEXUS_PLANET_MAP_PHASE_RENDER
		var/icon/canvas = icon('UserNamesBarsUi.png')
		canvas.Scale(max_x - min_x + 1, max_y - min_y + 1)
		canvas.DrawBox("#07090d", 1, 1, max_x - min_x + 1, max_y - min_y + 1)
		var/rows_since_yield = 0
		for(var/map_y = min_y, map_y <= max_y, map_y++)
			var/run_start = min_x
			var/run_color
			for(var/map_x = min_x, map_x <= max_x, map_x++)
				var/turf/target = locate(map_x, map_y, z_level)
				var/area/target_area = target ? target.loc : null
				var/matches_area = target_area && target_area.type == area_type
				if(matches_area) matching_tiles++
				var/tile_color = matches_area ? getNexusPlanetMapTurfColor(target, src) : "#07090d"
				if(!run_color)
					run_color = tile_color
					run_start = map_x
				else if(tile_color != run_color)
					canvas.DrawBox(run_color, run_start - min_x + 1, map_y - min_y + 1, map_x - min_x, map_y - min_y + 1)
					run_color = tile_color
					run_start = map_x
				render_tiles_scanned++
				tiles_scanned = render_tiles_scanned
				if(!(render_tiles_scanned % NEXUS_PLANET_MAP_SCAN_TILE_USAGE_CHECK) && world.tick_usage >= NEXUS_PLANET_MAP_SCAN_TICK_USAGE_LIMIT) yieldScan()
			if(run_color) canvas.DrawBox(run_color, run_start - min_x + 1, map_y - min_y + 1, max_x - min_x + 1, map_y - min_y + 1)
			rows_scanned++
			rows_since_yield++
			recordTickUsage()
			if(rows_since_yield >= NEXUS_PLANET_MAP_SCAN_ROWS_PER_YIELD || world.tick_usage >= NEXUS_PLANET_MAP_SCAN_TICK_USAGE_LIMIT)
				rows_since_yield = 0
				yieldScan()
		if(!matching_tiles)
			fail("No planetary surface was found for [planet_name] in its configured region.")
			return FALSE
		map_icon = canvas
		return TRUE

	proc/fail(message)
		map_icon = null
		error_message = message ? "[message]" : "The map scan failed."
		completed_at = world.time
		updateElapsed()
		phase = NEXUS_PLANET_MAP_PHASE_FAILED
		status = NEXUS_PLANET_MAP_SCAN_FAILED
		notifyRequesters(FALSE)

	proc/notifyRequesters(success)
		for(var/mob/viewer in requesters)
			var/turf/viewer_turf = viewer ? viewer.base_loc() : null
			var/area/viewer_area = viewer_turf ? viewer_turf.loc : null
			var/list/viewer_region = viewer_turf && viewer_area ? resolveNexusPlanetMapRegion(viewer_turf.z, viewer_area.type, viewer_turf.x, viewer_turf.y) : null
			if(!viewer || !viewer.client || !islist(viewer_region) || viewer_region["region_id"] != region_id) continue
			if(success) viewer << "Planet map scan complete. Open or refresh the map to view it."
			else viewer << "The planet map scanner could not generate an image for this location."
		requesters.Cut()

	proc/buildStats()
		updateElapsed()
		var/progress = total_tiles ? min(100, round(tiles_scanned * 100 / total_tiles, 0.1)) : 0
		var/elapsed_seconds = elapsed_deciseconds / 10
		var/elapsed_ticks = world.tick_lag > 0 ? round(elapsed_deciseconds / world.tick_lag) : 0
		var/tiles_per_second = elapsed_seconds > 0 ? round(tiles_scanned / elapsed_seconds) : 0
		var/status_message
		switch(status)
			if(NEXUS_PLANET_MAP_SCAN_QUEUED) status_message = "Waiting for the planet scanner."
			if(NEXUS_PLANET_MAP_SCAN_SCANNING) status_message = "Rendering [planet_name] terrain: [progress]%"
			if(NEXUS_PLANET_MAP_SCAN_READY) status_message = "Terrain scan complete."
			if(NEXUS_PLANET_MAP_SCAN_FAILED) status_message = error_message
		return list(
			"status" = status,
			"phase" = phase,
			"z_level" = z_level,
			"planet_id" = cache_key,
			"region_id" = region_id,
			"planet_name" = planet_name,
			"area_type" = "[area_type]",
			"progress" = progress,
			"tiles_scanned" = tiles_scanned,
			"total_tiles" = total_tiles,
			"total" = total_tiles,
			"render_tiles_scanned" = render_tiles_scanned,
			"render_total_tiles" = render_total_tiles,
			"matching_tiles" = matching_tiles,
			"rows_scanned" = rows_scanned,
			"total_rows" = max_y - min_y + 1,
			"elapsed_deciseconds" = elapsed_deciseconds,
			"elapsed_ticks" = elapsed_ticks,
			"elapsed_ms" = elapsed_deciseconds * 100,
			"elapsed_seconds" = elapsed_seconds,
			"tiles_per_second" = tiles_per_second,
			"yield_count" = yield_count,
			"unique_appearances" = unique_appearances,
			"peak_tick_usage" = round(peak_tick_usage, 0.1),
			"queue_position" = getNexusPlanetMapQueuePosition(src),
			"scan_id" = scan_id,
			"image_revision" = scan_id,
			"message" = status_message,
			"resource_name" = status == NEXUS_PLANET_MAP_SCAN_READY ? resource_name : null,
			"error" = error_message
		)

mob/proc/requestNexusPlanetMapScan()
	var/turf/player_turf = base_loc()
	var/area/player_area = player_turf ? player_turf.loc : null
	var/list/region = player_turf && player_area ? resolveNexusPlanetMapRegion(player_turf.z, player_area.type, player_turf.x, player_turf.y) : null
	if(!islist(region)) return getNexusPlanetMapUiState()
	var/cache_key = getNexusPlanetMapCacheKey(region["z_level"], region["area_type"], region["region_id"])
	var/datum/NexusPlanetMapScan/scan = nexus_planet_map_scan_cache[cache_key]
	if(!scan || scan.status == NEXUS_PLANET_MAP_SCAN_FAILED)
		if(scan)
			nexus_planet_map_scan_queue -= scan
			scan.requesters.Cut()
		scan = new(region)
		nexus_planet_map_scan_cache[cache_key] = scan
		nexus_planet_map_scan_queue += scan
		scan.addRequester(src)
		startNexusPlanetMapScanQueue()
	else if(scan.status == NEXUS_PLANET_MAP_SCAN_QUEUED || scan.status == NEXUS_PLANET_MAP_SCAN_SCANNING)
		scan.addRequester(src)
	return getNexusPlanetMapUiState()

mob/proc/cancelNexusPlanetMapScanRequest()
	var/turf/player_turf = base_loc()
	var/area/player_area = player_turf ? player_turf.loc : null
	var/list/region = player_turf && player_area ? resolveNexusPlanetMapRegion(player_turf.z, player_area.type, player_turf.x, player_turf.y) : null
	var/datum/NexusPlanetMapScan/scan = islist(region) ? getNexusPlanetMapScan(region["z_level"], region["area_type"], region["region_id"]) : null
	if(scan) scan.removeRequester(src)
	return TRUE

mob/proc/getNexusPlanetMapUiState()
	var/turf/player_turf = base_loc()
	var/area/player_area = player_turf ? player_turf.loc : null
	var/area_name = player_area ? "[player_area.name]" : "Unknown"
	var/list/region = player_turf && player_area ? resolveNexusPlanetMapRegion(player_turf.z, player_area.type, player_turf.x, player_turf.y) : null
	var/scannable_area = islist(region)
	var/planet_id = scannable_area ? getNexusPlanetMapCacheKey(region["z_level"], region["area_type"], region["region_id"]) : null
	var/region_planet_name = scannable_area ? region["planet_name"] : null
	var/planet_name = scannable_area ? "[region_planet_name]" : area_name
	var/minimum_x = scannable_area ? region["min_x"] : 1
	var/minimum_y = scannable_area ? region["min_y"] : 1
	var/maximum_x = scannable_area ? region["max_x"] : world.maxx
	var/maximum_y = scannable_area ? region["max_y"] : world.maxy
	var/region_total_tiles = (maximum_x - minimum_x + 1) * (maximum_y - minimum_y + 1)
	var/list/state = list(
		"available" = FALSE,
		"status" = "idle",
		"cache_scope" = "region-manifest",
		"area_name" = area_name,
		"planet_name" = planet_name,
		"name" = planet_name,
		"z_level" = player_turf ? player_turf.z : 0,
		"planet_id" = planet_id,
		"player_x" = player_turf ? player_turf.x : 0,
		"player_y" = player_turf ? player_turf.y : 0,
		"min_x" = minimum_x,
		"min_y" = minimum_y,
		"max_x" = maximum_x,
		"max_y" = maximum_y,
		"map_width" = maximum_x - minimum_x + 1,
		"map_height" = maximum_y - minimum_y + 1,
		"progress" = 0,
		"tiles_scanned" = 0,
		"total_tiles" = region_total_tiles,
		"resource_name" = null,
		"map_icon" = null,
		"image" = null,
		"image_revision" = null,
		"phase" = "idle",
		"message" = scannable_area ? "Ready to scan this location." : "A planetary map is not available in this location.",
		"error" = null
	)
	if(!player_turf || !isValidNexusPlanetMapZ(player_turf.z) || !scannable_area)
		state["error"] = "This location does not have a scannable map."
		return state
	state["available"] = TRUE
	var/datum/NexusPlanetMapScan/scan = getNexusPlanetMapScan(region["z_level"], region["area_type"], region["region_id"])
	if(!scan) return state
	var/list/stats = scan.buildStats()
	for(var/stat_name in stats) state[stat_name] = stats[stat_name]
	state["min_x"] = scan.min_x
	state["min_y"] = scan.min_y
	state["max_x"] = scan.max_x
	state["max_y"] = scan.max_y
	state["map_width"] = scan.min_x && scan.max_x ? scan.max_x - scan.min_x + 1 : world.maxx
	state["map_height"] = scan.min_y && scan.max_y ? scan.max_y - scan.min_y + 1 : world.maxy
	if(scan.status == NEXUS_PLANET_MAP_SCAN_READY && scan.map_icon)
		state["map_icon"] = scan.map_icon
		state["image"] = scan.map_icon
		if(client)
			if(!islist(client.nexus_planet_map_resource_tokens)) client.nexus_planet_map_resource_tokens = list()
			if(!client.nexus_planet_map_resource_tokens[scan.scan_id])
				src << browse_rsc(scan.map_icon, scan.resource_name)
				client.nexus_planet_map_resource_tokens[scan.scan_id] = TRUE
	return state

#undef NEXUS_PLANET_MAP_SCAN_QUEUED
#undef NEXUS_PLANET_MAP_SCAN_SCANNING
#undef NEXUS_PLANET_MAP_SCAN_READY
#undef NEXUS_PLANET_MAP_SCAN_FAILED
#undef NEXUS_PLANET_MAP_SCAN_ROWS_PER_YIELD
#undef NEXUS_PLANET_MAP_SCAN_TICK_USAGE_LIMIT
#undef NEXUS_PLANET_MAP_SCAN_TILE_USAGE_CHECK
#undef NEXUS_PLANET_MAP_PHASE_QUEUED
#undef NEXUS_PLANET_MAP_PHASE_RENDER
#undef NEXUS_PLANET_MAP_PHASE_COMPLETE
#undef NEXUS_PLANET_MAP_PHASE_FAILED
