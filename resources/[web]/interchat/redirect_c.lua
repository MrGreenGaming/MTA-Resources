local pressedOnce = false
function RequestRedirect()
	if pressedOnce then
		triggerServerEvent('onRequestRedirect', localPlayer)
	else
		local wnd = guiCreateWindow(0.3405,0.3657,0.319,0.05,"Confirm Dialog",true)
		local label = guiCreateLabel(0.0168,0.502,0.9757,0.6629,"Press F2 again if you want to go to the other server! This dialog box will disappear in 5 seconds",true,wnd)
		setTimer(function(x)
			destroyElement(x)
			pressedOnce = false
		end, 5000, 1, wnd)
		pressedOnce = true
	end
end
bindKey('f2', 'down',RequestRedirect)
addCommandHandler('requestredirect', RequestRedirect)

