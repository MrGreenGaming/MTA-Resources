local minimizeTime = 60000 -- Time before minimizing kills in ms

local minimizeRunningTick = false

addEvent('informClientAntiMinimize',true)
addEventHandler('informClientAntiMinimize',root,function(isRunning, tick) 
    if isRunning then
        minimizeRunningTick = getTickCount()
    else
        minimizeRunningTick = false
    end
end)


function handleMinimizePunish()
    if not minimizeRunningTick then return end

    if (tonumber(minimizeRunningTick) + minimizeTime ) < getTickCount() then
        setElementHealth( localPlayer, 0 )
        outputChatBox('You have been killed for minimizing your game!',255,0,0)
    end
end
addEventHandler( "onClientMinimize", root, handleMinimizePunish )