addEvent('onClientTogglePoliceSiren', true)
addEventHandler('onClientTogglePoliceSiren', root, 
function(state)
	triggerClientEvent(root, 'vip_startSirenForPlayer', source, source, state)
	saveVipSetting(source, 6, "enabled", state)
end)

addEventHandler('onPlayerVip', resourceRoot,
function(player, loggedIn)
	if player and isElement(player) and getElementType(player) == "player" then
		if loggedIn and getVipSetting(player,6,'enabled') then
			triggerClientEvent(root, 'vip_startSirenForPlayer', player, player, true)		
		end
	end
end
)