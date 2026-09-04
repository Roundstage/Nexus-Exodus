#define SCOURGE_TOTAL_ONLINE_TICKS (70 * 60 * 60 * 10)
#define SCOURGE_CONTAGION_RADIUS 3

var/list/scourge_stage_thresholds = list(0, 10 * 60 * 60 * 10, 25 * 60 * 60 * 10, 45 * 60 * 60 * 10, 60 * 60 * 60 * 10)

mob/var
	scourge_infected
	scourge_online_ticks
	scourge_stage
	scourge_outcome_resolved
	scourge_survivor
	tmp/scourge_loop_running

mob/proc/getScourgeStage()
	if(!scourge_infected || scourge_outcome_resolved) return 0
	var/stage = 1
	for(var/index = 2, index <= scourge_stage_thresholds.len, index++)
		if(scourge_online_ticks >= scourge_stage_thresholds[index]) stage = index
	return stage

mob/proc/exposeToScourgeVirus()
	if(!isViltrumiteRace() || scourge_survivor) return FALSE
	if(scourge_infected) return TRUE
	scourge_infected = TRUE
	scourge_online_ticks = 0
	scourge_stage = 1
	scourge_outcome_resolved = FALSE
	ScourgeVirusLoop()
	return TRUE

mob/proc/getScourgeSymptomMessage(stage)
	var/list/messages
	switch(stage)
		if(1)
			messages = list("For a moment, your throat feels strangely dry.", "A faint chill passes through you, then vanishes.", "Something feels slightly wrong, but you cannot place it.")
		if(2)
			messages = list("Your muscles ache more deeply than they should.", "Your heartbeat skips. The silence after it feels too long.", "A metallic taste lingers at the back of your mouth.")
		if(3)
			messages = list("A sudden wave of weakness forces you to steady yourself.", "You wipe a thin line of blood from beneath your nose.", "Your breath catches as a sharp pain moves through your chest.")
		if(4)
			messages = list("Your body feels impossibly heavy. Even standing takes effort.", "Blood wells between your teeth without warning.", "For several seconds, you cannot make your hands stop trembling.")
		if(5)
			messages = list("Your vision tunnels. Somewhere inside you, something is coming apart.", "Your legs nearly give way as warmth runs from your nose and mouth.", "Your heartbeat is weak, irregular, and terribly distant.", "A cold certainty settles over you: your body is failing.")
	if(!messages || !messages.len) return
	return pick(messages)

mob/proc/applyScourgeSymptoms(stage)
	if(!client || Dead) return
	var/message_chance = 4 + stage * 3
	if(prob(message_chance))
		var/message = getScourgeSymptomMessage(stage)
		if(message) src << "<font color=#b7b1aa><i>[message]</i></font>"
	if(stage >= 3 && prob(8 + stage * 3)) SaitamaBloodEffect(blood_range = 1, blood_chance = 100)
	if(stage == 3)
		Health = min(Health, 70)
		Ki = min(Ki, max_ki * 0.7)
	else if(stage == 4)
		Health = min(Health, 40)
		Ki = min(Ki, max_ki * 0.4)
		if(prob(5)) ApplyStun(time = 8, stun_power = 1)
	else if(stage >= 5)
		Health = min(Health, 20)
		Ki = min(Ki, max_ki * 0.2)
		if(prob(12)) ApplyStun(time = 15, stun_power = 1.5)
	updateOverheadHealthHud()

mob/proc/spreadScourgeVirus()
	if(!client || !scourge_infected || scourge_outcome_resolved || !z) return
	for(var/mob/player in range(SCOURGE_CONTAGION_RADIUS, src))
		if(player == src || !player.client || !player.playerCharacter) continue
		if(!player.isViltrumiteRace() || player.scourge_infected || player.scourge_survivor) continue
		player.exposeToScourgeVirus()

mob/proc/receiveScourgeAntiviral(super_treatment = FALSE)
	if(!scourge_infected || scourge_outcome_resolved) return FALSE
	var/list/responses
	if(super_treatment)
		responses = list(
			"A powerful cold rush spreads from the injection site. Your breathing steadies, and for a while the sickness seems to retreat.",
			"The pressure behind your eyes rapidly fades. Whatever was attacking your body suddenly feels weaker.",
			"Your pulse evens out as the concentrated treatment moves through you. For the first time in a long while, you feel almost well."
		)
	else
		responses = list(
			"A cool sensation spreads through your body. The ache in your muscles begins to ease.",
			"Your breathing feels clearer after the injection, as though the infection is finally losing its grip.",
			"The nausea slowly subsides. The antiviral seems to be doing something."
		)
	src << "<font color=#9fc7a5><i>[pick(responses)]</i></font>"
	return TRUE

mob/proc/resolveScourgeVirus()
	if(!scourge_infected || scourge_outcome_resolved) return
	scourge_outcome_resolved = TRUE
	if(isScourgeImmune())
		scourge_infected = FALSE
		scourge_survivor = TRUE
		src << "<font color=#c7d6c2><i>Your failing heartbeat steadies. Against every expectation, your body is still fighting.</i></font>"
		spawn() save()
		return
	src << "<font color=#9d1f2f><b>Your body can no longer endure what is consuming it.</b></font>"
	Health = 0
	spawn() Death("Scourge Virus")
	spawn() save()

mob/proc/ScourgeVirusLoop()
	set waitfor = 0
	if(scourge_loop_running) return
	scourge_loop_running = TRUE
	while(src && scourge_infected && !scourge_outcome_resolved)
		sleep(10)
		if(!src || !scourge_infected || scourge_outcome_resolved) break
		if(!client) continue
		spreadScourgeVirus()
		scourge_online_ticks = min(SCOURGE_TOTAL_ONLINE_TICKS, scourge_online_ticks + 10)
		var/current_stage = getScourgeStage()
		if(current_stage > scourge_stage)
			scourge_stage = current_stage
			spawn() save()
		if(scourge_online_ticks % 600 == 0) applyScourgeSymptoms(current_stage)
		if(scourge_online_ticks >= SCOURGE_TOTAL_ONLINE_TICKS) resolveScourgeVirus()
	scourge_loop_running = FALSE

obj/items/ScourgeVirus
	name = "Scourge Virus"
	icon = 'src/Icons/NexusIntegrated/Technology/ScourgeVirus.png'
	desc = "A sealed vial containing an unidentified fluorescent biological agent."
	Cost = 0
	Stealable = 1
	Injection = 1
	verb/Hotbar_use()
		set waitfor = 0
		set hidden = 1
		Use()
	verb/Use()
		if(!usr) return
		var/mob/target = usr.get_inject()
		if(!target) return
		player_view(15, usr) << "[usr] injects [target] with the contents of a sealed green vial."
		target.exposeToScourgeVirus()
		del(src)

obj/items/ExperimentalScourgeTreatment
	name = "Experimental Scourge Treatment"
	icon = 'Antivirus.dmi'
	icon_state = "red"
	desc = "An experimental antiviral treatment intended to suppress aggressive Viltrumite pathogens."
	Cost = 0
	Stealable = 1
	Injection = 1
	verb/Hotbar_use()
		set waitfor = 0
		set hidden = 1
		Use()
	verb/Use()
		if(!usr) return
		var/mob/target = usr.get_inject()
		if(!target) return
		player_view(15, usr) << "[usr] administers [src] to [target]."
		target << "<font color=#9fc7a5><i>A cool sensation spreads through your body as the treatment takes effect.</i></font>"
		del(src)
