turf/var/tmp/ki_water

var/image/kwns=image(icon = 'KiWater.dmi',icon_state="NS")
var/image/kwew=image(icon = 'KiWater.dmi',icon_state="EW")

turf/proc/ki_water(d)
	set waitfor=0
	if(ki_water) return
	ki_water=1
	var/image/i
	if(d in list(NORTH,SOUTH)) i=kwns
	else i=kwew
	overlays+=i
	sleep(20)
	ki_water=0
	overlays-=i
