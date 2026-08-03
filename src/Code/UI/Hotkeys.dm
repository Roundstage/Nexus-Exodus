mob/proc/LoadCharacterHotkeyThing()
	set waitfor=0
	sleep(10)
	if(Has_hotkey_server_backup())
		Restore_hotbar_from_IDs() //this automatically loads their hotkey backup if it hasnt been loaded already
	else
		Generate_starter_hotbar()
	initializeNexusHotkeys()

	//original - restore if any problems
	/*Generate_starter_hotbar()
	sleep(20)
	Restore_hotbar_from_IDs()*/

mob/proc
	Has_hotkey_server_backup()
		if(!client) return
		if(fexists("data/HotkeyBackups/[ckey]")) return 1

	Hotkey_server_backup_load()
		if(!client || !fexists("data/HotkeyBackups/[ckey]"))
			src<<"ERROR: Hotkey backup NOT FOUND"
			return
		var/savefile/f=new("data/HotkeyBackups/[ckey]")
		f["hotbar_ids"] >> hotbar_ids
		f["nexus_hotkey_bindings"] >> nexus_hotkey_bindings
		f["nexus_hotkey_version"] >> nexus_hotkey_version
		if("nexus_keyboard_layout" in f) f["nexus_keyboard_layout"] >> nexus_keyboard_layout
		nexus_keyboard_layout = normalizeNexusKeyboardLayout(nexus_keyboard_layout)

	Hotkey_server_backup_save()
		if(!client) return
		if(client.connection != "seeker") return //i think web connections and such are corrupting their hotkey file and erasing their hotkeys
		var/savefile/f = new("data/HotkeyBackups/[ckey]")
		f["hotbar_ids"] << hotbar_ids
		f["nexus_hotkey_bindings"] << nexus_hotkey_bindings
		f["nexus_hotkey_version"] << nexus_hotkey_version
		f["nexus_keyboard_layout"] << normalizeNexusKeyboardLayout(nexus_keyboard_layout)

obj/var/tmp
	is_for_moving
	move_macro_dir

mob/var/hotbar_proxies_added

var/list/global_hotbar_proxies

mob/proc/Add_hotbar_proxies()
	/*if(hotbar_proxies_added == 7) return //already added
	contents.Add(new/obj/Build_Menu,new/obj/Manual_Attack,new/obj/Train,new/obj/Meditate,new/obj/Power_Up,new/obj/Power_Down,new/obj/Grab,\
	new/obj/Local_chat,new/obj/World_chat,new/obj/Emote,new/obj/Countdown,new/obj/Learn,new/obj/Teach,new/obj/Injure,\
	new/obj/Lethal_toggle,new/obj/Dig_for_resources,new/obj/Use_object,new/obj/Play_Music,new/obj/Block,new/obj/Evade,new/obj/Flash_Step, \
	new/obj/Move_Left, new/obj/Move_Right, new/obj/Move_Up, new/obj/Move_Down, new/obj/Defend)
	hotbar_proxies_added = 7*/

	if(!global_hotbar_proxies)
		global_hotbar_proxies = list(new/obj/Build_Menu,new/obj/Manual_Attack,new/obj/Lunge,new/obj/Train,new/obj/Meditate,new/obj/Power_Up,new/obj/Power_Down,new/obj/Grab,\
		new/obj/Local_chat,new/obj/World_chat,new/obj/Emote,new/obj/Countdown,new/obj/Learn,new/obj/Teach,new/obj/Injure,\
		new/obj/Lethal_toggle,new/obj/Dig_for_resources,new/obj/Use_object,new/obj/Play_Music,new/obj/Block,new/obj/Evade,new/obj/Flash_Step, \
		new/obj/Move_Left, new/obj/Move_Right, new/obj/Move_Up, new/obj/Move_Down, new/obj/Defend, new/obj/Dice_Roll, new/obj/Local_World_chat, new/obj/Think)
	for(var/obj/o in global_hotbar_proxies)
		if(!(locate(o.type) in src))
			contents += new o.type
	hotbar_proxies_added = 7

obj/Use_object
	hotbar_type="Other"
	can_hotbar=1

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		if(!usr || !usr.client) return
		var/list/usables = new
		if(isobj(usr.loc))
			var/obj/o=usr.loc
			if(text2path("[o.type]/verb/Use") in o.verbs)
				usables+=o
		for(var/obj/o in view(1,usr))
			if(text2path("[o.type]/verb/Use") in o.verbs)
				usables+=o
		for(var/obj/o in usr.item_list)
			if(text2path("[o.type]/verb/Use") in o.verbs)
				usables+=o
		var/obj/o=input("Which object do you want to use?") in usables as obj|null
		if(!o || o == "Cancel" || !isobj(o)) return
		o:Use()

mob/proc/Defend()
	src << "This doesnt do anything yet"

obj/Defend
	can_hotbar=1
	hotbar_type="Defensive"
	repeat_macro=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.Defend()

obj/Move_Left
	can_hotbar=1
	hotbar_type="Other"
	repeat_macro=0
	is_for_moving = 1
	move_macro_dir = "west"
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.KeyDown(move_macro_dir)

obj/Move_Right
	can_hotbar=1
	hotbar_type="Other"
	repeat_macro=0
	is_for_moving = 1
	move_macro_dir = "east"
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.KeyDown(move_macro_dir)

obj/Move_Up
	can_hotbar=1
	hotbar_type="Other"
	repeat_macro=0
	is_for_moving = 1
	move_macro_dir = "north"
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.KeyDown(move_macro_dir)

obj/Move_Down
	can_hotbar=1
	hotbar_type="Other"
	repeat_macro=0
	is_for_moving = 1
	move_macro_dir = "south"
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.KeyDown(move_macro_dir)

obj/Build_Menu
	can_hotbar=1
	hotbar_type="Other"
	repeat_macro=0
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.ToggleBuildMenu()

obj/Dice_Roll
	can_hotbar=1
	hotbar_type="Other"
	repeat_macro=0
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.Dice_Roll()

mob/verb/Dice_Roll()
	set category = "Other"
	player_view(20,src) << "<font color=cyan>[src] rolled a [rand(1,20)]"

obj/Flash_Step
	can_hotbar=1
	hotbar_type="Ability"
	repeat_macro=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.Flash_Step()

obj/Block
	can_hotbar=0 //BECAUSE NEW COMBAT OFF NOW
	hotbar_type="Defensive"
	repeat_macro=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		//usr.Block()

obj/Evade
	can_hotbar=0
	hotbar_type="Defensive"
	repeat_macro=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		//usr.Evade()

obj/Play_Music
	hotbar_type="Other"
	can_hotbar=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.Play_Music()

obj/Injure
	hotbar_type="Melee"
	can_hotbar=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.Injure()

obj/Lethal_toggle
	hotbar_type="Other"
	can_hotbar=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.Ki_Toggle()

obj/Dig_for_resources
	hotbar_type="Other"
	can_hotbar=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.Dig_for_Resources()

obj/Local_chat
	hotbar_type="Other"
	can_hotbar=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.Say()

obj/World_chat
	hotbar_type="Other"
	can_hotbar=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.OOC()

obj/Local_World_chat
	hotbar_type="Other"
	can_hotbar=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.LOOC()

obj/Think
	hotbar_type="Other"
	can_hotbar=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.Think()

obj/Emote
	hotbar_type="Other"
	can_hotbar=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.Emote()

obj/Countdown
	hotbar_type="Other"
	can_hotbar=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.Countdown()

obj/Learn
	hotbar_type="Ability"
	can_hotbar=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.Learn()

obj/Teach
	hotbar_type="Ability"
	can_hotbar=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.Teach()

obj/Grab
	hotbar_type="Melee"
	can_hotbar=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.Grab()

obj/Manual_Attack
	hotbar_type="Melee"
	can_hotbar=1
	repeat_macro=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.Melee()

obj/Lunge
	can_hotbar=1
	hotbar_type="Melee"
	repeat_macro=0

	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.LungeAttack()

	verb/lunge()
		set name="Lunge"
		set category="Skills"
		usr.LungeAttack()

obj/Train
	hotbar_type="Training method"
	can_hotbar=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.Train()

obj/Meditate
	hotbar_type="Training method"
	can_hotbar=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		usr.Meditate()

obj/Power_Up
	hotbar_type="Buff"
	can_hotbar=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		if(!usr.powerup_obj)
			usr<<"You have not yet learned this ability"
			return
		usr.Power_up()

obj/Power_Down
	hotbar_type="Buff"
	can_hotbar=1
	verb/Hotbar_use()
		set waitfor=0
		set hidden=1
		if(!usr.powerup_obj)
			usr<<"You have not yet learned this ability"
			return
		usr.powerup_obj.Power_Down()

//client/control_freak=CONTROL_FREAK_MACROS

obj/Attacks
	hotbar_type="Blast"
	can_hotbar=1

obj/items
	hotbar_type="Item"
	can_hotbar=1

obj/var
	can_hotbar
	hotbar_type="Melee"
	hotbar_id //used for saving and restoring the hotbar from a savefile and re-assigning appropriate objects by ID

mob/var/tmp/list
	hotbar=new //every object the player has on the hot bar
	hotbar_ids=new //a savable list of IDs which can be used to restore the hotbar upon loading

var/list/hotbar_types=list("Melee","Blast","Beam","Buff","Defensive","Support","Ability","Transformation",\
"Combat item","Training method","Item","Other","Empty")

var/list/hotbar_type_icons

mob/proc/Get_hotbar_obj_by_key_pressed(kp)
	//if(key=="Tens of DU") src<<"Get_hotbar_obj_by_key_pressed"
	var/index = keys.Find(kp)
	if(!index) return
	if(hotbar.len<index) return
	var/obj/o=hotbar[index]
	return o

mob/proc/Get_hotbar_ability_key(obj/o)
	//if(key=="Tens of DU") src<<"Get_hotbar_ability_key"
	if(active_nexus_hotkey_actions)
		for(var/held_key in active_nexus_hotkey_actions)
			if(active_nexus_hotkey_actions[held_key] == o) return held_key
	var/index = hotbar.Find(o)
	if(!index) return
	if(keys.len<index) return
	return keys[index]

proc/Get_hotbar_type_icon(t)
	if(!hotbar_type_icons) Generate_hotbar_type_icons()
	for(var/obj/o in hotbar_type_icons) if(o.name==t) return o

obj/hotbar_type_icon

proc/Generate_hotbar_type_icons()
	hotbar_type_icons=new/list
	for(var/t in hotbar_types)
		var/obj/hotbar_type_icon/o=new
		o.name=t
		switch(t)
			if("Empty") o.icon='EmptyHotbarIcon.dmi'
			if("Melee") o.icon='Melee.jpg'
			if("Blast") o.icon='Blast.jpg'
			if("Beam") o.icon='Beam.jpg'
			if("Buff") o.icon='Buff.jpg'
			if("Defensive") o.icon='Defensive.jpg'
			if("Support") o.icon='Support.jpg'
			if("Other") o.icon='Other.jpg'
			if("Ability") o.icon='Ability.jpg'
			if("Transformation") o.icon='Transformation.jpg'
			if("Combat item") o.icon='CombatItem.jpg'
			if("Training method") o.icon='Training.png'
			if("Item") o.icon='Item.jpg'
		hotbar_type_icons+=o

proc/GridPosToListPos(gp)
	var/comma_pos = findtext(gp, ",")
	if(comma_pos) gp = copytext(gp, comma_pos + 1, length(gp) + 1)

	return text2num(gp)
proc/RetrieveParamsInformation(params)
	var/drop_coords = null;
	var/drop_pair = null;
	var/list/pairs = dd_text2list(params, ";");
	// Find the pair that contains the drop cell information
	for(var/pair in pairs)
	{
		if(findtext(pair, "drop-cell"))
		{		
			drop_pair = pair;
			break;
		}
	}
	// Extract the drop cell coordinates from the drop pair	
	if(drop_pair != null)
	{
		var/drop_str = dd_replaceText(drop_pair, "drop-cell=", "");
		drop_coords = drop_str
	}
	return drop_coords;


client/MouseDrop(obj/src_object, over_object, src_location, over_location, src_control, over_control, params)

	if(mob && isobj(src_object) && over_location && over_control == "hotbar.key_grid")

		//what was dragged is only an icon representing an object, so get the actual object from it
		if(istype(src_object,/obj/hotbar_type_icon))
			var/list_pos = GridPosToListPos(src_location)
			if(mob.hotbar_objects.len >= list_pos)
				src_object = mob.hotbar_objects[list_pos]

		if(src_object && src_object.loc == mob && src_object.can_hotbar)
			var/list_pos = GridPosToListPos(RetrieveParamsInformation(params))
			if(mob.hotbar.len < list_pos) mob.hotbar.len = list_pos

			//there is never any reason for them to drag the exact same object onto the exact same key its already on, but if allowed to do so
			//it will cause a bug, so thats why i put this safety check to just stop
			if(src_object == mob.hotbar[list_pos])
				return

			//if object is hotkeyed to another button clear that button because having the same thing on 2 different buttons is
			//not currently supported because if you relog it will clear 1 of the buttons anyway like a bug
			for(var/obj/o in mob.hotbar) if(o == src_object)
				mob.hotbar -= src_object
				mob.hotbar_ids -= src_object.hotbar_id
				mob << "<font color=yellow>[src_object] was cleared from the other key it was already assigned to because having the same thing attached to \
				multiple buttons is not currently supported."
			if(mob.hotbar.len < list_pos) mob.hotbar.len = list_pos //fix error
			mob.hotbar[list_pos] = src_object
			src_object.hotbar_id = Assign_hotbar_ID()
			mob.Register_hotbar_ID(src_object.type, src_object.hotbar_id, list_pos)
			mob.Refresh_hotbar_key_grid()

proc/Assign_hotbar_ID()
	return "[rand(1,999999999)]"

mob/proc/Register_hotbar_ID(t,i,hotbar_pos=1)
	//if(key=="Tens of DU") src<<"Register_hotbar_ID"
	if(istext(hotbar_pos)) hotbar_pos=text2num(hotbar_pos)
	if(isnum(i)) i=num2text(i)
	for(var/id in hotbar_ids) if(istext(id))
		var/list/id_info=hotbar_ids[id]
		if(id_info["hotbar position"]==hotbar_pos)
			hotbar_ids-=id
	hotbar_ids[i]=list("hotbar position"=hotbar_pos,"object type"=t)

//this fixes a bug with the original system. should be able to be removed after a while
mob/proc/Hotbar_IDs_valid()
	//if(key=="Tens of DU") src<<"Hotbar_IDs_valid"
	//if(!hotbar_ids.len) return
	if(istext(hotbar_ids))
		src << "HOTBAR INFORMATION INVALID. RESETTING"
		return
	for(var/v in hotbar_ids) if(istext(v))
		var/list/l=hotbar_ids[v]
		if(!("hotbar position" in l))
			src << "HOTBAR INFORMATION INVALID. RESETTING"
			return
		if(!("object type" in l))
			src << "HOTBAR INFORMATION INVALID. RESETTING"
			return
	return 1

mob/verb/Delete_hotbar()
	set hidden=1
	set name=".Delete_hotbar"
	//if(key=="Tens of DU") src<<"Delete_hotbar"
	hotbar=new/list
	hotbar_ids=new/list
	Refresh_hotbar_grids()
	initializeNexusHotkeys()

mob/var/starter_hotbar_generated

mob/verb/Restore_starter_hotbar()
	set hidden=1
	set name=".Restore_starter_hotbar"
	hotbar_ids=new/list
	starter_hotbar_generated=0
	Generate_starter_hotbar()
	Refresh_hotbar_grids()

mob/proc/Generate_starter_hotbar()
	if(hotbar_ids.len) return
	if(starter_hotbar_generated) return
	starter_hotbar_generated=1
	hotbar=new/list
	hotbar_ids=new/list
	var/index=0
	for(var/k in keys)
		index++
		var/object_type
		switch(k)
			if("Space") object_type=/obj/Manual_Attack
			//if("A") object_type=/obj/Attacks/Shockwave
			if("A") object_type=/obj/Move_Left
			if("B") object_type=/obj/World_chat
			if("C")
			//if("D") object_type=/obj/Attacks/Charge
			if("D") object_type=/obj/Move_Right
			if("E") object_type=/obj/Use_object
			if("F") object_type=/obj/Attacks/Blast
			if("G") object_type=/obj/Power_Up
			if("H") object_type=/obj/Power_Down
			if("I") object_type=/obj/Injure
			if("J") object_type=/obj/Meditate
			if("K") object_type=/obj/Train
			if("L") object_type=/obj/Play_Music
			if("M") object_type=/obj/Build_Menu
			if("N") object_type=/obj/Emote
			if("O") object_type=/obj/Lethal_toggle
			if("P") object_type=/obj/Shadow_Spar
			if("Q") object_type=/obj/Countdown
			if("R") object_type=/obj/Fly
			//if("S") object_type=/obj/Attacks/Beam
			if("S") object_type=/obj/Move_Down
			if("T") object_type=/obj/Grab
			if("U") object_type=/obj/Dig_for_resources
			if("V") object_type=/obj/Local_chat
			//if("W") object_type=/obj/Block
			if("W") object_type=/obj/Move_Up
			if("X") object_type=/obj/Learn
			if("Y") object_type=/obj/Auto_Attack
			if("Z") object_type=/obj/Teach
		if(object_type)
			Register_hotbar_ID(object_type,Assign_hotbar_ID(),index)
	Restore_hotbar_from_IDs()

mob/proc/Restore_hotbar_from_IDs()

	if(!client || skip_restore_hotbar) return

	if(!playerCharacter) return //this person is on the title screen and not loaded into a character

	if(!Hotbar_IDs_valid())
		hotbar = new/list
		hotbar_ids = new/list

	if(!hotbar_ids.len && Has_hotkey_server_backup())
		//src<<"ERROR: Loading hotkeys from backup stored on server. Report this error please."
		Hotkey_server_backup_load()

	hotbar=new/list

	var/list/hotbarrables=new
	for(var/obj/o in src) if(o.can_hotbar) hotbarrables+=o

	for(var/id in hotbar_ids) if(istext(id))

		var/obj_found
		var/list/hotbar_id_info=hotbar_ids[id]
		var/list_pos=hotbar_id_info["hotbar position"]
		var/obj_type=hotbar_id_info["object type"]

		for(var/obj/o in hotbarrables) if(o.hotbar_id==id)
			obj_found=1
			if(hotbar.len<list_pos) hotbar.len=list_pos
			hotbar[list_pos]=o
			break

		if(!obj_found) for(var/obj/o in hotbarrables) if(o.type==obj_type)
			if(!(o in hotbar))
				o.hotbar_id=Assign_hotbar_ID()
				hotbar_ids-=id
				Register_hotbar_ID(o.type,o.hotbar_id,list_pos)
				if(hotbar.len<list_pos) hotbar.len=list_pos
				hotbar[list_pos]=o
				break

	Refresh_hotbar_grids()
	initializeNexusHotkeys()

mob/proc/Refresh_hotbar_grids()
	//if(key=="Tens of DU") src<<"Refresh_hotbar_grids"
	if(!client) return
	if(winget(src,"hotbar","is-visible")!="true") return
	Refresh_hotbar_ability_grid()
	Refresh_hotbar_key_grid()

mob/var/tmp/list/hotbar_objects

mob/proc/Refresh_hotbar_ability_grid()
	//if(key=="Tens of DU") src<<"Refresh_hotbar_ability_grid"

	if(!client) return

	if(winget(src,"hotbar","is-visible")!="true") return
	hotbar_objects=new/list
	for(var/obj/o in src) if(o.can_hotbar) hotbar_objects+=o
	hotbar_objects=Sort_hotbar_objects(hotbar_objects)
	winset(src,"hotbar.ability_grid","cells=2x[hotbar_objects.len]")
	var/cell=1
	for(var/obj/o in hotbar_objects)

		winset(src,"hotbar.ability_grid","current-cell=1,[cell]")
		src<<output(Get_hotbar_type_icon(o.hotbar_type),"hotbar.ability_grid")

		winset(src,"hotbar.ability_grid","current-cell=2,[cell]")
		src<<output(o,"hotbar.ability_grid")

		cell++

var/list/keys=list("Space","0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R",\
"S","T","U","V","W","X","Y","Z")

var/list/hotbar_letter_icons

proc/Generate_hotbar_letter_icons()
	hotbar_letter_icons=new/list
	for(var/k in keys)
		var/obj/key_icon=new
		key_icon.icon=Get_hotbar_letter_icon(k)
		key_icon.name=k
		hotbar_letter_icons+=key_icon

proc/Get_hotbar_letter_obj(k)
	if(!hotbar_letter_icons) Generate_hotbar_letter_icons()
	for(var/obj/o in hotbar_letter_icons) if(o.name==k) return o

proc/Get_hotbar_letter_icon(k)
	switch(k)
		if("Space") return 'SpacebarHotbarIcon.jpg'
		if("0") return 'Asset0HotbarIcon.jpg'
		if("1") return 'Asset1HotbarIcon.jpg'
		if("2") return 'Asset2HotbarIcon.jpg'
		if("3") return 'Asset3HotbarIcon.jpg'
		if("4") return 'Asset4HotbarIcon.jpg'
		if("5") return 'Asset5HotbarIcon.jpg'
		if("6") return 'Asset6HotbarIcon.jpg'
		if("7") return 'Asset7HotbarIcon.jpg'
		if("8") return 'Asset8HotbarIcon.jpg'
		if("9") return 'Asset9HotbarIcon.jpg'
		if("A") return 'AHotbarIcon.jpg'
		if("B") return 'BHotbarIcon.jpg'
		if("C") return 'CHotbarIcon.jpg'
		if("D") return 'DHotbarIcon.jpg'
		if("E") return 'EHotbarIcon.jpg'
		if("F") return 'FHotbarIcon.jpg'
		if("G") return 'GHotbarIcon.jpg'
		if("H") return 'HHotbarIcon.jpg'
		if("I") return 'IHotbarIcon.jpg'
		if("J") return 'JHotbarIcon.jpg'
		if("K") return 'KHotbarIcon.jpg'
		if("L") return 'LHotbarIcon.jpg'
		if("M") return 'MHotbarIcon.jpg'
		if("N") return 'NHotbarIcon.jpg'
		if("O") return 'OHotbarIcon.jpg'
		if("P") return 'PHotbarIcon.jpg'
		if("Q") return 'QHotbarIcon.jpg'
		if("R") return 'RHotbarIcon.jpg'
		if("S") return 'SHotbarIcon.jpg'
		if("T") return 'THotbarIcon.jpg'
		if("U") return 'UHotbarIcon.jpg'
		if("V") return 'VHotbarIcon.jpg'
		if("W") return 'WHotbarIcon.jpg'
		if("X") return 'XHotbarIcon.jpg'
		if("Y") return 'YHotbarIcon.jpg'
		if("Z") return 'ZHotbarIcon.jpg'

mob/proc/Refresh_hotbar_key_grid()
	//if(key=="Tens of DU") src<<"Refresh_hotbar_key_grid"

	if(!client) return

	if(winget(src,"hotbar","is-visible")!="true") return
	winset(src,"hotbar.key_grid","cells=3x[keys.len]")
	var/cell=1
	for(var/k in keys)

		winset(src,"hotbar.key_grid","current-cell=1,[cell]")
		src<<output(Get_hotbar_letter_obj(k),"hotbar.key_grid")

		winset(src,"hotbar.key_grid","current-cell=2,[cell]")
		src<<output(Get_hotbar_type_icon("Empty"),"hotbar.key_grid")

		winset(src,"hotbar.key_grid","current-cell=3,[cell]")
		src<<output("Nothing","hotbar.key_grid")

		cell++
	cell=1
	for(var/v in hotbar)
		if(isobj(v))
			var/obj/o=v
			if(o.loc==src)

				winset(src,"hotbar.key_grid","current-cell=2,[cell]")
				src<<output(Get_hotbar_type_icon(o.hotbar_type),"hotbar.key_grid")

				winset(src,"hotbar.key_grid","current-cell=3,[cell]")
				src<<output(o.name,"hotbar.key_grid")

			else hotbar[cell]=null
		cell++

proc/Sort_hotbar_objects(list/original_list)
	if(!original_list.len) return original_list
	var/list/sorted_list=new
	for(var/t in hotbar_types)
		for(var/obj/o in original_list) if(o.hotbar_type==t)
			sorted_list+=o
			original_list-=o
	return sorted_list

mob/verb/Show_hotbar_grid()
	set hidden=1
	showNexusHotkeyEditor()

mob/verb/Hide_hotbar_grid()
	set hidden=1
	set name=".Hide_hotbar_grid"
	hideNexusHotkeyEditor()

mob/verb/ToggleHotbarMenu()
	set hidden=1
	if(nexus_hotkey_editor_open) Hide_hotbar_grid()
	else Show_hotbar_grid()

mob/verb/ToggleAutoAttack()
	set hidden=1
	AutoAttack()
