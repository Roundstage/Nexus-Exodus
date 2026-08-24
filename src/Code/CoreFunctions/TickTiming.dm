proc/TickMult(n=1)
	if(n<=0) return 0
	var/rounded=round(n,world.tick_lag)
	if(rounded>n) rounded-=world.tick_lag
	var/decimals=n-rounded
	if(prob(decimals * 100 / world.tick_lag)) rounded+=world.tick_lag

	rounded -= 0.001 //eliminate floating point errors test August 22nd 2017 dunno if it will work but its to stop missed frames

	return rounded

proc/ToOne(delay = 1)
	var/isneg = (delay < 0)
	delay = abs(delay)
	var/decimals = delay - round(delay)
	if(prob(decimals * 100)) delay++
	delay = round(delay)
	if(isneg) delay = -delay
	return delay
