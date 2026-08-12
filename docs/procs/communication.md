# Communication

## Overview
Channel-routed chat, OOC, LOOC, emotes, telepathy, player-visible logs, combat damage summaries, roleplay Progression XP awards, and account-scoped player music. Also includes spam control and simple text utilities.

## Files
- `src/Code/Communication/Communication.dm`
- `src/Code/Communication/Languages.dm`
- `src/Code/Communication/MediaAndDescriptions.dm`
- `src/Code/Communication/ProfileImages.dm`
- `src/Code/Communication/PlayerMusic.dm`

## Player description security contract

- `Set Player Description` opens `datum/NexusPlayerDescriptionEditor`, a structured bronze Profile Builder with separate profile name, title, portrait angle, and 3,000-character biography fields. The preview combines all fields into the same card players see through `View Description`.
- The portrait source can be the live character composite in one of four cardinal angles or one uploaded PNG/JPEG. Profile art is restricted before transfer to `1..400 KiB`, bound to a one-use editor/account/slot ticket, limited after a transient decode probe to `256x256`, fingerprinted, and stored byte-for-byte under an immutable account/slot/hash generation. The browser receives that same raw file under an opaque hash-versioned alias with the validated `.png` or `.jpg` suffix; the original filename and filesystem path are never published.
- Direct player-controlled image URLs are never rendered or fetched. This prevents profile viewers from being sent to tracking hosts and prevents Dream Daemon from becoming an SSRF/download proxy. Because raw uploads intentionally retain their original bytes, they may also retain EXIF/GPS/ICC metadata; the editor warns players to remove private metadata before upload. BYOND's native decode probe verifies compatibility and dimensions but is not a sanitizer. Deployments that need a hardened untrusted-image boundary should validate uploads with an isolated, resource-limited sidecar before Dream Daemon publishes them.
- Biography markup reuses the roleplay editor's server-side allowlist: balanced `[b]`, `[i]`, `[u]`, and `[color=#RRGGBB]` tags are rendered, while raw HTML and malformed/unknown tags remain non-executable. `normalizeNexusPlayerDescription()` also removes legacy HTML, normalizes control characters, and enforces the server-side limit. Saves created before the Profile Builder retain bracket tags as literal text until the player explicitly saves through the new editor, which advances `player_profile_markup_version`.
- Profile name and title are bounded single-line text. Values are escaped specifically for their HTML text or single-quoted attribute context, and the public card always identifies the actual in-game name and verified BYOND account separately from self-authored profile fields.
- The editor Topic accepts actions only from its owning live character and current controller, rejects stale render generations and Imitation state, serializes save/upload/delete requests, preserves normalized drafts across the native file prompt, avoids unchanged writes, and uses short save/open/upload throttles. Profile fields and art metadata participate in normal character serialization and are reread from the slot save before success is reported; a failed verification restores the previous in-memory state and keeps both immutable image generations when durable rollback cannot be confirmed. Raw generations are isolated by registered account and character slot under `data/ProfileImages/`, and older generations are removed only after the new metadata has been verified. Slot deletion, admin deletion, Hakai purge, old-save purge, and full wipe remove every generation. Public views are throttled, raw-image failures fall back to the live sprite in the browser, and opaque resource IDs do not embed account names. Disconnect and reconnect handoff destroy the editor controller and invalidate pending tickets.

## Player music security contract

- The single `client/AllowUpload()` broker routes mutually exclusive profile-art, music, and explicitly marked legacy icon prompts. Profile and music require one-use controller/account tickets; legacy player icon pickers receive one bounded, one-use authorization around their native prompt; admins retain the trusted parent path. With no authorized prompt, ordinary-player uploads fail closed instead of invoking BYOND's permissive parent behavior. Music rejects non-OGG filenames and files outside `1 KiB..5 MiB` before transfer, while profile-art tickets enforce their independent PNG/JPEG policy.
- `inspectNexusPlayerMusicUpload()` rechecks the received byte length and computes a SHA-1 fingerprint. Dream Daemon cannot safely parse or transcode arbitrary OGG binaries in DM, so extension and fingerprint checks are preflight/integrity controls, not codec certification.
- Every personal track starts quarantined. `client/validateNexusPlayerMusicFile()` performs a muted, serialized compatibility probe on reserved channel 1023 and accepts only matching-file `SoundQuery()` telemetry between 1 and 300 seconds. The window, account, track ID, generation, hash, file size, and SHA-1 are revalidated after the client round trip. `SoundQuery()` is uploader-client telemetry, not an authoritative sanitizer; hostile deployments should add an isolated server-side transcoder before treating uploaded media as trusted.
- `datum/NexusPlayerMusicLibrary` persists at most five tracks and 20 MiB per registered account under `data/PlayerMusic/<ckey>/`. Original filenames and browser parameters never form a server path; every blob path is derived from the account ckey plus a 32-character server-generated ID. A track becomes READY only when duration, validation time, current validation-policy version, and validation hash all match its current content fingerprint. Stale or incomplete validation metadata is cleared back to PENDING during load instead of hiding the stored track.
- Account/global daily byte budgets, a 1 GiB persistent archive ceiling, upload/playback/validation cooldowns, a bounded in-memory library cache, and a global validation-start throttle bound transfer, storage, hashing, and decoder-probe work. On first use after startup, the persistent byte counter is reconciled against bounded enumeration of server-generated OGG paths, so orphaned blobs and interrupted metadata/counter writes still consume the archive ceiling. Upload state is client-wide and one-shot so overlapping or stale file prompts fail closed instead of falling back to BYOND's permissive default `AllowUpload()` behavior.
- `client/startNexusPlayerMusic()` uses reserved channel 1024 with `SOUND_STREAM`; one per-client expiry worker forcibly ends the session after five minutes. Stopping or muting this channel leaves combat and interface sounds untouched.
- `mob/broadcastNexusCustomTrack()` is the only personal-track playback entry point. It resolves the track through the broadcaster's registered-account library, requires READY metadata, and re-hashes the stored file before delegating to `mob/broadcastNexusPlayerMusic()`. Guests may use bundled server tracks with an in-memory cooldown but cannot create persistent upload directories. Nearby playback reaches only unmuted clients in `player_view(22, source)`; starting a new broadcast stops that account's previous broadcast first.
- The former Vocaroo/HTML audio verb was removed. Player-supplied URLs are never rendered or fetched.

## integrated language adaptation

- `syncNexusLanguages(silent)` migrates racial languages and validates the currently spoken language.
- `renderSpokenLanguageFor(listener, raw_text, allow_learning)` calculates speaker/listener fluency, translation items, exposure gains, and the listener-specific rendered text.
- `renderNexusLanguageText(raw_text, language_id, understanding)` deterministically replaces unknown words with language-specific syllables while preserving fully understood words.
- `teachNexusLanguage()` provides a cooldown-limited nearby lesson from a speaker with at least 50% mastery.
- `mob/verb/languages()` selects the spoken language, starts a lesson, or creates the Custom Language milestone reward.
- Local Say, Whisper, and Communicator transmissions carry a visible language label and no longer leak one shared unmodified message to every listener.

## Proc Reference

### mob/proc/receiveNexusChatMessage(message, channel = "all", source_key, write_log = TRUE)
- Purpose: Route one message to its HudLib channel. IC and OOC also appear in All, while Combat remains isolated so mechanical output does not bury roleplay.
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
- Side effects: creates a temporary `NexusCombatLogBatch`, routes the result to the isolated Combat feed, and persists it in both participants' logs.

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

### mob/verb/Countdown(Seconds, message, final_message)
- Purpose: Broadcast one bounded public wait countdown with optional start/end messages.
- Inputs: a finite duration clamped to 1-600 seconds and optional text limited to 200 characters.
- Security: only one countdown may run per player, at most 64 may run globally, reuse is throttled, disconnect stops the worker, and all player text is HTML-escaped before routed chat/log delivery. The former client-controlled KO bypass was removed.
- Side effects: sleeps in bounded intervals, sends routed OOC messages to nearby players, and writes escaped chat logs.

`normalizeNexusCountdownSeconds()`, `sanitizeNexusCountdownText()`, and `broadcastNexusCountdown()` own the duration, text, and delivery boundaries used by the verb.

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
- Purpose: Open or close the account music-library interface while retaining the legacy verb path and hotkey binding.
- Side effects: creates or deletes `datum/NexusMusicLibraryWindow`; playback occurs only through authorized window actions.

### mob/verb/Stop_Player_Music()
- Purpose: Stop the dedicated player-music channel for the caller without interrupting game sound effects.
- Side effects: increments the listener generation so an older five-minute timer cannot stop a newer track.
