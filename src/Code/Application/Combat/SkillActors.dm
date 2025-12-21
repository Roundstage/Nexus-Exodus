var/global/datum/SkillActorRegistry/skill_actor_registry = new

datum/SkillActorRegistry
	var/list/actors = list()

	proc/register(datum/SkillActor/actor)
		if(!actor) return
		actors += actor

	proc/unregister(datum/SkillActor/actor)
		if(!actor) return
		actors -= actor

datum/SkillActor
	var
		active = 1
		created_at = 0

	New()
		created_at = world.time

	proc/tick(delta)
		return active

	proc/cleanup()
		return
