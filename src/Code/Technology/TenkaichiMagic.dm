#define NEXUS_ARCANE_PORTAL_LIFETIME 6000

mob/var
	list/arcane_permanent_effects = list()
	tmp/arcane_attack_empowered_until = 0
	tmp/arcane_defense_empowered_until = 0
	tmp/arcane_accelerated_until = 0
	tmp/arcane_regeneration_until = 0
	tmp/arcane_replenishment_until = 0
	tmp/arcane_merriment_until = 0
	arcane_portal_anchor_x = 0
	arcane_portal_anchor_y = 0
	arcane_portal_anchor_z = 0

obj/var/tmp/next_arcane_use = 0

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

mob/proc/showArcaneCastVfx(color = "#b875ff", sound_volume = 35)
	player_view(12, src) << "<font color=[color]>Arcane sigils flare around [src]."
	Play_Melee_Sound(sound_range = 12, origin = src, sound_file = 'src/Sound/SoundEffects/Combat/Kiplosion.ogg', sound_volume = sound_volume)
	Make_Shockwave(src, sw_icon_size = 64)

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
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTEnchantmentItems.dmi'

obj/ArcaneSpell/Projectile
	var
		essence_cost = 10
		cooldown = 20
		damage_percent = 0.55
		explosion_size = 0
		projectile_speed = 48
		projectile_distance = 48
		projectile_stun = 0

	proc/cast(mob/caster)
		if(!caster || caster.cant_blast()) return FALSE
		if(!caster.spendArcaneEssence(essence_cost, name, src, cooldown)) return FALSE
		var/obj/Blast/projectile = get_cached_blast()
		projectile.setStats(caster, Percent = damage_percent, Off_Mult = 1.15, Explosion = explosion_size, explosion_percent = explosion_size ? damage_percent * 0.7 : 0)
		projectile.from_attack = src
		projectile.icon = icon
		projectile.Stun = projectile_stun
		projectile.Shockwave = explosion_size ? 1.5 : 0.5
		projectile.dir = caster.dir
		projectile.SafeTeleport(caster.loc)
		projectile.step_x = caster.step_x
		projectile.step_y = caster.step_y
		projectile.BlastAutoTargetGo(boundWidth = 20, boundHeight = 20, vectorSpeed = projectile_speed, angleLimit = 30, dist = projectile_distance, randomAngle = 1)
		caster.showArcaneCastVfx()
		return TRUE

	verb/Hotbar_use()
		set hidden = 1
		cast(usr)

	Fireball
		name = "Fireball"
		desc = "Launch a homing sphere of arcane fire that erupts on impact."
		icon = 'src/Icons/Ki/Big/BlastFire.dmi'
		essence_cost = 18
		cooldown = 24
		damage_percent = 0.72
		explosion_size = 1
		verb/Fireball()
			set category = "Skills"
			cast(usr)

	FrostBolt
		name = "Frost Bolt"
		desc = "Launch a precise freezing bolt that briefly stuns its target."
		icon = 'src/Icons/Ki/Blasts/BlastDualFireBlast.dmi'
		essence_cost = 15
		cooldown = 20
		damage_percent = 0.55
		projectile_stun = 1
		projectile_speed = 54
		verb/Frost_Bolt()
			set category = "Skills"
			cast(usr)

	LightningBolt
		name = "Lightning Bolt"
		desc = "Condense Arcane Essence into a fast, stunning lightning strike."
		icon = 'src/Icons/Ki/Electricity/Lightning.dmi'
		essence_cost = 20
		cooldown = 32
		damage_percent = 0.68
		projectile_stun = 1
		projectile_speed = 64
		projectile_distance = 36
		verb/Lightning_Bolt()
			set category = "Skills"
			cast(usr)

obj/ArcaneSpell/FrostNova
	name = "Frost Nova"
	desc = "Release a freezing pulse that damages and slows nearby enemies."

	proc/cast(mob/caster)
		if(!caster || !caster.spendArcaneEssence(35, name, src, 70)) return FALSE
		caster.showArcaneCastVfx("#8ee9ff", 45)
		for(var/mob/target in range(2, caster))
			if(target == caster || target.KO || !target.client) continue
			var/damage = Clamp(7 * (caster.BP / max(target.BP, 1)) ** 0.35, 2, 16)
			target.TakeDamage(damage, attacker = caster, attack_name = name)
			target.ApplyStun(time = 8, stun_power = 1.5)
		return TRUE

	verb/Hotbar_use()
		set hidden = 1
		cast(usr)
	verb/Frost_Nova()
		set category = "Skills"
		cast(usr)

obj/ArcaneSpell/EarthPrison
	name = "Earth Prison"
	desc = "Raise a temporary square of destructible stone around the caster."

	proc/cast(mob/caster)
		if(!caster || !caster.spendArcaneEssence(45, name, src, 120)) return FALSE
		var/radius = 4
		for(var/turf/tile in range(radius, caster))
			if(max(abs(tile.x - caster.x), abs(tile.y - caster.y)) != radius) continue
			if(tile.density || locate(/obj/ArcaneEarthBarrier) in tile) continue
			var/obj/ArcaneEarthBarrier/barrier = new(tile)
			barrier.Builder = caster.key
			barrier.Health = max(1000, caster.BP * 0.35)
			spawn(600) if(barrier) del(barrier)
		caster.showArcaneCastVfx("#d4a46f", 50)
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

obj/ArcaneSpell/EmpoweredAttacks
	name = "Empowered Attacks"
	desc = "Empower nearby allies, increasing damage by 10% for 30 seconds."

	proc/cast(mob/caster)
		if(!caster || !caster.spendArcaneEssence(40, name, src, 180)) return FALSE
		for(var/mob/ally in range(5, caster))
			if(!ally.client) continue
			ally.arcane_attack_empowered_until = max(ally.arcane_attack_empowered_until, world.time + 300)
			ally << "<font color=#ffba66>Your attacks have been empowered for 30 seconds."
		caster.showArcaneCastVfx("#ff8d4a", 45)
		return TRUE

	verb/Hotbar_use()
		set hidden = 1
		cast(usr)
	verb/Empowered_Attacks()
		set category = "Skills"
		cast(usr)

obj/ArcaneSpell/EmpoweredDefenses
	name = "Empowered Defenses"
	desc = "Ward nearby allies, reducing damage taken by 15% for 30 seconds."

	proc/cast(mob/caster)
		if(!caster || !caster.spendArcaneEssence(40, name, src, 180)) return FALSE
		for(var/mob/ally in range(5, caster))
			if(!ally.client) continue
			ally.arcane_defense_empowered_until = max(ally.arcane_defense_empowered_until, world.time + 300)
			ally << "<font color=#89d5ff>Your defenses have been empowered for 30 seconds."
		caster.showArcaneCastVfx("#5aa8ff", 45)
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

	proc/cast(mob/caster)
		if(!caster || !caster.spendArcaneEssence(28, name, src, 120)) return FALSE
		var/list/targets = list(caster)
		for(var/mob/target in Get_step(caster, caster.dir)) if(target.client) targets += target
		var/mob/chosen = input(caster, "Accelerate whom?", name) as null|mob in targets
		if(!chosen) return FALSE
		chosen.arcane_accelerated_until = max(chosen.arcane_accelerated_until, world.time + 300)
		chosen << "<font color=#d7ffff>Time bends around you; your actions accelerate for 30 seconds."
		caster.showArcaneCastVfx("#d7ffff", 35)
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
		caster.showArcaneCastVfx("#9cffb2", 35)
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
		caster.showArcaneCastVfx("#bf87ff", 50)
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

	proc/activate()
		desc = "A [gravity_level]x magical gravity field. It expires after ten minutes."
		pulseGravity()
		spawn(6000) if(src) del(src)

	proc/pulseGravity()
		set waitfor = 0
		while(src)
			for(var/mob/target in range(2, src))
				target.Gravity = max(target.Gravity, gravity_level)
			sleep(10)

	Del()
		for(var/mob/target in range(2, src)) target.Gravity_Update()
		player_view(10, src) << "The Gravity Well collapses."
		. = ..()

obj/ArcaneSpell/CreatePortal
	name = "Create Portal"
	desc = "Bind a visited location as an anchor, then open a temporary two-way portal to it."

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
	desc = "Spend Arcane Essence to imbue one Tenkaichi-forged item with masterwork quality."

	proc/cast(mob/caster)
		if(!caster) return FALSE
		var/list/options = list()
		for(var/obj/items/Sword/Forged/weapon in caster.item_list)
			if(!weapon.master_blacksmith_quality) options += weapon
		for(var/obj/items/Armor/Forged/armor in caster.item_list)
			if(!armor.master_blacksmith_quality) options += armor
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
		else
			var/obj/items/Armor/Forged/armor = choice
			armor.master_blacksmith_quality = TRUE
			armor.refreshForgedArmor()
		player_view(10, caster) << "Arcane runes settle permanently into [choice]."
		caster.showArcaneCastVfx("#ffd166", 45)
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
	icon = 'src/Icons/Effects/Portal.dmi'
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
	name = "Boxing Gloves"
	desc = "Padded enchanted gloves intended for controlled sparring and training."
	icon = 'src/Icons/RoleplayTenkaichi/Magic/RTEnchantmentItems.dmi'
	icon_state = "RoS"
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

	verb/Store(obj/items/item in usr)
		set src in usr
		if(item == src) return
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
		if(choice) choice.Move(usr)

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

	verb/Set_Password()
		set src in oview(1)
		if(Password)
			usr << "The password has already been set."
			return
		Password = input(usr, "Set this vault's password.", name) as text

	proc/checkPassword(mob/user)
		if(!Password) return TRUE
		var/attempt = input(user, "Enter the vault password.", name) as text
		return attempt == Password

	verb/Deposit()
		set src in oview(1)
		if(!checkPassword(usr)) return
		var/amount = input(usr, "Deposit how much Arcane Essence?", name, 0) as num
		amount = Clamp(round(amount, 0.1), 0, usr.arcane_essence)
		usr.arcane_essence -= amount
		stored_essence += amount
		usr << "The vault now contains [round(stored_essence, 0.1)] Arcane Essence."

	verb/Withdraw()
		set src in oview(1)
		if(!checkPassword(usr)) return
		var/amount = input(usr, "Withdraw how much Arcane Essence?", name, 0) as num
		amount = Clamp(round(amount, 0.1), 0, stored_essence)
		stored_essence -= amount
		usr.arcane_essence += amount
		usr << "The vault now contains [round(stored_essence, 0.1)] Arcane Essence."

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
		var/mob/ArcaneDoll/doll = new(usr.base_loc())
		doll.owner = usr
		doll.name = input(usr, "Name the enchanted doll.", name, "Arcane Doll") as text
		doll.BP = max(1, usr.BP * 0.2)
		player_view(10, usr) << "[usr] awakens [doll] from an enchanted shell."
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
	desc = "Apply masterwork arcane quality to one Tenkaichi-forged weapon or armor."
	icon = 'src/Icons/Objects/Technology/Lab.dmi'
	icon_state = "Tool2"
	Cost = 0
	Savable = 1

	verb/Upgrade()
		set src in usr
		var/list/options = list()
		for(var/obj/items/Sword/Forged/weapon in usr.item_list) options += weapon
		for(var/obj/items/Armor/Forged/armor in usr.item_list) options += armor
		var/obj/items/choice = input(usr, "Upgrade which forged item?", name) as null|obj in options
		if(!choice) return
		if(istype(choice, /obj/items/Sword/Forged))
			var/obj/items/Sword/Forged/weapon = choice
			if(weapon.master_blacksmith_quality)
				usr << "[weapon] already has masterwork quality."
				return
			weapon.master_blacksmith_quality = TRUE
			weapon.refreshForgedWeapon()
		else
			var/obj/items/Armor/Forged/armor = choice
			if(armor.master_blacksmith_quality)
				usr << "[armor] already has masterwork quality."
				return
			armor.master_blacksmith_quality = TRUE
			armor.refreshForgedArmor()
		player_view(10, usr) << "Arcane runes settle into [choice]."
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
		if(!target) return
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
		if(applyEffect(usr)) del(src)

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
		desc = "Fully restores the drinker and grants 40 Progression XP. One effective dose per character."
		effect_id = "elixir_empowerment"
		applyEffect(mob/user)
			if(!user.addArcanePermanentEffect(effect_id))
				user << "A second Elixir of Empowerment would have no effect."
				return FALSE
			user.FullHeal()
			user.gainProgressionExperience(40, name, announce = TRUE)
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
		desc = "Grants 75 Progression XP from the recorded lessons of the past. One effective reading per character."
		effect_id = "book_lessons"
		applyEffect(mob/user)
			if(!user.addArcanePermanentEffect(effect_id)) return FALSE
			user.gainProgressionExperience(75, name, announce = TRUE)
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
