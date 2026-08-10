area/proc/Area_Nuke() if(icon!='LightningFlash.dmi')
	var/Old_State=icon_state
	icon='LightningFlash.dmi'
	icon_state=null
	spawn(600) if(src)
		icon='Weather.dmi'
		icon_state=Old_State

proc/Nuke_Icons(obj/F)
	switch(pick(1,2,3))
		if(1)
			F.icon='Explosion.dmi'
			F.icon_state=""
		if(2)
			F.icon='ExplosionLegacy2.dmi'
			F.icon_state=""
		if(3)
			F.icon='Smoke1.dmi'
			F.icon_state=""

turf/proc/Nuke(BP,Force,Range,Amount)
	set waitfor=0
	for(var/area/B in range(0,src)) if(B.type!=/area/Inside) B.Area_Nuke()
	spawn(1) while(Amount>0)
		spawn(rand(0,200)) view(10,src)<<pick('Blast.wav','Kiplosion.ogg','Wallhit.ogg','Explosion2.wav')
		var/obj/Blast/Fireball/F=new(src)
		F.BP=BP
		F.Force=Force
		F.Offense=1.#INF
		F.Nuke_Walk()
		Amount-=1
		sleep(0.2)

obj/var/Nukable=1

obj/Blast/var/tmp/blast_caches = 1 //whether this blast is allowed to be cached when it deletes

obj/Blast/Fireball
	icon='Explosion.dmi'
	density=1
	Shockwave=1
	Deflectable=0
	Explosive=0
	Piercer=1
	layer=MOB_LAYER+50
	Owner="the nuclear explosion!"
	Distance=1000000
	blast_caches = 0

	var
		tmp
			init

	proc/Nuke_Walk()
		set waitfor=0
		while(src && z)
			step_rand(src)
			sleep(1)

	New()
		icon=pick('Explosion1.dmi','Explosion2.dmi','Explosion3.dmi','Explosion4.dmi')
		Timed_Delete(src, rand(5000,7000))
		pixel_x=rand(-64,64)
		pixel_y=rand(-64,64)
		Nuke_Attack_Mobs()
		Nuke_Attack_Objs()
		Nuke_Attack_Turf()
		init = 1

	proc/Nuke_Attack_Mobs()
		set waitfor=0
		while(src && z)
			//for(var/mob/P in Get_step(src,dir))
			for(var/mob/P in view(1,src))
				Bump(P)
				sleep(rand(0,20))
				break
			sleep(rand(1,2))

	proc/Nuke_Attack_Objs()
		set waitfor=0
		while(src && z)
			for(var/obj/A in Get_step(src,dir)) if(A.type!=type&&A.Nukable)
				var/Old_Damage=Damage
				Damage*=100
				Bump(A)
				if(src) Damage=Old_Damage
				sleep(rand(1,100))
				break
			sleep(rand(0,20))

	proc/Nuke_Attack_Turf()
		set waitfor=0
		while(src && z)
			for(var/turf/A in range(1,src))
				if(A.density)
					var/Old_Damage=Damage
					Damage*=3
					Bump(A)
					if(src) Damage=Old_Damage
				else if(prob(100)&&!istype(A,/turf/GroundSandDark))
					A.Health=0
					A.Destroy()
			sleep(rand(0,40))

	Move()
		. = ..()

obj/var/makes_toxic_waste

obj/items/Nuke
	icon='Lab.dmi'
	era_reset_immune=0
	icon_state="Panel1"
	density=1
	makes_toxic_waste=1
	Stealable=1
	var/Force=1
	var/Range=20
	var/Amount=100
	var
		detonated = 0
	proc/canContinueNexusNukeInteraction(mob/user, atom/original_location)
		if(!user || loc != original_location) return FALSE
		if(original_location == user) return canUseAfterNexusTradeYield(user)
		return src in view(1,user)
	Cost=30000000
	science = 1
	science_level = 6
	science_path = "Engineering"
	takes_gradual_damage=1
	desc="This bomb can cause extreme damage over a large distance. It can be mounted to other objects \
	by having it in your items, facing the object you want to mount the bomb to, right click the bomb and \
	click Mount"
	verb/Upgrade_health()
		set name="Repair/Upgrade health"
		set src in view(1)
		if(usr in view(1,src))
			var/max_health=usr.Knowledge*usr.Intelligence()
			if(Health<max_health)
				player_view(15,usr)<<"[usr] repairs/upgrades the [src]'s health to [Commas(max_health)] BP"
				Health=max_health
			else usr<<"The [src] is beyond your upgrading abilities"
	New()
		spawn if(src) if(Bolted) Proximity_Detonation()
		. = ..()
	verb/Mount()
		if(Combat_Status(usr)) return
		if(!Bolted&&!Password)
			usr<<"You must arm the bomb or set a detonation code for the bomb first. Otherwise mounting it \
			will just be a waste of a bomb. It will never explode."
			return
		for(var/obj/o in Get_step(usr,usr.dir))
			player_view(15,usr)<<"[usr] mounts the [src] to the [o]"
			Move(o)
			return
	verb/Upgrade()
		set src in view(1)
		var/mob/user = usr
		var/atom/original_location = loc
		if(user in view(1,src))
			if(!canContinueNexusNukeInteraction(user, original_location)) return
			var/upgrade_choice = alert(user,"Upgrade power or range?","Options","Power","Range")
			if(!canContinueNexusNukeInteraction(user, original_location)) return
			switch(upgrade_choice)
				if("Range")
					var/res_cost=Item_cost(user,src)/2
					var/max_range=250
					if(Range>=max_range)
						alert(user,"The range is maxed out already at [Range]")
						return
					while(user&&src&&Range<max_range)
						var/range_choice = alert(user,"Upgrade range to [Range+initial(Range)] for [Commas(res_cost)] resources?","Options","No","Yes")
						if(!canContinueNexusNukeInteraction(user, original_location)) return
						switch(range_choice)
							if("No") return
							if("Yes")
								if(user.Res()<res_cost)
									user<<"You need [Commas(res_cost)] resources to do this"
									return
								user.Alter_Res(-res_cost)
								Range+=initial(Range)
				if("Power")
					var/Max_Upgrade=user.maxTurfUpgrade()*1
					var/Percent=(BP/Max_Upgrade)*100
					var/Res_Cost=Item_cost(user,src)/500
					if(Percent>=100)
						user<<"This is 100% upgraded at this time and cannot go any further."
						return
					var/Amount=input(user,"This is upgraded to [Commas(BP)] BP. The current maximum is \
					[Commas(Max_Upgrade)] BP. \
					It is at [Percent]% maximum power. Each 1% upgrade cost [Commas(Res_Cost)]$. The maximum is 100%. Input \
					the percentage of power you wish to bring this to. ([Percent]-100%)") as num
					if(!canContinueNexusNukeInteraction(user, original_location)) return
					if(Amount>100) Amount=100
					if(Amount<0.1)
						user<<"Amount must be higher than 0.1%"
						return
					if(Amount<=Percent)
						user<<"The weapon cannot be downgraded."
						return
					Res_Cost*=Amount-Percent
					if(user.Res()<Res_Cost)
						user<<"You do not have enough resources to do this."
						return
					user.Alter_Res(-Res_Cost)
					BP=Max_Upgrade*(Amount/100)
					Force=Avg_Force()
					player_view(15,user)<<"[user] upgraded [src] from [Percent]% to [Amount]% ([Commas(BP)] BP)"
			desc="[src]:<br>\
			Power: [Commas(BP)]<br>\
			Range: [Range]<br>"
	proc/Detonate()
		if(type==/obj/items/Nuke)
			var/turf/A=base_loc()
			spawn if(src && A)
				if(!detonated)
					detonated = 1
					Nuke_detonate(nuke_bp = BP, origin = A, range = Range, bombObj = src, requireBombObj = 1)
		else
			if(tournament_override(fighters_can=0,show_message=0))
				del(src)
				return
			var/Amount=5
			while(Amount)
				Amount-=1
				Make_Shockwave(src,7,sw_icon_size=256)
				player_view(10,src)<<sound('Wallhit.ogg',volume=25)
				for(var/mob/P in view(7,loc))
					var/Damage=(Force/P.End)*sqrt(BP/P.BP)*15
					P.TakeDamage(Damage, attack_name = "Bomb Explosion")
					if(P.KO) P.Death(src)
				sleep(5)
			del(src)
	verb/Set()
		set src in view(1)
		var/mob/user = usr
		var/atom/original_location = loc
		if(!canContinueNexusNukeInteraction(user, original_location)) return
		if(Combat_Status(user)) return
		if(Bolted)
			user<<"It is already armed, you cannot reprogram it"
			return
		player_view(15,src)<<"[user] has begun to program the bomb."
		var/new_password = input(user,"Set the access code for remote detonation.") as text
		if(!canContinueNexusNukeInteraction(user, original_location) || Bolted) return
		Password=new_password
	verb/Hotbar_use()
		set hidden=1
		Arm()
	verb/Arm()
		set src in oview(1)
		var/mob/user = usr
		var/atom/original_location = loc
		if(!canContinueNexusNukeInteraction(user, original_location)) return
		if(Combat_Status(user)) return
		if(Bolted)
			user<<"It is already armed"
			return
		var/arm_choice = input(user,"Choose method. Only choose if you do not plan on remote detonation. Once \
		activated, it cannot be deactivated.") in list("Cancel","Timer","Proximity")
		if(!canContinueNexusNukeInteraction(user, original_location) || Bolted) return
		switch(arm_choice)
			if("Timer") Timed_Detonation(user, original_location)
			if("Proximity") Proximity_Detonation()
	proc/Timed_Detonation(mob/user, atom/original_location)
		if(!canContinueNexusNukeInteraction(user, original_location) || Bolted) return
		var/Timer=input(user,"Set the timer, in seconds. (10 to 600)") as num
		if(!canContinueNexusNukeInteraction(user, original_location) || Bolted) return
		Bolted=1
		if(Timer<10) Timer=10
		if(Timer>600) Timer=600
		Timer=round(Timer)
		while(Timer)
			if(round(Timer,10)==Timer) player_view(15,src)<<"[src]: Detonation in [Timer] seconds."
			Timer-=1
			sleep(10)
		player_view(15,src)<<"[src]: GOODBYE"
		if(src) Detonate()
	proc/Proximity_Detonation()
		player_view(15,src)<<"[src]: Proximity Detonation activation in 1 minute"
		Bolted=1
		sleep(600)
		while(src)
			for(var/mob/A in player_view(7,src)) if(A.client)
				player_view(15,src)<<"[src]: Proximity Breach. Detonating..."
				spawn(10) if(src) Detonate()
				return
			sleep(rand(0,60))
	proc/Remote_Detonation()
		Bolted=1
		Detonate()
obj/items/Nuke/Sonic_Bomb
	icon='Lab.dmi'
	icon_state="Panel1"
	density=1
	desc="This bomb only harms people, not objects. It can kill. It can be mounted to any other object"
	Stealable=1
	Cost=500000
	science = 1
	science_level = 5
	science_path = "Engineering"
	New()
		spawn if(src) if(Bolted) Proximity_Detonation()
		. = ..()

proc
	Combat_Status(mob/M) // 1 = In Combat, 0 = Not in Combat
		if(M.KO || M.logout_timer || M.fearful || world.time < M.cant_logout_until_time)
			return 1
		else
			return 0
