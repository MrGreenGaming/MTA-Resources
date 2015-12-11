function adsay(player, c, ...) 			-- Admin chat 
	if not (hasObjectPermissionTo(player, "function.banPlayer", false)) then
		return
	end
	
	local message = table.concat({...}, ' ')
	
	for k, v in ipairs (getElementsByType("player")) do
		if hasObjectPermissionTo ( v, "general.adminpanel", false ) then
			outputChatBox ( "ADMIN> "..string.gsub ( (getPlayerName(player)), '#%x%x%x%x%x%x', '' )..": "..message, v, 255, 0, 0,true )
		end
	end

end
addCommandHandler('adsay', adsay)

addCommandHandler('achat', 
function(player, cmd, ...)
	if hasObjectPermissionTo(player, "function.banPlayer", false) then
	    local langs = {'ca', 'cs', 'da', 'de', 'en_us', 'en_gb', 'en_au', 'es', 'fi', 'fr', 'hi', 'ht', 'hu', 'id', 'it', 'ja', 'ko', 'la', 'nl', 'no', 'pl', 'pt', 'ru', 'sk', 'sv', 'tr', 'zh'}
	    -- local langs = {'af', 'ar', 'az', 'be', 'bg', 'bn', 'ca', 'cs', 'cy', 'da', 'de', 'el', 'en', 'en_us', 'en_gb', 'en_au', 'eo', 'es', 'et', 'eu', 'fa', 'fi', 'fr', 'ga', 'gl', 'gu', 'hi', 'hr', 'ht', 'hu', 'id', 'is', 'it', 'iw', 'ja', 'ka', 'kn', 'ko', 'la', 'lt', 'lv', 'mk', 'ms', 'mt', 'nl', 'no', 'pl', 'pt', 'ro', 'ru', 'sk', 'sl', 'sq', 'sr', 'sv', 'sw', 'ta', 'te', 'th', 'tl', 'tr', 'uk', 'ur', 'vi', 'yi', 'zh', 'zh-CN', 'zh-TW'}
		local lang = langs[math.random(#langs)]
		outputChatBox(lang, player)
		triggerClientEvent(getRootElement(), "onGameMessageSend2", getRootElement(), table.concat({...}, " "),lang)
	end
end
)

function findPlayerByName(playerPart)
	local pl = getPlayerFromName(playerPart)
	if isElement(pl) then
		return pl
	else
		for i,v in ipairs (getElementsByType ("player")) do
			if (string.find(string.gsub ( string.lower(getPlayerName(v)), '#%x%x%x%x%x%x', '' ),string.lower(playerPart))) then
				return v
			end
		end
    end
 end
 
function removePlayerFromTimes(player)
	local nameOfPlayer = getPlayerName(player)
	local map_names = {}
	for k, v in ipairs(exports.mapmanager:getMapsCompatibleWithGamemode(getResourceFromName('race'))) do
		map_names['race maptimes Sprint ' .. (getResourceInfo(v, 'name' ) or getResourceName(v))] = v
	end
	local maps_table = executeSQLQuery( "SELECT tbl_name FROM sqlite_master WHERE tbl_name LIKE 'race maptimes Sprint %' " )
	for k, v in ipairs(maps_table) do
			local mapTable = v.tbl_name
			if map_names[mapTable] then
				local mapTimes = executeSQLQuery( "SELECT playerName, playerSerial FROM ?", mapTable)
				for i, t in ipairs ( mapTimes ) do
					if (t.playerName == nameOfPlayer) and (t.playerSerial == getPlayerSerial(player)) then
						executeSQLDelete("'"..mapTable.."'", "playerName = '"..nameOfPlayer.."'")
					end
				end
			end
		end
end
 

function serialBan(player, commandName, ...)
	if not (hasObjectPermissionTo(player, "function.banPlayer", false)) then
		return 
	end
	local parameterCount = #arg
	if (arg[1]) then
		bannedPlayer = findPlayerByName(arg[1])
		if bannedPlayer then
			if #arg < 2 then
				local reason = "(Nick: "..getPlayerName(bannedPlayer)..") - No Reason"
				--[[removePlayerFromTimes(bannedPlayer)
				outputChatBox(getPlayerName(bannedPlayer).."'s global toptimes have been deleted.", player)
				outputChatBox("Current map's (if existent) needs to be deleted manually", player)]]
				-- ^ TOO LAGGY.
				addBan ( getPlayerIP(bannedPlayer), nil, getPlayerSerial(bannedPlayer), player, reason)
			else
				arg[1] = "(Nick: "..getPlayerName(bannedPlayer)..")"
				local fullReason = table.concat(arg, " ")
				--[[removePlayerFromTimes(bannedPlayer)
				outputChatBox(getPlayerName(bannedPlayer).."'s global toptimes have been deleted.", player)
				outputChatBox("Current map's (if existent) needs to be deleted manually", player)]]
				-- ^ TOO LAGGY.
				addBan(getPlayerIP(bannedPlayer), nil, getPlayerSerial(bannedPlayer), player , fullReason )
			end	
		else 
			outputChatBox('No player matches that nickname', player, 255, 0, 0)
		end
	else 
		outputChatBox('Correct command: /sban [nick] [reason]', player, 255, 0, 0)
	end	
end	
addCommandHandler('sban', serialBan)

-- /update
local updates = {}
function updateCMD(p, c, resname)
	local res = getResourceFromName(resname)
	if not res then
		outputChatBox(c .. ': res ' .. tostring(resname) .. ' not found', p, 255)
	else
		table.insert(updates, {resname, p})
		outputChatBox(c .. ': restarting ' .. tostring(resname) .. ' after map is finished', p, 255)
	end
end
addCommandHandler('update', updateCMD, true, true)

addEvent'onPostFinish'
addEventHandler('onPostFinish', root, function()
	for k, v in ipairs(updates) do
		local resname, p = v[1], v[2]
		local res = getResourceFromName(resname)
		if res then
			setTimer(function()
				outputChatBox('update: res ' .. tostring(resname) .. ' updating', p, 255)
				if getResourceState(res) == 'running' then
					restartResource(res)
				else
					startResource(res)
				end
			end, 500*(k), 1)
		else
			outputChatBox('update: res ' .. tostring(resname) .. ' not found', p, 255)
		end
	end
	updates = {}
end)

-- /k
function logKillAction(playerResponsible, playerKilled, reason)
    local file
    if fileExists("killers.log") then
        file = fileOpen("killers.log")
    else
        file = fileCreate("killers.log")
    end
    local dateTime = getRealTime().monthday.."."..tostring(getRealTime().month+1).."."..tostring(getRealTime().year+1900).." - "..getRealTime().hour..":"..getRealTime().minute
    playerResponsible = getPlayerName(playerResponsible)
    playerKilled = getPlayerName(playerKilled)
    local fullString = dateTime.." "..playerResponsible.." killed "..playerKilled.." for: "..reason
    fileSetPos(file, fileGetSize(file))
    fileWrite(file, "\n"..fullString)
    fileClose(file)
end

function blowUp(player, commandName, ...)
	if #arg < 2 then outputChatBox("Correct command: /k [nick] [full reason]", player, 0, 255, 0) return end
	if arg[1] then
		local blowPlayer = findPlayerByName(arg[1])
		if blowPlayer then
			if blowPlayer == player then
				return outputChatBox ( 'Don\'t use /k for fun, no fun allowed in this server!', player, 0, 255, 0)
			end
			local car = getPedOccupiedVehicle(blowPlayer)
			if not isPedDead(blowPlayer) and car and not isElementFrozen(car) then
				blowVehicle(car, false)
				outputChatBox(remcol(getPlayerName(player)).." has killed "..remcol(getPlayerName(blowPlayer)).. ". Reason: "..table.concat(arg, " ", 2), root, 255, 0, 0)
				if useIRC() then
                    exports.irc:outputIRC("05** "..remcol(getPlayerName(player)).." has killed "..remcol(getPlayerName(blowPlayer)).. ". Reason: "..table.concat(arg, " ", 2))
                    logKillAction(player, blowPlayer, table.concat(arg, " ", 2))
				end
			else
				outputChatBox('The player is currently dead', player, 255, 0, 0)
			end
		else
			outputChatBox("No player found", player, 0, 255,0)
		end
	else
		outputChatBox("Correct command: /k [nick] [full reason]", player, 0, 255, 0)
	end
end
addCommandHandler('k', blowUp, true, true)





function useIRC()
    if getResourceFromName('irc') and getResourceState(getResourceFromName('irc')) == 'running' and exports.irc then
        return true
    end
    return false
end

addCommandHandler('addban', 
function(player,cmd,...)
	if not (hasObjectPermissionTo(player, "function.banPlayer", false)) then
		return 
	end
	if not (arg[1]) then outputChatBox("State the player's full name (no color codes).",player) return end
	local banPlayerName = string.gsub (arg[1], '#%x%x%x%x%x%x', '' )
	local theInfo = getSerial(banPlayerName)
	if theInfo then
		local theSerial = theInfo.serial
		local theIP = theInfo.ip
		local reason = "(Nick: "..banPlayerName..") - No reason specified"
		if (#arg>1) then
			reason = ""
			arg[1] = "(Nick: "..banPlayerName..") - "
			reason = table.concat(arg," ")
		end
		theBan = addBan(theIP, nil, theSerial, player, reason, 0)
		if not theBan then outputChatBox("An error has occured. Can't ban player.", player)
		else outputChatBox("Successfully banned.", player)
			 outputChatBox(remcol(banPlayerName).." has been banned by "..remcol(getPlayerName(player)),root, 255,0,0)	
		end
	else outputChatBox("No player match. Try again.", player)	
	end
end
)

chat_is_disabled = false
playerResponsible = nil

function disableChat(p)
	if not (hasObjectPermissionTo(p, "function.banPlayer", false)) or chat_is_disabled then
		return
	end
	addEventHandler('onPlayerChat', root, chatIsOff)
	chat_is_disabled = true
	outputChatBox('Chatbox is disabled by ' .. remcol(getPlayerName(p)) .. '!', root, 238,201,0)
	playerResponsible = p
end
addCommandHandler('chatoff', disableChat)

function clearChat(p)
	if not (hasObjectPermissionTo(p, "function.banPlayer", false)) then
		return
	end
	for i=1,200 do
		outputChatBox(" ", root)
	end
	outputChatBox('Chatbox cleared by ' .. remcol(getPlayerName(p)) .. '!', root, 238,201,0)
end
addCommandHandler('clearchat', clearChat)

function enableChat(p)
	if not (hasObjectPermissionTo(p, "function.banPlayer", false)) or not chat_is_disabled then
		return
	end
	removeEventHandler('onPlayerChat', root, chatIsOff)
	chat_is_disabled = false
	outputChatBox('Chatbox is enabled again by ' .. remcol(getPlayerName(p)) .. '!', root, 238,201,0)
	playerResponsible = nil
end
addCommandHandler('chaton', enableChat)

function chatIsOff()
	if (hasObjectPermissionTo(source, "function.banPlayer", false)) then
		return
	end
	outputChatBox('Chatbox is currently disabled.', source, 0, 255, 0)
	cancelEvent()
end

function chatDisabled()
	return chat_is_disabled
end

addEventHandler('onPlayerQuit', root,
function()
    if playerResponsible and source == playerResponsible then
        removeEventHandler('onPlayerChat', root, chatIsOff)
        chat_is_disabled = false
        outputChatBox('Chatbox is enabled again!', root, 238,201,0)
        playerResponsible = nil
    end
end
)

--facilitating map deletion--
--it puts the deleted maps in resource-cache/trash folder
-- addEvent('onMapStarting', true)

-- function onNewMapStart()
--     local map = g_Map
--     if map == exports.mapmanager:getRunningGamemodeMap() then   --if map that was deleted gets replayed before deletion, halt deletion for the next map.
--         return
--     end
--     local name = getResourceInfo(map, "name")
--     local delete = deleteResource(getResourceName(map))
--     if not delete then
--         if isElement(g_P) then outputChatBox("Error: Map cannot be deleted.", g_P) end
--         canUseCommand = true
--         g_Map = nil
--         g_P = nil
--         removeEventHandler('onMapStarting', root, onNewMapStart)
--         return
--     end
--     if isElement(g_P) then
--         outputChatBox("Map deleted: "..name, g_P)
--     end
--     refreshResources()
--     canUseCommand = true
--     g_Map = nil
--     g_P = nil
--     removeEventHandler('onMapStarting', root, onNewMapStart)
-- end

-- canUseCommand = true
-- g_Map = nil
-- g_P = nil

-- addCommandHandler('deletemap',
-- function(p)
--     --powerful command. should be used only by staff. add ur name if u want access
--     -- if (getPlayerName(p) ~= "BinSlayer" and getPlayerName(p) ~= "#CC22CCH#FFFF00ulpje") then return end
--     --second check, just to be sure.
--     if not (hasObjectPermissionTo(p, "function.banPlayer", false)) then return end
--     --get current map running, copy it over as a backup and delete it from map list via refresh.
--     if not canUseCommand then outputChatBox("Error: Can't use command. An admin has already deleted this map.", p) return end
--     local map = exports.mapmanager:getRunningGamemodeMap()
--     if not map then outputChatBox("Error: No map.", p) return end
--     outputChatBox("Deleting current map at the start of the next map!", root, 255, 0, 0)
--     g_Map = map
--     g_P = p
--     addEventHandler('onMapStarting', root, onNewMapStart)
--     canUseCommand = false
-- end
-- )

function remcol(str)
	return string.gsub (str, '#%x%x%x%x%x%x', '' )
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end
