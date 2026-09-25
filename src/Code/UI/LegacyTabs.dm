mob/proc/View_update_logs()
	src << browse(New_Stuff, "window=Updates,size=800x600")

mob/var/tmp/tabs_hidden

// Old skins and saved settings must not restore the retired native tab panes.
mob/proc/hideNexusNativeTabs()
	tabs_hidden = TRUE
	nexus_interface_layout = normalizeNexusInterfaceLayout(nexus_interface_layout)
	if(!client) return
	client.show_verb_panel = FALSE
	winset(src, "rpane.rpanewindow", "left=;right=;splitter=100")
	winset(src, "classiclegacy.body", "left=;right=")
	for(var/control_id in list("rpane", "infowindow", "classiclegacy", "rpane.tabbutton"))
		winset(src, control_id, "is-visible=false")

mob/verb/Toggle_tabs()
	set name=".Toggle_tabs"
	set hidden = TRUE
	hideNexusNativeTabs()
	if(client && playerCharacter) toggleClassicWidget("menu")

mob/proc/Update_tab_button_text(button_visible=1)
	hideNexusNativeTabs()
