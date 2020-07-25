----------------------------------------------
-- Ping checker, sends a request to client,	--
-- client checks if downloading, responds,	--
-- server double-checks and kicks if needed	--
-- Also does check for stuck 0-ping players --
----------------------------------------------

local pingLimit1 = 300
local pingLimit2 = 350
local hour1 = 0
local hour2 = 8
local pingCheckTime = 5 * 1000


-------------------
-- Checking ping --
-------------------

addEventHandler ( "onResourceStart", resourceRoot,
	function()
		setTimer(checkPing, pingCheckTime, 0)	
	end
)


function getPingLimit()
	local h = getRealTime().hour
	return (hour1 <= h and h <= hour2) and pingLimit2 or pingLimit1
end
addCommandHandler( "ping", function(plyr) outputChatBox("Max Ping: ".. getPingLimit() ..". Your ping: ".. getPlayerPing(plyr)..".",plyr) end )


-- Set limit to element data
addEventHandler("onResourceStart",resourceRoot,
	function()
		setElementData(root,"anti_pinglimit",getPingLimit())
		setTimer(function() setElementData(root,"anti_pinglimit",getPingLimit()) end,60000,0)
	end)
addEventHandler("onResourceStop",resourceRoot,
	function()
		setElementData(root,"anti_pinglimit",nil)
	end)


function checkPing()
	local pingLimit = getPingLimit()
	for theKey,thePlayer in ipairs(getElementsByType ( "player" )) do
		if raceState ~= "Running" then return end
		local ip = split(getPlayerIP(thePlayer), '.')

		if not hasObjectPermissionTo ( thePlayer, "general.adminpanel" ) and (getPlayerPing(thePlayer) > pingLimit) and getElementData(thePlayer, 'state') == "alive" and not isGhostModeEnabled(thePlayer) then
			-- If the player's ping is too high and he's not an admin, show him the text and set a timer for the next check
			-- textDisplayAddObserver ( warn, thePlayer )
			setTimer(firstCheck, pingCheckTime, 1, thePlayer)
		end	
	end
end

function firstCheck ( thePlayer )
	local pingLimit = getPingLimit()
	if not isElement ( thePlayer ) then return end
	if (getPlayerPing(thePlayer) > pingLimit and getElementData(thePlayer, 'state') == "alive") then
		-- If the player's ping is still to high, send him an event
		triggerClientEvent(thePlayer, 'downloadCheck', root, pingLimit, pingCheckTime)
	else
		-- textDisplayRemoveObserver(warn, thePlayer)
	end
end

----------------------------
-- Last check and kicking --
----------------------------

function doubleCheck ( needKill )
	local pingLimit = getPingLimit()
	local thePlayer = client
	if punishedForMap[thePlayer] then return end
	if (needKill) and (getPlayerPing(thePlayer) > pingLimit) and getElementData(thePlayer, 'state') == "alive" then
		local action = "killed"
		if exports.race:getRaceMode() == "Shooter" or exports.race:getRaceMode() == "Destruction derby" or exports.race:getRaceMode() == "Deadline" then
			setElementHealth(thePlayer, 0)
		else
			-- triggerClientEvent(thePlayer, 'spectate', resourceRoot)
			action = "put in collisionless state"
			setPlayerCollisionless(thePlayer)
		end
		outputChatBox('You were '..action..' for high ping (Max ' .. pingLimit .. ')', thePlayer, 255, 165, 0)
		outputConsole(getPlayerName(thePlayer) .. ' was '..action..' for high ping (Max ' .. pingLimit .. ')')
		punishedForMap[thePlayer] = true
	else
		-- textDisplayRemoveObserver(warn, thePlayer)
	end
end
addEvent("clientCheck", true)
addEventHandler("clientCheck", getRootElement(), doubleCheck )

-------------------------------------------------------
----------- Packet Loss detection 
-------------------------------------------------------

function doubleCheckForPacket( needKill )
	local thePlayer = client
	if punishedForMap[thePlayer] then return end
	if (needKill) and getElementData(thePlayer, 'state') == "alive" then
		local action = "killed"
		if exports.race:getRaceMode() == "Shooter" or exports.race:getRaceMode() == "Destruction derby" or exports.race:getRaceMode() == "Deadline" then
			setElementHealth(thePlayer, 0)
		else
			-- triggerClientEvent(thePlayer, 'spectate', resourceRoot)
			action = "put in collisionless state"
			setPlayerCollisionless(thePlayer)
		end
		outputChatBox('You were '..action..' for high packet loss.', thePlayer, 255, 165, 0)
		outputConsole(getPlayerName(thePlayer) .. ' was '..action..' for high packet loss.')
		punishedForMap[thePlayer] = true
	else
		-- textDisplayRemoveObserver(warn, thePlayer)
	end
end
addEvent("onLaggerRequestKill", true)
addEventHandler("onLaggerRequestKill", root, doubleCheckForPacket)

function getPlayerFromPartialName(name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end

function getPackets(thePlayer, commandName, playerName)
	local r, g, b
	local nick = getPlayerFromPartialName(tostring(playerName))
	local lossTotal = getNetworkStats(nick)["packetlossTotal"]
	local lossLastSecond = getNetworkStats(nick)["packetlossLastSecond"]
	if (playerName) then
		if (string.len(playerName) >= 3) then
			if (isElement(nick)) then
				if (getElementType( nick ) == "player") then
					if (lossTotal > 0) or (lossLastSecond > 0) then
						r, g, b = 255, 0, 0
					else
						r, g, b = 0, 255, 0
					end
					outputChatBox(playerName.."'s packetlossTotal: %"..lossTotal, thePlayer, 0, 255, 0)
					outputChatBox(playerName.."'s packetlossLastSecond: %"..lossLastSecond, thePlayer, 0, 255, 0)
				end
			else
				r, g, b = 255, 0, 0
				outputChatBox("no player found with this name.", thePlayer, r, g, b)
			end
		else
			r, g, b = 255, 0, 0
			outputChatBox("please write a longer partial name.", thePlayer, r, g, b)
		end
	else
		r, g, b = 255, 0, 0
		outputChatBox("please write a player name.", thePlayer, r, g, b)
	end
end
addCommandHandler("getpackets", getPackets)
