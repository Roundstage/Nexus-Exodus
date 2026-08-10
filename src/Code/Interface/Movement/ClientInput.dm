client/North() return 0
client/South() return 0
client/East() return 0
client/West() return 0
client/Northwest() return 0
client/Northeast() return 0
client/Southwest() return 0
client/Southeast() return 0

client/MouseWheel(object, delta_x, delta_y, location, control, params)
	if(nexusMouseWheelCanZoomMap(control, object) && mob && mob.playerCharacter && delta_y)
		mob.adjustMapZoom(delta_y)
		return
	return ..()
