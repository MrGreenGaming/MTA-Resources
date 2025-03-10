local onlineAdmins = {}

motdText, changelog = '', false
motdVersion, changelogLastUpdate = 0, ""
	
function start()
	local motdNode = fileExists('motd.xml') and xmlLoadFile('motd.xml') or xmlCreateFile('motd.xml', 'motd')
	motdVersion = tonumber(xmlNodeGetAttribute(motdNode, 'version'))
	motdText = xmlNodeGetValue(motdNode) or ''
	xmlUnloadFile(motdNode)
end
addEventHandler('onResourceStart', resourceRoot, start)


addEvent('requestMOTD', true)
addEventHandler('requestMOTD', resourceRoot, 
function()
	triggerClientEvent ( client, 'receiveMotd', resourceRoot, motdText, motdVersion )
end
)

addEvent('requestAdmins', true)
addEventHandler('requestAdmins', resourceRoot, 
function()
	triggerClientEvent ( client, 'receiveAdmins', resourceRoot, onlineAdmins )
end
)

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
				return
			end
		end
	end
)

addEventHandler("onPlayerLogout", root,
	function(account)
		for i=1, #admins do
			if getAccountName(account) == admins[i].accountName then
				onlineAdmins[i] = false
				return
			end
		end
	end
)

addEventHandler ("onPlayerQuit", root, 
	function()
		local account = getPlayerAccount(source)
		if not account then return end
		
		for i=1, #admins do
			if getAccountName(account) == admins[i].accountName then
				onlineAdmins[i] = false
				return
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