var/client_fps = 100

proc/Get_Pixel(mob/O,x,y)
	var/icon/I=new(O.icon)
	if(ismob(O)&&O.client) return I.GetPixel(x,y)
	else return I.GetPixel(x,y,O.icon_state)

proc/Generate_Bounding_Box(obj/O,Test)
	if(!O.icon) return
	O.bound_height=1
	O.bound_width=1
	var/H=GetHeight(O.icon)
	var/W=GetWidth(O.icon)
	for(var/x in 1 to W) for(var/y in 1 to H) if(Get_Pixel(O,x,y))
		if(!O.bound_x||O.bound_x>x) O.bound_x=x
		if(!O.bound_y||O.bound_y>y) O.bound_y=y
		if(O.bound_width<x-O.bound_x) O.bound_width=x-O.bound_x
		if(O.bound_height<y-O.bound_y) O.bound_height=y-O.bound_y
		//world<<"[O.bound_width],[O.bound_height]"
	O.bound_height=round(O.bound_height*0.7)
