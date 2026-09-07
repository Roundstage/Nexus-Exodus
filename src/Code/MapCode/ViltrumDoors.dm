// Public grouped doors: no passwords and no inherited crushing behavior.
obj/ViltrumDoor
	parent_type = /obj/Turfs/Door
	name = "Public civic door"
	icon = 'src/Icons/Turfs/Viltrum/ViltrumDoors.dmi'
	icon_state = "civic_closed"
	density = TRUE
	opacity = TRUE
	Health = 1.#INF
	Password = ""
	Grabbable = FALSE
	Givable = FALSE
	Savable = FALSE
	Knockable = FALSE
	var
		door_material = "civic"
		door_group = ""
		door_busy = FALSE
	New()
		icon_state = "[door_material]_closed"
		// Skip the legacy door constructor's delayed crushing/setup behavior.
		return
	Cross(atom/movable/mover)
		if(ismob(mover))
			if(density && !door_busy) Open()
			return !density
		return ..()
	Click()
		if(usr && usr.z == z && get_dist(usr,src) <= 1) Open()
	Open()
		if(door_busy || !density || !loc) return
		for(var/obj/ViltrumDoor/panel in getDoorPanels()) panel.openDoorPanel()
		spawn(44)
			if(src && loc) Close()
	Close()
		if(!loc) return
		var/list/panels = getDoorPanels()
		for(var/obj/ViltrumDoor/panel in panels)
			for(var/mob/occupant in panel.loc)
				spawn(10)
					if(src && loc) Close()
				return
		for(var/obj/ViltrumDoor/panel in panels) panel.closeDoorPanel()
	proc/getDoorPanels()
		var/list/panels = list(src)
		if(door_group)
			for(var/obj/ViltrumDoor/panel in range(5,src))
				if(panel.door_group == door_group) panels |= panel
		return panels
	proc/openDoorPanel()
		if(door_busy || !density) return
		door_busy = TRUE
		icon_state = "[door_material]_opening"
		spawn(3)
			if(!src) return
			icon_state = "[door_material]_open"
			density = FALSE
			opacity = FALSE
			door_busy = FALSE
	proc/closeDoorPanel()
		if(door_busy || density) return
		door_busy = TRUE
		icon_state = "[door_material]_closing"
		spawn(3)
			if(!src) return
			// Recheck occupants after animation, before enabling collision.
			var/occupied = FALSE
			for(var/mob/occupant in loc) occupied = TRUE
			icon_state = occupied ? "[door_material]_open" : "[door_material]_closed"
			density = !occupied
			opacity = !occupied
			door_busy = FALSE
	Palace
		name = "Imperial audience door"
		door_material = "palace"
		icon_state = "palace_closed"
	Laboratory
		name = "Laboratory door"
		door_material = "laboratory"
		icon_state = "laboratory_closed"
	Hangar
		name = "Transit hangar door"
		door_material = "hangar"
		icon_state = "hangar_closed"
	ForceField
		name = "Grid service force field"
		door_material = "force_field"
		icon_state = "force_field_closed"
