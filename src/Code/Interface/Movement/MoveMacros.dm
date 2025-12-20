//we do this to fix the bug where you can make spacepods move at double speed to run away from someone if you add
//.north .south .east .west macros to your byond macros and they'll stack together with our macros here causing you
//to move really fast
client
	North() return 0
	South() return 0
	East() return 0
	West() return 0

mob/verb/KeyDown(d as text)
	set waitfor=0
	set hidden=1
	set instant=1
	HandleKeyDown(d)

mob/verb/KeyUp(d as text)
	set waitfor=0
	set hidden=1
	set instant=1
	HandleKeyUp(d)

client
	var
		tmp
			ctrl_button = 0
			shift = 0

mob/verb
	SetCtrlStatus(status as text)
		set hidden = 1
		if(status == "0") 
			client.ctrl_button = 0
			is_ctrl_down = 0		// Adds to global escope because fuck adding whatever needs it to the  proc above
			
		else 
			client.ctrl_button = 1
			is_ctrl_down = 1
		

	ShiftDown()
		set hidden 		= 1
		client.shift 	= 1
		is_shift_down 	= 1

	ShiftUp()
		set hidden 		= 1
		client.shift 	= 0
		is_shift_down 	= 0
