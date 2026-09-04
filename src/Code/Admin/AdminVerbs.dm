mob/Admin4/verb/loadExternalMapFile()
	set name = "Load External Map File"
	set category = "Admin"
	var/savefile/f = input("Choose a map file to load into the game on top of whatever is already here") as file|null
	if(!f)
		clients << "No file was chosen"
		return
	admin_blame(src, "[key] loaded an external map into the game.", TRUE)
	mapLoadExternal(f)

mob/Admin3/verb/giveMutation(mob/character in players)
	set name = "Give Mutation"
	set category = "Admin"
	if(AdminLevel() < 3 || !character || !character.playerCharacter) return
	var/list/mutation_options = list()
	for(var/mutation_id in CHARACTER_MUTATIONS)
		var/datum/CharacterMutation/mutation = CHARACTER_MUTATIONS[mutation_id]
		mutation_options["[mutation.stat] ([mutation_id])"] = mutation_id
	var/mutation_label = input(src, "Choose a mutation to add or update on [character].", "Give Mutation") as null|anything in mutation_options
	if(isnull(mutation_label)) return
	var/selected_mutation = mutation_options[mutation_label]
	var/current_percent = max(0, text2num("[character.character_mutations[selected_mutation]]"))
	var/new_percent = input(src, "Set the mutation strength from 1% to 30%.", "Give Mutation", max(1, current_percent)) as null|num
	if(isnull(new_percent)) return
	new_percent = Clamp(round(new_percent), 1, 30)
	if(!character.setCharacterMutationValue(selected_mutation, new_percent))
		src << "The mutation could not be granted."
		return
	admin_blame(src, "[key] set [character]'s [selected_mutation] mutation from [current_percent]% to [new_percent]%")
	src << "[character] now has [selected_mutation] at [new_percent]%."
	character << "An administrator granted you the [selected_mutation] mutation at [new_percent]%."

mob/Admin3/verb/rollMutations(mob/character in players)
	set name = "Roll Mutations"
	set category = "Admin"
	if(AdminLevel() < 3 || !character || !character.playerCharacter) return
	if(islist(character.character_mutations) && character.character_mutations.len)
		if(alert(src, "This replaces [character]'s current mutations and their stat modifiers.", "Roll Mutations", "Continue", "Cancel") != "Continue") return
	var/rarity_choice = input(src, "Use the natural rarity roll or force a mutation rarity.", "Roll Mutations") as null|anything in list("Natural Roll", "Common", "Uncommon", "Rare", "Anomaly")
	if(isnull(rarity_choice)) return
	var/forced_rarity = rarity_choice == "Natural Roll" ? null : rarity_choice
	if(!character.rerollCharacterMutations(forced_rarity))
		src << "The mutation roll failed."
		return
	var/result = "None"
	if(character.character_mutations.len)
		var/list/mutation_results = list()
		for(var/mutation_id in character.character_mutations)
			mutation_results += "[mutation_id] [character.character_mutations[mutation_id]]%"
		result = jointext(mutation_results, ", ")
	var/rarity_result = character.mutation_rarity ? character.mutation_rarity : "None"
	admin_blame(src, "[key] rerolled [character]'s mutations using [rarity_choice]: [result]")
	src << "[character]'s mutation result ([rarity_result]): [result]."
	character << "An administrator rerolled your mutations. Result: [result]."

mob/Admin3/verb/giveRareRace(mob/player in players)
	set name = "Give Rare Race"
	set category = "Admin"
	if(AdminLevel() < 3 || !player || !player.client) return
	var/list/choices = list("Legendary Saiyan", "Frost Lord", "Cooler", "Grand Regent", "All Rares")
	var/rare_choice = input(src, "Grant which rare character-creation option to [player]? The grant is consumed when that option is successfully created.", "Give Rare Race") as null|anything in choices
	if(isnull(rare_choice)) return
	var/list/granted = rare_choice == "All Rares" ? list("Legendary Saiyan", "Frost Lord", "Cooler", "Grand Regent") : list(rare_choice)
	for(var/grant in granted) player.grantNexusRareRace(grant)
	var/grant_text = jointext(granted, ", ")
	admin_blame(src, "[key] granted [player.key] rare character creation access: [grant_text]")
	src << "Granted [player] access to: [grant_text]."
	player << "An administrator granted your account rare character creation access to: [grant_text]."
	if(player.nexus_character_creator)
		if("Cooler" in granted) player.nexus_character_creator.cooler_available = TRUE
		player.nexus_character_creator.RefreshPage()

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

