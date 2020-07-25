addEvent("playerChatting", true )
addEvent("playerNotChatting", true )

function playerChatting()
	triggerClientEvent("updateChatList", root, source, true)
end

function playerNotChatting()
	triggerClientEvent("updateChatList", root, source, false)
end

addEventHandler("playerChatting", root, playerChatting)
addEventHandler("playerNotChatting", root, playerNotChatting)
addEventHandler ("onPlayerQuit", root, playerNotChatting )