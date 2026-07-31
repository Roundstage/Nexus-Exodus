mob/proc/Event_Guide()
	usr<<browse(Event_Guide,"window= ;size=700x600")

mob/proc/Rank_Guide()
	usr<<browse(SuggestedRanks,"window= ;size=700x600")

var/mob/WritingNotes

mob/Admin1/verb/notes()
	set name = "Notes"
	set category="Admin"
	usr<<browse(Notes,"window= ;size=700x600")

mob/Admin1/verb/editNotes()
	set name = "EditNotes"
	set category="Admin"
	if(!WritingNotes)
		WritingNotes=src
		Admin_Msg("[usr] is editing the notes...")
		Notes=input(usr,"Edit!","Edit Notes",Notes) as message
		Admin_Msg("[usr] is done editing the notes...")
		WritingNotes=0
		saveNotes()
	else usr<<"<b>Someone is already editing the notes."

var/mob/WritingStory

mob/verb/Story()
	//set category="Other"
	usr<<browse(Story,"window= ;size=700x600")

mob/Admin3/verb/editStory()
	set name = "EditStory"
	set category="Admin"
	if(!WritingStory)
		WritingStory=src
		Admin_Msg("[usr] is editing the story")
		Story=input(usr,"Edit!","Edit Story",Story) as message
		Admin_Msg("[usr] is done editing the story")
		WritingStory=0
		saveStory()
	else usr<<"<b>Someone is already editing the story."

var/mob/WritingRanks

/*mob/verb/Ranks()
	set category="Other"
	usr<<browse(rank_window,"window= ;size=700x600")*/

mob/Admin3/verb/editRanks()
	set name = "EditRanks"
	set category="Admin"
	if(!WritingRanks)
		WritingRanks=src
		Admin_Msg("[usr] is editing the ranks...")
		rank_window=input(usr,"Edit!","Edit Ranks",Ranks) as message
		Admin_Msg("[usr] is done editing the ranks...")
		WritingRanks=0
		saveRanks()
	else usr<<"<b>Someone is already editing the ranks."

var/mob/WritingJobs

mob/proc/Admin_Guide()
	usr<<browse(Jobs,"window= ;size=700x600")

mob/Admin4/verb/editJobs()
	set name = "EditJobs"
	set category="Admin"
	if(!WritingJobs)
		WritingJobs=src
		Admin_Msg("[usr] is editing the jobs...")
		Jobs=input(usr,"Edit!","Edit Jobs",Jobs) as message
		Admin_Msg("[usr] is done editing the jobs...")
		WritingJobs=0
		saveJobs()
	else usr<<"<b>Someone is already editing the jobs."

var/mob/WritingRules

mob/verb/View_Rules()
	set category="Other"
	usr<<browse(Rules,"window= ;size=700x600")

mob/Admin3/verb/editRules()
	set name = "EditRules"
	set category="Admin"
	if(!WritingRules)
		WritingRules=src
		Admin_Msg("[usr] is editing the rules...")
		Rules=input(usr,"Edit!","Edit Rules",Rules) as message
		Admin_Msg("[usr] is done editing the rules...")
		WritingRules=0
		saveRules()
	else usr<<"<b>Someone is already editing the rules."

var/mob/WritingUpdates

mob/Admin3/verb/editLogin()
	set name = "EditLogin"
	set category="Admin"
	if(!WritingUpdates)
		WritingUpdates=src
		Admin_Msg("[usr] is editing the login menu")
		Version_Notes=input(usr,"Edit!","Edit",Version_Notes) as message
		Admin_Msg("[usr] is done editing the login menu")
		WritingUpdates=0
		saveLogin()
	else usr<<"<b>Someone is already editing the login menu."
