proc/countAppearanceSmokeIcon(mob/character, icon_resource)
	var/count = 0
	// Atom appearances hold an icon resource, while colored hair fields may hold an /icon datum.
	var/image/reference_appearance = image(icon_resource)
	for(var/appearance_value in character.overlays)
		if(appearance_value:icon == reference_appearance.icon) count++
	return count

proc/assertCombatAppearanceSmoke(mob/character, context)
	nexusSmokeAssert(countAppearanceSmokeIcon(character, 'src/Icons/UI/LethalHud.dmi') == (character.sparring_mode == LETHAL_COMBAT ? 1 : 0), "[context]: Lethal overlays disagree with combat intent")
	nexusSmokeAssert(countAppearanceSmokeIcon(character, 'src/Icons/UI/RPModeHud.dmi') == (character.rp_mode ? 1 : 0), "[context]: RP Mode overlays disagree with the active mode")

proc/runAppearanceRebuildSmokeTests()
	for(var/lethal_enabled in list(FALSE, TRUE))
		for(var/rp_enabled in list(FALSE, TRUE))
			var/mob/NexusSmokeTest/character = new
			character.sparring_mode = lethal_enabled ? LETHAL_COMBAT : CASUAL_COMBAT
			character.rp_mode = rp_enabled
			character.hair = 'src/Icons/PlayerIcons/Hair/HairGoku.dmi'
			character.overlays += character.hair
			var/image/custom_overlay = image('src/Icons/PlayerIcons/Clothes/AngelWings.dmi', pixel_x = 12, pixel_y = 7)
			character.overlays += custom_overlay
			var/obj/items/Clothes/ShortSleeveShirt/shirt = new(character)
			shirt.suffix = "Equipped"
			character.rebuildPlayerAppearance("persistence fixture")
			assertCombatAppearanceSmoke(character, "initial rebuild")
			var/list/original_overlays = character.overlays.Copy()
			var/savefile/character_save = new
			character.Write(character_save)
			var/list/saved_overlays
			character_save["overlays"] >> saved_overlays
			var/saved_status_count = 0
			for(var/appearance_value in saved_overlays)
				if(appearance_value:icon == 'src/Icons/UI/LethalHud.dmi' || appearance_value:icon == 'src/Icons/UI/RPModeHud.dmi') saved_status_count++
			nexusSmokeAssert(!saved_status_count, "character save persisted derived combat status images")
			nexusSmokeAssert(character.overlays.len == original_overlays.len, "saving changed the live appearance")
			assertCombatAppearanceSmoke(character, "live character after save")
			var/mob/NexusSmokeTest/loaded = new
			loaded.Read(character_save)
			nexusSmokeAssert(loaded.rp_mode == rp_enabled && (loaded.sparring_mode == LETHAL_COMBAT) == lethal_enabled, "appearance load changed the saved mode flags")
			assertCombatAppearanceSmoke(loaded, "new save load")
			var/datum/PlayerAppearanceManager/previous_manager = loaded.player_appearance_manager
			// Emulate pre-fix saves, including orphaned variants no longer equal to either tmp handle.
			original_overlays += image('src/Icons/UI/LethalHud.dmi', pixel_x = 9, layer = 31)
			original_overlays += image('src/Icons/UI/RPModeHud.dmi', pixel_y = 11, layer = 32)
			character_save["overlays"] << original_overlays
			loaded.Read(character_save)
			nexusSmokeAssert(loaded.player_appearance_manager != previous_manager, "loading into an existing mob reused its previous appearance manager")
			assertCombatAppearanceSmoke(loaded, "legacy save load")
			nexusSmokeAssert(countAppearanceSmokeIcon(loaded, character.hair) == 1 && countAppearanceSmokeIcon(loaded, custom_overlay.icon) == 1, "legacy cleanup removed hair or custom cosmetics")
			nexusSmokeAssert(countAppearanceSmokeIcon(loaded, shirt.icon) == 1, "legacy cleanup lost or duplicated equipped clothing")
			loaded.normalizePrimaryTransformation()
			loaded.rebuildPlayerAppearance("repeated rebuild")
			assertCombatAppearanceSmoke(loaded, "repeated login normalization")
			loaded.SetSparringMode(CASUAL_COMBAT, FALSE)
			assertCombatAppearanceSmoke(loaded, "disable Lethal independently after relog")
			loaded.setRPMode(FALSE, announce = FALSE)
			assertCombatAppearanceSmoke(loaded, "disable after relog")
			del(loaded)
			del(character)

	var/mob/NexusSmokeTest/character = new
	character.SetSparringMode(LETHAL_COMBAT, FALSE)
	character.setRPMode(TRUE, announce = FALSE)
	character.overlays.Cut()
	character.refreshCombatStatusOverlays()
	assertCombatAppearanceSmoke(character, "cleared overlays with surviving tmp handles")
	var/list/transformation_snapshot = character.overlays.Copy()
	character.SetSparringMode(CASUAL_COMBAT, FALSE)
	character.setRPMode(FALSE, announce = FALSE)
	character.overlays += transformation_snapshot
	character.setNexusAppearanceIcon('src/Icons/PlayerIcons/BaseIcons/NewHumanIconsFromGuppinas/BaseHumanTan.dmi', center = TRUE)
	assertCombatAppearanceSmoke(character, "body icon change after restoring stale snapshot")
	character.SetSparringMode(LETHAL_COMBAT, FALSE)
	character.setRPMode(TRUE, announce = FALSE)
	character.Enlarge_Icon(64, 64)
	assertCombatAppearanceSmoke(character, "icon resize")
	character.SetSparringMode(CASUAL_COMBAT, FALSE)
	character.setRPMode(FALSE, announce = FALSE)
	nexusSmokeAssert(!character.overlays.len, "resizing baked combat indicators into permanent custom icons")
	character.overlays += transformation_snapshot
	var/obj/Hairs/Hair14/hair_choice = new
	Apply_Hair(character, hair_choice, "#222222")
	assertCombatAppearanceSmoke(character, "hair change with orphaned indicators")
	nexusSmokeAssert(countAppearanceSmokeIcon(character, character.hair) == 1, "hair change rebuild lost the selected hair")
	del(hair_choice)
	var/obj/items/Clothes/ShortSleeveShirt/shirt = new(character)
	shirt.suffix = "Equipped"
	character.rebuildPlayerAppearance("equipment icon fixture")
	var/old_shirt_icon = shirt.icon
	character.player_appearance_manager = null
	shirt.setNexusAppearanceIcon('src/Icons/PlayerIcons/Clothes/GokuSuit.dmi', "", center = TRUE)
	nexusSmokeAssert(!countAppearanceSmokeIcon(character, old_shirt_icon) && countAppearanceSmokeIcon(character, shirt.icon) == 1, "equipment icon change retained the old overlay or lost its replacement")
	shirt.Multiply_Color("#aa8844")
	nexusSmokeAssert(!countAppearanceSmokeIcon(character, 'src/Icons/PlayerIcons/Clothes/GokuSuit.dmi') && countAppearanceSmokeIcon(character, shirt.icon) == 1, "equipment recolor left its previous appearance")
	character.Clothes_Equip(shirt)
	nexusSmokeAssert(!countAppearanceSmokeIcon(character, shirt.icon), "changed equipment icon could not be removed by unequipping")
	del(character)
	world.log << "NEXUS_APPEARANCE_REBUILD_TESTS_PASSED: save/load, legacy indicators, icon changes, recoloring, cosmetics and equipment"
