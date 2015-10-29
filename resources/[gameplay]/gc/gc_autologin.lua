-------------------
---  Autologin  ---
-------------------

loginTable = "gc_autologin"
handlerConnect = nil

-- Setup sql database --
function startup()
	handlerConnect = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname", get("*gcshop.user"), get("*gcshop.pass"))
end

addEventHandler("onResourceStart", resourceRoot, startup)


function clientStart()
	local player = client
	checkPlayerSerialGreencoins(player)
	local serial = getPlayerSerial ( player )
	if handlerConnect then
		local query = dbQuery (autologinInfoReceived, {player}, handlerConnect, "SELECT forumid FROM `??` WHERE last_serial=?", loginTable, serial)
	end
end

addEvent ( 'onClientGreenCoinsStart', true )
addEventHandler('onClientGreenCoinsStart', root, clientStart)

function autologinInfoReceived (query, player)
	local results = dbPoll ( query, -1 )
	if results and #results > 0 and tonumber(results[1].forumid) then
		onAutoLogin ( tonumber(results[1].forumid), player )
	end
end

function updateAutologin ( player, forumid )
	local serial = getPlayerSerial ( player )
	local date = getRealDateTimeNowString()
	local ip = getPlayerIP(player)
	dbExec ( handlerConnect, "INSERT INTO `??` (forumid, last_serial, last_login, last_ip) VALUES (?,?,?,?) ON DUPLICATE KEY UPDATE forumid=?, last_login=?, last_ip=?",
	loginTable, forumid, serial, date, ip, forumid, date, ip )
end


function deleteAutologin ( forumid )
	dbExec ( handlerConnect, "DELETE FROM `??` WHERE forumid=?", loginTable, forumid )
end

