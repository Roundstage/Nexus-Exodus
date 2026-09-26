// Live chat is a bounded preview. Disk-backed player logs keep their existing policy.
datum/NexusChatBuffer
	var/tmp
		list/entries = list()
		next_id = 0
		revision = 0
		text_bytes = 0
		max_entries = 300
		max_bytes = 262144
		max_message_bytes = 32768
		max_age = 36000 // One hour in deciseconds.

	proc/appendMessage(message, now = world.time)
		// Avoid parsing or retaining exceptionally large markup in the live panel.
		if(length(message) > max_message_bytes)
			message = "<i>Message too large for the chat preview. Open LOGS to read it.</i>"
		var/rendered = closeNexusLegacyChatMarkup(message)
		entries += list(list("id" = ++next_id, "html" = rendered, "time" = now))
		text_bytes += length(rendered)
		revision++
		prune(now)

	proc/prune(now = world.time)
		var/remove_count = 0
		for(var/list/entry in entries)
			if(entries.len - remove_count <= max_entries && text_bytes <= max_bytes && now - entry["time"] < max_age) break
			text_bytes -= length(entry["html"])
			remove_count++
		if(!remove_count) return FALSE
		entries.Cut(1, remove_count + 1)
		revision++
		return TRUE

	proc/clearHistory()
		entries.Cut()
		text_bytes = 0
		revision++

	proc/buildUpdate(after_id = 0, reset = FALSE)
		var/list/messages = list()
		for(var/list/entry in entries)
			if(reset || entry["id"] > after_id)
				messages += list(list("id" = entry["id"], "html" = entry["html"]))
		var/list/first_entry = entries.len ? entries[1] : null
		return list("messages" = messages, "reset" = reset, "firstId" = first_entry ? first_entry["id"] : next_id + 1, "lastId" = next_id)

client/var/tmp/nexus_chat_last_prune = -600

client/proc/initializeNexusChatHistory()
	if(!islist(nexus_chat_history)) nexus_chat_history = list()
	for(var/channel in list("all", "combat", "ic", "ooc"))
		if(!istype(nexus_chat_history[channel], /datum/NexusChatBuffer)) nexus_chat_history[channel] = new /datum/NexusChatBuffer

client/proc/appendNexusChatHistory(message, channel)
	initializeNexusChatHistory()
	var/datum/NexusChatBuffer/buffer = nexus_chat_history[channel]
	buffer.appendMessage(message)

client/proc/pruneNexusChatHistory()
	if(world.time - nexus_chat_last_prune < 600) return
	nexus_chat_last_prune = world.time
	if(!islist(nexus_chat_history)) return
	for(var/channel in nexus_chat_history)
		var/datum/NexusChatBuffer/buffer = nexus_chat_history[channel]
		buffer.prune()

client/proc/clearNexusChatHistory()
	if(!islist(nexus_chat_history)) return
	for(var/channel in nexus_chat_history)
		var/datum/NexusChatBuffer/buffer = nexus_chat_history[channel]
		buffer.clearHistory()
	if(nexus_chat_hud) nexus_chat_hud.refreshMessages()
