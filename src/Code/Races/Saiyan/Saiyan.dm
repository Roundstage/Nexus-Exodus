var/elite_chance=8

mob/proc/Saiyan(Can_Elite=1,force_elite,force_low_class,force_normal_class=0)
	Race="Saiyan"
	incline_age=15
	incline_mod=0.2
	Gravity_Mod=1
	sp_mod=1
	mastery_mod=1

	/*
	alert(src,"Saiyan are a warrior race gifted with the potential for great power. \
	They have tails and when the moon comes out, they turn into giant ape \
	creatures of great power. Also there is a legend of the Super Saiyan, a form that would turn a \
	normal Saiyan into the most powerful being in the universe. Saiyan have some \
	intelligence penalties and master skills slowly, but have the most powerful zenkai of any race.")
	*/

	bp_mod=Get_race_starting_bp_mod()
	Decline=30
	Decline_Rate=1
	Intelligence=0.4
	knowledge_cap_rate=1
	Regenerate=0
	Lungs=0
	leech_rate=1
	med_mod=1
	zenkai_mod=4
	ssjat=rand(800000,1200000)
	ssj2at=rand(102000000,132000000)
	ssj3at=rand(360000000,440000000)
	gravity_mastered=10
	base_bp=rand(200,900)
	if(!force_elite && !force_normal_class && (prob(50) || force_low_class))
		base_bp=rand(5,20)
		hbtc_bp=0
		ssjat*=0.9
		Class="Low Class"
	else if(force_elite) Elite_Saiyan()
	else if(!force_normal_class&&Can_Elite&&(world.time>3000))
		var/elites=0
		for(var/mob/m in players) if(m.Race=="Saiyan"&&m.Class=="Elite") elites++
		if((Saiyan_Count()>=10&&elites/Saiyan_Count()<elite_chance/100))
			switch(alert(src,"Do you want to be an Elite Saiyan? This choice only appears if less than [elite_chance]% \
			of the Saiyans online are already elite. The penalty is that Super Saiyan will be harder to get \
			because the bp requirement is much higher. There are advantages, see the race guide for details.",\
			"options","No","Yes"))
				if("Yes") Elite_Saiyan()
