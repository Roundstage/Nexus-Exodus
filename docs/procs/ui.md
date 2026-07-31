# UI

## Overview
Runtime HUD, browser-based character/admin interfaces, hotkeys, and other client-facing presentation systems. The legacy Stats tab is no longer refreshed; the detailed Character sheet is opened from the top-right action HUD.

## Files
- `src/Code/UI/ActionHud.dm`
- `src/Code/UI/AdminInspector.dm`
- `src/Code/UI/CharacterSheet.dm`
- `src/Code/UI/DamageIndicators.dm`
- `src/Code/UI/Guide.dm`
- `src/Code/UI/HUD.dm`
- `src/Code/UI/HelperQuests.dm`
- `src/Code/UI/Hotkeys.dm`
- `src/Code/UI/RPWindow.dm`
- `src/Code/UI/SavePlayerSettings.dm`
- `src/Code/UI/Tabs2017/BuildTab.dm`
- `src/Code/UI/UIStuff.dm`
- `src/Code/UI/Wasted.dm`

## Proc Reference

### src/Code/UI/ActionHud.dm

- `initializeActionHud()` creates the top-right Lethal, RP Mode, and Character buttons and hides their obsolete skin controls.
- `refreshActionHud()` keeps button labels and colors synchronized with live combat state.
- `removeActionHud()` detaches runtime screen objects during client/HUD cleanup.

### src/Code/UI/AdminInspector.dm

- `showNexusAdminInspector(target)` opens a level-3-admin-only replacement for the raw EDIT window.
- `datum/NexusAdminInspector/buildHtml()` groups editable variables by identity, combat, progression, appearance, position, collection, system, or other and exposes live text/category filtering.
- `datum/NexusAdminInspector/editVariable(variable_name)` preserves the legacy number/text/file/list/null edit choices and admin logging.

### src/Code/UI/CharacterSheet.dm

- `showCharacterSheet()` exports the current sprite portrait and opens the responsive Character assessment.
- `buildCharacterSheetHtml(portrait_resource)` renders identity, equipment, vitals, effective and raw combat stats, growth, Technology, professions, Knowledge, Milestones, Lethal pressure, and learned skills.
- Admins receive a direct link from Character to the structured inspector.

### src/Code/UI/DamageIndicators.dm

#### proc/acquireDamageIndicator
- Signature: `proc/acquireDamageIndicator()`
- Inputs: None.
- Purpose: Acquire a pooled floating combat-text object.
- Returns: `/obj/DamageIndicator` ready for display.
- Side effects: removes an object from the cache or creates one.

#### atom/proc/showDamageIndicator
- Signature: `atom/proc/showDamageIndicator(amount, text_color = "#ff667a")`
- Inputs: positive damage amount and optional CSS color.
- Purpose: Display animated world-space damage above an atom.
- Returns: the acquired indicator, or null when nothing can be shown.
- Side effects: starts an asynchronous animation.

#### obj/DamageIndicator/proc/show
- Signature: `show(atom/target, amount, text_color)`
- Inputs: target, damage amount, and text color.
- Purpose: Format, position, animate, and release one damage indicator.
- Returns: none (asynchronous).
- Side effects: moves and animates the pooled object in the world.

#### obj/DamageIndicator/proc/release
- Signature: `release()`
- Inputs: None.
- Purpose: Reset and return an indicator to the cache.
- Returns: none (implicit).
- Side effects: clears visual state and removes the object from the map.

### src/Code/UI/Guide.dm

#### mob/verb/Guide
- Signature: `mob/verb/Guide()`
- Inputs: None
- Purpose: Handle guide.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/UI/HUD.dm

#### proc/hudPercentage
- Signature: `proc/hudPercentage(value, maximum = 100)`
- Inputs: current and maximum values.
- Purpose: Produce a nonnegative HUD percentage while guarding invalid maxima.
- Returns: percentage rounded to one decimal place.
- Side effects: none.

#### proc/nexusIsFiniteNumber
- Signature: `proc/nexusIsFiniteNumber(value)`
- Inputs: candidate numeric value.
- Purpose: Reject nonnumeric, infinite, and indeterminate values before they reach HUD or dummy calculations.
- Returns: boolean.
- Side effects: none.

#### proc/screenLocationPixels
- Signature: `proc/screenLocationPixels(screen_location)`
- Inputs: numeric BYOND `screen-loc` text.
- Purpose: Convert tile and pixel screen coordinates into absolute pixels for HUD dragging.
- Returns: two-item pixel coordinate list, or null for invalid input.
- Side effects: none.

#### proc/overheadHealthColor
- Signature: `proc/overheadHealthColor(health_percent)`
- Inputs: health percentage.
- Purpose: Resolve green above 60%, yellow from 50% through 60%, and red below 50%.
- Returns: hexadecimal color.
- Side effects: none.

#### proc/getOverheadHealthIcon
- Signature: `proc/getOverheadHealthIcon(health_percent)`
- Inputs: health percentage.
- Purpose: Build or reuse a real 32x5 icon with dark background and proportional colored fill.
- Returns: cached icon.
- Side effects: initializes a cache entry on first use.

#### proc/getVitalsPanelIcon
- Signature: `proc/getVitalsPanelIcon()`
- Inputs: None.
- Purpose: Build or reuse the clean 380x160 translucent backdrop for the draggable vitals panel.
- Returns: cached icon.
- Side effects: initializes the panel icon on first use.

#### proc/getVitalsBarIcon
- Signature: `proc/getVitalsBarIcon(percent, accent_color)`
- Inputs: percentage and accent color.
- Purpose: Build or reuse a 220x24 native progress-bar icon with proportional fill.
- Returns: cached icon.
- Side effects: initializes a cache entry on first use.

#### proc/getPowerGaugeIcon
- Signature: `proc/getPowerGaugeIcon(percent, over_limit)`
- Inputs: normalized soft-cap progress and over-limit state.
- Purpose: Build either lateral power gauge, switching from violet to red above the efficient limit.
- Returns: cached 9x96 icon.
- Side effects: initializes a cache entry on first use.

#### mob/proc/initializeVitalsHud
- Signature: `mob/proc/initializeVitalsHud()`
- Inputs: None.
- Purpose: Attach the compact overhead bar and initialize the lower-left main vitals panel for playable characters.
- Returns: none (implicit).
- Side effects: updates `vis_contents`, `client.screen`, and hides the obsolete DMF Bars window.

#### mob/proc/initializeMainVitalsHud
- Signature: `mob/proc/initializeMainVitalsHud()`
- Inputs: None.
- Purpose: Create the lower-left panel with a centered enlarged character, three vitals rows, lateral power gauges, and a percentage readout.
- Returns: none (implicit).
- Side effects: creates one client-owned screen-object tree and synchronizes visibility with `client.show_bars`.

#### mob/proc/updateMainVitalsHud
- Signature: `mob/proc/updateMainVitalsHud()`
- Inputs: None.
- Purpose: Refresh the centered character, right-aligned `(current Energy) percentage%`, raw power percentage, and powerup soft-cap state.
- Returns: none (implicit).
- Side effects: updates screen appearances and maptext.

#### mob/proc/setVitalsHudVisibility
- Signature: `mob/proc/setVitalsHudVisibility(visible)`
- Inputs: desired visibility.
- Purpose: Add or remove the main vitals panel from `client.screen` without exposing the old DMF window.
- Returns: none (implicit).
- Side effects: mutates the client's screen list.

#### mob/Write
- Signature: `mob/Write(savefile/save_file)`
- Inputs: destination savefile.
- Purpose: Temporarily detach the runtime-only overhead HUD during all mob serialization.
- Returns: parent serialization result.
- Side effects: removes and restores the visual around the write operation.

#### mob/proc/updateOverheadHealthHud
- Signature: `mob/proc/updateOverheadHealthHud()`
- Inputs: None.
- Purpose: Refresh the health state and vertical position of the overhead HUD.
- Returns: none (implicit).
- Side effects: may initialize the HUD if it is missing.

#### mob/proc/removeVitalsHud
- Signature: `mob/proc/removeVitalsHud()`
- Inputs: None.
- Purpose: Detach and delete both overhead and main vitals HUD objects.
- Returns: none (implicit).
- Side effects: removes visual and screen objects.

#### obj/NexusHud/VitalsPanel/proc/initialize
- Signature: `initialize(mob/owner)`
- Inputs: owning player.
- Purpose: Compose the centered character, two power gauges, percentage readout, and three stat rows over the panel root.
- Returns: none (implicit).
- Side effects: populates `vis_contents`.

#### obj/NexusHud/VitalsPanel/proc/update
- Signature: `update(mob/owner)`
- Inputs: owning player.
- Purpose: Calculate Health, Energy, Stamina, raw `BPpcnt`, and the efficient powerup threshold.
- Returns: none (implicit).
- Side effects: updates child screen objects.

#### obj/NexusHud/VitalsPanel/proc/moveToMouse
- Signature: `moveToMouse(screen_location)`
- Inputs: current mouse screen location.
- Purpose: Move the panel from its stored drag origin while keeping it inside the left/bottom screen edges.
- Returns: none (implicit).
- Side effects: updates panel screen position.

#### obj/NexusHud/VitalsPanel/proc/setScreenPosition
- Signature: `setScreenPosition(new_x, new_y)`
- Inputs: absolute lower-left pixel coordinates.
- Purpose: Store the panel position using BYOND's icon-aware `LEFT` and `BOTTOM` anchors.
- Returns: none (implicit).
- Side effects: updates `screen_loc`.

#### obj/NexusHud/CharacterPortrait/proc/update
- Signature: `update(mob/owner)`
- Inputs: owning player.
- Purpose: Copy, enlarge, and center the character between the lateral power gauges without an additional frame.
- Returns: none (implicit).
- Side effects: replaces the portrait appearance.

#### obj/NexusHud/VitalRow/proc/update
- Signature: `update(label, percent, detail, accent_color)`
- Inputs: row label, percentage, display detail, and accent color.
- Purpose: Render one native icon-based stat row, its progress fill, label, and numeric detail.
- Returns: none (implicit).
- Side effects: swaps a cached bar icon and updates maptext.

#### obj/NexusHud/PowerGauge/proc/update
- Signature: `update(percent, over_limit)`
- Purpose: Raise both lateral indicators with power and show red saturation after the soft cap.
- Returns: none (implicit).
- Side effects: swaps a cached vertical icon.

#### obj/NexusHud/PowerReadout/proc/update
- Signature: `update(power_percent, soft_cap, over_limit)`
- Purpose: Render exactly one percentage line below the character, using color rather than duplicate text to signal the soft cap.
- Returns: none (implicit).
- Side effects: updates maptext.

#### obj/NexusHud/OverheadHealthBar/proc/update
- Signature: `update(mob/owner)`
- Inputs: displayed character.
- Purpose: Render a 32x5 health bar that is green above 60%, yellow from 50% through 60%, and red below 50%.
- Returns: none (implicit).
- Side effects: swaps the cached world-space icon.

#### obj/NexusHud/VitalsPanel/MouseDrag
- Signature: `MouseDrag(over_object, src_location, over_location, src_control, over_control, params)`
- Inputs: standard BYOND mouse-drag context.
- Purpose: Drag the client-owned vitals panel directly by its translucent background.
- Returns: none (implicit).
- Side effects: updates the panel position.

#### proc/DrawHUD
- Signature: `proc/DrawHUD(mob/M=usr)`
- Inputs: mob/M=usr
- Purpose: Legacy unused target HUD retained for save compatibility; the active vitals HUD uses `/obj/NexusHud/VitalsPanel`.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/DrawBars
- Signature: `proc/DrawBars(mob/M=usr, t=0)`
- Inputs: mob/M=usr, t=0
- Purpose: Handle draw bars.
- Returns: none (implicit).
- Side effects: see implementation.

#### HUD/screenAnchor/New
- Signature: `New(screenX, screenY=null)`
- Inputs: screenX, screenY=null
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### HUD/statBar/New
- Signature: `New(mob/U, trX, trY, t=0)`
- Inputs: mob/U, trX, trY, t=0
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Update
- Signature: `proc/Update(mob/U, t=0)`
- Inputs: mob/U, t=0
- Purpose: Handle update.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/UI/HelperQuests.dm

#### mob/verb/HideHelpAlert
- Signature: `HideHelpAlert()`
- Inputs: None
- Purpose: Handle hide help alert.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/HelpAlert
- Signature: `HelpAlert(txt, duration = 999, command)`
- Inputs: txt, duration = 999, command
- Purpose: Handle help alert.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/InitHelperQuests
- Signature: `InitHelperQuests()`
- Inputs: None
- Purpose: Initialize Helper Quests.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/InitPowerQuest
- Signature: `InitPowerQuest()`
- Inputs: None
- Purpose: Initialize Power Quest.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PowerQuestLoop
- Signature: `PowerQuestLoop()`
- Inputs: None
- Purpose: Handle power quest loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/TryPowerQuestIntro
- Signature: `TryPowerQuestIntro()`
- Inputs: None
- Purpose: Handle try power quest intro.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/UI/Hotkeys.dm

#### mob/proc/LoadCharacterHotkeyThing
- Signature: `mob/proc/LoadCharacterHotkeyThing()`
- Inputs: None
- Purpose: Load Character Hotkey Thing.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/Has_hotkey_server_backup
- Signature: `Has_hotkey_server_backup()`
- Inputs: None
- Purpose: Return whether hotkey server backup.
- Returns: boolean flag.
- Side effects: none expected.

#### mob/proc/Hotkey_server_backup_load
- Signature: `Hotkey_server_backup_load()`
- Inputs: None
- Purpose: Handle hotkey server backup load.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Hotkey_server_backup_save
- Signature: `Hotkey_server_backup_save()`
- Inputs: None
- Purpose: Handle hotkey server backup save.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Add_hotbar_proxies
- Signature: `mob/proc/Add_hotbar_proxies()`
- Inputs: None
- Purpose: Add global utility proxies, including standalone Lunge and ownership-gated Flash Step.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### obj/Lunge verbs
- Signature: `Hotbar_use()`, `lunge()`
- Inputs: None.
- Purpose: Expose Lunge as a standalone hotbar action and Skills verb instead of a Space-release side effect.
- Returns: none (implicit).
- Side effects: delegates to `LungeAttack()`.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Defend
- Signature: `mob/proc/Defend()`
- Inputs: None
- Purpose: Handle defend.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Dice_Roll
- Signature: `mob/verb/Dice_Roll()`
- Inputs: None
- Purpose: Handle dice roll.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### verb/Hotbar_use
- Signature: `verb/Hotbar_use()`
- Inputs: None
- Purpose: Handle hotbar use.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Get_hotbar_obj_by_key_pressed
- Signature: `mob/proc/Get_hotbar_obj_by_key_pressed(kp)`
- Inputs: kp
- Purpose: Return hotbar obj by key pressed.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Get_hotbar_ability_key
- Signature: `mob/proc/Get_hotbar_ability_key(obj/o)`
- Inputs: obj/o
- Purpose: Return hotbar ability key.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/Get_hotbar_type_icon
- Signature: `proc/Get_hotbar_type_icon(t)`
- Inputs: t
- Purpose: Return hotbar type icon.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/Generate_hotbar_type_icons
- Signature: `proc/Generate_hotbar_type_icons()`
- Inputs: None
- Purpose: Handle generate hotbar type icons.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/GridPosToListPos
- Signature: `proc/GridPosToListPos(gp)`
- Inputs: gp
- Purpose: Handle grid pos to list pos.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/RetrieveParamsInformation
- Signature: `proc/RetrieveParamsInformation(params)`
- Inputs: params
- Purpose: Handle retrieve params information.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/MouseDrop
- Signature: `client/MouseDrop(obj/src_object, over_object, src_location, over_location, src_control, over_control, params)`
- Inputs: obj/src_object, over_object, src_location, over_location, src_control, over_control, params
- Purpose: Handle mouse drop.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Assign_hotbar_ID
- Signature: `proc/Assign_hotbar_ID()`
- Inputs: None
- Purpose: Handle assign hotbar id.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Register_hotbar_ID
- Signature: `mob/proc/Register_hotbar_ID(t,i,hotbar_pos=1)`
- Inputs: t, i, hotbar_pos=1
- Purpose: Handle register hotbar id.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Hotbar_IDs_valid
- Signature: `mob/proc/Hotbar_IDs_valid()`
- Inputs: None
- Purpose: Handle hotbar ids valid.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Delete_hotbar
- Signature: `mob/verb/Delete_hotbar()`
- Inputs: None
- Purpose: Delete hotbar.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/verb/Restore_starter_hotbar
- Signature: `mob/verb/Restore_starter_hotbar()`
- Inputs: None
- Purpose: Handle restore starter hotbar.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Generate_starter_hotbar
- Signature: `mob/proc/Generate_starter_hotbar()`
- Inputs: None
- Purpose: Handle generate starter hotbar.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Restore_hotbar_from_IDs
- Signature: `mob/proc/Restore_hotbar_from_IDs()`
- Inputs: None
- Purpose: Handle restore hotbar from ids.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Refresh_hotbar_grids
- Signature: `mob/proc/Refresh_hotbar_grids()`
- Inputs: None
- Purpose: Handle refresh hotbar grids.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Refresh_hotbar_ability_grid
- Signature: `mob/proc/Refresh_hotbar_ability_grid()`
- Inputs: None
- Purpose: Handle refresh hotbar ability grid.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Generate_hotbar_letter_icons
- Signature: `proc/Generate_hotbar_letter_icons()`
- Inputs: None
- Purpose: Handle generate hotbar letter icons.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Get_hotbar_letter_obj
- Signature: `proc/Get_hotbar_letter_obj(k)`
- Inputs: k
- Purpose: Return hotbar letter obj.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### proc/Get_hotbar_letter_icon
- Signature: `proc/Get_hotbar_letter_icon(k)`
- Inputs: k
- Purpose: Return hotbar letter icon.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/Refresh_hotbar_key_grid
- Signature: `mob/proc/Refresh_hotbar_key_grid()`
- Inputs: None
- Purpose: Handle refresh hotbar key grid.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Sort_hotbar_objects
- Signature: `proc/Sort_hotbar_objects(list/original_list)`
- Inputs: list/original_list
- Purpose: Handle sort hotbar objects.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Show_hotbar_grid
- Signature: `mob/verb/Show_hotbar_grid()`
- Inputs: None
- Purpose: Handle show hotbar grid.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/Hide_hotbar_grid
- Signature: `mob/verb/Hide_hotbar_grid()`
- Inputs: None
- Purpose: Handle hide hotbar grid.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/ToggleHotbarMenu
- Signature: `mob/verb/ToggleHotbarMenu()`
- Inputs: None
- Purpose: Toggle Hotbar Menu.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/verb/ToggleAutoAttack
- Signature: `mob/verb/ToggleAutoAttack()`
- Inputs: None
- Purpose: Toggle Auto Attack.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/UI/HotkeyEditor.dm

#### proc/canonicalNexusHotkey
- Signature: `canonicalNexusHotkey(base_key, use_ctrl = 0, use_shift = 0, use_alt = 0)`
- Inputs: allowlisted base key and modifier flags.
- Purpose: Produce stable combinations such as `CTRL+SHIFT+Numpad7`.
- Returns: canonical combination or null for an unsupported key.
- Side effects: none.

#### datum/NexusHotkeyAction
- Purpose: Define non-object actions with stable IDs, labels, availability predicates, repeat policy, and execution behavior.
- Current actions: eight Zanzoken directions, available only while the player owns `/obj/Zanzoken`.

#### mob/proc/initializeNexusHotkeys
- Purpose: Migrate positional legacy bindings, initialize runtime state, and rebuild client-local dynamic macros.
- Side effects: updates binding version and client macros.

#### mob/proc/resolveNexusHotkeyBinding
- Signature: `resolveNexusHotkeyBinding(combination)`
- Purpose: Resolve an available registered action or owned `can_hotbar` object at execution time.
- Returns: action datum, object, or null when unavailable.
- Side effects: none.

#### client/proc/syncNexusHotkeyMacros
- Purpose: Recreate modifier and non-static macros using `winset()`, with paired key-up handling.
- Supported: `CTRL`, `SHIFT`, `ALT`, independent numpad digits/operators, selected function keys, and utility keys.
- Side effects: replaces only client-local macros created by this system.

#### mob/proc/buildNexusHotkeyEditorHtml
- Purpose: Render the searchable action deck, draggable virtual keyboard, modifier controls, independent numpad, and active binding summary.
- Security: actions are represented by server-issued opaque tokens and revalidated in `Topic()`.

#### datum/NexusHotkeyEditor/Topic
- Purpose: Validate bind, unbind, clear, import, and close events sent by the in-game browser editor.
- Side effects: saves each change immediately and refreshes macros/editor state.

#### mob/proc/showNexusHotkeyEditor
- Purpose: Stop held input and open the new editor used by F5.
- Side effects: opens `NexusHotkeys` and suppresses gameplay key dispatch while active.

### src/Code/UI/RPWindow.dm

#### mob/proc/ViewEmoteWindow
- Signature: `ViewEmoteWindow(mob/admin, mob/player, unwritten, type = "Emote", path = "emotelogs", overwrite_ckey = "none")`
- Inputs: mob/admin, mob/player, unwritten, type = "Emote", path = "emotelogs", overwrite_ckey = "none"
- Purpose: Handle view emote window.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/ViewSelfRPWindow
- Signature: `ViewSelfRPWindow()`
- Inputs: None
- Purpose: Handle view self rpwindow.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/ViewSelfDevelopmentRPWindow
- Signature: `ViewSelfDevelopmentRPWindow()`
- Inputs: None
- Purpose: Handle view self development rpwindow.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/ViewSelfSayWindow
- Signature: `ViewSelfSayWindow()`
- Inputs: None
- Purpose: Handle view self say window.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PostEmoteRPWindow
- Signature: `PostEmoteRPWindow(text as text, key)`
- Inputs: text as text, key
- Purpose: Handle post emote rpwindow.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PostDevelopmentRPWindow
- Signature: `PostDevelopmentRPWindow(text as text, key)`
- Inputs: text as text, key
- Purpose: Handle post development rpwindow.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/ViewDescription
- Signature: `mob/verb/ViewDescription(mob/A)`
- Inputs: mob/A
- Purpose: Handle view description.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/EmoteLog
- Signature: `EmoteLog(info, the_key, type="emotelogs", needs_client = TRUE)`
- Inputs: info, the_key, type="emotelogs", needs_client = TRUE
- Purpose: Handle emote log.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Write_emotelogs
- Signature: `Write_emotelogs(allow_splits=1, type, log = "")`
- Inputs: allow_splits=1, type, log = ""
- Purpose: Handle write emotelogs.
- Returns: none (implicit).
- Side effects: see implementation.

#### proc/Split_EmoteFile
- Signature: `proc/Split_EmoteFile(the_key, type)`
- Inputs: the_key, type
- Purpose: Handle split emote file.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/UI/SavePlayerSettings.dm

#### mob/proc/save_player_settings
- Signature: `save_player_settings()`
- Inputs: None
- Purpose: Save player settings.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/load_player_settings
- Signature: `load_player_settings()`
- Inputs: None
- Purpose: Load player settings.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

### src/Code/UI/Tabs2017/BuildTab.dm

#### mob/verb/MapFocus
- Signature: `MapFocus()`
- Inputs: None
- Purpose: Handle map focus.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/ToggleBuildMenu
- Signature: `ToggleBuildMenu()`
- Inputs: None
- Purpose: Toggle Build Menu.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/PopulateBuildTabs
- Signature: `PopulateBuildTabs()`
- Inputs: None
- Purpose: Handle populate build tabs.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/PopulateBuildTab
- Signature: `PopulateBuildTab(win = "TabBuildFloors", cat = BUILD_UNDEFINED)`
- Inputs: win = "TabBuildFloors", cat = BUILD_UNDEFINED
- Purpose: Handle populate build tab.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/UI/UIStuff.dm

#### client/Del
- Signature: `client/Del()`
- Inputs: None
- Purpose: Remove the client from the global list and delete the client-owned vitals panel with all child visuals.
- Returns: parent deletion result.
- Side effects: removes the panel from `client.screen`.

#### client/proc/DisplayTitleScreen
- Signature: `DisplayTitleScreen()`
- Inputs: None
- Purpose: Handle display title screen.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/proc/DeleteTitleScreen
- Signature: `DeleteTitleScreen()`
- Inputs: None
- Purpose: Delete Title Screen.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### obj/Button/Click
- Signature: `Click()`
- Inputs: None
- Purpose: Handle click.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/Button/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### client/New
- Signature: `client/New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/HideAllUI
- Signature: `HideAllUI()`
- Inputs: None
- Purpose: Handle hide all ui.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/StatOverlayUpdateLoop
- Signature: `StatOverlayUpdateLoop()`
- Inputs: None
- Purpose: Handle stat overlay update loop.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/ToggleChatbox
- Signature: `ToggleChatbox()`
- Inputs: None
- Purpose: Toggle Chatbox.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/verb/SettingsButtonClicked
- Signature: `SettingsButtonClicked()`
- Inputs: None
- Purpose: Handle settings button clicked.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/PressEscape
- Signature: `PressEscape()`
- Inputs: None
- Purpose: Handle press escape.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/ToggleSettingsWindow
- Signature: `ToggleSettingsWindow()`
- Inputs: None
- Purpose: Toggle Settings Window.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/verb/ToggleStatsOverlay
- Signature: `ToggleStatsOverlay()`
- Inputs: None
- Purpose: Toggle Stats Overlay.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/verb/ToggleTabs
- Signature: `ToggleTabs()`
- Inputs: None
- Purpose: Toggle Tabs.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/verb/ToggleBars
- Signature: `ToggleBars()`
- Inputs: None
- Purpose: Toggle Bars.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/verb/ViewGuides
- Signature: `ViewGuides()`
- Inputs: None
- Purpose: Handle view guides.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/ViewHotkeys
- Signature: `ViewHotkeys()`
- Inputs: None
- Purpose: Handle view hotkeys.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/ToggleInterfaceOrganizationMode
- Signature: `ToggleInterfaceOrganizationMode()`
- Inputs: None
- Purpose: Toggle Interface Organization Mode.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/verb/PressEnter
- Signature: `PressEnter()`
- Inputs: None
- Purpose: Handle press enter.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/verb/MainWindowResized
- Signature: `MainWindowResized()`
- Inputs: None
- Purpose: Handle main window resized.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GetWindowSize
- Signature: `GetWindowSize(e = "mainwindow.resizeLabel")`
- Inputs: e = "mainwindow.resizeLabel"
- Purpose: Return Window Size.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/GetWindowPos
- Signature: `GetWindowPos(e = "mainwindow")`
- Inputs: e = "mainwindow"
- Purpose: Return Window Pos.
- Returns: computed value (see implementation).
- Side effects: none expected.

#### mob/proc/HelpAlertShowing
- Signature: `HelpAlertShowing()`
- Inputs: None
- Purpose: Handle help alert showing.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/NewCharHelpAlerts
- Signature: `NewCharHelpAlerts()`
- Inputs: None
- Purpose: Handle new char help alerts.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/DetectNewLoadButtonClick
- Signature: `DetectNewLoadButtonClick()`
- Inputs: None
- Purpose: Handle detect new load button click.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/NewClicked
- Signature: `NewClicked()`
- Inputs: None
- Purpose: Handle new clicked.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/LoadClicked
- Signature: `LoadClicked()`
- Inputs: None
- Purpose: Load Clicked.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/NewLoadPromptClassic
- Signature: `NewLoadPromptClassic()`
- Inputs: None
- Purpose: Handle new load prompt classic.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/UI/Wasted.dm

#### mob/proc/GTA5WastedSound
- Signature: `GTA5WastedSound()`
- Inputs: None
- Purpose: Handle gta5 wasted sound.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GTA5ScreenObjects
- Signature: `GTA5ScreenObjects()`
- Inputs: None
- Purpose: Handle gta5 screen objects.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GTA5WastedCheck
- Signature: `GTA5WastedCheck()`
- Inputs: None
- Purpose: Handle gta5 wasted check.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GTA5Wasted
- Signature: `GTA5Wasted()`
- Inputs: None
- Purpose: Handle gta5 wasted.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GTA5Vignette
- Signature: `GTA5Vignette(obj/o)`
- Inputs: obj/o
- Purpose: Handle gta5 vignette.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/GTA5WastedLogo
- Signature: `GTA5WastedLogo(obj/o)`
- Inputs: obj/o
- Purpose: Handle gta5 wasted logo.
- Returns: none (implicit).
- Side effects: see implementation.

#### obj/GTA5_Stuff/New
- Signature: `New()`
- Inputs: None
- Purpose: Initialize object state and register references.
- Returns: none (implicit).
- Side effects: see implementation.
