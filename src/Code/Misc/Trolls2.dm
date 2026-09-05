/*
make it so you can ask them to spar and they will say okay and fight you standing still and stop when ko'd or you stop attacking for like 5 seconds
make them generously give resources to someone who asks for them. bots get +1 mil in their inventory every 5 minutes and caps at say 5 mil

make them follow you if you say their name and "follow" or "come"
*/

mob/Admin4/verb/newtroll()
	set category="Admin"
	var/mob/new_troll/nt=new(loc)
	switch(alert(src,"Does this troll join tournaments?","Options","Yes","No"))
		if("No") if(nt) nt.troll_joins_tournaments=0
		if("Yes") if(nt) nt.troll_joins_tournaments=1

proc
	GetRandomTextColor()
		var
			textR = rand(0,255)
			textG = rand(0,255)
			textB = rand(0,255)
		if(textR + textG + textB < 240)
			switch(rand(1,3))
				if(1) textR = rand(150,255)
				if(2) textG = rand(150,255)
				if(3) textB = rand(150,255)
		return rgb(textR, textG, textB)

	RandomInsultName()
		return

mob/proc/TrollRespawn()
	var/mob/new_troll/nt = src
	z = 0
	sleep(600)
	nt.player = null
	nt.attacker = null
	SafeTeleport(nt.troll_spawn_loc)
	Revive()

mob/var
	provokedByWords = 1 //whether certain words will make it angry
	doesTalk = 1 //some trolls are just silent afkers always and never talk
	baseName //their name without any prefixes or suffixes that were attached afterward

var/list/trollbots = new

mob/new_troll
	Savable_NPC = 0 //set this to 0 if you ever dont want them to save between reboots again
	max_ki = 5000
	bp_mod = 2
	Race="Saiyan"
	leech_rate = 5
	Zanzoken=1000
	base_bp=1000
	gravity_mastered=10
	Dead_Zone_Immune=1
	canMindSwapWith = 0
	var
		trollInit //whether they have already been initialized the first time
		troll_joins_tournaments=1
		tmp/obj/Attacks/Beam/beam
		tmp
			turf/troll_spawn_loc
			trollRunAwayLoop
			runAwayUntil = 0 //time
			trollCombatMode //melee, blast, beam. what method of combat the troll is currently engaging in
		tmp/mob
			player
			attacker //the last person to attack you
		end_combat=0 //and the time the troll stops fighting
		path_steps_remaining=0
		target_reached
		followPlayers = 1 //see fakePlayers2019.dm
		followTargetDelay = list(0, 60) //the minimum and maximum times the bot "doesnt notice" that the player is not near them and pursues them again
		can_talk=1
		talk_mode=0
		followDist = 4 //the distance the troll will stop trying to get closer to you at, randomized
		firesBlasts = 1 //like players, some people simply NEVER use anything but melee
		trollTalksPissedIfYouDontTrain = 1 //this troll will get inevitably talk pissed to you for not helping it
		trollAttacksIfYouDontTrain = 1
		attackIfAttackedChance = 50
		cowardIfAttacked = 0
		lowHealthTurnCoward = 33 //the health value they will become a coward
		useZanzo = 1
		meleePerceptionDelay = 4.5

		fakeIP
		fakeCID

	New()
		new_troll_ai()

	Del()
		trollbots -= src
		players -= src
		. = ..()

	proc
		new_troll_ai()
			set waitfor=0
			trollbots += src

			players += src //THIS MAY CAUSE PROBLEMS IF SO REMOVE IT - JUNE 4TH 2019
			PlayerListSpoof()

			fakeIP = "[rand(1,255)].[rand(1,255)].[rand(1,255)].[rand(1,255)]"
			fakeCID = num2text(rand(10000000, 99999999), 20)
			//some bots just really dont care much about keeping up with their target, while others are obsessed
			if(prob(50)) followTargetDelay = list(0, rand(30, 60)) //NUMBERS ARE IN SECONDS

			sleep(5)
			update_area()
			dir = pick(NORTH,SOUTH,EAST,WEST)
			troll_spawn_loc = base_loc()

			if(!trollInit)
				var/obj/Attacks/Blast/B = new(src)
				B.Spread=3
				B.Shockwave=1
				B.Blast_Count=2
				var/obj/Icon=pick(Blasts)
				if(isobj(Icon)) B.icon=Icon.icon
				B.icon+=rgb(rand(0,255),rand(0,255),rand(0,255))
				TextColor = GetRandomTextColor()
				var/icons = list('BaseHumanPale.dmi','BaseHumanTan.dmi','BaseHumanDark.dmi','NewPaleFemale.dmi','NewTanFemale.dmi',\
				'NewBlackFemale.dmi','RaceGinyu.dmi','RaceKui.dmi')
				icon = pick(icons)
				if(!(icon in list('RaceGinyu.dmi','RaceKui.dmi')))
					var/obj/O=pick(Hairs)
					if(isobj(O)) overlays+=O.icon

				var/list/L=new
				for(var/obj/O in Clothing) L+=O.icon
				var/Clothes=rand(0,6)
				while(Clothes)
					Clothes-=1
					var/icon/I=pick(L)
					if(prob(70)) I+=rgb(rand(0,50),rand(0,50),rand(0,50))
					overlays+=I

				displaykey = GetTrollKey()

				//i commented these out just to arbitrarily make them weaker. they were very strong
				Raise_Speed(10)
				Raise_Durability(10)
				Raise_Defense(10)
				Raise_Offense(10)
				Raise_Resist(10)
				Raise_Force(10)

				contents+=new/obj/Fly
				contents+=new/obj/Zanzoken
				Warp=1
				KB_On=100
				if(name == initial(name)) troll_name()

			sleep(rand(0,150)) //so that all troll ai doesnt initialize in the same frame on a reboot

			if(!z)
				del(src)
				return

			if(!trollInit)
				meleePerceptionDelay = rand(40,50) / 10
				followDist = rand(1,8)
				firesBlasts = pick(0,1)
				if(prob(50)) useZanzo = 0
				else useZanzo = 1

				doesTalk = 1
				if(prob(50))
					doesTalk = 0 //always silent. never talks. perma afk minding their own business
					followPlayers = 0 //kind of goes hand in hand. looks really unnatural if a non-talking bot is constantly following you around while simultaneously ignoring you

				trollTalksPissedIfYouDontTrain = 0
				if(prob(50)) trollTalksPissedIfYouDontTrain = 1

				trollAttacksIfYouDontTrain = 0
				if(prob(50)) trollAttacksIfYouDontTrain = 1

				provokedByWords = 0
				if(prob(50)) provokedByWords = 1

				attackIfAttackedChance = rand(10,50)
				//if(prob(30)) attackIfAttackedChance = 0 //some just dont care if they get attacked

				cowardIfAttacked = pick(0,1)

				lowHealthTurnCoward = rand(0,80)
				if(prob(50)) lowHealthTurnCoward = 0 //some are brave no matter what

			beam = locate(/obj/Attacks/Beam) in src
			if(!beam)
				beam=new/obj/Attacks/Beam(src)
				beam.WaveMult*=1
				beam.icon='BeamStaticBeam.dmi'
				beam.icon += rgb(rand(0,255),rand(0,255),rand(0,255))

			troll_actions()
			start_talking()
			troll_regen()
			grab_struggle()
			troll_leech()
			detect_blasting()
			CombatTimerDecreaseLoop()
			get_bp_loop()

			Gravity_Update()
			if(Gravity>gravity_mastered) gravity_mastered=Gravity

			if(!trollInit)
				var/mob/m
				for(var/mob/p in players) if(!m || m.base_bp < p.base_bp) m = p
				if(m) Leech(m, 500)
				Attack_Gain(1200)
				base_bp *= 0.4 //arbitrarily weaken them
			trollInit = 1

		//someone attempted to invite this troll to a league
		LeagueInviteTroll(mob/inviter, leagueName)
			set waitfor=0
			sleep(rand(20,50))
			inviter << "[src] has refused to join the [leagueName]"
			if(prob(50))
				sleep(rand(35,70))
				var/list/responses = list("lol", "no thanks", "im a solo player", "i only play solo", "i dont really like leagues", "dont want to")
				TrollSay(pick(responses))

		CantTalkFor(t)
			set waitfor=0
			can_talk = 0
			sleep(t)
			can_talk = 1

		TrollRunAwayMode()
			return

		TrollGotAttacked(mob/m)
			set waitfor=0
			if(prob(attackIfAttackedChance))
				attacker = m
				end_combat = 30

		//how many trolls are currently targeting this player OTHER than this troll
		OtherTrollsTargeting(mob/m)
			var/count = 0
			for(var/mob/new_troll/nt in trollbots)
				if(nt == src) continue
				if(m && nt.player == m)
					count++
			return count

		find_player()
			var/list/a=new
			for(var/mob/m in players) if(m != src && m.type != /mob/new_troll)
				if(m.z == z && m.client && m.client.inactivity < 600 && !m.invisibility && m != player && same_area(src,m))
					if(OtherTrollsTargeting(m) <= 0) //<= 0 means 1 troll per player at a time
						a += m
			if(a.len) player = pick(a)

			//travel to other planet if no players found
			if(!player)
				var/mob/m = pick(players)
				if(m && m.z && !istype(m, /mob/new_troll))
					z = m.z
					update_area()

		invalid_player()
			if(!player || player.z != z || !player.client || player.client.inactivity > 600 || !same_area(src,player))
				return 1

		running_away()
			if(trollRunAwayLoop) return 1
			if(in_combat() && cowardIfAttacked) return 1
			if(Health < lowHealthTurnCoward && get_step_away(src, player, 50)) return 1

		//occasionally remove then reinsert self into player list so all trolls dont end up at the beginning as real players log in and out naturally
		PlayerListSpoof()
			set waitfor=0
			sleep(5 * 600)
			while(src)
				players -= src
				players.Insert(rand(1, players.len), src)
				sleep(10 * 600)

		GetTrollKey()
			return "Guest-[num2text(rand(1000000,9999999),12)]"

		troll_name()
			return

		troll_leech()
			set waitfor=0
			while(src)
				for(var/mob/m in player_view(15,src)) Leech(m, 50)
				sleep(50)

		troll_regen()
			set waitfor=0
			while(src)
				if(Health < 100) Health += 1.2
				if(Ki < max_ki) Ki += max_ki * 0.02
				sleep(10)

		detect_blasting()
			set waitfor=0
			while(src)
				if(KO)
					sleep(15)
					continue
				for(var/obj/Blast/b in view(2,src)) if(get_dir(src,b) in list(NORTH,SOUTH,EAST,WEST))
					if(b.dir==get_dir(b,src)&&ismob(b.Owner)&&b.Owner.client)
						if(prob(attackIfAttackedChance))
							attacker=b.Owner
							end_combat=20
							untrain()
							if(!beam.streaming&&!beam.charging)
								if(b.Beam||(get_dir(src,attacker) in list(NORTH,SOUTH,EAST,WEST)))
									Beam_Macro(beam)
									sleep(3)
									Beam_Macro(beam)
									while(BeamStruggling())
										if(!(get_dir(src,attacker) in list(NORTH,SOUTH,EAST,WEST))) break
										if(!attacker || attacker.KO) break
										dir = get_dir(src,attacker)
										sleep(5)
									stop_beaming()
								else if(!KB) step(src,turn(b.dir,pick(-90,90)))
						break
				sleep(world.tick_lag)

		grab_struggle()
			set waitfor=0
			while(src)
				var/mob/m=Is_Grabbed()
				if(m && !KO)
					if(prob(80)) player_view(15,src)<<"[src] struggles against [m]"
					else
						player_view(15,src)<<"[src] breaks free of [m]!"
						m.ReleaseGrab()
				sleep(20)

		troll_actions()
			set waitfor=0
			while(src)
				if(KO)
					sleep(20)
					continue
				var/didSomething
				if((!player || invalid_player()) && followPlayers) //if followPlayers = 0 it never has a reason to need a target before performing its little actions like training etc
					didSomething = 1
					untrain()
					find_player()
					for(var/v in 1 to 5)
						sleep(10)
						if(interrupted()) break
				else if(running_away())
					didSomething = 1
					untrain()
					TrollRunAwayMode()
					sleep(2)
				else if(in_combat())
					didSomething = 1
					untrain()
					troll_fight()
				else if(!target_reached && followPlayers)
					didSomething = 1
					untrain()
					Fly()
					if(player)
						troll_step()
					if(get_dist(src, player) <= followDist && viewable(src, player))
						target_reached=1
						if(!in_combat() && prob(20) && player && doesTalk)
							var/msg=null
							if(prob(40)) msg = null //just say their name
							if(prob(50))
								if(prob(50))
									msg = "[TrollNickName(player.name)] [msg]"
								else
									msg = "[msg] [TrollNickName(player.name)]"
							msg=mispell(msg,uppercase=pick(0,1),wrong_vowel=0.15,drop_letter=0.05,swap_letter=0.1)
							TrollSay(msg)
							CantTalkFor(45)
					//if(path_steps_remaining) sleep(TickMult(1))
					//else sleep(TickMult(1))
				else
					//check if the target has left the area
					if(followPlayers && !viewable(src, player, followDist))
						if(target_reached)
							didSomething = 1
							target_reached = 0
							var/sleepTime = rand(followTargetDelay[1],followTargetDelay[2]) //simulate a lack of awareness that the target has gone out of sight of them before going onto the next
							//troll_action (which is to follow them) because always insta-following them as soon as they go off screen is extremely unnatural
							//looking
							if(sleepTime)
								for(var/v in 1 to sleepTime)
									sleep(10)
									var/reason = interrupted()
									if(reason && reason != "target not reached" && reason != "not viewable")
										break
					if(target_reached || !followPlayers)
						didSomething = 1
						Land()
						untrain()
						var/list/action_list=list("train","med","walk a line")
						if(prob(30)) action_list += "fire beam" //they fired beams too often
						if(prob(35)) action_list += "fly circles" //they were doing this too often
						if(player) action_list += "face target"
						switch(pick(action_list))
							if("train")
								Train()
								var/seconds=rand(10,90)
								if(!followPlayers) seconds = 5 * 60
								for(var/v in 1 to seconds)
									sleep(10)
									if(interrupted() || KO || KB) break
							if("med")
								Meditate()
								var/seconds=rand(10,90)
								if(!followPlayers) seconds = 5 * 60
								for(var/v in 1 to seconds)
									sleep(10)
									if(interrupted() || KO || KB) break
							if("walk a line")
								var/lines = rand(1,6)
								if(!followPlayers) lines = rand(1,6)
								CantTalkFor(lines * world.tick_lag * 30)
								while(lines > 0)
									lines--
									var/dist=rand(1,8)
									if(!followPlayers) dist = rand(1,8)
									var/stepDelay = world.tick_lag * rand(1,2)
									dir=pick(NORTH,SOUTH,EAST,WEST, NORTHWEST, NORTHEAST, SOUTHWEST, SOUTHEAST)
									for(var/v in 1 to dist)
										var/success
										if(!KB) success = step(src,dir)
										sleep(stepDelay)
										if(interrupted() || !success || KO || KB) break
									if(prob(50)) sleep(rand(20,30)) //looks more natural if they sometimes stop for a while then go in another direction
							if("face target")
								if(player) step_away(src,player,99)
								sleep(TickMult(rand(2,6)))
								if(player && !KB) step_towards(src,player)
								var/seconds=rand(2,5) //wait this many seconds before doing another action
								for(var/v in 1 to seconds)
									sleep(10)
									if(interrupted() || KO || KB) break
							if("fly circles")
								Fly()
								dir=NORTH
								var/circles=rand(10, 140)
								var/turn_dir = pick(90,-90,45,-45)
								var/turnChance = rand(20,80)
								var/sleepDelay = 1
								CantTalkFor(circles * sleepDelay)
								for(var/v in 1 to circles)
									var/success
									if(!KB)
										if(prob(turnChance))
											success = step(src,turn(dir,turn_dir))
										else
											success = step(src,dir)
									sleep(TickMult(sleepDelay))
									if(interrupted() || !success || KO || KB) break //ALWAYS PUT interrupted() AFTER THE SLEEP TO MAKE POTENTIAL INFINITE LOOPS IMPOSSIBLE
								Land()
							if("fire beam")
								if(!beam.streaming&&!beam.charging)
									var/list/dirs=list("n","s","e","w")
									for(var/mob/m in player_view(10, src)) if(m.client)
										if(get_dir(src,m)==NORTH) dirs-="n"
										if(get_dir(src,m)==SOUTH) dirs-="s"
										if(get_dir(src,m)==EAST) dirs-="e"
										if(get_dir(src,m)==WEST) dirs-="w"
									if(dirs.len)
										Beam_Macro(beam) //start charging
										switch(pick(dirs))
											if("n") dir=NORTH
											if("s") dir=SOUTH
											if("e") dir=EAST
											if("w") dir=WEST
										sleep(10)
										Beam_Macro(beam) //fire
										var/seconds=rand(3,12)
										for(var/v in 1 to seconds)
											sleep(10)
											if(interrupted() || KO || KB) break
										stop_beaming() //stop firing
				if(!didSomething) sleep(10)
				else sleep(world.tick_lag) //remember this line is currently how fast they move toward a target too

		in_combat()
			if(attacker && !attacker.KO && end_combat && getdist(src, attacker) < 20) return 1

		CombatTimerDecreaseLoop()
			set waitfor=0
			sleep(10)
			while(src)
				end_combat--
				if(end_combat < 0) end_combat = 0
				sleep(10)

		TrollMeleeMoveLoop()
			set waitfor=0
			while(trollCombatMode == "melee")
				if(KO)
					sleep(10)
					continue
				if(!attacker)
					sleep(5)
					continue
				var/turf/attackerLoc = attacker.base_loc()
				if(!attackerLoc)
					sleep(5)
					continue
				MeleeMoveStep(attackerLoc)
				sleep(world.tick_lag)

		MeleeMoveStep(turf/attackerLoc)
			set waitfor=0
			sleep(meleePerceptionDelay) //perception delay. so it doesnt follow you instantly like an obvious ai. it goes to where you WERE not where you ARE
			if(!attacker || KO || KB) return
			var/dist = get_dist(src, attacker)
			if(dist <= 1)
				dir = get_dir(src, attacker)
			else
				step_to(src,attackerLoc)

		troll_fight()
			if(KO)
				sleep(5)
				return
			//the bot is already busy firing a beam, probably as one of their generic actions to appear more real, so we must wait til that is done to start combat
			if(beam.streaming || beam.charging)
				sleep(5) //prevent freezes from infinite undelayed calls to troll_fight()
				return

			trollCombatMode = null

			if(useZanzo && prob(15) && attacker && !KO && !KB)
				var/zanzos = rand(1,3)
				for(var/v in 1 to zanzos)
					var/turf/t
					if(attacker) t = locate(attacker.x + rand(-12,12), attacker.y + rand(-12,12), attacker.z)
					var/success = TrollZanzo(t)
					if(success) sleep(4)
				return

			if(attacker.Flying) Fly()
			else Land()
			var/actions = list("melee", "ki")
			if(firesBlasts == 0) actions -= "ki" //like players, sometimes they just never use anything but melee
			switch(pick(actions))
				if("melee")
					trollCombatMode = "melee"
					TrollMeleeMoveLoop() //needs decoupled from this timestep for realism
					var/seconds=rand(6,12)
					while(src)
						if(!in_combat()) break
						else Melee()
						var/delay = world.tick_lag
						seconds -= delay * 0.1
						if(seconds <= 0 || KO) break
						else sleep(delay)
				if("ki")
					//beaming
					if(get_dir(src,attacker) in list(NORTH,SOUTH,EAST,WEST))
						trollCombatMode = "beam"
						Beam_Macro(beam)
						sleep(3)
						Beam_Macro(beam)
						var/stopTime = world.time + rand(10, 30)
						while(world.time < stopTime || BeamStruggling())
							if(attacker) dir = get_dir(src, attacker)
							if(!in_combat() || KO || KB) break
							sleep(5)
						stop_beaming()
					//blasting
					else
						trollCombatMode = "blast"
						var/seconds = rand(2,5)
						var/can_step = 1
						while(src)
							if(!in_combat() || KO || KB) break
							if(can_step && step_away(src,attacker,8)) sleep(world.tick_lag)
							else
								can_step=0
								if(dir != get_dir(src, attacker))
									step_towards(src, attacker)
								Blast_Fire()
								var/delay = 1
								seconds -= delay * 0.1
								if(seconds <= 0) break
								else sleep(delay)
			trollCombatMode = null

		TrollZanzo(turf/t)
			if(KO) return
			if(!t || t.density || BeamStruggling() || Charging_or_Streaming() || stun_level || Beam_stunned() || ki_shield_on() || !viewable(src, t) || \
			t.type == /turf/Other/Blank)
				return
			for(var/atom/movable/m in t) return
			player_view(10,src) << sound('Teleport.ogg',volume=15)
			flick('Zanzoken.dmi',src)
			AfterImage()
			SafeTeleport(t)
			return 1

		get_troll_angry_message()
			var/msg=pick(list("I TOLD YOU I WOULD FUCKING KILL YOU IF YOU DIDNT TRAIN ME","NOW YOU DIE",\
			"YOUR RAIN OF TERROR IS OVER YOU SHOULD HAVE LISTENED","TRAIN ME ARE YOU DIE","YOU [uppertext(RandomInsultName())] YOU SHOULD HAVE LISTENED",\
			"[uppertext(RandomInsultName())] DIE","[uppertext(RandomInsultName())]","YOU DAMMIT YOU GOTTA BE SUCH A [uppertext(RandomInsultName())] JUST TRANE ME AND ILL STOP","WHY ARE YOU SUCH A [uppertext(RandomInsultName())]?",\
			"DIS IS YOUR FAULT FOR NOT TRAININ ME","YOU HAD YOUR CHANCE","NOW YOU PAY","MASTER JUST DO IT","ILL STOP IF YOU \
			TRANE ME","YOU DIE NOW","I SHALL HAVE MY REVENGE","YOU SHALL PAY","YOU REFUSE ME NOW YOU DIE","THIS IS YOUR FAULT",\
			"ILL KILL YOU NOW","IM GONNA ROB YOU TOO","YOU STUPID [uppertext(RandomInsultName())] I WARNED YOU","NOW PAY FOR YOUR SINS","YOU [uppertext(RandomInsultName())] I TOLD YOU",\
			"YOU DIDNT LISTEN NOW FEEL MY RAGE","I AM MAD AT YOU NOW DIE","FREEZA IS MAKING ME ATTACK YOU HE HAS \
			CONTROL OF MY MIND!!!","MAJIN BUU CONTROLS MY MIND HE MAKING ME ATTACK","AHHH IVE GONE MAJIN BECAUSE BABIDI HE MAKING \
			ME ATTACK YOU","HELP ME MASTER THEY ARE CONTROLLING MY MIND","STOP THEM MASTER THEYRE CONTROLLING ME"))
			return msg

		start_talking()
			return

		stop_beaming()
			if(beam.charging) Beam_Macro(beam)
			sleep(TickMult(5))
			if(beam.streaming) Beam_Macro(beam)

		interrupted(checkTargetReached = 1)
			if(!target_reached && checkTargetReached) return "target not reached"
			if(in_combat()) return "in combat"
			if(running_away()) return "running away"
			if(followPlayers)
				if(!player) return "no player"
				if(invalid_player()) return "invalid player"
				if(!viewable(src, player, 10)) return "not viewable"

		untrain()
			if(Action=="Training") Train()
			if(Action=="Meditating") Meditate()

		TrollTargetedPlayer()
			if(in_combat()) return attacker
			else return player

		troll_step()
			if(KO || KB || beam.streaming || beam.charging) return

			var/mob/m = TrollTargetedPlayer()
			if(!m) return

			if(path_steps_remaining)

				//g_step_to(m)

				if(step_to(src,m))
				else find_player() //cant get to whoever the current player is. so get a new player if possible

				path_steps_remaining--

			else if(!step_towards(src,m))
				path_steps_remaining=20
				//var/turf/t = Get_step(src,dir)

				//i just didnt want them obnoxiously breaking everything anymore. but this code still works if we uncomment it
				/*if(t && isturf(t) && t.density && t.Health != 1.#INF)
					flick("Attack",src)
					t.destroy_turf()

				else for(var/obj/o in Get_step(src,dir)) if(o.density && o.Health != 1.#INF)
					flick("Attack",src)
					del(o)*/

turf/proc/destroy_turf()
	Health=0
	Destroy()

proc/same_area(mob/a,mob/b)
	if(a.get_area() == b.get_area()) return 1

//this appears to no longer be in use anywhere
mob/proc/respond_anyway(msg)
	var/list/words=list("npc","not real","s fake","real player")
	words += name
	words += lowertext(name)
	words += uppertext(name)
	words += "[uppertext(copytext(name,1,2))][copytext(name,2,length(name)+1)]"
	for(var/v in words) if(findtext(msg,v)) return 1

mob/proc/NameMentioned(msg)
	var/list/words = new
	if(baseName && baseName != "")
		words += baseName
		words += lowertext(baseName)
		words += uppertext(baseName)
		words += "[uppertext(copytext(baseName,1,2))][copytext(baseName,2,length(baseName)+1)]"
	for(var/v in words) if(findtext(msg,v)) return 1

//lets the troll refer to a player by a shortened version of their name which looks more natural
mob/proc/TrollNickName(n = "")
	var/index_num = findtext(n," ") //find a space and return the index in the string it is found at
	if(index_num != 0)
		n = copytext(n,1,index_num)
	return n

mob/proc/TrollSay(msg)
	if(prob(1)) OOC(msg)
	else Say(msg)

//what if instead of a preset order of which snippets are processed first to last, its a list of snippets, and each troll shuffles the list so they response uniquely
//to them in order of what they think takes priority to respond to in the sentence?
mob/proc/troll_respond(msg)
	return

//uppercase is either 0 or 1. others are 0 to 1 indicating probability, with 1 being 100%
proc/mispell(name, uppercase=1, wrong_vowel=0.1, drop_letter=0.1, swap_letter=0.1)

	if(!name) return name

	name=lowertext(name)
	var/list/l=new
	for(var/v in 1 to length(name))
		var/t=copytext(name,v,v+1)
		if(!(t in list("0","1","2","3","4","5","6","7","8","9")))
			if(prob(wrong_vowel * 9)&&(t in list("a","e","i","o","u"))) t=pick("a","e","i","o","u")
			if(prob(100-(drop_letter*4))&&!is_symbol(t)) l+=t

	while(prob(40 * swap_letter))
		var/n=pick(1,length(l)-1)
		l.Swap(n,n+1)

	var/new_name=""
	for(var/v in l) new_name="[new_name][v]"
	if(uppercase) new_name=uppertext(new_name)
	else new_name=lowertext(new_name)
	return new_name

proc/is_symbol(t)
	if(t in list("`","~","@","#","$","%","^","&","*","(",")","{","}","<",">")) return 1
