-- VIP Badges
-- Actual badge rendering is in race resource nametags


function setVipBadge(player,bool)
	if not player or not isElement(player) or getElementType(player) ~= "player" then return end
	if bool == true then
		setElementData(player, "gcshop.vipbadge", "vip")
	else 
		removeElementData( player, 'gcshop.vipbadge' )
	end	
end


-- Handle vip join
addEventHandler('onPlayerVip', resourceRoot,
	function(player, loggedIn)
		if player and isElement(player) and getElementType(player) == "player" then
			if loggedIn and getVipSetting(player,1,"enabled") then
				setVipBadge(player,true)
			else
				setVipBadge(player,false)
			end	
		end
	end
)


-- Handle setting changed
addEvent( 'onClientChangeVipBadge', true )
addEventHandler( 'onClientChangeVipBadge', root, 
	function(bool) 
		if getElementType( source ) ~= "player" then return end

		if not isPlayerVIP(source) then
			vip_outputChatBox("Setting failed. Not VIP!",source,255,0,0)
			return
		end
		if bool == nil then 
			vip_outputChatBox("Setting failed. Please contact a dev!",source,255,0,0)
			return 
		end

		local saved = saveVipSetting(source, 1, "enabled", bool)
		if not saved then 
			vip_outputChatBox("Setting change failed. Please contact a dev.",source,255,0,0)
			return
		end

		setVipBadge(source,bool)
		if bool == true then
			vip_outputChatBox("Vip badge successfully enabled!",source,0,255,0)
		elseif bool == false then
			vip_outputChatBox("Vip badge successfully disabled!",source,0,255,0)
		end
		
	end
)

addEventHandler('onResourceStop', resourceRoot,
function()
	for i, p in ipairs(getElementsByType('player')) do
		removeElementData( p, 'gcshop.vipbadge' )
	end
end)