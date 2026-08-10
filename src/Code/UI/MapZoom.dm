var/const/NEXUS_WORLD_OVERLAY_PLANE = 20
var/const/NEXUS_FIXED_HUD_PLANE = 30

proc/getNexusMapZoomPlanes()
	return list(0, 1, 2, 3, 10, NEXUS_WORLD_OVERLAY_PLANE)

proc/getNexusMapZoomScale(view_width, render_width)
	render_width = max(1, round(render_width))
	view_width = Clamp(round(view_width), 1, render_width)
	return render_width / view_width

proc/getNexusMapRenderWidth(is_live_character, view_width, maximum_width)
	if(is_live_character) return max(1, round(maximum_width))
	return max(1, round(view_width))

proc/getNexusMapRenderHeight(render_width, resolution_width, resolution_height)
	render_width = max(1, round(render_width))
	var/aspect_ratio = max(1, resolution_width) / max(1, resolution_height)
	return max(1, round(render_width / aspect_ratio, 1))

proc/nexusMouseWheelCanZoomMap(control, object)
	if(control != "mapwindow.map") return FALSE
	if(istype(object, /atom))
		var/atom/hovered_atom = object
		if(hovered_atom.plane == NEXUS_FIXED_HUD_PLANE) return FALSE
	return TRUE

obj/NexusMapZoomPlaneMaster
	name = "map zoom compositor"
	screen_loc = "1,1"
	appearance_flags = PLANE_MASTER | PIXEL_SCALE | NO_CLIENT_COLOR
	mouse_opacity = 1
	Savable = 0
	Grabbable = 0
	attackable = 0
	density = 0

client
	var/tmp/list/nexus_map_zoom_plane_masters
	var/tmp/nexus_map_zoom_scale = 1

	proc/initializeNexusMapZoom()
		if(!mob || !mob.playerCharacter) return FALSE
		if(!islist(nexus_map_zoom_plane_masters)) nexus_map_zoom_plane_masters = list()
		for(var/world_plane in getNexusMapZoomPlanes())
			var/plane_key = "[world_plane]"
			var/obj/NexusMapZoomPlaneMaster/plane_master = nexus_map_zoom_plane_masters[plane_key]
			if(!plane_master)
				plane_master = new
				plane_master.plane = world_plane
				nexus_map_zoom_plane_masters[plane_key] = plane_master
			if(!(plane_master in screen)) screen += plane_master
		applyNexusMapZoom(mob.ViewX, max_screen_size)
		return TRUE

	proc/applyNexusMapZoom(view_width, render_width)
		if(!islist(nexus_map_zoom_plane_masters)) return 1
		nexus_map_zoom_scale = getNexusMapZoomScale(view_width, render_width)
		var/matrix/zoom_transform = matrix()
		zoom_transform.Scale(nexus_map_zoom_scale, nexus_map_zoom_scale)
		for(var/plane_key in nexus_map_zoom_plane_masters)
			var/obj/NexusMapZoomPlaneMaster/plane_master = nexus_map_zoom_plane_masters[plane_key]
			if(plane_master) plane_master.transform = matrix(zoom_transform)
		if(nexus_lighting_plane) nexus_lighting_plane.transform = matrix(zoom_transform)
		return nexus_map_zoom_scale

	proc/removeNexusMapZoom()
		if(islist(nexus_map_zoom_plane_masters))
			for(var/plane_key in nexus_map_zoom_plane_masters)
				var/obj/NexusMapZoomPlaneMaster/plane_master = nexus_map_zoom_plane_masters[plane_key]
				if(!plane_master) continue
				screen -= plane_master
				del(plane_master)
		nexus_map_zoom_plane_masters = null
		nexus_map_zoom_scale = 1
		if(nexus_lighting_plane) nexus_lighting_plane.transform = matrix()
