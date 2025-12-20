//Movement port definitions for isolating client/world calls
datum/MovementPort
	proc
		hasClient(mob/m)
			if(m && m.client) return 1
			return 0

		clientCtrlDown(mob/m)
			if(m && m.client && m.client.ctrl_button) return 1
			return 0

		clientShiftDown(mob/m)
			if(m && m.client && m.client.shift) return 1
			return 0

		areaUpdateSenseTargets(area/a)
			if(a) a.AreaUpdateSenseTargets()

		startCoreLoops(mob/m, area/a)
			if(m && m.client && a && istype(a, /area/Braal_Core))
				m.Start_core_loops()

		finalRealmLoop(mob/m)
			if(m) m.Final_realm_loop()

		verifyBattlegroundMaster(mob/m)
			if(m) m.VerifyBattlegroundMaster()

		sendMessage(mob/m, message)
			if(m) m << message
