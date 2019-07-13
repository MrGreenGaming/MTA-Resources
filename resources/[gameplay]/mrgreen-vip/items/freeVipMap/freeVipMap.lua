
function playerUsedFreeVipMap(player)
	if not player or not isPlayerVIP(player) then return end
	vip_outputChatBox("You have used your daily free map. You get another free map at 00:00 CET",player,0,255,0)
	saveVipSetting(player, 10, 'used', getRealTime().timestamp)
	if getResourceState( getResourceFromName( 'gcshop' ) ) == "running" then
		triggerClientEvent( player, 'onVipFreeMapInfo', player, false )
	end
end


function canBuyVipMap (player)
	if not player or not isPlayerVIP(player) then return false end

	local stamp = getVipSetting(player, 10, 'used')
	-- If never used, its set to false
	if stamp == false then return true end
	if stamp == nil then return false end
	local stampTime = getRealTime( stamp )
	if not stampTime then return false end

	-- Compare stamptime to current
	local currentTime = getRealTime()
	if stampTime.month ~= currentTime.month or stampTime.monthday ~= currentTime.monthday then
		-- Can use
		return true
	end
	return false
end

function refreshClientVipMap()
	if getResourceState( getResourceFromName( 'gcshop' ) ) == "running" then
		for p,val in pairs(vipPlayers) do
			if not p or not isElement(p) or getElementType(p) ~= "player" then break end
			triggerClientEvent( p, 'onVipFreeMapInfo', p, canBuyVipMap(p) )
		end
	end
end
local refreshVipMapTime = 5 -- in minutes
setTimer( refreshClientVipMap, refreshVipMapTime * 60000, 0 )

-- Handle vip join
addEventHandler('onPlayerVip', resourceRoot,
	function(player, loggedIn)
		if player and isElement(player) and getElementType(player) == "player" then
			if loggedIn then
				
				if getResourceState( getResourceFromName( 'gcshop' ) ) == "running" then
					triggerClientEvent( player, 'onVipFreeMapInfo', player, canBuyVipMap(player) )
				end
			else
				if getResourceState( getResourceFromName( 'gcshop' ) ) == "running" then
					triggerClientEvent( player, 'onVipFreeMapLogOut', player )
				end
			end	
		end
	end
)

addEvent("onClientRequestsVipMap", true)
addEventHandler( "onClientRequestsVipMap", root, function() 
	if getElementType(client) == "player" and isPlayerVIP(client) then
		triggerClientEvent( client, 'onVipFreeMapInfo', client, canBuyVipMap(client) )
	end
end)

addEventHandler('onResourceStop', resourceRoot,
function()
	for i, p in ipairs(getElementsByType('player')) do
		if getResourceState( getResourceFromName( 'gcshop' ) ) == "running" then
			triggerClientEvent( p, 'onVipFreeMapLogOut', p )
		end
	end
end)