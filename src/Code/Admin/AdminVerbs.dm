mob/Admin4/verb/loadExternalMapFile()
	set name = "Load External Map File"
	set category = "Admin"
	var/savefile/f = input("Choose a map file to load into the game on top of whatever is already here") as file|null
	if(!f)
		clients << "No file was chosen"
		return
	admin_blame(src, "[key] loaded an external map into the game.", TRUE)
	mapLoadExternal(f)

mob/Admin2/verb/bugLogs()
	set name = "Bug Logs"
	set category="Admin"
	var/T={"<html><head><body><body bgcolor="#000000"><font size=3><b>"}
	for(var/V in Bugs) T+="[V]<br>"
	usr<<browse(T,"window= ;size=700x600")

mob/Admin1/verb/viewRpWindow(mob/M in players)
	set category = "Admin"
	set name = "View Player RP Window"
	if(!IsAdmin()) return
	ViewEmoteWindow(src, M, M.unwritten_emotelogs, "Emote", "emotelogs")

mob/Admin1/verb/viewDevelopmentRpWindow(mob/M in players)
	set category = "Admin"
	set name = "View Player Development RP Window"
	if(!IsAdmin()) return
	ViewEmoteWindow(src, M, M.unwritten_emotelogs, "Development Emote", "emotelogs_dev")

mob/Admin1/verb/viewAdminLogs()
	set category = "Admin"
	set name = "View admin logs"
	if(!IsAdmin()) return
	var/list/admin_list = list()
	for(var/admin_key in Admins)
		admin_list += admin_key
	admin_list += "all"
	var/admin_key = input(src, "Select an admin to view their logs", "Admin Logs") in admin_list
	if(!admin_key) return
	src << "You are viewing the admin logs for [admin_key]"
	ViewEmoteWindow(src, src, "", "Admin log", "adminlogs", overwrite_ckey = ckey(admin_key))

mob/Admin1/verb/viewAllAdminLogs()
	set category = "Admin"
	set name = "View all admin logs"
	if(!IsAdmin()) return
	ViewEmoteWindow(src, src, "", "Admin log", "adminlogs", overwrite_ckey = "all")

mob/Admin4/verb
	wipeBountyList()
		set name = "wipe bounty list"
		set category="Admin"
		Bounties=list("Cancel")

