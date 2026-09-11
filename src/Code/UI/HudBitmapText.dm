// Deterministic single-line HUD text. Generated glyphs share the browser font's OFL source.
var/list/nexus_hud_font_metrics
var/list/nexus_hud_glyph_cache = list()
var/list/nexus_hud_text_icon_cache = list()

proc/getNexusHudFont(size)
	if(!nexus_hud_font_metrics) nexus_hud_font_metrics = json_decode(file2text('src/Fonts/NexusHudGlyphs.json'))
	return nexus_hud_font_metrics["sizes"]["[size]"]

proc/getNexusHudGlyphCode(character)
	var/code = text2ascii(character)
	return (code >= 32 && code <= 126) || (code >= 160 && code <= 255) ? code : 63

proc/normalizeNexusHudText(value)
	var/result = replacetext(replacetext(replacetext("[value]","\n"," "),ascii2text(13)," "),"\t"," ")
	return copytext_char(result,1,257)

proc/measureNexusHudText(value, size = 12)
	var/list/font = getNexusHudFont(size)
	var/list/advances = font["advances"]
	var/width = 0
	for(var/character in splittext_char(value,""))
		width += advances["[getNexusHudGlyphCode(character)]"]
	return width

proc/fitNexusHudText(value, size, width)
	if(measureNexusHudText(value,size) <= width) return value
	var/suffix = "..."
	if(measureNexusHudText(suffix,size) > width) return ""
	var/list/characters = splittext_char(value,"")
	var/list/font = getNexusHudFont(size)
	var/list/advances = font["advances"]
	var/used = measureNexusHudText(suffix,size)
	var/result = ""
	for(var/character in characters)
		var/advance = advances["[getNexusHudGlyphCode(character)]"]
		if(used+advance > width) break
		result += character
		used += advance
	return "[result][suffix]"

proc/getNexusHudTextBounds(value, size)
	var/list/font = getNexusHudFont(size)
	var/list/bounds = font["bounds"]
	var/top = font["height"]
	var/bottom = 0
	for(var/character in splittext_char(value,""))
		var/list/glyph_bounds = bounds["[getNexusHudGlyphCode(character)]"]
		if(glyph_bounds)
			top = min(top,glyph_bounds[1])
			bottom = max(bottom,glyph_bounds[2])
	return list(font["height"]-bottom+1,max(1,bottom-top))

proc/getNexusHudGlyph(size, code)
	var/cache_key = "[size]-[code]"
	if(!nexus_hud_glyph_cache[cache_key])
		var/list/font = getNexusHudFont(size)
		var/icon/glyph = icon('src/Icons/UI/NexusHudGlyphs.dmi',cache_key)
		glyph.Crop(1,1,24,font["height"])
		nexus_hud_glyph_cache[cache_key] = glyph
	return nexus_hud_glyph_cache[cache_key]

proc/getNexusHudTextIcon(value, size, width, height, text_color, alignment)
	var/cache_key = json_encode(list(value,size,width,height,text_color,alignment))
	if(nexus_hud_text_icon_cache[cache_key]) return nexus_hud_text_icon_cache[cache_key]
	var/list/font = getNexusHudFont(size)
	var/list/advances = font["advances"]
	var/text_width = measureNexusHudText(value,size)+1
	var/icon/letters = icon('src/Icons/UI/NexusHudGlyphs.dmi',"[size]-32")
	letters.Crop(1,1,max(1,text_width),font["height"])
	var/cursor_x = 1
	for(var/character in splittext_char(value,""))
		var/code = getNexusHudGlyphCode(character)
		letters.Blend(getNexusHudGlyph(size,code),ICON_OVERLAY,cursor_x,1)
		cursor_x += advances["[code]"]
	var/list/bounds = getNexusHudTextBounds(value,size)
	letters.Crop(1,bounds[1],text_width,bounds[1]+bounds[2]-1)
	var/icon/shadow = icon(letters)
	shadow.Blend("#080706",ICON_MULTIPLY)
	letters.Blend(text_color,ICON_MULTIPLY)
	var/icon/canvas = icon('src/Icons/UI/NexusHudGlyphs.dmi',"[size]-32")
	canvas.Crop(1,1,width,height)
	var/text_x = alignment == "center" ? round((width-text_width)/2) : (alignment == "right" ? width-text_width : 0)
	var/text_y = round((height-bounds[2]-1)/2)
	canvas.Blend(shadow,ICON_OVERLAY,text_x+2,text_y+1)
	canvas.Blend(letters,ICON_OVERLAY,text_x+1,text_y+2)
	// Changing energy values must not retain an unbounded number of word images.
	if(nexus_hud_text_icon_cache.len >= 512) nexus_hud_text_icon_cache.Cut(1,2)
	nexus_hud_text_icon_cache[cache_key] = canvas
	return canvas

obj/NexusHudBitmapText
	parent_type = /obj/NexusHud
	mouse_opacity = 0
	appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | PIXEL_SCALE
	var/tmp
		text_value = ""
		rendered_text = ""
		rendered_font_size = 12
		text_width = 0
		text_height = 0
		render_key

	proc/setBitmapText(value, requested_size = 12, text_color = "#eee3cf", alignment = "left", shrink_to_fit = FALSE)
		text_value = normalizeNexusHudText(value)
		maptext = null
		var/new_key = json_encode(list(text_value,requested_size,text_color,alignment,shrink_to_fit,maptext_width,maptext_height))
		if(new_key == render_key) return
		render_key = new_key
		if(!text_value || maptext_width < 1 || maptext_height < 1)
			rendered_text = ""
			text_width = 0
			text_height = 0
			icon = null
			return
		rendered_font_size = 8
		for(var/size in list(16,12,8))
			var/list/bounds = getNexusHudTextBounds(text_value,size)
			if(size <= requested_size && bounds[2]+1 <= maptext_height)
				if(shrink_to_fit && size > 8 && measureNexusHudText(text_value,size)+1 > maptext_width) continue
				rendered_font_size = size
				break
		rendered_text = fitNexusHudText(text_value,rendered_font_size,maptext_width-1)
		var/list/bounds = getNexusHudTextBounds(rendered_text,rendered_font_size)
		text_width = measureNexusHudText(rendered_text,rendered_font_size)+1
		text_height = bounds[2]+1
		if(text_height > maptext_height)
			icon = null
			return
		icon = getNexusHudTextIcon(rendered_text,rendered_font_size,maptext_width,maptext_height,text_color,alignment)
