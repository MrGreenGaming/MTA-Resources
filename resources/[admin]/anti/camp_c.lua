-- Global variable to check if a DD map is running --

local minDistance = 5
local interval = 1000
local maxCounter = 15
local warning = 8

local running = nil
local previousPosition = nil
local counter = 0

function mapRunning(isRunning)
	if isRunning then
		running = setTimer(campTimer, interval, 0)
		-- outputDebugString('dd running')
	else
		reset()
	end
end
addEvent('DDMapRunning', true)
addEventHandler('DDMapRunning', resourceRoot, mapRunning)

function newMapStarted()
	-- outputDebugString('map stopped running')
	reset()
end
addEventHandler('onClientMapStarting', root, newMapStarted)


function campTimer()
	if getElementHealth(localPlayer) < 1 or getElementData(localPlayer, 'state') ~= "alive" then
		return reset()
	end
	local currentPos = {getElementPosition(localPlayer)}
	if previousPosition and getDistanceBetweenPoints3D(currentPos[1], currentPos[2], currentPos[3], previousPosition[1], previousPosition[2], previousPosition[3]) < minDistance then
		counter = counter + 1
		if counter == warning then
			outputChatBox("Warning: you will be killed if you don't move!", 255, 0, 0)
		elseif counter >= maxCounter then
			-- outputChatBox("Killed for not moving", 255, 0, 0)
			-- triggerServerEvent("campKilled", resourceRoot, localPlayer)
			setElementHealth(localPlayer, 0)
			reset()
		end
	else
		-- outputDebugString('Thanks for moving!')
		counter = 0
		previousPosition = currentPos
	end
end

function reset()
	-- outputDebugString('reset')
	if isTimer(running) then killTimer(running) end
	running = nil
	previousPosition = nil
	counter = 0
end

addEventHandler("onClientVehicleCollision", root,
    function ( hit ) 
        if ( source == getPedOccupiedVehicle(localPlayer) ) then
            if ( hit ~= nil ) then 
				previousPosition = nil
				counter = 0
			end 
        end
    end
)