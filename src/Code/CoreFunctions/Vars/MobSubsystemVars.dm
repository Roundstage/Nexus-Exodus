mob/var/
	icer_form1_mult=0.1
	icer_form2_mult=0.2
	icer_form3_mult=0.3
	icer_form4_mult=0.6

// Global settings that affect RP ##############################################################################

mob/var/list/energies = list()
mob/var/energy_save_version

mob/var
	times_used_t_heal 					= 0				// Used to handle repeated instances of t_heal
	last_t_heal_use	 					= 0				// So we can reset the times_used_t_heal
	last_sensu_use	 					= 0				
mob/var
	sparring_mode						= CASUAL_COMBAT
	sparring_mode_text					= "casual spar"
	combat_ko_total 					= 0				// used to track when KO_SYSTEM_UNCONSCIOUS_KO should enter in effect
	individual_science_items 			= list()		// Allowed science tab items
	player_tech_level               	= 0				// Tech level of this player
	player_tech_paths             		= list()        // Tech Paths of this player
	global_science_items 				= list()		// Needed as otherwise items from the allowed list and global list would be added together
	time_of_press = 0

mob/var
	limit_break_mastery 						= 50

mob/var/tmp/playerCharacter //whether this mob is a loaded in player character
mob/var/majin_stat_version=0
mob/var/stat_version=0
mob/var/Mob_ID=0
mob/var/character_made_time = 0
mob/var/bp_mod_Leechable=1
