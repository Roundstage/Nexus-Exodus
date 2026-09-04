#define VILTRUMITE_OPENING_DURATION 30
#define VILTRUMITE_OPENING_ACCURACY 15
#define VILTRUMITE_STAGGER_WINDOW 60
#define VILTRUMITE_PURSUIT_WINDOW 35

mob/var/tmp
	mob/viltrumite_opening_source
	viltrumite_opening_until
	mob/viltrumite_pursuit_source
	viltrumite_pursuit_until
	viltrumite_stagger_count
	viltrumite_stagger_window_until
	viltrumite_rib_break_until

mob/proc/applyViltrumiteOpening(mob/source, duration_ticks = VILTRUMITE_OPENING_DURATION)
	if(!source || source == src || !source.isViltrumiteRace() || KO || rp_mode) return FALSE
	viltrumite_opening_source = source
	viltrumite_opening_until = world.time + max(1, duration_ticks)
	return TRUE

mob/proc/hasViltrumiteOpeningFrom(mob/source)
	if(!source || viltrumite_opening_source != source || world.time >= viltrumite_opening_until)
		viltrumite_opening_source = null
		viltrumite_opening_until = 0
		return FALSE
	return TRUE

mob/proc/consumeViltrumiteOpening(mob/source)
	if(!hasViltrumiteOpeningFrom(source)) return FALSE
	viltrumite_opening_source = null
	viltrumite_opening_until = 0
	return TRUE

mob/proc/applyViltrumiteStagger(mob/source, base_ticks = 8)
	if(!source || source == src || KO || rp_mode) return 0
	if(world.time >= viltrumite_stagger_window_until)
		viltrumite_stagger_count = 0
	viltrumite_stagger_count++
	viltrumite_stagger_window_until = world.time + VILTRUMITE_STAGGER_WINDOW
	var/stagger_ticks = max(0, round(base_ticks))
	if(viltrumite_stagger_count == 2) stagger_ticks = round(stagger_ticks * 0.5)
	else if(viltrumite_stagger_count >= 3) stagger_ticks = 0
	if(stagger_ticks > 0) ApplyStun(time = stagger_ticks, stun_power = 1.5)
	return stagger_ticks

mob/proc/applyViltrumiteRibBreak(mob/source, duration_ticks = 50)
	if(!source || source == src || KO || rp_mode) return FALSE
	viltrumite_rib_break_until = max(viltrumite_rib_break_until, world.time + max(1, duration_ticks))
	applyViltrumiteStagger(source, 7)
	applyViltrumiteOpening(source)
	src << "<font color=#d9b36c>Your breathing is disrupted; your Energy recovery is reduced for [round(duration_ticks / 10, 0.1)] seconds.</font>"
	return TRUE

mob/proc/getViltrumiteEnergyRecoveryMultiplier()
	return world.time < viltrumite_rib_break_until ? 0.6 : 1

mob/proc/beginViltrumiteTechniqueRecovery(recovery_ticks = 4)
	attacking = 1
	spawn(max(1, recovery_ticks))
		if(src && attacking) Reset_melee()

mob/proc/markViltrumitePursuit(mob/source, duration_ticks = VILTRUMITE_PURSUIT_WINDOW)
	if(!source || source == src) return FALSE
	viltrumite_pursuit_source = source
	viltrumite_pursuit_until = world.time + max(1, duration_ticks)
	return TRUE

mob/proc/canBePursuedByViltrumite(mob/source)
	if(!source || viltrumite_pursuit_source != source || world.time >= viltrumite_pursuit_until)
		viltrumite_pursuit_source = null
		viltrumite_pursuit_until = 0
		return FALSE
	return TRUE

mob/proc/resolveViltrumiteTechniqueHit(mob/target, obj/Attacks/NexusMeleeTechnique/technique, damage_multiplier = 1, force_hit = FALSE, consume_opening = TRUE)
	if(!target || !technique) return FALSE
	var/has_opening = target.hasViltrumiteOpeningFrom(src)
	if(has_opening) technique.accuracy_bonus += VILTRUMITE_OPENING_ACCURACY
	var/hit_landed = resolveNexusTechniqueHit(target, technique, damage_multiplier, force_hit)
	if(has_opening)
		technique.accuracy_bonus -= VILTRUMITE_OPENING_ACCURACY
		if(hit_landed && consume_opening) target.consumeViltrumiteOpening(src)
	return hit_landed

mob/proc/getViltrumiteTechniqueTarget(obj/Attacks/NexusMeleeTechnique/technique, maximum_range = 1, requirement_text)
	if(!technique || !isViltrumiteRace() || !can_melee()) return null
	var/mob/target = getNexusTechniqueTarget(maximum_range)
	if(!canHitNexusTechniqueTarget(target))
		src << (requirement_text ? requirement_text : "Select a valid target within [maximum_range] tiles.")
		return null
	return target

mob/proc/castViltrumiteTechnique(obj/Attacks/NexusMeleeTechnique/technique)
	if(!technique || !isViltrumiteRace())
		if(technique) src << "Only a Viltrumite can use [technique]."
		return FALSE
	switch(technique.behavior)
		if("viltrumite_rush") return castViltrumiteRush(technique)
		if("viltrumite_rib_breaker") return castViltrumiteRibBreaker(technique)
		if("viltrumite_pursuit") return castViltrumitePursuit(technique)
		if("viltrumite_grip") return castViltrumiteGrip(technique)
		if("viltrumite_meteor_drop") return castViltrumiteMeteorDrop(technique)
		if("viltrumite_spear_hand") return castViltrumiteSpearHand(technique)
		if("viltrumite_nolan_combo") return castViltrumiteNolanCombination(technique)
		if("viltrumite_reversal") return activateViltrumitePunishingReversal(technique)
	return FALSE

mob/proc/castViltrumiteRush(obj/Attacks/NexusMeleeTechnique/technique)
	var/mob/target = getViltrumiteTechniqueTarget(technique, technique.dash_range, "Viltrumite Rush requires a target within [technique.dash_range] tiles.")
	if(!target || !payNexusTechniqueCost(technique)) return FALSE
	technique.playCastEffects(src)
	AlterInputDisabled(1)
	attacking = 1
	if(getdist(src, target) > 1) runNexusSkillApproach(target, technique.dash_range * world.icon_size, world.icon_size, 125, 280, 340, 0.3)
	AlterInputDisabled(-1)
	if(!target || getdist(src, target) > 1)
		Reset_melee()
		return FALSE
	dir = get_dir(src, target)
	var/impact_direction = get_dir(src, target)
	var/turf/impact_turf = get_step(target, impact_direction)
	var/hits_wall = !impact_turf || impact_turf.density
	var/hit_landed = resolveViltrumiteTechniqueHit(target, technique)
	if(hit_landed && target)
		target.applyViltrumiteOpening(src)
		target.markViltrumitePursuit(src)
		if(hits_wall) target.applyViltrumiteStagger(src, 8)
	Reset_melee()
	return hit_landed

mob/proc/castViltrumiteRibBreaker(obj/Attacks/NexusMeleeTechnique/technique)
	var/mob/target = getViltrumiteTechniqueTarget(technique, 1, "Rib Breaker requires an adjacent target.")
	if(!target || !payNexusTechniqueCost(technique)) return FALSE
	technique.playCastEffects(src)
	beginViltrumiteTechniqueRecovery(4)
	dir = get_dir(src, target)
	var/hit_landed = resolveViltrumiteTechniqueHit(target, technique)
	if(hit_landed && target) target.applyViltrumiteRibBreak(src)
	return hit_landed

mob/proc/castViltrumitePursuit(obj/Attacks/NexusMeleeTechnique/technique)
	var/mob/target = getViltrumiteTechniqueTarget(technique, technique.dash_range, "Relentless Pursuit requires a recently launched target within [technique.dash_range] tiles.")
	if(!target || !target.canBePursuedByViltrumite(src))
		src << "That target has not been launched by you recently."
		return FALSE
	if(!payNexusTechniqueCost(technique)) return FALSE
	technique.playCastEffects(src)
	target.viltrumite_pursuit_source = null
	target.viltrumite_pursuit_until = 0
	AlterInputDisabled(1)
	var/motion_result = runNexusSkillApproach(target, technique.dash_range * world.icon_size, world.icon_size, 135, 310, 380, 0.25)
	AlterInputDisabled(-1)
	if(motion_result == NEXUS_SKILL_MOTION_REACHED && target && getdist(src, target) <= 1)
		dir = get_dir(src, target)
		return TRUE
	return FALSE

mob/proc/castViltrumiteGrip(obj/Attacks/NexusMeleeTechnique/technique)
	var/mob/target = getViltrumiteTechniqueTarget(technique, 1, "Conqueror's Grip requires an adjacent target.")
	if(!target || grabbedObject || !canGrabMovable(target) || target.Shielding() || target.Prisoner() || tournament_override(fighters_can = 1)) return FALSE
	if(!payNexusTechniqueCost(technique)) return FALSE
	technique.playCastEffects(src)
	beginViltrumiteTechniqueRecovery(4)
	dir = get_dir(src, target)
	var/was_blocking = target.blocking || target.hasNexusStance("block")
	var/hit_landed = resolveViltrumiteTechniqueHit(target, technique)
	if(!hit_landed || was_blocking || !target || !canGrabMovable(target)) return hit_landed
	grabbedObject = target
	target.grabber = src
	target.grabbed_from_behind = target.dir == dir
	target.applyViltrumiteOpening(src)
	player_view(15, src) << "<font color=#d9b36c>[src] locks [target] in a crushing Viltrumite grip!</font>"
	spawn() Update_grab_loop()
	return TRUE

mob/proc/castViltrumiteMeteorDrop(obj/Attacks/NexusMeleeTechnique/technique)
	if(!grabbedObject || !ismob(grabbedObject))
		src << "Meteor Drop requires a grabbed opponent."
		return FALSE
	var/mob/target = grabbedObject
	if(target.grabber != src || !canHitNexusTechniqueTarget(target) || !canUseNexusGrappleTechnique() || !payNexusTechniqueCost(technique)) return FALSE
	technique.playCastEffects(src)
	attacking = 1
	move = 0
	animate(src, pixel_y = 32, time = 4)
	animate(target, pixel_y = 32, time = 4)
	sleep(4)
	animate(target, transform = turn(matrix(), 180), pixel_y = 48, time = 3)
	sleep(3)
	animate(target, transform = null, pixel_y = 0, time = 2)
	var/hit_landed = resolveViltrumiteTechniqueHit(target, technique, force_hit = TRUE)
	ReleaseGrab()
	if(target)
		Make_Shockwave(target, sw_icon_size = 192)
		target.applyViltrumiteStagger(src, 8)
		target.applyViltrumiteOpening(src)
	animate(src, pixel_y = 0, time = 2)
	move = 1
	Reset_melee()
	return hit_landed

mob/proc/castViltrumiteSpearHand(obj/Attacks/NexusMeleeTechnique/technique)
	var/mob/target = getViltrumiteTechniqueTarget(technique, 1, "Spear Hand requires an adjacent target.")
	if(!target || !payNexusTechniqueCost(technique)) return FALSE
	technique.playCastEffects(src)
	beginViltrumiteTechniqueRecovery(5)
	dir = get_dir(src, target)
	var/executioner = sparring_mode == LETHAL_COMBAT && (target.KO || target.Health <= 15) && (locate(/obj/ViltrumiteExecutionersHand) in src)
	var/original_damage = technique.damage_multiplier
	var/original_bleed = technique.bleed_fraction
	if(executioner)
		technique.damage_multiplier *= 1.25
		technique.bleed_fraction = 0.25
		player_view(15, src) << "<font color=#a71930><b>[src] drives an executioner's hand toward [target]!</b></font>"
	var/hit_landed = resolveViltrumiteTechniqueHit(target, technique)
	technique.damage_multiplier = original_damage
	technique.bleed_fraction = original_bleed
	if(hit_landed && target) showNexusSwordSlashEffect(target, "#d1283f", 1.1)
	return hit_landed

mob/proc/castViltrumiteNolanCombination(obj/Attacks/NexusMeleeTechnique/technique)
	var/mob/target = getViltrumiteTechniqueTarget(technique, technique.dash_range, "Nolan's Combination requires a target within [technique.dash_range] tiles.")
	if(!target || !payNexusTechniqueCost(technique)) return FALSE
	technique.playCastEffects(src)
	AlterInputDisabled(1)
	attacking = 1
	if(getdist(src, target) > 1) runNexusSkillApproach(target, technique.dash_range * world.icon_size, world.icon_size, 120, 270, 330, 0.3)
	var/has_opening = target && target.hasViltrumiteOpeningFrom(src)
	if(has_opening) technique.accuracy_bonus += VILTRUMITE_OPENING_ACCURACY
	var/list/hit_multipliers = list(0.55, 0.55, 0.6, 1.1)
	var/hits_landed = 0
	var/original_bleed = technique.bleed_fraction
	for(var/hit_index = 1, hit_index <= hit_multipliers.len, hit_index++)
		if(!target || !canHitNexusTechniqueTarget(target) || getdist(src, target) > 1 || target.blocking || target.hasNexusStance("block")) break
		dir = get_dir(src, target)
		technique.bleed_fraction = hit_index == hit_multipliers.len ? 0.15 : 0
		if(!resolveNexusTechniqueHit(target, technique, hit_multipliers[hit_index])) break
		hits_landed++
		if(has_opening && hits_landed == 1) target.consumeViltrumiteOpening(src)
		if(hit_index == hit_multipliers.len) showNexusSwordSlashEffect(target, "#d1283f", 1.35)
		else sleep(3)
	technique.bleed_fraction = original_bleed
	if(has_opening) technique.accuracy_bonus -= VILTRUMITE_OPENING_ACCURACY
	AlterInputDisabled(-1)
	Reset_melee()
	return hits_landed == hit_multipliers.len

mob/proc/activateViltrumitePunishingReversal(obj/Attacks/NexusMeleeTechnique/technique)
	if(!technique || !can_melee() || !payNexusTechniqueCost(technique)) return FALSE
	setNexusStance("viltrumite_reversal", 10)
	technique.playCastEffects(src)
	src << "For one second, the next frontal melee attack can be punished."
	return TRUE

mob/proc/tryViltrumitePunishingReversal(mob/attacker)
	if(!attacker || !isViltrumiteRace() || !hasNexusStance("viltrumite_reversal") || usingMeleeWeapon()) return FALSE
	var/attack_direction = get_dir(src, attacker)
	if(!(attack_direction in list(dir, turn(dir, 45), turn(dir, -45)))) return FALSE
	var/obj/Attacks/NexusMeleeTechnique/Viltrumite/PunishingReversal/technique = locate() in src
	if(!technique) return FALSE
	clearNexusStance()
	dir = get_dir(src, attacker)
	attacker.applyViltrumiteStagger(src, 7)
	attacker.applyViltrumiteOpening(src)
	player_view(15, src) << "<font color=#e0b76f>[src] slips the attack and answers with a punishing elbow!</font>"
	resolveViltrumiteTechniqueHit(attacker, technique, force_hit = TRUE, consume_opening = FALSE)
	return TRUE

obj/Attacks/NexusMeleeTechnique/Viltrumite
	requires_unarmed = TRUE
	race_teach_only = 1
	teachable = 0
	cast_text_color = "#d9b36c"

obj/Attacks/NexusMeleeTechnique/Viltrumite/ViltrumiteRush
	name = "Viltrumite Rush"
	desc = "Surge up to seven tiles into a target. The impact opens their guard, enables Relentless Pursuit and briefly staggers them against solid terrain."
	damage_multiplier = 3
	accuracy_bonus = 5
	knockback_multiplier = 3
	energy_cost = 20
	cooldown_ticks = 100
	dash_range = 7
	behavior = "viltrumite_rush"
	effect_icon = 'src/Icons/NexusIntegrated/Attacks/Effects/RTImpactHeavy.dmi'
	verb/Viltrumite_Rush()
		set name = "Viltrumite Rush"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/NexusMeleeTechnique/Viltrumite/RibBreaker
	name = "Rib Breaker"
	desc = "Drive a compact strike into an adjacent target, briefly staggering them and creating a personal combat opening."
	damage_multiplier = 2.4
	accuracy_bonus = 5
	knockback_multiplier = 0
	energy_cost = 12
	cooldown_ticks = 80
	behavior = "viltrumite_rib_breaker"
	effect_icon = 'src/Icons/NexusIntegrated/Attacks/Effects/RTImpact.dmi'
	verb/Rib_Breaker()
		set name = "Rib Breaker"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/NexusMeleeTechnique/Viltrumite/RelentlessPursuit
	name = "Relentless Pursuit"
	desc = "Consume the pursuit window on a target you recently launched and close up to ten tiles without dealing damage."
	damage_multiplier = 0
	energy_cost = 8
	cooldown_ticks = 70
	dash_range = 10
	behavior = "viltrumite_pursuit"
	cast_sound_category = "flight"
	verb/Relentless_Pursuit()
		set name = "Relentless Pursuit"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/NexusMeleeTechnique/Viltrumite/ConquerorsGrip
	name = "Conqueror's Grip"
	desc = "Seize an adjacent unguarded opponent after a low-damage strike, preparing them for a grapple technique."
	damage_multiplier = 1.5
	accuracy_bonus = 5
	knockback_multiplier = 0
	energy_cost = 14
	cooldown_ticks = 120
	behavior = "viltrumite_grip"
	effect_icon = 'RTGrappleImpact.dmi'
	effect_icon_state = "1"
	verb/Conquerors_Grip()
		set name = "Conqueror's Grip"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/NexusMeleeTechnique/Viltrumite/MeteorDrop
	name = "Meteor Drop"
	desc = "Requires a grabbed opponent. Rise with them and drive them into the ground, opening and briefly staggering them."
	damage_multiplier = 5.5
	knockback_multiplier = 0
	energy_cost = 26
	cooldown_ticks = 150
	behavior = "viltrumite_meteor_drop"
	effect_icon = 'src/Icons/NexusIntegrated/Attacks/Effects/RTShockwave.dmi'
	verb/Meteor_Drop()
		set name = "Meteor Drop"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/NexusMeleeTechnique/Viltrumite/SpearHand
	name = "Spear Hand"
	desc = "A focused adjacent hand thrust with high damage, no knockback and severe bleeding. Combat openings improve its accuracy."
	damage_multiplier = 4.5
	accuracy_bonus = -10
	knockback_multiplier = 0
	bleed_fraction = 0.15
	energy_cost = 22
	cooldown_ticks = 120
	behavior = "viltrumite_spear_hand"
	effect_icon = 'src/Icons/NexusIntegrated/Attacks/Effects/RTStab.dmi'
	verb/Spear_Hand()
		set name = "Spear Hand"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/NexusMeleeTechnique/Viltrumite/NolansCombination
	name = "Nolan's Combination"
	desc = "Close four tiles and attempt four individually resolved strikes, ending in a bleeding knife-hand slash. Blocking or evading interrupts the sequence."
	damage_multiplier = 2.5
	accuracy_bonus = 0
	knockback_multiplier = 0
	sequence_hits = 4
	sequence_hit_multiplier = 0.7
	energy_cost = 34
	cooldown_ticks = 180
	dash_range = 4
	behavior = "viltrumite_nolan_combo"
	effect_icon = 'src/Icons/NexusIntegrated/Attacks/Effects/RTImpact.dmi'
	verb/Nolans_Combination()
		set name = "Nolan's Combination"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/NexusMeleeTechnique/Viltrumite/PunishingReversal
	name = "Punishing Reversal"
	desc = "For one second, counter the next frontal melee attack with a low-damage elbow that staggers and creates a combat opening."
	damage_multiplier = 2.2
	accuracy_bonus = 100
	knockback_multiplier = 0
	energy_cost = 16
	cooldown_ticks = 180
	behavior = "viltrumite_reversal"
	effect_icon = 'src/Icons/NexusIntegrated/Attacks/Effects/RTImpact.dmi'
	verb/Punishing_Reversal()
		set name = "Punishing Reversal"
		set category = "Skills"
		useTechnique(usr)

obj/Attacks/NexusStance/ViltrumiteGuard
	name = "Viltrumite Guard"
	desc = "Brace for two seconds. The next frontal attack deals 40% less final damage and gives you a personal opening against its attacker."
	stance_id = "viltrumite_guard"
	duration_ticks = 20
	energy_cost = 14
	cooldown_ticks = 150
	requires_unarmed = TRUE
	teachable = 0
	race_teach_only = 1
	activation_color = "#d9b36c"
	activation_message = "You brace to absorb and punish the next frontal attack."
	activate(mob/user)
		if(!user || !user.isViltrumiteRace())
			if(user) user << "Only a Viltrumite can use [src]."
			return FALSE
		return ..()
	verb/Viltrumite_Guard()
		set name = "Viltrumite Guard"
		set category = "Skills"
		activate(usr)

obj/ViltrumiteExecutionersHand
	name = "Executioner's Hand"
	desc = "Passive Viltrumite mastery: Spear Hand gains 25% damage and heavier bleeding against KO or critically wounded targets while you fight lethally."
	can_hotbar = 0
	teachable = 0
	race_teach_only = 1
