function outputGameMessage(text, triggerFor, size, r, g, b)
	if (r == nil) and (g == nil) and (b == nil) then
		r = 255
		g = 255
		b = 255
	end	
	triggerClientEvent(triggerFor, "onGameMessageSend", triggerFor, text,size,r, g, b)
end

addEventHandler('onMapStarting', getRootElement(),
function()	
	checkTimer = setTimer(function() timePassed = whichTimePassed()
		if timePassed then
		if timePassed > 25000 then 
			triggerClientEvent("getTimePassed", getRootElement(), "true")
			if isTimer(checkTimer) then killTimer(checkTimer) end
		end
		end
			end, 2000, 0)
end
)

function whichTimePassed()
	if getResourceFromName('race') and getResourceState(getResourceFromName('race')) == 'running' then
		return exports.race:getTimePassed() or 0
	end	
end


addEventHandler('onPlayerJoin', getRootElement(),
function()
	timePassed = whichTimePassed()
	if timePassed > 25000 then
		triggerClientEvent(source, "getTimePassed", source, "true")
	end	
end
)

addCommandHandler('achat', 
function(player, cmd, ...)
	if hasObjectPermissionTo(player, "function.banPlayer", false) then
		triggerClientEvent(getRootElement(), "onGameMessageSend", getRootElement(), table.concat({...}, " "),3, 255, 255, 255)
	end
end
)
