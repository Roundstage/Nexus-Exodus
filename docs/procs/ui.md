# UI

## Overview
Auto-generated first-pass proc summaries based on signature names. Refine descriptions during refactors.

## Files
- `src/Code/UI/Guide.dm`
- `src/Code/UI/HUD.dm`
- `src/Code/UI/HelperQuests.dm`
- `src/Code/UI/Hotkeys.dm`
- `src/Code/UI/RPWindow.dm`
- `src/Code/UI/SavePlayerSettings.dm`
- `src/Code/UI/Tabs 2017/BuildTab.dm`
- `src/Code/UI/UIStuff.dm`
- `src/Code/UI/Wasted.dm`

## Proc Reference

### src/Code/UI/Guide.dm

#### mob/verb/Guide
- Signature: `mob/verb/Guide()`
- Inputs: None
- Purpose: Handle guide.
- Returns: none (implicit).
- Side effects: see implementation.

### src/Code/UI/HUD.dm

#### proc/DrawHUD
- Signature: `proc/DrawHUD(mob/M=usr)`
- Inputs: mob/M=usr
- Purpose: Handle draw hud.
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
- Purpose: Add hotbar proxies.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

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

#### mob/Admin1/verb/ViewRPWindow
- Signature: `ViewRPWindow(mob/M in players)`
- Inputs: mob/M in players
- Purpose: Handle view rpwindow.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/Admin1/verb/ViewDevelopmentRPWindow
- Signature: `ViewDevelopmentRPWindow(mob/M in players)`
- Inputs: mob/M in players
- Purpose: Handle view development rpwindow.
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

### src/Code/UI/Tabs 2017/BuildTab.dm

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
- Purpose: Cleanup before deletion and return pooled objects if needed.
- Returns: none (implicit).
- Side effects: see implementation.

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
