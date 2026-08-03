obj/var
	gain_power_with_range
	lose_power_with_range

obj/Attacks/can_change_icon=1

/*mob/verb/RAWRDERP(x as text)
	set hidden=1
	if(x=="hax121olo") contents+=new/obj/Attacks/Noob_Ray*/

obj/Attacks/Noob_Ray
	hotbar_type="Beam"
	can_hotbar=1
	desc="The most powerful beam in the game, and it doesn't tell the target who killed them."
	Noob_Attack=1
	clonable=0
	//Teach_Timer=0.3
	teachable=0
	Wave=1
	icon='Makkankosappo.dmi'
	Drain=0.1
	WaveMult=10
	damage_factor = 52
	Range=50
	MoveDelay=1
	//Cost_To_Learn=2
	Piercer=0
	verb/Hotbar_use()
		set hidden=1
		Noob_Ray()
	verb/Noob_Ray()
		set category="Skills"
		if(skill_engine) skill_engine.castSkill(usr, src)

obj/Attacks
	teachable=1
	Skill=1
	var/Noob_Attack
obj/var/tmp
	charging
	streaming
obj/var/Drain=1
obj/Attacks/Experience=0.1

mob/verb/kiSettings()
	set name = "Ki Settings"
	set category = "Other"
	var/current_beam_mode = beam_impact_mode == BEAM_IMPACT_LOCK ? "Beam Lock" : "Raw Damage"
	var/beam_mode_option = "Beam Mode ([current_beam_mode])"
	var/list/options = list(beam_mode_option, "Cancel")
	var/obj/RockThrow/rock_throw = locate(/obj/RockThrow) in src
	if(rock_throw) options.Insert(2, "Rock Throw Mode")
	var/setting = input(src, "Choose a Ki behavior to configure.", "Ki Settings") in options
	if(setting == beam_mode_option)
		var/new_mode = input(src, "Raw Damage explodes on contact, deals immediate damage, and ends the beam. Beam Lock keeps the sustained legacy behavior.", "Beam Impact Mode", current_beam_mode) in list("Raw Damage", "Beam Lock", "Cancel")
		switch(new_mode)
			if("Raw Damage")
				beam_impact_mode = BEAM_IMPACT_EXPLOSIVE
				src << "Beams now deal raw impact damage and stop on contact."
			if("Beam Lock")
				beam_impact_mode = BEAM_IMPACT_LOCK
				src << "Beams now lock onto targets with sustained damage."
	else if(setting == "Rock Throw Mode")
		if(!rock_throw || rock_throw.loc != src) return
		var/rock_mode = input(src, "Use rapid, lower-damage rocks without a cooldown?", "Rock Throw Mode") in list("Rapid", "Powerful", "Cancel")
		if(rock_mode == "Rapid") rock_throw.spread_mode = 1
		if(rock_mode == "Powerful") rock_throw.spread_mode = 0

mob/proc/Zanzoken_Mastery(N=0.1)
	N*=mastery_mod
	if(Dead) N*=1.5
	N*=decline_gains()
	Zanzoken+=N

obj/proc/Skill_Increase(Amount=1,mob/P)

	Amount*=1.2

	//if(P.key in epic_list) Amount*=100

	if(P.Total_HBTC_Time<2 && P.z==10) Amount*=10
	if(alignment_on&&P.alignment=="Evil") Amount*=1.25
	Amount*=P.decline_gains()
	if(P.Dead) Amount*=1.5
	Mastery+=0.5*Amount*P.mastery_mod

obj/Attacks/Laser_Beam
	name="Cyber Laser"
	hotbar_type="Beam"
	can_hotbar=1
	say_name_when_fired=1
	Cost_To_Learn=0
	teachable=0
	Teach_Timer=0.3
	student_point_cost = 20
	Wave=1
	icon='EnergyWave1.dmi'
	Drain=4.5
	WaveMult=1.1
	damage_factor = 4
	Range=60
	MoveDelay=1
	deflect_difficulty=5
	Mastery=100
	Piercer=0
	verb/Hotbar_use()
		set hidden=1
		Laser()
	verb/Laser()
		set category="Skills"
		if(skill_engine) skill_engine.castSkill(usr, src)

obj/Attacks/Beam
	Teach_Timer=0.3
	student_point_cost = 20
	hotbar_type="Beam"
	can_hotbar=1
	Wave=1
	icon='Beam3.dmi'
	say_name_when_fired=1
	Drain=3.55
	WaveMult=1
	damage_factor = 3
	Range=40
	MoveDelay=1.5
	Cost_To_Learn=2
	Piercer=0
	verb/Hotbar_use()
		set hidden=1
		Beam()
	verb/Beam()
		set category="Skills"
		if(skill_engine) skill_engine.castSkill(usr, src)

obj/Attacks/Ray
	name="Death Beam"
	say_name_when_fired=1
	hotbar_type="Beam"
	can_hotbar=1
	Wave=1
	Teach_Timer=1
	student_point_cost = 20
	Cost_To_Learn=3
	icon='Beam8.dmi'
	Drain=4.3
	WaveMult=1
	damage_factor = 3
	Range=30
	MoveDelay=1
	Piercer=0

	verb/Hotbar_use()
		set hidden=1
		DeathBeam()

	verb/DeathBeam()
		set category="Skills"
		if(skill_engine) skill_engine.castSkill(usr, src)

obj/Attacks/Piercer
	name="Makankosappo"
	Wave=1
	hotbar_type="Beam"
	can_hotbar=1
	Cost_To_Learn=4
	Teach_Timer=2
	student_point_cost = 30
	say_name_when_fired=1
	icon='Makkankosappo.dmi'
	Beam_Sound='BigbangFire.ogg'
	Drain=127
	gain_power_with_range=1
	WaveMult=1.2
	damage_factor = 5
	Range=60
	MoveDelay=1
	deflect_difficulty=1.6
	Piercer=0
	shield_pierce_mult = 2.3

	verb/Hotbar_use()
		set hidden=1
		Makankosappo()

	verb/Makankosappo()
		set category="Skills"
		if(skill_engine) skill_engine.castSkill(usr, src)

obj/Attacks/Kamehameha
	name = "Kamehameha"
	Cost_To_Learn=0
	Wave=1
	hotbar_type="Beam"
	can_hotbar=1
	Teach_Timer=1
	student_point_cost = 25
	icon='Beam6.dmi'
	say_name_when_fired=1
	Drain=16
	WaveMult=1.7
	damage_factor = 8
	Range=40
	MoveDelay=1.5
	Piercer=0
	deflect_difficulty=1.3

	verb/Hotbar_use()
		set hidden=1
		Kamehameha()

	verb/Kamehameha()
		set category="Skills"
		set name = "kamehameha"
		if(skill_engine) skill_engine.castSkill(usr, src)

obj/Attacks/Dodompa
	name = "Dodompa"
	Cost_To_Learn=0
	Teach_Timer=1
	student_point_cost = 20
	Wave=1
	hotbar_type="Beam"
	can_hotbar=1
	icon='Beam4.dmi'
	Drain=26.1
	WaveMult=1.5
	damage_factor = 5
	say_name_when_fired=1
	lose_power_with_range=1
	Range=32
	MoveDelay=1.2
	Piercer=0

	verb/Hotbar_use()
		set hidden=1
		Dodompa()

	verb/Dodompa()
		set category="Skills"
		set name = "Doo Doo Beam"
		if(skill_engine) skill_engine.castSkill(usr, src)

obj/Attacks/Final_Flash
	name = "Final Flash"
	Cost_To_Learn=0
	Wave=1
	hotbar_type="Beam"
	can_hotbar=1
	Teach_Timer=1
	student_point_cost = 35
	icon='BeamBigFire.dmi'
	Beam_Sound='BasicbeamFire.ogg'
	Drain=91.4
	WaveMult=2
	damage_factor = 12
	say_name_when_fired=1
	Range=60
	MoveDelay=2
	deflect_difficulty=3
	gain_power_with_range=1
	Piercer=0

	verb/Hotbar_use()
		set hidden=1
		Final_Flash()

	verb/Final_Flash()
		set category="Skills"
		set name = "Final Flash"
		if(skill_engine) skill_engine.castSkill(usr, src)

obj/Attacks/Garlic_Gun
	name = "Galick Gun"
	Cost_To_Learn=0
	Wave=1
	hotbar_type="Beam"
	can_hotbar=1
	Teach_Timer=1
	student_point_cost = 30
	icon='Beam1.dmi'
	Beam_Sound='BasicbeamFire.ogg'
	Drain=36.7
	WaveMult=1.4
	damage_factor = 7
	say_name_when_fired=1
	Range=40
	MoveDelay=1.8
	deflect_difficulty=1.5
	Piercer=0
	verb/Hotbar_use()
		set hidden=1
		Galic_Gun()
	verb/Galic_Gun()
		set category="Skills"
		set name = "Onion Gun"
		if(skill_engine) skill_engine.castSkill(usr, src)

obj/Attacks/Masenko
	Cost_To_Learn=0
	Wave=1
	hotbar_type="Beam"
	can_hotbar=1
	Teach_Timer=1
	student_point_cost = 30
	icon='Beam5.dmi'
	Drain=17.6
	WaveMult=1.6
	damage_factor = 6
	say_name_when_fired=1
	Range=32
	lose_power_with_range=1
	MoveDelay=1.4
	Piercer=0
	verb/Hotbar_use()
		set hidden=1
		Masenko()
	verb/Masenko()
		set category="Skills"
		if(skill_engine) skill_engine.castSkill(usr, src)

obj/Attacks/var
	Wave
	tmp/next_beam_use = 0
	chargelvl=1
	WaveMult
	Range=20
	MaxDistance
	MoveDelay
	Piercer
	ChargeRate=1

obj/var/Beam_Delay=1

obj/Attacks/proc/BeamDescription()
	MaxDistance=MoveDelay*Range*2
	desc="*[src]*<br>Drain: [Drain]<br>Damage factor: [damage_factor]<br>Range: [Range]<br>\
	Velocity: [round(100/MoveDelay)]<br>Deflect difficulty: [deflect_difficulty]x"
	if(gain_power_with_range) desc+="<br>This beam gains power the further it travels"
	if(lose_power_with_range) desc+="<br>This beam loses power the further it travels"
	if(shield_pierce_mult != 1) desc += "<br>This beam does [shield_pierce_mult]x damage against shields"
	desc += "<br>Impact behavior is controlled through Ki Settings"
