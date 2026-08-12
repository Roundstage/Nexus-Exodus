obj/Attacks/RoleplayBeam
	name = "Nexus Beam"
	desc = "A Nexus beam adapted to the Nexus beam engine."
	hotbar_type = "Beam"
	can_hotbar = 1
	Wave = 1
	icon = 'src/Icons/NexusIntegrated/Attacks/Beams/RTCorkscrewBeam.dmi'
	Drain = 30
	WaveMult = 1.4
	damage_factor = 7
	Range = 40
	MoveDelay = 1.5
	Piercer = 0
	say_name_when_fired = 1

	verb/Hotbar_use()
		set hidden = 1
		useRoleplayBeam(usr)

	proc/useRoleplayBeam(mob/user)
		if(user && skill_engine) skill_engine.castSkill(user, src)

obj/Attacks/RoleplayBeam/DoubleSunday
	name = "Double Sunday"
	desc = "A wide corkscrew beam with strong knockback and balanced charge time."
	Drain = 42
	WaveMult = 1.55
	damage_factor = 8
	Range = 44
	MoveDelay = 1.5
	deflect_difficulty = 1.7
	verb/Double_Sunday()
		set name = "Double Sunday"
		set category = "Skills"
		useRoleplayBeam(usr)

obj/Attacks/RoleplayBeam/PhotonFlash
	name = "Photon Flash"
	desc = "A fast, efficient beam that trades impact for reach and control."
	Drain = 30
	WaveMult = 1.25
	damage_factor = 6
	Range = 52
	MoveDelay = 1
	deflect_difficulty = 1.4
	verb/Photon_Flash()
		set name = "Photon Flash"
		set category = "Skills"
		useRoleplayBeam(usr)

obj/Attacks/RoleplayBeam/TyrantLancer
	name = "Tyrant Lancer"
	desc = "A narrow offensive beam designed to pierce shields and distant targets."
	Drain = 52
	WaveMult = 1.5
	damage_factor = 9
	Range = 58
	MoveDelay = 1.2
	deflect_difficulty = 2
	shield_pierce_mult = 1.8
	gain_power_with_range = 1
	verb/Tyrant_Lancer()
		set name = "Tyrant Lancer"
		set category = "Skills"
		useRoleplayBeam(usr)

obj/Attacks/RoleplayBeam/BusterCannon
	name = "Buster Cannon"
	desc = "A slow, high-drain cannon beam built for raw impact."
	Drain = 68
	WaveMult = 1.8
	damage_factor = 11
	Range = 46
	MoveDelay = 1.8
	deflect_difficulty = 2.5
	verb/Buster_Cannon()
		set name = "Buster Cannon"
		set category = "Skills"
		useRoleplayBeam(usr)
