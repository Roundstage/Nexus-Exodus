proc/ShouldOneShot(mob/a, mob/b) //a = attacker
	if(!a || !b) return

	//makes it so npcs cant be one shotted or get one shotted for now since theres a bug where they always get 1 shotted because they have no base_bp
	//or something like that
	if(ismob(a) && !a.client) return
	if(ismob(b) && !b.client) return

	var/a_bp = 1
	var/b_bp = 1

	if(ismob(a))
		a_bp = a.base_bp * 3.5 + a.BP + a.cyber_bp
		if(ismob(b))
			if(a.BP < b.BP * 1.5) return
	else if(isnum(a)) a_bp = a

	if(ismob(b)) b_bp = b.base_bp * 3.5 + b.BP + a.cyber_bp
	else if(isnum(b)) b_bp = b

	if(a_bp > b_bp * one_shot_start) return 1

var
	lssj_always_angry = 1
	lssjTakeDmgMult = 0.9
	lssj_combat_bp_mult = 1.65
	saiyan_combat_bp_mult = 0.77
	half_saiyan_combat_bp_mult = 0.69
	android_combat_bp_mult = 1.35
	android_dmg_taken_mult = 0.55
	bio_android_combat_bp_mult = 1.1
	bio_android_dmg_taken_mult = 0.89
	majin_combat_bp_mult = 1.13
	majin_dmg_taken_mult = 0.96
	demigod_combat_bp_mult = 0.66
	frost_lord_combat_bp_mult = 0.8
	cooler_combat_bp_mult = 0.76
	cooler_dmg_taken_mult = 0.89
	makyo_combat_bp_mult = 0.94
	makyo_star_combat_bp_mult = 1.08

	bp_exponent = 0.50 //how much bp matters in a fight
	one_shot_start = 4 //you will begin inflicting insane damage against someone if you are more than this multiple stronger than them,
	//often 1 shotting them into a bloody mess like Saitama
	one_shot_dmg_mult = 2 //do this many times normal damage

	beam_dmg_mod = 0.6
	global_beam_deflect_mod = 1

	dura_regen_mod = 0.4 //this is for the system where higher durability (and resistance?) will slower your regen rate because it is like having more health to heal

	stun_damage_mod = 0.6 //reduces damage you take from any ki attack if you are stunned when it hits you
	arbitraryStunPower = 1.5
	arbitraryStunTime = 1.5

	//!!!!!!!!!! DO NOT USE modless_gain_exponent anymore. modless_gain_mult IS THE REPLACEMENT THAT IS MORE LINEAR WHICH IS BETTER
	modless_gain_exponent = 0.7 //adjusting these 2 vars can fix a lot of the balance problems. remember they are sort of intertwined
		//REMEMBER CHANGING modless_gain_exponent WILL NEED ALL PLAYERS TO REDO STATS
	balance_rating_mult = 0 //0.42 //0 = off. lower = retains more balance rating when changing stats.
	modless_gain_mult = 0.4 //we started using this instead of modless_gain_exponent to have more predictable numbers and just see how it goes

	base_melee_damage = 2.5
	base_melee_delay = 3 //was 3
	melee_delay_severity = 0.75 //was 0.52
	lowSpeedDmgAdd = 0.2

	superior_force_exponent = 0.7 //was .4
	inferior_force_exponent = 0.45 //was .4

	superior_strength_exponent = 0.8 //was .4
	inferior_strength_exponent = 0.45 //was .4

	defense_damage_reduction_exponent = 0.25 //was 0.25
	defense_damage_reduction_cap = 0.9 //was .77, essentially off if it is 1x

	shield_reduction = 0.6 //damage you take is multiplied by this amount so 0.4 = only take 0.4x normal damage
	shield_exponent = 0.4 //how much affect more energy mod will have on reducing shield damage

	swordBleedDmg = 0.2 //if 0.5, half of the swords overall damage is applied as bleed damage, and SUBTRACTED from the regular dmg so dont worry about that
	sword_damage_mod = 0.7 //applies to the bonus only, so +70% damage becomes +(70x0.8)% damage assuming the mod is 0.8, so not 1.7x0.8
	sword_drain_mult = 0.5 //melee drain *= 1 + (sword.Damage - 1) * sword_drain_mult
	sword_refire_mod = 0 //was 0.3 //delay *= 1 + (s.Damage - 1) * sword_refire_mod
	swordDodgeMod = 0.5 //accuracy /= 1 + (equipped_sword.Damage - 1) * swordDodgeMod
	energy_sword_damage_mod = 1 //0.975
	silver_sword_damage_penalty = 1 //against nonvampires
	silver_sword_damage_mult = 1.5 //against vampires

	strangle_str_mult_cap = 2.5 //2
	grab_struggle_mod = 2 //1.8
	grab_damage_mod = 2.5 //1.5 //put to about 1.3

	hit_from_behind_dmg_mult = 2

	speed_accuracy_mult_exponent = 0.25 //was 0.25
	speed_accuracy_mult_min = 1
	speed_accuracy_mult_max = 1.12 //was 1.12, 1 essentially is off

	base_melee_accuracy = 67 //was 67. 100 for new combat
	base_blast_accuracy = 40
	superior_off_vs_def_mult_exponent = 0.6 //was 0.45
	inferior_off_vs_def_mult_exponent = 0.45 //was 0.45

	kb_superior_scaling_mod = 0.5
	kb_inferior_scaling_mod = 1

	defense_auto_combo_backhit_chance = 20
	recovery_powerup_exponent = 1.3
	energy_mod_powerup_exponent = 0.90 //was .84, determines max powerup % before massive slowdown begins, a soft cap
	powerup_softcap_scaledown_exponent = 3 //how fast powerup slows down past the soft cap. this is not the soft cap itself
	health_regen_exponent = 1

	android_extra_cyber_bp_mult = 1.8

	standing_powerup_deflect_mult = 10
	teamer_dmg_mult = 0.65 //remember double angers is a possiblility

	melee_power=1
	ki_power=1

	// Skill factors mirrored by docs/Balance/SkillDamageBalance.xlsx.
	// Keep these values centralized so runtime tuning and startup validation cannot drift apart.
	basic_blast_base_refire_deciseconds = 0.75
	basic_blast_default_volley_size = 3
	basic_blast_max_volley_size = 3
	basic_blast_damage_scale = 0.3
	basic_blast_energy_scale = 0.2
	basic_blast_angle_spacing_degrees = 6
	basic_blast_angle_jitter_degrees = 2
	basic_blast_owner_active_limit = 24
	basic_blast_global_active_limit = 256
	skill_blast_total_factor = 0.6
	skill_big_bang_damage_factor = 22
	skill_charge_damage_factor = 4
	skill_cyber_charge_damage_factor = 2.5
	skill_makosen_damage_factor = 1
	skill_makosen_total_factor = 16
	skill_scatter_shot_damage_factor = 0.3
	skill_scatter_shot_total_factor = 18
	skill_attack_barrier_damage_factor = 0.2
	skill_shockwave_damage_factor = 0.5
	skill_explosion_damage_factor = 3
	skill_dash_attack_min_factor = 3
	skill_dash_attack_max_factor = 12
	skill_dash_attack_step_factor = 0.4
	skill_dropkick_opening_factor = 7
	skill_dropkick_finisher_factor = 5
	skill_sokidan_damage_factor = 6
	skill_sokidan_total_factor = 12
	skill_kienzan_damage_factor = 10
	skill_kienzan_pierce_decay = 0.5
	beam_skill_cooldown_ticks = 30
	beam_clash_winner_damage_mult = 1.35
	beam_clash_input_mult = 1.15

	// Roleplay combat and Willpower settings adapted from Nexus.
	WILLPOWER_LETHAL_KO_DRAIN = 30
	WILLPOWER_LETHAL_DURATION = 1200
	WILLPOWER_CRITICAL_DURATION = 2400
	WILLPOWER_FAILURE_RECOVERY = 10
	WILLPOWER_RECOVERY_AMOUNT = 1
	WILLPOWER_RECOVERY_INTERVAL = 300
	WILLPOWER_EXTERNAL_DRAIN = 10
	MILESTONE_STARTING_POINTS = 5
	NEXUS_MILESTONE_POINT_CAP = 22

	icer_recovery = 1.1 //was 1.2, but they wanted it off, meaning icer forms no longer lower recovery with each higher transformation

var
	ANGER_SYSTEM_TIME_BETWEEN_ANGERS	= 10 * 10 * 1	// 10 seconds //5 minutes (300 seconds)
	GLOBAL_MELEE_SPEED_OFFSET			= 1				// directly sum into melee speed formula
	GLOBAL_ACCURACY_EXPONENT 			= bp_exponent

// KO System
var
	KO_SYSTEM_UNCONSCIOUS_KO			= 1				// Which KO will mark Unconsciousness
	KO_SYSTEM_UNCONSCIOUS_KO_DURATION   = 10 * 10 * 6	// 10 minutes (600 seconds)
	KO_SYSTEM_NORMAL_KO_DURATION		= 3  * 10 * 3	// 3 minutes  (180 seconds)
	KO_SYSTEM_OUT_OF_COMBAT_TIMER		= 2  * 10 * 60	// 2 minutes  (120 seconds)
	KO_SYSTEM_OUT_OF_COMBAT				= 5  * 10 * 60	// 5 minutes  (300 seconds)
	KO_SYSTEM_HEAL_ANNOUNCE_TIMER		= 3  * 10 * 10	// 30 seconds 
	KO_SYSTEM_FULL_HEAL_IN_SPAR			= FALSE			// If TRUE, the player come back from the KO in full health

	KO_SYSTEM_STATS_AFFECT_HEAL_TIME	= TRUE			// If TRUE, the higher the regen stat, the faster the healing
	KO_SYSTEM_DEATH_REGEN_HEALS_KO		= TRUE			// If TRUE, the death regen will heal the player back to the KO before KO_SYSTEM_UNCONSCIOUS_KO
	KO_SYSTEM_SURVIVE_IF_NONLETHAL		= TRUE			// If the attacker is not in LETHAL_COMBAT, KO_SYSTEM_UNCONSCIOUS_KO will not kill the player if not healed

	KO_SYSTEM_REGENERATOR_MODIFIER		= 0.5			// Being inside a regenerator will make the Combat KO heal in 1/2 the time (100 -> 50)
	KO_SYSTEM_GIVEPOWER_MODIFIER		= 0.75			// Using regenerate will make the Combat KO heal in 3/4 the time		   (100 -> 75)
	KO_SYSTEM_REGENERATE_MODIFIER		= 0.8			// Using regenerate will make the Combat KO heal in 4/5 the time		   (100 -> 80)

	KO_SYSTEM_T_HEAL_USAGE_LIMIT		= 2				// How many times t_heal can be used before causing a ko
	KO_SYSTEM_T_HEAL_FAIL_COOLDOWN		= 10 * 10 * 6	// 10 minutes (600 seconds) - Cooldown for how many times t_heal can be used before causing a ko
	KO_SYSTEM_SENSU_COOLDOWN			= 30 * 10 * 6	// 10 minutes (600 seconds) - Cooldown for how many times sensu can be used before causing a ko
