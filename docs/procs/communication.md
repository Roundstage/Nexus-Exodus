# Communication

## Overview
Chat, OOC, LOOC, emotes, telepathy, and chat logging. Also includes spam control and simple text utilities.

## Files
- `src/Code/Communication/Communication.dm`

## Proc Reference

### mob/proc/ChatLog(info, the_key)
- Purpose: Buffer a formatted HTML chat entry for later file write.
- Inputs: `info` (HTML string), `the_key` (speaker label).
- Side effects: updates `last_chatlog_write`, appends to `unwritten_chatlogs`.

### mob/proc/Write_chatlogs(allow_splits = 1)
- Purpose: Flush buffered chat entries to `data/Logs/ChatLogs/`.
- Inputs: `allow_splits` toggles log file rollover.
- Side effects: writes to disk, clears `unwritten_chatlogs`, calls `Split_File` when enabled.

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
- Purpose: Show a "typing" overlay effect.
- Side effects: mutates `overlays`, sleeps briefly.

### mob/proc/Remove_Say_Spark()
- Purpose: Remove the typing overlay.

### mob/proc/End_Say()
- Purpose: Re-enable speech after a delay.
- Side effects: sets `can_say`, schedules `Remove_Say_Spark`.

### mob/proc/Spam_Check(Message)
- Purpose: Rate-limit OOC/LOOC/chat to prevent spam.
- Inputs: `Message`.
- Returns: truthy when the message should be blocked.
- Side effects: increments `Spam`, updates `recent_ooc`, auto-mutes offenders.

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
- Purpose: Send OOC to all players with spam checks and name formatting.
- Inputs: `msg` (optional; prompts if empty).
- Side effects: calls `Spam_Check`, broadcasts formatted HTML.

### mob/verb/OOC(msg)
- Purpose: Alias for `GlobalSay`.

### mob/verb/LOOC(msg)
- Purpose: Send local OOC (short range).
- Inputs: `msg` (optional; prompts if empty).
- Side effects: rate-limits with `can_say`, logs chat, triggers troll response.

### mob/verb/Whisper(msg)
- Purpose: Emit a whisper to nearby players; only fully audible at close range.
- Inputs: `msg` (optional; prompts if empty).
- Side effects: logs chat for listeners within 2 tiles.

### mob/verb/ToggleNekoCollar()
- Purpose: Toggle whether a neko collar appends a tilde to speech.

### mob/verb/Say(msg)
- Purpose: Standard local speech with optional neko collar suffix.
- Inputs: `msg` (optional; prompts if empty).
- Side effects: sends HTML to `Say_Recipients`, logs chat.

### mob/verb/Think(msg)
- Purpose: Send a local "thought" message formatted in italics.
- Inputs: `msg` (optional; prompts if empty).
- Side effects: sends and logs to `Say_Recipients`.

### mob/verb/SayCooldown()
- Purpose: Short speech cooldown helper (used by other systems).

### mob/verb/Emote(msg)
- Purpose: Broadcast a styled emote block to nearby players.
- Inputs: `msg` (optional; prompts if empty).
- Side effects: logs chat and posts to RP windows depending on type.

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
