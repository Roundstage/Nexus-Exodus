var/nexus_planet_map_refresh_ticks = 5
var/nexus_planet_map_window_name = "NexusPlanetMap"

client/var/tmp/datum/NexusPlanetMapWindow/nexus_planet_map

proc/normalizeNexusPlanetMapStatus(status)
	status = lowertext("[status]")
	if(status == "queued") return "scanning"
	if(status in list("idle", "scanning", "ready", "failed", "unavailable")) return status
	return "unavailable"

proc/nexusPlanetMapText(value, maximum_length = 160)
	var/rendered = isnull(value) ? "" : "[value]"
	maximum_length = max(1, round(maximum_length))
	if(length(rendered) > maximum_length) rendered = copytext(rendered, 1, maximum_length + 1)
	return rendered

proc/getNexusPlanetMapMarkerPercent(position, minimum, maximum, invert = FALSE)
	if(!nexusIsFiniteNumber(position) || !nexusIsFiniteNumber(minimum) || !nexusIsFiniteNumber(maximum)) return 50
	if(maximum < minimum)
		var/swap = minimum
		minimum = maximum
		maximum = swap
	var/span = max(1, maximum - minimum + 1)
	var/percentage = Clamp((position - minimum) / span * 100, 0, 100)
	if(invert) percentage = 100 - percentage
	return round(percentage, 0.01)

datum/NexusPlanetMapWindow
	var/tmp
		mob/owner
		client/window_client
		live_refresh_loop
		last_browser_heartbeat
		last_payload_signature
		next_scan_request_at
		list/sent_map_resources

	New(mob/new_owner)
		. = ..()
		owner = new_owner
		window_client = new_owner ? new_owner.client : null
		last_browser_heartbeat = world.time
		sent_map_resources = list()

	Del()
		if(window_client)
			window_client << browse(null, "window=[nexus_planet_map_window_name]")
			if(window_client.nexus_planet_map == src) window_client.nexus_planet_map = null
		window_client = null
		owner = null
		. = ..()

	proc/canUse()
		return owner && window_client && owner.client == window_client && owner.playerCharacter && owner.IsAdmin() && usr == owner && window_client.nexus_planet_map == src

	proc/hasLiveOwner()
		return owner && window_client && owner.client == window_client && owner.playerCharacter && owner.IsAdmin() && window_client.nexus_planet_map == src

	proc/isBrowserOpen()
		if(!hasLiveOwner()) return FALSE
		var/window_visibility = winget(owner, nexus_planet_map_window_name, "is-visible")
		if(window_visibility == "false") return FALSE
		if(window_visibility == "true") return TRUE
		return world.time - last_browser_heartbeat <= 30

	proc/recordHeartbeat()
		last_browser_heartbeat = world.time

	proc/getDefaultMessage(status)
		switch(status)
			if("idle") return "No map scan is active for this location."
			if("scanning") return "Scanning the current planetary surface."
			if("ready") return "Planetary surface scan is ready."
			if("failed") return "The planetary surface scan failed."
		return "A planetary map is not available in this location."

	proc/readBackendState()
		var/list/raw_state
		if(hasLiveOwner() && hascall(owner, "getNexusPlanetMapUiState"))
			raw_state = call(owner, "getNexusPlanetMapUiState")()
		if(!islist(raw_state)) raw_state = list()

		var/list/state = list()
		var/status = normalizeNexusPlanetMapStatus(raw_state["status"])
		if(!hascall(owner, "getNexusPlanetMapUiState")) status = "unavailable"
		else if("available" in raw_state && !raw_state["available"]) status = "unavailable"
		state["status"] = status
		state["scan_id"] = (istext(raw_state["scan_id"]) || isnum(raw_state["scan_id"])) ? raw_state["scan_id"] : null
		state["planet_id"] = nexusPlanetMapText(raw_state["planet_id"], 80)
		state["planet_name"] = nexusPlanetMapText(raw_state["planet_name"], 80)
		state["area_name"] = nexusPlanetMapText(raw_state["area_name"], 100)
		var/status_message = raw_state["message"]
		if(!status_message) status_message = raw_state["error"]
		state["message"] = nexusPlanetMapText(status_message, 240)
		if(!state["message"]) state["message"] = getDefaultMessage(status)

		var/minimum_x = nexusIsFiniteNumber(raw_state["min_x"]) ? round(raw_state["min_x"]) : 1
		var/minimum_y = nexusIsFiniteNumber(raw_state["min_y"]) ? round(raw_state["min_y"]) : 1
		var/maximum_x = nexusIsFiniteNumber(raw_state["max_x"]) ? round(raw_state["max_x"]) : world.maxx
		var/maximum_y = nexusIsFiniteNumber(raw_state["max_y"]) ? round(raw_state["max_y"]) : world.maxy
		if(maximum_x < minimum_x)
			var/swap_x = minimum_x
			minimum_x = maximum_x
			maximum_x = swap_x
		if(maximum_y < minimum_y)
			var/swap_y = minimum_y
			minimum_y = maximum_y
			maximum_y = swap_y
		state["min_x"] = minimum_x
		state["min_y"] = minimum_y
		state["max_x"] = maximum_x
		state["max_y"] = maximum_y

		state["map_width"] = nexusIsFiniteNumber(raw_state["map_width"]) ? Clamp(round(raw_state["map_width"]), 1, 8192) : max(1, maximum_x - minimum_x + 1)
		state["map_height"] = nexusIsFiniteNumber(raw_state["map_height"]) ? Clamp(round(raw_state["map_height"]), 1, 8192) : max(1, maximum_y - minimum_y + 1)
		var/progress = nexusIsFiniteNumber(raw_state["progress"]) ? raw_state["progress"] : 0
		var/tiles_scanned = nexusIsFiniteNumber(raw_state["tiles_scanned"]) ? max(0, round(raw_state["tiles_scanned"])) : 0
		var/total_tiles = nexusIsFiniteNumber(raw_state["total"]) ? max(0, round(raw_state["total"])) : 0
		if(!total_tiles && nexusIsFiniteNumber(raw_state["total_tiles"])) total_tiles = max(0, round(raw_state["total_tiles"]))
		if(!progress && total_tiles) progress = tiles_scanned / total_tiles * 100
		state["progress"] = Clamp(progress, 0, 100)
		state["tiles_scanned"] = tiles_scanned
		state["total_tiles"] = total_tiles
		state["elapsed_ticks"] = nexusIsFiniteNumber(raw_state["elapsed_ticks"]) ? max(0, round(raw_state["elapsed_ticks"], 0.1)) : 0
		state["elapsed_ms"] = nexusIsFiniteNumber(raw_state["elapsed_ms"]) ? max(0, round(raw_state["elapsed_ms"], 0.1)) : 0
		state["tiles_per_second"] = nexusIsFiniteNumber(raw_state["tiles_per_second"]) ? max(0, round(raw_state["tiles_per_second"])) : 0
		state["yield_count"] = nexusIsFiniteNumber(raw_state["yield_count"]) ? max(0, round(raw_state["yield_count"])) : 0
		state["unique_appearances"] = nexusIsFiniteNumber(raw_state["unique_appearances"]) ? max(0, round(raw_state["unique_appearances"])) : 0
		state["peak_tick_usage"] = nexusIsFiniteNumber(raw_state["peak_tick_usage"]) ? max(0, round(raw_state["peak_tick_usage"], 0.1)) : 0
		state["queue_position"] = nexusIsFiniteNumber(raw_state["queue_position"]) ? max(0, round(raw_state["queue_position"])) : 0
		state["image_revision"] = nexusPlanetMapText(raw_state["image_revision"], 100)
		state["resource_name"] = nexusPlanetMapText(raw_state["resource_name"], 160)
		var/map_image = raw_state["image"]
		if(isicon(map_image) || isfile(map_image)) state["image"] = map_image
		return state

	proc/getMapResource(list/state)
		if(!hasLiveOwner() || !islist(state)) return ""
		var/backend_resource = state["resource_name"]
		if(backend_resource) return backend_resource
		var/map_image = state["image"]
		if(!(isicon(map_image) || isfile(map_image))) return ""
		if(!islist(sent_map_resources)) sent_map_resources = list()
		var/planet_id = state["planet_id"]
		var/image_revision = state["image_revision"]
		var/resource_key = md5("[planet_id]|[image_revision]|[map_image]")
		var/resource_name = "nexus_planet_map_[resource_key].png"
		if(!sent_map_resources[resource_key])
			owner << browse_rsc(map_image, resource_name)
			sent_map_resources[resource_key] = TRUE
		return resource_name

	proc/buildMarkerData(list/state)
		var/list/marker = list(
			"visible" = FALSE,
			"left" = 50,
			"top" = 50,
			"x" = 0,
			"y" = 0,
			"z" = 0)
		if(!hasLiveOwner() || !owner.loc || !islist(state)) return marker
		var/minimum_x = state["min_x"]
		var/minimum_y = state["min_y"]
		var/maximum_x = state["max_x"]
		var/maximum_y = state["max_y"]
		if(owner.x < minimum_x || owner.x > maximum_x || owner.y < minimum_y || owner.y > maximum_y) return marker
		var/subtile_x = nexusIsFiniteNumber(owner.step_x) ? owner.step_x / max(1, world.icon_size) : 0
		var/subtile_y = nexusIsFiniteNumber(owner.step_y) ? owner.step_y / max(1, world.icon_size) : 0
		var/map_x = owner.x - minimum_x + 0.5 + subtile_x
		var/map_y = owner.y - minimum_y + 0.5 + subtile_y
		marker["visible"] = state["status"] == "ready" && !!(state["image"] || state["resource_name"])
		marker["left"] = getNexusPlanetMapMarkerPercent(minimum_x + map_x, minimum_x, maximum_x)
		marker["top"] = getNexusPlanetMapMarkerPercent(minimum_y + map_y, minimum_y, maximum_y, TRUE)
		marker["x"] = round(owner.x + subtile_x, 0.01)
		marker["y"] = round(owner.y + subtile_y, 0.01)
		marker["z"] = owner.z
		return marker

	proc/buildPayload(list/state, map_resource)
		var/list/marker = buildMarkerData(state)
		var/planet_name = state["planet_name"]
		if(!planet_name) planet_name = state["planet_id"]
		if(!planet_name) planet_name = "Unknown location"
		var/area_name = state["area_name"]
		if(!area_name) area_name = "Unknown area"
		return list(
			"status" = state["status"],
			"message" = state["message"],
			"planet_name" = planet_name,
			"area_name" = area_name,
			"progress" = state["progress"],
			"tiles_scanned" = state["tiles_scanned"],
			"total_tiles" = state["total_tiles"],
			"elapsed_ticks" = state["elapsed_ticks"],
			"elapsed_ms" = state["elapsed_ms"],
			"tiles_per_second" = state["tiles_per_second"],
			"yield_count" = state["yield_count"],
			"unique_appearances" = state["unique_appearances"],
			"peak_tick_usage" = state["peak_tick_usage"],
			"queue_position" = state["queue_position"],
			"min_x" = state["min_x"],
			"min_y" = state["min_y"],
			"max_x" = state["max_x"],
			"max_y" = state["max_y"],
			"map_width" = state["map_width"],
			"map_height" = state["map_height"],
			"image_resource" = map_resource,
			"marker_visible" = marker["visible"],
			"marker_left" = marker["left"],
			"marker_top" = marker["top"],
			"marker_x" = marker["x"],
			"marker_y" = marker["y"],
			"marker_z" = marker["z"])

	proc/sendLivePayload(force = FALSE)
		if(!hasLiveOwner()) return FALSE
		var/list/state = readBackendState()
		var/map_resource = getMapResource(state)
		var/list/payload = buildPayload(state, map_resource)
		var/json_payload = json_encode(payload)
		var/payload_signature = md5(json_payload)
		if(!force && payload_signature == last_payload_signature) return FALSE
		last_payload_signature = payload_signature
		owner << output(list2params(list(json_payload)), "NexusPlanetMap.browser:updateMarker")
		return TRUE

	proc/startLiveRefresh()
		set waitfor = FALSE
		if(live_refresh_loop) return
		live_refresh_loop = TRUE
		while(src && hasLiveOwner())
			sleep(max(1, nexus_planet_map_refresh_ticks))
			if(!src || !hasLiveOwner() || !isBrowserOpen()) break
			sendLivePayload()
		if(src)
			live_refresh_loop = FALSE
			del(src)

	proc/buildHtml(list/state, map_resource)
		var/list/payload = buildPayload(state, map_resource)
		var/status = payload["status"]
		var/marker_display = payload["marker_visible"] ? "block" : "none"
		var/image_display = map_resource ? "block" : "none"
		var/empty_display = map_resource ? "none" : "flex"
		var/scan_display = status == "idle" || status == "failed" ? "inline-flex" : "none"
		var/planet_name = html_encode(payload["planet_name"])
		var/area_name = html_encode(payload["area_name"])
		var/status_message = html_encode(payload["message"])
		var/progress = payload["progress"]
		var/map_width = payload["map_width"]
		var/map_height = payload["map_height"]
		var/marker_left = payload["marker_left"]
		var/marker_top = payload["marker_top"]
		var/tiles_scanned = payload["tiles_scanned"]
		var/total_tiles = payload["total_tiles"]
		var/elapsed_ms = payload["elapsed_ms"]
		var/tiles_per_second = payload["tiles_per_second"]
		var/yield_count = payload["yield_count"]
		var/unique_appearances = payload["unique_appearances"]
		var/peak_tick_usage = payload["peak_tick_usage"]
		var/marker_x = payload["marker_x"]
		var/marker_y = payload["marker_y"]
		var/marker_z = payload["marker_z"]
		var/minimum_x = payload["min_x"]
		var/minimum_y = payload["min_y"]
		var/maximum_x = payload["max_x"]
		var/maximum_y = payload["max_y"]
		var/live_script = getNexusLiveBrowserScript(src, 0)
		return {"<!doctype html><html><head><meta charset='utf-8'><title>Planet Map</title><style>
		[getNexusHudBrowserCss("bronze")]
		*{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:hidden}.map-shell{height:100vh;padding:10px;display:flex;flex-direction:column;gap:8px}.map-header{display:flex;align-items:center;gap:8px;padding:9px 12px;flex:0 0 auto}.map-heading{min-width:0;margin-right:auto}.map-heading b,.map-heading small{display:block}.map-heading b{font-size:17px}.map-heading small{margin-top:3px}.map-actions{display:flex;gap:6px}.map-actions .hud-button{display:inline-flex;align-items:center;justify-content:center;min-width:86px;padding:8px 10px}.map-body{display:grid;grid-template-columns:minmax(0,1fr) 250px;gap:8px;min-height:0;flex:1}.map-frame{padding:7px;min-width:0;min-height:0;display:flex;align-items:center;justify-content:center}.map-stage{position:relative;width:100%;height:100%;min-height:280px;max-height:100%;overflow:hidden;background:#0b100c;border:2px solid #171008;box-shadow:inset 0 0 0 2px #655039}.map-image{position:absolute;inset:0;width:100%;height:100%;object-fit:fill;image-rendering:pixelated}.map-empty{position:absolute;inset:0;align-items:center;justify-content:center;padding:24px;text-align:center;color:#a88f68;background:repeating-linear-gradient(45deg,#17140f,#17140f 8px,#1c1811 8px,#1c1811 16px)}.map-grid{position:absolute;inset:0;pointer-events:none;background-image:linear-gradient(rgba(239,205,137,.06) 1px,transparent 1px),linear-gradient(90deg,rgba(239,205,137,.06) 1px,transparent 1px);background-size:10% 10%}.self-marker{position:absolute;z-index:4;width:18px;height:18px;margin:-9px 0 0 -9px;border:3px solid #fff2b1;background:#e45252;box-shadow:0 0 0 2px #1a0d08,0 0 10px #ffdf79;transform:rotate(45deg);pointer-events:none}.self-marker:after{content:'YOU';position:absolute;left:14px;top:-15px;padding:2px 4px;border:1px solid #b88b49;background:#17100c;color:#fff1ba;font-size:8px;transform:rotate(-45deg);white-space:nowrap;text-shadow:1px 1px #000}.map-side{display:flex;flex-direction:column;gap:7px;min-height:0}.telemetry{padding:9px}.telemetry h2{margin:0 0 8px;padding:6px 8px;font-size:12px}.data-grid{display:grid;grid-template-columns:1fr;gap:5px}.data-row{padding:7px;border-left:3px solid #745d39}.data-row small,.data-row b{display:block}.data-row small{font-size:8px}.data-row b{margin-top:4px;font-size:11px;overflow-wrap:anywhere}.scan-panel{padding:9px}.scan-status{display:flex;align-items:center;justify-content:space-between;gap:6px}.status-badge{padding:4px 6px;border:1px solid #755a36;color:#f0d497;text-transform:uppercase}.progress-track{height:18px;margin-top:8px;padding:2px;background:#100c08;border:2px inset #60482d}.progress-fill{height:100%;background:#d2a34f;transition:width .2s linear}.scan-message{margin:8px 0 0;color:#bda67e;line-height:1.4}.scan-detail{margin-top:7px;color:#8f7d61;font-size:9px}.bounds{margin-top:auto}.coordinate{color:#fff0bd!important}@media(max-width:780px){.map-body{grid-template-columns:1fr}.map-side{display:grid;grid-template-columns:1fr 1fr}.bounds{margin-top:0}.map-stage{min-height:320px}}@media(max-width:560px){.map-header{align-items:flex-start;flex-wrap:wrap}.map-actions{width:100%}.map-actions .hud-button{flex:1}.map-side{grid-template-columns:1fr}}
		</style><script>
		var nexusPlanetMapWidth=[map_width],nexusPlanetMapHeight=[map_height];
		function nexusPlanetMapSetText(id,value){var node=document.getElementById(id);if(node)node.textContent=value===null||typeof value==='undefined'?'':String(value);}
		function nexusPlanetMapResize(){var stage=document.getElementById('mapStage');if(!stage)return;var frame=stage.parentNode;if(!frame)return;var availableWidth=Math.max(280,frame.clientWidth-14),availableHeight=Math.max(280,frame.clientHeight-14);var ratio=Math.max(1,nexusPlanetMapWidth)/Math.max(1,nexusPlanetMapHeight);var width=availableWidth,height=Math.round(width/ratio);if(height>availableHeight){height=availableHeight;width=Math.round(height*ratio);}stage.style.width=Math.max(220,width)+'px';stage.style.height=Math.max(220,height)+'px';}
		function updateMarker(payload){var data=null;try{data=JSON.parse(payload);}catch(error){return;}if(!data)return;var status=String(data.status||'unavailable');document.body.setAttribute('data-map-status',status);nexusPlanetMapSetText('planetName',data.planet_name||'Unknown location');nexusPlanetMapSetText('areaName',data.area_name||'Unknown area');nexusPlanetMapSetText('areaNameSide',data.area_name||'Unknown area');nexusPlanetMapSetText('statusBadge',status.toUpperCase());nexusPlanetMapSetText('statusMessage',data.message||'');nexusPlanetMapSetText('coordinates',String(data.marker_x)+' / '+String(data.marker_y)+' / Z'+String(data.marker_z));nexusPlanetMapSetText('scanCount',data.total_tiles>0?String(data.tiles_scanned)+' / '+String(data.total_tiles)+' tiles':String(data.tiles_scanned||0)+' tiles');nexusPlanetMapSetText('elapsed',data.elapsed_ms>0?String(data.elapsed_ms)+' ms':String(data.elapsed_ticks||0)+' ticks');nexusPlanetMapSetText('tilesPerSecond',String(data.tiles_per_second||0)+' tiles/s');nexusPlanetMapSetText('yieldCount',String(data.yield_count||0));nexusPlanetMapSetText('peakTickUsage',String(data.peak_tick_usage||0)+'%');nexusPlanetMapSetText('appearanceCount',String(data.unique_appearances||0));nexusPlanetMapSetText('boundsText','X '+data.min_x+'..'+data.max_x+' / Y '+data.min_y+'..'+data.max_y);var progress=Math.max(0,Math.min(100,Number(data.progress)||0));var fill=document.getElementById('progressFill');if(fill)fill.style.width=progress+'%';nexusPlanetMapSetText('progressText',Math.round(progress*10)/10+'%');var image=document.getElementById('mapImage'),empty=document.getElementById('mapEmpty');if(image&&data.image_resource){if(image.getAttribute('src')!==data.image_resource)image.setAttribute('src',data.image_resource);image.style.display='block';if(empty)empty.style.display='none';}else{if(image)image.style.display='none';if(empty)empty.style.display='flex';}var marker=document.getElementById('selfMarker');if(marker){marker.style.display=data.marker_visible?'block':'none';marker.style.left=(Number(data.marker_left)||0)+'%';marker.style.top=(Number(data.marker_top)||0)+'%';}var scan=document.getElementById('scanButton');if(scan)scan.style.display=status==='idle'||status==='failed'?'inline-flex':'none';nexusPlanetMapWidth=Math.max(1,Number(data.map_width)||1);nexusPlanetMapHeight=Math.max(1,Number(data.map_height)||1);nexusPlanetMapResize();}
		window.addEventListener('resize',nexusPlanetMapResize);window.addEventListener('load',nexusPlanetMapResize);
		</script>[live_script]</head><body class='nexus-hud' data-map-status='[status]'><main class='map-shell hud-shell'><header class='map-header hud-frame'><div class='map-heading'><b class='hud-title'>PLANETARY MAP / <span id='planetName'>[planet_name]</span></b><small class='hud-muted' id='areaName'>[area_name]</small></div><nav class='map-actions'><a id='scanButton' class='hud-button' style='display:[scan_display]' href='byond://?src=\ref[src]&action=scan'>SCAN</a><a class='hud-button' href='byond://?src=\ref[src]&action=refresh'>REFRESH</a><a class='hud-button danger' href='byond://?src=\ref[src]&action=close'>CLOSE</a></nav></header><section class='map-body'><div class='map-frame hud-frame'><div class='map-stage' id='mapStage'><img id='mapImage' class='map-image' src='[html_encode(map_resource)]' alt='Scanned planetary surface' style='display:[image_display]'><div class='map-empty' id='mapEmpty' style='display:[empty_display]'>No scanned surface image is available.</div><div class='map-grid'></div><div class='self-marker' id='selfMarker' style='display:[marker_display];left:[marker_left]%;top:[marker_top]%'></div></div></div><aside class='map-side'><section class='scan-panel hud-frame'><div class='scan-status'><span class='hud-label'>SCAN STATUS</span><b class='status-badge' id='statusBadge'>[uppertext(status)]</b></div><div class='progress-track'><div class='progress-fill' id='progressFill' style='width:[progress]%'></div></div><div class='scan-status'><small id='scanCount'>[tiles_scanned] / [total_tiles] tiles</small><b id='progressText'>[round(progress, 0.1)]%</b></div><p class='scan-message' id='statusMessage'>[status_message]</p><div class='scan-detail'>Elapsed <span id='elapsed'>[elapsed_ms] ms</span> | <span id='tilesPerSecond'>[tiles_per_second] tiles/s</span></div><div class='scan-detail'>Yields <span id='yieldCount'>[yield_count]</span> | peak tick <span id='peakTickUsage'>[peak_tick_usage]%</span> | appearances <span id='appearanceCount'>[unique_appearances]</span></div><p class='scan-detail'>Terrain only: characters and movable objects are excluded. Runtime turf changes may appear. The shared result is cached until reboot and keeps scanning after this window closes.</p></section><section class='telemetry hud-frame'><h2 class='hud-section-title'>POSITION</h2><div class='data-grid'><div class='data-row hud-panel'><small class='hud-label'>YOU ARE HERE</small><b class='coordinate' id='coordinates'>[marker_x] / [marker_y] / Z[marker_z]</b></div><div class='data-row hud-panel'><small class='hud-label'>AREA</small><b id='areaNameSide'>[area_name]</b></div></div></section><section class='telemetry hud-frame bounds'><h2 class='hud-section-title'>SCAN BOUNDS</h2><div class='data-grid'><div class='data-row hud-panel'><small class='hud-label'>WORLD TILES</small><b id='boundsText'>X [minimum_x]..[maximum_x] / Y [minimum_y]..[maximum_y]</b></div><div class='data-row hud-panel'><small class='hud-label'>OUTPUT</small><b>[map_width] x [map_height] px</b></div></div></section></aside></section></main></body></html>"}

	proc/show(force_refresh = TRUE)
		if(!hasLiveOwner())
			del(src)
			return
		var/list/state = readBackendState()
		var/map_resource = getMapResource(state)
		prepareNexusHudBrowserResources(owner)
		owner << browse(buildHtml(state, map_resource), "window=NexusPlanetMap;size=1080x760;can_resize=true;can_close=true")
		last_browser_heartbeat = world.time
		last_payload_signature = null
		spawn(1) if(src && hasLiveOwner()) sendLivePayload(TRUE)
		spawn(4) if(src && hasLiveOwner()) sendLivePayload(TRUE)
		startLiveRefresh()

	proc/requestScan()
		if(!hasLiveOwner() || world.time < next_scan_request_at) return FALSE
		next_scan_request_at = world.time + 10
		if(!hascall(owner, "requestNexusPlanetMapScan")) return FALSE
		call(owner, "requestNexusPlanetMapScan")()
		return TRUE

	Topic(href, list/href_list)
		if(!canUse()) return
		switch(href_list["action"])
			if("heartbeat")
				recordHeartbeat()
				return
			if("scan") requestScan()
			if("refresh")
				show(TRUE)
				return
			if("close")
				del(src)
				return
		sendLivePayload(TRUE)

mob/proc/showNexusPlanetMap(request_scan = FALSE)
	if(!client || !playerCharacter || !IsAdmin()) return
	if(client.nexus_planet_map) del(client.nexus_planet_map)
	client.nexus_planet_map = new /datum/NexusPlanetMapWindow(src)
	if(request_scan) client.nexus_planet_map.requestScan()
	client.nexus_planet_map.show(TRUE)

mob/proc/toggleNexusPlanetMap(request_scan = FALSE)
	if(!client || !playerCharacter || !IsAdmin()) return
	if(client.nexus_planet_map)
		del(client.nexus_planet_map)
		return
	showNexusPlanetMap(request_scan)

mob/proc/closeNexusPlanetMap()
	if(client && client.nexus_planet_map) del(client.nexus_planet_map)

mob/Admin1/verb/planetMap()
	set name = "Planet Map"
	set category = "Admin"
	if(!client || !playerCharacter || !IsAdmin()) return
	toggleNexusPlanetMap()
