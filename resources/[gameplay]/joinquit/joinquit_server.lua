addEventHandler("onPlayerJoin", root,
    function()		
        local country = exports.geoloc:getPlayerCountryName(source)
		country = country and (' (' .. country .. ')') or ''
		local redirect = ''
		if getElementData(source, 'redirectedFrom') then
			redirect = ' from ' .. string.lower(getElementData(source, 'redirectedFrom'))
			removeElementData(source, 'redirectedFrom')
		end
		
		-- local joinstr = '* Joins: ' .. getPlayerName(source) .. ' #FF6464'.. country .. redirect
		local joinstr = '✶ Joined: ' .. getPlayerName(source) .. '#FF6464'.. country ..' joined the server'.. redirect
		for k,v in ipairs(getElementsByType"player")do
			if v ~= source then
				outputChatBox(joinstr, v, 255, 100, 100, true)
			end
		end
		outputServerLog( joinstr )
    end
)

addEventHandler('onPlayerQuit', root,
	function(quittype, reason, resp)
        if quittype == "Kicked" or quittype == "Banned" then
            local rstr = ""
            if reason and 0 < string.len(reason) then
                rstr = ' ('..reason..')'
            end
            -- outputChatBox('* ' .. quittype .. ': ' .. getPlayerName(source) .. '#FF6464 '..rstr, g_Root, 255, 100, 100, true)
            outputChatBox('✶ Quit: ' .. getPlayerName(source) .. '#FF6464 has been ' .. string.lower(quittype) .. ''..rstr, g_Root, 255, 100, 100, true)
		else
			if getElementData(source, 'gotomix') then
				quittype = 'switched to ' .. string.lower(get('interchat.other_server')) .. ' server'
			end
			if (quittype == 'Quit') then
				-- outputChatBox('* Quits: ' .. getPlayerName(source),root,  255, 100, 100, true)
				outputChatBox('✶ Quit: ' .. getPlayerName(source)..'#FF6464 left the server.',root,  255, 100, 100, true)
			else
				-- outputChatBox('* Quits: ' .. getPlayerName(source) .. '#FF6464 [' .. quittype .. ']',root,  255, 100, 100, true)
				outputChatBox('✶ Quit: ' .. getPlayerName(source) .. '#FF6464 ' .. quittype ,root,  255, 100, 100, true)
			end
        end
	end
)