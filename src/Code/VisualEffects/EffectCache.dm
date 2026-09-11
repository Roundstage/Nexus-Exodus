var/list/effect_cache = new

proc/GetEffect()
	var/obj/Effect/e
	for(var/obj/o in effect_cache)
		e = o
		effect_cache -= e
		break
	if(!e) e = new/obj/Effect
	e.deferred_delete_generation++

	//delete these and use the ones back in Effect/Del() when we are done running diagnostics on what effect icon is most common to fix a lag issue
	ResetVars(e)
	e.icon = null

	return e

obj/Effect
	var/tmp/floating_text_generation = 0
	Savable=0
	Grabbable=0
	Health=1.#INF
	layer=MOB_LAYER+1
	Nukable=0
	Makeable=0
	Givable=0
	density=0
	//blend_mode=BLEND_ADD
	mouse_opacity = 0
	//Dead_Zone_Immune=1
	attackable=0

	Del()
		floating_text_generation++
		deferred_delete_generation++
		if(reallyDelete)
			effect_cache -= src
			return ..()
		loc = null
		effect_cache -= src
		effect_cache += src

		//re-enable these lines when we are done running diagnostics on which effect icon is most common and DELETE the alternative lines for these we
		//currently have in proc/GetEffect()
		//ResetVars(src)
		//icon = null

		transform = null
		color = null
		alpha = 255
		spinning = 0
		animate(src)

	proc/runFloatingText(duration = 10)
		set waitfor = FALSE
		if(!nexusIsFiniteNumber(duration)) duration = 10
		var/generation = ++floating_text_generation
		var/expires_at = world.time + max(0, duration)
		while(src && floating_text_generation == generation && world.time < expires_at)
			pixel_y += 4
			sleep(min(4, expires_at - world.time))
		if(src && floating_text_generation == generation) del(src)
