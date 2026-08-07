obj/Attacks/Buster_Barrage
	Drain=9
	Teach_Timer=2
	student_point_cost = 20
	Cost_To_Learn=7
	Experience=1

	//icon='ShieldLegendary.dmi'
	icon = 'GreenBall2017.dmi'

	desc="An attack which shoots energy from all parts of your body in random directions."
	Explosive=1
	Shockwave=1
	var
		tmp
			Barraging
			lastBlastSfx = 0

	verb/Hotbar_use()
		set hidden=1
		Buster_Barrage()

	verb/Buster_Barrage()
		set category="Skills"
		usr.Buster_Barrage(src)

mob/proc/Buster_Barrage(obj/Attacks/Buster_Barrage/B)
	if(!B) for(var/obj/Attacks/Buster_Barrage/C in ki_attacks) B=C
	if(!B) return
	if(B.Barraging)
		B.Barraging=0
		return
	if(cant_blast()) return
	attacking=3
	var/Delay = 0.75 * Speed_delay_mult(severity=0.5) + 1.35
	if(!client) Delay=1
	B.Experience+=0.05

	//var/trans_size = 64 / GetHeight(B.icon)

	//overlays += 'ShieldLegendary.dmi'
	var/obj/o = new
	o.icon = 'GreenBall2017.dmi'
	CenterIcon(o)
	o.transform *= 0.5
	o.alpha = 200
	overlays += o
	setNexusActionGlow("#72ff8c", 2.35, 175, 'NexusLightGradient.dmi', 6, "aura")

	B.Barraging=1
	var/projectiles_fired = 0
	var/datum/CombatDamageBudget/damage_budget = new(16)

	while(B.Barraging && projectiles_fired < 20 && !cant_blast(ignore_attack_check = 1) && Ki>=GetSkillDrain(mod = B.Drain, is_energy = 1))
		if(world.time - B.lastBlastSfx > 1.5)
			player_view(10,src)<<sound('Blast.wav',volume=10)
			B.lastBlastSfx = world.time
		B.Skill_Increase(1,src)
		Ki-=GetSkillDrain(mod = B.Drain, is_energy = 1)
		var/obj/Blast/A=get_cached_blast()

		A.setStats(src, Percent = 0.4, Off_Mult = 1, Explosion = 0, explosion_percent = 0.4, shared_budget = damage_budget)
		A.weaker_obstacles_cant_destroy_blast = 1
		A.from_attack=B
		A.Distance = 250
		A.icon = B.icon

		//A.transform = matrix() * trans_size

		CenterIcon(A)
		A.pixel_x+=rand(-10,10)
		A.pixel_y+=rand(-10,10)
		A.Shockwave=3
		A.vector_speed = 32
		if(prob(10)) A.Explosive=2
		A.dir=pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)
		A.loc=loc
		A.Buster_Barrage_Move()
		projectiles_fired++
		sleep(TickMult(Delay))

	attacking=0
	B.Barraging=0

	//overlays -= 'ShieldLegendary.dmi'
	overlays -= o
	clearNexusActionGlow()

obj/proc/Buster_Barrage_Move()
	set waitfor=0
	step(src,dir)
	sleep(1)
	var/mob/m=Owner
	while(src&&z&&Owner==m)
		if(ismob(Owner) && getdist(src,Owner) <= 2) step_away(src,Owner)
		else if(Owner && get_dist(src, Owner) > 17) step_towards(src, Owner)
		else
			step(src,dir)
			if(prob(50)) dir = pick(dir, turn(dir,45), turn(dir,-45))
		sleep(TickMult(0.7))





obj/Attacks/Attack_Barrier
	Drain=6
	Teach_Timer=2
	student_point_cost = 30
	Cost_To_Learn=5
	verb/Hotbar_use()
		set hidden=1
		Attack_Barrier()
	icon='Asset1.dmi'
	desc="An offensive and defensive move that makes many balls of ki swarm around you and whatever enters the \
	barrier will be attacked by them. Press the command once to begin firing the balls, press it again when you \
	feel you have fired enough. The more you fire the more it will drain your energy. This ability protects the \
	user from all explosion damage."
	var/tmp/Firing_Attack_Barrier
	verb/Attack_Barrier()
		set category="Skills"
		if(skill_engine) skill_engine.castSkill(usr, src)

obj/Blast/proc/attack_barrier_loop()
	set waitfor=0
	sleep(1)
	while(src&&z&&!deflected)
		if(!Owner) return
		var/mob/target = Owner.getSelectedTarget(max_dist = 3)
		if(target)
			step_towards(src,target)
			if(target in loc) Bump(target)
		else if(getdist(src,Owner) > 1) step_towards(src,Owner)
		else step_rand(src)

		if(ismob(Owner) && Owner.tournament_override(fighters_can=1,show_message=0)) break
		else if(ismob(Owner) && (!Owner.attack_barrier_obj || !Owner.attack_barrier_obj.Firing_Attack_Barrier)) break
		else sleep(TickMult(1))
	if(Owner&&ismob(Owner)) Owner.attack_barrier_blasts--
	if(z) del(src)

mob/var/tmp/attack_barrier_blasts=0
mob/var/tmp/obj/Attacks/Attack_Barrier/attack_barrier_obj

mob/proc/MaxAttackBarrierBlasts()
	var/n = 13 * Eff ** 0.3
	n = Clamp(n, 9, 20)
	n = ToOne(n)
	return n

mob/proc/UsingAttackBarrier()
	if(!attack_barrier_obj) return 0
	if(attack_barrier_obj.Firing_Attack_Barrier) return 1

mob/proc/Attack_Barrier(obj/Attacks/Attack_Barrier/B)
	if(skill_engine) return skill_engine.castAttackBarrier(src, B)
	return 0

atom/var/Fatal=0

mob/verb/Ki_Toggle()
	set category	="Other"
	set name		="Toggle Lethal Intent"
	toggleLethalIntent()

obj/var/Mastery=1

var/list/Blasts=new

proc/AddBlasts() for(var/A in typesof(/obj/Blasts)) if(A!=/obj/Blasts) Blasts+=new A

obj/var/tmp/iconSize = 32

obj/proc/AssignIconSize()
	iconSize = GetHeight(icon)

obj/Blasts
	icon_state="head"
	Givable=0
	Makeable=0

	Click()
		icon = initial(icon)
		var/Color=input("Choose a color. Hit Cancel to have default color.") as color|null
		if(!usr) return
		if(Color) icon += Color
		var/list/C=new
		for(var/obj/Attacks/D in usr.ki_attacks) if(D.type!=/obj/Attacks/Time_Freeze) C+=D
		var/obj/Attacks/A=input("Give this icon to which attack?") in C
		if(usr && A)
			A.icon=image(icon=icon,icon_state=icon_state)

			A.AssignIconSize()

		icon = initial(icon)

	Blast1 icon='Asset1.dmi'
	Blast2 icon='Asset2.dmi'
	Blast3 icon='Asset3.dmi'
	Blast4 icon='Asset4.dmi'
	Blast5 icon='Asset5.dmi'
	Blast6 icon='Asset6.dmi'
	Blast7 icon='Asset7.dmi'
	Blast8 icon='Asset8.dmi'
	Blast9 icon='Asset9.dmi'
	Blast10 icon='Asset10.dmi'
	Blast11 icon='Asset11.dmi'
	Blast12 icon='Asset12.dmi'
	Blast13 icon='Asset13.dmi'
	Blast14 icon='Asset14.dmi'
	Blast15 icon='Asset15.dmi'
	Blast16 icon='Asset16.dmi'
	Blast17 icon='Asset17.dmi'
	Blast18 icon='Asset18.dmi'
	Blast19 icon='Asset19.dmi'
	Blast20 icon='Asset20.dmi'
	Blast21 icon='Asset21.dmi'
	Blast22 icon='Asset22.dmi'
	Blast23 icon='Asset23.dmi'
	Blast24 icon='Asset24.dmi'
	Blast25 icon='Asset25.dmi'
	Blast26 icon='Asset26.dmi'
	Blast27 icon='Asset27.dmi'
	Blast28 icon='Asset28.dmi'
	Blast29 icon='Asset29.dmi'
	Blast30 icon='Asset30.dmi'
	Blast31 icon='Asset31.dmi'
	Blast32 icon='Asset32.dmi'
	Blast33 icon='Asset33.dmi'
	Blast34 icon='Asset34.dmi'
	Blast35 icon='Asset35.dmi'
	Blast36 icon='Asset36.dmi'
	Blast37 icon='Asset37.dmi'
	Blast38 icon='BlastDestructoDisk.dmi'
	Blast39 icon='BlastDualFireBlast.dmi'
	Blast40 icon='BlastKiShuriken.dmi'
	Blast41 icon='Holybolt.dmi'
	Blast42 icon='Blast0.dmi'
	Blast43 icon='Blast1.dmi'
	Blast44 icon='Blast2.dmi'
	Blast45 icon='Blast3.dmi'
	Blast46 icon='Blast4.dmi'
	Blast47 icon='Blast5.dmi'
	Blast48 icon='Blast6.dmi'
	Blast49 icon='Blast7.dmi'
	Blast50 icon='Blast8.dmi'
	Blast51 icon='Blast9.dmi'
	Blast52 icon='Blast10.dmi'
	Blast53 icon='Blast11.dmi'
	Blast54 icon='Blast12.dmi'
	Blast55 icon='Blast13.dmi'
	Blast56 icon='Blast14.dmi'
	Blast57 icon='Blast15.dmi'
	Blast58 icon='Blast16.dmi'
	Blast59 icon='Blast17.dmi'
	Blast60 icon='Blast18.dmi'
	Blast61 icon='Blast19.dmi'
	Blast62 icon='Blast20.dmi'
	Blast63 icon='Blast21.dmi'
	Blast64 icon='Blast22.dmi'
	Blast65 icon='Blast23.dmi'
	Blast66 icon='Blast24.dmi'
	Blast67 icon='Blast25.dmi'
	Blast68 icon='Blast26.dmi'
	Blast69 icon='Blast27.dmi'
	Blast70 icon='Blast28.dmi'
	Blast71 icon='Blast29.dmi'
	Blast72 icon='Blast30.dmi'
	Blast73 icon='BallSpiritBomb.dmi'
	Blast74 icon='BallSupernova.dmi'
	Blast75 icon='BlastFire.dmi'
	Blast76 icon='BlastSpiralingKi.dmi'
	Blast77 icon='BlastSuperDd.dmi'
	Blast78 icon='AuraBlastSize1.dmi'
	Blast79 icon='ElectroShield.dmi'
	Blast80 icon='Hadoken.dmi'
	Blast81 icon='Asset38.dmi'
	Blast82 icon='RoyalDeathCrusher.dmi'
	Blast83 icon='Asset39.dmi'
	Blast84 icon='BlastAqua.dmi'
	Blast85 icon='BlastFlame.dmi'
	Blast86 icon='BlastStar.dmi'
	Blast87 icon='Daitoppa.dmi'
	Blast88 icon='Asset40.dmi'
	Blast89 icon='Trishot.dmi'
	Blast90 icon='Zankoukyokuha.dmi'
	Blast91 icon='BasenioBlast.dmi'
	Blast92 icon='HeartBlast.dmi'
	Blast93 icon='DarkLance.dmi'
	Blast94 icon='OmegaBlasterZee.dmi'
	Blast95 icon='DarkBlast.dmi'
	Blast96 icon='Flareblast.dmi'
	Blast97 icon='FireBlastBig.dmi'
	Blast98 icon='BigBangAttack.dmi'
	Blast99 icon = 'GreenBall2017.dmi'
	Beam1 icon='Beam1.dmi'
	Beam2 icon='LightningBeam2014.dmi'
	Beam3 icon='Beam3.dmi'
	Beam4 icon='Beam4.dmi'
	Beam5 icon='Beam5.dmi'
	Beam6 icon='Beam6.dmi'
	Beam8 icon='Beam8.dmi'
	Beam9 icon='Beam9.dmi'
	Beam10 icon='Beam10.dmi'
	Beam11 icon='Beam11.dmi'
	Piercer_Icon icon='Makkankosappo.dmi'
	Beam12 icon='PoisonBeam2014.dmi'
	Beam13 icon='BeamKamehameha.dmi'
	Beam14 icon='BeamStaticBeam.dmi'
	Beam15 icon='BeamMultiBeam.dmi'
	Beam16 icon='BeamMasenko.dmi'
	Beam17 icon='BeamBlastDragon.dmi'
	Beam18 icon='BeamBeam1.dmi'
	Beam19 icon='BeamBigFire.dmi'
	Beam20 icon='Beam13.dmi'
	Beam21 icon='Beam14.dmi'
	Beam22 icon='BlackDragonBeam.dmi'
	Beam23 icon='Dragonbeam.dmi'
	Beam24 icon='ZentoBbkhh1.dmi'
	Beam25 icon='ZentoBbkhh2.dmi'
	Beam26 icon='SnakeBeam2014.dmi'
	Beam27 icon='EraserCannon.dmi'
	Beam28 icon='FreezaDeathRay.dmi'
	Beam29 icon='KingKoldDeathRay.dmi'

obj/Aura_Choices
	Savable=0
	Givable=0
	Makeable=0
	var
		Scale
		auraYoffset = 0
	Click()
		icon=initial(icon)
		if(Scale) icon=Scaled_Icon(icon,Scale,Scale)
		var/C=input("Choose a color. Hit cancel to have default color.") as color|null
		if(!usr||!usr.Auras) return
		if(C) icon+=C
		usr.Auras.SSj4=initial(usr.Auras.SSj4)
		if(C) usr.Auras.SSj4+=C
		usr.FlightAura='src/Icons/Ki/Auras/AuraFly.dmi'
		if(C) usr.FlightAura+=C
		usr.Auras.icon=image(icon=icon,icon_state=icon_state)
		usr.Auras.auraYoffset = auraYoffset
	None
	BlueFlameAura
		icon = 'BlueFlameAura.dmi'
	SuperBuu
		icon = 'Blurredsuperbuuaura.dmi'
	Large
		icon='AuraBig.dmi'
		Scale=74
		New() icon=Scaled_Icon(icon,Scale,Scale)
	Zen_Aura
		icon='ZenAura.dmi'
		New() icon=Scaled_Icon(icon,83,121) //half size
	Sparks icon='AbsorbSparks.dmi'
	Electric icon='AuraBloo.dmi'
	Electric_2 icon='AuraElectric.dmi'
	Default icon='src/Icons/Ki/Auras/Aura.dmi'
	Flowing icon='AuraNormal.dmi'
	Demon_Flame icon='BlackDemonflame.dmi'
	Vampire_Aura icon='Aura2.dmi'
	Electric_3 icon='ElecAura3.dmi'
	Electric_4 icon='ElecAura1.dmi'
	Aura1 icon='NormalTallAura.dmi'
	Aura2 icon='AuraJanuary27th2014.dmi'
	Buu_Aura icon='BuuAura.dmi'
	Fire_Aura
		icon = 'FireAura.dmi'
		auraYoffset = -19

obj/Charges
	Givable=0
	Makeable=0
	icon='BlastCharges.dmi'
	Click()
		icon=initial(icon)
		var/A=input("Choose a color. Hit cancel to have default color.") as color|null
		if(A) icon+=A
		usr.BlastCharge=image(icon=icon,icon_state=icon_state)
	Charge1 icon_state="1"
	Charge2 icon_state="2"
	Charge3 icon_state="3"
	Charge4 icon_state="4"
	Charge5 icon_state="5"
	Charge6 icon_state="6"
	Charge7 icon_state="7"
	Charge8 icon_state="8"
	Charge9 icon_state="9"
obj/Attacks/var
	Power=1 //Damage multiplier
	Explosive=0
	Shockwave=0
	Paralysis=0
	Scatter=0 //A barrage effect
atom/var
	Experience=0
	Add=1
	Level=1
	tmp/mob/Owner
	Password
	tmp/mob/Target
	Weight=1
	Health=1000
	Savable=1
	Builder
obj/Health=5000
mob/var/tmp/obj/Attacks/Blast/blast_obj

obj/Attacks/Blast
	Drain = 1
	Teach_Timer=0.5
	student_point_cost = 10
	Cost_To_Learn=2
	Experience=1
	var/Spread=1
	var/Blast_Count=1
	var/blast_refire=1
	var/blast_velocity=1
	icon='Asset1.dmi'
	desc="Fire blasts rapidly"
	repeat_macro=1

	var
		tmp
			last_retarget = 0
			mob/last_blast_targ
			lastBlastSfx = 0

	New()
		spawn if(ismob(loc))
			var/mob/m=loc
			m.blast_obj=src
		Recalculate_blast_drain()
		. = ..()

	verb/Blast_Options()
		set category="Other"
		while(usr)
			switch(input("These settings are for the 'Blast' ability") in list("Cancel","Firing Mode","Knockback","Explosiveness","Amount of blasts",\
			"Refire","Stun"))
				if("Cancel") return
				if("Stun")
					switch(alert("Stun? (Lowers damage)","Options","Yes","No"))
						if("No") Stun=0
						if("Yes") Stun=1
				if("Firing Mode")
					switch(alert("Firing Mode","Options","Normal","Spread","Barrage"))
						if("Normal") Spread=1
						if("Spread") Spread=2
						if("Barrage") Spread=3
				if("Knockback")
					switch(alert("Knockback?","Options","Yes","No"))
						if("Yes") Shockwave=1
						if("No") Shockwave=0
				if("Explosiveness")
					switch(alert("Explosive? Increases damage, damage range, and drain","Options","No","Yes"))
						if("No") Explosive=0
						if("Yes")
							//if(blast_refire>0.65)
							//	alert("Blast refire must not be higher than 0.65x to have explosions enabled. It has been \
							//	set to 0.65x automaticly")
							//	blast_refire=0.65
							Explosive=1
				if("Amount of blasts")
					Blast_Count=input("Amount of blasts? 1 to 4. More blasts increases drain heavily") as num
					if(Blast_Count<1) Blast_Count=1
					if(Blast_Count>4) Blast_Count=4
					Blast_Count=round(Blast_Count)
				if("Refire")
					var/max=1
					//if(Explosive) max=0.65
					blast_refire=input("Blast refire: 0.2 to [max]. The slower the more powerful. If you disable \
					exploding blasts you can set the refire higher") as num
					if(blast_refire>max) blast_refire=max
					if(blast_refire<0.2) blast_refire=0.2
			Recalculate_blast_drain()

	proc/Recalculate_blast_drain()
		Drain=initial(Drain)
		if(Spread>1) Drain += initial(Drain) * 1
		if(Explosive) Drain += initial(Drain) * 1
		if(Stun) Drain += initial(Drain) * 1.5
		Drain *= 1 / blast_refire

	verb/Hotbar_use()
		set hidden=1
		usr.Blast_macro()

	verb/Blast()
		set category="Skills"
		if(skill_engine) skill_engine.castSkill(usr, src)

mob/var/tmp
	blast_fire_loop

mob/verb/Blast_macro()
	set instant=1
	set hidden=1
	blast_fire_loop()

mob/proc/blast_fire_loop()
	if(blast_fire_loop) return
	blast_fire_loop=1
	if(blast_obj)
		var/k=Get_hotbar_ability_key(blast_obj)
		while(blast_obj && (k in keys_down))
			Blast_Fire(blast_obj)
			sleep(get_blast_refire())
	blast_fire_loop=0

mob/proc/get_blast_refire()
	if(!blast_obj) return 1
	return TickMult(1 / blast_obj.blast_refire * Speed_delay_mult(severity=0.5))

mob/proc/get_shuriken_refire()
	return TickMult(2.4 * Speed_delay_mult(severity=0.3))

mob/proc/Blast_Fire(obj/Attacks/Blast/B)
	if(skill_engine) return skill_engine.castBlast(src, B)
	return 0

//this just gives the blast a target when it is first spawned and makes it take a pixel vector directly to that target
var/ki_projectile_step_delay = 0.5

obj/Blast/var/tmp/projectile_flight_id = 0

obj/Blast/proc/stopProjectileFlight()
	projectile_flight_id++
	walk(src, 0)

obj/Blast/proc/startKiProjectileWalk(move_dir, delay_override = 0)
	set waitfor = 0
	stopProjectileFlight()
	if(!move_dir) return
	dir = move_dir
	if(Beam || !Is_Ki || Bullet)
		walk(src, dir, delay_override)
		return
	var/flight_id = projectile_flight_id
	var/move_delay = delay_override
	if(!move_delay) move_delay = ki_projectile_step_delay
	while(src && z && in_use && flight_id == projectile_flight_id)
		var/move_speed = vector_speed
		if(!move_speed) move_speed = 32
		vector_step_dir(src, dir, move_speed)
		sleep(TickMult(move_delay))

obj/Blast/proc/BlastAutoTargetGo(boundWidth = 32, boundHeight = 32, vectorSpeed = 44, angleLimit = 18, dist = 47, randomAngle = 0)
	set waitfor=0
	Can_Home = 0 //old system interferes with this new system and makes it look bad too
	bound_height = boundHeight
	bound_width = boundWidth
	bound_y = (32 - bound_height) * 0.5
	bound_x = (32 - bound_width) * 0.5
	vector_speed = vectorSpeed
	Distance = dist
	var/angle = dir_to_angle_0_360(dir)
	var/mob/targ = blast_homing_target
	if(!targ && Owner) targ = Owner.getSelectedTarget(max_dist = 100, dir_angle = dir, angle_limit = angleLimit)
	if(targ && !Is_viable_homing_target(targ)) targ = null
	blast_homing_target = targ
	if(targ) angle = get_global_angle(src, targ)
	angle += rand(-randomAngle, randomAngle)
	BlastVectorWalk(angle)

obj/Blast/proc/BlastVectorWalk(angle = 0)
	set waitfor=0
	stopProjectileFlight()
	var/flight_id = projectile_flight_id
	sleep(TickMult(ki_projectile_step_delay))
	while(z && !deflected && in_use && flight_id == projectile_flight_id)
		vector_step(src, angle, vector_speed)
		sleep(TickMult(ki_projectile_step_delay))

obj/Blast/proc/followSelectedTarget(mob/target)
	set waitfor = 0
	stopProjectileFlight()
	var/flight_id = projectile_flight_id
	while(src && z && !deflected && Owner && target && flight_id == projectile_flight_id && Owner.getSelectedTarget(target, require_view = FALSE) == target)
		var/move_speed = vector_speed
		if(!move_speed) move_speed = 32
		vector_step_toward(src, target, move_speed)
		if(target in loc)
			Bump(target)
			return
		sleep(TickMult(ki_projectile_step_delay))
	if(src && z && !deflected && flight_id == projectile_flight_id) del(src)

obj/Blast/proc/Blast_Move(obj/Attacks/Blast/b,mob/m, skip_first_delay)
	set waitfor=0
	var
		steps = 0
		spread_step = rand(1,4)
		move_speed = vector_speed
	if(!move_speed) move_speed = 32

	if(b.Spread == 3) spread_step = rand(0,8)

	if(!skip_first_delay) sleep(TickMult(ki_projectile_step_delay))

	while(src && z && !deflected)
		var/old_dir = dir
		if(b && b.Spread == 2 && steps == spread_step && prob(67))
			vector_step_dir(src, turn(dir, pick(-45,45)), move_speed)
			dir = old_dir
		else if(b && b.Spread == 3 && steps == spread_step && prob(90))
			dir = pick(turn(dir,45),turn(dir,-45))
			vector_step_dir(src, dir, move_speed)
		else vector_step_dir(src, dir, move_speed)
		steps++
		sleep(TickMult(ki_projectile_step_delay))

//avoid using this old ass proc whenever possible, it makes no sense
mob/proc/Disabled()
	if(rp_mode || KO || KB || (Frozen && !paralysis_immune) || (Action in list("Meditating","Training"))) return 1

obj/Attacks/Big_Bang_Attack
	Drain=80
	Teach_Timer=1
	student_point_cost = 20
	Cost_To_Learn=10
	Experience=1
	icon='BigBangAttack.dmi'
	desc="Basicly a more powerful version of the 'charge' ki attack"
	repeat_macro=1
	verb/Hotbar_use()
		set hidden=1
		Big_Bang()

	verb/Big_Bang()
		set category="Skills"
		if(skill_engine) skill_engine.castSkill(usr, src)

	/*verb/Big_Bang()
		set category="Skills"
		if(usr.cant_blast()) return
		if(usr.Ki<usr.GetSkillDrain(mod = Drain, is_energy = 1)) return
		if(prob(10)&&Experience<1) Experience+=0.1
		usr.Ki-=usr.GetSkillDrain(mod = Drain, is_energy = 1)
		Skill_Increase(2,usr)
		usr.attacking=3
		charging=1
		//usr.moving_charge=1
		usr.overlays+=usr.BlastCharge
		player_view(10,usr)<<sound('BasicbeamCharge.ogg',volume=30)
		var/turf/fire_location=usr.loc
		sleep(TickMult(23 * usr.Speed_delay_mult(severity=0.3)))
		usr.overlays-=usr.BlastCharge
		if(!usr.cant_blast(ignore_attack_check = 1))
			player_view(10,usr)<<sound('Blast.wav',volume=70)
			usr.Say("BIG BANG ATTACK!!")
			var/obj/Blast/A=get_cached_blast()
			var/dmg=54
			if(usr.loc==fire_location) dmg*=1.5
			A.setStats(usr,Percent=dmg,Off_Mult=1,Explosion=4)
			A.from_attack=src
			A.Shockwave=1
			//A.Distance=50
			A.vector_speed = 32 * 1
			A.icon=icon
			A.dir=usr.dir
			A.loc=usr.loc
			//step(A,A.dir)
			if(A&&A.z) A.blast_walk(world.tick_lag)
		usr.attacking=0
		//usr.moving_charge=0
		charging=0*/








obj/Attacks/Charge
	Drain=20
	Teach_Timer=0.1
	student_point_cost = 10
	Cost_To_Learn=1
	Experience=1
	icon='Asset20.dmi'
	desc="An explosive one-shot energy attack that takes a few seconds to charge."
	repeat_macro=1

	verb/Hotbar_use()
		set hidden=1
		Charge()

	verb/Charge()
		set category="Skills"
		if(skill_engine) skill_engine.castSkill(usr, src)

	/*verb/Charge()
		set category="Skills"
		if(usr.cant_blast()) return
		if(usr.Ki<usr.GetSkillDrain(mod = Drain, is_energy = 1)) return
		if(prob(10)&&Experience<1) Experience+=0.1
		usr.Ki-=usr.GetSkillDrain(mod = Drain, is_energy = 1)
		Skill_Increase(2,usr)
		usr.attacking=3
		//charging=1
		usr.moving_charge=1
		usr.overlays+=usr.BlastCharge
		player_view(10,usr)<<sound('BasicbeamCharge.ogg',volume=20)
		var/turf/fire_location=usr.loc
		sleep(TickMult(10*usr.Speed_delay_mult(severity=0.5)))
		usr.overlays-=usr.BlastCharge
		if(!usr.cant_blast(ignore_attack_check = 1))
			player_view(10,usr)<<sound('Blast.wav',volume=40)
			var/obj/Blast/A=get_cached_blast()
			var/dmg=20
			if(usr.loc==fire_location) dmg*=1.5
			A.setStats(usr,Percent=dmg,Off_Mult=2,Explosion=2)
			A.from_attack=src
			A.Shockwave=1
			//A.Distance=50
			A.icon=icon
			A.dir=usr.dir
			A.loc=usr.loc
			A.vector_speed = 32 * 1
			//step(A,A.dir)
			if(A&&A.z)
				A.blast_walk(world.tick_lag)
		usr.attacking=0
		usr.moving_charge=0
		*/

obj/Blast/proc/blast_walk(delay=ki_projectile_step_delay,start_dir)
	set waitfor=0
	if(start_dir) dir=start_dir
	startKiProjectileWalk(dir, delay)

mob/var/tmp/moving_charge
obj/Attacks/New()
	spawn(5) if(src&&ismob(loc))
		var/mob/m=loc
		m.ki_attacks+=src
	spawn(10) if(src&&Wave)
		calculate_beam_drain()
		BeamDescription()
	spawn(50) if(src && icon && icon == initial(icon))
		icon += rgb(rand(0,255),rand(0,255),rand(0,255))
	. = ..()
obj/Attacks/Cyber_Charge
	teachable=0
	Drain=10
	Teach_Timer=0.1
	student_point_cost = 15
	Cost_To_Learn=0
	Experience=1
	Mastery=100
	icon='Asset11.dmi'
	desc="This artificial attack is designed to mimic charge. It is a bit weaker but can be fired \
	twice as fast."
	repeat_macro=1
	verb/Hotbar_use()
		set hidden=1
		CyberCharge()
	verb/CyberCharge()
		set category="Skills"
		if(skill_engine) skill_engine.castSkill(usr, src)

obj/Attacks/Kienzan
	icon='BlastDestructoDisk.dmi'
	Cost_To_Learn=3
	Teach_Timer=1
	student_point_cost = 20
	desc="A guidable, piercing energy disk that cannot damage its owner."
	var/tmp/Kienzan_Delay=0.85
	Drain=100
	repeat_macro=1

	verb/Hotbar_use()
		set hidden=1
		Kienzan()

	verb/Kienzan()
		set category="Skills"
		usr.StopMovement()
		if(skill_engine) skill_engine.castSkill(usr, src)

obj/Attacks/Spin_Blast
	Experience=1
	Teach_Timer=0.4
	student_point_cost = 15
	Cost_To_Learn=2
	Drain = 10
	icon='Asset1.dmi'
	desc="Shoot many small blasts in every direction continuously"
	repeat_macro=1

	verb/Hotbar_use()
		set hidden=1
		SpinBlast()

	verb/SpinBlast()
		set category="Skills"
		Experience=1000
		if(usr.cant_blast()) return
		if(usr.Ki<usr.GetSkillDrain(mod = Drain, is_energy = 1)) return
		usr.Ki-=usr.GetSkillDrain(mod = Drain, is_energy = 1)
		Skill_Increase(2,usr)
		if(prob(50))
			usr.attacking=3
			var/Delay=25/Experience
			if(Delay<1*usr.Speed_delay_mult(severity=0.5)) Delay=1*usr.Speed_delay_mult(severity=0.5)
			Delay=TickMult(Delay)
			spawn(Delay) usr.attacking=0
		Experience+=0.01
		player_view(10,usr)<<sound('Blast.wav',volume=30)
		for(var/v in 1 to 4)
			var/obj/Blast/A=get_cached_blast()
			A.pixel_x+=rand(-12,12)
			A.pixel_y+=rand(-12,12)
			A.icon=icon
			A.setStats(usr, Percent = 0.5, Off_Mult = 1, Explosion = rand(2,3))
			A.from_attack=src
			A.vector_speed = ToOne(32 * 0.67)
			A.Shockwave=Shockwave
			A.dir=pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHEAST,SOUTHWEST)
			A.loc=usr.loc
			A.startKiProjectileWalk(A.dir)
			if(prob(67))
				spawn(3) if(A&&A.z && !A.deflected) A.dir=turn(A.dir,pick(-45,0,45))
				spawn(5) if(A&&A.z && !A.deflected) A.dir=pick(A.dir,turn(A.dir,45),turn(A.dir,-45))

obj/Attacks/Makosen
	Cost_To_Learn=6
	Teach_Timer=2
	student_point_cost = 30
	var/Spread=50
	var/ChargeTime = 140
	var/Shots=25
	var/ShotSpeed=2
	var/SleepProb=30
	var/Deletion=20
	var/ExplosiveChance=0
	var/Explosiveness=1
	Drain=150
	icon='AuraBlastSize1.dmi'
	desc="A very, very powerful attack, widespread and very destructive. Made up of many smaller shots \
	that inflict a lot of damage all together. It is very draining, not very long range, and has a \
	long charge time."
	repeat_macro=1

	verb/Hotbar_use()
		set hidden=1
		Makosen()

	verb/Makosen()
		set category="Skills"
		usr.StopMovement()
		if(skill_engine) skill_engine.castSkill(usr, src)

#define ALIEN_INFINITE_VOID_RADIUS 8
#define ALIEN_INFINITE_VOID_DURATION 70
#define ALIEN_INFINITE_VOID_WINDUP 8

obj/AlienInfiniteVoidVisual
	name = "time stop domain"
	icon = 'src/Icons/Effects/AlienInfiniteVoid.dmi'
	icon_state = "void"
	appearance_flags = PIXEL_SCALE
	plane = 20
	layer = 98
	invisibility = 0
	luminosity = 2
	alpha = 0
	density = 0
	mouse_opacity = 0
	attackable = 0
	Savable = 0
	Grabbable = 0
	Nukable = 0
	Makeable = 0
	Givable = 0

	Glow
		name = "time stop domain glow"
		layer = 99
		blend_mode = BLEND_ADD

proc/showAlienInfiniteVoidDomain(atom/center, duration = ALIEN_INFINITE_VOID_DURATION)
	set waitfor = 0
	var/turf/domain_turf = center ? center.base_loc() : null
	if(!domain_turf) return
	duration = max(14, round(duration))
	var/expand_ticks = ALIEN_INFINITE_VOID_WINDUP
	var/collapse_ticks = 10
	var/hold_ticks = max(3, duration - expand_ticks - collapse_ticks)

	var/obj/AlienInfiniteVoidVisual/domain = new(domain_turf)
	domain.blend_mode = BLEND_DEFAULT
	CenterIcon(domain)
	domain.transform = matrix() * 0.05
	domain.setNexusGlow("#5540ff", 8, 245, 'NexusLightGradient.dmi', 10, "blast")
	animate(domain, alpha = 235, transform = matrix(), time = expand_ticks, easing = CUBIC_EASING)
	animate(domain, alpha = 245, transform = turn(matrix() * 1.04, 8), time = hold_ticks, easing = SINE_EASING)
	animate(domain, alpha = 0, transform = turn(matrix() * 1.18, 16), time = collapse_ticks, easing = CUBIC_EASING)

	var/obj/AlienInfiniteVoidVisual/Glow/domain_glow = new(domain_turf)
	CenterIcon(domain_glow)
	domain_glow.transform = matrix() * 0.03
	animate(domain_glow, alpha = 180, transform = turn(matrix(), -5), time = expand_ticks, easing = CUBIC_EASING)
	animate(domain_glow, alpha = 115, transform = turn(matrix() * 1.1, -18), time = hold_ticks, easing = SINE_EASING)
	animate(domain_glow, alpha = 0, transform = turn(matrix() * 1.24, -28), time = collapse_ticks, easing = CUBIC_EASING)

	spawn(duration + 1)
		if(domain)
			domain.reallyDelete = TRUE
			del(domain)
		if(domain_glow)
			domain_glow.reallyDelete = TRUE
			del(domain_glow)

mob/proc/canHitAlienInfiniteVoidTarget(mob/target)
	if(!target || !canHitTenkaichiTechniqueTarget(target) || target.KO || !target.attackable) return FALSE
	var/turf/user_turf = base_loc()
	var/turf/target_turf = target.base_loc()
	if(!user_turf || !target_turf || user_turf.z != target_turf.z) return FALSE
	return TRUE

mob/proc/getAlienInfiniteVoidStunTicks(mob/target)
	if(!target) return 0
	var/bp_ratio = sqrt(max(0.05, max(1, BP) / max(1, target.BP)))
	var/control_ratio = Clamp((max(1, Pow) / max(1, target.Res)) ** 0.35, 0.5, 2)
	var/stun_ticks = Clamp(round(60 * bp_ratio * control_ratio), 30, 120)
	if(target.paralysis_immune) stun_ticks = max(6, round(stun_ticks * 0.25))
	return stun_ticks

mob/proc/showAlienInfiniteVoidHit()
	overlays -= 'TimeFreeze.dmi'
	overlays += 'TimeFreeze.dmi'
	pulseNexusGlow("#8d7dff", 3.2, 220, 12)
	spawn(10)
		if(src) overlays -= 'TimeFreeze.dmi'

mob/proc/applyAlienInfiniteVoidStun(turf/origin, radius = ALIEN_INFINITE_VOID_RADIUS)
	if(!origin) return 0
	var/targets_hit = 0
	for(var/mob/target in mob_view(max(1, radius), origin, FALSE))
		if(!canHitAlienInfiniteVoidTarget(target)) continue
		var/stun_ticks = getAlienInfiniteVoidStunTicks(target)
		if(stun_ticks <= 0) continue
		target.ApplyStun(time = stun_ticks, no_immunity = TRUE, stun_power = 4)
		target.showAlienInfiniteVoidHit()
		targets_hit++
	return targets_hit

obj/Time_Freeze_Energy
	var/TF_Timer=600
	var/ID
	New() TF_Delete()
	Del()
		var/mob/M=loc
		if(ismob(M))
			M.Frozen=0
			M.overlays-='TimeFreeze.dmi'
		. = ..()
	proc/TF_Delete()
		set waitfor=0
		sleep(1) //sleep long enough to let TF_Timer actually be set to something
		sleep(TF_Timer)
		if(src) del(src)

mob/var/tmp/list/Active_Freezes=new

mob/proc/Fill_Active_Freezes_List()
	for(var/mob/P in players) for(var/obj/Time_Freeze_Energy/T in P) if(T.ID==key) Active_Freezes+=T

obj/Attacks/Time_Freeze
	name = "Time Stop"
	icon = 'src/Icons/Effects/AlienInfiniteVoid.dmi'
	icon_state = "void"
	desc = "Expand an eight-tile cosmic domain that overwhelms every valid target inside it. Targets are stunned longer when your BP and Force overcome their BP and Resistance. Time Normalizers greatly reduce the stun."
	teachable=0
	hotbar_type="Ability"
	can_hotbar=1
	Cost_To_Learn=0
	Teach_Timer=9
	student_point_cost = 60
	var/tmp/time_freeze_timer=0
	var/domain_radius = ALIEN_INFINITE_VOID_RADIUS
	var/domain_windup = ALIEN_INFINITE_VOID_WINDUP
	repeat_macro=1

	verb/Hotbar_use()
		set hidden=1
		Time_Freeze()

	verb/Time_Freeze()
		set name = "Time Stop"
		set category="Skills"
		if(usr.attacking||usr.tournament_override(fighters_can=1)) return
		if(usr.Frozen) return
		if(usr.KO) return
		if(usr.rp_mode)
			usr << "Time Stop cannot be used while RP Mode is active."
			return
		if(usr.Safezone)
			usr << "Time Stop cannot be used inside a Safezone."
			return
		if(time_freeze_timer>0)
			usr<<"You can not use this for another [time_freeze_timer] seconds."
			return
		var/mob/user = usr
		var/turf/domain_origin = user.base_loc()
		if(!domain_origin) return
		user.attacking = 3
		user.StopMovement()
		time_freeze_timer=ToOne(60*usr.Speed_delay_mult(severity=0.5))

		spawn while(src&&time_freeze_timer>0)
			time_freeze_timer--
			sleep(10)

		showAlienInfiniteVoidDomain(domain_origin)
		user.showTenkaichiTechniqueAnnouncement("TIME STOP", "#9fdcff", 'src/Sound/SoundEffects/Combat/Shonen/AbilityCharge/AbilityCharge19V6.ogg', 50)
		user.pulseNexusGlow("#6d50ff", 5, 235, 18)
		flick("Blast", user)
		sleep(domain_windup)
		if(!user || loc != user || user.KO || user.rp_mode || user.Safezone)
			if(user) user.attacking = 0
			return
		player_view(15, domain_origin) << sound('src/Sound/SoundEffects/Combat/Shonen/AbilityRelease/AbilityRelease15V2.ogg', volume = 60)
		var/targets_hit = user.applyAlienInfiniteVoidStun(domain_origin, domain_radius)
		if(!targets_hit) user << "The domain expands, but catches no valid targets."
		user.attacking = 0

obj/Attacks/Explosion
	var/On
	hotbar_type="Ability"
	can_hotbar=1
	desc="This attack causes an explosion on the ground, the more you use it the bigger the explosion"
	Cost_To_Learn=2
	Teach_Timer=0.5
	student_point_cost = 20
	Experience=0
	Level=5

	New()
		if(Level>5) Level=5
		. = ..()

	verb/Hotbar_use()
		set hidden=1
		Explosion_Toggle()

	verb/Explosion_Toggle()
		set category="Skills"
		if(skill_engine) skill_engine.castSkill(usr, src)

mob/var/tmp/last_scattershot=0 //world.time

mob
	var
		tmp
			using_scattershot
			lastStopScattershot = -9999

/*mob/proc
	TryScatterShot(obj/Attacks/Scatter_Shot/s)
		if(using_scattershot)
			StopScatterShotting(s)
		else
			if(!CanScatterShot(s))
				return
			src << "<font color=cyan>Click again to stop"
			ScatterShot(s)

	CanScatterShot(obj/Attacks/Scatter_Shot/s)
		if(world.time - lastStopScattershot < 25) return //because theres a bug where if you just spam the scattershot verb you do this sure rapid fire homing blast thing
			//that will rek almost anyone
		if(using_scattershot || beaming || Beam_stunned() || cant_blast()) return
		if(Ki < GetSkillDrain(mod = s.Drain, is_energy = 1)) return
		return 1

	StopScatterShotting(obj/Attacks/Scatter_Shot/s)
		if(!using_scattershot)
			return
		src << "<font color=cyan>You stop using Scatter Shot"
		using_scattershot = 0
		lastStopScattershot = world.time
		attacking = 0
		overlays -= BlastCharge
		AlterInputDisabled(-1)
		for(var/obj/Blast/b in s.scatter_shot_blasts)
			if(b.z && b.Owner == src)
				if(ScatterShotInterrupted(s, ignore_low_ki = 1)) b.ScatterShotInterruptedFlyOff()
				else b.ScatterShotAttackTarget()

	ScatterShotInterrupted(obj/Attacks/Scatter_Shot/s, ignore_low_ki)
		if(KO || knock_dist >= 5 || stun_level || Frozen || cant_blast(ignore_attack_check = 1)) return 1
		if(!ignore_low_ki && Ki < GetSkillDrain(mod = s.Drain, is_energy = 1)) return 1

	ScatterShot(obj/Attacks/Scatter_Shot/s)
		for(var/obj/Blast/b in s.scatter_shot_blasts) if(!b.z || b.Owner != src) s.scatter_shot_blasts -= b
		AlterInputDisabled(1)
		attacking = 3
		using_scattershot = 1
		overlays += BlastCharge
		player_view(10,src) << sound('BasicbeamCharge.ogg', volume = 20)
		//var/charge_delay = TickMult(15 + (3 * Speed_delay_mult(severity = 0.5)))
		//sleep(charge_delay)
		overlays -= BlastCharge

		FireScatterShotsLoop(s)
		StopScatterShotting(s)

	FireScatterShotsLoop(obj/Attacks/Scatter_Shot/s)
		var
			refire = 1 + (1 * Speed_delay_mult(severity = 0.5)) * 0.5
			last_retarget = 0
			mob/target
			shots_fired = 0
		refire *= 0.75 //arbitrary
		while(using_scattershot)
			if(ScatterShotInterrupted(s)) break
			else
				if(world.time - last_retarget > 6)
					target = LungeTarget(dist_override = 21) //will be null if no target found
					last_retarget = world.time
				if(!knock_dist) //temporarily interrupted
					NewScatterShotBlast(target, s)
					shots_fired++
				if(shots_fired > 100)
					//using_scattershot = 0 //i turned this line off because it seems to stop you from ever being allowed to fire the scattershots you already made thus bugging you until you relog
					break
				sleep(TickMult(refire))

	NewScatterShotBlast(mob/m, obj/Attacks/Scatter_Shot/s)
		set waitfor=0
		if(!m) return
		flick("Attack",src)
		player_view(10,src) << sound('Blast.wav', volume = 10)
		Ki -= GetSkillDrain(mod = s.Drain, is_energy = 1)

		var/obj/Blast/b = get_cached_blast()
		s.scatter_shot_blasts += b
		//Percent was 3.7 before they asked me to buff it
		b.setStats(src, Percent = 5, Off_Mult = 1, Explosion = 3, homing_mod = 2)
		b.Distance = 150
		b.pixel_x += rand(-6,6)
		b.pixel_y += rand(-6,6)
		b.weaker_obstacles_cant_destroy_blast = 1
		b.icon = s.icon
		b.Shockwave = 1
		b.from_attack = s
		b.SafeTeleport(loc)
		b.scattershot_target = m
		b.blast_go_over_owner = 1
		b.pass_over_owners_blasts = 1
		b.skip_all_collisions = 1
		b.transform *= rand(85,115) / 100
		b.Can_Home = 0

		var/list/l = Circle(13, m, viewable_only = 1)
		for(var/turf/t in l) if(t.density) l -= t
		if(l && l.len) //avoid "pick from empty list" error spam
			var/turf/t = pick(l)
			if(t) b.ScatterShotGoTo(t)
*/

obj/Blast
	var
		tmp
			scattershot_attacking_target //if the blast is already trying to go at and hit the target
			mob/scattershot_target

	proc
		ScatterShotGoTo(turf/t)
			set waitfor=0
			vector_speed = 19
			while(loc != t && z && !scattershot_attacking_target)
				density = 0
				vector_step(src, get_global_angle(src,t), vector_speed)
				density = 1
				if(pixel_dist(src,t) * 32 <= vector_speed) break
				sleep(TickMult(ki_projectile_step_delay))

		ScatterShotInterruptedFlyOff()
			set waitfor=0
			scattershot_attacking_target = 1
			Offense = 1
			dir = pick(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)
			walk_rand(src)

		ScatterShotAttackTarget()
			set waitfor=0
			scattershot_attacking_target = 1
			skip_all_collisions = 0
			var/mob/m = scattershot_target
			if(!m || m.z != z)
				ScatterShotInterruptedFlyOff()
				return
			vector_speed = rand(19,25)
			var/angle = get_global_angle(src,m)
			while(z)
				vector_step(src, angle, vector_speed)
				sleep(TickMult(ki_projectile_step_delay))

obj/Attacks/Scatter_Shot
	Drain = 30
	Teach_Timer=1
	student_point_cost = 35
	Cost_To_Learn=6
	icon='Asset17.dmi'
	desc="This will create multiple homing balls all around an opponent, and when its done they will \
	all collide at once on top of them. Individually each ball is weak, but all together it can be \
	extremely devastating to most people. The more energy you get the more balls you can make at once."
	var/Setting=30
	var/tmp/list/scatter_shot_blasts=new

	repeat_macro = 0

	New()
		Drain = initial(Drain)
		. = ..()

	verb/Hotbar_use()
		set hidden=1
		Scatter_Shot()
		//usr.TryScatterShot(src)

	verb/Scatter_Shot()
		set category="Skills"
		if(skill_engine) skill_engine.castSkill(usr, src)

mob/var/tmp/lastSokidan = 0 //world.time

obj/var/tmp/Sokidan
obj/Attacks/Sokidan
	icon='Asset17.dmi'
	Teach_Timer=0.7
	student_point_cost = 25
	Cost_To_Learn=3
	desc="A guided energy bomb that deals equal impact and splash damage and cannot damage its owner."
	var/tmp/Sokidan_Delay=1
	Drain=20

	verb/Hotbar_use()
		set hidden=1
		Sokidan()

	verb/Sokidan()
		set category="Skills"
		usr.StopMovement()
		if(skill_engine) skill_engine.castSkill(usr, src)

obj/Attacks/Genocide
	var/Charging
	Drain=3
	Teach_Timer=5
	student_point_cost = 50
	Cost_To_Learn=40
	icon='Asset18.dmi'
	desc="This is a very weak attack, about the power of a single blast, but each one homes in on your selected \
	target across the planet. Press it once to begin firing, again to stop."
	verb/Hotbar_use()
		set hidden=1
		Genocide()
	verb/Genocide()
		set category="Skills"
		if(!Charging)
			if(usr.cant_blast()) return
			if(usr.Ki<usr.GetSkillDrain(mod = Drain, is_energy = 1)) return
			Charging=1
			usr.overlays+='SBombGivePower.dmi'
			usr.startNexusKiCharge(src, 1)
			usr.attacking=3
			sleep(25*usr.Speed_delay_mult(severity=0.5))
			var/projectiles_fired = 0

			while(Charging && projectiles_fired < 12 && !usr.cant_blast(ignore_attack_check = 1) && usr.Ki>10)
				var/mob/target = usr.getSelectedTarget(require_view = FALSE)
				if(target && !target.Safezone && !(target in All_Entrants) && !target.hiding_energy)
					Skill_Increase(1,usr)
					player_view(10,usr)<<sound('Blast.wav',volume=20)
					var/obj/Blast/A=get_cached_blast()
					A.Distance=500
					A.icon=icon
					A.setStats(usr, Percent = 0.25, Off_Mult = 1, Explosion = 0)
					if(skill_engine) skill_engine.applyHomingSettings(usr, A, null, src)
					A.from_attack=src
					A.loc=usr.loc
					A.dir=get_dir(usr,target)
					A.blast_homing_target = target
					A.followSelectedTarget(target)
					usr.Ki-=usr.GetSkillDrain(mod = Drain, is_energy = 1)
					projectiles_fired++
					sleep(5)
				else sleep(5)

			usr.overlays-='SBombGivePower.dmi'
			usr.clearNexusActionGlow()
			usr.attacking=0
			Charging=0
		else Charging=0

var/list/small_crater_cache=new
var/list/big_crater_cache=new

proc/Small_crater(turf/t)
	var/obj/Crater/c
	if(small_crater_cache.len)
		c=small_crater_cache[1]
		small_crater_cache-=c
	else c=new
	c.loc=t
	Timed_Delete(c,50)
	return c

obj/Crater
	icon='Craters.dmi'
	icon_state="small crater"
	Dead_Zone_Immune=1
	Health=1.#INF
	Grabbable=0
	Nukable=0
	Knockable=0
	Savable=0
	attackable=0

	New()
		for(var/obj/Crater/A in loc) if(A!=src) del(A)
		//SetTransformSize(rand(90,110) / 100)
		//. = ..()

	Del()
		SmallCraterDel()

	proc
		SmallCraterDel()
			set waitfor=0
			var/anim_time = 20
			animate(src, alpha = 0, time = anim_time)
			sleep(anim_time + 1)
			alpha = 255
			SafeTeleport(null)
			transform = null
			small_crater_cache += src

proc/BigCrater(turf/pos, maxSize, growTime, fadeTime, minRangeFromOtherCraters)

	maxSize *= 0.2 //to compensate for the new updated icon we use now that is larger than before

	if(minRangeFromOtherCraters && locate(/obj/BigCrater) in view(minRangeFromOtherCraters, pos)) return
	if(locate(/obj/BigCrater) in pos) return //no need to ever stack a crater in the same exact place. laggy
	var/obj/BigCrater/c
	if(big_crater_cache.len)
		c = big_crater_cache[1]
		big_crater_cache -= c
		c.New()
	else c = new
	c.pixel_y -= 11 //was just a little to high looking
	c.alpha = 255
	if(maxSize) c.craterMaxSize = sqrt(maxSize)
	if(growTime) c.craterGrowTime = growTime
	if(fadeTime) c.craterFadeTime = fadeTime
	c.loc=pos
	c.CraterDeleteTimer()
	return c

obj/BigCrater
	//icon='Craters.dmi'
	//icon_state="Center"

	//icon = 'KikohoCrater.dmi'
	icon = 'Crater2Stretch2019.png'

	Dead_Zone_Immune=1
	Health=1.#INF
	Grabbable=0
	Savable=0
	Nukable=0
	Knockable=0
	attackable=0
	layer = TURF_LAYER + 0.1

	var
		craterMaxSize = 1
		craterGrowTime = 1.7
		craterFadeTime = 20

	New()
		CenterIcon(src)
		transform = matrix() * 0.01
		CraterNew()

		/*layer-=0.1
		var/image/A=image(icon='Craters.dmi',icon_state="N",pixel_y=32)
		var/image/B=image(icon='Craters.dmi',icon_state="S",pixel_y=-32)
		var/image/C=image(icon='Craters.dmi',icon_state="E",pixel_x=32)
		var/image/D=image(icon='Craters.dmi',icon_state="W",pixel_x=-32)
		var/image/E=image(icon='Craters.dmi',icon_state="NE",pixel_y=32,pixel_x=32)
		var/image/F=image(icon='Craters.dmi',icon_state="NW",pixel_y=32,pixel_x=-32)
		var/image/G=image(icon='Craters.dmi',icon_state="SE",pixel_y=-32,pixel_x=32)
		var/image/H=image(icon='Craters.dmi',icon_state="SW",pixel_y=-32,pixel_x=-32)
		overlays=null
		overlays.Add(A,B,C,D,E,F,G,H)*/
		//. = ..()

	Del()
		BigCraterDel()

	proc
		CraterNew()
			set waitfor=0
			sleep(world.tick_lag)
			animate(src, transform = matrix() * craterMaxSize * rand(75,115) / 100, time = craterGrowTime)

		CraterDeleteTimer()
			set waitfor=0
			sleep(craterGrowTime + 60)
			del(src)

		BigCraterDel()
			set waitfor=0
			var/anim_time = craterFadeTime
			animate(src, alpha = 0, time = anim_time)
			sleep(anim_time + 1)
			SafeTeleport(null)
			transform = null
			big_crater_cache += src

obj/Blast/Genki_Dama
	Piercer=0
	Explosive=20
	density=1
	Sokidan=1
	weaker_obstacles_cant_destroy_blast = 1

mob/var/tmp/shockwaving
obj/Attacks/Shockwave
	teachable=1
	hotbar_type="Ability"
	can_hotbar=1
	Cost_To_Learn=3
	Teach_Timer=0.5
	student_point_cost = 15
	Drain=15
	desc="This emits a shockwave that will knockback anyone within range, dealing some damage. It does \
	damage based on your strength + force, compared to the target's durability + resistance"
	repeat_macro=1

	verb/Hotbar_use()
		set hidden=1
		Shockwave()

	verb/Shockwave()
		set category="Skills"
		if(skill_engine) skill_engine.castSkill(usr, src)

mob/var/tmp/next_shockwave=0
