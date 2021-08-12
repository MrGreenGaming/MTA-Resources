-- Traffic Light Addon by Nick_026
-- See for state references: https://wiki.multitheftauto.com/wiki/Traffic_light_states 

local GoToOffTimer = nil
local OffToVanillaTimer = nil

function MapLoaded()
	if isTimer(GoToOffTimer) then killTimer(goToOffTimer) end
	if isTimer(OffToVanillaTimer) then killTimer(OffToVanillaTimer) end

	outputDebugString("Map Loaded - Lights off")
	setTrafficLightsLocked(true)
	setTrafficLightState("disabled")
end
addEvent("triggerCountdownWait")
addEventHandler("triggerCountdownWait", root, MapLoaded)

function ReceiveCountdownTimer(whatToDo)
	if whatToDo == 3 then
		setTrafficLightState(2)
	elseif whatToDo == 1 then
		setTrafficLightState(6)
	elseif whatToDo == "go" then
		outputDebugString("Map Started - lights green")
		setTrafficLightState(5)
		GoToOffTimer = setTimer(function()
			outputDebugString("Temp. disabled lights")
			setTrafficLightState("disabled")
			OffToVanillaTimer = setTimer(function()
				outputDebugString("Back to vanilla")
				setTrafficLightState("auto")
				setTrafficLightsLocked(false)
			end, 3000, 1)
		end, 5000, 1)
	end

end
addEventHandler("receiveServerCountdown",resourceRoot,ReceiveCountdownTimer)