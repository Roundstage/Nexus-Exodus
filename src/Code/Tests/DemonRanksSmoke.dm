proc/runDemonRanksSmokeTests()
	var/mob/NexusSmokeTest/teacher = new
	var/mob/NexusSmokeTest/student = new
	teacher.Race = "Demon"
	student.Race = "Human"
	var/list/stats = list("bp_mult", "Str", "strmod", "Pow", "formod", "Off", "offmod", "End", "endmod", "Def", "defmod", "regen", "recov")
	var/list/baseline = list()
	for(var/stat_name in stats)
		teacher.vars[stat_name] = stat_name == "bp_mult" ? 1 : 10
		baseline[stat_name] = teacher.vars[stat_name]
	teacher.Ki = 1000
	teacher.max_ki = 1000
	for(var/rank_name in list("Famine", "War", "Pestilence", "Death"))
		var/buff_type = getDemonRankBuffType(rank_name)
		nexusSmokeAssert(teacher.Race_can_have_rank(rank_name) && !student.Race_can_have_rank(rank_name), "demon rank race eligibility is incorrect: [rank_name]")
		nexusSmokeAssert(!student.giveDemonRank(rank_name), "a non-demon received a Horseman rank")
		nexusSmokeAssert(teacher.giveDemonRank(rank_name), "demon rank grant failed: [rank_name]")
		var/count_before = teacher.contents.len
		teacher.giveDemonRank(rank_name)
		nexusSmokeAssert(teacher.contents.len == count_before, "repeated demon rank grant duplicated skills")
		var/obj/DemonBuff/skill = locate(buff_type) in teacher
		nexusSmokeAssert(skill && skill.teachable && !istype(skill, /obj/Buff) && teacher.Buff_count() == 0, "demon aura uses the custom buff slot or cannot be taught")
		nexusSmokeAssert(teacher.CanTeachSkillTo(student, skill), "demon aura cannot follow Mystic's teaching rules")
		nexusSmokeAssert(isProgressionCombatTreeExcluded(buff_type) && !teacher.getProgressionNodeIdForReward(buff_type), "rank aura is sold in Combat progression")
		teacher.ismystic = TRUE
		nexusSmokeAssert(!teacher.toggleDemonBuff(skill), "demon aura stacked with Mystic")
		teacher.ismystic = FALSE
		teacher.ismajin = TRUE
		nexusSmokeAssert(!teacher.toggleDemonBuff(skill), "demon aura stacked with Majin")
		teacher.ismajin = FALSE
		nexusSmokeAssert(teacher.toggleDemonBuff(skill) && teacher.active_demon_buff == buff_type && !teacher.current_buff, "demon aura did not activate independently")
		var/list/hud_data = teacher.getNexusActiveHudModifiers()
		var/list/hud_names = hud_data["names"]
		nexusSmokeAssert(rank_name in hud_names, "active demon aura missing from HUD")
		var/list/action_state = skill.getClassicSkillState(teacher)
		nexusSmokeAssert(action_state["state"] == "active", "demon aura missing active action-bar state")
		switch(rank_name)
			if("Famine")
				nexusSmokeAssertNear(teacher.regen, 13, 0.001, "Famine lost regeneration")
				nexusSmokeAssertNear(teacher.recov, 14, 0.001, "Famine lost recovery")
			if("War")
				nexusSmokeAssertNear(teacher.Str, 13, 0.001, "War lost Strength")
				nexusSmokeAssertNear(teacher.Pow, 13, 0.001, "War lost Force")
				nexusSmokeAssertNear(teacher.Off, 12.5, 0.001, "War lost Offense")
			if("Pestilence")
				nexusSmokeAssertNear(teacher.End, 14, 0.001, "Pestilence lost Endurance")
				nexusSmokeAssertNear(teacher.Def, 14, 0.001, "Pestilence lost Defense")
		nexusSmokeAssertNear(teacher.bp_mult, rank_name == "Death" ? 1.7 : 1.4, 0.001, "incorrect Horseman BP bonus")
		var/obj/DemonBuff/other = rank_name == "War" ? new /obj/DemonBuff/Death(teacher) : new /obj/DemonBuff/War(teacher)
		nexusSmokeAssert(!teacher.toggleDemonBuff(other) && teacher.active_demon_buff == buff_type, "two demon auras stacked")
		del(other)
		teacher.normalizeDemonBuff()
		nexusSmokeAssertNear(teacher.bp_mult, rank_name == "Death" ? 1.7 : 1.4, 0.001, "normalization applied the aura twice")
		nexusSmokeAssert(teacher.toggleDemonBuff(skill), "demon aura failed to toggle off")
		teacher.revertDemonBuff()
		for(var/stat_name in stats) nexusSmokeAssertNear(teacher.vars[stat_name], baseline[stat_name], 0.001, "demon aura left a stat modifier: [rank_name]/[stat_name]")

	var/obj/DemonBuff/War/war = locate(/obj/DemonBuff/War) in teacher
	if(!war) war = new(teacher)
	var/obj/Buff/Preset/MuscleForce/custom = new(teacher)
	teacher.Buff_Enable(custom)
	nexusSmokeAssert(teacher.toggleDemonBuff(war) && teacher.current_buff == custom && custom.suffix, "demon aura replaced the ordinary buff")
	teacher.revertDemonBuff()
	nexusSmokeAssert(teacher.current_buff == custom && custom.suffix, "reverting a demon aura disabled the ordinary buff")
	teacher.Buff_Disable(custom)
	teacher.toggleDemonBuff(war)
	teacher.Ki = 100
	teacher.drainDemonBuff()
	nexusSmokeAssertNear(teacher.Ki, 95, 0.001, "demon aura drain is not 0.5 percent of maximum Energy")
	var/savefile/buff_save = new
	teacher.Write(buff_save)
	var/mob/NexusSmokeTest/loaded = new
	loaded.Read(buff_save)
	loaded.normalizeDemonBuff()
	nexusSmokeAssert(loaded.active_demon_buff == /obj/DemonBuff/War, "active demon aura did not survive saving")
	nexusSmokeAssertNear(loaded.Str, 13, 0.001, "loading a demon aura doubled or lost its Strength")
	loaded.revertDemonBuff()
	for(var/stat_name in stats) nexusSmokeAssertNear(loaded.vars[stat_name], baseline[stat_name], 0.001, "loaded aura failed to revert [stat_name]")
	teacher.Ki = 1
	teacher.drainDemonBuff()
	nexusSmokeAssert(!teacher.active_demon_buff && teacher.Ki == 0, "exhausted demon aura remained active")
	teacher.Ki = 100
	teacher.toggleDemonBuff(war)
	del(war)
	nexusSmokeAssert(!teacher.active_demon_buff, "deleting a demon aura left its bonuses active")
	for(var/stat_name in stats) nexusSmokeAssertNear(teacher.vars[stat_name], baseline[stat_name], 0.001, "deleted aura failed to revert [stat_name]")

	var/obj/Demon_Contract/legacy_contract = new(teacher)
	legacy_contract.teachable = TRUE
	nexusSmokeAssert(!teacher.canUseSoulContract() && !teacher.CanTeachSkillTo(student, legacy_contract), "ordinary demon can use or teach a legacy Soul Contract")
	teacher.syncDemonRankSkills()
	nexusSmokeAssert(!(locate(/obj/Demon_Contract) in teacher), "ordinary demon retained the legacy racial Soul Contract")
	teacher.Daimaou()
	nexusSmokeAssert(teacher.canUseSoulContract() && (locate(/obj/Demon_Contract) in teacher), "Demon Lord rank did not grant Soul Contract")
	var/obj/Demon_Contract/lord_contract = locate(/obj/Demon_Contract) in teacher
	nexusSmokeAssert(!lord_contract.teachable && !lord_contract.Cost_To_Learn, "Soul Contract can be acquired outside its rank")
	lord_contract.can_hotbar = FALSE
	lord_contract.hotbar_type = null
	teacher.syncDemonRankSkills()
	nexusSmokeAssert(teacher.isNexusHotkeyObjectAvailable(lord_contract) && hascall(lord_contract, "Hotbar_use") && lord_contract.hotbar_type == "Support", "saved Demon Lord Soul Contract cannot be used from Skills or a hotbar")
	teacher.Ranks -= "Daimao"
	nexusSmokeAssert(!teacher.canUseSoulContract(), "removed Demon Lord rank still authorizes Soul Contract")
	teacher.syncDemonRankSkills()
	nexusSmokeAssert(!(locate(/obj/Demon_Contract) in teacher), "removed Demon Lord rank retained the skill")
	var/list/packages = getRacialProgressionSkillPackages()
	var/list/demon_package = packages["Daimao"]
	nexusSmokeAssert(!(/obj/Demon_Contract in demon_package), "racial progression still grants Soul Contract")
	del(loaded)
	del(student)
	del(teacher)
