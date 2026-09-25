proc/runPowerControlSmokeTests()
	var/mob/previous_usr = usr
	var/mob/NexusSmokeTest/player = new(locate(445, 10, 2))
	usr = player
	var/obj/Power_Control/original = new(player)
	original.Mastery = 77
	var/obj/Power_Up/up_action = new(player)
	var/obj/Power_Down/down_action = new(player)
	sleep(1)
	player.BPpcnt = 125
	up_action.Hotbar_use()
	nexusSmokeAssert(original.Powerup == 1 && player.BPpcnt > 125, "Power Control could not raise BP before receiving a rank")
	player.Elder()
	sleep(1) // Rank grants construct skills before adding them to contents.
	var/obj/Power_Control/duplicate
	for(var/obj/Power_Control/skill in player)
		if(skill != original) duplicate = skill
	nexusSmokeAssert(duplicate && player.powerup_obj == original, "rank Power Control duplicate replaced the player's existing controller")
	duplicate.Power_Down()
	nexusSmokeAssert(original.Powerup == 0 && duplicate.Powerup == 0, "duplicate Power Down command did not use the existing controller")
	up_action.Hotbar_use()
	var/powered_bp = player.BPpcnt
	player.Remove_Duplicate_Moves()
	nexusSmokeAssert(!duplicate && player.powerup_obj == original && original.Powerup == 1 && player.BPpcnt == powered_bp && original.Mastery >= 77, "rank duplicate cleanup lost Power Control, mastery or the active powerup")
	down_action.Hotbar_use()
	nexusSmokeAssert(original.Powerup == 0, "Power Down could not stop powering up after rank cleanup")
	down_action.Hotbar_use()
	sleep(11)
	nexusSmokeAssert(original.Powerup == -1 && player.BPpcnt < powered_bp, "Power Down could not lower BP after rank cleanup")
	up_action.Hotbar_use()
	nexusSmokeAssert(original.Powerup == 0, "Power Up could not stop powering down after rank cleanup")
	up_action.Hotbar_use()
	var/before_raise = player.BPpcnt
	sleep(11)
	nexusSmokeAssert(original.Powerup == 1 && player.BPpcnt > before_raise, "Power Up could not raise BP after rank cleanup")
	player.Stop_Powering_Up()

	// Reproduce the old cache pointing at the duplicate when cleanup deletes it.
	duplicate = new(player)
	sleep(1)
	player.powerup_obj = duplicate
	player.Remove_Duplicate_Moves()
	nexusSmokeAssert(!duplicate && player.powerup_obj == original, "deleting the cached duplicate did not rebind surviving Power Control")
	player.powerup_obj = null
	up_action.Hotbar_use()
	nexusSmokeAssert(player.powerup_obj == original && original.Powerup == 1, "Power Up hotbar did not recover a missing controller reference")
	player.Stop_Powering_Up()
	player.powerup_obj = null
	down_action.Hotbar_use()
	nexusSmokeAssert(player.powerup_obj == original && original.Powerup == -1, "Power Down hotbar did not recover a missing controller reference")
	up_action.Hotbar_use()
	player.Stop_Powering_Up()

	var/savefile/character_save = new
	player.Write(character_save)
	var/mob/NexusSmokeTest/loaded = new
	loaded.Read(character_save)
	sleep(1)
	usr = loaded
	var/obj/Power_Control/loaded_control = locate(/obj/Power_Control) in loaded
	var/obj/Power_Up/loaded_up = locate(/obj/Power_Up) in loaded
	loaded.powerup_obj = original // Reject a cache pointing into another character.
	loaded_up.Hotbar_use()
	nexusSmokeAssert(loaded_control && loaded.powerup_obj == loaded_control && loaded_control.Powerup == 1 && !original.Powerup, "loaded Power Control used another character's controller")
	loaded.Stop_Powering_Up()
	del(loaded_control)
	loaded_up.Hotbar_use()
	nexusSmokeAssert(!loaded.powerup_obj && !(loaded in powerup_mobs), "removing the last Power Control left the skill usable or draining Energy")
	usr = previous_usr
	del(loaded)
	del(player)
	world.log << "NEXUS_POWER_CONTROL_TESTS_PASSED: rank grants, duplicate cleanup, hotbar recovery and save/load"
