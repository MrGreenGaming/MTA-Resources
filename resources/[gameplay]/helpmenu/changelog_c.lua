---------------------
-- Fetch changelog --
---------------------
function startChangelogDownload()
	-- Old link: https://github.com/JarnoVgr/Mr.Green-MTA-Resources/commits/master.atom/
	fetchRemote ( "https://github.com/MrGreenGaming/MTA-Resources/commits/master.atom", receiveChangelog)
end

function receiveChangelog(responseData, errno)
	if errno == 0 then
		--Load previous log file and save new changelog
		--outputDebugString("Received changelog data", 3)
		local logFile = fileExists("changelog.xml") and fileDelete("changelog.xml") and fileCreate("changelog.xml") or fileCreate("changelog.xml") 
		fileWrite(logFile, responseData)
		fileClose(logFile)
			
		updateChangelogString()
	else
		outputDebugString("Can't receive changelog from GitHub. Error #"..errno, 1)
	end
end

-------------------------------------------
-- Convert XML data to a readable string --
-------------------------------------------
function updateChangelogString()
	local logNode = xmlLoadFile("changelog.xml")
		
	changelog = "Server changelog from https://github.com/MrGreenGaming/MTA-Resources/commits/master.atom\r\n"
	changelog = changelog .. "Last 20 changes at " .. makeCurrentDatetime() .. '\r\n'
	changelog = changelog .. "_________________________________________________________\r\n\r\n"
	
	local changesCounter = 0
	for i=0, 19 do
		local entryNode = xmlFindChild(logNode, "entry", i)
		
		local titleNode = xmlFindChild( entryNode, "title", 0 )
		local nameNode = xmlFindChild( xmlFindChild(entryNode, "author", 0) , "name", 0 )
		local updatedNode = xmlFindChild( entryNode, "updated", 0 )
		local contentNode = xmlFindChild( entryNode, "content", 0)
		
		local title = xmlNodeGetValue(titleNode)
		local name = xmlNodeGetValue(nameNode)
		local updated = xmlNodeGetValue(updatedNode)
		local content = xmlNodeGetValue(contentNode)
		--clean html from the string
		for i=1, #cleaner do
			local cleans = cleaner[i]
			content = string.gsub( content, cleans[1], cleans[2] )
		end
		--some other formatting
		local title = string.gsub(string.gsub(title, "\n", ""), "  ", "")
		local content = string.gsub(content, "      ", "")
		local content = string.gsub(content, "    ", "")
		local content = string.gsub(content, "\n", "\n   ")
		local updated =  string.gsub(string.gsub(updated, "T", " "), "+", " UTC +")
			
		if not string.find(title, "Merge pull request") and not string.find(title, "Merge branch 'master' of") then
			changelog = changelog .. "* " ..content.."by " .. name .. " on " .. updated .. "\r\n\r\n"
			changesCounter = changesCounter + 1
		end
			
		if i == 0 then
			changelogLastUpdate = updated
		end
	end
	
	changelog = string.gsub(changelog, "Last 20 changes at ", "Last " ..changesCounter.. " changes at ")
	xmlUnloadFile(logNode)
end

requestBrowserDomains({ "github.com", "mrgreengaming.com", "forums.mrgreengaming.com" })
startChangelogDownload()
setTimer(startChangelogDownload, 5*60*1000, 0)

function makeCurrentDatetime()
	local time = getRealTime()
	local year = time.year + 1900
	local month = fillDigits(time.month + 1)
	local day = fillDigits(time.monthday)
	local hour = fillDigits(time.hour)
	local minute = fillDigits(time.minute)
	local second = fillDigits(time.second)
	return year.."-"..month.."-"..day.." "..hour..":"..minute..":"..second
end