-- DISCLAIMER
--[[
	Any user of this resource is allowed to modify the code for personal use, and are not allowed to share their own version with people. Do not attempt to resell this resource as it is avaiblable for FREE. Anyone caught breaking the disclamer will find themselves in trouble with the law under the Copyright Act 2008. You may use / edit only for PERSONAL USE. This code is copyrighted to Christopher Graham Smith (Urangan, Queensland, AUS).
]]

-- Settings - These settings will change the scripts functions and allow you to disable certain parts.
settings = {
['enableTeamChat'] = true,
['adminTag'] = {
	['enabled'] = true,
	['ACL'] = { -- A bit more advanced.
		{ 'Admin', '#2EFEF7۩║Admin║۩ ' },
		{ 'SuperModerator', '#FF0000☆║SuperModerator║☆ ' },
		{ 'Moderator', '#40FF00۞║Moderator║۞ ' },
		{ 'Everyone', ' ' }
	}
},
['swearFilter'] = {
	['enabled'] = true,
	['swearCost'] = 0,
	['swears'] = { -- Allows you to set the blocked swear words, syntax is ['WORD'] = 'REPLACEMENT'
		['asshole'] = '*******',
		['fuck'] = '****',
		['slut'] = '****',
		['bitch'] = '*****',
		['cunt'] = '****',
		['whore'] = '*****',
		['pussy'] = '*****',
		['fag'] = '***',
		['perro'] = '*****',
		['puta'] = '****',
		['joder'] = '*****'
		}
},
['antiSpamFilter'] = {
	['enabled'] = true,
	['execeptionGroups'] = 'Admin', -- Groups which can spam, eg. 'Admin,SuperModerator,Moderator'
	['chatTimeOut'] = 1.5 -- Set in seconds.
},
['freezeChat'] = {
	['enabled'] = true,
	['command'] = 'freezechat', -- Command to use when activating frozen chat.
	['allowedGroups'] = 'Admin,SuperModerator', -- Groups which have access to this command.
	['resetTime'] = 5 -- Time in minutes before it automatically resets.
},
['clearChat'] = {
	['enabled'] = true,
	['command'] = 'clearchat',
	['allowedGroups'] = 'Admin,SuperModerator'
}
}

-- Required variables
spam = { }
stopChat = false

function chatbox(message, msgtype)
	if stopChat then cancelEvent() outputChatBox('#FF0000[FREEZECHAT] #FFFFFFAn admin has recently frozen chat.', source, 255, 255, 255, true) return end
	local account = getAccountName(getPlayerAccount(source))
	local name = getPlayerName(source)
	local serial = getPlayerSerial(source)
	local r, g, b = getPlayerNametagColor(source)
	local text = message:gsub("%a", string.upper, 1)
	local check = 0
	local spamCheck = false
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
	if msgtype == 0 then
		cancelEvent()
		if not settings['adminTag']['enabled'] and not spam[serial] then
			message = RGBToHex(r, g, b) .. name .. ':#FFFFFF ' .. text
			if 128 <= #message then
				outputChatBox('#FF0000Error: The message you entered is too big, please lower it!', source, 255, 255, 255, true)
			else
				outputChatBox(message, getRootElement(), 255, 255, 255, true)
				aclgroup = split(settings['antiSpamFilter']['execeptionGroups'], ', ') or settings['antiSpamFilter']['execeptionGroups']
				for i, v in ipairs(aclgroup) do	if isObjectInACLGroup("user." .. getAccountName(getPlayerAccount(source)), aclGetGroup(v)) then	spamCheck = true end end
				if not spamCheck then
					if settings['antiSpamFilter']['enabled'] then
						spam[serial] = true
						setTimer(function()
							spam[serial] = false
						end, settings['antiSpamFilter']['chatTimeOut']*1000, 1)
					end
				end
				outputServerLog('CHAT: ' .. name .. ': ' .. text)
			end
			return
		end
		for _,v in ipairs(settings['adminTag']['ACL']) do
			if isObjectInACLGroup('user.' .. account, aclGetGroup(v[1])) and check == 0 and not spam[serial] then
				local message = v[2] .. RGBToHex(r, g, b) .. name .. ":#FFFFFF " .. text
				if 128 <= #message then
					outputChatBox('#FF0000Error: The message you entered is too big, please lower it!', source, 255, 255, 255, true)
					check = 1
				else
					check = 1
					outputChatBox(message, getRootElement(), 255, 255, 255, true)
					if settings['antiSpamFilter']['enabled'] then
						aclgroup = split(settings['antiSpamFilter']['execeptionGroups'], ', ') or settings['antiSpamFilter']['execeptionGroups']
						for i, v in ipairs(aclgroup) do	if isObjectInACLGroup("user." .. getAccountName(getPlayerAccount(source)), aclGetGroup(v)) then	spamCheck = true end end
						if not spamCheck then
							spam[serial] = true
							check = 1
								setTimer(function()
								spam[serial] = false
							end, settings['antiSpamFilter']['chatTimeOut']*1000, 1)
						end
					end
					outputServerLog('CHAT: '.. v[2] .. name .. ': ' .. text)
				end
			elseif spam[serial] and check == 0 then
				outputChatBox('#FF0000Error: Please wait '..settings['antiSpamFilter']['chatTimeOut']..' seconds before saying a message!', source, 255, 255, 255, true)
				check = 1
			end
		end
	elseif msgtype == 1 and not settings['enableTeamChat'] then
		cancelEvent()
	end
end
addEventHandler("onPlayerChat", getRootElement(), chatbox)

addEventHandler("onPlayerQuit", getRootElement(),
function()
	local serial = getPlayerName(source)
	spam[serial] = false
end )

-- Freeze chat
addCommandHandler(settings['freezeChat']['command'],
function(player)
	if not settings['freezeChat']['enabled'] then return end
	aclgroup = split(settings['freezeChat']['allowedGroups'], ', ') or settings['freezeChat']['allowedGroups']
	for i, v in ipairs(aclgroup) do	if isObjectInACLGroup("user." .. getAccountName(getPlayerAccount(player)), aclGetGroup(v)) then	check = true end end
	if not check then return end
	
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
	if not settings['clearChat']['enabled'] then return end
	aclgroup = split(settings['clearChat']['allowedGroups'], ',') or settings['clearChat']['allowedGroups']
	for i, v in ipairs(aclgroup) do if isObjectInACLGroup("user." .. getAccountName(getPlayerAccount(player)), aclGetGroup(v)) then	check = true end end
	if not check then return end
	
	for i = 2, getElementData(player, 'chatLines') do
		outputChatBox(' ')
	end
	outputChatBox('#FF0000[CLEARCHAT]#FFFFFF '..getPlayerName(player)..'  has cleared the chat', getRootElement(), 255, 255, 255, true)
end
)

function RGBToHex(red, green, blue, alpha)
		return string.format("#%.2X%.2X%.2X", red,green,blue)
end