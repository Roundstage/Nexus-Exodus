obj/var/Cost_To_Learn=0

var/list/Learnable_Skills

proc/Initialize_Learnable_Skills_List()
	if(!Learnable_Skills)
		Learnable_Skills=new/list
		for(var/A in typesof(/obj))
			if(initial(A:Cost_To_Learn))
				Learnable_Skills["[initial(A:name)] (Cost: [initial(A:Cost_To_Learn)]) ([A])"] = A

var/list/Illegal_learnables = list(/obj/Regeneration,/obj/Absorb)

mob/proc/RemoveAbsorbFromNonZorbRacesIfZorbIsIllegal()
	set waitfor=0
	sleep(20)
	if(!(locate(/obj/Absorb) in Illegal_learnables)) return
	if(!(Race in list("Majin","Bio-Android","Alien","Demon")))
		if(!(locate(/obj/Module/Manual_Absorb) in active_modules))
			for(var/obj/Absorb/a in src) del(a)

mob/Admin4/verb/manageLearnableSkills()
	set name = "Manage Learnable Skills"
	set category="Admin"
	Initialize_Learnable_Skills_List()
	switch(alert(src,"Add or remove from the unlearnable skill list?","options","Add","Remove","Cancel"))
		if("Cancel") return

		if("Add")
			while(src&&client)
				var/list/L=list("Done")
				for(var/v in Learnable_Skills)
					var/skill_type = Learnable_Skills[v]
					if(!(skill_type in Illegal_learnables)) L[v] = skill_type
				var/choice = input(src,"Which skill to make unlearnable?") as null|anything in L
				if(!client || !choice || choice == "Done") return
				var/skill_type = L[choice]
				if(!ispath(skill_type, /obj)) return
				Illegal_learnables |= skill_type
				src<<"[choice] is now unlearnable"

		if("Remove")
			while(src&&client)
				var/list/L=list("Done")
				for(var/v in Illegal_learnables)
					if(ispath(v, /obj)) L["[initial(v:name)] ([v])"] = v
				var/choice = input(src,"What skill to make self learnable again?") as null|anything in L
				if(!client || !choice || choice == "Done") return
				var/skill_type = L[choice]
				if(!ispath(skill_type, /obj)) return
				Illegal_learnables -= skill_type
				src<<"[choice] is now learnable again"

mob/proc/Delete_excess_buffs()
	var/n=0
	for(var/obj/Buff/b in src)
		n++
		if(n>max_buffs) del(b)

var/max_buffs=8
mob/proc/Buff_count() //how many custom buffs they have
	var/n=0
	for(var/obj/Buff/b in src) n++
	return n

mob/var/tail_level=1

mob/verb/Learn()
	set category="Skills"

	if(is_saitama)
		alert("Nope")
		return

	if(!client) return
	syncProgressionTrees(silent = TRUE)
	showProgressionTrees("Combat", "Ki")

mob/proc/CostToLearn(obj/o)
	if(!o) return 0
	var/spNeeded = o.Cost_To_Learn
	spNeeded *= RaceSkillLearnDifficultyMod(o)
	return spNeeded

mob/proc/RaceSkillLearnDifficultyMod(obj/o)
	if(Race == "copy this as a template for all default as 1")
		if(o.type == /obj/Buff) return 1
		if(o.type == /obj/Final_Explosion) return 1
		if(o.type == /obj/Dropkick) return 1
		if(o.type == /obj/Attacks/Beam) return 1
		if(o.type == /obj/Attacks/Buster_Barrage) return 1
		if(o.type == /obj/Attacks/Blast) return 1
		if(o.type == /obj/Attacks/Charge) return 1
		if(o.type == /obj/Attacks/Spin_Blast) return 1
		if(o.type == /obj/Attacks/Big_Bang_Attack) return 1
		if(o.type == /obj/Attacks/Makosen) return 1
		if(o.type == /obj/Attacks/Explosion) return 1
		if(o.type == /obj/Attacks/Genocide) return 1
		if(o.type == /obj/Attacks/Shockwave) return 1
		if(o.type == /obj/Attacks/Piercer) return 1 //makankosappo
		if(o.type == /obj/Attacks/Ray) return 1 //death beam
		if(o.type == /obj/Attacks/Dodompa) return 1
		if(o.type == /obj/Attacks/Attack_Barrier) return 1
		if(o.type == /obj/Attacks/Kienzan) return 1
		if(o.type == /obj/Attacks/Scatter_Shot) return 1
		if(o.type == /obj/Attacks/Sokidan) return 1
		if(o.type == /obj/Attacks/Genki_Dama/Death_Ball) return 1
		if(o.type == /obj/Attacks/Genki_Dama/Supernova) return 1
		if(o.type == /obj/Telepathy) return 1
		if(o.type == /obj/Reincarnation) return 1
		if(o.type == /obj/Meditate_Level_2) return 1
		if(o.type == /obj/Shadow_Spar) return 1
		if(o.type == /obj/Shield) return 1
		if(o.type == /obj/Bind) return 1
		if(o.type == /obj/Kaio_Revive) return 1
		if(o.type == /obj/Restore_Youth) return 1
		if(o.type == /obj/Heal) return 1
		if(o.type == /obj/Unlock_Potential) return 1
		if(o.type == /obj/Observe) return 1
		if(o.type == /obj/SplitForm) return 1
		if(o.type == /obj/Hokuto_Shinken) return 1
		if(o.type == /obj/Planet_Destroy) return 1
		if(o.type == /obj/Dash_Attack) return 1
		if(o.type == /obj/Sense) return 1
		if(o.type == /obj/Advanced_Sense) return 1 //sense lv2
		if(o.type == /obj/Sense3) return 1
		if(o.type == /obj/Give_Power) return 1
		if(o.type == /obj/Zanzoken) return 1
		if(o.type == /obj/Self_Destruct) return 1
		if(o.type == /obj/Taiyoken) return 1
	if(Race == "Saiyan")
		if(Class == "Elite")
			if(o.type == /obj/Buff) return 1
			if(o.type == /obj/Final_Explosion) return 1
			if(o.type == /obj/Dropkick) return 1
			if(o.type == /obj/Attacks/Beam) return 1
			if(o.type == /obj/Attacks/Buster_Barrage) return 1
			if(o.type == /obj/Attacks/Blast) return 1
			if(o.type == /obj/Attacks/Charge) return 1
			if(o.type == /obj/Attacks/Spin_Blast) return 1
			if(o.type == /obj/Attacks/Big_Bang_Attack) return 1
			if(o.type == /obj/Attacks/Makosen) return 1
			if(o.type == /obj/Attacks/Explosion) return 1
			if(o.type == /obj/Attacks/Genocide) return 1
			if(o.type == /obj/Attacks/Shockwave) return 1
			if(o.type == /obj/Attacks/Piercer) return 10 //makankosappo
			if(o.type == /obj/Attacks/Ray) return 1 //death beam
			if(o.type == /obj/Attacks/Dodompa) return 1
			if(o.type == /obj/Attacks/Attack_Barrier) return 10
			if(o.type == /obj/Attacks/Kienzan) return 1
			if(o.type == /obj/Attacks/Scatter_Shot) return 10
			if(o.type == /obj/Attacks/Sokidan) return 10
			if(o.type == /obj/Attacks/Genki_Dama/Death_Ball) return 5
			if(o.type == /obj/Attacks/Genki_Dama/Supernova) return 5
			if(o.type == /obj/Telepathy) return 50
			if(o.type == /obj/Reincarnation) return 10
			if(o.type == /obj/Meditate_Level_2) return 10
			if(o.type == /obj/Shadow_Spar) return 10
			if(o.type == /obj/Shield) return 5
			if(o.type == /obj/Bind) return 2
			if(o.type == /obj/Kaio_Revive) return 3
			if(o.type == /obj/Restore_Youth) return 3
			if(o.type == /obj/Heal) return 10
			if(o.type == /obj/Unlock_Potential) return 3
			if(o.type == /obj/Observe) return 50
			if(o.type == /obj/SplitForm) return 2
			if(o.type == /obj/Hokuto_Shinken) return 1
			if(o.type == /obj/Planet_Destroy) return 1
			if(o.type == /obj/Dash_Attack) return 1
			if(o.type == /obj/Sense) return 2
			if(o.type == /obj/Advanced_Sense) return 3 //sense lv2
			if(o.type == /obj/Sense3) return 5
			if(o.type == /obj/Give_Power) return 3
			if(o.type == /obj/Zanzoken) return 1
			if(o.type == /obj/Self_Destruct) return 1
			if(o.type == /obj/Taiyoken) return 1
		else
			if(o.type == /obj/Buff) return 1
			if(o.type == /obj/Final_Explosion) return 1
			if(o.type == /obj/Dropkick) return 1
			if(o.type == /obj/Attacks/Beam) return 1
			if(o.type == /obj/Attacks/Buster_Barrage) return 1
			if(o.type == /obj/Attacks/Blast) return 1
			if(o.type == /obj/Attacks/Charge) return 1
			if(o.type == /obj/Attacks/Spin_Blast) return 1
			if(o.type == /obj/Attacks/Big_Bang_Attack) return 1
			if(o.type == /obj/Attacks/Makosen) return 1
			if(o.type == /obj/Attacks/Explosion) return 1
			if(o.type == /obj/Attacks/Genocide) return 1
			if(o.type == /obj/Attacks/Shockwave) return 1
			if(o.type == /obj/Attacks/Piercer) return 10 //makankosappo
			if(o.type == /obj/Attacks/Ray) return 10 //death beam
			if(o.type == /obj/Attacks/Dodompa) return 10
			if(o.type == /obj/Attacks/Attack_Barrier) return 10
			if(o.type == /obj/Attacks/Kienzan) return 10
			if(o.type == /obj/Attacks/Scatter_Shot) return 10
			if(o.type == /obj/Attacks/Sokidan) return 10
			if(o.type == /obj/Attacks/Genki_Dama/Death_Ball) return 5
			if(o.type == /obj/Attacks/Genki_Dama/Supernova) return 5
			if(o.type == /obj/Telepathy) return 50
			if(o.type == /obj/Reincarnation) return 10
			if(o.type == /obj/Meditate_Level_2) return 10
			if(o.type == /obj/Shadow_Spar) return 10
			if(o.type == /obj/Shield) return 5
			if(o.type == /obj/Bind) return 2
			if(o.type == /obj/Kaio_Revive) return 3
			if(o.type == /obj/Restore_Youth) return 3
			if(o.type == /obj/Heal) return 10
			if(o.type == /obj/Unlock_Potential) return 3
			if(o.type == /obj/Observe) return 50
			if(o.type == /obj/SplitForm) return 2
			if(o.type == /obj/Hokuto_Shinken) return 1
			if(o.type == /obj/Planet_Destroy) return 1
			if(o.type == /obj/Dash_Attack) return 1
			if(o.type == /obj/Sense) return 2
			if(o.type == /obj/Advanced_Sense) return 3 //sense lv2
			if(o.type == /obj/Sense3) return 5
			if(o.type == /obj/Give_Power) return 3
			if(o.type == /obj/Zanzoken) return 1
			if(o.type == /obj/Self_Destruct) return 1
			if(o.type == /obj/Taiyoken) return 1
	if(Race == "Namekian")
		if(o.type == /obj/Buff) return 1
		if(o.type == /obj/Final_Explosion) return 1
		if(o.type == /obj/Dropkick) return 1
		if(o.type == /obj/Attacks/Beam) return 1
		if(o.type == /obj/Attacks/Buster_Barrage) return 1
		if(o.type == /obj/Attacks/Blast) return 1
		if(o.type == /obj/Attacks/Charge) return 1
		if(o.type == /obj/Attacks/Spin_Blast) return 1
		if(o.type == /obj/Attacks/Big_Bang_Attack) return 1
		if(o.type == /obj/Attacks/Makosen) return 1
		if(o.type == /obj/Attacks/Explosion) return 1
		if(o.type == /obj/Attacks/Genocide) return 1
		if(o.type == /obj/Attacks/Shockwave) return 1
		if(o.type == /obj/Attacks/Piercer) return 1 //makankosappo
		if(o.type == /obj/Attacks/Ray) return 1 //death beam
		if(o.type == /obj/Attacks/Dodompa) return 1
		if(o.type == /obj/Attacks/Attack_Barrier) return 1
		if(o.type == /obj/Attacks/Kienzan) return 10
		if(o.type == /obj/Attacks/Scatter_Shot) return 1
		if(o.type == /obj/Attacks/Sokidan) return 1
		if(o.type == /obj/Attacks/Genki_Dama/Death_Ball) return 5
		if(o.type == /obj/Attacks/Genki_Dama/Supernova) return 5
		if(o.type == /obj/Telepathy) return 1
		if(o.type == /obj/Reincarnation) return 1
		if(o.type == /obj/Meditate_Level_2) return 1
		if(o.type == /obj/Shadow_Spar) return 1
		if(o.type == /obj/Shield) return 10
		if(o.type == /obj/Bind) return 1
		if(o.type == /obj/Kaio_Revive) return 1
		if(o.type == /obj/Restore_Youth) return 1
		if(o.type == /obj/Heal) return 1
		if(o.type == /obj/Unlock_Potential) return 1
		if(o.type == /obj/Observe) return 1
		if(o.type == /obj/SplitForm) return 1
		if(o.type == /obj/Hokuto_Shinken) return 1
		if(o.type == /obj/Planet_Destroy) return 3
		if(o.type == /obj/Dash_Attack) return 1
		if(o.type == /obj/Sense) return 1
		if(o.type == /obj/Advanced_Sense) return 1 //sense lv2
		if(o.type == /obj/Sense3) return 1
		if(o.type == /obj/Give_Power) return 1
		if(o.type == /obj/Zanzoken) return 1
		if(o.type == /obj/Self_Destruct) return 1
		if(o.type == /obj/Taiyoken) return 1
	if(Race == "Android")
		if(o.type == /obj/Buff) return 1
		if(o.type == /obj/Final_Explosion) return 1
		if(o.type == /obj/Dropkick) return 1
		if(o.type == /obj/Attacks/Beam) return 1
		if(o.type == /obj/Attacks/Buster_Barrage) return 1
		if(o.type == /obj/Attacks/Blast) return 1
		if(o.type == /obj/Attacks/Charge) return 1
		if(o.type == /obj/Attacks/Spin_Blast) return 1
		if(o.type == /obj/Attacks/Big_Bang_Attack) return 1
		if(o.type == /obj/Attacks/Makosen) return 1
		if(o.type == /obj/Attacks/Explosion) return 1
		if(o.type == /obj/Attacks/Genocide) return 1
		if(o.type == /obj/Attacks/Shockwave) return 1
		if(o.type == /obj/Attacks/Piercer) return 1 //makankosappo
		if(o.type == /obj/Attacks/Ray) return 1 //death beam
		if(o.type == /obj/Attacks/Dodompa) return 1
		if(o.type == /obj/Attacks/Attack_Barrier) return 1
		if(o.type == /obj/Attacks/Kienzan) return 1
		if(o.type == /obj/Attacks/Scatter_Shot) return 1
		if(o.type == /obj/Attacks/Sokidan) return 1
		if(o.type == /obj/Attacks/Genki_Dama/Death_Ball) return 1
		if(o.type == /obj/Attacks/Genki_Dama/Supernova) return 1
		if(o.type == /obj/Telepathy) return 1
		if(o.type == /obj/Reincarnation) return 10
		if(o.type == /obj/Meditate_Level_2) return 10
		if(o.type == /obj/Shadow_Spar) return 1
		if(o.type == /obj/Shield) return 1
		if(o.type == /obj/Bind) return 3
		if(o.type == /obj/Kaio_Revive) return 10
		if(o.type == /obj/Restore_Youth) return 10
		if(o.type == /obj/Heal) return 5
		if(o.type == /obj/Unlock_Potential) return 10
		if(o.type == /obj/Observe) return 1
		if(o.type == /obj/SplitForm) return 1
		if(o.type == /obj/Hokuto_Shinken) return 1
		if(o.type == /obj/Planet_Destroy) return 1
		if(o.type == /obj/Dash_Attack) return 1
		if(o.type == /obj/Sense) return 1
		if(o.type == /obj/Advanced_Sense) return 1 //sense lv2
		if(o.type == /obj/Sense3) return 1
		if(o.type == /obj/Give_Power) return 10
		if(o.type == /obj/Zanzoken) return 1
		if(o.type == /obj/Self_Destruct) return 1
		if(o.type == /obj/Taiyoken) return 1
	if(Race == "Frost Lord")
		if(o.type == /obj/Buff) return 1
		if(o.type == /obj/Final_Explosion) return 1
		if(o.type == /obj/Dropkick) return 1
		if(o.type == /obj/Attacks/Beam) return 1
		if(o.type == /obj/Attacks/Buster_Barrage) return 1
		if(o.type == /obj/Attacks/Blast) return 1
		if(o.type == /obj/Attacks/Charge) return 1
		if(o.type == /obj/Attacks/Spin_Blast) return 1
		if(o.type == /obj/Attacks/Big_Bang_Attack) return 1
		if(o.type == /obj/Attacks/Makosen) return 1
		if(o.type == /obj/Attacks/Explosion) return 1
		if(o.type == /obj/Attacks/Genocide) return 1
		if(o.type == /obj/Attacks/Shockwave) return 1
		if(o.type == /obj/Attacks/Piercer) return 1 //makankosappo
		if(o.type == /obj/Attacks/Ray) return 1 //death beam
		if(o.type == /obj/Attacks/Dodompa) return 1
		if(o.type == /obj/Attacks/Attack_Barrier) return 1
		if(o.type == /obj/Attacks/Kienzan) return 1
		if(o.type == /obj/Attacks/Scatter_Shot) return 1
		if(o.type == /obj/Attacks/Sokidan) return 1
		if(o.type == /obj/Attacks/Genki_Dama/Death_Ball) return 1
		if(o.type == /obj/Attacks/Genki_Dama/Supernova) return 1
		if(o.type == /obj/Telepathy) return 1
		if(o.type == /obj/Reincarnation) return 1
		if(o.type == /obj/Meditate_Level_2) return 1
		if(o.type == /obj/Shadow_Spar) return 1
		if(o.type == /obj/Shield) return 1
		if(o.type == /obj/Bind) return 1
		if(o.type == /obj/Kaio_Revive) return 1
		if(o.type == /obj/Restore_Youth) return 1
		if(o.type == /obj/Heal) return 1
		if(o.type == /obj/Unlock_Potential) return 1
		if(o.type == /obj/Observe) return 1
		if(o.type == /obj/SplitForm) return 1
		if(o.type == /obj/Hokuto_Shinken) return 1
		if(o.type == /obj/Planet_Destroy) return 1
		if(o.type == /obj/Dash_Attack) return 1
		if(o.type == /obj/Sense) return 5
		if(o.type == /obj/Advanced_Sense) return 5 //sense lv2
		if(o.type == /obj/Sense3) return 5
		if(o.type == /obj/Give_Power) return 1
		if(o.type == /obj/Zanzoken) return 1
		if(o.type == /obj/Self_Destruct) return 1
		if(o.type == /obj/Taiyoken) return 1
	return 1

mob/proc/learn_new_buff_attribute()
	var/list/availables=list("Cancel","Transformation")
	for(var/v in known_buff_attributes) availables-=v
	var/v=input("Which buff attribute do you want to learn?") in availables
	var/sp_cost=0
	switch(v)
		if(null) return
		if("Cancel") return
		if("Transformation")
			sp_cost=15
			v="transformation"
	switch(alert(src,"the [v] attribute cost [sp_cost] sp, learn it?","options","Yes","No"))
		if("Yes")
			if(Experience<sp_cost) return
			Experience-=sp_cost
			known_buff_attributes+=v
			src<<"You have learned [v] (buff attribute)"


mob/Prison_Bot
	icon='src/Icons/PlayerIcons/BaseIcons/Android.dmi'
	Click()
		dir=get_dir(src,usr)
		player_view(15,src)<<"[src]: Greetings. This is the prison hub where visitors can enter the prison. \
		The prison is another dimension where criminals caught over the bounty network are sent."
		sleep(40)
		dir=SOUTH
