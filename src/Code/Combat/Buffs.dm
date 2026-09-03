/*
YOU LEARN NEW BUFF ATTRIBUTES IN LEARN USING SP THEN YOU CAN APPLY THEM TO ANY CUSTOM BUFF YOU HAVE.

finish attribute system

attribute ideas
	trans bp: add a big ssj-like bp boost on top of your trans based on the avg bp. this adds energy drain
		which scales based on how many times greater the temp boost is compared to your base bp
	illusion: make copies of yourself to confuse your opponent. sometimes you and your copies will switch
		places so the enemy cant figure out which is you for long
		illusions constantly change direction to face the enemy
	berserker: you auto melee fight your opponent with no control over yourself. you attack nearest targets
	random KO: like limit breaker, gain added power, but don't know when it'll KO you
	giant: just makes you large like the Giant buff does
	God_Fist: gain added power of some kind by having the buff drain your health
	channel anger: gain bp boost of sqrt(anger), but have some other stat(s) /anger. no bp drain of course
		or perhaps gain sqrt(anger) on top of the current bp boost of your buff, and have the drain only

Make more transformation graphics modules

Make able to add duplicate trans gfx modules. like 2 kinds of shockwaves
*/
#define NEXUS_CUSTOM_BUFF_POINT_CAP 27

mob/var
	list
		known_buff_attributes=new
		active_buff_attributes=new
	buff_transform_bp=0 //bp from the transform buff attribute
	tmp/rebuff_timer=0

mob/var/tmp/buff_drain_loop

mob/proc/Buff_Drain_Loop()
	set waitfor=0
	if(buff_drain_loop) return
	buff_drain_loop=1
	while(src)
		var/obj/Buff/B=buffed()
		if(B&&B.buff_bp>1)
			var/Drain=3*(B.buff_bp-1)/Eff**0.5
			Drain=(max_ki/100)*Drain
			Ki-=Drain
			if(Ki<=0) Buff_Disable(B)
			sleep(10)
		else break
	buff_drain_loop=0

mob/proc/buffed()
	if(current_buff&&current_buff.suffix&&current_buff.loc==src) return current_buff
	for(var/obj/Buff/B in src) if(B.suffix) return B //They have a buff active

mob/proc/buffed_with_bp()
	for(var/obj/Buff/B in src) if(B.suffix&&B.buff_bp>1) return 1 //they are using a bp increasing buff

obj/var
	Relearnable
	Reteachable

obj/Buff
	name="Custom Buff"
	hotbar_type="Buff"
	can_hotbar=1
	desc="This is a buff created by a player"
	teachable=1 //teachable
	Cost_To_Learn=25
	Skill=1
	Teach_Timer=10
	student_point_cost = 20
	Relearnable=1 //you can learn multiple copies of the obj/Buff type
	Reteachable=1 //you can teach multiple copies of the obj/Buff type
	Duplicates_Allowed=1

	New()
		if(!preset_buff) normalizeNexusCustomBuffStats()
		spawn if(src&&name!=initial(name))
			new/obj/Buff/verb/Buff(src,name)
			verbs-=/obj/Buff/verb/Buff

		spawn(50) if(src)
			if(!preset_buff && buff_bp>max_buff_bp)
				var/mob/m=loc
				if(m&&ismob(m)) m.revert_all_buffs()
				buff_bp=max_buff_bp
			//if(buff_str>2) buff_str=2
			//if(buff_for>2) buff_for=2
			//if(buff_spd>2) buff_spd=2

		spawn(2) if(src&&suffix)
			var/mob/m=loc
			if(m&&ismob(m)) m.current_buff=src

		spawn(10) if(!preset_buff && !custom_buffs_allowed) del(src)

		. = ..()

	Del()
		var/mob/M=loc
		if(ismob(M)) M.Buff_Disable(src)
		. = ..()

	var
		tmp/being_edited
		editable=1
		points=0
		buff_bp=1
		buff_ki=1
		buff_str=1
		buff_dur=1
		buff_spd=1
		buff_for=1
		buff_res=1
		buff_off=1
		buff_def=1
		buff_reg=1
		buff_rec=1
		trans_graphics //whether opening graphics for transforming are enabled or not for this buff
		list/graphics //a list containing segments of the opening graphics, chosen by the player
		last_trans=0 //as realtime. prevents spamming of trans graphics
		buff_hair
		buff_icon
		prebuff_icon
		buff_aura
		prebuff_aura
		list/buff_overlays=list("Cancel")
		list/buff_opening //the opening transformation graphics customizable by the player
		list/buff_attributes=new
		preset_buff = FALSE
		preset_vfx_icon
		preset_vfx_color = "#ffffff"
		preset_vfx_sound

	verb/Hotbar_use()
		set hidden=1
		if(being_edited) return
		if(!suffix) usr.Buff_Enable(src)
		else usr.Buff_Disable(src)

	verb/Buff()
		set category="Skills"
		if(being_edited) return
		if(!suffix) usr.Buff_Enable(src)
		else usr.Buff_Disable(src)

	verb/Buff_Options()
		set category="Other"
		if(!editable)
			usr << "[src] is a fixed combat style and cannot be customized."
			return
		if(being_edited) return
		being_edited=1

		if(name == initial(name))
			for(var/V in verbs) if(V==/obj/Buff/verb/Buff) verbs-=V
			var/newname = input("You must name this buff before you can edit it further. This will be the name of the command to use it too. Example: Battle Mode","Options",name) as text
			if(newname && newname != "") name = newname
			new/obj/Buff/verb/Buff(src,name)
			verbs-=/obj/Buff/verb/Buff

		while(src&&usr)
			var/list/L=list("Cancel","Modify buff stat changes","Modify buff attributes")
			if(trans_graphics) L+="Disable graphical transformation"
			else L+="Enable graphical transformation"
			L+="Set name and description"
			if(buff_hair) L+="Reset buff hair"
			else L+="Choose buff hair"
			if(buff_icon) L+="Reset buff icon"
			else L+="Choose buff icon"
			if(buff_aura) L+="Reset buff aura"
			else L+="Choose buff aura"
			L+="Add buff overlay"
			if(buff_overlays.len>1) L+="Remove buff overlay"
			L+="Create opening transformation graphics"
			if(buff_opening&&buff_opening.len>0) L+="Remove opening transformation graphic"
			switch(input("What do you want to do to this buff?") in L)
				if("Cancel") break

				if("Modify buff stat changes")
					usr.Buff_Disable(src) //revert the buff before allowing edits
					being_edited=1
					winshow(usr,"buffstats",1)
					usr.Refresh_Buff_Window(src)
					while(src&&usr&&usr.client&&(winget(usr,"buffstats","is-visible")=="true")) sleep(1)
					if(usr&&usr.client) usr.buff_done()

				if("Modify buff attributes")
					while(src&&usr)
						switch(input("add or remove an attribute from this buff?") in list("cancel","add","remove",\
						"view guide"))
							if("cancel") break

							if("view guide") usr<<browse(buff_attribute_guide,"window=buff;size=700x600")

							if("add")
								var/list/addables=list("cancel")
								for(var/v in usr.known_buff_attributes) addables+=v
								for(var/v in buff_attributes) addables-=v
								if(addables.len==1) usr<<"You do not know any buff attributes to add to this"
								var/to_add=input("which buff attribute do you want added to this buff?") in addables
								if(to_add&&to_add!="cancel")
									buff_attributes+=to_add
									usr<<"[to_add] attribute added to [name]"

							if("remove")
								var/list/removables=list("cancel")
								for(var/v in buff_attributes) removables+=v
								if(removables.len==1) usr<<"There are no attributes on this buff to remove"
								var/to_remove=input("which attribute to remove?") in removables
								if(to_remove&&to_remove!="cancel")
									buff_attributes-=to_remove
									usr<<"[to_remove] attribute removed from [name]"

				if("Disable graphical transformation") trans_graphics=0

				if("Enable graphical transformation") trans_graphics=1

				if("Set name and description")
					for(var/V in verbs) if(V==/obj/Buff/verb/Buff) verbs-=V
					var/T=input("Name the buff","Options",name) as text
					if(T&&T!="") name=T
					T=input("Give it a description for Examine","Options",desc) as text
					desc=T
					new/obj/Buff/verb/Buff(src,name)
					verbs-=/obj/Buff/verb/Buff

				if("Reset buff icon") buff_icon=null

				if("Reset buff hair") buff_hair=null

				if("Reset buff aura") buff_aura=null

				if("Choose buff icon")
					if(!usr.beginNexusLegacyUploadPrompt())
						usr << "Finish the active file prompt before choosing a buff icon."
						being_edited = 0
						return
					var/icon/I=input(usr, "Choose the icon that you buff will change you to") as icon|null
					usr.endNexusLegacyUploadPrompt()

					if(findtext("[I]",".jpg") || findtext("[I]",".jpeg"))
						alert("jpegs are not allowed until BYOND fixes the crashing bug that occurs from jpegs now in BYOND v510")
						return

					if(!IconTooBig(I)) buff_icon=I

				if("Choose buff hair")
					if(!usr.beginNexusLegacyUploadPrompt())
						usr << "Finish the active file prompt before choosing buff hair."
						being_edited = 0
						return
					var/icon/I=input(usr, "Choose the hair icon that your buff will change you to") as icon|null
					usr.endNexusLegacyUploadPrompt()
					if(!IconTooBig(I)) buff_hair=I

				if("Choose buff aura")
					if(!usr.beginNexusLegacyUploadPrompt())
						usr << "Finish the active file prompt before choosing a buff aura."
						being_edited = 0
						return
					var/icon/I=input(usr, "Choose the aura your buff will have when powering up") as icon|null
					usr.endNexusLegacyUploadPrompt()
					if(!IconTooBig(I)) buff_aura=I

				if("Add buff overlay")
					if(!usr.beginNexusLegacyUploadPrompt())
						usr << "Finish the active file prompt before choosing a buff overlay."
						being_edited = 0
						return
					var/icon/I=input(usr, "Choose the overlay the buff will add to you") as icon|null
					usr.endNexusLegacyUploadPrompt()

					if(findtext("[I]",".jpg") || findtext("[I]",".jpeg"))
						alert("jpegs are not allowed until BYOND fixes the crashing bug that occurs from jpegs now in BYOND v510")
						return

					if(!IconTooBig(I)) buff_overlays+=I

				if("Remove buff overlay")
					var/V=input("Choose an overlay to remove from the buff") in buff_overlays
					if(V!="Cancel") buff_overlays-=V

				if("Create opening transformation graphics")
					buff_opening=usr.Add_Trans_Effects(buff_opening)
					last_trans=0

				if("Remove opening transformation graphic")
					buff_opening=usr.Remove_Trans_Effects(buff_opening)
					last_trans=0
		being_edited=0

mob/var/tmp/obj/Buff/current_buff
mob/proc
	Buffless_recovery()
		if(!current_buff||current_buff.buff_rec<=1) return recov
		return recov/current_buff.buff_rec

	BufflessKiMod()
		if(!current_buff||current_buff.buff_ki<=1) return Eff
		return Eff/current_buff.buff_ki

	revert_all_buffs() for(var/obj/Buff/b in src) Buff_Disable(b)

	Buff_Enable(obj/Buff/O) if(!O.being_edited&&!Redoing_Stats)

		if(rebuff_timer)
			src<<"You can not buff again for another [rebuff_timer] seconds (buff cooldown)"
			return
		/*for(var/obj/God_Fist/k in src) if(k.Using)
			src<<"Buffs can not be combined with God_Fist"
			return*/
		if(limit_breaker_on)
			src<<"Buffs can not be combined with Limit breaker"
			return

		if("transformation" in O.buff_attributes) preparePrimaryTransformation("alien_transform")
		for(var/obj/Buff/B in src) Buff_Disable(B)
		O.suffix="Active"
		if(O.trans_graphics&&world.realtime-O.last_trans>2*600) spawn if(src)
			Trans_Graphics(O.buff_opening)
			for(var/obj/Buff/B in src) B.last_trans=world.realtime

		if(O.buff_icon)
			O.prebuff_icon=icon
			icon=O.buff_icon
		if(O.buff_hair)
			overlays.Remove(hair,ssjhair,ussjhair,ssjfphair,ssj2hair,ssj3hair,ssj4hair, ssj_blue_hair)
			overlays+=O.buff_hair
		if(O.buff_aura&&Auras)
			O.prebuff_aura=Auras.icon
			Auras.icon=O.buff_aura
		for(var/V in O.buff_overlays) if(V!="Cancel") overlays+=V

		for(var/v in O.buff_attributes)
			active_buff_attributes-=v
			active_buff_attributes+=v
			switch(v)
				if("transformation")
					buff_transform_bp=Avg_Base*bp_mod
					if(buff_transform_bp>(base_bp+hbtc_bp)*4) buff_transform_bp=(base_bp+hbtc_bp)*4
					if(buff_transform_bp<(base_bp+hbtc_bp)*0.25) buff_transform_bp=(base_bp+hbtc_bp)*0.25

		Buff_Drain_Loop()
		buff_transform_drain()

		bp_mult+=O.buff_bp-1
		Ki*=O.buff_ki
		max_ki*=O.buff_ki
		Eff*=O.buff_ki
		Str*=O.buff_str
		strmod*=O.buff_str
		End*=O.buff_dur
		endmod*=O.buff_dur
		Spd*=O.buff_spd
		spdmod*=O.buff_spd
		Pow*=O.buff_for
		formod*=O.buff_for
		Res*=O.buff_res
		resmod*=O.buff_res
		Off*=O.buff_off
		offmod*=O.buff_off
		Def*=O.buff_def
		defmod*=O.buff_def
		regen*=O.buff_reg
		recov*=O.buff_rec

		current_buff=O
		if(!rebuff_timer) Rebuff_timer_countdown()
		rebuff_timer = 2
		playPresetBuffVfx(O, TRUE)
		src << "<font color=cyan>You have activated [O]"
		if(O.name == initial(O.name)) src << "<font color=cyan>But it appears you have not set it up yet. To customize a custom buff use the Buff Options \
		command found in the Other tab"
		if("transformation" in O.buff_attributes) syncActivePrimaryTransformation("custom transformation")


	Rebuff_timer_countdown()
		set waitfor=0
		sleep(1) //necessary
		while(src)
			if(!rebuff_timer) return
			rebuff_timer--
			if(!rebuff_timer) break
			else sleep(10)

	Buff_Disable(obj/Buff/O) if(O&&O.suffix)
		var/was_transformation = ("transformation" in O.buff_attributes)
		O.suffix=null

		if(O.buff_hair)
			overlays-=O.buff_hair
			SSj_Hair()
		if(O.buff_icon) icon=O.prebuff_icon
		if(O.buff_aura&&Auras) Auras.icon=O.prebuff_aura
		for(var/V in O.buff_overlays) if(V!="Cancel") overlays-=V

		for(var/v in O.buff_attributes)
			active_buff_attributes-=v
			switch(v)
				if("transformation")
					buff_transform_bp=0

		bp_mult-=O.buff_bp-1
		Ki/=O.buff_ki
		max_ki/=O.buff_ki
		Eff/=O.buff_ki
		Str/=O.buff_str
		strmod/=O.buff_str
		End/=O.buff_dur
		endmod/=O.buff_dur
		Spd/=O.buff_spd
		spdmod/=O.buff_spd
		Pow/=O.buff_for
		formod/=O.buff_for
		Res/=O.buff_res
		resmod/=O.buff_res
		Off/=O.buff_off
		offmod/=O.buff_off
		Def/=O.buff_def
		defmod/=O.buff_def
		regen/=O.buff_reg
		recov/=O.buff_rec

		playPresetBuffVfx(O, FALSE)
		src << "<font color=[rgb(0,255,0)]>You have deactivated [O]"

		current_buff=null
		if(was_transformation) syncActivePrimaryTransformation("custom transformation revert")

obj/Buff/Focus
	name = "Focus"
	desc = "A sustained Nexus focus: moderate power, speed, regeneration, and recovery at a continuous energy cost."
	editable = FALSE
	preset_buff = TRUE
	Duplicates_Allowed = FALSE
	buff_bp = 1.18
	buff_spd = 1.2
	buff_reg = 1.15
	buff_rec = 1.1
	preset_vfx_icon = 'src/Icons/VFX/CircleWind.dmi'
	preset_vfx_color = "#65d8ff"
	preset_vfx_sound = 'src/Sound/SoundEffects/Combat/Aura.ogg'

obj/Effect/ProgressionBuffBurst
	name = "combat aura"
	mouse_opacity = 0
	density = 0
	Grabbable = 0
	Savable = 0
	plane = 10
	layer = 100

	proc/configure(effect_icon, effect_color, activating = TRUE)
		if(effect_icon) icon = effect_icon
		if(effect_color) color = effect_color
		alpha = activating ? 230 : 150
		CenterIcon(src)
		var/matrix/start_matrix = matrix()
		start_matrix.Scale(activating ? 0.65 : 1.15)
		transform = start_matrix
		var/matrix/end_matrix = matrix()
		end_matrix.Scale(activating ? 1.55 : 0.75)
		animate(src, transform = end_matrix, alpha = 0, time = activating ? 10 : 6, easing = CUBIC_EASING)
		spawn(12) if(src) del(src)

mob/proc/playPresetBuffVfx(obj/Buff/buff, activating = TRUE)
	if(!buff || !buff.preset_buff) return
	if(buff.preset_vfx_sound && activating) player_view(12, src) << sound(buff.preset_vfx_sound, volume = 35)
	if(loc && buff.preset_vfx_icon)
		var/obj/Effect/ProgressionBuffBurst/burst = new(base_loc())
		burst.configure(buff.preset_vfx_icon, buff.preset_vfx_color, activating)
	if(activating) showNexusTechniqueAnnouncement("[buff]", buff.preset_vfx_color, null, 30)

obj/Buff/Preset
	editable = FALSE
	preset_buff = TRUE
	Reteachable = FALSE
	Relearnable = FALSE
	Duplicates_Allowed = FALSE
	Cost_To_Learn = 0

	MuscleForce
		name = "Muscle Force"
		desc = "A grounded physical style that reinforces strength and durability."
		buff_bp = 1.1
		buff_str = 1.2
		buff_dur = 1.12
		preset_vfx_icon = 'src/Icons/VFX/PressurePunch.dmi'
		preset_vfx_color = "#ffb24f"
		preset_vfx_sound = 'src/Sound/SoundEffects/Combat/Strongpunch.ogg'

	CombatMathematics
		name = "Combat Mathematics"
		desc = "Predictive calculations improve accuracy, reflex and measured movement."
		buff_spd = 1.08
		buff_off = 1.25
		buff_def = 1.25
		preset_vfx_icon = 'src/Icons/VFX/VfxElec.dmi'
		preset_vfx_color = "#61e8ff"
		preset_vfx_sound = 'src/Sound/SoundEffects/Combat/Scouterbeeps.ogg'

	KiBlade
		name = "Ki Blade"
		desc = "Condenses energy around close-range attacks, balancing strength, force and accuracy."
		buff_str = 1.12
		buff_for = 1.2
		buff_off = 1.12
		preset_vfx_icon = 'src/Icons/Ki/Blasts/BlastDestructoDisk.dmi'
		preset_vfx_color = "#a7fff0"
		preset_vfx_sound = 'src/Sound/SoundEffects/Combat/DestructodiscCharge.ogg'

	MagicForce
		name = "Magic Force"
		desc = "Arcane circulation improves force, resistance and recovery."
		buff_for = 1.25
		buff_res = 1.15
		buff_rec = 1.12
		preset_vfx_icon = 'src/Icons/Effects/GivePowerEffectWhite.dmi'
		preset_vfx_color = "#ca87ff"
		preset_vfx_sound = 'src/Sound/SoundEffects/Wisp.ogg'

	OffensiveStance
		name = "Offensive Stance"
		desc = "A committed attacking posture that trades defense for strength and accuracy."
		buff_str = 1.12
		buff_off = 1.22
		buff_def = 0.9
		preset_vfx_icon = 'src/Icons/NexusIntegrated/Attacks/Effects/RTImpactHeavy.dmi'
		preset_vfx_color = "#ff6d55"
		preset_vfx_sound = 'src/Sound/SoundEffects/Combat/Mediumpunch.ogg'

	DefensiveStance
		name = "Defensive Stance"
		desc = "A guarded posture that trades offense for durability and reflex."
		buff_dur = 1.15
		buff_off = 0.9
		buff_def = 1.25
		preset_vfx_icon = 'src/Icons/Ki/Shield/ShieldBlue.dmi'
		preset_vfx_color = "#74a7ff"
		preset_vfx_sound = 'src/Sound/SoundEffects/Combat/Reflect.ogg'

	BleedingEdge
		name = "Bleeding Edge"
		desc = "A dangerous speed style that sharpens strength and accuracy at a durability cost."
		buff_str = 1.18
		buff_dur = 0.9
		buff_spd = 1.15
		buff_off = 1.15
		preset_vfx_icon = 'src/Icons/Effects/NewBloodSplatters/BloodSpray.dmi'
		preset_vfx_color = "#ff304f"
		preset_vfx_sound = 'src/Sound/SoundEffects/Combat/Weapons/SwordImpact4.ogg'

	BurningFist
		name = "Burning Fist"
		desc = "Ignites a relentless close-range rhythm that favors strength and offense."
		buff_bp = 1.1
		buff_str = 1.22
		buff_off = 1.18
		preset_vfx_icon = 'src/Icons/VFX/FlamingFists.dmi'
		preset_vfx_color = "#ff7a31"
		preset_vfx_sound = 'src/Sound/SoundEffects/FogoNaMao.mp3'

	KiFist
		name = "Ki Fist"
		desc = "Channels force through unarmed strikes and reinforces their accuracy."
		buff_str = 1.12
		buff_for = 1.22
		buff_off = 1.12
		preset_vfx_icon = 'src/Icons/VFX/SaiyanPower.dmi'
		preset_vfx_color = "#ffe75e"
		preset_vfx_sound = 'src/Sound/SoundEffects/Combat/Powerup.wav'

	DemonicFury
		name = "Demonic Fury"
		desc = "A ferocious style with high power, strength and regeneration but reduced reflex."
		buff_bp = 1.2
		buff_str = 1.15
		buff_def = 0.9
		buff_reg = 1.18
		preset_vfx_icon = 'src/Icons/Ki/Auras/BlackDemonflame.dmi'
		preset_vfx_color = "#b04cff"
		preset_vfx_sound = 'src/Sound/SoundEffects/HellVoice.ogg'

	AngelicGrace
		name = "Angelic Grace"
		desc = "A serene high-mobility style that improves speed, reflex and recovery."
		buff_bp = 1.1
		buff_spd = 1.2
		buff_def = 1.2
		buff_rec = 1.2
		preset_vfx_icon = 'src/Icons/Effects/GivePowerEffectWhite.dmi'
		preset_vfx_color = "#e8f6ff"
		preset_vfx_sound = 'src/Sound/SoundEffects/WishSfx1.ogg'

	Channel
		name = "Channel"
		desc = "Sacrifices movement to expand energy, force and recovery for sustained casting."
		buff_ki = 1.3
		buff_spd = 0.85
		buff_for = 1.2
		buff_rec = 1.2
		preset_vfx_icon = 'src/Icons/Ki/BlastCharging/Charge1.dmi'
		preset_vfx_color = "#70d8ff"
		preset_vfx_sound = 'src/Sound/SoundEffects/Combat/BasicbeamCharge.ogg'

obj/Buff/Ultimate
	editable = FALSE
	preset_buff = TRUE
	teachable = FALSE
	Reteachable = FALSE
	Relearnable = FALSE
	Duplicates_Allowed = FALSE
	Cost_To_Learn = 0

	HighTension
		name = "High Tension"
		desc = "An Ultimate Buff favoring raw power and durability."
		buff_bp = 1.22
		buff_str = 1.25
		buff_dur = 1.15
		preset_vfx_icon = 'src/Icons/VFX/PressurePunch.dmi'
		preset_vfx_color = "#ffb236"
		preset_vfx_sound = 'src/Sound/SoundEffects/Combat/SSJ3Powerup.ogg'

	Godspeed
		name = "Godspeed"
		desc = "An Ultimate Buff favoring extreme movement, accuracy, and reflex."
		buff_bp = 1.15
		buff_spd = 1.35
		buff_off = 1.15
		buff_def = 1.15
		preset_vfx_icon = 'src/Icons/VFX/VfxElec.dmi'
		preset_vfx_color = "#70e8ff"
		preset_vfx_sound = 'src/Sound/SoundEffects/Combat/Teleport.ogg'

	FistsOfFury
		name = "Fists of Fury"
		desc = "An Ultimate Buff favoring strength and relentless offense."
		buff_bp = 1.18
		buff_str = 1.15
		buff_off = 1.3
		preset_vfx_icon = 'src/Icons/VFX/FlamingFists.dmi'
		preset_vfx_color = "#ff493c"
		preset_vfx_sound = 'src/Sound/SoundEffects/Combat/Strongpunch.ogg'

	ArcanePower
		name = "Arcane Power"
		desc = "An Ultimate Buff favoring energy capacity, force, and recovery."
		buff_bp = 1.18
		buff_ki = 1.35
		buff_for = 1.3
		buff_rec = 1.15
		preset_vfx_icon = 'src/Icons/Effects/GivePowerEffectWhite.dmi'
		preset_vfx_color = "#c171ff"
		preset_vfx_sound = 'src/Sound/SoundEffects/Wisp.ogg'

	BestialWrath
		name = "Bestial Wrath"
		desc = "An Ultimate Buff favoring ferocity, strength, and regeneration."
		buff_bp = 1.28
		buff_str = 1.2
		buff_reg = 1.25
		preset_vfx_icon = 'src/Icons/Ki/Auras/BlackDemonflame.dmi'
		preset_vfx_color = "#e34537"
		preset_vfx_sound = 'src/Sound/SoundEffects/Roar.wav'

	Bushido
		name = "Bushido"
		desc = "An Ultimate Buff favoring balanced weapon combat and precision."
		buff_bp = 1.2
		buff_spd = 1.15
		buff_off = 1.2
		buff_def = 1.2
		preset_vfx_icon = 'src/Icons/NexusIntegrated/Attacks/Effects/RTSlashArc.dmi'
		preset_vfx_color = "#d8f3ff"
		preset_vfx_sound = 'src/Sound/SoundEffects/Combat/Weapons/SwordSwingHeavy1.ogg'

mob/Admin4/verb/testNexusBuffs(mob/character in players)
	set name = "Test Nexus Buffs"
	set category = "Admin"
	var/list/buff_types = list(
		/obj/Buff/Focus,
		/obj/Buff/Preset/MuscleForce,
		/obj/Buff/Preset/CombatMathematics,
		/obj/Buff/Preset/MagicForce,
		/obj/Buff/Preset/OffensiveStance,
		/obj/Buff/Preset/DefensiveStance,
		/obj/Buff/Preset/BleedingEdge,
		/obj/Buff/Preset/BurningFist,
		/obj/Buff/Preset/DemonicFury,
		/obj/Buff/Preset/AngelicGrace,
		/obj/Buff/Preset/Channel,
		/obj/Buff/Ultimate/HighTension,
		/obj/Buff/Ultimate/Godspeed,
		/obj/Buff/Ultimate/FistsOfFury,
		/obj/Buff/Ultimate/ArcanePower,
		/obj/Buff/Ultimate/BestialWrath,
		/obj/Buff/Ultimate/Bushido)
	for(var/buff_type in buff_types)
		if(!(locate(buff_type) in character)) character.contents += new buff_type(character)
	for(var/ki_weapon_type in list(/obj/KiWeaponTechnique/KiFist, /obj/KiWeaponTechnique/KiSword, /obj/KiWeaponTechnique/KiHammer, /obj/KiWeaponTechnique/SpiritSword))
		if(!(locate(ki_weapon_type) in character)) character.contents += new ki_weapon_type(character)
	src << "[character] received every integrated Nexus preset and Ultimate Buff for testing."

obj/Buff/proc/normalizeNexusCustomBuffStats()
	if(preset_buff) return
	var/bp_maximum = 1
	if(nexusIsFiniteNumber(max_buff_bp)) bp_maximum = Clamp(max_buff_bp, 0.7, 10)
	buff_bp = nexusIsFiniteNumber(buff_bp) ? Clamp(round(buff_bp * 10) / 10, 0.7, bp_maximum) : 1
	buff_ki = nexusIsFiniteNumber(buff_ki) ? Clamp(round(buff_ki * 10) / 10, 0.7, 1.5) : 1
	buff_str = nexusIsFiniteNumber(buff_str) ? Clamp(round(buff_str * 10) / 10, 0.7, 2) : 1
	buff_dur = nexusIsFiniteNumber(buff_dur) ? Clamp(round(buff_dur * 10) / 10, 0.7, 2) : 1
	buff_spd = nexusIsFiniteNumber(buff_spd) ? Clamp(round(buff_spd * 10) / 10, 0.7, 2) : 1
	buff_for = nexusIsFiniteNumber(buff_for) ? Clamp(round(buff_for * 10) / 10, 0.7, 2) : 1
	buff_res = nexusIsFiniteNumber(buff_res) ? Clamp(round(buff_res * 10) / 10, 0.7, 2) : 1
	buff_off = nexusIsFiniteNumber(buff_off) ? Clamp(round(buff_off * 10) / 10, 0.7, 2) : 1
	buff_def = nexusIsFiniteNumber(buff_def) ? Clamp(round(buff_def * 10) / 10, 0.7, 2) : 1
	buff_reg = nexusIsFiniteNumber(buff_reg) ? Clamp(round(buff_reg * 10) / 10, 1, 1.3) : 1
	buff_rec = nexusIsFiniteNumber(buff_rec) ? Clamp(round(buff_rec * 10) / 10, 1, 1.3) : 1
	points = nexusIsFiniteNumber(points) ? Clamp(round(points), 0, NEXUS_CUSTOM_BUFF_POINT_CAP) : 0

obj/Buff/proc/adjustNexusCustomBuffStat(buff_stat, direction)
	if(preset_buff || !editable || !(direction in list(-1, 1))) return FALSE
	var/list/allowed_stats = list("buff_bp", "buff_ki", "buff_str", "buff_dur", "buff_spd", "buff_for", "buff_res", "buff_off", "buff_def", "buff_reg", "buff_rec")
	if(!(buff_stat in allowed_stats)) return FALSE
	normalizeNexusCustomBuffStats()

	var/current_value
	var/stat_minimum = 0.7
	var/stat_maximum = 2
	switch(buff_stat)
		if("buff_bp")
			current_value = buff_bp
			stat_maximum = nexusIsFiniteNumber(max_buff_bp) ? Clamp(max_buff_bp, 0.7, 10) : 1
		if("buff_ki")
			current_value = buff_ki
			stat_maximum = 1.5
		if("buff_str") current_value = buff_str
		if("buff_dur") current_value = buff_dur
		if("buff_spd") current_value = buff_spd
		if("buff_for") current_value = buff_for
		if("buff_res") current_value = buff_res
		if("buff_off") current_value = buff_off
		if("buff_def") current_value = buff_def
		if("buff_reg")
			current_value = buff_reg
			stat_minimum = 1
			stat_maximum = 1.3
		if("buff_rec")
			current_value = buff_rec
			stat_minimum = 1
			stat_maximum = 1.3

	var/new_value = (round(current_value * 10) + direction) / 10
	var/new_points = points - direction
	if(new_value < stat_minimum || new_value > stat_maximum) return FALSE
	if(new_points < 0 || new_points > NEXUS_CUSTOM_BUFF_POINT_CAP) return FALSE

	switch(buff_stat)
		if("buff_bp") buff_bp = new_value
		if("buff_ki") buff_ki = new_value
		if("buff_str") buff_str = new_value
		if("buff_dur") buff_dur = new_value
		if("buff_spd") buff_spd = new_value
		if("buff_for") buff_for = new_value
		if("buff_res") buff_res = new_value
		if("buff_off") buff_off = new_value
		if("buff_def") buff_def = new_value
		if("buff_reg") buff_reg = new_value
		if("buff_rec") buff_rec = new_value
	points = new_points
	return TRUE

mob/verb/buff_point(posneg as text, buff_stat as text) //posneg = "-1" | "1". verb called thru skin
	set name = ".buff_point"
	set hidden = 1

	if(usr != src || !client || !playerCharacter) return
	var/obj/Buff/B
	for(B in src) if(B.being_edited) break
	if(!B)
		buff_done()
		return
	if(!(winget(src,"buffstats","is-visible") == "true")) return
	posneg = text2num(posneg)
	if(B.adjustNexusCustomBuffStat("[buff_stat]", posneg)) Refresh_Buff_Window(B)

mob/verb/buff_done() //verb called thru skin
	set name=".buff_done"
	set hidden=1
	winshow(src,"buffstats",0)
	for(var/obj/Buff/B in src) B.being_edited=0

mob/proc/Refresh_Buff_Window(obj/Buff/B) if(client)
	winset(src,"buffstats.BPmult","text=[B.buff_bp]")
	winset(src,"buffstats.Efficiency","text=[B.buff_ki]")
	winset(src,"buffstats.Strength","text=[B.buff_str]")
	winset(src,"buffstats.Endurance","text=[B.buff_dur]")
	winset(src,"buffstats.Speed","text=[B.buff_spd]")
	winset(src,"buffstats.Force","text=[B.buff_for]")
	winset(src,"buffstats.Resistance","text=[B.buff_res]")
	winset(src,"buffstats.Offense","text=[B.buff_off]")
	winset(src,"buffstats.Defense","text=[B.buff_def]")
	winset(src,"buffstats.Regeneration","text=[B.buff_reg]")
	winset(src,"buffstats.Recovery","text=[B.buff_rec]")
	winset(src,"buffstats.points","text=[B.points]")

mob/proc
	Trans_Graphics(list/L) if(L) for(var/V in L)
		var/list/EA=L[V] //Effect Attributes
		var/I=EA["Icon"] //icon
		var/Timer=EA["Time"] //timer
		var/N=EA["Amount"] //amount of effects
		if(!N) N=1
		spawn for(var/O in 1 to N)
			switch(V)
				if("Shockwave")
					Make_Shockwave(src,7,I,sw_icon_size=256)
					sleep(rand(3,15))
				if("Shaking")
					for(var/mob/M in player_view(20,src)) if(M.client) M.ScreenShake()
					sleep(rand(3,15))
				if("Damaged Ground")
					for(var/turf/T in TurfCircle(EA["Range"],src))
						T.Make_Damaged_Ground(1)
						if(prob(25)) sleep(1)
					sleep(rand(5,15))
				if("Dust")
					var/turf/t = base_loc()
					if(t)
						Dust(t, end_size = 1, time = 35)
					sleep(rand(5,15))
				if("Explosions")
					var/list/Temp=new
					for(var/turf/T in view(10,src)) Temp+=T
					if(Temp.len)
						var/turf/Turf=pick(Temp)
						if(isturf(Turf)) Explosion_Graphics(Turf,rand(1,5))
					sleep(rand(10,30))
				if("Big Crater")
					BigCrater(loc)
					sleep(20)
				if("Little Craters")
					var/list/Temp=new
					for(var/turf/T in view(6,src)) Temp+=T
					if(Temp.len != 0)
						var/turf/Turf = pick(Temp)
						if(isturf(Turf)) Small_crater(Turf)
					sleep(5)
				if("Lightning")
					var/obj/Lightning_Strike/LS=Get_lightning_strike()
					LS.SafeTeleport(loc)
					LS.y+=12
					LS.x+=rand(-10,10)
					if(LS&&I)
						LS.icon=I
						LS.overlays-=LS.overlays
					sleep(rand(0,10))
		sleep(Timer)
	Add_Trans_Effects(list/L)
		if(!L) L=new/list
		var/max_effects=5
		while(L.len>=max_effects)
			switch(alert(src,"Your transformation effects list exceeds the maximum amount of entries \
			([L.len] / [max_effects]). You must remove the excess entries before you can add more. \
			Remove entries now?","Options","Yes","No"))
				if("No") return L
				if("Yes") L=Remove_Trans_Effects(L)
		while(src)
			if(L.len>=max_effects) break
			else switch(input(src,"What effect do you want to add? They will be executed in the order chosen. \
			You can choose [max_effects-L.len] more entries") in list("Done","Shockwaves","Shaking",\
			"Damaged Ground","Dust","Explosions","Big Crater","Little Craters","Lightning"))
				if("Done") break
				if("Shockwaves")
					var/icon/I
					switch(alert(src,"Custom icon?","Options","Default","Custom"))
						if("Custom")
							if(!beginNexusLegacyUploadPrompt())
								src << "Finish the active file prompt before choosing a shockwave icon."
								return L
							I=input(src,"Choose an icon") as icon|null
							endNexusLegacyUploadPrompt()
							if(IconTooBig(I)) I=null
					var/T=input(src,"Enter the delay between this effect and the next in seconds. 0.1-10","Options"\
					,0.5) as num
					if(T<0.1) T=0.1
					if(T>10) T=10
					var/N=input(src,"Enter amount of effects before effect finishes. 1-10","Options",3) as num
					if(N<1) N=1
					if(N>10) N=10
					L["Shockwave"]=list("Icon"=I,"Time"=T*10,"Amount"=round(N))
				if("Shaking")
					var/T=input(src,"Enter the delay between this effect and the next in seconds. 0.1-10","Options"\
					,0.5) as num
					if(T<0.1) T=0.1
					if(T>10) T=10
					var/N=input(src,"Enter amount of this effects before effect finishes. 1-10","Options",3) as num
					if(N<1) N=1
					if(N>10) N=10
					L["Shaking"]=list("Time"=T*10,"Amount"=round(N))
				if("Damaged Ground")
					var/T=input(src,"Enter the delay between this effect and the next in seconds. 0.1-10","Options"\
					,0.5) as num
					if(T<0.1) T=0.1
					if(T>10) T=10
					var/N=input(src,"Enter the range of this effect. 1-10","Options",3) as num
					if(N<1) N=1
					if(N>10) N=10
					L["Damaged Ground"]=list("Time"=T*10,"Range"=round(N))
				if("Dust")
					var/T=input(src,"Enter the delay between this effect and the next in seconds. 0.1-10","Options"\
					,0.5) as num
					if(T<0.1) T=0.1
					if(T>10) T=10
					L["Dust"]=list("Time"=T*10)
				if("Explosions")
					var/T=input(src,"Enter the delay between this effect and the next in seconds. 0.1-10","Options"\
					,0.5) as num
					if(T<0.1) T=0.1
					if(T>10) T=10
					var/N=input(src,"Enter amount of this effects before effect finishes. 1-5","Options",3) as num
					if(N<1) N=1
					if(N>5) N=5
					L["Explosions"]=list("Time"=T*10,"Amount"=round(N))
				if("Big Crater")
					var/T=input(src,"Enter the delay between this effect and the next in seconds. 0.1-10","Options"\
					,0.5) as num
					if(T<0.1) T=0.1
					if(T>10) T=10
					var/N=input(src,"Enter amount of this effects before effect finishes. 1-5","Options",1) as num
					if(N<1) N=1
					if(N>5) N=5
					L["Big Crater"]=list("Time"=T*10,"Amount"=round(N))
				if("Little Craters")
					var/T=input(src,"Enter the delay between this effect and the next in seconds. 0.1-10","Options"\
					,0.5) as num
					if(T<0.1) T=0.1
					if(T>10) T=10
					var/N=input(src,"Enter amount of this effects before effect finishes. 1-10","Options",5) as num
					if(N<1) N=1
					if(N>10) N=10
					L["Little Craters"]=list("Time"=T*10,"Amount"=round(N))
				if("Lightning")
					var/icon/I
					switch(alert(src,"Custom icon?","Options","Default","Custom"))
						if("Custom")
							if(!beginNexusLegacyUploadPrompt())
								src << "Finish the active file prompt before choosing a lightning icon."
								return L
							I=input(src,"Choose an icon") as icon|null
							endNexusLegacyUploadPrompt()
							if(IconTooBig(I)) I=null
					var/T=input(src,"Enter the delay between this effect and the next in seconds. 0.1-10","Options"\
					,0.5) as num
					if(T<0.1) T=0.1
					if(T>10) T=10
					var/N=input(src,"Enter amount of this effects before effect finishes. 1-20","Options",10) as num
					if(N<1) N=1
					if(N>20) N=20
					L["Lightning"]=list("Icon"=I,"Time"=T*10,"Amount"=round(N))
		return L
	Remove_Trans_Effects(list/L)
		if(!L||!L.len) alert(src,"There are no effects to remove")
		else while(src)
			var/list/Options=list("Done")
			for(var/V in L) Options+=V
			var/V=input(src,"Which effect do you want to remove?") in Options
			if(!V||V=="Done") break
			else L-=V
		return L
var/buff_attribute_guide={"<html><head><body><body bgcolor="#000000"><font size=5><font color="#CCCCCC">

Here are all the attributes and what they do:<ul>

<li>Transform: This attributes causes the buff to be like a transformation, for example, an alien
transformation. The buff will add some static bp on top of your normal bp. The amount it adds is based
on the average bp of the server. There will be energy drain.

<li>Giant: This has no stat effects but just causes you to grow into a giant.

<li>God_Fist: This attribute  will cause you to power up much faster than normal, but
instead of just your energy draining from powering up, your health drains as well. Speed increases.
Defense and regeneration decrease.

<li>Limit breaker: This attribute increases bp, regeneration, and recovery greatly. The downside is
that you could randomly get knocked out while using the buff.

</ul>

"}
