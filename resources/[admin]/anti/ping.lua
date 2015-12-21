----------------------------------------------
-- Ping checker, sends a request to client,	--
-- client checks if downloading, responds,	--
-- server double-checks and kicks if needed	--
-- Also does check for stuck 0-ping players --
----------------------------------------------

local pingLimit1 = 260
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


-- Set limit to element data
addEventHandler("onResourceStart",resourceRoot,
	function()
		setElementData("anti_pinglimit",root,getPingLimit())
		setTimer(function() setElementData("anti_pinglimit",root,getPingLimit()) end,60000,0)
	end)
addEventHandler("onResourceStop",resourceRoot,
	function()
		setElementData("anti_pinglimit",root,nil)
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
		if exports.race:getRaceMode() == "Shooter" or exports.race:getRaceMode() == "Destruction derby" then
			setElementHealth(thePlayer, 0)
		else
			-- triggerClientEvent(thePlayer, 'spectate', resourceRoot)
			action = "put in collisionless state"
			setPlayerCollisionless(thePlayer)
		end
		outputChatBox('You were '..action..' for high ping (Max ' .. pingLimit .. ')', thePlayer, 255, 165, 0)
		outputDebugString(getPlayerName(thePlayer) .. ' was '..action..' for high ping (Max ' .. pingLimit .. ')')
		punishedForMap[thePlayer] = true
	else
		-- textDisplayRemoveObserver(warn, thePlayer)
	end
end
addEvent("clientCheck", true)
addEventHandler("clientCheck", getRootElement(), doubleCheck )



