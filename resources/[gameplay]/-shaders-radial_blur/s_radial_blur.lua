--
-- s_radial_blur.lua
--

local currentFPSLimit = 0

----------------------------------------------------------------
-- onResourceStartedAtClient
--     Used for auto FPS adjustment
----------------------------------------------------------------
addEvent("onResourceStartedAtClient",true)
addEventHandler("onResourceStartedAtClient",resourceRoot,
	function()
		currentFPSLimit = getFPSLimit()
		if currentFPSLimit < 1 then
			currentFPSLimit = 60
		end
		triggerClientEvent( client, "onClientNotifyServerFPSLimit", resourceRoot, currentFPSLimit )
	end
)

setTimer( 
	function()
		local fpsLimit = getFPSLimit()
		if fpsLimit < 1 then
			fpsLimit = 60
		end
		if fpsLimit ~= currentFPSLimit then
			currentFPSLimit = fpsLimit
			triggerClientEvent( root, "onClientNotifyServerFPSLimit", resourceRoot, currentFPSLimit )
		end
	end
,5000 ,0)
