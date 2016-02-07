addEvent('onHeliChange', true)
addEventHandler('onHeliChange', root,
function(vehicle)
	setTimer(
	function(veh)
		if isElement(veh) then
			setHelicopterRotorSpeed(veh, 0.2)
		end
	end
	, 500+getPlayerPing(localPlayer), 1, vehicle)
end
)