# Communication

## Overview
Channel-routed chat, OOC, LOOC, emotes, telepathy, player-visible logs, combat damage summaries, and roleplay Progression XP awards. Also includes spam control and simple text utilities.

## Files
- `src/Code/Communication/Communication.dm`
- `src/Code/Communication/Languages.dm`
- `src/Code/Communication/MediaAndDescriptions.dm`

## RPT language adaptation

- `syncNexusLanguages(silent)` migrates racial languages and validates the currently spoken language.
- `renderSpokenLanguageFor(listener, raw_text, allow_learning)` calculates speaker/listener fluency, translation items, exposure gains, and the listener-specific rendered text.
- `renderNexusLanguageText(raw_text, language_id, understanding)` deterministically replaces unknown words with language-specific syllables while preserving fully understood words.
- `teachNexusLanguage()` provides a cooldown-limited nearby lesson from a speaker with at least 50% mastery.
- `mob/verb/languages()` selects the spoken language, starts a lesson, or creates the Custom Language milestone reward.
- Local Say, Whisper, and Communicator transmissions carry a visible language label and no longer leak one shared unmodified message to every listener.

## Proc Reference

### mob/proc/receiveNexusChatMessage(message, channel = "all", source_key, write_log = TRUE)
- Purpose: Route one message to the HudLib All feed and, when applicable, its IC, OOC, or Combat feed.
- Inputs: formatted message, normalized channel, optional source key, and logging toggle.
- Side effects: refreshes the active native chat HUD and buffers the message in the player's combined and channel-specific logs.

### mob/proc/ChatLog(info, the_key, channel = "all")
- Purpose: Buffer a formatted HTML entry for the combined log and its IC, OOC, or Combat log.
- Inputs: `info` (HTML string), `the_key` (speaker label), and channel identifier.
- Side effects: updates `last_chatlog_write`, `unwritten_chatlogs`, and `nexus_unwritten_channel_logs`.

### mob/proc/Write_chatlogs(allow_splits = 1)
- Purpose: Flush combined and channel-specific chat entries to `data/Logs/ChatLogs/`.
- Inputs: `allow_splits` toggles log file rollover.
- Side effects: writes to disk, clears `unwritten_chatlogs`, calls `Split_File` when enabled.

### mob/proc/queueNexusCombatDamage(attacker, amount, attack_name = "Attack", resource_name = "Health")
- Purpose: Aggregate repeated hits from the same attack briefly, then publish one readable combat summary to attacker and target.
- Inputs: attacker, applied damage, attack label, and damaged resource.
- Side effects: creates a temporary `NexusCombatLogBatch`, routes the result to Combat and All, and persists it in both participants' logs.

### mob/proc/applyNexusCombatShieldDamage(amount, attacker, attack_name = "Attack")
- Purpose: Apply Ki shield damage while preserving the same attribution and logging used by Health damage.
- Returns: applied Ki damage.

### proc/buildNexusCombatLogMessage(...)
- Purpose: Format attack, attacker, target, hit count, total/average damage, and remaining Health or Ki for the combat feed using the same hundredth-precision formatter as world-space damage indicators.

### proc/Split_File(the_key)
- Purpose: Rotate the current chat log if it exceeds ~100 MB.
- Inputs: `the_key` (ckey for filename).
- Side effects: copies and deletes log files in `data/Logs/ChatLogs/`.

### proc/TimeStamp(Z)
- Purpose: Format a timestamp string for logs/UI.
- Inputs: `Z` (1 for `MM-DD-YY`, else `MM/DD/YY(hh:mm s)`).
- Returns: formatted text string.

### proc/Replace_Text(Text, Old_Word, New_Word)
- Purpose: Replace substrings by splitting/joining.
- Inputs: `Text`, `Old_Word`, `New_Word`.
- Returns: new text with replacements.

### proc/Text_2_List(text, sep)
- Purpose: Split text into a list using a separator.
- Inputs: `text`, `sep`.
- Returns: list of segments.

### proc/List_2_Text(list/L, sep)
- Purpose: Join a list of strings into text using a separator.
- Inputs: `L`, `sep`.
- Returns: concatenated string.

### mob/verb/Countdown(Seconds, message, final_message, isKoStuff)
- Purpose: Broadcast a timed wait countdown with optional start/end messages.
- Inputs: seconds, optional message overrides, optional KO flag.
- Side effects: sleeps, sends chat to nearby players, writes chat logs.

### mob/proc/Say_Spark()
- Purpose: Attach an individual typing actor below Say text and above the character using its sprite height, independently from the lower vitals/Sense stack.
- Side effects: replaces `nexus_typing_indicator` in `vis_contents` and sleeps briefly.

### mob/proc/Remove_Say_Spark()
- Purpose: Remove and delete the current typing actor.

### mob/proc/End_Say()
- Purpose: Re-enable speech and immediately clear typing feedback after submission or cancellation.
- Side effects: sets `can_say` and calls `Remove_Say_Spark`.

### proc/countNexusWords(raw_text)
- Purpose: Count whitespace-delimited words for the overhead Say limit.
- Returns: integer word count.

### mob/proc/showNexusSayText(message)
- Purpose: Display local Say text of up to 50 words above the speaking character as a temporary, following maptext actor positioned clear of all three overhead vitals rows.
- Returns: true when the text is displayed, otherwise false.
- Side effects: replaces the speaker's previous overhead text and fades it after a duration based on message length.

### mob/proc/Spam_Check(Message)
- Purpose: Rate-limit OOC/LOOC/chat to prevent spam.
- Inputs: `Message`.
- Returns: truthy when the message should be blocked.
- Side effects: increments `Spam`, updates `recent_ooc`, auto-mutes offenders.

### mob/proc/awardProgressionFromCommunication(message, source, weight)
- Purpose: Award bounded, word-based Progression XP for participating in chat and roleplay.
- Inputs: raw message, source label, and channel weight.
- Side effects: tracks cooldowns and a normalized message hash so rapid or repeated text cannot farm XP; emotes receive the highest cap, IC speech receives full weight, and OOC channels receive reduced weight.

### proc/Spammer(P)
- Purpose: Quick mute check by key.
- Returns: true if in `Mutes`.

### mob/Admin4/verb/crazy()
- Purpose: Toggle the global `Crazy` flag.

### mob/proc/Say_Recipients(distance = 44)
- Purpose: Resolve who should hear local chat (players/ships/pilots).
- Inputs: `distance` (view range).
- Returns: list of recipient mobs.
- Side effects: temporarily alters `sight` and `see_invisible`.

### mob/verb/Ignore_GlobalSay()
- Purpose: Toggle visibility of global OOC messages for the user.
- Side effects: flips `OOCon`.

### mob/verb/GlobalSay(msg)
- Purpose: Send OOC to all players with spam checks, name formatting, and reduced-weight Progression XP.
- Inputs: `msg` (optional; prompts if empty).
- Side effects: calls `Spam_Check`, broadcasts formatted HTML.

### mob/verb/OOC(msg)
- Purpose: Alias for `GlobalSay`.

### mob/verb/LOOC(msg)
- Purpose: Send local OOC (short range) and award reduced-weight Progression XP.
- Inputs: `msg` (optional; prompts if empty).
- Side effects: rate-limits with `can_say`, logs chat, triggers troll response.

### mob/verb/Whisper(msg)
- Purpose: Emit a whisper to nearby players, award IC Progression XP, and keep the full text audible only at close range.
- Inputs: `msg` (optional; prompts if empty).
- Side effects: logs chat for listeners within 2 tiles.

### mob/verb/ToggleNekoCollar()
- Purpose: Toggle whether a neko collar appends a tilde to speech.

### mob/verb/Say(msg)
- Purpose: Standard local speech with optional neko collar suffix and full-weight Progression XP.
- Inputs: `msg` (optional; prompts if empty).
- Side effects: sends HTML to `Say_Recipients`, logs chat, and displays messages of at most 50 words above the speaker.

### mob/verb/Think(msg)
- Purpose: Send a local "thought" message formatted in italics and award IC Progression XP.
- Inputs: `msg` (optional; prompts if empty).
- Side effects: sends and logs to `Say_Recipients`.

### mob/verb/SayCooldown()
- Purpose: Short speech cooldown helper (used by other systems).

### mob/verb/Emote(msg)
- Purpose: Open the rich emote editor, or submit the supplied text directly for compatibility with macros and command-line use.
- Inputs: optional `msg`.
- Side effects: routes the safe rendered emote to IC and All and posts it to the selected normal/development RP log.

### obj/Telepathy/verb/Hotbar_use()
- Purpose: Hotbar wrapper to invoke telepathy.

### obj/Telepathy/verb/Telepathy(mob/M in players)
- Purpose: Send a private telepathy message to a known energy signature.
- Inputs: `M` (target mob), message input prompt.
- Side effects: respects `can_telepathy`, logs messages for both users.

### mob/verb/Who()
- Purpose: Display an HTML list of connected players.
- Side effects: uses `browse()` to open a window.

### mob/verb/Play_Music()
- Purpose: Play a predefined music track for nearby players with a cooldown.
- Side effects: rate-limits by `last_play_music`, logs notification.
