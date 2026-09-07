proc/PopulateClothesChoices()
	for(var/A in typesof(/obj/items/Clothes)) if(A != /obj/items/Clothes)
		var/obj/items/Clothes/c = new A
		c.underlays += pick('src/Icons/PlayerIcons/BaseIcons/NewHumanIconsFromGuppinas/BaseHumanTan.dmi','src/Icons/PlayerIcons/BaseIcons/NewHumanIconsFromGuppinas/BaseHumanPale.dmi','src/Icons/PlayerIcons/BaseIcons/NewHumanIconsFromGuppinas/BaseHumanDark.dmi')
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
		icon = 'src/Icons/PlayerIcons/Clothes/GokuSuit.dmi'
		Click() usr.Clothes_Proc(src)

	Black_Chadku_Suit
		icon = 'src/Icons/PlayerIcons/Clothes/BlackGokuSuitFixed.dmi'
		Click() usr.Clothes_Proc(src)

	Phoenix_Torso_Makyo
		icon='src/Icons/PlayerIcons/Clothes/Exgenesis1212012/PhoenixArmour/PhoenixTorsoMakyo.dmi'
		Click() usr.Clothes_Proc(src)

	Phoenix_Torso
		icon='src/Icons/PlayerIcons/Clothes/Exgenesis1212012/PhoenixArmour/PhoenixTorso.dmi'
		Click() usr.Clothes_Proc(src)

	Phoenix_Pauldrons_Makyo
		icon='src/Icons/PlayerIcons/Clothes/Exgenesis1212012/PhoenixArmour/PhoenixPauldronsMakyo.dmi'
		Click() usr.Clothes_Proc(src)

	Phoenix_Pauldrons
		icon='src/Icons/PlayerIcons/Clothes/Exgenesis1212012/PhoenixArmour/PhoenixPauldrons.dmi'
		Click() usr.Clothes_Proc(src)

	Uncoloured_Armour_Plating
		name = "Armor Plating"
		icon='src/Icons/PlayerIcons/Clothes/Exgenesis1212012/Mandalorian/UncolouredArmourPlating.dmi'
		Click() usr.Clothes_Proc(src)

	Mandalorian_Helmet
		icon='src/Icons/PlayerIcons/Clothes/Exgenesis1212012/Mandalorian/MandalorianHelmet.dmi'
		Click() usr.Clothes_Proc(src)

	Jumpsuit
		icon='src/Icons/PlayerIcons/Clothes/Exgenesis1212012/Mandalorian/Jumpsuit.dmi'
		Click() usr.Clothes_Proc(src)

	Dark_Jango
		icon='src/Icons/PlayerIcons/Clothes/Exgenesis1212012/Mandalorian/DarkJango.dmi'
		Click() usr.Clothes_Proc(src)

	Boba_Fett
		icon='src/Icons/PlayerIcons/Clothes/Exgenesis1212012/Mandalorian/BobaFett.dmi'
		Click() usr.Clothes_Proc(src)

	Armour
		icon='src/Icons/PlayerIcons/Clothes/Exgenesis1212012/Mandalorian/Armour.dmi'
		Click() usr.Clothes_Proc(src)

	Tunic
		icon='src/Icons/PlayerIcons/Clothes/Exgenesis1212012/Tunic.dmi'
		Click() usr.Clothes_Proc(src)

	Side_Cape
		icon='src/Icons/PlayerIcons/Clothes/Exgenesis1212012/SideCape.dmi'
		Click() usr.Clothes_Proc(src)

	ToS_Wings
		name = "Wings"
		icon='src/Icons/PlayerIcons/Clothes/Exgenesis1212012/ToSWingsBlack.dmi'
		Click() usr.Clothes_Proc(src)

	Neko_Collar
		icon='src/Icons/PlayerIcons/Clothes/Exgenesis1212012/NekoCollar.dmi'
		Click() usr.Clothes_Proc(src)

	VV_Gauntlet
		name = "Gauntlet"
		icon='src/Icons/PlayerIcons/Clothes/Exgenesis1212012/VvGauntletBlack.dmi'
		Click() usr.Clothes_Proc(src)

	Flowing_Cape
		name = "Cape"
		icon='src/Icons/PlayerIcons/Clothes/FlowingCape.dmi'
		Click() usr.Clothes_Proc(src)

	Succubus
		icon='src/Icons/PlayerIcons/Clothes/Succubus.dmi'
		Click() usr.Clothes_Proc(src)

	Tsujin_Tux
		icon='src/Icons/PlayerIcons/Clothes/TuffleTux.dmi'
		Click() usr.Clothes_Proc(src)

	Goggles
		icon='src/Icons/PlayerIcons/Clothes/ClothesGoggles.dmi'
		Click() usr.Clothes_Proc(src)

	Backpack
		icon='src/Icons/PlayerIcons/Clothes/ClothesBackpack.dmi'
		Click() usr.Clothes_Proc(src)

	Saiyan_Uniform
		icon='src/Icons/PlayerIcons/Clothes/ClothesSaiyanSuit.dmi'
		Click() usr.Clothes_Proc(src)

	Nero_Jacket
		icon='src/Icons/PlayerIcons/Clothes/ClothesNeroJacket.dmi'
		Click() usr.Clothes_Proc(src)

	Kung_Fu_Shirt
		icon='src/Icons/PlayerIcons/Clothes/ClothesKungFuShirt.dmi'
		Click() usr.Clothes_Proc(src)

	Naraku
		icon='src/Icons/PlayerIcons/Clothes/ClothesNaraku.dmi'
		Click() usr.Clothes_Proc(src)

	Demon_Arm
		icon='src/Icons/PlayerIcons/Clothes/ClothesDemonArm.dmi'
		Click() usr.Clothes_Proc(src)

	Azure_Armor
		icon='src/Icons/PlayerIcons/Clothes/Armor/ArmorAzure.dmi'
		Click() usr.Clothes_Proc(src)

	Wolf_Hermit
		icon='src/Icons/PlayerIcons/Clothes/ClothesWolfHermit.dmi'
		Click() usr.Clothes_Proc(src)

	Gi_Tobi_Uchiha
		icon='src/Icons/PlayerIcons/TobiUchihaIcons/ClothesGiCustom.dmi'
		Click() usr.Clothes_Proc(src)

	Wristband
		icon='src/Icons/PlayerIcons/Clothes/ClothesWristband.dmi'
		Click() usr.Clothes_Proc(src)

	Angel_Wings
		icon='src/Icons/PlayerIcons/Clothes/AngelWings.dmi'
		Click() usr.Clothes_Proc(src)

	Red_Eyes
		icon='src/Icons/Unsorted/Other/RedEyes.dmi'
		Click() usr.Clothes_Proc(src)

	Yellow_Eyes
		icon='src/Icons/Unsorted/Other/YellowEyes.dmi'
		Click() usr.Clothes_Proc(src)

	Full_Yardrat
		name = "Yardrat"
		icon='src/Icons/PlayerIcons/Clothes/ClothesFullYardrat.dmi'
		Click() usr.Clothes_Proc(src)

	Turban
		icon='src/Icons/PlayerIcons/Clothes/ClothesTurban.dmi'
		Click() usr.Clothes_Proc(src)

	TankTop
		icon='src/Icons/PlayerIcons/Clothes/ClothesTankTop.dmi'
		name="Tank Top"
		Click() usr.Clothes_Proc(src)

	ShortSleeveShirt
		icon='src/Icons/PlayerIcons/Clothes/ClothesShortSleeveShirt.dmi'
		name="Shirt"
		Click() usr.Clothes_Proc(src)

	Shoes
		icon='src/Icons/PlayerIcons/Clothes/ClothesShoes.dmi'
		Click() usr.Clothes_Proc(src)

	Jacket_2
		icon='src/Icons/PlayerIcons/Clothes/Jacket2.dmi'
		name="Jacket"
		Click() usr.Clothes_Proc(src)

	Hat
		icon='src/Icons/PlayerIcons/Clothes/Hat.dmi'
		Click() usr.Clothes_Proc(src)

	Mask
		icon='src/Icons/PlayerIcons/Clothes/Mask.dmi'
		Click() usr.Clothes_Proc(src)

	Sash
		icon='src/Icons/PlayerIcons/Clothes/ClothesSash.dmi'
		Click() usr.Clothes_Proc(src)

	Kimono
		icon='src/Icons/PlayerIcons/Clothes/ClothesKimono.dmi'
		Click() usr.Clothes_Proc(src)

	Pants
		icon='src/Icons/PlayerIcons/Clothes/ClothesPants.dmi'
		Click() usr.Clothes_Proc(src)

	NamekianScarf
		icon='src/Icons/PlayerIcons/Clothes/ClothesNamekianScarf.dmi'
		Click() usr.Clothes_Proc(src)
		name="Scarf"

	Akatsuki
		icon='src/Icons/PlayerIcons/TobiUchihaIcons/DragonAkatsukiOutfit.dmi'
		Click() usr.Clothes_Proc(src)

	LongSleeveShirt
		icon='src/Icons/PlayerIcons/Clothes/ClothesLongSleeveShirt.dmi'
		name="Long Shirt"
		Click() usr.Clothes_Proc(src)

	KaioSuit
		icon='src/Icons/PlayerIcons/Clothes/ClothesKaioSuit.dmi'
		name="Kai Suit"
		Click() usr.Clothes_Proc(src)

	Jacket
		icon='src/Icons/PlayerIcons/Clothes/ClothesJacket.dmi'
		Click() usr.Clothes_Proc(src)

	Headband
		icon='src/Icons/PlayerIcons/Clothes/ClothesHeadband.dmi'
		Click() usr.Clothes_Proc(src)

	Gloves
		icon='src/Icons/PlayerIcons/Clothes/ClothesGloves.dmi'
		Click() usr.Clothes_Proc(src)

	Boots
		icon='src/Icons/PlayerIcons/Clothes/ClothesBoots.dmi'
		Click() usr.Clothes_Proc(src)

	Bandana
		icon='src/Icons/PlayerIcons/Clothes/ClothesBandana.dmi'
		Click() usr.Clothes_Proc(src)

	Belt
		icon='src/Icons/PlayerIcons/Clothes/ClothesBelt.dmi'
		Click() usr.Clothes_Proc(src)

	Cape
		icon='src/Icons/PlayerIcons/TobiUchihaIcons/ItemPiccoloCape.dmi'
		Click() usr.Clothes_Proc(src)

	Kaio_Shirt
		name = "Kai Shirt"
		icon='src/Icons/PlayerIcons/Clothes/ClothesKaioShirt.dmi'
		Click() usr.Clothes_Proc(src)

	Tsurusennin
		name = "Crane Master"
		icon='src/Icons/PlayerIcons/Clothes/ClothesTsurusennin.dmi'
		Click() usr.Clothes_Proc(src)

	Shorts
		icon='src/Icons/PlayerIcons/Clothes/ClothesFemaleShorts.dmi'
		Click() usr.Clothes_Proc(src)

	Female_Shirt
		icon='src/Icons/PlayerIcons/Clothes/ClothesFemaleShirt.dmi'
		name="Shirt"
		Click() usr.Clothes_Proc(src)

	Frontless_Cape
		icon='src/Icons/PlayerIcons/Clothes/ClothesCape2.dmi'
		Click() usr.Clothes_Proc(src)

	Female_Gi
		icon='src/Icons/PlayerIcons/Clothes/ClothesGiFemale.dmi'
		Click() usr.Clothes_Proc(src)
		name="Gi"

	Ninja_Mask
		icon='src/Icons/PlayerIcons/Clothes/ClothesNinjaMask.dmi'
		Click() usr.Clothes_Proc(src)

	Ninja_Mask_2
		icon='src/Icons/PlayerIcons/Clothes/ClothesNinjaMask2.dmi'
		name="Ninja Mask"
		Click() usr.Clothes_Proc(src)

	Pimp_Hat
		icon='src/Icons/PlayerIcons/Clothes/ClothesPimpHat.dmi'
		Click() usr.Clothes_Proc(src)

	Assassin_Hoodless
		icon='src/Icons/PlayerIcons/Clothes/ClothesAssassinHoodless.dmi'
		Click() usr.Clothes_Proc(src)

	Assassin
		icon='src/Icons/PlayerIcons/Clothes/ClothesAssassin.dmi'
		Click() usr.Clothes_Proc(src)

	Power_Suit
		icon='src/Icons/PlayerIcons/Clothes/Armor/Armor8.dmi'
		Click() usr.Clothes_Proc(src)

	Daimaou_Cape
		name = "Daimao Cape"
		icon='src/Icons/PlayerIcons/Clothes/ClothesDaimaouCape.dmi'
		Click() usr.Clothes_Proc(src)

	Saiyan_Gloves
		icon='src/Icons/PlayerIcons/Clothes/ClothesSaiyanGloves.dmi'
		Click() usr.Clothes_Proc(src)

	Horns
		icon='src/Icons/PlayerIcons/Clothes/ClothesHorns.dmi'
		Click() usr.Clothes_Proc(src)

	Book
		icon='src/Icons/PlayerIcons/Clothes/ClothesBook.dmi'
		Click() usr.Clothes_Proc(src)

	Saiyan_Shoes
		icon='src/Icons/PlayerIcons/Clothes/ClothesSaiyanShoes.dmi'
		Click() usr.Clothes_Proc(src)

	Gi_Bottom
		icon='src/Icons/PlayerIcons/Clothes/ClothesGiBottom.dmi'
		Click() usr.Clothes_Proc(src)

	Gi_Top
		icon='src/Icons/PlayerIcons/Clothes/ClothesGiTop.dmi'
		Click() usr.Clothes_Proc(src)

	Kitsune
		icon='src/Icons/Unsorted/Other/Kitsune.dmi'
		Click() usr.Clothes_Proc(src)

	Neko
		icon='src/Icons/PlayerIcons/Clothes/ClothesNeko.dmi'
		Click() usr.Clothes_Proc(src)

	Tuxedo
		icon='src/Icons/PlayerIcons/Clothes/ClothesTuxedo.dmi'
		Click() usr.Clothes_Proc(src)

	Beard
		icon='src/Icons/PlayerIcons/Clothes/Beard.dmi'
		Click() usr.Clothes_Proc(src)

	Sunglasses
		icon='src/Icons/Objects/Items/ItemSunGlassess.dmi'
		Click() usr.Clothes_Proc(src)

	Tien
		icon='src/Icons/PlayerIcons/Clothes/TienClothes.dmi'
		Click() usr.Clothes_Proc(src)

	Kaio_Suit
		name = "Kai Suit"
		icon='src/Icons/PlayerIcons/Clothes/ClothesKaioSuitLegacy.dmi'
		Click() usr.Clothes_Proc(src)

	Namekian_Jacket
		icon='src/Icons/PlayerIcons/Clothes/ClothesNamekJacket.dmi'
		Click() usr.Clothes_Proc(src)

	Guardian_Robe
		icon='src/Icons/PlayerIcons/Clothes/ClothesGuardian.dmi'
		Click() usr.Clothes_Proc(src)

	Daimaou_Robe
		name = "Daimao Robe"
		icon='src/Icons/PlayerIcons/Clothes/ClothesDaimaou.dmi'
		Click() usr.Clothes_Proc(src)

	Undies
		icon='src/Icons/PlayerIcons/Clothes/ClothesDiaper.dmi'
		Click() usr.Clothes_Proc(src)

	Broly_Waistrobe
		name = "Broly"
		icon='src/Icons/PlayerIcons/TobiUchihaIcons/BrolyWaistrobe.dmi'
		Click() usr.Clothes_Proc(src)
	CustomClothing
		icon= 'src/Icons/PlayerIcons/Clothes/GokuSuit.dmi'
		Click() usr.Clothes_Proc(src)
