addEvent("onRaceStateChanging")
addEventHandler ( "onRaceStateChanging", root, 
	function(newState, old)
		if newState == "PreGridCountdown" then
			triggerClientEvent("serverSendGM", getRootElement(), exports.race:getRaceMode() )
		elseif newState == "NoMap" then
			triggerClientEvent("serverSendGM", getRootElement(), false )
		end

	end
)

addEvent('onPlayerReachCheckpoint')
addEventHandler('onPlayerReachCheckpoint', root,
	function(checkpointNum, timePassed)
		triggerClientEvent('onClientPlayerReachCheckpoint', source, checkpointNum, timePassed)
	end
)
