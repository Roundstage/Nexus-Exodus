#define HERAN_TRANSFORMATION_SSJ_MULTIPLIER 1.35
#define HERAN_TRANSFORMATION_MAX_MASTERY 300

mob/var
	heran_transformed
	heran_transformation_at = 1
	heran_transformation_bp_add
	heran_transformation_mastery = 150
	heran_transformation_full_power
	heran_transformation_started_at
	icon/heran_base_icon
	tmp/heran_transformation_drain_looping

obj/HeranTransformation
	name = "Heran Transformation"
	desc = "Unleash a temporary Heran power surge equal to a standard Super Saiyan. The entire gain is additive BP and never exceeds the equivalent Super Saiyan form. Mastering the form removes its Energy upkeep."
	Skill = 1
	teachable = 0
	race_teach_only = 1
	hotbar_type = "Transformation"
	can_hotbar = 1
	icon = 'src/Icons/PlayerIcons/BaseIcons/Heran/HeranBojack.dmi'

	verb/Hotbar_use()
		set waitfor = 0
		set hidden = 1
		toggleHeranTransformation()

	verb/toggleHeranTransformation()
		set name = "Heran Transformation"
		set category = "Skills"
		if(usr.heran_transformed)
			usr.revertHeranTransformation()
			return
		if(!usr.requestPrimaryTransformation("heran_transformation"))
			usr << "You need roughly [Commas(usr.heran_transformation_at)] available BP and half of that as effective base BP to awaken this transformation."

mob/proc/ensureHeranTransformation()
	if(Race != "Heran") return null
	if(heran_transformation_at <= 1) heran_transformation_at = rand(800000, 1200000)
	var/obj/HeranTransformation/kept_transformation
	for(var/obj/HeranTransformation/transformation in contents)
		if(!kept_transformation)
			kept_transformation = transformation
		else
			del(transformation)
	if(!kept_transformation) kept_transformation = new(src)
	return kept_transformation

mob/proc/hasHeranTransformationReq()
	if(Race != "Heran") return FALSE
	if(bp_tiers) return TRUE
	var/bp_needed = heran_transformation_at * 0.5
	return BP > heran_transformation_at && effectiveBaseBp > bp_needed

mob/proc/getHeranTransformationEquivalentBPAdd()
	return getHeranTransformationNaturalBPAdd() + getHeranTransformationStaticBPAdd()

mob/proc/getHeranTransformationNaturalBPAdd()
	var/natural_bp = max(base_bp + hbtc_bp + unlockedBP, 1)
	return natural_bp * (HERAN_TRANSFORMATION_SSJ_MULTIPLIER - 1)

mob/proc/getHeranTransformationStaticBPAdd()
	var/static_add = getSsjTierOneBasePowerAdd()
	if(heran_transformation_full_power && heran_transformation_mastery >= HERAN_TRANSFORMATION_MAX_MASTERY)
		static_add += getSsjFullPowerAdd()
	return max(static_add, 0)

mob/proc/getActiveHeranTransformationBPAdd()
	if(!heran_transformed) return 0
	var/equivalent_cap = getHeranTransformationEquivalentBPAdd()
	heran_transformation_bp_add = equivalent_cap
	return equivalent_cap

mob/proc/getHeranTransformationIcon()
	if(gender == "female") return 'src/Icons/PlayerIcons/BaseIcons/Heran/HeranBojackFemale.dmi'
	return 'src/Icons/PlayerIcons/BaseIcons/Heran/HeranBojack.dmi'

mob/proc/activateHeranTransformation(show_effects = TRUE)
	if(heran_transformed || transing || Race != "Heran") return FALSE
	if(!hasHeranTransformationReq()) return FALSE
	preparePrimaryTransformation("heran_transformation")
	transing = TRUE
	heran_base_icon = icon
	heran_transformed = TRUE
	heran_transformation_started_at = world.realtime
	if(show_effects) Old_Trans_Graphics()
	icon = getHeranTransformationIcon()
	heran_transformation_bp_add = getHeranTransformationEquivalentBPAdd()
	last_bp_get_time = 0
	transing = FALSE
	player_view(15, src) << "[src] unleashes the power of the Herans!"
	heranTransformationDrainLoop()
	syncActivePrimaryTransformation("Heran enabled")
	return TRUE

mob/proc/revertHeranTransformation(announce = TRUE, sync_state = TRUE)
	if(!heran_transformed)
		heran_transformation_bp_add = 0
		return FALSE
	heran_transformed = FALSE
	heran_transformation_bp_add = 0
	heran_transformation_started_at = 0
	if(heran_base_icon) icon = heran_base_icon
	heran_base_icon = null
	last_bp_get_time = 0
	if(powerup_obj && powerup_obj.Powerup == -1) powerup_obj.Powerup = 0
	if(announce) player_view(15, src) << "[src] returns to their base form."
	if(sync_state) syncActivePrimaryTransformation("Heran reverted")
	return TRUE

mob/proc/normalizeHeranTransformation()
	if(Race != "Heran")
		if(heran_transformed) revertHeranTransformation(FALSE, FALSE)
		return
	ensureHeranTransformation()
	if(!heran_transformed)
		heran_transformation_bp_add = 0
		heran_base_icon = null
		return
	if(!heran_base_icon) heran_base_icon = icon
	icon = getHeranTransformationIcon()
	heran_transformation_bp_add = getHeranTransformationEquivalentBPAdd()
	if(!heran_transformation_started_at) heran_transformation_started_at = world.realtime
	heranTransformationDrainLoop()

mob/proc/heranTransformationDrainLoop()
	set waitfor = 0
	if(heran_transformation_drain_looping) return
	heran_transformation_drain_looping = TRUE
	while(src && heran_transformed)
		var/amount = 3
		var/mastery_gain = 0.01 * amount * SSj_Mastery
		if(z == Z_LEVEL_HBTC || (world.maxz == 2 && z == 2)) mastery_gain *= 10
		if(hero == key) mastery_gain *= 2
		var/old_mastery = heran_transformation_mastery
		heran_transformation_mastery = min(heran_transformation_mastery + mastery_gain, HERAN_TRANSFORMATION_MAX_MASTERY)
		if(world.realtime - heran_transformation_started_at > 15 * 600)
			heran_transformation_mastery = HERAN_TRANSFORMATION_MAX_MASTERY
			heran_transformation_full_power = TRUE
		if(heran_transformation_mastery >= HERAN_TRANSFORMATION_MAX_MASTERY && old_mastery < HERAN_TRANSFORMATION_MAX_MASTERY)
			heran_transformation_full_power = TRUE
			heran_transformation_bp_add = getHeranTransformationEquivalentBPAdd()
			NoWaitAlert("You have mastered the Heran Transformation.")
		var/drain = 0
		if(heran_transformation_mastery < HERAN_TRANSFORMATION_MAX_MASTERY)
			var/safe_max_ki = max(max_ki, 1)
			drain = (safe_max_ki / max(heran_transformation_mastery, 1)) * (0.3 * amount) * (3500 / safe_max_ki) ** 0.4
		if(drain && Ki > drain * 10)
			Ki -= drain
		else if(drain)
			revertHeranTransformation()
			player_view(15, src) << "[src] reverts due to exhaustion."
		sleep(amount * 10)
	heran_transformation_drain_looping = FALSE

mob/proc/Heran(interactive_options = 1)
	Race = "Heran"
	Class = "Space Pirate"
	incline_age = 10
	incline_mod = 0.35
	Gravity_Mod = 1.2
	sp_mod = 1.2
	mastery_mod = 1.7
	bp_mod = Get_race_starting_bp_mod()
	Decline = 45
	Decline_Rate = 1
	Intelligence = 0.6
	knowledge_cap_rate = 0.9
	Regenerate = 0.1
	Lungs = 0
	leech_rate = 2.5
	med_mod = 1.4
	zenkai_mod = 1
	gravity_mastered = 12
	base_bp = rand(90, 130)
	heran_transformation_at = rand(800000, 1200000)
	ascension_bp *= 0.95
	stun_resistance_mod = 1.8
	if(interactive_options)
		alert(src, "Herans are durable space pirates who favor strength, pressure, and combat growth over technical or mystical development.")
	if(START_WITH_RACIAL_SKILLS)
		contents.Add(new /obj/Attacks/Blast, new /obj/Attacks/Charge, new /obj/Fly, new /obj/Dash_Attack)
	ensureHeranTransformation()

#undef HERAN_TRANSFORMATION_SSJ_MULTIPLIER
#undef HERAN_TRANSFORMATION_MAX_MASTERY
