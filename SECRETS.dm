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
    This is the hardcoded admins.

    Host computer is level 4 by default.

    Admins may be added in-game, and they will be saved to the ADMINS.sav file.

    Don't forget to add a comma to the end of every level, otherwise the list will not compile.

    Format:
        CKEY = LEVEL
    Example:
        VeryCoolAdmin   = ADMIN_HIGHEST_LEVEL,
        CoolAdmin       = ADMIN_HEAD_LEVEL
*/

var/list/coded_admins = list(
    "Roundstage"  = 5,
    "TheirNameHere" = 0
    )

