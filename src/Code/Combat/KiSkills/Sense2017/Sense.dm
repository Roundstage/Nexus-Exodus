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

	New()
		//verbs = new //new/list
		//verbs = null
		for(var/v in verbs) verbs -= v
		. = ..()

	Del()
		screen_indicator_cache -= src
		screen_indicator_cache += src
		loc = null
		target = null

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
			list/nexus_sense_readouts = new
			next_nexus_sense_refresh = 0
			next_nexus_sense_arrow_refresh = 0

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

		refreshNexusSenseReadouts()
			if(!client || !current_area || !hasNexusSenseDisplay())
				clearNexusSenseReadouts()
				return
			if(!islist(nexus_sense_readouts)) nexus_sense_readouts = list()
			var/list/active_targets = list()
			for(var/mob/target in current_area.mob_list)
				if(target == src || target.type == /mob/Body || target.unsenseable || !target.loc) continue
				if(target.locz() != locz() || !CanSense(src, target)) continue
				active_targets[target] = TRUE
				var/image/readout = nexus_sense_readouts[target]
				if(!readout)
					readout = image(icon = null, loc = target)
					readout.layer = 1000
					readout.maptext_width = 96
					readout.maptext_height = 12
					readout.mouse_opacity = 0
					nexus_sense_readouts[target] = readout
					client.images += readout
				readout.maptext_x = getNexusOverheadVitalsBasePixelX(target) - 32
				readout.maptext_y = getNexusOverheadPercentagePixelY(target)
				var/power_percent = Sense_Power(target)
				readout.maptext = "<div style='font-family:Courier New;font-size:7px;font-weight:bold;text-align:center;color:#9de8ff;text-shadow:1px 1px #000'>[power_percent]%</div>"
			for(var/mob/old_target in nexus_sense_readouts.Copy())
				if(active_targets[old_target]) continue
				var/image/old_readout = nexus_sense_readouts[old_target]
				if(old_readout) client.images -= old_readout
				nexus_sense_readouts -= old_target

		UpdateSenseArrowPositionsLoop()
			set waitfor=0
			while(1)
				if(client)
					UpdateSenseArrowPositions()
					if(world.time >= next_nexus_sense_arrow_refresh)
						UpdateSenseArrowList(current_area)
						next_nexus_sense_arrow_refresh = world.time + 50
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

			if(!CanSense(src,si.target) || si.target.locz() != locz()) si.alpha = 0
			else
				si.alpha = 116

				if(world.time - si.last_size_update > 10)
					UpdateSenseArrowSizeBasedOnPower(si)
					si.last_size_update = world.time

				if(world.time - si.last_appearance_update > 25)
					si.SenseArrowMatchAppearance(update_overlays = prob(20))
					si.last_appearance_update = world.time

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
			if(client) client.screen -= si
			sense_arrows -= si
			del(si)

		AddSenseArrow(obj/Screen_Indicator/si, clr)
			if(!client) return
			client.screen += si
			sense_arrows += si
			UpdateSenseArrowPosition(si, instant_update = 1)
			if(clr) si.color = clr

		RemoveAllSenseArrows()
			for(var/obj/o in sense_arrows) RemoveSenseArrow(o)
			sense_arrows = new/list

		UpdateSenseArrowList(area/a)
			RemoveAllSenseArrows()
			if(!a || !hasNexusSenseDisplay())
				clearNexusSenseReadouts()
				return
			for(var/mob/m in a.player_list)
				if(m != src)
					var/obj/Screen_Indicator/si = GetNewScreenIndicator()
					si.target = m
					si.SenseArrowMatchAppearance()
					AddSenseArrow(si, clr = GetSenseArrowColor(m))

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
			last_sense_target_update = 0 //world.time
			sense_update_queued
			max_sense_target_update_rate = 50
	proc
		//whenever someone enters or exits an area it updates sense targets for everyone
		AreaUpdateSenseTargets()
			if(sense_update_queued) return
			sense_update_queued = 1
			if(world.time - last_sense_target_update < max_sense_target_update_rate)
				sleep(max_sense_target_update_rate - (world.time - last_sense_target_update))

			for(var/mob/m in player_list)
				if(m.client)
					m.UpdateSenseArrowList(src)

			last_sense_target_update = world.time
			sense_update_queued = 0

var/list/screen_indicator_cache = new

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
			/*animate(si) //stop all animations
			si.transform = matrix()
			si.target = null
			si.alpha = 255
			si.color = null*/

		else si = new
		return si
