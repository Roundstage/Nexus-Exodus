client/authenticate = 0

var
	noPacksOnRP = 0
	classic_ui = 1 //use the classic user interface or not
		//remember to check the right skin file to include so it matches which one we have here
	daynight_enabled = 1
	fireflies = 1

	death_x=170
	death_y=200
	death_z=5


var
	SHOW_CHAR_NAME_ON_WHO 				= FALSE	
	CAN_BREAK_TURFS 					= TRUE
	SENSE_SYSTEM_SHOW_STAT_BUILD 		= FALSE
	SENSE_SYSTEM_SHOW_VAGUE_INFO		= TRUE			// Remove precision from Sense and show vague terms instead
	
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
