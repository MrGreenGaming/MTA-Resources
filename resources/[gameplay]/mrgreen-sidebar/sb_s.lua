addEvent("getServerName",true)
addEventHandler("getServerName",resourceRoot,
	function()
		local name = getServerName()
		triggerClientEvent(client,"receiveServerName",resourceRoot,name)
	end)