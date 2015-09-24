function handleRestore()
    setElementData(localPlayer, "isGameMinimized", false)
end


function handleMinimize()
    setElementData(localPlayer, "isGameMinimized", true)
end

addEventHandler('onClientResourceStart', resourceRoot, 
function()
	setElementData(localPlayer, "isGameMinimized", false)
	addEventHandler("onClientRestore",root,handleRestore)
	addEventHandler("onClientMinimize",root,handleMinimize)
end
)