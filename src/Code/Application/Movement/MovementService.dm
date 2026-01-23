var/global/datum/MovementService/movement_service = new /datum/MovementService

// Application-level movement service (adapter). Keeps movement logic centralized
datum/MovementService
	proc/AllowMove(mob/m, D)
		if(!m) return
		Debug("MovementService: AllowMove")
		// reuse existing mob helpers where appropriate to keep refactor incremental
		var/attack_lock = m.IsAttackMovementLocked()
		if(attack_lock)
			// Allow aiming (changing dir) for certain skills even when movement is locked
			if(istype(attack_lock, /obj/Attacks))
				var/obj/Attacks/A = attack_lock
				if(A.streaming || A.charging)
					m.dir = D
			return
		if(m._allow_move_prechecks(D)) return
		if(!m.Can_Move()) return
		if(m.icon_state == "KB" || m.KB || !m.move) return
		if(m._allow_move_handle_kiting_and_finalize(D)) return
		return 1
