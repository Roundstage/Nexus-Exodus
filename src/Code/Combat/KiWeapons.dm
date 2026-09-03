#define KI_WEAPON_PROFICIENCY_NOVICE 1
#define KI_WEAPON_PROFICIENCY_BASIC 2
#define KI_WEAPON_PROFICIENCY_ADEPT 3
#define KI_WEAPON_PROFICIENCY_ADVANCED 4
#define KI_WEAPON_PROFICIENCY_MASTER 5

mob/var/tmp/obj/KiWeaponTechnique/active_ki_weapon

mob/proc/getKiWeaponProficiency()
	if(hasProgressionNode("ki_weapon_proficiency_master")) return KI_WEAPON_PROFICIENCY_MASTER
	if(hasProgressionNode("ki_weapon_proficiency_advanced")) return KI_WEAPON_PROFICIENCY_ADVANCED
	if(hasProgressionNode("ki_weapon_proficiency_adept")) return KI_WEAPON_PROFICIENCY_ADEPT
	if(hasProgressionNode("ki_weapon_proficiency_basic")) return KI_WEAPON_PROFICIENCY_BASIC
	return KI_WEAPON_PROFICIENCY_NOVICE

mob/proc/getKiWeaponProficiencyName()
	switch(getKiWeaponProficiency())
		if(KI_WEAPON_PROFICIENCY_BASIC) return "Basic (Copper)"
		if(KI_WEAPON_PROFICIENCY_ADEPT) return "Adept (Iron)"
		if(KI_WEAPON_PROFICIENCY_ADVANCED) return "Advanced (Mythril)"
		if(KI_WEAPON_PROFICIENCY_MASTER) return "Master (Masterwork)"
	return "Novice (Normal)"

mob/proc/getKiWeaponBPBonus()
	switch(getKiWeaponProficiency())
		if(KI_WEAPON_PROFICIENCY_BASIC) return 0.06
		if(KI_WEAPON_PROFICIENCY_ADEPT) return 0.14
		if(KI_WEAPON_PROFICIENCY_ADVANCED) return 0.20
		if(KI_WEAPON_PROFICIENCY_MASTER) return 0.26
	return 0.03

mob/proc/usingKiWeapon()
	if(active_ki_weapon && active_ki_weapon.loc == src && active_ki_weapon.suffix) return active_ki_weapon
	active_ki_weapon = null
	for(var/obj/KiWeaponTechnique/ki_weapon in src)
		if(ki_weapon.suffix)
			if(!active_ki_weapon) active_ki_weapon = ki_weapon
			else ki_weapon.suffix = null
	return active_ki_weapon

mob/proc/usingKiWeaponAsWeapon()
	var/obj/KiWeaponTechnique/ki_weapon = usingKiWeapon()
	return ki_weapon && ki_weapon.counts_as_weapon

mob/proc/usingCuttingKiWeapon()
	var/obj/KiWeaponTechnique/ki_weapon = usingKiWeapon()
	return ki_weapon && ki_weapon.causes_bleed

mob/proc/usingMeleeWeapon()
	return using_sword() || usingKiWeaponAsWeapon()

mob/proc/getKiWeaponCombatBP()
	var/obj/KiWeaponTechnique/ki_weapon = usingKiWeapon()
	var/effective_bp = using_sword() ? getForgedWeaponAttackBP() : BP
	if(ki_weapon && ki_weapon.isEmbue(src)) return effective_bp
	return effective_bp * (1 + getKiWeaponBPBonus())

mob/proc/getKiWeaponSourceStat(obj/KiWeaponTechnique/ki_weapon)
	if(!ki_weapon) return getMilestonePhysicalDamageStat()
	return getMilestonePhysicalDamageStat() + getMilestoneScaledCombatStat(Pow) * ki_weapon.force_share

mob/proc/getKiWeaponAccuracyMultiplier()
	var/obj/KiWeaponTechnique/ki_weapon = usingKiWeapon()
	return ki_weapon ? ki_weapon.accuracy_multiplier : 1

mob/proc/getKiWeaponDelayMultiplier()
	var/obj/KiWeaponTechnique/ki_weapon = usingKiWeapon()
	return ki_weapon ? ki_weapon.delay_multiplier : 1

mob/proc/getKiWeaponEnergyMultiplier(obj/KiWeaponTechnique/ki_weapon)
	if(!ki_weapon || !ki_weapon.scales_with_energy) return 1
	return 0.7 + 0.3 * Clamp(Ki / max(max_ki, 1), 0, 1)

mob/proc/disableKiWeaponForPhysicalWeapon()
	var/obj/KiWeaponTechnique/ki_weapon = usingKiWeapon()
	if(ki_weapon && !ki_weapon.allows_physical_weapon)
		ki_weapon.deactivate(src, TRUE)

mob/proc/migrateLegacyKiWeapons()
	var/migrated_legacy_ki_weapon = FALSE
	var/obj/Buff/Preset/KiBlade/legacy_blade = locate() in src
	if(legacy_blade)
		migrated_legacy_ki_weapon = TRUE
		if(!(locate(/obj/KiWeaponTechnique/KiSword) in src)) contents += new /obj/KiWeaponTechnique/KiSword(src)
		if(legacy_blade.suffix) Buff_Disable(legacy_blade)
		del(legacy_blade)
	var/obj/Buff/Preset/KiFist/legacy_fist = locate() in src
	if(legacy_fist)
		migrated_legacy_ki_weapon = TRUE
		if(!(locate(/obj/KiWeaponTechnique/KiFist) in src)) contents += new /obj/KiWeaponTechnique/KiFist(src)
		if(legacy_fist.suffix) Buff_Disable(legacy_fist)
		del(legacy_fist)
	if(migrated_legacy_ki_weapon)
		if(!islist(progression_nodes_owned)) progression_nodes_owned = list()
		progression_nodes_owned["combat_ki_weapons_root"] = max(1, getProgressionNodeRank("combat_ki_weapons_root"))
		progression_nodes_owned["ki_weapon_proficiency_novice"] = max(1, getProgressionNodeRank("ki_weapon_proficiency_novice"))
	usingKiWeapon()

obj/KiWeaponTechnique
	name = "Ki Weapon"
	desc = "Shape Ki into a reliable close-combat weapon. Its tier follows your Ki Weapon proficiency."
	Skill = 1
	can_hotbar = 1
	hotbar_type = "Melee"
	repeat_macro = 0
	Cost_To_Learn = 0
	teachable = 0
	Reteachable = 0
	Relearnable = 0
	Duplicates_Allowed = 0
	icon = 'src/Icons/VFX/SaiyanPower.dmi'
	var
		force_share = 0
		counts_as_weapon = FALSE
		allows_physical_weapon = FALSE
		uses_energy_defense = FALSE
		scales_with_energy = FALSE
		causes_bleed = FALSE
		accuracy_multiplier = 1
		delay_multiplier = 1

	verb/Hotbar_use()
		set hidden = 1
		toggle(usr)

	Click()
		if(src in usr) toggle(usr)

	proc/toggle(mob/user)
		if(!user || loc != user || user.KO || user.Redoing_Stats) return FALSE
		if(suffix) return deactivate(user)
		if(!allows_physical_weapon && user.using_sword())
			user << "You must unequip your physical weapon before shaping [src]."
			return FALSE
		var/obj/KiWeaponTechnique/other = user.usingKiWeapon()
		if(other && other != src) other.deactivate(user, TRUE)
		suffix = "Active"
		user.active_ki_weapon = src
		var/activation_name = isEmbue(user) ? "Embue" : name
		user.showNexusTechniqueAnnouncement(activation_name, getActivationColor(), 'Kiplosion.ogg', 24)
		if(isEmbue(user)) user << "You Embue your physical weapon with Ki, adding 30% of Force without adding Ki Weapon BP."
		else user << "You shape [src] at [user.getKiWeaponProficiencyName()] proficiency."
		return TRUE

	proc/deactivate(mob/user, quiet = FALSE)
		if(!user || !suffix) return FALSE
		suffix = null
		if(user.active_ki_weapon == src) user.active_ki_weapon = null
		if(!quiet) user << "You release [src]."
		return TRUE

	proc/getActivationColor()
		return "#ffe75e"

	proc/isEmbue(mob/user)
		return FALSE

	KiFist
		name = "Ki Fist"
		desc = "Wraps the hands in Ki and adds 30% of Force to melee scaling. With a physical weapon this becomes Embue, retaining only the weapon's BP reinforcement."
		force_share = 0.3
		allows_physical_weapon = TRUE
		isEmbue(mob/user)
			return user && user.using_sword()

	KiSword
		name = "Ki Sword"
		desc = "Shapes a light Ki blade. Adds 70% of Force to melee scaling and carries a sword accuracy penalty, but does not unlock weapon techniques."
		force_share = 0.7
		accuracy_multiplier = 0.85
		icon = 'src/Icons/Ki/Blasts/BlastDestructoDisk.dmi'
		getActivationColor()
			return "#a7fff0"

	KiHammer
		name = "Ki Hammer"
		desc = "Shapes a heavy Ki hammer. Adds 100% of Force to melee scaling, counts as a weapon and trades speed and accuracy for impact."
		force_share = 1
		counts_as_weapon = TRUE
		accuracy_multiplier = 0.75
		delay_multiplier = 1.25
		getActivationColor()
			return "#70d8ff"

	SpiritSword
		name = "Spirit Sword"
		desc = "The highest Ki Weapon discipline. Adds 70% of Force to melee scaling, attacks Resistance through energy and counts as a weapon."
		force_share = 0.7
		counts_as_weapon = TRUE
		uses_energy_defense = TRUE
		scales_with_energy = TRUE
		causes_bleed = TRUE
		accuracy_multiplier = 0.85
		icon = 'src/Icons/Effects/CC0/SwordSlash.dmi'
		getActivationColor()
			return "#ca87ff"
