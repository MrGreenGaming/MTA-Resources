addEventHandler('onClientResourceStart', resourceRoot,
function()
		triggerServerEvent('nickProtectionLoaded', getLocalPlayer())
end
)
