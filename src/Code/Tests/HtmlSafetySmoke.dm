proc/runNexusHtmlSafetySmokeTests()
	var/list/payloads = list(
		"<script>window.location='byond://winset?command=quit'</script>",
		"<img src=x onerror=alert(1)><iframe src='https://example.invalid'></iframe>",
		"<svg><a xlink:href='javascript:alert(1)'>click</a><animate onbegin=alert(1)></svg>",
		"<math><mtext><table><mglyph><style><!--</style><img title='--><img src=x onerror=alert(1)>'>",
		"<a href='byond://?src=123&action=delete'>forged command</a><form action='byond://'><input autofocus onfocus=alert(1)></form>",
		"<meta http-equiv=refresh content='0;url=javascript:alert(1)'><base href='https://example.invalid'>",
		"<span id=classicContext class=context onclick=alert(1) style='position:fixed;inset:0;background:url(https://example.invalid);color:expression(alert(1))'>spoof</span>",
		"<font color='red onmouseover=alert(1)' size='7 onclick=alert(1)'>bad</font>",
		"<span style='color:&#x72;ed;behavior:url(x);-moz-binding:url(x)'>css</span>",
		"<span title=\"ignored style='color:red'\" onmouseover=alert(1)>quoted</span>",
		"</textarea></script><SCRIPT/SRC=https://example.invalid></SCRIPT>",
		"<b><i>crossed</b></i><img/src=x onerror=alert(1)>")
	var/list/rendered_payloads = list()
	for(var/payload in payloads)
		var/rendered = sanitizeNexusHtml(payload)
		rendered_payloads += rendered
		for(var/forbidden in list("<script", "<img", "<svg", "<math", "<iframe", "<a ", "<form", "<input", "<meta", "<base", "<style", " onclick=", " onerror=", " onmouseover=", " id=", " class=", "position:", "background:", "expression(", "behavior:", "-moz-binding:"))
			nexusSmokeAssert(!findtext(rendered, forbidden), "HTML sanitizer retained active markup: [forbidden]")
		nexusSmokeAssert(sanitizeNexusHtml(rendered) == rendered, "HTML sanitizer is not stable when persisted chat is rendered again")
	nexusSmokeAssert(sanitizeNexusHtml("<div><div>inner</div>outer</div>") == "<div><div>inner</div>outer</div>", "HTML sanitizer closes nested formatting too early")
	nexusSmokeAssert(sanitizeNexusHtml("<b>bold <i>italic") == "<b>bold <i>italic</i></b>", "HTML sanitizer leaves formatting open")
	var/entity_text = sanitizeNexusHtml("&lt;img src=x&gt; &amp; &#39;")
	nexusSmokeAssert(!findtext(entity_text, "<") && html_decode(entity_text) == "<img src=x> & '", "HTML sanitizer double-encodes text or reactivates entities")
	nexusSmokeAssert(sanitizeNexusHtml("<font COLOR=#Ff0000 size=99>notice</font>") == "<font color='#ff0000' size='7'>notice</font>", "legacy chat colors and bounded font sizes were lost")
	nexusSmokeAssert(sanitizeNexusHtmlStyle("color:#abc;font-weight:bold;position:fixed; background-image:url(x);font-size:99px") == "color:#abc;font-weight:bold;font-size:32px", "CSS allowlist accepts active declarations or loses safe formatting")
	nexusSmokeAssert(normalizeNexusHtmlColor("red' onclick='alert(1)", "#ffffff") == "#ffffff" && normalizeNexusChatTextSize("2; color:red") == 2, "saved chat preferences can escape their rendering context")
	var/attribute_text = encodeNexusHtmlAttribute("'\"<>&")
	nexusSmokeAssert(html_decode(attribute_text) == "'\"<>&" && !findtext(attribute_text, "'") && !findtext(attribute_text, "\"") && !findtext(attribute_text, "<") && !findtext(attribute_text, ">"), "HTML attributes do not escape both quote delimiters")
	nexusSmokeAssert(normalizeNexusBrowserUrl("https://example.com/path?a=1&b=2") == "https://example.com/path?a=1&b=2", "valid HTTP browser URL was rejected")
	for(var/url in list("javascript:alert(1)", "data:text/html,test", "byond://winset?command=quit", "file:///C:/test", "//example.com", "https://example.com/'</script>", "https://example.com\n.evil", "https://user@example.com", "https:///missing-host"))
		nexusSmokeAssert(!normalizeNexusBrowserUrl(url), "browser URL validator accepted [url]")
	nexusSmokeAssert(getNexusAdminMediaKind("portrait.PNG") == "image" && getNexusAdminMediaKind("theme.mp3") == "sound", "admin media rejected supported images or sounds")
	for(var/file_name in list("portrait.png.html", "portrait.svg", "page.htm", "script.js", "theme.mp3.html"))
		nexusSmokeAssert(!getNexusAdminMediaKind(file_name), "admin media accepts document disguised as [file_name]")
	var/encoded_argument = encodeNexusBrowserFunctionArgument("'</script><img src=x onerror=alert(1)>")
	nexusSmokeAssert(!findtext(encoded_argument, "'") && !findtext(encoded_argument, "<"), "browser function arguments can escape their JavaScript string")
	var/datum/NexusChatBuffer/buffer = new
	buffer.appendMessage(payloads[2])
	var/list/entry = buffer.entries[1]
	nexusSmokeAssert(!findtext(entry["html"], "<img") && !findtext(entry["html"], "<iframe"), "chat buffer bypasses HTML sanitization")
	del(buffer)
	var/deep_markup = ""
	for(var/index = 1, index <= 100, index++) deep_markup += "<b>"
	deep_markup += "bounded"
	nexusSmokeAssert(length(sanitizeNexusHtml(deep_markup)) == length("bounded") + 64 * 7, "HTML nesting is not bounded")
	// Emote/admin logs must be safe on disk as well as when viewed in game.
	var/mob/NexusSmokeTest/log_owner = new
	log_owner.EmoteLog(payloads[2], "<img src=x onerror=alert(1)>", "adminlogs", FALSE)
	var/log_entry = log_owner.unwritten_emotelogs[1]
	nexusSmokeAssert(!findtext(log_entry, "<img") && !findtext(log_entry, "<iframe"), "persistent emote/admin log retained executable input")
	del(log_owner)
	// Export the actual DM renderer's results for a browser parser regression test.
	if(fexists("html-safety-fixtures.json")) fdel("html-safety-fixtures.json")
	text2file(json_encode(rendered_payloads), "html-safety-fixtures.json")
