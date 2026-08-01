var/const/CHARACTER_MUTATION_SAVE_VERSION = 2
var/list/CHARACTER_MUTATIONS = list(
	"energy_efficiency" = new /datum/CharacterMutation("Energy"),
	"adaptive_musculature" = new /datum/CharacterMutation("Strength"),
	"reinforced_frame" = new /datum/CharacterMutation("Durability"),
	"accelerated_reflexes" = new /datum/CharacterMutation("Speed"),
	"focused_core" = new /datum/CharacterMutation("Force"),
	"resilient_cells" = new /datum/CharacterMutation("Resistance"),
	"predatory_instinct" = new /datum/CharacterMutation("Offense"),
	"reactive_guard" = new /datum/CharacterMutation("Defense"),
	"regenerative_cells" = new /datum/CharacterMutation("Regeneration"),
	"accelerated_recovery" = new /datum/CharacterMutation("Recovery"),
	"volatile_potential" = new /datum/CharacterMutation("Anger")
)

datum/CharacterMutation
	var/stat

	New(stat)
		src.stat = stat

mob/var
	mutation_save_version
	mutation_rarity
	list/character_mutations = list()

mob/proc/rollCharacterMutations(forced_rarity)
	if(src.mutation_save_version >= CHARACTER_MUTATION_SAVE_VERSION) return
	if(!islist(src.character_mutations)) src.character_mutations = list()
	src.character_mutations.Cut()
	src.mutation_rarity = null

	var/rarity = forced_rarity
	if(isnull(rarity))
		var/roll = rand(1, 100000)
		if(roll <= 1) rarity = "Anomaly"
		else if(roll <= 10) rarity = "Rare"
		else if(roll <= 50) rarity = "Uncommon"
		else if(roll <= 250) rarity = "Common"
	if(!(rarity in list("Common", "Uncommon", "Rare", "Anomaly")))
		src.mutation_save_version = CHARACTER_MUTATION_SAVE_VERSION
		return

	var/mutation_count = 1
	var/max_percent = 10
	if(rarity == "Uncommon") max_percent = 20
	if(rarity == "Rare")
		mutation_count = rand(2, 3)
		max_percent = 20
	if(rarity == "Anomaly")
		mutation_count = CHARACTER_MUTATIONS.len
		max_percent = 30

	var/list/available_mutations = list()
	for(var/mutation_id in CHARACTER_MUTATIONS)
		available_mutations += mutation_id
	while(mutation_count > 0 && available_mutations.len)
		var/mutation_id = pick(available_mutations)
		src.character_mutations[mutation_id] = rand(1, max_percent)
		available_mutations -= mutation_id
		mutation_count--

	src.mutation_rarity = rarity
	src.mutation_save_version = CHARACTER_MUTATION_SAVE_VERSION

mob/proc/normalizeCharacterMutations()
	if(!islist(src.character_mutations)) src.character_mutations = list()
	if(src.mutation_save_version < 2 && src.character_mutations.len)
		var/list/migrated_mutations = list()
		for(var/index in 1 to src.character_mutations.len)
			var/mutation_id = src.character_mutations[index]
			if(!CHARACTER_MUTATIONS[mutation_id]) continue
			var/legacy_percent = src.character_mutations[mutation_id]
			if(!isnum(legacy_percent) || legacy_percent <= 0) legacy_percent = 10
			migrated_mutations[mutation_id] = Clamp(round(legacy_percent), 1, 20)
		src.character_mutations = migrated_mutations
	if(!(src.mutation_rarity in list("Common", "Uncommon", "Rare", "Anomaly")))
		if(src.character_mutations.len == CHARACTER_MUTATIONS.len) src.mutation_rarity = "Anomaly"
		else if(src.character_mutations.len > 1) src.mutation_rarity = "Rare"
		else if(src.character_mutations.len == 1)
			var/legacy_id = src.character_mutations[1]
			if(text2num("[src.character_mutations[legacy_id]]") > 10) src.mutation_rarity = "Uncommon"
			else src.mutation_rarity = "Common"

	var/max_count
	var/max_percent
	switch(src.mutation_rarity)
		if("Common")
			max_count = 1
			max_percent = 10
		if("Uncommon")
			max_count = 1
			max_percent = 20
		if("Rare")
			max_count = 3
			max_percent = 20
		if("Anomaly")
			max_count = CHARACTER_MUTATIONS.len
			max_percent = 30
		else
			src.character_mutations = list()
			src.mutation_rarity = null
			src.mutation_save_version = CHARACTER_MUTATION_SAVE_VERSION
			return

	var/list/valid_mutations = list()
	for(var/mutation_id in src.character_mutations)
		if(valid_mutations.len >= max_count) break
		if(!CHARACTER_MUTATIONS[mutation_id]) continue
		var/percent = round(text2num("[src.character_mutations[mutation_id]]"))
		if(percent <= 0) continue
		valid_mutations[mutation_id] = Clamp(percent, 1, max_percent)
	src.character_mutations = valid_mutations
	if(!valid_mutations.len) src.mutation_rarity = null
	src.mutation_save_version = CHARACTER_MUTATION_SAVE_VERSION

mob/proc/getCharacterMutationRarity()
	if(!islist(src.character_mutations) || !src.character_mutations.len) return null
	var/highest_percent = 0
	for(var/mutation_id in src.character_mutations)
		highest_percent = max(highest_percent, text2num("[src.character_mutations[mutation_id]]"))
	if(src.character_mutations.len == 1 && highest_percent <= 10) return "Common"
	if(src.character_mutations.len == 1 && highest_percent <= 20) return "Uncommon"
	if(src.character_mutations.len <= 3 && highest_percent <= 20) return "Rare"
	return "Anomaly"

mob/proc/applyCharacterMutationRatio(mutation_id, ratio)
	var/datum/CharacterMutation/mutation = CHARACTER_MUTATIONS[mutation_id]
	if(!mutation || !isnum(ratio) || ratio <= 0) return FALSE
	switch(mutation.stat)
		if("Energy")
			src.Eff *= ratio
			src.max_ki *= ratio
			src.Ki *= ratio
		if("Strength")
			src.strmod *= ratio
			src.Str *= ratio
		if("Durability")
			src.endmod *= ratio
			src.End *= ratio
		if("Speed")
			src.spdmod *= ratio
			src.Spd *= ratio
		if("Force")
			src.formod *= ratio
			src.Pow *= ratio
		if("Resistance")
			src.resmod *= ratio
			src.Res *= ratio
		if("Offense")
			src.offmod *= ratio
			src.Off *= ratio
		if("Defense")
			src.defmod *= ratio
			src.Def *= ratio
		if("Regeneration") src.regen *= ratio
		if("Recovery") src.recov *= ratio
		if("Anger") src.max_anger *= ratio
	return TRUE

mob/proc/setCharacterMutationValue(mutation_id, percent)
	if(!CHARACTER_MUTATIONS[mutation_id]) return FALSE
	if(!islist(src.character_mutations)) src.character_mutations = list()
	var/old_percent = max(0, text2num("[src.character_mutations[mutation_id]]"))
	var/new_percent = Clamp(round(text2num("[percent]")), 0, 30)
	if(old_percent == new_percent) return TRUE
	var/old_multiplier = 1 + old_percent / 100
	var/new_multiplier = 1 + new_percent / 100
	if(!applyCharacterMutationRatio(mutation_id, new_multiplier / old_multiplier)) return FALSE
	if(new_percent) src.character_mutations[mutation_id] = new_percent
	else src.character_mutations -= mutation_id
	src.mutation_rarity = getCharacterMutationRarity()
	src.mutation_save_version = CHARACTER_MUTATION_SAVE_VERSION
	return TRUE

mob/proc/applyCharacterMutations()
	if(!islist(src.character_mutations)) return
	for(var/mutation_id in src.character_mutations)
		var/datum/CharacterMutation/mutation = CHARACTER_MUTATIONS[mutation_id]
		if(!mutation) continue
		var/percent = Clamp(text2num("[src.character_mutations[mutation_id]]"), 1, 30)
		var/multiplier = 1 + percent / 100
		switch(mutation.stat)
			if("Energy")
				src.Eff *= multiplier
				src.max_ki *= multiplier
				src.Ki *= multiplier
			if("Strength")
				src.strmod *= multiplier
				src.Str *= multiplier
			if("Durability")
				src.endmod *= multiplier
				src.End *= multiplier
			if("Speed")
				src.spdmod *= multiplier
				src.Spd *= multiplier
			if("Force")
				src.formod *= multiplier
				src.Pow *= multiplier
			if("Resistance")
				src.resmod *= multiplier
				src.Res *= multiplier
			if("Offense")
				src.offmod *= multiplier
				src.Off *= multiplier
			if("Defense")
				src.defmod *= multiplier
				src.Def *= multiplier
			if("Regeneration") src.regen *= multiplier
			if("Recovery") src.recov *= multiplier
			if("Anger") src.max_anger *= multiplier
