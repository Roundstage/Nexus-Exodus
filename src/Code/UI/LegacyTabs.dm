mob/proc/View_update_logs()
	src << browse(New_Stuff, "window=Updates,size=800x600")
	//winset(src,"rpane.rpanewindow","left=browserwindow")
	//Update_tab_button_text()

mob/var/tmp/tabs_hidden
mob/verb/Toggle_tabs()
	set name=".Toggle_tabs"
	if(winget(src,"rpane.rpanewindow","left")=="infowindow")
		winset(src,"rpane.rpanewindow","left=;")
		tabs_hidden=1
	else
		winset(src,"rpane.rpanewindow","left=infowindow")
		tabs_hidden=0
	Update_tab_button_text()

mob/proc/Update_tab_button_text(button_visible=1)
	if(!client) return
	if(button_visible) winset(src,"tabbutton","is-visible=true")
	else winset(src,"tabbutton","is-visible=false")
	var/t="Show tabs"
	if(winget(src,"rpane.rpanewindow","left")=="infowindow") t="Hide tabs"
	winset(src,"tabbutton","text='[t]'")
