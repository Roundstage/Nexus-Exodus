// Public read-only consoles. No passwords, teleports, per-tile timers or lights.
obj/ViltrumConsole
	name = "Imperial transit directory"
	icon = 'src/Icons/Turfs/Viltrum/ViltrumObjects.dmi'
	icon_state = "console"
	density = TRUE
	opacity = FALSE
	layer = OBJ_LAYER
	plane = 0
	Health = 1.#INF
	Grabbable = FALSE
	Givable = FALSE
	Savable = FALSE
	Knockable = FALSE
	var/status_text = "North: Capital Forum and public archive. South: Imperial terminal and landing apron. East and west terraces provide alternate routes."
	Click()
		if(!usr || usr.z != z || get_dist(usr, src) > 2) return
		usr << "[name]: [status_text]"
	Reactor
		name = "Civic energy regulator"
		icon_state = "reactor"
		status_text = "Civic power is online. This regulator serves the public archive and transit concourse. The lateral maintenance approaches remain open."
		Click()
			if(!usr || usr.z != z || get_dist(usr, src) > 2) return
			..()
			usr << "Regulator diagnostic: [world.timeofday] ticks; Viltrum surface grid responding."
