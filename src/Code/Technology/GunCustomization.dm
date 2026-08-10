/*
Ideas for attributes:
	Shuriken, bounces off walls or whatever
	Homing. For each point it homes in 5 tiles, after it uses up the tiles it just goes straight
	Range. 10 tiles per point perhaps? Sniping applications?
	Beam. Fire a constant beam for possibly heavy ammo drain.
	Charge. Increased damage by adding a charging period before firing.
	Piercing attribute, not only does this make it peirce through a person, but also gives it an edge in piercing through
	other bullets in its way even if they are more powerful
*/
obj/var/Customization_Points=10
obj/items/Gun
	hotbar_type="Combat item"
	era_reset_immune=0
	clonable = 0
	can_hotbar=1
	can_change_icon=1
	Customization_Points=35
	verb/Hotbar_use()
		set hidden=1
		Shoot()
mob/var/tmp/obj/items/Gun/Gun //The gun being customized currently.
mob/var/tmp/atom/nexus_gun_interaction_location
mob/proc/Customize_Gun_Stats(obj/items/Gun/G)
	if(!G) return
	Gun=G
	nexus_gun_interaction_location=G.loc
	if(!G.canContinueNexusGunInteraction(src, nexus_gun_interaction_location))
		Gun=null
		nexus_gun_interaction_location=null
		return
	G.nexus_customization_pending=TRUE
	G.Set_Default_Gun_Stats()
	Gun_Window_Refresh(G)
	winshow(src,"gunstats",1)
	while(src&&(winget(src,"gunstats","is-visible")=="true")) sleep(1)
	Gun=null
	nexus_gun_interaction_location=null
mob/proc/Gun_Window_Refresh(obj/items/Gun/G)
	winset(src,"GunPoints","text=[G.Customization_Points]")
	winset(src,"GunDamageVal","text=[G.bp_mod]")
	winset(src,"GunAmmoVal","text=[G.Max_Ammo]")
	winset(src,"GunVelocityVal","text=[G.Velocity]")
	winset(src,"GunRefireVal","text=[G.Delay]")
	winset(src,"GunPrecisionVal","text=[G.Precision]")
	winset(src,"GunExplosionVal","text=[G.Explodes]")
	winset(src,"GunSpreadVal","text=[G.Spread]")
	winset(src,"GunKnockbackVal","text=[G.Knockbacks]")
	winset(src,"GunStunVal","text=[G.Stun]")
	winset(src,"GunReloadVal","text=[G.Reload_Speed]")
	winset(src,"GunRangeVal","text=[G.Range]")
	if(G.Bullet) winset(src,"GunType","text='Ballistic Projectiles'")
	else winset(src,"GunType","text='Energy Projectiles'")
obj/items/Gun/proc/Set_Default_Gun_Stats()
	Customization_Points=initial(Customization_Points)
	bp_mod=initial(bp_mod)
	Max_Ammo=initial(Max_Ammo)
	Velocity=initial(Velocity)
	Delay=initial(Delay)
	Precision=initial(Precision)
	Explodes=initial(Explodes)
	Spread=initial(Spread)
	Knockbacks=initial(Knockbacks)
	Stun=initial(Stun)
	Bullet=initial(Bullet)
	Reload_Speed=initial(Reload_Speed)
	Range=initial(Range)
obj/items/Gun/proc/Gun_Stat_Lowest(A)
	switch(A)
		if("Damage") if(bp_mod<=initial(bp_mod)) return 1
		if("Ammo") if(Max_Ammo<=initial(Max_Ammo)) return 1
		if("Velocity") if(Velocity<=initial(Velocity)) return 1
		if("Refire") if(Delay<=initial(Delay)) return 1
		if("Precision") if(Precision<=initial(Precision)) return 1
		if("Explosion") if(Explodes<=initial(Explodes)) return 1
		if("Spread") if(Spread<=initial(Spread)) return 1
		if("Knockback") if(Knockbacks<=initial(Knockbacks)) return 1
		if("Stun") if(Stun<=initial(Stun)) return 1
		if("Reload") if(Reload_Speed<=initial(Reload_Speed)) return 1
		if("Range") if(Range<=initial(Range)) return 1
mob/verb/Customize_Gun(O as text,S as text) //O=Operator (+ or -), S=Stat
	set hidden=1
	set name=".Customize_Gun"

	var/obj/items/Gun/current_gun = Gun
	if(!current_gun || !current_gun.canContinueNexusGunInteraction(src, nexus_gun_interaction_location)) return //5/5/2012

	//security
	if(!(winget(src,"gunstats","is-visible")=="true")) return
	if(!(O in list("+","-"))) return
	if(!(S in list("Range","Damage","Ammo","Velocity","Refire","Precision","Explosion","Spread","Knockback",\
	"Stun","Reload","Type"))) return

	//if(S=="Stun")
		//alert("Stun guns are disabled due to players voting it off")
		//return

	if(S=="Type")
		current_gun.Bullet=!current_gun.Bullet
		Gun_Window_Refresh(current_gun)
		return
	var/Amount=1
	if(O=="-")
		Amount=-1
		if(current_gun.Customization_Points>=initial(current_gun.Customization_Points)||current_gun.Gun_Stat_Lowest(S)) return
	if(O=="+") if(current_gun.Customization_Points<1) return
	switch(S)
		if("Range") current_gun.Range+=Amount*1
		if("Damage") current_gun.bp_mod+=Amount*0.25
		if("Ammo") current_gun.Max_Ammo+=Amount*0.25
		if("Velocity")
			if(O=="+"&&current_gun.Velocity>=10) return
			current_gun.Velocity+=Amount*1
		if("Refire")
			if(O=="+"&&current_gun.Delay>=10) return
			current_gun.Delay+=Amount*1
		if("Precision") current_gun.Precision+=Amount*0.25
		if("Explosion")
			if(O=="+"&&current_gun.Explodes>=5) return
			current_gun.Explodes+=Amount
		if("Spread")
			if(O=="+"&&current_gun.Spread>=1) return
			current_gun.Spread+=Amount
		if("Knockback") current_gun.Knockbacks+=Amount
		if("Stun") current_gun.Stun+=Amount
		if("Reload") current_gun.Reload_Speed+=Amount*1
	current_gun.Customization_Points-=Amount
	Gun_Window_Refresh(current_gun)
mob/verb/Gun_Points_Done()
	set name=".Gun_Points_Done"
	set hidden=1
	if(!Gun||!Gun.Customization_Points) winshow(src,"gunstats",0)
//GUN APPEARANCES
obj/Gun_Icon/Click() if(usr.Gun)
	var/obj/items/Gun/current_gun = usr.Gun
	if(!current_gun.canContinueNexusGunInteraction(usr, usr.nexus_gun_interaction_location)) return
	current_gun.icon=icon
	current_gun.icon_state=icon_state
obj/Bullet_Icons/Click() if(usr.Gun)
	var/obj/items/Gun/current_gun = usr.Gun
	if(!current_gun.canContinueNexusGunInteraction(usr, usr.nexus_gun_interaction_location)) return
	var/new_bullet_icon = icon
	var/C=input(usr,"Choose a color. Hit cancel to have default color.") as color|null
	if(usr.Gun != current_gun || !current_gun.canContinueNexusGunInteraction(usr, usr.nexus_gun_interaction_location)) return
	current_gun.Bullet_Icon=new_bullet_icon
	if(C) current_gun.Bullet_Icon+=C
var/list/Gun_Icons=new
var/list/Bullet_Icons=new
proc/Initialize_Gun_Icons()
	var/Gun_Name=1
	var/obj/Gun_Icon/G=new
	G.name=Gun_Name
	G.icon='ItemBlaster.dmi'
	Gun_Icons+=G
	for(var/A in icon_states('GUNS.dmi')) if(!(A in list("Rocket Middle","Rocket Right","Ammo 1","Ammo 2",\
	"Ammo 3","Ammo Box")))
		Gun_Name+=1
		var/obj/Gun_Icon/B=new
		B.name=Gun_Name
		B.icon='GUNS.dmi'
		B.icon_state=A
		Gun_Icons+=B
	var/list/Bullets=list('Bullet1.dmi','Bullet2.dmi','Bullet3.dmi','Bullet4.dmi','Bullet.dmi','MissileSmall.dmi',\
	'Missile.dmi','Grenade.dmi')
	for(var/A in Bullets)
		var/obj/Bullet_Icons/B=new
		B.icon=A
		Bullet_Icons+=B
	for(var/obj/A in Blasts)
		var/obj/Bullet_Icons/B=new
		B.icon=A.icon
		B.icon_state=A.icon_state
		Bullet_Icons+=B

mob/proc/Grid(list/L, obj/items/Gun/G, update_only, show_names = 1)
	if(!client) return

	if(show_names) winset(src,"Grid2.Main Grid2","show-names=true")
	else winset(src,"Grid2.Main Grid2","show-names=false")

	winset(src,"Grid2.Main Grid2","is-list=true")
	winset(src,"Grid2.Main Grid2","cells=0") //clear the grid
	if(!L) if(winget(src,"Grid2","is-visible")=="true") return 1
	else
		if(G&&istype(G,/obj/items/Gun))
			Gun=G
			nexus_gun_interaction_location=G.loc
			if(!G.canContinueNexusGunInteraction(src, nexus_gun_interaction_location))
				Gun=null
				nexus_gun_interaction_location=null
				return
		var/Cell=1
		for(var/obj/O in L)
			winset(src,"Grid2.Main Grid2","current-cell=[Cell]")
			src<<output(O,"Grid2.Main Grid2")
			Cell++
		winset(src,"Grid2.Main Grid2","cells=[Cell]")
		winset(src,"Grid2","is-visible=true")
		if(!update_only) while(src&&client&&(winget(src,"Grid2","is-visible")=="true")) sleep(1)
		if(istype(G,/obj/items/Gun) && Gun == G)
			Gun=null
			nexus_gun_interaction_location=null
		if(!update_only) winset(src,"Grid2.Main Grid2","cells=0") //clear the grid

mob/verb/Hide_Main_Grid()
	set hidden=1
	set name=".Hide_Main_Grid"
	winset(src,"Grid2.Main Grid2","show-names=false")
	winset(src,"Grid2.Main Grid2","cells=0") //clear the grid
	winset(src,"Grid2","is-visible=false")
	winset(src,"Grid2","title=\"\"")


var/list/weights_icons=new
mob/var/tmp/obj/weights_icon_obj
obj/weights_icon
	Click()
		var/obj/items/Weights/weights = usr.weights_icon_obj
		if(!weights || !weights.canUseAfterNexusTradeYield(usr)) return
		var/new_weights_icon = icon
		var/RGB=input(usr,"Choose color. Hit Cancel to have default color.") as color|null
		if(usr.weights_icon_obj != weights || !weights.canUseAfterNexusTradeYield(usr)) return
		weights.icon=new_weights_icon
		if(RGB) weights.icon+=RGB
