obj/Attacks/Blast
	var
		roleplay_homing = FALSE
		roleplay_weapon_required = FALSE
		roleplay_projectile_speed = 44
		roleplay_projectile_distance = 47

obj/Attacks/Blast/RoleplayBlast
	name = "Roleplay Tenkaichi Blast"
	desc = "A Roleplay Tenkaichi projectile adapted to the Nexus projectile engine."
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Blasts/RTHomingBlast.dmi'
	repeat_macro = 0
	var
		self_cooldown_ticks = 50
		tmp/next_use = 0

	proc/useRoleplayBlast(mob/user)
		if(!user || !skill_engine) return FALSE
		if(roleplay_weapon_required && !user.using_sword())
			user << "You must equip a weapon before using [src]."
			return FALSE
		if(world.time < next_use)
			var/seconds_left = round((next_use - world.time) / 10, 0.1)
			user << "[src] will be ready in [seconds_left] seconds."
			return FALSE
		if(skill_engine.castSkill(user, src))
			next_use = world.time + self_cooldown_ticks
			return TRUE
		return FALSE

obj/Attacks/Blast/RoleplayBlast/MortarCharge
	name = "Mortar Charge"
	desc = "A heavy explosive shot that creates a violent impact and shrapnel-like shockwave."
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Blasts/RTMortarCharge.dmi'
	Drain = 30
	Explosive = 2
	Shockwave = 3
	blast_refire = 0.35
	self_cooldown_ticks = 90
	roleplay_projectile_speed = 34
	roleplay_projectile_distance = 55
	verb/Mortar_Charge()
		set name = "Mortar Charge"
		set category = "Skills"
		useRoleplayBlast(usr)

obj/Attacks/Blast/RoleplayBlast/ExplodingBolt
	name = "Exploding Bolt"
	desc = "A forged-weapon projectile that detonates on impact."
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Blasts/RTArrowCharge.dmi'
	Drain = 24
	Explosive = 2
	Shockwave = 2
	blast_refire = 0.4
	self_cooldown_ticks = 75
	roleplay_weapon_required = TRUE
	roleplay_projectile_speed = 48
	verb/Exploding_Bolt()
		set name = "Exploding Bolt"
		set category = "Skills"
		useRoleplayBlast(usr)

obj/Attacks/Blast/RoleplayBlast/HomingFinisher
	name = "Homing Finisher"
	desc = "Fire four low-damage projectiles that actively pursue the selected target."
	Drain = 7
	Blast_Count = 4
	Shockwave = 1
	blast_refire = 0.65
	self_cooldown_ticks = 85
	roleplay_homing = TRUE
	roleplay_projectile_speed = 38
	roleplay_projectile_distance = 70
	verb/Homing_Finisher()
		set name = "Homing Finisher"
		set category = "Skills"
		useRoleplayBlast(usr)

obj/Attacks/Blast/RoleplayBlast/HellzoneGrenade
	name = "Hellzone Grenade"
	desc = "Launch four pursuing blasts that explode in overlapping impact waves."
	Drain = 10
	Blast_Count = 4
	Explosive = 1
	Shockwave = 2
	blast_refire = 0.45
	self_cooldown_ticks = 135
	roleplay_homing = TRUE
	roleplay_projectile_speed = 34
	roleplay_projectile_distance = 80
	verb/Hellzone_Grenade()
		set name = "Hellzone Grenade"
		set category = "Skills"
		useRoleplayBlast(usr)

obj/Attacks/Blast/RoleplayBlast/BlasterMeteor
	name = "Blaster Meteor"
	desc = "A four-shot explosive homing barrage adapted from Roleplay Tenkaichi."
	Drain = 11
	Blast_Count = 4
	Explosive = 1
	Shockwave = 2
	blast_refire = 0.5
	self_cooldown_ticks = 125
	roleplay_homing = TRUE
	roleplay_projectile_speed = 42
	roleplay_projectile_distance = 75
	verb/Blaster_Meteor()
		set name = "Blaster Meteor"
		set category = "Skills"
		useRoleplayBlast(usr)

obj/Attacks/Blast/RoleplayBlast/KillDriver
	name = "Kill Driver"
	desc = "A short-range homing blast that stuns its target on impact."
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Blasts/RTKillDriver.dmi'
	Drain = 22
	Stun = 1
	blast_refire = 0.5
	self_cooldown_ticks = 95
	roleplay_homing = TRUE
	roleplay_projectile_speed = 48
	roleplay_projectile_distance = 35
	verb/Kill_Driver()
		set name = "Kill Driver"
		set category = "Skills"
		useRoleplayBlast(usr)

obj/Attacks/Blast/RoleplayBlast/IceArrow
	name = "Ice Arrow"
	desc = "A fast homing weapon projectile with a brief stunning impact."
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Blasts/RTQuincyArrow.dmi'
	Drain = 18
	Stun = 1
	blast_refire = 0.65
	self_cooldown_ticks = 75
	roleplay_homing = TRUE
	roleplay_weapon_required = TRUE
	roleplay_projectile_speed = 56
	roleplay_projectile_distance = 45
	verb/Ice_Arrow()
		set name = "Ice Arrow"
		set category = "Skills"
		useRoleplayBlast(usr)

obj/Attacks/Blast/RoleplayBlast/BlockTheSky
	name = "Block the Sky"
	desc = "Fire a spreading volley of weapon-generated energy arrows."
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Blasts/RTArrowBarrage.dmi'
	Drain = 6
	Blast_Count = 4
	Spread = 3
	blast_refire = 0.7
	self_cooldown_ticks = 90
	roleplay_weapon_required = TRUE
	roleplay_projectile_speed = 50
	roleplay_projectile_distance = 60
	verb/Block_The_Sky()
		set name = "Block the Sky"
		set category = "Skills"
		useRoleplayBlast(usr)

obj/Attacks/Blast/RoleplayBlast/EchoingSlash
	name = "Echoing Slash"
	desc = "Launch a cutting weapon shockwave that can bleed through its explosive impact."
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Blasts/RTEchoingSlash.dmi'
	Drain = 20
	Explosive = 1
	Shockwave = 2
	blast_refire = 0.5
	self_cooldown_ticks = 80
	roleplay_weapon_required = TRUE
	roleplay_projectile_speed = 50
	verb/Echoing_Slash()
		set name = "Echoing Slash"
		set category = "Skills"
		useRoleplayBlast(usr)

obj/Attacks/Blast/RoleplayBlast/SkyBreak
	name = "Sky Break"
	desc = "Break the sound barrier with a weapon and release a massive destructive slash."
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTBlackSlash.dmi'
	Drain = 42
	Explosive = 2
	Shockwave = 4
	blast_refire = 0.3
	self_cooldown_ticks = 145
	roleplay_weapon_required = TRUE
	roleplay_projectile_speed = 58
	roleplay_projectile_distance = 65
	verb/Sky_Break()
		set name = "Sky Break"
		set category = "Skills"
		useRoleplayBlast(usr)

obj/Attacks/Blast/RoleplayBlast/GuideBomb
	name = "Guide Bomb"
	desc = "A powerful guided bomb that actively follows the selected target and explodes on contact."
	Drain = 26
	Explosive = 1
	Shockwave = 2
	blast_refire = 0.45
	self_cooldown_ticks = 95
	roleplay_homing = TRUE
	roleplay_projectile_speed = 34
	roleplay_projectile_distance = 65
	verb/Guide_Bomb()
		set name = "Guide Bomb"
		set category = "Skills"
		useRoleplayBlast(usr)

obj/Attacks/Blast/RoleplayBlast/DragonNova
	name = "Dragon Nova"
	desc = "A giant, slow and highly explosive charged energy ball."
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Blasts/RTMortarCharge.dmi'
	Drain = 52
	Explosive = 3
	Shockwave = 4
	blast_refire = 0.25
	self_cooldown_ticks = 165
	roleplay_projectile_speed = 28
	roleplay_projectile_distance = 60
	verb/Dragon_Nova()
		set name = "Dragon Nova"
		set category = "Skills"
		useRoleplayBlast(usr)

obj/Attacks/Blast/RoleplayBlast/HyperTornado
	name = "Hyper Tornado"
	desc = "Release four delayed tornado projectiles that pursue the selected target."
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Effects/RTHyperTornado.dmi'
	Drain = 9
	Blast_Count = 4
	Shockwave = 2
	blast_refire = 0.55
	self_cooldown_ticks = 125
	roleplay_homing = TRUE
	roleplay_projectile_speed = 36
	roleplay_projectile_distance = 70
	verb/Hyper_Tornado()
		set name = "Hyper Tornado"
		set category = "Skills"
		useRoleplayBlast(usr)

obj/Attacks/Blast/RoleplayBlast/MegaBurst
	name = "Mega Burst"
	desc = "An enormous, draining single hit that is powerful but comparatively easy to dodge."
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Blasts/RTMegaBurst.dmi'
	Drain = 58
	Explosive = 2
	Shockwave = 4
	blast_refire = 0.25
	self_cooldown_ticks = 155
	roleplay_projectile_speed = 30
	roleplay_projectile_distance = 65
	verb/Mega_Burst()
		set name = "Mega Burst"
		set category = "Skills"
		useRoleplayBlast(usr)

obj/Attacks/Blast/RoleplayBlast/TriBeam
	name = "Tri-Beam"
	desc = "Fire three explosive high-power shots at the cost of severe energy drain."
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Blasts/RTMortarCharge.dmi'
	Drain = 18
	Blast_Count = 3
	Explosive = 2
	Shockwave = 3
	blast_refire = 0.35
	self_cooldown_ticks = 150
	roleplay_projectile_speed = 40
	roleplay_projectile_distance = 55
	verb/Tri_Beam()
		set name = "Tri-Beam"
		set category = "Skills"
		useRoleplayBlast(usr)

obj/Attacks/Blast/RoleplayBlast/ExplosiveDemonWave
	name = "Explosive Demon Wave"
	desc = "Release a short-range rain of accurate explosive demon blasts."
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Blasts/RTDemonWave.dmi'
	Drain = 10
	Blast_Count = 4
	Explosive = 1
	Spread = 2
	blast_refire = 0.55
	self_cooldown_ticks = 115
	roleplay_projectile_speed = 46
	roleplay_projectile_distance = 35
	verb/Explosive_Demon_Wave()
		set name = "Explosive Demon Wave"
		set category = "Skills"
		useRoleplayBlast(usr)

obj/Attacks/Blast/RoleplayBlast/SuperGhostKamikaze
	name = "Super Ghost Kamikaze Attack"
	desc = "Summon four explosive ghost projectiles that hunt the selected target."
	Drain = 12
	Blast_Count = 4
	Explosive = 2
	Shockwave = 2
	blast_refire = 0.45
	self_cooldown_ticks = 150
	roleplay_homing = TRUE
	roleplay_projectile_speed = 32
	roleplay_projectile_distance = 80
	verb/Super_Ghost_Kamikaze_Attack()
		set name = "Super Ghost Kamikaze Attack"
		set category = "Skills"
		useRoleplayBlast(usr)

obj/Attacks/Blast/RoleplayBlast/WallOfFlame
	name = "Wall of Flame"
	desc = "Create a four-shot spreading wall of stunning fire in front of the user."
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Blasts/RTWallOfFlame.dmi'
	Drain = 11
	Blast_Count = 4
	Explosive = 1
	Stun = 1
	Spread = 2
	blast_refire = 0.5
	self_cooldown_ticks = 125
	roleplay_projectile_speed = 28
	roleplay_projectile_distance = 30
	verb/Wall_of_Flame()
		set name = "Wall of Flame"
		set category = "Skills"
		useRoleplayBlast(usr)

obj/Attacks/Blast/RoleplayBlast/SuperExplosiveWave
	name = "Super Explosive Wave"
	desc = "Release a fast, non-suicidal fan of explosive energy around the forward arc."
	icon = 'src/Icons/RoleplayTenkaichi/Attacks/Blasts/RTCharge.dmi'
	Drain = 14
	Blast_Count = 4
	Explosive = 2
	Shockwave = 3
	Spread = 3
	blast_refire = 0.4
	self_cooldown_ticks = 140
	roleplay_projectile_speed = 42
	roleplay_projectile_distance = 45
	verb/Super_Explosive_Wave()
		set name = "Super Explosive Wave"
		set category = "Skills"
		useRoleplayBlast(usr)
