var/global/datum/SkillRegistry/skill_registry = new
var/global/datum/SkillEngine/skill_engine = new
var/global/skill_engine_debug = 1
var/global/skill_engine_debug_interval = 50

proc/initializeSkillEngine()
	if(skill_engine)
		skill_engine.bootstrap()
		skill_engine.startLoop()

datum/SkillDefinition
	var
		id
		name
		description
		icon
		category
		behavior_type
		movement_type
		size_class
		control_mode
		controller_type
		homing_mode
		homing_mod = 1
		control_range = 0
		control_bumps = 0
		control_delay = 0
		control_max_steps = 0
		control_avoid_owner = 0
		control_avoid_owner_chance = 0
		control_stop_on_deflect = 0
		hotbar_type
		can_hotbar = 1
		obj_type
		damage = 0
		damage_add = 0
		max_charge = 0
		charge_time = 0
		cooldown = 0
		cost = 0
		energy_type

datum/SkillRegistry
	var/list/definitions = list()

	proc/register(datum/SkillDefinition/def)
		if(!def || !def.id) return
		definitions[def.id] = def

	proc/get(id)
		return definitions[id]

	proc/all()
		return definitions

datum/SkillEngine
	var
		datum/SkillRegistry/registry
		datum/SkillControllerRegistry/controller_registry
		datum/SkillActorRegistry/actor_registry
		list/category_overrides
		list/homing_mode_overrides
		list/homing_mod_overrides
		list/active_actors
		loop_running = 0
		loop_delay = 0
		last_debug_time = 0

	New()
		registry = skill_registry
		controller_registry = skill_controller_registry
		actor_registry = skill_actor_registry
		active_actors = list()
		loop_delay = world.tick_lag
		category_overrides = list(
			/obj/Attacks/Genki_Dama = SKILL_CATEGORY_CONTROLLED_BIG_BLAST,
			/obj/Attacks/Kienzan = SKILL_CATEGORY_CONTROLLED_BLAST,
			/obj/Attacks/Sokidan = SKILL_CATEGORY_CONTROLLED_BLAST,
			/obj/Attacks/Big_Bang_Attack = SKILL_CATEGORY_BIG_BLAST,
			/obj/Attacks/Charge = SKILL_CATEGORY_CONTROLLED_BLAST,
			/obj/Attacks/Cyber_Charge = SKILL_CATEGORY_CONTROLLED_BLAST
		)
		homing_mode_overrides = list(
			/obj/Attacks/Big_Bang_Attack = SKILL_HOMING_AUTO,
			/obj/Attacks/Charge = SKILL_HOMING_AUTO,
			/obj/Attacks/Cyber_Charge = SKILL_HOMING_AUTO,
			/obj/Attacks/Genocide = SKILL_HOMING_AUTO,
			/obj/Attacks/Scatter_Shot = SKILL_HOMING_AUTO
		)
		homing_mod_overrides = list(
			/obj/Attacks/Big_Bang_Attack = 1,
			/obj/Attacks/Charge = 1,
			/obj/Attacks/Cyber_Charge = 1,
			/obj/Attacks/Sokidan = 2
		)

	proc/bootstrap()
		registry.definitions = list()
		registerLegacySkills()

	proc/startLoop()
		if(loop_running) return
		loop_running = 1
		debugLog("SkillEngine loop started.")
		spawn() engineLoop()

	proc/stopLoop()
		loop_running = 0
		debugLog("SkillEngine loop stopped.")

	proc/engineLoop()
		while(loop_running)
			tickActors()
			sleep(loop_delay || world.tick_lag)

	proc/registerActor(datum/SkillActor/actor)
		if(!actor) return
		active_actors += actor
		if(actor_registry) actor_registry.register(actor)

	proc/removeActor(datum/SkillActor/actor)
		if(!actor) return
		active_actors -= actor
		if(actor_registry) actor_registry.unregister(actor)

	proc/tickActors()
		if(!active_actors || !active_actors.len) return
		if(skill_engine_debug && world.time >= last_debug_time + skill_engine_debug_interval)
			debugLog("SkillEngine tick actors=[active_actors.len].")
			last_debug_time = world.time
		var/list/to_remove = list()
		for(var/datum/SkillActor/actor in active_actors)
			if(!actor)
				to_remove += actor
				continue
			var/keep = actor.tick(loop_delay || world.tick_lag)
			if(!keep)
				actor.cleanup()
				to_remove += actor
		if(to_remove.len)
			for(var/datum/SkillActor/actor in to_remove)
				removeActor(actor)

	proc/registerLegacySkills()
		for(var/path in typesof(/obj))
			if(initial(path:Skill) != 1) continue
			var/datum/SkillDefinition/def = new
			def.id = "[path]"
			def.obj_type = path
			def.name = initial(path:name)
			def.description = initial(path:desc)
			def.hotbar_type = initial(path:hotbar_type)
			def.can_hotbar = initial(path:can_hotbar)
			def.icon = resolveIcon(path)
			def.damage = resolveDamage(path)
			def.damage_add = resolveDamageAdd(path)
			def.max_charge = resolveMaxCharge(path)
			def.charge_time = resolveChargeTime(path)
			def.category = resolveCategory(path, def.hotbar_type)
			def.behavior_type = resolveBehavior(def.category)
			def.movement_type = resolveMovement(def.category)
			def.size_class = resolveSizeClass(def.category)
			def.control_mode = resolveControlMode(def.category)
			def.controller_type = resolveControllerType(path, def.category)
			def.homing_mode = resolveHomingMode(path, def.category)
			def.homing_mod = resolveHomingMod(path)
			def.control_range = resolveControlRange(path, def.category)
			def.control_bumps = resolveControlBumps(path, def.category)
			def.control_delay = resolveControlDelay(def.category)
			def.control_max_steps = resolveControlMaxSteps(path, def.category)
			def.control_avoid_owner = resolveControlAvoidOwner(path, def.category)
			def.control_avoid_owner_chance = resolveControlAvoidOwnerChance(path, def.category)
			def.control_stop_on_deflect = resolveControlStopOnDeflect(path, def.category)
			registry.register(def)

	proc/getDefinitionForObj(obj/skill_obj)
		if(!skill_obj) return
		return registry.get("[skill_obj.type]")

	proc/resolveCategory(path, hotbar_type)
		for(var/override_type in category_overrides)
			if(ispath(path, override_type))
				return category_overrides[override_type]

		switch(hotbar_type)
			if("Melee") return SKILL_CATEGORY_RUSH
			if("Blast") return SKILL_CATEGORY_BLAST
			if("Beam") return SKILL_CATEGORY_BEAM
			if("Defensive") return SKILL_CATEGORY_EVASIVE
			if("Ranged") return SKILL_CATEGORY_BLAST
			if("Ability") return SKILL_CATEGORY_UTILITY
			if("Support") return SKILL_CATEGORY_UTILITY
			if("Buff") return SKILL_CATEGORY_UTILITY
			if("Transformation") return SKILL_CATEGORY_UTILITY
			if("Training method") return SKILL_CATEGORY_UTILITY
			if("Other") return SKILL_CATEGORY_UTILITY
		return SKILL_CATEGORY_UTILITY

	proc/resolveBehavior(category)
		switch(category)
			if(SKILL_CATEGORY_RUSH) return SKILL_BEHAVIOR_RUSH
			if(SKILL_CATEGORY_BLAST) return SKILL_BEHAVIOR_PROJECTILE
			if(SKILL_CATEGORY_BIG_BLAST) return SKILL_BEHAVIOR_PROJECTILE
			if(SKILL_CATEGORY_CONTROLLED_BLAST) return SKILL_BEHAVIOR_CONTROLLED
			if(SKILL_CATEGORY_CONTROLLED_BIG_BLAST) return SKILL_BEHAVIOR_CONTROLLED
			if(SKILL_CATEGORY_BEAM) return SKILL_BEHAVIOR_BEAM
			if(SKILL_CATEGORY_EVASIVE) return SKILL_BEHAVIOR_EVASIVE
		return SKILL_BEHAVIOR_UTILITY

	proc/resolveMovement(category)
		switch(category)
			if(SKILL_CATEGORY_RUSH) return SKILL_MOVEMENT_DASH
			if(SKILL_CATEGORY_BLAST) return SKILL_MOVEMENT_PROJECTILE
			if(SKILL_CATEGORY_BIG_BLAST) return SKILL_MOVEMENT_PROJECTILE
			if(SKILL_CATEGORY_CONTROLLED_BLAST) return SKILL_MOVEMENT_GUIDED
			if(SKILL_CATEGORY_CONTROLLED_BIG_BLAST) return SKILL_MOVEMENT_GUIDED
			if(SKILL_CATEGORY_BEAM) return SKILL_MOVEMENT_BEAM
			if(SKILL_CATEGORY_EVASIVE) return SKILL_MOVEMENT_DASH
		return SKILL_MOVEMENT_NONE

	proc/resolveSizeClass(category)
		switch(category)
			if(SKILL_CATEGORY_BIG_BLAST) return SKILL_SIZE_BIG
			if(SKILL_CATEGORY_CONTROLLED_BIG_BLAST) return SKILL_SIZE_BIG
		return SKILL_SIZE_NORMAL

	proc/resolveControlMode(category)
		switch(category)
			if(SKILL_CATEGORY_CONTROLLED_BLAST) return SKILL_CONTROL_CONTROLLED
			if(SKILL_CATEGORY_CONTROLLED_BIG_BLAST) return SKILL_CONTROL_CONTROLLED
		return SKILL_CONTROL_UNCONTROLLED

	proc/resolveControllerType(path, category)
		if(ispath(path, /obj/Attacks/Genki_Dama))
			return SKILL_CONTROLLER_GUIDED_BOMB
		switch(category)
			if(SKILL_CATEGORY_CONTROLLED_BLAST) return SKILL_CONTROLLER_GUIDED_BLAST
			if(SKILL_CATEGORY_CONTROLLED_BIG_BLAST) return SKILL_CONTROLLER_GUIDED_BLAST
		return SKILL_CONTROLLER_NONE

	proc/resolveHomingMode(path, category)
		for(var/override_type in homing_mode_overrides)
			if(ispath(path, override_type))
				return homing_mode_overrides[override_type]
		switch(category)
			if(SKILL_CATEGORY_CONTROLLED_BLAST) return SKILL_HOMING_GUIDED
			if(SKILL_CATEGORY_CONTROLLED_BIG_BLAST) return SKILL_HOMING_GUIDED
		return SKILL_HOMING_NONE

	proc/resolveHomingMod(path)
		for(var/override_type in homing_mod_overrides)
			if(ispath(path, override_type))
				return homing_mod_overrides[override_type]
		return 1

	proc/resolveControlRange(path, category)
		if(category != SKILL_CATEGORY_CONTROLLED_BLAST && category != SKILL_CATEGORY_CONTROLLED_BIG_BLAST)
			return 0
		if(ispath(path, /obj/Attacks/Genki_Dama)) return 30
		if(ispath(path, /obj/Attacks/Kienzan)) return 27
		return 25

	proc/resolveControlBumps(path, category)
		if(category != SKILL_CATEGORY_CONTROLLED_BLAST && category != SKILL_CATEGORY_CONTROLLED_BIG_BLAST)
			return 0
		if(ispath(path, /obj/Attacks/Kienzan)) return 0
		return 5

	proc/resolveControlDelay(category)
		if(category != SKILL_CATEGORY_CONTROLLED_BLAST && category != SKILL_CATEGORY_CONTROLLED_BIG_BLAST)
			return 0
		return ki_projectile_step_delay

	proc/resolveControlMaxSteps(path, category)
		if(category != SKILL_CATEGORY_CONTROLLED_BLAST && category != SKILL_CATEGORY_CONTROLLED_BIG_BLAST)
			return 0
		if(ispath(path, /obj/Attacks/Genki_Dama)) return 80
		return 0

	proc/resolveControlAvoidOwner(path, category)
		if(category != SKILL_CATEGORY_CONTROLLED_BLAST && category != SKILL_CATEGORY_CONTROLLED_BIG_BLAST)
			return 0
		return 1

	proc/resolveControlAvoidOwnerChance(path, category)
		if(category != SKILL_CATEGORY_CONTROLLED_BLAST && category != SKILL_CATEGORY_CONTROLLED_BIG_BLAST)
			return 0
		if(ispath(path, /obj/Attacks/Kienzan)) return 87
		return 85

	proc/resolveControlStopOnDeflect(path, category)
		if(category != SKILL_CATEGORY_CONTROLLED_BLAST && category != SKILL_CATEGORY_CONTROLLED_BIG_BLAST)
			return 0
		if(ispath(path, /obj/Attacks/Genki_Dama)) return 1
		if(ispath(path, /obj/Attacks/Kienzan)) return 1
		return 0

	proc/resolveIcon(path)
		if(ispath(path, /obj/Attacks/Genki_Dama))
			var/icon/genki_icon = initial(path:Genki_Dama_icon)
			if(genki_icon) return genki_icon
		return initial(path:icon)

	proc/resolveDamage(path)
		if(ispath(path, /obj/Attacks/Genki_Dama))
			return initial(path:sb_initial_dmg)
		return 0

	proc/resolveDamageAdd(path)
		if(ispath(path, /obj/Attacks/Genki_Dama))
			return initial(path:sb_dmg_add)
		return 0

	proc/resolveMaxCharge(path)
		if(ispath(path, /obj/Attacks/Genki_Dama))
			return initial(path:sb_max_size)
		return 0

	proc/resolveChargeTime(path)
		if(ispath(path, /obj/Attacks/Genki_Dama))
			return initial(path:sb_charge_time)
		if(ispath(path, /obj/Attacks/Makosen))
			return initial(path:ChargeTime)
		return 0

	proc/applyHomingSettings(mob/user, obj/Blast/blast, datum/SkillDefinition/def, obj/skill_obj)
		if(!def && skill_obj) def = getDefinitionForObj(skill_obj)
		if(!def || !blast) return
		if(def.homing_mode == SKILL_HOMING_AUTO)
			if(user) blast.homing_chance = user.Get_blast_homing_chance(def.homing_mod)
			if(blast.Can_Home) blast.Can_Home = 1
			if(user) blast.blast_homing_target = user.getSelectedTarget(max_dist = 100)

	proc/controlBlast(mob/user, obj/Blast/blast, obj/skill_obj, datum/SkillDefinition/def)
		if(!def && skill_obj) def = getDefinitionForObj(skill_obj)
		if(!def || !blast) return 0
		if(!controller_registry) return 0
		var/controller_id = def.controller_type
		if(!controller_id || controller_id == SKILL_CONTROLLER_NONE) return 0
		var/datum/SkillController/controller = controller_registry.get(controller_id)
		if(!controller) return 0
		if(!hascall(controller, "execute")) return 0
		call(controller, "execute")(user, blast, def, skill_obj)
		return 1

	proc/castSkill(mob/user, obj/skill_obj)
		if(!user || !skill_obj) return 0
		debugLog("SkillEngine cast [skill_obj.type] for [user.key].", user)
		var/path = skill_obj.type
		if(isBeamSkill(path)) return castBeam(user, skill_obj)
		if(ispath(path, /obj/Attacks/Blast)) return castBlast(user, skill_obj)
		if(ispath(path, /obj/Attacks/Big_Bang_Attack)) return castBigBang(user, skill_obj)
		if(ispath(path, /obj/Attacks/Charge)) return castCharge(user, skill_obj)
		if(ispath(path, /obj/Attacks/Cyber_Charge)) return castCyberCharge(user, skill_obj)
		if(ispath(path, /obj/Attacks/Makosen)) return castMakosen(user, skill_obj)
		if(ispath(path, /obj/Attacks/Scatter_Shot)) return castScatterShot(user, skill_obj)
		if(ispath(path, /obj/Attacks/Attack_Barrier)) return castAttackBarrier(user, skill_obj)
		if(ispath(path, /obj/Attacks/Shockwave)) return castShockwave(user, skill_obj)
		if(ispath(path, /obj/Attacks/Explosion)) return toggleExplosion(user, skill_obj)
		if(ispath(path, /obj/Attacks/Genki_Dama)) return castGenkiDama(user, skill_obj)
		if(ispath(path, /obj/Attacks/Kikoho)) return castKikoho(user, skill_obj)
		if(ispath(path, /obj/Attacks/Sokidan)) return castSokidan(user, skill_obj)
		if(ispath(path, /obj/Attacks/Kienzan)) return castKienzan(user, skill_obj)
		if(ispath(path, /obj/Dash_Attack)) return castDashAttack(user, skill_obj)
		if(ispath(path, /obj/WolfFangFist)) return castWolfFangFist(user, skill_obj)
		if(ispath(path, /obj/Dropkick)) return castDropkick(user, skill_obj)
		if(ispath(path, /obj/Shield)) return castShield(user, skill_obj)
		if(ispath(path, /obj/Taiyoken)) return castSolarFlare(user, skill_obj)
		if(ispath(path, /obj/Final_Explosion)) return castFinalExplosion(user, skill_obj)
		return 0

	proc/isBeamSkill(path)
		if(ispath(path, /obj/Attacks) && initial(path:hotbar_type) == "Beam") return 1
		return 0

	proc/castBeam(mob/user, obj/Attacks/skill_obj)
		if(!user || !skill_obj) return 0
		if(!user.z) return 0
		if(user.cant_blast(ignore_attack_check = 1)) return 0
		if(user.using_final_explosion) return 0
		for(var/obj/Attacks/a in user.ki_attacks)
			if(a != skill_obj && (a.charging || a.streaming)) return 0

		if(!skill_obj.charging && !skill_obj.streaming)
			if(user.attacking <= 1)
				if(user.Ki < user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)) return 0
				user.last_beam_charge = world.time
				user.BeamCharge(skill_obj)
		else if(!skill_obj.streaming && skill_obj.charging)
			if(user.attacking)
				if(skill_obj.say_name_when_fired && user.last_beam_charge + 30 <= world.time)
					if(skill_obj.name == "Beam") user.Say("HAAAAAAAAAA!!!")
					else user.Say("[uppertext(skill_obj.name)]!!")
				user.BeamStream(skill_obj)
		else if(skill_obj.streaming)
			user.BeamStop(skill_obj)

		skill_obj.calculate_beam_drain()
		return 1

	proc/castBlast(mob/user, obj/Attacks/Blast/skill_obj)
		if(!user) return 0
		if(!skill_obj) skill_obj = user.blast_obj
		if(!skill_obj) for(var/obj/Attacks/Blast/c in user.ki_attacks) skill_obj = c
		if(!skill_obj) return 0

		skill_obj.Blast_Count = ToOne(skill_obj.Blast_Count)
		if(user.beaming || user.Beam_stunned()) return 0
		if(user.cant_blast()) return 0
		if(user.Ki < user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)) return 0
		skill_obj.Skill_Increase(1 / skill_obj.blast_refire, user)
		user.attacking = 3
		var/delay = user.get_blast_refire()
		if(!user.client) delay = 1
		spawn(delay) if(user) user.attacking = 0
		skill_obj.Experience += 0.05 / skill_obj.blast_refire
		if(world.time - skill_obj.lastBlastSfx > 1.5)
			skill_obj.lastBlastSfx = world.time
			player_view(10, user) << sound('Blast.wav', volume = 10)

		var/amount = Clamp(ToOne(skill_obj.Blast_Count), 1, 4)
		var/datum/CombatDamageBudget/damage_budget = new(skill_blast_total_factor)
		while(amount)
			user.Ki -= user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)

			var/obj/Blast/a = get_cached_blast()
			var/percent = 0.5375 - 0.1875 * Clamp(skill_obj.blast_refire, 0.2, 1)
			var/off_mod = 1
			if(skill_obj.Stun) percent *= 1
			a.Stun = skill_obj.Stun
			a.setStats(user, Percent = percent, Off_Mult = off_mod, Explosion = skill_obj.Explosive, explosion_percent = skill_obj.Explosive ? percent : 0, shared_budget = damage_budget)
			var
				base_speed = 32
				max_speed_bonus = 32 - base_speed
				step_speed = base_speed + (max_speed_bonus / user.Speed_delay_mult(severity = 0.5))
			a.vector_speed = step_speed

			a.from_attack = skill_obj
			a.icon = skill_obj.icon
			CenterIcon(a)
			a.setNexusGlow(getNexusAttackGlowColor(skill_obj), 2.2, 195)
			a.Shockwave = ToOne(1.4 * skill_obj.Shockwave / skill_obj.blast_refire ** 0.4)
			if(prob(100)) a.Explosive = skill_obj.Explosive
			a.dir = user.dir
			a.SafeTeleport(user.loc)
			// Apply character's pixel offset for vectorial positioning
			a.step_x = user.step_x
			a.step_y = user.step_y

			var/turf/t = get_step(a.loc, a.dir)
			if(!t || t.density) a.vector_speed = 32

			a.bound_height = 16
			a.bound_width = 16
			a.bound_y = (32 - a.bound_height) / 2
			a.bound_x = (32 - a.bound_width) / 2
			a.Can_Home = 0
			a.vector_speed = 44
			a.Distance = 47
			var/angle = dir_to_angle_0_360(a.dir)
			var/mob/targ = user.getSelectedTarget(max_dist = 30, dir_angle = user.dir, angle_limit = 18)
			a.blast_homing_target = targ
			if(targ) angle = get_global_angle(a, targ)
			angle += rand(-4, 4)
			a.BlastVectorWalk(angle)
			amount--
		return 1

	proc/castBigBang(mob/user, obj/Attacks/Big_Bang_Attack/skill_obj)
		if(!user || !skill_obj) return 0
		if(user.cant_blast()) return 0
		if(user.Ki < user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)) return 0
		if(prob(10) && skill_obj.Experience < 1) skill_obj.Experience += 0.1
		user.Ki -= user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)
		skill_obj.Skill_Increase(2, user)
		user.attacking = 3
		skill_obj.charging = 1
		user.overlays += user.BlastCharge
		player_view(10, user) << sound('BasicbeamCharge.ogg', volume = 30)
		sleep(TickMult(18 * user.Speed_delay_mult(severity = 0.4)))
		user.overlays -= user.BlastCharge
		if(!user.cant_blast(ignore_attack_check = 1))
			player_view(10, user) << sound('Blast.wav', volume = 70)
			user.Say("BIG BANG ATTACK!!")
			var/obj/Blast/a = get_cached_blast()
			a.setStats(user, Percent = skill_big_bang_damage_factor, Off_Mult = 1, Explosion = 4, \
				explosion_percent = skill_big_bang_damage_factor, max_damage_factor = skill_big_bang_damage_factor * 2)
			applyHomingSettings(user, a, null, skill_obj)
			a.from_attack = skill_obj
			a.Shockwave = 1
			a.icon = skill_obj.icon
			a.dir = user.dir
			a.loc = user.loc
			// Apply character's pixel offset for vectorial positioning
			a.step_x = user.step_x
			a.step_y = user.step_y
			a.BlastAutoTargetGo(boundWidth = 32, boundHeight = 32, vectorSpeed = 44, angleLimit = 27, dist = 60, randomAngle = 0)
		user.attacking = 0
		skill_obj.charging = 0
		return 1

	proc/castCharge(mob/user, obj/Attacks/Charge/skill_obj)
		if(!user || !skill_obj) return 0
		if(user.cant_blast()) return 0
		if(user.Ki < user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)) return 0
		if(prob(10) && skill_obj.Experience < 1) skill_obj.Experience += 0.1
		user.Ki -= user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)
		skill_obj.Skill_Increase(2, user)
		user.attacking = 3
		user.moving_charge = 1
		user.overlays += user.BlastCharge
		player_view(10, user) << sound('BasicbeamCharge.ogg', volume = 20)
		sleep(TickMult(7.5 * user.Speed_delay_mult(severity = 0.6)))
		user.overlays -= user.BlastCharge
		if(!user.cant_blast(ignore_attack_check = 1))
			player_view(10, user) << sound('Blast.wav', volume = 40)
			var/obj/Blast/a = get_cached_blast()
			a.setStats(user, Percent = skill_charge_damage_factor, Off_Mult = 2, Explosion = 2, \
				explosion_percent = skill_charge_damage_factor, max_damage_factor = skill_charge_damage_factor * 2)
			applyHomingSettings(user, a, null, skill_obj)
			a.from_attack = skill_obj
			a.Shockwave = 1
			a.icon = skill_obj.icon
			a.dir = user.dir
			a.loc = user.loc
			// Apply character's pixel offset for vectorial positioning
			a.step_x = user.step_x
			a.step_y = user.step_y
			a.BlastAutoTargetGo(boundWidth = 32, boundHeight = 32, vectorSpeed = 44, angleLimit = 20, dist = 47, randomAngle = 0)
		user.attacking = 0
		user.moving_charge = 0
		return 1

	proc/castCyberCharge(mob/user, obj/Attacks/Cyber_Charge/skill_obj)
		if(!user || !skill_obj) return 0
		if(user.cant_blast()) return 0
		if(user.Ki < user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)) return 0
		if(prob(10) && skill_obj.Experience < 1) skill_obj.Experience += 0.1
		user.Ki -= user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)
		skill_obj.Skill_Increase(2, user)
		user.attacking = 3
		skill_obj.charging = 1
		user.overlays += user.BlastCharge
		player_view(10, user) << sound('BasicbeamCharge.ogg', volume = 20)
		sleep(TickMult(5 * user.Speed_delay_mult(severity = 0.6)))
		user.overlays -= user.BlastCharge
		if(!user.cant_blast(ignore_attack_check = 1))
			player_view(10, user) << sound('Blast.wav', volume = 30)
			var/obj/Blast/a = get_cached_blast()
			a.icon = skill_obj.icon
			a.setStats(user, Percent = skill_cyber_charge_damage_factor, Off_Mult = 2, Explosion = 1, \
				explosion_percent = skill_cyber_charge_damage_factor, max_damage_factor = skill_cyber_charge_damage_factor * 2)
			applyHomingSettings(user, a, null, skill_obj)
			a.from_attack = skill_obj
			a.vector_speed = 32
			a.dir = user.dir
			a.loc = user.loc
			// Apply character's pixel offset for vectorial positioning
			a.step_x = user.step_x
			a.step_y = user.step_y
			if(a) a.blast_walk(ki_projectile_step_delay)
		user.attacking = 0
		skill_obj.charging = 0
		return 1

	proc/castMakosen(mob/user, obj/Attacks/Makosen/skill_obj)
		if(!user || !skill_obj) return 0
		if(user.cant_blast()) return 0
		if(user.Ki < user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)) return 0
		user.attacking = 3
		user.overlays += user.BlastCharge
		player_view(10, user) << sound('BasicbeamCharge.ogg', volume = 20)
		skill_obj.charging = 1
		sleep(TickMult(0.1 * skill_obj.ChargeTime * user.Speed_delay_mult(severity = 0.4)))
		if(user) user.overlays -= user.BlastCharge
		if(!user.cant_blast(ignore_attack_check = 1))
			player_view(10, user) << sound('BasicbeamFire.ogg', volume = 10)
			var/amount = Clamp(ToOne(17 * user.Eff ** 0.25), 1, 20)
			var/datum/CombatDamageBudget/damage_budget = new(skill_makosen_total_factor)
			while(amount)
				amount -= 1
				var/obj/Blast/a = get_cached_blast()
				a.Can_Home = 0
				a.icon = skill_obj.icon
				var/os = 5
				while(os)
					os -= 1
					var/image/i = image(icon = a.icon, icon_state = a.icon_state, pixel_x = rand(-32, 32), pixel_y = rand(-32, 32))
					a.overlays += i
				a.Deflectable = 0
				a.apply_short_range_beam_knock = 0
				a.layer = 4
				a.setStats(user, Percent = skill_makosen_damage_factor, Off_Mult = 1, Explosion = 0, shared_budget = damage_budget)
				a.deflect_difficulty = 4
				a.from_attack = skill_obj
				if(prob(skill_obj.ExplosiveChance)) a.Explosive = skill_obj.Explosiveness
				a.dir = user.dir
				a.pixel_x += rand(-32, 32)
				a.pixel_y += rand(-32, 32)
				a.Distance = 35
				a.is_makosen = 1
				a.loc = pick(Get_step(user, user.dir), Get_step(user, turn(user.dir, 45)), Get_step(user, turn(user.dir, -45)))
				// Apply character's pixel offset for vectorial positioning
				a.step_x = user.step_x
				a.step_y = user.step_y
				var/turf/t = a.loc
				if(t && isturf(t) && t.Owner && t.Health > a.BP) del(a)
				if(a) a.Beam()
				spawn if(a && a.z) a.startKiProjectileWalk(a.dir, max(ki_projectile_step_delay, skill_obj.ShotSpeed * world.tick_lag))
				sleep(TickMult(1))
			user.Ki -= user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)
			skill_obj.Skill_Increase(2, user)
		user.attacking = 0
		skill_obj.charging = 0
		return 1

	proc/castScatterShot(mob/user, obj/Attacks/Scatter_Shot/skill_obj)
		if(!user || !skill_obj) return 0
		if(user.beaming || user.Beam_stunned()) return 0
		if("Scatter shot" in user.active_prompts) return 0

		var/minutes = 1
		if(world.time < user.last_scattershot + (minutes * 60 * 10))
			var/minutes_left = (user.last_scattershot + (minutes * 60 * 10) - world.time) / (10 * 60)
			user << "You can not use scattershot for another [round(minutes_left)] minutes and [round((minutes_left * 60) % 60)] seconds"
			return 0

		for(var/obj/o in skill_obj.scatter_shot_blasts) if(!o.z) skill_obj.scatter_shot_blasts -= o
		if(user.cant_blast()) return 0
		if(!user.move || user.Ki < user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)) return 0

		var/mob/target = user.LungeTarget()
		if(!target)
			user << "No target found"
			return 0

		user.attacking = 3
		var/amount = ToOne(40 * sqrt(user.Eff))
		var/datum/CombatDamageBudget/damage_budget = new(skill_scatter_shot_total_factor)
		skill_obj.Using = 1
		user.last_scattershot = world.time
		while(amount && !user.cant_blast(ignore_attack_check = 1))
			player_view(10, user) << sound('Blast.wav', volume = 20)
			amount -= 1
			flick("Attack", user)
			var/obj/Blast/a = get_cached_blast()
			skill_obj.scatter_shot_blasts += a
			a.Distance = 70
			a.density = 0
			a.vector_speed = 22
			a.icon = skill_obj.icon
			if(prob(100)) a.Explosive = 1
			a.Shockwave = 3
			a.setStats(user, Percent = skill_scatter_shot_damage_factor, Off_Mult = 1, Explosion = 1, \
				explosion_percent = skill_scatter_shot_damage_factor, shared_budget = damage_budget)
			applyHomingSettings(user, a, null, skill_obj)
			a.from_attack = skill_obj
			a.loc = user.loc
			// Apply character's pixel offset for vectorial positioning
			a.step_x = user.step_x
			a.step_y = user.step_y
			var/turf/spot
			var/list/spots
			for(var/turf/t in Circle(9, target)) if(!t.density)
				if(!spots) spots = new/list
				spots += t
			if(spots)
				spot = pick(spots)
				a.Can_Home = 0
				walk_towards(a, spot, 1)
				spawn(rand(20, 25) * user.Speed_delay_mult(severity = 0.5)) if(a && a.z && a.Owner == user)
					a.density = 1
					if(!user || user.getSelectedTarget(target, require_view = FALSE) != target) target = null
					if(target)
						a.blast_homing_target = target
						a.followSelectedTarget(target)
				spawn if(a && a.z && a.Owner == user)
					while(a && a.z && target && a.Owner == user && !a.deflected && user && user.selected_target == target) sleep(TickMult(2))
					if(a && a.z && !a.deflected)
						walk_rand(a)
						spawn(rand(1, 50)) if(a) del(a)
				sleep(TickMult(0.3))
			else if(a) del(a)
		user.Ki -= user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)
		skill_obj.Skill_Increase(5, user)
		user.attacking = 0
		spawn(30 + user.Speed_delay_mult(severity = 0.5) * 4) if(skill_obj) skill_obj.Using = 0
		return 1

	proc/castAttackBarrier(mob/user, obj/Attacks/Attack_Barrier/skill_obj)
		if(!user || !skill_obj) return 0
		user.attack_barrier_obj = skill_obj
		if(skill_obj.Firing_Attack_Barrier)
			skill_obj.Firing_Attack_Barrier = 0
			user << "You stop using Attack Barrier"
			return 1
		if(user.cant_blast()) return 0
		if(user.Ki < user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)) return 0
		user.attacking = 3
		skill_obj.Experience += 0.05
		skill_obj.Firing_Attack_Barrier = 1

		user.overlays += user.BlastCharge
		player_view(10, user) << sound('BasicbeamCharge.ogg', volume = 20)
		sleep(15 + (2 * user.Speed_delay_mult(severity = 0.5)))
		var/orbs_fired = 0

		while(skill_obj.Firing_Attack_Barrier && orbs_fired < 20)
			var/max_blasts = user.MaxAttackBarrierBlasts()
			while(skill_obj && user && skill_obj.Firing_Attack_Barrier && user.attack_barrier_blasts >= max_blasts)
				sleep(5)
			if(user.Ki < user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1))
				skill_obj.Firing_Attack_Barrier = 0
			else if(user.cant_blast(ignore_attack_check = 1) || user.KB || user.KO || user.Stunned())
				skill_obj.Firing_Attack_Barrier = 0
			else
				skill_obj.Skill_Increase(0.6, user)
				user.Ki -= user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)
				flick("Blast", user)
				player_view(10, user) << sound('Blast.wav', 0, 1, 0, 15)
				user.attack_barrier_blasts++
				orbs_fired++
				var/obj/Blast/a = get_cached_blast()
				spawn(rand(600, 900)) if(a && a.z) del(a)
				a.Shockwave = 4
				a.blast_go_over_obstacles_if_cant_destroy = 1
				a.blast_go_over_owner = 1
				a.pass_over_owners_blasts = 1
				a.density = 0
				a.Distance = 99999999999
				a.pixel_x = rand(-16, 16)
				a.pixel_y = rand(-16, 16)
				a.icon = skill_obj.icon
				a.setStats(user, Percent = skill_attack_barrier_damage_factor, Off_Mult = 1, Explosion = 0)
				a.from_attack = skill_obj
				a.dir = user.dir
				a.loc = user.loc
				// Apply character's pixel offset for vectorial positioning
				a.step_x = user.step_x
				a.step_y = user.step_y
				a.attack_barrier_loop()
				sleep(TickMult(1 * user.Speed_delay_mult(severity = 0.3)))
		skill_obj.Firing_Attack_Barrier = 0
		user.attacking = 0
		user.overlays -= user.BlastCharge
		return 1

	proc/castShockwave(mob/user, obj/Attacks/Shockwave/skill_obj)
		if(!user || !skill_obj) return 0
		if(user.beaming || user.Beam_stunned()) return 0
		if(user.tournament_override(fighters_can = 1)) return 0
		if(user.cant_blast()) return 0
		if(user.dash_attacking || user.Ki < user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)) return 0
		if(world.time < user.next_shockwave)
			var/seconds = (user.next_shockwave - world.time) / 10
			user << "You can not use this for another [round(seconds, 0.1)] seconds"
			return 0
		user.ReleaseGrab()
		skill_obj.Skill_Increase(1.5, user)
		user.Ki -= user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)
		user.shockwaving = 1
		var/amount = 7
		player_view(10, user) << sound('Wallhit.ogg', volume = 25)
		spawn if(user) while(amount)
			amount -= 1
			Make_Shockwave(user, 7, sw_icon_size = 256)
			for(var/turf/t in oview(7, user))
				if(prob(10) && !t.density && !t.Water)
					var/dirts = prob(40)
					while(dirts)
						dirts -= 1
						var/image/i = image(icon = 'DamagedGround.dmi', pixel_x = rand(-16, 16), pixel_y = rand(-16, 16))
						t.overlays += i
						t.Remove_Damaged_Ground(i)
			spawn for(var/mob/p in mob_view(10, user)) if(p.z && p != user && p.grabbedObject != user)
				if(!p.AOE_auto_dodge(user, user.loc))
					var/distance = 7 * (((user.Pow + user.Str) / (p.Res + p.End)) ** 0.5) * ((user.BP / p.BP) ** 0.5)
					distance = round(distance)
					if(distance > 30) distance = 30
					p.Shockwave_Knockback(distance, user.loc, bypass_immunity = 1)
					var/dmg = user.getHybridCombatDamage(p, skill_shockwave_damage_factor)
					dmg *= sagas_bonus(user, p)
					user.training_period(p)
					if(p.ki_shield_on())
						dmg *= (p.max_ki / 100) * p.ShieldDamageReduction() / (p.Eff ** shield_exponent) * p.Generator_reduction()
						p.Ki -= dmg
					else p.TakeDamage(dmg)
					spawn if(p && p.drone_module) p.Drone_Attack(user, lethal = 1)
			spawn if(user)
				var/n = 0
				for(var/obj/o in view(7, user)) if(o.z && !o.Bolted && !istype(o, /obj/Turfs/Door))
					n++
					if(n > 10) break
					if(istype(o, /obj/Blast))
						var/obj/Blast/b = o
						if(b.Beam)
							if(user.BP > o.BP * 1.35) del(o)
							else n--
						else
							var/p = 80 * (user.BP / o.BP) ** 0.4
							if(prob(p)) del(o)
							else n--
					else
						if(o.Health <= user.BP) del(o)
						if(o) o.Shockwave_Knockback(10, user.loc)
			sleep(5)

			if(!amount && user) user.shockwaving = 0
		if(user) user.next_shockwave = world.time + 70 * user.Speed_delay_mult(severity = 0.25)
		return 1

	proc/toggleExplosion(mob/user, obj/Attacks/Explosion/skill_obj)
		if(!user || !skill_obj) return 0
		if(!skill_obj.On)
			user << "Explosion skill is now activated, click the ground to trigger."
			skill_obj.On = 1
		else
			user << "Explosion deactivated. Now when you click the ground you will warp there instead."
			skill_obj.On = 0
		return 1

	proc/handleExplosionClick(mob/user, turf/target, obj/Attacks/Explosion/skill_obj)
		if(!user || !target || !skill_obj) return 0
		if(getdist(user, target) > 20) return 0
		if(user.BeamStruggling()) return 0
		if(user.tournament_override()) return 0
		if(user.attacking || user.grabber) return 0
		if(user.Charging_or_Streaming()) return 0
		if(user.Ki < 5)
			user << "You do not have enough energy."
			return 0
		if(world.time - skill_obj.last_use < 20 * user.Speed_delay_mult(severity = 0.35)) return 0

		skill_obj.last_use = world.time
		skill_obj.Skill_Increase(5, user)
		if(skill_obj.Level <= 2) player_view(10, target) << sound('Kiplosion.ogg', volume = 40)
		else player_view(10, target) << sound('Explosion2.wav', volume = 40)
		var/list/l = TurfCircle(7, target)
		var/total_mobs_exploded = 0
		var/total_objs_exploded = 0

		for(var/turf/a in view(skill_obj.Level, target)) if((a in l) && prob(100))
			spawn for(var/v in 1 to 3) if(prob(15) || (a == target && v == 1))
				sleep(rand(2, 4))
				Explosion_Graphics(a, rand(2, 4))
			var/n = 0
			var/craterAlready
			for(var/obj/b in a) if(!istype(b, /obj/Explosion))
				n++
				total_objs_exploded++
				if(total_objs_exploded > 50) break
				if(n > 10) break
				if(b.Health <= user.BP)
					if(!craterAlready)
						BigCrater(pos = locate(b.x, b.y, b.z), minRangeFromOtherCraters = 3)
						craterAlready = 1
					del(b)
			n = 0
			for(var/mob/b in a) if(b != user)
				n++
				if(n > 5) break
				total_mobs_exploded++
				if(total_mobs_exploded > 50) break
				if(!b.AOE_auto_dodge(user, Get_step(b, get_dir(b, target))))
					var/dmg = user.getKiCombatDamage(b, skill_explosion_damage_factor)
					dmg *= sagas_bonus(user, b)
					user.training_period(b)
					if(b.ki_shield_on())
						b.Ki -= dmg * b.ShieldDamageReduction() * (b.max_ki / 100) / (b.Eff ** shield_exponent) * b.Generator_reduction()
					else
						b.TakeDamage(dmg)
						if(b.Health <= 0)
							if(!b.client) b.Death(user)
							else b.KO("[user]")
					if(b && b.drone_module) b.Drone_Attack(user, lethal = 1)
			if((a.Health < user.WallBreakPower()) && user.Is_wall_breaker())
				if(a.Health != 1.#INF)
					a.Health = 0
					a.Destroy()
		user.Ki -= 150
		return 1

	proc/castGenkiDama(mob/user, obj/Attacks/Genki_Dama/skill_obj)
		if(!user || !skill_obj) return 0
		return user.TrySpiritBomb2017(skill_obj)

	proc/castKikoho(mob/user, obj/Attacks/Kikoho/skill_obj)
		if(!user || !skill_obj) return 0
		if(user.Stunned()) return 0
		if(user.cant_blast()) return 0
		if(user.Ki < user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)) return 0

		var/target_was_hit
		var/mob/target = user.GetKikohoTarget()
		if(!target)
			user << "You must have a proper target in front of you"
			return 0

		user.attacking = 3
		skill_obj.charging = 1
		user.KikohoAtmosphereEffect()
		user.KikohoChargeupEffect(grow_til = 0.6)

		var
			chargeup_time = user.KikohoRefire(0.5)
			elapsed_time = 0
			interrupted
			turf/start_loc = user.loc

		while(elapsed_time < chargeup_time)
			elapsed_time++
			if(user.KB || user.Frozen || user.loc != start_loc)
				interrupted = 1
				user.ApplyStun(time = 15, no_immunity = 1, stun_power = 6)
				break
			else sleep(TickMult(1))

		if(!interrupted)
			target = user.GetKikohoTarget(target)
			if(target && !user.cant_blast(ignore_attack_check = 1))
				user.dir = get_dir(user, target)
				user.Ki -= user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)
				skill_obj.Skill_Increase(1, user)

				target_was_hit = 1
				player_view(20, user) << sound('Wallhit.ogg', volume = 40)
				target.GetHitByKikoho(user)
				user.KikohoKnockAwayNonTargets(target)

				user.kikoho_damage += kikoho_self_dmg
				user.KikohoDamageLoop()

		if(target_was_hit)
			sleep(user.KikohoRefire(0.5))
			if(interrupted) sleep(user.KikohoRefire(2))

		user.attacking = 0
		skill_obj.charging = 0
		return 1

	proc/castDashAttack(mob/user, obj/Dash_Attack/skill_obj)
		if(!user) return 0
		if(!skill_obj) skill_obj = locate(/obj/Dash_Attack) in user
		var/turf/t = user.loc
		if(!istype(t, /turf)) return 0

		if(user.dash_attacking || user.lunge_attacking || user.grabbedObject || user.in_dragon_rush) return 0
		if(user.lastDashAttack && world.time - user.lastDashAttack < 100)
			user << "Dash Attack is still on cooldown."
			return 0
		if(user.tournament_override()) return 0
		var/drain = 145 * (user.max_ki / 3000) ** 0.5
		if(user.Ki < drain)
			user << "You do not have enough energy"
			return 0
		if(user.Beam_stunned()) return 0

		user.dash_attacking = 1
		user.attack_forced_movement = 1
		user.original_dash_dir = user.dir
		user.lastDashAttack = world.time
		if(skill_obj && skill_obj.icon) user.overlays += skill_obj.icon
		for(var/steps in 1 to 25)
			if(user.KB) break
			var/dash_dir = user.original_dash_dir
			if(user.desired_dash_dir && round(steps / 3) == steps / 3)
				dash_dir = user.desired_dash_dir
				user.desired_dash_dir = 0
			if(!step(user, dash_dir)) break
			for(var/mob/p in mob_view(1, user))
				if(p != user)
					var/damage_factor = min(skill_dash_attack_max_factor, \
						skill_dash_attack_min_factor + (steps - 1) * skill_dash_attack_step_factor)
					var/damage = user.getPhysicalCombatDamage(p, damage_factor)
					var/acc = user.get_melee_accuracy(p) * 2
					var/kb_distance = (user.BP / p.BP) * (user.Str / p.End) * 5
					if(prob(acc))
						flick("Attack", user)
						if(p.ki_shield_on())
							p.Ki -= damage * p.ShieldDamageReduction() * (p.max_ki / 100) / (p.Eff ** shield_exponent) * p.Generator_reduction(is_melee = 1)
						else
							p.TakeDamage(damage)
						if(p.Health <= 0 || p.Ki <= 0) p.KO(user)
						if(p) p.DashAttackPart2(user, kb_distance)
						user.Ki -= drain
						if(skill_obj && skill_obj.icon) user.overlays -= skill_obj.icon
						user.attack_forced_movement = 0
						user.dash_attacking = 0
						return 1
					else
						flick('Zanzoken.dmi', p)
						step(p, turn(user.dir, pick(90, -90)))
			user.AfterImage(20)
			sleep(TickMult(0.7 * user.Speed_delay_mult(severity = 0.25)))
		user.Ki -= drain
		if(skill_obj && skill_obj.icon) user.overlays -= skill_obj.icon
		user.attack_forced_movement = 0
		user.dash_attacking = 0
		return 1

	proc/castWolfFangFist(mob/user, obj/WolfFangFist/skill_obj)
		if(!user) return 0
		if(world.time < user.last_WolfFangFist + (200))
			var/minutes_left = (user.last_WolfFangFist + (200) - world.time) / (10 * 60)
			user << "You can not use Wolf fang fist for another [round(minutes_left)] minutes and [round((minutes_left * 60) % 60)] seconds"
			return 0
		if(!user.CanMeleeFromOtherCauses()) return 0
		if(user.cant_blast()) return 0
		var/mob/victim = user.LungeTarget()
		if(!victim)
			user << "No target found"
			return 0
		user.last_WolfFangFist = world.time

		player_view(35, user) << sound('WolfHowl.mp3', volume = 35)
		user.Do_lunge_drawback_animation()
		sleep(TickMult(2 + user.Get_melee_delay(mult = 2)))
		victim = user.getSelectedTarget(victim, max_dist = user.Get_lunge_targeting_distance())
		if(!victim)
			user.AddStamina(-20)
			return 0

		var/flying = user.Flying
		user.Fly()

		var/targ_dist = getdist(user, victim)
		var/max_dist = targ_dist + 20
		for(var/s in 1 to max_dist)
			if(!victim || user.selected_target != victim) break
			user.AfterImage(20)
			var/success = step_towards(user, victim.base_loc(), 32)
			if(user.WolfFangFistCancelled(victim, success))
				break
			else sleep(world.tick_lag)

		if(!flying) user.Land()

		var/hitcount = 0
		for(var/hit_number in 1 to user.numberOfHits)
			if(!victim || user.selected_target != victim || victim.KO) break
			while(victim && user.selected_target == victim && getdist(user, victim) > 1)
				if(!vector_step_toward(user, victim, 32)) break
				user.AfterImage(12)
				sleep(world.tick_lag)
			if(!victim || getdist(user, victim) > 1) break

			var/accuracy = user.get_melee_accuracy(victim)
			if(hit_number == 1) accuracy *= 2
			if(!prob(accuracy))
				player_view(15, user) << sound('Meleemiss3.ogg', volume = 35)
				break
			hitcount++
			player_view(15, user) << sound('Strongpunch.ogg', volume = 60)
			flick("Attack", user)
			user.ScreenShake(Amount = 8, Offset = 5)
			victim.ScreenShake(Amount = 12, Offset = 7)
			var/dmg = user.getPhysicalCombatDamage(victim, wolf_fang_hit_damage_mult)
			victim.TakeDamage(dmg, 1)
			if(victim && !victim.KO) victim.Knockback(user, Distance = wolf_fang_knockback_distance, bypass_immunity = 1)
			sleep(2)
		if(!hitcount)
			user.AddStamina(-20)
			return 0
		user << "Wolf Fang Fist landed [hitcount] hit[hitcount == 1 ? "" : "s"]."
		return 1

	proc/castDropkick(mob/user, obj/Dropkick/skill_obj)
		if(!user) return 0
		if(user.Health <= 10 || (user.Ki <= user.max_ki / 10)) return 0
		if(world.time < user.last_dropkick + (300))
			var/minutes_left = (user.last_dropkick + (300) - world.time) / (10 * 60)
			user << "You can not use Dropkick another [round(minutes_left)] minutes and [round((minutes_left * 60) % 60)] seconds"
			return 0
		if(!user.CanMeleeFromOtherCauses()) return 0
		if(user.cant_blast()) return 0
		var/mob/m = user.LungeTarget()
		if(!m)
			user << "No target found"
			return 0
		user.attacking = 1
		user.last_dropkick = world.time
		user.AlterInputDisabled(1)

		user.DropkickFX()
		player_view(15, user) << sound('Throw.ogg', volume = 35)
		user.Do_lunge_drawback_animation()
		sleep(TickMult(2 + user.Get_melee_delay(mult = 2)))
		m = user.getSelectedTarget(m, max_dist = user.Get_lunge_targeting_distance())
		if(!m)
			user.attacking = 0
			user.AlterInputDisabled(-1)
			return 0

		var/flying = user.Flying
		user.Fly()

		var/cardinal_dir = cardinal_pixel_dir(user, m)
		var/rot_ang = 0
		if(cardinal_dir == NORTH) rot_ang = 180
		if(cardinal_dir == WEST) rot_ang = 90
		if(cardinal_dir == EAST) rot_ang = -90
		user.transform = turn(user.transform, rot_ang)
		spawn(5) if(user) user.transform = turn(user.transform, -rot_ang)

		var/targ_dist = getdist(user, m)
		var/max_dist = targ_dist + 8
		for(var/s in 1 to max_dist)
			if(!m || user.selected_target != m) break
			user.AfterImage(8)
			var/success = step_towards(user, m.base_loc(), 32)
			if(user.DropkickCancelled(m, success)) break
			else sleep(world.tick_lag)

		if(!flying) user.Land()

		var/hit = m && user.selected_target == m && prob(user.get_melee_accuracy(m) * 2)
		if(!m || getdist(user, m) > 1) hit = 0
		if(!hit) player_view(15, user) << sound('Meleemiss3.ogg', volume = 35)

		user.ScreenShake(Amount = 15, Offset = 8)
		if(m && hit)
			player_view(15, user) << sound('Strongpunch.ogg', volume = 60)
			m.AlterInputDisabled(1)
			m.ScreenShake(Amount = 15, Offset = 8)
			var/dmg = user.getPhysicalCombatDamage(m, skill_dropkick_opening_factor)
			var/hp_before_dmg = m.Health
			m.TakeDamage(dmg)
			if(dmg >= 100 + hp_before_dmg) m.KO(user, allow_anger = 1)
			else if(dmg >= hp_before_dmg) m.KO(user)
			sleep(2)
			if(m)
				m.AlterInputDisabled(-1)

				var/stun_time = 60 * (user.BP / m.BP) ** 0.5
				var/stun_power = 2 * (user.BP / m.BP) ** 0.5
				m.ApplyStun(time = stun_time, no_immunity = 1, stun_power = stun_power)

				var/base_dist = 0
				var/dist = base_dist * (user.BP / m.BP) ** 0.5 * (user.End / m.Str) ** 0.5
				dist = Clamp(dist, 0, base_dist * 3)
				m.Knockback(user, Distance = dist, bypass_immunity = 1, from_lunge = 1)

				if(user.Fatal)
					if(m.KO || m.Health <= 0)
						Explosion_Graphics(m, 3)
						m.SaitamaBloodEffect(blood_range = 3, blood_chance = 50)
						m.Death(user)

		user.last_dropkick_debuff_triggered = world.time
		if(m && hit && user.selected_target == m) m.TakeDamage(user.getPhysicalCombatDamage(m, skill_dropkick_finisher_factor))

		if(user.Health < 0)
			user.KO(user)
		user.AddStamina(-25)
		user.attacking = 0
		sleep(3)
		user.AlterInputDisabled(-1)
		return 1

	proc/castShield(mob/user, obj/Shield/skill_obj)
		if(!user) return 0
		if(!skill_obj) skill_obj = locate(/obj/Shield) in user
		if(!skill_obj) return 0
		if(user.KO) return 0
		if(!skill_obj.Using)
			if(user.CanUseKiShield())
				skill_obj.Using = 1
				user.Shield()
				user.Ki_shield_revert_loop()
		else user.Shield_Revert()
		return 1

	proc/castSolarFlare(mob/user, obj/Taiyoken/skill_obj)
		if(!user) return 0
		if(!user.CanSolarFlare()) return 0
		user.SolarFlare()
		return 1

	proc/castFinalExplosion(mob/user, obj/Final_Explosion/skill_obj)
		if(!user) return 0
		if(!user.charging_final_explosion && !user.using_final_explosion)
			if(user.cant_blast()) return 0
			if(user.tournament_override(fighters_can = 1)) return 0
			user << "Tap again to unleash the explosion"
			user.BeginChargingFinalExplosion()
		else
			if(user.charging_final_explosion)
				user.DoFinalExplosion()
		return 1

	proc/castSokidan(mob/user, obj/skill_obj)
		if(!user || !skill_obj) return 0
		if(world.time - user.lastSokidan < 20)
			debugLog("Sokidan blocked: cooldown.", user)
			return 0
		if(user.cant_blast())
			debugLog("Sokidan blocked: cant_blast.", user)
			return 0
		if(!user.move || user.Ki < user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1))
			debugLog("Sokidan blocked: move or Ki.", user)
			return 0
		var/turf/t = Get_step(user, NORTH)
		if(t)
			var/obstacle
			for(var/obj/o in t) if(o.density && !istype(o, /obj/Blast))
				obstacle = 1
				break
			if(t.density) obstacle = 1
			if(obstacle)
				user << "You can not use this here because there is an obstacle above you"
				debugLog("Sokidan blocked: obstacle.", user)
				return 0
		skill_obj.Using = 1
		user.attacking = 3

		if(user.h1_overhead_gfx)
			user.icon_state = "1H Overhead Charge"
		user.Ki -= user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)
		if(skill_obj) skill_obj.Skill_Increase(3, user)
		player_view(10, user) << sound('BasicbeamCharge.ogg', volume = 20)

		var/obj/Blast/A = get_cached_blast()
		A.Sokidan = 1
		A.blast_go_over_obstacles_if_cant_destroy = 1
		A.Stun = 2
		A.Distance = 180
		A.icon = skill_obj.icon
		A.loc = Get_step(user, NORTH)
		A.Shockwave = 2
		A.Piercer = 0
		A.vector_speed = 22
		A.setStats(user, Percent = skill_sokidan_damage_factor, Off_Mult = 3, Explosion = 2, homing_mod = 2, \
			explosion_percent = skill_sokidan_damage_factor, max_damage_factor = skill_sokidan_total_factor, owner_immunity = 1)
		A.from_attack = skill_obj
		A.weaker_obstacles_cant_destroy_blast = 1
		A.blast_go_over_owner = 1

		sleep(TickMult(7 * user.Speed_delay_mult(severity = 0.7)))

		if(user.h1_overhead_gfx)
			user.icon_state = ""

		if(A && A.z)
			player_view(10, user) << sound('Blast.wav', volume = 40)
			if(user.dir == SOUTH) A.density = 0
			flick("Attack", user)
			var/controlled = 0
			applyHomingSettings(user, A, null, skill_obj)
			controlled = controlBlast(user, A, skill_obj)
			if(!controlled && A && A.z) A.startKiProjectileWalk(A.dir)

		skill_obj.Using = 0
		user.attacking = 0
		user.lastSokidan = world.time
		debugLog("Sokidan fired.", user)
		return 1

	proc/castKienzan(mob/user, obj/skill_obj)
		if(!user || !skill_obj) return 0
		if(user.cant_blast())
			debugLog("Kienzan blocked: cant_blast.", user)
			return 0
		if(!user.move || user.Ki < user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1))
			debugLog("Kienzan blocked: move or Ki.", user)
			return 0
		var/turf/t = Get_step(user, NORTH)
		if(t)
			var/obstacle
			for(var/obj/o in t) if(o.density && !istype(o, /obj/Blast))
				obstacle = 1
				break
			if(t.density) obstacle = 1
			if(obstacle)
				user << "You can not use this here because there is an obstacle above you"
				debugLog("Kienzan blocked: obstacle.", user)
				return 0
		skill_obj.Using = 1
		user.attacking = 3
		if(user.h1_overhead_gfx)
			user.icon_state = "1H Overhead Charge"
		user.Ki -= user.GetSkillDrain(mod = skill_obj.Drain, is_energy = 1)
		if(skill_obj) skill_obj.Skill_Increase(3, user)
		player_view(10, user) << sound('DestructodiscCharge.ogg', volume = 35)

		var/obj/Blast/A = get_cached_blast()
		A.Sokidan = 1
		A.Distance = 180
		A.blast_go_over_obstacles_if_cant_destroy = 1
		A.icon = skill_obj.icon
		A.loc = Get_step(user, NORTH)
		A.Shockwave = 0
		A.Piercer = 1
		A.slice_attack = 1
		A.setStats(user, Percent = skill_kienzan_damage_factor, Off_Mult = 15, Explosion = 0, \
			owner_immunity = 1)
		A.from_attack = skill_obj
		A.vector_speed = 22
		A.weaker_obstacles_cant_destroy_blast = 1
		A.blast_go_over_owner = 1
		A.setNexusGlow("#fff176", 2.5, 220)
		user.pulseNexusGlow("#fff176", 2.8, 195, 12)

		sleep(TickMult(12 * user.Speed_delay_mult(severity = 0.3)))
		if(user && user.h1_overhead_gfx)
			user.icon_state = ""
		if(A)
			player_view(10, user) << sound('DiscFire.ogg', volume = 35)
			if(user.dir == SOUTH) A.density = 0
			flick("Attack", user)
			var/controlled = 0
			applyHomingSettings(user, A, null, skill_obj)
			controlled = controlBlast(user, A, skill_obj)
			if(!controlled && A && A.z) A.startKiProjectileWalk(A.dir)
		skill_obj.Using = 0
		if(user) user.attacking = 0
		debugLog("Kienzan fired.", user)
		return 1

	proc/debugLog(message, mob/receiver)
		if(!skill_engine_debug) return
		if(receiver && receiver.client)
			receiver << message
		else
			world.log << message
