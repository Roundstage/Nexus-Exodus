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
		/obj/Attacks/TenkaichiSpecialStyle/WallOfFlame,
		/obj/Attacks/TenkaichiSpecialStyle/ChargedProjectile/DragonNova,
		/obj/Attacks/TenkaichiSpecialStyle/ChargedProjectile/SkyBreak,
		/obj/Attacks/TenkaichiSpecialStyle/ChargedProjectile/EchoingSlash)

proc/getTenkaichiRockAttackTypes()
	return list(
		/obj/RockThrow,
		/obj/RockSlide,
		/obj/RockTomb)

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
	var/category = input(src, "Choose an adapted Roleplay Tenkaichi attack package.", "Tenkaichi Attacks") in list("Cancel", "Weapon Techniques", "Unarmed Techniques", "Rock Techniques", "Special Styles", "Beams", "All")
	if(category == "Cancel") return
	var/list/attack_types = list()
	switch(category)
		if("Weapon Techniques") attack_types = getTenkaichiWeaponAttackTypes()
		if("Unarmed Techniques") attack_types = getTenkaichiUnarmedAttackTypes()
		if("Rock Techniques") attack_types = getTenkaichiRockAttackTypes()
		if("Special Styles") attack_types = getTenkaichiSpecialStyleAttackTypes()
		if("Beams") attack_types = getTenkaichiBeamAttackTypes()
		if("All")
			attack_types.Add(getTenkaichiWeaponAttackTypes())
			attack_types.Add(getTenkaichiUnarmedAttackTypes())
			attack_types.Add(getTenkaichiRockAttackTypes())
			attack_types.Add(getTenkaichiSpecialStyleAttackTypes())
			attack_types.Add(getTenkaichiBeamAttackTypes())
	var/granted = grantTenkaichiAttackTypes(character, attack_types)
	admin_blame(src, "[key] gave [character] the [category] Roleplay Tenkaichi attack package ([granted] new attacks).")
	src << "[character] received [granted] new attacks from the [category] package. Existing attacks were preserved."


mob/Admin3/verb/testTenkaichiCombatEffects()
	set name = "Test Combat Effects"
	set category = "Admin"
	if(AdminLevel() < 3 || !loc) return
	var/test_profile = input(src, "Choose an audiovisual profile. These previews do not deal damage.", "Combat Effect Preview") in list("Cancel", "Sword - Light", "Sword - Heavy", "Sword Wave - Echoing Slash", "Rock - Launch and Rumble", "Rock - Impact", "Rock - Heavy Impact", "Explosion - Maximum Light", "Beam Explosion - Knockback")
	if(test_profile == "Cancel") return
	switch(test_profile)
		if("Sword - Light", "Sword - Heavy")
			var/obj/Attacks/TenkaichiMeleeTechnique/preview_technique
			if(test_profile == "Sword - Heavy") preview_technique = new /obj/Attacks/TenkaichiMeleeTechnique/OverheadSmash(src)
			else preview_technique = new /obj/Attacks/TenkaichiMeleeTechnique/Slice(src)
			showTenkaichiTechniqueAnnouncement("[test_profile] Preview", preview_technique.cast_text_color, preview_technique.getCastSound(), 40)
			sleep(3)
			preview_technique.showImpact(src)
			spawn(12) if(preview_technique) del(preview_technique)
		if("Sword Wave - Echoing Slash")
			showTenkaichiTechniqueAnnouncement("Echoing Slash Preview", "#b8ecff", pick(nexus_sword_swing_heavy_sounds), 40)
			showNexusSwordSlashEffect(src, "#b8ecff", 1.4)
		if("Rock - Launch and Rumble")
			player_view(15, src) << sound(pick(nexus_rock_launch_sounds), volume = 42)
			sleep(5)
			player_view(15, src) << sound('src/Sound/SoundEffects/Combat/Earth/RockRumble.ogg', volume = 48)
		if("Rock - Impact") showRockSkillImpact(src)
		if("Rock - Heavy Impact") showRockSkillImpact(src, heavy = TRUE)
		if("Explosion - Maximum Light")
			Explosion_Graphics(src, 5)
			player_view(15, src) << sound('Explosion2.wav', volume = 75)
		if("Beam Explosion - Knockback")
			var/turf/dummy_turf = get_step(src, dir)
			if(!dummy_turf || dummy_turf.density)
				src << "Stand in front of an open tile to test beam-explosion knockback."
				return
			var/mob/CombatDummy/impact_dummy = new(dummy_turf)
			impact_dummy.dir = turn(dir, 180)
			var/obj/Blast/test_beam_impact = get_cached_blast()
			test_beam_impact.SafeTeleport(dummy_turf)
			test_beam_impact.Owner = src
			test_beam_impact.Beam = TRUE
			test_beam_impact.dir = dir
			test_beam_impact.percent_damage = 10
			test_beam_impact.showExplosiveBeamImpact(impact_dummy, force_mob_impact = TRUE)
			spawn(60) if(impact_dummy) del(impact_dummy)
	src << "Previewed [test_profile]."
