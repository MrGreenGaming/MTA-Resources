-- Clientside so canceled nick changes dont show up
addEventHandler('onClientPlayerChangeNick', root,
	function(oldNick, newNick )
		-- Do not show for VIP's with supernick
		if getElementData(source, "vip.colorNick" ) then return end
		outputChatBox('* ' .. oldNick .. '#FF6464 is now known as ' .. newNick, 255, 100, 100, true)
	end
)