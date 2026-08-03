var/Max_Speed=1 //The speed of the person with the highest speed online
var/mob/max_speed_mob

var/speedDelayMultMod = 2.3

mob/proc/Speed_delay_mult(severity = 1)
	var/scalingFactor = (Spd/150) * GLOBAL_MELEE_SPEED_OFFSET //tuning factor
	var/ratio = 0.1 + (scalingFactor * Spd / (510 + Spd)) * 5.4

	var/mod = 1 //1 = perfectly average
	var/minMod = 0.25 //was 0.25

	if(ratio > 1) //high speed
		mod += 1 * (ratio**severity - 1)
	else //low speed
		mod *= ratio**severity
		if(mod < minMod) mod = minMod
	mod = 1 / mod //must be inverted to represent a "delay"

	var/final_delay = mod * speedDelayMultMod
	if(arcane_accelerated_until > world.time) final_delay *= 0.8
	return final_delay
