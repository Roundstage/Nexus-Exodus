mob/proc/Can_Move()
	if(KB || !move || Disabled()) return
	else return 1

mob/proc/Edge_Check(turf/old_loc)
	set waitfor=0

	return //disabled til fixed

	if(!Flying)
		var/turf/T=Get_step(old_loc,dir)
		if(T)
			if(!T.Enter(src)) return
			for(var/obj/Edges/A in loc)
				Bump(A)
				if(A) if(!(A.dir in list(dir,turn(dir,90),turn(dir,-90),turn(dir,45),turn(dir,-45))))
					SafeTeleport(old_loc)
					break
			for(var/obj/Edges/A in old_loc)
				Bump(A)
				if(A) if(A.dir in list(dir,turn(dir,45),turn(dir,-45)))
					SafeTeleport(old_loc)
					break

mob/proc/Save_Location() if(z&&!Regenerating)
	saved_x=x
	saved_y=y
	saved_z=z

mob/proc/Cease_training()
	set waitfor=0
	if(Action=="Training") Train()
	if(Action=="Meditating") Meditate()
	//if(auto_train) AI_Train()
	if(Shadow_Sparring) Shadow_Spar()
