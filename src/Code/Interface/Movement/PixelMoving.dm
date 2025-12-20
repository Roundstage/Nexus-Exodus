mob/Admin4/verb/FPS()
	set category="Admin"
	var/N=input(src,"Set the frames per second of the server. A value that can be divided by 2 as many times as possible seems to run smoothest, but as long \
	as it is divisible by 2 twice it doesn't seem to make much difference after that. For example 16, is divisible by 2 four times (16, 8, 4, 2, 1) \
	and is known to work pretty good. 20 also works good (20, 10, 5), at least try to make it an even number because it makes a big difference\
	","FPS",world.fps) as num
	if(N<1) N=1
	if(N>100) N=100
	world.fps=N

	N=input(src,"Set the frames per second of the client. 100 is recommended and the max byond can do","FPS",client_fps) as num
	//trust me if you try to allow client_fps to be 999 it will be choppy, idk why. but 100 is fine
	if(N<1) N=1
	if(N > 100) N = 100
	client_fps = N
	for(var/client/c) c.fps = client_fps
