proc/getNexusWeaponAttackTypes()
	return list(
		/obj/Attacks/NexusMeleeTechnique/Slice,
		/obj/Attacks/NexusMeleeTechnique/Bash,
		/obj/Attacks/NexusMeleeTechnique/Flourish,
		/obj/Attacks/NexusMeleeTechnique/WindHowl,
		/obj/Attacks/NexusMeleeTechnique/IaiSlash,
		/obj/Attacks/NexusMeleeTechnique/Riposte,
		/obj/Attacks/NexusMeleeTechnique/Cleave,
		/obj/Attacks/NexusMeleeTechnique/SwordStab,
		/obj/Attacks/NexusMeleeTechnique/OverheadSmash,
		/obj/Attacks/NexusMeleeTechnique/ColossalImpact,
		/obj/Attacks/NexusMeleeTechnique/BurningSlash,
		/obj/Attacks/NexusMeleeTechnique/CriticalEdge,
		/obj/Attacks/NexusSpecialStyle/ChargedProjectile/EchoingSlash,
		/obj/Attacks/NexusSpecialStyle/ChargedProjectile/SkyBreak)

proc/getNexusUnarmedAttackTypes()
	return list(
		/obj/Attacks/NexusMeleeTechnique/Headbutt,
		/obj/Attacks/NexusMeleeTechnique/UppercutCombo,
		/obj/Attacks/NexusMeleeTechnique/AxeKick,
		/obj/Attacks/NexusMeleeTechnique/KickbackCombo,
		/obj/Attacks/NexusMeleeTechnique/MarchOfFury,
		/obj/Attacks/NexusMeleeTechnique/PileDriver,
		/obj/Attacks/NexusMeleeTechnique/MegatonThrow,
		/obj/Attacks/NexusMeleeTechnique/ConsecutiveNormalPunches,
		/obj/Attacks/NexusMeleeTechnique/ExplodingHeartStrike,
		/obj/Attacks/NexusMeleeTechnique/TexasSmash,
		/obj/Attacks/NexusMeleeTechnique/GuardBreak,
		/obj/Attacks/NexusMeleeTechnique/WingClip,
		/obj/Attacks/NexusMeleeTechnique/SandThrow,
		/obj/Attacks/NexusMeleeTechnique/BurningShot,
		/obj/Attacks/NexusMeleeTechnique/BlueCometSpecial,
		/obj/Attacks/NexusMeleeTechnique/CometReversal)

proc/getNexusBeamAttackTypes()
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

proc/getNexusSpecialStyleAttackTypes()
	return list(
		/obj/Attacks/Buster_Barrage,
		/obj/Attacks/NexusSpecialStyle/WallOfFlame,
		/obj/Attacks/NexusSpecialStyle/SuperGhostKamikaze,
		/obj/Attacks/NexusAreaTechnique/SuperExplosiveWave,
		/obj/Attacks/NexusAreaTechnique/Earthquake,
		/obj/Attacks/NexusSpecialStyle/ChargedProjectile/DragonNova,
		/obj/Attacks/NexusSpecialStyle/ChargedProjectile/SkyBreak,
		/obj/Attacks/NexusSpecialStyle/ChargedProjectile/EchoingSlash)

proc/getNexusRockAttackTypes()
	return list(
		/obj/RockThrow,
		/obj/RockSlide,
		/obj/RockTomb)

proc/getNexusRangedAttackTypes()
	return getNexusSpecialStyleAttackTypes()

proc/grantNexusAttackTypes(mob/character, list/attack_types)
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

mob/Admin3/verb/giveNexusAttacks(mob/character in players)
	set name = "Give Nexus Attacks"
	set category = "Admin"
	if(AdminLevel() < 3 || !character) return
	var/category = input(src, "Choose an adapted Nexus attack package.", "Nexus Attacks") in list("Cancel", "Weapon Techniques", "Unarmed Techniques", "Rock Techniques", "Special Styles", "Beams", "All")
	if(category == "Cancel") return
	var/list/attack_types = list()
	switch(category)
		if("Weapon Techniques") attack_types = getNexusWeaponAttackTypes()
		if("Unarmed Techniques") attack_types = getNexusUnarmedAttackTypes()
		if("Rock Techniques") attack_types = getNexusRockAttackTypes()
		if("Special Styles") attack_types = getNexusSpecialStyleAttackTypes()
		if("Beams") attack_types = getNexusBeamAttackTypes()
		if("All")
			attack_types.Add(getNexusWeaponAttackTypes())
			attack_types.Add(getNexusUnarmedAttackTypes())
			attack_types.Add(getNexusRockAttackTypes())
			attack_types.Add(getNexusSpecialStyleAttackTypes())
			attack_types.Add(getNexusBeamAttackTypes())
	var/granted = grantNexusAttackTypes(character, attack_types)
	admin_blame(src, "[key] gave [character] the [category] Nexus attack package ([granted] new attacks).")
	src << "[character] received [granted] new attacks from the [category] package. Existing attacks were preserved."


mob/Admin3/verb/testNexusCombatEffects()
	set name = "Test Combat Effects"
	set category = "Admin"
	if(AdminLevel() < 3 || !loc) return
	var/test_profile = input(src, "Choose an audiovisual profile. These previews do not deal damage.", "Combat Effect Preview") in list("Cancel", "Critical - Black Flash", "Sword - Light", "Sword - Heavy", "Sword Wave - Echoing Slash", "Rock - Launch and Rumble", "Rock - Impact", "Rock - Heavy Impact", "Explosion - Maximum Light", "Beam Clash - Marker", "Beam Explosion - Knockback")
	if(test_profile == "Cancel") return
	switch(test_profile)
		if("Critical - Black Flash")
			showNexusCriticalImpact(src)
		if("Sword - Light", "Sword - Heavy")
			var/obj/Attacks/NexusMeleeTechnique/preview_technique
			if(test_profile == "Sword - Heavy") preview_technique = new /obj/Attacks/NexusMeleeTechnique/OverheadSmash(src)
			else preview_technique = new /obj/Attacks/NexusMeleeTechnique/Slice(src)
			showNexusTechniqueAnnouncement("[test_profile] Preview", preview_technique.cast_text_color, preview_technique.getCastSound(), 40)
			sleep(3)
			preview_technique.showImpact(src)
			spawn(12) if(preview_technique) del(preview_technique)
		if("Sword Wave - Echoing Slash")
			showNexusTechniqueAnnouncement("Echoing Slash Preview", "#b8ecff", pick(nexus_sword_swing_heavy_sounds), 40)
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
		if("Beam Clash - Marker")
			var/turf/clash_turf = get_step(src, dir)
			if(!clash_turf) clash_turf = loc
			showNexusBeamClashMarker(clash_turf)
			Make_Shockwave(clash_turf, sw_icon_size = 128)
			player_view(15, src) << sound('Explosion2.wav', volume = 36)
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
