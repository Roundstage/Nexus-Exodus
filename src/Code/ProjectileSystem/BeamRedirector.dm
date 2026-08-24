obj/beam_redirector //when beams are deflected this object is placed down at the spot where it was
//deflected, and the beam uses the object's dir to know which way it should then go
	icon='BeamAxis.dmi'
	Grabbable=0
	Savable=0
	layer=7
	Health=1.#INF
	New()
		overlays+=icon
		CenterIcon(src)
		the_loop()
	proc/the_loop()
		set waitfor=0
		while(src)
			var/found
			for(var/obj/Blast/b in view(1,src))
				if(src in loc)
					found=1
					break
				if(src in Get_step(b,b.dir))
					found=1
					break
			if(!found) del(src)
			sleep(2)
