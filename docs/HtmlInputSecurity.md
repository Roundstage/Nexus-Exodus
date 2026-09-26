# HTML input security review

Reviewed 2026-09-26. The review follows text, saved character/item values, submitted browser fields, editable documents, and uploaded media into `browse()`, chat HTML, `innerHTML`, maptext, and the BYOND browser/skin command bridge. Production saves and historical log files are not rewritten.

## Findings and changes

| Risk | Dangerous path | Change |
| --- | --- | --- |
| High: stored HTML injection in player and administrator browsers | Legacy `<<` messages and raw scouter messages entered `NexusChatBuffer`, then `ClassicHud.js` assigned the HTML to `innerHTML`. Object and character names also occur in many legacy messages. | Scouter text and affected identity fields are escaped. The shared chat renderer rebuilds only an inert formatting vocabulary before the buffer accepts the message. It also covers native lobby text output. |
| High: unescaped legacy form values; defensive attribute hardening | Legacy admin forms interpolated values directly into attributes and textareas. Other browser pages used the general `html_encode()` helper in attributes; runtime checks confirmed that pinned BYOND 516.1686 already escapes apostrophes, so those existing encoded sites were not confirmed quote-breakout vulnerabilities. | Legacy form values are encoded. Single-quoted attribute sites use the explicit `encodeNexusHtmlAttribute()` contract, now in `UI/HtmlSafety.dm`, with tests for both quote delimiters. |
| High: saved HTML executing when a log is reopened | Chat, emote and admin logs combined raw HTML; old disk files and pending entries were inserted into player/admin browser pages. Bug messages and runtime errors had direct browser sinks too. | New chat/emote/admin log entries are sanitized before persistence. Log viewers sanitize historical and pending content on read. Bug entries and the runtime-error viewer encode their contents as text. |
| High: active content supplied as an admin document | Notes, Story, Rules, Jobs and login notes could contain arbitrary HTML, including links to the game bridge. | Editable documents render through `buildNexusSafeDocument()`. Basic formatting remains; scripts, event attributes, forms, frames, images, links, document metadata and arbitrary CSS are removed. The gun guide's saved text uses the same boundary. |
| High: navigation to arbitrary HTML inside the game browser | `invisBrowser()` interpolated a URL directly into a script string, accepted executable schemes and loaded remote pages in the embedded browser. | The action now appears as **Open Website for Everyone**. It accepts bounded HTTP/HTTPS URLs and uses BYOND's external `link()` operation. Remote documents no longer receive the embedded game browser context through this action. |
| High: uploaded file rendered as a document | `Play_File()` recognized images by an extension substring and passed the original file to `browse()`. A name such as `portrait.png.html` matched. | Exact final extensions select supported image/sound types. Images are sent as fixed-name `browse_rsc()` resources and loaded only in an `<img>` within a fixed HTML wrapper. Audio uses `sound()`; uploaded files are never browser documents. |
| Medium: creator preview DOM injection | `buildReview()` concatenated the entered character name and other field values into `innerHTML`. | Review rows use `textContent` and `createTextNode()`. |
| Medium: CSS/skin parameter injection | Saved `TextColor` and `TextSize` values were interpolated into styles; the command prompt interpolated a command into a `winset` parameter string. | Color values use a fixed color grammar, sizes are numeric and bounded at use, and command text is transported with `list2params()`. The prompt still intentionally executes the player's chosen command. |
| Medium: player identities in standalone browsers | Who and server-details output interpolated names directly. | Dynamic identity values are HTML-encoded. |

## Rendering contract

- Store domain text independently of HTML presentation. Encode text at its output context: `html_encode()` for text, `encodeNexusHtmlAttribute()` for quoted HTML attributes, `url_encode()`/JSON for browser-function transport, and `list2params()` for skin commands. Attribute encoding does not validate a URL or CSS value.
- Use `sanitizeNexusHtml()` only for legacy formatted content. It tokenizes input and constructs new tags and validated attributes; it never returns an input tag verbatim. Allowed tags cover emphasis, paragraphs, headings, lists, tables, line breaks and legacy fonts. The only attributes are validated font properties and a restricted `style` vocabulary. It excludes URLs, event handlers, identifiers, classes and arbitrary positioning.
- The renderer balances retained tags, limits nesting to 64, input to 2 MiB and parsed tags to 20,000. Text beyond the tag budget is encoded; oversized input gets a visible truncation notice. Re-rendering canonical output preserves its entities rather than double-encoding them.
- Chat and authored documents no longer support clickable links, embedded images, custom layout CSS or scripts. Trusted application templates still define their own buttons, scripts, styles and resource images.
- Existing profile/emote bracket markup already escapes free text and validates colors; it remains the supported player rich-text interface. Generated resource aliases and URL-encoded JSON configuration remain separate from user HTML.
- Browser action handlers must still validate owner, permissions, current state and target ownership. Inspected Classic HUD, admin inspector/panel, profile, log, progression, trade and forge handlers retain their server-side checks. Rendering sanitization is not authorization or a complete audit of gameplay permissions.

## Verification

`runNexusHtmlSafetySmokeTests()` runs with the normal isolated BYOND startup suite. It covers scripts, event handlers, SVG/MathML, malformed/nested markup, forged BYOND links, CSS declarations, entity handling, safe legacy formatting, persistent emote/admin records, chat buffers, quote delimiters, URL schemes and disguised uploaded documents. It emits `html-safety-fixtures.json` inside the disposable smoke directory.

Run `node tools/TestHtmlSafety.cjs <smoke-world>/html-safety-fixtures.json` with Playwright available. This loads the actual DM-rendered fixtures in headless Chromium, checks the resulting DOM and absence of requests/dialogs, and exercises the production creator review function with hostile field values. A source guard enforces the explicit encoder in single-quoted attributes. Existing Classic HUD and character-creator browser tests cover regressions in those interfaces.

The normal compile/startup suite, runtime map-order check, strict asset-reference audit and non-strict naming audit remain applicable. Visual and interactive Dream Seeker verification stays with the user.

Validation results on 2026-09-26: BYOND 516.1686 compiled with zero errors/warnings; versioned and clean startup smoke runs passed with the security assertions enabled. The final source also passed a headless compile after maptext hardening. All 12 DM-generated browser attack fixtures, hostile creator fields, the existing Classic HUD test and the nine-size character-creation test passed. Runtime map ordering and strict asset references passed. The non-strict naming audit completed with existing legacy identifier violations.

## Limits

This is a code-level hardening pass with adversarial regression coverage, not a claim that every possible browser or game exploit is eliminated. Historical HTML logs opened directly from disk outside the protected viewers can still contain their original payloads; preservation of those records is intentional. Decoder vulnerabilities in uploaded media and all unrelated gameplay authorization paths require separate review. Administrator file replacement and arbitrary runtime-variable editing remain privileged operations.

The output-context approach follows [OWASP's XSS prevention guidance](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html); DOM text-node rendering follows its [DOM XSS guidance](https://cheatsheetseries.owasp.org/cheatsheets/DOM_based_XSS_Prevention_Cheat_Sheet.html).
