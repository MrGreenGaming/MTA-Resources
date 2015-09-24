-- Clientside so canceled nick changes dont show up
addEventHandler('onClientPlayerChangeNick', root,
	function(oldNick, newNick)
		outputChatBox('* ' .. oldNick .. '#FF6464 is now known as ' .. newNick, 255, 100, 100, true)
	end
)