-- dvo.id
-- dvo.color

-- vip.dvo.id
-- vip.dvo.color

function setDynamicOverlay(player, reason)
	if not player or not isElement(player) or getElementType( player ) ~= "player" then return end

	local overlayType = getVipSetting(player, 7, 'style')
	local overlayColor = getVipSetting(player, 7, 'color')

	if overlayType == false then
		-- Remove
		removeElementData( player, 'vip.dvo.id' )
		removeElementData( player, 'vip.dvo.color' )
		triggerClientEvent( root, 'onServerRemovedDvoid', resourceRoot, player, "remove" )

	elseif overlayType and overlayColor then

		setElementData( player, 'vip.dvo.id', overlayType )
		setElementData( player, 'vip.dvo.color', "#"..overlayColor )
		triggerClientEvent( root, 'onServerAddedDvoid', resourceRoot, player, reason or false )
	end 
end



addEvent('onClientRemoveVipOverlay',true)
addEvent('onClientSetVipOverlayType',true)
addEvent('onClientSetVipOverlayColor',true)
addEventHandler('onClientRemoveVipOverlay', root, 
	function() 
		if getElementType(source) ~= "player" or not isPlayerVIP(source) then return false end

		 -- save VIP skin
		 local saved = saveVipSetting(source, 7, 'style', false)
		 if saved then
		 	setDynamicOverlay(source)
		 	vip_outputChatBox("Your dynamic overlay has successfully been removed!",source,0,255,100)
		 else
		 	vip_outputChatBox("There was an error removing your dynamic overlay!",source,255,0,0)
		 end
	end
)


addEventHandler('onClientSetVipOverlayType', root, 
	function(id) 
		if getElementType(source) ~= "player" or not isPlayerVIP(source) or not tonumber(id) then return false end

		local saved = saveVipSetting(source, 7, 'style', tonumber(id))
		 if saved then
		 	setDynamicOverlay(source, "type")
		 	vip_outputChatBox("Your dynamic overlay has successfully been changed!",source,0,255,100)
		 else
		 	vip_outputChatBox("There was an error changing your dynamic overlay!",source,255,0,0)
		 end
	end
)
addEventHandler('onClientSetVipOverlayColor', root, 
	function(col) 
		if getElementType(source) ~= "player" or not isPlayerVIP(source) or not col then return false end

		local saved = saveVipSetting(source, 7, 'color', col)
		 if saved then
		 	setDynamicOverlay(source,"color")
		 	vip_outputChatBox("Your dynamic overlay color has successfully been changed!",source,0,255,100)
		 else
		 	vip_outputChatBox("There was an error changing your dynamic overlay color!",source,255,0,0)
		 end
	end
)



addEventHandler('onPlayerVip', resourceRoot,
	function(player, loggedIn)
		if player and isElement(player) and getElementType(player) == "player" then
			if loggedIn then
				setDynamicOverlay(player)
			else
				-- Handle logout
				setDynamicOverlay(player)
			end
		end
	end
)

addEventHandler('onResourceStop', resourceRoot,
function()
	for i, p in pairs(getElementsByType('player')) do
		removeElementData( p, 'vip.dvo.id' )
		removeElementData( p, 'vip.dvo.color' )
	end
end)

