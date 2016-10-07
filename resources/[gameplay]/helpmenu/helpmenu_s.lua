local onlineAdmins = {}

-- HTML Code Cleaner https://gist.github.com/HoraceBury/9001099
-- Edited by AleksCore
-- list of strings to replace (the order is important to avoid conflicts)
local cleaner = {
	{ "&amp;", "" }, --decode ampersands
	{ "&#39;", "'" }, --single quote
	{ "quot;", "\"" }, --double quote
	{ "<br ?/?>", "\n" }, --all <br> tags whether terminated or not (<br> <br/> <br />) become new lines
	{ "</p>", "\n" }, --ends of paragraphs become new lines
	{ "(%b<>)", "" }, --all other html elements are completely removed (must be done last)
	{ "\r", "\n" }, --return carriage become new lines
	{ "[\n\n]+", "\n" }, --reduce all multiple new lines with a single new line
	{ "^\n*", "" }, --trim new lines from the start...
	{ "\n*$", "" }, --... and end
	{ '&"', '"' },
}

motdText, changelog = '', false
motdVersion, changelogLastUpdate = 0, ""
	
function start()
	local motdNode = fileExists('motd.xml') and xmlLoadFile('motd.xml') or xmlCreateFile('motd.xml', 'motd')
	motdVersion = tonumber(xmlNodeGetAttribute(motdNode, 'version'))
	motdText = xmlNodeGetValue(motdNode) or ''
	xmlUnloadFile(motdNode)
	
	if fileExists('changelog.xml') then
		updateChangelogString()
	end
	
	startChangelogDownload()
	setTimer(startChangelogDownload, 5*60*1000, 0)
end
addEventHandler('onResourceStart', resourceRoot, start)


addEvent('requestMOTD', true)
addEventHandler('requestMOTD', resourceRoot, 
function()
	triggerClientEvent ( client, 'receiveMotd', resourceRoot, motdText, motdVersion )
end
)

addEvent('requestChangelog', true)
addEventHandler('requestChangelog', resourceRoot, 
function()
	triggerClientEvent ( client, 'receiveChangelog', resourceRoot, changelog, changelogLastUpdate )
end
)

addEvent('requestAdmins', true)
addEventHandler('requestAdmins', resourceRoot, 
function()
	triggerClientEvent ( client, 'receiveAdmins', resourceRoot, onlineAdmins )
end
)
---------------------
-- Fetch changelog --
---------------------
function startChangelogDownload()
	fetchRemote ( "https://github.com/JarnoVgr/Mr.Green-MTA-Resources/commits/master.atom/", receiveChangelog)
end

function receiveChangelog(responseData, errno)
	if errno == 0 then
		--Load previous log file and save new changelog
		outputDebugString("Received changelog data", 3)
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
		
	changelog = "Server changelog from https://github.com/JarnoVgr/Mr.Green-MTA-Resources/commits/master\r\n"
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

-------------------------------------------------------------
-- Saving motd ----------------------------------------------
-- player needs access to resource feature resource.*.motd --
-------------------------------------------------------------
function savemotd (motdText_)
	if not hasObjectPermissionTo(client,"resource." .. getResourceName(resource) .. ".motd",false) then
		return outputChatBox('You don\t have permission to use this', client, 255,0,0)
	end
	
	local motdNode = xmlLoadFile ( 'motd.xml' )
	motdVersion = (tonumber(xmlNodeGetAttribute(motdNode, 'version')) or 0) + 1
	xmlNodeSetValue(motdNode, motdText_)
	xmlNodeSetAttribute(motdNode, 'version', motdVersion)
	xmlNodeSetAttribute(motdNode, 'lastChanged', makeCurrentDatetime())
	xmlSaveFile ( motdNode )
	xmlUnloadFile(motdNode)
	motdText = motdText_
	outputChatBox('MOTD updated! Will show up once for all new visitors', client, 0, 255, 0)
end
addEvent('savemotd', true)
addEventHandler('savemotd', resourceRoot, savemotd)


------------------------------------------------------------------------------------------
-- makeCurrentDatetime() -----------------------------------------------------------------
-- Creates date and time (realtime, not ingame time) in the YYYY-MM-DD HH:MM:SS format. --
------------------------------------------------------------------------------------------
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

------------------------------------------------------------------------
-- fillDigits() --------------------------------------------------------
-- Adds leading zeros to a string, until it reaches a certain length. --
------------------------------------------------------------------------
function fillDigits(text, min)
	if min == nil then
		min = 2
	end
	local text = tostring(text)
	return string.rep( "0", min - text:len() )..text
end



addEventHandler("onPlayerLogin", root,
	function(_, account)
		for i=1, #admins do
			if getAccountName(account) == admins[i].accountName then
				onlineAdmins[i] = true
			end
		end
	end
)

addEventHandler("onPlayerLogout", root,
	function(account)
		for i=1, #admins do
			if getAccountName(account) == admins[i].accountName then
				onlineAdmins[i] = false
			end
		end
	end
)

addEventHandler("onResourceStart", resourceRoot,
	function()
		for _, player in pairs(getElementsByType("player")) do
			local account = getPlayerAccount(player)
			if account and not isGuestAccount(account) then
				for i=1, #admins do
					if getAccountName(account) == admins[i].accountName then
						onlineAdmins[i] = true
					end
				end
			end
		end
	end
)



addEvent("onRaceStateChanging")
addEventHandler("onRaceStateChanging", root,
	function(newStateName, oldStateName)
		if newStateName == "LoadingMap" then
			setTimer(triggerClientEvent, 5000, 1, root, 'receiveChangelog', resourceRoot, changelog, changelogLastUpdate, true)
		end
	end
)