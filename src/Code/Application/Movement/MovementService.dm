var/global/datum/MovementService/movement_service = new /datum/MovementService

// Application-level movement service (adapter). Keeps movement logic centralized
datum/MovementService
	proc/AllowMove(mob/m, D)
		if(!m) return
		Debug("MovementService: AllowMove")
		// reuse existing mob helpers where appropriate to keep refactor incremental
		if(m._allow_move_prechecks(D)) return
		if(!m.Can_Move()) return
		if(m.icon_state == "KB" || m.KB || !m.move) return
		if(m._allow_move_handle_kiting_and_finalize(D)) return
		return 1
