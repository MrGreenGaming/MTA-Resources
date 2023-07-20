settings = {
['adminTag'] = {
    ['enabled'] = true,
    ['ACL'] = { -- A bit more advanced.
        { 'bday', '#FF00FF[Happy Birthday!] ', '[Happy Birthday!]', '#FFFFFF', '%[Happy Birthday!%]' },
        { 'Developer', '#FFA500[Dev] ', '[Dev]', '#FFFFFF', '%[Dev%]' },
        { 'Admin', '#0099FF[Admin] ', '[Admin]', '#FFFFFF', '%[Admin%]' },
        { 'Killers', '#00FFFF[Mod] ', '[Mod]', '#FFFFFF', '%[Mod%]' },
        { 'VIP', '#FFFF00[VIP] ', '[VIP]', '#FFFFFF', '%[VIP%]' },
        { 'Everyone', '', '', '#DDDDDD' },
    }
},
['swearFilter'] = {
    ['enabled'] = false,
    ['swearCost'] = 0,
    ['swears'] = { -- Allows you to set the blocked swear words, syntax is ['WORD'] = 'REPLACEMENT'
        ['asshole'] = '*******',
        }
},
['antiSpamFilter'] = {
    ['enabled'] = false,
    ['execeptionGroups'] = 'Admin,Killers,ServerManager,Developer', -- Groups which can spam, eg. 'Admin,SuperModerator,Moderator'
    ['chatTimeOut'] = 1 -- Set in seconds.
},
['freezeChat'] = {
    ['enabled'] = true,
    ['command'] = 'freezechat', -- Command to use when activating frozen chat.
    ['allowedGroups'] = 'Admin,ServerManager,Developer', -- Groups which have access to this command.
    ['resetTime'] = 5 -- Time in minutes before it automatically resets.
},
['clearChat'] = {
    ['enabled'] = false,
    ['command'] = 'cchat',
    ['allowedGroups'] = 'Admin,ServerManager,Developer'
},
['colorFilter'] = {
	['enabled'] = false,
	['allowedGroups'] = 'Admin,ServerManager,Developer,Killers'
}
}

-- Required variables
spam = { }
stopChat = false

function chatbox(message, msgtype)
	local account = getAccountName(getPlayerAccount(source))
    if stopChat then
		cancelEvent()
		outputChatBox('#FF0000[FREEZECHAT] #FFFFFFAn admin has recently frozen chat.', source, 255, 255, 255, true)
		return
	end
    local name = getElementData(source, "vip.colorNick") or getPlayerName(source)
    local serial = getPlayerSerial(source)
    local r, g, b = getPlayerNametagColor(source)
    local text = message--:gsub("%a", string.upper, 1)
	local originalmsg = message
    local check = 0
    local spamCheck = false
	local colorCheck = false
    if settings['swearFilter']['enabled'] then
        for i, v in pairs(settings['swearFilter']['swears']) do
            while text:lower():find(i:lower(),1,true) do
                local start, end_ = text:lower():find(i:lower(),1,true)
                local found = text:sub(start,end_)
                text = text:gsub(found,v)
                if settings['swearFilter']['swearCost'] ~= 0 then
                    takePlayerMoney(source, settings['swearFilter']['swearCost'])
                end
			end
        end
    end
	--end
    if msgtype == 0 then
        cancelEvent()
        if not settings['adminTag']['enabled'] and not spam[serial] then
			local text1 = text:gsub("#%x%x%x%x%x%x", "")
            message = RGBToHex(r, g, b) .. name .. ':#FFFFFF ' .. text1
            if 128 <= #message then
                outputChatBox('#FF0000Error: The message you entered is too big, please lower it!', source, 255, 255, 255, true)
            else
                --outputChatBox(message, getRootElement(), 255, 255, 255, true)
				triggerEvent("playerMessage", source, originalmsg, message, 'CHAT: ' .. name .. ': ' .. text, false)
                aclgroup = split(settings['antiSpamFilter']['execeptionGroups'], ', ') or settings['antiSpamFilter']['execeptionGroups']
                for i, v in ipairs(aclgroup) do if isObjectInACLGroup("user." .. getAccountName(getPlayerAccount(source)), aclGetGroup(v)) then spamCheck = true end end
                if not spamCheck then
                    if settings['antiSpamFilter']['enabled'] then
                        spam[serial] = true
                        setTimer(function()
                            spam[serial] = false
                        end, settings['antiSpamFilter']['chatTimeOut']*1000, 1)
                    end
                end
                --outputServerLog('CHAT: ' .. name .. ': ' .. text)
            end
            return
        end
        for _,v in ipairs(settings['adminTag']['ACL']) do
            if (v[1]~='VIP' and isObjectInACLGroup('user.' .. account, aclGetGroup(v[1])) and check == 0 and not spam[serial]) or (v[1] == 'VIP' and getResourceState(getResourceFromName('mrgreen-vip')) == 'running' and exports['mrgreen-vip']:isPlayerVIP(source) and check == 0 and not spam[serial])then
				local text1 = text
				if settings['colorFilter']['enabled'] then
					aclgroup = split(settings['colorFilter']['allowedGroups'], ',') or settings['colorFilter']['allowedGroups']
					for i, v in ipairs(aclgroup) do if isObjectInACLGroup("user." .. getAccountName(getPlayerAccount(source)), aclGetGroup(v)) then colorCheck = true end end
					if not colorCheck then
						if string.match(text, "#%x%x%x%x%x%x") then
							outputChatBox("#736F6EYou are not allowed to use ColorCodes in chat, so we have remeoved them", source, 255,255,255,true)
						end
						text1 = text:gsub("#%x%x%x%x%x%x", "")
					end
				end
				message = RGBToHex(r, g, b) .. name .. "#FFFFFF:"..v[4].. text1
                local message = v[2] .. RGBToHex(r, g, b) .. name .. "#FFFFFF:"..v[4].." " .. text1
				local ass = v[4].." " .. text1
				local colorlessMessage = message:gsub("#%x%x%x%x%x%x", "")
                if 200 <= #colorlessMessage then
                    outputChatBox('#FF0000Error: The message you entered is too long, please shorten it!', source, 255, 255, 255, true)
                    check = 1
                else
                    check = 1
                    --outputChatBox(message, getRootElement(), 255, 255, 255, true)
					triggerEvent("playerMessage", source, originalmsg, message, 'CHAT: '.. v[3] .. name .. ': ' .. text1, false)
                    if settings['antiSpamFilter']['enabled'] then
                        aclgroup = split(settings['antiSpamFilter']['execeptionGroups'], ', ') or settings['antiSpamFilter']['execeptionGroups']
                        for i, v in ipairs(aclgroup) do if isObjectInACLGroup("user." .. getAccountName(getPlayerAccount(source)), aclGetGroup(v)) then spamCheck = true end end
                        if not spamCheck then
                            spam[serial] = true
                            check = 1
                                setTimer(function()
                                spam[serial] = false
                            end, settings['antiSpamFilter']['chatTimeOut']*1000, 1)
                        end
                    end
                    --outputServerLog('CHAT: '.. v[3] .. name .. ': ' .. text1)
                end
            elseif spam[serial] and check == 0 then
                outputChatBox('#FF0000Error: Please wait '..settings['antiSpamFilter']['chatTimeOut']..' seconds before saying a message!', source, 255, 255, 255, true)
                check = 1
            end
        end
    elseif msgtype == 2 then
        cancelEvent()
		local team = getPlayerTeam(source)
		if not team then return end
		local teamR, teamG, teamB = getTeamColor(team)
		local message = RGBToHex(teamR, teamG, teamB).."(TEAM) "..name..": #FFFFFF"..originalmsg
		triggerEvent("playerMessage", source, originalmsg, message, 'TEAMCHAT: '..getTeamName(team)..' - '..name.. ': ' ..originalmsg, true)
    end
end
addEventHandler("onPlayerChat", getRootElement(), chatbox)



addEvent("antiResp")
addEventHandler("antiResp", root,
function(msg, logmsg, teamChat)
    -- Ignored Player Check
    if getElementType( source ) == 'player' then
		if not teamChat then
			local sourceSerial = getPlayerSerial( source )
			for i,player in ipairs ( getElementsByType("player") ) do
				local playerIgnoreSettings = getElementData( player, 'mrgreen-settings.ignorelist' )
				if playerIgnoreSettings then
					local isSourceIgnored = false
					playerIgnoreSettings = fromJSON( playerIgnoreSettings )
					for i,serial in ipairs(playerIgnoreSettings) do
						if sourceSerial == serial then
							isSourceIgnored = true
							break
						end
					end

					if not isSourceIgnored then
					  outputChatBox(msg, player, 255, 255, 255, true)
					end

				else
				  outputChatBox(msg, player, 255, 255, 255, true)
				end
			end
		else
			local team = getPlayerTeam(source)
			local sourceSerial = getPlayerSerial( source )
			for i,player in ipairs ( getElementsByType("player") ) do
				if team == getPlayerTeam(player) then
					local playerIgnoreSettings = getElementData( player, 'mrgreen-settings.ignorelist' )
					if playerIgnoreSettings then
						local isSourceIgnored = false
						playerIgnoreSettings = fromJSON( playerIgnoreSettings )
						for i,serial in ipairs(playerIgnoreSettings) do
							if sourceSerial == serial then
								isSourceIgnored = true
								break
							end
						end

						if not isSourceIgnored then
						  outputChatBox(msg, player, 255, 255, 255, true)
						end

					else
					  outputChatBox(msg, player, 255, 255, 255, true)
					end
				end
			end
		end

    elseif not teamChat then
    	outputChatBox(msg, getRootElement(), 255, 255, 255, true)
    end
    outputServerLog(logmsg)
end)

addEventHandler("onPlayerConnect", getRootElement(),
function(nick)
	if not settings['adminTag']['enabled'] then return end
	local name = nick:gsub("#%x%x%x%x%x%x", "")
	local newName
	local changed = false
	for i,v in ipairs(settings['adminTag']['ACL']) do
		if i == #settings['adminTag']['ACL'] then break end
		if string.find(string.lower(name), string.lower(v[5])) then
			cancelEvent(true, "Your name contains illegal tags.\nPlease change your name and rejoin.")
		end
	end
end)

addEventHandler("onPlayerChangeNick", getRootElement(),
function(old, new)
	if not settings['adminTag']['enabled'] then return end
	local name = new:gsub("#%x%x%x%x%x%x", "")
	local newName
	for i,v in ipairs(settings['adminTag']['ACL']) do
		if i == #settings['adminTag']['ACL'] then break end
		if string.find(string.lower(name), string.lower(v[5])) then
			cancelEvent()
			outputChatBox("You name has not been changed because it contained illegal tags!", source, 255, 0, 0)
		end
	end
end)

function trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

addEventHandler("onPlayerQuit", getRootElement(),
function()
    local serial = getPlayerName(source)
    spam[serial] = false
end )

-- Freeze chat
addCommandHandler(settings['freezeChat']['command'],
function(player)
    if not settings['freezeChat']['enabled'] then return end

	local aclgroup = split(settings['freezeChat']['allowedGroups'], ',') or settings['freezeChat']['allowedGroups']
	local allow = false
	for i, v in ipairs(aclgroup) do
		if isObjectInACLGroup("user." .. getAccountName(getPlayerAccount(player)), aclGetGroup(v)) then
			allow = true
			break
		end
	end

   if not allow then return end

    if not stopChat then
        outputChatBox('#FF0000[FREEZECHAT] #FFFFFF'..getPlayerName(player)..' has frozen the chat!', getRootElement(), 255, 255, 255, true)
        stopChat = true
        frozenTimer = setTimer(function() stopChat = false end, (settings['freezeChat']['resetTime'] * 60000), 1)
    else
        outputChatBox('#FF0000[FREEZECHAT] #FFFFFF'..getPlayerName(player)..' has unfrozen the chat!', getRootElement(), 255, 255, 255, true)
        stopChat = false
    end
end
)

-- Clear chat
addCommandHandler(settings['clearChat']['command'],
function(player)
	local check = false
    if not settings['clearChat']['enabled'] then return end
    aclgroup = split(settings['clearChat']['allowedGroups'], ',') or settings['clearChat']['allowedGroups']
    for i, v in ipairs(aclgroup) do if isObjectInACLGroup("user." .. getAccountName(getPlayerAccount(player)), aclGetGroup(v)) then check = true end end
    if not check then return end

    for i = 1, 500 do
        outputChatBox(' ')
    end
    outputChatBox('#FF0000[CLEARCHAT]#FFFFFF '..getPlayerName(player)..'  #FFFFFFhas cleared the chat', getRootElement(), 255, 255, 255, true)
end
)

function RGBToHex(red, green, blue, alpha)
        return string.format("#%.2X%.2X%.2X", red,green,blue)
end


function isStringHexCode(theHex)
    local Hex = theHex:gsub("#", "")
    if #Hex == 6 and tonumber(Hex, 16) then return true end
    return false
end

