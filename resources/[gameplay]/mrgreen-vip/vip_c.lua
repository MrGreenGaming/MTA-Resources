playerOptions = {
	-- 	timestamp: expireTimestamp, 
	-- 	options: {
	-- 		[1] = {options},
	-- 		[2] = (options)
	-- 	}

}

vipTimeLeftLabelTimer = false


function receiveVip(vipPlayerInfo)
	playerOptions = vipPlayerInfo
	handleVipTimeLeftLabel()
	if isTimer(vipTimeLeftLabelTimer) then
		killTimer( vipTimeLeftLabelTimer )
	end
	vipTimeLeftLabelTimer = setTimer(handleVipTimeLeftLabel,1000,0)
	populateGuiOptions(vipPlayerInfo.options)
	enableVipTabs(true)
	
end
addEvent( 'onServerSendVip', true )
addEventHandler( 'onServerSendVip', resourceRoot, receiveVip )
addEvent( 'onServerChangedPlayerVipOptions', true)
addEventHandler( 'onServerChangedPlayerVipOptions', resourceRoot, receiveVip )

function removedFromVip()
	vip_outputChatBox("You are no longer VIP.",255)
	if isTimer(vipTimeLeftLabelTimer) then
		killTimer(vipTimeLeftLabelTimer)
	end
	guiSetSelectedTab( gui["vipTabs"], gui["tab_home"] )
	enableVipTabs(false)
	playerOptions = {}
	guiSetText( gui["vipLeftLabel"], "You do not have VIP" )
	guiLabelSetColor(gui["vipLeftLabel"],255,0,0)
end
addEvent('onServerRemovedVip',true)
addEventHandler( 'onServerRemovedVip', resourceRoot, removedFromVip)



function requestVip()
	triggerServerEvent( 'onClientRequestsVip', resourceRoot)
end
addEventHandler('onClientResourceStart', resourceRoot, requestVip)


