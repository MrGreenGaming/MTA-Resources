function countdown()
	local time = getRealTime().timestamp
	local eventTimeStamp = 1442422800

	local realCountDownTimeMS = (eventTimeStamp - time)
	triggerClientEvent(client,"serverSendCD",client,tonumber(realCountDownTimeMS))

end
addEvent("onAskCD",true)
addEventHandler("onAskCD",root,countdown)

-- --[[function checkVehicleIDChange(old,new)
-- 	if getElementType(source) == "vehicle" then
-- 		local occupant = getVehicleOccupant(source)
-- 		if occupant and isElement(occupant) and getElementType(occupant) == "player" then
-- 			outputDebugString(getPlayerName(occupant).." triggered "..eventName)
-- 		end
-- 	end
-- end
-- addEventHandler("onElementModelChange",root,checkVehicleIDChange)
-- addEventHandler("onVehicleEnter",root,checkVehicleIDChange)

-- function gmChecker(name)
-- 	if getElementType(source) == "player" and string.find(name,"overrideCollide") then -- If it's an gm override
-- 		-- triggerClientEvent("onPlayerVehicleIDChange",root,source)
-- 		outputDebugString(getPlayerName(source).." triggered "..eventName)
-- 	end
-- end
-- addEventHandler("onElementDataChange",root,gmChecker)

-- addEvent("onPlayerSpectateCollisionReset")
-- function unSpectateCollision()
-- 	if getElementType(source) == "player" then
-- 		outputDebugString(getPlayerName(source).." triggered "..eventName)
-- 	end
-- end
-- addEventHandler("onPlayerSpectateCollisionReset",root,unSpectateCollision)--]]

-- addCommandHandler('fancy', function(p)
-- 	triggerClientEvent('fancy', p)
-- end)

-- function update (server,channel,user,command,resname)
-- 	exports.ircoutputIRC(resname)	
-- end
-- exports.irc:addIRCCommandHandler('update', 'update', 3, true)