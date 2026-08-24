mob/proc/Shielding()
	if(Cyber_Force_Field&&Ki>=max_ki*0.1) return 1
	if(shield_obj&&shield_obj.Using) return 1
	if(!Tournament||!skill_tournament||(Tournament&&skill_tournament&&Fighter1!=src&&Fighter2!=src))
		for(var/obj/items/Force_Field/S in item_list) if(S.Level>0) return 1

mob/proc/ki_shield_on() if(shield_obj && shield_obj.Using) return 1

mob/proc/check_lose_tail(dmg=0,obj/culprit)
	if(Health<50&&dir==culprit.dir&&dmg>=40&&Tail)
		player_view(15,src)<<"<font color=cyan>[src]'s tail is sliced off!"
		Tail_Remove()


mob/proc/Apply_force_field_damage(obj/items/Force_Field/FF,dmg=0)
	if(!FF) return
	FF.Level-=dmg*1.5
	FF.Force_Field_Desc()
	if(FF.Level<=0)
		player_view(15,src)<<"[src]'s force field is overloaded and explodes!"
		Explosion_Graphics(src,3)
		KO("force field explosion")
		del(FF)
	Force_Field()
