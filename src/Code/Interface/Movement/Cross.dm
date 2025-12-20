//engine hooks for cross, bump, and enter
atom/movable/Cross(atom/movable/a)
	var/decision = MovementCrossDecision(a)
	if(decision != null) return decision
	return ..()

mob/Bump(mob/A)
	MovementBump(A)

turf/Enter(mob/m)
	var/return_value = ..()
	return MovementEnterResult(m, return_value)
