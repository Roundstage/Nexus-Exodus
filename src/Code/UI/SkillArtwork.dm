// Interface illustrations are separate from combat/projectile and world sprites.
client/var/tmp/list/nexus_skill_artwork_resources = list()
var/list/nexus_skill_artwork_native_cache = list()

proc/getNexusSkillArtworkFile(skill_type)
	if(!skill_type) return null
	switch("[skill_type]")
		if("/mob/verb/Grab") skill_type = /obj/Grab
		if("/mob/verb/Injure") skill_type = /obj/Injure
		if("/mob/verb/Med_verb") skill_type = /obj/Meditate
		if("/mob/verb/Train_verb") skill_type = /obj/Train
	return nexus_skill_artwork_files["[skill_type]"]

proc/getNexusSkillArtworkResource(mob/viewer, skill_type)
	var/art_file = getNexusSkillArtworkFile(skill_type)
	if(!art_file) return null
	var/resource_name = "nexus_skill_[md5("[nexus_skill_artwork_revision]|[art_file]")].png"
	if(viewer && viewer.client)
		if(!islist(viewer.client.nexus_skill_artwork_resources)) viewer.client.nexus_skill_artwork_resources = list()
		if(!viewer.client.nexus_skill_artwork_resources[resource_name])
			viewer << browse_rsc(art_file, resource_name)
			viewer.client.nexus_skill_artwork_resources[resource_name] = TRUE
	return resource_name

proc/getNexusSkillArtworkIcon(skill_type)
	var/art_file = getNexusSkillArtworkFile(skill_type)
	if(!art_file) return null
	var/cache_key = "[art_file]"
	if(!nexus_skill_artwork_native_cache[cache_key])
		var/icon/art_icon = icon(art_file)
		art_icon.Scale(32, 32)
		nexus_skill_artwork_native_cache[cache_key] = art_icon
	return nexus_skill_artwork_native_cache[cache_key]

proc/getNexusHotbarSkillIcon(obj/subject)
	if(!subject) return null
	var/icon/art_icon = getNexusSkillArtworkIcon(subject.type)
	return art_icon ? art_icon : Get_hotbar_type_icon(subject.hotbar_type)

datum/NexusHotkeyAction/var/artwork_type
datum/NexusHotkeyAction/Zanzoken/artwork_type = /obj/Zanzoken
datum/NexusHotkeyAction/DefensiveDash/artwork_type = /obj/Evade

proc/getNexusBindingSkillArtworkResource(mob/viewer, list/binding)
	if(!islist(binding)) return null
	switch(binding["kind"])
		if("object") return getNexusSkillArtworkResource(viewer, binding["object type"])
		if("action")
			var/datum/NexusHotkeyAction/action = getNexusHotkeyAction(binding["action id"])
			if(action) return getNexusSkillArtworkResource(viewer, action.artwork_type)
		if("verb") return getNexusSkillArtworkResource(viewer, binding["source"] == "object" ? binding["object type"] : binding["verb"])
	return null
