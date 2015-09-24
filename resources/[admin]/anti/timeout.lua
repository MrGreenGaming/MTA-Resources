local suspectPlayers = {}
function ping()
	setElementData(client, 'lastping', getRealTime().timestamp)
end
addEvent('ping', true)
addEventHandler('ping', root, ping)


setTimer(function()
	for k, v in ipairs(getElementsByType'player') do
		local lastping = getElementData(v,'lastping')
		if lastping and getRealTime().timestamp - lastping > 15 and not suspectPlayers[v] then

			if not suspectPlayers[v] then
				local p = getPlayerPing(v)
				suspectPlayers[v] = {}
				table.insert(suspectPlayers[v],{ping = p})
			end

		end
	end
end, 20000, 0)



function checkSuspectPlayers() -- Check if FPS and Ping are constant before real kick, this should eliminate all false positives

	for player, t in pairs(suspectPlayers) do
		if #t < 4 then -- only record 4 times
			

			local p = getPlayerPing(player)
			table.insert(suspectPlayers[player],{ping = p})
		elseif #t >= 4 then -- if recorded 4 times then compare
			local isTimedOut = true

			for i=1,3 do
				if t[i][ping] ~= t[i+1][ping] then -- If ping/fps has changed in the meantime, it means the player is not timed out
					isTimedOut = false
					
					break
				end
			end

			if isTimedOut then
				suspectPlayers[player] = nil
				kickPlayer(player, 'Timed out (timeout detection)')
				return
			end

			suspectPlayers[player] = nil -- Player is not timed out
		end
	end

end
setTimer(checkSuspectPlayers,2000,0)

