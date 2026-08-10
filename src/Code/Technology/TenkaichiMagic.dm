#define NEXUS_ARCANE_PORTAL_LIFETIME 6000
#define NEXUS_ARCANE_DEFENSE_MULTIPLIER 1.5

mob/var
	list/arcane_permanent_effects = list()
	tmp/arcane_attack_empowered_until = 0
	tmp/arcane_defense_empowered_until = 0
	tmp/arcane_defense_stat_empowered_until = 0
	tmp/arcane_accelerated_until = 0
	tmp/arcane_regeneration_until = 0
	tmp/arcane_replenishment_until = 0
	tmp/arcane_merriment_until = 0
	arcane_portal_anchor_x = 0
	arcane_portal_anchor_y = 0
	arcane_portal_anchor_z = 0

obj/var/tmp/next_arcane_use = 0
turf/var/tmp/arcane_gravity = 0

mob/proc/getArcaneDefenseStatMultiplier()
	if(arcane_defense_stat_empowered_until > world.time) return NEXUS_ARCANE_DEFENSE_MULTIPLIER
	return 1

mob/proc/getArcaneEmpoweredEndurance()
	return End * getArcaneDefenseStatMultiplier()

mob/proc/getArcaneEmpoweredResistance()
	return Res * getArcaneDefenseStatMultiplier()

mob/proc/isArcaneAlly(mob/other)
	if(!other) return FALSE
	if(other == src) return TRUE
	for(var/obj/League/owned_league in league_list)
		for(var/obj/League/other_league in other.league_list)
			if(owned_league.league_id == other_league.league_id) return TRUE
	return FALSE

mob/proc/hasArcanePermanentEffect(effect_id)
	if(!islist(arcane_permanent_effects)) arcane_permanent_effects = list()
	return effect_id in arcane_permanent_effects

mob/proc/addArcanePermanentEffect(effect_id)
	if(!effect_id) return FALSE
	if(!islist(arcane_permanent_effects)) arcane_permanent_effects = list()
	if(effect_id in arcane_permanent_effects) return FALSE
	arcane_permanent_effects += effect_id
	return TRUE

mob/proc/spendArcaneEssence(amount, spell_name, obj/spell, cooldown = 0)
	if(KO || rp_mode || !client) return FALSE
	if(spell && world.time < spell.next_arcane_use)
		src << "[spell_name] will be ready in [round((spell.next_arcane_use - world.time) / 10, 0.1)] seconds."
		return FALSE
	amount = max(0, round(amount / max(0.5, getMagicPotential()), 0.1))
	if(arcane_essence < amount)
		src << "[spell_name] requires [amount] Arcane Essence; you have [round(arcane_essence, 0.1)]."
		return FALSE
	arcane_essence -= amount
	if(spell && cooldown > 0) spell.next_arcane_use = world.time + cooldown
	gainMagicExperience(max(1, amount / 8), "casting [spell_name]", announce = FALSE)
	return TRUE

mob/proc/showArcaneCastVfx(color = "#b875ff", sound_volume = 35, effect_state = "portal", sound_category = "ability_charge")
	player_view(12, src) << "<font color=[color]>Arcane sigils flare around [src]."
	var/cast_sound = getNexusShonenSound(sound_category)
	if(!cast_sound) cast_sound = 'src/Sound/SoundEffects/Combat/Kiplosion.ogg'
	Play_Melee_Sound(sound_range = 12, origin = src, sound_file = cast_sound, sound_volume = sound_volume)
	showNexusOpenCombatEffect(src, "foozle_magic_64", effect_state, 1.2, color, 235, BLEND_ADD, 10, 0.2)

proc/arcaneDirectionText(direction)
	switch(direction)
		if(NORTH) return "north"
		if(SOUTH) return "south"
		if(EAST) return "east"
		if(WEST) return "west"
		if(NORTHEAST) return "northeast"
		if(NORTHWEST) return "northwest"
		if(SOUTHEAST) return "southeast"
		if(SOUTHWEST) return "southwest"
	return "an unknown direction"

obj/ArcaneSpell
	Skill = 1
	teachable = 0
	hotbar_type = "Ability"
	can_hotbar = 1
	icon = 'src/Icons/Effects/OpenCombat/FoozleMagic64.dmi'
	icon_state = "portal"

obj/ArcaneSpell/Projectile
	var
		essence_cost = 10
		cooldown = 20
		damage_percent = 0.55
		explosion_size = 0
		projectile_speed = 48
		projectile_distance = 48
		projectile_stun = 0
		cast_effect_state = "portal"
		impact_effect_state = "explosion"
		cast_sound_category = "ability_charge"
		impact_sound_category = "ability_release"

	proc/cast(mob/caster)
		if(!caster || caster.cant_blast()) return FALSE
		if(!caster.spendArcaneEssence(essence_cost, name, src, cooldown)) return FALSE
		var/obj/Blast/projectile = get_cached_blast()
		projectile.setStats(caster, Percent = damage_percent, Off_Mult = 1.15, Explosion = explosion_size, explosion_percent = explosion_size ? damage_percent * 0.7 : 0)
		projectile.from_attack = src
		projectile.icon = icon
		projectile.icon_state = icon_state
		projectile.projectile_impact_icon = 'src/Icons/Effects/OpenCombat/FoozleMagic64.dmi'
		projectile.projectile_impact_icon_state = impact_effect_state
		projectile.projectile_impact_sound = getNexusShonenSound(impact_sound_category)
		projectile.projectile_impact_sound_volume = 46
		projectile.Stun = projectile_stun
		projectile.Shockwave = explosion_size ? 1.5 : 0.5
		projectile.dir = caster.dir
		projectile.SafeTeleport(caster.loc)
		projectile.step_x = caster.step_x
		projectile.step_y = caster.step_y
		projectile.queueNexusProjectileGlowUpdate()
		projectile.BlastAutoTargetGo(boundWidth = 20, boundHeight = 20, vectorSpeed = projectile_speed, angleLimit = 30, dist = projectile_distance, randomAngle = 1)
		caster.showArcaneCastVfx(effect_state = cast_effect_state, sound_category = cast_sound_category)
		return TRUE

	verb/Hotbar_use()
		set hidden = 1
		cast(usr)

	Fireball
		name = "Fireball"
		desc = "Launch a homing sphere of arcane fire that erupts on impact."
		icon_state = "fire_ball"
		essence_cost = 18
		cooldown = 24
		damage_percent = 0.72
		explosion_size = 1
		cast_effect_state = "fire_ball"
		impact_effect_state = "explosion"
		impact_sound_category = "explosions"
		verb/Fireball()
			set category = "Skills"
			cast(usr)

	FrostBolt
		name = "Frost Bolt"
		desc = "Launch a precise freezing bolt that briefly stuns its target."
		icon_state = "water"
		essence_cost = 15
		cooldown = 20
		damage_percent = 0.55
		projectile_stun = 1
		projectile_speed = 54
		cast_effect_state = "water"
		impact_effect_state = "water_geyser"
		verb/Frost_Bolt()
			set category = "Skills"
			cast(usr)

	LightningBolt
		name = "Lightning Bolt"
		desc = "Condense Arcane Essence into a fast, stunning lightning strike."
		icon_state = "wind"
		essence_cost = 20
		cooldown = 32
		damage_percent = 0.68
		projectile_stun = 1
		projectile_speed = 64
		projectile_distance = 36
		cast_effect_state = "wind"
		impact_effect_state = "wind"
		cast_sound_category = "electric"
		impact_sound_category = "electric"
		verb/Lightning_Bolt()
			set category = "Skills"
			cast(usr)

obj/ArcaneSpell/FrostNova
	name = "Frost Nova"
	desc = "Release a freezing pulse that damages and stuns every valid enemy within two tiles."
	icon_state = "water_geyser"

	proc/applyNova(mob/caster)
		if(!caster) return 0
		var/hit_count = 0
		for(var/mob/target in oview(2, caster))
			if(!caster.canHitTenkaichiTechniqueTarget(target) || target.KO) continue
			var/damage = Clamp(7 * (caster.BP / max(target.BP, 1)) ** 0.35, 2, 16)
			if(!caster.applyTenkaichiTechniqueDamage(target, damage, name)) continue
			target.ApplyStun(time = 20, no_immunity = TRUE, stun_power = 2)
			showNexusOpenCombatEffect(target, "foozle_magic_64", "water_geyser", 0.75, "#8ee9ff", 225, BLEND_ADD, 12, 0.2)
			hit_count++
		return hit_count

	proc/cast(mob/caster)
		if(!caster || !caster.spendArcaneEssence(35, name, src, 70)) return FALSE
		caster.showArcaneCastVfx("#8ee9ff", 45, "water_geyser", "ability_release")
		applyNova(caster)
		return TRUE

	verb/Hotbar_use()
		set hidden = 1
		cast(usr)
	verb/Frost_Nova()
		set category = "Skills"
		cast(usr)

obj/ArcaneSpell/EarthPrison
	name = "Earth Prison"
	desc = "Raise a five-tile-radius square of temporary, destructible earthen walls around the caster."
	icon_state = "earth_spike"

	proc/createPerimeter(mob/caster, radius = 5, lifetime = 600)
		var/list/created_walls = list()
		var/turf/origin = caster ? caster.base_loc() : null
		if(!origin || radius < 1) return created_walls
		var/minimum_x = max(1, origin.x - radius)
		var/maximum_x = min(world.maxx, origin.x + radius)
		var/minimum_y = max(1, origin.y - radius)
		var/maximum_y = min(world.maxy, origin.y + radius)
		for(var/tile_x = minimum_x, tile_x <= maximum_x, tile_x++)
			for(var/tile_y = minimum_y, tile_y <= maximum_y, tile_y++)
				if(tile_x != minimum_x && tile_x != maximum_x && tile_y != minimum_y && tile_y != maximum_y) continue
				var/turf/tile = locate(tile_x, tile_y, origin.z)
				if(!tile || tile.density || locate(/obj/ArcaneEarthBarrier) in tile) continue
				var/obj/ArcaneEarthBarrier/barrier = new(tile)
				barrier.Builder = caster.key ? caster.key : "[caster]"
				barrier.Health = max(1000, caster.BP * 0.35)
				created_walls += barrier
				if(lifetime > 0) spawn(lifetime) if(barrier) del(barrier)
		return created_walls

	proc/cast(mob/caster)
		if(!caster || !caster.spendArcaneEssence(45, name, src, 120)) return FALSE
		createPerimeter(caster)
		caster.showArcaneCastVfx("#d4a46f", 50, "earth_spike", "land")
		return TRUE

	verb/Hotbar_use()
		set hidden = 1
		cast(usr)
	verb/Earth_Prison()
		set category = "Skills"
		cast(usr)

obj/ArcaneEarthBarrier
	name = "Earth Prison Wall"
	desc = "A temporary wall raised by an earth-prison spell."
	icon = 'src/Icons/Turfs/EarthTiles.dmi'
	density = 1
	Savable = 0
	Grabbable = 0
	takes_gradual_damage = 1

	New()
		. = ..()
		var/list/available_states = icon_states(icon)
		if(!icon_state && available_states.len && !("" in available_states)) icon_state = available_states[1]

obj/ArcaneSpell/EmpoweredAttacks
	name = "Empowered Attacks"
	desc = "Empower nearby allies, increasing damage by 10% for 30 seconds."
	icon_state = "fire_ball"

	proc/cast(mob/caster)
		if(!caster || !caster.spendArcaneEssence(40, name, src, 180)) return FALSE
		for(var/mob/ally in range(5, caster))
			if(!caster.isArcaneAlly(ally)) continue
			ally.arcane_attack_empowered_until = max(ally.arcane_attack_empowered_until, world.time + 300)
			ally << "<font color=#ffba66>Your attacks have been empowered for 30 seconds."
		caster.showArcaneCastVfx("#ff8d4a", 45, "fire_ball", "ability_ready")
		return TRUE

	verb/Hotbar_use()
		set hidden = 1
		cast(usr)
	verb/Empowered_Attacks()
		set category = "Skills"
		cast(usr)

obj/ArcaneSpell/EmpoweredDefenses
	name = "Empowered Defenses"
	desc = "Ward nearby allies, increasing effective Endurance and Resistance by 50% for 30 seconds."
	icon_state = "rocks"

	proc/cast(mob/caster)
		if(!caster || !caster.spendArcaneEssence(40, name, src, 180)) return FALSE
		for(var/mob/ally in range(5, caster))
			if(!caster.isArcaneAlly(ally)) continue
			ally.arcane_defense_stat_empowered_until = max(ally.arcane_defense_stat_empowered_until, world.time + 300)
			ally << "<font color=#89d5ff>Your defenses have been empowered for 30 seconds."
		caster.showArcaneCastVfx("#5aa8ff", 45, "rocks", "ability_ready")
		return TRUE

	verb/Hotbar_use()
		set hidden = 1
		cast(usr)
	verb/Empowered_Defenses()
		set category = "Skills"
		cast(usr)

obj/ArcaneSpell/Accelerate
	name = "Accelerate"
	desc = "Accelerate yourself or an adjacent ally for 30 seconds."
	icon_state = "wind"

	proc/cast(mob/caster)
		if(!caster || !caster.spendArcaneEssence(28, name, src, 120)) return FALSE
		var/list/targets = list(caster)
		for(var/mob/target in Get_step(caster, caster.dir)) if(target.client) targets += target
		var/mob/chosen = input(caster, "Accelerate whom?", name) as null|mob in targets
		if(!chosen) return FALSE
		chosen.arcane_accelerated_until = max(chosen.arcane_accelerated_until, world.time + 300)
		chosen << "<font color=#d7ffff>Time bends around you; your actions accelerate for 30 seconds."
		caster.showArcaneCastVfx("#d7ffff", 35, "wind", "ability_ready")
		return TRUE

	verb/Hotbar_use()
		set hidden = 1
		cast(usr)
	verb/Accelerate()
		set category = "Skills"
		cast(usr)

obj/ArcaneSpell/Rejuvenate
	name = "Rejuvenate"
	desc = "Restore an adjacent ally without sacrificing the caster's health."
	icon_state = "water"

	proc/cast(mob/caster)
		if(!caster) return FALSE
		var/mob/target
		for(var/mob/candidate in Get_step(caster, caster.dir))
			if(candidate.client)
				target = candidate
				break
		if(!target)
			caster << "Face an adjacent character to rejuvenate them."
			return FALSE
		if(!caster.spendArcaneEssence(30, name, src, 100)) return FALSE
		target.applyRegenerationHealth(25, drains_willpower = FALSE)
		target.Ki = min(target.max_ki, target.Ki + target.max_ki * 0.2)
		target.restoreWillpower(10, "Arcane rejuvenation restores your resolve.", announce = FALSE)
		caster.showArcaneCastVfx("#9cffb2", 35, "water", "ability_ready")
		player_view(12, caster) << "<font color=#9cffb2>[caster] rejuvenates [target]."
		return TRUE

	verb/Hotbar_use()
		set hidden = 1
		cast(usr)
	verb/Rejuvenate()
		set category = "Skills"
		cast(usr)

obj/ArcaneSpell/GravityWell
	name = "Gravity Well"
	desc = "Create a temporary pocket of increased gravity for training."
	icon_state = "portal"

	proc/cast(mob/caster)
		if(!caster) return FALSE
		var/maximum = max(2, min(50, caster.magic_level * 4))
		var/gravity = input(caster, "Choose gravity from 2x to [maximum]x.", name, 2) as null|num
		if(isnull(gravity)) return FALSE
		gravity = Clamp(round(gravity), 2, maximum)
		if(!caster.spendArcaneEssence(12 + gravity * 2, name, src, 300)) return FALSE
		var/obj/ArcaneGravityWell/well = new(caster.base_loc())
		well.gravity_level = gravity
		well.activate()
		caster.showArcaneCastVfx("#bf87ff", 50, "portal", "ability_release")
		return TRUE

	verb/Hotbar_use()
		set hidden = 1
		cast(usr)
	verb/Gravity_Well()
		set category = "Skills"
		cast(usr)

obj/ArcaneGravityWell
	name = "Gravity Well"
	desc = "A temporary magical gravity field."
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTMagicCircle.dmi'
	density = 0
	Savable = 0
	Grabbable = 0
	var/gravity_level = 2
	var/tmp/list/affected_turfs = list()
	var/tmp/active = FALSE

	proc/activate(lifetime = 6000)
		if(active) return
		active = TRUE
		desc = "A [gravity_level]x magical gravity field. It expires after ten minutes."
		for(var/turf/tile in view(2, src))
			affected_turfs += tile
			tile.arcane_gravity = max(tile.arcane_gravity, gravity_level)
			for(var/mob/target in tile) target.Gravity_Update()
		if(lifetime > 0) spawn(lifetime) if(src) del(src)

	Del()
		active = FALSE
		for(var/turf/tile in affected_turfs)
			tile.arcane_gravity = 0
			for(var/obj/ArcaneGravityWell/other_well in world)
				if(other_well != src && other_well.active && tile in other_well.affected_turfs)
					tile.arcane_gravity = max(tile.arcane_gravity, other_well.gravity_level)
			for(var/mob/target in tile) target.Gravity_Update()
		affected_turfs = null
		player_view(10, src) << "The Gravity Well collapses."
		. = ..()

obj/ArcaneSpell/CreatePortal
	name = "Create Portal"
	desc = "Bind a visited location as an anchor, then open a temporary two-way portal to it."
	icon_state = "portal"

	proc/cast(mob/caster)
		if(!caster || caster.Final_Realm() || caster.Prisoner() || caster.Teleport_nulled()) return FALSE
		var/choice = input(caster, "Manage your arcane portal anchor.", name) as null|anything in list("Cancel", "Bind current location", "Open portal to anchor")
		if(!choice || choice == "Cancel") return FALSE
		if(choice == "Bind current location")
			if(!caster.spendArcaneEssence(15, name, src, 30)) return FALSE
			caster.arcane_portal_anchor_x = caster.x
			caster.arcane_portal_anchor_y = caster.y
			caster.arcane_portal_anchor_z = caster.z
			caster << "This location is now bound as your arcane portal anchor."
			caster.showArcaneCastVfx()
			return TRUE
		if(!caster.arcane_portal_anchor_x || !caster.arcane_portal_anchor_y || !caster.arcane_portal_anchor_z)
			caster << "Bind an anchor before opening a portal."
			return FALSE
		var/turf/destination = locate(caster.arcane_portal_anchor_x, caster.arcane_portal_anchor_y, caster.arcane_portal_anchor_z)
		if(!destination || destination.density)
			caster << "The bound location is no longer safe."
			return FALSE
		if(!caster.spendArcaneEssence(80, name, src, 600)) return FALSE
		var/obj/ArcanePortal/entrance = new(caster.base_loc())
		var/obj/ArcanePortal/exit_portal = new(destination)
		entrance.partner = exit_portal
		exit_portal.partner = entrance
		entrance.Builder = caster.key
		exit_portal.Builder = caster.key
		spawn(NEXUS_ARCANE_PORTAL_LIFETIME)
			if(entrance) del(entrance)
			if(exit_portal) del(exit_portal)
		caster.showArcaneCastVfx("#7c62ff", 55)
		return TRUE

	verb/Hotbar_use()
		set hidden = 1
		cast(usr)
	verb/Create_Portal()
		set category = "Skills"
		cast(usr)

obj/ArcaneSpell/Enchant
	name = "Enchant"
	desc = "Spend Arcane Essence to permanently grant one Tenkaichi-forged item visible masterwork quality and improved combat statistics."
	icon_state = "molten_spear"

	proc/cast(mob/caster)
		if(!caster) return FALSE
		var/list/options = list()
		for(var/obj/items/Sword/Forged/weapon in caster.item_list)
			if(!weapon.master_blacksmith_quality) options += weapon
		for(var/obj/items/Armor/Forged/armor in caster.item_list)
			if(!armor.master_blacksmith_quality) options += armor
		for(var/obj/items/Gloves/Forged/gloves in caster.item_list)
			if(!gloves.master_blacksmith_quality) options += gloves
		for(var/obj/items/Mask/Forged/mask in caster.item_list)
			if(!mask.master_blacksmith_quality) options += mask
		if(!options.len)
			caster << "You carry no forged item that can receive this enchantment."
			return FALSE
		var/obj/items/choice = input(caster, "Enchant which forged item?", name) as null|obj in options
		if(!choice || choice.loc != caster) return FALSE
		if(!caster.spendArcaneEssence(120, name, src, 100)) return FALSE
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
		player_view(10, caster) << "Arcane runes settle permanently into [choice]."
		caster.showArcaneCastVfx("#ffd166", 45, "molten_spear", "ability_ready")
		return TRUE

	verb/Hotbar_use()
		set hidden = 1
		cast(usr)
	verb/Enchant_Item()
		set category = "Skills"
		cast(usr)

obj/ArcanePortal
	name = "Arcane Portal"
	desc = "A temporary two-way portal."
	icon = 'src/Icons/Effects/OpenCombat/FoozleMagic64.dmi'
	icon_state = "portal"
	density = 0
	Savable = 0
	Grabbable = 0
	var/tmp/obj/ArcanePortal/partner

	Crossed(atom/movable/traveler)
		. = ..()
		if(!partner || !traveler || !ismob(traveler)) return
		var/mob/character = traveler
		if(character.Teleport_nulled() || character.Final_Realm() || character.Prisoner()) return
		if(character.last_arcane_portal_use + 20 > world.time) return
		character.last_arcane_portal_use = world.time
		character.SafeTeleport(partner.loc)

mob/var/tmp/last_arcane_portal_use = 0

obj/items/Sword/Forged/ArcaneSword
	forged_material_id = "copper"
	forged_style_id = "flame"

obj/items/Sword/Forged/MagicHammer
	forged_material_id = "copper"
	forged_style_id = "hammer"

obj/items/Armor/Forged/ArcaneArmor
	forged_material_id = "copper"
	forged_style_id = "azure"

obj/items/ManaPylon
	name = "Mana Pylon"
	desc = "A stationary focus that increases nearby Arcane Essence gathering by 25%."
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTMagicCircle.dmi'
	icon_state = ""
	Cost = 0
	Savable = 1
	density = 1
	Grabbable = 1

obj/items/SpellBook
	name = "Spell Book"
	desc = "A grimoire that catalogs every spell and formula unlocked in the Magic progression tree."
	icon = 'src/Icons/PlayerIcons/Clothes/ClothesBook.dmi'
	Cost = 0
	Savable = 1

	verb/Study_Spellbook()
		set src in usr
		usr.showProgressionTrees("Magic")

obj/items/ArcaneFocusGauntlets
	name = "Magic Gauntlets"
	desc = "Enchanted gauntlets that increase Magic XP gains by 5% while carried."
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTEnchantmentItems.dmi'
	icon_state = "ArcanOrb"
	Cost = 0
	Savable = 1

obj/items/ArcaneBoxingGloves
	parent_type = /obj/items/Gloves/Forged
	forged_style_id = "boxing"
	Cost = 0
	Savable = 1

obj/items/ArcaneOrbOfMastery
	name = "Orb of Mastery"
	desc = "Carrying this orb increases Magic XP gains by 10%."
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTEnchantmentItems.dmi'
	icon_state = "PhiloStone"
	Cost = 0
	Savable = 1

obj/items/ArcaneSatchel
	name = "Utility Belt"
	desc = "A pocket-space container that can hold up to 20 items."
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTEnchantmentItems.dmi'
	icon_state = "ArcanOrb"
	Cost = 0
	Savable = 1
	var/capacity = 20

	proc/canStoreItem(mob/user, obj/items/item)
		return user && loc == user && item && item != src && item.loc == user

	proc/canRetrieveItem(mob/user, obj/items/item)
		return user && loc == user && item && item.loc == src

	verb/Store(obj/items/item in usr)
		set src in usr
		if(!canStoreItem(usr, item)) return
		var/item_count = 0
		for(var/obj/items/stored in src) item_count++
		if(item_count >= capacity)
			usr << "[src] is full."
			return
		item.Move(src)
		usr << "You store [item] in [src]."

	verb/Retrieve()
		set src in usr
		var/list/options = list()
		for(var/obj/items/stored in src) options += stored
		if(!options.len)
			usr << "[src] is empty."
			return
		var/obj/items/choice = input(usr, "Retrieve which item?", name) as null|obj in options
		if(!canRetrieveItem(usr, choice)) return
		choice.Move(usr)

	CookingBag
		name = "Cooking Bag"
		desc = "A 50-slot pocket-space bag adapted from the RPT cooking bag."
		capacity = 50

	Bookcase
		name = "Book Case"
		desc = "A portable enchanted book case with thirty storage slots."
		capacity = 30

obj/items/Simulator/ArcaneCrystal
	name = "Simulation Crystal"
	desc = "A crystal-bound version of the native simulator, adapted from Roleplay Tenkaichi."
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTEnchantmentItems.dmi'
	icon_state = "ArcanOrb"
	Cost = 0
	science = 0

obj/items/MagicVault
	name = "Magic Vault"
	desc = "A password-protected vault for storing Arcane Essence."
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTEnchantmentItems.dmi'
	icon_state = "PhiloStone"
	Cost = 0
	Savable = 1
	density = 1
	var/stored_essence = 0
	var/tmp/nexus_trade_prompt_pending
	var/tmp/mob/nexus_trade_prompt_user
	var/tmp/atom/nexus_trade_prompt_location
	var/tmp/nexus_trade_prompt_revision
	var/tmp/nexus_trade_location_revision

	Move()
		nexus_trade_location_revision++
		. = ..()

	proc/canAccessVault(mob/user)
		if(!user) return FALSE
		if(loc == user) return (src in user.item_list) && !isNexusTradeOfferedBy(user)
		return src in oview(1, user)

	proc/beginNexusVaultInteraction(mob/user, atom/original_location, original_revision)
		if(nexus_trade_prompt_pending || loc != original_location || nexus_trade_location_revision != original_revision || !canAccessVault(user)) return FALSE
		nexus_trade_prompt_pending = TRUE
		nexus_trade_prompt_user = user
		nexus_trade_prompt_location = original_location
		nexus_trade_prompt_revision = original_revision
		return TRUE

	proc/canContinueNexusVaultInteraction(mob/user, atom/original_location, original_revision)
		if(!nexus_trade_prompt_pending || nexus_trade_prompt_user != user) return FALSE
		if(nexus_trade_prompt_location != original_location || nexus_trade_prompt_revision != original_revision) return FALSE
		if(loc != original_location || nexus_trade_location_revision != original_revision) return FALSE
		return canAccessVault(user)

	proc/endNexusVaultInteraction(mob/user)
		if(nexus_trade_prompt_user && user != nexus_trade_prompt_user) return
		nexus_trade_prompt_pending = FALSE
		nexus_trade_prompt_user = null
		nexus_trade_prompt_location = null
		nexus_trade_prompt_revision = 0

	verb/Set_Password()
		set src in oview(1)
		if(Password)
			usr << "The password has already been set."
			return
		var/mob/user = usr
		var/atom/original_location = loc
		var/original_revision = nexus_trade_location_revision
		if(!beginNexusVaultInteraction(user, original_location, original_revision)) return
		var/new_password = input(user, "Set this vault's password.", name) as text
		if(!canContinueNexusVaultInteraction(user, original_location, original_revision) || Password)
			endNexusVaultInteraction(user)
			return
		Password = new_password
		endNexusVaultInteraction(user)

	proc/checkPassword(mob/user, atom/original_location, original_revision)
		if(!Password) return canContinueNexusVaultInteraction(user, original_location, original_revision)
		var/attempt = input(user, "Enter the vault password.", name) as text
		return canContinueNexusVaultInteraction(user, original_location, original_revision) && attempt == Password

	verb/Deposit()
		set src in oview(1)
		var/mob/user = usr
		var/atom/original_location = loc
		var/original_revision = nexus_trade_location_revision
		if(!beginNexusVaultInteraction(user, original_location, original_revision)) return
		if(!checkPassword(user, original_location, original_revision))
			endNexusVaultInteraction(user)
			return
		var/amount = input(user, "Deposit how much Arcane Essence?", name, 0) as num
		if(!canContinueNexusVaultInteraction(user, original_location, original_revision))
			endNexusVaultInteraction(user)
			return
		amount = Clamp(round(amount, 0.1), 0, user.arcane_essence)
		user.arcane_essence -= amount
		stored_essence += amount
		user << "The vault now contains [round(stored_essence, 0.1)] Arcane Essence."
		endNexusVaultInteraction(user)

	verb/Withdraw()
		set src in oview(1)
		var/mob/user = usr
		var/atom/original_location = loc
		var/original_revision = nexus_trade_location_revision
		if(!beginNexusVaultInteraction(user, original_location, original_revision)) return
		if(!checkPassword(user, original_location, original_revision))
			endNexusVaultInteraction(user)
			return
		var/amount = input(user, "Withdraw how much Arcane Essence?", name, 0) as num
		if(!canContinueNexusVaultInteraction(user, original_location, original_revision))
			endNexusVaultInteraction(user)
			return
		amount = Clamp(round(amount, 0.1), 0, stored_essence)
		stored_essence -= amount
		user.arcane_essence += amount
		user << "The vault now contains [round(stored_essence, 0.1)] Arcane Essence."
		endNexusVaultInteraction(user)

obj/items/ArcaneLocator
	name = "Locator"
	desc = "A divination compass that reveals the direction and distance of a character in the same realm."
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTEnchantmentItems.dmi'
	icon_state = "ArcanOrb"
	Cost = 0
	Savable = 1

	verb/Locate_Person()
		set src in usr
		var/list/options = list()
		for(var/mob/player in players) if(player.client && player != usr && player.z == usr.z && !player.invisibility) options += player
		var/mob/target = input(usr, "Locate whom in this realm?", name) as null|mob in options
		if(!target) return
		usr << "[target] is [getdist(usr, target)] tiles to the [arcaneDirectionText(get_dir(usr, target))]."

obj/items/MagicScanner
	name = "Magic Scanner"
	desc = "A divination lens that reads magical aptitude, essence and mutation signatures."
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTEnchantmentItems.dmi'
	icon_state = "ArcanEar"
	Cost = 0
	Savable = 1

	verb/Scan(mob/target in view(5, usr))
		set src in usr
		if(!target) return
		target.normalizeCharacterMutations()
		usr << "<b>[target]</b><br>Magic Level: [target.magic_level]<br>Magic potential: [round(target.getMagicPotential(), 0.01)]x<br>Arcane Essence: [round(target.arcane_essence, 0.1)]<br>Mutation rarity: [target.mutation_rarity ? target.mutation_rarity : "None"]"

obj/items/ArcaneDisguise
	name = "Disguise"
	desc = "A glamour veil that makes the bearer difficult to see for one minute. Combat breaks neither the timer nor the veil."
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTEnchantmentItems.dmi'
	icon_state = "ArcanEar"
	Cost = 0
	Savable = 1
	var/tmp/active = FALSE

	verb/Use()
		set src in usr
		if(active) return
		var/mob/user = usr
		var/old_invisibility = user.invisibility
		active = TRUE
		user.invisibility = max(user.invisibility, 1)
		var/applied_invisibility = user.invisibility
		player_view(10, user) << "A glamour settles over [user]."
		spawn(600)
			if(user && user.invisibility == applied_invisibility) user.invisibility = old_invisibility
			if(src) active = FALSE

obj/items/MagicFishingLure
	name = "Magic Fishing Lure"
	desc = "Consume beside water to draw ambient magic and aquatic life to the surface."
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTEnchantmentItems.dmi'
	icon_state = "Witheroot"
	Cost = 0
	Savable = 1

	verb/Use()
		set src in usr
		var/near_water = FALSE
		for(var/turf/tile in range(2, usr)) if(tile.Water)
			near_water = TRUE
			break
		if(!near_water)
			usr << "The lure only responds near water."
			return
		usr.gainArcaneEssence(20, "an enchanted catch", announce = TRUE)
		usr.gainMagicExperience(10, "using a magic fishing lure", announce = TRUE)
		player_view(10, usr) << "The water churns as [usr]'s magic lure flashes."
		del(src)

obj/items/EnchantedDoll
	name = "Enchanted Doll"
	desc = "Awaken this construct as a temporary arcane companion."
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTEnchantmentItems.dmi'
	icon_state = "ArcanOrb"
	Cost = 0
	Savable = 1

	verb/Awaken()
		set src in usr
		var/mob/user = usr
		if(!canUseAfterNexusTradeYield(user)) return
		var/doll_name = input(user, "Name the enchanted doll.", name, "Arcane Doll") as text
		if(!canUseAfterNexusTradeYield(user)) return
		var/mob/ArcaneDoll/doll = new(user.base_loc())
		doll.owner = user
		doll.name = doll_name
		doll.BP = max(1, user.BP * 0.2)
		player_view(10, user) << "[user] awakens [doll] from an enchanted shell."
		del(src)

mob/ArcaneDoll
	name = "Arcane Doll"
	icon = 'src/Icons/PlayerIcons/BaseIcons/Androids/BioExperiment.dmi'
	Savable = 0
	var/tmp/mob/owner

	New()
		. = ..()
		spawn followOwner()
		spawn(36000) if(src) del(src)

	proc/followOwner()
		while(src && owner)
			if(owner.z == z && getdist(src, owner) > 2) step_towards(src, owner)
			sleep(8)

obj/items/ArcaneUpgradeKit
	name = "Upgrade Kit"
	desc = "Apply masterwork arcane quality to one Tenkaichi-forged weapon, pair of gloves, mask, or armor."
	icon = 'src/Icons/Objects/Technology/Lab.dmi'
	icon_state = "Tool2"
	Cost = 0
	Savable = 1

	verb/Upgrade()
		set src in usr
		var/mob/user = usr
		if(!canUseAfterNexusTradeYield(user)) return
		var/list/options = list()
		for(var/obj/items/Sword/Forged/weapon in user.item_list) options += weapon
		for(var/obj/items/Armor/Forged/armor in user.item_list) options += armor
		for(var/obj/items/Gloves/Forged/gloves in user.item_list) options += gloves
		for(var/obj/items/Mask/Forged/mask in user.item_list) options += mask
		var/obj/items/choice = input(user, "Upgrade which forged item?", name) as null|obj in options
		if(!choice || !canUseAfterNexusTradeYield(user) || !(choice in options) || choice.loc != user || !(choice in user.item_list)) return
		if(istype(choice, /obj/items/Sword/Forged))
			var/obj/items/Sword/Forged/weapon = choice
			if(weapon.master_blacksmith_quality)
				user << "[weapon] already has masterwork quality."
				return
			weapon.master_blacksmith_quality = TRUE
			weapon.refreshForgedWeapon()
		else if(istype(choice, /obj/items/Armor/Forged))
			var/obj/items/Armor/Forged/armor = choice
			if(armor.master_blacksmith_quality)
				user << "[armor] already has masterwork quality."
				return
			armor.master_blacksmith_quality = TRUE
			armor.refreshForgedArmor()
		else if(istype(choice, /obj/items/Gloves/Forged))
			var/obj/items/Gloves/Forged/gloves = choice
			if(gloves.master_blacksmith_quality)
				user << "[gloves] already has masterwork quality."
				return
			gloves.master_blacksmith_quality = TRUE
			gloves.refreshForgedGloves()
		else
			var/obj/items/Mask/Forged/mask = choice
			if(mask.master_blacksmith_quality)
				user << "[mask] already has masterwork quality."
				return
			mask.master_blacksmith_quality = TRUE
			mask.refreshForgedMask()
		player_view(10, user) << "Arcane runes settle into [choice]."
		del(src)

obj/items/CrystalBall
	name = "Crystal Ball"
	desc = "Observe a visible character in the same realm for ten seconds."
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTEnchantmentItems.dmi'
	icon_state = "ArcanOrb"
	Cost = 0
	Savable = 1

	verb/Scry()
		set src in usr
		var/mob/user = usr
		if(!user.client) return
		var/list/options = list()
		for(var/mob/player in players) if(player.client && player.z == user.z && !player.invisibility) options += player
		var/mob/target = input(user, "Scry whom in this realm?", name) as null|mob in options
		if(!target || !canUseAfterNexusTradeYield(user) || !(target in options) || !target.client || target.z != user.z || target.invisibility) return
		user.client.eye = target
		user << "Your sight enters the crystal ball for ten seconds."
		spawn(100) if(user && user.client && user.client.eye == target) user.client.eye = user

obj/items/ArcaneElixir
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTEnchantmentItems.dmi'
	Cost = 0
	Savable = 1
	var/effect_id

	proc/applyEffect(mob/user)
		return FALSE

	verb/Drink()
		set src in usr
		var/mob/user = usr
		if(!canUseAfterNexusTradeYield(user)) return
		if(applyEffect(user) && canUseAfterNexusTradeYield(user)) del(src)

	Health
		name = "Elixir of Health"
		desc = "Triples natural regeneration for five minutes."
		effect_id = "elixir_health"
		applyEffect(mob/user)
			user.arcane_regeneration_until = max(user.arcane_regeneration_until, world.time + 3000)
			user << "Regenerative magic courses through your body."
			return TRUE

	Replenishment
		name = "Elixir of Replenishment"
		desc = "Doubles natural energy recovery for five minutes."
		effect_id = "elixir_replenishment"
		applyEffect(mob/user)
			user.arcane_replenishment_until = max(user.arcane_replenishment_until, world.time + 3000)
			return TRUE

	Merriment
		name = "Elixir of Merriment"
		desc = "Increases Progression XP earned from roleplay and chat by 25% for ten minutes."
		effect_id = "elixir_merriment"
		applyEffect(mob/user)
			user.arcane_merriment_until = max(user.arcane_merriment_until, world.time + 6000)
			return TRUE

	Life
		name = "Elixir of Life"
		desc = "Permanently extends the drinker's decline age by 25 years. One effective dose per character."
		effect_id = "elixir_life"
		applyEffect(mob/user)
			if(!user.addArcanePermanentEffect(effect_id))
				user << "A second Elixir of Life would have no effect."
				return FALSE
			user.Decline += 25
			return TRUE

	Empowerment
		name = "Elixir of Empowerment"
		desc = "Fully restores the drinker and grants 400 Progression XP. One effective dose per character."
		effect_id = "elixir_empowerment"
		applyEffect(mob/user)
			if(!user.addArcanePermanentEffect(effect_id))
				user << "A second Elixir of Empowerment would have no effect."
				return FALSE
			user.FullHeal()
			user.gainProgressionExperience(getScaledProgressionExperience(40), name, announce = TRUE)
			return TRUE

	Reformation
		name = "Elixir of Reformation"
		desc = "Clear character mutations and reopen the native stat-allocation process. One effective dose per character."
		effect_id = "elixir_reformation"
		applyEffect(mob/user)
			if(user.hasArcanePermanentEffect(effect_id))
				user << "A second Elixir of Reformation would have no effect."
				return FALSE
			if(alert(user, "This clears every mutation and begins the stat-redo process. Continue?", name, "Cancel", "Reform") != "Reform") return FALSE
			if(!canUseAfterNexusTradeYield(user) || user.hasArcanePermanentEffect(effect_id)) return FALSE
			user.addArcanePermanentEffect(effect_id)
			user.clearCharacterMutations()
			spawn(1) if(user) user.Redo_Stats(user)
			return TRUE

obj/items/ArcaneBook
	icon = 'src/Icons/PlayerIcons/Clothes/ClothesBook.dmi'
	Cost = 0
	Savable = 1
	var/effect_id

	proc/applyEffect(mob/user)
		return FALSE

	verb/Read_Arcane_Book()
		set src in usr
		if(applyEffect(usr)) del(src)

	Ages
		name = "Book of Ages"
		desc = "Age five years and gain one Milestone Point. One effective reading per character."
		effect_id = "book_ages"
		applyEffect(mob/user)
			if(!user.addArcanePermanentEffect(effect_id)) return FALSE
			user.Age += 5
			user.milestone_points++
			user.total_milestone_points++
			return TRUE

	Fortitude
		name = "Book of Fortitude"
		desc = "Reduces damage taken by 15% for ten minutes. One effective reading per character."
		effect_id = "book_fortitude"
		applyEffect(mob/user)
			if(!user.addArcanePermanentEffect(effect_id)) return FALSE
			user.arcane_defense_empowered_until = max(user.arcane_defense_empowered_until, world.time + 6000)
			return TRUE

	Lessons
		name = "Book of Lessons"
		desc = "Grants 750 Progression XP from the recorded lessons of the past. One effective reading per character."
		effect_id = "book_lessons"
		applyEffect(mob/user)
			if(!user.addArcanePermanentEffect(effect_id)) return FALSE
			user.gainProgressionExperience(getScaledProgressionExperience(75), name, announce = TRUE)
			return TRUE

	Power
		name = "Book of Power"
		desc = "Permanently increases BP growth by 5% and current base BP by 10%. One effective reading per character."
		effect_id = "book_power"
		applyEffect(mob/user)
			if(!user.addArcanePermanentEffect(effect_id)) return FALSE
			user.bp_mod *= 1.05
			user.base_bp *= 1.1
			return TRUE

obj/Turfs/Door/ArcaneDoor
	name = "Magic Door"
	desc = "A magically secured door created through Arcane Crafting."
	Cost = 0
	Savable = 1

	New()
		. = ..()
		spawn(1) if(src && !Password) Password = "arcane-[rand(1000, 9999)]"

#undef NEXUS_ARCANE_PORTAL_LIFETIME
#undef NEXUS_ARCANE_DEFENSE_MULTIPLIER
