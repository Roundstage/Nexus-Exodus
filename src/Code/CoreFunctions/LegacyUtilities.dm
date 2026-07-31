obj/proc/MakeImmovableIndestructable()
	Health = 1.#INF
	Dead_Zone_Immune = 1
	Knockable = 0
	//Bolted = 1
	Grabbable = 0
	Cloakable = 0
	can_blueprint = 0

proc/View(r,c)
	return view(r,c)

proc/Missile(t,s,e)
	missile(t,s,e)

proc/Get_step(mob/m,D)
	return get_step(m,D)

// Disabled because removing nulls changes hotbar key ordering.
proc/Remove_all_nulls()
	set waitfor=0
	while(1)
		return
