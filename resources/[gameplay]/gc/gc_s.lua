accounts = {}

----------------------------
---  Logging in and out  ---
----------------------------


-- email: forum email or nickname
-- pw: forum password
function onLogin ( email, pw, autologin )
	local player = source
    if not accounts[player] then
        accounts[player] = SAccount:create( player )
        accounts[player]:login(email, pw, player, onLoginSuccessfull)
    else
        triggerClientEvent( player, "onLoginFail", player, true )
    end
	return false
end

function onAutoLogin ( forumID, player )
    if not accounts[player] then
        accounts[player] = SAccount:create( player )
        accounts[player]:loginViaForumID(forumID, player, onLoginSuccessfull)
    else
        triggerClientEvent( player, "onLoginFail", player, true )
    end
	return false
end

function onLoginSuccessfull(result, player)
	if result then
		updateAutologin ( player, accounts[player]:getForumID() )
		triggerClientEvent( player, "onLoginSuccess", player, accounts[player]:getGreencoins(), accounts[player]:getForumName(), accounts[player]:getLoginEmail() )
		triggerEvent( 'onGCLogin', player, accounts[player]:getForumID(), accounts[player]:getGreencoins(), accounts[player]:getForumName())
		local serialGreencoins = getSerialGreencoins (player)
		-- Transfer gc's from serial storage to the forum storage and delete the serial greencoins
		if (serialGreencoins) then
			deleteSerialGreencoins(player)
			addPlayerGreencoins ( player, serialGreencoins )
			outputChatBox('[GC] Adding ' .. serialGreencoins .. ' GC from your rewards without an account', player, 0, 255, 0)
		end
		-- Download player forum avatar
		if accounts[player]:getProfileData() and accounts[player]:getProfileData()["photoThumb"] and string.find(accounts[player]:getProfileData()["photoThumb"], "photo-") then
			outputDebugString("forumAvatar1 " .. accounts[player]:getForumName() .. " " .. accounts[player]:getForumID() .. " " .. tostring(accounts[player]:getProfileData()["photoThumb"]))
			fetchRemote(accounts[player]:getProfileData()["photoThumb"], function(data, err) 
			outputDebugString("forumAvatar2 " .. accounts[player]:getForumName() .. " " .. tostring(err))
				if err == 0 then
			outputDebugString("forumAvatar3 " .. accounts[player]:getForumName())
					accounts[player]["photoThumb"] = data
					triggerClientEvent("forumAvatar", resourceRoot, data, accounts[player]:getForumID() )
					setElementData(player,"forumAvatar",{type = "image",src = ":gc/img/photo-thumb-" .. accounts[player]:getForumID() .. ".png",width = 20,height = 20})
				end
			end)
		end
		return true
	else
		triggerClientEvent( player, "onLoginFail", player, nil, not gcConnected() )
		accounts[player]:destroy()
		accounts[player] = nil
	end
end

addEvent('onGCLogin') -- broadcast event
addEvent("onLogin", true)
addEventHandler("onLogin", root, onLogin)

function clientStarted()
	for player, account in pairs(accounts) do
		if accounts[player]["photo"] then
			triggerClientEvent(client, "forumAvatar", resourceRoot, data, accounts[player]:getForumID() )
		end
	end
end
addEvent ( 'onClientGreenCoinsStart', true )
addEventHandler('onClientGreenCoinsStart', root, clientStarted)

function onOtherServerGCLogin ( forumID )
	for player, account in pairs ( accounts ) do
		if account:getForumID() == forumID then
			outputChatBox("[GC] You are logged in on another server!", player, 255, 0, 0)
			triggerEvent ( 'onLogout',  player )
		end
	end
end
addEventHandler('onOtherServerGCLogin', root, onOtherServerGCLogin)


function onLogout (playerElement)
	local source = source or playerElement
    if accounts[source] then
		local email = accounts[source]:getLoginEmail()
		local forumID = accounts[source]:getForumID()
		setElementData(player,"forumAvatar", nil)
        accounts[source]:destroy()
        accounts[source] = nil
        outputChatBox("[GC] Successfully logged out!", source, 0, 255, 0)
        triggerClientEvent(source, "onLogoutSuccess", root)
		triggerEvent( 'onGCLogout', source, forumID )
		deleteAutologin ( forumID )
    else
        outputChatBox("[GC] You're not logged in!", source, 255, 0, 0)
    end
end

addEvent('onGCLogout') -- broadcast event
addEvent("onLogout", true)
addEventHandler("onLogout", root, onLogout)


function onQuit ()
    if accounts[source] then
		local forumID = accounts[source]:getForumID()
		triggerEvent( 'onGCLogout', source, forumID )
        accounts[source]:destroy()
        accounts[source] = nil
    end
end

addEventHandler( "onPlayerQuit", root, onQuit )


function stopup ()
    for k, v in pairs (accounts) do
		local forumID = accounts[k]:getForumID()
		triggerEvent( 'onGCLogout', k, forumID )
        v:destroy(true)
        v = nil
		setElementData(k, "greencoins", nil, true)
    end
	exports.scoreboard:removeScoreboardColumn("greencoins", root)
	exports.scoreboard:removeScoreboardColumn("forumAvatar", root)
end

addEventHandler("onResourceStop", resourceRoot, stopup)


function addScoreboard(resource)
	if (resourceRoot == source or getResourceName ( resource ) == 'scoreboard') then
		exports.scoreboard:scoreboardAddColumn("greencoins", root, 77, "GreenCoins", 30)
		exports.scoreboard:scoreboardAddColumn("forumAvatar", root, 20, "", 1.5)
	end
end
addEventHandler("onResourceStart", root, addScoreboard)


-----------------------------
-- Serial based gc storage --
-----------------------------

local serialGreencoinsTable = "serialGreencoins"
function setupSerialGC()
	executeSQLQuery ( "CREATE TABLE IF NOT EXISTS ? (serial TEXT PRIMARY KEY NOT NULL, greencoins INT NOT NULL)", serialGreencoinsTable )
end
addEventHandler('onResourceStart', resourceRoot, setupSerialGC)

function checkPlayerSerialGreencoins(player)
	local greencoins = getSerialGreencoins ( player )
	if greencoins then
		triggerClientEvent(player, "onGCChange", root, greencoins, true)
		triggerClientEvent(player, "onGCSetVisible", root, true)
	end
end
addEventHandler('onPlayerJoin', root, checkPlayerSerialGreencoins)

function addSerialGreencoins (player, amount)
	local serial = isElement(player) and getPlayerSerial(player)
	amount = tonumber(amount)
	if not serial or not amount then return false end
	
	local greencoins = getSerialGreencoins ( player )
	if (not greencoins) then
		executeSQLQuery("INSERT INTO ? VALUES(?,?)", serialGreencoinsTable, serial, amount )
		triggerClientEvent(player, "onGCChange", root, amount, true)
		triggerClientEvent(player, "onGCSetVisible", root, true)
	else
		executeSQLQuery("UPDATE ? SET greencoins = ? WHERE serial = ?", serialGreencoinsTable, amount + greencoins, serial )
		triggerClientEvent(player, "onGCChange", root, amount + greencoins, true)
	end
end

function getSerialGreencoins (player)
	local serial = isElement(player) and getPlayerSerial(player)
	if not serial then return false end
	
	local results = executeSQLQuery ( "SELECT greencoins FROM ? WHERE serial=?", serialGreencoinsTable, serial )

	return (results and #results > 0) and results[1].greencoins or false
end
	
function deleteSerialGreencoins (player)
	local serial = isElement(player) and getPlayerSerial(player)
	if not serial then return false end
	
	executeSQLQuery("DELETE FROM ? WHERE serial = ?", serialGreencoinsTable, serial )
end
	

------------------------
-- Exported functions --
------------------------

function isPlayerLoggedInGC ( player )
	if accounts[player] then
		return true
	end
	return false
end

function getPlayerForumID ( player )
	if accounts[player] then
		return tonumber(accounts[player]:getForumID()) or false
	end
	return false
end

function getPlayerForumProfileData ( player )
	if accounts[player] then
		return accounts[player]:getProfileData() or false
	end
	return false
end

function getPlayerGreencoinsID ( player )
	if accounts[player] then
		return tonumber(accounts[player]:getGreencoinsID()) or false
	end
	return false
end

function getPlayerGreencoinsLogin ( player )
	if accounts[player] then
		return accounts[player]:getForumName() or false
	end
	return false
end

function getPlayerGreencoinsEmail ( player )
	if accounts[player] then
		return accounts[player]:getLoginEmail() or false
	end
	return false
end

function getPlayerGreencoins ( player )
	if accounts[player] then
		local totalGC = tonumber(accounts[player]:getGreencoins())
		local sessionGC = tonumber(accounts[player]:getSessionGreencoins())
		if totalGC and sessionGC then
			return totalGC, sessionGC
		end
	end
	return getSerialGreencoins (player) or 0
end

local anniversary = { day = 16, month = 9 }
function addPlayerGreencoins ( player, amount )
	if accounts[player] and type(amount) == 'number' then
		amount = math.ceil(amount)
		
		-- Double gc if it's the anniversary
		local time = getRealTime()
		if time.monthday == anniversary.day and time.month+1 == anniversary.month and amount > 0 then
			amount = amount * 2
		end
		
		if (accounts[player]:getGreencoins() + amount) >= 0 then
			GCTextPopUp (player, amount)
			accounts[player]:addGreencoins(amount)
			return true
		end
	else
		GCTextPopUp (player, amount)
		return addSerialGreencoins ( player, amount ) 
	end
	return false
end


------------------------
--  Usefull commands  --
------------------------

-- /addGC <amount> [player]
-- Gives the amount GC to yourself or specified player
function giveGC( source, cmd, amount, argPl)
	if (argPl) then
		player = getPlayerFromName(argPl)						--if an arg is given, use it to find a player
	else
		player = source											--if no arg, use the source
	end
		if accounts[player] and tonumber(amount) then
			accounts[player]:addGreencoins(tonumber(amount))
			if (source ~= player) then 
				outputChatBox('[GC] ' .. getPlayerName(source) .. ' gave ' .. amount .. ' GC to ' .. getPlayerName(player), source, 0x00, 0xFF, 0x00)
			end
			outputChatBox('[GC] ' .. getPlayerName(source) .. ' gave ' .. amount .. ' GC to ' .. getPlayerName(player), player, 0x00, 0xFF, 0x00)
		else
			outputChatBox('[GC] Failed to give "' .. tostring(amount) .. '" GC to "' .. tostring(argPl or getPlayerName(source)) .. '"', source)
		end
end
addCommandHandler("addGC", giveGC, true, false)


-- /greencoins [player]
-- Outputs total and session greencoins
function outputGC(source, cmd, argPl)
	GCplayer = (argPl and getPlayerFromName(argPl)) or source	--if an arg is given, use it to find a player
																--if no arg, use the source
	
	if argPl and (not GCplayer) then							--if an arg was given, check if a player was found
		outputChatBox('Error: No player found for "' .. argPl .. '", please type the full name', source)
	else
		local playerName = getPlayerName(GCplayer)
		if (not accounts[GCplayer]) then						--last check, is the player logged in
			outputChatBox('Error: "' .. playerName .. '" has no Green-Coins account', source)
		else
			local forumID, gcID = getPlayerForumID ( GCplayer ),getPlayerGreencoinsID ( GCplayer )
			local s = '[GC] ' .. playerName .. ' (forumID = ' .. tostring(forumID) ..'/gcID = '.. tostring(gcID) .. ')'
			outputConsole(s, source, 0x00, 0xFF, 0x00, true)
			local gc1, gc2 = getPlayerGreencoins(GCplayer) 
			s = '[GC] ' .. playerName .. '#00FF00 earned ' .. tostring(gc2) .. ' GreenCoins this session (total: ' .. tostring(gc1) .. ')'
			outputChatBox(s, source, 0x00, 0xFF, 0x00, true)
		end
	end
end
addCommandHandler("greencoins", outputGC, false, false)

-- /debuggc [player]
-- Outputs all info from the green-coins database in console

function debuggc (source, cmd, arg1)
	arg1 = getPlayerFromName(arg1 or '') or source
	local acc = accounts[arg1]
	if acc then
		outputConsole ( 'Dump player: ' .. getPlayerName(arg1), source)
		outputConsole ( 'forumID = ' .. 	tostring(acc.gcRecord[1]) .. ' (' .. type(acc.gcRecord[1]) .. ')')
		outputConsole ( 'gcID = ' .. 		tostring(acc.gcRecord[2]) .. ' (' .. type(acc.gcRecord[2]) .. ')')
		outputConsole ( 'gcAmmount = ' .. 	tostring(acc.gcRecord[3]) .. ' (' .. type(acc.gcRecord[3]) .. ')')
		outputConsole ( 'gcSession = ' .. 	tostring(acc.gcRecord[4]) .. ' (' .. type(acc.gcRecord[4]) .. ')')
		outputConsole ( 'getLoginEmail = ' .. 	tostring(acc.gcRecord[5]) .. ' (' .. type(acc.gcRecord[5]) .. ')')
	end
	local theCurrentAccount = getPlayerAccount ( arg1 )
	if not isGuestAccount ( theCurrentAccount ) then
		outputConsole ( 'link_acnt = ' .. tostring(getAccountName ( theCurrentAccount )) .. ' (' .. type(getAccountName ( theCurrentAccount )) .. ')')
		outputConsole ( 'link_nick = ' .. tostring(getAccountData ( theCurrentAccount, 'gc.nick' )) .. ' (' .. type(getAccountData ( theCurrentAccount, 'gc.nick' )) .. ')')
		outputConsole ( 'link_pass = ' .. tostring(getAccountData ( theCurrentAccount, 'gc.pass' )) .. ' (' .. type(getAccountData ( theCurrentAccount, 'gc.pass' )) .. ')')
	end
end
addCommandHandler('debuggc', debuggc, true, false )


setTimer(function()
	for _,player in ipairs(getElementsByType('player')) do
		local acc = accounts[player]
		local playtime = getElementData(player, "playtime")
		if acc and acc.gcRecord[4] and acc.gcRecord[4] > 0 and playtime then
			playtime = split(playtime, ':')
			local gpm = acc.gcRecord[4] / (playtime[1] + playtime[2]/60)
			setElementData(player, 'gpm', math.ceil(gpm))
			setElementData(player, 'sessiongc', acc.gcRecord[4])
		elseif acc and acc.gcRecord[4] == 0 then
			setElementData(player, 'gpm', 0)
			setElementData(player, 'sessiongc', 0)
		else
			setElementData(player, 'gpm', nil)
			setElementData(player, 'sessiongc', nil)
		end
	end
end, 1000, 0)
addCommandHandler('gpm', function(p) exports.scoreboard:scoreboardAddColumn('gpm', p, 35); exports.scoreboard:scoreboardAddColumn('sessiongc', p, 35) end)