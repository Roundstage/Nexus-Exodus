# UI

## Overview
Runtime HUD, browser-based character/admin interfaces, hotkeys, and other client-facing presentation systems. Players can persistently choose the compact classic chat overlay or a split side layout that stacks configurable native tabs above a smaller four-channel chat and CMD bar. The detailed Character sheet is opened from the top-right action HUD. A compact pixel-icon strip exposes Inventory, Skills, Progression, Milestones, Build, Sense, Chat, Hotkeys, and the classic Escape menu; World and Admin are permission-gated administrator tools. Pressing an active window icon again closes that window.

The compact lower-left vitals panel renders labeled Willpower, Health, Energy, and Stamina rows; Energy uses `(ki) percentage%`. Say text renders above Typing, and Typing renders above the character. Beneath the character, thin bars are ordered Willpower, Health, and Energy from top to bottom, with the Sense power percentage locked below the Energy row. Players can persistently reposition that lower stack and either drag or numerically position the main panel. The top-right action controls repair their own `client.screen` registration during normal HUD updates.

The HudLib chat owns All, Combat, IC, and OOC feeds. Classic Overlay renders the compact rustic panel over the lower-right map and includes a CMD action; Side + Tabs puts the native Skills, Other, Items, World, and Admin categories above a reduced chat with a permanent Dream Seeker command input. The reduced browser is not a plain fallback: it uses `getNexusHudBrowserCss("bronze")`, Silkscreen, the same bolted frames, and the canonical pixel pictograms for its channel and composition controls. It deliberately omits redundant command-bar/focus instructional copy. Enter routes to the appropriate CMD interaction for the selected layout. Entries are divided by responsive, full-width horizontal rules instead of fixed text dashes. Channel and action buttons use fixed-height flex rows so legacy HTML content cannot stack them vertically. Legacy `mob << text` output is intercepted at the client operator and retained in All as a System message, while sounds, images, browser resources, and targeted control output continue through BYOND normally.

The primary game browsers use `getNexusHudBrowserCss()` to reproduce the native HUD construction instead of layering a broad theme over unrelated markup. Player-facing Inventory, Skills, Sense, World, Character, Progression, Milestones, Build, and Music Library surfaces use the bronze chat/action-button palette; administration uses the blue Server Panel palette. Character is an explicit snapshot with a manual Refresh control so reading it can never be interrupted by document replacement. Live menu scripts write scroll state to `sessionStorage` and restore it after intentional navigation. Login and Dream Seeker reconnect both use the silent, resizable RPG-style three-slot character selector instead of the New/Load alert. The selector and classic map title share the canonical transparent pixel-art logo. A reconnect saves and cleans up the previously attached character, transfers the client to a fresh lobby mob, and applies the oversized title view only to that lobby host; live characters retain their clamped saved view.

## Visual Asset Contract

These references are intentional and must not be removed, renamed, replaced with emoji/SVG art, or repurposed as generic category illustrations:

- `src/Icons/Unsorted/UserNamesBarsUi.png` is the 315x125 structural canvas used by `getNexusHudLibraryIcon()`, `getNexusActionButtonIcon()`, and the shortcut builders before code scales and paints the final surface. It is a frame source, not an Inventory or Skill icon.
- `src/Icons/UI/LethalHud.dmi` is the on-character Lethal indicator: unnamed state, 32x32 cells, four frames. It is not the top-right Lethal button background.
- `src/Icons/UI/RPModeHud.dmi` is the on-character RP Mode indicator: unnamed state, 48x32 cells, eight frames. It is not the top-right RP Mode button background.
- `src/Fonts/SilkscreenRegular.ttf` and `src/Fonts/SilkscreenBold.ttf` are the canonical embedded pixel fonts for native-HUD browser screens, sourced from the official Google Fonts Silkscreen family. Their SIL Open Font License is stored in `src/Fonts/SilkscreenOFL.txt`; keep all three files together.
- `src/Icons/UI/NexusExodusLogo.png` is the canonical primary logo. Login must use this exact transparent bronze/gunmetal/cyan pixel-art resource through `browse_rsc()` and `DisplayTitleScreen()`; do not restore `NexusExodus.dmi`, the old JPEG, a text-only substitute, or a looping login theme.
- `src/Images/Slime64.png` is a legacy resource path whose contents are now the canonical 64x64 Nexus Exodus application/window icon: a simplified bronze gateway X with a cyan central rift. The filename is retained only as an already tracked compiled-resource handle; it contains no slime or third-party artwork. `UI.dmf` declares `'Slime64.png'` directly on the main window so the icon is present from startup, and `client/applyNexusApplicationIcon()` reapplies the same quoted compiled resource after client creation. A runtime `/icon` reference is not accepted by the skin parameter. Do not substitute franchise characters, mascots, or a reduced copy of the full wordmark.
- The top-right Lethal and RP Mode buttons are 108x20 procedural surfaces from `getNexusActionButtonIcon()`: black outer frame, bronze inner edge, two gold top bolts, Fixedsys/Courier maptext, red Lethal accent, and orange RP Mode accent.
- Native panel bolts are not separate image files. They are 2x2 `#c6a15c` pixels drawn at the corners by `getNexusHudLibraryIcon()` and reproduced by the scoped `.hud-frame`/`.hud-card` pseudo-elements in `getNexusHudBrowserCss()`.
- Content imagery must come from the actual runtime atom through `getNexusBrowserAtomIconResource()` (`icon`, `icon_state`, direction, color, and alpha). Category pictograms must never substitute for item, technique, character, or blueprint sprites.
- Bronze chrome (`#201810`, `#715735`, `#9a7440`, `#d2aa61`) belongs to player surfaces and chat. Blue chrome (`#080d14`, `#304456`, `#405a70`, `#72c6eb`) belongs to admin/development surfaces. Both use square corners, hard inset edges, black pixel shadows, and no gradients in structural frames.

## Files
- `src/Code/UI/DU.dmf`
- `src/Code/UI/ActionHud.dm`
- `src/Code/UI/AdminInspector.dm`
- `src/Code/UI/CharacterSheet.dm`
- `src/Code/UI/DamageIndicators.dm`
- `src/Code/UI/Guide.dm`
- `src/Code/UI/HUD.dm`
- `src/Code/UI/HelperQuests.dm`
- `src/Code/UI/Hotkeys.dm`
- `src/Code/UI/HudLibrary.dm`
- `src/Code/UI/MusicLibrary.dm`
- `src/Code/UI/RPWindow.dm`
- `src/Code/UI/SavePlayerSettings.dm`
- `src/Code/UI/Tabs2017/BuildTab.dm`
- `src/Code/UI/UIStuff.dm`
- `src/Code/UI/Wasted.dm`

## Proc Reference

### src/Code/UI/ActionHud.dm

- `getNexusActionButtonIcon()` builds the 108x20 rustic controls needed to display complete `LETHAL`, `RPMODE`, and `CHARACTER` labels without clipping.
- `getNexusShortcutBarIcon()`, `getNexusShortcutButtonIcon()`, and `drawNexusShortcutGlyph()` build the top-left bolted strip and its license-independent pixel pictograms, including distinct tree, trophy, and hammer glyphs for Progression Trees, Milestones, and Build.
- `initializeActionHud()` creates the top-right Lethal, RP Mode, and Character buttons plus the top-left shortcut strip as client-only screen objects and hides their obsolete skin controls.
- `hasCompleteActionHud()` and `rebuildActionHud()` validate and reconstruct the complete three-button set.
- `getNexusShortcutTypes()`, `hasCompleteShortcutHud()`, and `rebuildShortcutHud()` maintain nine player shortcuts, including direct Progression Trees, Milestones, and Build access, and add World plus Admin only when the owner has an active admin level. CMD lives with chat instead of consuming a navbar slot.
- `refreshActionHud()` keeps labels, colors, chat state, and permission-aware shortcuts synchronized and reattaches objects removed by another screen system. Icon-aware `RIGHT`/`TOP` anchors keep the compact controls inside the map viewport.
- `getNexusLiveBrowserScript()` supplies the owner-authenticated refresh heartbeat shared by live browser windows. Scroll events publish their position immediately, restoration is retried after layout settles, and the refresh cadence remains an internal implementation detail rather than a visible status badge.
- `getNexusHotkeyDownMacroCommand()` and `getNexusHotkeyUpMacroCommand()` quote modifier combinations, provide matching release macros, and preserve normal cardinal/diagonal movement when an arrow also owns a custom action.
- `datum/NexusPlayerMenu` provides bronze native-HUD Inventory, Skills, Sense, and admin-only World surfaces. Inventory presents both carried Resources and the authoritative Arcane Essence balance as currencies; Inventory, Skills, Sense, and World export actual runtime sprites where their subjects are atoms. Items committed to an active trade offer remain visible but cannot be invoked through the Inventory action. Skills accepts only authoritative `Skill == 1` objects and explicitly excludes `/obj/items`. While its root view is open, a bounded loop rebuilds content once per second and sends a new page only when server state changed and the reader is at the top; closing the window terminates the loop. Examine pauses automatic page replacement and provides Back navigation. World character cards expose Examine and, at Admin Level 3+, Edit through the complete structured inspector. Skill details calculate an attacker-only, equal-power damage preview with zero enemy Endurance/Resistance plus range, cost, cooldown, mechanics, and equipment/grab requirements. Nexus melee previews retain the canonical base melee, speed, equipped sword/style, forged BP, and Milestone path; projectile previews reserve `setStats()`-scaled direct damage and unscaled splash separately through the authored shared budget. Basic Blast derives its preview from the currently configured volley count, refire factor, and optional center-projectile splash instead of displaying the shared-budget ceiling as every configuration's damage; Super Ghost Kamikaze exposes the maximum of its three fixed direct hits through their shared budget. Buffs expose all non-neutral BP/Energy/stat/regeneration/recovery multipliers and special attributes; transformations explain their form behavior and current state, including Great Ape's concrete multipliers, activation requirements, cooldown, and controlled/uncontrolled behavior, without exposing Sense information above the owner's access level.
- `getSkillDamageData()`, `getProjectilePreviewReservedFactor()`, `getUnresistedSkillDamage()`, and `getSkillEffectData()` keep runtime preview profiles, projectile reservation semantics, resistance-free damage math, and buff/transformation metadata separate so Examine never reads the selected opponent. Direct physical/Ki/hybrid skills, projectile `setStats()` paths, weapon projectiles, canonical melee, and raw Final Explosion BP/Force scaling remain distinct profiles.
- `showNexusCommandPrompt()` focuses the permanent side CMD input or opens the overlay CMD prompt. `focusNexusCommand()` is the Return-key router for both layouts.
- `showNexusPlayerMenu(section)` opens the requested player-menu section; `toggleNexusPlayerMenu(section)` closes it when the matching Inventory, Skills, Sense, or World icon is pressed again.
- `removeActionHud()` detaches runtime screen objects and closes the replacement player menu during client/HUD cleanup.

### src/Code/UI/HudLibrary.dm

- `getNexusHudLibraryIcon()` creates and caches scalable bolted, square panel/button surfaces used by native HUD windows.
- `getNexusBrowserAtomIconResource()` exports and caches the real runtime sprite used by an object so browser Inventory and Skills remain visually identical to their in-game counterparts.
- `getNexusCharacterPortraitIcon()` flattens the character body, underlays, and overlays into the Character portrait, so equipped clothing and transformation layers are visible instead of exporting a naked base icon.
- `prepareNexusHudBrowserResources(viewer)` sends both local Silkscreen font weights once per client before a native-HUD browser is opened.
- `getNexusHudBrowserCss(theme)` provides the embedded `Nexus Silkscreen` font and scoped native-HUD components (`hud-frame`, `hud-card`, `hud-button`, `hud-tab`, `hud-panel`, and `hud-sprite`) in bronze player or blue admin palettes. It must be used through `body.nexus-hud`; it must not become an unscoped global override.
- `getNexusRpgBrowserCss()` remains the legacy shared rustic layer for creation, emote, log, hotkey, inspector, reward, and item windows that have not moved to the scoped native-HUD components.
- `datum/NexusHudWindow` owns a client's modal screen objects, provides consistent text/button construction, validates the clicking owner, and removes every object during close or disconnect.
- `/obj/HudWindow` forwards opaque action identifiers to its owning HUD window controller.
- `datum/NexusChatHud` renders the four-channel chat, paging, composition, personal-log actions, and hide control in either the HudLib overlay or `nexuschatwindow.chat`. Its channel and action controls are text-only; the four footer actions share the entire available width equally. Every message is rendered in its own block, and `closeNexusLegacyChatMarkup()` closes unmatched legacy formatting tags in stack order. The footer appears below messages through flex ordering but precedes untrusted legacy message fragments in source order, so malformed chat HTML cannot reparent or restyle its buttons. `buildHtml()` applies the player-facing bronze asset contract instead of maintaining a second basic chat theme. `attachSidePanel()` shares the right pane with native tabs; its deferred, generation-checked browser refresh waits until BYOND has finished reparenting the pane so the chat cannot remain blank. `attachOverlay()` returns the full width to the map.
- `datum/NexusInterfaceSettings` switches layouts, independently enables the Skills, Other, Items, World, and Admin legacy categories, and provides nudge, exact-coordinate, and reset controls for the lower bars/Sense stack and main vitals display. `showNexusInterfaceSettings()` is reachable through Interface Layout in the classic Settings menu.
- `client/proc/operator<<()` diverts untargeted gameplay text into the HudLib All feed while preserving non-text output and explicitly targeted controls.
- `applyNexusInterfaceLayout()` and `hideNexusLegacyInterface()` reconcile the configured panes while keeping obsolete output windows detached.

### src/Code/UI/MapZoom.dm

- `getNexusMapZoomPlanes()` lists only world-space render planes; the dedicated fixed-HUD plane is intentionally excluded.
- `getNexusMapRenderWidth()`, `getNexusMapRenderHeight()`, and `getNexusMapZoomScale()` keep live characters inside a stable maximum-sized render envelope, preserve the unrestricted title view, and convert the saved logical view width into a world-plane scale.
- `client/initializeNexusMapZoom()`, `applyNexusMapZoom()`, and `removeNexusMapZoom()` own per-client plane masters for map-only mouse-wheel zoom. The existing lighting plane receives the same transform, while HUD objects, prompts, maptext inputs, and screen effects remain on `NEXUS_FIXED_HUD_PLANE`.
- `nexusMouseWheelCanZoomMap()` prevents wheel events over fixed HUD atoms or non-map controls from changing the map scale.
- `/obj/NexusMapZoomPlaneMaster` keeps world mouse input enabled, avoids applying `client.color` twice, and uses pixel sampling so transformed sprites remain crisp.

### src/Code/UI/MusicLibrary.dm

- `datum/NexusMusicLibraryWindow` owns the scrollable personal/server track catalog, upload feedback, PENDING/READY compatibility state and duration, storage/cooldown status, mute state, rename/delete confirmation, and nearby playback controls.
- `canUse()` binds every Topic action to the live character, current client window pointer, captured account ckey, and current `usr`. Every rendered link also carries a generation, so stale pages cannot replay destructive actions.
- Upload uses a native DM `input() as file|null`, never an HTML file input. The controller revalidates the window, client, one-use upload ticket, authorized byte length, account library, track hash, and quota after every yielding prompt. New files remain PENDING until a muted native DreamSeeker compatibility probe reports a matching resource and a duration of at most five minutes; timeout, cancellation, hash drift, owner changes, and invalid duration all fail back to PENDING.
- Rename and delete resolve the opaque track ID only through the captured account library, then re-resolve it and compare the expected hash after `input()` or `alert()` returns.
- `showNexusMusicLibrary()` and `toggleNexusMusicLibrary()` preserve the existing `Play_Music` verb and `/obj/Play_Music` hotkey contract. The dedicated browser uses its explicit CLOSE action (`can_close=false`) so a native X cannot strand a live controller or reopen a hidden window after validation. `client/Del()` deletes the controller without occupying the shared modal `NexusHudWindow` slot.
- The interface exposes Upload OGG, Validate, Play Nearby, Stop For Me, Stop My Broadcast, Mute/Unmute, Rename, Delete, and the seven pre-existing server tracks. PLAY NEARBY is never rendered for a PENDING personal track, and the domain playback wrapper enforces the same rule independently of the browser. The interface never displays internal paths or original filenames.

### src/Code/UI/SavePlayerSettings.dm

- `save_player_settings()` and `load_player_settings()` persist the selected interface layout, all five native-tab category switches, the overhead-vitals offsets, and the main-panel screen position.

### src/Code/UI/UIStuff.dm

- `datum/NexusCharacterSelect` sends and renders the canonical logo, then validates three independent character slots with Create, Enter World, and confirmed Delete actions. It remains visible when creation or loading is rejected and closes only after the requested transition succeeds.
- `DisplayTitleScreen()` uses the same transparent primary-logo PNG for the classic map title. Initial login is intentionally silent; it must not start a repeating music channel.
- `ShowNexusLoginPrompt()` now opens the slot selector; `NewClicked(slot)` and `LoadClicked(slot)` bind the selected slot before invoking creation or persistence.
- `returnToNexusReconnectLobby()` saves a reattached live character, performs normal volatile combat cleanup, transfers the client to a fresh lobby mob, and deletes the stale body without running the normal Logout path twice.
- `getNexusInitialConnectViewWidth(current_mob, title_view_width)` returns the large title-screen width only for lobby mobs; a live character receives zero so `DetermineViewSize()` restores and clamps its existing preference.
- `getNexusApplicationIconSkinValue()` returns the quoted compiled resource name expected by the skin API, and `applyNexusApplicationIcon()` keeps `mainwindow` synchronized with the static DMF declaration after client creation.
- `ToggleTabs()` is retained as a hidden hotkey compatibility entry but opens Character instead of restoring the removed tab pane.

### src/Code/UI/AdminInspector.dm

- `showNexusAdminInspector(target)` opens a level-3-admin-only replacement for the raw EDIT window.
- `datum/NexusAdminInspector/buildHtml()` groups editable variables by identity, combat, progression, appearance, position, collection, system, or other and exposes live text/category filtering.
- `datum/NexusAdminInspector/editVariable(variable_name)` preserves the legacy number/text/file/list/null edit choices and admin logging.
- `datum/NexusAdminInspector/buildListHtml(variable_name)` exposes every entry in a legacy list instead of truncating it to the table preview and only resolves associative values for safe text keys.
- `datum/NexusAdminInspector/editMutation(mutation_id)` adds, updates, or removes a character mutation through the dedicated mutation panel.

### src/Code/UI/CharacterSheet.dm

- `showCharacterSheet()` opens a client-owned `datum/NexusCharacterSheetWindow`, exports the current sprite portrait, and starts its bounded live lifecycle.
- `datum/NexusCharacterSheetWindow` sends one placeholder-backed HTML snapshot, retains a heartbeat only for lifecycle cleanup, and never replaces the open document automatically. Refresh is an explicit player action and preserves the stored document scroll position.
- `buildCharacterSheetHtml(portrait_resource, topic_source, restore_scroll_y)` renders identity, vitals, effective and raw combat stats, growth, Technology, professions, Knowledge, Lethal pressure, owned Milestones, and learned skills as one bronze native-HUD dossier. Its portrait is a flattened copy of the current in-game appearance, including clothes, equipment, hair, and transformation overlays; learned techniques use their real runtime sprites. Unowned Milestones are omitted, and nested content scroll areas are deliberately avoided so refresh restoration has one authoritative scroll position.
- Admins receive a direct link from Character to the structured inspector.

### src/Code/UI/DamageIndicators.dm

#### proc/formatNexusCombatAmount
- Signature: `proc/formatNexusCombatAmount(amount)`
- Inputs: numeric combat amount.
- Purpose: Format the actual applied amount to hundredth precision for both floating damage indicators and combat-log messages.
- Returns: a compact decimal string without exposing BYOND floating-point noise.
- Side effects: none.

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
- Purpose: Format the exact applied hit to hundredth precision, position it, animate it, and release one damage indicator. Multi-hit attacks show each hit separately while the combat log additionally batches their total.
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

### Nexus player-menu action routing

- Skill and Sense links use one `subject` reference contract, with legacy `skill` and `target` parameters accepted by the handler.
- `NexusPlayerMenu.useOwnedSkill()` delegates to `executeNexusHotkeyAction()`, preserving the same ownership, `can_hotbar`, handler, and caller semantics as keyboard activation.
- Skill use/examination requires the object to remain directly owned; Sense targeting/examination revalidates the target's actual area and `CanSense()` state rather than depending on a possibly stale area list.
- Dynamic inventory details are read through a variable-name indirection so examining an item without a subtype-only durability variable cannot raise an undefined-variable runtime.

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
- Purpose: Build or reuse a thin 32x3 health icon with dark background and proportional colored fill.
- Returns: cached icon.
- Side effects: initializes a cache entry on first use.

#### proc/getOverheadVitalIcon
- Signature: `proc/getOverheadVitalIcon(percent, accent_color)`
- Inputs: percentage and status accent color.
- Purpose: Build the shared 32x3 overhead Energy and Willpower indicators.
- Returns: cached icon.
- Side effects: initializes a cache entry on first use.

#### proc/getVitalsPanelIcon
- Signature: `proc/getVitalsPanelIcon()`
- Inputs: None.
- Purpose: Build or reuse the clean 296x136 translucent backdrop for the draggable vitals panel.
- Returns: cached icon.
- Side effects: initializes the panel icon on first use.

#### proc/getVitalsBarIcon
- Signature: `proc/getVitalsBarIcon(percent, accent_color)`
- Inputs: percentage and accent color.
- Purpose: Build or reuse a 168x19 native progress-bar icon with proportional fill.
- Returns: cached icon.
- Side effects: initializes a cache entry on first use.

#### proc/getPowerGaugeIcon
- Signature: `proc/getPowerGaugeIcon(percent, over_limit)`
- Inputs: normalized soft-cap progress and over-limit state.
- Purpose: Build either lateral power gauge, switching from violet to red above the efficient limit.
- Returns: cached 7x72 icon.
- Side effects: initializes a cache entry on first use.

#### proc/getActiveModifiersPanelIcon
- Signature: `proc/getActiveModifiersPanelIcon()`
- Inputs: None.
- Purpose: Build or reuse the 296x38 rustic strip displayed directly above the main vitals panel while temporary modifiers are active.
- Returns: cached icon.
- Side effects: initializes the shared modifier-strip icon on first use.

#### mob/proc/getNexusActiveHudModifiers
- Signature: `mob/proc/getNexusActiveHudModifiers()`
- Inputs: None.
- Purpose: Aggregate active transformations, Mystic, preset/custom buffs, Ultimate Buffs, Kaioken, Limit Breaker, Giant/Great Ape, Third Eye, Majin, Overdrive, Fire Fist, and steroids using their authoritative balance variables. Additive BP changes become one effective ratio instead of being multiplied together.
- Returns: an associative list containing ordered active names and combined stat multipliers.
- Side effects: none.

#### mob/proc/getNexusActiveHudModifierSummary
- Signature: `mob/proc/getNexusActiveHudModifierSummary(maximum_stats = 8)`
- Inputs: maximum number of stat fragments to render.
- Purpose: Produce a compact title and at most two stat rows for the active-modifier strip, prioritizing BP, Speed, Recovery, Regeneration, and Energy. Long custom names and oversized stat sets are compacted; each returned row is rendered by an independently positioned maptext object so Dream Seeker cannot collapse the lines together.
- Returns: an associative render summary.
- Side effects: none.

#### proc/normalizeNexusHudOffset
- Signature: `proc/normalizeNexusHudOffset(value)`
- Inputs: requested world-space HUD offset.
- Purpose: Round and clamp a player-selected overhead offset to the supported -128 through 128 pixel range.
- Returns: normalized integer offset.
- Side effects: none.

#### proc/getNexusOverheadVitalsBasePixelX
- Signature: `proc/getNexusOverheadVitalsBasePixelX(mob/owner)`
- Inputs: displayed character.
- Purpose: Resolve the account-configured horizontal offset shared by the lower vitals and Sense-percentage stack.
- Returns: world-space pixel X offset.
- Side effects: none.

#### proc/getNexusOverheadVitalsBasePixelY
- Signature: `proc/getNexusOverheadVitalsBasePixelY(mob/owner)`
- Inputs: displayed character.
- Purpose: Position the bottom Energy row beneath the owner's sprite origin with the configured vertical offset.
- Returns: world-space pixel Y offset.
- Side effects: none.

#### proc/getNexusTypingIndicatorPixelY
- Signature: `proc/getNexusTypingIndicatorPixelY(mob/owner)`
- Inputs: displayed character.
- Purpose: Account for the icon's transparent cell padding so the visible Typing bubble sits below Say text and above the owner's sprite, independently from the lower-bar offset.
- Returns: world-space pixel Y offset for the typing actor.
- Side effects: none.

#### proc/getNexusOverheadFeedbackPixelY
- Signature: `proc/getNexusOverheadFeedbackPixelY(mob/owner)`
- Inputs: displayed character.
- Purpose: Resolve the sprite-height-aware Say position above the Typing bubble and character.
- Returns: world-space pixel Y offset.
- Side effects: none.

#### proc/getNexusOverheadPercentagePixelY
- Signature: `proc/getNexusOverheadPercentagePixelY(mob/owner)`
- Inputs: displayed character.
- Purpose: Position the 12-pixel Sense percentage one clear pixel below the bottom Energy row.
- Returns: world-space maptext Y offset.
- Side effects: none.

#### mob/proc/setNexusOverheadVitalsOffset
- Signature: `mob/proc/setNexusOverheadVitalsOffset(new_x, new_y)`
- Inputs: requested horizontal and vertical pixel offsets.
- Purpose: Apply a player's lower-stack placement and immediately realign the active Willpower, Health, and Energy bars; Sense readouts follow on refresh.
- Returns: none (implicit).
- Side effects: updates persistent preference variables and live world-space HUD actors.

#### mob/proc/setNexusMainVitalsPosition
- Signature: `mob/proc/setNexusMainVitalsPosition(new_x, new_y)`
- Inputs: requested lower-left screen coordinates.
- Purpose: Apply a non-negative main-panel position and synchronize an active panel.
- Returns: none (implicit).
- Side effects: updates persistent preference variables and `screen_loc`.

#### mob/proc/initializeVitalsHud
- Signature: `mob/proc/initializeVitalsHud()`
- Inputs: None.
- Purpose: Attach the compact overhead Health, Energy, and Willpower bars and initialize the lower-left main vitals panel for playable characters.
- Returns: none (implicit).
- Side effects: updates `vis_contents`, `client.screen`, and hides the obsolete DMF Bars window.

#### mob/proc/initializeMainVitalsHud
- Signature: `mob/proc/initializeMainVitalsHud()`
- Inputs: None.
- Purpose: Create the lower-left panel with a centered enlarged character, four vitals rows, lateral power gauges, a percentage readout, and a contextual active-modifier strip above it.
- Returns: none (implicit).
- Side effects: creates one client-owned screen-object tree and synchronizes visibility with `client.show_bars`.

#### mob/proc/updateMainVitalsHud
- Signature: `mob/proc/updateMainVitalsHud()`
- Inputs: None.
- Purpose: Refresh the centered character, right-aligned `(current Energy) percentage%`, raw power percentage, powerup soft-cap state, and combined temporary stat modifiers. The modifier strip stays transparent in base state.
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
- Purpose: Refresh the Health, Energy, and Willpower states and vertical positions of the overhead HUD.
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
- Purpose: Restore the owner's saved screen position and compose the centered character, two power gauges, percentage readout, and four labeled stat rows over the panel root.
- Returns: none (implicit).
- Side effects: populates `vis_contents`.

#### obj/NexusHud/VitalsPanel/proc/update
- Signature: `update(mob/owner)`
- Inputs: owning player.
- Purpose: Calculate Willpower, Health, Energy, Stamina, raw `BPpcnt`, and the efficient powerup threshold.
- Returns: none (implicit).
- Side effects: updates child screen objects.

#### obj/NexusHud/VitalsPanel/proc/moveToMouse
- Signature: `moveToMouse(screen_location)`
- Inputs: current mouse screen location.
- Purpose: Move the panel from its stored drag origin while keeping it inside the left/bottom screen edges.
- Returns: none (implicit).
- Side effects: updates panel screen position.

#### obj/NexusHud/VitalsPanel/proc/setScreenPosition
- Signature: `setScreenPosition(new_x, new_y, update_owner = TRUE)`
- Inputs: absolute lower-left pixel coordinates and whether to copy them to the owner preference.
- Purpose: Store the panel position using BYOND's icon-aware `LEFT` and `BOTTOM` anchors and retain player-driven changes.
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
- Purpose: Render one row of the 32x3 lower display ordered Willpower, Health, and Energy from top to bottom; Health changes color at its existing thresholds.
- Returns: none (implicit).
- Side effects: swaps the cached world-space icon.

#### obj/NexusHud/VitalsPanel/MouseDrag
- Signature: `MouseDrag(over_object, src_location, over_location, src_control, over_control, params)`
- Inputs: standard BYOND mouse-drag context.
- Purpose: Drag the client-owned vitals panel directly by its translucent background.
- Returns: none (implicit).
- Side effects: updates the panel position.

#### obj/NexusHud/VitalsPanel/MouseDrop
- Signature: `MouseDrop(over_object, src_location, over_location, src_control, over_control, params)`
- Inputs: standard BYOND mouse-drop context.
- Purpose: Finish direct panel placement and persist the resulting screen coordinates.
- Returns: none (implicit).
- Side effects: updates the panel position and exports player settings.

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
- Purpose: Restore legacy IDs, custom bindings, binding version, and the selected XKB keyboard layout.
- Returns: none (implicit).
- Side effects: see implementation.

#### mob/proc/Hotkey_server_backup_save
- Signature: `Hotkey_server_backup_save()`
- Inputs: None
- Purpose: Persist legacy IDs, custom bindings, binding version, and the normalized XKB keyboard layout.
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
- Signature: `canonicalNexusHotkey(base_key, use_ctrl = 0, use_shift = 0, use_alt = 0, tap_count = 1)`
- Inputs: allowlisted base key, modifier flags, and single/double activation count.
- Purpose: Produce stable combinations such as `CTRL+SHIFT+Numpad7` and `DOUBLE:Space`.
- Returns: canonical combination or null for an unsupported key.
- Side effects: none.

#### proc/getNexusKeyboardLayoutRows
- Signature: `getNexusKeyboardLayoutRows(layout_id)`
- Purpose: Return keyboard rows for normalized XKB-style profiles (`us`, `br`, `gb`, `fr`, `de`, and `us(dvorak)`).
- Returns: three keyboard rows; unsupported identifiers fall back to `us`.
- Side effects: none.

#### proc/getNexusUnixHotkeyName
- Signature: `getNexusUnixHotkeyName(combination)`
- Purpose: Present canonical BYOND keys using Unix/XKB labels such as `ctrl_l + kp_1` and `space + space`.
- Returns: display-only key combination.
- Side effects: none.

#### datum/NexusHotkeyAction
- Purpose: Define non-object actions with stable IDs, labels, availability predicates, repeat policy, and execution behavior.
- Current actions: eight Zanzoken directions available only while the player owns `/obj/Zanzoken`, plus eight universal Short Dash directions categorized as defensive actions.

#### mob/proc/initializeNexusHotkeys
- Purpose: Migrate positional legacy bindings, normalize the saved keyboard profile, initialize tap state, and rebuild client-local dynamic macros.
- Side effects: updates binding version and client macros.

#### mob/proc/getNexusHotkeyBindingIdForPress
- Signature: `getNexusHotkeyBindingIdForPress(trigger_combination, was_held = FALSE, press_time = world.time)`
- Purpose: Select the single binding immediately or the double binding when a second genuine press arrives within four ticks.
- Returns: canonical single or `DOUBLE:` binding ID.
- Side effects: updates per-key transient press timestamps; held-key repeats never count as a second tap.

#### mob/proc/resolveNexusHotkeyBinding
- Signature: `resolveNexusHotkeyBinding(combination)`
- Purpose: Resolve an available registered action or owned `can_hotbar` object at execution time.
- Returns: action datum, object, or null when unavailable.
- Side effects: none.

#### mob/proc/isNexusHotkeyObjectAvailable
- Signature: `isNexusHotkeyObjectAvailable(obj/hotkey_object)`
- Purpose: Revalidate object ownership, hotbar eligibility, special skill requirements, and trade-escrow state immediately before resolving or executing an object action.
- Returns: true only when the owned object may currently be invoked; items committed to an active trade offer return false.
- Side effects: none.

#### client/proc/syncNexusHotkeyMacros
- Purpose: Recreate modifier and non-static macros using `winset()`, with paired key-up handling.
- Supported: `CTRL`, `SHIFT`, `ALT`, independent numpad digits/operators, selected function keys, and utility keys.
- Side effects: replaces only client-local macros created by this system.

#### mob/proc/buildNexusHotkeyEditorHtml
- Purpose: Render the enlarged rustic action deck, draggable XKB-profile keyboard, Unix key labels, single/double activation controls, complete F-key row, navigation/editing block, visible arrow keys, independent numpad, and active binding summary without wrapping keyboard groups over one another.
- Security: actions are represented by server-issued opaque tokens and revalidated in `Topic()`.

#### datum/NexusHotkeyEditor/Topic
- Purpose: Validate bind, unbind, layout, clear, import, and close events sent by the in-game browser editor.
- Side effects: saves each change immediately and refreshes macros/editor state.

#### mob/proc/showNexusHotkeyEditor
- Purpose: Stop held input and open the new editor used by F5.
- Side effects: opens `NexusHotkeys` and suppresses gameplay key dispatch while active.

#### mob/proc/toggleNexusHotkeyEditor
- Purpose: Open the hotkey editor or close it when its active shortcut icon is pressed again.
- Side effects: delegates to the normal show/hide lifecycle so movement macros are restored on close.

### src/Code/UI/RPWindow.dm

#### proc/renderNexusEmoteMarkup
- Signature: `renderNexusEmoteMarkup(raw_text)`
- Purpose: Convert the editor's bracket markup for color, bold, italic, underline, and line breaks into balanced safe HTML while encoding raw HTML.

#### proc/buildNexusEmoteMessage
- Signature: `buildNexusEmoteMessage(character_name, rendered_text, emote_mode = "Normal")`
- Purpose: Compose the IC/log representation with an explicit blank line between the roleplay title and body while preserving safe inline colors.

#### proc/getNexusEmoteColorSwatchesHtml
- Signature: `getNexusEmoteColorSwatchesHtml()`
- Purpose: Build the nine editor palette buttons with priority inline backgrounds so the shared rustic button theme cannot replace their visible colors.

#### datum/NexusEmoteEditor
- Purpose: Provide a resizable two-pane emote editor with visible theme-safe color swatches, custom color selection, formatting controls, counters, RP mode selection, and live preview.

#### mob/proc/showNexusEmoteEditor
- Signature: `showNexusEmoteEditor()`
- Purpose: Open a fresh editor owned by the current client.

#### mob/proc/submitNexusEmote
- Signature: `submitNexusEmote(raw_text, emote_mode = "Normal")`
- Purpose: Validate and render an emote, send it through the IC channel, and persist its normal or Character Development RP record.

#### datum/NexusPlayerLogViewer
- Purpose: Display searchable All, Combat, IC, and OOC tabs using both the current persisted file and entries waiting to be flushed.

#### mob/proc/showNexusPlayerLogs
- Signature: `showNexusPlayerLogs(channel = "all")`
- Purpose: Open the current player's private channel log viewer.

#### mob/proc/ViewEmoteWindow
- Signature: `ViewEmoteWindow(mob/admin, mob/player, unwritten, type = "Emote", path = "emotelogs", overwrite_ckey = "none")`
- Inputs: mob/admin, mob/player, unwritten, type = "Emote", path = "emotelogs", overwrite_ckey = "none"
- Purpose: Render persisted and unwritten RP entries inside a complete HTML document without overriding their inline text colors.
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
- Purpose: Open the searchable private log viewer on its All tab.
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
- Purpose: Display a target's structured public Character Profile through the shared bronze UI, including self-authored title/name, verified account identity, a byte-preserved PNG/JPEG upload or composite runtime portrait, and allowlisted rich biography markup.
- Returns: none (implicit).
- Side effects: serves a bounded opaque, format-correct portrait resource with live-sprite fallback and opens `NexusPlayerProfile`; repeated requests are briefly throttled.

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
- Purpose: Save player settings, including interface layout, enabled native tabs, overhead-vitals offsets, and the main-vitals screen position.
- Returns: none (implicit).
- Side effects: mutates game state and/or world resources.

#### mob/proc/load_player_settings
- Signature: `load_player_settings()`
- Inputs: None
- Purpose: Load player settings and normalize the saved HUD offsets and screen coordinates before HUD initialization.
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
- Purpose: Toggle the modern `NexusBuildWindow` from the default `M` hotkey or top Build icon.
- Returns: none (implicit).
- Side effects: closes the legacy `TabHolder`, opens the browser catalog, and restores map focus on close.

#### datum/NexusBuildWindow
- Purpose: Render the unified build catalog for Floors, Ground, Roofs, Walls, Decor, Trees, Other, Custom, and Science.
- Navigation: category tabs, category search, 48-card pages, live resources, active-blueprint state, and direct create/edit/delete controls for owned custom decor.
- Performance: only the active page is rendered; extracted DMI states are cached globally and transferred once per client session.
- Placement: ordinary cards route through `selectBuildBlueprint()`, Science cards through `TryCreateScienceItem()`, and Custom cards through the existing custom-decor validation path.

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

The Nexus HUD, HudLib windows, overhead vitals, damage numbers, and Nexus technique announcements render on plane 20. The per-client lighting composition uses plane 15, so darkness and glows affect the game world without obscuring interaction or status text.

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
