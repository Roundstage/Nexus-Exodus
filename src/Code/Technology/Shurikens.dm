obj/items/Shuriken
	Cost=5000
	can_change_icon=1
	Stealable=1
	icon='Shuriken.dmi'
	desc="This is a ranged move based on the thrower's strength"
	var/Shurikens=100
	var/Shrapnel
	science = 1
	science_level = 2

	hotbar_type="Combat item"
	can_hotbar=1
	repeat_macro=1

	var/Bounce
	var/Explosive=0
	var/Knockback=0
	Can_Drop_With_Suffix=1

	New()
		suffix="[Commas(Shurikens)]"
		. = ..()

	verb/Upgrade()
		set src in view(1)
		var/mob/user = usr
		var/atom/original_location = loc
		if(user in view(1,src)) while(user)
			if(loc != original_location) return
			if(original_location == user)
				if(!canUseAfterNexusTradeYield(user)) return
			else if(!(src in view(1,user))) return
			var/Shrapnel_Cost=1000/user.Intelligence()
			var/Bounce_Cost=1000/user.Intelligence()
			var/Explode_Cost=1000/user.Intelligence()
			var/KB_Cost=1000/user.Intelligence()
			var/list/L=list("Cancel","Add Ammo")
			if(!Shrapnel) L+="Shrapnel ([Commas(Shrapnel_Cost)]$)"
			if(!Bounce) L+="Wall Bounce ([Commas(Bounce_Cost)]$)"
			if(!Explosive) L+="Explosive ([Commas(Explode_Cost)]$)"
			if(!Knockback) L+="Knockback ([Commas(KB_Cost)]$)"
			var/C=input(user,"Options") in L
			if(!user || loc != original_location) return
			if(original_location == user)
				if(!canUseAfterNexusTradeYield(user)) return
			else if(!(src in view(1,user))) return
			if(!(C in L)) return
			if(C=="Cancel") return
			if(C=="Add Ammo")
				var/Cost=round(5/user.Intelligence(),0.1)
				var/N=input(user,"How much ammo do you want to add? It cost you [Cost]$ per 1 ammo. You can add a max of \
				[round(user.Res()/Cost)] more ammo") as num
				if(!user || loc != original_location) return
				if(original_location == user)
					if(!canUseAfterNexusTradeYield(user)) return
				else if(!(src in view(1,user))) return
				if(N<0) return
				if(N>round(user.Res()/Cost)) N=round(user.Res()/Cost)
				Cost*=N
				user.Alter_Res(-Cost)
				Shurikens+=round(N)
				player_view(15,user)<<"[user] increases the [src]'s ammo to [Shurikens] (Cost: [Commas(Cost)]$)"
				suffix="[Commas(Shurikens)]"

			if(C=="Shrapnel ([Commas(Shrapnel_Cost)]$)")
				if(user.Res()<Shrapnel_Cost) return
				player_view(15,user)<<"[user] adds shrapnel attribute to [src]"
				Shrapnel=1
				user.Alter_Res(-Shrapnel_Cost)
				user << "Shrapnel attribute makes shurikens use +1 ammo per shot"

			if(C=="Wall Bounce ([Commas(Bounce_Cost)]$)")
				if(user.Res()<Bounce_Cost) return
				player_view(15,user)<<"[user] adds bounce attribute to [src]"
				Bounce=1
				user.Alter_Res(-Bounce_Cost)
				user << "Bounce attribute makes shurikens use +1 ammo per shot"

			if(C=="Explosive ([Commas(Explode_Cost)]$)")
				if(user.Res()<Explode_Cost) return
				player_view(15,user)<<"[user] adds explosion attribute to [src]"
				Explosive=1
				user.Alter_Res(-Explode_Cost)
				user << "This makes shurikens do 1.5x more damage and turns the damage to AoE damage. Downside is you fire 2x slower"

			if(C=="Knockback ([Commas(KB_Cost)]$)")
				if(user.Res()<KB_Cost) return
				player_view(15,user)<<"[user] adds knockback attribute to [src]"
				Knockback=1
				user.Alter_Res(-KB_Cost)

	verb/Hotbar_use()
		set hidden=1
		Shuriken()

	verb/Shuriken()
		set category="Skills"
		if(usr.tournament_override()) return
		if(usr.cant_blast()) return
		if(usr.KO||usr.KB||usr.grabbedObject) return
		var/stam_drain = 1
		if(usr.stamina < stam_drain) return
		if(Shurikens)
			Shurikens--
			if(Shrapnel) Shurikens--
			if(Bounce) Shurikens--
			usr.AddStamina(-stam_drain)

			var/explosion_dmg_mult = 1

			suffix="[Commas(Shurikens)]"
			usr.attacking=3
			var/delay = usr.get_shuriken_refire()
			if(Explosive) delay *= explosion_dmg_mult
			if(Explosive) delay *= 2 //exploding shuris are just in general too OP
			spawn(delay) if(usr) usr.attacking=0
			if(!Shurikens) usr<<"You are out of shurikens. Right click them and hit upgrade to add more"
			player_view(10,usr)<<sound('Swordhit.ogg',volume=30)
			var/obj/Blast/A=get_cached_blast()
			A.Is_Ki=0
			A.Distance=35
			A.Fatal=usr.Fatal
			A.icon=icon
			A.Owner=usr
			var/dmg = 7
			if(Explosive) dmg *= explosion_dmg_mult
			A.setStats(usr, Percent = 7, Off_Mult = 1.02, Explosion = Explosive * 2, bullet = 1, explosion_percent = Explosive ? 3.5 : 0)
			A.from_attack=src
			A.Force/=usr.sword_mult()
			A.Bullet=1
			A.Shrapnel=Shrapnel
			A.Bounce=Bounce
			A.Shockwave=Knockback
			if(Explosive) A.Shockwave *= 3
			A.bleed_damage = 1
			A.shuriken = 1
			A.dir=usr.dir
			A.SafeTeleport(usr.loc)
			walk(A,A.dir)


mob/var/tmp
	list/shuriken_overlays = new

mob/proc
	ShurikenOverlayEffect(icon/i)
		if(!i) return
		var/max_len = 10
		shuriken_overlays.len = max_len
		var/image/img = image(icon = i, pixel_x = rand(-7,7), pixel_y = rand(-13,5))
		overlays += img
		shuriken_overlays.Insert(1,img)
		if(shuriken_overlays.len > max_len)
			overlays -= shuriken_overlays[max_len + 1]
			shuriken_overlays.len = max_len
		RemoveShurikenOverlay(img, rand(300,600))

	RemoveShurikenOverlay(image/i, t = 0)
		set waitfor=0
		sleep(t)
		shuriken_overlays -= i
		overlays -= i

	TakeOffShurikenOverlaysOnSave()
		for(var/image/i in shuriken_overlays) overlays -= i

	ReApplyShurikenOverlaysOnSave()
		for(var/image/i in shuriken_overlays) overlays += i
