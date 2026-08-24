mob/proc
	Get_bp_loss_from_low_ki()
		if(Class=="Spirit Doll") return 0.3
		switch(Race)
			if("Namekian") return 0.2
			if("Saiyan") return 0.6
			if("Half Saiyan") return 0.4
			if("Bio-Android") return 0.2
			if("Human") return 0.3
			if("Tsujin") return 0.6
			if("Demigod") return 0.8
			if("Kai") return 0.1
		return 0.9

	Get_bp_loss_from_low_hp()
		switch(Race)
			if("Namekian") return 0.5
			if("Saiyan") return 0.6
			if("Half Saiyan") return 0.6
			if("Bio-Android") return 0.5
			if("Demon") return 0.1
			if("Human") return 0.6
			if("Demigod") return 0.8
		return 0.9
