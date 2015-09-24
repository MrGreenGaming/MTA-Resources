function downloadCheck (pingLimit, pingCheckTime)
	if not isTransferBoxActive() and getPlayerPing(localPlayer) > pingLimit then
		setTimer(function(pingLimit)
			if getPlayerPing(localPlayer) > pingLimit then
				triggerServerEvent('clientCheck', root, true)
			else
				triggerServerEvent('clientCheck', root, false)
			end
		end, pingCheckTime, 1, pingLimit)
	else
		triggerServerEvent('clientCheck', root, false)
	end
end
addEvent('downloadCheck', true)
addEventHandler( 'downloadCheck', root, downloadCheck )

function spectate ()
	executeCommandHandler('spectate')
end
addEvent('spectate', true)
addEventHandler( 'spectate', resourceRoot, spectate )