

-------------------------
---   Updating shop   ---
-------------------------

addEvent('onGCShopLogin')
addEvent('onGCShopLogout')
function gcLogin ( forumID, amount )
	triggerClientEvent ( source, 'cShopGCLogin', source, forumID, amount )
	triggerEvent( 'onGCShopLogin', source, forumID, amount )
end
function gcLogout( forumID )
	triggerClientEvent ( source, 'cShopGCLogout', source, forumID )
	triggerEvent( 'onGCShopLogout', source, forumID )
end

addEvent('onShopInit', true)
addEventHandler('onShopInit', root, function()
		if exports.gc and exports.gc:isPlayerLoggedInGC(client) then
			local forumID = exports.gc:getPlayerForumID(client)
			local amount = exports.gc:getPlayerGreencoins(client)
			triggerClientEvent ( client, 'cShopGCLogin', client, forumID, amount )
			triggerEvent( 'onGCShopLogin', client, forumID, amount )
		else
			triggerClientEvent ( client, 'cShopGCLogout', client, true )
			triggerEvent( 'onGCShopLogout', source )
		end
		--addEventHandler("onPlayerLogin" , client, mtaLogin )
		--addEventHandler("onPlayerLogout", client, mtaLogout)
		addEventHandler("onGCLogin" , client, gcLogin )
		addEventHandler("onGCLogout", client, gcLogout)
end)


--------------------------
---   Safe purchases   ---
--------------------------

function gcshopBuyItem ( player, price, itemText )
	if (not isElement(player)) and not (getElementType(player) == 'player') then return end
	price = tonumber(price)
	itemText = itemText or ''
	if not exports.gc:isPlayerLoggedInGC( player ) then
		outputChatBox('You\'re not logged into a Green-Coins account!', player, 255, 0, 0 )
		return
	elseif not exports.gc:getPlayerGreencoins( player ) then
		outputChatBox('Your Green-Coins account is bugged! Please do a /reconnect and try again', player, 255, 0, 0 )
		return
	elseif (not price) or (exports.gc:getPlayerGreencoins( player ) - price) < 0 then
		outputChatBox('You don\'t have enough Green-Coins to buy this!', player, 255, 0, 0 )
		return
	end

	local amount1 = exports.gc:getPlayerGreencoins( player )
	local check = exports.gc:addPlayerGreencoins( player, - price )
	local amount2 = exports.gc:getPlayerGreencoins( player )
	local name, acc, forumid = getPlayerName(player), (isGuestAccount(getPlayerAccount(player)) and '') or getAccountName(getPlayerAccount(player)), tostring(exports.gc:getPlayerForumID( player ))
	local serial, email = getPlayerSerial (player),  tostring(exports.gc:getPlayerGreencoinsLogin( player ) )

	pcall(addToLog, 'PURCHASE ' .. itemText .. ' : ' .. tostring(amount1) .. '-' .. tostring(price) .. '=' .. tostring(amount2) .. '(' .. tostring(check) .. ') - ' .. name ..'/'.. acc ..'/'.. forumid ..'/'.. serial ..'/'.. email)

	return check and ( (amount1 - price) == amount2), not ( (amount1 - price) == amount2)
end


-----------------------------
---   Logging purchases   ---
-----------------------------

local logFile = false
handlerConnect = nil			-- mysql handler

function addToLog(text)
	local t = getRealTime()
	if not isElement(logFile) then
		logFile = fileOpen("shop.log")
		if not logFile then
			logFile = fileCreate("shop.log")
		else
			fileSetPos(logFile, fileGetSize(logFile))
		end
		--fileWrite(logFile, "\r\n\r\n****** GCSHOP LOG OPENED - ".. getRealDateTimeString(t) .." ******\r\n\r\n")
	end
	text = "[" .. getRealDateTimeString(t) .. "] " .. tostring(text or '')
	fileWrite(logFile, text.."\r\n")
	fileFlush(logFile)
	fileClose(logFile)
	return true
end
addCommandHandler ( "addToLog", function(p, c, text) outputChatBox(tostring(addToLog(text))) end, true, true )

-- srun set("*gcshop.host", 'ares.limetric.com'); set("*gcshop.dbname", 'mrgreen_mtasrvs'); set("*gcshop.user", 'mrgreen_gcmta'); set("*gcshop.pass", 'pass');

addEvent'shopStarted'
function onStart()
	if isTimer(adTimer) then killTimer(adTimer) end
	adTimer = setTimer(function()
	exports.messages:outputGameMessage("Want some more GreenCoins?", root, 3, 255, 255, 255, true)
	setTimer(function() exports.messages:outputGameMessage("Then visit: https://mrgreengaming.com/greencoins/donate", root, 2.4, 50, 205, 50, true) end, 1000, 1)
	end, 2700000, 0)

	handlerConnect = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname" .. ';charset=utf8mb4', get("*gcshop.user"), get("*gcshop.pass"))
	addToLog ( "\r\n\r\n****** GCSHOP LOG OPENED - ".. getRealDateTimeString(getRealTime()) .." ******\r\n\r\n" )
	if not handlerConnect then
		outputDebugString('GCSHOP Database error: could not connect to the mysql db')
		addToLog ( 'Could not connect to the mysql db' )
	elseif handlerConnect then
		-- startUpFetch()
	end


	addToLog ( 'Shop started' )
	triggerEvent('shopStarted', resourceRoot)
end
addEventHandler('onResourceStart', resourceRoot, onStart )

addEvent'shopStopped'
function onStop()
	addToLog ( 'Shop stopped' )
	triggerEvent('shopStopped', resourceRoot)
end
addEventHandler('onResourceStop', resourceRoot, onStop )

function getRealDateTimeString( time )
	return string.format( '%04d-%02d-%02d %02d:%02d:%02d'
						,time.year + 1900
						,time.month + 1
						,time.monthday
						,time.hour
						,time.minute
						,time.second
						)
end


addEventHandler("onResourceStart", resourceRoot,
    function()
        if getResourceFromName("cw_script") and getResourceState(getResourceFromName("cw_script")) == "running" then
            cancelEvent(true, "Can't start gcshop whilst cw_script is running")
            outputChatBox("Can't start gcshop whilst cw_script is running.", root, 255, 0, 0)
        end
    end
)
