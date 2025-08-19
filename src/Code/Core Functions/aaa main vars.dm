client/authenticate = 0

mob/var/
	icer_form1_mult=0.1
	icer_form2_mult=0.2
	icer_form3_mult=0.3
	icer_form4_mult=0.6

proc/ShouldOneShot(mob/a, mob/b) //a = attacker
	if(!a || !b) return

	//makes it so npcs cant be one shotted or get one shotted for now since theres a bug where they always get 1 shotted because they have no base_bp
	//or something like that
	if(ismob(a) && !a.client) return
	if(ismob(b) && !b.client) return

	var
		a_bp = 1
		b_bp = 1

	if(ismob(a))
		a_bp = a.base_bp * 3.5 + a.BP + a.cyber_bp
		if(ismob(b))
			if(a.BP < b.BP * 1.5) return
	else if(isnum(a)) a_bp = a

	if(ismob(b)) b_bp = b.base_bp * 3.5 + b.BP + a.cyber_bp
	else if(isnum(b)) b_bp = b

	if(a_bp > b_bp * one_shot_start) return 1

var
	noPacksOnRP = 0
	classic_ui = 1 //use the classic user interface or not
		//remember to check the right skin file to include so it matches which one we have here
	daynight_enabled = 1
	fireflies = 1

	lssj_always_angry = 1
	lssjTakeDmgMult = 0.6

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

	base_melee_damage = 3.5
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
	android_dmg_taken_mult = 0.66

	standing_powerup_deflect_mult = 10
	teamer_dmg_mult = 0.65 //remember double angers is a possiblility

	melee_power=1
	ki_power=1

	icer_recovery = 1.1 //was 1.2, but they wanted it off, meaning icer forms no longer lower recovery with each higher transformation

	death_x=170
	death_y=200
	death_z=5


// Z-Level Settings -----------------------------------

var/const
	Z_LEVEL_EARTH = 1
	Z_LEVEL_KAMI_OUTPOST_AND_CAVES = 2
	Z_LEVEL_PURANTO = 3
	Z_LEVEL_BRAAL = 4
	Z_LEVEL_CHECKPOINT = 5
	Z_LEVEL_HELL = 6
	Z_LEVEL_HEAVEN = 7
	Z_LEVEL_ARCONIA = 8
	Z_LEVEL_SSX = 9
	Z_LEVEL_HBTC = 10
	Z_LEVEL_ATLANTIS_SHIP_GOD_AREA = 11
	Z_LEVEL_ICE = 12
	Z_LEVEL_KAIOSHIN = 13
	Z_LEVEL_DESERT_JUNGLE_ANDROID = 14
	Z_LEVEL_SONKU = 15
	Z_LEVEL_SPACE = 16
	Z_LEVEL_PRISON = 17
	Z_LEVEL_CORE = 18
	Z_LEVEL_BATTLEGROUNDS = 19

// Global settings that affect RP ##############################################################################

mob/var/energies

var
	ANGER_SYSTEM_TIME_BETWEEN_ANGERS	= 10 * 10 * 1	// 10 seconds //5 minutes (300 seconds)
	GLOBAL_MELEE_SPEED_OFFSET			= 1				// directly sum into melee speed formula
	GLOBAL_ACCURACY_EXPONENT 			= bp_exponent

var
	SHOW_CHAR_NAME_ON_WHO 				= FALSE	
	CAN_BREAK_TURFS 					= TRUE
	SENSE_SYSTEM_SHOW_STAT_BUILD 		= FALSE
	SENSE_SYSTEM_SHOW_VAGUE_INFO		= TRUE			// Remove precision from Sense and show vague terms instead
	
// KO System
var/const
	LETHAL_COMBAT 						= "Fight to Death"
	CASUAL_COMBAT 						= "Casual Spar" 

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

mob/var
	times_used_t_heal 					= 0				// Used to handle repeated instances of t_heal
	last_t_heal_use	 					= 0				// So we can reset the times_used_t_heal
	last_sensu_use	 					= 0				
// Vampire System
var
	DO_VAMPIRES_NEED_TO_FEED 			= TRUE
	DO_VAMPIRES_INFECT_ON_BITE 			= FALSE	
	VAMPIRE_POWER_FALL_INTERVAL 		= 10 * 60		// 60 seconds

// Science System
var
	GLOBAL_SCIENCE_TAB_ITEMS			= null		    // null so it is set to tech_list when the game starts

// Cloning System
var
	CLONING_SYSTEM_LIFESPAN_LOSS		= 0.95			// 95% of original lifespan. This DOES multiply the original lifespan, so its exponential
	CLONING_SYSTEM_POTENTIAL_LOSS		= 0.72			// 72% of original. This does NOT multiply the original potential, it is a flat loss

// New character settings
	START_WITH_RACIAL_SKILLS 			= TRUE

mob/var
	sparring_mode						= CASUAL_COMBAT
	sparring_mode_text					= "casual spar"
	combat_ko_total 					= 0				// used to track when KO_SYSTEM_UNCONSCIOUS_KO should enter in effect
	individual_science_items 			= list()		// Allowed science tab items
	player_tech_level               	= 0				// Tech level of this player
	player_tech_paths             		= list()        // Tech Paths of this player
	global_science_items 				= list()		// Needed as otherwise items from the allowed list and global list would be added together
	time_of_press = 0

//#####################################################################################################################

// Deadzone pressure settings
var
	DEADZONE_PRESSURE_ON 							= 1     // True
	DEADZONE_PRESSURE_BPLOSS_RESISTANT_RACE 		= 0.85
	DEADZONE_PRESSURE_BPLOSS_LIVING 				= 0.75
	DEADZONE_PRESSURE_BPLOSS_KEEPBODY 				= 0.7
	DEADZONE_PRESSURE_BPLOSS_DEAD 					= 0.3

	DEADZONE_PRESSURE_BPLOSS_IMMUNE_RACES			= list("Demon", "Android")
	DEADZONE_PRESSURE_BPLOSS_RESISTANT_RACES		= list("Kai", "Demigod")

// Limit break mastery settings

var
	CAN_MASTER_LIMIT_BREAK 				= 1		// true
	LIMIT_BREAK_MAX_MASTERY 			= 600	// 60 seconds
	LIMIT_BREAK_MIN_DURATION 			= 1		// starts at 5 seconds, goes up to 60 seconds
	LIMIT_BREAK_MAX_DURATION 			= 2		// starts at 10 seconds, goes up to 120 seconds
mob/var
	limit_break_mastery 						= 50


mob/var
	stamina = 100
	max_stamina = 100
	base_bp=1
	bp_mod=1
	Str=100
	End=100
	Spd=100
	Eff=1
	Pow=100
	Res=100
	Off=100
	Def=100
	regen=1
	recov=1
	max_ki=80
	gravity_mastered=1
	Age=0
	Decline=50
	real_age=0
	Race
	Class
	BP=1
	bp_mult=1
	strmod=1
	endmod=1
	spdmod=1
	formod=1
	resmod=1
	offmod=1
	defmod=1
	anger=100
	max_anger=100
	sp_mod=1
	mastery_mod=1
	Ki=10
	mental_power=100
	Immortal=0
	Body=1
	Tech=1
	hair
	ssjhair
	ssjfphair
	ussjhair
	ssj2hair
	ssj3hair
	HairColor
	BPpcnt=100
	displaykey
	Lungs=0
	leech_rate=1
	zenkai_mod=1
	med_mod=1
	Intelligence=0.1
	Demonic
	stun_resistance_mod=1
	ascension_bp=1000000
	is_ctrl_down 		= 0
	is_alt_down 		= 0
	is_shift_down 		= 0
	last_music_stream_time

