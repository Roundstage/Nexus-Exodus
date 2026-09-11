proc/runSkillArtworkSmokeTests()
	var/mob/owner = new
	var/obj/Attacks/NexusMeleeTechnique/Slice/skill = new(owner)
	var/obj/items/item = new(owner)
	item.icon = 'src/Icons/Unsorted/UserNamesBarsUi.png'
	var/original_icon = skill.icon
	var/original_state = skill.icon_state
	var/original_direction = skill.dir
	var/original_color = skill.color
	var/resource_name = getNexusBrowserAtomIconResource(owner, skill)
	nexusSmokeAssert(findtext(resource_name, "nexus_skill_") == 1 && resource_name == getNexusSkillArtworkResource(owner, skill.type), "Skill browser did not resolve the dedicated artwork")
	nexusSmokeAssert(resource_name != getNexusSkillArtworkResource(owner, /obj/Zanzoken), "Different skills share the same artwork resource")
	nexusSmokeAssert(skill.icon == original_icon && skill.icon_state == original_state && skill.dir == original_direction && skill.color == original_color, "Interface artwork changed the gameplay sprite")
	skill.icon = null
	nexusSmokeAssert(getNexusBrowserAtomIconResource(owner, skill) == resource_name, "An iconless skill lost its interface artwork")
	owner.initializeClassicSlots()
	owner.nexus_classic_slots[1] = owner.classicBindingForObject(skill)
	var/list/bar = owner.buildClassicActionBar()
	var/list/slot = bar[1]
	nexusSmokeAssert(slot["icon"] == resource_name && !slot["fallback"], "Iconless skill hotbar slot uses a category fallback")
	skill.icon = original_icon
	nexusSmokeAssert(!getNexusSkillArtworkFile(item.type) && findtext(getNexusBrowserAtomIconResource(owner, item), "nexus_atom_") == 1, "Skill artwork replaced an inventory sprite")
	nexusSmokeAssert(!getNexusSkillArtworkFile(/obj) && !getNexusSkillArtworkFile(null), "Artwork lookup leaked to an unrelated or missing type")
	var/icon/native_icon = getNexusHotbarSkillIcon(skill)
	nexusSmokeAssert(native_icon.Width() == 32 && native_icon.Height() == 32, "Native hotbar artwork is not 32 pixels")
	nexusSmokeAssert(native_icon == getNexusHotbarSkillIcon(skill), "Native hotbar artwork was not cached")
	var/list/north = list("kind" = "action", "action id" = "zanzoken_north")
	var/list/south = list("kind" = "action", "action id" = "zanzoken_south")
	var/zanzoken_resource = getNexusSkillArtworkResource(owner, /obj/Zanzoken)
	nexusSmokeAssert(getNexusBindingSkillArtworkResource(owner, north) == zanzoken_resource && getNexusBindingSkillArtworkResource(owner, south) == zanzoken_resource, "Directional Zanzoken shortcuts lost the parent skill artwork")
	var/list/train_binding = list("kind" = "verb", "source" = "mob", "verb" = "/mob/verb/Train_verb")
	nexusSmokeAssert(getNexusBindingSkillArtworkResource(owner, train_binding) == getNexusSkillArtworkResource(owner, /obj/Train), "Native skill verb and proxy artwork differ")
	var/list/transform_binding = list("kind" = "verb", "source" = "mob", "verb" = "/mob/verb/Transform")
	nexusSmokeAssert(getNexusBindingSkillArtworkResource(owner, transform_binding), "Transformation verb has no artwork")
	var/datum/NexusProgressionTreeWindow/tree = new(owner)
	var/datum/ProgressionNode/node = new
	node.reward_kind = "skill"
	node.reward_type = skill.type
	nexusSmokeAssert(findtext(tree.buildNodeIcon(node), resource_name), "Progression node artwork differs from the owned skill")
	node.reward_kind = "magic"
	node.reward_type = /obj/Arcane_Crafting
	node.icon_file = item.icon
	nexusSmokeAssert(!findtext(tree.buildNodeIcon(node), "nexus_skill_"), "Crafting recipe icon was replaced by the skill illustration")
	del(node)
	del(tree)
	del(item)
	del(skill)
	del(owner)
