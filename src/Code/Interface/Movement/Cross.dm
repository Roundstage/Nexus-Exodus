//engine hooks for cross, bump, and enter
atom/movable/Cross(atom/movable/a)
	var/decision = MovementCrossDecision(a)
	if(decision != null) return decision
	return ..()

mob/Bump(mob/A)
	MovementBump(A)

turf/Enter(mob/m)
	var/return_value = ..()

	// Flying bypass for dense turfs (Walls)
	if(!return_value && ismob(m) && m.Flying)
		// Check if really blocked by an object (like a Door)
		var/blocked_by_object = 0
		for(var/atom/movable/A in src)
			if(A.density && !A.Cross(m))
				blocked_by_object = 1
				break
		if(!blocked_by_object) return_value = 1

	return MovementEnterResult(m, return_value)
