
addEventHandler("onClientResourceStart", resourceRoot, function()
    setTimer(setNight, 30000, 0)
end)

addEventHandler('onClientMapStarting', getRootElement(),
function()
	setTimer(setNight, 3000, 1)
end
)

function setNight()
    if getResourceFromName("gus") and getResourceState(getResourceFromName("gus")) == "running" then
        local isDayNightModeEnabled = exports.gus:getDayNightMode()

        if not isDayNightModeEnabled then
            setTime(1, 0)
        end
    else
        setTime(1, 0)
    end
end
