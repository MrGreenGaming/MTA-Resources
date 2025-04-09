-- Traffic Light Addon by Nick_026
-- See for state references: https://wiki.multitheftauto.com/wiki/Traffic_light_states

-- Before countdown: Flashing Red
-- During 3 & 2: Red
-- During 1: Yellow
-- Go: Green for 5 seconds => Disabled for 3 seconds => Back to vanilla

local GoToOffTimer
local OffToVanillaTimer
local FlashRedTimer

function MapLoaded()
	if isTimer(GoToOffTimer) then killTimer(GoToOffTimer) end
	if isTimer(OffToVanillaTimer) then killTimer(OffToVanillaTimer) end
	if isTimer(FlashRedTimer) then killTimer(FlashRedTimer) end

	setTrafficLightsLocked(true)
	FlashRedTimer = setTimer(FlashRedLights, 500, 0)
end
addEvent("onCountdownWait", true)
addEventHandler("onCountdownWait", root, MapLoaded)

function ReceiveCountdownTimer(whatToDo)
	if whatToDo == 3 then
		if isTimer(FlashRedTimer) then killTimer(FlashRedTimer) end
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


function FlashRedLights()
    local lightsOff = getTrafficLightState() == 9
    if lightsOff then
        setTrafficLightState(2)
    else
        setTrafficLightState(9)
    end
end