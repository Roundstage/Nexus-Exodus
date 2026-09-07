// Copy this file to SECRETS.dm for local builds.
// SECRETS.dm is ignored by Git and must never be committed.

// Hub info
var
	const
		SECRETS_HUB_NAME        = ""
		SECRETS_HUB_PASSWORD    = ""

		SECRETS_VERSION         = "V35"

// Admin levels
var
	const
		ADMIN_HIGHEST_LEVEL     = 5
		ADMIN_HEAD_LEVEL        = 4
		ADMIN_LEVEL             = 3
		ADMIN_MOD_LEVEL         = 2
		ADMIN_HELPER_LEVEL      = 1

/*
	Admins may be added in-game and are saved to ADMINS.sav.
	Keep real hardcoded admin identities only in the ignored SECRETS.dm file.
*/
var/list/coded_admins = list(
	"TheirNameHere" = 0
	)
