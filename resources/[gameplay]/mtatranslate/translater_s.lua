local callT = {} -- {callID, player, from, original, target}
local callID = 0
local cc = {}
local chatbox = {}
local chatID = 0
local chatboxMax = 50
local geo = getResourceFromName("geoloc")

function translateGetTranslation(p, text, from, to, original, target)
	callID = callID + 1
	table.insert(callT, {callID, p, from, original, target})
	callRemote("http://mrgreengaming.com/mta/translate/mtatranslate.php", translateCallBack, callID, from, to, text)
end
addEvent("translateGetTranslation", true)
addEventHandler("translateGetTranslation", resourceRoot, translateGetTranslation)

function translateStart(p, commandName, text)
	triggerClientEvent(p,"translateOpenCloseGUI",resourceRoot)
end
addCommandHandler("translate", translateStart, true, true)

function translateCallBack(output)
	if output == nil then outputDebugString("MTA Translate: Translation error #1, callRemote error") return end -- Something went wrong with the callRemote in translateGetTranslation() function or the PHP script might give an error
	local p = false
	local from = ""
	local original = ""
	local target = ""
	local translation = output[4]
	local id = false
	for i,v in ipairs(callT) do
		if v[1] == output[1] then
			p = v[2]
			from = v[3]
			original = v[4]
			target = v[5]
			id = i
		end
	end
	
	if p == false then
		outputDebugString("MTA Translate: Translation error #2, translation data error") -- The data received as output doesn't correspond with anything stored in the table
	else
		triggerClientEvent(p,"translateSendTranslation",resourceRoot,translation, original, target, from)
	end
	if type(id) == "number" then table.remove(callT,i) else outputDebugString("MTA Translate: Translation error #3, call not removed") end -- The table which stores the translation data couldn't be cleand up
end

function chatMessage(message, messageType)
	if messageType == 0 or messageType == 1 then
		if getElementType(source) == "player" then
			local name = utf8.gsub(getPlayerNametagText(source), "#%x%x%x%x%x%x", "")
			local countryCode = getIP(source)
			chatID = chatID + 1
			table.insert(chatbox,{chatID,name,countryCode,message,"","","","",""}) -- {chatID, player, country code, message, from, to, translation, from flag, to flag}
		end
	end
	if #chatbox > chatboxMax then
		repeat
		table.remove(chatbox, 1)
		until #chatbox == chatboxMax
	end
end
addEventHandler("onPlayerChat", getRootElement(), chatMessage)

function translateFetchChatbox(p,chatID)
	local t = {}
	for i,v in ipairs(chatbox) do if v[1] > chatID then table.insert(t,v) end end
	triggerClientEvent(p,"translateSendChatbox",resourceRoot,t,chatID)
end
addEvent("translateFetchChatbox", true)
addEventHandler("translateFetchChatbox", resourceRoot, translateFetchChatbox)

function checkIP()
	local playerIP = getPlayerIP(source)
	for i,v in ipairs(cc) do
		if v[1] == playerIP then
			return
		end
	end
	local countryCode = ""
	if geo and getResourceState(geo) == "running" then
		if exports.geoloc:getPlayerCountry(source) then countryCode = exports.geoloc:getPlayerCountry(source) end -- implement geoloc in this resource
	end
	table.insert(cc,{playerIP,countryCode})
end
addEventHandler("onPlayerJoin", getRootElement(), checkIP)

--function removeIP()
--	local playerIP = getPlayerIP(source)
--	for i,v in ipairs(cc) do
--		if v[1] == playerIP then
--			table.remove(cc,i)
--		end
--	end
--end
--addEventHandler ( "onPlayerQuit", getRootElement(), removeIP)

function getIP(p)
	local playerIP = getPlayerIP(p)
	local countryCode = ""
	for i,v in ipairs(cc) do
		if v[1] == playerIP then
			countryCode = v[2]
		end
	end
	return countryCode
end