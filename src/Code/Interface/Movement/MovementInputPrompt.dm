mob/proc/Input(mob/m,msg,title,default,_type,list/l)
	north=0
	south=0
	east=0
	west=0
	keys_down=new/list

	var/r

	switch(_type)
		if(null)
			r=input(m,msg,title,default) in l
		if("mob")
			r=input(m,msg,title,default) as mob in l
		if("obj")
			r=input(m,msg,title,default) as obj in l
		if("turf")
			r=input(m,msg,title,default) as turf in l
		if("area")
			r=input(m,msg,title,default) as mob in l

	return r
