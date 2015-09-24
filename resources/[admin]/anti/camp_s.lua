addEvent('onRaceStateChanging', true)
addEventHandler('onRaceStateChanging', getRootElement(),
	function(state)
		local mode = getResourceRootElement(getResourceFromName'race') and getElementData(getResourceRootElement(getResourceFromName'race'), 'info') and getElementData(getResourceRootElement(getResourceFromName'race'), 'info').mapInfo.modename
        if  mode == "Destruction derby" or mode == "Shooter" then
                triggerClientEvent('DDMapRunning', resourceRoot, state == "Running")
				
        end    
	end
)

function campKilled(player)
	outputChatBox(string.gsub (getPlayerName(player), '#%x%x%x%x%x%x', '' ) .. " was killed for not moving", root, 255, 0, 0)
end
addEvent('campKilled', true)
addEventHandler('campKilled', resourceRoot, campKilled)
