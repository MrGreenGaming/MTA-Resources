
function rainbowcmd (psource,cmd)
	if ( hasObjectPermissionTo ( psource, "function.kickPlayer", false ) ) then
		if getElementData(psource,'vip.rainbow') then
			removeElementData( psource, 'vip.rainbow' )
			outputChatBox( 'VIP rainbow effect deactivated', psource, 0, 0, 255 )
		else
			setElementData( psource, 'vip.rainbow', true )
			outputChatBox( 'VIP rainbow effect activated', psource, 0, 0, 255 )
		end
	end
end
addCommandHandler( 'viprainbow', rainbowcmd )


