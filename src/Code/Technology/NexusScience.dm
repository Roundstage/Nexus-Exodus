mob/var
	has_adamantine_skeleton = FALSE
	android_upgrade_components = 0

mob/proc/getMutationProfileText()
	normalizeCharacterMutations()
	if(!islist(character_mutations) || !character_mutations.len) return "No awakened mutations."
	var/list/lines = list()
	for(var/mutation_id in character_mutations)
		var/datum/CharacterMutation/mutation = CHARACTER_MUTATIONS[mutation_id]
		if(!mutation) continue
		lines += "[mutation.stat]: +[round(character_mutations[mutation_id])]%"
	return lines.len ? jointext(lines, "<br>") : "No awakened mutations."

mob/proc/awakenRandomMutation(minimum_percent = 5, maximum_percent = 12, maximum_mutations = 2, synthetic = FALSE)
	var/is_android = Race == "Android"
	if(synthetic && !is_android)
		src << "Self-replicating code can only alter an Android core."
		return FALSE
	if(!synthetic && is_android)
		src << "Organic mutagen cannot alter an Android core."
		return FALSE
	normalizeCharacterMutations()
	if(character_mutations.len >= maximum_mutations)
		src << "Your mutation profile cannot safely support another awakened trait."
		return FALSE
	var/list/available_mutations = list()
	for(var/mutation_id in CHARACTER_MUTATIONS)
		var/datum/CharacterMutation/candidate_mutation = CHARACTER_MUTATIONS[mutation_id]
		if(candidate_mutation.stat == "Anger" && !canPossessAnger()) continue
		if(!(mutation_id in character_mutations)) available_mutations += mutation_id
	if(!available_mutations.len) return FALSE
	var/chosen_id = pick(available_mutations)
	var/value = rand(max(1, round(minimum_percent)), max(round(minimum_percent), round(maximum_percent)))
	if(!setCharacterMutationValue(chosen_id, value)) return FALSE
	var/datum/CharacterMutation/mutation = CHARACTER_MUTATIONS[chosen_id]
	player_view(10, src) << "<font color=#7dff9b>[src]'s physiology surges as a [mutation.stat] mutation awakens."
	Play_Melee_Sound(sound_range = 10, origin = src, sound_file = 'src/Sound/SoundEffects/Combat/Kiplosion.ogg', sound_volume = 40)
	Make_Shockwave(src, sw_icon_size = 64)
	src << "Mutation awakened: [mutation.stat] +[value]%."
	return TRUE

obj/items/MutagenInjector
	name = "Mutagen Injector"
	desc = "An integrated organic mutagen. It awakens one random 5-12% mutation, up to two mutations per organic character."
	icon = 'src/Icons/Objects/Technology/Roids.dmi'
	Cost = 10000000
	science = 1
	science_level = 7
	science_path = "Genetics"
	Savable = 1
	Stealable = 1

	verb/Inject_Mutagen()
		set src in usr
		if(usr.awakenRandomMutation(5, 12, 2, FALSE)) del(src)

obj/items/SelfReplicatingCodeInjector
	name = "Self-Replicating Code Injector"
	desc = "A synthetic counterpart to mutagen that awakens one random 5-12% Android mutation."
	icon = 'src/Icons/Objects/Technology/ControlChip.dmi'
	Cost = 12000000
	science = 1
	science_level = 7
	science_path = "Robotics"
	Savable = 1
	Stealable = 1

	verb/Inject_Code()
		set src in usr
		if(usr.awakenRandomMutation(5, 12, 2, TRUE)) del(src)

obj/items/GeneticSequencer
	name = "Genetic Sequencer"
	desc = "Analyzes native mutation profiles and can stabilize one awakened mutation by 1%, up to 30%. Stabilization has a ten-minute cooldown."
	icon = 'src/Icons/Objects/Technology/ScanMachine.dmi'
	Cost = 15000000
	science = 1
	science_level = 8
	science_path = "Genetics"
	Savable = 1
	Stealable = 1
	var/next_stabilization = 0

	verb/Analyze_Genetics(mob/target in view(1, usr))
		set src in view(1)
		if(!target) return
		usr << "<b>Genetic profile: [target]</b><br>Rarity: [target.mutation_rarity ? target.mutation_rarity : "None"]<br>[target.getMutationProfileText()]<br>Adamantine skeleton: [target.has_adamantine_skeleton ? "Present" : "Absent"]"

	verb/Stabilize_Mutation(mob/target in view(1, usr))
		set src in view(1)
		var/mob/user = usr
		var/atom/original_location = loc
		if(!target || !canContinueNexusTradeInteraction(user, original_location) || !(target in view(1, user))) return
		if(world.time < next_stabilization)
			user << "The sequencer will be ready in [round((next_stabilization - world.time) / 10)] seconds."
			return
		target.normalizeCharacterMutations()
		if(!target.character_mutations.len)
			usr << "[target] has no awakened mutation to stabilize."
			return
		var/list/options = list()
		for(var/mutation_id in target.character_mutations)
			var/datum/CharacterMutation/mutation = CHARACTER_MUTATIONS[mutation_id]
			if(!mutation) continue
			var/current_value = text2num("[target.character_mutations[mutation_id]]")
			if(current_value >= 30) continue
			options["[mutation.stat] ([current_value]%)"] = mutation_id
		if(!options.len)
			usr << "Every mutation in this profile is already fully stabilized."
			return
		var/choice = input(user, "Stabilize which mutation in [target]?", name) as null|anything in options
		if(isnull(choice) || !(choice in options) || !canContinueNexusTradeInteraction(user, original_location) || !(target in view(1, user))) return
		var/chosen_id = options[choice]
		if(!(chosen_id in target.character_mutations) || !CHARACTER_MUTATIONS[chosen_id]) return
		var/current_value = text2num("[target.character_mutations[chosen_id]]")
		if(current_value >= 30 || world.time < next_stabilization) return
		if(!target.setCharacterMutationValue(chosen_id, min(30, current_value + 1))) return
		next_stabilization = world.time + 6000
		player_view(10, target) << "The Genetic Sequencer stabilizes [target]'s mutation profile."

obj/items/AdamantineSkeletonTreatment
	name = "Adamantine Skeleton Treatment"
	desc = "A one-use integrated procedure that permanently reduces incoming damage by 8%. Installation causes an immediate knockout."
	icon = 'src/Icons/Objects/Technology/Vial.dmi'
	Cost = 25000000
	science = 1
	science_level = 8
	science_path = "Genetics"
	Savable = 1
	Stealable = 1

	verb/Install_Skeleton()
		set src in usr
		var/mob/user = usr
		if(!canUseAfterNexusTradeYield(user)) return
		if(user.Race == "Android")
			user << "This organic treatment is incompatible with an Android core."
			return
		if(user.has_adamantine_skeleton)
			user << "Your skeleton has already received this treatment."
			return
		if(alert(user, "Installation permanently changes this character and causes an immediate knockout. Continue?", name, "Cancel", "Install") != "Install") return
		if(!canUseAfterNexusTradeYield(user) || user.Race == "Android" || user.has_adamantine_skeleton) return
		user.has_adamantine_skeleton = TRUE
		user.willpower = 0
		player_view(10, user) << "<font color=#b8d8e8>[user]'s skeletal structure hardens with an adamantine resonance."
		Play_Melee_Sound(sound_range = 10, origin = user, sound_file = 'src/Sound/SoundEffects/Combat/Kiplosion.ogg', sound_volume = 45)
		user.KO(null)
		del(src)

obj/items/MutationSuppressant
	name = "Mutation Suppressant"
	desc = "A precision genetic treatment that removes one chosen awakened mutation without rerolling the remaining profile."
	icon = 'src/Icons/Objects/Technology/PoisonInjection.dmi'
	Cost = 8000000
	science = 1
	science_level = 6
	science_path = "Genetics"
	Savable = 1
	Stealable = 1

	verb/Suppress_Mutation()
		set src in usr
		var/mob/user = usr
		if(!canUseAfterNexusTradeYield(user)) return
		user.normalizeCharacterMutations()
		if(!user.character_mutations.len)
			user << "You have no awakened mutations to suppress."
			return
		var/list/options = list()
		for(var/mutation_id in user.character_mutations)
			var/datum/CharacterMutation/mutation = CHARACTER_MUTATIONS[mutation_id]
			if(mutation) options["[mutation.stat] (+[user.character_mutations[mutation_id]]%)"] = mutation_id
		var/choice = input(user, "Suppress which mutation? This cannot be undone.", name) as null|anything in options
		if(isnull(choice) || !(choice in options) || !canUseAfterNexusTradeYield(user)) return
		if(alert(user, "Permanently remove [choice]?", name, "Cancel", "Suppress") != "Suppress") return
		if(!canUseAfterNexusTradeYield(user) || !(choice in options) || !(options[choice] in user.character_mutations)) return
		if(user.setCharacterMutationValue(options[choice], 0))
			player_view(10, user) << "The suppressant rewrites part of [user]'s mutation profile."
			del(src)

obj/items/NexusRepairKit
	name = "Repair Kit"
	desc = "A one-use integrated repair kit that restores a damaged item's baseline structural integrity. The target must be nearby and unequipped."
	icon = 'src/Icons/Objects/Technology/Lab.dmi'
	icon_state = "Tool2"
	Cost = 800000
	science = 1
	science_level = 4
	science_path = "Engineering"
	Savable = 1

	verb/Repair_Item()
		set src in usr
		var/mob/user = usr
		if(!canUseAfterNexusTradeYield(user)) return
		var/list/options = list()
		var/list/original_locations = list()
		for(var/obj/items/target in view(1, user))
			if(target == src || target.suffix || !target.takes_gradual_damage) continue
			if(target.Health < initial(target.Health))
				options += target
				original_locations[target] = target.loc
		var/obj/items/choice = input(user, "Repair which damaged item?", name) as null|obj in options
		var/atom/original_choice_location = original_locations[choice]
		if(!choice || !canUseAfterNexusTradeYield(user) || !(choice in options) || choice.loc != original_choice_location || !(choice in view(1, user)) || choice.suffix || !choice.takes_gradual_damage) return
		if(original_choice_location == user && (!(choice in user.item_list) || choice.isNexusTradeOfferedBy(user))) return
		choice.Health = max(choice.Health, initial(choice.Health))
		player_view(10, user) << "[user] restores [choice] to its baseline integrity."
		del(src)

obj/items/NexusUpgradeKit
	name = "Scientific Upgrade Kit"
	desc = "A one-use engineering kit that applies masterwork calibration to Nexus-forged equipment."
	icon = 'src/Icons/Objects/Technology/Lab.dmi'
	icon_state = "Tool2"
	Cost = 1000000
	science = 1
	science_level = 6
	science_path = "Engineering"
	Savable = 1

	verb/Upgrade_Equipment()
		set src in usr
		var/mob/user = usr
		if(!canUseAfterNexusTradeYield(user)) return
		var/list/options = list()
		for(var/obj/items/Sword/Forged/weapon in user.item_list)
			if(!weapon.master_blacksmith_quality) options += weapon
		for(var/obj/items/Armor/Forged/armor in user.item_list)
			if(!armor.master_blacksmith_quality) options += armor
		for(var/obj/items/Gloves/Forged/gloves in user.item_list)
			if(!gloves.master_blacksmith_quality) options += gloves
		for(var/obj/items/Mask/Forged/mask in user.item_list)
			if(!mask.master_blacksmith_quality) options += mask
		var/obj/items/choice = input(user, "Upgrade which forged item?", name) as null|obj in options
		if(!choice || !canUseAfterNexusTradeYield(user) || !(choice in options) || choice.loc != user || !(choice in user.item_list)) return
		if(istype(choice, /obj/items/Sword/Forged))
			var/obj/items/Sword/Forged/weapon = choice
			weapon.master_blacksmith_quality = TRUE
			weapon.refreshForgedWeapon()
		else if(istype(choice, /obj/items/Armor/Forged))
			var/obj/items/Armor/Forged/armor = choice
			armor.master_blacksmith_quality = TRUE
			armor.refreshForgedArmor()
		else if(istype(choice, /obj/items/Gloves/Forged))
			var/obj/items/Gloves/Forged/gloves = choice
			gloves.master_blacksmith_quality = TRUE
			gloves.refreshForgedGloves()
		else
			var/obj/items/Mask/Forged/mask = choice
			mask.master_blacksmith_quality = TRUE
			mask.refreshForgedMask()
		player_view(10, user) << "[user] installs a precision upgrade in [choice]."
		del(src)

obj/items/MedicalAssessment
	name = "Medical Assessment"
	desc = "A disposable diagnostic package that reports a nearby character's vitals, biological age and mutation profile."
	icon = 'src/Icons/Objects/Technology/Lab.dmi'
	icon_state = "Lab2"
	Cost = 600000
	science = 1
	science_level = 4
	science_path = "Genetics"
	Savable = 1

	verb/Assess(mob/target in view(5, usr))
		set src in usr
		if(!target) return
		player_view(8, usr) << "[usr] performs a medical assessment of [target]."
		usr << "<b>Medical assessment: [target]</b><br>Health: [round(target.Health, 0.1)]%<br>Energy: [round(target.Ki)] / [round(target.max_ki)]<br>Physical age: [round(target.Age, 0.1)]<br>Decline age: [round(target.Decline, 0.1)]<br>Body potential: [round(target.Body * 100, 0.1)]%<br>Radiation: [round(target.radiation_level, 0.1)]%<br>[target.getMutationProfileText()]"
		del(src)

obj/items/ProspectingToolkit
	name = "Prospecting Toolkit"
	desc = "A one-use ground scanner that reveals one nearby native ore deposit. Mining progression still controls extraction."
	icon = 'src/Icons/Objects/Technology/ScanMachine.dmi'
	Cost = 1000000
	science = 1
	science_level = 5
	science_path = "Engineering"
	Savable = 1

	verb/Prospect()
		set src in usr
		if(usr.KO) return
		var/list/valid_tiles = list()
		for(var/turf/target in range(2, usr))
			if(isValidWorldOreTurf(target)) valid_tiles += target
		if(!valid_tiles.len)
			usr << "The toolkit finds no viable ground nearby."
			return
		var/turf/target = pick(valid_tiles)
		var/obj/WorldOreDeposit/deposit = new(target)
		deposit.configureOre(getWorldOreTypeForRoll(rand(1, 1000)))
		player_view(10, usr) << "[usr]'s prospecting pulse reveals [deposit]."
		del(src)

obj/items/AdvancedDoorPass
	parent_type = /obj/items/Door_Pass
	name = "Advanced Door Pass"
	desc = "An expensive adaptive pass that can open password-secured doors without storing their password."
	icon = 'src/Icons/Objects/Technology/DoorPass.dmi'
	Cost = 20000000
	science = 1
	science_level = 8
	science_path = "Engineering"
	Stealable = 1

obj/items/HealingPylon
	name = "Healing Pylon"
	desc = "A stationary medical field that increases natural regeneration by 50% within five tiles."
	icon = 'src/Icons/Objects/Technology/HealTank.dmi'
	Cost = 500000000
	science = 1
	science_level = 8
	science_path = "Genetics"
	density = 1
	Savable = 1
	Grabbable = 1

mob/proc/getScientificHealingMultiplier()
	for(var/obj/items/HealingPylon/pylon in range(5, src))
		if(pylon) return 1.5
	return 1

obj/items/Armor/PowerArmor
	name = "Power Armor"
	desc = "An adapted integrated power-armor suit with strong protection and substantial weight."
	icon = 'src/Icons/Objects/Technology/Modules.dmi'
	Cost = 900000000
	science = 1
	science_level = 8
	science_path = "Robotics"
	Armor = 1.75
	heaviness = 1.35
	can_change_icon = 0

obj/items/AndroidUpgradeComponent
	name = "Android Upgrade Component"
	desc = "A permanent Android core upgrade. Up to three components each improve BP growth and recovery by 3%."
	icon = 'src/Icons/Objects/Technology/Modules.dmi'
	Cost = 6000000
	science = 1
	science_level = 6
	science_path = "Robotics"
	Savable = 1

	verb/Install_Component()
		set src in usr
		if(usr.Race != "Android")
			usr << "Only an Android core can accept this component."
			return
		if(usr.android_upgrade_components >= 3)
			usr << "Your core has no remaining component slots."
			return
		usr.android_upgrade_components++
		usr.bp_mod *= 1.03
		usr.recov *= 1.03
		player_view(10, usr) << "[usr] integrates an Android upgrade component."
		del(src)

obj/items/AndroidChassis
	name = "Android Chassis"
	desc = "A reusable synthetic repair shell. An adjacent Android may enter it for a full repair once every ten minutes."
	icon = 'src/Icons/Objects/Technology/HealTank.dmi'
	Cost = 10000000
	science = 1
	science_level = 6
	science_path = "Robotics"
	density = 1
	Savable = 1
	Grabbable = 1
	var/next_repair = 0

	verb/Repair_Android(mob/target in view(1, usr))
		set src in view(1)
		if(!target || target.Race != "Android")
			usr << "The chassis only accepts Android cores."
			return
		if(world.time < next_repair)
			usr << "The chassis is still rebuilding its repair nanites."
			return
		target.FullHeal()
		next_repair = world.time + 6000
		player_view(10, target) << "The Android chassis completes a full synthetic repair on [target]."

mob/Admin4/verb/testNexusScience(mob/character in players)
	set name = "Test Nexus Science"
	set category = "Admin"
	if(!character) return
	new /obj/items/MutagenInjector(character)
	new /obj/items/SelfReplicatingCodeInjector(character)
	new /obj/items/GeneticSequencer(character)
	new /obj/items/AdamantineSkeletonTreatment(character)
	new /obj/items/MutationSuppressant(character)
	new /obj/items/NexusRepairKit(character)
	new /obj/items/NexusUpgradeKit(character)
	new /obj/items/MedicalAssessment(character)
	new /obj/items/ProspectingToolkit(character)
	new /obj/items/AdvancedDoorPass(character)
	new /obj/items/AndroidUpgradeComponent(character)
	character << "Nexus science test package granted."
	src << "Granted the Nexus genetics test package to [character]."
