// Low-frequency telemetry. Profiling is opt-in because it adds measurement cost
// and owns the engine's single proc-profiler session (including its counters).
var/datum/NexusCpuMonitor/nexus_cpu_monitor

proc/startNexusCpuMonitoring()
	if("[world.params["nexus_cpu_monitor"]]" == "0") return
	if(!nexus_cpu_monitor) nexus_cpu_monitor = new
	nexus_cpu_monitor.auto_profile = "[world.params["nexus_cpu_profile"]]" == "1"
	nexus_cpu_monitor.runMonitor()

proc/getNexusCpuElapsed(previous_time, current_time)
	// timeofday has subsecond precision; realtime's large epoch loses precision.
	return (current_time - previous_time + 864000) % 864000

proc/getNexusCpuPendingCount(list/queue, queue_head)
	return max(0, length(queue) - queue_head + 1)

datum/NexusCpuMonitor
	var
		running = FALSE
		auto_profile = FALSE
		profiling = FALSE
		profile_elapsed = 0
		profile_started_time = 0
		capture_cooldown = 0
		capture_slot = 0
		log_failed = FALSE
		log_max_bytes = 2097152
		log_path = "data/Logs/cpu-telemetry.jsonl"
		profile_prefix = "data/Logs/cpu-profile"
		list/history = list()
		list/capture_context

	proc/buildSample(elapsed_ds)
		return list("utc" = time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss", 0), \
			"world_time_ds" = world.time, "elapsed_ds" = elapsed_ds, \
			"late_ds" = max(0, elapsed_ds - 50), "cpu" = world.cpu, \
			"map_cpu" = world.map_cpu, "tick_usage_sample" = world.tick_usage, \
			"fps" = world.fps, "clients" = length(clients), "players" = length(players), \
			"blast_registry" = length(all_blast_objs), "status_targets" = length(nexus_status_effect_mobs), \
			"garbage_pending" = getNexusCpuPendingCount(garbage_collect, garbage_collection_head), \
			"delete_pending" = getNexusCpuPendingCount(pending_object_delete_list, pending_object_delete_head), \
			"effect_cache" = length(effect_cache), "explosion_cache" = length(explosion_cache), \
			"damage_indicator_cache" = length(damage_indicator_cache), \
			"map_scan_active" = !!nexus_active_planet_map_scan, \
			"map_scan_queue" = length(nexus_planet_map_scan_queue), "profiling" = profiling)

	proc/isSpike(list/sample)
		return sample["cpu"] >= 80 || sample["tick_usage_sample"] >= 90 || sample["late_ds"] >= 20

	proc/writeRecord(event_name, list/details)
		// Rotate around 2 MiB and keep one previous file; never scan world contents.
		if(fexists(log_path) && length(file(log_path)) >= log_max_bytes)
			if(!fcopy(log_path, "[log_path].previous") || !fdel(log_path))
				reportWriteFailure()
				return FALSE
		var/list/record = list("event" = event_name, "data" = details)
		if(!text2file(json_encode(record), log_path))
			reportWriteFailure()
			return FALSE
		log_failed = FALSE
		return TRUE

	proc/reportWriteFailure()
		if(!log_failed) world.log << "NEXUS_CPU: unable to write diagnostic files under data/Logs."
		log_failed = TRUE

	proc/rememberSample(list/sample)
		history += list(sample)
		if(history.len > 20) history.Cut(1, history.len - 19)

	proc/startCapture(reason = "manual")
		if(profiling || capture_cooldown > 0) return FALSE
		capture_context = list("reason" = reason, "byond" = "[world.byond_version].[world.byond_build]", \
			"start" = buildSample(0), "before" = history.Copy())
		profile_elapsed = 0
		profile_started_time = world.timeofday
		profiling = TRUE
		world.Profile(PROFILE_RESTART)
		writeRecord("profile_start", capture_context)
		return TRUE

	proc/finishCapture()
		if(!profiling) return FALSE
		// Stop before serializing/writing so the profile doesn't charge its own export.
		var/profile_json = world.Profile(PROFILE_STOP, "json")
		profile_elapsed = getNexusCpuElapsed(profile_started_time, world.timeofday)
		profiling = FALSE
		capture_cooldown = 3000
		capture_context["end"] = buildSample(0)
		capture_context["elapsed_ds"] = profile_elapsed
		capture_slot = (capture_slot % 6) + 1
		var/path = "[profile_prefix]-[capture_slot].json"
		var/saved = FALSE
		// Keep six captures with a hard per-capture cap; never truncate valid JSON.
		if(istext(profile_json) && length(profile_json) && length(profile_json) <= 2097152)
			var/header = json_encode(capture_context)
			var/payload = "{\"context\":[header],\"procs\":[profile_json]}"
			if(length(payload) <= 2097152 && (!fexists("[path].next") || fdel("[path].next")))
				if(text2file(payload, "[path].next")) saved = fcopy("[path].next", path)
				fdel("[path].next")
		writeRecord("profile_end", list("utc" = time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss", 0), \
			"path" = path, "saved" = saved, "elapsed_ds" = profile_elapsed, "profile_bytes" = length(profile_json)))
		if(!saved) world.log << "NEXUS_CPU: profile export failed or exceeded 2 MiB: [path]"
		capture_context = null
		return saved

	proc/sample(elapsed_ds)
		capture_cooldown = max(0, capture_cooldown - elapsed_ds)
		var/list/current = buildSample(elapsed_ds)
		rememberSample(current)
		writeRecord(isSpike(current) ? "spike" : "sample", current)
		if(profiling)
			profile_elapsed = getNexusCpuElapsed(profile_started_time, world.timeofday)
			if(profile_elapsed >= 300) finishCapture()
		else if(auto_profile && isSpike(current)) startCapture("automatic")

	proc/runMonitor()
		set waitfor = FALSE
		if(running) return
		running = TRUE
		writeRecord("start", list("byond" = "[world.byond_version].[world.byond_build]", \
			"auto_profile" = auto_profile, "sample" = buildSample(0)))
		var/previous_time = world.timeofday
		while(running)
			sleep(50)
			if(!running) break
			var/current_time = world.timeofday
			sample(getNexusCpuElapsed(previous_time, current_time))
			previous_time = current_time

mob/Admin5/verb/cpuDiagnostics()
	set name = "CPU Diagnostics"
	set category = "Admin"
	if(!client || AdminLevel() < 5) return
	if(!nexus_cpu_monitor)
		src << "CPU monitoring is disabled by the server startup parameters."
		return
	var/action = input(src, "Telemetry records every 5 seconds. Profiles run for 30 seconds, with a 5-minute cooldown. Starting a capture clears the BYOND proc profiler's previous counters; do not run another profiler session at the same time.", "CPU Diagnostics") as null|anything in list("Status", "Capture 30 seconds", "Enable automatic profiles", "Disable automatic profiles")
	if(!client || AdminLevel() < 5 || !action) return
	switch(action)
		if("Status")
			src << "CPU [world.cpu]% (map [world.map_cpu]%), profiles automatic=[nexus_cpu_monitor.auto_profile], active=[nexus_cpu_monitor.profiling], cooldown=[round(nexus_cpu_monitor.capture_cooldown / 10)]s. Files: data/Logs/cpu-*"
		if("Capture 30 seconds")
			src << (nexus_cpu_monitor.startCapture() ? "CPU profile started. The result will be saved under data/Logs/cpu-profile-*.json." : "A profile is already active or its 5-minute cooldown has not expired.")
		if("Enable automatic profiles")
			nexus_cpu_monitor.auto_profile = TRUE
			nexus_cpu_monitor.writeRecord("automatic_profiles_enabled", nexus_cpu_monitor.buildSample(0))
			src << "Automatic profiles enabled until reboot: CPU >=80%, sampled tick usage >=90%, or sampler delay >=2s."
		if("Disable automatic profiles")
			nexus_cpu_monitor.auto_profile = FALSE
			if(nexus_cpu_monitor.profiling) nexus_cpu_monitor.finishCapture()
			nexus_cpu_monitor.writeRecord("automatic_profiles_disabled", nexus_cpu_monitor.buildSample(0))
			src << "Automatic profiles disabled; any active capture was stopped and exported. Telemetry continues."
