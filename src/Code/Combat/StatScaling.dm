// Rate stats use the character's own build: an equal seven-stat build rates 100.
// Damage and accuracy contests still use their original effective stat values.
mob/proc/getNexusBuildStatRating(stat_value)
	if(!nexusIsFiniteNumber(stat_value) || stat_value <= 0) return 0
	var/unarmed_strength = max(0, Swordless_strength())
	var/largest_stat = max(unarmed_strength, End, Spd, Pow, Res, Off, Def)
	if(!nexusIsFiniteNumber(largest_stat) || largest_stat <= 0) return 0
	// Divide before adding so large, finite saved stats cannot overflow the total.
	var/scaled_total = unarmed_strength / largest_stat + max(0, End) / largest_stat + max(0, Spd) / largest_stat + max(0, Pow) / largest_stat + max(0, Res) / largest_stat + max(0, Off) / largest_stat + max(0, Def) / largest_stat
	if(!nexusIsFiniteNumber(scaled_total) || scaled_total <= 0) return 0
	return (stat_value / largest_stat) * (700 / scaled_total)
