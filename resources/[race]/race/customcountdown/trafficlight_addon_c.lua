-- Traffic Light Addon by Nick_026
-- See for state references: https://wiki.multitheftauto.com/wiki/Traffic_light_states 


function MapLoaded()
	setTrafficLightState(9)
end
addEventHandler("OnMapStarting", root, MapLoaded)

function ReceiveCountdownTimer(whatToDo)
	if whatToDo == 3 then
		setTrafficLightState(2)
	elseif whatToDo == 1 then
		setTrafficLightState(6)
	elseif whatToDo == "go" then
		setTrafficLightState(5)
		setTimer(function()
			setTrafficLightState(9)
			setTimer(function()
				setTrafficLightState("auto")
			end, 1000, 1)
		end, 3000, 1)
	end

end
addEventHandler("receiveServerCountdown",resourceRoot,ReceiveCountdownTimer)