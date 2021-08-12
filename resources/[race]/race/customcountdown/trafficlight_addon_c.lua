-- Traffic Light Addon by Nick_026
-- See for state references: https://wiki.multitheftauto.com/wiki/Traffic_light_states 


function MapLoaded()
	outputDebugString("Map Loaded - Lights off")
	setTrafficLightState("disabled")
end
addEventHandler("OnMapStarting", root, MapLoaded)

function ReceiveCountdownTimer(whatToDo)
	if whatToDo == 3 then
		setTrafficLightState(2)
	elseif whatToDo == 1 then
		setTrafficLightState(6)
	elseif whatToDo == "go" then
		outputDebugString("Map Started - lights green")
		setTrafficLightState(5)
		setTimer(function()
			outputDebugString("Temp. disabled lights")
			setTrafficLightState("disabled")
			setTimer(function()
				outputDebugString("Back to vanilla")
				setTrafficLightState("auto")
			end, 3000, 1)
		end, 3000, 1)
	end

end
addEventHandler("receiveServerCountdown",resourceRoot,ReceiveCountdownTimer)