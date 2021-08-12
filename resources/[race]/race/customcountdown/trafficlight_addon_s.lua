function onMapChange()
	triggerClientEvent( root,"onCountdownWait", root)
end
addEventHandler("onMapStarting", getRootElement(), onMapChange)