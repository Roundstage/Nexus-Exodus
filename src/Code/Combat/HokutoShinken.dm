mob/proc/using_hokuto() if(hokuto_obj&&hokuto_obj.Attacking) return 1

var/hundred_crack_hit_damage_mult = 0.5
var/hundred_crack_min_hits = 24

mob/var/tmp/obj/Hokuto_Shinken/hokuto_obj

obj/Hokuto_Shinken
	teachable=1
	Skill=1
	name="Hundred Crack Fist"
	hotbar_type="Melee"
	can_hotbar=1
	Teach_Timer=3
	student_point_cost = 30
	Cost_To_Learn=11
	desc="A sustained rush of twenty-four or more rapid strikes. Each hit deals increased melee damage, but the technique never executes the target or knocks out its user."
	var/tmp/Attacking
	New()
		spawn if(ismob(loc))
			var/mob/M=loc
			M.hokuto_obj=src

	verb/Hotbar_use()
		set hidden=1
		Hundred_Crack_Fist()

	verb/Hundred_Crack_Fist()
		set category="Skills"
		if(usr.beaming||usr.charging_beam)
			usr<<"You can not use this and beam at the same time"
			return
		if(usr.tournament_override(fighters_can=0)) return

		if(usr.KO||Attacking||usr.attacking) return
		if(usr.beaming||usr.charging_beam)
			usr<<"You can not use this and beam at the same time"
			return
		var/list/Chosen_Targets=new

		for(var/mob/P in player_view(15,usr))
			if(P!=usr&&!P.Safezone&&(get_dir(usr,P) in list(usr.dir,turn(usr.dir,45),turn(usr.dir,-45))))
				Chosen_Targets+=P
				if(alignment_on&&both_good(usr,P)) Chosen_Targets-=P
				if(Same_league_cant_kill(usr,P)) Chosen_Targets-=P

		if(usr.KO) return
		if(usr.beaming||usr.charging_beam)
			usr<<"You can not use this and beam at the same time"
			return
		if(Attacking||usr.attacking) return
		if(!(locate(/mob) in Chosen_Targets))
			usr<<"No viable targets..."
			return
		player_view(10,usr)<<sound('AiWoTorimodose2.ogg',volume=30)
		Attacking=1
		usr.attacking=3
		player_view(10,usr)<<sound('ATATATA.ogg')
		player_view(10,usr)<<"A glowing aura of power appears around [usr], suddenly their shirt rips off!"
		spawn(12) if(usr)
			for(var/obj/items/Clothes/TankTop/K in usr.item_list) if(K.suffix) K.Click(usr)
			for(var/obj/items/Clothes/ShortSleeveShirt/K in usr.item_list) if(K.suffix) K.Click(usr)
		var/Aura='AuraTall.dmi'+rgb(255,255,255)
		var/image/I=image(icon=Aura,icon_state="top",pixel_y=32)
		var/image/F=image(icon=Aura,icon_state="bottom")
		usr.overlays.Add(I,F)
		sleep(62)
		usr.Say("HOOOO!!! ATATATATATATATATATATATATA!!!")
		var/Amount = hundred_crack_min_hits
		BigCrater(pos = usr.loc, minRangeFromOtherCraters = 4)
		Dust(usr, end_size = 0.6, time = 7)
		Make_Shockwave(usr,sw_icon_size=256)
		while(Amount && usr && !usr.KO)
			Amount-=1
			if(Chosen_Targets)
				var/mob/M=pick(Chosen_Targets)
				if(M&&M.z==usr.z&&!M.KO)
					usr.Warp_To(Get_Warp_Destination(M,usr),M)
					usr.dir=get_dir(usr,M)
					usr.hundredCrackFistHit(M)
					spawn if(usr && prob(20)) Make_Shockwave(usr,sw_icon_size=pick(64,128))
			sleep(3)
		if(usr)
			usr.Say("You are already beaten.")
			usr.overlays.Remove(I,F)
			usr.Ki/=5
			usr.attacking=0
			Skill_Increase(1,usr)
		Attacking=0

mob/proc/hundredCrackFistHit(mob/target)
	if(!target || target.KO || target.Safezone || target.z != z) return 0
	var/accuracy = Clamp(get_melee_accuracy(target) * 1.15, 5, 100)
	if(!prob(accuracy))
		player_view(12, src) << sound(pick('Meleemiss1.ogg', 'Meleemiss2.ogg', 'Meleemiss3.ogg'), volume = 20)
		return 0
	var/damage = getPhysicalCombatDamage(target, hundred_crack_hit_damage_mult)
	flick("Attack", src)
	player_view(12, src) << sound(pick('Weakpunch.ogg', 'Mediumpunch.ogg'), volume = 25)
	target.TakeDamage(damage, 1, attacker = src, attack_name = "Hundred Crack Fist")
	target.SetLastAttackedTime(src)
	target.setOpponent(src)
	return 1

mob/proc/Hokuto_Shinken_Effects(mob/P)
	set waitfor=0
	if(!P) return
	for(var/obj/Hokuto_Shinken_Energy/E in src) if(E.Creator==P.key)
		del(E)

mob/proc/Add_Hokuto_Shinken_Energy(mob/P) if(ismob(P)) if(!(locate(/obj/Hokuto_Shinken_Energy) in P))
	if(hokuto_obj&&hokuto_obj.Attacking)
		var/obj/Hokuto_Shinken_Energy/E=new
		E.Creator=key
		E.Level=BP
		E.hs_str=Str/sword_mult()
		E.hs_force=Pow
		P.contents+=E

obj/Hokuto_Shinken_Energy
	Givable=0
	Makeable=0
	var
		hs_str=1
		hs_force=1
	New() spawn(3000) if(src) del(src)
