proc
	//misnomer. this activates pixel gliding instead of tile gliding. simply because pixel gliding looks better imo
	//BUG. looks like somewhere in the code is some object already with a non32 step_size because even if i disable this proc now it still uses pixel gliding
	ActivatePixelMovement()
		set waitfor=0

		return

		//to force the game to use pixel interpolation instead of gliding, since it looks better
		//but yet still works with tile moving with zero problems
		var/mob/m = new(locate(5,5,1))
		m.step_size = 8
		step(m,EAST) //if the object never moves then it doesnt switch the whole game to pixel gliding for some reason
		sleep(10)
		if(m) del(m)
