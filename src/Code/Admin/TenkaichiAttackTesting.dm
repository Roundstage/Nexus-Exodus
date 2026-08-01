proc/getTenkaichiWeaponAttackTypes()
	return list(
		/obj/Attacks/TenkaichiMeleeTechnique/Slice,
		/obj/Attacks/TenkaichiMeleeTechnique/Bash,
		/obj/Attacks/TenkaichiMeleeTechnique/Flourish,
		/obj/Attacks/TenkaichiMeleeTechnique/WindHowl,
		/obj/Attacks/TenkaichiMeleeTechnique/IaiSlash,
		/obj/Attacks/TenkaichiMeleeTechnique/Cleave,
		/obj/Attacks/TenkaichiMeleeTechnique/SwordStab,
		/obj/Attacks/TenkaichiMeleeTechnique/OverheadSmash,
		/obj/Attacks/TenkaichiMeleeTechnique/ColossalImpact,
		/obj/Attacks/TenkaichiMeleeTechnique/BurningSlash,
		/obj/Attacks/Blast/RoleplayBlast/ExplodingBolt,
		/obj/Attacks/Blast/RoleplayBlast/IceArrow,
		/obj/Attacks/Blast/RoleplayBlast/BlockTheSky,
		/obj/Attacks/Blast/RoleplayBlast/EchoingSlash,
		/obj/Attacks/Blast/RoleplayBlast/SkyBreak)

proc/getTenkaichiUnarmedAttackTypes()
	return list(
		/obj/Attacks/TenkaichiMeleeTechnique/Headbutt,
		/obj/Attacks/TenkaichiMeleeTechnique/UppercutCombo,
		/obj/Attacks/TenkaichiMeleeTechnique/AxeKick,
		/obj/Attacks/TenkaichiMeleeTechnique/KickbackCombo,
		/obj/Attacks/TenkaichiMeleeTechnique/MarchOfFury,
		/obj/Attacks/TenkaichiMeleeTechnique/PileDriver,
		/obj/Attacks/TenkaichiMeleeTechnique/MegatonThrow,
		/obj/Attacks/TenkaichiMeleeTechnique/ExplodingHeartStrike,
		/obj/Attacks/TenkaichiMeleeTechnique/TexasSmash,
		/obj/Attacks/TenkaichiMeleeTechnique/GuardBreak,
		/obj/Attacks/TenkaichiMeleeTechnique/WingClip,
		/obj/Attacks/TenkaichiMeleeTechnique/BurningShot,
		/obj/Attacks/TenkaichiMeleeTechnique/BlueCometSpecial,
		/obj/Attacks/TenkaichiMeleeTechnique/CriticalEdge)

proc/getTenkaichiBeamAttackTypes()
	return list(
		/obj/Attacks/Beam,
		/obj/Attacks/Dodompa,
		/obj/Attacks/Ray,
		/obj/Attacks/Piercer,
		/obj/Attacks/Kamehameha,
		/obj/Attacks/Final_Flash,
		/obj/Attacks/Garlic_Gun,
		/obj/Attacks/Masenko,
		/obj/Attacks/RoleplayBeam/DoubleSunday,
		/obj/Attacks/RoleplayBeam/PhotonFlash,
		/obj/Attacks/RoleplayBeam/TyrantLancer,
		/obj/Attacks/RoleplayBeam/BusterCannon)

proc/getTenkaichiRangedAttackTypes()
	return list(
		/obj/Attacks/Charge,
		/obj/Attacks/Kienzan,
		/obj/Attacks/Sokidan,
		/obj/Attacks/Buster_Barrage,
		/obj/Attacks/Blast/RoleplayBlast/MortarCharge,
		/obj/Attacks/Blast/RoleplayBlast/HomingFinisher,
		/obj/Attacks/Blast/RoleplayBlast/HellzoneGrenade,
		/obj/Attacks/Blast/RoleplayBlast/BlasterMeteor,
		/obj/Attacks/Blast/RoleplayBlast/KillDriver,
		/obj/Attacks/Blast/RoleplayBlast/GuideBomb,
		/obj/Attacks/Blast/RoleplayBlast/DragonNova,
		/obj/Attacks/Blast/RoleplayBlast/HyperTornado,
		/obj/Attacks/Blast/RoleplayBlast/MegaBurst,
		/obj/Attacks/Blast/RoleplayBlast/TriBeam,
		/obj/Attacks/Blast/RoleplayBlast/ExplosiveDemonWave,
		/obj/Attacks/Blast/RoleplayBlast/SuperGhostKamikaze,
		/obj/Attacks/Blast/RoleplayBlast/WallOfFlame,
		/obj/Attacks/Blast/RoleplayBlast/SuperExplosiveWave)

proc/grantTenkaichiAttackTypes(mob/character, list/attack_types)
	if(!character || !islist(attack_types)) return 0
	var/granted = 0
	for(var/attack_type in attack_types)
		var/already_owned = FALSE
		for(var/obj/existing_attack in character)
			if(existing_attack.type == attack_type)
				already_owned = TRUE
				break
		if(already_owned) continue
		new attack_type(character)
		granted++
	return granted

mob/Admin3/verb/giveTenkaichiAttacks(mob/character in players)
	set name = "Give Tenkaichi Attacks"
	set category = "Admin"
	if(AdminLevel() < 3 || !character) return
	var/category = input(src, "Choose an adapted Roleplay Tenkaichi attack package.", "Tenkaichi Attacks") in list("Cancel", "Weapon Techniques", "Unarmed Techniques", "Beams", "Ranged Attacks", "All")
	if(category == "Cancel") return
	var/list/attack_types = list()
	switch(category)
		if("Weapon Techniques") attack_types = getTenkaichiWeaponAttackTypes()
		if("Unarmed Techniques") attack_types = getTenkaichiUnarmedAttackTypes()
		if("Beams") attack_types = getTenkaichiBeamAttackTypes()
		if("Ranged Attacks") attack_types = getTenkaichiRangedAttackTypes()
		if("All")
			attack_types.Add(getTenkaichiWeaponAttackTypes())
			attack_types.Add(getTenkaichiUnarmedAttackTypes())
			attack_types.Add(getTenkaichiBeamAttackTypes())
			attack_types.Add(getTenkaichiRangedAttackTypes())
	var/granted = grantTenkaichiAttackTypes(character, attack_types)
	admin_blame(src, "[key] gave [character] the [category] Roleplay Tenkaichi attack package ([granted] new attacks).")
	src << "[character] received [granted] new attacks from the [category] package. Existing attacks were preserved."
