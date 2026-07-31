//ALSO SEE THE UTILITIES.DM FILE FOR MORE




/*
FindTargets() has various wrapper function, search for FindWarpTarget() for an example of how one works and what purpose it serves
almost all uses should be thru wrapper functions. even melee combat
*/

atom/movable/var/tmp/mob/auto_target
mob/var/tmp/mob/selected_target
client/var/tmp/image/selected_target_marker

var/icon/selected_target_marker_icon

proc/getSelectedTargetMarkerIcon()
	if(selected_target_marker_icon) return selected_target_marker_icon
	selected_target_marker_icon = icon('Healthbar.dmi', "100")
	selected_target_marker_icon.Scale(32, 32)
	selected_target_marker_icon.DrawBox(null, 1, 1, 32, 32)
	var/marker_color = "#28d7ff"
	selected_target_marker_icon.DrawBox(marker_color, 1, 1, 8, 2)
	selected_target_marker_icon.DrawBox(marker_color, 1, 1, 2, 8)
	selected_target_marker_icon.DrawBox(marker_color, 25, 1, 32, 2)
	selected_target_marker_icon.DrawBox(marker_color, 31, 1, 32, 8)
	selected_target_marker_icon.DrawBox(marker_color, 1, 31, 8, 32)
	selected_target_marker_icon.DrawBox(marker_color, 1, 25, 2, 32)
	selected_target_marker_icon.DrawBox(marker_color, 25, 31, 32, 32)
	selected_target_marker_icon.DrawBox(marker_color, 31, 25, 32, 32)
	return selected_target_marker_icon

mob/proc/canSelectTarget(mob/candidate)
	if(!candidate || candidate == src || !candidate.loc) return FALSE
	if(candidate.type == /mob/Body || !candidate.attackable) return FALSE
	if(candidate.invisibility > see_invisible) return FALSE
	return TRUE

mob/proc/setSelectedTarget(mob/new_target, announce = TRUE)
	if(new_target && !canSelectTarget(new_target)) new_target = null
	var/mob/old_target = selected_target
	if(client && client.selected_target_marker)
		client.images -= client.selected_target_marker
		del(client.selected_target_marker)
		client.selected_target_marker = null
	selected_target = new_target
	auto_target = null
	if(new_target)
		Target = new_target
		if(client)
			client.selected_target_marker = image(icon = getSelectedTargetMarkerIcon(), loc = new_target, layer = 99)
			client.images += client.selected_target_marker
		if(announce && old_target != new_target) src << "<font color=#28d7ff>Target selected: [new_target]."
	else
		if(Target == old_target) Target = null
		if(announce && old_target) src << "<font color=#9aa4b2>Target cleared."
	return selected_target

mob/proc/getSelectedTarget(mob/expected_target, max_dist = 0, require_view = TRUE, allow_ko = FALSE, require_attackable = TRUE, dir_angle = 0, angle_limit = 0)
	var/mob/current_target = selected_target
	if(expected_target && current_target != expected_target) return
	if(!canSelectTarget(current_target) || current_target.z != z)
		setSelectedTarget(null, FALSE)
		return
	if(require_attackable && !current_target.attackable) return
	if(!allow_ko && current_target.KO) return
	if(max_dist > 0 && bounds_dist(src, current_target) / world.icon_size > max_dist) return
	if(require_view && !viewable(src, current_target)) return
	if(angle_limit > 0)
		if(!dir_angle) dir_angle = dir
		dir_angle = dir_to_angle_0_360(dir_angle)
		var/target_angle = abs(ShortestDegreesBetweenAngles(dir_angle, get_global_angle(src, current_target)))
		if(target_angle > angle_limit) return
	return current_target

mob/verb/selectTarget()
	set name = "Select Target"
	set category = "Combat"
	var/list/candidates = list()
	for(var/mob/candidate in mob_view(50, src))
		if(!canSelectTarget(candidate)) continue
		if(candidate.client && candidate.playerCharacter || istype(candidate, /mob/CombatDummy)) candidates += candidate
	if(!candidates.len)
		src << "No selectable players or combat dummies are nearby."
		return
	var/mob/choice = input(src, "Select a combat target.", "Target Selection") as null|anything in candidates
	if(!choice) return
	if(!(choice in mob_view(50, src)) || !(choice.client && choice.playerCharacter || istype(choice, /mob/CombatDummy)) || !canSelectTarget(choice))
		src << "That target is no longer selectable."
		return
	setSelectedTarget(choice)

mob/verb/clearTarget()
	set name = "Clear Target"
	set category = "Combat"
	setSelectedTarget(null)

atom/movable/proc
	//dir_angle is like which way src is facing usually
	FindTarget(dir_angle=NORTH, angle_limit=33, max_dist=9, prefer_auto_target=1)
		var/list/targets = FindTargets(dir_angle, angle_limit, max_dist, prefer_auto_target)
		if(!targets) return
		return targets[1]

	IsValidTarget(mob/m, max_dist=10)
		if(m && z==m.z && bounds_dist(src,m)/world.icon_size <= max_dist && viewable(src,m)) return 1

	FindTargets(dir_angle=NORTH, angle_limit=33, max_dist=9, prefer_auto_target=0)

		dir_angle = dir_to_angle_0_360(dir_angle) //converts NSEW etc to a number between 0 and 360

		var/list/targets

		for(var/mob/m in mob_view(max_dist,src)) if(m != src)

			var/angle = abs(ShortestDegreesBetweenAngles(dir_angle,get_global_angle(src,m)))
			var/dist = bounds_dist(src,m) / world.icon_size
			if(dist > max_dist || angle > angle_limit) continue

			if(IsValidTarget(m, max_dist = max_dist))
				if(!targets) targets = new/list

				var/rating = 1 / (angle + 10) //+10 to prevent division by zero but also for distance influence reasons
				rating /= 1 + dist * 0.075

				targets[m] = rating

		if(!targets) return
		targets = BubbleSort(targets)

		//makes it as if the auto target has the best target rating in the list
		if(prefer_auto_target && auto_target && IsValidTarget(auto_target, max_dist = max_dist))
			targets -= auto_target
			targets.Insert(1,auto_target)

		auto_target = targets[1]
		return targets

proc/pixel_dir(mob/a,mob/b)
	var/ang = get_global_angle(a,b)
	return angle_to_dir(ang)

//probably useless
proc/pixel_dir_old(mob/a,mob/b)
	var
		ax=a.step_x + a.x * world.icon_size
		ay=a.step_y + a.y * world.icon_size
		bx=b.step_x + b.x * world.icon_size
		by=b.step_y + b.y * world.icon_size
	if(by>ay)
		if(bx>ax) return NORTHEAST
		if(bx<ax) return NORTHWEST
		return NORTH
	if(by<ay)
		if(bx>ax) return SOUTHEAST
		if(bx<ax) return SOUTHWEST
		return SOUTH
	if(bx>ax) return EAST
	return WEST

	/*var
		ax=a.bound_center_x()
		ay=a.bound_center_y()
		bx=b.bound_center_x()
		by=b.bound_center_y()
	if(by>ay)
		if(bx>ax) return NORTHEAST
		if(bx<ax) return NORTHWEST
		return NORTH
	if(by<ay)
		if(bx>ax) return SOUTHEAST
		if(bx<ax) return SOUTHWEST
		return SOUTH
	if(bx>ax) return EAST
	return WEST*/

proc/num_between(n,Min,Max)
	if(n >= Min && n <= Max) return 1

proc/angle_to_dir(ang)
	ang = angle_clamp_0_360(ang)
	if(num_between(ang,0,22.5)) return NORTH
	else if(num_between(ang,22.5,67.5)) return NORTHEAST
	else if(num_between(ang,67.5,112.5)) return EAST
	else if(num_between(ang,112.5,157.5)) return SOUTHEAST
	else if(num_between(ang,157.5,202.5)) return SOUTH
	else if(num_between(ang,202.5,247.5)) return SOUTHWEST
	else if(num_between(ang,247.5,292.5)) return WEST
	else if(num_between(ang,292.5,337.5)) return NORTHWEST
	else if(num_between(ang,337.5,360)) return NORTH
	world<<"INVALID ANGLE ERROR: [ang]"

//IM NOT SURE THIS FUNCTION WILL WORK IN ALL CASES ANYMORE SINCE I DID A LOT OF RIGGING TO GET IT TO WORK, BUT I DID SO WITHOUT UNDERSTANDING WHY IT WORKS
proc/ShortestDegreesBetweenAngles(start=0,end=0) //tells the shortest path from one angle to another, if going backwards thru zero is faster it'll show that
	//for example if start is 5 and end is 350, this returns -15, not +345
	if(end>=start) return ((end - start) + 180) % 360 - 180
	else return ((end - start) - 180) % 360 + 180

//highest values will be first in the list
proc/BubbleSort(list/l)
	var/i, j
	for(i=l.len,i>0,i--)
		for(j=1,j<i,j++)
			if(l[l[j]]<l[l[j+1]])
				l.Swap(j,j+1)
	return l
