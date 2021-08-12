-- Traffic Light Addon by Nick_026
-- See for state references: https://wiki.multitheftauto.com/wiki/Traffic_light_states

-- Before countdown: Disabled
-- During 3 & 2: Red
-- During 1: Yellow
-- During Go: Green for 5 seconds => Disabled for 3 seconds => Back to vanilla

local GoToOffTimer
local OffToVanillaTimer

function MapLoaded()
	if isTimer(GoToOffTimer) then killTimer(GoToOffTimer) end
	if isTimer(OffToVanillaTimer) then killTimer(OffToVanillaTimer) end

	setTrafficLightsLocked(true)
	setTrafficLightState("disabled")
end
addEvent("onCountdownWait", true)
addEventHandler("onCountdownWait", root, MapLoaded)

function ReceiveCountdownTimer(whatToDo)
	if whatToDo == 3 then
		setTrafficLightState(2)
	elseif whatToDo == 1 then
		setTrafficLightState(6)
	elseif whatToDo == "go" then

		setTrafficLightState(5)

		GoToOffTimer = setTimer(function()
			setTrafficLightState("disabled")

			OffToVanillaTimer = setTimer(function()
				setTrafficLightState("auto")
				setTrafficLightsLocked(false)
			end, 3000, 1)

		end, 5000, 1)
	end

end
addEventHandler("receiveServerCountdown",resourceRoot,ReceiveCountdownTimer)