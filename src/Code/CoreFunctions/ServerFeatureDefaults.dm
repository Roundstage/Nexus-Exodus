var/const/NEXUS_SERVER_FEATURE_DEFAULTS_VERSION = 1
var/const/NEXUS_DEFAULT_NPCS_ENABLED = 0
var/const/NEXUS_DEFAULT_FEATS_ENABLED = 0
var/const/NEXUS_DEFAULT_TOURNAMENT_INTERVAL_MINUTES = 0

var/nexus_server_feature_defaults_version = 0

proc/applyNexusServerFeatureDefaultsMigration()
	if(nexus_server_feature_defaults_version >= NEXUS_SERVER_FEATURE_DEFAULTS_VERSION) return FALSE
	npcs_enabled = NEXUS_DEFAULT_NPCS_ENABLED
	feats_on = NEXUS_DEFAULT_FEATS_ENABLED
	Tournament_Timer = NEXUS_DEFAULT_TOURNAMENT_INTERVAL_MINUTES
	nexus_server_feature_defaults_version = NEXUS_SERVER_FEATURE_DEFAULTS_VERSION
	return TRUE
