local AfkTable = {
	-- [player] = boolean -- Example Tree
}
local MapState = false


afkwarn = textCreateDisplay ()
local warnText1 = textCreateTextItem ( "You are being idle", 0.5, 0.30, "high", 230, 0, 0, 255, 4.0, "center", "center" )
local warnText3 = textCreateTextItem ( "You are being idle", 0.503, 0.303, "high", 230, 0, 0, 0, 4.0, "center", "center" )
local warnText2 = textCreateTextItem ( "Press a key to avoid being set to AFK state", 0.5, 0.37, "high", 217, 0, 0, 255, 2.5, "center", "center" )
local warnText4 = textCreateTextItem ( "Press a key to avoid being set to AFK state", 0.503, 0.373, "high", 217, 0, 0, 0, 2.5, "center", "center" )
textDisplayAddText ( afkwarn, warnText4 )
textDisplayAddText ( afkwarn, warnText3 )
textDisplayAddText ( afkwarn, warnText2 )
textDisplayAddText ( afkwarn, warnText1 )

afknotify = textCreateDisplay()
local notifyText1 = textCreateTextItem ( "You are AFK", 0.5, 0.30, "high", 230, 0, 0, 255, 4.0, "center", "center" )
local notifyText3 = textCreateTextItem ( "You are AFK", 0.503, 0.303, "high", 230, 0, 0, 0, 4.0, "center", "center" )
local notifyText2 = textCreateTextItem ( "Press 'b' to play again.", 0.5, 0.37, "high", 217, 0, 0, 255, 2.5, "center", "center" )
local notifyText4 = textCreateTextItem ( "Press 'b' to play again.", 0.503, 0.373, "high", 217, 0, 0, 0, 2.5, "center", "center" )
textDisplayAddText ( afknotify, notifyText4 )
textDisplayAddText ( afknotify, notifyText3 )
textDisplayAddText ( afknotify, notifyText2 )
textDisplayAddText ( afknotify, notifyText1 )

-- Calls and predefined viariables
-- local race = exports.race
local currentGamemode = getResourceState(getResourceFromName'race') == 'running' and exports.race:getRaceMode()

local sb = exports.scoreboard



function warnPlayer(player)
	if not textDisplayIsObserver( modsWarning, player ) then
		textDisplayAddObserver(afkwarn, player)
	end
end

function notifyPlayer(player)
	if not textDisplayIsObserver( modsWarning, player ) then
		textDisplayAddObserver(afknotify, player)
	end
end

function removeWarn(player)
	textDisplayRemoveObserver(afkwarn, player)
end

function removeNotify(player)
	textDisplayRemoveObserver(afknotify, player)
end

addEvent("warnPlayerIdle", true)
addEventHandler("warnPlayerIdle", root,
function(todo, idles, maxidles)
	local player = source
	if todo == "warnPlayer" then
		-- if not hasObjectPermissionTo ( player, "function.kickPlayer", false ) then
			warnPlayer(player)
		-- end
	elseif todo == "setAfkState" then
		-- if not hasObjectPermissionTo ( player, "function.kickPlayer", false ) then
		removeWarn(player)	
		setPlayerAFK(player,true)
		notifyPlayer(player)
		-- else
		-- 	removeWarn(player)
		-- 	removeNotify(player)
		-- 	AfkTable[player] = false
		-- end

	elseif todo == "removeWarn" then
		removeWarn(player)
		removeNotify(player)
		setPlayerAFK(player,false)
	end	
end
)

addEvent('onPostFinish', true)
addEventHandler('onPostFinish', root,
function()
	triggerClientEvent("onMapRunning", root, false)
end
)

addEvent('onRaceStateChanging', true)
addEventHandler('onRaceStateChanging', root,
function(state)
	MapState = state
	currentGamemode = exports.race:getRaceMode()
	if state == "Running" then
		triggerClientEvent("onMapRunning", root, true)
	else
		triggerClientEvent("onMapRunning", root, false)
	end	

	if state == "Running" then
		executeAfkState(exports.race:getRaceMode())

		if exports.race:getRaceMode() == "Capture the flag" or exports.race:getRaceMode() == "Destruction derby" or exports.race:getRaceMode() == "Shooter" or exports.race:getRaceMode() == "Deadline" then -- timemode short
			triggerClientEvent("setAFKTimeforGamemode",resourceRoot,true)
		end
	end

end
)



-- Join and Quit Handlers --
addEventHandler("onResourceStart", resourceRoot, 
function()
	local pTable = getElementsByType("player")
	for f,u in pairs(pTable) do
		if AfkTable[u] == nil then
			AfkTable[u] = false
		end
	end
end)

addEventHandler("onPlayerJoin", root, 
function()
	if AfkTable[source] == nil then
		AfkTable[source] = false
	end
end)

addEventHandler("onPlayerQuit", root, 
function()
	if AfkTable[source] ~= nil then
		AfkTable[source] = nil
	end
end)


-- Game mode specific afk handler --
-- triggerPlayerSpectate --Spec EVENT
function executeAfkState(gamemode)
	if gamemode == "Destruction derby" or gamemode == "Shooter" or gamemode == "Deadline" or gamemode == "Deadline" and not exports.race:getShooterMode() == "cargame" then
		for f,u in pairs(AfkTable) do
			if u then
				
				setElementData(f,"player state","away")
				
				if isElement(getPedOccupiedVehicle(f)) and not isPedDead(f) then
					-- outputDebugString("AFK Kill"..getPlayerName(f)..tostring(gamemode))
					outputChatBox("You were killed, reason: AFK.",f,255,0,0)
					setElementHealth(f, 0)
				end
			end
		end
	else -- Other gamemodes are handled the same
		for f,u in pairs(AfkTable) do
			if u then
				-- outputDebugString("AFK Spectate"..getPlayerName(f)..tostring(gamemode))
				setElementData(f,"player state","away")
				triggerClientEvent(f,"triggerPlayerSpectate",resourceRoot,true)
			end
		end
	end
end


function setPlayerAFK(p,bln)
	if not p then return end
	if bln ~= nil then
		if bln == true then
			AfkTable[p] = true
			notifyPlayer(p)
			if currentGamemode == "Destruction derby" or currentGamemode == "Shooter" or currentGamemode == "Deadline" then
				
				setElementData(p,"player state","away")
				

				if isElement(getPedOccupiedVehicle(p)) and MapState == "Running" and not isPedDead(p) then
					killPed( p )
					setElementHealth(p, 0)
					-- outputDebugString("AFK Kill"..getPlayerName(p).." ::Individual DD SH")
					outputChatBox("You were killed, reason: AFK.",p,255,0,0)

					if hasObjectPermissionTo ( p, "function.banPlayer", false ) then -- If its an admin then kill again
						triggerClientEvent(p,"triggerPlayerSpectate",resourceRoot,false)
						setTimer(function() if isElement(p) then setElementHealth(p, 0) end end,100,3)
					end
				end

				
			else
				-- outputDebugString("AFK Spectate"..getPlayerName(p).." ::Individual Else GM")
				triggerClientEvent(p,"triggerPlayerSpectate",resourceRoot,true)
				setElementData(p,"player state","away")
				
			end
		elseif bln == false then
			AfkTable[p] = false
			removeNotify(p)
			local theRealData = getElementData( p, "state" )
			setElementData( p, "player state", theRealData )
			-- if currentGamemode == "Destruction derby" or currentGamemode == "Shooter" then
				
			-- else
			-- 	triggerClientEvent(p,"triggerPlayerSpectate",resourceRoot,false)
			-- end
		end
	end
end


addCommandHandler( "afk", 
function(playerSource)
	if AfkTable[playerSource] == false then
		setPlayerAFK(playerSource,true)
		triggerClientEvent(playerSource,"usedAFKcommand",resourceRoot)
	end
end)

-- Export function --
function isPlayerAFK(player)
	if AfkTable[player] ~= nil then
		if AfkTable[player] == true then
			return true
		else
			return false
		end
	else 
		return false
	end
end


-- Scoreboard bidnizz --

addEventHandler("onElementDataChange", root,
function(name,old)
	if name == "state" then
		if AfkTable[source] == false then
			local theData = getElementData(source,name)
			setElementData( source, "player state", theData )
		end
	end
end
)


addEventHandler("onResourceStart",resourceRoot,
function()

	for f,p in pairs(getElementsByType( "player")) do
		local theRealData = getElementData( p, "state" )
		setElementData( p, "player state", theRealData )
	end
	
end
)

