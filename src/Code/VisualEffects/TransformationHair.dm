// Read the existing saved hair fields, including player-uploaded variants.
mob/proc/getTransformationHair(variant_key)
	var/static/list/hair_fields = list(
		"base" = "hair", "ssj" = "ssjhair", "ussj" = "ussjhair",
		"full_power" = "ssjfphair", "ssj2" = "ssj2hair", "ssj3" = "ssj3hair",
		"ssj4" = "ssj4hair", "blue" = "ssj_blue_hair", "god" = "ssj_god_hair"
	)
	var/field_name = hair_fields[variant_key]
	if(!field_name) return null
	return vars[field_name]

mob/proc/getActiveTransformationHairKey()
	if(ultra_instinct) return "base"
	if(is_ssj_blue) return "blue"
	if(is_ssg) return "god"
	if(!ssj || ismystic) return "base"
	if(ssj > 0 && ssj < 3 && is_ussj) return "ussj"
	if(ssj == 1) return has_ss_full_power ? "full_power" : "ssj"
	return "ssj[ssj]"

mob/proc/getActiveTransformationHair()
	var/variant_key = getActiveTransformationHairKey()
	var/selected_hair = getTransformationHair(variant_key)
	if(variant_key == "ssj3" && selected_hair == 'src/Icons/PlayerIcons/Hair/HairGokuSSj3.dmi' && ssj3drain >= 300)
		return 'src/Icons/PlayerIcons/Hair/Ssj3Mastered.dmi'
	return selected_hair
