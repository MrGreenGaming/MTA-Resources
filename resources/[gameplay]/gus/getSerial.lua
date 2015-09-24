local g_Root = getRootElement()
local g_ResRoot = getResourceRootElement(getThisResource())


function addToList(player)

	if isElement(player) then
		
	local playername = getPlayerName(player)
	local date = "not set yet"
	playername = string.gsub (getPlayerName(player), '#%x%x%x%x%x%x', '' )
	if string.find(playername, "?", 1, true) then
		playername = string.gsub(playername, '?', '' )
	end	
	if string.find(playername, "'", 1, true) then
		playername = string.gsub(playername, "'", '' )
	end	
	local serial = getPlayerSerial(player)
	local ip = getPlayerIP(player)
	local cmd = ''
	local query 
	local sql	
	if handlerConnect then
			cmd = "SELECT serial, playername, ip FROM serialsDB WHERE playername = ? LIMIT 1"
			query = dbQuery(handlerConnect, cmd, playername)
			sql = dbPoll(query, -1)
			if #sql > 0 then
				if sql[1].serial ~= serial then
					cmd = "UPDATE serialsDB SET serial = ? WHERE playername = ?"
					dbExec(handlerConnect, cmd, serial, playername)
				end
				if sql[1].ip ~= ip then
					cmd = "UPDATE serialsDB SET ip = ? WHERE playername = ?"
					dbExec(handlerConnect, cmd, ip, playername)
				end
			else
				cmd = "INSERT INTO serialsDB (playername, serial, date, ip) VALUES(?, ?, ?, ?)"
				dbExec(handlerConnect, cmd, playername, serial, date, ip)
			end
		end
	end	
end


--local canScriptWork = true
addEventHandler('onResourceStart', g_ResRoot,
	function()
		handlerConnect = dbConnect( 'mysql', 'host=' .. get"*gcshop.host" .. ';dbname=' .. get"*gcshop.dbname", get("*gcshop.user"), get("*gcshop.pass"))
		if not handlerConnect then
				outputDebugString('Serial/IP Database error: could not connect to the mysql db')
				--canScriptWork = false
				return
		end
		for i,j in ipairs(getElementsByType('player')) do 
			addToList(j)
		end	
	end
)

add = { } 
nick = { }
addEventHandler('onPlayerChangeNick', getRootElement(),
function(old,new)
	--if not canScriptWork then return end
	add[source] = setTimer(addToList,5000,1,source)	
	if string.find(new, "?", 1, true) or string.find(new, "'", 1, true) then
		outputChatBox("No '?' character allowed in nickname.", source)
		outputChatBox("No ' character allowed in nickname.", source)
		cancelEvent()
		-- nick[source] = setTimer(setPlayerNameWithCheck,6000,1,source,string.gsub(new, '?', '' ))
	end	

end
)

addEventHandler('onPlayerJoin', getRootElement(),
function()
	--if not canScriptWork then return end
	if string.find(getPlayerName(source), "?", 1, true) or string.find(getPlayerName(source), "'", 1, true) then
		outputChatBox("No '?' or  character allowed in nickname.", source)
		outputChatBox("No ' character allowed in nickname.", source)
		-- setTimer(setPlayerName,2000,1,source,"Guest"..tostring(getRealTime().timestamp))
		setPlayerName(source,"Guest"..tostring(getRealTime().timestamp))
		-- nick[source] = setTimer(setPlayerNameWithCheck,5000,1,source, string.gsub(getPlayerName(source), '?', '' ))
	end	

	addToList(source)
end
)

function setPlayerNameWithCheck(player,newName)

end


addEventHandler('onPlayerQuit', getRootElement(),
function()
	--if not canScriptWork then return end
	local realTime = getRealTime()
	if realTime.hour == 0 then realTime.hour = 23
	else realTime.hour = realTime.hour - 1
	end
	date = string.format("%02d/%02d/%04d", realTime.month + 1, realTime.monthday, realTime.year + 1900 )
    time = string.format("%02d:%02d", realTime.hour, realTime.minute )
	datetime = date.." "..time
	local name = getPlayerName(source)
	name = string.gsub (name, '#%x%x%x%x%x%x', '' )
	local cmd = ''
	local query 
	local sql
	if handlerConnect then
			cmd = "UPDATE serialsDB SET date = ? WHERE playername = ?"
			dbExec(handlerConnect, cmd, datetime, name)
	end	
end
)

addCommandHandler('seen', 
function(player,cmd,par)
	if not par then outputChatBox("State the player's full name.",player,0, 255, 0) return end
	par = string.gsub (par, '#%x%x%x%x%x%x', '' )
	if getPlayerFromPartialName(par) then outputChatBox(par.." is online right now.", player, 0, 255, 0 ) return end
	local cmd = ''
	local query 
	local sql
	if handlerConnect then
		cmd = "SELECT date, playername FROM serialsDB WHERE playername = ? LIMIT 1"
		query = dbQuery(handlerConnect, cmd, par)
		sql = dbPoll(query, -1)
		if #sql > 0 then
			local name = sql[1].playername
			local date = sql[1].date
			if date == nil then 
				outputChatBox("No database entry available yet for "..name, player,0, 255, 0)
			else
				outputChatBox(name.." was last seen on: "..date.." (GMT Time)",player,0, 255, 0)
			end
		else outputChatBox(par.." was never seen online.", player,0, 255, 0)
		end
	end	
end
)

addCommandHandler('serialnicks',
function (p,c,serial)
	local cmd = ''
	local query 
	local sql
	if handlerConnect then
		local stringOfPlayers = ""
		cmd = "SELECT serial, playername FROM serialsDB WHERE serial LIKE ?"
		query = dbQuery(handlerConnect, cmd, "%" .. serial .. "%")
		sql = dbPoll(query, -1)
		if #sql > 0 then
			outputChatBox('There are ' .. #sql .. ' matches for \'' .. serial .. '\':',p)
			for i = 1, #sql do 			
					if #stringOfPlayers == 0 then
						stringOfPlayers = sql[i].playername
					elseif i % 5 == 0 then
						outputChatBox(stringOfPlayers .. ' ,',p)
						stringOfPlayers = sql[i].playername
					else
						stringOfPlayers = stringOfPlayers.." , "..sql[i].playername
					end			
			end		
			return outputChatBox(stringOfPlayers,p) 
		else return outputChatBox('There are 0 matches for \'' .. serial .. '\':',p)
		end
	else return false	
	end
end
,true)

function getSerial(playername)
	--if not canScriptWork then return false end
	local cmd = ''
	local query 
	local sql
	if handlerConnect then
		cmd = "SELECT serial, ip, playername FROM serialsDB WHERE playername = ? LIMIT 1"
		query = dbQuery(handlerConnect, cmd, playername)
		sql = dbPoll(query, -1)
		if sql[1] then
			return { serial = sql[1].serial, ip = sql[1].ip }
		else return false
		end
	end	
end

function getPlayerFromPartialName(name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end