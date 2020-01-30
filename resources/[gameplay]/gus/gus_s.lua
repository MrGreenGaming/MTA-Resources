-- playtime recorder
addEventHandler("onResourceStart", root,
    function(resource)
		if (resourceRoot == source or getResourceName ( resource ) == 'scoreboard') then
			exports.scoreboard:scoreboardAddColumn("playtime", root, 60, "Playtime", 50)
		end
		if getResourceInfo(resource, "type") ~= "map" then
			outputDebugString("********* Started: " .. getResourceName(resource))
		end
    end
)
addEventHandler("onResourceStop", root,
	function(resource)
		if source == getResourceRootElement(getThisResource()) then
			exports.scoreboard:removeScoreboardColumn("playtime", root, 35)
		end
		if getResourceInfo(resource, "type") ~= "map" then
			outputDebugString("********* Stopped: " .. getResourceName(resource))
		end
	end
)

-- /playtime recorder


function freecam(p)
	triggerClientEvent(p, 'freecam', resourceRoot)
end
addCommandHandler('freecam', freecam, true)

addEvent("autologin",true)
addEventHandler("autologin",root,
function(user,pass)
	if not isGuestAccount(getPlayerAccount(client)) then return end
	local b
	if getAccount(user) then
		b = logIn(client,getAccount(user),pass)
	end
	if b then
		outputChatBox("You have been automatically logged in to #FFFFFF"..user.."'s#00FF00 account!",client,0,255,0,true)
		outputChatBox("To disable AutoLogin, use /autologin!",client,0,255,0,true)
	else
		outputChatBox('/autologin: wrong login/password', client, 255,0,0)
	end
end )
addEventHandler('onPlayerLogin', root, function(_, acc) if acc then setAccountData(acc, 'lastLogin', getRealTime().timestamp) end end)

addEventHandler("onElementDataChange", root,
    function(dataName, oldValue)
        -- Check data is coming from a client
        if client and getElementType(source) == 'player' and client ~= source then
 
			-- Report
			outputConsole( "Possible rouge client!"
					.. " client:" .. tostring(getPlayerName(client))
					.. " dataName:" .. tostring(dataName)
					.. " oldValue:" .. tostring(oldValue)
					.. " newValue:" .. tostring(getElementData(source,dataName))
					.. " source:" .. tostring(source)
					)
			-- Revert (Note this will cause an onElementDataChange event, but 'client' will be nil)
			setElementData( source, dataName, oldValue )               
        end
    end
)

-- Helper function to log and revert changes
function reportAndRevertDataChange( dataName, oldValue, source, client )
end


addCommandHandler('admins',
	function(player)
		local awayString = " (away)"
        local admins = {}
        for k, v in ipairs (getElementsByType("player")) do
            if hasObjectPermissionTo ( v, "general.adminpanel", false ) then
            	local away = ""
            	if exports.anti:isPlayerAFK(v) then
            		away = awayString
            	end
                admins[#admins+1] = getPlayerName(v)..away
            end
        end

        local moderators = {}
        for k, v in ipairs (getElementsByType("player")) do
            if hasObjectPermissionTo ( v, "command.k", false ) and not hasObjectPermissionTo ( v, "general.adminpanel", false ) then
            	local away = ""
            	if exports.anti:isPlayerAFK(v) then
            		away = awayString
            	end
                moderators[#moderators+1] = getPlayerName(v)..away
            end
        end

        local applicants = {}
        for k, v in ipairs (getElementsByType("player")) do
            if getElementData ( v, "adminapplicant" ) then
                applicants[#applicants+1] = getPlayerName(v)
            end
        end

        if #admins == 0 then
            outputChatBox('No admins online at the moment.', player, 0, 255, 0)
        else
            local adminstring = admins[1]
            if #admins > 1 then
                table.remove ( admins, 1 )
                for k, v in ipairs(admins) do
                    adminstring = adminstring..", "..v
                end
            end
			adminstring = string.gsub (adminstring, '#%x%x%x%x%x%x', '' )
            outputChatBox('Online admins: ' .. adminstring, player, 0, 255, 0)
        end

        if #moderators == 0 then
            outputChatBox('No moderators online at the moment.', player, 0, 255, 0)
        else
            local killerstring = moderators[1]
            if #moderators > 1 then
                table.remove ( moderators, 1 )
                for k, v in ipairs(moderators) do
                    killerstring = killerstring..", "..v
                end
            end
			killerstring = string.gsub (killerstring, '#%x%x%x%x%x%x', '' )
            outputChatBox('Online moderators: ' .. killerstring, player, 0, 255, 0)
        end

        if #applicants > 0 then
            outputChatBox('Online admin applicants: ' .. string.gsub(table.concat(applicants, ', '),'#%x%x%x%x%x%x', ''), player, 0, 255, 0)
        end
	end
)

local adminapplicants = {}
-- Update applicants on an interval instead of 'onResourceStart'
function getAdminApplicants()
	adminapplicants = {}
	local xml = xmlLoadFile("adminapplicants.xml")
	if not xml then return end
	for k, a in ipairs(xmlNodeGetChildren(xml)) do
		adminapplicants[tonumber(xmlNodeGetAttribute(a, 'forumid'))] = xmlNodeGetAttribute(a, 'nick')
	end
	xmlUnloadFile(xml)
end
setTimer(getAdminApplicants, 30 * 60000, 0)
addEventHandler('onResourceStart', resourceRoot, getAdminApplicants)

function gcLogin ( forumID, amount )
	if adminapplicants[forumID] then
		setElementData(source, 'adminapplicant', adminapplicants[forumID] , false)
		exports.irc:outputIRC("3*** Admin applicant " .. getPlayerName(source) .. " 13" .. adminapplicants[forumID] )
	end
end
addEventHandler("onGCLogin" , root, gcLogin )

function gcLogout ()
	if getElementData ( source, "adminapplicant" ) then
		exports.irc:outputIRC("2*** Admin applicant " .. getPlayerName(source) .. " 13" .. getElementData ( source, "adminapplicant" ) )
		removeElementData(source, 'adminapplicant')
	end
end
addEventHandler("onGCLogout" , root, gcLogout )

addCommandHandler('author',
function(player)
	local map = exports.mapmanager:getRunningGamemodeMap()
	if map then
		local author = getResourceInfo(map, 'author') or 'N/A'
		outputChatBox('\''..(getResourceInfo(map, 'name') or getResourceName(map)) .. '\' has been created by '..author, player, 0, 255, 0)
	end
end
)

addCommandHandler('mapupload',
	function(player)
		outputChatBox("Upload your maps at our forums: www.mrgreengaming.com/mta/mapupload", player, 0, 255, 0)
	end
)

addCommandHandler('upload',
	function(player)
		outputChatBox("Upload your maps at our forums: www.mrgreengaming.com/mta/mapupload", player, 0, 255, 0)
	end
)

addCommandHandler('uploadmap',
	function(player)
		outputChatBox("Upload your maps at our forums: www.mrgreengaming.com/mta/mapupload", player, 0, 255, 0)
	end
)

addCommandHandler('discord',
	function(player)
		outputChatBox("Join our Discord! If you need admin support, join the server and ask for an admin", player, 0, 255, 0)
		outputChatBox("Discord invite: https://discord.gg/SjbzC9Z", player, 0, 255, 0)
	end
)



addCommandHandler('pm',
	function(player)
		outputChatBox("Use /msg [nick] [text]", player, 255, 0, 0)
	end
)

g_lolPlayers = {}
addCommandHandler("lol",
    function(player, cmd, arg)
		if g_lolPlayers[player] and getTickCount() - g_lolPlayers[player] < 5000 then return end
		if isPlayerMuted(player) or chat_is_disabled then outputChatBox('You\'re muted.', player) return end
		local nick = getElementData(player, "vip.colorNick") or getPlayerName(player)
		if not arg then
			outputChatBox(nick.."#FFD700 is laughing out loud.", root, 255, 215, 0, true)
			exports.irc:outputIRC("7* " .. string.gsub(getPlayerName(player), '#%x%x%x%x%x%x', '' ) .. " is laughing out loud." )
			g_lolPlayers[player] = getTickCount()
		else
			local who = findPlayerByName(arg)
			if not who then outputChatBox("No player found", player)
			else
				local whoName = getElementData(who, "vip.colorNick") or getPlayerName(who)
				local lolString = nick.."#FFD700 is laughing out loud at "..whoName
				if string.len(lolString) > 256 then
					outputChatBox(nick.."#FFD700 is laughing out loud at "..string.gsub(whoName, '#%x%x%x%x%x%x', '' ), root, 255, 215, 0, true)
				else
					outputChatBox(lolString, root, 255, 215, 0, true)
				end
				
				exports.irc:outputIRC("7* " .. string.gsub(getPlayerName(player), '#%x%x%x%x%x%x', '' ) .. " is laughing out loud at "..string.gsub(whoName, '#%x%x%x%x%x%x', '' ) )
				g_lolPlayers[player] = getTickCount()
			end
		end	
    end
)

addEventHandler('onPlayerQuit', root, function() g_lolPlayers[source] = nil end)



addCommandHandler('song',
function(playerName, commandName)
	local map = exports.mapmanager:getRunningGamemodeMap()
	if map then
		local name = getResourceName(map)
		outputChatBox('If this map has a song, it has been downloaded into your computer. You can find it in:', playerName, 255,255,255)
		outputChatBox('Multi Theft Auto/mods/deathmatch/resources/'..name..'/ folder.',playerName, 255, 0, 0)
	end
end
)

function gclogin( message, messageType )
	if messageType == 0 then
		if (string.find(message, "gclogin", 1, true) == 1) or (string.find(message, "gclogin", 1, true) == 2) or (string.find(message, "gclogin", 1, true) == 3) or (string.find(message, "login", 1, true) == 1) then
			cancelEvent()
			outputChatBox("The correct command is /gclogin, do not misspell it",source,255,255,0)
		end
	end	
end

--DD Ghost car testing
local movedVehs = {}
function cleanGhostCar()
	-- outputDebugString("Alive:"..tostring(#getAlivePlayers()).." cars:"..tostring(#getElementsByType("vehicle")))
	local ghostCars = {}
	local vehicles = getElementsByType("vehicle")
	for _,veh in pairs(vehicles) do
		if not getVehicleOccupant( veh ) then
			-- and getElementAlpha(veh) < 255
			table.insert(ghostCars,veh)
		end
	end

	if #ghostCars > 0 then
		-- outputDebugString(tostring(#ghostCars).." veh's shifted")
		for _,ghost in pairs(ghostCars) do
			if not movedVehs[ghost] then
				-- local x,y,z = getElementPosition(ghost)
				setElementPosition(ghost,0,0,0-200)
				movedVehs[ghost] = true
			end

		end
	end
end


addEvent("onRaceStateChanging")
addEventHandler("onRaceStateChanging", root,
	function(state)
		if state == "Running" and exports.race:getRaceMode() == "Destruction derby" then
			GhostCarCleanupTimer = setTimer(cleanGhostCar,5000,0)
			movedVehs = {}
		elseif state == "LoadingMap" then
			-- handleRoundCount(exports.mapmanager:getRunningGamemodeMap())
		else
			if isTimer(GhostCarCleanupTimer) then 
				killTimer(GhostCarCleanupTimer)
			end
		end
		if state == "GridCountdown" then
			correctWeather()
		end
	end
)

-- /round command
local roundCount
addCommandHandler("round",
	function(player,command)
		if not player or not roundCount then return end

		outputChatBox(roundCount,player,255,255,255,true)
	end	)

addEvent("onGamemodeMapStart")

addEvent("onRoundCountChange",true)
function handleRoundCount(round,max)
	local max = max+1 -- max plus 1st round
	if round >= max then -- Round can get bigger then max because of /redo and map restarting.
		roundCount = "Currently playing round: #FF0000"..tostring(max).."/"..tostring(max)
	else
		roundCount = "Currently playing round: #00CD00"..tostring(round).."/"..tostring(max)
	end


	outputChatBox(roundCount,root,255,255,255,true)

end
addEventHandler("onRoundCountChange",root,handleRoundCount)

--Make sure map objects are restored server-side as some disappear for some reason
addEvent('onGamemodeMapStop', true)
addEventHandler('onGamemodeMapStop', root,
function()
	restoreAllWorldModels()
end
)


-- Remove /me chat
addEventHandler ( "onPlayerChat", root, function ( _, tp )
    if ( tp == 1 ) then
    	outputChatBox("/me messages are disabled in this server", source, 255, 0, 0)
        cancelEvent ( )
    end
end )

-- Wierd corrupted char prevention
local corruptedChars = {"̍", "̎", "̄", "̅", "̑", "̆", "̐", "͒", "͗", "͑", "̇", "̈", "͂", "̓", "̈́", "͋", "͌", "̂", "̌", "͐", "̋", "̏", "̒", "̓", "̔", "̽", "ͣ", "ͤ", "ͦ", "ͧ", "ͨ", "ͪ", "ͫ", "ͬ", "ͭ", "ͮ", "ͯ", "̾", "͛", "͆", "̚", "̖", "̗", "̘", "̙", "̜", "̝", "̞", "̟", "̠", "̤", "̥", "̦", "̩", "̪", "̫", "̬", "̭", "̮", "̯", "̰", "̱", "̲", "̳", "̹", "̺", "̻", "̼", "ͅ", "͇", "͈", "͉", "͍", "͎", "͓", "͔", "͕", "͖", "͙", "͚"}

addEventHandler("onPlayerChat",root,
	function(message) 
		for _,char in ipairs(corruptedChars) do 
			if string.find(message,char) then 
				cancelEvent() 
				outputChatBox("You used a corrupted character (      "..char..char..char..char..char..char..char..char..char..char..char..char..char..char..char..char..char..char.."      ) , please stop!",source,255,0,0) -- Multiplied to show character
				break 
			end 
		end
	end)

-- Correct weather
function correctWeather()
	if getWeather() > 20 then

		outputDebugString("Weather changed from "..tostring(getWeather()).." to 1.")
		setWeather(1)
	end
end

--------------------------------
-- Dice / Haxardous
--------------------------------

addCommandHandler('dice',
    function()
    	-- Needs a cooldown handler
		-- local g_rn = math.random(1,6)
		-- outputChatBox ("#00EC0B[#FFFFFFDice#00EC0B] A random number between 1 & 6 / Result: #FFFFFF".. g_rn .."#00EC0B.", source, 255, 255, 255, true)
	end
)

--------------------------------
-- Ghostmode at finish
--------------------------------
addEvent('onPlayerFinish')
addEventHandler( 'onPlayerFinish', root, 
function() 
	if getElementType(source) == 'player' then
		setElementData(source, 'overrideCollide.finishghostmode', 0, false)
		-- Element data will automatically be removed
	end
end)


--------------------------------
-- Fix for flickering objects when going through a removed world object.
--------------------------------
function handleOcclusions(mapInfo)
	local resName = mapInfo.resname
	local mapRes = getResourceFromName( resName )
	local mapResourceRoot = getResourceRootElement(mapRes )
	if not resName or not mapRes or not mapResourceRoot then return end

	if #getElementsByType ( "removeWorldObject", mapResourceRoot ) > 0 then
		setOcclusionsEnabled( false )
	else
		setOcclusionsEnabled( true )
	end
end
addEvent('onMapStarting')
addEventHandler('onMapStarting', root, handleOcclusions)

--------------------------------
-- Streak
--------------------------------
local currentStreakPlayer;
local currentPlayerStreakCount = 0;
local requiredPlayersToRecordAStreak = 10;

function getGreenCoinsAmountForStreak()
	if (currentPlayerStreakCount == 2) then
		return 10;
	elseif (currentPlayerStreakCount == 3) then
		return 15;
	elseif (currentPlayerStreakCount == 4) then
		return 20;
	elseif (currentPlayerStreakCount >= 5) then
		return 25;
	end
end

addEventHandler('onPlayerFinish', root, 
	function(rank) 
		if (getPlayerCount() >= requiredPlayersToRecordAStreak) then
			if (rank == 1) then
				if (currentStreakPlayer ~= source) then
					currentStreakPlayer = source
					currentPlayerStreakCount = 1;
				else
					if (currentStreakPlayer) then
						currentPlayerStreakCount = currentPlayerStreakCount+1;
						exports.gc:addPlayerGreencoins(source, getGreenCoinsAmountForStreak())
						outputChatBox("[Streak]"..getPlayerName(currentStreakPlayer).." #00ff00has made a streak! (#FFFFFFX".. currentPlayerStreakCount.."#00ff00) (earned "..getGreenCoinsAmountForStreak().."GC)", root, 0, 255, 0, true)
					end
				end
			end
		else
			if (rank == 1) then
				outputChatBox("There aren't enough players online to record this streak. ("..getPlayerCount().."/"..requiredPlayersToRecordAStreak..")", root, 0, 255, 0)
			end
		end
    end
)

function triggerStreakForOtherGamemodes()
	if (getPlayerCount() >= requiredPlayersToRecordAStreak) then
		if (currentStreakPlayer ~= source) then
			currentStreakPlayer = source
			currentPlayerStreakCount = 1;
		else
			if (currentStreakPlayer) then
				currentPlayerStreakCount = currentPlayerStreakCount+1;
				exports.gc:addPlayerGreencoins(source, getGreenCoinsAmountForStreak())
				outputChatBox("[Streak]"..getPlayerName(currentStreakPlayer).." #00ff00has made a streak! (#FFFFFFX".. currentPlayerStreakCount.."#00ff00) (earned "..getGreenCoinsAmountForStreak().."GC)", root, 0, 255, 0, true)
			end
		end
	else
		outputChatBox("There aren't enough players online to record this streak. ("..getPlayerCount().."/"..requiredPlayersToRecordAStreak..")", root, 0, 255, 0)
	end
end
addEventHandler("onPlayerWinDD", root, triggerStreakForOtherGamemodes)
addEventHandler("onPlayerWinShooter", root, triggerStreakForOtherGamemodes)
addEventHandler("onPlayerWinDeadline", root, triggerStreakForOtherGamemodes)

--------------------------------
-- admin floating message
--------------------------------
function isPlayerInACL(player, acl)
	if isElement(player) and getElementType(player) == "player" and aclGetGroup(acl or "") and not isGuestAccount(getPlayerAccount(player)) then
		local account = getPlayerAccount(player)
		
		return isObjectInACLGroup( "user.".. getAccountName(account), aclGetGroup(acl) )
	end
	return false
end

function sendMessageToAllPlayers(thePlayer, commandName, ...)
	local message = table.concat({...}, " ")
	if (isPlayerInACL(thePlayer, "Admin")) then
		if (...) then
			exports.messages:outputGameMessage(message, who or root, nil, 255, 153, 51)
		else 
			outputChatBox("SYNTAX: /"..commandName.." [text]", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("msgall", sendMessageToAllPlayers, false, false)
