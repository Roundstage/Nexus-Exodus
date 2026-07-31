mob/proc/Elite_starting_bp()
	if(!Player_Count()||!Saiyan_Count()) return 1
	var/bp=0
	for(var/mob/m in players) if(m.Race=="Saiyan") bp+=m.base_bp/m.bp_mod
	bp/=Saiyan_Count()
	return bp*bp_mod

mob/proc/Elite_Saiyan() if(Class!="Elite")
	if(START_WITH_RACIAL_SKILLS)
		contents.Add(new/obj/Attacks/Charge,new/obj/Attacks/Explosion,new/obj/Attacks/Beam,\
		new/obj/Attacks/Garlic_Gun,new/obj/Attacks/Final_Flash,new/obj/Fly,new/obj/Attacks/Kienzan,\
		new/obj/Attacks/Shockwave,new/obj/Attacks/Blast)
	base_bp=Elite_starting_bp()
	if(base_bp<1000) base_bp=1000

	var/bp_get=rand(6300,7700)
	if(base_bp<bp_get)
		bp_get-=base_bp
		if(bp_get>0) hbtc_bp+=bp_get

	if(max_ki<800*Eff) max_ki=800*Eff
	ssjmod/=2
	ssjat*=3
	ssj2mod*=5
	mastery_mod*=2
	Gravity_Mod*=2
	sp_mod*=1.2
	Class="Elite"
