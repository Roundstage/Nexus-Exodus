proc/PopulateClothesChoices()
	for(var/A in typesof(/obj/items/Clothes)) if(A != /obj/items/Clothes)
		var/obj/items/Clothes/c = new A
		c.underlays += pick('BaseHumanTan.dmi','BaseHumanPale.dmi','BaseHumanDark.dmi')
		c.dir = SOUTH
		Clothing += c
		var/obj/weights_icon/wi=new
		wi.appearance = c.appearance
		weights_icons += wi

		Clothing = SortListOfObjectsAlphabetically(Clothing)

mob/proc/Clothes_Equip(obj/A) if(A.loc==src)
	var/obj/items/item = A
	if(item) item.appearance_managed = TRUE
	if(!A.suffix)
		A.suffix="Equipped"
	else
		A.suffix=null
	rebuildPlayerAppearance("equipment toggle")

mob/proc/Clothes_Proc(obj/A)
	if(A in Clothing)
		var/obj/B=new A.type
		var/RGB=input(src,"Choose color. Hit Cancel to have default color.") as color|null
		if(!B) return
		if(RGB) B.icon+=RGB
		B.Move(src)
	else Clothes_Equip(A)

var/list/Clothing=new

obj/items/Clothes
	clonable = 1
	Savable=0
	can_change_icon=1
	ignore_body_swap=1

	verb/Hotbar_use()
		set hidden=1
		usr.Clothes_Proc(src)

	Chadku_Suit
		icon = 'GokuSuit.dmi'
		Click() usr.Clothes_Proc(src)

	Black_Chadku_Suit
		icon = 'BlackGokuSuitFixed.dmi'
		Click() usr.Clothes_Proc(src)

	Phoenix_Torso_Makyo
		icon='PhoenixTorsoMakyo.dmi'
		Click() usr.Clothes_Proc(src)

	Phoenix_Torso
		icon='PhoenixTorso.dmi'
		Click() usr.Clothes_Proc(src)

	Phoenix_Pauldrons_Makyo
		icon='PhoenixPauldronsMakyo.dmi'
		Click() usr.Clothes_Proc(src)

	Phoenix_Pauldrons
		icon='PhoenixPauldrons.dmi'
		Click() usr.Clothes_Proc(src)

	Uncoloured_Armour_Plating
		name = "Armor Plating"
		icon='UncolouredArmourPlating.dmi'
		Click() usr.Clothes_Proc(src)

	Mandalorian_Helmet
		icon='MandalorianHelmet.dmi'
		Click() usr.Clothes_Proc(src)

	Jumpsuit
		icon='Jumpsuit.dmi'
		Click() usr.Clothes_Proc(src)

	Dark_Jango
		icon='DarkJango.dmi'
		Click() usr.Clothes_Proc(src)

	Boba_Fett
		icon='BobaFett.dmi'
		Click() usr.Clothes_Proc(src)

	Armour
		icon='Armour.dmi'
		Click() usr.Clothes_Proc(src)

	Tunic
		icon='Tunic.dmi'
		Click() usr.Clothes_Proc(src)

	Side_Cape
		icon='SideCape.dmi'
		Click() usr.Clothes_Proc(src)

	ToS_Wings
		name = "Wings"
		icon='ToSWingsBlack.dmi'
		Click() usr.Clothes_Proc(src)

	Neko_Collar
		icon='NekoCollar.dmi'
		Click() usr.Clothes_Proc(src)

	VV_Gauntlet
		name = "Gauntlet"
		icon='VvGauntletBlack.dmi'
		Click() usr.Clothes_Proc(src)

	Flowing_Cape
		name = "Cape"
		icon='FlowingCape.dmi'
		Click() usr.Clothes_Proc(src)

	Succubus
		icon='Succubus.dmi'
		Click() usr.Clothes_Proc(src)

	Tsujin_Tux
		icon='TuffleTux.dmi'
		Click() usr.Clothes_Proc(src)

	Goggles
		icon='ClothesGoggles.dmi'
		Click() usr.Clothes_Proc(src)

	Backpack
		icon='ClothesBackpack.dmi'
		Click() usr.Clothes_Proc(src)

	Saiyan_Uniform
		icon='ClothesSaiyanSuit.dmi'
		Click() usr.Clothes_Proc(src)

	Nero_Jacket
		icon='ClothesNeroJacket.dmi'
		Click() usr.Clothes_Proc(src)

	Kung_Fu_Shirt
		icon='ClothesKungFuShirt.dmi'
		Click() usr.Clothes_Proc(src)

	Naraku
		icon='ClothesNaraku.dmi'
		Click() usr.Clothes_Proc(src)

	Demon_Arm
		icon='ClothesDemonArm.dmi'
		Click() usr.Clothes_Proc(src)

	Azure_Armor
		icon='ArmorAzure.dmi'
		Click() usr.Clothes_Proc(src)

	Wolf_Hermit
		icon='ClothesWolfHermit.dmi'
		Click() usr.Clothes_Proc(src)

	Gi_Tobi_Uchiha
		icon='ClothesGiCustom.dmi'
		Click() usr.Clothes_Proc(src)

	Wristband
		icon='ClothesWristband.dmi'
		Click() usr.Clothes_Proc(src)

	Angel_Wings
		icon='AngelWings.dmi'
		Click() usr.Clothes_Proc(src)

	Red_Eyes
		icon='RedEyes.dmi'
		Click() usr.Clothes_Proc(src)

	Yellow_Eyes
		icon='YellowEyes.dmi'
		Click() usr.Clothes_Proc(src)

	Full_Yardrat
		name = "Yardrat"
		icon='ClothesFullYardrat.dmi'
		Click() usr.Clothes_Proc(src)

	Turban
		icon='ClothesTurban.dmi'
		Click() usr.Clothes_Proc(src)

	TankTop
		icon='ClothesTankTop.dmi'
		name="Tank Top"
		Click() usr.Clothes_Proc(src)

	ShortSleeveShirt
		icon='ClothesShortSleeveShirt.dmi'
		name="Shirt"
		Click() usr.Clothes_Proc(src)

	Shoes
		icon='ClothesShoes.dmi'
		Click() usr.Clothes_Proc(src)

	Jacket_2
		icon='Jacket2.dmi'
		name="Jacket"
		Click() usr.Clothes_Proc(src)

	Hat
		icon='Hat.dmi'
		Click() usr.Clothes_Proc(src)

	Mask
		icon='Mask.dmi'
		Click() usr.Clothes_Proc(src)

	Sash
		icon='ClothesSash.dmi'
		Click() usr.Clothes_Proc(src)

	Kimono
		icon='ClothesKimono.dmi'
		Click() usr.Clothes_Proc(src)

	Pants
		icon='ClothesPants.dmi'
		Click() usr.Clothes_Proc(src)

	NamekianScarf
		icon='ClothesNamekianScarf.dmi'
		Click() usr.Clothes_Proc(src)
		name="Scarf"

	Akatsuki
		icon='DragonAkatsukiOutfit.dmi'
		Click() usr.Clothes_Proc(src)

	LongSleeveShirt
		icon='ClothesLongSleeveShirt.dmi'
		name="Long Shirt"
		Click() usr.Clothes_Proc(src)

	KaioSuit
		icon='ClothesKaioSuit.dmi'
		name="Kai Suit"
		Click() usr.Clothes_Proc(src)

	Jacket
		icon='ClothesJacket.dmi'
		Click() usr.Clothes_Proc(src)

	Headband
		icon='ClothesHeadband.dmi'
		Click() usr.Clothes_Proc(src)

	Gloves
		icon='ClothesGloves.dmi'
		Click() usr.Clothes_Proc(src)

	Boots
		icon='ClothesBoots.dmi'
		Click() usr.Clothes_Proc(src)

	Bandana
		icon='ClothesBandana.dmi'
		Click() usr.Clothes_Proc(src)

	Belt
		icon='ClothesBelt.dmi'
		Click() usr.Clothes_Proc(src)

	Cape
		icon='ItemPiccoloCape.dmi'
		Click() usr.Clothes_Proc(src)

	Kaio_Shirt
		name = "Kai Shirt"
		icon='ClothesKaioShirt.dmi'
		Click() usr.Clothes_Proc(src)

	Tsurusennin
		name = "Crane Master"
		icon='ClothesTsurusennin.dmi'
		Click() usr.Clothes_Proc(src)

	Shorts
		icon='ClothesFemaleShorts.dmi'
		Click() usr.Clothes_Proc(src)

	Female_Shirt
		icon='ClothesFemaleShirt.dmi'
		name="Shirt"
		Click() usr.Clothes_Proc(src)

	Frontless_Cape
		icon='ClothesCape2.dmi'
		Click() usr.Clothes_Proc(src)

	Female_Gi
		icon='ClothesGiFemale.dmi'
		Click() usr.Clothes_Proc(src)
		name="Gi"

	Ninja_Mask
		icon='ClothesNinjaMask.dmi'
		Click() usr.Clothes_Proc(src)

	Ninja_Mask_2
		icon='ClothesNinjaMask2.dmi'
		name="Ninja Mask"
		Click() usr.Clothes_Proc(src)

	Pimp_Hat
		icon='ClothesPimpHat.dmi'
		Click() usr.Clothes_Proc(src)

	Assassin_Hoodless
		icon='ClothesAssassinHoodless.dmi'
		Click() usr.Clothes_Proc(src)

	Assassin
		icon='ClothesAssassin.dmi'
		Click() usr.Clothes_Proc(src)

	Power_Suit
		icon='Armor8.dmi'
		Click() usr.Clothes_Proc(src)

	Daimaou_Cape
		name = "Daimao Cape"
		icon='ClothesDaimaouCape.dmi'
		Click() usr.Clothes_Proc(src)

	Saiyan_Gloves
		icon='ClothesSaiyanGloves.dmi'
		Click() usr.Clothes_Proc(src)

	Horns
		icon='ClothesHorns.dmi'
		Click() usr.Clothes_Proc(src)

	Book
		icon='ClothesBook.dmi'
		Click() usr.Clothes_Proc(src)

	Saiyan_Shoes
		icon='ClothesSaiyanShoes.dmi'
		Click() usr.Clothes_Proc(src)

	Gi_Bottom
		icon='ClothesGiBottom.dmi'
		Click() usr.Clothes_Proc(src)

	Gi_Top
		icon='ClothesGiTop.dmi'
		Click() usr.Clothes_Proc(src)

	Kitsune
		icon='Kitsune.dmi'
		Click() usr.Clothes_Proc(src)

	Neko
		icon='ClothesNeko.dmi'
		Click() usr.Clothes_Proc(src)

	Tuxedo
		icon='ClothesTuxedo.dmi'
		Click() usr.Clothes_Proc(src)

	Beard
		icon='Beard.dmi'
		Click() usr.Clothes_Proc(src)

	Sunglasses
		icon='ItemSunGlassess.dmi'
		Click() usr.Clothes_Proc(src)

	Tien
		icon='TienClothes.dmi'
		Click() usr.Clothes_Proc(src)

	Kaio_Suit
		name = "Kai Suit"
		icon='ClothesKaioSuitLegacy.dmi'
		Click() usr.Clothes_Proc(src)

	Namekian_Jacket
		icon='ClothesNamekJacket.dmi'
		Click() usr.Clothes_Proc(src)

	Guardian_Robe
		icon='ClothesGuardian.dmi'
		Click() usr.Clothes_Proc(src)

	Daimaou_Robe
		name = "Daimao Robe"
		icon='ClothesDaimaou.dmi'
		Click() usr.Clothes_Proc(src)

	Undies
		icon='ClothesDiaper.dmi'
		Click() usr.Clothes_Proc(src)

	Broly_Waistrobe
		name = "Broly"
		icon='BrolyWaistrobe.dmi'
		Click() usr.Clothes_Proc(src)
	CustomClothing
		icon= 'GokuSuit.dmi'
		Click() usr.Clothes_Proc(src)
