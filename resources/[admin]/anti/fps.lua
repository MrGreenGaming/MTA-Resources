------------------------------------------
-- Fps checker, invertal check system, 	--
-- with strikes. Limit = kickPlayer		--
-------------------------------------------

local fpsMinimum = 30
local checkInterval = 3 * 1000
local maxStrikes = 5
local fpsStrikes = {}

-- Set limit to element data
addEventHandler("onResourceStart",resourceRoot,
	function()
		setElementData(root,"anti_fpsMinimum",fpsMinimum)
	end)
addEventHandler("onResourceStop",resourceRoot,
	function()
		setElementData(root,"anti_fpsMinimum",nil)
	end)

-------------------
-- Checking ping --
-------------------

addEvent("onGamemodeMapStart")
addEventHandler("onGamemodeMapStart",root,function() fpsStrikes = {} end)

addEventHandler ( "onResourceStart", resourceRoot,
	function()
		setTimer(checkFPS, checkInterval, 0)	
	end
)

function checkFPS()
	-- if not (getResourceRootElement(getResourceFromName'race') and getElementData(getResourceRootElement(getResourceFromName'race'), 'info') and getElementData(getResourceRootElement(getResourceFromName'race'), 'info').mapInfo.modename == "Destruction derby") then
	-- 	return
	-- end
	for theKey,thePlayer in ipairs(getElementsByType ( "player" )) do
		local fps = getElementData(thePlayer, "fps")
		if not tonumber(fps) then return end
		if raceState ~= "Running" then return end
		if not punishedForMap[thePlayer] and (fps < fpsMinimum) and not getElementData(thePlayer, "isGameMinimized") and getElementData(thePlayer, 'state') == "alive" and not isGhostModeEnabled(thePlayer) then
			-- If the player's fps is low, add a strike
			fpsStrikes[thePlayer] = fpsStrikes[thePlayer] and (fpsStrikes[thePlayer] + 1) or 1
			-- textDisplayAddObserver ( warnFPS, thePlayer )
			if fpsStrikes[thePlayer] > maxStrikes then
				if not hasObjectPermissionTo ( thePlayer, "general.adminpanel" ) then
					local action = "killed"
					if exports.race:getRaceMode() == "Shooter" or exports.race:getRaceMode() == "Destruction derby" then
						setElementHealth(thePlayer, 0)
					else
						-- triggerClientEvent(thePlayer, 'spectate', resourceRoot)
						action = "put in collisionless state"
						setPlayerCollisionless(thePlayer)
					end
					outputChatBox('You were '..action..' for low fps (min ' .. fpsMinimum .. ')', thePlayer, 255, 165, 0)
					fpsStrikes[thePlayer] = nil
					punishedForMap[thePlayer] = true
					-- textDisplayRemoveObserver(warnFPS, thePlayer)
				end
			end
		elseif fpsStrikes[thePlayer] then
			fpsStrikes[thePlayer] = nil
			-- textDisplayRemoveObserver(warnFPS, thePlayer)
		end
	end
end

addEventHandler('onPlayerQuit', root, function()
	fpsStrikes[source] = nil
end)



function isGhostModeEnabled(player)
	if getElementData( player, "overrideCollide.uniqueblah" ) and getElementData( player, "overrideAlpha.uniqueblah" ) then
		return true
	end
	return false
end
