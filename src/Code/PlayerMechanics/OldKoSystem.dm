
/*
Greetings, One Who Will Suffer.

I dedicate this file to me, myself, and I.

Cordially,
Kaseio.

Last modified at 2023-03-29
Description: 
	Refactor everything to here from death.dm 
	Split KO loop into several smaller logical pieces
	Remove unnecessary code
*/

mob/proc/anger_chance(mod=1)
	if(!canPossessAnger()) return 0
	return 100

mob/proc/Angry()
	if(!canPossessAnger()) return disableAnger()
	if(anger > 100) return 1

mob/var/tmp/list/recent_ko_reasons=new

mob/proc/InTournament()
	if(!client || !Tournament || z != Z_LEVEL_HEAVEN || !(src in All_Entrants)) return
	return 1

mob/var/tmp
	last_knocked_out_by_mob
	koCount = 0 //how many times you were ko'd this session

mob/proc/ShouldAnger(mob/target)
	return target && target.canUseAngerHealthRecovery()

mob/proc/TryToCauseAnger(mob/Attacker, mob/Victim)
	if(!ShouldAnger(Victim) || Attacker == Victim) return FALSE
	var/ko_reason = "being pushed to the brink"
	if(ismob(Attacker))
		ko_reason = Attacker.ckey ? Attacker.ckey : "an enemy attack"
	return Victim.triggerAngerHealthRecovery(ko_reason)

mob/proc/TryToAnnounceBattlegroundsDefeat(mob/Attacker, mob/Victim)
	if(Victim.client && Victim.AtBattlegrounds())
		BattlegroundDefeat(defeater = Attacker)
		return

mob/proc/LogKoData(mob/Victim, mob/Attacker)
	if(ismob(Attacker)) 
		Victim.last_knocked_out_by_mob = Attacker

mob/proc/ResetStatsToDefault(mob/Victim)
	// Keep a fractional health point so the attack which caused the KO does not
	// immediately execute the victim in legacy fatal-hit follow-up checks.
	Victim.Health = 0.1
	Victim.Ki = max(0, Victim.Ki)
	Victim.BP = get_bp()
	if(Victim.BPpcnt > 100)
		Victim.BPpcnt = 100
		Victim.Aura_Overlays(remove_only=1)
	Victim.KB=0

mob/proc/StopDoingActions(mob/Victim)
	Victim.Stop_Shadow_Sparring()
	Victim.Limit_Revert()
	Victim.UltraInstinctRevert()
	Victim.God_FistStop()
	Victim.Destroy_Splitforms()
	Victim.Great_Ape_revert()
	Victim.Land()

	Victim.Action=null
	Victim.Auto_Attack=0

	if(Victim.grabbedObject)
		player_view(center=Victim) << "[Victim] is forced to release [grabbedObject]!"
		Victim.ReleaseGrab()

mob/proc/TryToRevertSSJ(mob/Victim)
	var/is_in_ssj 			= Victim.ssj > 0
	var/should_stay_in_ssj 	= FALSE

	// If the player has mastered SSJ 1, then they can stay in it while KO'd
	if(Victim.has_ss_full_power && Victim.ssj == 1)
		should_stay_in_ssj = TRUE

	if(is_in_ssj)
		if(should_stay_in_ssj) return
		else 
			Revert()

mob/proc/TryToKoNPC(mob/Attacker, mob/Victim)
	if(Victim.client) return

	// Frozen is the NPC equivalent of being KO'd.
	// It's a state where the NPC is unable to move or attack.
	if(!Victim.Frozen)
		if(istype(Victim, /mob/new_troll))
			if("KO" in icon_states(icon)) 
				Victim.icon_state = "KO"

			Victim.KO = 1
			Victim.Health = 100
			Victim.Frozen = 1
			spawn(700)
				Victim.icon_state = initial(icon_state)
				player_view(22, src) << "[src] regains consciousness"
				Victim.Health = 100
				Victim.KO = 0
				Victim.Frozen = 0
		else
			// In this case, the NPC most probably is a Splitform
			// (take this with a grain of salt)
			SplitformDestroyedByCheck(Attacker)

			// Tens --> all other npcs currently just die instantly upon ko
			del(Victim)


mob/proc/MinimumHeal(mob/Victim)
	if(!client) // NPC
		Frozen	= FALSE
		Health 	= 100
		Ki 		= Victim.max_ki
	else
		Victim.Health = 1
		Victim.Ki = 1
		Victim.move = 1
		Victim.attacking = 0

mob/proc/TryToKillWithPoison(mob/Victim)
	// NPC's can't be poisoned
	if(istype(Victim, /mob/Enemy)) return

	if(Victim.Poisoned && prob(50)) 
		Victim.Death("Poisoned to death")

mob/proc/TryToCauseAngerDueToKo(mob/Victim)
	// Anger now builds from damage instead of granting a random full-heal proc on KO.
	return FALSE
		
mob/proc/KO(mob/Attacker, allow_anger=TRUE, combat_ko_handled = FALSE, mob/Victim = src, combat_mode_override)
	set waitfor=0
	
	if(!Victim.client || !Victim.empty_player) 
		TryToKoNPC(Attacker, Victim)

	if(Victim.KO || Victim.Safezone) return

	if(Victim.spam_killed)
		Victim.FullHeal()
		return

	if(allow_anger && TryToCauseAnger(Attacker, Victim))
		return

	TryToAnnounceBattlegroundsDefeat(Attacker, Victim)
	give_tier(Attacker)

	Victim.KO = TRUE
	Victim.has_angered_before_ko = FALSE
	Victim.icon_state = "KO"
	Victim.CheckTriggerUltraInstinct()

	LogKoData(Victim, Attacker)
	StopDoingActions(Victim)
	TryToRevertSSJ(Victim)

	if(alignment_on&&!InTournament()) Drop_dragonballs()


	ResetStatsToDefault(Victim)
	if(!combat_ko_handled)
		Cause_Combat_KO(Victim, Attacker, combat_mode_override)

mob/proc/UnKO() if(KO)
	set waitfor=0
	var/mob/Victim = src

	TryToKillWithPoison(Victim)
	MinimumHeal(Victim)
	Victim.KO = FALSE
	Victim.icon_state = initial(icon_state)
