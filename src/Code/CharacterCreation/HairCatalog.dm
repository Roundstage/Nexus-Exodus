// Legacy type paths and fields are retained for saved characters and hair menus.
var/list/Hairs = new

proc/Fill_Hair_List()
	for(var/hair_type in typesof(/obj/Hairs) - /obj/Hairs) Hairs += new hair_type

obj/Hairs
	icon = null
	Givable = 0
	Makeable = 0
	var/SSj_Hair
	var/USSj_Hair
	var/SSjFP_Hair
	var/SSj2_Hair
	var/SSj3_Hair
	var/list/variant_overrides

	New()
		// Match the old catalog constructors: initialization has no world side effects.
		initializeHairVariants()

	Click()
		Apply_Hair(usr, src)

	proc/initializeHairVariants()
		if(!icon) return
		var/static/list/default_recipes = list(
			"ssj" = list("base", "#969600"),
			"ussj" = list("ssj"),
			"full_power" = list("base", "#a0a050"),
			"ssj2" = list("base", "#a0a014"),
			"ssj3" = list('src/Icons/PlayerIcons/Hair/HairSSj4.dmi', "#a0961e")
		)
		var/list/variants = list("base" = icon)
		for(var/variant_key in default_recipes)
			var/list/recipe = variant_overrides ? variant_overrides[variant_key] : null
			if(!recipe) recipe = default_recipes[variant_key]
			var/source_icon = recipe[1]
			if(istext(source_icon)) source_icon = variants[source_icon]
			if(recipe.len > 1) source_icon += recipe[2]
			variants[variant_key] = source_icon
		SSj_Hair = variants["ssj"]
		USSj_Hair = variants["ussj"]
		SSjFP_Hair = variants["full_power"]
		SSj2_Hair = variants["ssj2"]
		SSj3_Hair = variants["ssj3"]

	Bald

	Hair1
		icon = 'src/Icons/PlayerIcons/Hair/HairShaggy.dmi'

	Hair_Caulifla
		icon = 'src/Icons/PlayerIcons/Hair/CauliflaHairByJenny/CauliflaHair.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/CauliflaHairByJenny/CauliflaHairSSJ.dmi'),
			"ussj" = list('src/Icons/PlayerIcons/Hair/CauliflaHairByJenny/CauliflaHairUSSJ.dmi'),
			"full_power" = list('src/Icons/PlayerIcons/Hair/CauliflaHairByJenny/CauliflaHairSSjFP.dmi'),
			"ssj2" = list('src/Icons/PlayerIcons/Hair/CauliflaHairByJenny/CauliflaHairSsj2.dmi'),
			"ssj3" = list("ssj2")
		)

	Hair_Kale
		icon = 'src/Icons/PlayerIcons/Hair/KaleHair.dmi'

	Hair2
		icon = 'src/Icons/PlayerIcons/Hair/HairRen.dmi'

	Hair3
		icon = 'src/Icons/PlayerIcons/Hair/HairShortFemale.dmi'

	Hair4
		icon = 'src/Icons/PlayerIcons/Hair/HairPonytail.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairPonytailSSJ.dmi'),
			"full_power" = list('src/Icons/PlayerIcons/Hair/HairPonytailSsjfp.dmi'),
			"ssj2" = list("ssj")
		)

	Hair5
		icon = 'src/Icons/PlayerIcons/Hair/HairFemalePonytail.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/Unsorted/HairFemalePonyTailSSj.dmi'),
			"full_power" = list('src/Icons/Unsorted/HairFemalePonyTailSSj.dmi'),
			"ssj2" = list('src/Icons/Unsorted/HairFemalePonyTailSSj.dmi')
		)

	Hair6
		icon = 'src/Icons/PlayerIcons/Hair/HairMessy.dmi'

	Hair7
		icon = 'src/Icons/PlayerIcons/Hair/HairBushy.dmi'

	Hair8
		icon = 'src/Icons/PlayerIcons/Hair/HairBrownHeadband.dmi'

	Hair9
		icon = 'src/Icons/PlayerIcons/Hair/HairBlueMale.dmi'

	Hair10
		icon = 'src/Icons/PlayerIcons/Hair/HairCloud.dmi'
		variant_overrides = list(
			"ssj2" = list("base", "#b4b414")
		)

	Hair11
		icon = 'src/Icons/PlayerIcons/Hair/HairSuper17.dmi'

	Hair12
		icon = 'src/Icons/PlayerIcons/Hair/HairKidd.dmi'

	Hair13
		icon = 'src/Icons/PlayerIcons/Hair/HairMuse.dmi'

	Hair14
		icon = 'src/Icons/PlayerIcons/Hair/HairGoku.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairGokuSSj.dmi'),
			"ussj" = list('src/Icons/PlayerIcons/Hair/HairGokuUSSj.dmi'),
			"full_power" = list('src/Icons/PlayerIcons/Hair/HairGokuSSjFP.dmi'),
			"ssj2" = list('src/Icons/PlayerIcons/Hair/HairGokuUSSj.dmi'),
			"ssj3" = list('src/Icons/PlayerIcons/Hair/HairGokuSSj3Old.dmi')
		)

	Hair15
		icon = 'src/Icons/PlayerIcons/Hair/HairVegetaTobiUchiha.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairVegetaSSj.dmi'),
			"ussj" = list('src/Icons/PlayerIcons/Hair/HairVegetaUSSj.dmi'),
			"full_power" = list('src/Icons/PlayerIcons/Hair/HairVegetaSSjFPOld.dmi'),
			"ssj2" = list('src/Icons/PlayerIcons/Hair/HairVegetaSSj.dmi')
		)

	Hair16
		icon = 'src/Icons/PlayerIcons/Hair/HairRaditz.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairRaditzSSj.dmi'),
			"ussj" = list('src/Icons/PlayerIcons/Hair/HairGokuSSj3Old.dmi'),
			"full_power" = list('src/Icons/PlayerIcons/Hair/HairRaditzSSjFP.dmi'),
			"ssj2" = list('src/Icons/PlayerIcons/Hair/HairRaditzSSj.dmi'),
			"ssj3" = list('src/Icons/PlayerIcons/Hair/HairGokuSSj3Old.dmi')
		)

	Hair17
		icon = 'src/Icons/PlayerIcons/Hair/HairFutureGohan.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairGohanSSj.dmi'),
			"ussj" = list('src/Icons/PlayerIcons/Hair/HairGohanUSSj.dmi'),
			"full_power" = list('src/Icons/PlayerIcons/Hair/HairGohanSSjFPOriginal.dmi'),
			"ssj2" = list('src/Icons/PlayerIcons/Hair/HairGohanSSj.dmi')
		)

	Hair18
		icon = 'src/Icons/PlayerIcons/Hair/HairGohan.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairGohanSSj.dmi'),
			"ussj" = list('src/Icons/PlayerIcons/Hair/HairGohanUSSj.dmi'),
			"full_power" = list('src/Icons/PlayerIcons/Hair/HairGohanSSjFP.dmi'),
			"ssj2" = list('src/Icons/PlayerIcons/Hair/HairGohanSSj.dmi')
		)

	Hair19
		icon = 'src/Icons/PlayerIcons/Hair/HairLong.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairTrunksSSj.dmi'),
			"ussj" = list('src/Icons/PlayerIcons/TobiUchihaIcons/HairTrunksUSSj.dmi'),
			"full_power" = list('src/Icons/PlayerIcons/Hair/HairLongSSjFP.dmi'),
			"ssj2" = list('src/Icons/PlayerIcons/Hair/HairTrunksSSj.dmi')
		)

	Hair20
		icon = 'src/Icons/PlayerIcons/Hair/HairKidGohan.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairKidGohanSSj.dmi'),
			"ussj" = list('src/Icons/PlayerIcons/Hair/HairKidGohanUSSj.dmi'),
			"full_power" = list('src/Icons/PlayerIcons/Hair/HairKidGohanSSjFP.dmi'),
			"ssj2" = list('src/Icons/PlayerIcons/Hair/HairKidGohanSSj2.dmi')
		)

	Hair21
		icon = 'src/Icons/PlayerIcons/Hair/HairKylin2.dmi'
		variant_overrides = list(
			"ussj" = list('src/Icons/PlayerIcons/Hair/HairFemaleLongSSj.dmi')
		)

	Hair22
		icon = 'src/Icons/PlayerIcons/Hair/HairKylin3.dmi'

	Hair23
		icon = 'src/Icons/PlayerIcons/Hair/HairAfroLegacy.dmi'
		variant_overrides = list(
			"ssj3" = list("ssj")
		)

	Hair24
		icon = 'src/Icons/PlayerIcons/Hair/HairKylin1.dmi'

	Hair25
		icon = 'src/Icons/PlayerIcons/Hair/HairBroly.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairBrolySSj.dmi'),
			"ussj" = list('src/Icons/PlayerIcons/Hair/HairBrolyLssj.dmi'),
			"full_power" = list("ssj", "#0f0f0f"),
			"ssj2" = list("ssj")
		)

	Hair26
		icon = 'src/Icons/PlayerIcons/Hair/HairFemaleLong2.dmi'
		variant_overrides = list(
			"ussj" = list('src/Icons/PlayerIcons/Hair/HairFemaleLongSSj.dmi')
		)

	Hair27
		icon = 'src/Icons/PlayerIcons/Hair/HairLong.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairTrunksSSj.dmi'),
			"ussj" = list('src/Icons/PlayerIcons/TobiUchihaIcons/HairTrunksUSSj.dmi'),
			"full_power" = list('src/Icons/PlayerIcons/Hair/HairLongSSjFP.dmi'),
			"ssj2" = list('src/Icons/PlayerIcons/Hair/HairTrunksSSj.dmi')
		)

	Hair28
		icon = 'src/Icons/PlayerIcons/Hair/HairGoten.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairGokuSSj.dmi'),
			"ussj" = list('src/Icons/PlayerIcons/Hair/HairGokuUSSj.dmi'),
			"full_power" = list('src/Icons/PlayerIcons/Hair/HairGokuSSjFP.dmi'),
			"ssj2" = list('src/Icons/PlayerIcons/Hair/HairGokuSSj.dmi')
		)

	Hair29
		icon = 'src/Icons/PlayerIcons/Hair/HairGTTrunks.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairTrunksSSj.dmi'),
			"ussj" = list('src/Icons/PlayerIcons/Hair/HairGokuUSSj.dmi'),
			"full_power" = list('src/Icons/PlayerIcons/Hair/HairLongSSjFP.dmi'),
			"ssj2" = list('src/Icons/PlayerIcons/Hair/HairTrunksSSj.dmi')
		)

	Hair30
		icon = 'src/Icons/PlayerIcons/Hair/HairGTVegeta.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairGTVegetaSSj.dmi'),
			"ssj2" = list('src/Icons/PlayerIcons/Hair/HairGTVegetaSSj.dmi')
		)

	Hair31
		icon = 'src/Icons/PlayerIcons/Hair/HairMohawk.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairMohawkSSj.dmi'),
			"ussj" = list('src/Icons/PlayerIcons/TobiUchihaIcons/HairTrunksUSSj.dmi'),
			"ssj2" = list('src/Icons/PlayerIcons/Hair/HairMohawkSSj.dmi')
		)

	Hair32
		icon = 'src/Icons/PlayerIcons/Hair/HairSpike.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairSpikeSSj.dmi'),
			"ssj2" = list("ssj")
		)

	Hair33
		icon = 'src/Icons/PlayerIcons/Hair/HairYamcha.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairYamchaSSj.dmi'),
			"full_power" = list("ssj", "#0f0f0f"),
			"ssj2" = list("ssj")
		)

	Hair34
		icon = 'src/Icons/PlayerIcons/Hair/HairVegetaJunior.dmi'

	Hair35
		icon = 'src/Icons/PlayerIcons/Hair/HairLan.dmi'

	Hair36
		icon = 'src/Icons/PlayerIcons/Hair/BlackSSJhair.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairGokuSSj.dmi'),
			"ussj" = list('src/Icons/PlayerIcons/Hair/HairGokuUSSj.dmi'),
			"full_power" = list('src/Icons/PlayerIcons/Hair/HairGokuSSjFP.dmi'),
			"ssj2" = list('src/Icons/PlayerIcons/Hair/HairGokuUSSj.dmi'),
			"ssj3" = list('src/Icons/PlayerIcons/Hair/HairGokuSSj3.dmi')
		)

	Hair37
		icon = 'src/Icons/PlayerIcons/Hair/VegitoHairPVP.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairGokuUSSj.dmi'),
			"ussj" = list('src/Icons/PlayerIcons/Hair/HairGokuUSSj.dmi'),
			"full_power" = list('src/Icons/PlayerIcons/Hair/VegitoHairPVPSSjFP.dmi'),
			"ssj2" = list('src/Icons/PlayerIcons/Hair/HairGokuUSSj.dmi'),
			"ssj3" = list('src/Icons/PlayerIcons/Hair/HairGokuSSj3.dmi')
		)

	Hair38
		icon = 'src/Icons/PlayerIcons/Hair/ExGenesis/MezuHair.dmi'
		variant_overrides = list(
			"ssj3" = list('src/Icons/PlayerIcons/Hair/ExGenesis/HairSsj4Gogeta.dmi', "#a0961e")
		)

	Hair39
		icon = 'src/Icons/PlayerIcons/Hair/ExGenesis/HairStylishBlack.dmi'
		variant_overrides = list(
			"ssj3" = list('src/Icons/PlayerIcons/Hair/ExGenesis/HairSsj4Gogeta.dmi', "#a0961e")
		)

	Hair40
		icon = 'src/Icons/PlayerIcons/Hair/ExGenesis/HopeFfxiiiHair.dmi'

	Hair41
		icon = 'src/Icons/PlayerIcons/Hair/ExGenesis/HairSsj4Gogeta.dmi'
		variant_overrides = list(
			"ssj3" = list('src/Icons/PlayerIcons/Hair/HairGokuSSj3.dmi', "#a0961e")
		)

	Hair42
		icon = 'src/Icons/PlayerIcons/Hair/ExGenesis/HairHitsugaya.dmi'

	Hair43
		icon = 'src/Icons/PlayerIcons/Hair/LongFemaleHair.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/LongFemaleHairSsj.dmi'),
			"full_power" = list("ssj", "#141414"),
			"ssj2" = list("ssj"),
			"ssj3" = list('src/Icons/PlayerIcons/Hair/HairGokuSSj3.dmi')
		)

	Hair44
		icon = 'src/Icons/PlayerIcons/Hair/HairVegeta.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairVegetaSSj.dmi'),
			"ussj" = list('src/Icons/PlayerIcons/Hair/HairVegetaUSSj.dmi'),
			"full_power" = list('src/Icons/PlayerIcons/Hair/HairVegetaSSjFPOld.dmi'),
			"ssj2" = list('src/Icons/PlayerIcons/Hair/HairVegetaSSj.dmi')
		)

	Hair45
		icon = 'src/Icons/PlayerIcons/Hair/HairFemaleLong.dmi'
		variant_overrides = list(
			"ssj" = list('src/Icons/PlayerIcons/Hair/HairYamchaSSj.dmi'),
			"ussj" = list('src/Icons/PlayerIcons/Hair/HairBrolyLssj.dmi'),
			"full_power" = list("ssj", "#0f0f0f"),
			"ssj2" = list("ssj")
		)

	CustomHair
		icon = 'src/Icons/PlayerIcons/Hair/HairFemaleLong.dmi'
