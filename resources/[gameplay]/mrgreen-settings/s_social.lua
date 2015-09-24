function join_setSerial()
	setElementData( source, "pser", getPlayerSerial( source ), true )
end
addEventHandler ( "onPlayerJoin", root, join_setSerial )

function start_setSerial()
	for f,u in pairs(getElementsByType( "player" )) do
		if not hasObjectPermissionTo(u, "function.kickPlayer") then
			setElementData( u, "pser", getPlayerSerial( u ), true )
		end
	end
end
addEventHandler ( "onResourceStart", resourceRoot, start_setSerial )

function antiAdminIgnore()
	if hasObjectPermissionTo(source, "function.kickPlayer") then
		setElementData(source, "pser", "admin", true)
		recountAdmins()
	end
end
addEventHandler("onPlayerLogin", getRootElement(), antiAdminIgnore)

addEvent("requestAdminTable", true)
adminTable = {}
function recountAdmins()
	local t = {}
	for k,v in ipairs ( getElementsByType("player") ) do
		while true do
			local acc = getPlayerAccount(v)
			if not acc or isGuestAccount(acc) then break end
			local accName = getAccountName(acc)
			local isAdmin = isObjectInACLGroup("user."..accName,aclGetGroup("Admin"))
			if isAdmin == true then
				table.insert(t,v)
			end
			break
		end
	end
	if #adminTable ~= #t then
		adminTable = t
		sendAdminTabletoClients(adminTable)
	end
end	
addEventHandler("requestAdminTable", resourceRoot, recountAdmins)
addEventHandler("onPlayerQuit", getRootElement(), recountAdmins)



function sendAdminTabletoClients(t)
	triggerClientEvent( getRootElement(), "receiveAdminTable", resourceRoot, t)
end

