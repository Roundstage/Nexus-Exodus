
var/WorldDefaultAcc=55

proc/AccuracyFormula(mob/Offender,mob/Defender,KiManip=0,Chance=WorldDefaultAcc)
	if(Offender&&Defender)

		var/Offense=(Offender.BP*((Offender.Off)+(Offender.Spd*(0.1+(max(Offender.precog,Offender.precog_chance)*0.1)))))
		var/Defense=(Defender.BP*((Defender.Def)+(Defender.Spd*(0.1+(max(Defender.precog,Defender.precog_chance)*0.1)))))

		var/TotalAccuracy= Chance*(Offense/max(Defense,0.01))


		//Offender<<"Total Accuracy: [(TotalAccuracy)]"

		if(Offender.dir==Defender.dir)
			TotalAccuracy+=25
		if(Defender.attacking) TotalAccuracy+=10

		//Offender<<"Total Accuracy: [(TotalAccuracy)]"


		if(TotalAccuracy>=99) TotalAccuracy=99
		if(TotalAccuracy<=1) TotalAccuracy=1
		if(Defender.icon_state=="Meditate") TotalAccuracy=100
		//Offender<<"Your attack had an accuracy of [TotalAccuracy]"

		return TotalAccuracy

proc/DamageFormula(mob/Offender,mob/Defender,Strength=1,Force=0,Speed=0,Offense=0,DamageType="Physical",BaselineDamage=2,FlatDamage=0,UsesWeapon=1,IgnoresEnd=0)
	if(Offender&&Defender)
		var/EMPBP=0

		var/Dam=((Offender.BP)*((Offender.Str*Strength)+(Offender.Spd*Speed)+(Offender.Pow*Force)+(Offender.Off*Offense)))
		var/Res=((Defender.BP+(EMPBP))*(Defender.End-(Defender.End*(IgnoresEnd/100))))
		if(Offender.dir==Defender.dir)
			Dam+=Dam*0.1

		var/TotalDamage=FlatDamage+((BaselineDamage*(rand(50,150)/100))*((Dam/max(Res,0.01))))

		return TotalDamage


/*proc/KiAccuracyFormula(obj/ranged/Blast/BB,mob/Offender,mob/Defender,Chance=60)
	if(Offender&&Defender)
		var/Offense=(BB.Power/ki_Power*((BB.Offense)+(Offender.Spd*(0.15+(Offender.precog_chance*0.05)))))
		var/Defense=(Defender.BP*((Defender.Def)+(Defender.Spd*(0.15+(Defender.precog_chance*0.05)))))

		var/TotalAccuracy= Chance*(Offense/max(Defense,0.01))
		if(TotalAccuracy>=99) TotalAccuracy=99
		if(TotalAccuracy<=1) TotalAccuracy=1
		if(Defender.icon_state=="Meditate"||Defender.KOd) TotalAccuracy=100
	//	Offender<<"Your [BB] had an accuracy of [TotalAccuracy]"
		return TotalAccuracy*/



/*
proc/KiDamageFormula(mob/Offender,mob/Defender,Strength=1,Force=0,Speed=0,Offense=0,DamageType="Physical",BaselineDamage=3,FlatDamage=0,UsesWeapon=1,IgnoresEnd=0)
	if(Offender&&Defender)

		var/Sword_Damage=0
		var/MaxSwordPercent=0

		for(var/obj/items/Boxing_Gloves/A in Offender) if(A.suffix) A.DurabilityCheck(Offender)
		if(UsesWeapon)
			if(!Offender.KiFists&&!Offender.Disarmed) for(var/obj/items/Sword/A in Offender) if(A.suffix&&A.Durability>0)
				Sword_Damage=A.Health
				MaxSwordPercent=A.MaxBPAdd
				A.DurabilityCheck(Offender)
				break
			if(!Sword_Damage&&!Offender.KiFists&&!Offender.Disarmed) for(var/obj/items/Hammer/A in Offender) if(A.suffix&&A.Durability>0)
				Sword_Damage=A.Health
				MaxSwordPercent=A.MaxBPAdd
				A.DurabilityCheck(Offender)
				break
			if(!Sword_Damage) for(var/obj/items/Gauntlets/A in Offender) if(A.suffix&&A.Durability>0)
				Sword_Damage=A.Health
				MaxSwordPercent=A.MaxBPAdd
				A.DurabilityCheck(Offender)
				break
		if(Defender.ArmorOn) for(var/obj/items/Armor/A in Defender) if(A.suffix&&A.Durability>0)
			A.DurabilityCheck(Defender)
			break
		if(Sword_Damage>Offender.BP*(MaxSwordPercent/100)) Sword_Damage=Offender.BP*(MaxSwordPercent/100)
		if(Offender.KiBlade) Sword_Damage=Offender.BP*0.33
		if(Offender.KiFists) if(Sword_Damage<=Offender.BP*0.18)Sword_Damage=Offender.BP*0.18

		var/EMPBP=0
		if(Defender.ArmorOn) for(var/obj/items/Armor/A in Defender) if(A.suffix&&A.Durability>0) if(A.KineticBarrier) EMPBP=Defender.BP*(A.KineticBarrier/100)
		if(Defender.EmpoweredDefenseTicks) EMPBP=Defender.BP*0.5
		if(UsesWeapon==0)Sword_Damage=0

		var/Dam=((Offender.BP+(Sword_Damage*UsesWeapon))*((Offender.Str*Strength)+(Offender.Spd*Speed)+(Offender.Pow*Force)+(Offender.Off*Offense)))
		var/Res=((Defender.BP+(EMPBP))*(Defender.End))

		var/MyGodKi=0.5
		var/TheirGodKi=0.5
		if(Offender.GodKi&&Offender.GodKiActive&&Defender.IgnoresGodKi==0&&Offender.IgnoresGodKi==0) MyGodKi+=Offender.GodKi
		if(Offender.SSjGodKi&&Defender.IgnoresGodKi==0&&Offender.IgnoresGodKi==0) MyGodKi+=Offender.SSjGodKi
		if(Defender.GodKi&&Defender.GodKiActive&&Defender.IgnoresGodKi==0&&Offender.IgnoresGodKi==0) TheirGodKi+=Defender.GodKi
		if(Defender.SSjGodKi&&Defender.IgnoresGodKi==0&&Offender.IgnoresGodKi==0) TheirGodKi+=Defender.SSjGodKi
		var/GodKiRatio=(MyGodKi/TheirGodKi)


		var/YourSkill=Offender.UnarmedSkill
		if(Offender.SwordOn||Offender.HammerOn)YourSkill=Offender.SwordSkill
		if(DamageType=="Ki")YourSkill=Offender.KiManipulation
		if(DamageType=="KiFist")YourSkill=(Offender.KiManipulation*0.5)+(Offender.UnarmedSkill*0.5)
		YourSkill/=100000
		YourSkill+=1
		if(YourSkill>1.5)YourSkill=1.5

		BaselineDamage*=YourSkill

		var/TotalDamage=FlatDamage+((BaselineDamage*(rand(50,200)/100))*((Dam/max(Res,0.01)*GodKiRatio)))


		if(Offender.StanceLevel=="Novice") TotalDamage*=0.95

		for(var/obj/items/Boxing_Gloves/G in usr) if(G.suffix)
			TotalDamage /= 20
			break

		return TotalDamage


	var/Accuracy=80
	var/Damage
	if(kiblade==0&&SpiritSword==0)
		Damage=src.Power*(src.Strength*src.StrengthMultiplier)*rand(20,160)/10*WorldDamageMult
/*		if(SpiralStrength)
		{
			Damage=src.Power*(src.Strength*src.StrengthMultiplier)*5
		}*/
	else if(kiblade==1&&!src.GetDunked&&!src.StrengthOfWill)
		Damage=src.Power*((src.Strength*src.StrengthMultiplier)+((src.Force*src.ForceMultiplier)/1.5))*rand(2,8)*WorldDamageMult
		Accuracy=60
	else if(src.SpiritSword)
		var/hasSpirit=0
		for(var/obj/Items/Sword/s in src)
			if(s.suffix)
				if(s.SpiritSword)
					hasSpirit=1
		if(hasSpirit)
			Damage=src.Power*((src.Strength*src.StrengthMultiplier)+((src.Force*src.ForceMultiplier)))*rand(2,8)*WorldDamageMult
		else
			Damage=src.Power*((src.Strength*src.StrengthMultiplier))*rand(2,8)*WorldDamageMult
	else
		Damage=src.Power*(src.Strength*src.StrengthMultiplier)*rand(1,5)*WorldDamageMult
	if(src.SoulEdge)
		Damage=src.Power*(src.GetStr(5)*WorldDamageMult)
	if(src.ChaosPunching)
	{
		Damage*=GoCrand(0.2,5)
		Accuracy*=GoCrand(0.2,5)
	}
	if(src.Headbutt)
		Damage*=5
		if(src.Headbuttantispam==0)
			src.OMessage(10, "[src] slams their head into their opponent!", "[src] triggered Headbutt.")
			src.Headbuttantispam=1
			spawn(20)
				src.Headbuttantispam=0
	if(src.WhirlwindStrike)
		Damage*=1.5
		src.OMessage(10, "[src]'s strike creates a whirlwind, drawing everyone closer!", "[src] triggered Whirlwind Strike.")
		for(var/mob/m in oview(3, src))
			step_towards(m, src)
		for(var/mob/m in oview(5, src))
			step_towards(m, src)
		for(var/mob/m in oview(8, src))
			step_towards(m, src)
		src.WhirlwindStrike=0
	if(src.RebuffOverdrive)
		Damage*=2
		src.OMessage(10, "[src] strikes their opponent with Hamon-infused elbows!", "[src] triggered Rebuff Overdrive.")
		src.RebuffOverdrive=0
	if(src.PathType=="Luck")
		Damage*=GoCrand(0,1.6)
		Accuracy*=rand(0,3)
		if(src.trans["unlocked"] >=1)
			Damage*=GoCrand(0,3)
			Accuracy*=GoCrand(0,2)

mob/proc/Knockback(Distance,mob/P,Direction=get_dir(P,src),KB_Damage=1) spawn if(src)//Some abilities won't damage upon KB
	if(istype(src,/mob/Player/Afterimage)) return
	if(src.Class=="Heracles")
		Distance*=2
	if(P.Class=="Heracles")
		Distance*=0.5
	if(src.Darlose)
		Distance*=20
	if(src.SatsuiNoHado||src.KamuiSenjin||src.SuperKamuiAscension)
		return
	if(src.BladeSlow)
		src.DelayedKB+=Distance
		src.DelayedKBCatalyst=P
		return
	if(Distance>50)
		Distance=50
*/
