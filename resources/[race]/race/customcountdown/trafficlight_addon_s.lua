function onMapChange()
	triggerClientEvent( root,"triggerCountdownWait", root)
end
addEventHandler("onMapStarting", getRootElement(), onMapChange)