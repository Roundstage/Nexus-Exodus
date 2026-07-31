// Apply all injuries from a car wreck to the person hit.
obj/Car
	Health=1.#INF
	icon='Car.dmi'
	density=1
	var/mob/tmp/car_target
	Savable=0
	New()
		icon_state="[rand(1,63)]"
		transform*=2
		Car_AI()
		. = ..()
	proc/Car_AI()
		set waitfor=0
		sleep(1)
		spawn while(src)
			player_range(30,src)<<sound('Racing.ogg',volume=50)
			sleep(114)
		while(src)
			if(car_target&&car_target.z==z)
				if(prob(17)) step_towards(src,car_target)
				else step(src,pick(turn(dir,45),turn(dir,-45)))
			else
				for(var/v in 1 to 20)
					step(src,dir)
					sleep(1)
				del(src)
			sleep(1)
	Move()
		if(prob(5)) player_range(30,src)<<sound('TireSlide.ogg',volume=50)
		. = ..()
	Bump(mob/m)
		if(!car_target&&ismob(m))
			SafeTeleport(m.loc)
			return
		var/s=pick('BigCrash.ogg','LongCrash.ogg','SmallCrash.ogg')
		player_range(30,src)<<sound(s,volume=50)
		if(isturf(m)) for(var/turf/t in range(1,src)) if(t.density&&t.Health!=1.#INF)
			Explosion_Graphics(src,rand(2,4))
			Make_Shockwave(src)
			t.destroy_turf()
		if(isobj(m))
			Explosion_Graphics(src,rand(2,4))
			Make_Shockwave(src)
			SafeTeleport(m.loc)
		if(ismob(m))
			Explosion_Graphics(src,rand(2,4))
			Make_Shockwave(src)
			player_range(30,src)<<sound('Squished.ogg',volume=100)
			car_target=null

var/car_wreck_frequency=0

mob/Admin4/verb/carWreckFrequency()
	set name = "Car wreck frequency"
	set category="Admin"
	car_wreck_frequency=input(usr,"Set the frequency of random car wrecks","Options",car_wreck_frequency) as num
	car_wreck_frequency=Clamp(car_wreck_frequency,0,100)

proc/Car_wreck_loop()
	set waitfor=0
	sleep(600)
	while(1)
		while(!car_wreck_frequency) sleep(600)
		var/list/l
		for(var/mob/m in players) if(m.z&&m.client&&m.client.inactivity<600)
			if(!l) l=new/list
			l+=m
		var/mob/m=pick(l)
		if(m) Car_wreck(m)
		sleep(6000 / car_wreck_frequency)

proc/Car_wreck(mob/m)
	set waitfor=0
	var/obj/Car/car = new(locate(m.x-15,m.y,m.z))
	car.car_target=m

mob/Admin4/verb/carTest(mob/m in world)
	set name = "car test"
	Car_wreck(m)

mob/var/tmp/obj/Drivable_Car/car

obj/Drivable_Car
	name="Drivable Car"
	desc="A car with shit handling that busts thru every fucking thing"
	Cost=100000000
	Health=1
	science = 1
	science_level = 6
	science_path = "Engineering"
	icon='Car.dmi'
	density=1
	verb/Use()
		set src in oview(1)
		if(usr.loc!=src)
			player_view(20,usr)<<"[usr] gets in the [src]!"
			usr.SafeTeleport(src)
			usr.car=src
			Car_loop()
		else
			usr.SafeTeleport(loc)
			usr.car=null
			player_view(20,usr)<<"[usr] exits the [src]!"
	verb/Change_car_icon()
		set src in oview(1)
		icon_state="[rand(1,63)]"
	verb/Upgrade()
		set src in oview(1)
		if(BP<usr.maxTurfUpgrade()*0.99)
			BP=usr.maxTurfUpgrade()*0.99
			player_view(15,usr)<<"[usr] upgrades the [src] to [Commas(BP)] battle power"
		else usr<<"This [src] is beyond your upgrade abilities already"
	var/car_new_called
	New()
		if(!car_new_called)
			icon_state="[rand(1,63)]"
			transform*=2
			car_new_called=1
		. = ..()
	Del()
		for(var/mob/m in src) m.SafeTeleport(loc)
		. = ..()
	var/tmp/car_looping
	proc/Car_loop()
		set waitfor=0
		if(car_looping) return
		car_looping=1
		spawn while(car_looping)
			if(locate(/mob) in src)
				var/list/l=player_range(30,src)
				for(var/mob/m in src) l+=m
				l<<sound('Racing.ogg',volume=30)
			sleep(114)
		while(src)
			if(locate(/mob) in src)
				step(src,dir)
			else break
			sleep(1)
		car_looping=0
	Move()
		if(prob(5)) player_range(30,src)<<sound('TireSlide.ogg',volume=30)
		. = ..()
	Bump(mob/m)
		var/s=pick('BigCrash.ogg','LongCrash.ogg','SmallCrash.ogg')
		var/list/l=player_range(30,src)
		for(var/mob/m2 in src) l+=m2
		l<<sound(s,volume=30)
		if(isturf(m)&&m.Health<BP&&m.Health!=1.#INF) for(var/turf/t in range(1,src)) if(t.density)
			Explosion_Graphics(src,rand(2,4))
			Make_Shockwave(src)
			t.destroy_turf()
		if(isobj(m)&&m.Health<BP&&m.BP<BP)
			Explosion_Graphics(src,rand(2,4))
			Make_Shockwave(src)
			del(m)
		if(ismob(m))
			Explosion_Graphics(src,rand(2,4))
			Make_Shockwave(src)
			l=player_range(30,src)
			for(var/mob/m2 in src) l+=m2
			var/dmg=100 * (Avg_BP/m.BP)**2.5
			m.TakeDamage(dmg)
			if(m.Health<=0)
				l<<sound('Squished.ogg',volume=100)
				m.KO("runaway car!",allow_anger=0)
		dir=pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,SOUTHEAST,SOUTHWEST,NORTHWEST)
