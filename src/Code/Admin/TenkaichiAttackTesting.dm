proc/getTenkaichiWeaponAttackTypes()
	return list(
		/obj/Attacks/TenkaichiMeleeTechnique/Slice,
		/obj/Attacks/TenkaichiMeleeTechnique/Bash,
		/obj/Attacks/TenkaichiMeleeTechnique/Flourish,
		/obj/Attacks/TenkaichiMeleeTechnique/WindHowl,
		/obj/Attacks/TenkaichiMeleeTechnique/IaiSlash,
		/obj/Attacks/TenkaichiMeleeTechnique/Riposte,
		/obj/Attacks/TenkaichiMeleeTechnique/Cleave,
		/obj/Attacks/TenkaichiMeleeTechnique/SwordStab,
		/obj/Attacks/TenkaichiMeleeTechnique/OverheadSmash,
		/obj/Attacks/TenkaichiMeleeTechnique/ColossalImpact,
		/obj/Attacks/TenkaichiMeleeTechnique/BurningSlash)

proc/getTenkaichiUnarmedAttackTypes()
	return list(
		/obj/Attacks/TenkaichiMeleeTechnique/Headbutt,
		/obj/Attacks/TenkaichiMeleeTechnique/UppercutCombo,
		/obj/Attacks/TenkaichiMeleeTechnique/AxeKick,
		/obj/Attacks/TenkaichiMeleeTechnique/KickbackCombo,
		/obj/Attacks/TenkaichiMeleeTechnique/MarchOfFury,
		/obj/Attacks/TenkaichiMeleeTechnique/PileDriver,
		/obj/Attacks/TenkaichiMeleeTechnique/MegatonThrow,
		/obj/Attacks/TenkaichiMeleeTechnique/ConsecutiveNormalPunches,
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

proc/getTenkaichiSpecialStyleAttackTypes()
	return list(
		/obj/Attacks/Buster_Barrage,
		/obj/Attacks/TenkaichiSpecialStyle/WallOfFlame)

proc/getTenkaichiRangedAttackTypes()
	return getTenkaichiSpecialStyleAttackTypes()

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
	var/category = input(src, "Choose an adapted Roleplay Tenkaichi attack package.", "Tenkaichi Attacks") in list("Cancel", "Weapon Techniques", "Unarmed Techniques", "Special Styles", "Beams", "All")
	if(category == "Cancel") return
	var/list/attack_types = list()
	switch(category)
		if("Weapon Techniques") attack_types = getTenkaichiWeaponAttackTypes()
		if("Unarmed Techniques") attack_types = getTenkaichiUnarmedAttackTypes()
		if("Special Styles") attack_types = getTenkaichiSpecialStyleAttackTypes()
		if("Beams") attack_types = getTenkaichiBeamAttackTypes()
		if("All")
			attack_types.Add(getTenkaichiWeaponAttackTypes())
			attack_types.Add(getTenkaichiUnarmedAttackTypes())
			attack_types.Add(getTenkaichiSpecialStyleAttackTypes())
			attack_types.Add(getTenkaichiBeamAttackTypes())
	var/granted = grantTenkaichiAttackTypes(character, attack_types)
	admin_blame(src, "[key] gave [character] the [category] Roleplay Tenkaichi attack package ([granted] new attacks).")
	src << "[character] received [granted] new attacks from the [category] package. Existing attacks were preserved."
