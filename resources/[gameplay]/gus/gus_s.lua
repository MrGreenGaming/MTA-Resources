-- playtime recorder
addEventHandler("onResourceStart", root,
    function(resource)
		if (resourceRoot == source or getResourceName ( resource ) == 'scoreboard') then
			exports.scoreboard:addScoreboardColumn("playtime", root, 35)
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
addEventHandler('onResourceStart' , root, function()	-- root for updating w/e
	adminapplicants = {}
	local xml = xmlLoadFile("adminapplicants.xml")
	if not xml then return end
	for k, a in ipairs(xmlNodeGetChildren(xml)) do
		adminapplicants[tonumber(xmlNodeGetAttribute(a, 'forumid'))] = xmlNodeGetAttribute(a, 'nick')
	end
	xmlUnloadFile(xml)
end)

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
		outputChatBox("Upload your maps at our forums: www.mrgreengaming.com", player, 0, 255, 0)
	end
)

addCommandHandler('upload',
	function(player)
		outputChatBox("Upload your maps at our forums: www.mrgreengaming.com", player, 0, 255, 0)
	end
)

addCommandHandler('uploadmap',
	function(player)
		outputChatBox("Upload your maps at our forums: www.mrgreengaming.com", player, 0, 255, 0)
	end
)

addCommandHandler('irc',
	function(player)
		outputChatBox("Join our IRC Channel! If you need admin support, join the channel and ask for an admin", player, 0, 255, 0)
		outputChatBox("IRC Server: maple.nl.eu.gtanet.com IRC Channel: #mrgreen", player, 0, 255, 0)
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
		local nick = getPlayerName(player)
		if not arg then
			outputChatBox(nick.."#FFD700 is laughing out loud.", root, 255, 215, 0, true)
			exports.irc:outputIRC("7* " .. string.gsub(getPlayerName(player), '#%x%x%x%x%x%x', '' ) .. " is laughin out loud." )
			g_lolPlayers[player] = getTickCount()
		else
			local who = findPlayerByName(arg)
			if not who then outputChatBox("No player found", player)
			else
				local whoName = getPlayerName(who)
				outputChatBox(nick.."#FFD700 is laughing out loud at "..whoName, root, 255, 215, 0, true)
				exports.irc:outputIRC("7* " .. string.gsub(getPlayerName(player), '#%x%x%x%x%x%x', '' ) .. " is laughin out loud at "..string.gsub(whoName, '#%x%x%x%x%x%x', '' ) )
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
-- addEventHandler("onPlayerChat", getRootElement(), gclogin)	

-- addEventHandler('onPlayerChat', getRootElement(),
-- function(message)
	-- if string.find(string.lower(message) , "cheat") or string.find(string.lower(message) , "hack") then
		-- outputChatBox("If somebody is cheating, please use /report", source, 255, 0, 0)
		-- outputChatBox("It will PM online admins both in-game and in IRC (if any).", source, 255, 0, 0)
	-- end	
-- end
-- )

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
	end)



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
theTable = {"̍", "̎", "̄", "̅", "̑", "̆", "̐", "͒", "͗", "͑", "̇", "̈", "͂", "̓", "̈́", "͋", "͌", "̂", "̌", "͐", "̋", "̏", "̒", "̓", "̔", "̽", "ͣ", "ͤ", "ͦ", "ͧ", "ͨ", "ͪ", "ͫ", "ͬ", "ͭ", "ͮ", "ͯ", "̾", "͛", "͆", "̚", "̖", "̗", "̘", "̙", "̜", "̝", "̞", "̟", "̠", "̤", "̥", "̦", "̩", "̪", "̫", "̬", "̭", "̮", "̯", "̰", "̱", "̲", "̳", "̹", "̺", "̻", "̼", "ͅ", "͇", "͈", "͉", "͍", "͎", "͓", "͔", "͕", "͖", "͙", "͚"}

addEventHandler("onPlayerChat",root,
	function(message) 
		for _,char in ipairs(theTable) do 
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