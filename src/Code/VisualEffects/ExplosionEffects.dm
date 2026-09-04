var/list/explosion_cache=new

proc/Get_explosion()
	var/obj/Explosion/e
	for(var/obj/o in explosion_cache)
		e=o
		break
	if(!e) e=new/obj/Explosion
	explosion_cache-=e
	e.Explosion()
	return e

obj/Explosion
	layer=MOB_LAYER+1
	Nukable=0
	Savable=0
	Makeable=0
	Givable=0
	density=0
	Health=1.#INF
	icon_state="1"
	//blend_mode=BLEND_ADD

	proc/Explosion()
		set waitfor=0
		sleep(world.tick_lag)
		CenterIcon(src)
		for(var/v in 1 to 4)
			icon_state="[v]"
			sleep(1)
		del(src)

	Del()
		SafeTeleport(null)
		explosion_cache+=src

var/list/explosion_icons

proc/Initialize_explosion_icons()
	if(explosion_icons) return
	explosion_icons=new/list
	for(var/v in 1 to 5)
		var/icon/i='Explosion12013.dmi'
		var/size = 1.3
		i=Scaled_Icon(i, GetWidth(i) * (1.5 ** v) * size, GetHeight(i) * (1.5 ** v) * size)
		explosion_icons+=i

proc/Explosion_Graphics(atom/O,Distance=1,not_used=0)
	set waitfor=0
	//not_used is a 3rd arg from the old explosion graphics, remove it whenever
	Initialize_explosion_icons()
	if(!O) return
	showNexusExplosionLight(O, Distance)
	var/obj/Explosion/e=Get_explosion()
	e.SafeTeleport(O.base_loc())
	var/i=Clamp(Distance,0,explosion_icons.len)
	e.icon=explosion_icons[i]



proc/Explosion_Count(list/L)
	var/Amount=0
	for(var/obj/Explosion/E in L) Amount+=1
	return Amount

turf/proc/Make_Damaged_Ground(Amount=1) if(!Water)

	return //doesnt look good

	Amount=1
	var/O=0
	for(var/A in overlays) O+=1
	if(O>=1) return
	while(Amount)
		Amount-=1
		var/image/I=image(icon='Crack.dmi',pixel_x=rand(-0,0),pixel_y=rand(-0,0),layer=3.1)
		overlays+=I
		Remove_Damaged_Ground(I)

turf/proc/Remove_Damaged_Ground(image/I)
	set waitfor=0
	sleep(rand(600,3000))
	overlays-=I
