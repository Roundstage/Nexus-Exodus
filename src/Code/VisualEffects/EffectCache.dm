var/list/effect_cache = new

proc/GetEffect()
	var/obj/Effect/e
	for(var/obj/o in effect_cache)
		e = o
		effect_cache -= e
		break
	if(!e) e = new/obj/Effect

	//delete these and use the ones back in Effect/Del() when we are done running diagnostics on what effect icon is most common to fix a lag issue
	ResetVars(e)
	e.icon = null

	return e

obj/Effect
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
		loc = null
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
