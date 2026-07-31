mob/proc/Legendary_Saiyan()
	Saiyan(Can_Elite=0)
	Intelligence=0.1
	Gravity_Mod*=3
	Class="Legendary Saiyan"

	lssj_ver=1

	var/bp_get=rand(8000,10000)
	if(base_bp<bp_get)
		bp_get-=base_bp
		if(bp_get>0) hbtc_bp+=bp_get
	ssjadd = 10000
	ssjat = 5000000
	SSjAble = 1
	Decline -= 2
	Decline_Rate = 4
	stun_resistance_mod=2.5
