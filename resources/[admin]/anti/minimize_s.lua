addEvent('onRaceStateChanging', true)
addEventHandler('onRaceStateChanging', getRootElement(),
    function(state)
		local mode = getResourceRootElement(getResourceFromName'race') and getElementData(getResourceRootElement(getResourceFromName'race'), 'info') and getElementData(getResourceRootElement(getResourceFromName'race'), 'info').mapInfo.modename
        if  mode == "Destruction derby" then

                triggerClientEvent('informClientAntiMinimize', resourceRoot, state == "Running")
				
        end    
	end
)