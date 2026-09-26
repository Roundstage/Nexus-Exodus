proc/encodeNexusHtmlAttribute(value)
	var/encoded_value = html_encode("[value]")
	encoded_value = replacetext(encoded_value, "'", "&#39;")
	encoded_value = replacetext(encoded_value, "\"", "&quot;")
	return encoded_value

// Text belongs in html_encode(); legacy rich HTML must cross this boundary.
// Rebuild a small, inert vocabulary. Never return an input tag or attribute.
proc/nexusHtmlCharactersOnly(value, characters)
	if(!length(value)) return FALSE
	for(var/index = 1, index <= length(value), index++)
		if(!findtext(characters, copytext(value, index, index + 1))) return FALSE
	return TRUE

proc/normalizeNexusHtmlColor(value, fallback = "")
	value = lowertext(trimtext("[value]"))
	if(value in list("black", "silver", "gray", "grey", "white", "maroon", "red", "purple", "fuchsia", "green", "lime", "olive", "yellow", "navy", "blue", "teal", "aqua", "cyan", "orange", "pink", "gold", "brown", "transparent")) return value
	if(copytext(value, 1, 2) == "#" && (length(value) in list(4, 7, 9)))
		if(nexusHtmlCharactersOnly(copytext(value, 2), "0123456789abcdef")) return value
	return fallback

proc/normalizeNexusChatTextSize(value)
	if(!nexusIsFiniteNumber(value)) return 2
	return Clamp(round(value), 1, 10)

proc/sanitizeNexusHtmlStyle(value)
	var/list/declarations = list()
	for(var/declaration in splittext(copytext("[value]", 1, 1025), ";"))
		var/separator = findtext(declaration, ":")
		if(!separator) continue
		var/property_name = lowertext(trimtext(copytext(declaration, 1, separator)))
		var/property_value = lowertext(trimtext(copytext(declaration, separator + 1)))
		var/safe_value = ""
		switch(property_name)
			if("color", "background-color") safe_value = normalizeNexusHtmlColor(property_value)
			if("font-weight")
				if(property_value in list("normal", "bold", "400", "700")) safe_value = property_value
			if("font-style")
				if(property_value in list("normal", "italic")) safe_value = property_value
			if("text-decoration")
				if(property_value in list("none", "underline", "line-through")) safe_value = property_value
			if("text-align")
				if(property_value in list("left", "center", "right")) safe_value = property_value
			if("font-family")
				if(property_value in list("arial", "verdana", "courier new", "monospace", "sans-serif", "walk the moon")) safe_value = property_value
			if("font-size")
				if(length(property_value) < 3) continue
				var/unit = copytext(property_value, length(property_value) - 1)
				var/size_text = copytext(property_value, 1, length(property_value) - 1)
				if((unit in list("px", "pt")) && length(size_text) <= 2 && nexusHtmlCharactersOnly(size_text, "0123456789"))
					safe_value = "[Clamp(text2num(size_text), 8, 32)][unit]"
		if(safe_value) declarations[property_name] = safe_value
	var/list/rendered = list()
	for(var/property_name in declarations) rendered += "[property_name]:[declarations[property_name]]"
	return jointext(rendered, ";")

proc/getNexusHtmlAttributes(tag_tail)
	var/list/attributes = list()
	var/cursor = 1
	var/text_length = length(tag_tail)
	while(cursor <= text_length)
		while(cursor <= text_length && (copytext(tag_tail, cursor, cursor + 1) in list(" ", "\t", ascii2text(13), "\n", "/"))) cursor++
		var/name_start = cursor
		while(cursor <= text_length && findtext("abcdefghijklmnopqrstuvwxyz0123456789-", lowertext(copytext(tag_tail, cursor, cursor + 1)))) cursor++
		if(cursor == name_start)
			cursor++
			continue
		var/attribute_name = lowertext(copytext(tag_tail, name_start, cursor))
		while(cursor <= text_length && (copytext(tag_tail, cursor, cursor + 1) in list(" ", "\t", ascii2text(13), "\n"))) cursor++
		if(copytext(tag_tail, cursor, cursor + 1) != "=") continue
		cursor++
		while(cursor <= text_length && (copytext(tag_tail, cursor, cursor + 1) in list(" ", "\t", ascii2text(13), "\n"))) cursor++
		var/quote = copytext(tag_tail, cursor, cursor + 1)
		var/value_start = cursor
		var/attribute_value
		if(quote == "'" || quote == "\"")
			value_start = ++cursor
			var/value_end = findtext(tag_tail, quote, cursor)
			if(!value_end) break
			attribute_value = copytext(tag_tail, value_start, value_end)
			cursor = value_end + 1
		else
			while(cursor <= text_length && !(copytext(tag_tail, cursor, cursor + 1) in list(" ", "\t", ascii2text(13), "\n"))) cursor++
			attribute_value = copytext(tag_tail, value_start, cursor)
		if(attribute_name in list("color", "size", "face", "style")) attributes[attribute_name] = attribute_value
	return attributes

proc/buildNexusSafeHtmlTag(tag_name, tag_tail)
	var/list/attributes = getNexusHtmlAttributes(tag_tail)
	var/result = "<[tag_name]"
	var/style = sanitizeNexusHtmlStyle(attributes["style"])
	if(style) result += " style='[style]'"
	if(tag_name == "font")
		var/font_color = normalizeNexusHtmlColor(attributes["color"])
		if(font_color) result += " color='[font_color]'"
		var/font_size = attributes["size"]
		if(length(font_size) <= 2 && nexusHtmlCharactersOnly(font_size, "0123456789")) result += " size='[Clamp(text2num(font_size), 1, 7)]'"
		var/font_face = lowertext("[attributes["face"]]")
		if(font_face in list("arial", "verdana", "courier new", "monospace", "sans-serif", "walk the moon")) result += " face='[font_face]'"
	return "[result]>"

proc/sanitizeNexusHtml(value)
	// Bounds also cover old disk logs and deeply nested input. Work is linear in input size.
	var/raw_text = copytext("[value]", 1, 2097153)
	var/list/output_parts = list()
	var/list/open_tags = list()
	var/list/allowed_tags = list("b", "strong", "i", "em", "u", "s", "strike", "small", "big", "sub", "sup", "p", "div", "span", "pre", "blockquote", "center", "font", "h1", "h2", "h3", "h4", "h5", "h6", "ul", "ol", "li", "table", "thead", "tbody", "tfoot", "tr", "td", "th", "br", "hr")
	var/cursor = 1
	var/tag_count = 0
	while(cursor <= length(raw_text))
		var/tag_start = findtext(raw_text, "<", cursor)
		if(!tag_start || tag_count >= 20000)
			output_parts += html_encode(html_decode(copytext(raw_text, cursor)))
			break
		if(tag_start > cursor) output_parts += html_encode(html_decode(copytext(raw_text, cursor, tag_start)))
		var/tag_end = findtext(raw_text, ">", tag_start + 1)
		if(!tag_end)
			output_parts += html_encode(html_decode(copytext(raw_text, tag_start)))
			break
		cursor = tag_end + 1
		tag_count++
		if(tag_end - tag_start > 2048) continue
		var/tag_text = copytext(raw_text, tag_start + 1, tag_end)
		var/is_closing = copytext(tag_text, 1, 2) == "/"
		var/name_start = is_closing ? 2 : 1
		var/name_end = name_start
		while(name_end <= length(tag_text) && findtext("abcdefghijklmnopqrstuvwxyz0123456789", lowertext(copytext(tag_text, name_end, name_end + 1)))) name_end++
		var/tag_name = lowertext(copytext(tag_text, name_start, name_end))
		if(!(tag_name in allowed_tags)) continue
		if(name_end <= length(tag_text) && !(copytext(tag_text, name_end, name_end + 1) in list(" ", "\t", ascii2text(13), "\n", "/"))) continue
		if(is_closing)
			var/open_index = 0
			for(var/index = open_tags.len, index >= 1, index--)
				if(open_tags[index] == tag_name)
					open_index = index
					break
			if(!open_index) continue
			for(var/index = open_tags.len, index >= open_index, index--)
				output_parts += "</[open_tags[index]]>"
			open_tags.Cut(open_index)
		else
			if(open_tags.len >= 64) continue
			output_parts += buildNexusSafeHtmlTag(tag_name, copytext(tag_text, name_end))
			if(!(tag_name in list("br", "hr"))) open_tags += tag_name
	for(var/index = open_tags.len, index >= 1, index--) output_parts += "</[open_tags[index]]>"
	if(length("[value]") > length(raw_text)) output_parts += "<p>Content truncated for safe display.</p>"
	return jointext(output_parts, "")

proc/buildNexusSafeDocument(value, title = "Information")
	return "<!doctype html><html><head><meta charset='utf-8'><title>[html_encode(title)]</title></head><body style='background:#101923;color:#edf3fa;font:14px Arial'>[sanitizeNexusHtml(value)]</body></html>"

proc/normalizeNexusBrowserUrl(value)
	if(!istext(value) || length(value) > 2048) return null
	value = trimtext(value)
	var/lower_value = lowertext(value)
	if(findtext(lower_value, "https://") != 1 && findtext(lower_value, "http://") != 1) return null
	for(var/index = 1, index <= length(value), index++)
		var/code = text2ascii(value, index)
		if(code <= 32 || code == 127 || (copytext(value, index, index + 1) in list("<", ">", "\"", "'", "\\"))) return null
	var/authority_start = findtext(value, "://") + 3
	var/authority_end = length(value) + 1
	for(var/delimiter in list("/", "?", "#"))
		var/position = findtext(value, delimiter, authority_start)
		if(position) authority_end = min(authority_end, position)
	var/authority = copytext(value, authority_start, authority_end)
	if(!authority || findtext(authority, "@")) return null
	return value
