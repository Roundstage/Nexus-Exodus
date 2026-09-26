proc/runNexusCpuDiagnosticsSmokeTests()
	nexusSmokeAssert(getNexusCpuElapsed(863980, 30) == 50, "CPU sample duration broke across UTC midnight")
	nexusSmokeAssert(getNexusCpuPendingCount(list(null, null, "pending"), 3) == 1, "CPU diagnostics counted a processed queue prefix")
	nexusSmokeAssert(getNexusCpuPendingCount(list(), 1) == 0, "CPU diagnostics reported negative pending work")
	var/datum/NexusCpuMonitor/monitor = new
	monitor.log_path = "cpu-smoke-telemetry.jsonl"
	monitor.profile_prefix = "cpu-smoke-profile"
	var/list/healthy = list("cpu" = 20, "tick_usage_sample" = 10, "late_ds" = 0)
	var/list/overloaded = list("cpu" = 85, "tick_usage_sample" = 10, "late_ds" = 0)
	var/list/stalled = list("cpu" = 20, "tick_usage_sample" = 10, "late_ds" = 25)
	nexusSmokeAssert(!monitor.isSpike(healthy) && monitor.isSpike(overloaded) && monitor.isSpike(stalled), "CPU trigger missed overload/stall or flagged a healthy sample")
	for(var/index = 1, index <= 25, index++) monitor.rememberSample(list("sequence" = index))
	var/list/oldest = monitor.history[1]
	nexusSmokeAssert(monitor.history.len == 20 && oldest["sequence"] == 6, "CPU diagnostic history is not bounded in chronological order")
	nexusSmokeAssert(monitor.startCapture("smoke"), "CPU profiler failed to start")
	nexusSmokeAssert(!monitor.startCapture("duplicate"), "CPU profiler accepted an overlapping capture")
	for(var/index = 1, index <= 200, index++) getNexusCpuPendingCount(list("pending"), 1)
	sleep(1)
	nexusSmokeAssert(monitor.finishCapture(), "CPU profiler did not export its engine data")
	var/profile_text = file2text("cpu-smoke-profile-1.json")
	var/list/report = json_decode(profile_text)
	nexusSmokeAssert(findtext(profile_text, "getNexusCpuPendingCount"), "CPU profile did not identify the measured workload")
	var/list/context = report["context"]
	nexusSmokeAssert(context["reason"] == "smoke" && islist(report["procs"]) && length(report["procs"]), "CPU profile export lost context or engine proc data")
	nexusSmokeAssert(!monitor.profiling && !monitor.startCapture("cooldown"), "CPU profiler did not stop or enforce its cooldown")
	monitor.history = list()
	monitor.runMonitor()
	monitor.runMonitor()
	sleep(55)
	monitor.running = FALSE
	nexusSmokeAssert(monitor.history.len == 1, "CPU monitor spawned duplicate sampler loops")
	monitor.log_max_bytes = 1
	nexusSmokeAssert(monitor.writeRecord("rotation", healthy), "CPU telemetry rotation failed")
	var/list/rotated = json_decode(file2text(monitor.log_path))
	nexusSmokeAssert(fexists("[monitor.log_path].previous") && rotated["event"] == "rotation", "CPU telemetry did not preserve its previous log and replace the current log")
	// The sleeper exits before doing any further I/O when running becomes false.
	fdel("cpu-smoke-profile-1.json")
	fdel(monitor.log_path)
	fdel("[monitor.log_path].previous")
	del(monitor)
