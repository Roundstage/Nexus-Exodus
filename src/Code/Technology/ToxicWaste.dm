var/toxic_waste_on=1

obj/Toxic_Waste_Barrel
	icon='ToxicWasteBarrel.dmi'
	Savable=1
	takes_gradual_damage=1
	Cost=1000000
	science = 1
	science_level = 6
	science_path = "Engineering"
	density=1
	desc="There is no use for this stuff, and if it is destroyed the radioactive cloud will poison the nearby area for many hours, causing people to become radiation poisoned"
	can_scrap=0
	New()
		if(Health<Avg_BP*4) Health=Avg_BP*4
		if(z&&loc==initial(loc)) Savable=0
	Del()
		Spread_toxic_clouds()
		. = ..()

var/list/toxic_clouds=new
var/icon/toxic_cloud_icon

obj/Toxic_Cloud
	mouse_opacity = 0
	Dead_Zone_Immune=1
	Grabbable=0
	Health=1.#INF
	can_blueprint=0
	Cloakable=0
	Knockable=0
	Savable=1
	layer=6
	var/creation_time
	alpha=150
	var/toxicity_range=10

	New()
		spawn if(src)
			for(var/obj/Toxic_Cloud/tc in toxic_clouds) if(tc.z==z&&getdist(tc,src)<=3&&tc!=src)
				del(src)
				return
			for(var/obj/Revival_Altar/ra in revival_altars) if(ra.z==z&&getdist(ra,src)<=16)
				del(src)
				return
			for(var/obj/Spawn/s in Spawn_List) if(s.z==z&&getdist(s,src)<=16)
				del(src)
				return
			toxic_clouds+=src
			if(!creation_time) creation_time=world.realtime
			var/sleep_time=creation_time + toxic_waste_hours*60*60*10 - world.realtime
			if(sleep_time<0) sleep_time=0
			spawn(sleep_time) if(src) del(src)
			if(!toxic_cloud_icon)
				var/icon/i='FogCloud.dmi'-rgb(120,0,255)
				var/obj/o=new
				o.icon=i
				o.Enlarge_Icon(GetWidth(o.icon)*2,GetHeight(o.icon)*2)
				toxic_cloud_icon=o.icon
			icon=toxic_cloud_icon
			icon_state=pick("1","2","3","4")
			dir=pick(NORTH,SOUTH,EAST,WEST)
			CenterIcon(src)
	Del()
		toxic_clouds-=src
		. = ..()

var/toxic_waste_hours = 1

atom/movable/proc/Spread_toxic_clouds()
	new/obj/Toxic_Cloud(loc)

mob/var/tmp/in_radiation
mob/var/radiation_poisoned
mob/var/tmp/geiger_sounding
mob/var/radiation_level=0

mob/proc/Geiger_sound_loop()
	set waitfor=0
	if(geiger_sounding) return
	geiger_sounding=1
	while(in_radiation)
		src<<sound('Geiger.ogg',volume=60)
		sleep(173)
	geiger_sounding=0

mob/proc/Radiation_loop()
	set waitfor=0
	while(src)
		in_radiation=0
		if(Dead)
			radiation_poisoned=0
			radiation_level=0
		if(!Dead)
			if(!Tournament||z!=7||!(src in All_Entrants))
				for(var/obj/Toxic_Cloud/tc in toxic_clouds)
					if(z==tc.z&&getdist(src,tc)<=tc.toxicity_range&&viewable(src,tc))
						in_radiation=1
						if(!Dead&&!(Race in list("Majin","Android","Bio-Android","Demon")))
							radiation_level+=8
						break
		if(in_radiation && !geiger_sounding) Geiger_sound_loop()
		if(radiation_level >= 100)
			if(!radiation_poisoned)
				radiation_poisoned=1
				spawn while(radiation_poisoned)
					Health -= 0.5 * (radiation_level / 100)
					if(Health<=0)
						radiation_poisoned=0
						radiation_level=0
						if(prob(33)) Zombie_Virus=1
						Death("radiation poisoning")
					sleep(10)
				spawn alert(src,"You now have radiation poisoning")
		sleep(50)
