var/list/damage_indicator_cache = list()

proc/acquireDamageIndicator()
	var/obj/DamageIndicator/indicator
	if(damage_indicator_cache.len)
		indicator = damage_indicator_cache[1]
		damage_indicator_cache.Cut(1, 2)
	else indicator = new
	return indicator

atom/proc/showDamageIndicator(amount, text_color = "#ff667a")
	if(!isnum(amount) || amount <= 0 || !loc) return
	var/obj/DamageIndicator/indicator = acquireDamageIndicator()
	indicator.show(src, amount, text_color)
	return indicator

obj/DamageIndicator
	Savable = 0
	Grabbable = 0
	attackable = 0
	density = 0
	mouse_opacity = 0
	layer = 99
	maptext_width = 64
	maptext_height = 24

	proc/show(atom/target, amount, text_color)
		set waitfor = 0
		animate(src)
		alpha = 255
		transform = matrix()
		var/display_amount = round(amount, amount < 10 ? 0.1 : 1)
		var/display_text = display_amount < 1000000 ? num2text(display_amount, 10) : Commas(display_amount, FALSE)
		maptext = "<center><span style='font-family:Arial;font-size:14pt;font-weight:bold;color:[text_color];text-shadow:1px 1px #000000'>-[display_text]</span></center>"
		pixel_x = target.pixel_x - 16 + rand(-8, 8)
		pixel_y = target.pixel_y + (target.icon ? max(32, GetHeight(target.icon)) : 32)
		SafeTeleport(target.loc)
		var/end_y = pixel_y + 28
		animate(src, pixel_y = pixel_y + 8, transform = matrix() * 1.12, time = 2, easing = CUBIC_EASING)
		animate(src, pixel_y = end_y, alpha = 0, time = 8, easing = SINE_EASING)
		sleep(10)
		release()

	proc/release()
		animate(src)
		maptext = null
		alpha = 255
		transform = matrix()
		SafeTeleport(null)
		if(!(src in damage_indicator_cache)) damage_indicator_cache += src
