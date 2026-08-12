#define NEXUS_PLAYTEST_REWARD_VERSION 1
#define NEXUS_PLAYTEST_ACTION_COOLDOWN 20
#define NEXUS_PLAYTEST_RESOURCE_REWARD 50000000
#define NEXUS_PLAYTEST_ARCANE_ESSENCE_REWARD 5000
#define NEXUS_PLAYTEST_PROGRESSION_REWARD 100000
#define NEXUS_PLAYTEST_ABSOLUTE_BP_CAP 10000000000000

var/nexus_runtime_environment = "live"
var/nexus_runtime_environment_locked = FALSE
var/nexus_playtest_rewards_enabled = FALSE

proc/normalizeNexusRuntimeEnvironment(value)
	if(!istext(value)) return "live"
	return lowertext(value) == "playtest" ? "playtest" : "live"

proc/isNexusPlaytestRuntime()
	return nexus_runtime_environment_locked && nexus_runtime_environment == "playtest"

proc/isNexusPlaytestEnabledValue(value)
	if(isnum(value)) return value == 1
	if(!istext(value)) return FALSE
	return lowertext(value) in list("1", "true", "yes", "on")

proc/configureNexusPlaytestRewards()
	if(nexus_runtime_environment_locked) return
	nexus_runtime_environment = normalizeNexusRuntimeEnvironment(world.params["nexus_environment"])
	nexus_runtime_environment_locked = TRUE
	var/rewards_requested = isNexusPlaytestEnabledValue(world.params["nexus_playtest_rewards"])
	nexus_playtest_rewards_enabled = nexus_runtime_environment == "playtest" && rewards_requested
	for(var/mob/player in players)
		player.syncNexusPlaytestVerbs()
	if(nexus_playtest_rewards_enabled)
		world.log << "NEXUS_PLAYTEST_REWARDS enabled_by=world_param environment=playtest"
	else if(rewards_requested)
		world.log << "NEXUS_PLAYTEST_REWARDS refused reason=live_environment"

proc/getNexusPlaytestStrongestRelativeBaseBP()
	var/strongest_relative_bp = nexusIsFiniteNumber(highest_relative_base_bp) && highest_relative_base_bp > 0 ? highest_relative_base_bp : 1
	for(var/mob/player in players)
		if(!player.client || !player.playerCharacter) continue
		if(!nexusIsFiniteNumber(player.base_bp) || !nexusIsFiniteNumber(player.bp_mod) || player.base_bp < 0 || player.bp_mod <= 0) continue
		strongest_relative_bp = max(strongest_relative_bp, player.base_bp / player.bp_mod)
	return min(strongest_relative_bp, NEXUS_PLAYTEST_ABSOLUTE_BP_CAP)

mob/var
	nexus_playtest_currency_reward_version = 0
	nexus_playtest_progression_reward_version = 0
	tmp/nexus_playtest_last_action = -NEXUS_PLAYTEST_ACTION_COOLDOWN

mob/proc/syncNexusPlaytestVerbs()
	verbs -= typesof(/mob/NexusPlaytestVerbs/verb)
	if(isNexusPlaytestRuntime() && nexus_playtest_rewards_enabled && client && playerCharacter)
		verbs += typesof(/mob/NexusPlaytestVerbs/verb)

mob/proc/canUseNexusPlaytestRewardVerb()
	if(!isNexusPlaytestRuntime() || !nexus_playtest_rewards_enabled || !client || !playerCharacter || usr != src)
		return FALSE
	if(world.time < nexus_playtest_last_action + NEXUS_PLAYTEST_ACTION_COOLDOWN)
		src << "Please wait before using another playtest reward."
		return FALSE
	nexus_playtest_last_action = world.time
	return TRUE

mob/proc/noteNexusPlaytestReward(action)
	world.log << "NEXUS_PLAYTEST_REWARD account=[ckey(key)] slot=[active_character_slot] action=[action]"

mob/proc/claimNexusPlaytestCurrencies(announce = TRUE)
	if(nexus_playtest_currency_reward_version >= NEXUS_PLAYTEST_REWARD_VERSION)
		if(announce) src << "This character has already claimed the playtest Resources and Arcane Essence reward."
		return FALSE
	var/obj/Resources/resources = GetResourceObject()
	if(!resources)
		resources = new /obj/Resources(src)
		resource_obj = resources
	if(!nexusIsFiniteNumber(resources.Value) || resources.Value < 0) SetRes(0)
	Alter_Res(NEXUS_PLAYTEST_RESOURCE_REWARD)
	if(!nexusIsFiniteNumber(arcane_essence) || arcane_essence < 0) arcane_essence = 0
	if(!nexusIsFiniteNumber(arcane_essence_lifetime) || arcane_essence_lifetime < arcane_essence) arcane_essence_lifetime = arcane_essence
	arcane_essence += NEXUS_PLAYTEST_ARCANE_ESSENCE_REWARD
	arcane_essence_lifetime += NEXUS_PLAYTEST_ARCANE_ESSENCE_REWARD
	nexus_playtest_currency_reward_version = NEXUS_PLAYTEST_REWARD_VERSION
	if(announce) src << "Playtest reward claimed: [Commas(NEXUS_PLAYTEST_RESOURCE_REWARD)] Resources and [Commas(NEXUS_PLAYTEST_ARCANE_ESSENCE_REWARD)] Arcane Essence."
	return TRUE

mob/proc/claimNexusPlaytestProgression(announce = TRUE)
	if(nexus_playtest_progression_reward_version >= NEXUS_PLAYTEST_REWARD_VERSION)
		if(announce) src << "This character has already claimed the playtest Progression XP reward."
		return FALSE
	if(!nexusIsFiniteNumber(progression_experience) || progression_experience < 0) progression_experience = 0
	if(!nexusIsFiniteNumber(progression_lifetime_experience) || progression_lifetime_experience < progression_experience) progression_lifetime_experience = progression_experience
	migrateProgressionExperienceScale()
	gainProgressionExperience(NEXUS_PLAYTEST_PROGRESSION_REWARD, "playtest reward", announce = announce)
	nexus_playtest_progression_reward_version = NEXUS_PLAYTEST_REWARD_VERSION
	return TRUE

mob/proc/claimNexusPlaytestMilestones(announce = TRUE)
	normalizeMilestonePointBalances()
	var/granted = grantMilestonePoints(NEXUS_MILESTONE_POINT_CAP - total_milestone_points, "playtest reward", announce = FALSE)
	if(announce)
		if(granted) src << "Playtest reward claimed: [granted] Milestone Point[granted == 1 ? "" : "s"] (lifetime cap [NEXUS_MILESTONE_POINT_CAP])."
		else src << "This character is already at the lifetime cap of [NEXUS_MILESTONE_POINT_CAP] Milestone Points."
	return granted > 0

mob/proc/applyNexusPlaytestStatCap(stat_cap)
	if(!nexusIsFiniteNumber(stat_cap) || stat_cap <= 0 || !nexusIsFiniteNumber(Modless_Gain) || Modless_Gain <= 0) return FALSE
	if(!nexusIsFiniteNumber(Eff) || Eff <= 0 || !nexusIsFiniteNumber(energy_cap) || energy_cap <= 0) return FALSE
	var/list/stat_modifiers = list(strmod, endmod, spdmod, formod, resmod, offmod, defmod)
	for(var/stat_modifier in stat_modifiers)
		if(!nexusIsFiniteNumber(stat_modifier) || stat_modifier <= 0) return FALSE
	var/normalized_cap = min(stat_cap, NEXUS_PLAYTEST_ABSOLUTE_BP_CAP)
	Str = max(nexusIsFiniteNumber(Str) && Str >= 0 ? Str : 0, normalized_cap * strmod * Modless_Gain)
	End = max(nexusIsFiniteNumber(End) && End >= 0 ? End : 0, normalized_cap * endmod * Modless_Gain)
	Spd = max(nexusIsFiniteNumber(Spd) && Spd >= 0 ? Spd : 0, normalized_cap * spdmod * Modless_Gain)
	Pow = max(nexusIsFiniteNumber(Pow) && Pow >= 0 ? Pow : 0, normalized_cap * formod * Modless_Gain)
	Res = max(nexusIsFiniteNumber(Res) && Res >= 0 ? Res : 0, normalized_cap * resmod * Modless_Gain)
	Off = max(nexusIsFiniteNumber(Off) && Off >= 0 ? Off : 0, normalized_cap * offmod * Modless_Gain)
	Def = max(nexusIsFiniteNumber(Def) && Def >= 0 ? Def : 0, normalized_cap * defmod * Modless_Gain)
	var/target_max_ki = min(energy_cap * Eff, NEXUS_PLAYTEST_ABSOLUTE_BP_CAP)
	max_ki = max(nexusIsFiniteNumber(max_ki) && max_ki >= 0 ? max_ki : 0, target_max_ki)
	Ki = max_ki
	return TRUE

mob/proc/capNexusPlaytestStats(announce = TRUE)
	var/list/stat_modifiers = list(strmod, endmod, spdmod, formod, resmod, offmod, defmod, Modless_Gain)
	for(var/stat_modifier in stat_modifiers)
		if(!nexusIsFiniteNumber(stat_modifier) || stat_modifier <= 0)
			if(announce) src << "Your combat stats could not be capped because the character has invalid stat modifiers."
			return FALSE
	var/current_average = Stat_Avg()
	if(!nexusIsFiniteNumber(current_average) || current_average < 0) current_average = 1
	var/server_cap = nexusIsFiniteNumber(Stat_Record) && Stat_Record > 0 ? Stat_Record : 1
	var/stat_cap = max(1, server_cap, current_average)
	if(!applyNexusPlaytestStatCap(stat_cap))
		if(announce) src << "Your combat stats could not be capped because the character has invalid stat modifiers."
		return FALSE
	if(announce) src << "Your seven combat stats now meet the current server cap of [Commas(round(stat_cap))], and Energy is capped at [Commas(round(max_ki / Eff))]."
	return TRUE

mob/proc/applyNexusPlaytestRelativeBaseBP(relative_cap, announce = TRUE)
	if(!nexusIsFiniteNumber(relative_cap) || relative_cap <= 0 || !nexusIsFiniteNumber(bp_mod) || bp_mod <= 0) return FALSE
	var/target_bp = Clamp(relative_cap * bp_mod, 1, NEXUS_PLAYTEST_ABSOLUTE_BP_CAP)
	if(Race == "Android" || Android)
		base_bp = 1
		cyber_bp = max(nexusIsFiniteNumber(cyber_bp) ? cyber_bp : 0, target_bp)
		Record_cyber_bp = max(nexusIsFiniteNumber(Record_cyber_bp) ? Record_cyber_bp : 0, cyber_bp)
		if(announce) src << "Your cybernetic BP now matches the strongest base BP recorded this wipe."
	else
		base_bp = max(nexusIsFiniteNumber(base_bp) ? base_bp : 1, target_bp)
		highest_bp_ever_had = max(nexusIsFiniteNumber(highest_bp_ever_had) ? highest_bp_ever_had : 1, base_bp)
		if(announce) src << "Your base BP now matches the strongest base BP recorded this wipe at [Commas(round(base_bp))]."
	last_bp_get_time = world.time - 10
	BP = get_bp()
	return TRUE

mob/proc/saveNexusPlaytestRewardState()
	if(isNexusPlaytestRuntime() && key && displaykey && Savable) save()

mob/NexusPlaytestVerbs/verb
	claimPlaytestRewards()
		set name = "Claim Playtest Rewards"
		set category = "Playtest"
		if(!canUseNexusPlaytestRewardVerb()) return
		var/changed = claimNexusPlaytestCurrencies()
		changed = claimNexusPlaytestProgression() || changed
		changed = claimNexusPlaytestMilestones() || changed
		if(changed)
			noteNexusPlaytestReward("bundle")
			saveNexusPlaytestRewardState()

	claimPlaytestCurrencies()
		set name = "Claim Resources and Mana"
		set category = "Playtest"
		if(!canUseNexusPlaytestRewardVerb()) return
		if(claimNexusPlaytestCurrencies())
			noteNexusPlaytestReward("currencies")
			saveNexusPlaytestRewardState()

	claimPlaytestProgression()
		set name = "Claim Progression Points"
		set category = "Playtest"
		if(!canUseNexusPlaytestRewardVerb()) return
		if(claimNexusPlaytestProgression())
			noteNexusPlaytestReward("progression")
			saveNexusPlaytestRewardState()

	claimPlaytestMilestones()
		set name = "Claim Milestone Points"
		set category = "Playtest"
		if(!canUseNexusPlaytestRewardVerb()) return
		if(claimNexusPlaytestMilestones())
			noteNexusPlaytestReward("milestones")
			saveNexusPlaytestRewardState()

	capPlaytestStats()
		set name = "Cap Combat Stats"
		set category = "Playtest"
		if(!canUseNexusPlaytestRewardVerb()) return
		if(capNexusPlaytestStats())
			noteNexusPlaytestReward("stat_cap")
			saveNexusPlaytestRewardState()

	matchPlaytestBaseBP()
		set name = "Match Strongest Base BP"
		set category = "Playtest"
		if(!canUseNexusPlaytestRewardVerb()) return
		if(applyNexusPlaytestRelativeBaseBP(getNexusPlaytestStrongestRelativeBaseBP()))
			noteNexusPlaytestReward("base_bp_cap")
			saveNexusPlaytestRewardState()

mob/Admin4/verb/toggleNexusPlaytestRewards()
	set name = "Toggle Playtest Rewards"
	set category = "Admin"
	if(AdminLevel() < 4) return
	if(!isNexusPlaytestRuntime())
		src << "Playtest rewards cannot be enabled in a live runtime. Restart an isolated runtime with nexus_environment=playtest."
		return
	nexus_playtest_rewards_enabled = !nexus_playtest_rewards_enabled
	for(var/mob/player in players)
		player.syncNexusPlaytestVerbs()
	admin_blame(src, "[key] [nexus_playtest_rewards_enabled ? "enabled" : "disabled"] self-service playtest rewards.", TRUE)

mob/NexusPlaytestRewardSmoke
	New()
		return

proc/runNexusPlaytestRewardSmokeTests()
	nexusSmokeAssert(isNexusPlaytestEnabledValue(1) && isNexusPlaytestEnabledValue("TRUE") && !isNexusPlaytestEnabledValue(2) && !isNexusPlaytestEnabledValue("enabled"), "playtest reward launch flag is not fail-closed")
	nexusSmokeAssert(normalizeNexusRuntimeEnvironment("PLAYTEST") == "playtest" && normalizeNexusRuntimeEnvironment("staging") == "live", "playtest runtime environment normalization is not fail-closed")
	nexusSmokeAssert(NEXUS_MILESTONE_POINT_CAP == 22 && typesof(/mob/NexusPlaytestVerbs/verb).len == 6, "playtest reward cap or verb catalog is incomplete")
	nexusSmokeAssert(parseNexusHostKeyFile("Exact Host") == "exacthost" && parseNexusHostKeyFile("Bobby") != "bob" && isnull(parseNexusHostKeyFile("First Host\nSecond Host")), "HostKeys parsing permits substring or multi-key privilege escalation")
	nexusSmokeAssert(normalizeNexusCountdownSeconds(30) == 30 && normalizeNexusCountdownSeconds(1000) == 600 && !normalizeNexusCountdownSeconds(-1) && !normalizeNexusCountdownSeconds(1.#INF), "public countdown duration validation is not finite and bounded")
	var/safe_countdown_text = sanitizeNexusCountdownText("<script>alert(1)</script>")
	nexusSmokeAssert(safe_countdown_text && !findtext(safe_countdown_text, "<script>"), "public countdown text is not HTML-escaped")
	var/obj/Buff/buff_security_test = new
	nexusSmokeAssert(buff_security_test.adjustNexusCustomBuffStat("buff_str", -1) && round(buff_security_test.buff_str * 10) == 9 && buff_security_test.points == 1, "custom buff point exchange cannot create its bounded credit")
	nexusSmokeAssert(!buff_security_test.adjustNexusCustomBuffStat("points", -1) && buff_security_test.points == 1, "custom buff point exchange accepts an attacker-authored variable name")
	nexusSmokeAssert(buff_security_test.adjustNexusCustomBuffStat("buff_str", 1) && round(buff_security_test.buff_str * 10) == 10 && buff_security_test.points == 0, "custom buff point exchange cannot spend a legitimate credit")
	buff_security_test.buff_dur = 1000000
	buff_security_test.points = 1000000
	buff_security_test.normalizeNexusCustomBuffStats()
	nexusSmokeAssert(buff_security_test.buff_dur == 2 && buff_security_test.points == NEXUS_CUSTOM_BUFF_POINT_CAP, "legacy custom buff values are not normalized to hard caps")
	del(buff_security_test)
	var/mob/NexusPlaytestRewardSmoke/reward_test = new
	new /obj/Resources(reward_test)
	nexusSmokeAssert(reward_test.claimNexusPlaytestCurrencies(FALSE) && reward_test.Res() == NEXUS_PLAYTEST_RESOURCE_REWARD && reward_test.arcane_essence == NEXUS_PLAYTEST_ARCANE_ESSENCE_REWARD, "playtest currency claim did not grant its fixed server-authored bundle")
	nexusSmokeAssert(!reward_test.claimNexusPlaytestCurrencies(FALSE) && reward_test.Res() == NEXUS_PLAYTEST_RESOURCE_REWARD, "playtest currency claim can be repeated on one character")
	nexusSmokeAssert(reward_test.claimNexusPlaytestProgression(FALSE) && reward_test.progression_experience == NEXUS_PLAYTEST_PROGRESSION_REWARD, "playtest progression claim did not grant its fixed reward")
	nexusSmokeAssert(!reward_test.claimNexusPlaytestProgression(FALSE) && reward_test.progression_experience == NEXUS_PLAYTEST_PROGRESSION_REWARD, "playtest progression claim can be repeated on one character")
	reward_test.milestone_points = 3
	reward_test.total_milestone_points = 20
	nexusSmokeAssert(reward_test.claimNexusPlaytestMilestones(FALSE) && reward_test.milestone_points == 5 && reward_test.total_milestone_points == NEXUS_MILESTONE_POINT_CAP, "playtest Milestone claim did not stop at the lifetime cap")
	nexusSmokeAssert(!reward_test.claimNexusPlaytestMilestones(FALSE) && reward_test.total_milestone_points == NEXUS_MILESTONE_POINT_CAP, "playtest Milestone claim exceeded the lifetime cap")
	reward_test.Str = 1
	reward_test.End = 1
	reward_test.Spd = 1
	reward_test.Pow = 1
	reward_test.Res = 1
	reward_test.Off = 1
	reward_test.Def = 1
	reward_test.Eff = 1.5
	reward_test.max_ki = 100
	reward_test.Ki = 25
	nexusSmokeAssert(reward_test.applyNexusPlaytestStatCap(100) && reward_test.Str == 100 && reward_test.Def == 100, "playtest stat cap did not apply the normalized server cap")
	nexusSmokeAssertNear(reward_test.max_ki, energy_cap * reward_test.Eff, 0.001, "playtest stat cap did not apply the Efficiency-scaled Energy cap")
	nexusSmokeAssert(reward_test.Ki == reward_test.max_ki, "playtest stat cap did not refill Energy after raising its cap")
	reward_test.bp_mod = 2
	nexusSmokeAssert(reward_test.applyNexusPlaytestRelativeBaseBP(100, FALSE) && reward_test.base_bp == 200, "playtest base BP matching ignored the character BP modifier")
	reward_test.Race = "Android"
	reward_test.Android = TRUE
	reward_test.base_bp = 50
	nexusSmokeAssert(reward_test.applyNexusPlaytestRelativeBaseBP(150, FALSE) && reward_test.base_bp == 1 && reward_test.cyber_bp == 300, "Android playtest BP matching did not use cybernetic BP")
	del(reward_test)
