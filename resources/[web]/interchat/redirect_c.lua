function RequestRedirect()
	triggerServerEvent('onRequestRedirect', localPlayer)
end
addCommandHandler('switch', RequestRedirect)