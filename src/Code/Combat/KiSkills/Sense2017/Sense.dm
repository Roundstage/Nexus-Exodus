mob/var/tmp/testing_sense = TRUE

mob/verb/Toggle_Sense_Overlay()
	set category = "Other"
	testing_sense = TRUE
	UpdateSenseArrowList(current_area)
	src << "Sense tracking is always active while you have Sense or a scanner."

obj/Screen_Indicator
	Savable=0
	Health=1.#INF
	Dead_Zone_Immune=1
	Knockable=0
	Bolted=1
	Grabbable=0
	Cloakable=0
	can_blueprint=0
	layer = 999
	plane = NEXUS_FIXED_HUD_PLANE

	//mouse_opacity = 2
	mouse_opacity = 0 //i switched it off of 2 because clicking your char would often instead click a sense arrow and it was annoying so this was the easiest
	//way, not like clicking sense arrows is very important anyway

	icon = 'ScreenArrow.dmi'
	icon_state = "arrow"
	screen_loc = "CENTER"

	var
		tmp
			atom/movable/target
			base_trans_size = 0.7
			last_size_update = 0
			last_appearance_update = 0
			last_source_cx
			last_source_cy
			last_target_cx
			last_target_cy
			last_can_sense = FALSE
			next_visibility_update = 0

	New()
		//verbs = new //new/list
		//verbs = null
		for(var/v in verbs) verbs -= v
		. = ..()

	Del()
		if(screen_indicator_cache.len < screen_indicator_cache_retention_limit)
			screen_indicator_cache -= src
			screen_indicator_cache += src
			loc = null
			target = null
		else
			reallyDelete = TRUE
			. = ..()

	proc
		SenseArrowMatchAppearance(update_overlays = 1)
			if(!target) return
			var/mob/m = target
			//appearance = m.appearance
			icon = m.icon
			icon_state = m.icon_state
			dir = m.dir
			name = m.name
			//because updating overlays seems to cause a lot of cpu use
			if(update_overlays)
				overlays = m.overlays
				underlays = m.underlays

	Click()
		if(target) target.Click(usr)

var
	sense_arrow_update_rate = 2.5

mob
	var
		tmp
			list/sense_arrows = new
			list/sense_arrow_by_target = new
			list/nexus_sense_readouts = new
			next_nexus_sense_refresh = 0
			next_nexus_sense_arrow_refresh = 0
			area/last_nexus_sense_area
			last_nexus_sense_area_revision = -1
			last_nexus_sense_enabled = FALSE

	proc
		hasNexusSenseDisplay()
			if(Scouter || Cyber_Scanner) return TRUE
			if(Android) return FALSE
			if(sense_obj && sense_obj.loc == src) return TRUE
			if(locate(/obj/Sense) in src) return TRUE
			if(locate(/obj/Advanced_Sense) in src) return TRUE
			if(locate(/obj/Sense3) in src) return TRUE
			return FALSE

		clearNexusSenseReadouts()
			if(!islist(nexus_sense_readouts)) nexus_sense_readouts = list()
			if(client)
				for(var/mob/old_target in nexus_sense_readouts)
					var/image/old_readout = nexus_sense_readouts[old_target]
					if(old_readout) client.images -= old_readout
			nexus_sense_readouts = list()

		removeNexusSenseReadout(mob/target)
			if(!islist(nexus_sense_readouts)) nexus_sense_readouts = list()
			var/image/readout = nexus_sense_readouts[target]
			if(readout && client) client.images -= readout
			nexus_sense_readouts -= target

		ensureNexusSenseReadout(mob/target)
			if(!client || !target) return
			if(!islist(nexus_sense_readouts)) nexus_sense_readouts = list()
			var/image/readout = nexus_sense_readouts[target]
			if(readout) return readout
			readout = image(icon = null, loc = target)
			readout.layer = 1000
			readout.maptext_width = 96
			readout.maptext_height = 12
			readout.mouse_opacity = 0
			nexus_sense_readouts[target] = readout
			client.images += readout
			return readout

		syncNexusSenseReadouts(area/a)
			if(!client || !current_area || !hasNexusSenseDisplay())
				clearNexusSenseReadouts()
				return
			if(a != current_area) a = current_area
			if(!islist(nexus_sense_readouts)) nexus_sense_readouts = list()
			var/list/active_targets = list()
			for(var/mob/target in a.mob_list)
				if(target == src || target.type == /mob/Body || target.unsenseable || !target.loc) continue
				if(target.locz() != locz() || !CanSense(src, target)) continue
				active_targets[target] = TRUE
				ensureNexusSenseReadout(target)
			for(var/mob/old_target in nexus_sense_readouts.Copy())
				if(active_targets[old_target]) continue
				removeNexusSenseReadout(old_target)
			refreshNexusSenseReadouts()

		refreshNexusSenseReadouts()
			if(!client || !current_area || !hasNexusSenseDisplay())
				clearNexusSenseReadouts()
				return
			if(!islist(nexus_sense_readouts)) nexus_sense_readouts = list()
			for(var/mob/target in nexus_sense_readouts.Copy())
				if(!target || !target.loc || target.current_area != current_area || target.locz() != locz() || !CanSense(src, target))
					removeNexusSenseReadout(target)
					continue
				var/image/readout = nexus_sense_readouts[target]
				if(!readout) continue
				readout.maptext_x = getNexusOverheadVitalsBasePixelX(target) - 32
				readout.maptext_y = getNexusOverheadPercentagePixelY(target)
				var/power_percent = Sense_Power(target)
				readout.maptext = "<div style='font-family:Courier New;font-size:7px;font-weight:bold;text-align:center;color:#9de8ff;text-shadow:1px 1px #000'>[power_percent]%</div>"

		UpdateSenseArrowPositionsLoop()
			set waitfor=0
			while(1)
				if(client)
					UpdateSenseArrowPositions()
					var/area/a = current_area
					var/sense_enabled = hasNexusSenseDisplay()
					if(sense_enabled != last_nexus_sense_enabled || a != last_nexus_sense_area || (a && a.sense_target_revision != last_nexus_sense_area_revision) || world.time >= next_nexus_sense_arrow_refresh)
						UpdateSenseArrowList(current_area)
						next_nexus_sense_arrow_refresh = world.time + 300
					if(world.time >= next_nexus_sense_refresh)
						refreshNexusSenseReadouts()
						next_nexus_sense_refresh = world.time + 10
				sleep(sense_arrow_update_rate)

				var/inactive_time = 600
				if(client && client.inactivity > inactive_time)
					while(client && client.inactivity > inactive_time) sleep(5)

		UpdateSenseArrowPositions()
			if(!client) return
			var/area/a = current_area
			if(!a)
				RemoveAllSenseArrows()
				return
			for(var/obj/Screen_Indicator/si in sense_arrows)
				UpdateSenseArrowPosition(si)

		UpdateSenseArrowPosition(obj/Screen_Indicator/si, instant_update = 0)
			if(!client) return

			if(!si.target)
				RemoveSenseArrow(si)
				return

			var/source_cx = Cx()
			var/source_cy = Cy()
			var/target_cx = si.target.Cx()
			var/target_cy = si.target.Cy()
			var/position_changed = source_cx != si.last_source_cx || source_cy != si.last_source_cy || target_cx != si.last_target_cx || target_cy != si.last_target_cy
			si.last_source_cx = source_cx
			si.last_source_cy = source_cy
			si.last_target_cx = target_cx
			si.last_target_cy = target_cy

			if(instant_update || world.time >= si.next_visibility_update)
				var/was_senseable = si.last_can_sense
				si.last_can_sense = CanSense(src, si.target) && si.target.locz() == locz()
				si.next_visibility_update = world.time + 10
				si.alpha = si.last_can_sense ? 116 : 0
				if(si.last_can_sense && !was_senseable) position_changed = TRUE

				if(world.time - si.last_size_update > 10)
					UpdateSenseArrowSizeBasedOnPower(si)
					si.last_size_update = world.time

				if(world.time - si.last_appearance_update > 25)
					si.SenseArrowMatchAppearance(update_overlays = prob(20))
					si.last_appearance_update = world.time

			if(si.last_can_sense && position_changed)
				PointArrow(si, si.target, instant_update = instant_update, dist_mod = SenseArrowDistanceMod(si), do_rotation = 0)

		SenseArrowDistanceMod(obj/Screen_Indicator/si)
			//new way but idk if it works we'll see
			var/dist = 0.5
			dist += getdist(src,si.target) / 250 * (1 - dist) * 1.4 //last number is just an arbitrary multiplier
			if(dist > 2) dist = 2
			return dist

			//original working way
			/*var/dist = 0.5
			dist += getdist(src,si.target) / 250 * (1 - dist)
			if(dist > 1) dist = 1
			return dist*/

		UpdateSenseArrowSizeBasedOnPower(obj/Screen_Indicator/si)
			var/size_mod = (Sense_Power(si.target) / 100) ** 0.4
			size_mod = Clamp(size_mod, 0.5, 1.1)
			var/new_trans_size = size_mod * si.base_trans_size
			si.transform /= si.transform_size
			si.transform *= new_trans_size
			si.transform_size = new_trans_size

		RemoveSenseArrow(obj/Screen_Indicator/si)
			if(!si) return
			var/atom/movable/old_target = si.target
			if(client) client.screen -= si
			sense_arrows -= si
			if(islist(sense_arrow_by_target) && old_target && sense_arrow_by_target[old_target] == si)
				sense_arrow_by_target -= old_target
			del(si)

		AddSenseArrow(obj/Screen_Indicator/si, clr)
			if(!client || !si || !si.target) return
			if(!islist(sense_arrow_by_target)) sense_arrow_by_target = list()
			client.screen += si
			sense_arrows += si
			sense_arrow_by_target[si.target] = si
			UpdateSenseArrowPosition(si, instant_update = 1)
			if(clr) si.color = clr

		RemoveAllSenseArrows()
			for(var/obj/o in sense_arrows.Copy()) RemoveSenseArrow(o)
			sense_arrows = new/list
			sense_arrow_by_target = new/list

		UpdateSenseArrowList(area/a)
			if(!a || !hasNexusSenseDisplay())
				RemoveAllSenseArrows()
				clearNexusSenseReadouts()
				last_nexus_sense_area = a
				last_nexus_sense_area_revision = a ? a.sense_target_revision : -1
				last_nexus_sense_enabled = FALSE
				return
			if(!islist(sense_arrow_by_target)) sense_arrow_by_target = list()
			var/list/active_targets = list()
			for(var/mob/m in a.player_list)
				if(m == src || !m.loc) continue
				active_targets[m] = TRUE
				var/obj/Screen_Indicator/si = sense_arrow_by_target[m]
				if(si) continue
				si = GetNewScreenIndicator()
				si.target = m
				si.SenseArrowMatchAppearance()
				AddSenseArrow(si, clr = GetSenseArrowColor(m))
			for(var/mob/old_target in sense_arrow_by_target.Copy())
				if(active_targets[old_target]) continue
				RemoveSenseArrow(sense_arrow_by_target[old_target])
			syncNexusSenseReadouts(a)
			last_nexus_sense_area = a
			last_nexus_sense_area_revision = a.sense_target_revision
			last_nexus_sense_enabled = TRUE

		GetSenseArrowColor(mob/m)

			return

			var/c = GetSenseArrowColorByRace(m.Race, m.Class)
			return c

		GetSenseArrowColorByRace(race, class)
			switch(race)
				if("Human")
					if(class == "Spirit Doll") return rgb(222,255,255)
					else return rgb(255,255,255)
				if("Namekian") return rgb(0,255,0)
				if("Saiyan")
					if(class == "Legendary Saiyan") return rgb(180,255,0)
					else return rgb(233,120,0)
				if("Half Saiyan") return rgb(255,190,110)
				if("Alien") return rgb(0,0,255)
				if("Android") return rgb(70,70,70)
				if("Bio-Android") return rgb(255,255,0)
				if("Demigod") return rgb(255,255,120)
				if("Demon") return rgb(255,0,0)
				if("Frost Lord") return rgb(180,0,255)
				if("Kai") return rgb(0,222,255)
				if("Makyo") return rgb(130,0,170)
				if("Kanassan") return rgb(40,180,220)
				if("Heran") return rgb(70,190,110)
				if("Majin") return rgb(255,0,233)
				if("Tsujin") return rgb(180,180,180)

area
	var
		tmp
			sense_target_revision = 0
			sense_update_queued
			max_sense_target_update_rate = 5
	proc
		//Coalesce area membership changes so each observer reconciles at most once per movement burst.
		AreaUpdateSenseTargets()
			set waitfor=0
			if(sense_update_queued) return
			sense_update_queued = 1
			sleep(max_sense_target_update_rate)
			sense_target_revision++
			sense_update_queued = 0

var/list/screen_indicator_cache = new
var/screen_indicator_cache_retention_limit = 500

proc
	GetNewScreenIndicator()
		var/obj/Screen_Indicator/si
		if(screen_indicator_cache.len)
			si = screen_indicator_cache[1]
			screen_indicator_cache -= si

			//reset needed vars
			ResetVars(si)
			si.last_size_update = 0
			si.last_appearance_update = 0
			si.last_source_cx = null
			si.last_source_cy = null
			si.last_target_cx = null
			si.last_target_cy = null
			si.last_can_sense = FALSE
			si.next_visibility_update = 0
			/*animate(si) //stop all animations
			si.transform = matrix()
			si.target = null
			si.alpha = 255
			si.color = null*/

		else si = new
		return si
