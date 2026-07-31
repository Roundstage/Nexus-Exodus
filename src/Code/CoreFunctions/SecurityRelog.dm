var/list/relog_list=new

mob/proc/Add_relog_log()
	if(!key) return
	var/list/l=list("logouts"=0,"expire time"=0)
	if(key in relog_list) l=relog_list[key]
	if(world.time>=l["expire time"]) l["logouts"]=0
	l["logouts"]++
	l["expire time"]=world.time+(3*60*10)
	relog_list[key]=l

mob/proc/Spam_relogger()
	if(IsAdmin()) return
	if(key&&(key in relog_list))
		var/list/l=relog_list[key]
		if(world.time>=l["expire time"]) return
		if(l["logouts"]>=4)
			return l["expire time"]
