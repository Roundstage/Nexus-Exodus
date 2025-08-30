mob/Admin4/verb/Load_External_Map_File()
	set category = "Admin"
	var/savefile/f = input("Choose a map file to load into the game on top of whatever is already here") as file|null
	if(!f)
		clients << "No file was chosen"
		return
	admin_blame(src, "[key] loaded an external map into the game.", TRUE)
	MapLoadExternal(f)

mob/Admin2/verb/Bug_Logs()
	set category="Admin"
	var/T={"<html><head><body><body bgcolor="#000000"><font size=3><b>"}
	for(var/V in Bugs) T+="[V]<br>"
	usr<<browse(T,"window= ;size=700x600")

mob/Admin4/verb
	wipe_bounty_list()
		set category="Admin"
		Bounties=list("Cancel")

