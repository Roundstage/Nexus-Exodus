mob/proc/Cooler()
	if(base_bp<1000) base_bp=1000
	var/bp_get=rand(25000,65000)
	if(base_bp<bp_get)
		bp_get-=base_bp
		if(bp_get>0) hbtc_bp+=bp_get
	if(max_ki<800*Eff) max_ki=800*Eff
	mastery_mod*=2
	Gravity_Mod*=2
	sp_mod*=1.2
	IsCooler = 1
	Class="Cooler"
	contents.Add(new/obj/Attacks/Genki_Dama/Death_Ball, new/obj/Attacks/Genki_Dama/Supernova, new/obj/Attacks/Ray, new/obj/Attacks/Spin_Blast, \
			new/obj/Planet_Destroy, new/obj/Attacks/Kienzan, new/obj/Attacks/Explosion)
	stun_resistance_mod=1.6

mob/var/IsCooler = 0
