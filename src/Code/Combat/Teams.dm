var/const/NEXUS_COMBAT_TEAM_LIMIT = 5
var/const/NEXUS_COMBAT_TEAM_INVITE_RANGE = 30
var/icon/nexus_combat_team_marker_icon

mob/var/tmp/datum/CombatTeam/combat_team
mob/var/tmp/datum/CombatTeam/pending_combat_team
client/var/tmp/list/combat_team_markers

proc/getNexusCombatTeamMarkerIcon()
	if(nexus_combat_team_marker_icon) return nexus_combat_team_marker_icon
	var/icon/marker_icon = icon('healthbar.dmi', "100")
	marker_icon.Scale(32, 32)
	marker_icon.DrawBox(null, 1, 1, 32, 32)
	var/outline_color = "#2a2100"
	var/marker_color = "#ffd83d"
	var/highlight_color = "#fff3a1"
	// A compact downward arrow. Its visible pixels stay below overhead Say text.
	marker_icon.DrawBox(outline_color, 13, 8, 20, 16)
	marker_icon.DrawBox(outline_color, 8, 8, 25, 10)
	marker_icon.DrawBox(outline_color, 10, 6, 23, 9)
	marker_icon.DrawBox(outline_color, 12, 4, 21, 7)
	marker_icon.DrawBox(outline_color, 14, 2, 19, 5)
	marker_icon.DrawBox(marker_color, 15, 9, 18, 14)
	marker_icon.DrawBox(marker_color, 10, 9, 23, 9)
	marker_icon.DrawBox(marker_color, 12, 7, 21, 8)
	marker_icon.DrawBox(marker_color, 14, 5, 19, 6)
	marker_icon.DrawBox(marker_color, 16, 3, 17, 4)
	marker_icon.DrawBox(highlight_color, 15, 10, 16, 13)
	nexus_combat_team_marker_icon = marker_icon
	return nexus_combat_team_marker_icon

proc/getNexusCombatTeamMarkerPixelY(mob/member)
	var/icon_height = member && member.icon ? max(32, GetHeight(member.icon)) : 32
	return icon_height - 2

client/proc/removeCombatTeamMarker(mob/member)
	if(!islist(combat_team_markers) || !member) return
	var/image/marker = combat_team_markers[member]
	if(marker)
		images -= marker
		del(marker)
	combat_team_markers -= member

client/proc/clearCombatTeamMarkers()
	if(!islist(combat_team_markers))
		combat_team_markers = list()
		return
	for(var/mob/member in combat_team_markers.Copy()) removeCombatTeamMarker(member)
	combat_team_markers.Cut()

client/proc/syncCombatTeamMarkers()
	var/datum/CombatTeam/current_team = mob ? mob.combat_team : null
	if(!current_team || !islist(current_team.members) || !(mob in current_team.members))
		clearCombatTeamMarkers()
		return
	if(!islist(combat_team_markers)) combat_team_markers = list()
	for(var/mob/old_member in combat_team_markers.Copy())
		if(!old_member || !(old_member in current_team.members) || !old_member.loc) removeCombatTeamMarker(old_member)
	for(var/mob/member in current_team.members)
		if(!member || !member.loc) continue
		var/image/marker = combat_team_markers[member]
		if(!marker)
			marker = image(icon = getNexusCombatTeamMarkerIcon(), loc = member, layer = 99)
			marker.plane = NEXUS_WORLD_OVERLAY_PLANE
			marker.appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM
			marker.mouse_opacity = 0
			combat_team_markers[member] = marker
			images += marker
		marker.pixel_y = getNexusCombatTeamMarkerPixelY(member)

datum/CombatTeam
	var/list/members
	var/mob/leader

	New(mob/initial_leader)
		. = ..()
		members = list()
		if(initial_leader) addMember(initial_leader, FALSE)

	proc/cleanMembers()
		if(!islist(members)) members = list()
		for(var/mob/member in members.Copy())
			if(!member || member.combat_team != src) members -= member
		if(!leader || !(leader in members)) leader = members.len ? members[1] : null
		return members.len

	proc/hasCapacity()
		return cleanMembers() < NEXUS_COMBAT_TEAM_LIMIT

	proc/isLeader(mob/member)
		return member && member == leader && (member in members)

	proc/notifyMembers(message)
		if(!message) return
		cleanMembers()
		for(var/mob/member in members)
			if(member.client) member << "<font color=#ffd83d><b>TEAM:</b> [message]"

	proc/refreshMarkers()
		cleanMembers()
		for(var/mob/member in members)
			if(member.client) member.client.syncCombatTeamMarkers()

	proc/addMember(mob/member, announce = TRUE)
		if(!member) return FALSE
		cleanMembers()
		if(member.combat_team == src && (member in members)) return TRUE
		if(member.combat_team || members.len >= NEXUS_COMBAT_TEAM_LIMIT) return FALSE
		members += member
		member.combat_team = src
		if(!leader) leader = member
		if(announce) notifyMembers("[html_encode(member.name)] joined the combat team. ([members.len]/[NEXUS_COMBAT_TEAM_LIMIT])")
		refreshMarkers()
		return TRUE

	proc/removeMember(mob/member, reason, announce = TRUE)
		if(!member || !(member in members)) return FALSE
		if(announce)
			if(reason) notifyMembers(reason)
			else notifyMembers("[html_encode(member.name)] left the combat team.")
		members -= member
		if(member.combat_team == src) member.combat_team = null
		if(member.client) member.client.clearCombatTeamMarkers()
		var/leader_changed = leader == member
		if(leader_changed) leader = members.len ? members[1] : null
		if(!members.len)
			del(src)
			return TRUE
		if(leader_changed) notifyMembers("[html_encode(leader.name)] is now the team leader.")
		refreshMarkers()
		return TRUE

	proc/disband(mob/requester, announce = TRUE)
		cleanMembers()
		if(requester && !isLeader(requester)) return FALSE
		if(announce) notifyMembers("The combat team was disbanded.")
		var/list/old_members = members.Copy()
		members.Cut()
		leader = null
		for(var/mob/member in old_members)
			if(member.combat_team == src) member.combat_team = null
			if(member.pending_combat_team == src) member.pending_combat_team = null
			if(member.client) member.client.clearCombatTeamMarkers()
		del(src)
		return TRUE

mob/proc/isCombatTeammate(mob/other)
	return other && combat_team && other.combat_team == combat_team

mob/proc/createCombatTeam(announce = TRUE)
	if(combat_team) return combat_team
	var/datum/CombatTeam/new_team = new(src)
	if(announce) src << "<font color=#ffd83d><b>TEAM:</b> Combat team created. You can invite up to [NEXUS_COMBAT_TEAM_LIMIT - 1] nearby players."
	return new_team

mob/proc/leaveCombatTeam(reason, announce = TRUE)
	var/datum/CombatTeam/old_team = combat_team
	if(!old_team) return FALSE
	return old_team.removeMember(src, reason, announce)

mob/proc/showCombatTeamMembers()
	if(!combat_team)
		src << "<font color=#9aa4b2>You are not in a combat team."
		return
	combat_team.cleanMembers()
	src << "<font color=#ffd83d><b>COMBAT TEAM ([combat_team.members.len]/[NEXUS_COMBAT_TEAM_LIMIT])</b>"
	for(var/mob/member in combat_team.members)
		var/member_role = combat_team.leader == member ? "LEADER" : "MEMBER"
		var/member_state = member.client ? "ONLINE" : "OFFLINE"
		src << "<font color=#f6e7a8>[member_role] | [member_state] | [html_encode(member.name)]"

mob/proc/inviteCombatTeamMember()
	if(!client || !playerCharacter) return FALSE
	var/datum/CombatTeam/current_team = combat_team
	if(!current_team) current_team = createCombatTeam()
	if(!current_team || !current_team.isLeader(src))
		src << "<font color=#9aa4b2>Only the team leader can invite players."
		return FALSE
	if(!current_team.hasCapacity())
		src << "<font color=#9aa4b2>Your combat team already has [NEXUS_COMBAT_TEAM_LIMIT] members."
		return FALSE
	var/list/candidates = list()
	for(var/mob/candidate in mob_view(NEXUS_COMBAT_TEAM_INVITE_RANGE, src))
		if(candidate == src || !candidate.client || !candidate.playerCharacter || candidate.combat_team || candidate.pending_combat_team) continue
		candidates += candidate
	if(!candidates.len)
		src << "<font color=#9aa4b2>No available players are nearby."
		return FALSE
	var/mob/candidate = input(src, "Invite a nearby player. Team members receive a private yellow arrow above one another.", "Combat Team") as null|anything in candidates
	if(!candidate) return FALSE
	if(candidate.combat_team || candidate.pending_combat_team || !candidate.client || !candidate.playerCharacter || candidate.z != z || bounds_dist(src, candidate) / world.icon_size > NEXUS_COMBAT_TEAM_INVITE_RANGE || !viewable(src, candidate))
		src << "<font color=#9aa4b2>That player is no longer available."
		return FALSE
	candidate.pending_combat_team = current_team
	src << "<font color=#ffd83d><b>TEAM:</b> Invitation sent to [html_encode(candidate.name)]."
	var/invite_choice = alert(candidate, "[src] invited you to a combat team (maximum [NEXUS_COMBAT_TEAM_LIMIT] players). Team members are marked with a yellow arrow.", "Combat Team Invitation", "Accept", "Decline")
	if(candidate && candidate.pending_combat_team == current_team) candidate.pending_combat_team = null
	if(invite_choice != "Accept")
		var/candidate_name = candidate ? html_encode(candidate.name) : "That player"
		if(src && client) src << "<font color=#9aa4b2>[candidate_name] declined the team invitation."
		return FALSE
	if(!src || !client || !current_team || combat_team != current_team || !current_team.isLeader(src) || !current_team.hasCapacity()) return FALSE
	if(!candidate || !candidate.client || candidate.combat_team) return FALSE
	return current_team.addMember(candidate)

mob/proc/removeCombatTeamMember()
	var/datum/CombatTeam/current_team = combat_team
	if(!current_team || !current_team.isLeader(src))
		src << "<font color=#9aa4b2>Only the team leader can remove players."
		return FALSE
	var/list/candidates = list()
	for(var/mob/member in current_team.members)
		if(member != src) candidates += member
	if(!candidates.len)
		src << "<font color=#9aa4b2>There are no other members to remove."
		return FALSE
	var/mob/member = input(src, "Remove which member?", "Combat Team") as null|anything in candidates
	if(!member || combat_team != current_team || !current_team.isLeader(src) || !(member in current_team.members)) return FALSE
	return current_team.removeMember(member, "[html_encode(src.name)] removed [html_encode(member.name)] from the combat team.")

mob/verb/manageCombatTeam()
	set name = "Team"
	set category = "Combat"
	if(!client || !playerCharacter) return
	var/list/options = list()
	if(!combat_team) options += "Create Team"
	else
		combat_team.cleanMembers()
		options += "View Members"
		if(combat_team.isLeader(src) && combat_team.hasCapacity()) options += "Invite Player"
		if(combat_team.isLeader(src) && combat_team.members.len > 1) options += "Remove Member"
		if(combat_team.isLeader(src)) options += "Disband Team"
		else options += "Leave Team"
	options += "Cancel"
	var/choice = input(src, "Manage your temporary combat team.", "Combat Team") as null|anything in options
	switch(choice)
		if("Create Team") createCombatTeam()
		if("View Members") showCombatTeamMembers()
		if("Invite Player") inviteCombatTeamMember()
		if("Remove Member") removeCombatTeamMember()
		if("Leave Team") leaveCombatTeam()
		if("Disband Team")
			if(combat_team && combat_team.isLeader(src) && alert(src, "Disband the combat team for everyone?", "Combat Team", "Keep Team", "Disband") == "Disband") combat_team.disband(src)
