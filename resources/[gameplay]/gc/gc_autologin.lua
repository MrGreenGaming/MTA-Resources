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
	local serial = getPlayerSerial ( player )
	if handlerConnect then
		local query = dbQuery (autologinInfoReceived, {player}, handlerConnect, "SELECT forum_email, forum_password FROM `??` WHERE last_serial=?", loginTable, serial)
	else
		checkPlayerSerialGreencoins(player)
	end
end

addEvent ( 'onClientGreenCoinsStart', true )
addEventHandler('onClientGreenCoinsStart', root, clientStart)

function autologinInfoReceived (query, player)
	local results = dbPoll ( query, -1 )
	if results and #results > 0 then
		onLogin ( results[1].forum_email, results[1].forum_password, true, player )
	else
		checkPlayerSerialGreencoins(player)
	end
end

function addAutologin ( player, email, pw )
	local serial = getPlayerSerial ( player )
	local date = getRealDateTimeNowString()
	local ip = getPlayerIP(player)
	local query = dbQuery (handlerConnect, "SELECT forum_email, forum_password FROM `??` WHERE last_serial=?", loginTable, serial)
	local results = dbPoll ( query, -1 )
	if results and #results < 1 then
		dbExec ( handlerConnect, "INSERT INTO `??` VALUES (?,?,?,?,?)", loginTable, email, pw, serial, date, ip )
	end
end


function updateAutologin ( player )
	local serial = getPlayerSerial ( player )
	local date = getRealDateTimeNowString()
	local ip = getPlayerIP(player)
	dbExec ( handlerConnect, "UPDATE `??` SET last_login=?, last_ip=? WHERE last_serial=?", loginTable, date, ip, serial )
end


function deleteAutologin ( email )
	dbExec ( handlerConnect, "DELETE FROM `??` WHERE forum_email=?", loginTable, email )
end

