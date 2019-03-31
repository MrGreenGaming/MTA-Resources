local acceptedChars = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
local nickLimit = 22
local handlerConnect = nil

addEvent('onClientRequestNickSettings', true)
addEventHandler('onClientRequestNickSettings', root, 
function()
	triggerClientEvent(source, 'sendNickSettings', source, acceptedChars, nickLimit)
end)

addEvent('onClientChangeCustomNickname', true)
addEventHandler('onClientChangeCustomNickname', root,
function(nick)
	if not hasObjectPermissionTo(source, "command.ban", false) then 
		respondToClient(source, false, "Admin only feature!")
		return 
	end
	
	local isLogged = exports.gc:isPlayerLoggedInGC(source)
	if not isLogged then 
		respondToClient(source, false, "Not logged in!")
		return
	end
	
	local forumid = exports.gc:getPlayerForumID(source)
	
	local colorlessNick = string.gsub(nick, "#%x%x%x%x%x%x", "")
	local nickLength = string.len(colorlessNick)
	
	if nickLength > nickLimit then
		respondToClient(source, false, "Nick is too long")
		return
	elseif nickLength == 0 then
		respondToClient(source, false, "Nick can't be empty")
		return
	end
	
	for i, p in ipairs(getElementsByType("player")) do
		if p ~= source and string.lower(getPlayerName(p):gsub("#%x%x%x%x%x%x", "")) == string.lower(colorlessNick) then
			respondToClient(source, false, "Nick already in use!")
			return
		end
	end
	
	
	dbExec(handlerConnect, "UPDATE gc_nickcache SET colorname=? WHERE forumid=?", nick, forumid)
	
	setPlayerName(source, colorlessNick)
	
	setElementData(source, "vip.colorNick", nick)
	respondToClient(source, true, "Nick successfully set!")
end)

addEvent('onClientResetCustomNickname', true)
addEventHandler('onClientResetCustomNickname', root,
function()
	local isLogged = exports.gc:isPlayerLoggedInGC(source)
	if not isLogged then 
		respondToClient(source, false, "Not logged in!")
		return
	end
	
	local forumid = exports.gc:getPlayerForumID(source)
	
	local success = setElementData(source, 'vip.colorNick', false)
	success = success and dbExec(handlerConnect, "UPDATE gc_nickcache SET colorname=null WHERE forumid=?", forumid)
	
	if success then
		respondToClient(source, success, "Your name was successfully reset!")
	else
		respondToClient(source, success, "There was an error while resetting your name!")
	end
end)

addEventHandler('onPlayerChangeNick', root,
function()
	local isLogged = exports.gc:isPlayerLoggedInGC(source)
	if not isLogged then 
		respondToClient(source, false, "Not logged in!")
		return
	end
	
	local forumid = exports.gc:getPlayerForumID(source)
	
	if getElementData(source, 'vip.colorNick') then
		setElementData(source, 'vip.colorNick', false)
		dbExec(handlerConnect, "UPDATE gc_nickcache SET colorname=null WHERE forumid=?", forumid)
	end
end)

addEventHandler('onResourceStart', resourceRoot,
function()
	handlerConnect = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname" .. ';charset=utf8mb4', get("*gcshop.user"), get("*gcshop.pass"))
	if not handlerConnect then
		outputDebugString('colornick error: could not connect to the mysql db')
		return
	end
end)

addEvent('onGCShopLogin', true)
addEventHandler('onGCShopLogin', root,
function(forumid)
	local qh = dbQuery(handlerConnect, "SELECT colorname FROM gc_nickcache WHERE forumid=?", forumid)
	local res = dbPoll(qh, -1)
	if #res ~= 1 then return end
	if not res[1].colorname then return end
	
	setPlayerName(source, string.gsub(res[1].colorname, "#%x%x%x%x%x%x", ""))
	setElementData(source, 'vip.colorNick', res[1].colorname)
	respondToClient(source, true, "Your nickname has been set to your VIP nickname.")
end)

function respondToClient(player, success, message)
	if success then
		outputChatBox(message, player, 0, 255, 100)
	else
		outputChatBox(message, player, 255, 50, 0)
	end
end
